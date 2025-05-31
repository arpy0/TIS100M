import pareto
import pandas as pd
import itertools

# """UNIT TESTS"""
# I calculated the three_metric version by hand
# The four_metric version is just the output of the current version of code
# so don't trust it completely
    
cols = list(pareto.pareto_iter('ABC'))
val = [i for i in itertools.product([False,True],repeat=len(cols))]
test = pd.DataFrame(val,index=range(len(val)),columns=cols)
cats = test.apply(pareto.absorb,axis=1).agg(pareto.format_cats,axis=1)
comp = pd.read_csv('tests/three_metrics.csv',index_col=0)['0'].fillna('')
print((cats == comp).all())

# %%
cols = list(pareto.pareto_iter('ABCD'))
val = [i for i in itertools.product([False,True],repeat=len(cols))]
test = pd.DataFrame(val,index=range(len(val)),columns=cols)
cats = test.apply(pareto.absorb,axis=1).agg(pareto.format_cats,axis=1)
comp = pd.read_csv('tests/four_metrics.csv',index_col=0)['0'].fillna('')
print((cats == comp).all())
