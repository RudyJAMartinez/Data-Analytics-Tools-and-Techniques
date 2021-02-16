
# #### **1.** Scrape S&P 500 companies from Wikipedia and create a CSV file with the scraped company information
# #### **2.** Create a dataframe from the CSV and randomly select 1 security (ticker symbol)
# #### **3.** Scrape the Yahoo Finance site for key statistics, financial statements and stock price history for the selected security 
# #### **4.** Create a multi-layered stock screen to determine company's financial strength (fundamental analysis via Piotroski F-Score)
# #### **5.** Scrape Yahoo News Articles for langauge associated with "positive" sentiment for the security
# #### **6.** Can financial strength and positive sentiment predict stock price?


import random
from bs4 import BeautifulSoup
import requests
import pandas as pd
from io import StringIO
import csv



# #### **1. Scrape S&P 500 companies from Wikipedia and create a CSV file with the scraped company information**
#Acquires Wikipedia page content for S&P500 companies
wiki_url = 'https://en.wikipedia.org/wiki/List_of_S%26P_500_companies'
response_1 = requests.get(wiki_url)
company_page_content = BeautifulSoup(response_1.text, 'html.parser')

#Stores the table with company information into the company_table variable
table_id = "constituents"
company_table = company_page_content.find('table', attrs={'id': table_id})

#Creates a dataframe with company information and writes to csv
df = pd.read_html(str(company_table))
df[0].to_csv('00. S&P500 Company Information.csv')




# #### **2. Create a dataframe from the CSV and randomly select 1 security (ticker symbol)**
#Reads the CSV that was generated
csv_df = pd.read_csv('00. S&P500 Company Information.csv')

#Creates a list of companies
company_list = csv_df['Symbol'].to_list()

#Randomly select 1 company from company_list
random_company = random.sample(company_list,1)

#Establishes the randomly selected stock variable as a string
stock = ''.join(random_company)




# #### **3. Scrape the Yahoo Finance site for financial statements for the selected security**
#Funtion that makes all values numerical - will be needed in the below financial statement scraping
def conv_to_num(column):
    first_col = [val.replace(',','') for val in column]
    second_col = [val.replace('-','') for val in first_col]
    final_col = pd.to_numeric(second_col)
    
    return final_col

#Establishes the randomly selected stock variable as a string
stock = ''.join(random_company)

#Establishes URLs for Financial Statements and places them in a list
url_inc_statement = 'https://finance.yahoo.com/quote/{}/financials?p={}'
url_bs_statement = 'https://finance.yahoo.com/quote/{}/balance-sheet?p={}'
url_cf_statement = 'https://finance.yahoo.com/quote/{}/cash-flow?p={}'
url_list = [url_inc_statement, url_bs_statement, url_cf_statement]

statement_count = 0

for statement in url_list:
    #Acquires company financial statement page content 
    response_2 = requests.get(statement.format(stock, stock))
    fin_content = BeautifulSoup(response_2.text, 'html.parser')
    fin_data = fin_content.find_all('div', class_= 'D(tbr)')

    headers = []
    temp_list = []
    label_list = []
    final = []
    index = 0

    #Creates Headers for statement
    for item in fin_data[0].find_all('div', class_= 'D(ib)'):
        headers.append(item.text)

    #Statement Contents
    while index <= len(fin_data) - 1:
        temp = fin_data[index].find_all('div', class_= 'D(tbc)')
        for line in temp:
            temp_list.append(line.text)
        final.append(temp_list)
        temp_list = []
        index += 1
    
    #Places statement contents into a dataframe
    df = pd.DataFrame(final[1:])
    df.columns = headers
    
    #Makes all values numerical and removes na 
    for column in headers[1:]:
        df[column] = conv_to_num(df[column])
    
    final_df = df.fillna('0')
    
    #Used as a naming input for the csv export below
    statement_count += 1
    
    #Writes to csv for each financial statement
    if statement_count == 1:
        final_df.to_csv(f'01. {stock} Income Statement.csv')
    elif statement_count == 2:
        final_df.to_csv(f'02. {stock} Balance Sheet.csv')
    else:
        final_df.to_csv(f'03. {stock} Cash Flow Statement.csv')




# #### **3. Scrape the Yahoo Finance site for stock price history for the selected security**
#Acquires stock price history for the selected stock
stock_url = 'https://query1.finance.yahoo.com/v7/finance/download/{}?'

#Parameters for 5 yeares of stock history
params = {
    'range': '5y',
    'interval': '1d',
    'events':'history'
}

#Acquire the data from the page given the above params
response_3 = requests.get(stock_url.format(stock), params=params)

#Puts the stock price data into a list
price_file = StringIO(response_3.text)
reader = csv.reader(price_file)
data = list(reader)

#Creates a stock price data frame and write to CSV
price_df = pd.DataFrame(data)
price_df.to_csv(f'04. {stock} Stock Price - 5 Year Historical.csv')





# #### **3. Scrape the Yahoo Finance site for key statistics for the selected security**
#Established url for Key Statistics
stats = pd.read_html(f'https://finance.yahoo.com/quote/{stock}/key-statistics?p={stock}')

#Create dataframe with statistics
key_stats = stats[0]
stats_df = pd.DataFrame(key_stats)

#Write the dataframe to csv
stats_df.to_csv(f'05. {stock} Statistics.csv')




# #### **4. Create a multi-layered stock screen to determine company's financial strength (fundamental analysis via Piotroski F-score)**
# Importing Yahoo Finance module for the financial items that were not able to be scraped (the majority of the financials are coming from the initial web_scrape)
import yahoo_fin.stock_info as yf

yf_bs = []
yf_is = []
yf_cf = []
years = []

yf_bs = yf.get_balance_sheet(stock)
yf_is = yf.get_income_statement(stock)
yf_cf = yf.get_cash_flow(stock)
years = yf_bs.columns

#Reads in the financial statement CSVs that were generated as well as the years
income_statement = pd.read_csv(f'01. {stock} Income Statement.csv')
balance_sheet = pd.read_csv(f'02. {stock} Balance Sheet.csv')
cashflow_statement = pd.read_csv(f'03. {stock} Cash Flow Statement.csv')
years = list(income_statement.columns[3:6])

#Remove first column from dataframes
income_statement.drop(income_statement.columns[0], axis = 1, inplace = True)
balance_sheet.drop(balance_sheet.columns[0], axis = 1, inplace = True)
cashflow_statement.drop(cashflow_statement.columns[0], axis = 1, inplace = True)

#Initialize scoring tracker
profitability_score = 0
leverage_liquidity_score = 0
operating_efficiency_score = 0


def profitability():
    global profitability_score
    
    roa_cy = float(income_statement.iloc[4, 2]) / float(balance_sheet.iloc[0, 1])
    roa_py = income_statement.iloc[4, 3] / balance_sheet.iloc[0, 2]
    cfo_cy = cashflow_statement.iloc[0, 2]
    cfo_py = cashflow_statement.iloc[0,3]
    
    #return on assets logic
    if roa_cy > 0:
        profitability_score += 1
    if roa_cy - roa_py > 0:
        profitability_score += 1
    else:
        profitability_score += 0
   
    #cash flow from operations logic
    if cfo_cy > 0:
        profitability_score += 1
    if cfo_cy - cfo_py > 0:
        profitability_score += 1
    else:
        profitability_score += 0
    
    return profitability_score


def leverage():
    global leverage_liquidity_score
    
    lever_cy = balance_sheet.iloc[8, 1] / balance_sheet.iloc[0, 1]
    lever_py = balance_sheet.iloc[8, 2] / balance_sheet.iloc[0, 2]
    cur_ratio_cy = yf_bs.iloc[15, 0] / yf_bs.iloc[13, 0]
    cur_ratio_py = yf_bs.iloc[15, 1] / yf_bs.iloc[13, 1]
    share_cy = balance_sheet.iloc[10, 1]
    share_py = balance_sheet.iloc[10, 2]
    
    #leverage logic
    if lever_cy - lever_py < 0:
        leverage_liquidity_score += 1
    else:
        leverage_liquidity_score += 0
    
    #liquidity logic
    if cur_ratio_cy - cur_ratio_py > 0:
        leverage_liquidity_score += 1
    else:
        leverage_liquidity_score += 0
    
    #shares logic
    if share_cy - share_py < 0:
        leverage_liquidity_score += 1
    else:
        leverage_liquidity_score+= 0

    return leverage_liquidity_score
    

def operating_efficiency():
    global operating_efficiency_score
    
    gm_cy = yf_is.iloc[6, 0] / yf_is.iloc[15, 0]
    gm_py = yf_is.iloc[6, 1] / yf_is.iloc[15, 1]
    turn_cy = balance_sheet.iloc[0, 2] / ((balance_sheet.iloc[0, 1] + balance_sheet.iloc[0, 2]) / 2)
    turn_py = balance_sheet.iloc[0, 3] / ((balance_sheet.iloc[0, 2] + balance_sheet.iloc[0, 3]) / 2)
    
    #gm logic
    if gm_cy - gm_py > 0:
        operating_efficiency_score += 1
    else:
        operating_efficiency_score += 0
    
    #asset turnover ratio logic
    if turn_cy - turn_py > 0:
        operating_efficiency_score += 1
    else:
        operating_efficiency_score += 0
        
    return operating_efficiency_score




# #### **4. Export Financial Strength Scoring CSV (fundamental analysis via Piotroski F-Score)**
p_score = profitability()
lev_score = leverage()
oper_score = operating_efficiency()

fin_strength_scores = {'Profitability Score': p_score, 
                       'Leverage and Liquidity Score': lev_score, 
                       'Operating Efficiency Score': oper_score, 
                       'Total Score': p_score + lev_score + oper_score}

fin_strength_df = pd.DataFrame(list(fin_strength_scores.items()),columns = ['Scoring Criteria','Score']) 
fin_strength_df.to_csv(f'06. {stock} Piotroski Score Results.csv')