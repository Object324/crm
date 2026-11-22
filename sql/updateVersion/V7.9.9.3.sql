SET @modulename='PriceBooks';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='validfrom'; 
SET @fieldname='validfrom'; 
SET @zh='有效期起'; 
SET @en='有效期起'; 
SET @uitype=5; 
SET @typeofdata='D~M';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype=NULL;
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'VARCHAR','100',NULL);
ALTER TABLE ld_pricebook MODIFY COLUMN validfrom DATE;




SET @modulename='PriceBooks';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='validtill'; 
SET @fieldname='validtill'; 
SET @zh='有效期止'; 
SET @en='有效期止'; 
SET @uitype=5; 
SET @typeofdata='D~M';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype=NULL;
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'VARCHAR','100',NULL);
ALTER TABLE ld_pricebook MODIFY COLUMN validtill DATE;

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

select tabid into @tabid from ld_tab where name='customreport' ;
select GROUP_CONCAT( DISTINCT profileid)  into @allprofileids  from  ld_profile2standardpermissions
where  tabid=@tabid and ld_profile2standardpermissions.profileid not in(select DISTINCT profileid  from ld_profile2standardpermissions where tabid=@tabid and operation=3);
delete from ld_profile2standardpermissions where FIND_IN_SET(profileid,@allprofileids) 
and tabid=@tabid;
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)
select '150','reference' from dual
where not exists(select * from ld_ws_referencetype where type='PurchaseOrder');

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=150;
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'PurchaseOrder' from dual
where not exists(select * from ld_ws_referencetype where type='PurchaseOrder' and fieldtypeid=@fieldtypeid);
delimiter;


DROP PROCEDURE IF EXISTS `drop_event_task_dailyreport_reminder_20191209`;
delimiter ||
CREATE PROCEDURE `drop_event_task_dailyreport_reminder_20191209`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name`='ReportLog' AND presence IN (1,5)) THEN
		DELETE FROM ld_tab WHERE `name`='ReportLog';
		DELETE FROM ld_settings_field WHERE `name`='LBL_REMIND_SET';
		DROP EVENT IF EXISTS `task_dailyreport_reminder`;
		DROP EVENT IF EXISTS `task_monthreport_reminder`;
		DROP EVENT IF EXISTS `task_weekreport_reminder`;
	ELSEIF NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='ReportLog') THEN
		DELETE FROM ld_settings_field WHERE `name`='LBL_REMIND_SET';
		DROP EVENT IF EXISTS `task_dailyreport_reminder`;
		DROP EVENT IF EXISTS `task_monthreport_reminder`;
		DROP EVENT IF EXISTS `task_weekreport_reminder`;
	END IF;
end ||
delimiter;


CALL drop_event_task_dailyreport_reminder_20191209();
DROP PROCEDURE IF EXISTS `drop_event_task_dailyreport_reminder_20191209`;
-- 2019-12-13

SET @module='Accounts';
SET @template_name='account_buy_products.mrt';
SET @display_name='产品出库记录';
SET @databasetype='crmlink';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module LIMIT 1);
SET @related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Customreport' LIMIT 1);
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,type,related_coltable)
SELECT @relation_id+1,@tabid,@related_tabid,@template_name,@seq+1,@display_name,0,'datacategory_template_js',@databasetype FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE `name`=@template_name AND tabid=@tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

CALl AddColumn('ld_callbutler','potentialid','int','19','');
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','CALLCENTERREPORT','呼叫中心报表','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLCENTERREPORT'
                                               and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','CALLCENTERREPORT','Call center report','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLCENTERREPORT' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2019-12-19


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

UPDATE ld_version SET old_version='V7.9.9.3',current_version='V7.9.9.3',remark='V7.9.9.3-20191219',wx_version='V7.9.9.3';
delimiter;