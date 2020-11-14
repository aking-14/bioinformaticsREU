# read reference genome
my $genome_file = shift;
my $genome_sequence = "";
open(FILE,$genome_file);
while(my $line = <FILE>)
{
	$line =~ s/[\r\n]//g;
	if($line =~ />/)
	{
		
	}
	else
	{
		$genome_sequence .= $line;
	}
}
close FILE;
print STDERR "Load genome sequence ready!\n";

# load protein CDS information
my $cds_info_file = shift;
my %cds_hash;
my $num = 1;
open(FILE,$cds_info_file);
while(my $line = <FILE>)
{
	$line =~ s/[\r\n]//g;
	my @tmp = split(/\t/,$line);
	$hash{$num}{'Gene'} = $tmp[0];
	$hash{$num}{'CDS_start'} = $tmp[1];
	$hash{$num}{'CDS_end'} = $tmp[2];
	$hash{$num}{'Protein'} = $tmp[3];
	$hash{$num}{'Protein_seq'} = $tmp[4];
	$num++;
}
close FILE;
print STDERR "Load CDS information ready!\n";

our %nt2aa = ('TTT'=>'F','TTC'=>'F','TTA'=>'L','TTG'=>'L','CTT'=>'L','CTC'=>'L','CTA'=>'L','CTG'=>'L','ATT'=>'I','ATC'=>'I','ATA'=>'I','ATG'=>'M','GTT'=>'V','GTC'=>'V','GTA'=>'V','GTG'=>'V','TCT'=>'S','TCC'=>'S','TCA'=>'S','TCG'=>'S','CCT'=>'P','CCC'=>'P','CCA'=>'P','CCG'=>'P','ACT'=>'T','ACC'=>'T','ACA'=>'T','ACG'=>'T','GCT'=>'A','GCC'=>'A','GCA'=>'A','GCG'=>'A','TAT'=>'Y','TAC'=>'Y','TAA'=>'Stop','TAG'=>'Stop','CAT'=>'H','CAC'=>'H','CAA'=>'Q','CAG'=>'Q','AAT'=>'N','AAC'=>'N','AAA'=>'K','AAG'=>'K','GAT'=>'D','GAC'=>'D','GAA'=>'E','GAG'=>'E','TGT'=>'C','TGC'=>'C','TGA'=>'Stop','TGG'=>'W','CGT'=>'R','CGC'=>'R','CGA'=>'R','CGG'=>'R','AGT'=>'S','AGC'=>'S','AGA'=>'R','AGG'=>'R','GGT'=>'G','GGC'=>'G','GGA'=>'G','GGG'=>'G');

#load wig file and process for each genome segment;

my $wig_file = shift;
our %result_hash;
# for each segment
for (my $i = 1; $i < $num; $i++) 
{
	%result_hash = ();
	my $str = process($wig_file,$hash{$i}{'CDS_start'},$hash{$i}{'CDS_end'},$hash{$i}{'Protein_seq'},$genome_sequence);
	print "Gene Name\t$hash{$i}{'Gene'}\t";
	print "Protein Name\t$hash{$i}{'Protein'}\t";
	print "CDS start\t$hash{$i}{'CDS_start'}\t";
	print "CDS end\t$hash{$i}{'CDS_end'}\n";
	print "position(genome)\t\tposition(CDS)\t\tcoverage\t\tref nt\tref num\tpoly nt\tpoly num\tref pattern\tpoly pattern\tposition (amino acid)\tref aa\tpoly aa\n";
	print $str;
}

sub process
{
	my $file_name = shift;
	my $cds_start = shift;
	my $cds_end = shift;
	my $protein_seq = shift;
	my $ref_seq = shift;

	my $out_str = "";

	print STDERR $file_name."\t".$cds_start."\t".$cds_end."\n";

	my $cutoff = 0.1;

	my $result_num = 1;

	open(FILE,$file_name) or die ("can not open $list\n");
	while(my $line = <FILE>)
	{
		$line =~ s/\n//;
		if($line =~ /^track/)
		{
			next;
		}
		elsif($line =~ /^#/)
		{
			next;
		}
		elsif($line =~ /variableStep\schrom=([^\s]+)\s.+/)
		{
			next;
		}
		elsif($line =~ /^\d+/)
		{
			if($line =~ /^(\d+)\t(\d+)\.0\t(\d+)\.0\t(\d+)\.0\t(\d+)\.0.+/)
			{
				my $pos = $1;
				my $a = $2;
				my $c = $3;
				my $g = $4;
				my $t = $5;

				if(($pos >= $cds_start)&&($pos <= $cds_end))
				{
					
					my $cov = $a + $c + $g + $t;
					my %cov_hash = ('A'=>$a, 'C'=>$c, 'G'=>$g, 'T'=>$t);
					my @arr = ($a,$c,$g,$t);
					my @nt = ('A','C','G','T');

					my $num = 0;
					my $ref_nt = substr($ref_seq,$pos - 1,1);
					my $poly_nt = "";
					my $ref_num = 0;
					my $poly_num = 0;
					my $large_per = 0;
					for (my $i = 0; $i < 4; $i++) 
					{
						my $per = $arr[$i]/$cov;
						if($per > $cutoff)
						{
							$num++;
							if($nt[$i] ne $ref_nt)
							{
								if($per >= $large_per)
								{
									$poly_nt = $nt[$i];
									$poly_num = $arr[$i];
									$large_per = $per;
								}
							}
						}
						if($nt[$i] eq $ref_nt)
						{
							$ref_num = $arr[$i];
							if($per < 0.5)
							{
								$num++;
							}
						}

					}
					if($num > 1)
					{
						print STDERR "$pos\n";
						$cds_pos = $pos - $cds_start + 1;
						my $aa_pos = int($cds_pos/3);

						my $yu = $cds_pos%3;
						if($yu == 0)
						{
							$yu = 2;
						}
						elsif($yu == 1)
						{
							$yu = 0;
							$aa_pos += 1;
						}
						else
						{
							$yu = 1;
							$aa_pos += 1;
						}
						my $ref_pattern = substr($ref_seq,($aa_pos - 1)*3 + $cds_start - 1,3);
						my $poly_pattern = $ref_pattern;
						substr($poly_pattern,$yu,1) = $poly_nt;
						my $pos_cds = $pos - $cds_start + 1;
						$out_str .= "$pos\t$pos_cds\t$cov\t$ref_nt\t$ref_num\t$poly_nt\t$poly_num\t$ref_pattern\t$poly_pattern\t$aa_pos\t$nt2aa{$ref_pattern}\t$nt2aa{$poly_pattern}\t";
						if($nt2aa{$ref_pattern} eq $nt2aa{$poly_pattern})
						{
							$out_str .= "Same\n";
						}
						else
						{
							$out_str .= "Diff\n";
						}
					}
				}
				$result_num++;			
			}
			else
			{
				print "error\n";
			}
		}
		else
		{
			print "error1\n";
		}
	}
	close FILE;

	return $out_str;
}
