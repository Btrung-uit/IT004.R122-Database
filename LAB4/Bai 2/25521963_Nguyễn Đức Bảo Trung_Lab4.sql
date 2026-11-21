----------------------------------------------------------------------
-------------------------------LAB - 4--------------------------------
-------------BT Quản Lý Giáo Vụ: Phần III, Câu 19 - 35----------------
----------------------------------------------------------------------

USE QuanLyGiaoVu
GO

-- Câu 19: Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT TOP 1 WITH TIES MAKHOA, TENKHOA
FROM KHOA
ORDER BY NGTLAP;

-- Câu 20: Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT COUNT(MAGV) AS SoGV
FROM GIAOVIEN
WHERE HOCHAM IN ('GS', 'PGS');

-- Câu 21: Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa. 
SELECT MAKHOA, HOCVI, COUNT(MAGV) AS SoGV
FROM GIAOVIEN
WHERE HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS')
GROUP BY MAKHOA, HOCVI
ORDER BY MAKHOA;

-- Câu 22: Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt). 
SELECT MAMH, KQUA, COUNT(DISTINCT MAHV) AS SoLuongHV
FROM KETQUATHI
GROUP BY  MAMH, KQUA
ORDER BY MAMH;
-- Giải thích: Dùng DISTINCT để COUNT MAHV vì có thể 1 học viên thi 1 môn nhiều lần không đạt, nếu không dùng DISTINCT thì sẽ đếm hết các lần không đạt đó trong khi mình chỉ cần 1 lần.

-- Câu 23: Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học.
SELECT gv.MAGV, gv.HOTEN
FROM GIAOVIEN AS gv
WHERE gv.MAGV IN (
	SELECT l.MAGVCN
	FROM LOP AS l
	JOIN GIANGDAY AS gd
	ON l.MALOP = gd.MALOP
	WHERE l.MAGVCN = gv.MAGV
);

-- Câu 24: Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (
	SELECT TOP 1 WITH TIES TRGLOP
	FROM LOP
	ORDER BY SISO DESC
);
	
-- Câu 25: * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi).
SELECT hv.HO + ' ' + hv.TEN AS HOTEN
FROM HOCVIEN AS hv
JOIN LOP AS l
ON hv.MAHV = l.TRGLOP
JOIN KETQUATHI AS kq
ON l.TRGLOP = kq.MAHV
WHERE kq.KQUA = 'Khong Dat'
AND NOT EXISTS (
	SELECT 1
	FROM KETQUATHI AS kq2
	WHERE kq2.MAHV = kq.MAHV
	AND kq2.MAMH = kq.MAMH
	AND kq2.KQUA = 'Dat'
)
GROUP BY hv.MAHV, hv.HO, hv.TEN
HAVING COUNT(DISTINCT kq.MAMH) > 3;

-- Câu 26: Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất. 
SELECT hv.MAHV, hv.HO + ' ' + hv.TEN AS HOTEN
FROM HOCVIEN AS hv
WHERE hv.MAHV IN (
	SELECT TOP 1 WITH TIES kq.MAHV
	FROM KETQUATHI AS kq
	WHERE kq.DIEM IN (9, 10)
	GROUP BY MAHV
	ORDER BY COUNT(kq.MAMH) DESC
);

-- Câu 27: Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.
SELECT hv.MALOP, hv.HO + ' ' + hv.TEN AS HOTEN
FROM HOCVIEN AS hv
WHERE hv.MAHV IN (
	SELECT TOP 1 WITH TIES hv2.MAHV
	FROM HOCVIEN AS hv2
	LEFT JOIN KETQUATHI AS kq
	ON hv2.MAHV = kq.MAHV
	AND kq.DIEM IN (9, 10)
	WHERE hv2.MALOP = hv.MALOP
	GROUP BY hv2.MAHV
	ORDER BY COUNT(kq.MAMH) DESC
);
-- Giải thích: Dùng LEFT JOIN vì giả sử trong 1 lớp nếu không có ai có điểm 9 10 thì các học viên sẽ đồng hạn là có 0 số môn đạt 9 10 => Nếu dùng INNER JOIN thì sẽ bỏ qua lớp đó. Nếu ta dùng LEFT JOIN thì sẽ in ra lớp đó với những học viên đồng hạng 0 có số môn đạt 9 10

-- Câu 28: Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
SELECT gd.NAM, gd.HOCKY, gv.HOTEN,
		COUNT(DISTINCT gd.MAMH) AS SoMonPhanCong,
		COUNT(DISTINCT gd.MALOP) AS SoLop
FROM GIANGDAY AS gd
JOIN GIAOVIEN AS gv
ON gd.MAGV = gv.MAGV
GROUP BY gd.NAM, gd.HOCKY, gv.MAGV, gv.HOTEN
ORDER BY gd.NAM, gd.HOCKY;
-- Giải thích:
-- 1. Sử dụng DISTINCT cho MAMH và MALOP vì 1 giáo viên có thể được phân công dạy 1 môn cho nhiều lớp, 1 giáo viên có thể được phân công dạy nhiều môn cho 1 lớp => Nếu không dùng DISTINCT thì đếm sẽ bị trùng.
-- 2. Trong GROUP BY có MAGV vì nếu chỉ đếm theo HOTEN thì có thể sẽ có giáo viên có họ tên trùng nhau dẫn đến GROUP sai do đó để phân biệt 1 cách chính xác thì nên thêm vào MAGV

-- Câu 29: Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất. 
SELECT gd.NAM, gd.HOCKY, gv.MAGV, gv.HOTEN
FROM GIANGDAY AS gd
JOIN GIAOVIEN AS gv
ON gd.MAGV = gv.MAGV
WHERE gv.MAGV IN (
	SELECT TOP 1 WITH TIES gd2.MAGV
	FROM GIANGDAY AS gd2
	WHERE gd2.NAM = gd.NAM
	AND gd2.HOCKY = gd.HOCKY
	GROUP BY gd2.MAGV
	ORDER BY COUNT(*) DESC
)
GROUP BY gd.NAM, gd.HOCKY, gv.MAGV, gv.HOTEN
ORDER BY gd.NAM, gd.HOCKY;

-- Câu 30: Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.
SELECT mh.MAMH, mh.TENMH
FROM MONHOC AS mh
WHERE mh.MAMH IN (
	SELECT TOP 1 WITH TIES kq.MAMH
	FROM KETQUATHI AS kq
	WHERE LANTHI = 1
	AND KQUA = 'Khong Dat'
	GROUP BY MAMH
	ORDER BY COUNT(MAHV) DESC
);

-- Câu 31: Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1). 
SELECT hv.MAHV, hv.HO + ' ' + hv.TEN AS HOTEN
FROM HOCVIEN AS hv
WHERE hv.MAHV IN (
	SELECT kq.MAHV
	FROM KETQUATHI AS kq
	WHERE kq.LANTHI = 1 
		AND kq.MAHV NOT IN (
		SELECT kq2.MAHV
		FROM KETQUATHI AS kq2
		WHERE kq2.KQUA = 'Khong Dat'
	)
);

-- Câu 32: * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng). 
SELECT hv.MAHV, hv.HO + ' ' + hv.TEN AS HOTEN
FROM HOCVIEN AS hv
WHERE hv.MAHV IN (
	SELECT kq.MAHV
	FROM KETQUATHI AS kq
)
AND hv.MAHV NOT IN (
	SELECT kq.MAHV
	FROM KETQUATHI AS kq
	WHERE kq.KQUA = 'Khong Dat'
	AND kq.LANTHI = (
		SELECT MAX(kq2.LANTHI)
		FROM KETQUATHI AS kq2
		WHERE kq2.MAHV = kq.MAHV
		AND kq2.MAMH = kq.MAMH
	)
);

-- Câu 33: * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi thứ 1). 
-- Câu 34: * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi sau cùng). 
-- Câu 35: ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng).