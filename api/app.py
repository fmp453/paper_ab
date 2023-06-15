import os
import arxiv
import pandas as pd

from flask import Flask, request, jsonify

from logging import DEBUG, INFO, Formatter, FileHandler, StreamHandler, getLogger

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
    data = request.json
    
    if check_url(data["id"]):
        data = extract_id_from_url(data["id"])
    else:
        data["id"] = "url not match"

    if data["id"] == "url not match":
        logger.error(f"not correct URL : {data}")
        return data
    
    try:
        result = arxiv.Search(
            id_list=[data["id"]]
        )
    except :
        logger.error(f"Error : {data}")
        return f"Error : {data}"
    
    try:
        paper = next(result.results())
    except:
        logger.error(f"Error : {result}")
        return f"Error : {result}"
    
    json_res = {
        "id": data["id"],
        "title": paper.title,
        "abstract": paper.summary
    }
    return jsonify(json_res)

def extract_id_from_url(url):
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

def check_url(url):
    return "https" in url

@app.route('/add_info', methods=['GET', 'POST'])
def add_paper_action():
    data = request.json
    status = add_paper_to_csv(data['id'], data['title'], data['abstract'])
    return jsonify({"status" : status})


def add_paper_to_csv(id, title, abstract):
    csv_path = "../database/paper_info.csv"
    df = pd.read_csv(csv_path, dtype={'id': 'str'})

    if id == '' or title == 'URLまたはIDが間違っています' or abstract == '':
        return "IDまたはURLが間違っている可能性があります"

    if id in set(df["id"].values):
        return "Already added in the list"
    
    new_paper_info = {
        'id': id, 
        'title': title,
        'abstract': abstract
    }

    
    new_row = pd.DataFrame([new_paper_info])
    df = pd.concat([df, new_row], ignore_index=True)
    df.to_csv(csv_path, index=False)

    return "added into the list successfully"

@app.route('/add_tags', methods=['GET', 'POST'])
def add_paper_tags_action():
    data = request.json
    status = add_tags_to_csv(data['id'], data['tags'])
    return jsonify({"status" : status})

def add_tags_to_csv(id, tags):
    csv_path = "../database/tags_table.csv"
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
    csv_path = "../database/paper_info.csv"
    df = pd.read_csv(csv_path, dtype={'id': 'str'})
    logger.info("open csv file")
    json = df.to_json(orient='records')
    return jsonify(json)

@app.route('/tag_info', methods=["GET"])
def get_paper_tags():
    csv_path = "../database/tags_table.csv"
    df = pd.read_csv(csv_path, dtype={"tag_id": "str"})
    logger.info("OPEN TAG CSV")
    json = df.to_json(orient='records')
    return jsonify(json)

@app.route('/get_tags', methods=['GET'])
def get_tag_list():
    csv_path = "../database/tags_table.csv"
    df = pd.read_csv(csv_path)
    json = df["tag_name"].to_json(orient='records', force_ascii=False)
    return jsonify(json)

if __name__ == "__main__":
    app.run(debug=True)