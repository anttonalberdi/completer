#' Extracts a focal tree containing a certain number of closest neighbor tips from a larger tree 
#'
#' @param focal_tip Name of the focal tip around which the tree will be subseted.
#' @param tip_distances Distance matrix indicating the pairwaise tip distances in the reference tree.
#' @param tree The reference tree
#' @param span Number of neighboring genomes to be employed for calculating the imputed values.
#' @param power Power value used when assigning weights to neighbor genomes (larger values assign larger weights to close neighbors)
#' @return A subseted tree
#' @examples
#' getfocaltree("MAG014122",tip_distances,tree)
#' @export

getfocaltree <- function(focal_tip, tip_distances, tree, span=100, power=2){
  
  # Sort tips according to distance to the focal tip
  focal_tip_distances <- tip_distances[focal_tip, ] %>% sort()
  focal_tip_distances <- focal_tip_distances[names(focal_tip_distances) %in% tree$tip.label]
  
  # Select the tips around the focal genomes
  tip_span <- names(focal_tip_distances[c(1:(span+1))])
  
  # Subset the tree
  subtree <- keep.tip(tree, tip=tip_span)
  
  return(subtree)
}