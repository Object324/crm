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

call AddColumn('ld_equipment','product_id','int',19,'');
delimiter;

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

SET @disable_triggers = 'zkt';
call AddColumn('ld_account','currency_id','int',4,1);
call AddColumn('ld_account','conversion_rate','decimal','12','0');
ALTER TABLE ld_account MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_account','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_attachmentsforbills','currency_id','int',4,1);
call AddColumn('ld_attachmentsforbills','conversion_rate','decimal','12','0');
ALTER TABLE ld_attachmentsforbills MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_attachmentsforbills','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_notes','currency_id','int',4,1);
call AddColumn('ld_notes','conversion_rate','decimal','12','0');
ALTER TABLE ld_notes MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_notes','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_activity','currency_id','int',4,1);
call AddColumn('ld_activity','conversion_rate','decimal','12','0');
ALTER TABLE ld_activity MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_activity','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_workreport','currency_id','int',4,1);
call AddColumn('ld_workreport','conversion_rate','decimal','12','0');
ALTER TABLE ld_workreport MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_workreport','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_leads','currency_id','int',4,1);
call AddColumn('ld_leads','conversion_rate','decimal','12','0');
ALTER TABLE ld_leads MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_leads','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;
SET @disable_triggers = 'zkt';
call AddColumn('ld_contactrecords','currency_id','int',4,1);
call AddColumn('ld_contactrecords','conversion_rate','decimal','12','0');
ALTER TABLE ld_contactrecords MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_contactrecords','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_channelcode','currency_id','int',4,1);
call AddColumn('ld_channelcode','conversion_rate','decimal','12','0');
ALTER TABLE ld_channelcode MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_channelcode','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_reminds','currency_id','int',4,1);
call AddColumn('ld_reminds','conversion_rate','decimal','12','0');
ALTER TABLE ld_reminds MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_reminds','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;


set @parenttab_label = 'Settings';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE `parenttab_label`=@parenttab_label);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_parenttab',@parenttabid,@parenttabid,'用户和权限管理' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@parenttabid AND relateid=@parenttabid AND languagetype='zh' AND trantable='ld_parenttab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_parenttab',@parenttabid,@parenttabid,'User and permission management' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@parenttabid AND relateid=@parenttabid AND languagetype='en' AND trantable='ld_parenttab');
delimiter;

update ld_parenttab set imagename = 'left_nav_set_ico.png',fonticon='&#xe607;',fonticon_active='&#xe604;' where parenttab_label = 'Settings';
delimiter;

UPDATE ld_systems_deploy set setype = '' where deploy_type = '485';
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_reminds_accepted','currency_id','int',4,1);
call AddColumn('ld_reminds_accepted','conversion_rate','decimal','12','0');
ALTER TABLE ld_reminds_accepted MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_reminds_accepted','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SELECT MAX(sequence) INTO @sequence FROM ld_systems_deploy;
set @deploy_type = 491;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 'yes',@deploy_type,'待审批消息通知是否推送到钉钉待办中','',@sequence+1,'4','select',0,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@deploy_type);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@deploy_type,@deploy_type,'待审批消息通知是否推送到钉钉待办中'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_systems_deploy' and tabid = @deploy_type and relateid=@deploy_type);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@deploy_type,@deploy_type,'Whether the notification of the pending approval message is pushed to Dingding to-do'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_systems_deploy' and tabid = @deploy_type and relateid=@deploy_type);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TimeFieldHeplTip1','1、只改变时间展示类型，时间新建/编辑时还是选择{Var}','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TimeFieldHeplTip1' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TimeFieldHeplTip1',"1. Only change the time display type, and choose '{Var}' when creating/editing time",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TimeFieldHeplTip1' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TimeFieldHeplTip2','2、查重时会根据具体选择的{Var}进行査重 ','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TimeFieldHeplTip2' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TimeFieldHeplTip2',"2. When checking for plagiarism, it will be based on the specific selection of '{Var}'",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TimeFieldHeplTip2' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DINGDINGINTERFACEDELETETIP','注销后，钉钉CRM应用将无法使用，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'DINGDINGINTERFACEDELETETIP' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DINGDINGINTERFACEDELETETIP','After cancellation, the DingTalk CRM application will no longer be available. Do you want to continue? ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'DINGDINGINTERFACEDELETETIP' and languagetype='en' and labeltype = 'jspop');
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_equipment','currency_id','int',4,1);
call AddColumn('ld_equipment','conversion_rate','decimal','12','0');
ALTER TABLE ld_equipment MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_equipment','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_singin','currency_id','int',4,1);
call AddColumn('ld_singin','conversion_rate','decimal','12','0');
ALTER TABLE ld_singin MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_singin','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;

SET @disable_triggers = 'zkt';
call AddColumn('ld_signout','currency_id','int',4,1);
call AddColumn('ld_signout','conversion_rate','decimal','12','0');
ALTER TABLE ld_signout MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_signout','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;


SET @disable_triggers = 'zkt';
call AddColumn('ld_contactdetails','currency_id','int',4,1);
call AddColumn('ld_contactdetails','conversion_rate','decimal','12','0');
ALTER TABLE ld_contactdetails MODIFY COLUMN conversion_rate DECIMAL(12,6);
call AddColumn('ld_contactdetails','currency_symbol','varchar','30','');
SET @disable_triggers = NULL;
delimiter;


update ld_desk set fieldlabel='审批中心' where labelbol='PendingApproval' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Approve' where labelbol='PendingApproval' and languagetype='en' and Labeltype='fixedstr';
delimiter;

SET @labelbol = 'publiclimitcountinfolabel';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海客户保有量',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Number of customers in the open sea',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'limitcountinfolabel';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'普通客户管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Ordinary customer management',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'publiclimitcountinfolabellead';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海线索保有量',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Number of leads in the open sea',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'limitcountinfolabellead';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'普通线索管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Ordinary lead management',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'Pleaseentername';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入公海名称',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the name',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SQLtablecreatetip4',"如果使用存储过程需要分页,请预留两个分页参数(顺序不做要求),调用示例：call myprocedure('{offset}','{limit}');",'jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SQLtablecreatetip4' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SQLtablecreatetip4',"If you need paging using stored procedures, please reserve two paging parameters (the order is not required)， call the example：call myprocedure('{offset}','{limit}');",'jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SQLtablecreatetip4' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXCELHEADER','Excel表头','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXCELHEADER' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXCELHEADER',"Excel Header",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXCELHEADER' and labeltype='fixedstr');
delimiter;


set @tmptablename='ld_productproperty';
CALL AddColumn (@tmptablename, 'approvesubmittedtime', 'datetime', '', '');
CALL AddColumn (@tmptablename, 'approvesubmitter', 'int', '19', '0');
CALL AddColumn (@tmptablename, 'currentapprovestepid', 'int', '19', '0');
CALL AddColumn (@tmptablename, 'approveurgent', 'varchar', '10', 'no');
CALL AddColumn (@tmptablename, 'approveexpediting', 'varchar', '10', 'no');
CALL AddColumn (@tmptablename, 'approveby', 'int', '19', '0');
delimiter;

UPDATE ld_desk set fieldlabel = '经销商门户' where labelbol = 'CUSTOMIZED_DEALER_CHANNELS' and languagetype = 'zh';
set @sequence = (select sequence from ld_settings_blocks where label = 'ENTERPRISE_MANAGEMENT');
UPDATE ld_settings_blocks set sequence = @sequence + 1 where label = 'CUSTOMIZED_DEALER_CHANNELS';
UPDATE ld_settings_blocks set sequence = @sequence + 2 where label = 'LBI_UI_SETTINGS';
set @sequence_new = @sequence + 2;
UPDATE ld_settings_blocks set sequence = (@sequence_new:=@sequence_new + 1) where sequence > @sequence and label<>'CUSTOMIZED_DEALER_CHANNELS' and label<>'LBI_UI_SETTINGS';
UPDATE ld_desk set fieldlabel = '界面定制' where labelbol = 'LBI_UI_SETTINGS' and languagetype = 'zh';
UPDATE ld_desk set fieldlabel = '系统日志' where labelbol = 'EnterpriseLogs' and languagetype = 'zh';
UPDATE ld_desk set fieldlabel = 'System Logs' where labelbol = 'EnterpriseLogs' and languagetype = 'en';
set @blockid = (SELECT blockid from ld_settings_blocks where label = 'LBL_INTERFACE_SETTINGS');
set @seq = (select sequence from ld_settings_field where blockid = @blockid and `name` = 'addressbook_setting');
set @seqnew = @seq + 1;
UPDATE ld_settings_field set sequence = @seqnew where blockid = @blockid and `name` = 'wxselfbuiltapp_setting';
UPDATE ld_settings_field set sequence = (@seqnew:=@seqnew + 1) where blockid = @blockid and sequence > @seq and `name` <> 'wxselfbuiltapp_setting';
set @seq2 = (select sequence from ld_settings_field where blockid = @blockid and `name` = 'weixinpay_setting');
set @seqnew2 = @seq2 + 1;
UPDATE ld_settings_field set sequence = @seqnew2 where blockid = @blockid and `name` = 'LBL_WECHATSESSION_SETTINGS';
UPDATE ld_settings_field set sequence = (@seqnew2:=@seqnew2 + 1) where blockid = @blockid and sequence > @seq2 and `name` <> 'LBL_WECHATSESSION_SETTINGS';
delimiter;
-- 2024-11-10

DROP PROCEDURE IF EXISTS `updateloginswiperdefault`;
delimiter ||
CREATE PROCEDURE `updateloginswiperdefault`(
)

BEGIN
		declare loginnum int default 0;
		set loginnum = (select count(login_id) from ld_loginhistory);

		IF loginnum < 5 THEN
				update ld_loginsettingsinfo set isshow = 'no' where `name` = 'loginswiper' and type = 'default' and (content like '%defaultloginswiper2.png' or content like '%defaultloginswiper1.png');
		END IF;


end ||
delimiter;

CALL updateloginswiperdefault();
DROP PROCEDURE IF EXISTS `updateloginswiperdefault`;
delimiter;

update ld_desk set fieldlabel = '客户转到本公海后，更改负责人为' where labelbol = 'AFTERCONVERTINGMODIFYTHEOWNER' and languagetype = 'zh';
update ld_desk set fieldlabel = 'After converting common accounts to the unassigned accounts, modify the owner as' where labelbol = 'AFTERCONVERTINGMODIFYTHEOWNER' and languagetype = 'en';
SET @labelbol = 'AFTERCONVERTINGMODIFYTHEOWNERDES';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'只能选择公海成员，为空表示不更改',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'do nothing if empty',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

update ld_desk set fieldlabel = '公海已分配{$Accounts.Accounts}释放后，更改{$Accounts.Accounts}负责人为' where labelbol = 'AFTERRELEASINGTHEALLOCATEDHIGNSEAS' and languagetype = 'zh';
update ld_desk set fieldlabel = 'After releasing the allocated unassigned customers, modify the owner as' where labelbol = 'AFTERRELEASINGTHEALLOCATEDHIGNSEAS' and languagetype = 'en';
SET @labelbol = 'AFTERRELEASINGTHEALLOCATEDHIGNSEASDES';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'为空表示不更改',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'do nothing if empty',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

update ld_desk set fieldlabel = '{$Leads.Leads}转到本公海后，更改负责人为' where labelbol = 'AfterConvertingModfyTheLeadsOwner' and languagetype = 'zh';
update ld_desk set fieldlabel = 'After the {$Leads.Leads} is transferred to the high seas, the person in charge of the change' where labelbol = 'AfterConvertingModfyTheLeadsOwner' and languagetype = 'en';
SET @labelbol = 'AfterConvertingModfyTheLeadsOwnerDES';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'只能选择公海成员，为空表示不更改',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'only the high seas member can be selected, if it is blank, it means not to change',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

update ld_desk set fieldlabel = '公海已分配{$Leads.Leads}释放后，更改销售线索负责人为' where labelbol = 'AfterReleasignTheAllocatedHighSeasOfLeads' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Change the person in charge of the {$Leads.Leads} after the sales lead has been released' where labelbol = 'AfterReleasignTheAllocatedHighSeasOfLeads' and languagetype = 'en';
SET @labelbol = 'AfterReleasignTheAllocatedHighSeasOfLeadsDES';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'为空表示不更改',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'blank means no change',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProduct','导入产品信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProduct' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProduct','Import product information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProduct' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProductImage','导入产品图片','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImage' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProductImage','Import product images','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImage' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProductImageNoImageField','当前模块没有可导入的图片字段，请联系管理员！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageNoImageField' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProductImageNoImageField','There are no image fields available for import in the current module. Please contact the administrator!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageNoImageField' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProductImageTip1','支持批量导入多个产品的图片，每个产品最多支持 10 张图','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTip1' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProductImageTip1','support the batch introduction of pictures of multiple products, each product supports a maximum of 10 pictures','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTip1' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProductImageTip2','每次导入的图片数量推荐一次在500张内','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTip2' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProductImageTip2','The recommended number of images to be introduced each time is within 500','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTip2' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProductImageTip3','商品图片的命名应与商品名称或商品编码保持一致','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTip3' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProductImageTip3','The naming of product pictures should be consistent with the product name or product code.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTip3' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProductImageTipSelectImageField','请选择需要导入的图片字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTipSelectImageField' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProductImageTipSelectImageField','Please select the image fields to be imported','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTipSelectImageField' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProductImageTipSelectNamingField','请选择商品图片的命名格式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTipSelectNamingField' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProductImageTipSelectNamingField','Please select the naming format of the product images','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageTipSelectNamingField' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ForExample','示例','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ForExample' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ForExample','For example','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ForExample' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SupportFormat','支持{Var}等格式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SupportFormat' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SupportFormat','Support {Var} and and other formats','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SupportFormat' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ClickOrDrageToUpload','点击或拖拽上传','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ClickOrDrageToUpload' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ClickOrDrageToUpload','Click or drag to upload','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ClickOrDrageToUpload' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProductImageFieldCanNotUse','导入字段不可用，请重新选择!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageFieldCanNotUse' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProductImageFieldCanNotUse','The imported field is not available, please select again!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProductImageFieldCanNotUse' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportProgressTip','数据正在导入中，估计剩余时间...','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProgressTip' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportProgressTip','Data is being imported, estimated remaining time...','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportProgressTip' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportFailedReason','"{Var}"导入失败,原因：','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportFailedReason' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportFailedReason',"Import of '{Var}' failed, reason: ",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportFailedReason' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportFailedReasonNoRecord','未找到匹配的产品','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportFailedReasonNoRecord' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportFailedReasonNoRecord',"No matching product found",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportFailedReasonNoRecord' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportFailedReasonNotUnique','匹配的产品不唯一','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportFailedReasonNotUnique' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportFailedReasonNotUnique',"The matching product is not unique",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportFailedReasonNotUnique' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportFailedReasonOverLimit','该产品导入的图片数量已超过限制','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportFailedReasonOverLimit' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportFailedReasonOverLimit',"The number of imported images for this product has exceeded the limit",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportFailedReasonOverLimit' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImageImportSuccessfully','"{Var}"导入成功','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportSuccessfully' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImageImportSuccessfully',"'{Var}' has been successfully imported",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportSuccessfully' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImageImportTimeTip','共有{Var}个图片导入，预计剩余时间为','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImageImportTimeTip',"There are a total of {Var} images imported, with an estimated remaining time of ",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImageImportTimeFinishTip1','共有{Var}个图片，成功导入{Var}个图片','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishTip1' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImageImportTimeFinishTip1',"There are a total of {Var} images, {Var} images were successfully imported ",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishTip1' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImageImportTimeFinishTip2','导入失败{Var}个图片','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishTip2' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImageImportTimeFinishTip2'," and {Var} images failed to import",'jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishTip2' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImageImportTimeFinishDownloadTip','下载日志，查看错误原因','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishDownloadTip' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImageImportTimeFinishDownloadTip',"There are a total of {Var} images, {Var} images were successfully imported, and {Var} images failed to import",'jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishDownloadTip' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportImageLog','导入图片日志','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportImageLog' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportImageLog',' Import image log','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportImageLog' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportImageLog','导入图片日志','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportImageLog' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportImageLog',' Import image log','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImportImageLog' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_tranlabel set fieldlabel = 'Customer searching' where trantable = 'ld_parenttab' and languagetype = 'en' and Relateid = (select parenttabid from ld_parenttab where parenttab_label = 'LDsoukebao');
delimiter;

CALL AddColumn('ld_field','is_encrypt','varchar','10','no');
delimiter;

SET @labelbol = 'Decrypt';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'解密',@labeltype FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Decrypt',@labeltype FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

UPDATE ld_field SET bigtype = 'picklist' WHERE uitype = '15';
UPDATE ld_producttoolfield SET bigtype = 'picklist' WHERE uitype = '15';
UPDATE ld_field SET bigtype = 'users' WHERE uitype = '153';
delimiter;



SET @tmp_modulename = 'Equipment';
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @tmp_modulename;
SET @i = (SELECT MAX(sequence) FROM ld_profileallpermission WHERE tabid=@tabid);

INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE actionname IN ('Advance','DownLoad','Preview','DownloadSelected')
AND NOT EXISTS (SELECT 1 FROM ld_profileallpermission INNER JOIN ld_actionmapping ON ld_actionmapping.actionid = ld_profileallpermission.operation WHERE tabid=@tabid AND actionname = 'Advance');
delimiter;

UPDATE ld_desk set fieldlabel = '启用自动回收规则' where labelbol = 'Enablecommoncustomerautomaticreclaimrules' and languagetype = 'zh';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Mergemethod','合并方式','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Mergemethod' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Mergemethod','Merge method','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Mergemethod' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Donotmerge','不合并','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Donotmerge' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Donotmerge','Do not merge','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Donotmerge' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Accordingtospecifiedfields','按指定字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Accordingtospecifiedfields' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Accordingtospecifiedfields','According to specified fields','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Accordingtospecifiedfields' and labeltype='jspop');
delimiter;


ALTER TABLE ld_customtable_columns MODIFY is_merge VARCHAR(255);

update ld_customtable_columns set is_merge=`columns` where is_merge='yes';
delimiter;

UPDATE ld_producttoolfield
INNER JOIN ld_field on ld_field.columnname=ld_producttoolfield.columnname AND ld_field.tabid=14 AND ld_field.columnname!='productname'
SET ld_producttoolfield.input_type=1,ld_producttoolfield.fieldid=ld_field.fieldid
WHERE (ld_producttoolfield.tablename = 'ld_products' OR ld_producttoolfield.tablename = 'ld_productcf') AND ld_producttoolfield.input_type =0;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','RECYCLINGSCOPE','回收范围','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RECYCLINGSCOPE' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','RECYCLINGSCOPE','Recycling Scope','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RECYCLINGSCOPE' and labeltype='fixedstr');
delimiter;
-- 2024-11-17

CALL AddColumn('ld_contactdetails','mailingarea','varchar','100','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MSWHttpOrHttps','必须以”http:“或者”https:“作为开始','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MSWHttpOrHttps' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MSWHttpOrHttps','must start with "http:" or "https:"','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MSWHttpOrHttps' and labeltype='jspop');
delimiter;
-- 2024-11-20


SET @labelbol = 'APPROVESTATUS_UNAPPROVED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未提交','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'未提交','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPROVESTATUS_APPROVALOF';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批中','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'审批中','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPROVESTATUS_APPROVED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已批准','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'已批准','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPROVESTATUS_DISMISSED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已驳回','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'已驳回','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPROVESTATUS_REJECTED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已拒绝','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'已拒绝','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_translatefield','value_color','varchar','30',NULL);
delimiter;

UPDATE ld_field set bigtype = 'translatefield' where columnname = 'approvestatus';
delimiter;

insert into ld_translatefield(columnname,column_dbvalue,module,labelbol)
select 'approvestatus','未提交','lingdang','APPROVESTATUS_UNAPPROVED' from dual
where not exists(select 1 from ld_translatefield where module='lingdang' and columnname='approvestatus' and labelbol='APPROVESTATUS_UNAPPROVED');
delimiter;
insert into ld_translatefield(columnname,column_dbvalue,module,labelbol)
select 'approvestatus','审批中','lingdang','APPROVESTATUS_APPROVALOF' from dual
where not exists(select 1 from ld_translatefield where module='lingdang' and columnname='approvestatus' and labelbol='APPROVESTATUS_APPROVALOF');
delimiter;
insert into ld_translatefield(columnname,column_dbvalue,module,labelbol)
select 'approvestatus','已批准','lingdang','APPROVESTATUS_APPROVED' from dual
where not exists(select 1 from ld_translatefield where module='lingdang' and columnname='approvestatus' and labelbol='APPROVESTATUS_APPROVED');
delimiter;
insert into ld_translatefield(columnname,column_dbvalue,module,labelbol)
select 'approvestatus','已驳回','lingdang','APPROVESTATUS_DISMISSED' from dual
where not exists(select 1 from ld_translatefield where module='lingdang' and columnname='approvestatus' and labelbol='APPROVESTATUS_DISMISSED');
delimiter;
insert into ld_translatefield(columnname,column_dbvalue,module,labelbol)
select 'approvestatus','已拒绝','lingdang','APPROVESTATUS_REJECTED' from dual
where not exists(select 1 from ld_translatefield where module='lingdang' and columnname='approvestatus' and labelbol='APPROVESTATUS_REJECTED');
delimiter;

SET @labelbol = 'APPROVALSTATUSSETTING';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批状态设置',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Approval status setting',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ORIGINALNAME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'原名称',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Original name',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'NORMALNAME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'名称',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Name',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'APPLIEDALLAPPROVAL';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置后将应用于所有模块的审批状态上，是否继续？',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After setting, it will be applied to the approval status of all modules. Do you want to continue?',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

update ld_desk set fieldlabel = 'Support {Var} and other formats' where languagetype = 'en' and labelbol = 'SupportFormat' and labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Download the log and view the reason for the error' where languagetype = 'en' and labelbol = 'ImageImportTimeFinishDownloadTip' and labeltype = 'jspop';
delimiter;

update ld_customreport set sqlstr=REPLACE(sqlstr,'\'%2023%\'','CONCAT(\'%\',YEAR(NOW()),\'%\')') where primaryname = 'product_contracted_quantity_y_to_y';
delimiter;

SET @labelbol = 'COUNTDURINGTHISSTAGE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'仅统计该阶段下创建的单据',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Only count the documents created during this stage',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'COUNTALLDOCUMENTS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'统计所有历史单据',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Count all historical documents',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

UPDATE ld_desk SET fieldlabel = '仅统计最新进入该阶段后创建的单据' where labelbol = 'COUNTFIRSTAFTERENTERING' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Only count the latest documents created after entering this stage' where labelbol = 'COUNTFIRSTAFTERENTERING' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;


update ld_stuff set stufftype='transaction' where stuffid=33;
delimiter;

update ld_desk set fieldlabel='Approve Center' where labelbol='PendingApproval' and labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='Approve Center' where labelbol='APPROVAL' and labeltype='jspop' and languagetype='en';
update ld_desk set fieldlabel='审批中心' where labelbol='APPROVAL' and labeltype='jspop' and languagetype='zh';
delimiter;
-- 2024-11-21


UPDATE ld_field SET tablename = 'ld_activity' WHERE tabid = 9 AND columnname = 'contactid' AND uitype = 57;
delimiter;

SET @labelbol = 'IsNotDelAdvanceTiledRow';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'操作后，平铺的筛选条件将一并删除，是否继续？','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After the operation, the tiled filtering criteria will be deleted together. Do you want to continue?','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'ClearTiledFilterValues';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'清除平铺筛选值','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Clear tiled filter values','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ClearFilterValues';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'清除筛选值','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Clear Filter Values','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COORDINATECONVERSIONFAILED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'坐标转换失败','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Coordinate conversion failed','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

set @tmp_blockid = (SELECT blockid FROM ld_settings_blocks WHERE  `label` = 'EnterpriseLogs');
set @tmp_seq = (SELECT sequence FROM ld_settings_field WHERE blockid = @tmp_blockid AND `name` = 'OperationLogs');
UPDATE ld_settings_field SET sequence = @tmp_seq + 1 WHERE `name` = 'ImportExportLogs';
delimiter;
-- 2024-11-25

SET @i=0;
SET @tabid=(SELECT tabid FROM ld_tab WHERE name='SalesBack');
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Sales');
SET @order_seq=(SELECT sequence FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=22);
SET @back_seq=(SELECT sequence FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);
UPDATE ld_parenttabrel SET sequence=sequence+2 WHERE parenttabid=@parenttabid AND sequence>@order_seq AND @order_seq>0;
UPDATE ld_parenttabrel SET sequence=@order_seq+1 WHERE parenttabid=@parenttabid AND tabid=@tabid AND @order_seq>0 AND @back_seq>0 AND @order_seq<@back_seq;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;
delimiter;

update ld_desk set fieldlabel='Clear filter values' where labelbol='ClearTiledFilterValues' and labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='清除筛选值' where labelbol='ClearTiledFilterValues' and labeltype='fixedstr' and languagetype='zh';
delimiter;

DELETE from ld_cvadvfilter where cvid not in (SELECT cvid from ld_customview);
DELETE from ld_cvadvfilter_grouping where cvid not in (SELECT cvid from ld_customview);
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

UPDATE ld_version SET old_version='V8.6.4.8',current_version='V8.6.4.8',remark='V8.6.4.8-20241125',wx_version='V8.6.5.0';
delimiter;