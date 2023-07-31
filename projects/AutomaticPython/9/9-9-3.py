#!/usr/bin/env python
# pdf-230 book-179

import sys,re,os
from pathlib import Path

search_regex = re.compile(str(sys.argv[1]))

for filename in list((Path(Path.cwd()).glob('*.txt'))):

    file = open(Path.cwd() / filename)
    string = file.readlines()
    
    for item in string:
        if search_regex.search(item) != None:
            print(item)

    file.close()


