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
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: authentications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authentications (
    id integer NOT NULL,
    user_id integer,
    provider character varying(255) NOT NULL,
    uid character varying(255) NOT NULL,
    nickname character varying(255),
    name character varying(255),
    email character varying(255),
    location character varying(255),
    url character varying(255),
    image_url character varying(255),
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: authorities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authorities (
    id integer NOT NULL,
    user_id integer,
    authorized_by_id integer,
    item_id integer,
    item_type character varying(255),
    area character varying(31),
    is_owner boolean,
    can_create boolean,
    can_view boolean,
    can_update boolean,
    can_delete boolean,
    can_invite boolean,
    can_permit boolean,
    can_approve boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: authorities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authorities_id_seq OWNED BY authorities.id;


--
-- Name: ballots; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ballots (
    id integer NOT NULL,
    election_id integer NOT NULL,
    office_id integer NOT NULL,
    term_start_on date,
    term_end_on date,
    is_byelection boolean DEFAULT false NOT NULL,
    url character varying(255),
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ballots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ballots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ballots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ballots_id_seq OWNED BY ballots.id;


--
-- Name: candidates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE candidates (
    id integer NOT NULL,
    ballot_id integer NOT NULL,
    person_id integer NOT NULL,
    party_id integer,
    submitter_id integer,
    filename character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    is_rumoured boolean DEFAULT false NOT NULL,
    is_confirmed boolean DEFAULT false NOT NULL,
    is_incumbent boolean DEFAULT false NOT NULL,
    is_leader boolean DEFAULT false NOT NULL,
    is_acclaimed boolean DEFAULT false NOT NULL,
    is_elected boolean DEFAULT false NOT NULL,
    announced_on date,
    quit_on date,
    vote_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: candidates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE candidates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: candidates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE candidates_id_seq OWNED BY candidates.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts (
    id integer NOT NULL,
    item_id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    "position" integer DEFAULT 999 NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    confirmed_at timestamp without time zone,
    expires_at timestamp without time zone,
    name character varying(255),
    organization character varying(255),
    email character varying(255),
    twitter character varying(255),
    url character varying(255),
    phone character varying(255),
    phone2 character varying(255),
    fax character varying(255),
    address1 character varying(255),
    address2 character varying(255),
    city character varying(255),
    province character varying(255),
    country character varying(255),
    postal character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: datastores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE datastores (
    id integer NOT NULL,
    data bytea NOT NULL
);


--
-- Name: datastores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datastores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datastores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE datastores_id_seq OWNED BY datastores.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    datastore_id integer,
    container_path_id integer,
    user_id integer,
    is_authority_controlled boolean DEFAULT false NOT NULL,
    filename character varying(127) NOT NULL,
    size integer NOT NULL,
    content_type character varying(255) NOT NULL,
    charset character varying(31),
    description character varying(1023),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: elections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE elections (
    id integer NOT NULL,
    level_id integer,
    filename character varying(63) NOT NULL,
    name character varying(255) NOT NULL,
    start_on date,
    end_on date,
    description text,
    url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: elections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE elections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: elections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE elections_id_seq OWNED BY elections.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    user_id integer,
    start_at timestamp without time zone NOT NULL,
    end_at timestamp without time zone,
    timezone character varying(31),
    is_allday boolean DEFAULT false NOT NULL,
    is_draft boolean DEFAULT false NOT NULL,
    is_approved boolean DEFAULT false NOT NULL,
    is_wheelchair_accessible boolean DEFAULT false NOT NULL,
    is_adults_only boolean DEFAULT false NOT NULL,
    is_tentative boolean DEFAULT false NOT NULL,
    is_cancelled boolean DEFAULT false NOT NULL,
    is_featured boolean DEFAULT false NOT NULL,
    title character varying(255) NOT NULL,
    description character varying(511),
    content text,
    organizer character varying(255),
    organizer_url character varying(255),
    location character varying(255),
    address character varying(255),
    city character varying(255),
    province character varying(31),
    country character varying(2),
    location_url character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    image_id integer
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
-- Name: external_links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE external_links (
    id integer NOT NULL,
    item_id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    is_source boolean DEFAULT false NOT NULL,
    "position" integer,
    site character varying(31),
    title character varying(255) NOT NULL,
    url text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: external_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE external_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE external_links_id_seq OWNED BY external_links.id;


--
-- Name: image_variants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE image_variants (
    id integer NOT NULL,
    image_id integer NOT NULL,
    height integer,
    width integer,
    format character varying(31) NOT NULL,
    style character varying(15) NOT NULL,
    url text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: image_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE image_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE image_variants_id_seq OWNED BY image_variants.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE images (
    id integer NOT NULL,
    title text,
    alt_text character varying(127),
    description text,
    attribution character varying(127),
    attribution_url text,
    license_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: levels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE levels (
    id integer NOT NULL,
    parent_id integer,
    filename character varying(63) NOT NULL,
    name character varying(255) NOT NULL,
    url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE levels_id_seq OWNED BY levels.id;


--
-- Name: office_holders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE office_holders (
    id integer NOT NULL,
    office_id integer NOT NULL,
    person_id integer NOT NULL,
    previous_id integer NOT NULL,
    start_on date,
    end_on date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: office_holders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE office_holders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: office_holders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE office_holders_id_seq OWNED BY office_holders.id;


--
-- Name: offices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE offices (
    id integer NOT NULL,
    level_id integer NOT NULL,
    previous_id integer,
    filename character varying(63) NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(255),
    "position" integer DEFAULT 0 NOT NULL,
    established_on date,
    ended_on date,
    description text,
    url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: offices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE offices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE offices_id_seq OWNED BY offices.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pages (
    id integer NOT NULL,
    parent_id integer,
    is_authority_controlled boolean DEFAULT false NOT NULL,
    filename character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pages_id_seq OWNED BY pages.id;


--
-- Name: parties; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE parties (
    id integer NOT NULL,
    level_id integer NOT NULL,
    filename character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    abbrev character varying(255) NOT NULL,
    is_registered boolean DEFAULT false NOT NULL,
    colour character varying(255),
    url character varying(255),
    description text,
    established_on date,
    registered_on date,
    ended_on date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    aliases text[]
);


--
-- Name: parties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parties_id_seq OWNED BY parties.id;


--
-- Name: paths; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE paths (
    id integer NOT NULL,
    item_id integer,
    item_type character varying(255),
    sitepath text NOT NULL,
    redirect text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: paths_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE paths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE paths_id_seq OWNED BY paths.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    id integer NOT NULL,
    user_id integer,
    submitter_id integer,
    filename character varying(255) NOT NULL,
    fullname character varying(255) NOT NULL,
    aliases character varying(255)[] DEFAULT '{}'::character varying[] NOT NULL,
    bio text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    parent_id integer,
    creator_id integer NOT NULL,
    owner_id integer NOT NULL,
    is_visible boolean DEFAULT false NOT NULL,
    is_public_content boolean DEFAULT false NOT NULL,
    is_visible_member_list boolean DEFAULT false NOT NULL,
    is_joinable boolean DEFAULT false NOT NULL,
    is_members_can_invite boolean DEFAULT false NOT NULL,
    is_not_unsubscribable boolean DEFAULT false NOT NULL,
    is_moderated boolean DEFAULT false NOT NULL,
    is_only_admin_posts boolean DEFAULT false NOT NULL,
    is_no_comments boolean DEFAULT false NOT NULL,
    filename character varying(255),
    name character varying(255) NOT NULL,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: sourced_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sourced_items (
    id integer NOT NULL,
    source_id integer NOT NULL,
    item_id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    datastore_id integer,
    source_identifier character varying(255),
    last_sourced_at timestamp without time zone NOT NULL,
    has_local_modifications boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sourced_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sourced_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sourced_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sourced_items_id_seq OWNED BY sourced_items.id;


--
-- Name: sources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sources (
    id integer NOT NULL,
    container_item_id integer,
    container_item_type character varying(255),
    datastore_id integer,
    processor character varying(31) NOT NULL,
    url character varying(511) NOT NULL,
    method character varying(7) DEFAULT 'get'::character varying NOT NULL,
    post_args character varying(1023),
    last_updated_at timestamp without time zone,
    refresh_after_at timestamp without time zone,
    title character varying(127),
    description character varying(511),
    options text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sources_id_seq OWNED BY sources.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    item_id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    user_id integer,
    tag character varying(255) NOT NULL,
    title character varying(255),
    is_meta boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token character varying(127) NOT NULL,
    expires_at timestamp without time zone,
    last_used_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_tokens_id_seq OWNED BY user_tokens.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255),
    password_hash character varying(128),
    name character varying(255),
    is_verified_realname boolean DEFAULT false NOT NULL,
    email_confirmed boolean DEFAULT false NOT NULL,
    confirmation_token character varying(128),
    remember_token character varying(128),
    filename character varying(63),
    timezone character varying(31),
    location character varying(255),
    about text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    user_id integer NOT NULL,
    edited_at timestamp without time zone NOT NULL,
    edit_comment character varying(255),
    filename character varying(255),
    title character varying(255),
    "values" hstore
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorities ALTER COLUMN id SET DEFAULT nextval('authorities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ballots ALTER COLUMN id SET DEFAULT nextval('ballots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY candidates ALTER COLUMN id SET DEFAULT nextval('candidates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datastores ALTER COLUMN id SET DEFAULT nextval('datastores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY elections ALTER COLUMN id SET DEFAULT nextval('elections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY external_links ALTER COLUMN id SET DEFAULT nextval('external_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY image_variants ALTER COLUMN id SET DEFAULT nextval('image_variants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY images ALTER COLUMN id SET DEFAULT nextval('images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY levels ALTER COLUMN id SET DEFAULT nextval('levels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY office_holders ALTER COLUMN id SET DEFAULT nextval('office_holders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY offices ALTER COLUMN id SET DEFAULT nextval('offices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parties ALTER COLUMN id SET DEFAULT nextval('parties_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY paths ALTER COLUMN id SET DEFAULT nextval('paths_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sourced_items ALTER COLUMN id SET DEFAULT nextval('sourced_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sources ALTER COLUMN id SET DEFAULT nextval('sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_tokens ALTER COLUMN id SET DEFAULT nextval('user_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: authorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authorities
    ADD CONSTRAINT authorities_pkey PRIMARY KEY (id);


--
-- Name: ballots_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ballots
    ADD CONSTRAINT ballots_pkey PRIMARY KEY (id);


--
-- Name: candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY candidates
    ADD CONSTRAINT candidates_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: datastores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY datastores
    ADD CONSTRAINT datastores_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: elections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY elections
    ADD CONSTRAINT elections_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: external_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY external_links
    ADD CONSTRAINT external_links_pkey PRIMARY KEY (id);


--
-- Name: image_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY image_variants
    ADD CONSTRAINT image_variants_pkey PRIMARY KEY (id);


--
-- Name: images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (id);


--
-- Name: office_holders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY office_holders
    ADD CONSTRAINT office_holders_pkey PRIMARY KEY (id);


--
-- Name: offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: parties_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY parties
    ADD CONSTRAINT parties_pkey PRIMARY KEY (id);


--
-- Name: paths_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY paths
    ADD CONSTRAINT paths_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: sourced_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sourced_items
    ADD CONSTRAINT sourced_items_pkey PRIMARY KEY (id);


--
-- Name: sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: user_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_tokens
    ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: area; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX area ON authorities USING btree (area, user_id);


--
-- Name: auth; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX auth ON authentications USING btree (provider, uid);


--
-- Name: authorizer; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX authorizer ON authorities USING btree (authorized_by_id, user_id, area);


--
-- Name: container; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX container ON sources USING btree (container_item_type, container_item_id);


--
-- Name: creator; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX creator ON projects USING btree (creator_id);


--
-- Name: data; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX data ON documents USING btree (datastore_id);


--
-- Name: dates; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX dates ON events USING btree (start_at, end_at, is_allday, is_approved, is_draft, is_cancelled);


--
-- Name: edits_by_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX edits_by_date ON versions USING btree (edited_at, item_type, item_id);


--
-- Name: email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX email ON users USING btree (email);


--
-- Name: file; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX file ON documents USING btree (filename);


--
-- Name: filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX filename ON users USING btree (filename);


--
-- Name: index_ballots_on_election_id_and_office_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_ballots_on_election_id_and_office_id ON ballots USING btree (election_id, office_id);


--
-- Name: index_ballots_on_office_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ballots_on_office_id ON ballots USING btree (office_id);


--
-- Name: index_candidates_on_ballot_id_and_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_candidates_on_ballot_id_and_filename ON candidates USING btree (ballot_id, filename);


--
-- Name: index_candidates_on_ballot_id_and_is_confirmed_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_candidates_on_ballot_id_and_is_confirmed_and_name ON candidates USING btree (ballot_id, is_confirmed, name);


--
-- Name: index_candidates_on_ballot_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_candidates_on_ballot_id_and_name ON candidates USING btree (ballot_id, name);


--
-- Name: index_candidates_on_ballot_id_and_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_candidates_on_ballot_id_and_person_id ON candidates USING btree (ballot_id, person_id);


--
-- Name: index_candidates_on_ballot_id_and_vote_count_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_candidates_on_ballot_id_and_vote_count_and_name ON candidates USING btree (ballot_id, vote_count, name);


--
-- Name: index_candidates_on_submitter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_candidates_on_submitter_id ON candidates USING btree (submitter_id);


--
-- Name: index_contacts_on_confirmed_at_and_expires_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_confirmed_at_and_expires_at ON contacts USING btree (confirmed_at, expires_at);


--
-- Name: index_contacts_on_country_and_province_and_city; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_country_and_province_and_city ON contacts USING btree (country, province, city);


--
-- Name: index_contacts_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_email ON contacts USING btree (email);


--
-- Name: index_contacts_on_item_type_and_item_id_and_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_item_type_and_item_id_and_position ON contacts USING btree (item_type, item_id, "position");


--
-- Name: index_contacts_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_name ON contacts USING btree (name);


--
-- Name: index_elections_on_level_id_and_end_on; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_elections_on_level_id_and_end_on ON elections USING btree (level_id, end_on);


--
-- Name: index_elections_on_level_id_and_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_elections_on_level_id_and_filename ON elections USING btree (level_id, filename);


--
-- Name: index_events_on_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_title ON events USING btree (title);


--
-- Name: index_events_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_user_id ON events USING btree (user_id);


--
-- Name: index_external_links_on_item_type_and_item_id_and_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_external_links_on_item_type_and_item_id_and_position ON external_links USING btree (item_type, item_id, "position");


--
-- Name: index_image_variants_on_image_id_and_style_and_height_and_width; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_image_variants_on_image_id_and_style_and_height_and_width ON image_variants USING btree (image_id, style, height, width);


--
-- Name: index_office_holders_on_office_id_and_person_id_and_start_on; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_office_holders_on_office_id_and_person_id_and_start_on ON office_holders USING btree (office_id, person_id, start_on);


--
-- Name: index_office_holders_on_person_id_and_office_id_and_start_on; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_office_holders_on_person_id_and_office_id_and_start_on ON office_holders USING btree (person_id, office_id, start_on);


--
-- Name: index_office_holders_on_previous_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_office_holders_on_previous_id ON office_holders USING btree (previous_id);


--
-- Name: index_parties_on_level_id_and_abbrev; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_parties_on_level_id_and_abbrev ON parties USING btree (level_id, abbrev);


--
-- Name: index_parties_on_level_id_and_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_parties_on_level_id_and_filename ON parties USING btree (level_id, filename);


--
-- Name: index_parties_on_level_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_parties_on_level_id_and_name ON parties USING btree (level_id, name);


--
-- Name: index_people_on_aliases; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_aliases ON people USING btree (aliases);


--
-- Name: index_people_on_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_people_on_filename ON people USING btree (filename);


--
-- Name: index_people_on_fullname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_fullname ON people USING btree (fullname);


--
-- Name: index_people_on_submitter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_submitter_id ON people USING btree (submitter_id);


--
-- Name: index_people_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_people_on_user_id ON people USING btree (user_id);


--
-- Name: index_projects_on_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_filename ON projects USING btree (filename);


--
-- Name: index_projects_on_name_and_is_visible; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_name_and_is_visible ON projects USING btree (name, is_visible);


--
-- Name: index_sourced_items_on_datastore_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sourced_items_on_datastore_id ON sourced_items USING btree (datastore_id);


--
-- Name: index_sourced_items_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sourced_items_on_item_type_and_item_id ON sourced_items USING btree (item_type, item_id);


--
-- Name: index_sourced_items_on_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sourced_items_on_source_id ON sourced_items USING btree (source_id);


--
-- Name: index_sourced_items_on_source_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sourced_items_on_source_identifier ON sourced_items USING btree (source_identifier);


--
-- Name: index_sources_on_datastore_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sources_on_datastore_id ON sources USING btree (datastore_id);


--
-- Name: index_sources_on_last_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sources_on_last_updated_at ON sources USING btree (last_updated_at);


--
-- Name: index_sources_on_processor; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sources_on_processor ON sources USING btree (processor);


--
-- Name: index_sources_on_refresh_after_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sources_on_refresh_after_at ON sources USING btree (refresh_after_at);


--
-- Name: index_user_tokens_on_expires_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_tokens_on_expires_at ON user_tokens USING btree (expires_at);


--
-- Name: index_user_tokens_on_last_used_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_tokens_on_last_used_at ON user_tokens USING btree (last_used_at);


--
-- Name: index_user_tokens_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_tokens_on_token ON user_tokens USING btree (token);


--
-- Name: index_user_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_tokens_on_user_id ON user_tokens USING btree (user_id);


--
-- Name: item; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX item ON authorities USING btree (item_id, item_type, user_id);


--
-- Name: item_by_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX item_by_date ON versions USING btree (item_type, item_id, edited_at);


--
-- Name: item_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX item_idx ON paths USING btree (item_type, item_id);


--
-- Name: key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX key ON settings USING btree (key);


--
-- Name: levels_filename_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX levels_filename_idx ON levels USING btree (filename);


--
-- Name: levels_parent_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX levels_parent_idx ON levels USING btree (parent_id, filename);


--
-- Name: offices_filename_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX offices_filename_idx ON offices USING btree (level_id, filename);


--
-- Name: offices_level_position_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX offices_level_position_idx ON offices USING btree (level_id, "position");


--
-- Name: offices_previous_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX offices_previous_idx ON offices USING btree (previous_id);


--
-- Name: owner; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX owner ON projects USING btree (owner_id);


--
-- Name: parent; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX parent ON projects USING btree (parent_id);


--
-- Name: path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX path ON pages USING btree (parent_id, filename);


--
-- Name: pathname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX pathname ON documents USING btree (container_path_id, filename);


--
-- Name: remember_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX remember_token ON users USING btree (remember_token);


--
-- Name: site; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX site ON external_links USING btree (site);


--
-- Name: sitepath; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX sitepath ON paths USING btree (sitepath);


--
-- Name: tags_item_tag_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX tags_item_tag_idx ON tags USING btree (item_type, item_id, tag);


--
-- Name: tags_tag_item_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tags_tag_item_idx ON tags USING btree (tag, item_type, item_id);


--
-- Name: tags_user_item_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tags_user_item_idx ON tags USING btree (user_id, item_type, item_id);


--
-- Name: title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX title ON external_links USING btree (title);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: user; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "user" ON authentications USING btree (user_id, provider);


--
-- Name: user_by_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_by_date ON versions USING btree (user_id, edited_at, item_type, item_id);


--
-- Name: user_by_item; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_by_item ON versions USING btree (user_id, item_type, item_id, edited_at);


--
-- Name: user_map; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX user_map ON authorities USING btree (user_id, item_id, item_type, area);


--
-- Name: userfile; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX userfile ON documents USING btree (user_id, filename);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');
