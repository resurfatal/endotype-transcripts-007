# endotype-transcripts-007

Tanisha's copy of the method in Anne Deslattes Mays' repository (NIH-NLM/endotypes-transcriptomics), applied to the internal RNA-seq data (RGM: four sequencing facilities) and the JDM-lab data, run on Lifebit.

## Start here

**What changed in this folder compared with what you gave me**

- **New: `ipynb/04b_NIH_JDM_batch_correction_all_sources.ipynb`.** Puts the four facilities and the JDM lab on one scale, says which sources can and cannot be corrected, and checks that the correction did not erase the interferon signal.
- **Edited: `ipynb/07_NIH_bulk_RNA_seq_JDM_comparison.ipynb`.** Its old section 4 (the pooled ComBat view) moved into 04b. Nothing else in 07 changed.
- **Everything else is byte-for-byte what you uploaded** (01 to 06, 001 to 006, `paths.R`, the six gene lists, the environment files). So 02, 03, 04, 05 and 06 do not need to be re-run if they already ran.

**To run 04b you need:** notebooks 02, 03 and 04 finished (04b reads their files), the JDM files on `/mnt/file-systems/` (`4b_rpkm.csv`, `jdm-HC RNASEQ sample ID.csv`), and the `genes/` folder at `/home/jovyan/session_data/endotype-transcripts-007/genes` (the same place 06 and 07 already read it from). Kernel: R (WGCNA), the same one you used for 04.

**Getting the two files onto Lifebit.** Upload `04b_...ipynb` and `07_...ipynb` next to your other notebooks. If you would rather re-clone the GitHub repo as in your old README, note that re-cloning replaces the notebooks in the cloned folder, so any outputs saved inside the notebooks are lost. The CSV results are written to `/home/jovyan/session_data/Attempt0/endotype_results/`, outside the repository, and are not touched.

## The order

| step | notebook | language | what it does | writes (in `endotype_results/rnaseq_out_v2/`) |
|---|---|---|---|---|
| 1 | `02_…make_facility_csvs` | Python | each facility tab to its own CSV, healthy controls added to the facility they were sequenced at | `facility_csv/` |
| 2 | `03_…parse_metadata` | Python | whole blood, library size, patient metadata, drops post-treatment, one sample per patient | counts, sample sheets, `batch_by_diagnosis_eligible.csv` |
| 3 | `04_…batch_PCA_ComBatSeq` | R | the four facilities corrected with ComBat-seq on counts (RGM only) | `batch_correction/` |
| 4 | **`04b_…all_sources`** | R | **RGM + JDM lab on one scale, with proof** | `all_sources_correction/` |
| 5 | `05_…differential_expression` | R | each disease against healthy, limma-voom, raw counts, batch as a model term | `differential_expression/` |
| 6 | `06_…clusters_heatmaps` | R | heatmaps and sample groups (RGM) | `clusters/` |
| 7 | `07_…JDM_comparison` | R | JDM against each RGM disease, each against its own lab's healthy controls | `jdm_comparison/` |

`01_NanoString…` and `001` to `006` (the public GSE65391 and GSE232381 sets) are independent of this chain; the public sets come back in when the SLE comparison is added.

## How to read 04b in three questions

1. **Part 4: which sources can be corrected?** A source can be corrected when it holds healthy controls, or a disease, that another source also holds. That shared group is the ruler its shift is measured from. A source holding one diagnosis found nowhere else cannot be corrected by any method, because "this source" and "this disease" are the same thing. Such sources are left out of the combined table, listed with the reason, and never silently included.
2. **Part 6a: did the source pattern fall?** The share of the main patterns explained by *source* should drop from stage 1 to stage 3, while the share explained by *diagnosis* stays.
3. **Part 6b and 6c: is the biology still there?** The interferon genes must still be up in CANDLE, SAVI, AGS, UAID and JDM after correction (6b), and a disease found in two sources must give the same fingerprint in both (6c). The last cell prints a SUMMARY with PASS or CHECK for each.

## How this maps to Anne's repository

| here | Anne's notebook | note |
|---|---|---|
| 02, 03, 04 | 40 | reading the four facility files, ComBat-seq on counts |
| 05 | 41, 46 | limma-voom, patient as block, batch in the design |
| 06 | 42 | heatmaps of top genes, interferon genes, Ward trees |
| 07 | 46, 46b | each disease against its own healthy controls |
| **04b** | **48, 49** | Anne tried to remove the lab difference with control genes (RUVg) and concluded that no setting works, because each lab held one kind of sample. 04b therefore anchors on the healthy controls that the sources really share, and reuses her **positive and negative controls** (28 interferon genes up, 11 NF-κB genes unchanged) as pass or fail checks. |
| not yet | 12 to 15c | WGCNA, see below |
| not yet | 06c, 48 | SLE comparisons, see below |

## Not built yet, and the plan

**SLE comparisons.** Anne's lesson (notebooks 46, 48, 49) is that pooling SLE with the internal diseases and "correcting" the lab does not work when SLE sits in different labs from everything else. The plan is the same as for JDM: put SLE and each disease against **its own lab's healthy controls** (GSE65391 has 46 healthy children, GSE69529 has 43, GSE232381 has none), and compare the lists and the interferon scores, not pooled values.

**WGCNA.** Anne builds one network **per study**, then asks whether one study's modules exist in another (her 15 and 26 for preservation, 15b and 26b for projection). The plan is the same: one network on the RGM data (after notebook 04), one on the JDM-lab data, then preservation between them and projection of the GSE65391 modules. Her settings are signed network, power from the scale-free rule (FAQ value if no power reaches R² 0.90), `minModuleSize` 30, `mergeCutHeight` 0.25, `maxBlockSize` 5000, genes with fewer than 10 counts in more than 90% of samples removed, PFlog1pPF normalisation. The pooled table from 04b is for plots, not for building the network.

## Folder layout

```
README.md          this file
ipynb/             notebooks (run in the order above)
src/paths.R        where files live on Lifebit (your cloud version)
genes/             the six gene lists (28 interferon response genes and subsets, NF-kB controls, 6-gene score)
env/               endotypes.yml and setup_endotypes_env.sh (unchanged)
```

Results never go into this folder: they are written to `/home/jovyan/session_data/Attempt0/endotype_results/`.
