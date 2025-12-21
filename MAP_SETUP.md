# Map & Location Setup Guide

## ✅ Đã hoàn thành:

### 1. Cài đặt packages
- `flutter_map` - Hiển thị bản đồ OpenStreetMap (FREE)
- `latlong2` - Tọa độ lat/lng
- `geolocator` - Lấy GPS location
- `permission_handler` - Xin quyền location
- `http` - Call routing API

### 2. Files đã tạo:
- `lib/core/services/location_service.dart` - Service lấy GPS, tính khoảng cách
- `lib/core/services/shipper_tracking_service.dart` - Auto-track shipper mỗi 10s
- `lib/Shipper/widgets/delivery_map_widget.dart` - Widget hiển thị map
- `lib/Shipper/views/order_detail.dart` - Đã integrate map thật

### 3. Android permissions đã thêm:
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- ACCESS_BACKGROUND_LOCATION

---

## 📋 Cần làm tiếp (Supabase):

### Bước 1: Update schema `restaurants` table
Chạy SQL trong Supabase SQL Editor:

```sql
-- Thêm cột lat/lng cho bảng restaurants
ALTER TABLE restaurants 
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- Update sample data (ví dụ cho Saigon)
UPDATE restaurants 
SET latitude = 10.762622, 
    longitude = 106.660172
WHERE latitude IS NULL;
```

### Bước 2: Update schema `shipper_profiles` table
```sql
-- Thêm cột tracking cho shipper (có thể đã có)
ALTER TABLE shipper_profiles 
ADD COLUMN IF NOT EXISTS current_latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS current_longitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS last_location_update TIMESTAMP WITH TIME ZONE;
```

### Bước 3: Enable Realtime cho customer tracking
```sql
-- Enable realtime cho bảng shipper_profiles
ALTER PUBLICATION supabase_realtime 
ADD TABLE shipper_profiles;
```

### Bước 4: RLS Policy cho location
```sql
-- Cho phép customer đọc vị trí shipper của đơn hàng mình
CREATE POLICY "Users can read their shipper location"
ON shipper_profiles FOR SELECT
TO authenticated
USING (
  user_id IN (
    SELECT shipper_id FROM orders WHERE user_id = auth.uid()
  )
);
```

---

## 🚀 Cách sử dụng:

### Trong Shipper Dashboard:
```dart
import 'package:mobile/core/services/shipper_tracking_service.dart';

// Start tracking khi shipper online
await ShipperTrackingService().startTracking();

// Stop tracking khi offline
ShipperTrackingService().stopTracking();
```

### Hiển thị map trong order detail:
Map sẽ tự động hiển thị với 3 markers:
- 🔵 Shipper (màu xanh dương)
- 🟠 Restaurant (màu cam)
- 🟢 Customer (màu xanh lá)

---

## 🎯 Tính năng tiếp theo có thể thêm:

### 1. Routing/Directions (FREE - OSRM API)
```dart
// Call OSRM API để lấy đường đi
final url = 'http://router.project-osrm.org/route/v1/driving/'
    '${startLng},${startLat};${endLng},${endLat}?overview=full&geometries=geojson';
```

### 2. Live tracking cho Customer
Tạo widget subscribe realtime:
```dart
supabase
  .from('shipper_profiles')
  .stream(primaryKey: ['user_id'])
  .eq('user_id', shipperId)
  .listen((data) {
    // Update shipper marker on map
  });
```

### 3. Turn-by-turn navigation
- Integrate với Google Maps app
- Hoặc dùng map packages khác

---

## 🐛 Troubleshooting:

### Map không hiện:
- Check internet connection
- Check console logs
- Verify lat/lng không null

### Location permission denied:
- Mở Settings → App → Permissions → Location → Allow

### Shipper location không update:
- Check Supabase RLS policies
- Check console logs cho errors
- Verify `shipper_profiles` table có cột lat/lng

---

## 📱 Test flow:

1. **Shipper side:**
   - Login as shipper
   - Mở Dashboard → start tracking
   - Mở order detail → xem map với 3 markers
   - Di chuyển điện thoại → location tự động update Supabase

2. **Customer side:** (cần implement thêm)
   - Login as customer
   - Mở order đang giao
   - Xem shipper di chuyển realtime trên map

---

## 💡 Tips:

- OpenStreetMap FREE hoàn toàn, không giới hạn
- Không cần credit card hay API key
- OSRM routing API cũng FREE
- Có thể cache tiles để dùng offline
- Nên throttle location updates (đã set 10 giây)

Có vấn đề gì ping tôi nhé! 🚀
