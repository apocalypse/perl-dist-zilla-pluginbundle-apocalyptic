package Dist::Zilla::PluginBundle::Apocalyptic;

# ABSTRACT: Let the apocalypse build your dist!

use Moose 1.21;
use File::Spec 3.33;
use File::HomeDir 0.93;

# The plugins we use ( excluding ones bundled in dzil )
with 'Dist::Zilla::Role::PluginBundle::Easy' => { -version => '4.102345' };	# basically sets the dzil version
use Pod::Weaver::PluginBundle::Apocalyptic 0.001;
use Dist::Zilla::Plugin::CompileTests 1.103030;
use Dist::Zilla::Plugin::ApocalypseTests 0.01;
use Dist::Zilla::Plugin::Prepender 1.101590;
use Dist::Zilla::Plugin::Authority 1.001;
use Dist::Zilla::Plugin::PodWeaver 3.101641;
use Dist::Zilla::Plugin::ChangelogFromGit 0.002;
use Dist::Zilla::Plugin::MinimumPerl 1.001;
use Dist::Zilla::Plugin::MetaProvides::Package 1.12044908;
use Dist::Zilla::Plugin::Bugtracker 1.102670;
use Dist::Zilla::Plugin::Homepage 1.101420;
use Dist::Zilla::Plugin::Repository 0.16;
use Dist::Zilla::Plugin::MetaNoIndex 1.101550;
use Dist::Zilla::Plugin::DualBuilders 0.03;
use Dist::Zilla::Plugin::ReadmeFromPod 0.14;
use Dist::Zilla::Plugin::InstallGuide 1.101461;
use Dist::Zilla::Plugin::Signature 1.100930;
use Dist::Zilla::Plugin::CheckChangesHasContent 0.003;
use Dist::Zilla::Plugin::Git 1.103470;
use Dist::Zilla::Plugin::ArchiveRelease 3.01;	# TODO seems like it's indexing on CPAN is screwed?
use Dist::Zilla::Plugin::ReportVersions::Tiny 1.02;
use Dist::Zilla::Plugin::MetaData::BuiltWith 0.01018204;

# TODO what about sub-deps that we need? Just list them here?
# Pod::Weaver::Section::Legal - add extra line about LICENSE ( pending pull req in github )

sub configure {
	my $self = shift;

#	; -- start off by bumping the version
	$self->add_plugins( [ 'Git::NextVersion' => {
		'version_regexp' => '^release-(.+)$',
	} ] );

#	; -- start the basic dist skeleton
	$self->add_plugins(
	qw(
		GatherDir
		PruneCruft
		AutoPrereqs
	),
	[
		'GenerateFile', 'MANIFEST.SKIP', {
			'filename'	=> 'MANIFEST.SKIP',
			'is_template'	=> 1,
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
	$self->add_plugins(
	[
		'CompileTests' => {
			# fake the $ENV{HOME} in case smokers don't like us
			'fake_home' => 1,
		},
	],
	qw(
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
	qw(
		Authority
		PkgVersion
	),
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
	$self->add_plugins(
	qw(
		MinimumPerl
		Bugtracker
		Homepage
		MetaConfig
	),
	[
		'MetaData::BuiltWith' => {
			'show_uname' => 1,
			'uname_args' => '-s -r -m',
		}
	],
	[
		'Repository' => {
			# TODO convert "origin" to "github"
			'git_remote' => 'origin',
		}
	],
	[
		'MetaResources' => {
			# TODO add the usual list of stuff found in my POD? ( cpants, bla bla )
			'license'	=> 'http://dev.perl.org/licenses/',
		}
	], );

#	; -- generate meta files
	my @dirs;
	foreach my $d ( qw( inc t xt examples share eg ) ) {
		push( @dirs, $d ) if -d $d;
	}
	$self->add_plugins(
	[
		'MetaNoIndex' => {
			'directory' => \@dirs,
		}
	],
	[
		'MetaProvides::Package' => { # needs to be added after MetaNoIndex
			# don't report the noindex directories
			'meta_noindex' => 1,
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
			'sign' => 'archive',
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
#		'TestRelease',	# TODO fix Test::Apocalypse so it doesn't stop the flow if "so-what" tests fail :) ( mark them as TODO tests? )
	);

#	; -- release
	# TODO can this also check the %PAUSE stash in config.ini / dist.ini ?
	if ( -e File::Spec->catfile( File::HomeDir->my_home, '.pause' ) or -e File::Spec->catfile( '.', '.pause' ) ) {
		$self->add_plugins( 'UploadToCPAN' );
	} else {
		warn 'No .pause file detected, using FakeRelease!';
		$self->add_plugins( 'FakeRelease' );
	}

#	; -- post-release
	$self->add_plugins(
	# TODO now that I have a twitter account, should I tweet it? :)
	[
		'ArchiveRelease' => {
			'directory' => 'releases',
		}
	],
	[
		'Git::Commit' => {
			'changelog'	=> 'Changes',
			'commit_msg'	=> 'New CPAN release of %N - v%v%n%n%c',
			'time_zone'	=> 'UTC',
			'add_files_in'	=> 'releases',
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

=for Pod::Coverage configure

=head1 DESCRIPTION

This plugin bundle attempts to automate as much as sanely possible the job of building your dist. It builds upon
L<Dist::Zilla> and utilizes numerous plugins to reduce the burden on the programmer.

	# In your dist.ini:
	name = My-Super-Cool-Dist
	[@Apocalyptic]

Don't forget the new global config.ini file added in L<Dist::Zilla> v4!

	apoc@blackhole:~$ cat .dzil/config.ini
	[%User]
	name  = Apocalypse
	email = APOCAL@cpan.org

	[%Rights]
	license_class    = Perl_5
	copyright_holder = Apocalypse

	[%PAUSE]
	username = APOCAL
	password = myawesomepassword

This is equivalent to setting this in your dist.ini:

	# Skipping the usual name/author/license/copyright stuff

	; -- start off by bumping the version
	[Git::NextVersion]		; find the last tag, and bump to next version via Version::Next
	version_regexp = ^release-(.+)$

	; -- start the basic dist skeleton
	[GatherDir]			; we start with everything in the dist dir
	[PruneCruft]			; automatically prune cruft defined by RJBS :)
	[AutoPrereqs]			; automatically find our prereqs
	[GenerateFile / MANIFEST.SKIP]	; make our default MANIFEST.SKIP
	[ManifestSkip]			; skip files that matches MANIFEST.SKIP
	skipfile = MANIFEST.SKIP

	; -- Generate our tests
	[CompileTests]			; Create a t/00-compile.t file that auto-compiles every module in the dist
	fake_home = 1			; fakes $ENV{HOME} just in case
	[ApocalypseTests]		; Create a t/apocalypse.t file that runs Test::Apocalypse
	[ReportVersions::Tiny]		; Report the versions of our prereqs

	; -- munge files
	[Prepender]			; automatically add lines following the shebang in modules
	copyright = 1
	line = use strict; use warnings;
	[Authority]			; put the $AUTHORITY line in modules
	authority = cpan:APOCAL
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
	[ExecDir]			; automatically install files from bin/ directory as executables ( if it exists )
	dir = bin
	[ShareDir]			; automatically install File::ShareDir files from share/ ( if it exists )
	dir = share
	[MinimumPerl]			; automatically find the minimum perl version required and add it to prereqs
	[Bugtracker]			; set bugtracker to http://rt.cpan.org/Public/Dist/Display.html?Name=$dist
	[Homepage]			; set homepage to http://search.cpan.org/dist/$dist/
	[MetaConfig]			; dump dzil config into metadata
	[MetaData::BuiltWith]		; dump entire perl modules we used to build into metadata
	[Repository]			; set git repository path by looking at git configs
	git_remote = origin
	[MetaResources]			; add arbitrary resources to metadata
	license = http://dev.perl.org/licenses/



	; -- generate meta files
	[MetaNoIndex]			; tell PAUSE to not index those stuff ( if it exists )
	directory = inc
	directory = t
	directory = xt
	directory = examples
	directory = share
	directory = eg
	[MetaProvides::Package]		; get provides from package definitions in files
	meta_noindex = 1
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
	sign = archive
	[Manifest]			; finally, create the MANIFEST file

	; -- pre-release
	[CheckChangesHasContent]	; make sure you explained your changes :)
	changelog = Changes
	[Git::Check]			; check working path for any uncommitted stuff ( exempt Changes because it will be committed after release )
	changelog = Changes
	[ConfirmRelease]		; double-check that we ACTUALLY want a release, ha!
	[TestRelease]			; make sure that we won't release a FAIL distro :)

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

=head2 Changes creation

create a Changes file with the boilerplate text in it

	Revision history for Dist::Zilla::PluginBundle::Apocalyptic

	{{$NEXT}}

		initial release

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

=head2 locale files

L<Dist::Zilla::Plugin::LocaleMsgfmt> looks interesting, I should auto-enable it if I find the .po files?

=head2 DZP::PkgDist

Do we need the $DIST variable? What software uses it? I already provide that info in the POD of the file...

=head1 SEE ALSO

L<Dist::Zilla>

=cut
