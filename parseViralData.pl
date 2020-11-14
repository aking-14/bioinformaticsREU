#!/usr/bin/perl
#use strict;
use List::Util qw(min max);

my $data_folder_name = "";
opendir(my $dh, $data_folder_name) || die "Can't open $some_dir: $!";
my @files = grep ! /^\./, readdir $dh;
closedir $dh;
foreach(@files)
{
	my $total_rows = "cd $_; fn=$_.txt; total_rows=\$(awk 'END{print NR}' \$fn); echo \$total_rows; cd ..";
	if(`$total_rows` > 3){
		my $tissue = substr($_, -4);
		my $tissue_namess = substr($_, 0, -5);
		my $counter = 4;
		if($tissue eq "L001"){
			while($counter <= `$total_rows`){ #if name and L001,2,3,4 at bottom subtract 2 from total_rows for each condition
				my $cmd = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue=\$(awk 'NR=='\$num_rows'{print \$4}' \$fn); echo \$tissue; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; echo $tissue_namess,\$first_num,\$cov,\$pos,,,,,,,,,,\$aa,\$out,,,,,,, >>~/Desktop/test_libre.csv; cd ..";
				print `$cmd`;
				$counter = $counter + 1;
			}	
		}
	}
}
foreach(@files)
{
	my $total_rows = "cd $_; fn=$_.txt; total_rows=\$(awk 'END{print NR}' \$fn); echo \$total_rows; cd ..";
	if(`$total_rows` > 3){
		my $tissue = substr($_, -4);
		if($tissue eq "L002"){
			my $counter = 4;
			while($counter <= `$total_rows`){
				my $tissue_nam = substr($_, 0, -5);
				my $con = "_L001"; # Will just work for L002
				my $new_con = $tissue_nam . $con; # To check min values in L001
				my $vvv = "cd $_; fn='$_.txt'; first_num=\$(awk 'NR==5{print \$1}' \$fn); echo \$first_num";
				my $vv = `$vvv`;
				my $awkPos = "cd $_; fn='$_.txt'; counter=$counter; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cd ..";
				my $value= `$awkPos`;
				my $test = "cd $_; val='$value'; awk -v pos=\$val 'BEGIN{max=0}{if(\$2 > max && \$2 < pos) max=\$2} END{print max}' $_.txt"; #Min value of row FIGURE OUT WAY TO TAKE MIN VALUE IN TEST LIBRE DOC
				my $test_two = "cd $new_con; val='$value'; awk -v pos=\$val 'BEGIN{max=0}{if(\$2 > max && \$2 < pos) max=\$2} END{print max}' $new_con.txt; cd ..";
				$test = max(`$test`,`$test_two`);
				print "$test";
				my $name = "r='$tissue_nam'; awkPos=`$awkPos`; awk -v r=\$r -v pos=\$awkPos -F, '{if(\$1 ~ r && \$2 ~ pos) print NR}' ~/Desktop/test_libre.csv";
				print `$name`;				
				my $name_print = `$name`;
				if(`$name` ne ""){
					my $cmd3 = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue='$tissue_nam'; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; comma=','; insert_row='$name_print'; insert_value=\$first_num; awk -v comma=\$comma -v r=\$insert_row -v c=5 -v val=\$insert_value 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=6 -v val=\$cov 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=7 -v val=\"\$pos\" 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=16 -v val=\$aa 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=17 -v val=\"\$out\" 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; cd ..";					
					print `$cmd3`;
				}
				if(`$name` eq ""){
					my $nam = "r='$tissue_nam'; min_value='$test'; awk -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && \$2 ~ pos) print NR+1}' ~/Desktop/test_libre.csv";
					my $nam2 = "r='$tissue_nam'; min_value='$test'; awk -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && \$5 ~ pos) print NR+1}' ~/Desktop/test_libre.csv";
					print `$nam`;
					print `$nam2`;
					$name_print = "";
					if(`$nam` ne "" || `$nam2` ne ""){
						if(`$nam` ne ""){
							$name_print = `$nam`;
						}else{
							$name_print = `$nam2`;
						}
						#print "$name_print";
						my $cmd4 = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue='$tissue_nam'; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; comma=','; insert_row='$name_print'; insert_value=\$first_num; awk -v r=\$insert_row -v c=22 -v comma=\$comma -v new_line=\"\n\" 'BEGIN{FS=OFS=comma} NR==r{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=1 -v comma=\$comma -v new_line=\",,,,,,,,,,,,,,,,,,,,,\" 'BEGIN{FS=OFS=comma} NR==r+1{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=22 -v comma=\$comma -v new_line=\"\n\" 'BEGIN{FS=OFS=comma} NR==r+1{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=1 -v comma=\$comma -v new_line=\",,,,,,,,,,,,,,,,,,,,,\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=5 -v val=\$insert_value 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=6 -v val=\$cov 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=7 -v val=\"\$pos\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=16 -v val=\$aa 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=17 -v val=\"\$out\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=1 -v val=\"\$tissue\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=22 -v comma=\$comma -v new_line=\"\n\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=1 -v comma=\$comma -v new_line=\",,,,,,,,,,,,,,,,,,,,,\" 'BEGIN{FS=OFS=comma} NR==r+3{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; cd ..";				
						print `$cmd4`;
					}
					if($name_print eq ""){
						#my $na = "r='$tissue_nam'; min_value='$test'; low_num='$vv'; awk -v low_num=\$low_num -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && pos == 0 && \$2 ~ low_num) print NR-3}' ~/Desktop/test_libre.csv";
						#$name_print = `$na`;
						my $cmd2 = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue='$tissue_nam'; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; echo \$tissue,,,,\$first_num,\$cov,\$pos,,,,,,,,,\$aa,\$out,,,,, >>~/Desktop/test_libre.csv; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; cd ..";
						print `$cmd2`;
					}	
				}
				$counter = $counter + 1;
			}			
		}
	}
}
foreach(@files)
{
	my $total_rows = "cd $_; fn=$_.txt; total_rows=\$(awk 'END{print NR}' \$fn); echo \$total_rows; cd ..";
	if(`$total_rows` > 3){
		my $tissue = substr($_, -4);
		if($tissue eq "L003"){
			my $counter = 4;
			while($counter <= `$total_rows`){
				my $tissue_nam = substr($_, 0, -5);
				my $con = "_L001";
				my $con2 = "_L002";
				my $new_con = $tissue_nam . $con; 
				my $new_con_two = $tissue_nam . $con2;
				my $vvv = "cd $_; fn='$_.txt'; first_num=\$(awk 'NR==5{print \$1}' \$fn); echo \$first_num";
				my $vv = `$vvv`;
				my $awkPos = "cd $_; fn='$_.txt'; counter=$counter; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cd ..";
				my $value= `$awkPos`;
				my $test = "cd $_; val='$value'; awk -v pos=\$val 'BEGIN{max=0}{if(\$2 > max && \$2 < pos) max=\$2} END{print max}' $_.txt"; #Min value of row
				my $test_two = "cd $new_con; val='$value'; awk -v pos=\$val 'BEGIN{max=0}{if(\$2 > max && \$2 < pos) max=\$2} END{print max}' $new_con.txt; cd ..";
				my $test_three = "cd $new_con_two; val='$value'; awk -v pos=\$val 'BEGIN{max=0}{if(\$2 > max && \$2 < pos) max=\$2} END{print max}' $new_con_two.txt; cd ..";				
				$test = max(`$test`,`$test_two`, `$test_three`);
				print "$test";
				print `$awkPos`;
				my $name = "r='$tissue_nam'; awkPos=`$awkPos`; awk -v r=\$r -v pos=\$awkPos -F, '{if(\$1 ~ r && \$2 ~ pos) print NR}' ~/Desktop/test_libre.csv";
				my $name2 = "r='$tissue_nam'; awkPos=`$awkPos`; awk -v r=\$r -v pos=\$awkPos -F, '{if(\$1 ~ r && \$5 ~ pos) print NR}' ~/Desktop/test_libre.csv";
				print "Name for L003: ";
				print `$name`;
				print "Name2 for L003: ";
				print `$name2`;	
				my $name_print = "";
				if(`$name` ne "" || `$name2` ne ""){
					if(`$name` ne ""){
						$name_print = `$name`;
					}else{
						$name_print = `$name2`;
					}
					my $cmd3 = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue=$tissue_nam; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; comma=','; insert_row='$name_print'; insert_value=\$first_num; awk -v comma=\$comma -v r=\$insert_row -v c=8 -v val=\$insert_value 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=9 -v val=\$cov 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=10 -v val=\"\$pos\" 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=18 -v val=\$aa 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=19 -v val=\"\$out\" 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; cd ..";					
					print `$cmd3`;
				}
				if($name_print eq ""){
					my $nam = "r='$tissue_nam'; min_value='$test'; awk -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && \$2 ~ pos) print NR+1}' ~/Desktop/test_libre.csv";
					my $nam2 = "r='$tissue_nam'; min_value='$test'; awk -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && \$5 ~ pos) print NR+1}' ~/Desktop/test_libre.csv";
					my $nam3 = "r='$tissue_nam'; min_value='$test'; awk -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && \$8 ~ pos) print NR+1}' ~/Desktop/test_libre.csv"; 
					$name_print = "";
					if(`$nam` ne "" || `$nam2` ne "" || `$nam3` ne ""){
						if(`$nam` ne ""){
							$name_print = `$nam`;
						}elsif(`$nam2` ne ""){
							$name_print = `$nam2`;
						}else{
							$name_print = `$nam3`;
						}
						my $cmd4 = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue=$tissue_nam; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; comma=','; insert_row='$name_print'; insert_value=\$first_num; awk -v r=\$insert_row -v c=22 -v comma=\$comma -v new_line=\"\n\" 'BEGIN{FS=OFS=comma} NR==r{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=1 -v comma=\$comma -v new_line=\",,,,,,,,,,,,,,,,,,,,,\" 'BEGIN{FS=OFS=comma} NR==r+1{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=22 -v comma=\$comma -v new_line=\"\n\" 'BEGIN{FS=OFS=comma} NR==r+1{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=1 -v comma=\$comma -v new_line=\",,,,,,,,,,,,,,,,,,,,,\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=8 -v val=\$insert_value 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=9 -v val=\$cov 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=10 -v val=\"\$pos\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=18 -v val=\$aa 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=19 -v val=\"\$out\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=1 -v val=\"\$tissue\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=22 -v comma=\$comma -v new_line=\"\n\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=1 -v comma=\$comma -v new_line=\",,,,,,,,,,,,,,,,,,,,,\" 'BEGIN{FS=OFS=comma} NR==r+3{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; cd ..";				
						print `$cmd4`;
					}
					if($name_print eq ""){
						my $cmd2 = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue=$tissue_nam; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; echo \$tissue,,,,,,,\$first_num,\$cov,\$pos,,,,,,,,\$aa,\$out,,, >>~/Desktop/test_libre.csv; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; cd ..";
						print `$cmd2`;
					}	
				}
				$counter = $counter + 1;
			}			
		}
	}
}
foreach(@files)
{
	my $total_rows = "cd $_; fn=$_.txt; total_rows=\$(awk 'END{print NR}' \$fn); echo \$total_rows; cd ..";
	if(`$total_rows` > 3){
		my $tissue = substr($_, -4);
		if($tissue eq "L004"){
			my $counter = 4;
			while($counter <= `$total_rows`){
				my $tissue_nam = substr($_, 0, -5);
				my $con = "_L001";
				my $con2 = "_L002";
				my $con3 = "_L003";
				my $new_con = $tissue_nam . $con; 
				my $new_con_two = $tissue_nam . $con2;
				my $new_con_three = $tissue_nam . $con3;
				my $vvv = "cd $_; fn='$_.txt'; first_num=\$(awk 'NR==5{print \$1}' \$fn); echo \$first_num";
				my $vv = `$vvv`;
				my $awkPos = "cd $_; fn='$_.txt'; counter=$counter; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cd ..";
				my $value= `$awkPos`;
				my $test = "cd $_; val='$value'; awk -v pos=\$val 'BEGIN{max=0}{if(\$2 > max && \$2 < pos) max=\$2} END{print max}' $_.txt"; #Min value of row
				my $test_two = "cd $new_con; val='$value'; awk -v pos=\$val 'BEGIN{max=0}{if(\$2 > max && \$2 < pos) max=\$2} END{print max}' $new_con.txt; cd ..";
				my $test_three = "cd $new_con_two; val='$value'; awk -v pos=\$val 'BEGIN{max=0}{if(\$2 > max && \$2 < pos) max=\$2} END{print max}' $new_con_two.txt; cd ..";				
				my $test_four = "cd $new_con_three; val='$value'; awk -v pos=\$val 'BEGIN{max=0}{if(\$2 > max && \$2 < pos) max=\$2} END{print max}' $new_con_three.txt; cd ..";				
				$test = max(`$test`,`$test_two`, `$test_three`, `$test_four`);			
				my $name = "r='$tissue_nam'; awkPos=`$awkPos`; awk -v r=\$r -v pos=\$awkPos -F, '{if(\$1 ~ r && \$2 ~ pos) print NR}' ~/Desktop/test_libre.csv";
				my $name2 = "r='$tissue_nam'; awkPos=`$awkPos`; awk -v r=\$r -v pos=\$awkPos -F, '{if(\$1 ~ r && \$5 ~ pos) print NR}' ~/Desktop/test_libre.csv"; 
				my $name3 = "r='$tissue_nam'; awkPos=`$awkPos`; awk -v r=\$r -v pos=\$awkPos -F, '{if(\$1 ~ r && \$8 ~ pos) print NR}' ~/Desktop/test_libre.csv"; 
				print "Name for L004: ";
				print `$name`;
				print "Name2 for L004: ";
				print `$name2`;	
				print "Name3 for L004: ";
				print `$name3`;
				my $name_print = "";
				if(`$name` ne "" || `$name2` ne "" || `$name3` ne ""){
					if(`$name` ne ""){
						$name_print = `$name`;
					}elsif(`$name2` ne ""){
						$name_print = `$name2`;
					}else{
						$name_print = `$name3`;
					}
					my $cmd3 = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue=\$(awk 'NR=='\$num_rows'{print \$4}' \$fn); echo \$tissue; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; comma=','; insert_row='$name_print'; insert_value=\$first_num; awk -v comma=\$comma -v r=\$insert_row -v c=11 -v val=\$insert_value 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=12 -v val=\$cov 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=13 -v val=\"\$pos\" 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=20 -v val=\$aa 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=21 -v val=\"\$out\" 'BEGIN{FS=OFS=comma} NR==r{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; cd ..";					
					print `$cmd3`;
				}
				if($name_print eq ""){
					my $nam = "r='$tissue_nam'; min_value='$test'; awk -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && \$2 ~ pos) print NR+1}' ~/Desktop/test_libre.csv";
					my $nam2 = "r='$tissue_nam'; min_value='$test'; awk -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && \$5 ~ pos) print NR+1}' ~/Desktop/test_libre.csv";
					my $nam3 = "r='$tissue_nam'; min_value='$test'; awk -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && \$8 ~ pos) print NR+1}' ~/Desktop/test_libre.csv";
					my $nam4 = "r='$tissue_nam'; min_value='$test'; awk -v r=\$r -v pos=\$min_value -F, '{if(\$1 ~ r && \$11 ~ pos) print NR+1}' ~/Desktop/test_libre.csv";
					$name_print = "";
					if(`$nam` ne "" || `$nam2` ne "" || `$nam3` ne "" || `$nam4` ne ""){
						if(`$nam` ne ""){
							$name_print = `$nam`;
						}elsif(`$nam2` ne ""){
							$name_print = `$nam2`;
						}elsif(`$nam3` ne ""){
							$name_print = `$nam3`;
						}else{
							$name_print = `$nam4`;
						}
						my $cmd4 = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue=$tissue_nam; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; comma=','; insert_row='$name_print'; insert_value=\$first_num; awk -v r=\$insert_row -v c=22 -v comma=\$comma -v new_line=\"\n\" 'BEGIN{FS=OFS=comma} NR==r{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=1 -v comma=\$comma -v new_line=\",,,,,,,,,,,,,,,,,,,,,\" 'BEGIN{FS=OFS=comma} NR==r+1{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=22 -v comma=\$comma -v new_line=\"\n\" 'BEGIN{FS=OFS=comma} NR==r+1{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=1 -v comma=\$comma -v new_line=\",,,,,,,,,,,,,,,,,,,,,\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=11 -v val=\$insert_value 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=12 -v val=\$cov 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=13 -v val=\"\$pos\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=20 -v val=\$aa 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=21 -v val=\"\$out\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v comma=\$comma -v r=\$insert_row -v c=1 -v val=\"\$tissue\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=val} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=22 -v comma=\$comma -v new_line=\"\n\" 'BEGIN{FS=OFS=comma} NR==r+2{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; awk -v r=\$insert_row -v c=1 -v comma=\$comma -v new_line=\",,,,,,,,,,,,,,,,,,,,,\" 'BEGIN{FS=OFS=comma} NR==r+3{\$c=new_line} 1' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv; cd ..";				
						print `$cmd4`;
					}
					if($name_print eq ""){
						my $cmd2 = "cd $_; fn=$_.txt; counter=$counter; num_rows=\$(awk 'END{print NR}' \$fn); num_rows=\$((\$num_rows-1)); tissue=$tissue_nam; echo \$tissue; first_num=\$(awk -v r=\$counter 'NR==r{print \$1}' \$fn); echo \$first_num; cov=\$(awk -v r=\$counter 'NR==r{print \$3}' \$fn); echo \$cov; ref_nt=\$(awk -v r=\$counter 'NR==r{print \$4}' \$fn); poly_nt=\$(awk -v r=\$counter 'NR==r{print \$6}' \$fn); ref_num=\$(awk -v r=\$counter 'NR==r{print \$5}' \$fn);  poly_num=\$(awk -v r=\$counter 'NR==r{print \$7}' \$fn); pos=\"\$ref_nt/\$poly_nt (\$ref_num|\$poly_num)\"; echo \$pos; aa=\$(awk -v r=\$counter 'NR==r{print \$10}' \$fn); echo \$aa; ref_aa=\$(awk -v r=\$counter 'NR==r{print \$11}' \$fn); poly_aa=\$(awk -v r=\$counter 'NR==r{print \$12}' \$fn); variance=\$(awk -v r=\$counter 'NR==r{print \$13}' \$fn); out=\"\$ref_aa/\$poly_aa (\$variance)\"; echo \$out; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; echo \$tissue,,,,,,,,,,\$first_num,\$cov,\$pos,,,,,,,\$aa,\$out, >>~/Desktop/test_libre.csv; echo ,,,,,,,,,,,,,,,,,,,,, >>~/Desktop/test_libre.csv; cd ..";
						print `$cmd2`;
					}	
				}
				$counter = $counter + 1;
			}			
		}
	}
}
my $final_command = "awk -F, '{if (\$0!=\",,,,,,,,,,,,,,,,,,,,,\") {print}}' ~/Desktop/test_libre.csv > ~/Desktop/temp.csv && mv ~/Desktop/temp.csv ~/Desktop/test_libre.csv";
print `$final_command`;
my $real_final_command = "cd ..; libreoffice --headless --convert-to ods ~/Desktop/test_libre.csv";
print `$real_final_command`;

#Program that takes desired data from a text file, and inserts it into the correct order in a csv file, then converts the csv file into a ods (libre office spreedsheet file for easy viewing) data_folder_name is file where data is located 


	
