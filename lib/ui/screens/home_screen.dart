import 'package:flutter/material.dart'; import 'package:provider/provider.dart';
import '../../app.dart'; import '../widgets/candles_chart.dart'; import 'news_screen.dart'; import 'signals_screen.dart'; import 'backtest_screen.dart';
class HomeScreen extends StatefulWidget{ const HomeScreen({super.key}); @override State<HomeScreen> createState()=>_S(); }
class _S extends State<HomeScreen>{ final textCtrl=TextEditingController(text:'EURUSD'); String tf='1m';
  @override Widget build(BuildContext context){ final app=context.watch<AppState>(); final series=app.candleRepo.series(app.symbol, app.timeframe);
    return Scaffold(appBar: AppBar(title: const Text('Ultron Signals — Exnova')), body: ListView(padding: const EdgeInsets.all(12), children:[
      Row(children:[ Expanded(child: TextField(controller:textCtrl, decoration: const InputDecoration(labelText:'Par (OTC/normal)', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()), onSubmitted:(v)=>app.setSymbol(v.trim().toUpperCase()))),
        const SizedBox(width:8),
        DropdownButton<String>(value:tf, items: const [DropdownMenuItem(value:'1m',child:Text('1m')), DropdownMenuItem(value:'5m',child:Text('5m'))],
          onChanged:(v){ setState(()=>tf=v!); app.setTF(tf);}),
      ]),
      const SizedBox(height:12),
      Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text('Gráfico ${app.symbol} (${app.timeframe})', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height:8), CandlesChart(data: series),
      ]))),
      const SizedBox(height:12),
      Row(children:[
        Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.flash_on), label: const Text('Señales'),
          onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=> const SignalsScreen())))),
        const SizedBox(width:8),
        Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.event), label: const Text('Noticias'),
          onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=> const NewsScreen())))),
      ]),
      const SizedBox(height:12),
      OutlinedButton.icon(icon: const Icon(Icons.analytics), label: const Text('Backtest (CSV/Excel)'),
        onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=> const BacktestScreen()))),
    ])); }
}
