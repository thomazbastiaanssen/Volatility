#' Compute volatility between pairs of microbiome count data
#' @description The main function of the volatility package.
#' @param counts a microbiome count table, with rows as features and columns as samples
#' @param metadata a vector in the same order as `counts`, containing information on which samples are from the same source and should be linked.
#' @param transform a boolean, whether to CLR-transform count data beforehand. Highly recommended.
#' @param verbose A boolean. Toggles whether to print diagnostic information while running. Useful for debugging errors on large datasets.
#' @return a data.frame with IDs and volatility estimates per sample pair
#' @export
#'
volatility <- function(counts, metadata, transform = TRUE, verbose = TRUE){
  if(transform){stopifnot("Count table contains negative values;\nIt looks like the count table is already transformed." = all(counts >= 0))}

  if(transform){
  ###Apply CLR transformation
  counts = clr_c(counts)
    }
  ###Compute volatility
  volatility_df = compute_volatility(counts = counts, ids = metadata)
}

# volatility_boot <- function(counts, metadata, transform = TRUE, times = 1000, nmax = 50, verbose = TRUE){
#   #stopifnot("nmax cannot exceed the the number of features." = nmax <= nrow(counts))
#
#   boot_inds <- replicate(times, sample(1:nrow(counts), size = nmax, replace = T))
#   res = apply(boot_inds, MARGIN = 2, FUN = function(x) {volatility(counts = counts[x,], metadata = metadata)$volatility})
#
#   row.names(res) = unique(sort(metadata))
#
#   return(res)
# }

compute_volatility <- function(counts, ids, verbose = TRUE){
  stopifnot("For simple volatility calculations all microbiomes need exactly two measurements" = all(table(ids) == 2))

  #First compute a euclidean distance matrix for all samples
  dist.matrix = as.matrix(dist(x = t(counts), method = "euclidean", diag = T, upper = T))

  #Establish the order of the IDs in metadata.
  #r will contain the locations of the first member of each sample pair.
  r = order(ids)[1:length(ids) %% 2 == 1]
  #c will contain the location of the second member of each sample pair.
  c = order(ids)[1:length(ids) %% 2 == 0]

  #Make a single index of values to extract form the matrix.
  #r represents the row position in the matrix, whereas (c-1)*nrow represents how
  #many times the number of rows needs to be added to reflect increasing the column position by 1.
  volatility = dist.matrix[r + ((c-1)*nrow(dist.matrix)) ]


  volatility_df = data.frame(ID         = unique(sort(ids)),
                             volatility = volatility)

  return(volatility_df)

}
# counts <- vola_genus_table
#
# counts = counts[apply(counts == 0, 1, sum) <= (ncol(counts) *0.90 ), ]
#
# counts.exp = clr_c(counts)
# res = volatility(counts = counts, metadata = vola_metadata$mouse_ID)
# bootres = volatility_boot(counts = counts, metadata = vola_metadata$mouse_ID, times = 10, nmax = 500 )
#
# mapres = lapply(X = (10 *1:8), FUN = function(x){volatility_boot(counts = counts, metadata = vola_metadata$mouse_ID, times = 10, nmax = x)})
#
# mapres = lapply(X = mapres, FUN = function(x){apply(x, 1, median)})
# bootres = do.call(cbind, mapres)
# bootres = apply(bootres, 1, median)
#
# bootres = data.frame(ID = rownames(bootres),
#                      volatility = bootres)
#
# library(tidyverse)
#
# met = vola_metadata
# colnames(met)[5] = "ID"
# left_join(bootres, met[1:60,], "ID") %>%
#   pivot_longer(!c(ID, sample_ID, cohort, timepoint, treatment)) %>%
#   ggplot(aes(x = name, y = value, groups = treatment)) +
#   geom_path(aes(group = ID)) +
#   geom_boxplot()+
#   geom_point(position = position_dodge(0.75)) +
#   facet_wrap(~cohort)

