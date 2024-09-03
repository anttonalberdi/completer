#' Generate a vector of phylogenetic distances to closest reference genomes
#'
#' @param focal_genomes Vector of focal genomes
#' @param user_tree User reference tree
#' @param reference_tree CompleteR reference tree
#' @return A vector of phylogenetic distances to closest reference genomes
#' @export

distances_tree <- function(focal_genomes,user_tree,reference_tree){
  
  message("   Calculating phylogenetic distances between target and reference genomes...")
  tree_distances <- ape::cophenetic.phylo(user_tree)
  
  focal_genomes %>%
    map_dbl(~ tree_distances[.x, ] %>% 
              t() %>% t() %>% 
              as.data.frame() %>% 
              rownames_to_column(var = "genome") %>% 
              rename(distance = 2) %>% 
              filter(genome %in% reference_tree$tip.label) %>% 
              arrange(distance) %>% 
              slice(1) %>% 
              mutate(genome = gsub("[^[:alnum:]_]", "", genome)) %>% 
              pull(distance)) %>%
              
    set_names(focal_genomes)
  
}