DROP PROCEDURE IF EXISTS `crm_addtab_intoprofile`;
delimiter ||
CREATE PROCEDURE `crm_addtab_intoprofile`(
tabname varchar(100),
operation int(10)
)
BEGIN
		declare var_profileid int(19);
	  declare done  int  default 0;
	 declare cur1 CURSOR FOR SELECT profileid   FROM  ld_profile;
	 declare continue handler  for not   found  SET done =1;
  set @sql='select tabid into @tabid from ld_tab  where ';
	 set @sql=CONCAT(@sql, " name='",tabname,"'");
	prepare stmt from @sql;
	execute stmt;
	deallocate prepare stmt;
  open cur1;
	Fetch cur1 into var_profileid;
	loop1: while  done<>1 DO	
		
			set @sql=" insert into ld_profile2tab(profileid,tabid,permissions) select ";
			set @sql=concat(@sql,var_profileid,",",@tabid,",",0 ," from dual where not exists(select 1 from ld_profile2tab where tabid=",@tabid," and profileid=",var_profileid,")");
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
		  set @sql=" insert into ld_profileallpermission(tabid,operation,sequence) select ";
			set @sql=concat(@sql,@tabid,",",operation ,",",0, " from dual where not exists(select 1 from ld_profileallpermission where tabid=",@tabid ,' and operation=',operation,")");
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
			
			set @sql=" insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select ";
			set @sql=concat(@sql,var_profileid,',',@tabid,",",operation ,",",0,",",0, " from dual where not exists(select 1 from ld_profile2standardpermissions where profileid=" ,var_profileid," and tabid=",@tabid ,' and operation=',operation,")");
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
			Fetch cur1 into var_profileid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `rest_cvcolumnlist_wx`;
delimiter ||
CREATE PROCEDURE `rest_cvcolumnlist_wx`(
	tmp_module VARCHAR(100),
	tmp_column VARCHAR(100),
	tmp_rownum INT(1),
	tmp_colnum INT(1),
	tmp_showtag VARCHAR(20),
	tmp_sysdefault VARCHAR(20)
)
BEGIN
	
	SET @columnname=(
		SELECT 
			CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1)) 
		FROM ld_tab a
		LEFT JOIN ld_field b ON a.tabid=b.tabid
		WHERE a.`name`=tmp_module
			AND b.columnname=tmp_column
		LIMIT 1);

	DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
	INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
	SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `DelForeignkey`;
delimiter ||
CREATE PROCEDURE `DelForeignkey`(
	tablename varchar(50),
	foreignname varchar(50)
)
BEGIN

		SELECT DATABASE() INTO @tableschema;
		
		SET @cnt=0;
		SET tablename=lower(tablename);
		SELECT count(1) INTO @cnt FROM information_schema.INNODB_SYS_FOREIGN WHERE ID=concat(DATABASE(),'/',foreignname) AND FOR_NAME=CONCAT(DATABASE(),'/',tablename);
		
		IF @cnt>0 THEN
				SET @sql1=CONCAT(' alter table ',tablename, ' drop foreign key ',foreignname);
				PREPARE stalter FROM @sql1;
				EXECUTE stalter;
				DEALLOCATE PREPARE stalter;
		END IF;

end ||
delimiter;

update ld_tranlabel set fieldlabel='设置负库存时是否允许出库' where trantable='ld_systems_deploy' and Relateid=141 and languagetype='zh';
update ld_tranlabel set fieldlabel='Whether to allow out of storage when setting negative stock' where trantable='ld_systems_deploy' and Relateid=141 and languagetype='en';
delimiter;

update ld_desk set fieldlabel='消息' where languagetype='zh' and labelbol='REMINDS' and Labeltype='fixedstr';
update ld_desk set fieldlabel='News' where languagetype='en' and labelbol='REMINDS' and Labeltype='fixedstr';
delimiter;

select tabid into @cashbilltabid from ld_tab where name='CashBill';
select tabid into @sendcashbilltabid from ld_tab where name='SendCashBill';
select blockid into @blockid from ld_appparenttab where parenttab_label='Finacial';
select sequence into @sequence from ld_appparenttabrel where blockid=@blockid and tabid=@cashbilltabid;
update ld_appparenttabrel set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
set @sequence=IFNULL(@sequence,0);

insert into ld_appparenttabrel(blockid,tabid,sequence) 
select @blockid,@sendcashbilltabid,@sequence+1 from dual where not exists(select 1 from ld_appparenttabrel 
where blockid=@blockid and tabid=@sendcashbilltabid);

set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='SendCashBill';
CALL rest_cvcolumnlist_wx('SendCashBill','sendcashbill_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('SendCashBill','vendorid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('SendCashBill','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('SendCashBill','smownerid','4','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;

SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'vendor_id',(@i:=@i+1),'title',0,'no' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'sendcashbill_no',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='sendcashbill_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'cashbilldate',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='cashbilldate');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;
-- 2018-05-08

CALL DelForeignkey('ld_homestuff','ld_homestuff_ibfk_1');
CALL DelForeignkey('ld_salesmanactivityrel','ld_salesmanactivityrel_ibfk_1');
CALL DelForeignkey('ld_users2group','ld_users2group_ibfk_1');

update ld_desk set fieldlabel='合同年度销售业绩情况' where labelbol='ANNUALSALES' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Annual sales performance of the contract' where labelbol='ANNUALSALES' and Labeltype='fixedstr' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Operating_Instructions','操作说明','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Operating_Instructions' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','Operating_Instructions','Operating Instructions','jspop' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Operating_Instructions' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARETYPEADD','在已有的共享人基础上增加新勾选的成员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARETYPEADD' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SHARETYPEADD','Adding newly elected members on the basis of an existing shared person','jspop' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARETYPEADD' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARETYPEREPLACE','将已有的共享人替换为新勾选的成员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARETYPEREPLACE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SHARETYPEREPLACE','Replacing existing shared people as newly selected members','jspop' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARETYPEREPLACE' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARETYPECANCEL','从已有的共享人中移除所选成员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARETYPECANCEL' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SHARETYPECANCEL','Remove selected members from an existing shared person','jspop' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARETYPECANCEL' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SUCCESS','成功','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SUCCESS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SUCCESS','Success','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SUCCESS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOINCHARGEOF','单据[%s]%s不成功！原因：您不是该单据的负责人!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NOINCHARGEOF' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','NOINCHARGEOF','Document[%s] %s no success! The reason: you are not the person in charge of the document！','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NOINCHARGEOF' and Labeltype='fixedstr');


UPDATE ld_systems_deploy SET description='设置是否仅允许系统管理员用户和负责人共享单据。1:否，0:是' WHERE deploy_type=33;
UPDATE ld_tranlabel SET fieldlabel = '设置是否仅允许系统管理员用户和负责人共享单据'
WHERE languagetype='zh' AND trantable='ld_systems_deploy'AND tabid=33 AND  Relateid=33;
UPDATE ld_tranlabel SET fieldlabel = 'Set whether to allow only the system administrator user and the person in charge to share the documents'
WHERE languagetype='en' AND trantable='ld_systems_deploy'AND tabid=33 AND  Relateid=33;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SUPERADDTION','追加','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SUPERADDTION' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SUPERADDTION','Add','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SUPERADDTION' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REPLACE','替换','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='REPLACE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REPLACE','Update','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REPLACE' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TYPE','类型','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TYPE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TYPE','Type','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TYPE' and Labeltype='jspop');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_account_bwid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `accountid` int(11) NOT NULL DEFAULT '0',
  `bw_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

update ld_desk set fieldlabel='自分配或创建之日起距最近一次{$CashBill.CashBill}的{$CashBill.createdtime}已超过' where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILLCREATE' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='The nearest {$CashBill.cashbilldate} of {$CashBill.createdtime} has exceed  the date of distribution or creation' where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILLCREATE' and languagetype='en' and labeltype='fixedstr';
delimiter;
-- 2018-05-15

UPDATE ld_tranlabel SET fieldlabel = 'Set whether to allow only the system administrator user and the person in charge to share records'
WHERE languagetype='en' AND trantable='ld_systems_deploy'AND tabid=33 AND  Relateid=33;

update ld_desk set fieldlabel='Operation description'
where labelbol='Operating_Instructions' and languagetype='en' and Labeltype='jspop';
update ld_desk set fieldlabel='Update'
where labelbol='REPLACE' and languagetype='en' and Labeltype='jspop';
update ld_desk set fieldlabel='单据[%s]共享失败！原因：您不是该单据的负责人!'
where labelbol='NOINCHARGEOF' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Record [%s] sharing fail! The reason: you are not the person in charge of the record！'
where labelbol='NOINCHARGEOF' and languagetype='en' and Labeltype='fixedstr';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARESUCCEED','单据[%s]共享成功!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARESUCCEED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHARESUCCEED','Record [%s] sharing succeed!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARESUCCEED' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARECANCEL','单据[%s]取消共享成功!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARECANCEL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHARECANCEL','Record [%s] sharing cancel!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARECANCEL' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHAREDETAILFAIL','您没有权限共享该单据！<br/>原因：您不是该单据的负责人！','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHAREDETAILFAIL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SHAREDETAILFAIL','You have no authority to share the record!<br/>Reason: you are not the person in charge of the record!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en'
                                                and labelbol='SHAREDETAILFAIL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WARMPROMPT','温馨提示','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WARMPROMPT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WARMPROMPT','Warm prompt','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WARMPROMPT' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='账号' where labelbol='USERNAME' and languagetype='zh' and Labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel='领取为自己的公海客户' where labelbol='GETMYPUBLICACCOUNT' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

call crm_addtab_intoprofile('RecycleBin',3);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GECOUNT','个','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and Labeltype='fixedstr' and labelbol='GECOUNT');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GECOUNT','','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and Labeltype='fixedstr' and labelbol='GECOUNT');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARETYPE','共享类型','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARETYPE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHARETYPE','The share type','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARETYPE' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CANCELSHARE','取消共享','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CANCELSHARE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANCELSHARE','Cancel Sharing','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CANCELSHARE' and Labeltype='jspop');
delimiter;
-- 2018-05-23

UPDATE ld_producttoolfield SET allowhide='yes' WHERE tabid=20 AND columnname IN ('entitytype','entitytypeid');

INSERT INTO ld_systems_deploy (deploy_value, deploy_type, description, sequence, presence)
SELECT 1,160,'坐席状态根据CRM是否登录显示 1:否，0:是',76,0 FROM dual
WHERE NOT exists(SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 160);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',160,160,'坐席状态根据CRM是否登录显示' from dual
where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=160);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',160,160,'Seat status according to CRM login display' from dual
where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=160);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HANTIANSEATSTATERELATETOCRM','CRM系统登录成功后，坐席状态显示为置闲；未登录时，坐席状态显示为置忙','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'HANTIANSEATSTATERELATETOCRM' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HANTIANSEATSTATERELATETOCRM','When the CRM system is successfully logged in, the seat status is displayed as idle. When it is not logged in, the seat status is displayed as busy.','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'HANTIANSEATSTATERELATETOCRM' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

update ld_tranlabel set fieldlabel='销售税率' where trantable='ld_inventorytaxinfo' and fieldlabel='销售' and languagetype='zh';
update ld_tranlabel set fieldlabel='服务税率' where trantable='ld_inventorytaxinfo' and fieldlabel='服务' and languagetype='zh';
update ld_tranlabel set fieldlabel='Sales Tax Rate' where trantable='ld_inventorytaxinfo' and fieldlabel='Sales Tax' and languagetype='en';
update ld_tranlabel set fieldlabel='Service Tax Rate' where trantable='ld_inventorytaxinfo' and fieldlabel='Service Tax' and languagetype='en';
update ld_desk set fieldlabel='{$PaymentPlan.PaymentPlan}是针对{$SalesOrder.SalesOrder}、{$ServiceContracts.ServiceContracts}或{$Invoice.Invoice}的，不允许直接新增' where labelbol='How_to_create_plan1' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='可通过系统参数控制，新增{$SalesOrder.SalesOrder}、{$ServiceContracts.ServiceContracts}或{$Invoice.Invoice}后自动弹出{$PaymentPlan.PaymentPlan}新增界面' where labelbol='How_to_create_plan2' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='也可以通过{$SalesOrder.SalesOrder}、{$ServiceContracts.ServiceContracts}或{$Invoice.Invoice}查看明细界面更多->创建{$PaymentPlan.PaymentPlan}增加' where labelbol='How_to_create_plan3' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$PaymentPlan.PaymentPlan} is for the {$SalesOrder.SalesOrder},{$ServiceContracts.ServiceContracts} or {$Invoice.Invoice}, direct creation is not allowed' where labelbol='How_to_create_plan1' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Can be controlled by the system parameters, after creating {$SalesOrder.SalesOrder},{$ServiceContracts.ServiceContracts} or {$Invoice.Invoice},create plans immediately' where labelbol='How_to_create_plan2' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='You can view the {$SalesOrder.SalesOrder},{$ServiceContracts.ServiceContracts} or {$Invoice.Invoice} detailes and click the button More->Create {$PaymentPlan.PaymentPlan}' where labelbol='How_to_create_plan3' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$SendPayment.SendPayment}是针对{$PurchaseOrder.PurchaseOrder}或{$PurchaseInvoice.PurchaseInvoice}的，不允许直接新增' where labelbol='How_to_send_create_plan1' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$SendPayment.SendPayment} is for the {$PurchaseOrder.PurchaseOrder} or {$PurchaseInvoice.PurchaseInvoice}, direct creation is not allowed' where labelbol='How_to_send_create_plan1' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='可通过系统参数控制，新增{$PurchaseOrder.PurchaseOrder}或{$PurchaseInvoice.PurchaseInvoice}后自动弹出{$SendPayment.SendPayment}新增界面' where labelbol='How_to_send_create_plan2' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Can be controlled by the system parameters, after creating {$PurchaseOrder.PurchaseOrder} or {$PurchaseInvoice.PurchaseInvoice},create plans immediately' where labelbol='How_to_send_create_plan2' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='也可以通过{$PurchaseOrder.PurchaseOrder}或{$PurchaseInvoice.PurchaseInvoice}查看明细界面更多->创建{$SendPayment.SendPayment}增加' where labelbol='How_to_send_create_plan3' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Or view the {$PurchaseOrder.PurchaseOrder} or {$PurchaseInvoice.PurchaseInvoice} detailes and click the button More->Create {$SendPayment.SendPayment}' where labelbol='How_to_send_create_plan3' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords}次数TOP10' where labelbol='CUSTOMERCONTACTNUMTEN' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords} number TOP10' where labelbol='CUSTOMERCONTACTNUMTEN' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords}次数TOP50' where labelbol='CUSTOMERCONTACTNUMFIFTY' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords} number TOP50' where labelbol='CUSTOMERCONTACTNUMFIFTY' and languagetype='en' and Labeltype='fixedstr';
delimiter;
-- 2018-05-27

select tabid into @invoicetabid from ld_tab where name='Invoice';
select tabid into @purchaseinvoicetabid from ld_tab where name='PurchaseInvoice';
select blockid into @blockid from ld_appparenttab where parenttab_label='Finacial';
select sequence into @sequence from ld_appparenttabrel where blockid=@blockid and tabid=@invoicetabid;
update ld_appparenttabrel set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
set @sequence=IFNULL(@sequence,0);
insert into ld_appparenttabrel(blockid,tabid,sequence) 
select @blockid,@purchaseinvoicetabid,@sequence+1 from dual where not exists(select 1 from ld_appparenttabrel 
where blockid=@blockid and tabid=@purchaseinvoicetabid);

set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='PurchaseInvoice';
CALL rest_cvcolumnlist_wx('PurchaseInvoice','purchaseinvoice_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('PurchaseInvoice','vendorid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('PurchaseInvoice','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('PurchaseInvoice','smownerid','4','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInvoice');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;

SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'vendor_id',(@i:=@i+1),'title',0,'no' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'purchaseinvoice_no',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='purchaseinvoice_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'sendcashbilldate',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='sendcashbilldate');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;

select tabid into @paymentplantabid from ld_tab where name='PaymentPlan';
select tabid into @sendpaymenttabid from ld_tab where name='SendPayment';
select blockid into @blockid from ld_appparenttab where parenttab_label='Finacial';
select sequence into @sequence from ld_appparenttabrel where blockid=@blockid and tabid=@paymentplantabid;
update ld_appparenttabrel set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
set @sequence=IFNULL(@sequence,0);
insert into ld_appparenttabrel(blockid,tabid,sequence) 
select @blockid,@sendpaymenttabid,@sequence+1 from dual where not exists(select 1 from ld_appparenttabrel 
where blockid=@blockid and tabid=@sendpaymenttabid);

set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='SendPayment';
CALL rest_cvcolumnlist_wx('SendPayment','sendpayment_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('SendPayment','vendorid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('SendPayment','amount','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('SendPayment','smownerid','4','1','yes','yes');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendPayment');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'sendpayment_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='sendpayment_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'vendor_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'plandate',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='plandate');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'amount',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='amount');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;
-- 2018-05-30

DROP PROCEDURE IF EXISTS `ldcrm_add_approveprocess`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_approveprocess`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_modname VARCHAR(100) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			b.tabid,
			c.fieldlabel
		FROM ld_systems_deploy a
		INNER JOIN ld_tab b ON a.setype=b.`name`
		LEFT JOIN ld_tranlabel c ON c.tabid=b.tabid AND c.trantable='ld_tab' AND c.languagetype='zh'
		WHERE IFNULL(a.setype,'')<>''
		ORDER BY tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;


	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_modname;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @maxid=IFNULL((SELECT MAX(id) FROM ld_approve),0);
		INSERT INTO ld_approve(id,tabid,`name`,description,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
		SELECT @maxid+1,tmp_tabid,CONCAT(tmp_modname,'选人审批流程'),CONCAT(tmp_modname,'预置审批流程'),0,1,1,NOW(),NOW(),0,0,0;

		UPDATE ld_approve_seq SET id=(SELECT max(id) FROM ld_approve);

		INSERT INTO ld_approve2user(approveid,userid) SELECT @maxid+1,-1;

		SET @i=0;
		SET @maxstepid=IFNULL((SELECT MAX(id) FROM ld_approvestep),0);		
		INSERT INTO ld_approvestep(id,approveid,`name`,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxstepid+1,@maxid+1,'一级审批','',0,1,(@i:=@i+1),NOW(),NOW(),6,NULL,0;

		INSERT INTO ld_approvestep(id,approveid,`name`,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxstepid+2,@maxid+1,'二级审批','',1,1,(@i:=@i+1),NOW(),NOW(),6,NULL,0;

		INSERT INTO ld_approvestep(id,approveid,`name`,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxstepid+3,@maxid+1,'三级审批','',1,1,(@i:=@i+1),NOW(),NOW(),6,NULL,0;
		
		UPDATE ld_approvestep_seq SET id=(SELECT max(id) FROM ld_approvestep);
		FETCH MYCUSOR INTO tmp_tabid,tmp_modname;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_reset_approveprocess_20180531`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_approveprocess_20180531`(
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) AND NOT EXISTS (SELECT 1 FROM ld_approvelog) THEN
		DELETE FROM ld_approve;
		DELETE FROM ld_approvestep;
		DELETE FROM ld_approve2user;
		DELETE FROM ld_approvelog;
		
		CALL ldcrm_add_approveprocess();
	END IF;

end ||
delimiter;

CALL ldcrm_reset_approveprocess_20180531();

DROP PROCEDURE IF EXISTS `ldcrm_reset_approveprocess_20180531`;
DROP PROCEDURE IF EXISTS `ldcrm_add_approveprocess`;
-- 2018-05-31

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select tabid into @relatetabid from ld_tab where name = 'Quotes';
update ld_relatedlists set related_coltable='inventoryproductrel.entitytypeid' where tabid=@tabid and related_tabid=@relatetabid;
delimiter;

DROP PROCEDURE if EXISTS account_nocomplete_recoveryrule;
delimiter ||
CREATE PROCEDURE  account_nocomplete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
  select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';
     
  select allotaccount into @allotaccount from ld_account_set ;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if var_condition='and'  then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );
			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0   ");

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(curdate(),case when ld_account.allocatedate>max( ",var_tablename,'.',var_columnname,")   then ld_account.allocatedate else max(",var_tablename,'.',var_columnname,") end  )>",var_days );
      set @tmpsqlone=concat(@tmpsqlone,"  and datediff(ld_account.allocatedate,min( ",var_tablename,'.',var_columnname,"))>",var_days);

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then

				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");

				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate > max(" , var_tablename,".",var_columnname," ) then ld_account.allocatedate else max(" , var_tablename,".",var_columnname,") end  )<=",var_days );
			  set @tmpsqlone=concat(@tmpsqlone,"  and datediff(ld_account.allocatedate,min( ",var_tablename,'.',var_columnname,"))<=",var_days);
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');

		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
    
		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
	  else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);

		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;

			if var_condition='or'  then
				set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		 else
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
		  end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;
	end if;
	

end ||
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'vendorid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','vendor_id' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @vendorcontacttabid from ld_tab where name='VendorContact';
select tabid into @purchaseinquiryordertabid from ld_tab where name='PurchaseInquiryOrder';
select blockid into @blockid from ld_appparenttab where parenttab_label='Purchase';
select sequence into @sequence from ld_appparenttabrel where blockid=@blockid and tabid=@vendorcontacttabid;
update ld_appparenttabrel set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
set @sequence=IFNULL(@sequence,0);
insert into ld_appparenttabrel(blockid,tabid,sequence) 
select @blockid,@purchaseinquiryordertabid,@sequence+1 from dual where not exists(select 1 from ld_appparenttabrel 
where blockid=@blockid and tabid=@purchaseinquiryordertabid);

set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='PurchaseInquiryOrder';
CALL rest_cvcolumnlist_wx('PurchaseInquiryOrder','purchaseinquiryorder_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('PurchaseInquiryOrder','vendorid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('PurchaseInquiryOrder','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('PurchaseInquiryOrder','smownerid','4','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInquiryOrder');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;

SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'purchaseinquiryorder_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='purchaseinquiryorder_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'vendor_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
delete from ld_related_field where trigger_fieldid=@trigger_fieldid and fromvalue_info='vendor_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','vendorid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

update ld_tab set mobilepresence='weixin' where name='Attachment';
delimiter;

update ld_desk set fieldlabel='添加' where labelbol='ADDINGATTACHMENTS' and Labeltype='jspop' and languagetype='zh';
delimiter;

select tabid into @tabid from ld_tab where name='OutboundOrder';
update ld_field set masseditable=0 where tabid=@tabid 
	and (columnname='have_invoicetotal' or columnname='lastinvoice_no' or columnname='invoicetotal'or columnname='lastinvoicedate');
delimiter;

select tabid into @tabid from ld_tab where name='stock';
update ld_field set masseditable=0 where tabid=@tabid 
	and (columnname='have_invoicetotal' or columnname='lastinvoice_no' or columnname='invoicetotal'or columnname='lastinvoicedate');
delimiter;

select tabid into @tabid from ld_tab where name='outboundorder';
select sequence into @sequence from ld_profileallpermission  where operation=6 and tabid=70;
update ld_profileallpermission set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=5);
delimiter;

select tabid into @tabid from ld_tab where name='stock';
select sequence into @sequence from ld_profileallpermission  where operation=6 and tabid=70;
update ld_profileallpermission set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=5);
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
select sequence into @sequence from ld_profileallpermission  where operation=6 and tabid=@tabid;
update ld_profileallpermission set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=5);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInvoice';
select sequence into @sequence from ld_profileallpermission  where operation=6 and tabid=@tabid;
update ld_profileallpermission set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=5);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESLECTFIRST','请先选择','jspop' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASESLECTFIRST' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESLECTFIRST','Please select','jspop' from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASESLECTFIRST' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THNECHOOSE','，再选择','jspop' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='THNECHOOSE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THNECHOOSE',' first, then choose','jspop' from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='THNECHOOSE' and labeltype='jspop');
delimiter;
-- 2018-06-06

DELETE FROM ld_usereportcolumns WHERE `columns` LIKE '%ld_singin:singincount:singincount:OftenUseReport%';

select usereportid into @usereportid  from ld_usereport  where name='SalesSumSequence';
select sequence into @sequence  from ld_usereportcolumns  where usereportid=@usereportid and  columns like '%ld_users:last_name:last_name:OftenUseReport_last_name%';
update ld_usereportcolumns set sequence=sequence+1 where sequence>@sequence and usereportid=@usereportid;
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_singin:singincount:singincount:OftenUseReport_外勤签到次数:N',@sequence+1,1,'ld_singin:singincount:singincount:OftenUseReport_外勤签到次数:N','ld_singin:singincount:singincount:OftenUseReport_Number of sign in:N' from DUAL
where not EXISTS(select 1 from ld_usereportcolumns where usereportid =@usereportid and columns like '%ld_singin:singincount:singincount:OftenUseReport%');
delimiter;

update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords}次数TOP10' where labelbol='CUSTOMERCONTACTNUMTEN' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords} number TOP10' where labelbol='CUSTOMERCONTACTNUMTEN' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords}次数TOP50' where labelbol='CUSTOMERCONTACTNUMFIFTY' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords} number TOP50' where labelbol='CUSTOMERCONTACTNUMFIFTY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$ContactRecords.ContactRecords}数量负责人/月度统计' where labelbol='CONTACTRECORDSQUANTITY' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='{$ContactRecords.ContactRecords} person in charge of number/ monthly statistics' where labelbol='CONTACTRECORDSQUANTITY' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='{$ContactRecords.contactrecordtype}分布统计' where labelbol='CONTACTRECORDSTYPE' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$ContactRecords.contactrecordtype} distribution statistics' where labelbol='CONTACTRECORDSTYPE' and languagetype='en' and Labeltype='fixedstr';
delimiter;


select sequence into @sequence from ld_systems_deploy where deploy_type=59;
update ld_systems_deploy set sequence=sequence+1 where sequence>@sequence and roottype=1;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select '',160,'设置服务合同新增保存后更新客户的客户状态字段',@sequence+1,1,'select',0,'[{"value":"rating","text":"rating"},{"field":"rating","type":"picklist","relatetable":"ld_field"},{"relatedmodule":"SalesOrder,Accounts"},{"isSelectValue":"yes"}]'
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=160);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',160,160,'设置{$ServiceContracts.ServiceContracts}新增保存后是否更新{$Accounts.Accounts}的{$Accounts.rating}字段为（为空表示不更新）'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=160 and Relateid=160 and trantable='ld_systems_deploy' and  languagetype='zh');
 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',160,160,'{$Accounts.Accounts} updated when {$ServiceContracts.ServiceContracts} Added save {$Accounts.rating} is (blank means no update)'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=160 and Relateid=160 and trantable='ld_systems_deploy' and  languagetype='en');
delimiter;

 insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ifsendpaythestatehasebeenselectedaspartofthe','若是选择状态为部分已付或已付，保存之后则不可再编辑该单据。是否需要保存？','jspop'
from dual where not exists(select 1 from ld_desk where labelbol='ifsendpaythestatehasebeenselectedaspartofthe' and labeltype='jspop' and languagetype='zh');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ifsendpaythestatehasebeenselectedaspartofthe','若是选择状态为部分已付或已付，保存之后则不可再编辑该单据。是否需要保存？','jspop'
from dual where not exists(select 1 from ld_desk where labelbol='ifsendpaythestatehasebeenselectedaspartofthe' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SUPPORTSTAFFBANG','处理客服(用户)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SUPPORTSTAFFBANG' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SUPPORTSTAFFBANG','support staff','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SUPPORTSTAFFBANG' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CALLOUTBANG','呼出','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CALLOUTBANG' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CALLOUTBANG','call out','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CALLOUTBANG' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CALLINBANG','呼入','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CALLINBANG' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CALLINBANG','call in','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CALLINBANG' and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_callcenter_record`(
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `centername`     VARCHAR(255),
  `crm_userid`     INT(19),
  `seatname`     VARCHAR(255),
  `callid`     VARCHAR(255) not null unique ,
  `direction`     TINYINT(4),
  `from_phone`      VARCHAR(255),
  `to_phone`      VARCHAR(255),
  `starttime` datetime,
  `duration`      INT(11),
  `status`       TINYINT(4),
  `recordurl`      VARCHAR(255),
  `crm_recordid` INT(19) default 0,
  `crm_module` VARCHAR(255)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_callcenter_user` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(19) NOT NULL,
  `username` varchar(255) DEFAULT '',
  `centername` varchar(255) DEFAULT '',
  `seatname` varchar(255) DEFAULT '',
  `seatpassword` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

update ld_desk set fieldlabel='执行该操作后，使用本流程审批中的单据将自动返回负责人，是否继续？' where labelbol='PERSONCHARGEWHETHERCONTINUE' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='After implementation of the operation, the documents in the approval process will automatically return to the person in charge and continue.' where labelbol='PERSONCHARGEWHETHERCONTINUE' and languagetype='en' and Labeltype='jspop';
delimiter;

select tabid into @tabid from ld_tab where name='Attachment';
select fieldid into @fieldid from ld_field where tabid=@tabid and fieldname='uuid';
update ld_tranlabel set fieldlabel='手机设备号' where Relateid=@fieldid and languagetype='zh';
delimiter;

update ld_desk set fieldlabel='3. 同一成员24小时内只需要验证一次' where labelbol='WARMREMINDETHREEE' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='3. 24 hours just need to verify once at the same users;' where labelbol='WARMREMINDETHREEE' and Labeltype='fixedstr' and languagetype='en';
delimiter;


update ld_field set quickcreate = 2 where columnname in ('5w2p_why1','5w2p_plan1','5w2p_plan2','5w2p_why2','5w2p_why3','5w2p_why4','5w2p_why5');
delimiter;
drop PROCEDURE if exists account_nocomplete_recoveryrule;
delimiter ||
create PROCEDURE account_nocomplete_recoveryrule()


BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
  select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';
     
  select allotaccount into @allotaccount from ld_account_set ;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if var_condition='and'  then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );
			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0   ");

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(curdate(),case when ld_account.allocatedate>max( ",var_tablename,'.',var_columnname,")   then ld_account.allocatedate else max(",var_tablename,'.',var_columnname,") end  )>",var_days );
      set @tmpsqlone=concat(@tmpsqlone,"  and datediff(ld_account.allocatedate,min( ",var_tablename,'.',var_columnname,"))>",var_days);

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then

				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");

				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate > max(" , var_tablename,".",var_columnname," ) then ld_account.allocatedate else max(" , var_tablename,".",var_columnname,") end  )<=",var_days );
			  set @tmpsqlone=concat(@tmpsqlone,"  and datediff(ld_account.allocatedate,min( ",var_tablename,'.',var_columnname,"))<=",var_days);
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');

		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
    
		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
	  else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);

		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
     

	if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "nocomplete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "nocomplete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成" group by ld_account.smownerid    ');
		end if;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();

			if var_condition='or'  then
				set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		 else
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
		  end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;
	end if;
	



end ||
delimiter;

drop PROCEDURE if EXISTS account_complete_recoveryrule;
delimiter ||
create PROCEDURE account_complete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';

  select allotaccount into @allotaccount from ld_account_set;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

			set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
		  set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);

			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );


				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');

		end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
		

    if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成" group by ld_account.smownerid    ');
		end if;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();

			if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			ELSE
			  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

end||
delimiter;

drop PROCEDURE if EXISTS account_normal_recoveryrule;
delimiter ||
create PROCEDURE account_normal_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';

	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.smownerid=ld_account.smownerid ');

			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end>    max(",var_tablename,'.',var_columnname,") then  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );

      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
				set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end>max( ", var_tablename,'.',var_columnname,") then  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);


				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
			select @tmpsql;

		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
		end if;
select @TMPSQL_TWO;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();


		if var_condition='or'  then
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		      set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			ELSE
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
     end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

end ||
delimiter;
-- 2018-06-08

update ld_tab set tablabel = 'ModComments' where `name` = 'ModComments';
delimiter;

delete from ld_cvcolumnlist_wx where modulename='ServiceCharge' and (columnname like 'ld_contactscf%' or columnname like 'ld_contactdetails%');
delimiter;

update ld_desk set fieldlabel='网页端菜单定制' where labelbol='LBL_TABLIST' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OftenUseReport';
update ld_usereport set tabids = @tabid where `name` = 'SalesSumSequence';
delimiter;

select count(1) into @cnt from ld_field where tabid = 6 and duplicatefield = 0;
update ld_field set duplicatefield = 0 where tabid = 6 and columnname in ('phone','lastname','mobile') and @cnt = 1;
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ONLINEHELP','帮助','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ONLINEHELP' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ONLINEHELP','Help','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ONLINEHELP' and languagetype='en' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExternalContactSetting','外部联系人设置','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactSetting' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExternalContactSetting','External contact interface setting','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactSetting' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CRMWeatherShowExternalContact','设置微信端CRM中是否显示外部联系人','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CRMWeatherShowExternalContact' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CRMWeatherShowExternalContact','Setting up whether an external contact is displayed in the WeChat side CRM','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CRMWeatherShowExternalContact' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
select max(fieldid) into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'ExternalContactSetting','picklistdependency.png','CRMWeatherShowExternalContact','index.php?module=Settings&action=ExternalContact&parenttab=Settings',@sequence+1,0 from DUAL
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'ExternalContactSetting');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExternalContactInterfaceSetting','外部联系人接口设置','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactInterfaceSetting' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExternalContactInterfaceSetting','External contact interface setting','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactInterfaceSetting' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExternalContactUsersSetting','外部联系人人员设置','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactUsersSetting' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExternalContactUsersSetting','External contact users setting','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactUsersSetting' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExplainOfExternalContact','选择的成员，在微信端CRM列表界面可导入外部联系人至CRM系统，在CRM系统联系人详情界面可直接进行企业微信聊天。','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExplainOfExternalContact' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExplainOfExternalContact','The selected members can import the external contacts to the CRM system on the WeChat CRM list interface, and can directly chat with WeChat in the CRM system contact details interface.','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExplainOfExternalContact' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

CALL AddColumn('ld_wx_config','userid','text',null,null);
CALL AddColumn('ld_wx_config','usertype','varchar',100,null);
call AddColumn('ld_contactdetails','weixin_external_userid','varchar',255,null);

insert into ld_wx_config(name,description,switch,userid,usertype)
select 'external_contact','外部联系人配置','open','','all'
from dual where not exists(select 1 from ld_wx_config where name='external_contact');
delimiter;


call AddColumn('ld_contactdetails','weixin_external_userid','varchar',255,null );
delimiter;

CREATE TABLE IF NOT EXISTS `ld_approvestepadvfilter_grouping` (
  `groupid` int(11) NOT NULL,
  `stepid` int(19) NOT NULL,
  `group_condition` varchar(50) DEFAULT NULL,
  `condition_expression` text,
  PRIMARY KEY (`groupid`,`stepid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_approvestepadvfilter` (
  `stepid` int(19) NOT NULL,
  `columnindex` int(11) NOT NULL,
  `columnname` varchar(250) DEFAULT '',
  `comparator` varchar(50) DEFAULT NULL,
  `value` varchar(200) DEFAULT '',
  `groupid` int(11) DEFAULT '1',
  `column_condition` varchar(255) DEFAULT 'and',
  PRIMARY KEY (`stepid`,`columnindex`),
  KEY `approveadvfilter_cvid_idx` (`stepid`) USING BTREE
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CHOICEAPPROVALPROCESSSELECTAPPROVAL','该审批流程的审批步骤条件都不满足，请重新选择流程！','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='CHOICEAPPROVALPROCESSSELECTAPPROVAL' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CHOICEAPPROVALPROCESSSELECTAPPROVAL','该审批流程的审批步骤条件都不满足，请重新选择流程！','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='CHOICEAPPROVALPROCESSSELECTAPPROVAL' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CURRENTAPPROVALPROCESSSELECTAPPROVAL','当前流程的审批步骤条件都不满足，请重新选择审批流程！','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='CURRENTAPPROVALPROCESSSELECTAPPROVAL' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CURRENTAPPROVALPROCESSSELECTAPPROVAL','当前流程的审批步骤条件都不满足，请重新选择审批流程！','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='CURRENTAPPROVALPROCESSSELECTAPPROVAL' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','APPROVE_BATCHSUBMITLOG_NOTSUBMIT','单据[%s]提交不成功！原因：该单据没有满足审批条件的审批步骤！','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='APPROVE_BATCHSUBMITLOG_NOTSUBMIT' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','APPROVE_BATCHSUBMITLOG_NOTSUBMIT','单据[%s]提交不成功！原因：该单据没有满足审批条件的审批步骤！','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='APPROVE_BATCHSUBMITLOG_NOTSUBMIT' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='审批中是否允许编辑单据' where labelbol='WHETHERTOALLOWEDITINGOFDATA' and languagetype='zh' ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVEFINISHEDALLOWEDIT','审批结束是否允许编辑单据','fixedstr' from dual where not exists(select 1 from ld_desk  where labelbol='APPROVEFINISHEDALLOWEDIT' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVEFINISHEDALLOWEDIT','审批结束是否允许编辑单据','fixedstr' from dual where not exists(select 1 from ld_desk  where labelbol='APPROVEFINISHEDALLOWEDIT' and labeltype='fixedstr' and languagetype='eb');
delimiter;

call AddColumn('ld_approve','finishedallowedit','varchar',50,'no');
delimiter;

update ld_approve set finishedallowedit='yes' where tabid=6 and 
exists(select 1 from ld_systems_deploy where deploy_type=16 and deploy_value=0);
delimiter;

update ld_systems_deploy set roottype=0 where deploy_type=16;
delimiter;

call AddColumn('ld_approvestepdetails','pickcolumnname','varchar',100,'');
delimiter;

update ld_approvestepdetails INNER JOIN 
(select ld_field.columnname,ld_field.tabid,ld_approvestep.id from ld_approvepickfield
INNER JOIN ld_field  on ld_field.fieldid=ld_approvepickfield.fieldid
inner join ld_approve on ld_approve.tabid=ld_field.tabid 
INNER JOIN ld_approvestep on ld_approvestep.approveid=ld_approve.id)
as tmpstep on tmpstep.id=ld_approvestepdetails.stepid 
set ld_approvestepdetails.pickcolumnname=tmpstep.columnname;
delimiter;

update ld_desk set fieldlabel='注销企业' where languagetype='zh' and labelbol='LBL_WECHATAPPLICATION' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Logout company' where languagetype='en' and labelbol='LBL_WECHATAPPLICATION' and Labeltype='fixedstr';
delimiter;
-- 2018-06-22

CREATE TABLE IF NOT EXISTS `ld_port_cable` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT '',
  `module` varchar(255) DEFAULT '',
  `crm_id` int(19) not null ,
  `port_id` int(19) not null ,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;
-- 2018-06-25

DROP PROCEDURE IF EXISTS `rest_kehu001_caidan`;
delimiter ||
CREATE PROCEDURE `rest_kehu001_caidan`(
)
begin
	
	IF DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' THEN

		UPDATE ld_tab SET presence=0 WHERE `name` IN ('CashBill');

		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Service');
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parenttabid,(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),20000 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill'))
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=57);

		SET @i=0;
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid 
			ORDER BY FIELD(tabid,
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts'),
				(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge'),
				(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn'),
				(SELECT tabid FROM ld_tab WHERE `name`='Products'),
				(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork')
			),sequence;


		SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Service' AND systemdefault='yes' LIMIT 1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),20000 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill'))
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=57);

		SET @i=0;
		UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid 
			ORDER BY FIELD(tabid,
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge'),
				(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk'),
				(SELECT tabid FROM ld_tab WHERE `name`='Faq'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts'),
				(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),
				(SELECT tabid FROM ld_tab WHERE `name`='Products'),
				(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork')
			),sequence;

	END IF;

end ||
delimiter;

CALL rest_kehu001_caidan();
DROP PROCEDURE IF EXISTS `rest_kehu001_caidan`;

update ld_desk set fieldlabel='不支持wps格式' where labelbol='wpsformatisnotsupported' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='wps format is not supported' where labelbol='wpsformatisnotsupported' and languagetype='en' and Labeltype='fixedstr';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HOWEVERINPORTWPS','（但是，可以在WPS中编辑后另存为*.xls格式再导入）','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'HOWEVERINPORTWPS' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HOWEVERINPORTWPS','(however, you can save it as *.xls format after editing in WPS and import it again)','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'HOWEVERINPORTWPS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

select usereportid into @usereportid from ld_usereport where name='SalesOrderTrack';
delete from ld_usereportcolumns   where usereportid=@usereportid and columns like '%ld_salesorder:stockpresence:stockpresence:salesorder%' 
and not  EXISTS(select * from ld_tab  where  presence in(0,2,5));
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Thisparametercanonlybeselectedasamemberofthehighseas','该参数只能选择公海成员','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Thisparametercanonlybeselectedasamemberofthehighseas' and labeltype=  'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Thisparametercanonlybeselectedasamemberofthehighseas','This parameter can only be selected as a member of the high seas','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Thisparametercanonlybeselectedasamemberofthehighseas' and labeltype=  'fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BACKPREVLEVEL','返回上一级','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BACKPREVLEVEL' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BACKPREVLEVEL','返回上一级','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BACKPREVLEVEL' and labeltype='fixedstr');
delimiter;
-- 2018-06-26

UPDATE ld_field SET presence=1 WHERE tabid=29 AND columnname IN ('approvestatus','approveby') AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
UPDATE ld_field SET presence=2 WHERE tabid=6 AND columnname='rating' AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
-- 2018-06-27

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THISDEPENDENCYALREADYEXISTS','该依赖项已经存在','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'THISDEPENDENCYALREADYEXISTS' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THISDEPENDENCYALREADYEXISTS','This dependency already exists','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'THISDEPENDENCYALREADYEXISTS' and languagetype='en' and labeltype = 'jspop');
delimiter;

update  ld_desk set fieldlabel='天数必须输入大于等于1的整数！' 
where labelbol='DAYSMUSTGREATERQUZERO' and labeltype='jspop' and languagetype='zh';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IMPORTRECORDDETAILTIP','其中成功导入%d条明细，失败%d条明细','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='IMPORTRECORDDETAILTIP' and languagetype='zh' and fieldlabel='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','IMPORTRECORDDETAILTIP','The successful introduction of %d details and failure %d details ','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='IMPORTRECORDDETAILTIP' and languagetype='en' and fieldlabel='fixedstr');
delimiter;


update ld_desk set fieldlabel='启用公海{$Accounts.Accounts}' where labeltype='fixedstr' and labelbol='ACTIVATEPUBLICCUST' and languagetype='zh' ;
update ld_desk set fieldlabel='Activate {$Accounts.Accounts}' where labeltype='fixedstr' and labelbol='ACTIVATEPUBLICCUST' and languagetype='en' ;
delimiter;

update ld_desk set fieldlabel='公海未分配{$Accounts.Accounts}不允许领取（只能由公海管理员分配）' where labeltype='fixedstr' and labelbol='UNALLOCATECUSTOMERADMIN'
and languagetype='zh' ;
update ld_desk set fieldlabel='No distribution of the high seas not allowed to obtain(Only can be  distributed by administrators)' where labeltype='fixedstr' and labelbol='UNALLOCATECUSTOMERADMIN'
and languagetype='en' ;
delimiter;

update ld_desk set fieldlabel='公海未分配{$Accounts.Accounts}不控制数据权限（可查询所有公海未分配{$Accounts.Accounts}）' where labeltype='fixedstr' and labelbol='CUSTOMERCONTROLPUBLIC'
and languagetype='zh' ;
update ld_desk set fieldlabel='The high seas not assigned customers do not control data access(Can query all unallocated customer high seas)' where labeltype='fixedstr' and labelbol='CUSTOMERCONTROLPUBLIC'
and languagetype='en' ;
delimiter;

update ld_desk set fieldlabel='公海成员{$Accounts.Accounts}序时簿“全部”页签是否显示公海{$Accounts.Accounts}' 
where labeltype='fixedstr' and labelbol='WEHERTODISPLAYTHEPUBLICCUSTOMERES' and languagetype='zh' ;
update ld_desk set fieldlabel='Does the "all" page sign of the members of the open sea show the high Seas customers?' 
where labeltype='fixedstr' and labelbol='WEHERTODISPLAYTHEPUBLICCUSTOMERES'
and languagetype='en' ;
delimiter;

update ld_desk set fieldlabel='公海成员{$Accounts.Accounts}序时簿“新建”功能下拉选项' 
where labeltype='fixedstr' and labelbol='NEWBUTTONDROP-DOWNOPTIONS' and languagetype='zh' ;
update ld_desk set fieldlabel='The new member function drop-down button option is in the order of the high seas members' 
where labeltype='fixedstr' and labelbol='NEWBUTTONDROP-DOWNOPTIONS'
and languagetype='en' ;
delimiter;

update ld_desk set fieldlabel='公海{$Accounts.Accounts}数量上限' 
where labeltype='fixedstr' and labelbol='maximumnumberofhighseascustomers' and languagetype='zh' ;
update ld_desk set fieldlabel='The maximum number of {$Accounts.Accounts}' 
where labeltype='fixedstr' and labelbol='maximumnumberofhighseascustomers'
and languagetype='en' ;
delimiter;


update ld_desk set fieldlabel='公海成员快速创建{$Accounts.Accounts}默认的{$Accounts.Accounts}公海状态' 
where labeltype='fixedstr' and labelbol='quicklycreatedefaultaccount' and languagetype='zh' ;
update ld_desk set fieldlabel="The members of the high seas quickly create the {$Accounts.Accounts} default state of the high seas" 
where labeltype='fixedstr' and labelbol='quicklycreatedefaultaccount'
and languagetype='en' ;
delimiter;


update ld_desk set fieldlabel='普通{$Accounts.Accounts}转为公海后，更改{$Accounts.Accounts}负责人为（为空表示不更改）' 
where labeltype='fixedstr' and labelbol='AFTERCONVERTINGMODIFYTHEOWNER' and languagetype='zh' ;
update ld_desk set fieldlabel="After converting common {$Accounts.Accounts} to the hign seas {$Accounts.Accounts} ,modify the owner as(do nothing if empty)" 
where labeltype='fixedstr' and labelbol='AFTERCONVERTINGMODIFYTHEOWNER'
and languagetype='en' ;
delimiter;

update ld_desk set fieldlabel='转为公海{$Accounts.Accounts}' 
where labeltype='fixedstr' and labelbol='CONVERTEDHIGHSEASCUST' and languagetype='zh' ;
delimiter;

update ld_desk set fieldlabel='转为普通{$Accounts.Accounts}' 
where labeltype='fixedstr' and labelbol='CONVERTEDORDINARYCUST' and languagetype='zh' ;
delimiter;

update ld_desk set fieldlabel='公海{$Accounts.Accounts}管理员具有分配公海{$Accounts.Accounts}、转换公海{$Accounts.Accounts}、延长公海{$Accounts.Accounts}期限等权限' 
where labeltype='fixedstr' and labelbol='EXTENDPUBLICCUSTOMER' and languagetype='zh' ;
delimiter;

update ld_desk set fieldlabel='公海成员可以在{$Accounts.Accounts}序时簿看到公海{$Accounts.Accounts}、领取公海{$Accounts.Accounts}' 
where labeltype='fixedstr' and labelbol='USERSPUBLICCUSTOMER' and languagetype='zh' ;
delimiter;

update ld_desk set fieldlabel='公海{$Accounts.Accounts}是一种压力型销售管理工具' 
where labeltype='fixedstr' and labelbol='PRESSCUSTOMER' and languagetype='zh' ;
delimiter;

update ld_desk set fieldlabel='将公海{$Accounts.Accounts}领取或分配给某些销售，每个销售只能拥有一定数量内的公海{$Accounts.Accounts}，且在期限内必须达成设定的条件，否则{$Accounts.Accounts}就会自动回归公海重新分配给其他销售。' 
where labeltype='fixedstr' and labelbol='CUSTOMERSALESFULFILLED' and languagetype='zh' ;
delimiter;

update ld_desk set fieldlabel = '适用范围选择的人员可使用该审批流程' where languagetype = 'zh' and labelbol = 'DOCSELECTROLEAPPROVAL' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'The approval process can be used by the person choosing the scope of application.' where languagetype = 'en' and labelbol = 'DOCSELECTROLEAPPROVAL' and Labeltype = 'fixedstr';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','onlyacontractwithmorethan','只显示应收款大于0的合同','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'onlyacontractwithmorethan' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','onlyacontractwithmorethan',' Only a contract with more than 0 receivables ','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'onlyacontractwithmorethan' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

select fieldid into @trigger_fieldid from ld_field where tabid = 22 and columnname = 'potentialid';
select fieldid into @effect_fieldid from ld_field where tabid = 22 and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','contactid' from dual
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Documents';
insert into ld_picklist_set(listname,relatetable)
select 'folderid','ld_field' from DUAL
where not exists(select 1 from ld_picklist_set where listname = 'folderid' and relatetable = 'ld_field');
select listid into @listid from ld_picklist_set where listname = 'folderid' and relatetable = 'ld_field';
delete from ld_picklist_values where listid = @listid;
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,foldername,sequence from ld_attachmentsfolder ORDER BY sequence;
update ld_field set uitype = 15 where tabid = @tabid and columnname = 'folderid';
alter table ld_notes modify column folderid VARCHAR(100);
update ld_notes inner JOIN ld_attachmentsfolder on ld_attachmentsfolder.folderid = ld_notes.folderid
set ld_notes.folderid = ld_attachmentsfolder.foldername;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
select max(sequence) into @sequence from ld_blocks where tabid = @tabid;
select max(blockid) into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,display_status,iscustom)
select @max_blockid+1,@tabid,'附件信息',@sequence+1,1,0 from DUAL
where not exists(select 1 from ld_blocks where blocklabel = '附件信息' and tabid = @tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = '附件信息';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @blockid and languagetype = 'zh' and trantable = 'ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachment info' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @blockid and languagetype = 'en' and trantable = 'ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = '附件信息' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'filename','yes','ld_attachments',1,1109,'filename','附件',1,2,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'filename');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'filename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,' 附件' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Attachment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SAMENUMBEROFCOPIES','相同份数','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='SAMENUMBEROFCOPIES' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SAMENUMBEROFCOPIES','The same number of copies','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='SAMENUMBEROFCOPIES' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NUMBEROFDIFFERENT','不同份数','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='NUMBEROFDIFFERENT' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NUMBEROFDIFFERENT','A number of different','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='NUMBEROFDIFFERENT' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NUMBEROFCOPIES','套餐份数','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='NUMBEROFCOPIES' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NUMBEROFCOPIES','Set the number of copies','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='NUMBEROFCOPIES' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','PRODUCTPACKAGE','产品套餐','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='PRODUCTPACKAGE' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','PRODUCTPACKAGE','Product Package','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='PRODUCTPACKAGE' and labeltype='jspop');
delimiter;

update ld_desk set fieldlabel='普通{$Accounts.Accounts}' 
where labeltype='fixedstr' and labelbol='COMMONACCOUNT' and languagetype='zh' ;
delimiter;

update ld_desk set fieldlabel='设置公海{$Accounts.Accounts}管理参数' 
where labeltype='fixedstr' and labelbol='LBL_ACCOUNT_SET_DESCRIPTION' and languagetype='zh' ;
delimiter;

update ld_desk set fieldlabel='普通{$Accounts.Accounts}参与回收，自动回收规则' 
where labeltype='fixedstr' and labelbol='REGULARCUSTOMERRECOVERYRULE' and languagetype='zh' ;
delimiter;
-- 2018-07-02

select tabid into @tabid from ld_tab where name='Documents';
update ld_field set allowhide='yes' where columnname='folderid' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='accounts';
update ld_field set allowhide='no' where columnname='lastname' and tabid=6;
delimiter;

update ld_desk set fieldlabel ='自动查重合并' where labelbol='CHECKMERGE' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel ='Automatic weight checking and merging'
where labelbol='CHECKMERGE' and Labeltype='fixedstr' and languagetype='en';

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','DUPLICATECHECKREMIND','请选择匹配字段（选择多个字段时为且的关系）','fixedstr' from dual where
not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DUPLICATECHECKREMIND' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
select 'en','DUPLICATECHECKREMIND','Please select the match field（The relationship between multiple fields）','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DUPLICATECHECKREMIND' and Labeltype='fixedstr');

select sequence into @sequence from ld_systems_deploy where deploy_type=59;
update ld_systems_deploy set sequence=sequence+1 where sequence>@sequence and roottype=1;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select '',161,'设置服务合同新增保存后更新客户的客户状态字段',@sequence+1,1,'select',0,'[{"value":"rating","text":"rating"},{"field":"rating","type":"picklist","relatetable":"ld_field"},{"relatedmodule":"SalesOrder,Accounts"},{"isSelectValue":"yes"}]'
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=161);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',161,161,'设置{$ServiceContracts.ServiceContracts}新增保存后是否更新{$Accounts.Accounts}的{$Accounts.rating}字段为（为空表示不更新）'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=161 and Relateid=161 and trantable='ld_systems_deploy' and  languagetype='zh');
 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',161,161,'{$Accounts.Accounts} updated when {$ServiceContracts.ServiceContracts} Added save {$Accounts.rating} is (blank means no update)'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=161 and Relateid=161 and trantable='ld_systems_deploy' and  languagetype='en');
delimiter;
-- 2018-07-06

SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
UPDATE ld_customreport_info SET sequence=sequence+10 WHERE folder_id=@id;

SET @report_name='工作汇报日志统计表';
SET @report_type='template';
SET @report_template='default_workreport_daily.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @sequence=1;
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);

SET @report_name='工作汇报周计划统计表';
SET @report_type='template';
SET @report_template='default_workreport_weekly.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SET @sequence=2;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);

SET @report_name='工作汇报月计划统计表';
SET @report_type='template';
SET @report_template='default_workreport_monthly.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SET @sequence=3;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);

SET @i=0;
UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@id ORDER BY sequence;
delimiter;

SET @i=0;
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
UPDATE ld_customreport_info SET sequence=sequence+10 WHERE folder_id=@id;
UPDATE ld_customreport_info SET sequence=1,setype='CooperativeWork' WHERE folder_id=@id AND report_template='default_workreport_daily.mrt';
UPDATE ld_customreport_info SET sequence=2,setype='CooperativeWork' WHERE folder_id=@id AND report_template='default_workreport_weekly.mrt';
UPDATE ld_customreport_info SET sequence=3,setype='CooperativeWork' WHERE folder_id=@id AND report_template='default_workreport_monthly.mrt';
UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@id ORDER BY sequence;
delimiter;
-- 2018-07-06

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
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.4.3',current_version='V7.4.3',remark='V7.4.3-20180706',wx_version='V7.4.3';
delimiter;