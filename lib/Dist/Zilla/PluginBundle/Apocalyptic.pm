package Dist::Zilla::PluginBundle::Apocalyptic;

# ABSTRACT: Let the apocalypse build your dist!

use Moose 1.21;

# The plugins we use ( excluding ones bundled in dzil )
with 'Dist::Zilla::Role::PluginBundle::Easy' => { -version => '5.011' };	# basically sets the dzil version
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
use Dist::Zilla::Plugin::InstallGuide 1.101461;
use Dist::Zilla::Plugin::Signature 1.100930;
use Dist::Zilla::Plugin::CheckChangesHasContent 0.003;
use Dist::Zilla::Plugin::Git 1.110500;
use Dist::Zilla::Plugin::ArchiveRelease 3.01;
use Dist::Zilla::Plugin::MetaData::BuiltWith 0.01018204;
use Dist::Zilla::Plugin::Clean 0.002;
use Dist::Zilla::Plugin::LocaleMsgfmt 1.203;
use Dist::Zilla::Plugin::CheckPrereqsIndexed 0.007;
use Dist::Zilla::Plugin::DOAP 0.002;
use Dist::Zilla::Plugin::Covenant 0.1.0;
use Dist::Zilla::Plugin::CheckIssues 0.002;
use Dist::Zilla::Plugin::SchwartzRatio 0.2.0;
use Dist::Zilla::Plugin::CheckSelfDependency 0.007;
use Dist::Zilla::Plugin::Git::Describe 0.003;
use Dist::Zilla::Plugin::ReportPhase; # TODO we wanted to specify 0.03 but it's weird version stanza blows up! RT#99769
use Dist::Zilla::Plugin::ReadmeAnyFromPod 0.142470;
use Dist::Zilla::Plugin::Git::CheckFor::CorrectBranch 0.011;
use Dist::Zilla::Plugin::Git::Remote::Check 0.1.2;
use Dist::Zilla::Plugin::PromptIfStale 0.028;
use Dist::Zilla::Plugin::ModuleBuildTiny 0.007;
use Dist::Zilla::Plugin::MakeMaker::Fallback 0.013;
use Dist::Zilla::Plugin::Git::Contributors 0.008;
use Dist::Zilla::Plugin::ChangeStats::Git 0.3.0;
use Dist::Zilla::Plugin::Test::ReportPrereqs 0.019;
use Dist::Zilla::Plugin::GitHub::Update 0.38;
use Dist::Zilla::Plugin::GithubMeta 0.46;
use Dist::Zilla::Plugin::Bitbucket::Update 0.001;
use Dist::Zilla::Plugin::Metadata 3.03;

# Allow easier config manipulation
with qw(
	Dist::Zilla::Role::PluginBundle::Config::Slicer
	Dist::Zilla::Role::PluginBundle::PluginRemover
);

sub configure {
	my $self = shift;

#	; -- Report the phases as a debugging aid
	# TODO should this module automatically figure it out? if so, go make a pull req!
	if ( join( ' ', @ARGV ) =~ /--verbose/i ) {
		$self->add_plugins( [ 'ReportPhase' => 'ENTER' ] );
	}

#	; -- start off by bumping the version
	$self->add_plugins(
	[
		'Git::NextVersion' => {
			'version_regexp' => '^release-(.+)$',
		}
	],

#	; -- import our files from the git root
	[
		'Git::GatherDir' => {
			'exclude_filename' => 'README.pod',
			'include_dotfiles' => 1,
		},
	],

#	; -- start the basic dist skeleton
	qw(
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
		Test::ReportPrereqs
	),

#	; -- munge files
	[
		'Prepender' => {
			'copyright'	=> 1,
			'line'		=> 'use strict; use warnings;',
			'skip'	=> 'Module\.pm$', # don't prepend our skeleton file!
		}
	],
	qw(
		Authority
		Git::Describe
		PkgVersion
	),
	[
		'PodWeaver' => {
			'config_plugin'		=> '@Apocalyptic',
			'replacer'		=> 'replace_with_comment',
			'post_code_replacer'	=> 'replace_with_nothing',
		}
	],

	# not always present!
	( -d 'share/locale' ?
	[
		'LocaleMsgfmt' => {
			'locale' => 'share/locale',
		},
	] : () ),

#	; -- update the Changelog
	[
		'NextRelease' => {
			'time_zone'	=> 'UTC',
			'filename'	=> 'Changes',
			'format'	=> '%v%t%{yyyy-MM-dd HH:mm:ss VVVV}d',
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
			'dir'	=> 'share',
		} ] );
	}
	$self->add_plugins(
	qw(
		MinimumPerl
		Bugtracker
		MetaConfig
		Git::Contributors
	),
	[
		'MetaData::BuiltWith' => {
			'show_uname' => 1,
			'uname_args' => '-s -r -m',
		}
	],
	[
		'GithubMeta' => {
			# TODO convert "origin" to "github"
			'remote' => 'origin',
			'issues' => 0, # we use the CPAN RT tracker
		}
	],
	[
		'MetaResources' => {
			# TODO add the usual list of stuff found in my POD? ( cpants, bla bla )
			'license'	=> 'http://dev.perl.org/licenses/',
		}
	],
	[
		# https://metacpan.org/about/metadata
		'Metadata' => {
			'x_IRC' => {
				'url' => 'irc://irc.perl.org/#perl-help',
				'web' => 'https://chat.mibbit.com/?channel=%23perl-help&server=irc.perl.org',
			},
		},
	],
	);

#	; -- generate meta files
	my @dirs;
	foreach my $d ( qw( inc t xt examples share eg mylib ) ) {
		push( @dirs, $d ) if -d $d;
	}

	# if we try to use the plugin with empty @dirs, this happens...
#	got impossible zero-value <directory> key at /usr/local/share/perl/5.18.2/Config/MVP/Assembler/WithBundles.pm line 147, <GEN1> line 2.
#	Config::MVP::Assembler::WithBundles::_add_bundle_contents(Dist::Zilla::MVP::Assembler::Zilla=HASH(0x39dc688), "bundle_config", HASH(0x3a9f898)) called at /usr/local/share/perl/5.18.2/Config/MVP/Assembler/WithBundles.pm line 82
	$self->add_plugins(
	( scalar @dirs ? [
		'MetaNoIndex' => {
			'directory' => \@dirs,
		}
	] : () ),
	[
		'MetaProvides::Package' => { # needs to be added after MetaNoIndex
			# don't report the noindex directories
			( scalar @dirs ? ('meta_noindex' => 1) : () ),
		}
	],
	qw(
		License
		ModuleBuildTiny
		MakeMaker::Fallback
	),
	qw(
		MetaYAML
		MetaJSON
		InstallGuide
		DOAP
		Covenant
		CPANFile
	),

#	; -- special stuff for README files
#		we want README and README.pod but only include README in the built tarball and use README.pod in the root of the project!
	'ReadmeAnyFromPod',
	[
		'ReadmeAnyFromPod', 'pod for github' => {
			'type'	=> 'pod',
			'location'	=> 'root',
			'phase'	=> 'release',
		},
	],
	[
                'ChangeStats::Git' => {
                        'group' => 'STATISTICS',
			'auto_previous_tag' => 1,
                },
        ],
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
			'allow_dirty'	=> [ 'README.pod', 'Changes' ], # TODO Changes shouldn't be in here but if I don't add it as allow_dirty it doesn't get committed!
		}
	],

#	; -- sanity-check our git stuff
#	TODO we need to fix Git::CheckFor::Fixups so it uses the version_regexp!
	qw(
		Git::CheckFor::CorrectBranch
	),
	[
		'Git::CheckFor::MergeConflicts' => {
			'ignore' => 'CommitLog',
		}
	],
	qw(
		Git::Remote::Check
	),

#	; -- more sanity tests before confirming
	[
		'PromptIfStale' => {
			'check_authordeps'	=> 1,
			'check_all_plugins'	=> 1,
			'check_all_prereqs'	=> 1,
			'phase'			=> 'release',
			'fatal'			=> 0,
		},
	],
	qw(
		TestRelease
		CheckPrereqsIndexed
		CheckSelfDependency
		CheckIssues
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
			'allow_dirty'	=> [ 'README.pod', 'Changes' ], # TODO Changes shouldn't be in here but if I don't add it as allow_dirty it doesn't get committed!
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
			# TODO add "github" support somehow... introspect the Git config?
			'push_to'	=> 'origin',
			'push_to' => 'bitbucket',
		}
	],
	[
		'GitHub::Update' => {
			'remote' => 'origin',
			'meta_home' => 1,
		}
	],
	[
		'Bitbucket::Update' => {
			'remote' => 'bitbucket',
		}
	],
	qw(
		Clean
		SchwartzRatio
	),
	);

	if ( join( ' ', @ARGV ) =~ /--verbose/i ) {
		$self->add_plugins( [ 'ReportPhase' => 'LEAVE' ] );
	}
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

	[ReportPhase / ENTER]	; reports the dzil build phases

	; -- start off by bumping the version
	[Git::NextVersion]		; find the last tag, and bump to next version via Version::Next
	version_regexp = ^release-(.+)$

	; -- start the basic dist skeleton
	[Git::GatherDir]			; we start with everything in the root dir, ignoring our auto-generated README.pod
	exclude_filename = README.pod
	[PruneCruft]			; automatically prune cruft defined by RJBS :)
	[AutoPrereqs]			; automatically find our prereqs
	[GenerateFile / MANIFEST.SKIP]	; make our default MANIFEST.SKIP
	[ManifestSkip]			; skip files that matches MANIFEST.SKIP
	skipfile = MANIFEST.SKIP

	; -- Generate our tests
	[Test::Compile]			; Create a t/00-compile.t file that auto-compiles every module in the dist
	fake_home = 1			; fakes $ENV{HOME} just in case
	[ApocalypseTests]		; Create a t/apocalypse.t file that runs Test::Apocalypse
	[Test::ReportPrereqs]		; Report the versions of our prereqs

	; -- munge files
	[Prepender]			; automatically add lines following the shebang in modules
	copyright = 1
	line = use strict; use warnings;
	[Authority]			; put the $AUTHORITY line in modules and the metadata
	[Git::Describe]		 ; make a note of the git commit description used in building this release
	[PkgVersion]			; put the "our $VERSION = ...;" line in modules
	[PodWeaver]			; weave our POD and add useful boilerplate
	config_plugin = @Apocalyptic
	replacer = replace_with_comment
	post_code_replacer = replace_with_nothing
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
	[Bugtracker]			; set bugtracker to http://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-PluginBundle-Apocalyptic
	[MetaConfig]			; dump dzil config into metadata
	[Git::Contributors]   	; generate our CONTRIBUTORS section by looking at the git history
	[MetaData::BuiltWith]		; dump entire perl modules we used to build into metadata
	[GithubMeta]			; set git repository path by looking at github data
	remote = origin
	issues = 0	; we prefer CPAN RT bugtracker
	[MetaResources]			; add arbitrary resources to metadata
	license = http://dev.perl.org/licenses/
	[Metadata]				; advertise the default IRC chatroom :)
	x_IRC.url = irc://irc.perl.org/#perl-help
	x_IRC.web = https://chat.mibbit.com/?channel=%23perl-help&server=irc.perl.org

	; -- generate meta files
	[MetaNoIndex]			; tell PAUSE to not index those directories
	directory = inc t xt examples share eg mylib
	[MetaProvides::Package]		; get provides from package definitions in files
	meta_noindex = 1
	[License]			; create LICENSE file
	[ModuleBuildTiny]		; create Build.PL file
	[MakeMaker::Fallback]	; create Makefile.PL file for older Perls
	[MetaYAML]			; create META.yml file
	[MetaJSON]			; create META.json file
	[ReadmeAnyFromPod]			; create README file
	[ReadmeAnyFromPod / PodRoot]	; create README.pod file in repository root ( useful for github! )
	[InstallGuide]			; create INSTALL file
	[DOAP]				; create doap.xml describing the module
	[Covenant]			; create AUTHOR_PLEDGE describing how PAUSE admins can grant co-maint
	[CPANFile]			; create a 'cpanfile' file describing prereqs
	[Signature]			; create SIGNATURE file when we are releasing ( annoying to enter password during test builds... )
	sign = archive
	[Manifest]			; finally, create the MANIFEST file

	; -- pre-release
	[CheckChangesHasContent]	; make sure you explained your changes :)
	changelog = Changes
	[Git::Check]			; check working path for any uncommitted stuff ( exempt Changes because it will be committed after release )
	changelog = Changes
	allow_dirty = README.pod
	[PromptIfStale]		; check our installed dependencies to make sure that we don't have stale modules and prevent release if so
	check_authordeps = 1
	check_all_plugins = 1
	check_all_prereqs = 1
	phase = release
	[TestRelease]                   ; make sure that we won't release a FAIL distro :)
	[@Git::CheckFor]		; prevent common git errors ( wrong branch, forgotten squash/fixups! )
	[CheckPrereqsIndexed]		; make sure that our prereqs actually exist on CPAN
	[CheckSelfDependency]           ; make sure we didn't create a recursive dependency situation!
	[CheckIssues]		; Looks on RT and github for issues that we can review
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
	allow_dirty = README.pod
	[Git::Tag]			; tag our new release
	tag_format = release-%v
	tag_message = Tagged release-%v
	[Git::Push]			; automatically push to the "origin" defined in .git/config AND our bitbucket :)
	push_to = origin
	push_to = bitbucket
	[GitHub::Update]		; update the github meta stuff
	[Bitbucket::Update]	; update the Bitbucket meta stuff
	[Clean]				; run dzil clean so we have no cruft :)
	[SchwartzRatio]		; informs us of old distributions lingering on CPAN

	[ReportPhase / LEAVE]	; reports the dzil build phases

=head1 Setting options

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

=head2 Newer method to manipulate this bundle

This PluginBundle now supports L<Dist::Zilla::PluginBundle::ConfigSlicer>, so you can pass in options to the plugins used like this:

	[@Apocalyptic]
	Git::Push.push_to = gitorious

This PluginBundle also supports L<Dist::Zilla::Role::PluginBundle::PluginRemover>, so dropping a plugin is as easy as this:

	[@Apocalyptic]
	-remove = ArchiveRelease

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

=head2 submit project to ohloh

we need more perl projects on ohloh! there's L<WWW::Ohloh::API>

=head2 DZP::PkgDist

Do we need the $DIST variable? What software uses it? I already provide that info in the POD of the file...

=head1 SEE ALSO
Dist::Zilla

=cut
