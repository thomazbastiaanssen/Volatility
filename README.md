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
expects two objects.

-   `counts`, a microbiome feature count table, with columns as samples
    and rows and features.
-   `metadata`, a vector in the same order as the count table, denoting
    which samples are from the same source.
-   the column `mouse_ID` in `vola_metadata` is appropriate for this.

``` r
head(vola_genus_table[,1:2])
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
  geom_boxplot(alpha = 1/2)+
  geom_point(shape = 21) +
  facet_wrap(~cohort) +
  scale_fill_manual(values = c("Control" = "#3690c0", "Stress"  = "#cb181d")) +
  theme_bw() 
```

![](README_files/figure-gfm/plot_volatility-1.png)<!-- -->