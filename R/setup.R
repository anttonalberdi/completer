#' Prepare reference data for CompleteR
#'
#' @importFrom curl curl_download
#' @export

download_with_progress <- function(url, destfile) {
    curl::curl_download(url,destfile)
    cat("\nDownload complete!\n")
  }
  
download_and_load_data <- function() {
    
    data_path <- file.path(system.file("exdata", package = "completer"), "data.RData")
    
    if (!file.exists(data_path)) {
      message("Downloading large data file...")
      download_with_progress("https://sid.erda.dk/share_redirect/H9VSThONVr/data.RData", data_path)
    }
    message("Loading reference data to the environment")
    load(data_path, envir = .GlobalEnv)
  }
  
