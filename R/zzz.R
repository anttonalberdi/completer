.onLoad <- function(libname, pkgname) {
  data_path <- file.path(system.file("exdata", package = "completer"), "completer_v1.RData")
  
  if (!file.exists(data_path)) {
    message("Reference data have not been downloaded yet. Run completer_setup() to get the library ready to run.")
  } else {
    load(data_path, envir = asNamespace(pkgname))
  }
}