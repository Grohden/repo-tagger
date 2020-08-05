import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Similar to GetView but this one forces a controller instance to be present
/// (get loses itself sometimes)
abstract class TaggerPage<T> extends StatelessWidget {
  const TaggerPage({Key key}) : super(key: key);

  T provider();

  T get controller => Get.put<T>(provider());
}
