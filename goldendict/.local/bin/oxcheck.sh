#!/usr/bin/bash
sed -n "/\b$1\b/p" $HOME/.goldendict/wordlist/*.txt
