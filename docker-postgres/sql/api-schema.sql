--
-- PostgreSQL database dump
--

-- Dumped from database version 14.7 (Debian 14.7-1.pgdg110+1)
-- Dumped by pg_dump version 14.7 (Ubuntu 14.7-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: opensociocracy_api; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA opensociocracy_api;


--
-- Name: account_roles; Type: TYPE; Schema: opensociocracy_api; Owner: -
--

CREATE TYPE opensociocracy_api.account_roles AS ENUM (
    'owner',
    'member-admin',
    'billing-admin',
    'viewer',
    'editor'
);


--
-- Name: circle_roles; Type: TYPE; Schema: opensociocracy_api; Owner: -
--

CREATE TYPE opensociocracy_api.circle_roles AS ENUM (
    'vetoer',
    'leader',
    'log-keeper',
    'voting-member',
    'contributing-member',
    'viewing-member'
);


--
-- Name: nugget_types; Type: TYPE; Schema: opensociocracy_api; Owner: -
--

CREATE TYPE opensociocracy_api.nugget_types AS ENUM (
    'org',
    'team',
    'circle',
    'role',
    'driver',
    'proposal',
    'decision',
    'agreement',
    'peer-review',
    'asset',
    'json',
    'bylaws',
    'policy',
    'procedure',
    'job-description',
    'charter',
    'agenda',
    'minutes',
    'budget',
    'ledger',
    'ledger-account',
    'topic',
    'outcome',
    'process',
    'objective',
    'key-result',
    'vote',
    'survey'
);


--
-- Name: create_account(character varying, uuid); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.create_account(name_in character varying, owner_uid uuid) RETURNS TABLE(id bigint, uid uuid, created_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$

DECLARE new_account_id BIGINT;
DECLARE new_account_uid uuid;
DECLARE new_account_created_at timestamp without time zone;

BEGIN
    
	INSERT INTO opensociocracy_api.account(name, personal)
		 VALUES(name_in, false)
		 RETURNING opensociocracy_api.account.id, opensociocracy_api.account.uid, opensociocracy_api.account.created_at INTO new_account_id, new_account_uid, new_account_created_at;
		
	INSERT INTO opensociocracy_api.account_member(account_id, member_id , roles)
		 VALUES(new_account_id, (SELECT m.id FROM opensociocracy_api.member m where m.uid = owner_uid),  '{"owner"}');

	RETURN QUERY SELECT new_account_id, new_account_uid, new_account_created_at;
	
	
END; 
$$;


--
-- Name: create_account_nugget(character varying, character varying, character varying, bigint, uuid); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.create_account_nugget(public_title character varying, internal_name character varying, nugget_type character varying, account_uid bigint, member_uid uuid, OUT id bigint, OUT uid uuid, OUT created_at timestamp without time zone, OUT account_id bigint) RETURNS record
    LANGUAGE plpgsql
    AS $_$
#variable_conflict use_column
BEGIN

	INSERT INTO opensociocracy_api.nugget(
				public_title, 
				internal_name,   
				account_id, 
				nugget_type_id,
				created_at
			)
			VALUES (
				$1, 
				$2, 
				opensociocracy_api.get_member_account($4),
				1,
				DEFAULT
				)
 	RETURNING id, uid, created_at, account_id INTO id, uid, created_at, account_id;

	

	
END; 
$_$;


--
-- Name: create_member_nugget(character varying, character varying, character varying, uuid, jsonb); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.create_member_nugget(public_title character varying, internal_name character varying, nugget_type character varying, member_uid uuid, blocks jsonb, OUT id bigint, OUT uid uuid, OUT created_at timestamp without time zone, OUT account_id bigint) RETURNS record
    LANGUAGE plpgsql
    AS $_$
#variable_conflict use_column
BEGIN

	INSERT INTO opensociocracy_api.nugget(
				public_title, 
				internal_name, 
				nugget_type,
				account_id,
				blocks
				)
			VALUES (
				$1, 
				$2, 
				$3,
				opensociocracy_api.get_member_account($4),
				$5
				)
 	RETURNING id, uid, created_at, account_id INTO id, uid, created_at, account_id;

	

	
END; 
$_$;


--
-- Name: get_account_nuggets_by_type(uuid, uuid, text); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.get_account_nuggets_by_type(member_uid_in uuid, account_uid_in uuid, nugget_type_in text) RETURNS TABLE("nuggetUid" uuid, "createdAt" timestamp without time zone, "updatedAt" timestamp without time zone, "pubAt" timestamp without time zone, "unPubAt" timestamp without time zone, "publicTitle" character varying, "internalName" character varying, "nuggetType" character varying, blocks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY 
SELECT 
n.uid AS "nuggetUid",  
n.created_at AS "createdAt",  
n.updated_at AS "updatedAt",  
n.pub_at AS "pubAt", 
n.un_pub_at AS "unPubAt", 
n.public_title AS "publicTitle", 
n.internal_name AS "internalName", 
n.nugget_type AS "nuggetType",
n.blocks
FROM opensociocracy_api.member m 
INNER JOIN opensociocracy_api.account_member am ON am.member_id = m.id
INNER JOIN opensociocracy_api.account a ON a.id = am.account_id
INNER JOIN opensociocracy_api.nugget n ON n.account_id = am.account_id
WHERE m.uid = member_uid_in
AND a.uid = account_uid_in
AND n.nugget_type = nugget_type_in;
END;
$$;


--
-- Name: get_member_account(uuid); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.get_member_account(uid_in uuid) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	RETURN (SELECT a.id 
	FROM opensociocracy_api.account_member am 
	INNER JOIN opensociocracy_api.account a ON a.id = am.account_id
	INNER JOIN opensociocracy_api.member m ON m.id = am.member_id
	WHERE m.uid = uid_in
	 AND a.personal = true
	ORDER BY a.created_at LIMIT 1);

	
END; 
$$;


--
-- Name: get_member_accounts(uuid); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.get_member_accounts(uid_in uuid) RETURNS TABLE("accountUid" uuid, "createdAt" timestamp without time zone, name character varying, personal boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	RETURN QUERY (SELECT a.uid, a.created_at, a.name, a.personal  
	FROM opensociocracy_api.account_member am 
	INNER JOIN opensociocracy_api.account a ON a.id = am.account_id
	INNER JOIN opensociocracy_api.member m ON m.id = am.member_id
	WHERE m.uid = uid_in);

	
END; 
$$;


--
-- Name: get_member_nuggets_by_type(uuid, text); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.get_member_nuggets_by_type(member_uid_in uuid, nugget_type_in text) RETURNS TABLE("nuggetUid" uuid, "createdAt" timestamp without time zone, "updatedAt" timestamp without time zone, "pubAt" timestamp without time zone, "unPubAt" timestamp without time zone, "publicTitle" character varying, "internalName" character varying, "nuggetType" character varying, blocks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY 
SELECT 
n.uid AS "nuggetUid",  
n.created_at AS "createdAt",  
n.updated_at AS "updatedAt",  
n.pub_at AS "pubAt", 
n.un_pub_at AS "unPubAt", 
n.public_title AS "publicTitle", 
n.internal_name AS "internalName", 
n.nugget_type AS "nuggetType",
n.blocks
FROM opensociocracy_api.member m 
INNER JOIN opensociocracy_api.account_member am ON am.member_id = m.id
INNER JOIN opensociocracy_api.account a ON a.id = am.account_id
	AND a.personal = true
INNER JOIN opensociocracy_api.nugget n ON n.account_id = am.account_id
WHERE m.uid = member_uid_in
AND n.nugget_type = nugget_type_in;
END;
$$;


--
-- Name: get_nugget_type_id(character varying, bigint); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.get_nugget_type_id(type_name_in character varying, account_id_in bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
  	SELECT id FROM opensociocracy_api.nugget_type WHERE name = 'article' AND ( account_id = account_id_in OR account_id IS NULL )
	ORDER BY account_id
	LIMIT 1
  );
  
	
END; 
$$;


--
-- Name: new_member_from_user(); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.new_member_from_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE new_member_id BIGINT;
	DECLARE new_account_id BIGINT;	
BEGIN

	INSERT INTO opensociocracy_api.member(uid, created_at)
	 VALUES(uuid(NEW.user_id), to_timestamp(NEW.time_joined/1000) )
	 RETURNING id INTO new_member_id;
	
	INSERT INTO opensociocracy_api.account(name)
		 VALUES('Member Account for ' || new_member_id )
		 RETURNING id INTO new_account_id;
		
	INSERT INTO opensociocracy_api.account_member(account_id, member_id, roles)
		 VALUES(new_account_id, new_member_id, '{"owner"}');
		 
		 RETURN NEW;
END;
$$;


--
-- Name: register_member(text, text, numeric); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.register_member(uid_in text, email_in text, time_joined_in numeric) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    
	INSERT INTO opensociocracy_api.member(uid, email, created_at, last_sign_in)
	VALUES(uuid(uid_in), email_in,  to_timestamp(time_joined_in/1000), CURRENT_TIMESTAMP)
	ON CONFLICT (uid) DO UPDATE 
	SET last_sign_in = CURRENT_TIMESTAMP, email = EXCLUDED.email;
	
	RETURN 'OK';
	
END; 
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.account (
    id bigint NOT NULL,
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying(150),
    personal boolean DEFAULT true
);


--
-- Name: org_circle; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.org_circle (
    id bigint NOT NULL,
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    name character varying(64) NOT NULL,
    description text,
    org_id bigint NOT NULL
);


--
-- Name: account_circle_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.account_circle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_circle_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.account_circle_id_seq OWNED BY opensociocracy_api.org_circle.id;


--
-- Name: account_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.account_id_seq OWNED BY opensociocracy_api.account.id;


--
-- Name: account_member; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.account_member (
    account_id bigint NOT NULL,
    member_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    roles opensociocracy_api.account_roles[] DEFAULT '{viewer}'::opensociocracy_api.account_roles[] NOT NULL
);


--
-- Name: comment; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.comment (
    id bigint NOT NULL,
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    "created_at " timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    org_id bigint NOT NULL,
    nugget_id bigint NOT NULL
);


--
-- Name: logbook; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.logbook (
    id bigint NOT NULL,
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying(64) NOT NULL,
    org_id bigint NOT NULL
);


--
-- Name: logbook_entry; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.logbook_entry (
    id bigint NOT NULL,
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    logbook_id bigint,
    note text,
    nugget_id bigint NOT NULL
);


--
-- Name: logbook_entry_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.logbook_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logbook_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.logbook_entry_id_seq OWNED BY opensociocracy_api.logbook_entry.id;


--
-- Name: logbook_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.logbook_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logbook_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.logbook_id_seq OWNED BY opensociocracy_api.logbook.id;


--
-- Name: member; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.member (
    id bigint NOT NULL,
    uid uuid,
    created_at timestamp without time zone
);


--
-- Name: member_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.member_id_seq OWNED BY opensociocracy_api.member.id;


--
-- Name: nugget; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.nugget (
    id bigint NOT NULL,
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    pub_at timestamp without time zone,
    un_pub_at timestamp without time zone,
    public_title character varying(150),
    internal_name character varying(75),
    blocks jsonb DEFAULT '{}'::jsonb,
    nugget_type opensociocracy_api.nugget_types DEFAULT 'json'::opensociocracy_api.nugget_types NOT NULL,
    org_id bigint NOT NULL
);


--
-- Name: nugget_comment_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.nugget_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nugget_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.nugget_comment_id_seq OWNED BY opensociocracy_api.comment.id;


--
-- Name: nugget_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.nugget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nugget_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.nugget_id_seq OWNED BY opensociocracy_api.nugget.id;


--
-- Name: org; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.org (
    id bigint NOT NULL,
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    account_id bigint NOT NULL
);


--
-- Name: org_account_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.org_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_account_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.org_account_id_seq OWNED BY opensociocracy_api.org.account_id;


--
-- Name: org_circle_member; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.org_circle_member (
    id bigint NOT NULL,
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    org_circle_id bigint NOT NULL,
    member_email character varying(256),
    member_name character varying(128),
    circle_role opensociocracy_api.circle_roles[] DEFAULT '{viewing-member}'::opensociocracy_api.circle_roles[] NOT NULL
);


--
-- Name: org_circle_member_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.org_circle_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_circle_member_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.org_circle_member_id_seq OWNED BY opensociocracy_api.org_circle_member.id;


--
-- Name: org_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.org_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.org_id_seq OWNED BY opensociocracy_api.org.id;


--
-- Name: reaction; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.reaction (
    nugget_id bigint NOT NULL,
    org_id bigint NOT NULL,
    member_id bigint NOT NULL
);


--
-- Name: response; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.response (
    id bigint NOT NULL,
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comment_id bigint,
    response_id bigint,
    org_id bigint NOT NULL,
    nugget_id bigint NOT NULL
);


--
-- Name: response_id_seq; Type: SEQUENCE; Schema: opensociocracy_api; Owner: -
--

CREATE SEQUENCE opensociocracy_api.response_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_id_seq; Type: SEQUENCE OWNED BY; Schema: opensociocracy_api; Owner: -
--

ALTER SEQUENCE opensociocracy_api.response_id_seq OWNED BY opensociocracy_api.response.id;


--
-- Name: account id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.account ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.account_id_seq'::regclass);


--
-- Name: comment id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.comment ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.nugget_comment_id_seq'::regclass);


--
-- Name: logbook id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.logbook_id_seq'::regclass);


--
-- Name: logbook_entry id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook_entry ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.logbook_entry_id_seq'::regclass);


--
-- Name: member id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.member ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.member_id_seq'::regclass);


--
-- Name: nugget id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.nugget ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.nugget_id_seq'::regclass);


--
-- Name: org id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.org_id_seq'::regclass);


--
-- Name: org account_id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org ALTER COLUMN account_id SET DEFAULT nextval('opensociocracy_api.org_account_id_seq'::regclass);


--
-- Name: org_circle id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.account_circle_id_seq'::regclass);


--
-- Name: org_circle_member id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle_member ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.org_circle_member_id_seq'::regclass);


--
-- Name: response id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.response ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.response_id_seq'::regclass);


--
-- Name: org_circle account_circle_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle
    ADD CONSTRAINT account_circle_pkey PRIMARY KEY (id);


--
-- Name: account_member account_member_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.account_member
    ADD CONSTRAINT account_member_pkey PRIMARY KEY (account_id, member_id);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: logbook_entry logbook_entry_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook_entry
    ADD CONSTRAINT logbook_entry_pkey PRIMARY KEY (id);


--
-- Name: logbook logbook_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook
    ADD CONSTRAINT logbook_pkey PRIMARY KEY (id);


--
-- Name: member member_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- Name: comment nugget_comment_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.comment
    ADD CONSTRAINT nugget_comment_pkey PRIMARY KEY (id);


--
-- Name: nugget nugget_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.nugget
    ADD CONSTRAINT nugget_pkey PRIMARY KEY (id);


--
-- Name: reaction nugget_reaction_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.reaction
    ADD CONSTRAINT nugget_reaction_pkey PRIMARY KEY (nugget_id, org_id, member_id);


--
-- Name: org_circle_member org_circle_member_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle_member
    ADD CONSTRAINT org_circle_member_pkey PRIMARY KEY (id);


--
-- Name: org org_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org
    ADD CONSTRAINT org_pkey PRIMARY KEY (id);


--
-- Name: response response_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.response
    ADD CONSTRAINT response_pkey PRIMARY KEY (id);


--
-- Name: comment uq_comment_uid; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.comment
    ADD CONSTRAINT uq_comment_uid UNIQUE (uid);


--
-- Name: logbook_entry uq_logbook_entry_uid; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook_entry
    ADD CONSTRAINT uq_logbook_entry_uid UNIQUE (uid);


--
-- Name: logbook uq_logbook_org_name; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook
    ADD CONSTRAINT uq_logbook_org_name UNIQUE (name, org_id);


--
-- Name: logbook uq_logbook_uid; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook
    ADD CONSTRAINT uq_logbook_uid UNIQUE (uid);


--
-- Name: member uq_member_uid; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.member
    ADD CONSTRAINT uq_member_uid UNIQUE (uid);


--
-- Name: nugget uq_nugget_uid; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.nugget
    ADD CONSTRAINT uq_nugget_uid UNIQUE (uid);


--
-- Name: org_circle_member uq_org_circle_member_circle_member_email; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle_member
    ADD CONSTRAINT uq_org_circle_member_circle_member_email UNIQUE (member_email, org_circle_id);


--
-- Name: org_circle_member uq_org_circle_member_uid; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle_member
    ADD CONSTRAINT uq_org_circle_member_uid UNIQUE (uid);


--
-- Name: org_circle uq_org_circle_org_name; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle
    ADD CONSTRAINT uq_org_circle_org_name UNIQUE (org_id, name);


--
-- Name: org_circle uq_org_circle_uid; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle
    ADD CONSTRAINT uq_org_circle_uid UNIQUE (uid);


--
-- Name: org uq_org_uid; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org
    ADD CONSTRAINT uq_org_uid UNIQUE (uid);


--
-- Name: response uq_response_uid; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.response
    ADD CONSTRAINT uq_response_uid UNIQUE (uid);


--
-- Name: account_member fk_account_member_account_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.account_member
    ADD CONSTRAINT fk_account_member_account_id FOREIGN KEY (account_id) REFERENCES opensociocracy_api.account(id) NOT VALID;


--
-- Name: account_member fk_account_member_member_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.account_member
    ADD CONSTRAINT fk_account_member_member_id FOREIGN KEY (member_id) REFERENCES opensociocracy_api.member(id) NOT VALID;


--
-- Name: comment fk_comment_nugget_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.comment
    ADD CONSTRAINT fk_comment_nugget_id FOREIGN KEY (nugget_id) REFERENCES opensociocracy_api.nugget(id) NOT VALID;


--
-- Name: comment fk_comment_org_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.comment
    ADD CONSTRAINT fk_comment_org_id FOREIGN KEY (org_id) REFERENCES opensociocracy_api.org(id) NOT VALID;


--
-- Name: logbook_entry fk_logbook_entry_logbook_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook_entry
    ADD CONSTRAINT fk_logbook_entry_logbook_id FOREIGN KEY (logbook_id) REFERENCES opensociocracy_api.logbook(id) NOT VALID;


--
-- Name: logbook_entry fk_logbook_entry_nugget_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook_entry
    ADD CONSTRAINT fk_logbook_entry_nugget_id FOREIGN KEY (nugget_id) REFERENCES opensociocracy_api.nugget(id) NOT VALID;


--
-- Name: logbook fk_logbook_org_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.logbook
    ADD CONSTRAINT fk_logbook_org_id FOREIGN KEY (org_id) REFERENCES opensociocracy_api.org(id) NOT VALID;


--
-- Name: nugget fk_nugget_org_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.nugget
    ADD CONSTRAINT fk_nugget_org_id FOREIGN KEY (org_id) REFERENCES opensociocracy_api.org(id) NOT VALID;


--
-- Name: org fk_org_account_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org
    ADD CONSTRAINT fk_org_account_id FOREIGN KEY (account_id) REFERENCES opensociocracy_api.account(id) NOT VALID;


--
-- Name: org_circle_member fk_org_circle_member_org_circle_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle_member
    ADD CONSTRAINT fk_org_circle_member_org_circle_id FOREIGN KEY (org_circle_id) REFERENCES opensociocracy_api.org_circle(id) NOT VALID;


--
-- Name: org_circle fk_org_circle_org_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_circle
    ADD CONSTRAINT fk_org_circle_org_id FOREIGN KEY (org_id) REFERENCES opensociocracy_api.org(id) NOT VALID;


--
-- Name: reaction fk_reaction_member_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.reaction
    ADD CONSTRAINT fk_reaction_member_id FOREIGN KEY (member_id) REFERENCES opensociocracy_api.member(id) NOT VALID;


--
-- Name: reaction fk_reaction_nugget_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.reaction
    ADD CONSTRAINT fk_reaction_nugget_id FOREIGN KEY (nugget_id) REFERENCES opensociocracy_api.nugget(id) NOT VALID;


--
-- Name: reaction fk_reaction_org_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.reaction
    ADD CONSTRAINT fk_reaction_org_id FOREIGN KEY (org_id) REFERENCES opensociocracy_api.org(id) NOT VALID;


--
-- Name: response fk_response_comment_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.response
    ADD CONSTRAINT fk_response_comment_id FOREIGN KEY (comment_id) REFERENCES opensociocracy_api.comment(id) NOT VALID;


--
-- Name: response fk_response_nugget_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.response
    ADD CONSTRAINT fk_response_nugget_id FOREIGN KEY (nugget_id) REFERENCES opensociocracy_api.nugget(id) NOT VALID;


--
-- Name: response fk_response_org_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.response
    ADD CONSTRAINT fk_response_org_id FOREIGN KEY (org_id) REFERENCES opensociocracy_api.org(id) NOT VALID;


--
-- Name: response fk_response_response_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.response
    ADD CONSTRAINT fk_response_response_id FOREIGN KEY (response_id) REFERENCES opensociocracy_api.response(id) NOT VALID;


--
-- Name: SCHEMA opensociocracy_api; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA opensociocracy_api TO opensociocracy_supertokens;


--
-- Name: TABLE account; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.account TO opensociocracy_supertokens;


--
-- Name: TABLE org_circle; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.org_circle TO opensociocracy_supertokens;


--
-- Name: SEQUENCE account_circle_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.account_circle_id_seq TO opensociocracy_supertokens;


--
-- Name: SEQUENCE account_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.account_id_seq TO opensociocracy_supertokens;


--
-- Name: TABLE account_member; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.account_member TO opensociocracy_supertokens;


--
-- Name: TABLE comment; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.comment TO opensociocracy_supertokens;


--
-- Name: TABLE logbook; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.logbook TO opensociocracy_supertokens;


--
-- Name: TABLE logbook_entry; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.logbook_entry TO opensociocracy_supertokens;


--
-- Name: SEQUENCE logbook_entry_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.logbook_entry_id_seq TO opensociocracy_supertokens;


--
-- Name: SEQUENCE logbook_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.logbook_id_seq TO opensociocracy_supertokens;


--
-- Name: TABLE member; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.member TO opensociocracy_supertokens;


--
-- Name: SEQUENCE member_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.member_id_seq TO opensociocracy_supertokens;


--
-- Name: TABLE nugget; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.nugget TO opensociocracy_supertokens;


--
-- Name: SEQUENCE nugget_comment_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.nugget_comment_id_seq TO opensociocracy_supertokens;


--
-- Name: SEQUENCE nugget_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.nugget_id_seq TO opensociocracy_supertokens;


--
-- Name: TABLE org; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.org TO opensociocracy_supertokens;


--
-- Name: SEQUENCE org_account_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.org_account_id_seq TO opensociocracy_supertokens;


--
-- Name: TABLE org_circle_member; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.org_circle_member TO opensociocracy_supertokens;


--
-- Name: SEQUENCE org_circle_member_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.org_circle_member_id_seq TO opensociocracy_supertokens;


--
-- Name: SEQUENCE org_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.org_id_seq TO opensociocracy_supertokens;


--
-- Name: TABLE reaction; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.reaction TO opensociocracy_supertokens;


--
-- Name: TABLE response; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON TABLE opensociocracy_api.response TO opensociocracy_supertokens;


--
-- Name: SEQUENCE response_id_seq; Type: ACL; Schema: opensociocracy_api; Owner: -
--

GRANT ALL ON SEQUENCE opensociocracy_api.response_id_seq TO opensociocracy_supertokens;


--
-- PostgreSQL database dump complete
--

