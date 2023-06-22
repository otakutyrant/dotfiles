The original lemma.en.txt comes from [skywind3000/ECDICT](https://raw.githubusercontent.com/skywind3000/ECDICT/master/lemma.en.txt). And the removed claim is shown below:

> En Lemma Database (version 1.0.3)
> Compiled by Lin Wei (https://github.com/skywind3000), Mar 28, 2017
> by referencing the 100M+ words in the British National Corpus (BNC),
> NodeBox Linguistics and Yasumasa Someya's lemma list.
> This lemma list is provided "as is" and is free to use for any research
> and/or educational purposes.
> The list currently contains 186,523 words (tokens) in 84,487 lemma groups.
> If you have any questions or comments about this lemma list, feel free
> to contact me (skywind3000@163.com), at any time..

The search_from_text supports global search for a keyword of any length, like "delusion", "ask for", and "get rid of", in a Calibre diretory which have some txts, or in a subtitles directory which have some srt files. And it can shows what oxford level a keyword is too.

I recommend use this script in GolddenDict as a program. Note that it only passes test on my own Linux, it may take your own a little effort to make it work on other systems.

The only dependence is sh. I use Arch Linux so I `pacman -S python-sh` immediately.
