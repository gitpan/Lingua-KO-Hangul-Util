use ExtUtils::MakeMaker;

# This code for  XS-NOXS installer is shamelessly stolen
# from Gurusamy Sarathy's Data::Dumper. Thank you!

use File::Copy qw();

my $arg = $ARGV[0] || "";
my($DOXS, $DONOXS);
$DONOXS = shift if $arg =~ /^noxs/i
	and -f "MANIFEST"
	and -f "Util.pm";
$DOXS   = shift if $arg =~ /^xs/i
	and -f "MANIFEST.XS"
	and -f "Util.xs.XS"
	and -f "Util.pm.XS";

if ($DONOXS) {
    print STDERR "Disabling XS in sources...\n";
    die "***** Failed, sources could be inconsistent! *****\n"
     unless File::Copy::move('Util.xs',	'Util.xs.XS');
}
elsif ($DOXS) {
    print STDERR "Enabling XS in sources...\n";
    die "***** Failed, sources could be inconsistent! *****\n"
     unless File::Copy::move('MANIFEST',	'MANIFEST.NXS')
	and File::Copy::move('MANIFEST.XS',	'MANIFEST')
	and File::Copy::move('Util.pm',	'Util.pm.NXS')
	and File::Copy::move('Util.xs.XS',	'Util.xs')
	and File::Copy::move('Util.pm.XS',	'Util.pm');
}

WriteMakefile(
    'NAME'	=> 'Lingua::KO::Hangul::Util',
    'VERSION_FROM' => 'Util.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Util.pm', # retrieve abstract from module
       AUTHOR     => 'SADAHIRO Tomoyuki <SADAHIRO@cpan.org>') : ()),
);
