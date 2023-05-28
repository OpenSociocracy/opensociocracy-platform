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
-- Data for Name: org_roles; Type: TABLE DATA; Schema: opensociocracy_api; Owner: -
--

INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (4, '5c8310c2-abbe-4929-ae90-f11854ad1f54', '2023-05-27 06:40:08.49215', 'owner', NULL, NULL, '{"all": "all"}');
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (5, '3d71079b-4b76-4ae4-8b3f-a1f89065ebb6', '2023-05-27 08:22:29.791163', 'member-admin', NULL, NULL, '{"tables": {"org_group_member": ["c", "r", "u", "d"]}}');
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (7, '212f1f21-d9b2-423d-90ba-7fb9e9cc56fb', '2023-05-27 09:02:37.244904', 'leader', NULL, NULL, NULL);
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (8, '4b3ac946-a77e-46b2-8aa6-d28f5cb7fac0', '2023-05-27 09:02:37.244904', 'editor', NULL, NULL, NULL);
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (9, 'be887fe8-28b4-4719-96ca-a998006e5b7d', '2023-05-27 09:02:37.244904', 'reviewer', NULL, NULL, NULL);
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (10, '6eba5f49-b4cc-4797-89c9-908b7ea03432', '2023-05-27 09:02:37.244904', 'viewer', NULL, NULL, NULL);
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (11, 'bb790cb5-ab7f-4b41-99c1-31aeb8dc1154', '2023-05-27 09:02:37.244904', 'team-member', NULL, NULL, NULL);
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (12, '2a4108b3-abda-4c21-be86-91452c17964e', '2023-05-27 09:04:23.487881', 'admin', NULL, NULL, NULL);
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (6, 'f87d9f51-95d2-4cbe-935b-a56ee883b87a', '2023-05-27 08:22:29.791163', 'billing-admin', NULL, NULL, '{"nuggets": {"platform-invoice": ["r"], "platform-billing-contact": ["c", "r", "u", "d"]}}');
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (13, '57a6e864-0f3a-48e7-9f9c-31e172a542ba', '2023-05-28 02:07:25.539077', 'logbook-keeper', NULL, NULL, '{"tables": {"logbook_entry": ["c", "r", "u", "d"]}}');
INSERT INTO opensociocracy_api.org_roles (id, uid, created_at, name, description, org_id, perms) VALUES (14, 'dbfa8fcc-1c35-4d46-9b53-6a6ef3433fca', '2023-05-28 02:07:25.539077', 'logbook-viewer', NULL, NULL, '{"tables": {"logbook_entry": ["r"]}}');


--
-- Name: org_roles_id_seq; Type: SEQUENCE SET; Schema: opensociocracy_api; Owner: -
--

SELECT pg_catalog.setval('opensociocracy_api.org_roles_id_seq', 14, true);


--
-- PostgreSQL database dump complete
--

