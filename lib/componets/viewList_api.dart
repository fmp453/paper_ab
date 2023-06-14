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


// 表の各行をクリックしたときに出てくるダイアログを管理する関数
// title, abstractとその論文ページをブラウザで開くボタンに翻訳ボタンと閉じるボタン
// 翻訳部分については未実装
void showDetails(BuildContext context, String title, String abstract, String id, List<String> tags) {
  String tagText = "タグなし";
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
              const Divider(thickness: 2.0), // TitleとAbstractの間に薄めの横線を表示して区切る
              const SizedBox(height: 8,),
              Text(tagText),
              const Divider(thickness: 2.0), // TitleとAbstractの間に薄めの横線を表示して区切る
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
                  debugPrint("hello");
                }, 
                child: const Text("Abstractを翻訳する")
              ),
              ElevatedButton(
                onPressed: (){
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