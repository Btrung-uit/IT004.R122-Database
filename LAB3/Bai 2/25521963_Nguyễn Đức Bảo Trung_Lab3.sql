----------------------------------------------------------------------
-------------------------------LAB - 3--------------------------------
----------------------------------------------------------------------

----------------------------------------------------------------------
-- BT Quản Lý Giáo Vụ: Phần III, Câu 5 - 19 (Sử dụng truy vấn lồng) --
----------------------------------------------------------------------

USE QuanLyGiaoVu
GO

-- Câu 5: * Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả các lần thi). 
SELECT hv.MAHV, hv.HO + ' ' + hv.TEN AS HOTEN
FROM HOCVIEN AS hv
WHERE hv.MALOP LIKE 'K%'
	AND EXISTS (
		SELECT 1
		FROM KETQUATHI AS kq
		WHERE kq.MAHV = hv.MAHV
		AND kq.MAMH = 'CTRR'
	)
	AND NOT EXISTS (
		SELECT 1
		FROM KETQUATHI AS kq
		WHERE kq.MAHV = hv.MAHV
		AND kq.MAMH = 'CTRR'
		AND kq.DIEM >= 5
	);



-- Câu 6: Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006. 
SELECT TENMH
FROM MONHOC
WHERE MAMH IN (
	SELECT MAMH
	FROM GIANGDAY
	WHERE HOCKY = 1
	AND NAM = 2006
	AND MAGV IN (
		SELECT MAGV
		FROM GIAOVIEN
		WHERE HOTEN = 'Tran Tam Thanh'
	)
);

-- Câu 7: Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006.
SELECT TENMH, MAMH
FROM MONHOC
WHERE MAMH IN (
	SELECT MAMH
	FROM GIANGDAY
	WHERE HOCKY = 1
	AND NAM = 2006
	AND MAGV = ( -- Dùng = thay vì dùng IN vì truy vấn con trả về đúng 1 giá trị vì chỉ có đúng 1 MALOP K11
			SELECT MAGVCN
			FROM LOP
			WHERE MALOP = 'K11'
	)
);
-- Câu 8: Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”. 
SELECT HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (
	SELECT TRGLOP
	FROM LOP
	WHERE MALOP IN (
		SELECT MALOP
		FROM GIANGDAY
		WHERE MAGV IN (
			SELECT MAGV
			FROM GIAOVIEN
			WHERE HOTEN = 'Nguyen To Lan'
		)
		AND MAMH IN (
			SELECT MAMH
			FROM MONHOC
			WHERE TENMH = 'Co So Du Lieu'
		)
	)
);

-- Câu 9: In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.
SELECT MAMH, TENMH
FROM MONHOC
WHERE MAMH IN (
	SELECT MAMH_TRUOC
	FROM DIEUKIEN
	WHERE MAMH IN (
		SELECT MAMH
		FROM MONHOC
		WHERE TENMH = 'Co So Du Lieu'
	)
);

-- Câu 10: Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào.
SELECT MAMH, TENMH
FROM MONHOC
WHERE MAMH IN (
	SELECT MAMH
	FROM DIEUKIEN
	WHERE MAMH_TRUOC IN (
		SELECT MAMH
		FROM MONHOC
		WHERE TENMH = 'Cau Truc Roi Rac'
	)
);

-- Câu 11: Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.
SELECT HOTEN
FROM GIAOVIEN
WHERE MAGV IN (
	SELECT MAGV
	FROM GIANGDAY
	WHERE MALOP = 'K11'
	AND MAMH = 'CTRR'
	AND HOCKY = 1
	AND NAM = 2006
	AND MAGV IN (
		SELECT MAGV
		FROM GIANGDAY
		WHERE MALOP = 'K12'
		AND MAMH = 'CTRR'
		AND HOCKY = 1
		AND NAM = 2006
	)
);

-- Câu 12: Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này.
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (
	SELECT MAHV
	FROM KETQUATHI
	WHERE MAMH = 'CSDL'
	AND KQUA = 'Khong Dat'
	AND LANTHI = 1
	AND MAHV NOT IN (
		SELECT MAHV
		FROM KETQUATHI
		WHERE MAMH = 'CSDL'
		AND LANTHI > 1
	)
);

-- Câu 13: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào. 
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV NOT IN (
	SELECT MAGV
	FROM GIANGDAY
);

-- Câu 14: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách.
SELECT gv.MAGV, gv.HOTEN
FROM GIAOVIEN AS gv
WHERE gv.MAGV NOT IN (
	SELECT gd.MAGV
	FROM GIANGDAY AS gd
	WHERE gd.MAGV = gv.MAGV
	AND gd.MAMH IN (
		SELECT mh.MAMH
		FROM MONHOC AS mh
		WHERE mh.MAKHOA = gv.MAKHOA
	)
);

-- Câu 15: Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm.
SELECT hv.HO + ' ' + hv.TEN AS HOTEN
FROM HOCVIEN AS hv
WHERE hv.MALOP = 'K11'
AND hv.MAHV IN (
	SELECT kq.MAHV
	FROM KETQUATHI AS kq
	WHERE (kq.LANTHI > 3
	AND kq.KQUA = 'Khong Dat')
	OR (kq.LANTHI = 2
	AND kq.MAMH = 'CTRR'
	AND kq.DIEM = 5)
);

-- Câu 16: Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.
SELECT gv.HOTEN
FROM GIAOVIEN AS gv
WHERE gv.MAGV IN (
	SELECT gd.MAGV
	FROM GIANGDAY AS gd
	WHERE gd.MAMH = 'CTRR'
	GROUP BY MAGV, HOCKY, NAM -- Gom nhóm theo học kỳ và năm, sau đó đếm số lớp khác nhau, group by MAGV vì ta cần biết lớp nào cùng 1 học kì của 1 năm học
	HAVING COUNT(DISTINCT MALOP) >= 2
);

-- Câu 17: Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng). 
SELECT hv.MAHV, hv.HO + ' ' + hv.TEN AS HOTEN, kq.DIEM
FROM HOCVIEN AS hv
JOIN KETQUATHI AS kq
ON hv.MAHV = kq.MAHV
WHERE kq.MAMH = 'CSDL'
AND kq.LANTHI = (
	SELECT MAX(kq2.LANTHI)
	FROM KETQUATHI AS kq2
	WHERE kq2.MAHV = kq.MAHV
	AND kq2.MAMH = kq.MAMH
)
ORDER BY hv.MAHV ASC;


-- Câu 18: Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).
SELECT DISTINCT hv.MAHV, hv.HO + ' ' + hv.TEN AS HOTEN, kq.DIEM -- Dùn DISTINCT vì học viên thi các lần khác nhau có thể có cùng số điểm tối đa
FROM HOCVIEN AS hv
JOIN KETQUATHI AS kq
ON hv.MAHV = kq.MAHV
WHERE kq.MAMH IN (
	SELECT mh.MAMH
	FROM MONHOC AS mh
	WHERE TENMH = 'Co So Du Lieu'
)
AND kq.DIEM = (
	SELECT MAX(kq2.DIEM)
	FROM KETQUATHI AS kq2
	WHERE kq2.MAHV = kq.MAHV
	AND kq2.MAMH = kq.MAMH
);

-- Câu 19: Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất. 
SELECT k.MAKHOA, k.TENKHOA
FROM KHOA AS k
WHERE NGTLAP = (
	SELECT MIN(NGTLAP)
	FROM KHOA
);