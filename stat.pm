#$Id: stat.pm,v 0.43 2002/01/10 13:59:44 dankogai Exp dankogai $

package BSD::stat;

use 5.00503;
use strict;
# use warnings;
use Carp;

require Exporter;
require DynaLoader;
use AutoLoader;

use vars qw($RCSID $VERSION $DEBUG);

$RCSID = q$Id: stat.pm,v 0.43 2002/01/10 13:59:44 dankogai Exp dankogai $;
$VERSION = do { my @r = (q$Revision: 0.43 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use vars qw(@ISA %EXPORT_TAGS @EXPORT_OK @EXPORT);

@ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BSD::stat ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

%EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw(
	     stat
	     lstat
	     chflags
	     UF_SETTABLE
	     UF_NODUMP
	     UF_IMMUTABLE
	     UF_APPEND
	     UF_OPAQUE
	     UF_NOUNLINK
	     SF_SETTABLE
	     SF_ARCHIVED
	     SF_IMMUTABLE
	     SF_APPEND
	     SF_NOUNLINK
	     );

bootstrap BSD::stat $VERSION; # make XS available;

use constant Field =>{
    dev       =>  0,
    ino       =>  1,
    mode      =>  2,
    nlink     =>  3,
    uid       =>  4,
    gid       =>  5,
    rdev      =>  6,
    size      =>  7,
    atime     =>  8,
    mtime     =>  9,
    ctime     => 10,
    blksize   => 11,
    blocks    => 12,
    atimensec => 13,
    mtimensec => 14,
    ctimensec => 15,
    flags     => 16,
    gen       => 17,
};

# define attribute methods all at once w/o AUTOLOAD

while (my ($method, $index) = each %{Field()}){
    no strict 'refs';
    *$method = sub{ $_[0]->[$index] };
}

sub DESTROY{
    $DEBUG or return;
    carp "Destroying ", __PACKAGE__;
    $DEBUG >= 2 or return;
    eval qq{ require Devel::Peek; } and Devel::Peek::Dump $_[0];
    return;
}

sub stat(;$){
    my $arg = shift || $_;
    my $self = 
	ref \$arg eq 'SCALAR' ? xs_stat($arg) : xs_fstat(fileno($arg), 0);
    defined $self or return;
    return wantarray ? @$self : bless $self;
}

sub lstat(;$){
    my $arg = shift || $_;
    my $self =
	ref \$arg eq 'SCALAR' ? xs_lstat($arg) : xs_fstat(fileno($arg), 1);
    defined $self or return;
    return wantarray ? @$self : bless $self;
}

# chflag implementation
# see <sys/stat.h>

use constant UF_SETTABLE  => 0x0000ffff;
use constant UF_NODUMP    => 0x00000001;
use constant UF_IMMUTABLE => 0x00000002;
use constant UF_APPEND    => 0x00000004;
use constant UF_OPAQUE    => 0x00000008;
use constant UF_NOUNLINK  => 0x00000010;
use constant SF_SETTABLE  => 0xffff0000;
use constant SF_ARCHIVED  => 0x00010000;
use constant SF_IMMUTABLE => 0x00020000;
use constant SF_APPEND    => 0x00040000;
use constant SF_NOUNLINK  => 0x00100000;

sub chflags{
    my $flags = shift;
    my $count = 0;
    for my $f (@_){
	xs_chflags($f, $flags) == 0 and $count++;
    }
    $count;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

BSD::stat - stat() with BSD 4.4 extentions

=head1 SYNOPSIS

  use BSD::stat;

  # just like CORE::stat

  ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
   $atime,$mtime,$ctime,$blksize,$blocks,
   $atimensec,$mtimensec,$ctimensec,$flags,$gen)
    = stat($filename); 

  # BSD::stat now accepts filehandles, too

  open F, "foo";
  my @stat = stat(*F);

  # omit an argument and it will use $_;

  my $_ = "foo";
  my stat = stat;

  # stat($file) then -x _ works like CORE::stat();
  stat("foo") and -x _ and print "foo is executable"

  # but -x $file then stat(_) will not!!!

  # just like File::stat

  $st = stat($file) or die "No $file: $!";
  if ( ($st->mode & 0111) && $st->nlink > 1) ) {
    print "$file is executable with lotsa links\n";
  }

  # chflags

  chflags(UF_IMMUTABLE, @files)

=head1 DESCRIPTION

This module's default exports override the core stat() and
lstat() functions, replacing them with versions that contains BSD 4.4
extentions such as flags.  This module also adds chflags function.

Here are the meaning of the fields:

  0 dev      device number of filesystem
  1 ino      inode number
  2 mode     file mode  (type and permissions)
  3 nlink    number of (hard) links to the file
  4 uid      numeric user ID of file's owner
  5 gid      numeric group ID of file's owner
  6 rdev     the device identifier (special files only)
  7 size     total size of file, in bytes
  8 atime    last access time in seconds since the epoch
  9 mtime    last modify time in seconds since the epoch
 10 ctime    inode change time (NOT creation time!) in seconds si
 11 blksize  preferred block size for file system I/O
 12 blocks   actual number of blocks allocated
 13 atimensec;         /* nsec of last access */
 14 mtimensec;         /* nsec of last data modification */
 15 ctimensec;         /* nsec of last file status change */
 16 flags;             /* user defined flags for file */
 17 gen;               /* file generation number */

When called with an array context, lstat() and stat() returns an array
like CORE::stat,.  When called with a scalar context, it returns an
object whose methods are named as above, just as File::stat.

Like CORE::stat(), BSD::stat supports _ filehandle.  It does set "stat
cache" so the following -x _ operators can benefit.  Be careful,
however, that BSD::stat::stat(_) will not work (or cannot be made to
work) because BSD::stat::stat() holds more info than that is stored in
Perl's internal stat cache.

BSD::stat also adds chflags().  Like CORE::chmod it takes first
argument as flags and any following arguments as filenames.  
for convenience, the followin constants are also set;

  UF_SETTABLE     0x0000ffff  /* mask of owner changeable flags */
  UF_NODUMP       0x00000001  /* do not dump file */
  UF_IMMUTABLE    0x00000002  /* file may not be changed */
  UF_APPEND       0x00000004  /* writes to file may only append */
  UF_OPAQUE       0x00000008  /* directory is opaque wrt. union *
  UF_NOUNLINK     0x00000010  /* file may not be removed or renamed */
  SF_SETTABLE     0xffff0000  /* mask of superuser changeable flags */
  SF_ARCHIVED     0x00010000  /* file is archived */
  SF_IMMUTABLE    0x00020000  /* file may not be changed */
  SF_APPEND       0x00040000  /* writes to file may only append */
  SF_NOUNLINK     0x00100000  /* file may not be removed or renamed */

so that you can go like

  chflags(SF_ARCHIVED|SF_IMMUTABLE, @files);

just like CORE::chmod(), chflags() returns the number of files
successfully changed. when an error occurs, it sets !$ so you can
check what went wrong when you applied only one file.

to unset all flags, simply

  chflags 0, @files;

=head2 PERFORMANCE

You can use t/benchmark.pl to test the perfomance.  Here is the result
on my FreeBSD.

Benchmark: timing 100000 iterations of BSD::stat, Core::stat,
File::stat...
BSD::stat:  3 wallclock secs ( 2.16 usr +  0.95 sys =  3.11 CPU) @
32160.80/s (n=100000)
Core::stat:  1 wallclock secs ( 1.18 usr +  0.76 sys =  1.94 CPU) @
51612.90/s (n=100000)
File::stat:  7 wallclock secs ( 6.40 usr +  0.93 sys =  7.33 CPU) @
13646.06/s (n=100000)

Not too bad, huh?

=head2 EXPORT

stat(), lstat(), chflags() and chflags-related constants are exported

=head2 BUGS

This is the best approximation of CORE::stat() and File::stat::stat()
that module can go.

In exchange of '_' support, BSD::stat now peeks and pokes too much of
perlguts in terms tat BSD::stat uses such variables as PL_statcache
that does not appear in "perldoc perlapi" and such.

Very BSD specific.  It will not work on any other platform.

=head1 AUTHOR

Dan Kogai E<dankogai@dan.co.jp>

=head1 SEE ALSO

L<chflags(2)>
L<stat(2)>
L<File::stat>
L<perldoc -f -x>
L<perdoc -f stat>

=head1 COPYRIGHT

Copyright 2001 Dan Kogai <dankogai@dan.co.jp>

This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut
