SET @my_presence=1;
SET @my_tabid=37;
SET @my_relmodule='OutboundOrder';
SET @my_reltabid=(SELECT tabid FROM ld_tab WHERE `name`=@my_relmodule LIMIT 1);
SET @my_seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@my_tabid);
SET @my_actions='add';
SET @my_reltype='entitytype_datacategory_sql';
SET @my_relcoltable='tmpsourcedetail.id';
SET @my_buttonstatus='yes';


SET @my_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,buttonstatus)
SELECT @my_id+1,@my_tabid,@my_reltabid,CONCAT('get_',LOWER(@my_relmodule)),@my_seq,@my_relmodule,@my_presence,@my_actions,0,4,@my_reltype,@my_relcoltable,0,@my_buttonstatus FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@my_tabid AND related_tabid=@my_reltabid);

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

SET @my_scnt=(SELECT COUNT(1) FROM ld_servicecontracts);
update ld_servicecontracts set service_units=(select count(1) from ld_troubletickets 
where servicecontractsid=ld_servicecontracts.servicecontractsid and deleted=0 and IFNULL(approvestatus,'')<>'已拒绝')
where not exists (select 1 from ld_field where tabid=6 and columnname='service_units')
	AND @my_scnt<1000;
delimiter;



select tabid into @tabid from ld_tab where name='cashbill';

update ld_field  set displaytype=2,presence=2,bigtype='translatefield',uitype=1,allowhide='no' where tabid=@tabid and columnname='cashtype';
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CreateCashBill','收款','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CreateCashBill' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CreateCashBill','Actual receipts','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CreateCashBill' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CreateDebuction','预收','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CreateDebuction' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CreateDebuction','Collect in advance','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CreateDebuction' and labeltype='fixedstr');
delimiter;

alter table ld_cashbill alter cashtype set default 'cashbill';
delimiter;

SET @disable_triggers=1;
update ld_cashbill set cashtype='cashbill' where cashtype is null or cashtype='';
SET @disable_triggers=NULL;
delimiter;


CREATE TABLE if not exists `ld_translatefield` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `columnname` varchar(50) DEFAULT NULL,
	`column_Dbvalue` varchar(100) DEFAULT NULL,
  `module` varchar(50) DEFAULT NULL,
  `labelbol` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'cashtype','CashBill','cashbill','CreateCashBill' from dual 
where not exists(select 1 from ld_translatefield where module='CashBill' and columnname='cashtype' and column_Dbvalue='cashbill');
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'cashtype','CashBill','debuction','CreateDebuction' from dual 
where not exists(select 1 from ld_translatefield where module='CashBill' and columnname='cashtype' and column_Dbvalue='debuction');
delimiter;

update ld_tranlabel 
INNER JOIN ld_field on ld_field.fieldid=ld_tranlabel.relateid
and ld_tranlabel.trantable='ld_field'
INNER JOIN ld_tab on ld_tab.tabid=ld_field.tabid
set ld_tranlabel.fieldlabel='实际收款金额'
where ld_tab.name='cashbill' and ld_field.columnname='total' and ld_tranlabel.languagetype='zh' ;
delimiter;
update ld_tranlabel 
INNER JOIN ld_field on ld_field.fieldid=ld_tranlabel.relateid
and ld_tranlabel.trantable='ld_field'
INNER JOIN ld_tab on ld_tab.tabid=ld_field.tabid
set ld_tranlabel.fieldlabel='Actual Receipts'
where ld_tab.name='cashbill' and ld_field.columnname='total' and ld_tranlabel.languagetype='en' ;

delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'ActualReceipts','实际收款金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ActualReceipts' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'ActualReceipts','Actual Receipts','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ActualReceipts' and labeltype='fixedstr');
delimiter;

CALl AddColumn('ld_cashbill','debuctionamount','decimal','20','0');
delimiter;

CALl AddColumn('ld_cashbill','debuctionbalanceamount','decimal','20','0');
delimiter;

alter table ld_cashbill  modify column debuctionamount decimal(22,8);
delimiter;
alter table ld_cashbill  modify column debuctionbalanceamount decimal(22,8);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'DeductedAmount','本次抵扣金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DeductedAmount' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'DeductedAmount','deducted amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DeductedAmount' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CanDeductibleAmount','可抵扣金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CanDeductibleAmount' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CanDeductibleAmount','can deductible amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CanDeductibleAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'UsedAmount','核销金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UsedAmount' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'UsedAmount','Used Amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UsedAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'AvailableAmount','余额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AvailableAmount' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'AvailableAmount','Available Amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AvailableAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'UsedAmountHistory','核销记录','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UsedAmountHistory' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'UsedAmountHistory','Used Amount Detail','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UsedAmountHistory' and labeltype='fixedstr');
delimiter;

CREATE TABLE if not exists `ld_cashbilldebuctiondetail` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `cashbillid` int(19) DEFAULT NULL,
	`debuctionid` int(19) DEFAULT NULL,
	`amount` decimal(22,8) default 0,
  `userid` int(11) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @modulename='CashBill';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='cashbill_no' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='cashbill_no' LIMIT 1);
SET @columnname='debuctionamount';
SET @fieldname='debuctionamount';
SET @zh='已核销金额';
SET @en='Used Amount';
SET @uitype=72;
SET @typeofdata='N~O~22,2';
SET @quickcreate=0;
SET @displaytype=2;

INSERT INTO ld_field
(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);


set @relateid=(select fieldid from ld_field where tabid=@tabid and columnname=@columnname);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field' ,@tabid,@relateid,@zh from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='zh' and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field' ,@tabid,@relateid,@en from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='en' and trantable='ld_field');

SET @columnname='debuctionbalanceamount';
SET @fieldname='debuctionbalanceamount';
SET @zh='余额';
SET @en='Available Amount';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);

INSERT INTO ld_field
(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

set @relateid=(select fieldid from ld_field where tabid=@tabid and columnname=@columnname);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field' ,@tabid,@relateid,@zh from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='zh' and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field' ,@tabid,@relateid,@en from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='en' and trantable='ld_field');
delimiter;


UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
delimiter;


CALL getallprofile('CashBill');
CALL fieldprofile('CashBill');
delimiter;
-- 2020-04-21

DROP PROCEDURE IF EXISTS `ldcrm_add_email`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_email`(
	tmp_subject text,
	tmp_content text,
	tmp_toemail text,
	tmp_sendtime datetime,
	tmp_sender int(19)
)
BEGIN
	
		IF LENGTH(tmp_toemail)>5 THEN 

			SET @tmpcrmid=(SELECT MAX(crmid) FROM ld_crmentity);
			
			INSERT INTO ld_crmentity(crmid,setype) SELECT @tmpcrmid+1,'Emails';

			UPDATE ld_crmentity_seq SET id=(SELECT max(crmid) FROM ld_crmentity); 

			INSERT INTO ld_activity(activityid,`subject`,description,to_email,date_start,smownerid,smcreatorid,activitytype,visibility,deleted)
			SELECT @tmpcrmid+1,tmp_subject,tmp_content,tmp_toemail,tmp_sendtime,tmp_sender,tmp_sender,'Emails','公共',0;
			
			INSERT INTO ld_activitycf(activityid) SELECT @tmpcrmid+1;

			INSERT INTO ld_activity_reminder(activity_id,email_remind)
			SELECT @tmpcrmid+1,tmp_sendtime;

		END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_email_cc`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_email_cc`(
	tmp_subject text,
	tmp_content text,
	tmp_toemail text,
	tmp_ccemail text,
	tmp_sendtime datetime,
	tmp_sender int(19)
)
BEGIN
	
		IF LENGTH(tmp_toemail)>5 THEN 

			SET @tmpcrmid=(SELECT MAX(crmid) FROM ld_crmentity);
			
			INSERT INTO ld_crmentity(crmid,setype) SELECT @tmpcrmid+1,'Emails';

			UPDATE ld_crmentity_seq SET id=(SELECT max(crmid) FROM ld_crmentity); 

			INSERT INTO ld_activity(activityid,`subject`,description,to_email,cc_email,date_start,smownerid,smcreatorid,activitytype,visibility,deleted)
			SELECT @tmpcrmid+1,tmp_subject,tmp_content,tmp_toemail,tmp_ccemail,tmp_sendtime,tmp_sender,tmp_sender,'Emails','公共',0;
			
			INSERT INTO ld_activitycf(activityid) SELECT @tmpcrmid+1;

			INSERT INTO ld_activity_reminder(activity_id,email_remind)
			SELECT @tmpcrmid+1,tmp_sendtime;
			
		END IF;

end ||
delimiter;


UPDATE ld_warehouse SET started=0 WHERE id IN (2,3,4) AND `name` IN ('总仓','赠品仓','其他仓');

DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200421`;
delimiter ||
CREATE  PROCEDURE `reset_newdemoaccount_20200421`(
)
BEGIN

	SET @my_tabid=(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder');

	SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='OutboundOrder' AND viewname='All' LIMIT 1);
	IF NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@my_cvid) THEN
		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:out_no:out_no:OutboundOrder_fieldlabel:Array',0,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:accountid:account_id:OutboundOrder_fieldlabel:I',1,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:wareid:wareid:OutboundOrder_fieldlabel:V',2,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:D',3,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:presence:presence:OutboundOrder_fieldlabel:V',4,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V',5,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:subsmownerid:subsmownerid:OutboundOrder_fieldlabel:Array',6,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_products:productname:productname:Products_fieldlabel:V',7,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorderdetail:quantity:quantity:Products_fieldlabel:N',8,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorderdetail:entitytypeid:entitytypeid:Products_fieldlabel:V',9,@my_cvid;
	END IF;


	SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='OutboundOrder' AND viewname='未出库');
	IF NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@my_cvid) THEN
		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:out_no:out_no:OutboundOrder_fieldlabel:Array',0,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:accountid:account_id:OutboundOrder_fieldlabel:I',1,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:wareid:wareid:OutboundOrder_fieldlabel:V',2,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:D',3,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:presence:presence:OutboundOrder_fieldlabel:V',4,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V',5,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:subsmownerid:subsmownerid:OutboundOrder_fieldlabel:Array',6,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_products:productname:productname:Products_fieldlabel:V',7,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorderdetail:quantity:quantity:Products_fieldlabel:N',8,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorderdetail:entitytypeid:entitytypeid:Products_fieldlabel:V',9,@my_cvid;
	END IF;

	SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='OutboundOrder' AND viewname='已出库');
	IF NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@my_cvid) THEN
		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:out_no:out_no:OutboundOrder_fieldlabel:Array',0,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:accountid:account_id:OutboundOrder_fieldlabel:I',1,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:wareid:wareid:OutboundOrder_fieldlabel:V',2,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:D',3,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:presence:presence:OutboundOrder_fieldlabel:V',4,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V',5,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorder:subsmownerid:subsmownerid:OutboundOrder_fieldlabel:Array',6,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_products:productname:productname:Products_fieldlabel:V',7,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorderdetail:quantity:quantity:Products_fieldlabel:N',8,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_outboundorderdetail:entitytypeid:entitytypeid:Products_fieldlabel:V',9,@my_cvid;
	END IF;


	SET @my_tabid=21;
	SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='PurchaseOrder' AND viewname='All' LIMIT 1);
	IF NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@my_cvid) THEN
		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_fieldlabel:V',0,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:subject:subject:PurchaseOrder_fieldlabel:V',1,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_fieldlabel:I',2,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:contactid:contact_id:PurchaseOrder_fieldlabel:I',3,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D',4,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_fieldlabel:N',5,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:postatus:postatus:PurchaseOrder_fieldlabel:V',6,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V',7,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_products:productname:productname:Products_fieldlabel:V',8,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorderdetail:quantity:quantity:Products_fieldlabel:N',9,@my_cvid;
	END IF;

	SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='PurchaseOrder' AND viewname='已作废' LIMIT 1);
	IF NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@my_cvid) THEN
		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_fieldlabel:V',0,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:subject:subject:PurchaseOrder_fieldlabel:V',1,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_fieldlabel:I',2,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:contactid:contact_id:PurchaseOrder_fieldlabel:I',3,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D',4,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_fieldlabel:N',5,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:postatus:postatus:PurchaseOrder_fieldlabel:V',6,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V',7,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_products:productname:productname:Products_fieldlabel:V',8,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorderdetail:quantity:quantity:Products_fieldlabel:N',9,@my_cvid;
	END IF;

	SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='PurchaseOrder' AND viewname='已审批' LIMIT 1);
	IF NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@my_cvid) THEN
		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_fieldlabel:V',0,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:subject:subject:PurchaseOrder_fieldlabel:V',1,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_fieldlabel:I',2,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:contactid:contact_id:PurchaseOrder_fieldlabel:I',3,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D',4,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_fieldlabel:N',5,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:postatus:postatus:PurchaseOrder_fieldlabel:V',6,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V',7,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_products:productname:productname:Products_fieldlabel:V',8,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorderdetail:quantity:quantity:Products_fieldlabel:N',9,@my_cvid;
	END IF;

	SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='PurchaseOrder' AND viewname='未审批' LIMIT 1);
	IF NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@my_cvid) THEN
		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_fieldlabel:V',0,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:subject:subject:PurchaseOrder_fieldlabel:V',1,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_fieldlabel:I',2,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:contactid:contact_id:PurchaseOrder_fieldlabel:I',3,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D',4,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_fieldlabel:N',5,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:postatus:postatus:PurchaseOrder_fieldlabel:V',6,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V',7,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_products:productname:productname:Products_fieldlabel:V',8,@my_cvid;

		INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
		SELECT @my_tabid,'ld_purchaseorderdetail:quantity:quantity:Products_fieldlabel:N',9,@my_cvid;
	END IF;

end ||
delimiter;

CALL reset_newdemoaccount_20200421(); 
DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200421`;

UPDATE ld_blockdisplay SET is_display=1 WHERE NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
DELETE FROM ld_settings_field WHERE `name`='LBL_ACCOUNTS_CONTACTS_FIELDS' AND EXISTS (SELECT 1 FROM ld_blockdisplay WHERE is_display=1);

UPDATE ld_entityname SET fieldname='quote_no' WHERE tabid=20 AND fieldname='subject' 
	AND EXISTS (SELECT 1 FROM ld_field WHERE tabid=20 AND columnname='subject' AND presence=1);

UPDATE ld_entityname SET fieldname='purchaseorder_no' WHERE tabid=21 AND fieldname='subject' 
	AND EXISTS (SELECT 1 FROM ld_field WHERE tabid=21 AND columnname='subject' AND presence=1);
    
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHMORE','更多搜索','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SEARCHMORE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHMORE','Search more','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SEARCHMORE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOADINGNEW','正在加载...','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LOADINGNEW' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOADINGNEW','Loading...','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='LOADINGNEW' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='Not submitted' where labelbol='Unapproved' and labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='View Range Senior' where labelbol='VIEWRANGESENIOR' and labeltype='jspop' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWPICKLIST','新增下拉框','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NEWPICKLIST' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWPICKLIST','New the drop-down box','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NEWPICKLIST' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITPICKLIST','编辑下拉框','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EDITPICKLIST' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITPICKLIST','Edit the drop-down box','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='EDITPICKLIST' and Labeltype='fixedstr');
delimiter;

alter table `ld_sendcashbill` alter currency_id set default 1;
alter table `ld_sendcashbill` alter conversion_rate set default 1;
alter table `ld_sendcashbill` alter currency_symbol set default '¥';

UPDATE ld_sendcashbill SET currency_id=1,conversion_rate=1,currency_symbol='¥' WHERE IFNULL(currency_id,0) IN (0,'');

UPDATE ld_bankaccountset a
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.Total) AS Total
	FROM ld_cashbill a
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
			CASE
				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=83 AND deploy_value=0) THEN 1=1
				ELSE a.approvestatus='已批准'
			END)
	GROUP BY a.bankaccountsetid
) s1 ON a.Bankaccountsetid=s1.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.Total) AS Total
	FROM ld_sendcashbill a
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
			CASE
				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=84 AND deploy_value=0) THEN 1=1
				ELSE a.approvestatus='已批准'
			END)
	GROUP BY a.bankaccountsetid
) z1 ON a.Bankaccountsetid=z1.bankaccountsetid
LEFT JOIN (
	SELECT
		a.inaccount,
		SUM(a.cashmoney) AS total
	FROM ld_cashdeposit a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.inaccount
) s2 ON a.Bankaccountsetid=s2.inaccount
LEFT JOIN (
	SELECT
		a.Outaccount,
		SUM(a.cashmoney) AS total
	FROM ld_cashdeposit a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.Outaccount
) z2 ON a.Bankaccountsetid=z2.Outaccount
LEFT JOIN (
	SELECT
		a.inaccount,
		SUM(a.cashmoney) AS total
	FROM ld_putcash a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.inaccount
) s3 ON a.Bankaccountsetid=s3.inaccount
LEFT JOIN (
	SELECT
		a.Outaccount,
		SUM(a.cashmoney) AS total
	FROM ld_putcash a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.Outaccount
) z3 ON a.Bankaccountsetid=z3.Outaccount
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_purchasecashback a
	WHERE a.deleted=0
	GROUP BY a.bankaccountsetid
) s4 ON a.Bankaccountsetid=s4.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_cashback a
	WHERE a.deleted=0
	GROUP BY a.bankaccountsetid
) z4 ON a.Bankaccountsetid=z4.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_expense a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.bankaccountsetid
) z5 ON a.Bankaccountsetid=z5.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_commission a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.bankaccountsetid
) z6 ON a.Bankaccountsetid=z6.bankaccountsetid
SET a.curbalancemoney=IFNULL(a.InitMoney,0)+IFNULL(s1.Total,0)+IFNULL(s2.Total,0)+IFNULL(s3.Total,0)+IFNULL(s4.Total,0)-IFNULL(z1.Total,0)-IFNULL(z2.Total,0)-IFNULL(z3.Total,0)-IFNULL(z4.Total,0)-IFNULL(z5.Total,0)-IFNULL(z6.Total,0);
delimiter;
-- 2020-04-22

UPDATE ld_field SET datarang='permit' WHERE columnname='pricebooksid' AND datarang IS NULL;

DROP PROCEDURE IF EXISTS `reset_demoaccount_20200423`;
delimiter ||
CREATE  PROCEDURE `reset_demoaccount_20200423`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE trade='finance') AND (SELECT COUNT(id) FROM ld_option_module)<5 THEN
		DELETE FROM ld_option_module;
		INSERT INTO `ld_option_module` VALUES ('1', '67', '2', '0', '0', '0', '3', '88', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('2', '67', '22', '0', '0', '0', '1', '88', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('3', '67', '37', '0', '0', '0', '2', '88', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('4', '67', '13', '0', '0', '0', '4', '88', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('5', '67', '48', '0', '0', '0', '5', '88', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('6', '67', '47', '0', '0', '0', '6', '88', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('7', '94', '22', '0', '0', '0', '1', '87', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('8', '94', '37', '0', '0', '0', '2', '87', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('9', '122', '48', '0', '1', '0', '1', '59', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('10', '23', '22', '0', '1', '0', '1', '69', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('11', '23', '37', '0', '0', '0', '2', '69', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('12', '23', '70', '0', '0', '0', '3', '69', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('13', '103', '21', '0', '1', '0', '1', '71', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('14', '103', '71', '0', '0', '0', '2', '71', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('15', '65', '22', '0', '0', '0', '1', '73', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('16', '65', '37', '0', '0', '0', '2', '73', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('17', '65', '23', '0', '0', '0', '3', '73', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('18', '65', '64', '0', '0', '0', '4', '73', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('19', '65', '70', '0', '0', '0', '5', '73', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('20', '80', '21', '0', '1', '0', '1', '74', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('21', '80', '103', '0', '0', '0', '2', '74', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('22', '80', '71', '0', '0', '0', '2', '74', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('23', '80', '79', '0', '0', '0', '2', '74', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('24', '70', '22', '0', '1', '0', '1', '62', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('25', '70', '37', '0', '0', '0', '2', '62', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('26', '70', '23', '0', '0', '0', '3', '62', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('27', '71', '21', '0', '1', '0', '1', '63', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('28', '71', '103', '0', '0', '0', '2', '63', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('29', '70', '71', '0', '0', '0', '4', '62', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('30', '64', '22', '0', '1', '0', '1', '77', 'permit', 'entitytypeid', '5');
		INSERT INTO `ld_option_module` VALUES ('31', '64', '37', '0', '0', '0', '2', '77', 'permit', 'entitytypeid', '5');
		INSERT INTO `ld_option_module` VALUES ('32', '64', '23', '0', '0', '0', '3', '77', 'all', 'entitytypeid', '5');
		INSERT INTO `ld_option_module` VALUES ('33', '79', '21', '0', '1', '0', '1', '78', 'permit', 'purchaseorder_id', '5');
		INSERT INTO `ld_option_module` VALUES ('34', '79', '103', '0', '0', '0', '2', '78', 'all', 'purchaseorder_id', '5');
		INSERT INTO `ld_option_module` VALUES ('35', '21', '22', '0', '1', '0', '1', '30', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('36', '21', '141', '0', '0', '0', '2', '30', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('37', '141', '20', '0', '1', '0', '1', '33', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('38', '141', '22', '0', '0', '0', '2', '33', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('39', '94', '2', '1', '0', '0', '3', '87', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('40', '21', '37', '1', '0', '0', '3', '30', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('41', '142', '6', '0', '1', '0', '1', '120', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('42', '142', '4', '0', '0', '0', '2', '120', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('43', '142', '55', '0', '0', '0', '3', '120', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('44', '142', '2', '0', '0', '0', '4', '120', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('45', '142', '48', '0', '0', '0', '6', '120', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('46', '142', '14', '1', '0', '0', '8', '120', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('47', '163', '22', '0', '0', '0', '1', '141', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('48', '163', '37', '0', '0', '0', '2', '141', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('49', '163', '2', '1', '0', '0', '3', '141', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('50', '164', '22', '0', '0', '0', '1', '142', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('51', '164', '37', '0', '0', '0', '2', '142', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('52', '164', '2', '1', '0', '0', '3', '142', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('53', '165', '22', '0', '0', '0', '1', '143', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('54', '165', '37', '0', '0', '0', '2', '143', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('55', '165', '2', '1', '0', '0', '3', '143', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('56', '166', '22', '0', '0', '0', '1', '144', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('57', '166', '37', '0', '0', '0', '2', '144', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('58', '166', '2', '1', '0', '0', '3', '144', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('59', '167', '22', '0', '0', '0', '1', '145', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('60', '167', '37', '0', '0', '0', '2', '145', 'permit', null, '5');
		INSERT INTO `ld_option_module` VALUES ('61', '167', '2', '1', '0', '0', '3', '145', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('132', '153', '22', '0', '1', '0', '1', '131', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('133', '153', '37', '0', '0', '0', '2', '131', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('134', '153', '21', '1', '0', '0', '3', '131', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('135', '153', '23', '1', '0', '0', '4', '131', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('136', '153', '103', '1', '0', '0', '5', '131', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('137', '153', '70', '1', '0', '0', '6', '131', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('138', '153', '71', '1', '0', '0', '7', '131', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('139', '154', '22', '0', '1', '0', '1', '132', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('140', '154', '37', '0', '0', '0', '2', '132', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('141', '154', '21', '1', '0', '0', '3', '132', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('142', '154', '23', '1', '0', '0', '4', '132', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('143', '154', '103', '1', '0', '0', '5', '132', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('144', '154', '70', '1', '0', '0', '6', '132', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('145', '154', '71', '1', '0', '0', '7', '132', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('146', '155', '22', '0', '1', '0', '1', '133', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('147', '155', '37', '0', '0', '0', '2', '133', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('148', '155', '21', '1', '0', '0', '3', '133', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('149', '155', '23', '1', '0', '0', '4', '133', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('150', '155', '103', '1', '0', '0', '5', '133', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('151', '155', '70', '1', '0', '0', '6', '133', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('152', '155', '71', '1', '0', '0', '7', '133', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('153', '156', '22', '0', '1', '0', '1', '134', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('154', '156', '37', '0', '0', '0', '2', '134', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('155', '156', '21', '1', '0', '0', '3', '134', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('156', '156', '23', '1', '0', '0', '4', '134', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('157', '156', '103', '1', '0', '0', '5', '134', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('158', '156', '70', '1', '0', '0', '6', '134', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('159', '156', '71', '1', '0', '0', '7', '134', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('160', '157', '22', '0', '1', '0', '1', '135', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('161', '157', '37', '0', '0', '0', '2', '135', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('162', '157', '21', '1', '0', '0', '3', '135', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('163', '157', '23', '1', '0', '0', '4', '135', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('164', '157', '103', '1', '0', '0', '5', '135', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('165', '157', '70', '1', '0', '0', '6', '135', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('166', '157', '71', '1', '0', '0', '7', '135', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('167', '158', '22', '0', '1', '0', '1', '136', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('168', '158', '37', '0', '0', '0', '2', '136', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('169', '158', '21', '1', '0', '0', '3', '136', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('170', '158', '23', '1', '0', '0', '4', '136', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('171', '158', '103', '1', '0', '0', '5', '136', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('172', '158', '70', '1', '0', '0', '6', '136', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('173', '158', '71', '1', '0', '0', '7', '136', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('174', '159', '22', '0', '1', '0', '1', '137', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('175', '159', '37', '0', '0', '0', '2', '137', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('176', '159', '21', '1', '0', '0', '3', '137', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('177', '159', '23', '1', '0', '0', '4', '137', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('178', '159', '103', '1', '0', '0', '5', '137', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('179', '159', '70', '1', '0', '0', '6', '137', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('180', '159', '71', '1', '0', '0', '7', '137', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('181', '160', '22', '0', '1', '0', '1', '138', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('182', '160', '37', '0', '0', '0', '2', '138', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('183', '160', '21', '1', '0', '0', '3', '138', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('184', '160', '23', '1', '0', '0', '4', '138', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('185', '160', '103', '1', '0', '0', '5', '138', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('186', '160', '70', '1', '0', '0', '6', '138', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('187', '160', '71', '1', '0', '0', '7', '138', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('188', '161', '22', '0', '1', '0', '1', '139', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('189', '161', '37', '0', '0', '0', '2', '139', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('190', '161', '21', '1', '0', '0', '3', '139', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('191', '161', '23', '1', '0', '0', '4', '139', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('192', '161', '103', '1', '0', '0', '5', '139', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('193', '161', '70', '1', '0', '0', '6', '139', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('194', '161', '71', '1', '0', '0', '7', '139', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('195', '162', '22', '0', '1', '0', '1', '140', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('196', '162', '37', '0', '0', '0', '2', '140', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('197', '162', '21', '1', '0', '0', '3', '140', 'permit', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('198', '162', '23', '1', '0', '0', '4', '140', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('199', '162', '103', '1', '0', '0', '5', '140', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('200', '162', '70', '1', '0', '0', '6', '140', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('201', '162', '71', '1', '0', '0', '7', '140', 'all', 'source_list', '5');
		INSERT INTO `ld_option_module` VALUES ('202', '142', '13', '0', '0', '0', '5', '120', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('203', '22', '20', '0', '1', '0', '1', '27', 'all', 'quote_id', '5');
		INSERT INTO `ld_option_module` VALUES ('204', '22', '139', '0', '0', '0', '2', '27', 'all', 'quote_id', '5');
		INSERT INTO `ld_option_module` VALUES ('205', '20', '141', '0', '1', '0', '1', '0', 'all', null, '20');
		INSERT INTO `ld_option_module` VALUES ('206', '67', '21', '0', '0', '0', '7', '88', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('207', '142', '26', '0', '0', '0', '7', '122', null, null, '5');
		INSERT INTO `ld_option_module` VALUES ('208', '48', '22', '0', null, '0', '1', '0', 'all', null, '5');
		INSERT INTO `ld_option_module` VALUES ('209', '48', '37', '0', '1', '0', '2', '0', 'all', null, '5');
	END IF;

end ||
delimiter;

CALL reset_demoaccount_20200423(); 
DROP PROCEDURE IF EXISTS `reset_demoaccount_20200423`;
-- 2020-04-23


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

UPDATE ld_version SET old_version='V8.0.0.8',current_version='V8.0.0.8',remark='V8.0.0.8-20200422',wx_version='V8.0.0.8';
delimiter;