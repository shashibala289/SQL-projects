--Project Detail:
/*An auction Web site has items for sale that are provided by sellers. Each item is associated with one or more categories, has an opening price, a description, and an ending time. Further, each item may or may not be featured.  Sellers also have the option to promote their items as special sale items.  Each special sale item has a sale starting and ending timestamp as well as a special sale price for the sale period.  Customers submit bids. The highest, earliest bid submitted before the ending time is the winning bid and the item is sold to the bidder. Each seller must pay the auction company 5% of the winning bid. The auction company wants to be able to analyze the sales behavior of its customers and sellers and so must keep track of all bids and sales.
The auction company should also provide online mechanisms for sellers/buyers to enter comments about transactions and buyers/sellers involved in the specific transactions.  The auction company should also provide online mechanisms to keep track of disputes between sellers and buyers as well as bid retractions.  A detailed description should accompany any disputes and similarly a reason must be provided for each bid retraction. The auction company has the right to disqualify persons with a large number of retractions and/or disputes from the auction web site.

This ER diagram was mapped into a set of database tables (with the appropriate normalization/denormalization) as shown below:*/


/* drop tables first */
drop table users;
drop table sellers;
drop table buyers;
drop table items;
drop table categories;
drop table itemcategory;
drop table promotions;
drop table bids;
drop table retractions;
drop table sales;

/*Create the table*/

CREATE TABLE users 
(     	userID 		NUMBER 
		CONSTRAINT pk_users PRIMARY KEY, -- uses user_id sequence number
       	email 		VARCHAR2(50),
        	lname 		VARCHAR2(20),
       	fname 		VARCHAR2(25),
       	street 		VARCHAR2(50),
        	city  		VARCHAR2(25),
       	state 		VARCHAR2(2),
        	zip 		VARCHAR2(10),
     	status 		CHAR(1)		-- 'G' or 'B'
);

select count(*) from users;

CREATE TABLE sellers 
(	userID		NUMBER CONSTRAINT fk_sellers  
                        	REFERENCES users(userID) ON DELETE CASCADE,
	creditCardType 	VARCHAR2(10),
	creditCardNumber VARCHAR2(16),
	expiration 	VARCHAR2(6),
	bank 		VARCHAR2(20),
	accountNo 	VARCHAR2(25),
		CONSTRAINT pk_sellers PRIMARY KEY (userID) 
);

select count(*) from sellers;

create table buyers 
(   	userID 		NUMBER CONSTRAINT fk_buyers  
	                       REFERENCES users(userID) ON DELETE CASCADE,
	maxBidAmount 	NUMBER, 
		CONSTRAINT pk_buyers PRIMARY KEY (userID)
);

select count(*) from buyers;

CREATE TABLE items 
(	itemID 		NUMBER
		CONSTRAINT pk_items PRIMARY KEY, -- uses item_id sequence number
        name 		VARCHAR2(50),
        description 	VARCHAR2(64),
        openingPrice 	NUMBER(9,2),
        increase 	NUMBER(9,2),
        startingTime 	DATE,
        endingTime 	DATE,
        featured 	CHAR(1),	-- 'Y' or 'N'
        userID 		NUMBER CONSTRAINT fk_items
				REFERENCES sellers(userID) ON DELETE CASCADE 
);

select count(*) from items;

CREATE TABLE categories 
(	cID 		NUMBER 
		CONSTRAINT pk_categories PRIMARY KEY, -- uses category_id number
	name    	VARCHAR2(20),
	description 	VARCHAR2(128)
);

select count(*) from categories;

CREATE TABLE itemCategory 
(	
	cID 		NUMBER CONSTRAINT fk_itemcategory_cID 
				REFERENCES categories(cID) ON DELETE CASCADE,
	itemID 		NUMBER CONSTRAINT fk_itemcategory_itemID 
				REFERENCES items(itemID) ON DELETE CASCADE, 
          	CONSTRAINT pk_itemcategory PRIMARY KEY (cID, itemID)
);

select count(*) from itemcategory;

CREATE TABLE promotions 
(	
	itemID 		NUMBER 
	   CONSTRAINT fk_promotions REFERENCES items(itemID) ON DELETE CASCADE,
	startingTime 	DATE,
	endingTime 	DATE,
	salePrice	NUMBER(9,2),
		CONSTRAINT pk_promotions PRIMARY KEY (itemID,startingTime)
);

select count(*) from promotions;

CREATE TABLE bids 
(	
	userID 		NUMBER CONSTRAINT  fk_bids_userID 
		      		REFERENCES buyers(userID) ON DELETE CASCADE,
	itemID 		NUMBER CONSTRAINT fk_bids_itemID 
                            	REFERENCES items(itemID) ON DELETE CASCADE,
       	price 		NUMBER(9,2),
	timestamp 	DATE,
		CONSTRAINT pk_bids PRIMARY KEY (userID, itemID, price)
); 

select * from bids;

CREATE TABLE retractions 
( 	
	retractionTimestamp  DATE,
	userID 		NUMBER CONSTRAINT fk_retractions_userID 
				REFERENCES users(userID) ON DELETE CASCADE,
  	itemID 		NUMBER CONSTRAINT fk_retractions_itemID 
				REFERENCES items(itemID) ON DELETE CASCADE,
	reason 		VARCHAR2(128),
		CONSTRAINT pk_retractions PRIMARY KEY (retractionTimestamp, userId, itemID)
);

select count(*) from retractions;

CREATE TABLE sales 
( 	
	itemID 		NUMBER CONSTRAINT fk_sales_itemID 
				REFERENCES items(itemID) ON DELETE CASCADE,
	sellerUserID 	NUMBER CONSTRAINT fk_sales_sellerUserID
				REFERENCES sellers(userID) ON DELETE CASCADE,
   	buyerUserID 	NUMBER CONSTRAINT fk_sales_buyerUserID
				REFERENCES buyers(userID) ON DELETE CASCADE,
   	price 		NUMBER(9,2),
  	settlementdate 	DATE,
	  	CONSTRAINT pk_sales PRIMARY KEY (itemID)
);

select count(*) from sales;

select * from sales;

/*******************************STAR SCHEMA********************************/

--SELLER DIMENSION
CREATE TABLE SELLER_DIMENSION (

	userID		NUMBER PRIMARY KEY,
        creditCardType 	VARCHAR2(10),
	creditCardNumber VARCHAR2(16),
	expiration 	VARCHAR2(6),
	bank 		VARCHAR2(20),
	accountNo 	VARCHAR2(25));
    
insert into SELLER_DIMENSION select * from SELLERS;

select * from seller_dimension;

--USER DIMENSION
CREATE TABLE USER_DIMENSION
(     	userID 		NUMBER PRIMARY KEY,
	email 		VARCHAR2(50),
        lname 		VARCHAR2(20),
       	fname 		VARCHAR2(25),
       	state 		VARCHAR2(2),
        zip 		VARCHAR2(10),
     	status 		CHAR(1)		);

insert into USER_DIMENSION (userID,email,lname,fname,state,zip,status)
select userID,email,lname,fname,state,zip,status from USERS ;

select * from USER_DIMENSION;

--BUYER DIMENSION
create table BUYER_DIMENSION 
(   	userID 		NUMBER PRIMARY KEY,  
	    maxBidAmount 	NUMBER );
        
INSERT INTO BUYER_DIMENSION
SELECT * FROM BUYERS;

SELECT * FROM BUYER_DIMENSION;

--ITEM DIMENSION
CREATE TABLE ITEM_DIMENSION 
(	itemID 		NUMBER PRIMARY KEY,
        name 		VARCHAR2(50),
        description 	VARCHAR2(64),
        openingPrice 	NUMBER(9,2),
        increase 	NUMBER(9,2),
        startingTime 	DATE,
        endingTime 	DATE,
        featured 	CHAR(1),	
        userID 		NUMBER );
        
insert into ITEM_DIMENSION
select * from items;

SELECT * FROM ITEM_DIMENSION;

--PROMOTION DIMENSION
CREATE TABLE PROMOTION_DIMENSION 
(	
	itemID 		NUMBER null REFERENCES item_dimension(itemID) ,
	startingTime DATE,
	endingTime 	DATE,
	salePrice	NUMBER(9,2)); 
    
insert into PROMOTION_DIMENSION
select * from PROMOTIONS;

SELECT * FROM PROMOTION_DIMENSION;

--CATEGORY DIMENSION 
CREATE TABLE CATEGORY_DIMENSION 
(	cID 		NUMBER PRIMARY KEY, 
	name    	VARCHAR2(20),
	description 	VARCHAR2(128)
);

insert into CATEGORY_DIMENSION
select * from CATEGORIES;

SELECT * FROM CATEGORY_DIMENSION;

--ITEMCATEGORY DIMENSION 
CREATE TABLE ITEMCATEGORY_DIMENSION 
(	
	cID 		NUMBER 
				REFERENCES CATEGORY_DIMENSION(cID) ,
	itemID 		NUMBER 
				REFERENCES ITEM_DIMENSION(itemID) );
                
INSERT INTO ITEMCATEGORY_DIMENSION
SELECT * FROM ITEMCATEGORY

SELECT * FROM ITEMCATEGORY_DIMENSION;

--TIME DIMENSION
CREATE TABLE TIME_DIMENSION 
(	DATE_KEY 		NUMBER PRIMARY KEY,
        full_date 		DATE,
        day_num_in_month 	NUMBER,
        day_name 	VARCHAR2(200),
        weekday_flag 	VARCHAR2(200),
        BIDS_TIMESTAMP DATE,
        RETRACTION_TIMESTAMP DATE);

select * from time_dimension;

CREATE TABLE SALES_FACT (
USERID	   NUMBER REFERENCES USER_DIMENSION(USERID),
SELLERUSERID	   NUMBER REFERENCES SELLER_DIMENSION(USERID),
BUYERUSERID     NUMBER REFERENCES BUYER_DIMENSION(USERID),
ITEMID     NUMBER REFERENCES ITEM_DIMENSION(ITEMID),
DATE_KEY   NUMBER REFERENCES TIME_DIMENSION(DATE_KEY),
CID        NUMBER REFERENCES CATEGORY_DIMENSION(CID),
PRICE      NUMBER,
BIDPRICE NUMBER);

insert into SALES_FACT(USERID)
select USERID from USER_DIMENSION;

insert into SALES_FACT(SELLERUSERID)
select USERID from SELLER_DIMENSION;

insert into SALES_FACT(BUYERUSERID)
select USERID from BUYER_DIMENSION;

insert into SALES_FACT(ITEMID)
select ITEMID from ITEM_DIMENSION;

insert into SALES_FACT(DATE_KEY)
select DATE_KEY from TIME_DIMENSION;

insert into SALES_FACT(CID)
select CID from CATEGORY_DIMENSION;

insert into SALES_FACT(PRICE)
select PRICE from SALES;

insert into SALES_FACT(BIDPRICE)
select PRICE from BIDS;

---
/*INSERT INTO bid_sales_fact 
(price, buyer_userid, seller_userid, item_id, date_key, sales_flag)
(SELECT bid_price, buyer_userid, seller_userid, bid_item, date_key,
        DECODE (sales_price, NULL, 'N', 'Y')
FROM
(SELECT bid_price, buyer_userid, seller_userid, bid_item, date_key, s.price sales_price
FROM
(SELECT b.price bid_price, b.userid buyer_userid, i.userid seller_userid, b.itemid bid_item, t.date_key
FROM bids b, items i, time_dim t
WHERE b.itemid = i.itemid
AND b.timestamp = t.full_date) bid
LEFT OUTER JOIN sales s
ON (bid_item = s.itemid
AND bid_price = s.price)));*/


--1.Find the seller user id and buy user id such that the buyer has bought
--at least one item from the seller but the buyer and seller are located in different states.
SELECT SELLERS.USERID AS SellerUserIDBuyer, BUYERS.USERID AS BuyerUserIDBuyer
FROM SALES, BUYERS, SELLERS, USERS buyeruser
WHERE SALES.BUYERUSERID = BUYERS.USERID
AND SALES.SELLERUSERID = SELLERS.USERID
AND BUYERS.USERID = buyeruser.USERID
AND (SELLERS.USERID, BUYERS.USERID, buyeruser.STATE)  NOT IN 
             (SELECT SELLERS.USERID AS SellerUserIDSeller, 
                              BUYERS.USERID AS BuyerUserIDSeller, USERS.STATE AS SellerState
                FROM SALES, BUYERS, SELLERS, USERS
                WHERE SALES.BUYERUSERID = BUYERS.USERID
                AND SALES.SELLERUSERID = SELLERS.USERID
                AND SELLERS.USERID = USERS.USERID
                AND buyeruser.STATE = USERS.STATE);


--2.Find item name along with the seller id and buyer id such 
--that the seller has sold the item to the buyer.
SELECT SALES.SELLERUSERID, SALES.BUYERUSERID, ITEMS.NAME
FROM SALES, ITEMS 
WHERE SALES.ITEMID = ITEMS.ITEMID

--3.For each seller and each item sold by the seller, find the total amount sold.
SELECT USERS.EMAIL AS SellerEmail,SALES.SELLERUSERID,ITEMS.NAME AS Item,SUM(SALES.PRICE) AS AmountOfItemSold
FROM ITEMS, SELLERS, SALES, USERS
WHERE ITEMS.USERID = SELLERS.USERID
AND SALES.ITEMID = ITEMS.ITEMID
AND SALES.SELLERUSERID = SELLERS.USERID
AND SELLERS.USERID = USERS.USERID
GROUP BY ITEMS.NAME, USERS.EMAIL,SALES.SELLERUSERID;

--4.Find the top seller.
SELECT SELLEREMAIL AS TOP_SELLER,SELLERID
FROM ( SELECT USERS.EMAIL AS SELLEREMAIL,SELLERS.USERID as SELLERID, SUM(SALES.PRICE) AS TOTALSALES
              FROM SALES, SELLERS, USERS
              WHERE SALES.SELLERUSERID = SELLERS.USERID
              AND SELLERS.USERID = USERS.USERID
              GROUP BY USERS.EMAIL,SELLERS.USERID
              ORDER BY TOTALSALES DESC)
WHERE ROWNUM=1;

--5.Find the top buyer.
SELECT BUYEREMAIL AS TOP_BUYER
FROM (SELECT USERS.EMAIL AS BUYEREMAIL, SUM(SALES.PRICE) AS TOTALSALES
              FROM SALES, BUYERS, USERS
              WHERE SALES.BUYERUSERID = BUYERS.USERID
              AND BUYERS.USERID = USERS.USERID
              GROUP BY USERS.EMAIL
              ORDER BY TOTALSALES DESC)
WHERE ROWNUM=1

        
--CREATE INDEXES        
CREATE INDEX BUYERUSERID_I ON SALES(BUYERUSERID);
CREATE INDEX STATE_I ON USERS(STATE);
CREATE INDEX SELLERUSERID_I ON SALES(SELLERUSERID);
CREATE INDEX TOTALSALES_I ON SALES (PRICE);











