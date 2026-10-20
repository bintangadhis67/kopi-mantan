
CREATE TABLE vouchers (
  code        VARCHAR(30)  PRIMARY KEY,
  title       VARCHAR(100) NOT NULL,
  description TEXT         NOT NULL DEFAULT '',
  type        VARCHAR(10)  NOT NULL CHECK (type IN ('pct', 'flat', 'b1g1', 'free', 'ship')),
  value       INT          NOT NULL DEFAULT 0,
  is_promo    BOOLEAN      NOT NULL DEFAULT FALSE,  -- boleh dipakai dengan mengetik kode
  claim_key   VARCHAR(30)  UNIQUE                   -- kunci untuk voucher yang bisa diklaim
);

CREATE TABLE user_vouchers (
  id           SERIAL PRIMARY KEY,
  user_id      INT         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  voucher_code VARCHAR(30) NOT NULL REFERENCES vouchers (code),
  description  TEXT,
  claim_key    VARCHAR(30),
  used         BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at   TIMESTAMP   NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, claim_key)
);

CREATE INDEX user_vouchers_user_idx ON user_vouchers (user_id);