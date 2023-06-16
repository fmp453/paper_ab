# paper_ab

URLまたは論文IDで検索してabstractやタイトルを表示する。

ローカルのcsvファイルに登録することもできる

## Getting Started
フロントはflutterで実装 (機能が増えたらReactでの実装にしてWebベースにするかも)
- flutter : 3.7.10
- Dart : 2.19.6

バックエンド環境構築
```bash
cd api
pip install -r requirements.txt
```
データベース用csvファイル生成 (`paper_ab`で実行)
```bash
cd database
python make_csv.py
```
`api`ディレクトリで実行
```bash
python app.py
```
または
```bash
nohup python app.py &
```

## To Do
- タグの管理 : TOXI法で実装予定 (CSV管理する予定だが状況に応じてSQLに切り替える。`make_csv.py`も変更)
- 翻訳ボタンの中身の実装 : Google Translateにクエリを投げる？
- リストにおいて検索機能の追加 (現状はタグをクエリとする, 検索部分は終了したので結果の表示を今後実装)
- リストのソート機能 (Additional, 何をkeyとしてソートするかは考え中。投稿日時ならその情報をデータベースに追加する必要がある)
- タグ指定して追加するボタンの中身の実装 : これだけ`linkSearch.dart`の話