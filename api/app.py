import arxiv
import pandas as pd

from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/api', methods=['GET', 'POST'])
def data_with_url():
    data = request.json
    
    if check_url(data["id"]):
        data = extract_id_from_url(data["id"])
    else:
        data["id"] = "url not match"

    if data["id"] == "url not match":
        return data
    
    try:
        result = arxiv.Search(
            id_list=[data["id"]]
        )
    except :
        return f"Error : {data}"
    
    try:
        paper = next(result.results())
    except:
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


@app.route('/paper_info', methods=['GET'])
def get_paper_info():
    csv_path = "../database/paper_info.csv"
    df = pd.read_csv(csv_path, dtype={'id': 'str'})
    json = df.to_json(orient='records')
    return jsonify(json)


if __name__ == "__main__":
    app.run(debug=True)