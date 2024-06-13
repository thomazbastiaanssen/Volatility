#' Make a table of pairwise distances based on group membership.
#' @description Given a dist object, extract the relevant pairwise distances. .
#' @param x a dist object, denoting the pairwise distances between samples.
#' @param metadata a vector or table. If a table is given, `g` cannot be left at `NULL`. In this case, all additional information in the metadata file is preserved in the returned `data.frame`.
#' @param g Defaults to `NULL`. If metadata is a table, g should denote the name or index of the column that contains the grouping variable.
#' @param simplify_output Defaults to `TRUE`. Whether duplicate columns should be removed from the returned data.frame.
#' @return a `data.frame` with at least four columns: "to", "from", "dist" and "group". As well as any additional information provided with `metadata` argument.
#' @importFrom utils combn
#' @export
#'
#' @examples
#' c.exp <- clr_lite(vola_genus_table)
#' c.dist <- dist(t(c.exp))
#'
#' get_pairwise_distance(x = c.dist, metadata = vola_metadata, g = "ID")
#'
get_pairwise_distance <- function(x, metadata, g = NULL, simplify_output = TRUE){
  is_1d <- (is.null(dim(metadata)) & length(metadata) > 1)
  #Check call format
  if(!is_1d){
    stopifnot("'metadata' is not a vector, but g is 'NULL'. metadata' should either be a vector, or a table with 'g' designating the relevant column name or index" =
                !is.null(g))
    group <- metadata[,g]
    metadata[,g] <- NULL
  }
  if(is.null(g)){
    stopifnot("'metadata' should either be a vector, or a table with 'g' designating the relevant column name or index" =
                (is_1d))
    group <- metadata
  }

  #Get indices for distances of interest
  paired_idx <- get_paired_index(g = group)

  #Simple case with no additional metadata:
  if(is_1d){
    return(
      data.frame(
        from     = attr(x, "Labels")[paired_idx[1,]],
        to       = attr(x, "Labels")[paired_idx[2,]],
        dist     = x[ind_from_2d_to_1d(dist_obj = x, i = paired_idx[2,], j = paired_idx[1,])],
        group    = group[paired_idx[1,]])
    )
  }
  #Else, when metadata is a table:

  if(simplify_output){

    redundant_cols <- apply(metadata[paired_idx[2,],1:ncol(metadata)] == metadata[paired_idx[1,],1:ncol(metadata)], MARGIN = 2, all)

    return(
      data.frame(
        from     = attr(x, "Labels")[paired_idx[1,]],
        to       = attr(x, "Labels")[paired_idx[2,]],
        dist     = x[ind_from_2d_to_1d(dist_obj = x, i = paired_idx[2,], j = paired_idx[1,])],
        group    = group[paired_idx[1,]],
        metadata[paired_idx[1,], redundant_cols],
        to       = metadata[paired_idx[1,],!redundant_cols],
        from     = metadata[paired_idx[2,],!redundant_cols]
      )
    )
  }

  data.frame(
    from     = attr(x, "Labels")[paired_idx[1,]],
    to       = attr(x, "Labels")[paired_idx[2,]],
    dist     = x[ind_from_2d_to_1d(dist_obj = x, i = paired_idx[2,], j = paired_idx[1,])],
    group    = group[paired_idx[1,]],
    to       = metadata[paired_idx[1,],],
    from     = metadata[paired_idx[2,],]
  )

}

#' @noRd
## 2D index to 1D index
#Credit to Zheyuan Li on stackoverflow:
#https://stackoverflow.com/questions/39005958/
ind_from_2d_to_1d <- function (i, j, dist_obj) {
  if (!inherits(dist_obj, "dist")) stop("please provide a 'dist' object")
  n <- attr(dist_obj, "Size")
  valid <- (i >= 1) & (j >= 1) & (i > j) & (i <= n) & (j <= n)
  k <- (2 * n - j) * (j - 1) / 2 + (i - j)
  k[!valid] <- NA_real_
  k
}

#' @noRd
get_paired_index <- function(g){
  do.call(what = "cbind", tapply(X = g, INDEX = g, FUN = function(y) combn(which(g %in% y), m = 2)))
}
