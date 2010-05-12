package Dist::Zilla::PluginBundle::Apocalyptic;

# ABSTRACT: Let the apocalypse build your dist!

use Moose 1.01;
use File::Spec 3.31;
use File::HomeDir 0.88;

# TODO wait for improved Moose that allows "with 'Foo::Bar' => { -version => 1.23 };"
use Dist::Zilla::Role::PluginBundle::Easy 2.101310;
with 'Dist::Zilla::Role::PluginBundle::Easy';

# The plugins we use
use Dist::Zilla::Plugin::BumpVersionFromGit 0.006;
use Dist::Zilla::Plugin::GatherDir 2.101310;
use Dist::Zilla::Plugin::PruneCruft 2.101310;
use Dist::Zilla::Plugin::AutoPrereq 2.101310;
use Dist::Zilla::Plugin::GenerateFile 2.101310;
use Dist::Zilla::Plugin::ManifestSkip 2.101310;
use Dist::Zilla::Plugin::CompileTests 1.100740;
use Dist::Zilla::Plugin::ApocalypseTests 0.01;
use Dist::Zilla::Plugin::Prepender 1.100960;
use Dist::Zilla::Plugin::Authority 0.01;
use Dist::Zilla::Plugin::PkgVersion 2.101310;
use Dist::Zilla::Plugin::PodWeaver 3.100710;
use Pod::Weaver::PluginBundle::Apocalyptic 0.001;
use Dist::Zilla::Plugin::NextRelease 2.101310;
use Dist::Zilla::Plugin::ChangelogFromGit 0.002;
use Dist::Zilla::Plugin::ExecDir 2.101310;
use Dist::Zilla::Plugin::ShareDir 2.101310;
use Dist::Zilla::Plugin::MinimumPerl 0.02;
use Dist::Zilla::Plugin::MetaProvides::Package 1.10001919;
use Dist::Zilla::Plugin::Bugtracker 1.100701;
use Dist::Zilla::Plugin::Homepage 1.100700;
use Dist::Zilla::Plugin::MetaConfig 2.101310;
use Dist::Zilla::Plugin::Repository 0.11;
use Dist::Zilla::Plugin::MetaResources 2.101310;
use Dist::Zilla::Plugin::MetaNoIndex 1.101130;
use Dist::Zilla::Plugin::License 2.101310;
use Dist::Zilla::Plugin::MakeMaker 2.101310;
use Dist::Zilla::Plugin::ModuleBuild 2.101310;
use Dist::Zilla::Plugin::DualBuilders 0.02;
use Dist::Zilla::Plugin::MetaYAML 2.101310;
use Dist::Zilla::Plugin::MetaJSON 2.101310;
use Dist::Zilla::Plugin::ReadmeFromPod 0.09;
use Dist::Zilla::Plugin::InstallGuide 1.100701;
use Dist::Zilla::Plugin::Signature 1.100930;
use Dist::Zilla::Plugin::Manifest 2.101310;
use Dist::Zilla::Plugin::Git::Check 1.100970;
use Dist::Zilla::Plugin::ConfirmRelease 2.101310;
use Dist::Zilla::Plugin::UploadToCPAN 2.101310;
use Dist::Zilla::Plugin::FakeRelease 2.101310;
use Dist::Zilla::Plugin::ArchiveRelease 0.09;
use Dist::Zilla::Plugin::Git::Commit 1.100970;
use Dist::Zilla::Plugin::Git::Tag 1.100970;
use Dist::Zilla::Plugin::Git::Push 1.100970;

sub configure {
	my $self = shift;
	my $args = $self->payload;

	# We need the pauseid
	my $pauseid = $args->{pauseid} or die "PAUSEID is required";

#	; -- start off by bumping the version
	$self->add_plugins( [ 'BumpVersionFromGit' => {
		'version_regexp' => '^release-(.+)$',
	} ] );

#	; -- start the basic dist skeleton
	$self->add_plugins( qw(
		GatherDir
		PruneCruft
		AutoPrereq
	),
	[
		'GenerateFile', 'MANIFEST.SKIP', {
			'filename'	=> 'MANIFEST.SKIP',
			'content'	=> <<'EOC',
# Added by Dist::Zilla::PluginBundle::Apocalyptic

# skip Eclipse IDE stuff
\.includepath$
\.project$
\.settings/

# Avoid version control files.
\bRCS\b
\bCVS\b
,v$
\B\.svn\b
\B\.git\b
^\.gitignore$

# Avoid configuration metadata file
^MYMETA\.

# Avoid Makemaker generated and utility files.
^Makefile$
^blib/
^MakeMaker-\d
\bpm_to_blib$
^blibdirs$

# Avoid Module::Build generated and utility files.
\bBuild$
\bBuild.bat$
\b_build
\bBuild.COM$
\bBUILD.COM$
\bbuild.com$

# Avoid temp and backup files.
~$
\.old$
\#$
^\.#
\.bak$

# our tarballs
\.tar\.gz$
^releases/
EOC
		}
	],
	[
		'ManifestSkip' => {
			'skipfile' => 'MANIFEST.SKIP',
		}
	] );

#	; -- Generate our tests
	$self->add_plugins( qw(
		CompileTests
		ApocalypseTests
	) );

#	; -- munge files
	$self->add_plugins(
	[
		'Prepender' => {
			'copyright'	=> 1,
			'line'		=> 'use strict; use warnings;',
		}
	],
	[
		'Authority' => {
			'authority'	=> 'cpan:' . $pauseid,
			'do_metadata'	=> 1,
		}
	],
		'PkgVersion',
	[
		'PodWeaver' => {
			'config_plugin' => '@Apocalyptic',
		}
	], );

#	; -- update the Changelog
	$self->add_plugins(
	[
		'NextRelease' => {
			'time_zone'	=> 'UTC',
			'filename'	=> 'Changes',
			'format'	=> '* %v%n%tReleased: %{yyyy-MM-dd HH:mm:ss VVVV}d',
		}
	],
	[
		'ChangelogFromGit' => {
			'tag_regexp'	=> '^release-(.+)$',
			'file_name'	=> 'CommitLog',
		}
	], );

#	; -- generate/process meta-information
	if ( -d 'bin' ) {
		$self->add_plugins( [ 'ExecDir' => {
			'dir'	=> 'bin',
		} ] );
	}
	if ( -d 'share' ) {
		$self->add_plugins( [ 'ShareDir' => {
			'dir'	=> 'bin',
		} ] );
	}
	$self->add_plugins( qw(
		MinimumPerl
		MetaProvides::Package
		Bugtracker
		Homepage
		MetaConfig
	),
	[
		'Repository' => {
			'git_remote' => 'origin',
		}
	],
	[
		'MetaResources' => {
			# TODO add the usual list of stuff found in my POD? ( cpants, bla bla )
			# seen in DZPB::AVAR - Ratings => "http://cpanratings.perl.org/d/$dist"
			# seen in DZPB::PDONELAN - ratings ( lc R... which should I pick? hah )
			'license'	=> 'http://dev.perl.org/licenses/',
		}
	], );

#	; -- generate meta files
	my @dirs;
	foreach my $d ( qw( inc t xt examples share ) ) {
		push( @dirs, $d ) if -d $d;
	}
	$self->add_plugins(
	[
		'MetaNoIndex' => {
			'directory' => \@dirs,
		}
	],
	qw(
		License
		MakeMaker
		ModuleBuild
	),
	[
		'DualBuilders' => {
			'prefer' => 'build',
		}
	],
	qw(
		MetaYAML
		MetaJSON
		ReadmeFromPod
		InstallGuide
	), );

	# TODO How do we detect a configured Module::Signature?
#	$self->add_plugin( 'Signature' => {
#		'sign' => 'always',
#	} );
	$self->add_plugins( 'Manifest' );

#	; -- pre-release
	$self->add_plugins(
	[
		'Git::Check' => {
			'changelog'	=> 'Changes',
		}
	],
		'ConfirmRelease',
	);

#	; -- release
	if ( -e File::Spec->catfile( File::HomeDir->my_home, '.pause' ) or -e File::Spec->catfile( '.', '.pause' ) ) {
		$self->add_plugins( 'UploadToCPAN' );
	} else {
		warn 'No .pause file detected, using FakeRelease!';
		$self->add_plugins( 'FakeRelease' );
	}

#	; -- post-release
	$self->add_plugins(
	[
		'ArchiveRelease' => {
			'directory' => 'releases',
		}
	],
	[
		'Git::Commit' => {
			'changelog'	=> 'Changes',
			'commit_msg'	=> 'New CPAN release of %N - v%v',
		}
	],
	[
		'Git::Tag' => {
			'tag_format'	=> 'release-%v',
			'tag_message'	=> 'Tagged release-%v',
		}
	],
	[
		'Git::Push' => {
			# TODO add "github", "gitorious" support somehow... introspect the Git config?
			'push_to'	=> 'origin',
		}
	], );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=pod

=for Pod::Coverage
configure

=head1 DESCRIPTION

This plugin bundle attempts to automate as much as sanely possible the job of building your dist. It builds upon
L<Dist::Zilla> and utilizes numerous plugins to reduce the burden on the programmer.

	# In your dist.ini:
	name			= My-Super-Cool-Dist
	author			= A. U. Thor
	license			= Perl_5
	copyright_holder	= A. U. Thor
	[@Apocalyptic]
	pauseid = THOR

This is equivalent to setting this in your dist.ini:

	# Skipping the usual name/author/license/copyright stuff

	; -- start off by bumping the version
	[BumpVersionFromGit]		; find the last tag, and bump to next version via Version::Next
	version_regexp = ^release-(.+)$

	; -- start the basic dist skeleton
	[AllFiles]			; we start with everything in the dist dir
	[PruneCruft]			; automatically prune cruft defined by RJBS :)
	[AutoPrereq]			; automatically find our prereqs
	[GenerateFile / MANIFEST.SKIP]	; make our default MANIFEST.SKIP
	[ManifestSkip]			; skip files that matches MANIFEST.SKIP
	skipfile = MANIFEST.SKIP

	; -- Generate our tests
	[CompileTests]			; Create a t/00-compile.t file that auto-compiles every module in the dist
	[ApocalypseTests]		; Create a t/apocalypse.t file that runs Test::Apocalypse

	; -- munge files
	[Prepender]			; automatically add lines following the shebang in modules
	copyright = 1
	line = use strict; use warnings;
	[Authority]			; put the $AUTHORITY line in modules
	authority = cpan:PAUSEID
	do_metadata = 1
	[PkgVersion]			; put the "our $VERSION = ...;" line in modules
	[PodWeaver]			; weave our POD and add useful boilerplate
	config_plugin = @Apocalyptic

	; -- update the Changelog
	[NextRelease]
	time_zone = UTC
	filename = Changes
	format = * %v%n%tReleased: %{yyyy-MM-dd HH:mm:ss VVVV}d
	[ChangelogFromGit]		; generate CommitLog from git history
	tag_regexp = ^release-(.+)$
	file_name = CommitLog

	; -- generate/process meta-information
	[MinimumPerl]			; automatically find the minimum perl version required and add it to prereqs
	[ExecDir]			; automatically install files from bin/ directory as executables ( if it exists )
	dir = bin
	[ShareDir]			; automatically install File::ShareDir files from share/ ( if it exists )
	dir = share
	[MetaProvides::Package]		; get provides from package definitions in files
	[Bugtracker]			; set bugtracker to http://rt.cpan.org/Public/Dist/Display.html?Name=$dist
	[Repository]			; set git repository path by looking at git configs
	git_remote = origin
	[Homepage]			; set homepage to http://search.cpan.org/dist/$dist/
	[MetaResources]			; add arbitrary resources to metadata
	license = http://dev.perl.org/licenses/
	[MetaConfig]			; dump dzil config into metadata

	; -- generate meta files
	[MetaNoIndex]			; tell PAUSE to not index those stuff ( if it exists )
	directory = inc
	directory = t
	directory = xt
	directory = examples
	directory = share
	[License]			; create LICENSE file
	[MakeMaker]			; create Makefile.PL file
	[ModuleBuild]			; create Build.PL file
	[DualBuilders]			; have M::B and EU::MM but select only M::B as prereq
	prefer = build
	[MetaYAML]			; create META.yml file
	[MetaJSON]			; create META.json file
	[ReadmeFromPod]			; create README file
	[InstallGuide]			; create INSTALL file
	[Signature]			; create SIGNATURE file when we are building ( if Module::Signature is setup )
	sign = always
	[Manifest]			; finally, create the MANIFEST file

	; -- pre-release
	[Git::Check]			; check working path for any uncommitted stuff ( exempt Changes because it will be committed after release )
	changelog = Changes
	[ConfirmRelease]		; double-check that we ACTUALLY want a release, ha!

	; -- release
	[UploadToCPAN]			; upload your dist to CPAN using CPAN::Uploader ( if .pause file exists in HOME dir or dist dir )

	; -- post-release
	[ArchiveRelease]		; archive our tarballs under releases/
	directory = releases
	[Git::Commit]			; commit the dzil-generated stuff
	changelog = Changes
	commit_msg = New CPAN release of %N - v%v
	[Git::Tag]			; tag our new release
	tag_format = release-%v
	tag_message = Tagged release-%v
	[Git::Push]			; automatically push to the "origin" defined in .git/config
	push_to = origin

However, this plugin bundle does A LOT of things, so you would need to read the config carefully to see if it does
anything you don't want to do. You can override the options simply by removing the offending plugin from the bundle
by using the L<Dist::Zilla::PluginBundle::Filter> package. By doing that you are free to specify alternate plugins,
or the desired plugin configuration manually.

	# In your dist.ini:
	name			= My-Super-Cool-Dist
	author			= A. U. Thor
	license			= Perl_5
	copyright_holder	= A. U. Thor

	; we don't want to archive our releases
	; we want to push to gitorious instead
	[@Filter]
	bundle = @Apocalyptic
	remove = ArchiveRelease
	remove = Git::Push
	[Git::Push]
	push_to = gitorious

=head2 Attributes

You can pass various attributes to this module in F<dist.ini> and they are:

=head3 pauseid

The PAUSE id you want to use when building the dist. As of now it's only used for the L<Dist::Zilla::Plugin::Authority> plugin but
in the future there might be other uses for it. Required.

=head2 Plugins considered for inclusion but rejected

=head3 CheckChangeLog

It doesn't like my Changes format and my L<Test::Apocalypse> suite already checks for Changelog stuff...

=head3 PerlTidy

I never use PerlTidy myself, so this is irrelevant

=head3 *Tests

My ApocalypseTests plugin handles most of this, and if I find any useful ones I will add it to L<Test::Apocalypse> instead of adding yet another plugin.

=head3 ReportVersions

This seems nifty, but do I *really* need it? CPANTesters already does a good job of reporting prereqs when it submits a report...

=head1 SEE ALSO

L<Dist::Zilla>

=cut
