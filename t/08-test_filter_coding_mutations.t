use Test::More tests => 5;
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

my $is_intergenic = $biocore->filter_functional_consequence(
    func_consequence => 'intergenic'
    );
is($is_intergenic, 1, "intergenic is filtered");

my $is_synonymous = $biocore->filter_functional_consequence(
    func_consequence => 'synonymous SNV'
    );
is($is_synonymous, 1, "synonymous SNV is filtered");

my $is_unknown = $biocore->filter_functional_consequence(
    func_consequence => 'unknown'
    );
is($is_unknown, 1, "unknown, is filtered");

my $is_nonsynonymous = $biocore->filter_functional_consequence(
    func_consequence => 'nonsynonymous SNV'
    );
is($is_nonsynonymous, 0, "nonsynonymous SNV, is not filtered");
