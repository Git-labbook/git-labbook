package Git::LabBook::ConfigAttribute;
use Moose ();
use Moose::Exporter;
use Scalar::Util qw(blessed);
use Moose::Util::TypeConstraints qw(find_type_constraint);
use Git::LabBook::Types;
use Git::LabBook::Role::HaveConfig;
#use Ledger::Role::HaveValues;
#use Moose::Util qw/find_meta does_role apply_all_roles/;;

Moose::Exporter->setup_import_methods(
    with_meta => [ 'has_config',
		   'has_config_file',
		   'has_config_dir',
		   'has_config_str',
#                   'has_value_constant',
#                   'has_value_directive',
#                   'has_value_separator_optional',
#                   'has_value_separator_simple',
#                   'has_value_separator_hard',
#                   'has_value_indented_line',
    ],
    #also      => 'Moose',
    );

use UNIVERSAL::require;
=head1 SYNOPSIS

    Can be used to declare configuration items

=head1 METHODS

=head2 has_config

This method is the main one. Documentation to improve

=cut
sub has_config {
    #print "'", join("', '",@_), "'\n";
    my ( $meta, $name, %attr ) = @_;
#    my $meta = shift;
#    my $name = shift;
#    my %attr = (@_);
    my $attrtype = $attr{'isa'} // 'Str';
    my $type;
    my %buildhash=();
    my %attrhash=();
    if (exists($attr{'default'})) {
	$buildhash{'default'}=$attr{'default'};
    }
    my @optnames=();
    if (exists($attr{'optnames'})) {
	push @optnames, @{$attr{'optnames'}};
    }
    push @optnames, $name;
    if (exists($attr{'coerce'})) {
	$attrhash{'coerce'}=$attr{'coerce'};
    }

    my $role='Git::LabBook::Role::HaveConfig';
    if (! $meta->does_role($role)) {
        if ($meta->isa("Moose::Meta::Role")) {
            die "missing \"with '$role';\" in ".$meta->name."\n";
        }
        #print "=> [".$meta->name."] Registering $role to $meta\n";
        $role->meta->apply($meta);
        #apply_all_roles($meta, $role);
        # meta has been modified/reinstanciated. We reload it
        $meta = ($meta->name)->meta;
        #my @roles=$meta->calculate_all_roles_with_inheritance;
        #print "roles=@roles\n";
        #print "   Current roles :\n     ".join(
        #    "\n     ",
        #    (map { $_->name }
        #     $meta->calculate_all_roles_with_inheritance))."\n";
        #print "=> [".$meta->name."] Registered $role to $meta\n";
        #$meta->add_role($role->meta);
        #$role='Ledger::Role::HaveParent';
    }
    #print "<= Registered $role to $meta ".$meta->name."\n";
    #print "   [".$meta->name."] Adding Value attribute $name ($meta)\n";

  TYPE:
    while(1) {
        foreach my $t ('Git::LabBook::Type::'.$attrtype, $attrtype) {
	    if (find_type_constraint($t)) {
                $type=$t;
		last TYPE;
	    }
            if ($t->require) {
                $type=$t;
                last TYPE;
            }
            $t =~ s,::,/,g;
            print $@ if $@ !~ /^Can't locate $t\.pm in /;
        }
        die "Unkwown Value type '".$attrtype.
            "'. Is 'has_config' from ".$meta->name." using a correct 'isa'?\n";
    }

    if ($name !~ /^[+]/) {
        %attrhash=(
            %attrhash,
            is        => 'rw',
            isa       => $type,
            lazy      => 1,
            );
    }

    $meta->add_attribute(
        $name,
        default   => sub {
            my $self=shift;
            #print 'creating '.$name.' with parent: ', blessed($self), "\n";
            #print 'attr names: '.join(", ", $self->all_value_names)."\n";
            #$self->_register_config($origname, $name);
            return $buildhash{'default'} // undef;
        },
        %attrhash,
        );

    @optnames = map { my $res=$_ ; $res =~ s/[-_]//g ; $res } @optnames;
    $meta->add_attribute(
        '_config_'.$name,
	is => 'ro',
	isa => 'ArrayRef[Git::LabBook::Type::Config]',
        default   => sub { \@optnames },
	init_arg => undef,
	lazy => 1,
	required => 1,
        );
    
    #$meta->find_method_by_name('_register_value_name')->execute($meta, $name);
}

sub has_config_file {
    my ( $meta, $name, %attr ) = @_;
    has_config($meta, $name,
	       isa => 'File',
	       coerce => 1,
	       %attr,
	);
}

sub has_config_dir {
    my ( $meta, $name, %attr ) = @_;
    has_config($meta, $name,
	       isa => 'Dir',
	       coerce => 1,
	       %attr,
	);
}

sub has_config_str {
    my ( $meta, $name, %attr ) = @_;
    has_config($meta, $name,
	       isa => 'Str',
	       %attr,
	);
}

1;
