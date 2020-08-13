import numpy as np
import itertools
import matplotlib.pyplot as plt
import tqdm

class key:
    def __init__(self,obj_tuple,state_tuple):
        self.obj_tuple = obj_tuple
        self.state_tuple = state_tuple
        self.order = len(obj_tuple)

    def __getitem__(self,idx):
        if idx == 0:
            return self.obj_tuple
        else:
            return self.state_tuple

    def __len__(self):
        return self.order

    def __repr__(self):
        return str((self.obj_tuple,self.state_tuple))

class keychain:
    def __init__(self,num_objects,num_states):
        self.num_objects = num_objects
        self.num_states = num_states
        self.keys = []
        self.constraint_obj = []

    def add_keys(self,constraint_marginal):
        self.constraint_obj.append(constraint_marginal)
        for state in itr_states(len(constraint_marginal),self.num_states):
            self.keys.append(key(constraint_marginal,state))

    def prune_chain(self,constraint_marginal):
        chain_length = len(self)
        new_chain_length = 0
        while chain_length != new_chain_length:
            chain_length = len(self)
            order = len(constraint_marginal)
            these_keys = self.keys
            if len(constraint_marginal) > 0:
                for key in these_keys:
                    #prunelog = 'Checking key: '+str(key)+'\n'
                    if len(key) > order:
                        #prunelog = prunelog+' order: '+str(len(key))+'\n'
                        #prunelog = prunelog + ' is '+str(set(list(constraint_marginal)))+' subset of '+ str(set(list(key[0])))+'?'+'\n'
                        if set(list(constraint_marginal)).issubset(set(list(key[0]))):
                            #prunelog = prunelog + ' YES\n'
                            #prunelog = prunelog + ' '+str(constraint_marginal)+': '+str(list(map(lambda x:key[1][key[0].index(x)],constraint_marginal)))+'\n'
                            if np.sum(list(map(lambda x:key[1][key[0].index(x)],constraint_marginal))) == 0:
                                #print(prunelog)
                                self.keys.pop(self.keys.index(key))
            else:
                #print('The empty key: ((),())')
                for key in these_keys:
                    if np.sum(key[1])==0 and len(key)!=0:
                        self.keys.pop(self.keys.index(key))
            new_chain_length = len(self)

    def __getitem__(self,idx):
        return self.keys[idx]

    def __len__(self):
        return len(self.keys)

    def __repr__(self):
        print('\n')
        for key in self.keys:
            print(key)
        return '-----------------'+str(len(self.keys))+' keys'

class model:
    def __init__(self,pdf_empirical,constraint_marginals,tol = 10**-4):
        print('-------------Initializing MaxEnt model----------------')
        self.tol = tol
        self.pdf_empirical = pdf_empirical
        self.num_objects = len(np.shape(pdf_empirical))
        self.num_states = np.shape(pdf_empirical)[0]
        self.groups = []

        #create all the marginals of the empirical distribution
        print('Constructing marginal structure...')
        self.marginals = {}
        for order in tqdm.tqdm(range(self.num_objects)):
            for group in itr_obj_combs(self.num_objects,order):
                self.marginals[group] = marginal(pdf_empirical,group)
                self.groups.append(group)

        print('Adding constraints to keychain...')
        self.alphas = keychain(self.num_objects,self.num_states)
        for contraint in tqdm.tqdm(constraint_marginals):
            self.alphas.add_keys(contraint)
        self.alphas.prune_chain(constraint_marginals)

        self._build_h_norm()
        print('--------------------Ready to GIS----------------------')

    def prune_chain(self):
        print('Pruning keychain')
        for constraint in constraint_marginals:
            self.alphas.prune_chain(constraint)
        for constraint in constraint_marginals:
            self.alphas.prune_chain(constraint)

    def _seed_mu(self):
        print('Seeding model parameters...')
        self.mu = {}
        for alpha in self.alphas:
            self.mu[alpha] = 1


    def _GIS(self):
        print('----------------------------Generalized Iterative Scaling-----')
        self._seed_mu()
        #pdf = self.pdf_empirical
        #for state in itr_states(self.num_objects,self.num_states):
        #    pdf[state] = pdf[state]*(1+.4*np.random.random()-.2)
        pdf = np.ones(np.shape(self.pdf_empirical))
        pdf = pdf/np.sum(pdf)
        mu_old = self.mu
        while True:
            mu_new = {}
            #for state in itr_states(self.num_objects,self.num_states):
            for alpha in self.alphas:
                #pdf[state] = pdf[state]*np.prod([(self.marginals[alpha[0]][alpha[1]]/np.sum([pdf[s]*self._h(alpha,s)
                #                                    for s in itr_states(self.num_objects,self.num_states)]))**self._h(alpha,state) for alpha in self.alphas])
                constraint      = self.marginals[alpha[0]][alpha[1]]
                constraint_aprx = np.sum([pdf[state]*self._h(alpha,state)
                                            for state
                                            in itr_states(
                                                self.num_objects,self.num_states
                                            )])
                #print(str(alpha) + ': ' + str(constraint) +', '+str(constraint_aprx))
                mu_new[alpha] = (constraint/constraint_aprx)*mu_old[alpha]
            self.mu = mu_new
            pdf_old = pdf
            pdf = self._make_pdf()
            #for alpha in self.alphas: print(str(alpha) + ': '+str(mu_new[alpha]))
            #if self._convergent(mu_new,mu_old):
            if self._convergent_p(pdf_old/np.sum(pdf_old),pdf/np.sum(pdf)):
                break
            else:
                for alpha in self.alphas:mu_old[alpha] = mu_new[alpha]
        self.pdf_maxent = pdf / np.sum( pdf )

    def _make_pdf(self):
        print('Constructing pdf from model parameters...',end='\r')
        pdf = np.ones(np.shape(self.pdf_empirical))
        for state in itr_states(self.num_objects,self.num_states):
            pdf[state] = np.prod([self.mu[alpha]**self._ht(alpha,state) for alpha in self.alphas])
        return pdf

    def _h(self,alpha,state):
        if len(alpha) == 0:
            return 1
        elif tuple(np.array(state)[np.array(alpha[0])])==alpha[1]:
            return 1
        else:
            return 0

    def _ht(self,alpha,state):
        return self._h(alpha,state)/self._hnorm[state]

    def _convergent(self,mu_old,mu_new):
        meandiff = np.mean([np.abs(mu_new[alpha]/mu_old[alpha]-1) for alpha in self.alphas])
        print('mean diff: '+str(meandiff),end = '\r')
        if meandiff < self.tol or np.isnan(meandiff):
            return True
        else:
            return False

    def _convergent_p(self,p1,p2):
        diff = KL_divergence(p2,p1)
        print(' KL divergence: '+str(diff),end = '\r')
        if diff < self.tol or np.isnan(diff):
            return True
        else:
            return False

    def _build_h_norm(self):
        print('normalizing projectors...')
        hnorm = {}
        for state in itr_states(self.num_objects,self.num_states):
            hnorm[state] = np.sum(self._h(alpha,state) for alpha
                                in self.alphas)
        self._hnorm = hnorm


#----------------------------------------------------------------------ITERATORS
def itr_states(num_objects,num_states):
    #An iterator over all the joint states of the objects
    return itertools.product(range(num_states),repeat = num_objects)

def itr_obj_combs(num_objects,group_size):
    #An iterator over all combinations of given size taken from the set of
    #all objects. Objects are in increasing order
    if type(num_objects) == int:
        return itertools.combinations(range(num_objects),r = group_size)
    elif type(num_objects) == tuple:
        return itertools.combinations(group, r = group_size)

#----------------------------------------------------------------------FUNCTIONS
def marginal(pdf,idx_tuple):
    #calculates the marginal of a joint pdf where the free indices are given
    #in idx_tuple.
    dimension = len(np.shape(pdf))
    marginalization_axes = (filter(lambda x: not(x in set(idx_tuple)),
                            range(dimension)))
    return np.sum(pdf,axis = tuple(marginalization_axes))

def KL_divergence(p,q):
    return np.sum(p*np.log(p/q))
