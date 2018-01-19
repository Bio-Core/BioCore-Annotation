use Test::More tests => 1;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
    { class_basename => 'Test' }
    );

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('BioCore::Annotation::Filter');

# instantiate the test class based on the given role
my $biocore;
lives_ok
    {
        $biocore = $test_class->new();
        }
    'Class instantiated';

    my $annovar_dir = "$Bin/../lib/BioCore/Annotation/Filter/Annovar";
my $annovar_files = $biocore->get_annovar_files(dir => $annovar_dir);

my $annovar_file = $annovar_files->[0];

my %_test_sample_gene_hash;
$biocore->create_sample_gene_hash(
    file => join('/', $annovar_dir, $annovar_file),
    sample_gene_hash => \%_test_sample_gene_hash
    );

my @_some_array;
my $_some_return_hash = $biocore->apply_custom_filter(data => \@_some_array, exac => 0.01);
print Dumper($_some_return_hash);
