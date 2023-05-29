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
-- Name: reporting; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA reporting;


--
-- Name: v_org_members; Type: VIEW; Schema: reporting; Owner: -
--

CREATE VIEW reporting.v_org_members AS
 SELECT o.uid AS "orgUid",
    o.name AS "orgName",
    om.role,
    m.uid AS "memberUid",
    u.email,
    l.uid AS "logbookUid"
   FROM ((((opensociocracy_api.org o
     LEFT JOIN opensociocracy_api.org_member om ON ((om.org_id = o.id)))
     LEFT JOIN opensociocracy_api.member m ON ((m.id = om.member_id)))
     LEFT JOIN opensociocracy_api.logbook l ON ((l.org_id = o.id)))
     LEFT JOIN supertokens.passwordless_users u ON (((u.user_id)::uuid = m.uid)));


--
-- Name: v_user_member_accounts; Type: VIEW; Schema: reporting; Owner: -
--

CREATE VIEW reporting.v_user_member_accounts AS
 SELECT pu.email,
    m.uid AS "memberUid",
    m.created_at AS "createdAt",
    a.uid AS "accountUid",
    am.roles,
    a.personal
   FROM ((((supertokens.all_auth_recipe_users u
     JOIN supertokens.passwordless_users pu ON ((pu.user_id = u.user_id)))
     JOIN opensociocracy_api.member m ON ((m.uid = (u.user_id)::uuid)))
     JOIN opensociocracy_api.account_member am ON ((am.member_id = m.id)))
     JOIN opensociocracy_api.account a ON ((a.id = am.account_id)));


--
-- PostgreSQL database dump complete
--

