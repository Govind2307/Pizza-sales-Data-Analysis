CREATE DATABASE pizzahome;
USE pizzahome;

CREATE TABLE orders(
	order_id INT NOT NULL,
    order_date date NOT NULL,
    order_time TIME ,
    PRIMARY KEY(order_id));
    
CREATE TABLE orders_details(
	order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT,
    PRIMARY KEY(order_details_id));


-- Q.1 Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_order_placed
FROM
    orders;

-- Q.2 Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;
    
-- Q.3 Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Q.4 Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS total_size
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY total_size DESC
LIMIT 1;

-- Q.5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS total_quant
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quant DESC
LIMIT 5;


-- Q.6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS total_cat_count
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_cat_count DESC;

-- Q.7 Determine the distribution of total quantity of orders by hour of day.

SELECT 
    HOUR(orders.order_time) AS H,
    SUM(orders_details.quantity) AS hour_count
FROM
    orders
        JOIN
    orders_details ON orders.order_id = orders_details.order_id
GROUP BY H
ORDER BY hour_count DESC;

-- Q.8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
	pizza_types.category,
    COUNT(pizza_types.name) AS dist_count
FROM pizza_types
GROUP BY pizza_types.category
ORDER BY dist_count DESC;

-- Q.9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_quant), 0) AS QUANT
FROM
    (SELECT 
        orders.order_date AS date_ordered,
            SUM(orders_details.quantity) AS total_quant
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY date_ordered
    ORDER BY total_quant DESC) AS order_quant;

-- Q.10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Q.11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    SUM(orders_details.quantity * pizzas.price) AS total_revenue
                FROM
                    orders_details
                        JOIN
                    pizzas ON orders_details.pizza_id = pizzas.pizza_id), 4) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Q.12 Analyze the cumulative revenue generated over time.

SELECT
	order_date,
    ROUND(SUM(revenue) over (order by order_date), 2) as cum_revenue
FROM
(SELECT 
	orders.order_date,
	ROUND(SUM(orders_details.quantity * pizzas.price),2) AS revenue
FROM orders JOIN orders_details ON orders.order_id =  orders_details.order_id
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY orders.order_date) AS sales;


-- Q.13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.


SELECT
	name,
    revenue,
    category
FROM
(
SELECT 
	name,
    revenue,
    category,
    RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
(SELECT 
    pizza_types.name,
    SUM(pizzas.price * orders_details.quantity) AS revenue,
    pizza_types.category
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name , pizza_types.category) AS sub) AS final
WHERE rn <= 3;


    