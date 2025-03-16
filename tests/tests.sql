/* Represents all the items sold by the store
CREATE TABLE IF NOT EXISTS `products` (
    `sku` TEXT NOT NULL PRIMARY KEY,
    `brand_id` INTEGER NOT NULL,
    `category_id` INTEGER NOT NULL,
    `item` TEXT NOT NULL,
    `availability_id` INTEGER NOT NULL,
    `stock_physical` NUMERIC NOT NULL DEFAULT 0,
    `stock_online` NUMERIC NOT NULL DEFAULT 0,
    `total_stock` INTEGER GENERATED ALWAYS AS (`stock_physical` + `stock_online`) STORED,
    `unit` TEXT NOT NULL,
    `unit_price` NUMERIC NOT NULL DEFAULT 0.00,
    `keywords` TEXT,
    CHECK (`stock_physical` >= 0 AND `stock_online` >= 0),
    CHECK (`unit_price` >= 0),
    CHECK (`availability_id` IN (1, 2, 3)),
    FOREIGN KEY (`brand_id`) REFERENCES `brands`(`id`),
    FOREIGN KEY (`availability_id`) REFERENCES `product_availability` (`id`),
    FOREIGN KEY (`category_id`) REFERENCES `item_categories`(`id`)
);*/

INSERT INTO brands (name)
VALUES ('No Brand'), ('Generic');

INSERT INTO suppliers (name)
VALUES 
	('SteelAsia'), 
	('Cathay Pacific Steel Corporation (CAPASCO)'), 
	('Golden Dragon Metal Products Inc.'), 
	('JEA Steel Industries, Inc.');

DROP TABLE brands;
DROP TABLE suppliers;

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
	'SA3321',
	1,
	1,
	'Grade 33 16mm x 6m',
	1,
	100,
	0,
	'pcs',
	500,
	'steel-rebar, deformed-bars, grade-33'
);

SELECT * FROM products;
