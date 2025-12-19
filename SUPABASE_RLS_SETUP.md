# Hướng dẫn cấu hình RLS Policies cho Supabase Storage

## Vấn đề
Lỗi "new row violates row-level security policy" hoặc "403 Unauthorized" xảy ra khi upload ảnh lên bucket `profile_images` vì bucket chưa có RLS policies phù hợp.

## Lưu ý quan trọng về Access Keys
**Với Supabase Flutter SDK, bạn KHÔNG cần sử dụng Access Key ID và Secret Access Key trực tiếp.** 

Supabase Flutter SDK tự động sử dụng JWT token từ Supabase Auth để xác thực. Access keys chỉ cần thiết nếu bạn sử dụng S3-compatible API trực tiếp (không qua Flutter SDK).

Code hiện tại đã được cấu hình để:
- Tự động refresh session nếu token sắp hết hạn
- Kiểm tra authentication trước khi upload
- Xử lý lỗi RLS một cách rõ ràng

## Giải pháp

### Bước 1: Tạo bucket `profile_images` trong Supabase Dashboard

1. Đăng nhập vào Supabase Dashboard: https://supabase.com/dashboard
2. Chọn project của bạn
3. Vào **Storage** → **Buckets**
4. Tạo bucket mới tên `profile_images`
5. Chọn **Public bucket** nếu muốn truy cập công khai, hoặc **Private bucket** nếu chỉ authenticated users mới truy cập được

### Bước 2: Cấu hình RLS Policies

Vào **Storage** → **Policies** → chọn bucket `profile_images`, sau đó tạo các policies sau:

#### Policy 1: Cho phép authenticated users upload ảnh của chính họ

```sql
-- Policy name: Allow authenticated users to upload their own images
-- Operation: INSERT
-- Target roles: authenticated

CREATE POLICY "Allow authenticated users to upload their own images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile_images' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

Hoặc nếu bạn muốn đơn giản hơn, cho phép tất cả authenticated users upload:

```sql
CREATE POLICY "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'profile_images');
```

#### Policy 2: Cho phép authenticated users đọc ảnh của chính họ

```sql
-- Policy name: Allow users to read their own images
-- Operation: SELECT
-- Target roles: authenticated

CREATE POLICY "Allow users to read their own images"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'profile_images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

Hoặc cho phép đọc public (nếu bucket là public):

```sql
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'profile_images');
```

#### Policy 3: Cho phép authenticated users xóa ảnh của chính họ

```sql
-- Policy name: Allow users to delete their own images
-- Operation: DELETE
-- Target roles: authenticated

CREATE POLICY "Allow users to delete their own images"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile_images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

### Bước 3: Cấu hình đơn giản hơn (Khuyến nghị)

Nếu bạn muốn đơn giản và cho phép tất cả authenticated users upload/read/delete trong bucket:

```sql
-- INSERT Policy
CREATE POLICY "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'profile_images');

-- SELECT Policy  
CREATE POLICY "Allow authenticated reads"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'profile_images');

-- DELETE Policy
CREATE POLICY "Allow authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'profile_images');
```

### Bước 4: Kiểm tra

Sau khi tạo policies, thử upload ảnh lại trong app. Nếu vẫn gặp lỗi:

1. Kiểm tra user đã đăng nhập chưa
2. Kiểm tra bucket name đúng là `profile_images`
3. Kiểm tra policies đã được tạo và enabled
4. Kiểm tra user có role `authenticated` trong Supabase Auth

## Lưu ý

- File name format trong code: `{userId}_{timestamp}.{extension}`
- Nếu bạn muốn sử dụng folder structure (ví dụ: `{userId}/{filename}`), cần cập nhật code và policies tương ứng
- Đảm bảo bucket `profile_images` đã được tạo trước khi chạy app

