import 'package:tflite_flutter/tflite_flutter.dart';
class PatternModel{
  late final Interpreter _i; bool _r=false;
  PatternModel(){ try{ _i=Interpreter.fromAsset('assets/ai/patterns.tflite'); _r=true; }catch(_){ _r=false; } }
  double predict(List<List<double>> x){ if(!_r) return 0.5; final input=[x]; final output=List.filled(1,List.filled(1,0.0)); _i.run(input,output); return output[0][0]; }
  void close(){ if(_r) _i.close(); }
}
