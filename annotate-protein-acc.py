#!/usr/bin/env python3

import argparse
from pathlib import Path

import pandas as pd
import numpy as np
from Bio import SeqIO


def parse_args():
    '''
    '''

    parser = argparse.ArgumentParser()
    parser.add_argument('--gbk', type=str)
    parser.add_argument('--matches', type=str)    
    args = parser.parse_args()

    return args


def find_pos(s):
    chars = list(s)
    pos = len(chars)
    count = 0
    
    while True:
        char = chars.pop()
        
        if char == ']':
            count += 1
        if char == '[':
            count -= 1
        pos -= 1

        if count == 0:
            return pos

def parse_gbk(filename):
    data = []
    
    for entry in SeqIO.parse(filename, 'genbank'):
        descr = entry.description
        split_pos = find_pos(descr)

        if split_pos is None:
            (descr, species) = (descr, None)
        else:
            (descr, species) = (descr[: split_pos-1], descr[split_pos+1:-1])                        
        
        data.append([entry.id, descr, species])

    return data

def main():
    '''
    '''

    args = parse_args()

    gbk = pd.DataFrame(parse_gbk(args.gbk),
                       columns=['accession', 'descr', 'species'])

    matches = pd.read_csv(args.matches, sep='\t', header=None)
    matches.columns=['accession', 'count']
    matches = matches.merge(gbk, on='accession', how='left')

    args.matches = Path(args.matches)
    radical = Path(args.matches.parent, args.matches.stem)
    matches.set_index('accession').to_csv(f'{radical}-with-descr.tsv', sep='\t')

if __name__ == '__main__':
    main()
