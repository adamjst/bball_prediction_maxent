import MaxEnt
from pathlib import Path
import pandas as pd
import numpy as np

# I don't totally understand the constraint syntax, but this works for solving the 2D case: reconstructing a 2D matrix with two 1D marginals
constraint = ((1,),(0,) )
#print(constraint)


# create empty data frames for appending
div_maxent_list = []
div_marginals_list = []

def step7_maxent(division, year_start, years_back):
    #Create loop counter for years
    yrs = []
    yrs.append(year_start)
    for i in range(years_back):
        yrs.append(yrs[i] - 1)
    for yr in yrs:
        #path for csv based on division and year arguments
        step6_array = Path('step7_divisions', '{}_{}.csv'.format(division, yr), header=True)
        ##EXAMPLE: Atlantic Division 2017
        #Team, Boston, Brooklyn, New York, Philadelphia, Toronto
        #Boston 0, 1, 0.75, 0.75, 0.5
        #Brooklyn 0, 0, 0, 0.25, 0
        #New York 0.25, 1, 0, 0, 0.25
        #Philadelphia 0.25, 0.75, 1, 0, 0.25
        #Toronto 0.5, 1, 0.75, 0.75, 0

        # write csv path for maxent
        step7_maxent = Path('{}_step7_maxent.csv'.format(division, header=True))
        # write csv path for marginals
        step7_marginals = Path('{}_step7_marginals.csv'.format(division, header=True))
        #load csv and remove header team-names
        data = np.genfromtxt(step6_array, delimiter=',', skip_header=1)
        #convert csv to array and remove rowname team-names
        array = np.array(data, dtype=float)
        #print(array)
        array = array[:, 1:]
        #print(array)
        #[[0.   1.   0.75 0.75 0.5]
        #[0.   0.   0.   0.25 0.]
        #[0.25 1.   0.   0.   0.25]
        #[0.25 0.75 1.   0.   0.25]
        #[0.5  1.   0.75 0.75 0.  ]]

        #run model
        m5 = MaxEnt.model(array, constraint)
        m5._GIS()

        #Convert to df and print results
        div_maxent_df = pd.DataFrame(m5.pdf_maxent)
        print(div_maxent_df)
        div_marginals_df = pd.DataFrame(m5.marginals)
        print(div_marginals_df)

        #add season year
        div_maxent_df['yr'] = yr
        div_marginals_df['yr'] = yr

        #append to list of all seasons
        div_maxent_list.append(div_maxent_df)
        div_marginals_list.append(div_marginals_df)

    #concatenate all lists together
    div_maxent_df = pd.concat(div_maxent_list, sort=False)
    div_marginals_df = pd.concat(div_marginals_list, sort=False)

    #write to csv
    #div_maxent_df.to_csv((step7_maxent), header=True, line_terminator='\n')
    #div_marginals_df.to_csv((step7_marginals), header=True, line_terminator='\n')


#There have been various realignments over the years. Data goes back to 1995
step7_maxent("atlantic", 2017, 2)
# step7_maxent("central", 2017, 22)
# step7_maxent("midwest", 2004, 9)
# step7_maxent("atlantic", 2017, 22)
# step7_maxent("northwest", 2017, 12)
# step7_maxent("pacific", 2017, 22)
# step7_maxent("southeast", 2017, 12)
# step7_maxent("southwest", 2017, 8)

