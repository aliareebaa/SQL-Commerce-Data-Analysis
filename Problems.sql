-- Calculate the average order amount for each country

SELECT country , AVG(priceEach * quantityOrdered) AS avg_order_value
FROM customers c
INNER JOIN orders o ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY country 
ORDER BY avg_order_value
;

-- Calculate the total sales amount for each product line

SELECT p.productLine, sum(priceEach * quantityOrdered) AS total_sales
FROM products p
INNER JOIN productlines pl ON p.productLine = pl.productLine
INNER JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY productLine
;

#alternate solution
SELECT productLine, sum(priceEach * quantityOrdered) AS total_sales
FROM orderdetails od
INNER JOIN products p ON od.productCode = p.productCode
GROUP BY productLine
;



-- List the top 10 best-selling products based on total quantity sold
SELECT productName, sum(quantityOrdered) AS quantity_sold
FROM orderdetails od
INNER JOIN products p ON od.productCode =p.productCode
GROUP BY productName
ORDER BY quantity_sold desc
LIMIT 10
;

-- Evaluate the sales performance of each sales rep
SELECT e.firstName, e.lastName, sum(quantityOrdered*priceEach) as order_value
FROM employees e
INNER JOIN customers c ON employeeNumber = salesRepEmployeeNumber AND e.jobTitle = 'Sales Rep'
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber

GROUP BY firstName, lastName
ORDER BY order_value desc

;


# Calculate the average number of orders placed by each customer

SELECT COUNT(o.orderNumber)/ COUNT(DISTINCT c.customerNumber)
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
;

# Calculate percentage of orders shipped on time

SELECT sum(CASE WHEN requiredDate >=  shippedDate THEN 1 ELSE 0 END) /COUNT(orderNumber)*100 as percent_ontime
FROM orders
;

-- Calculate the profit margin for each product by subtracting the cost of goods sold from sales revenue 
SELECT productName,  sum((quantityOrdered*priceEach) - (buyPrice*quantityOrdered)) AS profit_margin
FROM products p
INNER JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY productName

;


-- Segment customers based on their total purchase amount
SELECT c.*, t2.customer_segment
FROM customers c
LEFT JOIN
(SELECT *, CASE WHEN purchase_amt > 100000 THEN 'High value'
				WHEN 50000 < purchase_amt < 100000 THEN 'Medium value'
                WHEN purchase_amt < 50000 THEN 'Low value' 
ELSE 'Other' END AS customer_segment
FROM
	(SELECT DISTINCT customerNumber, sum(quantityOrdered*priceEach) AS purchase_amt
	FROM orders o
	INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
	GROUP BY  customerNumber)t1
    )t2
ON c.customerNumber = t2.customerNumber
;



-- Identify frequently co-purchased products to understand cross-selling opportunities
SELECT od.productCode, p.productName, od2.productCode, p2.productName, count(*) as purchased_together
FROM orderdetails od
INNER JOIN orderdetails od2 ON od.orderNumber = od2.orderNumber AND od.productCode <> od2.productCode
INNER JOIN products p ON od.productCode = p.productCode 
INNER JOIN products p2 ON p.productCode = p2.productCode

GROUP BY od.productCode, p.productName, od2.productCode, p2.productName
ORDER BY purchased_together desc

;


