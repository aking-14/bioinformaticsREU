# Bioinformatics Scripts with Data
* pipeline.pl is a perl script that will run multiple bioinformatics software programs (bowtie2, FastQC, Trimmomatic, samtools) to detect and output sections of cattle DNA that have viral mutations.
* parseViralData.pl is another perl script that grabs sections of the cattle DNA raw data that contain viral mutations and outputs them to test_libre.csv and test_libre.ods files for eaiser analysis and grouping.
* The Samples folder is where the raw data is located that is parsed by the parseViralData.pl script.