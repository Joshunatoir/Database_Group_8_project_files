set ECHO ON
spool c:/cprg250s/timber_project_p4.txt

CREATE TABLE T_CUSTOMER (
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

ALTER TABLE T_CUSTOMER ADD(
	CONSTRAINT t_customer_cust_num_pk PRIMARY KEY (customer#),
	CONSTRAINT t_customer_phnum_ck CHECK (REGEXP_LIKE (phoneNumber,'^\d{3}\.\d{3}\.\d{4}$')),
	CONSTRAINT t_customer_prov_ck CHECK (prov IN ('ab','bc','sk','mb','on','qc','pe','nl','nt','yt','ns','nb','nu')),
	CONSTRAINT t_customer_postcode_ck CHECK (REGEXP_LIKE (postal_code, '^[A-Z]\d[A-Z]\d[A-Z]\d$')),
	CONSTRAINT t_customer_postcode_uq UNIQUE (postal_code),
	CONSTRAINT t_customer_email_uq UNIQUE (customerEmail),
	CONSTRAINT t_customer_timember CHECK(isTimberMember IN(0, 1))
);
	
ALTER TABLE T_CUSTOMER MODIFY(
	firstname, NOT NULL,
	lastname, NOT NULL,
	phoneNumber, NOT NULL,
	address,NOT NULL,
	city,NOT NULL,
	prov,NOT NULL,
	postal_code,NOT NULL,
	customerEmail,NOT NULL	
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