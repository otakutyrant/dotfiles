#!/bin/env python3.8

from functools import partial
import itertools
from pathlib import Path
import sys

import sh

# sh.RunCommand class is a str subtype


def word_to_lemma(word: str):
    lemma_pathname = Path('/home/otakutyrant/Projects/ECDICT/lemma.en.txt')
    result = None
    try:
        _ = sh.egrep(f'([^-\']|^){word}([^-\']|$)', str(lemma_pathname))
        result = sh.egrep(f'\\b{word}\\b', _in=_)
    except sh.ErrorReturnCode_1:
        return None
    else:
        if '/' in result:
            lemma = result.split(' ')[0].split('/')[0]
        else:
            lemma = result.split(' ')[0]
        return lemma


def lemma_to_inflections(lemma: str) -> list:
    lemma_pathname = Path('/home/otakutyrant/Projects/ECDICT/lemma.en.txt')
    line = sh.egrep(f'([^-\']|^){lemma}([^-\']|$)', str(lemma_pathname))
    line = sh.egrep(f'\\b{lemma}\\b', _in=line)
    inflections = line.split()[-1].split(',')
    if lemma not in inflections:
        inflections.insert(0, lemma)
    return inflections


def search_from_directory(directory: Path, keyword: str, suffix: str) -> str:
    combinations = []
    words = keyword.split(' ')
    for word in words:
        lemma = word_to_lemma(word)
        if lemma is None:
            combinations.append((word,))
        else:
            inflections = lemma_to_inflections(lemma)
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


calibre_directory = Path.home() / 'Calibre'
calibre = partial(search_from_directory, calibre_directory, suffix='txt')
subtitles_directory = Path.home() / 'Nutstore/subtitles'
subtitles = partial(search_from_directory, subtitles_directory, suffix='srt')


def oxford(keyword: str) -> str:
    pathname = Path.home() / '.goldendict/oxford5000.txt'
    lemma = word_to_lemma(keyword)
    if lemma is not None:
        keyword = lemma
    try:
        record = sh.egrep(
                f'\\b{keyword}\\b', str(pathname)).stdout.decode().strip()
    except sh.ErrorReturnCode_1:
        return ""
    else:
        return f"""
        <b>oxford level</b>
        {record}
        <br>
        """
        return ""


def main():
    keyword = sys.argv[1]
    record = """
    <!DOCTYPE html>
    <html>
    <body>
    """
    functions = (calibre, subtitles, oxford)
    for function in functions:
        record += function(keyword)
    record += """
    </body>
    </html>
    """
    return record


if __name__ == '__main__':
    print(main())
