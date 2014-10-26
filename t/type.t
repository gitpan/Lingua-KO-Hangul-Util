use Test;
use strict;
use warnings;
BEGIN { plan tests => 33 };

use Lingua::KO::Hangul::Util "getSyllableType";
ok(1); # If we made it this far, we're ok.

#########################

ok(getSyllableType(0x0000), 'NA');
ok(getSyllableType(0x0100), 'NA');
ok(getSyllableType(0x1000), 'NA');
ok(getSyllableType(0x10FF), 'NA');
ok(getSyllableType(0x1100), 'L');
ok(getSyllableType(0x1101), 'L');
ok(getSyllableType(0x1159), 'L');
ok(getSyllableType(0x115A), 'NA');
ok(getSyllableType(0x115E), 'NA');
ok(getSyllableType(0x115F), 'L');
ok(getSyllableType(0x1160), 'V');
ok(getSyllableType(0x1161), 'V');
ok(getSyllableType(0x11A0), 'V');
ok(getSyllableType(0x11A2), 'V');
ok(getSyllableType(0x11A3), 'NA');
ok(getSyllableType(0x11A7), 'NA');
ok(getSyllableType(0x11A8), 'T');
ok(getSyllableType(0x11AF), 'T');
ok(getSyllableType(0x11E0), 'T');
ok(getSyllableType(0x11F9), 'T');
ok(getSyllableType(0x11FA), 'NA');
ok(getSyllableType(0x11FF), 'NA');
ok(getSyllableType(0x3011), 'NA');
ok(getSyllableType(0x11A7), 'NA');
ok(getSyllableType(0xABFF), 'NA');
ok(getSyllableType(0xAC00), 'LV');
ok(getSyllableType(0xAC01), 'LVT');
ok(getSyllableType(0xAC1B), 'LVT');
ok(getSyllableType(0xAC1C), 'LV');
ok(getSyllableType(0xD7A3), 'LVT');
ok(getSyllableType(0xD7A4), 'NA');
ok(getSyllableType(0xFFFF), 'NA');

