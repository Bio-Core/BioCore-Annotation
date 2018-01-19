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
my $biocore;
lives_ok
    {
        $biocore = $test_class->new();
        }
    'Class instantiated';

my $protein_input = "SAMD11:NM_152486:exon3:c.G166A:p.G56S";
my $multi_protein_input = "MFAP2:NM_001135247:exon8:c.T429C:p.H143H,MFAP2:NM_001135248:exon8:c.T429C:p.H143H";

my $expected_protein = "p.G56S";
my $expected_multi_protein = "p.H143H";

my $protein_change = $biocore->get_protein_change(input => $protein_input);
my $multi_protein_change = $biocore->get_protein_change(input => $multi_protein_input);

is(
    $protein_change,
    $expected_protein,
    "Protein change $protein_change matches expected"
    );
is(
    $multi_protein_change,
    $expected_multi_protein,
    "Multi-protein change $multi_protein_change matches expected"
    );
