package BioCore::Annotation::Filter;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Basename;
use Data::Dumper;

=head1 NAME

BioCore::Annotation::Filter

=head1 SYNOPSIS

A Perl role for handling various filtering methods.

=head1 ATTRIBUTES AND DELEGATES

=cut

our %_annovar_index = (
    "Chr" => 0,
    "Start" => 1,
    "End" => 2,
    "Ref" => 3,
    "Alt" => 4,
    "Func.refGene" => 5,
    "Gene.refGene" => 6,
    "GeneDetail.refGene" => 7,
    "ExonicFunc.refGene" => 8,
    "AAChange.refGene" => 9,
    "Func.knownGene" => 10,
    "Gene.knownGene" => 11,
    "GeneDetail.knownGene" => 12,
    "ExonicFunc.knownGene" => 13,
    "AAChange.knownGene" => 14,
    "genomicSuperDups" => 15,
    "avsift" => 16,
    "cosmic70" => 17,
    "PopFreqMax" => 18,
    "1000G_ALL" => 19,
    "1000G_AFR" => 20,
    "1000G_AMR" => 21,
    "1000G_EAS" => 22,
    "1000G_EUR" => 23,
    "1000G_SAS" => 24,
    "ExAC_ALL" => 25,
    "ExAC_AFR" => 26,
    "ExAC_AMR" => 27,
    "ExAC_EAS" => 28,
    "ExAC_FIN" => 29,
    "ExAC_NFE" => 30,
    "ExAC_OTH" => 31,
    "ExAC_SAS" => 32,
    "ESP6500siv2_ALL" => 33,
    "ESP6500siv2_AA" => 34,
    "ESP6500siv2_EA" => 35,
    "CG46" => 36,
    "clinvar_20150629" => 37,
    "avsnp144" => 38,
    "snp138NonFlagged" => 39,
    "SIFT_score" => 40,
    "SIFT_pred" => 41,
    "Polyphen2_HDIV_score" => 42,
    "Polyphen2_HDIV_pred" => 43,
    "Polyphen2_HVAR_score" => 44,
    "Polyphen2_HVAR_pred" => 45,
    "LRT_score" => 46,
    "LRT_pred" => 47,
    "MutationTaster_score" => 48,
    "MutationTaster_pred" => 49,
    "MutationAssessor_score" => 50,
    "MutationAssessor_pred" => 51,
    "FATHMM_score" => 52,
    "FATHMM_pred" => 53,
    "RadialSVM_score" => 54,
    "RadialSVM_pred" => 55,
    "LR_score" => 56,
    "LR_pred" => 57,
    "VEST3_score" => 58,
    "CADD_raw" => 59,
    "CADD_phred" => 60,
    "GERP++_RS" => 61,
    "phyloP46way_placental" => 62,
    "phyloP100way_vertebrate" => 63,
    "SiPhy_29way_logOdds" => 64,
    "vcf_chr" => 65,
    "vcf_pos" => 66,
    "vcf_id" => 67,
    "vcf_ref" => 68,
    "vcf_alt" => 69,
    "vcf_qual" => 70,
    "vcf_filter" => 71,
    "vcf_info" => 72,
    "vcf_format" => 73,
    "vcf_format_sample" => 74
    );

our %_annovar_format_index = (
    "DP" => 3,
    "FA" => 14
    );

=head1 SUBROUTINES/METHODS

=head2 $obj->make_gene_table()

A method for creating the custom gene table from standard ANNOVAR output.  This will create
the generic gene table which can then be used the mutation calling specific gene tables.

=head3 Arguments:

=over 2

=item * directory: directory containing the output files for processing (required)

=item * depth: minimum depth of coverage to filter (default: 100)

=item * input_suffix: the input file common suffix which is used to search for and remove (default: hg19_multianno.txt)

=item * output_suffix: the output file suffix to append to the output data file (default: '')

=item * filter_criteria: filter criteria used in the data

=item * tool: name of mutation calling tool used (default: VarScan)

=item * tool_version: version of pipeline used (default: v1601)

=back

=cut

sub make_gene_table {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        directory => {
            isa         => 'Str',
            required    => 1
            },
        depth => {
            isa         => 'Int',
            required    => 0,
            default     => 100
            },
        input_suffix => {
            isa         => 'Str',
            required    => 0,
            default     => 'hg19_multianno.txt'
            },
        output_suffix => {
            isa         => 'Str',
            required    => 0,
            default     => ""
            },
        filter_criteria => {
            isa         => 'Str',
            required    => 0,
            default     => ""
            },
        tool => {
            isa         => 'Str',
            required    => 0,
            default     => 'VarScan'
            },
        tool_version => {
            isa         => 'Str',
            required    => 0,
            default     => 'v1601'
            }
        );

    # the directory name containing the output data will be used as the output file
    # prefix
    my $output_file_prefix;
    if ( -d $args{'directory'}) {
        $output_file_prefix = File::Basename::basename($args{'directory'});
        }

    # the output file suffix is dependent on the tool used for calling the mutations,
    # the pipeline version (???) and any filtering criteria used
    my $output_suffix;
    if ($args{'output_suffix'} eq '') {
        $output_suffix = join('',
            '.gene_table_'
            );
    } else {
        $output_suffix = $args{'output_suffix'}
        }

    # from here we can construct the output filename
    my $output_file = join('',
        $output_file_prefix,
        $output_suffix
        );



    my %return_values = (

        );

    return(\%return_values);
    }

=head2 $obj->create_sample_hash()

Create the sample hash from the list of ANNOVAR output files.

=head3 Arguments:

=over 2

=item * dir: directory containing the ANNOVAR output files

=back

=cut

sub create_sample_hash {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        dir => {
            isa         => 'Str',
            required    => 1
            }
        );

    my %_sample_hash;
    my $annovar_files = $self->get_annovar_files(
        dir => $args{'dir'}
        );

    foreach my $sample_file (@{ $annovar_files }) {
        my $sample = $self->extract_sample_name_from_annovar_file(
            file => $sample_file
            );
        $self->add_sample_to_sample_hash(hash => \%_sample_hash, sample => $sample);
        }

    return(\%_sample_hash);
    }

=head2 $obj->create_sample_gene_hash()

A method that creates a per sample gene hash.

=head3 Arguments:

=over 2

=item * file: full path to the ANNOVAR output file

=back

=cut

sub create_sample_gene_hash {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        file => {
            isa         => 'Str',
            required    => 1
            },
        sample_gene_hash => {
            isa         => 'HashRef',
            required    => 1
            }
        );

    my $_sample_gene_hash = $args{'sample_gene_hash'};

    my $samplename = $self->extract_sample_name_from_annovar_file(
        file => $args{'file'}
        );
    open(my $anno_fh, '<', $args{'file'});
    while(my $line = <$anno_fh>) {
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        my @_annovar_line = split(/\t/, $line);

        if ($_sample_gene_hash->{$samplename}{$_annovar_line[$_annovar_index{'Gene.refGene'}]}) {
            $_sample_gene_hash->{$samplename}{$_annovar_line[$_annovar_index{'Gene.refGene'}]}{'count_all'}++;
            push($_sample_gene_hash->{$samplename}{$_annovar_line[$_annovar_index{'Gene.refGene'}]}{'protein_all'}, 'a');
            push($_sample_gene_hash->{$samplename}{$_annovar_line[$_annovar_index{'Gene.refGene'}]}{'protein_cosmic'}, 'b');
            $_sample_gene_hash->{$samplename}{$_annovar_line[$_annovar_index{'Gene.refGene'}]}{'count_cosmic'}++;                    
        } else {
            $_sample_gene_hash->{$samplename}{$_annovar_line[$_annovar_index{'Gene.refGene'}]}{'count_all'} = 0;
            $_sample_gene_hash->{$samplename}{$_annovar_line[$_annovar_index{'Gene.refGene'}]}{'protein_all'} = [];
            $_sample_gene_hash->{$samplename}{$_annovar_line[$_annovar_index{'Gene.refGene'}]}{'protein_cosmic'} = [];
            $_sample_gene_hash->{$samplename}{$_annovar_line[$_annovar_index{'Gene.refGene'}]}{'count_cosmic'} = 0;        
            }
        }
    close($anno_fh);

    }

=head2 $obj->create_gene_hash()

A method to create a hash that contains all genes for all samples.  The gene hash
consists of a sample name and a gene value.  The gene has a value corresponding
to an array of protein changes.  To make the table readable, the protein change array
is limited to at most 11 protein changes.

=head3 Arguments:

=over 2

=item * dir: directory containing the ANNOVAR output files

=back

=cut

sub create_gene_hash {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        dir => {
            isa         => 'Str',
            required    => 0,
            default     => './'
            }
        );

    my %_gene_hash;
    my $annovar_files = $self->get_annovar_files(dir => $args{'dir'});
    foreach my $annovar_file (@{ $annovar_files }) {
        open(my $ifh, '<', join('/', $args{'dir'}, $annovar_file)) or die
            "Cannot open file $annovar_file";
        while(my $line = <$ifh>) {
            $line =~ s/^\s+//;
            $line =~ s/\s+$//;

            my @_input_line = split(/\t/, $line);
            if ($self->filter_functional_consequence(func_consequence => $_input_line[$_annovar_index{'ExonicFunc.refGene'}])) {
                $self->add_gene_to_gene_hash(
                    hash => \%_gene_hash,
                    gene => $_input_line[$_annovar_index{"Gene.refGene"}]
                    );
                }
            }
        close($ifh);
        }

    return(\%_gene_hash);
    }

=head2 $obj->add sample_to_sample_hash()

A method to add a sample to the sample hash.

=head3 Arguments:

=over 2

=item * hash: the sample hash to use as a hash reference (required)

=item * sample: name of sample to use in the hash (required)

=back

=cut

sub add_sample_to_sample_hash {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        hash => {
            isa         => 'HashRef',
            required    => 1
            },
        sample => {
            isa         => 'Str',
            required    => 1
            }
        );

    # check if sample is already in the sample hash
    if (!$args{'hash'}->{$args{'sample'}}) {
        $args{'hash'}->{$args{'sample'}} = 1;
        }

    return 0;
    }

=head2 $obj->add_gene_to_gene_hash()

A method to add a gene to the gene hash.

=head3 Arguments:

=over 2

=item * hash: the gene hash to use as a hash reference (required)

=item * gene: name of gene to add to the hash if not already in hash (required)

=back

=cut

sub add_gene_to_gene_hash {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        hash => {
            isa         => 'HashRef',
            required    => 1
            },
        gene => {
            isa         => 'Str',
            required    => 1
            }
        );

    if (!$args{'hash'}->{$args{'gene'}}) {
        $args{'hash'}->{$args{'gene'}} = 1;
        }
    return 0;
    }

=head2 $obj->extract_sample_name_from_annovar_file()

A method that extracts the name of the sample from an ANNOVAR output file.  Note that the file
should contain the sample name and the output file will have a standard suffix that can be
stripped from the file.

=head3 Arguments:

=over 2

=item * file: name of file to process (required)

=item * suffix: suffix to search for and delete (default: hg19_multianno.txt)

=back

=cut

sub extract_sample_name_from_annovar_file {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        file => {
            isa         => 'Str',
            required    => 1
            },
        suffix => {
            isa         => 'Str',
            required    => 0,
            default     => '.hg19_multianno.txt'
            }
        );

    my $sample_name;
    if ($args{'file'} =~ m/$args{'suffix'}$/) {
        $sample_name = File::Basename::basename($args{'file'}, ($args{'suffix'}));
        }

    return $sample_name;
    }

=head2 $obj->get_annovar_files()

A method for getting the ANNOVAR output files.

=head3 Arguments:

=over 2

=item * dir: directory containing the ANNOVAR output files (default: ./)

=item * suffix: suffix of the ANNOVAR files (default: .hg19_multianno.txt)

=back

=cut

sub get_annovar_files {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        dir => {
            isa         => 'Str',
            required    => 0,
            default     => './'
            },
        suffix => {
            isa         => 'Str',
            required    => 0,
            default     => '.hg19_multianno.txt'
            }
        );

    my @_annovar_file_array;
    opendir(my $dirh, $args{'dir'});
    while (my $annovar_file = readdir($dirh)) {
        next unless $annovar_file =~ m/$args{'suffix'}/;
        push(@_annovar_file_array, $annovar_file);
        }
    closedir($dirh);

    return(\@_annovar_file_array);
    }

=head2 $obj->get_depth_of_coverage()

A method to parse the VCF FORMAT string and extract the depth of coverage.  It
requires an index where the depth of coverage can be found

=head3 Arguments:

=over 2

=item * input: FORMAT string to extract depth of coverage (required)

=item * depth_index: the array index for the depth of coverage (default: 3)

=back

=cut

sub get_depth_of_coverage {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        input => {
            isa         => 'Str',
            required    => 1
            },
        depth_index => {
            isa         => 'Int',
            required    => 0,
            default     => 3
            }
        );

    my @format_string = split(/\:/, $args{'input'});

    return($format_string[$args{'depth_index'}]);
    }

=head2 $obj->get_protein_change()

A method to parse the protein change in the ANNOVAR output and extract
the specific amino acid change.  Note that for multi-transcript or
multi-protein changes, we will use the first protein change which
ANNOVAR sorts as most damaging to least damaging.

=head3 Arguments:

=over 2

=item * input: the ANNOVAR data containing the protein change (required)

=item * protein_index: the array index for the protein change (default: 4)

=item * multi_protein_index: the array index to obtain amino acid change in multiple protein changes (default: 0)

=back

=cut

sub get_protein_change {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        input => {
            isa         => 'Str',
            required    => 1
            },
        protein_index => {
            isa         => 'Int',
            required    => '0',
            default     => 4
            },
        multi_protein_index => {
            isa         => 'Int',
            required    => 0,
            default     => 0
            }
        );

    my @protein_changes = split(/\,/, $args{'input'});
    my @protein_change = split(/\:/, $protein_changes[$args{'multi_protein_index'}]);

    return($protein_change[$args{'protein_index'}]);
    }

=head2 $obj->filter_functional_consequence()

A method to filter mutations based on the functional consequence (i.e. remove
synonymous, unknown, intergenic and empty consequence information).

=head3 Arguments:

=over 2

=item * func_consequence: functional consequence (i.e. ExonicFunc.refGene) from ANNOVAR output

=back

=cut

sub filter_functional_consequence {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        func_consequence => {
            isa         => 'Str',
            required    => 1
            }
        );

    if (!(($args{'func_consequence'} =~ /^synonymous/) ||
      ($args{'func_consequence'} =~ /^unknown/) ||
      ($args{'func_consequence'} =~ /^intergenic/)) &&
      $args{'func_consequence'}) {
        return 0;
        }
    else {
        return 1;
        }
    }


=head2 $obj->apply_custom_filter()

A method for applying a set of custom filters.

=head3 Arguments:

=over 2

=item * arg: argument

=back

=cut

sub apply_custom_filter {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        data => {
            isa         => 'ArrayRef',
            required    => 1
            },
        exac => {
            isa         => 'Num',
            required    => 0,
            default     => 0.01
            },
        g1000 => {
            isa         => 'Num',
            required    => 0,
            default     => 0.01
            },
        esp6500 => {
            isa         => 'Num',
            required    => 0,
            default     => 0.01
            }
        );

    my %return_values = (

        );

    return(\%return_values);
    }

=head1 AUTHOR

Richard J. de Borja, C<< <richard.deborja at uhnresearch.ca> >>

=head1 ACKNOWLEDGEMENT

Zhibin Lu -- University Health Network

Natalie Stickle -- University Health Network

Carl Virtanen -- University Health Network

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-test at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=test-test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc BioCore::Annotation::Filter

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=test-test>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/test-test>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/test-test>

=item * Search CPAN

L<http://search.cpan.org/dist/test-test/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2018 The University Health Network

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

no Moose::Role;

1; # End of BioCore::Annotation::Filter
