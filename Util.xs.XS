
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "hangul.h"

MODULE = Lingua::KO::Hangul::Util	PACKAGE = Lingua::KO::Hangul::Util

void
composeHangul(src)
    SV * src
  PROTOTYPE: $
  PREINIT:
    SV * dst;
    U8 *s, *p, *e, *d;
    UV lastuv, nextuv, sindex, lindex, vindex, tindex;
    STRLEN srclen, dstlen, dstcur, curlen, retlen, ulen;
    int notwantarray;
  PPCODE:
    s = SvPV(src, srclen);
    e = s + srclen;
    notwantarray = (GIMME_V != G_ARRAY);

    if(SvUTF8(src)) {
	if(notwantarray) {
	    dstlen = srclen + 1; /* equal or shorter */
	    dst = newSV(dstlen);
	    (void)SvPOK_only(dst);
	    d = (U8*)SvPVX(dst);
	}
        else {
	    if(! strlen) XSRETURN_EMPTY;
	    else EXTEND(SP, sv_len_utf8(src));
	} /* wantarray */

	for(p = s; p < e;){
	    lastuv = utf8n_to_uvchr(p, e - p, &retlen, 0);
	    p += retlen;
	    curlen = e - p;
	    if(curlen) nextuv = utf8n_to_uvchr(p, curlen, &retlen, 0);

     /* 1. composed if lastuv is L and nextuv is V. */
	    if(curlen && _Hangul_isL(lastuv) && _Hangul_isV(nextuv)) {
		lindex = lastuv - _Hangul_LBase;
		vindex = nextuv - _Hangul_VBase;
		lastuv = _Hangul_SBase + 
		    (lindex * _Hangul_VCount + vindex) * _Hangul_TCount;
		p += retlen;
		curlen = e - p;
		if(curlen) nextuv = utf8n_to_uvchr(p, curlen, &retlen, 0);
	    }

     /* 2. composed if lastuv is LV and nextuv is T. */
	    if(curlen && _Hangul_isLV(lastuv) && _Hangul_isT(nextuv)) {
		tindex = nextuv - _Hangul_TBase;
		lastuv += tindex;
		p += retlen;
	    }

     /* 3. just append lastuv */
	    if(notwantarray) d = uvuni_to_utf8(d, lastuv);
	    else XPUSHs(sv_2mortal(newSViv(lastuv)));
	} /* for */

	if(notwantarray){
	    dstcur = d - (U8*)SvPVX(dst);
	    SvCUR_set(dst, dstcur);
	    SvUTF8_on(dst);
	    XPUSHs(dst);
	}
    } /* SvUTF8(src) */
    else {
	if(notwantarray){
	    XPUSHs(sv_mortalcopy(src));
	}
	else {
	    if(!srclen) XSRETURN_EMPTY;
	    EXTEND(SP, srclen);
	    for(p = s; p < e; p++) XPUSHs(sv_2mortal(newSViv(*p)));
	}
    } /* composeHangul */



void
decomposeHangul(code)
    UV code
  PROTOTYPE: $
  PREINIT:
    UV sindex, lindex, vindex, tindex;
    SV *decomp;
    U8 *t, temp[3 * UTF8_MAXLEN + 1];
    STRLEN tlen;
    int notwantarray;
  PPCODE:
    notwantarray = (GIMME_V != G_ARRAY);
    if(! _Hangul_isS(code)){
	if(notwantarray) XSRETURN_UNDEF;
	else XSRETURN_EMPTY;
    }
    sindex = code - _Hangul_SBase;
    lindex =  sindex / _Hangul_NCount;
    vindex = (sindex % _Hangul_NCount) / _Hangul_TCount;
    tindex =  sindex % _Hangul_TCount;

    if(notwantarray) {
	t = temp;
	t = uvuni_to_utf8(t, (lindex + _Hangul_LBase));
	t = uvuni_to_utf8(t, (vindex + _Hangul_VBase));
	if (tindex) t = uvuni_to_utf8(t, (tindex + _Hangul_TBase));
	*t = '\0';
	tlen = strlen(temp);
	decomp = sv_2mortal(newSVpvn(temp, tlen));
	SvUTF8_on(decomp);
	XPUSHs(decomp);
    }
    else {
	XPUSHs(sv_2mortal(newSViv(lindex + _Hangul_LBase)));
	XPUSHs(sv_2mortal(newSViv(vindex + _Hangul_VBase)));
	if(tindex) XPUSHs(sv_2mortal(newSViv(tindex + _Hangul_TBase)));
    } /* decomposeHangul */



SV*
getHangulName(code)
    UV code
  PROTOTYPE: $
  PREINIT:
    UV sindex, lindex, vindex, tindex;
    U8 name[_Hangul_NameMax + 1];
    STRLEN nlen;
  CODE:
    if(! _Hangul_isS(code)) XSRETURN_UNDEF;
    sindex = code - _Hangul_SBase;
    lindex =  sindex / _Hangul_NCount;
    vindex = (sindex % _Hangul_NCount) / _Hangul_TCount;
    tindex =  sindex % _Hangul_TCount;
    strcpy(name, _Hangul_BName);
    strcat(name, _hangul_JamoL[lindex]);
    strcat(name, _hangul_JamoV[vindex]);
    strcat(name, _hangul_JamoT[tindex]);
    nlen = strlen(name);
    RETVAL = newSVpvn(name, nlen);
  OUTPUT:
    RETVAL



SV*
parseHangulName(sv)
    SV* sv
  PROTOTYPE: $
  PREINIT:
    UV uv;
    U8 jamoL[_Hangul_LLenMax];
    U8 jamoV[_Hangul_VLenMax];
    U8 jamoT[_Hangul_TLenMax];
    U8 *s, *p, *e;
    STRLEN slen, llen, vlen, tlen;
  CODE:
    s = (U8*)SvPV(sv, slen);
    e = s + slen;
    if( slen <= _Hangul_BNameLen
	|| _Hangul_NameMax < slen
	|| strnNE(s, _Hangul_BName, _Hangul_BNameLen)
    ) XSRETURN_UNDEF;

    s += _Hangul_BNameLen;
    for(p = s; p < e && p < s + _Hangul_LLenMax; ++p) {
	if      (_IsHangulJamoC(*p)) jamoL[p - s] = *p;
	else if (_IsHangulJamoV(*p)) break;
	else XSRETURN_UNDEF;
    }
    llen = p - s;
    s += llen;

    for(p = s; p < e && p < s + _Hangul_VLenMax; ++p) {
	if      (_IsHangulJamoV(*p)) jamoV[p - s] = *p;
	else if (_IsHangulJamoC(*p)) break;
	else XSRETURN_UNDEF;
    }
    vlen = p - s;
    if(! vlen) XSRETURN_UNDEF;   /* Vowel has length */

    s += vlen;
    for(p = s; p < e && p < s + _Hangul_TLenMax; ++p) {
	if (_IsHangulJamoC(*p)) jamoT[p - s] = *p;
	else XSRETURN_UNDEF;
    }
    tlen = p - s;
    s += tlen;
    if(s != e) XSRETURN_UNDEF; /* has weird trailing char(s) */

    uv = _Hangul_SBase;

    if(llen == 0) {
	uv +=  11 * _Hangul_NCount;
    }
    else if (llen == 1) { 
	switch(jamoL[0]) {
	    case 'G' : uv +=  0 * _Hangul_NCount; break;
	    case 'N' : uv +=  2 * _Hangul_NCount; break;
	    case 'D' : uv +=  3 * _Hangul_NCount; break;
	    case 'R' : uv +=  5 * _Hangul_NCount; break;
	    case 'M' : uv +=  6 * _Hangul_NCount; break;
	    case 'B' : uv +=  7 * _Hangul_NCount; break;
	    case 'S' : uv +=  9 * _Hangul_NCount; break;
	    case 'J' : uv += 12 * _Hangul_NCount; break;
	    case 'C' : uv += 14 * _Hangul_NCount; break;
	    case 'K' : uv += 15 * _Hangul_NCount; break;
	    case 'T' : uv += 16 * _Hangul_NCount; break;
	    case 'P' : uv += 17 * _Hangul_NCount; break;
	    case 'H' : uv += 18 * _Hangul_NCount; break;
	    default  : XSRETURN_UNDEF;
	}
    }
    else { /* llen == 2 */
	if (jamoL[0] != jamoL[1]) XSRETURN_UNDEF;
	switch(jamoL[0]) {
	    case 'G' : uv +=  1 * _Hangul_NCount; break;
	    case 'D' : uv +=  4 * _Hangul_NCount; break;
	    case 'B' : uv +=  8 * _Hangul_NCount; break;
	    case 'S' : uv += 10 * _Hangul_NCount; break;
	    case 'J' : uv += 13 * _Hangul_NCount; break;
	    default  : XSRETURN_UNDEF;
	}
    } /* jamoL */

    if (vlen == 1) { 
	switch(jamoV[0]) {
	    case 'A' : uv +=  0 * _Hangul_TCount; break;
	    case 'E' : uv +=  5 * _Hangul_TCount; break;
	    case 'O' : uv +=  8 * _Hangul_TCount; break;
	    case 'U' : uv += 13 * _Hangul_TCount; break;
	    case 'I' : uv += 20 * _Hangul_TCount; break;
	    default  : XSRETURN_UNDEF;
	}
    }
    else if (vlen == 2) {
	if      (jamoV[0] == 'A') {
	    if(jamoV[1] == 'E') uv +=  1 * _Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'O') {
	    if(jamoV[1] == 'E') uv += 11 * _Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'E') {
	    if     (jamoV[1] == 'O') uv +=  4 * _Hangul_TCount;
	    else if(jamoV[1] == 'U') uv += 18 * _Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'Y') {
	    if     (jamoV[1] == 'A') uv +=  2 * _Hangul_TCount;
	    else if(jamoV[1] == 'E') uv +=  7 * _Hangul_TCount;
	    else if(jamoV[1] == 'O') uv += 12 * _Hangul_TCount;
	    else if(jamoV[1] == 'U') uv += 17 * _Hangul_TCount;
	    else if(jamoV[1] == 'I') uv += 19 * _Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'W') {
	    if     (jamoV[1] == 'A') uv +=  9 * _Hangul_TCount;
	    else if(jamoV[1] == 'E') uv += 15 * _Hangul_TCount;
	    else if(jamoV[1] == 'I') uv += 16 * _Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else XSRETURN_UNDEF;
    }
    else { /* vlen == 3 */
	if      (jamoV[0] == 'Y') {
	    if      (jamoV[1] == 'A' && jamoV[2] == 'E')
		uv +=  3 * _Hangul_TCount;
	    else if (jamoV[1] == 'E' && jamoV[2] == 'O')
		uv +=  6 * _Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'W') {
	    if      (jamoV[1] == 'A' && jamoV[2] == 'E')
		uv +=  10 * _Hangul_TCount;
	    else if (jamoV[1] == 'E' && jamoV[2] == 'O')
		uv +=  14 * _Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else XSRETURN_UNDEF;
    } /* jamoV */

    if      (tlen == 0) {
	uv +=  0;
    }
    else if (tlen == 1) { 
	switch(jamoT[0]) {
	    case 'G' : uv +=  1; break;
	    case 'N' : uv +=  4; break;
	    case 'D' : uv +=  7; break;
	    case 'L' : uv +=  8; break;
	    case 'M' : uv += 16; break;
	    case 'B' : uv += 17; break;
	    case 'S' : uv += 19; break;
	    case 'J' : uv += 22; break;
	    case 'C' : uv += 23; break;
	    case 'K' : uv += 24; break;
	    case 'T' : uv += 25; break;
	    case 'P' : uv += 26; break;
	    case 'H' : uv += 27; break;
	    default  : XSRETURN_UNDEF;
	}
    }
    else { /* tlen == 2 */
	if      (jamoT[0] == 'G') {
	    if     (jamoT[1] == 'G') uv +=  2;
	    else if(jamoT[1] == 'S') uv +=  3;
	    else XSRETURN_UNDEF;
	}
	else if (jamoT[0] == 'N') {
	    if     (jamoT[1] == 'J') uv +=  5;
	    else if(jamoT[1] == 'H') uv +=  6;
	    else if(jamoT[1] == 'G') uv += 21;
	    else XSRETURN_UNDEF;
	}
	else if (jamoT[0] == 'L') {
	    if     (jamoT[1] == 'G') uv +=  9;
	    else if(jamoT[1] == 'M') uv += 10;
	    else if(jamoT[1] == 'B') uv += 11;
	    else if(jamoT[1] == 'S') uv += 12;
	    else if(jamoT[1] == 'T') uv += 13;
	    else if(jamoT[1] == 'P') uv += 14;
	    else if(jamoT[1] == 'H') uv += 15;
	    else XSRETURN_UNDEF;
	}
	else if (jamoT[0] == 'B') {
	    if     (jamoT[1] == 'S') uv += 18;
	    else XSRETURN_UNDEF;
	}
	else if (jamoT[0] == 'S') {
	    if     (jamoT[1] == 'S') uv += 20;
	    else XSRETURN_UNDEF;
	}
	else XSRETURN_UNDEF;
    } /* jamoT */

    RETVAL = newSViv(uv);
  OUTPUT:
    RETVAL
