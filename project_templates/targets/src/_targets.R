# Setup -------------------------------------------------------------------

# Do all of the setup work
# This also loads and configures the targets package
suppressMessages(ProjectTemplate::load.project())

# Project folders
projdir <- rprojroot::find_rstudio_root_file()
srcdir <- file.path(projdir, "src")
rawdatdir <- file.path(projdir, "data", "raw")
deriveddatdir <- file.path(projdir, "data", "derived")
reportdir <- file.path(projdir, "reports")

# Load the R scripts for data preparation and analysis
source_folder(file.path(srcdir, "data-prep"))
source_folder(file.path(srcdir, "analyses"))
source_folder(file.path(srcdir, "report"))

# Analysis parameters -----------------------------------------------------

# Target list -------------------------------------------------------------

list(

)