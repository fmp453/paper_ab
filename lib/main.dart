import 'package:flutter/material.dart';
import 'package:paper_ab/views/linkSearch.dart';
import 'package:paper_ab/views/viewList.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Paper Abstract'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  late TabController tabController;
  Color appBarBackgroundColor = Colors.redAccent;

  @override
  void initState(){
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
       switch (tabController.index){
        case 0:
          appBarBackgroundColor = Colors.redAccent;
          break;
        case 1:
        //   appBarBackgroundColor = Colors.orangeAccent;
        //   break;
        // case 2:
          appBarBackgroundColor = Colors.blueAccent;
          break;
       } 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        title: Text(widget.title),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'リンクまたはIDで探す'),
            // Tab(text: 'タイトルで探す'),
            Tab(text: '登録したリストを見る'),
          ],
        ),
      ),

      body: TabBarView(
        controller: tabController,
        children: const [
          LinkSearchTab(),
          // TitleSearchTab(),
          ViewListTab()
        ],
      ),
    );
  }
}