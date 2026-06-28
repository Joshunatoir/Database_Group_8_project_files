set ECHO ON
spool c:/cprg250s/timber_project_p4.txt

rem dropping child tables first
rem drop timber_orderitems
DROP TABLE timber_orderitems CASCADE CONSTRAINTS;
rem drop timber_tax
DROP TABLE timber_tax CASCADE CONSTRAINTS;
rem drop timber_order
DROP TABLE timber_order CASCADE CONSTRAINTS;
rem drop timber_ship_rate
DROP TABLE timber_ship_rate CASCADE CONSTRAINTS;
rem drop timber_customer_product_review
DROP TABLE timber_customer_product_review CASCADE CONSTRAINTS;
rem drop timber_customer
DROP TABLE timber_customer CASCADE CONSTRAINTS;
rem drop timber_product_review
DROP TABLE timber_product_review CASCADE CONSTRAINTS;
rem drop timber_product_supplier
DROP TABLE timber_product_supplier CASCADE CONSTRAINTS;
rem drop timber_product
DROP TABLE timber_product CASCADE CONSTRAINTS;
rem drop timber_supplier
DROP TABLE timber_supplier CASCADE CONSTRAINTS;
rem drop timber_category
DROP TABLE timber_category CASCADE CONSTRAINTS;

CREATE TABLE timber_category (
  category# NUMBER CONSTRAINT category_num_pk PRIMARY KEY,
	name VARCHAR2(100) NOT NULL,
	parent_category# NUMBER CONSTRAINT parent_cat#_fk REFERENCES timber_category(category#)
);

CREATE TABLE timber_customer (
	customer# NUMBER,
	firstname VARCHAR2(50),
	lastname VARCHAR2(50),
	phoneNumber CHAR(12),
	address VARCHAR2(100),
	city VARCHAR2(50),
	prov CHAR(2),
	postal_code CHAR(6),
	customerEmail VARCHAR2(100),
	isTimberMember NUMBER(1)
);

ALTER TABLE timber_customer ADD(
	CONSTRAINT t_customer_cust_num_pk PRIMARY KEY (customer#),
	CONSTRAINT t_customer_phnum_ck CHECK (REGEXP_LIKE (phoneNumber,'^\d{3}\.\d{3}\.\d{4}$')),
	CONSTRAINT t_customer_prov_ck CHECK (prov IN ('ab','bc','sk','mb','on','qc','pe','nl','nt','yt','ns','nb','nu')),
	CONSTRAINT t_customer_postcode_ck CHECK (REGEXP_LIKE (postal_code, '^[A-Z]\d[A-Z]\d[A-Z]\d$')),
	CONSTRAINT t_customer_postcode_uq UNIQUE (postal_code),
	CONSTRAINT t_customer_email_uq UNIQUE (customerEmail),
	CONSTRAINT t_customer_timember CHECK(isTimberMember IN(0, 1))
);
	
ALTER TABLE timber_customer MODIFY(
	firstname, NOT NULL,
	lastname, NOT NULL,
	phoneNumber, NOT NULL,
	address,NOT NULL,
	city,NOT NULL,
	prov,NOT NULL,
	postal_code,NOT NULL,
	customerEmail,NOT NULL	
);

CREATE TABLE T_TAX(
	prov CHAR(2),
	prov_hst_rate NUMBER(4,3),
	gst_rate NUMBER(4,3),
	pst_rate NUMBER(4,3)
);

CREATE TABLE T_SHIPPING_RATE(
	shiprate# NUMBER,
	min_weight NUMBER(6,2),
	max_weight NUMBER(6,2),
	shippng_amount NUMBER(6,2)
);
CREATE TABLE T_ORDER (
	order# NUMBER CONSTRAINT t_order_ordnum_pk PRIMARY KEY,
	customer# NUMBER CONSTRAINT t_order_custnum_fk FOREIGN KEY,
	orderDate DATE CONSTRAINT t_order_orderDate_nn NOT NULL,
	estimatedDeliveryDate DATE,
	prov char(2) CONSTRAINT t_order_prov_nn NOT NULL,
	totalWeight NUMBER(10,3),
	tax NUMBER(10,2),
	shipAmount NUMBER(6,2),
	shiprate# NUMBER CONSTRAINT t_shiprate_nn NOT NULL
);


spool off