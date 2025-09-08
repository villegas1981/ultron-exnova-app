import 'package:flutter/material.dart'; import '../../domain/models.dart';
class SignalsScreen extends StatefulWidget{ const SignalsScreen({super.key}); @override State<SignalsScreen> createState()=>_S(); }
class _S extends State<SignalsScreen>{ final List<Signal> _signals=[];
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('Señales (demo)')),
    body: ListView.separated(padding: const EdgeInsets.all(12), itemBuilder: (_,i){ final s=_signals[i]; return ListTile(
      leading: Icon(s.direction=='CALL'?Icons.north_east:Icons.south_east), title: Text('${s.direction}  conf: ${s.confidence.toStringAsFixed(2)}'), subtitle: Text('${s.time}')); },
      separatorBuilder: (_, __)=> const Divider(), itemCount: _signals.length),
    floatingActionButton: FloatingActionButton.extended(icon: const Icon(Icons.play_arrow), label: const Text('Simular señal'),
      onPressed: (){ final now=DateTime.now(); _signals.insert(0, Signal(time: now, direction: now.second%2==0 ? 'CALL':'PUT', confidence: 0.71)); setState((){}); }), ); }
}
