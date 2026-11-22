<?php

	//自定义报表sql
	Class cls_Report_Sql{
		
		public function __construct(){
			
		}
		//Direct项目汇总表 
		static function getDriectProjectSummaryReport(){
			$sql = "SELECT
				expenseid,
                po_no,
                subjectcode,
                subjectsummary,
                sum(rmb_tota) as rmb_tota,
				count(1) as cnt
            FROM (
                SELECT
					a.expenseid,
                    e.po_no,
                    b.expensetype,
                    CASE 
					WHEN length(ifnull(b.subjectcode,'')) <2 THEN '5121.00'
						ELSE b.subjectcode
					END AS subjectcode,
					CASE 
						WHEN length(ifnull(b.subjectsummary,'')) <2 THEN 'Direct' 
						ELSE b.subjectsummary
					END AS subjectsummary,
                    round(c.rmb_total,2) as rmb_tota
                FROM ld_expense a
                LEFT JOIN ld_expensedetail b on a.expenseid=b.expenseid
                LEFT JOIN ld_expensedetailscf c on b.expensedetailid=c.expensedetailid
                LEFT JOIN ld_users d ON d.id=a.smownerid
                LEFT JOIN ld_project e ON e.projectid=b.entitytypeid
                WHERE a.deleted=0 
                   
                    and ifnull(b.expensetype,'') not in ('finance only-uni cost','finance only-EH cost','finance only-trip')
                    and b.entitytype='Project' and b.entitytypeid>0 and c.timetype='Direct'
                    and ifnull(e.program,'') not in ('Innovation Kickstart','Local Funding')
                    and (select date_format(createdtime,'%Y-%m-%d') from ld_approvelog where crmid=a.expenseid order by id desc limit 1) BETWEEN ? and ?) a
            GROUP BY po_no,subjectcode,subjectsummary;";
            //echo $sql;
			return $sql;
		}

		//Direct项目汇总表明细
		public static function getDirectReportDetail(){
			$sql = "SELECT
				a.expenseid,
                d.last_name,
                b.Startdate,
                e.po_no,
                b.expensetype,
				CASE 
					WHEN length(ifnull(b.subjectcode,'')) <2 THEN '5121.00'
					ELSE b.subjectcode
				END AS subjectcode,
				CASE 
					WHEN length(ifnull(b.subjectsummary,'')) <2 THEN 'Direct' 
					ELSE b.subjectsummary
				END AS subjectsummary,
                round(c.rmb_total,2) as rmb_tota,
				b.expensedetailid
            FROM ld_expense a
            LEFT JOIN ld_expensedetail b on a.expenseid=b.expenseid
            LEFT JOIN ld_expensedetailscf c on b.expensedetailid=c.expensedetailid
            LEFT JOIN ld_users d ON d.id=a.smownerid
            LEFT JOIN ld_project e ON e.projectid=b.entitytypeid
            WHERE a.deleted=0 
                and a.approvestatus='已批准'
                and ifnull(b.expensetype,'') not in ('finance only-uni cost','finance only-EH cost','finance only-trip')
                and b.entitytype='Project' and b.entitytypeid>0 and c.timetype='Direct'
                and ifnull(e.program,'') not in ('Innovation Kickstart','Local Funding')
                and (select date_format(createdtime,'%Y-%m-%d') from ld_approvelog where crmid=a.expenseid order by id desc limit 1) BETWEEN ? and ?
            ORDER BY e.po_no,b.Startdate,d.last_name;";
			return $sql;
		}

		//InDirect 项目汇总表
		public static function getInDriectProjectSummaryReport(){
			//Eidtor:gyq_64M Reason:下拉框改进  Date:2018/3/16 0016 下午 3:59
			$sql = "SELECT
				expenseid,
				expensetype,
				po_no,
				subjectcode,
				subjectsummary,
				usercategory,
				CONCAT(subjectcode2,'/',subjectsummary2) AS subjectcode2,
				SUM(rmb_tota) AS rmb_tota,
				count(1) as cnt
			FROM (
				SELECT
					b.expensetype,
					CASE 
						WHEN length(ifnull(b.subjectcode,'')) <2 THEN '5142.02'
						ELSE b.subjectcode
					END AS subjectcode,
					CASE 
						WHEN length(ifnull(b.subjectsummary,'')) <2 THEN e.subjectsummary 
						ELSE b.subjectsummary
					END AS subjectsummary,
					d.usercategory,
					CASE
						WHEN length(ifnull(b.subjectcode2,''))>=2 THEN b.subjectcode2 
						WHEN length(ifnull(b.subjectcode,'')) <2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Operation' THEN concat(e.subjectcode,'.002') 
						WHEN length(ifnull(b.subjectcode,'')) <2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Engineer' THEN concat(e.subjectcode,'.003') 
						WHEN length(ifnull(b.subjectcode,'')) >=2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Operation' THEN concat(b.subjectcode,'.002') 
						WHEN length(ifnull(b.subjectcode,'')) >=2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Engineer' THEN concat(b.subjectcode,'.003')  
						ELSE '' 
					END AS subjectcode2,
					CASE
						WHEN length(ifnull(b.subjectsummary2,''))>=1 THEN b.subjectsummary2   
						WHEN d.usercategory='Operation' THEN 'Operation Dept.'
						WHEN d.usercategory='Engineer' THEN 'R&D Dept.'
						ELSE ''
					END AS subjectsummary2,
					round(c.rmb_total,2) as rmb_tota,
					a.expenseid,
					f.po_no
				FROM ld_expense a
				LEFT JOIN ld_expensedetail b on a.expenseid=b.expenseid
				LEFT JOIN ld_expensedetailscf c on b.expensedetailid=c.expensedetailid
				LEFT JOIN ld_users d ON d.id=a.smownerid

				LEFT JOIN (
              SELECT
                id ,listvalue,subjectsummary,subjectcode
              FROM ld_picklist_values
                LEFT JOIN ld_picklist_set
                  ON ld_picklist_set.listid = ld_picklist_values.listid
              WHERE listname = 'expensetype' AND relatetable = 'ld_field')
    AS e ON e.listvalue = b.expensetype

				WHERE a.deleted=0 
					and ifnull(a.approvestatus,'') = '已批准'
                    and ifnull(b.expensetype,'') not in ('finance only-uni cost','finance only-EH cost','finance only-trip')
					and c.timetype='Indirect'
					and (select date_format(createdtime,'%Y-%m-%d') from ld_approvelog where crmid=a.expenseid order by id desc limit 1) BETWEEN ? and ?
				UNION ALL
				SELECT
					b.expensetype,
					CASE 
						WHEN length(ifnull(b.subjectcode,'')) <2 THEN e.subjectcode 
						ELSE b.subjectcode
					END AS subjectcode,
					CASE 
						WHEN length(ifnull(b.subjectsummary,'')) <2 THEN e.subjectsummary 
						ELSE b.subjectsummary
					END AS subjectsummary,
					d.usercategory,
					CASE
						WHEN length(ifnull(b.subjectcode2,''))>=2 THEN b.subjectcode2 
						WHEN length(ifnull(b.subjectcode,'')) <2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Operation' THEN concat(e.subjectcode,'.002') 
						WHEN length(ifnull(b.subjectcode,'')) <2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Engineer' THEN concat(e.subjectcode,'.003') 
						WHEN length(ifnull(b.subjectcode,'')) >=2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Operation' THEN concat(b.subjectcode,'.002') 
						WHEN length(ifnull(b.subjectcode,'')) >=2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Engineer' THEN concat(b.subjectcode,'.003')  
						ELSE '' 
					END AS subjectcode2,
					CASE
						WHEN length(ifnull(b.subjectsummary2,''))>=1 THEN b.subjectsummary2   
						WHEN d.usercategory='Operation' THEN 'Operation Dept.'
						WHEN d.usercategory='Engineer' THEN 'R&D Dept.'
						ELSE ''
					END AS subjectsummary2,
					round(c.rmb_total,2) as rmb_tota,
					a.expenseid
				FROM ld_expense a
				LEFT JOIN ld_expensedetail b on a.expenseid=b.expenseid
				LEFT JOIN ld_expensedetailscf c on b.expensedetailid=c.expensedetailid
				LEFT JOIN ld_users d ON d.id=a.smownerid

				LEFT JOIN (
              SELECT
                id ,listvalue,subjectsummary,subjectcode
              FROM ld_picklist_values
                LEFT JOIN ld_picklist_set
                  ON ld_picklist_set.listid = ld_picklist_values.listid
              WHERE listname = 'expensetype' AND relatetable = 'ld_field')
    AS e ON e.listvalue = b.expensetype

                LEFT JOIN ld_project f ON f.projectid=b.entitytypeid
				WHERE a.deleted=0 
					and ifnull(a.approvestatus,'') = '已批准'
					and ifnull(b.expensetype,'') not in ('finance only-uni cost','finance only-EH cost','finance only-trip')
					and b.entitytype='Project' and b.entitytypeid>0 and c.timetype='Direct'
					and ifnull(f.program,'') in ('Innovation Kickstart','Local Funding')
					and (select date_format(createdtime,'%Y-%m-%d') from ld_approvelog where crmid=a.expenseid order by id desc limit 1) BETWEEN ? and ?) t
			GROUP BY expensetype,subjectcode,usercategory,subjectcode2
			ORDER BY subjectcode,expensetype,subjectcode2;";
            //echo $sql;;
			return $sql;
		}
		
		//InDirect 项目汇总明细表
		public static function getInDirectReportDetail(){
			//Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 4:00
			 $sql="SELECT * FROM (
					SELECT
						a.expenseid,
						b.expensedetailid,
						d.last_name,
						b.Startdate,
						b.description AS indirect,
						b.expensetype,
						CASE 
							WHEN length(ifnull(b.subjectcode,'')) <2 THEN e.subjectcode 
							ELSE b.subjectcode
						END AS subjectcode,
						CASE 
							WHEN length(ifnull(b.subjectsummary,'')) <2 THEN e.subjectsummary 
							ELSE b.subjectsummary
						END AS subjectsummary,
						d.usercategory,
						CASE 
							WHEN length(ifnull(b.subjectcode,'')) <2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Operation' THEN concat(e.subjectcode,'.002') 
							WHEN length(ifnull(b.subjectcode,'')) <2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Engineer' THEN concat(e.subjectcode,'.003') 
							WHEN length(ifnull(b.subjectcode,'')) >=2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Operation' THEN concat(b.subjectcode,'.002') 
							WHEN length(ifnull(b.subjectcode,'')) >=2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Engineer' THEN concat(b.subjectcode,'.003') 
							WHEN length(ifnull(b.subjectcode2,''))>=2 THEN b.subjectcode2 
							ELSE '' 
						END AS subjectcode2,
						CASE
							WHEN length(ifnull(b.subjectsummary2,''))>=1 THEN b.subjectsummary2 
							WHEN d.usercategory='Operation' THEN 'Operation Dept.'
							WHEN d.usercategory='Engineer' THEN 'R&D Dept.'
							ELSE ''
						END AS subjectsummary2,
						round(c.rmb_total,2) as rmb_tota
					FROM ld_expense a
					LEFT JOIN ld_expensedetail b on a.expenseid=b.expenseid
					LEFT JOIN ld_expensedetailscf c on b.expensedetailid=c.expensedetailid
					LEFT JOIN ld_users d ON d.id=a.smownerid


					LEFT JOIN (
              SELECT
                id ,listvalue,subjectsummary,subjectcode
              FROM ld_picklist_values
                LEFT JOIN ld_picklist_set
                  ON ld_picklist_set.listid = ld_picklist_values.listid
              WHERE listname = 'expensetype' AND relatetable = 'ld_field')
    AS e ON e.listvalue = b.expensetype

					WHERE a.deleted=0 
						and ifnull(a.approvestatus,'') = '已批准'
						and ifnull(b.expensetype,'') not in ('finance only-uni cost','finance only-EH cost','finance only-trip')
						and c.timetype='Indirect'
						and (select date_format(createdtime,'%Y-%m-%d') from ld_approvelog where crmid=a.expenseid order by id desc limit 1) BETWEEN ? and ?
					UNION ALL
					SELECT
						a.expenseid,
						b.expensedetailid,
						d.last_name,
						b.Startdate,
						b.description AS indirect,
						b.expensetype,
						CASE 
							WHEN length(ifnull(b.subjectcode,'')) <2 THEN e.subjectcode 
							ELSE b.subjectcode
						END AS subjectcode,
						CASE 
							WHEN length(ifnull(b.subjectsummary,'')) <2 THEN e.subjectsummary 
							ELSE b.subjectsummary
						END AS subjectsummary,
						d.usercategory,
						CASE 
							WHEN length(ifnull(b.subjectcode,'')) <2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Operation' THEN concat(e.subjectcode,'.002') 
							WHEN length(ifnull(b.subjectcode,'')) <2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Engineer' THEN concat(e.subjectcode,'.003') 
							WHEN length(ifnull(b.subjectcode,'')) >=2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Operation' THEN concat(b.subjectcode,'.002') 
							WHEN length(ifnull(b.subjectcode,'')) >=2 and length(ifnull(b.subjectcode2,''))<2 and d.usercategory='Engineer' THEN concat(b.subjectcode,'.003') 
							WHEN length(ifnull(b.subjectcode2,''))>=2 THEN b.subjectcode2 
							ELSE '' 
						END AS subjectcode2,
						CASE
							WHEN length(ifnull(b.subjectsummary2,''))>=1 THEN b.subjectsummary2 
							WHEN d.usercategory='Operation' THEN 'Operation Dept.'
							WHEN d.usercategory='Engineer' THEN 'R&D Dept.'
							ELSE ''
						END AS subjectsummary2,
						round(c.rmb_total,2) as rmb_tota
					FROM ld_expense a
					LEFT JOIN ld_expensedetail b on a.expenseid=b.expenseid
					LEFT JOIN ld_expensedetailscf c on b.expensedetailid=c.expensedetailid
					LEFT JOIN ld_users d ON d.id=a.smownerid


					LEFT JOIN (
              SELECT
                id ,listvalue,subjectsummary,subjectcode
              FROM ld_picklist_values
                LEFT JOIN ld_picklist_set
                  ON ld_picklist_set.listid = ld_picklist_values.listid
              WHERE listname = 'expensetype' AND relatetable = 'ld_field')
    AS e ON e.listvalue = b.expensetype

					LEFT JOIN ld_project f ON f.projectid=b.entitytypeid
					WHERE a.deleted=0 
						and ifnull(a.approvestatus,'') = '已批准'
						and ifnull(b.expensetype,'') not in ('finance only-uni cost','finance only-EH cost','finance only-trip')
						and b.entitytype='Project' and b.entitytypeid>0 and c.timetype='Direct'
						and ifnull(f.program,'') in ('Innovation Kickstart','Local Funding')
						and (select date_format(createdtime,'%Y-%m-%d') from ld_approvelog where crmid=a.expenseid order by id desc limit 1) BETWEEN ? and ?) T 
				ORDER BY subjectcode,subjectcode2,last_name,Startdate";
			return $sql;
		}

	}


?>