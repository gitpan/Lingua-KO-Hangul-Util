package Lingua::KO::Hangul::Util;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ();
our @EXPORT_OK = ();
our @EXPORT = qw(
    decomposeHangul
    composeHangul
    getHangulName
    parseHangulName
    getHangulComposite
);
our $VERSION = '0.07';

our @JamoL = ( # Initial (HANGUL CHOSEONG)
    "G", "GG", "N", "D", "DD", "R", "M", "B", "BB",
    "S", "SS", "", "J", "JJ", "C", "K", "T", "P", "H",
  );

our @JamoV = ( # Medial  (HANGUL JUNGSEONG)
    "A", "AE", "YA", "YAE", "EO", "E", "YEO", "YE", "O",
    "WA", "WAE", "OE", "YO", "U", "WEO", "WE", "WI",
    "YU", "EU", "YI", "I",
  );

our @JamoT = ( # Final    (HANGUL JONGSEONG)
    "", "G", "GG", "GS", "N", "NJ", "NH", "D", "L", "LG", "LM",
    "LB", "LS", "LT", "LP", "LH", "M", "B", "BS",
    "S", "SS", "NG", "J", "C", "K", "T", "P", "H",
  );

our $BlockName = "HANGUL SYLLABLE ";

use constant SBase  => 0xAC00;
use constant SFinal => 0xD7A3; # SBase -1 + SCount
use constant SCount =>  11172; # LCount * NCount

use constant NCount =>    588; # VCount * TCount

use constant LBase  => 0x1100;
use constant LFinal => 0x1112;
use constant LCount =>     19; # scalar @JamoL

use constant VBase  => 0x1161;
use constant VFinal => 0x1175;
use constant VCount =>     21; # scalar @JamoV

use constant TBase  => 0x11A7;
use constant TFinal => 0x11C2;
use constant TCount =>     28; # scalar @JamoT

our(%CodeL, %CodeV, %CodeT);
@CodeL{@JamoL} = 0 .. LCount-1;
@CodeV{@JamoV} = 0 .. VCount-1;
@CodeT{@JamoT} = 0 .. TCount-1;

sub Hangul_IsS  ($) { SBase <= $_[0] && $_[0] <= SFinal }

sub Hangul_IsL  ($) { LBase <= $_[0] && $_[0] <= LFinal }

sub Hangul_IsV  ($) { VBase <= $_[0] && $_[0] <= VFinal }

sub Hangul_IsT  ($) { TBase  < $_[0] && $_[0] <= TFinal }
		    # TBase <= $_[0] is false!

sub Hangul_IsLV ($) {
    SBase <= $_[0] && $_[0] <= SFinal && (($_[0] - SBase ) % TCount) == 0;
}

sub getHangulName {
    my $code = shift;
    return undef unless Hangul_IsS($code);
    my $SIndex = $code - SBase;
    my $LIndex = int( $SIndex / NCount);
    my $VIndex = int(($SIndex % NCount) / TCount);
    my $TIndex =      $SIndex % TCount;
    return "$BlockName$JamoL[$LIndex]$JamoV[$VIndex]$JamoT[$TIndex]";
}

sub parseHangulName {
    my $arg = shift;
    return undef unless $arg =~ s/$BlockName//o;
    return undef unless $arg =~ /^([^AEIOUWY]*)([AEIOUWY]+)([^AEIOUWY]*)$/;
    return undef unless exists $CodeL{$1}
		 && exists $CodeV{$2} && exists $CodeT{$3};
    return SBase + $CodeL{$1} * NCount + $CodeV{$2} * TCount + $CodeT{$3};
}

sub getHangulComposite ($$) {
    if(Hangul_IsL($_[0]) && Hangul_IsV($_[1])) {
	my $lindex = $_[0] - LBase;
	my $vindex = $_[1] - VBase;
	return (SBase + ($lindex * VCount + $vindex) * TCount);
    }
    if(Hangul_IsLV($_[0]) && Hangul_IsT($_[1])) {
	return($_[0] + $_[1] - TBase);
    }
    return undef;
}

sub decomposeHangul {
    my $code = shift;
    return unless Hangul_IsS($code);
    my $SIndex = $code - SBase;
    my $LIndex = int( $SIndex / NCount);
    my $VIndex = int(($SIndex % NCount) / TCount);
    my $TIndex =      $SIndex % TCount;
    my @ret = (
       LBase + $LIndex,
       VBase + $VIndex,
      $TIndex ? (TBase + $TIndex) : (),
    );
    wantarray ? @ret : pack('U*', @ret);
}

#
# To Do:
#  s/(\p{JamoL}\p{JamoV})/toHangLV($1)/ge;
#  s/(\p{HangLV}\p{JamoT})/toHangLVT($1)/ge;
#
sub composeHangul {
    my $str = shift;
    if(! length $str) { return wantarray ? () : $str }
    my(@ret);

    foreach my $ch (unpack('U*', $str)) # Makes list! The string be short!
    {
      push(@ret, $ch) and next unless @ret;

      # 1. check to see if $ret[-1] is L and $ch is V.

      if(Hangul_IsL($ret[-1]) && Hangul_IsV($ch)) {
          $ret[-1] -= LBase; # LIndex
          $ch      -= VBase; # VIndex
          $ret[-1]  = SBase + ($ret[-1] * VCount + $ch) * TCount;
          next; # discard $ch
      }

      # 2. check to see if $ret[-1] is LV and $ch is T.

      if(Hangul_IsLV($ret[-1]) && Hangul_IsT($ch)) {
          $ret[-1] += $ch - TBase; # + TIndex
          next; # discard $ch
      }

      # 3. just append $ch
      push(@ret, $ch);
    }
    wantarray ? @ret : pack('U*', @ret);
}

1;
__END__
