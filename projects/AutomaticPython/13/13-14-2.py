#!/usr/bin/env python3
# pdf-369 book-258
import openpyxl
import sys
from openpyxl.styles import Font
from openpyxl.utils import get_column_letter, column_index_from_string

n = int(sys.argv[1])
m = int(sys.argv[2])
file = int(sys.argv[3])
