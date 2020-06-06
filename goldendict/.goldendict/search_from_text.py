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
    other_result = None
    with suppress(sh.ErrorReturnCode_1):
        _ = sh.egrep(f'([^-\']|^){word}([^-\']|$)', str(lemma_pathname))
        result = sh.egrep(f'\\b{word}\\b', _in=_)
        other_result = sh.egrep(f'^{word}', _in=result)
    if other_result is not None:
        lemma = sh.sed(f's|\\({word}\\).*|\\1|g', _in=other_result)
        lemma = lemma.strip()
        return lemma
    elif result is not None:
        lemma = sh.sed('s|\\([a-z]*\\).*|\\1|g', _in=result)
        lemma = lemma.strip()
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
        keyword = '{}'.format(keyword)
    else:
        inflections = lemma_to_inflections(lemma)
        keyword = '({})'.format('|'.join(inflections))
    record = ''

    for pathname in directory.rglob(f'*.{suffix}'):
        count = None
        running_command = None
        with suppress(sh.ErrorReturnCode_1):
            running_command = sh.egrep('-c', keyword, f'{pathname}')
        if running_command is not None and running_command.exit_code == 0:
            count = int(running_command)
            record += '<details>'
            record += f'<summary>{pathname.stem} <b>{count}</b></summary>'
            for inflection in inflections:
                try:
                    sh.egrep(inflection, f'{pathname}')
                except Exception:
                    pass
                else:
                    for line in sh.egrep(inflection, f'{pathname}'):
                        record += sh.sed(
                                f's|\\b{inflection}\\b|<b>&</b>|g', _in=line
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
