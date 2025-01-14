## Finding useful data in the noise
Much real-world data consists of mostly noise, and only a small amount of information. The hammnn algorithm can be helpful in extracting the useful information.

An example is genomics data. The prostata dataset consists of genomic
microarray data from 102 subjects. Fifty of the 102 subjects were normal,
while the other 52 had a prostate tumor. For each case, there 
are 12534 data points, of which one is the class attribute. Can this
mass of data be used to predict whether a person has a tumor or is normal?


```v
v run hamnn.v rank -w -s datasets/prostata.tab 
```   
```
Attributes Sorted by Rank Value, including missing values
For datafile: datasets/prostata.tab, binning range [2, 16]
 Index  Name                         Type   Rank Value   Bins
 _____  ___________________________  ____   __________   ____
 10426  NELL2                        C           80.15      9
  6117  HPN                          C           78.15      7
  9104  PTGDS                        C           74.62      6
  6394  RBP1                         C           74.23     13
 10070  CALM1_4                      C           72.85     13
  8897  HSPD1                        C           72.77     13
  4297  TRGC2                        C           70.85     11 
	...
	...
	...
  2048  MR1_3                        C            8.77     16
  4056  CPA2                         C            8.54     13
  5692  SEDLP                        C            8.08     14
  4163  PIP                          C            2.00      2
  4852  SEMG2                        C            2.00      2
  7529  SEMG1                        C            2.00      2
```

Accumulated experience with the algorithm suggests that using a fixed number
of bins often gives good results. 
```v
v run hamnn.v rank -w -s -b 6 datasets/prostata.tab
```
```
Attributes Sorted by Rank Value, including missing values
For datafile: datasets/prostata.tab, binning range [6]
 Index  Name                         Type   Rank Value   Bins
 _____  ___________________________  ____   __________   ____
  9104  PTGDS                        C           74.62      6
  6117  HPN                          C           74.31      6
  8897  HSPD1                        C           71.08      6
 10426  NELL2                        C           66.15      6
  4297  TRGC2                        C           65.23      6
  8966  LMO3                         C           64.54      6
 12085  GSTM1_2                      C           64.08      6
  6394  RBP1                         C           62.08      6
  5498  HSD11B1                      C           61.08      6
   137  ANXA2                        C           60.85      6
   ...
   ...
   ...
  9490  PDCD4                        C            2.00      6
  2495  CPN1                         C            2.00      6
   579  PMCH                         C            2.00      6
  5692  SEDLP                        C            2.00      6
  5580  PRR4                         C            1.92      6
```

We can verify this by comparing cross-validation results over a range of 
attribute numbers, either with a fixed number of bins, or with bin number
which is optimized over a range.

Here are the results for exploring over a range of attributes from 1 to 20, 
and a binning range from 2 to 12:
```v
v -gc boehm run hamnn.v explore -c -e -g -w -b 2,12 -a 1,20 datasets/prostata.tab
```
Note the flags: -c calls for parallel processing, using all available CPU cores
on you machine; -e for expanded output to the console; -g results in graphical
plots of the results as ROC curves.
```
A correct classification to "normal" is a True Positive (TP);
A correct classification to "tumor" is a True Negative (TN).
Attributes    Bins     TP    FP    TN    FN Sensitivity Specificity   PPV   NPV  Balanced Accuracy
         1  2 - 2      49     1    37    15       0.766       0.974 0.980 0.712              0.870
         1  2 - 3      48     2    37    15       0.762       0.949 0.960 0.712              0.855
         1  2 - 4      46     4    30    22       0.676       0.882 0.920 0.577              0.779
         1  2 - 5      43     7    43     9       0.827       0.860 0.860 0.827              0.843
         1  2 - 6      35    15    40    12       0.745       0.727 0.700 0.769              0.736
         1  2 - 7      41     9    49     3       0.932       0.845 0.820 0.942              0.888
         1  2 - 8      39    11    49     3       0.929       0.817 0.780 0.942              0.873
         1  2 - 9      40    10    50     2       0.952       0.833 0.800 0.962              0.893
         1  2 - 10     39    11    50     2       0.951       0.820 0.780 0.962              0.885
         1  2 - 11     38    12    50     2       0.950       0.806 0.760 0.962              0.878
         1  2 - 12     38    12    50     2       0.950       0.806 0.760 0.962              0.878
         2  2 - 2      44     6    38    14       0.759       0.864 0.880 0.731              0.811
         2  2 - 3      46     4    38    14       0.767       0.905 0.920 0.731              0.836
         2  2 - 4      46     4    41    11       0.807       0.911 0.920 0.788              0.859
         2  2 - 5      46     4    37    15       0.754       0.902 0.920 0.712              0.828
         2  2 - 6      44     6    42    10       0.815       0.875 0.880 0.808              0.845
         2  2 - 7      46     4    45     7       0.868       0.918 0.920 0.865              0.893
         2  2 - 8      45     5    45     7       0.865       0.900 0.900 0.865              0.883
         2  2 - 9      45     5    49     3       0.938       0.907 0.900 0.942              0.922
         2  2 - 10     45     5    49     3       0.938       0.907 0.900 0.942              0.922
         2  2 - 11     45     5    49     3       0.938       0.907 0.900 0.942              0.922
         2  2 - 12     45     5    49     3       0.938       0.907 0.900 0.942              0.922
         3  2 - 2      47     3    39    13       0.783       0.929 0.940 0.750              0.856
         3  2 - 3      47     3    37    15       0.758       0.925 0.940 0.712              0.842
         3  2 - 4      47     3    41    11       0.810       0.932 0.940 0.788              0.871
         3  2 - 5      47     3    46     6       0.887       0.939 0.940 0.885              0.913
         3  2 - 6      49     1    45     7       0.875       0.978 0.980 0.865              0.927
         3  2 - 7      48     2    47     5       0.906       0.959 0.960 0.904              0.932
         3  2 - 8      47     3    49     3       0.940       0.942 0.940 0.942              0.941
         3  2 - 9      47     3    49     3       0.940       0.942 0.940 0.942              0.941
         3  2 - 10     47     3    49     3       0.940       0.942 0.940 0.942              0.941
         3  2 - 11     47     3    49     3       0.940       0.942 0.940 0.942              0.941
         3  2 - 12     47     3    48     4       0.922       0.941 0.940 0.923              0.931
         4  2 - 2      47     3    40    12       0.797       0.930 0.940 0.769              0.863
         4  2 - 3      39    11    40    12       0.765       0.784 0.780 0.769              0.775
         4  2 - 4      48     2    42    10       0.828       0.955 0.960 0.808              0.891
         4  2 - 5      45     5    42    10       0.818       0.894 0.900 0.808              0.856
         4  2 - 6      48     2    45     7       0.873       0.957 0.960 0.865              0.915
         4  2 - 7      47     3    47     5       0.904       0.940 0.940 0.904              0.922
         4  2 - 8      47     3    47     5       0.904       0.940 0.940 0.904              0.922
         4  2 - 9      47     3    48     4       0.922       0.941 0.940 0.923              0.931
         4  2 - 10     47     3    48     4       0.922       0.941 0.940 0.923              0.931
         4  2 - 11     48     2    48     4       0.923       0.960 0.960 0.923              0.942
         4  2 - 12     48     2    48     4       0.923       0.960 0.960 0.923              0.942
         5  2 - 2      47     3    43     9       0.839       0.935 0.940 0.827              0.887
         5  2 - 3      40    10    41    11       0.784       0.804 0.800 0.788              0.794
         5  2 - 4      44     6    42    10       0.815       0.875 0.880 0.808              0.845
         5  2 - 5      45     5    41    11       0.804       0.891 0.900 0.788              0.847
         5  2 - 6      47     3    45     7       0.870       0.938 0.940 0.865              0.904
         5  2 - 7      48     2    47     5       0.906       0.959 0.960 0.904              0.932
         5  2 - 8      48     2    47     5       0.906       0.959 0.960 0.904              0.932
         5  2 - 9      47     3    46     6       0.887       0.939 0.940 0.885              0.913
         5  2 - 10     47     3    46     6       0.887       0.939 0.940 0.885              0.913
         5  2 - 11     46     4    47     5       0.902       0.922 0.920 0.904              0.912
         5  2 - 12     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         6  2 - 2      48     2    44     8       0.857       0.957 0.960 0.846              0.907
         6  2 - 3      41     9    43     9       0.820       0.827 0.820 0.827              0.823
         6  2 - 4      47     3    44     8       0.855       0.936 0.940 0.846              0.895
         6  2 - 5      47     3    39    13       0.783       0.929 0.940 0.750              0.856
         6  2 - 6      47     3    43     9       0.839       0.935 0.940 0.827              0.887
         6  2 - 7      44     6    47     5       0.898       0.887 0.880 0.904              0.892
         6  2 - 8      44     6    47     5       0.898       0.887 0.880 0.904              0.892
         6  2 - 9      46     4    46     6       0.885       0.920 0.920 0.885              0.902
         6  2 - 10     46     4    46     6       0.885       0.920 0.920 0.885              0.902
         6  2 - 11     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         6  2 - 12     42     8    47     5       0.894       0.855 0.840 0.904              0.874
         7  2 - 2      48     2    43     9       0.842       0.956 0.960 0.827              0.899
         7  2 - 3      42     8    43     9       0.824       0.843 0.840 0.827              0.833
         7  2 - 4      45     5    44     8       0.849       0.898 0.900 0.846              0.874
         7  2 - 5      45     5    41    11       0.804       0.891 0.900 0.788              0.847
         7  2 - 6      48     2    43     9       0.842       0.956 0.960 0.827              0.899
         7  2 - 7      46     4    47     5       0.902       0.922 0.920 0.904              0.912
         7  2 - 8      46     4    47     5       0.902       0.922 0.920 0.904              0.912
         7  2 - 9      46     4    46     6       0.885       0.920 0.920 0.885              0.902
         7  2 - 10     46     4    46     6       0.885       0.920 0.920 0.885              0.902
         7  2 - 11     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         7  2 - 12     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         8  2 - 2      45     5    40    12       0.789       0.889 0.900 0.769              0.839
         8  2 - 3      42     8    44     8       0.840       0.846 0.840 0.846              0.843
         8  2 - 4      46     4    45     7       0.868       0.918 0.920 0.865              0.893
         8  2 - 5      46     4    43     9       0.836       0.915 0.920 0.827              0.876
         8  2 - 6      48     2    44     8       0.857       0.957 0.960 0.846              0.907
         8  2 - 7      46     4    48     4       0.920       0.923 0.920 0.923              0.922
         8  2 - 8      47     3    48     4       0.922       0.941 0.940 0.923              0.931
         8  2 - 9      47     3    45     7       0.870       0.938 0.940 0.865              0.904
         8  2 - 10     47     3    45     7       0.870       0.938 0.940 0.865              0.904
         8  2 - 11     46     4    46     6       0.885       0.920 0.920 0.885              0.902
         8  2 - 12     46     4    46     6       0.885       0.920 0.920 0.885              0.902
         9  2 - 2      45     5    41    11       0.804       0.891 0.900 0.788              0.847
         9  2 - 3      43     7    44     8       0.843       0.863 0.860 0.846              0.853
         9  2 - 4      45     5    44     8       0.849       0.898 0.900 0.846              0.874
         9  2 - 5      43     7    42    10       0.811       0.857 0.860 0.808              0.834
         9  2 - 6      49     1    46     6       0.891       0.979 0.980 0.885              0.935
         9  2 - 7      46     4    47     5       0.902       0.922 0.920 0.904              0.912
         9  2 - 8      46     4    47     5       0.902       0.922 0.920 0.904              0.912
         9  2 - 9      47     3    46     6       0.887       0.939 0.940 0.885              0.913
         9  2 - 10     47     3    46     6       0.887       0.939 0.940 0.885              0.913
         9  2 - 11     47     3    46     6       0.887       0.939 0.940 0.885              0.913
         9  2 - 12     48     2    46     6       0.889       0.958 0.960 0.885              0.924
        10  2 - 2      46     4    40    12       0.793       0.909 0.920 0.769              0.851
        10  2 - 3      42     8    45     7       0.857       0.849 0.840 0.865              0.853
        10  2 - 4      45     5    44     8       0.849       0.898 0.900 0.846              0.874
        10  2 - 5      44     6    42    10       0.815       0.875 0.880 0.808              0.845
        10  2 - 6      46     4    46     6       0.885       0.920 0.920 0.885              0.902
        10  2 - 7      48     2    46     6       0.889       0.958 0.960 0.885              0.924
        10  2 - 8      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        10  2 - 9      46     4    45     7       0.868       0.918 0.920 0.865              0.893
        10  2 - 10     46     4    45     7       0.868       0.918 0.920 0.865              0.893
        10  2 - 11     46     4    46     6       0.885       0.920 0.920 0.885              0.902
        10  2 - 12     48     2    48     4       0.923       0.960 0.960 0.923              0.942
        11  2 - 2      48     2    40    12       0.800       0.952 0.960 0.769              0.876
        11  2 - 3      46     4    44     8       0.852       0.917 0.920 0.846              0.884
        11  2 - 4      46     4    44     8       0.852       0.917 0.920 0.846              0.884
        11  2 - 5      44     6    43     9       0.830       0.878 0.880 0.827              0.854
        11  2 - 6      44     6    47     5       0.898       0.887 0.880 0.904              0.892
        11  2 - 7      48     2    48     4       0.923       0.960 0.960 0.923              0.942
        11  2 - 8      47     3    46     6       0.887       0.939 0.940 0.885              0.913
        11  2 - 9      46     4    45     7       0.868       0.918 0.920 0.865              0.893
        11  2 - 10     46     4    45     7       0.868       0.918 0.920 0.865              0.893
        11  2 - 11     46     4    46     6       0.885       0.920 0.920 0.885              0.902
        11  2 - 12     47     3    48     4       0.922       0.941 0.940 0.923              0.931
        12  2 - 2      48     2    41    11       0.814       0.953 0.960 0.788              0.884
        12  2 - 3      44     6    44     8       0.846       0.880 0.880 0.846              0.863
        12  2 - 4      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        12  2 - 5      46     4    44     8       0.852       0.917 0.920 0.846              0.884
        12  2 - 6      46     4    47     5       0.902       0.922 0.920 0.904              0.912
        12  2 - 7      48     2    44     8       0.857       0.957 0.960 0.846              0.907
        12  2 - 8      47     3    46     6       0.887       0.939 0.940 0.885              0.913
        12  2 - 9      46     4    44     8       0.852       0.917 0.920 0.846              0.884
        12  2 - 10     46     4    45     7       0.868       0.918 0.920 0.865              0.893
        12  2 - 11     44     6    42    10       0.815       0.875 0.880 0.808              0.845
        12  2 - 12     47     3    43     9       0.839       0.935 0.940 0.827              0.887
        13  2 - 2      48     2    37    15       0.762       0.949 0.960 0.712              0.855
        13  2 - 3      43     7    43     9       0.827       0.860 0.860 0.827              0.843
        13  2 - 4      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        13  2 - 5      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        13  2 - 6      46     4    46     6       0.885       0.920 0.920 0.885              0.902
        13  2 - 7      46     4    46     6       0.885       0.920 0.920 0.885              0.902
        13  2 - 8      47     3    46     6       0.887       0.939 0.940 0.885              0.913
        13  2 - 9      44     6    43     9       0.830       0.878 0.880 0.827              0.854
        13  2 - 10     45     5    44     8       0.849       0.898 0.900 0.846              0.874
        13  2 - 11     45     5    44     8       0.849       0.898 0.900 0.846              0.874
        13  2 - 12     47     3    43     9       0.839       0.935 0.940 0.827              0.887
        14  2 - 2      47     3    41    11       0.810       0.932 0.940 0.788              0.871
        14  2 - 3      43     7    41    11       0.796       0.854 0.860 0.788              0.825
        14  2 - 4      46     4    44     8       0.852       0.917 0.920 0.846              0.884
        14  2 - 5      46     4    44     8       0.852       0.917 0.920 0.846              0.884
        14  2 - 6      48     2    47     5       0.906       0.959 0.960 0.904              0.932
        14  2 - 7      45     5    48     4       0.918       0.906 0.900 0.923              0.912
        14  2 - 8      47     3    47     5       0.904       0.940 0.940 0.904              0.922
        14  2 - 9      44     6    42    10       0.815       0.875 0.880 0.808              0.845
        14  2 - 10     46     4    46     6       0.885       0.920 0.920 0.885              0.902
        14  2 - 11     45     5    43     9       0.833       0.896 0.900 0.827              0.865
        14  2 - 12     47     3    44     8       0.855       0.936 0.940 0.846              0.895
        15  2 - 2      47     3    41    11       0.810       0.932 0.940 0.788              0.871
        15  2 - 3      42     8    42    10       0.808       0.840 0.840 0.808              0.824
        15  2 - 4      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        15  2 - 5      46     4    47     5       0.902       0.922 0.920 0.904              0.912
        15  2 - 6      48     2    47     5       0.906       0.959 0.960 0.904              0.932
        15  2 - 7      46     4    48     4       0.920       0.923 0.920 0.923              0.922
        15  2 - 8      45     5    48     4       0.918       0.906 0.900 0.923              0.912
        15  2 - 9      45     5    43     9       0.833       0.896 0.900 0.827              0.865
        15  2 - 10     46     4    45     7       0.868       0.918 0.920 0.865              0.893
        15  2 - 11     44     6    43     9       0.830       0.878 0.880 0.827              0.854
        15  2 - 12     46     4    43     9       0.836       0.915 0.920 0.827              0.876
        16  2 - 2      46     4    40    12       0.793       0.909 0.920 0.769              0.851
        16  2 - 3      42     8    43     9       0.824       0.843 0.840 0.827              0.833
        16  2 - 4      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        16  2 - 5      48     2    47     5       0.906       0.959 0.960 0.904              0.932
        16  2 - 6      48     2    47     5       0.906       0.959 0.960 0.904              0.932
        16  2 - 7      46     4    48     4       0.920       0.923 0.920 0.923              0.922
        16  2 - 8      44     6    47     5       0.898       0.887 0.880 0.904              0.892
        16  2 - 9      44     6    46     6       0.880       0.885 0.880 0.885              0.882
        16  2 - 10     46     4    45     7       0.868       0.918 0.920 0.865              0.893
        16  2 - 11     45     5    43     9       0.833       0.896 0.900 0.827              0.865
        16  2 - 12     45     5    45     7       0.865       0.900 0.900 0.865              0.883
        17  2 - 2      46     4    41    11       0.807       0.911 0.920 0.788              0.859
        17  2 - 3      41     9    44     8       0.837       0.830 0.820 0.846              0.833
        17  2 - 4      46     4    44     8       0.852       0.917 0.920 0.846              0.884
        17  2 - 5      45     5    46     6       0.882       0.902 0.900 0.885              0.892
        17  2 - 6      47     3    46     6       0.887       0.939 0.940 0.885              0.913
        17  2 - 7      47     3    48     4       0.922       0.941 0.940 0.923              0.931
        17  2 - 8      45     5    48     4       0.918       0.906 0.900 0.923              0.912
        17  2 - 9      44     6    46     6       0.880       0.885 0.880 0.885              0.882
        17  2 - 10     45     5    45     7       0.865       0.900 0.900 0.865              0.883
        17  2 - 11     45     5    43     9       0.833       0.896 0.900 0.827              0.865
        17  2 - 12     46     4    44     8       0.852       0.917 0.920 0.846              0.884
        18  2 - 2      47     3    42    10       0.825       0.933 0.940 0.808              0.879
        18  2 - 3      41     9    44     8       0.837       0.830 0.820 0.846              0.833
        18  2 - 4      46     4    44     8       0.852       0.917 0.920 0.846              0.884
        18  2 - 5      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        18  2 - 6      48     2    47     5       0.906       0.959 0.960 0.904              0.932
        18  2 - 7      47     3    48     4       0.922       0.941 0.940 0.923              0.931
        18  2 - 8      44     6    48     4       0.917       0.889 0.880 0.923              0.903
        18  2 - 9      45     5    45     7       0.865       0.900 0.900 0.865              0.883
        18  2 - 10     46     4    45     7       0.868       0.918 0.920 0.865              0.893
        18  2 - 11     46     4    43     9       0.836       0.915 0.920 0.827              0.876
        18  2 - 12     46     4    42    10       0.821       0.913 0.920 0.808              0.867
        19  2 - 2      48     2    43     9       0.842       0.956 0.960 0.827              0.899
        19  2 - 3      40    10    44     8       0.833       0.815 0.800 0.846              0.824
        19  2 - 4      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        19  2 - 5      46     4    45     7       0.868       0.918 0.920 0.865              0.893
        19  2 - 6      47     3    45     7       0.870       0.938 0.940 0.865              0.904
        19  2 - 7      47     3    47     5       0.904       0.940 0.940 0.904              0.922
        19  2 - 8      46     4    48     4       0.920       0.923 0.920 0.923              0.922
        19  2 - 9      46     4    46     6       0.885       0.920 0.920 0.885              0.902
        19  2 - 10     45     5    43     9       0.833       0.896 0.900 0.827              0.865
        19  2 - 11     45     5    43     9       0.833       0.896 0.900 0.827              0.865
        19  2 - 12     46     4    44     8       0.852       0.917 0.920 0.846              0.884
        20  2 - 2      49     1    44     8       0.860       0.978 0.980 0.846              0.919
        20  2 - 3      42     8    43     9       0.824       0.843 0.840 0.827              0.833
        20  2 - 4      47     3    44     8       0.855       0.936 0.940 0.846              0.895
        20  2 - 5      46     4    42    10       0.821       0.913 0.920 0.808              0.867
        20  2 - 6      48     2    47     5       0.906       0.959 0.960 0.904              0.932
        20  2 - 7      47     3    48     4       0.922       0.941 0.940 0.923              0.931
        20  2 - 8      46     4    47     5       0.902       0.922 0.920 0.904              0.912
        20  2 - 9      45     5    44     8       0.849       0.898 0.900 0.846              0.874
        20  2 - 10     45     5    44     8       0.849       0.898 0.900 0.846              0.874
        20  2 - 11     45     5    43     9       0.833       0.896 0.900 0.827              0.865
        20  2 - 12     44     6    44     8       0.846       0.880 0.880 0.846              0.863

```


We can see that the maximum for balanced accuracy is 0.942, which first occurs 
for 4 attributes and a bin range of 2-11. However, we achieve almost the same
accuracy (ie, 0.941) with only 3 attributes. Using more attributes does not
provide any increases in accuracy.

Experience with this algorithm suggests that using the same number of bins for 
all continuous attributes in some cases provides better results. We can try this
with the -u flag, over an abbreviated range of attributes and bins:

```v
v -gc boehm run hamnn.v explore -c -e -g -w -b 6,12 -a 3,5 -u datasets/prostata.tab
```
```
A correct classification to "normal" is a True Positive (TP);
A correct classification to "tumor" is a True Negative (TN).
Attributes    Bins     TP    FP    TN    FN Sensitivity Specificity   PPV   NPV  Balanced Accuracy
         3       6     49     1    47     5       0.907       0.979 0.980 0.904              0.943
         3       7     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         3       8     47     3    46     6       0.887       0.939 0.940 0.885              0.913
         3       9     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         3      10     45     5    44     8       0.849       0.898 0.900 0.846              0.874
         3      11     42     8    40    12       0.778       0.833 0.840 0.769              0.806
         3      12     42     8    40    12       0.778       0.833 0.840 0.769              0.806
         4       6     46     4    44     8       0.852       0.917 0.920 0.846              0.884
         4       7     44     6    45     7       0.863       0.882 0.880 0.865              0.873
         4       8     46     4    47     5       0.902       0.922 0.920 0.904              0.912
         4       9     43     7    43     9       0.827       0.860 0.860 0.827              0.843
         4      10     44     6    41    11       0.800       0.872 0.880 0.788              0.836
         4      11     46     4    45     7       0.868       0.918 0.920 0.865              0.893
         4      12     44     6    43     9       0.830       0.878 0.880 0.827              0.854
         5       6     47     3    44     8       0.855       0.936 0.940 0.846              0.895
         5       7     45     5    47     5       0.900       0.904 0.900 0.904              0.902
         5       8     42     8    46     6       0.875       0.852 0.840 0.885              0.863
         5       9     45     5    43     9       0.833       0.896 0.900 0.827              0.865
         5      10     44     6    39    13       0.772       0.867 0.880 0.750              0.819
         5      11     46     4    46     6       0.885       0.920 0.920 0.885              0.902
         5      12     47     3    46     6       0.887       0.939 0.940 0.885              0.913
```

It turns out that three attributes and 6 bins for all attributes,
gives us the best balanced accuracy of 0.943, marginally better than when using a range of bins. Let's stick with these settings, and create a classifier that
can be used for predicting outcomes:

```v
v run hamnn.v make -a 3 -b 6 -u -c -o ../classifiers/prostata_classifier datasets/prostata.tab
```

Note the use of the -o flag to specify a file where the classifier is to stored
for later use (work in progress).