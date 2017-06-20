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
-- Name: datastores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datastores ALTER COLUMN id SET DEFAULT nextval('datastores_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


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
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: paths id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY paths ALTER COLUMN id SET DEFAULT nextval('paths_id_seq'::regclass);


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
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: paths paths_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY paths
    ADD CONSTRAINT paths_pkey PRIMARY KEY (id);


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
-- Name: index_pages_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_parent_id ON pages USING btree (parent_id);


--
-- Name: index_paths_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_paths_on_item_type_and_item_id ON paths USING btree (item_type, item_id);


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
('3'),
('4'),
('5'),
('6'),
('7'),
('8'),
('9');


