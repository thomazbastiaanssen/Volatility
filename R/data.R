#' The untransformed genus-level count table for the volatility study
#'
#' @description DADA2 with SILVA138 was used to generate this count table.
#'
#' @format A data.frame object with 137 rows, genera, and 120 columns, samples.
#' @source \url{https://doi.org/10.1016/j.psyneuen.2020.105047}
#'
"vola_genus_table"

#' A snippet of the metadata from the volatility study
#'
#' @description There were two cohorts, discovery and validation. Both have a control and stress group.
#' All animals underwent 10 days of chronic social defeat stress or 10 days of business as usual for the controls.
#' Pre and post indicate timepoint, before or after the 10 day period. mouse_ID indicates which samples belong to the same animal.
#'
#' @format A data.frame object with 120 rows, samples, and 5 columns, denoting sample ID, cohort, treatment group, timepoint and mouse_ID, respectively.
#' @source \url{https://doi.org/10.1016/j.psyneuen.2020.105047}
#'
"vola_metadata"
