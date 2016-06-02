package Git::LabBook;
use Moose;
use namespace::sweep;

# ABSTRACT: manage a laboratory book with Git

use Git::LabBook::Types;
use Git::LabBook::ConfigAttribute;
use Path::Class;

has_config_file 'labbookstate' => (
    default => file('.gitlabbook-state'),
    );

has_config_file 'labbookfile' => (
    default => file('LabBook.org'),
    );

has_config_dir 'srcdir' => (
    default => dir('src'),
    );

has_config_dir 'datadir' => (
    default => dir('data'),
    );

has_config_dir 'analysisdir' => (
    default => dir('analysis'),
    );

has_config_str 'databranch' => (
    default => 'data',
    );

has_config_str 'xpbranch' => (
    default => 'xp/%s',
    );

has_config_str 'xptag' => (
    default => 'xp/%s',
    );

has_config_bool 'labbookentry' => (
    default => 1,
    );

sub set {
    my $self = shift;
    my $optname = shift;
    my $value = shift;

    $optname =~ s/-//g;

    my $realname = $self->_get_configname($optname);
    if (! defined($realname)) {
	die "Invalid option name $optname";
    }
    $realname = '_set_'.$realname;
    $self->$realname($value);
}

around 'xpbranch' => sub {
    my $orig = shift;
    my $self = shift;

    my $xpname = shift;
    my $branch=$self->$orig();
    $branch =~ s/%s/$xpname/ if defined($xpname);
    return $branch;
};

around 'xptag' => sub {
    my $orig = shift;
    my $self = shift;

    my $xpname = shift;
    my $tag=$self->$orig();
    $tag =~ s/%s/$xpname/ if defined($xpname);
    return $tag;
};

1;

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

just to see


