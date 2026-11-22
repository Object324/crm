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

DROP PROCEDURE IF EXISTS `fieldprofile`;
delimiter ||
CREATE  PROCEDURE `fieldprofile`(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from ld_def_org_field where fieldid=',ffieldid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `getallprofile`;
delimiter ||
CREATE  PROCEDURE `getallprofile`(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;

	declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;

	open cur2;
	fetch cur2 into pprofileid;
	loop2: while  done<>1 DO

		call fieldintoprofile(pprofileid,tabname);
		fetch cur2 into pprofileid;
	end while loop2;
	close cur2;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
BEGIN
	
	SELECT DATABASE() into @datebase;

	SET @sql2=CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	IF @cnt=0 THEN 
		SET @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
  END IF;
	
end ||
delimiter;

update ld_field SET savedatabase='no' where uitype=1503 and bigtype = 'qrcode';
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Potentials');
update ld_field set tablename = 'ld_potential' where tabid = @tabid and columnname='subtotal';
update ld_tabwithproductview set `columns` = 'ld_potential:subtotal:hdnSubTotal:Potentials_:N' where tabid=@tabid and `columns` like '%ld_potentials:subtotal:hdnSubTotal:Potentials_:N%';
delimiter;

UPDATE ld_desk SET fieldlabel='停留' WHERE labelbol='STAGEDETENTIONDURATION' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Stay' WHERE labelbol='STAGEDETENTIONDURATION' AND languagetype='en';
delimiter;

UPDATE ld_desk SET fieldlabel='从【%s】可流转到' WHERE labelbol='FROMPUSHTO' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='Push 【%s】 to' WHERE labelbol='FROMPUSHTO' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;


SET @labelbol = 'SAVEANDADVANCE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'保存并推进','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Save and Advance','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASECHOOSENEXTSTAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择下一状态','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please choose next stage','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'STAGEDETENTIONDURATIONTWO';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'阶段滞留时长','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Stage detention duration','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_advancepicklisttask
INNER JOIN ld_advancepicklist ON ld_advancepicklist.advanceid = ld_advancepicklisttask.advanceid
SET ld_advancepicklisttask.completerequest = ld_advancepicklist.completerequest
where (ld_advancepicklisttask.completerequest is NULL or  ld_advancepicklisttask.completerequest = '')
AND ld_advancepicklist.completerequest = 'yes' ;
delimiter;

ALTER TABLE ld_advancepicklisttask MODIFY presence varchar(10);
delimiter;
UPDATE ld_advancepicklisttask SET presence = 'yes' where presence = 0;
delimiter;
call addtableIndex('ld_advancepicklistlog','advancelog_record','record');
delimiter;
-- 2022-06-14

update ld_tabdetailfield set bigtype='amount' where fieldtype='RMB_Amount';
delimiter;

UPDATE ld_field SET fieldplaceholder=NULL WHERE fieldplaceholder='undefined';
UPDATE ld_producttoolfield SET fieldplaceholder=NULL WHERE fieldplaceholder='undefined';
delimiter;

DELETE FROM ld_settings_field WHERE `name`='LBL_REMIND_SET' AND NOT EXISTS (SELECT 1 FROM ld_tab WHERE tabid=63);
delimiter;

SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype='PaymentPlan' AND viewname='本月已收' LIMIT 1);
UPDATE ld_cvadvfilter SET comparator='c' WHERE cvid=@cvid ANd `value`='已收' AND comparator='e' AND columnname LIKE 'ld_paymentplan:paymentstatus:paymentstatus%';
UPDATE ld_cvadvfilter SET columnname='ld_paymentplan:plandate:plandate:PaymentPlan_fieldlabel:D' WHERE columnname='ld_paymentplan:plandate:plandate:PaymentPlan_plandate:D';
delimiter;

SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SendPayment' AND viewname='本月已付' LIMIT 1);
UPDATE ld_cvadvfilter SET comparator='c' WHERE cvid=@cvid ANd `value`='已付' AND comparator='e' AND columnname LIKE 'ld_sendpayment:cpstatus:cpstatus%';
UPDATE ld_cvadvfilter SET columnname='ld_sendpayment:plandate:plandate:SendPayment_fieldlabel:D' WHERE columnname='ld_sendpayment:plandate:plandate:SendPayment_plandate:D';
delimiter;

UPDATE ld_cvadvfilter SET columnname='ld_purchasecashback:purchasecashbackdate:purchasecashbackdate:PurchaseCashBack_fieldlabel:D' WHERE columnname LIKE 'ld_purchasecashback:purchasecashbackdate:purchasecashbackdate%';
delimiter;

update ld_field set savedatabase = 'yes' where fieldname='service_representative'   and savedatabase='YES';
update ld_field set allowedit = 'yes' where fieldname='service_representative' and allowedit='YES';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewGroupingField','新增分组字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewGroupingField' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewGroupingField',"New Grouping Field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewGroupingField' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddCascadingField','新增级联字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddCascadingField' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddCascadingField',"Add Cascading Field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddCascadingField' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetCascadingOptions','设置级联选项','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetCascadingOptions' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetCascadingOptions',"Set Cascading Options",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetCascadingOptions' and labeltype='jspop');
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal`;
delimiter ||
CREATE  PROCEDURE `account_singlerecycle_normal`()
BEGIN

	DECLARE normal_id int(11);
	DECLARE var_pool_id int(11);
	declare done  int  default 0;
	declare cur1 CURSOR FOR select id,pool_id from ld_account_normal;
	declare continue handler  for not   found  SET done =1;
		OPEN cur1;
			Fetch cur1 into normal_id,var_pool_id;
			loop1: while  done<>1 DO

				if normal_id > 0 THEN
						call account_singlerecycle_normal_rule(normal_id,var_pool_id);
						call account_singlerecycle_normal_rule_beforeremind(normal_id,var_pool_id);
				end IF;

    	Fetch cur1 into normal_id,var_pool_id;
    	end while loop1;
    close cur1;

end ||
delimiter;
-- 2022-06-15

call AddColumn('ld_wx_users','isauth','varchar',10,'no');
update ld_wx_users set isauth='yes' where nickname is not null and nickname!='';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseLoginDingdingApp','请登录钉钉APP，进入灵当CRM应用绑定CRM账号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PleaseLoginDingdingApp' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseLoginDingdingApp',"Please log in to nailing app and enter lingdang CRM application to bind CRM account",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PleaseLoginDingdingApp' and labeltype='fixedstr');
delimiter;

drop PROCEDURE if EXISTS update_advance_judge;
delimiter ||
create PROCEDURE update_advance_judge
(
)
BEGIN
		IF EXISTS (SELECT 1 from ld_version where remark = 'V8.4.6.6-20220609') THEN
			update ld_advancepicklist set stagename_target = '' where taskgroup >0 ;
			call update_advance_first();
		END IF;
end ||
delimiter;

drop PROCEDURE if EXISTS update_advance_first;
delimiter ||
create PROCEDURE update_advance_first
(
)
BEGIN
 declare var_id int(19);
 declare done  int  default 0;
 declare cur1 CURSOR FOR SELECT id FROM  ld_settings_advance where method = 'field' and module_field is not NULL;
 declare continue handler  for not   found  SET done =1;
 
SET @@max_sp_recursion_depth = 5;
 open cur1;
Fetch cur1 into var_id;
 loop1: while  done<>1 DO
        
        set @sql='select tabid,pushback,module_field into @tabid,@pushback,@module_field from ld_settings_advance  where ';
				set @sql=CONCAT(@sql, " id='",var_id,"'");
				prepare stmt from @sql;
				execute stmt;
				deallocate prepare stmt;
				
				set @sql="SELECT listid into @listid FROM ld_picklist_set where listname = ";
				set @sql=CONCAT(@sql, "'",@module_field,"'");
				prepare stmt from @sql;
				execute stmt;
				deallocate prepare stmt;

				call update_advance_second(@module_field,@tabid,@pushback,@listid);
    
				Fetch cur1 into var_id;
 end while loop1;
 close cur1;
end ||
delimiter;

drop PROCEDURE if EXISTS update_advance_second;
delimiter ||
create PROCEDURE update_advance_second
(
module_field varchar(100),
var_tabid int(10),
pushback varchar(10),
tmp_listid int(10)
)
BEGIN
 declare var_stagename varchar(100);
 declare pre_stagename varchar(100);
 declare done1  int  default 0;
	
 declare cur1 CURSOR FOR SELECT listvalue FROM ld_picklist_values where listid = tmp_listid ORDER BY sequence ASC;
 declare continue handler  for not   found  SET done1 =1;
 open cur1;
Fetch cur1 into var_stagename;
 loop1: while  done1<>1 DO
        IF pre_stagename <> '' AND EXISTS(SELECT 1 from ld_advancepicklist where stagename = pre_stagename and tabid = var_tabid and fieldname = module_field and (stagename_target = '' or stagename_target is NULL)) THEN
						DELETE from ld_advancepicklist where stagename = pre_stagename and tabid = var_tabid 
							and fieldname = module_field and stagename_target = var_stagename and advanceid not in (SELECT DISTINCT advanceid from ld_advancepicklisttask );
						UPDATE ld_advancepicklist SET stagename_target = var_stagename,presence='yes' where stagename = pre_stagename and tabid = var_tabid and fieldname = module_field and (stagename_target = '' or stagename_target is NULL);
					END if;
				SET pre_stagename = var_stagename;
				Fetch cur1 into var_stagename;
 end while loop1;
 close cur1;
end ||
delimiter;

call update_advance_judge();
drop PROCEDURE  if EXISTS update_advance_first;
delimiter;
drop PROCEDURE  if EXISTS update_advance_second;
delimiter;
drop PROCEDURE  if EXISTS update_advance_judge;
delimiter;
-- 2022-06-15

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

UPDATE ld_version SET old_version='V8.4.6.6.1',current_version='V8.4.6.6.1',remark='V8.4.6.6.1-20220615',wx_version='V8.4.6.6.1';
delimiter;