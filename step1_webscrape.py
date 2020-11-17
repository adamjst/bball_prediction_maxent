# Import libraries
import requests
from pathlib import Path

"""Scrape regular season and playoff game summary data from basketball reference and convert it to a raw html output."""


headers = {'User-Agent': 'Adam Sawyer', 'From': 'ajsawyer@syr.edu'}
##Source
##https://urllib3.readthedocs.io/en/latest/user-guide.html


##Set the nested loop
def step1_scrape(league, year_start, years_back, stage):
    """Scrape regular season game summary data and save it to a local folder in raw html form."""
    ##Set three parameters for loop: league, year, and month
    years = []
    # May and June accounted for under playoffs.
    months = ['october', 'november', 'december', 'january', 'february', 'march', 'april']
    years.append(year_start)
    for i in range(years_back):
        years.append(years[i] - 1)
    if league == 'WNBA':
        for year in years:
            print('WNBA', year)
            step1_html = Path('data', 'html', '{}_{}_step1.html'.format(league, year), header=True)
            url = 'https://www.basketball-reference.com/wnba/years/{}-schedule.html'.format(year)
            page_url = requests.get(url).text.encode('utf-8')
            str_html = page_url
            with open(step1_html, 'wb') as f:
                f.write(str_html)
                f.close()
    else:
        for year in years:
            if stage == 'Playoffs':
                print('playoffs', year)
                # Create relative path
                step1_html = Path('data', 'html', 'playoffs', '{}_{}_playoffs_step1.html'.format(league, year), header=True)
                url = 'https://www.basketball-reference.com/playoffs/{}_{}_games.html'.format(league, year)
                page_url = requests.get(url).text.encode('utf-8')
                str_html = page_url
                with open(step1_html, 'wb') as f:
                    f.write(str_html)
                    f.close()
            else:
                for month in months:
                    ##Differentiates inputs by playoffs compared to regular season
                    print(month, year)
                    step1_html = Path('data', 'html', '{}_{}_{}_step1.html'.format(league, year, month), header=True)
                    url = 'https://www.basketball-reference.com/leagues/{}_{}_games-{}.html'.format(league, year, month)
                    page_url = requests.get(url).text.encode('utf-8')
                    str_html = page_url
                    with open(step1_html, 'wb') as f:
                        f.write(str_html)
                        f.close()

#Run function for both regular season and playoffs
step1_scrape('WNBA', 2019, 23, 'Regular')
step1_scrape('NBA', 2019, 71, 'Regular')
step1_scrape('ABA', 1976, 10, 'Regular')
step1_scrape('BAA', 1949, 4, 'Regular')
step1_scrape('NBA', 2019, 71, 'Playoffs')
step1_scrape('ABA', 1976, 10, 'Playoffs')
step1_scrape('BAA', 1949, 4, 'Playoffs')
