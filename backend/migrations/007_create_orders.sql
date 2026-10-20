
CREATE TABLE orders (
  id             SERIAL PRIMARY KEY,
  user_id        INT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  mode           VARCHAR(20)  NOT NULL CHECK (mode IN ('Pickup', 'Dine-In', 'Delivery')),
  place          VARCHAR(200) NOT NULL,          -- nama outlet, atau label alamat bila Delivery
  address_detail TEXT,                           -- alamat lengkap (hanya Delivery)
  payment        VARCHAR(50)  NOT NULL,
  subtotal       INT          NOT NULL,
  discount       INT          NOT NULL DEFAULT 0,
  ship_fee       INT          NOT NULL DEFAULT 0,
  ship_discount  INT          NOT NULL DEFAULT 0,
  bag_fee        INT          NOT NULL DEFAULT 0,
  total          INT          NOT NULL,
  points_earned  INT          NOT NULL DEFAULT 0,
  voucher_code   VARCHAR(30),
  status         VARCHAR(20)  NOT NULL DEFAULT 'Selesai',
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX orders_user_idx ON orders (user_id, id DESC);

CREATE TABLE order_items (
  id           SERIAL PRIMARY KEY,
  order_id     INT          NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  product_id   VARCHAR(10)  NOT NULL REFERENCES products (id),
  product_name VARCHAR(150) NOT NULL,            
  size         VARCHAR(20)  NOT NULL DEFAULT 'Regular',
  ice          VARCHAR(30)  NOT NULL DEFAULT '',
  sugar        VARCHAR(30)  NOT NULL DEFAULT '',
  note         VARCHAR(200) NOT NULL DEFAULT '',
  qty          INT          NOT NULL CHECK (qty > 0),
  unit_price   INT          NOT NULL            
);

CREATE INDEX order_items_order_idx ON order_items (order_id);