-- Ford GoBike Analysis (2014–2017)

-- 1) Trip Duration by Month
SELECT 
    DATE_TRUNC('month', start_time) AS month,
    AVG(trip_duration) AS avg_trip_duration,
    COUNT(*) AS total_trips
FROM trips
GROUP BY 1
ORDER BY 1;

-- 2) Bike Utilization by Region
SELECT 
    s.region,
    COUNT(t.trip_id) AS trips,
    COUNT(DISTINCT t.bike_id) AS bikes_used,
    COUNT(t.trip_id)::decimal / NULLIF(COUNT(DISTINCT t.bike_id),0) AS trips_per_bike
FROM trips t
JOIN stations s ON t.start_station_id = s.station_id
GROUP BY s.region
ORDER BY trips DESC;

-- 3) Trip Share by Region (Percent of total)
SELECT 
    s.region,
    COUNT(*) AS trips,
    ROUND(100 * COUNT(*)::decimal / SUM(COUNT(*)) OVER (), 2) AS pct_share
FROM trips t
JOIN stations s ON t.start_station_id = s.station_id
GROUP BY s.region
ORDER BY trips DESC;

-- 4) Seasonality (Nov–Dec drop-off check)
SELECT 
    DATE_TRUNC('month', start_time) AS month,
    COUNT(*) AS total_trips
FROM trips
GROUP BY 1
HAVING EXTRACT(MONTH FROM DATE_TRUNC('month', start_time)) IN (11, 12)
ORDER BY 1;
