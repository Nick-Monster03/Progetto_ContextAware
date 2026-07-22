--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4 (Debian 15.4-1.pgdg110+1)
-- Dumped by pg_dump version 15.4 (Debian 15.4-1.pgdg110+1)

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
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: postgres
--




--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: postgres
--




--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--




--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: postgres
--



--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agenda_utente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agenda_utente (
    id integer NOT NULL,
    id_utente integer NOT NULL,
    id_poi integer NOT NULL,
    titolo character varying(150) NOT NULL,
    orario_inizio timestamp with time zone NOT NULL,
    orario_fine timestamp with time zone NOT NULL,
    CONSTRAINT chk_orario_validi CHECK ((orario_fine > orario_inizio))
);


ALTER TABLE public.agenda_utente OWNER TO postgres;

--
-- Name: agenda_utente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agenda_utente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.agenda_utente_id_seq OWNER TO postgres;

--
-- Name: agenda_utente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agenda_utente_id_seq OWNED BY public.agenda_utente.id;


--
-- Name: categoria_poi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria_poi (
    id integer NOT NULL,
    nome character varying(50) NOT NULL,
    CONSTRAINT categoria_poi_nome_check CHECK (((nome)::text = ANY (ARRAY[('biblioteca'::character varying)::text, ('sala_studio'::character varying)::text, ('mensa'::character varying)::text, ('ufficio'::character varying)::text, ('segreteria'::character varying)::text, ('fermata'::character varying)::text, ('noleggio_bici'::character varying)::text, ('stazione'::character varying)::text, ('benzinaio'::character varying)::text])))
);


ALTER TABLE public.categoria_poi OWNER TO postgres;

--
-- Name: categoria_poi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categoria_poi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categoria_poi_id_seq OWNER TO postgres;

--
-- Name: categoria_poi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categoria_poi_id_seq OWNED BY public.categoria_poi.id;


--
-- Name: evento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evento (
    id integer NOT NULL,
    id_utente integer NOT NULL,
    id_poi integer,
    tipo character varying(50) NOT NULL,
    messaggio text,
    feedback character varying(20),
    motivo text,
    time_stamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    posizione_utente_reale public.geometry(Point,4326),
    CONSTRAINT evento_feedback_check CHECK (((feedback)::text = ANY (ARRAY[('Utile'::character varying)::text, ('Non Utile'::character varying)::text]))),
    CONSTRAINT evento_tipo_check CHECK (((tipo)::text = ANY (ARRAY[('Avviso_agenda'::character varying)::text, ('Suggerimento'::character varying)::text, ('poi_selezionato'::character varying)::text, ('geofencing_enter'::character varying)::text, ('geofencing_exit'::character varying)::text])))
);


ALTER TABLE public.evento OWNER TO postgres;

--
-- Name: evento_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.evento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.evento_id_seq OWNER TO postgres;

--
-- Name: evento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.evento_id_seq OWNED BY public.evento.id;


--
-- Name: orario_poi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orario_poi (
    id integer NOT NULL,
    id_poi integer NOT NULL,
    giorno integer NOT NULL,
    orario_apertura time without time zone NOT NULL,
    orario_chiusura time without time zone NOT NULL,
    CONSTRAINT orario_poi_giorno_check CHECK (((giorno >= 0) AND (giorno <= 6)))
);


ALTER TABLE public.orario_poi OWNER TO postgres;

--
-- Name: orario_poi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orario_poi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orario_poi_id_seq OWNER TO postgres;

--
-- Name: orario_poi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orario_poi_id_seq OWNED BY public.orario_poi.id;


--
-- Name: poi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.poi (
    id integer NOT NULL,
    nome character varying(150) NOT NULL,
    id_categoria integer NOT NULL,
    descrizione text,
    geometria public.geometry(Geometry,4326) NOT NULL,
    campus character varying(100)
);


ALTER TABLE public.poi OWNER TO postgres;

--
-- Name: poi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.poi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poi_id_seq OWNER TO postgres;

--
-- Name: poi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.poi_id_seq OWNED BY public.poi.id;


--
-- Name: preferenza_utente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preferenza_utente (
    id_utente integer NOT NULL,
    id_categoria integer NOT NULL
);


ALTER TABLE public.preferenza_utente OWNER TO postgres;

--
-- Name: utente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utente (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    cognome character varying(100) NOT NULL,
    campus character varying(100),
    mezzo_di_spostamento character varying(50) DEFAULT 'A PIEDI'::character varying,
    password character varying(100) DEFAULT '123'::character varying NOT NULL,
    CONSTRAINT utente_mezzo_di_spostamento_check CHECK (((mezzo_di_spostamento)::text = ANY (ARRAY[('A PIEDI'::character varying)::text, ('BICI A NOLEGGIO'::character varying)::text, ('AUTOBUS'::character varying)::text, ('TRENO'::character varying)::text, ('MOTO'::character varying)::text, ('AUTO'::character varying)::text, ('ALTRO'::character varying)::text])))
);


ALTER TABLE public.utente OWNER TO postgres;

--
-- Name: utente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.utente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.utente_id_seq OWNER TO postgres;

--
-- Name: utente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.utente_id_seq OWNED BY public.utente.id;


--
-- Name: agenda_utente id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda_utente ALTER COLUMN id SET DEFAULT nextval('public.agenda_utente_id_seq'::regclass);


--
-- Name: categoria_poi id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_poi ALTER COLUMN id SET DEFAULT nextval('public.categoria_poi_id_seq'::regclass);


--
-- Name: evento id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento ALTER COLUMN id SET DEFAULT nextval('public.evento_id_seq'::regclass);


--
-- Name: orario_poi id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orario_poi ALTER COLUMN id SET DEFAULT nextval('public.orario_poi_id_seq'::regclass);


--
-- Name: poi id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poi ALTER COLUMN id SET DEFAULT nextval('public.poi_id_seq'::regclass);


--
-- Name: utente id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utente ALTER COLUMN id SET DEFAULT nextval('public.utente_id_seq'::regclass);


--
-- Data for Name: agenda_utente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agenda_utente (id, id_utente, id_poi, titolo, orario_inizio, orario_fine) FROM stdin;
63	10	266	Oculista	2026-07-11 14:00:00+00	2026-07-11 14:15:00+00
\.


--
-- Data for Name: categoria_poi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categoria_poi (id, nome) FROM stdin;
1	biblioteca
2	sala_studio
3	mensa
4	ufficio
5	segreteria
6	fermata
7	noleggio_bici
8	stazione
9	benzinaio
\.


--
-- Data for Name: evento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.evento (id, id_utente, id_poi, tipo, messaggio, feedback, motivo, time_stamp, posizione_utente_reale) FROM stdin;
2	3	\N	Suggerimento	Nuova sala studio aperta nelle vicinanze	Non Utile	me la detto zo tilde	2026-06-28 19:23:28.450287	0101000020E61000001D38674469AF264048BF7D1D383F4640
6	1	\N	Suggerimento	Sei nei paraggi di Bike Sharing Zamboni, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.69)	2026-06-29 00:34:32.815403	0101000020E61000003333333333B326408FC2F5285C3F4640
7	1	\N	Suggerimento	Sei nei paraggi di Bike Sharing Zamboni, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.69)	2026-06-29 00:37:23.164146	0101000020E61000003333333333B326408FC2F5285C3F4640
8	1	\N	geofencing_enter	Sei entrato nell' area di Bike Sharing Zamboni.	Non Utile	Geofence scattato	2026-06-29 00:58:32.628693	0101000020E6100000A69BC420B0B22640736891ED7C3F4640
9	7	\N	Suggerimento	Test del feedback automatico	Utile	Testing	2026-06-29 12:15:09.089926	0101000020E61000003333333333B326408FC2F5285C3F4640
5	1	\N	geofencing_enter	Sei entrato nell'area del plesso universitario	Utile	Promemoria comodo per timbrare o segnare la presenza	2026-06-28 19:24:44.423266	0101000020E6100000F7E461A1D6B4264048E17A14AE3F4640
10	10	699	Suggerimento	Sei nei paraggi di Barbiano 1, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 6.81)	2026-07-04 15:15:53.159625	0101000020E610000095545C0B69AF264087B6AD77C93C4640
11	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 1.06)	2026-07-04 15:17:08.173503	0101000020E610000095545C0B69AF26402C6519E2583F4640
12	10	699	Suggerimento	Sei nei paraggi di Barbiano 1, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 4.54)	2026-07-04 15:19:53.296163	0101000020E610000095545C0B69AF264087B6AD77C93C4640
13	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 1.06)	2026-07-04 15:21:53.362164	0101000020E610000095545C0B69AF26402C6519E2583F4640
14	10	699	Suggerimento	Sei nei paraggi di Barbiano 1, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 4.54)	2026-07-04 15:22:53.360641	0101000020E610000095545C0B69AF264087B6AD77C93C4640
15	10	699	Suggerimento	Sei nei paraggi di Barbiano 1, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 4.54)	2026-07-04 15:26:23.397129	0101000020E610000095545C0B69AF264087B6AD77C93C4640
16	10	415	Suggerimento	Sei nei paraggi di Porta Castiglione, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.22)	2026-07-04 15:44:10.602757	0101000020E610000095545C0B69AF26404BEA0434113E4640
17	10	415	Suggerimento	Sei nei paraggi di Porta Castiglione, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.22)	2026-07-04 16:20:14.051059	0101000020E610000095545C0B69AF26404BEA0434113E4640
18	10	699	Suggerimento	Sei nei paraggi di Barbiano 1, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 4.54)	2026-07-04 16:20:29.059923	0101000020E610000095545C0B69AF264087B6AD77C93C4640
29	10	91	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria.	Utile	\N	2026-07-04 16:49:37.444647	0101000020E610000052167431BCB426407455EAA39D3F4640
34	10	91	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria.	Non Utile	Geofence scattato	2026-07-04 17:28:47.712081	0101000020E610000052167431BCB426407455EAA39D3F4640
30	10	110	Suggerimento	Sei nei paraggi di Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi", potrebbe interessarti!	Utile	\N	2026-07-04 16:49:37.435735	0101000020E610000052167431BCB426407455EAA39D3F4640
27	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Utile	\N	2026-07-04 16:49:22.436806	0101000020E610000095545C0B69AF26402C6519E2583F4640
25	10	123	geofencing_exit	Sei uscito dall' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Utile	\N	2026-07-04 16:34:57.254307	0101000020E610000095545C0B69AF26402C6519E2583F4640
24	10	91	geofencing_exit	Sei uscito dall' area di Biblioteca Universitaria.	Non Utile	\N	2026-07-04 16:34:57.252168	0101000020E610000095545C0B69AF26402C6519E2583F4640
26	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	\N	2026-07-04 16:34:57.23747	0101000020E610000095545C0B69AF26402C6519E2583F4640
22	10	123	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Non Utile	\N	2026-07-04 16:34:27.358114	0101000020E610000052167431BCB426407455EAA39D3F4640
23	10	110	Suggerimento	Sei nei paraggi di Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi", potrebbe interessarti!	Non Utile	\N	2026-07-04 16:34:27.358026	0101000020E610000052167431BCB426407455EAA39D3F4640
20	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Utile	\N	2026-07-04 16:23:12.085931	0101000020E610000095545C0B69AF26402C6519E2583F4640
19	10	699	Suggerimento	Sei nei paraggi di Barbiano 1, potrebbe interessarti!	Utile	\N	2026-07-04 16:21:42.087267	0101000020E610000095545C0B69AF264087B6AD77C93C4640
35	10	123	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Non Utile	Geofence scattato	2026-07-04 17:28:51.196394	0101000020E610000052167431BCB426407455EAA39D3F4640
36	10	110	Suggerimento	Sei nei paraggi di Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 1.35)	2026-07-04 17:28:51.048184	0101000020E610000052167431BCB426407455EAA39D3F4640
33	10	110	Suggerimento	Sei nei paraggi di Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi", potrebbe interessarti!	Utile	Miglior POI per contesto attuale (Punteggio: 1.35)	2026-07-04 17:18:35.870743	0101000020E610000052167431BCB426407455EAA39D3F4640
28	10	123	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Utile	\N	2026-07-04 16:49:37.440367	0101000020E610000052167431BCB426407455EAA39D3F4640
21	10	91	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria.	Utile	Geofence scattato	2026-07-04 16:34:27.357514	0101000020E610000052167431BCB426407455EAA39D3F4640
31	10	91	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria.	Non Utile	\N	2026-07-04 17:18:36.029615	0101000020E610000052167431BCB426407455EAA39D3F4640
32	10	123	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Utile	\N	2026-07-04 17:18:36.061027	0101000020E610000052167431BCB426407455EAA39D3F4640
37	10	123	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Non Utile	Geofence scattato	2026-07-04 18:30:05.03562	0101000020E610000052167431BCB426407455EAA39D3F4640
38	10	91	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria.	Non Utile	Geofence scattato	2026-07-04 18:30:05.096171	0101000020E610000052167431BCB426407455EAA39D3F4640
39	10	790	Suggerimento	Sei nei paraggi di Le Bacchette, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.86)	2026-07-04 18:30:04.89644	0101000020E610000052167431BCB426407455EAA39D3F4640
40	10	91	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria.	Non Utile	Geofence scattato	2026-07-04 18:35:14.349252	0101000020E610000052167431BCB426407455EAA39D3F4640
41	10	123	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Non Utile	Geofence scattato	2026-07-04 18:35:14.35655	0101000020E610000052167431BCB426407455EAA39D3F4640
42	10	790	Suggerimento	Sei nei paraggi di Le Bacchette, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.86)	2026-07-04 18:35:17.957182	0101000020E610000052167431BCB426407455EAA39D3F4640
51	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 36.18)	2026-07-04 18:59:53.386501	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
43	10	91	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria.	Non Utile	Geofence scattato	2026-07-04 18:40:51.66953	0101000020E610000052167431BCB426407455EAA39D3F4640
44	10	123	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Non Utile	Geofence scattato	2026-07-04 18:40:56.1919	0101000020E610000052167431BCB426407455EAA39D3F4640
47	10	123	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Non Utile	Geofence scattato	2026-07-04 18:55:52.366785	0101000020E610000052167431BCB426407455EAA39D3F4640
50	10	91	geofencing_exit	Sei uscito dall' area di Biblioteca Universitaria.	Non Utile	Geofence scattato	2026-07-04 18:59:53.386581	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
53	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 36.18)	2026-07-04 19:06:30.557703	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
45	10	790	Suggerimento	Sei nei paraggi di Le Bacchette, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.86)	2026-07-04 18:40:56.134872	0101000020E610000052167431BCB426407455EAA39D3F4640
46	10	91	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria.	Non Utile	Geofence scattato	2026-07-04 18:55:48.666553	0101000020E610000052167431BCB426407455EAA39D3F4640
48	10	790	Suggerimento	Sei nei paraggi di Le Bacchette, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.86)	2026-07-04 18:55:52.367742	0101000020E610000052167431BCB426407455EAA39D3F4640
49	10	123	geofencing_exit	Sei uscito dall' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia.	Non Utile	Geofence scattato	2026-07-04 18:59:53.383494	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
52	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Utile	Miglior POI per contesto attuale (Punteggio: 36.18)	2026-07-04 19:04:10.455049	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
54	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 36.05)	2026-07-05 15:20:22.510875	0101000020E6100000EB56CF49EFAB264033A7CB62623F4640
55	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 36.05)	2026-07-05 15:28:38.287097	0101000020E6100000EB56CF49EFAB264033A7CB62623F4640
56	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 36.18)	2026-07-05 15:41:39.799335	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
57	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 36.18)	2026-07-05 15:45:03.926097	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
58	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 36.18)	2026-07-05 15:47:42.920684	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
59	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 36.18)	2026-07-05 15:59:20.151973	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
60	10	195	Suggerimento	Sei nei paraggi di Piazza San Francesco, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 36.18)	2026-07-05 16:06:47.43103	0101000020E6100000BBE69F2AF0AB264033A7CB62623F4640
61	10	699	Suggerimento	Sei nei paraggi di Barbiano 1, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.18)	2026-07-05 16:07:33.265315	0101000020E6100000BBE69F2AF0AB26408EF85FF8D23C4640
62	10	634	Suggerimento	Sei nei paraggi di Rondone, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 0.49)	2026-07-05 16:08:18.274127	0101000020E6100000BBE69F2AF0AB2640DD989EB0C43F4640
63	10	441	Suggerimento	Sei nei paraggi di Masia, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 6.95)	2026-07-05 16:13:34.375828	0101000020E61000004AA995534CBB2640DD989EB0C43F4640
64	10	441	Suggerimento	Sei nei paraggi di Masia, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 6.95)	2026-07-05 16:13:50.725416	0101000020E61000004AA995534CBB2640DD989EB0C43F4640
65	10	441	Suggerimento	Sei nei paraggi di Masia, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 6.95)	2026-07-05 16:15:58.482177	0101000020E61000004AA995534CBB2640DD989EB0C43F4640
66	10	793	Suggerimento	Sei nei paraggi di Pizzeria Da Youssef, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 9.2)	2026-07-05 16:31:04.787436	0101000020E61000004AA995534CBB2640DD989EB0C43F4640
67	10	793	Suggerimento	Sei nei paraggi di Pizzeria Da Youssef, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 9.2)	2026-07-05 18:00:32.449407	0101000020E61000004AA995534CBB2640DD989EB0C43F4640
69	10	793	Suggerimento	Sei nei paraggi di Pizzeria Da Youssef, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 9.2)	2026-07-05 18:05:19.222832	0101000020E61000004AA995534CBB2640DD989EB0C43F4640
70	10	787	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	\N	2026-07-05 18:05:30.032929	0101000020E61000004AA995534CBB2640DD989EB0C43F4640
71	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 26.46)	2026-07-05 18:07:04.257323	0101000020E610000095545C0B69AF26402C6519E2583F4640
72	10	779	Suggerimento	Sei nei paraggi di La Tua Piadina, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 2.64)	2026-07-05 18:07:19.260552	0101000020E610000095545C0B69AF26404BEA0434113E4640
73	10	93	geofencing_enter	Sei entrato nell' area di Biblioteca di ingegneria Gian Paolo Dore.	Non Utile	Geofence scattato	2026-07-05 18:10:19.313675	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
74	10	545	Suggerimento	Sei nei paraggi di Porta Saragozza Frassinago, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.14)	2026-07-05 18:10:19.30306	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
75	10	560	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	\N	2026-07-05 18:10:28.633296	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
76	10	93	geofencing_enter	Sei entrato nell' area di Biblioteca di ingegneria Gian Paolo Dore.	Non Utile	Geofence scattato	2026-07-05 18:10:55.292187	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
77	10	545	Suggerimento	Sei nei paraggi di Porta Saragozza Frassinago, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.14)	2026-07-05 18:10:59.371417	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
78	10	794	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-05 18:11:59.075986	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
79	10	194	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-05 18:12:01.774118	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
80	10	195	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-05 18:12:08.894452	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
81	10	93	geofencing_enter	Sei entrato nell' area di Biblioteca di ingegneria Gian Paolo Dore.	Non Utile	Geofence scattato	2026-07-05 18:18:34.910975	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
82	10	545	Suggerimento	Sei nei paraggi di Porta Saragozza Frassinago, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.14)	2026-07-05 18:18:37.755006	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
83	10	93	geofencing_enter	Sei entrato nell' area di Biblioteca di ingegneria Gian Paolo Dore.	Non Utile	Geofence scattato	2026-07-05 18:24:57.984576	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
84	10	545	Suggerimento	Sei nei paraggi di Porta Saragozza Frassinago, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.14)	2026-07-05 18:25:01.62366	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
85	10	93	geofencing_enter	Sei entrato nell' area di Biblioteca di ingegneria Gian Paolo Dore.	Non Utile	Geofence scattato	2026-07-05 18:25:51.712678	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
86	10	545	Suggerimento	Sei nei paraggi di Porta Saragozza Frassinago, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.14)	2026-07-05 18:25:55.644342	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
87	10	93	geofencing_enter	Sei entrato nell' area di Biblioteca di ingegneria Gian Paolo Dore.	Non Utile	Geofence scattato	2026-07-05 18:26:35.55415	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
88	10	545	Suggerimento	Sei nei paraggi di Porta Saragozza Frassinago, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.14)	2026-07-05 18:26:39.646374	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
89	10	93	geofencing_enter	Sei entrato nell' area di Biblioteca di ingegneria Gian Paolo Dore.	Non Utile	Geofence scattato	2026-07-05 18:27:42.116711	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
90	10	545	Suggerimento	Sei nei paraggi di Porta Saragozza Frassinago, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.14)	2026-07-05 18:27:45.670255	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
91	10	102	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-05 18:29:15.387049	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
94	10	139	Suggerimento	Sei nei paraggi di Plesso Risorgimento, potrebbe interessarti!	Utile	Miglior POI per contesto attuale (Punteggio: 1000.0)	2026-07-06 12:15:58.078583	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
93	10	139	Suggerimento	Sei nei paraggi di Plesso Risorgimento, potrebbe interessarti!	Utile	Miglior POI per contesto attuale (Punteggio: 1000.0)	2026-07-06 12:15:39.168643	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
92	10	93	geofencing_enter	Sei entrato nell' area di Biblioteca di ingegneria Gian Paolo Dore.	Utile	Geofence scattato	2026-07-06 12:15:39.163049	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
95	10	93	geofencing_enter	Sei entrato nell' area di Biblioteca di ingegneria Gian Paolo Dore.	Non Utile	Geofence scattato	2026-07-06 12:51:17.681426	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
96	10	139	Suggerimento	Sei nei paraggi di Plesso Risorgimento, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 1000.0)	2026-07-06 12:51:21.560572	0101000020E6100000BEB0EBCD5EA82640248E869D733E4640
97	10	93	geofencing_exit	Sei uscito dall' area di Biblioteca di ingegneria Gian Paolo Dore.	Non Utile	Geofence scattato	2026-07-06 12:55:51.655432	0101000020E6100000BEB0EBCD5EA82640E8C1DD59BB3F4640
98	10	852	Suggerimento	Sei nei paraggi di Eni, potrebbe interessarti!	Utile	Miglior POI per contesto attuale (Punteggio: 7.45)	2026-07-06 12:55:51.636817	0101000020E6100000BEB0EBCD5EA82640E8C1DD59BB3F4640
99	10	852	Suggerimento	Sei nei paraggi di Eni, potrebbe interessarti!	Utile	Miglior POI per contesto attuale (Punteggio: 7.45)	2026-07-06 21:27:44.462853	0101000020E6100000BEB0EBCD5EA82640E8C1DD59BB3F4640
100	10	852	Suggerimento	Sei nei paraggi di Eni, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 7.45)	2026-07-07 16:48:07.417077	0101000020E6100000BEB0EBCD5EA82640E8C1DD59BB3F4640
101	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 26.46)	2026-07-07 16:50:22.262364	0101000020E610000095545C0B69AF26402C6519E2583F4640
102	10	98	Suggerimento	Sei nei paraggi di Biblioteca Universitaria di Ingegneria e Architettura. Sezione di Architettura "G. Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.73)	2026-07-07 16:50:52.275666	0101000020E610000010690A534AAA26404BEA0434113E4640
103	10	98	Suggerimento	Sei nei paraggi di Biblioteca Universitaria di Ingegneria e Architettura. Sezione di Architettura "G. Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.73)	2026-07-07 16:52:56.316511	0101000020E610000010690A534AAA26404BEA0434113E4640
104	10	98	Suggerimento	Sei nei paraggi di Biblioteca Universitaria di Ingegneria e Architettura. Sezione di Architettura "G. Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.73)	2026-07-07 16:58:54.404072	0101000020E610000010690A534AAA26404BEA0434113E4640
105	11	139	Suggerimento	Sei nei paraggi di Plesso Risorgimento, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.39)	2026-07-07 17:03:12.328983	0101000020E610000010690A534AAA26404BEA0434113E4640
106	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-07 17:11:09.595019	0101000020E610000010690A534AAA26404BEA0434113E4640
107	10	473	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-07 17:12:07.782143	0101000020E610000010690A534AAA26404BEA0434113E4640
108	10	303	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-07 17:12:10.810046	0101000020E610000010690A534AAA26404BEA0434113E4640
109	10	415	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-07 17:12:41.316051	0101000020E610000010690A534AAA26404BEA0434113E4640
110	10	775	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-07 17:12:43.745908	0101000020E610000010690A534AAA26404BEA0434113E4640
111	10	812	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-07 17:12:46.629987	0101000020E610000010690A534AAA26404BEA0434113E4640
112	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-07 17:38:27.927114	0101000020E610000010690A534AAA26404BEA0434113E4640
113	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-07 17:41:53.033114	0101000020E610000010690A534AAA26404BEA0434113E4640
114	10	122	poi_selezionato	Hai selezionato il seguente luogo dalla mappa	Non Utile	Marker cliccato	2026-07-07 17:42:18.962656	0101000020E610000010690A534AAA26404BEA0434113E4640
115	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-07 18:39:01.942365	0101000020E610000010690A534AAA26404BEA0434113E4640
116	1	139	Suggerimento	Sei nei paraggi di Plesso Risorgimento, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 8.49)	2026-07-07 18:55:26.460999	0101000020E610000010690A534AAA26404BEA0434113E4640
117	7	139	Suggerimento	Sei nei paraggi di Plesso Risorgimento, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.39)	2026-07-07 18:58:02.42093	0101000020E610000010690A534AAA26404BEA0434113E4640
118	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 16:03:18.334187	0101000020E610000010690A534AAA26404BEA0434113E4640
119	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 16:13:40.645436	0101000020E610000010690A534AAA26404BEA0434113E4640
120	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 16:31:07.961855	0101000020E610000010690A534AAA26404BEA0434113E4640
121	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 16:41:11.328209	0101000020E610000010690A534AAA26404BEA0434113E4640
122	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 16:50:29.313926	0101000020E610000010690A534AAA26404BEA0434113E4640
123	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 17:14:38.716839	0101000020E610000010690A534AAA26404BEA0434113E4640
124	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 17:20:57.855493	0101000020E610000010690A534AAA26404BEA0434113E4640
125	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 17:41:03.112409	0101000020E610000010690A534AAA26404BEA0434113E4640
126	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 17:50:13.253536	0101000020E610000010690A534AAA26404BEA0434113E4640
159	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 18:00:24.016483	0101000020E610000010690A534AAA26404BEA0434113E4640
160	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 18:06:33.418164	0101000020E610000010690A534AAA26404BEA0434113E4640
161	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 18:08:10.403129	0101000020E610000010690A534AAA26404BEA0434113E4640
162	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-08 18:42:54.672739	0101000020E610000010690A534AAA26404BEA0434113E4640
163	10	139	Suggerimento	Sei nei paraggi di Plesso Risorgimento, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.39)	2026-07-08 18:45:35.636647	0101000020E610000010690A534AAA26404BEA0434113E4640
164	10	139	Suggerimento	Sei nei paraggi di Plesso Risorgimento, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.39)	2026-07-08 18:48:59.265134	0101000020E610000010690A534AAA26404BEA0434113E4640
165	10	473	Suggerimento	Sei nei paraggi di Villa Baruzziana, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.32)	2026-07-08 19:48:07.858814	0101000020E610000010690A534AAA26404BEA0434113E4640
167	10	173	Avviso_agenda	Inviata notifica per l'evento: testing	Non Utile	Impegno in agenda entro 15 minuti	2026-07-08 19:49:07.126635	0101000020E610000010690A534AAA26404BEA0434113E4640
168	10	102	Suggerimento	Sei nei paraggi di Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci", potrebbe interessarti!	Utile	Miglior POI per contesto attuale (Punteggio: 5.71)	2026-07-10 17:12:22.906112	0101000020E610000010690A534AAA26404BEA0434113E4640
166	10	473	Suggerimento	Sei nei paraggi di Villa Baruzziana, potrebbe interessarti!	Utile	Miglior POI per contesto attuale (Punteggio: 3.32)	2026-07-08 19:49:01.178998	0101000020E610000010690A534AAA26404BEA0434113E4640
169	10	93	Suggerimento	Sei nei paraggi di Biblioteca di ingegneria Gian Paolo Dore, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.74)	2026-07-11 10:37:20.809156	0101000020E610000010690A534AAA26404BEA0434113E4640
170	10	473	Suggerimento	Sei nei paraggi di Villa Baruzziana, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 3.32)	2026-07-11 10:38:07.843134	0101000020E610000010690A534AAA26404BEA0434113E4640
171	10	852	Suggerimento	Sei nei paraggi di Eni, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 5.64)	2026-07-11 10:40:52.886662	0101000020E610000010690A534AAA26402C6519E2583F4640
172	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 10.58)	2026-07-11 10:41:22.894331	0101000020E610000095545C0B69AF26402C6519E2583F4640
173	10	165	Suggerimento	Sei nei paraggi di Pizza Leggera, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 11.21)	2026-07-11 10:41:52.897286	0101000020E610000095545C0B69AF26402B27EB81A0404640
174	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 26.46)	2026-07-11 10:42:37.905779	0101000020E610000095545C0B69AF26402C6519E2583F4640
175	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 26.46)	2026-07-11 10:45:06.967023	0101000020E610000095545C0B69AF26402C6519E2583F4640
176	10	161	Avviso_agenda	Inviata notifica per l'evento: gran premo	Non Utile	Impegno in agenda entro 15 minuti	2026-07-11 10:46:20.141242	0101000020E610000095545C0B69AF26402C6519E2583F4640
177	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 26.46)	2026-07-11 10:46:47.989864	0101000020E610000095545C0B69AF26402C6519E2583F4640
179	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Utile	Miglior POI per contesto attuale (Punteggio: 26.46)	2026-07-11 13:15:32.795486	0101000020E610000095545C0B69AF26402C6519E2583F4640
178	10	138	Avviso_agenda	Inviata notifica per l'evento: Dentista	Utile	Impegno in agenda entro 15 minuti	2026-07-11 12:51:17.428039	0101000020E610000095545C0B69AF26402C6519E2583F4640
180	10	812	Suggerimento	Sei nei paraggi di Crock!, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 26.46)	2026-07-11 13:19:03.885074	0101000020E610000095545C0B69AF26402C6519E2583F4640
181	10	125	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Scienze economiche - DSE.	Non Utile	Geofence scattato	2026-07-11 13:22:49.066754	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
182	10	119	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Filosofia e Comunicazione - FILCOM. Sezione di Filosofia.	Non Utile	Geofence scattato	2026-07-11 13:22:49.066551	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
183	10	121	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Storia antica.	Non Utile	Geofence scattato	2026-07-11 13:22:49.106314	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
184	10	95	geofencing_enter	Sei entrato nell' area di Biblioteca Giuridica Antonio Cicu.	Non Utile	Geofence scattato	2026-07-11 13:22:49.089465	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
185	10	142	geofencing_enter	Sei entrato nell' area di Piazza Antonino Scaravilli.	Non Utile	Geofence scattato	2026-07-11 13:22:49.088926	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
187	10	110	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi".	Non Utile	Geofence scattato	2026-07-11 13:22:49.153166	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
188	10	94	geofencing_enter	Sei entrato nell' area di Biblioteca di discipline umanistiche.	Non Utile	Geofence scattato	2026-07-11 13:22:49.153311	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
189	10	103	geofencing_enter	Sei entrato nell' area di Biblioteca universitaria del Dipartimento di Scienze Statistiche "Paolo Fortunati".	Non Utile	Geofence scattato	2026-07-11 13:22:49.213644	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
186	10	129	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria "Ezio Raimondi" - Sezione di Discipline Umanistiche.	Non Utile	Geofence scattato	2026-07-11 13:22:49.11772	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
190	10	94	Suggerimento	Sei nei paraggi di Biblioteca di discipline umanistiche, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 64.77)	2026-07-11 13:22:48.919075	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
191	10	266	Avviso_agenda	Inviata notifica per l'evento: Oculista	Non Utile	Impegno in agenda entro 15 minuti	2026-07-11 13:51:17.732196	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
192	10	94	geofencing_enter	Sei entrato nell' area di Biblioteca di discipline umanistiche.	Non Utile	Geofence scattato	2026-07-13 11:50:02.243328	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
193	10	95	geofencing_enter	Sei entrato nell' area di Biblioteca Giuridica Antonio Cicu.	Non Utile	Geofence scattato	2026-07-13 11:50:02.241731	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
194	10	110	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi".	Non Utile	Geofence scattato	2026-07-13 11:50:02.35932	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
195	10	103	geofencing_enter	Sei entrato nell' area di Biblioteca universitaria del Dipartimento di Scienze Statistiche "Paolo Fortunati".	Non Utile	Geofence scattato	2026-07-13 11:50:02.352175	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
196	10	136	Suggerimento	Sei nei paraggi di Università di Bologna, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 2500.0)	2026-07-13 11:50:01.810701	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
197	10	125	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Scienze economiche - DSE.	Non Utile	Geofence scattato	2026-07-13 11:50:02.44543	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
198	10	119	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Filosofia e Comunicazione - FILCOM. Sezione di Filosofia.	Non Utile	Geofence scattato	2026-07-13 11:50:02.512051	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
199	10	142	geofencing_enter	Sei entrato nell' area di Piazza Antonino Scaravilli.	Non Utile	Geofence scattato	2026-07-13 11:50:02.519479	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
200	10	121	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Storia antica.	Non Utile	Geofence scattato	2026-07-13 11:50:02.529646	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
201	10	129	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria "Ezio Raimondi" - Sezione di Discipline Umanistiche.	Non Utile	Geofence scattato	2026-07-13 11:50:02.600071	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
202	10	94	geofencing_enter	Sei entrato nell' area di Biblioteca di discipline umanistiche.	Non Utile	Geofence scattato - L'utente ha attraversato il confine virtuale del POI: Biblioteca di discipline umanistiche	2026-07-13 11:52:10.576243	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
203	10	95	geofencing_enter	Sei entrato nell' area di Biblioteca Giuridica Antonio Cicu.	Non Utile	Geofence scattato - L'utente ha attraversato il confine virtuale del POI: Biblioteca Giuridica Antonio Cicu	2026-07-13 11:52:10.590044	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
204	10	119	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Filosofia e Comunicazione - FILCOM. Sezione di Filosofia.	Non Utile	Geofence scattato - L'utente ha attraversato il confine virtuale del POI: Biblioteca del Dipartimento di Filosofia e Comunicazione - FILCOM. Sezione di Filosofia	2026-07-13 11:52:14.59881	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
205	10	125	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Scienze economiche - DSE.	Non Utile	Geofence scattato - L'utente ha attraversato il confine virtuale del POI: Biblioteca del Dipartimento di Scienze economiche - DSE	2026-07-13 11:52:14.606122	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
206	10	142	geofencing_enter	Sei entrato nell' area di Piazza Antonino Scaravilli.	Non Utile	Geofence scattato - L'utente ha attraversato il confine virtuale del POI: Piazza Antonino Scaravilli	2026-07-13 11:52:14.616386	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
207	10	110	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi".	Non Utile	Geofence scattato - L'utente ha attraversato il confine virtuale del POI: Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi"	2026-07-13 11:52:14.611952	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
208	10	129	geofencing_enter	Sei entrato nell' area di Biblioteca Universitaria "Ezio Raimondi" - Sezione di Discipline Umanistiche.	Non Utile	Geofence scattato - L'utente ha attraversato il confine virtuale del POI: Biblioteca Universitaria "Ezio Raimondi" - Sezione di Discipline Umanistiche	2026-07-13 11:52:14.620411	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
209	10	121	geofencing_enter	Sei entrato nell' area di Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Storia antica.	Non Utile	Geofence scattato - L'utente ha attraversato il confine virtuale del POI: Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Storia antica	2026-07-13 11:52:14.648199	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
210	10	103	geofencing_enter	Sei entrato nell' area di Biblioteca universitaria del Dipartimento di Scienze Statistiche "Paolo Fortunati".	Non Utile	Geofence scattato - L'utente ha attraversato il confine virtuale del POI: Biblioteca universitaria del Dipartimento di Scienze Statistiche "Paolo Fortunati"	2026-07-13 11:52:14.644002	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
211	10	136	Suggerimento	Sei nei paraggi di Università di Bologna, potrebbe interessarti!	Non Utile	Miglior POI per contesto attuale (Punteggio: 2500.0)	2026-07-13 11:52:14.587841	0101000020E61000008CA83FB104B42640FAF202ECA33F4640
\.


--
-- Data for Name: orario_poi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orario_poi (id, id_poi, giorno, orario_apertura, orario_chiusura) FROM stdin;
251	149	1	07:00:00	02:00:00
252	149	2	07:00:00	02:00:00
253	149	3	07:00:00	02:00:00
254	149	4	07:00:00	02:00:00
255	149	5	07:00:00	24:00:00
256	149	6	00:00:00	24:00:00
257	149	0	00:00:00	02:00:00
258	153	1	07:00:00	02:00:00
259	153	2	07:00:00	02:00:00
260	153	3	07:00:00	02:00:00
261	153	4	07:00:00	02:00:00
262	153	5	07:00:00	24:00:00
263	153	6	00:00:00	24:00:00
264	153	0	00:00:00	02:00:00
265	151	1	11:30:00	22:30:00
266	151	2	11:30:00	22:30:00
267	151	3	11:30:00	22:30:00
268	151	4	11:30:00	22:30:00
269	151	5	11:30:00	22:30:00
270	151	6	11:30:00	22:30:00
271	151	0	11:30:00	16:30:00
272	152	1	12:00:00	15:00:00
273	152	2	12:00:00	15:00:00
274	152	3	12:00:00	15:00:00
275	152	4	12:00:00	15:00:00
276	152	5	12:00:00	15:00:00
277	152	0	18:00:00	22:00:00
278	149	0	10:30:00	23:30:00
279	149	1	10:30:00	23:30:00
280	149	2	10:30:00	23:30:00
281	149	3	10:30:00	23:30:00
282	149	4	10:30:00	23:30:00
283	149	5	10:30:00	00:00:00
284	149	6	10:30:00	00:00:00
285	153	0	10:30:00	23:30:00
286	153	1	10:30:00	23:30:00
287	153	2	10:30:00	23:30:00
288	153	3	10:30:00	23:30:00
289	153	4	10:30:00	23:30:00
290	153	5	10:30:00	00:00:00
291	153	6	10:30:00	00:00:00
292	154	1	12:00:00	15:00:00
293	154	2	12:00:00	15:00:00
294	154	3	12:00:00	15:00:00
295	154	4	12:00:00	15:00:00
296	154	5	12:00:00	15:00:00
297	154	6	12:30:00	15:30:00
298	154	0	12:30:00	15:30:00
300	157	1	07:00:00	18:00:00
301	157	2	07:00:00	18:00:00
302	157	3	07:00:00	18:00:00
303	157	4	07:00:00	18:00:00
304	157	5	07:00:00	18:00:00
305	158	1	11:00:00	15:00:00
306	158	2	11:00:00	15:00:00
307	158	3	11:00:00	15:00:00
308	158	4	11:00:00	15:00:00
309	158	5	11:00:00	15:00:00
310	158	6	11:00:00	15:00:00
311	160	6	10:00:00	14:30:00
61	91	1	09:00:00	18:45:00
62	91	2	09:00:00	18:45:00
63	91	3	09:00:00	18:45:00
64	91	4	09:00:00	18:45:00
65	91	5	09:00:00	18:45:00
66	91	6	09:00:00	13:30:00
67	92	1	08:30:00	18:30:00
68	92	2	08:30:00	18:30:00
69	92	3	08:30:00	18:30:00
70	92	4	08:30:00	18:30:00
71	92	5	08:30:00	16:30:00
72	93	1	09:00:00	24:00:00
73	93	2	09:00:00	24:00:00
74	93	3	09:00:00	24:00:00
75	93	4	09:00:00	24:00:00
76	93	5	09:00:00	24:00:00
77	93	6	09:00:00	18:45:00
78	94	1	09:00:00	23:50:00
79	94	2	09:00:00	23:50:00
80	94	3	09:00:00	23:50:00
81	94	4	09:00:00	23:50:00
82	94	5	09:00:00	23:50:00
83	94	0	11:00:00	19:00:00
84	94	6	11:00:00	19:00:00
85	95	1	08:30:00	19:00:00
86	95	2	08:30:00	19:00:00
87	95	3	08:30:00	19:00:00
88	95	4	08:30:00	19:00:00
89	95	5	08:30:00	19:00:00
90	95	6	08:30:00	13:30:00
91	97	1	09:00:00	18:30:00
92	97	2	09:00:00	18:30:00
93	97	3	09:00:00	18:30:00
94	97	4	09:00:00	18:30:00
95	97	5	09:00:00	18:30:00
96	98	1	09:00:00	16:00:00
97	98	2	09:00:00	17:00:00
98	98	3	09:00:00	16:00:00
99	98	4	09:00:00	17:00:00
100	98	5	09:00:00	14:00:00
101	99	1	08:30:00	18:30:00
102	99	2	08:30:00	18:30:00
103	99	3	08:30:00	18:30:00
104	99	4	08:30:00	18:30:00
105	99	5	08:30:00	18:30:00
106	100	1	09:00:00	18:00:00
107	100	2	09:00:00	18:00:00
108	100	3	09:00:00	18:00:00
109	100	4	09:00:00	18:00:00
110	100	5	09:00:00	18:00:00
111	101	1	08:30:00	18:30:00
112	101	2	08:30:00	18:30:00
113	101	3	08:30:00	18:30:00
114	101	4	08:30:00	18:30:00
115	101	5	08:30:00	18:30:00
116	102	1	09:00:00	18:45:00
117	102	2	09:00:00	18:45:00
118	102	3	09:00:00	18:45:00
119	102	4	09:00:00	18:45:00
120	102	5	09:00:00	18:45:00
121	103	1	09:00:00	19:00:00
122	103	2	09:00:00	19:00:00
123	103	3	09:00:00	19:00:00
124	103	4	09:00:00	19:00:00
125	103	5	09:00:00	19:00:00
126	104	1	09:00:00	19:00:00
127	104	2	09:00:00	19:00:00
128	104	3	09:00:00	19:00:00
129	104	4	09:00:00	19:00:00
130	104	5	09:00:00	19:00:00
131	105	1	08:30:00	18:30:00
132	105	2	08:30:00	18:30:00
133	105	3	08:30:00	18:30:00
134	105	4	08:30:00	18:30:00
135	105	5	08:30:00	18:30:00
136	106	1	08:30:00	18:00:00
137	106	2	08:30:00	18:00:00
138	106	3	08:30:00	18:00:00
139	106	4	08:30:00	18:00:00
140	106	5	08:30:00	14:00:00
141	107	1	09:00:00	18:00:00
142	107	2	09:00:00	17:30:00
143	107	3	09:00:00	18:00:00
144	107	4	09:00:00	17:30:00
145	107	5	09:00:00	15:00:00
146	108	1	08:30:00	18:00:00
147	108	2	08:30:00	18:00:00
148	108	3	08:30:00	18:00:00
149	108	4	08:30:00	18:00:00
150	108	5	08:30:00	14:00:00
151	109	1	09:00:00	19:30:00
152	109	2	09:00:00	19:30:00
153	109	3	09:00:00	19:30:00
154	109	4	09:00:00	19:30:00
155	109	5	09:00:00	19:30:00
156	110	1	08:00:00	24:00:00
157	110	2	08:00:00	24:00:00
158	110	3	08:00:00	24:00:00
159	110	4	08:00:00	24:00:00
160	110	5	08:00:00	24:00:00
161	110	6	08:00:00	17:45:00
162	110	0	09:00:00	17:45:00
163	111	1	09:00:00	18:00:00
164	111	2	09:00:00	18:00:00
165	111	3	09:00:00	18:00:00
166	111	4	09:00:00	18:00:00
167	111	5	09:00:00	18:00:00
168	112	1	09:00:00	18:00:00
169	112	2	09:00:00	18:00:00
170	112	3	09:00:00	18:00:00
171	112	4	09:00:00	18:00:00
172	112	5	09:00:00	18:00:00
173	114	1	09:00:00	19:00:00
174	114	2	09:00:00	19:00:00
175	114	3	09:00:00	19:00:00
176	114	4	09:00:00	19:00:00
177	114	5	09:00:00	19:00:00
178	116	1	08:00:00	14:00:00
179	116	2	08:00:00	14:00:00
180	116	3	08:00:00	14:00:00
181	116	4	08:00:00	14:00:00
182	116	5	08:00:00	14:00:00
183	117	1	09:00:00	10:00:00
184	117	2	09:00:00	10:00:00
185	117	3	09:00:00	10:00:00
186	117	4	15:00:00	17:00:00
187	117	5	09:00:00	10:00:00
188	118	1	09:00:00	18:45:00
189	118	2	09:00:00	18:45:00
190	118	3	09:00:00	18:45:00
191	118	4	09:00:00	18:45:00
192	118	5	09:00:00	18:45:00
193	119	1	09:00:00	18:00:00
194	119	2	09:00:00	18:00:00
195	119	3	09:00:00	18:00:00
196	119	4	09:00:00	18:00:00
197	119	5	09:00:00	14:30:00
198	120	1	09:00:00	18:30:00
199	120	2	09:00:00	18:30:00
200	120	3	09:00:00	18:30:00
201	120	4	09:00:00	18:30:00
202	120	5	09:00:00	18:30:00
203	121	1	09:00:00	18:30:00
204	121	2	09:00:00	18:30:00
205	121	3	09:00:00	18:30:00
206	121	4	09:00:00	18:30:00
207	121	5	09:00:00	18:30:00
208	122	1	09:00:00	18:40:00
209	122	2	09:00:00	18:40:00
210	122	3	09:00:00	18:40:00
211	122	4	09:00:00	18:40:00
212	122	5	09:00:00	18:40:00
213	123	1	09:00:00	16:30:00
214	123	2	09:00:00	16:30:00
215	123	3	09:00:00	16:30:00
216	123	4	09:00:00	16:30:00
217	123	5	09:00:00	16:30:00
218	124	1	09:00:00	18:00:00
219	124	2	09:00:00	18:00:00
220	124	3	09:00:00	18:00:00
221	124	4	09:00:00	18:00:00
222	124	5	09:00:00	13:30:00
223	125	1	08:00:00	24:00:00
224	125	2	08:00:00	24:00:00
225	125	3	08:00:00	24:00:00
226	125	4	08:00:00	24:00:00
227	125	5	08:00:00	24:00:00
228	125	6	08:00:00	17:45:00
229	125	0	09:00:00	17:45:00
230	126	1	08:30:00	18:45:00
231	126	2	08:30:00	18:45:00
232	126	3	08:30:00	18:45:00
233	126	4	08:30:00	18:45:00
234	126	5	08:30:00	18:45:00
235	127	1	09:00:00	17:00:00
236	127	2	09:00:00	17:00:00
237	127	3	09:00:00	17:00:00
238	127	4	09:00:00	17:00:00
239	127	5	09:00:00	17:00:00
240	128	1	09:00:00	17:30:00
241	128	2	09:00:00	17:30:00
242	128	3	09:00:00	17:30:00
243	128	4	09:00:00	17:30:00
244	128	5	09:00:00	15:00:00
245	129	1	09:00:00	23:50:00
246	129	2	09:00:00	23:50:00
247	129	3	09:00:00	23:50:00
248	129	4	09:00:00	23:50:00
249	129	5	09:00:00	23:50:00
312	160	1	09:00:00	17:00:00
313	160	2	09:00:00	17:00:00
314	160	3	09:00:00	17:00:00
315	160	4	09:00:00	17:00:00
316	160	5	09:00:00	17:00:00
317	163	1	11:00:00	15:00:00
318	163	2	11:00:00	15:00:00
319	163	3	11:00:00	15:00:00
320	163	4	11:00:00	15:00:00
321	163	5	11:00:00	15:00:00
322	163	6	11:00:00	15:00:00
323	163	0	11:00:00	15:00:00
324	164	0	12:00:00	23:00:00
325	164	1	12:00:00	23:00:00
326	164	2	12:00:00	23:00:00
327	164	3	12:00:00	23:00:00
328	164	4	12:00:00	23:00:00
329	164	5	12:00:00	24:00:00
330	164	6	12:00:00	24:00:00
331	168	0	08:00:00	21:00:00
332	168	1	08:00:00	21:00:00
333	168	2	08:00:00	21:00:00
334	168	3	08:00:00	21:00:00
335	168	4	08:00:00	21:00:00
336	168	5	08:00:00	22:00:00
337	168	6	08:00:00	22:00:00
338	172	1	10:30:00	22:30:00
339	172	2	10:30:00	22:30:00
340	172	3	10:30:00	22:30:00
341	172	4	10:30:00	22:30:00
342	172	5	10:30:00	22:30:00
343	172	6	10:30:00	22:30:00
344	173	2	12:00:00	21:30:00
345	173	3	12:00:00	21:30:00
346	173	4	12:00:00	21:30:00
347	173	5	12:00:00	21:30:00
348	173	6	12:00:00	21:30:00
349	173	0	12:00:00	18:00:00
350	175	1	12:00:00	15:00:00
351	175	2	12:00:00	15:00:00
352	175	3	12:00:00	15:00:00
353	175	4	12:00:00	15:00:00
354	175	5	12:00:00	15:00:00
355	176	1	18:00:00	22:30:00
356	176	2	18:00:00	22:30:00
357	176	3	18:00:00	22:30:00
358	176	4	18:00:00	22:30:00
359	176	5	12:00:00	14:30:00
360	176	6	12:00:00	14:30:00
361	176	0	12:00:00	14:30:00
362	177	1	12:00:00	14:30:00
363	177	3	12:00:00	14:30:00
364	177	4	12:00:00	14:30:00
365	177	5	12:00:00	14:30:00
366	178	2	11:00:00	23:30:00
367	178	3	11:00:00	23:30:00
368	178	4	11:00:00	23:30:00
369	178	5	11:00:00	23:30:00
370	178	6	11:00:00	23:30:00
371	180	1	12:00:00	15:00:00
372	180	0	19:00:00	23:00:00
373	180	3	19:00:00	23:00:00
374	180	4	19:00:00	00:00:00
375	180	5	12:00:00	15:00:00
376	180	6	12:00:00	15:00:00
377	182	1	11:30:00	19:30:00
378	182	2	11:30:00	19:30:00
379	182	3	11:30:00	19:30:00
380	182	4	11:30:00	19:30:00
381	184	0	12:30:00	22:00:00
382	184	1	12:30:00	22:00:00
383	184	2	12:30:00	22:00:00
384	184	3	12:30:00	22:00:00
385	184	4	12:30:00	22:00:00
386	184	5	12:30:00	22:00:00
387	184	6	12:30:00	23:00:00
388	185	2	12:00:00	15:30:00
389	185	3	12:00:00	15:30:00
390	185	4	12:00:00	15:30:00
391	185	5	12:00:00	15:30:00
392	186	1	12:00:00	14:30:00
393	186	2	12:00:00	14:30:00
394	186	3	12:00:00	14:30:00
395	186	4	12:00:00	14:30:00
396	186	5	12:00:00	14:30:00
397	186	6	12:00:00	14:30:00
398	186	0	19:00:00	23:00:00
399	188	1	11:00:00	18:00:00
400	188	2	11:00:00	18:00:00
401	188	3	11:00:00	18:00:00
402	188	4	11:00:00	21:00:00
403	188	5	11:00:00	21:00:00
404	188	6	11:00:00	21:00:00
405	189	2	12:00:00	15:00:00
406	189	3	12:00:00	15:00:00
407	189	4	12:00:00	15:00:00
408	189	5	12:00:00	15:00:00
409	189	6	12:00:00	15:00:00
410	189	1	19:00:00	22:30:00
411	190	1	09:00:00	19:00:00
412	190	2	09:00:00	19:00:00
413	190	3	09:00:00	19:00:00
414	190	4	09:00:00	19:00:00
415	190	5	09:00:00	19:00:00
1128	999	0	18:00:00	22:00:00
1129	999	1	18:00:00	22:00:00
1130	999	2	18:00:00	22:00:00
1131	999	3	18:00:00	22:00:00
1132	999	4	18:00:00	22:00:00
1133	999	5	18:00:00	22:00:00
1135	1000	0	09:00:00	20:00:00
1136	1000	2	09:00:00	20:00:00
1137	1000	3	09:00:00	20:00:00
1138	1000	4	09:00:00	20:00:00
427	774	0	09:00:00	19:00:00
428	774	1	09:00:00	19:00:00
429	774	2	09:00:00	19:00:00
430	774	3	09:00:00	19:00:00
431	774	4	09:00:00	19:00:00
432	774	5	09:00:00	19:00:00
433	774	6	09:00:00	19:00:00
434	775	1	09:30:00	12:30:00
435	775	2	09:30:00	12:30:00
436	775	3	09:30:00	12:30:00
437	775	4	09:30:00	12:30:00
438	775	5	09:30:00	12:30:00
439	775	1	15:30:00	19:00:00
440	775	2	15:30:00	19:00:00
441	775	3	15:30:00	19:00:00
442	775	4	15:30:00	19:00:00
443	775	5	15:30:00	19:00:00
444	775	0	10:00:00	13:00:00
445	775	6	10:00:00	13:00:00
1139	1000	5	09:00:00	20:00:00
1140	1000	6	09:00:00	20:00:00
448	130	1	08:30:00	18:30:00
449	130	2	08:30:00	18:30:00
450	130	3	08:30:00	18:30:00
451	130	4	08:30:00	18:30:00
452	130	5	08:30:00	18:30:00
453	131	1	08:00:00	19:00:00
454	131	2	08:00:00	19:00:00
455	131	3	08:00:00	19:00:00
456	131	4	08:00:00	19:00:00
457	131	5	08:00:00	19:00:00
458	132	1	08:30:00	18:00:00
459	132	2	08:30:00	18:00:00
460	132	3	08:30:00	18:00:00
461	132	4	08:30:00	18:00:00
462	132	5	08:30:00	18:00:00
463	133	1	08:00:00	19:00:00
464	133	2	08:00:00	19:00:00
465	133	3	08:00:00	19:00:00
466	133	4	08:00:00	19:00:00
467	133	5	08:00:00	19:00:00
468	134	1	08:00:00	19:00:00
469	134	2	08:00:00	19:00:00
470	134	3	08:00:00	19:00:00
471	134	4	08:00:00	19:00:00
472	134	5	08:00:00	19:00:00
473	135	1	08:00:00	19:00:00
474	135	2	08:00:00	19:00:00
475	135	3	08:00:00	19:00:00
476	135	4	08:00:00	19:00:00
477	135	5	08:00:00	19:00:00
478	136	1	08:00:00	19:00:00
479	136	2	08:00:00	19:00:00
480	136	3	08:00:00	19:00:00
481	136	4	08:00:00	19:00:00
482	136	5	08:00:00	19:00:00
483	137	1	08:30:00	18:30:00
484	137	2	08:30:00	18:30:00
485	137	3	08:30:00	18:30:00
486	137	4	08:30:00	18:30:00
487	137	5	08:30:00	18:30:00
488	138	1	08:00:00	19:00:00
489	138	2	08:00:00	19:00:00
490	138	3	08:00:00	19:00:00
491	138	4	08:00:00	19:00:00
492	138	5	08:00:00	19:00:00
493	139	1	08:00:00	19:00:00
494	139	2	08:00:00	19:00:00
495	139	3	08:00:00	19:00:00
496	139	4	08:00:00	19:00:00
497	139	5	08:00:00	19:00:00
498	140	1	08:30:00	18:30:00
499	140	2	08:30:00	18:30:00
500	140	3	08:30:00	18:30:00
501	140	4	08:30:00	18:30:00
502	140	5	08:30:00	18:30:00
503	141	1	08:00:00	19:00:00
504	141	2	08:00:00	19:00:00
505	141	3	08:00:00	19:00:00
506	141	4	08:00:00	19:00:00
507	141	5	08:00:00	19:00:00
508	142	1	08:00:00	19:00:00
509	142	2	08:00:00	19:00:00
510	142	3	08:00:00	19:00:00
511	142	4	08:00:00	19:00:00
512	142	5	08:00:00	19:00:00
513	143	1	08:00:00	19:00:00
514	143	2	08:00:00	19:00:00
515	143	3	08:00:00	19:00:00
516	143	4	08:00:00	19:00:00
517	143	5	08:00:00	19:00:00
518	144	1	08:00:00	19:00:00
519	144	2	08:00:00	19:00:00
520	144	3	08:00:00	19:00:00
521	144	4	08:00:00	19:00:00
522	144	5	08:00:00	19:00:00
523	145	1	08:00:00	18:00:00
524	145	2	08:00:00	18:00:00
525	145	3	08:00:00	18:00:00
526	145	4	08:00:00	18:00:00
527	145	5	08:00:00	18:00:00
528	146	1	08:30:00	17:30:00
529	146	2	08:30:00	17:30:00
530	146	3	08:30:00	17:30:00
531	146	4	08:30:00	17:30:00
532	146	5	08:30:00	17:30:00
533	147	1	08:00:00	19:00:00
534	147	2	08:00:00	19:00:00
535	147	3	08:00:00	19:00:00
536	147	4	08:00:00	19:00:00
537	147	5	08:00:00	19:00:00
538	148	1	09:00:00	18:00:00
539	148	2	09:00:00	18:00:00
540	148	3	09:00:00	18:00:00
541	148	4	09:00:00	18:00:00
542	148	5	09:00:00	18:00:00
543	902	1	08:30:00	13:30:00
544	902	2	08:30:00	13:30:00
545	902	3	08:30:00	13:30:00
546	902	4	08:30:00	13:30:00
547	902	5	08:30:00	13:30:00
548	902	6	08:30:00	13:00:00
549	903	1	09:00:00	24:00:00
550	903	2	09:00:00	24:00:00
551	903	3	09:00:00	24:00:00
552	903	4	09:00:00	24:00:00
553	903	5	09:00:00	24:00:00
1141	1001	0	19:00:00	22:30:00
1142	1001	2	19:00:00	22:30:00
1143	1001	3	19:00:00	22:30:00
1144	1001	4	19:00:00	22:30:00
1145	1001	5	19:00:00	22:30:00
1146	1001	6	19:00:00	22:30:00
1147	1002	0	11:00:00	23:00:00
1148	1002	1	11:00:00	23:00:00
1149	1002	2	11:00:00	23:00:00
1150	1002	3	11:00:00	23:00:00
1151	1002	4	11:00:00	23:00:00
1152	1002	5	11:00:00	23:00:00
1153	1002	6	11:00:00	23:00:00
1154	1003	0	18:30:00	22:30:00
1155	1003	1	18:30:00	22:30:00
1156	1003	2	18:30:00	22:30:00
1157	1003	3	18:30:00	22:30:00
1158	1003	4	18:30:00	22:30:00
1159	1003	5	18:30:00	22:30:00
1160	1003	6	18:30:00	22:30:00
1161	1004	0	11:00:00	24:00:00
1162	1004	1	11:00:00	24:00:00
1163	1004	2	11:00:00	24:00:00
1164	1004	3	11:00:00	24:00:00
1165	1004	4	11:00:00	24:00:00
1166	1004	5	11:00:00	24:00:00
1167	1004	6	11:00:00	24:00:00
1168	1005	0	10:00:00	20:00:00
1169	1005	1	10:00:00	20:00:00
1170	1005	3	10:00:00	20:00:00
1171	1005	4	10:00:00	20:00:00
1172	1005	5	10:00:00	20:00:00
1173	1005	6	10:00:00	20:00:00
1174	1006	0	10:30:00	01:00:00
1175	1006	1	10:30:00	01:00:00
1176	1006	2	10:30:00	01:00:00
1177	1006	3	10:30:00	01:00:00
1178	1006	4	10:30:00	01:00:00
1179	1006	5	10:30:00	02:00:00
1180	1006	6	10:30:00	02:00:00
601	149	0	10:30:00	01:00:00
602	149	1	10:30:00	01:00:00
603	149	2	10:30:00	01:00:00
604	149	3	10:30:00	01:00:00
605	149	4	10:30:00	01:00:00
606	149	5	10:30:00	02:00:00
607	149	6	10:30:00	02:00:00
608	153	0	10:30:00	01:00:00
609	153	1	10:30:00	01:00:00
610	153	2	10:30:00	01:00:00
611	153	3	10:30:00	01:00:00
612	153	4	10:30:00	01:00:00
613	153	5	10:30:00	02:00:00
614	153	6	10:30:00	02:00:00
615	776	0	10:30:00	01:00:00
616	776	1	10:30:00	01:00:00
617	776	2	10:30:00	01:00:00
618	776	3	10:30:00	01:00:00
619	776	4	10:30:00	01:00:00
620	776	5	10:30:00	02:00:00
621	776	6	10:30:00	02:00:00
622	780	0	10:30:00	01:00:00
623	780	1	10:30:00	01:00:00
624	780	2	10:30:00	01:00:00
625	780	3	10:30:00	01:00:00
626	780	4	10:30:00	01:00:00
627	780	5	10:30:00	02:00:00
628	780	6	10:30:00	02:00:00
1181	1198	1	08:00:00	19:00:00
1182	1197	1	08:00:00	18:00:00
1183	1196	1	08:00:00	19:00:00
1184	1195	1	08:00:00	19:00:00
1185	1194	1	08:00:00	19:00:00
1186	1193	1	08:00:00	19:00:00
1187	1192	1	09:00:00	18:00:00
1188	1191	1	08:00:00	19:00:00
1189	1190	1	09:00:00	18:00:00
1190	1009	1	07:30:00	19:30:00
1191	1008	1	07:00:00	19:00:00
1192	1007	1	08:00:00	19:00:00
1193	1198	2	08:00:00	19:00:00
1194	1197	2	08:00:00	18:00:00
1195	1196	2	08:00:00	19:00:00
1196	1195	2	08:00:00	19:00:00
1197	1194	2	08:00:00	19:00:00
1198	1193	2	08:00:00	19:00:00
1199	1192	2	09:00:00	18:00:00
1200	1191	2	08:00:00	19:00:00
1201	1190	2	09:00:00	18:00:00
1202	1009	2	07:30:00	19:30:00
1203	1008	2	07:00:00	19:00:00
1204	1007	2	08:00:00	19:00:00
1205	1198	3	08:00:00	19:00:00
1206	1197	3	08:00:00	18:00:00
1207	1196	3	08:00:00	19:00:00
1208	1195	3	08:00:00	19:00:00
1209	1194	3	08:00:00	19:00:00
1210	1193	3	08:00:00	19:00:00
1211	1192	3	09:00:00	18:00:00
1212	1191	3	08:00:00	19:00:00
1213	1190	3	09:00:00	18:00:00
1214	1009	3	07:30:00	19:30:00
1215	1008	3	07:00:00	19:00:00
1216	1007	3	08:00:00	19:00:00
1217	1198	4	08:00:00	19:00:00
1218	1197	4	08:00:00	18:00:00
1219	1196	4	08:00:00	19:00:00
1220	1195	4	08:00:00	19:00:00
1221	1194	4	08:00:00	19:00:00
1222	1193	4	08:00:00	19:00:00
1223	1192	4	09:00:00	18:00:00
1224	1191	4	08:00:00	19:00:00
1225	1190	4	09:00:00	18:00:00
1226	1009	4	07:30:00	19:30:00
1227	1008	4	07:00:00	19:00:00
1228	1007	4	08:00:00	19:00:00
1229	1198	5	08:00:00	19:00:00
1230	1197	5	08:00:00	18:00:00
1231	1196	5	08:00:00	19:00:00
1232	1195	5	08:00:00	19:00:00
1233	1194	5	08:00:00	19:00:00
1234	1193	5	08:00:00	19:00:00
1235	1192	5	09:00:00	18:00:00
1236	1191	5	08:00:00	19:00:00
1237	1190	5	09:00:00	18:00:00
1238	1009	5	07:30:00	19:30:00
1239	1008	5	07:00:00	19:00:00
1240	1007	5	08:00:00	19:00:00
\.


--
-- Data for Name: poi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.poi (id, nome, id_categoria, descrizione, geometria, campus) FROM stdin;
91	Biblioteca Universitaria	1	Biblioteca Universitaria	0101000020E610000045A40117BFB42640A848CF3EA03F4640	Bologna
92	Biblioteca Biomedica Centrale	1	Biblioteca Biomedica Centrale	0101000020E6100000E41D96BCF0B52640653E7B890C404640	Bologna
93	Biblioteca di ingegneria Gian Paolo Dore	1	Biblioteca di ingegneria Gian Paolo Dore	0101000020E610000026AB22DC64A826400268EFE76F3E4640	Bologna
94	Biblioteca di discipline umanistiche	1	Biblioteca di discipline umanistiche	0101000020E610000098F6CDFDD5B326400F4EFA319C3F4640	Bologna
95	Biblioteca Giuridica Antonio Cicu	1	Biblioteca Giuridica Antonio Cicu	0101000020E6100000FB54BA6015B4264081ECF5EE8F3F4640	Bologna
96	Sala Studio Petroni	1	Sala Studio Petroni	0101000020E6100000054AAF720DB42640C4E3ECE75E3F4640	Bologna
97	Biblioteca Universitaria di Scienze dell'Educazione "Mario Gattullo"	1	Biblioteca Universitaria di Scienze dell'Educazione "Mario Gattullo"	0101000020E6100000C1CF132A93B5264086787F1711404640	Bologna
98	Biblioteca Universitaria di Ingegneria e Architettura. Sezione di Architettura "G. Michelucci"	1	Biblioteca Universitaria di Ingegneria e Architettura. Sezione di Architettura "G. Michelucci"	0101000020E6100000BBB0DAA106A8264041672D605D3E4640	Bologna
99	Biblioteca del Navile	1	Biblioteca del Navile	0101000020E6100000BD56427749AC2640C9213DA0C7424640	Bologna
100	Biblioteca Universitaria di Matematica, Fisica, Astronomia e Informatica. Sezione di Matematica	1	Biblioteca Universitaria di Matematica, Fisica, Astronomia e Informatica. Sezione di Matematica	0101000020E6100000321015F428B62640F3F395F6BC3F4640	Bologna
101	Biblioteca Universitaria di Agraria Gabriele Goidanich	1	Biblioteca Universitaria di Agraria Gabriele Goidanich	0101000020E610000081E6183504D026407FEA0E18DA414640	Bologna
102	Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci"	1	Biblioteca di Ingegneria e Architettura. Sezione di Ingegneria civile "Giovanni Michelucci"	0101000020E6100000819E61C504A82640C417377F5D3E4640	Bologna
103	Biblioteca universitaria del Dipartimento di Scienze Statistiche "Paolo Fortunati"	1	Biblioteca universitaria del Dipartimento di Scienze Statistiche "Paolo Fortunati"	0101000020E61000007CC15DAC5EB426408720BD97B13F4640	Bologna
104	Biblioteca di Scienze Politiche e Sociali "Nicola Matteucci"	1	Biblioteca di Scienze Politiche e Sociali "Nicola Matteucci"	0101000020E6100000473F75070CB52640CEC7105BD53E4640	Bologna
105	Biblioteca Universitaria del Dipartimento di Filosofia e Comunicazione	1	Biblioteca Universitaria del Dipartimento di Filosofia e Comunicazione	0101000020E610000082EC50A802AD26408F3C6B1217404640	Bologna
106	Biblioteca del Dipartimento di Scienze Biologiche, Geologiche e Ambientali. Sezione di Biologia	1	Biblioteca del Dipartimento di Scienze Biologiche, Geologiche e Ambientali. Sezione di Biologia	0101000020E6100000983BE93356B526405FCE119E753F4640	Bologna
107	Biblioteca Universitaria Interdipartimentale di Matematica, Fisica, Astronomia e Informatica. Sezione di Fisica	1	Biblioteca Universitaria Interdipartimentale di Matematica, Fisica, Astronomia e Informatica. Sezione di Fisica	0101000020E61000007C7BD7A02FB52640404D2D5BEB3F4640	Bologna
108	Biblioteca del Dipartimento di Scienze Biologiche, Geologiche e Ambientali. Sezione di Geologia	1	Biblioteca del Dipartimento di Scienze Biologiche, Geologiche e Ambientali. Sezione di Geologia	0101000020E6100000179E978A8DB52640F399A2128D3F4640	Bologna
109	Biblioteca Universitaria di Ingegneria e Architettura. Sezione Ingegneria Chimica, Ambientale e Gestionale "F.P. Foraboschi"	1	Biblioteca Universitaria di Ingegneria e Architettura. Sezione Ingegneria Chimica, Ambientale e Gestionale "F.P. Foraboschi"	0101000020E6100000CC2555DB4DA4264038E85C9BD7414640	Bologna
110	Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi"	1	Biblioteca Universitaria di Discipline Economico Aziendali "Walter Bigiavi"	0101000020E61000000921D6D127B42640AC58FCA6B03F4640	Bologna
111	Biblioteca Universitaria del Dipartimento di Storia Culture Civiltà. Sezione di Archeologia	1	Biblioteca Universitaria del Dipartimento di Storia Culture Civiltà. Sezione di Archeologia	0101000020E610000061FBC9181FB22640F2C8C452C93E4640	Bologna
112	Biblioteca Universitaria del Dipartimento di Storia Culture Civiltà. Sezione Storia Medievale	1	Biblioteca Universitaria del Dipartimento di Storia Culture Civiltà. Sezione Storia Medievale	0101000020E6100000E516A9E628B226401777CDF5C73E4640	Bologna
113	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Sezione di Malattie dell'apparato cardiovascolare	1	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Sezione di Malattie dell'apparato cardiovascolare	0101000020E61000002B436678FDB726403F28DEB7103F4640	Bologna
114	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Sezione di Medicina interna "Gasbarrini"	1	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Sezione di Medicina interna "Gasbarrini"	0101000020E610000044A51133FBB82640E1F08288D43E4640	Bologna
115	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Sezione di Chirurgia generale e dei trapianti d'organo "L. Possati"	1	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Sezione di Chirurgia generale e dei trapianti d'organo "L. Possati"	0101000020E6100000B598E9A8B4B72640723A24100A3F4640	Bologna
116	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Sezione di Scienze ginecologiche, ostetriche e pediatriche	1	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Sezione di Scienze ginecologiche, ostetriche e pediatriche	0101000020E610000036994C7045B9264074EA6FAE063F4640	Bologna
117	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Fondo di Microbiologia	1	Biblioteca di Medicina. Biblioteca Clinica "F. B. Bianchi". Fondo di Microbiologia	0101000020E610000042EDB776A2B826403DB3C986DA3E4640	Bologna
118	Biblioteca delle Arti. Sezione di Arti visive "I. B. Supino"	1	Biblioteca delle Arti. Sezione di Arti visive "I. B. Supino"	0101000020E61000006BDECC4301B6264048C9062D7F3E4640	Bologna
119	Biblioteca del Dipartimento di Filosofia e Comunicazione - FILCOM. Sezione di Filosofia	1	Biblioteca del Dipartimento di Filosofia e Comunicazione - FILCOM. Sezione di Filosofia	0101000020E6100000C095ECD808B4264012BCC6D3973F4640	Bologna
120	Biblioteca del Dipartimento di Lingue, Letterature e Culture moderne - LILEC	1	Biblioteca del Dipartimento di Lingue, Letterature e Culture moderne - LILEC	0101000020E610000082188D21A5B22640DF313CF6B33E4640	Bologna
121	Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Storia antica	1	Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Storia antica	0101000020E61000006A91A3EF24B426406B494739983F4640	Bologna
122	Biblioteca delle Arti. Sezione di Musica e Spettacolo	1	Biblioteca delle Arti. Sezione di Musica e Spettacolo	0101000020E6100000EAF29CE392AD2640D295BEC6E43E4640	Bologna
123	Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia	1	Biblioteca del Dipartimento di Storia Culture Civiltà - DiSCi. Sezione di Orientalistica e Antropologia	0101000020E6100000A48F543AB3B42640083A5AD5923F4640	Bologna
124	Biblioteca "Silvana Contento" del Dipartimento di Psicologia	1	Biblioteca "Silvana Contento" del Dipartimento di Psicologia	0101000020E6100000BF5D9B32DCB52640C1368710FC3F4640	Bologna
125	Biblioteca del Dipartimento di Scienze economiche - DSE	1	Biblioteca del Dipartimento di Scienze economiche - DSE	0101000020E61000002D05A4FD0FB42640F2EA1C03B23F4640	Bologna
126	Biblioteca Giuridica Antonio Cicu - sezione Filopanti	1	Biblioteca Giuridica Antonio Cicu - sezione Filopanti	0101000020E6100000A661F88898B6264060E234E95B3F4640	Bologna
127	Biblioteca del Dipartimento di Sociologia e Diritto dell'Economia - SDE. Sezione di Sociologia "Achille Ardigò"	1	Biblioteca del Dipartimento di Sociologia e Diritto dell'Economia - SDE. Sezione di Sociologia "Achille Ardigò"	0101000020E61000007F85CC9541B526405BE619A0D93E4640	Bologna
128	Biblioteca del Dipartimento di Sociologia e Diritto dell'Economia - SDE. Sezione di Diritto dell'economia	1	Biblioteca del Dipartimento di Sociologia e Diritto dell'Economia - SDE. Sezione di Diritto dell'economia	0101000020E6100000CED3CACEECB42640ABD4473BC93E4640	Bologna
129	Biblioteca Universitaria "Ezio Raimondi" - Sezione di Discipline Umanistiche	1	Biblioteca Universitaria "Ezio Raimondi" - Sezione di Discipline Umanistiche	0101000020E61000002CABFAA6FAB326402B24AA01943F4640	Bologna
130	Università di Bologna - Plesso Navile	2	Università di Bologna - Plesso Navile	0106000020E6100000020000000103000000010000007D0000008D1E094504AD264059912CBBBB4246409E9D674705AD2640DB4136DABB42464032B32A1D07AD2640D5986B2CBC424640DEDCA9CA08AD2640BDE0D39CBC424640542179420AAD26406467C00FBD4246400DBD6A0A09AD264022D45636BD4246408C46E3F505AD2640F20703CFBD424640108D936703AD264081D657B2BE4246408F160C5300AD2640FD95DFB3BF424640907EA081FDAC26404A479451C0424640159D7642F9AC2640BB44F5D6C042464062BEBC00FBAC2640A91B83A9C1424640DE077B6EFCAC26404FFE9364C24246408F41DDF6F3AC264019FF3EE3C2424640F04119F4EFAC26407EC4AF58C34246400A06216AECAC2640A2F6B6F4C3424640A3C629DFD8AC2640C8D34DBDC94246405130630AD6AC264098631E9ECA42464095EF1989D0AC26402C4BCF4FCC4246402BFDDF6CCEAC26406EC493DDCC424640564046E5CBAC264044CF1C48CD424640648ADE4EC7AC26408B4DD0CBCD42464038C2FDDBC0AC2640B484C65DCE4246409FAA4203B1AC2640B4F4577ECF4246402BD8EB8266AC2640350FBB4AD2424640F292A4106DAC264005CD9D4FD3424640A93693CA6FAC26409A16ABBCD3424640F9D4569176AC2640E7B3F281D3424640B1506B9A77AC2640AB39E576D44246401616DC0F78AC264010FF55ECD442464096A24BEE66AC264010B79E7CD5424640FFBC5FBB6AAC2640A99D06B1D8424640EF5DDE7767AC2640BB08F8DAD8424640998F5A176DAC26401EC2F869DC424640F09AA10271AC2640C9B72D80DF424640A5468DAE77AC264017557545DF424640557DF8437DAC26405C374A03E4424640FF21FDF675AC26401AD2F24DE4424640A87B53477DAC2640232015B5EA424640E0490B9755AC2640CF1B823EEC424640CFF57D3848AC26400AA1832EE1424640E899A8EF46AC26406FDCBD37E14246403361455733AC2640BEE1992BDE42464034396BA631AC2640761B2F38DE424640820AFD0230AC2640A1CE26D1DC424640B19014EC1AAC2640916FA58DD942464033EDAC2704AC2640E0BC38F1D5424640BDA8DDAF02AC2640CF0FC8CAD4424640120FCDE1FFAB2640CA2AB693D242464075779D0DF9AB26404D09D2D6D2424640D557FC4BF7AB2640A0072DDAD24246408836B68DF5AB2640E7CD97CDD24246402ABEEB7DF4AB264053E0AEA8D2424640E95ECC3BF3AB2640E8436161D242464087698423EDAB26404E57C1B9D0424640B9612530E7AB26404F01D5E4CE424640F743C769E3AB2640B59E6BA9CD424640A230838CDBAB26409E205624CB4246408052A346D7AB26409FF87B73C94246408FE4F21FD2AB2640F316B435C7424640DF65D01ACDAB264083C366DBC4424640E0CD6449CAAB2640AEEC2708C34246400DC11660C4AB2640E0826C59BE424640147651F4C0AB26403B1C5DA5BB424640E9CD4D40B8AB2640260C14C2B44246407149C44ABBAB26400336316EB44246401021AE9CBDAB2640AAA8B008B4424640BC4A2D4ABFAB26406E90FFB8B34246409D595C2DC1AB2640C8DB0022B3424640A9D3CB39C2AB2640F8A75489B242464073A66494C2AB2640640223D4B1424640A31694B3C1AB26406AF3A4F1B0424640C7C49C56C0AB2640297AE063B0424640E6B56D73BEAB2640473767E9AF424640750305DEC9AB26406B6FA6F8AE42464038B1D183CCAB2640FAFB7BDFAE424640BE175FB4C7AB2640CBF3E0EEAC4246403894EBB7C0AB2640F6083543AA424640A4614216B3AB26409A2C49F9A4424640D9999DA0A8AB2640D1A79F81A242464033FE7DC685AB2640846973F7944246403C6304F97EAB2640C672A664944246400F7B46C77AAB264032B907D79242464016E8C9EB77AB26408C7AD2D3914246402AA7E26B74AB26400F739362914246406A7693CE76AB264016DADE1390424640AEA5DB6D72AB2640ED4CFCAC8D4246404AB8904770AB2640FF2DB76A8D424640D40330AF6DAB26406AE4A9FD8C424640E7EA22E06BAB2640DC9F8B868C4246401D6041F56AAB26405FC65E398C424640F9D115116AAB26404DFF48C78B4246403B095BA269AB2640423D224B8B4246401DF0AFD469AB264066FF97C68A4246404C88B9A46AAB26406C4C3E2C8A4246408DE7D8E66BAB2640668F06A689424640F7D912036EAB264078149D1B8942464035046CAC69AB2640BAEFBD6488424640013F993567AB2640D2A755F4874246401DF0AFD469AB26404A3A144F8742464037610CF670AB2640C7759D578642464082C41B3E8EAB2640FEA83C7084424640758F6CAE9AAB2640BC71F7DE84424640C3352D67A5AB2640564A2AAE8542464014AC167DAAAB2640BC8B9C2A84424640005D8F1DAFAB2640FE0461B8844246409C645012B7AB2640C1CCD2A98642464099C00875ECAB2640B66F496991424640DA311A9E03AC2640844FCEAB95424640D5AEAEAF1AAC26409FFAACD799424640A59828E730AC2640268A90BA9D4246406B08331246AC264072778CE1A042464071FF36305EAC2640E73F5A52A44246406914371378AC2640DA571EA4A74246406876DD5B91AC2640791563AAAA424640134ABAC1ABAC26402AE27492AD424640FB52E4B5B7AC2640244D17BDAE424640DDA9CA08B9AC2640181527ADAE424640BCB20B06D7AC2640640223D4B14246409E51A9C8D7AC2640AB24B20FB242464079B29B19FDAC26404AF663EEB542464015D742DA10AD264078FEFEDEB7424640C5A810340BAD264006E1C09AB9424640CC5D4BC807AD2640A61A07A8BA4246408D1E094504AD264059912CBBBB4246400103000000010000002E00000065A6594524AB2640CE6E2D93E14246404B72C0AE26AB2640FD906DCFE242464026512FF834AB26405A73918CE64246409A5544F23AAB26401E3B037EE84246406A728CBF48AB264054573ECBF34246403F2F26474BAB2640E2F7808AF4424640F1A54B5A4CAB2640FA9573CEF4424640DEBE58294EAB26408EDF803BF542464001BD152E50AB264005B4BE92F5424640A04C481053AB2640A607AAEBF54246401C06989E55AB2640A030CD19F642464022B8DB3F60AB264052C19778F64246406B798AC168AB264076B11F18F64246406A93799A82AB26402F7B2304F5424640A88B14CAC2AB2640A82DBF1DF242464050A8A78FC0AB264038EEDE9BF04246406DCC4642B6AB2640E2EE0797E94246403E7CF4E1B4AB264083A44FABE84246404679E6E5B0AB2640F699B33EE5424640D34CF73AA9AB26402E63F9A9E04246406CBA545BA0AB2640FBEB1516DC424640DAC46E449CAB26405EFEF96CD34246400EDDEC0F94AB264058552FBFD3424640A61B727D69AB26408701A667D54246405BD2510E66AB264071276C9AD24246405CAA775D64AB264042D7193AD14246401E46521C51AB2640653733FAD1424640815B77F354AB26407568A219D5424640DCA96F4F46AB26409F9F98ABD54246402BC3B81B44AB2640588341E3D3424640BEE36FD63BAB2640D960E124CD424640A240440F21AB2640FC1C1F2DCE424640EEFCEC9117AB26403B25D698C6424640837A449616AB26405FE74B14C64246409CAEDD2C14AB26407E062F55C4424640A89BD54C08AB26405A44B9D9C442464050B8681206AB26409B3347FBC44246404586B07504AB2640AD9E3825C542464046161F5503AB26406506E055C5424640E150AEDF02AB264018699890C5424640CF41E1FD02AB264059B44AFAC5424640E6C52EF603AB2640710A86CEC64246409E89FA6E04AB264088D68A36C7424640F0C91EFC1FAB26401D609CAEDD4246409636662321AB26403ACF3351DF42464065A6594524AB2640CE6E2D93E1424640	Bologna
131	Università di Bologna - Plesso Bertalia-Lazzaretto	2	Università di Bologna - Plesso Bertalia-Lazzaretto	0106000020E61000000100000001030000000100000024000000856E4095E4A226401422E010AA41464072E1404816A42640E82BED79A34146403CEEA53A2EA4264083386AE0A24146402F0CA2FF2FA42640AFD2382FA9414640AC9223F83AA426403B8FE5B8AE41464095826E2F69A4264091C547D5C0414640A5468DAE77A426401E26D016C6414640A75B76887FA426406E6EA708CB414640A000E54A98A4264045F872FAD541464041F8AB5B98A426409D09F258D84146405AE48D8296A4264091CBC9D5D941464098C926AF84A426402A0E5652DD4146402C5D667D6FA42640D45FAFB0E0414640A9A10DC006A42640926D2A9CEE4146400F6A7528F9A32640EAC6606AF041464049F7730AF2A3264055D97745F0414640AF772403E5A32640280527ECEC41464050471163E3A32640B0E83125ED4146407B6D910FD5A32640BD68D9A4EC414640988D29B39CA32640AB425E6ADF41464060C37872F2A326401CF5C6FFD341464054EF5F0FDCA32640C074FFFDCE414640366D10F7A2A32640A38C5D47C14146407393629170A326405EC76E55C8414640DBA6785C54A3264004482355CA414640919D126B4CA326400A1F0027CA414640B35E0CE544A326406869B812CB414640B341261939A326405E995C31C84146405D26D41DD5A2264088B02B77B04146406913CC3DC9A22640240B98C0AD414640E107E753C7A22640544DB5BBAC414640C3161637C9A22640A87F5A56AB414640FC5069C4CCA226403E59D6A2AA414640B2D47ABFD1A22640677C5F5CAA414640D322EC25D7A226402088E244AA414640856E4095E4A226401422E010AA414640	Bologna
132	Sede di Mineralogia	2	Sede di Mineralogia	0106000020E610000001000000010300000001000000160000002F7C8ED9A3B5264063BDACE4BE3F46400353173AC0B52640DEA40E97C13F46405AA61595C3B526403261EA9DC03F4640BF5D9B32DCB52640FBE59315C33F464060BAFF7EE7B52640B9669714C43F46407E1B62BCE6B526408333F8FBC53F4640A2D45E44DBB52640E24F9EC3C63F4640EDEEA600BDB526404C14C6BBC83F4640EA663513C2B52640E542E55FCB3F4640EF93FEB9C3B5264009A3FE1FCC3F464007184CB2C4B5264085AA3D91CC3F46402F3CE58700B626405E51A5C1C83F4640C90EE0E302B6264034A4E59BC83F4640CFCB176A03B626409A6F8E84C73F4640213A048E04B62640E95AC52CC53F46404BCD1E6805B62640EF37DA71C33F4640F1811DFF05B62640A9D3CB39C23F464046A055C103B6264073EE1B04C23F4640EA831BDFCDB52640050363D8BC3F4640AB8C90CBC9B52640B1D0BD3DBE3F4640B46F93F6ABB52640B20A4048BB3F46402F7C8ED9A3B5264063BDACE4BE3F4640	Bologna
133	Università di Bologna - Facoltà di Lingue e Letterature Straniere - Presidenza	2	Università di Bologna - Facoltà di Lingue e Letterature Straniere - Presidenza	0106000020E61000000100000001030000000100000012000000DAD1EE46D5B52640A368D43208404640AE6EAB0FDAB52640F5A276BF0A404640670A9DD7D8B526406616A1D80A404640BD659824E0B52640A583F57F0E404640E6B0FB8EE1B52640880E266A0E4046403D2CD49AE6B5264080457EFD10404640DD5D6743FEB52640BC35559C0F40464091CC8F64FBB526401D44C6FE0D404640748B0AE6F9B52640C42C0F2D0D4046403CD63153FFB526404753E2DF0C404640D423B2B4F8B526402B604C4409404640818AF4EC03B626403DB7D095084046403619FACCFEB526403F1F65C40540464067DFCB33E5B5264085DF9744074046405B1DA5B7E4B52640D34ECDE506404640832B4597DCB526404A511D6107404640D0DCF934DDB52640A9E38CBC07404640DAD1EE46D5B52640A368D43208404640	Bologna
134	Università di Bologna - Plesso Ranzani	2	Università di Bologna - Plesso Ranzani	0106000020E610000001000000010300000001000000150000003E86D8AA6EB72640699725F03D40464024157C8967B72640BD81131B3D4046407B9054956CB72640AC5ED9603C40464084CA092472B72640A0B657303B404640E62FE35C79B726400069A44A39404640D10836AE7FB7264037CA558737404640E0AC776E90B726405238712832404640F76A91FEA8B726407A04920B294046409F34796FB1B7264064E8D8412540464050430A54B5B72640E88AADFB2240464063D75130BEB72640271763601D4046400FB9196EC0B726408681F80A1C404640C8D68E3DD6B726405B24ED461F40464043215DC713B826402C955C6A294046400D9E53DA2CB826403645DB8C2E4046408982740C23B826405F06088B2F4046401E4E603AADB726406556EF703B4046401CC2E73D84B72640454541953F404640AC12769B81B72640C8F54AB43F40464022F2A7D777B7264051F3FA383F4046403E86D8AA6EB72640699725F03D404640	Bologna
135	San Giovanni in Monte	2	San Giovanni in Monte	0106000020E61000000100000001030000000100000010000000737E2F2A4EB226402C1785B8CD3E4640C145DDBD92B22640EF09C84DC33E464018096D3997B22640FCFF3861C23E46401E6FF25B74B22640FFD59931BB3E464081BADCBB61B2264088FB2367BC3E46407A2F63AF1CB226401A750877C23E46405664744012B226406682E15CC33E46409B4EFC6200B226407E9065C1C43E46403931DA99F8B12640425E0F26C53E464070445266DEB1264071DC73AAC63E4640C4549F50F4B12640C5CFDAC8D03E4640BFE3254921B22640660F5949D03E4640A4B789A427B22640241A93B4D13E464023E06B6347B22640D82C978DCE3E4640D23EB1A94EB22640F0880AD5CD3E4640737E2F2A4EB226402C1785B8CD3E4640	Bologna
136	Università di Bologna	2	Università di Bologna	0106000020E61000000100000001030000000100000055000000BF3EDFBB72B62640F68AB84AC13F46402577D84466B62640CCB22781CD3F464033DE567A6DB62640CC22B9A1CE3F4640221741086DB62640784C384FD03F46402092C60D64B62640672783A3E43F46407BC3D89D49B62640F89E364F1A4046401A41199936B62640C79860DD1D404640CDDDF824C1B52640D9DEB8D6284046403E39AF5692B526406C30C3352D404640DDABFB6C89B52640A1FBCD1F2E404640C08D39741FB52640B4194C6837404640E789E76C01B5264007C776082D4046408EBC62FCEAB42640288870822540464049EBB996DAB42640D873E3271F4046407189C855D1B42640935DC4D21B404640A344A6D7C1B4264006A1174916404640694018D3A7B426401D7810960C404640471A811DA4B4264030E939330B40464031467FC39FB42640E399E150094046407AA290099DB4264067086C7308404640EC74D65D8FB4264005E5113702404640286D606177B4264087FC3383F83F464024A82BE972B42640875E903EF73F4640741B1E0C86B42640583C5002F63F464046A3F1FA82B4264089AC7F21F53F4640B875374F75B426405064F72EEF3F4640817B9E3F6DB4264022AA4B21EB3F4640F25CDF8783B42640F42BE79CE93F46404EA0E3FE7EB42640B933130CE73F46402EE6E786A6B42640F24A485AE03F4640523D3EC681B4264098350C7ACA3F4640297F52488DB42640EC7B1EEDC93F46406DF6515788B426404D7C5AEAC53F46408DC34FD2B2B426401913ACBBC33F46402CD1FEAC9EB42640025E0B1FB63F4640D4ED91729CB426400807D6CCB53F46408754AC753DB4264007B9E6E9B73F4640D32934B511B42640D7BE805EB83F46400DFFE9060AB426403D00F3DAB63F4640357227220DB426409D8F21B6AA3F4640089854C8F0B326401A0D2ABBAA3F4640AD3A6178DBB32640BC52E0AEA83F4640F7B2486EA8B32640B1F215EEA63F4640A56F2DEE9AB32640B73FBC53A63F4640D527147D99B3264029154328A53F4640CE9DAA8C90B3264005114EB0A43F4640302E55698BB3264058C7F143A53F46403A4E1B1F77B32640ACF996DEA33F4640E827E66A75B326402A91442FA33F4640E0BA624678B32640F0FACC599F3F46406429ED6877B32640327AC95A9E3F464089AF1B5B74B32640BCABC3769C3F4640F21CDB7C6DB326406F5C6B949A3F46405E9786866AB32640AC1E300F993F46404435255987B3264087DD770C8F3F4640EAB35E679EB32640E574A3D9863F464062180B9E9DB32640683F5244863F4640130AB6B695B3264045DF3884853F46404E3C0C5295B32640EC51B81E853F464097D2E92FAAB32640D6D9DA0C813F4640D9B6836CB4B3264024D97E8D7F3F464099BC0166BEB326402B40CA3E7E3F4640C31D5EC603B42640A6DC3301753F4640A4912AE510B4264022AAF067783F46408B975DE62AB426401DFC6948813F4640CE531D7233B4264046BD9646823F4640DF8AC40435B4264070E01F00823F4640C7B4DBD37AB4264091E398767B3F4640E8BE9CD9AEB4264088331A54763F4640DA21591BBEB42640E26AAEE4743F464053286618D2B42640E370E657733F464032E9EFA5F0B42640DEB9E644713F4640E326593D16B52640F7BF6DB76E3F4640E7502BF125B52640212BAEE06D3F4640E140481630B52640BC653D6B6D3F464091E744CC36B526400AD5720C6D3F464014DC59057BB526407DE47BEB683F464077C6AD388BB52640A721AAF0673F4640950F41D5E8B52640DA756F45623F4640CF0DF21F77B6264079E8BB5B593F46402EC088C78FB626400FAECACF573F4640D31EE516A9B62640577A6D36563F4640343C07E0B0B62640B0F380C3553F4640ECFBCB4983B626405CF40478C13F4640BF3EDFBB72B62640F68AB84AC13F4640	Bologna
137	Dipartimento di Filosofia e Comunicazione - Comunicazione	2	Dipartimento di Filosofia e Comunicazione - Comunicazione	0106000020E610000001000000010300000001000000210000002711E15F04AD2640F488D1730B404640A917D75306AD264071AAB5300B404640B39943520BAD2640665E58480A404640AFF1F4A512AD26405F5331DF0B404640419F234D17AD26407BEAA2320F404640A66F88A70DAD2640FD32182312404640BC1BB05010AD26402D509CED1B40464099D53BDC0EAD264098480E7D1C40464061E696B1FCAC26402B2A87BB1F4046402A7C6C81F3AC2640B44F11F120404640A2708797F1AC26406BC5ED86234046401B3DC8FCEDAC2640E1AD98B62440464002171A3ED8AC2640618E79782A404640D277126CB7AC26404634CBAF3040464015FA0560A8AC2640B05417F0324046408879A05FA5AC26406904769032404640E859FF9DA3AC2640B7A1BD5532404640ADB717E2A2AC26402E1AD76432404640E979DC5CA1AC2640049B2963324046402B4190CD9FAC2640AB69CD45324046405BB1BFEC9EAC26405D424F143240464086F425659CAC2640BD080907314046406F0B3B3190AC26409188DF032A40464076C075C58CAC2640C76D8F392A404640652431F77FAC2640B920B64F22404640E60E513BB2AC264016B2A9A91B404640E55E059DB5AC2640FE8980F91A4046401A19E42EC2AC2640AC4FDE6C18404640BD6257A4D3AC2640DE27A2BA14404640DFED8B95E2AC2640BC5D2F4D11404640B6DCF4C2F8AC2640F488D1730B4046409DA85B2CFBAC26402A5A14D10A4046402711E15F04AD2640F488D1730B404640	Bologna
138	Ex Bodoniana - Dipartimento di Farmacia e Biotecnologie	2	Ex Bodoniana - Dipartimento di Farmacia e Biotecnologie	0106000020E6100000010000000103000000010000000E00000016574BF03CB726402B1AC638DA3F46409FD5B8ED31B72640B5311B09D93F464014268C6665B72640BAFF7EE7CD3F464055B4835B88B72640008C67D0D03F4640855E7F129FB72640DC5328C1D13F4640F74DAB329DB7264058CBF852D33F4640FE4BAD52D5B7264016EA9F96D53F46403F7100FDBEB7264001FA7DFFE63F46406252D735B5B7264019B2158FE63F4640D80638CEB7B7264050B7A283E43F4640DBFD2AC077B726404DE438A6DD3F46409D6E34DB70B726400A03E0E9DF3F4640280582A55FB726404D6E6F12DE3F464016574BF03CB726402B1AC638DA3F4640	Bologna
139	Plesso Risorgimento	2	Plesso Risorgimento	0106000020E61000000100000001030000000100000019000000D77AD0FDE6A726405895D810773E4640D230218BD9A72640A6E727E66A3E46403FEF7CF5A7A72640C216BB7D563E4640984D8061F9A726402465E65D503E4640226A4716D5A726401A9249FC403E4640AD9113DCFEA726406F545D763E3E4640CC5B1A6437A826408AA9995A5B3E4640FCCB498336A8264075B0FECF613E46408FFD2C9622A9264069893A18563E4640F1C7A30A35A92640F0A88CDA583E4640C4C6061C53A926408DCD339B6C3E46403B9F4B8281A92640D5E18D716A3E46402A4FC532A2A92640E6632DF4773E46401C1318A18EA92640623722CE793E4640629115B2A9A926405E2D7766823E464007EE409DF2A82640CA7C51CC8B3E46406859F78F85A82640509033A8913E4640E85FDC572FA82640E4B96356943E464058D581621AA82640E0EBB5EA843E464074A37ECD28A8264035B401D8803E4640A006C20424A82640A2009BBD7D3E46404EC3A68416A826406B20A7F9743E46407DD92C4D00A82640AC23A2F3753E4640A3D2E352F0A72640AB09FDA7763E4640D77AD0FDE6A726405895D810773E4640	Bologna
140	Plesso Fanin	2	Plesso Fanin	0106000020E61000000100000001030000000100000019000000B42C4E6B89CF264070BC96EBC8414640C5591135D1CF2640AE9003C0C2414640C9BBD9D59AD02640E1230791B1414640D40A783EA8D02640379FDF9CB6414640477F1E59AFD026403EEC8502B64146408A839554B7D026408A4F4BBDB8414640FAEE5696E8D026403356F6B8CA414640B334A61600D12640ED4218E4D3414640924BD2EB05D126401D3D7E6FD3414640998D846C0FD126407A956BC0D641464092CD55F31CD1264057636424D6414640E4C8B9032BD1264012FA997ADD4146407029424530D126401BD82AC1E2414640CC6C46BC2BD126400D94CACAE5414640C0FDCA9420D12640E9CB1CDCE7414640F4A5B73F17D126400569C6A2E94146405B7C0A80F1D026403F47F5E7EC414640A5EBD33B26D02640E3BE7A81FE414640461850B9D3CF26401B01CB0006424640AC39403047CF264089CB9651D141464044183F8D7BCF2640916C640DCD4146406C38D15389CF26401992EE42CE414640A8CFC42A94CF26400E46915ACD41464093437A408FCF264009617F23CB414640B42C4E6B89CF264070BC96EBC8414640	Bologna
141	Università di Bologna - Plesso Berti Pichat	2	Università di Bologna - Plesso Berti Pichat	0106000020E610000001000000010300000001000000060000001229722DFFB62640CF8D9F7C30404640F6F0C05B7BB62640F672E9A91F40464071A719F78BB62640FFB1101D024046402F3F26080DB72640E8D19EDC00404640786572C520B726407F7912222A4046401229722DFFB62640CF8D9F7C30404640	Bologna
142	Piazza Antonino Scaravilli	2	Piazza Antonino Scaravilli	0106000020E6100000010000000103000000010000000700000091B932A836B42640430D9535A03F46406B08331246B42640A5CB51369B3F4640D4145C0762B42640442D72F49D3F46400A0CFE2378B42640BA579C20A03F4640DCBEA2B668B426405899DF1FA53F4640ED2B0FD253B42640651FBF12A33F464091B932A836B42640430D9535A03F4640	Bologna
143	Dipartimento di Arti Visive	2	Dipartimento di Arti Visive	0106000020E61000000100000001030000000100000024000000EAF29CE392B526403BBC314E8D3E4640416E75EF97B526407CF376DF8C3E4640B08D78B29BB52640FF4124438E3E46408BBF92509FB52640349765998F3E464033D13131A7B526406968A8F68E3E46405B6C49FDABB52640CF19AC938E3E4640FB383F6AB8B52640525A24928D3E464091D6732DB5B52640DC43673E8C3E4640D4E5DE0DB3B52640ADAB5D6E8B3E464040D01B38B1B526404285D9BA8A3E46402077B6ECB5B526402AB9D4528A3E4640D20AC2CBC2B526408A7F8E45893E4640BF23CF9AC4B5264036678EF6893E464023111AC1C6B52640243E1CC98A3E4640A8041FDECEB52640AD0DBA298A3E46409BAF928FDDB52640FB6882F2883E464007472465E6B5264055867137883E4640787B1002F2B52640FC40A841873E46401750036102B62640DF2D35E7853E4640EEB1F4A10BB62640D40FEA22853E4640626E522C12B62640A4D3049B843E4640EDD9CE520DB62640CFFCC5C7823E4640B3C755760BB626408E55EF15823E464050508A56EEB5264016A64AEF763E46408BEE6A03C1B52640912B50E67A3E4640611E8D9EB6B52640E797778B763E4640C5A63A89ADB526407E7D63BE723E46403CA64984A1B526407259E086733E46407B60110D9CB526407716180D743E4640E9256B798AB52640703903C8753E46407C8ED9A381B52640174A26A7763E46402D8084BC79B52640E1A6F56D773E4640BE26B5615EB526405C8E57207A3E4640307B7EBD67B52640F646AD307D3E464057CEDE196DB526409BC761307F3E4640EAF29CE392B526403BBC314E8D3E4640	Bologna
144	Dipartimento delle Arti - DAMSLab	2	Dipartimento delle Arti - DAMSLab	0106000020E6100000010000000103000000010000000800000054AD855968AB2640AD6296E24F404640268F029F7AAB264033816CA34B404640AA8DFBA078AB264093A9825149404640B187F6B182AB26409F854E1949404640E399869796AB264060048D9944404640CAF962EFC5AB2640750069A44A40464065E833FB97AB26402195BD005640464054AD855968AB2640AD6296E24F404640	Bologna
145	Aula Magna di Santa Lucia	2	Aula Magna di Santa Lucia	0106000020E6100000010000000103000000010000003500000024C2757BFFB1264065F4ED6EAF3E4640B42FEAA408B2264076734C71B03E4640839FDDC60BB2264017C737CAB03E4640F73361A010B22640DBC2F352B13E4640D2AD32AE13B22640BDD75AA9B13E4640D06D783018B22640FE501F37B23E4640A40A35F91CB226400BBD59DEB03E46402659E25C1EB2264046EFAF79B03E46401EA4A7C821B2264064C0A3D7B03E46400B2D46B824B2264017235C12B13E4640AABC789A27B226400B197E26B13E464043FF04172BB226409FD85427B13E4640B96BAE3F2EB2264082638511B13E464040E7244A31B226405EBBB4E1B03E4640C7629B5434B2264064647F8FB03E4640DE567A6D36B22640418E9C3BB03E46401969F34938B226401785B8CDAF3E464054C3239639B2264071FECB5AAF3E4640C44ABB873AB22640717495EEAE3E4640891865EC3AB22640B9F880E5AD3E4640124427953AB22640073AA462AD3E4640A7C17E9939B226407EFA74E1AC3E46408B1068FA36B22640619F4A17AC3E4640E60BB50133B22640FCABC77DAB3E4640231631EC30B22640370C303DAB3E4640CCFFF51B37B22640EBEAE97EA93E46401AD1877835B22640D97FF854A93E4640D58C56FF31B22640CDEBE3FCA83E464077ECB13E2FB22640279309AEA83E4640E24680892EB22640339DE799A83E4640DFC9028129B2264033E59E09A83E464063586A6226B22640FED1DCAFA73E464086F1892B1DB22640DA159FA7A63E464028999CDA19B226402885D448A63E46406346787B10B226401D0B653CA53E464005EE8A2A0DB226406A7A9ADDA43E4640D4884FF003B22640B2FE85D4A33E46404708EAEF00B2264065A9F57EA33E4640B5EA2928FBB12640477CDDD8A23E4640407E80FFF7B126407DA9447EA23E4640499B4FC2F1B12640B2B6CE64A43E464014FE56FCF0B12640FF81284EA43E464070B4E386DFB126407444BE4BA93E4640101C3CB8E0B12640B5334C6DA93E46402B48D85CDAB126403D3F3157AB3E46401ED66542DDB12640379666A9AB3E46404AE6FD24E3B1264054C37E4FAC3E46404F3BA17CE6B12640729472ADAC3E4640E1308793EAB12640ADDA3521AD3E4640C7DC103EEFB12640F558E9A4AD3E4640313FDC7AF2B1264054EB5800AE3E464050954AD3FBB12640E2E7BF07AF3E464024C2757BFFB1264065F4ED6EAF3E4640	Bologna
146	DIBINEM - sede di malattie odontostomatologiache e Chirurgia maxillo-facciale	2	Università di Bologna - Dipartimento Scienze Biomediche e Neuromotorie (DIBINEM) - Sede Malattie odontostomatologiache e Chirurgia maxillo-facciale	0106000020E6100000010000000103000000010000001F000000D134722722B526403414D2753C3F4640872B0C361AB526403E7958A8353F46407784D38217B526409F8D017E323F4640E973FFA215B526400B4A2C84303F464076D77ED70CB52640C30DF8FC303F4640CCCDDCE808B5264071A5434C2E3F4640582E652A0EB526401846D50A2E3F464006989E550BB526402B5BDA5F2C3F464085B1852007B5264062D630E8293F4640E74130FD01B52640EC9799E3263F4640C2D8E7D610B52640F2E43F49263F4640095ADCDA1DB526400BA30F4C243F46402935C52D30B52640EEBDAE15233F46409A94826E2FB5264036429A0C223F46408DA4935B49B526406742380B203F4640C16966D24BB52640E32FD230213F4640D8158E7B4EB526401252126D223F4640BDE9F1D654B526407C58B961253F4640BE26B5615EB526400E7679292B3F46407AAFB55263B52640B338AD252E3F46409D3DE13664B52640A1B316B02E3F46400376DABF57B526403B0213132F3F4640555458045AB52640EC585B67323F4640E9F989B95AB52640CE531D72333F4640240C03965CB52640DECC4301363F46401772B6CA5DB52640497DFE20373F46407AF76CC262B52640ACA690D03B3F4640BE51860552B526401D1ABBE93B3F4640EE5C18E945B526405E09490B3C3F46409344E5153EB526407C7E18213C3F4640D134722722B526403414D2753C3F4640	Bologna
147	Plesso Hercolani - UniBo	2	Plesso Hercolani - UniBo	0106000020E6100000010000000103000000010000001F0000007999BC5C1FB52640EAD78CC2E43E464017E247EB5EB526408EE733A0DE3E4640F286EA9C55B52640904FC8CEDB3E4640822A244F48B526408038FEFAD73E4640A1E128D42EB52640EF2076A6D03E464019CB4F0537B526400D54C6BFCF3E4640CFA513645FB5264086200725CC3E46402B6B9BE271B52640F86B578DCA3E4640546E47DD73B52640C26C020CCB3E464020E637F17AB52640FE42345FCA3E46406BC7C33181B526402E0F88C6C93E46405A208B7E7EB52640D5F7D0F4C83E4640727CFEC57DB526404C14C6BBC83E4640ECB7C02F3FB52640C7E93587B53E4640BDF7DCAE3CB52640C7455ACFB53E4640126CB7B821B52640FB9463B2B83E4640524255F1EBB4264097A4D70BAA3E4640CD960744E3B426403DE30C0FAB3E4640E0302CDA77B42640CCA0359AB73E4640D51B5A0982B426403046C950BA3E46408702113D84B4264017BC43E5BA3E4640561F590A92B4264069667792BE3E46405BBCB3D194B4264039C8354FBF3E46400F12FD35B4B42640F3A0EAA1C73E464046C4DED5BCB42640EC7B1EEDC93E4640DEE68D93C2B426408035BD7ACB3E4640AFFBD86ECCB426409DE6D319CE3E4640F41F2D29D2B426406C5CFFAECF3E46400F869565E3B4264099CEF34CD43E46408D1E094504B526400061962CDD3E46407999BC5C1FB52640EAD78CC2E43E4640	Bologna
148	Johns Hopkins University	2	Johns Hopkins University	0106000020E610000001000000010300000001000000090000008ED9A38169B6264037B176CA593F46408192020B60B6264017DF066B523F4640468B7D1354B6264029D42E01533F46407F880D164EB626404FA84CD64D3F46400D3E2883FEB526404E9CDCEF503F46408FF172220BB62640A910340B593F46409D103AE812B62640B292A0095E3F4640A842F28414B62640B202322A5F3F46408ED9A38169B6264037B176CA593F4640	Bologna
149	McDonald's	3	Cucina: burger | Takeaway	0101000020E61000009C4EB2D5E5CC264061AD35EF933C4640	Bologna
150	Burger King	3	Cucina: burger | Takeaway	0101000020E6100000B51089E711B02640D2A2E30FAB404640	Bologna
151	Il Panino	3	Cucina: sandwich	0101000020E61000004C87F31549B02640EAB70ABD59404640	Bologna
152	La Tua Piadina	3	Cucina: italian	0101000020E61000000C7F3CAA50B326404ED944C1E73E4640	Bologna
153	McDonald's	3	Cucina: burger | Takeaway	0101000020E6100000055DB1755FB02640091DCFC2F93F4640	Bologna
154	Indegno	3	Cucina: italian	0101000020E6100000EC0F392284B42640845671F4423F4640	Bologna
155	Wei Tea - Bubble Tea & Poke	3	Cucina: bubble_tea;chinese	0101000020E6100000F1A611E96DB22640A9F34D3F4D3F4640	Bologna
157	Le Salentine	3	Cucina: italian	0101000020E6100000A26F1CC242B72640DC566941DE3F4640	Bologna
158	KOI	3	Cucina: chinese	0101000020E6100000C0E78711C2B32640D253E410713F4640	Bologna
159	BE'MO	3	Cucina: chinese	0101000020E610000060F93DFBDBB3264064CA87A06A3F4640	Bologna
160	INQUCINA	3	Cucina: deli	0101000020E61000004E80BCB266BB2640ADA1D45E443F4640	Bologna
161	Largo Respighi	3	Cucina: pizza	0101000020E61000003B133F6B23B32640528836B68D3F4640	Bologna
162	Hamerica's	3	Cucina: burger;diner;american	0101000020E61000009294F430B4AE264017FF2DB76A414640	Bologna
163	Le Bacchette	3	Cucina: chinese	0101000020E6100000A67F492A53B426406B30687CBA3F4640	Bologna
164	Bonelli Burgers	3	Cucina: burger	0101000020E6100000982B28B110AE26403F631525D73F4640	Bologna
165	Pizza Leggera	3	Cucina: pizza	0101000020E610000002F8020EFCAF264008C7D1C19F404640	Bologna
166	Pizzeria Da Youssef	3	Cucina: kebab;pizza	0101000020E610000004A9B981A7B9264056FD005AA93F4640	Bologna
167	O Fiore Mio	3	Cucina: italian_pizza	0101000020E6100000CEAACFD556AC264058BCA2A53C3F4640	Bologna
168	Bottega Portici - 2 Torri	3	Cucina: regional | Takeaway	0101000020E6100000F5A2D1787DB126401F381DB74E3F4640	Bologna
169	Pizzeria Il Monello	3	Cucina: pizza | Takeaway	0101000020E6100000DCED1FB017CB26407D6CDCAC0B3D4640	Bologna
170	Il bello della pizza	3	Cucina: pizza	0101000020E6100000189BB1C3F3A92640138E6A227D404640	Bologna
171	Quebracho - Pollo a La Brasa	3	Cucina: chicken | Takeaway	0101000020E610000099C98168F7B12640FACCFEE5FF414640	Bologna
172	novanta6 Pizza	3	Cucina: pizza | Takeaway	0101000020E61000002DA924FC9CB42640DEBB17A9413F4640	Bologna
173	Mo Mortadella Lab	3	Cucina: sandwich	0101000020E6100000A8B2DE5E88AF2640600C9BB7A03F4640	Bologna
174	Flower Burger	3	Cucina: burger | Takeaway	0101000020E6100000ECF1E780C9AE26406DC7D45DD93F4640	Bologna
175	Sensazioni	3	Cucina: piadina; regional	0101000020E6100000F174F8B53FA126403147EA984E404640	Bologna
176	Bonelli	3	Cucina: burger | Takeaway	0101000020E6100000B4780CEAB6C326407963F7D3353D4640	Bologna
177	Timo Pizzeria	3	Cucina: pizza	0101000020E6100000F365B33401A4264027D2A2E30F404640	Bologna
178	Chicken Hut	3	Cucina: burger;kebab	0101000020E6100000B4A1AC29DAAE264088F71C588E414640	Bologna
179	Green Poké Bologna	3	Cucina: poke	0101000020E6100000C5FAAB6CC4AC26404B6B1D66793F4640	Bologna
180	Regina Sofia Pizza e Sfizi	3	Cucina: pizza	0101000020E6100000FB3A70CE88B62640CA52EBFD463F4640	Bologna
181	Zero Due	3	Cucina: sushi; dimsum; asian; japanese; chinese	0101000020E610000059B44AFAC5BA264020FF16AE583E4640	Bologna
182	L'asporto	3	Cucina: sandwich	0101000020E6100000D6880563E9B02640BBAF6FCC573F4640	Bologna
183	Cou Cou Street Food Bologna	3	Cucina: asian;korean	0101000020E61000002882380F27B026401B24E93F10404640	Bologna
184	Migarba	3	Cucina: sandwich	0101000020E610000030478FDFDBAC26402DBA5054913F4640	Bologna
185	Crock!	3	Cucina: italian;sandwich	0101000020E61000006CA285BAFEAF26401C0F1192603F4640	Bologna
186	Ben Cotta	3	Cucina: pizza	0101000020E6100000D77D117EF3C02640ED8D10D4DF3B4640	Bologna
187	Riso	3	Cucina: chinese	0101000020E610000093FE5E0A0FBE2640BDEAB765763E4640	Bologna
188	Nabò Pizza & Sfizi	3	Cucina: pizza	0101000020E610000045509033A8BD264054628D695C3E4640	Bologna
189	MAIZ Taqueria	3	Cucina: mexican | Takeaway	0101000020E6100000B4C6455ACFB9264062ED94B31C3F4640	Bologna
190	IAAD Bologna - Istituto d'Arte Applicata e Design	5	Tipo ufficio: educational_institution (Bologna)	0101000020E610000084DFE1D121B326409F33B3E08F404640	Bologna
191	Putti	6	Operatore: TPER	0101000020E61000003AA05B9EBDB1264069A7E672833D4640	Bologna
192	Piazzale Bacchelli	6	Operatore: TPER	0101000020E61000002D149FF133B02640D4E1D7FE843D4640	Bologna
193	Porta Saragozza Frassinago	6	Operatore: TPER	0101000020E6100000EA9CFA9BABA92640C27D2E64BF3E4640	Bologna
194	Sant'Isaia Piazza Malpighi	6	Operatore: TPER	0101000020E6100000736C98FCAAAB26400AB144B1263F4640	Bologna
195	Piazza San Francesco	6	Operatore: TPER	0101000020E6100000F01307D0EFAB2640623FD532633F4640	Bologna
196	Andrea Costa	6	Operatore: TPER	0101000020E610000009D2D6D2EDA6264001ACE9D55B3F4640	Bologna
197	Dagnini	6	Operatore: TPER	0101000020E6100000510B6F206EBC2640EC04EA831B3D4640	Bologna
198	C.S. Pescarola	6	Operatore: TPER	0101000020E6100000E3569CC5E6A2264084166DE92C434640	Bologna
199	Tanari	6	Operatore: TPER	0101000020E6100000CC15945808A926404B3CA06CCA404640	Bologna
200	Spina	6	Operatore: TPER	0101000020E61000005BB4006DABC12640214322C89C3E4640	Bologna
201	Etruria	6	Operatore: TPER	0101000020E6100000354EF9C6C6C2264096B20C71AC3E4640	Bologna
203	Chiesa Nuova	6	Operatore: TPER	0101000020E6100000E5B4A7E49CBC264004C35ECDA63C4640	Bologna
204	Santa Viola	6	Operatore: TPER	0101000020E61000007100FDBE7F9B264068FFA8F2E2404640	Bologna
205	Toscana Pavese 2	6	Operatore: TPER	0101000020E6100000F06EC04241B826407A5C0AFE6D394640	Bologna
206	San Ruffillo	6	Operatore: TPER	0101000020E6100000D82E6D382CBD26408471265C7E3A4640	Bologna
208	Byron	6	Operatore: TPER	0101000020E61000004D028A4798B82640F7BCD17DEF454640	Bologna
209	Fiera Palazzo Congressi	6	Operatore: TPER	0101000020E610000087FC3383F8B8264068B51BD885414640	Bologna
210	Villa Ranuzzi	6	Operatore: TPER	0101000020E6100000651E543DF48C2640BC5D2F4D113F4640	Bologna
211	De Gama	6	Operatore: TPER	0101000020E61000004F1432A193A72640BDBE7BECD3424640	Bologna
212	Santa Viola	6	Operatore: TPER	0101000020E6100000AD1B4A48FF9A26401BFE8980F9404640	Bologna
213	Molinelli	6	Operatore: TPER	0101000020E610000055C444DECDBA2640DA09E5338F3C4640	Bologna
214	Molinelli	6	Operatore: TPER	0101000020E6100000D7FE29B05BBB26408F75CCD47F3C4640	Bologna
215	Parisio	6	Operatore: TPER	0101000020E61000005B327D6594BD264065B3D9475D3C4640	Bologna
216	Monte Cuccolino	6	Operatore: TPER	0101000020E6100000108F691261A826406F1C6789843B4640	Bologna
217	Monte Cuccolino	6	Operatore: TPER	0101000020E6100000D95A046B41A82640C3459330783B4640	Bologna
218	Bivio Gaibola	6	Operatore: TPER	0101000020E6100000A65714C0DEA62640A4552DE9283B4640	Bologna
219	Ca` Di Savini	6	Operatore: TPER	0101000020E61000008EE733A0DEA42640ABE23213B13A4640	Bologna
220	Colli	6	Operatore: TPER	0101000020E61000002A0C80A77FA32640BCF7263C573A4640	Bologna
221	Forte	6	Operatore: TPER	0101000020E61000009A7ADD2230A226405DD1F7640F3A4640	Bologna
222	Paderno	6	Operatore: TPER	0101000020E6100000A081A2C38DA12640589D8B7560394640	Bologna
223	Tiro Al Piattello	6	Operatore: TPER	0101000020E61000002FCD63833B9E264006465ED6C4384640	Bologna
224	Cavaioni	6	Operatore: TPER	0101000020E61000003E7782FDD79D264025085740A1384640	Bologna
225	Piazza Aldrovandi	6	Operatore: TPER	0101000020E6100000AC634B4519B42640617C8791143F4640	Bologna
226	Porta Santo Stefano	6	Operatore: TPER	0101000020E61000009FB18A92EBB52640EA48E471073E4640	Bologna
227	San Paolo di Ravone	6	Operatore: TPER | Linee: 14, 21, 61, 89	0101000020E6100000C36169E047A5264054E1CFF0663F4640	Bologna
228	Bombicci	6	Operatore: TPER	0101000020E61000004A737511F0C9264026F098CB573D4640	Bologna
229	Lavino di Mezzo Chiesa	6	Operatore: TPER	0101000020E61000007FB3DEB9417A26402AFAE879DC434640	Bologna
230	Magnani	6	Operatore: TPER	0101000020E61000009B9F2CC60AA02640676BD84A433F4640	Bologna
231	Battaglia	6	Operatore: TPER	0101000020E61000006E991DF34BC22640ED647094BC3B4640	Bologna
232	Albornoz	6	Operatore: TPER	0101000020E6100000214FDC3BB4C12640740D33349E3B4640	Bologna
233	Cherubini	6	Operatore: TPER	0101000020E61000005E8B7159E0C22640187D6022393C4640	Bologna
234	Villa Mazzacorati	6	Operatore: TPER	0101000020E61000001583D1F6F9BD2640947A60110D3C4640	Bologna
235	Direttissima	6	Operatore: TPER	0101000020E61000000E2439AAE4BD26402A221EE4503B4640	Bologna
236	Pilastro Vecchio	6	Operatore: TPER	0101000020E61000009B5F28BBF4C6264031A479B6FD404640	Bologna
237	Pilastro	6	Operatore: TPER	0101000020E610000037B68DF5C3CA2640D9243FE257414640	Bologna
238	Croara Bivio	6	Operatore: TPER	0101000020E61000005EFD8E9724CD2640DEB06D51663B4640	Bologna
239	San Paolo di Ravone	6	Operatore: TPER	0101000020E61000004DBC033C69A52640A2C6CE25663F4640	Bologna
240	Crocetta	6	Operatore: TPER	0101000020E6100000776FA01BF5A326401867C2E5673F4640	Bologna
241	Andrea Costa	6	Operatore: TPER | Linee: 14, 21, 61, 89	0101000020E61000006806F1811DA72640A80AFC975A3F4640	Bologna
242	Martini	6	Operatore: TPER | Linee: 14, 21, 61, 89	0101000020E6100000A1C26C5DC5A126401F0D4C135B3F4640	Bologna
245	Ospedale Sant'Orsola	6	Operatore: TPER, Autoguidovie	0101000020E6100000726A0CDF67B92640A4497375113F4640	Bologna
246	Porta San Vitale	6	Operatore: TPER	0101000020E6100000A4E9A2D755B72640738C1A02363F4640	Bologna
247	Massarenti	6	Operatore: TPER	0101000020E6100000FD9474DE10BC2640DA4E006A0F3F4640	Bologna
248	Magnani	6	Operatore: TPER | Linee: 14, 21, 61, 89	0101000020E61000007F70992E1FA026402AA913D0443F4640	Bologna
249	Massarenti	6	Operatore: TPER	0101000020E6100000E1A7BBFC98BC2640982B28B1103F4640	Bologna
250	Sant'Egidio	6	Operatore: TPER	0101000020E6100000F57A9C0E09B8264021F7BE02E23F4640	Bologna
251	Porta San Donato	6	Operatore: TPER	0101000020E6100000CAD70A3FDDB52640B3507CC6CF3F4640	Bologna
252	Porta San Donato	6	Operatore: TPER	0101000020E61000004B4C61EF0FB52640F5D2B947DB3F4640	Bologna
253	Cherubini	6	Operatore: TPER	0101000020E6100000F6B52E3542C3264014E0055B363C4640	Bologna
254	Parisio	6	Operatore: TPER	0101000020E6100000B0BF362C57BD26405D154D0C6E3C4640	Bologna
255	Villa Mazzacorati	6	Operatore: TPER	0101000020E610000051DA1B7C61BE2640E9995E622C3C4640	Bologna
256	Castiglione	6	Operatore: TPER	0101000020E61000000D3C52D8A0B22640314278B4713D4640	Bologna
257	Piazzale Bacchelli	6	Operatore: TPER	0101000020E61000007C5CC07053B026408DF3925A833D4640	Bologna
258	Cavazzoni	6	Operatore: TPER	0101000020E610000063ADEB6179C12640B4EE7AC4433C4640	Bologna
259	San Ruffillo	6	Operatore: TPER	0101000020E6100000101E12633EBD2640F0D46D9A883A4640	Bologna
260	Toscana Pavese 1	6	Operatore: TPER	0101000020E610000059DAA9B9DCB82640A48E8EAB91394640	Bologna
261	Toscana Pavese 1	6	Operatore: TPER	0101000020E6100000BC38961C1CB92640E82BED79A3394640	Bologna
262	Toscana Pietro Da Anzola	6	Operatore: TPER	0101000020E6100000C071BE7DC2BA2640EBB2F391EF394640	Bologna
263	Ponte Savena	6	Operatore: TPER	0101000020E6100000ACB310D374BC2640D3CBDE08413A4640	Bologna
264	Toscana Pavese 2	6	Operatore: TPER	0101000020E6100000CC0061F1E5B726402BA1606B5B394640	Bologna
265	Croara Bivio	6	Operatore: TPER	0101000020E61000005E036C51B0CC26405FCE119E753B4640	Bologna
266	Resto Del Carlino	6	Operatore: TPER	0101000020E6100000BE9A4D918DD52640D235936FB63F4640	Bologna
267	Villanova Mattei	6	Operatore: TPER	0101000020E6100000FBF3233438D82640DA52ACBFCA3F4640	Bologna
268	Gandino	6	Operatore: TPER	0101000020E61000003B3F202B53B7264065F95F538C3D4640	Bologna
269	Svevo	6	Operatore: TPER	0101000020E610000043C5387F13CA26408A2947B714414640	Bologna
270	Magazzari	6	Operatore: TPER	0101000020E61000002A64F899C4BE2640465B3A8B83404640	Bologna
271	Porta San Vitale	6	Operatore: TPER	0101000020E6100000908FCCD9F1B52640349E08E23C3F4640	Bologna
272	Croce di Camaldoli	6	Operatore: TPER	0101000020E610000015E46723D7BD26401C0EA6BCB13B4640	Bologna
273	Varthema	6	Operatore: TPER	0101000020E6100000FD48B65FE3BB2640009B62C4F43C4640	Bologna
274	Villa Mazzacorati	6	Operatore: TPER	0101000020E610000052657330F6BD2640BA90FDE2083C4640	Bologna
275	Varthema	6	Operatore: TPER	0101000020E6100000A35A441493BB2640663387A4163D4640	Bologna
276	Angelo Custode	6	Operatore: TPER	0101000020E6100000ED3257618EBD2640D0381E7DDD3A4640	Bologna
277	Angelo Custode	6	Operatore: TPER	0101000020E6100000887FD8D2A3BD2640E6A8482AF83A4640	Bologna
278	Chiesa Nuova	6	Operatore: TPER	0101000020E6100000CF0C874AC8BC264068A730009E3C4640	Bologna
279	Direttissima	6	Operatore: TPER	0101000020E6100000B5B05D90E3BD264036D318085D3B4640	Bologna
280	Toscana Pietro Da Anzola	6	Operatore: TPER	0101000020E6100000390F27309DBA26405F24592CEA394640	Bologna
281	Ragno	6	Operatore: TPER	0101000020E6100000B35CDB8074BA26402471A0D1673D4640	Bologna
282	Ragno	6	Operatore: TPER	0101000020E61000005974A1A822BB26409C1F35DC363D4640	Bologna
283	Sterlino	6	Operatore: TPER	0101000020E6100000D1782288F3B82640323212EB9E3D4640	Bologna
284	Sterlino	6	Operatore: TPER	0101000020E6100000822C55B318BA2640CD0182397A3D4640	Bologna
285	Murri	6	Operatore: TPER	0101000020E6100000441669E21DB82640163A0A6BBE3D4640	Bologna
286	Porta Santo Stefano Rosa Parks	6	Operatore: TPER	0101000020E61000006017EA5509B72640C8C8A365EE3D4640	Bologna
287	Byron	6	Operatore: TPER	0101000020E61000001E4D9AAB8BB826400C63C1B3F3454640	Bologna
288	Ospedale Maggiore Maternità	6	Operatore: TPER	0101000020E610000013B875374FA126401805C1E3DB404640	Bologna
289	Lino	6	Operatore: TPER	0101000020E6100000DACBB6D3D69C264022B193B0253F4640	Bologna
290	Largo Lercaro	6	Operatore: TPER	0101000020E6100000736D03D259BD264079F1344F643D4640	Bologna
291	Largo Lercaro	6	Operatore: TPER	0101000020E6100000B6589B1084BD26409C3AEA43723D4640	Bologna
292	Certosa	6	Operatore: TPER	0101000020E6100000C87FDCD9B29B26406AA2CF47193F4640	Bologna
293	Certosa	6	Operatore: TPER	0101000020E6100000F34AA313539B26400068DEBB173F4640	Bologna
294	Stadio	6	Operatore: TPER	0101000020E61000000B4E33935E9E2640BC163E6C333F4640	Bologna
295	Beroaldo	6	Operatore: TPER	0101000020E6100000D91B21A8BFBB2640B61D09EA4A404640	Bologna
296	Calindri	6	Operatore: TPER	0101000020E61000005A379490FEBD2640AED117E714404640	Bologna
297	Dagnini	6	Operatore: TPER	0101000020E61000002F84413E8DBC26409BD9F85D223D4640	Bologna
298	Duse	6	Operatore: TPER	0101000020E6100000E27904920BBD26401F6BA1BF2B404640	Bologna
299	Laura Bassi	6	Operatore: TPER	0101000020E6100000D5E6A49CD4BC26404C9D91521A3E4640	Bologna
300	Vermiglia	6	Operatore: TPER	0101000020E6100000C286A757CABE264068EE7C9AEE3E4640	Bologna
301	Fioravanti Piazza Liber Paradisus	6	Operatore: TPER	0101000020E6100000F7C4DF9B4BAE26400F6503441C414640	Bologna
302	Tiarini	6	Operatore: TPER	0101000020E610000032433E4393AF2640758CD0741B414640	Bologna
303	Piazzale Bacchelli	6	Operatore: TPER	0101000020E610000002EA173614B0264063CAD12D853D4640	Bologna
304	Piazza Dei Colori	6	Operatore: TPER	0101000020E6100000C1B79F4264CB2640984C158C4A3F4640	Bologna
305	Piazza Dei Colori	6	Operatore: TPER	0101000020E610000071B43E4052CB2640C2137AFD493F4640	Bologna
306	Barelli	6	Operatore: TPER	0101000020E6100000F745F8CDB3CC2640C921E2E6543F4640	Bologna
307	Rotonda Mezzini	6	Operatore: TPER	0101000020E61000001866FC5646C2264006EF50B92E3B4640	Bologna
308	Rotonda Mezzini	6	Operatore: TPER	0101000020E610000075DBCF7355C2264024DAE9622E3B4640	Bologna
309	Rotonda Mezzini	6	Operatore: TPER	0101000020E6100000E052848A60C22640CF17D6E8303B4640	Bologna
310	Autostazione	6	Operatore: TPER	0101000020E6100000E4F96761AAB026405E4FCF166B404640	Bologna
311	Colombarola	6	Operatore: TPER	0101000020E6100000D149A58E44B62640A54F06A282454640	Bologna
312	Piazza dell'Unità	6	Operatore: TPER	0101000020E61000003C28CD8BB8B12640B36AC6585C414640	Bologna
313	Piazza dell'Unità	6	Operatore: TPER	0101000020E61000003CFDFBE7C4B126407E2F2A4E5A414640	Bologna
314	Marescalchi	6	Operatore: TPER	0101000020E610000090430E5BC4B52640136F53F2A0454640	Bologna
315	Alemanni	6	Operatore: TPER	0101000020E6100000A8604326CFBB2640DDF75E32443E4640	Bologna
316	Alemanni	6	Operatore: TPER	0101000020E61000004959D0C5F0BA264055F833BC593E4640	Bologna
317	Calabria	6	Operatore: TPER	0101000020E6100000CF60F82DDFC326402A8991CAB93C4640	Bologna
318	Calabria	6	Operatore: TPER	0101000020E6100000F2B5679604C4264033953435BF3C4640	Bologna
319	Chiesa San Lorenzo	6	Operatore: TPER	0101000020E61000000F09DFFB1BC42640A0E238F06A3C4640	Bologna
320	Chiesa San Lorenzo	6	Operatore: TPER	0101000020E610000041A9AC5C5EC326409610621D7D3C4640	Bologna
321	Fermi	6	Operatore: TPER	0101000020E6100000C98A86318EBE2640E1229CBB023E4640	Bologna
322	Fermi	6	Operatore: TPER	0101000020E6100000C1FF56B263BF2640AAC99DE3ED3D4640	Bologna
323	Firenze	6	Operatore: TPER	0101000020E61000002484A2D4B9C526407FD0C4854D3C4640	Bologna
324	Firenze	6	Operatore: TPER	0101000020E6100000A2C15C4189C52640A2410A9E423C4640	Bologna
325	Laura Bassi	6	Operatore: TPER	0101000020E61000002C4DA5FA29BD2640171D7F58253E4640	Bologna
326	Laura Bassi	6	Operatore: TPER	0101000020E610000086C1A15CBFBD2640E326593D163E4640	Bologna
327	Longo Cavazzoni	6	Operatore: TPER	0101000020E61000000D79BAA937C526409FFC8282F73B4640	Bologna
328	Longo	6	Operatore: TPER	0101000020E6100000167B794B83C42640FD2488049D3B4640	Bologna
329	Longo	6	Operatore: TPER	0101000020E61000000A021A5BBEC426403419E9A0A63B4640	Bologna
330	Mazzoni	6	Operatore: TPER	0101000020E6100000E1197E816AC52640205B3BF6583C4640	Bologna
331	Mazzoni	6	Operatore: TPER	0101000020E610000097FE25A94CC52640739B15F6593C4640	Bologna
332	Milano	6	Operatore: TPER	0101000020E61000008D00B8A349C32640583101648D3C4640	Bologna
333	Piazzale Atleti Azzurri	6	Operatore: TPER	0101000020E610000015F3BDD06DC3264074E151746E3B4640	Bologna
334	Piazzale Atleti Azzurri	6	Operatore: TPER	0101000020E61000000EB5125F92C326401BDE077B6E3B4640	Bologna
335	Brini	6	Operatore: TPER	0101000020E6100000796BAA381FB826404B3558DD8F444640	Bologna
336	Tuscolano	6	Operatore: TPER	0101000020E610000022591BBEE0B6264002E49535FB434640	Bologna
337	Bertalia	6	Operatore: TPER	0101000020E6100000E9C36977FE9F2640656DF882BB424640	Bologna
338	ITC Luxemburg	6	Operatore: TPER	0101000020E61000008AB2124E669F26402D6BAC0ECA414640	Bologna
339	Pane	6	Operatore: TPER	0101000020E610000030270DDA50A62640A69BC420B0424640	Bologna
340	Pane	6	Operatore: TPER	0101000020E6100000D855928664A6264066EF31FDB7424640	Bologna
341	Negri	6	Operatore: TPER	0101000020E6100000FEEDB25F77CA264007184CB2C4414640	Bologna
342	Tanari	6	Operatore: TPER	0101000020E6100000545D1B857FA826407DDB5DB1D0404640	Bologna
343	Piazza dei Martiri	6	Operatore: TPER	0101000020E61000006A920EC5D3AD2640A863DF5F4E404640	Bologna
344	Fiera Palazzo Congressi	6	Operatore: TPER	0101000020E6100000F60D4C6E14B92640993FF04284414640	Bologna
345	Fiera Palazzo Congressi	6	Operatore: TPER	0101000020E6100000720F536C16B92640A8339CD77D414640	Bologna
346	Fiera Palazzo Congressi	6	Operatore: TPER	0101000020E6100000C212B46E28B9264000039C397F414640	Bologna
347	Villa Ranuzzi	6	Operatore: TPER	0101000020E610000032B32A1D078D26406B8B21EF0B3F4640	Bologna
348	Ghisello	6	Operatore: TPER	0101000020E6100000E3B0EA628999264056815A0C1E3F4640	Bologna
349	Ghisello	6	Operatore: TPER	0101000020E610000040B9122631992640B2852007253F4640	Bologna
350	Baraccano	6	Operatore: TPER	0101000020E6100000F0106B9670B52640A47213B5343E4640	Bologna
351	Cricca	6	Operatore: TPER	0101000020E6100000810E4E9F78C526403D27BD6F7C3C4640	Bologna
352	Cricca	6	Operatore: TPER	0101000020E6100000B5CF19074DC52640B6589B10843C4640	Bologna
353	Garganelli	6	Operatore: TPER	0101000020E6100000D9171A9991B32640D218ADA3AA3E4640	Bologna
354	Garganelli	6	Operatore: TPER	0101000020E61000005D77A9C76CB326405D6DC5FEB23E4640	Bologna
355	Orti	6	Operatore: TPER	0101000020E6100000302DEA93DCBD2640F66FA829133D4640	Bologna
356	Orti	6	Operatore: TPER	0101000020E610000052CCE6165FBD26403E53F9E81E3D4640	Bologna
357	Ospedale Bellaria	6	Operatore: TPER	0101000020E6100000A62490B701C826403320D6766E3B4640	Bologna
358	Po	6	Operatore: TPER	0101000020E61000004261AB5F44C22640860C9A4CCB3C4640	Bologna
359	Po	6	Operatore: TPER	0101000020E61000005166834C32C22640C5E97F14D03C4640	Bologna
360	Ragno	6	Operatore: TPER	0101000020E61000008D6E7319EDBB26409D56C0F3413D4640	Bologna
361	Roma	6	Operatore: TPER	0101000020E610000092D5085806C8264040321D3A3D3C4640	Bologna
362	Roma	6	Operatore: TPER	0101000020E610000093A23AC20EC82640B6B86BAE3F3C4640	Bologna
363	La Piccionaia	6	Operatore: TPER	0101000020E610000097A2A6A7D97D264096A7BDD243414640	Bologna
364	Rigosa	6	Operatore: TPER	0101000020E610000006781C50807A2640F9C0E9B875414640	Bologna
365	Siepelunga	6	Operatore: TPER	0101000020E610000062122EE411B826409725F03D123D4640	Bologna
366	Funivia	6	Operatore: TPER	0101000020E6100000AB71DB638E9A26408F6CAE9AE73E4640	Bologna
367	Marcello	6	Operatore: TPER	0101000020E61000009C926236B7C02640B3BDCC66C43B4640	Bologna
368	Stadio Falchi	6	Operatore: TPER	0101000020E61000008F7DDAF2DBC126406CA45B655C3B4640	Bologna
369	Stadio Falchi	6	Operatore: TPER	0101000020E6100000AAD5575705C22640D06053E7513B4640	Bologna
370	Benedetto Marcello	6	Operatore: TPER	0101000020E6100000C27751AA33C12640CEC7105BD53B4640	Bologna
371	Albornoz	6	Operatore: TPER	0101000020E610000024EF1CCA50C12640AA262D019D3B4640	Bologna
372	Marcello	6	Operatore: TPER	0101000020E6100000597FF0468BC02640C7CC4FBBA93B4640	Bologna
373	Albornoz	6	Operatore: TPER	0101000020E61000004D6551D845C126402B91FAA1883B4640	Bologna
374	Giardini Margherita	6	Operatore: TPER	0101000020E610000054D0A39872B42640F34E4F690E3E4640	Bologna
375	Porta Castiglione	6	Operatore: TPER	0101000020E6100000145333B5B6B22640932FB2AE1B3E4640	Bologna
376	Porta Santo Stefano	6	Operatore: TPER	0101000020E6100000B0045262D7B62640D2AD32AE133E4640	Bologna
377	Giardini Margherita	6	Operatore: TPER	0101000020E61000001346B3B27DB426405C97755A123E4640	Bologna
378	Porta Castiglione	6	Operatore: TPER	0101000020E6100000CDC75AE8EFB22640FCAB22371E3E4640	Bologna
379	Gandino	6	Operatore: TPER	0101000020E6100000A8D19AD5F1B626408CB6CFCF793D4640	Bologna
380	Saffi	6	Operatore: TPER	0101000020E610000031732612F1A32640CF90E0FC3C404640	Bologna
381	Cinta Daziaria	6	Operatore: TPER	0101000020E6100000FA3EC16AD1932640B78CE5A782414640	Bologna
382	Berretta Rossa	6	Operatore: TPER	0101000020E61000000AFC3CA1329D26408470BB86CF404640	Bologna
383	Beolco	6	Operatore: TPER	0101000020E61000002AEF99DB73BF2640A40689A361404640	Bologna
384	Ristori	6	Operatore: TPER	0101000020E6100000D88F5E1E7CBE2640C47B0E2C47404640	Bologna
385	Piazza Roosevelt	6	Operatore: TPER	0101000020E61000006302C81A3FAE2640E118B8F2483F4640	Bologna
386	Pontelungo	6	Operatore: TPER	0101000020E61000008501F0F4EF972640D7F7E12021414640	Bologna
387	Cinta Daziaria	6	Operatore: TPER	0101000020E61000004A2F206A919326407A7C314A86414640	Bologna
388	Timavo	6	Operatore: TPER	0101000020E610000015D8ADAFBFA22640FF9C386F52404640	Bologna
389	Saffi	6	Operatore: TPER	0101000020E6100000CB0E9656E8A42640783760A120404640	Bologna
390	Caruso	6	Operatore: TPER	0101000020E6100000FFFA3262B0B82640263ACB2C423D4640	Bologna
391	Prati di Caprara	6	Operatore: TPER	0101000020E6100000302306CB229E264077A45588A2404640	Bologna
392	Faggiolo	6	Operatore: TPER	0101000020E6100000211510A49C912640E11D2AD725414640	Bologna
393	Pomponazzi	6	Operatore: TPER	0101000020E6100000DA102DC3C9C72640F008B831873D4640	Bologna
394	Pomponazzi	6	Operatore: TPER	0101000020E6100000867071F9B4C72640C60D0929893D4640	Bologna
395	Piazza San Martino	6	Operatore: TPER | Con pensilina	0101000020E6100000E758390F82B12640F09EA8119F3F4640	Bologna
396	Pavese	6	Operatore: TPER	0101000020E610000095CA259F68B82640F4103235AE394640	Bologna
397	Piazza dei Martiri	6	Operatore: TPER	0101000020E6100000C2C2499A3FAE2640F2BCAF253F404640	Bologna
398	Indipendenza Mille	6	Operatore: TPER	0101000020E610000089FA134B80B02640A67C08AA46404640	Bologna
399	Piazza Malpighi	6	Operatore: City Red Bus	0101000020E6100000CE82F52455AC2640B79C4B71553F4640	Bologna
400	Bovi Campeggi	6	Operatore: TPER	0101000020E6100000E88F1FE0FFA92640E48F5841C2404640	Bologna
401	Porta San Vitale	6	Operatore: TPER	0101000020E6100000E3E313B2F3B62640E15C68531A3F4640	Bologna
402	Filopanti	6	Operatore: TPER	0101000020E6100000C6032560CFB62640A8B118D0663F4640	Bologna
403	Porta San Donato	6	Operatore: TPER	0101000020E610000079C1F1C693B62640C1BA3B7CE33F4640	Bologna
404	Due Ponti	6	Operatore: TPER	0101000020E6100000E4439AC2949626403750E09D7C424640	Bologna
405	Due Ponti	6	Operatore: TPER	0101000020E61000003293A8177C9626401D6041F56A424640	Bologna
406	Bernardi	6	Operatore: TPER	0101000020E610000061B9EF62AB99264012FEA0890B414640	Bologna
407	Acquedotto Triumvirato	6	Operatore: TPER	0101000020E6100000C8CD154ACB9526403E2A59A9FB414640	Bologna
408	Acquedotto Triumvirato	6	Operatore: TPER	0101000020E6100000E5BBEF73D79526400A2C802903424640	Bologna
409	Zanolini - Casa delle Donne	6	Operatore: TPER	0101000020E6100000120FCDE1FFB726403FADFDF8A63F4640	Bologna
410	Putti	6	Operatore: TPER	0101000020E6100000A0E062450DB22640237722D2803D4640	Bologna
411	Castiglione	6	Operatore: TPER	0101000020E6100000C860C5A9D6B22640F55A1A097E3D4640	Bologna
412	Delle Rose	6	Operatore: TPER	0101000020E61000003F96992DB4B2264018601F9DBA3D4640	Bologna
413	Delle Rose	6	Operatore: TPER	0101000020E610000023580BA2A4B22640B3A3271BC53D4640	Bologna
414	Porta Castiglione	6	Operatore: TPER	0101000020E61000007AC0E1AA57B22640DE49FA6AFD3D4640	Bologna
415	Porta Castiglione	6	Operatore: TPER	0101000020E61000008F9FD7E951B226406A7C7088023E4640	Bologna
416	Crocefissi	6	Operatore: TPER	0101000020E61000005B272EC72B94264058152BB4BD3E4640	Bologna
417	Lunetta Gamberini	6	Operatore: TPER	0101000020E6100000A180ED60C4BE264041C17BFDFF3C4640	Bologna
418	Beolco	6	Operatore: TPER	0101000020E61000002A37514B73BF2640A0F99CBB5D404640	Bologna
419	Dopolavoro Ferroviario	6	Operatore: TPER	0101000020E6100000B40AF6BAA0B5264006195CCE00414640	Bologna
420	Stalingrado Parri	6	Operatore: TPER	0101000020E6100000B11A4B581BB72640C03FA54A94414640	Bologna
421	Case Nuove	6	Operatore: TPER	0101000020E61000007593180456BE2640F6E0FFD835454640	Bologna
422	Facoltà di Agraria	6	Operatore: TPER	0101000020E610000099B44E01D5D02640A9FB5B5DA9414640	Bologna
423	Pioppa	6	Operatore: TPER	0101000020E61000007A90F9DBF97D26404C4CBCA882434640	Bologna
424	Cavalieri Ducati	6	Operatore: TPER	0101000020E610000079043752B68426407EB38300CF414640	Bologna
425	Villa Bellombra	6	Operatore: TPER	0101000020E6100000EE5465845C822640DFB18E99FA414640	Bologna
426	Traghetto	6	Operatore: TPER	0101000020E6100000D8BAD408FDA026406C1107BFC3434640	Bologna
427	Case Savini	6	Operatore: TPER	0101000020E6100000C2EE8513E28F264019969A9889434640	Bologna
428	Prati di Caprara	6	Operatore: TPER	0101000020E6100000FEF2C98AE19E2640E22F7777AE404640	Bologna
429	Prati di Caprara	6	Operatore: TPER	0101000020E610000017563BD4009F2640F20FB633A7404640	Bologna
430	Rotonda Granatieri - AVIS	6	Operatore: TPER	0101000020E610000028BBF48A02A02640B4AD669DF1404640	Bologna
431	Istituto Manfredi Tanari	6	Operatore: TPER	0101000020E6100000E7EDBE19EBC52640C931A3699A3E4640	Bologna
432	Etruria	6	Operatore: TPER	0101000020E6100000516DCBDB6CC3264092770E65A83E4640	Bologna
433	Scalo	6	Operatore: TPER	0101000020E61000005CCF6B47CCA72640D35E8E684C404640	Bologna
434	Tanari	6	Operatore: TPER	0101000020E6100000DBCAA6B79AA82640AC055152BB404640	Bologna
435	Giacinto	6	Operatore: TPER	0101000020E61000009D465A2A6F9B2640789B374E0A414640	Bologna
436	Giorgione	6	Operatore: TPER	0101000020E61000000DFB3DB14E9926402C43C13170414640	Bologna
437	De Gama	6	Operatore: TPER	0101000020E61000005F7CD11E2FA82640F2AE1F07CA424640	Bologna
438	Oca	6	Operatore: TPER	0101000020E61000001077F52A32A62640ACEE47403B424640	Bologna
439	C.S. Pescarola	6	Operatore: TPER	0101000020E6100000B5DE6FB4E3A226403B78DCA62E434640	Bologna
440	Smeraldo	6	Operatore: TPER	0101000020E61000007FAB2B5558BF26404F351F7CCD3E4640	Bologna
441	Masia	6	Operatore: TPER	0101000020E6100000B944E4AA68BA2640723B8FE5B83F4640	Bologna
442	Masia	6	Operatore: TPER	0101000020E61000009610621D7DBA2640C7928323923F4640	Bologna
443	Stalingrado	6	Operatore: TPER	0101000020E61000001381EA1F44B62640FBE769C020414640	Bologna
444	Stalingrado	6	Operatore: TPER	0101000020E610000025F5543D4FB626404C44AE8A26414640	Bologna
445	Manifattura	6	Operatore: TPER	0101000020E6100000514D49D6E1B8264003931B45D6424640	Bologna
446	Case Nuove	6	Operatore: TPER	0101000020E6100000C153C8957ABE26400AEB10493E454640	Bologna
447	Case Sant`Anna	6	Operatore: TPER	0101000020E6100000852348A5D8C12640AF2479AEEF454640	Bologna
448	Case Sant`Anna	6	Operatore: TPER	0101000020E6100000E6762FF7C9C126409D853DEDF0454640	Bologna
449	Piazza dell'Unità	6	Operatore: TPER	0101000020E61000008D81D0D5B1B12640A428E1534A414640	Bologna
450	Piazza dell'Unità	6	Operatore: TPER	0101000020E610000074AECD6B91B126403BA92F4B3B414640	Bologna
451	Colombo	6	Operatore: TPER	0101000020E6100000A25D85949FB426405DDF878384464640	Bologna
452	Creti	6	Operatore: TPER	0101000020E610000045F46BEBA7B326402D99637957414640	Bologna
453	Creti	6	Operatore: TPER	0101000020E6100000B3E496FB89B32640441DB17158414640	Bologna
454	Stalingrado	6	Operatore: TPER	0101000020E6100000C305EADED4B52640005878F244414640	Bologna
455	Battiferro	6	Operatore: TPER	0101000020E6100000BC5175D9F9AC2640A1CE26D1DC414640	Bologna
456	Borre	6	Operatore: TPER	0101000020E610000088A9E3E775A226409A362DC25E434640	Bologna
457	Pellegrino	6	Operatore: TPER	0101000020E61000007F1475E61EAA26403A9A7EE431434640	Bologna
458	Villa Saltarelli	6	Operatore: TPER	0101000020E6100000725E526B50922640A9B816D286434640	Bologna
459	Cavalieri Ducati	6	Operatore: TPER	0101000020E6100000B0BD6081F9892640789CFDDC2B424640	Bologna
460	Tolstoi	6	Operatore: TPER	0101000020E6100000F1AD5978A8932640D828907EA03F4640	Bologna
461	Buon Pastore	6	Operatore: TPER	0101000020E6100000610B8B9B64BD2640649E4B27C83A4640	Bologna
462	Mario	6	Operatore: TPER	0101000020E610000009ED8B3A29C22640D6011077F53A4640	Bologna
463	Rigosa Chiesa	6	Operatore: TPER	0101000020E610000064E0CA23C9792640172D40DB6A414640	Bologna
464	Adige	6	Operatore: TPER	0101000020E6100000E833A0DE8CC226402CF180B2293D4640	Bologna
465	Ospedale Malpighi	6	Operatore: TPER	0101000020E61000007A05FDE0D7BB2640B0592E1B9D3E4640	Bologna
466	Villa Mazzacorati	6	Operatore: TPER	0101000020E61000000C6E10525CBE264088FAB8910D3C4640	Bologna
467	Dante	6	Operatore: TPER	0101000020E6100000F435CB65A3B72640614D0A98653E4640	Bologna
468	Laura Bassi	6	Operatore: TPER | Con pensilina	0101000020E6100000663C009821BC264003C12D69D63D4640	Bologna
469	Baraccano	6	Operatore: TPER	0101000020E61000005F6E4100BAB52640227D4919273E4640	Bologna
470	Dante	6	Operatore: TPER	0101000020E610000076E3384B24B8264018A941E2683E4640	Bologna
471	Rovighi	6	Operatore: TPER	0101000020E610000025862EF2FCBB26404A5C6CFF6F3C4640	Bologna
472	Battaglia	6	Operatore: TPER	0101000020E610000065FACA283BC226401952EA37B83B4640	Bologna
473	Villa Baruzziana	6	Operatore: TPER	0101000020E6100000521443CDEBAB2640697BAAF9E03D4640	Bologna
474	Parco Nord	6	Operatore: TPER	0101000020E61000005778978BF8BE2640EF004F5AB8424640	Bologna
475	Ospedale Malpighi	6	Operatore: TPER	0101000020E61000007AAA436E86BB2640D393E81B873E4640	Bologna
476	Alemanni	6	Operatore: TPER	0101000020E61000006FBC3B3256BB26402EBEB21C323E4640	Bologna
477	Bella Ripa	6	Operatore: TPER	0101000020E6100000237DFF8B0CB32640AB6C697FB13C4640	Bologna
478	Piazza Trento Trieste	6	Operatore: TPER	0101000020E6100000D7416F3B7EB92640E4F159434E3E4640	Bologna
479	Villa Colonna	6	Operatore: TPER	0101000020E610000060DDC2047FB126400E2E1D739E3C4640	Bologna
480	San Ruffillo Stazione	6	Operatore: TPER	0101000020E610000082397AFCDEBE2640B85DC367463B4640	Bologna
481	Pontebuco Bivio	6	Operatore: TPER	0101000020E6100000AF8E88CED7CD264010F97832493B4640	Bologna
482	Caserma Chiarini	6	Operatore: TPER	0101000020E6100000B2AA14F18CD02640A741D13C803F4640	Bologna
483	Resto Del Carlino	6	Operatore: TPER	0101000020E61000004CF7DFEFBCD52640A19119B9B83F4640	Bologna
484	Roveri	6	Operatore: TPER	0101000020E6100000D84BAEBDAAD226408F256200973F4640	Bologna
485	Tiro Al Piattello	6	Operatore: TPER	0101000020E61000002577D844669E264015ADDC0BCC384640	Bologna
486	Ca` Di Savini	6	Operatore: TPER	0101000020E61000008A66AF88ABA42640A1DB4B1AA33A4640	Bologna
487	Istituto Arcangeli	6	Operatore: TPER	0101000020E61000000298D7B6CDB92640BEE8E1BA183D4640	Bologna
488	Torino	6	Operatore: TPER	0101000020E61000008869DFDC5FC12640A5356156833C4640	Bologna
489	Armi	6	Operatore: TPER	0101000020E610000070DD83C602C126406A85E97B0D3C4640	Bologna
490	Corelli	6	Operatore: TPER	0101000020E610000008D3E6EE29BF26407B698A00A73A4640	Bologna
491	Ospedale Malpighi	6	Operatore: TPER	0101000020E6100000E1140C9D8DBB2640A34511AD703E4640	Bologna
492	Garganelli	6	Operatore: TPER	0101000020E6100000C2B0B26C9CB32640F8E12021CA3E4640	Bologna
493	Piazza Roosevelt	6	Operatore: TPER	0101000020E6100000CD4BB49A64AE2640763AEBAE473F4640	Bologna
494	Stalingrado	6	Operatore: TPER	0101000020E6100000CAF4F00AE9B52640A76ED34444414640	Bologna
495	Fioravanti Tibaldi	6	Operatore: TPER	0101000020E610000033FF4355A7AE2640EEA29EF474414640	Bologna
496	Battiferro	6	Operatore: TPER	0101000020E61000000DC74ED3C2AC26405A626534F2414640	Bologna
497	Pellegrino	6	Operatore: TPER	0101000020E61000007E1F69CB14AA2640597A23A93B434640	Bologna
498	Varanini	6	Operatore: TPER	0101000020E61000003F2773E261A02640BF61A2410A434640	Bologna
499	Collegio San Luigi	6	Operatore: TPER	0101000020E6100000BA3F283971832640E8C5E468E9404640	Bologna
500	Bottego	6	Operatore: TPER	0101000020E61000009755D80C70A926403F8ADFB99C424640	Bologna
501	Beverara	6	Operatore: TPER	0101000020E6100000C9E9EBF99AA92640BBBDFFEACC424640	Bologna
502	Bottego	6	Operatore: TPER	0101000020E6100000778CE1A073A92640C7084DB791424640	Bologna
503	Beverara	6	Operatore: TPER	0101000020E6100000673C5B5194A92640E8829FDDC6424640	Bologna
504	Sostegno	6	Operatore: TPER	0101000020E610000064B895B954AC264090C1E50C20444640	Bologna
505	Varanini	6	Operatore: TPER	0101000020E61000001C0CD01154A0264064496F6E02434640	Bologna
506	C.S. Pontelungo	6	Operatore: TPER	0101000020E610000098D98C78579A2640749B70AFCC414640	Bologna
507	Calderara Bivio	6	Operatore: TPER	0101000020E610000021020EA14A852640FE2AC0779B454640	Bologna
508	Bargellino	6	Operatore: TPER	0101000020E6100000956588635D842640D1419770E8454640	Bologna
509	Le Piastre	6	Operatore: TPER	0101000020E61000000F63D2DF4B81264083BEF4F6E7464640	Bologna
510	Triumvirato	6	Operatore: TPER	0101000020E6100000279E584C11952640556CCCEB88414640	Bologna
511	Birra	6	Operatore: TPER	0101000020E610000099840B7904972640FAD0AA3BBB424640	Bologna
512	Garganelli	6	Operatore: TPER	0101000020E6100000855561D806B326402F90FBB1A43E4640	Bologna
513	Gaibola	6	Operatore: TPER	0101000020E6100000267733FED8A326403DB83B6BB73B4640	Bologna
514	Vetulonia	6	Operatore: TPER	0101000020E610000085EF58C74CC126401C6B35DA603E4640	Bologna
515	Spina	6	Operatore: TPER	0101000020E610000022A57E839BC12640EF33D362953E4640	Bologna
516	Villa Aldini	6	Operatore: TPER	0101000020E6100000A8BF03A84EA82640E4A5F67D933D4640	Bologna
517	Villa Aldini	6	Operatore: TPER	0101000020E61000009826B6CC33A826407E3672DD943D4640	Bologna
518	Forte	6	Operatore: TPER	0101000020E61000003FA07DF66DA226404D8F5CED173A4640	Bologna
519	Piazza Trento Trieste	6	Operatore: TPER	0101000020E610000074DF7BC910B92640D4C62297493E4640	Bologna
520	Fermata Servizio Due Madonne	6	Operatore: TPER	0101000020E61000006803B00111CA264069931EE10F3E4640	Bologna
521	Vetulonia	6	Operatore: TPER	0101000020E6100000C77949AD41C126408B6D52D1583E4640	Bologna
522	Bivio Gaibola	6	Operatore: TPER	0101000020E6100000FDA60B0CB4A62640D91DF7521D3B4640	Bologna
523	Torino	6	Operatore: TPER	0101000020E6100000A37895B54DC12640DFDC04847B3C4640	Bologna
524	Foscherara	6	Operatore: TPER	0101000020E6100000D8AB7E5B66BF264096A07543093C4640	Bologna
525	Armi	6	Operatore: TPER	0101000020E6100000A420D335EEC02640F07BE58B073C4640	Bologna
526	Rovighi	6	Operatore: TPER	0101000020E6100000B47405DB88BB26408BB0975C7B3C4640	Bologna
527	Gubellini	6	Operatore: TPER	0101000020E610000083FCC79D2DC32640AD495C6CFF3B4640	Bologna
528	Zona Industriale Zola Predosa Curiel	6	Operatore: TPER	0101000020E6100000F56970B6147F264039268BFB8F3F4640	Bologna
529	Faenza	6	Operatore: TPER	0101000020E61000005EA340FA81C6264050340F60913C4640	Bologna
530	Foscherara	6	Operatore: TPER	0101000020E6100000F9895EA16ABF26406CB3B112F33B4640	Bologna
531	Abba	6	Operatore: TPER	0101000020E6100000E0803BF5EDC126409AE9036E823B4640	Bologna
532	Rigosa Chiesa	6	Operatore: TPER	0101000020E6100000ECA2E8818F792640C68844A165414640	Bologna
533	Cavaioni	6	Operatore: TPER	0101000020E610000046E40522D59D2640439D03159F384640	Bologna
534	Caruso	6	Operatore: TPER	0101000020E61000004CE6B397C8B8264056F5F23B4D3D4640	Bologna
535	Villa Sampiera	6	Operatore: TPER	0101000020E6100000FECCC5843DB2264064C3E457BD3C4640	Bologna
536	Aranzio	6	Operatore: TPER	0101000020E6100000C5138B29A2BC2640D02DCFDE743C4640	Bologna
537	Croara Bivio	6	Operatore: TPER	0101000020E6100000871FF70890CC26400F9A5DF7563B4640	Bologna
538	Faenza	6	Operatore: TPER	0101000020E6100000112851E56AC62640F808EBB58F3C4640	Bologna
539	Vermiglia	6	Operatore: TPER	0101000020E6100000E56D5B4A4CBE26407BF7C77BD53E4640	Bologna
540	Dopolavoro Ferroviario	6	Operatore: TPER	0101000020E6100000B31BC75922B5264063B3C81B05414640	Bologna
541	Casoni	6	Operatore: TPER	0101000020E6100000B9BC83E9C5B62640E43C52335A424640	Bologna
542	Persicetana Vecchia	6	Operatore: TPER	0101000020E6100000AA2D7590D78B26407C46223482434640	Bologna
543	Piazza dei Martiri	6	Operatore: TPER	0101000020E610000043F3EFE9A0AD264062AD90A806404640	Bologna
544	Rondone	6	Operatore: TPER	0101000020E6100000FE7C5BB054AB2640055BDBCA01404640	Bologna
545	Porta Saragozza Frassinago	6	Operatore: TPER	0101000020E610000047B30D373BA926403A330BFEC83E4640	Bologna
546	Vestri	6	Operatore: TPER	0101000020E6100000F2A43B3E10B72640A14731E5E8404640	Bologna
547	Ruggeri	6	Operatore: TPER	0101000020E6100000C2FFB16BD6B8264012AB9A7BA3404640	Bologna
548	Pezzana	6	Operatore: TPER	0101000020E61000007E84AB4DADB82640A0F42AD780404640	Bologna
549	Noce	6	Operatore: TPER	0101000020E61000004E4C721B68A12640B26900CA3A444640	Bologna
550	Timavo	6	Operatore: TPER	0101000020E6100000BA41FEE3CEA22640A5BB90B355404640	Bologna
551	Rotonda Granatieri - AVIS	6	Operatore: TPER	0101000020E6100000B3AFE18EDC9F2640D1306B18F4404640	Bologna
552	Persicetana Vecchia Commenda	6	Operatore: TPER	0101000020E61000003276C24B708A2640E59997C3EE434640	Bologna
553	Persicetana Vecchia	6	Operatore: TPER	0101000020E6100000AAEE91CD558B264070EF1AF4A5434640	Bologna
554	Cavalcavia San Donato	6	Operatore: TPER	0101000020E61000005CF7A0B140B9264008066BF706404640	Bologna
555	Rossi	6	Operatore: TPER	0101000020E610000071FF91E9D0B926405897AEBBD43F4640	Bologna
556	Stalingrado Parri	6	Operatore: TPER	0101000020E6100000B5F171B735B72640EF8FF7AA95414640	Bologna
557	Fiorini	6	Operatore: TPER	0101000020E610000058FC4BF7DFD72640F8962831BE414640	Bologna
558	Bigari	6	Operatore: TPER	0101000020E61000001C615111A7B326404617E5E324414640	Bologna
559	Calzolari	6	Operatore: TPER	0101000020E61000009A40118B18B626403F6F2A5261424640	Bologna
560	Porta Saragozza Frassinago	6	Operatore: TPER	0101000020E610000047C60F3A8DA92640BB7207FBC03E4640	Bologna
561	Vestri	6	Operatore: TPER	0101000020E61000008E684CD246B72640A8F3F285DA404640	Bologna
562	Bigari	6	Operatore: TPER	0101000020E610000096517644CFB3264086C0368710414640	Bologna
563	Creti	6	Operatore: TPER	0101000020E6100000B7E974C531B32640811B73E83E414640	Bologna
564	Arca	6	Operatore: TPER	0101000020E6100000AED4B32094AF26404DE19C6C5E414640	Bologna
565	Istituto Serpieri	6	Operatore: TPER	0101000020E6100000932C712E0FBB264035B22B2D23464640	Bologna
566	Piazza dei Martiri	6	Operatore: TPER	0101000020E610000067406260C2AD2640F3188AE024404640	Bologna
567	Istituto Serpieri	6	Operatore: TPER	0101000020E610000058A3682FECBA264041FE881524464640	Bologna
568	Bovi Campeggi	6	Operatore: TPER	0101000020E6100000108BBDBCA5A92640DFCFDF3AB5404640	Bologna
569	San Pio V	6	Operatore: TPER	0101000020E610000041EA1B3D23A626404FECFC361F404640	Bologna
570	Usodimare	6	Operatore: TPER	0101000020E61000002834FF9E0EA626407E74EACA67424640	Bologna
571	Pietra	6	Operatore: TPER	0101000020E6100000C10B11267B9226405F9445065E414640	Bologna
572	Pietra	6	Operatore: TPER	0101000020E610000003931B45D6922640B8FF6DBB75414640	Bologna
573	Faggiolo	6	Operatore: TPER	0101000020E61000000DF159E89491264053DF43D323414640	Bologna
574	Marzabotto	6	Operatore: TPER	0101000020E6100000D270CADC7C9F26409CBA97A02B404640	Bologna
575	Marzabotto	6	Operatore: TPER	0101000020E6100000D21D1F88879F2640ACD161742F404640	Bologna
576	Santa Viola	6	Operatore: TPER	0101000020E6100000DCE33BE75D9B2640F43C13F5DD404640	Bologna
577	Battindarno Segantini	6	Operatore: TPER	0101000020E61000004D09D2D6D29926405FC65E398C404640	Bologna
578	Deposito Battindarno	6	Operatore: TPER	0101000020E6100000582140E1479826405590550042404640	Bologna
579	De Pisis	6	Operatore: TPER	0101000020E61000000BBD59DEB094264086A6913B11404640	Bologna
580	Villaggio Speranza	6	Operatore: TPER	0101000020E61000005A153CE015802640C78FE7E912424640	Bologna
581	Bovi Campeggi Questura	6	Operatore: TPER	0101000020E61000000AD0002890AB26403F6EBF7CB2404640	Bologna
582	Bovi Campeggi Questura	6	Operatore: TPER	0101000020E61000000619B78773AB264033A6608DB3404640	Bologna
583	Bovi Campeggi	6	Operatore: TPER	0101000020E61000003571BC4C5EAA2640BCDA9B29BE404640	Bologna
584	Bolognese	6	Operatore: TPER	0101000020E6100000A96917D34CAF26406951442B9C414640	Bologna
585	Traghetto	6	Operatore: TPER	0101000020E61000000C11267B3AA126406D14FEB1B5434640	Bologna
586	Istituto Manfredi Tanari	6	Operatore: TPER	0101000020E6100000282614C726C62640F594E6A0953E4640	Bologna
587	Scalo	6	Operatore: TPER	0101000020E610000075D8333AD6A72640ED5921F653404640	Bologna
588	Battindarno Veronese	6	Operatore: TPER	0101000020E6100000C8BB7E1C2897264086376BF0BE3F4640	Bologna
589	Battindarno Veronese	6	Operatore: TPER	0101000020E6100000E017F263279726406C92C437B93F4640	Bologna
590	Porta Lame	6	Operatore: TPER	0101000020E6100000D4D51D8B6DAA2640DEE4B7E864404640	Bologna
591	Oca	6	Operatore: TPER	0101000020E6100000D65988693AA626403DCF447D37424640	Bologna
592	Cirenaica	6	Operatore: TPER	0101000020E610000089BBD5CE8BBA2640B1506B9A773F4640	Bologna
593	Duse	6	Operatore: TPER	0101000020E6100000452FA3586EBD2640CF41E1FD02404640	Bologna
594	Andreini	6	Operatore: TPER	0101000020E610000006DBE3E02DBF26407EFC4A8C0A404640	Bologna
595	Andreini	6	Operatore: TPER	0101000020E61000003295D97B4CBF264029F345312F404640	Bologna
596	Rossi	6	Operatore: TPER	0101000020E61000004048BB760EBA264087B9EEF7D53F4640	Bologna
597	Piazza dell'Unità	6	Operatore: TPER	0101000020E6100000A766C526E8B126406EDFA3FE7A414640	Bologna
598	Ponte Romano	6	Operatore: TPER	0101000020E61000000470B378B19826405BD2510E66414640	Bologna
599	Zanardi Cintura Ferroviaria	6	Operatore: TPER	0101000020E61000000A11700855A22640C1806FE4CB444640	Bologna
600	Zona Artigianale Due Scal	6	Operatore: TPER	0101000020E61000003691990B5C8626409C6A2DCC42454640	Bologna
601	Salute	6	Operatore: TPER	0101000020E6100000ABEAE5779A8C26409BE5B2D139434640	Bologna
602	Della Salute 16	6	Operatore: TPER	0101000020E6100000F419506F468D2640AE9AE7887C434640	Bologna
603	Della Salute 16	6	Operatore: TPER	0101000020E6100000C614AC71368D26403CBF28417F434640	Bologna
604	25 Della Salute 89/3	6	Operatore: TPER	0101000020E6100000DE736039428E26402D5DC136E2434640	Bologna
605	26 Della Fornace Case Sav	6	Operatore: TPER	0101000020E610000016BEBED6A58E2640685C381092434640	Bologna
606	Due Portoni	6	Operatore: TPER	0101000020E61000005FEB5223F48B264054C90050C5434640	Bologna
607	32 Persicetana V. Commenda	6	Operatore: TPER	0101000020E6100000F0C000C2878A26406153E751F1434640	Bologna
608	33 Persicetana V. Commenda	6	Operatore: TPER	0101000020E6100000651BB803758A264045D61A4AED434640	Bologna
609	47 Vivaio 41	6	Operatore: TPER	0101000020E61000002461DF4E228226403755F7C8E6444640	Bologna
610	48 Vivaio 10/3	6	Operatore: TPER	0101000020E610000068942EFD4B822640FB5C6DC5FE444640	Bologna
611	Fondazza	6	Operatore: TPER	0101000020E6100000DC8310902FB526403A39E8B7543E4640	Bologna
612	Cirenaica	6	Operatore: TPER	0101000020E61000009B046F48A3BA2640E32DA1CC503F4640	Bologna
613	Franceschini	6	Operatore: TPER	0101000020E6100000FB1CC4735BB326406BC1413168414640	Bologna
614	Porta Lame	6	Operatore: TPER	0101000020E6100000EC246C89A6A926405F0196A652404640	Bologna
615	Centro Sportivo Barca	6	Operatore: TPER	0101000020E61000008A856BFF14902640FBB0DEA8153F4640	Bologna
616	Ca' Nuova	6	Operatore: TPER	0101000020E61000001B2323B1EE7D26409B5AB6D617424640	Bologna
617	Boiardo	6	Operatore: TPER	0101000020E61000002DE11AE95685264044FB58C16F414640	Bologna
618	Casarini	6	Operatore: TPER	0101000020E61000002317F77A52A92640DC82A5BA80404640	Bologna
619	Le Torri	6	Operatore: TPER	0101000020E61000006026E5492D8F2640D1E05BFD7D404640	Bologna
620	Salvemini	6	Operatore: TPER	0101000020E6100000E65718C7ED8C264030C7E18222404640	Bologna
621	Le Torri	6	Operatore: TPER	0101000020E6100000F4DE1802808F26401A129C9F87404640	Bologna
622	Lavino di Mezzo Chiesa	6	Operatore: TPER	0101000020E6100000B8F41E1D0D7A26406933F389E1434640	Bologna
623	21 Della Salute 10	6	Operatore: TPER	0101000020E61000003656629E958C2640657094BC3A434640	Bologna
624	30 Persicetana V. Rotonda	6	Operatore: TPER	0101000020E6100000AD889AE8F38926407923F3C81F444640	Bologna
625	Persicetana Vecchia Zona Artigianale	6	Operatore: TPER	0101000020E6100000C0046EDDCD8B26403FE0810184434640	Bologna
626	Persicetana Vecchia Zona Artigianale	6	Operatore: TPER	0101000020E610000039471D1D578B2640D61C2098A3434640	Bologna
627	36 Sant`Agnese	6	Operatore: TPER	0101000020E61000007C0C569C6A8D26404C6F7F2E1A444640	Bologna
628	37 Di Mezzo 6	6	Operatore: TPER	0101000020E610000039D0436D1B862640F56915FDA1434640	Bologna
629	39 Di Mezzo 5	6	Operatore: TPER	0101000020E6100000416C448BC7842640B7DA79D10D444640	Bologna
630	40 Di Mezzo 5	6	Operatore: TPER	0101000020E61000001766A19DD3842640EC1516DC0F444640	Bologna
631	45 Di Mezzo Vivaio	6	Operatore: TPER	0101000020E61000004390831266822640C0417BF5F1444640	Bologna
632	50 Vivaio 6	6	Operatore: TPER	0101000020E6100000FC3905F9D98026407F30F0DC7B444640	Bologna
633	61 Punta Di Mezzo Levante	6	Operatore: TPER	0101000020E61000005854C4E9247B2640295FD04202464640	Bologna
634	Rondone	6	Operatore: TPER	0101000020E610000002A72D6464AB264008CFDFDFFB3F4640	Bologna
635	Colombo	6	Operatore: TPER	0101000020E6100000BFD4CF9B8AB4264038A1100187464640	Bologna
636	Villaggio Rurale	6	Operatore: TPER	0101000020E61000005A1135D1E7B3264044DB317557464640	Bologna
637	Porta Lame	6	Operatore: TPER	0101000020E61000005797530262AA2640B88663A769404640	Bologna
638	Zona Artigianale Commenda	6	Operatore: TPER	0101000020E610000028603B18B1872640DAFF006BD5444640	Bologna
639	Case Ghedini	6	Operatore: TPER	0101000020E6100000B75D0DF5609326401D51460147434640	Bologna
640	Villa Saltarelli	6	Operatore: TPER	0101000020E6100000BA2AF5D14E9226404497811486434640	Bologna
641	Bivio San Vittore	6	Operatore: TPER	0101000020E6100000641EF98381AF26402FD16A92693B4640	Bologna
642	Salgari	6	Operatore: TPER	0101000020E6100000EA53D856FDC72640EFB32506DC414640	Bologna
643	Cavalcavia San Donato	6	Operatore: TPER	0101000020E6100000B0952B1785B82640DB59AAC1EA3F4640	Bologna
644	Bovi Campeggi	6	Operatore: TPER	0101000020E6100000D6427F57BAA92640017D6CDCAC404640	Bologna
645	Casarini	6	Operatore: TPER	0101000020E6100000D1B2EE1F0BA9264004C8D0B183404640	Bologna
646	Borgo Panigale Cimitero	6	Operatore: TPER	0101000020E61000003278F3AF408B264041C4BC7D0C424640	Bologna
647	31 Persicetana V. Rotonda	6	Operatore: TPER	0101000020E6100000AD6BB41CE889264056815A0C1E444640	Bologna
648	38 Di Mezzo 6	6	Operatore: TPER	0101000020E610000017450F7C0C8626404F0647C9AB434640	Bologna
649	46 Di Mezzo Vivaio	6	Operatore: TPER	0101000020E6100000AF97A60870822640967A1684F2444640	Bologna
650	59 Punta 15	6	Operatore: TPER	0101000020E61000004E7FF623457C2640D00D4DD9E9454640	Bologna
651	60 Punta 15	6	Operatore: TPER	0101000020E6100000126A8654517C2640BC067DE9ED454640	Bologna
652	Fondazza	6	Operatore: TPER	0101000020E6100000F5E681D94EB5264057941282553E4640	Bologna
653	Case Ghedini	6	Operatore: TPER	0101000020E6100000D10836AE7F932640431F2C6343434640	Bologna
654	Caserma R.R.A.E.	6	Operatore: TPER	0101000020E6100000983C540905932640853474FDCC434640	Bologna
655	Caserma R.R.A.E.	6	Operatore: TPER	0101000020E61000008A5352CCE69226403EDB59AAC1434640	Bologna
656	Stadio	6	Operatore: TPER	0101000020E6100000BB61DBA2CC9E2640A82913C8363F4640	Bologna
657	Belcantone	6	Operatore: TPER	0101000020E6100000D8857A55C2962640E32E675B723F4640	Bologna
658	Battivento	6	Operatore: TPER	0101000020E61000006B9FE9807FB12640F0D69EFE583C4640	Bologna
659	Massarenti	6	Operatore: TPER	0101000020E610000056174BEC35BC2640A04DB3E5013F4640	Bologna
660	Arpa	6	Operatore: TPER	0101000020E6100000C65D73FD71BD2640187ECBF7E73E4640	Bologna
661	Arpa	6	Operatore: TPER	0101000020E6100000B4E32B26DBBD264033672211BF3E4640	Bologna
662	Scuola Attilia Neri	6	Operatore: TPER	0101000020E6100000A7B9CB3450B7264096C338C9A0454640	Bologna
663	Centro Gallia	6	Operatore: TPER	0101000020E6100000E665039FD5C426402458665B173C4640	Bologna
664	Alemanni	6	Operatore: TPER	0101000020E61000003A3135536BBB26407DCC07043A3E4640	Bologna
665	Cavazzoni	6	Operatore: TPER	0101000020E61000002CFF10D19EC12640CCC0B79F423C4640	Bologna
666	Gubellini	6	Operatore: TPER	0101000020E6100000CC6BDBE67CC3264018AAACB7173C4640	Bologna
667	Mario	6	Operatore: TPER	0101000020E610000068D8DE5D1DC226409B937252F33A4640	Bologna
668	Trebbo Rosario	6	Operatore: TPER	0101000020E61000008B36C7B94DB02640F7C77BD5CA464640	Bologna
669	Noce	6	Operatore: TPER	0101000020E61000000962EAF879A1264089C5B99745444640	Bologna
670	Olmetola	6	Operatore: TPER	0101000020E6100000BF28417FA17B2640F5E0496650414640	Bologna
671	Villa Boschi	6	Operatore: TPER	0101000020E6100000043F051B32812640C78FE7E912414640	Bologna
672	Case Giardino	6	Operatore: TPER	0101000020E61000001203136EE8842640E3DF675C38414640	Bologna
673	Villa Guastavillani	6	Operatore: TPER	0101000020E6100000F92D3A596AB126404568041BD73B4640	Bologna
674	Sacro Cuore	6	Operatore: TPER	0101000020E6100000FD440A0A28B12640FF72D2A00D414640	Bologna
675	Centro Prove Autoveicoli	6	Operatore: TPER	0101000020E6100000BB96355607A126409D58F15712444640	Bologna
676	Centro Prove Autoveicoli	6	Operatore: TPER	0101000020E610000029A44632F5A02640364A4D710B444640	Bologna
677	Porta San Felice	6	Operatore: TPER	0101000020E61000004384C99E4EA72640F0BA2308FC3F4640	Bologna
678	Usodimare	6	Operatore: TPER	0101000020E6100000DEB7109A13A62640B1581EFF60424640	Bologna
679	Zanardi Cintura Ferroviaria	6	Operatore: TPER	0101000020E6100000862F5DD262A226402A67391AD1444640	Bologna
680	Triumvirato	6	Operatore: TPER	0101000020E6100000EFA3BF3C09952640ECB314DA83414640	Bologna
681	Battindarno Segantini	6	Operatore: TPER	0101000020E6100000D56A5908BC992640875E358584404640	Bologna
682	24 Della Salute 89/3	6	Operatore: TPER	0101000020E61000009F8EC70C548E2640ECA17DACE0434640	Bologna
683	Due Portoni	6	Operatore: TPER	0101000020E6100000FCAA5CA8FC8B2640766B990CC7434640	Bologna
684	41 Di Mezzo 32	6	Operatore: TPER	0101000020E6100000D597A59D9A832640739F1C0588444640	Bologna
685	42 Di Mezzo 5/8	6	Operatore: TPER	0101000020E6100000DD41EC4CA183264049D8B79388444640	Bologna
686	43 Di Mezzo Bargellino	6	Operatore: TPER	0101000020E6100000EACE13CFD98226408D28ED0DBE444640	Bologna
687	44 Di Mezzo Bargellino	6	Operatore: TPER	0101000020E6100000FCC401F4FB82264043194FA9B7444640	Bologna
688	57 Punta	6	Operatore: TPER	0101000020E610000082AD122C0E7F264097E65608AB454640	Bologna
689	Borre	6	Operatore: TPER	0101000020E6100000BD25EFD23CA22640D1F1875572434640	Bologna
690	Chiesa Borgo Panigale	6	Operatore: TPER	0101000020E6100000922AE510CC8C26404BC0F91E3F424640	Bologna
691	49 Vivaio 29	6	Operatore: TPER	0101000020E6100000C3D7D7BAD4802640B0CBF09F6E444640	Bologna
692	51 Vivaio Persicetana	6	Operatore: TPER	0101000020E61000001AF7E6374C842640080264E8D8454640	Bologna
693	52 Vivaio Persicetana	6	Operatore: TPER	0101000020E6100000B403AE2B66842640809A5AB6D6454640	Bologna
694	53 Punta Vivaio	6	Operatore: TPER	0101000020E61000005E8429CAA5812640F0F8F6AE41454640	Bologna
695	54 Punta Vivaio	6	Operatore: TPER	0101000020E6100000102043C70E822640F700DD9733454640	Bologna
696	55 Punta 7	6	Operatore: TPER	0101000020E6100000A5BBEB6CC87F26406DE525FF93454640	Bologna
697	56 Punta 7	6	Operatore: TPER	0101000020E61000007BC03C64CA7F26409087BEBB95454640	Bologna
698	58 Punta	6	Operatore: TPER	0101000020E6100000E3C62DE6E77E26403F541A31B3454640	Bologna
699	Barbiano 1	6	Operatore: TPER	0101000020E61000003D66FBEB70AF2640198CB6CFCF3C4640	Bologna
700	Colli	6	Operatore: TPER	0101000020E6100000BE8EEED6E8A326404BAA5BE26D3A4640	Bologna
701	Croara Bivio	6	Operatore: TPER	0101000020E6100000310CB32B88CC264087BC8A31553B4640	Bologna
702	Corticelli	6	Operatore: TPER	0101000020E61000008D3CB59F31C02640476B56C73B3B4640	Bologna
703	Viale Pepoli	6	Operatore: TPER	0101000020E6100000A181583673A826402FC1A90F243F4640	Bologna
704	Parco Cavaioni	6	Operatore: TPER	0101000020E61000002BA0F595AC9B2640EC7717DE9B384640	Bologna
705	Corticelli	6	Operatore: TPER	0101000020E61000006E85B01A4BC02640CDE3D5DE4C3B4640	Bologna
706	Villa Getsemani	6	Operatore: TPER	0101000020E6100000F8C66BB98EB826406036A6CC723C4640	Bologna
707	Po	6	Operatore: TPER	0101000020E6100000FFE66AD03CC12640710B4C5DE83C4640	Bologna
708	Po	6	Operatore: TPER	0101000020E6100000CBD8D0CDFEC026408E469968EB3C4640	Bologna
709	Lunetta Gamberini	6	Operatore: TPER	0101000020E61000007239B93A5BBF26406B4029FFFF3C4640	Bologna
710	Porta Santo Stefano Rosa Parks	6	Operatore: TPER	0101000020E610000094C0E61C3CB7264008A98020E53D4640	Bologna
711	Porta San Vitale	6	Operatore: TPER	0101000020E61000003EDB59AAC1B6264028976B76493F4640	Bologna
712	Carducci	6	Operatore: TPER	0101000020E61000009DDDB5DF35B7264060257A747E3E4640	Bologna
713	Villa Getsemani	6	Operatore: TPER	0101000020E610000066D185A28AB82640330FAA1E7A3C4640	Bologna
714	Agucchi	6	Operatore: TPER	0101000020E61000006FDCBD37E1A1264039CA0BFA1C434640	Bologna
715	Agucchi	6	Operatore: TPER	0101000020E6100000E4D1D73DC3A12640BB46CB811E434640	Bologna
716	Bertalia	6	Operatore: TPER	0101000020E61000005CD37256FA9F264020555E3CCD424640	Bologna
717	Autostazione	6	Operatore: TPER	0101000020E6100000347B455CA5B026408A3C49BA66404640	Bologna
718	Piazza Venti Settembre	6	Operatore: TPER	0101000020E6100000260CB90842B026401B214D0691404640	Bologna
719	Carracci Stazione AV	6	Operatore: TPER	0101000020E6100000217365506DB02640D027F224E9404640	Bologna
720	Sterlino	6	Operatore: TPER	0101000020E61000008BFF3BA242B926402EA9DA6E823D4640	Bologna
721	Deposito Due Madonne 2	6	Operatore: TPER	0101000020E61000006460788082CA2640C3D32B65193E4640	Bologna
722	Porta San Donato	6	Operatore: TPER	0101000020E61000006D4782BA92B6264017E1DC15B03F4640	Bologna
723	Zanolini - Casa delle Donne	6	Operatore: TPER	0101000020E6100000D3EF671DFAB7264008889345AB3F4640	Bologna
724	Piazzale Atleti Azzurri	6	Operatore: TPER	0101000020E61000000F24946357C32640E74C7F9B6A3B4640	Bologna
725	Rotonda Mezzini	6	Operatore: TPER	0101000020E6100000DB78663854C22640D55E44DB313B4640	Bologna
726	Sant'Egidio	6	Operatore: TPER	0101000020E6100000DD8EBAE70AB826402E35E785E03F4640	Bologna
727	Giardino Gino Cervi	6	Operatore: TPER	0101000020E610000046031D52B1BE26402FAAA0FDA3404640	Bologna
728	Giardino Gino Cervi	6	Operatore: TPER	0101000020E61000006DA23B2DE4BE26405B8EA1AD94404640	Bologna
729	Creti	6	Operatore: TPER	0101000020E6100000124A5F0839B32640749BCB683F414640	Bologna
730	Carducci	6	Operatore: TPER	0101000020E6100000E711ED7431B72640A66BDC51523E4640	Bologna
731	Ospedale Bellaria	6	Operatore: TPER	0101000020E61000003B5E375B2FC82640513981446E3B4640	Bologna
732	Altobelli	6	Operatore: TPER	0101000020E6100000B0157EBACB932640215F9DBEF93F4640	Bologna
733	Lavino di Mezzo Ponte	6	Operatore: TPER	0101000020E610000087E8C6AAF7762640E692AAED26444640	Bologna
734	Lavino di Mezzo Ponte	6	Operatore: TPER	0101000020E6100000AFDD87CD117726405826B2C524444640	Bologna
735	Pioppa	6	Operatore: TPER	0101000020E6100000638E2FEB0F7E26409C9F877F7D434640	Bologna
736	Ospedale Maggiore Maternità	6	Operatore: TPER	0101000020E6100000BD659824E0A12640D0019365D2404640	Bologna
737	Autostazione	6	Operatore: TPER	0101000020E6100000B6F5D37FD6B026402D4ABF3390404640	Bologna
738	Camping Città di Bologna	6	Operatore: TPER	0101000020E61000005AA7806A72BF2640398DFEE1F8424640	Bologna
739	Aeroporto MEX	6	Operatore: TPER | Con pensilina	0101000020E61000006930B209D59626400F153EB6C0434640	Bologna
740	Aeroporto	6	Operatore: TPER | Con pensilina	0101000020E6100000A0D4A8D1F59626408194D8B5BD434640	Bologna
741	Aeroclub	6	Operatore: TPER	0101000020E6100000AD252E11B9922640ED89647E24444640	Bologna
742	Ponte Savena	6	Operatore: TPER	0101000020E6100000721F14EF5BBC264017CD14843C3A4640	Bologna
743	ITC Luxemburg	6	Operatore: TPER	0101000020E6100000EDAA51595E9F26408D316601C9414640	Bologna
744	Casa della Salute Navile	6	Operatore: TPER	0101000020E61000002018F66A36AD2640C87C40A033414640	Bologna
745	Casa della Salute Navile	6	Operatore: TPER	0101000020E61000006AFD88BA6AAD26403C1CB85E2E414640	Bologna
746	Croce di Camaldoli	6	Operatore: TPER	0101000020E61000009E0F2ACCD6BD2640C246A34CB43B4640	Bologna
747	Sterlino	6	Operatore: TPER	0101000020E6100000A35BAFE941B92640B2CFAD21823D4640	Bologna
748	Murri	6	Operatore: TPER	0101000020E610000040DEAB5626B82640287D21E4BC3D4640	Bologna
749	Corelli	6	Operatore: TPER	0101000020E6100000E3CE3B0444BF264000941A35BA3A4640	Bologna
750	Piazza Aldrovandi - Due Torri	6	Operatore: TPER	0101000020E6100000832ADAC12DB42640FB213658383F4640	Bologna
751	Ospedale Malpighi - Alemanni	6	Operatore: TPER	0101000020E6100000A7AFE76B96BB26404CD2EB05553E4640	Bologna
752	Battisti	6	Operatore: TPER	0101000020E61000007984E4AE6FAD26400F63D2DF4B3F4640	Bologna
753	Marescalchi	6	Operatore: TPER	0101000020E6100000FB1F60ADDAB526408B5AF51494454640	Bologna
754	Aeroporto	6	Operatore: TPER	0101000020E61000004F5EBFBBF09626401C7343F8BC434640	Bologna
755	Ca` Bianca	6	Operatore: TPER	0101000020E610000014E3A194B5B2264084A33F8FAC464640	Bologna
756	Fermata Servizio Ferrarese	6	Operatore: TPER	0101000020E61000009A2FE53224B52640D2A92B9FE5424640	Bologna
757	Casa della Salute U. Comunali	6	Operatore: TPER	0101000020E61000001F57D92DB8AD2640C4CDA96400414640	Bologna
758	Albertoni	6	Operatore: TPER	0101000020E610000043DCE6D720B926409EF6EF55863E4640	Bologna
759	Berretta Rossa - Opificio Golinelli	6	Operatore: TPER	0101000020E610000074113A43CC9C2640E5FD6E70D8404640	Bologna
760	Nanni Costa	6	Operatore: TPER	0101000020E61000000DE2033BFE9B264042107BFC39414640	Bologna
761	Deposito Battindarno	6	Operatore: TPER	0101000020E6100000737F9AFFFC9726407C7665BC52404640	Bologna
762	Deposito Battindarno	6	Operatore: TPER	0101000020E61000008BFED0CC9397264095511B8B5C404640	Bologna
763	Giotto Centro Commerciale	6	Operatore: TPER	0101000020E61000003B5E375B2F9426403FEC3B759B3F4640	Bologna
764	Cassini	6	Operatore: TPER	0101000020E6100000AD1D20F35C922640F0468BD8CC3E4640	Bologna
765	Certosa Gandhi	6	Operatore: TPER	0101000020E610000080E0E0C1059F26402C1785B8CD3F4640	Bologna
766	Certosa Gandhi	6	Operatore: TPER	0101000020E61000008FE9BFBD219F26408E0CCDD0D33F4640	Bologna
767	Saffi	6	Operatore: TPER	0101000020E61000000D0BFF3394A42640174850FC18404640	Bologna
768	Fermata A;T2	6	Rete: TPER | Operatore: Tper | Con pensilina	0101000020E6100000A359D93EE4AD2640CB8058DBB93F4640	Bologna
769	Fermata 34;183	6	Operatore: TPER	0101000020E61000004F9FD3E24298264038B3A72E2A414640	Bologna
774	Bike in Bo	7	\N	0101000020E6100000EE073C3080B0264024B5503239404640	Bologna
775	Bike Rental Bologna	7	\N	0101000020E6100000F2AA18F89BAE2640B15FC1470E3F4640	Bologna
776	McDonald's	3	Cucina: burger | Takeaway	0101000020E61000009C4EB2D5E5CC264061AD35EF933C4640	Bologna
777	Burger King	3	Cucina: burger | Takeaway	0101000020E6100000B51089E711B02640D2A2E30FAB404640	Bologna
778	Il Panino	3	Cucina: sandwich	0101000020E61000004C87F31549B02640EAB70ABD59404640	Bologna
779	La Tua Piadina	3	Cucina: italian	0101000020E61000000C7F3CAA50B326404ED944C1E73E4640	Bologna
780	McDonald's	3	Cucina: burger | Takeaway	0101000020E6100000055DB1755FB02640091DCFC2F93F4640	Bologna
781	Indegno	3	Cucina: italian	0101000020E6100000EC0F392284B42640845671F4423F4640	Bologna
782	Wei Tea - Bubble Tea & Poke	3	Cucina: bubble_tea;chinese	0101000020E6100000F1A611E96DB22640A9F34D3F4D3F4640	Bologna
783	Nippon Ramen	3	Cucina: japanese	0101000020E610000082D6B26B31B226401A3966344D3F4640	Bologna
784	Le Salentine	3	Cucina: italian	0101000020E6100000A26F1CC242B72640DC566941DE3F4640	Bologna
785	KOI	3	Cucina: chinese	0101000020E6100000C0E78711C2B32640D253E410713F4640	Bologna
786	BE'MO	3	Cucina: chinese	0101000020E610000060F93DFBDBB3264064CA87A06A3F4640	Bologna
787	INQUCINA	3	Cucina: deli	0101000020E61000004E80BCB266BB2640ADA1D45E443F4640	Bologna
788	Largo Respighi	3	Cucina: pizza	0101000020E61000003B133F6B23B32640528836B68D3F4640	Bologna
789	Hamerica's	3	Cucina: burger;diner;american	0101000020E61000009294F430B4AE264017FF2DB76A414640	Bologna
790	Le Bacchette	3	Cucina: chinese	0101000020E6100000A67F492A53B426406B30687CBA3F4640	Bologna
791	Bonelli Burgers	3	Cucina: burger	0101000020E6100000982B28B110AE26403F631525D73F4640	Bologna
792	Pizza Leggera	3	Cucina: pizza	0101000020E610000002F8020EFCAF264008C7D1C19F404640	Bologna
793	Pizzeria Da Youssef	3	Cucina: kebab;pizza	0101000020E610000004A9B981A7B9264056FD005AA93F4640	Bologna
794	O Fiore Mio	3	Cucina: italian_pizza	0101000020E6100000CEAACFD556AC264058BCA2A53C3F4640	Bologna
795	Bottega Portici - 2 Torri	3	Cucina: regional | Takeaway	0101000020E6100000F5A2D1787DB126401F381DB74E3F4640	Bologna
796	Pizzeria Il Monello	3	Cucina: pizza | Takeaway	0101000020E6100000DCED1FB017CB26407D6CDCAC0B3D4640	Bologna
797	Il bello della pizza	3	Cucina: pizza	0101000020E6100000189BB1C3F3A92640138E6A227D404640	Bologna
798	Quebracho - Pollo a La Brasa	3	Cucina: chicken | Takeaway	0101000020E610000099C98168F7B12640FACCFEE5FF414640	Bologna
799	novanta6 Pizza	3	Cucina: pizza | Takeaway	0101000020E61000002DA924FC9CB42640DEBB17A9413F4640	Bologna
800	Mo Mortadella Lab	3	Cucina: sandwich	0101000020E6100000A8B2DE5E88AF2640600C9BB7A03F4640	Bologna
801	Flower Burger	3	Cucina: burger | Takeaway	0101000020E6100000ECF1E780C9AE26406DC7D45DD93F4640	Bologna
802	Sensazioni	3	Cucina: piadina; regional	0101000020E6100000F174F8B53FA126403147EA984E404640	Bologna
803	Bonelli	3	Cucina: burger | Takeaway	0101000020E6100000B4780CEAB6C326407963F7D3353D4640	Bologna
804	Timo Pizzeria	3	Cucina: pizza	0101000020E6100000F365B33401A4264027D2A2E30F404640	Bologna
805	Chicken Hut	3	Cucina: burger;kebab	0101000020E6100000B4A1AC29DAAE264088F71C588E414640	Bologna
806	Green Poké Bologna	3	Cucina: poke	0101000020E6100000C5FAAB6CC4AC26404B6B1D66793F4640	Bologna
807	Regina Sofia Pizza e Sfizi	3	Cucina: pizza	0101000020E6100000FB3A70CE88B62640CA52EBFD463F4640	Bologna
808	Zero Due	3	Cucina: sushi; dimsum; asian; japanese; chinese	0101000020E610000059B44AFAC5BA264020FF16AE583E4640	Bologna
809	L'asporto	3	Cucina: sandwich	0101000020E6100000D6880563E9B02640BBAF6FCC573F4640	Bologna
810	Cou Cou Street Food Bologna	3	Cucina: asian;korean	0101000020E61000002882380F27B026401B24E93F10404640	Bologna
811	Migarba	3	Cucina: sandwich	0101000020E610000030478FDFDBAC26402DBA5054913F4640	Bologna
812	Crock!	3	Cucina: italian;sandwich	0101000020E61000006CA285BAFEAF26401C0F1192603F4640	Bologna
813	Ben Cotta	3	Cucina: pizza	0101000020E6100000D77D117EF3C02640ED8D10D4DF3B4640	Bologna
814	Riso	3	Cucina: chinese	0101000020E610000093FE5E0A0FBE2640BDEAB765763E4640	Bologna
815	Nabò Pizza & Sfizi	3	Cucina: pizza	0101000020E610000045509033A8BD264054628D695C3E4640	Bologna
816	MAIZ Taqueria	3	Cucina: mexican | Takeaway	0101000020E6100000B4C6455ACFB9264062ED94B31C3F4640	Bologna
817	IAAD Bologna - Istituto d'Arte Applicata e Design	5	Tipo ufficio: educational_institution (Bologna)	0101000020E610000084DFE1D121B326409F33B3E08F404640	Bologna
818	Q8	9	Operatore: Burtone Giuseppe e C. S.N.C.	0101000020E61000007F4C6BD3D8CA264092109B7E3F3F4640	Bologna
819	IP	9	Operatore: Gestioni Europa S.P.A.	0101000020E6100000FFE2BE7A818626406AC427F8013F4640	Bologna
820	Eni	9	Operatore: Ely-Mar di Rimondi Giuseppe e Auregli David S.N.C.	0101000020E6100000CAF0E9FBBABD26405AAC9795DC3B4640	Bologna
821	IP	9	Operatore: Colasanto Daniela	0101000020E6100000991A57128FC62640CB259F68683E4640	Bologna
822	IP	9	Operatore: Gestioni Europa S.P.A.	0101000020E610000001A4367172CB264017B5A09C0D424640	Bologna
823	Spring Gas	9	Operatore: Sprint Gas Carburanti S.R.L.	0101000020E61000004EEC46C439972640032DB87AA93F4640	Bologna
824	Eni	9	Operatore: Campazzi S.N.C. di Campazzi Michela & C.	0101000020E61000008705AD760393264085DD66E0363F4640	Bologna
825	Eni	9	Operatore: Aemme S.N.C. di Aparo Angelo e Minarelli Marco	0101000020E6100000AE7FD767CEC62640DB2967391A3F4640	Bologna
826	Eni	9	Operatore: Riccio Francesco e C. S.A.S.	0101000020E6100000DE99643FE69A2640ECB078A004414640	Bologna
827	Q8 Easy	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E6100000A70705A568BD2640F7A287EB623C4640	Bologna
828	Enilive	9	Operatore: Area di Servizio Eni S.A.S. di Oleksandra Vypiraka & C.	0101000020E6100000B8F1DD9C00CD264029D082AB973C4640	Bologna
829	Bertelli Carburanti	9	Operatore: Bertelli Walter e Rolando - Carburanti - S.p.A.	0101000020E6100000A8DEBF1EB8B726403B9B9F2CC6404640	Bologna
830	REL	9	Operatore: Isottano S.N.C. di Rimondi Giuseppe & C.	0101000020E6100000B85CFDD824CB26402A3520E7A23C4640	Bologna
831	IP	9	Operatore: Ip Services S.R.L.	0101000020E61000005EC6038019BE26405AF0A2AF203C4640	Bologna
832	Eni	9	Operatore: Gestioni Innovative Italia S.R.L.	0101000020E6100000E57ADB4C85BC26407D957CEC2E3E4640	Bologna
833	IP	9	Operatore: Natali Roberto	0101000020E6100000F92EA52E19B72640962941DA5A3E4640	Bologna
834	Eni	9	Operatore: Ely-Mar di Rimondi Giuseppe e Auregli David S.N.C.	0101000020E61000005C493CEAF9C82640D1706F230A3D4640	Bologna
835	Q8	9	Operatore: Stazione di Servizio Scanavini Davide	0101000020E61000005A10CAFB38C62640FE614B8FA6414640	Bologna
836	Beyfin	9	Operatore: Bertarelli Maria Cristina	0101000020E6100000DB68A5B50E8B26401C5025B9B2434640	Bologna
837	Ego	9	Operatore: Fuel di Mignani Marco e C. S.A.S.	0101000020E61000007DFF8B0C17A626404152FAF83A424640	Bologna
838	Q8	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E610000025A47F93B7A9264041E77F03A4404640	Bologna
839	Q8	9	Operatore: Sprint Gas - S.p.A.	0101000020E6100000AD7191D673B926407045BD3B8D424640	Bologna
840	Coil	9	Operatore: Non specificato	0101000020E6100000DAD9A1ABBE7C26401D9BD31BA4434640	Bologna
841	Q8	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E610000034057CC8A58326404AD05FE811434640	Bologna
842	Q8	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E6100000BDD41929A58D2640129E7532DD3E4640	Bologna
843	Q8	9	Operatore: Vel - Co di Mazzeo Salvatore e Maccaferri Daniela - Società in Nome Collettivo	0101000020E61000001D8AA7C3AF812640C3FCCBA43C434640	Bologna
844	Avia	9	Operatore: ENERGIA S.P.A.	0101000020E61000000880E0E0C18D264018FE1D9B2E424640	Bologna
845	IP	9	Operatore: Ip Services S.R.L.	0101000020E61000005AF2785A7EC0264034C06092253F4640	Bologna
846	Eni	9	Operatore: Club Auto S.N.C. di Giorgio e Luca Possenti	0101000020E6100000A6D997C7F5B22640D5377A466C404640	Bologna
847	Eni	9	Operatore: Ongaro Adriano	0101000020E6100000AD29DA6674852640202B5327FB3E4640	Bologna
848	IP	9	Operatore: Ip Services S.R.L.	0101000020E61000008C9A54D91CB826407F315BB22A454640	Bologna
849	BC Energia	9	Operatore: Energia S.R.L.	0101000020E61000004F18DEF64ECA26401D48CD0D3C3F4640	Bologna
850	IP	9	Operatore: Pit Stop 2 di Falzone Marco e C. S.N.C.	0101000020E61000003E9A45836FA926402C989DEA35434640	Bologna
851	IP	9	Operatore: Orsoni S.N.C. di Neri Carlo e Orsoni Riccardo	0101000020E6100000C216BB7D56992640B4DCE396A03E4640	Bologna
852	Eni	9	Operatore: Ferri Matteo	0101000020E6100000D0C831A369AA2640CB811E6ADB3F4640	Bologna
853	IP	9	Operatore: Penny S.A.S. di Salvatore La Rizza e C.	0101000020E6100000F1F85168B4A826406157EE601F404640	Bologna
854	Eni	9	Operatore: Bronchi Combustibili S.R.L.	0101000020E6100000A16FC108D0B926405CF5CA06E3454640	Bologna
855	Metano	9	Operatore: Bipiemme - S.R.L.	0101000020E6100000145333B5B6822640467FC39F3C434640	Bologna
856	Metano	9	Operatore: Italmet S.R.L.	0101000020E6100000CF4A5AF10DCD2640910DA48B4D3F4640	Bologna
857	Esso	9	Operatore: Service Car Plus S.A.S. di Lucio Piccolo & C.	0101000020E6100000015D459094B6264092EC6C23F93D4640	Bologna
858	Eni	9	Operatore: Basile Biagio	0101000020E6100000333D17FCECAE26404D1C2F9397444640	Bologna
859	IP	9	Operatore: Ip Services S.R.L.	0101000020E610000051F3FA383FB626408CA37213B5444640	Bologna
860	Q8	9	Operatore: G e P Oil di Martulano Giuseppe & C. S.N.C.	0101000020E6100000F3881B0126B6264056B77A4E7A454640	Bologna
861	Esso	9	Operatore: F.lli Perri di Perri Franco & C. S.A.S.	0101000020E610000015BBC7E3B3B226409064FB35FE424640	Bologna
862	REL	9	Operatore: Caramia Vincenzo	0101000020E6100000DB6F48FEBBBD2640AFE6A507AA3B4640	Bologna
863	IP	9	Operatore: Ip Services S.R.L.	0101000020E6100000D3F8855792BC26403C4ED1915C3A4640	Bologna
864	IP	9	Operatore: Gestioni Europa - Società Per Azioni	0101000020E6100000F551A115738F26407664F6C319414640	Bologna
865	IP	9	Operatore: Fuel & Oil S.A.S. di Vitali Fausto e C.	0101000020E610000075F4AE3033D226400803CFBD87414640	Bologna
866	Q8	9	Operatore: G.S. S.R.L	0101000020E6100000F9A1D28899B92640BAA706F5883D4640	Bologna
867	Q8	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E61000001C98DC28B2CA2640DFF8DA334B424640	Bologna
868	Ego	9	Operatore: N Due S.N.C. di Paggi Elena & Stagni Stefano	0101000020E61000001A03A1AB63C726406AC2F693313D4640	Bologna
869	Q8	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E6100000BB6246787BC02640EA27F796CD3D4640	Bologna
870	Eni	9	Operatore: Basile Biagio	0101000020E610000051E740C5278B264044ABEEEC86414640	Bologna
871	Q8	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E6100000164CFC51D4CD264045A165DD3F3B4640	Bologna
872	Q8	9	Operatore: Sb di Battistini Daniela e C. S.N.C.	0101000020E610000053B4CDE8A2C42640A0ED878ED33C4640	Bologna
873	Enilive	9	Operatore: Vignoli Stefano & C. S.N.C.	0101000020E610000089528C3DC57B26404224438EAD434640	Bologna
874	Sprint Gas	9	Operatore: Non specificato	0101000020E610000094EA4CEB80B92640B89B960E8C424640	Bologna
875	IP	9	Operatore: Bordandini Igino & C. - Società a Responsabilità Limitata	0101000020E610000044520B2593BF2640A49B0EAECA404640	Bologna
876	IP	9	Operatore: Ip Services S.R.L.	0101000020E6100000B84489F1F5982640A249BD022C3F4640	Bologna
877	Esso	9	Operatore: Non specificato	0101000020E6100000A280481A37B42640D00A0C59DD434640	Bologna
878	Q8 Easy	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E6100000E43C52335AB52640FEC34C9132444640	Bologna
879	IP	9	Operatore: Società Azienda Importazione Carburanti Affini - S.A.I.C.A. - a Responsabilità Limitata	0101000020E61000007F2370DA42B2264075C7629B54464640	Bologna
880	Q8	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E61000009542C5DDC5D42640C3352D67A53F4640	Bologna
881	Api-Ip	9	Operatore: Ip Services S.R.L.	0101000020E6100000B2FA7EC575D32640A71F798C973F4640	Bologna
882	Eni	9	Operatore: Mancini Angelo	0101000020E6100000444E5FCFD7B82640CA65ED0099394640	Bologna
883	Eni	9	Operatore: Multi3 S.R.L.	0101000020E6100000ADDC0BCC0ABD2640675A07ACC1444640	Bologna
884	Esso	9	Operatore: Orsini Alessandro	0101000020E610000051853FC39BC52640EA245B5D4E3D4640	Bologna
885	Esso	9	Operatore: Colli & Simoni di Colli Simonetta & C. S.N.C.	0101000020E61000008C46E3F505BD2640EC2E5052603A4640	Bologna
886	Enercoop	9	Operatore: Vega Carburanti	0101000020E6100000C2A0F1E956D8264031348DDC893E4640	Bologna
887	REL	9	Operatore: SERVISAVENA S.R.L.	0101000020E6100000B1146E9E8FD726402B0A05B6943E4640	Bologna
888	Shell	9	Operatore: Non specificato	0101000020E610000053DD6D28C6872640D0BDE20401424640	Bologna
889	IP	9	Operatore: Gruppo API	0101000020E6100000BF3D74E6C3CC2640AAD381ACA7404640	Bologna
890	Bologna Roveri	8	Operatore: Ferrovie Emilia Romagna	0101000020E61000003C8963B895D126408EC1D4E0C73F4640	Bologna
891	Bologna Corticella	8	Operatore: Rete Ferroviaria Italiana | Accessibile in sedia a rotelle	0101000020E61000003F389F3A56B52640CE0BC1BBA6464640	Bologna
892	Bologna Mazzini	8	Operatore: Rete Ferroviaria Italiana | Accessibile in sedia a rotelle	0101000020E610000035C3FCCBA4C02640F402475DC63D4640	Bologna
893	Casteldebole	8	Operatore: Rete Ferroviaria Italiana | Accessibile in sedia a rotelle	0101000020E6100000D1483AB9958C26409B7631CD74404640	Bologna
894	Bologna Borgo Panigale	8	Operatore: Rete Ferroviaria Italiana | Accessibile in sedia a rotelle	0101000020E6100000062747A6E89126408BBE277BF0414640	Bologna
895	Lazzaretto	8	Operatore: Marconi Express | Accessibile in sedia a rotelle	0101000020E6100000AF82CE5AC0A22640100DE60A4A424640	Bologna
896	Bologna Centrale	8	Operatore: Marconi Express | Accessibile in sedia a rotelle	0101000020E6100000D3F544D785AF2640A5B67988EB404640	Bologna
897	Bologna Centrale	8	Operatore: Rete Ferroviaria Italiana | Accessibile in sedia a rotelle	0101000020E6100000F89969B1CAAF26407422669BC0404640	Bologna
898	Bologna Fiere	8	Operatore: Rete Ferroviaria Italiana	0101000020E6100000852BFB09C2BC2640BE0864C0A3414640	Bologna
899	Bologna Zanolini	8	Operatore: Ferrovie Emilia Romagna	0101000020E6100000CA46318A2FB826405AF9C0E9B83F4640	Bologna
900	Bologna San Ruffillo	8	Operatore: Rete Ferroviaria Italiana | Non accessibile in sedia a rotelle	0101000020E61000006F6182BF04BF2640DD64AFD2383B4640	Bologna
901	Forlì	8	Operatore: Rete Ferroviaria Italiana | Accessibile in sedia a rotelle	0101000020E610000088B839950C1C28406C75DE6BAD1C4640	Forlì
914	Agip	9	Operatore: Agip	0101000020E6100000F3C81F0C3C2728400740DCD5AB1C4640	Forlì
902	Biblioteca comunale Aurelio Saffi	1	Biblioteca comunale Aurelio Saffi	0101000020E61000006B33A9FCC61628406E8D637F341C4640	Forlì
903	Biblioteca Centrale "R. Ruffilli"	1	Biblioteca Centrale "R. Ruffilli"	0101000020E6100000B4233031F1122840E99898D30A1C4640	Forlì
904	Robgas	9	Operatore: Robgas Commerciale S.R.L.	0101000020E610000075CB0EF10F332840DE8D058541214640	Forlì
905	Q8	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E610000042075DC2A11F2840AC394030471B4640	Forlì
906	Q8	9	Operatore: Magnani Mauro	0101000020E61000007995B54DF10828404628B682A61D4640	Forlì
907	Eni	9	Operatore: Berti & Ruffilli S.N.C. di Berti Vanni & Ruffilli Silverio	0101000020E61000002CD670917B322840C2F9D4B14A194640	Forlì
908	Esso	9	Operatore: F.lli Galassi di Galassi Stefania e C. - S.N.C.	0101000020E6100000862F5DD2622628400F5F268A901A4640	Forlì
909	Beyfin	9	Operatore: Distributore Carburanti di Cremonini Guerrino e C. S.N.C.	0101000020E610000061EB0896D9FE27403FF559AF33194640	Forlì
910	Agip	9	Operatore: Gestioni Innovative Italia S.R.L.	0101000020E6100000901150E1081A284097E315889E1A4640	Forlì
911	Gep Carburanti	9	Operatore: Celli Giuliano S.R.L.	0101000020E6100000078C3F9B662728409904B9D5BD164640	Forlì
912	Eni	9	Operatore: Catania Nicola	0101000020E6100000D2FD9C82FC14284066FA25E2AD1B4640	Forlì
913	Esso	9	Operatore: Bottoni Massimo	0101000020E610000094A46B26DF1C2840091A33897A1D4640	Forlì
915	AVIA	9	Operatore: Nuova C.L.A.R. S.R.L.	0101000020E61000008C2D043928292840EEED96E4801F4640	Forlì
916	Esso	9	Operatore: Montanari Ivan	0101000020E6100000AF44A0FA07112840245E9ECE151B4640	Forlì
917	Tamoil	9	Operatore: Lambruschi Romano & C. - Società in Nome Collettivo	0101000020E6100000FE614B8FA60A2840B85B9203761D4640	Forlì
918	Eni	9	Operatore: B.M.B. Carburanti S.N.C. di Bertoni Massimo e C.	0101000020E61000006193EB5C072D2840DF3DF669CB1E4640	Forlì
919	Agip	9	Operatore: F.lli Bartolucci S.N.C. di Andrea ed Alvero	0101000020E61000004E29AF95D0212840FA4C5189461D4640	Forlì
920	IP	9	Operatore: Capri Società Cooperativa a Responsabilità Limitata in sigla Coop. Capri	0101000020E610000049788C3C5A062840F66283E04C1E4640	Forlì
921	Eni	9	Operatore: Prati Angelo	0101000020E6100000E49299C1CE1B28408E48CACCBB1B4640	Forlì
922	Agip	9	Operatore: Zannoni S.R.L.	0101000020E61000009C80704FA11028404FEB36A8FD1D4640	Forlì
923	Metano Schiavonia	9	Operatore: Metano Schiavonia S.N.C. di Carini Marco e C.	0101000020E61000001B04673A850A2840821B295B241E4640	Forlì
924	Ego	9	Operatore: Atena S.R.L.	0101000020E61000005875B1C45E2B2840C79FA86C581A4640	Forlì
925	IP	9	Operatore: Caroli Alessandro e Scavone Brunetta S.N.C.	0101000020E6100000F2576DA3A61E2840F7915B936E1B4640	Forlì
926	Q8 Easy	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E6100000F99BF5CE0D1E284056DC137F6F1B4640	Forlì
927	Q8	9	Operatore: Casali S.N.C. di Casali Maurizio	0101000020E6100000ABB019E0821428402AC58EC6A11A4640	Forlì
928	Metano	9	Operatore: Zannoni S.R.L.	0101000020E6100000094FE8F5273128405BBD7960B6204640	Forlì
929	ENI	9	Operatore: Benedetti - Albonetti - Gramellini - Missiroli - S.N.C. di Benedetti Claudio & C.	0101000020E6100000A7D887ABB9FE2740C3D3D0ABA61A4640	Forlì
930	Agip	9	Operatore: Merli Claudio	0101000020E610000006A799492F292840D8220E7E871A4640	Forlì
931	Eni	9	Operatore: Fast Service di Giovannini Davide	0101000020E6100000C560B47D7EFA2740A3F08FAD1D1F4640	Forlì
932	IP	9	Operatore: Ip Services S.R.L.	0101000020E6100000380AB54BC024284030F1EC97F41E4640	Forlì
933	Eni	9	Operatore: Zannoni S.R.L.	0101000020E610000074475A852826284016FA60191B154640	Forlì
934	IP	9	Operatore: S.C.E.L.F. S.R.L.	0101000020E6100000835D031198292840A6C52AEFF41D4640	Forlì
935	IP Matic	9	Operatore: Ip Services S.R.L.	0101000020E6100000C3B3A95F8E0F28402F281DF68C1A4640	Forlì
936	Eni	9	Operatore: Catania Nicola	0101000020E61000004464FD0BA90B28407F49CF99591D4640	Forlì
937	Metano	9	Operatore: Metano	0101000020E61000006419879FA4292840B922E7B3F21D4640	Forlì
938	METANO	9	Operatore: METANO	0101000020E6100000A1B888940B2628403A973D6425154640	Forlì
939	IP	9	Operatore: S.C.E.L.F. S.R.L.	0101000020E61000008F6FEF1AF4292840F8C9AC399B1B4640	Forlì
940	Q8	9	Operatore: Servizi & Gestioni Italia S.R.L.	0101000020E61000007A96D69585112840B2F677B6471D4640	Forlì
941	Q8	9	Operatore: Epa S.R.L.	0101000020E610000037D43950F12D28403FDFBB72621F4640	Forlì
942	Eni	9	Operatore: Gestioni Innovative Italia S.R.L.	0101000020E6100000F5087FD0C42128404A404CC2851E4640	Forlì
943	IP	9	Operatore: Ip Services S.R.L.	0101000020E6100000E0C4EB55BF0D2840F538C258951C4640	Forlì
944	Eni	9	Operatore: Pieraccini & Prati e C. - S.N.C.	0101000020E61000007D70E3BB391D2840FCF8F0D1871B4640	Forlì
945	IP	9	Operatore: Donori Loris	0101000020E61000002F8F90DCF5052840A13C3D00F31D4640	Forlì
946	EnerGas	9	Operatore: Idro Vz S.N.C. di Venieri Andrea Zambrini Giacomo e Meldoli Marco	0101000020E610000098C51FA056502840B7966EB7C91E4640	Forlì
947	IP	9	Operatore: IP	0101000020E6100000C5854DAE7329284061095A37941B4640	Forlì
948	Associazione degli Studenti Slovacchi Università di Bologna	5	Tipo ufficio: educational_institution	0101000020E61000001F0EB7E809142840EA69D14C411C4640	Forlì
999	America Graffiti	3	Cucina: american	0101000020E6100000B994A938C42A28401D00169E3C1E4640	Forlì
1000	Il Chiosco dei Giardini	3	Cucina: piadina;bar | Opzioni vegane | Takeaway	0101000020E61000008CAD56DC6E182840F4B006DE7F1B4640	Forlì
1001	WOW Burger Artigianali	3	Cucina: burger | Takeaway	0101000020E6100000C81C1549051B28405A2668380A1B4640	Forlì
1002	Alibaba	3	Cucina: kebab;indian	0101000020E61000002CD670917B162840311DDF837C1C4640	Forlì
1003	Amburgheria Creativa	3	Cucina: hamburgher;sandwich	0101000020E61000001D9F7F715F152840DE8893A0641B4640	Forlì
1004	Asian Rosticceria e Doner Kebab	3	Cucina: kebab;chinese | Opzioni vegane	0101000020E610000065FCFB8C0B1728400A0385306D1C4640	Forlì
1005	San Martino piada	3	Cucina: piadina;local	0101000020E610000065564A2AAE112840CE55F31C91174640	Forlì
1006	McDonald's	3	Cucina: burger | Takeaway	0101000020E6100000B164332CEB0B28404FAB8D565A1D4640	Forlì
1007	Campus Universitario di Forlì	2	Campus Universitario di Forlì	0106000020E6100000010000000103000000010000001300000083AF9E495115284049DA8D3EE61B464007EC6AF294152840A75A0BB3D01B4640D03D9061BA1528405F189FB8D21B46403FFD0C141D162840C75A8D36D81B46404784903D8C1628403ACF3351DF1B46405015F82FB5162840D93E8974E41B4640FFAD090ED4162840EE71F096F51B46400D4460F6FC162840B2ECEEA6001C464017A9E628F61628403A6E9D24021C464067599CD6121728408AC4A97B091C4640CFFD309D31172840192CE631141C4640C3D66CE5251728407C2766BD181C464081DBC9969B162840C46C1338231C464034FE33396B162840F2B62D25261C4640629923D005162840F5633843161C4640E67228E89B1528404BE7C3B3041C4640BCDB06FF6C152840A3EFC91EFC1B4640D383279941152840E5DB16C0EF1B464083AF9E495115284049DA8D3EE61B4640	Forlì
1064	Box8	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000994FB1C5C91C28402ACA00AB7E1C4640	Forlì
1008	Dipartimento di Ingegneria - Università di Bologna	2	Dipartimento di Ingegneria - Università di Bologna	0106000020E6100000010000000103000000010000000600000016F1E725102028400DB55CECAC19464047E28A30EA1F28406CCEC133A119464084899A43AD20284093B943D48E1946402DF5E27ACA2028407C24CA83991946407CDE43786A20284076285481A419464016F1E725102028400DB55CECAC194640	Forlì
1009	Ingegneria Aerospaziale - Meccanica - Università di Bologna	2	Ingegneria Aerospaziale - Meccanica - Università di Bologna	0106000020E6100000010000000103000000010000000600000081F33D7ECA202840BBB486F7C1194640094FE8F5272128402B61B719B81946407E231521D0202840BB911E2B9D19464051007B3B78202840C9F264EDA519464093BD4AE3BC202840272F3201BF19464081F33D7ECA202840BBB486F7C1194640	Forlì
1010	Campus Universitario II	7	Operatore: Mi muovo in bici | Capacità: 10 posti	0101000020E6100000C00C2142B7162840B80ABD59DE1B4640	Bologna
1011	Campus Universitario I	7	Operatore: Mi muovo in bici | Capacità: 8 posti	0101000020E6100000C9FFE4EFDE1528400AE7093A101C4640	Bologna
1012	Vittoria	7	Operatore: Mi muovo in bici | Capacità: 8 posti	0101000020E6100000A140E955AE1928409462EC29DE1B4640	Bologna
1013	Vittorio Veneto	7	Operatore: Mi muovo in bici | Capacità: 13 posti	0101000020E6100000133E004E94152840485AE0E12C1D4640	Bologna
1014	Piazza Saffi	7	Operatore: Mi muovo in bici | Capacità: 28 posti	0101000020E6100000C64E78094E152840C3FEA14F9A1C4640	Bologna
1015	San Domenico	7	Operatore: Mi muovo in bici | Capacità: 14 posti	0101000020E6100000BA4BE2AC88122840F3565D876A1C4640	Bologna
1016	Park dell'Argine	7	Operatore: Mi muovo in bici | Capacità: 21 posti	0101000020E6100000C8BCE9F1D6102840631525D7031C4640	Bologna
1017	Park Schiavonia	7	Operatore: Mi muovo in bici | Capacità: 6 posti	0101000020E61000007412A5187B0E2840D6355A0EF41C4640	Bologna
1018	Ospedale Morgagni Pierantoni	7	Operatore: Mi muovo in bici | Capacità: 6 posti	0101000020E6100000A76ED344440A2840FCDB0A067C1A4640	Bologna
1019	Park Oriani	7	Operatore: Mi muovo in bici | Capacità: 7 posti	0101000020E6100000F212526D26192840D3BAB2B04C1C4640	Bologna
1020	Campus Universitario II	7	Operatore: Mi muovo in bici | Capacità: 10 posti	0101000020E6100000C00C2142B7162840B80ABD59DE1B4640	Bologna
1021	Campus Universitario I	7	Operatore: Mi muovo in bici | Capacità: 8 posti	0101000020E6100000C9FFE4EFDE1528400AE7093A101C4640	Bologna
1022	Vittoria	7	Operatore: Mi muovo in bici | Capacità: 8 posti	0101000020E6100000A140E955AE1928409462EC29DE1B4640	Bologna
1023	Vittorio Veneto	7	Operatore: Mi muovo in bici | Capacità: 13 posti	0101000020E6100000133E004E94152840485AE0E12C1D4640	Bologna
1024	Piazza Saffi	7	Operatore: Mi muovo in bici | Capacità: 28 posti	0101000020E6100000C64E78094E152840C3FEA14F9A1C4640	Bologna
1025	San Domenico	7	Operatore: Mi muovo in bici | Capacità: 14 posti	0101000020E6100000BA4BE2AC88122840F3565D876A1C4640	Bologna
1026	Park dell'Argine	7	Operatore: Mi muovo in bici | Capacità: 21 posti	0101000020E6100000C8BCE9F1D6102840631525D7031C4640	Bologna
1027	Park Schiavonia	7	Operatore: Mi muovo in bici | Capacità: 6 posti	0101000020E61000007412A5187B0E2840D6355A0EF41C4640	Bologna
1028	Ospedale Morgagni Pierantoni	7	Operatore: Mi muovo in bici | Capacità: 6 posti	0101000020E6100000A76ED344440A2840FCDB0A067C1A4640	Bologna
1029	Park Oriani	7	Operatore: Mi muovo in bici | Capacità: 7 posti	0101000020E6100000F212526D26192840D3BAB2B04C1C4640	Bologna
1030	Campus Universitario II	7	Operatore: Mi muovo in bici | Capacità: 10 posti	0101000020E6100000C00C2142B7162840B80ABD59DE1B4640	Bologna
1031	Campus Universitario I	7	Operatore: Mi muovo in bici | Capacità: 8 posti	0101000020E6100000C9FFE4EFDE1528400AE7093A101C4640	Bologna
1032	Vittoria	7	Operatore: Mi muovo in bici | Capacità: 8 posti	0101000020E6100000A140E955AE1928409462EC29DE1B4640	Bologna
1033	Vittorio Veneto	7	Operatore: Mi muovo in bici | Capacità: 13 posti	0101000020E6100000133E004E94152840485AE0E12C1D4640	Bologna
1034	Piazza Saffi	7	Operatore: Mi muovo in bici | Capacità: 28 posti	0101000020E6100000C64E78094E152840C3FEA14F9A1C4640	Bologna
1035	San Domenico	7	Operatore: Mi muovo in bici | Capacità: 14 posti	0101000020E6100000BA4BE2AC88122840F3565D876A1C4640	Bologna
1036	Park dell'Argine	7	Operatore: Mi muovo in bici | Capacità: 21 posti	0101000020E6100000C8BCE9F1D6102840631525D7031C4640	Bologna
1037	Park Schiavonia	7	Operatore: Mi muovo in bici | Capacità: 6 posti	0101000020E61000007412A5187B0E2840D6355A0EF41C4640	Bologna
1038	Ospedale Morgagni Pierantoni	7	Operatore: Mi muovo in bici | Capacità: 6 posti	0101000020E6100000A76ED344440A2840FCDB0A067C1A4640	Bologna
1039	Park Oriani	7	Operatore: Mi muovo in bici | Capacità: 7 posti	0101000020E6100000F212526D26192840D3BAB2B04C1C4640	Bologna
1040	Campus Universitario II	7	Operatore: Mi muovo in bici | Capacità: 10 posti	0101000020E6100000C00C2142B7162840B80ABD59DE1B4640	Forlì
1041	Campus Universitario I	7	Operatore: Mi muovo in bici | Capacità: 8 posti	0101000020E6100000C9FFE4EFDE1528400AE7093A101C4640	Forlì
1042	Vittoria	7	Operatore: Mi muovo in bici | Capacità: 8 posti	0101000020E6100000A140E955AE1928409462EC29DE1B4640	Forlì
1043	Vittorio Veneto	7	Operatore: Mi muovo in bici | Capacità: 13 posti	0101000020E6100000133E004E94152840485AE0E12C1D4640	Forlì
1044	Piazza Saffi	7	Operatore: Mi muovo in bici | Capacità: 28 posti	0101000020E6100000C64E78094E152840C3FEA14F9A1C4640	Forlì
1045	San Domenico	7	Operatore: Mi muovo in bici | Capacità: 14 posti	0101000020E6100000BA4BE2AC88122840F3565D876A1C4640	Forlì
1046	Park dell'Argine	7	Operatore: Mi muovo in bici | Capacità: 21 posti	0101000020E6100000C8BCE9F1D6102840631525D7031C4640	Forlì
1047	Park Schiavonia	7	Operatore: Mi muovo in bici | Capacità: 6 posti	0101000020E61000007412A5187B0E2840D6355A0EF41C4640	Forlì
1048	Ospedale Morgagni Pierantoni	7	Operatore: Mi muovo in bici | Capacità: 6 posti	0101000020E6100000A76ED344440A2840FCDB0A067C1A4640	Forlì
1049	Park Oriani	7	Operatore: Mi muovo in bici | Capacità: 7 posti	0101000020E6100000F212526D26192840D3BAB2B04C1C4640	Forlì
1050	Aeroporto	6	Operatore: Start Romagna	0101000020E6100000234E82925D242840370B6AAE89194640	Forlì
1051	Vittoria A	6	Operatore: Start Romagna | Con pensilina	0101000020E610000059901C9F7F1928409D0C33D9E41B4640	Forlì
1052	Libertà-Scuole	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000FFAAC88DC7192840D2B5E512FD1B4640	Forlì
1053	Centro Studi (Risorgimento)	6	Operatore: StartRomagna	0101000020E610000021729FC14B152840C573B680D01A4640	Forlì
1054	Stazione FS	6	Rete: TPER | Operatore: Start Romagna | Con pensilina	0101000020E6100000D08FD0E0001C284027D87F9D9B1C4640	Forlì
1055	Eritrea	6	Operatore: Start Romagna	0101000020E61000004D52F41B811F2840298EA8F5231E4640	Forlì
1056	Ospedaletto	6	Operatore: Start Romagna	0101000020E61000007022FAB5F51F2840E89FE062451E4640	Forlì
1057	Orceoli	6	Operatore: Start Romagna	0101000020E6100000B32A1D07B9222840A1C10188161E4640	Forlì
1058	Box7	6	Operatore: Start Romagna | Con pensilina	0101000020E61000002FB319F1AE1C284011AAD4EC811C4640	Forlì
1059	Box2	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000D5642195BD1C28403E78EDD2861C4640	Forlì
1060	Box4	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000262DA6E37B1C2840E7751FDB8D1C4640	Forlì
1061	Box1	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000311FB52EDA1C28400A57F613841C4640	Forlì
1062	Box6	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000A730A5E48B1C2840C8050C37851C4640	Forlì
1063	Box3	6	Operatore: Start Romagna | Con pensilina	0101000020E610000003160A229C1C28409B2CFF6B8A1C4640	Forlì
1065	Box5	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000FF04172B6A1C28400D1C2B8C881C4640	Forlì
1066	Vittoria B	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000775325259819284057AE5C14E21B4640	Forlì
1067	Forli FS B	6	Rete: TPER | Operatore: Start Romagna | Con pensilina	0101000020E6100000E4FF441B361C2840E8B2E265971C4640	Forlì
1068	Forli FS C	6	Rete: TPER | Operatore: Start Romagna | Con pensilina	0101000020E6100000AE5F5562431C28404E7E8B4E961C4640	Forlì
1069	Forli FS D	6	Rete: TPER | Operatore: Start Romagna | Con pensilina	0101000020E610000054A1CBE5501C28403DA30804951C4640	Forlì
1070	Forli FS A	6	Rete: TPER | Operatore: Start Romagna | Con pensilina	0101000020E61000002068603F1F1C2840EC4905BA9B1C4640	Forlì
1071	Fiera	6	Operatore: Start Romagna	0101000020E6100000F75965A6B42628401C599EACBD1E4640	Forlì
1072	Centro Studi (Moro) A	6	Operatore: StartRomagna | Con pensilina	0101000020E6100000D2133BBFCD132840658BA4DDE81A4640	Forlì
1073	Centro Studi (Moro) B	6	Operatore: StartRomagna | Con pensilina	0101000020E61000002D1098E205142840F7A52325E21A4640	Forlì
1074	Pierantoni (Forlanini)	6	Operatore: StartRomagna | Con pensilina	0101000020E61000003B29DDA7F4092840970E8C721F1A4640	Forlì
1075	Montaspro	6	Rete: TPER | Operatore: Start Romagna	0101000020E6100000E2DEA1CD162128401B35BADE91194640	Forlì
1076	Montaspro	6	Rete: TPER | Operatore: Start Romagna	0101000020E6100000E1A1DE420D2128407817DE9B95194640	Forlì
1077	Berlinguer	6	Operatore: Start Romagna	0101000020E610000051F0B9B832292840C6F6FF16091A4640	Forlì
1078	Montgolfier	6	Operatore: Start Romagna	0101000020E6100000FBA24E8AA0272840A711E96D221A4640	Forlì
1079	Icaro	6	Operatore: Start Romagna	0101000020E610000085FC7D1013262840CB3D6E090A1A4640	Forlì
1080	Itaer	6	Operatore: Start Romagna	0101000020E610000054C48E6BE81F2840BC896BC6B3194640	Forlì
1081	Fontanelle	6	Rete: TPER | Operatore: Start Romagna	0101000020E6100000100C7B359B1E28403A083A5AD5194640	Forlì
1082	Ottaviani	6	Operatore: Start Romagna	0101000020E61000003B6178DB3B1D2840ABAD7DA6031A4640	Forlì
1083	Teatro Il Piccolo	6	Operatore: Start Romagna	0101000020E61000004C22B193B01D284056009D93281A4640	Forlì
1084	Bernardi	6	Operatore: Start Romagna	0101000020E610000002EDB36F931E284080FF9C386F1A4640	Forlì
1085	Spazzoli	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000F75D6CB5E21E28406868F283A91A4640	Forlì
1086	Liverani	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000F7274C73861D2840799A2732CE1A4640	Forlì
1087	Poligono	6	Operatore: Start Romagna | Con pensilina	0101000020E61000001E1DB2DC2D1C28408ACC5CE0F21A4640	Forlì
1088	Campo di Marte	6	Operatore: Start Romagna	0101000020E6100000B5F97FD5911B2840CF842689251B4640	Forlì
1089	Stadium	6	Operatore: Start Romagna	0101000020E6100000DAE38574781C28401F7B6242711B4640	Forlì
1090	Cucchiari	6	Operatore: Start Romagna	0101000020E6100000E9C946318A1B28404DCF053FBB1B4640	Forlì
1091	Galilei	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000E2FCF26ED11A2840AE06729A4F1C4640	Forlì
1092	Colombo	6	Operatore: Start Romagna	0101000020E61000001EE0490B97192840BF9CD9AED01C4640	Forlì
1093	Teatro Testori	6	Operatore: Start Romagna	0101000020E6100000D902E7316F1A2840DF162CD5051D4640	Forlì
1094	Foro Boario	6	Operatore: Start Romagna	0101000020E61000008C5C8132D71B2840161E8F74611D4640	Forlì
1095	Forli (Cimitero)	6	Rete: TPER | Operatore: Start Romagna	0101000020E610000028B682A6251E2840B5649F11B61D4640	Forlì
1096	Spinelli	6	Operatore: Start Romagna	0101000020E61000009DC541F806212840FC164273421E4640	Forlì
1097	M. Da Padova	6	Operatore: Start Romagna	0101000020E6100000F8EE456A90242840777066AA161E4640	Forlì
1098	Cervese	6	Operatore: Start Romagna	0101000020E61000006CF992D7942528406CC779A4661E4640	Forlì
1099	Fiera	6	Operatore: Start Romagna	0101000020E61000005160A692A62628405180CDDEBE1E4640	Forlì
1100	Iper Forli	6	Operatore: Start Romagna	0101000020E610000004A4A2563D29284010882183261F4640	Forlì
1101	Iper Forli	6	Operatore: Start Romagna	0101000020E610000098EF2AB528292840530D56F7231F4640	Forlì
1102	Cervese	6	Operatore: Start Romagna	0101000020E6100000720976B28A25284082C64CA25E1E4640	Forlì
1103	M. Da Padova	6	Operatore: Start Romagna	0101000020E6100000A63FA0D8AF242840C91A9A571A1E4640	Forlì
1104	Orceoli	6	Operatore: Start Romagna	0101000020E6100000B10342469B222840363F598C151E4640	Forlì
1105	Spinelli	6	Operatore: Start Romagna	0101000020E6100000891F0835E82028401FED24C7421E4640	Forlì
1106	Ospedaletto	6	Operatore: Start Romagna	0101000020E610000008628F3F072028406CCCEB88431E4640	Forlì
1107	Eritrea	6	Operatore: Start Romagna	0101000020E61000004DFF48C78B1F2840A38E33F21E1E4640	Forlì
1108	Forli (Cimitero)	6	Rete: TPER | Operatore: Start Romagna	0101000020E6100000EAFBBA1D2B1E2840EDBD535CB01D4640	Forlì
1109	Foro Boario	6	Operatore: Start Romagna	0101000020E6100000EF16ED96891B284083818C25511D4640	Forlì
1110	Teatro Testori	6	Operatore: Start Romagna	0101000020E6100000A191BEFF451A2840F8020EFC031D4640	Forlì
1111	Colombo	6	Operatore: Start Romagna	0101000020E6100000DC18969A98192840C481EBE5D21C4640	Forlì
1112	Costa	6	Operatore: Start Romagna	0101000020E61000005ECD4B0F541B2840B5E44C6E6F1C4640	Forlì
1113	Galilei	6	Operatore: Start Romagna | Con pensilina	0101000020E610000064A25236F61A2840C52E9B4A501C4640	Forlì
1114	Cucchiari	6	Operatore: Start Romagna	0101000020E6100000533AFD45751B284065451ED2B91B4640	Forlì
1115	Stadium	6	Operatore: Start Romagna	0101000020E6100000D2ACC7D8641C2840F0B4464E701B4640	Forlì
1116	Campo di Marte	6	Operatore: Start Romagna	0101000020E6100000FCF8F0D1871B28400ADF56D5261B4640	Forlì
1117	Poligono	6	Operatore: Start Romagna	0101000020E6100000C93846B2471C28402EDC03BEEC1A4640	Forlì
1118	Liverani	6	Operatore: Start Romagna	0101000020E6100000684D3D1C6E1D2840200DA7CCCD1A4640	Forlì
1119	Spazzoli	6	Operatore: Start Romagna	0101000020E610000068D608B3BF1E28407AA5D189A91A4640	Forlì
1120	Bernardi	6	Operatore: Start Romagna	0101000020E6100000A5BF97C2831E2840E5DEB2F96E1A4640	Forlì
1121	Teatro Il Piccolo	6	Operatore: Start Romagna	0101000020E6100000102620819A1D28406915A2E8261A4640	Forlì
1122	Ottaviani	6	Operatore: Start Romagna	0101000020E61000006729594E421D28408864C8B1F5194640	Forlì
1123	Fontanelle	6	Rete: TPER | Operatore: Start Romagna	0101000020E610000088BCE5EAC71E284097E1E423CE194640	Forlì
1124	Itaer	6	Operatore: Start Romagna	0101000020E6100000B9DFA128D01F2840AA381FE8B2194640	Forlì
1125	Aeroporto	6	Operatore: Start Romagna	0101000020E6100000872DE2E0772428409AE1500999194640	Forlì
1126	Icaro	6	Operatore: Start Romagna	0101000020E610000061DEE34C1326284063D6E65A0F1A4640	Forlì
1127	Montgolfier	6	Operatore: Start Romagna	0101000020E610000087BB1F5CA62728407C444C89241A4640	Forlì
1128	Ponte Nuovo	6	Operatore: Start Romagna	0101000020E61000000F289B728577284000AC8E1CE9114640	Cesena
1129	Ippodromo TML A	6	Operatore: Start Romagna | Con pensilina	0101000020E61000008BC9761959752840A0FCDD3B6A124640	Cesena
1130	Gramsci	6	Operatore: Start Romagna	0101000020E6100000C459B67B5E7628407E0C0C0F50124640	Cesena
1131	Battisti	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000A728F27FA2792840D2B1DE03CF114640	Cesena
1132	Papa	6	Operatore: Start Romagna	0101000020E610000057314BF1A77C284098906A33A9114640	Cesena
1133	Chiaramonti	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000AC7DF090187B284041AB8207BC114640	Cesena
1134	Duomo	6	Operatore: Start Romagna	0101000020E61000008E46F4215E7D2840F83F76CD9A114640	Cesena
1135	Piazza della Libertà	6	Operatore: Start Romagna	0101000020E610000027BD6F7CED7D2840F789A82E85114640	Cesena
1136	Teatro	6	Operatore: Start Romagna	0101000020E610000066FFF27FFD7E28401401F33570114640	Cesena
1137	Valzania	6	Operatore: Start Romagna	0101000020E61000007D259012BB8228409FCFDB33A6114640	Cesena
1138	Giardini Via Verdi	6	Operatore: Start Romagna	0101000020E6100000F93FD1860D802840BD84549B49114640	Cesena
1139	Ghirotti Ospedale	6	Operatore: Start Romagna | Con pensilina	0101000020E610000027DE019EB484284013B3035372114640	Cesena
1140	Battistini Ospedale	6	Operatore: Start Romagna	0101000020E610000059B5B5CF7484284054D3E4187F114640	Cesena
1141	Cesare Montanari	6	Operatore: Start Romagna	0101000020E6100000AD7CE074DC7E2840FF82932353114640	Cesena
1142	Ospedale	6	Operatore: Start Romagna | Con pensilina	0101000020E61000002E0BDC700E852840F6871C1142114640	Cesena
1143	Valzania	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000413BF1E6BA822840C6C61748AB114640	Cesena
1144	Comandini	6	Operatore: Start Romagna	0101000020E61000000EDD47C906812840835781107F114640	Cesena
1145	Teatro	6	Operatore: Start Romagna	0101000020E610000069A85148327F2840493C8F4072114640	Cesena
1146	Piazza della Libertà	6	Operatore: Start Romagna	0101000020E6100000B0DE4D5C337E2840715C210780114640	Cesena
1147	Papa	6	Operatore: Start Romagna	0101000020E6100000A2B437F8C27C2840C7287403AA114640	Cesena
1148	Duomo	6	Operatore: Start Romagna	0101000020E6100000346B84D95F7D28406EF4D6659D114640	Cesena
1149	Chiaramonti	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000DCE33BE75D7B28408815C9B2BB114640	Cesena
1150	Tripoli	6	Operatore: Start Romagna	0101000020E6100000AAFC21ECCA7528400B6C843419124640	Cesena
1151	Matteotti	6	Operatore: Start Romagna	0101000020E61000009D0C33D9E4752840C9B2BB9B02124640	Cesena
1152	Ponte Nuovo	6	Operatore: Start Romagna	0101000020E61000000BCD1A61F677284042A154B1E7114640	Cesena
1153	Battisti	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000D06D7830187A2840CDE67118CC114640	Cesena
1154	Ex Zuccherificio	6	Operatore: Start Romagna	0101000020E6100000EF552B137E792840333A7BC26D124640	Cesena
1155	Ippodromo TML B	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000EA2E3F2608752840F682AA2C65124640	Cesena
1156	Saba	6	Operatore: Start Romagna	0101000020E610000004EF9A46497A28408D91369F84124640	Cesena
1157	Università	6	Operatore: Start Romagna	0101000020E61000006BBA9EE8BA7828406AC999DCDE124640	Cesena
1158	Quasimodo	6	Operatore: Start Romagna	0101000020E6100000206A91A3EF78284013DD6921B7124640	Cesena
1159	Europa	6	Operatore: Start Romagna	0101000020E61000003BD2CF8A5E7C284083A5BA8097124640	Cesena
1160	Barriera Terminal	6	Operatore: Start Romagna | Con pensilina	0101000020E61000006BCDFBA47F7E284097715303CD114640	Cesena
1161	USL	6	Operatore: Start Romagna	0101000020E6100000333E82D19B802840DC2E34D769124640	Cesena
1162	Monopoli	6	Operatore: Start Romagna	0101000020E6100000A8740BB8427F28406157EE601F124640	Cesena
1163	Serraglio	6	Operatore: Start Romagna | Con pensilina	0101000020E610000079C83956CE7F2840F39CE39299114640	Cesena
1164	Porta Santi	6	Operatore: Start Romagna	0101000020E61000007BB2AC45558128400723F609A0114640	Cesena
1165	Ghirotti Ospedale	6	Operatore: Start Romagna	0101000020E6100000DAB2D716F98428402CADD05158114640	Cesena
1166	Brunelli	6	Operatore: Start Romagna | Con pensilina	0101000020E6100000A5749FD277852840D957C3EA34114640	Cesena
1167	Madre Teresa di Calcutta	6	Operatore: Start Romagna	0101000020E6100000317DAF2138862840EA3E00A94D114640	Cesena
1168	Molise	6	Operatore: Start Romagna	0101000020E610000065C405A05186284001248914B9114640	Cesena
1169	Verazzano	6	Operatore: Start Romagna	0101000020E610000047938B31B08628402920ED7F80114640	Cesena
1170	Piazzale Olimpia	6	Operatore: Start Romagna	0101000020E61000001D50DB2B98852840B121EEA0C8114640	Cesena
1171	Montefiore	6	Operatore: Start Romagna | Con pensilina	0101000020E61000006D623722CE852840839E72F15C124640	Cesena
1172	Verazzano	6	Operatore: Start Romagna	0101000020E610000052D32EA6998628403145B9347E114640	Cesena
1173	Molise	6	Operatore: Start Romagna	0101000020E61000001FC99BB2898628406A4FC939B1114640	Cesena
1174	Madre Teresa di Calcutta	6	Operatore: Start Romagna	0101000020E6100000A667D5422486284062A9E4524B114640	Cesena
1175	Porta Santi	6	Operatore: Start Romagna	0101000020E61000008993A06417812840A8D205ABA0114640	Cesena
1176	Piazzale Olimpia	6	Operatore: Start Romagna	0101000020E610000020240B98C0852840C0E78711C2114640	Cesena
1177	Brunelli	6	Operatore: Start Romagna | Con pensilina	0101000020E610000087BC8A31558528403B5684F645114640	Cesena
1178	Serraglio	6	Operatore: Start Romagna	0101000020E61000008636A5619D7F284070EF1AF4A5114640	Cesena
1179	Barriera Carducci	6	Operatore: Start Romagna	0101000020E6100000089BF001707E28409E29CF17D6114640	Cesena
1180	Angeloni	6	Operatore: Start Romagna	0101000020E6100000912749D74C7E28400C1EA67D73124640	Cesena
1181	Finali	6	Operatore: Start Romagna	0101000020E61000003B657FEA697D2840538BD2EF0C124640	Cesena
1182	Finali	6	Operatore: Start Romagna	0101000020E61000009DAD7257657D28408948A8740B124640	Cesena
1183	Parcheggio Mattarella	7	\N	0101000020E6100000959EE925C67E2840C1745AB741124640	Cesena
1184	Piazzale della Stazione ferroviaria	7	Operatore: http://www.comune.cesena.fc.it/flex/cmhttp://www.comune.cesena.fc.it/flex/cm/pages/ServeBLOB.php/L/IT/IDPagina/10373/pages/ServeBLOB.php/L/IT/IDPagina/10373	0101000020E610000008BB174E887F28409EA0038184124640	Cesena
1185	MiMuovo	7	\N	0101000020E6100000B52F455E7B7F28404AEF1B5F7B124640	Cesena
1186	Stazione Noleggio Bici	7	Operatore: Bicincittà	0101000020E6100000BBF7CB82E4782840C5515ED0E7124640	Cesena
1190	Facoltà di Agraria	2	Facoltà di Agraria	0106000020E6100000010000000103000000020000000E000000AB8D565AEB7C2840F54FCB6A15144640D7602BB2E77C2840F54FCB6A151446408967BFA4E77C2840CA20D2CA18144640B7578BF4477D2840825A67D718144640E1325D3E487D284086274FB406144640C14879F7117D2840DF2A99AD06144640B2B2220FE97C284062AD90A80614464065B9B601E97C28405ACA43F0091446409FF3098FEC7C28405ACA43F009144640A5F8F884EC7C2840777B5A8F0C14464037F9D280E67C2840E2BB838E0C1446404303B16CE67C2840C1EC54AF111446404C851D6BEB7C284056AC2BB011144640AB8D565AEB7C2840F54FCB6A1514464005000000A7BA360AFF7C284049F2012615144640E3EC8CA5FE7C2840660234000A144640F3075E88307D28408449F1F109144640B7D507ED307D28406639BF1715144640A7BA360AFF7C284049F2012615144640	Cesena
1191	Ingegneria e Scienze Informatiche	2	Ingegneria e Scienze Informatiche	0106000020E6100000010000000103000000020000001900000075A098068F7C2840D2C3D0EAE4114640E1FA66518E7C28406DA23B2DE41146400561B8848D7C284080CBAD5AE31146401F25C0FA897C28406ADD06B5DF1146402D3993DB9B7C2840356E2013DF1146409E5099AC9B7C28403CEF1010DD114640AA5A77989B7C2840B325AB22DC114640B20FB22C987C28400C570740DC114640269C27E8407C28407C629D2ADF114640267F411C357C2840CFEA2E9ADF11464045701239337C28409961A3ACDF11464091B932A8367C28400142356FE611464061490389377C2840D1E57228E8114640DCBA9BA73A7C2840C295A24BEE11464095568D6F397C28409816F549EE11464078859911397C2840663E31FCF1114640FA1BFEE4397C2840D1A634ACF3114640BEDBBC71527C284036864A6DF3114640CB75093D517C2840F0F96184F011464077BF65A9507C2840910BCEE0EF1146406C45F69C4F7C28409EEDD11BEE114640CD58349D9D7C28408E469968EB114640BB911E2B9D7C28407DE71725E811464074F04C68927C284083482B63E811464075A098068F7C2840D2C3D0EAE411464007000000CCC0B79F427C2840EB257CA5E21146402C15AF0D707C2840992D5915E1114640CED9A788787C284024264D28E9114640339B11EF4A7C2840ACA7FBA5EA1146406A300DC3477C284066ED0099E7114640771211FE457C284013C7CBE4E5114640CCC0B79F427C2840EB257CA5E2114640	Cesena
1192	Campus di Scienze degli Alimenti	2	Campus di Scienze degli Alimenti	0106000020E6100000010000000103000000010000000C0000003CD5C67D507C28403C8B3963F313464046EBA86A827C28406C6BFAA2F31346407A14538E6E7D28409B4BBBE2F31346407A14538E6E7D2840A0F18E9D0114464068A4EF7F917D2840B8616FBD011446400397C79A917D2840EEFCEC91171446402625F37E927D2840A120675023144640757FAB2B557C2840899C195822144640757FAB2B557C28402823D3461A144640BA86191A4F7C2840342DB1321A144640E31934F44F7C28405DD1F7640F1446403CD5C67D507C28403C8B3963F3134640	Cesena
1193	Seconda Facoltà di Ingegneria	2	teaching	0106000020E6100000010000000103000000010000000500000088258A35017B28404524AF737813464075C12A28567B2840C8D4B892781346407B0ED18D557B28406DD0F297711346403BE466B8017B2840D8101C977113464088258A35017B28404524AF7378134640	Cesena
1194	Seconda Facoltà di Ingegneria	2	Seconda Facoltà di Ingegneria	0106000020E610000001000000010300000001000000050000008EB51A6DB07B2840D99D49F663124640E95ECC3BF37B28409D3DE13664124640BEABD4A2F47B28401245ED235C124640B7007ED7B17B28408A05BEA25B1246408EB51A6DB07B2840D99D49F663124640	Cesena
1195	Seconda Facoltà di Ingegneria	2	laboratories	0106000020E6100000010000000103000000010000000A000000EED9290C807B2840B4ED0FEF941346401ABFF04A927B2840B4ED0FEF94134640358AF6C2AE7B28401F2E39EE94134640358AF6C2AE7B2840D1A45E019613464004FAE9E4B17B2840D1A45E01961346405EFD33DEB17B28402F9EE6898C134640328BF5B2927B2840C45DBD8A8C13464047DD7305807B2840591D948B8C134640EED9290C807B284038BEF6CC92134640EED9290C807B2840B4ED0FEF94134640	Cesena
1196	Università di Bologna - Facoltà di Psicologia	2	Università di Bologna - Facoltà di Psicologia	0106000020E61000000100000001030000000100000012000000CF0B1C75197F2840E284533074124640BCDC71D41B7F28408EC8772975124640A78AF3812E7F28405B26C3F17C1246403FD873E3277F2840DE60037D7D12464073558FEA2A7F28403602F1BA7E124640E92ADD5D677F2840CEA55DF179124640CCE957DF657F2840AA73565579124640115663096B7F284093A751ED78124640ECA75A666C7F2840925F9A7D79124640F3A55C86A47F2840A0D7440B7512464018D2E1218C7F284076919D126B12464021CEC3094C7F284008C902267012464002953B7D4E7F28405B09DD2571124640813E9127497F28405B931392711246406720E05A377F2840AD5D24FE72124640D8FD19941F7F2840A6AE21DD74124640982E69311D7F28408F2AD4E473124640CF0B1C75197F2840E284533074124640	Cesena
1218	Esso	9	Operatore: Esso 3 B Lavaggio Cesenate di Bravaccini R. & C. S.N.C.	0101000020E61000008A004CBE7E752840364A4D710B124640	Cesena
1197	Università di Bologna - Facoltà di Psicologia	2	Università di Bologna - Facoltà di Psicologia	0106000020E610000001000000010300000001000000060000007039A80E037F28403A4E1B1F7712464024BAC216167F2840DD2CB9E57E1246403FD873E3277F2840DE60037D7D124640A78AF3812E7F28405B26C3F17C124640BCDC71D41B7F28408EC87729751246407039A80E037F28403A4E1B1F77124640	Cesena
1198	Università di Bologna - Campus di Cesena	2	Università di Bologna - Campus di Cesena	0106000020E6100000010000000103000000010000002D00000074FE37407A782840E6C52EF6031346402EE2E07778782840D39684550613464002A667D542782840390609F604134640E3B496B84478284034F3E49A02134640AB47759549782840EA2BFEA5FB1246402C239AE557782840CBB2710EE812464066C28AAE6678284059C97D61E81246408908FF22687828408A6DF717E612464004A271F26C782840FBE02131E612464087808D356D782840C09A5EBDE51246407A0327367A78284057AE5C14E2124640845DB9837D7828401CDE6234E1124640E992BB197F78284081BD78F5E01246407DA87EEF80782840755776C1E01246407B88A13083782840CF2CAE96E01246401B608B8285782840343AD67BE01246400E36D0D787782840BDC1BC6CE012464096F9FD518A782840BDC1BC6CE012464076C075C58C7828401CF80780E01246403BB31314F5782840540C46DBE71246404E524FD5F378284089BDAB79E91246406716574BF078284086D91544EE1246404AB8EB00E378284040457AF601134640AB28B91EE078284097361C960613464029DA0BBBDE782840AE2AFBAE08134640B24D85D3DD78284043A21A4009134640EF0F4A4EDC782840962AACAF09134640A236BBFFD9782840AEC89EF309134640686CF992D7782840EFB72C150A1346408835F0FED37828409CB9D1110A1346407381CB63CD782840720C12EC09134640695DFE9EB3782840FBDBAF4C091346407ADC5CA1B47828400EF1B4A1071346402224C10AA678284008628F3F07134640E589D640A9782840B7FF120203134640AE84494CAB782840A686EC7200134640CFD2BAB2B07828402937F69100134640E67EE25BB378284078E0AD3DFD124640AAF9E06BBE78284091538550EF124640B91798158A782840398485EEED12464055E2957F88782840EA6A3C22F01246407F958D1887782840F5262B2BF21246409F16CD1484782840351EB63EF612464000CF51A2807828401ACA3FE9FA12464074FE37407A782840E6C52EF603134640	Cesena
1199	McDonald's	3	Cucina: burger | Takeaway	0101000020E6100000FD9D9218A9902840AB1B391CA7154640	Cesena
1200	Piadineria	3	Cucina: italian	0101000020E61000001C7BF65CA68A284041C28B193C124640	Cesena
1201	La Piadina di Stefano e Mascia	3	Cucina: regional	0101000020E6100000135BE619A07D284068DD5042FA114640	Cesena
1202	Istambul Kebab	3	Cucina: kebab	0101000020E61000006F29E78BBD7728403AB8CF85EC114640	Cesena
1203	Istituto tecnico statale per geometri Leonardo Da Vinci	5	Tipo ufficio: educational_institution	0101000020E6100000729BBA3CE7802840D19C50E339124640	Cesena
1204	Istituto tecnico statale per geometri Leonardo Da Vinci	5	Tipo ufficio: educational_institution	0101000020E6100000729BBA3CE7802840D19C50E339124640	Cesena
1205	Shell	9	Operatore: Zignani Lino Piero S.R.L.	0101000020E6100000C381902C605A2840EDD3F19881064640	Cesena
1206	Metano	9	Operatore: Metanauto Del Savio di Niso Avio & Mordenti Benito S.N.C.	0101000020E6100000EDF0D7648D8E284006F357C85C154640	Cesena
1207	Tamoil	9	Operatore: Calisesi & Biondi S.R.L.	0101000020E610000057E9EE3A1B922840C83F33880F164640	Cesena
1208	Api	9	Operatore: S.C.E.L.F. S.R.L.	0101000020E610000059C16F438C9728400475CAA31B174640	Cesena
1209	Agip	9	Operatore: Paganelli Nerio	0101000020E6100000E8A38CB8009C284054C8957A16184640	Cesena
1210	Esso	9	Operatore: Esso	0101000020E61000001C0934D8D48928404D6551D845114640	Cesena
1211	Agip	9	Operatore: Eni Fuel S.p.A.	0101000020E61000005E7E4C101A862840DA5FD10891114640	Cesena
1212	Atras	9	Operatore: Montalti S.A.S. di Montalti Paolo e Mauro & C.	0101000020E610000016CA784ABD7128405A2327B8FD134640	Cesena
1213	Energia Fluida Cesena	9	Operatore: Sacchetti Massimo	0101000020E6100000DF32A7CB628A28403B3602F1BA104640	Cesena
1214	Tamoil	9	Operatore: Calisesi & Biondi S.R.L.	0101000020E610000024C9BD0A3A6328404419AA622A144640	Cesena
1215	Tamoil	9	Operatore: Calisesi & Biondi S.R.L.	0101000020E6100000211DC30886682840351D4B69470E4640	Cesena
1216	OIL ONE	9	Operatore: Acema S.p.A.	0101000020E61000005471E316F36F28407270445266124640	Cesena
1217	Q8	9	Operatore: Q8	0101000020E61000003D10B45DFC742840EAB8759208124640	Cesena
1219	Eni	9	Operatore: Siboni & Ravaioli S.N.C.	0101000020E610000017ABBCD353762840995C31C802124640	Cesena
1220	Ego	9	Operatore: Maestri S.p.A.	0101000020E6100000E09B4B169C762840A20337F7FC114640	Cesena
1221	Agip	9	Operatore: R.T.M. di Romualdi Roberto e C. S.A.S.	0101000020E6100000B8CEBF5DF68B28400ABC934F8F154640	Cesena
1222	Agip	9	Operatore: F.lli Monti S.N.C. di Monti Loreno e Iuri	0101000020E6100000A0DD21C500712840C1470E2263164640	Cesena
1223	Tamoil	9	Operatore: Calisesi & Biondi S.R.L.	0101000020E6100000EB121FE91D8C284014364DE9AA104640	Cesena
1224	Tamoil	9	Operatore: Calisesi & Biondi S.R.L.	0101000020E6100000F6AB4A6C888F2840DDB98B8BFE114640	Cesena
1225	Conad	9	Operatore: Laema S.R.L.	0101000020E6100000B31314F538862840080C48B192124640	Cesena
1226	Indipendent	9	Operatore: Metanauto Del Savio di Niso Avio & Mordenti Benito S.N.C.	0101000020E6100000F5FF60962C7128402D0ABB287A144640	Cesena
1227	TotalErg	9	Operatore: Zignani Lino Piero S.R.L.	0101000020E610000048838021505E2840DF6DDE3829084640	Cesena
1228	Tamoil	9	Operatore: Calisesi & Biondi S.R.L.	0101000020E6100000D42B6519E2682840286618D23C0E4640	Cesena
1229	Metano	9	Operatore: Metano	0101000020E61000005FECBDF8A2712840B895B95400144640	Cesena
1230	Tamoil	9	Operatore: Calisesi & Biondi S.R.L.	0101000020E61000005A396A3B5C6D284017CAD30330114640	Cesena
1231	Tamoil	9	Operatore: Calisesi & Biondi S.R.L.	0101000020E6100000DCA96F4F466F28400679E2DEA1114640	Cesena
1232	Tamoil	9	Operatore: Calisesi & Biondi S.R.L.	0101000020E6100000962D48E9886A2840A796ADF5450F4640	Cesena
1233	Q8	9	Operatore: Stazione di Servizio S.N.C. di Bartolini Sesto & C.	0101000020E6100000BFB3E2C0507C2840F7F9394F86104640	Cesena
1234	Agip	9	Operatore: Gozi Carmen Snc e C.	0101000020E6100000BDF1FFF4B06D2840DAFF006BD5104640	Cesena
1235	EnerCoop	9	Operatore: Carburanti 3.0 S.R.L.	0101000020E61000003386DE8728732840746781D140164640	Cesena
1236	Atras	9	Operatore: Montalti S.A.S. di Montalti Paolo e Mauro & C.	0101000020E6100000232D95B7237428400A80F10C1A164640	Cesena
1237	eni	9	Operatore: Gestioni Innovative Italia S.R.L.	0101000020E61000003864A82FF08D284098DA520779114640	Cesena
1238	Biblioteca Malatestiana	1	Biblioteca Malatestiana	0101000020E6100000D09CF529C77C284012369776C5114640	Cesena
1239	Cesena	8	Operatore: Rete Ferroviaria Italiana | Accessibile in sedia a rotelle	0101000020E61000003B1C5DA5BB7F2840697F564F9C124640	Cesena
1240	Nuova Aula Paperino	1	Aula studio aperta h24 con prese di corrente e distributori automatici.	0101000020E6100000713D0AD7A3B02640736891ED7C3F4640	Bologna
1241	TestingPoint	2	Testing di aggiunta da interfaccia	0101000020E6100000F6285C8FC275264014AE47E17A344640	Forlì
\.


--
-- Data for Name: preferenza_utente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.preferenza_utente (id_utente, id_categoria) FROM stdin;
1	1
1	2
2	3
2	7
4	1
4	5
7	5
3	4
10	9
1	3
10	1
10	2
10	3
10	6
10	5
10	4
10	7
10	8
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: utente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utente (id, nome, cognome, campus, mezzo_di_spostamento, password) FROM stdin;
2	Giulia	Bianchi	Cesena	BICI A NOLEGGIO	123
3	Alessandro	Verdi	Bologna	AUTOBUS	123
4	Elena	Neri	Forlì	AUTO	123
6	Valerio	Velino	Bologna	A PIEDI	123
7	Giacomo	Lanese	Cesena	BICI A NOLEGGIO	123
8	admin	amdmin	\N	AUTO	a1
11	a	b	Bologna	A PIEDI	c
1	Mario	Rossi	Bologna	AUTOBUS	123
10	Nicola	Tinari	Bologna	AUTO	n1
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: agenda_utente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agenda_utente_id_seq', 63, true);


--
-- Name: categoria_poi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_poi_id_seq', 9, true);


--
-- Name: evento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.evento_id_seq', 211, true);


--
-- Name: orario_poi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orario_poi_id_seq', 1241, true);


--
-- Name: poi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.poi_id_seq', 1242, true);


--
-- Name: utente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utente_id_seq', 11, true);


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: postgres
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- Name: agenda_utente agenda_utente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda_utente
    ADD CONSTRAINT agenda_utente_pkey PRIMARY KEY (id);


--
-- Name: categoria_poi categoria_poi_nome_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_poi
    ADD CONSTRAINT categoria_poi_nome_key UNIQUE (nome);


--
-- Name: categoria_poi categoria_poi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_poi
    ADD CONSTRAINT categoria_poi_pkey PRIMARY KEY (id);


--
-- Name: evento evento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento
    ADD CONSTRAINT evento_pkey PRIMARY KEY (id);


--
-- Name: orario_poi orario_poi_id_poi_giorno_orario_apertura_orario_chiusura_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orario_poi
    ADD CONSTRAINT orario_poi_id_poi_giorno_orario_apertura_orario_chiusura_key UNIQUE (id_poi, giorno, orario_apertura, orario_chiusura);


--
-- Name: orario_poi orario_poi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orario_poi
    ADD CONSTRAINT orario_poi_pkey PRIMARY KEY (id);


--
-- Name: poi poi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poi
    ADD CONSTRAINT poi_pkey PRIMARY KEY (id);


--
-- Name: preferenza_utente preferenza_utente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preferenza_utente
    ADD CONSTRAINT preferenza_utente_pkey PRIMARY KEY (id_utente, id_categoria);


--
-- Name: utente uq_utente_nome_cognome_password; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utente
    ADD CONSTRAINT uq_utente_nome_cognome_password UNIQUE (nome, cognome, password);


--
-- Name: utente utente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utente
    ADD CONSTRAINT utente_pkey PRIMARY KEY (id);


--
-- Name: agenda_utente agenda_utente_id_poi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda_utente
    ADD CONSTRAINT agenda_utente_id_poi_fkey FOREIGN KEY (id_poi) REFERENCES public.poi(id) ON DELETE CASCADE;


--
-- Name: agenda_utente agenda_utente_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda_utente
    ADD CONSTRAINT agenda_utente_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utente(id) ON DELETE CASCADE;


--
-- Name: evento evento_id_poi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento
    ADD CONSTRAINT evento_id_poi_fkey FOREIGN KEY (id_poi) REFERENCES public.poi(id) ON DELETE SET NULL;


--
-- Name: evento evento_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento
    ADD CONSTRAINT evento_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utente(id) ON DELETE CASCADE;


--
-- Name: orario_poi orario_poi_id_poi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orario_poi
    ADD CONSTRAINT orario_poi_id_poi_fkey FOREIGN KEY (id_poi) REFERENCES public.poi(id) ON DELETE CASCADE;


--
-- Name: poi poi_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poi
    ADD CONSTRAINT poi_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria_poi(id) ON DELETE RESTRICT;


--
-- Name: preferenza_utente preferenza_utente_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preferenza_utente
    ADD CONSTRAINT preferenza_utente_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria_poi(id) ON DELETE CASCADE;


--
-- Name: preferenza_utente preferenza_utente_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preferenza_utente
    ADD CONSTRAINT preferenza_utente_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utente(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--