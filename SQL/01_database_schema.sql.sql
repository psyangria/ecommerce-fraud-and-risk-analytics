--
-- PostgreSQL database dump
--

\restrict 6DE5Hk12yCZfQHRUth1qmiQiidbYxIBwmt31agoHPEYdN8TpfWGF9TDCGw155uT

-- Dumped from database version 16.14 (Homebrew)
-- Dumped by pg_dump version 16.14 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cancellations_table; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.cancellations_table (
    cancellation_id text NOT NULL,
    order_id text,
    customer_unique_id text,
    seller_id text,
    cancellation_date timestamp without time zone,
    cancellation_reason text,
    cancellation_type text,
    order_value numeric(10,2)
);


ALTER TABLE public.cancellations_table OWNER TO chestabhandari;

--
-- Name: customer_cancellation_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.customer_cancellation_features (
    customer_unique_id text,
    cancellation_count bigint,
    customer_requested_count bigint,
    payment_failure_count bigint,
    seller_issue_count bigint,
    logistics_issue_count bigint,
    total_orders bigint,
    cancellation_rate numeric
);


ALTER TABLE public.customer_cancellation_features OWNER TO chestabhandari;

--
-- Name: customer_delivery_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.customer_delivery_features (
    customer_unique_id text,
    delivered_order_count bigint,
    avg_delivery_delay numeric,
    max_delivery_delay integer,
    late_order_count bigint,
    late_order_ratio numeric
);


ALTER TABLE public.customer_delivery_features OWNER TO chestabhandari;

--
-- Name: customer_feature_mart; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.customer_feature_mart (
    customer_unique_id text,
    total_orders bigint,
    total_spend numeric,
    avg_order_value numeric,
    purchased_items bigint,
    returned_items bigint,
    return_rate numeric,
    refund_count bigint,
    total_refund_amount numeric,
    full_refund_count bigint,
    partial_refund_count bigint,
    avg_refund_ratio numeric,
    cancellation_count bigint,
    customer_requested_count bigint,
    payment_failure_count bigint,
    seller_issue_count bigint,
    logistics_issue_count bigint,
    cancellation_rate numeric,
    avg_review_score numeric,
    review_count bigint,
    low_review_ratio numeric,
    delivered_order_count bigint,
    avg_delivery_delay numeric,
    max_delivery_delay integer,
    late_order_count bigint,
    late_order_ratio numeric
);


ALTER TABLE public.customer_feature_mart OWNER TO chestabhandari;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.customers (
    customer_id text NOT NULL,
    customer_unique_id text,
    customer_zip_code_prefix integer,
    customer_city text,
    customer_state text
);


ALTER TABLE public.customers OWNER TO chestabhandari;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.order_items (
    order_id text NOT NULL,
    order_item_id integer NOT NULL,
    product_id text,
    seller_id text,
    shipping_limit_date timestamp without time zone,
    price numeric(10,2),
    freight_value numeric(10,2)
);


ALTER TABLE public.order_items OWNER TO chestabhandari;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.orders (
    order_id text NOT NULL,
    customer_id text,
    order_status text,
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone
);


ALTER TABLE public.orders OWNER TO chestabhandari;

--
-- Name: customer_order_summary; Type: VIEW; Schema: public; Owner: chestabhandari
--

CREATE VIEW public.customer_order_summary AS
 SELECT c.customer_unique_id,
    count(DISTINCT o.order_id) AS total_orders,
    round(sum(oi.price), 2) AS total_spend,
    round((sum(oi.price) / (count(DISTINCT o.order_id))::numeric), 2) AS avg_order_value
   FROM ((public.customers c
     JOIN public.orders o ON ((c.customer_id = o.customer_id)))
     JOIN public.order_items oi ON ((o.order_id = oi.order_id)))
  GROUP BY c.customer_unique_id;


ALTER VIEW public.customer_order_summary OWNER TO chestabhandari;

--
-- Name: customer_refund_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.customer_refund_features (
    customer_unique_id text,
    refund_count bigint,
    total_refund_amount numeric,
    full_refund_count bigint,
    partial_refund_count bigint,
    avg_refund_ratio numeric
);


ALTER TABLE public.customer_refund_features OWNER TO chestabhandari;

--
-- Name: customer_return_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.customer_return_features (
    customer_unique_id text,
    purchased_items bigint,
    returned_items bigint,
    return_rate numeric
);


ALTER TABLE public.customer_return_features OWNER TO chestabhandari;

--
-- Name: customer_review_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.customer_review_features (
    customer_unique_id text,
    avg_review_score numeric,
    review_count bigint,
    low_review_ratio numeric
);


ALTER TABLE public.customer_review_features OWNER TO chestabhandari;

--
-- Name: customer_risk_scores; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.customer_risk_scores (
    customer_unique_id text,
    return_component numeric,
    refund_component numeric,
    cancellation_component numeric,
    review_component numeric,
    delivery_component numeric,
    risk_score numeric
);


ALTER TABLE public.customer_risk_scores OWNER TO chestabhandari;

--
-- Name: fraud_flags; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.fraud_flags (
    customer_unique_id text,
    risk_score numeric,
    risk_band text,
    is_flagged integer
);


ALTER TABLE public.fraud_flags OWNER TO chestabhandari;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.payments (
    order_id text NOT NULL,
    payment_sequential integer NOT NULL,
    payment_type text,
    payment_installments integer,
    payment_value numeric(10,2)
);


ALTER TABLE public.payments OWNER TO chestabhandari;

--
-- Name: products; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.products (
    product_id text NOT NULL,
    product_category_name text,
    product_name_lenght integer,
    product_description_lenght integer,
    product_photos_qty integer,
    product_weight_g numeric,
    product_length_cm numeric,
    product_height_cm numeric,
    product_width_cm numeric
);


ALTER TABLE public.products OWNER TO chestabhandari;

--
-- Name: refunds_table; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.refunds_table (
    refund_id text NOT NULL,
    return_id text,
    order_id text,
    customer_unique_id text,
    seller_id text,
    refund_date timestamp without time zone,
    refund_reason text,
    refund_type text,
    refund_status text,
    item_price numeric(10,2),
    refund_amount numeric(10,2),
    refund_ratio numeric(6,4)
);


ALTER TABLE public.refunds_table OWNER TO chestabhandari;

--
-- Name: returns_table; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.returns_table (
    return_id text NOT NULL,
    order_id text,
    order_item_id integer,
    customer_unique_id text,
    product_id text,
    seller_id text,
    return_date timestamp without time zone,
    return_reason text,
    item_price numeric(10,2)
);


ALTER TABLE public.returns_table OWNER TO chestabhandari;

--
-- Name: reviews_dedup; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.reviews_dedup (
    review_id text,
    order_id text,
    review_score integer,
    review_comment_title text,
    review_comment_message text,
    review_creation_date timestamp without time zone,
    review_answer_timestamp timestamp without time zone
);


ALTER TABLE public.reviews_dedup OWNER TO chestabhandari;

--
-- Name: seller_cancellation_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_cancellation_features (
    seller_id text,
    cancellation_count bigint,
    seller_issue_count bigint,
    logistics_issue_count bigint,
    cancellation_rate numeric
);


ALTER TABLE public.seller_cancellation_features OWNER TO chestabhandari;

--
-- Name: seller_delivery_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_delivery_features (
    seller_id text,
    delivered_order_count bigint,
    avg_delivery_delay numeric,
    max_delivery_delay integer,
    late_order_count bigint,
    late_order_ratio numeric
);


ALTER TABLE public.seller_delivery_features OWNER TO chestabhandari;

--
-- Name: seller_feature_mart; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_feature_mart (
    seller_id text,
    total_orders bigint,
    total_items_sold bigint,
    total_revenue numeric,
    avg_item_price numeric,
    returned_items bigint,
    return_rate numeric,
    refund_count bigint,
    total_refund_amount numeric,
    full_refund_count bigint,
    partial_refund_count bigint,
    avg_refund_ratio numeric,
    avg_review_score numeric,
    review_count bigint,
    low_review_ratio numeric,
    cancellation_count bigint,
    seller_issue_count bigint,
    logistics_issue_count bigint,
    cancellation_rate numeric,
    delivered_order_count bigint,
    avg_delivery_delay numeric,
    max_delivery_delay integer,
    late_order_count bigint,
    late_order_ratio numeric
);


ALTER TABLE public.seller_feature_mart OWNER TO chestabhandari;

--
-- Name: seller_feature_mart_capped; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_feature_mart_capped (
    seller_id text,
    total_orders bigint,
    total_items_sold bigint,
    total_revenue numeric,
    avg_item_price numeric,
    return_rate numeric,
    returned_items_capped numeric,
    avg_refund_ratio numeric,
    refund_count_capped numeric,
    total_refund_amount_capped numeric,
    full_refund_count bigint,
    partial_refund_count bigint,
    avg_review_score numeric,
    review_count bigint,
    low_review_ratio numeric,
    cancellation_count bigint,
    seller_issue_count bigint,
    logistics_issue_count bigint,
    cancellation_rate numeric,
    avg_delivery_delay numeric,
    max_delivery_delay_capped numeric,
    delivered_order_count bigint,
    late_order_count bigint,
    late_order_ratio numeric
);


ALTER TABLE public.seller_feature_mart_capped OWNER TO chestabhandari;

--
-- Name: seller_flags; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_flags (
    seller_id text,
    risk_score numeric,
    risk_band text,
    is_flagged integer
);


ALTER TABLE public.seller_flags OWNER TO chestabhandari;

--
-- Name: seller_order_summary; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_order_summary (
    seller_id text,
    total_orders bigint,
    total_items_sold bigint,
    total_revenue numeric,
    avg_item_price numeric
);


ALTER TABLE public.seller_order_summary OWNER TO chestabhandari;

--
-- Name: seller_refund_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_refund_features (
    seller_id text,
    refund_count bigint,
    total_refund_amount numeric,
    full_refund_count bigint,
    partial_refund_count bigint,
    avg_refund_ratio numeric
);


ALTER TABLE public.seller_refund_features OWNER TO chestabhandari;

--
-- Name: seller_return_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_return_features (
    seller_id text,
    total_items_sold bigint,
    returned_items bigint,
    return_rate numeric
);


ALTER TABLE public.seller_return_features OWNER TO chestabhandari;

--
-- Name: seller_review_features; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_review_features (
    seller_id text,
    avg_review_score numeric,
    review_count bigint,
    low_review_ratio numeric
);


ALTER TABLE public.seller_review_features OWNER TO chestabhandari;

--
-- Name: seller_risk_scores; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.seller_risk_scores (
    seller_id text,
    return_component numeric,
    refund_component numeric,
    review_component numeric,
    cancellation_component numeric,
    delivery_component numeric,
    risk_score numeric
);


ALTER TABLE public.seller_risk_scores OWNER TO chestabhandari;

--
-- Name: sellers; Type: TABLE; Schema: public; Owner: chestabhandari
--

CREATE TABLE public.sellers (
    seller_id text NOT NULL,
    seller_zip_code_prefix integer,
    seller_city text,
    seller_state text
);


ALTER TABLE public.sellers OWNER TO chestabhandari;

--
-- Name: vw_customer_fraud_monitoring; Type: VIEW; Schema: public; Owner: chestabhandari
--

CREATE VIEW public.vw_customer_fraud_monitoring AS
 SELECT cfm.customer_unique_id,
    ff.risk_score,
    ff.risk_band,
    ff.is_flagged,
    crs.return_component,
    crs.refund_component,
    crs.cancellation_component,
    crs.review_component,
    crs.delivery_component,
    cfm.total_orders,
    cfm.total_spend,
    cfm.avg_order_value,
    cfm.purchased_items,
    cfm.returned_items,
    cfm.return_rate,
    cfm.refund_count,
    cfm.total_refund_amount,
    cfm.full_refund_count,
    cfm.partial_refund_count,
    cfm.avg_refund_ratio,
    cfm.cancellation_count,
    cfm.customer_requested_count,
    cfm.payment_failure_count,
    cfm.seller_issue_count,
    cfm.logistics_issue_count,
    cfm.cancellation_rate,
    cfm.avg_review_score,
    cfm.review_count,
    cfm.low_review_ratio,
    cfm.delivered_order_count,
    cfm.avg_delivery_delay,
    cfm.max_delivery_delay,
    cfm.late_order_count,
    cfm.late_order_ratio
   FROM ((public.customer_feature_mart cfm
     LEFT JOIN public.customer_risk_scores crs ON ((cfm.customer_unique_id = crs.customer_unique_id)))
     LEFT JOIN public.fraud_flags ff ON ((cfm.customer_unique_id = ff.customer_unique_id)));


ALTER VIEW public.vw_customer_fraud_monitoring OWNER TO chestabhandari;

--
-- Name: vw_financial_exposure; Type: VIEW; Schema: public; Owner: chestabhandari
--

CREATE VIEW public.vw_financial_exposure AS
 SELECT sfm.seller_id,
    sf.risk_score,
    sf.risk_band,
    sf.is_flagged,
    sfm.total_orders,
    sfm.total_items_sold,
    sfm.total_revenue,
    sfm.avg_item_price,
    sfm.refund_count,
    sfm.total_refund_amount,
    sfm.avg_refund_ratio,
    sfm.cancellation_count,
    sfm.cancellation_rate,
    round((COALESCE(sfm.total_refund_amount, (0)::numeric) + ((COALESCE(sfm.cancellation_count, (0)::bigint))::numeric * COALESCE(sfm.avg_item_price, (0)::numeric))), 2) AS estimated_loss,
    round(((COALESCE(sfm.total_refund_amount, (0)::numeric) + ((COALESCE(sfm.cancellation_count, (0)::bigint))::numeric * COALESCE(sfm.avg_item_price, (0)::numeric))) / NULLIF(sfm.total_revenue, (0)::numeric)), 4) AS loss_to_revenue_ratio
   FROM (public.seller_feature_mart sfm
     LEFT JOIN public.seller_flags sf ON ((sfm.seller_id = sf.seller_id)));


ALTER VIEW public.vw_financial_exposure OWNER TO chestabhandari;

--
-- Name: vw_seller_risk_monitoring; Type: VIEW; Schema: public; Owner: chestabhandari
--

CREATE VIEW public.vw_seller_risk_monitoring AS
 SELECT sfm.seller_id,
    sf.risk_score,
    sf.risk_band,
    sf.is_flagged,
    srs.return_component,
    srs.refund_component,
    srs.review_component,
    srs.cancellation_component,
    srs.delivery_component,
    sfm.total_orders,
    sfm.total_items_sold,
    sfm.total_revenue,
    sfm.avg_item_price,
    sfm.returned_items,
    sfm.return_rate,
    sfm.refund_count,
    sfm.total_refund_amount,
    sfm.full_refund_count,
    sfm.partial_refund_count,
    sfm.avg_refund_ratio,
    sfm.avg_review_score,
    sfm.review_count,
    sfm.low_review_ratio,
    sfm.cancellation_count,
    sfm.seller_issue_count,
    sfm.logistics_issue_count,
    sfm.cancellation_rate,
    sfm.delivered_order_count,
    sfm.avg_delivery_delay,
    sfm.max_delivery_delay,
    sfm.late_order_count,
    sfm.late_order_ratio
   FROM ((public.seller_feature_mart sfm
     LEFT JOIN public.seller_risk_scores srs ON ((sfm.seller_id = srs.seller_id)))
     LEFT JOIN public.seller_flags sf ON ((sfm.seller_id = sf.seller_id)));


ALTER VIEW public.vw_seller_risk_monitoring OWNER TO chestabhandari;

--
-- Name: cancellations_table cancellations_table_pkey; Type: CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.cancellations_table
    ADD CONSTRAINT cancellations_table_pkey PRIMARY KEY (cancellation_id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_id, order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (order_id, payment_sequential);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: refunds_table refunds_table_pkey; Type: CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.refunds_table
    ADD CONSTRAINT refunds_table_pkey PRIMARY KEY (refund_id);


--
-- Name: returns_table returns_table_pkey; Type: CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.returns_table
    ADD CONSTRAINT returns_table_pkey PRIMARY KEY (return_id);


--
-- Name: sellers sellers_pkey; Type: CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_pkey PRIMARY KEY (seller_id);


--
-- Name: order_items fk_order_items_order; Type: FK CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: order_items fk_order_items_product; Type: FK CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: order_items fk_order_items_seller; Type: FK CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_seller FOREIGN KEY (seller_id) REFERENCES public.sellers(seller_id);


--
-- Name: orders fk_orders_customer; Type: FK CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: payments fk_payments_order; Type: FK CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: reviews_dedup fk_reviews_order; Type: FK CONSTRAINT; Schema: public; Owner: chestabhandari
--

ALTER TABLE ONLY public.reviews_dedup
    ADD CONSTRAINT fk_reviews_order FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 6DE5Hk12yCZfQHRUth1qmiQiidbYxIBwmt31agoHPEYdN8TpfWGF9TDCGw155uT

