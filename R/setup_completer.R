#' Prepare reference data for CompleteR
#'
#' @importFrom curl curl_download
#' @export

setup_completer <- function(){
  message("Downloading a large data file. This will take a while...")
  data_path <- file.path(system.file("exdata", package = "completer"), "data.RData")
  curl::curl_download("https://sid.erda.dk/share_redirect/H9VSThONVr/data.RData",data_path)
  load(data_path, envir = .GlobalEnv)
}

  
