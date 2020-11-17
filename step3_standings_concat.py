import pandas as pd
import glob
from pathlib import Path

"""Concatenate dataframes from all months, all years, all leagues. Return one centralized dataframe"""
def df_concatenate():
    """Convert csvs to dataframes and then concatenate before returning csv"""
    ## Set relative path for csv concatenation.
    path = Path('basketballpredict', 'standings', '{}.csv'.format('*'))
    path_str = str(path)
    print(path_str)
    all_files = glob.glob(path_str)
    total =[]

    ## Loop through files and append to giant dataframe

    for filename in all_files:
        print(filename)
        df = pd.read_csv(filename, index_col=None, header=0)
        total.append(df)


    total = pd.concat(total, axis=0, ignore_index=True, sort=False)
    print(total.columns)
    total.to_csv(Path('basketballpredict', 'total_division_data.csv', header=True), line_terminator= '\n')
    print(total)
df_concatenate()
