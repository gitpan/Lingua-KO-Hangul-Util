package Lingua::KO::Hangul::Util;

require 5.006;

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);

@EXPORT_OK = ();
@EXPORT = qw(
    decomposeHangul
    composeHangul
    getHangulName
    parseHangulName
    getHangulComposite
);
$VERSION = '0.06';

bootstrap Lingua::KO::Hangul::Util $VERSION;

1;
__END__
