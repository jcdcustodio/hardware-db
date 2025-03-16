/* SAMPLE QUERIES */

-- Search products based on the keyword
SELECT * FROM products p
WHERE p.keywords LIKE '%grade-60%';

-- Search products from a category
SELECT * FROM products p
JOIN item_categories ic ON p.category_id = ic.id
WHERE ic.type = 'bldg_materials';

-- Search products given a brand name
SELECT * FROM products p
JOIN brands b ON p.brand_id = b.id
WHERE b.name = 'Neltex';

-- Add a new product into the database
INSERT INTO products (
	sku, 
	brand_id, 
	category_id, 
	item, 
	availability_id, 
	stock_physical, 
	stock_online,
	unit,
	unit_price,
	keywords
)
VALUES (
	'SA4021', 1, 1, 'Grade 40 16mm x 6m', 1, 100, 0, 'pcs', 450, 'steel-rebar, deformed-bars, grade-40'
);

-- Process and record a sale in the store 
BEGIN TRANSACTION;

UPDATE products
SET stock_physical = stock_physical - 25 
WHERE sku = 'SA4021';

INSERT INTO sales_logs (from_store, total_amount, payment_method, delivery)
VALUES ('physical', 0, 'Bank Transfer', 'ship');

INSERT INTO sales_logs_items (receipt_id, sku, quantity, unit, unit_price)
VALUES (1, 'SA4021', 25, 'pcs', 450);

INSERT INTO order_status (receipt_id, status)
VALUES (1, 'ongoing');

COMMIT;

-- Process and record a restocking of product in the store
BEGIN TRANSACTION;

UPDATE products
SET stock_physical = stock_physical + 25 
WHERE sku = 'SA4021';

INSERT INTO restock_logs (supplier_id, total_amount)
VALUES (2, 0);

INSERT INTO restock_logs_items (receipt_id, sku, quantity, unit, unit_price)
VALUES (1, 'SA4021', 25, 'pcs', 400);

COMMIT;