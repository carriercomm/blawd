#!/usr/bin/perl 
use strict;
use Test::More;
use Try::Tiny;
use Path::Class;
use Blawd;

BEGIN {
    try { use Git::Wrapper }
    catch { plan skip_all => 'Tests Require Git::Wrapper ' };
}

my $directory = 'my-blog';
dir($directory)->rmtree if -e $directory;
dir($directory)->mkpath;

my $g = Git::Wrapper->new($directory);
$g->init;
my $hello = dir($directory)->file('hello');
$hello->openw->print("# Hello World\n");
$g->add('hello');
$g->commit( { message => 'first post' } );

my $blog = Blawd->new(
    repo     => "$directory/.git",
    renderer => 'Blawd::Renderer::MultiMarkdown',
);

my @entries = $blog->find_entries, 'got entries';
is( $entries[0]->render_as_fragment, qq[<h1 id="helloworld">Hello World</h1>\n], 'render correctly' );

done_testing;
dir($directory)->rmtree;