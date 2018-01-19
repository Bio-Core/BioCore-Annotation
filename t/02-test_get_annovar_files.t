use Test::More tests => 2;
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
my $annotation;
my $example_dir = "$Bin/examples/02_test_get_annovar_files";
lives_ok
    {
        $annotation = $test_class->new();
        }
    'Class instantiated';

my $annovar_files = $annotation->get_annovar_files(
    dir => $example_dir
    );
my @expected_annovar_files = (
    "1.hg19_multianno.txt",
    "2.hg19_multianno.txt",
    "3.hg19_multianno.txt"
    );
is_deeply($annovar_files, \@expected_annovar_files, "File array matches expected");
