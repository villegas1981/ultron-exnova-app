import '../domain/models.dart';
class TickAggregator {
  final String timeframe; // '1m'|'5m'
  Candle? _current;
  TickAggregator(this.timeframe);
  Duration get _bucket => timeframe=='5m' ? const Duration(minutes:5) : const Duration(minutes:1);
  Candle? add(Tick tick) {
    if (_current == null) { _current = Candle(_align(tick.t), tick.price, tick.price, tick.price, tick.price, v: tick.volume); return null; }
    final endTime = _current!.t.add(_bucket);
    if (tick.t.isBefore(endTime)) {
      final c=_current!; final h=tick.price>c.h?tick.price:c.h; final l=tick.price<c.l?tick.price:c.l;
      _current = Candle(c.t, c.o, h, l, tick.price, v: (c.v ?? 0) + (tick.volume ?? 0)); return null;
    } else { final closed=_current!; _current = Candle(_align(tick.t), tick.price, tick.price, tick.price, tick.price, v: tick.volume); return closed; }
  }
  DateTime _align(DateTime t){ final b=_bucket; final ts=t.toUtc(); final m=ts.minute-(ts.minute%b.inMinutes); return DateTime.utc(ts.year,ts.month,ts.day,ts.hour,m); }
  Candle? flush()=>_current;
}
