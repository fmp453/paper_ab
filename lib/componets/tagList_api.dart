import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:paper_ab/componets/paper_container.dart';

Future<List<String>> searchPapersWithTags(List<String> tagsList) async {
  var uri = Uri.parse("http://127.0.0.1:5000/paper_info_tags"); 
  List<dynamic> jsonList = [];
  
  for (String item in tagsList) {
    jsonList.add(item);
  }
  String body = json.encode(jsonList);
  http.Response response = await http.post(uri, body: body, headers: {'Content-Type': 'application/json'});
  var resJson = response.body;
  
  if(response.statusCode == 403){
    return ["403", "サーバーが起動していません"];
  }
  
  String tmp = json.decode(resJson);
  List<String> l = tmp.split("}");

  for(int i = 0; i < l.length; i++){
    l[i] = "${l[i]}}";
    l[i] = l[i].substring(1);
    l[i] = l[i].replaceAll(r"\n", " ");
  }

  l.removeRange(l.length - 1, l.length);
  return l;
}

Future<List<PaperInfo>> getPaperInfo(List<String> tagsList) async{
  List<String> l = await searchPapersWithTags(tagsList);
  List<PaperInfo> res = [];
  List<Map<String, dynamic>> p = [];
  Set<String> s = {};
  for(int i = 0; i < l.length; i++){
    p.add(json.decode(l[i]));
  }
  for(int i = 0; i < p.length; i++){
    if(s.contains(p[i]["id"])){
      continue;
    }
    List<String> tags = p[i]["tags"].split(",");
    PaperInfo tmp = PaperInfo(
      title: p[i]["title"],
      id: p[i]["id"], 
      abstractString: p[i]["abstract"],
      tags: tags
    );
    res.add(tmp);
    s.add(p[i]["id"]);
  }
  return res;
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