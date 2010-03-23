#!perl -T

use strict;
use warnings;
use Test::More;

unless ( $ENV{GEARMAN_LIVE_TEST} ) {
  plan( skip_all => 'Set $ENV{GEARMAN_LIVE_TEST} to run this test' );
}

my $res = eval "use Net::Telnet::Gearman 0.02; 1";
unless ($res) {
  plan( skip_all => 'Net::Telnet::Gearman 0.02 required to run this test' );
}

plan tests => 4;

my $telnet = Net::Telnet::Gearman->new(
  host => '127.0.0.1',
  port => 4730,
);

my $found_func;
my $list_func;
my $dereg_func;
for my $worker ( $telnet->workers() ) {
  for my $function ( @{$worker->{functions}} ) {
    if ( $function eq 'GMSXReverseTest' ) {
      $found_func++;
    }
    if ( $function =~ /^list:\d+$/ ) {
      $list_func = $function;
    }
    if ( $function =~ /^dereg:\d+$/ ) {
      $dereg_func = $function;
    }
  }
}

ok($found_func, 'Found reverse function');
ok($found_func == 1, 'Found only 1 reverse function');
BAIL_OUT('Did not find exactly one reverse function')
  unless $found_func == 1;

ok($list_func, 'Found list func');
ok($dereg_func, 'Found dereg func');

unless ( $list_func =~ /^list:(\d+)$/ ) {
  BAIL_OUT('Could not get pid from list function')
}

my $pid = $1;

kill 'TERM', $pid;
