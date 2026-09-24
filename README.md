# Blood Bank Network — DBMS Case Study

A comprehensive Database Management System (DBMS) project modeling a multi-city blood bank network. This project features a normalized PostgreSQL relational schema, realistic Indian demographic seed data, 20 business analytical SQL queries, ACID transaction workflows, concurrency and transaction isolation demonstrations, and an interactive full-stack web dashboard.

---

## 👥 Team Members & Query Assignments

| Member | Queries Written | Assigned Files & Responsibilities |
| :--- | :--- | :--- |
| **Pratik Swain** | Q1–Q5 | `schema.sql`, `seed.sql` (Database Schema & Seed Data) |
| **Mahek Yadav** | Q6–Q10 | `README.md` (ER Model & Design Decisions) |
| **Pranav Nair** | Q11–Q15 | `transactions.sql` (Transactions & Concurrency) |
| **Dhruv Chavda** | Q16–Q20 | `index.js`, `queryData.js`, `public/` (Web App & API) |

---

## 📁 Files

| File | Description |
| :--- | :--- |
| `schema.sql` | DDL script containing `CREATE DATABASE`, 6 tables, primary/foreign keys, and `CHECK` constraints. |
| `seed.sql` | DML script inserting realistic Indian demographic sample data across all 6 tables. |
| `queries.sql` | All 20 SQL business queries organized from basic filtering to advanced subqueries. |
| `transactions.sql` | Multi-part transaction demo: ACID issuance, concurrency lock blocking, and PostgreSQL isolation levels. |
| `index.js` | Express backend server, PostgreSQL pool connection, PG type parsers, and REST endpoints. |
| `queryData.js` | JavaScript registry exporting the 20 pre-formulated queries and questions for the frontend. |
| `public/index.html` | Interactive web dashboard with KPI cards, query explorer sidebar, SQL viewer, and results table. |
| `public/style.css` | Custom modern dark-theme styles, typography, badges, and responsive grid layout. |
| `public/script.js` | Frontend client script: live SQL execution, statistics fetching, SQL syntax highlighting, and table rendering. |
| `README.md` | Project documentation, ER model, design decisions, query catalog, and execution instructions. |

---

## 📐 ER Model — Entities & Relationships

### Entities & Attributes (from `schema.sql`)

| Entity | Attributes & Constraints | Description |
| :--- | :--- | :--- |
| **`donor`** | `donor_id` (PK, Serial)<br>`first_name` VARCHAR(50), NOT NULL<br>`last_name` VARCHAR(50), NOT NULL<br>`blood_group` VARCHAR(5), NOT NULL, CHECK in ('A+','A-','B+','B-','AB+','AB-','O+','O-')<br>`gender` CHAR(1), NOT NULL, CHECK in ('M','F','O')<br>`dob` DATE, NOT NULL<br>`phone` VARCHAR(15), NOT NULL, UNIQUE<br>`email` VARCHAR(100), UNIQUE<br>`city` VARCHAR(50), NOT NULL | Stores registered blood donors and their contact/demographic details. |
| **`blood_bank`** | `bank_id` (PK, Serial)<br>`bank_name` VARCHAR(100), NOT NULL<br>`city` VARCHAR(50), NOT NULL<br>`phone` VARCHAR(15), NOT NULL, UNIQUE | Stores licensed blood banks operating across various cities. |
| **`donation`** | `donation_id` (PK, Serial)<br>`donor_id` INT, FK → `donor(donor_id)`<br>`bank_id` INT, FK → `blood_bank(bank_id)`<br>`donation_date` DATE, NOT NULL, DEFAULT CURRENT_DATE | Records donation events linking a donor to a specific blood bank. |
| **`hospital`** | `hospital_id` (PK, Serial)<br>`hospital_name` VARCHAR(100), NOT NULL<br>`city` VARCHAR(50), NOT NULL<br>`phone` VARCHAR(15), NOT NULL, UNIQUE | Partner hospitals that submit requisitions and receive units. |
| **`blood_unit`** | `unit_id` (PK, Serial)<br>`donation_id` INT, FK → `donation(donation_id)`<br>`blood_group` VARCHAR(5), NOT NULL, CHECK in ('A+','A-','B+','B-','AB+','AB-','O+','O-')<br>`volume_ml` INT, NOT NULL, CHECK (volume_ml > 0)<br>`status` VARCHAR(10), NOT NULL, DEFAULT 'available', CHECK in ('available','reserved','issued','expired')<br>`bank_id` INT, FK → `blood_bank(bank_id)`<br>`issued_to_hospital` INT, NULLABLE, FK → `hospital(hospital_id)` | Individual component units produced from donations with custody and status tracking. |
| **`hospital_request`** | `request_id` (PK, Serial)<br>`hospital_id` INT, FK → `hospital(hospital_id)`<br>`blood_group` VARCHAR(5), NOT NULL, CHECK in ('A+','A-','B+','B-','AB+','AB-','O+','O-')<br>`units_requested` INT, NOT NULL, CHECK (units_requested > 0)<br>`request_date` DATE, NOT NULL, DEFAULT CURRENT_DATE<br>`status` VARCHAR(10), NOT NULL, DEFAULT 'pending', CHECK in ('pending','fulfilled','partial') | Demands raised by partner hospitals for blood units. |

### Relationships & Cardinalities

```
[donor] 1 ──────────< makes >────────── N [donation]
[blood_bank] 1 ─────< receives >─────── N [donation]
[donation] 1 ───────< produces >─────── N [blood_unit]
[blood_bank] 1 ─────< holds >────────── N [blood_unit]
[hospital] 1 ───────< raises >───────── N [hospital_request]
[hospital] 1 ───────< receives >─────── N [blood_unit] (issued)
```

| Relationship | Cardinality | Meaning |
| :--- | :---: | :--- |
| **Donor → Donation** | 1 : N | One donor can make many donations over time. |
| **Blood Bank → Donation** | 1 : N | One blood bank can host and record many donations. |
| **Donation → Blood Unit** | 1 : N | One donation produces one or more separated units (RBC, plasma, platelets). |
| **Blood Bank → Blood Unit** | 1 : N | One blood bank stores and manages many blood units in stock. |
| **Hospital → Hospital Request** | 1 : N | One hospital can place multiple blood requisitions. |
| **Hospital → Blood Unit** | 1 : N | One hospital can receive multiple issued blood units. |
| **Blood Unit → Hospital** | N : 0..1 | Each unit can be issued to at most one hospital (or remains unissued in stock). |

---

## 📊 Dataset Summary (from `seed.sql`)

The seed file populates realistic, mutually consistent sample data across all 6 tables:

- **20 Donors**: Distributed across Indian metro cities (Mumbai, Delhi, Pune, Bangalore, Ahmedabad, Hyderabad, Kolkata, Chennai).
- **6 Blood Banks**: Major medical centers (e.g., Red Cross Central, LifeLine Blood Centre, Delhi Voluntary Blood Bank).
- **25 Donations**: Complete records linking donors and blood banks across dates.
- **6 Partner Hospitals**: Tier-1 hospitals (KEM Hospital, Lilavati Hospital, AIIMS Delhi, Fortis Healthcare, Ruby Hall Clinic, Manipal Hospital).
- **30 Blood Units**: Diverse blood groups (`O+`, `A+`, `B+`, `AB+`, `O-`, `A-`, `B-`, `AB-`) with volumes from 300 ml to 450 ml and statuses (`available`, `reserved`, `issued`, `expired`).
- **10 Hospital Requests**: Requisitions spanning `pending`, `fulfilled`, and `partial` statuses.

---

## 🔍 The 20 Business Queries (from `queries.sql`)

The project implements 20 business queries designed to test SQL capabilities across all difficulty tiers:

| # | Question / Requirement | Primary SQL Concepts | Assigned Member |
| :-: | :--- | :--- | :--- |
| **Q1** | List all donors sorted by city (name, blood group, contact) | `ORDER BY city, last_name` | Pratik Swain |
| **Q2** | List every blood unit whose volume lies between 300 and 450 ml | `BETWEEN ... AND ...` | Pratik Swain |
| **Q3** | Find all donors whose name begins with 'R' | `LIKE 'R%'` (pattern matching) | Pratik Swain |
| **Q4** | List the distinct blood groups currently held in stock | `DISTINCT`, `WHERE status = 'available'` | Pratik Swain |
| **Q5** | Top 5 blood banks holding the most available units | `JOIN`, `COUNT()`, `GROUP BY`, `ORDER BY DESC LIMIT 5` | Pratik Swain |
| **Q6** | Count available units for each blood group | `COUNT(*)`, `GROUP BY blood_group` | Mahek Yadav |
| **Q7** | Total volume collected by each blood bank | `SUM(volume_ml)`, `JOIN`, `GROUP BY` | Mahek Yadav |
| **Q8** | Average number of units produced per donation, for each blood bank | Nested `FROM` subquery, `COUNT()`, `AVG()` | Mahek Yadav |
| **Q9** | Highest and lowest unit volume for each blood group | `MAX(volume_ml)`, `MIN(volume_ml)`, `GROUP BY` | Mahek Yadav |
| **Q10** | Blood groups whose available unit count has fallen below 10 | `GROUP BY`, `HAVING COUNT(*) < 10` | Mahek Yadav |
| **Q11** | Full traceability: donor → donation → unit → bank → hospital | 5-table `JOIN` / `LEFT JOIN` supply chain traversal | Pranav Nair |
| **Q12** | Donors who have never made a donation | `LEFT JOIN ... WHERE donation_id IS NULL` (anti-join) | Pranav Nair |
| **Q13** | Unfulfilled hospital requests, sorted by units requested | `JOIN`, `WHERE status = 'pending'`, `ORDER BY DESC` | Pranav Nair |
| **Q14** | Self-join: pairs of donors from the same city with the same blood group | Self-join (`d1 JOIN d2 ON city AND blood_group AND d1.id < d2.id`) | Pranav Nair |
| **Q15** | For each hospital: total units issued and distinct blood groups received | `JOIN`, `COUNT(unit_id)`, `COUNT(DISTINCT blood_group)` | Pranav Nair |
| **Q16** | Hospitals whose total requested units exceed the average across all hospitals | Subquery in `HAVING` with `AVG()` over grouped sums | Dhruv Chavda |
| **Q17** | Blood banks holding more units of a blood group than the average for that group | Correlated subquery in `HAVING` with outer reference | Dhruv Chavda |
| **Q18** | Donors who donated at any bank in a given list of cities (using IN) | `JOIN`, `WHERE bb.city IN ('Mumbai', 'Delhi', 'Pune')` | Dhruv Chavda |
| **Q19** | Blood banks that have never issued a single unit (using NOT EXISTS) | `WHERE NOT EXISTS (SELECT 1 ... WHERE status = 'issued')` | Dhruv Chavda |
| **Q20** | Donors whose donation count is greater than every donor from Delhi (using ALL) | `HAVING COUNT(...) > ALL (SELECT COUNT(...) WHERE city = 'Delhi')` | Dhruv Chavda |

---

## ⚡ Transactions & Concurrency (from `transactions.sql`)

The `transactions.sql` script is structured into 6 demonstration parts:

### Part 1: ACID Transaction (BEGIN, COMMIT, ROLLBACK)
- **Business Scenario**: Fulfilling hospital request #1 by issuing two available `O+` units (`unit_id` 1 and 3) to KEM Hospital (`hospital_id = 1`).
- **Steps**:
  1. `UPDATE blood_unit SET status = 'issued', issued_to_hospital = 1 WHERE unit_id = 1 AND status = 'available';`
  2. `UPDATE blood_unit SET status = 'issued', issued_to_hospital = 1 WHERE unit_id = 3 AND status = 'available';`
  3. `UPDATE hospital_request SET status = 'fulfilled' WHERE request_id = 1;`
  4. `COMMIT;` (or `ROLLBACK;` if verification fails).

### Part 2: Concurrency Demonstration (Row-Level Locking)
- **Session 1** (Terminal 1): Starts a transaction and locks a row:
  ```sql
  BEGIN;
  UPDATE blood_unit SET status = 'reserved' WHERE unit_id = 5;
  -- Keep open without committing
  ```
- **Session 2** (Terminal 2): Attempts to update the exact same row:
  ```sql
  BEGIN;
  UPDATE blood_unit SET status = 'issued', issued_to_hospital = 2 WHERE unit_id = 5;
  -- BLOCKS until Session 1 finishes!
  ```
- **Session 1**: Executes `COMMIT;` → Session 2 immediately unblocks and executes its update.

### Part 4: Isolation Level — READ COMMITTED
Demonstrates PostgreSQL's default isolation level:
- Session 1 reads `status` of unit 5 (`available`).
- Session 2 updates unit 5 to `'reserved'` and commits.
- Session 1 reads unit 5 again within the same transaction and sees the updated value (`reserved`), demonstrating a **Non-Repeatable Read**.

### Part 5: Isolation Level — REPEATABLE READ
Demonstrates Snapshot Isolation:
- Session 1 sets isolation level to `REPEATABLE READ` and reads unit 5.
- Session 2 updates unit 5 to `'reserved'` and commits.
- Session 1 reads unit 5 again: it still sees `available` from its transaction snapshot, preventing non-repeatable reads.

### Part 6: Isolation Level — SERIALIZABLE
Demonstrates strict serializability:
- When concurrent transactions attempt conflicting updates on overlapping data sets, PostgreSQL detects the serialization anomaly and throws:
  `ERROR: could not serialize access due to concurrent update`
- The aborted transaction must be rolled back and retried.

### Part 7: Final State Verification
Queries `blood_unit` to inspect final statuses and hospital assignments after all test runs.

---

## 🎯 Design Decisions

1. **Why a separate `blood_unit` table?**
   A single donation can be separated into multiple components (RBCs, plasma, platelets). Each unit has its own volume and status, and can be independently issued to a hospital. This satisfies real-world blood banking standards.

2. **Why `issued_to_hospital` on `blood_unit` instead of a separate junction table?**
   Each blood unit is physical and can be issued to at most one hospital. This is a 1:1 or N:1 relationship from the unit's perspective, so a nullable foreign key column (`issued_to_hospital`) is simpler, more efficient, and prevents assigning the same unit to multiple hospitals.

3. **Why `hospital_request` is separate from unit issuance?**
   A request represents hospital *demand* ("we need 5 units of O+"). Issuance is the physical *supply* action. Keeping them distinct allows tracking pending, partial, or unfulfilled requests (Query 13).

4. **Lifecycle Status Tracking:**
   - `blood_unit.status` (`available | reserved | issued | expired`) tracks the full inventory lifecycle.
   - `hospital_request.status` (`pending | fulfilled | partial`) tracks requisition completion.

5. **Data Integrity via CHECK Constraints:**
   - Validated blood groups: `('A+','A-','B+','B-','AB+','AB-','O+','O-')`.
   - Validated volume: `volume_ml > 0` and `units_requested > 0`.
   - `UNIQUE` constraints on phone and email prevent duplicate donor, hospital, and bank registrations.

6. **PostgreSQL Date Type Handling (Zero Timezone Shift):**
   - In `index.js`, `types.setTypeParser(1082, (val) => val)` is configured to keep PostgreSQL `DATE` types as pure `YYYY-MM-DD` strings, preventing unwanted UTC time shifts across local timezones (e.g., IST UTC+5:30).

---

## 💻 Full-Stack Web Explorer Application

The repository includes a web interface built with Node.js and Express to interact with the PostgreSQL database directly in a browser:

- **Interactive Query Runner**: Select and run any of the 20 queries, view the formatted SQL with syntax highlighting, and see live results.
- **Raw Table Inspector**: Inspect all 6 tables with limit pagination and formatted pills for blood groups and statuses.
- **Live KPI Counters**: Real-time counter metrics for Total Donors, Blood Units, Hospitals, and Hospital Requests via `/api/stats`.
- **Clean Date Formatting**: Clean `YYYY-MM-DD` presentation for donor birth dates, donation dates, and request dates.

---

## 🚀 Setup & Execution Guide

### 1. Prerequisites
- **PostgreSQL** installed and running on `localhost:5432`
- **Node.js** (v18+ recommended) & **npm**

### 2. Database Setup (CLI)
```bash
# Connect to PostgreSQL
psql -U postgres

# Create database and connect
CREATE DATABASE BloodBankNetwork;
\c bloodbanknetwork

# Execute SQL files in order:
\i schema.sql
\i seed.sql
\i queries.sql
\i transactions.sql
```

### 3. Web Application Setup
```bash
# Install dependencies
npm install

# Start the application
npm start
# (or: node index.js)
```

Open **`http://localhost:3000`** in your browser to access the explorer.
