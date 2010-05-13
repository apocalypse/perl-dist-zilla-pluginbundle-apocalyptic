package Pod::Weaver::PluginBundle::Apocalyptic;

# ABSTRACT: Let the apocalypse generate your POD!

use Pod::Weaver::Config::Assembler 3.100710;

# The plugins we use
use Pod::Weaver::Section::SeeAlso;
use Pod::Weaver::Section::Support 0.006;

sub _exp {
	Pod::Weaver::Config::Assembler->expand_package( $_[0] );
}

sub mvp_bundle_config {
	return (
		# some basics we need
		[ '@Apocalyptic/CorePrep',	_exp('@CorePrep'), {} ],

		# Move our special markers to the start of the POD
		[ '@Apocalyptic/PodCoverage',	_exp('Region'), {
			region_name	=> 'Pod::Coverage',
			allow_nonpod	=> 1,
			flatten		=> 0,
		} ],
		[ '@Apocalyptic/PodSpelling',	_exp('Region'), {
			region_name	=> 'stopwords',
			allow_nonpod	=> 1,
			flatten		=> 0,
		} ],

		# Start the POD!
		[ '@Apocalyptic/Name',		_exp('Name'), {} ],
		[ '@Apocalyptic/Version',	_exp('Version'), {
			format		=> 'This document describes v%v of %m - released %{LLLL dd, yyyy}d as part of %r.',
			is_verbatim	=> 1,
		} ],

		# The standard sections
		[ '@Apocalyptic/Synopsis',	_exp('Generic'), {
			header		=> 'SYNOPSIS',
		} ],
		[ '@Apocalyptic/Description',	_exp('Generic'), {
			header		=> 'DESCRIPTION',
#			required	=> 1, # TODO huh? it doesn't work for dzpb::apocalyptic?
		} ],
		[ '@Apocalyptic/Overview',	_exp('Generic'), {
			header		=> 'OVERVIEW',
		} ],

		# Our subs
		[ '@Apocalyptic/Attributes',	_exp('Collect'), {
			header		=> 'ATTRIBUTES',
			command		=> 'attr',
		} ],
		[ '@Apocalyptic/Methods',	_exp('Collect'), {
			header		=> 'METHODS',
			command		=> 'method',
		} ],
		[ '@Apocalyptic/Functions',	_exp('Collect'), {
			header		=> 'FUNCTIONS',
			command		=> 'func',
		} ],

		# Anything that wasn't matched gets dumped here
		[ '@Apocalyptic/Leftovers',	_exp('Leftovers'), {} ],

		# The usual end of POD...
		[ '@Apocalyptic/SeeAlso',	_exp('SeeAlso'), {} ],
		[ '@Apocalyptic/Support',	_exp('Support'), {} ],
		[ '@Apocalyptic/Authors',	_exp('Authors'), {} ],
		[ '@Apocalyptic/Legal',		_exp('Legal'), {
			filename	=> 'LICENSE',
		} ],

		# Mangle the entire POD
		[ '@Apocalyptic/ListTransformer',	_exp('-Transformer'), {
			transformer	=> 'List',
		} ],

		# TODO this concept needs more work...
#		[ '@Apocalyptic/ImageTransformer',	_exp('-Transformer'), {
#			transformer	=> 'Images',
#		} ],
	);
}

1;

=pod

=for Pod::Coverage
mvp_bundle_config

=head1 DESCRIPTION

This is the bundle used by default (specifically by Pod::Weaver's
C<new_with_default_config> method).  It may change over time, but should remain
fairly conservative and straightforward.

It is nearly equivalent to the following:

  [@CorePrep]

  [Name]
  [Version]

  [Region  / prelude]

  [Generic / SYNOPSIS]
  [Generic / DESCRIPTION]
  [Generic / OVERVIEW]

  [Collect / ATTRIBUTES]
  command = attr

  [Collect / METHODS]
  command = method

  [Collect / FUNCTIONS]
  command = func

  [Leftovers]

  [Region  / postlude]

  [Authors]
  [Legal]

=head1 TODO

What I want to do is...

=head2 Add "ACKNOWLEDGEMENTS" as sub-section of AUTHOR

So I can give the proper props :)

=head2 auto image in POD?

=begin HTML
<p><img src="http://i.imgur.com/Hb2cD.png" width="600"></p>
=end HTML

Saw that in http://search.cpan.org/~wonko/Smolder-1.51/lib/Smolder.pm

Maybe we can make a transformer to automatically do that? ( =image http://blah.com/foo.png )

<jhannah> Apocalypse: ya, right? cool and dangerous and prone to FAIL as URLs become invalid... :/
<jhannah> I'd hate to see craptons of broken images on s.c.o   :(
<Apocalypse> Yeah jhannah it would be best if you could include the image in the dist itself... but that's a problem for another day :)
<jhannah> Apocalypse: it'd be trivial to include the .jpg in the .tgz... but what's the POD markup for that? and would s.c.o. do it correctly?
<jhannah> =begin HTML is ... eep
<Apocalypse> I think you could do it via sneaky means but it's prone to breakage
<Apocalypse> i.e. include it in dist as My-Foo-Dist/misc/image.png and link to it via s.c.o's "browse dist" directory
<Apocalypse> i.e. link to http://cpansearch.perl.org/src/WONKO/Smolder-1.51/misc/image.png
<Apocalypse> I should try that sneaky tactic and see if it works =]

=cut
