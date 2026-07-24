import 'package:flutter/material.dart';

import 'app.dart';
import 'data/local_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await LocalRepository.create();
  runApp(EasyTyperApp(repository: repository));
}

