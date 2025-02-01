import 'dart:async';

import 'package:haf_spb_app/model/client_info.dart';
import 'package:haf_spb_app/model/instrument_info.dart';

import '../model/forms_history_item.dart';
import '../model/instrument_instance.dart';

import '../logger.dart';
import '../server_connection.dart';
import '../storage.dart';
import '../user_info.dart';

mixin SendFormMixin {
  Future<bool> sendFormAndAddToHistory(
      ServerConnection connection,
      ClientInfo clientInfo,
      InstrumentInfo instrumentInfo,
      int recordId,
      InstrumentInstance instrumentInstance) async {
    if (instrumentInfo.isRepeating) {
      var instanceRecordId = await connection.createNewInstance(
          instrumentInfo, recordId, instrumentInstance);

      if (instanceRecordId == null) {
        return false;
      }
    } else {
      //non-repeatable form
      var newRecordId =
          await connection.editNonRepeatForm(recordId, instrumentInstance);

      if (newRecordId != recordId) {
        logger.d("recordId != _recordId $newRecordId != $recordId");
        return false;
      }
    }

    var historyItem = new FormsHistoryItem(
        tokenHash: UserInfo.tokenHash!,
        createTime: DateTime.now(),
        lastEditTime: DateTime.now(),
        formName: instrumentInfo.formNameId,
        secondaryId: clientInfo.secondaryId,
        instanceNumber: instrumentInstance.number);
    Storage.addFormsHistoryItem(historyItem);
    return true;
  }
}
