use ExtUtils::MakeMaker;

my $clean = {};

if (-f "Util.xs") {
    print STDERR "Making header files for XS...\n";

    do "mkheader";
    $clean = { FILES => 'lkhutmp.h' };
}


WriteMakefile(
    'NAME'          => 'Lingua::KO::Hangul::Util',
    'VERSION_FROM'  => 'Util.pm', # finds $VERSION
    'PREREQ_PM'     => {}, # e.g., Module::Name => 1.1
    'ABSTRACT_FROM' => 'Util.pm', # retrieve abstract from module
    'AUTHOR'        => 'SADAHIRO Tomoyuki <SADAHIRO@cpan.org>',
    'clean'		=> $clean,
);
