use studentManagement;

-- 1.	 Cho biết họ tên sinh viên KHÔNG học học phần nào (5đ)-- 
select sv.masv, sv.hoten
from sinhvien sv 
where sv.masv not in (
select sv.masv
from sinhvien sv
join diemhp dhp on dhp.masv = sv.masv);

-- 2.	Cho biết họ tên sinh viên CHƯA học học phần nào có mã 1 (5đ)
select sv.masv, sv.hoten
from sinhvien sv 
where sv.masv not in (
select sv.masv
from sinhvien sv
join diemhp dhp on dhp.masv = sv.masv
where dhp.mahp = 1);

-- 3.	Cho biết Tên học phần KHÔNG có sinh viên điểm HP <5. (5đ)
select dmhp.mahp, dmhp.tenHP
from dmhocphan dmhp
where dmhp.tenHP not in (
select dmhp.tenHP
from diemhp dhp
join dmhocphan dmhp on dmhp.mahp = dhp.mahp
where dhp.diemHP <5);

-- 4.	Cho biết Họ tên sinh viên KHÔNG có học phần điểm HP<5 (5đ)
select sv.masv, sv.hoTen
from sinhvien sv
where sv.masv not in (
select dhp.masv
from diemhp dhp
where dhp.diemHP <5 );

-- 5.	Cho biết Tên lớp có sinh viên tên Hoa (5đ)
select l.tenLop
from dmlop l 
where l.malop = (select sv.malop from sinhvien sv where sv.hoTen like "%Hoa");

-- 6.	Cho biết HoTen sinh viên có điểm học phần 1 là <5.
select sv.hoTen
from sinhvien sv
where sv.maSV in
(select dhp.masv 
from diemhp dhp where maHP = 1 and diemHP < 5);

-- 7.	Cho biết danh sách các học phần có số đơn vị học trình lớn hơn hoặc bằng số đơn vị học trình của học phần mã 1.
select * from
dmhocphan
where sodvht >= 
(select sodvht
from dmhocphan where mahp = 1);

-- 8.	Cho biết HoTen sinh viên có DiemHP cao nhất. (ALL)
select hoten
from sinhvien
where maSV = all (select maSV from diemhp where diemHP = (select max(diemHP)from diemhp));

-- 9.	Cho biết MaSV, HoTen sinh viên có điểm học phần mã 1 cao nhất. (ALL)
select masv, hoten
from sinhvien
where maSV = all (select maSV from diemhp where diemHP = (select max(diemHP)from diemhp) and mahp = 1);

-- 10.	Cho biết MaSV, MaHP có điểm HP lớn hơn bất kì các điểm HP của sinh viên mã 3 (ANY).
select masv,mahp
from diemhp 
where diemhp > any (select diemhp from diemhp where masv = 3);

-- 11.	Cho biết MaSV, HoTen sinh viên ít nhất một lần học học phần nào đó. (EXISTS)
select masv,hoten
from sinhvien 
where exists
(select diemhp.masv from diemhp where sinhvien.masv = diemhp.masv );

-- 12.	Cho biết MaSV, HoTen sinh viên đã không học học phần nào. (EXISTS)
select masv,hoten
from sinhvien 
where not exists
(select diemhp.masv from diemhp where sinhvien.masv = diemhp.masv );

-- 13.	Cho biết MaSV đã học ít nhất một trong hai học phần có mã 1, 2. 
select masv from diemhp where mahp = 1
union
select masv from diemhp where mahp = 2;

-- 14.	Tạo thủ tục có tên KIEM_TRA_LOP cho biết HoTen sinh viên KHÔNG có điểm HP <5 ở lớp có mã chỉ định (tức là tham số truyền vào procedure là mã lớp). Phải kiểm tra MaLop chỉ định có trong danh mục hay không, nếu không thì hiển thị thông báo ‘Lớp này không có trong danh mục’. Khi lớp tồn tại thì đưa ra kết quả.
-- Ví dụ gọi thủ tục: Call KIEM_TRA_LOP(‘CT12’).
delimiter //
create procedure KIEM_TRA_LOP(input varchar(20))
begin
select hoten from sinhvien
where masv not in (select sv.masv 
from sinhvien sv join diemhp dhp on dhp.masv = sv.masv 
where dhp.diemHP < 5)
and malop = input;
end//
Call KIEM_TRA_LOP('CT13');

-- 15.	Tạo một trigger để kiểm tra tính hợp lệ của dữ liệu nhập vào bảng sinhvien là MaSV không được rỗng 
--  Nếu rỗng hiển thị thông báo ‘Mã sinh viên phải được nhập’.
delimiter //
create trigger checkMaSVNull
before insert on sinhvien for each row
begin
    if new.maSV is null then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mã sinh viên phải được nhập';
    end if;
end//
insert into sinhvien (hoten) values ('Nhung');

-- 16.	Tạo một TRIGGER khi thêm một sinh viên trong bảng sinhvien ở một lớp nào đó 
-- thì cột SiSo của lớp đó trong bảng dmlop (các bạn tạo thêm một cột SiSo trong bảng dmlop) tự động tăng lên 1, 
-- đảm bảo tính toàn vẹn dữ liệu khi thêm một sinh viên mới trong bảng sinhvien thì sinh viên đó phải có mã lớp trong bảng dmlop. 
-- Đảm bảo tính toàn vẹn dữ liệu khi thêm là mã lớp phải có trong bảng dmlop.
create trigger increaseSiSo
after insert on sinhvien for each row
update dmlop set siso = siso + 1 where malop = new.malop;
INSERT INTO sinhvien VALUES ('10', 'Nhung', 'CT12', '0', '19960427', 'Hà Nội')
-- 17.	Viết một function DOC_DIEM đọc điểm chữ số thập phân thành chữ  
-- Sau đó ứng dụng để lấy ra MaSV, HoTen, MaHP, DiemHP, DOC_DIEM(DiemHP) để đọc điểm HP của sinh viên đó thành chữ


-- 18.	Tạo thủ tục: HIEN_THI_DIEM Hiển thị danh sách gồm MaSV, HoTen, MaLop, DiemHP, MaHP của những sinh viên có DiemHP nhỏ hơn số chỉ định, 
-- nếu không có thì hiển thị thông báo không có sinh viên nào.
create view V_Diem as (select sv.masv,sv.hoten,dhp.diemhp,dhp.mahp from sinhvien sv join diemhp dhp on dhp.masv = sv.masv order by mahp);
delimiter //
create procedure HIEN_THI_DIEM(input float)
begin
declare c int;
set c = (select count(*) from V_Diem where diemhp < input);
if c > 0 then
 select * from V_Diem where diemhp < input;	
 else 
 SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không có sinh viên nào';
        end if;
end//
Call HIEN_THI_DIEM(4);
    
-- 19.	Tạo thủ tục: HIEN_THI_MAHP hiển thị HoTen sinh viên CHƯA học học phần có mã chỉ định. 
-- Kiểm tra mã học phần chỉ định có trong danh mục không. Nếu không có thì hiển thị thông báo không có học phần này.
-- Vd: Call HIEN_THI_MAHP(1);
delimiter //
create procedure HIEN_THI_MAHP(input int)
begin
declare a int;
set a = (select count(*) from dmhocphan where mahp = input);
if a = 0 then
 SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không có phần học này';
        else
        select distinct hoten from v_diem where masv not in (select masv from v_diem where mahp = input);
        end if;
end//
Call HIEN_THI_MAHP(2);

-- 20.	Tạo thủ tục: HIEN_THI_TUOI  Hiển thị danh sách gồm: MaSV, HoTen, MaLop, NgaySinh, GioiTinh, Tuoi của sinh viên có tuổi trong khoảng chỉ định. 
-- Nếu không có thì hiển thị không có sinh viên nào.
-- VD: Call HIEN_THI_TUOI (20,30);
delimiter //
create procedure HIEN_THI_TUOI(in `from` int,in `to` int)
begin
declare c int;
set c = (select count(*) from sinhvien where timestampdiff(year,ngaysinh,curdate()) between `from` and `to`);
if c > 0 then
select masv, hoten, malop, ngaysinh, gioitinh, timestampdiff(year,ngaysinh,curdate()) as tuoi from sinhvien
where timestampdiff(year,ngaysinh,curdate()) between `from` and `to`
order by tuoi;
else 
 SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không có sinh viên nào';
        end if;
end//
Call HIEN_THI_TUOI (40,50);