import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:excel/excel.dart';
import '../../data/csv_loader.dart';
import '../../logic/signal_engine.dart';
import '../../domain/models.dart';
import '../../app.dart';
import 'package:provider/provider.dart';

class BacktestScreen extends StatefulWidget {
  const BacktestScreen({super.key});
  @override State<BacktestScreen> createState()=>_BacktestScreenState();
}

class _BacktestScreenState extends State<BacktestScreen> {
  bool _loading=false;
  String _summary='';
  int _signals=0, _wins=0, _loss=0;
  String _tf='1m';
  int _horizon=3;
  final List<List<dynamic>> _rows=[
    ['time','time_iso','direction','confidence','entry','exit','diff','horizon','outcome']
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Backtest (CSV)')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Timeframe:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _tf,
                  items: const [
                    DropdownMenuItem(value:'1m', child: Text('1m')),
                    DropdownMenuItem(value:'5m', child: Text('5m')),
                  ],
                  onChanged: (v)=> setState(()=> _tf=v!),
                ),
                const SizedBox(width: 16),
                const Text('Horizonte:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _horizon,
                  items: const [
                    DropdownMenuItem(value:1, child: Text('1 vela')),
                    DropdownMenuItem(value:3, child: Text('3 velas')),
                    DropdownMenuItem(value:5, child: Text('5 velas')),
                  ],
                  onChanged: (v)=> setState(()=> _horizon=v!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Cargar CSV de velas'),
                  onPressed: _loading ? null : () => _runBacktest(context),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Exportar CSV (Downloads)'),
                  onPressed: _rows.length>1 ? _exportCsvDownloads : null,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.table_view),
                  label: const Text('Exportar Excel (.xlsx)'),
                  onPressed: _rows.length>1 ? _exportExcel : null,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir CSV'),
                  onPressed: _rows.length>1 ? _shareCsv : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            if (_summary.isNotEmpty) Text(_summary, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _runBacktest(BuildContext context) async {
    setState(()=> _loading=true);
    _rows.removeRange(1, _rows.length);
    final candles = await CsvLoader().pickAndLoad();
    if (candles.isEmpty){ setState(()=> _loading=false); return; }

    final app = context.read<AppState>();
    final engine = app.engine;
    final news = <NewsEvent>[];
    int signals=0, wins=0, loss=0;

    for (int i=0; i<candles.length; i++){
      final sub = candles.sublist(0, i+1);
      final sig = engine.evaluate(sub, news);
      if (sig!=null){
        signals++;
        final dir = sig.direction;
        final j = (i+_horizon < candles.length) ? i+_horizon : candles.length-1;
        final entry = candles[i].c;
        final exit = candles[j].c;
        final diff = (exit/entry)-1;
        final good = dir=='CALL' ? diff>0 : diff<0;
        if (good) wins++; else loss++;
        _rows.add([
          candles[i].t.millisecondsSinceEpoch,
          candles[i].t.toIso8601String(),
          dir,
          sig.confidence,
          entry,
          exit,
          diff,
          _horizon,
          good?'WIN':'LOSS'
        ]);
      }
    }

    setState((){
      _signals=signals; _wins=wins; _loss=loss;
      _summary='TF: $_tf | Horizonte: $_horizon velas | Señales: $signals | Wins: $wins | Loss: $loss | WinRate: ${signals>0?(wins*100/signals).toStringAsFixed(1):'0'}%';
      _loading=false;
    });
  }

  Future<void> _exportCsvDownloads() async {
    final csv = const ListToCsvConverter().convert(_rows);
    final fileName = 'backtest_${_tf}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final downloads = Directory('/storage/emulated/0/Download');
    await Permission.storage.request();
    String savePath = (await downloads.exists())
      ? '${downloads.path}/$fileName'
      : '${(await getApplicationDocumentsDirectory()).path}/$fileName';
    final f = File(savePath);
    await f.writeAsString(csv);
  }

  Future<void> _shareCsv() async {
    final csv = const ListToCsvConverter().convert(_rows);
    final x = XFile.fromData(
      Uint8List.fromList(csv.codeUnits),
      mimeType: 'text/csv',
      name: 'backtest_${_tf}_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await Share.shareXFiles([x], text: 'Resultados de backtest');
  }

  Future<void> _exportExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Backtest'];
    for (final row in _rows) {
      sheet.appendRow(row);
    }
    final bytes = excel.encode();
    if (bytes == null) return;
    final fileName = 'backtest_${_tf}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    await Permission.storage.request();
    final downloads = Directory('/storage/emulated/0/Download');
    String savePath = (await downloads.exists())
      ? '${downloads.path}/$fileName'
      : '${(await getApplicationDocumentsDirectory()).path}/$fileName';
    final f = File(savePath);
    await f.writeAsBytes(bytes, flush: true);
  }
}
