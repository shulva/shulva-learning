#!/usr/bin/env python3
# pdf-308 book-210
# use selenium and webdriver-manager
from selenium import webdriver
from selenium.webdriver.common.by import By

options = webdriver.ChromeOptions()
options.add_experimental_option('detach',True)

browser = webdriver.Chrome(options=options)
browser.get('https://mail.qq.com')

password = browser.find_element(By.CSS_SELECTOR,'a#switcher.plogin.link')
print(password.text)
password.click()
