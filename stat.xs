/*
 * $Id: stat.xs,v 0.41 2002/01/07 17:48:02 dankogai Exp dankogai $
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

static AV *
st2av(struct stat *st){
    AV* retval;
    SV* sva[NUMSTATMEM];
    int i;

    /* same as CORE::stat */

    sva[0]  =  newSViv(PL_statcache.st_dev     = st->st_dev);
    sva[1]  =  newSViv(PL_statcache.st_ino     = st->st_ino);
    sva[2]  =  newSViv(PL_statcache.st_mode    = st->st_mode);
    sva[3]  =  newSViv(PL_statcache.st_nlink   = st->st_nlink);
    sva[4]  =  newSViv(PL_statcache.st_uid     = st->st_uid);
    sva[5]  =  newSViv(PL_statcache.st_gid     = st->st_gid);
    sva[6]  =  newSViv(PL_statcache.st_rdev    = st->st_rdev);
    sva[7]  =  newSViv(PL_statcache.st_size    = st->st_size);
    sva[8]  =  newSViv(PL_statcache.st_atime   = st->st_atime);
    sva[9]  =  newSViv(PL_statcache.st_mtime   = st->st_mtime);
    sva[10] =  newSViv(PL_statcache.st_ctime   = st->st_ctime);
    sva[11] =  newSViv(PL_statcache.st_blksize = st->st_blksize);
    sva[12] =  newSViv(PL_statcache.st_blocks  = st->st_blocks);


    /* BSD-specific */

    sva[13] =  newSViv(st->st_atimespec.tv_nsec);
    sva[14] =  newSViv(st->st_mtimespec.tv_nsec);
    sva[15] =  newSViv(st->st_ctimespec.tv_nsec);
    sva[16] =  newSViv(st->st_flags);
    sva[17] =  newSViv(st->st_gen);

    /* DO NOT MORTALIZE THIS! */
    return av_make(NUMSTATMEM, sva);
}

#define EMPTY_AV newAV()

static AV *
xs_stat(char *path){
    struct stat st;
    int err = stat(path, &st);
    PL_laststype = OP_STAT;
    if (setbang(err)){
	return EMPTY_AV;
    }else{
	return st2av(&st);
    }
}

static AV *
xs_lstat(char *path){
    struct stat st;
    int err = lstat(path, &st);
    PL_laststype = OP_LSTAT;
    if (setbang(err)){
	return EMPTY_AV;
    }else{
	return st2av(&st);
    }
}

static AV *
xs_fstat(int fd, int waslstat){
    struct stat st;
    int err = fstat(fd, &st);
    PL_laststype = waslstat ? OP_LSTAT : OP_STAT;
    if (setbang(err)){
	return EMPTY_AV;
    }else{
	return st2av(&st);
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

AV *
xs_stat(path)
    char * path;
    CODE:
	RETVAL = xs_stat(path);
    OUTPUT:
	RETVAL

AV *
xs_lstat(path)
    char * path;
    CODE:
	RETVAL = xs_lstat(path);
    OUTPUT:
	RETVAL

AV *
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
