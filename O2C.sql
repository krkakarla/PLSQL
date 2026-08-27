Order Management Tables; 
Initiatlly Data will be send to Interface table 

  Header Table : 
  
  For service sector like travel company generate the orders and send the order details to custom table => 
Ex: 
Header Table:  xxexp_om_oms_ord_hdr_t 
Lines table : xxexp_om_oms_ord_line_t

Data will send to Interface table. 

OE_ORDER_HEADERS_ALL and 
OE_ORDER_LINES_ALL.

After that we have to run the process for send the data to base table. 
  
1) Auto Invoice Master Program 

----Data will move the Oracle transaction Table -------
  	
SELECT                   *          FROM       RA_CUSTOMER_TRX_ALL WHERE TRX_NUMBER = ''
SELECT                   *          FROM       RA_CUSTOMER_TRX_LINES_ALL WHERE CUSTOMER_TRX_ID = '756712';
SELECT EVENT_ID            FROM       RA_CUST_TRX_LINE_GL_DIST_ALL WHERE CUSTOMER_TRX_ID = '756712'; 

Sub ledger Accounting will happen. 

SELECT * FROM XLA_EVENTS WHERE EVENT_ID = '3318729' STATUS IS UNPOSTED. 
SELECT * FROM XLA_AE_HEADERS WHERE EVENT_ID = '3318729'; 

We can see this details only after create accounting is completed. 

SELECT * FROM XLA_AE_LINES WHERE AE_HEADER_ID = '4945976';

Sub Ledger to GL INTERFACE TABLE 

SELECT * FROOM GL_INTERFACE WHERE REFERENCE26 = '3318729';
Finally data will go to GL TABLES: 

SELECT * FROM GL_JE_BATCHES WHERE NAME = 'Receivable A 1546007 ';
SELECT * FROM GL_JE_HEADERS WHERE JE_BATCH_ID = '2927184';
SELECT * FROM GL_JE_LINES WHERE HE_HEADER_ID = '' Status U It means data not posted. 
  
----------------Receipt Table ---------------------

Receipt Table Details:

SELECT * FROM AR_CASH_RECEIPTS_ALL WHERE RECEIPT_NUMBER LIKE 'RECEIPT_663976'
SELECT * FROM AR_CASH_RECEIPT_HISTORY_ALL WHERE CASH_RECEIPT_ID = '109991'
SELECT * FROM AR_RECEIVABLE_APPLICATIONS_ALL WHERE CASH_RECEIPT_ID = '109991'
SELECT * FROM AR_PAYMENT_SCHEDULES_ALL WHERE CASH_RECEIPT_ID = '109991' REMAINING AMOUNT WE YOU CAN ABLE TO SEE 
SELECT EVENT_ID FROM AR_CASH_RECEIPT_HISTORY_ALL WHERE CASH_RECEIPT_ID = '109991'

  II.	Sub Ledger Journal Details : 

SELECT * FROM XLA_EVENTS WHERE EVENT_ID ='3318731';
SELECT * FROM  XLA_AE_HEADERS WHERE EVENT_ID  ='3318731';

We can see these details only after create accounting program completed. 
  
SELECT * FROM XLA_AE_LINES WHERE AE_HEADER_ID = '4945977';
SELECT * FROM GL_INTERFACE WHERE REFERENCE26 = '3318731'

III.	GL Ledger: 
SELECT * FROM GL_JE_BATCHES WHERE NAME = 'Receivable A 1546007 ';
SELECT * FROM GL_JE_HEADERS WHERE JE_BATCH_ID = '2927184';
SELECT * FROM GL_JE_LINES WHERE HE_HEADER_ID = '' Status U It means data not posted. 

-----------Data Moved to Oracle Gl Table. ------------

CRS ChRM Import Tables. 
Once Orders are available at OMS Order Table then we will submit “EXPD CRS EAC Order ChRM Import and Commission Daily Request Set” 
Once Program completed then program will send the data to below table. 
1)	ozf_funds_utilized_all_b
2)	ozf_funds_untilized_all_b 
XXEXPD_OZF_COMM_EXPORT_T

  
