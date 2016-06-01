package Git::LabBook::Cmds;
use Moose;
use namespace::sweep;

has '_cmds' => (
    traits   => ['Hash'],
    is       => 'ro',
    isa      => 'HashRef[Git::LabBook::Cmd]',
    required  => 1,
    lazy      => 1,
    init_arg  => undef,
    default  => sub { {} },
    handles  => {
	all_cmds => 'values',
	_register_cmd => 'set',
	has_cmd => 'exists',
	_get_cmd => 'get',
    }
    );

has 'cmd' => (
    is        => 'ro',
    writer    => '_set_cmd',
    isa       => 'Git::LabBook::Cmd',
    predicate => 'cmd_parsed',
    clearer   => '_reset_cmd',
    );

has '_ARGV' => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    default  => sub { [] },
    lazy      => 1,
    handles  => {
	ARGV => 'elements',
	_add_args => 'push',
    }
    );
    
    
sub register {
    my $self = shift;
    my %opts = @_;
    my $cmd;
    
    if ($opts{'main-cmd'} // 0) {
	$cmd = Git::LabBook::SubCmd->new(%opts, '_cmds' => $self);
    } else {
	$cmd = Git::LabBook::Cmd->new(%opts, '_cmds' => $self);
    }
    if ($self->has_cmd($cmd->fullname)) {
	die 'Duplicate registration of CMD '.$cmd->fullname;
    }
    $self->_register_cmd($cmd->fullname, $cmd);
    return $self;
}

sub parse {
    my $self = shift;
    my @ARGV = @_;
    my %cmdlist = map { $_->name => 1 }
    (grep { !$_->isa('Git::LabBook::SubCmd') } $self->all_cmds);
    $self->_reset_cmd;
    my $prefix='';
    
    for (my $i = 0; $i < @ARGV; $i++) {
	if (exists($cmdlist{$ARGV[$i]})) {
	    my $cmd = $self->_get_cmd($prefix.$ARGV[$i]);
	    $self->_set_cmd($cmd);
	    splice @ARGV, $i, 1;
	    last if (! $cmd->has_subcmds);
	    $i--;
	    $prefix=$cmd->name."-";
	    %cmdlist = map { $_->name => 1 }
	    (grep { $_->isa('Git::LabBook::SubCmd') && 
			$_->parent == $cmd } $self->all_cmds);
	}
    }
    $self->_add_args(@ARGV);
}

1;

package Git::LabBook::Cmd;
use Moose;
use namespace::sweep;

has '_cmds' => (
    is       => 'ro',
    isa      => 'Git::LabBook::Cmds',
    required  => 1,
    weak_ref => '1',
    );

has 'name' => (
    is      => 'ro',
    isa      => 'Str',
    required  => 1,
    );

has 'desc' => (
    is      => 'ro',
    isa      => 'Str',
    required  => 1,
    );

has 'code' => (
    is      => 'ro',
    isa      => 'CodeRef',
    predicate => '_has_code',
    );

has 'opts' => (
    is      => 'ro',
    isa      => 'HashRef',
    default => sub { {} },
    );

has 'has_subcmds' => (
    is       => 'ro',
    isa      => 'Bool',
    required => 1,
    default  => 0,
    lazy     => 1,
    init_arg => 'has-subcmds',    
    );

sub fullname {
    my $self = shift;
    return $self->name;
}

sub displayname {
    my $self = shift;
    return $self->name;
}

sub run {
    my $self = shift;

    return $self->code->($self, @_);
}

sub BUILD {
    my $self = shift;
    
    if ($self->_has_code && $self->has_subcmds) {
	die 'Cannot have code and subcommands for '.$self->fullname;
    }
    if (!$self->_has_code && !$self->has_subcmds) {
	die 'Missing code for '.$self->fullname;
    }
}

1;

package Git::LabBook::SubCmd;
use Moose;
use namespace::sweep;

extends 'Git::LabBook::Cmd';

has 'main_cmd' => (
    is        => 'ro',
    isa       => 'Str',
    required  => 1,
    init_arg  => 'main-cmd',
    );

has 'parent' => (
    is        => 'ro',
    isa       => 'Git::LabBook::Cmd',
    required  => 1,
    lazy      => 1,
    init_arg  => undef,
    default   => sub {
	my $self = shift;
	return $self->_cmds->_get_cmd($self->main_cmd);
    },
    );

after 'BUILD' => sub {
    my $self = shift;
    
    if (! $self->_cmds->has_cmd($self->main_cmd)) {
	die 'Invalid main-cmd '.$self->main_cmd.' for '.$self->name;
    }
    if (! $self->parent->has_subcmds) {
	die $self->main_cmd.' cannot have subcommands such as '.$self->name;
    }
    if ($self->has_subcmds) {
	die 'subcommand '.$self->name.' cannot have subcommands';
    }
};

sub fullname {
    my $self = shift;
    return $self->main_cmd.'-'.$self->name;
}

sub displayname {
    my $self = shift;
    return $self->main_cmd.' '.$self->name;
}

1;
