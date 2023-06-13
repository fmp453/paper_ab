import os
import pandas as pd


df = pd.DataFrame(columns=['id', 'title', 'abstract'])

if not os.path.exists('paper_info.csv'):
    df.to_csv('paper_info.csv', index=False)

df_tag = pd.DataFrame(columns=['tag_name', 'tag_id'])

if not os.path.exists('tags_table.csv'):
    df_tag.to_csv('tags_table.csv', index=False)