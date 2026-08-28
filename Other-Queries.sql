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

-------------
