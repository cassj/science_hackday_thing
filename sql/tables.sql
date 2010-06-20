create table experiment(
   id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
   plan_uri TEXT NOT NULL
);

/* all keys assoc with an experiment (and their vals as we get them) */
create table tags(
   id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
   name VARCHAR(255) NOT NULL,
   experiment_id INT NOT NULL REFERENCES experiment(id),
   value TEXT
);

/* An event, corresponding to a step in the plan */
create table event(
   id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
   event_uri TEXT NOT NULL,
   experiment_id INT NOT NULL REFERENCES experiment(id),
   status enum ('PLANNED', 'COMPLETE','FAILED') NOT NULL
);

/* Bits of metadata that must be defined before the event can be run*/
create table event_required_tags(
  event_id INT NOT NULL REFERENCES event(id),
  tag_id INT NOT NULL REFERENCES tag(id),
  PRIMARY KEY(event_id, tag_id)
);


