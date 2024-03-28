import os
import arxiv
import pandas as pd

from flask import Flask, request, jsonify
from openai import OpenAI

from logging import DEBUG, INFO, Formatter, FileHandler, StreamHandler, getLogger
from typing import List, Dict

app = Flask(__name__)
app.config["JSON_AS_ASCII"] = False


def get_logger(verbose):
    os.makedirs("logs", exist_ok=True)
    logger = getLogger(__name__)
    logger = _set_handeler(logger, StreamHandler(), False)
    logger = _set_handeler(logger, FileHandler("logs/log.txt", encoding='utf-8'), verbose)
    logger.setLevel(DEBUG)
    logger.propagate = False
    return logger

def _set_handeler(logger, handler, verbose):
    if verbose:
        handler.setLevel(DEBUG)
    else:
        handler.setLevel(INFO)
    handler.setFormatter(Formatter('%(asctime)s %(name)s:%(lineno)s %(funcName)s [%(levelname)s]: %(message)s'))
    logger.addHandler(handler)
    return logger

logger = get_logger(True)

@app.route('/api', methods=['GET', 'POST'])
def data_with_url():
    data: Dict = request.json
    client = arxiv.Client()
    
    if check_url(data["id"]):
        data = extract_id_from_url(data["id"])
    else:
        data["id"] = "url not match"

    if data["id"] == "url not match":
        logger.error(f"not correct URL : {data}")
        return data
    
    try:
        search = arxiv.Search(
            id_list=[data["id"]]
        )
    except :
        logger.error(f"Error : {data}")
        return f"Error : {data}"
    
    try:
        paper = next(client.results(search))
    except:
        logger.error(f"Error : {search}")
        return f"Error : {search}"
    
    json_res: Dict = {
        "id": data["id"],
        "title": paper.title,
        "abstract": paper.summary
    }
    return jsonify(json_res)

def extract_id_from_url(url: str) -> Dict:
    """
        assumed input cases
        case1 : https://arxiv.org/abs/1706.03762 => 1706.03762
        case2 : https://arxiv.org/pdf/1706.03762.pdf => 1706.03762
    """

    if "https://arxiv.org/abs/" in url:
        n = len("https://arxiv.org/abs/")
        return {"id": url[n:]}
    
    elif "https://arxiv.org/pdf/" in url:
        n = len("https://arxiv.org/pdf/")
        return {"id": url[n:].strip(".pdf")}
    
    return {"id" : "url not match"}

def check_url(url) -> bool:
    return "https" in url

@app.route('/add_info', methods=['GET', 'POST'])
def add_paper_action():
    data: Dict = request.json
    status = add_paper_to_csv(data['id'], data['title'], data['abstract'])
    return jsonify({"status" : status})

def add_paper_to_csv(id: str, title: str, abstract: str) -> str:
    csv_path: str = "../database/paper_info.csv"
    df = pd.read_csv(csv_path, dtype={'id': 'str'})

    if id == '' or title == 'URLまたはIDが間違っています' or abstract == '':
        return "IDまたはURLが間違っている可能性があります"

    if id in set(df["id"].values):
        return "Already added in the list"
    
    new_paper_info: Dict = {
        'id': id, 
        'title': title,
        'abstract': abstract
    }

    new_row = pd.DataFrame([new_paper_info])
    df = pd.concat([df, new_row], ignore_index=True)
    df.to_csv(csv_path, index=False)

    return "added into the list successfully"

@app.route('/add_info_with_tags', methods=['GET', 'POST'])
def add_paper_action_with_tags():
    data: Dict = request.json
    status = add_paper_to_csv_tags(data['id'], data['title'], data['abstract'], data['tags'])
    return jsonify({"status": status})

def add_paper_to_csv_tags(id: str, title: str, abstract: str, tags: str) -> str:
    csv_path = "../database/paper_info.csv"
    df = pd.read_csv(csv_path, dtype={'id': 'str'})

    if id == '' or title == 'URLまたはIDが間違っています' or abstract == '':
        return "IDまたはURLが間違っている可能性があります"

    if id in set(df["id"].values):
        return "Already added in the list"
    
    # tagsの[]とタグ区切りのカンマの後ろの空白を消す
    tags = tags.replace("[", "").replace("]", "").replace(", ", ",")

    new_paper_info: Dict = {
        'id': id, 
        'title': title,
        'abstract': abstract,
        'tags': tags
    }

    new_row = pd.DataFrame([new_paper_info])
    df = pd.concat([df, new_row], ignore_index=True)
    df.to_csv(csv_path, index=False)
    return "added into the list successfully"

@app.route('/add_tags_to_paper_list', methods=['GET', 'POST'])
def add_tags_to_paper_list():
    data: Dict = request.json
    status = add_tags_to_paper_info(data['id'], data['tags'])
    return jsonify({"status" : status})

def add_tags_to_paper_info(id: str, tags: str) -> str:
    csv_path: str = "../database/paper_info.csv"
    df = pd.read_csv(csv_path, dtype={'id': 'str'})

    # tagsの[]を取る
    tags = tags.replace("[", "").replace("]", "")

    if id == '':
        return "IDまたはURLが間違っている可能性があります"

    if id not in set(df["id"].values):
        return "paper not found"
    
    df.loc[df["id"] == id, "tags"] = tags
    df.to_csv(csv_path, index=False)

    return "added into the list successfully"


@app.route('/add_tags', methods=['GET', 'POST'])
def add_paper_tags_action():
    data: Dict = request.json
    status = add_tags_to_csv(data['id'], data['tags'])
    return jsonify({"status" : status})

def add_tags_to_csv(id: str, tags: str) -> str:
    csv_path: str = "../database/tags_table.csv"
    df = pd.read_csv(csv_path, dtype={'id': 'str'})

    if id == '':
        return "IDまたはURLが間違っている可能性があります"

    if id in set(df["id"].values):
        return "Already added in the list"
    
    new_paper_tags = {
        'id': id, 
        'tags': tags
    }

    new_row = pd.DataFrame([new_paper_tags])
    df = pd.concat([df, new_row], ignore_index=True)
    df.to_csv(csv_path, index=False)

    return "added into the list successfully"

@app.route('/paper_info', methods=['GET'])
def get_paper_info():
    csv_path: str = "../database/paper_info.csv"
    df = pd.read_csv(csv_path, dtype={'id': 'str'})
    logger.info("open csv file")
    json = df.to_json(orient='records')
    return jsonify(json)

@app.route('/tag_info', methods=["GET"])
def get_paper_tags():
    csv_path: str = "../database/tags_table.csv"
    df = pd.read_csv(csv_path, dtype={"tag_id": "str"})
    logger.info("OPEN TAG CSV")
    json = df.to_json(orient='records')
    return jsonify(json)

@app.route('/get_tags', methods=['GET'])
def get_tag_list():
    csv_path: str = "../database/tags_table.csv"
    df = pd.read_csv(csv_path)
    json = df["tag_name"].to_json(orient='records', force_ascii=False)
    return jsonify(json)

@app.route('/paper_info_tags', methods=['GET', 'POST'])
def get_paper_info_with_tags():
    tags: List = request.json
    csv_path: str = "../database/paper_info.csv"
    df = pd.read_csv(csv_path, dtype={'id': 'str'})
    tag_columns = df["tags"].to_numpy()
    conditioned_df = pd.DataFrame(columns=df.columns)

    tags = set(tags)
    andSearch: bool = "AND" in tags
    
    if andSearch:
        tags.remove("AND")

    # csvから条件タグに一致するものを選択する。ORとANDのときで変える必要あり
    for i, each_tag in enumerate(tag_columns):
        # 各論文につけられたタグ
        each_tag = str(each_tag).split(",")
        # OR検索
        if not andSearch:
            for x in each_tag:
                if x in tags:
                    extracted_paper_info: Dict = {}
                    for element in df.iloc[i].index:
                        extracted_paper_info[element] = df.iloc[i][element]

                    new_row = pd.DataFrame([extracted_paper_info])
                    conditioned_df = pd.concat([conditioned_df, new_row], ignore_index=True)
        
        # AND検索
        else:
            each_tag = set(each_tag)
            ok = True
            for x in tags:
                if x not in each_tag:
                    ok = False
                    break
            if ok:
                extracted_paper_info: Dict = {}
                for element in df.iloc[i].index:
                    extracted_paper_info[element] = df.iloc[i][element]
                new_row = pd.DataFrame([extracted_paper_info])
                conditioned_df = pd.concat([conditioned_df, new_row], ignore_index=True)

    json = conditioned_df.to_json(orient='records')
    return jsonify(json)


@app.route('/translate_abstract', method=["GET", "POST"])
def translate_abstract_api():
    data: Dict = request.json
    translated_abstract = translate_abstract(data["abstract"])
    
    return jsonify({"translated_abstract": translated_abstract})
    
def translate_abstract(abstract_sentences: str) -> str:
    # OpenAI APIを用いてabstractを翻訳する
    # トークン数節約のため英語で指示を出す
    # refer1 : https://platform.openai.com/docs/guides/text-generation/chat-completions-api
    # refer2 : https://platform.openai.com/docs/guides/text-generation/chat-completions-vs-completions
    instruction_sentence = f"""
    Please translate given abstract of the paper written in English into Japanse.

    ## input
    {abstract_sentences}
    """
    model_id = "gpt-3.5-turbo"
    input_message = [{"role": "user", "content": instruction_sentence}]
    
    client = OpenAI()
    response = client.chat.completions.create(
        model=model_id,
        messages=input_message
    )
    return response.choices[0].message.content

if __name__ == "__main__":
    app.run(debug=True)