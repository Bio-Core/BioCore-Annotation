package BioCore::Annotation::Filter;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Basename;

=head1 NAME

BioCore::Annotation::Filter

=head1 SYNOPSIS

A Perl role for handling various filtering methods.

=head1 ATTRIBUTES AND DELEGATES



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

=head2 $obj->make_mutect_gene_table()

A method to create the MuTect specific gene table.

=head3 Arguments:

=over 2

=item * arg: argument

=back

=cut

sub make_mutect_gene_table {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        arg => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            }
        );

    my %return_values = (

        );

    return(\%return_values);
    }

=head2 $obj->make_varscan_gene_table()

A method to create the VarScan specific gene table.

=head3 Arguments:

=over 2

=item * arg: argument

=back

=cut

sub make_varscan_gene_table {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        arg => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            }
        );

    my %return_values = (

        );

    return(\%return_values);
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

=head1 AUTHOR

Richard J. de Borja, C<< <richard.deborja at uhnresearch.ca> >>

=head1 ACKNOWLEDGEMENT

Carl Virtanen -- University Health Network

Natalie Stickle -- University Health Network

Zhibin Lu -- University Health Network

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

Copyright 2017 Richard J. de Borja.

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
