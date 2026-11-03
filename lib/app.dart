import 'package:flutter/material.dart';

import 'features/localizacoes/presentation/screens/tela_coleta.dart';
import 'tema_app.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Localizações',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.escuro,
      darkTheme: TemaApp.escuro,
      themeMode: ThemeMode.dark,
      home: const TelaColeta(),
    );
  }
}
