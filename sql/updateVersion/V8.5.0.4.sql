DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF IFNULL(tmp_defaultvalue,'')='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
	END IF;

end ||
delimiter;

set @tabid = (select tabid from ld_tab where `name`='SendCashBill');
update ld_relatedlists set type = 'sendcashbillsourcebill_datacategory_sql' and related_coltable='tmp_related_cashbill.entitytypeid' 
where related_tabid=@tabid and type = 'entitytype_datacategory_sql' and related_coltable='tmpsourcedetail.id' and tabid in (select option_tabid from ld_option_module where tabid=@tabid);
set @tabid = (select tabid from ld_tab where `name`='CashBill');
update ld_relatedlists set type = 'cashbillsourcebill_datacategory_sql' and related_coltable='tmp_related_cashbill.entitytypeid' 
where related_tabid=@tabid and type = 'entitytype_datacategory_sql' and related_coltable='tmpsourcedetail.id' and tabid in (select option_tabid from ld_option_module where tabid=@tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','IMPORTNODATAERROR','模板文件中没有数据，导入失败！','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'IMPORTNODATAERROR' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','IMPORTNODATAERROR','There is no data in the template file,import failed!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'IMPORTNODATAERROR' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMMONLEADS','普通销售线索','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='COMMONLEADS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMMONLEADS','Common Lead','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMONLEADS' and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PRIVACYPOLICY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'隐私政策','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Privacy Policy','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CRMADDRESS','crm地址','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CRMADDRESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CRMADDRESS','crm address','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CRMADDRESS' and Labeltype = 'fixedstr');
delimiter;

CALL AddColumn('ld_organizationdetails','crm_address','varchar','255',null);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ORGANIZATIONSETTINGSREMIND01','CRM地址请参照此格式输入：http://www.51mis.com/crm','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ORGANIZATIONSETTINGSREMIND01' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ORGANIZATIONSETTINGSREMIND01','Please enter CRM URL according to the example, example: http://www.51mis.com/crm','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ORGANIZATIONSETTINGSREMIND01' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','publiccountresult1','公海未分配','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='publiccountresult1' and Labeltype='fixedstr');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','publiccountresult1','No distribution','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='publiccountresult1' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','publiccountresult2','公海已分配','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='publiccountresult2' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','publiccountresult2','Distribution','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='publiccountresult2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approveresult0','未提交','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='approveresult0' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','approveresult0','Not Submitted','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='approveresult0' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approveresult1','审批中','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='approveresult1' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','approveresult1','Approving','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='approveresult1' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approveresult2','已批准','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='approveresult2' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','approveresult2','Approved','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='approveresult2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approveresult3','已拒绝','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='approveresult3' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','approveresult3','Rejected','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='approveresult3' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approveresult4','已驳回','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='approveresult4' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','approveresult4','Dismissed','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='approveresult4' and Labeltype='fixedstr');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewServiceContractsCount' limit 1 ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:contract_status:contract_status:ServiceContracts_fieldlabel:V','n','已作废' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:contract_status:contract_status:ServiceContracts_%') ;

select  id into @homestuffdetailid from  ld_homestuffdetail where  stufflabel='NewServiceContractsAmount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:contract_status:contract_status:ServiceContracts_fieldlabel:V','n','已作废' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:contract_status:contract_status:ServiceContracts_%') ;

select  id into @homestuffdetailid from  ld_homestuffdetail where  stufflabel='NewSalesOrderAmount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:sostatus:sostatus:SalesOrder_fieldlabel:V','n','已作废' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:sostatus:sostatus:SalesOrder_%') ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Datebasis','日期依据','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Datebasis' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Datebasis','Date basis','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Datebasis' and Labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TIMERANGE','时间范围','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TIMERANGE' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TIMERANGE','Time range','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TIMERANGE' and Labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Auditstatus','审核状态','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Auditstatus' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Auditstatus','Audit status','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Auditstatus' and Labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel='普通{$Leads.Leads}' where labelbol='COMMONLEADS'  and languagetype='zh' and Labeltype='fixedstr';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_relatedlists_reminds`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_relatedlists_reminds`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	
	DECLARE MYCUSOR CURSOR FOR 
		SELECT
			a.tabid
		FROM ld_tab a
		LEFT JOIN ld_relatedlists b ON b.`name`='get_reminds' AND b.tabid=a.tabid
		WHERE b.related_tabid IS NULL
			AND a.tabid IN (SELECT DISTINCT tabid FROM ld_field WHERE columnname='smownerid')
		ORDER BY a.tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @tabid=tmp_tabid;
		SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
		SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);

		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
		SELECT @relation_id+1,@tabid,61,'get_reminds',@seq+1,'Reminds',0,'','datacategory_sql','reminds.related_to' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=61);

		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

		FETCH MYCUSOR INTO tmp_tabid;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_add_relatedlists_reminds();
DROP PROCEDURE IF EXISTS `ldcrm_add_relatedlists_reminds`;
-- 2023-06-05


SET @disable_triggers=NULL;
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
UPDATE ld_customview_seq SET id = (SELECT MAX(cvid) FROM ld_customview);
UPDATE ld_links_seq SET id=(SELECT MAX(linkid) FROM ld_links);
UPDATE ld_picklist_dependency_seq SET id=(SELECT MAX(id) FROM ld_picklist_dependency);
UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
UPDATE ld_approve_seq SET id=(SELECT MAX(id) FROM ld_approve);
UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);
UPDATE ld_autotask_seq SET id = (SELECT MAX(autotaskid) FROM ld_autotask);
UPDATE ld_currency_info_seq SET id=(SELECT MAX(id) FROM ld_currency_info);
UPDATE ld_users_seq SET id=(SELECT MAX(id) FROM ld_users);
UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
UPDATE ld_customreport_info_seq SET id=(SELECT MAX(report_id) FROM ld_customreport_info);
UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT MAX(fieldid) FROM ld_settings_field);
UPDATE ld_workreport_field_seq SET id=(SELECT MAX(id) FROM ld_workreport_field);
delimiter;

UPDATE ld_version SET old_version='V8.5.0.4',current_version='V8.5.0.4',remark='V8.5.0.4-20230605',wx_version='V8.5.0.4';
delimiter;