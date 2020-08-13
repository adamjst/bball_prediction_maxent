import MaxEnt

# I don't totally understand the constraint syntax, but this works for solving the 2D case: reconstructing a 2D matrix with two 1D marginals
constraint = ((1,),(0,) )


# this model is trivial (and maxent solution is identical)
d1 = ((1,0),  # define empirical distribution
      (0,0))
m1 = MaxEnt.model( d1, constraint ) # init model of distribution with knowledge of marginals
m1._GIS() # find maxent solution 

m1.pdf_maxent # report reconstructed 2D
m1.marginals # report reconstructed random variables
### Output:
# >>> m1.pdf_maxent
# array([[1., 0.],
#        [0., 0.]])
# m1.marginals
# >>> m1.marginals
# {(): 1, (0,): array([1, 0]), (1,): array([1, 0])}




# this model is less trivial but also recovered by maxent
d2 = ((0.5,0),
      (0.5,0))
m2 = MaxEnt.model( d2, constraint )
m2._GIS()

m2.pdf_maxent
m2.marginals
# >>> m2.pdf_maxent
# array([[0.5, 0. ],
#        [0.5, 0. ]])
# m2.marginals
# >>> m2.marginals
# {(): 1.0, (0,): array([0.5, 0.5]), (1,): array([1., 0.])}



# this model is trivial. dist is recovered by maxent
d3 = ((0.25,0.25),
      (0.25,0.25))
m3 = MaxEnt.model( d3, constraint )
m3._GIS()

m3.pdf_maxent
m3.marginals
# >>> m3.pdf_maxent
# array([[0.25, 0.25],
#        [0.25, 0.25]])
# m3.marginals
# >>> m3.marginals
# {(): 1.0, (0,): array([0.5, 0.5]), (1,): array([0.5, 0.5])}



# this model is the heart of maxent. Note that recovered dist is different
d4 = ((0.5,0.0),
      (0.0,0.5))
m4 = MaxEnt.model( d4, constraint )
m4._GIS()

m4.pdf_maxent
m4.marginals
# >>> m4.pdf_maxent
# array([[0.25, 0.25],
#        [0.25, 0.25]])
# m4.marginals
# >>> m4.marginals
# {(): 1.0, (0,): array([0.5, 0.5]), (1,): array([0.5, 0.5])}


# this model is the heart of maxent, extended
d5 = ((0.5,0.0,0.0),
      (0.0,0.25,0.0),
      (0.0,0.0,0.25))
m5 = MaxEnt.model( d5, constraint )
m5._GIS()

m5.pdf_maxent
m5.marginals
# >>> m5.pdf_maxent
# array([[0.24729975, 0.12499633, 0.12499633],
#        [0.12499633, 0.06317873, 0.06317873],
#        [0.12499633, 0.06317873, 0.06317873]])
# m5.marginals
# >>> m5.marginals
# {(): 1.0, (0,): array([0.5 , 0.25, 0.25]), (1,): array([0.5 , 0.25, 0.25])}
