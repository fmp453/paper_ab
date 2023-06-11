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
                  showDetails(
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