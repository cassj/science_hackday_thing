package HackFlow::Schema::Result::Experiment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

HackFlow::Schema::Result::Experiment

=cut

__PACKAGE__->table("experiment");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 plan_uri

  data_type: 'text'
  is_nullable: 0

=head2 user_id

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "plan_uri",
  { data_type => "text", is_nullable => 0 },
  "user_id",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-06-20 01:05:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cnNm3CFjOhv3XWhVVAR7gA


# You can replace this text with custom content, and it will be preserved on regeneration


__PACKAGE__->belongs_to(user => 'HackFlow::Schema::Result::User', 'user_id');



__PACKAGE__->has_many(tags =>'HackFlow::Schema::Result::Tag',
		      {
         'foreign.experiment_id'              => 'self.id',
		      });

__PACKAGE__->has_many(events =>'HackFlow::Schema::Result::Event',
                      {
          'foreign.experiment_id'              => 'self.id',
                      });



1;
