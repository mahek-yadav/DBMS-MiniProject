-- ============================================================
--  BLOOD BANK NETWORK — 20 BUSINESS QUERIES
-- ============================================================


-- Q1. List all donors sorted by city (name, blood group, contact)
SELECT first_name, last_name, blood_group, phone, city FROM donor
ORDER BY city, last_name;


-- Q2. List every blood unit whose volume lies between 300 and 450 ml
SELECT unit_id, blood_group, volume_ml, status FROM blood_unit
WHERE volume_ml BETWEEN 300 AND 450;


-- Q3. Find all donors whose name begins with 'R'
SELECT donor_id, first_name, last_name, blood_group FROM donor
WHERE first_name LIKE 'R%';


-- Q4. List the distinct blood groups currently held in stock
SELECT DISTINCT blood_group FROM blood_unit
WHERE status = 'available'
ORDER BY blood_group;


-- Q5. Top 5 blood banks holding the most available units
SELECT bb.bank_name, COUNT(bu.unit_id) AS available_units
FROM blood_bank AS bb
JOIN blood_unit AS bu ON bb.bank_id = bu.bank_id
WHERE bu.status = 'available'
GROUP BY bb.bank_name
ORDER BY available_units DESC
LIMIT 5;


-- Q6. Count available units for each blood group
SELECT blood_group, COUNT(*) AS available_units FROM blood_unit
WHERE status = 'available'
GROUP BY blood_group
ORDER BY blood_group;


-- Q7. Total volume collected by each blood bank
SELECT bb.bank_name, SUM(bu.volume_ml) AS total_volume_ml
FROM blood_bank AS bb
JOIN blood_unit AS bu ON bb.bank_id = bu.bank_id
GROUP BY bb.bank_name
ORDER BY total_volume_ml DESC;


-- Q8. Average number of units produced per donation, for each blood bank
SELECT sub.bank_name, AVG(sub.unit_count) AS avg_units_per_donation
FROM (
    SELECT bb.bank_name, bu.donation_id, COUNT(bu.unit_id) AS unit_count
    FROM blood_bank AS bb
    JOIN blood_unit AS bu ON bb.bank_id = bu.bank_id
    GROUP BY bb.bank_name, bu.donation_id
) AS sub
GROUP BY sub.bank_name;


-- Q9. Highest and lowest unit volume for each blood group
SELECT blood_group, MAX(volume_ml) AS max_volume, MIN(volume_ml) AS min_volume
FROM blood_unit
GROUP BY blood_group
ORDER BY blood_group;


-- Q10. Blood groups whose available unit count has fallen below 10
SELECT blood_group, COUNT(*) AS available_units FROM blood_unit
WHERE status = 'available'
GROUP BY blood_group
HAVING COUNT(*) < 10;


-- Q11. Full traceability: donor → donation → unit → bank → hospital
SELECT d.first_name, d.last_name, dn.donation_id, bu.unit_id,
       bb.bank_name AS issuing_bank, h.hospital_name AS receiving_hospital
FROM donor AS d
JOIN donation AS dn ON d.donor_id = dn.donor_id
JOIN blood_unit AS bu ON dn.donation_id = bu.donation_id
JOIN blood_bank AS bb ON bu.bank_id = bb.bank_id
LEFT JOIN hospital AS h ON bu.issued_to_hospital = h.hospital_id
ORDER BY d.last_name, dn.donation_id;


-- Q12. Donors who have never made a donation
SELECT d.donor_id, d.first_name, d.last_name, d.blood_group
FROM donor AS d
LEFT JOIN donation AS dn ON d.donor_id = dn.donor_id
WHERE dn.donation_id IS NULL;


-- Q13. Unfulfilled hospital requests, sorted by units requested
SELECT h.hospital_name, hr.blood_group, hr.units_requested, hr.request_date
FROM hospital_request AS hr
JOIN hospital AS h ON hr.hospital_id = h.hospital_id
WHERE hr.status = 'pending'
ORDER BY hr.units_requested DESC;


-- Q14. Self-join: pairs of donors from the same city with the same blood group
SELECT d1.first_name AS donor1_first, d1.last_name AS donor1_last,
       d2.first_name AS donor2_first, d2.last_name AS donor2_last,
       d1.city, d1.blood_group
FROM donor AS d1
JOIN donor AS d2
  ON d1.city = d2.city
 AND d1.blood_group = d2.blood_group
 AND d1.donor_id < d2.donor_id;


-- Q15. For each hospital: total units issued and distinct blood groups received
SELECT h.hospital_name, COUNT(bu.unit_id) AS total_units_issued,
       COUNT(DISTINCT bu.blood_group) AS distinct_blood_groups
FROM hospital AS h
JOIN blood_unit AS bu ON h.hospital_id = bu.issued_to_hospital
GROUP BY h.hospital_name;


-- Q16. Hospitals whose total requested units exceed the average across all hospitals
SELECT h.hospital_name, SUM(hr.units_requested) AS total_requested
FROM hospital_request AS hr
JOIN hospital AS h ON hr.hospital_id = h.hospital_id
GROUP BY h.hospital_name
HAVING SUM(hr.units_requested) > (
    SELECT AVG(hospital_total) FROM (
        SELECT SUM(units_requested) AS hospital_total
        FROM hospital_request
        GROUP BY hospital_id
    ) AS sub
);


-- Q17. Blood banks holding more units of a blood group than the average for that group
SELECT bb.bank_name, bu.blood_group, COUNT(*) AS unit_count
FROM blood_bank AS bb
JOIN blood_unit AS bu ON bb.bank_id = bu.bank_id
WHERE bu.status = 'available'
GROUP BY bb.bank_name, bu.blood_group
HAVING COUNT(*) > (
    SELECT AVG(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM blood_unit
        WHERE status = 'available' AND blood_group = bu.blood_group
        GROUP BY bank_id
    ) AS sub
);


-- Q18. Donors who donated at any bank in a given list of cities (using IN)
SELECT DISTINCT d.first_name, d.last_name, d.blood_group
FROM donor AS d
JOIN donation AS dn ON d.donor_id = dn.donor_id
JOIN blood_bank AS bb ON dn.bank_id = bb.bank_id
WHERE bb.city IN ('Mumbai', 'Delhi', 'Pune');


-- Q19. Blood banks that have never issued a single unit (using NOT EXISTS)
SELECT bb.bank_id, bb.bank_name, bb.city FROM blood_bank AS bb
WHERE NOT EXISTS (
    SELECT 1 FROM blood_unit AS bu
    WHERE bu.bank_id = bb.bank_id AND bu.status = 'issued'
);


-- Q20. Donors whose donation count is greater than every donor from Delhi (using ALL)
SELECT d.first_name, d.last_name, COUNT(dn.donation_id) AS donation_count
FROM donor AS d
JOIN donation AS dn ON d.donor_id = dn.donor_id
GROUP BY d.donor_id, d.first_name, d.last_name
HAVING COUNT(dn.donation_id) > ALL (
    SELECT COUNT(dn2.donation_id)
    FROM donor AS d2
    JOIN donation AS dn2 ON d2.donor_id = dn2.donor_id
    WHERE d2.city = 'Delhi'
    GROUP BY d2.donor_id
);
