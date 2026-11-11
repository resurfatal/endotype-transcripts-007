# What each notebook writes, and what each file is for

Everything below is written under `/home/jovyan/session_data/Attempt0/endotype_results/rnaseq_out_v2/` (`OUT` below). All files are CSV (plus two `.md` logs and one `.csv.gz`). Plots are shown inside the notebook and are not saved.

**Privacy note.** Files marked ⚠ contain sample names, patient initials or enrollment IDs. Keep them on Lifebit; do not paste them into chat or email. The notebooks themselves print only counts and group names.

**Which files to actually look at.** Marked ★. The others are inputs for the next notebook, or backup detail.

---

## 02 · `02_NIH_bulk_RNA_seq_make_facility_csvs` (Python)

Goal: split the Goldbach-Mansky workbook into one file per sequencing facility, and add each healthy control to the facility it was sequenced at.

| file (in `OUT/facility_csv/`) | what it is | use it for |
|---|---|---|
| `BCM-HGSC.csv`, `NCI-FNL.csv`, `NIAID-NCI.csv`, `NIAMS.csv` | One per facility. Top 9 rows = sample information (diagnosis, treatment, facility, cohort...), then one row per gene with raw counts. Columns = samples. | Input to notebook 03 only. You never analyse these directly. |
| ★ `facility_csv_summary.csv` | One row per facility: patients in the tab, healthy controls added, total samples, number of genes. | **Check:** compare these totals with what notebook 03 prints in its Part 4. If they differ, something was lost. |

---

## 03 · `03_NIH_bulk_RNA_seq_parse_metadata` (Python)

Goal: choose which samples are usable (whole blood, enough reads, not post-treatment, one per patient), attach patient information, and convert counts to RPKM and TPM.

| file (in `OUT/`) | what it is | use it for |
|---|---|---|
| `rnaseq_counts_raw.csv` | Raw gene counts, **one sample per patient** (genes × samples). Columns: `Gene_ID` (Ensembl, with version), `Gene_Name`, then one column per sample. | Input to later notebooks. Counts are whole numbers. ⚠ column names are sample names. |
| `rnaseq_counts_raw_eligible.csv` | Same, but **all eligible samples** (a patient can appear more than once). | The main input for 04, 04b and 05 (they pick one-per-patient or use all of them). ⚠ |
| `rnaseq_counts_all_samples.csv.gz` | Raw counts of every sample that had counts, even excluded ones (compressed). | Backup only. |
| `gene_lengths.csv` | Length of each gene in base pairs (from GENCODE). | Needed to turn counts into RPKM/TPM. Reused on re-runs so it is not downloaded again. |
| `rnaseq_rpkm.csv`, `rnaseq_tpm.csv` | Counts divided by gene length and library size (RPKM), or rescaled so every sample sums to 1,000,000 (TPM). One sample per patient. | Looking at expression levels; the JDM-lab data are also RPKM, so this is the like-for-like version. **Not** for statistics. |
| ★ `rnaseq_samples.csv` | One row per kept sample (one per patient): `sample_id`, `patient_key`, `dx_clean` (diagnosis), `batch` (facility; NIAMS split by cohort), `facility`, `tx_status` (pre/post/unlabelled), `sex`, `age_yrs`, `total_counts`, and how the patient was matched to metadata (`meta_join`). | The sample sheet that goes with `rnaseq_counts_raw.csv`. ⚠ |
| `rnaseq_samples_eligible.csv` | Same columns for **all eligible** samples, plus `one_per_patient` (True/False). | The sample sheet that goes with `rnaseq_counts_raw_eligible.csv`. Notebooks 04, 04b, 05, 06, 07 all read it. ⚠ |
| ★ `rnaseq_samples_ALL_with_flags.csv` | Every sample read, with `status` saying what happened to it (`kept`, `post-treatment`, `not whole blood`, `library below minimum`, `no patient ID`, `eligible, not the chosen sample of this patient`...). | **Answers "why is sample X missing?"** ⚠ (has enrollment IDs and initials) |
| ★ `unmatched_or_weak_metadata.csv` | Kept samples whose patient could not be matched firmly to the metadata sheet (no enrollment ID match). | A to-do list: fix these IDs at the source, then re-run 03. ⚠ |
| ★ `batch_by_diagnosis_eligible.csv` | Table: rows = batches (facilities), columns = diagnoses, cells = number of samples, plus `n_diagnoses`. | **The most important table for batch correction.** A batch with `n_diagnoses = 1` cannot be separated from that diagnosis. 04b reads the same idea. |
| `PROCESSING_LOG_notebook03.md` | Text log: files read, rules applied in order, how many samples survived each rule, the batch-by-diagnosis table. | A record to keep or paste into a methods section. |

---

## 04 · `04_NIH_bulk_RNA_seq_batch_PCA_ComBatSeq` (R)

Goal: check whether samples cluster by facility instead of by disease, and remove the facility shift from the counts (RGM data only, JDM not included yet).

| file (in `OUT/batch_correction/`) | what it is | use it for |
|---|---|---|
| ★ `counts_combatseq_eligible.csv` | Counts after ComBat-seq, all eligible samples (`Gene_ID`, `Gene_Name`, samples). Whole numbers, facility shift removed, diagnosis protected. | **Display and clustering only** (notebooks 04b, 06, 07 read it). Never for statistical tests. |
| `counts_combatseq_one_per_patient.csv` | Same, one sample per patient. | Same use, when you want each person once. |
| `pca_before.csv`, `pca_after.csv` | The first 5 PCA coordinates (`PC1`...`PC5`) of every sample before and after correction, with its `batch` and `diagnosis`. ⚠ | Re-drawing the PCA yourself in another tool. |
| ★ `variance_explained_by_batch_and_diagnosis.csv` | 4 rows (before/after × batch/diagnosis) with how much of PC1 and PC2 each explains (0 to 1). | The numbers behind "did it work": **batch should fall, diagnosis should stay**. |

---

## 04b · `04b_NIH_JDM_batch_correction_all_sources` (R) **new**

Goal: put the four facilities **and** the JDM lab on one scale, and prove the correction did not erase the biology.

| file (in `OUT/all_sources_correction/`) | what it is | use it for |
|---|---|---|
| ★ `source_by_diagnosis.csv` | Rows = the 7 sources (BCM-HGSC, NCI-FNL, NIAID-NCI, NIAMS cohorts, JDM-lab), columns = diagnoses, cells = number of samples. | The picture of your whole dataset. Read this first. |
| ★ `source_verdicts.csv` | One row per source: samples, healthy controls (`HC`), diagnoses held, `verdict` (`OK`, `CANNOT BE CORRECTED`, `TOO SMALL`, `NOT LINKED TO THE OTHER SOURCES`), what its shift is measured from, and `what_it_means` in words. | Tells you which sources made it into the corrected table and why any did not. |
| ★ `excluded_samples.csv` | Every sample not in the corrected table, with `source` and `reason` (JDM-lab label neither JDM nor HC, same library or same person as an RGM sample, or its whole source was left out). ⚠ | **Answers "where did my sample go?"** |
| ★ `corrected_log2_all_sources.csv` | The result: genes (by gene symbol, column `gene`) × samples, log2 values after correction, all usable sources on one scale. | Plots, clustering, heatmaps. **Not** statistical tests. ⚠ column names are sample names. |
| `corrected_samples.csv` | One row per column of the table above: `sample_id`, `diagnosis` (HC, AGS, CANDLE, SAVI, UAID, JDM...), `source`, `lab` (RGM or JDM lab), `patient_key`. | The sample sheet for the corrected table. ⚠ |
| ★ `variance_explained_by_stage.csv` | For three stages (1 uncorrected, 2 facilities corrected, 3 facilities + JDM corrected): how much of PC1, PC2, PC3 is explained by `source` and by `diagnosis`. | **Proof 6a:** `source` rows should fall from stage 1 to 3, `diagnosis` rows should stay. |
| ★ `checks_signal_genes.csv` | Per disease, for the 28 interferon genes (`IFN_28`) and the 11 NF-κB control genes (`NFkB_11`): `within_source_effect` (the true size, measured inside each source against its own healthy controls), `pooled_before`, `pooled_after`, and a `verdict`. | **Proof 6b:** every `IFN_28` row should say `PASS`. `FAIL` means the correction erased interferon signal, so do not use the table. |
| `checks_shared_disease.csv` | For each disease found in two sources: how similar its fingerprint is between them (`rho_reference` from the uncorrected data, `rho_after` after correction), and `PASS`/`CHECK`. May be empty if no disease sits in two sources. | **Proof 6c.** An empty file is not an error; it means that check cannot be run on your data. |
| `PROCESSING_LOG_all_sources.md` | Text log: settings used, source verdicts, variance table, interferon checks. | A record to keep. |

---

## 05 · `05_NIH_bulk_RNA_seq_differential_expression` (R)

Goal: which genes differ between each disease and healthy, and between diseases. Uses **raw counts** with facility as a term in the model (the correct way to test).

| file (in `OUT/differential_expression/`) | what it is | use it for |
|---|---|---|
| ★ `summary_comparisons.csv` | One row per comparison: group sizes, `batches_with_both_groups`, how many genes pass the cut-offs (adjusted p < 0.05 and at least 2-fold), up and down, and a `note`. | The overview. A comparison with `batches_with_both_groups = 0` is marked `CONFOUNDED WITH BATCH`: do not read it as a disease effect. |
| `de_<A>_vs_<B>.csv`, e.g. `de_CANDLE_vs_HC.csv` | **Every gene** for that comparison: `gene_id`, `gene_name`, `logFC` (log2 fold change; positive = higher in the first-named group), `AveExpr`, `t`, `P.Value`, `adj.P.Val`, `B`. One file per pair of diagnoses. | The full result. 06 and 07 read the `..._vs_HC.csv` ones. |
| ★ `top_genes_<A>_vs_<B>.csv` | Only the genes that pass the cut-offs (`gene_id`, `gene_name`, `logFC`, `AveExpr`, `adj.P.Val`), smallest p first. | The gene lists you would actually read or report. Look for interferon genes (IFI27, IFI44L, ISG15, RSAD2, MX1) in the disease-vs-HC lists. |

---

## 06 · `06_NIH_bulk_RNA_seq_clusters_heatmaps` (R)

Goal: heatmaps of the top genes and sample groups, using the facility-corrected counts from 04.

| file (in `OUT/clusters/`) | what it is | use it for |
|---|---|---|
| ★ `sample_clusters.csv` | Each sample's cluster number (the sample tree cut into `K_CLUSTERS` groups) with its `diagnosis` and `batch`. ⚠ | **Check:** a cluster that is mostly one diagnosis is disease-driven; mostly one batch means batch still drives it. |
| `genes_used_for_clustering.csv` | The genes in the all-samples heatmap (`gene_id`, `gene_name`). | Knowing exactly what the clusters were built from. |
| ★ `ifn_score_by_diagnosis.csv` | For each diagnosis: number of samples and the median interferon score (mean z-score of the 28 interferon genes). | Healthy controls should be lowest; CANDLE, SAVI, AGS, UAID higher. |

---

## 07 · `07_NIH_bulk_RNA_seq_JDM_comparison` (R)

Goal: compare JDM with each RGM disease, each measured against **its own lab's** healthy controls, so the lab difference never enters.

| file (in `OUT/jdm_comparison/`) | what it is | use it for |
|---|---|---|
| `de_JDM_vs_HC_jdm_lab.csv` | JDM against the JDM lab's healthy controls, every gene (`logFC`, `adj.P.Val`, `gene_name`...). | The JDM equivalent of the `de_..._vs_HC.csv` files from 05. |
| ★ `comparison_summary.csv` | One row per RGM disease: genes compared, `rank_correlation_logFC` (do JDM and that disease change the same genes in the same direction? near 1 = yes, near 0 = no), top genes on each side, how many are shared, how many go the same way. | **The headline result:** how alike JDM is to CANDLE, SAVI, AGS, UAID. |
| `compare_JDM_vs_<disease>.csv` | Gene-by-gene side by side: `logFC_nih`, `adj.P.Val_nih`, `logFC_jdm`, `adj.P.Val_jdm`, and `ifn_gene` (TRUE for the 28 interferon genes). | The detail behind the summary and the scatter plots. |
| ★ `comparison_without_ifn_genes.csv` | Same as `comparison_summary.csv` but with the 28 interferon genes removed: `rho_all_genes`, `rho_without_ifn`, and a `reading` (`holds without interferon genes` / `mostly interferon` / `no similarity to begin with`). | Tells you whether JDM resembles a disease beyond the shared interferon signature. |
| ★ `ifn_score_by_group.csv` | Median interferon score per group (RGM diseases, both labs' healthy controls, JDM), each scored against its own lab's healthy controls. | Healthy groups of both labs should sit near 0; if they are far apart, read the rest with more care. |
| `sample_clusters_with_jdm.csv` | Cluster number of every sample (JDM included) with `group` and `lab`. ⚠ | JDM samples mixing with CANDLE/SAVI/UAID samples is the signal of interest; clusters split only by lab are not. |

---

## 08 · `08_SLE_GSE65391_vs_JDM_and_interferonopathies` (R)

Goal: compare childhood SLE (public array study GSE65391) with JDM and your diseases, each against its own healthy controls. Needs 001 to 003 (public array data), and 05 and 07.

| file (in `OUT/sle_comparison/`) | what it is | use it for |
|---|---|---|
| `de_SLE_vs_healthy_GSE65391.csv` | SLE (first visit, 157 children) against 46 healthy children, every gene (`logFC`, `adj.P.Val`, `gene_name`...). | The SLE equivalent of the `de_..._vs_HC.csv` files. |
| ★ `comparison_sle_vs_others.csv` | One row per disease (and JDM): genes compared, `rho_all_genes` (rank correlation of fold changes), `rho_without_ifn` (same without the 28 interferon genes), shared top genes, and a `reading`. | **The headline result:** does SLE share more with a disease than the interferon signature? |
| `compare_SLE_vs_<disease>.csv` | Gene by gene: `logFC_sle`, `adj.P.Val_sle`, `logFC_other`, `adj.P.Val_other`, `ifn_gene`. | The detail behind the summary and the scatter plots. |
| ★ `ifn_score_sle.csv` | Median interferon score of SLE and of the array's healthy children. | SLE should sit above healthy. |
| `PROCESSING_LOG_sle.md` | Text log of settings and the two tables. | A record to keep. |

---

## 09 · `09_WGCNA_RGM_and_JDM_modules` (R)

Goal: find groups of genes that move together (modules) in your RNA-seq data and in the JDM lab, and see which modules appear in both. Files go to `OUT/wgcna/`. `<study>` is `RGM` or `JDM`.

| file | what it is | use it for |
|---|---|---|
| `<study>/power_fit.csv` | Scale-free fit and mean connectivity for each power tried. | Shows why the power was chosen. |
| `<study>/module_genes.csv` | Every gene in a module: `gene`, `module` (colour name), `kME` (its correlation with the module's eigengene; high = hub gene). | The module membership lists. Grey genes are in no module and are not listed. |
| ★ `<study>/module_summary.csv` | One row per module: size, interferon genes inside it, the diagnosis it is most linked to (`strongest_diagnosis`, `r_with_it`, `adj_p`), `max_abs_r_batch`, top hub genes, and a `flag` of `batch?` where the batch link beats every diagnosis link. | **Start here.** One line per module. A `batch?` module is probably technical. |
| `<study>/module_trait.csv` | Every module against every trait: each diagnosis, `IFN_score`, and (RGM only) each sequencing batch, with `r`, `p`, `adj_p`. | The full table behind the summary. |
| ★ `<study>/ifn_module.csv` | The module holding most of the 28 interferon genes, how many are in it, and how many of the 11 NF-kB control genes fell into it. | The control: NF-kB genes should not be in the interferon module. |
| ★ `preservation_RGM_modules_in_JDM.csv`, `preservation_JDM_modules_in_RGM.csv` | For each module of one study: do its genes also hang together in the other? `mean_cor`, `prop_var_PC1`, their Z scores, and a `reading` (`none`, `weak to moderate`, `strong`). | A `strong` module is reproduced across labs. |
| ★ `module_overlap_RGM_JDM.csv` | Which RGM module matches which JDM module: genes shared, hypergeometric `adj_p`, and `involves_ifn_module`. | Colour names differ between studies; this is the translation table. |
| `PROCESSING_LOG_wgcna.md` | Text log of settings and the tables above. | A record to keep. |

---

## The order in one line

02 → 03 → 04 → **04b** → 05 → 06 → 07 → 08 → 09. Each notebook reads the previous ones' files, so if one fails, nothing after it can run.
