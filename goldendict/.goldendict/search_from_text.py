#!/bin/env python

from functools import partial
import itertools
from pathlib import Path
import re
import sys

import sh

# sh.RunCommand class is a str subtype

lemma_pathname = Path.home() / '.goldendict/lemma.en.txt'
lemma_file = open(lemma_pathname)


def word_to_inflections(word: str):
    for line in lemma_file:
        match = re.search(rf'(?=[^-\']|^)\b{word}\b(?=[^-\']|$)', line)
        if match:
            lemma = line.split(' ')[0].split('/')[0]
            inflections = line.split()[-1].split(',')
            if lemma not in inflections:
                inflections.insert(0, lemma)
            else:
                index = inflections.index(lemma)
                inflections[0], inflections[index] = inflections[index], inflections[0]
            return inflections
    return None


def search_from_directory(directory: Path, keyword: str, suffix: str) -> str:
    combinations = []
    words = keyword.split(' ')
    for word in words:
        inflections = word_to_inflections(word)
        if inflections is None:
            combinations.append((word,))
        else:
            combinations.append(inflections)
    keywords = list(itertools.product(*combinations))

    def words_to_keyword(words):
        return ' '.join(words)
    keywords = [words_to_keyword(words) for words in keywords]
    pattern = '\\b({})\\b'.format('|'.join(keywords))
    record = ''

    for pathname in directory.rglob(f'*.{suffix}'):
        count = None
        running_command = None
        try:
            running_command = sh.egrep('-c', pattern, f'{pathname}')
        except sh.ErrorReturnCode_1:
            pass
        else:
            count = int(running_command)
            record += '<details>'
            record += f'<summary>{pathname.stem} <b>{count}</b></summary>'
            for line in sh.egrep(pattern, f'{pathname}'):
                record += sh.sed(
                        '-E', f's/{pattern}/<b>&<\\/b>/g', _in=line
                ).stdout.decode().strip()
                record += '<br>'
                record += '<br>'
            record += '</details>'
    if record != '':
        record = f"""
        <b>{directory.stem}</b>
        <br>
        """ + record
    return record


calibre_directory = Path.home() / 'Calibre Library'
calibre = partial(search_from_directory, calibre_directory, suffix='txt')
subtitles_directory = Path.home() / 'Nutstore/subtitles'
subtitles = partial(search_from_directory, subtitles_directory, suffix='srt')


def main():
    keyword = sys.argv[1]
    record = """<!DOCTYPE html>
<html>
<body>
"""
    functions = (calibre, subtitles)
    for function in functions:
        record += function(keyword)
    record += """</body>
</html>"""
    line_numbers = len(record.split('\n'))
    if line_numbers > 5:
        print(record)


if __name__ == '__main__':
    main()
    # word_to_lemma('foodstuff')
