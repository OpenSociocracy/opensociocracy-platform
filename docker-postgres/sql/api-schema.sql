--
-- PostgreSQL database dump
--

-- Dumped from database version 14.7 (Debian 14.7-1.pgdg110+1)
-- Dumped by pg_dump version 14.8 (Ubuntu 14.8-0ubuntu0.22.04.1)

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
-- Name: org_roles; Type: TYPE; Schema: opensociocracy_api; Owner: -
--

CREATE TYPE opensociocracy_api.org_roles AS ENUM (
    'owner',
    'leader',
    'participant'
);


--
-- Name: account_by_role(uuid, uuid, opensociocracy_api.account_roles); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.account_by_role(member_uid_in uuid, account_uid_in uuid, role_in opensociocracy_api.account_roles) RETURNS TABLE(id bigint, uid uuid)
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	RETURN QUERY (SELECT a.id, a.uid
		FROM opensociocracy_api.account a
		INNER JOIN opensociocracy_api.account_member am ON am.account_id = a.id
		INNER JOIN opensociocracy_api.member m ON m.id = am.member_id
		WHERE m.uid =  member_uid_in
		AND a.uid = account_uid_in
		AND role_in = ANY(am.roles));	
END; 
$$;


--
-- Name: create_account(uuid, character varying); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.create_account(owner_uid uuid, name_in character varying) RETURNS TABLE(id bigint, uid uuid, created_at timestamp without time zone)
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
-- Name: create_logbook_entry(uuid, uuid, uuid, text); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.create_logbook_entry(member_uid_in uuid, logbook_uid_in uuid, nugget_uid_in uuid, note_in text) RETURNS TABLE("logbookEntryId" bigint, "logbookEntryUid" uuid, "createdAt" timestamp without time zone)
    LANGUAGE plpgsql
    AS $$

DECLARE new_record_id BIGINT;
DECLARE new_record_uid uuid;
DECLARE new_record_created_at timestamp without time zone;

BEGIN
    
	INSERT INTO opensociocracy_api.logbook_entry(logbook_id, nugget_id, note)
		 VALUES(
			(SELECT id FROM logbook_by_member(member_uid_in, logbook_uid_in)),
		    (SELECT id FROM nugget WHERE uid = nugget_uid_in),
		     note_in)
		 RETURNING opensociocracy_api.logbook_entry.id, opensociocracy_api.logbook_entry.uid, opensociocracy_api.logbook_entry.created_at INTO new_record_id, new_record_uid, new_record_created_at;
		
	 
	RETURN QUERY SELECT new_record_id, new_record_uid, new_record_created_at;
	
	
END; 
$$;


--
-- Name: create_logbook_entry_nugget(uuid, uuid, timestamp with time zone, timestamp with time zone, character varying, character varying, jsonb, opensociocracy_api.nugget_types, text); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.create_logbook_entry_nugget(member_uid_in uuid, logbook_uid_in uuid, pub_at_in timestamp with time zone, un_pub_at_in timestamp with time zone, public_title_in character varying, internal_name_in character varying, blocks_in jsonb, nugget_type_in opensociocracy_api.nugget_types, note_in text) RETURNS TABLE("nuggetId" bigint, "nuggetUid" uuid, "logbookEntryId" bigint, "logbookEntryUid" uuid, "createdAt" timestamp without time zone)
    LANGUAGE plpgsql
    AS $$

DECLARE new_nugget_id BIGINT;
DECLARE new_nugget_uid uuid;
DECLARE new_logbook_entry_id BIGINT;
DECLARE new_logbook_entry_uid uuid;
DECLARE new_logbook_entry_created_at timestamp without time zone;
DECLARE valid_org_id bigint;
DECLARE valid_account_id bigint;
DECLARE valid_logbook_id bigint;

BEGIN
	-- Get account and org id, ensuring they are connected to the member
	SELECT account_id, org_id, logbook_id FROM valid_logbook_account_org(member_uid_in, logbook_uid_in) INTO valid_account_id, valid_org_id, valid_logbook_id;
    
	-- Create the nugget
	INSERT INTO opensociocracy_api.nugget(
		pub_at, 
		  un_pub_at, 
		  public_title, 
		  internal_name, 
		  blocks,
		  nugget_type, 
		  org_id, 
		  account_id)
		 VALUES(
			 pub_at_in, 
			 un_pub_at_in, 
			 public_title_in, 
			 internal_name_in, 
			 blocks_in,
			 nugget_type_in, 
			 valid_org_id,
			 valid_account_id
			)
		-- Store nugget creation results
		RETURNING opensociocracy_api.nugget.id, opensociocracy_api.nugget.uid, opensociocracy_api.nugget.created_at 
		INTO new_nugget_id, new_nugget_uid;
	
	-- Create a new logbook entry, referencing the nugget
	INSERT INTO opensociocracy_api.logbook_entry(logbook_id, nugget_id, note)
		 VALUES(
			valid_logbook_id,
		    new_nugget_id,
		     note_in)
		 RETURNING opensociocracy_api.logbook_entry.id, opensociocracy_api.logbook_entry.uid, opensociocracy_api.logbook_entry.created_at INTO new_logbook_entry_id, new_logbook_entry_uid, new_logbook_entry_created_at;

	-- Return ID and UID of nugget and logbookRecord
	RETURN QUERY SELECT new_nugget_id, new_nugget_uid, new_logbook_entry_id, new_logbook_entry_uid, new_logbook_entry_created_at;
	
	
END; 
$$;


--
-- Name: create_logbook_nugget(uuid, uuid, timestamp with time zone, timestamp with time zone, character varying, character varying, jsonb, opensociocracy_api.nugget_types); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.create_logbook_nugget(member_uid_in uuid, logbook_uid_in uuid, pub_at_in timestamp with time zone, un_pub_at_in timestamp with time zone, public_title_in character varying, internal_name_in character varying, blocks_in jsonb, nugget_type_in opensociocracy_api.nugget_types) RETURNS TABLE(id bigint, uid uuid, "createdAt" timestamp without time zone)
    LANGUAGE plpgsql
    AS $$

DECLARE new_record_id BIGINT;
DECLARE new_record_uid uuid;
DECLARE new_record_created_at timestamp without time zone;
DECLARE valid_org_id bigint;
DECLARE valid_account_id bigint;

BEGIN

	SELECT account_id, org_id FROM valid_logbook_account_org(member_uid_in, logbook_uid_in) INTO valid_account_id, valid_org_id;
    
	INSERT INTO opensociocracy_api.nugget(pub_at, 
										  un_pub_at, 
										  public_title, 
										  internal_name, 
										  blocks,
										  nugget_type, 
										  org_id, 
										  account_id)
		 VALUES(
			 pub_at_in, 
			  un_pub_at_in, 
			  public_title_in, 
			  internal_name_in, 
			  blocks_in,
			  nugget_type_in, 
			 valid_org_id,
			 valid_account_id
			)
		 RETURNING opensociocracy_api.nugget.id, opensociocracy_api.nugget.uid, opensociocracy_api.nugget.created_at INTO new_record_id, new_record_uid, new_record_created_at;
		
	 
	RETURN QUERY SELECT new_record_id, new_record_uid, new_record_created_at;
	
	
END; 
$$;


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
-- Name: create_org(uuid, uuid, character varying, text); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.create_org(member_uid_in uuid, account_uid_in uuid, name_in character varying, note_in text) RETURNS TABLE("orgId" bigint, "orgUid" uuid, "createdAt" timestamp without time zone, name character varying, "logbookId" bigint, "logbookUid" uuid)
    LANGUAGE plpgsql
    AS $$

DECLARE new_org_id bigint;
DECLARE new_org_uid uuid;
DECLARE new_org_created_at timestamp without time zone;
DECLARE new_logbook_id bigint;
DECLARE new_logbook_uid uuid;

BEGIN
    
	INSERT INTO opensociocracy_api.org(name, note, account_id )
		 VALUES(name_in, note_in, (SELECT id from opensociocracy_api.account_by_role(
			member_uid_in, 
			account_uid_in, 
			'owner'
		)))
		 RETURNING opensociocracy_api.org.id, opensociocracy_api.org.uid, opensociocracy_api.org.created_at INTO new_org_id, new_org_uid, new_org_created_at;
		 
    INSERT INTO opensociocracy_api.org_member(member_id, org_id, role)
		 VALUES((SELECT id FROM opensociocracy_api.member m WHERE m.uid = member_uid_in), new_org_id, 'owner');
		
	INSERT INTO opensociocracy_api.logbook(name, org_id)
		 VALUES(CONCAT('Logbook for ', name_in), new_org_id)
		 RETURNING opensociocracy_api.logbook.id, opensociocracy_api.logbook.uid INTO new_logbook_id, new_logbook_uid;
		 
	INSERT INTO opensociocracy_api.logbook_entry(note, logbook_id)
		 VALUES(CONCAT('Created logbook entry in ', new_logbook_uid), new_logbook_id);
		 
	RETURN QUERY SELECT new_org_id, new_org_uid, new_org_created_at, name_in, new_logbook_id, new_logbook_uid;
	
	
END; 
$$;


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
-- Name: get_account_orgs(uuid, uuid); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.get_account_orgs(member_uid_in uuid, account_uid_in uuid) RETURNS TABLE("orgUid" uuid, "createdAt" timestamp without time zone, name character varying, note text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	RETURN QUERY (SELECT o.uid, o.created_at, o.name, o.note
	FROM opensociocracy_api.org o 
	INNER JOIN opensociocracy_api.account a ON a.id = o.account_id
	INNER JOIN opensociocracy_api.account_member am ON am.account_id = a.id
	INNER JOIN opensociocracy_api.member m ON m.id = am.member_id
	WHERE m.uid = member_uid_in
 	AND a.uid =account_uid_in );

	
END; 
$$;


--
-- Name: get_logbook_entries(uuid, uuid); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.get_logbook_entries(member_uid_in uuid, logbook_uid_in uuid) RETURNS TABLE("logbookEntryUid" uuid, "createdAt" timestamp without time zone, note text, "nuggetUid" uuid)
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	RETURN QUERY (SELECT le.uid, le.created_at, le.note, n.uid
	FROM opensociocracy_api.logbook_entry le
	LEFT JOIN nugget n ON n.id = le.nugget_id
    INNER JOIN opensociocracy_api.logbook l ON l.id = le.logbook_id
	INNER JOIN opensociocracy_api.org o ON o.id = l.org_id
	INNER JOIN opensociocracy_api.account a ON a.id = o.account_id
	INNER JOIN opensociocracy_api.account_member am ON am.account_id = a.id
	INNER JOIN opensociocracy_api.member m ON m.id = am.member_id
	WHERE m.uid = member_uid_in
 	AND l.uid = logbook_uid_in );

	
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
-- Name: get_org_logbooks(uuid, uuid); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.get_org_logbooks(member_uid_in uuid, org_uid_in uuid) RETURNS TABLE("logbookUid" uuid, "createdAt" timestamp without time zone, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	RETURN QUERY (SELECT l.uid, l.created_at, l.name
	FROM opensociocracy_api.logbook l
	INNER JOIN opensociocracy_api.org o ON o.id = l.org_id
	INNER JOIN opensociocracy_api.account a ON a.id = o.account_id
	INNER JOIN opensociocracy_api.account_member am ON am.account_id = a.id
	INNER JOIN opensociocracy_api.member m ON m.id = am.member_id
	WHERE m.uid = member_uid_in
 	AND o.uid = org_uid_in );

	
END; 
$$;


--
-- Name: logbook_by_member(uuid, uuid); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.logbook_by_member(member_uid_in uuid, logbook_uid_in uuid) RETURNS TABLE(id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	RETURN QUERY (SELECT l.id
					FROM logbook l
					JOIN org o ON o.id = l.org_id
					JOIN org_member om ON om.org_id = o.id
					JOIN account a ON a.id = o.account_id
					JOIN account_member am ON am.account_id = a.id
					JOIN member m ON m.id = am.member_id
					WHERE l.uid = logbook_uid_in
					AND m.uid = member_uid_in
					AND (om.role = ANY('{"owner","leader"}') OR  'owner' = ANY(am.roles)));	
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
-- Name: valid_logbook_account_org(uuid, uuid); Type: FUNCTION; Schema: opensociocracy_api; Owner: -
--

CREATE FUNCTION opensociocracy_api.valid_logbook_account_org(member_uid_in uuid, logbook_uid_in uuid) RETURNS TABLE(account_id bigint, org_id bigint, logbook_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	RETURN QUERY (SELECT a.id AS account_id, o.id AS org_id, l.id AS logbook_id
		FROM opensociocracy_api.account a
		INNER JOIN opensociocracy_api.account_member am ON am.account_id = a.id
		INNER JOIN opensociocracy_api.member m ON m.id = am.member_id
	    INNER JOIN opensociocracy_api.org o ON o.account_id = a.id
	    INNER JOIN opensociocracy_api.org_member om ON om.org_id = o.id AND om.member_id = m.id
	    INNER JOIN opensociocracy_api.logbook l ON l.org_id = o.id
		WHERE m.uid =  member_uid_in
		AND l.uid = logbook_uid_in
		AND (om.role = ANY('{"owner","leader"}') OR  'owner' = ANY(am.roles)));	
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
    nugget_id bigint
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
    uid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    full_name character varying(64),
    platform_username character varying(32),
    public_profile boolean DEFAULT false NOT NULL
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
    org_id bigint,
    account_id bigint NOT NULL
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
    account_id bigint NOT NULL,
    name character varying(64),
    note text
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
-- Name: org_member; Type: TABLE; Schema: opensociocracy_api; Owner: -
--

CREATE TABLE opensociocracy_api.org_member (
    org_id bigint NOT NULL,
    member_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    role opensociocracy_api.org_roles DEFAULT 'participant'::opensociocracy_api.org_roles NOT NULL
);


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
-- Name: response id; Type: DEFAULT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.response ALTER COLUMN id SET DEFAULT nextval('opensociocracy_api.response_id_seq'::regclass);


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
-- Name: org_member org_member_pkey; Type: CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_member
    ADD CONSTRAINT org_member_pkey PRIMARY KEY (org_id, member_id);


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
-- Name: org_member fk_org_member_member_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_member
    ADD CONSTRAINT fk_org_member_member_id FOREIGN KEY (member_id) REFERENCES opensociocracy_api.member(id);


--
-- Name: org_member fk_org_member_org_id; Type: FK CONSTRAINT; Schema: opensociocracy_api; Owner: -
--

ALTER TABLE ONLY opensociocracy_api.org_member
    ADD CONSTRAINT fk_org_member_org_id FOREIGN KEY (org_id) REFERENCES opensociocracy_api.org(id);


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

