CREATE DATABASE CustomersAndProduct;
SHOW DATABASES;
USE CustomersAndProduct;
select * from cleaned_superstore; 

-- 1. Total sales by customer segment
select Segment, round(SUM(Sales), 2) As Total_Sales from cleaned_superstore
group by Segment
Order by Total_Sales Desc;

-- KEY INSIGHTS:
-- 1. The top segment gives the most sales.
-- 2. Focus more on this segment to grow business.
-- 3. Segments with less sales need attention.


-- 2. Average discount applied per region
Select Region, AVG(Discount) AS Average_discount from cleaned_superstore
group by Region
Order by Average_discount Desc;

-- KEY INSIGHTS: 
-- hows the average discount given in each region.
-- Helps find regions where more discounts are applied.
-- Useful to check if high discounts are affecting profit in certain regions.


-- 3. total sales and categorize customers based on their total discount as 'High Discount',
-- 'Medium Discount', or 'Low Discount'. 

Select `Customer Name`, Region, Sum(Sales) AS Total_Sales, 
CASE
    When Avg(Discount) >= 0.2 then 'High Discount'
    When Avg(Discount) between 0.1 and 0.199 then 'Medium Discount'
    else 'Low Discount'
End As Discount_Level from cleaned_superstore
Group by `Customer Name`, Region 
Order by Total_Sales Desc
limit 0, 10; 

-- INSIGHTS: 
-- Top customers bring high sales from specific regions.
-- Most top customers get Low or Medium discounts.
-- Giving High discounts doesn't always mean more sales.

-- 4. products based on profit margin as 'High Profit', 'Moderate Profit', or 'Low/Negative Profit'. 
-- Return product name, category, sub-category, total sales, total profit, and profit category.
Select `Product Name`, Category, `Sub-Category`, Sum(Sales) As Total_Sales, 
Sum(Profit) As Total_Profit, 
Case
 when sum(Profit)/NullIF(sum(Sales), 0) >= 0.2 Then 'High Profit' # nullif for preventing 0 devision error
 When sum(Profit)/Nullif(sum(Sales), 0) between 0.05 and 0.199 then 'Moderate Profit'
 else 'Low Profit_Category' end as Profit_Category
 from cleaned_superstore
 group by `Product Name`, Category, `Sub-Category`
 Order by Total_Sales Desc
 Limit 0, 20;
 
 -- INSIGHTS: 
-- Some high-selling products still have low profit margins.
-- High profit products are not always the top in sales.
-- Category and sub-category affect profit levels a lot.

 
-- Q5. each product into 'Best Seller', 'Moderate Seller', or 'Low Seller' based on its total sales.

Select `Product Name`, Category, `Sub-Category`, 
Sum(Sales) As Total_Sales, 
Case
When sum(Sales) > 10000 then 'Best Selling'
When  Sum(Sales) between 1000 and 3000 then 'Moderate Selling'
Else 'Low Selling' end as Sales_Status
From cleaned_superstore
Group by `Product Name`, Category, `Sub-Category` 
Order by Total_Sales Desc
Limit 0, 10;

-- INSIGHTS: 
-- Best-selling products have sales above ₹10,000.
-- Most top products fall in the Best Selling group.
-- Moderate and low sellers may need better promotion or review.


-- 6. Top-Selling by Revenue
Select `Product Name`, Category, Sum(Sales) As Total_Sales 
From cleaned_superstore
Group by `Product Name`, Category
Order by Total_Sales Desc
Limit 10;

-- Shows the top 10 products with highest sales revenue.
-- These products are the main revenue drivers for the business.
-- Ideal for focus in promotions, stocking, and strategy.


-- 7. Low-selling Products 
Select `Product Name`, Category, Sum(Sales) As Total_Sales 
from cleaned_superstore
group by `Product Name`, Category
having Sum(Sales) < 500 
Order by Total_Sales
Limit 0, 10;
-- KEY INSIGHTS: 
-- Lists products with very low total sales (below ₹500).
-- These products may be less popular or poorly marketed.
-- Useful for deciding whether to improve, discount, or remove such products.


-- 8. Product Sales by Region 
Select `Product Name`, Category, Region, Sum(Sales) As Total_Sales 
from cleaned_superstore 
group by Region, `Product Name`, Category 
Order by Total_Sales Desc
Limit 0, 100;

-- KEY INSIGHTS: 
-- Shows which products sell most in each region.
-- Helps identify regional demand and preferences.
-- Useful for region-wise marketing and inventory planning.


-- 9. Best Product Per Category (Max Sales) 
Select Category, `Product Name`, Sum(Sales) As Total_Sales 
From cleaned_superstore
group by Category, `Product Name`
Having Sum(Sales) = (Select Max(Sum(Sales)) 
from cleaned_superstore As sub
Where sub.Category = cleaned_superstore.Category
group by `Product Name`
) 
Order by Category; 

-- KEY INSIGHTS: 
-- Shows the best-selling product in each category.
-- These products are the top contributors to sales within their category.
-- They are ideal for promotion and restocking to boost revenue.

-- 10. Now using CTE, Best Product Per Category (Max Sales) 
With ProductSales As (
  Select Category, `Product Name`, Sum(Sales) As Total_Sales
  From cleaned_superstore
  group by Category, `Product Name`
  ), 
  MaxSalesPerCategory AS( 
  Select Category, Max(Total_Sales) As Max_Sales
  From ProductSales
  Group by Category
  )
  Select ps.Category, ps.`Product Name`, ps.Total_Sales 
  From ProductSales ps 
  Join MaxSalesPerCategory ms 
  on ps.Category = ms.Category 
  And ps.Total_Sales = ms.Max_Sales 
  Order by ps.Category; 
  -- Limit 0, 100;
  
  -- INSIGHTS: 
  -- These are the top-selling products in each category.
-- They bring the highest sales within their category.
-- These products are key for revenue, so they should be promoted more.

  -- 11. top 2 selling products in terms of total sales per category. 
With ProductSales AS ( 
      Select 
           Category, `Product Name`, SUM(Sales) As Total_Sales
           From Cleaned_superstore
           group by category, `Product Name`
), 
TopRankedProducts As (
       Select *, 
             dense_rank() over (partition by Category Order by Total_Sales Desc) As Sales_rank
		from ProductSales
) 
Select Category, `Product Name`, Total_Sales
From TopRankedProducts
Where Sales_rank <= 2
Order by Category, Sales_rank;

-- INSIGHTS: 
-- These are the top 2 best-selling products in each category.
-- They play a big role in category-wise revenue.
-- These products can be focused for promotions and stocking.

  
-- 12. Find all products where average discount is high (=> 20%) but total profit is low (≤ 100).
With ProductsAna As ( 
    Select 
        `Product Name`, Category, Avg(Discount) As Avg_Discount, 
        Sum(Profit) As Total_Profit from cleaned_superstore 
        group by `Product Name`, Category 
	) 
    Select * from ProductsAna 
    where Avg_Discount >= 0.20 and Total_Profit <= 100 
    Order by Avg_Discount Desc; 
    
-- INSIGHTS: 
-- These products get a high discount (20% or more).
-- Even after discounts, they give very low profit (₹100 or less).
-- Such products may be hurting profit and need pricing or discount review.


-- 13. Month-over-mont sales growth per category
With MonthlySales As (
Select Category, Date_Format(`Order Date`, '%Y-%m') As Order_Month, 
Sum(Sales) As Monthly_Sales from cleaned_superstore 
group by Category, Order_Month
), 
SalesGrowth As (
    Select *, 
           Lag(Monthly_Sales) Over (Partition by Category Order by Order_Month) As Prev_month_Sales
           from MonthlySales
    ) 
    Select Category, Order_Month, Monthly_Sales, Round(((Monthly_Sales - Prev_month_Sales) / Prev_month_Sales) * 100, 2)
    As Growth_Percentage 
From SalesGrowth 
Where Prev_month_Sales is not null; 

-- INSIGHTS: 
-- Shows how sales changed each month for every category.
-- Helps find fast-growing or declining categories.
-- Useful to plan marketing and stock based on monthly trends.


-- 14. first Product purchased by each customer based on order date. 
With CustomerOrders As ( 
  Select `Customer Name`, `Order Date`, `Product Name`, 
  Row_Number() Over (Partition by `Customer Name` Order by `Order Date`) As Order_Rank
  from cleaned_superstore 
  ) 
  Select  `Customer Name`, `Order Date`, `Product Name` from CustomerOrders 
  Where Order_rank = 1 
  Order by `Customer Name`;

-- INSIGHT: 
-- It shows the first product each customer bought.
-- Useful to understand what attracts new customers.
-- These products can be used for starter offers or promotions. 


  -- 15. Second highest Sales product 
  Select Distinct Sum(Sales) As `Total_Sales` from employees
  group by `Product Name`, Category
  order by `Total_Sales` desc 
  limit 1 offset 1; 
  
-- KEY INSIGHTS: 
-- This gives the second highest selling product overall.
-- It shows which product is just below the top in performance.
-- This product has strong sales potential and can be promoted more to reach the top spot.





