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
-- 2022-05-10

update  ld_producttoolfield set bigtype='num' where uitype=10;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
delimiter ||
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

end ||
delimiter;

CALL ldcrm_approvereminds_remindtitle_add();
DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
delimiter;

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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','search_erp_stcok','金蝶库存查询_移动端','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='search_erp_stcok' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','search_erp_stcok','KingDee search stock','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='search_erp_stcok' and Labeltype='fixedstr');
delimiter;

insert into ld_linkmodulecustom(zh_label,en_label,url,`status`,scope,entitytype,linkcvid,authcheck,paramvalue)
select '金蝶库存查询（PC）','金蝶库存查询（PC）','index.php?module=Customreport&action=CustomreportAjax&file=stock_report','yes','all','custom',0,'no','null' from dual
where not exists(select 1 from ld_linkmodulecustom where entitytype = 'custom' and url = 'index.php?module=Customreport&action=CustomreportAjax&file=stock_report');
delimiter;

SET @labelbol = 'beforeoperationthisrecord2';
DELETE from ld_desk where labelbol = @labelbol;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该单据未审批，不允许升级为"{$Accounts.Accounts}"和"{$Potentials.Potentials}"单据！','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'This document is not approved and cannot be upgraded to "{$Accounts.Accounts}" and "{$Potentials.Potentials}" documents!','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

update  ld_linkmodulecustom set linkmodule=replace(linkmodule,'CustomReport','Customreport') where  linkmodule='CustomReport';
delimiter;
-- 2022-05-15

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','shopping','订货商城','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='shopping' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','shopping','Shopping','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='shopping' and labeltype='fixedstr');
delimiter;

select blockid,sequence into @blockid,@sequence from ld_appparenttabrel where tabid = 22 LIMIT 1;
update ld_appparenttabrel set sequence = sequence + 1000 where blockid = @blockid and sequence > @sequence;
insert into ld_appparenttabrel(blockid,tabid,sequence,tab_tablename) 
select @blockid,-12,@sequence+1,'ld_tab' from DUAL 
where not exists(select 1 from ld_appparenttabrel where tabid = -12);
set @i =0 ;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence asc;
delimiter;

SET @modulename='SalesOrder';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where fieldname = 'assigned_user_id' and tabid = @tabid);
SET @sequence=(select max(sequence) + 1 from ld_field where block = @relateid and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_salesorder';
SET @columnname='order_source';
SET @fieldname='order_source';
SET @zh='订单来源';
SET @en='Order Source';
SET @uitype=15;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='picklist';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@sequence,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

call AddColumn('ld_salesorder','order_source','varchar','20','null');
delimiter;

update ld_salesorder set order_source = '合同模块' where IFNULL(order_source,'') = '';
delimiter;

insert into ld_picklist_set(listname,relatetable,picklist_allowedit)
select 'order_source','ld_field','yes' from dual 
where not exists(select 1 from ld_picklist_set where listname = 'order_source' and relatetable = 'ld_field');
delimiter;

select listid into @listid from ld_picklist_set where listname = 'order_source' and relatetable = 'ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'合同模块',1 from dual 
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '合同模块');
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'订货商城',2 from dual 
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '订货商城');
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'商城小程序',3 from dual 
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '商城小程序');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','myshopcart','我的订货','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='myshopcart' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','myshopcart','My ShopCart','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='myshopcart' and labeltype='fixedstr');
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'WorkSheet');
UPDATE ld_field SET tablename = 'ld_attachments' where tabid = @tabid AND columnname = 'filename';
delimiter;

insert into ld_tab(tabid,`name`,presence,tabsequence,isentitytype,mobilepresence,quicksubmit,againsubmit)
select -12,'Shopping',0,100,1,'mobile,weixin','yes','no' from dual 
where not exists(select 1 from ld_tab where tabid = -12);
delimiter;


insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',-12,-12,'订货商城' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tab' and tabid = -12 and relateid = -12);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',-12,-12,'Shopping' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tab' and tabid = -12 and relateid = -12);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExpressQueryComponent','快递查询组件','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExpressQueryComponent' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExpressQueryComponent','Express query component','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExpressQueryComponent' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_field set bigtype='express' where columnname = 'express_no' and bigtype = 'text' and tabid in(22,23,70);
delimiter;


set @listid = (select listid from ld_picklist_set where listname = 'express_company' and relatetable = 'ld_field');
update ld_picklist_set set picklist_allowedit='no',picklist_allowdelete='no' where listname = 'express_company' and relatetable = 'ld_field';
delete from ld_picklist_values where listid = @listid and listvalue = '丰巢快递';
update ld_picklist_values set listvalue = 'EMS' where listid = @listid and listvalue = '邮政EMS';

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'顺丰速运',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '顺丰速运');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'天天快递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '天天快递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'百世快递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '百世快递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'圆通快递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '圆通快递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'中通快递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '中通快递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'韵达快递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '韵达快递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'申通快递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '申通快递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'EMS',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = 'EMS');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'德邦',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '德邦');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'德邦快递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '德邦快递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'极兔速递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '极兔速递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'京东物流',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '京东物流');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'丹鸟',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '丹鸟');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'邮政快递包裹',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '邮政快递包裹');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'EMS包裹',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = 'EMS包裹');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'邮政标准快递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '邮政标准快递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'速必达',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '速必达');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'优速快递',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '优速快递');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'宅急送',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '宅急送');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'安得物流',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '安得物流');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'百世快运',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '百世快运');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'丰网速运',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '丰网速运');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'安能快运',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '安能快运');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'京东快运',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '京东快运');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'韵达快运',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '韵达快运');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'顺丰快运',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '顺丰快运');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'中通快运',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '中通快运');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'中通国际',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '中通国际');
delimiter;

SET @i=0;
SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname = 'express_company' AND relatetable = 'ld_field');
UPDATE ld_picklist_values SET sequence=(@i:=@i+1) WHERE listid=@listid ORDER BY getPY(listvalue),CONVERT(listvalue USING GBK);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_expressinfo` (
`express_no` varchar(255) NOT NULL COMMENT '物流单号',
`express_info` text COMMENT '物流信息',
`query_time` timestamp COMMENT "查询时间点",
PRIMARY KEY (`express_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
-- 2022-05-17

UPDATE ld_desk set fieldlabel= '已添加购物车' where labelbol = 'SUCCESSADDCART' and languagetype = 'zh';
UPDATE ld_desk set fieldlabel= 'Shopping cart added' where labelbol = 'SUCCESSADDCART' and languagetype = 'en';
delimiter;
-- 2022-05-20

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

UPDATE ld_version SET old_version='V8.4.6.3',current_version='V8.4.6.3',remark='V8.4.6.3-20220520',wx_version='V8.4.6.3';
delimiter;