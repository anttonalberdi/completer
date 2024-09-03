#' Generate a vector of closest reference genomes
#'
#' @param focal_genomes Vector of focal genomes
#' @param user_tree User reference tree
#' @param reference_tree CompleteR reference tree
#' @return A vector of closest reference genomes
#' @export

references_tree <- function(focal_genomes,user_tree,reference_tree){
  
  message("   Searching for closest reference genomes...")
  tree_distances <- ape::cophenetic.phylo(user_tree)
  
  focal_genomes %>%
          map_chr(~ tree_distances[.x, ] %>% 
                    t() %>% t() %>% 
                    as.data.frame() %>% 
                    rownames_to_column(var = "genome") %>% 
                    rename(distance = 2) %>% 
                    filter(genome %in% reference_tree$tip.label) %>% 
                    arrange(distance) %>% 
                    slice(1) %>% 
                    mutate(genome = gsub("[^[:alnum:]_]", "", genome)) %>% 
                    pull(genome)) %>%
          set_names(focal_genomes)
        
}