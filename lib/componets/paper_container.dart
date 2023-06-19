import 'package:flutter/material.dart';

class PaperInfo{
  PaperInfo({
    required this.title,
    required this.id,
    required this.abstractString,
    this.tags = const [],
  });
  final String id;
  final String title;
  final String abstractString;
  final List<String> tags;

  factory PaperInfo.fromJson(Map<String, dynamic> json){
    return PaperInfo(
      title: json['title'],
      id: json['id'],
      abstractString: json['abstract'],
      tags: List<String>.from(json['tags'].map((tag) => tag['name'])),
    );
  }
}

class PaperContainer extends StatelessWidget {
  const PaperContainer({
    Key? key,
    required this.paper,
  }) : super(key: key);

  final PaperInfo paper;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16
      ),
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paper.id,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 15,),
            Center(
              child: Text(
                paper.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}