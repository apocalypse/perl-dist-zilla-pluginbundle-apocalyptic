package Pod::Elemental::Transformer::Images;

# ABSTRACT: transform :image regions into proper HTML links

use Moose 1.01;
use Moose::Autobox 0.10;
use namespace::autoclean 0.09;

# TODO wait for improved Moose that allows "with 'Foo::Bar' => { -version => 1.23 };"
use Pod::Elemental::Transformer 0.100220;
with 'Pod::Elemental::Transformer';

use Pod::Elemental::Element::Pod5::Command 0.100220;
use Pod::Elemental::Types 0.100220 qw( FormatName );

has format_name => (
	is  => 'ro',
	isa => FormatName,
	default => 'image',
);

has dist => (
	is => 'ro',
	isa => 'Str',
);

sub transform_node {
	my( $self, $node ) = @_;

use Data::Dumper::Concise;
print Dumper( $self, $node );
die 'frobnicate';

	for my $i ( reverse( 0 .. $#{ $node->children } ) ) {
		my $para = $node->children->[ $i ];
		next unless $self->__is_xformable($para);
		my @replacements = $self->_expand_image_paras( $para->children );
		splice @{ $node->children }, $i, 1, @replacements;
	}
}

sub __is_xformable {
	my ($self, $para) = @_;

	return unless $para->isa('Pod::Elemental::Element::Pod5::Region')
		and $para->format_name eq $self->format_name;

	die "image regions must be pod (=for :" . $self->format_name . ")"
		unless $para->is_pod;

	return 1;
}

sub _expand_image_paras {
	my ($self, $paras) = @_;

	# We must have one node, and it is an ordinary one...
	die 'image regions must follow the exact format!' if $paras->length > 1
		or ! $paras->[0]->isa( 'Pod::Elemental::Element::Pod5::Ordinary' );

	# Okay, get the content and figure out what to do
	my $content = $paras->[0]->content;
	if ( $content =~ /^http/ ) {
		# Convert to a HTML link to the content
		$content = '<p><img src="' . $content . '"></p>';
	} else {
		# Assume a local file in the dist, use the search.cpan.org local dist trick

		# Argh, introspect the POD for the dist name
		$content = "foobar $content foobar";
	}

	# Set the new HTML region
	return Pod::Elemental::Element::Pod5::Region->new( {
		format_name => 'HTML',
		content => '',
		children => [
			Pod::Elemental::Element::Pod5::Ordinary->new( {
				content => $content,
			} ),
		],
	} );
}

1;
__END__

  my $type;
  my $i = 1;

  PARA: for my $para (@$paras) {
    unless ($para->isa('Pod::Elemental::Element::Pod5::Ordinary')) {
      push @replacements, $self->__is_xformable($para)
         ? $self->_expand_list_paras($para->children)
         : $para;

      next PARA;
    }

    my $pip = q{}; # paragraph in progress
    my @lines = split /\n/, $para->content;

    LINE: for my $line (@lines) {
      if (my ($prefix, $rest) = $line =~ m{^(=|\*|(?:[0-9]+\.))\s+(.+)$}) {
        if (length $pip) {
          push @replacements, Pod::Elemental::Element::Pod5::Ordinary->new({
            content => $pip,
          });
        }

        $prefix = '0' if $prefix =~ /^[0-9]/;
        my $line_type = $_TYPE{ $prefix };
        $type ||= $line_type;

        confess("mismatched list types; saw $line_type marker after $type")
          if $line_type ne $type;

        my $method = "__paras_for_$type\_marker";
        my ($marker, $leftover) = $self->$method($rest, $i++);
        push @replacements, $marker;
        if (defined $leftover and length $leftover) {
          push @replacements, Pod::Elemental::Element::Pod5::Ordinary->new({
            content => $leftover,
          });
        }
        $pip = q{};
      } else {
        $pip .= "$line\n";
      }
    }

    if (length $pip) {
      push @replacements, Pod::Elemental::Element::Pod5::Ordinary->new({
        content => $pip,
      });
    }
  }

  unshift @replacements, Pod::Elemental::Element::Pod5::Command->new({
    command => 'over',
    content => 4,
  });

  push @replacements, Pod::Elemental::Element::Pod5::Command->new({
    command => 'back',
    content => '',
  });

  return @replacements;
}

1;

__END__
=pod

=head1 NAME

Pod::Elemental::Transformer::List - transform :list regions into =over/=back to save typing

=head1 VERSION

version 0.093580

=head1 SYNOPSIS

By transforming your L<Pod::Elemental::Document> like this:

  my $xform = Pod::Elemental::Transfomer::List->new;
  $xform->transform_node($pod_document);

You can then produce traditional Pod5 lists by using C<:list> regions like
this:

  =for :list
  * Doe
  a (female) deer
  * Ray
  a drop of golden sun

The behavior of list regions is slighly complex, and described L<below|/LIST
REGION PARSING>.

=for :image http://www.perlfoundation.org/data/workspaces/perlfoundation/attachments/perl_trademark:20061112062117-1-29352/files/perl_powered-1.png

=head1 ATTRIBUTES

=head2 format_name

This attribute, which defaults to "list" is the region format that will be
processed by this transformer.

=head1 LIST REGION PARSING

There are three kinds of lists: numbered, bulleted, and definition.  Every list
must be only one kind of list.  Trying to mix list styles will result in an
exception during transformation.

Lists can be written as a single paragraph beginning C<< =for :list >> or a
region marked off with C<< =begin :list >> and C<< =end :list >>.  The content
allowed in each of those two types is defined by the L<Pod
specification|perlpodspec> but boils down to this: "for" regions will only be
able to contain list markers and paragraphs of text, while "begin and end"
regions can contain arbitrary Pod paragraphs and nested list regions.

Ordinary paragraphs in list regions are scanned for lines beginning with list
item markers (see below).  If they're found, the list is broken into paragraphs
and markers.  Here's a demonstrative example:

  =for :list
  * Doe
  a deer,
  a female deer
  * Ray
  a drop of golden sun
  or maybe it's a golden
  drop of sun

The above is equivalent to

  =begin :list

  * Doe
  a deer,
  a female deer
  * Ray
  a drop of golden sun
  or maybe it's a golden
  drop of sun

  =end :list

It will be transformed into:

  =over 4

  =item *

  Doe

  a deer,
  a female deer

  =item *

  Ray

  a drop of golden sun
  or maybe it's a golden
  drop of sun

In other words: the B<C<*>> indicates a new bullet.  The rest of the line is
made into one paragraph, which will become the text of the bullet point when
rendered.  (Yeah, Pod is weird.)  All subsequent lines without markers will be
kept together as one paragraph.

Asterisks mark off bullet list items.  Numbered lists are marked off with
"C<1.>" (or any number followed by a dot).  Equals signs mark off definition
lists.  The markers must be followed by a space.

Here's a numbered list:

  =for :list
  1. bell
  2. book
  3. candle

The choice of number doesn't matter.  The generated Pod C<=item> commands will
start with 1 and increase by 1 each time.

Definition lists are unusual in that the text on the line after a item marker
will be used as the bullet, rather than the next paragraph.  So this input:

  =begin :list

  = benefits

  There are more benefits than can be listed here.

  =end :list

Or this input:

  =for :list
  = benefits
  There are more benefits than can be listed here.

Will become the following output Pod:

  =over 4

  =item benefits

  There are more benefits than can be listed here

  =back

If you want to nest lists, you have to make the outer list a begin/end region,
like this:

  =begin :list

  * first outer item

  * second outer item

  =begin :list

  1. first inner item

  2. second inner item

  =end :list

  * third outer item

  =end :list

The inner list, above, could have been written as a compact "for" region.

=head1 AUTHOR

  Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

