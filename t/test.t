# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;
BEGIN { plan tests => 66 };
use Lingua::KO::Hangul::Util;
ok(1); # If we made it this far, we're ok.

#########################

my($str, @ary, $NG, $aryref);

sub strhex { join ':', map sprintf("%04X", $_), unpack 'U*', shift }
sub strfy  { join ':', map sprintf("%04X", $_), @_ }

##
## decomposeHangul: 7 tests
##
ok(strfy(decomposeHangul(0xAC00)), "1100:1161");
ok(strfy(decomposeHangul(0xAE00)), "1100:1173:11AF");
ok(strhex(scalar decomposeHangul(0xAC00)), "1100:1161");
ok(strhex(scalar decomposeHangul(0xAE00)), "1100:1173:11AF");
ok(scalar decomposeHangul(0x0041), undef);
ok(scalar decomposeHangul(0x0000), undef);
@ary = decomposeHangul(0x0000);
ok(scalar @ary, 0);


##
## composeHangul: 13 tests
##
$NG = 0;
foreach $aryref (
   [ "", 0 ], ["\x00", 1 ], [ "\x20", 1 ], [ "ABC", 3 ], 
   [ "\x{3042}\x{1FF}", 2 ], [ "Perl", 4 ],
){ 
  my @ary = composeHangul($aryref->[0]);
  $NG++ unless @ary == $aryref->[1];
}
ok($NG, 0);

ok(strfy(composeHangul("\x00")),    "0000");
ok(strfy(composeHangul("\x20")),    "0020");
ok(strfy(composeHangul("\x{A1}\x{FF}\x00\x40")),    "00A1:00FF:0000:0040");
ok(strfy(composeHangul("\x40\x{1FF}")), "0040:01FF");
ok(strfy(composeHangul("\x{3042}\x{3044}")), "3042:3044");
ok(strfy(composeHangul("\x40\x{1100}\x{1161}\x{1100}\x{1173}\x{11AF}\x60")),
   "0040:AC00:AE00:0060");

ok(strhex(scalar composeHangul("")), "");
ok(strhex(scalar composeHangul("\x00")), "0000");
ok(strhex(scalar composeHangul("\x20")), "0020");
ok(strhex(scalar composeHangul("\x{A1}\x{FF}\x00\x40")),
     "00A1:00FF:0000:0040");
ok(strhex(scalar composeHangul("\x40\x{1FF}")), "0040:01FF");
ok(strhex(scalar composeHangul(
  "\x40\x{1100}\x{1161}\x{1100}\x{1173}\x{11AF}\x60")
), "0040:AC00:AE00:0060");

##
## getHangulName: 11 tests
##
ok(getHangulName(0xAC00), "HANGUL SYLLABLE GA");
ok(getHangulName(0xAE00), "HANGUL SYLLABLE GEUL");
ok(getHangulName(0xC544), "HANGUL SYLLABLE A");
ok(getHangulName(0xD7A3), "HANGUL SYLLABLE HIH");
ok(getHangulName(0x0000),  undef);
ok(getHangulName(0x00FF),  undef);
ok(getHangulName(0x0100),  undef);
ok(getHangulName(0x11A3),  undef);
ok(getHangulName(0x10000), undef);
ok(getHangulName(0x20000), undef);
ok(getHangulName(0x100000),undef);

##
## parseHangulName: 32 tests
##
ok(parseHangulName('HANGUL SYLLABLE GA'),   0xAC00);
ok(parseHangulName('HANGUL SYLLABLE GEUL'), 0xAE00);
ok(parseHangulName('HANGUL SYLLABLE A'),    0xC544);
ok(parseHangulName('HANGUL SYLLABLE HIH'),  0xD7A3);
ok(parseHangulName('HANGUL SYLLABLE PERL'), undef);
ok(parseHangulName('LATIN LETTER SMALL A'), undef);
ok(parseHangulName('LEFTWARDS TRIPLE ARROW'), undef);
ok(parseHangulName('LATIN LETTER SMALL CAPITAL H'), undef);
ok(parseHangulName('HIRAGANA LETTER BA'), undef);
ok(parseHangulName('HANGUL JONGSEONG PANSIOS'), undef);
ok(parseHangulName('PARENTHESIZED HANGUL KHIEUKH A'), undef);
ok(parseHangulName('CJK COMPATIBILITY IDEOGRAPH-FA24'), undef);
ok(parseHangulName('HANGUL SYLLABLE '), undef);
ok(parseHangulName('HANGUL SYLLABLE'), undef);
ok(parseHangulName('HANGUL SYLLABLE H'), undef);
ok(parseHangulName('HANGUL SYLLABLE HH'), undef);
ok(parseHangulName('HANGUL SYLLABLE AA'), undef);
ok(parseHangulName('HANGUL SYLLABLE AAAA'), undef);
ok(parseHangulName('HANGUL SYLLABLE WYZ'), undef);
ok(parseHangulName('HANGUL SYLLABLE QA'), undef);
ok(parseHangulName('HANGUL SYLLABLE LA'), undef);
ok(parseHangulName('HANGUL SYLLABLE MAR'), undef);
ok(parseHangulName('HANGUL SYLLABLE  GA'), undef);
ok(parseHangulName('HANGUL SYLLABLEGA'), undef);
ok(parseHangulName('HANGUL SYLLABLE GA'."\000"), undef);
ok(parseHangulName('HANGUL SYLLABLE GA '), undef);
ok(parseHangulName('HANGUL SYLLABLE KAA'), undef);
ok(parseHangulName('HANGUL SYLLABLE KKKAK'), undef);
ok(parseHangulName('HANGUL SYLLABLE SAQ'), undef);
ok(parseHangulName('HANGUL SYLLABLE SAU'), undef);
ok(parseHangulName('HANGUL SYLLABLE TEE'), undef);
ok(parseHangulName('HANGUL SYLLABLE SHA'), undef);

##
## round trip : 2 tests
##
$NG = 0;
foreach my $i (0xAC00..0xD7A3){
  $NG ++ if $i != parseHangulName(getHangulName($i));
}
ok($NG, 0);

$NG = 0;
foreach my $i (0xAC00..0xD7A3){
  $NG ++ if $i != (composeHangul scalar decomposeHangul($i))[0];
}
ok($NG, 0);

