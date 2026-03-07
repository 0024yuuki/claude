#!/bin/bash
# SessionStart - Inject environment info and reference tables
# Only runs at session start, not every message

CONTEXT="## Environment Reference

### Conda Environments
- Shared (read-only): /home/condauser/miniforge3/envs/ (QIIME2, antiSMASH, MetaPhlAn, CheckM, GTDB-Tk, etc.)
- Personal: /home/yuki0024/conda_local/my_env (Python 3.10, BioPython, pandas, numpy)
- Personal conda: ~/.conda/envs/ (bigscape, clinker, gemini)

### Tool Wrappers
/home/yuki0024/packages/ contains: kraken2, Bracken, CAT, orthofinder, antismashv7, seqkit, R utilities, SGE submission scripts

### File Formats Reference
| Tool | Output | Key Columns |
|------|--------|-------------|
| QUAST | report.tsv | Assembly, N50, L50, # contigs |
| CheckM | results | UID, taxon, completeness, contamination |
| GTDB-Tk | bac120.summary.tsv | classification_method, taxonomy |
| BLAST | .blastn.genome.out | query, subject, identity(%), length, e-value |
| Kraken2 | .txt reports | percentage, reads, taxonomy path |
| Prokka | .gff, .faa | CDS, gene name, product |

### Data Flow
Input (fastq/fasta) -> Taxonomy (Kraken2->Bracken) -> Quality (QUAST/CheckM) -> Annotation (Prokka->OrthoFinder->KEGG) -> BGC (antiSMASH->BiG-SCAPE/BiGSLICE) -> Visualization (R/Rmarkdown->HTML)"

ESCAPED=$(echo "$CONTEXT" | jq -Rs .)
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":${ESCAPED}}}"

exit 0
