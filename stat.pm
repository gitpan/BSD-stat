#$Id: stat.pm,v 0.25 2001/12/19 09:22:39 dankogai Exp dankogai $

package BSD::stat;

use 5.00503;
use strict;
# use warnings;
use Carp;

require Exporter;
require DynaLoader;
use AutoLoader;

use vars qw($RCSID $VERSION);

$RCSID = q$Id: stat.pm,v 0.25 2001/12/19 09:22:39 dankogai Exp dankogai $;
$VERSION = do { my @r = (q$Revision: 0.25 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

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

use vars qw($AUTOLOAD);

sub AUTOLOAD{
    my $self = shift;
    my $name = $AUTOLOAD; $name =~ s/^.*:://o;
    $AUTOLOAD eq 'DESTROY' and return;
    if (exists Field->{$name}){
	return $self->[Field->{$name}];
    }else{
	croak "Field $name nonexistent!:";
    }
}

sub anystat{
    my $self = xs_stat(@_);
    @$self or return;
    if (wantarray){ # returns an array
        return @$self;
    }else{          # returns an object as in File::stat
        return bless $self, caller();
    }
}

sub lstat { anystat(@_,0) }
sub stat  { anystat(@_,1) }

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
like CORE::stat.  When called with a scalar context, it returns an
object whose methods are named as above, just as File::stat.

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

=head2 EXPORT

stat(), lstat(), chflags() and chflags-related constants are exported

=head2 BUGS

unlike CORE::stat, BSD::stat does not accept filehandle as an argument
(as yet).

Very BSD specific.  It will not work on any other platform.

=head1 AUTHOR

Dan Kogai E<lt>dankogai@dan.co.jp<gt>

=head1 SEE ALSO

L<chflags(2)>
L<stat(2)>
L<perl>.

=head1 COPYRIGHT

Copyright 2001 Dan Kogai <dankogai@dan.co.jp>

This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut
