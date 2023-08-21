source_folder <- function(folder) {

    lapply(list.files(folder, pattern = ".R", full.names = TRUE), source)

    return(invisible(NULL))
    
}