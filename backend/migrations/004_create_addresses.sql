
CREATE TABLE addresses (
  id         SERIAL PRIMARY KEY,
  user_id    INT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  label      VARCHAR(50)  NOT NULL,
  detail     TEXT         NOT NULL,
  created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX addresses_user_idx ON addresses (user_id);