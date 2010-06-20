create table user(
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255) NOT NULL,
  forename VARCHAR(255),
  surname VARCHAR(255), 
  email VARCHAR(255),
  phone VARCHAR(255)
);

create table experiment(
   id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
   plan_uri TEXT NOT NULL,
   user_id VARCHAR(255) NOT NULL REFERENCES user(id)
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
   stage_identifier VARCHAR(255) NOT NULL,s
   experiment_id INT NOT NULL REFERENCES experiment(id),
   status enum ('PLANNED', 'PENDING', 'COMPLETE','FAILED') NOT NULL,
   title VARCHAR(255),
   description TEXT
);

/* Bits of metadata that must be defined before the event can be run*/
create table event_required_tags(
  event_id INT NOT NULL REFERENCES event(id),
  tag_id INT NOT NULL REFERENCES tag(id),
  PRIMARY KEY(event_id, tag_id)
);


