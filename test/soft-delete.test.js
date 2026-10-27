const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.join(__dirname, "..");
const schema = fs.readFileSync(path.join(root, "database", "schema.sql"), "utf8");
const admin = fs.readFileSync(path.join(root, "server", "controllers", "adminController.js"), "utf8");
const auth = fs.readFileSync(path.join(root, "server", "controllers", "authController.js"), "utf8");
const order = fs.readFileSync(path.join(root, "server", "controllers", "orderController.js"), "utf8");

test("business tables include soft-delete metadata", () => {
  for (const table of ["users", "categories", "products", "therapists", "coupons", "orders", "service_reviews", "announcements", "newsletter_subscribers"]) {
    const definition = schema.match(new RegExp(`CREATE TABLE IF NOT EXISTS ${table} \\(([\\s\\S]*?)\\n\\) ENGINE`));
    assert.ok(definition, `${table} must exist`);
    assert.match(definition[1], /deleted_at DATETIME NULL/);
    assert.match(definition[1], /deleted_by INT UNSIGNED NULL/);
  }
});

test("admin deletion archives business records instead of hard deleting them", () => {
  for (const table of ["users", "categories", "products", "therapists", "coupons", "orders", "newsletter_subscribers"]) {
    assert.doesNotMatch(admin, new RegExp(`DELETE FROM ${table}\\b`, "i"));
  }
  assert.match(admin, /UPDATE orders SET deleted_at = NOW\(\), deleted_by = \?/);
  assert.match(admin, /UPDATE users SET deleted_at = NOW\(\), deleted_by = \?/);
});

test("archived accounts and orders are excluded from customer access", () => {
  assert.match(auth, /SELECT \* FROM users WHERE email = \? AND deleted_at IS NULL/);
  assert.match(order, /FROM orders WHERE deleted_at IS NULL AND \$\{whereClause\}/);
});
