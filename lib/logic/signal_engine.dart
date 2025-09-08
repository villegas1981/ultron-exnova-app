import '../domain/models.dart'; import '../domain/rules.dart'; import '../ai/pattern_model.dart';
class SignalEngine{
  final PatternModel model; double threshold; SignalEngine(this.model,{this.threshold=0.62});
  double _vol(List<Candle> w){ if(w.length<2) return 0; double s=0; for(var i=1;i<w.length;i++){ s+=(w[i].c-w[i-1].c).abs(); } return s/(w.length-1); }
  bool _news(DateTime now,List<NewsEvent> n)=> n.any((e)=> e.impact=='high' && now.isAfter(e.time.subtract(const Duration(minutes:10))) && now.isBefore(e.time.add(const Duration(minutes:10))));
  Signal? evaluate(List<Candle> s,List<NewsEvent> news){ if(s.length<60) return null; final w=s.sublist(s.length-60); final p=model.predict(w.map((c)=>[c.o,c.h,c.l,c.c]).toList());
    final prev=w[w.length-2], cur=w.last; final engulf=isBullishEngulfing(prev,cur)||isBearishEngulfing(prev,cur);
    final vol=_vol(w); if(_news(cur.t,news)) return null; if(vol<0.0005) return null; final score=p+(engulf?0.1:0.0);
    if(score>=threshold){ return Signal(time:cur.t,direction:p>=0.5?'CALL':'PUT',confidence:score); } return null; }
}
