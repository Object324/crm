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


SET @i=0;
UPDATE ld_industrydemo SET sequence=sequence+5;
UPDATE ld_industrydemo SET sequence=1 WHERE datasql_path='IndustryDemo/001_factory.sql';

INSERT INTO ld_industrydemo (industry_zh, industry_en, datasql_path, templatefile_path, suit_crmversion, sequence)
SELECT '半导体设计和品牌厂商适用', 'Semiconductor Solution for Agents', 'IndustryDemo/017_bandaotiforchangshang.sql',NULL, 'all', '2' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_industrydemo WHERE datasql_path='IndustryDemo/017_bandaotiforchangshang.sql');

INSERT INTO ld_industrydemo (industry_zh, industry_en, datasql_path, templatefile_path, suit_crmversion, sequence)
SELECT '半导体集成方案代理商适用', 'Semiconductor Solution for Agents', 'IndustryDemo/016_bandaotifordailishang.sql',NULL, 'all', '3' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_industrydemo WHERE datasql_path='IndustryDemo/016_bandaotifordailishang.sql');

UPDATE ld_industrydemo SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter; 

CALL AddColumn('ld_productdetail','setdefault','tinyint','2',0);
delimiter;

CALL AddColumn('ld_shopcartdetails','productdetail_lineitem_id','int','255',0);
delimiter;

UPDATE ld_desk set fieldlabel='设置系统登录时密码连续输错{n}次后，不允许登录的限制时长（为空表示不限制时长，允许登录）' WHERE labelbol='PwdErrorAllowTimes' and languagetype='zh' and labeltype='fixedstr';
delimiter;

set @tabid = (select tabid from ld_tab where `name`='WorkReportList');
update ld_field set uitype=5,typeofdata='D~O',bigtype='date' where tabid=@tabid and columnname='sendlog_workdate' and tablename='ld_workreport';
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_BackupSettings','https://help.51mis.com/docs/zHFXu4n8','数据库备份帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_BackupSettings');
delimiter;
UPDATE ld_desk set fieldlabel='用下面的下拉选项替换' WHERE labelbol='REPLACEWITHPICKLIST' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Replace with' WHERE labelbol='REPLACEWITHPICKLIST' and languagetype='en' and labeltype='fixedstr';
delimiter;

call AddColumn('ld_settings_advance','staytimemethod','varchar','20',NULL);
UPDATE ld_settings_advance set staytimemethod = 'getlast' where IFNULL(staytimemethod,'') = '';
delimiter;

call AddColumn('ld_advancepicklisttask','effect_range','varchar','20',NULL);
call AddColumn('ld_advancepicklisttask','approve_demand','varchar','20',NULL);
UPDATE ld_advancepicklisttask set effect_range = 'getlast' where IFNULL(effect_range,'') = '' and type = 'module';
UPDATE ld_advancepicklisttask set approve_demand = 'no' where IFNULL(approve_demand,'') = '' and type = 'module';
delimiter;

call addtableIndex('ld_advancepicklisttask','idx_advancetask_advanceid','advanceid');
call addtableIndex('ld_advancepicklistlog','idx_advancetasklog_taskid','taskid');
delimiter;

SET @labelbol = 'COUNTFIRSTAFTERENTERING';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'仅统计最新进入该阶段后创建的单据',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Only count the documents created for the first time after entering this stage',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'RELATEDDOCUMENTSAPPROVED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'关联单据必须审批通过',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Related documents must be approved',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'DURATIONMETHOD';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'停留时长计算方法',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Calculation method for duration of stay',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'LATESTDURATION';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'阶段最新停留时长',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Latest duration',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'TOTALDURATION';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'阶段总计停留时长',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Total duration',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'CANNOTMOVEBEFORECOMPLETEPC';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'任务未完成，不能向前推进！',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The task has not been completed and cannot move forward!',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'NOTPUSHWITHOUTAPPROVAL';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'以下单据未审批不允许推进',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The following documents cannot be pushed forward without approval',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'CHECKVALIDATARULESJS';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'验证规则',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Validation Rules',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

UPDATE ld_desk SET fieldlabel = '阶段停留时长' where labelbol = 'STAGEDETENTIONDURATIONTWO' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_before_discounted_name`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_before_discounted_name`()
BEGIN

    DECLARE tmptablename VARCHAR(50) DEFAULT 'ld_products';

    DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT tablename FROM ld_producttoolfield WHERE columnname = 'tax_price_after_discounted';

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmptablename = NULL;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ld_salesorderdetail' AND column_name = 'tax_price_before_discounted' AND TABLE_SCHEMA=DATABASE() ) THEN
        SET @disable_triggers = 1;
        OPEN MYCUSOR;
        FETCH MYCUSOR INTO tmptablename;
        WHILE(tmptablename IS NOT NULL) DO

                SET @sql2=CONCAT('ALTER TABLE ', tmptablename, ' CHANGE tax_price_after_discounted tax_price_before_discounted decimal(25,8) ' );
                PREPARE statement_name FROM @sql2;
                EXECUTE statement_name;
                DEALLOCATE PREPARE statement_name;

                SET @sql2=CONCAT('ALTER TABLE ', tmptablename, ' CHANGE tax_amount_after_discounted tax_amount_before_discounted decimal(25,8) ' );
                PREPARE statement_name FROM @sql2;
                EXECUTE statement_name;
                DEALLOCATE PREPARE statement_name;

                FETCH MYCUSOR INTO tmptablename;
            END WHILE;
        CLOSE MYCUSOR;
        SET @disable_triggers = NULL;
    END IF;
    UPDATE ld_producttoolfield SET columnname = 'tax_price_before_discounted' WHERE columnname = 'tax_price_after_discounted';
    UPDATE ld_producttoolfield SET columnname = 'tax_amount_before_discounted' WHERE columnname = 'tax_amount_after_discounted';
END ||
delimiter;

CALL ldcrm_update_before_discounted_name();
delimiter;
DROP PROCEDURE IF EXISTS `ldcrm_update_before_discounted_name`;

DROP PROCEDURE IF EXISTS `ldcrm_update_before_discounted_value`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_before_discounted_value`()
BEGIN

    DECLARE tmp_record INT(19) DEFAULT 0;
    DECLARE tmp_module VARCHAR(50) DEFAULT '';

    DECLARE MYCUSOR CURSOR FOR
        SELECT record, module FROM ld_pricepolicy_use
                                       LEFT JOIN ld_pricepolicy ON ld_pricepolicy.pricepolicyid = ld_pricepolicy_use.pricepolicyid
        WHERE ld_pricepolicy.pricepolicy_type = 'product' AND ld_pricepolicy.pricepolicy_forms <> 'product_present';

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_record = NULL;

    SET @disable_triggers = 1;
    OPEN MYCUSOR;
    FETCH MYCUSOR INTO tmp_record, tmp_module;
    WHILE(tmp_record IS NOT NULL) DO
            SELECT tablename INTO @tmptablename FROM ld_producttoolfield WHERE columnname = 'tax_price_before_discounted' LIMIT 1;

            SET @sql2=CONCAT('UPDATE ', @tmptablename, ' SET ', @tmptablename, '.tax_price_before_discounted = ', @tmptablename, '.taxprice , ', @tmptablename, '.taxprice = ', @tmptablename, '.tax_price_before_discounted WHERE ', @tmptablename, '.id = ', tmp_record );

            PREPARE statement_name FROM @sql2;
            EXECUTE statement_name;
            DEALLOCATE PREPARE statement_name;

            SET @sql2=CONCAT('UPDATE ', @tmptablename, ' SET ', @tmptablename, '.tax_amount_before_discounted = ',
                             @tmptablename, '.tax_amount , ', @tmptablename, '.tax_amount = ', @tmptablename, '.tax_amount_before_discounted
							WHERE ', @tmptablename, '.id = ', tmp_record );

            PREPARE statement_name FROM @sql2;
            EXECUTE statement_name;
            DEALLOCATE PREPARE statement_name;

            FETCH MYCUSOR INTO tmp_record, tmp_module;
        END WHILE;
    CLOSE MYCUSOR;
    SET @disable_triggers = NULL;
END ||
delimiter;

CALL ldcrm_update_before_discounted_value();
delimiter;
DROP PROCEDURE IF EXISTS `ldcrm_update_before_discounted_value`;

SET @i=0;
UPDATE ld_industrydemo SET sequence=sequence+5;
UPDATE ld_industrydemo SET sequence=1 WHERE datasql_path='IndustryDemo/001_factory.sql';

INSERT INTO ld_industrydemo (industry_zh, industry_en, datasql_path, templatefile_path, suit_crmversion, sequence)
SELECT '半导体设计和品牌厂商适用', 'Semiconductor Solution for Agents', 'IndustryDemo/017_bandaotiforchangshang.sql',NULL, 'all', '2' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_industrydemo WHERE datasql_path='IndustryDemo/017_bandaotiforchangshang.sql');

INSERT INTO ld_industrydemo (industry_zh, industry_en, datasql_path, templatefile_path, suit_crmversion, sequence)
SELECT '半导体集成方案代理商适用', 'Semiconductor Solution for Agents', 'IndustryDemo/016_bandaotifordailishang.sql',NULL, 'all', '3' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_industrydemo WHERE datasql_path='IndustryDemo/016_bandaotifordailishang.sql');

UPDATE ld_industrydemo SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetFiltering','设置筛选','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SetFiltering' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetFiltering','Set filtering','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SetFiltering' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
-- 2024-10-20

DROP PROCEDURE IF EXISTS `reset_fieldinfo_20241022`;
delimiter ||
CREATE  PROCEDURE `reset_fieldinfo_20241022`()
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM ld_troubletickets) OR DATABASE() LIKE 'yanshi_%' OR DATABASE() LIKE 'demo_%' THEN
		SET @block=(SELECT block FROM ld_field WHERE tabid=13 AND columnname='sign_location_address' LIMIT 1);
		UPDATE ld_field SET block=@block WHERE tabid=13 AND columnname='signin_address';
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_contactdetails) OR DATABASE() LIKE 'yanshi_%' OR DATABASE() LIKE 'demo_%' THEN
		SET @block=(SELECT block FROM ld_field WHERE tabid=13 AND columnname='smcreatorid' LIMIT 1);
		UPDATE ld_field SET presence=0,allowhide='no',block=@block WHERE tabid=4 AND columnname='createdtime';
	END IF;

end ||
delimiter;

CALL reset_fieldinfo_20241022();
DROP PROCEDURE IF EXISTS `reset_fieldinfo_20241022`;
delimiter;


UPDATE ld_systems_deploy 
SET deploy_value=1 
WHERE deploy_type=165 
	AND NOT EXISTS (SELECT 1 FROM ld_attachmentsforsign)
	AND NOT EXISTS (SELECT 1 FROM ld_attachments)
	AND NOT  EXISTS (SELECT 1 FROM ld_attachmentsforbillsdetails);
delimiter;

update ld_attachments set type='application/pdf' where newfile_name like '%.pdf%' and ifnull(type,'')='';
update ld_attachments set type='image/jpeg' where newfile_name like '%.jpg%' and ifnull(type,'')='' ;
update ld_attachments set type='image/png' where newfile_name like '%.png%' and ifnull(type,'')='' ;
update ld_attachments set type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' where newfile_name like '%.xlsx%' and ifnull(type,'')='';
update ld_attachments set type='application/vnd.ms-excel' where newfile_name like '%.xls%' and ifnull(type,'')='';
update ld_attachments set type='application/vnd.openxmlformats-officedocument.wordprocessingml.document' where newfile_name like '%.docx%' and ifnull(type,'')='';
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_WorkTemplate','https://help.51mis.com/docs/FKRA6T5P','工作汇报模板定制帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_WorkTemplate');
delimiter;
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_AutomaticReminds','https://help.51mis.com/docs/Yf61an2j','自动提醒设置帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_AutomaticReminds');
delimiter;
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_Import','https://help.51mis.com/docs/EeMr6S','导入帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_Import');
delimiter;
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_PriceStrategy','https://help.51mis.com/docs/qskzfxvn','定价策略帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_PriceStrategy');
delimiter;
update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/zjubeS' where label = 'HelpUrl_ModuleManager';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','discountprice','优惠价','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='discountprice' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','discountprice','Ddiscount Price','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='discountprice' and labeltype='jspop' and languagetype='en');
delimiter;

SET @labelbol = 'BRANCHHIGHESTPRIORITY';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'提示：所有条件都不满足时，流转到优先级最高的分支',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Tip: When all conditions are not met, flow to the branch with the highest priority',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

select tabid into @tabid from ld_tab where name='ProductProperty';
delete from ld_tabdetailfield where tabid=@tabid and columnname='setdefault';
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE   PROCEDURE `account_singlerecycle_normal_rule`(new_normal_id 	int(11),
	new_pool_id 	int(11))
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
  DECLARE var_smownercolumn varchar(50);
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
		ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
		,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
		and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

    declare continue handler  for not   found  SET done =1;
    select if(ld_users.id>0,ld_account_normal.transfer_users,0) into @allotaccount from ld_account_normal
    LEFT join ld_users on ld_users.id =ld_account_normal.transfer_users where ld_account_normal.id = new_normal_id;

		if  ifnull(@allotaccount,0)=0  then 
			set @allotaccount=0;
	end if;
    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_account_set_rule_normal.days) into @maxdays
			from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
			INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
			and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

			select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;
			set @account_rule_pool_id = new_pool_id;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
    	end if;

		OPEN cur1;

    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
    		   else
    				set	var_smownercolumn='smownerid' ;
    			end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
    				end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
    			else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

    			 end if;
          set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
    					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
    						and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
    				end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
    				end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
    				else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
    			   end if;

    				set @tmpsql=concat(@tmpsql,' union all ' );

    			end if;
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;


    	if @tmpint>0 then
    		set @len=CHAR_LENGTH(' union all ');
    		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    	  if var_condition='or'  then

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
						set @TMPSQL_LOG_ONE = concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id,ld_account.smownerid,"',new_normal_id,'" as log_grammeid  from ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
					if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
						set @TMPSQL_LOG_ONE=concat(@TMPSQL_LOG_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    		 	end if;
    			 set @TMPSQL_TWO=concat(' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
    				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
    				end if;
    		else
    			 if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
    				ELSE
    					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
    				end if;

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_LOG_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id,ld_account.smownerid,"',new_normal_id,'" as log_grammeid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
						set @TMPSQL_TWO=concat(' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
    		 end if;
					
					set @TMPSQL_LOG_TWO = concat(@TMPSQL_LOG_ONE,@TMPSQL_TWO);
					set @TMPSQL_TWO = concat(@TMPSQL_ONE,@TMPSQL_TWO);

    	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id,old_smownerid,programmeid) ',@TMPSQL_LOG_TWO);
    		 prepare stmt from @TMPSQL_THREE;
    		 execute stmt;
    		 deallocate prepare stmt;



    		if var_condition='or'  then
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from    ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    		   if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    		 	end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
    		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    			if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
    				end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
    		else
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
    		end if;

         delete from ld_publicaccount_remindtableview ;

         set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids )  ", @TMPSQL_TWO);
    		prepare stmt from @tmpthree;
    		execute stmt;
    		deallocate prepare stmt;

       call crm_publicaccount_recoveryreminds();


    		if var_condition='or'  then
    			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');

    		      if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    					end if;
    				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
							if @allotaccount>0 THEN
							set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
						end if;
    					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
    				  end if;

    			ELSE
    				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
							if @allotaccount>0 THEN
								set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
						end if;

						set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');

    		 end if;
    		prepare stmt from @TMPSQL_TWO;
    		execute stmt;
    		deallocate prepare stmt;

    	end if;
    END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule_beforeremind`(
    new_normal_id 	int(11),
    new_pool_id 	int(11)
        )
    label_a:
BEGIN
	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
                                   ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
                                                                                                                                                ,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                                                                                                                                                                                                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
select max(ld_account_set_rule_normal.days) into @maxdays
from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                 INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;

select beforereminddays into @var_beforereminddays from ld_account_normal where id = new_normal_id;
if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
    		leave label_a ;
end if;
       set @maxdays=@maxdays-@var_beforereminddays;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
else
    				set	var_smownercolumn='smownerid' ;
end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

end if;

               set @tmpsqltwo=concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime , '",var_tabname,"' as remindtabname from ld_account LEFT JOIN (select ld_account.accountid from ld_account inner join ",var_tablename,' on ld_account.accountid=',
                    var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


    			IF var_iscycle = 'yes' then
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
ELSE
						set @tmpthree=@tmpsqltwo;
end if;

    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account inner join "  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
end if;

    				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
    			set @tmpint=@tmpint+1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;


if @tmpint>0 then
    			set @len=CHAR_LENGTH(' union all ');
    			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    			if var_condition='or'  then
						set @TMP_TMPTable= ( select  concat("'(",GROUP_CONCAT(ld_tranlabel.fieldlabel),")'")  from ld_account_set_rule_normal
							INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname
							INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
							and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
							where ld_account_set_rule_normal.`status`="active" and normal_id = new_normal_id ORDER BY ld_account_set_rule_normal.sequence asc ) ;
						
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,',@TMP_TMPTable,',\'</a>\'');
    				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid ') ;
ELSE
    					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid') ;
end if;
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,lingdangtmp.fieldlabel,\'</a>\'');
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(',@tmp_namelink,'  separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid'  );
end if;
delete from ld_publicaccount_remindtableview ;
set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicaccount_beforereminds();
end if;
END IF;

end ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMFIRMTOWRITEOFF','确定要注销吗','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMFIRMTOWRITEOFF' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMFIRMTOWRITEOFF','Are you sure you want to write it off','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMFIRMTOWRITEOFF' and Labeltype='jspop' and languagetype='en');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'Productbom';
DELETE FROM ld_producttoolfield WHERE columnname = 'product_licence_price' AND tabid = @tabid;
DELETE FROM ld_producttoolfield WHERE columnname = 'cumulative_benefits' AND tabid = @tabid;
delimiter;

CALL DelColumn('ld_productbom', 'product_licence_price');
CALL DelColumn('ld_productbom', 'cumulative_benefits');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'WareHouseTransfer';
DELETE FROM ld_producttoolfield WHERE columnname = 'product_licence_price' AND tabid = @tabid;
DELETE FROM ld_producttoolfield WHERE columnname = 'cumulative_benefits' AND tabid = @tabid;
delimiter;

CALL DelColumn('ld_warehousetransfer', 'product_licence_price');
CALL DelColumn('ld_warehousetransfer', 'cumulative_benefits');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TIPOFBILL2','(温馨提示：光标定位在$字段名称$中按下Ctrl+Enter键可以更改当前行及之后所有行的$字段名称$及其更多币种设置)','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TIPOFBILL2' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TIPOFBILL2','(Tip: The cursor is located in the $field name$ and press Ctrl+Enter to change the $field name$ of the current line and all subsequent lines And more currency settings)','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TIPOFBILL2' and labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_field SET bigtype = 'text' WHERE columnname = 'approvestatus' AND uitype IN (130,609) AND (bigtype = '' or bigtype is NULL);
delimiter;

select tabid into @producttabid from ld_tab where name='Products';

select parenttabid into @tmp_parenttabid from ld_parenttabrel where tabid=@producttabid and tab_tablename='ld_tab' limit 1;

select max(sequence) into @sequence from ld_parenttabrel where parenttabid=@tmp_parenttabid;

set @tmp_modulename = 'ShoppingMall';
set @tmp_zhmoudulename = '订货商城';
set @tmp_enmoudulename = 'Shopping Mall';
SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,@tmp_modulename,0,@maxtseq+1,@tmp_modulename,1,'' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=@tmp_modulename);

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@tmp_modulename);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab',@tabid,@tabid,@tmp_zhmoudulename FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab',@tabid,@tabid,@tmp_enmoudulename FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');


SET @labseq=IFNULL((SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=@tmp_parenttabid),0);
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @tmp_parenttabid,@tabid,@labseq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@tmp_parenttabid AND tabid=@tabid);
delimiter;


select tabid into @tabid from ld_tab where name='ShoppingMall';
SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid)
  AND actionname IN ('index');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_productdetail_lineitem_id`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_productdetail_lineitem_id`(
    tmptabid INT(11),
    tmpsourcemodule VARCHAR(50),
    tmptablename VARCHAR(50)
)
BEGIN
    DECLARE tmptypeofdata VARCHAR(20) DEFAULT 'V~O';
    SET @disable_triggers = 1;

    SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
    SET @columnname = 'productdetail_lineitem_id';
    SET @trantable='ld_producttoolfield';
    SET @allowhide = 'yes';
    SET @fieldlabel = '产品属性';
    SET @zh='产品属性';
    SET @en='Product Property';
    SET @bigtype='';
    SET @uitype=1;
    SET @parentbigtype='';
    SET @newline=0;
    SET @edit_permission=1;
    SELECT IFNULL(MAX(sequence),1) INTO @sequence FROM ld_producttoolfield where tabid=tmptabid;

    INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type, fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
    SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,tmptypeofdata,@sequence+1,tmptabid,tmptablename,45,@edit_permission,0,0,@newline,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,tmpsourcemodule FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND tablename=tmptablename AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) );

    SELECT producttoolfieldid INTO @relatedid FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) LIMIT 1;
    INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
    SELECT 'zh',@trantable,tmptabid,@relatedid,@zh FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);
    INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
    SELECT 'en',@trantable,tmptabid,@relatedid,@en FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);

    CALL AddColumn (tmptablename, @columnname, 'INT', '11', '');

    UPDATE ld_producttoolfield_seq SET ld_producttoolfield_seq.id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);

    SET @disable_triggers = NULL;
END ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_detailfield_productdetail_lineitem_id`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_detailfield_productdetail_lineitem_id`()
BEGIN
    DECLARE tmptabid INT(11) DEFAULT 0;
    DECLARE tmpsourcemodule VARCHAR(50) DEFAULT '';
    DECLARE tmptablename VARCHAR(50) DEFAULT 'ld_products';

    DECLARE MYCUSOR CURSOR FOR SELECT tabid,sourcemodule,tablename FROM ld_producttoolfield WHERE columnname = 'tax_amount' ;

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmptabid = NULL;

    SET @disable_triggers = 1;
    OPEN MYCUSOR;
    FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmptablename;
    WHILE(tmptabid IS NOT NULL) DO

            CALL ldcrm_add_productdetail_lineitem_id(tmptabid, tmpsourcemodule, tmptablename);

            FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmptablename;
        END WHILE;

    CLOSE MYCUSOR;
    SET @disable_triggers = NULL;
END ||
delimiter;

CALL ldcrm_add_detailfield_productdetail_lineitem_id();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_detailfield_productdetail_lineitem_id`;
delimiter;

SELECT tabid INTO @tmp_tabid FROM ld_tab WHERE `name` = 'Checks';
SET @tmp_tablename = 'ld_checksdetail';
CALL ldcrm_add_productdetail_lineitem_id(@tmp_tabid, NULL, @tmp_tablename);

SELECT tabid INTO @tmp_tabid FROM ld_tab WHERE `name` = 'PricePolicy';
SET @tmp_tablename = 'ld_pricepolicydetail';
CALL ldcrm_add_productdetail_lineitem_id(@tmp_tabid, NULL, @tmp_tablename);

DROP PROCEDURE IF EXISTS `ldcrm_add_productdetail_lineitem_id`;
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_SMSSetting','https://help.51mis.com/docs/ECGBpdeD','短信账户设置帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_SMSSetting');
delimiter;
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_EmailConfig','https://help.51mis.com/docs/pL4FyunO','邮件服务器设置帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_EmailConfig');
delimiter;
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_DingtalkSetting','https://help.51mis.com/docs/4KdpXiam','钉钉接口设置帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_DingtalkSetting');
delimiter;
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_DingtalkWebhookSetting','https://help.51mis.com/docs/bywLNPPw','钉钉群消息推送设置帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_DingtalkWebhookSetting');
delimiter;
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_YunzhijiaSetting','https://help.51mis.com/docs/zXX7Z3jy','云之家接口设置帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_YunzhijiaSetting');
delimiter;
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_LoginControl','https://help.51mis.com/docs/rKc6mM','密码严格管理规则帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_LoginControl');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportDevicecode','导出设备码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExportDevicecode' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportDevicecode','Export device code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExportDevicecode' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FaultRepair','故障报修','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FaultRepair' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FaultRepair','Fault repair report','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FaultRepair' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Devicecode','设备码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Devicecode' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Devicecode','Device Code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Devicecode' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ScanCodesToViewDeviceDetails','实时扫码查看设备详情信息！','fuwu' from dual
where not exists(select 1 from ld_desk where labelbol='ScanCodesToViewDeviceDetails' and labeltype='fuwu' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ScanCodesToViewDeviceDetails','Scan codes in real time to view device details!','fuwu' from dual
where not exists(select 1 from ld_desk where labelbol='ScanCodesToViewDeviceDetails' and labeltype='fuwu' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `addReferenceUitypmodule`;
delimiter ||
create PROCEDURE `addReferenceUitypmodule`(
referenceuitype varchar(100)
)
begin
    set @sql=concat('select MAX(ld_ws_fieldtype.uitype) into @uitype from ld_ws_fieldtype LEFT JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
                where type="',referenceuitype,'"' );
        prepare stmt from @sql;
        execute stmt;
        deallocate prepare stmt;
    if ifnull(@uitype,0)=0 then
        set @uitype=0;
    end if;

    if @uitype = 0 then
        select max(uitype+0) into @maxuitype from ld_ws_fieldtype;
        if @maxuitype<2000  then
            set @maxuitype=2000;
        else
            set @maxuitype=@maxuitype+1;
        end if;

        set @sql=concat('insert into ld_ws_fieldtype(uitype,fieldtype)value("',@maxuitype,'","reference")');
        prepare stmta from @sql;
        execute stmta;
        deallocate prepare stmta;
        set @sql=concat('select fieldtypeid  into @lastid from ld_ws_fieldtype where uitype ="',@maxuitype,'"');
        prepare stmt1 from @sql;
        execute stmt1;
        deallocate prepare stmt1;

        set @sql=concat('insert into ld_ws_referencetype(fieldtypeid,type)value("',@lastid,'","',referenceuitype,'")');
        prepare stmt2 from @sql;
        execute stmt2;
        deallocate prepare stmt2;
    end if;
END ||
delimiter;

DROP PROCEDURE IF EXISTS addmodule_equipment;
delimiter ||
CREATE PROCEDURE addmodule_equipment()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM ld_tab WHERE `name` = 'Equipment') THEN

        -- 建表
        CREATE TABLE IF NOT EXISTS `ld_equipment` (
            `equipmentid` INT(19) NOT NULL,
            `equipmentname` VARCHAR(100) COMMENT '设备名称',
            `equipment_no` VARCHAR(100) COMMENT '设备编号',
            `accountid` INT(19),
            `contactid` INT(19),
            `salesorderid` INT(19),
            `servicecontractid` INT(19),
            `outboundorderid` INT(19),
            `equipmentcode` VARCHAR(100) COMMENT '二维码/条形码编码',
            `version` VARCHAR(100) COMMENT '设备版本',
            `productiondate` date COMMENT '生产日期',
            `purchasedate` date COMMENT '购买日期',
            `installationdate` date COMMENT '安装日期',
            `runningtime` varchar(255) COMMENT '运行时长',
            `bill_country` varchar(30) COMMENT '国家',
            `bill_state` varchar(30) COMMENT '省份',
            `bill_city` varchar(30) COMMENT '城市',
            `bill_area` varchar(30) COMMENT '区域',
            `bill_street` varchar(255) COMMENT '详细地址',

            `smownerid` INT(11) COMMENT '负责人',
            `smcreatorid` INT(11) COMMENT '创建人',
            `modifiedby` INT(11),
            `modifiedtime` datetime,
            `createdtime` datetime,
            `deleted` int(1) DEFAULT 0,
            `team_memberid` text,

            `approvestatus` VARCHAR(50) COMMENT 'Approve Status',
            `approveby` INT(11) COMMENT 'Approve By',
            `approvetime` datetime COMMENT 'Approve Time',
            `approvesubmitter` INT(11),
            `approvesubmittedtime` datetime,
            `approveurgent` VARCHAR(10),
            `approveexpediting` VARCHAR(10),
            `currentapprover` text,
            `currentapprovestepid` int(4),
            `print_times` INT(4),

            `qrcodeimage` varchar(10) COMMENT '二维码',
            `barcodeimage` varchar(10) COMMENT '条形码',
            PRIMARY KEY (`equipmentid`)
        ) ENGINE = INNODB;
        
        call addtableIndex('ld_equipment','approvestatus','approvestatus');
        call addtableIndex('ld_equipment','deleted','deleted');
        call addtableIndex('ld_equipment','smownerid','smownerid');
        call addtableIndex('ld_equipment','smcreatorid','smcreatorid');
        call addtableIndex('ld_equipment','equipmentcode','equipmentcode');
        call addtableIndex('ld_equipment','modifiedtime','modifiedtime');
        call addtableIndex('ld_equipment','createdtime','createdtime');

        CREATE TABLE IF NOT EXISTS `ld_equipmentcf` (
            `equipmentid` int(19) NOT NULL,
            PRIMARY KEY (`equipmentid`)
        ) ENGINE = INNODB;
        

        -- 	插入模块
        SELECT tabsequence INTO @tabsequence FROM ld_tab WHERE `name` = 'Products';
        UPDATE ld_tab SET tabsequence := tabsequence + 1 WHERE tabsequence > @tabsequence;

        SELECT MAX(tabid)+1 INTO @tabid FROM ld_tab ;
        INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,mobilepresence,main_tablename,custom_tablename,primary_key,isduplicate)
        SELECT @tabid,'Equipment',0,@tabsequence+1,'Equipment',1,'mobile,weixin','ld_equipment','ld_equipmentcf','equipmentid','yes' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_tab WHERE `name`='Equipment');

        SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Equipment';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh','ld_tab',@tabid,@tabid,'设备' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab' );
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en','ld_tab',@tabid,@tabid,'Equipment' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');


        -- 	插入菜单栏
        SET @tabid = (select tabid from ld_tab where `name` = 'Equipment');
        SET @products_tabid = (select tabid from ld_tab where `name` = 'Products');
        set @sequence = (select sequence from ld_parenttabrel where tabid = @products_tabid AND tab_tablename = 'ld_tab' LIMIT 1);
        set @parenttabid = (select parenttabid from ld_parenttabrel where tabid = @products_tabid AND tab_tablename = 'ld_tab' LIMIT 1);
        UPDATE ld_parenttabrel SET sequence = sequence+1 WHERE parenttabid = @parenttabid AND sequence > @sequence;

        INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
        SELECT @parenttabid,@tabid,@sequence+1,'ld_tab' FROM DUAL 
        WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid = @parenttabid AND tabid = @tabid AND tab_tablename = 'ld_tab');


        -- 	字段区块
        SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Equipment';
        set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
        INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
        SELECT @blockid,@tabid,'LBL_LABEL',1 FROM DUAL 
        WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_LABEL' AND sequence = 1);


        set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
        INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
        SELECT @blockid,@tabid,'LBL_EQUIPMENT_BASICINFORMATION',2 FROM DUAL 
        WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_EQUIPMENT_BASICINFORMATION' AND sequence = 2);

        set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
        INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
        SELECT @blockid,@tabid,'LBL_EQUIPMENT_ADDRESS',3 FROM DUAL
        WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_EQUIPMENT_ADDRESS' AND sequence = 3);

        set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
        INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
        SELECT @blockid,@tabid,'LBL_FILE_INFORMATION',4 FROM DUAL 
        WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_FILE_INFORMATION' AND sequence = 4);


        update ld_blocks_seq set id=@blockid;


        -- 区块翻译
        SET @tabid = (select tabid from ld_tab where `name` = 'Equipment');
        set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_LABEL');
        INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '标签' from dual
        where not exists (select 1 from ld_tranlabel where  tabid =@tabid and trantable = 'ld_blocks' and languagetype ='zh' and fieldlabel ='标签');
        INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Label' from dual
        where not exists (select 1 from ld_tranlabel where  tabid =@tabid and trantable = 'ld_blocks' and languagetype ='en' and fieldlabel ='Label');

        set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_EQUIPMENT_BASICINFORMATION');
        INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '基本信息' from dual
        where not exists (select 1 from ld_tranlabel where  tabid =@tabid and trantable = 'ld_blocks' and languagetype ='zh' and fieldlabel ='基本信息');
        INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Basic Information' from dual
        where not exists (select 1 from ld_tranlabel where  tabid =@tabid and trantable = 'ld_blocks' and languagetype ='en' and fieldlabel ='Basic Information');

        set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_EQUIPMENT_ADDRESS');
        INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '设备地址' from dual
        where not exists (select 1 from ld_tranlabel where  tabid =@tabid and trantable = 'ld_blocks' and languagetype ='zh' and fieldlabel ='设备地址');
        INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Equipment Address' from dual
        where not exists (select 1 from ld_tranlabel where  tabid =@tabid and trantable = 'ld_blocks' and languagetype ='en' and fieldlabel ='Equipment Address');

        set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_FILE_INFORMATION');
        INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '附件信息' from dual
        where not exists (select 1 from ld_tranlabel where  tabid =@tabid and trantable = 'ld_blocks' and languagetype ='zh' and fieldlabel ='附件信息');
        INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Attachments Information' from dual
        where not exists (select 1 from ld_tranlabel where  tabid =@tabid and trantable = 'ld_blocks' and languagetype ='en' and fieldlabel ='Attachments Information');


        -- 基本信息-字段
        SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Equipment';
        SET @tablename='ld_equipment';
        SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid=@tabid and blocklabel='LBL_EQUIPMENT_BASICINFORMATION';

        SET @columnname='equipment_no';
        SET @fieldname='equipment_no';
        SET @zh='设备编号';
        SET @uitype=4;
        SET @bigtype='moduleno';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT IFNULL(MAX(sequence),0) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='equipmentname';
        SET @fieldname='equipmentname';
        SET @zh='设备名称';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='accountid';
        SET @fieldname='account_id';
        SET @zh='客户名称';
        SET @uitype=73;
        SET @bigtype='reference';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='smownerid';
        SET @fieldname='assigned_user_id';
        SET @zh='负责人';
        SET @uitype=53;
        SET @bigtype='users';
        SET @readonly=1;
        SET @presence=0;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='contactid';
        SET @fieldname='contact_id';
        SET @zh='联系人';
        SET @uitype=57;
        SET @bigtype='reference';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='salesorderid';
        SET @fieldname='salesorder_id';
        SET @zh='销售订单';
        SET @uitype=80;
        SET @bigtype='reference';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='servicecontractid';
        SET @fieldname='servicecontract_id';
        SET @zh='服务合同';
        SET @uitype=243;
        SET @bigtype='reference';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        
        call addReferenceUitypmodule('OutboundOrder');

        SET @columnname='outboundorderid';
        SET @fieldname='outboundorder_id';
        SET @zh='出库单';
        set @uitype=(SELECT max(uitype) FROM ld_ws_fieldtype LEFT JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid where ld_ws_referencetype.type='OutboundOrder');
        SET @bigtype='reference';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);


        SET @columnname='equipmentcode';
        SET @fieldname='equipmentcode';
        SET @zh='二维码/条形码编码';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,1,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='version';
        SET @fieldname='version';
        SET @zh='设备版本';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);


        SET @columnname='productiondate';
        SET @fieldname='productiondate';
        SET @zh='生产日期';
        SET @uitype=5;
        SET @bigtype='date';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='D~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='purchasedate';
        SET @fieldname='purchasedate';
        SET @zh='购买日期';
        SET @uitype=5;
        SET @bigtype='date';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='D~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='installationdate';
        SET @fieldname='installationdate';
        SET @zh='安装日期';
        SET @uitype=5;
        SET @bigtype='date';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='D~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='runningtime';
        SET @fieldname='runningtime';
        SET @zh='运行时长';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='smcreatorid';
        SET @fieldname='smcreatorid';
        SET @zh='创建人';
        SET @uitype=52;
        SET @bigtype='users';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~0';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='createdtime';
        SET @fieldname='createdtime';
        SET @zh='创建时间';
        SET @uitype=70;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='DT~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='modifiedby';
        SET @fieldname='modifiedby';
        SET @zh='最新更新人';
        SET @uitype=52;
        SET @bigtype='users';
        SET @readonly=1;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='modifiedtime';
        SET @fieldname='modifiedtime';
        SET @zh='更新时间';
        SET @uitype=70;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='DT~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='team_memberid';
        SET @fieldname='team_memberid';
        SET @zh='团队成员';
        SET @uitype=154;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='tag';
        SET @fieldname='tag';
        SET @zh='标签';
        SET @uitype=301;
        SET @bigtype='tag';
        SET @readonly=0;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='approvestatus';
        SET @fieldname='approvestatus';
        SET @zh='审批状态';
        SET @uitype=609;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='approvetime';
        SET @fieldname='approvetime';
        SET @zh='最新审批时间';
        SET @uitype=70;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='DT~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='approveby';
        SET @fieldname='approveby';
        SET @zh='上一步审批人';
        SET @uitype=131;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='currentapprover';
        SET @fieldname='currentapprover';
        SET @zh='当前审批人';
        SET @uitype=132;
        SET @bigtype='users';
        SET @readonly=1;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='print_times';
        SET @fieldname='print_times';
        SET @zh='打印次数';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=1;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='N~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='qrcodeimage';
        SET @fieldname='qrcodeimage';
        SET @zh='二维码图片';
        SET @uitype=69;
        SET @bigtype='fileattachment';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='barcodeimage';
        SET @fieldname='barcodeimage';
        SET @zh='条形码图片';
        SET @uitype=69;
        SET @bigtype='fileattachment';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        -- 设备地址-字段
        SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Equipment';
        SET @tablename='ld_equipment';
        SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid=@tabid and blocklabel='LBL_EQUIPMENT_ADDRESS';

        SET @columnname='bill_country';
        SET @fieldname='bill_country';
        SET @zh='国家';
        SET @uitype=15;
        SET @bigtype='picklist';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue='中国';
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
        
        SET @columnname='bill_state';
        SET @fieldname='bill_state';
        SET @zh='省份';
        SET @uitype=15;
        SET @bigtype='picklist';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='bill_city';
        SET @fieldname='bill_city';
        SET @zh='城市';
        SET @uitype=15;
        SET @bigtype='picklist';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='bill_area';
        SET @fieldname='bill_area';
        SET @zh='区域';
        SET @uitype=15;
        SET @bigtype='picklist';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='bill_street';
        SET @fieldname='bill_street';
        SET @zh='详细地址';
        SET @uitype=21;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        -- 级联关系
        SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Equipment';
        SELECT tabid INTO @account_tabid FROM ld_tab WHERE `name`='Accounts';

        SELECT MAX(id) INTO @id FROM ld_picklist_dependency;
        INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues,criteria)
        SELECT @id:= @id + 1,@tabid,sourcefield,targetfield,sourcevalue,targetvalues,criteria FROM ld_picklist_dependency WHERE tabid = @account_tabid AND sourcefield = 'bill_state'
        AND NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE tabid = @tabid AND sourcefield='bill_state' AND targetfield = 'bill_city');

        SELECT MAX(id) INTO @id FROM ld_picklist_dependency;
        INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues,criteria)
        SELECT @id:= @id + 1,@tabid,sourcefield,targetfield,sourcevalue,targetvalues,criteria FROM ld_picklist_dependency WHERE tabid = @account_tabid AND sourcefield = 'bill_city'
        AND NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE tabid = @tabid AND sourcefield='bill_city' AND targetfield = 'bill_area');

        SELECT MAX(id) INTO @id FROM ld_picklist_dependency;
        INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues,criteria)
        SELECT @id:= @id + 1,@tabid,sourcefield,targetfield,sourcevalue,targetvalues,criteria FROM ld_picklist_dependency WHERE tabid = @account_tabid AND sourcefield = 'bill_country'
        AND NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE tabid = @tabid AND sourcefield='bill_country' AND targetfield = 'bill_state');

        UPDATE ld_picklist_dependency_seq SET id=(SELECT max(id) FROM ld_picklist_dependency);

        -- 	字段中英文翻译
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`="Equipment");
        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='equipment_no' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='设备编号';
        SET @en='Equipment number';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='equipmentname' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='设备名称';
        SET @en='Equipment name';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='accountid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='客户名称';
        SET @en='Customer Name';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='负责人';
        SET @en='Assigned To';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='contactid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='联系人';
        SET @en='Contacts';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='salesorderid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='销售订单';
        SET @en='Sales order';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='servicecontractid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='服务合同';
        SET @en='Service contract';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='outboundorderid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='出库单';
        SET @en='Outbound order';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='equipmentcode' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='二维码/条形码编码';
        SET @en='Qr code/barcode code';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='version' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='设备版本';
        SET @en='Equipment version';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='productiondate' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='生产日期';
        SET @en='Production date';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='purchasedate' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='购买日期';
        SET @en='Purchase date';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='installationdate' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='安装日期';
        SET @en='Installation date';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='runningtime' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='运行时长';
        SET @en='Running time';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='创建人';
        SET @en='Creator';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='创建时间';
        SET @en='Created Time';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='最新更新人';
        SET @en='Modified By';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='更新时间';
        SET @en='Modified Time';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='团队成员';
        SET @en='Team Members';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        
        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='tag' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='标签';
        SET @en='Tag';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        
        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='审批状态';
        SET @en='Approve Status';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='最新审批时间';
        SET @en='Last approval time';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='上一步审批人';
        SET @en='The Last Approver';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='当前审批人';
        SET @en='Current Approver';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='打印次数';
        SET @en='Printing times';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='qrcodeimage' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='二维码图片';
        SET @en='QR code image';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='barcodeimage' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='条形码图片';
        SET @en='Barcode image';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bill_country' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='国家';
        SET @en='State';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bill_state' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='省份';
        SET @en='Province';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bill_city' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='城市';
        SET @en='City';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bill_area' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='区域';
        SET @en='Area';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bill_street' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='详细地址';
        SET @en='Address';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        -- 	查询分类
        SELECT MAX(cvid) + 1 INTO @maxcvid FROM ld_customview;
        INSERT INTO ld_customview ( cvid,viewname,setdefault,setmetrics,entitytype,STATUS,userid,sequence )
        SELECT @maxcvid,'All',1,0,'Equipment',3,1,1 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype = 'Equipment' AND viewname = 'All');

        UPDATE ld_customview_seq SET id = @maxcvid;

        SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'Equipment';
        SELECT cvid INTO @cvid FROM ld_customview WHERE entitytype = 'Equipment' AND viewname = 'All';

        INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
        select @cvid, 0, 'ld_equipment:equipment_no:equipment_no:Equipment_fieldlabel:V' from dual
        where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

        INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
        select @cvid, 1, 'ld_equipment:equipmentname:equipmentname:Equipment_fieldlabel:V' from dual
        where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

        INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
        select @cvid, 2, 'ld_equipment:accountid:account_id:Equipment_fieldlabel:V' from dual
        where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

        INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
        select @cvid, 3, 'ld_equipment:equipmentcode:equipmentcode:Equipment_fieldlabel:V' from dual
        where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

        INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
        select @cvid, 4, 'ld_equipment:purchasedate:purchasedate:Equipment_fieldlabel:D' from dual
        where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

        INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
        select @cvid, 5, 'ld_equipment:installationdate:installationdate:Equipment_fieldlabel:D' from dual
        where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

        INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
        select @cvid, 6, 'ld_equipment:smownerid:smownerid:Equipment_fieldlabel:V' from dual
        where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

        INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
        select @cvid, 7, 'ld_equipment:contactid:contact_id:Equipment_fieldlabel:V' from dual
        where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);

        -- 单据编号规则
        SET @tmp_modulename = 'Equipment';
        SELECT id+1 INTO @modentity_num_seq FROM ld_modentity_num_seq;
        INSERT INTO `ld_modentity_num`(`num_id`, `semodule`, `prefix`, `start_id`, `cur_id`, `active`, `datetype`, `UseUserAccount`, `isallow`, `prefixtype`)
        SELECT @modentity_num_seq, @tmp_modulename, 'EQMT', '1', '1', '1', 'none', 0, 0, 0  FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_modentity_num WHERE  semodule = @tmp_modulename);

        UPDATE ld_modentity_num_seq SET id =( SELECT max(num_id) FROM ld_modentity_num );

        -- 超链接字段
        SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @tmp_modulename;
        INSERT INTO `ld_entityname`(`tabid`, `modulename`, `tablename`, `fieldname`, `entityidfield`, `entityidcolumn`)
        SELECT @tabid, @tmp_modulename, 'ld_equipment', 'equipment_no', 'equipmentid', 'equipmentid' FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid = @tabid);

        -- 权限
        SET @tmp_modulename = 'Equipment';
        SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @tmp_modulename;
        CALL getallprofile(@tmp_modulename);
        CALL fieldprofile(@tmp_modulename);
        CALL addtabintoprofile(@tmp_modulename,1);

        SET @actionid = (SELECT MAX(actionid) FROM ld_actionmapping);
        INSERT INTO ld_actionmapping(actionid,actionname,securitycheck,`actionlabel`)
        SELECT @actionid+1,'ExportDevicecode',0,'ExportDevicecode' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname='ExportDevicecode');

        SET @i=0;
        INSERT INTO ld_profileallpermission(tabid,operation,sequence)
        SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid)
            AND actionname IN ('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Import','Export','ExportDevicecode','ChangeCreator','Print','CustomView');

        -- 按钮
        INSERT INTO ld_listview_btn(`name`,btntype,description,`iconname`)
        SELECT 'ExportDevicecode','rely','导出设备码','Batchoffshelves.png' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_listview_btn WHERE name='ExportDevicecode' AND btntype = 'rely');

        -- 相关信息
        SET @module='Accounts';
        SET @rel_module='Equipment';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
        SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
        SET @template=CONCAT('get_',LOWER(@rel_module));
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,1,'add','datacategory_sql','equipment.accountid','[{"columnname":"equipment.accountid","comparator":"e","columncondition":""}]' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        SET @module='Contacts';
        SET @rel_module='Equipment';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Contacts');
        SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
        SET @template=CONCAT('get_',LOWER(@rel_module));
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,1,'add','datacategory_sql','equipment.contactid','[{"columnname":"equipment.contactid","comparator":"e","columncondition":""}]' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        SET @module='SalesOrder';
        SET @rel_module='Equipment';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder');
        SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @outboundorder_tabid = (SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder');
        SET @seq=(SELECT `sequence` FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@outboundorder_tabid LIMIT 1);
        UPDATE ld_relatedlists SET `sequence` = sequence+1 WHERE tabid=@tabid AND sequence > @seq;
        SET @template=CONCAT('get_',LOWER(@rel_module));
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','equipment.salesorderid','[{"columnname":"equipment.salesorderid","comparator":"e","columncondition":""}]' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        SET @module='ServiceContracts';
        SET @rel_module='Equipment';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
        SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @outboundorder_tabid = (SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder');
        SET @seq=(SELECT `sequence` FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@outboundorder_tabid LIMIT 1);
        UPDATE ld_relatedlists SET `sequence` = sequence+1 WHERE tabid=@tabid AND sequence > @seq;
        SET @template=CONCAT('get_',LOWER(@rel_module));
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','equipment.servicecontractid','[{"columnname":"equipment.servicecontractid","comparator":"e","columncondition":""}]' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        SET @module='OutboundOrder';
        SET @rel_module='Equipment';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder');
        SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @seq=0;
        UPDATE ld_relatedlists SET `sequence` = sequence+1 WHERE tabid=@tabid;
        SET @template=CONCAT('get_',LOWER(@rel_module));
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','equipment.outboundorderid','[{"columnname":"equipment.outboundorderid","comparator":"e","columncondition":""}]' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        -- 客户服务单加字段
        call AddColumn('ld_troubletickets','equipmentid','int','19',0);

        SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='HelpDesk';
        SET @tablename='ld_troubletickets';
        SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid=@tabid and blocklabel='LBL_TICKET_INFORMATION';

        call addReferenceUitypmodule('Equipment');

        SET @columnname='equipmentid';
        SET @fieldname='equipment_id';
        SET @zh='设备';
        set @uitype=(SELECT max(uitype) FROM ld_ws_fieldtype LEFT JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid where ld_ws_referencetype.type='Equipment');
        SET @bigtype='reference';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT sequence + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid AND columnname = 'product_id';
        UPDATE ld_field SET `sequence` = sequence+1 WHERE tabid=@tabid AND block=@blockid AND sequence >= @seq;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
        
        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='equipmentid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='设备';
        SET @en='Equipment';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        -- 相关信息
        SET @module='Equipment';
        SET @rel_module='HelpDesk';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk');
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @seq=(SELECT IFNULL(MAX(sequence),0) FROM ld_relatedlists WHERE tabid=@tabid);
        SET @template=CONCAT('get_',LOWER(@rel_module));
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','troubletickets.equipmentid','[{"columnname":"troubletickets.equipmentid","comparator":"e","columncondition":""}]' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        SET @module='Equipment';
        SET @rel_module='SharedUsers';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @rel_tabid=0;
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @seq=(SELECT IFNULL(MAX(sequence),0) FROM ld_relatedlists WHERE tabid=@tabid);
        SET @template = 'get_SharedUsers';
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'share','','','' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        SET @module='Equipment';
        SET @rel_module='ViewHistory';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @rel_tabid=-7;
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @seq=(SELECT IFNULL(MAX(sequence),0) FROM ld_relatedlists WHERE tabid=@tabid);
        SET @template = 'get_viewhistory';
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'','','','' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        SET @module='Equipment';
        SET @rel_module='OperationLogs';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @rel_tabid=-19;
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @seq=(SELECT IFNULL(MAX(sequence),0) FROM ld_relatedlists WHERE tabid=@tabid);
        SET @template = 'get_operationlogs';
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'','','','' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        SET @module='Equipment';
        SET @rel_module='ChangeView';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @rel_tabid=-10;
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @seq=(SELECT IFNULL(MAX(sequence),0) FROM ld_relatedlists WHERE tabid=@tabid);
        SET @template = 'get_changeview';
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'','','','' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        SET @module='Equipment';
        SET @rel_module='Reminds';
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds');
        SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
        SET @seq=(SELECT IFNULL(MAX(sequence),0) FROM ld_relatedlists WHERE tabid=@tabid);
        SET @template=CONCAT('get_',LOWER(@rel_module));
        INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
        SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','reminds.related_to','[{"columnname":"reminds.related_to","comparator":"e","columncondition":""}]' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
        UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

        -- 移动端列表字段
        INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`) 
        select 'Equipment', '1', '1', 'ld_equipment:equipmentname:equipmentname:Equipment_设备名称:V', '0', NULL, '0', 'no', 'yes', 'yes' from dual
        where not exists(select 1 from ld_cvcolumnlist_wx where modulename='Equipment' and columnname='ld_equipment:equipmentname:equipmentname:Equipment_设备名称:V');

        INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
        select 'Equipment', '2', '1', 'ld_equipment:equipmentcode:equipmentcode:Equipment_二维码/条形码编码:V', '0', NULL, '0', 'no', 'yes', 'yes' from dual
        where not exists(select 1 from ld_cvcolumnlist_wx where modulename='Equipment' and columnname='ld_equipment:equipmentcode:equipmentcode:Equipment_二维码/条形码编码:V');

        INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
        select 'Equipment', '3', '1', 'ld_equipment:purchasedate:purchasedate:Equipment_购买日期:D', '0', NULL, '0', 'no', 'yes', 'yes' from dual
        where not exists(select 1 from ld_cvcolumnlist_wx where modulename='Equipment' and columnname='ld_equipment:purchasedate:purchasedate:Equipment_购买日期:D');

        INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
        select 'Equipment', '3', '2', 'ld_equipment:installationdate:installationdate:Equipment_安装日期:D', '0', NULL, '0', 'no', 'yes', 'yes' from dual
        where not exists(select 1 from ld_cvcolumnlist_wx where modulename='Equipment' and columnname='ld_equipment:installationdate:installationdate:Equipment_安装日期:D');

        -- 移动端详情字段
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
        INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
        SELECT @tabid,'equipmentname',1,'normal',0,'yes' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='equipmentname');
        
        INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
        SELECT @tabid,'equipmentcode',2,'normal',0,'yes' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='equipmentcode');

        INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
        SELECT @tabid,'account_id',3,'normal',0,'yes' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');

        INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
        SELECT @tabid,'purchasedate',4,'normal',0,'yes' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='purchasedate');

        INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
        SELECT @tabid,'installationdate',5,'normal',0,'yes' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='installationdate');

        -- 服务小程序加模块
        SET @modulename='Equipment';

        INSERT INTO ld_weixinmp_set(modulename,`viewall`)
        SELECT @modulename,'no' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_set WHERE modulename=@modulename);

        SET @seq=(SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_module WHERE modulename = 'HelpDesk');
        INSERT INTO ld_weixinmp_module(modulename,`type`,mplabel,`image`,content,presence,`sequence`,mplabel_en)
        SELECT @modulename,'view','扫一扫查设备','scan','ScanCodesToViewDeviceDetails',0,@seq+1,'Scan and check the device' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_module WHERE modulename=@modulename);

        -- 服务小程序字段
        SET @modulename='Equipment';
        SET @tmp_fieldname = 'equipment_no';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','设备编号','createno','m','',@tmp_seq+1,'Equipment number' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'equipmentname';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','设备名称','all','m','',@tmp_seq+1,'Equipment name' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'account_id';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','客户名称','all','o','',@tmp_seq+1,'Customer number' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'assigned_user_id';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','负责人','createno','o','',@tmp_seq+1,'Assigned To' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'salesorder_id';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','销售订单','all','o','',@tmp_seq+1,'Sales order' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'servicecontract_id';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','服务合同','all','o','',@tmp_seq+1,'Service contract' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'equipmentcode';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','二维码/条形码编码','all','m','',@tmp_seq+1,'Qr code/barcode code' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'version';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','设备版本','all','o','',@tmp_seq+1,'Equipment version' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'productiondate';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','生产日期','all','o','',@tmp_seq+1,'Production date' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'purchasedate';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','购买日期','all','o','',@tmp_seq+1,'Purchase date' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'installationdate';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','安装日期','all','o','',@tmp_seq+1,'Installation date' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        SET @tmp_fieldname = 'runningtime';
        SET @tmp_seq = (SELECT IFNULL(MAX(sequence),0) FROM ld_weixinmp_fields WHERE modulename=@modulename);
        INSERT INTO ld_weixinmp_fields(modulename,`fieldname`,tabletype,`fieldlabel`,displaytype,typeofdata,`defaultvalue`,`sequence`,fieldlabel_en)
        SELECT @modulename,@tmp_fieldname,'main','运行时长','all','o','',@tmp_seq+1,'Running time' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_fields WHERE modulename=@modulename AND fieldname = @tmp_fieldname);

        -- 服务小程序列表字段
        SET @modulename = 'Equipment';
        SET @fieldname = 'equipmentname';
        INSERT INTO ld_weixinmp_listfields(modulename,rownumber,listnumber,fieldname,presence,showtag)
        SELECT @modulename,1,1,@fieldname,0,0 FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_listfields WHERE modulename=@modulename AND fieldname=@fieldname);

        SET @fieldname = 'equipmentcode';
        INSERT INTO ld_weixinmp_listfields(modulename,rownumber,listnumber,fieldname,presence,showtag)
        SELECT @modulename,2,1,@fieldname,0,0 FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_listfields WHERE modulename=@modulename AND fieldname=@fieldname);

        SET @fieldname = 'purchasedate';
        INSERT INTO ld_weixinmp_listfields(modulename,rownumber,listnumber,fieldname,presence,showtag)
        SELECT @modulename,3,1,@fieldname,0,0 FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_listfields WHERE modulename=@modulename AND fieldname=@fieldname);

        SET @fieldname = 'installationdate';
        INSERT INTO ld_weixinmp_listfields(modulename,rownumber,listnumber,fieldname,presence,showtag)
        SELECT @modulename,3,2,@fieldname,0,0 FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_weixinmp_listfields WHERE modulename=@modulename AND fieldname=@fieldname);

        -- 审批流程
        SET @tmp_modulename = 'Equipment';
        SET @tmp_zhmoudulename = '设备';
        SET @tabid = (select tabid from ld_tab where `name` = 'Equipment');

        SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
        SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
        INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
        SELECT 0,490,CONCAT(@tmp_zhmoudulename,'是否启用审批流程'),@tmp_modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=490);

        SET @approvename=CONCAT(@tmp_zhmoudulename,'审批流程');
        SET @approveid=(SELECT MAX(id) FROM ld_approve);
        INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,isnewapprove)
        SELECT @approveid+1,@tabid,CONCAT(@tmp_zhmoudulename,'审批流程'),0,1,1,now(),now(),0,0,0,'no','yes' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

        SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
        SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
        SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
        INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
		SELECT @maxsetpid+1,@approveid,'开始',NULL,1,1,now(),now(),6,'','start','yes',1,NULL,-1,-1 FROM DUAL WHERE @hadinsert=0;
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
		SELECT @maxsetpid+2,@approveid,'一级审批',1,1,2,now(),now(),6,'','approver','yes',2,1,-1,1 FROM DUAL WHERE @hadinsert=0;

        UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

        SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
        INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
        SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

        SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
        INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
        SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

        SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
        INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
        SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

        -- 关联带出
        SET @tabid = (select tabid from ld_tab where `name` = 'Equipment');
        SET @trigger_columnname='salesorderid';
        SET @effect_columnname='accountid';
        SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
        SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
        SET @fromvalue_type="column";
        SET @fromvalue_info="accountid";
        INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
        SELECT 'main',@trigger_fieldid,@effect_fieldid,@fromvalue_type,@fromvalue_info FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
        AND @trigger_fieldid>0 AND @effect_fieldid>0;

        SET @trigger_columnname='servicecontractid';
        SET @effect_columnname='accountid';
        SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
        SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
        SET @fromvalue_type="column";
        SET @fromvalue_info="accountid";
        INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
        SELECT 'main',@trigger_fieldid,@effect_fieldid,@fromvalue_type,@fromvalue_info FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
        AND @trigger_fieldid>0 AND @effect_fieldid>0;

        SET @trigger_columnname='outboundorderid';
        SET @effect_columnname='accountid';
        SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
        SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
        SET @fromvalue_type="column";
        SET @fromvalue_info="accountid";
        INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
        SELECT 'main',@trigger_fieldid,@effect_fieldid,@fromvalue_type,@fromvalue_info FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
        AND @trigger_fieldid>0 AND @effect_fieldid>0;

    END IF;
END ||
delimiter;

CALL addmodule_equipment();
DROP PROCEDURE IF EXISTS `addmodule_equipment`;
DROP PROCEDURE IF EXISTS `addReferenceUitypmodule`;
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 33,'SalesRanking_Invoice','fixedstr',
       'ld_invoice.total','sum','开票金额',
       'Invoice Amount','',
       'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V','yes','Invoice','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SalesRanking_Invoice' and compute_module='Invoice' and stuffid=33);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 33,'SalesRanking_OutboundOrder','fixedstr',
       'ld_outboundorder.total','sum','出库金额',
       'OutboundOrder Amount','',
       'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V','yes','OutboundOrder','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SalesRanking_OutboundOrder' and compute_module='OutboundOrder' and stuffid=33);
delimiter;

select tabid into @tabid from ld_tab where name='Expense';

update ld_tabdetailfield set bigtype='currency' where tabid=@tabid and columnname='currency_id' ;
delimiter;

UPDATE ld_validatasave set conditiongroupid = 1,valid_condition = '' where conditiongroupid is NULL and module = 'CollectionSlip' and fieldname = 'collected_amount';
delimiter;
-- 2024-10-27

SET @i=0;
SET @seq=(SELECT MAX(sequence) FROM ld_industrydemo WHERE datasql_path='IndustryDemo/013_zixunrenzheng.sql');
UPDATE ld_industrydemo SET sequence=sequence+5 WHERE sequence>@seq+0;

INSERT INTO ld_industrydemo (industry_zh, industry_en, datasql_path, templatefile_path, suit_crmversion, sequence)
SELECT '知识产权行业账套', 'Intellectual property', 'IndustryDemo/018.zhishichanquan.sql',NULL, 'all', @seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_industrydemo WHERE datasql_path='IndustryDemo/018.zhishichanquan.sql');

UPDATE ld_industrydemo SET sequence=@seq+1 WHERE datasql_path='IndustryDemo/018.zhishichanquan.sql';

UPDATE ld_industrydemo SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter; 


CALl AddColumn('ld_customform16','triggercount','INT','11',0);
delimiter; 

CREATE TABLE if not EXISTS `ld_user_group_set` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
	`userid` int(19) DEFAULT NULL,
  `groupid` int(19) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `content` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB; 
delimiter;

call addtableIndex('ld_user_group_set','idx_user_group_set_userid','userid');
call addtableIndex('ld_user_group_set','idx_user_group_set_groupid','groupid');
delimiter;

INSERT into ld_user_group_set(`userid`,`groupid`,`type`,`content`)
SELECT DISTINCT ld_users.id,ld_users2group.groupid,'userlevel',IFNULL(ld_users.userlevel,'') 
from ld_users INNER JOIN ld_users2group on ld_users.id = ld_users2group.userid
where ld_users.userlevel <> '' AND not EXISTS(SELECT 1 from ld_user_group_set);
delimiter;

set @tabid = (SELECT tabid from ld_tab where `name` = 'Users');
UPDATE ld_field set uitype = 34,bigtype = 'relatedpicklist',masseditable = 2 where tabid = @tabid and columnname = 'userlevel';
delimiter;

call AddColumn('ld_worksheetdetailscf','sequence','int','10','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetAllAsUnread','全部未读','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetAllAsUnread' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetAllAsUnread','Set all as unread','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetAllAsUnread' and labeltype='fixedstr' and languagetype='en');
delimiter;

set @tabid = (SELECT tabid from ld_tab where `name` = 'Singin');
UPDATE ld_blocks set display_status = 0 where  blocklabel = 'LBL_ADDRESS_SINGIN' 
and tabid in (SELECT option_tabid from ld_option_module where tabid = @tabid and enablewhenadding = 0);
UPDATE ld_option_module set enablewhenadding = 1 where tabid = @tabid;
delimiter;

UPDATE ld_customtable_columns
left join ld_customtable on ld_customtable_columns.report_id=ld_customtable.report_id
SET `columns` = REPLACE(`columns`, SUBSTRING_INDEX(SUBSTRING_INDEX(`columns`, '_', -1), ':', 1), 'fieldlabel')
where ld_customtable.report_type='selectfield';

UPDATE ld_customtable_condition
SET `columns` = REPLACE(`columns`, SUBSTRING_INDEX(SUBSTRING_INDEX(`columns`, '_', -1), ':', 1), 'fieldlabel');
UPDATE ld_customtable_sorting
SET `columns` = REPLACE(`columns`, SUBSTRING_INDEX(SUBSTRING_INDEX(`columns`, '_', -1), ':', 1), 'fieldlabel');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_workreport_download_preview`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_workreport_download_preview`(
)
BEGIN
	DECLARE tmp_profileid INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	set @tmp_downloadid = (select actionid from ld_actionmapping where actionname = 'DownLoad');
	set @tmp_previewid = (select actionid from ld_actionmapping where actionname = 'Preview');
	set @tabid = (select tabid from ld_tab where `name`='CooperativeWork');

	IF NOT EXISTS (select 1 from ld_profileallpermission where tabid = @tabid and operation in (@tmp_downloadid,@tmp_previewid)) THEN
			OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO
				SET @profileid=tmp_profileid;
				IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation=@tmp_downloadid AND profileid=@profileid) THEN
					INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT @profileid,@tabid,@tmp_downloadid,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation=@tmp_downloadid AND profileid=@profileid)
    LIMIT 1;
END IF;
				IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation=@tmp_previewid AND profileid=@profileid) THEN
					INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT @profileid,@tabid,@tmp_previewid,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation=@tmp_previewid AND profileid=@profileid)
    LIMIT 1;
END IF;
FETCH MYCUSOR INTO tmp_profileid;
END WHILE;
CLOSE MYCUSOR;

set @max_sequence = (select MAX(sequence) from ld_profileallpermission where tabid = @tabid);
INSERT into ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@tmp_downloadid,@max_sequence+1 from DUAL where NOT EXISTS
                                                                  (SELECT 1 from ld_profileallpermission where tabid = @tabid AND operation = @tmp_downloadid);

INSERT into ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@tmp_previewid,@max_sequence+2 from DUAL where NOT EXISTS
                                                                 (SELECT 1 from ld_profileallpermission where tabid = @tabid AND operation = @tmp_previewid);
END IF;


END ||
delimiter;

CALL ldcrm_add_profile_for_workreport_download_preview();
DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_workreport_download_preview`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BriefReportStyle','简报生成样式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BriefReportStyle' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BriefReportStyle','Style of briefing generation','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BriefReportStyle' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BriefReportShowStyleWithHTML','HTML（不可编辑，有超链接）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BriefReportShowStyleWithHTML' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BriefReportShowStyleWithHTML','HTML (non editable, with hyperlinks)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BriefReportShowStyleWithHTML' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BriefReportShowStyleWithText','文本（可编辑无超链接）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BriefReportShowStyleWithText' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BriefReportShowStyleWithText','Text (editable without hyperlinks)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BriefReportShowStyleWithText' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_workreport','saleskit_showtype','varchar','50','');
call AddColumn('ld_workreport','saleskit_listinfo','text','','');
update ld_workreport set saleskit_showtype = 'text' where (saleskit_showtype is null or saleskit_showtype = '') and entitytype = 'workreport';
delimiter;

SET @labelbol = 'basepoolinfolabel';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'基础设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Basic Settings',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'publicpoolinfolabel';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海池管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Management of sea pools',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'publiclimitcountinfolabel';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海客户保有量',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Number of customers in the open sea',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'limitcountinfolabel';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'普通客户管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Ordinary customer management',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'listtabinfolabel';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海页签设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'High Seas Tab Settings',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'pulicpoolchecksave';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'有修改，是否保存？',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' has been modified, do you want to save it?',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

UPDATE ld_btnset SET tabid = 16 WHERE tabid = 9 AND btn_type = "detailbtn";
delimiter;


set @max_fieldid = (SELECT max(fieldid) from ld_settings_field);
set @blockid = (SELECT blockid from ld_settings_field where `name` = 'LBL_EXPRESS100_SETTINGS');
set @sequence = (SELECT sequence from ld_settings_field where `name` = 'LBL_EXPRESS100_SETTINGS');
INSERT INTO ld_settings_field(fieldid, blockid, `name`,description,linkto,sequence)
SELECT @max_fieldid+1, @blockid, 'LBL_WECHATSESSION_SETTINGS','会话存档接口设置','index.php?module=Settings&action=WechatSessionSetting&parenttab=Settings',@sequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_settings_field WHERE name = 'LBL_WECHATSESSION_SETTINGS');
SET @i=0;
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;
UPDATE ld_settings_field_seq SET id=(SELECT MAX(fieldid) FROM ld_settings_field);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_WECHATSESSION_SETTINGS','会话存档接口设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LBL_WECHATSESSION_SETTINGS' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_WECHATSESSION_SETTINGS','Session Archive Interface Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LBL_WECHATSESSION_SETTINGS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SessionBasicSettings','会话内容基础设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SessionBasicSettings' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SessionBasicSettings','Session content basic settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SessionBasicSettings' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FileStorageMode','文件存储方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'FileStorageMode' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FileStorageMode','File storage mode','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'FileStorageMode' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LocalServer','本地服务器','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LocalServer' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LocalServer','Local server','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LocalServer' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Bucketname','存储桶名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'Bucketname' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Bucketname','Bucketname','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'Bucketname' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Region','地域','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'Region' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Region','Region','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'Region' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','msgExceptionRemindSet','消息异常提醒设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'msgExceptionRemindSet' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','msgExceptionRemindSet','Message exception reminder setting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'msgExceptionRemindSet' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SessionNotUpdateSendMsg','会话内容未更新是否发送消息提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SessionNotUpdateSendMsg' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SessionNotUpdateSendMsg','Whether to send a message notification if the session content is not updated','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SessionNotUpdateSendMsg' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ClearWechatSessionSettingTip','注销后，将不再同步会话存档内容和发送消息异常提醒，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ClearWechatSessionSettingTip' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ClearWechatSessionSettingTip','After logging out, session archive content and message exception alerts will no longer be synchronized. Do you want to continue?','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ClearWechatSessionSettingTip' and Labeltype='jspop');
delimiter;

ALTER TABLE ld_wechatsession_conf MODIFY id INT(11);
delimiter;
ALTER TABLE ld_wechatsession_conf ALTER COLUMN receiverids SET DEFAULT '1';
UPDATE ld_wechatsession_conf SET receiverids = 1 WHERE receiverids = 'admin';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SQLtablecreatetip1','SQL中不允许select *，请写出查询的具体字段；','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SQLtablecreatetip1' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SQLtablecreatetip1','Select * is not allowed in SQL. Please specify the specific fields of the query;','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SQLtablecreatetip1' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SQLtablecreatetip2','为保证运算正确，请先在数据库工具中将SQL调试正确；','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SQLtablecreatetip2' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SQLtablecreatetip2','To ensure correct computation, please debug the SQL correctly in the database tool first;','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SQLtablecreatetip2' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SQLtablecreatetip3','SQL填写后，请点击执行语句来获取字段。','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SQLtablecreatetip3' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SQLtablecreatetip3','After filling out the SQL, please click on the execute statement to retrieve the fields.','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SQLtablecreatetip3' and labeltype='jspop' and languagetype='en');
delimiter;

update ld_field  SET value_format = '' where value_format = 'null';
delimiter;

SET @labelbol = 'DistributionRules';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'分配领取规则',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Distribution and Collection Rules',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;
-- 2024-11-01

call AddColumn('ld_equipment','product_id','int',19,'');

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Equipment';
SET @tablename='ld_equipment';
SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid=@tabid and blocklabel='LBL_EQUIPMENT_BASICINFORMATION';

SET @columnname='product_id';
SET @fieldname='product_id';
SET @zh='产品名称';
SET @uitype=59;
SET @bigtype='reference';
SET @readonly=0;
SET @presence=2;
SET @defaultvalue=NULL;
SET @displaytype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @quickcreatesequence=NULL;
SET @info_type='BAS';
SET @masseditable=2;
SET @allowhide='yes';
SELECT (sequence) + 1 INTO @field_seq FROM ld_field WHERE tabid=@tabid AND block=@blockid AND columnname='outboundorderid';
SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@field_seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='product_id' LIMIT 1);
SET @trantable='ld_field';
SET @zh='产品名称';
SET @en='Product Name';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @module='Products';
SET @rel_module='Equipment';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Products');
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Equipment');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template=CONCAT('get_',LOWER(@rel_module));
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,1,'add','datacategory_sql','equipment.product_id','[{"columnname":"equipment.product_id","comparator":"e","columncondition":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

UPDATE ld_field SET sequence = sequence + 1 WHERE tabid=@rel_tabid AND block=@blockid AND sequence > @field_seq
AND NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
delimiter;

SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='RenShiGuanLi' LIMIT 1);
DELETE FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tab_tablename='ld_linkmodulecustom';
delimiter;

UPDATE ld_tab SET presence=1 WHERE `name`='Equipment';
UPDATE ld_tab SET presence=5 WHERE `name`='ShoppingMall' AND presence=0;
UPDATE ld_tab SET presence=5 WHERE `name`='ProductProperty' AND presence=0 AND NOT EXISTS (SELECT 1 FROM ld_productproperty);
UPDATE ld_tab SET presence=5 WHERE `name`='PricePolicy' AND presence=0 AND NOT EXISTS (SELECT 1 FROM ld_pricepolicy);
UPDATE ld_tab SET presence=5 WHERE `name`='Competition' AND presence=0 AND NOT EXISTS (SELECT 1 FROM ld_competition);
UPDATE ld_tab SET presence=5 WHERE `name`='CollectionSlip' AND presence=0 AND NOT EXISTS (SELECT 1 FROM ld_collectionslip);
delimiter;
-- 2204-11-06

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

UPDATE ld_version SET old_version='V8.6.4.7',current_version='V8.6.4.7',remark='V8.6.4.7-20241101',wx_version='V8.6.5.0';
delimiter;