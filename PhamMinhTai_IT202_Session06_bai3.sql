-- =========================================================
-- TOOL: TRUY QUÉT TÀI KHOẢN ĐẦU CƠ (SPAM / FRAUD)
-- =========================================================

-- Giả định bảng:
-- bookings(booking_id, user_id, status, total_price, ...)

-- =========================================================
-- 1. Ý TƯỞNG (I/O & LUỒNG)
-- =========================================================

-- Input:
--  - dữ liệu bookings theo từng user

-- Output:
--  - danh sách user_id thỏa:
--      + tổng số đơn >= 10
--      + số đơn CANCELLED > 5

-- Vấn đề:
--  - COUNT(*) → đếm toàn bộ đơn
--  - Nhưng cần đếm RIÊNG số đơn CANCELLED

--  Giải pháp:
--  - Dùng CASE WHEN bên trong SUM()
--  - Biến mỗi dòng thành:
--      CANCELLED → 1
--      khác → 0
--  - Sau đó SUM lại → ra số đơn bị hủy

-- =========================================================
-- 2. TRIỂN KHAI SQL (CHUẨN THI)
-- =========================================================

SELECT 
    user_id,
    COUNT(*) AS total_booking,   -- tổng số đơn
    SUM(
        CASE 
            WHEN status = 'CANCELLED' THEN 1
            ELSE 0
        END
    ) AS cancelled_count         -- số đơn bị hủy
FROM bookings
GROUP BY user_id
HAVING 
    COUNT(*) >= 10               -- tổng đơn >= 10
    AND 
    SUM(
        CASE 
            WHEN status = 'CANCELLED' THEN 1
            ELSE 0
        END
    ) > 5;                       -- đơn hủy > 5

-- =========================================================
-- 3. GIẢI THÍCH
-- =========================================================

-- COUNT(*) → đếm tất cả booking của user
-- CASE WHEN → lọc logic trong từng dòng
-- SUM(CASE ...) → đếm có điều kiện
-- GROUP BY user_id → gom theo user
-- HAVING → lọc sau khi đã tính toán

-- =========================================================
-- 4. VIẾT GỌN (ĐẸP HƠN)
-- =========================================================

SELECT 
    user_id,
    COUNT(*) AS total_booking,
    SUM(status = 'CANCELLED') AS cancelled_count   -- MySQL tự cast TRUE=1
FROM bookings
GROUP BY user_id
HAVING 
    total_booking >= 10
    AND cancelled_count > 5;

-- =========================================================
-- 5. BONUS (ANTI-FRAUD THỰC TẾ HƠN)
-- =========================================================

--  Tỷ lệ hủy cao (>50%)
SELECT 
    user_id,
    COUNT(*) AS total_booking,
    SUM(status = 'CANCELLED') AS cancelled_count,
    SUM(status = 'CANCELLED') / COUNT(*) AS cancel_rate
FROM bookings
GROUP BY user_id
HAVING 
    total_booking >= 10
    AND cancel_rate > 0.5;

-- =========================================================
-- 6. KẾT LUẬN
-- =========================================================
--  COUNT(*) → tổng
--  SUM(CASE WHEN ...) → đếm có điều kiện
--  HAVING → lọc theo nhóm
--  Pattern này = cực kỳ hay ra thi + dùng thực tế
-- =========================================================