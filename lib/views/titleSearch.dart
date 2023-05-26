import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TitleSearchTab extends StatefulWidget{
  const TitleSearchTab({super.key});
  
  @override
  State<TitleSearchTab> createState() => TitleSearchTabState();
}

class TitleSearchTabState extends State<TitleSearchTab>{
  final TextEditingController _userPaperTitleField = TextEditingController();
  
  Color appBarBackgroundColor = Colors.orange;

  String outputText = "";

  Future<String> postData() async {
    var uri = Uri.parse("http://127.0.0.1:5000/title_api");
    String body = json.encode({'title_q': _userPaperTitleField.text});

    http.Response response = await http.post(uri, body: body, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      debugPrint('Error posting data: ${response.statusCode}');
      return "Erorr";
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        const SizedBox(height: 20,),
        Row (
          children:[
            const SizedBox(width: 15,),
            const Text("Link"),
            const SizedBox(width: 10,),
            Expanded(
              child: TextField(
                controller: _userPaperTitleField,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Link (ex. Attention Is All You Need)"
                ),
              ),
            ),
            const SizedBox(width: 15,),
          ]
        ),
        const SizedBox(height: 25,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint(_userPaperTitleField.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarBackgroundColor
                ),
                child: const Text("sample buttom"),
              ),
            )
          ]
        ),
        const SizedBox(height: 25,),
        Center(child: Text(outputText),)
      ],
    );
  }
}