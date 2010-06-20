package HackFlow::Schema::Result::EventRequiredTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

HackFlow::Schema::Result::EventRequiredTag

=cut

__PACKAGE__->table("event_required_tags");

=head1 ACCESSORS

=head2 event_id

  data_type: 'integer'
  is_nullable: 0

=head2 tag_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "event_id",
  { data_type => "integer", is_nullable => 0 },
  "tag_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("event_id", "tag_id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-06-20 01:05:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PBfiOfB9VO8G3PNU8BwZrg


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->belongs_to(event => 'HackFlow::Schema::Result::Event', 'event_id');
__PACKAGE__->belongs_to(tag => 'HackFlow::Schema::Result::Tag', 'tag_id');


1;
