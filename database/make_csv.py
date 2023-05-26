import pandas as pd


df = pd.DataFrame(columns=['id', 'title', 'abstract'])

df.to_csv('paper_info.csv', index=False)
