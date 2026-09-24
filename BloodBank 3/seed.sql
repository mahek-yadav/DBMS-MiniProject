-- ============================================================
--  BLOOD BANK NETWORK — SEED DATA
--  Realistic Indian data for all 6 tables
-- ============================================================

-- ========================
-- DONORS (20 donors)
-- ========================
INSERT INTO donor (first_name, last_name, blood_group, gender, dob, phone, email, city)
VALUES
('Rahul',   'Sharma',   'O+',  'M', '1995-03-14', '9876543210', 'rahul.sharma@gmail.com',   'Mumbai'),
('Priya',   'Mehta',    'A+',  'F', '1998-07-22', '9876543211', 'priya.mehta@gmail.com',     'Mumbai'),
('Amit',    'Verma',    'B+',  'M', '1990-01-10', '9876543212', 'amit.verma@gmail.com',      'Delhi'),
('Sneha',   'Patil',    'AB+', 'F', '1993-11-05', '9876543213', 'sneha.patil@gmail.com',     'Pune'),
('Karan',   'Patel',    'O-',  'M', '1997-06-18', '9876543214', 'karan.patel@gmail.com',     'Ahmedabad'),
('Neha',    'Singh',    'A-',  'F', '1996-09-30', '9876543215', 'neha.singh@gmail.com',      'Delhi'),
('Rohit',   'Kumar',    'B-',  'M', '1992-04-12', '9876543216', 'rohit.kumar@gmail.com',     'Bangalore'),
('Anjali',  'Reddy',    'O+',  'F', '1994-12-25', '9876543217', 'anjali.reddy@gmail.com',    'Hyderabad'),
('Vikas',   'Joshi',    'AB-', 'M', '1991-08-08', '9876543218', 'vikas.joshi@gmail.com',     'Pune'),
('Meera',   'Nair',     'A+',  'F', '1999-02-14', '9876543219', 'meera.nair@gmail.com',      'Chennai'),
('Arjun',   'Gupta',    'B+',  'M', '1988-05-20', '9876543220', 'arjun.gupta@gmail.com',     'Delhi'),
('Pooja',   'Desai',    'O+',  'F', '1997-10-03', '9876543221', 'pooja.desai@gmail.com',     'Mumbai'),
('Suresh',  'Yadav',    'A-',  'M', '1985-07-15', '9876543222', 'suresh.yadav@gmail.com',    'Ahmedabad'),
('Kavita',  'Bose',     'B+',  'F', '1993-03-28', '9876543223', 'kavita.bose@gmail.com',     'Kolkata'),
('Deepak',  'Mishra',   'AB+', 'M', '1990-11-11', '9876543224', 'deepak.mishra@gmail.com',   'Bangalore'),
('Riya',    'Chopra',   'O-',  'F', '1996-01-07', '9876543225', 'riya.chopra@gmail.com',     'Chandigarh'),
('Manish',  'Tiwari',   'A+',  'M', '1989-09-19', '9876543226', 'manish.tiwari@gmail.com',   'Pune'),
('Swati',   'Kulkarni', 'B-',  'F', '1995-06-02', '9876543227', 'swati.kulkarni@gmail.com',  'Mumbai'),
('Nikhil',  'Saxena',   'O+',  'M', '1992-12-30', '9876543228', 'nikhil.saxena@gmail.com',   'Delhi'),
('Tanvi',   'Iyer',     'AB-', 'F', '1998-04-16', '9876543229', 'tanvi.iyer@gmail.com',      'Chennai');


-- ========================
-- BLOOD BANKS (6 blood banks)
-- ========================
INSERT INTO blood_bank (bank_name, city, phone)
VALUES
('LifeLine Blood Bank',     'Mumbai',     '0221234567'),
('Red Cross Blood Centre',  'Delhi',      '0112345678'),
('City Blood Bank',         'Pune',       '0203456789'),
('Apollo Blood Centre',     'Bangalore',  '0804567890'),
('Care Blood Bank',         'Hyderabad',  '0405678901'),
('Hope Blood Bank',         'Chennai',    '0446789012');


-- ========================
-- DONATIONS (18 donations — donors 19 and 20 have NEVER donated)
-- ========================
INSERT INTO donation (donor_id, bank_id, donation_date)
VALUES
-- Donor 1 (Rahul) donated 3 times
(1,  1, '2025-01-10'),
(1,  1, '2025-06-15'),
(1,  3, '2025-11-20'),
-- Donor 2
(2,  1, '2025-02-14'),
-- Donor 3 donated twice
(3,  2, '2025-03-05'),
(3,  2, '2025-09-10'),
-- Donor 4
(4,  3, '2025-04-22'),
-- Donor 5
(5,  1, '2025-05-30'),
-- Donor 6
(6,  2, '2025-06-18'),
-- Donor 7 donated twice
(7,  4, '2025-07-04'),
(7,  4, '2025-12-01'),
-- Donor 8
(8,  5, '2025-08-15'),
-- Donor 9
(9,  3, '2025-09-25'),
-- Donor 10
(10, 6, '2025-10-10'),
-- Donor 11
(11, 2, '2025-11-11'),
-- Donor 12
(12, 1, '2025-12-25'),
-- Donor 13
(13, 1, '2025-03-18'),
-- Donor 14
(14, 5, '2025-04-09');
-- Donors 15-20: no donations (15, 16 donated below; 19, 20 never donate)

-- Donor 15
INSERT INTO donation (donor_id, bank_id, donation_date) VALUES (15, 4, '2025-05-14');
-- Donor 16
INSERT INTO donation (donor_id, bank_id, donation_date) VALUES (16, 6, '2025-07-22');
-- Donors 17, 18 donated
INSERT INTO donation (donor_id, bank_id, donation_date) VALUES (17, 3, '2025-08-30');
INSERT INTO donation (donor_id, bank_id, donation_date) VALUES (18, 1, '2025-10-05');
-- Donors 19 (Nikhil) and 20 (Tanvi) have NEVER donated — used in Query 12


-- ========================
-- HOSPITALS (6 hospitals)
-- ========================
INSERT INTO hospital (hospital_name, city, phone)
VALUES
('KEM Hospital',         'Mumbai',     '0221111111'),
('AIIMS Delhi',          'Delhi',      '0112222222'),
('Sassoon Hospital',     'Pune',       '0203333333'),
('Manipal Hospital',     'Bangalore',  '0804444444'),
('Nizam Hospital',       'Hyderabad',  '0405555555'),
('Apollo Chennai',       'Chennai',    '0446666666');


-- ========================
-- BLOOD UNITS (30 units from the 22 donations)
-- ========================
-- donation_id 1-3 belong to donor 1, etc.
INSERT INTO blood_unit (donation_id, blood_group, volume_ml, status, bank_id)
VALUES
-- From donation 1
(1,  'O+',  350, 'available', 1),
(1,  'O+',  250, 'issued',    1),
-- From donation 2
(2,  'O+',  450, 'available', 1),
-- From donation 3
(3,  'O+',  300, 'issued',    3),
-- From donation 4
(4,  'A+',  400, 'available', 1),
(4,  'A+',  350, 'available', 1),
-- From donation 5
(5,  'B+',  320, 'available', 2),
(5,  'B+',  280, 'reserved',  2),
-- From donation 6
(6,  'B+',  380, 'issued',    2),
-- From donation 7
(7,  'AB+', 340, 'available', 3),
-- From donation 8
(8,  'O-',  360, 'available', 1),
-- From donation 9
(9,  'A-',  300, 'issued',    2),
-- From donation 10
(10, 'B-',  310, 'available', 4),
(10, 'B-',  290, 'available', 4),
-- From donation 11
(11, 'O+',  370, 'available', 4),
-- From donation 12
(12, 'A+',  420, 'available', 5),
-- From donation 13
(13, 'AB-', 330, 'reserved',  3),
-- From donation 14
(14, 'A+',  350, 'available', 6),
-- From donation 15
(15, 'B+',  400, 'available', 2),
-- From donation 16
(16, 'O+',  380, 'available', 1),
-- From donation 17
(17, 'A-',  310, 'issued',    1),
-- From donation 18
(18, 'B+',  340, 'available', 5),
-- From donation 19 (donation_id 19)
(19, 'AB+', 350, 'available', 4),
-- From donation 20
(20, 'O-',  300, 'available', 6),
-- From donation 21
(21, 'A+',  360, 'available', 3),
-- From donation 22
(22, 'B-',  290, 'available', 1),
-- Extra units to give variety
(2,  'O+',  200, 'expired',   1),
(6,  'B+',  410, 'available', 2),
(11, 'O+',  350, 'reserved',  4),
(12, 'A+',  300, 'available', 5);


-- ========================
-- HOSPITAL REQUESTS (10 requests)
-- ========================
INSERT INTO hospital_request (hospital_id, blood_group, units_requested, request_date, status)
VALUES
(1, 'O+',  5,  '2025-12-01', 'fulfilled'),
(1, 'A+',  3,  '2025-12-05', 'pending'),
(2, 'B+',  4,  '2025-12-10', 'pending'),
(3, 'AB+', 2,  '2025-12-12', 'fulfilled'),
(4, 'O-',  6,  '2025-12-15', 'pending'),
(5, 'A-',  2,  '2025-12-18', 'fulfilled'),
(6, 'B-',  3,  '2025-12-20', 'pending'),
(2, 'O+',  8,  '2025-12-22', 'pending'),
(3, 'A+',  1,  '2025-12-25', 'fulfilled'),
(4, 'AB-', 2,  '2025-12-28', 'pending');


-- ========================
-- ISSUE UNITS TO HOSPITALS (mark which units went where)
-- ========================
-- Unit 2 (O+) issued to KEM Hospital (1)
UPDATE blood_unit SET issued_to_hospital = 1 WHERE unit_id = 2;
-- Unit 4 (O+) issued to Sassoon Hospital (3)
UPDATE blood_unit SET issued_to_hospital = 3 WHERE unit_id = 4;
-- Unit 9 (B+) issued to AIIMS Delhi (2)
UPDATE blood_unit SET issued_to_hospital = 2 WHERE unit_id = 9;
-- Unit 12 (A-) issued to Nizam Hospital (5)
UPDATE blood_unit SET issued_to_hospital = 5 WHERE unit_id = 12;
-- Unit 21 (A-) issued to AIIMS Delhi (2)
UPDATE blood_unit SET issued_to_hospital = 2 WHERE unit_id = 21;
