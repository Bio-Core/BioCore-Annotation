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

# my $annovar_dir = "$Bin/../lib/BioCore/Annotation/Filter/Annovar";
# there are two multianno.txt files in here for testing purposes
my $annovar_dir = "$Bin/../lib/BioCore/Annotation/Filter/test";
my $gene_hash = $biocore->create_gene_hash(dir => $annovar_dir);
foreach my $_gene (keys %{ $gene_hash} ) {
    print $_gene, "\n";
}