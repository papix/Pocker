package Pocker::Validator;
use strict;
use warnings;
use utf8;
use parent 'FormValidator::Lite';
use Pocker::Exception;

use Path::Tiny;

sub validate {
    my ($class, $req, @rules) = @_;

    my $validation_message_path = path( 'config', 'common', 'validate_message.pl' );
    my $validation_message = do $validation_message_path || undef;

    my $validator = __PACKAGE__->new($req);
    $validator->set_message_data($validation_message) if $validation_message;
    $validator->load_constraints("+Pocker::Validator::Constraint");

    $validator->check(@rules);
    return $validator;
}

sub exception {
    my ($self) = @_;

    Pocker::Exception::Validator->throw(
        v => $self,
    ) if $self->has_error;
}

package Pocker::Exception::Validator {
    use parent -norequire, 'Pocker::Exception';
    use Class::Accessor::Lite (
        ro => [qw/ v /],
    );
}

1;
