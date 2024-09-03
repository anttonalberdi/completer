#' Imputes gene annotations to incomplete genomes based on phylogenetic signal.
#'
#' @param traits Table containing presence/absence information of gene annotations (columns) across genomes (rows).
#' @param tree GTDB tree containing target and reference genomes. 
#' @param focal_genomes Optional vector of focal genomes to conduct imputation. If not provided, target genomes are inferred from the tree.
#' @param span Number of neighboring genomes to be employed for calculating the imputed values.
#' @param power Power value used when assigning weights to neighbor genomes (larger values assign larger weights to close neighbors)
#' @param threshold Relative threshold to assign a presence.
#' @param maxref Maximum number of references to keep in the user tree.
#' @return A table of imputed values and imputation statistics.
#' @import tidyverse
#' @importFrom ape cophenetic.phylo keep.tip drop.tip
#' @examples
#' completer(genome_traits,tree)
#' @export

completer <- function(traits, tree, focal_genomes, span=50, power=3, threshold=0.90, maxref=15000){
  
  ######
  # Handle tree
  ######
  
  user_tree <- tree
  
  # Clean tip labels, if they contain ''s
  user_tree$tip.label <- gsub("^'|'$", "", user_tree$tip.label)
  
  # Get tip labels from tree
  tip_labels <- user_tree$tip.label
  
  # Check if any tip label does not contain 'GB_' or 'RS_'
  if (!any(grepl("GB_|RS_|GCA_|GCF_", tip_labels))) {
    stop("Completer stopped because the phylogenetic tree does not contain GTDB genomes.")
  }
  
  # Get focal genomes
  if(missing(focal_genomes)){
    # If missing, predict focal genomes
    focal_genomes <- tip_labels[!grepl("^(GB_|RS_)", tip_labels)]
  }else{
    #If present, ensure it's a vector
    if(is.matrix(focal_genomes)){focal_genomes <- as.vector(focal_genomes)}
    if(is.data.frame(focal_genomes)){focal_genomes <- pull(focal_genomes)}
    if(is_tibble(focal_genomes)){focal_genomes <- pull(focal_genomes)}
  }
  
  # Once focal genomes are identified, remove 'GB_' and 'RS_' prefixes
  user_tree$tip.label <- str_remove(user_tree$tip.label, "^GB_|^RS_")
  
  # Get reference genomes
  reference_genomes <- scan("data/reference_genomes.txt", character(), quote = "", quiet=TRUE)
  tip_labels_in_reference <- user_tree$tip.label[user_tree$tip.label %in% reference_genomes]
  
  # Reduce references to 10,000 or the value indicated in maxref
  if(length(tip_labels_in_reference)>maxref){
    tip_labels_in_reference <- sample(tip_labels_in_reference, maxref, replace = FALSE)
  }
  
  # Prune user tree
  user_tree <- keep.tip(user_tree,tip=c(focal_genomes,tip_labels_in_reference))
  
  ######
  # Handle traits
  ######
  
  # User-imputed traits
  #user_traits <- lizard_traits[1,]
  user_traits <- traits
  
  # Check concordance between tree and traits
  if (!all(user_traits$genome %in% focal_genomes)) {
    warning("One or more genomes in the trait table are not present in the tree. Only the ones in the tree will be processed")
  }
  
  user_traits <- user_traits %>% 
    filter(genome %in% focal_genomes)
  
  # GTDB traits
  if (!exists("reference_traits")) {
    message("   Loading reference traits...")
    reference_traits <- read_tsv("data/reference_kegg.tsv.xz", show_col_types = FALSE)
  }
  
  # Combine traits
  traits <- bind_rows(user_traits,reference_traits)
  
  # Update focal genomes
  focal_genomes <- focal_genomes[focal_genomes %in% user_traits$genome]
  
  ######
  # Simplify identifiers
  ######
  # Often identifiers with non alphanumeric characters might interfere with the analyses.
  
  # Simplify tree tips
  user_tree$tip.label <- gsub("[^[:alnum:]_]", "", user_tree$tip.label)

  # Simplifytraits
  traits$genome <- gsub("[^[:alnum:]_]", "", traits$genome)
  
  # Simplify focal genomes
  focal_genomes <- gsub("[^[:alnum:]_]", "", focal_genomes)
  
  ######
  # Find references
  ######
  
  # Load reference tree
  reference_tree <- read_tree("data/reference_tree.tre")
  
  #Update GTDB traits 
  reference_traits <- reference_traits %>% 
      filter(genome %in% reference_tree$tip.label)
  
  # Prune reference tree
  reference_tree <- keep.tip(reference_tree,tip=reference_traits$genome)
  
  # Calculate tip distances of user tree
  message("   Calculating cophenetic distances among genomes...")
  user_tree_distances <- ape::cophenetic.phylo(user_tree)
  
  # Find closest reference
  closest_references <- c()
  for(genome in focal_genomes){
    closest_reference <- user_tree_distances[genome, ] %>% 
      t() %>% t() %>% 
      as.data.frame() %>% 
      rownames_to_column(var="genome") %>% 
      rename(distance=2) %>% 
      filter(genome %in% reference_tree$tip.label) %>% 
      arrange(distance) %>% 
      slice(1) %>% 
      mutate(genome=gsub("[^[:alnum:]_]", "", genome)) %>% 
      pull(genome)
    closest_references <- c(closest_references,closest_reference)
  }
  names(closest_references) <- focal_genomes
  
  # Distance to closest reference
  closest_reference_distances <- c()
  for(genome in focal_genomes){
    closest_reference_distance <- user_tree_distances[genome, ] %>% 
      t() %>% t() %>% 
      as.data.frame() %>% 
      rownames_to_column(var="genome") %>% 
      rename(distance=2) %>% 
      filter(genome %in% reference_tree$tip.label) %>% 
      arrange(distance) %>% 
      slice(1) %>% 
      pull(distance)
    closest_reference_distances <- c(closest_reference_distances,closest_reference_distance)
  }
  
  # Collect distances to closest reference
  reference_distance <- tibble(genome=focal_genomes,reference=closest_references,distance=round(closest_reference_distances,2))
  
  #Merge target and reference focal genomes
  focal_genomes2 <- tibble(target=focal_genomes,reference=closest_references) %>% 
    pmap(~ list(target = .x, reference = .y))
  
  # Calculate pairwise cophenetic distances between all tree tips
  # Required to apply span
  
  if (!exists("reference_tree_distances")) {
    message("   Loading tip distances...")
    load("data/reference_tree.RData")
  }
  
  tip_distances <- reference_tree_distances
  
  # Generate a list of focal trees (one per focal genome)
  message("   Generating focal trees...")
  focaltrees <- purrr::map(closest_references, ~getfocaltree(focal_tip = .x, 
                                              tip_distances = tip_distances, 
                                              tree = reference_tree, 
                                              span = span, 
                                              power = power))
  

  
  # Generate imputation across focal genomes using the focal trees
  message("   Conducting local imputation...")
  focalimput <- purrr::map2(focaltrees, focal_genomes2, ~imputer(traits = traits,
                                         focaltree = .x, 
                                         focal_genome = .y, 
                                         span = span, 
                                         power = power,
                                         threshold = threshold)) %>%
                set_names(focal_genomes)
  
  # Generate a list of focal trees (one per focal genome)
  focaltree_scope <- focaltrees %>%
    map2_dfr(names(focalimput), ~ {
      tibble(
        genome = .y,
        scope = round(mean(ape::cophenetic.phylo(.x)),3)
      )
    })
  
  # Generate imputation sensitivity estimates based on existing presences
  # i.e., percentage of presences recovered successfully in the imputation before the presence allocation
  sensitivity <- focalimput %>%
    map2_dfr(names(focalimput), ~ {
      tibble(
        genome = .y,
        sensitivity = round(impsens(.x),3)
      )
    })
  
  #Summarise imputation results in a table
  result <- focalimput %>%
    imap(~ .x %>%
           select(trait, learnt) %>%
           mutate(genome = .y)) %>%
    bind_rows() %>%
    group_by(trait, genome) %>% 
    summarize(learnt = first(learnt), .groups = 'drop') %>%
    pivot_wider(names_from = genome, values_from = learnt) 
  
  
  # Merge statistics
  statistics <- reference_distance %>% 
    left_join(focaltree_scope,by="genome") %>% 
    left_join(sensitivity,by="genome")
  
  # Generate final object
  return(list(imputation=result,statistics=statistics))
}
