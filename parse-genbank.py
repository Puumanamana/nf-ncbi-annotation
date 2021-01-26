#!/usr/bin/env python

from pathlib import Path
import argparse

import pandas as pd
import numpy as np
from Bio import SeqIO

def parse_args():
    '''
    '''

    parser = argparse.ArgumentParser()
    parser.add_argument('gbk', type=str)
    args = parser.parse_args()

    return args

def main():
    '''
    '''

    args = parse_args()

    parser = SeqIO.parse(args.gbk, 'gb')
    data = []

    for entry in parser:
        for f in entry.features:
            product = f.qualifiers.get('product')
            if product is not None and ' '.join(product) != 'hypothetical protein':
                product = ' '.join(product)
                data.append([entry.id, f.type, f'{len(f):,}', product])

    
    data = pd.DataFrame(data, columns=['contig', 'type', 'length', 'name'])
    
    prefix = Path(Path(args.gbk).parent, Path(args.gbk).stem)
    data.to_csv(f'{prefix}_summary.csv', index=False)
                    
if __name__ == '__main__':
    main()
