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

-- ============================================
-- USERS TABLE POLICIES
-- ============================================
-- Users can insert their own record during sign up
CREATE POLICY "Users can insert during signup" ON users
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can read their own data
CREATE POLICY "Users can read own data" ON users
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Users can update their own data
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- RESTAURANTS TABLE POLICIES
-- ============================================
-- Anyone authenticated can read all restaurants
CREATE POLICY "Anyone can read restaurants" ON restaurants
  FOR SELECT TO authenticated USING (true);

-- Owners can insert their own restaurants
CREATE POLICY "Owners can create restaurants" ON restaurants
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = owner_id);

-- Owners can update their own restaurants
CREATE POLICY "Owners can update own restaurants" ON restaurants
  FOR UPDATE TO authenticated
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Owners can delete their own restaurants
CREATE POLICY "Owners can delete own restaurants" ON restaurants
  FOR DELETE TO authenticated
  USING (auth.uid() = owner_id);

-- ============================================
-- FOODS TABLE POLICIES
-- ============================================
-- Anyone authenticated can read all foods
CREATE POLICY "Anyone can read foods" ON foods
  FOR SELECT TO authenticated USING (true);

-- Owners can insert foods for their restaurants
CREATE POLICY "Owners can create foods" ON foods
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() IN (
      SELECT owner_id FROM restaurants WHERE restaurant_id = foods.restaurant_id
    )
  );

-- Owners can update foods for their restaurants
CREATE POLICY "Owners can update own foods" ON foods
  FOR UPDATE TO authenticated
  USING (
    auth.uid() IN (
      SELECT owner_id FROM restaurants WHERE restaurant_id = foods.restaurant_id
    )
  )
  WITH CHECK (
    auth.uid() IN (
      SELECT owner_id FROM restaurants WHERE restaurant_id = foods.restaurant_id
    )
  );

-- Owners can delete foods for their restaurants
CREATE POLICY "Owners can delete own foods" ON foods
  FOR DELETE TO authenticated
  USING (
    auth.uid() IN (
      SELECT owner_id FROM restaurants WHERE restaurant_id = foods.restaurant_id
    )
  );

-- ============================================
-- ORDERS TABLE POLICIES
-- ============================================
-- Users can read their own orders
CREATE POLICY "Users can read own orders" ON orders
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Owners can read orders for their restaurants
CREATE POLICY "Owners can read restaurant orders" ON orders
  FOR SELECT TO authenticated
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM restaurants WHERE owner_id = auth.uid()
    )
  );

-- Users can create their own orders
CREATE POLICY "Users can create orders" ON orders
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own orders
CREATE POLICY "Users can update own orders" ON orders
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Owners can update orders for their restaurants
CREATE POLICY "Owners can update restaurant orders" ON orders
  FOR UPDATE TO authenticated
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM restaurants WHERE owner_id = auth.uid()
    )
  );

-- ============================================
-- ORDER_ITEMS TABLE POLICIES
-- ============================================
-- Users can read items from their own orders
CREATE POLICY "Users can read own order items" ON order_items
  FOR SELECT TO authenticated
  USING (
    order_id IN (SELECT order_id FROM orders WHERE user_id = auth.uid())
  );

-- Owners can read items from their restaurant orders
CREATE POLICY "Owners can read restaurant order items" ON order_items
  FOR SELECT TO authenticated
  USING (
    order_id IN (
      SELECT o.order_id FROM orders o
      JOIN restaurants r ON o.restaurant_id = r.restaurant_id
      WHERE r.owner_id = auth.uid()
    )
  );

-- Users can insert items when creating orders
CREATE POLICY "Users can create order items" ON order_items
  FOR INSERT TO authenticated
  WITH CHECK (
    order_id IN (SELECT order_id FROM orders WHERE user_id = auth.uid())
  );

-- ============================================
-- CARTS TABLE POLICIES
-- ============================================
-- Users can read their own cart
CREATE POLICY "Users can read own cart" ON carts
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Users can create their own cart
CREATE POLICY "Users can create own cart" ON carts
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own cart
CREATE POLICY "Users can update own cart" ON carts
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own cart
CREATE POLICY "Users can delete own cart" ON carts
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ============================================
-- CART_ITEMS TABLE POLICIES
-- ============================================
-- Users can read their own cart items
CREATE POLICY "Users can read own cart items" ON cart_items
  FOR SELECT TO authenticated
  USING (
    cart_id IN (SELECT cart_id FROM carts WHERE user_id = auth.uid())
  );

-- Users can insert items to their own cart
CREATE POLICY "Users can create cart items" ON cart_items
  FOR INSERT TO authenticated
  WITH CHECK (
    cart_id IN (SELECT cart_id FROM carts WHERE user_id = auth.uid())
  );

-- Users can update their own cart items
CREATE POLICY "Users can update cart items" ON cart_items
  FOR UPDATE TO authenticated
  USING (
    cart_id IN (SELECT cart_id FROM carts WHERE user_id = auth.uid())
  )
  WITH CHECK (
    cart_id IN (SELECT cart_id FROM carts WHERE user_id = auth.uid())
  );

-- Users can delete their own cart items
CREATE POLICY "Users can delete cart items" ON cart_items
  FOR DELETE TO authenticated
  USING (
    cart_id IN (SELECT cart_id FROM carts WHERE user_id = auth.uid())
  );

-- ============================================
-- PROMOS TABLE POLICIES
-- ============================================
-- Anyone authenticated can read active promos
CREATE POLICY "Anyone can read active promos" ON promos
  FOR SELECT TO authenticated
  USING (active = true);

-- Owners can read all their restaurant promos
CREATE POLICY "Owners can read own promos" ON promos
  FOR SELECT TO authenticated
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM restaurants WHERE owner_id = auth.uid()
    )
  );

-- Owners can create promos for their restaurants
CREATE POLICY "Owners can create promos" ON promos
  FOR INSERT TO authenticated
  WITH CHECK (
    restaurant_id IN (
      SELECT restaurant_id FROM restaurants WHERE owner_id = auth.uid()
    )
  );

-- Owners can update their restaurant promos
CREATE POLICY "Owners can update own promos" ON promos
  FOR UPDATE TO authenticated
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM restaurants WHERE owner_id = auth.uid()
    )
  )
  WITH CHECK (
    restaurant_id IN (
      SELECT restaurant_id FROM restaurants WHERE owner_id = auth.uid()
    )
  );

-- Owners can delete their restaurant promos
CREATE POLICY "Owners can delete own promos" ON promos
  FOR DELETE TO authenticated
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM restaurants WHERE owner_id = auth.uid()
    )
  );

-- ============================================
-- FAVORITES TABLE POLICIES
-- ============================================
-- Users can read their own favorites
CREATE POLICY "Users can read own favorites" ON favorites
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Users can create their own favorites
CREATE POLICY "Users can create favorites" ON favorites
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own favorites
CREATE POLICY "Users can delete favorites" ON favorites
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ============================================
-- PAYMENTS TABLE POLICIES
-- ============================================
-- Users can read payments for their orders
CREATE POLICY "Users can read own payments" ON payments
  FOR SELECT TO authenticated
  USING (
    order_id IN (SELECT order_id FROM orders WHERE user_id = auth.uid())
  );

-- Owners can read payments for their restaurant orders
CREATE POLICY "Owners can read restaurant payments" ON payments
  FOR SELECT TO authenticated
  USING (
    order_id IN (
      SELECT o.order_id FROM orders o
      JOIN restaurants r ON o.restaurant_id = r.restaurant_id
      WHERE r.owner_id = auth.uid()
    )
  );

-- Users can create payments for their orders
CREATE POLICY "Users can create payments" ON payments
  FOR INSERT TO authenticated
  WITH CHECK (
    order_id IN (SELECT order_id FROM orders WHERE user_id = auth.uid())
  );

-- System can update payment status (for webhook callbacks)
CREATE POLICY "Users can update own payments" ON payments
  FOR UPDATE TO authenticated
  USING (
    order_id IN (SELECT order_id FROM orders WHERE user_id = auth.uid())
  );
