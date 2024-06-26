<!-- README.md is generated from README.Rmd. Please edit that file -->

## Introduction

Volatility refers to the degree of instability (or change over time) in
the microbiome. High volatility, ie an unstable microbiome, has been
associated with an exaggerated stress response and conditions like IBS.

This library provides a basic framework to calculate volatility for
timepoint microbiome data.

If you use this software, please cite our work.

**Volatility as a Concept to Understand the Impact of Stress on the
Microbiome**

Thomaz F.S Bastiaanssen, Anand Gururajan, Marcel van de Wouw, Gerard M
Moloney, Nathaniel L Ritz, Caitriona M Long-Smith, Niamh C Wiley, Amy B
Murphy, Joshua M Lyte, Fiona Fouhy, Catherine Stanton, Marcus J
Claesson, Timothy G Dinan, John F Cryan

Psychoneuroendocrinology, 2021
<https://doi.org/10.1016/j.psyneuen.2020.105047>

## Setup

OK, now let’s get started. We’ll load a complementary training dataset
using `data(volatility_data)`. This loads a curated snippet from the
dataset described in more detail here:
<https://doi.org/10.1016/j.psyneuen.2020.105047>

The method presented here is differs only incidentally from the one used
there (namely in terms of how zeroes were imputed before
CLR-transformation).

``` r
#install and load volatility library
#devtools::install_github("thomazbastiaanssen/volatility")
library(volatility)

#load tidyverse to wrangle and plot results.
library(tidyverse)

#load example data + metadata from the volatility study.
data(volatility_data)
```

## Input data

In order to compute volatility, we need a feature (count) table, which
contains our microbiome data and a metadata object, which denotes at
least which samples should be paired.

``` r
vola_genus_table[4:10,1:2]
```

    ##                               Validation_Pre_Control_1 Validation_Pre_Control_2
    ## Atopobiaceae_Olsenella                               0                        0
    ## Coriobacteriaceae_Collinsella                        0                        0
    ## Eggerthellaceae_DNF00809                           102                       47
    ## Eggerthellaceae_Enterorhabdus                       53                      114
    ## Eggerthellaceae_Parvibacter                         21                       20
    ## Bacteroidaceae_Bacteroides                         616                      453
    ## Marinifilaceae_Odoribacter                         780                      915

- `metadata`, a vector in the same order as the count table, denoting
  which samples are from the same source.
  - The column `ID` in `vola_metadata` is appropriate for this.

``` r
head(vola_metadata)
```

    ##                  sample_ID     cohort timepoint treatment ID
    ## 1 Validation_Pre_Control_1 Validation       Pre   Control  1
    ## 2 Validation_Pre_Control_2 Validation       Pre   Control  2
    ## 3 Validation_Pre_Control_3 Validation       Pre   Control  3
    ## 4 Validation_Pre_Control_4 Validation       Pre   Control  4
    ## 5 Validation_Pre_Control_5 Validation       Pre   Control  5
    ## 6 Validation_Pre_Control_6 Validation       Pre   Control  6

## Data preparation

Before we compute pairwise distances between samples, it’s a good idea
to transform microbial count data, to help deal with the compositional
nature. Here, we will use a CLR transformation.

``` r
#CLR-transform
vola_genus_table <- clr_c(vola_genus_table)

#Compute distance
vola.dist <- dist(t(vola_genus_table))
```

## Basic use

``` r
vola_out <- get_pairwise_distance(x = vola.dist, metadata = vola_metadata, g = "ID")
```

The output of the main `volatility` function is a data.frame with two
columns. `ID` corresponds to the pairs of samples passed on in the
`metadata` argument, whereas `volatility` shows the measured volatility
between those samples in terms of Aitchison distance (Euclidean distance
of CLR-transformed counts).

## Plot the results

``` r
vola_out %>%
  
  #Pipe into ggplot
  ggplot() +
  
  #Define aesthetics
  aes(x = treatment, y = dist, fill = treatment) + 
  
  #Define geoms, boxplots overlayed with data points in this case
  geom_boxplot(alpha = 1/2)+
  geom_point(shape = 21) +
  
  #Split the plot by cohort
  facet_wrap(~cohort) +
  
  #Tweak appearance 
  scale_fill_manual(values = c("Control" = "#3690c0", "Stress"  = "#cb181d")) +
  theme_bw() +
  xlab("") +
  ylab("Volatility (Aitchison distance)")
```

![](README_files/figure-gfm/plot_volatility-1.png)<!-- -->
