use Test::More tests => 4;
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
my $filter;
lives_ok
    {
        $filter = $test_class->new();
        }
    'Class instantiated';

my $file = "/some/directory/sample_ABC.hg19_multianno.txt";
my $sample_name = $filter->extract_sample_name_from_annovar_file(
    file => $file,
    suffix => '.hg19_multianno.txt'
    );
my $expected_sample_name = "sample_ABC";
is($sample_name, $expected_sample_name, "Sample name matches expected: $sample_name");


# test the creation of the sample hash
my %_test_sample_hash;
$filter->add_sample_to_sample_hash(hash => \%_test_sample_hash, sample => $sample_name);
$filter->add_sample_to_sample_hash(hash => \%_test_sample_hash, sample => "some_new_sample");
my %_expected_hash = ("sample_ABC" => 1, "some_new_sample" => 1);
print Dumper(\%_test_sample_hash);
is_deeply(\%_test_sample_hash, \%_expected_hash, "Sample hash matches expected");


# test the creation of the gene hash
my %_test_gene_hash;
$filter->add_gene_to_gene_hash(hash => \%_test_gene_hash, gene => "TP53");
$filter->add_gene_to_gene_hash(hash => \%_test_gene_hash, gene => "TP53");
$filter->add_gene_to_gene_hash(hash => \%_test_gene_hash, gene => "EGFR");
my %_expected_gene_hash = ("TP53" => 1, "EGFR" => 1);
print Dumper(\%_test_gene_hash);
is_deeply(\%_test_gene_hash, \%_expected_gene_hash, "Gene hash matches expected");
