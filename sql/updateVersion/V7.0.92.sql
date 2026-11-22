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

CALL AddColumn('ld_wx_config','datetime','datetime','','');
CALL AddColumn('ld_reminds','push_time','datetime','','');
CALL AddColumn('ld_workreport_remind','push_time','datetime','','');
delimiter;
-- 2017-08-17

select tabid into @tabid from ld_tab where name='Invoice';
select blockid into @blockid from ld_appparenttab where parenttab_label='Sales';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Invoice',0,0,'ld_invoice:invoice_no:invoice_no:Invoice_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Invoice' and columnname LIKE 'ld_invoice:invoice_no:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Invoice',0,1,'ld_invoice:subject:subject:Invoice_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Invoice' and columnname LIKE 'ld_invoice:subject:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Invoice',1,0,'ld_invoice:accountid:account_id:Invoice_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Invoice' and columnname LIKE 'ld_invoice:accountid:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Invoice',1,1,'ld_invoice:total:hdnGrandTotal:Invoice_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Invoice' and columnname LIKE 'ld_invoice:total:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Invoice',1,2,'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Invoice' and columnname LIKE 'ld_invoice:smownerid:%');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'account_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETELOG','删除日志','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DELETELOG' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETELOG','Delete Log','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DELETELOG' and labeltype = 'fixedstr');
delimiter;

select max(tabid)into @maxtabid from ld_tab ;
select tabsequence into @tabsequence from ld_tab where `name` = 'Accounts';
update ld_tab set tabsequence = tabsequence +1000 where tabsequence >= @tabsequence;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'Leads',0,@tabsequence,'Leads',1 from dual 
where not EXISTS(select 1 from ld_tab where name='Leads');
set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'销售线索' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Leads' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

select max(parenttabid) into @maxparenttabid from ld_parenttab;
insert into ld_parenttab(parenttabid,parenttab_label,sequence,visible)
select @maxparenttabid+1,'Promotion platform',11,0 from dual 
where not EXISTS(select 1 from ld_parenttab where parenttab_label='Promotion platform');
delimiter;
select parenttabid into  @parenttabid  from ld_parenttab where parenttab_label='Promotion platform';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_parenttab',@parenttabid,@parenttabid,'推广平台' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_parenttab' and Relateid=@parenttabid);
select parenttabid into  @parenttabid  from ld_parenttab where parenttab_label='Promotion platform';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_parenttab',@parenttabid,@parenttabid,'Promotion platform' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_parenttab' and Relateid=@parenttabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Promotion platform';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,1 from DUAL
where not exists(select 1 from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid);
delimiter;

select max(num_id) into @maxnum_id from ld_modentity_num ;
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
select @maxnum_id+1 ,'Leads','LEA',1,1,1,'none',0,1,0 from dual 
where not EXISTS(select 1 from ld_modentity_num where semodule='Leads');
update ld_modentity_num_seq set id=@maxnum_id+1;
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs);
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','Copy','allocate','share','Delete','EditView','ADVANCE','ChangeCreator');
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
insert into ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'Leads','ld_leads','leads_no','leadsid','leadsid' from dual 
where not exists(select 1 from ld_entityname where tabid=@tabid and modulename='Leads');
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select max(blockid) into @maxblockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_LEADS_BASICINFORMATION',1,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_LEADS_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_LEADS_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');

insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+2,@tabid,'LBL_ADDRESS_BASICINFORMATION',2,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_ADDRESS_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_ADDRESS_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'地址信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Address Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');

insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+3,@tabid,'LBL_DESCRIPTION_INFORMATION',3,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_DESCRIPTION_INFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_DESCRIPTION_INFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'备注信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Description Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_LEADS_BASICINFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'accountname','ld_leads',1,1,'accountname','客户名称',1,0,1,@blockid ,1,'V~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='accountname');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+2,'leads_no','ld_leads',1,4,'leads_no','单据编号',1,0,2,@blockid ,1,'V~M',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='leads_no');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+3,'contactname','ld_leads',1,1,'contactname','联系人名称',1,0,3,@blockid ,1,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='contactname');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+4,'mobile','ld_leads',1,1101,'mobile','手机号码',1,0,4,@blockid ,1,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='mobile');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+5,'leadsource','ld_leads',1,15,'leadsource','商机来源',1,0,5,@blockid ,1,'V~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='leadsource');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+6,'status','ld_leads',1,1,'status','商机状态',1,0,6,@blockid ,2,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='status');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+7,'productcategory','ld_leads',1,15,'productcategory','意向产品',1,0,7,@blockid ,1,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='productcategory');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+8,'smownerid','ld_leads',1,53,'assigned_user_id','负责人',1,0,8,@blockid ,1,'V~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+9,'promotionalpartner','ld_leads',1,52,'promotionalpartner','直属伙伴',1,0,9,@blockid ,2,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='promotionalpartner');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+10,'promoter','ld_leads',1,52,'promoter','推客',1,0,10,@blockid ,2,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='promoter');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+11,'createdtime','ld_leads',1,70,'createdtime','创建时间',1,0,11,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+12,'smcreatorid','ld_leads',1,52,'smcreatorid','创建人',1,0,12,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+13,'modifiedtime','ld_leads',1,70,'modifiedtime','修改时间',1,0,13,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+14,'modifiedby','ld_leads',1,52,'modifiedby','最新更新人',1,0,14,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+15,'failurereason','ld_leads',1,1,'failurereason','关闭原因',1,0,15,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='failurereason');
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_ADDRESS_BASICINFORMATION';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+16,'bill_country','ld_leads',1,15,'bill_country','国家',1,0,16,@blockid ,1,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='bill_country');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+17,'bill_state','ld_leads',1,15,'bill_state','省份',1,0,17,@blockid ,1,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='bill_state');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+18,'bill_city','ld_leads',1,15,'bill_city','城市',1,0,18,@blockid ,1,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='bill_city');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+19,'bill_street','ld_leads',1,21,'bill_street','地址',1,0,19,@blockid ,1,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='bill_street');
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+20,'description','ld_leads',1,19,'description','备注',1,0,20,@blockid ,1,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='description');
delimiter;

call getallprofile('Leads');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='accountname';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'客户名称' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Account Name' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='leads_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Leads No' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='contactname';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'联系人姓名' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Contact Name' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='mobile';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'手机号码' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Mobile' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='leadsource';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'商机来源' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Leadsource' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='status';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'商机状态' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Status' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='productcategory';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'意向产品' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Product Category' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'负责人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Assigned To' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='promotionalpartner';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'直属伙伴' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Promotional Partner' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='promoter';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'推客' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Promoter' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='failurereason';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'关闭原因' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Failure Reason' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='bill_country';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'国家' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Bill Country' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='bill_state';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'省份' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Bill State' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='bill_city';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'城市' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Bill City' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='bill_street';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'地址' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Bill Street' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'备注' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'Leads',3,1,1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='Leads' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+2,'推广平台',0,0,'Leads',3,1,2 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='Leads' and viewname='推广平台');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+3,'新建',0,0,'Leads',3,1,3 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='Leads' and viewname='新建');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+4,'跟进中',0,0,'Leads',3,1,4 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='Leads' and viewname='跟进中');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+5,'失败关闭',0,0,'Leads',3,1,5 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='Leads' and viewname='失败关闭');
update ld_customview_seq set id = (select max(cvid) from ld_customview);
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select cvid into @cvid from ld_customview where entitytype='Leads' and viewname='All';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_leads:leads_no:leads_no:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_leads:accountname:accountname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_leads:contactname:contactname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_leads:mobile:mobile:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_leads:leadsource:leadsource:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_leads:status:status:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_leads:bill_state:bill_state:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_leads:bill_city:bill_city:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'ld_leads:smownerid:assigned_user_id:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'ld_leads:modifiedtime:modifiedtime:Leads_fieldlabel:D';
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select cvid into @cvid from ld_customview where entitytype='Leads' and viewname='推广平台';
delete from ld_cvcolumnlist where cvid = @cvid;
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_leads:leadsource:leadsource:Leads_fieldlabel:V','e','推广平台',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_leads:leads_no:leads_no:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_leads:accountname:accountname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_leads:contactname:contactname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_leads:mobile:mobile:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_leads:leadsource:leadsource:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_leads:status:status:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_leads:bill_state:bill_state:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_leads:bill_city:bill_city:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'ld_leads:smownerid:assigned_user_id:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'ld_leads:modifiedtime:modifiedtime:Leads_fieldlabel:D';
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select cvid into @cvid from ld_customview where entitytype='Leads' and viewname='新建';
delete from ld_cvcolumnlist where cvid = @cvid;
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_leads:status:status:Leads_fieldlabel:V','e','新建',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_leads:leads_no:leads_no:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_leads:accountname:accountname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_leads:contactname:contactname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_leads:mobile:mobile:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_leads:leadsource:leadsource:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_leads:bill_state:bill_state:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_leads:bill_city:bill_city:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_leads:smownerid:assigned_user_id:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'ld_leads:modifiedtime:modifiedtime:Leads_fieldlabel:D';
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select cvid into @cvid from ld_customview where entitytype='Leads' and viewname='跟进中';
delete from ld_cvcolumnlist where cvid = @cvid;
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_leads:status:status:Leads_fieldlabel:V','e','跟进中',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_leads:leads_no:leads_no:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_leads:accountname:accountname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_leads:contactname:contactname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_leads:mobile:mobile:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_leads:leadsource:leadsource:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_leads:bill_state:bill_state:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_leads:bill_city:bill_city:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_leads:smownerid:assigned_user_id:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'ld_leads:modifiedtime:modifiedtime:Leads_fieldlabel:D';
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select cvid into @cvid from ld_customview where entitytype='Leads' and viewname='失败关闭';
delete from ld_cvcolumnlist where cvid = @cvid;
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_leads:status:status:Leads_fieldlabel:V','e','失败关闭',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_leads:leads_no:leads_no:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_leads:accountname:accountname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_leads:contactname:contactname:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_leads:mobile:mobile:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_leads:leadsource:leadsource:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_leads:bill_state:bill_state:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_leads:bill_city:bill_city:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_leads:failurereason:failurereason:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'ld_leads:smownerid:assigned_user_id:Leads_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'ld_leads:modifiedtime:modifiedtime:Leads_fieldlabel:D';
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select tabid into @related_tabid from ld_tab where name='reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,'创建提醒' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-1',2,0,'修改日志' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-1');
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-10',3,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-10');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Leads';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,5,0,'打印工具' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-1,'get_SharedUsers',1,'SharedUsers',0,'share','','' from dual 
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-1' and name='get_SharedUsers');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Leads';
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from DUAL
where not exists(select 1 from ld_def_org_share where tabid = @tabid);
delimiter;

call addtabintoprofile('Leads',1);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FOLLOWING','跟进中','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'FOLLOWING' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FOLLOWING','Following','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'FOLLOWING' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FAILLEDTOCOLSE','失败关闭','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'FAILLEDTOCOLSE' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FAILLEDTOCOLSE','Failed to close','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'FAILLEDTOCOLSE' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INITIAL','新建','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'INITIAL' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INITIAL','Initial','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'INITIAL' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UPGRADE','升级','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'UPGRADE' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UPGRADE','Upgrade','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'UPGRADE' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIELDSMAPPING','映射','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'FIELDSMAPPING' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIELDSMAPPING','Mapping','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'FIELDSMAPPING' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIELDSMAPPING','映射','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'FIELDSMAPPING' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIELDSMAPPING','Mapping','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'FIELDSMAPPING' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_Field','字段','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'LBL_Field' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_Field','Field','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'LBL_Field' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Reason','原因','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'Reason' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Reason','Reason','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'Reason' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'promotionalpartner','ld_account',1,52,'promotionalpartner','直属伙伴',1,0,9,@blockid ,2,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='promotionalpartner');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+2,'promoter','ld_account',1,52,'promoter','推客',1,0,10,@blockid ,2,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='promoter');

select tabid into @tabid from ld_tab  where name='Accounts';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='promotionalpartner';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'直属伙伴' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Promotional Partner' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Accounts';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='promoter';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'推客' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Promoter' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid = @tabid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'promotionalpartner','ld_account',1,52,'promotionalpartner','直属伙伴',1,0,@sequence+1,@blockid ,2,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='promotionalpartner');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+2,'promoter','ld_account',1,52,'promoter','推客',1,0,@sequence+2,@blockid ,2,'V~O',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='promoter');

select tabid into @tabid from ld_tab  where name='Accounts';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='promotionalpartner';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'直属伙伴' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Promotional Partner' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='Accounts';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='promoter';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'推客' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Promoter' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

call AddColumn('ld_account','promotionalpartner','int','11',0);
call AddColumn('ld_account','promoter','int','11',0);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_leads` (
  `leadsid` int(11) NOT NULL AUTO_INCREMENT,
  `leads_no` varchar(25) DEFAULT NULL,
  `accountname` varchar(80) DEFAULT NULL,
  `contactname` varchar(80) DEFAULT NULL,
  `mobile` varchar(25) DEFAULT NULL,
  `leadsource` varchar(25) DEFAULT NULL,
  `status` varchar(25) DEFAULT '新建',
  `productcategory` varchar(25) DEFAULT NULL,
  `smownerid` int(11) DEFAULT NULL,
  `promotionalpartner` int(11) DEFAULT NULL,
  `promoter` int(11) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smcreatorid` int(11) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `modifiedby` int(11) DEFAULT NULL,
  `failurereason` text,
  `bill_country` varchar(30) DEFAULT NULL,
  `bill_state` varchar(30) DEFAULT NULL,
  `bill_city` varchar(30) DEFAULT NULL,
  `bill_street` text,
  `description` text,
  `deleted` int(11) DEFAULT '0',
  `accountsaveid` int(19) DEFAULT '0',
  `marketpersonid` int(19) DEFAULT '0',
  PRIMARY KEY (`leadsid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_leadscf` (
  `leadsid` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`leadsid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_module_mappingfields` (
  `tabid` int(11) DEFAULT NULL,
  `fieldid` int(11) DEFAULT NULL,
  `columnname` varchar(25) DEFAULT NULL,
  `mapping_module` varchar(25) DEFAULT NULL,
  `mapping_columnname` varchar(25) DEFAULT NULL,
  `is_disabled` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'accountname';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'Accounts','accountname',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'leads_no';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'Accounts','account_no',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'contactname';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname)
select @tabid,@fieldid,@columnname,'Contacts','lastname' from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'mobile';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname)
select @tabid,@fieldid,@columnname,'Contacts','mobile' from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'leadsource';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname)
select @tabid,@fieldid,@columnname,'Accounts','leadsource' from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'status';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname)
select @tabid,@fieldid,@columnname,'Accounts','' from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'productcategory';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname)
select @tabid,@fieldid,@columnname,'Accounts','productcategory' from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'Accounts','smownerid',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'smcreatorid';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'Accounts','smcreatorid',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'failurereason';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname)
select @tabid,@fieldid,@columnname,'Accounts','' from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'bill_country';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'AccountsContacts','bill_country',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'bill_state';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'AccountsContacts','bill_state',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'bill_city';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'AccountsContacts','bill_city',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'bill_street';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'AccountsContacts','bill_street',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'description';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname)
select @tabid,@fieldid,@columnname,'Accounts','description' from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'promotionalpartner';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'Accounts','promotionalpartner',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid = @tabid and columnname = 'promoter';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'Accounts','promoter',1 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
delimiter;
-- 2017-08-22

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 48;
update ld_systems_deploy set sequence = sequence+1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,141,'设置是否允许负库存出库','',@sequence+1,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]' from DUAL
where not EXISTS(select 1 from ld_systems_deploy where deploy_type = 141);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',141,141,'设置是否允许负库存出库' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid = 141 and Relateid = 141);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',141,141,'Set whether negative inventory is allowed' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid = 141 and Relateid = 141);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHETHERTOCONTINUE','是否继续？','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'WHETHERTOCONTINUE' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHETHERTOCONTINUE','continue or not?','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'WHETHERTOCONTINUE' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTSQUANTITYEXCESS','产品数量超过总库存数量','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'PRODUCTSQUANTITYEXCESS' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTSQUANTITYEXCESS','Product quantity excess total inventory quantity','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'PRODUCTSQUANTITYEXCESS' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','productquantity','产品数量','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'productquantity' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','productquantity','Product quantity','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'productquantity' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QTYINSTOCK','总库存数量','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'QTYINSTOCK' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QTYINSTOCK','Total inventory quantity','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'QTYINSTOCK' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHECKFAIL','审核失败','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CHECKFAIL' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHECKFAIL','Check Failure','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CHECKFAIL' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name`= 'Leads';
update ld_field set issmownerid = 0 where tabid = @tabid;
update ld_field set issmownerid = 1 where tabid = @tabid and columnname = 'smownerid' and fieldname = 'assigned_user_id';
delimiter;

select min(picklist_valueid) into @picklist_valueid from ld_leadsource;
update ld_leadsource set picklist_valueid = picklist_valueid + 1000;
insert into ld_leadsource(leadsource,presence,picklist_valueid)
select '推广平台',1,@picklist_valueid from DUAL
where not exists(select 1 from ld_leadsource where leadsource = '推广平台');
set @i=@picklist_valueid;
update ld_leadsource set picklist_valueid=(@i:=@i+1) order by picklist_valueid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field set quickcreate = 1 where tabid = @tabid and columnname in ('promotionalpartner','promoter');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
update ld_field set quickcreate = 1 where tabid = @tabid and columnname in ('promotionalpartner','promoter','status','leads_no');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
update ld_field set allowhide = 'no' where tabid = @tabid and columnname in ('accountname','leads_no');
update ld_field set fieldonly = 1 where tabid = @tabid and columnname = 'accountname';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
update ld_entityname set fieldname = 'accountname' where tabid = @tabid;
update ld_field set defaultvalue = '中国' where tabid = @tabid and columnname = 'bill_country';
update ld_field set defaultvalue = '--无--' where tabid = @tabid and columnname = 'bill_state';
update ld_field set defaultvalue = '--无--' where tabid = @tabid and columnname = 'bill_city';
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_LEADS_BASICINFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select sequence into @sequence from ld_field where tabid = @tabid and columnname = 'contactname';
update ld_field set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate)
select @tabid,@maxfieldid+1,'contact_job','ld_leads',1,1,'contact_job','联系人职位',1,0,@sequence+1,@blockid ,1,'V~O',0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='contact_job');

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='contact_job';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'联系人职位' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Contact Job' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

call AddColumn('ld_leads','contact_job','varchar','100',NULL);
delimiter;

select tabid into @tabid from ld_tab  where name='Leads';
select fieldid,columnname into @fieldid,@columnname from ld_field where tabid=@tabid and columnname='contact_job';
insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
select @tabid,@fieldid,@columnname,'Contacts','',0 from DUAL
where not exists(select 1 from ld_module_mappingfields where columnname = @columnname);
delimiter;

call getallprofile('Leads');
delimiter;

delete from ld_field where tabid = 22 and tablename in ('ld_sobillads','ld_soshipads');
delimiter;

select tabid into @tabid from ld_tab where name='PaymentPlan';
select blockid into @blockid from ld_appparenttab where parenttab_label='Sales';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'PaymentPlan',0,0,'ld_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PaymentPlan' and columnname LIKE 'ld_paymentplan:paymentplan_no:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'PaymentPlan',0,1,'ld_paymentplan:accountid:account_id:PaymentPlan_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PaymentPlan' and columnname LIKE 'ld_paymentplan:accountid:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'PaymentPlan',1,0,'ld_paymentplan:amount:amount:PaymentPlan_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PaymentPlan' and columnname LIKE 'ld_paymentplan:amount:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'PaymentPlan',1,1,'ld_paymentplan:entitytypeid:entitytypeid:PaymentPlan_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PaymentPlan' and columnname LIKE 'ld_paymentplan:entitytypeid:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'PaymentPlan',1,2,'ld_paymentplan:smownerid:assigned_user_id:PaymentPlan_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PaymentPlan' and columnname LIKE 'ld_paymentplan:smownerid:%');
delimiter;

select tabid into @tabid from ld_tab where name='PaymentPlan';
update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;
select tabid into @tabid from ld_tab where name='Invoice';
update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;
-- 2017-08-24

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Leads';
SELECT defaultvalue INTO @defaultvalue FROM ld_field WHERE tabid=6 AND columnname='bill_state';
UPDATE ld_field SET defaultvalue=@defaultvalue WHERE tabid=@tabid AND columnname='bill_state';
delimiter;

UPDATE ld_tab a
LEFT JOIN ld_field b ON a.tabid=b.tabid
LEFT JOIN ld_tranlabel c ON c.Relateid=b.fieldid AND c.trantable='ld_field'
SET c.fieldlabel='联系人职务'
WHERE a.`name`='Leads'
	AND b.columnname='contact_job'
	AND c.languagetype='zh'
	AND c.fieldlabel='联系人职位';
    
SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Leads';
UPDATE ld_module_mappingfields SET mapping_columnname='title' 
WHERE tabid=@tabid AND columnname='contact_job' AND mapping_module='Contacts' AND IFNULL(mapping_columnname,'')='';
delimiter;

SELECT fieldid INTO @trigger_fieldid FROM ld_field WHERE tabid=22 AND columnname='potentialid'; 
SELECT fieldid INTO @effect_fieldid FROM ld_field WHERE tabid=22 AND columnname='contactid'; 
DELETE FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid; 
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select tabid into @related_tabid from ld_tab where name='reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,'创建提醒' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-1',2,0,'修改日志' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-1');
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-10',3,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-10');
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
INSERT INTO ld_modtracker_tabs(tabid,visible)
SELECT @tabid,1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','afteroperationthisrecord','升级后将转入"{$Accounts.Accounts}"模块，是否继续？','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'afteroperationthisrecord' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','afteroperationthisrecord','After operation this record will be transferred to "{$Accounts.Accounts}",continue or not?','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'afteroperationthisrecord' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RepeatUpgradeFAILED','重复，升级失败！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'RepeatUpgradeFAILED' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RepeatUpgradeFAILED',' repeat,upgrade failed!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'RepeatUpgradeFAILED' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ISNULLUpgradeFAILED','为空，升级失败！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ISNULLUpgradeFAILED' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ISNULLUpgradeFAILED',' is null,upgrade failed!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ISNULLUpgradeFAILED' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel = 'product quantity' where labelbol = 'productquantity' and languagetype = 'en';
delimiter;
update ld_desk set fieldlabel = 'total inventory quantity' where labelbol = 'QTYINSTOCK' and languagetype = 'en';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'create_paymentplan','create_paymentplan','http://51mis.com.cn/forum.php?mod=viewthread&tid=157&fromuid=1','合同订单创建回款计划' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype ='create_paymentplan' and linklabel = 'create_paymentplan');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'create_paymentplan','create_paymentplan','http://51mis.com.cn/forum.php?mod=viewthread&tid=158&fromuid=1','服务合同创建回款计划' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype ='create_paymentplan' and linklabel = 'create_paymentplan');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
update ld_field set fieldonly = 1 where columnname = 'leads_no';
delimiter;

update ld_field set issmownerid = 0 where tabid = 6 and columnname in ('promotionalpartner','promoter');
delimiter;

call ChangeColumn('ld_leadscf','leadid','leadsid','int','11');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
insert into ld_org_share_action2tab(share_action_id,tabid)
select 0,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where tabid = @tabid and share_action_id = 0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 1,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where tabid = @tabid and share_action_id = 1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 2,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where tabid = @tabid and share_action_id = 2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 3,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where tabid = @tabid and share_action_id = 3);
delimiter;

DROP TABLE IF EXISTS ld_sobillads;
DROP TABLE IF EXISTS ld_soshipads;
call DEL_FK('ld_leadscf','ld_leadscf_ibfk_1');
delimiter;

update ld_customview set sequence = 0 where entitytype = 'Leads' and viewname = 'All';
delimiter;
-- 2017-08-28

ALTER TABLE ld_hantian_phonerecord MODIFY COLUMN userid INT(19);

select tabid into @tabid from ld_tab where name='Users';
select max(blockid) into @maxblockid from ld_blocks ;
select sequence into @sequence from ld_blocks where tabid=@tabid and blocklabel='LBL_USERLOGIN_MOBILE';
update ld_blocks set sequence=sequence+2 where sequence>@sequence and tabid=@tabid;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_USERLOGIN_WEIXIN',@sequence+1,0,0,0,0,0,1,0 from DUAL 
where not EXISTS(select 1 from ld_blocks where tabid=@tabid and blocklabel='LBL_USERLOGIN_WEIXIN');
set @i=0;

update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USERLOGIN_WEIXIN';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_blocks',@tabid,@blockid,'微信端相关设置' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_blocks' and tabid=@tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_blocks',@tabid,@blockid,'Weixin terminal related settings' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_blocks' and tabid=@tabid and relateid=@blockid);
delimiter;

call AddColumn('ld_users','push_wx_reminds','int',4,0);
delimiter;

select max(fieldid) into @maxfieldid from ld_field ;
select tabid into @tabid from ld_tab where name='Users';
select blockid into @blockid from ld_blocks where blocklabel='LBL_USERLOGIN_WEIXIN';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'push_wx_reminds','ld_users',1,56,'push_wx_reminds','是否允许推送微信提醒',0,0,1, @blockid,1,'V~O',3,1,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='push_wx_reminds');
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='push_wx_reminds');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='push_wx_reminds';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'是否允许推送微信提醒' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Are allowed to push weixin reminder' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

update ld_users set push_wx_reminds = 1;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wxmoduleset` (
  `userid` int(11) NOT NULL DEFAULT '0',
  `modulename` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
-- 2017-08-29

UPDATE ld_desk SET fieldlabel='我共享给他人的' WHERE labelbol='Ishared' AND languagetype='zh' AND fieldlabel='共享给他人的';

select tabid into @tabid from ld_tab where `name` = 'Invoice'; 
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202; 
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid'; 
delete from ld_related_field where trigger_fieldid = @trigger_fieldid and @effect_fieldid = effect_fieldid; 
delimiter;

select id into @id from ld_option_showtableheader where module='Invoice' and selectmodule='SalesOrder';
update ld_option_showheader_label set columnname = 'have_invoicetotal' where columnname = 'invoicetotal' and label_from = 'desk' and optionshowtabheader_id = @id;
delimiter;

update ld_desk set fieldlabel = '我共享给他人的' where labelbol = 'Ishared' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'I share it with others' where labelbol = 'Ishared' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
delete from ld_usereportbasic where Usereportid = @usereportid and columns = 'ld_troubletickets:approvestatus:approvestatus:HelpDesk_approvestatus:I';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'entitytypeid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'account_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

alter table ld_productcurrencyrel modify column converted_price decimal(25,8);
alter table ld_productcurrencyrel modify column actual_price decimal(25,8);
delimiter;

update ld_desk set fieldlabel = '1.	{$HelpDesk.HelpDesk}业绩=({$HelpDesk.productcategory}绩效基数*{$HelpDesk.ticketcategories}绩效权重*0.01 + {$Accounts.bill_city}绩效基数)*{$HelpDesk.servicetype}*0.01*{$ServiceReturn.resolutionrate}*{$ServiceReturn.timelyrate}*{$ServiceReturn.satisfaction}'
where labelbol = 'Performance_scores_1' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '1.	Performance scores of {$HelpDesk.HelpDesk}=scores of ({$HelpDesk.productcategory} * {$HelpDesk.ticketcategories} * weight*0.01+ scores of {$Accounts.bill_city})*{$HelpDesk.servicetype}*0.01*{$ServiceReturn.resolutionrate}*{$ServiceReturn.timelyrate}*{$ServiceReturn.satisfaction}'
where labelbol = 'Performance_scores_1' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

call AddColumn('ld_approvereminds','reminduserid','varchar','200',NULL);
delimiter;
-- 2017-09-04

select tabid into @tabid from ld_tab where `name` = 'Invoice'; 
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid'; 
delete from ld_related_field where trigger_fieldid = @trigger_fieldid; 
delimiter;

SELECT autotaskid INTO @autotaskid FROM ld_autotask WHERE tabid=6 AND autotaskname='30天未联系客户自动转公海';
UPDATE ld_autotaskquery SET `query`=CONCAT("DROP PROCEDURE IF EXISTS `task_turntopublick_over30days`;
delimiter $","$
CREATE  PROCEDURE `task_turntopublick_over30days`(
)
BEGIN
	declare tmp_accountid  int default 0;
	declare tmp_accountname varchar(200) default '';
	declare tmp_smownerid  int default 0;
	declare mycursor cursor for select accountid, accountname,smownerid from ld_account where nolinkdays>30 and publicaccount<>1;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_accountid = NULL;
	open mycursor;
	fetch mycursor into tmp_accountid,tmp_accountname,tmp_smownerid;
	while(tmp_accountid is not null) DO
		update ld_account set protectdate=NULL,publicaccount=1 where accountid=tmp_accountid;
		set @maxid=0;
		select max(crmid) into @maxid from ld_crmentity;
		insert into ld_crmentity(crmid,setype)
		select @maxid+1,'Reminds';

		update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);

		insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
		select @maxid+1,concat('计划任务：30天未联系客户自动转公海已执行，客户：',tmp_accountname,'已自动转公海！'),now(),tmp_smownerid,'未读',tmp_accountid,'Accounts',0,0,0,1,1,1,now(),now(),null,0;
		

		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'zh','TASK_30DAYNOLINK_TOBETHEHIGHSEAS','自动任务：30天未联系客户自动转公海','fixedstr' FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='TASK_30DAYNOLINK_TOBETHEHIGHSEAS' AND languagetype='zh');

		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'en','TASK_30DAYNOLINK_TOBETHEHIGHSEAS','自动任务：30天未联系客户自动转公海','fixedstr' FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='TASK_30DAYNOLINK_TOBETHEHIGHSEAS' AND languagetype='en');
	
		insert into ld_logpublicaccount(username,operation,opdate,accountid)
		select '系统','TASK_30DAYNOLINK_TOBETHEHIGHSEAS',NOW(),tmp_accountid;

		fetch mycursor into tmp_accountid,tmp_accountname,tmp_smownerid;

	end while;
	close mycursor;
EN","D $$
delimit","er;
call task_turntopublick_over30days;
delimit","er;")
WHERE autotaskid=@autotaskid;
delimiter;

select max(sequence) into @sequence from ld_appparenttab;
insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '财务管理',0,@sequence+1,'yes','Finacial' from DUAL
where not exists(select 1 from ld_appparenttab where blockname='财务管理');
update ld_appparenttab set systemdefault='yes',parenttab_label='Finacial' where blockname='财务管理';
delimiter;
insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '其他',0,@sequence+2,'yes','Others' from DUAL
where not exists(select 1 from ld_appparenttab where blockname='其他');
update ld_appparenttab set systemdefault='yes',parenttab_label='Others' where blockname='其他';
delimiter;
select blockid into @blockid from ld_appparenttab where parenttab_label='Finacial';
update ld_appparenttabrel set blockid=@blockid where tabid 
in(select tabid from ld_tab where name in('Invoice','CashBill','PaymentPlan'));
set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid ORDER BY sequence;
delimiter;
select blockid into @blockid from ld_appparenttab where parenttab_label='Others';
update ld_appparenttabrel set blockid=@blockid where tabid 
in(select tabid from ld_tab where name in('PublicAnnouncement'));
set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid ORDER BY sequence;
delimiter;
select tabid into @tabid from ld_tab where name='ModComments';
select blockid into @blockid from ld_appparenttab where parenttab_label='Others';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ModComments',0,0,'ld_modcomments:commentcontent:commentcontent:ModComments_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ModComments' and columnname LIKE 'ld_modcomments:commentcontent:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ModComments',0,1,'ld_modcomments:related_to:related_to:ModComments_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ModComments' and columnname LIKE 'ld_modcomments:related_to:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ModComments',1,0,'ld_modcomments:createdtime:createdtime:ModComments_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ModComments' and columnname LIKE 'ld_modcomments:createdtime:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ModComments',1,1,'ld_modcomments:smownerid:assigned_user_id:ModComments_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ModComments' and columnname LIKE 'ld_modcomments:smownerid:%');
delimiter;

select tabid into @tabid from ld_tab where name='ProjectMilestone';
select blockid into @blockid from ld_appparenttab where parenttab_label='Project';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ProjectMilestone',0,0,'ld_projectmilestone:projectmilestone_no:projectmilestone_no:ProjectMilestone_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectMilestone' and columnname LIKE 'ld_projectmilestone:projectmilestone_no:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ProjectMilestone',0,1,'ld_projectmilestone:projectmilestonename:projectmilestonename:ProjectMilestone_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectMilestone' and columnname LIKE 'ld_projectmilestone:projectmilestonename:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ProjectMilestone',1,0,'ld_projectmilestone:projectmilestonedate:projectmilestonedate:ProjectMilestone_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectMilestone' and columnname LIKE 'ld_projectmilestone:projectmilestonedate:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ProjectMilestone',1,1,'ld_projectmilestone:smownerid:assigned_user_id:ProjectMilestone_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectMilestone' and columnname LIKE 'ld_projectmilestone:smownerid:%');
delimiter;

select tabid into @tabid from ld_tab where name='Rate';
select blockid into @blockid from ld_appparenttab where parenttab_label='Project';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Rate',0,0,'ld_rate:ratename:ratename:Rate_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Rate' and columnname LIKE 'ld_rate:ratename:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Rate',0,1,'ld_rate:rate:rate:Rate_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Rate' and columnname LIKE 'ld_rate:rate:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Rate',1,0,'ld_rate:startdate:startdate:Rate_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Rate' and columnname LIKE 'ld_rate:startdate:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Rate',1,1,'ld_rate:enddate:enddate:Rate_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Rate' and columnname LIKE 'ld_rate:enddate:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Rate',1,2,'ld_rate:smownerid:assigned_user_id:Rate_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Rate' and columnname LIKE 'ld_rate:smownerid:%');
delimiter;

select tabid into @tabid from ld_tab where name='ServiceReturn';
select blockid into @blockid from ld_appparenttab where parenttab_label='Service';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ServiceReturn',0,0,'ld_servicereturn:servicereturn_no:servicereturn_no:ServiceReturn_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceReturn' and columnname LIKE 'ld_servicereturn:servicereturn_no:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ServiceReturn',0,1,'ld_servicereturn:accountid:account_id:ServiceReturn_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceReturn' and columnname LIKE 'ld_servicereturn:accountid:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ServiceReturn',1,0,'ld_servicereturn:createdtime:createdtime:ServiceReturn_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceReturn' and columnname LIKE 'ld_servicereturn:createdtime:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ServiceReturn',1,1,'ld_servicereturn:smownerid:assigned_user_id:ServiceReturn_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceReturn' and columnname LIKE 'ld_servicereturn:smownerid:%');
delimiter;
update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;


alter table ld_products modify column unit_price decimal(25,8);
alter table ld_products modify column costprice decimal(25,8);
delimiter;


select tabid into @tabid from ld_tab where name='Products';
update ld_relatedlists set wx_presence=1 where tabid=@tabid 
and related_tabid in(select tabid from ld_tab where name in('HelpDesk','SalesOrder'));
delimiter;
select tabid into @tabid from ld_tab where name='Potentials';
update ld_relatedlists set wx_presence=1 where tabid=@tabid 
and related_tabid =(select tabid from ld_tab where name = 'Contacts');
delimiter;


select tabid into @tabid from ld_tab where name='Invoice';
select blockid into @blockid from ld_appparenttab where parenttab_label='Finacial';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
delete from ld_appparenttabrel where tabid=@tabid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
values(@blockid,@tabid,@sequence+1);
delimiter;

select tabid into @tabid from ld_tab where name='PaymentPlan';
select blockid into @blockid from ld_appparenttab where parenttab_label='Finacial';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
delete from ld_appparenttabrel where tabid=@tabid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
values(@blockid,@tabid,@sequence+1);
delimiter;

select tabid into @tabid from ld_tab where name='ServiceContracts';
select blockid into @blockid from ld_appparenttab where parenttab_label='Service';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
delete from ld_appparenttabrel where tabid=@tabid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
values(@blockid,@tabid,@sequence+1);
delimiter;

select tabid into @tabid from ld_tab where name='Products';
update ld_relatedlists set wx_presence=0 where tabid=@tabid 
and related_tabid in(select tabid from ld_tab where name in('HelpDesk','SalesOrder'));
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
update ld_relatedlists set wx_presence=0 where tabid=@tabid 
and related_tabid =(select tabid from ld_tab where name = 'Contacts');
delimiter;
-- 2017-09-07

update ld_systems_deploy set deploy_value = 1 where deploy_type = 141;
delimiter;

select tabid into @tabid from ld_tab where name='ServiceReturn';
update ld_relatedlists set actions='add' where related_tabid=@tabid;
delimiter;
select tabid into @tabid from ld_tab where name='ProjectMilestone';
update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;
select tabid into @tabid from ld_tab where name='ProjectProgress';
update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;
select tabid into @tabid from ld_tab where name='CashBill';
update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 141;
update ld_systems_deploy set sequence = sequence+1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,142,'控制合同订单是否需要提示负库存','',@sequence+1,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]' from DUAL
where not EXISTS(select 1 from ld_systems_deploy where deploy_type = 142);
set @i=0;

update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',142,142,'控制合同订单是否需要提示负库存' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid = 142 and Relateid = 142);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',142,142,'Control the sales order whether negative stock should be prompted' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid = 142 and Relateid = 142);
delimiter;

select tabid into @tabid from ld_tab where name='ServiceReturn';
update ld_relatedlists set actions='' where related_tabid=@tabid;
delimiter;
-- 2017-09-11

select tabid into @tabid from ld_tab where name='Products';
update ld_relatedlists set wx_presence = 1 where tabid=@tabid and related_tabid in 
(select tabid from ld_tab where name in('SalesOrder','Invoice'));
delimiter;

call AddColumn('ld_reminds','remindstype','varchar','200',NULL);
delimiter;

select tabid into @tabid from ld_tab where name='Products';
update ld_relatedlists set wx_presence = presence where tabid=@tabid and related_tabid in 
(select tabid from ld_tab where name in ('SalesOrder','Invoice','PurchaseOrder'));
delimiter;
-- 2017-09-13

select tabid into @tabid from ld_tab where name='PurchaseOrder';
update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','crmserver','您的CRM服务器不能访问外网，请设置允许服务器访问外网！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'crmserver' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','crmserver','Your CRM server cannot access the extranet. Please allow the server to access the extranet!','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'crmserver' and labeltype = 'jspop');
delimiter;

insert into ld_links(linktype,linklabel,linkurl,description)
select 'Settings','ApproveList','http://51mis.com.cn/forum.php?mod=viewthread&tid=42&fromuid=1','控制面板-审批流程管理' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'ApproveList');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
update ld_relatedlists set wx_presence=presence where related_tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
update ld_field set uitype=81 where tabid=@tabid and fieldname='vendor_id';
delimiter;

select tabid into @vtabid from ld_tab where name='Vendors';
select tabid into @stabid from ld_tab where name = 'Stock';
update ld_relatedlists set related_coltable='stock.vendorid' where tabid=@vtabid and related_tabid=@stabid;
delimiter;

update ld_producttoolfield set uitype = 72 where columnname = 'productcost' and input_type = 1 and fieldid > 0;
delimiter;

call AddColumn('ld_productcurrencyrel','price_type','varchar','100',NULL);
delimiter;
update ld_productcurrencyrel set price_type = 'unit_price' where price_type is NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','nextstepofapproval','下一步审批人','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'nextstepofapproval' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','nextstepofapproval','下一步审批人','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'nextstepofapproval' and labeltype = 'jspop');
delimiter;
-- 2017-09-19

update ld_field set allowhide='yes' WHERE tabid=14 AND columnname='discontinued';
ALTER TABLE ld_products alter  COLUMN discontinued SET DEFAULT 0;

DROP PROCEDURE IF EXISTS `ldcrm_add_reminder`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_reminder`(
	tmp_content text,
	tmp_recieverid int(19),
    tmp_reltab varchar(100),
	tmp_related_to int(19)
    
)
BEGIN
	
	set @maxid=0;
	select max(crmid) into @maxid from ld_crmentity;
	insert into ld_crmentity(crmid,setype)
	select @maxid+1,'Reminds';			
	insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
	select @maxid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0;

	update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);

end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_gonggao_reminder`;
delimiter ||
CREATE PROCEDURE `task_gonggao_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_userid INT(19) DEFAULT 0;
	DECLARE tmp_content text DEFAULT '';

	DECLARE Mycur CURSOR FOR
		SELECT 
			a.publicannouncementid,
			b.userid
		FROM ld_publicannouncement a
		LEFT JOIN ld_publicannouncement_reminds b ON a.publicannouncementid=b.crmid
		WHERE a.deleted=0
			AND CURDATE() BETWEEN startdate AND enddate
			AND NOT EXISTS (SELECT 1 FROM ld_reminds WHERE related_to=a.publicannouncementid AND recieverid=b.userid AND content like '公告提醒：有新的公告，请及时关注！');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	OPEN Mycur;
	FETCH Mycur INTO tmp_id,tmp_userid;
	WHILE (tmp_id IS NOT NULL) DO
		SET @content='公告提醒：有新的公告，请及时关注！';
		CALL ldcrm_add_reminder(@content,tmp_userid,'PublicAnnouncement',tmp_id);
		FETCH Mycur INTO tmp_id,tmp_userid;
	END WHILE;
	CLOSE Mycur;	
end ||
delimiter;

SET GLOBAL event_scheduler = on;
DROP EVENT IF EXISTS `task_gonggao_reminder`;
CREATE EVENT `task_gonggao_reminder`
ON SCHEDULE EVERY 300 SECOND STARTS '2017-06-23 14:00:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

CALL task_gonggao_reminder();
delimiter;

update ld_field set displaytype = 2 where tabid = 14 and columnname = 'modifiedby' and displaytype = 3;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'telephone_view';
update ld_tranlabel set fieldlabel = '是否允许该用户访问手机APP通讯录' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Do you allow this user to access the mobile APP address book' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'en';
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type=132;
update ld_systems_deploy set sequence=sequence+2 where sequence>@sequence and roottype=4;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,inputvalue,presence)
select 0,143,'微信端外勤签到时客户是否必录。1:否，0:是',@sequence+1,4,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=143);
delimiter;

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=143 AND NOT EXISTS (SELECT 1 FROM ld_singin); 

set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=4 order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',143,143,'微信端外勤签到时客户是否必录'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=143);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',143,143,'WeChat in the end whether the customer will be recorded'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=143);
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type=143;
update ld_systems_deploy set sequence=sequence+2 where sequence>@sequence and roottype=4;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,inputvalue,presence)
select 0,144,'微信端工作日志中是否显示关联客户、联系人和产品',@sequence+1,4,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=144);
delimiter;

set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=4 order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',144,144,'微信端工作日志中是否显示关联客户、联系人和产品'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=144);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',144,144,'Whether display associated customer、 contact and product when use WeChat'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=144);

update ld_version set wx_version='V4' where id=1;
delimiter;
-- 2017-09-22

select tabid into @tabid from ld_tab where name='OutboundOrder';
delete from ld_appparenttabrel where tabid=@tabid;
select blockid into @blockid from ld_appparenttab where parenttab_label='Inventory';
insert into ld_appparenttabrel(blockid,tabid,sequence)
values(@blockid,@tabid,1);
select tabid into @tabid from ld_tab where name='TimeSheet';
delete from ld_appparenttabrel where tabid=@tabid;
select blockid into @blockid from ld_appparenttab where parenttab_label='Project';
insert into ld_appparenttabrel(blockid,tabid,sequence)
values(@blockid,@tabid,3);
select tabid into @tabid from ld_tab where name='PurchaseOrder';
delete from ld_appparenttabrel where tabid=@tabid;
select blockid into @blockid from ld_appparenttab where parenttab_label='Purchase';
insert into ld_appparenttabrel(blockid,tabid,sequence)
values(@blockid,@tabid,4);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleaseselectatleaprofile','请至少选择一个角色！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Pleaseselectatleaprofile' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleaseselectatleaprofile','Please select at least one role!','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Pleaseselectatleaprofile' and labeltype = 'jspop');
delimiter;

update ld_option_showheader_label set columnname = 'have_invoicetotal' where optionshowtabheader_id = 2 and columnname = 'invoicetotal';
update ld_option_showtableheader set `columns` = '[{"modulename":"ServiceContracts","select_column":"href_columnname,due_date,total,have_invoicetotal,invoicedate,href_columnname,have_invoicetotal,cashbilldate"}]'
where 	module = 'Invoice' AND selectmodule = 'ServiceContracts';
update ld_option_showheader_label set columnname = 'have_invoicetotal' where optionshowtabheader_id = 3 and columnname = 'invoicetotal';
update ld_option_showtableheader set `columns` = '[{"modulename":"OutboundOrder","select_column":"href_columnname,outdate,total,have_invoicetotal,invoicedate,href_columnname,have_invoicetotal,cashbilldate"}]'
where 	module = 'Invoice' AND selectmodule = 'OutboundOrder';
delimiter;

select tabid into @tabid from ld_tab where name='PublicAnnouncement';
delete from ld_appparenttabrel where tabid=@tabid;
select blockid into @blockid from ld_appparenttab where parenttab_label='Others';
insert into ld_appparenttabrel(blockid,tabid,sequence)
values(@blockid,@tabid,2);
delimiter;
-- 2017-09-25

UPDATE ld_tab SET presence=1 WHERE `name`='Leads';
UPDATE ld_parenttab SET visible=5 WHERE parenttab_label='Promotion platform';

select tabid into @tabid from ld_tab where name='ServiceCharge';
update ld_relatedlists 
inner join ld_tab on ld_relatedlists.related_tabid=ld_tab.tabid
set wx_presence=ld_relatedlists.presence
where ld_tab.mobilepresence like '%weixin%' and ld_relatedlists.tabid=@tabid;
delimiter;

select max(sequence) into @sequence from ld_systems_deploy where roottype = 3;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,145,'单据分配时是否发送邮件通知负责人',@sequence+1,3,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 145);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',145,145,'单据分配时是否发送邮件通知负责人' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'zh' and tabid = 145 and Relateid = 145 and trantable = 'ld_systems_deploy');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',145,145,'When the document is allocated, does the mail notify the person in charge?' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'en' and tabid = 145 and Relateid = 145 and trantable = 'ld_systems_deploy');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Faq';
select max(fieldid) into @fieldid from ld_field;
select blockid into @block from ld_blocks where blocklabel = 'LBL_FAQ_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @block;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate)
select @tabid,@fieldid+1,'smcreatorid','yes','ld_faq',1,52,'creator','创建人',1,2,@sequence+1,@block,2,'V~O',3 from DUAL
where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'smcreatorid');
delimiter;

update ld_field_seq set id = (select max(sequence) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Faq';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'zh' and tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'en' and tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field');
delimiter;

call fieldprofile('ld_faq');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','manualcreationoftablesisnotsupported','，不支持手动创建表格','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'manualcreationoftablesisnotsupported' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','manualcreationoftablesisnotsupported',',manual creation of tables is not supported','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'manualcreationoftablesisnotsupported' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','wpsformatisnotsupported','，不支持wps格式','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'wpsformatisnotsupported' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','wpsformatisnotsupported',',wps format is not supported','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'wpsformatisnotsupported' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel = '请使用导出模板表格' where labelbol = 'PLEASEUSETHEEXPORTTEMPLATETABLE' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Please use the export template table' where labelbol = 'PLEASEUSETHEEXPORTTEMPLATETABLE' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

UPDATE ld_field SET defaultvalue=100 WHERE tabid=6 AND columnname='discount_rate' AND IFNULL(defaultvalue,0)=0
	AND EXISTS (SELECT 1 FROM ld_producttoolfield WHERE columnname='discount_percent' AND tabid=22 AND defaultvalue=0);

UPDATE ld_field SET defaultvalue=0 WHERE tabid=6 AND columnname='discount_rate' AND IFNULL(defaultvalue,0) IN (0,100)
	AND EXISTS (SELECT 1 FROM ld_producttoolfield WHERE columnname='discount_percent' AND tabid=22 AND defaultvalue=100);

    
DROP PROCEDURE IF EXISTS `update_cvcolumnlist_wx_20170927`;
delimiter ||
CREATE  PROCEDURE `update_cvcolumnlist_wx_20170927`(
)
begin

	declare tmp_module varchar(100) default '';
	declare cur1 cursor for SELECT DISTINCT modulename from ld_cvcolumnlist_wx WHERE rownumber=0 OR listnumber=0;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_module = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_module;
	while(tmp_module is not null) DO
		select min(rownumber) into @min_row from ld_cvcolumnlist_wx where modulename=tmp_module;
		select min(listnumber) into @min_col from ld_cvcolumnlist_wx where modulename=tmp_module;
		update ld_cvcolumnlist_wx set rownumber=rownumber+1 where modulename=tmp_module and @min_row=0;
		update ld_cvcolumnlist_wx set listnumber=listnumber+1 where modulename=tmp_module and @min_col=0;
		Fetch cur1 into tmp_module;
	end while;

	close cur1;

end ||
delimiter;

call update_cvcolumnlist_wx_20170927();
delimiter;

DROP PROCEDURE IF EXISTS `update_cvcolumnlist_wx_20170531`;
DROP PROCEDURE IF EXISTS `update_cvcolumnlist_wx_20170927`;
-- 2017-09-27

select tabid into @tabid from ld_tab where name='Stock';
select fieldid into @tfieldid from ld_field where tabid=@tabid and fieldname='vendor_id';
select fieldid into @efieldid from ld_field where tabid=@tabid and fieldname='assigned_user_id';
delete from ld_related_field where trigger_fieldid=@tfieldid and effect_fieldid=@efieldid;
delimiter;

update ld_desk set fieldlabel = '只统计已审批的' where labelbol = 'EXCOMMTOTAL' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Only statistics are approved for' where labelbol = 'EXCOMMTOTAL' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

UPDATE ld_wx_config SET switch='open',time_interval=120 WHERE `name`='remind_time';
-- 2017-09-28

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','coveragemethodwillupdate','覆盖方式，会更新系统原有的数据，请慎用！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'coveragemethodwillupdate' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','coveragemethodwillupdate','Coverage method will update the original data of the system, please be careful!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'coveragemethodwillupdate' and labeltype = 'fixedstr');
delimiter;

update ld_tranlabel set fieldlabel = '微信端外勤签到时是否显示客户' where tabid = 143 and Relateid = 143 and languagetype = 'zh' and trantable = 'ld_systems_deploy';
update ld_tranlabel set fieldlabel = 'Whether to display the customer of WeChat in the end' where tabid = 143 and Relateid = 143 and languagetype = 'en' and trantable = 'ld_systems_deploy';
update ld_systems_deploy set description = '微信端外勤签到时是否显示客户' where deploy_type = 143;
delimiter;


UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=143 AND NOT EXISTS (SELECT 1 FROM ld_singin); 

UPDATE ld_workremindset SET dailyreminddate='不提醒' WHERE NOT EXISTS (SELECT 1 FROM ld_workreport WHERE type=1);
UPDATE ld_workremindset SET weekreminddate='不提醒' WHERE NOT EXISTS (SELECT 1 FROM ld_workreport WHERE type=2);
UPDATE ld_workremindset SET monthreminddate='不提醒' WHERE NOT EXISTS (SELECT 1 FROM ld_workreport WHERE type=3);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ContactRecords';
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname in ('potentialid','salesorderid','troubleticketid','projectid','projecttaskid','product_id')
	AND NOT EXISTS (SELECT 1 FROM ld_contactrecords);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
insert into ld_automaticreminds(tabid,`name`,columnname,remindnum,remindway,reminder,remindcontent,`status`,smcreatorid,createdtime,remindmethod)
select @tabid,'最晚服务到期日前30天邮件提醒客户','ld_account:lastservicedate:lastservicedate:ServiceCharge_fieldlabel',1,2,'Accounts','<p>您的服务还有30天即将已经到期，请联系您的服务人员：[var.account_servicecasher_ServiceCharge]</p>',2,1,now(),1 from DUAL
where not exists(select 1 from ld_automaticreminds where tabid = @tabid and `name` = '最晚服务到期日前30天邮件提醒客户');
select id into @id from ld_automaticreminds where tabid = @tabid and `name` = '最晚服务到期日前30天邮件提醒客户';
insert into ld_remindway(wayid,remindsday,sequence)
select @id,'-30',1 from DUAL
where not exists(select 1 from ld_remindway where wayid = @id);
insert into ld_remindcvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@id,'',0 from DUAL
where not exists(select 1 from ld_remindcvadvfilter_grouping where cvid = @id);
delimiter;

update ld_field set quickcreate = 3 where uitype = 1109;
delimiter;
-- 2017-09-29

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
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
delimiter;

update ld_version set old_version='V7.0.92',current_version='V7.0.92',remark='V7.0.9SP2-20170929',wx_version='V4';
delimiter;