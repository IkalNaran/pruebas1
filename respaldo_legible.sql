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
-- Data for Name: flight_snapshots; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.flight_snapshots (id, icao24, callsign, lat, lon, altitude, speed, heading, last_seen, raw, created_at) FROM stdin;
1	0d06a7	SLI2525	18.9129	-99.1162	4770.12	148.2	4.98	1762483738	{"lat": 18.9129, "lon": -99.1162, "speed": 148.2, "icao24": "0d06a7", "heading": 4.98, "altitude": 4770.12, "callsign": "SLI2525", "estimated": false, "last_seen": 1762483738}	2025-11-07 02:49:08.3281
2	0d07f7	VOI1397	18.9084	-99.5093	9380.22	215.22	294.73	1762483738	{"lat": 18.9084, "lon": -99.5093, "speed": 215.22, "icao24": "0d07f7", "heading": 294.73, "altitude": 9380.22, "callsign": "VOI1397", "estimated": false, "last_seen": 1762483738}	2025-11-07 02:49:08.328113
3	a1245e	AMX339	18.9489	-99.2356	5364.48	157.12	124.73	1762483738	{"lat": 18.9489, "lon": -99.2356, "speed": 157.12, "icao24": "a1245e", "heading": 124.73, "altitude": 5364.48, "callsign": "AMX339", "estimated": false, "last_seen": 1762483738}	2025-11-07 02:49:08.32812
4	0d0380	SLI1639	19.6718	-99.4092	4526.28	148.68	123.14	1762483738	{"lat": 19.6718, "lon": -99.4092, "speed": 148.68, "icao24": "0d0380", "heading": 123.14, "altitude": 4526.28, "callsign": "SLI1639", "estimated": false, "last_seen": 1762483738}	2025-11-07 02:49:08.328123
5	a16d99		19.1392	-99.4772	4884.42	132.47	156.42	1762483615	{"lat": 19.1392, "lon": -99.4772, "speed": 132.47, "icao24": "a16d99", "heading": 156.42, "altitude": 4884.42, "callsign": "", "estimated": false, "last_seen": 1762483615}	2025-11-07 02:49:08.328128
6	0d04ae	SLI340	19.3611	-99.4666	6865.62	200.15	268.97	1762483738	{"lat": 19.3611, "lon": -99.4666, "speed": 200.15, "icao24": "0d04ae", "heading": 268.97, "altitude": 6865.62, "callsign": "SLI340", "estimated": false, "last_seen": 1762483738}	2025-11-07 02:49:08.328133
7	0d0b04	AMX322	19.4435	-99.0621	2209.8	92.47	59.58	1762483736	{"lat": 19.4435, "lon": -99.0621, "speed": 92.47, "icao24": "0d0b04", "heading": 59.58, "altitude": 2209.8, "callsign": "AMX322", "estimated": false, "last_seen": 1762483736}	2025-11-07 02:49:08.328137
8	0d09de	XAFOF	19.2683	-99.0598	7261.86	205.96	12.4	1762483739	{"lat": 19.2683, "lon": -99.0598, "speed": 205.96, "icao24": "0d09de", "heading": 12.4, "altitude": 7261.86, "callsign": "XAFOF", "estimated": false, "last_seen": 1762483739}	2025-11-07 02:49:08.328142
9	4d23a0	VIV1373	19.3976	-99.1382	2468.88	84.26	58.74	1762483735	{"lat": 19.3976, "lon": -99.1382, "speed": 84.26, "icao24": "4d23a0", "heading": 58.74, "altitude": 2468.88, "callsign": "VIV1373", "estimated": false, "last_seen": 1762483735}	2025-11-07 02:49:08.328147
10	0d0fec	XCNZA	19.3703	-98.9768	2225.04	36.56	76.16	1762483726	{"lat": 19.3703, "lon": -98.9768, "speed": 36.56, "icao24": "0d0fec", "heading": 76.16, "altitude": 2225.04, "callsign": "XCNZA", "estimated": false, "last_seen": 1762483726}	2025-11-07 02:49:08.328151
11	0d0fba	VIV1353	19.444	-99.0637	\N	7.2	241.88	1762483738	{"lat": 19.444, "lon": -99.0637, "speed": 7.2, "icao24": "0d0fba", "heading": 241.88, "altitude": null, "callsign": "VIV1353", "estimated": false, "last_seen": 1762483738}	2025-11-07 02:49:08.328156
12	0d06a7	SLI2525	18.9154	-99.1159	4754.88	147.07	17.93	1762483746	{"lat": 18.9154, "lon": -99.1159, "speed": 147.07, "icao24": "0d06a7", "heading": 17.93, "altitude": 4754.88, "callsign": "SLI2525", "estimated": false, "last_seen": 1762483746}	2025-11-07 02:49:24.673405
13	0d07f7	VOI1397	18.915	-99.5245	9448.8	215.01	294.6	1762483747	{"lat": 18.915, "lon": -99.5245, "speed": 215.01, "icao24": "0d07f7", "heading": 294.6, "altitude": 9448.8, "callsign": "VOI1397", "estimated": false, "last_seen": 1762483747}	2025-11-07 02:49:24.673416
14	a1245e	AMX339	18.948	-99.2343	5364.48	157.12	124.73	1762483739	{"lat": 18.948, "lon": -99.2343, "speed": 157.12, "icao24": "a1245e", "heading": 124.73, "altitude": 5364.48, "callsign": "AMX339", "estimated": false, "last_seen": 1762483739}	2025-11-07 02:49:24.673421
15	0d0380	SLI1639	19.6664	-99.4004	4503.42	150.1	123.25	1762483746	{"lat": 19.6664, "lon": -99.4004, "speed": 150.1, "icao24": "0d0380", "heading": 123.25, "altitude": 4503.42, "callsign": "SLI1639", "estimated": false, "last_seen": 1762483746}	2025-11-07 02:49:24.673427
16	a16d99		19.1392	-99.4772	4884.42	132.47	156.42	1762483615	{"lat": 19.1392, "lon": -99.4772, "speed": 132.47, "icao24": "a16d99", "heading": 156.42, "altitude": 4884.42, "callsign": "", "estimated": false, "last_seen": 1762483615}	2025-11-07 02:49:24.673431
17	0d04ae	SLI340	19.3607	-99.4892	6979.92	199.64	268.97	1762483746	{"lat": 19.3607, "lon": -99.4892, "speed": 199.64, "icao24": "0d04ae", "heading": 268.97, "altitude": 6979.92, "callsign": "SLI340", "estimated": false, "last_seen": 1762483746}	2025-11-07 02:49:24.673436
18	0d0b04	AMX322	19.4435	-99.0621	2209.8	92.47	59.58	1762483746	{"lat": 19.4435, "lon": -99.0621, "speed": 92.47, "icao24": "0d0b04", "heading": 59.58, "altitude": 2209.8, "callsign": "AMX322", "estimated": false, "last_seen": 1762483746}	2025-11-07 02:49:24.67344
19	0d09de	XAFOF	19.2816	-99.0574	7338.06	205.91	7.32	1762483747	{"lat": 19.2816, "lon": -99.0574, "speed": 205.91, "icao24": "0d09de", "heading": 7.32, "altitude": 7338.06, "callsign": "XAFOF", "estimated": false, "last_seen": 1762483747}	2025-11-07 02:49:24.673445
20	4d23a0	VIV1373	19.3976	-99.1382	2468.88	84.26	58.74	1762483744	{"lat": 19.3976, "lon": -99.1382, "speed": 84.26, "icao24": "4d23a0", "heading": 58.74, "altitude": 2468.88, "callsign": "VIV1373", "estimated": false, "last_seen": 1762483744}	2025-11-07 02:49:24.673449
21	0d0fec	XCNZA	19.3703	-98.9768	2225.04	36.56	76.16	1762483726	{"lat": 19.3703, "lon": -98.9768, "speed": 36.56, "icao24": "0d0fec", "heading": 76.16, "altitude": 2225.04, "callsign": "XCNZA", "estimated": false, "last_seen": 1762483726}	2025-11-07 02:49:24.673454
22	0d0fba	VIV1353	19.444	-99.0637	\N	\N	239.06	1762483744	{"lat": 19.444, "lon": -99.0637, "speed": null, "icao24": "0d0fba", "heading": 239.06, "altitude": null, "callsign": "VIV1353", "estimated": false, "last_seen": 1762483744}	2025-11-07 02:49:24.673458
23	0d06a7	SLI2525	18.9154	-99.1159	4754.88	147.07	17.93	1762483746	{"lat": 18.9154, "lon": -99.1159, "speed": 147.07, "icao24": "0d06a7", "heading": 17.93, "altitude": 4754.88, "callsign": "SLI2525", "estimated": false, "last_seen": 1762483746}	2025-11-07 02:49:40.943198
24	0d07f7	VOI1397	18.9415	-99.5849	9685.02	215.01	294.6	1762483778	{"lat": 18.9415, "lon": -99.5849, "speed": 215.01, "icao24": "0d07f7", "heading": 294.6, "altitude": 9685.02, "callsign": "VOI1397", "estimated": false, "last_seen": 1762483778}	2025-11-07 02:49:40.943209
25	a1245e	AMX339	18.9157	-99.1869	5379.72	156.63	125.78	1762483778	{"lat": 18.9157, "lon": -99.1869, "speed": 156.63, "icao24": "a1245e", "heading": 125.78, "altitude": 5379.72, "callsign": "AMX339", "estimated": false, "last_seen": 1762483778}	2025-11-07 02:49:40.943214
26	0d0380	SLI1639	19.6569	-99.385	4450.08	151.25	123.2	1762483760	{"lat": 19.6569, "lon": -99.385, "speed": 151.25, "icao24": "0d0380", "heading": 123.2, "altitude": 4450.08, "callsign": "SLI1639", "estimated": false, "last_seen": 1762483760}	2025-11-07 02:49:40.943218
27	a16d99		19.0854	-99.3057	6324.6	132.47	156.42	1762483778	{"lat": 19.0854, "lon": -99.3057, "speed": 132.47, "icao24": "a16d99", "heading": 156.42, "altitude": 6324.6, "callsign": "", "estimated": false, "last_seen": 1762483778}	2025-11-07 02:49:40.943224
28	0d04ae	SLI340	19.36	-99.5324	7208.52	199.12	268.96	1762483769	{"lat": 19.36, "lon": -99.5324, "speed": 199.12, "icao24": "0d04ae", "heading": 268.96, "altitude": 7208.52, "callsign": "SLI340", "estimated": false, "last_seen": 1762483769}	2025-11-07 02:49:40.943228
29	0d0b04	AMX322	19.4435	-99.0621	2209.8	92.47	59.58	1762483776	{"lat": 19.4435, "lon": -99.0621, "speed": 92.47, "icao24": "0d0b04", "heading": 59.58, "altitude": 2209.8, "callsign": "AMX322", "estimated": false, "last_seen": 1762483776}	2025-11-07 02:49:40.943233
30	0d09de	XAFOF	19.3417	-99.0567	7620	207.33	359.57	1762483779	{"lat": 19.3417, "lon": -99.0567, "speed": 207.33, "icao24": "0d09de", "heading": 359.57, "altitude": 7620, "callsign": "XAFOF", "estimated": false, "last_seen": 1762483779}	2025-11-07 02:49:40.943237
31	4d23a0	VIV1373	19.4406	-99.0626	\N	10.8	36.56	1762483777	{"lat": 19.4406, "lon": -99.0626, "speed": 10.8, "icao24": "4d23a0", "heading": 36.56, "altitude": null, "callsign": "VIV1373", "estimated": false, "last_seen": 1762483777}	2025-11-07 02:49:40.943242
32	0d0fec	XCNZA	19.3703	-98.9768	2225.04	36.56	76.16	1762483726	{"lat": 19.3703, "lon": -98.9768, "speed": 36.56, "icao24": "0d0fec", "heading": 76.16, "altitude": 2225.04, "callsign": "XCNZA", "estimated": false, "last_seen": 1762483726}	2025-11-07 02:49:40.943247
33	0d0fba	VIV1353	19.4422	-99.0668	\N	11.32	239.06	1762483777	{"lat": 19.4422, "lon": -99.0668, "speed": 11.32, "icao24": "0d0fba", "heading": 239.06, "altitude": null, "callsign": "VIV1353", "estimated": false, "last_seen": 1762483777}	2025-11-07 02:49:40.943251
34	0d06a7	SLI2525	19.0338	-99.0696	4152.9	143.79	20.96	1762483836	{"lat": 19.0338, "lon": -99.0696, "speed": 143.79, "icao24": "0d06a7", "heading": 20.96, "altitude": 4152.9, "callsign": "SLI2525", "estimated": false, "last_seen": 1762483836}	2025-11-07 02:50:43.313794
35	a1245e	AMX339	18.9023	-99.1096	5372.1	152.31	60.23	1762483836	{"lat": 18.9023, "lon": -99.1096, "speed": 152.31, "icao24": "a1245e", "heading": 60.23, "altitude": 5372.1, "callsign": "AMX339", "estimated": false, "last_seen": 1762483836}	2025-11-07 02:50:43.313805
36	0d0380	SLI1639	19.6569	-99.385	4450.08	143.74	130.65	1762483834	{"lat": 19.6569, "lon": -99.385, "speed": 143.74, "icao24": "0d0380", "heading": 130.65, "altitude": 4450.08, "callsign": "SLI1639", "estimated": false, "last_seen": 1762483834}	2025-11-07 02:50:43.31381
37	a16d99		19.1389	-99.2567	6880.86	155.36	24.87	1762483829	{"lat": 19.1389, "lon": -99.2567, "speed": 155.36, "icao24": "a16d99", "heading": 24.87, "altitude": 6880.86, "callsign": "", "estimated": false, "last_seen": 1762483829}	2025-11-07 02:50:43.313813
38	0d0b04	AMX322	19.5318	-98.9015	3474.72	153.15	67.48	1762483836	{"lat": 19.5318, "lon": -98.9015, "speed": 153.15, "icao24": "0d0b04", "heading": 67.48, "altitude": 3474.72, "callsign": "AMX322", "estimated": false, "last_seen": 1762483836}	2025-11-07 02:50:43.313818
39	0d09de	XAFOF	19.4513	-99.0582	8061.96	213.01	359.03	1762483837	{"lat": 19.4513, "lon": -99.0582, "speed": 213.01, "icao24": "0d09de", "heading": 359.03, "altitude": 8061.96, "callsign": "XAFOF", "estimated": false, "last_seen": 1762483837}	2025-11-07 02:50:43.313822
40	4d23a0	VIV1373	19.443	-99.0616	\N	2.83	2.81	1762483835	{"lat": 19.443, "lon": -99.0616, "speed": 2.83, "icao24": "4d23a0", "heading": 2.81, "altitude": null, "callsign": "VIV1373", "estimated": false, "last_seen": 1762483835}	2025-11-07 02:50:43.313826
41	0d0f91	VIV146	19.4515	-99.0479	2506.98	92.4	60.29	1762483836	{"lat": 19.4515, "lon": -99.0479, "speed": 92.4, "icao24": "0d0f91", "heading": 60.29, "altitude": 2506.98, "callsign": "VIV146", "estimated": false, "last_seen": 1762483836}	2025-11-07 02:50:43.31383
42	0d0fec	XCNZA	19.387	-98.9744	2225.04	36.18	330.15	1762483803	{"lat": 19.387, "lon": -98.9744, "speed": 36.18, "icao24": "0d0fec", "heading": 330.15, "altitude": 2225.04, "callsign": "XCNZA", "estimated": false, "last_seen": 1762483803}	2025-11-07 02:50:43.313835
43	0d0fba	VIV1353	19.4415	-99.0681	\N	12.35	239.06	1762483791	{"lat": 19.4415, "lon": -99.0681, "speed": 12.35, "icao24": "0d0fba", "heading": 239.06, "altitude": null, "callsign": "VIV1353", "estimated": false, "last_seen": 1762483791}	2025-11-07 02:50:43.313839
44	0d06a7	SLI2525	19.0477	-99.0641	4152.9	144.27	20.89	1762483847	{"lat": 19.0477, "lon": -99.0641, "speed": 144.27, "icao24": "0d06a7", "heading": 20.89, "altitude": 4152.9, "callsign": "SLI2525", "estimated": false, "last_seen": 1762483847}	2025-11-07 02:50:59.702895
45	a1245e	AMX339	18.9138	-99.0953	5349.24	152.99	42	1762483849	{"lat": 18.9138, "lon": -99.0953, "speed": 152.99, "icao24": "a1245e", "heading": 42, "altitude": 5349.24, "callsign": "AMX339", "estimated": false, "last_seen": 1762483849}	2025-11-07 02:50:59.702907
46	0d0380	SLI1639	19.5898	-99.2849	4122.42	143.74	130.65	1762483846	{"lat": 19.5898, "lon": -99.2849, "speed": 143.74, "icao24": "0d0380", "heading": 130.65, "altitude": 4122.42, "callsign": "SLI1639", "estimated": false, "last_seen": 1762483846}	2025-11-07 02:50:59.702911
47	a16d99		19.1612	-99.2486	7040.88	157.38	15.35	1762483846	{"lat": 19.1612, "lon": -99.2486, "speed": 157.38, "icao24": "a16d99", "heading": 15.35, "altitude": 7040.88, "callsign": "", "estimated": false, "last_seen": 1762483846}	2025-11-07 02:50:59.702916
48	0d09de	XAFOF	19.4771	-99.0586	8168.64	214.55	359.18	1762483850	{"lat": 19.4771, "lon": -99.0586, "speed": 214.55, "icao24": "0d09de", "heading": 359.18, "altitude": 8168.64, "callsign": "XAFOF", "estimated": false, "last_seen": 1762483850}	2025-11-07 02:50:59.70292
49	4d23a0	VIV1373	19.4436	-99.0617	\N	5.66	345.94	1762483849	{"lat": 19.4436, "lon": -99.0617, "speed": 5.66, "icao24": "4d23a0", "heading": 345.94, "altitude": null, "callsign": "VIV1373", "estimated": false, "last_seen": 1762483849}	2025-11-07 02:50:59.702924
50	0d0f91	VIV146	19.4573	-99.0373	2674.62	91.25	60.26	1762483849	{"lat": 19.4573, "lon": -99.0373, "speed": 91.25, "icao24": "0d0f91", "heading": 60.26, "altitude": 2674.62, "callsign": "VIV146", "estimated": false, "last_seen": 1762483849}	2025-11-07 02:50:59.702928
51	0d0fec	XCNZA	19.387	-98.9744	2225.04	36.18	330.15	1762483803	{"lat": 19.387, "lon": -98.9744, "speed": 36.18, "icao24": "0d0fec", "heading": 330.15, "altitude": 2225.04, "callsign": "XCNZA", "estimated": false, "last_seen": 1762483803}	2025-11-07 02:50:59.702932
52	0d0fba	VIV1353	19.4415	-99.0681	\N	12.35	239.06	1762483791	{"lat": 19.4415, "lon": -99.0681, "speed": 12.35, "icao24": "0d0fba", "heading": 239.06, "altitude": null, "callsign": "VIV1353", "estimated": false, "last_seen": 1762483791}	2025-11-07 02:50:59.702936
53	0d06a7	SLI2525	19.068	-99.0559	4152.9	145.89	20.86	1762483864	{"lat": 19.068, "lon": -99.0559, "speed": 145.89, "icao24": "0d06a7", "heading": 20.86, "altitude": 4152.9, "callsign": "SLI2525", "estimated": false, "last_seen": 1762483864}	2025-11-07 02:51:15.99784
54	a1245e	AMX339	18.9311	-99.0848	5242.56	153.34	22.69	1762483863	{"lat": 18.9311, "lon": -99.0848, "speed": 153.34, "icao24": "a1245e", "heading": 22.69, "altitude": 5242.56, "callsign": "AMX339", "estimated": false, "last_seen": 1762483863}	2025-11-07 02:51:15.997849
55	0d0380	SLI1639	19.5898	-99.2849	4122.42	143.74	130.65	1762483846	{"lat": 19.5898, "lon": -99.2849, "speed": 143.74, "icao24": "0d0380", "heading": 130.65, "altitude": 4122.42, "callsign": "SLI1639", "estimated": false, "last_seen": 1762483846}	2025-11-07 02:51:15.997853
56	a16d99		19.183	-99.2444	7117.08	162.14	6.74	1762483864	{"lat": 19.183, "lon": -99.2444, "speed": 162.14, "icao24": "a16d99", "heading": 6.74, "altitude": 7117.08, "callsign": "", "estimated": false, "last_seen": 1762483864}	2025-11-07 02:51:15.997856
57	0d09de	XAFOF	19.5051	-99.059	8275.32	215.56	359.45	1762483865	{"lat": 19.5051, "lon": -99.059, "speed": 215.56, "icao24": "0d09de", "heading": 359.45, "altitude": 8275.32, "callsign": "XAFOF", "estimated": false, "last_seen": 1762483865}	2025-11-07 02:51:15.997859
58	4d23a0	VIV1373	19.4441	-99.0625	\N	6.94	292.5	1762483863	{"lat": 19.4441, "lon": -99.0625, "speed": 6.94, "icao24": "4d23a0", "heading": 292.5, "altitude": null, "callsign": "VIV1373", "estimated": false, "last_seen": 1762483863}	2025-11-07 02:51:15.997862
59	0d0f91	VIV146	19.4636	-99.0256	2758.44	94.95	60.1	1762483864	{"lat": 19.4636, "lon": -99.0256, "speed": 94.95, "icao24": "0d0f91", "heading": 60.1, "altitude": 2758.44, "callsign": "VIV146", "estimated": false, "last_seen": 1762483864}	2025-11-07 02:51:15.997866
60	0d0fec	XCNZA	19.387	-98.9744	2225.04	36.18	330.15	1762483803	{"lat": 19.387, "lon": -98.9744, "speed": 36.18, "icao24": "0d0fec", "heading": 330.15, "altitude": 2225.04, "callsign": "XCNZA", "estimated": false, "last_seen": 1762483803}	2025-11-07 02:51:15.99787
61	0d0fba	VIV1353	19.4415	-99.0681	\N	12.35	239.06	1762483791	{"lat": 19.4415, "lon": -99.0681, "speed": 12.35, "icao24": "0d0fba", "heading": 239.06, "altitude": null, "callsign": "VIV1353", "estimated": false, "last_seen": 1762483791}	2025-11-07 02:51:15.997873
62	0d06f6	SLI1057	18.9589	-99.1442	4884.42	149.83	30.09	1762483988	{"lat": 18.9589, "lon": -99.1442, "speed": 149.83, "icao24": "0d06f6", "heading": 30.09, "altitude": 4884.42, "callsign": "SLI1057", "estimated": false, "last_seen": 1762483988}	2025-11-07 02:53:24.324843
63	0d06a7	SLI2525	19.2129	-99.0463	3970.02	137.89	316.06	1762483988	{"lat": 19.2129, "lon": -99.0463, "speed": 137.89, "icao24": "0d06a7", "heading": 316.06, "altitude": 3970.02, "callsign": "SLI2525", "estimated": false, "last_seen": 1762483988}	2025-11-07 02:53:24.324855
64	a1245e	AMX339	19.0962	-99.0362	4419.6	142.32	15.95	1762483988	{"lat": 19.0962, "lon": -99.0362, "speed": 142.32, "icao24": "a1245e", "heading": 15.95, "altitude": 4419.6, "callsign": "AMX339", "estimated": false, "last_seen": 1762483988}	2025-11-07 02:53:24.324861
65	0d0380	SLI1639	19.4265	-99.2335	3078.48	129.14	179.09	1762483988	{"lat": 19.4265, "lon": -99.2335, "speed": 129.14, "icao24": "0d0380", "heading": 179.09, "altitude": 3078.48, "callsign": "SLI1639", "estimated": false, "last_seen": 1762483988}	2025-11-07 02:53:24.324866
66	a16d99		19.3704	-99.2186	8328.66	165.52	7.5	1762483989	{"lat": 19.3704, "lon": -99.2186, "speed": 165.52, "icao24": "a16d99", "heading": 7.5, "altitude": 8328.66, "callsign": "", "estimated": false, "last_seen": 1762483989}	2025-11-07 02:53:24.324871
67	0d09de	XAFOF	19.7575	-99.0625	8831.58	237.69	359.26	1762483989	{"lat": 19.7575, "lon": -99.0625, "speed": 237.69, "icao24": "0d09de", "heading": 359.26, "altitude": 8831.58, "callsign": "XAFOF", "estimated": false, "last_seen": 1762483989}	2025-11-07 02:53:24.324876
68	4d23a0	VIV1373	19.4416	-99.0681	\N	11.83	239.06	1762483939	{"lat": 19.4416, "lon": -99.0681, "speed": 11.83, "icao24": "4d23a0", "heading": 239.06, "altitude": null, "callsign": "VIV1373", "estimated": false, "last_seen": 1762483939}	2025-11-07 02:53:24.324881
69	0d0f91	VIV146	19.5338	-98.9045	3276.6	148.98	55.27	1762483988	{"lat": 19.5338, "lon": -98.9045, "speed": 148.98, "icao24": "0d0f91", "heading": 55.27, "altitude": 3276.6, "callsign": "VIV146", "estimated": false, "last_seen": 1762483988}	2025-11-07 02:53:24.324885
70	0d0fec	XCNZA	19.387	-98.9744	2225.04	22.74	52.35	1762483950	{"lat": 19.387, "lon": -98.9744, "speed": 22.74, "icao24": "0d0fec", "heading": 52.35, "altitude": 2225.04, "callsign": "XCNZA", "estimated": false, "last_seen": 1762483950}	2025-11-07 02:53:24.32489
71	0d0fba	VIV1353	19.4415	-99.0681	\N	12.35	239.06	1762483791	{"lat": 19.4415, "lon": -99.0681, "speed": 12.35, "icao24": "0d0fba", "heading": 239.06, "altitude": null, "callsign": "VIV1353", "estimated": false, "last_seen": 1762483791}	2025-11-07 02:53:24.324894
72	0d06f6	SLI1057	18.9897	-99.1255	4777.74	145.87	29.82	1762484015	{"lat": 18.9897, "lon": -99.1255, "speed": 145.87, "icao24": "0d06f6", "heading": 29.82, "altitude": 4777.74, "callsign": "SLI1057", "estimated": false, "last_seen": 1762484015}	2025-11-07 02:53:40.885424
73	0d06a7	SLI2525	19.2371	-99.0709	3771.9	138.65	313.35	1762484015	{"lat": 19.2371, "lon": -99.0709, "speed": 138.65, "icao24": "0d06a7", "heading": 313.35, "altitude": 3771.9, "callsign": "SLI2525", "estimated": false, "last_seen": 1762484015}	2025-11-07 02:53:40.885434
74	a1245e	AMX339	19.1283	-99.0264	4328.16	133.7	15.85	1762484015	{"lat": 19.1283, "lon": -99.0264, "speed": 133.7, "icao24": "a1245e", "heading": 15.85, "altitude": 4328.16, "callsign": "AMX339", "estimated": false, "last_seen": 1762484015}	2025-11-07 02:53:40.88544
75	0d0380	SLI1639	19.3973	-99.231	2910.84	115.5	161.57	1762484015	{"lat": 19.3973, "lon": -99.231, "speed": 115.5, "icao24": "0d0380", "heading": 161.57, "altitude": 2910.84, "callsign": "SLI1639", "estimated": false, "last_seen": 1762484015}	2025-11-07 02:53:40.885445
76	a16d99		19.4098	-99.2132	8481.06	171.14	7.25	1762484015	{"lat": 19.4098, "lon": -99.2132, "speed": 171.14, "icao24": "a16d99", "heading": 7.25, "altitude": 8481.06, "callsign": "", "estimated": false, "last_seen": 1762484015}	2025-11-07 02:53:40.88545
77	4d23a0	VIV1373	19.4416	-99.0681	\N	11.83	239.06	1762483939	{"lat": 19.4416, "lon": -99.0681, "speed": 11.83, "icao24": "4d23a0", "heading": 239.06, "altitude": null, "callsign": "VIV1373", "estimated": false, "last_seen": 1762483939}	2025-11-07 02:53:40.885455
78	0d0fec	XCNZA	19.387	-98.9744	2225.04	22.74	52.35	1762483950	{"lat": 19.387, "lon": -98.9744, "speed": 22.74, "icao24": "0d0fec", "heading": 52.35, "altitude": 2225.04, "callsign": "XCNZA", "estimated": false, "last_seen": 1762483950}	2025-11-07 02:53:40.885459
79	0d0fba	VIV1353	19.4415	-99.0681	\N	12.35	239.06	1762483791	{"lat": 19.4415, "lon": -99.0681, "speed": 12.35, "icao24": "0d0fba", "heading": 239.06, "altitude": null, "callsign": "VIV1353", "estimated": false, "last_seen": 1762483791}	2025-11-07 02:53:40.885463
80	0d06f6	SLI1057	19.0232	-99.1053	4663.44	144.72	29.85	1762484044	{"lat": 19.0232, "lon": -99.1053, "speed": 144.72, "icao24": "0d06f6", "heading": 29.85, "altitude": 4663.44, "callsign": "SLI1057", "estimated": false, "last_seen": 1762484044}	2025-11-07 02:54:12.53289
81	0d06a7	SLI2525	19.2637	-99.1057	3528.06	131.71	307.54	1762484050	{"lat": 19.2637, "lon": -99.1057, "speed": 131.71, "icao24": "0d06a7", "heading": 307.54, "altitude": 3528.06, "callsign": "SLI2525", "estimated": false, "last_seen": 1762484050}	2025-11-07 02:54:12.5329
82	a1245e	AMX339	19.1693	-99.0164	4183.38	133.32	358.01	1762484050	{"lat": 19.1693, "lon": -99.0164, "speed": 133.32, "icao24": "a1245e", "heading": 358.01, "altitude": 4183.38, "callsign": "AMX339", "estimated": false, "last_seen": 1762484050}	2025-11-07 02:54:12.532905
83	0d0380	SLI1639	19.3743	-99.2062	2735.58	103.63	108.52	1762484050	{"lat": 19.3743, "lon": -99.2062, "speed": 103.63, "icao24": "0d0380", "heading": 108.52, "altitude": 2735.58, "callsign": "SLI1639", "estimated": false, "last_seen": 1762484050}	2025-11-07 02:54:12.53291
84	a16d99		19.4647	-99.2058	8717.28	174.77	7.27	1762484051	{"lat": 19.4647, "lon": -99.2058, "speed": 174.77, "icao24": "a16d99", "heading": 7.27, "altitude": 8717.28, "callsign": "", "estimated": false, "last_seen": 1762484051}	2025-11-07 02:54:12.532915
85	4d23a0	VIV1373	19.4416	-99.0681	\N	11.83	239.06	1762483939	{"lat": 19.4416, "lon": -99.0681, "speed": 11.83, "icao24": "4d23a0", "heading": 239.06, "altitude": null, "callsign": "VIV1373", "estimated": false, "last_seen": 1762483939}	2025-11-07 02:54:12.532921
86	0d0fec	XCNZA	19.4222	-99.0181	2225.04	22.74	52.35	1762484032	{"lat": 19.4222, "lon": -99.0181, "speed": 22.74, "icao24": "0d0fec", "heading": 52.35, "altitude": 2225.04, "callsign": "XCNZA", "estimated": false, "last_seen": 1762484032}	2025-11-07 02:54:12.532926
87	0d0fba	VIV1353	19.4415	-99.0681	\N	12.35	239.06	1762483791	{"lat": 19.4415, "lon": -99.0681, "speed": 12.35, "icao24": "0d0fba", "heading": 239.06, "altitude": null, "callsign": "VIV1353", "estimated": false, "last_seen": 1762483791}	2025-11-07 02:54:12.53293
88	a52c4f	UAL429	19.4408	-99.0687	\N	4.12	329.06	1762495358	{"lat": 19.4408, "lon": -99.0687, "speed": 4.12, "icao24": "a52c4f", "heading": 329.06, "altitude": null, "callsign": "UAL429", "estimated": false, "last_seen": 1762495358}	2025-11-07 06:04:53.11811
89	a52c4f	UAL429	19.4408	-99.0687	\N	4.12	329.06	1762495358	{"lat": 19.4408, "lon": -99.0687, "speed": 4.12, "icao24": "a52c4f", "heading": 329.06, "altitude": null, "callsign": "UAL429", "estimated": false, "last_seen": 1762495358}	2025-11-07 06:05:09.295974
90	a52c4f	UAL429	19.4408	-99.0687	\N	4.12	329.06	1762495358	{"lat": 19.4408, "lon": -99.0687, "speed": 4.12, "icao24": "a52c4f", "heading": 329.06, "altitude": null, "callsign": "UAL429", "estimated": false, "last_seen": 1762495358}	2025-11-07 06:05:25.77276
91	a52c4f	UAL429	19.4408	-99.0687	\N	4.12	329.06	1762495358	{"lat": 19.4408, "lon": -99.0687, "speed": 4.12, "icao24": "a52c4f", "heading": 329.06, "altitude": null, "callsign": "UAL429", "estimated": false, "last_seen": 1762495358}	2025-11-07 06:05:42.074838
92	0c21a5	CMP858	19.4382	-99.0739	\N	5.4	239.06	1762498631	{"lat": 19.4382, "lon": -99.0739, "speed": 5.4, "icao24": "0c21a5", "heading": 239.06, "altitude": null, "callsign": "CMP858", "estimated": false, "last_seen": 1762498631}	2025-11-07 07:00:48.546107
93	4cadab	MAA8352	19.2667	-98.9667	6080.76	216	170.4	1762498843	{"lat": 19.2667, "lon": -98.9667, "speed": 216, "icao24": "4cadab", "heading": 170.4, "altitude": 6080.76, "callsign": "MAA8352", "estimated": false, "last_seen": 1762498843}	2025-11-07 07:00:48.546122
94	0c21a5	CMP858	19.4382	-99.0739	\N	5.4	239.06	1762498631	{"lat": 19.4382, "lon": -99.0739, "speed": 5.4, "icao24": "0c21a5", "heading": 239.06, "altitude": null, "callsign": "CMP858", "estimated": false, "last_seen": 1762498631}	2025-11-07 07:01:05.088384
95	4cadab	MAA8352	19.2533	-98.9651	6134.1	216.63	174.28	1762498850	{"lat": 19.2533, "lon": -98.9651, "speed": 216.63, "icao24": "4cadab", "heading": 174.28, "altitude": 6134.1, "callsign": "MAA8352", "estimated": false, "last_seen": 1762498850}	2025-11-07 07:01:05.088396
96	0c21a5	CMP858	19.4382	-99.0739	\N	5.4	239.06	1762498631	{"lat": 19.4382, "lon": -99.0739, "speed": 5.4, "icao24": "0c21a5", "heading": 239.06, "altitude": null, "callsign": "CMP858", "estimated": false, "last_seen": 1762498631}	2025-11-07 07:01:21.360198
97	4cadab	MAA8352	19.2219	-98.9634	6271.26	218.37	177.3	1762498866	{"lat": 19.2219, "lon": -98.9634, "speed": 218.37, "icao24": "4cadab", "heading": 177.3, "altitude": 6271.26, "callsign": "MAA8352", "estimated": false, "last_seen": 1762498866}	2025-11-07 07:01:21.36021
98	0c21a5	CMP858	19.4382	-99.0739	\N	5.4	239.06	1762498631	{"lat": 19.4382, "lon": -99.0739, "speed": 5.4, "icao24": "0c21a5", "heading": 239.06, "altitude": null, "callsign": "CMP858", "estimated": false, "last_seen": 1762498631}	2025-11-07 07:02:25.534112
99	4cadab	MAA8352	19.1036	-98.9575	6697.98	226.1	177.26	1762498925	{"lat": 19.1036, "lon": -98.9575, "speed": 226.1, "icao24": "4cadab", "heading": 177.26, "altitude": 6697.98, "callsign": "MAA8352", "estimated": false, "last_seen": 1762498925}	2025-11-07 07:02:25.534123
100	a6b253	VOI9692	19.4428	-99.063	2491.74	82.95	60.26	1762498925	{"lat": 19.4428, "lon": -99.063, "speed": 82.95, "icao24": "a6b253", "heading": 60.26, "altitude": 2491.74, "callsign": "VOI9692", "estimated": false, "last_seen": 1762498925}	2025-11-07 07:02:25.534128
101	4cadab	MAA8352	19.0422	-98.9544	6865.62	231.26	177.19	1762498954	{"lat": 19.0422, "lon": -98.9544, "speed": 231.26, "icao24": "4cadab", "heading": 177.19, "altitude": 6865.62, "callsign": "MAA8352", "estimated": false, "last_seen": 1762498954}	2025-11-07 07:02:41.846771
102	a6b253	VOI9692	19.4549	-99.0402	2842.26	102.29	60.47	1762498955	{"lat": 19.4549, "lon": -99.0402, "speed": 102.29, "icao24": "a6b253", "heading": 60.47, "altitude": 2842.26, "callsign": "VOI9692", "estimated": false, "last_seen": 1762498955}	2025-11-07 07:02:41.846788
103	4cadab	MAA8352	18.9918	-98.9518	7086.6	231.78	177.2	1762498979	{"lat": 18.9918, "lon": -98.9518, "speed": 231.78, "icao24": "4cadab", "heading": 177.2, "altitude": 7086.6, "callsign": "MAA8352", "estimated": false, "last_seen": 1762498979}	2025-11-07 07:03:13.504262
104	a6b253	VOI9692	19.4669	-99.0184	3108.96	120.43	59.16	1762498978	{"lat": 19.4669, "lon": -99.0184, "speed": 120.43, "icao24": "a6b253", "heading": 59.16, "altitude": 3108.96, "callsign": "VOI9692", "estimated": false, "last_seen": 1762498978}	2025-11-07 07:03:13.504274
105	a6b253	VOI9692	19.5072	-98.9481	3901.44	159.16	59.29	1762499040	{"lat": 19.5072, "lon": -98.9481, "speed": 159.16, "icao24": "a6b253", "heading": 59.29, "altitude": 3901.44, "callsign": "VOI9692", "estimated": false, "last_seen": 1762499040}	2025-11-07 07:04:01.300672
106	78157d	CHH7925	19.5687	-99.2677	3947.16	123.99	143.61	1762499140	{"lat": 19.5687, "lon": -99.2677, "speed": 123.99, "icao24": "78157d", "heading": 143.61, "altitude": 3947.16, "callsign": "CHH7925", "estimated": false, "last_seen": 1762499140}	2025-11-07 07:05:54.858707
107	78157d	CHH7925	19.5687	-99.2677	3947.16	123.99	143.61	1762499140	{"lat": 19.5687, "lon": -99.2677, "speed": 123.99, "icao24": "78157d", "heading": 143.61, "altitude": 3947.16, "callsign": "CHH7925", "estimated": false, "last_seen": 1762499140}	2025-11-07 07:06:11.114288
108	78157d	CHH7925	19.4863	-99.2346	3436.62	110.11	178.93	1762499226	{"lat": 19.4863, "lon": -99.2346, "speed": 110.11, "icao24": "78157d", "heading": 178.93, "altitude": 3436.62, "callsign": "CHH7925", "estimated": false, "last_seen": 1762499226}	2025-11-07 07:07:14.31486
109	78157d	CHH7925	19.4654	-99.2342	3299.46	101.36	179.13	1762499248	{"lat": 19.4654, "lon": -99.2342, "speed": 101.36, "icao24": "78157d", "heading": 179.13, "altitude": 3299.46, "callsign": "CHH7925", "estimated": false, "last_seen": 1762499248}	2025-11-07 07:07:30.606398
110	78157d	CHH7925	19.4517	-99.234	3200.4	99.29	179.41	1762499263	{"lat": 19.4517, "lon": -99.234, "speed": 99.29, "icao24": "78157d", "heading": 179.41, "altitude": 3200.4, "callsign": "CHH7925", "estimated": false, "last_seen": 1762499263}	2025-11-07 07:07:46.945735
111	0d111a	VOI261	19.3651	-99.1901	2689.86	96.86	26.84	1762502569	{"lat": 19.3651, "lon": -99.1901, "speed": 96.86, "icao24": "0d111a", "heading": 26.84, "altitude": 2689.86, "callsign": "VOI261", "estimated": false, "last_seen": 1762502569}	2025-11-07 08:03:02.756427
112	0d09d0	AMX026	19.4422	-99.0644	\N	10.29	53.44	1762502569	{"lat": 19.4422, "lon": -99.0644, "speed": 10.29, "icao24": "0d09d0", "heading": 53.44, "altitude": null, "callsign": "AMX026", "estimated": false, "last_seen": 1762502569}	2025-11-07 08:03:02.75644
113	a3cff5	AVA234	19.1972	-99.031	4099.56	135.7	315.77	1762502570	{"lat": 19.1972, "lon": -99.031, "speed": 135.7, "icao24": "a3cff5", "heading": 315.77, "altitude": 4099.56, "callsign": "AVA234", "estimated": false, "last_seen": 1762502570}	2025-11-07 08:03:02.756446
114	0d111a	VOI261	19.3743	-99.1827	2621.28	94.98	46.54	1762502584	{"lat": 19.3743, "lon": -99.1827, "speed": 94.98, "icao24": "0d111a", "heading": 46.54, "altitude": 2621.28, "callsign": "VOI261", "estimated": false, "last_seen": 1762502584}	2025-11-07 08:03:19.14105
115	0d09d0	AMX026	19.4427	-99.0636	\N	5.14	59.06	1762502584	{"lat": 19.4427, "lon": -99.0636, "speed": 5.14, "icao24": "0d09d0", "heading": 59.06, "altitude": null, "callsign": "AMX026", "estimated": false, "last_seen": 1762502584}	2025-11-07 08:03:19.141062
116	a3cff5	AVA234	19.2095	-99.0436	4000.5	135.34	315.92	1762502584	{"lat": 19.2095, "lon": -99.0436, "speed": 135.34, "icao24": "a3cff5", "heading": 315.92, "altitude": 4000.5, "callsign": "AVA234", "estimated": false, "last_seen": 1762502584}	2025-11-07 08:03:19.141067
117	0d111a	VOI261	19.3859	-99.1637	2598.42	94.06	59.79	1762502608	{"lat": 19.3859, "lon": -99.1637, "speed": 94.06, "icao24": "0d111a", "heading": 59.79, "altitude": 2598.42, "callsign": "VOI261", "estimated": false, "last_seen": 1762502608}	2025-11-07 08:03:35.390772
118	0d09d0	AMX026	19.4421	-99.0634	\N	3.34	188.44	1762502605	{"lat": 19.4421, "lon": -99.0634, "speed": 3.34, "icao24": "0d09d0", "heading": 188.44, "altitude": null, "callsign": "AMX026", "estimated": false, "last_seen": 1762502605}	2025-11-07 08:03:35.390784
119	a3cff5	AVA234	19.2312	-99.0654	3810	135.02	316.7	1762502608	{"lat": 19.2312, "lon": -99.0654, "speed": 135.02, "icao24": "a3cff5", "heading": 316.7, "altitude": 3810, "callsign": "AVA234", "estimated": false, "last_seen": 1762502608}	2025-11-07 08:03:35.39079
120	0acac1	AVA044	19.1825	-99.0218	4145.28	126.05	347.27	1762504945	{"lat": 19.1825, "lon": -99.0218, "speed": 126.05, "icao24": "0acac1", "heading": 347.27, "altitude": 4145.28, "callsign": "AVA044", "estimated": false, "last_seen": 1762504945}	2025-11-07 08:42:27.173696
121	0d0a18	VOI185	19.405	-99.2322	3025.14	112.09	169.15	1762504944	{"lat": 19.405, "lon": -99.2322, "speed": 112.09, "icao24": "0d0a18", "heading": 169.15, "altitude": 3025.14, "callsign": "VOI185", "estimated": false, "last_seen": 1762504944}	2025-11-07 08:42:27.173709
122	0acac1	AVA044	19.2067	-99.0402	3939.54	129.14	315.16	1762504971	{"lat": 19.2067, "lon": -99.0402, "speed": 129.14, "icao24": "0acac1", "heading": 315.16, "altitude": 3939.54, "callsign": "AVA044", "estimated": false, "last_seen": 1762504971}	2025-11-07 08:42:59.860964
123	0d0a18	VOI185	19.3826	-99.2177	2827.02	113.44	128.74	1762504971	{"lat": 19.3826, "lon": -99.2177, "speed": 113.44, "icao24": "0d0a18", "heading": 128.74, "altitude": 2827.02, "callsign": "VOI185", "estimated": false, "last_seen": 1762504971}	2025-11-07 08:42:59.860976
124	0acac1	AVA044	19.2239	-99.0578	3825.24	125.54	316.49	1762504992	{"lat": 19.2239, "lon": -99.0578, "speed": 125.54, "icao24": "0acac1", "heading": 316.49, "altitude": 3825.24, "callsign": "AVA044", "estimated": false, "last_seen": 1762504992}	2025-11-07 08:43:16.123115
125	0d0a18	VOI185	19.3756	-99.1989	2758.44	107.92	94.92	1762504991	{"lat": 19.3756, "lon": -99.1989, "speed": 107.92, "icao24": "0d0a18", "heading": 94.92, "altitude": 2758.44, "callsign": "VOI185", "estimated": false, "last_seen": 1762504991}	2025-11-07 08:43:16.123123
126	0acac1	AVA044	19.2369	-99.0706	3733.8	124.46	316.67	1762505008	{"lat": 19.2369, "lon": -99.0706, "speed": 124.46, "icao24": "0acac1", "heading": 316.67, "altitude": 3733.8, "callsign": "AVA044", "estimated": false, "last_seen": 1762505008}	2025-11-07 08:43:32.442855
127	0d0a18	VOI185	19.3776	-99.1817	2689.86	103.31	72.02	1762505007	{"lat": 19.3776, "lon": -99.1817, "speed": 103.31, "icao24": "0d0a18", "heading": 72.02, "altitude": 2689.86, "callsign": "VOI185", "estimated": false, "last_seen": 1762505007}	2025-11-07 08:43:32.442867
128	0acac1	AVA044	19.2479	-99.0837	3680.46	123.18	307.87	1762505023	{"lat": 19.2479, "lon": -99.0837, "speed": 123.18, "icao24": "0acac1", "heading": 307.87, "altitude": 3680.46, "callsign": "AVA044", "estimated": false, "last_seen": 1762505023}	2025-11-07 08:43:48.723424
129	0d0a18	VOI185	19.3837	-99.1694	2644.14	96.87	59.35	1762505022	{"lat": 19.3837, "lon": -99.1694, "speed": 96.87, "icao24": "0d0a18", "heading": 59.35, "altitude": 2644.14, "callsign": "VOI185", "estimated": false, "last_seen": 1762505022}	2025-11-07 08:43:48.723436
130	0acac1	AVA044	19.2595	-99.0999	3596.64	114.93	307.18	1762505041	{"lat": 19.2595, "lon": -99.0999, "speed": 114.93, "icao24": "0acac1", "heading": 307.18, "altitude": 3596.64, "callsign": "AVA044", "estimated": false, "last_seen": 1762505041}	2025-11-07 08:44:04.805703
131	0d0a18	VOI185	19.3917	-99.1556	2598.42	89.55	58.87	1762505041	{"lat": 19.3917, "lon": -99.1556, "speed": 89.55, "icao24": "0d0a18", "heading": 58.87, "altitude": 2598.42, "callsign": "VOI185", "estimated": false, "last_seen": 1762505041}	2025-11-07 08:44:04.805715
132	0acac1	AVA044	19.2795	-99.1274	3215.64	118.13	307.57	1762505072	{"lat": 19.2795, "lon": -99.1274, "speed": 118.13, "icao24": "0acac1", "heading": 307.57, "altitude": 3215.64, "callsign": "AVA044", "estimated": false, "last_seen": 1762505072}	2025-11-07 08:44:36.855548
133	0d0a18	VOI185	19.4041	-99.1326	2438.4	87.04	61.01	1762505072	{"lat": 19.4041, "lon": -99.1326, "speed": 87.04, "icao24": "0d0a18", "heading": 61.01, "altitude": 2438.4, "callsign": "VOI185", "estimated": false, "last_seen": 1762505072}	2025-11-07 08:44:36.855557
134	0acac1	AVA044	19.2901	-99.1419	3040.38	117.4	307.52	1762505088	{"lat": 19.2901, "lon": -99.1419, "speed": 117.4, "icao24": "0acac1", "heading": 307.52, "altitude": 3040.38, "callsign": "AVA044", "estimated": false, "last_seen": 1762505088}	2025-11-07 08:44:53.021949
135	0d0a18	VOI185	19.4104	-99.1211	2369.82	85.84	58.98	1762505088	{"lat": 19.4104, "lon": -99.1211, "speed": 85.84, "icao24": "0d0a18", "heading": 58.98, "altitude": 2369.82, "callsign": "VOI185", "estimated": false, "last_seen": 1762505088}	2025-11-07 08:44:53.021967
136	0acac1	AVA044	19.3092	-99.1684	2933.7	109.78	307.19	1762505119	{"lat": 19.3092, "lon": -99.1684, "speed": 109.78, "icao24": "0acac1", "heading": 307.19, "altitude": 2933.7, "callsign": "AVA044", "estimated": false, "last_seen": 1762505119}	2025-11-07 08:45:24.464684
137	0d0a18	VOI185	19.4213	-99.1016	2232.66	83.47	59.64	1762505116	{"lat": 19.4213, "lon": -99.1016, "speed": 83.47, "icao24": "0d0a18", "heading": 59.64, "altitude": 2232.66, "callsign": "VOI185", "estimated": false, "last_seen": 1762505116}	2025-11-07 08:45:24.464696
138	0acac1	AVA044	19.3208	-99.1836	2903.22	109.19	313.09	1762505137	{"lat": 19.3208, "lon": -99.1836, "speed": 109.19, "icao24": "0acac1", "heading": 313.09, "altitude": 2903.22, "callsign": "AVA044", "estimated": false, "last_seen": 1762505137}	2025-11-07 08:45:40.701937
139	0d0a18	VOI185	19.4213	-99.1016	2232.66	83.47	59.64	1762505116	{"lat": 19.4213, "lon": -99.1016, "speed": 83.47, "icao24": "0d0a18", "heading": 59.64, "altitude": 2232.66, "callsign": "VOI185", "estimated": false, "last_seen": 1762505116}	2025-11-07 08:45:40.70195
140	0acac1	AVA044	19.3298	-99.1907	2849.88	106.43	330.46	1762505149	{"lat": 19.3298, "lon": -99.1907, "speed": 106.43, "icao24": "0acac1", "heading": 330.46, "altitude": 2849.88, "callsign": "AVA044", "estimated": false, "last_seen": 1762505149}	2025-11-07 08:45:57.218536
141	0d0a18	VOI185	19.4213	-99.1016	2232.66	83.47	59.64	1762505116	{"lat": 19.4213, "lon": -99.1016, "speed": 83.47, "icao24": "0d0a18", "heading": 59.64, "altitude": 2232.66, "callsign": "VOI185", "estimated": false, "last_seen": 1762505116}	2025-11-07 08:45:57.218549
142	0acac1	AVA044	19.3613	-99.1918	2705.1	101.19	18.99	1762505184	{"lat": 19.3613, "lon": -99.1918, "speed": 101.19, "icao24": "0acac1", "heading": 18.99, "altitude": 2705.1, "callsign": "AVA044", "estimated": false, "last_seen": 1762505184}	2025-11-07 08:46:29.602537
143	0d0a18	VOI185	19.4399	-99.0686	\N	6.43	59.06	1762505183	{"lat": 19.4399, "lon": -99.0686, "speed": 6.43, "icao24": "0d0a18", "heading": 59.06, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505183}	2025-11-07 08:46:29.602548
144	0acac1	AVA044	19.3779	-99.1776	2606.04	92.19	52.94	1762505209	{"lat": 19.3779, "lon": -99.1776, "speed": 92.19, "icao24": "0acac1", "heading": 52.94, "altitude": 2606.04, "callsign": "AVA044", "estimated": false, "last_seen": 1762505209}	2025-11-07 08:47:02.222472
145	0d0a18	VOI185	19.4408	-99.0687	\N	3.86	329.06	1762505207	{"lat": 19.4408, "lon": -99.0687, "speed": 3.86, "icao24": "0d0a18", "heading": 329.06, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505207}	2025-11-07 08:47:02.222484
146	0acac1	AVA044	19.3944	-99.1486	2560.32	86.38	58.39	1762505250	{"lat": 19.3944, "lon": -99.1486, "speed": 86.38, "icao24": "0acac1", "heading": 58.39, "altitude": 2560.32, "callsign": "AVA044", "estimated": false, "last_seen": 1762505250}	2025-11-07 08:47:34.710384
147	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:47:34.710393
148	0acac1	AVA044	19.4006	-99.138	2484.12	84.26	58.74	1762505265	{"lat": 19.4006, "lon": -99.138, "speed": 84.26, "icao24": "0acac1", "heading": 58.74, "altitude": 2484.12, "callsign": "AVA044", "estimated": false, "last_seen": 1762505265}	2025-11-07 08:47:50.8365
149	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:47:50.836509
150	0acac1	AVA044	19.4133	-99.1157	2331.72	82.4	58.79	1762505298	{"lat": 19.4133, "lon": -99.1157, "speed": 82.4, "icao24": "0acac1", "heading": 58.79, "altitude": 2331.72, "callsign": "AVA044", "estimated": false, "last_seen": 1762505298}	2025-11-07 08:48:23.1206
151	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:48:23.120617
152	0acac1	AVA044	19.4225	-99.0995	2217.42	80.21	59.98	1762505322	{"lat": 19.4225, "lon": -99.0995, "speed": 80.21, "icao24": "0acac1", "heading": 59.98, "altitude": 2217.42, "callsign": "AVA044", "estimated": false, "last_seen": 1762505322}	2025-11-07 08:48:54.602695
153	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:48:54.60271
154	0acac1	AVA044	19.4279	-99.09	2148.84	79.32	59.61	1762505338	{"lat": 19.4279, "lon": -99.09, "speed": 79.32, "icao24": "0acac1", "heading": 59.61, "altitude": 2148.84, "callsign": "AVA044", "estimated": false, "last_seen": 1762505338}	2025-11-07 08:49:10.930162
155	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:49:10.930173
156	0acac1	AVA044	19.4395	-99.0693	\N	29.84	61.88	1762505381	{"lat": 19.4395, "lon": -99.0693, "speed": 29.84, "icao24": "0acac1", "heading": 61.88, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505381}	2025-11-07 08:49:43.024776
157	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:49:43.024789
158	0acac1	AVA044	19.4419	-99.0667	\N	3.6	2.81	1762505411	{"lat": 19.4419, "lon": -99.0667, "speed": 3.6, "icao24": "0acac1", "heading": 2.81, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505411}	2025-11-07 08:50:14.683822
159	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:50:14.683831
160	0acac1	AVA044	19.442	-99.067	\N	3.6	284.06	1762505422	{"lat": 19.442, "lon": -99.067, "speed": 3.6, "icao24": "0acac1", "heading": 284.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505422}	2025-11-07 08:50:31.065817
161	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:50:31.065829
162	0acac1	AVA044	19.4417	-99.0677	\N	3.86	241.88	1762505443	{"lat": 19.4417, "lon": -99.0677, "speed": 3.86, "icao24": "0acac1", "heading": 241.88, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505443}	2025-11-07 08:50:47.324967
163	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:50:47.324981
164	0acac1	AVA044	19.4414	-99.0683	\N	4.37	239.06	1762505459	{"lat": 19.4414, "lon": -99.0683, "speed": 4.37, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505459}	2025-11-07 08:51:19.546932
165	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:51:19.546947
166	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:51:35.964382
167	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:51:35.964394
168	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:51:52.237692
169	0d0a18	VOI185	19.4409	-99.0691	\N	3.86	278.44	1762505220	{"lat": 19.4409, "lon": -99.0691, "speed": 3.86, "icao24": "0d0a18", "heading": 278.44, "altitude": null, "callsign": "VOI185", "estimated": false, "last_seen": 1762505220}	2025-11-07 08:51:52.237703
170	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:52:24.730444
171	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:52:41.128004
172	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:52:57.795134
173	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:53:29.653137
174	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:53:45.895485
175	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:54:02.20787
176	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:54:18.539554
177	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:54:35.172909
178	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:54:51.516041
179	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:55:23.293535
180	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:55:39.525107
181	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:55:55.755067
182	0acac1	AVA044	19.441	-99.0689	\N	4.89	239.06	1762505475	{"lat": 19.441, "lon": -99.0689, "speed": 4.89, "icao24": "0acac1", "heading": 239.06, "altitude": null, "callsign": "AVA044", "estimated": false, "last_seen": 1762505475}	2025-11-07 08:56:28.153204
183	0d112c	AMX208	19.3679	-99.1457	5135.88	173.53	258.89	1762525109	{"lat": 19.3679, "lon": -99.1457, "speed": 173.53, "icao24": "0d112c", "heading": 258.89, "altitude": 5135.88, "callsign": "AMX208", "estimated": false, "last_seen": 1762525109}	2025-11-07 14:18:33.97049
184	0d03f3	SLI2441	19.4347	-99.0721	2095.5	73.32	59.66	1762525037	{"lat": 19.4347, "lon": -99.0721, "speed": 73.32, "icao24": "0d03f3", "heading": 59.66, "altitude": 2095.5, "callsign": "SLI2441", "estimated": false, "last_seen": 1762525037}	2025-11-07 14:18:33.970502
185	0d0e21	AMX508	19.4831	-98.9913	2750.82	121.31	59.41	1762525109	{"lat": 19.4831, "lon": -98.9913, "speed": 121.31, "icao24": "0d0e21", "heading": 59.41, "altitude": 2750.82, "callsign": "AMX508", "estimated": false, "last_seen": 1762525109}	2025-11-07 14:18:33.970508
186	0d0bba	AMX057	19.4402	-99.0644	\N	2.31	202.5	1762525101	{"lat": 19.4402, "lon": -99.0644, "speed": 2.31, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525101}	2025-11-07 14:18:33.970513
187	ad6b0e	AMX034	19.447	-99.0559	2316.48	90.29	60.66	1762525108	{"lat": 19.447, "lon": -99.0559, "speed": 90.29, "icao24": "ad6b0e", "heading": 60.66, "altitude": 2316.48, "callsign": "AMX034", "estimated": false, "last_seen": 1762525108}	2025-11-07 14:18:33.970518
188	0d112c	AMX208	19.3611	-99.1821	5402.58	173.13	258.69	1762525131	{"lat": 19.3611, "lon": -99.1821, "speed": 173.13, "icao24": "0d112c", "heading": 258.69, "altitude": 5402.58, "callsign": "AMX208", "estimated": false, "last_seen": 1762525131}	2025-11-07 14:19:06.503752
189	0d03f3	SLI2441	19.4347	-99.0721	2095.5	73.32	59.66	1762525037	{"lat": 19.4347, "lon": -99.0721, "speed": 73.32, "icao24": "0d03f3", "heading": 59.66, "altitude": 2095.5, "callsign": "SLI2441", "estimated": false, "last_seen": 1762525037}	2025-11-07 14:19:06.503763
190	0d0e21	AMX508	19.4954	-98.9696	2948.94	121.58	59.2	1762525131	{"lat": 19.4954, "lon": -98.9696, "speed": 121.58, "icao24": "0d0e21", "heading": 59.2, "altitude": 2948.94, "callsign": "AMX508", "estimated": false, "last_seen": 1762525131}	2025-11-07 14:19:06.503768
191	0d0bba	AMX057	19.4394	-99.0649	\N	4.37	202.5	1762525126	{"lat": 19.4394, "lon": -99.0649, "speed": 4.37, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525126}	2025-11-07 14:19:06.503773
192	ad6b0e	AMX034	19.4559	-99.0396	2545.08	91.32	59.53	1762525131	{"lat": 19.4559, "lon": -99.0396, "speed": 91.32, "icao24": "ad6b0e", "heading": 59.53, "altitude": 2545.08, "callsign": "AMX034", "estimated": false, "last_seen": 1762525131}	2025-11-07 14:19:06.503778
193	0d112c	AMX208	19.3468	-99.2592	5608.32	190.79	258.96	1762525176	{"lat": 19.3468, "lon": -99.2592, "speed": 190.79, "icao24": "0d112c", "heading": 258.96, "altitude": 5608.32, "callsign": "AMX208", "estimated": false, "last_seen": 1762525176}	2025-11-07 14:19:38.730663
194	0d03f3	SLI2441	19.4347	-99.0721	2095.5	73.32	59.66	1762525037	{"lat": 19.4347, "lon": -99.0721, "speed": 73.32, "icao24": "0d03f3", "heading": 59.66, "altitude": 2095.5, "callsign": "SLI2441", "estimated": false, "last_seen": 1762525037}	2025-11-07 14:19:38.730675
195	0d0e21	AMX508	19.5228	-98.9212	3200.4	136.05	59.56	1762525177	{"lat": 19.5228, "lon": -98.9212, "speed": 136.05, "icao24": "0d0e21", "heading": 59.56, "altitude": 3200.4, "callsign": "AMX508", "estimated": false, "last_seen": 1762525177}	2025-11-07 14:19:38.730681
196	0d0bba	AMX057	19.4391	-99.0651	\N	5.14	202.5	1762525135	{"lat": 19.4391, "lon": -99.0651, "speed": 5.14, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525135}	2025-11-07 14:19:38.730685
197	ad6b0e	AMX034	19.4757	-99.0044	2994.66	94.58	59.25	1762525176	{"lat": 19.4757, "lon": -99.0044, "speed": 94.58, "icao24": "ad6b0e", "heading": 59.25, "altitude": 2994.66, "callsign": "AMX034", "estimated": false, "last_seen": 1762525176}	2025-11-07 14:19:38.730691
198	0d112c	AMX208	19.3415	-99.2877	5676.9	196.03	258.96	1762525192	{"lat": 19.3415, "lon": -99.2877, "speed": 196.03, "icao24": "0d112c", "heading": 258.96, "altitude": 5676.9, "callsign": "AMX208", "estimated": false, "last_seen": 1762525192}	2025-11-07 14:19:55.26896
199	0d03f3	SLI2441	19.4347	-99.0721	2095.5	73.32	59.66	1762525037	{"lat": 19.4347, "lon": -99.0721, "speed": 73.32, "icao24": "0d03f3", "heading": 59.66, "altitude": 2095.5, "callsign": "SLI2441", "estimated": false, "last_seen": 1762525037}	2025-11-07 14:19:55.268972
200	0d0e21	AMX508	19.5317	-98.9028	3291.84	143.61	67.02	1762525192	{"lat": 19.5317, "lon": -98.9028, "speed": 143.61, "icao24": "0d0e21", "heading": 67.02, "altitude": 3291.84, "callsign": "AMX508", "estimated": false, "last_seen": 1762525192}	2025-11-07 14:19:55.268977
201	0d0bba	AMX057	19.4391	-99.0651	\N	5.14	202.5	1762525135	{"lat": 19.4391, "lon": -99.0651, "speed": 5.14, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525135}	2025-11-07 14:19:55.268982
202	ad6b0e	AMX034	19.4829	-98.9919	3139.44	96.52	58.51	1762525192	{"lat": 19.4829, "lon": -98.9919, "speed": 96.52, "icao24": "ad6b0e", "heading": 58.51, "altitude": 3139.44, "callsign": "AMX034", "estimated": false, "last_seen": 1762525192}	2025-11-07 14:19:55.268986
203	0d112c	AMX208	19.3364	-99.3149	5814.06	196.64	258.84	1762525210	{"lat": 19.3364, "lon": -99.3149, "speed": 196.64, "icao24": "0d112c", "heading": 258.84, "altitude": 5814.06, "callsign": "AMX208", "estimated": false, "last_seen": 1762525210}	2025-11-07 14:20:11.941511
204	0d03f3	SLI2441	19.4347	-99.0721	2095.5	73.32	59.66	1762525037	{"lat": 19.4347, "lon": -99.0721, "speed": 73.32, "icao24": "0d03f3", "heading": 59.66, "altitude": 2095.5, "callsign": "SLI2441", "estimated": false, "last_seen": 1762525037}	2025-11-07 14:20:11.941523
205	0d0bba	AMX057	19.4391	-99.0651	\N	5.14	202.5	1762525135	{"lat": 19.4391, "lon": -99.0651, "speed": 5.14, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525135}	2025-11-07 14:20:11.941527
206	a2d68d	N282MS	18.9624	-99.263	5890.26	164.1	148.85	1762525209	{"lat": 18.9624, "lon": -99.263, "speed": 164.1, "icao24": "a2d68d", "heading": 148.85, "altitude": 5890.26, "callsign": "N282MS", "estimated": false, "last_seen": 1762525209}	2025-11-07 14:20:11.941532
207	ad6b0e	AMX034	19.4913	-98.9774	3208.02	109.4	58.85	1762525210	{"lat": 19.4913, "lon": -98.9774, "speed": 109.4, "icao24": "ad6b0e", "heading": 58.85, "altitude": 3208.02, "callsign": "AMX034", "estimated": false, "last_seen": 1762525210}	2025-11-07 14:20:11.941537
208	0d112c	AMX208	19.3202	-99.4028	6248.4	199.16	258.98	1762525255	{"lat": 19.3202, "lon": -99.4028, "speed": 199.16, "icao24": "0d112c", "heading": 258.98, "altitude": 6248.4, "callsign": "AMX208", "estimated": false, "last_seen": 1762525255}	2025-11-07 14:20:59.359368
209	0d03f3	SLI2441	19.4347	-99.0721	2095.5	73.32	59.66	1762525037	{"lat": 19.4347, "lon": -99.0721, "speed": 73.32, "icao24": "0d03f3", "heading": 59.66, "altitude": 2095.5, "callsign": "SLI2441", "estimated": false, "last_seen": 1762525037}	2025-11-07 14:20:59.35938
210	0d0bba	AMX057	19.4391	-99.0651	\N	5.14	202.5	1762525135	{"lat": 19.4391, "lon": -99.0651, "speed": 5.14, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525135}	2025-11-07 14:20:59.359385
211	a2d68d	N282MS	18.9043	-99.226	6217.92	167.37	148.7	1762525254	{"lat": 18.9043, "lon": -99.226, "speed": 167.37, "icao24": "a2d68d", "heading": 148.7, "altitude": 6217.92, "callsign": "N282MS", "estimated": false, "last_seen": 1762525254}	2025-11-07 14:20:59.35939
212	ad6b0e	AMX034	19.5171	-98.9314	3429	139.31	59.36	1762525254	{"lat": 19.5171, "lon": -98.9314, "speed": 139.31, "icao24": "ad6b0e", "heading": 59.36, "altitude": 3429, "callsign": "AMX034", "estimated": false, "last_seen": 1762525254}	2025-11-07 14:20:59.359395
213	0d112c	AMX208	19.3198	-99.4048	6256.02	199.16	258.98	1762525256	{"lat": 19.3198, "lon": -99.4048, "speed": 199.16, "icao24": "0d112c", "heading": 258.98, "altitude": 6256.02, "callsign": "AMX208", "estimated": false, "last_seen": 1762525256}	2025-11-07 14:21:15.746505
214	0d03f3	SLI2441	19.4347	-99.0721	2095.5	73.32	59.66	1762525037	{"lat": 19.4347, "lon": -99.0721, "speed": 73.32, "icao24": "0d03f3", "heading": 59.66, "altitude": 2095.5, "callsign": "SLI2441", "estimated": false, "last_seen": 1762525037}	2025-11-07 14:21:15.746514
215	0d0bba	AMX057	19.4391	-99.0651	\N	5.14	202.5	1762525135	{"lat": 19.4391, "lon": -99.0651, "speed": 5.14, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525135}	2025-11-07 14:21:15.746517
216	ad6b0e	AMX034	19.5202	-98.9257	3459.48	143.02	59.28	1762525260	{"lat": 19.5202, "lon": -98.9257, "speed": 143.02, "icao24": "ad6b0e", "heading": 59.28, "altitude": 3459.48, "callsign": "AMX034", "estimated": false, "last_seen": 1762525260}	2025-11-07 14:21:15.746521
217	0d111a	VOI370	19.4507	-99.0492	2529.84	87.55	60.42	1762525289	{"lat": 19.4507, "lon": -99.0492, "speed": 87.55, "icao24": "0d111a", "heading": 60.42, "altitude": 2529.84, "callsign": "VOI370", "estimated": false, "last_seen": 1762525289}	2025-11-07 14:21:32.121225
218	0d112c	AMX208	19.3113	-99.4504	6431.28	202.39	258.86	1762525280	{"lat": 19.3113, "lon": -99.4504, "speed": 202.39, "icao24": "0d112c", "heading": 258.86, "altitude": 6431.28, "callsign": "AMX208", "estimated": false, "last_seen": 1762525280}	2025-11-07 14:21:32.121237
219	0d03f3	SLI2441	19.4347	-99.0721	2095.5	73.32	59.66	1762525037	{"lat": 19.4347, "lon": -99.0721, "speed": 73.32, "icao24": "0d03f3", "heading": 59.66, "altitude": 2095.5, "callsign": "SLI2441", "estimated": false, "last_seen": 1762525037}	2025-11-07 14:21:32.121242
220	0d0bba	AMX057	19.4391	-99.0651	\N	5.14	202.5	1762525135	{"lat": 19.4391, "lon": -99.0651, "speed": 5.14, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525135}	2025-11-07 14:21:32.121247
221	0d111a	VOI370	19.4658	-99.0212	2819.4	102.23	61.11	1762525325	{"lat": 19.4658, "lon": -99.0212, "speed": 102.23, "icao24": "0d111a", "heading": 61.11, "altitude": 2819.4, "callsign": "VOI370", "estimated": false, "last_seen": 1762525325}	2025-11-07 14:22:18.924132
222	0d112c	AMX208	19.2999	-99.5115	6652.26	207.13	258.83	1762525317	{"lat": 19.2999, "lon": -99.5115, "speed": 207.13, "icao24": "0d112c", "heading": 258.83, "altitude": 6652.26, "callsign": "AMX208", "estimated": false, "last_seen": 1762525317}	2025-11-07 14:22:18.924141
223	0d03f3	SLI2441	19.4347	-99.0721	2095.5	73.32	59.66	1762525037	{"lat": 19.4347, "lon": -99.0721, "speed": 73.32, "icao24": "0d03f3", "heading": 59.66, "altitude": 2095.5, "callsign": "SLI2441", "estimated": false, "last_seen": 1762525037}	2025-11-07 14:22:18.924144
224	0d0bba	AMX057	19.4391	-99.0651	\N	5.14	202.5	1762525135	{"lat": 19.4391, "lon": -99.0651, "speed": 5.14, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525135}	2025-11-07 14:22:18.924148
225	0d111a	VOI370	19.4881	-98.9819	3139.44	122.91	58.17	1762525368	{"lat": 19.4881, "lon": -98.9819, "speed": 122.91, "icao24": "0d111a", "heading": 58.17, "altitude": 3139.44, "callsign": "VOI370", "estimated": false, "last_seen": 1762525368}	2025-11-07 14:22:50.912643
226	0d0a0d	VOI750	19.4505	-99.0505	2476.5	95.02	59.41	1762525367	{"lat": 19.4505, "lon": -99.0505, "speed": 95.02, "icao24": "0d0a0d", "heading": 59.41, "altitude": 2476.5, "callsign": "VOI750", "estimated": false, "last_seen": 1762525367}	2025-11-07 14:22:50.912652
227	0d0bba	AMX057	19.4391	-99.0651	\N	5.14	202.5	1762525135	{"lat": 19.4391, "lon": -99.0651, "speed": 5.14, "icao24": "0d0bba", "heading": 202.5, "altitude": null, "callsign": "AMX057", "estimated": false, "last_seen": 1762525135}	2025-11-07 14:22:50.912655
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

