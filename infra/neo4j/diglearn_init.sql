--
-- PostgreSQL database dump
--

\restrict WTpQ1eVCPPRUCyErcbvlcF3GrrDSo1RBU71BKWeyabFzg98OuxV07QYwzaQ93Lm

-- Dumped from database version 16.11 (Debian 16.11-1.pgdg12+1)
-- Dumped by pg_dump version 16.11 (Debian 16.11-1.pgdg12+1)

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

ALTER TABLE IF EXISTS ONLY public.level_kp_ids DROP CONSTRAINT IF EXISTS fkp0nnxideac4ma86nv4vqy3q0a;
ALTER TABLE IF EXISTS ONLY public.level_test_cases DROP CONSTRAINT IF EXISTS fkkmlxih421wunodkv9wioag86u;
ALTER TABLE IF EXISTS ONLY public.tag_kp_map DROP CONSTRAINT IF EXISTS fk_tag_kp_map_tag;
ALTER TABLE IF EXISTS ONLY public.level_allowed_components DROP CONSTRAINT IF EXISTS fk8jyr7srp15tgof3nfd091i25o;
ALTER TABLE IF EXISTS ONLY public.level_test_steps DROP CONSTRAINT IF EXISTS fk4t7ce7skdlrwoymhajnurjvuy;
DROP INDEX IF EXISTS public.uk_level_pass_user_level;
DROP INDEX IF EXISTS public.ix_level_pass_user;
DROP INDEX IF EXISTS public.idx_uqs_user_mastered;
DROP INDEX IF EXISTS public.idx_tag_kp_map_tag_id;
DROP INDEX IF EXISTS public.idx_tag_kp_map_kp_id;
DROP INDEX IF EXISTS public.idx_questions_type;
DROP INDEX IF EXISTS public.idx_questions_status;
DROP INDEX IF EXISTS public.idx_questions_pool;
DROP INDEX IF EXISTS public.idx_questions_difficulty;
DROP INDEX IF EXISTS public.idx_qtm_tag_id;
DROP INDEX IF EXISTS public.idx_cm_student_status;
DROP INDEX IF EXISTS public.idx_cm_class_status;
DROP INDEX IF EXISTS public.idx_classes_teacher;
DROP INDEX IF EXISTS public.idx_attempt_user_question;
DROP INDEX IF EXISTS public.idx_attempt_user_mode;
ALTER TABLE IF EXISTS ONLY public.user_question_state DROP CONSTRAINT IF EXISTS user_question_state_pkey;
ALTER TABLE IF EXISTS ONLY public.user_question_state DROP CONSTRAINT IF EXISTS uk_user_question_state;
ALTER TABLE IF EXISTS ONLY public.level_test_steps DROP CONSTRAINT IF EXISTS uk_test_step_index;
ALTER TABLE IF EXISTS ONLY public.tags DROP CONSTRAINT IF EXISTS uk_tags_name;
ALTER TABLE IF EXISTS ONLY public.tag_kp_map DROP CONSTRAINT IF EXISTS uk_tag_kp_map_tag_kp;
ALTER TABLE IF EXISTS ONLY public.question_tag_map DROP CONSTRAINT IF EXISTS uk_question_tag;
ALTER TABLE IF EXISTS ONLY public.level_test_cases DROP CONSTRAINT IF EXISTS uk_level_test_case_order;
ALTER TABLE IF EXISTS ONLY public.class_membership DROP CONSTRAINT IF EXISTS uk_class_membership;
ALTER TABLE IF EXISTS ONLY public.app_users DROP CONSTRAINT IF EXISTS uk_app_users_username;
ALTER TABLE IF EXISTS ONLY public.app_users DROP CONSTRAINT IF EXISTS uk_app_users_email;
ALTER TABLE IF EXISTS ONLY public.teacher_requests DROP CONSTRAINT IF EXISTS teacher_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.tags DROP CONSTRAINT IF EXISTS tags_pkey;
ALTER TABLE IF EXISTS ONLY public.questions DROP CONSTRAINT IF EXISTS questions_pkey;
ALTER TABLE IF EXISTS ONLY public.question_attempts DROP CONSTRAINT IF EXISTS question_attempts_pkey;
ALTER TABLE IF EXISTS ONLY public.persistent_logins DROP CONSTRAINT IF EXISTS persistent_logins_pkey;
ALTER TABLE IF EXISTS ONLY public.levels DROP CONSTRAINT IF EXISTS levels_pkey;
ALTER TABLE IF EXISTS ONLY public.level_test_steps DROP CONSTRAINT IF EXISTS level_test_steps_pkey;
ALTER TABLE IF EXISTS ONLY public.level_test_cases DROP CONSTRAINT IF EXISTS level_test_cases_pkey;
ALTER TABLE IF EXISTS ONLY public.level_pass_records DROP CONSTRAINT IF EXISTS level_pass_records_pkey;
ALTER TABLE IF EXISTS ONLY public.level_kp_ids DROP CONSTRAINT IF EXISTS level_kp_ids_pkey;
ALTER TABLE IF EXISTS ONLY public.level_allowed_components DROP CONSTRAINT IF EXISTS level_allowed_components_pkey;
ALTER TABLE IF EXISTS ONLY public.classes DROP CONSTRAINT IF EXISTS classes_pkey;
ALTER TABLE IF EXISTS ONLY public.class_membership DROP CONSTRAINT IF EXISTS class_membership_pkey;
ALTER TABLE IF EXISTS ONLY public.app_users DROP CONSTRAINT IF EXISTS app_users_pkey;
SELECT pg_catalog.lo_unlink(oid) FROM pg_catalog.pg_largeobject_metadata WHERE oid = '24780';
SELECT pg_catalog.lo_unlink(oid) FROM pg_catalog.pg_largeobject_metadata WHERE oid = '24779';
SELECT pg_catalog.lo_unlink(oid) FROM pg_catalog.pg_largeobject_metadata WHERE oid = '24778';
SELECT pg_catalog.lo_unlink(oid) FROM pg_catalog.pg_largeobject_metadata WHERE oid = '16548';
ALTER TABLE IF EXISTS public.level_pass_records ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS public.user_question_state;
DROP TABLE IF EXISTS public.teacher_requests;
DROP TABLE IF EXISTS public.tags;
DROP TABLE IF EXISTS public.tag_kp_map;
DROP TABLE IF EXISTS public.questions;
DROP TABLE IF EXISTS public.question_tag_map;
DROP TABLE IF EXISTS public.question_attempts;
DROP TABLE IF EXISTS public.persistent_logins;
DROP TABLE IF EXISTS public.levels;
DROP TABLE IF EXISTS public.level_test_steps;
DROP TABLE IF EXISTS public.level_test_cases;
DROP SEQUENCE IF EXISTS public.level_pass_records_id_seq;
DROP TABLE IF EXISTS public.level_pass_records;
DROP TABLE IF EXISTS public.level_kp_ids;
DROP TABLE IF EXISTS public.level_allowed_components;
DROP TABLE IF EXISTS public.classes;
DROP TABLE IF EXISTS public.class_membership;
DROP TABLE IF EXISTS public.app_users;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_users (
    user_id character varying(128) NOT NULL,
    email character varying(254) NOT NULL,
    name character varying(128) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(20) NOT NULL,
    username character varying(64) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    CONSTRAINT app_users_role_check CHECK (((role)::text = ANY ((ARRAY['STUDENT'::character varying, 'TEACHER'::character varying, 'ADMIN'::character varying])::text[])))
);


ALTER TABLE public.app_users OWNER TO postgres;

--
-- Name: class_membership; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_membership (
    id uuid NOT NULL,
    class_id uuid NOT NULL,
    decided_at timestamp(6) with time zone,
    decided_by character varying(128),
    requested_at timestamp(6) with time zone NOT NULL,
    status character varying(16) NOT NULL,
    student_id character varying(128) NOT NULL,
    CONSTRAINT class_membership_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying])::text[])))
);


ALTER TABLE public.class_membership OWNER TO postgres;

--
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classes (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    name character varying(200) NOT NULL,
    teacher_id character varying(128) NOT NULL
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- Name: level_allowed_components; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.level_allowed_components (
    level_code character varying(64) NOT NULL,
    component character varying(64) NOT NULL
);


ALTER TABLE public.level_allowed_components OWNER TO postgres;

--
-- Name: level_kp_ids; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.level_kp_ids (
    level_code character varying(64) NOT NULL,
    kp_id character varying(64) NOT NULL
);


ALTER TABLE public.level_kp_ids OWNER TO postgres;

--
-- Name: level_pass_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.level_pass_records (
    id bigint NOT NULL,
    user_id character varying(128) NOT NULL,
    level_code character varying(64) NOT NULL,
    first_passed_at timestamp with time zone NOT NULL,
    last_passed_at timestamp with time zone NOT NULL,
    pass_count integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.level_pass_records OWNER TO postgres;

--
-- Name: level_pass_records_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.level_pass_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.level_pass_records_id_seq OWNER TO postgres;

--
-- Name: level_pass_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.level_pass_records_id_seq OWNED BY public.level_pass_records.id;


--
-- Name: level_test_cases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.level_test_cases (
    id uuid NOT NULL,
    name character varying(200),
    order_index integer NOT NULL,
    level_code character varying(64) NOT NULL
);


ALTER TABLE public.level_test_cases OWNER TO postgres;

--
-- Name: level_test_steps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.level_test_steps (
    id uuid NOT NULL,
    expected_json text NOT NULL,
    inputs_json text NOT NULL,
    step_index integer NOT NULL,
    test_case_id uuid NOT NULL
);


ALTER TABLE public.level_test_steps OWNER TO postgres;

--
-- Name: levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.levels (
    code character varying(64) NOT NULL,
    description text,
    template_circuit_json text,
    title character varying(200) NOT NULL,
    devices text,
    allow_cycles boolean DEFAULT false NOT NULL
);


ALTER TABLE public.levels OWNER TO postgres;

--
-- Name: persistent_logins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persistent_logins (
    username character varying(64) NOT NULL,
    series character varying(64) NOT NULL,
    token character varying(64) NOT NULL,
    last_used timestamp without time zone NOT NULL
);


ALTER TABLE public.persistent_logins OWNER TO postgres;

--
-- Name: question_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.question_attempts (
    id uuid NOT NULL,
    context_kp_id character varying(64),
    is_correct boolean,
    mode character varying(20) NOT NULL,
    question_id uuid NOT NULL,
    source_question_id uuid,
    submitted_at timestamp(6) with time zone NOT NULL,
    user_answer jsonb NOT NULL,
    user_id character varying(128) NOT NULL,
    CONSTRAINT question_attempts_mode_check CHECK (((mode)::text = ANY ((ARRAY['CHAPTER'::character varying, 'RECOMMENDED'::character varying, 'REINFORCEMENT'::character varying])::text[])))
);


ALTER TABLE public.question_attempts OWNER TO postgres;

--
-- Name: question_tag_map; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.question_tag_map (
    question_id uuid NOT NULL,
    tag_id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    weight integer NOT NULL
);


ALTER TABLE public.question_tag_map OWNER TO postgres;

--
-- Name: questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.questions (
    id uuid NOT NULL,
    content jsonb NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    difficulty smallint NOT NULL,
    explanation text,
    lang character varying(10) NOT NULL,
    solution jsonb,
    status character varying(20) NOT NULL,
    stem text NOT NULL,
    type character varying(40) NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    question_pool character varying(20) DEFAULT 'SUPPLEMENT'::character varying NOT NULL,
    CONSTRAINT questions_status_check CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'PUBLISHED'::character varying])::text[]))),
    CONSTRAINT questions_type_check CHECK (((type)::text = ANY ((ARRAY['SINGLE_CHOICE'::character varying, 'MULTI_CHOICE'::character varying, 'SHORT_ANSWER'::character varying])::text[])))
);


ALTER TABLE public.questions OWNER TO postgres;

--
-- Name: COLUMN questions.question_pool; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.questions.question_pool IS 'CHAPTER=章节核心练习(3道/KP); SUPPLEMENT=巩固补充题(≥5道/KP); EXAM=综合模考题';


--
-- Name: tag_kp_map; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tag_kp_map (
    kp_id character varying(64) NOT NULL,
    weight integer NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.tag_kp_map OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    id uuid NOT NULL,
    description text,
    name character varying(64) NOT NULL
);


ALTER TABLE public.tags OWNER TO postgres;

--
-- Name: teacher_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_requests (
    user_id character varying(128) NOT NULL,
    decided_at timestamp(6) with time zone,
    requested_at timestamp(6) with time zone NOT NULL,
    status character varying(16) NOT NULL,
    CONSTRAINT teacher_requests_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying])::text[])))
);


ALTER TABLE public.teacher_requests OWNER TO postgres;

--
-- Name: user_question_state; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_question_state (
    id uuid NOT NULL,
    last_attempt_at timestamp(6) with time zone,
    last_wrong_at timestamp(6) with time zone,
    mastered boolean NOT NULL,
    question_id uuid NOT NULL,
    user_id character varying(128) NOT NULL,
    wrong_count integer NOT NULL
);


ALTER TABLE public.user_question_state OWNER TO postgres;

--
-- Name: level_pass_records id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_pass_records ALTER COLUMN id SET DEFAULT nextval('public.level_pass_records_id_seq'::regclass);


--
-- Name: 16548; Type: BLOB; Schema: -; Owner: postgres
--

SELECT pg_catalog.lo_create('16548');


ALTER LARGE OBJECT 16548 OWNER TO postgres;

--
-- Name: 24778; Type: BLOB; Schema: -; Owner: postgres
--

SELECT pg_catalog.lo_create('24778');


ALTER LARGE OBJECT 24778 OWNER TO postgres;

--
-- Name: 24779; Type: BLOB; Schema: -; Owner: postgres
--

SELECT pg_catalog.lo_create('24779');


ALTER LARGE OBJECT 24779 OWNER TO postgres;

--
-- Name: 24780; Type: BLOB; Schema: -; Owner: postgres
--

SELECT pg_catalog.lo_create('24780');


ALTER LARGE OBJECT 24780 OWNER TO postgres;

--
-- Data for Name: app_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.app_users (user_id, email, name, password_hash, role, username, enabled) VALUES ('4f03d15d-8916-4c81-a1b2-4b251a50d1ac', 'admin@example.com', 'administrator', '{bcrypt}$2a$10$uOuAi/oE5jDgTgspE4JbE.rTpZw4QpMY5gEUICjVmnzvlDk7gUqd6', 'ADMIN', 'admin', true);
INSERT INTO public.app_users (user_id, email, name, password_hash, role, username, enabled) VALUES ('f286e1e3-9bb1-41ae-b7e9-dbc7ef9c8b1d', 'tom@example.edu.cn', 'Tom', '{bcrypt}$2a$10$X8qbfk5Nz7IDYu1rQEHRY.6c43on5cvDvCIhiwB7HkopfInTOCxPG', 'STUDENT', 'tom', true);
INSERT INTO public.app_users (user_id, email, name, password_hash, role, username, enabled) VALUES ('b5ac2aa0-2de4-410d-9a2a-dcb478389ca7', 'alice@example.edu.cn', 'Alice', '{bcrypt}$2a$10$GXKvr6mP6SWLd6.9cUPpI.k8PNEfrdP2fU.7U9nOsbpTw3bkET8t2', 'TEACHER', 'alice', true);


--
-- Data for Name: class_membership; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.class_membership (id, class_id, decided_at, decided_by, requested_at, status, student_id) VALUES ('e9a7cba3-42e6-4930-9e23-ab316d4a8a14', 'a33299bd-696e-4d41-ae59-ad9ee350b3b6', '2026-02-24 15:46:32.175647+00', 'b5ac2aa0-2de4-410d-9a2a-dcb478389ca7', '2026-02-24 15:45:29.025387+00', 'APPROVED', 'f286e1e3-9bb1-41ae-b7e9-dbc7ef9c8b1d');


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.classes (id, created_at, name, teacher_id) VALUES ('a33299bd-696e-4d41-ae59-ad9ee350b3b6', '2026-02-24 15:45:11.201595+00', '数电106周三12节', 'b5ac2aa0-2de4-410d-9a2a-dcb478389ca7');


--
-- Data for Name: level_allowed_components; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L00_EXPR', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L00_EXPR', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L00_EXPR', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L00_EXPR', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L00_EXPR', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L01_NAND', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L01_NAND', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L01_NAND', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L01_NAND', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L02_XOR', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L02_XOR', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L02_XOR', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L02_XOR', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L02_XOR', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L02_XOR', 'Nand');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L03_SIMPLIFY', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L03_SIMPLIFY', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L03_SIMPLIFY', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L03_SIMPLIFY', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L03_SIMPLIFY', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L04_SOP_MINTERMS', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L04_SOP_MINTERMS', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L04_SOP_MINTERMS', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L04_SOP_MINTERMS', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L04_SOP_MINTERMS', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L04_SOP_MINTERMS', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L05_KMAP_4VAR', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L05_KMAP_4VAR', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L05_KMAP_4VAR', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L05_KMAP_4VAR', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L05_KMAP_4VAR', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L05_KMAP_4VAR', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L06_MAJORITY', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L06_MAJORITY', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L06_MAJORITY', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L06_MAJORITY', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L06_MAJORITY', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L06_MAJORITY', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L07_MUX2', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L07_MUX2', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L07_MUX2', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L07_MUX2', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L07_MUX2', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L07_MUX2', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L08_DECODER_2x4', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L08_DECODER_2x4', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L08_DECODER_2x4', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L08_DECODER_2x4', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L08_DECODER_2x4', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L08_DECODER_2x4', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L09_ENCODER_4x2', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L09_ENCODER_4x2', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L09_ENCODER_4x2', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L09_ENCODER_4x2', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L09_ENCODER_4x2', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L09_ENCODER_4x2', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L10_FULL_ADDER', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L10_FULL_ADDER', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L10_FULL_ADDER', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L10_FULL_ADDER', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L10_FULL_ADDER', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L10_FULL_ADDER', 'Xor');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L10_FULL_ADDER', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L11_ADDER_2BIT', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L11_ADDER_2BIT', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L11_ADDER_2BIT', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L11_ADDER_2BIT', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L11_ADDER_2BIT', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L11_ADDER_2BIT', 'Xor');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L11_ADDER_2BIT', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L12_SUB_2BIT', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L12_SUB_2BIT', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L12_SUB_2BIT', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L12_SUB_2BIT', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L12_SUB_2BIT', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L12_SUB_2BIT', 'Xor');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L12_SUB_2BIT', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L13_COMP_2BIT', 'Xnor');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L13_COMP_2BIT', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L13_COMP_2BIT', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L13_COMP_2BIT', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L13_COMP_2BIT', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L13_COMP_2BIT', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L13_COMP_2BIT', 'Xor');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L13_COMP_2BIT', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L14_ALU_1BIT', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L14_ALU_1BIT', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L14_ALU_1BIT', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L14_ALU_1BIT', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L14_ALU_1BIT', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L14_ALU_1BIT', 'Xor');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L14_ALU_1BIT', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L15_SR_LATCH', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L15_SR_LATCH', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L15_SR_LATCH', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L15_SR_LATCH', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L16_DFF_SAMPLE', 'Dff');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L16_DFF_SAMPLE', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L16_DFF_SAMPLE', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L16_DFF_SAMPLE', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L17_TFF', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L17_TFF', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L17_TFF', 'Dff');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L17_TFF', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L17_TFF', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L17_TFF', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L17_TFF', 'Xor');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L17_TFF', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L18_SHIFTREG_2BIT', 'Dff');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L18_SHIFTREG_2BIT', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L18_SHIFTREG_2BIT', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L18_SHIFTREG_2BIT', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L19_COUNTER_2BIT', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L19_COUNTER_2BIT', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L19_COUNTER_2BIT', 'Dff');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L19_COUNTER_2BIT', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L19_COUNTER_2BIT', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L19_COUNTER_2BIT', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L19_COUNTER_2BIT', 'Xor');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L19_COUNTER_2BIT', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L20_RAM_2x1_DFF', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L20_RAM_2x1_DFF', 'Or');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L20_RAM_2x1_DFF', 'Dff');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L20_RAM_2x1_DFF', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L20_RAM_2x1_DFF', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L20_RAM_2x1_DFF', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L20_RAM_2x1_DFF', 'Lamp');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L21_FSM_EDGE_DETECT', 'Not');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L21_FSM_EDGE_DETECT', 'Dff');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L21_FSM_EDGE_DETECT', 'Button');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L21_FSM_EDGE_DETECT', 'And');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L21_FSM_EDGE_DETECT', 'Repeater');
INSERT INTO public.level_allowed_components (level_code, component) VALUES ('L21_FSM_EDGE_DETECT', 'Lamp');


--
-- Data for Name: level_kp_ids; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L00_EXPR', 'DC-FND-04');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L01_NAND', 'DC-BOOL-03');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L02_XOR', 'DC-BOOL-01');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L03_SIMPLIFY', 'DC-BOOL-02');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L04_SOP_MINTERMS', 'DC-BOOL-04');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L05_KMAP_4VAR', 'DC-BOOL-05');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L06_MAJORITY', 'DC-COMB-01');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L07_MUX2', 'DC-COMB-02');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L08_DECODER_2x4', 'DC-COMB-03');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L09_ENCODER_4x2', 'DC-COMB-04');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L10_FULL_ADDER', 'DC-ARITH-01');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L11_ADDER_2BIT', 'DC-ARITH-02');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L12_SUB_2BIT', 'DC-ARITH-03');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L13_COMP_2BIT', 'DC-ARITH-04');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L14_ALU_1BIT', 'DC-ARITH-05');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L15_SR_LATCH', 'DC-SEQ-02');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L16_DFF_SAMPLE', 'DC-SEQ-01');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L16_DFF_SAMPLE', 'DC-SEQ-03');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L17_TFF', 'DC-SEQ-04');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L18_SHIFTREG_2BIT', 'DC-SEQ-05');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L19_COUNTER_2BIT', 'DC-SEQ-06');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L20_RAM_2x1_DFF', 'DC-MEM-01');
INSERT INTO public.level_kp_ids (level_code, kp_id) VALUES ('L21_FSM_EDGE_DETECT', 'DC-FSM-01');


--
-- Data for Name: level_pass_records; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: level_test_cases; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('06b44e55-e83d-4ea3-a2d7-ef4c0aa789cb', 'truth-table-3in', 1, 'L00_EXPR');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('0426ba69-5454-48dd-b176-efba5922abf9', 'truth-table', 1, 'L01_NAND');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('8a5d13ce-6aba-4cce-a352-d7627a981537', 'truth-table', 1, 'L02_XOR');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('e61f329a-9404-4313-9f81-7e5134d081d7', 'equivalent-to-A', 1, 'L03_SIMPLIFY');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('453e0696-9a30-4cb6-914d-667a06b3c6ee', 'truth-table', 1, 'L04_SOP_MINTERMS');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('72f6c62c-eb28-4d00-ace2-d1b55dd80563', 'full-truth-table-4var', 1, 'L05_KMAP_4VAR');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('45b47389-06fa-4a66-8dbd-828a463ae1b3', 'truth-table', 1, 'L06_MAJORITY');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('4f8c17b2-5732-4753-8256-d04c3b01bb5e', 'truth-table', 1, 'L07_MUX2');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('1ceaa2fe-a721-4284-a6ff-18fd020893b0', 'decoder-truth-table', 1, 'L08_DECODER_2x4');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('da0dbe58-ebcd-4ef7-8ac6-99a8e97e158b', NULL, 1, 'L09_ENCODER_4x2');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('a9a20bd9-0511-47a8-9712-a496de1ef029', 'full-truth-table', 1, 'L10_FULL_ADDER');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('054d64fd-8212-482d-bf40-e9480c4b033e', 'exhaustive-2bit', 1, 'L11_ADDER_2BIT');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('8fc7fdc0-9bd1-4c8b-b930-9800dca91d07', 'selected-cases', 1, 'L12_SUB_2BIT');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('d03b7725-cd11-4f39-9065-9aabebf8f491', 'exhaustive-2bit-compare', 1, 'L13_COMP_2BIT');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('9ce5d26f-46ad-4bc6-9ca6-e025dedf730a', 'alu-opcodes', 1, 'L14_ALU_1BIT');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('e1eed1ae-956a-4e27-9949-9b5525fdd2c3', 'sequence-hold-set-reset', 1, 'L15_SR_LATCH');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('f72a74a5-a02e-40ca-a36e-1f2cef690255', 'reset-and-sample', 1, 'L16_DFF_SAMPLE');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('a73e1330-6f23-4ddc-a714-3894a6b3afec', 'toggle-sequence', 1, 'L17_TFF');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('96a976f2-f06f-403a-a718-6ff470f931d1', 'shift-sequence', 1, 'L18_SHIFTREG_2BIT');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('0902cb0a-407d-4063-a826-d7a44eac756d', 'count-0-to-3', 1, 'L19_COUNTER_2BIT');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('d2b145e2-7247-478f-8471-b0aa619a4791', 'write-read-sequence', 1, 'L20_RAM_2x1_DFF');
INSERT INTO public.level_test_cases (id, name, order_index, level_code) VALUES ('61b7aea6-6e59-42b2-9389-dae22e70b839', 'edge-detect-seq', 1, 'L21_FSM_EDGE_DETECT');


--
-- Data for Name: level_test_steps; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('87f39f18-7655-4765-9bfe-b0e3fcedf60e', '{"Y":0}', '{"A":0,"B":0,"C":0}', 0, '06b44e55-e83d-4ea3-a2d7-ef4c0aa789cb');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('4b1a3f28-64f7-4e2d-ab7f-0703f5a4f123', '{"Y":1}', '{"A":0,"B":0,"C":1}', 1, '06b44e55-e83d-4ea3-a2d7-ef4c0aa789cb');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('f423f033-d2eb-4067-b389-8be02817d1d9', '{"Y":0}', '{"A":0,"B":1,"C":0}', 2, '06b44e55-e83d-4ea3-a2d7-ef4c0aa789cb');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('89513604-d58e-44cb-b10a-f2437323eb94', '{"Y":1}', '{"A":0,"B":1,"C":1}', 3, '06b44e55-e83d-4ea3-a2d7-ef4c0aa789cb');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('86d920bc-1e35-4668-ba84-dc7a991f50b8', '{"Y":1}', '{"A":1,"B":0,"C":0}', 4, '06b44e55-e83d-4ea3-a2d7-ef4c0aa789cb');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('12627b74-501f-44c9-a0b8-534647b159bb', '{"Y":1}', '{"A":1,"B":0,"C":1}', 5, '06b44e55-e83d-4ea3-a2d7-ef4c0aa789cb');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('e5eafbec-716e-4c9e-8258-1ee6bdc99c7a', '{"Y":0}', '{"A":1,"B":1,"C":0}', 6, '06b44e55-e83d-4ea3-a2d7-ef4c0aa789cb');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('3c0e8b42-25eb-4bec-a00e-4fb8a45d6dc4', '{"Y":1}', '{"A":1,"B":1,"C":1}', 7, '06b44e55-e83d-4ea3-a2d7-ef4c0aa789cb');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('4c7d9aa0-58c4-4831-b9b3-cc576d75d22f', '{"Y":1}', '{"A":0,"B":0}', 0, '0426ba69-5454-48dd-b176-efba5922abf9');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('5e72e398-248b-4f28-8905-8d9f5e09f3d3', '{"Y":1}', '{"A":0,"B":1}', 1, '0426ba69-5454-48dd-b176-efba5922abf9');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('919a6156-ac6a-44a9-b6d4-e80652fc18ee', '{"Y":1}', '{"A":1,"B":0}', 2, '0426ba69-5454-48dd-b176-efba5922abf9');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('869575cd-5e0b-486b-8dcd-20f3f7e0af5b', '{"Y":0}', '{"A":1,"B":1}', 3, '0426ba69-5454-48dd-b176-efba5922abf9');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('b51dee22-b8cc-402c-bc40-08248e31affd', '{"Y":0}', '{"A":0,"B":0}', 0, '8a5d13ce-6aba-4cce-a352-d7627a981537');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('b489f1e3-9340-42a8-9073-9ab20fdd2b17', '{"Y":1}', '{"A":0,"B":1}', 1, '8a5d13ce-6aba-4cce-a352-d7627a981537');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('b3ecfe94-c63e-4dd9-9bb7-e8d091257cb0', '{"Y":1}', '{"A":1,"B":0}', 2, '8a5d13ce-6aba-4cce-a352-d7627a981537');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('ddf14758-4c3a-451d-86ec-bdabddc23c95', '{"Y":0}', '{"A":1,"B":1}', 3, '8a5d13ce-6aba-4cce-a352-d7627a981537');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('342f890b-2a30-41e4-aeb3-6c615cfa2dd7', '{"Y":0}', '{"A":0,"B":0}', 0, 'e61f329a-9404-4313-9f81-7e5134d081d7');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('b4e28eee-2a57-4292-9015-748b2b0b3f5e', '{"Y":0}', '{"A":0,"B":1}', 1, 'e61f329a-9404-4313-9f81-7e5134d081d7');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('cb484082-1092-450f-8fed-dcbd3ec51330', '{"Y":1}', '{"A":1,"B":0}', 2, 'e61f329a-9404-4313-9f81-7e5134d081d7');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('7374f176-2215-4987-bed5-fff4b8e6beb6', '{"Y":1}', '{"A":1,"B":1}', 3, 'e61f329a-9404-4313-9f81-7e5134d081d7');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('9a672154-3db9-4108-9327-a87e8043fd77', '{"Y":0}', '{"A":0,"B":0,"C":0}', 0, '453e0696-9a30-4cb6-914d-667a06b3c6ee');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('eaa3f790-485d-4935-b8a2-c15ac461fb9f', '{"Y":1}', '{"A":0,"B":0,"C":1}', 1, '453e0696-9a30-4cb6-914d-667a06b3c6ee');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('08656970-f1da-4078-b8d7-fe4356684bdc', '{"Y":1}', '{"A":0,"B":1,"C":0}', 2, '453e0696-9a30-4cb6-914d-667a06b3c6ee');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('634b0b6b-5f69-47d4-8b52-56941998f38b', '{"Y":0}', '{"A":0,"B":1,"C":1}', 3, '453e0696-9a30-4cb6-914d-667a06b3c6ee');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('64bc343a-a4d2-4dc2-9007-d4ecfc929e92', '{"Y":0}', '{"A":1,"B":0,"C":0}', 4, '453e0696-9a30-4cb6-914d-667a06b3c6ee');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('c5003948-1544-4df5-9a58-5fab50b7e831', '{"Y":1}', '{"A":1,"B":0,"C":1}', 5, '453e0696-9a30-4cb6-914d-667a06b3c6ee');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('f40f5b5f-de1e-4f06-921a-ebcc6ba2bd59', '{"Y":0}', '{"A":1,"B":1,"C":0}', 6, '453e0696-9a30-4cb6-914d-667a06b3c6ee');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('fb170a82-b0c4-4ea7-8806-ea8fcebe1525', '{"Y":1}', '{"A":1,"B":1,"C":1}', 7, '453e0696-9a30-4cb6-914d-667a06b3c6ee');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('8ca8b813-c547-477b-8d91-480fd4091d2f', '{"F":1}', '{"W":0,"X":0,"Y":0,"Z":0}', 0, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('1985a64b-a0f5-4561-bb8e-b9b98dd3a646', '{"F":1}', '{"W":0,"X":0,"Y":0,"Z":1}', 1, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('cd2f9a3a-3c24-4e84-8667-1460938edaaa', '{"F":1}', '{"W":0,"X":0,"Y":1,"Z":0}', 2, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('54040b56-03e4-4192-8eb5-6b3ee685d3ed', '{"F":1}', '{"W":0,"X":0,"Y":1,"Z":1}', 3, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('4865e31b-69ef-49cf-82c3-7bdda460cc09', '{"F":0}', '{"W":0,"X":1,"Y":0,"Z":0}', 4, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('fb7c4abe-703b-48cf-b490-cd305252e367', '{"F":0}', '{"W":0,"X":1,"Y":0,"Z":1}', 5, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('ae801c25-ed27-4880-8902-79530b28a8d5', '{"F":0}', '{"W":0,"X":1,"Y":1,"Z":0}', 6, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('597e64e7-e85b-4133-a55f-513ca43ea005', '{"F":1}', '{"W":0,"X":1,"Y":1,"Z":1}', 7, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('d99b03ab-e161-4d26-bd50-3dda0ef9c5f0', '{"F":0}', '{"W":1,"X":0,"Y":0,"Z":0}', 8, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('29f06192-7950-43e4-bb87-093cedabdc03', '{"F":0}', '{"W":1,"X":0,"Y":0,"Z":1}', 9, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('cd5d2e5f-7401-41eb-a937-7e2ff6552f5a', '{"F":0}', '{"W":1,"X":0,"Y":1,"Z":0}', 10, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('ef98e978-d623-4dbe-b194-d592165d68a6', '{"F":1}', '{"W":1,"X":0,"Y":1,"Z":1}', 11, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('292f514e-e3f9-4b3c-90cf-38cfa84c4e26', '{"F":0}', '{"W":1,"X":1,"Y":0,"Z":0}', 12, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('a2bff869-359c-4466-83df-66f6349166cf', '{"F":0}', '{"W":1,"X":1,"Y":0,"Z":1}', 13, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('d954fb74-ce3b-4b80-b92e-63f476ae3242', '{"F":0}', '{"W":1,"X":1,"Y":1,"Z":0}', 14, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('805355bd-1a55-437a-a87e-b8f69ffcde44', '{"F":1}', '{"W":1,"X":1,"Y":1,"Z":1}', 15, '72f6c62c-eb28-4d00-ace2-d1b55dd80563');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('65cad912-e97c-4526-870f-acbd44949c2d', '{"Y":0}', '{"A":0,"B":0,"C":0}', 0, '45b47389-06fa-4a66-8dbd-828a463ae1b3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('038aef2a-68d0-4128-bca9-8cc67c7f8fd2', '{"Y":0}', '{"A":0,"B":0,"C":1}', 1, '45b47389-06fa-4a66-8dbd-828a463ae1b3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('8d19ab30-2f21-4ca1-b21d-fe055dc7d449', '{"Y":0}', '{"A":0,"B":1,"C":0}', 2, '45b47389-06fa-4a66-8dbd-828a463ae1b3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('0a7e0294-c9a0-4e35-a2d0-08584f7cda4f', '{"Y":1}', '{"A":0,"B":1,"C":1}', 3, '45b47389-06fa-4a66-8dbd-828a463ae1b3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('4602cb69-8de0-4866-bf91-02385283aa34', '{"Y":0}', '{"A":1,"B":0,"C":0}', 4, '45b47389-06fa-4a66-8dbd-828a463ae1b3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('f3770187-935b-4c98-a4e5-6ca25795a2a5', '{"Y":1}', '{"A":1,"B":0,"C":1}', 5, '45b47389-06fa-4a66-8dbd-828a463ae1b3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('c73b9ab9-5dbe-47e6-8b3d-0a9dbdb6da08', '{"Y":1}', '{"A":1,"B":1,"C":0}', 6, '45b47389-06fa-4a66-8dbd-828a463ae1b3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('dd7d1d07-308e-4c5a-805a-1cf6104997a1', '{"Y":1}', '{"A":1,"B":1,"C":1}', 7, '45b47389-06fa-4a66-8dbd-828a463ae1b3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('1298bb43-95d5-4279-98f5-0d2de4e4984d', '{"Y":0}', '{"D0":0,"D1":0,"S":0}', 0, '4f8c17b2-5732-4753-8256-d04c3b01bb5e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('927ef6a8-fda6-4ad5-81b4-6a1251218b8a', '{"Y":1}', '{"D0":1,"D1":0,"S":0}', 1, '4f8c17b2-5732-4753-8256-d04c3b01bb5e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('16759220-d470-42e7-bcb4-beac001ec28a', '{"Y":0}', '{"D0":0,"D1":1,"S":0}', 2, '4f8c17b2-5732-4753-8256-d04c3b01bb5e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('25095f3b-2e72-4e5a-b448-063fea829e94', '{"Y":0}', '{"D0":0,"D1":0,"S":1}', 4, '4f8c17b2-5732-4753-8256-d04c3b01bb5e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('ffa1470e-219e-487f-90fe-9e119a29d243', '{"Y":0}', '{"D0":1,"D1":0,"S":1}', 5, '4f8c17b2-5732-4753-8256-d04c3b01bb5e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('e3da33c9-a39f-462a-948d-ad93742e429f', '{"Y":1}', '{"D0":0,"D1":1,"S":1}', 6, '4f8c17b2-5732-4753-8256-d04c3b01bb5e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('a71a27b2-b27f-4b21-8eed-00f2eb67894a', '{"Y":1}', '{"D0":1,"D1":1,"S":1}', 7, '4f8c17b2-5732-4753-8256-d04c3b01bb5e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('3f1ee336-891d-4b02-bf51-582e80e9d2f0', '{"Y0":0,"Y1":0,"Y2":0,"Y3":0}', '{"A":0,"B":0,"EN":0}', 0, '1ceaa2fe-a721-4284-a6ff-18fd020893b0');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('249ff3c5-c468-406d-95bc-8421dd777070', '{"Y0":0,"Y1":0,"Y2":0,"Y3":0}', '{"A":0,"B":1,"EN":0}', 1, '1ceaa2fe-a721-4284-a6ff-18fd020893b0');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('992c72db-eecf-4dfe-8ec6-8be65d7fa9d1', '{"Y0":0,"Y1":0,"Y2":0,"Y3":0}', '{"A":1,"B":0,"EN":0}', 2, '1ceaa2fe-a721-4284-a6ff-18fd020893b0');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('9a48706e-658e-41fb-b480-1f100e40086d', '{"Y0":0,"Y1":0,"Y2":0,"Y3":0}', '{"A":1,"B":1,"EN":0}', 3, '1ceaa2fe-a721-4284-a6ff-18fd020893b0');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('e3ce8a28-4e12-4f02-b24b-be053dd4001f', '{"Y0":1,"Y1":0,"Y2":0,"Y3":0}', '{"A":0,"B":0,"EN":1}', 4, '1ceaa2fe-a721-4284-a6ff-18fd020893b0');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('455bec2e-d08e-4fae-aabb-838ff2da3e5e', '{"Y0":0,"Y1":1,"Y2":0,"Y3":0}', '{"A":0,"B":1,"EN":1}', 5, '1ceaa2fe-a721-4284-a6ff-18fd020893b0');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('d2ad8291-ed3f-42b9-bebe-ed74115b22a5', '{"Y0":0,"Y1":0,"Y2":1,"Y3":0}', '{"A":1,"B":0,"EN":1}', 6, '1ceaa2fe-a721-4284-a6ff-18fd020893b0');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('ed407956-5ad5-46a0-809e-f841a6b8e912', '{"Y0":0,"Y1":0,"Y2":0,"Y3":1}', '{"A":1,"B":1,"EN":1}', 7, '1ceaa2fe-a721-4284-a6ff-18fd020893b0');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('bd0f9e4f-66a8-4e5f-83d4-921fea091187', '{"O1":0,"O0":0,"V":0}', '{"I0":0,"I1":0,"I2":0,"I3":0}', 0, 'da0dbe58-ebcd-4ef7-8ac6-99a8e97e158b');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('409ab061-a398-40c8-a246-cd48d59a1724', '{"O1":0,"O0":0,"V":1}', '{"I0":1,"I1":0,"I2":0,"I3":0}', 1, 'da0dbe58-ebcd-4ef7-8ac6-99a8e97e158b');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('ca695bae-cc3f-42a0-8f47-523c25990e53', '{"O1":0,"O0":1,"V":1}', '{"I0":0,"I1":1,"I2":0,"I3":0}', 2, 'da0dbe58-ebcd-4ef7-8ac6-99a8e97e158b');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('392e6963-30e8-4eea-a136-eea562156736', '{"O1":1,"O0":0,"V":1}', '{"I0":0,"I1":0,"I2":1,"I3":0}', 3, 'da0dbe58-ebcd-4ef7-8ac6-99a8e97e158b');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('523c9e20-b7b2-4b1a-bb17-190df8644045', '{"O1":1,"O0":1,"V":1}', '{"I0":0,"I1":0,"I2":0,"I3":1}', 4, 'da0dbe58-ebcd-4ef7-8ac6-99a8e97e158b');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('a9bb31dc-a78c-4b8e-9108-024a0ba7c816', '{"Sum":0,"Cout":0}', '{"A":0,"B":0,"Cin":0}', 0, 'a9a20bd9-0511-47a8-9712-a496de1ef029');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('46109d70-e0e3-424c-a05d-fb9fb37ec0c9', '{"Sum":1,"Cout":0}', '{"A":0,"B":0,"Cin":1}', 1, 'a9a20bd9-0511-47a8-9712-a496de1ef029');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('40b8b4b4-c7c4-4527-b3a6-32162e2cdfa6', '{"Sum":1,"Cout":0}', '{"A":0,"B":1,"Cin":0}', 2, 'a9a20bd9-0511-47a8-9712-a496de1ef029');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('49732198-bdd2-4e17-9263-084ef975cafb', '{"Sum":0,"Cout":1}', '{"A":0,"B":1,"Cin":1}', 3, 'a9a20bd9-0511-47a8-9712-a496de1ef029');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('4f03d093-9eff-4e29-8add-f7b9bfa9b0c7', '{"Sum":1,"Cout":0}', '{"A":1,"B":0,"Cin":0}', 4, 'a9a20bd9-0511-47a8-9712-a496de1ef029');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('5e1cae21-ebfc-4e76-95d9-4d7419bc3039', '{"Sum":0,"Cout":1}', '{"A":1,"B":0,"Cin":1}', 5, 'a9a20bd9-0511-47a8-9712-a496de1ef029');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('c14c1c3b-b0a3-42cf-9790-40ccf7572c43', '{"Sum":0,"Cout":1}', '{"A":1,"B":1,"Cin":0}', 6, 'a9a20bd9-0511-47a8-9712-a496de1ef029');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('27df5d0d-8346-497e-ada0-149f65d29b37', '{"Sum":1,"Cout":1}', '{"A":1,"B":1,"Cin":1}', 7, 'a9a20bd9-0511-47a8-9712-a496de1ef029');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('9ca36829-fcb5-4c84-a9e5-949ff1f3fe68', '{"S1":0,"S0":0,"Cout":0}', '{"A1":0,"A0":0,"B1":0,"B0":0}', 0, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('224b3167-722d-4944-82e5-670f03d33ecf', '{"S1":0,"S0":1,"Cout":0}', '{"A1":0,"A0":0,"B1":0,"B0":1}', 1, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('1bd0b955-082e-424c-ae78-9e8fc59f5f82', '{"S1":1,"S0":0,"Cout":0}', '{"A1":0,"A0":0,"B1":1,"B0":0}', 2, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('08762dbb-eead-4a77-945a-0337826b2489', '{"S1":1,"S0":1,"Cout":0}', '{"A1":0,"A0":0,"B1":1,"B0":1}', 3, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('3dde1b31-554d-4262-964c-032af224eaf9', '{"S1":0,"S0":1,"Cout":0}', '{"A1":0,"A0":1,"B1":0,"B0":0}', 4, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('32363e39-ae1d-48ba-992d-3d4e9013a5c8', '{"S1":1,"S0":0,"Cout":0}', '{"A1":0,"A0":1,"B1":0,"B0":1}', 5, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('f2154742-9a4c-45d6-9cd9-6b7beac5c11d', '{"S1":1,"S0":1,"Cout":0}', '{"A1":0,"A0":1,"B1":1,"B0":0}', 6, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('dc6cfc27-92e1-43ac-9f09-50322e02d306', '{"S1":0,"S0":0,"Cout":1}', '{"A1":0,"A0":1,"B1":1,"B0":1}', 7, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('1907e407-aa45-4fec-8c78-a4e147b0a804', '{"S1":1,"S0":0,"Cout":0}', '{"A1":1,"A0":0,"B1":0,"B0":0}', 8, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('95d69a0b-ad68-4342-82ad-efa6932600ce', '{"S1":1,"S0":1,"Cout":0}', '{"A1":1,"A0":0,"B1":0,"B0":1}', 9, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('89741432-17a0-40b0-944e-90b09d50f9b5', '{"S1":0,"S0":0,"Cout":1}', '{"A1":1,"A0":0,"B1":1,"B0":0}', 10, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('d0b94fd6-2647-4deb-89d6-66f882f9ec93', '{"S1":0,"S0":1,"Cout":1}', '{"A1":1,"A0":0,"B1":1,"B0":1}', 11, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('1b55d23c-25b2-4ee4-9f62-a54afc6742b5', '{"S1":1,"S0":1,"Cout":0}', '{"A1":1,"A0":1,"B1":0,"B0":0}', 12, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('1907826c-1d23-40e1-bb90-ac21f796293b', '{"S1":0,"S0":0,"Cout":1}', '{"A1":1,"A0":1,"B1":0,"B0":1}', 13, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('e6ece00d-4c0c-4fff-8b24-2d7abfdcf530', '{"S1":0,"S0":1,"Cout":1}', '{"A1":1,"A0":1,"B1":1,"B0":0}', 14, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('856ce4c0-9235-4ef6-b7f7-34ed0ba2a2f8', '{"S1":1,"S0":0,"Cout":1}', '{"A1":1,"A0":1,"B1":1,"B0":1}', 15, '054d64fd-8212-482d-bf40-e9480c4b033e');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('88a54bc8-7b67-4ee7-86f7-f9ba827aafbd', '{"D1":0,"D0":0,"Borrow":0}', '{"A1":0,"A0":0,"B1":0,"B0":0}', 0, '8fc7fdc0-9bd1-4c8b-b930-9800dca91d07');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('7a56aa7b-317e-4310-ab82-e71d4b5ff90a', '{"D1":0,"D0":1,"Borrow":0}', '{"A1":0,"A0":1,"B1":0,"B0":0}', 1, '8fc7fdc0-9bd1-4c8b-b930-9800dca91d07');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('059960a7-01de-43b0-903a-8e37d75adeb0', '{"D1":0,"D0":1,"Borrow":0}', '{"A1":1,"A0":0,"B1":0,"B0":1}', 2, '8fc7fdc0-9bd1-4c8b-b930-9800dca91d07');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('c741b744-a120-443f-86b8-923d3a5f41b7', '{"D1":1,"D0":0,"Borrow":0}', '{"A1":1,"A0":1,"B1":0,"B0":1}', 3, '8fc7fdc0-9bd1-4c8b-b930-9800dca91d07');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('1f3f298b-8128-42b1-acd2-b859321b6a88', '{"D1":1,"D0":1,"Borrow":1}', '{"A1":0,"A0":0,"B1":0,"B0":1}', 4, '8fc7fdc0-9bd1-4c8b-b930-9800dca91d07');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('c50b12bc-572d-4903-96bd-1557591f1365', '{"D1":1,"D0":1,"Borrow":1}', '{"A1":0,"A0":1,"B1":1,"B0":0}', 5, '8fc7fdc0-9bd1-4c8b-b930-9800dca91d07');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('5882609e-72c2-4763-8aa6-66edb6ee2589', '{"D1":1,"D0":1,"Borrow":1}', '{"A1":1,"A0":0,"B1":1,"B0":1}', 6, '8fc7fdc0-9bd1-4c8b-b930-9800dca91d07');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('48eaadcb-21d9-47dd-8d9c-ce8e112307e4', '{"D1":0,"D0":1,"Borrow":1}', '{"A1":0,"A0":0,"B1":1,"B0":1}', 7, '8fc7fdc0-9bd1-4c8b-b930-9800dca91d07');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('6d19b585-08ff-435c-aaca-70b60a14f0c9', '{"GT":0,"EQ":1,"LT":0}', '{"A1":0,"A0":0,"B1":0,"B0":0}', 0, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('2a81daef-d603-4679-ab12-cd33c7247630', '{"GT":0,"EQ":0,"LT":1}', '{"A1":0,"A0":0,"B1":0,"B0":1}', 1, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('49f2accb-67ae-4d3b-82e2-81a2399c55ce', '{"GT":0,"EQ":0,"LT":1}', '{"A1":0,"A0":0,"B1":1,"B0":0}', 2, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('b86b11ee-a52a-492a-ad61-49890ca82f1d', '{"GT":0,"EQ":0,"LT":1}', '{"A1":0,"A0":0,"B1":1,"B0":1}', 3, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('693339ac-f534-49cd-b2de-4ef7be5acce2', '{"GT":1,"EQ":0,"LT":0}', '{"A1":0,"A0":1,"B1":0,"B0":0}', 4, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('25f9d7dd-83fe-4091-bc16-e9c3ffac611f', '{"GT":0,"EQ":1,"LT":0}', '{"A1":0,"A0":1,"B1":0,"B0":1}', 5, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('a2e38381-9757-46f5-a277-8a29bde512d8', '{"GT":0,"EQ":0,"LT":1}', '{"A1":0,"A0":1,"B1":1,"B0":0}', 6, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('f3f1718a-e287-4476-be8b-b2ad87e4264d', '{"GT":0,"EQ":0,"LT":1}', '{"A1":0,"A0":1,"B1":1,"B0":1}', 7, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('9ec2edcf-4c4a-4ddf-8f0d-a17818ee14da', '{"GT":1,"EQ":0,"LT":0}', '{"A1":1,"A0":0,"B1":0,"B0":0}', 8, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('41f1e0b0-c7c7-4b43-8ed5-0ac55e472614', '{"GT":1,"EQ":0,"LT":0}', '{"A1":1,"A0":0,"B1":0,"B0":1}', 9, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('bcb0c131-021f-4379-9b25-af95de38ed93', '{"GT":0,"EQ":1,"LT":0}', '{"A1":1,"A0":0,"B1":1,"B0":0}', 10, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('11207423-072e-476c-9210-7c395164bb2d', '{"GT":0,"EQ":0,"LT":1}', '{"A1":1,"A0":0,"B1":1,"B0":1}', 11, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('9e9d6266-6f9b-4336-af4a-9dac80572f17', '{"GT":1,"EQ":0,"LT":0}', '{"A1":1,"A0":1,"B1":0,"B0":0}', 12, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('233adcb2-a429-4214-96ea-48ebbd9650a8', '{"GT":1,"EQ":0,"LT":0}', '{"A1":1,"A0":1,"B1":0,"B0":1}', 13, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('f7e0f5ed-3a6f-459b-abb3-98580c4c6cd6', '{"GT":1,"EQ":0,"LT":0}', '{"A1":1,"A0":1,"B1":1,"B0":0}', 14, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('ada27a63-70c6-4359-9a3d-09a513a7dc2d', '{"GT":0,"EQ":1,"LT":0}', '{"A1":1,"A0":1,"B1":1,"B0":1}', 15, 'd03b7725-cd11-4f39-9065-9aabebf8f491');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('104b8b70-9520-4e5f-ae49-bb7ae8a60ab0', '{"Y":0,"Cout":0}', '{"A":0,"B":0,"Op1":0,"Op0":0}', 0, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('92e9035a-7b5b-4351-baae-238e1471bb67', '{"Y":0,"Cout":0}', '{"A":0,"B":1,"Op1":0,"Op0":0}', 1, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('cef848d8-494a-4198-a6f2-9c5836f3f41a', '{"Y":0,"Cout":0}', '{"A":1,"B":0,"Op1":0,"Op0":0}', 2, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('a4d85fca-1264-46b6-90e5-c91a104403a6', '{"Y":1,"Cout":0}', '{"A":1,"B":1,"Op1":0,"Op0":0}', 3, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('06fe3e9a-b4a6-4d66-84b4-8ef7c32fe0d4', '{"Y":0,"Cout":0}', '{"A":0,"B":0,"Op1":0,"Op0":1}', 4, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('89223e00-ec55-4c78-8fd8-ae169fc78570', '{"Y":1,"Cout":0}', '{"A":0,"B":1,"Op1":0,"Op0":1}', 5, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('f6d1a7d7-08cf-49dc-862c-3855d5fc30c4', '{"Y":1,"Cout":0}', '{"A":1,"B":0,"Op1":0,"Op0":1}', 6, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('2c8d012c-b1f5-43ab-886a-af28a2e93d2b', '{"Y":1,"Cout":0}', '{"A":1,"B":1,"Op1":0,"Op0":1}', 7, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('8c28f1d9-0dc8-4489-bd54-d586ea36d3b3', '{"Y":0,"Cout":0}', '{"A":0,"B":0,"Op1":1,"Op0":0}', 8, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('8ae04a3a-cd84-4db6-af8a-eb53c7ffec5a', '{"Y":1,"Cout":0}', '{"A":0,"B":1,"Op1":1,"Op0":0}', 9, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('1758dc36-b134-4dd0-b1dc-7e28a559a7d7', '{"Y":1,"Cout":0}', '{"A":1,"B":0,"Op1":1,"Op0":0}', 10, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('b52f6f24-648c-4ac4-9357-3e98aab6974d', '{"Y":0,"Cout":0}', '{"A":1,"B":1,"Op1":1,"Op0":0}', 11, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('57671593-05e8-461e-89d7-188ef12a3781', '{"Y":0,"Cout":0}', '{"A":0,"B":0,"Op1":1,"Op0":1}', 12, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('0f183217-bc4f-4d8f-b1ac-a75383836ca6', '{"Y":1,"Cout":0}', '{"A":0,"B":1,"Op1":1,"Op0":1}', 13, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('433367a5-5119-4bce-af0a-93c07a8f5633', '{"Y":1,"Cout":0}', '{"A":1,"B":0,"Op1":1,"Op0":1}', 14, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('c835bcba-5816-426d-926d-00b89eda6074', '{"Y":0,"Cout":1}', '{"A":1,"B":1,"Op1":1,"Op0":1}', 15, '9ce5d26f-46ad-4bc6-9ca6-e025dedf730a');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('d2264576-d418-491f-9563-0aaddaeb7990', '{"Q":0,"Qn":1}', '{"S":0,"R":1}', 0, 'e1eed1ae-956a-4e27-9949-9b5525fdd2c3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('a723814e-7fa7-44e5-8a44-7a134fc05b2d', '{"Q":0,"Qn":1}', '{"S":0,"R":0}', 1, 'e1eed1ae-956a-4e27-9949-9b5525fdd2c3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('cd95c07b-1f33-4767-a047-3b06885af35c', '{"Q":1,"Qn":0}', '{"S":1,"R":0}', 2, 'e1eed1ae-956a-4e27-9949-9b5525fdd2c3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('600ba9dd-5f65-4f82-b55e-c81fe0f551e7', '{"Q":1,"Qn":0}', '{"S":0,"R":0}', 3, 'e1eed1ae-956a-4e27-9949-9b5525fdd2c3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('9da6ecba-2741-4d84-af33-db89d27688d3', '{"Q":0,"Qn":1}', '{"S":0,"R":1}', 4, 'e1eed1ae-956a-4e27-9949-9b5525fdd2c3');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('86573e82-b8f9-49ac-a3bf-ea7ab31f837e', '{"Q":0}', '{"RST":1,"CLK":0,"D":0}', 0, 'f72a74a5-a02e-40ca-a36e-1f2cef690255');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('80d21912-8b53-469f-8218-c97ef0d6ccd7', '{"Q":0}', '{"RST":0,"CLK":0,"D":0}', 1, 'f72a74a5-a02e-40ca-a36e-1f2cef690255');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('60bd1c2f-6bb7-4f9e-9484-34c17d34460a', '{"Q":0}', '{"RST":0,"CLK":0,"D":1}', 2, 'f72a74a5-a02e-40ca-a36e-1f2cef690255');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('a348a6fd-f41e-4834-b209-01ff8c2f847d', '{"Q":1}', '{"RST":0,"CLK":1,"D":1}', 3, 'f72a74a5-a02e-40ca-a36e-1f2cef690255');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('a6b3a880-e427-4466-b940-d24f5865d7a4', '{"Q":1}', '{"RST":0,"CLK":0,"D":1}', 4, 'f72a74a5-a02e-40ca-a36e-1f2cef690255');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('5c1970fd-4825-4ecc-a749-1ebc5af78489', '{"Q":1}', '{"RST":0,"CLK":0,"D":0}', 5, 'f72a74a5-a02e-40ca-a36e-1f2cef690255');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('8e5c7a82-6e91-479a-bb9a-40021096f426', '{"Q":0}', '{"RST":0,"CLK":1,"D":0}', 6, 'f72a74a5-a02e-40ca-a36e-1f2cef690255');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('94661e0c-74fc-4156-b428-2929d5686b38', '{"Q":0}', '{"RST":1,"CLK":0,"D":1}', 7, 'f72a74a5-a02e-40ca-a36e-1f2cef690255');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('08d55644-6897-46c4-a854-4efbe1e0b20d', '{"Q":0}', '{"RST":1,"CLK":0,"T":0}', 0, 'a73e1330-6f23-4ddc-a714-3894a6b3afec');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('1ecc26f9-1120-4596-b909-87895d2166a1', '{"Q":0}', '{"RST":0,"CLK":0,"T":1}', 1, 'a73e1330-6f23-4ddc-a714-3894a6b3afec');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('f7bf4e98-5aa6-4388-9319-6640ce329fb9', '{"Q":1}', '{"RST":0,"CLK":1,"T":1}', 2, 'a73e1330-6f23-4ddc-a714-3894a6b3afec');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('6958c9f8-6a1e-47f8-a553-f40ec3a33784', '{"Q":1}', '{"RST":0,"CLK":0,"T":1}', 3, 'a73e1330-6f23-4ddc-a714-3894a6b3afec');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('bd490476-4447-4401-93be-35f32fc03e23', '{"Q":0}', '{"RST":0,"CLK":1,"T":1}', 4, 'a73e1330-6f23-4ddc-a714-3894a6b3afec');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('5703955b-c10a-43a3-86dd-6cbea14be365', '{"Q":0}', '{"RST":0,"CLK":0,"T":0}', 5, 'a73e1330-6f23-4ddc-a714-3894a6b3afec');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('e895ccfd-ab6b-4008-9c58-0d2bf5ccfcac', '{"Q":0}', '{"RST":0,"CLK":1,"T":0}', 6, 'a73e1330-6f23-4ddc-a714-3894a6b3afec');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('cd9fa415-6456-4dc7-bf18-1b90328ef422', '{"Q0":0,"Q1":0}', '{"RST":1,"CLK":0,"Din":0}', 0, '96a976f2-f06f-403a-a718-6ff470f931d1');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('4f015e64-01df-4ef0-adc4-cd3a2609a4bc', '{"Q0":0,"Q1":0}', '{"RST":0,"CLK":0,"Din":1}', 1, '96a976f2-f06f-403a-a718-6ff470f931d1');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('9c5ffcb2-5dfd-4c85-8f5d-e13446d169c7', '{"Q0":1,"Q1":0}', '{"RST":0,"CLK":1,"Din":1}', 2, '96a976f2-f06f-403a-a718-6ff470f931d1');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('d6513bc1-f504-4450-b2ed-2e5cdfdbd566', '{"Q0":1,"Q1":0}', '{"RST":0,"CLK":0,"Din":0}', 3, '96a976f2-f06f-403a-a718-6ff470f931d1');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('64578690-5562-45fe-9cda-f7538e15b0fc', '{"Q0":0,"Q1":1}', '{"RST":0,"CLK":1,"Din":0}', 4, '96a976f2-f06f-403a-a718-6ff470f931d1');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('f5f9ec37-ddd6-4c57-b6fb-4d4fe10ba1de', '{"Q0":0,"Q1":1}', '{"RST":0,"CLK":0,"Din":1}', 5, '96a976f2-f06f-403a-a718-6ff470f931d1');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('105077bb-4a0a-4ca1-b92f-4823b5181857', '{"Q0":1,"Q1":0}', '{"RST":0,"CLK":1,"Din":1}', 6, '96a976f2-f06f-403a-a718-6ff470f931d1');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('909c872b-9e98-4cdc-b301-a38e73460134', '{"Q1":0,"Q0":0}', '{"RST":1,"CLK":0}', 0, '0902cb0a-407d-4063-a826-d7a44eac756d');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('69412f44-3050-4f22-9a71-5ba38be65907', '{"Q1":0,"Q0":0}', '{"RST":0,"CLK":0}', 1, '0902cb0a-407d-4063-a826-d7a44eac756d');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('4cf391cf-11ec-4c98-8d44-f9b4fad5a08b', '{"Q1":0,"Q0":1}', '{"RST":0,"CLK":1}', 2, '0902cb0a-407d-4063-a826-d7a44eac756d');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('3f5f1864-c889-4486-a8ee-6242c1f2eaa6', '{"Q1":0,"Q0":1}', '{"RST":0,"CLK":0}', 3, '0902cb0a-407d-4063-a826-d7a44eac756d');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('5506a97d-c7ec-4305-beb5-6cc497317d1a', '{"Q1":1,"Q0":0}', '{"RST":0,"CLK":1}', 4, '0902cb0a-407d-4063-a826-d7a44eac756d');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('57ace0fb-c724-4ad0-927b-03aa2daacd88', '{"Q1":1,"Q0":0}', '{"RST":0,"CLK":0}', 5, '0902cb0a-407d-4063-a826-d7a44eac756d');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('7fd3df6c-6b39-407d-8126-3dc8f13b8655', '{"Q1":1,"Q0":1}', '{"RST":0,"CLK":1}', 6, '0902cb0a-407d-4063-a826-d7a44eac756d');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('3953ddd0-3e69-4824-a8cd-2d807690f0cb', '{"Q1":1,"Q0":1}', '{"RST":0,"CLK":0}', 7, '0902cb0a-407d-4063-a826-d7a44eac756d');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('e8c7f1c6-789d-4a42-8bb8-e88be516c7d3', '{"Q1":0,"Q0":0}', '{"RST":0,"CLK":1}', 8, '0902cb0a-407d-4063-a826-d7a44eac756d');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('31f4317b-1fb5-4eed-bf01-ff14fbfb921a', '{"Y":0}', '{"RST":1,"CLK":0,"WE":0,"A":0,"D":0}', 0, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('a9063639-e7cc-48c1-a69c-cf0bcff1625f', '{"Y":0}', '{"RST":0,"CLK":0,"WE":0,"A":0,"D":0}', 1, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('d20c6da4-ec5e-4010-abe4-cb1c450da5dc', '{"Y":0}', '{"RST":0,"CLK":0,"WE":1,"A":0,"D":1}', 2, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('d59789e0-e610-4fc6-8c72-db036aa0e5d0', '{"Y":1}', '{"RST":0,"CLK":1,"WE":1,"A":0,"D":1}', 3, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('3b801aae-8474-4351-b6ab-ff22fd55cdd9', '{"Y":1}', '{"RST":0,"CLK":0,"WE":0,"A":0,"D":0}', 4, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('298143cd-0447-4714-a147-8bf165211567', '{"Y":0}', '{"RST":0,"CLK":0,"WE":1,"A":1,"D":1}', 5, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('d6423be1-10ca-4374-b39d-6d616cd85644', '{"Y":1}', '{"RST":0,"CLK":1,"WE":1,"A":1,"D":1}', 6, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('748b3b5b-8721-408f-b367-dd150fc9339a', '{"Y":1}', '{"RST":0,"CLK":0,"WE":0,"A":1,"D":0}', 7, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('ff86ffdb-0556-44d0-9c2c-48f6aecca794', '{"Y":1}', '{"RST":0,"CLK":0,"WE":1,"A":0,"D":0}', 8, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('59b5364f-5461-4163-9b6e-64c1c516c4e9', '{"Y":0}', '{"RST":0,"CLK":1,"WE":1,"A":0,"D":0}', 9, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('606d8cf8-939d-41c4-831a-a6ea07e6c3ab', '{"Y":0}', '{"RST":0,"CLK":0,"WE":0,"A":0,"D":0}', 10, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('ac07f303-9291-4ba7-9ad6-8a244abae7aa', '{"Y":1}', '{"RST":0,"CLK":0,"WE":0,"A":1,"D":0}', 11, 'd2b145e2-7247-478f-8471-b0aa619a4791');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('eaee737b-345b-41c7-93b3-f12b5dec7ebe', '{"Z":0}', '{"RST":1,"CLK":0,"X":0}', 0, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('0bda1432-4651-4fa0-ba78-77687728bb69', '{"Z":0}', '{"RST":0,"CLK":0,"X":0}', 1, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('62139eed-bb9a-4afb-94a5-5a661b9a9bde', '{"Z":0}', '{"RST":0,"CLK":1,"X":0}', 2, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('5110e991-2249-4b8d-b077-f733390ef8ed', '{"Z":0}', '{"RST":0,"CLK":0,"X":1}', 3, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('c7060f22-c40d-4ac4-81b4-60192e04c960', '{"Z":1}', '{"RST":0,"CLK":1,"X":1}', 4, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('21c177e3-59d7-4cee-aa00-b304340ee4c3', '{"Z":1}', '{"RST":0,"CLK":0,"X":1}', 5, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('e52d7af3-d183-4194-b4db-93dddbc00bd1', '{"Z":0}', '{"RST":0,"CLK":1,"X":1}', 6, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('4a9d68b5-44eb-41a6-a58f-b29164e05707', '{"Z":0}', '{"RST":0,"CLK":0,"X":0}', 7, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('fc066ee8-deaf-49fa-b958-03db2eba6615', '{"Z":0}', '{"RST":0,"CLK":1,"X":0}', 8, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('c5f8cc26-13ca-455c-b06c-841c6b964e50', '{"Z":0}', '{"RST":0,"CLK":0,"X":1}', 9, '61b7aea6-6e59-42b2-9389-dae22e70b839');
INSERT INTO public.level_test_steps (id, expected_json, inputs_json, step_index, test_case_id) VALUES ('e955fd50-d3fb-4c37-b624-e39dab66c28f', '{"Z":1}', '{"RST":0,"CLK":1,"X":1}', 10, '61b7aea6-6e59-42b2-9389-dae22e70b839');


--
-- Data for Name: levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L00_EXPR', '用逻辑门实现：Y = (A AND (NOT B)) OR C', 'null', '表达式实现（真值表入门）', '{"A":{"type":"Button","label":"A","x":40,"y":40},"B":{"type":"Button","label":"B","x":40,"y":120},"C":{"type":"Button","label":"C","x":40,"y":200},"Y":{"type":"Lamp","label":"Y","x":620,"y":120}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L01_NAND', '用 And+Not 搭建 NAND：Y = NOT(A AND B)', 'null', 'NAND 实现', '{"A":{"type":"Button","label":"A","x":40,"y":40},"B":{"type":"Button","label":"B","x":40,"y":120},"Y":{"type":"Lamp","label":"Y","x":620,"y":80}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L02_XOR', '仅用 And/Or/Not 搭建异或：Y = A XOR B', 'null', 'XOR 实现（不用 Xor 元件）', '{"A":{"type":"Button","label":"A","x":40,"y":40},"B":{"type":"Button","label":"B","x":40,"y":120},"Y":{"type":"Lamp","label":"Y","x":620,"y":80}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L03_SIMPLIFY', '目标函数：Y = (A AND B) OR (A AND (NOT B))。提示：可用布尔代数化简。', 'null', '布尔代数化简（输出等于 A）', '{"A":{"type":"Button","label":"A","x":40,"y":40},"B":{"type":"Button","label":"B","x":40,"y":120},"Y":{"type":"Lamp","label":"Y","x":620,"y":80}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L04_SOP_MINTERMS', '实现三变量函数：F(A,B,C) = Σm(1,2,5,7)。请用 And/Or/Not 实现输出 Y。', 'null', 'SOP 规范形式（最小项）', '{"A":{"type":"Button","label":"A","x":40,"y":40},"B":{"type":"Button","label":"B","x":40,"y":120},"C":{"type":"Button","label":"C","x":40,"y":200},"Y":{"type":"Lamp","label":"Y","x":620,"y":120}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L05_KMAP_4VAR', '实现四变量函数：F(W,X,Y,Z) = Σm(0,1,2,3,7,11,15)。请用 And/Or/Not 实现输出 F。', 'null', '卡诺图化简（4 变量）', '{"W":{"type":"Button","label":"W","x":40,"y":40},"X":{"type":"Button","label":"X","x":40,"y":110},"Y":{"type":"Button","label":"Y","x":40,"y":180},"Z":{"type":"Button","label":"Z","x":40,"y":250},"F":{"type":"Lamp","label":"F","x":620,"y":145}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L06_MAJORITY', '实现多数表决：当 A,B,C 中至少两个为 1 时，Y=1，否则 Y=0。', 'null', '组合逻辑设计：三输入多数表决', '{"A":{"type":"Button","label":"A","x":40,"y":40},"B":{"type":"Button","label":"B","x":40,"y":120},"C":{"type":"Button","label":"C","x":40,"y":200},"Y":{"type":"Lamp","label":"Y","x":620,"y":120}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L07_MUX2', '实现 2:1 多路选择器：当 S=0 时 Y=D0；当 S=1 时 Y=D1。', 'null', '2:1 MUX（用门电路实现）', '{"D0":{"type":"Button","label":"D0","x":40,"y":40},"D1":{"type":"Button","label":"D1","x":40,"y":120},"S":{"type":"Button","label":"S","x":40,"y":200},"Y":{"type":"Lamp","label":"Y","x":620,"y":120}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L08_DECODER_2x4', '实现 2→4 Decoder：当 EN=1 时，(A,B)=00/01/10/11 分别令 Y0/Y1/Y2/Y3 为 1（独热）；当 EN=0 时全为 0。', 'null', '2→4 译码器（含使能 EN）', '{"A":{"type":"Button","label":"A","x":40,"y":60},"B":{"type":"Button","label":"B","x":40,"y":140},"EN":{"type":"Button","label":"EN","x":40,"y":220},"Y0":{"type":"Lamp","label":"Y0","x":620,"y":20},"Y1":{"type":"Lamp","label":"Y1","x":620,"y":80},"Y2":{"type":"Lamp","label":"Y2","x":620,"y":140},"Y3":{"type":"Lamp","label":"Y3","x":620,"y":200}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L09_ENCODER_4x2', '实现编码器：I0/I1/I2/I3 为独热输入；输出 (O1,O0) 为二进制编码，V 表示是否有任意输入为 1。约定：I0->00, I1->01, I2->10, I3->11；全 0 时 V=0 且 O1O0=00。', 'null', '4→2 编码器（one-hot 输入）', '{"I0":{"type":"Button","label":"I0","x":40,"y":20},"I1":{"type":"Button","label":"I1","x":40,"y":90},"I2":{"type":"Button","label":"I2","x":40,"y":160},"I3":{"type":"Button","label":"I3","x":40,"y":230},"O1":{"type":"Lamp","label":"O1","x":620,"y":70},"O0":{"type":"Lamp","label":"O0","x":620,"y":130},"V":{"type":"Lamp","label":"V","x":620,"y":190}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L10_FULL_ADDER', '实现 1-bit 全加器：输入 A,B,Cin；输出 Sum,Cout。', 'null', '全加器（Full Adder）', '{"A":{"type":"Button","label":"A","x":40,"y":40},"B":{"type":"Button","label":"B","x":40,"y":120},"Cin":{"type":"Button","label":"Cin","x":40,"y":200},"Sum":{"type":"Lamp","label":"Sum","x":620,"y":90},"Cout":{"type":"Lamp","label":"Cout","x":620,"y":170}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L11_ADDER_2BIT', '实现 2-bit 加法：A1A0 + B1B0 => Cout S1 S0（无 Cin）。', 'null', '2-bit 串行进位加法器（Ripple Carry）', '{"A1":{"type":"Button","label":"A1","x":40,"y":20},"A0":{"type":"Button","label":"A0","x":40,"y":80},"B1":{"type":"Button","label":"B1","x":40,"y":160},"B0":{"type":"Button","label":"B0","x":40,"y":220},"S1":{"type":"Lamp","label":"S1","x":620,"y":80},"S0":{"type":"Lamp","label":"S0","x":620,"y":140},"Cout":{"type":"Lamp","label":"Cout","x":620,"y":200}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L12_SUB_2BIT', '实现 2-bit 无符号减法：A1A0 - B1B0 => D1D0 与 Borrow（当 A<B 时 Borrow=1）。', 'null', '2-bit 减法器（A - B）', '{"A1":{"type":"Button","label":"A1","x":40,"y":20},"A0":{"type":"Button","label":"A0","x":40,"y":80},"B1":{"type":"Button","label":"B1","x":40,"y":160},"B0":{"type":"Button","label":"B0","x":40,"y":220},"D1":{"type":"Lamp","label":"D1","x":620,"y":80},"D0":{"type":"Lamp","label":"D0","x":620,"y":140},"Borrow":{"type":"Lamp","label":"Borrow","x":620,"y":200}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L13_COMP_2BIT', '比较 2-bit 无符号数 A 与 B：输出 GT(>)、EQ(=)、LT(<)。要求三者始终独热。', 'null', '2-bit 比较器（GT/EQ/LT）', '{"A1":{"type":"Button","label":"A1","x":40,"y":20},"A0":{"type":"Button","label":"A0","x":40,"y":80},"B1":{"type":"Button","label":"B1","x":40,"y":160},"B0":{"type":"Button","label":"B0","x":40,"y":220},"GT":{"type":"Lamp","label":"GT","x":620,"y":60},"EQ":{"type":"Lamp","label":"EQ","x":620,"y":130},"LT":{"type":"Lamp","label":"LT","x":620,"y":200}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L14_ALU_1BIT', '实现 1-bit ALU：Op1Op0=00->AND，01->OR，10->XOR，11->ADD(输出 Sum 与 Cout)。非 ADD 时 Cout=0。', 'null', '1-bit ALU（AND/OR/XOR/ADD）', '{"A":{"type":"Button","label":"A","x":40,"y":40},"B":{"type":"Button","label":"B","x":40,"y":120},"Op1":{"type":"Button","label":"Op1","x":40,"y":200},"Op0":{"type":"Button","label":"Op0","x":40,"y":260},"Y":{"type":"Lamp","label":"Y","x":620,"y":120},"Cout":{"type":"Lamp","label":"Cout","x":620,"y":200}}', false);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L15_SR_LATCH', '用两个 Nor 门交叉反馈实现 SR 锁存器（S/R 高有效）：S=1置位，R=1复位，S=R=0保持。请输出 Q 与 Qn。', 'null', 'SR 锁存器（用 NOR 交叉反馈）', '{"S":{"type":"Button","label":"S","x":40,"y":80},"R":{"type":"Button","label":"R","x":40,"y":160},"Q":{"type":"Lamp","label":"Q","x":620,"y":90},"Qn":{"type":"Lamp","label":"Qn","x":620,"y":170}}', true);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L16_DFF_SAMPLE', '连接预置 Dff：RST=1 时 Q 复位为 0；在 CLK 上升沿采样 D 到 Q；其余时间保持。', 'null', 'D 触发器采样（带异步复位）', '{"D":{"type":"Button","label":"D","x":40,"y":40},"CLK":{"type":"Button","label":"CLK","x":40,"y":120},"RST":{"type":"Button","label":"RST","x":40,"y":200},"FF":{"type":"Dff","label":"DFF","x":320,"y":110,"bits":1,"polarity.clock":true,"polarity.arst":true,"arst_value":"0","initial":"0"},"Q":{"type":"Lamp","label":"Q","x":620,"y":120}}', true);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L17_TFF', '实现 TFF：RST 复位 Q=0；在 CLK 上升沿：若 T=0 则 Q 保持；若 T=1 则 Q 翻转。提示：可用 D = T XOR Q。', 'null', 'T 触发器（用 DFF 实现）', '{"T":{"type":"Button","label":"T","x":40,"y":40},"CLK":{"type":"Button","label":"CLK","x":40,"y":120},"RST":{"type":"Button","label":"RST","x":40,"y":200},"FF":{"type":"Dff","label":"DFF","x":320,"y":110,"bits":1,"polarity.clock":true,"polarity.arst":true,"arst_value":"0","initial":"0"},"Q":{"type":"Lamp","label":"Q","x":620,"y":120}}', true);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L18_SHIFTREG_2BIT', '实现 2-bit shift register：每个 CLK 上升沿：Q0<-Din，Q1<-Q0(旧)。RST 复位清零。', 'null', '2-bit 移位寄存器（串入串移）', '{"Din":{"type":"Button","label":"Din","x":40,"y":40},"CLK":{"type":"Button","label":"CLK","x":40,"y":120},"RST":{"type":"Button","label":"RST","x":40,"y":200},"FF0":{"type":"Dff","label":"FF0","x":280,"y":70,"bits":1,"polarity.clock":true,"polarity.arst":true,"arst_value":"0","initial":"0"},"FF1":{"type":"Dff","label":"FF1","x":380,"y":70,"bits":1,"polarity.clock":true,"polarity.arst":true,"arst_value":"0","initial":"0"},"Q0":{"type":"Lamp","label":"Q0","x":620,"y":90},"Q1":{"type":"Lamp","label":"Q1","x":620,"y":170}}', true);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L19_COUNTER_2BIT', '实现同步二进制计数器：RST 清零；每次 CLK 上升沿：Q 从 00->01->10->11->00 循环。提示：Q0_next=NOT Q0；Q1_next=Q1 XOR Q0。', 'null', '2-bit 同步计数器（Mod-4）', '{"CLK":{"type":"Button","label":"CLK","x":40,"y":80},"RST":{"type":"Button","label":"RST","x":40,"y":160},"FF0":{"type":"Dff","label":"FF0(Q0)","x":300,"y":70,"bits":1,"polarity.clock":true,"polarity.arst":true,"arst_value":"0","initial":"0"},"FF1":{"type":"Dff","label":"FF1(Q1)","x":400,"y":70,"bits":1,"polarity.clock":true,"polarity.arst":true,"arst_value":"0","initial":"0"},"Q0":{"type":"Lamp","label":"Q0","x":620,"y":90},"Q1":{"type":"Lamp","label":"Q1","x":620,"y":170}}', true);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L20_RAM_2x1_DFF', '实现 2-word 1-bit 存储：地址 A 选择字；CLK 上升沿在 WE=1 时写入 D；输出 Y 为当前地址读出值。RST 清零两字。', 'null', '2×1bit RAM（用 DFF + 译码/选择实现）', '{"A":{"type":"Button","label":"A(addr)","x":40,"y":40},"D":{"type":"Button","label":"D(data)","x":40,"y":110},"WE":{"type":"Button","label":"WE","x":40,"y":180},"CLK":{"type":"Button","label":"CLK","x":40,"y":250},"RST":{"type":"Button","label":"RST","x":40,"y":320},"M0":{"type":"Dff","label":"M0","x":300,"y":120,"bits":1,"polarity.clock":true,"polarity.arst":true,"polarity.enable":true,"arst_value":"0","initial":"0"},"M1":{"type":"Dff","label":"M1","x":420,"y":120,"bits":1,"polarity.clock":true,"polarity.arst":true,"polarity.enable":true,"arst_value":"0","initial":"0"},"Y":{"type":"Lamp","label":"Y","x":620,"y":170}}', true);
INSERT INTO public.levels (code, description, template_circuit_json, title, devices, allow_cycles) VALUES ('L21_FSM_EDGE_DETECT', '用 DFF 构造状态机：Prev 记录上一拍 X；输出寄存器 Z 满足 Z_next = (NOT Prev) AND X。RST 清零。观察 Z 在检测到 0→1 时输出一个周期的 1。', 'null', 'FSM 案例：同步上升沿检测（0→1）', '{"X":{"type":"Button","label":"X","x":40,"y":40},"CLK":{"type":"Button","label":"CLK","x":40,"y":120},"RST":{"type":"Button","label":"RST","x":40,"y":200},"Prev":{"type":"Dff","label":"Prev","x":300,"y":90,"bits":1,"polarity.clock":true,"polarity.arst":true,"arst_value":"0","initial":"0"},"ZFF":{"type":"Dff","label":"ZFF","x":420,"y":90,"bits":1,"polarity.clock":true,"polarity.arst":true,"arst_value":"0","initial":"0"},"Z":{"type":"Lamp","label":"Z","x":620,"y":120}}', true);


--
-- Data for Name: persistent_logins; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: question_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: question_tag_map; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000015', '10000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000015', '20000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000016', '10000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000016', '20000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000017', '10000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000017', '20000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000018', '10000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('30000000-0000-0000-0000-000000000018', '20000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('31000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('32000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000001', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('33000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000003', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000014', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('34000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('35000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000005', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000004', '2026-02-23 08:28:36.851164+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('36000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000006', '2026-02-23 08:28:36.851164+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('50000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('51000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000011', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('52000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000012', '2026-02-23 14:26:42.55366+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('53000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000013', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '2026-02-23 14:26:42.55366+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', '2026-02-23 14:26:42.55366+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('54000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000014', '2026-02-23 14:26:42.55366+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000015', '10000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('60000000-0000-0000-0000-000000000015', '20000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000005', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000005', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('61000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('62000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('63000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000023', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('64000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000024', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000021', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000022', '2026-02-23 14:42:13.022167+00', 70);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 50);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 100);
INSERT INTO public.question_tag_map (question_id, tag_id, created_at, weight) VALUES ('65000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000025', '2026-02-23 14:42:13.022167+00', 50);


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('46db3d79-758d-434e-b132-3b035d56a4cf', '{"options": [{"id": "A", "text": "(AB)''=A''+B''"}, {"id": "B", "text": "(A+B)''=A''B''"}, {"id": "C", "text": "A+B = AB"}, {"id": "D", "text": "A''=A"}]}', '2026-02-12 03:32:51.466024+00', 2, '(A+B)''=A''B''。', 'zh-CN', '{"correctOptionId": "B"}', 'DRAFT', '下列哪个是德摩根定律的正确形式？', 'SINGLE_CHOICE', '2026-02-12 03:32:51.466024+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "0"}, {"id": "B", "text": "1"}]}', '2026-02-23 08:28:36.851164+00', 1, 'AND门只有所有输入均为1时才输出1；A=1,B=0 → 输出0。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-01) AND门：A=1, B=0 时输出为？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "0"}, {"id": "B", "text": "1"}]}', '2026-02-23 08:28:36.851164+00', 1, 'XOR（异或）：相同输入为0，不同输入为1；A=B=1 → 输出0。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-01) XOR门：A=1, B=1 时输出为？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "NAND"}, {"id": "B", "text": "NOR"}, {"id": "C", "text": "XOR"}]}', '2026-02-23 08:28:36.851164+00', 1, 'NOR = NOT(A+B)，即对 OR 结果取反。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-01) 哪种门等价于 NOT(A OR B)？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "A"}, {"id": "B", "text": "0"}, {"id": "C", "text": "1"}]}', '2026-02-23 08:28:36.851164+00', 1, '幂等律：A+A=A；A·A=A。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-02) 幂等律：A + A = ?', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "A"}, {"id": "B", "text": "0"}, {"id": "C", "text": "1"}]}', '2026-02-23 08:28:36.851164+00', 1, '恒等律：A·1=A；A+0=A。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-02) 恒等律：A · 1 = ?', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000006', '{"format": "single_choice", "options": [{"id": "A", "text": "A"}, {"id": "B", "text": "A·B"}, {"id": "C", "text": "B"}]}', '2026-02-23 08:28:36.851164+00', 1, '吸收律：A+AB=A；A(A+B)=A。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-02) 吸收律：A + A·B = ?', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000007', '{"format": "single_choice", "options": [{"id": "A", "text": "NOT(A) · NOT(B)"}, {"id": "B", "text": "NOT(A) + NOT(B)"}, {"id": "C", "text": "A + B"}]}', '2026-02-23 08:28:36.851164+00', 1, 'NOT(A·B) = NOT(A)+NOT(B)：乘积取反变为各项取反后相或。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-03) 德摩根定律：NOT(A·B) 等价于？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000008', '{"format": "single_choice", "options": [{"id": "A", "text": "A NAND A"}, {"id": "B", "text": "A NAND 0"}, {"id": "C", "text": "A NAND 1"}]}', '2026-02-23 08:28:36.851164+00', 1, 'NAND(A,A) = NOT(A·A) = NOT(A)，同输入 NAND 即取反。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-03) 仅用 NAND 门实现 NOT A，做法是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000009', '{"format": "single_choice", "options": [{"id": "A", "text": "NAND"}, {"id": "B", "text": "NOR"}, {"id": "C", "text": "XNOR"}]}', '2026-02-23 08:28:36.851164+00', 1, 'NOR = NOT(A+B)，即 OR 结果取反。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-03) NOT(A + B) 对应哪种逻辑门？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000010', '{"format": "single_choice", "options": [{"id": "A", "text": "m(0,1)"}, {"id": "B", "text": "m(1,3)"}, {"id": "C", "text": "m(2,3)"}]}', '2026-02-23 08:28:36.851164+00', 2, '(0,1)→二进制01=1→m1；(1,1)→二进制11=3→m3；故为 m(1,3)。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-04) 2变量F(A,B)在(0,1)和(1,1)时F=1，最小项编号集合是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000011', '{"format": "single_choice", "options": [{"id": "A", "text": "若干变量相或"}, {"id": "B", "text": "所有n个变量相与（各取原变量或反变量）"}, {"id": "C", "text": "单个变量的取反"}]}', '2026-02-23 08:28:36.851164+00', 2, 'SOP的每一项是最小项：所有n个变量相 AND，各变量可取原变量或反变量。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-04) 标准SOP中，每个"积项"（最小项）是指？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000012', '{"format": "single_choice", "options": [{"id": "A", "text": "编号0和2"}, {"id": "B", "text": "除0和2以外的所有编号"}, {"id": "C", "text": "无法判断"}]}', '2026-02-23 08:28:36.851164+00', 2, '最大项编号集合即F=0的最小项编号，ΠM(0,2)表示在输入0和2处F=0。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-04) F = ΠM(0,2) 表示 F 在哪些编号上为0？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000013', '{"format": "single_choice", "options": [{"id": "A", "text": "任意2的整数倍"}, {"id": "B", "text": "2的幂次（1,2,4,8）"}, {"id": "C", "text": "任意连续格数"}]}', '2026-02-23 08:28:36.851164+00', 2, '卡诺图分组必须是2的幂次（1,2,4,8,…），才能消去相应数量的变量。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-05) 3变量卡诺图中，合法的分组大小是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000014', '{"format": "single_choice", "options": [{"id": "A", "text": "减少实现所需的门数量与级数"}, {"id": "B", "text": "减少输入变量个数"}, {"id": "C", "text": "减少真值表行数"}]}', '2026-02-23 08:28:36.851164+00', 2, '化简通过合并最小项得到最简 SOP，减少门数/级数，降低实现成本。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-05) 卡诺图化简的主要目标是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000015', '{"format": "single_choice", "options": [{"id": "A", "text": "是，左右/上下边界均相邻可环绕"}, {"id": "B", "text": "否，边界格不相邻"}]}', '2026-02-23 08:28:36.851164+00', 2, '卡诺图采用格雷码排列，行列边界均可环绕，形成"圆柱面"拓扑相邻关系。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-05) 卡诺图的边界格是否可以"环绕"相邻？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000016', '{"format": "single_choice", "options": [{"id": "A", "text": "不同路径门延迟不一致导致信号到达时间差"}, {"id": "B", "text": "输入电平本身不稳定"}, {"id": "C", "text": "使用了XOR门"}]}', '2026-02-23 08:28:36.851164+00', 2, '毛刺/冒险根本原因：多条信号路径延迟不同，切换瞬间输出出现意外脉冲。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-06) 组合逻辑"毛刺/冒险"的典型成因是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000017', '{"format": "single_choice", "options": [{"id": "A", "text": "输出本应稳定为1，却短暂下降至0"}, {"id": "B", "text": "输出本应稳定为0，却短暂升至1"}, {"id": "C", "text": "输出在0和1之间反复振荡"}]}', '2026-02-23 08:28:36.851164+00', 2, '静态1冒险：稳态为1，因路径延迟不一致出现短暂0脉冲。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-06) "静态1冒险"（Static-1 Hazard）是指？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('30000000-0000-0000-0000-000000000018', '{"format": "single_choice", "options": [{"id": "A", "text": "增加覆盖相邻最小项的冗余共识项（Consensus Term）"}, {"id": "B", "text": "将所有AND门改为XOR门"}, {"id": "C", "text": "降低工作频率"}]}', '2026-02-23 08:28:36.851164+00', 2, '添加冗余共识项使相邻分组产生重叠覆盖，消除切换时的毛刺。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-06) 消除SOP实现中静态1冒险的常用方法是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('31000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "0"}, {"id": "B", "text": "1"}]}', '2026-02-23 08:28:36.851164+00', 1, 'NAND = NOT(A·B) = NOT(1·1) = NOT(1) = 0。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-01) NAND门：A=1, B=1 时，输出为？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('31000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "0"}, {"id": "B", "text": "1"}, {"id": "C", "text": "取决于具体型号"}]}', '2026-02-23 08:28:36.851164+00', 1, 'AND门所有输入均为1时输出1，与输入个数无关。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-01) 三输入AND门：A=1, B=1, C=1 时，输出为？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('31000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "OR"}, {"id": "B", "text": "XOR"}, {"id": "C", "text": "XNOR"}]}', '2026-02-23 08:28:36.851164+00', 1, 'XOR（异或）：同0异1。XNOR（同或）：同1异0，与XOR相反。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-01) 哪种门的功能是"相同输入时输出0，不同输入时输出1"？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('31000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "AND"}, {"id": "B", "text": "OR"}, {"id": "C", "text": "NAND"}]}', '2026-02-23 08:28:36.851164+00', 2, 'NAND 和 NOR 均是通用门，可单独实现任意布尔函数（由德摩根定律与逻辑完备性保证）。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-01) 仅用一种门即可实现任意布尔函数，该类门称"通用门"。以下哪种是通用门？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('31000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "0"}, {"id": "B", "text": "1"}]}', '2026-02-23 08:28:36.851164+00', 1, 'NOR = NOT(A+B) = NOT(0+0) = NOT(0) = 1。NOR门仅在所有输入为0时输出1。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-01) NOR门：A=0, B=0 时，输出为？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('32000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "0"}, {"id": "B", "text": "A"}, {"id": "C", "text": "1"}]}', '2026-02-23 08:28:36.851164+00', 1, '互补律：A·A''=0；对应地，A+A''=1。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-02) 互补律：A · A'' = ?（A''表示NOT A）', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('32000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "A"}, {"id": "B", "text": "1"}, {"id": "C", "text": "0"}]}', '2026-02-23 08:28:36.851164+00', 1, '零元律（OR）：A+1=1；零元律（AND）：A·0=0。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-02) 零元律：A + 1 = ?', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('32000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "A"}, {"id": "B", "text": "0"}, {"id": "C", "text": "1"}]}', '2026-02-23 08:28:36.851164+00', 1, '双重否定律：两次取反恢复原值，NOT(NOT(A))=A。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-02) 双重否定律：NOT(NOT(A)) = ?', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('32000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "A·B + A·C"}, {"id": "B", "text": "A + B·C"}, {"id": "C", "text": "A·B·C"}]}', '2026-02-23 08:28:36.851164+00', 1, '布尔分配律与普通代数一致：A(B+C)=AB+AC。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-02) 分配律：A · (B + C) = ?', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('32000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "A + B"}, {"id": "B", "text": "A"}, {"id": "C", "text": "A·B"}]}', '2026-02-23 08:28:36.851164+00', 2, 'A+A''B = (A+A'')(A+B) = 1·(A+B) = A+B（推广吸收律，利用分配律展开可得）。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-02) 化简：A + A''·B = ?（A''=NOT A）', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('33000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "NOT A · NOT B · NOT C"}, {"id": "B", "text": "NOT A + NOT B + NOT C"}, {"id": "C", "text": "A + B + C"}]}', '2026-02-23 08:28:36.851164+00', 2, '德摩根推广：多变量乘积取反，等于各变量取反后相或。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-03) 三变量德摩根：NOT(A·B·C) = ?', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('33000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "A·B"}, {"id": "B", "text": "A+B"}, {"id": "C", "text": "A''·B''"}]}', '2026-02-23 08:28:36.851164+00', 2, '德摩根：NOT(A''+B'') = NOT(A'')·NOT(B'') = A·B。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-03) 化简 NOT(A'' + B'')（A''=NOT A，B''=NOT B）= ?', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('33000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "A、B直接接一个NAND门"}, {"id": "B", "text": "先NAND(A,A)和NAND(B,B)各自取非，再将两结果接入NAND"}, {"id": "C", "text": "三个NAND门串联"}]}', '2026-02-23 08:28:36.851164+00', 2, 'OR(A,B)=NOT(NOT A·NOT B)=NAND(NOT A,NOT B)；NOT A=NAND(A,A)，NOT B=NAND(B,B)，故选B。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-03) 仅使用NAND门实现 OR(A,B)，正确连接方式是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('33000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "OR(NOT A, NOT B)"}, {"id": "B", "text": "NOR(A, B)"}, {"id": "C", "text": "AND(NOT A, NOT B)"}]}', '2026-02-23 08:28:36.851164+00', 2, '由德摩根：NAND(A,B)=NOT(A·B)=NOT A+NOT B=OR(NOT A,NOT B)，即"输入取反的OR门"。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-03) 气泡推进（Bubble Pushing）：NAND(A,B) 等价于？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('33000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "NOT A · NOT B"}, {"id": "B", "text": "NOT A + NOT B"}, {"id": "C", "text": "A · B"}]}', '2026-02-23 08:28:36.851164+00', 2, '由德摩根：NOR(A,B)=NOT(A+B)=NOT A·NOT B，即"输入取反的AND门"。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-03) NOR(A,B) 经德摩根变换等价于？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('34000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "6"}, {"id": "B", "text": "8"}, {"id": "C", "text": "16"}]}', '2026-02-23 08:28:36.851164+00', 1, 'n变量有2ⁿ种输入组合，对应2ⁿ个最小项。3变量共2³=8个。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-04) n=3变量的布尔函数共有多少个最小项？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('34000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "A''BC"}, {"id": "B", "text": "AB''C"}, {"id": "C", "text": "ABC''"}]}', '2026-02-23 08:28:36.851164+00', 2, '5的三位二进制为101，A=1,B=0,C=1，对应积项 A·B''·C。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-04) 三变量(A高位,B,C低位)最小项m₅对应的标准积项是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('34000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "包含全部n个变量，各取原变量或反变量之一"}, {"id": "B", "text": "只包含值为1的变量"}, {"id": "C", "text": "至少包含一个变量"}]}', '2026-02-23 08:28:36.851164+00', 2, '最小项要求全部n个变量都出现，每个变量根据输入取值选原变量或反变量。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-04) 标准SOP（最小项之和）中，每个最小项须满足？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('34000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "A''B + AB''"}, {"id": "B", "text": "A''B'' + AB"}, {"id": "C", "text": "A''B'' + A''B"}]}', '2026-02-23 08:28:36.851164+00', 2, 'm0=(A=0,B=0)→A''B''；m3=(A=1,B=1)→AB；SOP = A''B''+AB（即XNOR）。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-04) 两变量A(高位),B(低位)，F=Σm(0,3)的标准SOP是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('34000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "(0,0) 和 (1,1)"}, {"id": "B", "text": "(0,1) 和 (1,0)"}, {"id": "C", "text": "(0,0) 和 (0,1)"}]}', '2026-02-23 08:28:36.851164+00', 2, 'M1→(0,1)处F=0；M2→(1,0)处F=0；余下 m0=(0,0) 和 m3=(1,1) 处F=1。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-04) 两变量A(高位),B(低位)，F=ΠM(1,2)，F=1的输入组合是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('35000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "2"}, {"id": "B", "text": "4"}, {"id": "C", "text": "8"}]}', '2026-02-23 08:28:36.851164+00', 1, '2变量有2²=4种输入组合，卡诺图共4个格，排列为2×2。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-05) 2变量卡诺图共有几个格（cell）？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('35000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "1"}, {"id": "B", "text": "2"}, {"id": "C", "text": "4"}]}', '2026-02-23 08:28:36.851164+00', 2, '含2ᵏ格的分组消去k个变量：4=2²，消去2个变量，剩余4-2=2个文字。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-05) 4变量卡诺图中，一个含4格的分组，化简后积项包含几个文字？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('35000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "必须当作1"}, {"id": "B", "text": "必须当作0"}, {"id": "C", "text": "可视化简需要灵活指定为0或1"}]}', '2026-02-23 08:28:36.851164+00', 2, '无关项代表不关心的输出，化简时可任意指定0或1以获得更大/更优分组。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-05) 卡诺图中无关项（Don''t-care，标记X）的处理方式是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('35000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "A+B"}, {"id": "B", "text": "A·B"}, {"id": "C", "text": "1（常数）"}]}', '2026-02-23 08:28:36.851164+00', 2, '所有格均为1，整个卡诺图合为一组，函数恒为1（常数真）。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-05) 2变量卡诺图中，F=Σm(0,1,2,3)，化简结果为？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('35000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "覆盖最小项数最多的主蕴含项"}, {"id": "B", "text": "包含至少一个被它唯一覆盖的最小项（其他主蕴含项均不覆盖）"}, {"id": "C", "text": "只含1个格的最小分组"}]}', '2026-02-23 08:28:36.851164+00', 2, '本质主蕴含项覆盖了某个"独占"最小项（无其他PI可覆盖），必须被选入最终表达式。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-05) 关于"本质主蕴含项（Essential Prime Implicant）"，描述正确的是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('36000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "输出本应稳定为0，却出现短暂的1脉冲"}, {"id": "B", "text": "输出本应稳定为1，却出现短暂的0脉冲"}, {"id": "C", "text": "输出在0和1之间持续振荡"}]}', '2026-02-23 08:28:36.851164+00', 2, '静态0冒险：稳态为0，因延迟不一致短暂出现1脉冲（与静态1冒险方向相反）。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-06) 静态0冒险（Static-0 Hazard）是指？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('36000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "输出在本该跳变一次时发生多次意外翻转（如0→1→0→1）"}, {"id": "B", "text": "输出完全不发生跳变"}, {"id": "C", "text": "仅在时序逻辑中出现"}]}', '2026-02-23 08:28:36.851164+00', 2, '动态冒险：信号本应只跳变一次，却因多级延迟不一致出现多次翻转。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-06) 动态冒险（Dynamic Hazard）的特征是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('36000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "两个相邻的1格未被任何共同（或重叠）的分组覆盖"}, {"id": "B", "text": "某分组格数不是2的幂"}, {"id": "C", "text": "存在无关项（Don''t-care）"}]}', '2026-02-23 08:28:36.851164+00', 2, '若逻辑相邻（仅一位不同）的两个1格分属不同分组且无重叠，切换该位时会出现静态1冒险。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-06) 在卡诺图中，如何判断SOP实现存在静态1冒险？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('36000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "BC"}, {"id": "B", "text": "AC"}, {"id": "C", "text": "A''B"}]}', '2026-02-23 08:28:36.851164+00', 3, '添加共识项BC后F=AB+A''C+BC。当B=C=1时BC=1恒成立，无论A如何变化输出均稳定为1。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-06) F=AB+A''C，B=C=1时改变A会产生毛刺。消除毛刺应添加的冗余项是？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('36000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "静态1冒险"}, {"id": "B", "text": "静态0冒险"}, {"id": "C", "text": "POS不会产生冒险"}]}', '2026-02-23 08:28:36.851164+00', 2, 'SOP（AND-OR）实现易产生静态1冒险；POS（OR-AND）实现易产生静态0冒险。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-BOOL] (DC-BOOL-06) POS（和之积）形式的表达式可能存在哪种静态冒险？', 'SINGLE_CHOICE', '2026-02-23 08:28:36.851164+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "温度传感器输出的连续电压"}, {"id": "B", "text": "正弦波音频信号"}, {"id": "C", "text": "高/低电平跳变的矩形脉冲序列"}]}', '2026-02-23 14:26:42.55366+00', 1, '数字信号在时间和幅度上均离散（高/低电平表示0和1）；温度电压和正弦波均为时间和幅度连续的模拟信号。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-01) 下列信号中，哪种属于数字信号？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "1种"}, {"id": "B", "text": "2种"}, {"id": "C", "text": "4种"}]}', '2026-02-23 14:26:42.55366+00', 1, 'bit是最小信息单元，只能取0或1两种离散状态，这是数字电路"二值逻辑"的基础。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-01) 一个二进制位（bit）能且仅能表示几种状态？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "抗干扰能力强"}, {"id": "B", "text": "便于大规模集成与数字存储"}, {"id": "C", "text": "可以无损地表示和处理任意精度的连续模拟量"}]}', '2026-02-23 14:26:42.55366+00', 1, 'ADC量化必然引入误差，数字系统无法无损表示任意精度连续量；抗干扰强、便于集成与存储均是数字电路的突出优点。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-01) 以下哪项不是数字电路相比模拟电路的优点？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "11"}, {"id": "B", "text": "13"}, {"id": "C", "text": "15"}]}', '2026-02-23 14:26:42.55366+00', 1, '按权展开：1×2³+1×2²+0×2¹+1×2⁰ = 8+4+0+1 = 13。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-02) 二进制数 1101(2) 转换为十进制数是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "0x1A"}, {"id": "B", "text": "0x1B"}, {"id": "C", "text": "0x1C"}]}', '2026-02-23 14:26:42.55366+00', 1, '27 = 1×16+11；十六进制中11用字母B表示，故结果为0x1B。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-02) 十进制数 27 转换为十六进制是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000006', '{"format": "single_choice", "options": [{"id": "A", "text": "100111(2)"}, {"id": "B", "text": "100011(2)"}, {"id": "C", "text": "101011(2)"}]}', '2026-02-23 14:26:42.55366+00', 2, '八进制转二进制：每位拆为3位二进制；4(8)→100(2)，7(8)→111(2)，拼接得100111(2)。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-02) 八进制数 47(8) 转换为二进制是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000007', '{"format": "single_choice", "options": [{"id": "A", "text": "10000101"}, {"id": "B", "text": "11111010"}, {"id": "C", "text": "11111011"}]}', '2026-02-23 14:26:42.55366+00', 1, '+5原码=00000101；取反（反码）=11111010；再加1得补码=11111011。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-03) 十进制 -5 用8位补码表示为？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000008', '{"format": "single_choice", "options": [{"id": "A", "text": "-127 ~ +127"}, {"id": "B", "text": "-128 ~ +127"}, {"id": "C", "text": "-128 ~ +128"}]}', '2026-02-23 14:26:42.55366+00', 1, 'n位补码范围：-2^(n-1) ~ 2^(n-1)-1；8位最小值10000000=-128，最大值01111111=+127。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-03) 8位二进制补码（有符号数）的表示范围是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000009', '{"format": "single_choice", "options": [{"id": "A", "text": "计算出错，需要重算"}, {"id": "B", "text": "发生了正溢出（上溢），结果不可信"}, {"id": "C", "text": "两正数之和确实为负数，完全正常"}]}', '2026-02-23 14:26:42.55366+00', 2, '0x70(+112)+0x30(+48)=160>127，超出8位补码上限，发生正溢出；结果1010 0000被错误解读为-96，不可信。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-03) 两个8位正数补码相加：0111 0000 + 0011 0000，结果符号位变为1，这说明？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000010', '{"format": "single_choice", "options": [{"id": "A", "text": "0"}, {"id": "B", "text": "1"}]}', '2026-02-23 14:26:42.55366+00', 1, 'AND（·）优先于OR（+）：B·C=1·1=1，F=0+1=1。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-04) 逻辑函数 F = A + B·C，当 A=0, B=1, C=1 时，F=？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000011', '{"format": "single_choice", "options": [{"id": "A", "text": "8"}, {"id": "B", "text": "16"}, {"id": "C", "text": "32"}]}', '2026-02-23 14:26:42.55366+00', 1, 'n个输入变量有2ⁿ种输入组合；4变量：2⁴=16行。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-04) 四变量逻辑函数的真值表共有多少行？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('50000000-0000-0000-0000-000000000012', '{"format": "single_choice", "options": [{"id": "A", "text": "找F=0的各行对应最小项，求和"}, {"id": "B", "text": "找F=1的各行对应最小项，求和"}, {"id": "C", "text": "把所有变量的所有积项直接相加"}]}', '2026-02-23 14:26:42.55366+00', 1, '标准SOP由所有使F=1的输入对应的最小项相OR构成；F=0的行对应最大项，用于构造POS（积之和的对偶形式）。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-04) 从真值表写出标准SOP（与或式），正确方法是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('51000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "DAC（数模转换器）"}, {"id": "B", "text": "ADC（模数转换器）"}, {"id": "C", "text": "运算放大器（Op-Amp）"}]}', '2026-02-23 14:26:42.55366+00', 1, 'ADC（Analog-to-Digital Converter）将连续模拟信号经采样、量化、编码转换为数字信号；DAC完成反向转换。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-01) 将模拟信号转换为数字信号的器件称为？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('51000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "程序代码的执行与存储"}, {"id": "B", "text": "音频信号的高保真连续放大"}, {"id": "C", "text": "图像文件的压缩与存储"}]}', '2026-02-23 14:26:42.55366+00', 1, '模拟电路擅长处理连续信号（如高保真音频放大）；程序执行和文件压缩/存储均属数字系统的典型强项。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-01) 以下哪类应用场景最适合采用模拟电路而非数字电路？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('51000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "取值连续，可以是任意实数"}, {"id": "B", "text": "取值离散，通常只有0和1两种"}, {"id": "C", "text": "取值随时间连续平滑变化"}]}', '2026-02-23 14:26:42.55366+00', 1, '数字信号在时间和幅度上均离散，以有限个值（通常0/1）表示信息；这是其抗干扰能力强的根本原因。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-01) 与模拟信号相比，数字信号的取值特点是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('51000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "4"}, {"id": "B", "text": "8"}, {"id": "C", "text": "16"}]}', '2026-02-23 14:26:42.55366+00', 1, '1 Byte = 8 bits，字节是计算机中最常用的基本存储单位；4位称为半字节（nibble），可表示一个十六进制数字（0~F）。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-01) 一个字节（Byte）包含多少个二进制位（bit）？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('51000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "温度计中水银柱的高度"}, {"id": "B", "text": "硬盘磁道上磁化方向（南极/北极两种状态）"}, {"id": "C", "text": "麦克风输出的连续音频电压"}]}', '2026-02-23 14:26:42.55366+00', 2, '硬盘以两种磁化方向编码0和1，是数字存储的典型例子；水银柱高度和音频电压均为连续变化的模拟量。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-01) 以下哪种存储介质利用了"两态"（离散）特性来表示数字信息？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('52000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "47"}, {"id": "B", "text": "57"}, {"id": "C", "text": "63"}]}', '2026-02-23 14:26:42.55366+00', 1, '按权展开：5×8¹+7×8⁰ = 40+7 = 47。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-02) 八进制数 57(8) 转换为十进制数是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('52000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "0xEF"}, {"id": "B", "text": "0xFF"}, {"id": "C", "text": "0xFE"}]}', '2026-02-23 14:26:42.55366+00', 1, '255 = 15×16+15 = 0xFF；F在十六进制中代表15（最大单个数字）。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-02) 十进制数 255 转换为十六进制是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('52000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "2位"}, {"id": "B", "text": "3位"}, {"id": "C", "text": "4位"}]}', '2026-02-23 14:26:42.55366+00', 1, '2⁴=16，恰好4位二进制对应一个十六进制数字（0~F），故按4位分组；3位对应八进制转换。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-02) 将二进制数转换为十六进制时，从低位（右）起每几位分为一组？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('52000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "0xCC"}, {"id": "B", "text": "0xC3"}, {"id": "C", "text": "0x3C"}]}', '2026-02-23 14:26:42.55366+00', 2, '按4位分组：高位1100(2)=12=C，低位1100(2)=12=C，拼接得0xCC。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-02) 二进制数 11001100(2) 对应的十六进制是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('52000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "1100100(2)"}, {"id": "B", "text": "1100010(2)"}, {"id": "C", "text": "1101100(2)"}]}', '2026-02-23 14:26:42.55366+00', 2, '100=64+32+4=2⁶+2⁵+2²，对应1100100(2)；验证：64+32+4=100。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-02) 十进制数 100 转换为二进制是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('53000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "完全相同（符号位0，数值位不变）"}, {"id": "B", "text": "数值位按位取反"}, {"id": "C", "text": "数值位取反再加1"}]}', '2026-02-23 14:26:42.55366+00', 1, '正数：原码=反码=补码，符号位为0，数值位不变；只有负数的补码才需要"取反加1"操作。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-03) 正数的补码与其原码的关系是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('53000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "-0"}, {"id": "B", "text": "-127"}, {"id": "C", "text": "-128"}]}', '2026-02-23 14:26:42.55366+00', 1, '10000000最高位兼作数值位，权值为-2⁷=-128，故表示-128；这是8位补码唯一没有对应正数的特殊值（最小值）。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-03) 8位补码 10000000 代表哪个十进制数？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('53000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "-10"}, {"id": "B", "text": "-9"}, {"id": "C", "text": "-8"}]}', '2026-02-23 14:26:42.55366+00', 2, '最高位1→负数；求反：00001001；加1得00001010=10；故真值为-10。（验证：-128+64+32+16+4+2=-10）', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-03) 8位补码 11110110 对应的十进制真值是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('53000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "不会；异号之和绝对值缩小，必在范围内"}, {"id": "B", "text": "可能溢出，取决于操作数大小"}, {"id": "C", "text": "一定溢出"}]}', '2026-02-23 14:26:42.55366+00', 2, '设a∈[0,127]，b∈[-128,-1]，则a+b∈[-128,126]，始终在8位补码[-128,127]范围内。溢出只在同号相加（正+正 或 负+负）时发生。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-03) 两个符号相异（一正一负）的数做8位补码加法，是否可能溢出？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('53000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "00001010 + 11111101"}, {"id": "B", "text": "00001010 + 00000011"}, {"id": "C", "text": "11110101 + 00000011"}]}', '2026-02-23 14:26:42.55366+00', 2, '减去+3等于加上-3；-3的补码：+3=00000011，取反=11111100，加1=11111101；故10-3=00001010+11111101=00000111=7。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-03) 计算补码减法 00001010 - 00000011（即10-3），等价于哪个补码加法？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('54000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "AND（与）"}, {"id": "B", "text": "OR（或）"}, {"id": "C", "text": "XOR（异或）"}]}', '2026-02-23 14:26:42.55366+00', 1, 'F=A''B+AB''即XOR（异或）的标准定义式：输入不同时F=1（A=0,B=1 或 A=1,B=0），输入相同时F=0。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-04) 逻辑表达式 F = A''B + AB''（A''=NOT A）实现的是哪种运算？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('54000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "一般逻辑表达式（非标准形式）"}, {"id": "B", "text": "真值表"}, {"id": "C", "text": "逻辑图（门电路图）"}]}', '2026-02-23 14:26:42.55366+00', 1, '真值表穷举所有输入组合及对应输出，能唯一确定逻辑函数；同一函数可有多种等价的逻辑表达式和逻辑图。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-04) 以下哪种表示方法能唯一确定一个逻辑函数？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('54000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "A"}, {"id": "B", "text": "B"}, {"id": "C", "text": "A''（即NOT A）"}]}', '2026-02-23 14:26:42.55366+00', 2, '提取公因子：F = (A''+A)·B = 1·B = B（互补律A+A''=1，恒等律1·B=B）。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-04) 化简：F = A''B + AB（A''=NOT A），结果是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('54000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "A'' + B''（即NOT A + NOT B）"}, {"id": "B", "text": "A''·B''（即NOT A · NOT B）"}, {"id": "C", "text": "A + B"}]}', '2026-02-23 14:26:42.55366+00', 2, '德摩根定律：NOT(A·B) = NOT(A)+NOT(B) = A''+B''（"积取反"变"各取反后相或"）。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-04) 逻辑函数 F = A·B 的反函数 F'' = NOT(A·B) 化简结果是？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('54000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "16"}, {"id": "B", "text": "25"}, {"id": "C", "text": "32"}]}', '2026-02-23 14:26:42.55366+00', 1, 'n变量有2ⁿ种输入组合；5变量：2⁵=32行。注意是2的5次方=32，而非5×5=25。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-FND] (DC-FND-04) 五变量逻辑函数的真值表有多少行？', 'SINGLE_CHOICE', '2026-02-23 14:26:42.55366+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000012', '{"format": "single_choice", "options": [{"id": "A", "text": "011（代表I3）"}, {"id": "B", "text": "101（代表I5）"}, {"id": "C", "text": "000（代表I0）"}]}', '2026-02-23 14:42:13.022167+00', 2, 'I7=0故不参与竞争；I5与I3同时有效，I5优先级高于I3；I5对应编码5=101(2)，故输出Y2Y1Y0=101。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-04) 8:3优先编码器（高位I7优先级最高）中，若I7=0, I5=1, I3=1 同时有效，输出编码Y2Y1Y0为？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "组合逻辑不含任何门电路"}, {"id": "B", "text": "组合逻辑输出只取决于当前输入，不含记忆元件"}, {"id": "C", "text": "组合逻辑必须使用时钟信号同步"}]}', '2026-02-23 14:42:13.022167+00', 1, '组合逻辑：任意时刻输出仅由当前输入决定，无存储/反馈元件；时序逻辑含触发器等记忆元件，输出与历史状态有关。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-01) 组合逻辑电路与时序逻辑电路最本质的区别是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "验证真值表正确性"}, {"id": "B", "text": "得到最简逻辑表达式，减少实现所需的门数量与级数"}, {"id": "C", "text": "将需求翻译为二进制编码"}]}', '2026-02-23 14:42:13.022167+00', 1, '化简步骤（卡诺图/代数法）目标是减少积项数和每项变量数，直接降低实现成本（门数/级数/延迟），而非验证真值表。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-01) 组合逻辑设计流程中，"逻辑化简"步骤（如卡诺图）的主要目的是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "D触发器"}, {"id": "B", "text": "移位寄存器"}, {"id": "C", "text": "全加器（Full Adder）"}]}', '2026-02-23 14:42:13.022167+00', 2, '全加器由纯组合门（AND/OR/XOR）构成，输出（Sum/Cout）仅取决于当前输入（A,B,Cin），无记忆元件；D触发器和移位寄存器含存储元件，属时序电路。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-01) 以下器件中，哪个属于纯组合逻辑电路？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "2位"}, {"id": "B", "text": "3位"}, {"id": "C", "text": "4位"}]}', '2026-02-23 14:42:13.022167+00', 1, '8:1 MUX需要区分8路，2³=8，故需要3位选择信号（S2S1S0）；2位只能选4路，4位可选16路。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-02) 从8路数据中选择1路输出，需要多少位选择控制信号？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "F = S·D0 + S''·D1（S''=NOT S）"}, {"id": "B", "text": "F = S''·D0 + S·D1（S''=NOT S）"}, {"id": "C", "text": "F = S + D0 + D1"}]}', '2026-02-23 14:42:13.022167+00', 1, 'S=0时选D0：F=1·D0+0·D1=D0；S=1时选D1：F=0·D0+1·D1=D1；标准表达式为F=S''·D0+S·D1。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-02) 2:1 MUX（选择端S，数据端D0/D1）的逻辑表达式是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000006', '{"format": "single_choice", "options": [{"id": "A", "text": "1变量"}, {"id": "B", "text": "2变量"}, {"id": "C", "text": "4变量"}]}', '2026-02-23 14:42:13.022167+00', 2, '4:1 MUX有4个数据输入，可穷举2变量（2²=4种组合）的所有情况：将S1S0作为函数输入，对应D0~D3接0或1即可实现任意2变量函数。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-02) 4:1 MUX可以直接（无需额外门）实现所有几变量布尔函数？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000007', '{"format": "single_choice", "options": [{"id": "A", "text": "从多路输入中选择一路输出"}, {"id": "B", "text": "将n位二进制编码转换为2ⁿ路互斥有效信号（每次仅1路有效）"}, {"id": "C", "text": "将多路模拟信号转换为数字信号"}]}', '2026-02-23 14:42:13.022167+00', 1, 'n:2ⁿ译码器将n位地址/编码映射到2ⁿ根输出线，任意时刻恰好1根处于有效电平；A描述的是MUX的功能。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-03) 译码器（Decoder）的核心功能描述正确的是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000008', '{"format": "single_choice", "options": [{"id": "A", "text": "3个（与输入位数相同）"}, {"id": "B", "text": "1个"}, {"id": "C", "text": "取决于输入地址"}]}', '2026-02-23 14:42:13.022167+00', 1, '译码器的互斥特性：3位地址对应2³=8个最小项，但每次输入只对应一个最小项为1，故仅1个输出有效；这也是译码器实现最小项的理论基础。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-03) 3:8译码器正常工作时，任意时刻恰好有几个输出为有效电平？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000009', '{"format": "single_choice", "options": [{"id": "A", "text": "全为0（低电平有效，全部有效）"}, {"id": "B", "text": "全为1（高电平，全部无效）"}, {"id": "C", "text": "由输入地址A2A1A0决定"}]}', '2026-02-23 14:42:13.022167+00', 2, '使能端EN=0（未使能）时译码器被禁用，低电平有效的输出端全部维持高电平（无效态）；仅当EN=1时才根据地址进行正常译码。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-03) 某3:8译码器有一个高电平有效使能端（EN）及低电平有效输出（Y0~Y7）。当EN=0（禁用）时，各输出为？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000010', '{"format": "single_choice", "options": [{"id": "A", "text": "只能处理低电平有效信号"}, {"id": "B", "text": "要求任意时刻只有1个输入为有效，多个输入同时有效时输出混乱"}, {"id": "C", "text": "无法与译码器配合使用"}]}', '2026-02-23 14:42:13.022167+00', 1, '普通编码器假设输入互斥（同一时刻仅1个有效），若多个输入同时有效则输出为各编码的OR叠加，产生错误码；优先编码器通过优先级机制解决此问题。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-04) 普通（非优先）编码器的局限性是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000011', '{"format": "single_choice", "options": [{"id": "A", "text": "优先编码器的输出位数更多"}, {"id": "B", "text": "多个输入同时有效时，优先编码器按预定优先级只响应最高优先级输入"}, {"id": "C", "text": "优先编码器只能处理1位输入"}]}', '2026-02-23 14:42:13.022167+00', 1, '优先编码器核心：当多个输入同时有效时，电路自动识别最高优先级输入并输出其编码，忽略较低优先级输入；这使其可安全用于中断控制等异步场景。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-04) 优先编码器（Priority Encoder）与普通编码器的核心区别是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000013', '{"format": "single_choice", "options": [{"id": "A", "text": "高阻、低阻、中阻三种电阻状态"}, {"id": "B", "text": "高电平（逻辑1）、低电平（逻辑0）、高阻态（Hi-Z）"}, {"id": "C", "text": "正电压、负电压、零电压"}]}', '2026-02-23 14:42:13.022167+00', 1, '三态门有三种输出状态：逻辑1（高电平）、逻辑0（低电平）和高阻态（Hi-Z）。高阻态下输出端与总线电气断开，等效为开路，不影响总线上的其他驱动。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-05) 三态缓冲器（Tri-state Buffer）的三种输出状态是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000014', '{"format": "single_choice", "options": [{"id": "A", "text": "不限，多个可以同时驱动"}, {"id": "B", "text": "只允许一个"}, {"id": "C", "text": "最多两个"}]}', '2026-02-23 14:42:13.022167+00', 1, '若多个三态门同时驱动总线且输出不一致，将产生"总线竞争"：高低电平直接短路，形成大电流，可能损坏器件并产生不确定逻辑电平；故任意时刻只允许一个驱动器有效。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-05) 共享总线上，同一时刻允许几个三态驱动器处于有效输出（非高阻）状态？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('60000000-0000-0000-0000-000000000015', '{"format": "single_choice", "options": [{"id": "A", "text": "输出端短路到地（低电平固定）"}, {"id": "B", "text": "输出端与总线电气断开（开路）"}, {"id": "C", "text": "输出端锁存当前电平值"}]}', '2026-02-23 14:42:13.022167+00', 1, '高阻态下输出级内部晶体管全部截止，输出阻抗极高，等效于从总线断开；总线电平由其他有效驱动器决定，该三态门不产生任何影响。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-05) 三态缓冲器处于高阻态（Hi-Z）时，其输出端等效于？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'CHAPTER');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('61000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "多路选择器（MUX）"}, {"id": "B", "text": "译码器（Decoder）"}, {"id": "C", "text": "带异步置位的D触发器"}]}', '2026-02-23 14:42:13.022167+00', 1, 'MUX和Decoder均是纯组合逻辑（无记忆元件）；D触发器含存储单元（由SR锁存器构成），具有记忆功能，属时序逻辑器件。', 'zh-CN', '{"answer": "C"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-01) 下列电路中，哪个不是组合逻辑电路？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('61000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "AB + BC + AC"}, {"id": "B", "text": "A + B + C"}, {"id": "C", "text": "ABC"}]}', '2026-02-23 14:42:13.022167+00', 2, '真值表中F=1的最小项为m3(011),m5(101),m6(110),m7(111)；卡诺图化简得AB+BC+AC（覆盖所有至少两个为1的情况）；A+B+C在仅一个为1时也输出1，不正确。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-01) 三输入多数表决电路（F=1当且仅当A,B,C中至少两个为1）的最简SOP为？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('61000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "无任何影响，无关项始终为0"}, {"id": "B", "text": "若强制将无关项视为0，可能错过化简机会，导致表达式不够简单"}, {"id": "C", "text": "必须将无关项视为1，否则电路出错"}]}', '2026-02-23 14:42:13.022167+00', 2, '无关项（X）代表该输入组合不会出现或不关心输出值；化简时应灵活指定0或1以扩大卡诺图分组；若一律视为0，会遗漏可用的合并机会，导致结果不是最简式。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-01) 组合逻辑设计中，无关项（Don''t-care）处理不当会导致？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('61000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "两级NAND等价于AND-OR结构（第一级实现各积项，第二级实现求和）"}, {"id": "B", "text": "两级NAND只能实现单变量取反"}, {"id": "C", "text": "两级NAND与两级NOR完全等价，可以互换使用"}]}', '2026-02-23 14:42:13.022167+00', 2, '由德摩根定律：NAND(NAND(A,B), NAND(C,D)) = AB+CD，即两级NAND实现AND-OR（SOP）。这是NAND通用性的体现，可用纯NAND门实现任意SOP表达式。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-01) 用两级 NAND 门实现 SOP 表达式，原理是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('61000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "电路正常工作所需的最低电源电压"}, {"id": "B", "text": "从输入信号发生变化到输出达到稳定值所经历的最大时间"}, {"id": "C", "text": "每个逻辑门平均工作时间的总和"}]}', '2026-02-23 14:42:13.022167+00', 1, '传播延迟tpd：输入变化到输出稳定的最长路径延迟（关键路径延迟）；它决定电路能可靠工作的最高频率，是组合逻辑时序分析的核心指标。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-01) 组合逻辑电路传播延迟（tpd）的含义是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('62000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "D0接逻辑1，D1接逻辑0，S接A"}, {"id": "B", "text": "D0接逻辑0，D1接逻辑1，S接A"}, {"id": "C", "text": "D0和D1均接A，S接逻辑1"}]}', '2026-02-23 14:42:13.022167+00', 1, 'S=A=0时选D0=1，输出1=NOT(0)；S=A=1时选D1=0，输出0=NOT(1)；故D0=1,D1=0,S=A即实现非门。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-02) 用2:1 MUX实现 F=NOT(A)，正确的连接方式是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('62000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "将A,B接选择端S1S0；对每组(A,B)分析C的影响，数据端D0~D3接0、1或C、C取反"}, {"id": "B", "text": "将A,B,C全部接选择端，输出由硬件自动决定"}, {"id": "C", "text": "4:1 MUX无法实现3变量函数，必须换用8:1 MUX"}]}', '2026-02-23 14:42:13.022167+00', 2, 'Shannon展开：以A,B为选择变量（4:1 MUX），将函数对每组(A,B)值的余式（可能是0/1/C/C取反）接到对应数据端，即可用4:1 MUX配合1个非门实现任意3变量函数。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-02) 利用4:1 MUX实现3变量函数 F(A,B,C) 时，常用的方法是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('62000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "6:1"}, {"id": "B", "text": "8:1"}, {"id": "C", "text": "16:1"}]}', '2026-02-23 14:42:13.022167+00', 2, '两个4:1 MUX各选4路，每个输出接到2:1 MUX的D0/D1；2:1 MUX用第3位选择信号决定输出哪组4路，共8路，构成8:1 MUX。这是MUX级联扩展的标准方法。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-02) 用两个4:1 MUX和一个2:1 MUX可以组成几路选择器？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('64000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "Y0"}, {"id": "B", "text": "Y3"}, {"id": "C", "text": "Y2"}]}', '2026-02-23 14:42:13.022167+00', 2, 'I3有效时优先编码器输出11（二进制，即编码3）；2:4译码器输入为11时Y3有效（仅Y3=1，Y0~Y2=0）。Encoder加Decoder级联实现了原信号到编码再到还原的完整路径。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-04) 将4:2优先编码器（高位优先）的输出直接接到2:4译码器的输入，若I3有效（最高优先级），译码器哪个输出有效？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('62000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "MUX只是数据选择器，不能实现逻辑函数"}, {"id": "B", "text": "Shannon展开定理：任意布尔函数可对任意变量展开为两子函数的选择形式"}, {"id": "C", "text": "MUX可以替代任何门电路，因为所有门都可以用选择器描述"}]}', '2026-02-23 14:42:13.022167+00', 2, 'Shannon展开：F(x1,...,xn) = x1取反·F(0,x2,...,xn) + x1·F(1,x2,...,xn)；以x1为选择端，两子函数接数据端，递归展开可用MUX树实现任意函数。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-02) 关于 MUX 实现任意逻辑函数的理论依据是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('62000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "9个"}, {"id": "B", "text": "11个"}, {"id": "C", "text": "16个"}]}', '2026-02-23 14:42:13.022167+00', 1, '8:1 MUX有8个数据输入（D0~D7）加3个选择输入（S2S1S0）共11个输入引脚；外加1个输出，共12个信号引脚（不含电源/地）。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-02) 8:1 MUX 共有多少个输入引脚（数据输入加选择输入，不含使能和电源）？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('63000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "8个输出端，每个对应3位输入的一种组合（即一个最小项）"}, {"id": "B", "text": "3个输出端，每个对应一个输入位的缓冲"}, {"id": "C", "text": "6个输出端，分别对应输入的原变量和反变量"}]}', '2026-02-23 14:42:13.022167+00', 1, '3:8译码器：3位输入对应8个互斥输出，输出Yi有效当且仅当输入地址等于i，即Yi对应第i个最小项。这使译码器成为实现逻辑函数的通用器件。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-03) 3:8译码器有多少个输出端？每个输出端对应什么逻辑含义？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('63000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "OR门：将 Y2、Y4、Y6 相或"}, {"id": "B", "text": "NAND门：将 Y2、Y4、Y6 接入NAND"}, {"id": "C", "text": "AND门：将 Y2、Y4、Y6 相与"}]}', '2026-02-23 14:42:13.022167+00', 2, '低有效输出：Yi=0表示第i个最小项有效。NAND(Y2,Y4,Y6)=NOT(Y2·Y4·Y6)；当m2/m4/m6任一有效（对应Yi=0）时NAND输出1，其余时NAND(1,1,1)=0，恰好实现F=m2+m4+m6。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-03) 用一片3:8译码器（输出低电平有效 Y0~Y7）加少量门实现 F=Σm(2,4,6)，外部应接哪种门？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('63000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "两片使能端均接逻辑1，用第4位地址A3选择哪片工作（A3=0使能第一片，A3=1使能第二片）"}, {"id": "B", "text": "两片使能端均接逻辑1，地址线A3不接"}, {"id": "C", "text": "两片并联，使能端均接逻辑0"}]}', '2026-02-23 14:42:13.022167+00', 2, '标准扩展方法：A3=0使能低8路译码片（输出Y0~Y7）；A3=1使能高8路译码片（输出Y8~Y15）；两片共享低3位地址A2A1A0，合计实现4:16译码。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-03) 用两片3:8译码器（各有使能端EN，高电平有效）扩展为4:16译码器，使能端如何连接？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('63000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "存储数据内容"}, {"id": "B", "text": "根据地址总线的高位产生片选信号（CS），选中对应存储芯片"}, {"id": "C", "text": "放大数据总线的驱动能力"}]}', '2026-02-23 14:42:13.022167+00', 1, '地址译码器接收CPU发出的高位地址，译出对应的片选（CS）信号使目标存储芯片使能；低位地址则直接送入被选中芯片的内部地址线，实现精确寻址。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-03) 译码器在存储器系统中最主要的应用是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('63000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "两者功能完全相同，可以互换"}, {"id": "B", "text": "MUX是多选一（N路输入选1路输出），Decoder是一激多（1个n位编码激活2的n次方路互斥输出），互为功能上的对偶"}, {"id": "C", "text": "MUX只用于数据通路，Decoder只用于控制通路"}]}', '2026-02-23 14:42:13.022167+00', 2, 'MUX：用n位地址从2的n次方路数据中选1路输出（多选一）；Decoder：n位地址激活2的n次方路输出中的1根（一激多）。两者均基于地址选择，是数字系统路由的两种互补方式。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-03) MUX（多路选择器）与Decoder（译码器）在功能上的对应关系是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('64000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "01（代表I1）"}, {"id": "B", "text": "10（代表I2）"}, {"id": "C", "text": "11（代表I3）"}]}', '2026-02-23 14:42:13.022167+00', 2, 'I3=0不参与；I2、I1、I0均为1，I2优先级最高；I2对应编码2=10(二进制)，故输出Y1Y0=10。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-04) 4:2优先编码器（高位优先I3>I2>I1>I0），输入I3=0,I2=1,I1=1,I0=1时，输出Y1Y0=？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('64000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "存储器地址译码"}, {"id": "B", "text": "中断控制器（将多个中断请求编码为中断向量号，高优先级中断优先响应）"}, {"id": "C", "text": "数据总线位宽扩展"}]}', '2026-02-23 14:42:13.022167+00', 1, 'CPU中断控制器（如Intel 8259A）内部即含优先编码器：多个外设同时发中断请求时，编码器输出最高优先级的中断向量号，CPU据此响应对应ISR。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-04) 优先编码器在计算机系统中最典型的应用场景是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('64000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "功能完全相同，可互换使用"}, {"id": "B", "text": "互为逆操作：Encoder将2的n次方路互斥输入编为n位码；Decoder将n位码还原为2的n次方路互斥输出"}, {"id": "C", "text": "Encoder只能处理模拟信号，Decoder只能处理数字信号"}]}', '2026-02-23 14:42:13.022167+00', 1, '功能对称：Encoder将独热（one-hot）或优先输入编码为紧凑二进制；Decoder将紧凑二进制还原为互斥有效输出；级联可构成编码-传输-译码链路。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-04) 编码器（Encoder）与译码器（Decoder）的功能关系最准确的描述是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('64000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "输出总是等于有效输入中编号最小的那个"}, {"id": "B", "text": "输出等于有效输入中优先级最高（编号最大）的那个输入的二进制编码"}, {"id": "C", "text": "当多个输入同时有效时输出为各编码的OR"}]}', '2026-02-23 14:42:13.022167+00', 2, '优先编码器按优先级排序（通常高编号=高优先级），当多个输入有效时输出最高优先级输入的二进制编码，忽略所有低优先级输入；选A描述的是最低优先级编码器，选C是普通编码器的故障现象。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-04) 以下关于8:3优先编码器输出的说法，正确的是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('65000000-0000-0000-0000-000000000001', '{"format": "single_choice", "options": [{"id": "A", "text": "仅导致逻辑电平不确定，不影响器件寿命"}, {"id": "B", "text": "高低电平直接短路，产生大电流，可能永久损坏驱动器件，同时总线电平不确定"}, {"id": "C", "text": "总线自动进入高阻态，安全保护器件"}]}', '2026-02-23 14:42:13.022167+00', 1, '竞争时两个驱动器输出相反逻辑：CMOS输出高电平一侧的PMOS与输出低电平一侧的NMOS形成低阻通路，产生穿通电流（shoot-through current），轻则功耗急增，重则烧毁驱动管。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-05) 总线竞争（Bus Contention）的根本危害是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('65000000-0000-0000-0000-000000000002', '{"format": "single_choice", "options": [{"id": "A", "text": "放置两个方向相反的三态缓冲器，由方向控制信号保证同一时刻只有一个方向使能"}, {"id": "B", "text": "将两个普通（非三态）缓冲器串联，数据自动选择方向"}, {"id": "C", "text": "使用一个单方向三态门，A到B和B到A共用同一个使能端"}]}', '2026-02-23 14:42:13.022167+00', 2, '双向总线：A到B方向三态门和B到A方向三态门各一个，DIR=0使能A到B方向（另一个高阻）；DIR=1使能B到A方向（另一个高阻）；互斥使能是关键，否则产生竞争。74HC245即是典型双向总线驱动器。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-05) 用三态门实现双向总线（A与B互传数据），正确的设计思路是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('65000000-0000-0000-0000-000000000003', '{"format": "single_choice", "options": [{"id": "A", "text": "提高数据传输速率"}, {"id": "B", "text": "实现多设备分时复用同一条总线，避免不使用时占用总线"}, {"id": "C", "text": "增加数据总线的位宽"}]}', '2026-02-23 14:42:13.022167+00', 1, '三态门使每个设备在不需要通信时将自身输出置为高阻（从总线断开），只有被选中的设备（由片选/控制逻辑决定）才驱动总线，实现物理线路的分时复用（总线共享）。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-05) 在CPU与多个外设共享同一数据总线的系统中，三态门解决的核心问题是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('65000000-0000-0000-0000-000000000004', '{"format": "single_choice", "options": [{"id": "A", "text": "使能有效时输出进入高阻态；使能无效时正常驱动"}, {"id": "B", "text": "使能有效时正常输出数据（高或低电平）；使能无效时进入高阻态"}, {"id": "C", "text": "三态门无需使能控制，始终处于有效驱动状态"}]}', '2026-02-23 14:42:13.022167+00', 1, '三态门的使能端（OE/EN）：有效时输出正常跟随输入（高或低电平）；无效时输出高阻态，从总线断开。具体有效极性（高低电平有效）因器件而异，如74HC245为低电平有效OE。', 'zh-CN', '{"answer": "B"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-05) 关于三态缓冲器使能控制逻辑，正确的说法是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');
INSERT INTO public.questions (id, content, created_at, difficulty, explanation, lang, solution, status, stem, type, updated_at, question_pool) VALUES ('65000000-0000-0000-0000-000000000005', '{"format": "single_choice", "options": [{"id": "A", "text": "开漏只能主动输出低电平（或高阻），高电平需依赖外部上拉电阻；三态可主动输出高、低两种电平"}, {"id": "B", "text": "两者功能完全相同，仅名称不同"}, {"id": "C", "text": "开漏输出速度更快，三态输出驱动能力更强"}]}', '2026-02-23 14:42:13.022167+00', 2, '开漏（OD）：内部只有下拉NMOS，输出低时NMOS导通拉低；输出高时NMOS截止，依靠外部上拉电阻到VCC。优点是可实现线与（Wired-AND）并允许不同电压域互连（如I2C总线）。三态则可主动输出高低双态，速度更快但不支持线与。', 'zh-CN', '{"answer": "A"}', 'PUBLISHED', '[DEMO-COMB] (DC-COMB-05) 开漏输出（Open-Drain）与三态输出最主要的区别是？', 'SINGLE_CHOICE', '2026-02-23 14:42:13.022167+00', 'SUPPLEMENT');


--
-- Data for Name: tag_kp_map; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-05', 1, 'b06ec59c-5dc5-40d1-a420-9290ab919333');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-04', 1, 'b06ec59c-5dc5-40d1-a420-9290ab919333');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-01', 100, '10000000-0000-0000-0000-000000000001');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-02', 100, '10000000-0000-0000-0000-000000000002');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-03', 100, '10000000-0000-0000-0000-000000000003');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-04', 100, '10000000-0000-0000-0000-000000000004');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-05', 100, '10000000-0000-0000-0000-000000000005');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-06', 100, '10000000-0000-0000-0000-000000000006');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-FND-01', 100, '10000000-0000-0000-0000-000000000011');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-FND-02', 100, '10000000-0000-0000-0000-000000000012');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-FND-03', 100, '10000000-0000-0000-0000-000000000013');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-FND-04', 100, '10000000-0000-0000-0000-000000000014');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-01', 50, '20000000-0000-0000-0000-000000000001');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-02', 50, '20000000-0000-0000-0000-000000000002');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-03', 50, '20000000-0000-0000-0000-000000000003');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-04', 50, '20000000-0000-0000-0000-000000000004');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-05', 50, '20000000-0000-0000-0000-000000000005');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-BOOL-06', 50, '20000000-0000-0000-0000-000000000006');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-FND-01', 50, '20000000-0000-0000-0000-000000000011');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-FND-02', 50, '20000000-0000-0000-0000-000000000012');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-FND-03', 50, '20000000-0000-0000-0000-000000000013');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-FND-04', 50, '20000000-0000-0000-0000-000000000014');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-01', 100, '10000000-0000-0000-0000-000000000021');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-02', 100, '10000000-0000-0000-0000-000000000022');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-03', 100, '10000000-0000-0000-0000-000000000023');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-04', 100, '10000000-0000-0000-0000-000000000024');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-05', 100, '10000000-0000-0000-0000-000000000025');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-01', 50, '20000000-0000-0000-0000-000000000021');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-02', 50, '20000000-0000-0000-0000-000000000022');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-03', 50, '20000000-0000-0000-0000-000000000023');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-04', 50, '20000000-0000-0000-0000-000000000024');
INSERT INTO public.tag_kp_map (kp_id, weight, tag_id) VALUES ('DC-COMB-05', 50, '20000000-0000-0000-0000-000000000025');


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tags (id, description, name) VALUES ('b06ec59c-5dc5-40d1-a420-9290ab919333', '卡诺图化简', 'KMAP');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000001', 'KP: 基本逻辑门（AND/OR/NOT/XOR/NAND/NOR）', 'kp:DC-BOOL-01');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000002', 'KP: 布尔代数基本定律', 'kp:DC-BOOL-02');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000003', 'KP: 德摩根定律与门级变换（NAND/NOR实现）', 'kp:DC-BOOL-03');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000004', 'KP: 最小项/最大项与SOP/POS规范形式', 'kp:DC-BOOL-04');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000005', 'KP: 卡诺图化简（2~4变量）', 'kp:DC-BOOL-05');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000006', 'KP: 组合逻辑毛刺与冒险（Hazard）', 'kp:DC-BOOL-06');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000011', 'KP: 数字电路导论（模拟vs数字）', 'kp:DC-FND-01');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000012', 'KP: 数制与进制转换（二/八/十/十六）', 'kp:DC-FND-02');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000013', 'KP: 有符号数与补码（溢出）', 'kp:DC-FND-03');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000014', 'KP: 真值表与逻辑表达式入门', 'kp:DC-FND-04');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000001', '基本逻辑门', 'topic:BOOL-gates');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000002', '布尔代数定律', 'topic:BOOL-laws');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000003', '德摩根定理与门级变换', 'topic:BOOL-demorgan');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000004', 'SOP/POS 规范形式', 'topic:BOOL-sop-pos');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000005', '卡诺图化简', 'topic:BOOL-kmap');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000006', '组合逻辑冒险', 'topic:BOOL-hazard');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000011', '数字电路基础概念', 'topic:FND-intro');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000012', '数制与进制转换', 'topic:FND-numbase');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000013', '有符号数与补码', 'topic:FND-signed');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000014', '真值表与逻辑表达式', 'topic:FND-truthtable');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000021', 'KP: 组合逻辑设计流程（规格→真值表→化简→实现）', 'kp:DC-COMB-01');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000022', 'KP: 多路选择器 MUX（实现与应用）', 'kp:DC-COMB-02');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000023', 'KP: 译码器 Decoder（含使能与地址译码）', 'kp:DC-COMB-03');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000024', 'KP: 编码器 Encoder（含优先编码）', 'kp:DC-COMB-04');
INSERT INTO public.tags (id, description, name) VALUES ('10000000-0000-0000-0000-000000000025', 'KP: 三态缓冲与总线（Tri-state & Bus）', 'kp:DC-COMB-05');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000021', '组合逻辑设计流程', 'topic:COMB-design');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000022', '多路选择器MUX', 'topic:COMB-mux');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000023', '译码器', 'topic:COMB-decoder');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000024', '编码器', 'topic:COMB-encoder');
INSERT INTO public.tags (id, description, name) VALUES ('20000000-0000-0000-0000-000000000025', '三态缓冲与总线', 'topic:COMB-tristate');


--
-- Data for Name: teacher_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.teacher_requests (user_id, decided_at, requested_at, status) VALUES ('b5ac2aa0-2de4-410d-9a2a-dcb478389ca7', '2026-02-24 15:15:02.829755+00', '2026-02-24 15:14:51.202901+00', 'APPROVED');


--
-- Data for Name: user_question_state; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: level_pass_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.level_pass_records_id_seq', 11, true);


--
-- Data for Name: BLOBS; Type: BLOBS; Schema: -; Owner: -
--

BEGIN;

SELECT pg_catalog.lo_open('16548', 131072);
SELECT pg_catalog.lowrite(0, '\x7b2264657669636573223a7b2241223a7b2274797065223a22427574746f6e222c226c6162656c223a2241227d2c2242223a7b2274797065223a22427574746f6e222c226c6162656c223a2242227d2c224731223a7b2274797065223a22416e64222c226c6162656c223a22414e4431222c2262697473223a312c22696e70757473223a327d2c2259223a7b2274797065223a224c616d70222c226c6162656c223a2259227d7d2c22636f6e6e6563746f7273223a5b7b2266726f6d223a7b226964223a2241222c22706f7274223a226f7574227d2c22746f223a7b226964223a224731222c22706f7274223a22696e31227d7d2c7b2266726f6d223a7b226964223a2242222c22706f7274223a226f7574227d2c22746f223a7b226964223a224731222c22706f7274223a22696e32227d7d2c7b2266726f6d223a7b226964223a224731222c22706f7274223a226f7574227d2c22746f223a7b226964223a2259222c22706f7274223a22696e227d7d5d2c227375626369726375697473223a7b7d7d');
SELECT pg_catalog.lo_close(0);

SELECT pg_catalog.lo_open('24778', 131072);
SELECT pg_catalog.lowrite(0, '\x7b2264657669636573223a7b2241223a7b226c6162656c223a2241222c2274797065223a22427574746f6e222c2270726f7061676174696f6e223a302c226e756d62617365223a22686578222c2262697473223a312c226e6574223a22222c22706f736974696f6e223a7b2278223a32302c2279223a39357d7d2c2242223a7b226c6162656c223a2242222c2274797065223a22427574746f6e222c2270726f7061676174696f6e223a302c226e756d62617365223a22686578222c2262697473223a312c226e6574223a22222c22706f736974696f6e223a7b2278223a31352c2279223a3138307d7d2c2259223a7b226c6162656c223a2259222c2274797065223a224c616d70222c2270726f7061676174696f6e223a302c226e756d62617365223a22686578222c2262697473223a312c226e6574223a22222c22706f736974696f6e223a7b2278223a3630302c2279223a37357d7d2c22414e4431223a7b226c6162656c223a22222c2274797065223a22416e64222c2270726f7061676174696f6e223a312c2262697473223a312c22696e70757473223a322c22706f736974696f6e223a7b2278223a3139302c2279223a3130307d7d2c224e4f5431223a7b226c6162656c223a22222c2274797065223a224e6f74222c2270726f7061676174696f6e223a312c2262697473223a312c22706f736974696f6e223a7b2278223a3339302c2279223a39307d7d7d2c22636f6e6e6563746f7273223a5b7b2266726f6d223a7b226964223a2241222c22706f7274223a226f7574227d2c22746f223a7b226964223a22414e4431222c22706f7274223a22696e31227d7d2c7b2266726f6d223a7b226964223a2242222c22706f7274223a226f7574227d2c22746f223a7b226964223a22414e4431222c22706f7274223a22696e32227d7d2c7b2266726f6d223a7b226964223a22414e4431222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e4f5431222c22706f7274223a22696e227d7d2c7b2266726f6d223a7b226964223a224e4f5431222c22706f7274223a226f7574227d2c22746f223a7b226964223a2259222c22706f7274223a22696e227d7d5d2c227375626369726375697473223a7b7d7d');
SELECT pg_catalog.lo_close(0);

SELECT pg_catalog.lo_open('24779', 131072);
SELECT pg_catalog.lowrite(0, '\x7b2264657669636573223a7b2241223a7b226c6162656c223a2241222c2274797065223a22427574746f6e222c2270726f7061676174696f6e223a302c226e756d62617365223a22686578222c2262697473223a312c226e6574223a22222c22706f736974696f6e223a7b2278223a382c2279223a387d7d2c2242223a7b226c6162656c223a2242222c2274797065223a22427574746f6e222c2270726f7061676174696f6e223a302c226e756d62617365223a22686578222c2262697473223a312c226e6574223a22222c22706f736974696f6e223a7b2278223a32302c2279223a3332357d7d2c2259223a7b226c6162656c223a2259222c2274797065223a224c616d70222c2270726f7061676174696f6e223a302c226e756d62617365223a22686578222c2262697473223a312c226e6574223a22222c22706f736974696f6e223a7b2278223a3639302c2279223a3139357d7d2c224e4f5431223a7b226c6162656c223a22222c2274797065223a224e6f74222c2270726f7061676174696f6e223a312c2262697473223a312c22706f736974696f6e223a7b2278223a3134352c2279223a3131357d7d2c224e4f5432223a7b226c6162656c223a22222c2274797065223a224e6f74222c2270726f7061676174696f6e223a312c2262697473223a312c22706f736974696f6e223a7b2278223a3135302c2279223a3236357d7d2c22414e4431223a7b226c6162656c223a22222c2274797065223a22416e64222c2270726f7061676174696f6e223a312c2262697473223a312c22696e70757473223a322c22706f736974696f6e223a7b2278223a3430352c2279223a3331357d7d2c22414e4432223a7b226c6162656c223a22222c2274797065223a22416e64222c2270726f7061676174696f6e223a312c2262697473223a312c22696e70757473223a322c22706f736974696f6e223a7b2278223a3339302c2279223a32357d7d2c224f5231223a7b226c6162656c223a22222c2274797065223a224f72222c2270726f7061676174696f6e223a312c2262697473223a312c22696e70757473223a322c22706f736974696f6e223a7b2278223a3536302c2279223a3138357d7d7d2c22636f6e6e6563746f7273223a5b7b2266726f6d223a7b226964223a2242222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e4f5432222c22706f7274223a22696e227d7d2c7b2266726f6d223a7b226964223a2241222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e4f5431222c22706f7274223a22696e227d7d2c7b2266726f6d223a7b226964223a224e4f5431222c22706f7274223a226f7574227d2c22746f223a7b226964223a22414e4431222c22706f7274223a22696e31227d7d2c7b2266726f6d223a7b226964223a2242222c22706f7274223a226f7574227d2c22746f223a7b226964223a22414e4431222c22706f7274223a22696e32227d7d2c7b2266726f6d223a7b226964223a224e4f5432222c22706f7274223a226f7574227d2c22746f223a7b226964223a22414e4432222c22706f7274223a22696e32227d7d2c7b2266726f6d223a7b226964223a2241222c22706f7274223a226f7574227d2c22746f223a7b226964223a22414e4432222c22706f7274223a22696e31227d7d2c7b2266726f6d223a7b226964223a22414e4432222c22706f7274223a226f7574227d2c22746f223a7b226964223a224f5231222c22706f7274223a22696e31227d7d2c7b2266726f6d223a7b226964223a22414e4431222c22706f7274223a226f7574227d2c22746f223a7b226964223a224f5231222c22706f7274223a22696e32227d7d2c7b2266726f6d223a7b226964223a224f5231222c22706f7274223a226f7574227d2c22746f223a7b226964223a2259222c22706f7274223a22696e227d7d5d2c227375626369726375697473223a7b7d7d');
SELECT pg_catalog.lo_close(0);

SELECT pg_catalog.lo_open('24780', 131072);
SELECT pg_catalog.lowrite(0, '\x7b2264657669636573223a7b2241223a7b226c6162656c223a2241222c2274797065223a22427574746f6e222c2270726f7061676174696f6e223a302c226e756d62617365223a22686578222c2262697473223a312c226e6574223a22222c22706f736974696f6e223a7b2278223a32352c2279223a3135307d7d2c2242223a7b226c6162656c223a2242222c2274797065223a22427574746f6e222c2270726f7061676174696f6e223a302c226e756d62617365223a22686578222c2262697473223a312c226e6574223a22222c22706f736974696f6e223a7b2278223a31352c2279223a3334357d7d2c2259223a7b226c6162656c223a2259222c2274797065223a224c616d70222c2270726f7061676174696f6e223a302c226e756d62617365223a22686578222c2262697473223a312c226e6574223a22222c22706f736974696f6e223a7b2278223a3636302c2279223a3232357d7d2c224e414e31223a7b226c6162656c223a22222c2274797065223a224e616e64222c2270726f7061676174696f6e223a312c2262697473223a312c22696e70757473223a322c22706f736974696f6e223a7b2278223a3438352c2279223a3233307d7d2c224e414e32223a7b226c6162656c223a22222c2274797065223a224e616e64222c2270726f7061676174696f6e223a312c2262697473223a312c22696e70757473223a322c22706f736974696f6e223a7b2278223a38352c2279223a3232357d7d2c224e414e33223a7b226c6162656c223a22222c2274797065223a224e616e64222c2270726f7061676174696f6e223a312c2262697473223a312c22696e70757473223a322c22706f736974696f6e223a7b2278223a3235352c2279223a3238307d7d2c224e414e34223a7b226c6162656c223a22222c2274797065223a224e616e64222c2270726f7061676174696f6e223a312c2262697473223a312c22696e70757473223a322c22706f736974696f6e223a7b2278223a3235352c2279223a3138357d7d7d2c22636f6e6e6563746f7273223a5b7b2266726f6d223a7b226964223a2241222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e414e32222c22706f7274223a22696e31227d7d2c7b2266726f6d223a7b226964223a2242222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e414e32222c22706f7274223a22696e32227d7d2c7b2266726f6d223a7b226964223a224e414e32222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e414e34222c22706f7274223a22696e32227d7d2c7b2266726f6d223a7b226964223a224e414e32222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e414e33222c22706f7274223a22696e31227d7d2c7b2266726f6d223a7b226964223a2242222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e414e33222c22706f7274223a22696e32227d7d2c7b2266726f6d223a7b226964223a2241222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e414e34222c22706f7274223a22696e31227d7d2c7b2266726f6d223a7b226964223a224e414e34222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e414e31222c22706f7274223a22696e31227d7d2c7b2266726f6d223a7b226964223a224e414e33222c22706f7274223a226f7574227d2c22746f223a7b226964223a224e414e31222c22706f7274223a22696e32227d7d2c7b2266726f6d223a7b226964223a224e414e31222c22706f7274223a226f7574227d2c22746f223a7b226964223a2259222c22706f7274223a22696e227d7d5d2c227375626369726375697473223a7b7d7d');
SELECT pg_catalog.lo_close(0);

COMMIT;

--
-- Name: app_users app_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT app_users_pkey PRIMARY KEY (user_id);


--
-- Name: class_membership class_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_membership
    ADD CONSTRAINT class_membership_pkey PRIMARY KEY (id);


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- Name: level_allowed_components level_allowed_components_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_allowed_components
    ADD CONSTRAINT level_allowed_components_pkey PRIMARY KEY (level_code, component);


--
-- Name: level_kp_ids level_kp_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_kp_ids
    ADD CONSTRAINT level_kp_ids_pkey PRIMARY KEY (level_code, kp_id);


--
-- Name: level_pass_records level_pass_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_pass_records
    ADD CONSTRAINT level_pass_records_pkey PRIMARY KEY (id);


--
-- Name: level_test_cases level_test_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_test_cases
    ADD CONSTRAINT level_test_cases_pkey PRIMARY KEY (id);


--
-- Name: level_test_steps level_test_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_test_steps
    ADD CONSTRAINT level_test_steps_pkey PRIMARY KEY (id);


--
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (code);


--
-- Name: persistent_logins persistent_logins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persistent_logins
    ADD CONSTRAINT persistent_logins_pkey PRIMARY KEY (series);


--
-- Name: question_attempts question_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_attempts
    ADD CONSTRAINT question_attempts_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: teacher_requests teacher_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_requests
    ADD CONSTRAINT teacher_requests_pkey PRIMARY KEY (user_id);


--
-- Name: app_users uk_app_users_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT uk_app_users_email UNIQUE (email);


--
-- Name: app_users uk_app_users_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT uk_app_users_username UNIQUE (username);


--
-- Name: class_membership uk_class_membership; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_membership
    ADD CONSTRAINT uk_class_membership UNIQUE (class_id, student_id);


--
-- Name: level_test_cases uk_level_test_case_order; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_test_cases
    ADD CONSTRAINT uk_level_test_case_order UNIQUE (level_code, order_index);


--
-- Name: question_tag_map uk_question_tag; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_tag_map
    ADD CONSTRAINT uk_question_tag PRIMARY KEY (question_id, tag_id);


--
-- Name: tag_kp_map uk_tag_kp_map_tag_kp; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag_kp_map
    ADD CONSTRAINT uk_tag_kp_map_tag_kp PRIMARY KEY (kp_id, tag_id);


--
-- Name: tags uk_tags_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT uk_tags_name UNIQUE (name);


--
-- Name: level_test_steps uk_test_step_index; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_test_steps
    ADD CONSTRAINT uk_test_step_index UNIQUE (test_case_id, step_index);


--
-- Name: user_question_state uk_user_question_state; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_question_state
    ADD CONSTRAINT uk_user_question_state UNIQUE (user_id, question_id);


--
-- Name: user_question_state user_question_state_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_question_state
    ADD CONSTRAINT user_question_state_pkey PRIMARY KEY (id);


--
-- Name: idx_attempt_user_mode; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempt_user_mode ON public.question_attempts USING btree (user_id, mode);


--
-- Name: idx_attempt_user_question; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempt_user_question ON public.question_attempts USING btree (user_id, question_id);


--
-- Name: idx_classes_teacher; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classes_teacher ON public.classes USING btree (teacher_id);


--
-- Name: idx_cm_class_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cm_class_status ON public.class_membership USING btree (class_id, status);


--
-- Name: idx_cm_student_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cm_student_status ON public.class_membership USING btree (student_id, status);


--
-- Name: idx_qtm_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_qtm_tag_id ON public.question_tag_map USING btree (tag_id);


--
-- Name: idx_questions_difficulty; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_difficulty ON public.questions USING btree (difficulty);


--
-- Name: idx_questions_pool; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_pool ON public.questions USING btree (question_pool);


--
-- Name: idx_questions_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_status ON public.questions USING btree (status);


--
-- Name: idx_questions_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_type ON public.questions USING btree (type);


--
-- Name: idx_tag_kp_map_kp_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tag_kp_map_kp_id ON public.tag_kp_map USING btree (kp_id);


--
-- Name: idx_tag_kp_map_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tag_kp_map_tag_id ON public.tag_kp_map USING btree (tag_id);


--
-- Name: idx_uqs_user_mastered; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_uqs_user_mastered ON public.user_question_state USING btree (user_id, mastered);


--
-- Name: ix_level_pass_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_level_pass_user ON public.level_pass_records USING btree (user_id);


--
-- Name: uk_level_pass_user_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uk_level_pass_user_level ON public.level_pass_records USING btree (user_id, level_code);


--
-- Name: level_test_steps fk4t7ce7skdlrwoymhajnurjvuy; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_test_steps
    ADD CONSTRAINT fk4t7ce7skdlrwoymhajnurjvuy FOREIGN KEY (test_case_id) REFERENCES public.level_test_cases(id);


--
-- Name: level_allowed_components fk8jyr7srp15tgof3nfd091i25o; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_allowed_components
    ADD CONSTRAINT fk8jyr7srp15tgof3nfd091i25o FOREIGN KEY (level_code) REFERENCES public.levels(code);


--
-- Name: tag_kp_map fk_tag_kp_map_tag; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag_kp_map
    ADD CONSTRAINT fk_tag_kp_map_tag FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: level_test_cases fkkmlxih421wunodkv9wioag86u; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_test_cases
    ADD CONSTRAINT fkkmlxih421wunodkv9wioag86u FOREIGN KEY (level_code) REFERENCES public.levels(code);


--
-- Name: level_kp_ids fkp0nnxideac4ma86nv4vqy3q0a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_kp_ids
    ADD CONSTRAINT fkp0nnxideac4ma86nv4vqy3q0a FOREIGN KEY (level_code) REFERENCES public.levels(code);


--
-- PostgreSQL database dump complete
--

\unrestrict WTpQ1eVCPPRUCyErcbvlcF3GrrDSo1RBU71BKWeyabFzg98OuxV07QYwzaQ93Lm

