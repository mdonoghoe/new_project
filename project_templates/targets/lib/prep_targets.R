projdir <- rprojroot::find_rstudio_root_file()
Sys.setenv(TAR_CONFIG = file.path(projdir, "config", "_targets.yaml"))
targets::tar_config_set(store = file.path(projdir, "cache"),
                        script = file.path(projdir, "src", "_targets.R"))
targets::tar_option_set(format = "rds")