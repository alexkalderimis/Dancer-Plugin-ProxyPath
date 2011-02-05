#/usr/bin/perl

use strict;
use warnings;
use Scalar::Util qw/refaddr/;
use Test::MockObject;

use Test::More tests => 7;

BEGIN {
    my $mock_request = Test::MockObject->new;
    $mock_request->mock(path => sub {'/foo'})
                ->mock(referer => sub {'client_side/foo'})
                ->mock(uri_for => sub {'server_side/foo'});

    my $mock_dancer = Test::MockObject->new;
    $mock_dancer->fake_module("Dancer",
        request => sub {$mock_request}
    );
}
    
use Dancer::Plugin::ProxyPath::Proxy;

isa_ok(Dancer::Plugin::ProxyPath::Proxy->instance, 
    "Dancer::Plugin::ProxyPath::Proxy", "Instance");

is(
    refaddr(Dancer::Plugin::ProxyPath::Proxy->instance),
    refaddr(Dancer::Plugin::ProxyPath::Proxy->instance),
    "Always returns the same instance"
);

my $proxy = Dancer::Plugin::ProxyPath::Proxy->instance;

can_ok($proxy, qw/uri_for/);

is($proxy->uri_for("/bar"), "client_side/bar", "Constructs abs destination");

is($proxy->uri_for("bar"), "client_side/foo/bar", "Constructs rel destination");

is($proxy->uri_for(Dancer::request->path), "client_side/foo", "Constructs own path explicitly");

is($proxy->uri_for(), "client_side/foo", "Constructs own path implicitly");



