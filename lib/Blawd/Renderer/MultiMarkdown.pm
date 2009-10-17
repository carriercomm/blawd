package Blawd::Renderer::MultiMarkdown;
use Moose;
use 5.10.0;
use namespace::autoclean;
use Text::MultiMarkdown ();

with qw(Blawd::Renderer::API);

has markdown_instance => (
    isa        => 'Text::MultiMarkdown',
    is         => 'ro',
    lazy_build => 1,
    handles    => [qw(markdown)],
);

sub _build_markdown_instance {
    Text::MultiMarkdown->new(
        document_format => 1,
        use_metadata    => 1,
        strip_metadata  => 1,
    );
}

sub render {
    my ( $self, $entry ) = @_;
    return $self->markdown(
"Format: complete\n${\$entry->content}\nBy: $entry->{author} on $entry->{date}"
    );
}

sub render_as_fragment {
    my ( $self, $entry ) = @_;
    return $self->markdown(
        $entry->content . "\nBy: ${\$entry->author} on $entry->{date}" );
}

__PACKAGE__->meta->make_immutable;
1;
__END__
