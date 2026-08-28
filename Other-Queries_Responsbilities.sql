-----Finding Concurrent Program Details. --------------
SELECT *
  FROM fnd_concurrent_requests          fcr,
       fnd_concurrent_programs_tl       fcpt
WHERE     fcr.concurrent_program_id = fcpt.concurrent_program_id
       AND fcr.program_application_id = fcpt.application_id
       AND ARGUMENT_TEXT LIKE  '%226425%'
       AND fcpt.user_concurrent_program_name LIKE '%Format%Payment%Instructions%with%Text%Output%';
----Query 2 -------------------------------------------
SELECT
  distinct user_concurrent_program_name, fcp.concurrent_program_id
/* responsibility_name,
  request_date,
  argument_text,
  request_id,
  phase_code,
  status_code,
  logfile_name,
  outfile_name,
  output_file_type,
  hold_flag,
  user_name */
FROM
  fnd_concurrent_requests fcr,
  fnd_concurrent_programs_tl fcp,
  fnd_responsibility_tl fr,
  fnd_user fu
WHERE
  fcr.CONCURRENT_PROGRAM_ID = fcp.concurrent_program_id
-- and fcp.concurrent_program_id = '431359'
  and fcr.responsibility_id = fr.responsibility_id
-- and argument_text like '%ENCRYPT%BAML%'
--  and TO_CHAR(request_date,'DD-MON-YY') = '14-MAR-22'
  and fcr.requested_by = fu.user_id
  --and user_name = upper('HIMSINGH')
  and user_concurrent_program_name like '%EXPD AP Vendor Interface to LSM%';

---------------Concurrent Program Inputs-----------------

SELECT fcpt.user_concurrent_program_name Input_Program,
            (SELECT fcpt1.user_concurrent_program_name Incompatible_Programs
                FROM fnd_concurrent_programs_tl   fcpt1
             WHERE fcpt1.concurrent_program_id in (fcps.to_run_concurrent_program_id)
                  AND rownum = 1) Incompatible_Programs
   FROM fnd_concurrent_program_serial fcps
            ,fnd_concurrent_programs_tl       fcpt
WHERE fcps.running_concurrent_program_id = fcpt.concurrent_program_id
     AND fcpt.user_concurrent_program_name like 'EXPD CPAY AWS KMS Encryption Decryption Wrapper';
---------------------

------------Concurrent Program Details ----------------
SELECT
  distinct user_concurrent_program_name,
  responsibility_name,
  request_date,
  argument_text,
  request_id,
  phase_code,
  status_code,
  logfile_name,
  outfile_name,
  output_file_type,
  hold_flag,
  user_name
FROM
  fnd_concurrent_requests fcr,
  fnd_concurrent_programs_tl fcp,
  fnd_responsibility_tl fr,
  fnd_user fu
WHERE
  fcr.CONCURRENT_PROGRAM_ID = fcp.concurrent_program_id
  and fcp.concurrent_program_id = '431359'
  and fcr.responsibility_id = fr.responsibility_id
  and argument_text like '%ENCRYPT%BAML%'
  and TO_CHAR(request_date,'DD-MON-YY') = '14-MAR-22'
  and fcr.requested_by = fu.user_id
  --and user_name = upper('HIMSINGH')
  --and user_concurrent_program_name in
--('Active Users')
  --and Phase_code='P'
ORDER BY REQUEST_DATE DESC;
-------------------------------------
----------------Responsibility Name -------------
SELECT frt.responsibility_name, frg.request_group_name,
     frgu.request_unit_type,frgu.request_unit_id,
     fcpt.user_concurrent_program_name
     FROM fnd_Responsibility fr, fnd_responsibility_tl frt,
     fnd_request_groups frg, fnd_request_group_units frgu,
     fnd_concurrent_programs_tl fcpt
     WHERE frt.responsibility_id = fr.responsibility_id
     AND frg.request_group_id = fr.request_group_id
     AND frgu.request_group_id = frg.request_group_id
     AND fcpt.concurrent_program_id = frgu.request_unit_id
     AND frt.LANGUAGE = USERENV('LANG')
     AND fcpt.LANGUAGE = USERENV('LANG')
     AND fcpt.user_concurrent_program_name = 'EXPD Claims Autopay Program'
     ORDER BY 1,2,3,4;
------------
--------------------------Supplier and Supplier bank Account Details. -----------------
SELECT distinct vendor_name, VENDOR_SITE_CODE --vendor_name,
FROM ap.ap_suppliers aps,
ap.ap_supplier_sites_all apss,
apps.iby_ext_bank_accounts ieba,
apps.iby_account_owners iao,
apps.iby_ext_banks_v ieb,
apps.iby_ext_bank_branches_v iebb
WHERE aps.vendor_id = apss.vendor_id
and iao.account_owner_party_id = aps.party_id
and ieba.ext_bank_account_id = iao.ext_bank_account_id
and ieb.bank_party_id = iebb.bank_party_id
and ieba.branch_id = iebb.branch_party_id
and ieba.bank_id = ieb.bank_party_id
and ieba.ext_bank_account_id is not null
and ieba.COUNTRY_CODE = apss.COUNTRY
and ieba.country_code = 'BG'
and apss.Pay_site_FLAG ='Y'
and apss.HOLD_ALL_PAYMENTS_FLAG = 'N'
and apss.attribute_category = 'MER'
and apss.ORG_ID = '223'
and (INACTIVE_DATE is null or INACTIVE_DATE >= trunc(sysdate) )
--and aps.VAT_REGISTRATION_NUM IS NULL
--and ieba.CHECK_DIGITS is not null;
and apss.VENDOR_SITE_CODE like '%E'
and apss.INVOICE_CURRENCY_CODE = 'BGN';
----------------------------------------------------
--------------Supplier Details-------------------
SELECT d.INVOICE_ID, d.INVOICE_NUM, e.BATCH_NAME, d.PAY_GROUP_LOOKUP_CODE, d.INVOICE_AMOUNT, d.INVOICE_CURRENCY_CODE, d.INVOICE_DATE,
g.VENDOR_NAME, g.SEGMENT1, d.TERMS_ID
FROM IBY_PAYMENTS_ALL a, AP_CHECKS_ALL b, AP_INVOICE_PAYMENTS_ALL c, AP_INVOICES_ALL d, AP_BATCHES_ALL e, AP_Suppliers g
WHERE 1=1
and a.PAYMENT_ID = b.PAYMENT_ID
and b.CHECK_ID = c.CHECK_ID
and c.INVOICE_ID = d.INVOICE_ID
and d.BATCH_ID = e.BATCH_ID
and d.VENDOR_ID = g.VENDOR_ID
and a.INT_BANK_ACCOUNT_NAME IN ('BOA USD 7369 11105') 
--and a.PAYMENT_CURRENCY_CODE = 'EUR'
and d.PAYMENT_METHOD_CODE = 'EFT'
---and d.INVOICE_AMOUNT >= '100.00'
ORDER BY a.CREATION_DATE DESC;


SELECT d.INVOICE_ID, d.INVOICE_NUM, e.BATCH_NAME, d.PAY_GROUP_LOOKUP_CODE, d.INVOICE_AMOUNT, d.INVOICE_CURRENCY_CODE, d.INVOICE_DATE,
g.VENDOR_NAME, g.SEGMENT1, d.TERMS_ID
FROM IBY_PAYMENTS_ALL a, AP_CHECKS_ALL b, AP_INVOICE_PAYMENTS_ALL c, AP_INVOICES_ALL d, AP_BATCHES_ALL e, AP_Suppliers g
WHERE 1=1
and a.PAYMENT_ID = b.PAYMENT_ID
and b.CHECK_ID = '3327187'
and c.INVOICE_ID = d.INVOICE_ID
and d.BATCH_ID = e.BATCH_ID
and d.VENDOR_ID = g.VENDOR_ID;

SELECT count(1), PAY_GROUP_LOOKUP_CODE
FROM IBY_PAYMENTS_ALL a, AP_CHECKS_ALL b, AP_INVOICE_PAYMENTS_ALL c, AP_INVOICES_ALL d
WHERE 1=1
and a.PAYMENT_ID = b.PAYMENT_ID
and b.CHECK_ID = '3327187'
and b.CHECK_NUMBER = '1000714905'
and c.INVOICE_ID = d.INVOICE_ID
GROUP BY PAY_GROUP_LOOKUP_CODE ;

ELECT PAY_GROUP_LOOKUP_CODE, count(*), a.VENDOR_ID  FROM ap_invoices_all a where invoice_id in
(SELECT invoice_id FROM ap_invoice_payments_all where check_id = 3327187 and org_id = 223
)
group by PAY_GROUP_LOOKUP_CODE, VENDOR_ID;
--having PAY_GROUP_LOOKUP_CODE <> 'LVP'

SELECT 193396/2 FROM dual;

-------------Supplier Details --------

SELECT d.INVOICE_ID, d.INVOICE_NUM, e.BATCH_NAME, d.PAY_GROUP_LOOKUP_CODE, d.INVOICE_AMOUNT, d.INVOICE_CURRENCY_CODE, d.INVOICE_DATE,
g.VENDOR_NAME, g.SEGMENT1, d.TERMS_ID
FROM IBY_PAYMENTS_ALL a, AP_CHECKS_ALL b, AP_INVOICE_PAYMENTS_ALL c, AP_INVOICES_ALL d, AP_BATCHES_ALL e, AP_Suppliers g
WHERE 1=1
and a.PAYMENT_ID = b.PAYMENT_ID
and b.CHECK_ID = c.CHECK_ID
and c.INVOICE_ID = d.INVOICE_ID
and d.BATCH_ID = e.BATCH_ID
and d.VENDOR_ID = g.VENDOR_ID
and a.INT_BANK_ACCOUNT_NAME IN ('BOA USD 7369 11105') 
--and a.PAYMENT_CURRENCY_CODE = 'EUR'
and d.PAYMENT_METHOD_CODE = 'EFT'
---and d.INVOICE_AMOUNT >= '100.00'
ORDER BY a.CREATION_DATE DESC;


SELECT d.INVOICE_ID, d.INVOICE_NUM, e.BATCH_NAME, d.PAY_GROUP_LOOKUP_CODE, d.INVOICE_AMOUNT, d.INVOICE_CURRENCY_CODE, d.INVOICE_DATE,
g.VENDOR_NAME, g.SEGMENT1, d.TERMS_ID
FROM IBY_PAYMENTS_ALL a, AP_CHECKS_ALL b, AP_INVOICE_PAYMENTS_ALL c, AP_INVOICES_ALL d, AP_BATCHES_ALL e, AP_Suppliers g
WHERE 1=1
and a.PAYMENT_ID = b.PAYMENT_ID
and b.CHECK_ID = '3327187'
and c.INVOICE_ID = d.INVOICE_ID
and d.BATCH_ID = e.BATCH_ID
and d.VENDOR_ID = g.VENDOR_ID;

SELECT count(1), PAY_GROUP_LOOKUP_CODE
FROM IBY_PAYMENTS_ALL a, AP_CHECKS_ALL b, AP_INVOICE_PAYMENTS_ALL c, AP_INVOICES_ALL d
WHERE 1=1
and a.PAYMENT_ID = b.PAYMENT_ID
and b.CHECK_ID = '3327187'
and b.CHECK_NUMBER = '1000714905'
and c.INVOICE_ID = d.INVOICE_ID
GROUP BY PAY_GROUP_LOOKUP_CODE ;

