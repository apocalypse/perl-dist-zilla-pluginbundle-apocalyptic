package Dist::Zilla::MintingProfile::Author::APOCAL;

# ABSTRACT: Mint distributions like Apocalypse does

# ETHER++ I plagarized her code :)
use Moose;
with 'Dist::Zilla::Role::MintingProfile';
use File::ShareDir;
use Path::Class;        # sadly, we still need to use Path::Class :(
use Carp qw( confess );

sub profile_dir {
	my ($self, $profile_name) = @_;
	$profile_name /= 'default';
	die 'minting requires perl 5.014' unless $] >= 5.013002;
	my $dist_name = 'Dist-Zilla-PluginBundle-Apocalyptic';
	my $profile_dir = dir( File::ShareDir::dist_dir($dist_name) )->subdir( 'profiles', $profile_name );
	return $profile_dir if -d $profile_dir;
	confess "Can't find profile $profile_name via $self: it should be in $profile_dir";
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=pod

=head1 SYNOPSIS

	dzil new -P Author::APOCAL Foo::Bar

=head1 DESCRIPTION

Apocalypse's MintingProfile :)

=cut
