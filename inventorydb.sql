
-- ============================================
-- DROP TABLES (clean rebuild)
-- ============================================
DROP TABLE IF EXISTS items_order;
DROP TABLE IF EXISTS order_receipts;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS admin;
DROP TABLE IF EXISTS users;

-- ============================================
-- CREATE TABLES (with all updates)
-- ============================================

-- USERS
CREATE TABLE users (
    user_id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    PRIMARY KEY (user_id)
);

-- ADMIN
CREATE TABLE admin (
    id BIGINT NOT NULL AUTO_INCREMENT,
    admin_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

-- ORDERS
CREATE TABLE orders (
    order_id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending',
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    PRIMARY KEY (order_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- CATEGORIES
CREATE TABLE categories (
    id BIGINT NOT NULL AUTO_INCREMENT,
    description VARCHAR(255),
    category_name VARCHAR(255),
    category_type VARCHAR(100),
    PRIMARY KEY (id)
);

-- ITEMS
CREATE TABLE items (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    items_quantity INT NOT NULL,
    admin_id BIGINT NOT NULL,
    price DECIMAL(10,2) DEFAULT 0.00,
    description VARCHAR(255),
	category_id BIGINT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (admin_id) REFERENCES admin(id)
);


-- ITEMS_ORDER (junction table)
CREATE TABLE items_order (
    item_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    PRIMARY KEY (item_id, order_id),
    FOREIGN KEY (item_id) REFERENCES items(id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ORDER RECEIPTS
CREATE TABLE order_receipts (
    id BIGINT NOT NULL AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    new_column BIGINT,
    user_id BIGINT NOT NULL,
    payment_method VARCHAR(50),
    receipt_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

ALTER TABLE items_order
DROP FOREIGN KEY items_order_ibfk_1;

ALTER TABLE items_order
ADD CONSTRAINT fk_items_order_items
FOREIGN KEY (item_id) REFERENCES items(id)
ON DELETE CASCADE;

-- ============================================
-- INSERT STATEMENTS (updated with new attributes)
-- ============================================

-- Admins
INSERT INTO admin (admin_name)
VALUES ('Super Admin');

-- Users
INSERT INTO users (name, email)
VALUES 
('John Doe', 'john@example.com'),
('Mary Jane', 'mary@example.com');

-- Orders
INSERT INTO orders (user_id, order_date, status, total_amount)
VALUES
(1, NOW(), 'completed', 1500.00),
(2, NOW(), 'processing', 320.50);


-- Categories
INSERT INTO categories (id, category_name, category_type, description)
VALUES
(1, 'Computer Accessories', 'Electronics', 'Accessories for laptops and PCs'),
(2, 'Peripherals', 'Electronics', 'General computer peripherals'),
(3, 'Keyboards', 'Electronics', 'Keyboard devices'),
(4, 'Displays', 'Electronics', 'Display devices including monitors');

-- Items
INSERT INTO items (id ,name, items_quantity, admin_id, price, description, category_id)
VALUES
(1, 'Laptop', 10, 1, 1200.00, 'High-performance laptop', 2),
(2, 'Mouse', 50, 1, 15.99, 'Wireless mouse', 2),
(3, 'Keyboard', 30, 1, 45.99, 'Mechanical RGB keyboard', 3),
(4, 'Monitor', 15, 1, 220.00, '24-inch IPS display', 4);

-- Items_Order (junction)
INSERT INTO items_order (item_id, order_id)
VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2);

-- Order Receipts
INSERT INTO order_receipts (order_id, new_column, user_id, payment_method)
VALUES
(1, 900, 1, 'Credit Card'),
(2, 1200, 2, 'Bank Transfer');

-- ============================================
-- SELECT (SHOW) COMMANDS


-- Show orders with details
SELECT order_id, user_id, order_date, status, total_amount
FROM orders;

-- Show items with price + description
SELECT id, name, price, description, items_quantity
FROM items;

-- Show categories
SELECT id, category_name, category_type, description
FROM categories;

-- Show receipts
SELECT id, order_id, user_id, payment_method, receipt_date
FROM order_receipts;

-- ============================================
-- UPDATE COMMANDS
-- ============================================

-- Update user
UPDATE users
SET name = 'John Updated'
WHERE user_id = 1;

-- Update category
UPDATE categories
SET description = 'Updated category description'
WHERE id = 1;

-- Update item
UPDATE items
SET category_id = 1
WHERE id = 1;



-- Update order
UPDATE orders
SET status = 'shipped'
WHERE order_id = 2;

-- Update receipt
UPDATE order_receipts
SET payment_method = 'Debit Card'
WHERE id = 1;

-- ============================================
-- DELETE COMMANDS
-- ============================================

-- Delete order + junction entries
DELETE FROM items_order WHERE order_id = 1;
DELETE FROM order_receipts WHERE order_id = 1;
DELETE FROM orders WHERE order_id = 1;

-- Delete item + category 
DELETE i
FROM items i
JOIN categories c ON i.category_id = c.id
WHERE i.id = 3;

DELETE FROM categories
WHERE id = 3;

-- Delete user + receipts
DELETE FROM order_receipts WHERE user_id = 1;
DELETE FROM users WHERE user_id = 1;

-- ============================================
-- JOIN QUERIES
-- ============================================

-- Users + Orders + Receipts
SELECT u.name, o.order_id, o.status, o.total_amount,
       r.payment_method, r.receipt_date
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_receipts r ON o.order_id = r.order_id;

-- Orders + Items
SELECT o.order_id, i.name AS item_name, i.price, o.total_amount
FROM orders o
JOIN items_order io ON o.order_id = io.order_id
JOIN items i ON io.item_id = i.id;

-- Items + Categories + Admin
SELECT 
    i.name AS item_name, 
    i.price, 
    c.category_name, 
    c.category_type, 
    a.admin_name
FROM items i
JOIN categories c ON i.category_id = c.id
JOIN admin a ON i.admin_id = a.id;

-- Full chain: User → Order → Items → Categories
SELECT 
    u.name AS user_name,
    o.order_id,
    i.name AS item_name,
    c.category_name,
    c.category_type
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN items_order io ON o.order_id = io.order_id
JOIN items i ON io.item_id = i.id
JOIN categories c ON i.category_id = c.id;


-- Show all tables
SHOW TABLES;

-- Show attributes of each table
DESCRIBE users;
DESCRIBE admin;
DESCRIBE orders;
DESCRIBE items;
DESCRIBE categories;
DESCRIBE items_order;
DESCRIBE order_receipts;

select * from categories;

select * from orders;

select * from items;

select * from items_order;

select * from order_receipts;