#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 14:04:30 2023

@author: hong
"""

import FinanceDataReader as fdr
import pandas as pd
from matplotlib import pyplot as plt

#fdr.DataReader("ks11")["Close"].plot()

KOSPI = fdr.DataReader("ks11").reset_index()
KOSPI = KOSPI.dropna()
KOSPI.to_csv("KOSPI.csv", index = False)

"""
git hub code

cd desktop/r\ project/r-quant
git add .
git commit -m "upload"
git push
"""