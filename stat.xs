/*
 * $Id: stat.xs,v 0.23 2001/12/17 03:46:39 dankogai Exp dankogai $
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
xs_stat(char *path, int type){
    struct stat st;
    AV * result = newAV();
    int err = (type == 0) ? lstat(path, &st) : stat(path, &st);
    if (setbang(err)){
	return result;
    }

    /* same as CORE::stat */

    av_push(result, newSViv(st.st_dev));
    av_push(result, newSViv(st.st_ino));
    av_push(result, newSViv(st.st_mode));
    av_push(result, newSViv(st.st_nlink));
    av_push(result, newSViv(st.st_uid));
    av_push(result, newSViv(st.st_gid));
    av_push(result, newSViv(st.st_rdev));
    av_push(result, newSViv(st.st_size));
    av_push(result, newSViv(st.st_atime));
    av_push(result, newSViv(st.st_mtime));
    av_push(result, newSViv(st.st_ctime));
    av_push(result, newSViv(st.st_blksize));
    av_push(result, newSViv(st.st_blocks));

    /* BSD-specifig */

    av_push(result, newSViv(st.st_atimespec.tv_nsec));
    av_push(result, newSViv(st.st_mtimespec.tv_nsec));
    av_push(result, newSViv(st.st_ctimespec.tv_nsec));
    av_push(result, newSViv(st.st_flags));
    av_push(result, newSViv(st.st_gen));

    return result;
}

static int
xs_chflags(char *path, int flags){
    int err = chflags(path, flags);
    return setbang(err);
}

/* */

MODULE = BSD::stat		PACKAGE = BSD::stat

AV *
xs_stat(path, type)
    char * path;
    int    type;
    CODE:
	RETVAL = xs_stat(path, type);
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

