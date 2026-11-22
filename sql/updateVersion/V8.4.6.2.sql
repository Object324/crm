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

update ld_desk set fieldlabel='销售行为考核表' where fieldlabel='销售业绩考核表' and languagetype='zh' and labelbol='SalesSumSequence';
delimiter;

SET @labelbol = 'beforeoperationthisrecord2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该单据未审批，不允许升级为"{$Accounts.Accounts}"和"{$Potentials.Potentials}"单据！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'This document is not allowed to be upgraded to "{$Accounts.Accounts}" and "{$Potentials.Potentials}" document without approval!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk set  fieldlabel= 'Leads are upgraded to accounts and opportunities' where labelbol = 'LeadUgradeToPotentials' and languagetype = 'en';
delimiter;

update ld_dashboard_app set home_sequence = home_sequence + 100 where home_sequence>0;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence,home_presence,home_sequence) 
select 'commonmodules','commonmoduleslabel',NULL,'dashboard_10',0,1,1,1,0,'yes',1 from DUAL 
where not EXISTS(select 1 from ld_dashboard_app where `name` = 'commonmodules');
set @i=0;
update ld_dashboard_app set home_sequence=(@i:=@i+1) where  home_sequence>0 ORDER BY home_sequence ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','commonmoduleslabel','常用模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'commonmoduleslabel' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','commonmoduleslabel','Common module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'commonmoduleslabel' and labeltype = 'fixedstr');
delimiter;

update ld_dashboard_app set home_sequence = home_sequence + 100 where home_sequence>0;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence,home_presence,home_sequence) 
select 'commonmodules','commonmoduleslabel',NULL,'dashboard_10',0,1,1,1,0,'yes',1 from DUAL 
where not EXISTS(select 1 from ld_dashboard_app where `name` = 'commonmodules');
set @i=0;
update ld_dashboard_app set home_sequence=(@i:=@i+1) where  home_sequence>0 ORDER BY home_sequence ;
delimiter;

update ld_field LEFT JOIN ld_tab on ld_field.tabid=ld_tab.tabid LEFT JOIN ld_modentity_num on ld_modentity_num.semodule=ld_tab.`name` set editpage = 'listview'  where ld_field.uitype = 4 and ld_modentity_num.isallow = 1;
delimiter;

-- 2022-05-05

DROP PROCEDURE IF EXISTS `ldcrm_addfield_for_link2erp_20220323`;
delimiter ||
CREATE PROCEDURE `ldcrm_addfield_for_link2erp_20220323`(
)
BEGIN

	DECLARE tmp_module VARCHAR(100) DEFAULT NULL;
	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_block INT(19) DEFAULT 0;
	DECLARE tmp_table VARCHAR(100) DEFAULT NULL;

	
	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			b.`name` AS module,
			a.tabid,
			a.block,
			a.tablename
		FROM ld_field a
		LEFT JOIN ld_tab b ON b.tabid=a.tabid
		WHERE a.columnname='smownerid'
			AND a.tablename NOT IN ('ld_reminds','ld_activity','ld_notes')
		GROUP BY a.tabid
		ORDER BY a.tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_block,tmp_table;
	WHILE(tmp_tabid IS NOT NULL) DO
		CALl AddColumn(tmp_table,'kis_id','VARCHAR','200',NULL);
		CALl AddColumn(tmp_table,'kis_no','VARCHAR','200',NULL);

		SET @modulename=tmp_module;
		SET @tabid=tmp_tabid;
		SET @relateid=tmp_block;
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=tmp_table;
		SET @columnname='exchtime'; 
		SET @fieldname='exchtime'; 
		SET @zh='最新同步时间'; 
		SET @en='最新同步时间'; 
		SET @uitype=86; 
		SET @typeofdata='DT~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype='datetime';
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,@columnname,'DATETIME','50','');


		SET @modulename=tmp_module;
		SET @tabid=tmp_tabid;
		SET @relateid=tmp_block;
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=tmp_table;
		SET @columnname='exchmsg'; 
		SET @fieldname='exchmsg'; 
		SET @zh='最新同步结果'; 
		SET @en='最新同步结果'; 
		SET @uitype=19; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype='longtextarea';
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,@columnname,'TEXT','50','');

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);

		SET @query_sql=CONCAT("ALTER TABLE ",tmp_table," MODIFY COLUMN exchtime datetime AFTER kis_no");
		PREPARE mysmt FROM @query_sql;
		EXECUTE mysmt;
		DEALLOCATE PREPARE mysmt;

		SET @query_sql=CONCAT("ALTER TABLE ",tmp_table," MODIFY COLUMN exchmsg TEXT AFTER exchtime");
		PREPARE mysmt FROM @query_sql;
		EXECUTE mysmt;
		DEALLOCATE PREPARE mysmt;

		FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_block,tmp_table;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_addfield_for_link2erp_20220323();
DROP PROCEDURE IF EXISTS `ldcrm_addfield_for_link2erp_20220323`;
delimiter;

CALl AddColumn('ld_salesorderdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_servicecontractsdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_quotesdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_salesbackdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_purchaseorderdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_purchasebackdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_outboundorderdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_stockdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_warehousetransferdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_purchaseinvoicedetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_invoicedetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_cashbackdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_purchasecashbackdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_productbomdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_quoteschangedetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_purchaseinquiryorderdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform11detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform12detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform13detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform14detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform15detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform16detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform17detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform18detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform19detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform20detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_potentialsdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform36detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform37detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform38detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform39detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform40detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform41detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform42detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform43detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform44detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform45detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_worksheetdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_budgetchangedetail','erpentryid','VARCHAR','100',NULL);
delimiter;

CALl AddColumn('ld_cashbill2paymentplan','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_expensedetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_sendcashbill2payment','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_commission2payment','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_timesheetdetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_addjobbilldetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_minusjobbilldetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_businessapplydetail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform21detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform22detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform23detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform24detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform25detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform26detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform27detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform28detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform29detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform30detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform31detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform32detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform33detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform34detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_customform35detail','erpentryid','VARCHAR','100',NULL);
CALl AddColumn('ld_expensebudgetdetail','erpentryid','VARCHAR','100',NULL);
delimiter;

UPDATE ld_desk SET fieldlabel='移动端工作台定制' WHERE labelbol='mobile_home_setting' AND fieldlabel='移动端首页定制' AND languagetype='zh';


update ld_producttoolfield set bigtype='num' where uitype=10;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
DELIMITER ;;
CREATE  PROCEDURE `ldcrm_approvereminds_remindtitle_add`(
)
BEGIN
	declare var_id int(100);
	DECLARE var_type varchar(100);
	DECLARE var_reminduser varchar(100);
	DECLARE var_remindmethod varchar(100);
	DECLARE var_title varchar(100);
	DECLARE var_tabid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select ld_approvereminds.id as tmp_id,ld_approvereminds.type,ld_approvereminds.reminduser,ld_approvereminds.remindmethod,ld_approvereminds.remindtitle as tmp_title,tmp_table.tabid as tmp_tabid from ld_approvereminds LEFT JOIN (SELECT ld_approvestep.id AS stepid,ld_approve.tabid AS tabid from ld_approvestep LEFT JOIN ld_approve ON ld_approve.id=ld_approvestep.approveid ) AS tmp_table ON tmp_table.stepid = ld_approvereminds.stepid;
		declare continue handler  for not   found  SET done =1;
	OPEN cur1;

	 Fetch cur1 into var_id,var_type,var_reminduser,var_remindmethod, var_title,var_tabid;
	 loop1: while  done<>1 DO
		if var_title is null and var_remindmethod in ('dialog','weiin') then
			set @modulename = (select fieldlabel from ld_tranlabel where tabid = var_tabid and languagetype = 'zh' and trantable = 'ld_tab');
			if var_type=0 and var_reminduser='approver' THEN
			 update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批提醒') where ld_approvereminds.id=var_id;
			elseif var_type=0 and var_reminduser='selectuser'  THEN
				update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批抄送提醒') where ld_approvereminds.id=var_id;
			elseif var_type=1 and var_reminduser='smowner'  THEN
				update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批结果通知') where ld_approvereminds.id=var_id;
			elseif var_type=1 and var_reminduser in ('smcreator','selectuser')  THEN
				update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批结果提醒') where ld_approvereminds.id=var_id;
			elseif var_type=2 THEN
				update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批结果提醒') where ld_approvereminds.id=var_id;
			end if;
	end if;
   Fetch cur1 into var_id,var_type,var_reminduser,var_remindmethod, var_title,var_tabid;
	end while loop1;
	close cur1;
end
;;
DELIMITER ;
CALL ldcrm_approvereminds_remindtitle_add();
DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
DELIMITER ;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TheFunctionality','函数功能','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TheFunctionality' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TheFunctionality','The functionality','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TheFunctionality' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ParameterField','参数字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ParameterField' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ParameterField','Parameter field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ParameterField' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Avg','取平均值','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Avg' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Avg','Avg','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Avg' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CountDistinct','去重计数','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CountDistinct' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CountDistinct','CountDistinct','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CountDistinct' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FirstLine','取第一行','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FirstLine' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FirstLine','First line','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FirstLine' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LastLine','取最后一行','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LastLine' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LastLine','Last line','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LastLine' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Max','取最大值','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Max' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Max','Max','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Max' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Min','取最小值','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Min' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Min','Min','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Min' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Summation','求和','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Summation' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Summation','Sum','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Summation' and labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','INVENTORY','库存','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INVENTORY' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','INVENTORY',' Stock','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INVENTORY' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SEARCHINVENTORY','查库存','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SEARCHINVENTORY' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SEARCHINVENTORY',' Inventory','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SEARCHINVENTORY' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SEARCHINVENTORY','查库存','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SEARCHINVENTORY' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SEARCHINVENTORY',' Inventory','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SEARCHINVENTORY' and labeltype='fixedstr');
delimiter;

SET @wx_sequence = (select max(wx_sequence)+1 from ld_dashboard_app);
SET @home_sequence = (select max(home_sequence)+1 from ld_dashboard_app);

select wx_sequence into @sequence from ld_dashboard_app where name='search_erp_stcok';
update ld_dashboard_app set wx_sequence=wx_sequence+2;
insert into ld_dashboard_app(name,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence,home_presence,home_sequence)
select 'search_erp_stcok','search_erp_stcok','','dashboard_10',0,1,@sequence+1,0,0,'no',@home_sequence  from dual
where not EXISTS(select 1 from ld_dashboard_app where name='search_erp_stcok');
delimiter;
select blockid into @blockid from ld_appparenttab where parenttab_label='Reports';
select id into @tabid from ld_dashboard_app where name='search_erp_stcok';
select max(sequence) into @maxsequence from ld_appparenttabrel;
insert into ld_appparenttabrel(blockid,tabid,sequence,relatename)
select @blockid,@tabid,1,'search_erp_stcok' from dual where not EXISTS(select 1 from ld_appparenttabrel where relatename='search_erp_stcok');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','search_erp_stcok','金蝶库存查询_移动端','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='search_erp_stcok' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','search_erp_stcok','KingDee search stock','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='search_erp_stcok' and Labeltype='fixedstr');
delimiter;


SET @sequence = (select max(sequence)+1 from ld_mobile_report_tab_rel);
select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='sales';
select id into @reportid from ld_dashboard_app where name = 'search_erp_stcok';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename) select @block_id,@reportid,1,'ld_tab'
from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
delimiter;

insert into ld_linkmodulecustom(zh_label,en_label,url,`status`,scope,entitytype,linkcvid,authcheck,paramvalue)
select '金蝶库存查询（PC）','金蝶库存查询（PC）','index.php?module=Customreport&action=CustomreportAjax&file=stock_report','yes','all','custom',0,'no','null' from dual 
where not exists(select 1 from ld_linkmodulecustom where entitytype = 'custom' and url = 'index.php?module=Customreport&action=CustomreportAjax&file=stock_report');
delimiter;
-- 2022-05-10

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

UPDATE ld_version SET old_version='V8.4.6.2',current_version='V8.4.6.2',remark='V8.4.6.2-20220511',wx_version='V8.4.6.2';
delimiter;