#!/usr/bin/env bash
# Run in a Lifebit TERMINAL (not a notebook cell):
#     bash /home/jovyan/session_data/Attempt0/setup_endotypes_env.sh
# Put endotypes.yml in the same folder as this script first.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
ENVDIR=/home/jovyan/envs/endotypes        # lives in your home dir, so the shared env is untouched

# use mamba if present (much faster), otherwise conda
if command -v mamba >/dev/null 2>&1; then PM=mamba; else PM=conda; fi
echo "Using $PM"

$PM env create -p "$ENVDIR" -f "$HERE/endotypes.yml" -y

# register BOTH kernels so they show up in the notebook "Select Kernel" menu
"$ENVDIR/bin/Rscript" -e 'IRkernel::installspec(name = "endotypes-r", displayname = "R (endotypes)")'
"$ENVDIR/bin/python" -m ipykernel install --user --name endotypes-py --display-name "Python (endotypes)"

# quick self-test: every package the notebooks call
"$ENVDIR/bin/Rscript" -e 'for (p in c("GEOquery","Biobase","limma","edgeR","sva","data.table","readxl","illuminaHumanv4.db","BiocManager")) cat(sprintf("%-20s %s\n", p, if (requireNamespace(p, quietly=TRUE)) "OK" else "MISSING"))'
"$ENVDIR/bin/python" -c "import pandas, numpy, matplotlib, openpyxl; print('python libs OK')"
echo "Done. Refresh the browser, then pick 'R (endotypes)' or 'Python (endotypes)' as the kernel."
