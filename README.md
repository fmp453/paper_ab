# paper_ab

URLまたは論文IDで検索してabstractやタイトルを表示する。

ローカルのcsvファイルに登録することもできる

## Getting Started

バックエンドには`Flask`および`pandas`を用いているのでインストールが必要
```bash
cd api
pip install -r requirements.txt
```

`api`ディレクトリで実行
```bash
python app.py
```
または
```bash
nohup python app.py &
```