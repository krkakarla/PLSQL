////Invoice Details Table. 
We can see invoices details at below table however the transaction accounting details available at XLA event Level. 
1.	select * from ap_invoices_all;
2.	select * from ap_invoice_lines_all;
3.	select * from ap_invoice_distributions_all where  Invoice_id = '108335958'; => Here we get accounting_event_id information.
II.	Sub Ledger Journals Details.
4.	select * from XLA_EVENTS WHERE EVENT_ID = '5339125904';
5.	select * from xla_ae_headers where event_id = '5339125904';
6.	select * from xla_ae_lines where ae_header_id = '5330865516';

III.	GL Ledger: 
SELECT * FROM GL_JE_BATCHES WHERE NAME = 'Payable  % ';
SELECT * FROM GL_JE_HEADERS WHERE JE_BATCH_ID = '2927184';
SELECT * FROM GL_JE_LINES WHERE HE_HEADER_ID = '' Status U It means data not posted. 
Technical Table Payment Details 
Before we make payment then we will get the invoices details at below table.
This is Journal entry after making the payment. 
S.No	Particulars	Debit 	Credit
1	Account Payable  A/C 	XXXXX	
	      To Bank Account or Cash in Transit Account A/C		XXXXXX
	(Being Make bank transfer) 		
  
Payment 
1.	select * from ap_payment_schedules_all where INVOICE_ID = '108335958';
2.	select * from ap_invoice_payments_all where INVOICE_ID = '108335958';
3.	select * from ap_checks_all where check_id = '12768998';
4.	select payment_id from ap_checks_all where check_id = '12768998';
5.	select * from iby_docs_payable_all where payment_id = '13955877';
6.	select * from iby_pay_service_requests;
7.	select * from iby_payments_all where payment_id = '13955877';
8.	select * from iby_pay_service_requests where payment_service_request_id = '279390'
Payment Sub ledger Accounting 
7.	select accounting_event_id from ap_invoice_payments_all where INVOICE_ID = '108335958';
8.	select * from xla_events where EVENT_ID = '5339125905';
9.	select * from xla_ae_headers where EVENT_ID = '5339125905';
10.	select * from xla_ae_lines where ae_header_id = '5330865517';
