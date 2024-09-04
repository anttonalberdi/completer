.onLoad <- function(libname, pkgname) {
  
  #Detect reference data
  data_path <- file.path(system.file("exdata", package = "completer"), "completer_v1.RData")
  
  if (!file.exists(data_path)) {
    message("Reference data have not been downloaded yet. Run setup_completer() to get the library ready to run.")
  } else {
    message("Loading reference data...")
    load(data_path, envir = .GlobalEnv)
  }
}