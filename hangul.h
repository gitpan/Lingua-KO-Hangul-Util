/*
 * hangul.h
 *
 *   This file is for the Perl module Lingua::KO::Hangul::Util.
 */

#ifndef _HANGUL_H
#define _HANGUL_H

/* Perl 5.6.1 ? */
#ifndef uvuni_to_utf8
#define uvuni_to_utf8   uv_to_utf8
#endif /* uvuni_to_utf8 */ 

/* Perl 5.6.1 ? */
#ifndef utf8n_to_uvchr
#define utf8n_to_uvchr  utf8_to_uv
#endif /* utf8n_to_uvchr */ 

#define _Hangul_SBase  0xAC00
#define _Hangul_SFinal 0xD7A3
#define _Hangul_SCount  11172

#define _Hangul_NCount    588

#define _Hangul_LBase  0x1100
#define _Hangul_LFinal 0x1112
#define _Hangul_LCount     19

#define _Hangul_VBase  0x1161
#define _Hangul_VFinal 0x1175
#define _Hangul_VCount     21

#define _Hangul_TBase  0x11A7
#define _Hangul_TFinal 0x11C2
#define _Hangul_TCount     28

#define _Hangul_isS(u)  ((_Hangul_SBase <= (u)) && ((u) <= _Hangul_SFinal))
#define _Hangul_isN(u)  (! (((u) - _Hangul_SBase) % _Hangul_TCount))
#define _Hangul_isLV(u) (_Hangul_isS(u) && _Hangul_isN(u))
#define _Hangul_isL(u)  ((_Hangul_LBase <= (u)) && ((u) <= _Hangul_LFinal))
#define _Hangul_isV(u)  ((_Hangul_VBase <= (u)) && ((u) <= _Hangul_VFinal))
#define _Hangul_isT(u)  ((_Hangul_TBase <= (u)) && ((u) <= _Hangul_TFinal))

#define _Hangul_BName "HANGUL SYLLABLE "
#define _Hangul_BNameLen 16
#define _Hangul_LLenMax   2
#define _Hangul_VLenMax   3
#define _Hangul_TLenMax   2
#define _Hangul_NameMax  23

#define _IsHangulJamoV(c) ( \
  (c) == 'A' || (c) == 'E' || (c) == 'I' || (c) == 'O' || \
  (c) == 'U' || (c) == 'W' || (c) == 'Y' )

#define _IsHangulJamoC(c) ( \
  (c) == 'G' || (c) == 'N' || (c) == 'D' || (c) == 'R' || (c) == 'L' || \
  (c) == 'M' || (c) == 'B' || (c) == 'S' || (c) == 'J' || (c) == 'C' || \
  (c) == 'K' || (c) == 'T' || (c) == 'P' || (c) == 'H' )

U8* _hangul_JamoL[] = { /* Initial (HANGUL CHOSEONG) */
    "G", "GG", "N", "D", "DD", "R", "M", "B", "BB",
    "S", "SS", "", "J", "JJ", "C", "K", "T", "P", "H"
  };

U8* _hangul_JamoV[] = { /* Medial (HANGUL JUNGSEONG) */
    "A", "AE", "YA", "YAE", "EO", "E", "YEO", "YE", "O",
    "WA", "WAE", "OE", "YO", "U", "WEO", "WE", "WI", "YU", "EU", "YI", "I"
  };

U8* _hangul_JamoT[] = { /* Final (HANGUL JONGSEONG) */
    "", "G", "GG", "GS", "N", "NJ", "NH", "D", "L", "LG", "LM",
    "LB", "LS", "LT", "LP", "LH", "M", "B", "BS",
    "S", "SS", "NG", "J", "C", "K", "T", "P", "H"
  };

#endif	/* _HANGUL_H */
