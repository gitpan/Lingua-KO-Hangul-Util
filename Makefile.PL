use ExtUtils::MakeMaker;

# This code for  XS-NOXS installer is shamelessly stolen
# from Gurusamy Sarathy's Data::Dumper. Thank you!

# a bit modified.

use File::Copy qw();

my $arg = $ARGV[0] || "";

if ($arg =~ /^no/i and -f "Util.xs") {
    print STDERR "Disabling XS in sources...\n";

    die "***** Failed, sources could be inconsistent! *****\n"
     unless File::Copy::move('MANIFEST',	'MANIFEST.XS')
	and File::Copy::move('MANIFEST.NXS',	'MANIFEST')
	and File::Copy::move('Util.pm',		'Util.pm.XS')
	and File::Copy::move('Util.xs',		'Util.xs.XS')
	and File::Copy::move('Util.pm.NXS',	'Util.pm');
}
if ($arg =~ /^xs/i and -f "Util.xs.XS") {
    print STDERR "Enabling XS in sources...\n";

    die "***** Failed, sources could be inconsistent! *****\n"
     unless File::Copy::move('MANIFEST',	'MANIFEST.NXS')
	and File::Copy::move('MANIFEST.XS',	'MANIFEST')
	and File::Copy::move('Util.pm',		'Util.pm.NXS')
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
