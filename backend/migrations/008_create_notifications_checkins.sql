
CREATE TABLE notifications (
  id         SERIAL PRIMARY KEY,
  user_id    INT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  title      VARCHAR(150) NOT NULL,
  body       TEXT         NOT NULL DEFAULT '',
  is_read    BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX notifications_user_idx ON notifications (user_id, id DESC);

CREATE TABLE checkins (
  id           SERIAL PRIMARY KEY,
  user_id      INT         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  day_no       INT         NOT NULL,              
  reward       VARCHAR(20) NOT NULL,              
  checkin_date DATE        NOT NULL DEFAULT CURRENT_DATE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, checkin_date)                  
);