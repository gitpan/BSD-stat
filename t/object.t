#
# $Id: object.t,v 0.25 2001/12/19 09:22:39 dankogai Exp dankogai $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
my $Debug = 0;
BEGIN { plan tests => 13 };

use BSD::stat;

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
