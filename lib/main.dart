import 'package:flutter/material.dart';
import 'package:kintore/src/app.dart';
import 'package:kintore/src/service_locator.dart';

void main() {
  // DB初期化がrunApp前に始まるため、プラットフォームチャネルを
  // 使える状態にしておく。
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const KintoreApp());
}
