#' Converts a tabular annotation file to a trait table ready to be used for imputation
#'
#' @param annot A tabular functional genome annotation file.
#' @param genome_index Column number in which the genome name is indicated
#' @param kegg_index Column number in which to search for KEGG identifiers
#' @return A trait presence/absence table
#' @examples
#' imputation(imputation)
#' @export

annot_to_traits <- function(annot, genome_index, kegg_index){
  
  # Load references if needed
  setup_completer()
  
  # Load reference KEGG list
  keggs <- colnames(completer_traits)[-1]
    
  if(!missing(genome_index)){
    
    # Split by genome
    traits <- annot %>%
      rename_at(vars(all_of(c(genome_index, kegg_index))), ~ c("genome", "kegg")) %>% 
      select(genome, kegg) %>%
      filter(!is.na(kegg)) %>%
      mutate(presence = 1) %>%
      group_split(genome) %>%
      purrr::map(~ {
        genome_name <- unique(.x$genome)
        .x %>%
          group_by(kegg) %>%
          right_join(keggs, by = "kegg") %>%
          mutate(genome = genome_name,
                 presence = ifelse(is.na(presence), 0, presence)) %>%
          arrange(desc(presence)) %>%
          slice(1) %>%
          ungroup() %>%
          arrange(kegg)
      }) %>%
      bind_rows()%>%
      pivot_wider(names_from = "kegg",values_from = "presence")
    
  } else {
    
    # Single genome
    traits <- annot %>%
      rename_at(vars(all_of(c(kegg_index))), ~ c("kegg")) %>% 
      select(kegg) %>%
      filter(!is.na(kegg)) %>%
      mutate(presence = 1) %>%
      group_by(kegg) %>%
          right_join(keggs, by = "kegg") %>%
          mutate(presence = ifelse(is.na(presence), 0, presence)) %>%
          arrange(desc(presence)) %>%
          slice(1) %>%
      ungroup() %>%
       arrange(kegg) %>%
      bind_rows()%>%
      pivot_wider(names_from = "kegg",values_from = "presence")
    }
    
    return(traits)
}