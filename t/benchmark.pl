#!/usr/local/bin/perl
#
# $Id: benchmark.pl,v 0.40 2001/12/29 15:45:25 dankogai Exp $
#

use lib qw(blib/arch blib/lib);
use File::stat ();
use BSD::stat ();
use Benchmark;

my $count = $ARGV[0] || 1024;
print <<"";
----
File::stat = $File::stat::VERSION
BSD::stat  = $BSD::stat::VERSION
----

timethese($count, {
               'Core::stat' => sub { my @st = CORE::stat("/dev/null") },
               'BSD::stat' =>  sub { my $st = BSD::stat::stat("/dev/null")},
	       'File::stat' =>  sub { my $st = File::stat::stat("/dev/null")},
           });
