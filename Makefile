all:Bacillus_complete.txt Bacillus_complete_ftp_addresses.txt \
	BacillusGenomesComplete BacillusGenomesComplete/GCA_000015065.1_ASM1506v1 \
	Bacillus_incomplete.txt Bacillus_incomplete_ftp_addresses.txt \
	BacillusGenomesInComplete BacillusGenomesInComplete/GCA_000833655.1_ASM83365v1/ \
	complete_complete incomplete_incomplete Bacillus_PhaME/ref/GCA_000832605.1_ASM83260v1_genomic.gff.gz

Bacillus_complete.txt:Bacillus_LANL.txt
	grep "Complete Genome" $< > $@

Bacillus_complete_ftp_addresses.txt:Bacillus_complete.txt
	@echo "Extracting column with FTP addresses"
	awk -F'\t' '{ print $$20 }' $< | sed 's/$$/\//g' > $@

BacillusGenomesComplete:
	@echo "Creating folder for downloading genomes"
	mkdir -p $@

BacillusGenomesComplete/GCA_000015065.1_ASM1506v1:scripts/dload.R Bacillus_complete_ftp_addresses.txt
	@echo "Downloading complete genomes as listed in  *.txt file"
	Rscript $< -i $(word 2, $^) -o BacillusGenomesComplete

Bacillus_incomplete.txt:Bacillus_LANL.txt
	grep "Contig\|Scaffold\|Chromosome" $< > $@

Bacillus_incomplete_ftp_addresses.txt:Bacillus_incomplete.txt
	@echo "Extracting column with FTP addresses"
	awk -F'\t' '{ print $$20 }' $< | sed 's/$$/\//g' > $@

BacillusGenomesInComplete:
	@echo "Creating folder for downloading incomplete genomes"
	mkdir -p $@

BacillusGenomesInComplete/GCA_000833655.1_ASM83365v1/:scripts/dload.R Bacillus_incomplete_ftp_addresses.txt
	@echo "Downloading complete genomes as listed in  *.txt file"
	Rscript $< -i $(word 2, $^) -o BacillusGenomesInComplete

complete_complete:
	mkdir -p Bacillus_PhaME/ref
	find BacillusGenomesComplete -name '*_genomic.fna.gz'| grep -v "from" > complete.txt
	rsync -av --files-from=complete.txt . Bacillus_PhaME/ref/
	find Bacillus_PhaME/ref -iname "*.gz" -exec cp {} Bacillus_PhaME/ref/ \;
	rm -rf Bacillus_PhaME/ref/BacillusGenomesComplete
	find Bacillus_PhaME/ref -iname "*.gz" -exec gzip -d {} \;
	touch $@

incomplete_incomplete:
	find BacillusGenomesInComplete -name '*_genomic.fna.gz' | grep -v "from" > incomplete.txt
	rsync -av --files-from=incomplete.txt . Bacillus_PhaME/
	find Bacillus_PhaME/ -iname "*.gz" -exec cp {} Bacillus_PhaME/ \;
	rm -rf Bacillus_PhaME/BacillusGenomesInComplete
	find Bacillus_PhaME -iname "*.gz" -exec gzip -d {} \;
	touch $@

Bacillus_PhaME/ref/GCA_000832605.1_ASM83260v1_genomic.gff:BacillusGenomesComplete/GCA_000832605.1_ASM83260v1/GCA_000832605.1_ASM83260v1_genomic.gff.gz
	 cp $< Bacillus_PhaME/ref/
	 gzip -d Bacillus_PhaME/ref/GCA_000832605.1_ASM83260v1_genomic.gff.gz

