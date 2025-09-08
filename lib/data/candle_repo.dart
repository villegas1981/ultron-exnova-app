import '../domain/models.dart';
class CandleRepo{ final Map<String,List<Candle>> _s={}; List<Candle> series(String sym,String tf)=> _s['$sym:$tf']??[];
  void push(String sym,String tf,Candle c){ final k='$sym:$tf'; final l=_s.putIfAbsent(k,()=>[]); l.add(c); if(l.length>5000) l.removeAt(0); }
}
