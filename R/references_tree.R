references_tree <- function(focal_genomes,user_tree,reference_tree){
  
  message("   Calculating cophenetic distances among genomes...")
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