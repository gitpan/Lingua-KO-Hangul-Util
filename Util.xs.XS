
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "hangul.h"

/* Perl 5.6.1 ? */
#ifndef uvuni_to_utf8
#define uvuni_to_utf8   uv_to_utf8
#endif /* uvuni_to_utf8 */ 

/* Perl 5.6.1 ? */
#ifndef utf8n_to_uvchr
#define utf8n_to_uvchr  utf8_to_uv
#endif /* utf8n_to_uvchr */ 

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
	    if(curlen && Hangul_IsL(lastuv) && Hangul_IsV(nextuv)) {
		lindex = lastuv - Hangul_LBase;
		vindex = nextuv - Hangul_VBase;
		lastuv = Hangul_SBase + 
		    (lindex * Hangul_VCount + vindex) * Hangul_TCount;
		p += retlen;
		curlen = e - p;
		if(curlen) nextuv = utf8n_to_uvchr(p, curlen, &retlen, 0);
	    }

     /* 2. composed if lastuv is LV and nextuv is T. */
	    if(curlen && Hangul_IsLV(lastuv) && Hangul_IsT(nextuv)) {
		tindex = nextuv - Hangul_TBase;
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
	    dst = sv_mortalcopy(src);
	    sv_utf8_upgrade(dst);
	    XPUSHs(dst);
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
    if(! Hangul_IsS(code)){
	if(notwantarray) XSRETURN_UNDEF;
	else XSRETURN_EMPTY;
    }
    sindex = code - Hangul_SBase;
    lindex =  sindex / Hangul_NCount;
    vindex = (sindex % Hangul_NCount) / Hangul_TCount;
    tindex =  sindex % Hangul_TCount;

    if(notwantarray) {
	t = temp;
	t = uvuni_to_utf8(t, (lindex + Hangul_LBase));
	t = uvuni_to_utf8(t, (vindex + Hangul_VBase));
	if (tindex) t = uvuni_to_utf8(t, (tindex + Hangul_TBase));
	*t = '\0';
	tlen = strlen(temp);
	decomp = sv_2mortal(newSVpvn(temp, tlen));
	SvUTF8_on(decomp);
	XPUSHs(decomp);
    }
    else {
	XPUSHs(sv_2mortal(newSVuv(lindex + Hangul_LBase)));
	XPUSHs(sv_2mortal(newSVuv(vindex + Hangul_VBase)));
	if(tindex) XPUSHs(sv_2mortal(newSViv(tindex + Hangul_TBase)));
    } /* decomposeHangul */



SV*
getHangulName(code)
    UV code
  PROTOTYPE: $
  PREINIT:
    UV sindex, lindex, vindex, tindex;
    U8 name[Hangul_NameMax + 1];
    STRLEN nlen;
  CODE:
    if(! Hangul_IsS(code)) XSRETURN_UNDEF;
    sindex = code - Hangul_SBase;
    lindex =  sindex / Hangul_NCount;
    vindex = (sindex % Hangul_NCount) / Hangul_TCount;
    tindex =  sindex % Hangul_TCount;
    strcpy(name, Hangul_BName);
    strcat(name, hangul_JamoL[lindex]);
    strcat(name, hangul_JamoV[vindex]);
    strcat(name, hangul_JamoT[tindex]);
    nlen = strlen(name);
    RETVAL = newSVpvn(name, nlen);
  OUTPUT:
    RETVAL



SV*
getHangulComposite(uv,uv2)
    UV uv
    UV uv2
  PROTOTYPE: $$
  CODE:
    if(Hangul_IsL(uv) && Hangul_IsV(uv2)) {
	UV lindex = uv  - Hangul_LBase;
	UV vindex = uv2 - Hangul_VBase;
	RETVAL = newSVuv(
	    Hangul_SBase + (lindex * Hangul_VCount + vindex) * Hangul_TCount
	);
    }
    else if(Hangul_IsLV(uv) && Hangul_IsT(uv2)) {
	RETVAL = newSVuv(uv + uv2 - Hangul_TBase);
    }
    else XSRETURN_UNDEF;
  OUTPUT:
    RETVAL


SV*
parseHangulName(sv)
    SV* sv
  PROTOTYPE: $
  PREINIT:
    UV uv;
    U8 jamoL[Hangul_LLenMax];
    U8 jamoV[Hangul_VLenMax];
    U8 jamoT[Hangul_TLenMax];
    U8 *s, *p, *e;
    STRLEN slen, llen, vlen, tlen;
  CODE:
    s = (U8*)SvPV(sv, slen);
    e = s + slen;
    if( slen <= Hangul_BNameLen
	|| Hangul_NameMax < slen
	|| strnNE(s, Hangul_BName, Hangul_BNameLen)
    ) XSRETURN_UNDEF;

    s += Hangul_BNameLen;
    for(p = s; p < e && p < s + Hangul_LLenMax; ++p) {
	if      (IsHangulNameC(*p)) jamoL[p - s] = *p;
	else if (IsHangulNameV(*p)) break;
	else XSRETURN_UNDEF;
    }
    llen = p - s;
    s += llen;

    for(p = s; p < e && p < s + Hangul_VLenMax; ++p) {
	if      (IsHangulNameV(*p)) jamoV[p - s] = *p;
	else if (IsHangulNameC(*p)) break;
	else XSRETURN_UNDEF;
    }
    vlen = p - s;
    if(! vlen) XSRETURN_UNDEF;   /* Vowel has length */

    s += vlen;
    for(p = s; p < e && p < s + Hangul_TLenMax; ++p) {
	if (IsHangulNameC(*p)) jamoT[p - s] = *p;
	else XSRETURN_UNDEF;
    }
    tlen = p - s;
    s += tlen;
    if(s != e) XSRETURN_UNDEF; /* has weird trailing char(s) */

    uv = Hangul_SBase;

    if(llen == 0) {
	uv +=  11 * Hangul_NCount;
    }
    else if (llen == 1) { 
	switch(jamoL[0]) {
	    case 'G' : uv +=  0 * Hangul_NCount; break;
	    case 'N' : uv +=  2 * Hangul_NCount; break;
	    case 'D' : uv +=  3 * Hangul_NCount; break;
	    case 'R' : uv +=  5 * Hangul_NCount; break;
	    case 'M' : uv +=  6 * Hangul_NCount; break;
	    case 'B' : uv +=  7 * Hangul_NCount; break;
	    case 'S' : uv +=  9 * Hangul_NCount; break;
	    case 'J' : uv += 12 * Hangul_NCount; break;
	    case 'C' : uv += 14 * Hangul_NCount; break;
	    case 'K' : uv += 15 * Hangul_NCount; break;
	    case 'T' : uv += 16 * Hangul_NCount; break;
	    case 'P' : uv += 17 * Hangul_NCount; break;
	    case 'H' : uv += 18 * Hangul_NCount; break;
	    default  : XSRETURN_UNDEF;
	}
    }
    else { /* llen == 2 */
	if (jamoL[0] != jamoL[1]) XSRETURN_UNDEF;
	switch(jamoL[0]) {
	    case 'G' : uv +=  1 * Hangul_NCount; break;
	    case 'D' : uv +=  4 * Hangul_NCount; break;
	    case 'B' : uv +=  8 * Hangul_NCount; break;
	    case 'S' : uv += 10 * Hangul_NCount; break;
	    case 'J' : uv += 13 * Hangul_NCount; break;
	    default  : XSRETURN_UNDEF;
	}
    } /* jamoL */

    if (vlen == 1) { 
	switch(jamoV[0]) {
	    case 'A' : uv +=  0 * Hangul_TCount; break;
	    case 'E' : uv +=  5 * Hangul_TCount; break;
	    case 'O' : uv +=  8 * Hangul_TCount; break;
	    case 'U' : uv += 13 * Hangul_TCount; break;
	    case 'I' : uv += 20 * Hangul_TCount; break;
	    default  : XSRETURN_UNDEF;
	}
    }
    else if (vlen == 2) {
	if      (jamoV[0] == 'A') {
	    if(jamoV[1] == 'E') uv +=  1 * Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'O') {
	    if(jamoV[1] == 'E') uv += 11 * Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'E') {
	    if     (jamoV[1] == 'O') uv +=  4 * Hangul_TCount;
	    else if(jamoV[1] == 'U') uv += 18 * Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'Y') {
	    if     (jamoV[1] == 'A') uv +=  2 * Hangul_TCount;
	    else if(jamoV[1] == 'E') uv +=  7 * Hangul_TCount;
	    else if(jamoV[1] == 'O') uv += 12 * Hangul_TCount;
	    else if(jamoV[1] == 'U') uv += 17 * Hangul_TCount;
	    else if(jamoV[1] == 'I') uv += 19 * Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'W') {
	    if     (jamoV[1] == 'A') uv +=  9 * Hangul_TCount;
	    else if(jamoV[1] == 'E') uv += 15 * Hangul_TCount;
	    else if(jamoV[1] == 'I') uv += 16 * Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else XSRETURN_UNDEF;
    }
    else { /* vlen == 3 */
	if      (jamoV[0] == 'Y') {
	    if      (jamoV[1] == 'A' && jamoV[2] == 'E')
		uv +=  3 * Hangul_TCount;
	    else if (jamoV[1] == 'E' && jamoV[2] == 'O')
		uv +=  6 * Hangul_TCount;
	    else XSRETURN_UNDEF;
	}
	else if (jamoV[0] == 'W') {
	    if      (jamoV[1] == 'A' && jamoV[2] == 'E')
		uv +=  10 * Hangul_TCount;
	    else if (jamoV[1] == 'E' && jamoV[2] == 'O')
		uv +=  14 * Hangul_TCount;
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
