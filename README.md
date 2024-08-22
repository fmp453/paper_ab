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
- 翻訳ボタンの中身の実装 : OpenAI APIでGPTに翻訳させる。
- リストのソート機能 (Additional, 何をkeyとしてソートするかは考え中。投稿日時ならその情報をデータベースに追加する必要がある)