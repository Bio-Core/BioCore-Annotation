#!/usr/bin/env perl

### convert_delly_vcf_to_table.pl #################################################################
# A Perl script that converts a Delly generated VCF file to a tab separated file.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2018-01-10      Richard de Borja    Initial development

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use Vcf;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
    vcf => undef,
    );

### MAIN CALLER ###################################################################################
my $result = main();
exit($result);

### FUNCTIONS #####################################################################################

### main ##########################################################################################
# Description:
#   Main subroutine for program
# Input Variables:
#   %opts = command line arguments
# Output Variables:
#   N/A

sub main {
    # get the command line arguments
    GetOptions(
        \%opts,
        "help|?",
        "man",
        "vcf|v=s"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument \n";
            pod2usage(128);
            }
        }



    return 0;
    }


=head2 $convert_to_bed()

Convert to the BED format.

=head3 Arguments:

=over 2

=item * chr: chromosome field

=item * start: start position

=item * end: end position

=item * name: name field

=item * score: score field

=item * strand: strange (i.e. +/-) for loci

=back

=cut
convert_to_bed {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        chr => {
            isa         => 'Str',
            required    => 1
            },
        start => {
            isa         => 'Int',
            required    => 1
            },
        end => {
            isa         => 'Int',
            required    => 0,
            default     => 0
            }
        );

    my $end_position;
    if ($args{'end'} == 0) {
        $end_position = $args{'start'} + 1;
        }



    my %return_values = (

        );

    return(\%return_values);
    }

__END__


=head1 NAME

convert_delly_vcf_to_table.pl

=head1 SYNOPSIS

B<convert_delly_vcf_to_table.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --vcf           full path to the VCF file to process (required)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--vcf>

Full path to the VCF file to be processed.  The file contains valid VCF
output from the Delly structural rearrangement program.

=back

=head1 DESCRIPTION

B<convert_delly_vcf_to_table.pl> A Perl script that converts a Delly generated VCF file to a tab separated file

=head1 EXAMPLE

convert_delly_vcf_to_table.pl --vcf /path/to/file.vcf

=head1 AUTHOR

Richard J. de Borja -- Princess Margaret Cancer Centre

=head1 ACKNOLEDGEMENTS

Carl Virtanen   -- Princess Margaret Cancer Centre

Zhibin Lu       -- Princess Margaret Cancer Centre

Natalie Stickle -- Princess Margaret Cancer Centre

=cut

