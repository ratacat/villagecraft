--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activities (
    id integer NOT NULL,
    trackable_id integer,
    trackable_type character varying(255),
    owner_id integer,
    owner_type character varying(255),
    key character varying(255),
    parameters text,
    recipient_id integer,
    recipient_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: attendances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attendances (
    id integer NOT NULL,
    event_id integer,
    user_id integer,
    guests integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255),
    message text,
    uuid character varying(255),
    deleted_at timestamp without time zone
);


--
-- Name: attendances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attendances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attendances_id_seq OWNED BY attendances.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    course_id integer,
    host_id integer,
    location_id integer,
    min_attendees integer DEFAULT 0,
    max_attendees integer DEFAULT 8,
    open boolean,
    max_observers integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    secret character varying(255),
    short_title character varying(255),
    price numeric(8,2) DEFAULT 0,
    venue_id integer,
    uuid character varying(255),
    image_id integer,
    state character varying(255),
    workshop_id integer,
    first_meeting_id integer,
    deleted_at timestamp without time zone,
    external boolean,
    external_url character varying(255),
    unlocked_at timestamp without time zone,
    rsvp boolean DEFAULT true
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE images (
    id integer NOT NULL,
    user_id integer,
    uuid character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    i_file_name character varying(255),
    i_content_type character varying(255),
    i_file_size integer,
    i_updated_at timestamp without time zone
);


--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE images_id_seq OWNED BY images.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE locations (
    id integer NOT NULL,
    street character varying(255),
    city character varying(255),
    zip character varying(255),
    state character varying(255),
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    latitude double precision,
    longitude double precision,
    address character varying(255),
    country character varying(255),
    state_code character varying(255),
    time_zone character varying(255),
    neighborhood_id integer,
    deleted_at timestamp without time zone,
    point geometry(Point,4326)
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE locations_id_seq OWNED BY locations.id;


--
-- Name: meetings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meetings (
    id integer NOT NULL,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    snippet text,
    venue_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    uuid character varying(255),
    event_id integer,
    deleted_at timestamp without time zone,
    send_warmup_at timestamp without time zone,
    sent_warmup_at timestamp without time zone,
    send_reminder_at timestamp without time zone,
    sent_reminder_at timestamp without time zone
);


--
-- Name: meetings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE meetings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meetings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE meetings_id_seq OWNED BY meetings.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages (
    id integer NOT NULL,
    uuid character varying(255),
    subject character varying(255),
    body text,
    from_user_id integer,
    to_user_id integer,
    apropos_id integer,
    apropos_type character varying(255),
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    send_at timestamp without time zone,
    sent_at timestamp without time zone
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: neighborhoods; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE neighborhoods (
    id integer NOT NULL,
    state character varying(2),
    county character varying(255),
    city character varying(255),
    name character varying(255),
    regionid numeric,
    geom geometry(MultiPolygon,4326)
);


--
-- Name: neighborhoods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE neighborhoods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: neighborhoods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE neighborhoods_id_seq OWNED BY neighborhoods.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer,
    activity_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    uuid character varying(255),
    deleted_at timestamp without time zone,
    emailed_at timestamp without time zone,
    smsed_at timestamp without time zone,
    seen_at timestamp without time zone,
    email_me boolean,
    sms_me boolean
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reviews (
    id integer NOT NULL,
    author_id integer,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    rating integer DEFAULT 0,
    title character varying(160),
    event_id integer,
    uuid character varying(255)
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reviews_id_seq OWNED BY reviews.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sightings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sightings (
    id integer NOT NULL,
    location_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sightings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sightings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sightings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sightings_id_seq OWNED BY sightings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    username character varying(255),
    number_of_events_attended integer,
    number_of_events_hosted integer,
    number_of_events_reserved integer,
    number_of_people_met integer,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    location_id integer,
    uuid character varying(255),
    profile_image_id integer,
    auth_provider character varying(255),
    auth_provider_uid character varying(255),
    has_set_password boolean DEFAULT true,
    deleted_at timestamp without time zone,
    admin boolean,
    phone character varying(255),
    name character varying(255),
    host boolean,
    authentication_token character varying(255),
    email_notifications boolean DEFAULT true,
    external boolean,
    description text,
    sms_short_messages boolean,
    email_short_messages boolean DEFAULT false,
    promote_host boolean,
    preferred_distance_units character varying(255) DEFAULT 'mi'::character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: venues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE venues (
    id integer NOT NULL,
    name character varying(255),
    owner_id integer,
    location_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    uuid character varying(255),
    deleted_at timestamp without time zone
);


--
-- Name: venues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE venues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: venues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE venues_id_seq OWNED BY venues.id;


--
-- Name: workshops; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workshops (
    id integer NOT NULL,
    title character varying(255),
    description text,
    frequency character varying(255),
    image_id integer,
    host_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    uuid character varying(255),
    deleted_at timestamp without time zone,
    external boolean,
    external_url character varying(255),
    venue_id integer,
    greeting_subject character varying(255),
    greeting_body text,
    warmup_subject character varying(255),
    warmup_body text,
    reminder character varying(255)
);


--
-- Name: workshops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workshops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workshops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workshops_id_seq OWNED BY workshops.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attendances ALTER COLUMN id SET DEFAULT nextval('attendances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY images ALTER COLUMN id SET DEFAULT nextval('images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY locations ALTER COLUMN id SET DEFAULT nextval('locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY meetings ALTER COLUMN id SET DEFAULT nextval('meetings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY neighborhoods ALTER COLUMN id SET DEFAULT nextval('neighborhoods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews ALTER COLUMN id SET DEFAULT nextval('reviews_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sightings ALTER COLUMN id SET DEFAULT nextval('sightings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY venues ALTER COLUMN id SET DEFAULT nextval('venues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workshops ALTER COLUMN id SET DEFAULT nextval('workshops_id_seq'::regclass);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: attendances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attendances
    ADD CONSTRAINT attendances_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meetings
    ADD CONSTRAINT meetings_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: neighborhoods_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY neighborhoods
    ADD CONSTRAINT neighborhoods_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: sightings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sightings
    ADD CONSTRAINT sightings_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: venues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);


--
-- Name: workshops_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workshops
    ADD CONSTRAINT workshops_pkey PRIMARY KEY (id);


--
-- Name: index_activities_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_owner_id_and_owner_type ON activities USING btree (owner_id, owner_type);


--
-- Name: index_activities_on_recipient_id_and_recipient_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_recipient_id_and_recipient_type ON activities USING btree (recipient_id, recipient_type);


--
-- Name: index_activities_on_trackable_id_and_trackable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_trackable_id_and_trackable_type ON activities USING btree (trackable_id, trackable_type);


--
-- Name: index_attendances_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attendances_on_deleted_at ON attendances USING btree (deleted_at);


--
-- Name: index_attendances_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attendances_on_event_id ON attendances USING btree (event_id);


--
-- Name: index_attendances_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attendances_on_user_id ON attendances USING btree (user_id);


--
-- Name: index_events_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_deleted_at ON events USING btree (deleted_at);


--
-- Name: index_events_on_external; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_external ON events USING btree (external);


--
-- Name: index_events_on_first_meeting_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_first_meeting_id ON events USING btree (first_meeting_id);


--
-- Name: index_events_on_image_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_image_id ON events USING btree (image_id);


--
-- Name: index_events_on_rsvp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_rsvp ON events USING btree (rsvp);


--
-- Name: index_events_on_venue_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_venue_id ON events USING btree (venue_id);


--
-- Name: index_events_on_workshop_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_workshop_id ON events USING btree (workshop_id);


--
-- Name: index_images_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_images_on_deleted_at ON images USING btree (deleted_at);


--
-- Name: index_locations_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_locations_on_deleted_at ON locations USING btree (deleted_at);


--
-- Name: index_locations_on_neighborhood_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_locations_on_neighborhood_id ON locations USING btree (neighborhood_id);


--
-- Name: index_locations_on_point; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_locations_on_point ON locations USING gist (point);


--
-- Name: index_meetings_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meetings_on_deleted_at ON meetings USING btree (deleted_at);


--
-- Name: index_meetings_on_send_reminder_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meetings_on_send_reminder_at ON meetings USING btree (send_reminder_at);


--
-- Name: index_meetings_on_send_warmup_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meetings_on_send_warmup_at ON meetings USING btree (send_warmup_at);


--
-- Name: index_meetings_on_sent_reminder_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meetings_on_sent_reminder_at ON meetings USING btree (sent_reminder_at);


--
-- Name: index_meetings_on_sent_warmup_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meetings_on_sent_warmup_at ON meetings USING btree (sent_warmup_at);


--
-- Name: index_meetings_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meetings_on_uuid ON meetings USING btree (uuid);


--
-- Name: index_meetings_on_venue_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meetings_on_venue_id ON meetings USING btree (venue_id);


--
-- Name: index_messages_on_apropos_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_apropos_id ON messages USING btree (apropos_id);


--
-- Name: index_messages_on_apropos_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_apropos_type ON messages USING btree (apropos_type);


--
-- Name: index_messages_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_deleted_at ON messages USING btree (deleted_at);


--
-- Name: index_messages_on_from_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_from_user_id ON messages USING btree (from_user_id);


--
-- Name: index_messages_on_send_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_send_at ON messages USING btree (send_at);


--
-- Name: index_messages_on_sent_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_sent_at ON messages USING btree (sent_at);


--
-- Name: index_messages_on_to_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_to_user_id ON messages USING btree (to_user_id);


--
-- Name: index_messages_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_uuid ON messages USING btree (uuid);


--
-- Name: index_notifications_on_activity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_activity_id ON notifications USING btree (activity_id);


--
-- Name: index_notifications_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_deleted_at ON notifications USING btree (deleted_at);


--
-- Name: index_notifications_on_email_me; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_email_me ON notifications USING btree (email_me);


--
-- Name: index_notifications_on_emailed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_emailed_at ON notifications USING btree (emailed_at);


--
-- Name: index_notifications_on_seen_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_seen_at ON notifications USING btree (seen_at);


--
-- Name: index_notifications_on_sms_me; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_sms_me ON notifications USING btree (sms_me);


--
-- Name: index_notifications_on_smsed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_smsed_at ON notifications USING btree (smsed_at);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_user_id ON notifications USING btree (user_id);


--
-- Name: index_reviews_on_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reviews_on_author_id ON reviews USING btree (author_id);


--
-- Name: index_reviews_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reviews_on_deleted_at ON reviews USING btree (deleted_at);


--
-- Name: index_reviews_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reviews_on_event_id ON reviews USING btree (event_id);


--
-- Name: index_sightings_on_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sightings_on_location_id ON sightings USING btree (location_id);


--
-- Name: index_sightings_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sightings_on_user_id ON sightings USING btree (user_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_deleted_at ON users USING btree (deleted_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_email_short_messages; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_email_short_messages ON users USING btree (email_short_messages);


--
-- Name: index_users_on_external; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_external ON users USING btree (external);


--
-- Name: index_users_on_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_location_id ON users USING btree (location_id);


--
-- Name: index_users_on_preferred_distance_units; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_preferred_distance_units ON users USING btree (preferred_distance_units);


--
-- Name: index_users_on_profile_image_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_profile_image_id ON users USING btree (profile_image_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_sms_short_messages; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_sms_short_messages ON users USING btree (sms_short_messages);


--
-- Name: index_venues_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_venues_on_deleted_at ON venues USING btree (deleted_at);


--
-- Name: index_venues_on_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_venues_on_location_id ON venues USING btree (location_id);


--
-- Name: index_venues_on_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_venues_on_owner_id ON venues USING btree (owner_id);


--
-- Name: index_workshops_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_workshops_on_deleted_at ON workshops USING btree (deleted_at);


--
-- Name: index_workshops_on_external; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_workshops_on_external ON workshops USING btree (external);


--
-- Name: index_workshops_on_host_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_workshops_on_host_id ON workshops USING btree (host_id);


--
-- Name: index_workshops_on_image_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_workshops_on_image_id ON workshops USING btree (image_id);


--
-- Name: index_workshops_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_workshops_on_uuid ON workshops USING btree (uuid);


--
-- Name: index_workshops_on_venue_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_workshops_on_venue_id ON workshops USING btree (venue_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: geometry_columns_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE geometry_columns_delete AS ON DELETE TO geometry_columns DO INSTEAD NOTHING;


--
-- Name: geometry_columns_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE geometry_columns_insert AS ON INSERT TO geometry_columns DO INSTEAD NOTHING;


--
-- Name: geometry_columns_update; Type: RULE; Schema: public; Owner: -
--

CREATE RULE geometry_columns_update AS ON UPDATE TO geometry_columns DO INSTEAD NOTHING;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130425175141');

INSERT INTO schema_migrations (version) VALUES ('20130427224725');

INSERT INTO schema_migrations (version) VALUES ('20130429052327');

INSERT INTO schema_migrations (version) VALUES ('20130513070553');

INSERT INTO schema_migrations (version) VALUES ('20130611052901');

INSERT INTO schema_migrations (version) VALUES ('20130611053213');

INSERT INTO schema_migrations (version) VALUES ('20130611053608');

INSERT INTO schema_migrations (version) VALUES ('20130611053911');

INSERT INTO schema_migrations (version) VALUES ('20130611054212');

INSERT INTO schema_migrations (version) VALUES ('20130611055105');

INSERT INTO schema_migrations (version) VALUES ('20130611191634');

INSERT INTO schema_migrations (version) VALUES ('20130611191656');

INSERT INTO schema_migrations (version) VALUES ('20130612060436');

INSERT INTO schema_migrations (version) VALUES ('20130614070935');

INSERT INTO schema_migrations (version) VALUES ('20130618070756');

INSERT INTO schema_migrations (version) VALUES ('20130621185840');

INSERT INTO schema_migrations (version) VALUES ('20130621191421');

INSERT INTO schema_migrations (version) VALUES ('20130621192042');

INSERT INTO schema_migrations (version) VALUES ('20130621233522');

INSERT INTO schema_migrations (version) VALUES ('20130621234451');

INSERT INTO schema_migrations (version) VALUES ('20130621235352');

INSERT INTO schema_migrations (version) VALUES ('20130622000105');

INSERT INTO schema_migrations (version) VALUES ('20130622003047');

INSERT INTO schema_migrations (version) VALUES ('20130625073502');

INSERT INTO schema_migrations (version) VALUES ('20130625074332');

INSERT INTO schema_migrations (version) VALUES ('20130625074339');

INSERT INTO schema_migrations (version) VALUES ('20130626001845');

INSERT INTO schema_migrations (version) VALUES ('20130705171421');

INSERT INTO schema_migrations (version) VALUES ('20130709032555');

INSERT INTO schema_migrations (version) VALUES ('20130709032725');

INSERT INTO schema_migrations (version) VALUES ('20130709033637');

INSERT INTO schema_migrations (version) VALUES ('20130710235700');

INSERT INTO schema_migrations (version) VALUES ('20130710235844');

INSERT INTO schema_migrations (version) VALUES ('20130712050606');

INSERT INTO schema_migrations (version) VALUES ('20130716062020');

INSERT INTO schema_migrations (version) VALUES ('20130721210528');

INSERT INTO schema_migrations (version) VALUES ('20130723225059');

INSERT INTO schema_migrations (version) VALUES ('20130724032103');

INSERT INTO schema_migrations (version) VALUES ('20130803011040');

INSERT INTO schema_migrations (version) VALUES ('20130805060530');

INSERT INTO schema_migrations (version) VALUES ('20130806054656');

INSERT INTO schema_migrations (version) VALUES ('20130809074419');

INSERT INTO schema_migrations (version) VALUES ('20130826233436');

INSERT INTO schema_migrations (version) VALUES ('20130827064535');

INSERT INTO schema_migrations (version) VALUES ('20130827065539');

INSERT INTO schema_migrations (version) VALUES ('20130827073301');

INSERT INTO schema_migrations (version) VALUES ('20130828080618');

INSERT INTO schema_migrations (version) VALUES ('20130912063520');

INSERT INTO schema_migrations (version) VALUES ('20131001181450');

INSERT INTO schema_migrations (version) VALUES ('20131004032805');

INSERT INTO schema_migrations (version) VALUES ('20131004200709');

INSERT INTO schema_migrations (version) VALUES ('20131014194826');

INSERT INTO schema_migrations (version) VALUES ('20131017001956');

INSERT INTO schema_migrations (version) VALUES ('20131020062302');

INSERT INTO schema_migrations (version) VALUES ('20131020092041');

INSERT INTO schema_migrations (version) VALUES ('20131029053448');

INSERT INTO schema_migrations (version) VALUES ('20131108080816');

INSERT INTO schema_migrations (version) VALUES ('20131109000344');

INSERT INTO schema_migrations (version) VALUES ('20131109001607');

INSERT INTO schema_migrations (version) VALUES ('20131109002707');

INSERT INTO schema_migrations (version) VALUES ('20131109011456');

INSERT INTO schema_migrations (version) VALUES ('20131109012452');

INSERT INTO schema_migrations (version) VALUES ('20131109013703');

INSERT INTO schema_migrations (version) VALUES ('20131109013726');

INSERT INTO schema_migrations (version) VALUES ('20131109021024');

INSERT INTO schema_migrations (version) VALUES ('20131109073509');

INSERT INTO schema_migrations (version) VALUES ('20131109074258');

INSERT INTO schema_migrations (version) VALUES ('20131125065030');

INSERT INTO schema_migrations (version) VALUES ('20131208193226');

INSERT INTO schema_migrations (version) VALUES ('20131208201630');

INSERT INTO schema_migrations (version) VALUES ('20131219070410');

INSERT INTO schema_migrations (version) VALUES ('20131219070514');

INSERT INTO schema_migrations (version) VALUES ('20131219070526');

INSERT INTO schema_migrations (version) VALUES ('20131219072112');

INSERT INTO schema_migrations (version) VALUES ('20131219072125');

INSERT INTO schema_migrations (version) VALUES ('20131219072140');

INSERT INTO schema_migrations (version) VALUES ('20131219072508');

INSERT INTO schema_migrations (version) VALUES ('20131219072535');

INSERT INTO schema_migrations (version) VALUES ('20131219225835');

INSERT INTO schema_migrations (version) VALUES ('20131220083733');

INSERT INTO schema_migrations (version) VALUES ('20131220083747');

INSERT INTO schema_migrations (version) VALUES ('20131222080919');

INSERT INTO schema_migrations (version) VALUES ('20131223092627');

INSERT INTO schema_migrations (version) VALUES ('20131227181226');

INSERT INTO schema_migrations (version) VALUES ('20140110003604');

INSERT INTO schema_migrations (version) VALUES ('20140110205239');

INSERT INTO schema_migrations (version) VALUES ('20140110205504');

INSERT INTO schema_migrations (version) VALUES ('20140110205629');

INSERT INTO schema_migrations (version) VALUES ('20140110205655');

INSERT INTO schema_migrations (version) VALUES ('20140110210757');

INSERT INTO schema_migrations (version) VALUES ('20140120192240');

INSERT INTO schema_migrations (version) VALUES ('20140122060716');

INSERT INTO schema_migrations (version) VALUES ('20140122060741');

INSERT INTO schema_migrations (version) VALUES ('20140122073707');

INSERT INTO schema_migrations (version) VALUES ('20140128213504');

INSERT INTO schema_migrations (version) VALUES ('20140206020811');

INSERT INTO schema_migrations (version) VALUES ('20140206061556');

INSERT INTO schema_migrations (version) VALUES ('20140206073826');

INSERT INTO schema_migrations (version) VALUES ('20140206075938');

INSERT INTO schema_migrations (version) VALUES ('20140211223923');

INSERT INTO schema_migrations (version) VALUES ('20140218044120');

INSERT INTO schema_migrations (version) VALUES ('20140220163903');

INSERT INTO schema_migrations (version) VALUES ('20140226223209');

INSERT INTO schema_migrations (version) VALUES ('20140303132705');

INSERT INTO schema_migrations (version) VALUES ('20140303201055');

INSERT INTO schema_migrations (version) VALUES ('20140303201711');

INSERT INTO schema_migrations (version) VALUES ('20140304212426');

INSERT INTO schema_migrations (version) VALUES ('20140305004713');

INSERT INTO schema_migrations (version) VALUES ('20140306082211');

INSERT INTO schema_migrations (version) VALUES ('20140307065103');

INSERT INTO schema_migrations (version) VALUES ('20140307065212');

INSERT INTO schema_migrations (version) VALUES ('20140307065313');

INSERT INTO schema_migrations (version) VALUES ('20140307093032');

INSERT INTO schema_migrations (version) VALUES ('20140307093132');

INSERT INTO schema_migrations (version) VALUES ('20140310203645');