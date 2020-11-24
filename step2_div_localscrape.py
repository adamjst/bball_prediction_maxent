# Import libraries
import pandas as pd
import re
from bs4 import BeautifulSoup
from pathlib import Path
import numpy as np

"""Scrape local html file and return in html and formatted csv"""

n_teams = 0
def step2_scrape(league, year_start, years_back):
    """Scrape local html file for regular season data and return in html and csv in separate output folders"""
    yrs = []
    yrs.append(year_start)
    for i in range(years_back):
        yrs.append(yrs[i] - 1)
    for yr in yrs:
        print(yr)
        if yr < 2020 and yr > 2004:
            n_teams = 30
        elif yr < 2004 and yr > 1994:
            n_teams = 29
        elif yr < 1995 and yr > 1988:
            n_teams = 27
        elif yr == 1988:
            n_teams = 25
        elif yr < 1988 and yr > 1979:
            n_teams = 23
        elif yr < 1980 and yr > 1975:
            n_teams = 22
        elif yr == 1974 or yr == 1975:
            n_teams = 18
        elif yr == 1949 or yr < 1974 and yr > 1969:
            n_teams = 17
        elif yr == 1968 or yr == 1969:
            n_teams = 14
        elif yr == 1967 or yr == 1948:
            n_teams = 12
        elif yr == 1966 or yr == 1951:
            n_teams = 10
        elif yr < 1966 and yr > 1960:
            n_teams = 9
        elif yr == 1947 or yr < 1961 and yr > 1953:
            n_teams = 8
        elif yr == 1953:
            n_teams = 9
        elif yr == 1951 or yr == 1952:
            n_teams = 10
        elif yr == 1950 or yr == 1946:
            n_teams = 11


        ##Assign local path, URL
        ##Create relative path
        step1_html = Path('data', 'html', 'standings', '{}_{}_standings_step1.html'.format(league, yr), header=True)
        step2_csv = Path('basketballpredict', 'standings', '{}_{}_standings_step2.csv'.format(league, yr), header=True)

            # open local-saved html file
        page_url = open(step1_html, encoding = 'utf8')

        ## Apply Beautiful Soup to determine columns of new table##
        soup = BeautifulSoup(page_url, "html.parser")

        ##Setup of variables. Some not yet used.
        div = soup.find_all('table')
        header = []
        conferences = []
        standings = []
        wins = []
        losses = []
        win_pct = []
        GB = []
        AvgPts = []
        AvgPtsOpp = []
        SRS = []
        division = []
        out_divisions = []
        reg = r'\w+.(Division)'

        #Loop through div and acquire header and column names
        for d in div:
            first_row = d.find('thead')
            head = first_row.find('tr')
            cols = head.find_all('th')
            for col in cols:
                header.append(col.get_text())
            ##Identify main table body and loop to find teams and stats
            table = soup.find_all('tbody')[-2:]
            #print(table)
            for t in table:
                teams = t.find_all('tr')
                #print(teams)
                for t in teams:
                    spots = t.find_all('th')
                    #stats = t.find_all('td')
                    ##Strip teams of weird spacing
                    for s in spots:
                        raw_team = s.get_text()
                        clean_team = re.sub(r'\*?(\s\(\d+\)\s?)?', '', raw_team)
                        ##If new line marks a new division name, start a new list, else append to the most recent list
                        if re.match(reg, clean_team) or len(out_divisions) == 0:
                            out_divisions.append([clean_team])
                        else:
                            out_divisions[-1].append(clean_team)

        division.append(out_divisions)
        ##FOR ADDING EXTENDED STANDINGS INFORMATION. Not necessary, but will look to add in future
                    #print(division)
                        # for s in stats:
                        #     print(s)
                        #     wins.append(s.get_text('td'))
                        #     losses.append(s.get_text('td'))
                        #     win_pct.append(s.get_text('td'))
                        #     GB.append(s.get_text('td'))
                        #     AvgPts.append(s.get_text('td'))
                        #     AvgPtsOpp.append(s.get_text('td'))
                        #     SRS.append(s.get_text('td'))

        ##Create dataframe based on divisions
        teams_df = pd.DataFrame(division)
        # get length of df's columns
        num_cols = len(list(teams_df))
        # generate range of ints for suffixes
        # with length exactly half that of num_cols;
        # if num_cols is even, truncate concatenated list later
        # to get to original list length
        rng = range(1, num_cols + 2)

        new_cols = ['division_' + str(i) for i in rng] + ['expt_' + str(i) for i in rng]

        # ensure the length of the new columns list is equal to the length of df's columns
        teams_df.columns = new_cols[:num_cols]

        # transpose, add column name
        teams_df2 = pd.DataFrame.transpose(teams_df)
        teams_df2.columns= ["Teams"]
        #Convert lists to long format and add a couple columns
        teams_df3 = teams_df2.explode('Teams')
        teams_df3["SeasonStart"] = yr
        teams_df3["Assoc"] = league

        #Take only last table entries into list (division standings)
        teams_df4 = teams_df3.tail(36)
        #Remove Division names from dataframe and print to csv
        filter = teams_df4["Teams"].str.contains((reg))
        teams_df4 = teams_df4[~filter]
        teams_df4.to_csv((step2_csv), header=True)

# # # Run for each league during league's years of operation
#step2_scrape('WNBA', '', 2019, 23)
step2_scrape('NBA', 2019, 4)
# # #step2_scrape('NBA', 2019, 71, 'Playoffs')
# # step2_scrape('ABA', 1975, 9)
# # #step2_scrape('BAA', 1949, 4, 'Playoffs')
