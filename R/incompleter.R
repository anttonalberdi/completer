#' Filters out annotation table to emulate lower completeness genomes
#'
#' @param annot A tabular functional genome annotation file.
#' @param genome_index Column number in which the genome name is indicated
#' @param contig_index Column number in which the contig name is indicated
#' @param gene_index Column number in which the gene name is indicated
#' @param completeness Completeness percentage to be emulated
#' @param iter Number of iterations. In each iteration a random set of contigs will be removed
#' @return A table of imputed values and imputation statistics.
#' @import tidyverse
#' @importFrom ape cophenetic.phylo keep.tip drop.tip
#' @examples
#' completer(genome_traits,tree)
#' @export

incompleter <- function(annotation, genome_index, contig_index, gene_index, completeness, iter=1){
  
  if(missing(genome_index)){
    stop("You need to specify the column number of genome identities")
  }
  
  if(missing(completeness)){
    stop("You need to specify the desired completeness in percentages. e.g., 80 for 80%")
  }
  
  if(missing(contig_index) & missing(gene_index)){
    stop("You need to specify the column number of either contig or gene identities")
  }
  
  if(!missing(contig_index) & !missing(gene_index)){
    warning("Column numbers for both contig or gene identities have been provided.")
    message(str_c("  Genome annotations will be reduced to ",completeness,"% based on contigs."))
    warning("  If you prefer to transform annotations based on genes, then remove contig_index argument")
    
    # Get original column names
    original_names <- colnames(annotation)[c(genome_index,contig_index)]
    
    # Rename annotation table
    annotation2 <- annotation %>% 
      rename_at(vars(all_of(c(genome_index, contig_index))), ~ c("genome", "contig")) 
    
    # Set transformation type
    type="contig"
  }
  
  if(!missing(contig_index) & missing(gene_index)){
    message(str_c("Genome annotations will be reduced to ",completeness,"% based on contigs."))
    
    # Get original column names
    original_names <- colnames(annotation)[c(genome_index,contig_index)]
    
    # Rename annotation table
    annotation2 <- annotation %>% 
      rename_at(vars(all_of(c(genome_index, contig_index))), ~ c("genome", "contig")) 
    
    # Set transformation type
    type="contig"
  }
  
  if(missing(contig_index) & !missing(gene_index)){
    message(str_c("Genome annotations will be reduced to ",completeness,"% based on genes"))
    
    # Get original column names
    original_names <- colnames(annotation)[c(genome_index,gene_index)]
    
    # Rename annotation table
    annotation2 <- annotation %>% 
      rename_at(vars(all_of(c(genome_index, gene_index))), ~ c("genome", "gene"))
    
    # Set transformation type
    type="gene"
  }
  
  if(iter>1){
    message(str_c("Emulating ",completeness,"% completeness accross ",iter," iterations..."))
  }
  
  incomplete_list <- list()
  
  for (i in c(1:iter)){
    
    if(iter>1){
      message(str_c("  Iteration ",i," out of ",iter,""))
    }
    
    if(type == "contig"){
      incomplete <- annotation2 %>% 
        group_by(genome) %>%
        mutate(complete = n_distinct(contig)) %>%
        mutate(incomplete=round(complete * completeness / 100, 0)) %>% 
      group_by(genome, contig) %>%
        sample_frac(1) %>%
        mutate(contig_rank = row_number()) %>%
        ungroup() %>%
        filter(contig_rank <= incomplete) %>%
        select(-c(complete,incomplete)) %>%
        rename_at(vars(all_of(c(genome_index, contig_index))), ~ original_names) 
      
      incomplete_list[[i]] <- incomplete
    }
    
    if(type == "gene"){
      
      incomplete <- annotation2 %>% 
        group_by(genome) %>%
        mutate(complete = n_distinct(gene)) %>%
        mutate(incomplete=round(complete * completeness / 100, 0))
      group_by(genome, gene) %>%
        sample_frac(1) %>%
        mutate(gene_rank = row_number()) %>%
        ungroup() %>%
        filter(gene_rank <= incomplete) %>%
        select(-c(complete,incomplete)) %>%
        rename_at(vars(all_of(c(gene_index, contig_index))), ~ original_names) 
      
      incomplete_list[[i]] <- incomplete
    }
    
  }
  
  if(iter==1){
    incomplete_list <- incomplete_list[[1]]
  }
  
  return(incomplete_list)
  
}