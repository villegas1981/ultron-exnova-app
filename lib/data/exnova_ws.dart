import 'dart:async'; import 'dart:convert'; import 'package:web_socket_channel/web_socket_channel.dart';
import '../domain/models.dart'; import 'tick_aggregator.dart'; import 'candle_repo.dart';

class ExnovaWS{
  final Uri uri=Uri.parse('wss://ws.trade.exnova.com/echo/websocket'); // Reemplaza si difiere
  final String bearerToken='Bearer PON_AQUI_TU_TOKEN';
  final String timeframe; // '1m'|'5m'
  final CandleRepo repo;
  late final TickAggregator agg; WebSocketChannel? _ch;
  String currentSymbol='EURUSD';
  ExnovaWS(this.timeframe, this.repo){ agg=TickAggregator(timeframe); }
  void connectAndSubscribe({required String symbol}){
    currentSymbol=symbol;
    _ch=WebSocketChannel.connect(uri, headers:{'Authorization':bearerToken,'Origin':'https://exnova.com'});
    _ch!.stream.listen(_onEvent, onDone: _onDone, onError: _onDone);
    final sub={"action":"subscribe","channel":"ticks","symbol":symbol};
    _ch!.sink.add(jsonEncode(sub));
  }
  void _onEvent(dynamic event){
    try{
      final m=jsonDecode(event);
      final ts = (m['ts'] ?? m['time']) as int;
      final price = (m['price'] as num).toDouble();
      final vol = m['volume']==null? null : (m['volume'] as num).toDouble();
      final tick = Tick(DateTime.fromMillisecondsSinceEpoch(ts, isUtc:true), price, volume: vol);
      final closed = agg.add(tick);
      if (closed!=null){ repo.push(currentSymbol, timeframe, closed); }
    }catch(_){}
  }
  void _onDone([_]){ final last=agg.flush(); if(last!=null){ repo.push(currentSymbol, timeframe, last); } }
  void dispose(){ _ch?.sink.close(); }
}
