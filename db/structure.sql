SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authentications (
    id bigint NOT NULL,
    user_id bigint,
    provider character varying NOT NULL,
    uid character varying NOT NULL,
    nickname character varying,
    name character varying,
    email character varying,
    location character varying,
    url character varying,
    image_url character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: authorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authorities (
    id bigint NOT NULL,
    user_id bigint,
    authorized_by_id bigint,
    item_type character varying,
    item_id bigint,
    area character varying(31),
    is_owner boolean,
    can_create boolean,
    can_view boolean,
    can_update boolean,
    can_delete boolean,
    can_invite boolean,
    can_permit boolean,
    can_approve boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: ballots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ballots (
    id bigint NOT NULL,
    election_id bigint NOT NULL,
    office_id bigint NOT NULL,
    "position" integer DEFAULT 999 NOT NULL,
    section character varying,
    term_start_on date,
    term_end_on date,
    is_byelection boolean DEFAULT false NOT NULL,
    url character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: candidates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE candidates (
    id bigint NOT NULL,
    ballot_id bigint NOT NULL,
    person_id bigint NOT NULL,
    party_id bigint,
    submitter_id bigint,
    filename character varying NOT NULL,
    name character varying NOT NULL,
    is_rumoured boolean DEFAULT false NOT NULL,
    is_confirmed boolean DEFAULT false NOT NULL,
    is_incumbent boolean DEFAULT false NOT NULL,
    is_leader boolean DEFAULT false NOT NULL,
    is_acclaimed boolean DEFAULT false NOT NULL,
    is_elected boolean DEFAULT false NOT NULL,
    announced_on date,
    quit_on date,
    vote_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contacts (
    id bigint NOT NULL,
    item_type character varying,
    item_id bigint NOT NULL,
    "position" integer DEFAULT 999 NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    confirmed_at timestamp without time zone,
    expires_at timestamp without time zone,
    name character varying,
    organization character varying,
    email character varying,
    twitter character varying,
    url character varying,
    phone character varying,
    phone2 character varying,
    fax character varying,
    address1 character varying,
    address2 character varying,
    city character varying,
    province character varying,
    country character varying,
    postal character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: datastores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE datastores (
    id bigint NOT NULL,
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
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE documents (
    id bigint NOT NULL,
    datastore_id bigint,
    container_path_id bigint,
    user_id bigint,
    is_authority_controlled boolean DEFAULT false NOT NULL,
    filename character varying(127) NOT NULL,
    size integer NOT NULL,
    content_type character varying NOT NULL,
    charset character varying(31),
    description character varying(1023),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: elections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE elections (
    id bigint NOT NULL,
    level_id bigint,
    filename character varying(63) NOT NULL,
    name character varying NOT NULL,
    start_on date,
    end_on date,
    description text,
    url text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE events (
    id bigint NOT NULL,
    user_id bigint,
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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_id bigint
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
-- Name: external_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE external_links (
    id bigint NOT NULL,
    item_type character varying,
    item_id bigint NOT NULL,
    is_source boolean DEFAULT false NOT NULL,
    "position" integer,
    site character varying(31),
    title character varying(255) NOT NULL,
    url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: image_variants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE image_variants (
    id bigint NOT NULL,
    image_id bigint NOT NULL,
    height integer,
    width integer,
    format character varying(31) NOT NULL,
    style character varying(15) NOT NULL,
    url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE images (
    id bigint NOT NULL,
    title text,
    alt_text character varying(127),
    description text,
    attribution character varying(127),
    attribution_url text,
    license_url text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE levels (
    id bigint NOT NULL,
    parent_id bigint,
    filename character varying(63) NOT NULL,
    name character varying NOT NULL,
    url text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: office_holders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE office_holders (
    id bigint NOT NULL,
    office_id bigint NOT NULL,
    person_id bigint NOT NULL,
    previous_id bigint NOT NULL,
    start_on date,
    end_on date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE offices (
    id bigint NOT NULL,
    level_id bigint NOT NULL,
    previous_id bigint,
    filename character varying(63) NOT NULL,
    name character varying NOT NULL,
    title character varying,
    "position" integer DEFAULT 0 NOT NULL,
    established_on date,
    ended_on date,
    description text,
    url text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pages (
    id bigint NOT NULL,
    parent_id bigint,
    is_authority_controlled boolean DEFAULT false NOT NULL,
    filename character varying NOT NULL,
    title character varying NOT NULL,
    description text,
    content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: parties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE parties (
    id bigint NOT NULL,
    level_id bigint NOT NULL,
    filename character varying NOT NULL,
    name character varying NOT NULL,
    abbrev character varying NOT NULL,
    is_registered boolean DEFAULT false NOT NULL,
    colour character varying,
    url character varying,
    description text,
    established_on date,
    registered_on date,
    ended_on date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
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
-- Name: paths; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE paths (
    id bigint NOT NULL,
    item_type character varying,
    item_id bigint,
    sitepath text NOT NULL,
    redirect text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE people (
    id bigint NOT NULL,
    user_id bigint,
    submitter_id bigint,
    filename character varying NOT NULL,
    fullname character varying NOT NULL,
    aliases character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    bio text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE projects (
    id bigint NOT NULL,
    parent_id bigint,
    creator_id bigint NOT NULL,
    owner_id bigint NOT NULL,
    is_visible boolean DEFAULT false NOT NULL,
    is_public_content boolean DEFAULT false NOT NULL,
    is_visible_member_list boolean DEFAULT false NOT NULL,
    is_joinable boolean DEFAULT false NOT NULL,
    is_members_can_invite boolean DEFAULT false NOT NULL,
    is_not_unsubscribable boolean DEFAULT false NOT NULL,
    is_moderated boolean DEFAULT false NOT NULL,
    is_only_admin_posts boolean DEFAULT false NOT NULL,
    is_no_comments boolean DEFAULT false NOT NULL,
    filename character varying,
    name character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE settings (
    id bigint NOT NULL,
    key character varying,
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: sourced_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sourced_items (
    id bigint NOT NULL,
    source_id bigint NOT NULL,
    item_type character varying,
    item_id bigint,
    datastore_id bigint,
    source_identifier character varying,
    last_sourced_at timestamp without time zone NOT NULL,
    has_local_modifications boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_ignored boolean DEFAULT false NOT NULL
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
-- Name: sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sources (
    id bigint NOT NULL,
    container_item_type character varying,
    container_item_id bigint,
    datastore_id bigint,
    processor character varying(31) NOT NULL,
    url character varying(511) NOT NULL,
    method character varying(7) DEFAULT 'get'::character varying NOT NULL,
    post_args character varying(1023),
    last_updated_at timestamp without time zone,
    refresh_after_at timestamp without time zone,
    title character varying(127),
    description character varying(511),
    options text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tags (
    id bigint NOT NULL,
    item_type character varying,
    item_id bigint NOT NULL,
    user_id bigint,
    tag character varying NOT NULL,
    title character varying,
    is_meta boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token character varying(127) NOT NULL,
    expires_at timestamp without time zone,
    last_used_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id bigint NOT NULL,
    email character varying,
    password_hash character varying(128),
    name character varying,
    is_verified_realname boolean DEFAULT false NOT NULL,
    email_confirmed boolean DEFAULT false NOT NULL,
    confirmation_token character varying(128),
    remember_token character varying(128),
    filename character varying(63),
    timezone character varying(31),
    location character varying,
    about text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE versions (
    id bigint NOT NULL,
    item_type character varying,
    item_id bigint NOT NULL,
    user_id bigint NOT NULL,
    edited_at timestamp without time zone NOT NULL,
    edit_comment character varying,
    filename character varying,
    title character varying,
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
-- Name: authentications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: authorities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorities ALTER COLUMN id SET DEFAULT nextval('authorities_id_seq'::regclass);


--
-- Name: ballots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ballots ALTER COLUMN id SET DEFAULT nextval('ballots_id_seq'::regclass);


--
-- Name: candidates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY candidates ALTER COLUMN id SET DEFAULT nextval('candidates_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: datastores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datastores ALTER COLUMN id SET DEFAULT nextval('datastores_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: elections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY elections ALTER COLUMN id SET DEFAULT nextval('elections_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: external_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY external_links ALTER COLUMN id SET DEFAULT nextval('external_links_id_seq'::regclass);


--
-- Name: image_variants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY image_variants ALTER COLUMN id SET DEFAULT nextval('image_variants_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY images ALTER COLUMN id SET DEFAULT nextval('images_id_seq'::regclass);


--
-- Name: levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY levels ALTER COLUMN id SET DEFAULT nextval('levels_id_seq'::regclass);


--
-- Name: office_holders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY office_holders ALTER COLUMN id SET DEFAULT nextval('office_holders_id_seq'::regclass);


--
-- Name: offices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY offices ALTER COLUMN id SET DEFAULT nextval('offices_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: parties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parties ALTER COLUMN id SET DEFAULT nextval('parties_id_seq'::regclass);


--
-- Name: paths id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY paths ALTER COLUMN id SET DEFAULT nextval('paths_id_seq'::regclass);


--
-- Name: people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: sourced_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sourced_items ALTER COLUMN id SET DEFAULT nextval('sourced_items_id_seq'::regclass);


--
-- Name: sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sources ALTER COLUMN id SET DEFAULT nextval('sources_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: user_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_tokens ALTER COLUMN id SET DEFAULT nextval('user_tokens_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: authentications authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: authorities authorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorities
    ADD CONSTRAINT authorities_pkey PRIMARY KEY (id);


--
-- Name: ballots ballots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ballots
    ADD CONSTRAINT ballots_pkey PRIMARY KEY (id);


--
-- Name: candidates candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY candidates
    ADD CONSTRAINT candidates_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: datastores datastores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datastores
    ADD CONSTRAINT datastores_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: elections elections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY elections
    ADD CONSTRAINT elections_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: external_links external_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY external_links
    ADD CONSTRAINT external_links_pkey PRIMARY KEY (id);


--
-- Name: image_variants image_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY image_variants
    ADD CONSTRAINT image_variants_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (id);


--
-- Name: office_holders office_holders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY office_holders
    ADD CONSTRAINT office_holders_pkey PRIMARY KEY (id);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: parties parties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parties
    ADD CONSTRAINT parties_pkey PRIMARY KEY (id);


--
-- Name: paths paths_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY paths
    ADD CONSTRAINT paths_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: sourced_items sourced_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sourced_items
    ADD CONSTRAINT sourced_items_pkey PRIMARY KEY (id);


--
-- Name: sources sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: user_tokens user_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_tokens
    ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: area; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX area ON authorities USING btree (area, user_id);


--
-- Name: auth; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX auth ON authentications USING btree (provider, uid);


--
-- Name: authorizer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authorizer ON authorities USING btree (authorized_by_id, user_id, area);


--
-- Name: container; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX container ON sources USING btree (container_item_type, container_item_id);


--
-- Name: creator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX creator ON projects USING btree (creator_id);


--
-- Name: data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX data ON documents USING btree (datastore_id);


--
-- Name: dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dates ON events USING btree (start_at, end_at, is_allday, is_approved, is_draft, is_cancelled);


--
-- Name: edits_by_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX edits_by_date ON versions USING btree (edited_at, item_type, item_id);


--
-- Name: email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX email ON users USING btree (email);


--
-- Name: file; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file ON documents USING btree (filename);


--
-- Name: filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX filename ON users USING btree (filename);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_authorities_on_authorized_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorities_on_authorized_by_id ON authorities USING btree (authorized_by_id);


--
-- Name: index_authorities_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorities_on_item_type_and_item_id ON authorities USING btree (item_type, item_id);


--
-- Name: index_authorities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorities_on_user_id ON authorities USING btree (user_id);


--
-- Name: index_ballots_on_election_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ballots_on_election_id ON ballots USING btree (election_id);


--
-- Name: index_ballots_on_election_id_and_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ballots_on_election_id_and_office_id ON ballots USING btree (election_id, office_id);


--
-- Name: index_ballots_on_election_id_and_office_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ballots_on_election_id_and_office_id_and_position ON ballots USING btree (election_id, office_id, "position");


--
-- Name: index_ballots_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ballots_on_office_id ON ballots USING btree (office_id);


--
-- Name: index_candidates_on_ballot_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_candidates_on_ballot_id ON candidates USING btree (ballot_id);


--
-- Name: index_candidates_on_ballot_id_and_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_candidates_on_ballot_id_and_filename ON candidates USING btree (ballot_id, filename);


--
-- Name: index_candidates_on_ballot_id_and_is_confirmed_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_candidates_on_ballot_id_and_is_confirmed_and_name ON candidates USING btree (ballot_id, is_confirmed, name);


--
-- Name: index_candidates_on_ballot_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_candidates_on_ballot_id_and_name ON candidates USING btree (ballot_id, name);


--
-- Name: index_candidates_on_ballot_id_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_candidates_on_ballot_id_and_person_id ON candidates USING btree (ballot_id, person_id);


--
-- Name: index_candidates_on_ballot_id_and_vote_count_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_candidates_on_ballot_id_and_vote_count_and_name ON candidates USING btree (ballot_id, vote_count, name);


--
-- Name: index_candidates_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_candidates_on_party_id ON candidates USING btree (party_id);


--
-- Name: index_candidates_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_candidates_on_person_id ON candidates USING btree (person_id);


--
-- Name: index_candidates_on_submitter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_candidates_on_submitter_id ON candidates USING btree (submitter_id);


--
-- Name: index_contacts_on_confirmed_at_and_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_confirmed_at_and_expires_at ON contacts USING btree (confirmed_at, expires_at);


--
-- Name: index_contacts_on_country_and_province_and_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_country_and_province_and_city ON contacts USING btree (country, province, city);


--
-- Name: index_contacts_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_email ON contacts USING btree (email);


--
-- Name: index_contacts_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_item_type_and_item_id ON contacts USING btree (item_type, item_id);


--
-- Name: index_contacts_on_item_type_and_item_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_item_type_and_item_id_and_position ON contacts USING btree (item_type, item_id, "position");


--
-- Name: index_contacts_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_name ON contacts USING btree (name);


--
-- Name: index_documents_on_container_path_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_container_path_id ON documents USING btree (container_path_id);


--
-- Name: index_documents_on_datastore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_datastore_id ON documents USING btree (datastore_id);


--
-- Name: index_documents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_user_id ON documents USING btree (user_id);


--
-- Name: index_elections_on_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elections_on_level_id ON elections USING btree (level_id);


--
-- Name: index_elections_on_level_id_and_end_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elections_on_level_id_and_end_on ON elections USING btree (level_id, end_on);


--
-- Name: index_elections_on_level_id_and_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elections_on_level_id_and_filename ON elections USING btree (level_id, filename);


--
-- Name: index_events_on_image_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_image_id ON events USING btree (image_id);


--
-- Name: index_events_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_title ON events USING btree (title);


--
-- Name: index_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_user_id ON events USING btree (user_id);


--
-- Name: index_external_links_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_links_on_item_type_and_item_id ON external_links USING btree (item_type, item_id);


--
-- Name: index_external_links_on_item_type_and_item_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_links_on_item_type_and_item_id_and_position ON external_links USING btree (item_type, item_id, "position");


--
-- Name: index_image_variants_on_image_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_image_variants_on_image_id ON image_variants USING btree (image_id);


--
-- Name: index_image_variants_on_image_id_and_style_and_height_and_width; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_image_variants_on_image_id_and_style_and_height_and_width ON image_variants USING btree (image_id, style, height, width);


--
-- Name: index_levels_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_levels_on_parent_id ON levels USING btree (parent_id);


--
-- Name: index_office_holders_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_holders_on_office_id ON office_holders USING btree (office_id);


--
-- Name: index_office_holders_on_office_id_and_person_id_and_start_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_holders_on_office_id_and_person_id_and_start_on ON office_holders USING btree (office_id, person_id, start_on);


--
-- Name: index_office_holders_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_holders_on_person_id ON office_holders USING btree (person_id);


--
-- Name: index_office_holders_on_person_id_and_office_id_and_start_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_holders_on_person_id_and_office_id_and_start_on ON office_holders USING btree (person_id, office_id, start_on);


--
-- Name: index_office_holders_on_previous_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_holders_on_previous_id ON office_holders USING btree (previous_id);


--
-- Name: index_offices_on_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_level_id ON offices USING btree (level_id);


--
-- Name: index_offices_on_previous_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_previous_id ON offices USING btree (previous_id);


--
-- Name: index_pages_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_parent_id ON pages USING btree (parent_id);


--
-- Name: index_parties_on_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_on_level_id ON parties USING btree (level_id);


--
-- Name: index_parties_on_level_id_and_abbrev; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_parties_on_level_id_and_abbrev ON parties USING btree (level_id, abbrev);


--
-- Name: index_parties_on_level_id_and_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_parties_on_level_id_and_filename ON parties USING btree (level_id, filename);


--
-- Name: index_parties_on_level_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_parties_on_level_id_and_name ON parties USING btree (level_id, name);


--
-- Name: index_paths_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_paths_on_item_type_and_item_id ON paths USING btree (item_type, item_id);


--
-- Name: index_people_on_aliases; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_aliases ON people USING btree (aliases);


--
-- Name: index_people_on_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_people_on_filename ON people USING btree (filename);


--
-- Name: index_people_on_fullname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_fullname ON people USING btree (fullname);


--
-- Name: index_people_on_submitter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_submitter_id ON people USING btree (submitter_id);


--
-- Name: index_people_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_people_on_user_id ON people USING btree (user_id);


--
-- Name: index_projects_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_creator_id ON projects USING btree (creator_id);


--
-- Name: index_projects_on_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_filename ON projects USING btree (filename);


--
-- Name: index_projects_on_name_and_is_visible; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_name_and_is_visible ON projects USING btree (name, is_visible);


--
-- Name: index_projects_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_owner_id ON projects USING btree (owner_id);


--
-- Name: index_projects_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_parent_id ON projects USING btree (parent_id);


--
-- Name: index_sourced_items_on_datastore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sourced_items_on_datastore_id ON sourced_items USING btree (datastore_id);


--
-- Name: index_sourced_items_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sourced_items_on_item_type_and_item_id ON sourced_items USING btree (item_type, item_id);


--
-- Name: index_sourced_items_on_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sourced_items_on_source_id ON sourced_items USING btree (source_id);


--
-- Name: index_sourced_items_on_source_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sourced_items_on_source_identifier ON sourced_items USING btree (source_identifier);


--
-- Name: index_sources_on_container_item_type_and_container_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sources_on_container_item_type_and_container_item_id ON sources USING btree (container_item_type, container_item_id);


--
-- Name: index_sources_on_datastore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sources_on_datastore_id ON sources USING btree (datastore_id);


--
-- Name: index_sources_on_last_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sources_on_last_updated_at ON sources USING btree (last_updated_at);


--
-- Name: index_sources_on_processor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sources_on_processor ON sources USING btree (processor);


--
-- Name: index_sources_on_refresh_after_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sources_on_refresh_after_at ON sources USING btree (refresh_after_at);


--
-- Name: index_tags_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_item_type_and_item_id ON tags USING btree (item_type, item_id);


--
-- Name: index_tags_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_user_id ON tags USING btree (user_id);


--
-- Name: index_user_tokens_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tokens_on_expires_at ON user_tokens USING btree (expires_at);


--
-- Name: index_user_tokens_on_last_used_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tokens_on_last_used_at ON user_tokens USING btree (last_used_at);


--
-- Name: index_user_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tokens_on_token ON user_tokens USING btree (token);


--
-- Name: index_user_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tokens_on_user_id ON user_tokens USING btree (user_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: index_versions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_user_id ON versions USING btree (user_id);


--
-- Name: item; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX item ON authorities USING btree (item_id, item_type, user_id);


--
-- Name: item_by_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX item_by_date ON versions USING btree (item_type, item_id, edited_at);


--
-- Name: item_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX item_idx ON paths USING btree (item_type, item_id);


--
-- Name: key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX key ON settings USING btree (key);


--
-- Name: levels_filename_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX levels_filename_idx ON levels USING btree (filename);


--
-- Name: levels_parent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX levels_parent_idx ON levels USING btree (parent_id, filename);


--
-- Name: offices_filename_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX offices_filename_idx ON offices USING btree (level_id, filename);


--
-- Name: offices_level_position_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX offices_level_position_idx ON offices USING btree (level_id, "position");


--
-- Name: offices_previous_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX offices_previous_idx ON offices USING btree (previous_id);


--
-- Name: owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX owner ON projects USING btree (owner_id);


--
-- Name: parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX parent ON projects USING btree (parent_id);


--
-- Name: path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX path ON pages USING btree (parent_id, filename);


--
-- Name: pathname; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pathname ON documents USING btree (container_path_id, filename);


--
-- Name: remember_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX remember_token ON users USING btree (remember_token);


--
-- Name: site; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site ON external_links USING btree (site);


--
-- Name: sitepath; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sitepath ON paths USING btree (sitepath);


--
-- Name: tags_item_tag_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tags_item_tag_idx ON tags USING btree (item_type, item_id, tag);


--
-- Name: tags_tag_item_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tags_tag_item_idx ON tags USING btree (tag, item_type, item_id);


--
-- Name: tags_user_item_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tags_user_item_idx ON tags USING btree (user_id, item_type, item_id);


--
-- Name: title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX title ON external_links USING btree (title);


--
-- Name: user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "user" ON authentications USING btree (user_id, provider);


--
-- Name: user_by_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_by_date ON versions USING btree (user_id, edited_at, item_type, item_id);


--
-- Name: user_by_item; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_by_item ON versions USING btree (user_id, item_type, item_id, edited_at);


--
-- Name: user_map; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_map ON authorities USING btree (user_id, item_id, item_type, area);


--
-- Name: userfile; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX userfile ON documents USING btree (user_id, filename);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('1'),
('10'),
('11'),
('12'),
('13'),
('14'),
('15'),
('16'),
('17'),
('18'),
('19'),
('2'),
('20'),
('20150617230424'),
('21'),
('22'),
('23'),
('24'),
('25'),
('26'),
('27'),
('28'),
('29'),
('3'),
('30'),
('31'),
('4'),
('5'),
('6'),
('7'),
('8'),
('9');


