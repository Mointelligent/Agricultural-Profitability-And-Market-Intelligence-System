CREATE TABLE farmer_profile(
     farmer_id VARCHAR (5) PRIMARY KEY,
	 farmer_name VARCHAR (10),
	 region VARCHAR (10),
	 age INT,
	 gender VARCHAR (10),
	 coop_member VARCHAR (5)
);


SELECT *
FROM farmer_profile

CREATE TABLE farm_production(
    farm_id VARCHAR (10) PRIMARY KEY,
	farmer_id VARCHAR (5) REFERENCES farmer_profile(farmer_id),
	crop VARCHAR (10),
	season VARCHAR (5),
	yeild DECIMAL,
	fertilizer_used DECIMAL,
	labour_cost DECIMAL,
	region VARCHAR (10),
	fertilizer_cost DECIMAL
);


SELECT *
FROM farm_production

CREATE TABLE market_price(
    market_id VARCHAR (5) PRIMARY KEY,
	region VARCHAR (10),
	market_name VARCHAR (10),
	crop VARCHAR (10),
	market_price DECIMAL,
	date DATE
);

DROP TABLE market_price

SELECT *
FROM market_price


CREATE TABLE sales_transaction(
     sales_id VARCHAR (5) PRIMARY KEY,
	 farmer_id VARCHAR (5) REFERENCES farmer_profile(farmer_id),
	 farm_id VARCHAR (10) REFERENCES farm_production(farm_id),
	 market_id VARCHAR (10) REFERENCES market_price(market_id),
	 crop VARCHAR (10),
	 quantity_sold DECIMAL,
	 market_price DECIMAL,
	 transport_cost DECIMAL,
	 storage_cost DECIMAL,
	 loss_transit DECIMAL,
	 stored DECIMAL,
	 capacity DECIMAL,
	 sale_date DATE 
);

SELECT *
FROM sales_transaction

--crops generate the highest profit margins by region
SELECT
    fp.Region,
    st.Crop,
    SUM(st.quantity_sold * st.market_Price) AS Total_Revenue,
    SUM(st.transport_cost + st.storage_cost + fp.labour_cost + fp.fertilizer_cost) AS Total_Cost,
    (SUM(st.quantity_sold * st.market_price) - 
     SUM(st.transport_cost + st.storage_Cost + fp.labour_cost + fp.fertilizer_cost)) AS Profit,
    ROUND(
        ((SUM(st.quantity_sold * st.market_price) - 
          SUM(st.transport_cost + st.storage_cost + fp.labour_cost + fp.fertilizer_cost)) /
          SUM(st.quantity_sold * st.market_price)) * 100, 2
    ) AS profit_margin_percentage
FROM sales_transaction st
JOIN farm_production fp ON st.Farm_ID = fp.Farm_ID
GROUP BY fp.Region, st.Crop
ORDER BY Profit_Margin_Percentage DESC;


--highest profit margins by region
SELECT
    fp.Region,
    SUM(st.quantity_sold * st.market_Price) AS Total_Revenue,
    SUM(st.transport_cost + st.storage_cost + fp.labour_cost + fp.fertilizer_cost) AS Total_Cost,
    (SUM(st.quantity_sold * st.market_price) - 
     SUM(st.transport_cost + st.storage_Cost + fp.labour_cost + fp.fertilizer_cost)) AS Profit,
    ROUND(
        ((SUM(st.quantity_sold * st.market_price) - 
          SUM(st.transport_cost + st.storage_cost + fp.labour_cost + fp.fertilizer_cost)) /
          SUM(st.quantity_sold * st.market_price)) * 100, 2
    ) AS profit_margin_percentage
FROM sales_transaction st
JOIN farm_production fp ON st.Farm_ID = fp.Farm_ID
GROUP BY fp.Region
ORDER BY Profit_Margin_Percentage DESC;


--highest profit margins by crop
SELECT
    st.Crop,
    SUM(st.quantity_sold * st.market_Price) AS Total_Revenue,
    SUM(st.transport_cost + st.storage_cost + fp.labour_cost + fp.fertilizer_cost) AS Total_Cost,
    (SUM(st.quantity_sold * st.market_price) - 
     SUM(st.transport_cost + st.storage_Cost + fp.labour_cost + fp.fertilizer_cost)) AS Profit,
    ROUND(
        ((SUM(st.quantity_sold * st.market_price) - 
          SUM(st.transport_cost + st.storage_cost + fp.labour_cost + fp.fertilizer_cost)) /
          SUM(st.quantity_sold * st.market_price)) * 100, 2
    ) AS profit_margin_percentage
FROM sales_transaction st
JOIN farm_production fp ON st.Farm_ID = fp.Farm_ID
GROUP BY st.Crop
ORDER BY Profit_Margin_Percentage DESC;


--Which regions experienced the most transportation losses?
SELECT
    fp.Region,
    SUM(st.loss_transit) AS Total_Loss,
    ROUND(
        (SUM(st.loss_transit) / (SUM(st.quantity_sold) + SUM(st.loss_transit))) * 100,
        2
    ) AS Loss_Percentage
FROM sales_transaction st
JOIN farm_production fp ON st.farm_id = fp.farm_id
GROUP BY fp.Region
ORDER BY Total_loss DESC;


--What is the average logistics cost per kg sold?
SELECT
    fp.Region,
    st.Crop,
    SUM(st.Transport_Cost + st.Storage_Cost) AS Total_Logistics_Cost,
    SUM(st.Quantity_Sold) AS Total_Quantity_Sold,
    ROUND(SUM(st.Transport_Cost + st.Storage_Cost) / SUM(st.Quantity_Sold), 2) AS Logistics_Cost_per_kg
FROM sales_transaction st
JOIN farm_production fp ON st.Farm_ID = fp.Farm_ID
GROUP BY fp.Region, st.Crop
ORDER BY Logistics_Cost_per_kg DESC;

--Average logistics cost per kg sold
SELECT ROUND((SUM(transport_cost) + SUM(storage_cost) + (SELECT SUM(labour_cost) + SUM(fertilizer_cost) FROM farm_production))/ SUM(quantity_sold), 2) AS average_logistics
FROM sales_transaction

--How much revenue is lost due to spoilage or inefficient transport?
SELECT
    fp.Region,
    st.Crop,
    SUM(st.Loss_Transit * st.Market_Price) AS Lost_Revenue_Naira,
    SUM(st.Quantity_Sold * st.Market_Price) AS Actual_Revenue_Naira,
    ROUND((SUM(st.Loss_Transit * st.Market_Price) /
           (SUM(st.Quantity_Sold * st.Market_Price) + SUM(st.Loss_Transit * st.Market_Price))) * 100, 2)
           AS Revenue_Leakage_Percentage
FROM sales_transaction st
JOIN farm_production fp ON st.Farm_ID = fp.Farm_ID
GROUP BY fp.Region, st.Crop
ORDER BY Lost_Revenue_Naira DESC;


--How much revenue is lost due to spoilage or inefficient transport? (by region)
SELECT
    fp.Region,
    SUM(st.Loss_Transit * st.Market_Price) AS Lost_Revenue_Naira,
    SUM(st.Quantity_Sold * st.Market_Price) AS Actual_Revenue_Naira,
    ROUND((SUM(st.Loss_Transit * st.Market_Price) /
           (SUM(st.Quantity_Sold * st.Market_Price) + SUM(st.Loss_Transit * st.Market_Price))) * 100, 2)
           AS Revenue_Leakage_Percentage
FROM sales_transaction st
JOIN farm_production fp ON st.Farm_ID = fp.Farm_ID
GROUP BY fp.Region
ORDER BY Lost_Revenue_Naira DESC;


--How much revenue is lost due to spoilage or inefficient transport? (by crop)
SELECT
    st.Crop,
    SUM(st.Loss_Transit * st.Market_Price) AS Lost_Revenue_Naira,
    SUM(st.Quantity_Sold * st.Market_Price) AS Actual_Revenue_Naira,
    ROUND((SUM(st.Loss_Transit * st.Market_Price) /
           (SUM(st.Quantity_Sold * st.Market_Price) + SUM(st.Loss_Transit * st.Market_Price))) * 100, 2)
           AS Revenue_Leakage_Percentage
FROM sales_transaction st
JOIN farm_production fp ON st.Farm_ID = fp.Farm_ID
GROUP BY st.Crop
ORDER BY Lost_Revenue_Naira DESC;

--Which farmer groups or markets are most efficient?
SELECT
    f.Farmer_name AS Farmer_Name,
    f.Coop_Member AS Coop_Member_Status,
    fp.Region,
    SUM(st.quantity_sold * st.market_price) AS Total_Revenue,
    SUM(st.transport_cost + st.storage_cost + fp.labour_cost + fp.fertilizer_cost) AS Total_Cost,
    ROUND(
        ((SUM(st.quantity_sold * st.market_price) -
          SUM(st.transport_cost + st.storage_cost + fp.labour_cost + fp.fertilizer_cost)) /
          SUM(st.quantity_sold * st.market_price)) * 100, 2
    ) AS Efficiency_Percentage
FROM sales_transaction st
JOIN farm_production fp ON st.Farm_ID = fp.Farm_ID
JOIN farmer_profile f ON fp.Farmer_ID = f.Farmer_ID
GROUP BY f.farmer_name, f.Coop_Member, fp.Region
ORDER BY Efficiency_Percentage DESC;

