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
my $biocore;
lives_ok
    {
        $biocore = $test_class->new();
        }
    'Class instantiated';
my $annovar_dir = "$Bin/../lib/BioCore/Annotation/Filter/Annovar";
my $sample_hash = $biocore->create_sample_hash(dir => $annovar_dir);
my %_expected_sample_hash = (
    'Mx-1.processed.cns' => 1,
    'Mx-2.processed.cns' => 1,
    'Mx-3.processed.cns' => 1,
    'Mx-4.processed.cns' => 1,
    'Mx-5.processed.cns' => 1,
    'Mx-6.processed.cns' => 1,
    'Mx-7.processed.cns' => 1,
    'Mx-8.processed.cns' => 1,
    'Mx-9.processed.cns' => 1,
    'Mx-10.processed.cns' => 1,
    );
is_deeply($sample_hash, \%_expected_sample_hash, "Sample hash matches expected");
