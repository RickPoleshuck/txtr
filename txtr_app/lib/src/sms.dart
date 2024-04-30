import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:txtr_shared/txtr_shared.dart';
import 'package:background_sms/background_sms.dart';

class Sms {
  final _query = SmsQuery();
  static const List<SmsQueryKind> defaultKinds = [
    SmsQueryKind.inbox,
    SmsQueryKind.sent
  ];

  Future<List<SmsMessage>> query(
      {int count = 10, List<SmsQueryKind> kinds = defaultKinds}) async {
    final messages = await _query.querySms(
      kinds: kinds,
      count: count,
    );
    return messages;
  }

  Future<SmsStatus> send(final TxtrMessageDTO message) async {
    SmsStatus result = await BackgroundSms.sendMessage(phoneNumber: message.address, message: message.body);
    return result;
  }
}
