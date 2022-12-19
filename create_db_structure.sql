-- public.blacklisted_domains definition


CREATE TABLE public.blacklisted_domains (
	id serial4 NOT NULL,
	"name" varchar(255) NOT NULL,
	CONSTRAINT blacklisted_domains_pk PRIMARY KEY (id),
	CONSTRAINT blacklisted_domains_un UNIQUE (name)
);


-- public.users definition


CREATE TABLE public.users (
	id serial4 NOT NULL,
	username varchar(255) NOT NULL,
	email varchar(255) NOT NULL,
	"password" varchar(255) NOT NULL,
	CONSTRAINT unique_email UNIQUE (email),
	CONSTRAINT unique_username UNIQUE (username),
	CONSTRAINT users_pk PRIMARY KEY (id)
);


-- public.links definition


CREATE TABLE public.links (
	id serial4 NOT NULL,
	creator_id int4 NULL,
	access_id varchar(10) NOT NULL,
	target varchar(2000) NOT NULL,
	expiry_time timestamp NOT NULL,
	remaining_uses int4 NULL,
	CONSTRAINT links_un UNIQUE (access_id),
	CONSTRAINT links_fk FOREIGN KEY (creator_id) REFERENCES public.users(id)
);


-- public.sessions definition

CREATE TABLE public.sessions (
	user_id int4 NOT NULL,
	"data" jsonb NULL DEFAULT '{}'::jsonb,
	id uuid NOT NULL DEFAULT uuid_generate_v4(),
	expiry_time timestamp NOT NULL DEFAULT (now() + '08:00:00'::interval),
	CONSTRAINT sessions_pk PRIMARY KEY (id),
	CONSTRAINT sessions_fk FOREIGN KEY (user_id) REFERENCES public.users(id)
);
