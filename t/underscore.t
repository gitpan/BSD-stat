#
# $Id: underscore.t,v 0.30 2001/12/28 09:47:54 dankogai Exp dankogai $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
my $Debug = 0;
BEGIN { plan tests => 18 };

use BSD::stat;

my @lstat1 = lstat($0);
$_ = $0;
my @lstat2 = lstat;

for my $i (0..$#lstat1){
    $lstat1[$i] == $lstat2[$i] ? ok(1) : ok(0);
}
$Debug and warn join(",", @lstat1), "\n";
