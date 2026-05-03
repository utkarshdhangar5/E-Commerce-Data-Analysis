# Olist E-Commerce Data Analysis (SQL + Power BI)

## Project Overview
This project analyzes the Brazilian Olist e-commerce dataset to uncover insights related to sales performance, customer behavior, product trends, and delivery efficiency.
The analysis was performed using **SQL Server** for data processing and **Power BI** for building an interactive, multi-page dashboard.

---
## Objective
The goal of this project is to:
* Analyze business performance across orders, revenue, and customers
* Identify top-performing products and regions
* Evaluate delivery efficiency and its impact on customer satisfaction
* Generate actionable insights for business improvement

---
## Dataset Information
* Dataset: Olist Brazilian E-Commerce
* Total Orders: ~99,441
* Total Revenue: ~15.8M

### Tables Used:
* customers
* orders
* order_items
* products
* sellers
* payments
* reviews
* geolocation
* category_translation

---
## Tools & Technologies
* **SQL Server**
  * Data cleaning and transformation
  * Joins and relationships (PK/FK)
  * Views for analysis
  * KPI calculations
* **Power BI**
  * Data modeling
  * DAX measures
  * Interactive dashboards
  * Multi-page reporting

---
## Project Workflow

### 1. Data Preparation (SQL)
* Created database and tables manually
* Imported CSV data using flat file import
* Handled null values and duplicates
* Created primary and foreign keys
* Built analytical views:
  * `clean_orders`
  * `order_value`
  * `final_orders`

---
### 2. Data Analysis (SQL)
* Calculated key KPIs:
  * Total Revenue
  * Total Orders
  * Average Order Value (AOV)
  * Delivery metrics

* Performed:
  * Customer analysis
  * Category analysis
  * Seller performance
  * Delivery vs review correlation

---
### 3. Data Visualization (Power BI)
Created a **5-page interactive dashboard**:
#### 1. Overview
* Total Revenue
* Total Orders
* AOV
* Late Delivery %
* Revenue by City

---
#### 2. Sales & Growth
* Revenue trends over time
* Order patterns
* Growth insights

---
#### 3. Product Analysis

* Revenue by category
* Top-performing product segments

---
#### 4. Customer Analysis
* Top customers
* Revenue distribution by city
* Customer behavior insights

---
#### 5. Delivery & Reviews
* Avg Delivery Time
* Late vs On-Time Delivery %
* Review Score vs Delivery Delay
* Customer satisfaction patterns

---
## Key Insights
* Revenue is driven by high order volume with relatively low AOV (~160)
* Major cities like São Paulo contribute the highest revenue
* Categories like **Health & Beauty** and **Home Products** perform best
* ~93% of deliveries are on time or early
* Early deliveries lead to higher customer ratings
* Low ratings still occur despite early delivery → product quality matters

---
## Recommendations
* Improve customer retention (loyalty programs)
* Focus on high-performing product categories
* Enhance product quality monitoring
* Reduce late deliveries further
* Expand operations in top-performing cities

---
## Conclusion
The business demonstrates strong logistics performance and a high-volume sales model. While delivery efficiency positively impacts customer satisfaction, other factors such as product quality also play a critical role. Strategic improvements in retention, product quality, and regional focus can drive further growth.

---
## Future Improvements
* Add payment method analysis
* Include seller-level performance dashboards
* Build predictive models for delivery delays
* Enhance dashboard with advanced DAX measures

---
## Connect With Me
* LinkedIn: https://www.linkedin.com/in/utkarshdhangar

⭐ If you found this project useful, feel free to star the repository!
