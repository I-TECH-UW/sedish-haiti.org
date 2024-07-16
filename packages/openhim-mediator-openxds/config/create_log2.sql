
CREATE DATABASE log2 OWNER openxds;

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ip; Type: TABLE; Schema: public; Owner: openxds
--

CREATE TABLE IF NOT EXISTS ip (
    ip character varying(255) NOT NULL,
    company_name character varying(255),
    email character varying(255),
    CONSTRAINT ip_pkey PRIMARY KEY (ip)
);


ALTER TABLE ip OWNER TO openxds;

--
-- Name: main; Type: TABLE; Schema: public; Owner: openxds
--

CREATE TABLE IF NOT EXISTS main (
    messageid character varying(255) NOT NULL,
    pass boolean,
    is_secure boolean,
    test text,
    timereceived timestamp without time zone,
    ip character varying(255),
    CONSTRAINT main_pkey PRIMARY KEY (messageid),
    CONSTRAINT fk3305b9b029afaa FOREIGN KEY (ip) REFERENCES ip(ip)
);


ALTER TABLE main OWNER TO openxds;

--
-- Name: error; Type: TABLE; Schema: public; Owner: openxds
--

CREATE TABLE IF NOT EXISTS error (
    id character varying(255) NOT NULL,
    name character varying(255),
    value text,
    messageid character varying(255) NOT NULL,
    CONSTRAINT error_pkey PRIMARY KEY (id),
    CONSTRAINT fk5c4d20858d0dab FOREIGN KEY (messageid) REFERENCES main(messageid)
);


ALTER TABLE error OWNER TO openxds;

--
-- Name: http; Type: TABLE; Schema: public; Owner: openxds
--

CREATE TABLE IF NOT EXISTS http (
    id character varying(255) NOT NULL,
    name character varying(255),
    value text,
    messageid character varying(255) NOT NULL,
    CONSTRAINT http_pkey PRIMARY KEY (id),
    CONSTRAINT fk31088858d0dab FOREIGN KEY (messageid) REFERENCES main(messageid)
);


ALTER TABLE http OWNER TO openxds;

--
-- Name: other; Type: TABLE; Schema: public; Owner: openxds
--

CREATE TABLE IF NOT EXISTS other (
    id character varying(255) NOT NULL,
    name character varying(255),
    value text,
    messageid character varying(255) NOT NULL,
    CONSTRAINT other_pkey PRIMARY KEY (id),
    CONSTRAINT fk6527f1058d0dab FOREIGN KEY (messageid) REFERENCES main(messageid)
);


ALTER TABLE other OWNER TO openxds;

--
-- Name: soap; Type: TABLE; Schema: public; Owner: openxds
--

CREATE TABLE IF NOT EXISTS soap (
    id character varying(255) NOT NULL,
    name character varying(255),
    value text,
    messageid character varying(255) NOT NULL,
    CONSTRAINT soap_pkey PRIMARY KEY (id),
    CONSTRAINT fk35f38b58d0dab FOREIGN KEY (messageid) REFERENCES main(messageid)
);


ALTER TABLE soap OWNER TO openxds;

