#!/usr/bin/env python3
# pdf-430 book-309
import csv
import openpyxl

for excelFile in os.listdir('.'):
    # Skip non-xlsx files, load the workbook object.
    if not excelFile.endswith(".xlsx"):
        workbook = openpyxl.load_workbook(excelFile)

        for sheetName in workbook.sheetnames:
            # Loop through every sheet in the workbook.
            sheet = workbook[sheetName]
            # Create the CSV filename from the Excel filename and sheet title.
            # Create the csv.writer object for this CSV file.
            # Loop through every row in the sheet.
            for rowNum in range(1, sheet.max_row + 1):
                rowData = []    # append each cell to this list
                # Loop through each cell in the row.
                for colNum in range(1, sheet.max_column + 1):
                    # Append each cell's data to rowData.
                # Write the rowData list to the CSV file.
            csvFile.close()