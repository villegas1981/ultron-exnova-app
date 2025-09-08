import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/home_screen.dart';
import 'data/candle_repo.dart';
import 'data/news_repo.dart';
import 'logic/signal_engine.dart';
import 'ai/pattern_model.dart';

class AppState extends ChangeNotifier {
  String symbol = 'EURUSD';
  String timeframe = '1m';
  final candleRepo = CandleRepo();
  final newsRepo = NewsRepo();
  late final PatternModel model;
  late final SignalEngine engine;
  AppState(){ model=PatternModel(); engine=SignalEngine(model, threshold:0.62); }
  void setSymbol(String s){ symbol=s; notifyListeners(); }
  void setTF(String tf){ timeframe=tf; notifyListeners(); }
  @override void dispose(){ model.close(); super.dispose(); }
}

class UltronApp extends StatelessWidget {
  const UltronApp({super.key});
  @override
  Widget build(BuildContext context){
    return ChangeNotifierProvider(
      create: (_)=>AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner:false,
        title:'Ultron Signals – Exnova',
        theme: ThemeData(useMaterial3:true, colorSchemeSeed: Colors.teal),
        home: const HomeScreen(),
      ),
    );
  }
}
