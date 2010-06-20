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
         $c->detach('View::JSON');
     }

     #fetch experiment or create a new one
     my $expt;
     if ($plan_uri){
       warn "\n $plan_uri \n";
    
       $plan_uri =~ s/\%2f/\//i;

       #check it's a full uri
       $plan_uri = "http://$plan_uri" unless ($plan_uri =~ /w+\:\/\/.*/);

	$data->{plan_uri} = $plan_uri;


         warn "Creating new experiment for plan $plan_uri";
        $expt = $self->create_experiment($c,$data);
        delete $data->{plan_uri};
     }else{
        $expt = $c->model('DB::Experiment')->find({id => $expt_id});
        warn "Usign experiment ". $expt->id;
        delete $data->{experiment_id};
     }

     #bail if  we don't have an expt by now.
     unless($expt){          
         $c->stash->{submission_success}=0;
         $c->stash->{error_message}="No 'plan_uri' or 'experiment_id' key found in the submission";
         $c->detach('View::JSON');
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

   my $request = HTTP::Request->new(GET => $url);
   my $ua = LWP::UserAgent->new;
   my $response = $ua->request($request);

   unless ($response->code == 200){
      $c->stash->{error_message} = "Couldn't retrieve URL: ".$response->message;
      $c->stash->{submission_success} = 0;
      $c->detach('View::JSON');
   }

   unless ($response->content) {
      $c->stash->{error_message} = "Couldn't retrieve URL $url";
      $c->stash->{submission_success} = 0;
      $c->detach('View::JSON');
    }

   my $plan = XMLin($response->content);
   warn "Got Plan";

   #generate a new experiment from it,
   my $expt = $c->model('DB::Experiment')->create({
         user_id => 1,
         plan_uri => $data->{'plan_uri'},
   });
   warn "Made New Expt";

   #parse the plan to get the required requirements.
   my $stages =  $plan->{"eo:ExperimentPlanStage"};
   foreach my $stage (@$stages){
      my $event = $c->model('DB::Event')->create({
	   experiment_id => $expt->id,
           description => $stage->{'dc:description'},
           title => $stage->{'dc:title'},
           stage_identifier => $stage->{'rdf:about'},
	});
      warn "Created new event ".$event->id;

      my $reqs  = $stage->{'eo:requires'};     
      my $subst = defined($plan->{"eo:YetToExistSubstance"}) ? $plan->{"eo:YetToExistSubstance"} : [];
      my $files = defined($plan->{"eo:YetToExistFile"}) ? $plan->{"eo:YetToExistFile"} : [];

      #All events have a required tag with the same name as their stage_identifier which holds their URI
      my $new_tag = $c->model('DB::Tag')->create({name=>$event->stage_identifier, experiment_id=>$expt->id});
      my $event_req_tags = $c->model('DB::EventRequiredTag')->create({tag_id => $new_tag->id, event_id => $event->id});

      foreach my $tag (values %$reqs ){

        my ($tag_info) =  grep {$_->{'rdf:about'} eq $tag} @$subst;
        #create or retrieve a tag

       my $new_tag =  $c->model('DB::Tag')->search({name=>$tag, experiment_id=>$expt->id})->next 
	          || $c->model('DB::Tag')->create({name=>$tag, experiment_id=>$expt->id}) ;

       warn "created or retrieved tag ".$new_tag->id;

       #link tag to this event
       my $event_req_tags = $c->model('DB::EventRequiredTag')->create({tag_id => $new_tag->id, event_id => $event->id});
       warn 'linked tag '.$new_tag->id.'to event '.$event->id; 
     }
   }

   return $expt;
}




sub tag_experiment{
  my ($self,$c, $expt, $data) = @_;
  foreach my $key (keys %$data){

    my $tag =  $c->model('DB::Tag')->search({name=>$key, experiment_id=>$expt->id})->next
               || $c->model('DB::Tag')->create({name=>$key, experiment_id=>$expt->id}) ;

    $tag->value($key);
    $tag->update;
  }
  
  $self->inspect_pending_events($c, $expt);
   
}

sub inspect_pending_events{
   my ($self,$c, $expt) = @_;

   warn "Checking pending experiments";

   #fetch the events we haven't run yet for this experiment
   my $planned_events = $c->model('DB::Event')->search({
      experiment_id => $expt->id,
      status => 'PLANNED'
   });


   #if we don't have any planned events left we're done.
   return unless $planned_events->count > 0;

   #have we got a uri for it? if so, tell the front controller
    while( my $event = $planned_events->next ){
        warn "Checking URI for event ".$event->stage_identifier;
   
        #find the uri tag 
        my $tags = $c->model('DB::Tag')->search({
           experiment_id => $expt->id,
           name => $event->stage_identifier,
         });
       #does it have a value?
       my $uri = $tags->next->value;
       #run this event, if it does,
       $self->run_event($c, $event, $uri) if $uri;
    }

    #are we wating for anything? if not, we probably need to trigger an alert,
    my $pending_events = $c->model('DB::Event')->search({
      experiment_id => $expt->id,
      status => 'PENDING'
   });
   unless($pending_events->count > 0){
      $self->resolve($c, $expt);
   }
}


sub run_event{
   my($self,$c,$event, $uri) = @_;

   warn "Running event ". $event->stage_identifier; 

   #tell the front controller to watch for a result.
   my $res = $self->to_front_controller({event =>{
                                            resource_uri => $uri, 
                                            plan_uri => $event->experiment->plan_uri, 
                                            experiment_id => $event->experiment->id,
                                            stage_identifier => $event->stage_identifier
 
                                        }});

   $event->status('PENDING');
   $event->update;

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


sub resolve {
  my ($c, $expt) = @_;
  #do some stuff.
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
