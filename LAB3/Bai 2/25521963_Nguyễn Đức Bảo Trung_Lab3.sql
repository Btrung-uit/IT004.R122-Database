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
JOIN KETQUATHI AS kq
ON hv.MAHV = kq.MAHV
WHERE hv.MALOP LIKE 'K%' AND kq.MAMH = 'CTRR'
GROUP BY hv.MAHV, hv.HO, hv.TEN
HAVING MAX(kq.DIEM) < 5; -- Điểm cao nhất của tất cả các lần thi dưới 5 thì có nghĩa là không đạt ở tất cả các lần thi




-- Câu 6: Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006. 
-- Câu 7: Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006. 
-- Câu 8: Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”. 
-- Câu 9: In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”. 
-- Câu 10: Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào. 
-- Câu 11: Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.
-- Câu 12: Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này. 
-- Câu 13: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào. 
-- Câu 14: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách. 
-- Câu 15: Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm. 
-- Câu 16: Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học. 
-- Câu 17: Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng). 
-- Câu 18: Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi). 
-- Câu 19: Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất. 