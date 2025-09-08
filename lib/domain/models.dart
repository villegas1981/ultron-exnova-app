class Candle { final DateTime t; final double o,h,l,c; final double? v; Candle(this.t,this.o,this.h,this.l,this.c,{this.v}); }
class Tick { final DateTime t; final double price; final double? volume; Tick(this.t,this.price,{this.volume}); }
class Signal { final DateTime time; final String direction; final double confidence; Signal({required this.time, required this.direction, required this.confidence}); }
class NewsEvent { final DateTime time; final String currency; final String impact; final String title; NewsEvent(this.time,this.currency,this.impact,this.title); }
