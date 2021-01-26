#!/usr/bin/env python3

import argparse
import subprocess
from itertools import islice


def parse_args():
    '''
    '''

    parser = argparse.ArgumentParser()
    parser.add_argument('proteins', type=str)
    parser.add_argument('--outdir', type=str)        
    parser.add_argument('--batch', type=int, default=1000)
    args = parser.parse_args()

    return args

def chunk(it, size=2):
    it = iter(it)
    return iter(lambda: tuple(islice(it, size)), ())

def main():
    '''
    '''

    args = parse_args()

    with open(args.proteins) as handle:
        handle = map(lambda x: x.split('\t')[0], handle)
        for i, accessions in enumerate(chunk(handle, args.batch)):
            query = ' '.join(accessions)
            subprocess.run(['make', 'genbank', f'SUFFIX=_{i+1}', f'OUTDIR={args.outdir}', f'QUERY="{query}"'])
            print(f'{(1+i)*args.batch:,} accessions processed', end='\r')

if __name__ == '__main__':
    main()
