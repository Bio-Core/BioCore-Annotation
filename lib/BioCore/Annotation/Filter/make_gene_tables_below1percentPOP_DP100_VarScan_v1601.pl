#!/usr/bin/perl
# Previously called hashgenematrix.pl and hashgenematrixcosmic.pl
#
# Creates two tables with samples (i.e. ANNOVAR files) as the rows and gene names as
# columns. Two files are produced in the input directory:
#
# - (dir_name).gene_table.txt
# - (dir_name).gene_table_onlyCOSMIC.txt
#     
# The files begin with a  list of protein changes and quality fields - every
# observation that passes a depth of coverage filter is listed, so there may be
# duplicates. The onlyCOSMIC output  also lists COSMIC IDs.
#
# The files have a tab-separated table where the rows are sample names and the
# columns are gene names. The entries in each table are every protein change
# reported for the gene, following the structure described on the web page:
# http://www.hgmd.cf.ac.uk/docs/mut_nom.html. The onlyCOSMIC output, perhaps
# unsurprisingly, includes only protein changes that correspond to COSMIC IDs.

use File::Basename;
use Data::Dumper;

%SAMPLEhash;
%GENENAMEhash;
%SAMPLENAMEhash;

# Filtering is performed on the DP field to make sure there is sufficient coverage.
$cov_threshold= 100;

$DIRECTORY=$ARGV[0];
opendir (DIR,$DIRECTORY) or die "Can't open input directory  $DIRECTORY";

# Name the output files
$dirname=basename($DIRECTORY);
$out=$DIRECTORY."/".$dirname.".gene_table-v1601.txt";
$cosmic_out=$DIRECTORY."/".$dirname.".gene_table_below1percentPOP_DP100_VarScan-v1601.txt";

open(OUT, ">", $out);
open(COSMIC_OUT, ">", $cosmic_out);

# Initialize the structure of the SAMPLEhash, which stores the names of all genes
# with mutations according to the structure {samplename}=>{genename}
while (defined($filename=readdir(DIR)))
{
	if ($filename=~/hg19_multianno\.txt/)
    {
        $filename=~/(.*)\.hg19_multianno\.txt/;
        $sample=$1;
        print "CONSOLE -- Sample name: $sample\n";
	    if (!($SAMPLENAMEhash{$sample})){
            $SAMPLENAMEhash{$sample}=1;
            }
	    
        $filepath = $DIRECTORY."/".$filename;
        open(FILEHANDLE, "<", $filepath) or die "Can't open file $filepath";
        $data=<FILEHANDLE>;

        while ($data=<FILEHANDLE>)
	    {
		    chomp $data;
		    if ($data=~/\r/) {chop $data;}
         	@fields=split("\t",$data);
            
            if (!(($fields[8]=~/^synonymous/)||($fields[8]=~/^unknown/)) && $fields[8])
            {
                $genename=$fields[6];
                if (!($GENENAMEhash{$genename})){ $GENENAMEhash{$genename}=1; }    
            }
        }
	}
}	

print Dumper(\%SAMPLENAMEhash);
print Dumper(\%GENENAMEhash);
exit;

foreach my $sample (sort keys %SAMPLENAMEhash)
{
    $flag=0;
    foreach my $genename (sort keys %GENENAMEhash)
    {
        $SAMPLEhash{$sample}{$genename}[0]=0;   # count of changes in all genes
        $SAMPLEhash{$sample}{$genename}[1]="|"; # protein changes in all genes
        $SAMPLEhash{$sample}{$genename}[2]="|"; # protein changes w/ COSMIC IDs
	$SAMPLEhash{$sample}{$genename}[3]=0; #count  changes w/ COSMIC IDs
    }
}
close($filename);
close(DIR);

# Print header for beginning of output file, which lists different protein changes
print OUT "ProteinChange\tmutationType\tDepthofCoverage\tQualityFields\n";
print COSMIC_OUT "ProteinChange\tmutationType\tCOSMICID\t1000gFreq\tExAC\tESP\tClinvar\tDepthofCoverage\tQualityFields\n";

# Read through the directory again, adding to the SAMPLEhash
opendir (DIR,$DIRECTORY) or die "Can't open input directory  $DIRECTORY";
while (defined($filename=readdir(DIR)))
{
	if ($filename=~/hg19_multianno\.txt/)
    {
        $filename=~/(.*)\.hg19_multianno\.txt/;
        $sample=$1;
            
        $filepath = $DIRECTORY."/".$filename;
        open(FILEHANDLE, "<", $filepath) or die "Can't open file $filepath";
        $data=<FILEHANDLE>;
        while ($data=<FILEHANDLE>)
        {
            chomp $data;
            if ($data=~/\r/) {chop $data;}
            @fields=split("\t",$data);
            
            if (!(($fields[8]=~/^synonymous/)||($fields[8]=~/^unknown/)) && $fields[8])
	    {
                @qfields=split(":",$fields[74]);
                $DP=$qfields[3];

                if($DP >= $cov_threshold)
                {
                    # Hash value is (chr):(start)-(end)|(refGene AA change)
                    $hashval=$fields[0].":".$fields[1]."-".$fields[2]."|".$fields[9];

                    # Split the refGene AA change field to retrieve just the protein change
                    $protein_change=(split /:/, $fields[9])[4];
                    if ($protein_change=~/,/)
                    {
                        @tempsplit=split(",",$protein_change);
                        $protein_change=$tempsplit[0];
                    }

                    # Add to list at beginning of file
                    if (!(($fields[19]>0.01)||($fields[25]>0.01)||($fields[33]>0.01))) {
                        print COSMIC_OUT $protein_change."\t".$fields[8]."\t".$cosmic."\t".$fields[19]."\t".$fields[25]."\t".$fields[33]."\t".$clinvar."\t".$DP."\t".$fields[74]."\n";
                    }
                    else {
                        print OUT $protein_change."\t".$fields[8]."\t".$DP."\t".$fields[74]."\n";
                    }

                    $genename=$fields[6];

                    # Store the number of protein changes seen in each sample per gene
                    if ($SAMPLEhash{$sample}{$genename}[0] == 0)
                    {	
                        $SAMPLEhash{$sample}{$genename}[0]=1;
                        $SAMPLEhash{$sample}{$genename}[1] .= $protein_change;	
                        if (!(($fields[19]>0.01)||($fields[25]>0.01)||($fields[33]>0.01))) {
                            $SAMPLEhash{$sample}{$genename}[2] .= $protein_change;
                        }
                    }
                    else 
                    {
                        $SAMPLEhash{$sample}{$genename}[0]++;

                        # Limit # of reported changes per sample/gene combination
                        if ($SAMPLEhash{$sample}{$genename}[0]<11)
                        {
                            $SAMPLEhash{$sample}{$genename}[1] .= "|".$protein_change;
			}
                        elsif ($SAMPLEhash{$sample}{$genename}[0]==11)
                            {
                                $SAMPLEhash{$sample}{$genename}[1] .= "|+more";
                            }
		    if ($SAMPLEhash{$sample}{$genename}[3]<11)
		    {
			    if (!(($fields[19]>0.01)||($fields[25]>0.01)||($fields[33]>0.01))) {
                                $SAMPLEhash{$sample}{$genename}[2] .= "|".$protein_change;
				$SAMPLEhash{$sample}{$genename}[3]++;
				if ($SAMPLEhash{$sample}{$genename}[3]==11)
				{
				    $SAMPLEhash{$sample}{$genename}[2] .= "|+more";
				}
                            }
                     }
                    }
                } # End DP threshold
            } # End not synonomous
         }
    }
} # End while loop on dir

# Print a tab-separated list of gene IDs, which will form the column names of
# the output tables
print OUT "\n\nSample\t";
print COSMIC_OUT "\n\nSample\t";
foreach my $genename (sort keys %GENENAMEhash)
{
	print OUT $genename,"\t";
	print COSMIC_OUT $genename,"\t";
}
print OUT "\n";
print COSMIC_OUT "\n";

foreach my $sample (sort keys %SAMPLEhash)
{
    print OUT $sample,"\t";
    print COSMIC_OUT $sample,"\t";
    foreach my $genename (sort keys %{$SAMPLEhash{$sample}})
    {
        print OUT $SAMPLEhash{$sample}{$genename}[1],"\t";
        print COSMIC_OUT $SAMPLEhash{$sample}{$genename}[2],"\t";
    }
    print OUT "\n";
    print COSMIC_OUT "\n";
}

close(OUT);
close(COSMIC_OUT);
