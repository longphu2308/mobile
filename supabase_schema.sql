-- Supabase Database Schema for Food Delivery App

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE (Auth only - tách riêng cho authentication)
-- ============================================
CREATE TABLE users (
  user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  role TEXT DEFAULT 'user' CHECK (role IN ('user', 'owner', 'shipper')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- USER_PROFILES TABLE (Thông tin profile)
-- ============================================
CREATE TABLE user_profiles (
  profile_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE UNIQUE NOT NULL,
  full_name TEXT,
  phone TEXT UNIQUE,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- USER_ADDRESSES TABLE (Địa chỉ - có thể có nhiều)
-- ============================================
CREATE TABLE user_addresses (
  address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE NOT NULL,
  label TEXT DEFAULT 'home' CHECK (label IN ('home', 'work', 'other')),
  address TEXT NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- SHIPPER_PROFILES TABLE (Thông tin riêng cho shipper)
-- ============================================
CREATE TABLE shipper_profiles (
  shipper_profile_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE UNIQUE NOT NULL,
  vehicle_type TEXT CHECK (vehicle_type IN ('bike', 'motorbike', 'car')),
  vehicle_plate TEXT,
  license_number TEXT,
  is_available BOOLEAN DEFAULT false,
  current_latitude DECIMAL(10, 8),
  current_longitude DECIMAL(11, 8),
  rating DECIMAL(2,1) DEFAULT 5.0,
  total_deliveries INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- RESTAURANTS TABLE
-- ============================================
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

-- ============================================
-- FOODS TABLE
-- ============================================
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

-- ============================================
-- ORDERS TABLE (thêm shipper_id)
-- ============================================
CREATE TABLE orders (
  order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  restaurant_id UUID REFERENCES restaurants(restaurant_id),
  shipper_id UUID REFERENCES users(user_id),
  total_amount DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready_for_pickup', 'delivering', 'delivered', 'cancelled')),
  delivery_address TEXT NOT NULL,
  delivery_latitude DECIMAL(10, 8),
  delivery_longitude DECIMAL(11, 8),
  payment_method TEXT DEFAULT 'cash',
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ORDER_ITEMS TABLE
-- ============================================
CREATE TABLE order_items (
  order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(order_id) ON DELETE CASCADE,
  food_id UUID REFERENCES foods(food_id),
  food_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- CARTS TABLE
-- ============================================
CREATE TABLE carts (
  cart_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE UNIQUE,
  restaurant_id UUID REFERENCES restaurants(restaurant_id),
  restaurant_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- CART_ITEMS TABLE
-- ============================================
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

-- ============================================
-- PROMOS TABLE
-- ============================================
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

-- ============================================
-- FAVORITES TABLE
-- ============================================
CREATE TABLE favorites (
  favorite_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  food_id UUID REFERENCES foods(food_id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, food_id)
);

-- ============================================
-- PAYMENTS TABLE
-- ============================================
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

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_user_profiles_user ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_phone ON user_profiles(phone);
CREATE INDEX idx_user_addresses_user ON user_addresses(user_id);
CREATE INDEX idx_shipper_profiles_user ON shipper_profiles(user_id);
CREATE INDEX idx_shipper_profiles_available ON shipper_profiles(is_available);
CREATE INDEX idx_foods_restaurant ON foods(restaurant_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_orders_shipper ON orders(shipper_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX idx_promos_restaurant ON promos(restaurant_id);
CREATE INDEX idx_favorites_user ON favorites(user_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE shipper_profiles ENABLE ROW LEVEL SECURITY;
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
-- USER_PROFILES TABLE POLICIES
-- ============================================
-- Users can read their own profile
CREATE POLICY "Users can read own profile" ON user_profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Anyone can read profiles for display (name, avatar)
CREATE POLICY "Anyone can read profiles for display" ON user_profiles
  FOR SELECT TO authenticated
  USING (true);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- USER_ADDRESSES TABLE POLICIES
-- ============================================
-- Users can read their own addresses
CREATE POLICY "Users can read own addresses" ON user_addresses
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Users can insert their own addresses
CREATE POLICY "Users can insert own addresses" ON user_addresses
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own addresses
CREATE POLICY "Users can update own addresses" ON user_addresses
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own addresses
CREATE POLICY "Users can delete own addresses" ON user_addresses
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ============================================
-- SHIPPER_PROFILES TABLE POLICIES
-- ============================================
-- Shippers can read their own profile
CREATE POLICY "Shippers can read own shipper profile" ON shipper_profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Anyone can read available shippers (for order assignment)
CREATE POLICY "Anyone can read available shippers" ON shipper_profiles
  FOR SELECT TO authenticated
  USING (true);

-- Shippers can insert their own profile
CREATE POLICY "Shippers can insert own shipper profile" ON shipper_profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Shippers can update their own profile
CREATE POLICY "Shippers can update own shipper profile" ON shipper_profiles
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

-- Shippers can read orders assigned to them
CREATE POLICY "Shippers can read assigned orders" ON orders
  FOR SELECT TO authenticated
  USING (auth.uid() = shipper_id);

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

-- Shippers can update orders assigned to them
CREATE POLICY "Shippers can update assigned orders" ON orders
  FOR UPDATE TO authenticated
  USING (auth.uid() = shipper_id);

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

-- Shippers can read items from their assigned orders
CREATE POLICY "Shippers can read assigned order items" ON order_items
  FOR SELECT TO authenticated
  USING (
    order_id IN (SELECT order_id FROM orders WHERE shipper_id = auth.uid())
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
