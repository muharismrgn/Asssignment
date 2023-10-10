-- QUESTION 1
-- 1. How many users are there?
select 
	count(distinct user_id) as total_user
from 
	users;

-- 2. How many cookies does each user have on average?
select 
	user_id, 
	count(cookie_id) as total_cookie,
    avg(count(cookie_id)) over() as avg_cookie
from 
	users
group by 
	user_id;

-- 3. What is the unique number of visits by all users per month?
select 
	date_format(start_date, "%Y-%m") as month, 
	count(distinct user_id) as total_user
FROM 
	users
group by 
	month
order by 
	month asc;

-- 4. What is the number of events for each event type?
SELECT 
	event_type, 
    count(event_type) as total_event
FROM 
	events
group by 
	event_type;

-- 5. What is the percentage of visits which have a purchase event?
select 
	ei.event_name, 
    round(count(e.visit_id)/(select count(distinct visit_id) from events) * 100, 2) as visit_percentage
from 
	events e
join 
	event_identifier ei
on 
	e.event_type = ei.event_type
where 
	ei.event_name = 'Purchase';

-- 6. What is the number of views and cart adds for each product category?
with views as(
	select 
		ph.product_category, 
        count(e.event_type) as total_views
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Page View' and ph.product_category is not null
	group by 
		ph.product_category
),
cart_adds as(
	select 
		ph.product_category, 
        count(e.event_type) as total_cart_adds
	from
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Add to Cart' and ph.product_category is not null
	group by 
		ph.product_category
)	
select 
	v.product_category, 
    v.total_views, 
    ca.total_cart_adds
from 
	views v
join 
	cart_adds ca
on 
	v.product_category = ca.product_category;

-- QUESTION 2
-- How many times was each product viewed?
select 
	ph.page_name as product_name, 
	count(ph.page_name) as views_count
from 
	page_hierarchy ph
join 
	events e
on 
	ph.page_id = e.page_id
join 
	event_identifier as ei
on 
	e.event_type = ei.event_type
where 
	ei.event_name='Page View' and ph.product_category is not null
group by 
	ph.page_name
order by 
	views_count desc;

-- How many times was each product added to cart?
select 
	ph.page_name as product_name, 
	count(ph.page_name) as cart_adds_count
from 
	page_hierarchy ph
join 
	events e
on 
	ph.page_id = e.page_id
join 
	event_identifier as ei
on 
	e.event_type = ei.event_type
where 
	ei.event_name='Add to Cart' and ph.product_category is not null
group by 
	ph.page_name
order by
	cart_adds_count desc;

-- How many times was each product added to a cart but not purchased (abandoned)?
with cart_adds as (
	select 
		e.visit_id,
        ph.page_name as product_name
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Add to Cart'
),
purchases as (
	select 
		e.visit_id
	from 
		events e
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Purchase'
)
select 
	ca.product_name,
    count(ca.product_name) as total_abandoned
from 
	cart_adds ca
left join 
	purchases p
on 
	ca.visit_id = p.visit_id
where 
	p.visit_id is null
group by
	ca.product_name
order by 
	total_abandoned desc;

-- How many times was each product purchased?
with cart_adds as (
	select 
		e.visit_id,
        e.event_time,
        ph.product_id, 
        ph.page_name as product_name
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Add to Cart'
),
purchases as (
	select 
		e.visit_id
	from 
		events e
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Purchase'
)
select 
	ca.product_name,
    count(ca.product_name) as total_purchased
from 
	cart_adds ca
join 
	purchases p
on 
	ca.visit_id = p.visit_id
group by
	ca.product_name
order by 
	total_purchased desc;
    
-- ----------------------

-- 1. Which product had the most views, cart adds and purchases?
with views as(
	select 
		ph.page_name as product_name, 
		count(ph.page_name) as total_views
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Page View' and ph.product_category is not null
    group by 
		product_name
),
cart_adds as (
	select  
		e.visit_id,
		ph.page_name as product_name,
		count(ph.page_name) over (partition by ph.page_name) as total_cart_adds
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Add to Cart'
),
purchases as (
	select 
		e.visit_id
	from 
		events e
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Purchase'
)
select 
	v.product_name, 
	v.total_views, 
    dense_rank() over (order by v.total_views desc) as view_rank,
    ca.total_cart_adds,
    dense_rank() over (order by ca.total_cart_adds desc) as cart_adds_rank,
	count(ca.product_name) as total_purchases,
    dense_rank() over (order by count(ca.product_name) desc) as purchase_rank
from 
	views v
join 
	cart_adds ca
on 
	v.product_name = ca.product_name
join 
	purchases p
on 
	ca.visit_id = p.visit_id
group by 
	ca.product_name;

-- 2. Which product was most likely to be abandoned?
with cart_adds as (
	select 
		e.visit_id,
        ph.page_name as product_name
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Add to Cart'
),
purchases as (
	select 
		e.visit_id
	from 
		events e
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Purchase'
)
select 
	ca.product_name, 
	count(ca.product_name) as total_abandoned,
    dense_rank () over (order by count(ca.product_name) desc) as ranking
from 
	cart_adds ca
left join 
	purchases p
on 
	ca.visit_id = p.visit_id
where 
	p.visit_id is null
group by 
	ca.product_name;

-- 3. Which product had the highest view to purchase percentage?
with views as(
	select 
		ph.page_name as product_name, 
		count(ph.page_name) as total_views
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Page View' and ph.product_category is not null
    group by 
		product_name
),
cart_adds as (
	select  
		e.visit_id,
        ph.page_name as product_name,
		count(ph.page_name) over (partition by ph.page_name) as total_cart_adds
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Add to Cart'
),
purchases as (
	select 
		e.visit_id
	from 
		events e
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Purchase'
)
select 
	ca.product_name, 
	v.total_views, 
	count(ca.product_name) as total_purchases,
    round(count(ca.product_name)/v.total_views * 100, 2) as convertion_rate,
    dense_rank() over (order by count(ca.product_name)/v.total_views desc) as convertion_rank
from 
	views v
join 
	cart_adds ca
on 
	v.product_name = ca.product_name
join 
	purchases p
on 
	ca.visit_id = p.visit_id
group by 
	ca.product_name;

-- 4. What is the average conversion rate from view to cart add?
with views as(
	select 
		ph.page_name as product_name, 
		count(ph.page_name) as total_views
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Page View' and ph.product_category is not null
    group by 
		product_name
),
cart_adds as (
	select
        ph.page_name as product_name,
		count(ph.page_name) as total_cart_adds
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Add to Cart'
	group by 
		product_name
)
select 
	v.product_name, 
    v.total_views,
    ca.total_cart_adds,
    round(ca.total_cart_adds/v.total_views * 100, 2) as convertion_rate,
    dense_rank() over (order by ca.total_cart_adds/v.total_views desc) as convertion_rank,
    round(avg(ca.total_cart_adds/v.total_views * 100) over(), 2) as avg_convertion_rate
from 
	views v
join 
	cart_adds ca
on 
	v.product_name = ca.product_name;

-- 5. What is the average conversion rate from cart add to purchase?
with cart_adds as (
	select  
		e.visit_id,
        ph.page_name as product_name,
		count(ph.page_name) over (partition by ph.page_name) as total_cart_adds
	from 
		page_hierarchy ph
	join 
		events e
	on 
		ph.page_id = e.page_id
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Add to Cart'
),
purchases as (
	select 
		e.visit_id
	from 
		events e
	join 
		event_identifier as ei
	on 
		e.event_type = ei.event_type
	where 
		ei.event_name='Purchase'
),
cart_purchases as(
	select 
		ca.product_name,
		ca.total_cart_adds,
		count(ca.product_name) as total_purchases,
        round(count(ca.product_name)/ca.total_cart_adds*100, 2) as convertion_rate,
        dense_rank() over (order by count(ca.product_name)/ca.total_cart_adds desc) as convertion_rank
	from
		cart_adds ca
	join 
		purchases p
	on 
		ca.visit_id = p.visit_id
	group by
		ca.product_name
)
select
	product_name,
    total_cart_adds,
    total_purchases,
    convertion_rate,
    convertion_rank,
    round(avg(convertion_rate) over(), 2) as avg_convertion_rate
from 
	cart_purchases;