#
# $Id: filehandle.t,v 0.30 2001/12/28 09:47:54 dankogai Exp dankogai $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
my $Debug = 0;
BEGIN { plan tests => 36 };

use BSD::stat;

my @lstat = lstat($0);

open F, $0 or die "$0:$!";
my @fstat1 = lstat(*F);
close F;

#use FileHandle;
my $fh = FileHandle->new($0) or die "$0:$!";
my @fstat2 = lstat($fh);
undef $fh;

for my $i (0..$#lstat){
    $lstat[$i] == $fstat1[$i] ? ok(1) : ok(0);
    $lstat[$i] == $fstat2[$i] ? ok(1) : ok(0);
}
$Debug and warn join(",", @fstat1), "\n";
