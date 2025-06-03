import numpy as np
import pandas as pd
from itertools import combinations as combs

def check_pareto(scores):
    """
    Checks which scores in a dataframe of scores are pareto.
    A score is pareto if it is better than the other scores in at least one way.
    This function expands by a dimension to check one score against every other score at once.
    The "worse" part is all the solutions that equal or better than the given score in all metrics.
    The "equal" part is for strict equality. When they match, the solution is pareto.
    There might be a way to simplify the calculation but this works pretty well.
    """
    if scores.ndim == 1:
        return scores == scores.min(axis=0)
    elif scores.ndim == 2:
        worse = (scores.values[:,None,:]>=scores.values[None,:,:]).all(axis=2).sum(axis=1)
        equal = (scores.values[:,None,:]==scores.values[None,:,:]).all(axis=2).sum(axis=1)
        return worse == equal

def pareto_iter(labels):
    for i in range(len(labels)):
        for label in combs(labels,i+1):
            label = ''.join(label)
            yield label

format_label = lambda x: f'({x})' if len(x) > 1 else x
                    
def find_frontiers(scores,formatted=True):
    """
    This finds every pareto frontier a score is on. 
    A score is on a frontier if, among the frontier's metrics, it is pareto.
    That means no consideration of tiebreakers past the given metrics.
    """
    labels = list(pareto_iter(scores.columns))
    frontiers = pd.DataFrame(False,columns=labels,index=scores.index)
    for label in labels:
        label_ind = list(label)
        frontiers.loc[check_pareto(scores[label_ind]),label] = True
    if formatted:
        format_frontiers = lambda x: (' '.join([format_label(j) for j in frontiers.columns[x]]))
        frontiers = frontiers.apply(format_frontiers,axis=1)
    return frontiers

def absorb(row):
    """
    This finds categories from the frontiers a solution is on.
    It has to "absorb" frontiers to determine categories.
    For example, if a solution is on A, (AB), and (ABC), then its category is ABC.
    See the test script for how this works for different combinations of frontiers.
    
    Easily the weakest part of this code due to the set operations.
    """
    items = row.index[row.values]
    def supers(items,story=[]):
        if items.empty:
            return [story]
        stories = []
        handled = ~items.map(lambda x: set(x) > set(''.join(story))).to_numpy()
        while (~handled).any():
            item = items[~handled][0]
            matches = items.map(lambda x: (set(x) >= set(item)))
            handled[matches] = True
            new = ''.join(sorted(set(item).difference(''.join(story))))
            stories += supers(items[matches][1:],story + [new])
        return stories
    return pd.Series([tuple(cat) for cat in supers(items)])

def trim(cats):
    """
    Categories sometimes include too much detail. 
    If a score is the sole minimum in a category, it doesn't need to show
    each letter of its category. This function checks when this is possible 
    and trims the categories of these very good scores.
    """
    check = False
    cats = cats.copy()
    while not check:
        old_cats = cats.copy()
        trim = cats.map(lambda x: x[:-1],na_action='ignore')
        uniques = cats.stack().unique()
        valid = ~trim.isin(uniques)&trim.astype(bool)
        cats[valid] = trim[valid]
        check = ((cats==old_cats)|cats.isna()).all(None)
    dedupe = cats.apply(lambda x: list(set(x)),axis=1).apply(pd.Series)
    dedupe = dedupe.apply(lambda x: pd.Series(x.sort_values().values),axis=1)
    cats = dedupe.dropna(how='all',axis=1)
    return cats

def find_category(scores,metrics=None,formatted=True):
    """
    Finds a category based on the given order of metrics.
    If metrics is None, the column order is taken as given.
    """
    if metrics is None:
        metrics = scores.columns
    out = pd.Series(True,index=scores.index)
    pareto = ''
    for metric in metrics:
        pareto += metric
        paretos = check_pareto(scores[list(pareto)])
        out.loc[out&~paretos] = False
    if formatted:
        out = out.replace([False,True],['',''.join(format_label(i) for i in metrics)])
    return out

def find_flagged_category(scores,flag_score,flags,metrics=None,formatted=True):
    """
    Finds a category based on the given order of metrics.
    If metrics is None, the column order is taken as given.
    """
    out = pd.Series('',index=scores.index,dtype=str)
    for ind,flag in enumerate(flags):
        inds = flag_score<=ind
        temp = pd.Series('',index=scores.index,dtype=str)
        temp.loc[inds] = find_category(scores.loc[inds])
        temp[temp!=''] = flag + temp[temp!='']
        out.loc[out==''] += temp[out=='']
        
    return out.fillna('')

    
format_cats = lambda x: ','.join([''.join(format_label(i) for i in j) for j in x if not pd.isna(j)])

def find_categories(scores,pareto_only=False,trimmed=True,formatted=True):
    """
    This is the big function that combines all the prior functions.
    Follow what they do to know what this does.
    """
    if pareto_only: 
        scores = scores.loc[check_pareto(scores)]
    frontiers = find_frontiers(scores,formatted=False)
    cats = frontiers.apply(absorb,axis=1)
    if trimmed: 
        cats = trim(cats)
    if formatted:
        fcats = cats.agg(format_cats,axis=1)
        return fcats
    else:
        return cats
    
def prune_flag_categories(higher,lower):
    """
    Checks between two categories when a flag is on or off to determine if
    the category only occurs in the less restrictive flag.
    """
    higher,lower = higher.dropna(),lower.dropna()
    keep = []
    for catA in higher:
        keepq = True
        for catB in lower:
            if len(catA) <= len(catB) and all([j in i for i,j in zip(catA,catB)]):
                keepq = False
                break
        keep.append(keepq)
    return higher[keep]

format_flag_cats = lambda x,flag: ','.join([flag + ''.join(format_label(i) for i in j) for j in x if not pd.isna(j)])

def find_flagged_categories(scores,flag_score,flags,trimmed=True):
    """
    Flags applied to scores might put them in different categories.
    This function calculates categories with different flag levels and
    only returns categories where less restrictive flags allow for a better category.
    
    It's frankly probably not the best way to do this but it works.
    """
    cats = []
    for ind,flag in enumerate(flags):
        inds = flag_score<=ind
        temp = find_categories(scores.loc[inds],trimmed=False,formatted=False)
        out = pd.DataFrame(columns = temp.columns, index=scores.index)
        out.iloc[:,0] = [tuple() for i in range(out.shape[0])]
        out.loc[temp.index] = temp
        for jnd in range(ind):
            out = out.apply(lambda x: prune_flag_categories(x,cats[jnd].loc[x.name]),axis=1)
        cats.append(out)

    for ind,flag in enumerate(flags):
        if trimmed and not cats[ind].empty:
            cats[ind] = trim(cats[ind])        
        cats[ind] = cats[ind].agg(lambda x: format_flag_cats(x,flag),axis=1)
        
    return pd.concat(cats,axis=1).agg(lambda x: ','.join([i for i in x if i]),axis=1)
    
def generate_toy_data(N,m,r):
    """
    Small function to test out paretos and speed.
    """
    metrics = list('ABCDEFGHIJKLMNOPQRSTUVWXYZ')[:m]
    rng = np.random.default_rng(10)
    scores = rng.integers(5,m*r,(N,m))
    scores = scores[scores.sum(axis=1) > r*m + rng.integers(-r,r+1,N)]
    scores = pd.DataFrame(scores,columns=metrics)
    return scores,metrics

if __name__ == '__main__':
    N = 100
    m = 3
    r = 50
    
    scores,metrics = generate_toy_data(N,m,r)
    # categories = find_categories(scores)
    out = find_category(scores,['A','BC'])