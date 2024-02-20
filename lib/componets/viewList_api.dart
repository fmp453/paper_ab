import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;


Future<List<String>> getPaperInfos() async{
  var uri = Uri.parse("http://127.0.0.1:5000/paper_info");
  http.Response response = await http.get(uri);
  var resJson = response.body;
  
  if(response.statusCode == 403){
    return ["403", "サーバーが起動していません"];
  }

  String tmp = json.decode(resJson);
  List<String> l = tmp.split("}");
  for(int i = 0; i < l.length - 1; i++){
    l[i] = "${l[i]}}";
    l[i] = l[i].substring(1);
    l[i] = l[i].replaceAll(r"\n", " ");
  }
  return l;
}
void _launchURL(String url) async{
    if (await canLaunchUrlString(url)){
      await launchUrlString(url);
    } else{
      throw 'could not launch $url';
    }
}

// 各論文につけられたタグをTitleとAbstractの間に表示する。
// タグがない場合はshowDetails内で制御するのでタグが1つ以上あるとしてよい
// Tag Selectと同じ見た目で表示する
Widget splitAndMakeTagIcon(String tags){
  List<String> tagLists = tags.split(",");
  debugPrint(tagLists[0]);

  return Wrap(
    runSpacing: 16,
    spacing: 16,
    children: tagLists.map((tag){
      return InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            border: Border.all(
              width: 2,
              color: Colors.lightBlue,
            ),
            color: Colors.lightBlue
          ),
          child: Text(tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ),
      );
    }).toList(),
  );
}

Widget makeRegisterTagsButton(BuildContext context, String paperTitle, String id, String abstract){
  return ElevatedButton(
    onPressed: () {
      selectTags(
        context,
        paperTitle,
        id,
        abstract
      );
    },
    style: ElevatedButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32))
      ),
      backgroundColor: Colors.lightBlue,
      foregroundColor: Colors.white
    ),
    child: const Text("タグを登録する"),
  );
}

// 翻訳ボタンを押したら内容を表示する
// ダイアログにしてるけど元々のtext fieldの値を変更する方がいいかも
void showTranslatedTextDialog(BuildContext context, String abstract){
  showDialog(
    context: context, 
    builder: (BuildContext context) {
      return  AlertDialog(
        title: const Text("Abstract 日本語訳"),
        content: const Text("未実装です！"),
        actions: [
          ElevatedButton(
            onPressed: () async{
              Navigator.of(context).pop();
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black)
            ),
            child: const Text('閉じる')
          )
        ]
      );
    }
  );
}

// 表の各行をクリックしたときに出てくるダイアログを管理する関数
// title, abstractとその論文ページをブラウザで開くボタンに翻訳ボタンと閉じるボタン
// 翻訳部分については未実装
void showDetails(BuildContext context, String title, String abstract, String id, String? tags) {
  
  // タグが複数の場合はカンマ区切りで文字列が入ってくる
  // タグなしの場合は登録ボタンを表示する

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        // はみ出すときにスクロールできるようにする
        // SingleChildScrollViewが2つあって冗長では？
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(thickness: 2.0), // TitleとTagの間に薄めの横線を表示して区切る
              const SizedBox(height: 8,),
              tags == null ? makeRegisterTagsButton(context, title, id, abstract) : splitAndMakeTagIcon(tags),
              const Divider(thickness: 2.0), // TagとAbstractの間に薄めの横線を表示して区切る
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  // コピペできるようにSelectableTextを使用
                  child: SelectableText(abstract),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            // 要素を等間隔に配置
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children : [
              ElevatedButton(
                onPressed: (){
                  String url = "https://arxiv.org/abs/$id";
                  _launchURL(url);
                }, 
                child: const Text("ブラウザでPDFを見る")
              ),
              ElevatedButton(
                onPressed: () {
                  // debugPrint("hello");
                  showTranslatedTextDialog(context, abstract);
                }, 
                child: const Text("英 → 日 (未実装)")
              ),
              ElevatedButton(
                onPressed: () async{
                  Navigator.of(context).pop();
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(
                    color: Colors.black
                  )
                ),
                child: const Text('閉じる')
              )
            ]
          )
        ],
      );
    },
  );
}

Future<http.Response> addInfoWithTags(String id, String title, String abstract, List<String> tags) async {
  var uri = Uri.parse("http://127.0.0.1:5000/add_tags_to_paper_list");
  String body = json.encode({
    "id": id,
    "title": title,
    "abstract": abstract,
    "tags": tags.toString(), 
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
                Text(paperTitle, textAlign: TextAlign.center,),
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
                              // Timerで管理した方がいい？
                              var result = addInfoWithTags(id, paperTitle, abstract, selectedTags);
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