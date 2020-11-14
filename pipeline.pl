#use strict;

my $data_path = "";
my $data_folder_name = "data";
my $reference_folder_name = "reference";
my $working_folder_name = "working";
my $bin_folder_name = "";




###################################################
##      reference genome building
###################################################
my $reference_folder_name = $data_path."/".$reference_folder_name;
$reference_folder_name =~ s/\/\//\//g;

opendir(my $dh, $reference_folder_name) || die "Can't open $some_dir: $!";
while (readdir $dh) 
{
	if($_ =~ /.fasta$/)
	{
		print STDERR "Binding reference genome index ...\n";
		my $cmd = "cd $reference_folder_name; mv $_ Ref_DB.fas";
		`$cmd`;
		my $cmd = "cd $reference_folder_name; bowtie2-build Ref_DB.fas Ref_DB";
		`$cmd`;
		print STDERR "Buind reference genome index finished\n";
	}
}

my $refdb = $reference_folder_name."/"."Ref_DB";



###################################################
##      input data read
###################################################
my $data_folder_name = $data_path."/".$data_folder_name;
$data_folder_name =~ s/\/\//\//g;

my %sample_hash;

opendir(my $dh, $data_folder_name) || die "Can't open $some_dir: $!";
while (readdir $dh) 
{
	if($_ =~ /\.fastq/)
	{
		#print "$data_path"."$_\n";
		my $file = $_;
		my $id = $file;
		$id =~ s/_R\d.+//;
		if($file =~ /_R1/)
		{
			$hash{$id}{1} = $file;
		}
		elsif($file =~ /_R2/)
		{
			$hash{$id}{2} = $file;
		}
	}
}
closedir $dh;

## test
=pod
foreach (keys %hash)
{
	print STDERR $_."\t".$hash{$_}{1}."\t".$hash{$_}{2}."\n";
}
=cut


###################################################
##      setup working dir
###################################################
my $working_folder_name = $data_path."/".$working_folder_name;
$working_folder_name =~ s/\/\//\//g;
if(!-e $working_folder_name)
{
	mkdir($working_folder_name);
}

###################################################
##      start process
###################################################

foreach (keys %hash)
{
	print STDERR "Start process $_ ... \n";

	my $cur_folder = $working_folder_name."/".$_;
	#mkdir($cur_folder);

	my $original_read1 = $data_folder_name."/".$hash{$_}{1};
	my $original_read2 = $data_folder_name."/".$hash{$_}{2};

	#### step 1    FastQC test
	print STDERR "######################\nStart FastQC test ... \n######################\n";
	my $fastqc_path = $bin_folder_name."/FastQC/fastqc";
	my $cmd = "$fastqc_path $original_read1 $original_read2 -o $cur_folder";
	#`$cmd`;
	print STDERR "######################\nFinish FastQC test. \n######################\n";

	#### step 2    Quality trimming 
	print STDERR "######################\nStart Quality trimming  ... \n######################\n";
	my $read1_trim = "reads_trim_1.fastq";
	my $read2_trim = "reads_trim_2.fastq";
	my $read1_trim_up = "reads_trim_1up.fastq";
	my $read2_trim_up = "reads_trim_2up.fastq";
	my $read_up = "reads_up.fastq";

	my $trimmer_path = $bin_folder_name."/Trimmomatic/Trimmomatic.jar";
	my $cmd = "cd $cur_folder; java -jar $trimmer_path PE -phred33 $original_read1 $original_read2 $read1_trim $read1_trim_up $read2_trim $read2_trim_up LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:50 1> trim_log.txt";
	#`$cmd`;
	#	$cmd = "cd $cur_folder; cat $read1_trim_up $read2_trim_up > $read_up";
	#	print STDERR $cmd."\n";
	#	`$cmd`;
	print STDERR "######################\nFinish Quality trimming . \n######################\n";

	#### step 3    Bowtie2
	print STDERR "######################\nStart Bowtie2 ... \n######################\n";
	my $cmd = "cd $cur_folder; bowtie2 --local -q -x $refdb -1 $read1_trim  -2 $read2_trim -S Mapping.sam ";;
	#`$cmd`;
	print STDERR "######################\nFinish Bowtie2. \n######################\n";

	##### step 3    sam to bam
	my $bam = "out.bam";
	$cmd = "cd $cur_folder; samtools view -Sb Mapping.sam > $bam";
	`$cmd`;

	##### step 4    sort bam
	my $sort_bam = "sort.bam";
	$cmd = "cd $cur_folder; samtools sort -O bam -T sample.sort -o $sort_bam $bam";
	`$cmd`;

	##### step 5    index bam
	$cmd = "cd $cur_folder; samtools index $sort_bam";
	`$cmd`;
}










































