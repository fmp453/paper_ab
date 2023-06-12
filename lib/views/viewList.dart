import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paper_ab/componets/viewList_api.dart';


class ViewListTab extends StatefulWidget{
  const ViewListTab({super.key});

  @override
  State<ViewListTab> createState() => ViewListTabState();
}

class ViewListTabState extends State<ViewListTab>{
  List<Map<String, dynamic>> paperInfoList = [];

  Future<void> fetchPaperInfo(BuildContext context) async {
    List<String> l = await getPaperInfos();
    if(l[0] == "403"){
      // ignore: use_build_context_synchronously
      showDialog(
        context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l[1]),
                const SizedBox(height: 30,),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ),
              ],
            ),
          );
        }
      );
    } else{
      setState(() {
        for(int i = 0; i < l.length - 1; i++){
          paperInfoList.add(json.decode(l[i]));
        }
      });
    }
  }

  @override
  void initState() {
    fetchPaperInfo(context);
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