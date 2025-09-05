import numpy as np
import pandas as pd
from itertools import combinations as combs
import sqlite3

order = 'GCAITLN'
fmap = {'G':0,'C':1,'A':2,'I':3,'T':4}
bmap = {0:'G',1:'C',2:'A',3:'I',4:'T'}

def pareto_iter(labels):
    for i in range(len(labels)+1):
        for label in combs(labels,i):
            yield ''.join(label)

format_label = lambda x: f'({x})' if len(x) > 1 else x
format_frontiers = lambda x: (' '.join([format_label(j) for j in x]))
format_cats = lambda x: ','.join([''.join(format_label(i) for i in j) for j in x])

def map_to_set(metrics,fmap=fmap):
    out = np.array([set(fmap[i] for i in list(j)) for j in metrics])
    return out

def map_to_string(metrics,bmap=bmap,order=order):
    out = [''.join(sorted((bmap[i] for i in j),key=lambda x: order.index(x))) for j in metrics]
    return out

def is_pareto(scores):
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
        worse = (scores.values[:,None]>=scores.values).all(axis=2).sum(axis=1)
        equal = (scores.values[:,None]==scores.values).all(axis=2).sum(axis=1)
        return worse == equal

def find_frontiers(scores,formatted=True):
    """.
    This finds every pareto frontier a score is on. 
    A score is on a frontier if, among the frontier's metrics, it is pareto.
    That means no consideration of tiebreakers past the given metrics.
    """
    labels = list(pareto_iter(scores.columns))
    frontiers = pd.DataFrame(columns=labels,index=scores.index,dtype=bool)
    for label in labels:
        frontiers[label] = is_pareto(scores[list(label)])
    a,b = frontiers.values.nonzero()
    split = np.unique(a,return_counts=True)[1].cumsum()
    frontiers = np.array_split(frontiers.columns.values[b],split[:-1])
    frontiers = pd.Series(frontiers,scores.index)
    if formatted:
        frontiers = frontiers.apply(format_frontiers)
    return frontiers
    
def traverse(sets,paths):
    stack = [(0, [])]
    out = []
    while stack:
        current,path = stack.pop()
        if paths[current].size == 0:
            out.append(np.diff(path,prepend=set()))
        else:
            for child in paths[current]:
                next_index = (sets==child).nonzero()[0][0]
                stack.append((next_index, path + [child]))
    return out

def categorize(metrics,fmap=fmap,bmap=bmap):
    N = len(metrics)
    sets = map_to_set(metrics)
    sub = sets > sets[:,None]
    out = []
    for i in range(N):
        immediate = sets[sub[i]][~sub[sub[i]][:,sub[i]].any(axis=0)]
        out.append(immediate)
    out = traverse(sets,out)
    out = [map_to_string(i) for i in out]
    out = format_cats(out)
    return out

if __name__ == '__main__':
    con = sqlite3.connect(r'leaderboard.db')
    db = pd.read_sql('SELECT * FROM test',con,index_col='index')
    db = db.loc[db.PUZZLE=='STABILIZED_WATER']
    db = db.loc[db['OVERLAP']==0]
    # db = db.loc[db['TRACKLESS']==1]
    db['NTRACKLESS'] = 1-db['TRACKLESS']
    db = db.loc[db['LOOPING']==1]
    # db['NLOOPING'] = 1-db['LOOPING']
    m = ['COST','CYCLES','AREA','INSTRUCTIONS','NTRACKLESS']
    df = db[m]
    db = db[is_pareto(df)]
    df = df[is_pareto(df)]
    df.columns = list('GCAIT')

    fr = find_frontiers(df,formatted=False)
    cats = fr.apply(categorize)