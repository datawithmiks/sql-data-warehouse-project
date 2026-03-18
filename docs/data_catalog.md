# **Data Dictionary For Gold Layer**

## Overview

##### The Gold Layer is the business-level data presentation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics.
---
#### 1. gold.dim_customers
##### **Purpose:** Store customer details enriched with demographic and geographic data.

| Column Name   | Data Type   | Description |
| ----          |----         |----         |
|customer_key   | INT         | Surrogate key uniquely identifying each customer record in dimension table. |
|customer_id    | INT         | Unique numerical identifier assigned to each other.                         |
|customer_number| NVARCHAR(50)| Alphanumeric identifier representing the customer, used for tracking and referencing.|
|first_name     | NVARCHAR(50)| The customer's first name, as recorded in the system. |
|last_name      | NVARCHAR(50)| The customer's last name, as recorded in the system.| 
|country        | NVARCHAR(50)| The country of residence or the customer (e.g 'Austrailia') |
|marital_status | NVARCHAR(50)| The marital status of the customer (e.g 'Single', 'Married') |
|gender         | NVARCHAR(50)| The gender of customer (e.g 'Male', 'Female', 'n/a') |
|birth_date     | DATE        | The date of birth of the customer, formatted as YYYY-MM-DD (e.g 2026-03-18) |
|create_date    | DATE        | The date and time when the customer record was created in the system.
---
#### 2. gold.dim_products
##### **Purpose:** Provide information about the products and their attributes.

| Column Name         | Data Type   | Description |
| ----                |----         |----         |
|product_key          | INT         | Surrogate key uniquely identifying each product record in the product dimension table. |
|product_id           | INT         | Unique numerical identifier assigned to product for internal tracking and referencing. |
|product_number       | NVARCHAR(50)| A structured alphanumeric identifier representing the product, often used for categorization or inventory.|
|product_name         | NVARCHAR(50)| Descriptive name of the product, including key details such as type, color, and size. |
|category_id          | NVARCHAR(50)| A unique identifier for the product's category, linking to its high-level classification.| 
|category             | NVARCHAR(50)| The broader classification of the product (e.g Bikes, Components) to group related items.|
|subcategory          | NVARCHAR(50)| A more detailed classification of the product within the category, such as product type. |
|maintenance_required | NVARCHAR(50)| Indicates the product requires maintenance. (e.g 'Yes', 'No') |
|cost                 | INT         | The cost or base price of the product, measured in monetary units. |
|product_line         |NVARCHAR(50) | The specific product line or series which the product belongs. (e.g 'Road', 'Mountain','n/a') |
|start_date           | DATE        | The date when the product became available for sale or use, formatted as YYYY-MM-DD .(e.g 2026-03-18) |
---
#### 3. gold.fact_sales
##### **Purpose:** Stores transactional sales data for analytical purposes.

| Column Name         | Data Type   | Description |
| ----                |----         |----         |
|order_number         | NVARCHAR(50)| A unique alphanumeric identifier for each sales order. (e.g 'SO43697')|
|product_key          | INT         | Surrogate key linking the order to the product dimension table. |
|customer_key         | INT         | Surrogate key linking the order to the customer dimension table.  |
|order_date           | DATE        | The date when the order was placed, formatted as YYYY-MM-DD. (e.g 2026-03-18) |
|shipping_date        | DATE        | The date when the order was shipped to the customer, formatted as YYYY-MM-DD. (e.g 2026-03-18) |
|due_date             | DATE        | The date when the order was payment was due, formatted as YYYY-MM-DD. (e.g 2026-03-18) |
|sales_amount         | INT         | The total monetary value of the sale for the line item, in whole currency units. (e.g, 25) |
|quantity             | INT         | The number of units of the product ordered for the line item. (e.g, 1) |
|price                | INT         | The price per unit of the product for the line item, in whole currency units. (e.g, 25)|
