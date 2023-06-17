import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:paper_ab/utils/utils.dart';


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

Future<http.Response> addInfoWithTags(String id, String title, String abstract, List<String> tags) async {
  var uri = Uri.parse("http://127.0.0.1:5000/add_info_with_tags");
  String body = json.encode({
    "id": id,
    "title": title,
    "abstract": abstract,
    "tags": tags.toString().substring(1, tags.length - 1), // tagsの[]を取る
  });

  try{
    http.Response response = await http.post(uri, body: body, headers: {'Content-Type': 'application/json'});
    return response;
  } catch(e){
    throw Exception("Unexpected Error $e");
  }
}

// タグのリストをcsvから取得
Future<List<String>> getTags() async {
  var uri = Uri.parse("http://127.0.0.1:5000/get_tags");
  http.Response response = await http.get(uri);
  var resJson = response.body;
  String tmp = json.decode(resJson);
  // tmpの例 : ["Image","NLP","Audio","Video","Time Series","理論","GAN","Diffusion Models","強化学習","グラフ"]
  // 最初と最後の[]と"を取り除く必要がある。
  List<String> l = tmp.substring(1, tmp.length - 1).replaceAll("\"", "").split(",");
  return l;
}

void selectTags(BuildContext context, String paperTitle, String id, String abstract) async{
  List<String> tags = await getTags();
  List<String> selectedTags = [];

  // ignore: use_build_context_synchronously
  showDialog(
    context: context,
    builder: (context) {
      // dialogでsetStateするにはStatefulBuilderで囲む必要あり
      return StatefulBuilder(
        builder: (context, setState){
          return AlertDialog(
            title: const Text("Select Genre", textAlign: TextAlign.center,),
            content: Column(
              children : [
                const SizedBox(height: 30,),
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: tags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    // 選択されたタグの色を変える
                    return InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                      onTap: () async {
                        debugPrint("tapped $tag");
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
                // ボタンの実装。backとクリアと登録の3つ
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                color: Colors.black
                              )
                            ),
                            child: const Text("戻る"),
                          ),
                        ),
                        const SizedBox(width: 35,),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              selectedTags.clear();
                              setState(() {},);
                            }, 
                            child: const Text('選択を全てクリア')
                          ),
                        ),
                        const SizedBox(width: 35,),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // ここでリストに登録してポップアップを閉じる
                              // リスト登録部分のみ未実装
                              // Timerで管理した方がいい？
                              debugPrint(selectedTags.toString());
                              setState(() {},);
                              Navigator.of(context).pop();
                            }, 
                            child: const Text("リストに登録"),
                          )
                        ),
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