/*
 * $Id: stat.xs,v 0.43 2002/01/10 13:59:44 dankogai Exp dankogai $
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static int
setbang(int err)
{
    SV* bang = perl_get_sv("!", 1);
    if (err){
        sv_setpv(bang, strerror(errno));
	sv_setiv(bang, errno << 8);
    }else{
        sv_setpv(bang, "");
	sv_setiv(bang, 0);
    }
    return err;
}

#define NUMSTATMEM 18

static SV *
st2aref(struct stat *st){
    SV* retval;
    SV* sva[NUMSTATMEM];
    int i;

    /* same as CORE::stat */

    sva[0]  = sv_2mortal(newSViv(PL_statcache.st_dev     = st->st_dev));
    sva[1]  = sv_2mortal(newSViv(PL_statcache.st_ino     = st->st_ino));
    sva[2]  = sv_2mortal(newSViv(PL_statcache.st_mode    = st->st_mode));
    sva[3]  = sv_2mortal(newSViv(PL_statcache.st_nlink   = st->st_nlink));
    sva[4]  = sv_2mortal(newSViv(PL_statcache.st_uid     = st->st_uid));
    sva[5]  = sv_2mortal(newSViv(PL_statcache.st_gid     = st->st_gid));
    sva[6]  = sv_2mortal(newSViv(PL_statcache.st_rdev    = st->st_rdev));
    sva[7]  = sv_2mortal(newSViv(PL_statcache.st_size    = st->st_size));
    sva[8]  = sv_2mortal(newSViv(PL_statcache.st_atime   = st->st_atime));
    sva[9]  = sv_2mortal(newSViv(PL_statcache.st_mtime   = st->st_mtime));
    sva[10] = sv_2mortal(newSViv(PL_statcache.st_ctime   = st->st_ctime));
    sva[11] = sv_2mortal(newSViv(PL_statcache.st_blksize = st->st_blksize));
    sva[12] = sv_2mortal(newSViv(PL_statcache.st_blocks  = st->st_blocks));


    /* BSD-specific */

    sva[13] = sv_2mortal(newSViv(st->st_atimespec.tv_nsec));
    sva[14] = sv_2mortal(newSViv(st->st_mtimespec.tv_nsec));
    sva[15] = sv_2mortal(newSViv(st->st_ctimespec.tv_nsec));
    sva[16] = sv_2mortal(newSViv(st->st_flags));
    sva[17] = sv_2mortal(newSViv(st->st_gen));
    
    retval = newRV_noinc((SV *)av_make(NUMSTATMEM, sva));
    return retval;
}

static SV *
xs_stat(char *path){
    struct stat st;
    int err = stat(path, &st);
    if (setbang(err)){
	return &PL_sv_undef;
    }else{
	PL_laststype = OP_STAT;
	return st2aref(&st);
    }
}

static SV *
xs_lstat(char *path){
    struct stat st;
    int err = lstat(path, &st);
    if (setbang(err)){
	return &PL_sv_undef;
    }else{
        PL_laststype = OP_LSTAT;
	return st2aref(&st);
    }
}

static SV *
xs_fstat(int fd, int waslstat){
    struct stat st;
    int err = fstat(fd, &st);
    if (setbang(err)){
	return &PL_sv_undef;
    }else{
        PL_laststype = waslstat ? OP_LSTAT : OP_STAT;
	return st2aref(&st);
    }
}

static int
xs_chflags(char *path, int flags){
    int err = chflags(path, flags);
    return setbang(err);
}

/* */

MODULE = BSD::stat		PACKAGE = BSD::stat

PROTOTYPES: ENABLE

SV *
xs_stat(path)
    char * path;
    CODE:
	RETVAL = xs_stat(path);
    OUTPUT:
	RETVAL

SV *
xs_lstat(path)
    char * path;
    CODE:
	RETVAL = xs_lstat(path);
    OUTPUT:
	RETVAL

SV *
xs_fstat(fd, waslstat)
    int    fd;
    int    waslstat;
    CODE:
	RETVAL = xs_fstat(fd, waslstat);
    OUTPUT:
	RETVAL

int
xs_chflags(path, flags)
    char * path;
    int    flags;
    CODE:
	RETVAL = xs_chflags(path, flags);
    OUTPUT:
	RETVAL
