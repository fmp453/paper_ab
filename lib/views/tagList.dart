import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TagSearchDBTab extends StatefulWidget{
  const TagSearchDBTab({super.key});
  
  @override
  State<TagSearchDBTab> createState() => TagSearchDBTabState();
}

class TagSearchDBTabState extends State<TagSearchDBTab>{
  final tags = [
    'Image',
    'NLP',
    'Audio',
    'Video',
    '時系列',
    '理論',
    'GAN',
    '拡散モデル',
    '強化学習',
    'グラフ',
  ];
  List<String> selectedTags = [];
  bool orSearch = false;

  @override
  Widget build(BuildContext context){
    return Column(
      children:[
        const SizedBox(height: 20,),
        Wrap(
          runSpacing: 16,
          spacing: 16,
          children: tags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              onTap: () async {
                debugPrint("tagged $tag");
                if(isSelected){
                  selectedTags.remove(tag);
                } else {
                  selectedTags.add(tag);
                }
                setState(() {},);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  border: Border.all(
                    width: 2,
                    color: Colors.lightBlue
                  ),
                  color: isSelected ? Colors.lightBlue : null,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 15,),
        // Optionalの設定
        Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("OR検索"),
                const SizedBox(width: 18,),
                CupertinoSwitch(
                  activeColor: Colors.greenAccent,
                  value: orSearch,
                  onChanged: (value) {
                    orSearch = value;
                    setState(() {});
                  },
                ),
              ],
            ),
        ),
        // ボタンの実装
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      selectedTags.clear();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black)
                    ),
                    child: const Text("選択をクリア"),
                  ),
                ),
                const SizedBox(width: 30,),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint("search");
                      debugPrint(selectedTags.toString());
                    },
                    child: const Text("探す"),
                  ),
                ),
              ],
            ),
          )
        ),
      ]
    );
  }
}