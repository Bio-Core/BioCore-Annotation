use Test::More tests => 3;
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
my %test_hash;
$filter->add_sample_to_sample_hash(hash => \%test_hash, sample => $sample_name);
$filter->add_sample_to_sample_hash(hash => \%test_hash, sample => "some_new_sample");
my %_expected_hash = ("sample_ABC" => 1, "some_new_sample" => 1);
is_deeply(\%test_hash, \%_expected_hash, "Hash matches expected");
