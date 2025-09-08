import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../domain/models.dart';

class CsvLoader {
  Future<List<Candle>> pickAndLoad() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (res == null || res.files.isEmpty) return [];
    final bytes = res.files.first.bytes;
    if (bytes == null) return [];
    final content = utf8.decode(bytes);
    final rows = const CsvToListConverter(eol: '\n').convert(content);
    final out = <Candle>[];
    for (final r in rows.skip(1)) {
      try {
        final ts = r[0];
        DateTime t;
        if (ts is num) {
          t = DateTime.fromMillisecondsSinceEpoch(ts.toInt(), isUtc: true);
        } else {
          t = DateTime.parse(ts.toString()).toUtc();
        }
        final o = (r[1] as num).toDouble();
        final h = (r[2] as num).toDouble();
        final l = (r[3] as num).toDouble();
        final c = (r[4] as num).toDouble();
        final v = r.length > 5 && r[5] != null ? (r[5] as num).toDouble() : null;
        out.add(Candle(t, o, h, l, c, v: v));
      } catch (_) {}
    }
    out.sort((a,b)=> a.t.compareTo(b.t));
    return out;
  }
}
