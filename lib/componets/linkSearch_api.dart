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
        debugPrint("Response OK");
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