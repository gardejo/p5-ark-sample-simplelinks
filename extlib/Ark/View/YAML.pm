package Ark::View::YAML;
use Ark 'View';

use Encode qw(decode_utf8);

# todo: treat YAML flag with $self->options
has options => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { {} },
);

has mime_type => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        'text/plain';
        # or 'text/yaml';
        # or 'text/x-yaml';
        # or 'application/yaml';
        # or 'application/x-yaml';
    },
);

sub dump {
    my ($self, $data) = @_;
    $self->context->stash->{__view_yaml_data} = $data;
    $self;
}

sub render {
    my $self     = shift;
    my $data     = shift;
    my $context  = $self->context;

    $data     ||= $self->context->stash->{__view_yaml_data}
              || $self->context->request->action->reverse
                  or return;

    $self->ensure_class_loaded('YAML::Any');
    decode_utf8(YAML::Any::Dump $data);
}

sub process {
    my ($self, $c) = @_;
    $c->response->header
        ( content_type => sprintf('%s; charset=UTF-8', $self->mime_type) );
    $c->response->body( $self->render );
}

1;
