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
-- Name: supertokens; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA supertokens;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: all_auth_recipe_users; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.all_auth_recipe_users (
    user_id character(36) NOT NULL,
    recipe_id character varying(128) NOT NULL,
    time_joined bigint NOT NULL
);


--
-- Name: dashboard_user_sessions; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.dashboard_user_sessions (
    session_id character(36) NOT NULL,
    user_id character(36) NOT NULL,
    time_created bigint NOT NULL,
    expiry bigint NOT NULL
);


--
-- Name: dashboard_users; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.dashboard_users (
    user_id character(36) NOT NULL,
    email character varying(256) NOT NULL,
    password_hash character varying(256) NOT NULL,
    time_joined bigint NOT NULL
);


--
-- Name: emailpassword_pswd_reset_tokens; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.emailpassword_pswd_reset_tokens (
    user_id character(36) NOT NULL,
    token character varying(128) NOT NULL,
    token_expiry bigint NOT NULL
);


--
-- Name: emailpassword_users; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.emailpassword_users (
    user_id character(36) NOT NULL,
    email character varying(256) NOT NULL,
    password_hash character varying(256) NOT NULL,
    time_joined bigint NOT NULL
);


--
-- Name: emailverification_tokens; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.emailverification_tokens (
    user_id character varying(128) NOT NULL,
    email character varying(256) NOT NULL,
    token character varying(128) NOT NULL,
    token_expiry bigint NOT NULL
);


--
-- Name: emailverification_verified_emails; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.emailverification_verified_emails (
    user_id character varying(128) NOT NULL,
    email character varying(256) NOT NULL
);


--
-- Name: jwt_signing_keys; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.jwt_signing_keys (
    key_id character varying(255) NOT NULL,
    key_string text NOT NULL,
    algorithm character varying(10) NOT NULL,
    created_at bigint
);


--
-- Name: key_value; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.key_value (
    name character varying(128) NOT NULL,
    value text,
    created_at_time bigint
);


--
-- Name: passwordless_codes; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.passwordless_codes (
    code_id character(36) NOT NULL,
    device_id_hash character(44) NOT NULL,
    link_code_hash character(44) NOT NULL,
    created_at bigint NOT NULL
);


--
-- Name: passwordless_devices; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.passwordless_devices (
    device_id_hash character(44) NOT NULL,
    email character varying(256),
    phone_number character varying(256),
    link_code_salt character(44) NOT NULL,
    failed_attempts integer NOT NULL
);


--
-- Name: passwordless_users; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.passwordless_users (
    user_id character(36) NOT NULL,
    email character varying(256),
    phone_number character varying(256),
    time_joined bigint NOT NULL
);


--
-- Name: role_permissions; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.role_permissions (
    role character varying(255) NOT NULL,
    permission character varying(255) NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.roles (
    role character varying(255) NOT NULL
);


--
-- Name: session_access_token_signing_keys; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.session_access_token_signing_keys (
    created_at_time bigint NOT NULL,
    value text
);


--
-- Name: session_info; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.session_info (
    session_handle character varying(255) NOT NULL,
    user_id character varying(128) NOT NULL,
    refresh_token_hash_2 character varying(128) NOT NULL,
    session_data text,
    expires_at bigint NOT NULL,
    created_at_time bigint NOT NULL,
    jwt_user_payload text
);


--
-- Name: thirdparty_users; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.thirdparty_users (
    third_party_id character varying(28) NOT NULL,
    third_party_user_id character varying(256) NOT NULL,
    user_id character(36) NOT NULL,
    email character varying(256) NOT NULL,
    time_joined bigint NOT NULL
);


--
-- Name: totp_used_codes; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.totp_used_codes (
    user_id character varying(128) NOT NULL,
    code character varying(8) NOT NULL,
    is_valid boolean NOT NULL,
    expiry_time_ms bigint NOT NULL,
    created_time_ms bigint NOT NULL
);


--
-- Name: totp_user_devices; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.totp_user_devices (
    user_id character varying(128) NOT NULL,
    device_name character varying(256) NOT NULL,
    secret_key character varying(256) NOT NULL,
    period integer NOT NULL,
    skew integer NOT NULL,
    verified boolean NOT NULL
);


--
-- Name: totp_users; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.totp_users (
    user_id character varying(128) NOT NULL
);


--
-- Name: user_last_active; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.user_last_active (
    user_id character varying(128) NOT NULL,
    last_active_time bigint
);


--
-- Name: user_metadata; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.user_metadata (
    user_id character varying(128) NOT NULL,
    user_metadata text NOT NULL
);


--
-- Name: user_roles; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.user_roles (
    user_id character varying(128) NOT NULL,
    role character varying(255) NOT NULL
);


--
-- Name: userid_mapping; Type: TABLE; Schema: supertokens; Owner: -
--

CREATE TABLE supertokens.userid_mapping (
    supertokens_user_id character(36) NOT NULL,
    external_user_id character varying(128) NOT NULL,
    external_user_id_info text
);


--
-- Name: all_auth_recipe_users all_auth_recipe_users_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.all_auth_recipe_users
    ADD CONSTRAINT all_auth_recipe_users_pkey PRIMARY KEY (user_id);


--
-- Name: dashboard_user_sessions dashboard_user_sessions_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.dashboard_user_sessions
    ADD CONSTRAINT dashboard_user_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: dashboard_users dashboard_users_email_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.dashboard_users
    ADD CONSTRAINT dashboard_users_email_key UNIQUE (email);


--
-- Name: dashboard_users dashboard_users_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.dashboard_users
    ADD CONSTRAINT dashboard_users_pkey PRIMARY KEY (user_id);


--
-- Name: emailpassword_pswd_reset_tokens emailpassword_pswd_reset_tokens_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.emailpassword_pswd_reset_tokens
    ADD CONSTRAINT emailpassword_pswd_reset_tokens_pkey PRIMARY KEY (user_id, token);


--
-- Name: emailpassword_pswd_reset_tokens emailpassword_pswd_reset_tokens_token_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.emailpassword_pswd_reset_tokens
    ADD CONSTRAINT emailpassword_pswd_reset_tokens_token_key UNIQUE (token);


--
-- Name: emailpassword_users emailpassword_users_email_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.emailpassword_users
    ADD CONSTRAINT emailpassword_users_email_key UNIQUE (email);


--
-- Name: emailpassword_users emailpassword_users_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.emailpassword_users
    ADD CONSTRAINT emailpassword_users_pkey PRIMARY KEY (user_id);


--
-- Name: emailverification_tokens emailverification_tokens_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.emailverification_tokens
    ADD CONSTRAINT emailverification_tokens_pkey PRIMARY KEY (user_id, email, token);


--
-- Name: emailverification_tokens emailverification_tokens_token_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.emailverification_tokens
    ADD CONSTRAINT emailverification_tokens_token_key UNIQUE (token);


--
-- Name: emailverification_verified_emails emailverification_verified_emails_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.emailverification_verified_emails
    ADD CONSTRAINT emailverification_verified_emails_pkey PRIMARY KEY (user_id, email);


--
-- Name: jwt_signing_keys jwt_signing_keys_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.jwt_signing_keys
    ADD CONSTRAINT jwt_signing_keys_pkey PRIMARY KEY (key_id);


--
-- Name: key_value key_value_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.key_value
    ADD CONSTRAINT key_value_pkey PRIMARY KEY (name);


--
-- Name: passwordless_codes passwordless_codes_link_code_hash_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.passwordless_codes
    ADD CONSTRAINT passwordless_codes_link_code_hash_key UNIQUE (link_code_hash);


--
-- Name: passwordless_codes passwordless_codes_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.passwordless_codes
    ADD CONSTRAINT passwordless_codes_pkey PRIMARY KEY (code_id);


--
-- Name: passwordless_devices passwordless_devices_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.passwordless_devices
    ADD CONSTRAINT passwordless_devices_pkey PRIMARY KEY (device_id_hash);


--
-- Name: passwordless_users passwordless_users_email_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.passwordless_users
    ADD CONSTRAINT passwordless_users_email_key UNIQUE (email);


--
-- Name: passwordless_users passwordless_users_phone_number_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.passwordless_users
    ADD CONSTRAINT passwordless_users_phone_number_key UNIQUE (phone_number);


--
-- Name: passwordless_users passwordless_users_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.passwordless_users
    ADD CONSTRAINT passwordless_users_pkey PRIMARY KEY (user_id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role, permission);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role);


--
-- Name: session_access_token_signing_keys session_access_token_signing_keys_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.session_access_token_signing_keys
    ADD CONSTRAINT session_access_token_signing_keys_pkey PRIMARY KEY (created_at_time);


--
-- Name: session_info session_info_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.session_info
    ADD CONSTRAINT session_info_pkey PRIMARY KEY (session_handle);


--
-- Name: thirdparty_users thirdparty_users_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.thirdparty_users
    ADD CONSTRAINT thirdparty_users_pkey PRIMARY KEY (third_party_id, third_party_user_id);


--
-- Name: thirdparty_users thirdparty_users_user_id_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.thirdparty_users
    ADD CONSTRAINT thirdparty_users_user_id_key UNIQUE (user_id);


--
-- Name: totp_used_codes totp_used_codes_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.totp_used_codes
    ADD CONSTRAINT totp_used_codes_pkey PRIMARY KEY (user_id, created_time_ms);


--
-- Name: totp_user_devices totp_user_devices_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.totp_user_devices
    ADD CONSTRAINT totp_user_devices_pkey PRIMARY KEY (user_id, device_name);


--
-- Name: totp_users totp_users_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.totp_users
    ADD CONSTRAINT totp_users_pkey PRIMARY KEY (user_id);


--
-- Name: user_last_active user_last_active_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.user_last_active
    ADD CONSTRAINT user_last_active_pkey PRIMARY KEY (user_id);


--
-- Name: user_metadata user_metadata_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.user_metadata
    ADD CONSTRAINT user_metadata_pkey PRIMARY KEY (user_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role);


--
-- Name: userid_mapping userid_mapping_external_user_id_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.userid_mapping
    ADD CONSTRAINT userid_mapping_external_user_id_key UNIQUE (external_user_id);


--
-- Name: userid_mapping userid_mapping_pkey; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.userid_mapping
    ADD CONSTRAINT userid_mapping_pkey PRIMARY KEY (supertokens_user_id, external_user_id);


--
-- Name: userid_mapping userid_mapping_supertokens_user_id_key; Type: CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.userid_mapping
    ADD CONSTRAINT userid_mapping_supertokens_user_id_key UNIQUE (supertokens_user_id);


--
-- Name: all_auth_recipe_users_pagination_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX all_auth_recipe_users_pagination_index ON supertokens.all_auth_recipe_users USING btree (time_joined DESC, user_id DESC);


--
-- Name: dashboard_user_sessions_expiry_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX dashboard_user_sessions_expiry_index ON supertokens.dashboard_user_sessions USING btree (expiry);


--
-- Name: emailpassword_password_reset_token_expiry_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX emailpassword_password_reset_token_expiry_index ON supertokens.emailpassword_pswd_reset_tokens USING btree (token_expiry);


--
-- Name: emailverification_tokens_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX emailverification_tokens_index ON supertokens.emailverification_tokens USING btree (token_expiry);


--
-- Name: passwordless_codes_created_at_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX passwordless_codes_created_at_index ON supertokens.passwordless_codes USING btree (created_at);


--
-- Name: passwordless_codes_device_id_hash_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX passwordless_codes_device_id_hash_index ON supertokens.passwordless_codes USING btree (device_id_hash);


--
-- Name: passwordless_devices_email_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX passwordless_devices_email_index ON supertokens.passwordless_devices USING btree (email);


--
-- Name: passwordless_devices_phone_number_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX passwordless_devices_phone_number_index ON supertokens.passwordless_devices USING btree (phone_number);


--
-- Name: role_permissions_permission_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX role_permissions_permission_index ON supertokens.role_permissions USING btree (permission);


--
-- Name: totp_used_codes_expiry_time_ms_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX totp_used_codes_expiry_time_ms_index ON supertokens.totp_used_codes USING btree (expiry_time_ms);


--
-- Name: user_roles_role_index; Type: INDEX; Schema: supertokens; Owner: -
--

CREATE INDEX user_roles_role_index ON supertokens.user_roles USING btree (role);


--
-- Name: all_auth_recipe_users new_user_member_account; Type: TRIGGER; Schema: supertokens; Owner: -
--

CREATE TRIGGER new_user_member_account AFTER INSERT ON supertokens.all_auth_recipe_users FOR EACH ROW EXECUTE FUNCTION opensociocracy_api.new_member_from_user();


--
-- Name: dashboard_user_sessions dashboard_user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.dashboard_user_sessions
    ADD CONSTRAINT dashboard_user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES supertokens.dashboard_users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: emailpassword_pswd_reset_tokens emailpassword_pswd_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.emailpassword_pswd_reset_tokens
    ADD CONSTRAINT emailpassword_pswd_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES supertokens.emailpassword_users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: passwordless_codes passwordless_codes_device_id_hash_fkey; Type: FK CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.passwordless_codes
    ADD CONSTRAINT passwordless_codes_device_id_hash_fkey FOREIGN KEY (device_id_hash) REFERENCES supertokens.passwordless_devices(device_id_hash) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_fkey; Type: FK CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.role_permissions
    ADD CONSTRAINT role_permissions_role_fkey FOREIGN KEY (role) REFERENCES supertokens.roles(role) ON DELETE CASCADE;


--
-- Name: totp_used_codes totp_used_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.totp_used_codes
    ADD CONSTRAINT totp_used_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES supertokens.totp_users(user_id) ON DELETE CASCADE;


--
-- Name: totp_user_devices totp_user_devices_user_id_fkey; Type: FK CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.totp_user_devices
    ADD CONSTRAINT totp_user_devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES supertokens.totp_users(user_id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_role_fkey; Type: FK CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.user_roles
    ADD CONSTRAINT user_roles_role_fkey FOREIGN KEY (role) REFERENCES supertokens.roles(role) ON DELETE CASCADE;


--
-- Name: userid_mapping userid_mapping_supertokens_user_id_fkey; Type: FK CONSTRAINT; Schema: supertokens; Owner: -
--

ALTER TABLE ONLY supertokens.userid_mapping
    ADD CONSTRAINT userid_mapping_supertokens_user_id_fkey FOREIGN KEY (supertokens_user_id) REFERENCES supertokens.all_auth_recipe_users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

