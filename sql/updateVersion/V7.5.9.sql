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

delete from ld_tab where name in ('InventoryLedger','InventoryQuery','InventoryAccount');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWPWDNOTSAMEOLD','您输入的旧密码与原来的密码不一致，请重新输入！','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='NEWPWDNOTSAMEOLD');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWPWDNOTSAMEOLD','The original password you entered is inconsistent with the original password, please re-enter!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='NEWPWDNOTSAMEOLD');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'presence';
update ld_tranlabel set fieldlabel = '出库状态' where languagetype = 'zh' and tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field';
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'presence';
update ld_tranlabel set fieldlabel = 'OutboundOrder Status' where languagetype = 'en' and tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'presence';
update ld_tranlabel set fieldlabel = '入库状态' where languagetype = 'zh' and tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field';
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'presence';
update ld_tranlabel set fieldlabel = 'Stock Status' where languagetype = 'en' and tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field';
delimiter;

INSERT into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RELEASE','释放','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'RELEASE' and labeltype = 'jspop');
INSERT into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RELEASE','Release','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'RELEASE' and labeltype = 'jspop');
delimiter;

INSERT into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RELEASEACCOUNTTREASON','释放原因','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'RELEASEACCOUNTTREASON' and labeltype = 'jspop');
INSERT into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RELEASEACCOUNTTREASON','release reason','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'RELEASEACCOUNTTREASON' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel = '普通{$Accounts.Accounts}转为公海后，更改{$Accounts.Accounts}负责人为（只能选择公海成员，为空表示不更改）'
where languagetype = 'zh' and labelbol = 'AFTERCONVERTINGMODIFYTHEOWNER' and Labeltype = 'fixedstr';
delimiter;

update ld_dashboard_app set kehu001_presence=1 where name in ('daylog','weeklog','monthlog');
delimiter;

insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'CRM微信小程序二维码','zh','CRMWECHATSMALLPROGRAMTWODIMENSIONAL','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CRMWECHATSMALLPROGRAMTWODIMENSIONAL' and labeltype='fixedstr');
insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'CRM Wechat Small Program Two-Dimensional Code','en','CRMWECHATSMALLPROGRAMTWODIMENSIONAL','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CRMWECHATSMALLPROGRAMTWODIMENSIONAL' and labeltype='fixedstr');
delimiter;

insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select '下载地址','zh','DOWNLOADLINK','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOWNLOADLINK' and labeltype='fixedstr');
insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'download link','en','DOWNLOADLINK','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOWNLOADLINK' and labeltype='fixedstr');
delimiter;

insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'CRM微信小程序二维码图片，可直接用微信扫码','zh','CANBESCANNEDDIRECTLYWITHWECHAT','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' and labeltype='fixedstr');
insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'Two-dimensional code picture of CRM Wechat applet can be scanned directly with Wechat.','en','CANBESCANNEDDIRECTLYWITHWECHAT','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' and labeltype='fixedstr');
delimiter;
update ld_desk set fieldlabel='CRM外网访问地址请参照此格式' where labelbol='WECHATAPPLETSETTINGSREMIND05' and Labeltype='fixedstr' and languagetype='zh';
delimiter;
-- 2018-11-28

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select usereportid into @usereportid from ld_usereport where parent_id=0 and `name` = 'SalesReport';
select Parent_id,sequence,reporttype into @Parent_id,@sequence,@reporttype from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereport set sequence = sequence + 1000 where Parent_id = @Parent_id and sequence > @sequence;
insert into ld_usereport(`name`,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype,pagewidthpercent,presence,setype)
select 'CashBillSum_Outboundorder','应收款统计表_按{$OutboundOrder}统计',@tabid,1,1,1,@usereportid,@sequence+1,@reporttype,100,0,'OutboundOrder' from DUAL
where not exists(select 1 from ld_usereport where `name` = 'CashBillSum_Outboundorder');
set @i=0;
update ld_usereport set sequence=(@i:=@i+1) where parent_id = @usereportid order by sequence;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CashBillSum_Outboundorder',"应收款统计表_按 {$OutboundOrder.OutboundOrder}统计",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CashBillSum_Outboundorder' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CashBillSum_Outboundorder',"Statistics of Receivables Acc To  {$OutboundOrder.OutboundOrder}",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CashBillSum_Outboundorder' and Labeltype='fixedstr');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Outboundorder';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_assigned_user_id:V',1,1,'ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_销售负责人:V','ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_Assigned to:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_assigned_user_id:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:groupname:groupname:OutboundOrder_groupname:V',2,1,'ld_outboundorder:groupname:groupname:OutboundOrder_部门:V','ld_outboundorder:groupname:groupname:OutboundOrder_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:groupname:groupname:OutboundOrder_groupname:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:out_no:out_no:OutboundOrder_Out no:V',3,1,'ld_outboundorder:out_no:out_no:OutboundOrder_出库编号:V','ld_outboundorder:out_no:out_no:OutboundOrder_Out No:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:out_no:out_no:OutboundOrder_Out no:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D',4,1,'ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D','ld_outboundorder:outdate:outdate:OutboundOrder_Outdate:D' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:accountid:account_id:OutboundOrder_Account Name:I',5,1,'ld_outboundorder:accountid:account_id:OutboundOrder_出库_客户名称:I','ld_outboundorder:accountid:account_id:OutboundOrder_AccountName:I' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:accountid:account_id:OutboundOrder_Account Name:I');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:presence:presence:OutboundOrder_Status:V',6,1,'ld_outboundorder:presence:presence:OutboundOrder_出库_出库状态:V','ld_outboundorder:presence:presence:OutboundOrder_Status:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:presence:presence:OutboundOrder_Status:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_Total:N',7,1,'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_合计:N','ld_outboundorder:total:hdnGrandTotal:OutboundOrder_Total:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_Total:N');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N',8,1,'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_已收金额:N','ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBill Amount:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N',9,1,'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_应收款余额:N','ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_Payment Balance:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Outboundorder';
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D','thisstartmonth~thisendmonth',1 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D');
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_accountoutboundorder:accountname:account_id:OutboundOrder_Account Name:I','',2 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_accountoutboundorder:accountname:account_id:OutboundOrder_Account Name:I');
delimiter;

UPDATE ld_tranlabel SET fieldlabel='“库存状态”更新的触发点' WHERE trantable='ld_systems_deploy' AND languagetype='zh' AND Relateid=48;
UPDATE ld_tranlabel SET fieldlabel='update the trigger point of inventory status' WHERE trantable='ld_systems_deploy' AND languagetype='en' AND Relateid=48;
UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=48 AND NOT EXISTS (SELECT 1 FROM ld_warehouse2products);
UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type BETWEEN 171 AND 195
	AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype LIKE 'CustomForm%');
delimiter;
   
DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND Relateid IN (SELECT fieldid FROM ld_field WHERE uitype=202 AND tablename LIKE '%ld_customform%');
DELETE FROM ld_field WHERE uitype=202 AND tablename LIKE '%ld_customform%';
    
DROP PROCEDURE IF EXISTS `ldcrm_add_choosesourcebill_20181129`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_choosesourcebill_20181129`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0; 
	DECLARE tmp_moudlename VARCHAR(100) DEFAULT NULL; 

	DECLARE MYCUSOR CURSOR FOR SELECT tabid,`name` FROM ld_tab WHERE `name` LIKE 'CustomForm%' AND RIGHT(`name`,2)>=11 AND RIGHT(`name`,2)<=20;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_moudlename;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @tabid=tmp_tabid;
		SET @modulename=tmp_moudlename;
		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename='';
		SET @columnname=''; 
		SET @fieldname=''; 
		SET @zh='选择源单'; 
		SET @en='Data sources'; 
		SET @uitype=202; 
		SET @typeofdata='V~O';
		SET @quickcreate=0;
		SET @presence=2;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,1,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND uitype=@uitype); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND uitype=@uitype LIMIT 1);
		DELETE FROM ld_tranlabel WHERE trantable=@trantable AND tabid = @tabid AND relateid=@relateid;
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en;

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);

		DELETE FROM ld_option_module WHERE tabid=@tabid;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,22,0,1,0,1,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,37,0,0,0,2,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,21,1,0,0,3,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,23,1,0,0,4,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInvoice'),1,0,0,5,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder'),1,0,0,6,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,(SELECT tabid FROM ld_tab WHERE `name`='Stock'),1,0,0,7,5;
				
		FETCH MYCUSOR INTO tmp_tabid,tmp_moudlename;
	END WHILE;
	CLOSE MYCUSOR;
	
end ||
delimiter;

CALL ldcrm_add_choosesourcebill_20181129();
DROP PROCEDURE IF EXISTS `ldcrm_add_choosesourcebill_20181129`;
-- 2018-11-29

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOANORDINARYCUSTOMERERROR1','单据[%s]转为普通客户失败！原因：您不是该单据的负责人，您没有权限执行这个操作！','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TOANORDINARYCUSTOMERERROR1' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOANORDINARYCUSTOMERERROR1','Documents [%s] turned to ordinary customers failed! Reason: You are not responsible for the document, you have no authority to perform this operation!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TOANORDINARYCUSTOMERERROR1' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_approvestep','alloweditbill','varchar',50,null );
delimiter;

update ld_approvestep
INNER JOIN ld_approve  on ld_approve.id=ld_approvestep.approveid
 set alloweditbill= case when ld_approve.allowediting=1 then 'yes' else 'no' end 
where alloweditbill is null ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CURAPPROVESTEPALLOWEDIT','当前步骤审批人是否允许编辑单据','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CURAPPROVESTEPALLOWEDIT'  and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CURAPPROVESTEPALLOWEDIT','Whether the approver of the current step allows editing documents','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CURAPPROVESTEPALLOWEDIT'  and labeltype='fixedstr');
delimiter;

insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select '提醒','zh','TIXING','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TIXING' and labeltype='fixedstr');
insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'reminds','en','TIXING','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TIXING' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='是否允许编辑单据' where labelbol='CURAPPROVESTEPALLOWEDIT' and languagetype='zh' and Labeltype='fixedstr';
delimiter;

update ld_producttoolfield set uitype= 1 where columnname = 'comment' and uitype = 3;
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 10;
update ld_systems_deploy set sequence = sequence + 1000 where inputtype = @roottype and sequence > @sequence;
update ld_systems_deploy set sequence = @sequence + 2 where deploy_type = 67;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '0',198,'设置工作汇报是否允许选择日期','',@sequence+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type=198);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',198,198,'设置{$CooperativeWork.CooperativeWork}是否允许选择日期' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=198 and tabid = 198);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',198,198,' Setting the Date of {$CooperativeWork.CooperativeWork} Allowed ' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=198 and tabid = 198);
delimiter;

call AddColumn('ld_workreport','sendlog_workdate','varchar','255',null);
delimiter;

INSERT into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thelogdatecannotbegreater','日志日期不能大于当前日期','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thelogdatecannotbegreater' and labeltype = 'jspop');
INSERT into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thelogdatecannotbegreater','The log date cannot be greater than the current date','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thelogdatecannotbegreater' and labeltype = 'jspop');
delimiter;
-- 2018-11-30

UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq set id=(SELECT MAX(relation_id) FROM ld_relatedlists);
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
delimiter;

UPDATE ld_version SET old_version='V7.5.9',current_version='V7.5.9',remark='V7.5.9-20181130',wx_version='V7.5.5.5';
delimiter;