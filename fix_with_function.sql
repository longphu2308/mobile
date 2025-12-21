-- ============================================
-- CÁCH 1: DISABLE RLS (Đơn giản nhất)
-- ============================================
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE order_items DISABLE ROW LEVEL SECURITY;

-- ============================================
-- CÁCH 2: TẠO FUNCTION SECURITY DEFINER (An toàn hơn)
-- Function này bypass RLS nhưng vẫn filter theo user_id
-- ============================================

-- Function lấy orders của user
CREATE OR REPLACE FUNCTION get_user_orders(p_user_id UUID)
RETURNS SETOF orders
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT * FROM orders 
  WHERE user_id = p_user_id 
  ORDER BY created_at DESC;
$$;

-- Function lấy order_items của order
CREATE OR REPLACE FUNCTION get_order_items(p_order_id UUID)
RETURNS SETOF order_items
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT * FROM order_items 
  WHERE order_id = p_order_id;
$$;

-- Function lấy orders kèm items của user (JSON)
CREATE OR REPLACE FUNCTION get_user_orders_with_items(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(
    json_build_object(
      'order_id', o.order_id,
      'user_id', o.user_id,
      'restaurant_id', o.restaurant_id,
      'shipper_id', o.shipper_id,
      'total_amount', o.total_amount,
      'status', o.status,
      'delivery_address', o.delivery_address,
      'delivery_latitude', o.delivery_latitude,
      'delivery_longitude', o.delivery_longitude,
      'payment_method', o.payment_method,
      'note', o.note,
      'cancel_reason', o.cancel_reason,
      'created_at', o.created_at,
      'updated_at', o.updated_at,
      'delivered_at', o.delivered_at,
      'order_items', (
        SELECT json_agg(
          json_build_object(
            'order_item_id', oi.order_item_id,
            'order_id', oi.order_id,
            'food_id', oi.food_id,
            'food_name', oi.food_name,
            'quantity', oi.quantity,
            'price', oi.price
          )
        )
        FROM order_items oi
        WHERE oi.order_id = o.order_id
      )
    )
  )
  INTO result
  FROM orders o
  WHERE o.user_id = p_user_id
  ORDER BY o.created_at DESC;
  
  RETURN COALESCE(result, '[]'::JSON);
END;
$$;
