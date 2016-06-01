package Git::LabBook;
use Moose;
use namespace::sweep;

# ABSTRACT: manage a laboratory book with Git

use Git::LabBook::Types;
use Git::LabBook::ConfigAttribute;
use Path::Class;

has_config_file 'labbookfile' => (
    optnames => [ 'labbook-file-name' ],
    default => file('LabBook.org'),
    );

has_config_dir 'srcdir' => (
    optnames => [ 'src-dir-name' ],
    default => dir('src'),
    );

has_config_dir 'datadir' => (
    optnames => [ 'data-dir-name' ],
    default => dir('data'),
    );

has_config_str 'databranch' => (
    optnames => [ 'data-branch-name' ],
    default => 'data',
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

    $self->$realname($value);
}

1;

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

just to see


