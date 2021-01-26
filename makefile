DATA_DIR = $(HOME)/data/dust-metagenome
FASTA ?= $(DATA_DIR)/virus-identification/virsorter/virsorter-all.fasta
OUTDIR ?= $(DATA_DIR)/taxonomy/functional/diamond-blastx/refseq-virsorter
DB ?= $(HOME)/db/diamond/refseq_prot_viral.dmnd

diamond:
	mkdir -p $(OUTDIR)
	diamond blastx --threads 20 -b12 -c1 --max-target-seqs 500 --query-cover 0.5 \
		--out $(OUTDIR)/diamond-output.tsv --query $(FASTA) --db $(DB)

summary:
	cut -f2 $(OUTDIR)/diamond-output.tsv | sort | uniq -c | sort -rnk1 | awk '{print $$2"\t"$$1}' > $(OUTDIR)/proteins.tsv

genbank:
	cut -f1 $(OUTDIR)/proteins.tsv > /tmp/proteins.txt
	nextflow run nf-convert-ids -entry genbank --accessions /tmp/proteins.txt --outdir $(OUTDIR) --chunks 1000

lineage:
	cut -f1 $(OUTDIR)/proteins.tsv > /tmp/proteins.txt
	nextflow run nf-convert-ids -entry lineage --accessions /tmp/proteins.txt --outdir $(OUTDIR) --chunks 1000
