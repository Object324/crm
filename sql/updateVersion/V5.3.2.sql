drop procedure if exists `fieldprofile`;
delimiter ||
create procedure fieldprofile
(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  LD_field where tabid in(select tabid from lD_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into LD_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from LD_def_org_field where fieldid=',ffieldid,')');
	
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

drop procedure  if exists `addtabintoprofile`;
delimiter ||
create procedure addtabintoprofile
(
tabname varchar(50),
permissions int(19)

)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  LD_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from LD_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;
	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
	set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
			  set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
		 set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'Documents',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='Documents');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select '',37,'创建合同时是否自动更新客户状态' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=37);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select '',38,'创建合同时是否自动更新销售机会阶段' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=38);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WHETHER','是否','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WHETHER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WHETHER','Whether','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WHETHER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHANGE','更改','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CHANGE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHANGE','Change','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHANGE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CREATEREPORTGENERATION','生成报表','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CREATEREPORTGENERATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CREATEREPORTGENERATION','Report generation','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CREATEREPORTGENERATION' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TIP','使用说明','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TIP' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TIP','TIP','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TIP' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DE','的','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DE','’s','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DE' and Labeltype='fixedstr');
delimiter;

SELECT usereportid into@id FROM ld_usereport WHERE name='Performancestatisticscollection';
UPDATE ld_usereportcolumns SET sequence=3 
WHERE columns='LD_account:accountname:accountname:Accounts_accountname:V' and Usereportid=@id;
delimiter;

SELECT usereportid into@id FROM ld_usereport where name='Contractamount';
UPDATE ld_usereportcolumns SET columns='LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:V',
realcolumns='LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:V',
realencolumns='LD_salesorder:ordernum:ordernum:SalesOrder_Rank:V' 
WHERE Usereportid=@id AND columns='LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N';
delimiter;

SELECT usereportid into@id FROM ld_usereport where name='CommencementSchedule';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:NN',
realcolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN',
realencolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:N';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN',
realcolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN',
realencolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:N';
delimiter;

SELECT usereportid into@id FROM ld_usereport where name='OverallCommencementSchedule';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN',
realcolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN',
realencolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:N';
delimiter;

SELECT usereportid into@id FROM ld_usereport where name='PartnerCommencementSchedule';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:NN',
realcolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN',
realencolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:N';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN',
realcolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN',
realencolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:N';
delimiter;

SELECT usereportid into@id FROM ld_usereport where name='LecturerCommencementSchedule';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:NN',
realcolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN',
realencolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:N';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN',
realcolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN',
realencolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:N';
delimiter;

SELECT usereportid into@id FROM ld_usereport where name='Contactbusinesstable';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:NN',
realcolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN',
realencolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:N';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN',
realcolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN',
realencolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:N';

UPDATE ld_usereportcolumns SET columns='LD_salesorder:CashBillBalance:CashBillBalance:salesorder_CashBillBalance:NN',
realcolumns='LD_salesorder:CashBillBalance:CashBillBalance:salesorder_已收款项:NN',
realencolumns='LD_salesorder:CashBillBalance:CashBillBalance:salesorder_已收款项:NN' 
WHERE Usereportid=@id AND columns='LD_salesorder:CashBillBalance:CashBillBalance:salesorder_CashBillBalance:N';

UPDATE ld_usereportcolumns SET columns='ld_expense:total:total:expense_total:NN',
realcolumns='ld_expense:total:total:expense_佣金:NN',
realencolumns='ld_expense:total:total:expense_佣金:NN' 
WHERE Usereportid=@id AND columns='ld_expense:total:total:expense_total:N';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_commission` (
  `commission_id` int(19) NOT NULL auto_increment,
  `commission_no` varchar(25) default NULL,
  `accountid` int(19) default NULL,
  `expensedate` date default NULL,
  `potentialid` int(19) default NULL,
  `bankaccountsetid` int(19) default NULL,
  `commissiontype` varchar(25) default NULL,
  `subtotal` decimal(25,2) default NULL,
  `total` decimal(25,2) default NULL,
  `noamount` decimal(25,2) default NULL,
  `approvestatus` varchar(200) default '未提交',
  `approveby` int(1) default NULL,
  PRIMARY KEY  (`commission_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1946 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_commission2payment` (
  `commission_id` int(19) default NULL,
  `salesorderid` int(19) default NULL,
  `remark` varchar(200) default NULL,
  `rate` decimal(25,2) default '0.00',
  `amount` decimal(25,2) default '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_commissionscf` (
  `commission_id` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_commissiontype` (
  `commissiontypeid` int(19) NOT NULL auto_increment,
  `commissiontype` varchar(100) default NULL,
  `presence` int(11) default NULL,
  `picklist_valueid` int(11) default NULL,
  PRIMARY KEY  (`commissiontypeid`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_commissiontype_seq` (
  `id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

select max(tabid)+1 into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
select ifnull(id,0) into @id from ld_version where versiontype = 2;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'Commission',case when @id=0 then 1 else 0 end,@tabsequence+1,'Commission',1,'Finacial',0 
from dual where not EXISTS(select 1 from ld_tab  where tablabel ='Commission');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Finacial';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Expense';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'佣金单' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='佣金单');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'Commission' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='Commission');

insert into ld_ws_entity(name,handler_path,handler_class,ismodule)
select 'Commission','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 
from dual where not EXISTS(select 1 from ld_ws_entity  where name = 'Commission' );
delimiter;

call fieldprofile('Commission');
call getallprofile('Commission');
call addtabintoprofile('Commission',0);
select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;
update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_COMMISSION_INFO',1 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_COMMISSION_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_COMMISSION_DESCRIPTION',2 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_COMMISSION_DESCRIPTION' and sequence = 2);
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_COMMISSION_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='基本信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Reminds Content' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Reminds Content');

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_COMMISSION_DESCRIPTION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'描述信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='描述信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Basic Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Basic Information');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'expensedate','LD_commission',5,'expensedate','报销日期',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),1,0,'D~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'expensedate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'commission_no','LD_commission',4,'commission_no','佣金单编号',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),1,0,'V~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'commission_no');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'accountid','LD_commission',73,'account_id','客户名称',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),1,0,'V~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'accountid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'potentialid','LD_commission',76,'potential_id','销售机会',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),1,0,'V~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'potentialid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'','',200,'','源单',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),1,0,'V~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = '' and uitype = 200);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'bankaccountsetid','LD_commission',251,'bankaccountsetid','账户',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'bankaccountsetid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'commissiontype','LD_commission',15,'commissiontype','佣金类别',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'commissiontype');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','LD_crmentity',53,'assigned_user_id','报销人',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'total','LD_commission',222,'hdnGrandTotal','Total',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),3,0,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'total');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'subtotal','LD_commission',222,'hdnSubTotall','Sub Total',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),3,0,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'subtotal');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'noamount','LD_commission',222,'noamount','noamount',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),3,0,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'noamount');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','LD_crmentity',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),2,0,'DT~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','LD_crmentity',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),2,0,'DT~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','LD_crmentity',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),2,0,'V~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);

select tabid into @tabid from ld_tab where `name` = 'Commission';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'expensedate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'报销日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='报销日期');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Reimbursement Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Reimbursement Date');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'commission_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'佣金单编号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='佣金单编号');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Commission No' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Commission No');

select fieldid into @fieldid from ld_field where tabid = @tabid and uitype = 200;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Data sources' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid and fieldlabel='Data sources');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'account_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'客户名称' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='客户名称');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Account Name' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Account Name');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'potential_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'销售机会' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='销售机会');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Potential Name' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Potential Name');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'bankaccountsetid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'账户' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='账户');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Account' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Account');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'commissiontype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'佣金类别' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='佣金类别');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Commission Type' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Commission Type');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'报销人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='报销人');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Holder' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Holder');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnGrandTotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'合计' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='合计');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Total' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Total');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnSubTotall';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'小计' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='小计');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Sub Total' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Sub Total');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'修改时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='修改时间');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Mody' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Amount');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='创建时间');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Create Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Create Time');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='创建人');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Creator' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Creator');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'调整金额' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='调整金额');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modified Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Modified Time');

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'Commission','Com',1,2,1,'none' 
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'Commission' 
and prefix ='Com');
update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);

select max(id) into @id from ld_picklistvalues_seq;
insert into LD_commissiontype(commissiontype,presence,picklist_valueid)
select '合作费',1,@id+1 
from dual where not EXISTS(select 1 from LD_commissiontype  where commissiontype = '合作费');
update ld_picklistvalues_seq set id = @id +1;
select max(id) into @id from ld_picklistvalues_seq;
insert into LD_commissiontype(commissiontype,presence,picklist_valueid)
select '礼品费',1,@id+1 
from dual where not EXISTS(select 1 from LD_commissiontype  where commissiontype = '礼品费');
update ld_picklistvalues_seq set id = @id +1;
select max(id) into @id from ld_picklistvalues_seq;
insert into LD_commissiontype(commissiontype,presence,picklist_valueid)
select '佣金',1,@id+1 
from dual where not EXISTS(select 1 from LD_commissiontype  where commissiontype = '佣金');
update ld_picklistvalues_seq set id = @id +1;
update LD_commissiontype_seq set id = (select max(commissiontypeid) from LD_commissiontype);

SELECT tabid into @tabid FROM ld_tab where name='Commission';
SELECT blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_COMMISSION_INFO';
select id into @id from ld_field_seq;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approvestatus','LD_commission',1,130,'approvestatus','Approvestatus',1,2,'',100,19,@blockid,2,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='LD_commission' and fieldname='approvestatus');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);
delimiter;
SELECT tabid into @tabid FROM ld_tab where name='Commission';
SELECT blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_COMMISSION_INFO';
select id into @id from ld_field_seq;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approveby','LD_commission',1,131,'approveby','Approveby',1,2,'',100,19,@blockid,2,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='LD_commission' and fieldname='approveby');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);
delimiter;
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'Approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'审批状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='审批状态');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Approve Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Approve Status');
delimiter;
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'Approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='审批人');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Approver');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,36,'佣金单是否启用审批流程。1:否，0:是','Commission' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=36);
delimiter;

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'All',1,'Commission',0,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All' 
and entitytype ='Commission');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'Commission' and viewname = 'All';

delete from ld_cvcolumnlist where cvid =  @cvid and columnindex = 1;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_commission:commission_no:commission_no:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:commission_no:commission_no:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_commission:expensedate:expensedate:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:expensedate:expensedate:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_commission:accountid:account_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:accountid:account_id:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_commission:total:total:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:total:total:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V');

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'已批准',0,'Commission',1,1,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '已批准' 
and entitytype ='Commission');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'Commission' and viewname = '已批准';

delete from ld_cvcolumnlist where cvid =  @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_commission:commission_no:commission_no:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:commission_no:commission_no:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_commission:expensedate:expensedate:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:expensedate:expensedate:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_commission:accountid:account_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:accountid:account_id:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_commission:total:total:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:total:total:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V');

delete from ld_cvadvfilter where cvid =  @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid)
select @cvid,0,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V','e','已批准',1 
from dual where not EXISTS(select 1 from ld_cvadvfilter  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' and value = '已批准');

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',' 0 ' from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid = @cvid 
and groupid = 1);

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'审批中',0,'Commission',1,1,2,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '审批中' 
and entitytype ='Commission');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'Commission' and viewname = '审批中';

delete from ld_cvcolumnlist where cvid =  @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_commission:commission_no:commission_no:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:commission_no:commission_no:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_commission:expensedate:expensedate:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:expensedate:expensedate:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_commission:accountid:account_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:accountid:account_id:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_commission:total:total:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:total:total:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V');

delete from ld_cvadvfilter where cvid =  @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid)
select @cvid,0,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V','e','审批中',1 
from dual where not EXISTS(select 1 from ld_cvadvfilter  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' and value = '审批中');

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',' 0 ' from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid = @cvid 
and groupid = 1);

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'已驳回',0,'Commission',1,1,3,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '已驳回' 
and entitytype ='Commission');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Commission' and viewname = '已驳回';
delete from ld_cvcolumnlist where cvid =  @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_commission:commission_no:commission_no:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:commission_no:commission_no:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_commission:expensedate:expensedate:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:expensedate:expensedate:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_commission:accountid:account_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:accountid:account_id:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_commission:total:total:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:total:total:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V');

delete from ld_cvadvfilter where cvid =  @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid)
select @cvid,0,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V','e','已驳回',1 
from dual where not EXISTS(select 1 from ld_cvadvfilter  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' and value = '已驳回');
select cvid into @cvid from ld_customview where entitytype = 'Commission' and viewname = '已驳回';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',' 0 ' from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid = @cvid 
and groupid = 1);

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'未提交',0,'Commission',1,1,4,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '未提交' 
and entitytype ='Commission');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Commission' and viewname = '未提交';
delete from ld_cvcolumnlist where cvid =  @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_commission:commission_no:commission_no:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:commission_no:commission_no:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_commission:expensedate:expensedate:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:expensedate:expensedate:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_commission:accountid:account_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:accountid:account_id:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_commission:total:total:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:total:total:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V');

delete from ld_cvadvfilter where cvid =  @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid)
select @cvid,0,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V','e','未提交',1 
from dual where not EXISTS(select 1 from ld_cvadvfilter  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' and value = '未提交');

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',' 0 ' from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid = @cvid 
and groupid = 1);

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'已拒绝',0,'Commission',1,1,5,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '已拒绝' 
and entitytype ='Commission');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'Commission' and viewname = '已拒绝';
delete from ld_cvcolumnlist where cvid =  @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_commission:commission_no:commission_no:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:commission_no:commission_no:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_commission:expensedate:expensedate:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:expensedate:expensedate:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_commission:accountid:account_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:accountid:account_id:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_commission:total:total:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_commission:total:total:Commission_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_crmentity:smownerid:assigned_user_id:Commission_fieldlabel:V');

delete from ld_cvadvfilter where cvid =  @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid)
select @cvid,0,'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V','e','已拒绝',1 
from dual where not EXISTS(select 1 from ld_cvadvfilter  where cvid = @cvid 
and columnname = 'LD_commission:approvestatus:approvestatus:Commission_fieldlabel:V' and value = '已拒绝');

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',' 0 ' from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid = @cvid 
and groupid = 1);

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'Commission','LD_commission','commission_no','commission_id','commission_id'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid 
and modulename ='Commission');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid 
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

update ld_tab set printtab = 1 where `name` = 'Commission';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid 
and visible =1);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMMISSIONINFO','佣金单信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMMISSIONINFO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMMISSIONINFO','Commission Info','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMISSIONINFO' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SPAYMENT','收款方式','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SPAYMENT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SPAYMENT','Payment','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SPAYMENT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMMISSION','佣金','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMMISSION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMMISSION','Commission','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMISSION' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PROPORTTION','比例','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PROPORTTION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PROPORTTION','Proportion','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PROPORTTION' and Labeltype='fixedstr');
delimiter;

ALTER TABLE LD_commission2payment MODIFY COLUMN rate decimal(25,2) default 0.00;
ALTER TABLE LD_commission2payment MODIFY COLUMN amount decimal(25,2) default 0.00;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @commission_tabid from ld_tab where name = 'Commission';
select sequence into @sequence from ld_relatedlists where tabid =@tabid and label = 'Expense';
select id into @id from ld_relatedlists_seq;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@commission_tabid,'get_commission',@sequence,'Commission','add' from dual 
where not EXISTS(select 1 from ld_relatedlists  where tabid=@tabid and related_tabid=@commission_tabid);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @commission_tabid from ld_tab where name = 'Commission';
select sequence into @sequence from ld_relatedlists where tabid =@tabid and label = 'Expense';
select id into @id from ld_relatedlists_seq;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@commission_tabid,'get_commission',@sequence+1,'Commission','add' from dual 
where not EXISTS(select 1 from ld_relatedlists  where tabid=@tabid and related_tabid=@commission_tabid);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);

select usereportid into @usereportid from ld_usereport where name = 'SalesOrderTrack';
insert into ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'LD_commission2payment:amount:amount:OftenUseReport_Amount:NN',14,1,'LD_commission2payment:amount:amount:OftenUseReport_佣金金额:NN','LD_commission2payment:amount:amount:OftenUseReport_Amount:NN'
from dual where not EXISTS(select 1 from ld_usereportcolumns  where Usereportid = @usereportid and columns ='LD_commission2payment:amount:amount:OftenUseReport_Amount:NN');
delimiter;

select usereportid into @usereportid from ld_usereport where name = 'Performancestatisticscollection';
insert into ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_CommissionTotal:NN',11,1,'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_佣金合计:NN','LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_Commission Total:NN'
from dual where not EXISTS(select 1 from ld_usereportcolumns  where Usereportid = @usereportid and columns ='LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_佣金合计:NN');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Contacts';
UPDATE ld_field SET displaytype = 1 WHERE tabid = @tabid AND uitype = 55 AND fieldname = 'salutationtype' AND displaytype != 1;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'VendorContact';
UPDATE ld_field SET displaytype = 1 WHERE tabid = @tabid AND uitype = 55 AND fieldname = 'salutationtype' AND displaytype != 1;
-- END 2014-06-17 by luyx

select tabid into @tabid from ld_tab where name='ServiceContracts';
select ifnull(max(blockid),0) into @blockid from ld_blocks;
select ifnull(max(sequence),0) into @seq from ld_blocks where tabid=@tabid;
select 'LBL_DESCRIPTION_INFORMATION' into @blocklabel;
select '备注信息' into @zh;
select 'Description' into @en;

insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @blockid+1,@tabid,@blocklabel,@seq+1,0,0,0,0,0,1,0 from dual 
where not exists (select 1 from ld_blocks where tabid=@tabid and blocklabel=@blocklabel);

update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_blocks set visible=0 where tabid=@tabid and blocklabel=@blocklabel;

select blockid into @relateid from ld_blocks where tabid=@tabid and blocklabel=@blocklabel;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_blocks',@tabid,@relateid,@zh from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@relateid and trantable='LD_blocks');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_blocks',@tabid,@relateid,@en from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@relateid and trantable='LD_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='ServiceContracts';
select ifnull(max(fieldid),0) into @maxid from ld_field;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
select ifnull(max(sequence),0) into @seq from ld_field where tabid=@tabid and block=@blockid;
select 'description' into @columnname;
select 'Description' into @en;
select '备注' into @zh;
select 'LD_crmentity' into @tablename;
select 19 into @uitype;

update ld_blocks set visible=0 where blockid=@blockid and tabid=@tabid;

insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@columnname,@zh,0,2,'',100,@seq+1,@blockid,1,'V~O',1,null,'BAS',1,NULL,0  
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname=@columnname);

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_field set presence=2 where tabid=@tabid and columnname=@columnname;

select fieldid into @relateid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_field',@tabid,@relateid,@zh from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@relateid and trantable='LD_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_field',@tabid,@relateid,@en from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@relateid and trantable='LD_field');

call fieldprofile(@tablename);
call getallprofile(@tablename);
delimiter;

select tabid into @tabid from ld_tab where name='ServiceContracts';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_CUSTOM_INFORMATION';
select ifnull(max(sequence),0) into @seq from ld_blocks where tabid=@tabid;
update ld_blocks set sequence=@seq+1 where tabid=@tabid and blockid=@blockid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TIMES_SYS','时','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TIMES_SYS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TIMES_SYS','times','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TIMES_SYS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AS_SYS','为','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AS_SYS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AS_SYS','as','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AS_SYS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOTUPDATEISEMPTY','（为空表示不更新）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NOTUPDATEISEMPTY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NOTUPDATEISEMPTY','(not update is empty)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NOTUPDATEISEMPTY' and Labeltype='fixedstr');
delimiter;

SELECT usereportid into @id FROM ld_usereport WHERE name='Customersparticipatinginthetrainingschedule';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_accountSalesOrder:accountname:account_id:salesorder_accountid:I','',5  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=5);
delimiter;
select usereportid into @id from LD_usereport where name='Customersparticipatinginthetrainingschedule';
SELECT tabid into @tid from LD_tab where name='SalesOrder';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:subject:subject:salesorder_salesorder_subject:V', 7, 1, 'LD_salesorder:subject:subject:salesorder_合同主题:V','LD_salesorder:subject:subject:salesorder_合同主题:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:subject:subject:salesorder_合同主题:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_no:salesorder_no:salesorder_salesorder_no:V', 8, 1, 'LD_salesorder:salesorder_no:salesorder_no:salesorder_合同编号:V','LD_salesorder:salesorder_no:salesorder_no:salesorder_合同编号:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesorder_no:salesorder_no:salesorder_合同编号:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:N', 9, 1, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_合同总计:N','LD_salesorder:salesordertotal:salesordertotal:salesorder_合同总计:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同总计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_expense:total:total:expense_total:N', 10, 1, 'ld_expense:total:total:expense_佣金:N','LD_salesorder:total:total:expense_佣金:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='ld_expense:total:total:expense_佣金:N');
delimiter;

update ld_tranlabel set fieldlabel = '基本信息' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Accounts') 
and Relateid in (select blockid from ld_blocks where blocklabel= 'LBL_ACCOUNT_INFORMATION' and tabid in (select tabid from ld_tab where name = 'Accounts') );
delimiter;

update ld_desk set Fieldlabel='{$SalesOrder.SalesOrder}、{$Quotes.Quotes}、{$Invoice.Invoice}、{$Stock.Stock}、{$OutboundOrder.OutboundOrder}、{$PurchaseOrder.PurchaseOrder}上是否显示成本和期望GP（毛利率%）' where labelbol='PRODUCTSETLABEL';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CONFIRME','确认','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CONFIRME' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CONFIRME','Confirme','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CONFIRME' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EXCOMMTOTAL','费用报销单、佣金单统计范围','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='EXCOMMTOTAL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EXCOMMTOTAL','The Expense、Commission statistics scope of','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EXCOMMTOTAL' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','STSTISTICS','统计','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='STSTISTICS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','STSTISTICS','Statistics','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='STSTISTICS' and Labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel = '评论' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'HelpDesk') 
and Relateid in (select blockid from ld_blocks where blocklabel= 'LBL_COMMENTS' and tabid in (select tabid from ld_tab where name = 'HelpDesk') );
update ld_tranlabel set fieldlabel = 'Comments' where languagetype = 'en' and tabid in (select tabid from ld_tab where name = 'HelpDesk') 
and Relateid in (select blockid from ld_blocks where blocklabel= 'LBL_COMMENTS' and tabid in (select tabid from ld_tab where name = 'HelpDesk') );
delimiter;

update ld_desk set Fieldlabel='设置系统模块的开启或关闭' where labelbol='VTLIB_LBL_MODULE_MANAGER_DESCRIPTION' and languagetype='zh';
delimiter;

update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='Accounts');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='ContactRecords');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='HelpDesk');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='Calendar');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='Documents');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='Potentials');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='Quotes');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='SalesOrder');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='PurchaseOrder');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='Project');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='ProjectTask');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='Invoice');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='CashDeposit');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='PutCash');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='Expense');
update ld_field set presence = 0,displaytype=3 where columnname = 'approvestatus' and tabid in (SELECT tabid from ld_tab where name='Commission');

update ld_relatedlists set sequence=sequence+1 where tabid=6;
update ld_relatedlists set sequence=0 where tabid=6 and name='get_balanceofaccount';
SELECT @i:=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=6 order by sequence; 
delimiter;

update ld_systems_deploy set deploy_value=1,description='订单、报价单、发票、出入库单上是否显示成本和期望GP(毛利率%) 0:显示，1:不显示' where deploy_type=34;
-- End by luyx 2014-06-18

-- Begin: 2014-06-19 by luyx 
update ld_desk set Fieldlabel='选择Email模板' where labelbol='SELECTEMAILTEMPLATE' and languagetype='zh';

select tabid into @tabid1 from ld_tab where name like 'Expense';
select tabid into @tabid2 from ld_tab where name like 'Commission';
select tabid into @tabid3 from ld_tab where name like 'BankAccountSet';
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Finacial';
select ifnull(sequence,0) into @seq from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid1;
update ld_parenttabrel set sequence=sequence+2 where parenttabid=@parenttabid and sequence>@seq;
update ld_parenttabrel set sequence=@seq+1 where  parenttabid=@parenttabid and tabid=@tabid2;
select ifnull(max(sequence),0) into @seq1 from ld_parenttabrel where parenttabid=@parenttabid;
update ld_parenttabrel set sequence=@seq1+1 where  parenttabid=@parenttabid and tabid=@tabid3;
SELECT @i:=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=@parenttabid order by sequence; 
delimiter;

update ld_usereport set reporttype=3 where name='PartnerCommencementSchedule';
update ld_usereport set reporttype=3 where name='LecturerCommencementSchedule';
update ld_usereport set reporttype=3 where name='KPCCommencementDetails';
update ld_usereport set reporttype=4 where name='CommencementSchedule';
delimiter;

select usereportid into @id from LD_usereport where name='SalesOrderTrack';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id;
delimiter;

select usereportid into @id from LD_usereport where name='SalesOrderTrack';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V', 1, 1, 'LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V','LD_crmentity:smownerid:assigned_user_id:SalesOrder_Assigned To:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D', 2, 1, 'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D','LD_salesorder:signed_data:signed_data:SalesOrder_Date of Contract:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V', 3, 1, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_订单编号:V','LD_salesorder:salesorder_no:salesorder_no:SalesOrder_sales order no:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_订单编号:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:createdtime:createdtime:SalesOrder_CreatedTime:DT', 4, 1, 'LD_crmentity:createdtime:createdtime:SalesOrder_创建时间:DT','LD_crmentity:createdtime:createdtime:SalesOrder_Created Time:DT'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:createdtime:createdtime:SalesOrder_创建时间:DT');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:subject:subject:SalesOrder_Subject:V', 5, 1, 'LD_salesorder:subject:subject:SalesOrder_主题:V','LD_salesorder:subject:subject:SalesOrder_Order Subject:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:subject:subject:SalesOrder_主题:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_accountSalesOrder:accountid:account_id:SalesOrder_Account_Name:I', 6, 1, 'LD_accountSalesOrder:accountid:account_id:SalesOrder_客户:I','LD_accountSalesOrder:accountid:account_id:SalesOrder_Account Name:I'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_accountSalesOrder:accountid:account_id:SalesOrder_客户:I');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:sostatus:sostatus:SalesOrder_sostatus:V', 7, 1, 'LD_salesorder:sostatus:sostatus:SalesOrder_状态:V','LD_salesorder:sostatus:sostatus:SalesOrder_order status:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:sostatus:sostatus:SalesOrder_状态:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:duedate:duedate:SalesOrder_duedate:D', 8, 1, 'LD_salesorder:duedate:duedate:SalesOrder_交付日期:D','LD_salesorder:duedate:duedate:SalesOrder_due date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:duedate:duedate:SalesOrder_交付日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N', 9, 1, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_合同订单合计:N','LD_salesorder:total:hdnGrandTotal:SalesOrder_Order Total:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:total:hdnGrandTotal:SalesOrder_合同订单合计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_invoice:total:hdnGrandTotal:Invoice_Total:N', 10, 1, 'LD_invoice:total:hdnGrandTotal:Invoice_销售发票合计:N','LD_invoice:total:hdnGrandTotal:Invoice_Invoice Total:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_invoice:total:hdnGrandTotal:Invoice_销售发票合计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_InvoiceBalance:N', 11, 1, 'LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_开票余额:N','LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_Invoice Balance:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_开票余额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:Expenseamount:费用金额:OftenUseReport_Expenseamount:N', 12, 1, 'LD_reporttable:Expenseamount:费用金额:OftenUseReport_费用金额:N','LD_reporttable:Expenseamount:费用金额:OftenUseReport_Expense amount:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:Expenseamount:费用金额:OftenUseReport_费用金额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_commission2payment:amount:amount:OftenUseReport_Amount:NN', 13, 1, 'LD_commission2payment:amount:amount:OftenUseReport_佣金金额:NN','LD_commission2payment:amount:amount:OftenUseReport_Commission total:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_commission2payment:amount:amount:OftenUseReport_佣金金额:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N', 14, 1, 'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_已收款金额:N','LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBill amount:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:CashBillamount:已收款金额:OftenUseReport_已收款金额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N', 15, 1, 'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_应收款余额:N','LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_Payment Balance:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_应收款余额:N');
delimiter;

select usereportid into @id from LD_usereport where name='CashBillSum_Paymentplan';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id;
delimiter;

select usereportid into @id from LD_usereport where name='CashBillSum_Paymentplan';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_paymentplan:smownerid:assigned_user_id:PaymentPlan_assigned_user_id:V', 1, 1, 'LD_paymentplan:smownerid:assigned_user_id:PaymentPlan_销售负责人:V','LD_paymentplan:smownerid:assigned_user_id:PaymentPlan_assigned to:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_paymentplan:smownerid:assigned_user_id:PaymentPlan_销售负责人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_paymentplan:accountid:account_id:PaymentPlan_Account_Name:V', 2, 1, 'LD_paymentplan:accountid:account_id:PaymentPlan_客户名称:V','LD_paymentplan:accountid:account_id:PaymentPlan_Account Name:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_paymentplan:accountid:account_id:PaymentPlan_客户名称:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D', 3, 1, 'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D','LD_salesorder:signed_data:signed_data:SalesOrder_Date of Contract:D' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_salesorder:I', 4, 1, 'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_合同主题:I','LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_sales order:I' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_合同主题:I');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V', 5, 1, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_合同订单编号:V','LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder no:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N', 6, 1, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_合同订单合计:N','LD_salesorder:total:hdnGrandTotal:SalesOrder_Order Total:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:total:hdnGrandTotal:SalesOrder_合同订单合计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D', 7, 1, 'LD_paymentplan:plandate:plandate:PaymentPlan_计划回款日期:D','LD_paymentplan:plandate:plandate:PaymentPlan_PaymentPlan Date :D' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_paymentplan:plandate:plandate:PaymentPlan_计划回款日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_paymentplan_no:I', 8, 1, 'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_回款单编号:I','LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_paymentplan no:I' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_回款单编号:I');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_paymentplan:periodtime:periodtime:PaymentPlan_periodtime:V', 9, 1, 'LD_paymentplan:periodtime:periodtime:PaymentPlan_期次:V','LD_paymentplan:periodtime:periodtime:PaymentPlan_Stages:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_paymentplan:periodtime:periodtime:PaymentPlan_期次:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_paymentplan:amount:amount:PaymentPlan_amount:N', 10, 1, 'LD_paymentplan:amount:amount:PaymentPlan_回款计划金额:N','LD_paymentplan:amount:amount:PaymentPlan_PaymentPlan amount:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_paymentplan:amount:amount:PaymentPlan_回款计划金额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_paymentplan:actualamount:actualamount:PaymentPlan_actualamount:V', 11, 1, 'LD_paymentplan:actualamount:actualamount:PaymentPlan_回款计划已收金额:V','LD_paymentplan:actualamount:actualamount:PaymentPlan_plan amount received:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_paymentplan:actualamount:actualamount:PaymentPlan_回款计划已收金额:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V', 12, 1, 'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_回款计划状态:V','LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_payment status:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_回款计划状态:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N', 13, 1, 'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_应收款余额:N','LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_Payment Balance:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_应收款余额:N');
delimiter;

select usereportid into @id from LD_usereport where name='CashBillSum_SalesOrder';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id;
delimiter;

select usereportid into @id from LD_usereport where name='CashBillSum_SalesOrder';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_usersSalesOrder:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V', 1, 1, 'LD_usersSalesOrder:smownerid:assigned_user_id:SalesOrder_销售负责人:V','LD_usersSalesOrder:smownerid:assigned_user_id:SalesOrder_assigned to:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_usersSalesOrder:smownerid:assigned_user_id:SalesOrder_销售负责人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_SalesOrder No:V', 2, 1, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_合同订单编号:V','LD_salesorder:salesorder_no:salesorder_no:SalesOrder_Sales Order No:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_合同订单编号:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D', 3, 1, 'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D','LD_salesorder:signed_data:signed_data:SalesOrder_Date of Contract:D' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:createdtime:createdtime:SalesOrder_Created Time:DT', 4, 0, 'LD_crmentity:createdtime:createdtime:SalesOrder_创建时间:DT','LD_crmentity:createdtime:createdtime:SalesOrder_CreatedTime:DT' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:createdtime:createdtime:SalesOrder_创建时间:DT');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:subject:subject:SalesOrder_Subject:V', 5, 1, 'LD_salesorder:subject:subject:SalesOrder_合同订单_主题:V','LD_salesorder:subject:subject:SalesOrder_Order Subject:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:subject:subject:SalesOrder_合同订单_主题:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:accountid:account_id:SalesOrder_Account Name:I', 6, 1, 'LD_salesorder:accountid:account_id:SalesOrder_合同订单_客户名称:I','LD_salesorder:accountid:account_id:SalesOrder_AccountName:I' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:accountid:account_id:SalesOrder_合同订单_客户名称:I');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:sostatus:sostatus:SalesOrder_Status:V', 7, 1, 'LD_salesorder:sostatus:sostatus:SalesOrder_合同订单_订单状态:V','LD_salesorder:sostatus:sostatus:SalesOrder_order status:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:sostatus:sostatus:SalesOrder_合同订单_订单状态:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N', 8, 1, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_合同订单_合计:N','LD_salesorder:total:hdnGrandTotal:SalesOrder_order total:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:total:hdnGrandTotal:SalesOrder_合同订单_合计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N', 9, 1, 'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_已收金额:N','LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBill amount:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:CashBillamount:已收款金额:OftenUseReport_已收金额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N', 10, 1, 'LD_reporttable:PaymentBalance:应收款余额:OftenUseReport_应收款余额:N','LD_reporttable:PaymentBalance:应收款余额:OftenUseReport_Payment Balance:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:PaymentBalance:应收款余额:OftenUseReport_应收款余额:N');
delimiter;


select usereportid into @id from LD_usereport where name='PurchaseOrderTrack';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id;
delimiter;

select usereportid into @id from LD_usereport where name='PurchaseOrderTrack';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:duedate:duedate:PurchaseOrder_duedate:D', 1, 1, 'LD_purchaseorder:duedate:duedate:PurchaseOrder_采购订单_交付日期:D','LD_purchaseorder:duedate:duedate:PurchaseOrder_due date:D' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:duedate:duedate:PurchaseOrder_采购订单_交付日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:postatus:postatus:PurchaseOrder_postatus:V', 2, 1, 'LD_purchaseorder:postatus:postatus:PurchaseOrder_采购订单_订单状态:V','LD_purchaseorder:postatus:postatus:PurchaseOrder_Purchase Order status:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:postatus:postatus:PurchaseOrder_采购订单_订单状态:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:purchaseorder_No:purchaseorder_No:PurchaseOrder_purchaseorder_No:V', 3, 1, 'LD_purchaseorder:purchaseorder_No:purchaseorder_No:PurchaseOrder_采购订单-编号','LD_purchaseorder:purchaseorder_No:purchaseorder_No:PurchaseOrder_purchaseorder No' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:purchaseorder_No:purchaseorder_No:PurchaseOrder_采购订单-编号');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_purchaseorder_signed_data:D', 4, 1, 'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D','LD_purchaseorder:signed_data:signed_data:PurchaseOrder_Date of Contract:D' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V', 0, 1, 'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_采购订单_销售负责人:V','LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_assigned to:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_采购订单_销售负责人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_PurchaseOrder:total:hdnGrandTotal:PurchaseOrder_Total:N', 5, 1, 'LD_PurchaseOrder:total:hdnGrandTotal:PurchaseOrder_采购订单_合计:N','LD_PurchaseOrder:total:hdnGrandTotal:PurchaseOrder_PurchaseOrder Total:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_PurchaseOrder:total:hdnGrandTotal:PurchaseOrder_采购订单_合计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBillamount:N', 6, 1, 'LD_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_付款单金额:N','LD_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBill amount:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_付款单金额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_vendor:vendorname:vendorname:Vendors_vendorname:V', 7, 1, 'LD_vendor:vendorname:vendorname:Vendors_供应商:V','LD_vendor:vendorname:vendorname:Vendors_Vendor Name:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_vendor:vendorname:vendorname:Vendors_供应商:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V', 8, 1, 'LD_purchaseorder:subject:subject:PurchaseOrder_采购订单_主题:V','LD_purchaseorder:subject:subject:PurchaseOrder_PurchaseOrder Subject:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:subject:subject:PurchaseOrder_采购订单_主题:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:createdtime:createdtime:PurchaseOrder_CreatedTime:DT', 9, 1, 'LD_crmentity:createdtime:createdtime:PurchaseOrder_采购订单_创建时间:DT','LD_crmentity:createdtime:createdtime:PurchaseOrder_Created Time:DT' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:createdtime:createdtime:PurchaseOrder_采购订单_创建时间:DT');
delimiter;

select usereportid into @id from LD_usereport where name='SendCashBillSum_PurchaseOrder';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id;
delimiter;

select usereportid into @id from LD_usereport where name='SendCashBillSum_PurchaseOrder';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V', 1, 1, 'LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_销售负责人:V','LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_assigned to:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_销售负责人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V', 2, 1, 'LD_purchaseorder:subject:subject:PurchaseOrder_采购订单主题:V','LD_purchaseorder:subject:subject:PurchaseOrder_PurchaseOrder Subject:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:subject:subject:PurchaseOrder_采购订单主题:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:vendorid:vendorid:PurchaseOrder_vendorname:I', 3, 1, 'LD_purchaseorder:vendorid:vendorid:PurchaseOrder_供应商:I','LD_purchaseorder:vendorid:vendorid:PurchaseOrder_vendor name:I' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:vendorid:vendorid:PurchaseOrder_供应商:I');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:postatus:postatus:PurchaseOrder_Status:V', 4, 1, 'LD_purchaseorder:postatus:postatus:PurchaseOrder_采购订单状态:V','LD_purchaseorder:postatus:postatus:PurchaseOrder_PurchaseOrder Status:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:postatus:postatus:PurchaseOrder_采购订单状态:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N', 5, 1, 'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_采购订单合计:N','LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_PurchaseOrder Total:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_采购订单合计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:CashBillamount:SendCashBillamount:oftenusereport_SendCashBillamount:N', 6, 1, 'ld_sendcashbill:SendCashBillamount:SendCashBillamount:oftenusereport_已付款金额:N','ld_sendcashbill:SendCashBillamount:SendCashBillamount:oftenusereport_SendCashBill amount:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='ld_sendcashbill:SendCashBillamount:SendCashBillamount:oftenusereport_已付款金额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_sendcashbill:PaymentBalance:SendCashBillBalance:OftenUseReport_PaymentBalance:N', 7, 1, 'ld_sendcashbill:SendCashBillBalance:SendCashBillBalance:oftenusereport_应付款余额:N','ld_sendcashbill:SendCashBillBalance:SendCashBillBalance:oftenusereport_SendCashBill Balance:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='ld_sendcashbill:SendCashBillBalance:SendCashBillBalance:oftenusereport_应付款余额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder No:V', 8, 1, 'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V','LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_Purchase Order No:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder No:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:createdtime:createdtime:PurchaseOrder_Created Time:DT', 9, 1, 'LD_crmentity:createdtime:createdtime:PurchaseOrder_创建时间:DT','LD_crmentity:createdtime:createdtime:PurchaseOrder_CreatedTime:DT' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:createdtime:createdtime:PurchaseOrder_创建时间:DT');
delimiter;


select usereportid into @id from LD_usereport where name='SendCashBillSum_SendPayment';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id;
delimiter;

select usereportid into @id from LD_usereport where name='SendCashBillSum_SendPayment';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_purchaseorder_signed_data:D', 1, 1, 'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D','LD_purchaseorder:signed_data:signed_data:PurchaseOrder_Date of Contract:D' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_purchaseorder_no:V', 2, 1, 'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V','LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_purchaseorder no:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:smownerid:smownerid:SendPayment_smownerid:V', 0, 1, 'LD_crmentity:smownerid:smownerid:SendPayment_采购订单销售负责人:V','LD_crmentity:smownerid:smownerid:SendPayment_Assigned To:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:smownerid:smownerid:SendPayment_采购订单销售负责人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_vendor:vendorid:vendorid:SendPayment_vendorid:V', 4, 1, 'LD_vendor:vendorid:vendorid:SendPayment_采购订单_供应商:V','LD_vendor:vendorid:vendorid:SendPayment_vendor name:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_vendor:vendorid:vendorid:SendPayment_采购订单_供应商:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N', 5, 1, 'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_采购订单_合计:N:V','LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_PurchaseOrder_Total:N:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_采购订单_合计:N:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_sendpayment:plandate:plandate:SendPayment_plandate:D', 6, 1, 'LD_sendpayment:plandate:plandate:SendPayment_计划付款日期:D','LD_sendpayment:plandate:plandate:SendPayment_PaymentPlan Date:D' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_sendpayment:plandate:plandate:SendPayment_计划付款日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_sendpayment_no:I', 7, 1, 'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_付款计划编号:I','LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_sendpayment no:I' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_付款计划编号:I');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_sendpayment:Actualdate:Actualdate:SendPayment_Actualdate:V', 8, 1, 'LD_sendpayment:Actualdate:Actualdate:SendPayment_实际付款时间:V','LD_sendpayment:Actualdate:Actualdate:SendPayment_Actual date:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_sendpayment:Actualdate:Actualdate:SendPayment_实际付款时间:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_sendpayment:amount:amount:SendPayment_amount:N', 9, 1, 'LD_sendpayment:amount:amount:SendPayment_付款计划_金额:N','LD_sendpayment:amount:amount:SendPayment_SendPayment amount:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_sendpayment:amount:amount:SendPayment_付款计划_金额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_sendpayment:actualamount:actualamount:SendPayment_actualamount:V', 10, 1, 'LD_sendpayment:actualamount:actualamount:SendPayment_已付金额:V','LD_sendpayment:actualamount:actualamount:SendPayment_actual amount:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_sendpayment:actualamount:actualamount:SendPayment_已付金额:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_sendpayment:CPStatus:CPStatus:SendPayment_CPStatus:V', 11, 1, 'LD_sendpayment:CPStatus:CPStatus:SendPayment_付款计划_状态:V','LD_sendpayment:CPStatus:CPStatus:SendPayment_SendPayment Status:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_sendpayment:CPStatus:CPStatus:SendPayment_付款计划_状态:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_sendpayment:SendPaymentBalance:SendPaymentBalance:OftenUseReport_SendPaymentBalance:N', 12, 1, 'LD_sendpayment:SendPaymentBalance:SendPaymentBalance:OftenUseReport_应付款余额:N','LD_sendpayment:SendPaymentBalance:SendPaymentBalance:OftenUseReport_SendPayment Balance:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_sendpayment:SendPaymentBalance:SendPaymentBalance:OftenUseReport_应付款余额:N');

delimiter;


select usereportid into @id from LD_usereport where name='Contactbusinesstable';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id AND columns='ld_expense:total:total:expense_total:N';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id AND columns='ld_expense:total:total:expense_total:NN';
delimiter;

SELECT tabid into@tabid FROM ld_tab WHERE name='Expense';
select  fieldlabel into@enfieldname FROM ld_tranlabel WHERE tabid=@tabid and relateid=@tabid and languagetype='en';
select  fieldlabel into@zhfieldname FROM ld_tranlabel WHERE tabid=@tabid and relateid=@tabid and languagetype='zh';

select usereportid into @id from LD_usereport where name='Contactbusinesstable';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_expense:total:total:expense_total:NN', 10, 1, concat('ld_expense:total:total:expense_佣金(',@zhfieldname,'):NN'),
concat('ld_expense:total:total:expense_Commission(',@enfieldname,'):NN')   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id 
and columns='ld_expense:total:total:expense_total:NN');
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'GraphicalReports',0,50,'GraphicalReports',0,0,1,'Parent Reports',0 from dual 
where not exists(select 1 from lD_tab where name='GraphicalReports');
delimiter;

select tabid into @tabid from lD_tab where name='GraphicalReports';
select parenttabid into @parenttabid from LD_parenttab where  parenttab_Label='Parent Reports';
insert into LD_parenttabrel(tabid,parenttabid,sequence) select @tabid,@parenttabid,4 from dual 
where not exists(select 1 from LD_parenttabrel where tabid=@tabid );
delimiter;


select tabid into @tabid from ld_tab where name='GraphicalReports';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'GraphicalReports','图形化报表','图形化报表' from dual 
where not EXISTS(select 1 from ld_languagepackage where tabid=@tabid);

insert into  ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_tab',@tabid,@tabid,'图形化报表' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='LD_tab' and relateid=@tabid);

insert into  ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_tab',@tabid,@tabid,'Graphical Reports' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='LD_tab' and relateid=@tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ReportName','Report Name','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ReportName' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ReportName','报表名称','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ReportName' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ZHANGTAONAME','账套名称','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ZHANGTAONAME' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ZHANGTAONAME','Zhang Tao name','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ZHANGTAONAME' and Labeltype='jspop');
delimiter;
update ld_datainterface set soft_factory = '金蝶',soft_version=1,demo_name='',sa='sa',pwd='',databasename='',
hostname='.',using_order=0,using_credence=0,using_inventory=0 where ID = 1;
delimiter;

select tabid into @tabid from LD_tab where name='SalesGoal' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;

update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
update LD_def_org_share set permission = 3,editstatus=0 where tabid = @tabid;
delimiter;

select usereportid into @usereportid from ld_usereport where name = 'Performancestatisticscollection';
delete from ld_usereportcolumns where Usereportid = @usereportid and columns = 'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_CommissionTotal:NN';

insert into ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_CommissionTotal:NN',11,1,'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_佣金合计:NN','LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_Commission Total:NN'
from dual where not EXISTS(select 1 from ld_usereportcolumns  where Usereportid = @usereportid and columns='LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_CommissionTotal:NN');
delimiter;

ALTER TABLE ld_campaign MODIFY COLUMN expectedresponsecount decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_campaign MODIFY COLUMN expectedsalescount decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_campaign MODIFY COLUMN actualresponsecount decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_campaign MODIFY COLUMN actualsalescount decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_inventoryproductrel MODIFY COLUMN firmoffer decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_inventoryproductrel MODIFY COLUMN profitloss decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_inventoryproductrel MODIFY COLUMN paperquantity decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_products MODIFY COLUMN qtyinstock decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_products MODIFY COLUMN qtyearly decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_warehouse2products MODIFY COLUMN productqty decimal(25,2) default 0.00;
delimiter;
ALTER TABLE ld_warehouse2startedproducts MODIFY COLUMN qty decimal(25,2) default 0.00;
delimiter;

UPDATE ld_desk set Fieldlabel='Whether to display ‘Expect GP‘ and ‘Cost Price’ on the order、quote、invoice、in or out store etc' where labelbol='PRODUCTSETLABEL' and languagetype='en';
UPDATE ld_desk set Fieldlabel='The Expense and Commission statistics scope of' where labelbol='EXCOMMTOTAL' and languagetype='en';
UPDATE ld_desk set Fieldlabel='费用报销单和佣金单统计范围' where labelbol='EXCOMMTOTAL' and languagetype='zh';
update ld_tab set presence=1 where `name`='GraphicalReports';

select tabid into @tabid from ld_tab where `name`='Commission';
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Expense';
SELECT @i:=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=@parenttabid order by sequence; 
delimiter;
-- End: 2014-06-19 by luyx 

update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
delimiter;
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;
update ld_customview_seq set id = (select max(cvid) from ld_customview);
delimiter;
update ld_links_seq set id=(select max(linkid) from ld_links);
delimiter;
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
delimiter;
update ld_approve_seq set id=(select max(id) from ld_approve);
delimiter;
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
delimiter;
update lD_version set old_version='V5.3.2' ,current_version='V5.3.2' ,remark='V5.3.2-20140619';
delimiter;