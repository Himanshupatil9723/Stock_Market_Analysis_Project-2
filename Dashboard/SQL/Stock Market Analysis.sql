select * from stock_market_data;

#..................................................... STOCK MARKET ANALYSIS KPI’s.............................................................#

#1 .............................................Average Daily Trading Volume#.............................................#
SELECT 
    Ticker, 
    CONCAT(ROUND(AVG(Volume) / 1000000, 2), ' M') AS AverageDailyTradingVolume
FROM 
    stock_market_data
GROUP BY 
    Ticker;
    
#2 .............................................Most Volatile Stocks.............................................#
    
SELECT Ticker, ROUND(AVG(Beta), 2) AS AvgBeta
FROM stock_market_data
WHERE Beta > 1.0
GROUP BY Ticker;

#3 .............................................Stocks with Highest Dividend and Lowest Dividend.............................................#

SELECT 
    Stock_Name,
    CASE WHEN High_Rank = 1 THEN Total_Dividend END AS Highest_Dividend,
    CASE WHEN Low_Rank = 1 THEN Total_Dividend END AS Lowest_Dividend
FROM (
    SELECT 
        Ticker AS Stock_Name,
        SUM(`Dividend Amount`) AS Total_Dividend,
        ROW_NUMBER() OVER (ORDER BY SUM(`Dividend Amount`) DESC) AS High_Rank,
        ROW_NUMBER() OVER (ORDER BY SUM(`Dividend Amount`) ASC) AS Low_Rank
    FROM 
        stock_market_data
    WHERE 
        Ticker IN ('GOOGL', 'MSFT', 'AAPL', 'FB', 'AMZN') -- Add all your desired stocks here
    GROUP BY 
        Ticker
) AS Subquery
WHERE High_Rank = 1 OR Low_Rank = 1;

#4 .............................................Highest and Lowest P/E Ratios.............................................#

SELECT 
    Ticker AS Stock_Name,
    FORMAT(MAX(`PE Ratio`), 2) AS Highest_PE_Ratio,
    FORMAT(MIN(`PE Ratio`), 2) AS Lowest_PE_Ratio
FROM 
    stock_market_data
WHERE 
    Ticker IN ('GOOGL', 'MSFT', 'AAPL', 'FB', 'AMZN') -- Add all your desired stocks here
GROUP BY 
    Ticker;

#5 .............................................Stocks with Highest Market Cap.............................................#
    
SELECT 
    Ticker AS Stock_Name,
    CONCAT(FORMAT(SUM(`Market Cap`) / 1000000000, 2), ' Billion') AS Total_Market_Cap
FROM 
    stock_market_data
WHERE 
    Ticker IN ('GOOGL', 'MSFT', 'AAPL', 'FB', 'AMZN')
GROUP BY 
    Ticker;

#6 .............................................Stocks Near 52 Week High.............................................#
    
SELECT 
    Ticker AS Stock_Name,Year,
    MAX(`52 Week High`) AS FiftyTwo_Week_High
FROM 
    stock_market_data
GROUP BY 
    Ticker,year;

#7.............................................Stocks Near 52 Week Low.............................................#
    
    SELECT 
    Ticker AS Stock_Name,year,
    MIN(`52 Week Low`) AS FiftyTwo_Week_Low
FROM 
    stock_market_data
GROUP BY 
    Ticker,year;

#8.............................................Stocks with Strong Buy Signals and stocks with Strong Selling Signal.............................................#
    
 SELECT 
    Date,
    Ticker AS Stock_Name,
    `RSI (14 days)` AS RSI,
    `MACD` AS MACD,
    CASE 
        WHEN (`RSI (14 days)` < 45 AND `MACD` > 0) THEN 'Strong Buy Signal'
        WHEN (`RSI (14 days)` >= 69) THEN 'Strong Selling Signal'
        WHEN (`RSI (14 days)` BETWEEN 45 AND 68) THEN 'Neutral'
        ELSE NULL
    END AS Signal_Type
FROM 
    stock_market_data
WHERE 
    (`RSI (14 days)` < 45 AND `MACD` > 0) OR (`RSI (14 days)` >= 69) OR (`RSI (14 days)` BETWEEN 45 AND 68);



    
#*****************************************************************END*****************************************************************





