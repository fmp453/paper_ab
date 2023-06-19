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
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
      ),
    );
  }
}