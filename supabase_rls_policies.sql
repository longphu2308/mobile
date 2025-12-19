-- ============================================
-- RLS POLICIES CHO BUCKET profile_images
-- ============================================
-- Copy và paste các câu lệnh này vào Supabase SQL Editor
-- Đường dẫn: Dashboard → SQL Editor → New Query

-- Bước 1: Đảm bảo bucket đã được tạo
-- Vào Storage → Buckets → Tạo bucket mới tên "profile_images"
-- Chọn Public hoặc Private tùy nhu cầu

-- Bước 2: Tạo RLS Policies
-- Chạy các câu lệnh SQL sau:

-- ============================================
-- POLICY 1: Cho phép authenticated users UPLOAD (INSERT)
-- ============================================
CREATE POLICY "Allow authenticated users to upload profile images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile_images'
);

-- ============================================
-- POLICY 2: Cho phép authenticated users ĐỌC (SELECT)
-- ============================================
CREATE POLICY "Allow authenticated users to read profile images"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'profile_images'
);

-- ============================================
-- POLICY 3: Cho phép authenticated users XÓA (DELETE)
-- ============================================
CREATE POLICY "Allow authenticated users to delete profile images"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile_images'
);

-- ============================================
-- POLICY 4: Cho phép authenticated users CẬP NHẬT (UPDATE) - Tùy chọn
-- ============================================
CREATE POLICY "Allow authenticated users to update profile images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile_images'
)
WITH CHECK (
  bucket_id = 'profile_images'
);

-- ============================================
-- Nếu bạn muốn PUBLIC access (không cần đăng nhập):
-- ============================================
-- Thay TO authenticated thành TO public trong các policies trên

-- ============================================
-- Nếu bạn muốn giới hạn user chỉ upload/đọc/xóa ảnh của chính họ:
-- ============================================
-- Sử dụng các policies sau thay vì các policies trên:

-- Upload chỉ ảnh của chính mình (file name bắt đầu bằng userId)
CREATE POLICY "Allow users to upload their own images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile_images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Đọc chỉ ảnh của chính mình
CREATE POLICY "Allow users to read their own images"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'profile_images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Xóa chỉ ảnh của chính mình
CREATE POLICY "Allow users to delete their own images"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile_images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- KIỂM TRA POLICIES ĐÃ TẠO
-- ============================================
-- Chạy câu lệnh sau để xem tất cả policies của bucket:
SELECT * FROM storage.policies WHERE bucket_id = 'profile_images';

-- ============================================
-- XÓA POLICIES (nếu cần)
-- ============================================
-- DROP POLICY "Allow authenticated users to upload profile images" ON storage.objects;
-- DROP POLICY "Allow authenticated users to read profile images" ON storage.objects;
-- DROP POLICY "Allow authenticated users to delete profile images" ON storage.objects;

