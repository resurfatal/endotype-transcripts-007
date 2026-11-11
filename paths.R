# paths.R : where files live (version for the cloud hub).
# Save as  /home/jovyan/session_data/Attempt0/src/paths.R
# Notebooks 001-006 load it with:  source("/home/jovyan/session_data/Attempt0/src/paths.R")

ROOT <- "/home/jovyan/session_data/Attempt0"     # everything for this attempt lives under here
DATA <- file.path(ROOT, "data")                  # downloaded files:  data/<study>/<file>
NCBI <- file.path(DATA, "ncbi")                  # NCBI gene table shared by the studies
SEED <- 20260928                                 # random seed for any method that draws random numbers

# Folder of gene-list files (one symbol per line). Uses the repo's genes/ folder if it is there.
GENES <- c(file.path(ROOT, "genes"), "/home/jovyan/session_data/endotype-transcripts-007/genes")
GENES <- GENES[dir.exists(GENES)][1]

.in <- function(base, study, file) {             # make the folder if needed, return folder or file path
  d <- file.path(base, study)
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
  if (is.null(file)) d else file.path(d, file)
}
raw <- function(gse, file = NULL) .in(DATA, gse, file)                              # raw("GSE65391", "x.gz") -> .../data/GSE65391/x.gz
art <- function(gse, file = NULL) .in(file.path(DATA, "run_artifacts"), gse, file)  # results:  .../data/run_artifacts/GSE65391/x.rds
fig <- function(gse, file = NULL) .in(file.path(ROOT, "figures"), gse, file)        # figures:  .../figures/GSE65391/x.png

read_gene_set <- function(name) {                # lines starting with # are notes
  x <- trimws(readLines(file.path(GENES, name)))
  x[x != "" & !startsWith(x, "#")]
}

dir.create(NCBI, recursive = TRUE, showWarnings = FALSE)
