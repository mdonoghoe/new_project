cache
================

ProjectTemplate requires a `cache` directory in order to create a project, where it stores derived datasets and output. I don't use it for that purpose (I prefer `data/derived` and `output`), and instead use it as the `targets` store: this is set in `lib/prep_targets.R`.
