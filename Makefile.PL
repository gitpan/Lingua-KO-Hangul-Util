use ExtUtils::MakeMaker;

my $clean = {};

if (-f "Util.xs") {
    print STDERR "Making header files for XS...\n";
    do 'mkheader' or die $@ || "mkheader: $!";
    $clean = { FILES => 'lkhutmp.h' };
}


WriteMakefile(
    'NAME'          => 'Lingua::KO::Hangul::Util',
    'VERSION_FROM'  => 'Util.pm', # finds $VERSION
    'AUTHOR'        => 'SADAHIRO Tomoyuki <SADAHIRO@cpan.org>',
    'clean'		=> $clean,
    'PREREQ_PM'	  	=> {
	Carp		=> 0,
	charnames	=> 0,
	constant	=> 0,
	DynaLoader	=> 0,
	Exporter	=> 0,
	File::Copy	=> 0,
	strict		=> 0,
	Test		=> 0,
	warnings	=> 0,
    },
);
