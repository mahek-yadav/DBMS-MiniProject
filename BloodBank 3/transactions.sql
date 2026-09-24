-- ============================================================
--  BLOOD BANK NETWORK — TRANSACTIONS & CONCURRENCY
-- ============================================================


-- =============================================
-- PART 1: TRANSACTION with BEGIN, COMMIT, ROLLBACK
-- =============================================
-- Scenario: A hospital request arrives for 2 units of O+ blood.
--   Step 1 — Mark two available O+ units as 'issued'.
--   Step 2 — Record which hospital receives them.
--   Step 3 — If anything fails, ROLLBACK. Otherwise COMMIT.

BEGIN;

-- Reserve unit 1 (an available O+ unit) for KEM Hospital (hospital_id = 1)
UPDATE blood_unit SET status = 'issued', issued_to_hospital = 1
WHERE unit_id = 1 AND status = 'available';

-- Reserve unit 3 (another available O+ unit) for KEM Hospital
UPDATE blood_unit SET status = 'issued', issued_to_hospital = 1
WHERE unit_id = 3 AND status = 'available';

-- Mark the hospital request as fulfilled
UPDATE hospital_request SET status = 'fulfilled'
WHERE request_id = 1;

-- If everything looks good:
COMMIT;

-- If something went wrong you would run:
-- ROLLBACK;


-- Verify after transaction:
SELECT unit_id, status, issued_to_hospital FROM blood_unit
WHERE unit_id IN (1, 3);

SELECT request_id, status FROM hospital_request
WHERE request_id = 1;


-- =============================================
-- PART 2: CONCURRENCY DEMONSTRATION
-- =============================================
-- Open TWO psql sessions (Terminal 1 and Terminal 2).
-- Run the commands in the order shown below.

-- ----- SESSION 1 (Terminal 1) -----
-- Step 1: Start a transaction and lock a row
BEGIN;
UPDATE blood_unit SET status = 'reserved'
WHERE unit_id = 5;
-- DO NOT COMMIT YET — keep the transaction open.


-- ----- SESSION 2 (Terminal 2) -----
-- Step 2: Try to update the SAME row
BEGIN;
UPDATE blood_unit SET status = 'issued', issued_to_hospital = 2
WHERE unit_id = 5;
-- This will WAIT (block) because Session 1 holds the lock.


-- ----- SESSION 1 (Terminal 1) -----
-- Step 3: Now commit Session 1
COMMIT;
-- Session 2 unblocks and its UPDATE executes.


-- ----- SESSION 2 (Terminal 2) -----
-- Step 4: Commit Session 2
COMMIT;

-- Verify the final state
SELECT unit_id, status, issued_to_hospital FROM blood_unit
WHERE unit_id = 5;
-- Expected: status = 'issued', issued_to_hospital = 2
-- (Session 2's update overwrites Session 1's because it ran second)

-- ============================================================
-- PART 4: ISOLATION LEVEL 2
--          READ COMMITTED
-- ============================================================

-- READ COMMITTED is PostgreSQL's default isolation level.
--
-- A statement can see changes committed by other transactions
-- between two SELECT statements.


-- ------------------------------------------------------------
-- SESSION 1
-- ------------------------------------------------------------

BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT unit_id,
       status
FROM blood_unit
WHERE unit_id = 5;

-- Suppose the result is:
-- 5 | available


-- ------------------------------------------------------------
-- SESSION 2
-- ------------------------------------------------------------

BEGIN;

UPDATE blood_unit
SET status = 'reserved'
WHERE unit_id = 5;

COMMIT;


-- ------------------------------------------------------------
-- BACK TO SESSION 1
-- ------------------------------------------------------------

SELECT unit_id,
       status
FROM blood_unit
WHERE unit_id = 5;

-- The second SELECT can now see:
-- 5 | reserved
--
-- Therefore:
--
-- First SELECT  -> available
-- Second SELECT -> reserved
--
-- This demonstrates a NON-REPEATABLE READ.


ROLLBACK;



-- ============================================================
-- PART 5: ISOLATION LEVEL 3
--          REPEATABLE READ
-- ============================================================

-- REPEATABLE READ provides a consistent snapshot
-- throughout the transaction.
--
-- A later SELECT does not see changes committed by
-- other transactions after the transaction's snapshot.


-- ------------------------------------------------------------
-- SESSION 1
-- ------------------------------------------------------------

BEGIN;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT unit_id,
       status
FROM blood_unit
WHERE unit_id = 5;

-- Suppose the result is:
-- 5 | available


-- ------------------------------------------------------------
-- SESSION 2
-- ------------------------------------------------------------

BEGIN;

UPDATE blood_unit
SET status = 'reserved'
WHERE unit_id = 5;

COMMIT;


-- ------------------------------------------------------------
-- BACK TO SESSION 1
-- ------------------------------------------------------------

SELECT unit_id,
       status
FROM blood_unit
WHERE unit_id = 5;

-- Session 1 continues seeing its transaction snapshot.
--
-- It can still show:
-- 5 | available
--
-- even though Session 2 has already committed:
-- 5 | reserved


ROLLBACK;



-- ============================================================
-- PART 6: ISOLATION LEVEL 4
--          SERIALIZABLE
-- ============================================================

-- SERIALIZABLE is the strongest standard isolation level.
--
-- PostgreSQL ensures that the result is consistent with
-- some serial ordering of the concurrent transactions.
--
-- If PostgreSQL detects a serialization conflict,
-- one transaction can fail with a serialization error
-- and must be retried.


-- ------------------------------------------------------------
-- SESSION 1
-- ------------------------------------------------------------

BEGIN;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT unit_id,
       status
FROM blood_unit
WHERE unit_id = 5;

-- Suppose the result is:
-- 5 | available


-- ------------------------------------------------------------
-- SESSION 2
-- ------------------------------------------------------------

BEGIN;

UPDATE blood_unit
SET status = 'reserved'
WHERE unit_id = 5;

COMMIT;


-- ------------------------------------------------------------
-- BACK TO SESSION 1
-- ------------------------------------------------------------

UPDATE blood_unit
SET status = 'issued',
    issued_to_hospital = 2
WHERE unit_id = 5;

-- Depending on the exact transaction timing,
-- PostgreSQL can detect a serialization conflict and
-- produce an error such as:
--
-- ERROR: could not serialize access due to concurrent update
--
-- If this happens, the transaction must be rolled back
-- and retried.


ROLLBACK;



-- ============================================================
-- PART 7: FINAL VERIFICATION
-- ============================================================

SELECT unit_id,
       status,
       issued_to_hospital
FROM blood_unit
WHERE unit_id = 5;