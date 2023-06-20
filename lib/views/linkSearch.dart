import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:paper_ab/componets/linkSearch_api.dart';

/*
MacOS connection failed solution
https://github.com/dart-lang/http/issues/808

I had the same issue. My problem was the macOS permissions were not set in the respective entitlements files to allow network client access for the macOS build.

Adding the following to macos/Runner/DebugProfile.entitlements and macos/Runner/Release.entitlements fixed my issue.

<key>com.apple.security.network.client</key>
<true/>
*/

class LinkSearchTab extends StatefulWidget{
  const LinkSearchTab({super.key});

  @override
  State<LinkSearchTab> createState() => LinkSearchTabState();
}

class LinkSearchTabState extends State<LinkSearchTab>{
  final TextEditingController _userPaperLinkField = TextEditingController();
  
  Color appBarBackgroundColor = Colors.redAccent;

  bool showDivider = false;
  String abstractChapter = "";
  String abstractString = "";
  String titleText = "";
  String paperID = "";
  static const String worngMessage = "URLまたはIDが間違っています";
  static const String textFieldHintText = "ID or URL (ex. https://arxiv.org/abs/1706.03762 or 1706.03762)";

  void displayPaperInfo(Map<String, dynamic> paperInfo){
    showDivider = true;
    paperID = paperInfo["id"];
    titleText = paperInfo["title"];
    abstractChapter = "Abstract";
    abstractString = paperInfo["abstract"];
  }
  
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 15,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    paperID = "";
                    titleText = "";
                    abstractString = "";
                    abstractChapter = "";
                    showDivider = false;
                    _userPaperLinkField.text = "";
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                child: const Text("Clear", style: TextStyle(fontSize: 11),),
              ),
            ),
            const SizedBox(width: 20,)
          ],
        ),
        const SizedBox(height: 20,),
        Row (
            children:[
              const SizedBox(width: 15,),
              const Text("Link"),
              const SizedBox(width: 10,),
              Expanded(
                child: TextField(
                  controller: _userPaperLinkField,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: textFieldHintText
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
                onPressed: () async {
                  String resJson = await postData(_userPaperLinkField.text);
                  try{
                    Map<String, dynamic> paperInfo = json.decode(resJson);
                    if(paperInfo["id"] == "url not match"){
                      setState(() {
                        titleText = worngMessage;
                      });
                      return ;
                    } else{
                      setState(() {
                        displayPaperInfo(paperInfo);
                      });
                    }
                  }
                  catch(e){
                    setState(() {
                      titleText = worngMessage;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarBackgroundColor
                ),
                child: const Text("View Abstract"),
              ),
            ),
            const SizedBox(width: 25,),
            // タグなしで保存
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () async{
                  var resJson = await addInfo(paperID, titleText, abstractString);
                  Map<String, dynamic> statusMessage = json.decode(resJson.body);
                  // timerで時間管理する。ここでは0.8秒でポップアップが消えるようにしている
                  Timer _timer = Timer(
                    const Duration(milliseconds: 800), 
                    () { 
                      Navigator.pop(context); 
                      },
                  );

                  // ignore: use_build_context_synchronously
                  await showDialog(context: context, builder: (context) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AlertDialog(
                          content: Text(statusMessage["status"]),
                        ),
                      ],
                    );
                  });

                  if(_timer.isActive){
                    _timer.cancel();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarBackgroundColor
                ),
                child: const Text("Add List without Genre Tag"),
              ),
            ),
            const SizedBox(width: 25,),
            // タグ付きで保存
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () async{
                  // pressedでtag選択のポップアップを出す
                  // 現在の実装では一旦abstractなどを表示させないといけないのでこれの対処法を考える
                  // view abstractを押した時の処理を挟む
                  if(titleText == "" || paperID == "" || abstractString == ""){
                    String resJson = await postData(_userPaperLinkField.text);
                    Map<String, dynamic> paperInfo = json.decode(resJson);
                    if(paperInfo["id"] == "url not match"){
                      setState(() {
                        titleText = worngMessage;
                      });
                      return ;
                    } else{
                      setState(() {
                        displayPaperInfo(paperInfo);
                      });
                    }
                  }
                  // ignore: use_build_context_synchronously
                  selectTags(context, titleText, paperID, abstractString);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarBackgroundColor
                ),
                child: const Text("Add List with Genre Tag"),
              ),
            ),
          ]
        ),
        const SizedBox(height: 15,),
        Wrap(
          direction: Axis.horizontal,
          children: [
            Text(titleText, style: const TextStyle(fontSize: 20), textAlign: TextAlign.center,)
          ]
        ),
        const SizedBox(height: 10,),
        // 線を動的に表示
        Divider(
          height: showDivider? null : 0,
          thickness: showDivider? 2.0 : 0,
          color: showDivider? Colors.black : Colors.transparent,
        ),
        Row(
          children: [
            const SizedBox(width: 15,),
            Text(abstractChapter, style: const TextStyle(fontSize: 15),),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(abstractString)
          )
        )
      ],
    );
  }
}