package Dist::Zilla::PluginBundle::Apocalyptic;

# ABSTRACT: Let the apocalypse build your dist!

use Moose 1.01;
use File::Spec 3.31;
use File::HomeDir 0.88;

# TODO wait for improved Moose that allows "with 'Foo::Bar' => { -version => 1.23 };"
use Dist::Zilla::Role::PluginBundle::Easy 2.101310;
with 'Dist::Zilla::Role::PluginBundle::Easy';

# The plugins we use ( excluding ones bundled in dzil )
use Dist::Zilla::Plugin::BumpVersionFromGit 0.006;
use Dist::Zilla::Plugin::CompileTests 1.100740;
use Dist::Zilla::Plugin::ApocalypseTests 0.01;
use Dist::Zilla::Plugin::Prepender 1.100960;
use Dist::Zilla::Plugin::Authority 0.01;
use Dist::Zilla::Plugin::PodWeaver 3.100710;
use Pod::Weaver::PluginBundle::Apocalyptic;	# TODO put it in a separate dist so I can specify the ver...
use Dist::Zilla::Plugin::ChangelogFromGit 0.002;
use Dist::Zilla::Plugin::MinimumPerl 0.02;
use Dist::Zilla::Plugin::MetaProvides::Package 1.10001919;
use Dist::Zilla::Plugin::Bugtracker 1.100701;
use Dist::Zilla::Plugin::Homepage 1.100700;
use Dist::Zilla::Plugin::Repository 0.13;
use Dist::Zilla::Plugin::MetaNoIndex 1.101130;
use Dist::Zilla::Plugin::License 2.101310;
use Dist::Zilla::Plugin::DualBuilders 0.02;
use Dist::Zilla::Plugin::ReadmeFromPod 0.09;
use Dist::Zilla::Plugin::InstallGuide 1.100701;
use Dist::Zilla::Plugin::Signature 1.100930;
use Dist::Zilla::Plugin::Manifest 2.101310;
use Dist::Zilla::Plugin::CheckChangesHasContent 0.003;
use Dist::Zilla::Plugin::Git 1.101330;
use Dist::Zilla::Plugin::ArchiveRelease 0.09;
use Dist::Zilla::Plugin::ReportVersions::Tiny 1.00;

=attr pauseid

The PAUSE id you want to use when building the dist. As of now it's only used for the L<Dist::Zilla::Plugin::Authority> plugin but
in the future there might be other uses for it.

The default is: APOCAL

=cut

has 'pauseid' => (
	is => 'ro',
	isa => 'Str',
	default => 'APOCAL',
);

sub configure {
	my $self = shift;

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
# Added by Dist::Zilla::PluginBundle::Apocalyptic v{{$Dist::Zilla::PluginBundle::Apocalyptic::VERSION}}

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
		ReportVersions::Tiny
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
			'authority'	=> 'cpan:' . $self->pauseid,
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
			'format'	=> '%v%n%tReleased: %{yyyy-MM-dd HH:mm:ss VVVV}d',
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
	),
	[
		'Signature' => {
			'sign' => 'release',
		}
	],
		'Manifest',
	);

#	; -- pre-release
	$self->add_plugins(
	[
		'CheckChangesHasContent' => {
			'changelog'	=> 'Changes',
		}
	],
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
			'commit_msg'	=> 'New CPAN release of %N - v%v%n%n%c',
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
	[GatherDir]			; we start with everything in the dist dir
	[PruneCruft]			; automatically prune cruft defined by RJBS :)
	[AutoPrereq]			; automatically find our prereqs
	[GenerateFile / MANIFEST.SKIP]	; make our default MANIFEST.SKIP
	[ManifestSkip]			; skip files that matches MANIFEST.SKIP
	skipfile = MANIFEST.SKIP

	; -- Generate our tests
	[CompileTests]			; Create a t/00-compile.t file that auto-compiles every module in the dist
	[ApocalypseTests]		; Create a t/apocalypse.t file that runs Test::Apocalypse
	[ReportVersions::Tiny]		; Report the versions of our prereqs

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
	format = %v%n%tReleased: %{yyyy-MM-dd HH:mm:ss VVVV}d
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
	[Signature]			; create SIGNATURE file when we are releasing ( annoying to enter password during test builds... )
	sign = release
	[Manifest]			; finally, create the MANIFEST file

	; -- pre-release
	[CheckChangesHasContent]	; make sure you explained your changes :)
	changelog = Changes
	[Git::Check]			; check working path for any uncommitted stuff ( exempt Changes because it will be committed after release )
	changelog = Changes
	[ConfirmRelease]		; double-check that we ACTUALLY want a release, ha!

	; -- release
	[UploadToCPAN]			; upload your dist to CPAN using CPAN::Uploader ( if .pause file exists in HOME dir or dist dir )
					; if not, we will use [FakeRelease] so you can still release :)

	; -- post-release
	[ArchiveRelease]		; archive our tarballs under releases/
	directory = releases
	[Git::Commit]			; commit the dzil-generated stuff
	changelog = Changes
	commit_msg = New CPAN release of %N - v%v%n%n%c
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

=head1 Future Plans

=head2 ArchiveRelease work with @Git

I want the Git::Commit thing to commit the archived release under releases/

However, how do I figure out the "dirty file" name in advance? I can't just give it a dir...

=head2 SIGNATURE

It works, it doesn't work... Setting it to "release" doesn't work for me. Setting it to "always"
works but it's annoying...

=head2 Work with Task::* dists

From Dist::Zilla::PluginBundle::FLORA

	; Not sure if it supports config_plugin = @Bundle like PodWeaver does...
	[TaskWeaver]	; weave our POD for a Task::* module ( enabled only if it's a Task-* dist )

	has is_task => (
	    is      => 'ro',
	    isa     => Bool,
	    lazy    => 1,
	    builder => '_build_is_task',
	);

	method _build_is_task {
	    return $self->dist =~ /^Task-/ ? 1 : 0;
	}

	...

	$self->is_task
        ? $self->add_plugins('TaskWeaver')
        : $self->add_plugins([ 'PodWeaver' => { config_plugin => '@FLORA' } ]);

=head2 I would like to start digging into the C<dzil new> command and see how to automate stuff in it.

Current list:

=head2 github integration

automatically create github repo + set description/homepage via L<Dist::Zilla::Plugin::UpdateGitHub> and L<App::GitHub::create> or L<App::GitHub>

GitHub needs a README - can we extract it and upload it on release? ( the current L<Dist::Zilla::Plugin::Readme> doesn't extract the entire POD... )

=head2 gitorious integration

unfortunately there's no perl API for gitorious? L<http://www.mail-archive.com/gitorious@googlegroups.com/msg01016.html>

=head2 .gitignore creation

it should contain only one line - the damned dist build dir "/Foo-Dist-*"

=head2 Eclipse files creation

create the .project/.includepath/.settings stuff

=head2 submit project to ohloh

we need more perl projects on ohloh! there's L<WWW::Ohloh::API>

=head1 SEE ALSO

L<Dist::Zilla>

=cut
