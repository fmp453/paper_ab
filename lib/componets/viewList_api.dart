import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;


Future<List<String>> getPaperInfos() async{
  var uri = Uri.parse("http://127.0.0.1:5000/paper_info");
  http.Response response = await http.get(uri);
  var resJson = response.body;
  String tmp = json.decode(resJson);
  List<String> l = tmp.split("}");
  for(int i = 0; i < l.length - 1; i++){
    l[i] = "${l[i]}}";
    l[i] = l[i].substring(1);
    l[i] = l[i].replaceAll(r"\n", " ");
  }
  return l;
}