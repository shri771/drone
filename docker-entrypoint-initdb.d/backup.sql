INSERT INTO users (email, hashed_password, name) VALUES ('dummy@example.com', '$2a$10$DDA63k/8/R.I.2.Y5.Y.e.j4JzL6.d.w.q.e.g.i.y.a.p.e.n.d.a', 'Dummy User');
--
-- PostgreSQL database dump
--

\restrict IhvrUexkeiDScVKBFhKOyVzfDW90NAyylj6HnoxxglgoC4J1s6dJXw23XqeBtxt

-- Dumped from database version 13.22 (Debian 13.22-1.pgdg13+1)
-- Dumped by pg_dump version 13.22 (Debian 13.22-1.pgdg13+1)

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
-- Name: activity_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.activity_type AS ENUM (
    'upload',
    'delete',
    'restore',
    'share',
    'unshare',
    'rename',
    'move',
    'comment',
    'download',
    'star',
    'unstar'
);


ALTER TYPE public.activity_type OWNER TO postgres;

--
-- Name: file_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.file_status AS ENUM (
    'active',
    'trashed',
    'deleted'
);


ALTER TYPE public.file_status OWNER TO postgres;

--
-- Name: item_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.item_type AS ENUM (
    'file',
    'folder'
);


ALTER TYPE public.item_type OWNER TO postgres;

--
-- Name: permission_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.permission_role AS ENUM (
    'viewer',
    'commenter',
    'editor',
    'owner'
);


ALTER TYPE public.permission_role OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    file_id uuid,
    activity_type public.activity_type NOT NULL,
    details jsonb,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.activity_log OWNER TO postgres;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    file_id uuid NOT NULL,
    user_id uuid NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: file_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.file_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    file_id uuid NOT NULL,
    version_number integer NOT NULL,
    storage_path text NOT NULL,
    size bigint NOT NULL,
    uploaded_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.file_versions OWNER TO postgres;

--
-- Name: files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.files (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(500) NOT NULL,
    original_name character varying(500) NOT NULL,
    mime_type character varying(100) NOT NULL,
    size bigint NOT NULL,
    storage_path text NOT NULL,
    owner_id uuid NOT NULL,
    parent_folder_id uuid,
    status public.file_status DEFAULT 'active'::public.file_status,
    is_starred boolean DEFAULT false,
    thumbnail_path text,
    preview_available boolean DEFAULT false,
    version integer DEFAULT 1,
    current_version_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    trashed_at timestamp without time zone,
    last_accessed_at timestamp without time zone
);


ALTER TABLE public.files OWNER TO postgres;

--
-- Name: folders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.folders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(500) NOT NULL,
    owner_id uuid NOT NULL,
    parent_folder_id uuid,
    is_root boolean DEFAULT false,
    status public.file_status DEFAULT 'active'::public.file_status,
    is_starred boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    trashed_at timestamp without time zone
);


ALTER TABLE public.folders OWNER TO postgres;

--
-- Name: goose_db_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.goose_db_version (
    id integer NOT NULL,
    version_id bigint NOT NULL,
    is_applied boolean NOT NULL,
    tstamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.goose_db_version OWNER TO postgres;

--
-- Name: goose_db_version_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.goose_db_version ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.goose_db_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    item_type public.item_type NOT NULL,
    item_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role public.permission_role NOT NULL,
    granted_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: shares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shares (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    item_type public.item_type NOT NULL,
    item_id uuid NOT NULL,
    token text NOT NULL,
    created_by uuid NOT NULL,
    permission public.permission_role DEFAULT 'viewer'::public.permission_role,
    expires_at timestamp without time zone,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shares OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password text NOT NULL,
    name character varying(255) NOT NULL,
    storage_used bigint DEFAULT 0,
    storage_limit bigint DEFAULT '16106127360'::bigint,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: activity_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_log (id, user_id, file_id, activity_type, details, created_at) FROM stdin;
2fd2f0c9-2377-4031-a6c5-60f740ea7725	78c793b5-a705-403a-bec3-2cd04a654bb3	5b952786-4f3d-4bc7-9acd-38f5760b000f	upload	\N	2025-11-03 04:41:12.415986
be1d1bb0-91cd-4a42-bf13-db19fc2146e7	78c793b5-a705-403a-bec3-2cd04a654bb3	4044f7c8-b4bc-44d1-9d0d-435ae04770ca	upload	\N	2025-11-03 04:41:14.591366
d8edd007-b658-4609-90d5-ad428446df19	78c793b5-a705-403a-bec3-2cd04a654bb3	864d62b3-2ab4-4c91-9d61-665f59ab41f3	upload	\N	2025-11-03 04:41:16.527214
2cce8d37-1329-4308-8840-431b9b5adc35	78c793b5-a705-403a-bec3-2cd04a654bb3	cdbab8dc-4edc-4808-a7f1-2d396b4b72f2	upload	\N	2025-11-03 04:41:18.748299
ebe235b1-41dc-4a9a-a0fc-19b18e0dcea6	78c793b5-a705-403a-bec3-2cd04a654bb3	9dd7a41d-86d3-4f7c-a68e-47a715463aa7	upload	\N	2025-11-03 04:41:27.190933
86885a6c-6bf4-436f-abec-97778cf5ec80	78c793b5-a705-403a-bec3-2cd04a654bb3	4db10556-cb7c-47d7-a882-1ae057aa6ecf	upload	\N	2025-11-03 04:41:38.314613
f7ed7c1a-e88a-4f9c-a246-021724ed494e	78c793b5-a705-403a-bec3-2cd04a654bb3	caa920b0-093d-4a2f-9814-2bf153e83ca5	upload	\N	2025-11-03 04:42:11.08114
4dfa0523-8593-4570-8de1-66d9d69c6241	78c793b5-a705-403a-bec3-2cd04a654bb3	03934a3d-9584-4c8a-9e9b-7d4adcf19004	upload	\N	2025-11-03 04:42:12.52737
bcd1906a-c9bc-4c0b-b6b1-6c71efd75e78	78c793b5-a705-403a-bec3-2cd04a654bb3	a368c2e7-0bc8-4a38-bd7a-9788ec8f67b2	upload	\N	2025-11-03 04:42:14.402019
ab59f126-3233-46d0-a93e-aa70a2043e0f	78c793b5-a705-403a-bec3-2cd04a654bb3	9dd6f107-7f42-4075-8681-e001404284ce	upload	\N	2025-11-03 04:42:14.427532
dbfbc5cb-08c3-4dbd-8b9f-772fbd2b3b71	78c793b5-a705-403a-bec3-2cd04a654bb3	8ca9195e-68fc-4888-879e-7cb33a194ee3	upload	\N	2025-11-03 04:42:14.453585
0181d384-70aa-4c08-a9d4-79a2973a75cf	78c793b5-a705-403a-bec3-2cd04a654bb3	197222bb-b87b-4987-8c7c-98b6ba547c5a	upload	\N	2025-11-03 04:42:14.478493
2edf5d13-eb4c-4bc2-9787-11dff6843b35	78c793b5-a705-403a-bec3-2cd04a654bb3	8bfd1edb-64ce-4c12-b0e6-c0a5a2dada07	upload	\N	2025-11-03 04:42:14.503114
1a1b1b20-73c6-4778-8ad0-9dbf53669207	78c793b5-a705-403a-bec3-2cd04a654bb3	3ac5db9c-905b-4a04-af55-5b5a893c14a9	upload	\N	2025-11-03 04:42:14.526337
3432c142-7ff9-4021-8975-326ef7c32c13	78c793b5-a705-403a-bec3-2cd04a654bb3	a5407038-d0ac-4a58-9c75-b6f21449eef9	upload	\N	2025-11-03 04:42:14.553435
53425f79-efd2-49bc-9f6d-5611501b8ba7	78c793b5-a705-403a-bec3-2cd04a654bb3	95d978e9-7224-42bf-8553-77be0f39067e	upload	\N	2025-11-03 04:42:14.576182
a86fb623-43b5-46b2-930b-486ddb0cee78	78c793b5-a705-403a-bec3-2cd04a654bb3	d5c70f6f-50f6-4fd5-ae76-38aa50f6e760	upload	\N	2025-11-03 04:42:14.599625
d7f16869-980a-47ae-86ce-165e481f17f8	78c793b5-a705-403a-bec3-2cd04a654bb3	73028d7b-4ada-4d8b-8c66-2f11b7eaa1b0	upload	\N	2025-11-03 04:42:14.622197
35a5640e-c469-462f-83cc-7b678b1f9825	78c793b5-a705-403a-bec3-2cd04a654bb3	62a4e761-71eb-459f-b648-ccc7dbf1dd5f	upload	\N	2025-11-03 04:42:14.648507
d4acbbe5-868e-488c-b9d5-807386180e43	78c793b5-a705-403a-bec3-2cd04a654bb3	80c1c7fa-0f9f-4c16-80dc-21494109399b	upload	\N	2025-11-03 04:42:14.669446
b2189f1f-71be-45a9-a9ca-0d305bdf61e3	78c793b5-a705-403a-bec3-2cd04a654bb3	322d1d7c-d133-4ad7-9d3c-0b999a55a9b7	upload	\N	2025-11-03 04:42:14.87564
29e45670-6d79-424f-8e9b-6e495869dfd2	78c793b5-a705-403a-bec3-2cd04a654bb3	ffbb2f7d-af9d-4805-b7a5-48c612a424b9	upload	\N	2025-11-03 04:42:14.896593
7d1cf661-df7a-42a6-b8cc-58a7054f6037	78c793b5-a705-403a-bec3-2cd04a654bb3	f1c2f140-3d4d-417f-a305-fdc7ecf5e362	upload	\N	2025-11-03 04:42:14.917666
83fd87aa-e1ef-4c79-acf9-eb7493000bd2	78c793b5-a705-403a-bec3-2cd04a654bb3	f84b5b70-e189-4866-ad91-6f92e367613a	upload	\N	2025-11-03 04:42:14.941944
b8580a8c-1869-4f38-92eb-890d7228cc18	78c793b5-a705-403a-bec3-2cd04a654bb3	b097a6d5-555f-41ab-b06f-946ef53eea2a	upload	\N	2025-11-03 04:42:14.966501
87a17998-6c52-471b-8be1-8c31d9be9b56	78c793b5-a705-403a-bec3-2cd04a654bb3	820da44d-dde1-4221-9ac5-453880ae84ad	upload	\N	2025-11-03 04:42:14.992005
402562a0-b6c2-404a-a0aa-79875136dfb5	78c793b5-a705-403a-bec3-2cd04a654bb3	ae7bd493-5033-4c29-8675-9322980fd9c7	upload	\N	2025-11-03 04:42:15.015517
e32627f2-9f76-4ad8-8f64-a6c1854fb32e	78c793b5-a705-403a-bec3-2cd04a654bb3	42518f10-7bfa-4613-b2df-fc4e01981464	upload	\N	2025-11-03 04:42:15.039202
2b0972b7-8621-416a-ac15-ad4148403a81	78c793b5-a705-403a-bec3-2cd04a654bb3	23e19e3f-48ee-4950-9e01-5c0f87ad1e65	upload	\N	2025-11-03 04:42:15.06569
4796ba37-0c5c-444a-a369-452a74aa1e25	78c793b5-a705-403a-bec3-2cd04a654bb3	58066a94-c3af-425f-9aba-aaca060dae27	upload	\N	2025-11-03 04:42:15.086762
4cac13d0-6643-4f8a-bb6e-8d9e737b8365	78c793b5-a705-403a-bec3-2cd04a654bb3	30a3159a-17c5-409e-a433-0b5ee479ecfc	upload	\N	2025-11-03 04:42:15.110668
d344f48c-f701-42ab-91b1-fbe8ccd51b73	78c793b5-a705-403a-bec3-2cd04a654bb3	9557840c-871e-47e0-886c-f2b98dbc4eef	upload	\N	2025-11-03 04:42:15.138621
558cb29b-4451-4532-855e-cf7e09745d3e	78c793b5-a705-403a-bec3-2cd04a654bb3	f6d27409-6eae-4426-8988-158d993adc7b	upload	\N	2025-11-03 04:42:15.172616
d3bc5eb6-4946-438f-9f6e-c697e8874bc3	78c793b5-a705-403a-bec3-2cd04a654bb3	c19144a3-f2ed-47b8-98e5-23d3edfc0352	upload	\N	2025-11-03 04:42:15.197896
c9326f66-7a37-4aa8-a3c6-b6c39de6da5d	78c793b5-a705-403a-bec3-2cd04a654bb3	e15f5aa8-3c97-4f93-a623-2f037776ad6f	upload	\N	2025-11-03 04:42:15.22262
5de9f351-8f19-4e01-bf2e-9b72eae7d4d2	78c793b5-a705-403a-bec3-2cd04a654bb3	bc8324a7-7d90-4330-9fc2-d5161991d940	upload	\N	2025-11-03 04:42:15.245871
d32c5e92-266d-4ed2-97fb-40b7e508de5d	78c793b5-a705-403a-bec3-2cd04a654bb3	d03aee5b-d503-4269-a7a6-afcc3151a37a	upload	\N	2025-11-03 04:42:15.269262
f98ae9b5-c35a-4075-b64a-02097e70bdb2	78c793b5-a705-403a-bec3-2cd04a654bb3	bc70a517-a616-4574-afcf-ea9a2559a0c6	upload	\N	2025-11-03 04:42:15.292687
e2235607-2a0a-43dd-837e-7660f2811fb5	78c793b5-a705-403a-bec3-2cd04a654bb3	7de489bf-4c58-4139-b2cc-76dca4c70695	upload	\N	2025-11-03 04:42:15.314846
749e8471-de2d-49b2-9077-0c848c078462	78c793b5-a705-403a-bec3-2cd04a654bb3	4f6d103f-ca59-4c08-9c28-d75d04ec35ab	upload	\N	2025-11-03 04:42:15.34026
afb053bc-197b-4ec3-bf68-8301b23746ae	78c793b5-a705-403a-bec3-2cd04a654bb3	0c18f64b-c38a-4abc-9d4f-e7b18256d862	upload	\N	2025-11-03 04:42:15.365341
94823d07-658f-4dfd-9124-4caf42e88775	78c793b5-a705-403a-bec3-2cd04a654bb3	bcbaaa30-ee37-46c8-909b-4b3d8d424596	upload	\N	2025-11-03 04:42:15.391683
a458a2ba-e008-46c7-8475-982b37d974dc	78c793b5-a705-403a-bec3-2cd04a654bb3	c826bf28-e0f5-4d65-8c72-9814ef03bd36	upload	\N	2025-11-03 04:42:15.416884
112f088e-a010-4855-9c77-52941ae07286	78c793b5-a705-403a-bec3-2cd04a654bb3	d0bc512f-c236-4b80-bfbe-fabf265cfb2a	upload	\N	2025-11-03 04:42:15.441128
5f72fc89-368f-48ee-a981-f876f839d775	78c793b5-a705-403a-bec3-2cd04a654bb3	2873b52a-fb90-425d-9053-ef2c61117c07	upload	\N	2025-11-03 04:42:15.465222
73d7f086-9de1-46fa-bd18-e6e19686790d	78c793b5-a705-403a-bec3-2cd04a654bb3	c10aa07e-6d98-4236-891d-8e6efd244a37	upload	\N	2025-11-03 04:42:15.487726
4737b0d1-fa4f-4b63-9622-5989e636a5e2	78c793b5-a705-403a-bec3-2cd04a654bb3	715f5977-175b-42a1-8e08-680c7de9bd9d	upload	\N	2025-11-03 04:42:15.510417
10555437-0669-4d00-b862-6bc37c835544	78c793b5-a705-403a-bec3-2cd04a654bb3	0b4a9a62-e46e-4892-8cdd-bbc755824334	upload	\N	2025-11-03 04:42:15.535784
0442f299-c467-4657-be82-35c23de7bc9c	78c793b5-a705-403a-bec3-2cd04a654bb3	010fe3c2-c771-4324-bd82-9b72ea5295b3	upload	\N	2025-11-03 04:42:15.559784
1b21b98d-f044-4d44-94f5-1895360c15f8	78c793b5-a705-403a-bec3-2cd04a654bb3	c2c4958e-8c27-4add-9da5-aac61a6dc55c	upload	\N	2025-11-03 04:42:15.584262
a592c8dc-81d8-4fc3-a721-9fa92111ee62	78c793b5-a705-403a-bec3-2cd04a654bb3	edf2cd87-97fa-4c6e-bb83-e86ddd7f7325	upload	\N	2025-11-03 04:42:15.60665
c4b373a7-8de6-4630-b69d-e66c2ce85770	78c793b5-a705-403a-bec3-2cd04a654bb3	d7d7ead7-a814-413d-8d6f-b82108dc9e18	upload	\N	2025-11-03 04:42:15.628041
8e75e255-8adf-481f-bc06-81f317c82922	78c793b5-a705-403a-bec3-2cd04a654bb3	a5af63e5-59fb-4a34-b1e3-607db403252f	upload	\N	2025-11-03 04:42:15.652217
aa362430-100b-4b06-8809-e1c6ea29d659	78c793b5-a705-403a-bec3-2cd04a654bb3	04885337-41ca-460e-8651-f5533026f66c	upload	\N	2025-11-03 04:42:15.672487
62cbae27-91b7-44aa-ac6b-1e116bf7df26	78c793b5-a705-403a-bec3-2cd04a654bb3	f51f6aa4-2884-41e4-8c27-8409e18c8c68	upload	\N	2025-11-03 04:42:15.693533
0eae53fa-c97c-42a9-a46c-eef36f18fec1	78c793b5-a705-403a-bec3-2cd04a654bb3	dc30e883-d39f-436a-a90e-63592950d4b2	upload	\N	2025-11-03 04:42:15.714532
ee572781-a525-46e2-9970-c84f65453730	78c793b5-a705-403a-bec3-2cd04a654bb3	15fd71a0-8fee-454e-9b97-c13a5d515433	upload	\N	2025-11-03 04:42:15.73589
8a37540b-3ae8-4a11-ab0a-34307e996f2f	78c793b5-a705-403a-bec3-2cd04a654bb3	fb8a226f-f9ed-4768-b90d-41cfc2eb9179	upload	\N	2025-11-03 04:42:15.759301
3ea6b9ff-3dd6-43cc-8354-bcb70fc47f67	78c793b5-a705-403a-bec3-2cd04a654bb3	1b437c3b-e890-44ec-b644-cbf8de34859f	upload	\N	2025-11-03 04:42:15.781659
23098407-95d7-4c0e-a93a-303782d37a0e	78c793b5-a705-403a-bec3-2cd04a654bb3	042a43e4-e025-490f-95bf-2b530af4f155	upload	\N	2025-11-03 04:42:15.803855
15a7cb42-3199-4f63-b735-cda1b96d279b	78c793b5-a705-403a-bec3-2cd04a654bb3	2fe6ee61-79ba-4dcd-a14a-fd29826c0d59	upload	\N	2025-11-03 04:42:15.827713
bf962c24-2792-4e96-a897-1624c46b780f	78c793b5-a705-403a-bec3-2cd04a654bb3	f869d0c9-8a1e-4cd0-8cfc-06333dcef82d	upload	\N	2025-11-03 04:42:15.84792
b766be48-64f9-48a8-b1c4-17e0d10a50a6	78c793b5-a705-403a-bec3-2cd04a654bb3	81b03945-6eb5-46f5-915f-9dd15c3af4af	upload	\N	2025-11-03 04:42:15.868977
112f773c-785e-4efc-aa11-1dc36dd2f827	78c793b5-a705-403a-bec3-2cd04a654bb3	f1441617-f061-4dde-9757-f3fff70acef8	upload	\N	2025-11-03 04:42:15.88924
6fda14fa-da36-418c-99d6-e92d6c396657	78c793b5-a705-403a-bec3-2cd04a654bb3	af2c6a37-72c9-488f-96f0-c7ade32b357f	upload	\N	2025-11-03 04:42:15.909115
5dceaf84-a3d3-4654-a2d1-fd9ebf70147e	78c793b5-a705-403a-bec3-2cd04a654bb3	947a0e66-c6fb-4afe-9b60-4c9c76e7ef6f	upload	\N	2025-11-03 04:42:15.928864
4d04d4ec-d082-4ba4-a21a-c2dff55ce75e	78c793b5-a705-403a-bec3-2cd04a654bb3	338822f8-3b04-4ce6-bf7a-1379113eac2a	upload	\N	2025-11-03 04:42:15.95085
3ce91d58-38fd-43b6-8269-31e335f99f49	78c793b5-a705-403a-bec3-2cd04a654bb3	d4239963-b239-4634-8739-a4957efcfb42	upload	\N	2025-11-03 04:42:15.972365
87670d9f-b480-4a04-9826-0407dc0aa68b	78c793b5-a705-403a-bec3-2cd04a654bb3	a6bff225-189a-4c47-8b52-b2baac25bb65	upload	\N	2025-11-03 04:42:15.992693
4a68744d-c25c-4f9b-9454-e66329a9bf54	78c793b5-a705-403a-bec3-2cd04a654bb3	574b5411-1b9b-49b7-bde9-4ef5e3d70815	upload	\N	2025-11-03 04:42:16.012519
86c8fce1-d8df-4a5b-9e9b-0c0d67f74292	78c793b5-a705-403a-bec3-2cd04a654bb3	b370351e-e862-4b25-acb6-a3828e2d7059	upload	\N	2025-11-03 04:42:16.035244
8c8ccce7-d041-4f58-bf64-08c5653d9141	78c793b5-a705-403a-bec3-2cd04a654bb3	33bbad4e-e5dc-4e42-a5bd-cbc6ad494384	upload	\N	2025-11-03 04:42:16.055732
a3682b00-a7db-40b9-bce8-e635dc3c6a2d	78c793b5-a705-403a-bec3-2cd04a654bb3	4885b5d7-0b48-4061-a721-10279d3fbf69	upload	\N	2025-11-03 04:42:16.077255
3743dd3f-4cbe-4888-840a-5598b94e99bd	78c793b5-a705-403a-bec3-2cd04a654bb3	551acd30-e5d3-41d0-a336-a3a5cb8d9121	upload	\N	2025-11-03 04:42:16.098567
fc3abaf4-2d82-4ddf-9508-252b18adf3fc	78c793b5-a705-403a-bec3-2cd04a654bb3	33d19217-f3fa-4a9d-86e8-2cc057525618	upload	\N	2025-11-03 04:42:16.119809
a5c3cf74-cc67-43b7-8ee1-c14bae0a8a82	78c793b5-a705-403a-bec3-2cd04a654bb3	30111653-87c8-4d7a-a129-9f048c3168cf	upload	\N	2025-11-03 04:42:16.141832
c8e60d62-e59a-4dfa-bbba-3d4a3e1fe998	78c793b5-a705-403a-bec3-2cd04a654bb3	cfcfc277-ae47-415e-b85e-4e6720a2a4d8	upload	\N	2025-11-03 04:42:16.162727
7c73318a-976f-450e-a57e-5378445b53c5	78c793b5-a705-403a-bec3-2cd04a654bb3	85176579-f940-4ecc-94b8-26b23a0d94f0	upload	\N	2025-11-03 04:42:16.18349
d59eefbc-2af9-4bfb-a60f-88387610bc41	78c793b5-a705-403a-bec3-2cd04a654bb3	7526efb5-683a-4121-8cf7-3cac1a0c3124	upload	\N	2025-11-03 04:42:16.206785
aab19f61-cb6b-4cbb-8bbd-76b1f8aae3e0	78c793b5-a705-403a-bec3-2cd04a654bb3	39f04fd0-d218-4325-bc62-726c5f72332b	upload	\N	2025-11-03 04:42:16.225284
44d1c0ea-cea4-465a-83c6-a1a4ad99a398	78c793b5-a705-403a-bec3-2cd04a654bb3	6f0ab404-e4cb-48e8-a010-5e45e556a122	upload	\N	2025-11-03 04:42:16.250658
d9f267f4-48b6-4dc5-8266-544eacc8b0a9	78c793b5-a705-403a-bec3-2cd04a654bb3	15a7d5c8-08a1-4ef8-a6bc-d195ded3e477	upload	\N	2025-11-03 04:42:16.273221
59bda02d-3d7e-4652-8a49-8a9aede1d925	78c793b5-a705-403a-bec3-2cd04a654bb3	87612912-2347-435a-be86-be77e1bfdd18	upload	\N	2025-11-03 04:42:16.297121
aeaa3027-31fd-4284-a576-8b1704f53f77	78c793b5-a705-403a-bec3-2cd04a654bb3	b78b8e3d-31f9-4786-842c-6a9a42b88a2f	upload	\N	2025-11-03 04:42:16.319618
dfaedd5e-6f67-4fc7-949a-b0f224f441d2	78c793b5-a705-403a-bec3-2cd04a654bb3	6575da8e-d064-42aa-8779-28cb091644c9	upload	\N	2025-11-03 04:42:16.340831
83afd24c-a9fb-4dd6-ba1a-292181d6a64e	78c793b5-a705-403a-bec3-2cd04a654bb3	a09e64e3-cdde-48a2-b436-7309e8d35525	upload	\N	2025-11-03 04:42:16.365025
31ad15bc-cf13-4b83-8b12-3031d56ec6b5	78c793b5-a705-403a-bec3-2cd04a654bb3	61f50571-7d17-4efb-85fc-d994b52f9e18	upload	\N	2025-11-03 04:42:46.428145
c8270108-e3cc-493f-ba0b-59793d7dedbe	78c793b5-a705-403a-bec3-2cd04a654bb3	3d63e431-b733-406d-a2a7-c1ad5139b2cb	upload	\N	2025-11-03 04:42:58.66844
145e966d-07ee-4bbb-ae0c-ae99555527de	78c793b5-a705-403a-bec3-2cd04a654bb3	2179ed99-bef1-49ad-8ee1-a8f42e8cd8d8	upload	\N	2025-11-03 04:43:04.856707
c4be283e-c2a4-48f7-83d9-7e087bbe32e1	78c793b5-a705-403a-bec3-2cd04a654bb3	85f445e5-a8a9-42d5-8a3a-8e3bb8e2d4c1	upload	\N	2025-11-03 04:43:09.724993
8f6159db-e4fc-487b-8136-658632290e79	78c793b5-a705-403a-bec3-2cd04a654bb3	fe796dd7-b5e8-44c1-a296-25a36055c4a7	upload	\N	2025-11-03 04:43:15.598579
b2769a49-bef3-4eb7-8aa2-db85ff5a2f30	78c793b5-a705-403a-bec3-2cd04a654bb3	5c555b40-3e96-4c1f-ae35-5d6ac5a30985	upload	\N	2025-11-03 04:43:31.715577
cd9a7727-ba94-4f40-aa80-5d840e470d4b	78c793b5-a705-403a-bec3-2cd04a654bb3	5a204d25-4430-4ecc-a41a-26ee160c4a64	upload	\N	2025-11-03 04:43:36.375879
2933ab62-9bcf-47c1-acfd-cdf3e8c63fbe	78c793b5-a705-403a-bec3-2cd04a654bb3	603ca557-7647-4579-ad46-167f31cd83a4	upload	\N	2025-11-03 04:43:41.50877
a0d742b7-4293-4f19-922c-feff84db7b7d	78c793b5-a705-403a-bec3-2cd04a654bb3	b01754da-b54b-406f-bf00-823adc3d6988	upload	\N	2025-11-03 04:43:47.744532
f4d6e7b4-573d-4f20-9897-a04e247c610a	78c793b5-a705-403a-bec3-2cd04a654bb3	2c33ef82-7c4d-4183-a2c5-235d57add03d	upload	\N	2025-11-03 04:43:54.154982
a1c9f4d7-4191-4efe-804d-b1f5ff8fa19f	78c793b5-a705-403a-bec3-2cd04a654bb3	aae3354a-e90c-431d-ba2e-347c26e3e60b	upload	\N	2025-11-03 04:43:57.663293
d5537ba8-055f-421d-9778-ed77eb76692e	78c793b5-a705-403a-bec3-2cd04a654bb3	e060acac-8fdf-478b-b408-3f2b23447883	upload	\N	2025-11-03 04:44:05.868632
48007b44-b723-46f8-89af-ead513d4e80b	78c793b5-a705-403a-bec3-2cd04a654bb3	e060acac-8fdf-478b-b408-3f2b23447883	delete	\N	2025-11-03 04:44:12.762218
4ca6472e-6420-42b8-beeb-6313d90a5551	78c793b5-a705-403a-bec3-2cd04a654bb3	603ca557-7647-4579-ad46-167f31cd83a4	delete	\N	2025-11-03 04:44:15.076942
34623011-bcc3-464e-936e-51ba8bf1bdd1	78c793b5-a705-403a-bec3-2cd04a654bb3	1e6995a7-9f4d-4276-a7d1-96d4275d7011	upload	\N	2025-11-03 04:44:34.372475
9ec6ecf9-7c3f-4251-847f-de3942ed2100	78c793b5-a705-403a-bec3-2cd04a654bb3	1e6995a7-9f4d-4276-a7d1-96d4275d7011	delete	\N	2025-11-03 04:44:40.776997
49f0f1b7-7278-42fd-9459-e840878a8e00	78c793b5-a705-403a-bec3-2cd04a654bb3	7a29d2a3-4abb-47ba-a074-33dd191c7bb8	upload	\N	2025-11-03 04:44:42.920798
6f6f2816-bc87-4e08-9c54-bb3b12b05ba7	78c793b5-a705-403a-bec3-2cd04a654bb3	af2c523a-01e6-45df-a7b7-79a85d7d65a4	upload	\N	2025-11-03 04:44:48.747651
dfb6ce58-8d3f-4d3a-9576-42fe26eafdb4	78c793b5-a705-403a-bec3-2cd04a654bb3	144cb4bc-5228-4d95-af0a-69b28fc2503c	upload	\N	2025-11-03 04:44:59.929604
e386d585-8618-41c5-a523-e0a9062966c0	78c793b5-a705-403a-bec3-2cd04a654bb3	b31ca8ec-1952-4ab6-bc1d-9448d9f0fd24	upload	\N	2025-11-03 04:45:09.666854
289d23f0-aa57-408b-a0f0-51bccff3d4f9	78c793b5-a705-403a-bec3-2cd04a654bb3	5ef67e06-9eeb-4c22-a712-27a3e1cd7c34	upload	\N	2025-11-03 04:45:29.606807
f722f242-cc89-43a8-8948-a4d829b9913e	78c793b5-a705-403a-bec3-2cd04a654bb3	8c1a933e-dab4-4c83-b81d-30fb912ac1e7	upload	\N	2025-11-03 04:45:31.503834
14909d60-7304-41dd-a842-1308bb448303	78c793b5-a705-403a-bec3-2cd04a654bb3	d4c6301f-b510-4880-9294-331b9ae4e70a	upload	\N	2025-11-03 04:45:35.01474
aaecb15f-493b-46c6-93a6-c5b24c58e5f1	78c793b5-a705-403a-bec3-2cd04a654bb3	67d595db-eaff-4554-a5ad-ad2ac532516d	upload	\N	2025-11-03 04:45:37.782614
7df3ce57-435e-4ae8-904f-1b44000570c7	78c793b5-a705-403a-bec3-2cd04a654bb3	4e090b4c-c8ef-49a3-ac21-9a4338383c4e	upload	\N	2025-11-03 04:45:39.826428
84e77bc6-214e-4503-8345-8e27361784dd	78c793b5-a705-403a-bec3-2cd04a654bb3	253191cd-3da4-4b80-8101-d9eec2c78689	upload	\N	2025-11-03 04:45:43.153735
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (id, file_id, user_id, content, created_at, updated_at, is_deleted) FROM stdin;
\.


--
-- Data for Name: file_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.file_versions (id, file_id, version_number, storage_path, size, uploaded_by, created_at) FROM stdin;
587a9347-2f56-4944-aaff-3a760903cd57	5b952786-4f3d-4bc7-9acd-38f5760b000f	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a3501d44-678f-44b4-9bd6-2f7515f0ec1d/v1_Lag Ja Gale (From _Bhoomi_).mp3	7364274	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:41:12.408638
db486dd8-31b9-4568-91f2-88d78a5feb46	4044f7c8-b4bc-44d1-9d0d-435ae04770ca	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/11f3a7ea-4d63-47c6-bd3e-82dbd7e79ef0/v1_SUBHANALLAH.mp3	8204874	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:41:14.584535
e2f3277e-1eb7-4d87-895d-640e40f1644c	864d62b3-2ab4-4c91-9d61-665f59ab41f3	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/557cc06a-8a56-4c24-8d5e-b67d35cebcfc/v1_Somewhere Only We Know.mp3	7920416	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:41:16.521241
a62e7495-1198-4542-8ad0-e18640084b09	cdbab8dc-4edc-4808-a7f1-2d396b4b72f2	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/323880e1-4a72-48f9-9832-18bf55dfc965/v1_Rishte Naate.mp3	9879142	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:41:18.742549
5341c8cb-4bba-4946-a856-9a9c102aeaa9	9dd7a41d-86d3-4f7c-a68e-47a715463aa7	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/02c1ae7e-c88c-4b2e-a4db-a556bf0b642c/v1_Screenshot from 2024-12-10 18-37-15.png	37623	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:41:27.183958
d069756a-4ed0-4451-92d5-710cddc6df1d	4db10556-cb7c-47d7-a882-1ae057aa6ecf	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/dc8318fd-e3b6-464e-a200-787a7d64a399/v1_Dil Ke Paas (Indian Version by Arijit Singh).mp3	8965286	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:41:38.309993
de28ea12-5ffc-4918-9bdd-b879359329ee	caa920b0-093d-4a2f-9814-2bf153e83ca5	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a8d8424b-336d-4fbb-842a-2f62dce51edb/v1_gtk-master.zip	5717247	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:11.075589
a6f73d71-3c47-4b5b-a88b-e915878974f2	03934a3d-9584-4c8a-9e9b-7d4adcf19004	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/b808e142-e5ce-4c70-a562-c2d78c2c6150/v1_Breeze-gtk.tar	367987	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:12.522609
270a5b74-e69b-4f97-88da-0caaa4fa6085	a368c2e7-0bc8-4a38-bd7a-9788ec8f67b2	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/04ff5dc2-a1e3-4767-9654-fbbccddd1191/v1_LICENSE	35141	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.396535
711ed7fc-fb0c-4730-af75-224863b23415	9dd6f107-7f42-4075-8681-e001404284ce	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7b9b743f-9208-4ba9-ac13-ab18e62465f3/v1_install.sh	3263	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.422093
852f0d0c-043f-4a1a-a3b8-34e603a0072e	8ca9195e-68fc-4888-879e-7cb33a194ee3	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ee2a0747-e726-49c4-8ed1-6ff9134a1517/v1_terminal_box_nw.png	1094	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.448255
6547b059-6c1b-4465-a865-d14d6210da1a	197222bb-b87b-4987-8c7c-98b6ba547c5a	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/53c6dc6b-cca7-48a0-9202-73a42b3c9600/v1_dejavu_sans_16.pf2	203880	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.47386
1388e1b1-b1d9-4666-af7c-bfc38444d449	8bfd1edb-64ce-4c12-b0e6-c0a5a2dada07	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/48650491-60ba-4145-99e9-759a532f5215/v1_select_c.png	181	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.498045
f3056f47-0190-4a2e-999c-ac58fef87ec2	3ac5db9c-905b-4a04-af55-5b5a893c14a9	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4244470a-c8f0-44cf-b3dd-d5ef4932202b/v1_terminus-18.pf2	26835	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.521272
92c9be43-9744-4167-a35e-5d11eb37f6df	a5407038-d0ac-4a58-9c75-b6f21449eef9	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ebd04f23-7db1-45db-851e-7016949cf3ee/v1_select_w.png	280	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.548127
bb94ab12-9a93-4146-9e61-2176455df3ab	95d978e9-7224-42bf-8553-77be0f39067e	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/9becb7cc-a4d2-499e-babf-9c5ecd98365d/v1_terminal_box_w.png	952	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.57154
ce85d5c4-850e-430d-96aa-1153715d5014	d5c70f6f-50f6-4fd5-ae76-38aa50f6e760	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/f359ce6f-9298-476c-b5ac-6dccf11a638a/v1_terminal_box_s.png	963	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.594282
76e3a89e-d306-4173-9981-eeef3dc1475a	73028d7b-4ada-4d8b-8c66-2f11b7eaa1b0	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/83a70701-f071-433e-acb7-cbc8fe320eb4/v1_dejavu_sans_14.pf2	185427	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.616717
25ba0cbe-cae9-4d51-8b5e-04e5e0ae23e5	62a4e761-71eb-459f-b648-ccc7dbf1dd5f	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/594c1386-965a-49b6-97ed-dce4340f7ea8/v1_dejavu_sans_48.pf2	868265	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.644132
b2beadd0-67a5-4503-be64-a26074903543	80c1c7fa-0f9f-4c16-80dc-21494109399b	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/143863bf-5d49-470f-9dc5-eba197cf2579/v1_terminus-14.pf2	23941	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.664645
57fbdfe8-ac69-47fe-8abb-1805b5fa2db6	322d1d7c-d133-4ad7-9d3c-0b999a55a9b7	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/013e6a1e-16fc-4753-8856-a83aa8fa9c77/v1_background.jpg	634281	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.870471
681cfd5a-34a0-43a7-8439-30187538e647	ffbb2f7d-af9d-4805-b7a5-48c612a424b9	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/8ba85e2f-9b3d-4ce2-85ae-bc473726e070/v1_terminal_box_ne.png	1115	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.892411
c76f9a46-6c67-4ef6-acef-82a7fbc0d002	f1c2f140-3d4d-417f-a305-fdc7ecf5e362	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/3890e92b-3933-46f6-89ec-7e5ddcd077ed/v1_terminus-12.pf2	21895	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.913411
9f5a33bc-f7ec-4506-874d-7e0f4113c05c	f84b5b70-e189-4866-ad91-6f92e367613a	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/478e995d-5381-4a8f-8f1b-bbbb862b5b8d/v1_dejavu_32.pf2	452923	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.936886
c1cde57e-9ba7-4abf-982e-2cd2567ec0d2	b097a6d5-555f-41ab-b06f-946ef53eea2a	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/cdef7325-d7b5-44c9-bfe3-f1c287f7989f/v1_dejavu_sans_12.pf2	168761	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.961086
92b836c5-cd8e-4d87-af07-b5012df7b7a8	820da44d-dde1-4221-9ac5-453880ae84ad	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/0b3424ab-2bd6-4429-a503-290d043e66fb/v1_dejavu_sans_24.pf2	308972	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:14.987324
448576e9-fd2a-4fb6-951b-bc5ee740bf6d	ae7bd493-5033-4c29-8675-9322980fd9c7	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/2f94a9e0-0118-48b2-bab4-ec056e139fd2/v1_terminal_box_c.png	976	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.010733
8e877dcb-8aaf-4247-ab22-1e71ed7b8d95	42518f10-7bfa-4613-b2df-fc4e01981464	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/2cee5b27-7647-4bcd-ad45-fc1760179cff/v1_kbd.png	470	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.033835
94145a2f-90cc-4d7b-94d9-47258b3ad4db	23e19e3f-48ee-4950-9e01-5c0f87ad1e65	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/05bd00e3-cc79-4833-b684-5db1a4803dcc/v1_antergos.png	1125	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.060428
6ccca9ec-7609-4e79-80f9-16b62fabc93b	58066a94-c3af-425f-9aba-aaca060dae27	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/cc7497c7-3233-4ca7-a2b6-662e9c762d18/v1_find.none.png	808	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.08172
befe6321-4848-4637-9020-e4fa5718c709	30a3159a-17c5-409e-a433-0b5ee479ecfc	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/f895cbca-c4c6-424d-a2c4-b9bf62436370/v1_arcolinux.png	483	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.105909
74390636-2332-4735-844b-34bf7675379e	9557840c-871e-47e0-886c-f2b98dbc4eef	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ced5a7f7-6190-4678-89e3-7b743192b8cc/v1_unset.png	652	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.131974
ac401b2a-c9e8-43f0-9ec6-6ce11d9847d2	f6d27409-6eae-4426-8988-158d993adc7b	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/58e482b8-617b-4ce5-a119-7993ad804399/v1_endeavouros.png	1312	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.166423
17ff7998-4369-4277-bbb1-d595d2d35c29	c19144a3-f2ed-47b8-98e5-23d3edfc0352	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/8a91833b-1c2c-4cc5-9576-bbf0afd1c0d5/v1_arch.png	881	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.193236
ce81670d-4119-49e7-8453-c02e2e4061f7	e15f5aa8-3c97-4f93-a623-2f037776ad6f	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7c55e747-cc87-4210-b7c9-dd82f03de2bf/v1_shutdown.png	909	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.216829
3363a508-20ec-4a26-b830-63ea28e1f879	bc8324a7-7d90-4330-9fc2-d5161991d940	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/9efd180d-36c9-4df0-9be9-bccb5ecc0ef5/v1_windows.png	598	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.241436
aa1c060f-4dde-4ae5-8538-9077849e4142	d03aee5b-d503-4269-a7a6-afcc3151a37a	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/bf0dd010-c88b-470e-8d3a-fd15d5e449d9/v1_lubuntu.png	1188	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.264077
7ac86ae7-e6af-468f-bd62-915c1b099fb8	bc70a517-a616-4574-afcf-ea9a2559a0c6	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c2b21980-5d5f-4f1e-9d26-a9fc78330cc3/v1_steamos.png	1082	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.288186
b2f18633-a1f1-4e1c-b42d-b01aff090447	7de489bf-4c58-4139-b2cc-76dca4c70695	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/1dd259a0-7799-4725-b24e-e3283d08a6e4/v1_void.png	1256	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.310321
9c5567c2-2dc1-439c-bab7-776c27ef65ea	4f6d103f-ca59-4c08-9c28-d75d04ec35ab	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/47601019-87cb-418a-ab36-990eb18b1f9c/v1_unknown.png	1397	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.334067
323a3e5c-831d-4785-8db2-78cdb1c69bff	0c18f64b-c38a-4abc-9d4f-e7b18256d862	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ead8d224-5fec-4a32-bab0-ced562b44267/v1_linux.png	1397	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.359958
ada5cf1f-b5e3-426e-99f7-07e32ddd8260	bcbaaa30-ee37-46c8-909b-4b3d8d424596	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ce368176-f214-43d9-b4c5-fe3c825a6634/v1_chakra.png	1255	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.385865
77f393c1-7193-40a7-82e2-d5393470e418	c826bf28-e0f5-4d65-8c72-9814ef03bd36	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/8f5cde84-45dc-4534-afdf-d0dea8357ad6/v1_kubuntu.png	1291	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.41192
cb0d056d-098b-488c-9d03-b21b94fc1ab1	d0bc512f-c236-4b80-bfbe-fabf265cfb2a	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/5666b5ee-af5a-447a-abb6-d4e3ee6c8714/v1_tz.png	818	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.436007
4cb3a34f-a5fc-466b-9e76-6ae01a4bb69a	2873b52a-fb90-425d-9053-ef2c61117c07	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/64469652-30d0-440a-b782-823a1e2c23a6/v1_mageia.png	1397	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.459712
f9c341b1-436c-4d58-a435-683818305a3d	c10aa07e-6d98-4236-891d-8e6efd244a37	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4997ca95-97e3-4826-95c3-4a5f8d5178f6/v1_help.png	480	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.483089
b1054a69-e1b5-498e-8a2d-80d37b0acaa9	715f5977-175b-42a1-8e08-680c7de9bd9d	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/25ce4b10-41ad-43fd-95f2-36941348ac2f/v1_manjaro.png	388	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.505251
4ec37e3d-b58e-4f91-80e1-76fc4583dd73	0b4a9a62-e46e-4892-8cdd-bbc755824334	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c420f129-8748-48d4-a2ac-714467646956/v1_edit.png	418	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.530071
496f8d9c-53d0-467c-bf54-b95b72db8b73	010fe3c2-c771-4324-bd82-9b72ea5295b3	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7452fd5a-9f40-428f-92ba-d773f98b9c80/v1_archlinux.png	881	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.554359
e39580d6-39ff-4ff5-a13c-f5061e3c7fd6	c2c4958e-8c27-4add-9da5-aac61a6dc55c	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/39cc9ed6-c4c2-49a8-b7f3-5e91f5e94b7c/v1_memtest.png	793	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.579054
ed0b48ad-a314-46f9-a777-5a0250b1d238	edf2cd87-97fa-4c6e-bb83-e86ddd7f7325	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a0ccd011-f9c7-4bea-96a2-77f0457198e2/v1_find.efi.png	699	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.601663
88b56a32-e45c-4039-afa8-d0e557698b16	d7d7ead7-a814-413d-8d6f-b82108dc9e18	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/0e71aacd-a527-4dab-96cc-33229af65356/v1_debian.png	1096	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.623396
ce9d5be7-b951-4758-a903-0cbee759439b	a5af63e5-59fb-4a34-b1e3-607db403252f	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/61a7bd71-cc07-4ec0-b4e1-b887aa1b1544/v1_devuan.png	788	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.647032
9a85b917-2c5b-4657-903c-eccc13f17213	04885337-41ca-460e-8651-f5533026f66c	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/05e99868-beae-41a6-bcba-74ea4e5056e4/v1_gentoo.png	863	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.667871
a8e52d16-7e0e-4db3-9281-6f805cc635e0	f51f6aa4-2884-41e4-8c27-8409e18c8c68	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/5d5364c9-381b-41c7-bf8d-acb4ce3f43db/v1_korora.png	1113	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.688954
b2a63d9b-9f17-496c-8646-bf1405076d2a	dc30e883-d39f-436a-a90e-63592950d4b2	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4b997a76-4690-422b-826e-d4ae0d246aa7/v1_kali.png	1059	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.710222
7be2462d-221d-4fc5-be7a-f50f3bd02b1c	15fd71a0-8fee-454e-9b97-c13a5d515433	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ef7e6778-4ef6-4cf1-8f7f-35460806de2e/v1_pop-os.png	1424	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.731138
dbbd6253-c327-49b3-91f0-a10b136feaf0	fb8a226f-f9ed-4768-b90d-41cfc2eb9179	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/12f0116a-44c5-4a4c-872b-dd6aa0dfcee2/v1_opensuse.png	1327	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.754468
ca8471c7-0e92-4f58-9ad1-54de342fd4de	1b437c3b-e890-44ec-b644-cbf8de34859f	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c7a99e81-9fc1-4e93-b25c-0c1eda0e5fde/v1_deepin.png	1208	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.777076
aadde2ca-1f71-4326-b421-3cbb9996bb00	042a43e4-e025-490f-95bf-2b530af4f155	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/b9da345d-ec7c-4386-a9d8-ac9283465b2a/v1_recovery.png	707	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.799285
edad1799-508a-47fd-b129-56a34ed670bb	2fe6ee61-79ba-4dcd-a14a-fd29826c0d59	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/85ba54ce-1efd-4191-91b4-bc1d3fa51447/v1_restart.png	709	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.822791
e370e611-0111-465d-94ee-2fb8ade78bca	f869d0c9-8a1e-4cd0-8cfc-06333dcef82d	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/272b1160-f626-45d0-8541-f6145dd0c828/v1_lfs.png	1397	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.843551
617777cb-5699-4019-8e23-9461796f412e	81b03945-6eb5-46f5-915f-9dd15c3af4af	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/1519a032-9926-436b-9333-03391f26378e/v1_ubuntu.png	1261	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.864358
7d8b9f59-251d-4d8f-9f5a-0ddc6fbf49ce	f1441617-f061-4dde-9757-f3fff70acef8	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7acd0acf-08a7-4b4f-ab65-c0feb9023f2c/v1_elementary.png	1577	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.884669
672c6838-40ce-4bb0-b2e9-6c20ada7d898	af2c6a37-72c9-488f-96f0-c7ade32b357f	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/209d8339-ffa3-4264-9304-7c6e4f2c038b/v1_gnu-linux.png	1397	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.904517
fe91753c-c2a3-426d-ac46-d2400191ab31	947a0e66-c6fb-4afe-9b60-4c9c76e7ef6f	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/76495eac-f828-4e65-b440-c5ef2efde7ef/v1_cancel.png	541	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.924551
b26ecf06-8f12-4ccd-807a-3b3fbb3c57ff	338822f8-3b04-4ce6-bf7a-1379113eac2a	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/566965a1-0f88-4830-9ab6-1366cd3d762f/v1_linuxmint.png	1003	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.946183
2ddd08ad-f6f3-4355-9473-2f81ff9c6722	d4239963-b239-4634-8739-a4957efcfb42	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/905bad8a-d795-4b9f-9679-7b2b9e6c8c78/v1_lang.png	1202	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.967824
b924c6cc-5b94-43ad-a77e-8d7c1f279e82	a6bff225-189a-4c47-8b52-b2baac25bb65	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/76eb2767-b3f6-4018-a4ec-24e90be6107d/v1_type.png	385	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:15.987868
a839fc1b-555c-4ca3-a850-e3770d70f770	574b5411-1b9b-49b7-bde9-4ef5e3d70815	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ba25c79a-6393-4969-9d9e-f60d3fa00d74/v1_efi.png	665	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.008063
e1c2f65c-5b77-45f3-b7b9-c993ea1036a3	b370351e-e862-4b25-acb6-a3828e2d7059	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/05b32b1c-c6a2-461a-b235-70c3823e54da/v1_Manjaro.i686.png	388	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.03076
27d2f4c8-938d-4e45-8b2e-26fbb1477226	33bbad4e-e5dc-4e42-a5bd-cbc6ad494384	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/e3c28b62-2cdf-40a9-817f-ed8e69f87a0b/v1_solus.png	1199	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.051124
e26e951f-d7fd-434e-9c7b-21cd48d976fe	4885b5d7-0b48-4061-a721-10279d3fbf69	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a4200590-8807-4548-9bdc-3f0c6bc982e8/v1_kaos.png	995	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.072166
d4753cd0-26c2-424a-bde0-7114d91dfa1b	551acd30-e5d3-41d0-a336-a3a5cb8d9121	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a252e489-8a09-482b-bf63-d1e632884463/v1_Manjaro.x86_64.png	388	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.093771
f0bc740f-d2f9-4d26-aa69-c76ad66109f6	33d19217-f3fa-4a9d-86e8-2cc057525618	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/2174ba22-c177-40c0-bea7-9b49b0583a07/v1_driver.png	793	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.115072
e1e0e37f-40b4-4028-ba87-25c4b7020ccd	30111653-87c8-4d7a-a129-9f048c3168cf	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/81dcdd91-fe10-4651-9b05-d1d123e2f9b4/v1_siduction.png	1147	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.137045
23a3829f-bf6b-4525-b07f-9db6a0c20e5a	cfcfc277-ae47-415e-b85e-4e6720a2a4d8	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/782bce7b-d244-4e48-bf1a-f44d2b3f08bc/v1_fedora.png	1057	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.158529
9a3dfcad-6ff3-423a-ab94-c5823d973bba	85176579-f940-4ecc-94b8-26b23a0d94f0	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/6090231d-b964-4f9b-8be4-a31ebabc06ad/v1_macosx.png	880	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.17914
0698cf4e-6555-4f98-ac3b-95785a0c1dbc	7526efb5-683a-4121-8cf7-3cac1a0c3124	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/dfb9f8cb-65b8-44a4-8489-98ece0482943/v1_xubuntu.png	1048	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.201727
5bbe9378-089f-4585-8ad3-22989ecf4048	39f04fd0-d218-4325-bc62-726c5f72332b	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/914ab96e-444a-4a1d-a6a2-6c41ca3b6563/v1_terminus-16.pf2	24214	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.221012
4e896896-31a2-4713-b8bd-fdd34806a930	6f0ab404-e4cb-48e8-a010-5e45e556a122	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/547402d4-d015-4aad-afcc-7e977a19cb4f/v1_terminal_box_se.png	1102	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.245144
01b37ab3-a5f7-4fe9-9931-60d315ad180c	15a7d5c8-08a1-4ef8-a6bc-d195ded3e477	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/33e3e479-674f-419b-b8b9-5206b824f288/v1_theme.txt	903	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.268552
7c256243-70eb-459b-ab44-81efee4e0c6b	87612912-2347-435a-be86-be77e1bfdd18	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/41571ceb-663c-4bb3-9a54-57505dfb9a15/v1_terminal_box_e.png	952	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.292077
3b77683b-f56d-4f1a-a603-498f339bde7e	b78b8e3d-31f9-4786-842c-6a9a42b88a2f	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/29696639-a836-4bc4-b4be-30b0dc42ea64/v1_select_e.png	289	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.315392
2bf4afd4-93a2-497d-bd4f-2628892e2425	6575da8e-d064-42aa-8779-28cb091644c9	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/0472dfee-e49c-447b-bb8b-becb4f8b3f78/v1_terminal_box_sw.png	1107	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.336185
15c0a034-e1e5-478d-8ef8-2652287282c0	a09e64e3-cdde-48a2-b436-7309e8d35525	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/47f04bce-91c5-4168-9cf3-5fc24ba2c1e5/v1_terminal_box_n.png	963	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:16.359719
8cb3a0f2-0307-455b-a915-2a1351d56b51	61f50571-7d17-4efb-85fc-d994b52f9e18	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/83099836-6fc0-4c30-b484-1a7c5f5f13ea/v1_2025-04-15_20-37.png	23606	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:46.42257
594c9f77-c0d6-47d5-ae42-01ecd8900b77	3d63e431-b733-406d-a2a7-c1ad5139b2cb	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/e7a9bb39-ce7b-494e-8dbd-b899ab5b4287/v1_Screenshot_02-Nov_14-34-24_3960.png	6323	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:42:58.66171
9dccb357-fd00-4ab3-8793-0049defc1042	2179ed99-bef1-49ad-8ee1-a8f42e8cd8d8	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/2d8fbd89-0488-4e73-a1ca-ad2b7ce856e4/v1_Screenshot_01-Oct_20-55-34_1945.png	29262	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:43:04.851041
721a8833-6105-4c1c-9ead-dd6305a81ddf	85f445e5-a8a9-42d5-8a3a-8e3bb8e2d4c1	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/d22b5f4c-8202-49af-9c33-8e3b35244337/v1_braces.png	1424843	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:43:09.719649
1e40376a-b8db-472b-b60a-8db76f533687	fe796dd7-b5e8-44c1-a296-25a36055c4a7	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/39555f7f-5b4c-4eaf-b0b9-80a786ad3027/v1_Screenshot_02-Oct_16-32-22_5891.png	122298	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:43:15.592025
ca478d07-b6b8-4d0a-8475-435d4c2cf23f	5c555b40-3e96-4c1f-ae35-5d6ac5a30985	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7ce2bb4c-e5f6-49e5-81ac-5c0976f7908a/v1_16-May_22-16-01-2025.png	260844	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:43:31.709878
0f829378-2580-4c69-97f3-dc5ffd0780a7	5a204d25-4430-4ecc-a41a-26ee160c4a64	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/01e87fb3-0b50-4932-8618-5d68b49efdd0/v1_ 5-May_16-50-20-2025.png	392995	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:43:36.370648
4927c497-a44f-497d-925a-1c5c5fa24ab2	603ca557-7647-4579-ad46-167f31cd83a4	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c7e0c1b9-595f-4c49-b87b-c6f54abf341c/v1_23-May_03-53-35-2025.png	22755	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:43:41.501797
e5dad3ec-d0cb-4854-815d-5f03d6211352	b01754da-b54b-406f-bf00-823adc3d6988	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c80f73c2-0b6f-4d84-b868-a8a3a1b1867e/v1_ 6-June_19-40-09-2025.png	436303	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:43:47.738462
019ba889-8584-4e26-ad59-cac33d822eac	2c33ef82-7c4d-4183-a2c5-235d57add03d	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/3d9dbca8-dab0-4740-9f22-3e0b7ce01427/v1_24-June_19-47-39-2025.png	862385	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:43:54.150695
ac055bfd-8119-42c5-8c87-1d3a22aaf882	aae3354a-e90c-431d-ba2e-347c26e3e60b	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/766579fa-1673-491b-81e5-98805c20ad00/v1_11-July_12-51-07-2025.png	807176	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:43:57.657733
2dc9d5f1-a014-494f-9e24-f8489482d3b9	e060acac-8fdf-478b-b408-3f2b23447883	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/101099bc-56b2-4f0b-bcda-d2f131ea5f28/v1_22-July_16-53-05-2025.png	364643	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:44:05.863599
6e68ba79-f0d2-41f4-a97d-db1089a56abd	1e6995a7-9f4d-4276-a7d1-96d4275d7011	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/874eac16-38f2-40c3-b405-f15f9c2df218/v1_18-July_12-30-07-2025.png	848047	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:44:34.367633
58438ed2-37d1-47f1-9e20-4266467ff0d9	7a29d2a3-4abb-47ba-a074-33dd191c7bb8	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/98fe3c11-e63f-44d7-9277-799e497f226b/v1_Screenshot_15-Jul_13-08-34_1498.png	1251719	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:44:42.916635
d39e7905-b312-4253-be92-7b9aa1c275c8	af2c523a-01e6-45df-a7b7-79a85d7d65a4	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/56f758a0-dc81-40d8-9068-3617637ac1e1/v1_Screenshot_13-Jul_14-52-40_5508.png	1233235	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:44:48.742045
63661cb8-b6b0-435c-ac56-8d6798b38276	144cb4bc-5228-4d95-af0a-69b28fc2503c	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4b252c62-b6a6-4701-b16f-8f9cfb85b92b/v1_25-June_20-33-10-2025.png	561176	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:44:59.924484
db93f2d3-3ede-4a62-9232-6f43f8bbfcb2	b31ca8ec-1952-4ab6-bc1d-9448d9f0fd24	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/37be7a2e-9f2f-49ff-8cca-981f0b315e81/v1_23-May_03-53-35-2025.png	22755	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:45:09.661848
1ac47e6b-7d58-4670-b8ba-9d71257f2377	5ef67e06-9eeb-4c22-a712-27a3e1cd7c34	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/83f0b4ca-91c3-4643-b933-f6e4daac706f/v1_Rebuttal_Sentence_Stems.pdf	2437	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:45:29.600109
94c13346-3870-4362-b6b0-d89476874516	8c1a933e-dab4-4c83-b81d-30fb912ac1e7	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/3f67457a-7817-4cd6-8114-b571420e959e/v1_Debate (1).pdf	1003429	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:45:31.498733
3693e33f-fe66-449d-a938-60dccadf1bd1	d4c6301f-b510-4880-9294-331b9ae4e70a	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4e0a2833-848f-4279-8e96-41302b811367/v1_Sounds of English Consonant Sounds.pdf	164419	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:45:35.00862
3df96bbf-9364-4e50-b98d-d90994541de1	67d595db-eaff-4554-a5ad-ad2ac532516d	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/55a35a77-73db-4ce5-bc13-b9ccceecb45d/v1_Language-On-Schools-English-Irregular-Verbs-List (1).pdf	71999	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:45:37.777465
96383d17-23ca-4716-989b-bf16ab38881e	4e090b4c-c8ef-49a3-ac21-9a4338383c4e	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/21cb4e9b-ff0e-4b3a-9f45-154d3f4e4722/v1_notely-474107-b7a125a8fdaf.json	2369	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:45:39.820772
4d1c1431-45d5-46d2-9d7c-c6c015b4ceac	253191cd-3da4-4b80-8101-d9eec2c78689	1	user_78c793b5-a705-403a-bec3-2cd04a654bb3/f2a3e506-1046-497a-9d93-cd9fedb96148/v1_Expressions for Discussion and Debate new.pdf	36912	78c793b5-a705-403a-bec3-2cd04a654bb3	2025-11-03 04:45:43.149246
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.files (id, name, original_name, mime_type, size, storage_path, owner_id, parent_folder_id, status, is_starred, thumbnail_path, preview_available, version, current_version_id, created_at, updated_at, trashed_at, last_accessed_at) FROM stdin;
5b952786-4f3d-4bc7-9acd-38f5760b000f	Lag Ja Gale (From _Bhoomi_).mp3	Lag Ja Gale (From _Bhoomi_).mp3	audio/mpeg	7364274	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a3501d44-678f-44b4-9bd6-2f7515f0ec1d/v1_Lag Ja Gale (From _Bhoomi_).mp3	78c793b5-a705-403a-bec3-2cd04a654bb3	02f4d329-ac4d-4f9d-b7b5-32081928e0cf	active	f	\N	f	1	\N	2025-11-03 04:41:12.39458	2025-11-03 04:41:12.39458	\N	\N
4044f7c8-b4bc-44d1-9d0d-435ae04770ca	SUBHANALLAH.mp3	SUBHANALLAH.mp3	audio/mpeg	8204874	user_78c793b5-a705-403a-bec3-2cd04a654bb3/11f3a7ea-4d63-47c6-bd3e-82dbd7e79ef0/v1_SUBHANALLAH.mp3	78c793b5-a705-403a-bec3-2cd04a654bb3	02f4d329-ac4d-4f9d-b7b5-32081928e0cf	active	f	\N	f	1	\N	2025-11-03 04:41:14.580462	2025-11-03 04:41:14.580462	\N	\N
864d62b3-2ab4-4c91-9d61-665f59ab41f3	Somewhere Only We Know.mp3	Somewhere Only We Know.mp3	audio/mpeg	7920416	user_78c793b5-a705-403a-bec3-2cd04a654bb3/557cc06a-8a56-4c24-8d5e-b67d35cebcfc/v1_Somewhere Only We Know.mp3	78c793b5-a705-403a-bec3-2cd04a654bb3	02f4d329-ac4d-4f9d-b7b5-32081928e0cf	active	f	\N	f	1	\N	2025-11-03 04:41:16.516753	2025-11-03 04:41:16.516753	\N	\N
cdbab8dc-4edc-4808-a7f1-2d396b4b72f2	Rishte Naate.mp3	Rishte Naate.mp3	audio/mpeg	9879142	user_78c793b5-a705-403a-bec3-2cd04a654bb3/323880e1-4a72-48f9-9832-18bf55dfc965/v1_Rishte Naate.mp3	78c793b5-a705-403a-bec3-2cd04a654bb3	02f4d329-ac4d-4f9d-b7b5-32081928e0cf	active	f	\N	f	1	\N	2025-11-03 04:41:18.73813	2025-11-03 04:41:18.73813	\N	\N
4db10556-cb7c-47d7-a882-1ae057aa6ecf	Dil Ke Paas (Indian Version by Arijit Singh).mp3	Dil Ke Paas (Indian Version by Arijit Singh).mp3	audio/mpeg	8965286	user_78c793b5-a705-403a-bec3-2cd04a654bb3/dc8318fd-e3b6-464e-a200-787a7d64a399/v1_Dil Ke Paas (Indian Version by Arijit Singh).mp3	78c793b5-a705-403a-bec3-2cd04a654bb3	02f4d329-ac4d-4f9d-b7b5-32081928e0cf	active	f	\N	f	1	\N	2025-11-03 04:41:38.305527	2025-11-03 04:41:38.305527	\N	\N
caa920b0-093d-4a2f-9814-2bf153e83ca5	gtk-master.zip	gtk-master.zip	application/zip	5717247	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a8d8424b-336d-4fbb-842a-2f62dce51edb/v1_gtk-master.zip	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:11.071452	2025-11-03 04:42:11.071452	\N	\N
03934a3d-9584-4c8a-9e9b-7d4adcf19004	Breeze-gtk.tar	Breeze-gtk.tar	application/x-tar	367987	user_78c793b5-a705-403a-bec3-2cd04a654bb3/b808e142-e5ce-4c70-a562-c2d78c2c6150/v1_Breeze-gtk.tar	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:12.519726	2025-11-03 04:42:12.519726	\N	\N
a368c2e7-0bc8-4a38-bd7a-9788ec8f67b2	LICENSE	LICENSE	application/octet-stream	35141	user_78c793b5-a705-403a-bec3-2cd04a654bb3/04ff5dc2-a1e3-4767-9654-fbbccddd1191/v1_LICENSE	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.393048	2025-11-03 04:42:14.393048	\N	\N
9dd6f107-7f42-4075-8681-e001404284ce	install.sh	install.sh	text/x-sh	3263	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7b9b743f-9208-4ba9-ac13-ab18e62465f3/v1_install.sh	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.419052	2025-11-03 04:42:14.419052	\N	\N
8ca9195e-68fc-4888-879e-7cb33a194ee3	terminal_box_nw.png	terminal_box_nw.png	image/png	1094	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ee2a0747-e726-49c4-8ed1-6ff9134a1517/v1_terminal_box_nw.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	ee2a0747-e726-49c4-8ed1-6ff9134a1517.jpg	t	1	\N	2025-11-03 04:42:14.445525	2025-11-03 04:42:14.445525	\N	\N
197222bb-b87b-4987-8c7c-98b6ba547c5a	dejavu_sans_16.pf2	dejavu_sans_16.pf2	application/octet-stream	203880	user_78c793b5-a705-403a-bec3-2cd04a654bb3/53c6dc6b-cca7-48a0-9202-73a42b3c9600/v1_dejavu_sans_16.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.471013	2025-11-03 04:42:14.471013	\N	\N
8bfd1edb-64ce-4c12-b0e6-c0a5a2dada07	select_c.png	select_c.png	image/png	181	user_78c793b5-a705-403a-bec3-2cd04a654bb3/48650491-60ba-4145-99e9-759a532f5215/v1_select_c.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	48650491-60ba-4145-99e9-759a532f5215.jpg	t	1	\N	2025-11-03 04:42:14.495479	2025-11-03 04:42:14.495479	\N	\N
3ac5db9c-905b-4a04-af55-5b5a893c14a9	terminus-18.pf2	terminus-18.pf2	application/octet-stream	26835	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4244470a-c8f0-44cf-b3dd-d5ef4932202b/v1_terminus-18.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.518606	2025-11-03 04:42:14.518606	\N	\N
a5407038-d0ac-4a58-9c75-b6f21449eef9	select_w.png	select_w.png	image/png	280	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ebd04f23-7db1-45db-851e-7016949cf3ee/v1_select_w.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	ebd04f23-7db1-45db-851e-7016949cf3ee.jpg	t	1	\N	2025-11-03 04:42:14.545205	2025-11-03 04:42:14.545205	\N	\N
95d978e9-7224-42bf-8553-77be0f39067e	terminal_box_w.png	terminal_box_w.png	image/png	952	user_78c793b5-a705-403a-bec3-2cd04a654bb3/9becb7cc-a4d2-499e-babf-9c5ecd98365d/v1_terminal_box_w.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	9becb7cc-a4d2-499e-babf-9c5ecd98365d.jpg	t	1	\N	2025-11-03 04:42:14.568992	2025-11-03 04:42:14.568992	\N	\N
d5c70f6f-50f6-4fd5-ae76-38aa50f6e760	terminal_box_s.png	terminal_box_s.png	image/png	963	user_78c793b5-a705-403a-bec3-2cd04a654bb3/f359ce6f-9298-476c-b5ac-6dccf11a638a/v1_terminal_box_s.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	f359ce6f-9298-476c-b5ac-6dccf11a638a.jpg	t	1	\N	2025-11-03 04:42:14.5914	2025-11-03 04:42:14.5914	\N	\N
73028d7b-4ada-4d8b-8c66-2f11b7eaa1b0	dejavu_sans_14.pf2	dejavu_sans_14.pf2	application/octet-stream	185427	user_78c793b5-a705-403a-bec3-2cd04a654bb3/83a70701-f071-433e-acb7-cbc8fe320eb4/v1_dejavu_sans_14.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.613622	2025-11-03 04:42:14.613622	\N	\N
62a4e761-71eb-459f-b648-ccc7dbf1dd5f	dejavu_sans_48.pf2	dejavu_sans_48.pf2	application/octet-stream	868265	user_78c793b5-a705-403a-bec3-2cd04a654bb3/594c1386-965a-49b6-97ed-dce4340f7ea8/v1_dejavu_sans_48.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.641458	2025-11-03 04:42:14.641458	\N	\N
80c1c7fa-0f9f-4c16-80dc-21494109399b	terminus-14.pf2	terminus-14.pf2	application/octet-stream	23941	user_78c793b5-a705-403a-bec3-2cd04a654bb3/143863bf-5d49-470f-9dc5-eba197cf2579/v1_terminus-14.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.662235	2025-11-03 04:42:14.662235	\N	\N
322d1d7c-d133-4ad7-9d3c-0b999a55a9b7	background.jpg	background.jpg	image/jpeg	634281	user_78c793b5-a705-403a-bec3-2cd04a654bb3/013e6a1e-16fc-4753-8856-a83aa8fa9c77/v1_background.jpg	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	013e6a1e-16fc-4753-8856-a83aa8fa9c77.jpg	t	1	\N	2025-11-03 04:42:14.864098	2025-11-03 04:42:14.864098	\N	\N
ffbb2f7d-af9d-4805-b7a5-48c612a424b9	terminal_box_ne.png	terminal_box_ne.png	image/png	1115	user_78c793b5-a705-403a-bec3-2cd04a654bb3/8ba85e2f-9b3d-4ce2-85ae-bc473726e070/v1_terminal_box_ne.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	8ba85e2f-9b3d-4ce2-85ae-bc473726e070.jpg	t	1	\N	2025-11-03 04:42:14.889874	2025-11-03 04:42:14.889874	\N	\N
f1c2f140-3d4d-417f-a305-fdc7ecf5e362	terminus-12.pf2	terminus-12.pf2	application/octet-stream	21895	user_78c793b5-a705-403a-bec3-2cd04a654bb3/3890e92b-3933-46f6-89ec-7e5ddcd077ed/v1_terminus-12.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.910831	2025-11-03 04:42:14.910831	\N	\N
f84b5b70-e189-4866-ad91-6f92e367613a	dejavu_32.pf2	dejavu_32.pf2	application/octet-stream	452923	user_78c793b5-a705-403a-bec3-2cd04a654bb3/478e995d-5381-4a8f-8f1b-bbbb862b5b8d/v1_dejavu_32.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.934218	2025-11-03 04:42:14.934218	\N	\N
b097a6d5-555f-41ab-b06f-946ef53eea2a	dejavu_sans_12.pf2	dejavu_sans_12.pf2	application/octet-stream	168761	user_78c793b5-a705-403a-bec3-2cd04a654bb3/cdef7325-d7b5-44c9-bfe3-f1c287f7989f/v1_dejavu_sans_12.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.958296	2025-11-03 04:42:14.958296	\N	\N
820da44d-dde1-4221-9ac5-453880ae84ad	dejavu_sans_24.pf2	dejavu_sans_24.pf2	application/octet-stream	308972	user_78c793b5-a705-403a-bec3-2cd04a654bb3/0b3424ab-2bd6-4429-a503-290d043e66fb/v1_dejavu_sans_24.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:14.984725	2025-11-03 04:42:14.984725	\N	\N
ae7bd493-5033-4c29-8675-9322980fd9c7	terminal_box_c.png	terminal_box_c.png	image/png	976	user_78c793b5-a705-403a-bec3-2cd04a654bb3/2f94a9e0-0118-48b2-bab4-ec056e139fd2/v1_terminal_box_c.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	2f94a9e0-0118-48b2-bab4-ec056e139fd2.jpg	t	1	\N	2025-11-03 04:42:15.008081	2025-11-03 04:42:15.008081	\N	\N
42518f10-7bfa-4613-b2df-fc4e01981464	kbd.png	kbd.png	image/png	470	user_78c793b5-a705-403a-bec3-2cd04a654bb3/2cee5b27-7647-4bcd-ad45-fc1760179cff/v1_kbd.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	2cee5b27-7647-4bcd-ad45-fc1760179cff.jpg	t	1	\N	2025-11-03 04:42:15.030914	2025-11-03 04:42:15.030914	\N	\N
23e19e3f-48ee-4950-9e01-5c0f87ad1e65	antergos.png	antergos.png	image/png	1125	user_78c793b5-a705-403a-bec3-2cd04a654bb3/05bd00e3-cc79-4833-b684-5db1a4803dcc/v1_antergos.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	05bd00e3-cc79-4833-b684-5db1a4803dcc.jpg	t	1	\N	2025-11-03 04:42:15.057583	2025-11-03 04:42:15.057583	\N	\N
58066a94-c3af-425f-9aba-aaca060dae27	find.none.png	find.none.png	image/png	808	user_78c793b5-a705-403a-bec3-2cd04a654bb3/cc7497c7-3233-4ca7-a2b6-662e9c762d18/v1_find.none.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	cc7497c7-3233-4ca7-a2b6-662e9c762d18.jpg	t	1	\N	2025-11-03 04:42:15.079007	2025-11-03 04:42:15.079007	\N	\N
30a3159a-17c5-409e-a433-0b5ee479ecfc	arcolinux.png	arcolinux.png	image/png	483	user_78c793b5-a705-403a-bec3-2cd04a654bb3/f895cbca-c4c6-424d-a2c4-b9bf62436370/v1_arcolinux.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	f895cbca-c4c6-424d-a2c4-b9bf62436370.jpg	t	1	\N	2025-11-03 04:42:15.103126	2025-11-03 04:42:15.103126	\N	\N
9557840c-871e-47e0-886c-f2b98dbc4eef	unset.png	unset.png	image/png	652	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ced5a7f7-6190-4678-89e3-7b743192b8cc/v1_unset.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	ced5a7f7-6190-4678-89e3-7b743192b8cc.jpg	t	1	\N	2025-11-03 04:42:15.128106	2025-11-03 04:42:15.128106	\N	\N
f6d27409-6eae-4426-8988-158d993adc7b	endeavouros.png	endeavouros.png	image/png	1312	user_78c793b5-a705-403a-bec3-2cd04a654bb3/58e482b8-617b-4ce5-a119-7993ad804399/v1_endeavouros.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	58e482b8-617b-4ce5-a119-7993ad804399.jpg	t	1	\N	2025-11-03 04:42:15.163094	2025-11-03 04:42:15.163094	\N	\N
c19144a3-f2ed-47b8-98e5-23d3edfc0352	arch.png	arch.png	image/png	881	user_78c793b5-a705-403a-bec3-2cd04a654bb3/8a91833b-1c2c-4cc5-9576-bbf0afd1c0d5/v1_arch.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	8a91833b-1c2c-4cc5-9576-bbf0afd1c0d5.jpg	t	1	\N	2025-11-03 04:42:15.190333	2025-11-03 04:42:15.190333	\N	\N
e15f5aa8-3c97-4f93-a623-2f037776ad6f	shutdown.png	shutdown.png	image/png	909	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7c55e747-cc87-4210-b7c9-dd82f03de2bf/v1_shutdown.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	7c55e747-cc87-4210-b7c9-dd82f03de2bf.jpg	t	1	\N	2025-11-03 04:42:15.213933	2025-11-03 04:42:15.213933	\N	\N
bc8324a7-7d90-4330-9fc2-d5161991d940	windows.png	windows.png	image/png	598	user_78c793b5-a705-403a-bec3-2cd04a654bb3/9efd180d-36c9-4df0-9be9-bccb5ecc0ef5/v1_windows.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	9efd180d-36c9-4df0-9be9-bccb5ecc0ef5.jpg	t	1	\N	2025-11-03 04:42:15.238566	2025-11-03 04:42:15.238566	\N	\N
d03aee5b-d503-4269-a7a6-afcc3151a37a	lubuntu.png	lubuntu.png	image/png	1188	user_78c793b5-a705-403a-bec3-2cd04a654bb3/bf0dd010-c88b-470e-8d3a-fd15d5e449d9/v1_lubuntu.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	bf0dd010-c88b-470e-8d3a-fd15d5e449d9.jpg	t	1	\N	2025-11-03 04:42:15.261432	2025-11-03 04:42:15.261432	\N	\N
bc70a517-a616-4574-afcf-ea9a2559a0c6	steamos.png	steamos.png	image/png	1082	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c2b21980-5d5f-4f1e-9d26-a9fc78330cc3/v1_steamos.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	c2b21980-5d5f-4f1e-9d26-a9fc78330cc3.jpg	t	1	\N	2025-11-03 04:42:15.285031	2025-11-03 04:42:15.285031	\N	\N
7de489bf-4c58-4139-b2cc-76dca4c70695	void.png	void.png	image/png	1256	user_78c793b5-a705-403a-bec3-2cd04a654bb3/1dd259a0-7799-4725-b24e-e3283d08a6e4/v1_void.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	1dd259a0-7799-4725-b24e-e3283d08a6e4.jpg	t	1	\N	2025-11-03 04:42:15.307657	2025-11-03 04:42:15.307657	\N	\N
4f6d103f-ca59-4c08-9c28-d75d04ec35ab	unknown.png	unknown.png	image/png	1397	user_78c793b5-a705-403a-bec3-2cd04a654bb3/47601019-87cb-418a-ab36-990eb18b1f9c/v1_unknown.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	47601019-87cb-418a-ab36-990eb18b1f9c.jpg	t	1	\N	2025-11-03 04:42:15.330695	2025-11-03 04:42:15.330695	\N	\N
0c18f64b-c38a-4abc-9d4f-e7b18256d862	linux.png	linux.png	image/png	1397	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ead8d224-5fec-4a32-bab0-ced562b44267/v1_linux.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	ead8d224-5fec-4a32-bab0-ced562b44267.jpg	t	1	\N	2025-11-03 04:42:15.357166	2025-11-03 04:42:15.357166	\N	\N
bcbaaa30-ee37-46c8-909b-4b3d8d424596	chakra.png	chakra.png	image/png	1255	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ce368176-f214-43d9-b4c5-fe3c825a6634/v1_chakra.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	ce368176-f214-43d9-b4c5-fe3c825a6634.jpg	t	1	\N	2025-11-03 04:42:15.382897	2025-11-03 04:42:15.382897	\N	\N
c826bf28-e0f5-4d65-8c72-9814ef03bd36	kubuntu.png	kubuntu.png	image/png	1291	user_78c793b5-a705-403a-bec3-2cd04a654bb3/8f5cde84-45dc-4534-afdf-d0dea8357ad6/v1_kubuntu.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	8f5cde84-45dc-4534-afdf-d0dea8357ad6.jpg	t	1	\N	2025-11-03 04:42:15.409035	2025-11-03 04:42:15.409035	\N	\N
d0bc512f-c236-4b80-bfbe-fabf265cfb2a	tz.png	tz.png	image/png	818	user_78c793b5-a705-403a-bec3-2cd04a654bb3/5666b5ee-af5a-447a-abb6-d4e3ee6c8714/v1_tz.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	5666b5ee-af5a-447a-abb6-d4e3ee6c8714.jpg	t	1	\N	2025-11-03 04:42:15.433297	2025-11-03 04:42:15.433297	\N	\N
2873b52a-fb90-425d-9053-ef2c61117c07	mageia.png	mageia.png	image/png	1397	user_78c793b5-a705-403a-bec3-2cd04a654bb3/64469652-30d0-440a-b782-823a1e2c23a6/v1_mageia.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	64469652-30d0-440a-b782-823a1e2c23a6.jpg	t	1	\N	2025-11-03 04:42:15.457018	2025-11-03 04:42:15.457018	\N	\N
c10aa07e-6d98-4236-891d-8e6efd244a37	help.png	help.png	image/png	480	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4997ca95-97e3-4826-95c3-4a5f8d5178f6/v1_help.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	4997ca95-97e3-4826-95c3-4a5f8d5178f6.jpg	t	1	\N	2025-11-03 04:42:15.480193	2025-11-03 04:42:15.480193	\N	\N
715f5977-175b-42a1-8e08-680c7de9bd9d	manjaro.png	manjaro.png	image/png	388	user_78c793b5-a705-403a-bec3-2cd04a654bb3/25ce4b10-41ad-43fd-95f2-36941348ac2f/v1_manjaro.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	25ce4b10-41ad-43fd-95f2-36941348ac2f.jpg	t	1	\N	2025-11-03 04:42:15.502434	2025-11-03 04:42:15.502434	\N	\N
0b4a9a62-e46e-4892-8cdd-bbc755824334	edit.png	edit.png	image/png	418	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c420f129-8748-48d4-a2ac-714467646956/v1_edit.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	c420f129-8748-48d4-a2ac-714467646956.jpg	t	1	\N	2025-11-03 04:42:15.52722	2025-11-03 04:42:15.52722	\N	\N
010fe3c2-c771-4324-bd82-9b72ea5295b3	archlinux.png	archlinux.png	image/png	881	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7452fd5a-9f40-428f-92ba-d773f98b9c80/v1_archlinux.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	7452fd5a-9f40-428f-92ba-d773f98b9c80.jpg	t	1	\N	2025-11-03 04:42:15.551124	2025-11-03 04:42:15.551124	\N	\N
c2c4958e-8c27-4add-9da5-aac61a6dc55c	memtest.png	memtest.png	image/png	793	user_78c793b5-a705-403a-bec3-2cd04a654bb3/39cc9ed6-c4c2-49a8-b7f3-5e91f5e94b7c/v1_memtest.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	39cc9ed6-c4c2-49a8-b7f3-5e91f5e94b7c.jpg	t	1	\N	2025-11-03 04:42:15.576338	2025-11-03 04:42:15.576338	\N	\N
edf2cd87-97fa-4c6e-bb83-e86ddd7f7325	find.efi.png	find.efi.png	image/png	699	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a0ccd011-f9c7-4bea-96a2-77f0457198e2/v1_find.efi.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	a0ccd011-f9c7-4bea-96a2-77f0457198e2.jpg	t	1	\N	2025-11-03 04:42:15.599171	2025-11-03 04:42:15.599171	\N	\N
d7d7ead7-a814-413d-8d6f-b82108dc9e18	debian.png	debian.png	image/png	1096	user_78c793b5-a705-403a-bec3-2cd04a654bb3/0e71aacd-a527-4dab-96cc-33229af65356/v1_debian.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	0e71aacd-a527-4dab-96cc-33229af65356.jpg	t	1	\N	2025-11-03 04:42:15.620768	2025-11-03 04:42:15.620768	\N	\N
a5af63e5-59fb-4a34-b1e3-607db403252f	devuan.png	devuan.png	image/png	788	user_78c793b5-a705-403a-bec3-2cd04a654bb3/61a7bd71-cc07-4ec0-b4e1-b887aa1b1544/v1_devuan.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	61a7bd71-cc07-4ec0-b4e1-b887aa1b1544.jpg	t	1	\N	2025-11-03 04:42:15.644177	2025-11-03 04:42:15.644177	\N	\N
04885337-41ca-460e-8651-f5533026f66c	gentoo.png	gentoo.png	image/png	863	user_78c793b5-a705-403a-bec3-2cd04a654bb3/05e99868-beae-41a6-bcba-74ea4e5056e4/v1_gentoo.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	05e99868-beae-41a6-bcba-74ea4e5056e4.jpg	t	1	\N	2025-11-03 04:42:15.665366	2025-11-03 04:42:15.665366	\N	\N
f51f6aa4-2884-41e4-8c27-8409e18c8c68	korora.png	korora.png	image/png	1113	user_78c793b5-a705-403a-bec3-2cd04a654bb3/5d5364c9-381b-41c7-bf8d-acb4ce3f43db/v1_korora.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	5d5364c9-381b-41c7-bf8d-acb4ce3f43db.jpg	t	1	\N	2025-11-03 04:42:15.686331	2025-11-03 04:42:15.686331	\N	\N
dc30e883-d39f-436a-a90e-63592950d4b2	kali.png	kali.png	image/png	1059	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4b997a76-4690-422b-826e-d4ae0d246aa7/v1_kali.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	4b997a76-4690-422b-826e-d4ae0d246aa7.jpg	t	1	\N	2025-11-03 04:42:15.707636	2025-11-03 04:42:15.707636	\N	\N
15fd71a0-8fee-454e-9b97-c13a5d515433	pop-os.png	pop-os.png	image/png	1424	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ef7e6778-4ef6-4cf1-8f7f-35460806de2e/v1_pop-os.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	ef7e6778-4ef6-4cf1-8f7f-35460806de2e.jpg	t	1	\N	2025-11-03 04:42:15.728397	2025-11-03 04:42:15.728397	\N	\N
fb8a226f-f9ed-4768-b90d-41cfc2eb9179	opensuse.png	opensuse.png	image/png	1327	user_78c793b5-a705-403a-bec3-2cd04a654bb3/12f0116a-44c5-4a4c-872b-dd6aa0dfcee2/v1_opensuse.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	12f0116a-44c5-4a4c-872b-dd6aa0dfcee2.jpg	t	1	\N	2025-11-03 04:42:15.75111	2025-11-03 04:42:15.75111	\N	\N
1b437c3b-e890-44ec-b644-cbf8de34859f	deepin.png	deepin.png	image/png	1208	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c7a99e81-9fc1-4e93-b25c-0c1eda0e5fde/v1_deepin.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	c7a99e81-9fc1-4e93-b25c-0c1eda0e5fde.jpg	t	1	\N	2025-11-03 04:42:15.774201	2025-11-03 04:42:15.774201	\N	\N
042a43e4-e025-490f-95bf-2b530af4f155	recovery.png	recovery.png	image/png	707	user_78c793b5-a705-403a-bec3-2cd04a654bb3/b9da345d-ec7c-4386-a9d8-ac9283465b2a/v1_recovery.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	b9da345d-ec7c-4386-a9d8-ac9283465b2a.jpg	t	1	\N	2025-11-03 04:42:15.796557	2025-11-03 04:42:15.796557	\N	\N
2fe6ee61-79ba-4dcd-a14a-fd29826c0d59	restart.png	restart.png	image/png	709	user_78c793b5-a705-403a-bec3-2cd04a654bb3/85ba54ce-1efd-4191-91b4-bc1d3fa51447/v1_restart.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	85ba54ce-1efd-4191-91b4-bc1d3fa51447.jpg	t	1	\N	2025-11-03 04:42:15.820119	2025-11-03 04:42:15.820119	\N	\N
f869d0c9-8a1e-4cd0-8cfc-06333dcef82d	lfs.png	lfs.png	image/png	1397	user_78c793b5-a705-403a-bec3-2cd04a654bb3/272b1160-f626-45d0-8541-f6145dd0c828/v1_lfs.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	272b1160-f626-45d0-8541-f6145dd0c828.jpg	t	1	\N	2025-11-03 04:42:15.841124	2025-11-03 04:42:15.841124	\N	\N
81b03945-6eb5-46f5-915f-9dd15c3af4af	ubuntu.png	ubuntu.png	image/png	1261	user_78c793b5-a705-403a-bec3-2cd04a654bb3/1519a032-9926-436b-9333-03391f26378e/v1_ubuntu.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	1519a032-9926-436b-9333-03391f26378e.jpg	t	1	\N	2025-11-03 04:42:15.861898	2025-11-03 04:42:15.861898	\N	\N
f1441617-f061-4dde-9757-f3fff70acef8	elementary.png	elementary.png	image/png	1577	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7acd0acf-08a7-4b4f-ab65-c0feb9023f2c/v1_elementary.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	7acd0acf-08a7-4b4f-ab65-c0feb9023f2c.jpg	t	1	\N	2025-11-03 04:42:15.8822	2025-11-03 04:42:15.8822	\N	\N
af2c6a37-72c9-488f-96f0-c7ade32b357f	gnu-linux.png	gnu-linux.png	image/png	1397	user_78c793b5-a705-403a-bec3-2cd04a654bb3/209d8339-ffa3-4264-9304-7c6e4f2c038b/v1_gnu-linux.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	209d8339-ffa3-4264-9304-7c6e4f2c038b.jpg	t	1	\N	2025-11-03 04:42:15.901974	2025-11-03 04:42:15.901974	\N	\N
947a0e66-c6fb-4afe-9b60-4c9c76e7ef6f	cancel.png	cancel.png	image/png	541	user_78c793b5-a705-403a-bec3-2cd04a654bb3/76495eac-f828-4e65-b440-c5ef2efde7ef/v1_cancel.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	76495eac-f828-4e65-b440-c5ef2efde7ef.jpg	t	1	\N	2025-11-03 04:42:15.922088	2025-11-03 04:42:15.922088	\N	\N
338822f8-3b04-4ce6-bf7a-1379113eac2a	linuxmint.png	linuxmint.png	image/png	1003	user_78c793b5-a705-403a-bec3-2cd04a654bb3/566965a1-0f88-4830-9ab6-1366cd3d762f/v1_linuxmint.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	566965a1-0f88-4830-9ab6-1366cd3d762f.jpg	t	1	\N	2025-11-03 04:42:15.943467	2025-11-03 04:42:15.943467	\N	\N
d4239963-b239-4634-8739-a4957efcfb42	lang.png	lang.png	image/png	1202	user_78c793b5-a705-403a-bec3-2cd04a654bb3/905bad8a-d795-4b9f-9679-7b2b9e6c8c78/v1_lang.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	905bad8a-d795-4b9f-9679-7b2b9e6c8c78.jpg	t	1	\N	2025-11-03 04:42:15.965022	2025-11-03 04:42:15.965022	\N	\N
a6bff225-189a-4c47-8b52-b2baac25bb65	type.png	type.png	image/png	385	user_78c793b5-a705-403a-bec3-2cd04a654bb3/76eb2767-b3f6-4018-a4ec-24e90be6107d/v1_type.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	76eb2767-b3f6-4018-a4ec-24e90be6107d.jpg	t	1	\N	2025-11-03 04:42:15.985189	2025-11-03 04:42:15.985189	\N	\N
574b5411-1b9b-49b7-bde9-4ef5e3d70815	efi.png	efi.png	image/png	665	user_78c793b5-a705-403a-bec3-2cd04a654bb3/ba25c79a-6393-4969-9d9e-f60d3fa00d74/v1_efi.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	ba25c79a-6393-4969-9d9e-f60d3fa00d74.jpg	t	1	\N	2025-11-03 04:42:16.005339	2025-11-03 04:42:16.005339	\N	\N
b370351e-e862-4b25-acb6-a3828e2d7059	Manjaro.i686.png	Manjaro.i686.png	image/png	388	user_78c793b5-a705-403a-bec3-2cd04a654bb3/05b32b1c-c6a2-461a-b235-70c3823e54da/v1_Manjaro.i686.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	05b32b1c-c6a2-461a-b235-70c3823e54da.jpg	t	1	\N	2025-11-03 04:42:16.028246	2025-11-03 04:42:16.028246	\N	\N
33bbad4e-e5dc-4e42-a5bd-cbc6ad494384	solus.png	solus.png	image/png	1199	user_78c793b5-a705-403a-bec3-2cd04a654bb3/e3c28b62-2cdf-40a9-817f-ed8e69f87a0b/v1_solus.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	e3c28b62-2cdf-40a9-817f-ed8e69f87a0b.jpg	t	1	\N	2025-11-03 04:42:16.04858	2025-11-03 04:42:16.04858	\N	\N
4885b5d7-0b48-4061-a721-10279d3fbf69	kaos.png	kaos.png	image/png	995	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a4200590-8807-4548-9bdc-3f0c6bc982e8/v1_kaos.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	a4200590-8807-4548-9bdc-3f0c6bc982e8.jpg	t	1	\N	2025-11-03 04:42:16.06953	2025-11-03 04:42:16.06953	\N	\N
551acd30-e5d3-41d0-a336-a3a5cb8d9121	Manjaro.x86_64.png	Manjaro.x86_64.png	image/png	388	user_78c793b5-a705-403a-bec3-2cd04a654bb3/a252e489-8a09-482b-bf63-d1e632884463/v1_Manjaro.x86_64.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	a252e489-8a09-482b-bf63-d1e632884463.jpg	t	1	\N	2025-11-03 04:42:16.09133	2025-11-03 04:42:16.09133	\N	\N
33d19217-f3fa-4a9d-86e8-2cc057525618	driver.png	driver.png	image/png	793	user_78c793b5-a705-403a-bec3-2cd04a654bb3/2174ba22-c177-40c0-bea7-9b49b0583a07/v1_driver.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	2174ba22-c177-40c0-bea7-9b49b0583a07.jpg	t	1	\N	2025-11-03 04:42:16.112339	2025-11-03 04:42:16.112339	\N	\N
30111653-87c8-4d7a-a129-9f048c3168cf	siduction.png	siduction.png	image/png	1147	user_78c793b5-a705-403a-bec3-2cd04a654bb3/81dcdd91-fe10-4651-9b05-d1d123e2f9b4/v1_siduction.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	81dcdd91-fe10-4651-9b05-d1d123e2f9b4.jpg	t	1	\N	2025-11-03 04:42:16.13435	2025-11-03 04:42:16.13435	\N	\N
cfcfc277-ae47-415e-b85e-4e6720a2a4d8	fedora.png	fedora.png	image/png	1057	user_78c793b5-a705-403a-bec3-2cd04a654bb3/782bce7b-d244-4e48-bf1a-f44d2b3f08bc/v1_fedora.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	782bce7b-d244-4e48-bf1a-f44d2b3f08bc.jpg	t	1	\N	2025-11-03 04:42:16.156134	2025-11-03 04:42:16.156134	\N	\N
85176579-f940-4ecc-94b8-26b23a0d94f0	macosx.png	macosx.png	image/png	880	user_78c793b5-a705-403a-bec3-2cd04a654bb3/6090231d-b964-4f9b-8be4-a31ebabc06ad/v1_macosx.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	6090231d-b964-4f9b-8be4-a31ebabc06ad.jpg	t	1	\N	2025-11-03 04:42:16.176663	2025-11-03 04:42:16.176663	\N	\N
7526efb5-683a-4121-8cf7-3cac1a0c3124	xubuntu.png	xubuntu.png	image/png	1048	user_78c793b5-a705-403a-bec3-2cd04a654bb3/dfb9f8cb-65b8-44a4-8489-98ece0482943/v1_xubuntu.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	dfb9f8cb-65b8-44a4-8489-98ece0482943.jpg	t	1	\N	2025-11-03 04:42:16.199207	2025-11-03 04:42:16.199207	\N	\N
39f04fd0-d218-4325-bc62-726c5f72332b	terminus-16.pf2	terminus-16.pf2	application/octet-stream	24214	user_78c793b5-a705-403a-bec3-2cd04a654bb3/914ab96e-444a-4a1d-a6a2-6c41ca3b6563/v1_terminus-16.pf2	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:16.218467	2025-11-03 04:42:16.218467	\N	\N
6f0ab404-e4cb-48e8-a010-5e45e556a122	terminal_box_se.png	terminal_box_se.png	image/png	1102	user_78c793b5-a705-403a-bec3-2cd04a654bb3/547402d4-d015-4aad-afcc-7e977a19cb4f/v1_terminal_box_se.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	547402d4-d015-4aad-afcc-7e977a19cb4f.jpg	t	1	\N	2025-11-03 04:42:16.242424	2025-11-03 04:42:16.242424	\N	\N
15a7d5c8-08a1-4ef8-a6bc-d195ded3e477	theme.txt	theme.txt	text/plain	903	user_78c793b5-a705-403a-bec3-2cd04a654bb3/33e3e479-674f-419b-b8b9-5206b824f288/v1_theme.txt	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	\N	f	1	\N	2025-11-03 04:42:16.265593	2025-11-03 04:42:16.265593	\N	\N
87612912-2347-435a-be86-be77e1bfdd18	terminal_box_e.png	terminal_box_e.png	image/png	952	user_78c793b5-a705-403a-bec3-2cd04a654bb3/41571ceb-663c-4bb3-9a54-57505dfb9a15/v1_terminal_box_e.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	41571ceb-663c-4bb3-9a54-57505dfb9a15.jpg	t	1	\N	2025-11-03 04:42:16.289178	2025-11-03 04:42:16.289178	\N	\N
b78b8e3d-31f9-4786-842c-6a9a42b88a2f	select_e.png	select_e.png	image/png	289	user_78c793b5-a705-403a-bec3-2cd04a654bb3/29696639-a836-4bc4-b4be-30b0dc42ea64/v1_select_e.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	29696639-a836-4bc4-b4be-30b0dc42ea64.jpg	t	1	\N	2025-11-03 04:42:16.312702	2025-11-03 04:42:16.312702	\N	\N
6575da8e-d064-42aa-8779-28cb091644c9	terminal_box_sw.png	terminal_box_sw.png	image/png	1107	user_78c793b5-a705-403a-bec3-2cd04a654bb3/0472dfee-e49c-447b-bb8b-becb4f8b3f78/v1_terminal_box_sw.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	0472dfee-e49c-447b-bb8b-becb4f8b3f78.jpg	t	1	\N	2025-11-03 04:42:16.333575	2025-11-03 04:42:16.333575	\N	\N
a09e64e3-cdde-48a2-b436-7309e8d35525	terminal_box_n.png	terminal_box_n.png	image/png	963	user_78c793b5-a705-403a-bec3-2cd04a654bb3/47f04bce-91c5-4168-9cf3-5fc24ba2c1e5/v1_terminal_box_n.png	78c793b5-a705-403a-bec3-2cd04a654bb3	ba5144a3-ed87-411b-a7cd-91da00156f4e	active	f	47f04bce-91c5-4168-9cf3-5fc24ba2c1e5.jpg	t	1	\N	2025-11-03 04:42:16.356916	2025-11-03 04:42:16.356916	\N	\N
61f50571-7d17-4efb-85fc-d994b52f9e18	2025-04-15_20-37.png	2025-04-15_20-37.png	image/png	23606	user_78c793b5-a705-403a-bec3-2cd04a654bb3/83099836-6fc0-4c30-b484-1a7c5f5f13ea/v1_2025-04-15_20-37.png	78c793b5-a705-403a-bec3-2cd04a654bb3	4edbc827-8410-4644-8a85-1d6873c9eff3	active	f	83099836-6fc0-4c30-b484-1a7c5f5f13ea.jpg	t	1	\N	2025-11-03 04:42:46.417841	2025-11-03 04:42:46.417841	\N	\N
3d63e431-b733-406d-a2a7-c1ad5139b2cb	Screenshot_02-Nov_14-34-24_3960.png	Screenshot_02-Nov_14-34-24_3960.png	image/png	6323	user_78c793b5-a705-403a-bec3-2cd04a654bb3/e7a9bb39-ce7b-494e-8dbd-b899ab5b4287/v1_Screenshot_02-Nov_14-34-24_3960.png	78c793b5-a705-403a-bec3-2cd04a654bb3	4edbc827-8410-4644-8a85-1d6873c9eff3	active	f	e7a9bb39-ce7b-494e-8dbd-b899ab5b4287.jpg	t	1	\N	2025-11-03 04:42:58.655238	2025-11-03 04:42:58.655238	\N	\N
2179ed99-bef1-49ad-8ee1-a8f42e8cd8d8	Screenshot_01-Oct_20-55-34_1945.png	Screenshot_01-Oct_20-55-34_1945.png	image/png	29262	user_78c793b5-a705-403a-bec3-2cd04a654bb3/2d8fbd89-0488-4e73-a1ca-ad2b7ce856e4/v1_Screenshot_01-Oct_20-55-34_1945.png	78c793b5-a705-403a-bec3-2cd04a654bb3	4edbc827-8410-4644-8a85-1d6873c9eff3	active	f	2d8fbd89-0488-4e73-a1ca-ad2b7ce856e4.jpg	t	1	\N	2025-11-03 04:43:04.844371	2025-11-03 04:43:04.844371	\N	\N
85f445e5-a8a9-42d5-8a3a-8e3bb8e2d4c1	braces.png	braces.png	image/png	1424843	user_78c793b5-a705-403a-bec3-2cd04a654bb3/d22b5f4c-8202-49af-9c33-8e3b35244337/v1_braces.png	78c793b5-a705-403a-bec3-2cd04a654bb3	4edbc827-8410-4644-8a85-1d6873c9eff3	active	f	d22b5f4c-8202-49af-9c33-8e3b35244337.jpg	t	1	\N	2025-11-03 04:43:09.712746	2025-11-03 04:43:09.712746	\N	\N
fe796dd7-b5e8-44c1-a296-25a36055c4a7	Screenshot_02-Oct_16-32-22_5891.png	Screenshot_02-Oct_16-32-22_5891.png	image/png	122298	user_78c793b5-a705-403a-bec3-2cd04a654bb3/39555f7f-5b4c-4eaf-b0b9-80a786ad3027/v1_Screenshot_02-Oct_16-32-22_5891.png	78c793b5-a705-403a-bec3-2cd04a654bb3	4edbc827-8410-4644-8a85-1d6873c9eff3	active	f	39555f7f-5b4c-4eaf-b0b9-80a786ad3027.jpg	t	1	\N	2025-11-03 04:43:15.587527	2025-11-03 04:43:15.587527	\N	\N
5c555b40-3e96-4c1f-ae35-5d6ac5a30985	16-May_22-16-01-2025.png	16-May_22-16-01-2025.png	image/png	260844	user_78c793b5-a705-403a-bec3-2cd04a654bb3/7ce2bb4c-e5f6-49e5-81ac-5c0976f7908a/v1_16-May_22-16-01-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	4edbc827-8410-4644-8a85-1d6873c9eff3	active	f	7ce2bb4c-e5f6-49e5-81ac-5c0976f7908a.jpg	t	1	\N	2025-11-03 04:43:31.704881	2025-11-03 04:43:31.704881	\N	\N
e060acac-8fdf-478b-b408-3f2b23447883	22-July_16-53-05-2025.png	22-July_16-53-05-2025.png	image/png	364643	user_78c793b5-a705-403a-bec3-2cd04a654bb3/101099bc-56b2-4f0b-bcda-d2f131ea5f28/v1_22-July_16-53-05-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	a2b2462a-8c94-4851-81a9-e234f0309f80	trashed	f	101099bc-56b2-4f0b-bcda-d2f131ea5f28.jpg	t	1	\N	2025-11-03 04:44:05.859203	2025-11-03 04:44:05.859203	2025-11-03 04:44:12.754849	2025-11-03 04:44:09.556163
5a204d25-4430-4ecc-a41a-26ee160c4a64	 5-May_16-50-20-2025.png	 5-May_16-50-20-2025.png	image/png	392995	user_78c793b5-a705-403a-bec3-2cd04a654bb3/01e87fb3-0b50-4932-8618-5d68b49efdd0/v1_ 5-May_16-50-20-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	a2b2462a-8c94-4851-81a9-e234f0309f80	active	f	01e87fb3-0b50-4932-8618-5d68b49efdd0.jpg	t	1	\N	2025-11-03 04:43:36.366241	2025-11-03 04:43:36.366241	\N	2025-11-03 04:43:37.415008
b01754da-b54b-406f-bf00-823adc3d6988	 6-June_19-40-09-2025.png	 6-June_19-40-09-2025.png	image/png	436303	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c80f73c2-0b6f-4d84-b868-a8a3a1b1867e/v1_ 6-June_19-40-09-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	a2b2462a-8c94-4851-81a9-e234f0309f80	active	f	c80f73c2-0b6f-4d84-b868-a8a3a1b1867e.jpg	t	1	\N	2025-11-03 04:43:47.734186	2025-11-03 04:43:47.734186	\N	\N
2c33ef82-7c4d-4183-a2c5-235d57add03d	24-June_19-47-39-2025.png	24-June_19-47-39-2025.png	image/png	862385	user_78c793b5-a705-403a-bec3-2cd04a654bb3/3d9dbca8-dab0-4740-9f22-3e0b7ce01427/v1_24-June_19-47-39-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	a2b2462a-8c94-4851-81a9-e234f0309f80	active	f	3d9dbca8-dab0-4740-9f22-3e0b7ce01427.jpg	t	1	\N	2025-11-03 04:43:54.146707	2025-11-03 04:43:54.146707	\N	\N
aae3354a-e90c-431d-ba2e-347c26e3e60b	11-July_12-51-07-2025.png	11-July_12-51-07-2025.png	image/png	807176	user_78c793b5-a705-403a-bec3-2cd04a654bb3/766579fa-1673-491b-81e5-98805c20ad00/v1_11-July_12-51-07-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	a2b2462a-8c94-4851-81a9-e234f0309f80	active	f	766579fa-1673-491b-81e5-98805c20ad00.jpg	t	1	\N	2025-11-03 04:43:57.653809	2025-11-03 04:43:57.653809	\N	\N
603ca557-7647-4579-ad46-167f31cd83a4	23-May_03-53-35-2025.png	23-May_03-53-35-2025.png	image/png	22755	user_78c793b5-a705-403a-bec3-2cd04a654bb3/c7e0c1b9-595f-4c49-b87b-c6f54abf341c/v1_23-May_03-53-35-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	a2b2462a-8c94-4851-81a9-e234f0309f80	trashed	f	c7e0c1b9-595f-4c49-b87b-c6f54abf341c.jpg	t	1	\N	2025-11-03 04:43:41.494538	2025-11-03 04:43:41.494538	2025-11-03 04:44:15.070736	\N
7a29d2a3-4abb-47ba-a074-33dd191c7bb8	Screenshot_15-Jul_13-08-34_1498.png	Screenshot_15-Jul_13-08-34_1498.png	image/png	1251719	user_78c793b5-a705-403a-bec3-2cd04a654bb3/98fe3c11-e63f-44d7-9277-799e497f226b/v1_Screenshot_15-Jul_13-08-34_1498.png	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	active	f	98fe3c11-e63f-44d7-9277-799e497f226b.jpg	t	1	\N	2025-11-03 04:44:42.91274	2025-11-03 04:44:42.91274	\N	\N
1e6995a7-9f4d-4276-a7d1-96d4275d7011	18-July_12-30-07-2025.png	18-July_12-30-07-2025.png	image/png	848047	user_78c793b5-a705-403a-bec3-2cd04a654bb3/874eac16-38f2-40c3-b405-f15f9c2df218/v1_18-July_12-30-07-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	trashed	f	874eac16-38f2-40c3-b405-f15f9c2df218.jpg	t	1	\N	2025-11-03 04:44:34.363377	2025-11-03 04:44:34.363377	2025-11-03 04:44:40.770725	2025-11-03 04:44:35.778814
af2c523a-01e6-45df-a7b7-79a85d7d65a4	Screenshot_13-Jul_14-52-40_5508.png	Screenshot_13-Jul_14-52-40_5508.png	image/png	1233235	user_78c793b5-a705-403a-bec3-2cd04a654bb3/56f758a0-dc81-40d8-9068-3617637ac1e1/v1_Screenshot_13-Jul_14-52-40_5508.png	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	active	f	56f758a0-dc81-40d8-9068-3617637ac1e1.jpg	t	1	\N	2025-11-03 04:44:48.738194	2025-11-03 04:44:48.738194	\N	2025-11-03 04:44:50.187634
5ef67e06-9eeb-4c22-a712-27a3e1cd7c34	Rebuttal_Sentence_Stems.pdf	Rebuttal_Sentence_Stems.pdf	application/pdf	2437	user_78c793b5-a705-403a-bec3-2cd04a654bb3/83f0b4ca-91c3-4643-b933-f6e4daac706f/v1_Rebuttal_Sentence_Stems.pdf	78c793b5-a705-403a-bec3-2cd04a654bb3	3a997056-57b2-4560-9e0b-f72a41ce73c0	active	f	\N	t	1	\N	2025-11-03 04:45:29.595934	2025-11-03 04:45:29.595934	\N	\N
8c1a933e-dab4-4c83-b81d-30fb912ac1e7	Debate (1).pdf	Debate (1).pdf	application/pdf	1003429	user_78c793b5-a705-403a-bec3-2cd04a654bb3/3f67457a-7817-4cd6-8114-b571420e959e/v1_Debate (1).pdf	78c793b5-a705-403a-bec3-2cd04a654bb3	3a997056-57b2-4560-9e0b-f72a41ce73c0	active	f	\N	t	1	\N	2025-11-03 04:45:31.494569	2025-11-03 04:45:31.494569	\N	\N
144cb4bc-5228-4d95-af0a-69b28fc2503c	25-June_20-33-10-2025.png	25-June_20-33-10-2025.png	image/png	561176	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4b252c62-b6a6-4701-b16f-8f9cfb85b92b/v1_25-June_20-33-10-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	active	t	4b252c62-b6a6-4701-b16f-8f9cfb85b92b.jpg	t	1	\N	2025-11-03 04:44:59.920427	2025-11-03 04:46:03.881129	\N	2025-11-03 04:45:01.164637
d4c6301f-b510-4880-9294-331b9ae4e70a	Sounds of English Consonant Sounds.pdf	Sounds of English Consonant Sounds.pdf	application/pdf	164419	user_78c793b5-a705-403a-bec3-2cd04a654bb3/4e0a2833-848f-4279-8e96-41302b811367/v1_Sounds of English Consonant Sounds.pdf	78c793b5-a705-403a-bec3-2cd04a654bb3	3a997056-57b2-4560-9e0b-f72a41ce73c0	active	f	\N	t	1	\N	2025-11-03 04:45:35.005011	2025-11-03 04:45:35.005011	\N	\N
67d595db-eaff-4554-a5ad-ad2ac532516d	Language-On-Schools-English-Irregular-Verbs-List (1).pdf	Language-On-Schools-English-Irregular-Verbs-List (1).pdf	application/pdf	71999	user_78c793b5-a705-403a-bec3-2cd04a654bb3/55a35a77-73db-4ce5-bc13-b9ccceecb45d/v1_Language-On-Schools-English-Irregular-Verbs-List (1).pdf	78c793b5-a705-403a-bec3-2cd04a654bb3	3a997056-57b2-4560-9e0b-f72a41ce73c0	active	f	\N	t	1	\N	2025-11-03 04:45:37.774128	2025-11-03 04:45:37.774128	\N	\N
4e090b4c-c8ef-49a3-ac21-9a4338383c4e	notely-474107-b7a125a8fdaf.json	notely-474107-b7a125a8fdaf.json	application/json	2369	user_78c793b5-a705-403a-bec3-2cd04a654bb3/21cb4e9b-ff0e-4b3a-9f45-154d3f4e4722/v1_notely-474107-b7a125a8fdaf.json	78c793b5-a705-403a-bec3-2cd04a654bb3	3a997056-57b2-4560-9e0b-f72a41ce73c0	active	f	\N	f	1	\N	2025-11-03 04:45:39.814273	2025-11-03 04:45:39.814273	\N	\N
253191cd-3da4-4b80-8101-d9eec2c78689	Expressions for Discussion and Debate new.pdf	Expressions for Discussion and Debate new.pdf	application/pdf	36912	user_78c793b5-a705-403a-bec3-2cd04a654bb3/f2a3e506-1046-497a-9d93-cd9fedb96148/v1_Expressions for Discussion and Debate new.pdf	78c793b5-a705-403a-bec3-2cd04a654bb3	3a997056-57b2-4560-9e0b-f72a41ce73c0	active	f	\N	t	1	\N	2025-11-03 04:45:43.14604	2025-11-03 04:45:43.14604	\N	\N
b31ca8ec-1952-4ab6-bc1d-9448d9f0fd24	23-May_03-53-35-2025.png	23-May_03-53-35-2025.png	image/png	22755	user_78c793b5-a705-403a-bec3-2cd04a654bb3/37be7a2e-9f2f-49ff-8cca-981f0b315e81/v1_23-May_03-53-35-2025.png	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	active	t	37be7a2e-9f2f-49ff-8cca-981f0b315e81.jpg	t	1	\N	2025-11-03 04:45:09.658645	2025-11-03 04:46:02.091783	\N	\N
9dd7a41d-86d3-4f7c-a68e-47a715463aa7	Screenshot from 2024-12-10 18-37-15.png	Screenshot from 2024-12-10 18-37-15.png	image/png	37623	user_78c793b5-a705-403a-bec3-2cd04a654bb3/02c1ae7e-c88c-4b2e-a4db-a556bf0b642c/v1_Screenshot from 2024-12-10 18-37-15.png	78c793b5-a705-403a-bec3-2cd04a654bb3	02f4d329-ac4d-4f9d-b7b5-32081928e0cf	active	t	02c1ae7e-c88c-4b2e-a4db-a556bf0b642c.jpg	t	1	\N	2025-11-03 04:41:27.176703	2025-11-03 04:46:07.089139	\N	\N
\.


--
-- Data for Name: folders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.folders (id, name, owner_id, parent_folder_id, is_root, status, is_starred, created_at, updated_at, trashed_at) FROM stdin;
b30e320e-8b0d-468f-a142-e88a42b3b3de	My Drive	f151587c-cf86-4586-a9ed-4d842b52369c	\N	t	active	f	2025-11-03 04:35:22.333055	2025-11-03 04:35:22.333055	\N
29efd2e4-99b9-4fd0-bf4d-470b38c3475f	My Drive	baf466cc-5098-46aa-9d2b-c994ec769911	\N	t	active	f	2025-11-03 04:36:39.765293	2025-11-03 04:36:39.765293	\N
dd11b2d6-b2b8-4a66-b466-076558bccb47	My Drive	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	t	active	f	2025-11-03 04:39:58.633532	2025-11-03 04:39:58.633532	\N
3a997056-57b2-4560-9e0b-f72a41ce73c0	Docs	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	f	active	f	2025-11-03 04:40:18.199545	2025-11-03 04:40:18.199545	\N
4edbc827-8410-4644-8a85-1d6873c9eff3	Photo	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	f	active	f	2025-11-03 04:40:29.812681	2025-11-03 04:40:29.812681	\N
02f4d329-ac4d-4f9d-b7b5-32081928e0cf	Music	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	f	active	f	2025-11-03 04:40:33.914839	2025-11-03 04:40:33.914839	\N
ba5144a3-ed87-411b-a7cd-91da00156f4e	Backup	78c793b5-a705-403a-bec3-2cd04a654bb3	\N	f	active	f	2025-11-03 04:40:40.255168	2025-11-03 04:40:40.255168	\N
a2b2462a-8c94-4851-81a9-e234f0309f80	Screenshot	78c793b5-a705-403a-bec3-2cd04a654bb3	4edbc827-8410-4644-8a85-1d6873c9eff3	f	active	f	2025-11-03 04:42:54.409271	2025-11-03 04:42:54.409271	\N
\.


--
-- Data for Name: goose_db_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.goose_db_version (id, version_id, is_applied, tstamp) FROM stdin;
1	0	t	2025-11-03 04:34:57.28887
2	1	t	2025-11-03 04:34:57.325506
3	2	t	2025-11-03 04:34:57.348061
4	3	t	2025-11-03 04:34:57.372171
5	4	t	2025-11-03 04:34:57.392578
6	5	t	2025-11-03 04:34:57.427613
7	6	t	2025-11-03 04:34:57.444292
8	7	t	2025-11-03 04:34:57.46706
9	8	t	2025-11-03 04:34:57.486665
10	9	t	2025-11-03 04:34:57.505658
11	10	t	2025-11-03 04:34:57.55412
12	11	t	2025-11-03 04:34:57.57514
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, item_type, item_id, user_id, role, granted_by, created_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, user_id, token, expires_at, created_at) FROM stdin;
2c076c0f-1166-42cc-9df9-bf39415c9812	f151587c-cf86-4586-a9ed-4d842b52369c	586cd0a47a14ee19da2f9c1288a422f8ce7687026b6f4ddeb5302d3468ef18b6	2025-12-03 04:35:22.335962	2025-11-03 04:35:22.336198
71eacc63-35fc-459b-9116-2877d0be5269	baf466cc-5098-46aa-9d2b-c994ec769911	5f6ea5f31178fa6d9b2c19ff324cee63b9fe5ec8a57b1c628f981f1a0f7662d5	2025-12-03 04:36:39.767781	2025-11-03 04:36:39.767836
2151f7c8-2bb2-4210-aee1-3539061523a8	78c793b5-a705-403a-bec3-2cd04a654bb3	cd993ca61818d29e19b91ffd4acee3b49ff9b51455525e1a84671d56b6e99479	2025-12-03 04:39:58.637007	2025-11-03 04:39:58.637143
\.


--
-- Data for Name: shares; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shares (id, item_type, item_id, token, created_by, permission, expires_at, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, hashed_password, name, storage_used, storage_limit, created_at, updated_at) FROM stdin;
f151587c-cf86-4586-a9ed-4d842b52369c	user@example.com	$2a$10$jD4T.MxtUGh6dvjbOo7J1u7Bzp/pi6M1ss/LGnNwERD4vxE3f/BKy	Test User	0	16106127360	2025-11-03 04:35:22.326214	2025-11-03 04:35:22.326214
baf466cc-5098-46aa-9d2b-c994ec769911	shri@gmail.com	$2a$10$bJLh36z/mOTt1EIWzR0eLO1HIc7i2r6SgMhdBP45nKhrYRswPhWlm	shrikant	0	16106127360	2025-11-03 04:36:39.759061	2025-11-03 04:36:39.759061
78c793b5-a705-403a-bec3-2cd04a654bb3	dummy@tst.com	$2a$10$anmyqOD.ZuaMgm/M.w9Ttui.ZdLRrrEZ97ol.zVksecXi0tobkW16	dummy	61427049	16106127360	2025-11-03 04:39:58.6101	2025-11-03 04:45:43.151646
\.


--
-- Name: goose_db_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.goose_db_version_id_seq', 12, true);


--
-- Name: activity_log activity_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: file_versions file_versions_file_id_version_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_versions
    ADD CONSTRAINT file_versions_file_id_version_number_key UNIQUE (file_id, version_number);


--
-- Name: file_versions file_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_versions
    ADD CONSTRAINT file_versions_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: folders folders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (id);


--
-- Name: goose_db_version goose_db_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goose_db_version
    ADD CONSTRAINT goose_db_version_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_item_type_item_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_item_type_item_id_user_id_key UNIQUE (item_type, item_id, user_id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_token_key UNIQUE (token);


--
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: shares shares_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_token_key UNIQUE (token);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_activity_file; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_file ON public.activity_log USING btree (file_id);


--
-- Name: idx_activity_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_user ON public.activity_log USING btree (user_id, created_at DESC);


--
-- Name: idx_comments_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_created_at ON public.comments USING btree (created_at DESC);


--
-- Name: idx_comments_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_file_id ON public.comments USING btree (file_id);


--
-- Name: idx_comments_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_user_id ON public.comments USING btree (user_id);


--
-- Name: idx_file_versions_file; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_file_versions_file ON public.file_versions USING btree (file_id);


--
-- Name: idx_files_name_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_name_search ON public.files USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: idx_files_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_owner ON public.files USING btree (owner_id);


--
-- Name: idx_files_parent_folder; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_parent_folder ON public.files USING btree (parent_folder_id);


--
-- Name: idx_files_starred; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_starred ON public.files USING btree (is_starred) WHERE (is_starred = true);


--
-- Name: idx_files_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_status ON public.files USING btree (status);


--
-- Name: idx_files_trashed_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_trashed_at ON public.files USING btree (trashed_at) WHERE (status = 'trashed'::public.file_status);


--
-- Name: idx_folders_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_folders_owner ON public.folders USING btree (owner_id);


--
-- Name: idx_folders_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_folders_parent ON public.folders USING btree (parent_folder_id);


--
-- Name: idx_folders_trashed_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_folders_trashed_at ON public.folders USING btree (trashed_at) WHERE (status = 'trashed'::public.file_status);


--
-- Name: idx_permissions_item; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_permissions_item ON public.permissions USING btree (item_type, item_id);


--
-- Name: idx_permissions_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_permissions_user ON public.permissions USING btree (user_id);


--
-- Name: idx_sessions_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_token ON public.sessions USING btree (token);


--
-- Name: idx_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_user_id ON public.sessions USING btree (user_id);


--
-- Name: idx_shares_item; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shares_item ON public.shares USING btree (item_type, item_id);


--
-- Name: idx_shares_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shares_token ON public.shares USING btree (token);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: activity_log activity_log_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: activity_log activity_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: comments comments_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: file_versions file_versions_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_versions
    ADD CONSTRAINT file_versions_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: file_versions file_versions_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_versions
    ADD CONSTRAINT file_versions_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: files files_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: files files_parent_folder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_parent_folder_id_fkey FOREIGN KEY (parent_folder_id) REFERENCES public.folders(id) ON DELETE SET NULL;


--
-- Name: folders folders_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: folders folders_parent_folder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_parent_folder_id_fkey FOREIGN KEY (parent_folder_id) REFERENCES public.folders(id) ON DELETE CASCADE;


--
-- Name: permissions permissions_granted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES public.users(id);


--
-- Name: permissions permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shares shares_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict IhvrUexkeiDScVKBFhKOyVzfDW90NAyylj6HnoxxglgoC4J1s6dJXw23XqeBtxt

