import 'package:flutter/material.dart';

class ListOpened extends StatelessWidget {
  final String title;
  final String quizCount;
  final String imageUrl;

  const ListOpened({
    super.key,
    required this.title,
    required this.quizCount,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        isThreeLine: true,
        leading: Image.network(imageUrl, width: 100, height: 100),
        title: Text(
          title,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(quizCount, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
