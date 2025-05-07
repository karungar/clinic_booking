-- Clinic Booking System Database
-- A database for managing a healthcare clinic's appointments, staff, patients, and services
CREATE DATABASE clinicdb;
USE clinicdb;
-- Create Clinics table
CREATE TABLE Clinics (
    clinic_id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    website VARCHAR(100),
    opening_hours VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Departments table
CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_id INT NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    description TEXT,
    floor INT,
    phone_extension VARCHAR(10),
    FOREIGN KEY (clinic_id) REFERENCES Clinics(clinic_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Staff table (base table for all employees)
CREATE TABLE Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(255) NOT NULL,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    emergency_contact VARCHAR(100),
    emergency_phone VARCHAR(20),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Doctors table (extends Staff)
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    staff_id INT UNIQUE NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    years_of_experience INT NOT NULL DEFAULT 0,
    bio TEXT,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Patients table
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(255) NOT NULL,
    emergency_contact VARCHAR(100),
    emergency_phone VARCHAR(20),
    blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    allergies TEXT,
    insurance_provider VARCHAR(100),
    insurance_policy_number VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Specialties table
CREATE TABLE Specialties (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Services table
CREATE TABLE Services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    duration_minutes INT NOT NULL DEFAULT 30,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Service Prices table (connects services to clinics with prices)
CREATE TABLE ServicePrices (
    service_price_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    clinic_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (service_id) REFERENCES Services(service_id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_id) REFERENCES Clinics(clinic_id) ON DELETE CASCADE,
    UNIQUE KEY unique_service_clinic (service_id, clinic_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Doctor Specialties table (Many-to-Many relationship between Doctors and Specialties)
CREATE TABLE DoctorSpecialties (
    doctor_id INT NOT NULL,
    specialty_id INT NOT NULL,
    PRIMARY KEY (doctor_id, specialty_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (specialty_id) REFERENCES Specialties(specialty_id) ON DELETE CASCADE,
    certification_date DATE,
    certification_number VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Appointments table
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    service_id INT NOT NULL,
    clinic_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status ENUM('Scheduled', 'Confirmed', 'Completed', 'Cancelled', 'No-Show') DEFAULT 'Scheduled',
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES Services(service_id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_id) REFERENCES Clinics(clinic_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Medical Records table
CREATE TABLE MedicalRecords (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    diagnosis TEXT,
    treatment TEXT,
    notes TEXT,
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_date DATE,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Prescriptions table
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    duration VARCHAR(50) NOT NULL,
    notes TEXT,
    FOREIGN KEY (record_id) REFERENCES MedicalRecords(record_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Payments table
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATETIME NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Insurance', 'Online Payment') NOT NULL,
    status ENUM('Pending', 'Completed', 'Refunded', 'Failed') DEFAULT 'Pending',
    transaction_id VARCHAR(100),
    insurance_claim_id VARCHAR(100),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Sample Data Insertion

-- Insert Clinic data
INSERT INTO Clinics (clinic_name, address, city, state, zip_code, phone, email, website, opening_hours) VALUES
('HealthFirst Medical Center', '123 Wellness Avenue', 'Springfield', 'IL', '62704', '555-123-4567', 'info@healthfirst.com', 'www.healthfirst.com', 'Mon-Fri: 8:00-18:00, Sat: 9:00-13:00, Sun: Closed'),
('CarePoint Health Clinic', '456 Healing Boulevard', 'Springfield', 'IL', '62701', '555-987-6543', 'contact@carepoint.com', 'www.carepointclinic.com', 'Mon-Sat: 7:30-19:00, Sun: 9:00-14:00');

-- Insert Department data
INSERT INTO Departments (clinic_id, department_name, description, floor, phone_extension) VALUES
(1, 'General Medicine', 'Primary healthcare services for patients of all ages', 1, '101'),
(1, 'Pediatrics', 'Healthcare services for children and adolescents', 1, '102'),
(1, 'Cardiology', 'Diagnosis and treatment of heart conditions', 2, '201'),
(2, 'Dermatology', 'Diagnosis and treatment of skin conditions', 1, '101'),
(2, 'Orthopedics', 'Treatment of musculoskeletal conditions', 2, '201');

-- Insert Staff data
INSERT INTO Staff (department_id, first_name, last_name, gender, date_of_birth, email, phone, address, position, hire_date, emergency_contact, emergency_phone) VALUES
(1, 'John', 'Smith', 'Male', '1975-05-15', 'john.smith@healthfirst.com', '555-111-2222', '789 Oak Street, Springfield, IL 62704', 'Chief Physician', '2015-03-10', 'Mary Smith', '555-111-3333'),
(2, 'Sarah', 'Johnson', 'Female', '1980-08-22', 'sarah.johnson@healthfirst.com', '555-222-3333', '567 Maple Road, Springfield, IL 62704', 'Pediatrician', '2017-06-15', 'Robert Johnson', '555-222-4444'),
(3, 'Michael', 'Williams', 'Male', '1970-11-03', 'michael.williams@healthfirst.com', '555-333-4444', '890 Elm Avenue, Springfield, IL 62704', 'Cardiologist', '2016-09-20', 'Jennifer Williams', '555-333-5555'),
(4, 'Emily', 'Brown', 'Female', '1982-02-14', 'emily.brown@carepoint.com', '555-444-5555', '123 Pine Street, Springfield, IL 62701', 'Dermatologist', '2018-04-05', 'David Brown', '555-444-6666'),
(5, 'Robert', 'Davis', 'Male', '1978-07-27', 'robert.davis@carepoint.com', '555-555-6666', '456 Cedar Boulevard, Springfield, IL 62701', 'Orthopedic Surgeon', '2019-01-15', 'Lisa Davis', '555-555-7777'),
(1, 'Jessica', 'Miller', 'Female', '1985-09-18', 'jessica.miller@healthfirst.com', '555-666-7777', '789 Birch Lane, Springfield, IL 62704', 'Nurse', '2018-03-12', 'Thomas Miller', '555-666-8888'),
(4, 'Daniel', 'Wilson', 'Male', '1990-04-30', 'daniel.wilson@carepoint.com', '555-777-8888', '234 Spruce Drive, Springfield, IL 62701', 'Nurse', '2020-06-10', 'Emma Wilson', '555-777-9999');

-- Insert Doctors data
INSERT INTO Doctors (doctor_id, staff_id, license_number, years_of_experience, bio) VALUES
(1, 1, 'IL-MD-12345', 20, 'Dr. Smith is a board-certified physician with extensive experience in general medicine and preventive care.'),
(2, 2, 'IL-MD-23456', 15, 'Dr. Johnson specializes in pediatric care and has a special interest in childhood development and preventive healthcare.'),
(3, 3, 'IL-MD-34567', 25, 'Dr. Williams is a renowned cardiologist specializing in interventional cardiology and cardiac imaging.'),
(4, 4, 'IL-MD-45678', 13, 'Dr. Brown is a board-certified dermatologist specializing in medical and cosmetic dermatology.'),
(5, 5, 'IL-MD-56789', 17, 'Dr. Davis is an orthopedic surgeon specializing in sports injuries and joint replacement surgeries.');

-- Insert Patients data
INSERT INTO Patients (first_name, last_name, gender, date_of_birth, email, phone, address, emergency_contact, emergency_phone, blood_type, allergies, insurance_provider, insurance_policy_number) VALUES
('James', 'Anderson', 'Male', '1985-06-12', 'james.anderson@email.com', '555-123-9876', '123 Main Street, Springfield, IL 62704', 'Linda Anderson', '555-123-8765', 'O+', 'Penicillin', 'Blue Cross', 'BC123456789'),
('Patricia', 'Taylor', 'Female', '1990-03-25', 'patricia.taylor@email.com', '555-234-8765', '456 High Street, Springfield, IL 62704', 'Thomas Taylor', '555-234-7654', 'A+', 'None', 'Aetna', 'AET987654321'),
('Richard', 'Thomas', 'Male', '1975-11-08', 'richard.thomas@email.com', '555-345-7654', '789 Park Avenue, Springfield, IL 62704', 'Susan Thomas', '555-345-6543', 'B-', 'Sulfa drugs', 'United Healthcare', 'UH456789123'),
('Elizabeth', 'Harris', 'Female', '1980-02-17', 'elizabeth.harris@email.com', '555-456-6543', '234 Lake Drive, Springfield, IL 62701', 'William Harris', '555-456-5432', 'AB+', 'Latex', 'Cigna', 'CG789123456'),
('Charles', 'Martin', 'Male', '1995-09-30', 'charles.martin@email.com', '555-567-5432', '567 River Road, Springfield, IL 62701', 'Margaret Martin', '555-567-4321', 'O-', 'Aspirin', 'Humana', 'HU321654987'),
('Susan', 'Thompson', 'Female', '1972-07-22', 'susan.thompson@email.com', '555-678-4321', '890 Forest Lane, Springfield, IL 62704', 'Joseph Thompson', '555-678-3210', 'A-', 'Shellfish', 'Medicare', 'MC123789456'),
('Sarah', 'Jones', 'Female', '2015-04-15', 'parent.jones@email.com', '555-789-3210', '345 Meadow Path, Springfield, IL 62704', 'David Jones', '555-789-2109', 'B+', 'Peanuts', 'Blue Cross', 'BC987456123');

-- Insert Specialties data
INSERT INTO Specialties (specialty_name, description) VALUES
('Family Medicine', 'Primary care for patients of all ages'),
('Pediatrics', 'Medical care for infants, children, and adolescents'),
('Cardiology', 'Diagnosis and treatment of heart disease'),
('Dermatology', 'Medical and surgical treatment of the skin'),
('Orthopedics', 'Treatment of the musculoskeletal system'),
('Internal Medicine', 'Prevention, diagnosis, and treatment of adult diseases');

-- Insert Doctor Specialties relationships
INSERT INTO DoctorSpecialties (doctor_id, specialty_id, certification_date, certification_number) VALUES
(1, 1, '2010-05-20', 'CERT-FM-12345'),
(1, 6, '2012-03-15', 'CERT-IM-23456'),
(2, 2, '2008-06-10', 'CERT-PD-34567'),
(3, 3, '2005-09-25', 'CERT-CD-45678'),
(4, 4, '2010-04-18', 'CERT-DM-56789'),
(5, 5, '2006-11-30', 'CERT-OP-67890');

-- Insert Services data
INSERT INTO Services (service_name, description, duration_minutes) VALUES
('General Consultation', 'Routine check-up and consultation', 30),
('Pediatric Check-up', 'Regular check-up for children', 30),
('Cardiac Evaluation', 'Comprehensive heart examination', 60),
('Skin Examination', 'Examination of skin conditions', 45),
('Orthopedic Assessment', 'Evaluation of bone and joint issues', 45),
('Vaccination', 'Administration of vaccines', 15),
('Blood Test', 'Collection and analysis of blood samples', 15),
('ECG', 'Electrocardiogram test', 30),
('X-Ray', 'Radiographic imaging', 30),
('Minor Surgery', 'Small surgical procedures', 90);

-- Insert Service Prices data
INSERT INTO ServicePrices (service_id, clinic_id, price) VALUES
(1, 1, 75.00),
(2, 1, 90.00),
(3, 1, 150.00),
(6, 1, 40.00),
(7, 1, 35.00),
(8, 1, 85.00),
(9, 1, 110.00),
(10, 1, 250.00),
(1, 2, 80.00),
(4, 2, 120.00),
(5, 2, 130.00),
(6, 2, 45.00),
(7, 2, 40.00),
(9, 2, 120.00),
(10, 2, 275.00);

-- Insert Appointments data
INSERT INTO Appointments (appointment_id,patient_id, doctor_id, service_id, clinic_id, appointment_date, start_time, end_time, status, notes) VALUES
(1, 1, 1, 1, 1, '2023-05-15', '09:00:00', '09:30:00', 'Completed', 'Regular check-up'),
(2, 2, 1, 1, 1, '2023-05-15', '10:00:00', '10:30:00', 'Completed', 'Follow-up for hypertension'),
(3, 3, 3, 3, 1, '2023-05-15', '11:00:00', '12:00:00', 'Completed', 'Chest pain evaluation'),
(4, 4, 4, 4, 2, '2023-05-16', '09:30:00', '10:15:00', 'Completed', 'Skin rash examination'),
(5, 5, 5, 5, 2, '2023-05-16', '11:00:00', '11:45:00', 'Completed', 'Knee pain assessment'),
(6, 7, 2, 2, 1, '2023-05-17', '10:00:00', '10:30:00', 'Completed', 'Regular pediatric check-up'),
(7, 1, 1, 1, 1, '2023-06-15', '09:00:00', '09:30:00', 'Confirmed', 'Follow-up appointment'),
(8, 6, 3, 3, 1, '2023-06-16', '13:00:00', '14:00:00', 'Scheduled', 'New patient cardiac evaluation'),
(9, 4, 4, 4, 2, '2023-06-17', '14:30:00', '15:15:00', 'Confirmed', 'Follow-up for skin condition');

-- Insert Medical Records data
INSERT INTO MedicalRecords (appointment_id, diagnosis, treatment, notes, follow_up_required, follow_up_date) VALUES
(1, 'Seasonal allergies', 'Prescribed antihistamines', 'Patient reports improved symptoms with medication', TRUE, '2023-06-15'),
(2, 'Hypertension, well-controlled', 'Continue current medication', 'Blood pressure 130/85, slight improvement from last visit', TRUE, '2023-08-15'),
(3, 'Non-cardiac chest pain, GERD', 'Prescribed proton pump inhibitor', 'ECG normal, likely acid reflux causing symptoms', TRUE, '2023-06-15'),
(4, 'Contact dermatitis', 'Prescribed topical corticosteroid', 'Advised to avoid identified allergen', TRUE, '2023-06-17'),
(5, 'Patellar tendonitis', 'Prescribed NSAID and physical therapy', 'Recommended rest and ice application', TRUE, '2023-06-16'),
(6, 'Healthy child, normal development', 'Routine vaccinations administered', 'Growth parameters within normal limits', TRUE, '2023-11-17');

-- Insert Prescriptions data
INSERT INTO Prescriptions (record_id, medication_name, dosage, frequency, duration, notes) VALUES
(1, 'Cetirizine', '10mg', 'Once daily', '30 days', 'Take in the morning'),
(2, 'Lisinopril', '20mg', 'Once daily', '90 days', 'Take with food'),
(3, 'Omeprazole', '40mg', 'Once daily', '30 days', 'Take before breakfast'),
(4, 'Hydrocortisone cream', '1%', 'Apply twice daily', '14 days', 'Apply thin layer to affected areas'),
(5, 'Ibuprofen', '600mg', 'Three times daily', '10 days', 'Take with food');

-- Insert Payments data
INSERT INTO Payments (appointment_id, amount, payment_date, payment_method, status, transaction_id, insurance_claim_id) VALUES
(1, 20.00, '2023-05-15 09:45:00', 'Credit Card', 'Completed', 'TXN-123456', 'CLM-789012'),
(2, 20.00, '2023-05-15 10:45:00', 'Insurance', 'Completed', NULL, 'CLM-789013'),
(3, 30.00, '2023-05-15 12:15:00', 'Credit Card', 'Completed', 'TXN-123457', 'CLM-789014'),
(4, 25.00, '2023-05-16 10:30:00', 'Debit Card', 'Completed', 'TXN-123458', 'CLM-789015'),
(5, 30.00, '2023-05-16 12:00:00', 'Cash', 'Completed', NULL, 'CLM-789016'),
(6, 25.00, '2023-05-17 11:00:00', 'Insurance', 'Completed', NULL, 'CLM-789017');

-- Sample Queries for Key Operations

-- 1. Find all appointments for a specific doctor on a given date
SELECT a.appointment_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name, 
       s.service_name, a.start_time, a.end_time, a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Services s ON a.service_id = s.service_id
WHERE a.doctor_id = 1 AND a.appointment_date = '2023-05-15'
ORDER BY a.start_time;

-- 2. List all doctors with their specialties
SELECT CONCAT(s.first_name, ' ', s.last_name) AS doctor_name, 
       GROUP_CONCAT(sp.specialty_name SEPARATOR ', ') AS specialties
FROM Doctors d
JOIN Staff s ON d.staff_id = s.staff_id
JOIN DoctorSpecialties ds ON d.doctor_id = ds.doctor_id
JOIN Specialties sp ON ds.specialty_id = sp.specialty_id
GROUP BY d.doctor_id;

-- 3. Calculate clinic revenue by department for a specific month
SELECT d.department_name, SUM(p.amount) AS total_revenue
FROM Payments p
JOIN Appointments a ON p.appointment_id = a.appointment_id
JOIN Doctors doc ON a.doctor_id = doc.doctor_id
JOIN Staff s ON doc.staff_id = s.staff_id
JOIN Departments d ON s.department_id = d.department_id
WHERE MONTH(a.appointment_date) = 5 AND YEAR(a.appointment_date) = 2023
GROUP BY d.department_id
ORDER BY total_revenue DESC;

-- 6. Find patients who need follow-up appointments
SELECT CONCAT(p.first_name, ' ', p.last_name) AS patient_name, p.phone, 
       mr.follow_up_date, mr.diagnosis
FROM MedicalRecords mr
JOIN Appointments a ON mr.appointment_id = a.appointment_id
JOIN Patients p ON a.patient_id = p.patient_id
WHERE mr.follow_up_required = TRUE 
  AND mr.follow_up_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
  AND NOT EXISTS (
      SELECT 1 FROM Appointments a2 
      WHERE a2.patient_id = p.patient_id 
        AND a2.appointment_date >= CURDATE()
        AND a2.status IN ('Scheduled', 'Confirmed')
  )
ORDER BY mr.follow_up_date;

-- 4. Get doctor's schedule for the day
SELECT a.start_time, a.end_time, s.service_name, 
       CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
       a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Services s ON a.service_id = s.service_id
WHERE a.doctor_id = 1 AND a.appointment_date = CURDATE()
ORDER BY a.start_time;

-- 5. List services with their prices at a specific clinic
SELECT s.service_name, s.duration_minutes, sp.price
FROM Services s
JOIN ServicePrices sp ON s.service_id = sp.service_id
WHERE sp.clinic_id = 1
ORDER BY s.service_name;