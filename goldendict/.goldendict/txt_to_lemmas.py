#!/bin/env python

from collections import Counter
from pathlib import Path

from search_from_text import word_to_inflections


def main():
    hashmap = {}
    lemma_pathname = Path.home() / '.goldendict/lemma.en.txt'
    with open(lemma_pathname) as lemma_file:
        for line in lemma_file:
            lemma, _, inflections = line.split(' ')
            lemma = lemma.split('/')[0]
            hashmap[lemma] = lemma
            inflections = inflections.split(',')
            for inflection in inflections:
                hashmap[inflection] = lemma
    for pathname in (Path.home() / 'Calibre Library').glob('**/*.txt'):
        # if pathname != Path('/home/otakutyrant/Calibre Library/Hourly History/The Black Death_ A History From Begi (65)/The Black Death_ A History From - Hourly History.txt'):
        if pathname.name == 'lemmas.txt':
            continue
        lemma_pathname = pathname.parent / 'lemmas.txt'
        with open(pathname) as file_, open(lemma_pathname, 'w') as lemma_file:
            words = [
                    word
                    for line in file_
                    for word in line.split()
                    if word.isalpha() and word.isascii()
            ]
            set_ = set(words)
            words = [
                    word.lower()
                    if word.lower() in set_
                    else word
                    for word in words
            ]
            lemmas = [
                    hashmap[word.lower()]
                    if word.lower() in hashmap
                    else word
                    for word in words
            ]
            counter = Counter(lemmas)
            for word, count in counter.most_common():
                lemma_file.write(f'{word} {count}\n')
        print(f'{pathname} done.')


if __name__ == '__main__':
    main()
