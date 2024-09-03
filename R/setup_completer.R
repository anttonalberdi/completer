#' Prepare reference data for CompleteR
#'
#' @importFrom ape cophenetic.phylo
#' @examples
#' imputation(imputation)
#' @export

setup_completer <- function(){
  message("Loading reference information...")
  # Load tree
  reference_tree <- read_tree("data/reference_tree.tre")
  
  # Load reference metadata
  reference_kegg <- read_tsv("data/reference_kegg.tsv.xz", show_col_types = FALSE) %>% 
    filter(genome %in% reference_tree$tip.label)
  
  message("Preparing CompleteR reference database. This may take a while...")
  # Process reference tree
  keep.tip(reference_tree,tip=reference_kegg$genome) %>% 
    cophenetic.phylo() %>% 
    save(.,file="data/reference_tree.RData")
}