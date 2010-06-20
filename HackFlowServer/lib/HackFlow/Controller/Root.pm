package HackFlow::Controller::Root;
use Moose;
use namespace::autoclean;
use JSON;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;
use XML::Simple;
use Data::Dumper;

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
    my $data = $c->req->data || $c->req->params || {};

    my $plan_uri = $data->{plan_uri};
    my $expt_id = $data->{experiment_id};

    unless ($plan_uri || $expt_id){
         $c->stash->{submission_success}=0;
         $c->stash->{error_message}="No 'plan_uri' or 'experiment_id' key found in the submission";
         $c->forward('View::JSON');
     }

     #fetch experiment or create a new one
     my $expt;
     if ($plan_uri){
        $expt = $self->create_experiment($c,$data);
        delete $data->{plan_uri};
        #post to http://science.heroku.com/experiment with {experiment_id};
       
        my $res = $self->to_front_controller({experiment=>{experiment_id => $expt->id,
                                                           resource_url => 'http://a.fake.url.com/'
                                  }});

     }else{
        $expt = $c->model('DB::Experiment')->find({id => $expt_id});
        delete $data->{experiment_id};
     }

     #bail if  we don't have an expt by now.
     unless($expt){          
         $c->stash->{submission_success}=0;
         $c->stash->{error_message}="No 'plan_uri' or 'experiment_id' key found in the submission";
         $c->forward('View::JSON');
     }


     #add any metadata tags:
     $self->tag_experiment($c, $expt, $data);

     $c->stash->{experiment_id} = $expt->id;
     $c->forward('View::JSON');

}


#create a new expt
sub create_experiment{
   my ($self,$c, $data) = @_;
   my $url = $data->{plan_uri};

   my  $request = HTTP::Request->new(GET => $url);
   my $ua = LWP::UserAgent->new;
   my $response = $ua->request($request);

   my $plan = XMLin($response->content);
   die Dumper $plan;

   my $stages =  $plan->{"eo:ExperimentPlanStage"};
   foreach (@$stages){
      my $rdf_res  = $_->{'eo:requires'}->{'rdf:resource'} ;
      die $rdf_res;
   }


   #generate a new experiment from it,
   my $expt = $c->model('DB::Experiment')->create({
         user_id => 1,
         plan_uri => $data->{'plan_uri'},
   });
   return $expt;
}

sub tag_experiment{
  my ($self,$c, $expt, $data) = @_;
  foreach my $key (keys %$data){
     my $tag = $c->model('DB::Tag')->create({
       name => $key,
       experiment_id => $expt->id,
       value => $data->{$key}
     });
  }
  
  $self->try_events($c, $expt);
   
}

sub try_events{
   my ($self,$c, $expt) = @_;

   #fetch the events we haven't run yet for this experiment
   my $planned_events = $c->model('DB::Event')->search({
      experiment_id => $expt->id,
      status => 'PLANNED'
   });

   my $tags = $expt->tags;

   #check the metadata for each one and run it if
   while(my $event = $planned_events->next){
      my $req = $event->required_tags;
       

    }
}


sub run_event{
#   my($self,$c,$event, $uri) = @_;

   #trigger the event

  
   #tell the front controller to watch for a result.
#   my $res = $self->to_front_controller({experiment=>{experiment_id => $event->experiment->id,
#                                                      resource_url => $uri;
#                                        }});


}


#send a message in json to the front controller.
sub to_front_controller{
  my($self, $message) = @_;
  my $json = encode_json $message;        
  my $h = HTTP::Headers->new;
        $h->header('Content-Type' => 'application/json',
                    User_Agent   => 'HackFlow/0.00000000000000001'
                  );
  my  $request = HTTP::Request->new(POST => 'http://science.heroku.com/experiments', $h, $json);
  my $ua = LWP::UserAgent->new;
  my  $response = $ua->request($request);

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
