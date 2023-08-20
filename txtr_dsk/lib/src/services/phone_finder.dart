import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:txtr_dsk/src/services/net_service.dart';
import 'package:txtr_dsk/src/views/settings/bloc/settings_model.dart';
import 'package:txtr_dsk/src/views/settings/bloc/settings_service.dart';
import 'package:txtr_shared/txtr_shared.dart';

final List<ActiveHost> phones = [];

class PhoneFinder {
  final _netRepository = NetService();

  Future<bool> checkPreviousPhone() async {
    final SettingsModel settings = SettingsService.load();
    try {
      final PhoneDTO phone = await _netRepository.getPhone(settings.phone.ip);
      return phone.name == settings.phone.name;
    } catch (_) {
      if (settings.phone.name.isNotEmpty) {
        final previousPhone = await getPhoneByName(settings.phone.name);
        if (previousPhone.name == settings.phone.name) {
          // Phone with same name found, but different ip
          settings.phone = previousPhone;
          SettingsService.save(settings);
          return true;
        }
      }
      return false;
    }
  }

  Future<PhoneDTO> getPhoneByName(final String phoneName) async {
    final String? myIp = await NetworkInfo().getWifiIP();
    if (myIp == null) return PhoneDTO.empty();
    final completer = Completer<PhoneDTO>();
    final String subnet = myIp.substring(0, myIp.lastIndexOf('.'));

    HostScanner.scanDevicesForSinglePort(
      subnet,
      TxtrShared.restPort,
    ).listen(
      (host) async {
        // found host, check that name matches
        final phone = await _getPhone(host.address);
        if (phone.name == phoneName) {
          completer.complete(phone);
        }
      },
      onDone: () {
        debugPrint('Scan completed');
      },
    );
    return await completer.future;
  }

  Future<List<PhoneDTO>> findPhones() async {
    final hosts = await _findHosts();
    final List<PhoneDTO> phones = [];
    for (final h in hosts) {
      try {
        final PhoneDTO phone = await _getPhone(h.address);
        phones.add(phone);
      } catch (e) {
        // ignore hosts that don't respond to getPhone
        debugPrint('getPhone(${h.address}): $e');
      }
    }
    return phones;
  }

  Future<List<ActiveHost>> _findHosts() async {
    final String? myIp = await NetworkInfo().getWifiIP();
    if (myIp == null) return [];
    final completer = Completer<List<ActiveHost>>();
    final String subnet = myIp.substring(0, myIp.lastIndexOf('.'));
    phones.clear();
    HostScanner.scanDevicesForSinglePort(subnet, TxtrShared.restPort,
            progressCallback: (progress) {
      debugPrint('Progress for host discovery : $progress');
    }, resultsInAddressAscendingOrder: true)
        .listen(
      (host) {
        phones.add(host);
      },
      onDone: () {
        completer.complete(phones);
        debugPrint('Scan completed');
      },
    );
    return await completer.future;
  }

  Future<PhoneDTO> _getPhone(final String ip) async {
    return await _netRepository.getPhone(ip);
  }
}
