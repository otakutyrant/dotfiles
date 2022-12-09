#!/usr/bin/bash
sed -i "/\b$1\b/ s/$/ deleted/" $HOME/.goldendict/wordlist/*.txt
