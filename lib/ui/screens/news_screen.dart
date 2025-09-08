import 'package:flutter/material.dart'; import '../../data/news_repo.dart';
class NewsScreen extends StatelessWidget{ const NewsScreen({super.key});
  @override Widget build(BuildContext context){ final news=NewsRepo().upcoming('USD'); return Scaffold(appBar: AppBar(title: const Text('Calendario económico (demo)')), body:
    ListView.separated(padding: const EdgeInsets.all(12), itemBuilder: (_,i){ final n=news[i]; return ListTile(leading: Icon(n.impact=='high'?Icons.warning:Icons.info), title: Text(n.title), subtitle: Text('${n.currency} — ${n.time} — ${n.impact}')); },
      separatorBuilder: (_, __)=> const Divider(), itemCount: news.length)); }
}
