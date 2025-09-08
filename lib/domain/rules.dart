import 'models.dart';
bool _bear(Candle c)=>c.c<c.o; bool _bull(Candle c)=>c.c>c.o;
bool isBullishEngulfing(Candle p,Candle c){ final pb=_bear(p), cb=_bull(c); final e=c.o<=p.c && c.c>=p.o; return pb && cb && e; }
bool isBearishEngulfing(Candle p,Candle c){ final pb=_bull(p), cb=_bear(c); final e=c.o>=p.c && c.c<=p.o; return pb && cb && e; }
