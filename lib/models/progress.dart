import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ProgressDialogWrapper{
  ProgressDialog _progressDialog;
  double _maxProgress;

  ProgressDialogWrapper(BuildContext context, String initMessage, double maxProgress,){
    this._maxProgress = maxProgress;
    this._progressDialog = ProgressDialog(context, type: ProgressDialogType.Download,);
    this._progressDialog.style(
        message: initMessage,
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 1,
        maxProgress: this._maxProgress,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
  }

  void updateProgressDialog(String message, double currentStep) async {
    this._progressDialog.update(
        message: message,
        progressWidget: CircularProgressIndicator(),
        progress: currentStep,
        maxProgress: this._maxProgress,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
  }

  Future showProgressDialog() async {
    await this._progressDialog.show();
  }

  Future dismissProgressDialog() async {
    await this._progressDialog.hide();
  }
}