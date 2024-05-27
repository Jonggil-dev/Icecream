DROP TABLE IF EXISTS parent_child_mapping;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS goal;
DROP TABLE IF EXISTS destination;
DROP TABLE IF EXISTS crosswalk;
DROP TABLE IF EXISTS crosswalk_cctv_mapping;
DROP TABLE IF EXISTS road;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(10) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    login_id VARCHAR(20),
    password VARCHAR(100),
    device_id VARCHAR(20) NOT NULL,
    is_parent BOOLEAN NOT NULL,
    profile_image TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX unique_phone_number ON users(phone_number) WHERE is_deleted = FALSE;
CREATE UNIQUE INDEX unique_login_id ON users(login_id) WHERE is_deleted = FALSE;
CREATE UNIQUE INDEX unique_device_id ON users(device_id) WHERE is_deleted = FALSE;

CREATE TABLE parent_child_mapping (
    id SERIAL PRIMARY KEY,
    parent_id INT NOT NULL,
    child_id INT NOT NULL,
    CONSTRAINT fk_parent FOREIGN KEY (parent_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_child FOREIGN KEY (child_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT uc_parent_child UNIQUE (parent_id, child_id)
);

CREATE TABLE goal (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    period INT NOT NULL,
    record INT NOT NULL DEFAULT 0,
    content VARCHAR(500) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE destination (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(20) NOT NULL,
    icon INT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address VARCHAR(100) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    day VARCHAR(7) NOT NULL,
    location geography(Point, 4326) NOT NULL,
    radius DOUBLE PRECISION NOT NULL DEFAULT 100.0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE crosswalk (
    id SERIAL PRIMARY KEY,
    crosswalk_area geometry(Polygon, 4326) NOT NULL,
    crosswalk_name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE crosswalk_cctv_mapping (
    id SERIAL PRIMARY KEY,
    cctv_name VARCHAR(20) NOT NULL,
    crosswalk_name VARCHAR(20) NOT NULL
);

CREATE TABLE road (
    id SERIAL PRIMARY KEY,
    road_area geometry(Polygon, 4326) NOT NULL
);
