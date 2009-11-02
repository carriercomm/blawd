package Blawd::Cmd::Container;
use Moose::Role;
use namespace::autoclean;

use Bread::Board;
use aliased 'Blawd::Renderer::RSS';

sub build_app {
    my ( $self, $cfg ) = @_;

    my $c = container Blawd => as {

        service gitdir => ( $cfg->repo );

        service title => ( $cfg->title );

        service headers => q[
	        <link rel="alternate" type="application/rss+xml" title="RSS" href="rss.xml" />
	        <link rel="openid.server" href="http://www.myopenid.com/server" />
	        <link rel="openid.delegate" href="http://openid.prather.org/chris" />
	    ];

        service app => (
            class        => 'Blawd',
            lifecycle    => 'Singleton',
            dependencies => [
                depends_on('title'), depends_on('indexes'),
                depends_on('entries'),
            ]
        );

        service storage => (
            class        => 'Blawd::Storage::Git',
            dependencies => [ depends_on('gitdir'), ]
        );

        service entries => (
            block => sub {
                my $store = $_[0]->param('storage');
                [ sort { $b->date <=> $a->date } $store->find_entries ];
            },
            dependencies => [ depends_on('storage'), ],
        );

        service indexes => (
            block => sub {
                my %common = (
                    title   => $_[0]->param('title'),
                    entries => $_[0]->param('entries')
                );
                return [
                    Blawd::Index->new(
                        filename => 'index',
                        headers  => $_[0]->param('headers'),
                        %common,
                    ),
                    Blawd::Index->new(
                        filename => 'rss',
                        renderer => RSS,
                        %common,
                    )
                ];
            },
            dependencies => [
                depends_on('title'), depends_on('entries'),
                depends_on('headers'),
            ]
        );

    };

    return $c->fetch('app')->get;
}

1;
__END__
