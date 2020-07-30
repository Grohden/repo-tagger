import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../organisms/adaptive_dialog.dart';

/// Utility controller for forms
abstract class FormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final showLoading = false.obs;
  final autoValidate = false.obs;

  /// Validates the current form
  /// can be overridden to provide custom validation
  FutureOr<bool> isValid() => formKey.currentState.validate();

  /// Classes that extends [FormController]
  /// should submit data without further validations
  /// and can omit catch clauses (see [submit])
  @protected
  Future onSubmit();

  /// Submits the form, calling the validation function
  /// for the [formKey] and enabling [autoValidate]
  /// in the case of a invalid form
  ///
  /// it also handles the submit failure response
  /// and show a default dialog with the
  /// backend error message (if available)
  Future submit() async {
    if (showLoading.value) {
      return;
    }

    if (!(await isValid())) {
      autoValidate.value = true;

      return;
    }

    try {
      showLoading.value = true;
      await onSubmit();
    } on DioError catch (error) {
      Get.dialog(AdaptiveDialog.alert(
        title: const Text('Error!'),
        content: Text(error.response?.data?.toString() ?? 'Unknown'),
      ));
    } finally {
      showLoading.value = false;
    }
  }
}
