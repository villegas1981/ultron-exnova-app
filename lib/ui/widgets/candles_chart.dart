import 'package:flutter/material.dart'; import '../../domain/models.dart';
class CandlesChart extends StatelessWidget{ final List<Candle> data; const CandlesChart({super.key,required this.data});
  @override Widget build(BuildContext context){ return AspectRatio(aspectRatio:16/9, child: CustomPaint(painter:_P(data))); }
}
class _P extends CustomPainter{ final List<Candle> d; _P(this.d);
  @override void paint(Canvas c, Size s){ final n=d.length; if(n==0) return; final w=s.width/n; final hs=d.map((e)=>e.h).reduce((a,b)=>a>b?a:b); final ls=d.map((e)=>e.l).reduce((a,b)=>a<b?a:b);
    double y(double v)=> s.height*(1-(v-ls)/(hs-ls+1e-9));
    for(var i=0;i<n;i++){ final e=d[i]; final x=i*w+w/2; final p=Paint()..strokeWidth=1..color=e.c>=e.o?Colors.green:Colors.red;
      c.drawLine(Offset(x,y(e.h)), Offset(x,y(e.l)), p); final left=i*w+w*0.2, right=i*w+w*0.8; final top=y(e.o>e.c?e.o:e.c), bottom=y(e.o>e.c?e.c:e.o); c.drawRect(Rect.fromLTRB(left,top,right,bottom), p); } }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>true;
}
