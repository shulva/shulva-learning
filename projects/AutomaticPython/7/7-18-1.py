#!/usr/bin/env python
# pdf-186/228 book-146

import re
import sys
date_regex=re.compile(r'(\d\d)/(\d\d)/(\d\d\d\d)')
date_analyse=date_regex.search(sys.argv[0])

if date_analyse==None:
    print("date do not fit regex")
