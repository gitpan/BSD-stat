#
# $Id: statcache.t,v 1.0 2002/01/11 10:12:10 dankogai Exp $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
my $Debug = 0;
BEGIN { plan tests => 27 };

use BSD::stat ();

BSD::stat::lstat($0); (-r _) == (-r $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-w _) == (-w $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-x _) == (-x $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-o _) == (-o $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-R _) == (-R $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-W _) == (-W $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-X _) == (-X $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-O _) == (-O $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-e _) == (-e $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-z _) == (-z $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-s _) == (-s $0) ? ok(1) : ok(0); 
BSD::stat::lstat($0); (-f _) == (-f $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-d _) == (-d $0) ? ok(1) : ok(0);

# -l _ should only work on lstat so we test that, too.

BSD::stat::lstat($0); (-l _) == (-l $0) ? ok(1) : ok(0);
eval {BSD::stat::stat($0); (-l _)} ; $@ ? ok(1) : ok(0);

BSD::stat::lstat($0); (-p _) == (-p $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-S _) == (-S $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-b _) == (-b $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-c _) == (-c $0) ? ok(1) : ok(0);

# Stat cache does not work on -t so this one is commented out.
# BSD::stat::lstat(*STDIN); (-t _) == (-t STDIN) ? ok(1) : ok(0);

BSD::stat::lstat($0); (-u _) == (-u $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-g _) == (-g $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-k _) == (-k $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-T _) == (-T $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-B _) == (-B $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-M _) == (-M $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-A _) == (-A $0) ? ok(1) : ok(0);
BSD::stat::lstat($0); (-C _) == (-C $0) ? ok(1) : ok(0);

if ($Debug){
   my @lstat = BSD::stat::lstat(*STDIN);
   warn join(",", @lstat), "\n";
}

