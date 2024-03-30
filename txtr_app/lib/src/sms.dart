import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:txtr_shared/txtr_shared.dart';

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

  Future<String> send(final TxtrMessageDTO message) async {
    String result =
        await sendSMS(message: message.body, recipients: [message.address])
            .catchError((e) {
      return e.toString();
    });
    return result;
  }
}
