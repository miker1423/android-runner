import sys
import os
import pandas as pd
import pandasql as ps
from pandas import DataFrame


def load_files(input_path, inner_path, sep) -> []:
    list_dirs = os.listdir(input_path)
    empty_dirs = []
    data = []
    for directory in list_dirs:
        complete_path = input_path + directory + inner_path
        list_of_file = os.listdir(complete_path)
        resource_type, website = classification(directory, sep)
        if list_of_file and len(list_of_file) > 0:
            fp_files, fcp_files, lcp_files, fid_files = list_of_files_by_category(complete_path)
            fp, fcp, lcp, fid = aggregate_values(complete_path, fp_files, fcp_files, lcp_files, fid_files)
            data.append([directory, website, resource_type, float(fp), float(fcp), float(lcp), float(fid)])
        else:
            web_link = fix_website_link(directory, website)
            url = '"' + resource_type + '/' + web_link + '"'
            empty_dirs.append([directory, resource_type, web_link, url])
    export_empty_directories(data=empty_dirs)
    return data


# A trivial change to re-run the websites
def fix_website_link(directory: str, website: str) -> str:
    ext_token: [] = directory.split('-')
    ext: str = ext_token[len(ext_token) - 1]
    website_tokens: [] = website.split('-')
    fixed_website_name: str = ''
    for x in range(0, len(website_tokens) - 1):
        fixed_website_name += website_tokens[x] + '-'
    fixed_website_name = fixed_website_name[0: len(fixed_website_name) - 1]
    fixed_website_name += '.' + ext
    return fixed_website_name


def export_empty_directories(data):
    df = pd.DataFrame(data=data, columns=['directories', 'resource_hint_type', 'website', 'url'])
    df = df.sort_values('resource_hint_type')
    df.to_csv('empty_directories.csv')


def classification(directory: str, split_sep: str) -> (str, str):
    sep: str = '-'
    website_classification_str: str = directory.split(split_sep)[1]
    in_arr = website_classification_str.split(sep)
    resource_hint_type: str = in_arr[0] + sep + in_arr[1]
    website: str = ''
    for x in range(2, len(in_arr)):
        website += in_arr[x] + sep
    website = website[0:len(website) - 2]
    return resource_hint_type, website


def aggregate_values(complete_path, fp_files, fcp_files, lcp_files, fid_files) -> (float, float, float, float):
    fp_column_name = 'fp'
    fcp_column_name = "fcp"
    lcp_column_name = 'lcp'
    fid_column_name = 'fid'

    avg_fp: float = 0.0
    avg_fcp: float = 0.0
    avg_lcp: float = 0.0
    avg_fid: float = 0.0

    agg_fp: float = 0.0
    agg_fcp: float = 0.0
    agg_lcp: float = 0.0
    agg_fid: float = 0.0

    total_files_fp: int = len(fp_files)
    total_files_fcp: int = len(fcp_files)
    total_files_lcp: int = len(lcp_files)
    total_files_fid: int = len(fid_files)

    # To check if the list is not empty
    if fp_files:
        for fp_file in fp_files:
            df = pd.read_csv(complete_path + fp_file)
            agg_fp += df[fp_column_name]
            if df[fp_column_name][0] == 0.0 and total_files_fp > 0:
                total_files_fp = total_files_fp - 1
        avg_fp = agg_fp / total_files_fp
    if fcp_files:
        for fcp_file in fcp_files:
            df = pd.read_csv(complete_path + fcp_file)
            agg_fcp += df[fcp_column_name]
            if df[fcp_column_name][0] == 0.0 and total_files_fcp > 0:
                total_files_fcp = total_files_fcp - 1
        avg_fcp = agg_fcp / total_files_fcp
    if lcp_files:
        for lcp_file in lcp_files:
            df = pd.read_csv(complete_path + lcp_file)
            agg_lcp += df[lcp_column_name]
            if df[lcp_column_name][0] == 0.0 and total_files_lcp > 0:
                total_files_lcp = total_files_lcp - 1
        avg_lcp = agg_lcp / total_files_lcp
    if fid_files:
        for fid_file in fid_files:
            df = pd.read_csv(complete_path + fid_file)
            agg_fid += df[fid_column_name]
            if df[fid_column_name][0] == 0.0 and total_files_fid > 0:
                total_files_fid = total_files_fid - 1
        avg_fid = agg_fid / total_files_fid
    return avg_fp, avg_fcp, avg_lcp, avg_fid


def list_of_files_by_category(complete_path) -> ([], [], [], []):
    files = os.listdir(complete_path)
    fcp = []
    fp = []
    lcp = []
    fid = []
    for filename in files:
        file_type = filename.split('_')[0]
        if file_type.upper() == 'FCP':
            fcp.append(filename)
        elif file_type.upper() == 'FP':
            fp.append(filename)
        elif file_type.upper() == 'LCP':
            lcp.append(filename)
        elif file_type.upper() == 'FID':
            fid.append(filename)
    return fp, fcp, lcp, fid


def save_file(output_filename: str, data: []) -> None:
    df = pd.DataFrame(data=data, columns=['directory', 'website_name', 'resource_hint_type', 'fp', 'fcp', 'lcp', 'fid'])
    df = df.sort_values(['website_name', 'resource_hint_type'])
    df.to_csv(output_filename, sep='|')


def battery_stat(path, spliter):
    battery_stat_df = pd.read_csv(path, sep=',')
    data = []
    for index in battery_stat_df.index:
        directory = battery_stat_df['subject'][index]
        power_consumption = battery_stat_df['power'][index]
        resource_type, website = classification(directory, spliter)
        web_link = fix_website_link(directory, website)
        data.append([directory, web_link, resource_type, power_consumption])
    df = pd.DataFrame(columns=['Directory', 'Website', 'Resource_Type', 'Power_Consumption'], data=data)
    df = df.sort_values(['Resource_Type'])
    df.to_csv('power_consumption.csv')


def generate_data(path:str):
    input_path = 'IP3/nokia_incognito/'
    inner_path = '/chrome/perfume_js/'
    output_filename = 'final_result.csv'
    data: [] = load_files(path, inner_path, '-t4-t4-')
    save_file(output_filename, data)


def execute_query(path: str, query: str):
    df = pd.read_csv(path, sep='|')
    df1 = ps.sqldf(query)
    return df1


def analyze() -> DataFrame:
    # query = 'select distinct(website_name) from df'
    query = 'select website_name,count(1) from df group by website_name having count(1)=8'
    df = execute_query('final_result.csv', query)
    print(df)


if __name__ == '__main__':
    path = sys.argv[1]
    generate_data(path)
    # analyze()
    # To run the batterystat uncomment the below two lines
    # battery_stat_path = 'New_Power_Consumption.csv'
    # battery_stat(battery_stat_path, '-t4-t4-')
