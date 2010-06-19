package HackFlow::Controller::Root;
use Moose;
use namespace::autoclean;
#use JSON;


BEGIN { extends 'Catalyst::Controller::REST' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

HackFlow::Controller::Root - Root Controller for HackFlow

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

POST data in any form that Catalyst::Controller::REST can serialize.
Should have a plan_uri which will initiate a new exeriment
or an experiment_id in which case new info will be added to that experiment

Returns JSON like 
experiment_id:1234,  
submission_success:1,
error_msg:"if success is 0, some info as to why"


=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

   use Data::Dumper;
	warn Dumper $c->req->data;
  
    #is it a new experiment?
    if ($c->request->data('plan_uri')){
       $c->stash->{experiment_id}='12345';
       $c->stash->{submission_success}=1;

    }
    #or an existing experiment
    elsif ($c->request->data('experiment_id')){
       $c->stash->{experiment_id}='12345';
       $c->stash->{submission_success}=1;

    }
    #or not an experiment at all?
    else{
       $c->stash->{submission_success}=1;
       $c->stash->{error_message}="No 'plan_uri' or 'experiment_id' key found in the submission";
    }



#    $json_text = JSON::XS->new->utf8->encode ($perl_scalar)
    $c->forward('View::JSON');

}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
