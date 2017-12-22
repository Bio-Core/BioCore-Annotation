package BioCore::Annotation::Gene::mutect;
use Moose::Roles;

use MooseX::Params::Validate;


sub print_cosmic_annotation_header {
    my self = shift;
    my %args = validated_hash(
        \@,
        arg1 => {
            isa => 'Str',
            required => 0,
            default => "some text"
            }
        arg2 => {
            isa => 'Str',
            required => 1
            }
        );

    }


