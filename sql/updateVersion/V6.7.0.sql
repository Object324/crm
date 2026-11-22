DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @colName=NULL;
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
		ELSEIF columntype='decimal' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, '(',columnlen,',2)',' default 0.00');
		ELSEIF columntype='int' THEN
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default 0');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
profileid int(19),
tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter ||
CREATE  PROCEDURE `addtabintoprofile`(
tabname varchar(50),
permissions int(19)

)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;
	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
			  set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
		 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
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

set @tabid=26;
set @blockid=74;
set @tablename='ld_campaign';
set @columnname='smcreatorid';
set @fieldname='creator';
set @zh='创建人';
set @en='Creator';
set @uitype=52;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call getallprofile('Campaigns');
delimiter;
call fieldprofile('Campaigns');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDINGATTACHMENTS','添加附件','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='zh' AND Labeltype='jspop' and labelbol='ADDINGATTACHMENTS');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDINGATTACHMENTS','Brows','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='en' AND Labeltype='jspop' and labelbol='ADDINGATTACHMENTS');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTINUEADDING','继续添加','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='zh' AND Labeltype='jspop' and labelbol='CONTINUEADDING');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTINUEADDING','Brows','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='en' AND Labeltype='jspop' and labelbol='CONTINUEADDING');
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'PublicAnnouncement',0,0,'LD_publicannouncement:subject:subject:PublicAnnouncement_标题:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PublicAnnouncement' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'PublicAnnouncement',1,0,'LD_publicannouncement:startdate:startdate:PublicAnnouncement_发布日期:D' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PublicAnnouncement' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'PublicAnnouncement',1,1,'LD_publicannouncement:smownerid:assigned_user_id:PublicAnnouncement_负责人:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PublicAnnouncement' and rownumber=1 AND listnumber=1);
-- 2016-03-07

DROP TABLE IF EXISTS ld_jiuweiak_talkrecord;
delimiter;

update ld_producttoolfield set uitype = 69 where columnname = 'imagename' and input_type = 1;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ResetListWidth','重置序时簿列宽','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ResetListWidth' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ResetListWidth','Reset Column Width','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ResetListWidth' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ResetSuccess','重置成功','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ResetSuccess' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ResetSuccess','Reset Success','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ResetSuccess' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ResetFailed','重置失败','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ResetFailed' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ResetFailed','Reset Failed','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ResetFailed' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','NONEXTAPPROVER','暂无审批人，请检查审批流程步骤！','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='NONEXTAPPROVER' and Labeltype = 'fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','NONEXTAPPROVER','No approver found, please check the approval process!','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='NONEXTAPPROVER' and Labeltype = 'fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_inventoryproductrel','lastlistprice','decimal',25,NULL);
call AddColumn('ld_inventoryproductrel','lasttaxprice','decimal',25,NULL);
delimiter;

alter table ld_inventoryproductrel modify lastlistprice decimal(25,8);
alter table ld_inventoryproductrel modify lasttaxprice decimal(25,8);
delimiter;

call AddColumn('ld_producttoolfield','description','varchar',255,'');
delimiter;

drop procedure if exists add_lastlistprice_lasttaxprice;
delimiter ||
CREATE PROCEDURE add_lastlistprice_lasttaxprice()
BEGIN
	   DECLARE tid int;
	   DECLARE done int default 0;
	   DECLARE cursor_name CURSOR FOR select tabid from ld_tab where name in('Quotes','PurchaseOrder','SalesOrder','Invoice','ServiceContracts',
				'OutboundOrder','Stock','Checks','SalesBack','CashBack','PurchaseBack','PurchaseCashBack','PurchaseInvoice','WareHouseTransfer');

	   DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;

			OPEN cursor_name;

				fetch  cursor_name into tid;

				while done <> 1 do

						insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline,defaultcolumn,description)
						select (select max(producttoolfieldid)+1 from ld_producttoolfield),tid,'ld_inventoryproductrel','lastlistprice','最近价格(未税)',1,730,'N~O~25,6',@sequence,NULL,22,2,0,0,0,3,'最近价格取值受订单是否选择客户控制'
						from dual where not exists(select 1 from ld_producttoolfield where tabid = tid and columnname = 'lastlistprice' and tablename = 'ld_inventoryproductrel');

						set @producttoolfieldid=0;
						select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = tid and columnname = 'lastlistprice' and tablename = 'ld_inventoryproductrel';
						insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						select 'zh','ld_producttoolfield',tid,@producttoolfieldid,'最近价格(未税)'
						from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
						and trantable ='ld_producttoolfield' and tabid = tid and relateid=@producttoolfieldid);
						insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						select 'en','ld_producttoolfield',tid,@producttoolfieldid,'Recent price（Tax-free）'
						from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
						and trantable ='ld_producttoolfield' and tabid = tid and relateid=@producttoolfieldid);



						insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline,defaultcolumn,description)
						select (select max(producttoolfieldid)+1 from ld_producttoolfield),tid,'ld_inventoryproductrel','lasttaxprice','最近价格(含税)',1,730,'N~O~25,6',@sequence,NULL,22,2,0,0,0,3,'最近价格取值受订单是否选择客户控制'
						from dual where not exists(select 1 from ld_producttoolfield where tabid = tid and columnname = 'lasttaxprice' and tablename = 'ld_inventoryproductrel');

						set @producttoolfieldid=0;
						select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = tid and columnname = 'lasttaxprice' and tablename = 'ld_inventoryproductrel';
						insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						select 'zh','ld_producttoolfield',tid,@producttoolfieldid,'最近价格(含税)'
						from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
						and trantable ='ld_producttoolfield' and tabid = tid and relateid=@producttoolfieldid);
						insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						select 'en','ld_producttoolfield',tid,@producttoolfieldid,'Recent price（Tax-inclusive）'
						from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
						and trantable ='ld_producttoolfield' and tabid = tid and relateid=@producttoolfieldid);
				fetch  cursor_name into tid;
				end while;
			 CLOSE cursor_name;
END ||
delimiter;

CALL add_lastlistprice_lasttaxprice();
delimiter;

update ld_producttoolfield set uitype=811,description='最近价格取值不受订单是否选择供应商控制' where tabid
in(select tabid from ld_tab where name in('PurchaseOrder','PurchaseBack','PurchaseInvoice','PurchaseCashBack','Stock'))
and columnname in('lasttaxprice','lastlistprice');
-- 2017-03-14

DROP PROCEDURE IF EXISTS `update_cashbill2paymentplan_entitytype`;
delimiter ||
CREATE  PROCEDURE `update_cashbill2paymentplan_entitytype`(
)
begin

	set @cnt=0;
	select count(1) into @cnt from ld_cashbill2paymentplan where entitytypeid>0 and LENGTH(ifnull(entitytype,''))<1;
	IF @cnt>0 THEN

		update ld_cashbill2paymentplan a
		LEFT JOIN ld_crmentity b on a.entitytypeid=b.crmid
		set a.entitytype=b.setype
		where a.entitytypeid>0 and LENGTH(ifnull(a.entitytype,''))<1;

	END IF;

end ||
delimiter;

call update_cashbill2paymentplan_entitytype();
delimiter;

call addtabintoprofile('SalesGoal',1);
select tabid into @tabid from ld_tab where `name` = 'SalesGoal';
delete from ld_profile2standardpermissions where tabid = @tabid and operation in (0,1,2,11);
delimiter;

select sequence into @sequence from ld_systems_deploy where roottype = 1 and deploy_type = 93;
update ld_systems_deploy set sequence = sequence + 100 where roottype = 1 and sequence >@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',122,'设置单据分录明细中预置产品行数','',@sequence+1,1,'opetext',0,'' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 122);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',122,122,'设置单据分录明细中预置产品行数' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid =122 and relateid = 122);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',122,122,'Set the number of lines in the entry details' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid =122 and relateid = 122);
set @i=1;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype =1 order by sequence asc;
delimiter;

select sequence into @sequence from ld_systems_deploy where roottype = 1 and deploy_type = 122;
update ld_systems_deploy set sequence = sequence + 100 where roottype = 1 and sequence >@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',123,'设置产品分录中最后一行选择产品后是否自动新增一个空行','',@sequence+1,1,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 123);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',123,123,'设置产品分录中最后一行选择产品后是否自动新增一个空行' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid =123 and relateid = 123);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',123,123,'After entering for the last line , add a line automatically' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid =123 and relateid = 123);
set @i=1;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype =1 order by sequence asc;
delimiter;

call AddColumn('ld_producttoolfield','nullfield','int','2',1);
delimiter;

call AddColumn('ld_tabdetailfield','nullfield','int','2',1);
delimiter;

update ld_producttoolfield set nullfield = 0 where tabid in (select tabid from ld_tab where `name` in ('SalesOrder','ServiceContracts','Quotes','PurchaseOrder','OutboundOrder','Stock','WareHouseTransfer',
'Checks','Invoice','PurchaseInvoice','Productbom')) and columnname = 'productname';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_tabdetailfield set nullfield = 0 where tabid = @tabid and columnname in ('expenseuse','money');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_tabdetailfield set nullfield = 0 where tabid = @tabid and columnname in ('amount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
update ld_tabdetailfield set nullfield = 0,typeofdata = 'V~M~50' where tabid = @tabid and columnname = 'timetype';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRICEINFORMATION','价格信息','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'PRICEINFORMATION' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRICEINFORMATION','Price Information','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'PRICEINFORMATION' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTHISTORICALPRICE','选择历史价格，只显示最近5次不同的历史价格','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'SELECTHISTORICALPRICE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTHISTORICALPRICE','Select the historical price, showing only the last 5 different historical prices','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'SELECTHISTORICALPRICE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHOWDOCUMENTSASSOCIATEDS','仅显示该%s关联的历史单据','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'SHOWDOCUMENTSASSOCIATEDS' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHOWDOCUMENTSASSOCIATEDS','Show only the historical documents associated with the %s','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'SHOWDOCUMENTSASSOCIATEDS' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTPRICEBOOKS','选择价格表，','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'SELECTPRICEBOOKS' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTPRICEBOOKS','Select the pricebook,','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'SELECTPRICEBOOKS' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIEWPRICEBOOKS','查看价格表','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'VIEWPRICEBOOKS' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIEWPRICEBOOKS','View the pricebook','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'VIEWPRICEBOOKS' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_producttoolfield set uitype = 1,typeofdata = if(LOCATE('M',typeofdata) >0,'V~M~100','V~O~100') where input_type = 1 and defaultcolumn = 4;
delimiter;
-- 2017-03-20

update ld_inventoryproductrel set `comment`=NULL where `comment`='null';

CREATE TABLE IF NOT EXISTS `ld_attachmentsforbillsdetails` (
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `attachmentsid`     int(19),
  `filename`     varchar(255),
  `newfile_name`  varchar(255),
  `size` Varchar(100),
  `path`   text,
  `type`     Varchar(100)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_attachmentsforbills','lineitem_id','int','19',0);
call AddColumn('ld_attachmentsforbillsdetails','lineitem_id','int','19',0);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPORTDATATITLE','导出数据','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXPORTDATATITLE');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPORTDATATITLE','Export data','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXPORTDATATITLE');
delimiter;

SELECT tabid into @tabid FROM ld_tab where NAME='Attachment';
UPDATE ld_field SET tablename='ld_attachmentsforbillsdetails' WHERE columnname in('filename','size','uuid','imagefromtype') AND tabid=@tabid;
delimiter;
-- 2017-03-21

call AddColumn('ld_attachmentsforbillsdetails','imagefromtype','varchar','100',NULL);
delimiter;

update ld_tranlabel set fieldlabel='评论信息' where trantable='ld_blocks' and Relateid=38 and languagetype='zh';

select tabid into @tabid from ld_tab where `name` = 'Attachment';
SELECT MAX(sequence) INTO @sequence FROM ld_blocks WHERE tabid=@tabid;
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'ATTACHMENTS_LBL_ATTACHMENTS_INFO',@sequence+1 from dual
where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'ATTACHMENTS_LBL_ATTACHMENTS_INFO');
delimiter;

update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Attachment';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'ATTACHMENTS_LBL_ATTACHMENTS_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from dual
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_blocks' and tabid = @tabid and Relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachments Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_blocks' and tabid = @tabid and Relateid=@blockid);
delimiter;


select tabid into @tabid from ld_tab where `name` = 'Attachment';
SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid=@tabid and blocklabel='ATTACHMENTS_LBL_ATTACHMENTS_INFO';
SELECT fieldid into @fieldid FROM ld_field WHERE tabid=@tabid AND columnname='filename';
UPDATE ld_field set block=@blockid where fieldid=@fieldid;
delimiter;

SELECT tabid into @tabid FROM ld_tab WHERE `name`='Attachment';
update ld_field SET presence=0 where columnname in ('size','uuid','imagefromtype') AND tabid=@tabid;
delimiter;

UPDATE  ld_cvcolumnlist_wx SET columnname='ld_publicannouncement:subject:subject:PublicAnnouncement_标题:V'
WHERE columnname like 'ld_publicannouncement:subject:subject:%' AND modulename='PublicAnnouncement';

UPDATE  ld_cvcolumnlist_wx SET columnname='ld_publicannouncement:startdate:startdate:PublicAnnouncement_发布日期:D'
WHERE columnname like 'ld_publicannouncement:startdate:startdate:%' AND modulename='PublicAnnouncement';
UPDATE  ld_cvcolumnlist_wx SET columnname='ld_publicannouncement:smownerid:assigned_user_id:PublicAnnouncement_负责人:V'
WHERE columnname like 'ld_publicannouncement:smownerid:assigned_user_id:%' AND modulename='PublicAnnouncement';
delimiter;

call AddColumn('ld_attachments','size','varchar','100',null);
delimiter;

select tabid into @tabid from ld_tab where `name`='Documents';
update ld_quickactions set presence=1 where related_tabid in(-6,-7) AND tabid=@tabid;
update ld_field set presence=1 where columnname='filesize' AND tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'CashBill',0,0,'ld_cashbill:cashbill_no:cashbill_no:CashBill_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'CashBill' and rownumber=0 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'CashBill',0,1,'ld_cashbill:accountid:account_id:CashBill_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'CashBill' and rownumber=0 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'CashBill',1,0,'ld_cashbill:total:hdnGrandTotal:CashBill_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'CashBill' and rownumber=1 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'CashBill',1,1,'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'CashBill' and rownumber=1 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'CashBill',1,2,'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'CashBill' and rownumber=1 AND listnumber=2);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'TimeSheet',0,0,'ld_timesheet:timesheet_no:timesheet_no:TimeSheet_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'TimeSheet' and rownumber=0 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'TimeSheet',1,0,'ld_timesheet:smownerid:assigned_user_id:TimeSheet_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'TimeSheet' and rownumber=1 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'TimeSheet',1,1,'ld_timesheet:createdtime:createdtime:TimeSheet_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'TimeSheet' and rownumber=1 AND listnumber=1);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTEOFSetDiscountPercent','（说明：光标定位在折扣率中，按下Ctrl+Enter快捷键，更改当前行之后所有行的折扣率，并自动重算折扣额和价税合计）','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'NOTEOFSetDiscountPercent' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTEOFSetDiscountPercent','(Note: the cursor in the field of Discount rate(%), press Ctrl+Enter,
change all the discount rate after current line, and the field of Tax-inclusive amount and  Direct Reduction will recalculate)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'NOTEOFSetDiscountPercent' and labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_inventoryproductrel','serialnumber','VARCHAR',200,NULL);
delimiter;

drop procedure if exists add_serialnumber;
delimiter ||
CREATE PROCEDURE add_serialnumber()
BEGIN
	   DECLARE tid int;
	   DECLARE done int default 0;
	   DECLARE cursor_name CURSOR FOR select tabid from ld_tab where name in('Quotes','PurchaseOrder','SalesOrder','Invoice','ServiceContracts',
				'OutboundOrder','Stock','Checks','SalesBack','CashBack','PurchaseBack','PurchaseCashBack','PurchaseInvoice','WareHouseTransfer');

	   DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;

			OPEN cursor_name;

				fetch  cursor_name into tid;

				while done <> 1 do
						select max(sequence)+1 into @sequence from ld_producttoolfield where tabid=tid;
						insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline,defaultcolumn,description)
						select (select max(producttoolfieldid)+1 from ld_producttoolfield),tid,'ld_inventoryproductrel','serialnumber','序列号',1,2,'V~O~',@sequence,NULL,22,0,0,0,0,3,''
						from dual where not exists(select 1 from ld_producttoolfield where tabid = tid and columnname = 'serialnumber' and tablename = 'ld_inventoryproductrel');

						set @producttoolfieldid=0;
						select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = tid and columnname = 'serialnumber' and tablename = 'ld_inventoryproductrel';
						insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						select 'zh','ld_producttoolfield',tid,@producttoolfieldid,'序列号'
						from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
						and trantable ='ld_producttoolfield' and tabid = tid and relateid=@producttoolfieldid);
						insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						select 'en','ld_producttoolfield',tid,@producttoolfieldid,'serial number'
						from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
						and trantable ='ld_producttoolfield' and tabid = tid and relateid=@producttoolfieldid);


				fetch  cursor_name into tid;
				end while;
			 CLOSE cursor_name;
END ||
delimiter;

CALL add_serialnumber();
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Documents';
UPDATE ld_field set tablename='ld_attachments',columnname='name',fieldname='name' where tabid=@tabid AND columnname='filename';
UPDATE ld_field set tablename='ld_attachments',columnname='size',fieldname='size' where tabid=@tabid AND columnname='filesize';
UPDATE ld_field set tablename='ld_attachments',columnname='type',fieldname='type' where tabid=@tabid AND columnname='filetype';
delimiter;

select tabid into @tabid from ld_tab where name = 'Attachment';
INSERT INTO ld_attachmentsforbillsdetails(attachmentsid,filename,newfile_name,size,path,type,imagefromtype)
select attachmentsid,filename,newfile_name,size,path,type,imagefromtype from ld_attachmentsforbills
WHERE NOT EXISTS (SELECT 1 FROM ld_attachmentsforbillsdetails);
delimiter;

update ld_select_related_field set relatedstring='{"main":[{"table_column_value":"accountid","fieldname":"account_id"},{"table_column_value":"contactid","fieldname":"contact_id"}]}'
where module='OutboundOrder' and selectmodule='SalesOrder';
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'OutboundOrder',0,0,'ld_outboundorder:out_no:out_no:OutboundOrder_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'OutboundOrder' and rownumber=0 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'OutboundOrder',0,1,'ld_outboundorder:accountid:account_id:OutboundOrder_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'OutboundOrder' and rownumber=0 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'OutboundOrder',1,0,'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'OutboundOrder' and rownumber=1 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'OutboundOrder',1,1,'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'OutboundOrder' and rownumber=1 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'OutboundOrder',1,2,'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'OutboundOrder' and rownumber=1 AND listnumber=2);
delimiter;

DROP PROCEDURE IF EXISTS `puyoung_update_serialnumber`;
delimiter ||
CREATE PROCEDURE `puyoung_update_serialnumber`(
)
begin

	IF exists (select 1 from ld_version where trade='puyoung' and versiontype=1) THEN
		IF exists (select 1 from ld_producttoolfield where columnname='sf4' and fieldlabel='序列号' and presence=0) THEN
			update ld_inventoryproductrel a
			left join ld_inventoryproductrelscf b ON a.lineitem_id=b.lineitem_id
			set a.serialnumber=b.sf4
			where ifnull(a.serialnumber,'')='';

			update ld_producttoolfield set presence=1 where columnname='sf4' AND fieldlabel='序列号' and presence=0;
		END IF;
	END IF;

end ||
delimiter;

CALL puyoung_update_serialnumber();
delimiter;
-- 2017-03-28

update ld_desk set fieldlabel='明细' where labelbol='DETAIL' and languagetype='zh';
call AddColumn('ld_attachments','size','varchar','100',null);
call AddColumn('ld_attachmentsforbillsdetails','uuid','varchar','500',null);
delimiter;

DROP PROCEDURE IF EXISTS `set_default_columnlist_V700`;
delimiter ||
CREATE PROCEDURE `set_default_columnlist_V700`(
)
begin

	declare tmp_cvid int default 0;
	declare tmp_entitytype varchar(200);
	declare cur1 CURSOR FOR SELECT cvid,entitytype FROM ld_customview WHERE entitytype in ('Attachment','Documents') ORDER BY cvid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_cvid,tmp_entitytype;
	while(tmp_cvid is not null) DO
		IF tmp_entitytype='Attachment' THEN
			SELECT tabid into @tabid FROM ld_tab WHERE `name`='Attachment';
			DELETE FROM ld_tabwithproductview WHERE cvid=tmp_cvid;
			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:smownerid:assigned_user_id:Attachment_fieldlabel:V',0,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:reltab:reltab:Attachment_fieldlabel:V',1,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:related_to:related_to:Attachment_fieldlabel:V',2,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:createdtime:createdtime:Attachment_fieldlabel:V',3,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:description:description:Attachment_fieldlabel:V',4,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbillsdetails:filename:filename:Attachment_fieldlabel:V',5,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbillsdetails:size:size:Attachment_fieldlabel:V',6,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbillsdetails:imagefromtype:imagefromtype:Attachment_fieldlabel:V',7,tmp_cvid;
		ELSEIF tmp_entitytype='Documents' THEN
			SELECT tabid into @tabid FROM ld_tab WHERE `name`='Documents';
			DELETE FROM ld_tabwithproductview WHERE cvid=tmp_cvid;
			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:note_no:note_no:Documents_fieldlabel:V',0,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:notes_title:notes_title:Documents_fieldlabel:V',1,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:smownerid:assigned_user_id:Documents_fieldlabel:V',2,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:createdtime:createdtime:Documents_fieldlabel:DT',3,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:notecontent:notecontent:Documents_fieldlabel:V',4,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:name:name:Documents_fieldlabel:V',5,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:filelocationtype:filelocationtype:Documents_fieldlabel:V',6,tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachments:size:size:Documents_fieldlabel:I',7,tmp_cvid;
		END IF;
		Fetch cur1 into tmp_cvid,tmp_entitytype;
	end while;
	close cur1;

end ||
delimiter;

CALL set_default_columnlist_V700();
delimiter;

update ld_cvadvfilter set columnname='ld_attachmentsforbillsdetails:imagefromtype:imagefromtype:Attachment_fieldlabel:V'
where columnname like 'ld_attachmentsforbills:imagefromtype%';
-- 2017-03-29

call AddColumn('ld_cashbill2paymentplan','source_total','decimal',25,0);
delimiter;
call AddColumn('ld_cashbill2paymentplan','received_amount','decimal',25,0);
delimiter;
call AddColumn('ld_cashbill2paymentplan','entitytype_value','varchar',100,'');
delimiter;
call AddColumn('ld_cashbill2paymentplan','currency_id','int',1,'');
delimiter;
call AddColumn('ld_cashbill2paymentplan','conversion_rate','decimal',25,0);
delimiter;
call AddColumn('ld_cashbill2paymentplan','currency_symbol','varchar',30,'');
delimiter;
alter table ld_cashbill2paymentplan modify source_total decimal(25,6);
delimiter;
alter table ld_cashbill2paymentplan modify received_amount decimal(25,2);
delimiter;
alter table ld_cashbill2paymentplan modify conversion_rate decimal(25,6);
delimiter;

call AddColumn('ld_cashbill2paymentplan','cashbill2paymentplan_id','int','19','');
call altercolumnfor_primarykey('ld_cashbill2paymentplan','cashbill2paymentplan_id');
delimiter;

update ld_cashbill2paymentplan a
LEFT JOIN ld_paymentplan b ON a.entitytypeid=b.paymentplanid
SET a.source_total = b.amount,
	a.received_amount = b.actualamount,
	a.entitytype_value = b.paymentplan_no,
	a.currency_id = b.currency_id,
	a.conversion_rate = b.conversion_rate,
	a.currency_symbol = b.currency_symbol
WHERE a.entitytype='PaymentPlan';

UPDATE ld_cashbill2paymentplan a
LEFT JOIN ld_salesorder b ON a.entitytypeid = b.salesorderid
SET a.source_total = b.total,
	a.received_amount = b.received_amount,
	a.entitytype_value = b.salesorder_no,
	a.currency_id = b.currency_id,
	a.conversion_rate = b.conversion_rate,
	a.currency_symbol = b.currency_symbol
WHERE a.entitytype = 'SalesOrder';

UPDATE ld_cashbill2paymentplan a
LEFT JOIN ld_servicecontracts b ON a.entitytypeid = b.servicecontractsid
SET a.source_total = b.total,
	a.received_amount = b.received_amount,
	a.entitytype_value = b.contract_no,
	a.currency_id = b.currency_id,
	a.conversion_rate = b.conversion_rate,
	a.currency_symbol = b.currency_symbol
WHERE a.entitytype = 'ServiceContracts';


UPDATE ld_cashbill2paymentplan a
LEFT JOIN ld_outboundorder b ON a.entitytypeid = b.out_id
SET a.source_total = b.total,
	a.received_amount = b.received_amount,
	a.entitytype_value = b.out_no,
	a.currency_id = b.currency_id,
	a.conversion_rate = b.conversion_rate,
	a.currency_symbol = b.currency_symbol
WHERE a.entitytype = 'OutboundOrder';

UPDATE ld_cashbill2paymentplan a
LEFT JOIN ld_invoice b ON a.entitytypeid = b.invoiceid
SET a.source_total = b.total,
	a.received_amount = b.received_amount,
	a.entitytype_value = b.invoice_no,
	a.currency_id = b.currency_id,
	a.conversion_rate = b.conversion_rate,
	a.currency_symbol = b.currency_symbol
WHERE a.entitytype = 'Invoice';
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBill';
select count(1) into @countcv from ld_tabwithproductview where tabid = @tabid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,columnname,columnindex,cvid from ld_cvcolumnlist
where cvid in(select cvid from ld_customview where entitytype = 'CashBill') and @countcv=0;
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'entitytype','ld_cashbill2paymentplan','源单类型',2,'SourceType','V~O',0
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytype');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytype' and tablename = 'ld_cashbill2paymentplan';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'源单类型'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Source Type'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'entitytypeid','ld_cashbill2paymentplan','源单',2,'SelectSource','V~O',1
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid' and tablename = 'ld_cashbill2paymentplan';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'源单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Orignal bill'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'source_total','ld_cashbill2paymentplan','源单总额',2,'SourceAmount','V~O',1
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'source_total');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'source_total' and tablename = 'ld_cashbill2paymentplan';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'源单总额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Source Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'received_amount','ld_cashbill2paymentplan','源单已收总额',2,'SourceAmount','V~O',1
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'received_amount');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'received_amount' and tablename = 'ld_cashbill2paymentplan';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'源单已收总额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Source Received Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'amount','ld_cashbill2paymentplan','本次收款金额',2,'Amount','V~O',1
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'amount');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'amount' and tablename = 'ld_cashbill2paymentplan';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'本次收款金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'The amount collected'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
delimiter;

call AddColumn('ld_sendcashbill2payment','source_total','decimal',25,0);
delimiter;
call AddColumn('ld_sendcashbill2payment','pay_amount','decimal',25,0);
delimiter;
call AddColumn('ld_sendcashbill2payment','entitytype_value','varchar',100,NULL);
delimiter;
call AddColumn('ld_sendcashbill2payment','currency_id','int',1,'');
delimiter;
call AddColumn('ld_sendcashbill2payment','conversion_rate','decimal',25,0);
delimiter;
call AddColumn('ld_sendcashbill2payment','currency_symbol','varchar',30,NULL);
delimiter;

alter table ld_sendcashbill2payment modify source_total decimal(25,6);
alter table ld_sendcashbill2payment modify pay_amount decimal(25,2);
alter table ld_sendcashbill2payment modify conversion_rate decimal(25,6);

call AddColumn('ld_sendcashbill2payment','sendcashbill2payment_id','int','19','');
call altercolumnfor_primarykey('ld_sendcashbill2payment','sendcashbill2payment_id');
delimiter;

UPDATE ld_sendcashbill2payment a
LEFT JOIN ld_sendpayment b ON a.entitytypeid = b.sendpaymentid
SET a.source_total = b.amount,
	a.pay_amount = b.actualamount,
	a.entitytype_value = b.Sendpayment_no,
	a.currency_id = b.currency_id,
	a.conversion_rate = b.conversion_rate,
	a.currency_symbol = b.currency_symbol
WHERE a.entitytype = 'SendPayment';


UPDATE ld_sendcashbill2payment a
LEFT JOIN ld_stock b ON a.entitytypeid = b.stock_id
SET a.source_total = b.total,
	a.pay_amount = b.pay_amount,
	a.entitytype_value = b.ware_stock_no,
	a.currency_id = b.currency_id,
	a.conversion_rate = b.conversion_rate,
	a.currency_symbol = b.currency_symbol
WHERE a.entitytype = 'Stock';

UPDATE ld_sendcashbill2payment a
LEFT JOIN ld_purchaseinvoice b ON a.entitytypeid = b.purchaseinvoiceid
SET a.source_total = b.total,
	a.pay_amount = b.pay_amount,
	a.entitytype_value = b.purchaseinvoice_no,
	a.currency_id = b.currency_id,
	a.conversion_rate = b.conversion_rate,
	a.currency_symbol = b.currency_symbol
WHERE a.entitytype = 'PurchaseInvoice';

UPDATE ld_sendcashbill2payment a
LEFT JOIN ld_purchaseorder b ON a.entitytypeid = b.purchaseorderid
SET a.source_total = b.total,
	a.pay_amount = b.pay_amount,
	a.entitytype_value = b.purchaseorder_no,
	a.currency_id = b.currency_id,
	a.conversion_rate = b.conversion_rate,
	a.currency_symbol = b.currency_symbol
WHERE a.entitytype = 'PurchaseOrder';
delimiter;


select tabid into @tabid from ld_tab where name = 'SendCashBill';
select count(1) into @countcv from ld_tabwithproductview where tabid = @tabid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,columnname,columnindex,cvid from ld_cvcolumnlist
where cvid in(select cvid from ld_customview where entitytype = 'SendCashBill') and @countcv=0;
delimiter;

select tabid into @tabid from ld_tab where name = 'SendCashBill';
insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'entitytype','ld_sendcashbill2payment','源单类型',2,'SourceType','V~O',0
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytype');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytype' and tablename = 'ld_sendcashbill2payment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'源单类型'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Source Type'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'entitytypeid','ld_sendcashbill2payment','源单',2,'SelectSource','V~O',1
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid' and tablename = 'ld_sendcashbill2payment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'源单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Orignal bill'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'source_total','ld_sendcashbill2payment','源单总额',2,'SourceAmount','V~O',1
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'source_total');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'source_total' and tablename = 'ld_sendcashbill2payment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'源单总额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Source Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'pay_amount','ld_sendcashbill2payment','源单已付总额',2,'SourceAmount','V~O',1
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'pay_amount');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'pay_amount' and tablename = 'ld_sendcashbill2payment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'源单已付总额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Source Pay Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence)
select @tabid,'amount','ld_sendcashbill2payment','本次付款金额',2,'Amount','V~O',1
from dual where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'amount');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'amount' and tablename = 'ld_sendcashbill2payment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'本次付款金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'The amount pay'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tabdetailfield' and tabid = @tabid and relateid=@tabdetailfieldid);

select sequence into @sequence from ld_systems_deploy where roottype = 4 and deploy_type = 79;
update ld_systems_deploy set sequence = sequence + 100 where roottype = 4 and sequence >@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 'taxprice',124,'单据分录中产品明细计算公式基准字段','',@sequence+1,4,'select',0,'[{"value":"taxprice","text":"PRODUCTLIST_TAXPRICE"},{"value":"listprice","text":"PRODUCTLIST_LISTPRICE"},{"sql":""}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 124);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',124,124,'单据分录中产品明细计算公式基准字段' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid =124 and relateid = 124);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',124,124,'Reference field for product detail calculation formula in document entry' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid =124 and relateid = 124);
set @i=1;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype =4 order by sequence asc;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_producttoolfield_formula_base` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `base_column` varchar(255) DEFAULT NULL,
  `formulastring` text,
  `columnstring` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

TRUNCATE ld_producttoolfield_formula_base;
insert into ld_producttoolfield_formula_base(base_column,formulastring,columnstring)
select 'base_list_amount_taxprice',ld_producttoolfield_formula.formulastring,
 SUBSTRING(substring(ld_producttoolfield_formula.columnstring,14),1,CHARACTER_LENGTH(substring(ld_producttoolfield_formula.columnstring,14))-2) from ld_producttoolfield INNER JOIN ld_producttoolfield_formula on ld_producttoolfield.producttoolfieldid = ld_producttoolfield_formula.producttoolfieldid
where ld_producttoolfield_formula.columnstring LIKE '%taxprice%' and columnname = 'listprice' limit 1;
delimiter;

insert into ld_producttoolfield_formula_base(base_column,formulastring,columnstring)
select 'base_list_amount_listprice','a',"{'lettervar':'a','column':'listprice'}" from DUAL
where not exists(select 1 from ld_producttoolfield_formula_base where base_column = 'base_list_amount_listprice');
delimiter;

insert into ld_producttoolfield_formula_base(base_column,formulastring,columnstring)
select 'base_tax_amount_taxprice','b',"{'lettervar':'b','column':'taxprice'}" from DUAL
where not exists(select 1 from ld_producttoolfield_formula_base where base_column = 'base_tax_amount_taxprice');
delimiter;

insert into ld_producttoolfield_formula_base(base_column,formulastring,columnstring)
select 'base_tax_amount_listprice',ld_producttoolfield_formula.formulastring,
 SUBSTRING(substring(ld_producttoolfield_formula.columnstring,14),1,CHARACTER_LENGTH(substring(ld_producttoolfield_formula.columnstring,14))-2) from ld_producttoolfield INNER JOIN ld_producttoolfield_formula on ld_producttoolfield.producttoolfieldid = ld_producttoolfield_formula.producttoolfieldid
where ld_producttoolfield_formula.columnstring like '%listprice%' and columnname = 'taxprice' limit 1;
delimiter;

update ld_producttoolfield_formula
INNER JOIN ld_producttoolfield on ld_producttoolfield.producttoolfieldid = ld_producttoolfield_formula.producttoolfieldid
set formulastring = "base_list_amount*b*(1-c/100)",columnstring = "{formulavar:[base_list_amount,{'lettervar':'c','column':'quantity'},{'lettervar':'d','column':'discount_percent'}]}"
where ld_producttoolfield.columnname = 'list_amount' and formulastring = '(a)*b*(1-c/100)';
delimiter;

update ld_producttoolfield_formula
INNER JOIN ld_producttoolfield on ld_producttoolfield.producttoolfieldid = ld_producttoolfield_formula.producttoolfieldid
set formulastring = "base_list_amount*c*(1-d/100)",columnstring = "{formulavar:[base_list_amount,{'lettervar':'c','column':'quantity'},{'lettervar':'d','column':'discount_percent'}]}"
where ld_producttoolfield.columnname = 'list_amount' and formulastring = '(a/(1+(b)/100))*c*(1-d/100)';
delimiter;

update ld_producttoolfield_formula
INNER JOIN ld_producttoolfield on ld_producttoolfield.producttoolfieldid = ld_producttoolfield_formula.producttoolfieldid
set formulastring = "base_list_amount*d*(1-e/100)",columnstring = "{formulavar:[base_list_amount,{'lettervar':'c','column':'quantity'},{'lettervar':'d','column':'discount_percent'}]}"
where ld_producttoolfield.columnname = 'list_amount' and formulastring = '(a/(1+(b+c)/100))*d*(1-e/100)';
delimiter;

update ld_producttoolfield_formula
INNER JOIN ld_producttoolfield on ld_producttoolfield.producttoolfieldid = ld_producttoolfield_formula.producttoolfieldid
set formulastring = "base_list_amount*e*(1-f/100)",columnstring = "{formulavar:[base_list_amount,{'lettervar':'c','column':'quantity'},{'lettervar':'d','column':'discount_percent'}]}"
where ld_producttoolfield.columnname = 'list_amount' and formulastring = '(a/(1+(b+c+d)/100))*e*(1-f/100)';
delimiter;

update ld_producttoolfield_formula
INNER JOIN ld_producttoolfield on ld_producttoolfield.producttoolfieldid = ld_producttoolfield_formula.producttoolfieldid
set formulastring = "a*base_tax_amount*(1-c/100)",columnstring = "{formulavar:[{'lettervar':'a','column':'quantity'},base_tax_amount,{'lettervar':'c','column':'discount_percent'}]}"
where ld_producttoolfield.columnname = 'tax_amount' and formulastring = 'a*b*(1-c/100)';
delimiter;

update ld_attachmentsforbillsdetails INNER JOIN
ld_attachmentsforbills on ld_attachmentsforbills.attachmentsid =ld_attachmentsforbillsdetails.attachmentsid
set ld_attachmentsforbillsdetails.uuid=ld_attachmentsforbills.uuid;

update ld_tabwithproductview set COLUMNS='ld_attachments:name:name:Documents_fieldlabel:V'
where COLUMNS like '%ld_notes:name:name:Documents%' and tabid=8;

update ld_salesorder INNER JOIN(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) AS invoicetotal
FROM
	(
		SELECT
			b.invoice_num,
			a.invoicedate,
			a.currency_id,
			c.entitytypeid,
			round(
				c.tax_amount / ifnull(a.conversion_rate, 1),
				2
			) tax_amount
		FROM
			ld_invoice a
		LEFT JOIN ld_invoicecf b ON a.invoiceid = b.invoiceid
		LEFT JOIN (
			SELECT
				ld_inventoryproductrel.id,
				ld_inventoryproductrel.entitytypeid,
				sum(
					ifnull(
						tmp_adjustment.adjustment,
						0
					)
				) AS tax_amount
			FROM
				(
					SELECT DISTINCT
						b.id,
						b.entitytypeid,
						a.adjustment,
						min(lineitem_id) AS minlineitem_id
					FROM
						ld_invoice a
					LEFT JOIN ld_inventoryproductrel b ON a.invoiceid = b.id
					GROUP BY
						a.invoiceid
				) AS tmp_adjustment
			INNER JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = tmp_adjustment.id
			AND minlineitem_id = lineitem_id
			WHERE
				ifnull(adjustment, 0) <> 0
			GROUP BY
				entitytypeid
			UNION ALL
				SELECT
					id,
					entitytypeid,
					tax_amount
				FROM
					ld_inventoryproductrel
		) c ON a.invoiceid = c.id
		WHERE
			a.deleted = 0
		AND ifnull(a.invoicestatus, '') != '已作废'

		ORDER BY
			a.invoicedate DESC,
			createdtime DESC
	) c GROUP BY c.entitytypeid ) as sales_entity on sales_entity.entitytypeid=ld_salesorder.salesorderid
set have_invoicetotal=if(ld_salesorder.currency_id=1,invoicetotal,invoicetotal*ifNULL(ld_salesorder.conversion_rate,1));
delimiter;


update ld_servicecontracts INNER JOIN(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) AS invoicetotal
FROM
	(
		SELECT
			b.invoice_num,
			a.invoicedate,
			a.currency_id,
			c.entitytypeid,
			round(
				c.tax_amount / ifnull(a.conversion_rate, 1),
				2
			) tax_amount
		FROM
			ld_invoice a
		LEFT JOIN ld_invoicecf b ON a.invoiceid = b.invoiceid
		LEFT JOIN (
			SELECT
				ld_inventoryproductrel.id,
				ld_inventoryproductrel.entitytypeid,
				sum(
					ifnull(
						tmp_adjustment.adjustment,
						0
					)
				) AS tax_amount
			FROM
				(
					SELECT DISTINCT
						b.id,
						b.entitytypeid,
						a.adjustment,
						min(lineitem_id) AS minlineitem_id
					FROM
						ld_invoice a
					LEFT JOIN ld_inventoryproductrel b ON a.invoiceid = b.id
					GROUP BY
						a.invoiceid
				) AS tmp_adjustment
			INNER JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = tmp_adjustment.id
			AND minlineitem_id = lineitem_id
			WHERE
				ifnull(adjustment, 0) <> 0
			GROUP BY
				entitytypeid
			UNION ALL
				SELECT
					id,
					entitytypeid,
					tax_amount
				FROM
					ld_inventoryproductrel
		) c ON a.invoiceid = c.id
		WHERE
			a.deleted = 0
		AND ifnull(a.invoicestatus, '') != '已作废'

		ORDER BY
			a.invoicedate DESC,
			createdtime DESC
	) c GROUP BY c.entitytypeid ) as sales_entity on sales_entity.entitytypeid=ld_servicecontracts.servicecontractsid
set have_invoicetotal=if(ld_servicecontracts.currency_id=1,invoicetotal,invoicetotal*ifNULL(ld_servicecontracts.conversion_rate,1));
delimiter;


update ld_outboundorder INNER JOIN(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) AS invoicetotal
FROM
	(
		SELECT
			b.invoice_num,
			a.invoicedate,
			a.currency_id,
			c.entitytypeid,
			round(
				c.tax_amount / ifnull(a.conversion_rate, 1),
				2
			) tax_amount
		FROM
			ld_invoice a
		LEFT JOIN ld_invoicecf b ON a.invoiceid = b.invoiceid
		LEFT JOIN (
			SELECT
				ld_inventoryproductrel.id,
				ld_inventoryproductrel.entitytypeid,
				sum(
					ifnull(
						tmp_adjustment.adjustment,
						0
					)
				) AS tax_amount
			FROM
				(
					SELECT DISTINCT
						b.id,
						b.entitytypeid,
						a.adjustment,
						min(lineitem_id) AS minlineitem_id
					FROM
						ld_invoice a
					LEFT JOIN ld_inventoryproductrel b ON a.invoiceid = b.id
					GROUP BY
						a.invoiceid
				) AS tmp_adjustment
			INNER JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = tmp_adjustment.id
			AND minlineitem_id = lineitem_id
			WHERE
				ifnull(adjustment, 0) <> 0
			GROUP BY
				entitytypeid
			UNION ALL
				SELECT
					id,
					entitytypeid,
					tax_amount
				FROM
					ld_inventoryproductrel
		) c ON a.invoiceid = c.id
		WHERE
			a.deleted = 0
		AND ifnull(a.invoicestatus, '') != '已作废'

		ORDER BY
			a.invoicedate DESC,
			createdtime DESC
	) c GROUP BY c.entitytypeid ) as sales_entity on sales_entity.entitytypeid=ld_outboundorder.out_id
set have_invoicetotal=if(ld_outboundorder.currency_id=1,invoicetotal,invoicetotal*ifNULL(ld_outboundorder.conversion_rate,1));
delimiter;

update ld_servicecontracts set nothave_invoicetotal=total-have_invoicetotal where nothave_invoicetotal<>total-have_invoicetotal;
update ld_salesorder set nothave_invoicetotal=total-have_invoicetotal where nothave_invoicetotal<>total-have_invoicetotal;
update ld_outboundorder set nothave_invoicetotal=total-have_invoicetotal where nothave_invoicetotal<>total-have_invoicetotal;
delimiter;

update ld_field set columnname='',fieldname='',tablename=''
where uitype=202 and  tabid=(select tabid from ld_tab where name='cashbill');
delimiter;
-- 2017-03-30

drop procedure if exists update_attachment_name;  
delimiter ||
CREATE PROCEDURE update_attachment_name()
BEGIN  
	   DECLARE tid int;
	   DECLARE done int default 0;  
	   DECLARE cur_name CURSOR FOR SELECT ld_attachments.attachmentsid FROM ld_notes
				LEFT JOIN ld_seattachmentsrel on ld_seattachmentsrel.crmid=ld_notes.notesid
				LEFT JOIN ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid WHERE ld_attachments.attachmentsid>0;
	   DECLARE CONTINUE HANDLER  for not found  SET done=1;  

			OPEN cur_name;  	  
				fetch  cur_name into tid;  
				
				while done <> 1 do
						SELECT crmid INTO @crmid FROM ld_seattachmentsrel WHERE attachmentsid=tid;
						UPDATE ld_attachments set `name`=replace(name, name, concat(@crmid,'_',name)) WHERE attachmentsid=tid;
				fetch cur_name into tid;   
				end while;
			 CLOSE cur_name;
END ||
delimiter;
CALL update_attachment_name();
delimiter;

call AddColumn('ld_producttoolfield_formula_base','tabid','int','11','');
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,CONCAT(@tabname,'全景报表'),'template','default_account_panorama.mrt',@sequence+1,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_panorama.mrt' and systemdefault=1);
delimiter;
-- 2017-04-05

update ld_systems_deploy set deploy_value=0,presence=1 where  deploy_type=103;
delimiter;

update ld_desk set fieldlabel='最大限制：' where labelbol='MAXUPLOADSIZE' and languagetype='zh';
update ld_desk set fieldlabel='Maximum limit ' where labelbol='MAXUPLOADSIZE' and languagetype='en';
update ld_desk set fieldlabel='，允许上传的文件格式：' where labelbol='supportformat' and languagetype='zh';
update ld_desk set fieldlabel=', you can upload ' where labelbol='supportformat' and languagetype='en';

update ld_desk set fieldlabel='（温馨提示：光标定位在折扣率中按下Ctrl+Enter键可以更改当前行及之后所有行的折扣率）' 
where labelbol='NOTEOFSetDiscountPercent' and languagetype='zh';

update ld_desk set fieldlabel = '字，签名包含' where labelbol = 'Word' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = ' Word，Signature contains ' where labelbol = 'Word' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

update ld_desk set fieldlabel = '，短信内容总共' where labelbol = 'Totalcontentofthemessage' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = '，Total content of the message ' where labelbol = 'Totalcontentofthemessage' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

update ld_desk set fieldlabel='正在导出数据请不要关闭或刷新浏览器' where labelbol='EXPORTINGDATA' and languagetype='zh' AND Labeltype='fixedstr';
update ld_desk set fieldlabel='Exporting data please do not refresh or close the browser' where labelbol='EXPORTINGDATA' and languagetype='en' AND  Labeltype='fixedstr';
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
SELECT actionid into @actionid FROM ld_actionmapping where actionname='Import';
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid and operation=@actionid);
delimiter;

select tabid into @tabid from ld_tab where name='SendCashBill';
SELECT actionid into @actionid FROM ld_actionmapping where actionname='Import';
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid and operation=@actionid);
delimiter;

update ld_producttoolfield set edit_permission = 0 where columnname = 'tax_amount' and uitype=28; 
delimiter; 
update ld_producttoolfield set presence=1 where columnname in ('discount_amount','adjustment') and tablename<>'ld_inventoryproductrel' and (select count(1) from ld_crmentity)<=2; 
update ld_producttoolfield set edit_permission = 1 where columnname = 'total' and newline = 1 and defaultcolumn = 2; 
delimiter;
-- 2017-04-10

update ld_tranlabel set fieldlabel='税(销售)' where fieldlabel='销售' and trantable='ld_producttoolfield' and languagetype='zh'
	and Relateid in (select producttoolfieldid from ld_producttoolfield where columnname='tax2');
update ld_tranlabel set fieldlabel='Tax(Sales)' where fieldlabel='Potentials' and trantable='ld_producttoolfield' and languagetype='en'
	and Relateid in (select producttoolfieldid from ld_producttoolfield where columnname='tax2');
    
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHOOSEENTITYTYPE','源单类型','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHOOSEENTITYTYPE');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHOOSEENTITYTYPE','Entity Type','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHOOSEENTITYTYPE');
delimiter;
-- 2017-04-11

set @i=0;
UPDATE ld_systems_deploy set sequence=0 WHERE  roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=73 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=74 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=108 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=109 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=116 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=117 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=118 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=119 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=54 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=12 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=1 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=58 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=59 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=57 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=37 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=38 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=56 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=63 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=15 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=20 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=48 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=10 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=33 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=13 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=67 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=14 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=66 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=78 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=72 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=69 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=49 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=93 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=122 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=123 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=77 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=80 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=81 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=90 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=114 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=25 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=32 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=65 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=68 AND roottype=1;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=89 AND roottype=1;
delimiter;

set @i=0;
UPDATE ld_systems_deploy set sequence=0 WHERE  roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=28 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=17 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=120 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=70 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=71 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=11 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=16 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=94 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=27 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=29 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=5 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=3 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=47 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=6 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=100 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=22 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=23 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=98 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=99 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=4 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=50 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=9 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=36 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=30 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=31 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=112 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=113 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=8 AND roottype=2;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=96 AND roottype=2;
delimiter;

set @i=0;
UPDATE ld_systems_deploy set sequence=0 WHERE  roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=51 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=18 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=24 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=53 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=40 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=41 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=7 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=62 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=21 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=95 AND roottype=3;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=115 AND roottype=3;
delimiter;

set @i=0;
UPDATE ld_systems_deploy set sequence=0 WHERE  roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=61 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=26 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=110 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=85 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=124 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=79 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=82 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=83 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=84 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=92 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=105 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=106 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=86 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=111 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=102 AND roottype=4;
UPDATE ld_systems_deploy set sequence=(@i:=@i+1) WHERE deploy_type=103 AND roottype=4;
delimiter;
-- 2017-04-11

DROP PROCEDURE IF EXISTS `puyoung_update_serialnumber`;
delimiter ||
CREATE PROCEDURE `puyoung_update_serialnumber`(
)
BEGIN

	DECLARE tmp_tabid INT;
	DECLARE tmp_seq INT;

	DECLARE cur1 CURSOR FOR SELECT tabid,sequence FROM ld_producttoolfield WHERE columnname='sf4' and tabid>0 AND presence=0 ORDER BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;
	
	IF EXISTS (SELECT 1 FROM ld_version WHERE trade='puyoung')  THEN
		IF EXISTS (SELECT 1 FROM ld_producttoolfield WHERE columnname='sf4' AND fieldlabel='序列号' AND presence=0) THEN
				OPEN cur1;
				Fetch cur1 into tmp_tabid,tmp_seq;
				WHILE(tmp_tabid is not null) DO
					UPDATE ld_producttoolfield SET presence=0,sequence=tmp_seq WHERE tabid=tmp_tabid and columnname='serialnumber';
					Fetch cur1 into tmp_tabid,tmp_seq;
				END WHILE;
				CLOSE cur1;

				UPDATE ld_inventoryproductrel a
				LEFT JOIN ld_inventoryproductrelscf b ON a.lineitem_id=b.lineitem_id
				SET a.serialnumber=b.sf4
				WHERE IFNULL(a.serialnumber,'')='';
			
				UPDATE ld_producttoolfield SET presence=1 WHERE columnname='sf4';
		END IF;
	END IF;

end ||
delimiter;

CALL puyoung_update_serialnumber();
delimiter;

update ld_producttoolfield set presence=1 where tabid=37 and columnname='serialnumber';
call AddColumn('ld_relatedlists','type','varchar',255,'');
delimiter;

call AddColumn('ld_relatedlists','related_coltable','varchar',255,'');
delimiter;

update ld_tabdetailfield set fieldtype='RMB_Amount' where columnname='rmb_total' and tablename='ld_expensedetailscf';

update ld_relatedlists 
INNER JOIN ld_tab on ld_tab.tabid=ld_relatedlists.related_tabid
set type='datacategory_sql';

update ld_relatedlists set type='CallButler_Info' where name='get_CallButler';
delimiter;

update ld_relatedlists set type='seproductsrel_datacategory_sql' where name='get_products' and tabid=6;
update ld_relatedlists set type='senotesrel_datacategory_sql' where name='get_attachments' ;
update ld_relatedlists set type='campaignaccountrel_datacategory_sql' where name='get_campaigns'  and tabid=6;
update ld_relatedlists set type='servicecontacts_datacategory_sql' where name='get_ServiceContracts'  and tabid=6;
update ld_relatedlists set related_coltable='contactdetails.accountid' where tabid=6 and name='get_contacts';
update ld_relatedlists set related_coltable='potential.accountid' where tabid=6 and name='get_opportunities';
update ld_relatedlists set related_coltable='quotes.accountid' where tabid=6 and name='get_quotes';
update ld_relatedlists set related_coltable='salesorder.accountid' where tabid=6 and name='get_salesorder';
update ld_relatedlists set related_coltable='invoice.accountid' where tabid=6 and name='get_invoices';
update ld_relatedlists set related_coltable='senotesrel.crmid' where  name='get_attachments';
update ld_relatedlists set related_coltable='troubletickets.accountid' where  name='get_tickets'  and tabid=6;
update ld_relatedlists set related_coltable='seproductsrel.crmid' where  name='get_products'  and tabid=6;
update ld_relatedlists set related_coltable='campaignaccountrel.accountid' where  name='get_campaigns'  and tabid=6;
update ld_relatedlists set related_coltable='servicecontracts.accountid' where  name='get_ServiceContracts'  and tabid=6;
update ld_relatedlists set related_coltable='contactrecords.accountid' where  name='get_contactrecords'  and tabid=6;
update ld_relatedlists set related_coltable='paymentplan.accountid' where  name='get_paymentplan'  and tabid=6;
update ld_relatedlists set related_coltable='cashbill.accountid' where  name='get_cashbill'  and tabid=6;
update ld_relatedlists set related_coltable='expense.accountid' where  name='get_expense'  and tabid=6;
update ld_relatedlists set related_coltable='attachmentsforbills.related_to' where  name='get_attachment';
update ld_relatedlists set related_coltable='outboundorder.accountid' where  name='get_attachment' and tabid=6;
update ld_relatedlists set related_coltable='salesback.accountid' where  name='get_salesback' and tabid=6;
update ld_relatedlists set related_coltable='cashback.accountid' where  name='get_cashback' and tabid=6;
update ld_relatedlists set related_coltable='commission.accountid' where  name='get_commission' and tabid=6;
update ld_relatedlists set related_coltable='activity.accountid' where  name='get_schedule' and tabid=6;
update ld_relatedlists set related_coltable='project.accountid' where  name='get_project' and tabid=6;
update ld_relatedlists set related_coltable='dividendorder.accountid' where  name='get_dividendorder' and tabid=6;
update ld_relatedlists set related_coltable='servicereturn.accountid' where  name='get_servicereturn' and tabid=6;
update ld_relatedlists set related_coltable='reminds.related_to' where  name='get_reminds' ;
delimiter;

update ld_relatedlists set related_coltable='potential.contactid' where tabid=4 and name='get_opportunities';
update ld_relatedlists set related_coltable='troubletickets.contactid' where tabid=4 and name='get_tickets';
update ld_relatedlists set related_coltable='quotes.contactid' where tabid=4 and name='get_quotes';
update ld_relatedlists set related_coltable='salesorder.contactid' where tabid=4 and name='get_salesorder';
update ld_relatedlists set related_coltable='contactdetails.contactid'  , type='seproductsrel_datacategory_sql' where tabid=4 and name='get_products';
update ld_relatedlists set related_coltable='campaigncontrel.contactid'  , type='campaigncontrel_datacategory_sql' where tabid=4 and name='get_campaigns';
update ld_relatedlists set related_coltable='servicecontracts.contactid'  where tabid=4 and name='get_ServiceContracts';
update ld_relatedlists set related_coltable='contactrecords.contactid'  where tabid=4 and name='get_contactrecords';
update ld_relatedlists set related_coltable='activity.contactid'  where tabid=4 and name='get_schedule';
update ld_relatedlists set related_coltable='project.contactid'  where tabid=4 and name='get_project';
update ld_relatedlists set related_coltable='contpotentialrel.potentialid' ,type='contpotentialrel_datacategory_sql' where tabid=2 and name='get_contacts';
update ld_relatedlists set related_coltable='seproductsrel.crmid' ,type='seproductsrel_datacategory_sql' where tabid=2 and name='get_products';
update ld_relatedlists set related_coltable='quotes.contactid'  where tabid=2 and name='get_Quotes';
update ld_relatedlists set related_coltable='salesorder.contactid'  where tabid=2 and name='get_salesorder';
update ld_relatedlists set related_coltable='contactrecords.contactid'  where tabid=2 and name='get_contactrecords';
update ld_relatedlists set related_coltable='servicecontracts.contactid'  where tabid=2 and name='get_servicecontracts';
update ld_relatedlists set related_coltable='expense.contactid'  where tabid=2 and name='get_expense';
update ld_relatedlists set related_coltable='activity.contactid'  where tabid=2 and name='get_schedule';
update ld_relatedlists set related_coltable='project.contactid'  where tabid=2 and name='get_project';
update ld_relatedlists set related_coltable='account.accountid',type='accountpotentialrel_datacategory_sql'  where tabid=2 and name='get_accounts';
delimiter;

select tabid into @tabid from ld_tab where name='salesorder';
update ld_relatedlists set related_coltable='tmp_related_cashbill.entitytypeid',type='cashbillsourcebill_datacategory_sql'  where tabid=@tabid and name='get_cashbill';
update ld_relatedlists set related_coltable='inventoryproductrel.entitytypeid'  where tabid=@tabid and name='get_invoices';
update ld_relatedlists set related_coltable='inventoryproductrel.entitytypeid'  where tabid=@tabid and name='get_outorder';
update ld_relatedlists set related_coltable='inventoryproductrel.entitytypeid'  where tabid=@tabid and name='get_purchaseorder';
update ld_relatedlists set related_coltable='salesback.salesorderid'  where tabid=@tabid and name='get_salesback';
update ld_relatedlists set related_coltable='cashback.salesorderid'  where tabid=@tabid and name='get_cashback';
update ld_relatedlists set related_coltable='servicecontracts.salesorderid'  where tabid=@tabid and name='get_servicecontracts';
update ld_relatedlists set related_coltable='troubletickets.salesorderid'  where tabid=@tabid and name='get_tickets';
update ld_relatedlists set related_coltable='contactrecords.salesorderid'  where tabid=@tabid and name='get_contactrecords';
update ld_relatedlists set related_coltable='project.salesorderid'  where tabid=@tabid and name='get_project';
update ld_relatedlists set related_coltable='paymentplan.entitytypeid'  where tabid=@tabid and name='get_paymentplan';
update ld_relatedlists set related_coltable='salesorder.parentid'  where tabid=@tabid and name='get_salesorder';
update ld_relatedlists set related_coltable='commission2payment.entitytypeid'  where tabid=@tabid and name='get_commission';
update ld_relatedlists set related_coltable='expensedetail.entitytypeid'  where tabid=@tabid and name='get_expense';
delimiter;

select tabid into @tabid from ld_tab where name='servicecontracts';
update ld_relatedlists set related_coltable='troubletickets.servicecontractsid' where tabid=@tabid and name='get_helpdesk';
update ld_relatedlists set related_coltable='tmp_related_cashbill.entitytypeid',type='cashbillsourcebill_datacategory_sql'  where tabid=@tabid and name='get_cashbill';
update ld_relatedlists set related_coltable='inventoryproductrel.entitytypeid'  where tabid=@tabid and name='get_invoice';
update ld_relatedlists set related_coltable='commission2payment.entitytypeid'  where tabid=@tabid and name='get_commission';
update ld_relatedlists set related_coltable='expensedetail.entitytypeid'  where tabid=@tabid and name='get_expense';
update ld_relatedlists set related_coltable='paymentplan.entitytypeid'  where tabid=@tabid and name='get_paymentplan';
delimiter;

select tabid into @tabid from ld_tab where name='products';
update ld_relatedlists set related_coltable='troubletickets.product_id' where tabid=@tabid and name='get_tickets';
update ld_relatedlists set related_coltable='inventoryproductrel.productid' where tabid=@tabid and name='get_quotes';
update ld_relatedlists set related_coltable='inventoryproductrel.productid' where tabid=@tabid and name='get_purchase_orders';
update ld_relatedlists set related_coltable='inventoryproductrel.productid' where tabid=@tabid and name='get_salesorder';
update ld_relatedlists set related_coltable='inventoryproductrel.productid' where tabid=@tabid and name='get_invoices';
update ld_relatedlists set related_coltable='inventoryproductrel.productid' where tabid=@tabid and name='get_ServiceContracts';
update ld_relatedlists set related_coltable='inventoryproductrel.productid' where tabid=@tabid and name='get_productbom';
update ld_relatedlists set related_coltable='fund_net.product_id' where tabid=@tabid and name='get_fundnet';
update ld_relatedlists set related_coltable='pricebookproductrel.product_id'  ,type='pricebookproductrel_datacategory_sql' where tabid=@tabid and name='get_product_pricebooks';
update ld_relatedlists set related_coltable='products.productid' ,type='seproductsrel_datacategory_sql' where tabid=@tabid and name='get_accounts';
update ld_relatedlists set related_coltable='products.productid' ,type='seproductsrel_datacategory_sql' where tabid=@tabid and name='get_contacts';
update ld_relatedlists set related_coltable='products.productid' ,type='seproductsrel_datacategory_sql' where tabid=@tabid and name='get_opportunities';
delimiter;

select tabid into @tabid from ld_tab where name='helpdesk';
update ld_relatedlists set related_coltable='contactrecords.troubleticketid' where tabid=@tabid and name='get_contactRecords';
update ld_relatedlists set related_coltable='servicereturn.productid' where tabid=@tabid and name='get_servicereturn';
update ld_relatedlists set related_coltable='troubletickets.ticketid' ,type='faqhelpdesk_datacategory_sql' where tabid=@tabid and name='get_commonproblem';
delimiter;

select tabid into @tabid from ld_tab where name='quotes';
update ld_relatedlists set related_coltable='salesorder.quoteid' where tabid=@tabid and name='get_salesorder';
delimiter;

select tabid into @tabid from ld_tab where name='salesback';
update ld_relatedlists set related_coltable='cashback.salesbackid' where tabid=@tabid and name='get_cashback';
delimiter;

select tabid into @tabid from ld_tab where name='servicecharge';
update ld_relatedlists set type='seproductsrel_datacategory_sql' where name='get_products' and tabid=@tabid;
update ld_relatedlists set type='campaignaccountrel_datacategory_sql' where name='get_campaigns'  and tabid=@tabid;
update ld_relatedlists set type='servicecontacts_datacategory_sql' where name='get_ServiceContracts'  and tabid=@tabid;
update ld_relatedlists set related_coltable='contactdetails.accountid' where tabid=@tabid and name='get_contacts';
update ld_relatedlists set related_coltable='potentials.accountid' where tabid=@tabid and name='get_opportunities';
update ld_relatedlists set related_coltable='quotes.accountid' where tabid=@tabid and name='get_quotes';
update ld_relatedlists set related_coltable='salesorder.accountid' where tabid=@tabid and name='get_salesorder';
update ld_relatedlists set related_coltable='invoice.accountid' where tabid=@tabid and name='get_invoices';
update ld_relatedlists set related_coltable='troubletickets.accountid' where  name='get_tickets'  and tabid=@tabid;
update ld_relatedlists set related_coltable='seproductsrel.crmid' where  name='get_products'  and tabid=@tabid;
update ld_relatedlists set related_coltable='campaignaccountrel.accountid' where  name='get_campaigns'  and tabid=@tabid;
update ld_relatedlists set related_coltable='servicecontracts.accountid' where  name='get_ServiceContracts'  and tabid=@tabid;
update ld_relatedlists set related_coltable='contactrecords.accountid' where  name='get_contactrecords'  and tabid=@tabid;
update ld_relatedlists set related_coltable='paymentplan.accountid' where  name='get_paymentplan'  and tabid=@tabid;
update ld_relatedlists set related_coltable='cashbill.accountid' where  name='get_cashbill'  and tabid=@tabid;
update ld_relatedlists set related_coltable='expense.accountid' where  name='get_expense'  and tabid=@tabid;
update ld_relatedlists set related_coltable='attachmentforbills.related_to' where  name='get_attachment';
update ld_relatedlists set related_coltable='outboundorder.accountid' where  name='get_attachment' and tabid=@tabid;
update ld_relatedlists set related_coltable='salesback.accountid' where  name='get_salesback' and tabid=@tabid;
update ld_relatedlists set related_coltable='cashback.accountid' where  name='get_cashback' and tabid=@tabid;
update ld_relatedlists set related_coltable='commission.accountid' where  name='get_commission' and tabid=@tabid;
update ld_relatedlists set related_coltable='activity.accountid' where  name='get_schedule' and tabid=@tabid;
update ld_relatedlists set related_coltable='project.accountid' where  name='get_project' and tabid=@tabid;
update ld_relatedlists set related_coltable='dividendorder.accountid' where  name='get_dividendorder' and tabid=@tabid;
update ld_relatedlists set related_coltable='servicereturn.accountid' where  name='get_servicereturn' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='project';
update ld_relatedlists set related_coltable='projectmilestone.projectid' where  name='get_dependents_list'  and tabid=@tabid and label='ProjectMilestone';
update ld_relatedlists set related_coltable='projecttask.projectid' where  name='get_dependents_list'  and tabid=@tabid and label='projecttask';
update ld_relatedlists set related_coltable='projectprogress.projectid' where  name='get_dependents_list'  and tabid=@tabid and label='ProjectProgress';
update ld_relatedlists set related_coltable='crmentityrel.crmid',type='crmentityrel_datacategory_sql' where  name='get_related_list'  and tabid=@tabid;
update ld_relatedlists set related_coltable='contactrecords.projectid' where  name='get_contactRecords'  and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='projecttask';
update ld_relatedlists set related_coltable='servicereturn.projecttaskid' where  name='get_servicereturn'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='projectprogress.projectid' where  name='get_dependents_list'  and tabid=@tabid and label='ProjectProgress';
update ld_relatedlists set related_coltable='contactrecords.projecttaskid' where  name='get_contactRecords'  and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='invoice';
update ld_relatedlists set related_coltable='cashbill2paymentplan.entitytypeid' where  name='get_cashbill'  and tabid=@tabid ;
select tabid into @tabid from ld_tab where name='purchaseinvoice';
update ld_relatedlists set related_coltable='sendcashbill2payment.entitytypeid' where  name='get_SendCashBill'  and tabid=@tabid ;
select tabid into @tabid from ld_tab where name='paymentplan';
update ld_relatedlists set related_coltable='cashbill2paymentplan.entitytypeid' where  name='get_cashbill'  and tabid=@tabid ;
delimiter;

select tabid into @tabid from ld_tab where name='sendpayment';
update ld_relatedlists set related_coltable='sendcashbill2payment.entitytypeid' where  name='get_sendcashbill'  and tabid=@tabid ;
delimiter;

select tabid into @tabid from ld_tab where name='outboundorder';
update ld_relatedlists set related_coltable='cashbill2paymentplan.entitytypeid' where  name='get_cashbill'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='inventoryproductrel.entitytypeid' where  name='get_invoices'  and tabid=@tabid ;

select tabid into @tabid from ld_tab where name='stock';
update ld_relatedlists set related_coltable='sendcashbill2payment.entitytypeid' where  name='get_SendCashBill'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='inventoryproductrel.entitytypeid' where  name='get_purchaseinvoice'  and tabid=@tabid ;
delimiter;

select tabid into @tabid from ld_tab where name='vendors';
update ld_relatedlists set related_coltable='products.vendor_id' where  name='get_products'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='purchaseorder.vendorid' where  name='get_purchase_orders'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='sendcashbill.vendorid' where  name='get_sendcashbill'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='sendpayment.vendorid' where  name='get_sendpayment'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='vendorcontacts.vendorid' where  name='get_vendorcontact'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='stock.vendor_id' where  name='get_stock'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='purchaseinvoice.vendorid' where  name='get_purchaseinvoice'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='vendorcontactrecords.vendorid' where  name='get_VendorContactRecords'  and tabid=@tabid ;
select tabid into @tabid from ld_tab where name='VendorContact';
update ld_relatedlists set related_coltable='vendorcontactrecords.contactid' where  name='get_VendorContactRecords'  and tabid=@tabid ;
delimiter;

select tabid into @tabid from ld_tab where name='purchaseorder';
update ld_relatedlists set related_coltable='inventoryproductrel.entitytypeid' where  name='get_stock'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='purchaseback.purchaseorder_id' where  name='get_purchaseback'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='inventoryproductrel.entitytypeid' where  name='get_purchaseinvoice'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='sendpayment.purchaseorder_id' where  name='get_SendPayment'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='sendcashbill2payment.entitytypeid' where  name='get_SendCashBill'  and tabid=@tabid ;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseBack';
update ld_relatedlists set related_coltable='purchasecashback.purchaseback_id' where  name='get_purchasecashback'  and tabid=@tabid ;
delimiter;

select tabid into @tabid from ld_tab where name='Campaigns';
update ld_relatedlists set related_coltable='campaignaccountrel.campaignid',type='campaignaccountrel_datacategory_sql' where  name='get_accounts'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='campaigncontrel.campaignid',type='campaigncontrel_datacategory_sql' where  name='get_contacts'  and tabid=@tabid ;
update ld_relatedlists set related_coltable='potential.campaignid',type='campaignaccountrel_datacategory_sql' where  name='get_opportunities'  and tabid=@tabid ;

select tabid into @tabid from ld_tab where name='pricebooks';
update ld_relatedlists set related_coltable='pricebookproductrel.pricebookid' ,type='pricebookproductrel_datacategory_sql' where  name='get_pricebook_products'  and tabid=@tabid ;
delimiter;

UPDATE ld_salesorder set conversion_rate=(SELECT conversion_rate FROM ld_currency_info WHERE ld_salesorder.currency_id=ld_currency_info.id) WHERE IFNULL(conversion_rate,'')='';
UPDATE ld_servicecontracts set conversion_rate=(SELECT conversion_rate FROM ld_currency_info WHERE ld_servicecontracts.currency_id=ld_currency_info.id) WHERE IFNULL(conversion_rate,'')='';
UPDATE ld_quotes set conversion_rate=(SELECT conversion_rate FROM ld_currency_info WHERE ld_quotes.currency_id=ld_currency_info.id) WHERE IFNULL(conversion_rate,'')='';
UPDATE ld_purchaseorder set conversion_rate=(SELECT conversion_rate FROM ld_currency_info WHERE ld_purchaseorder.currency_id=ld_currency_info.id) WHERE IFNULL(conversion_rate,'')='';
UPDATE ld_stock set conversion_rate=(SELECT conversion_rate FROM ld_currency_info WHERE ld_stock.currency_id=ld_currency_info.id) WHERE IFNULL(conversion_rate,'')='';
delimiter;
-- 2017-04-12

select tabid into @tabid from ld_tab where `name`='Attachment';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_attachmentsforbills';
set @columnname='attachment_no';
set @fieldname='attachment_no';
set @zh='附件编号';
set @en='附件编号';
set @uitype=4;
set @readonly=0;
set @presence=0;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','100',NULL);
delimiter;

call getallprofile('Attachment');
delimiter;
call fieldprofile('Attachment');
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,UseUserAccount,isallow,prefixtype)
select (select id+1 from ld_modentity_num_seq),'Attachment','ATT',1,1,1,'none',0,0,0 from dual 
where not exists (select 1 from ld_modentity_num where semodule='Attachment');

update ld_modentity_num_seq set id=(select max(num_id) from ld_modentity_num);
delimiter;

set @i=0;
update ld_attachmentsforbills set attachment_no=CONCAT('ATT',(@i:=@i+1)) 
where exists (select 1 from ld_modentity_num where semodule='Attachment' and active=1 and cur_id=1) ORDER BY createdtime;
delimiter;

update ld_modentity_num set cur_id=(select right(attachment_no,LENGTH(attachment_no)-3)+1 from ld_attachmentsforbills order by createdtime desc limit 1) where semodule='Attachment' and active=1 and prefix='ATT';

select tabid into @tabid from ld_tab where `name`='Attachment';
delete from ld_entityname where modulename='Attachment';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'Attachment','ld_attachmentsforbills','attachment_no','attachmentsid','attachmentsid';
delimiter;

select tabid into @tabid from ld_tab where `name`='Attachment';
update ld_field set fieldonly=1 where tabid=@tabid and columnname='attachment_no';
delimiter;

DROP PROCEDURE IF EXISTS `set_default_columnlist_V700`;
delimiter ||
CREATE PROCEDURE `set_default_columnlist_V700`(
)
begin

	declare tmp_cvid int default 0;
	declare tmp_entitytype varchar(200);
	declare cur1 CURSOR FOR SELECT cvid,entitytype FROM ld_customview WHERE entitytype in ('Attachment','Documents') ORDER BY cvid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_cvid,tmp_entitytype;
	while(tmp_cvid is not null) DO
		IF tmp_entitytype='Attachment' THEN
			SELECT tabid into @tabid FROM ld_tab WHERE `name`='Attachment';
			DELETE FROM ld_tabwithproductview WHERE cvid=tmp_cvid;

			set @i=0;
			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:attachment_no:attachment_no:Attachment_fieldlabel:V',(@i:=@i+1),tmp_cvid;
			
			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:smownerid:assigned_user_id:Attachment_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:reltab:reltab:Attachment_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:related_to:related_to:Attachment_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:createdtime:createdtime:Attachment_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbills:description:description:Attachment_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbillsdetails:filename:filename:Attachment_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbillsdetails:size:size:Attachment_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachmentsforbillsdetails:imagefromtype:imagefromtype:Attachment_fieldlabel:V',(@i:=@i+1),tmp_cvid;
		ELSEIF tmp_entitytype='Documents' THEN
			SELECT tabid into @tabid FROM ld_tab WHERE `name`='Documents';
			DELETE FROM ld_tabwithproductview WHERE cvid=tmp_cvid;

			set @i=0;
			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:note_no:note_no:Documents_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:notes_title:notes_title:Documents_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:smownerid:assigned_user_id:Documents_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:createdtime:createdtime:Documents_fieldlabel:DT',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:notecontent:notecontent:Documents_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachments:name:name:Documents_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_notes:filelocationtype:filelocationtype:Documents_fieldlabel:V',(@i:=@i+1),tmp_cvid;

			INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
			SELECT @tabid,'ld_attachments:size:size:Documents_fieldlabel:I',(@i:=@i+1),tmp_cvid;
		END IF;
		Fetch cur1 into tmp_cvid,tmp_entitytype;
	end while;
	close cur1;

end ||
delimiter;

CALL set_default_columnlist_V700();
delimiter;
-- 2017-04-13

update ld_desk set fieldlabel='把附件作为邮件附件发送' where labelbol='SENTEMAILATTACHMENTS' and languagetype='zh';

update ld_relatedlists set related_coltable='outboundorder.accountid' where tabid=6 and name='get_outorder';
update ld_relatedlists set related_coltable='attachmentsforbills.related_to' where name='get_attachment';
update ld_relatedlists set actions='' where tabid=6 and (name='get_salesback' or name='get_cashback');

update  ld_tabwithproductview set `columns`='ld_attachments:name:name:Documents_fieldlabel:V'  where tabid=8  and `columns` like '%ld_notes:name:name:Documents%';
update ld_relatedlists set related_coltable='contactrecords.potentialid' where name='get_contactrecords' and tabid=2;
update ld_relatedlists set related_coltable='quotes.potentialid' where name='get_Quotes'and tabid=2;
update ld_relatedlists set related_coltable='project.potentialid' where name='get_project' and tabid=2;
update ld_relatedlists set related_coltable='activity.potentialid' where name='get_schedule' and tabid=2;
update ld_relatedlists set related_coltable='salesorder.potentialid' where name='get_salesorder'and tabid=2;
update ld_relatedlists set related_coltable='expensedetail.entitytypeid' where name='get_expense'and tabid=2;
update ld_relatedlists set related_coltable='servicecontracts.potentialid' where name='get_servicecontracts'and tabid=2;
delimiter;

UPDATE ld_relatedlists SET related_coltable='attachmentsforbills.related_to' WHERE related_coltable='attachmentforbills.related_to'  AND `name`='get_attachment';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryAccount';
update ld_field set typeofdata = 'DT~M' where tabid = @tabid and columnname = 'operationtime';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Reminds';
select fieldid into @fieldid1 from ld_field where tabid = @tabid and columnname = 'content';
select fieldid into @fieldid2 from ld_field where tabid = @tabid and columnname = 'reltab';
select fieldid into @fieldid3 from ld_field where tabid = @tabid and columnname = 'related_to';
select fieldid into @fieldid4 from ld_field where tabid = @tabid and columnname = 'date_time';
select fieldid into @fieldid5 from ld_field where tabid = @tabid and columnname = 'smcreatorid';

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid1,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid1);
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid5,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid5);
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid4,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid4);
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid2,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid2);
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid3,0,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid3);
delimiter;

update ld_relatedlists set related_coltable='servicereturn.troubleticketid' where name='get_servicereturn' and tabid=13;
update ld_relatedlists  set type='' where  name='get_communicationLog';
select tabid into @tabid from ld_tab where name='servicecharge';
update ld_relatedlists set related_coltable='outboundorder.accountid' where name='get_outorder' and tabid=@tabid;
delimiter;

select tabid into @tabid   from ld_tab where name='salesback';
update ld_relatedlists set actions='' where name='get_cashback' and tabid=@tabid;
select tabid into @tabid from ld_tab where name='PurchaseBack';
update ld_relatedlists set actions='' where tabid=@tabid and name='get_purchasecashback';
select tabid into @tabid from ld_tab where name='products';
update ld_relatedlists set related_coltable='pricebookproductrel.productid' where name='get_product_pricebooks' and tabid=@tabid;
select tabid into @tabid  from ld_tab where name='purchaseorder';
update ld_relatedlists set actions='add' where name='get_purchaseinvoice' and tabid=@tabid;
update ld_relatedlists set actions='' where name='get_purchaseback' and tabid=@tabid;
delimiter;

select tabid into @tabid  from ld_tab where name='campaigns';
update ld_relatedlists set type='datacategory_sql' where name='get_opportunities' and tabid=@tabid;
select tabid into @tabid  from ld_tab where name='project';
update ld_relatedlists set actions='ADD' where name='get_dependents_list' and tabid=@tabid and label='ProjectTask';
select tabid into @tabid  from ld_tab where name='salesorder';
update ld_relatedlists set actions='' where name='get_cashback' and tabid=@tabid ;
update ld_relatedlists set actions='' where name='get_salesback' and tabid=@tabid ;
delimiter;

select tabid into @tabid  from ld_tab where name='ServiceContracts';
update ld_relatedlists set actions='' where name='get_cashback' and tabid=@tabid ;
update ld_relatedlists set actions='' where name='get_salesback' and tabid=@tabid ;
delimiter;

select tabid into @tabid  from ld_tab where name='ServiceCharge';
update ld_relatedlists set actions='' where name='get_cashback' and tabid=@tabid ;
update ld_relatedlists set actions='' where name='get_salesback' and tabid=@tabid ;
update ld_relatedlists set related_coltable='potential.accountid' where name='get_opportunities' and tabid=@tabid;
delimiter;

select tabid into @tabid  from ld_tab where name='projecttask';
update ld_relatedlists set related_coltable='projectprogress.projecttaskid' where name='get_dependents_list' and tabid=@tabid;
delimiter;

update ld_relatedlists set type='salesordercashback_datacategory_sql',related_coltable='main_tmp_joinTable_related_cashback.entitytypeid'
where tabid=22 and name='get_cashback';
 
update ld_tabdetailfield set typeofdata='N~O' where columnname='amount'
and tabid in(select tabid from ld_tab where name='paymentplan' or name='sendpayment');
delimiter;

update ld_usereport set advfilter=0 where `name`='Performancestatisticscollection';
delimiter;

select tabid into @tabid from ld_tab where `name`='Attachment';
select fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','PriceBooks',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'PriceBooks');
delimiter;

update ld_relatedlists set related_coltable='accountpotentialrel.potentialid' where tabid=2 AND `name`='get_accounts';
delimiter
-- 2017-04-18

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
delimiter;

update ld_version set old_version='V6.7.0',current_version='V6.7.0',remark='V6.7.0-20170418';
delimiter;