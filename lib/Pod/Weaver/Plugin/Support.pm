package Pod::Weaver::Section::Support;

# ABSTRACT: add a SUPPORT pod section

use Moose 1.01;
use Moose::Autobox 0.10;

use Pod::Weaver::Role::Section 3.100710;
with 'Pod::Weaver::Role::Section';

sub weave_section {
	my ($self, $document, $input) = @_;
	my $zilla = $input->{zilla} or return;

	my $dist = $zilla->name;
	my $first_char = substr( $dist, 0, 1 );
	my $lc_dist = lc( $dist );
	my $perl_name = $dist;
	$perl_name =~ s/-/::/g;
	my $repository = $zilla->distmeta->{resources}{repository} or die 'repository not present in distmeta';

	$document->children->push(
		Pod::Elemental::Element::Nested->new( {
			command => 'head1',
			content => 'SUPPORT',
			children => [
				Pod::Elemental::Element::Pod5::Ordinary->new( {
					content => <<EOPOD,
You can find documentation for this module with the perldoc command.

	perldoc $perl_name
EOPOD
				} ),
				Pod::Elemental::Element::Nested->new( {
					command => 'head2',
					content => 'Websites',
					children => [
						Pod::Elemental::Element::Pod5::Ordinary->new( {
							content => <<EOPOD,
=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/$dist>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/$dist>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/$dist>

=item * CPAN Forum

L<http://cpanforum.com/dist/$dist>

=item * RT: CPAN's Bug Tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=$dist>

=item * CPANTS Kwalitee

L<http://cpants.perl.org/dist/overview/$dist>

=item * CPAN Testers Results

L<http://cpantesters.org/distro/$first_char/$dist.html>

=item * CPAN Testers Matrix

L<http://matrix.cpantesters.org/?dist=$dist>

=item * Source Code Repository

The code is open to the world, and available for you to hack on. Please feel free to browse it and pull
from it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<$repository>

=back
EOPOD
						} ),
					],
				} ),
				Pod::Elemental::Element::Nested->new( {
					command => 'head2',
					content => 'Bugs',
					children => [
						Pod::Elemental::Element::Pod5::Ordinary->new( {
							content => <<EOPOD,
Please report any bugs or feature requests to C<bug-$lc_dist at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=$dist>.  I will be
notified, and then you'll automatically be notified of progress on your bug as I make changes.
EOPOD
						} ),
					],
				} ),
			],
		} ),
	);
}

1;

=pod

=head1 DESCRIPTION

This section plugin will produce a hunk of pod that lists the common support websites
and an explanation of how to report bugs.

=cut

