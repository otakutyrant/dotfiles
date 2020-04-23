#!/bin/bash

zotero () {
  # TODO: combine all text into a library and maintain it
  match_flag=false
  pdf_directory=$HOME/.zotero/zotero/yg83zi0h.default/zotero/storage
  tmp_directory=$HOME/tmp/zotero_txt
  sum=0
  count=0
  IFS=$'\n'
  for line in $(find $pdf_directory -name '*.pdf'); do
    if [ "$match_flag" = false ]; then
      match_flag=true
      echo "<b>zotero</b>"
      echo "<br>"
    fi
    filename="$(basename "$line" ".pdf").txt"
    text_pathname="$tmp_directory/$filename"
    if [ -f "$text_pathname" ] ; then
      if grep -c "$1" "$text_pathname" > /dev/null ; then
        count="$(grep -c "$1" "$text_pathname")"
        sum=$(( $sum + $count ))
      fi
    else
      pdftotext "$line" "$text_pathname" > /dev/null 2>&1
    fi
  done
  unset IFS
  if [ "$match_flag" = true ]; then
    echo "PDF count: $sum"
    echo "<br>"
  fi
}

calibre () {
  calibre_directory=$HOME/Calibre
  match_flag=false
  grep --include \*.txt -lr "\<$1\>" $calibre_directory | while read line; do
    if [ "$match_flag" = false ]; then
      match_flag=true
      echo "<b>calibre</b>"
      echo "<br>"
    fi
    headline="$(basename "$line" .txt)"
    echo "<details>"
    count="$(grep -c "\<$1\>" "$line")"
    echo "<summary>$headline <b>$count</b></summary>"
    grep -rIh --color=no "\<$1\>" "$line" | while read line; do
      echo $line | sed "s|\b$1\b|<b>&</b>|g"
      echo "<br>"
      echo "<br>"
    done
    echo "</details>"
  done
}

oxford () {
  grep "\b$1\b" $HOME/.goldendict/oxford5000.txt > /dev/null
  if [ $? -eq 0 ] ; then
    echo "<b>oxford level</b>"
    grep "\b$1\b" $HOME/.goldendict/oxford5000.txt
    echo "<br>"
  fi
}

subtitles () {
  match_flag=false
  subtitles_directory=$HOME/Nutstore/subtitles
  grep -lr "\<$1\>" $subtitles_directory | while read line; do
    if [ "$match_flag" = false ]; then
      match_flag=true
      echo "<b>subtitles</b>"
      echo "<br>"
    fi
    filename=`basename $line`
    echo "<details>"
    count="$(grep -c "\<$1\>" "$line")"
    echo "<summary>$filename <b>$count</b></summary>"
    grep -rIh --color=no "\<$1\>" "$line" | while read line; do
      echo $line | sed "s|\b$1\b|<b>&</b>|g"
      echo "<br>"
      echo "<br>"
    done
    echo "</details>"
  done
}

cat << 'EOF'
<!DOCTYPE html>
<html>
<body>
EOF

#zotero "$1"
calibre "$1"
subtitles "$1"
oxford "$1"

cat << 'EOF'
</body>
</html>
EOF
