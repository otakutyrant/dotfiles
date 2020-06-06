#!/bin/env python3.8

from contextlib import suppress
from functools import partial
from pathlib import Path
import sys

import sh

# sh.RunCommand class is a str subtype


def word_to_lemma(word: str):
    lemma_pathname = Path('/home/otakutyrant/Projects/ECDICT/lemma.en.txt')
    result = None
    with suppress(sh.ErrorReturnCode_1):
        _ = sh.egrep(f'([^-\']|^){word}([^-\']|$)', str(lemma_pathname))
        result = sh.egrep(f'\\b{word}\\b', _in=_)
    if result is not None:
        if '/' in result:
            lemma = result.split(' ')[0].split('/')[0]
        else:
            lemma = result.split(' ')[0]
        return lemma
    else:
        return None


def lemma_to_inflections(lemma: str) -> list:
    lemma_pathname = Path('/home/otakutyrant/Projects/ECDICT/lemma.en.txt')
    line = sh.egrep(f'([^-\']|^){lemma}([^-\']|$)', str(lemma_pathname))
    line = sh.egrep(f'\\b{lemma}\\b', _in=line)
    inflections = line.split()[-1].split(',')
    if lemma not in inflections:
        inflections.insert(0, lemma)
    return inflections


def search_from_directory(directory: Path, keyword: str, suffix: str) -> str:
    lemma = word_to_lemma(keyword)
    if lemma is None:
        inflections = [keyword]
        pattern = '\\b{}\\b'.format(keyword)
    else:
        inflections = lemma_to_inflections(lemma)
        pattern = '\\b({})\\b'.format('|'.join(inflections))
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
