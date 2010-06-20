package HackFlow::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

HackFlow::Schema::Result::Tag

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 experiment_id

  data_type: 'integer'
  is_nullable: 0

=head2 value

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "experiment_id",
  { data_type => "integer", is_nullable => 0 },
  "value",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-06-20 01:05:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d++5vWPzKfpErCNUqOcXlQ


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(experiment => 'HackFlow::Schema::Result::Experiment', 'experiment_id');

__PACKAGE__->has_many(event_required_tags =>'HackFlow::Schema::Result::EventRequiredTag',
                      {
          'foreign.tag_id'              => 'self.id',
                      });


1;
