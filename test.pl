#
# $Id: test.pl,v 0.21 2001/12/16 22:51:55 dankogai Exp dankogai $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
my $Debug = 0;
BEGIN { plan tests => 28 };

use BSD::stat;
ok(1); # If we made it this far, we're ok.

my $stat = BSD::stat::xs_stat('test', 0);
$! and ok(1);
$Debug and warn $!;

my @bsdstat = lstat($0);
my @perlstat = CORE::lstat($0);
for my $i (0..$#perlstat){
    $perlstat[$i] == $bsdstat[$i] ? ok(1) : ok(0);
}
$Debug and warn join(",", @bsdstat), "\n";

use File::stat ();
my $bsdstat = lstat($0);
my $perlstat = File::stat::lstat($0);

no strict 'refs';
for my $s (qw(dev ino mode nlink uid gid rdev size
	      atime mtime ctime blksize blocks))
{
    $perlstat->$s() == $bsdstat->$s() ? ok(1) : ok(0);
}
use strict;
$Debug and print $bsdstat->dev, "\n";

use File::Copy;
my $dummy = $0; $dummy =~ s,([^/]+),dummy,o;
copy($0, $dummy) or die "copy $0 -> $dummy failed!";

chflags(UF_IMMUTABLE, "dummy") ? ok(1) : ok(0);
lstat("dummy")->flags == UF_IMMUTABLE ? ok(1) : ok(0);
unlink("dummy") ? ok(0) : ok(1);
$Debug and warn $!;
chflags(0, "dummy") ? ok(1) : ok(0);
unlink("dummy") ? ok(1) : ok(0);

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

