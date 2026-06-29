SET ECHO ON
SPOOL c:/cprg250s/timber_project_p4.txt

--------------------------------------------------------------------------------
-- 1. DROP TABLES IN REVERSE ORDER
--------------------------------------------------------------------------------
DROP TABLE timber_orderitems CASCADE CONSTRAINTS;
DROP TABLE timber_tax CASCADE CONSTRAINTS;
DROP TABLE timber_order CASCADE CONSTRAINTS;
DROP TABLE timber_ship_rate CASCADE CONSTRAINTS;
DROP TABLE timber_review CASCADE CONSTRAINTS;
DROP TABLE timber_customer CASCADE CONSTRAINTS;
DROP TABLE timber_product_supplier CASCADE CONSTRAINTS;
DROP TABLE timber_product CASCADE CONSTRAINTS;
DROP TABLE timber_supplier CASCADE CONSTRAINTS;
DROP TABLE timber_category CASCADE CONSTRAINTS;

--------------------------------------------------------------------------------
-- 2. CREATE PARENT TABLES FIRST
--------------------------------------------------------------------------------

-- Table 1: Category (Self-Referencing Parent)
CREATE TABLE timber_category (
    category#         NUMBER CONSTRAINT timber_category_pk PRIMARY KEY,
    name              VARCHAR2(100) NOT NULL,
    parent_category#  NUMBER CONSTRAINT timber_parent_cat_fk REFERENCES timber_category(category#)
);

-- Table 2: Supplier
CREATE TABLE timber_supplier (
    supplier#     NUMBER CONSTRAINT timber_supplier_pk PRIMARY KEY,
    name          VARCHAR2(100) NOT NULL,
    email_address VARCHAR2(100) NOT NULL CONSTRAINT timber_supplier_email_uq UNIQUE,
    city          VARCHAR2(50) NOT NULL,
    prov          CHAR(2) NOT NULL,
    CONSTRAINT timber_supplier_email_ck CHECK (REGEXP_LIKE(email_address, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')),
    CONSTRAINT timber_supplier_prov_ck CHECK (prov IN ('AB','BC','SK','MB','ON','QC','PE','NL','NT','YT','NS','NB','NU'))
);

-- Table 3: Product
CREATE TABLE timber_product (
    product#          NUMBER CONSTRAINT timber_product_pk PRIMARY KEY,
    category#         NUMBER CONSTRAINT timber_product_cat_fk REFERENCES timber_category(category#),
    price             NUMBER(12,2) NOT NULL,
    quantity_on_hand  NUMBER(12) NOT NULL,
    description       VARCHAR2(1000) NOT NULL,
    title             VARCHAR2(150) NOT NULL,
    weight_kg         NUMBER(12,2) NOT NULL,
    isTaxExempt       NUMBER(1) NOT NULL,
    CONSTRAINT timber_product_price_ck CHECK (price > 0),
    CONSTRAINT timber_product_qty_ck CHECK (quantity_on_hand >= 0),
    CONSTRAINT timber_product_weight_ck CHECK (weight_kg > 0),
    CONSTRAINT timber_product_tax_ex_ck CHECK (isTaxExempt IN (0, 1))
);

-- Table 4: Customer
CREATE TABLE timber_customer (
    customer#       NUMBER CONSTRAINT timber_customer_pk PRIMARY KEY,
    firstname       VARCHAR2(50) NOT NULL,
    lastname        VARCHAR2(50) NOT NULL,
    phoneNumber     CHAR(12) NOT NULL,
    address         VARCHAR2(100) NOT NULL,
    city            VARCHAR2(50) NOT NULL,
    prov            CHAR(2) NOT NULL,
    postal_code     CHAR(6) NOT NULL,
    customerEmail   VARCHAR2(100) NOT NULL,
    isTimberMember  NUMBER(1) NOT NULL,
    CONSTRAINT timber_cust_phone_ck CHECK (REGEXP_LIKE(phoneNumber, '^\d{3}\.\d{3}\.\d{4}$')),
    CONSTRAINT timber_cust_prov_ck CHECK (prov IN ('AB','BC','SK','MB','ON','QC','PE','NL','NT','YT','NS','NB','NU')),
    CONSTRAINT timber_cust_postal_ck CHECK (REGEXP_LIKE(postal_code, '^[A-Z]\d[A-Z]\d[A-Z]\d$')),
    CONSTRAINT timber_cust_email_uq UNIQUE (customerEmail),
    CONSTRAINT timber_cust_email_ck CHECK (REGEXP_LIKE(customerEmail, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')),
    CONSTRAINT timber_cust_member_ck CHECK (isTimberMember IN (0, 1))
);

-- Table 5: Shipping Rate
CREATE TABLE timber_ship_rate (
    shiprate#        NUMBER CONSTRAINT timber_ship_rate_pk PRIMARY KEY,
    min_weight       NUMBER(6,2) NOT NULL,
    max_weight       NUMBER(6,2) NOT NULL,
    shipping_amount  NUMBER(6,2) NOT NULL,
    CONSTRAINT timber_ship_weight_ck CHECK (min_weight < max_weight),
    CONSTRAINT timber_ship_amount_ck CHECK (shipping_amount >= 0)
);

-- Table 6: Tax Rate
CREATE TABLE timber_tax (
    prov           CHAR(2) CONSTRAINT timber_tax_pk PRIMARY KEY,
    prov_hst_rate  NUMBER(4,3),
    gst_rate       NUMBER(4,3),
    pst_rate       NUMBER(4,3),
    CONSTRAINT timber_tax_prov_ck CHECK (prov IN ('AB','BC','SK','MB','ON','QC','PE','NL','NT','YT','NS','NB','NU'))
);

--------------------------------------------------------------------------------
-- 3. CREATE CHILD & BRIDGING TABLES
--------------------------------------------------------------------------------

-- Table 7: Product Supplier Bridge (Composite Primary Key)
CREATE TABLE timber_product_supplier (
    supplier#  NUMBER,
    product#   NUMBER,
    CONSTRAINT timber_prod_supp_pk PRIMARY KEY (supplier#, product#),
    CONSTRAINT timber_prod_supp_fk_supp FOREIGN KEY (supplier#) REFERENCES timber_supplier(supplier#),
    CONSTRAINT timber_prod_supp_fk_prod FOREIGN KEY (product#) REFERENCES timber_product(product#)
);

-- Table 8: Review
CREATE TABLE timber_review (
    review#         NUMBER CONSTRAINT timber_review_pk PRIMARY KEY,
    rating          NUMBER(1) NOT NULL,
    dateOfReview    DATE NOT NULL,
    reviewComments  VARCHAR2(1000) NOT NULL,
    customer#       NUMBER NOT NULL,
    product#        NUMBER NOT NULL,
    CONSTRAINT timber_review_rating_ck CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT timber_review_cust_fk FOREIGN KEY (customer#) REFERENCES timber_customer(customer#),
    CONSTRAINT timber_review_prod_fk FOREIGN KEY (product#) REFERENCES timber_product(product#)
);

-- Table 9: Order (Utilizing ALTER TABLE additions)
CREATE TABLE timber_order (
    order#                   NUMBER CONSTRAINT timber_order_pk PRIMARY KEY,
    customer#                NUMBER NOT NULL,
    order_date               DATE NOT NULL,
    estimated_delivery_date  DATE,
    prov                     CHAR(2) NOT NULL,
    total_weight             NUMBER(10,3),
    tax_amount               NUMBER(10,2),
    ship_amount              NUMBER(6,2),
    shiprate#                NUMBER NOT NULL
);

ALTER TABLE timber_order ADD (
    CONSTRAINT timber_order_cust_fk FOREIGN KEY (customer#) REFERENCES timber_customer(customer#),
    CONSTRAINT timber_order_tax_fk FOREIGN KEY (prov) REFERENCES timber_tax(prov),
    CONSTRAINT timber_order_ship_fk FOREIGN KEY (shiprate#) REFERENCES timber_ship_rate(shiprate#)
);

-- Table 10: Order Items Bridge (Composite Key + Unique Naming)
CREATE TABLE timber_orderitems (
    order#            NUMBER,
    product#          NUMBER,
    quantity_ordered  NUMBER(5) NOT NULL,
    CONSTRAINT timber_orderitems_pk PRIMARY KEY (order#, product#),
    CONSTRAINT timber_orderitems_qty_ck CHECK (quantity_ordered > 0)
);

ALTER TABLE timber_orderitems ADD (
    CONSTRAINT timber_orderitems_order_fk FOREIGN KEY (order#) REFERENCES timber_order(order#),
    CONSTRAINT timber_orderitems_prod_fk FOREIGN KEY (product#) REFERENCES timber_product(product#)
);

SPOOL OFF;
