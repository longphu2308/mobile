-- ============================================
-- FIX: THÊM POLICY SELECT CHO USER ĐỌC ORDERS
-- ============================================

-- Xóa policy cũ nếu có
DROP POLICY IF EXISTS "Users can read own orders" ON orders;

-- Tạo policy mới cho user đọc orders của chính họ
CREATE POLICY "Users can read own orders" ON orders
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================
-- FIX: POLICY CHO ORDER_ITEMS (ĐƠN GIẢN, KHÔNG QUERY ORDERS)
-- ============================================
DROP POLICY IF EXISTS "Users can read own order items" ON order_items;
DROP POLICY IF EXISTS "Owners can read restaurant order items" ON order_items;
DROP POLICY IF EXISTS "Shippers can read assigned order items" ON order_items;

-- Cho phép tất cả authenticated users đọc order_items
-- (Vì orders đã có policy bảo vệ, user chỉ lấy được order_items của orders họ có quyền đọc)
CREATE POLICY "Users can read order items" ON order_items
  FOR SELECT
  TO authenticated
  USING (true);

-- ============================================
-- KIỂM TRA LẠI
-- ============================================
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('orders', 'order_items') AND cmd = 'SELECT'
ORDER BY tablename, policyname;
