#!/bin/env python3.8

from contextlib import suppress
from functools import partial
from pathlib import Path
import sys

import sh


def word_to_lemma(word: str):
    lemma_pathname = Path('/home/otakutyrant/Projects/ECDICT/lemma.en.txt')
    result = None
    other_result = None
    with suppress(sh.ErrorReturnCode_1):
        result = sh.egrep(
                f'([^-\']|^){word}([^-\']|$)', str(lemma_pathname)
        ).stdout.decode()
        result = sh.egrep(f'\\b{word}\\b', _in=result).stdout.decode()
        other_result = sh.egrep(f'^{word}', _in=result).stdout.decode()
    if other_result is not None:
        lemma = sh.sed(
                f's|\\({word}\\).*|\\1|g', _in=other_result).stdout.decode()
        lemma = lemma.strip()
        return lemma
    elif result is not None:
        lemma = sh.sed(
                's|\\([a-z]*\\).*|\\1|g', _in=result).stdout.decode()
        lemma = lemma.strip()
        return lemma
    else:
        return None


def lemma_to_inflections(lemma: str) -> list:
    lemma_pathname = Path('/home/otakutyrant/Projects/ECDICT/lemma.en.txt')
    line = sh.egrep(
            f'([^-\']|^){lemma}([^-\']|$)',
            str(lemma_pathname)).stdout.decode()
    line = sh.egrep(f'\\b{lemma}\\b', _in=line)
    inflections = line.split()[-1].split(',')
    inflections.append(lemma)
    return inflections


def search_from_directory(directory: Path, keyword: str, suffix: str) -> str:
    lemma = word_to_lemma(keyword)
    if lemma is None:
        inflections = [keyword]
    else:
        inflections = lemma_to_inflections(lemma)
    record = ''

    for pathname in directory.rglob(f'*.{suffix}'):
        count = None
        running_command = None
        with suppress(sh.ErrorReturnCode_1):
            combined_keywords = '({})'.format('|'.join(inflections))
            running_command = sh.egrep('-c', combined_keywords, f'{pathname}')
        if running_command is not None and running_command.exit_code == 0:
            count = running_command.stdout.decode()
            record += '<details>'
            record += f'<summary>{pathname.stem} <b>{count}</b></summary>'
            for keyword in inflections:
                try:
                    sh.egrep(keyword, f'{pathname}')
                except Exception:
                    pass
                else:
                    for line in sh.egrep(keyword, f'{pathname}'):
                        record += sh.sed(
                                f's|\\b{keyword}\\b|<b>&</b>|g', _in=line
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
        record = sh.egrep(f'\\b{keyword}\\b', str(pathname)).stdout.decode()
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
