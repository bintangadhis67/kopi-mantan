CREATE TABLE users (
  id             SERIAL PRIMARY KEY,
  name           VARCHAR(100) NOT NULL DEFAULT 'Pengguna Mantan',
  email          VARCHAR(100),
  email_verified BOOLEAN      NOT NULL DEFAULT FALSE,
  phone          VARCHAR(20) UNIQUE,
  provider       VARCHAR(20)  NOT NULL DEFAULT 'phone',
  gender         VARCHAR(20)  NOT NULL DEFAULT 'Rahasia',
  birth          DATE,
  city           VARCHAR(50)  NOT NULL DEFAULT '',
  google_linked  BOOLEAN      NOT NULL DEFAULT FALSE,
  pin_hash       TEXT,
  points         INT          NOT NULL DEFAULT 0,
  spend          BIGINT       NOT NULL DEFAULT 0,
  created_at     TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX users_provider_demo_idx
  ON users (provider) WHERE phone IS NULL;