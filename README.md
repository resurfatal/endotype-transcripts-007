# endotype-transcripts-007

Tanisha's copy of the method in Anne Deslattes Mays' repository (NIH-NLM/endotypes-transcriptomics), applied to the internal RNA-seq data (RGM: four sequencing facilities) and the JDM-lab data, run on Lifebit.

## Start here

**Status (2026-11-11).** Notebooks 02 to 08 have been written. 02 to 07 have been run on Lifebit; 08 ran and its results are summarised below. 09 (WGCNA) ran and its results are summarised below; 10 (second SLE study) is written and has not been run yet.

**What is different from Anne's repository and from the files first uploaded:**

- **New: `04b_NIH_JDM_batch_correction_all_sources`.** Puts the four facilities and the JDM lab on one scale, says which sources can and cannot be corrected, and checks that the correction did not erase the interferon signal.
- **New: `10_SLE_GSE135779_vs_JDM_and_interferonopathies`.** The second SLE study (GSE135779), compared with every disease, JDM and the first SLE study. Before running it, put the by-hand supplement `41590_2020_743_MOESM3_ESM.xlsx` in `/home/jovyan/session_data/Attempt0/data/GSE135779/` (`mkdir -p` that folder first).
- **New: `09_WGCNA_RGM_and_JDM_modules`.** Gene modules per study, preservation between RGM and the JDM lab, a module-overlap table, and one plain-English verdict per module.
- **New: `08_SLE_GSE65391_vs_JDM_and_interferonopathies`.** SLE (public array GSE65391) against its own healthy children, compared with every disease and JDM.
- **Edited: `07`.** The pooled ComBat view moved into 04b. The JDM key sheet is no longer needed (the `Cohort` row of `4b_rpkm.csv` says JDM or healthy). Added section 1b (comparison without the 28 interferon genes). The heatmap draws one colour strip (this R's `heatmap()` takes only one).
- **Edited: `06`.** Same one-colour-strip heatmap fix.
- **Edited: `03`.** The Checkpoint 10 histogram no longer crashes (all TPM column sums are exactly 1,000,000).
- **Edited: `04b`.** Reads JDM or healthy from `4b_rpkm.csv` itself; no key sheet.
- Everything else is as uploaded (`01`, `02`, `04`, `05`, `001` to `006`, `paths.R`, the six gene lists, the environment files).

## Setup: the terminal commands, in order

Run these in a Lifebit **terminal** (not a notebook cell). Steps 1 to 3 are done once per Lifebit session; the environment from step 2 stays in your home folder.

**1. Put the folder in place and copy `paths.R`.** The folder must be at exactly `/home/jovyan/session_data/endotype-transcripts-007` (notebooks 04b, 06, 07 read the gene lists from there).

```bash
cd ~/session_data
ls endotype-transcripts-007            # should list: README.md ipynb src genes env
mkdir -p /home/jovyan/session_data/Attempt0/src
cp /home/jovyan/session_data/endotype-transcripts-007/src/paths.R /home/jovyan/session_data/Attempt0/src/
ls /home/jovyan/session_data/Attempt0/src/paths.R    # must print the path, not an error
```

**2. Build the environment** (R with limma, edgeR, sva, plus Python for notebooks 02 and 03). Takes several minutes; leave the terminal open until it prints "Done".

```bash
bash /home/jovyan/session_data/endotype-transcripts-007/env/setup_endotypes_env.sh
```

Every package line near the end should say `OK`. The environment is created at `/home/jovyan/envs/endotypes`. Do not use `conda install -p /home/jovyan/envs/wgcna ...`: that environment does not exist in the current Lifebit session.

**3. Check your input files are present.**

```bash
ls /mnt/file-systems | grep -i -E "Goldbach|HC_blood|MetadataPatients|4b_rpkm"
```

You need the Goldbach-Mansky workbook, `HC_blood_all_samples.xlsx`, `MetadataPatients_NoPHI.xlsx` and `4b_rpkm.csv`. (04b needs no JDM key sheet.)

**4. In the browser:** refresh the tab, then open each notebook and choose Kernel > Change Kernel:

| notebooks | kernel |
|---|---|
| 02, 03 | **Python (endotypes)** |
| 04, 04b, 05, 06, 07 | **R (endotypes)** (the notebooks say "R (WGCNA)" in their text; ignore that) |

Check R once, in a cell on the R kernel. All three must say `TRUE`:

```r
sapply(c("limma", "edgeR", "sva"), requireNamespace, quietly = TRUE)
```

**5. Run each notebook with Restart & Run All, in the order below.** Each reads the previous ones' files, so stop at the first error.

**Handy checks while you work** (terminal):

```bash
# what has been written so far
ls /home/jovyan/session_data/Attempt0/endotype_results/rnaseq_out_v2/
# did 04b finish? (should list 9 files)
ls /home/jovyan/session_data/Attempt0/endotype_results/rnaseq_out_v2/all_sources_correction/
# which kernels exist
jupyter kernelspec list
```

If something fails, copy the red error message and the cell it came from. For install problems, copy the last 30 lines of the terminal.

**Known harmless messages:** ComBat's "Found N batches / Standardizing Data" lines in 04b; and in 03 the Checkpoint 10 histogram error is already fixed in this folder's copy.

Every file each notebook writes, and what it is for, is listed in **`OUTPUTS.md`**.

## Run order

| step | notebook | language | what it does | writes (in `endotype_results/rnaseq_out_v2/`) |
|---|---|---|---|---|
| 1 | `02_…make_facility_csvs` | Python | each facility tab to its own CSV, healthy controls added to the facility they were sequenced at | `facility_csv/` |
| 2 | `03_…parse_metadata` | Python | whole blood, library size, patient metadata, drops post-treatment, one sample per patient | counts, sample sheets, `batch_by_diagnosis_eligible.csv` |
| 3 | `04_…batch_PCA_ComBatSeq` | R | the four facilities corrected with ComBat-seq on counts (RGM only) | `batch_correction/` |
| 4 | **`04b_…all_sources`** | R | **RGM + JDM lab on one scale, with proof** | `all_sources_correction/` |
| 5 | `05_…differential_expression` | R | each disease against healthy, limma-voom, raw counts, batch as a model term | `differential_expression/` |
| 6 | `06_…clusters_heatmaps` | R | heatmaps and sample groups (RGM) | `clusters/` |
| 7 | `07_…JDM_comparison` | R | JDM against each RGM disease, each against its own lab's healthy controls | `jdm_comparison/` |
| 8 | `08_SLE_GSE65391_vs_…` | R | SLE (public array GSE65391) against its own healthy children, then against every disease and JDM, with and without the interferon genes. Needs 001 to 003 first | `sle_comparison/` |
| 9 | `09_WGCNA_RGM_and_JDM_modules` | R | gene modules (WGCNA), one network for RGM and one for the JDM lab, then module preservation both ways and module overlap | `wgcna/` |
| 10 | `10_SLE_GSE135779_vs_JDM_and_…` | R | the second SLE study (single-cell PBMC as pseudobulk) against its own healthy children, then against every disease, JDM and the first SLE study. Downloads 1.3 GB on the first run; needs the by-hand supplement | `sle2_comparison/` |

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
| 10 | 20 to 22, 48 | the second SLE study: download, metadata, pseudobulk, SLE vs healthy with batch in the model |
| 09 | 12 to 15, 25 to 26 | WGCNA per study and module preservation (the array modules are not projected yet) |
| 08 | 06c, 48 | SLE against its own healthy children, then compared with the other diseases |

## Results so far (what the data said)

These are readings of the printed output, from notebooks that ran on Lifebit. They are not final conclusions.

- **04b, all-sources correction.** Six sources were corrected (JDM-lab, NCI-FNL, NIAID-NCI, NIAMS-Batch1, NIAMS-Batch2, NIAMS-unlabelled; 218 samples, 11,145 genes). **BCM-HGSC was left out**: it has only 8 samples (2 each of AGS, CANDLE, HC, SAVI), too few to measure its shift. Source explained 0.98 of PC1+PC2 before correction and 0.10 after. The interferon check passed for all 5 diseases (5 PASS, 0 FAIL) and the shared-disease check passed (5 PASS, 0 CHECK). The one CHECK was the crude 6a rule (diagnosis share fell 0.41 to 0.32 against a threshold of 0.33); source fell as intended and the other two checks passed, so it was treated as a false alarm.
- **07, JDM against each disease.** Rank correlation of fold changes: UAID 0.55, CANDLE 0.46, SAVI 0.35, AGS -0.32. Shared top genes all go in the same direction for CANDLE, SAVI and UAID. Interferon score (each against its own lab's healthy): JDM 0.76, against CANDLE 3.15, SAVI 3.13, UAID 2.49, AGS 1.60; healthy groups -0.15 and -0.33. Removing the 28 interferon genes removes about 26 genes from each shared list and leaves most of it (CANDLE 168 to 142, SAVI 154 to 129, UAID 130 to 104). The correlation barely moves because 28 genes are about 0.25% of the genes compared, so that column is a weak test.
- **08, SLE.** SLE against healthy (157 children with SLE, 46 healthy, 13,261 genes, 5,335 with adjusted p < 0.05) matches Anne's run on the same data (157, 46, 13,259, 5,335). Rank correlation with SLE: SAVI 0.46, UAID 0.44, JDM 0.40, CANDLE 0.37, AGS -0.23. These four positive values are close together and should not be ranked. SLE interferon score 2.75 against -0.29 for its healthy children (24 of 28 genes measured).
- **AGS.** `AGS_vs_HC` has 3 batches holding both groups (16 AGS, 62 healthy), so it is not a facility artefact. Its signal is weaker (88 genes up, 114 down at 2-fold) and it is negatively correlated with JDM and SLE. Unexplained; a cell-mix shift is one untested guess. Check: the `gene_name` column of `top_genes_AGS_vs_HC.csv`.
- **Small groups.** `AGS-like` (2 to 3 samples) and `CANDLE-like` (3) appear as their own diagnoses. Notebook 08 skips them by default.

- **09, WGCNA.** RGM network: 113 samples, 27,768 genes, power 12 (the WGCNA FAQ fallback: the scale-free fit never passed R-squared 0.75), 34 modules. JDM-lab network: 112 samples, 12,005 genes, power 12, 29 modules. **Interferon module** in both labs holds all 28 of the 28 interferon genes and none of the NF-kB control genes (RGM `grey60`, 386 genes, median kME 0.88; JDM `tan`, 256 genes, kME 0.91); the two modules share 183 genes (adjusted p about 2e-274), and the RGM one is strongly preserved in the JDM lab. Most other disease-linked RGM modules look like blood cell composition (hubs suggest neutrophil, monocyte, B-cell, eosinophil, NK/T) with modest links (|r| 0.2 to 0.5). Modules with a strong batch link (`steelblue` 0.90, `red` 0.66, `darkorange` 0.63, `orange` 0.50, `brown` 0.42) have mostly non-coding or pseudogene hubs and could not be tested or were not reproduced in the JDM lab, which supports calling them technical. The `batch?` flag in the summary is crude (15 of 34 flagged, many borderline); `module_verdicts_RGM.csv` uses a threshold of 0.4. 27 of 29 JDM modules are preserved in RGM; 8 of 34 RGM modules are strongly preserved, 13 weakly, 7 not, 6 untestable.

**Cautions that apply to all of the above.** Array and RNA-seq are never on one scale; only fold changes against each study's own healthy controls are compared, by rank and direction. A resemblance shared by SLE, JDM, CANDLE, SAVI and UAID may be a general blood signal (interferon, neutrophils) and not specific to any one disease. The corrected table from 04b is for plots and clustering, never for statistical tests.

## Not built yet, and the plan

**WGCNA (notebook 09)** is written, not yet run. It needs the package, installed with `conda install -y -p /home/jovyan/envs/endotypes -c conda-forge r-wgcna` (done), and the R kernel restarted. It follows Anne's notebooks 13 to 15: signed network, power from the scale-free rule (FAQ value if none reaches R-squared 0.90), `minModuleSize` 30, `mergeCutHeight` 0.25, `maxBlockSize` 5000, count filter and PFlog1pPF for the RGM counts. One network per study (RGM from the notebook-04 ComBat-seq counts; the JDM lab from log2 RPKM), then module preservation in both directions and a gene-overlap table that says which RGM module matches which JDM module. Her array modules (GSE65391) are not projected into your data yet.

**Optional side checks.** The broader interferon-gene test (remove the genes most correlated with the interferon score, then redo 07 and 08); the AGS gene-list check above; GSE69529 (43 healthy children) and GSE135779 (PBMC) as further SLE references.

## Folder layout

```
README.md          this file
ipynb/             notebooks (run in the order above)
src/paths.R        where files live on Lifebit (your cloud version)
genes/             the six gene lists (28 interferon response genes and subsets, NF-kB controls, 6-gene score)
env/               endotypes.yml and setup_endotypes_env.sh (unchanged)
```

Results never go into this folder: they are written to `/home/jovyan/session_data/Attempt0/endotype_results/`.
