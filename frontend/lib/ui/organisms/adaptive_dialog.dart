import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../molecules/adaptive_dialog_action.dart';
import '../utils/adaptive.dart';

/// Adaptive dialog that either shows a cupertino or material
/// themed dialog
class AdaptiveDialog extends StatelessWidget {
  const AdaptiveDialog({
    @required this.title,
    this.actions,
    this.content,
  });

  /// Shows a default adaptive dialog with a OK
  /// action that calls Get.back
  factory AdaptiveDialog.alert({@required Widget title, Widget content}) {
    return AdaptiveDialog(
      title: title,
      content: content,
      actions: <Widget>[
        AdaptiveDialogAction(
          child: const Text('Ok'),
          onPressed: Get.back,
        )
      ],
    );
  }

  /// Shows a default adaptive dialog with a yes and no actions
  /// the yes action returns a true value
  factory AdaptiveDialog.confirm({@required Widget title, Widget content}) {
    return AdaptiveDialog(
      title: title,
      content: content,
      actions: <Widget>[
        AdaptiveDialogAction(
          child: const Text('Não'),
          onPressed: Get.back,
        ),
        AdaptiveDialogAction(
          child: const Text('Sim'),
          onPressed: () => Get.back(result: true),
        ),
      ],
    );
  }

  final Widget title;
  final Widget content;
  final List<Widget> actions;

  Widget buildMaterialDialog(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: actions,
    );
  }

  Widget buildCupertinoDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      content: content,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (shouldUseMaterial(theme)) {
      return buildMaterialDialog(context);
    } else {
      return buildCupertinoDialog(context);
    }
  }
}
