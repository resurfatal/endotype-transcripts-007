# endotype-transcripts-007

Setup, done once:

#### mkdir -p /home/jovyan/session_data/Attempt0/src
#### cp ~/session_data/endotype-transcripts-007/paths.R /home/jovyan/session_data/Attempt0/src/Upload paths.R 

## CHECK!!!
#### ls /home/jovyan/session_data/Attempt0/src/paths.R

## when i change data on github repo do this so it pulls the most recent data but the thing is it resets the progress ughhh
cd ~/session_data
rm -rf endotype-transcripts-007
git clone https://github.com/resurfatal/endotype-transcripts-007.git
# conda install -p /home/jovyan/envs/wgcna -c conda-forge -c bioconda bioconductor-geoquery bioconductor-biobase bioconductor-limma bioconductor-illuminahumanv4.db r-data.table r-readxl

basically switch to wgcna kernel within R
