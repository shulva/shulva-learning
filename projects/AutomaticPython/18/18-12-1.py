import openpyxl
import random
import smtplib
# pdf-568

mail_list = openpyxl.load_workbook("mail.xlsx")
sheet = mail_list[mail_list.sheetnames[0]]

max_row = sheet.max_row

chores = []
mails = []
for i in range(max_row):
    mails.append(sheet['A'+str(i+1)].value)
    chores.append(sheet['B'+str(i+1)].value)

smtp = smtplib.SMTP('smtp.qq.com', 587)
smtp.ehlo()
smtp.starttls()

for i in range(len(mails)):
    if mails[i] is not None:
        smtp.login(str(mails[i]), input())
        random_chore = random.choice(chores)
        smtp.sendmail(mails[i], str(random.choice(mails)), random_chore)
        chores.remove(random_chore)
