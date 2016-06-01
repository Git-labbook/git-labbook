package Git::LabBook::Role::HaveConfig;
use Moose::Role;
use namespace::sweep;
use MooseX::ClassAttribute;
use TryCatch;

class_has 'config_names' => (
    traits    => ['Hash'],
    is        => 'ro',
    isa       => 'HashRef[Str]',
    default  => sub {
        my $self = shift;
        return $self->_get_all_config_names();
    },
    handles  => {
        all_config_names       => 'values',
        all_opt_names       => 'keys',
	has_opt             => 'exists',
	_get_configname       => 'get',
        #_register_value_name  => 'push',
        #_map_types       => 'map',
        #_filter_types=> 'grep',
        #find_element   => 'first',
        #get_type    => 'get',
        #join_elements  => 'join',
        #count_types => 'count',
        #has_options    => 'count',
        #_has_no_config_names => 'is_empty',
        #sorted_options => 'sort',
    },
    lazy => 1,
    );

# return an ARRAYREF
use Data::Dumper;
sub _get_all_config_names {
    my $self = shift;
    my $info = shift // "constructor";
    my $meta = $self;
    my %config_names=();

    if (not $meta->isa('Moose::Meta::Class')) {
        $meta=$meta->meta;
    }

    #print "Attributes ($info) in ".$meta->name." / $meta / $self\n";
    for my $attr ( $meta->get_all_attributes ) {
        my $v = $attr->type_constraint->is_a_type_of("ArrayRef[Git::LabBook::Type::Config]");
        #print "  + ",$attr->name, " ($v)\n";
        if ($v) {
	    my $readnames=$attr->name;
	    my $attrname=$readnames;
	    $attrname =~ s/^_config_//;
	    #print ("names $readnames : ", @{$self->$readnames}, "\n");
	    %config_names = (%config_names,
			     map { $_ => $attrname } @{$self->$readnames});
        }
    }
    #print "Registered: ", Dumper( \%config_names), "\n";
    return \%config_names;
}

1;
