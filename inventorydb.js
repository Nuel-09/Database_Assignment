// ===============================================
// CREATE COLLECTIONS
// ===============================================

db.createCollection("users");
db.createCollection("admin");
db.createCollection("categories");
db.createCollection("items");
db.createCollection("orders");
db.createCollection("items_order");
db.createCollection("order_receipts");

// ===============================================
// INSERT DATA
// ===============================================

// Users
db.users.insertMany([
  { _id: 1, name: "John Doe", email: "john@example.com" },
  { _id: 2, name: "Mary Jane", email: "mary@example.com" },
]);

// Admin
db.admin.insertOne({
  _id: 1,
  admin_name: "Super Admin",
});

// Categories (parent)
db.categories.insertMany([
  {
    _id: 1,
    category_name: "Computer Accessories",
    category_type: "Electronics",
    description: "Accessories for laptops and PCs",
  },
  {
    _id: 2,
    category_name: "Peripherals",
    category_type: "Electronics",
    description: "General computer peripherals",
  },
  {
    _id: 3,
    category_name: "Keyboards",
    category_type: "Electronics",
    description: "Keyboard devices",
  },
  {
    _id: 4,
    category_name: "Displays",
    category_type: "Electronics",
    description: "Display devices including monitors",
  },
]);

// Items (child)
db.items.insertMany([
  {
    _id: 1,
    name: "Laptop",
    items_quantity: 10,
    admin_id: 1,
    price: 1200.0,
    description: "High-performance laptop",
    category_id: 1,
  },
  {
    _id: 2,
    name: "Mouse",
    items_quantity: 50,
    admin_id: 1,
    price: 15.99,
    description: "Wireless mouse",
    category_id: 2,
  },
  {
    _id: 3,
    name: "Keyboard",
    items_quantity: 30,
    admin_id: 1,
    price: 45.99,
    description: "Mechanical RGB keyboard",
    category_id: 3,
  },
  {
    _id: 4,
    name: "Monitor",
    items_quantity: 15,
    admin_id: 1,
    price: 220.0,
    description: "24-inch IPS display",
    category_id: 4,
  },
]);

// Orders
db.orders.insertMany([
  {
    _id: 1,
    user_id: 1,
    order_date: new Date(),
    status: "completed",
    total_amount: 1500.0,
  },
  {
    _id: 2,
    user_id: 2,
    order_date: new Date(),
    status: "processing",
    total_amount: 320.5,
  },
]);

// Items_Order (junction)
db.items_order.insertMany([
  { item_id: 1, order_id: 1 },
  { item_id: 2, order_id: 1 },
  { item_id: 3, order_id: 2 },
  { item_id: 4, order_id: 2 },
]);

// Order Receipts
db.order_receipts.insertMany([
  {
    _id: 1,
    order_id: 1,
    user_id: 1,
    payment_method: "Credit Card",
    receipt_date: new Date(),
  },
  {
    _id: 2,
    order_id: 2,
    user_id: 2,
    payment_method: "Bank Transfer",
    receipt_date: new Date(),
  },
]);

// ===============================================
// QUERYING DATA FROM MULTIPLE ENTITIES
// ===============================================

// Items + Categories
db.items.aggregate([
  {
    $lookup: {
      from: "categories",
      localField: "category_id",
      foreignField: "_id",
      as: "category",
    },
  },
]);

// Orders + Users
db.orders.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "user_id",
      foreignField: "_id",
      as: "user",
    },
  },
]);

// ===============================================
// UPDATING RECORDS ACROSS MULTIPLE ENTITIES
// ===============================================

// Update item + category
db.items.updateOne({ _id: 1 }, { $set: { price: 1300.0 } });

db.categories.updateOne(
  { _id: 1 },
  { $set: { description: "Updated category description" } }
);

// Update order + receipt
db.orders.updateOne({ _id: 2 }, { $set: { status: "shipped" } });

db.order_receipts.updateOne(
  { order_id: 2 },
  { $set: { payment_method: "Debit Card" } }
);

// ===============================================
// DELETING RECORDS ACROSS MULTIPLE ENTITIES
// ===============================================

// Delete an item and its junction references
db.items_order.deleteMany({ item_id: 2 });
db.items.deleteOne({ _id: 2 });

// Delete a category and all items under it
db.items.deleteMany({ category_id: 3 });
db.categories.deleteOne({ _id: 3 });

// Delete a user and all related data
db.order_receipts.deleteMany({ user_id: 1 });
db.orders.deleteMany({ user_id: 1 });
db.users.deleteOne({ _id: 1 });

// ===============================================
// MULTI-ENTITY LOOKUP (JOIN EQUIVALENTS)
// ===============================================

// Full chain: User → Order → Items → Categories
db.orders.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "user_id",
      foreignField: "_id",
      as: "user",
    },
  },
  {
    $lookup: {
      from: "items_order",
      localField: "_id",
      foreignField: "order_id",
      as: "order_items",
    },
  },
  {
    $lookup: {
      from: "items",
      localField: "order_items.item_id",
      foreignField: "_id",
      as: "items",
    },
  },
  {
    $lookup: {
      from: "categories",
      localField: "items.category_id",
      foreignField: "_id",
      as: "categories",
    },
  },
]);

// Items + Admin + Categories
db.items.aggregate([
  {
    $lookup: {
      from: "admin",
      localField: "admin_id",
      foreignField: "_id",
      as: "admin",
    },
  },
  {
    $lookup: {
      from: "categories",
      localField: "category_id",
      foreignField: "_id",
      as: "category",
    },
  },
]);
