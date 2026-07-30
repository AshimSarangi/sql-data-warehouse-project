# Data Catalog - Gold Layer

## Overview

The Gold Layer is the business-facing representation of the data warehouse, structured as a **star schema** to support analytical and reporting use cases. It consists of **dimension tables** (descriptive attributes) and **fact tables** (measurable, transactional events).

---

## 1. gold.dim_customers

**Purpose:** Stores customer master data enriched with demographic and geographic attributes.

| Column Name      | Data Type     | Description                                                                                   |
|-------------------|--------------|-----------------------------------------------------------------------------------------------|
| customer_key       | INT          | Surrogate key uniquely identifying each customer record in the dimension table.               |
| customer_id        | INT          | Unique numerical identifier assigned to each customer (source: CRM).                          |
| customer_number    | NVARCHAR(50) | Alphanumeric identifier used to track and reference the customer (source: CRM).                |
| first_name         | NVARCHAR(50) | Customer's first name, as recorded in the source system.                                       |
| last_name          | NVARCHAR(50) | Customer's last (family) name, as recorded in the source system.                               |
| country            | NVARCHAR(50) | Country of residence for the customer (e.g., 'Australia'), sourced from ERP location data.     |
| marital_status     | NVARCHAR(50) | Marital status of the customer (e.g., 'Married', 'Single').                                    |
| gender             | NVARCHAR(50) | Gender of the customer (e.g., 'Male', 'Female', 'n/a'). CRM is treated as the source of truth; ERP gender is used only when CRM is 'n/a'. |
| birthday           | DATE         | Date of birth of the customer, sourced from ERP data.                                          |
| create_date        | DATE         | Date on which the customer record was first created in the CRM source system.                  |

---

## 2. gold.dim_products

**Purpose:** Stores product master data along with category, subcategory, and cost attributes. Only currently active products are included (historical/retired product records are filtered out).

| Column Name      | Data Type     | Description                                                                                   |
|-------------------|--------------|-----------------------------------------------------------------------------------------------|
| product_key        | INT          | Surrogate key uniquely identifying each product record in the dimension table.                |
| product_id         | INT          | Unique identifier assigned to the product in the source system (CRM).                          |
| product_number     | NVARCHAR(50) | Structured alphanumeric code representing the product, used for categorization or inventory.   |
| product_name       | NVARCHAR(50) | Descriptive name of the product, including key attributes such as type or model.               |
| category_id        | NVARCHAR(50) | Identifier linking the product to its high-level category, used to derive the `category` value.|
| category           | NVARCHAR(50) | Broad classification of the product (e.g., Bikes, Components) to group related items.          |
| subcategory        | NVARCHAR(50) | More detailed classification of the product within its category (e.g., specific product type). |
| maintenance        | NVARCHAR(50) | Indicates whether the product requires maintenance (e.g., 'Yes', 'No').                        |
| cost               | INT          | Cost or base price of the product, measured in whole currency units.                           |
| product_line       | NVARCHAR(50) | Product line or series to which the product belongs (e.g., Mountain, Road, Touring, Other Sales).|
| start_date         | DATE         | Date on which the product became available for sale or use (current/active record).            |

---

## 3. gold.fact_sales

**Purpose:** Stores transactional sales data for analytical purposes, linking to the customer and product dimensions.

| Column Name      | Data Type     | Description                                                                                   |
|-------------------|--------------|-----------------------------------------------------------------------------------------------|
| order_number       | NVARCHAR(50) | Unique alphanumeric identifier for the sales order (e.g., 'SO54496').                          |
| product_key        | INT          | Surrogate key linking the sale to the corresponding product in `gold.dim_products`.            |
| customer_key       | INT          | Surrogate key linking the sale to the corresponding customer in `gold.dim_customers`.          |
| order_date         | DATE         | Date on which the order was placed.                                                            |
| shipping_date      | DATE         | Date on which the order was shipped to the customer.                                           |
| due_date           | DATE         | Date on which payment for the order was due.                                                   |
| sales_amount       | INT          | Total monetary value of the sale line item, in whole currency units (quantity × price).        |
| quantity           | INT          | Number of units of the product ordered for the line item.                                      |
| price              | INT          | Price per unit of the product for the line item, in whole currency units.                      |

---

## Star Schema Relationships

- `gold.fact_sales.product_key` → `gold.dim_products.product_key`
- `gold.fact_sales.customer_key` → `gold.dim_customers.customer_key`

Both dimension tables use surrogate keys (`customer_key`, `product_key`) generated via `ROW_NUMBER()`, decoupling the gold layer from source-system identifiers and providing stable keys for reporting tools.
