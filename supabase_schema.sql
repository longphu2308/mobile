-- Supabase Database Schema for Food Delivery App

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (without restaurant_id first)
CREATE TABLE users (
  user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone TEXT UNIQUE,
  role TEXT DEFAULT 'user' CHECK (role IN ('user', 'owner')),
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Restaurants table
CREATE TABLE restaurants (
  restaurant_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT,
  phone TEXT,
  image_url TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed', 'busy')),
  rating DECIMAL(2,1) DEFAULT 0.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add restaurant_id column to users after restaurants table is created
ALTER TABLE users ADD COLUMN restaurant_id UUID REFERENCES restaurants(restaurant_id);

-- Foods table
CREATE TABLE foods (
  food_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  category TEXT CHECK (category IN ('appetizer', 'main', 'dessert', 'drink', 'combo')),
  available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders table
CREATE TABLE orders (
  order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  restaurant_id UUID REFERENCES restaurants(restaurant_id),
  total_amount DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'delivering', 'delivered', 'cancelled')),
  delivery_address TEXT NOT NULL,
  payment_method TEXT DEFAULT 'cash',
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items table
CREATE TABLE order_items (
  order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(order_id) ON DELETE CASCADE,
  food_id UUID REFERENCES foods(food_id),
  food_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Carts table
CREATE TABLE carts (
  cart_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE UNIQUE,
  restaurant_id UUID REFERENCES restaurants(restaurant_id),
  restaurant_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cart items table
CREATE TABLE cart_items (
  cart_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cart_id UUID REFERENCES carts(cart_id) ON DELETE CASCADE,
  food_id UUID REFERENCES foods(food_id),
  food_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Promos table
CREATE TABLE promos (
  promo_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
  code TEXT UNIQUE NOT NULL,
  description TEXT,
  discount INTEGER NOT NULL,
  type TEXT CHECK (type IN ('delivery', 'food', 'both')),
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  active BOOLEAN DEFAULT true,
  used_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Favorites table
CREATE TABLE favorites (
  favorite_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  food_id UUID REFERENCES foods(food_id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, food_id)
);

-- Payments table
CREATE TABLE payments (
  payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(order_id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  method TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
  transaction_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for better query performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_foods_restaurant ON foods(restaurant_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX idx_promos_restaurant ON promos(restaurant_id);
CREATE INDEX idx_favorites_user ON favorites(user_id);

-- Row Level Security (RLS) Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE promos ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own data
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = user_id);

-- Anyone can read restaurants
CREATE POLICY "Anyone can read restaurants" ON restaurants
  FOR SELECT TO authenticated USING (true);

-- Owners can update their own restaurants
CREATE POLICY "Owners can update own restaurants" ON restaurants
  FOR UPDATE USING (auth.uid() = owner_id);

-- Anyone can read available foods
CREATE POLICY "Anyone can read foods" ON foods
  FOR SELECT TO authenticated USING (true);

-- Owners can manage foods for their restaurants
CREATE POLICY "Owners can manage own restaurant foods" ON foods
  FOR ALL USING (
    auth.uid() IN (
      SELECT owner_id FROM restaurants WHERE restaurant_id = foods.restaurant_id
    )
  );

-- Users can read their own orders
CREATE POLICY "Users can read own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

-- Users can create orders
CREATE POLICY "Users can create orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can read their own cart
CREATE POLICY "Users can manage own cart" ON carts
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own cart items" ON cart_items
  FOR ALL USING (
    cart_id IN (SELECT cart_id FROM carts WHERE user_id = auth.uid())
  );

-- Anyone can read active promos
CREATE POLICY "Anyone can read promos" ON promos
  FOR SELECT TO authenticated USING (active = true);

-- Users can manage their own favorites
CREATE POLICY "Users can manage own favorites" ON favorites
  FOR ALL USING (auth.uid() = user_id);
