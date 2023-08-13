#!/usr/bin/env python3
# pdf-369 book-258
import openpyxl
import sys
from openpyxl.utils import get_column_letter

n = int(sys.argv[1])
m = int(sys.argv[2])  # space
file = str(sys.argv[3])

workbook = openpyxl.load_workbook(file)
first = workbook.sheetnames[0]
sheet = workbook[first]

row_max = sheet.max_row
column_max = sheet.max_column

for row in range(row_max, -1, n):
    for column in range(column_max):
        row_next = row + m
        column_next = get_column_letter(column)
        sheet[column_next+str(row_next)] = sheet[column_next+str(row)]

workbook.save('13-14-1.xlsx')
