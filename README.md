# Clinic Booking System

A comprehensive healthcare clinic management solution for scheduling appointments, managing patients, staff, medical records, and payments.

![Clinic Database ERD](https://i.imgur.com/placeholder.png)

## Project Description

The Clinic Booking System is a robust database solution designed to efficiently manage all aspects of a healthcare clinic's operations. This system provides a centralized database for multiple clinic locations, their departments, medical staff, services, and patient information, with a focus on streamlining the appointment booking process.

### Key Features

- **Multi-Clinic Management**: Support for multiple clinic locations with location-specific departments and services
- **Staff Management**: Comprehensive tracking of all clinic staff with specialized doctor profiles
- **Patient Records**: Complete patient demographics, medical history, and insurance information
- **Appointment Scheduling**: Efficient booking, tracking, and management of patient appointments
- **Medical Documentation**: Structured storage of diagnoses, treatments, and prescriptions
- **Financial Management**: Processing and monitoring of payments with multiple payment methods
- **Specialty Organization**: Classification of doctors by medical specialties with certification details
- **Service Pricing**: Location-specific pricing for different medical services

## Database Structure

The database consists of the following key tables:

- **Clinics**: Information about physical clinic locations
- **Departments**: Organizational units within clinics
- **Staff**: Base information for all employees
- **Doctors**: Extended information for medical practitioners
- **Patients**: Patient demographics and medical information
- **Specialties**: Medical specializations
- **Services**: Available medical procedures and consultations
- **ServicePrices**: Location-specific pricing for services
- **DoctorSpecialties**: Many-to-many relationship between doctors and specialties
- **Appointments**: Scheduled patient visits
- **MedicalRecords**: Clinical documentation from appointments
- **Prescriptions**: Medication records
- **Payments**: Financial transactions for appointments

## Setup Instructions

### Requirements

- MySQL Server 5.7 or higher
- Sufficient storage for patient records and medical data

### Installation Steps

1. **Clone the repository**:
   ```
   git clone https://github.com/karungar/clinic_booking.git
   cd clinic_booking
   ```

2. **Import the Database Schema**:
   ```
   mysql -u your_username -p < schema.sql
   ```
   
   Alternatively, you can use a MySQL client like MySQL Workbench to import the schema:
   - Open MySQL Workbench
   - Connect to your MySQL server
   - Go to Server > Data Import
   - Choose "Import from Self-Contained File" and select the schema.sql file
   - Create a new schema named "clinicdb" or select an existing one
   - Click "Start Import"

3. **Verify Installation**:
   ```
   mysql -u your_username -p
   USE clinicdb;
   SHOW TABLES;
   ```

### Sample Data

The schema includes sample data for:
- 2 clinic locations
- 5 departments
- 7 staff members (5 doctors and 2 nurses)
- 7 patients
- 6 medical specialties
- 10 services with pricing
- 9 appointments with corresponding medical records
- 6 payments

## Usage Examples

The database includes several example queries for common operations:

1. **Find all appointments for a specific doctor on a given date**:
   ```sql
   SELECT a.appointment_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name, 
          s.service_name, a.start_time, a.end_time, a.status
   FROM Appointments a
   JOIN Patients p ON a.patient_id = p.patient_id
   JOIN Services s ON a.service_id = s.service_id
   WHERE a.doctor_id = 1 AND a.appointment_date = '2023-05-15'
   ORDER BY a.start_time;
   ```

2. **List all doctors with their specialties**:
   ```sql
   SELECT CONCAT(s.first_name, ' ', s.last_name) AS doctor_name, 
          GROUP_CONCAT(sp.specialty_name SEPARATOR ', ') AS specialties
   FROM Doctors d
   JOIN Staff s ON d.staff_id = s.staff_id
   JOIN DoctorSpecialties ds ON d.doctor_id = ds.doctor_id
   JOIN Specialties sp ON ds.specialty_id = sp.specialty_id
   GROUP BY d.doctor_id;
   ```

3. **Calculate clinic revenue by department for a specific month**:
   ```sql
   SELECT d.department_name, SUM(p.amount) AS total_revenue
   FROM Payments p
   JOIN Appointments a ON p.appointment_id = a.appointment_id
   JOIN Doctors doc ON a.doctor_id = doc.doctor_id
   JOIN Staff s ON doc.staff_id = s.staff_id
   JOIN Departments d ON s.department_id = d.department_id
   WHERE MONTH(a.appointment_date) = 5 AND YEAR(a.appointment_date) = 2023
   GROUP BY d.department_id
   ORDER BY total_revenue DESC;
   ```

## Entity Relationship Diagram (ERD)

The ERD for this database can be found at the top of this README. It visually represents all tables and their relationships, providing a clear overview of the database structure.

## Future Enhancements

- Patient portal integration
- Electronic prescription system
- Insurance verification API
- Business intelligence and reporting
- Telemedicine appointment support
- Inventory management for clinic supplies

## Contributors

- [Sylvia Waweru]
  

## License

This project is licensed under the [MIT License](LICENSE).
