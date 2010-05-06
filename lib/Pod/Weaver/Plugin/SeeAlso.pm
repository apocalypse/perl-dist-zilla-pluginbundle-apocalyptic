package Pod::Weaver::Section::SeeAlso;

# ABSTRACT: add a SEE ALSO pod section

use Moose 1.01;
use Moose::Autobox 0.10;

use Pod::Weaver::Role::Section 3.100710;
with 'Pod::Weaver::Role::Section';

sub weave_section {
	my ($self, $document, $input) = @_;
	my $zilla = $input->{zilla} or return;
	my $main = $zilla->main_module;

	# Is this the main module POD?
	use Data::Dumper;
	print Dumper( $document );
	die 'footastic';
#	foreach my $para ( @{ $document->children } ) {
#		next unless $para->isa('Pod::Elemental::Element::Pod5::Region')
#			and $para->is_pod
#			and $para->format_name eq 'NAME';
#
#		if ( $para->content


	# Get any text already in the POD and append it to our hunk


	$document->children->push(
		Pod::Elemental::Element::Nested->new( {
			command => 'head1',
			content => 'SEE ALSO',
			children => [
				Pod::Elemental::Element::Pod5::Ordinary->new( {
					content => <<EOPOD,
None.
EOPOD
				} ),
			],
		} ),
	);
}

1;

=pod

=head1 DESCRIPTION

This section plugin will produce a hunk of pod that references the main module of a dist
from it's submodules and adds any other text already present in the pod.

=cut

