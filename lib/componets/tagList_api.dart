import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;


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

  return l;
}