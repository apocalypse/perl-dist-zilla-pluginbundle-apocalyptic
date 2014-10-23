package Dist::Zilla::PluginBundle::Apocalyptic;

# ABSTRACT: Let the apocalypse build your dist!

use Moose 1.21;

# The plugins we use ( excluding ones bundled in dzil )
with 'Dist::Zilla::Role::PluginBundle::Easy' => { -version => '4.200004' };	# basically sets the dzil version
use Pod::Weaver::PluginBundle::Apocalyptic 0.002;
use Dist::Zilla::Plugin::Test::Compile 1.112820;
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
use Dist::Zilla::Plugin::DualBuilders 1.001;
use Dist::Zilla::Plugin::ReadmeFromPod 0.14;
use Dist::Zilla::Plugin::InstallGuide 1.101461;
use Dist::Zilla::Plugin::Signature 1.100930;
use Dist::Zilla::Plugin::CheckChangesHasContent 0.003;
use Dist::Zilla::Plugin::Git 1.110500;
use Dist::Zilla::Plugin::ArchiveRelease 3.01;
use Dist::Zilla::Plugin::ReportVersions::Tiny 1.02;
use Dist::Zilla::Plugin::MetaData::BuiltWith 0.01018204;
use Dist::Zilla::Plugin::Clean 0.002;
use Dist::Zilla::Plugin::LocaleMsgfmt 1.203;
use Dist::Zilla::Plugin::CheckPrereqsIndexed 0.007;
use Dist::Zilla::Plugin::DOAP 0.002;

# TODO fix this: http://changes.cpanhq.org/author/APOCAL

# TODO follow up on those local patches:
# Plugin::ChangelogFromGit - better HEAD tag name ( https://github.com/rcaputo/dzp-changelogfromgit/pull/1 )

sub configure {
	my $self = shift;

#	; -- start off by bumping the version
	$self->add_plugins(
	[
		'Git::NextVersion' => {
			'version_regexp' => '^release-(.+)$',
		}
	],

#	; -- start the basic dist skeleton
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

# Ignore Dist::Zilla's build dir
^\.build/

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
	],

#	; -- Generate our tests
	[
		'Test::Compile' => {
			# fake the $ENV{HOME} in case smokers don't like us
			'fake_home' => 1,
		}
	],
	qw(
		ApocalypseTests
		ReportVersions::Tiny
	),

#	; -- munge files
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
	],
	[
		'LocaleMsgfmt' => {
			'locale' => 'share/locale',
		},
	],

#	; -- update the Changelog
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
	],
	);

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
			# TODO actually use gitorious!
			'git_remote' => 'origin',
		}
	],
	[
		'MetaResources' => {
			# TODO add the usual list of stuff found in my POD? ( cpants, bla bla )
			'license'	=> 'http://dev.perl.org/licenses/',
		}
	],
	);

#	; -- generate meta files
	my @dirs;
	foreach my $d ( qw( inc t xt examples share eg mylib ) ) {
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
		DOAP
	),
	[
		'Signature' => {
			'sign' => 'always',
		}
	],
	qw(
		Manifest
	),

#	; -- pre-release
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
	qw(
		TestRelease
		CheckPrereqsIndexed
		ConfirmRelease
	),

#	; -- release
	qw(
		UploadToCPAN
	),

#	; -- post-release
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
	],
	qw(
		Clean
	),
	);
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

=head2 dist.ini

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
	[Test::Compile]			; Create a t/00-compile.t file that auto-compiles every module in the dist
	fake_home = 1			; fakes $ENV{HOME} just in case
	[ApocalypseTests]		; Create a t/apocalypse.t file that runs Test::Apocalypse
	[ReportVersions::Tiny]		; Report the versions of our prereqs

	; -- munge files
	[Prepender]			; automatically add lines following the shebang in modules
	copyright = 1
	line = use strict; use warnings;
	[Authority]			; put the $AUTHORITY line in modules and the metadata
	[PkgVersion]			; put the "our $VERSION = ...;" line in modules
	[PodWeaver]			; weave our POD and add useful boilerplate
	config_plugin = @Apocalyptic
	[LocaleMsgfmt]			; compile .po files to .mo files in share/locale
	locale = share/locale

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
	[MetaNoIndex]			; tell PAUSE to not index those directories
	directory = inc t xt examples share eg mylib
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
	[DOAP]				; create doap.xml describing the module
	[Signature]			; create SIGNATURE file when we are releasing ( annoying to enter password during test builds... )
	sign = archive
	[Manifest]			; finally, create the MANIFEST file

	; -- pre-release
	[CheckChangesHasContent]	; make sure you explained your changes :)
	changelog = Changes
	[Git::Check]			; check working path for any uncommitted stuff ( exempt Changes because it will be committed after release )
	changelog = Changes
	[TestRelease]                   ; make sure that we won't release a FAIL distro :)
	[CheckPrereqsIndexed]		; make sure that our prereqs actually exist on CPAN
	[ConfirmRelease]		; double-check that we ACTUALLY want a release, ha!

	; -- release
	[UploadToCPAN]			; upload your dist to CPAN using CPAN::Uploader

	; -- post-release
	[ArchiveRelease]		; archive our tarballs under releases/
	directory = releases
	[Git::Commit]			; commit the dzil-generated stuff
	changelog = Changes
	commit_msg = New CPAN release of %N - v%v%n%n%c
	time_zone = UTC
	add_files_in = releases		; add our release tarballs to the repo
	[Git::Tag]			; tag our new release
	tag_format = release-%v
	tag_message = Tagged release-%v
	[Git::Push]			; automatically push to the "origin" defined in .git/config
	push_to = origin
	[Clean]				; run dzil clean so we have no cruft :)

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

=head2 dumpphases

Here is an output of a distribution using Dist::Zilla and only this bundle:

	apoc@apoc-x300:~/mygit/perl-dist-zilla-pluginbundle-apocalyptic$ dzil dumpphases

	Phase: Version
	 - description: Provide a version for the distribution
	 - role: -VersionProvider
	 * @Apocalyptic/Git::NextVersion => Dist::Zilla::Plugin::Git::NextVersion

	Phase: MetaData
	 - description: Specify MetaData for the distribution
	 - role: -MetaProvider
	 * @Apocalyptic/Authority => Dist::Zilla::Plugin::Authority
	 * @Apocalyptic/Bugtracker => Dist::Zilla::Plugin::Bugtracker
	 * @Apocalyptic/Homepage => Dist::Zilla::Plugin::Homepage
	 * @Apocalyptic/MetaConfig => Dist::Zilla::Plugin::MetaConfig
	 * @Apocalyptic/MetaData::BuiltWith => Dist::Zilla::Plugin::MetaData::BuiltWith
	 * @Apocalyptic/Repository => Dist::Zilla::Plugin::Repository
	 * @Apocalyptic/MetaResources => Dist::Zilla::Plugin::MetaResources
	 * @Apocalyptic/MetaNoIndex => Dist::Zilla::Plugin::MetaNoIndex
	 * @Apocalyptic/MetaProvides::Package => Dist::Zilla::Plugin::MetaProvides::Package

	Phase: Before Build
	 - role: -BeforeBuild
	 * @Apocalyptic/LocaleMsgfmt => Dist::Zilla::Plugin::LocaleMsgfmt

	Phase: Gather Files
	 - role: -FileGatherer
	 * @Apocalyptic/GatherDir => Dist::Zilla::Plugin::GatherDir
	 * @Apocalyptic/MANIFEST.SKIP => Dist::Zilla::Plugin::GenerateFile
	 * @Apocalyptic/Test::Compile => Dist::Zilla::Plugin::Test::Compile
	 * @Apocalyptic/ApocalypseTests => Dist::Zilla::Plugin::ApocalypseTests
	 * @Apocalyptic/ReportVersions::Tiny => Dist::Zilla::Plugin::ReportVersions::Tiny
	 * @Apocalyptic/ChangelogFromGit => Dist::Zilla::Plugin::ChangelogFromGit
	 * @Apocalyptic/License => Dist::Zilla::Plugin::License
	 * @Apocalyptic/MetaYAML => Dist::Zilla::Plugin::MetaYAML
	 * @Apocalyptic/MetaJSON => Dist::Zilla::Plugin::MetaJSON
	 * @Apocalyptic/Signature => Dist::Zilla::Plugin::Signature
	 * @Apocalyptic/Manifest => Dist::Zilla::Plugin::Manifest

	Phase: Prune Files
	 - role: -FilePruner
	 * @Apocalyptic/PruneCruft => Dist::Zilla::Plugin::PruneCruft
	 * @Apocalyptic/ManifestSkip => Dist::Zilla::Plugin::ManifestSkip
	 * @Apocalyptic/ArchiveRelease => Dist::Zilla::Plugin::ArchiveRelease

	Phase: Munge Files
	 - role: -FileMunger
	 * @Apocalyptic/ApocalypseTests => Dist::Zilla::Plugin::ApocalypseTests
	 * @Apocalyptic/Prepender => Dist::Zilla::Plugin::Prepender
	 * @Apocalyptic/Authority => Dist::Zilla::Plugin::Authority
	 * @Apocalyptic/PkgVersion => Dist::Zilla::Plugin::PkgVersion
	 * @Apocalyptic/PodWeaver => Dist::Zilla::Plugin::PodWeaver
	 * @Apocalyptic/NextRelease => Dist::Zilla::Plugin::NextRelease

	Phase: Register Preqreqs
	 - role: -PrereqSource
	 * @Apocalyptic/AutoPrereqs => Dist::Zilla::Plugin::AutoPrereqs
	 * @Apocalyptic/MinimumPerl => Dist::Zilla::Plugin::MinimumPerl
	 * @Apocalyptic/MakeMaker => Dist::Zilla::Plugin::MakeMaker
	 * @Apocalyptic/ModuleBuild => Dist::Zilla::Plugin::ModuleBuild
	 * @Apocalyptic/DualBuilders => Dist::Zilla::Plugin::DualBuilders

	Phase: Install Tool
	 - role: -InstallTool
	 * @Apocalyptic/MakeMaker => Dist::Zilla::Plugin::MakeMaker
	 * @Apocalyptic/ModuleBuild => Dist::Zilla::Plugin::ModuleBuild
	 * @Apocalyptic/DualBuilders => Dist::Zilla::Plugin::DualBuilders
	 * @Apocalyptic/ReadmeFromPod => Dist::Zilla::Plugin::ReadmeFromPod
	 * @Apocalyptic/InstallGuide => Dist::Zilla::Plugin::InstallGuide

	Phase: After Build
	 - role: -AfterBuild
	 * @Apocalyptic/DualBuilders => Dist::Zilla::Plugin::DualBuilders
	 * @Apocalyptic/Signature => Dist::Zilla::Plugin::Signature

	Phase: Before Archive
	 - role: -BeforeArchive
	 * @Apocalyptic/Signature => Dist::Zilla::Plugin::Signature

	Phase: Releaser
	 - role: -Releaser
	 * @Apocalyptic/UploadToCPAN => Dist::Zilla::Plugin::UploadToCPAN
	 * @Apocalyptic/ArchiveRelease => Dist::Zilla::Plugin::ArchiveRelease

	Phase: Before Release
	 - role: -BeforeRelease
	 * @Apocalyptic/CheckChangesHasContent => Dist::Zilla::Plugin::CheckChangesHasContent
	 * @Apocalyptic/Git::Check => Dist::Zilla::Plugin::Git::Check
	 * @Apocalyptic/TestRelease => Dist::Zilla::Plugin::TestRelease
	 * @Apocalyptic/CheckPrereqsIndexed => Dist::Zilla::Plugin::CheckPrereqsIndexed
	 * @Apocalyptic/ConfirmRelease => Dist::Zilla::Plugin::ConfirmRelease
	 * @Apocalyptic/UploadToCPAN => Dist::Zilla::Plugin::UploadToCPAN
	 * @Apocalyptic/ArchiveRelease => Dist::Zilla::Plugin::ArchiveRelease
	 * @Apocalyptic/Git::Tag => Dist::Zilla::Plugin::Git::Tag

	Phase: After Release
	 - role: -AfterRelease
	 * @Apocalyptic/NextRelease => Dist::Zilla::Plugin::NextRelease
	 * @Apocalyptic/Git::Commit => Dist::Zilla::Plugin::Git::Commit
	 * @Apocalyptic/Git::Tag => Dist::Zilla::Plugin::Git::Tag
	 * @Apocalyptic/Git::Push => Dist::Zilla::Plugin::Git::Push
	 * @Apocalyptic/Clean => Dist::Zilla::Plugin::Clean

	Phase: Test Runner
	 - role: -TestRunner
	 * @Apocalyptic/MakeMaker => Dist::Zilla::Plugin::MakeMaker
	 * @Apocalyptic/ModuleBuild => Dist::Zilla::Plugin::ModuleBuild

	Phase: Build Runner
	 - role: -BuildRunner
	 * @Apocalyptic/MakeMaker => Dist::Zilla::Plugin::MakeMaker
	 * @Apocalyptic/ModuleBuild => Dist::Zilla::Plugin::ModuleBuild

=head1 Future Plans

=head2 use XDG's Twitter plugin

I want to tweet and be a web2.0 dude! :)

=head2 use GETTY's cool Dist::Zilla::Plugin::Run::AfterRelease

I want to use that to automatically install the generated tarball

	sudo cpanp i --force file:///home/apoc/mygit/perl-dist-zilla-pluginbundle-apocalyptic/Dist-Zilla-PluginBundle-Apocalyptic-0.001.tar.gz

However, how do I get the full tarball path?

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

=head3 Changes creation

create a Changes file with the boilerplate text in it

	Revision history for Dist::Zilla::PluginBundle::Apocalyptic

	{{$NEXT}}

		initial release

=head3 github integration

automatically create github repo + set description/homepage via L<Dist::Zilla::Plugin::UpdateGitHub> and L<App::GitHub::create> or L<App::GitHub>

GitHub needs a README - can we extract it and upload it on release? ( the current L<Dist::Zilla::Plugin::Readme> doesn't extract the entire POD... )

=head3 gitorious integration

unfortunately there's no perl API for gitorious? L<http://www.mail-archive.com/gitorious@googlegroups.com/msg01016.html>

=head3 .gitignore creation

it should contain only one line - the damned dist build dir "/Foo-Dist-*"
also, it needs the "/.build/" line?

=head3 Eclipse files creation

create the .project/.includepath/.settings stuff

=head3 submit project to ohloh

we need more perl projects on ohloh! there's L<WWW::Ohloh::API>

=head2 DZP::PkgDist

Do we need the $DIST variable? What software uses it? I already provide that info in the POD of the file...

=head1 SEE ALSO
Dist::Zilla

=cut
