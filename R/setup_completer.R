#' Prepare reference data for CompleteR
#'
#' @importFrom curl curl_download
#' @export

setup_completer <- function(){
  
  # Detect reference data
  data_path <- file.path(system.file("exdata", package = "completer"), "completer_v1.RData")
  
  if (!file.exists(data_path)) {
      # Download and load reference data if does not exist.
      message("Downloading 493.4 MBs of reference data...")
      curl::curl_download("https://sid.erda.dk/share_redirect/H9VSThONVr/completer_v1.RData",data_path, quiet = FALSE)
      message(" Download finished succesfully. Loading objects to environment.")
      load(data_path, envir = .GlobalEnv)
  }else{
      # List required objects
      reference_data <- c("completer_genomes", "completer_tree", "completer_traits", "completer_distances")
      missing_objects <- sapply(reference_data, function(obj) !exists(obj))
      if (any(missing_objects)) {
          # Load reference data if not already loaded.
          message("Loading reference data...")
          load(data_path, envir = .GlobalEnv)
      }
  }
  
}

  
