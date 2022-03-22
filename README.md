<!-- README.md is generated from README.Rmd. Please edit that file -->

## Introduction

Volatility refers to the degree of instability (or change over time) in
the microbiome. High volatility, ie an unstable microbiome, has been
associated with an exaggerated stress response and conditions like IBS.

This library provides a basic framework to calculate volatility for
timepoint microbiome data.

If you use this software, please cite our work.

Thomaz F.S Bastiaanssen, Anand Gururajan, Marcel van de Wouw, Gerard M
Moloney, Nathaniel L Ritz, Caitriona M Long-Smith, Niamh C Wiley, Amy B
Murphy, Joshua M Lyte, Fiona Fouhy, Catherine Stanton, Marcus J
Claesson, Timothy G Dinan, John F Cryan, Volatility as a Concept to
Understand the Impact of Stress on the Microbiome,
Psychoneuroendocrinology
<https://doi.org/10.1016/j.psyneuen.2020.105047>

## Setup

OK, now let’s get started. We’ll load a complementary training dataset
using `data(volatility_data)`. This loads a curated snippet from the
dataset described in more detail here:
<https://doi.org/10.1016/j.psyneuen.2020.105047>

The method presented here is differs only marginally from the one used
there.

``` r
#install and load volatility library
#devtools::install_github("thomazbastiaanssen/volatility")
library(volatility)

#load tidyverse to wrangle and plot results
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
    ## ✓ tibble  3.1.6     ✓ dplyr   1.0.8
    ## ✓ tidyr   1.2.0     ✓ stringr 1.4.0
    ## ✓ readr   2.1.2     ✓ forcats 0.5.1

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
#load example data + metadata from the volatility study study
data(volatility_data)
```

## Input data

The main `volatility` function does all the heavy lifting here. It
expects two objects. \* `counts`, a microbiome feature count table, with
columns as samples and rows and features. \* `metadata`, a vector in the
same order as the count table, denoting which samples are from the same
source. + the column `mouse_ID` in `vola_metadata` is appropriate for
this.

``` r
head(vola_genus_table)
```

    ##                                                                                                Validation_Pre_Control_1
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        1017
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    102
    ##                                                                                                Validation_Pre_Control_2
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     47
    ##                                                                                                Validation_Pre_Control_3
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        5650
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    139
    ##                                                                                                Validation_Pre_Control_4
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         790
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    136
    ##                                                                                                Validation_Pre_Control_5
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         723
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        5
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     81
    ##                                                                                                Validation_Pre_Control_6
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         579
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        5
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     95
    ##                                                                                                Validation_Pre_Control_7
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        2347
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    168
    ##                                                                                                Validation_Pre_Control_8
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          87
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     61
    ##                                                                                                Validation_Pre_Control_9
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     21
    ##                                                                                                Validation_Pre_Control_10
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       7
    ##                                                                                                Validation_Pre_Stress_11
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     82
    ##                                                                                                Validation_Pre_Stress_13
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         343
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     82
    ##                                                                                                Validation_Pre_Stress_14
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        3564
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                       80
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     74
    ##                                                                                                Validation_Pre_Stress_15
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        3361
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                      397
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     58
    ##                                                                                                Validation_Pre_Stress_16
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        1678
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                      262
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       14
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    101
    ##                                                                                                Validation_Pre_Stress_17
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         144
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    104
    ##                                                                                                Validation_Pre_Stress_18
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    182
    ##                                                                                                Validation_Pre_Stress_19
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     93
    ##                                                                                                Validation_Pre_Stress_20
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          76
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        8
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     13
    ##                                                                                                Validation_Pre_Stress_21
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        1602
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       10
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     13
    ##                                                                                                Validation_Pre_Stress_23
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         379
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     49
    ##                                                                                                Validation_Pre_Stress_24
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         764
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        8
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    154
    ##                                                                                                Validation_Pre_Stress_25
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         142
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     96
    ##                                                                                                Validation_Pre_Stress_26
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        2366
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       10
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    107
    ##                                                                                                Validation_Pre_Stress_27
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        2431
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       11
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    232
    ##                                                                                                Validation_Pre_Stress_28
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         198
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     47
    ##                                                                                                Validation_Pre_Stress_29
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       19
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     30
    ##                                                                                                Validation_Pre_Stress_30
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           4
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       11
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     41
    ##                                                                                                Validation_Pre_Stress_31
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         623
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       52
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     85
    ##                                                                                                Validation_Pre_Stress_32
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         359
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        7
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     21
    ##                                                                                                Validation_Pre_Stress_33
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        2064
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                      159
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                      203
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     39
    ##                                                                                                Validation_Pre_Stress_34
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        2554
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                       18
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                      277
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     84
    ##                                                                                                Validation_Pre_Stress_35
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                      321
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    100
    ##                                                                                                Validation_Pre_Stress_36
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    103
    ##                                                                                                Validation_Pre_Stress_37
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          10
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     60
    ##                                                                                                Validation_Pre_Stress_38
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         850
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        6
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     29
    ##                                                                                                Validation_Pre_Stress_39
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        7410
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       38
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    134
    ##                                                                                                Validation_Pre_Stress_40
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        2474
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     86
    ##                                                                                                Discovery_Pre_Control_C13
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          299
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      32
    ##                                                                                                Discovery_Pre_Control_C18
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         1939
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        39
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      79
    ##                                                                                                Discovery_Pre_Control_C20
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           16
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      18
    ##                                                                                                Discovery_Pre_Control_C22
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          136
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       8
    ##                                                                                                Discovery_Pre_Control_C23
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          944
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        10
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      42
    ##                                                                                                Discovery_Pre_Control_C24
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           75
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      17
    ##                                                                                                Discovery_Pre_Control_C25
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         2586
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        20
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      17
    ##                                                                                                Discovery_Pre_Control_C26
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           48
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      48
    ##                                                                                                Discovery_Pre_Control_C7
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         483
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     28
    ##                                                                                                Discovery_Pre_Stress_SR1
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          84
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        5
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     40
    ##                                                                                                Discovery_Pre_Stress_SR11
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         2460
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        14
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      59
    ##                                                                                                Discovery_Pre_Stress_SR14
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           89
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      12
    ##                                                                                                Discovery_Pre_Stress_SR15
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         2545
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        37
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      68
    ##                                                                                                Discovery_Pre_Stress_SR16
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         5599
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        46
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      45
    ##                                                                                                Discovery_Pre_Stress_SR19
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           20
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      24
    ##                                                                                                Discovery_Pre_Stress_SR25
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          371
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         7
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       8
    ##                                                                                                Discovery_Pre_Stress_SR8
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         570
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     68
    ##                                                                                                Discovery_Pre_Stress_SS21
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         4
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      92
    ##                                                                                                Discovery_Pre_Stress_SS3
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         368
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     89
    ##                                                                                                Discovery_Pre_Stress_SS5
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     55
    ##                                                                                                Discovery_Pre_Stress_SS7
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         798
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       31
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                    141
    ##                                                                                                Discovery_Pre_Stress_SS9
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                        2955
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                       26
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                 6
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     63
    ##                                                                                                Validation_Post_Control_1
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           59
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      49
    ##                                                                                                Validation_Post_Control_2
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         9
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      58
    ##                                                                                                Validation_Post_Control_3
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          998
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      93
    ##                                                                                                Validation_Post_Control_4
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          481
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      14
    ##                                                                                                Validation_Post_Control_5
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            6
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      46
    ##                                                                                                Validation_Post_Control_6
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          529
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      55
    ##                                                                                                Validation_Post_Control_7
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         5675
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      61
    ##                                                                                                Validation_Post_Control_8
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          496
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     167
    ##                                                                                                Validation_Post_Control_9
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          114
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        33
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     103
    ##                                                                                                Validation_Post_Control_10
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                             4
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       31
    ##                                                                                                Validation_Post_Stress_11
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            3
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      45
    ##                                                                                                Validation_Post_Stress_13
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         1508
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      48
    ##                                                                                                Validation_Post_Stress_14
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          725
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        47
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         7
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      87
    ##                                                                                                Validation_Post_Stress_15
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          581
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                       188
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      36
    ##                                                                                                Validation_Post_Stress_16
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          648
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                        70
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      19
    ##                                                                                                Validation_Post_Stress_17
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          454
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         8
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       7
    ##                                                                                                Validation_Post_Stress_18
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        61
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     211
    ##                                                                                                Validation_Post_Stress_19
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      75
    ##                                                                                                Validation_Post_Stress_20
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          344
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      90
    ##                                                                                                Validation_Post_Stress_21
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          374
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      45
    ##                                                                                                Validation_Post_Stress_23
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          707
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     119
    ##                                                                                                Validation_Post_Stress_24
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         1957
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        19
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      93
    ##                                                                                                Validation_Post_Stress_25
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           96
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      84
    ##                                                                                                Validation_Post_Stress_26
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         3394
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        13
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      56
    ##                                                                                                Validation_Post_Stress_27
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         2241
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      78
    ##                                                                                                Validation_Post_Stress_28
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         1619
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      18
    ##                                                                                                Validation_Post_Stress_29
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         6
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       8
    ##                                                                                                Validation_Post_Stress_30
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      64
    ##                                                                                                Validation_Post_Stress_31
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         7755
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        16
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      39
    ##                                                                                                Validation_Post_Stress_32
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          448
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        10
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      47
    ##                                                                                                Validation_Post_Stress_33
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         1147
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                       167
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         7
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     131
    ##                                                                                                Validation_Post_Stress_34
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           47
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       9
    ##                                                                                                Validation_Post_Stress_35
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      76
    ##                                                                                                Validation_Post_Stress_36
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           16
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      17
    ##                                                                                                Validation_Post_Stress_37
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          257
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      24
    ##                                                                                                Validation_Post_Stress_38
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           33
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       0
    ##                                                                                                Validation_Post_Stress_39
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          952
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         6
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      71
    ##                                                                                                Validation_Post_Stress_40
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          765
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        10
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       0
    ##                                                                                                Discovery_Post_Control_C13
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          2867
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       71
    ##                                                                                                Discovery_Post_Control_C18
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          3511
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       41
    ##                                                                                                Discovery_Post_Control_C20
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            59
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                        0
    ##                                                                                                Discovery_Post_Control_C22
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          1892
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        120
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      158
    ##                                                                                                Discovery_Post_Control_C23
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          1437
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          6
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       51
    ##                                                                                                Discovery_Post_Control_C24
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           318
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         14
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      184
    ##                                                                                                Discovery_Post_Control_C25
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          1491
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       86
    ##                                                                                                Discovery_Post_Control_C26
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           166
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      154
    ##                                                                                                Discovery_Post_Control_C7
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          323
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      28
    ##                                                                                                Discovery_Post_Stress_SR1
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           15
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      90
    ##                                                                                                Discovery_Post_Stress_SR11
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          1533
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          8
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      384
    ##                                                                                                Discovery_Post_Stress_SR14
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            24
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      222
    ##                                                                                                Discovery_Post_Stress_SR15
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          2561
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          8
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      118
    ##                                                                                                Discovery_Post_Stress_SR16
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           657
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      143
    ##                                                                                                Discovery_Post_Stress_SR19
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           152
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                        8
    ##                                                                                                Discovery_Post_Stress_SR25
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                           130
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       19
    ##                                                                                                Discovery_Post_Stress_SR8
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          375
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      63
    ##                                                                                                Discovery_Post_Stress_SS21
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            12
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                     0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                          0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                   0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       11
    ##                                                                                                Discovery_Post_Stress_SS3
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            6
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                        12
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                      34
    ##                                                                                                Discovery_Post_Stress_SS5
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                            0
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     106
    ##                                                                                                Discovery_Post_Stress_SS7
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                          292
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                       0
    ##                                                                                                Discovery_Post_Stress_SS9
    ## Bacteria_Actinobacteria_Actinobacteria_Bifidobacteriales_Bifidobacteriaceae_Bifidobacterium                         5226
    ## Bacteria_Actinobacteria_Actinobacteria_Kineosporiales_Kineosporiaceae_Quadrisphaera                                    0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Coriobacteriaceae_UCG-002                         0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Atopobiaceae_Olsenella                                      2371
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Coriobacteriaceae_Collinsella                                  0
    ## Bacteria_Actinobacteria_Coriobacteriia_Coriobacteriales_Eggerthellaceae_DNF00809                                     916

``` r
head(vola_metadata)
```

    ##                  sample_ID     cohort timepoint treatment mouse_ID
    ## 1 Validation_Pre_Control_1 Validation       Pre   Control        1
    ## 2 Validation_Pre_Control_2 Validation       Pre   Control        2
    ## 3 Validation_Pre_Control_3 Validation       Pre   Control        3
    ## 4 Validation_Pre_Control_4 Validation       Pre   Control        4
    ## 5 Validation_Pre_Control_5 Validation       Pre   Control        5
    ## 6 Validation_Pre_Control_6 Validation       Pre   Control        6

## Basic use

``` r
vola_out <- volatility(counts = vola_genus_table, metadata = vola_metadata$mouse_ID)
```

## Plot the results

``` r
met = vola_metadata
colnames(met)[5] = "ID"
left_join(vola_out, met[1:60,], "ID") %>%

  ggplot(aes(x = treatment, y = volatility, fill = treatment)) +
  geom_path(aes(group = ID)) +
  geom_boxplot(alpha = 1/2)+
  geom_point(shape = 21) +
  facet_wrap(~cohort) +
  scale_fill_manual(values = c("Control" = "#3690c0", "Stress"  = "#cb181d")) +
  theme_bw() 
```

    ## geom_path: Each group consists of only one observation. Do you need to adjust
    ## the group aesthetic?
    ## geom_path: Each group consists of only one observation. Do you need to adjust
    ## the group aesthetic?

![](README_files/figure-gfm/plot_volatility-1.png)<!-- -->
