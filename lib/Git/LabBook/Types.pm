package Git::LabBook::Types;
use Moose::Util::TypeConstraints;
use namespace::sweep;
use Path::Class;

subtype 'Git::LabBook::Type::Dir',
    as 'Path::Class::Dir',
    message { "$_ is not a strange directory!" };
    
subtype 'Git::LabBook::Type::File',
    as 'Path::Class::File',
    message { "$_ is not a strange file!" };
    
coerce 'Git::LabBook::Type::Dir',
    from 'Str',
    via { dir($_) };

coerce 'Git::LabBook::Type::File',
    from 'Str',
    via { file($_) };

subtype 'Git::LabBook::Type::Config',
    as 'Str',
    message { "$_ is not a strange file!" };

1;
