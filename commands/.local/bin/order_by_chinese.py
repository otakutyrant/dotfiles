#!/bin/env python
import re
import shutil
from pathlib import Path

import requests


def cn2an(chinese_num) -> int:
    params = {
        "text": chinese_num,
        "function": "cn2an",
        "method": "strict",
    }
    response = requests.get("https://api.dovolopor.com/v1/cn2an", params)
    assert response.json()["msg"] == "转化成功"
    arab_num = response.json()["output"]
    return arab_num


# 获取当前目录
directory_pathname = Path.cwd()

max_digits_length = 0
rename_map = {}

for file_pathname in directory_pathname.iterdir():
    if file_pathname.name.split()[0].isnumeric():
        continue
    match = re.search("[一二三四五六七八九十]+", file_pathname.name)
    if match:
        chinese_num = match.group()
        max_digits_length = max(max_digits_length, len(chinese_num))
        rename_map[file_pathname] = arab_num = cn2an(chinese_num)

for file_pathname, arab_num in rename_map.items():
    rename_map[file_pathname] = str(arab_num).zfill(max_digits_length)

for file_pathname in rename_map.keys():
    new_name = rename_map[file_pathname] + " " + file_pathname.name
    new_pathname = directory_pathname / new_name
    shutil.move(file_pathname, new_pathname)
