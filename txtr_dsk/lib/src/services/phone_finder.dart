import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:txtr_dsk/src/net/net_repository.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_model.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_service.dart';
import 'package:txtr_shared/txtr_shared.dart';

final List<ActiveHost> phones = [];

class PhoneFinder {
  final _netRepository = NetRepository();

  Future<bool> checkPreviousPhone() async {
    final SettingsModel settings = SettingsService.load();
    try {
      final PhoneDTO phone = await _netRepository.getPhone(settings.phoneIp);
      return phone.name == settings.phoneName;
    } catch (_) {
      if (settings.phoneName.isNotEmpty) {
        final previousPhone = await getPhoneByName(settings.phoneName);
        if (previousPhone.name == settings.phoneName) {
          // Phone with same name found, but different ip
          settings.phoneIp = previousPhone.ip;
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
        final phone = await getPhone(host.address);
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

  Future<List<ActiveHost>> findHosts() async {
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

  Future<PhoneDTO> getPhone(final String ip) async {
    return await _netRepository.getPhone(ip);
  }
}
