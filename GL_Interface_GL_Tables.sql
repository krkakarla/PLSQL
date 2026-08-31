------------------------------GL Details -------------------------------------------------------
select * from apps.GL_JE_HEADERS;

select * from apps.gl_je_categories;
--------------------------------------------FA Objects. ------------------

select * from all_objects 
where status != 'VALID' and OBJECT_NAME like 'HR_UTILITY%';
----------------------------------------GL Table Details ---------------------------------------
GL Table Details : 
	
select * from apps.gl_code_combinations where segment1 = '01' and Segment2 = '32' and segment3 = '12' 
and segment4 = '66' and segment5 = '160500' and segment6 = '000' and segment7 = '000';

---------------------------------------------Report Mapping Details------------------------------

select GM.to_segment_name, gr.parent_flex_value, gr.child_flex_value_low, gr.child_flex_value_high  from 
apps.GL_CONS_SEGMENT_MAP_V GM, apps.GL_CONS_ROLLUP_RANGES_V GR
where GM.to_segment_name = 'STATFR_ACCOUNT'   -------------Segment Name 
and gr.child_flex_value_high in ('219000','330500','118002','330500') --------
---('161100','181000','181110','180000','180120','180205','330500')
--------('320100','330100','330400','350110','330510')
and   gm.segment_map_id = gr.segment_map_id;

------------------------------------------GL Interface Table Data Insertion---------------------------
create or replace PACKAGE BODY xx_gl_interface_pkg AS
--Write to concurrent program log
    PROCEDURE write_to_log (
        message IN VARCHAR2
    ) AS
    BEGIN
        fnd_file.put_line(fnd_file.log, message);
    END write_to_log;

    PROCEDURE xx_gl_int_prc (
        errbuf        OUT VARCHAR2,
        retcode       OUT NUMBER,
        p_from_date   IN VARCHAR2,
        p_to_date     IN VARCHAR2,
        p_from_ledger IN NUMBER,
        p_to_ledger   IN NUMBER,
        p_j_header_id IN NUMBER,
        p_conv_type   IN VARCHAR2,
        p_je_source_name IN VARCHAR2,
		p_je_category IN VARCHAR2,
        p_je_currency IN VARCHAR2
    ) AS

        v_requestid   NUMBER;
        itotalrecords NUMBER := 0;
        nConvertedDR  NUMBER := 0;
        nConvertedCR  NUMBER := 0;
        nAccountedDR  NUMBER := 0;
        nAccountedCR  NUMBER := 0;
        nSumAccoutnedDr NUMBER := 0;
        nSumAccountedCr NUMBER := 0;
        vJournalName  gl_interface.reference4%type;
        nDiffAmt NUMBER := 0; 

        CURSOR cur_gl_data IS
        SELECT
            gjh.ledger_id,
            gjh.default_effective_date accounting_date,
            gjh.default_effective_date currency_conv_date,
            xal.currency_conversion_Date sla_currency_conv_date,
            gjh.currency_code,
            gj.user_je_category_name,
            gs.user_je_source_name,
            gjh.default_effective_date,
            gjb.name                                        batch_name,
            gjh.name||'-'||gjh.je_header_id                     journal_name,
            gjh.je_header_id                                je_header_id,
            gjh.description                                 head_description,
	            gjl.description                                 line_description,
            gjl.code_combination_id,
            gjl.entered_dr,
            gjl.entered_cr,
            gjl.accounted_dr,
            gjl.accounted_cr,
            gjl.reference_6,
            gjl.reference_7,
            gjl.reference_8,
            gjl.reference_9,
            gjl.gl_sl_link_id,
            gjl.gl_sl_link_table
        FROM
            gl_je_batches    gjb,
            gl_je_headers    gjh,
            gl_je_lines      gjl,
            gl_je_sources    gs,
            gl_je_categories gj,
            xla_ae_lines     xal
        WHERE
                gjb.je_batch_id = gjh.je_batch_id
            AND gjh.je_header_id = gjl.je_header_id
            and gjl.gl_sl_link_id = xal.gl_sl_link_id (+)
            AND gjh.je_category = gj.je_category_name
            AND gjh.je_source = gs.je_source_name
            AND gjh.je_source <> 'Revaluation'
            AND gjh.je_header_id = nvl(p_j_header_id, gjh.je_header_id)
            AND gjh.default_effective_date
                BETWEEN NVL(TO_DATE(p_from_date, 'YYYY/MM/DD HH24:MI:SS'),gjh.default_effective_date-1)
                    AND nvl(TO_DATE(p_to_date, 'YYYY/MM/DD HH24:MI:SS'), gjh.default_effective_date+1)
            AND gjh.ledger_id = p_from_ledger
            AND gs.user_je_source_name = nvl(p_je_source_name,gs.user_je_source_name)
			AND gj.user_je_category_name = nvl(p_je_category,gj.user_je_category_name)
            AND gjh.currency_code = nvl(p_je_currency,gjh.currency_code)
            AND not exists
            (select 1 from gl_je_headers gjht
            where gjht.ledger_id = p_to_ledger
            and gjht.external_reference = to_char(gjh.je_header_id)
            and gjht.period_name = gjh.period_name
            )
            ;

        CURSOR gl(requestid NUMBER) IS
        SELECT DISTINCT reference4, group_id
          FROM gl_interface
         WHERE GROUP_ID = requestid;


    BEGIN
        v_requestid := fnd_global.conc_request_id;

        write_to_log('Processing Data');

        FOR i IN cur_gl_data LOOP

            If i.ledger_id = 2026 and i.currency_code <> 'CNY' and
              ( (i.entered_dr = i.accounted_dr and nvl(i.entered_dr,0) > 0.01)
                 OR
                (i.entered_cr = i.accounted_cr and nvl(i.entered_cr,0) > 0.01))
            Then
               Begin
                 SELECT ROUND((i.entered_dr * gdr.conversion_rate), 2),
                        ROUND((i.entered_cr * gdr.conversion_rate), 2)
                   INTO nAccountedDR, nAccountedCR
                   FROM apps.gl_daily_rates gdr
                  WHERE gdr.conversion_type = p_conv_type
                    AND gdr.from_currency = 'CNY'
                    AND gdr.to_currency = 'USD'
                    AND gdr.conversion_date = nvl(i.sla_currency_conv_date,i.currency_conv_date);

               nConvertedDR := nAccountedDR;
               nConvertedCR := nAccountedCR;
               Exception
                 WHEN NO_DATA_FOUND THEN write_to_log('No conversion rate found for accounted DR/CR');
                 WHEN TOO_MANY_ROWS THEN write_to_log('Multiple conversion rates found for accounted DR/CR');
                 WHEN OTHERS THEN write_to_log('Unknown Error while fetching accounted DR/CR: '||SQLERRM);
               End;
            Else
               If i.currency_code = 'USD' Then
                  nAccountedDR := i.entered_dr;
                  nAccountedCR := i.entered_cr;
                  nConvertedDR := i.entered_dr;
                  nConvertedCR := i.entered_cr;
               Else 
               begin
                 SELECT ROUND((i.entered_dr * gdr.conversion_rate), 2),
                        ROUND((i.entered_cr * gdr.conversion_rate), 2)
                   INTO nAccountedDR, nAccountedCR
                   FROM apps.gl_daily_rates gdr
                  WHERE gdr.conversion_type = p_conv_type
                    AND gdr.from_currency = i.currency_code
                    AND gdr.to_currency = 'USD'
                    AND gdr.conversion_date = nvl(i.sla_currency_conv_date,i.currency_conv_date);

                 If i.currency_code = 'CNY' Then
                    nConvertedDR := i.entered_dr;
                    nConvertedCR := i.entered_cr;
                 Else
                   SELECT ROUND((nAccountedDR * gdr.conversion_rate), 2),
                          ROUND((nAccountedCR * gdr.conversion_rate), 2)
                     INTO nConvertedDR, nConvertedCR
                     FROM apps.gl_daily_rates gdr
                    WHERE gdr.conversion_type = p_conv_type
                      AND gdr.from_currency = 'USD'
                      AND gdr.to_currency = i.currency_code
                      AND gdr.conversion_date = nvl(i.sla_currency_conv_date,i.currency_conv_date);               
                End If;
               Exception
                 WHEN NO_DATA_FOUND THEN write_to_log('No conversion rate found for accounted DR/CR');
                 WHEN TOO_MANY_ROWS THEN write_to_log('Multiple conversion rates found for accounted DR/CR');
                 WHEN OTHERS THEN write_to_log('Unknown Error while fetching accounted DR/CR: '||SQLERRM);
               End; 
               End If;
            End If;


            INSERT INTO gl_interface (
                status,
                ledger_id,
                accounting_date,
                currency_code,
                date_created,
                created_by,
                actual_flag,
                user_je_category_name,
                user_je_source_name,
                user_currency_conversion_type,
                currency_conversion_date,
                currency_conversion_rate,
                reference1,
                reference4,
                reference5,
                reference6,
                reference7,
                reference8,
                reference9,
                reference10,
                code_combination_id,
                entered_dr,
                entered_cr,
                accounted_dr,
                accounted_cr,
                gl_sl_link_id,
                gl_sl_link_table,
                group_id
            ) VALUES (
                'NEW',
                p_to_ledger,
                i.accounting_date,
                i.currency_code,
                sysdate,
                - 1,
                'A',
                i.user_je_category_name,
                i.user_je_source_name,
                'User',
                i.currency_conv_date,
                1,
                i.batch_name,
                i.journal_name,
                i.head_description,
                i.je_header_id,
                NULL,
                NULL,
                NULL,
                i.line_description,
                i.code_combination_id,
                nConvertedDR,
                nConvertedCR,
                nAccountedDR,
                nAccountedCR,
                i.gl_sl_link_id,
                i.gl_sl_link_table,
                v_requestid
            );

            itotalrecords := itotalrecords + 1;
        END LOOP;
        COMMIT;

        write_to_log('Total Lines Processed ' || itotalrecords);


       FOR j IN gl(v_requestid) LOOP
         BEGIN
           SELECT reference4, SUM(accounted_dr), SUM(accounted_cr)
             INTO vJournalName, nSumAccoutnedDr, nSumAccountedCr
             FROM gl_interface a
            WHERE 1 = 1
              AND reference4 = j.reference4
              AND group_id = j.group_id
           GROUP BY reference4;

           nDiffAmt := nSumAccoutnedDr - nSumAccountedCr;
           IF NVL(nDiffAmt, 0) <> 0
               THEN
                 UPDATE gl_interface
                    SET accounted_dr = accounted_dr - nDiffAmt
                  WHERE reference4 = vJournalName
                    AND accounted_dr > -1 * nDiffAmt
                    AND rownum = 1 ;
           END IF;
         EXCEPTION
         WHEN OTHERS THEN 
           write_to_log ('Unknown error while updating records in gl_interface: '||SQLERRM);
         END;

       END LOOP;

       COMMIT;
     write_to_log('END xx_gl_int_prc');
    EXCEPTION
        WHEN OTHERS THEN
            write_to_log('Exception Raised ' || sqlerrm);
            retcode := 2;
    END xx_gl_int_prc;
END xx_gl_interface_pkg;
---------------------------------------GL Interface Details------------------------------------------------
