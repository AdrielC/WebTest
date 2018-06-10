import time
import datetime
import pandas as pd
import unicodecsv as csv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


class webSession():
    def __init__(self, url):
        chrome_options = webdriver.ChromeOptions()

        self.browser = webdriver.Chrome(chrome_options= chrome_options)
        self.browser.set_page_load_timeout(30)
        self.browser.get(url)
        
        cookies = self.browser.get_cookies()
        keys = cookies[0].keys()
        
        with open('test1.csv', 'wb') as output_file:
            dict_writer = csv.DictWriter(output_file, keys)
            dict_writer.writeheader()
            dict_writer.writerows(cookies)
      
    def scrollPage(self):
        
        SCROLL_PAUSE_TIME = 0.0001
        
        # Get scroll height
        last_height = self.browser.execute_script("return document.body.scrollHeight")

        while True:
          # Scroll down to bottom
          self.browser.execute_script("window.scrollTo(window.pageYOffset, window.pageYOffset + 5);")
        
          # Wait to load page
          #time.sleep(SCROLL_PAUSE_TIME)
        
          # pageYOffset will work consistently for all browsers
          current_height = self.browser.execute_script("return window.pageYOffset")
        
          if current_height >= last_height:
            break
        
        return self.browser.page_source

def scroll_site(URL):
    Session = webSession(URL)
    data = Session.scrollPage()
    Session.browser.quit()

    return data
