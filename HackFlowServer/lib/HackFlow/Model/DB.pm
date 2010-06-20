package HackFlow::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'HackFlow::Schema',
    
    connect_info => {
        dsn => 'dbi:mysql:hackflow',
        user => 'hackflow',
        password => 'hackflow',
    }
);

=head1 NAME

HackFlow::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<HackFlow>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<HackFlow::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.41

=head1 AUTHOR

Ubuntu

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
