#' permuteMeans
#'
#' Sets up permutations of the classes corresponding to the grouMeans matrix
#' for evaluating the performance of various distance functions used with the
#' spSwarm method.
#'
#' @name permuteMeans
#' @rdname permuteMeans
#' @aliases permuteMeans
#' @param spCountsMul A spCounts object containing multiplets.
#' @param spUnsupervised An spUnsupervised object.
#' @param nPerms Number of total permutations. If NULL set to 100 per multiplet.
#' @param ... additional arguments to pass on
#' @return data.frame
#' @author Jason T. Serviss
#'
#'
#'
NULL
#' @export
#' @import sp.scRNAseq
#' @importFrom purrr map

permuteMeans <- function(
  spCountsMul,
  spUnsupervised,
  nPerms = NULL
){
  means <- getData(spUnsupervised, "groupMeans")
  idx <- getData(spUnsupervised, "selectInd")
  l <- ncol(means)
  if(is.null(nPerms)) {nPerms <- 100 * ncol(getData(spCountsMul, "counts"))}
  
  pIdx <- .colIdx(nPerms, idx, l)
  sIdx <- .rowIdx(idx, l, nPerms, pIdx)
  
  matrix(
    means[sIdx],
    ncol = l,
    dimnames = list(sort(rep(1:nPerms, length(idx))), colnames(means)),
    byrow = TRUE
  )
}

.colIdx <- function(nPerms, idx, l) {
  map(1:(nPerms * length(idx)), function(x) {
    sample(seq(1, l, 1), l, replace = FALSE)
  }) %>%
  unlist()
}

.rowIdx <- function(idx, l, nPerms, pIdx) {
  matrix(
    c(rep(sort(rep(1:length(idx), l)), nPerms), pIdx),
    ncol = 2
  )
}


#' permuteClass
#'
#' Sets up permutations of the classes corresponding to the counts matrix
#' for evaluating the performance of various distance functions used with the
#' spSwarm method.
#'
#' @name permuteClass
#' @rdname permuteClass
#' @aliases permuteClass
#' @param spCountsMul A spCounts object containing multiplets.
#' @param spUnsupervised An spUnsupervised object.
#' @param nPerms Number of total permutations. If NULL set to 100 per multiplet.
#' @param ... additional arguments to pass on
#' @return data.frame
#' @author Jason T. Serviss
#'
#'
#'
NULL
#' @export
#' @import sp.scRNAseq
#' @importFrom purrr map

permuteClass <- function(
  spCountsMul,
  spUnsupervised,
  nPerms = NULL
){
  classes <- getData(spUnsupervised, "classification")
  l <- length(classes)
  if(is.null(nPerms)) {nPerms <- 100 * ncol(getData(spCountsMul, "counts"))}
  
  pIdx <- map(1:nPerms, function(x) {
    sample(seq(1, l, 1), l, replace = FALSE)
  }) %>%
  unlist()
  
  perms <- classes[pIdx]
  names(perms) <- sort(rep(1:nPerms, l))
  lapply(1:nPerms, function(x) perms[names(perms) == x])
}

#' calculateMeans
#'
#' Calculates the group means using output from the permuteClass function.
#'
#' @name permuteCounts
#' @rdname permuteCounts
#' @aliases permuteCounts
#' @param perms Output from \code{permuteClass} function.
#' @param spCountsSng A spCounts object containing singlets.
#' @param spUnsupervised An spUnsupervised object.
#' @param ... additional arguments to pass on
#' @return data.frame
#' @author Jason T. Serviss
#'
#'
#'
NULL
#' @export
#' @import sp.scRNAseq
#' @importFrom purrr map

calculateMeans <- function(
  perms,
  spCountsSng,
  spUnsupervised,
  ...
){
  idx <- getData(spUnsupervised, "selectInd")
  counts <- getData(spCountsSng, "counts.cpm")[idx, ]
  classes <- getData(spUnsupervised, "classification")
  c <- unique(classes)
  id <- sort(rep(1:length(perms), nrow(counts)))
  
  map_dfr(1:length(perms), ~.calcMeans(perms[[.]], c, counts)) %>%
  unlist() %>%
  matrix(., ncol = length(c), dimnames = list(id, c))
}

.calcMeans <- function(classes, c, counts) {
  map_dfc(c, function(x) {data.frame(rowMeans(counts[, classes == x]))})
}

#' permutationCosts
#'
#' Calculates the costs for each permutation using the provided function and
#' returns these together with the real costs. Note that the real costs in the
#' spSwarm object should be calculated with the SAME distance function as
#' provided in the \code{distFun} argument.
#'
#' @name permutationCosts
#' @rdname permutationCosts
#' @aliases permutationCosts
#' @param permutationMeans Output from permutationMeans function.
#' @param spCountsMul An spCounts object containing multiplets.
#' @param spUnsupervised An spUnsupervised object.
#' @param nPermsPerMul Numeric; Number of permutations per multiplet. If null
#'  this is set to 100.
#' @param Function; A distance function that returns the cost.
#' @param ... additional arguments to pass on.
#' @return matrix
#' @author Jason T. Serviss
#'
#'
#'
NULL

#' @export
#' @import sp.scRNAseq
#' @importFrom purrr map_dfc
#' @importFrom dplyr mutate
#' @importFrom purrr map2_int pmap_int
#' @importFrom tibble add_column
#' @importFrom tidyr gather spread
#' @importFrom magrittr "%>%"

permutationCosts <- function(
  permutationMeans,
  spCountsMul,
  spUnsupervised,
  spSwarm,
  nPermsPerMul = NULL,
  distFun = sp.scRNAseq:::distToSlice,
  ...
){
  idx <- getData(spUnsupervised, "selectInd")
  multiplets <- getData(spCountsMul, "counts.cpm")[idx, ]
  fracs <- getData(spSwarm, "spSwarm")
  if(is.null(nPermsPerMul)) {nPermsPerMul <- 100}
  
  real <- tibble(
    key = rownames(getData(spSwarm, "spSwarm")),
    cost = getData(spSwarm, "costs")
  )
  
  map_dfc(
    1:ncol(multiplets),
    ~.cost2(.x, multiplets, fracs, nPermsPerMul, permutationMeans, distFun)
  ) %>%
  setNames(colnames(multiplets)) %>%
  add_column(tmp = 1:nPermsPerMul) %>%
  gather(key, value, -tmp) %>%
  spread(tmp, value) %>%
  left_join(real, by = "key") %>%
  gather(iteration, cost, -key) %>%
  mutate(Type = if_else(iteration == "cost", "real", "permuted")) %>%
  select(-iteration)
}

.cost <- function(
  i,
  multiplets,
  fracs,
  nPermsPerMul,
  permutationMeans,
  distFun
){
  pIdx <- ((i * nPermsPerMul) - (nPermsPerMul - 1)):(i * nPermsPerMul)
  multiplet <- multiplets[, i]
  frac <- as.numeric(fracs[i, ])
  
  map_dbl(
    1:length(pIdx),
    ~ distFun(
      frac,
      permutationMeans[rownames(permutationMeans) == pIdx[.x], ],
      multiplet
    )
  ) %>%
  as_tibble()
}

.cost2 <- function(
  i,
  multiplets,
  fracs,
  nPermsPerMul,
  permutationMeans,
  distFun
){
  pIdx <- ((i * nPermsPerMul) - (nPermsPerMul - 1)):(i * nPermsPerMul)
  multiplet <- multiplets[, i]
  frac <- matrix(rep(as.numeric(fracs[i, ]), length(pIdx)), ncol = length(fracs), byrow = TRUE)
  
  distFun(frac, permutationMeans[rownames(permutationMeans) %in% pIdx, ], multiplet) %>%
  as_tibble()
}

#' plotDistPermutations
#'
#' Plots the results from the \code{permutationCosts} function.
#'
#' @name plotDistPermutations
#' @rdname plotDistPermutations
#' @aliases plotDistPermutations
#' @param permCosts Tibble; Output from the \code{permutationCosts} function.
#' @param bw Numeric; Binwidth argument to ggplot.
#' @param facet Logical; Indicates if plot should be faceted by multiplet.
#' @param ... additional arguments to pass on.
#' @return matrix
#' @author Jason T. Serviss
#'
#'
#'
NULL

#' @export
#' @import sp.scRNAseq
#' @import ggplot2
#' @importFrom ggthemes theme_few
#' @importFrom magrittr "%>%"

plotDistPermutations <- function(
  permCosts,
  bw = 10000,
  facet = FALSE,
  ...
){
  p <- permCosts %>%
  ggplot() +
  geom_histogram(aes(x = cost, fill = Type), binwidth = as.numeric(bw)) +
  theme_few() +
  theme(
    axis.text.x = element_text(angle = 90),
    legend.position = "top"
  )
  
  if(facet) {
    p <- p + facet_wrap(~key)
    p
    return(p)
  } else {
    p
    return(p)
  }
}
