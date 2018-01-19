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

my $format_string = "1/1:105:19:19:0:19:100%:2.8292E-11:0:42:0:0:11:8:1.0000";
my $depth = $biocore->get_depth_of_coverage(input => $format_string);
my $expected_depth = 19;
is($depth, $expected_depth, "Depth $depth matches expected");
