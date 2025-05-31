import pandas as pd
import requests
import os,subprocess
from pathlib import Path
import re
from zipfile import ZipFile
import pareto

# The only input is the month!
month = '2502'
filename = f'TIS100M-{month}'

table = pd.read_csv(f'sheets/from_tally/{filename}.csv')
puzz = Path(f'custom/{filename}.lua')
sols = Path(f'save/TIS100M/{month}/raw')

try:
    os.mkdir(f'save/TIS100M/{month}')
    os.mkdir(f'save/TIS100M/{month}/raw')
    os.mkdir(f'save/TIS100M/{month}/fin')
except:
    pass

# %% load_solutions
# This cell pulls in the solutions from tally. You can't run this.
for ind,row in table.iterrows():
    person = row["What is the submitter's name?"]
    loc = row["Provide your solution here:"]
    tag = row["Submission ID"]
    ext = re.search(r'private\/.*?\.(\w\w\w)\?',loc).group(1)
    response = requests.get(loc)
    sol = Path(f'{sols}/SPEC{filename}.{person}_{tag}.{ext}')
    if ext == 'txt':    
        sol.write_text(response.content.decode('utf-8'),newline='\n')
    elif ext == 'zip':
        sol.write_bytes(response.content)
        zipped = ZipFile(sol)
        for i,file in enumerate(zipped.namelist()):
            sol = Path(f'{sols}/SPEC{filename}.{person}_{tag}.{i}.txt')
            sol.write_text(zipped.open(file).read().decode('utf-8'),newline='\n')
        zipped.close()

# %% run_solutions
# This cell runs the simulation for each solution.
names = []
scores = []
for sol in sols.iterdir():
    print(sol.name)
    if sol.name[-3:] == 'zip': 
        sol.unlink()
        continue
    cmd = subprocess.run(f'TIS-100-CXX -L {puzz} {sol} --seeds 1..10000 --limit 1000000 -j 0',capture_output=True)
    out = cmd.stdout.decode('utf-8')
    error = cmd.stderr.decode('utf-8')
    if error: print(error)
    print(out)
    print()
    score = out.split()[3].split('/')
    if len(score) == 3: score.append('0')
    if score[-1] == 'c': score[-1] = '1'
    if score[-1] == 'h': score[-1] = '2'
    scores.append(score)
    name = '_'.join(sol.name.split('.')[1].split('_')[:-1])
    names.append(name)

# %% calculate_process_nodes
# This cell calculates Process nodes, a metric to ignore simple nodes.
dirs = set(('UP','DOWN','LEFT','RIGHT'))
p_scores = []
for sol in sols.iterdir():
    try:
        with open(sol) as f:
            nodes = [[j for j in i.splitlines()[1:] if j and not j.startswith('#')] for i in f.read().split('@')][1:]
            nodes = [node for node in nodes if len(node) > 0]
            
        process_nodes = len(nodes)
        for node in nodes:
            if len(node) == 1:
                line = node[0].split(':')[-1].split(' ')
                if line[0] == 'MOV' and dirs.issuperset(line[1:]):
                    process_nodes -= 1
        p_scores.append(process_nodes)
                
    except:
        print(sol.name)

# %% generate_spreadsheet
# This cell takes the scores from the simulation and puts it into a csv.
initial_cols = ['Name','C','N','P','I','O']
N_cols = ['C','N','I']
P_cols = ['C','P','I']

scores_df = pd.DataFrame(columns=initial_cols)
scores_df['Name'] = names
scores_df[N_cols+['O']] = scores
scores_df[N_cols+['O']] = scores_df[N_cols+['O']].astype(int)
scores_df['P'] = p_scores

scores_df['Pareto? (N)'] = pareto.check_pareto(scores_df[N_cols+['O']])
scores_df['Pareto? (N)'] = scores_df['Pareto? (N)'].replace([False,True],['','Yes'])
scores_df['Categories Won (N)'] = pareto.find_flagged_categories(scores_df[N_cols],scores_df['O'],{'':0,'c':1,'h':2})

scores_df['Pareto? (P)'] = pareto.check_pareto(scores_df[P_cols+['O']])
scores_df['Pareto? (P)'] = scores_df['Pareto? (P)'].replace([False,True],['','Yes'])
scores_df['Categories Won (P)'] = pareto.find_flagged_categories(scores_df[P_cols],scores_df['O'],{'':0,'c':1,'h':2})

scores_df['O'] = scores_df['O'].replace([0,1,2],['','Yes','Hard'])
scores_df = scores_df.rename(columns={'O':'Cheated?'})

scores_df.to_csv(f'sheets/{filename}_fin.csv',index=False)
