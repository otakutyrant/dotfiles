#!/usr/bin/bash
sed -i "/\b$1\b/d" $HOME/.goldendict/wordlist/*.txt
