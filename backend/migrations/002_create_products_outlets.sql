
CREATE TABLE products (
  id          VARCHAR(10)  PRIMARY KEY,
  name        VARCHAR(150) NOT NULL,
  category    VARCHAR(50)  NOT NULL,
  price       INT          NOT NULL CHECK (price >= 0),
  description TEXT         NOT NULL DEFAULT '',
  color       VARCHAR(7)   NOT NULL DEFAULT '#B77B4B',
  is_drink    BOOLEAN      NOT NULL DEFAULT TRUE,
  badge       VARCHAR(30),
  is_merch    BOOLEAN      NOT NULL DEFAULT FALSE,
  sort_order  INT          NOT NULL DEFAULT 0
);

CREATE INDEX products_category_idx ON products (category);

CREATE TABLE outlets (
  id         SERIAL PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  address    TEXT         NOT NULL,
  distance   VARCHAR(20)  NOT NULL DEFAULT '',
  hours      VARCHAR(30)  NOT NULL,
  delivery   BOOLEAN      NOT NULL DEFAULT TRUE,
  pickup     BOOLEAN      NOT NULL DEFAULT TRUE,
  drive      BOOLEAN      NOT NULL DEFAULT FALSE,
  sort_order INT          NOT NULL DEFAULT 0
);
