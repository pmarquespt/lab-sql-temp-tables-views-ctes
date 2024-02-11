
/* 
Challenge
Creating a Customer Summary Report

In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, 
including their rental history and payment details. 
The report will be generated using a combination of views, CTEs, and temporary tables.


Step 1: Create a View
First, create a view that summarizes rental information for each customer. 
The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

Step 2: Create a Temporary Table
Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
The CTE should include the customer's name, email address, rental count, and total amount paid.

Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name,
email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

*/





/* 
Step 1: Create a View
First, create a view that summarizes rental information for each customer. 
The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
*/



USE sakila;

DROP TEMPORARY TABLE total_paid_customer;
DROP VIEW customer_rental_info;

SELECT c.customer_id, CONCAT(c.first_name, " ", c.last_name) AS Customer_name, c.email, COUNT(r.rental_id) AS Total_Rental
FROM customer c
JOIN rental r 
ON c.customer_id = r.customer_id
GROUP BY r.customer_id;

CREATE VIEW customer_rental_info AS (
									SELECT c.customer_id, CONCAT(c.first_name, " ", c.last_name) AS Customer_name, c.email, COUNT(r.rental_id) AS Total_Rental
									FROM customer c
									JOIN rental r 
									ON c.customer_id = r.customer_id
									GROUP BY r.customer_id);






/*
Step 2: Create a Temporary Table
Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and 
calculate the total amount paid by each customer.
*/



DROP TEMPORARY TABLE IF EXISTS total_paid_customer;

CREATE TEMPORARY TABLE total_paid_customer AS 
SELECT cri.customer_id, 
       SUM(p.amount) AS total_paid
FROM customer_rental_info AS cri
JOIN payment p
ON cri.customer_id = p.customer_id
GROUP BY cri.customer_id;

SELECT c.customer_id, tpc.total_paid, CONCAT(c.first_name, " ", c.last_name) as name_customer
FROM total_paid_customer AS tpc
Join customer c 
ON tpc.customer_id = c.customer_id;





/*
Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
The CTE should include the customer's name, email address, rental count, and total amount paid.
*/



WITH customer_summary AS (
							SELECT cri.customer_id, cri.customer_name, cri.email, cri.total_rental, tpc.total_paid
							FROM customer_rental_info AS cri
							JOIN total_paid_customer AS tpc
							ON cri.customer_id = tpc.customer_id
)
SELECT customer_id, customer_name, email, total_rental, total_paid
FROM customer_summary;






/*
Next, using the CTE, create the query to generate the final customer summary report, 
which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
this last column is a derived column from total_paid and rental_count.
*/

WITH customer_summary AS (
    SELECT cri.customer_id, 
           CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
           cri.email, 
           cri.total_rental AS rental_count, 
           tpc.total_paid,
           tpc.total_paid / cri.total_rental AS average_payment_per_rental
    FROM customer_rental_info cri
    JOIN total_paid_customer tpc ON cri.customer_id = tpc.customer_id
    JOIN customer c ON c.customer_id = cri.customer_id
)
SELECT customer_name, email, rental_count, total_paid, average_payment_per_rental
FROM customer_summary;