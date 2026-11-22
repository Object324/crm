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
			IF tmp_defaultvalue='' THEN
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
			IF tmp_columnlen<=1 THEN 
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

ALTER TABLE ld_users MODIFY COLUMN `real_name` varchar(255) AFTER `last_name`;

DELETE FROM ld_systems_deploy WHERE description='设置是否启用电子名片功能' AND deploy_type<>270;
SET @roottype=7;
SET @seq=(SELECT sequence FROM ld_systems_deploy WHERE deploy_type=199);
update ld_systems_deploy set sequence=sequence+1 where sequence>@seq and roottype=@roottype;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 1,270,'设置是否启用电子名片功能',"",@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=270);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',270,270,'设置是否启用电子名片功能'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_systems_deploy' and tabid = 270 and relateid=270);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',270,270,'Set whether to enable electronic business card function'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_systems_deploy' and tabid = 270 and relateid=270);
delimiter;

DELETE FROM ld_modtracker_basic WHERE crmid NOT IN (SELECT crmid FROM ld_crmentity);
DELETE FROM ld_modtracker_detail WHERE id NOT IN (SELECT id FROM ld_modtracker_basic);
-- 2021-02-26


UPDATE ld_cvcolumnlist 
SET columnname=REPLACE(columnname,'absamount','cf_1308')
WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='Potentials') 
	AND columnname LIKE '%cf_1308%'
	AND columnname LIKE '%absamount%';

UPDATE ld_tabwithproductview 
SET `columns`=REPLACE(`columns`,'absamount','cf_1308')
WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='Potentials') 
	AND `columns` LIKE '%cf_1308%'
	AND `columns` LIKE '%absamount%';
delimiter;
  
update ld_homestuffdetailcondition set columns='ld_troubletickets:createdtime:createdtime:HelpDesk_fieldlabel:DT' where columns='ld_troubletickets:createdtime:createdtime:HelpDesk_fieldlabel:D';
update ld_homestuffdetailcondition set columns='ld_troubletickets:approvestatus:approvestatus:HelpDesk_fieldlabel:V' where columns='ld_troubletickets:approvestatus:approvestatus:Leads_fieldlabel:V';
delimiter;

select tabid into @tabid from ld_tab where name='leads';
update ld_field set allowedit='no' where tabid=@tabid and columnname='status';
delimiter;

update ld_desk set fieldlabel = '全局查找' where languagetype = 'zh' and labelbol = 'QUICKFIND' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Global search' where languagetype = 'en' and labelbol = 'QUICKFIND' and Labeltype = 'fixedstr';
delimiter; 

UPDATE ld_field SET defaultvalue='未入库' WHERE defaultvalue='已入库' AND columnname='salesbackstatus' AND tablename='ld_salesback';
delimiter; 
-- 2021-03-05

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Allownewordinarycustomers','允许新建“普通客户”','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Allownewordinarycustomers','Allow new ordinary customers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_account_public','is_commonaccount_create','varchar','50',NULL);
delimiter;

alter table ld_account_public alter is_commonaccount_create set default 'yes';
update ld_account_public set is_commonaccount_create = 'yes' where is_commonaccount_create is NULL;
delimiter;

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

UPDATE ld_version SET old_version='V8.4.0',current_version='V8.4.0',remark='V8.4.0-20210305',wx_version='V8.4.0';
delimiter;