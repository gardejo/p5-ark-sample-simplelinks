package Ark::View::JSON;
use Ark 'View';

use Data::Structure::Util qw(unbless);
use Data::Util qw(:check);
use Encode qw(decode_utf8);
use JSON::Any;
use Scalar::Util qw(blessed);
use Storable qw(dclone);

has options => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { {} },
);

# todo: to use OO interface
# has json => (
#     is      => 'rw',
#     isa     => 'JSON::Any',
#     lazy    => 1,
#     default => sub {
#         my $self = shift;
# 
#         $self->ensure_class_loaded('JSON::Any');
#         JSON::Any->new;
#     },
# );

has mime_type => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        'text/plain';
        # or 'text/json';
        # or 'text/x-json';
        # or 'application/json';
        # or 'application/x-json';
    },
);

sub dump {
    my ($self, $data) = @_;
    $self->context->stash->{__view_json_data} = $data;
    $self;
}

sub render {
    my $self     = shift;
    my $data     = shift;
    my $context  = $self->context;

    $data     ||= $self->context->stash->{__view_json_data}
              || $self->context->request->action->reverse
                  or return;

    my $json = JSON::Any->new(
        utf8            => 1,
        pretty          => 1,
        convert_blessed => 1,
        allow_blessed   => 1,
    );
    $json->objToJson( _unbless_recursively( dclone( $data ) ) );
}

sub _unbless_recursively {
    my $data = shift;

    if (blessed $data) {
        unbless $data;
    }

    if (is_array_ref($data)) {
        ELEMENT:
        foreach (@$data) {
            next ELEMENT
                unless defined $_;
            _unbless_recursively( $_ );
        }
    }
    elsif (is_hash_ref($data)) {
        KEY:
        foreach my $key (keys %$data) {
            next KEY
                unless defined $data->{$key};
            $data->{$key} = _unbless_recursively( $data->{$key} );
        }
    }
    elsif (is_scalar_ref($data)) {
        $data = $$data;     # URI
    }
    elsif (is_code_ref($data)) {
        $data = &$data;
    }
    elsif (is_glob_ref($data)) {
        $data = *$data;
    }

    return $data;
}

sub process {
    my ($self, $c) = @_;
    $c->response->header
        ( content_type => sprintf('%s; charset=UTF-8', $self->mime_type) );
    $c->response->body( $self->render );
}

1;
