package Pod::Weaver::PluginBundle::Apocalyptic;

# ABSTRACT: Let the apocalypse generate your POD!

use Pod::Weaver::Config::Assembler 3.100710;

sub _exp {
	Pod::Weaver::Config::Assembler->expand_package( $_[0] );
}

sub mvp_bundle_config {
	return (
		# some basics we need
		[ '@Apocalyptic/CorePrep',	_exp('@CorePrep'), {} ],
		[ '@Apocalyptic/TransformList',	_exp('Transformer'), {
			transformer => 'List',
			format_name => 'outline',
		} ],

		# Start the POD!
		[ '@Apocalyptic/Name',		_exp('Name'), {} ],
		[ '@Apocalyptic/Version',	_exp('Version'), {} ],
		[ '@Apocalyptic/Prelude',	_exp('Region'), {
			region_name => 'prelude',
		} ],

		# The standard sections
		[ 'SYNOPSIS',		_exp('Generic'), {} ],
		[ 'DESCRIPTION',	_exp('Generic'), {} ],
		[ 'OVERVIEW',		_exp('Generic'), {} ],

		# Our subs
		[ 'ATTRIBUTES',		_exp('Collect'), {
			command => 'attr',
		} ],
		[ 'METHODS',		_exp('Collect'), {
			command => 'method',
		} ],
		[ 'FUNCTIONS',		_exp('Collect'), {
			command => 'func',
		} ],

		# The rest of the POD...
		[ '@Apocalyptic/Leftovers',	_exp('Leftovers'), {} ],
		[ '@Apocalyptic/Postlude',	_exp('Region'), {
			region_name => 'postlude',
		} ],

		# The usual end of POD...
		# TODO only do this for the main module?
		[ '@Apocalyptic/SeeAlso',	_exp('SeeAlso'), {} ],
		[ '@Apocalyptic/Support',	_exp('Support'), {} ],
		[ '@Apocalyptic/Authors',	_exp('Authors'), {} ],
		[ '@Apocalyptic/Legal',		_exp('Legal'), {} ],
	);
}

1;

=pod

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

=head2 Add my usual SUPPORT section automatically

This only exists in the main module, not submodules

also, automatically add the =for pod_spelling FOO BAR BAZ stuff preceding it

=head2 Add DISCLAIMER OF WARRANTY head1 section

DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

( Where can I get this text? Software::License? )

Also, this exists only in the main module

=head2 munge the LICENSE section a bit

I want to add the "The license can also be read in LICENSE in this dist..." under the auto-generated license section

=head2 SEE ALSO section

Automatically add a link from submodules to main module + whatever was specified if the section existed

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
