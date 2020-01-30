CREATE DATABASE movie_pockerface;

CREATE TABLE movie_db (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) not null,
    image_url VARCHAR(500),
    year VARCHAR(10),
    runtime VARCHAR(40),
    genre VARCHAR(50),
    actors VARCHAR(500),
    award VARCHAR(200),
    rate VARCHAR(50),
    db_date_of_entry TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE user_db(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) not null,
    email VARCHAR(100),
    password VARCHAR(200),
    requests INTEGER
);

CREATE TABLE user_comments(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) not null,
    comment TEXT,
    response TEXT,
    user_id INTEGER,
    CONSTRAINT commment_user_id FOREIGN KEY (user_id) REFERENCES user_db (id)
);

ALTER TABLE movie_db RENAME TO movie_db_table;
ALTER TABLE user_db RENAME TO user_db_table;
ALTER TABLE user_comments RENAME TO user_comments_table;
ALTER TABLE user_db_table RENAME COLUMN password TO processed_password;
ALTER TABLE movie_db_table RENAME COLUMN name TO Title;

ALTER TABLE user_db_table ADD CONSTRAINT PKuser_unique_ac UNIQUE (email);
ALTER TABLE movie_db_table ADD COLUMN mega_data TEXT;

DROP TABLE movie_db_table;

CREATE TABLE movie_db_table (
    id SERIAL PRIMARY KEY,
    Title VARCHAR(200) not null,
    Poster VARCHAR(500),
    Year VARCHAR(10),
    Runtime VARCHAR(40),
    Genre VARCHAR(200),
    Actors VARCHAR(500),
    Awards VARCHAR(200),
    Ratings VARCHAR(200),
    mega_data text,
    db_date_of_entry TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE movie_db_table ADD COLUMN frequency INTEGER;
UPDATE movie_db_table SET frequency = 1;
ALTER TABLE movie_db_table ALTER COLUMN frequency SET DEFAULT 1;

ALTER TABLE user_db_table ADD COLUMN accesslevel INTEGER;
ALTER TABLE user_db_table ALTER COLUMN accesslevel SET DEFAULT 0;



CREATE TABLE request_db_table(
    id SERIAL PRIMARY KEY,
    db_id INTEGER,
    requester_id INTEGER,
    origine VARCHAR(10),
    db_date_of_entry TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT request_db_id FOREIGN KEY (db_id) REFERENCES movie_db_table(id),
    CONSTRAINT request_user_id FOREIGN KEY (requester_id) REFERENCES user_db_table(id)
);

ALTER TABLE movie_db_table ADD CONSTRAINT singleentry UNIQUE (Title);
ALTER TABLE user_db_table DROP COLUMN request;
UPDATE user_db_table SET accesslevel = 0;






