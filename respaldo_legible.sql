--
-- PostgreSQL database dump
--

\restrict KDFIBUgVqkeOtdKcDOwZJZRYRWcGmg89VQyCNcSfbXczlEQ13eoFx66kbwCu1b5

-- Dumped from database version 17.6 (Debian 17.6-0+deb13u1)
-- Dumped by pg_dump version 17.6 (Debian 17.6-0+deb13u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: event_logs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.event_logs (
    id integer NOT NULL,
    event_type character varying(50),
    description text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.event_logs OWNER TO admin;

--
-- Name: event_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.event_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.event_logs_id_seq OWNER TO admin;

--
-- Name: event_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.event_logs_id_seq OWNED BY public.event_logs.id;


--
-- Name: flight_snapshots; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.flight_snapshots (
    id integer NOT NULL,
    icao24 character varying(12),
    callsign character varying(32),
    lat double precision,
    lon double precision,
    altitude double precision,
    speed double precision,
    heading double precision,
    last_seen bigint,
    raw jsonb,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.flight_snapshots OWNER TO admin;

--
-- Name: flight_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.flight_snapshots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.flight_snapshots_id_seq OWNER TO admin;

--
-- Name: flight_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.flight_snapshots_id_seq OWNED BY public.flight_snapshots.id;


--
-- Name: system_status; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.system_status (
    id integer NOT NULL,
    parameter character varying(50) NOT NULL,
    value character varying(100),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.system_status OWNER TO admin;

--
-- Name: system_status_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.system_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_status_id_seq OWNER TO admin;

--
-- Name: system_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.system_status_id_seq OWNED BY public.system_status.id;


--
-- Name: event_logs id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.event_logs ALTER COLUMN id SET DEFAULT nextval('public.event_logs_id_seq'::regclass);


--
-- Name: flight_snapshots id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.flight_snapshots ALTER COLUMN id SET DEFAULT nextval('public.flight_snapshots_id_seq'::regclass);


--
-- Name: system_status id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.system_status ALTER COLUMN id SET DEFAULT nextval('public.system_status_id_seq'::regclass);


--
-- Data for Name: event_logs; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.event_logs (id, event_type, description, created_at) FROM stdin;
\.

--
-- Data for Name: system_status; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.system_status (id, parameter, value, updated_at) FROM stdin;
1	api_status	OK	2025-11-06 18:49:59.120231
2	db_cleanup	IDLE	2025-11-06 18:49:59.120231
3	flight_alert	NORMAL	2025-11-06 18:49:59.120231
\.


--
-- Name: event_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.event_logs_id_seq', 1, false);


--
-- Name: flight_snapshots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.flight_snapshots_id_seq', 227, true);


--
-- Name: system_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.system_status_id_seq', 3, true);


--
-- Name: event_logs event_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.event_logs
    ADD CONSTRAINT event_logs_pkey PRIMARY KEY (id);


--
-- Name: flight_snapshots flight_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.flight_snapshots
    ADD CONSTRAINT flight_snapshots_pkey PRIMARY KEY (id);


--
-- Name: system_status system_status_parameter_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.system_status
    ADD CONSTRAINT system_status_parameter_key UNIQUE (parameter);


--
-- Name: system_status system_status_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.system_status
    ADD CONSTRAINT system_status_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict KDFIBUgVqkeOtdKcDOwZJZRYRWcGmg89VQyCNcSfbXczlEQ13eoFx66kbwCu1b5

