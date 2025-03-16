/* TABLE DEFINITIONS */

-- Represents all the items sold by the store
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
);

-- Represents what platforms the items sold by the store are available
CREATE TABLE IF NOT EXISTS `product_availability` (
    `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `type` TEXT NOT NULL COLLATE NOCASE,
    CHECK (`type` IN ('physical', 'online', 'physical and online'))
);

-- Represents the brand names of the items sold by the store
CREATE TABLE IF NOT EXISTS `brands` (
    `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `name` TEXT NOT NULL UNIQUE COLLATE NOCASE DEFAULT 'No Brand'
);

-- Represents the category of the items sold by the store
CREATE TABLE IF NOT EXISTS `item_categories` (
    `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `type` TEXT NOT NULL UNIQUE COLLATE NOCASE,
    CHECK (`type` IN (
        'bldg_materials', 
        'plumbing', 
        'electrical', 
        'painting', 
        'hardware', 
        'tools'
        )
    )
);

-- Contains all records pertaining to sales
CREATE TABLE IF NOT EXISTS `sales_logs` (
    `receipt_id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `sales_datetime` NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `from_store` TEXT NOT NULL,
    `customer` TEXT DEFAULT NULL,
    `total_amount` NUMERIC NOT NULL DEFAULT 0.00,
    `payment_method` TEXT NOT NULL COLLATE NOCASE,
    `delivery` TEXT NOT NULL COLLATE NOCASE,
    CHECK (`from_store` IN ('physical', 'online')),
    CHECK (`total_amount` >= 0),
    CHECK (`payment_method` IN (
        'cash', 
        'e-wallet', 
        'bank transfer', 
        'check', 
        'credit'
        )
    ),
    CHECK (`delivery` IN ('pickup', 'ship'))
);

-- Additional information about the items involved in the sales
CREATE TABLE IF NOT EXISTS `sales_logs_items` (
    `receipt_id` INTEGER NOT NULL,
    `sku` TEXT NOT NULL,
    `quantity` NUMERIC NOT NULL, 
    `unit` TEXT NOT NULL,
    `unit_price` NUMERIC NOT NULL,
    `total` NUMERIC GENERATED ALWAYS AS (`quantity` * `unit_price`) STORED,
    CHECK (`quantity` >= 0),
    CHECK (`unit_price` >= 0 AND `total` >= 0),
    FOREIGN KEY (`receipt_id`) REFERENCES `sales_logs` (`receipt_id`)
);

-- For monitoring of orders due to sales
CREATE TABLE IF NOT EXISTS `order_status` (
    `receipt_id` INTEGER NOT NULL,
    `status` TEXT NOT NULL COLLATE NOCASE DEFAULT 'ongoing',
    CHECK (`status` IN ('ongoing', 'shipping', 'completed')),
    FOREIGN KEY (`receipt_id`) REFERENCES `sales_logs` (`receipt_id`)
);

-- Full contact list of suppliers of items
CREATE TABLE IF NOT EXISTS `suppliers` (
    `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `name` TEXT NOT NULL,
    `contact_person` TEXT DEFAULT NULL,
    `contact_number` TEXT DEFAULT NULL,
    `email` TEXT DEFAULT NULL
);

-- Contains all records pertaining to restocking of items
CREATE TABLE IF NOT EXISTS `restock_logs` (
    `receipt_id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `restock_datetime` NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `supplier_id` INTEGER NOT NULL,
    `total_amount` NUMERIC NOT NULL DEFAULT 0.00,
    CHECK (`total_amount` >= 0),
    FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
);

-- Additional information about the items involved in the restock
CREATE TABLE IF NOT EXISTS `restock_logs_items` (
    `receipt_id` INTEGER NOT NULL,
    `sku` TEXT NOT NULL,
    `quantity` NUMERIC NOT NULL, 
    `unit` TEXT NOT NULL,
    `unit_price` NUMERIC NOT NULL,
    `total` NUMERIC GENERATED ALWAYS AS (`quantity` * `unit_price`) STORED,
    CHECK (`quantity` >= 0),
    CHECK (`unit_price` >= 0 AND `total` >= 0),
    FOREIGN KEY (`receipt_id`) REFERENCES `restock_logs` (`receipt_id`)
);

/* TRIGGER FOR SALES RECORDS */

CREATE TRIGGER IF NOT EXISTS `update_sales_total_1`
AFTER INSERT ON `sales_logs_items`
FOR EACH ROW
BEGIN
    UPDATE sales_logs
    SET total_amount = (
        SELECT IFNULL(SUM(`total`), 0)
        FROM sales_logs_items
        WHERE receipt_id = NEW.receipt_id
    )
    WHERE receipt_id = NEW.receipt_id;
END;

CREATE TRIGGER IF NOT EXISTS `update_sales_total_2`
AFTER UPDATE ON `sales_logs_items`
FOR EACH ROW
BEGIN
    UPDATE sales_logs
    SET total_amount = (
        SELECT IFNULL(SUM(`total`), 0)
        FROM sales_logs_items
        WHERE receipt_id = NEW.receipt_id
    )
    WHERE receipt_id = NEW.receipt_id;
END;

CREATE TRIGGER IF NOT EXISTS `update_sales_total_3`
AFTER DELETE ON `sales_logs_items`
FOR EACH ROW
BEGIN
    UPDATE sales_logs
    SET total_amount = (
        SELECT IFNULL(SUM(total), 0)
        FROM sales_logs_items
        WHERE receipt_id = NEW.receipt_id
    )
    WHERE receipt_id = NEW.receipt_id;
END;

/* TRIGGER FOR RESTOCK RECORDS */

CREATE TRIGGER IF NOT EXISTS `update_restock_total_1`
AFTER INSERT ON `restock_logs_items`
FOR EACH ROW
BEGIN
    UPDATE restock_logs
    SET total_amount = (
        SELECT IFNULL(SUM(total), 0)
        FROM restock_logs_items
        WHERE receipt_id = NEW.receipt_id
    )
    WHERE receipt_id = NEW.receipt_id;
END;

CREATE TRIGGER IF NOT EXISTS `update_restock_total_2`
AFTER UPDATE ON `restock_logs_items`
FOR EACH ROW
BEGIN
    UPDATE restock_logs
    SET total_amount = (
        SELECT IFNULL(SUM(total), 0)
        FROM restock_logs_items
        WHERE receipt_id = NEW.receipt_id
    )
    WHERE receipt_id = NEW.receipt_id;
END;

CREATE TRIGGER IF NOT EXISTS `update_restock_total_3`
AFTER DELETE ON `restock_logs_items`
FOR EACH ROW
BEGIN
    UPDATE restock_logs
    SET total_amount = (
        SELECT IFNULL(SUM(total), 0)
        FROM restock_logs_items
        WHERE receipt_id = NEW.receipt_id
    )
    WHERE receipt_id = NEW.receipt_id;
END;

/* INDEX DEFINITIONS */

-- Create index for optimization of common queries
CREATE INDEX IF NOT EXISTS `item_search` ON `products` (`item`, `keywords`);
CREATE INDEX IF NOT EXISTS `sold_items_search` ON `sales_logs_items` (`receipt_id`, `sku`);
CREATE INDEX IF NOT EXISTS `restock_items_search` ON `restock_logs_items` (`receipt_id`, `sku`);

/* SAMPLE VIEWS */

-- View all brands in proper order
CREATE VIEW `all_brands` AS
SELECT * FROM brands
ORDER BY name;

CREATE VIEW `active_orders` AS
SELECT * FROM `sales_logs` s
JOIN `order_status` o USING(`receipt_id`)
WHERE o.status != 'completed'
ORDER BY s.sales_datetime DESC;