--
-- PostgreSQL database dump
--

\restrict QP2RhDUXFCThe63x1gi4w4E7B97gekKJewZKonKNUdHUueCsqTISyGMOgL90vP6

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

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
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: book_appointment(integer, integer, integer, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: bani
--

CREATE FUNCTION public.book_appointment(p_customer_id integer, p_service_id integer, p_stylist_id integer, p_start_time timestamp without time zone) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_duration INT;
  v_end_time TIMESTAMP;
BEGIN
  SELECT duration_minutes
  INTO v_duration
  FROM services
  WHERE service_id = p_service_id;

  IF v_duration IS NULL THEN
    RAISE EXCEPTION 'Service tidak valid';
  END IF;

  v_end_time := p_start_time
                + (v_duration || ' minutes')::INTERVAL;

  IF p_start_time::time < TIME '09:00'
     OR v_end_time::time > TIME '17:00' THEN
    RAISE EXCEPTION
      'Booking hanya tersedia antara jam 09:00 sampai 17:00';
  END IF;

  INSERT INTO appointments (
    customer_id, service_id, stylist_id,
    start_time, end_time
  )
  VALUES (
    p_customer_id, p_service_id, p_stylist_id,
    p_start_time, v_end_time
  );

  RETURN 1;
END;
$$;


ALTER FUNCTION public.book_appointment(p_customer_id integer, p_service_id integer, p_stylist_id integer, p_start_time timestamp without time zone) OWNER TO bani;

--
-- Name: get_available_slots(integer, integer, date); Type: FUNCTION; Schema: public; Owner: bani
--

CREATE FUNCTION public.get_available_slots(p_service_id integer, p_stylist_id integer, p_date date) RETURNS TABLE(start_time timestamp without time zone)
    LANGUAGE sql
    AS $$
WITH service_duration AS (
  SELECT duration_minutes
  FROM services
  WHERE service_id = p_service_id
),
slots AS (
  SELECT
    generate_series(
      p_date + TIME '09:00',
      p_date + TIME '17:00',
      INTERVAL '30 minutes'
    ) AS slot_start
),
valid_slots AS (
  SELECT
    slot_start,
    slot_start
      + (sd.duration_minutes || ' minutes')::INTERVAL AS slot_end
  FROM slots
  CROSS JOIN service_duration sd
  WHERE
    slot_start::time >= TIME '09:00'
    AND (slot_start
      + (sd.duration_minutes || ' minutes')::INTERVAL)::time <= TIME '17:00'
)
SELECT vs.slot_start
FROM valid_slots vs
WHERE NOT EXISTS (
  SELECT 1
  FROM appointments a
  WHERE a.stylist_id = p_stylist_id
    AND tsrange(a.start_time, a.end_time)
        && tsrange(vs.slot_start, vs.slot_end)
)
ORDER BY vs.slot_start;
$$;


ALTER FUNCTION public.get_available_slots(p_service_id integer, p_stylist_id integer, p_date date) OWNER TO bani;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointments (
    appointment_id integer NOT NULL,
    customer_id integer,
    service_id integer,
    stylist_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL
);


ALTER TABLE public.appointments OWNER TO postgres;

--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.appointments_appointment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.appointments_appointment_id_seq OWNER TO postgres;

--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.appointments_appointment_id_seq OWNED BY public.appointments.appointment_id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    phone character varying(20) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_customer_id_seq OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.services (
    service_id integer NOT NULL,
    name character varying(50) NOT NULL,
    duration_minutes integer NOT NULL
);


ALTER TABLE public.services OWNER TO postgres;

--
-- Name: services_service_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.services_service_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.services_service_id_seq OWNER TO postgres;

--
-- Name: services_service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.services_service_id_seq OWNED BY public.services.service_id;


--
-- Name: stylists; Type: TABLE; Schema: public; Owner: bani
--

CREATE TABLE public.stylists (
    stylist_id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.stylists OWNER TO bani;

--
-- Name: stylists_stylist_id_seq; Type: SEQUENCE; Schema: public; Owner: bani
--

CREATE SEQUENCE public.stylists_stylist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stylists_stylist_id_seq OWNER TO bani;

--
-- Name: stylists_stylist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bani
--

ALTER SEQUENCE public.stylists_stylist_id_seq OWNED BY public.stylists.stylist_id;


--
-- Name: appointments appointment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments ALTER COLUMN appointment_id SET DEFAULT nextval('public.appointments_appointment_id_seq'::regclass);


--
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- Name: services service_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services ALTER COLUMN service_id SET DEFAULT nextval('public.services_service_id_seq'::regclass);


--
-- Name: stylists stylist_id; Type: DEFAULT; Schema: public; Owner: bani
--

ALTER TABLE ONLY public.stylists ALTER COLUMN stylist_id SET DEFAULT nextval('public.stylists_stylist_id_seq'::regclass);


--
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.appointments (appointment_id, customer_id, service_id, stylist_id, start_time, end_time) FROM stdin;
5	5	2	6	2025-12-20 10:00:00	2025-12-20 10:30:00
6	6	3	6	2025-12-20 13:00:00	2025-12-20 14:30:00
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (customer_id, phone, name) FROM stdin;
5	0811111111	Andi
6	0822222222	Budi
7	0833333333	Citra
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (service_id, name, duration_minutes) FROM stdin;
2	Haircut	30
3	Hair Coloring	90
4	Hair Wash	20
5	Hair Treatment	60
\.


--
-- Data for Name: stylists; Type: TABLE DATA; Schema: public; Owner: bani
--

COPY public.stylists (stylist_id, name) FROM stdin;
6	Rina
7	Dewi
8	Sari
\.


--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.appointments_appointment_id_seq', 7, true);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_customer_id_seq', 7, true);


--
-- Name: services_service_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.services_service_id_seq', 5, true);


--
-- Name: stylists_stylist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bani
--

SELECT pg_catalog.setval('public.stylists_stylist_id_seq', 8, true);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (appointment_id);


--
-- Name: customers customers_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_phone_key UNIQUE (phone);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: appointments no_overlapping_appointments; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT no_overlapping_appointments EXCLUDE USING gist (stylist_id WITH =, tsrange(start_time, end_time) WITH &&);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (service_id);


--
-- Name: stylists stylists_pkey; Type: CONSTRAINT; Schema: public; Owner: bani
--

ALTER TABLE ONLY public.stylists
    ADD CONSTRAINT stylists_pkey PRIMARY KEY (stylist_id);


--
-- Name: appointments appointments_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: appointments appointments_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id);


--
-- Name: appointments fk_stylist; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_stylist FOREIGN KEY (stylist_id) REFERENCES public.stylists(stylist_id);


--
-- PostgreSQL database dump complete
--

\unrestrict QP2RhDUXFCThe63x1gi4w4E7B97gekKJewZKonKNUdHUueCsqTISyGMOgL90vP6

