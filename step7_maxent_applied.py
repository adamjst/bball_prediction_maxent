import MaxEnt
from pathlib import Path
import numpy as np

# I don't totally understand the constraint syntax, but this works for solving the 2D case: reconstructing a 2D matrix with two 1D marginals
constraint = ((1,),(0,) )

def step7_maxent(division, year_start, years_back):
    #Create loop counter for years
    yrs = []
    yrs.append(year_start)
    for i in range(years_back):
        yrs.append(yrs[i] - 1)
    for yr in yrs:
        #path for csv based on division and year arguments
        step6_array = Path('{}_{}.csv'.format(division, yr), header=True)
        #write csv path (not used yet)
        step7_maxent = Path('{}_{}_step7.csv'.format(division, yr), header=True)

        #load csv and remove header team-names
        data = np.genfromtxt(step6_array, delimiter=',', skip_header=1)
        #convert csv to array and remove rowname team-names
        array = np.array(data, dtype=float)
        array = array[:, 1:]

        #run model and print results
        m5 = MaxEnt.model(array, constraint)
        m5._GIS()
        #
        print(m5.pdf_maxent)
        print(m5.marginals)
        # >>> m5.pdf_maxent
        # array([[0.24729975, 0.12499633, 0.12499633],
        #        [0.12499633, 0.06317873, 0.06317873],
        #        [0.12499633, 0.06317873, 0.06317873]])
        # m5.marginals
        # >>> m5.marginals
        # {(): 1.0, (0,): array([0.5 , 0.25, 0.25]), (1,): array([0.5 , 0.25, 0.25])}

step7_maxent("atlantic", 2017, 22)
step7_maxent("central", 2017, 22)
step7_maxent("midwest", 2004, 9)
step7_maxent("atlantic", 2017, 22)
step7_maxent("northwest", 2017, 12)
step7_maxent("pacific", 2017, 22)
step7_maxent("southeast", 2017, 12)
step7_maxent("southwest", 2017, 8)
