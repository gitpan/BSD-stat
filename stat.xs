/*
 * $Id: stat.xs,v 0.40 2001/12/29 15:45:25 dankogai Exp dankogai $
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

static AV *
st2av(struct stat *st, AV *av){

    /* same as CORE::stat */

    av_push(av, newSViv(st->st_dev));
    av_push(av, newSViv(st->st_ino));
    av_push(av, newSViv(st->st_mode));
    av_push(av, newSViv(st->st_nlink));
    av_push(av, newSViv(st->st_uid));
    av_push(av, newSViv(st->st_gid));
    av_push(av, newSViv(st->st_rdev));
    av_push(av, newSViv(st->st_size));
    av_push(av, newSViv(st->st_atime));
    av_push(av, newSViv(st->st_mtime));
    av_push(av, newSViv(st->st_ctime));
    av_push(av, newSViv(st->st_blksize));
    av_push(av, newSViv(st->st_blocks));

    /* Set PL_statcache */

    PL_statcache.st_dev     = st->st_dev;
    PL_statcache.st_ino     = st->st_ino;
    PL_statcache.st_mode    = st->st_mode;
    PL_statcache.st_nlink   = st->st_nlink;
    PL_statcache.st_uid     = st->st_uid;
    PL_statcache.st_uid     = st->st_uid;
    PL_statcache.st_gid     = st->st_gid;
    PL_statcache.st_rdev    = st->st_rdev;
    PL_statcache.st_size    = st->st_size;
    PL_statcache.st_atime   = st->st_atime;
    PL_statcache.st_mtime   = st->st_mtime;
    PL_statcache.st_ctime   = st->st_ctime;
    PL_statcache.st_blksize = st->st_blksize;
    PL_statcache.st_blocks  = st->st_blocks;

    /* BSD-specifig */

    av_push(av, newSViv(st->st_atimespec.tv_nsec));
    av_push(av, newSViv(st->st_mtimespec.tv_nsec));
    av_push(av, newSViv(st->st_ctimespec.tv_nsec));
    av_push(av, newSViv(st->st_flags));
    av_push(av, newSViv(st->st_gen));

    return av;
}

static AV *
xs_stat(char *path){
    struct stat st;
    AV * result = newAV();
    int err = stat(path, &st);
    PL_laststype = OP_STAT;
    if (setbang(err)){
	return result;
    }else{
	return st2av(&st, result);
    }
}

static AV *
xs_lstat(char *path){
    struct stat st;
    AV * result = newAV();
    int err = lstat(path, &st);
    PL_laststype = OP_LSTAT;
    if (setbang(err)){
	return result;
    }else{
	return st2av(&st, result);
    }
}

static AV *
xs_fstat(int fd, int waslstat){
    struct stat st;
    AV * result = newAV();
    int err = fstat(fd, &st);
    PL_laststype = waslstat ? OP_LSTAT : OP_STAT;
    if (setbang(err)){
	return result;
    }else{
	return st2av(&st, result);
    }
}

static int
xs_chflags(char *path, int flags){
    int err = chflags(path, flags);
    return setbang(err);
}

/* */

MODULE = BSD::stat		PACKAGE = BSD::stat

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

