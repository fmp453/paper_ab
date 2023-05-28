import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:paper_ab/componets/viewList_api.dart';


class ViewListTab extends StatefulWidget{
  const ViewListTab({super.key});

  @override
  State<ViewListTab> createState() => ViewListTabState();
}

class ViewListTabState extends State<ViewListTab>{
  List<Map<String, dynamic>> paperInfoList = [];

  Future<void> fetchPaperInfo() async {
    List<String> l = await getPaperInfos();
    setState(() {
      for(int i = 0; i < l.length - 1; i++){
        paperInfoList.add(json.decode(l[i]));
      }
    });
  }

  void _launchURL(String url) async{
    if (await canLaunchUrlString(url)){
      await launchUrlString(url);
    } else{
      throw 'could not launch $url';
    }
  }

  void _showDetails(BuildContext context, String title, String abstract, String id) {
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
                  child: const Text("Open in Browser")
                ),
                ElevatedButton(
                  onPressed: () {
                    debugPrint("hello");
                  }, 
                  child: const Text("Translate")
                ),
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  }, 
                  child: const Text('Close')
                )
              ]
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    fetchPaperInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        showCheckboxColumn: false,
        columns: [
          // コラムを中央揃えにする
          DataColumn(
            label: Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text('Title'),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text('Abstract'),
              ),
            ),
          ),
        ],
        rows: List<DataRow>.generate(
          paperInfoList.length, 
          (index) {
            final idString = paperInfoList[index]["id"];
            final titleString = paperInfoList[index]["title"];
            final abstractString = paperInfoList[index]["abstract"];

            return DataRow(
              onSelectChanged: (bool? selected){
                if (selected!= null && selected){
                  _showDetails(
                    context,
                    titleString,
                    abstractString,
                    idString
                  );
                }
              },
              cells: [
                DataCell(
                  Text(
                    titleString,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  )
                ),
                DataCell(
                  Text(
                    abstractString,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ),
              ]
            );
          }
        )
      )
    );
  }
}