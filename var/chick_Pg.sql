-- DROP TABLE transfer;
CREATE TABLE transfer (
   db_animal         int4,       -- Internal ID of animal
   db_unit           int4,       -- Internal ID of unit
   ext_animal        text,       -- External ID of an animal
   opening_dt        date,       -- number channel is open up to this time
   closing_dt        date,       -- number channel is closed up to this time
   id_set            int4,       -- Set of categories for the numbering scheme
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2        -- version of record
);

-- DROP INDEX  uidx_pk_transfer;
CREATE UNIQUE INDEX uidx_pk_transfer ON transfer ( db_unit, ext_animal )
WHERE closing_dt is NULL;

-- DROP INDEX idx_transfer_1;
CREATE  INDEX idx_transfer_1 ON transfer ( db_animal );
-- DROP INDEX idx_transfer_2;
CREATE  INDEX idx_transfer_2 ON transfer ( ext_animal, db_unit );

-- DROP INDEX uidx_transfer_rowid;
CREATE UNIQUE INDEX uidx_transfer_rowid ON transfer ( guid );

-- DROP SEQUENCE seq_transfer__db_animal;
CREATE SEQUENCE seq_transfer__db_animal;

-- DROP TABLE event;
CREATE TABLE event (
   db_event          int4,       -- Internal ID of an event
   db_event_type     int4,       -- Internal ID of a performence test
   event_dt          date,       -- Date of the event
   db_location       int4,       -- Internal ID of the location of performance
   db_sampler        int4,       -- Internal ID of a sampler
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2        -- version of record
);

-- DROP INDEX  uidx_pk_event;
CREATE UNIQUE INDEX uidx_pk_event ON event ( db_event_type, event_dt, db_location );

-- DROP INDEX idx_event_1;
CREATE  INDEX idx_event_1 ON event ( db_event );
-- DROP INDEX idx_event_2;
CREATE  INDEX idx_event_2 ON event ( db_event_type );
-- DROP INDEX idx_event_3;
CREATE  INDEX idx_event_3 ON event ( db_event_type, event_dt );

-- DROP INDEX uidx_event_rowid;
CREATE UNIQUE INDEX uidx_event_rowid ON event ( guid );

-- DROP SEQUENCE seq_event__db_event;
CREATE SEQUENCE seq_event__db_event;

-- DROP TABLE unit;
CREATE TABLE unit (
   db_unit           int4,       -- Internal ID of a unit
   ext_unit          text,       -- Class of a unit
   ext_id            text,       -- External name of a unit
   db_role           int4,       -- Short name of a code
   db_member         int4,       -- Short name of a code
   db_address        int4,       -- Short name of a code
   opening_dt        date,       -- number channel is open up to this time
   closing_dt        date,       -- number channel is closed up to this time
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2        -- version of record
);

-- DROP INDEX  uidx_pk_unit;
CREATE UNIQUE INDEX uidx_pk_unit ON unit ( ext_unit, ext_id )
WHERE closing_dt is NULL;

-- DROP INDEX idx_unit_1;
CREATE  INDEX idx_unit_1 ON unit ( db_unit );
-- DROP INDEX idx_unit_2;
CREATE  INDEX idx_unit_2 ON unit ( ext_unit, ext_id );

-- DROP INDEX uidx_unit_rowid;
CREATE UNIQUE INDEX uidx_unit_rowid ON unit ( guid );

-- DROP SEQUENCE seq_unit__db_unit;
CREATE SEQUENCE seq_unit__db_unit;

-- DROP TABLE codes;
CREATE TABLE codes (
   db_code           int4,       -- Internal ID of a code
   class             text,       -- Internal ID of a code
   ext_code          text,       -- External name of a code
   short_name        text,       -- Short name of a code
   long_name         text,       -- Long name of a code
   description       text,       -- Description of a code
   opening_dt        date,       -- number channel is open up to this time
   closing_dt        date,       -- number channel is closed up to this time
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2        -- version of record
);

-- DROP INDEX  uidx_pk_codes;
CREATE UNIQUE INDEX uidx_pk_codes ON codes ( class, ext_code )
WHERE closing_dt is NULL;

-- DROP INDEX idx_codes_1;
CREATE  INDEX idx_codes_1 ON codes ( db_code );
-- DROP INDEX idx_codes_2;
CREATE  INDEX idx_codes_2 ON codes ( class, ext_code );

-- DROP INDEX uidx_codes_rowid;
CREATE UNIQUE INDEX uidx_codes_rowid ON codes ( guid );

-- DROP SEQUENCE seq_codes__db_code;
CREATE SEQUENCE seq_codes__db_code;

-- DROP TABLE address;
CREATE TABLE address (
   db_address        int4,       -- Internal ID of an address
   ext_address       text,       -- External name of a address
   db_title          int4,       -- Title of a person
   db_salutation     int4,       -- Salutation of a person
   first_name        text,       -- Firstname of a person
   second_name       text,       -- Second name of a person
   street            text,       -- Streed
   hz                text,       -- HZ
   zip               text,       -- Zip
   town              text,       -- Town
   zu_haenden        text,       -- for person
   firma_name        text,       -- firma_name
   birth_dt          text,       -- birth_dt
   county            text,       -- County
   db_country        int4,       -- Country
   db_language       int4,       -- Language
   phone_priv        text,       -- phone_priv
   phone_firma       text,       -- phone_firma
   phone_mobil       text,       -- phone_mobil
   fax               text,       -- fax
   email             text,       -- email
   http              text,       -- http
   comment           text,       -- comment
   bank              text,       -- bank
   iban              text,       -- iban
   bic               text,       -- bic
   db_payment        int4,       -- db_payment
   member_entry_dt   date,       -- member_entry_dt
   member_exit_dt    date,       -- member_exit_dt
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2        -- version of record
);

-- DROP INDEX  uidx_pk_address;
CREATE UNIQUE INDEX uidx_pk_address ON address ( ext_address );

-- DROP INDEX idx_address_1;
CREATE  INDEX idx_address_1 ON address ( db_address );
-- DROP INDEX idx_address_2;
CREATE  INDEX idx_address_2 ON address ( ext_address );

-- DROP INDEX uidx_address_rowid;
CREATE UNIQUE INDEX uidx_address_rowid ON address ( guid );

-- DROP SEQUENCE seq_address__db_address;
CREATE SEQUENCE seq_address__db_address;

-- DROP TABLE animal;
CREATE TABLE animal (
   db_animal         int4,       -- Internal ID of animal
   db_sire           int4,       -- Internal ID of sire
   db_dam            int4,       -- Internal ID of dam
   db_sex            int4,       -- Sex of an animal
   db_breed          int4,       -- Breed of an animal
   db_selection      int4,       -- Selection status of an animal
   birth_dt          date,       -- birth date
   la_rep_dt         date,       -- Internal use of a date for checking
   la_rep            text,       -- Last action
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2,       -- version of record
   db_cage           int4,       
   line              float4,     
   exit_dt           date,       
   db_exit           int4        
);

-- DROP INDEX uidx_animal_1;
CREATE UNIQUE INDEX uidx_animal_1 ON animal ( db_animal );
-- DROP INDEX idx_animal_2;
CREATE  INDEX idx_animal_2 ON animal ( db_sire );
-- DROP INDEX idx_animal_3;
CREATE  INDEX idx_animal_3 ON animal ( db_dam );

-- DROP INDEX uidx_animal_rowid;
CREATE UNIQUE INDEX uidx_animal_rowid ON animal ( guid );

-- DROP TABLE locations;
CREATE TABLE locations (
   db_animal         int4,       -- Internal ID of animal
   entry_dt          date,       -- animal comes into an location
   db_entry_action   int4,       -- Action while entering the location
   exit_dt           date,       -- animal goes out of an location
   db_exit_action    int4,       -- Action while leaving the location
   db_location       int4,       -- Animal location - it can be farm or enclosure or even field
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2        -- version of record
);

-- DROP INDEX idx_locations_1;
CREATE  INDEX idx_locations_1 ON locations ( db_location );
-- DROP INDEX idx_locations_2;
CREATE  INDEX idx_locations_2 ON locations ( db_animal );

-- DROP INDEX uidx_locations_rowid;
CREATE UNIQUE INDEX uidx_locations_rowid ON locations ( guid );

-- DROP TABLE languages;
CREATE TABLE languages (
   lang_id           int4,       -- language id
   iso_lang          text,       -- language id
   lang              text,       -- language id
   creation_dt       timestamp,  -- Timestamp of creation
   creation_user     text,       -- Who did the creation
   end_dt            timestamp,  -- Timestamp of creation
   end_user          text,       -- Who did the creation
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2        -- version of record
);

-- DROP INDEX uidx_languages_1;
CREATE UNIQUE INDEX uidx_languages_1 ON languages ( lang_id );
-- DROP INDEX uidx_languages_2;
CREATE UNIQUE INDEX uidx_languages_2 ON languages ( iso_lang );
-- DROP INDEX uidx_languages_3;
CREATE UNIQUE INDEX uidx_languages_3 ON languages ( guid );

-- DROP INDEX uidx_languages_rowid;
CREATE UNIQUE INDEX uidx_languages_rowid ON languages ( guid );

-- DROP SEQUENCE seq_languages__lang_id;
CREATE SEQUENCE seq_languages__lang_id;

-- DROP TABLE nodes;
CREATE TABLE nodes (
   nodename          text,       -- node name
   address           text,       -- node ip address
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2        -- version of record
);

-- DROP INDEX uidx_nodes_1;
CREATE UNIQUE INDEX uidx_nodes_1 ON nodes ( guid );

-- DROP INDEX uidx_nodes_rowid;
CREATE UNIQUE INDEX uidx_nodes_rowid ON nodes ( guid );

-- DROP SEQUENCE seq_database__guid;
CREATE SEQUENCE seq_database__guid;

-- DROP TABLE pt_indiv;
CREATE TABLE pt_indiv (
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2,       -- version of record
   db_event          int4,       
   db_cage           int4,       
   db_animal         int4,       
   body_wt           float4      
);

-- DROP INDEX uidx_pt_indiv_1;
CREATE UNIQUE INDEX uidx_pt_indiv_1 ON pt_indiv ( db_event, db_animal );

-- DROP INDEX uidx_pt_indiv_rowid;
CREATE UNIQUE INDEX uidx_pt_indiv_rowid ON pt_indiv ( guid );

-- DROP TABLE pt_cage;
CREATE TABLE pt_cage (
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2,       -- version of record
   db_event          int4,       
   db_cage           int4,       
   hen_number        text,       
   body_wt           float4      
);

-- DROP INDEX uidx_pt_cage_1;
CREATE UNIQUE INDEX uidx_pt_cage_1 ON pt_cage ( db_event, db_cage, hen_number );

-- DROP INDEX uidx_pt_cage_rowid;
CREATE UNIQUE INDEX uidx_pt_cage_rowid ON pt_cage ( guid );

-- DROP TABLE possible_dams;
CREATE TABLE possible_dams (
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2,       -- version of record
   db_animal         int4,       
   db_dam1           int4,       
   db_dam2           int4,       
   db_dam3           int4,       
   db_dam4           int4,       
   db_dam5           int4,       
   db_dam6           int4,       
   db_dam7           int4,       
   db_dam8           int4,       
   db_dam9           int4,       
   db_dam10          int4        
);

-- DROP INDEX uidx_possible_dams_1;
CREATE UNIQUE INDEX uidx_possible_dams_1 ON possible_dams ( db_animal );

-- DROP INDEX uidx_possible_dams_rowid;
CREATE UNIQUE INDEX uidx_possible_dams_rowid ON possible_dams ( guid );

-- DROP TABLE eggs_cage;
CREATE TABLE eggs_cage (
   last_change_dt     timestamp,  -- Timestamp of last change
   last_change_user   text,       -- Who did the last change
   dirty              bool,       -- report errors from CHECK_integrity
   synch              bool,       -- is record targeted for synchronization
   chk_lvl            int2,       -- check level
   guid               int4,       -- global indentifier
   owner              text,       -- Who is the owner or record
   version            int2,       -- version of record
   db_event           int4,       
   db_cage            int4,       
   number_hens        float4,     
   total_weight_eggs  float4,     
   n_eggs             float4      
);

-- DROP INDEX uidx_eggs_cage_1;
CREATE UNIQUE INDEX uidx_eggs_cage_1 ON eggs_cage ( db_event, db_cage );

-- DROP INDEX uidx_eggs_cage_rowid;
CREATE UNIQUE INDEX uidx_eggs_cage_rowid ON eggs_cage ( guid );

-- DROP TABLE hatch_cage;
CREATE TABLE hatch_cage (
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   dirty             bool,       -- report errors from CHECK_integrity
   synch             bool,       -- is record targeted for synchronization
   chk_lvl           int2,       -- check level
   guid              int4,       -- global indentifier
   owner             text,       -- Who is the owner or record
   version           int2,       -- version of record
   db_event          int4,       
   db_cage           int4,       
   collected_eggs    float4,     
   incubated_eggs    float4,     
   hatched_eggs      float4,     
   hatch_dt          date,       
   far_id            text        
);

-- DROP INDEX uidx_hatch_cage_1;
CREATE UNIQUE INDEX uidx_hatch_cage_1 ON hatch_cage ( db_cage );

-- DROP INDEX uidx_hatch_cage_rowid;
CREATE UNIQUE INDEX uidx_hatch_cage_rowid ON hatch_cage ( guid );

-- DROP TABLE ar_users;
CREATE TABLE ar_users (
   user_id               int4,       -- unique user number - internal sequence
   user_login            text,       -- login name
   user_password         text,       -- user password
   user_language_id      int4,       -- default language of the user
   user_marker           text,       -- private user identifier which is insert into the owner column
   user_disabled         bool,       -- checking if the user can login to the system
   user_status           bool,       -- current login status of the user (is logged or not)
   user_last_login       timestamp,  -- date of the last login to the system
   user_last_activ_time  time,       -- the time which is updated during the user session after each opertion
   user_session_id       text,       -- session_id  for the interface
   last_change_dt        timestamp,  -- Date of last change, automatic timestamp
   last_change_user      text,       -- User who did the last change
   dirty                 bool,       -- report errors from check_integrity
   chk_lvl               int2,       -- check level
   guid                  int4,       -- global identifier
   owner                 text,       -- record class
   version               int4,       -- version
   synch                 bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_users_1;
CREATE UNIQUE INDEX uidx_ar_users_1 ON ar_users ( user_id );
-- DROP INDEX uidx_ar_users_2;
CREATE UNIQUE INDEX uidx_ar_users_2 ON ar_users ( user_login );
-- DROP INDEX uidx_ar_users_3;
CREATE UNIQUE INDEX uidx_ar_users_3 ON ar_users ( guid );

-- DROP INDEX uidx_ar_users_rowid;
CREATE UNIQUE INDEX uidx_ar_users_rowid ON ar_users ( guid );

-- DROP SEQUENCE seq_ar_users__user_id;
CREATE SEQUENCE seq_ar_users__user_id;

-- DROP TABLE ar_users_data;
CREATE TABLE ar_users_data (
   user_id           int4,       -- Foreign Key to the user table
   user_first_name   text,       -- First name/Department
   user_second_name  text,       -- Family/company name
   user_institution  text,       -- company name
   user_email        text,       -- Email address
   user_country      text,       -- country of the user
   user_street       text,       -- Name of Street + Nr.
   user_town         text,       -- Town name
   user_zip          text,       -- Postal zip code
   user_other_info   text,       -- Comments
   opening_dt        date,       -- Date of opening this record
   closing_dt        date,       -- Date of closing this record
   last_change_dt    timestamp,  -- Timestamp of last change
   last_change_user  text,       -- Who did the last change
   creation_dt       timestamp,  -- Timestamp of creation
   creation_user     text,       -- Who did the creation
   end_dt            timestamp,  -- Timestamp of end using
   end_user          text,       -- Who did the end status
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_users_data_1;
CREATE UNIQUE INDEX uidx_ar_users_data_1 ON ar_users_data ( user_id );
-- DROP INDEX uidx_ar_users_data_2;
CREATE UNIQUE INDEX uidx_ar_users_data_2 ON ar_users_data ( guid );

-- DROP INDEX uidx_ar_users_data_rowid;
CREATE UNIQUE INDEX uidx_ar_users_data_rowid ON ar_users_data ( guid );

-- DROP TABLE ar_roles;
CREATE TABLE ar_roles (
   role_id           int4,       -- unique role number - internal sequence
   role_name         text,       -- unique name of the role
   role_long_name    text,       -- long role name
   role_type         text,       -- the role type which can be specified as ST (System Task) or DBT (Database Task)
   role_subset       text,       -- Names of the roles which are defined as a subset of role
   role_descr        text,       -- description of the role
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_roles_1;
CREATE UNIQUE INDEX uidx_ar_roles_1 ON ar_roles ( role_id );
-- DROP INDEX uidx_ar_roles_2;
CREATE UNIQUE INDEX uidx_ar_roles_2 ON ar_roles ( role_name, role_type );
-- DROP INDEX uidx_ar_roles_3;
CREATE UNIQUE INDEX uidx_ar_roles_3 ON ar_roles ( guid );

-- DROP INDEX uidx_ar_roles_rowid;
CREATE UNIQUE INDEX uidx_ar_roles_rowid ON ar_roles ( guid );

-- DROP SEQUENCE seq_ar_roles__role_id;
CREATE SEQUENCE seq_ar_roles__role_id;

-- DROP TABLE ar_user_roles;
CREATE TABLE ar_user_roles (
   user_id           int4,       -- Foreign Key to the user table
   role_id           int4,       -- Foreign Key to the role table
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_user_roles_1;
CREATE UNIQUE INDEX uidx_ar_user_roles_1 ON ar_user_roles ( user_id, role_id );
-- DROP INDEX uidx_ar_user_roles_2;
CREATE UNIQUE INDEX uidx_ar_user_roles_2 ON ar_user_roles ( guid );

-- DROP INDEX uidx_ar_user_roles_rowid;
CREATE UNIQUE INDEX uidx_ar_user_roles_rowid ON ar_user_roles ( guid );

-- DROP TABLE ar_dbtpolicies;
CREATE TABLE ar_dbtpolicies (
   dbtpolicy_id      int4,       -- unique policy number for the database tasks - internal sequence
   action_id         int4,       -- Foreign Key to the codes table - SQL action type
   table_id          int4,       -- Foreign Key to the ar_dbttables
   descriptor_id     int4,       -- Foreign Key to the descriptor table
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_dbtpolicies_1;
CREATE UNIQUE INDEX uidx_ar_dbtpolicies_1 ON ar_dbtpolicies ( dbtpolicy_id );
-- DROP INDEX uidx_ar_dbtpolicies_2;
CREATE UNIQUE INDEX uidx_ar_dbtpolicies_2 ON ar_dbtpolicies ( action_id, table_id, descriptor_id );
-- DROP INDEX uidx_ar_dbtpolicies_3;
CREATE UNIQUE INDEX uidx_ar_dbtpolicies_3 ON ar_dbtpolicies ( guid );

-- DROP INDEX uidx_ar_dbtpolicies_rowid;
CREATE UNIQUE INDEX uidx_ar_dbtpolicies_rowid ON ar_dbtpolicies ( guid );

-- DROP SEQUENCE seq_ar_dbtpolicies__dbtpolicy_id;
CREATE SEQUENCE seq_ar_dbtpolicies__dbtpolicy_id;

-- DROP TABLE ar_role_dbtpolicies;
CREATE TABLE ar_role_dbtpolicies (
   role_id           int4,       -- Foreign Key to the role table
   dbtpolicy_id      int4,       -- Foreign Key to the database policies table
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_role_dbtpolicies_1;
CREATE UNIQUE INDEX uidx_ar_role_dbtpolicies_1 ON ar_role_dbtpolicies ( role_id, dbtpolicy_id );
-- DROP INDEX uidx_ar_role_dbtpolicies_2;
CREATE UNIQUE INDEX uidx_ar_role_dbtpolicies_2 ON ar_role_dbtpolicies ( guid );

-- DROP INDEX uidx_ar_role_dbtpolicies_rowid;
CREATE UNIQUE INDEX uidx_ar_role_dbtpolicies_rowid ON ar_role_dbtpolicies ( guid );

-- DROP TABLE ar_dbttables;
CREATE TABLE ar_dbttables (
   table_id          int4,       -- unique number - internal sequence
   table_name        text,       -- table name
   table_columns     text,       -- the columns of defined table
   table_desc        text,       -- description of the table
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_dbttables_1;
CREATE UNIQUE INDEX uidx_ar_dbttables_1 ON ar_dbttables ( table_id );
-- DROP INDEX uidx_ar_dbttables_2;
CREATE UNIQUE INDEX uidx_ar_dbttables_2 ON ar_dbttables ( table_name, table_columns );
-- DROP INDEX uidx_ar_dbttables_3;
CREATE UNIQUE INDEX uidx_ar_dbttables_3 ON ar_dbttables ( guid );

-- DROP INDEX uidx_ar_dbttables_rowid;
CREATE UNIQUE INDEX uidx_ar_dbttables_rowid ON ar_dbttables ( guid );

-- DROP SEQUENCE seq_ar_dbttabels__table_id;
CREATE SEQUENCE seq_ar_dbttabels__table_id;

-- DROP TABLE ar_dbtdescriptors;
CREATE TABLE ar_dbtdescriptors (
   descriptor_id     int4,       -- unique descriptor number - internal sequence
   descriptor_name   text,       -- descriptor name is a column name which is used as a one of the filter for the access rights
   descriptor_value  text,       -- the values for defined descriptor (column)
   descriptor_desc   text,       -- description of the descriptor
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_dbtdescriptors_1;
CREATE UNIQUE INDEX uidx_ar_dbtdescriptors_1 ON ar_dbtdescriptors ( descriptor_id );
-- DROP INDEX uidx_ar_dbtdescriptors_2;
CREATE UNIQUE INDEX uidx_ar_dbtdescriptors_2 ON ar_dbtdescriptors ( descriptor_name, descriptor_value );
-- DROP INDEX uidx_ar_dbtdescriptors_3;
CREATE UNIQUE INDEX uidx_ar_dbtdescriptors_3 ON ar_dbtdescriptors ( guid );

-- DROP INDEX uidx_ar_dbtdescriptors_rowid;
CREATE UNIQUE INDEX uidx_ar_dbtdescriptors_rowid ON ar_dbtdescriptors ( guid );

-- DROP SEQUENCE seq_ar_dbtdescriptor__descriptor_id;
CREATE SEQUENCE seq_ar_dbtdescriptor__descriptor_id;

-- DROP TABLE ar_stpolicies;
CREATE TABLE ar_stpolicies (
   stpolicy_id       int4,       -- unique policy number for the system tasks - internal sequence
   stpolicy_name     text,       -- name of the application or form or report or some other action
   stpolicy_type     text,       -- type of system task policy (www, report, form, action, subroutine)
   stpolicy_desc     text,       -- system policy description
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_stpolicies_1;
CREATE UNIQUE INDEX uidx_ar_stpolicies_1 ON ar_stpolicies ( stpolicy_id );
-- DROP INDEX uidx_ar_stpolicies_2;
CREATE UNIQUE INDEX uidx_ar_stpolicies_2 ON ar_stpolicies ( stpolicy_name, stpolicy_type );
-- DROP INDEX uidx_ar_stpolicies_3;
CREATE UNIQUE INDEX uidx_ar_stpolicies_3 ON ar_stpolicies ( guid );

-- DROP INDEX uidx_ar_stpolicies_rowid;
CREATE UNIQUE INDEX uidx_ar_stpolicies_rowid ON ar_stpolicies ( guid );

-- DROP SEQUENCE seq_ar_stpolicies__stpolicy_id;
CREATE SEQUENCE seq_ar_stpolicies__stpolicy_id;

-- DROP TABLE ar_role_stpolicies;
CREATE TABLE ar_role_stpolicies (
   role_id           int4,       -- Foreign Key to the role table
   stpolicy_id       int4,       -- Foreign Key to the system policies table
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_role_stpolicies_1;
CREATE UNIQUE INDEX uidx_ar_role_stpolicies_1 ON ar_role_stpolicies ( role_id, stpolicy_id );
-- DROP INDEX uidx_ar_role_stpolicies_2;
CREATE UNIQUE INDEX uidx_ar_role_stpolicies_2 ON ar_role_stpolicies ( guid );

-- DROP INDEX uidx_ar_role_stpolicies_rowid;
CREATE UNIQUE INDEX uidx_ar_role_stpolicies_rowid ON ar_role_stpolicies ( guid );

-- DROP TABLE ar_constraints;
CREATE TABLE ar_constraints (
   cons_id           int4,       -- unique constraints number - internal sequence
   cons_name         text,       -- constraints name
   cons_type         text,       -- constraints type which can be defined as: user-group, group-group, role-group
   cons_desc         text,       -- constraint description
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_constraints_1;
CREATE UNIQUE INDEX uidx_ar_constraints_1 ON ar_constraints ( cons_id );
-- DROP INDEX uidx_ar_constraints_2;
CREATE UNIQUE INDEX uidx_ar_constraints_2 ON ar_constraints ( cons_name, cons_type );
-- DROP INDEX uidx_ar_constraints_3;
CREATE UNIQUE INDEX uidx_ar_constraints_3 ON ar_constraints ( guid );

-- DROP INDEX uidx_ar_constraints_rowid;
CREATE UNIQUE INDEX uidx_ar_constraints_rowid ON ar_constraints ( guid );

-- DROP SEQUENCE seq_ar_constraints__cons_id;
CREATE SEQUENCE seq_ar_constraints__cons_id;

-- DROP TABLE ar_role_constraints;
CREATE TABLE ar_role_constraints (
   cons_id           int4,       -- Foreign Key to the constraints table
   first_role_id     int4,       -- Foreign Key to the roles table
   second_role_id    int4,       -- Foreign Key to the roles table
   last_change_dt    timestamp,  -- Date of last change, automatic timestamp
   last_change_user  text,       -- User who did the last change
   dirty             bool,       -- report errors from check_integrity
   chk_lvl           int2,       -- check level
   guid              int4,       -- global identifier
   owner             text,       -- record class
   version           int4,       -- version
   synch             bool        -- is record targeted for synchronization
);

-- DROP INDEX uidx_ar_role_constraints_1;
CREATE UNIQUE INDEX uidx_ar_role_constraints_1 ON ar_role_constraints ( cons_id, first_role_id, second_role_id );
-- DROP INDEX uidx_ar_role_constraints_2;
CREATE UNIQUE INDEX uidx_ar_role_constraints_2 ON ar_role_constraints ( guid );

-- DROP INDEX uidx_ar_role_constraints_rowid;
CREATE UNIQUE INDEX uidx_ar_role_constraints_rowid ON ar_role_constraints ( guid );

-- DROP VIEW v_transfer;
CREATE VIEW v_transfer AS
SELECT a.guid AS v_guid,
       a.db_animal,
       a.db_unit,
       b.ext_unit || ':::' || b.ext_id AS ext_unit,
       a.ext_animal,
       a.opening_dt,
       a.closing_dt,
       a.id_set,
       c.ext_code AS ext_id_set,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version
FROM transfer a LEFT OUTER JOIN unit b ON a.db_unit = b.db_unit
                LEFT OUTER JOIN codes c ON a.id_set = c.db_code;

-- DROP VIEW v_event;
CREATE VIEW v_event AS
SELECT a.guid AS v_guid,
       a.db_event,
       a.db_event_type,
       b.ext_code AS ext_event_type,
       a.event_dt,
       a.db_location,
       c.ext_unit || ':::' || c.ext_id AS ext_location,
       a.db_sampler,
       d.ext_unit || ':::' || d.ext_id AS ext_sampler,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version
FROM event a LEFT OUTER JOIN codes b ON a.db_event_type = b.db_code
             LEFT OUTER JOIN unit c ON a.db_location = c.db_unit
             LEFT OUTER JOIN unit d ON a.db_sampler = d.db_unit;

-- DROP VIEW v_unit;
CREATE VIEW v_unit AS
SELECT a.guid AS v_guid,
       a.db_unit,
       a.ext_unit,
       a.ext_id,
       a.db_role,
       b.ext_address AS ext_role,
       a.db_member,
       c.ext_address AS ext_member,
       a.db_address,
       d.ext_address AS ext_address,
       a.opening_dt,
       a.closing_dt,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version
FROM unit a LEFT OUTER JOIN address b ON a.db_role = b.db_address
            LEFT OUTER JOIN address c ON a.db_member = c.db_address
            LEFT OUTER JOIN address d ON a.db_address = d.db_address;

-- DROP VIEW v_codes;
CREATE VIEW v_codes AS
SELECT a.guid AS v_guid,
       a.db_code,
       a.class,
       a.ext_code,
       a.short_name,
       a.long_name,
       a.description,
       a.opening_dt,
       a.closing_dt,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version
FROM codes a;

-- DROP VIEW v_address;
CREATE VIEW v_address AS
SELECT a.guid AS v_guid,
       a.db_address,
       a.ext_address,
       a.db_title,
       b.ext_code AS ext_title,
       a.db_salutation,
       c.ext_code AS ext_salutation,
       a.first_name,
       a.second_name,
       a.street,
       a.hz,
       a.zip,
       a.town,
       a.zu_haenden,
       a.firma_name,
       a.birth_dt,
       a.county,
       a.db_country,
       d.ext_code AS ext_country,
       a.db_language,
       e.ext_code AS ext_language,
       a.phone_priv,
       a.phone_firma,
       a.phone_mobil,
       a.fax,
       a.email,
       a.http,
       a.comment,
       a.bank,
       a.iban,
       a.bic,
       a.db_payment,
       f.ext_code AS ext_payment,
       a.member_entry_dt,
       a.member_exit_dt,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version
FROM address a LEFT OUTER JOIN codes b ON a.db_title = b.db_code
               LEFT OUTER JOIN codes c ON a.db_salutation = c.db_code
               LEFT OUTER JOIN codes d ON a.db_country = d.db_code
               LEFT OUTER JOIN codes e ON a.db_language = e.db_code
               LEFT OUTER JOIN codes f ON a.db_payment = f.db_code;

-- DROP VIEW v_animal;
CREATE VIEW v_animal AS
SELECT a.guid AS v_guid,
       a.db_animal,
       c.ext_unit || ':::' || c.ext_id || ':::' || b.ext_animal AS ext_animal,
       a.db_sire,
       e.ext_unit || ':::' || e.ext_id || ':::' || d.ext_animal AS ext_sire,
       a.db_dam,
       g.ext_unit || ':::' || g.ext_id || ':::' || f.ext_animal AS ext_dam,
       a.db_sex,
       h.ext_code AS ext_sex,
       a.db_breed,
       i.ext_code AS ext_breed,
       a.db_selection,
       j.ext_code AS ext_selection,
       a.birth_dt,
       a.la_rep_dt,
       a.la_rep,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.db_cage,
       k.ext_unit || ':::' || k.ext_id AS ext_cage,
       a.line,
       a.exit_dt,
       a.db_exit
FROM animal a LEFT OUTER JOIN transfer b ON a.db_animal = b.db_animal
              LEFT OUTER JOIN unit c ON b.db_unit = c.db_unit
              LEFT OUTER JOIN transfer d ON a.db_sire = d.db_animal
              LEFT OUTER JOIN unit e ON d.db_unit = e.db_unit
              LEFT OUTER JOIN transfer f ON a.db_dam = f.db_animal
              LEFT OUTER JOIN unit g ON f.db_unit = g.db_unit
              LEFT OUTER JOIN codes h ON a.db_sex = h.db_code
              LEFT OUTER JOIN codes i ON a.db_breed = i.db_code
              LEFT OUTER JOIN codes j ON a.db_selection = j.db_code
              LEFT OUTER JOIN unit k ON a.db_cage = k.db_unit;

-- DROP VIEW v_locations;
CREATE VIEW v_locations AS
SELECT a.guid AS v_guid,
       a.db_animal,
       c.ext_unit || ':::' || c.ext_id || ':::' || b.ext_animal AS ext_animal,
       a.entry_dt,
       a.db_entry_action,
       d.ext_code AS ext_entry_action,
       a.exit_dt,
       a.db_exit_action,
       e.ext_code AS ext_exit_action,
       a.db_location,
       f.ext_unit || ':::' || f.ext_id AS ext_location,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version
FROM locations a LEFT OUTER JOIN transfer b ON a.db_animal = b.db_animal
                 LEFT OUTER JOIN unit c ON b.db_unit = c.db_unit
                 LEFT OUTER JOIN codes d ON a.db_entry_action = d.db_code
                 LEFT OUTER JOIN codes e ON a.db_exit_action = e.db_code
                 LEFT OUTER JOIN unit f ON a.db_location = f.db_unit;

-- DROP VIEW v_languages;
CREATE VIEW v_languages AS
SELECT a.guid AS v_guid,
       a.lang_id,
       a.iso_lang,
       a.lang,
       a.creation_dt,
       a.creation_user,
       a.end_dt,
       a.end_user,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version
FROM languages a;

-- DROP VIEW v_nodes;
CREATE VIEW v_nodes AS
SELECT a.guid AS v_guid,
       a.nodename,
       a.address,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version
FROM nodes a;

-- DROP VIEW v_pt_indiv;
CREATE VIEW v_pt_indiv AS
SELECT a.guid AS v_guid,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.db_event,
       c.class || ':::' || c.ext_code || ':::' || b.event_dt || ':::' || d.ext_unit || ':::' || d.ext_id AS ext_event,
       a.db_cage,
       e.ext_unit || ':::' || e.ext_id AS ext_cage,
       a.db_animal,
       g.ext_unit || ':::' || g.ext_id || ':::' || f.ext_animal AS ext_animal,
       a.body_wt
FROM pt_indiv a LEFT OUTER JOIN event b ON a.db_event = b.db_event
                LEFT OUTER JOIN codes c ON b.db_event_type = c.db_code
                LEFT OUTER JOIN unit d ON b.db_location = d.db_unit
                LEFT OUTER JOIN unit e ON a.db_cage = e.db_unit
                LEFT OUTER JOIN transfer f ON a.db_animal = f.db_animal
                LEFT OUTER JOIN unit g ON f.db_unit = g.db_unit;

-- DROP VIEW v_pt_cage;
CREATE VIEW v_pt_cage AS
SELECT a.guid AS v_guid,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.db_event,
       c.class || ':::' || c.ext_code || ':::' || b.event_dt || ':::' || d.ext_unit || ':::' || d.ext_id AS ext_event,
       a.db_cage,
       e.ext_unit || ':::' || e.ext_id AS ext_cage,
       a.hen_number,
       a.body_wt
FROM pt_cage a LEFT OUTER JOIN event b ON a.db_event = b.db_event
               LEFT OUTER JOIN codes c ON b.db_event_type = c.db_code
               LEFT OUTER JOIN unit d ON b.db_location = d.db_unit
               LEFT OUTER JOIN unit e ON a.db_cage = e.db_unit;

-- DROP VIEW v_possible_dams;
CREATE VIEW v_possible_dams AS
SELECT a.guid AS v_guid,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.db_animal,
       c.ext_unit || ':::' || c.ext_id || ':::' || b.ext_animal AS ext_animal,
       a.db_dam1,
       e.ext_unit || ':::' || e.ext_id || ':::' || d.ext_animal AS ext_dam1,
       a.db_dam2,
       g.ext_unit || ':::' || g.ext_id || ':::' || f.ext_animal AS ext_dam2,
       a.db_dam3,
       i.ext_unit || ':::' || i.ext_id || ':::' || h.ext_animal AS ext_dam3,
       a.db_dam4,
       k.ext_unit || ':::' || k.ext_id || ':::' || j.ext_animal AS ext_dam4,
       a.db_dam5,
       m.ext_unit || ':::' || m.ext_id || ':::' || l.ext_animal AS ext_dam5,
       a.db_dam6,
       o.ext_unit || ':::' || o.ext_id || ':::' || n.ext_animal AS ext_dam6,
       a.db_dam7,
       q.ext_unit || ':::' || q.ext_id || ':::' || p.ext_animal AS ext_dam7,
       a.db_dam8,
       s.ext_unit || ':::' || s.ext_id || ':::' || r.ext_animal AS ext_dam8,
       a.db_dam9,
       u.ext_unit || ':::' || u.ext_id || ':::' || t.ext_animal AS ext_dam9,
       a.db_dam10,
       w.ext_unit || ':::' || w.ext_id || ':::' || v.ext_animal AS ext_dam10
FROM possible_dams a LEFT OUTER JOIN transfer b ON a.db_animal = b.db_animal
                     LEFT OUTER JOIN unit c ON b.db_unit = c.db_unit
                     LEFT OUTER JOIN transfer d ON a.db_dam1 = d.db_animal
                     LEFT OUTER JOIN unit e ON d.db_unit = e.db_unit
                     LEFT OUTER JOIN transfer f ON a.db_dam2 = f.db_animal
                     LEFT OUTER JOIN unit g ON f.db_unit = g.db_unit
                     LEFT OUTER JOIN transfer h ON a.db_dam3 = h.db_animal
                     LEFT OUTER JOIN unit i ON h.db_unit = i.db_unit
                     LEFT OUTER JOIN transfer j ON a.db_dam4 = j.db_animal
                     LEFT OUTER JOIN unit k ON j.db_unit = k.db_unit
                     LEFT OUTER JOIN transfer l ON a.db_dam5 = l.db_animal
                     LEFT OUTER JOIN unit m ON l.db_unit = m.db_unit
                     LEFT OUTER JOIN transfer n ON a.db_dam6 = n.db_animal
                     LEFT OUTER JOIN unit o ON n.db_unit = o.db_unit
                     LEFT OUTER JOIN transfer p ON a.db_dam7 = p.db_animal
                     LEFT OUTER JOIN unit q ON p.db_unit = q.db_unit
                     LEFT OUTER JOIN transfer r ON a.db_dam8 = r.db_animal
                     LEFT OUTER JOIN unit s ON r.db_unit = s.db_unit
                     LEFT OUTER JOIN transfer t ON a.db_dam9 = t.db_animal
                     LEFT OUTER JOIN unit u ON t.db_unit = u.db_unit
                     LEFT OUTER JOIN transfer v ON a.db_dam10 = v.db_animal
                     LEFT OUTER JOIN unit w ON v.db_unit = w.db_unit;

-- DROP VIEW v_eggs_cage;
CREATE VIEW v_eggs_cage AS
SELECT a.guid AS v_guid,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.db_event,
       c.class || ':::' || c.ext_code || ':::' || b.event_dt || ':::' || d.ext_unit || ':::' || d.ext_id AS ext_event,
       a.db_cage,
       e.ext_unit || ':::' || e.ext_id AS ext_cage,
       a.number_hens,
       a.total_weight_eggs,
       a.n_eggs
FROM eggs_cage a LEFT OUTER JOIN event b ON a.db_event = b.db_event
                 LEFT OUTER JOIN codes c ON b.db_event_type = c.db_code
                 LEFT OUTER JOIN unit d ON b.db_location = d.db_unit
                 LEFT OUTER JOIN unit e ON a.db_cage = e.db_unit;

-- DROP VIEW v_hatch_cage;
CREATE VIEW v_hatch_cage AS
SELECT a.guid AS v_guid,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.synch,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.db_event,
       c.class || ':::' || c.ext_code || ':::' || b.event_dt || ':::' || d.ext_unit || ':::' || d.ext_id AS ext_event,
       a.db_cage,
       e.ext_unit || ':::' || e.ext_id AS ext_cage,
       a.collected_eggs,
       a.incubated_eggs,
       a.hatched_eggs,
       a.hatch_dt,
       a.far_id
FROM hatch_cage a LEFT OUTER JOIN event b ON a.db_event = b.db_event
                  LEFT OUTER JOIN codes c ON b.db_event_type = c.db_code
                  LEFT OUTER JOIN unit d ON b.db_location = d.db_unit
                  LEFT OUTER JOIN unit e ON a.db_cage = e.db_unit;

-- DROP VIEW v_ar_users;
CREATE VIEW v_ar_users AS
SELECT a.guid AS v_guid,
       a.user_id,
       a.user_login,
       a.user_password,
       a.user_language_id,
       a.user_marker,
       a.user_disabled,
       a.user_status,
       a.user_last_login,
       a.user_last_activ_time,
       a.user_session_id,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_users a;

-- DROP VIEW v_ar_users_data;
CREATE VIEW v_ar_users_data AS
SELECT a.guid AS v_guid,
       a.user_id,
       a.user_first_name,
       a.user_second_name,
       a.user_institution,
       a.user_email,
       a.user_country,
       a.user_street,
       a.user_town,
       a.user_zip,
       a.user_other_info,
       a.opening_dt,
       a.closing_dt,
       a.last_change_dt,
       a.last_change_user,
       a.creation_dt,
       a.creation_user,
       a.end_dt,
       a.end_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_users_data a;

-- DROP VIEW v_ar_roles;
CREATE VIEW v_ar_roles AS
SELECT a.guid AS v_guid,
       a.role_id,
       a.role_name,
       a.role_long_name,
       a.role_type,
       a.role_subset,
       a.role_descr,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_roles a;

-- DROP VIEW v_ar_user_roles;
CREATE VIEW v_ar_user_roles AS
SELECT a.guid AS v_guid,
       a.user_id,
       a.role_id,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_user_roles a;

-- DROP VIEW v_ar_dbtpolicies;
CREATE VIEW v_ar_dbtpolicies AS
SELECT a.guid AS v_guid,
       a.dbtpolicy_id,
       a.action_id,
       b.ext_code AS ext_action_id,
       a.table_id,
       a.descriptor_id,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_dbtpolicies a LEFT OUTER JOIN codes b ON a.action_id = b.db_code;

-- DROP VIEW v_ar_role_dbtpolicies;
CREATE VIEW v_ar_role_dbtpolicies AS
SELECT a.guid AS v_guid,
       a.role_id,
       a.dbtpolicy_id,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_role_dbtpolicies a;

-- DROP VIEW v_ar_dbttables;
CREATE VIEW v_ar_dbttables AS
SELECT a.guid AS v_guid,
       a.table_id,
       a.table_name,
       a.table_columns,
       a.table_desc,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_dbttables a;

-- DROP VIEW v_ar_dbtdescriptors;
CREATE VIEW v_ar_dbtdescriptors AS
SELECT a.guid AS v_guid,
       a.descriptor_id,
       a.descriptor_name,
       a.descriptor_value,
       a.descriptor_desc,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_dbtdescriptors a;

-- DROP VIEW v_ar_stpolicies;
CREATE VIEW v_ar_stpolicies AS
SELECT a.guid AS v_guid,
       a.stpolicy_id,
       a.stpolicy_name,
       a.stpolicy_type,
       a.stpolicy_desc,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_stpolicies a;

-- DROP VIEW v_ar_role_stpolicies;
CREATE VIEW v_ar_role_stpolicies AS
SELECT a.guid AS v_guid,
       a.role_id,
       a.stpolicy_id,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_role_stpolicies a;

-- DROP VIEW v_ar_constraints;
CREATE VIEW v_ar_constraints AS
SELECT a.guid AS v_guid,
       a.cons_id,
       a.cons_name,
       a.cons_type,
       a.cons_desc,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_constraints a;

-- DROP VIEW v_ar_role_constraints;
CREATE VIEW v_ar_role_constraints AS
SELECT a.guid AS v_guid,
       a.cons_id,
       a.first_role_id,
       a.second_role_id,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM ar_role_constraints a;


-- DROP VIEW entry_transfer;
CREATE VIEW entry_transfer AS
SELECT      db_animal, db_unit, ext_animal, opening_dt, closing_dt, id_set, last_change_dt, last_change_user, dirty, synch, chk_lvl, guid, owner, version
FROM        transfer
WHERE       closing_dt is NULL;

-- DROP VIEW entry_unit;
CREATE VIEW entry_unit AS
SELECT      db_unit, ext_unit, ext_id, db_role, db_member, db_address, opening_dt, closing_dt, last_change_dt, last_change_user, dirty, synch, chk_lvl, guid, owner, version
FROM        unit
WHERE       closing_dt is NULL;

-- DROP VIEW entry_codes;
CREATE VIEW entry_codes AS
SELECT      db_code, class, ext_code, short_name, long_name, description, opening_dt, closing_dt, last_change_dt, last_change_user, dirty, synch, chk_lvl, guid, owner, version
FROM        codes
WHERE       closing_dt is NULL;

