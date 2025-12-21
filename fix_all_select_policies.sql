-- ============================================
-- KIỂM TRA TẤT CẢ POLICY GÂY RECURSION
-- ============================================

-- 1. Xem tất cả policy SELECT của orders
SELECT 'orders' as table_name, policyname, qual 
FROM pg_policies 
WHERE tablename = 'orders' AND cmd = 'SELECT';

-- 2. Xem tất cả policy SELECT của restaurants (có thể query orders)
SELECT 'restaurants' as table_name, policyname, qual 
FROM pg_policies 
WHERE tablename = 'restaurants' AND cmd = 'SELECT';

-- 3. Xem tất cả policy SELECT của order_items
SELECT 'order_items' as table_name, policyname, qual 
FROM pg_policies 
WHERE tablename = 'order_items' AND cmd = 'SELECT';

-- 4. Xem tất cả policy SELECT của shipper_profiles
SELECT 'shipper_profiles' as table_name, policyname, qual 
FROM pg_policies 
WHERE tablename = 'shipper_profiles' AND cmd = 'SELECT';

-- ============================================
-- FIX: XÓA TẤT CẢ POLICY SELECT CỦA ORDERS VÀ TẠO LẠI ĐƠN GIẢN
-- ============================================

-- Xóa tất cả policy SELECT của orders
DROP POLICY IF EXISTS "Users can read own orders" ON orders;
DROP POLICY IF EXISTS "Owners can read restaurant orders" ON orders;
DROP POLICY IF EXISTS "Shippers can read pending orders" ON orders;
DROP POLICY IF EXISTS "Shippers can read assigned orders" ON orders;

-- Tạo policy SELECT đơn giản nhất - OR tất cả điều kiện trong 1 policy
CREATE POLICY "Read orders policy" ON orders
  FOR SELECT
  TO authenticated
  USING (
    -- User đọc order của mình
    user_id = auth.uid()
    OR
    -- Shipper đọc order được giao cho họ
    shipper_id = auth.uid()
    OR
    -- Shipper đọc pending orders (không dùng EXISTS)
    (status = 'pending' AND shipper_id IS NULL)
    OR
    -- Owner đọc order của restaurant họ (sẽ fix sau)
    restaurant_id IN (SELECT restaurant_id FROM restaurants WHERE owner_id = auth.uid())
  );

-- Xóa tất cả policy SELECT của order_items
DROP POLICY IF EXISTS "Users can read own order items" ON order_items;
DROP POLICY IF EXISTS "Users can read order items" ON order_items;
DROP POLICY IF EXISTS "Owners can read restaurant order items" ON order_items;
DROP POLICY IF EXISTS "Shippers can read assigned order items" ON order_items;

-- Tạo policy SELECT đơn giản cho order_items
CREATE POLICY "Read order items policy" ON order_items
  FOR SELECT
  TO authenticated
  USING (true);

-- Kiểm tra kết quả
SELECT tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('orders', 'order_items') AND cmd = 'SELECT';
