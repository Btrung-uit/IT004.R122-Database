------------------------------------------------------------------------
-- BT Quản Lý Bán Hàng: Phần III, Câu 13 - 19 (Sử dụng truy vấn lồng) --
------------------------------------------------------------------------

-- Chuyển qua db QuanLyBanHang
USE QuanLyBanHang
GO

-- 13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20. 
-- Cách 1: Truy vấn lồng độc lập
SELECT SOHD FROM CTHD
WHERE MASP = 'BB01'AND SL BETWEEN 10 AND 20
	AND SOHD IN (
		SELECT SOHD FROM CTHD
		WHERE MASP = 'BB02' AND SL BETWEEN 10 AND 20
	);

-- Cách 2: Truy vấn lồng tương quan
SELECT CT1.SOHD
FROM CTHD AS CT1
WHERE CT1.MASP = 'BB01' AND CT1.SL BETWEEN 10 AND 20
  AND EXISTS (
      SELECT 1
      FROM CTHD AS CT2
      WHERE CT2.SOHD = CT1.SOHD 
        AND CT2.MASP = 'BB02' 
        AND CT2.SL BETWEEN 10 AND 20
  );
-- 14. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được bán ra trong ngày 1/1/2007.
-- Cách 1: Truy vấn lồng độc lập
SELECT MASP, TENSP FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'
	OR MASP IN (
		SELECT CT.MASP
		FROM CTHD AS CT
		JOIN HOADON AS HD ON CT.SOHD = HD.SOHD
		WHERE HD.NGHD = '2007-01-01'
	);

-- Cách 2: Truy vấn lồng tương quan
SELECT MASP, TENSP 
FROM SANPHAM AS SP
WHERE NUOCSX = 'Trung Quoc'
	OR EXISTS (
		SELECT 1
		FROM CTHD AS CT
		JOIN HOADON AS HD ON CT.SOHD = HD.SOHD
		WHERE CT.MASP = SP.MASP
			AND HD.NGHD = '2007-01-01'
	);
-- 15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
-- Cách 1: Truy vấn lồng độc lập
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP NOT IN (
	SELECT MASP
	FROM CTHD
);

-- Cách 2: Truy vấn lồng tương quan
SELECT SP.MASP, SP.TENSP
FROM SANPHAM AS SP
WHERE NOT EXISTS (
	SELECT 1
	FROM CTHD AS CT
	WHERE CT.MASP = SP.MASP
);

-- 16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
-- Cách 1: Truy vấn lồng độc lập
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP NOT IN (
	SELECT CT.MASP
	FROM CTHD AS CT
	JOIN HOADON AS HD ON CT.SOHD = HD.SOHD
	WHERE YEAR(HD.NGHD) = 2006
);
-- Cách 2: Truy vấn lồng tương quan
SELECT SP.MASP, SP.TENSP
FROM SANPHAM AS SP
WHERE NOT EXISTS (
	SELECT 1
	FROM CTHD AS CT
	JOIN HOADON AS HD ON CT.SOHD = HD.SOHD
	WHERE CT.MASP = SP.MASP 
	AND YEAR(HD.NGHD) = 2006
);
-- 17. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006.
-- Cách 1: Truy vấn lồng độc lập
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'
	AND MASP NOT IN (
		SELECT CT.MASP
		FROM CTHD AS CT
		JOIN HOADON AS HD ON CT.SOHD = HD.SOHD
		WHERE YEAR(HD.NGHD) = 2006
	);

-- Cách 2: Truy vấn lồng tương quan
SELECT SP.MASP, SP.TENSP
FROM SANPHAM AS SP
WHERE NUOCSX = 'Trung Quoc'
	AND NOT EXISTS (
		SELECT 1
		FROM CTHD AS CT
		JOIN HOADON AS HD ON CT.SOHD = HD.SOHD
		WHERE CT.MASP = SP.MASP
		AND YEAR(HD.NGHD) = 2006
	);

-- 18. Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất. 
-- Cách 1: Truy vấn lồng độc lập
SELECT CT.SOHD
FROM CTHD AS CT
JOIN SANPHAM AS SP ON CT.MASP = SP.MASP
WHERE SP.NUOCSX = 'Singapore'
GROUP BY CT.SOHD
HAVING COUNT(DISTINCT CT.MASP) = (
    SELECT COUNT(*) 
    FROM SANPHAM 
    WHERE NUOCSX = 'Singapore'
);

-- Cách 2: Truy vấn lồng tương quan
-- Vậy dễ hiểu là lấy ra số hóa đơn mà hóa đơn đó không bỏ quên sản phẩm nào của Singapore. Không bỏ quên -> Mua hết tất cả || Có bỏ quên -> Không mua hết -> Loại
SELECT HD.SOHD
FROM HOADON AS HD
WHERE NOT EXISTS ( -- Chọn ra hóa đơn mà hóa đơn đó không bỏ quên món nào của Singapore
	SELECT 1
	FROM SANPHAM AS SP
	WHERE SP.NUOCSX = 'Singapore'
		AND NOT EXISTS ( -- Kiểm tra món nào không có trong hóa đơn. Có nghĩa là cầm tờ hóa đơn xem có quên sản phẩm nào của Singapore không
			SELECT 1
			FROM CTHD AS CT
			WHERE CT.SOHD = HD.SOHD
				AND CT.MASP = SP.MASP
		)
);

-- 19. Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất. 
-- Cách 1: Truy vấn lồng độc lập
SELECT CT.SOHD
FROM CTHD AS CT
JOIN HOADON AS HD ON CT.SOHD = HD.SOHD
JOIN SANPHAM AS SP ON CT.MASP = SP.MASP
WHERE YEAR(HD.NGHD) = 2006
	AND SP.NUOCSX = 'Singapore'
GROUP BY CT.SOHD
HAVING COUNT(DISTINCT CT.MASP) = (
    SELECT COUNT(*) 
    FROM SANPHAM 
    WHERE NUOCSX = 'Singapore'
);

-- Cách 2: Truy vấn lồng tương quan
SELECT HD.SOHD
FROM HOADON AS HD
WHERE YEAR(HD.NGHD) = 2006
	AND NOT EXISTS (
		SELECT 1
		FROM SANPHAM AS SP
		WHERE SP.NUOCSX = 'Singapore'
			AND NOT EXISTS (
				SELECT 1
				FROM CTHD AS CT
				WHERE CT.SOHD = HD.SOHD
					AND CT.MASP = SP.MASP
			)
);