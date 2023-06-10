import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;


Future<String> postData(String idString) async {
    var uri = Uri.parse("http://127.0.0.1:5000/api");
    String body = json.encode({'id': idString});

    try{
      http.Response response = await http.post(uri, body: body, headers: {'Content-Type': 'application/json'});
      
      if(200 <= response.statusCode && response.statusCode < 300){
        return response.body;
      } else {
        throw Exception("Failed API Request : ${response.statusCode}");
      }

    } catch(e){
      throw Exception("予期せぬエラー : $e");
    }
}

Future<http.Response> addInfo(String id, String title, String abstract) async {
    var uri = Uri.parse("http://127.0.0.1:5000/add_info");
    String body = json.encode({
      "id": id,
      "title": title,
      "abstract": abstract
    });
    
    try{
      http.Response response = await http.post(uri, body: body, headers: {'Content-Type': 'application/json'});
      return response;
    } catch(e){
      throw Exception("予期せぬエラー : $e");
    }
}

void selectTags(BuildContext context, String paperTitle, String id){
  final tags = [
    'Image',
    'NLP',
    'Audio',
    'Video',
    '時系列',
    '理論',
    'GAN',
    '拡散モデル',
    '強化学習',
    'グラフ',
  ];
  List<String> selectedTags = [];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState){
          return AlertDialog(
            title: Text(paperTitle),
            content: Column(
              children : [
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: tags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                      onTap: () async {
                        debugPrint("tapped");
                        if(isSelected){
                          selectedTags.remove(tag);
                        } else {
                          selectedTags.add(tag);
                        }
                        setState(() {},);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(32)),
                          border: Border.all(
                            width: 2,
                            color: Colors.lightBlue,
                          ),
                          color: isSelected ? Colors.lightBlue : null,
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.lightBlue,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            selectedTags.clear();
                            setState(() {},);
                          }, 
                          child: const Text('Clear')
                        ),
                        const SizedBox(width: 25,),
                        ElevatedButton(
                          onPressed: () {
                            // ここでリストに登録してポップアップを閉じる
                            // リスト登録部分のみ未実装
                            debugPrint(selectedTags.toString());
                            setState(() {},);
                            Navigator.of(context).pop();
                          }, 
                          child: const Text("Add List"),
                        )
                      ],
                    ),
                  ),
                ),
              ]
            )
          );
        }
      );
    }
  );
}