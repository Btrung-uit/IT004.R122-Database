----------------------------------------------------------------------
-------------------------------LAB - 4--------------------------------
-------------BT Quản Lý Bán Hàng: Phần III, Câu 20 - 45---------------
----------------------------------------------------------------------

-- Câu 20: Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua? 
SELECT COUNT(*) AS SoLuongHD
FROM HOADON
WHERE MAKH IS NULL;

-- Câu 21: Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.
SELECT COUNT(DISTINCT MASP) AS SoSPKhacNhau
FROM CTHD
WHERE SOHD IN (
	SELECT SOHD
	FROM HOADON
	WHERE YEAR(NGHD) = 2006
);
-- Giải thích: Có DISTINCT trong COUNT MASP vì nhiều CTHD có cùng MASP nên phải để DISTINCT để đếm MASP khác nhau

-- Câu 22: Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?
SELECT MAX(TRIGIA) AS GIA_MAX, MIN(TRIGIA) AS GIAM_MIN
FROM HOADON;
 
-- Câu 23: Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) AS TB_TRIGIA
FROM HOADON
WHERE YEAR(NGHD) = 2006;

-- Câu 24: Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(TRIGIA) AS DoanhThu
FROM HOADON
WHERE YEAR(NGHD) = 2006;

-- Câu 25: Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT SOHD
FROM HOADON
WHERE YEAR(NGHD) = 2006
AND TRIGIA = (
	SELECT MAX(TRIGIA)
	FROM HOADON
	WHERE YEAR(NGHD) = 2006
);

-- Câu 26: Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006. 
SELECT DISTINCT kh.HOTEN
FROM KHACHHANG AS kh
JOIN HOADON AS hd
ON kh.MAKH = hd.MAKH
WHERE YEAR(NGHD) = 2006
	AND TRIGIA = (
		SELECT MAX(TRIGIA)
		FROM HOADON
		WHERE YEAR(NGHD) = 2006
	);
-- Giải thích: Dùng DISTINCT khi SELECT HOTEN khách hàng vì có thể có trường hợp 1 khách hàng nhiều hóa đơn có cùng trị giá lớn nhất, nếu không có DISTINCT thì khi SELECT có thể sẽ trả về họ tên khách hàng đó nhiều lần.

-- Câu 27: In ra danh sách 3 khách hàng đầu tiên (MAKH, HOTEN) sắp xếp theo doanh số giảm dần.
SELECT TOP 3 MAKH, HOTEN
FROM KHACHHANG
ORDER BY DOANHSO DESC;

-- Câu 28: In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
SELECT MASP, TENSP
FROM SANPHAM
WHERE GIA IN (
	SELECT DISTINCT TOP 3 GIA
	FROM SANPHAM
	ORDER BY GIA DESC
);
-- Giải thích: Dùng DISTINCT khi SELECT TOP 3 GIA vì các sản phẩm có thể có cùng mức giá cao nhất nên dùng DISTINCT để chọn 3 mức giá cao nhất khác nhau.

-- Câu 29: In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm). 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Thai Lan'
AND GIA IN (
	SELECT DISTINCT TOP 3 GIA
	FROM SANPHAM
	ORDER BY GIA DESC
);

-- Câu 30: In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất). 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'
AND GIA IN (
	SELECT DISTINCT TOP 3 GIA
	FROM SANPHAM
	WHERE NUOCSX = 'Trung Quoc'
	ORDER BY GIA DESC
);

-- Câu 31: * In ra danh sách khách hàng nằm trong 3 hạng cao nhất (xếp hạng theo doanh số). 
SELECT MAKH, HOTEN
FROM KHACHHANG
WHERE DOANHSO IN (
	SELECT DISTINCT TOP 3 DOANHSO
	FROM KHACHHANG
	ORDER BY DOANHSO DESC
);

-- Câu 32: Tính tổng số sản phẩm do "Trung Quoc" sản xuất.
SELECT COUNT(*) AS SoLuongSPTQ
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc';

-- Câu 33: Tính tổng số sản phẩm của từng nước sản xuất.
SELECT NUOCSX, COUNT(*) AS SoLuongSP
FROM SANPHAM
GROUP BY NUOCSX;

-- Câu 34: Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm. 
SELECT NUOCSX,
	MAX(GIA) AS GIA_MAX,
	MIN(GIA) AS GIA_MIN,
	AVG(GIA) AS GIA_AVG
FROM SANPHAM
GROUP BY NUOCSX

-- Câu 35: Tính doanh thu bán hàng mỗi ngày. 
SELECT CAST(NGHD AS DATE) AS NGAY,
	   SUM(TRIGIA) AS DOANHTHU
FROM HOADON 
GROUP BY CAST(NGHD AS DATE)
ORDER BY NGAY;
-- Giải thích: Dùng CAST vì NGHD có thời gian giờ phút giây, trong cùng 1 ngày mà hóa đơn có thời gian khác nhau nếu không dùng CAST để loại bỏ phần giờ phút giây này thì khi GROUP BY nó sẽ cho ra nhiều nhóm riêng biệt dù cho các hóa đơn có cùng 1 ngày.

-- Câu 36: Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT MASP, SUM(SL) AS SoLuong
FROM CTHD
WHERE SOHD IN ( 
	SELECT SOHD
	FROM HOADON
	WHERE MONTH(NGHD) = 10 AND YEAR(NGHD) = 2006
)
GROUP BY MASP
ORDER BY MASP;

-- Câu 37: Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(NGHD) AS THANG, SUM(TRIGIA)
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
ORDER BY THANG

-- Câu 38: Tìm số hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT SOHD FROM CTHD
GROUP BY SOHD
HAVING  COUNT(DISTINCT SOHD) >= 4;

-- Câu 39: Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT SOHD
FROM CTHD
WHERE MASP IN (
	SELECT MASP
	FROM SANPHAM
	WHERE NUOCSX = 'Viet Nam'
)
GROUP BY SOHD
HAVING COUNT(DISTINCT MASP) = 3 -- 3 sản phẩm khác nhau
ORDER BY SOHD;

-- Câu 40: Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.  
SELECT MAKH, HOTEN
FROM KHACHHANG
WHERE MAKH IN (
	SELECT TOP 1 WITH TIES MAKH
	FROM HOADON
	WHERE MAKH IS NOT NULL
	GROUP BY MAKH
	ORDER BY COUNT(SOHD) DESC
)
-- Giải thích: Dùng WITH TIES khi SELECT TOP 1 MAKH vì có thể co nhiều KH có cùng số lần mua hàng nhiều nhất, thêm WITH TIES sẽ lấy những KH có cùng số lần mua nhiều nhất nếu có.

-- Câu 41: Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ? 
SELECT TOP 1 WITH TIES MONTH(NGHD) AS Thang
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
ORDER BY SUM(TRIGIA) DESC

-- Câu 42: Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP IN (
	SELECT TOP 1 WITH TIES ct.MASP
	FROM CTHD AS ct
	JOIN HOADON AS hd
	ON ct.SOHD = hd.SOHD
	WHERE YEAR(hd.NGHD) = 2006
	GROUP BY ct.MASP
	ORDER BY SUM(ct.SL)
);

-- Câu 43: *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất. 
SELECT sp.NUOCSX, sp.MASP, sp.TENSP
FROM SANPHAM AS sp
JOIN (
	SELECT NUOCSX, MAX(GIA) AS GIA_MAX
	FROM SANPHAM
	GROUP BY NUOCSX
) AS t
ON t.NUOCSX = sp.NUOCSX
AND t.GIA_MAX = sp.GIA;

-- Câu 44: Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT NUOCSX
FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3;

-- Câu 45: *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
SELECT TOP 1 WITH TIES kh.MAKH, kh.HOTEN
FROM KHACHHANG AS kh
JOIN HOADON AS hd
ON kh.MAKH = hd.MAKH
WHERE kh.MAKH IN (
	SELECT TOP 10 MAKH
	FROM KHACHHANG
	ORDER BY DOANHSO DESC
)
GROUP BY kh.MAKH, kh.HOTEN
ORDER BY COUNT(SOHD) DESC;

