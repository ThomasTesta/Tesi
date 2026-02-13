import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/di.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: AppDI.providers(),
      child: const AppRoot(),
    ),
  );
}

//kevin@gmail.com 
//password: password123!   (provarea aneh P maiuscola in caso)