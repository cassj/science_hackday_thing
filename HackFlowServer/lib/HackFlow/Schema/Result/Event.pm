package HackFlow::Schema::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

HackFlow::Schema::Result::Event

=cut

__PACKAGE__->table("event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 event_uri

  data_type: 'text'
  is_nullable: 0

=head2 experiment_id

  data_type: 'integer'
  is_nullable: 0

=head2 status

  data_type: 'enum'
  extra: {list => ["PLANNED","COMPLETE","FAILED"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "event_uri",
  { data_type => "text", is_nullable => 0 },
  "experiment_id",
  { data_type => "integer", is_nullable => 0 },
  "status",
  {
    data_type => "enum",
    extra => { list => ["PLANNED", "COMPLETE", "FAILED"] },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-06-20 01:05:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QM/oixegf+RXONI7ryjwog


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(experiment => 'HackFlow::Schema::Result::Experiment', 'experiment_id');

__PACKAGE__->has_many(event_required_tags =>'HackFlow::Schema::Result::EventRequiredTag',
                      {
          'foreign.event_id'              => 'self.id',
                      });

__PACKAGE__->many_to_many(required_tags => 'event_required_tags', 'event');


1;
