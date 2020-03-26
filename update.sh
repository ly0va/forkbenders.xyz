#!/bin/bash

git pull

for md in $(ls templates)
do
    name=$(basename "$md" .md)
    cat header <(markdown-it -l -t "templates/$md") footer | sed "s/TITLE_TOKEN/$name/" > public/$name.html
done

