#' Prepare reference data for CompleteR
#'
#' @importFrom curl curl_download
#' @export

setup_completer <- function(){
  message("Downloading 5.6GBs of reference data.")
  message("  This will take a while...")
  data_path <- file.path(system.file("exdata", package = "completer"), "data.RData")
  curl::curl_download("https://sid.erda.dk/share_redirect/H9VSThONVr/data.RData",data_path, quiet = FALSE)
  message("  Download finished succesfully. Loading objects to environment.")
  load(data_path, envir = .GlobalEnv)
}

  
