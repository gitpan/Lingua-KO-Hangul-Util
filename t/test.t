# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;
BEGIN { plan tests => 80 };
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
## composeHangul: 14 tests
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
ok(strfy(composeHangul("\x{AC00}\x{11A7}\x{AC00}\x{11A8}")), "AC00:11A7:AC01");
ok(strfy(composeHangul("\x40\x{1FF}")), "0040:01FF");
ok(strfy(composeHangul("\x{3042}\x{3044}")), "3042:3044");
ok(strfy(composeHangul("\x40\x{1100}\x{1161}\x{1100}\x{1173}\x{11AF}\x60")),
   "0040:AC00:AE00:0060");

ok(strhex(scalar composeHangul("")), "");
ok(strhex(scalar composeHangul("\x00")), "0000");
ok(strhex(scalar composeHangul("\x20")), "0020");
ok(strhex(scalar composeHangul("\x40\x{1FF}")), "0040:01FF");
ok(strhex(scalar composeHangul("\x{AC00}\x{11A7}\x{AC00}\x{11A8}")),
   "AC00:11A7:AC01");

ok(strhex(scalar composeHangul(
    "\x40\x{1100}\x{1161}\x{1100}\x{1173}\x{11AF}\x60")
), "0040:AC00:AE00:0060");

ok(strhex(scalar composeHangul(
  "\x{AC00}\x{11A7}\x{1100}\x{0300}\x{1161}")
), "AC00:11A7:1100:0300:1161");

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


##
## getHangulComposite: 13 tests
##
ok(getHangulComposite( 0,  0), undef);
ok(getHangulComposite( 0, 41), undef);
ok(getHangulComposite(41,  0), undef);
ok(getHangulComposite(41, 41), undef);
ok(getHangulComposite(0x1100, 0x1161), 0xAC00);
ok(getHangulComposite(0x1100, 0x1173), 0xADF8);
ok(getHangulComposite(0xAC00, 0x11A7), undef);
ok(getHangulComposite(0xAC00, 0x11A8), 0xAC01);
ok(getHangulComposite(0xADF8, 0x11AF), 0xAE00);
ok(getHangulComposite(12, 0x0300), undef);
ok(getHangulComposite(0x0055, 0xFF00), undef);
ok(getHangulComposite(0x1100, 0x11AF), undef);
ok(getHangulComposite(0x1173, 0x11AF), undef);

