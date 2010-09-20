package Blawd;
use Blawd::OO;

our $VERSION = '0.01';

has indexes => (
    isa     => 'ArrayRef[Blawd::Index]',
    is      => 'ro',
    traits  => ['Array'],
    handles => {
        index      => [ 'get', '0' ],
        find_index => ['grep'],
    },
    required => 1,
);

sub get_index {
    my ( $self, $name ) = @_;
    return unless $name;
    my ($idx) = $self->find_index( sub { $_->filename eq $name } );
    return $idx;
}

has entries => (
    isa     => 'ArrayRef',
    traits  => ['Array'],
    handles => {
        find_entry => ['grep'],
        entries    => ['elements'],
    },
    required => 1,
);

sub get_entry {
    my ( $self, $name ) = @_;
    return unless $name;
    my ($entry) = $self->find_entry( sub { $_->filename eq $name } );
    return $entry;
}

has renderers => (
    isa     => 'ArrayRef',
    traits  => ['Array'],
    handles => {
        find_renderer => ['grep'],
        renderers     => ['elements'],
    },
    required => 1,
);

sub get_renderer {
    my ( $self, $name ) = @_;
    return unless $name;
    my ($renderer) = $self->find_renderer(
        sub { blessed($_) eq "Blawd::Renderer::$name" }
    );
    return $renderer;
}

sub render_all {
    my $self = shift;
    my ($output_dir) = @_;

    # XXX: this should all eventually be configurable

    for my $entry ($self->entries) {
        my $renderer = $self->get_renderer('HTML');
        $renderer->render_to_file(
            File::Spec->catfile($output_dir, $entry->filename_base . $renderer->extension),
            $entry,
        );
    }

    for my $index (@{ $self->indexes }) {
        for my $renderer ($self->renderers) {
            $renderer->render_to_file(
                File::Spec->catfile($output_dir, $index->filename_base . $renderer->extension),
                $index,
            );
        }
    }
}

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

Blawd - A Blogging application in the style of Jekyll or Blosxome

=head1 VERSION

This documentation refers to version 0.01.

=head1 SYNOPSIS

	$ blawd server --repo $HOME/my-blog/.git

=head1 DESCRIPTION

Blawd is a blog aware git based content management system, similar to
Bloxsom or Jekyll. It has managed to replace MovableType on my personal
blog, but it is still very very rough. By default it will generate a
tree of HTML documents, but it can be run as a server as well using
L<Plack>

=head1 METHODS

=head2 get_index (Str $name)

Retrieved the the named L<Blawd::Index|Blawd::Index>

=head2 get_entry (Str $name)

Retrieve the named Blawd Entry.

=head1 DEPENDENCIES

=over

=item aliased

=item Bread::Board

=item DateTime

=item DBI

=item Git::PurePerl

=item Memoize

=item Module::Pluggable

=item Moose => 0.92

=item MooseX::Aliases

=item MooseX::Types::DateTime

=item MooseX::Types::DateTimeX

=item MooseX::Types::Path::Class

=item namespace::autoclean

=item Path::Class

=item Plack

=item Text::MultiMarkdown => 1.0.30

=item Try::Tiny

=item XML::RSS

=item YAML

=back

=head1 BUGS AND LIMITATIONS

None known currently, please email the author if you find any.

=head1 AUTHOR

Chris Prather (chris@prather.org)

=head1 LICENCE

Copyright 2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
