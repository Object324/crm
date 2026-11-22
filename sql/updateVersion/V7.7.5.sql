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

DROP PROCEDURE IF EXISTS `update_products_ststus1`;
delimiter ||
CREATE PROCEDURE `update_products_ststus1`(
)
begin

	declare done  int  default 0;
	declare tmpproductid int default 0;

	-- 因为不知道资产状态时哪个字段，以“备注”字段为例做说明。
	declare tmpdescription varchar(200) default null;

	-- 按照每个资产去循环更新资产的状态，如果“资产状态”是自定义字段，这个查询需要跟ld_productscf做个表连接
	declare curw CURSOR FOR SELECT productid,description FROM  ld_products;

	declare continue handler  for not   found  SET done =1;

	OPEN curw;
		Fetch curw INTO tmpproductid,tmpdescription;
		loop1: while  done<>1 DO
			
			-- 按照签约日期查询该资产最近的一个未删除、已审批的合同订单，
			SET @salesorderid=0;
			SELECT
				ld_salesorder.salesorderid INTO @salesorderid
			FROM ld_salesorder
			LEFT JOIN ld_salesorderdetail ON ld_salesorder.salesorderid=ld_salesorderdetail.id
			WHERE ld_salesorder.deleted=0 
				AND ld_salesorder.approvestatus='已批准'
				AND ld_salesorderdetail.productid=tmpproductid 
			ORDER BY ld_salesorder.signed_data DESC LIMIT 1;

			IF @salesorderid>0 THEN
			
				-- 如果该产品有销售合同，找该产品、该销售合同对应的服务合同，找服务到期日最晚的一个
				-- 需要在做服务合同的关联销售合同
				SET @service_end_date=NULL;
				SELECT
					IFNULL(ld_servicecontractsdetail.servicecontracts_end_date,'1900-01-01') INTO @service_end_date
				FROM ld_servicecontracts
				LEFT JOIN ld_servicecontractsdetail ON ld_servicecontracts.servicecontractsid=ld_servicecontractsdetail.id
				WHERE ld_servicecontracts.deleted=0 
					AND ld_servicecontractsdetail.productid=tmpproductid 
				ORDER BY ld_servicecontractsdetail.servicecontracts_end_date DESC LIMIT 1;
				
				IF @service_end_date='1900-01-01' THEN
					-- 如果没有服务合同，则更新状态为“已售”
					UPDATE ld_products SET description='已售' WHERE productid=tmpproductid;
				
				ELSEIF @service_end_date>=CURDATE() THEN
					-- 如果有服务到期日期，并且服务到期日大当前日期，则更新状态到初始状态“已租”
					UPDATE ld_products SET description='已租' WHERE productid=tmpproductid;
					
				ELSE
					-- 否则服务到期日小于当前日期，更新状态为初始状态
					UPDATE ld_products SET description='待售租' WHERE productid=tmpproductid;
				END IF;
			
			ELSE
				-- 没有合同订单，同样更新资产状态为初始状态
				UPDATE ld_products SET description='待售租' WHERE productid=tmpproductid;
			END IF;

		Fetch curw INTO tmpproductid,tmpdescription;
		end while loop1;
	close curw;
end ||
delimiter;

call AddColumn('ld_setscoperhigher','viewothers','int',11,'');
delimiter;
call AddColumn('ld_setscoperhigher','editothers','int',11,'');
delimiter;
call AddColumn('ld_setscoperhigher','delothers','int',11,'');
delimiter;
call AddColumn('ld_setscoperhigher','viewselfbills','int',11,'');
delimiter;

update ld_setscoperhigher inner join(
select ld_tab.name,ld_users.id,viewothers,editothers,delothers,viewselfbills from ld_tab,
 ld_users
where presence in(0,2) 
and ld_tab.tabid in(select tabid from ld_profileallpermission where operation=1)
and ifnull(ld_users.is_admin,'')='off'
order by ld_users.id asc) as tmptab on tmptab.name=ld_setscoperhigher.modulename
and tmptab.id=ld_setscoperhigher.userid
set ld_setscoperhigher.viewothers=tmptab.viewothers,ld_setscoperhigher.editothers=tmptab.editothers,
ld_setscoperhigher.delothers=tmptab.delothers,ld_setscoperhigher.viewselfbills=tmptab.viewselfbills
where  exists(select fieldid from ld_field where tabid=29 and presence in(0,2) and columnname='viewothers');
delimiter;

insert into ld_setscoperhigher(userid,scopeauthority,modulename,viewothers,editothers,delothers,viewselfbills)
select ld_users.id,0,ld_tab.name,viewothers,editothers,delothers,viewselfbills from ld_tab,
 ld_users
where presence in(0,2) 
and ld_tab.tabid in(select tabid from ld_profileallpermission where operation=1)
and ifnull(ld_users.is_admin,'')='off'
and ld_users.id not in(select userid from ld_setscoperhigher)
and exists(select fieldid from ld_field where tabid=29 and presence in(0,2) and columnname='viewothers');
delimiter;

delete from ld_field where tabid=29 and columnname in('viewothers','editothers','delothers','editothers','viewselfbills');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ME','自己的','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='me' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ME','Own','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='me' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BYUSERS','按成员','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='BYUSERS' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BYUSERS','Users','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='BYUSERS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BYDEPARTMENTS','按部门','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='BYDEPARTMENTS' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BYDEPARTMENTS','Department','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='BYDEPARTMENTS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','allowviewothers','查看其他成员的单据','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='allowviewothers' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','allowviewothers',"View Other's",'fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='allowviewothers' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','alloweditothers','编辑其他成员的单据','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='alloweditothers' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','alloweditothers',"Edit Other's",'fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='alloweditothers' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','allowdelothers','删除其他成员的单据','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='allowdelothers' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','allowdelothers',"Delete Other's",'fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='allowdelothers' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','allowviewselfcreatedbill','查询自己创建的单据','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='allowviewselfcreatedbill' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','allowviewselfcreatedbill',"Query Self-added",'fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='allowviewselfcreatedbill' and labeltype='fixedstr');
delimiter;
-- 2019-05-08

UPDATE ld_tab SET isduplicate='yes' WHERE NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>8);
UPDATE ld_desk SET fieldlabel='自己的' WHERE labelbol='ME' AND languagetype='zh';

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

update ld_systems_deploy set description = '设置客户、服务收费管理和供应商保存时，没用工商信息不允许保存' where deploy_type = 199;
delimiter;

update ld_tranlabel set fieldlabel = '设置{$Accounts.Accounts}、{$ServiceCharge.ServiceCharge}和{$Vendors.Vendors}保存时，没用工商信息不允许保存'
where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid = 199 and Relateid = 199;
update ld_tranlabel set fieldlabel = '{$Accounts.Accounts}、{$ServiceCharge.ServiceCharge} and {$Vendors.Vendors} is not allowed to be saved without business information'
where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid = 199 and Relateid = 199;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseenterthename2','This {$Vendors.Vendors} business information does not exist, cannot save!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='pleaseenterthename2' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseenterthename2','该{$Vendors.Vendors}工商信息不存在，无法保存！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='pleaseenterthename2' and labeltype='jspop');
delimiter;

update ld_desk set fieldlabel =replace(fieldlabel,'High Seas','Unassigned')
where languagetype='en' and BINARY fieldlabel like '%High Seas%';
delimiter;
update ld_desk set fieldlabel =replace(fieldlabel,'High seas','Unassigned')
where languagetype='en' and BINARY fieldlabel like '%High seas%';
delimiter;
update ld_desk set fieldlabel =replace(fieldlabel,'hign seas','high seas')
where languagetype='en' and BINARY fieldlabel like '%hign seas%';
delimiter;
update ld_desk set fieldlabel =replace(fieldlabel,'high seas','unassigned')
where languagetype='en' and BINARY fieldlabel like '%high seas%';
delimiter;
-- 2019-05-10

UPDATE ld_relatedlists SET actions='add' WHERE tabid=21 AND `name`='get_SendPayment';

UPDATE ld_field a
LEFT JOIN ld_tab b ON a.tabid=b.tabid
SET a.allowhide='yes'
WHERE a.uitype=202
	AND b.`name` LIKE 'CustomForm%'
	AND REPLACE(b.`name`,'CustomForm','')+0 BETWEEN 11 AND 20;

UPDATE ld_producttoolfield a
LEFT JOIN ld_tab b ON a.tabid=b.tabid
SET a.allowhide='yes'
WHERE a.columnname IN ('entitytypeid','entitytype')
	AND b.`name` LIKE 'CustomForm%'
	AND REPLACE(b.`name`,'CustomForm','')+0 BETWEEN 11 AND 20;
    

DELETE FROM ld_tab WHERE `name`='reportlog' AND presence<>0 AND NOT EXISTS (SELECT 1 FROM ld_dailyreport)
	AND NOT EXISTS (SELECT 1 FROM ld_weekreport) AND NOT EXISTS (SELECT 1 FROM ld_monthreport);
DELETE FROM ld_settings_field WHERE `name`='LBL_REMIND_SET' AND NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='reportlog');
UPDATE ld_workremindset SET dailyreminddate='不提醒',weekreminddate='不提醒',monthreminddate='不提醒' WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='reportlog');
DELETE FROM ld_templatesstuff WHERE stufftitle='DAILYWEEKMONTH' AND stufftype='reportLog';

UPDATE ld_systems_deploy SET inputvalue='[{"value":"0","text":"NOTCREATE"},{"value":"1","text":"CREATEAFTERSAVE"},{"value":"2","text":"CREATEAFTERAPPROVE"},{"sql":""},{"relatedmodule":"SalesOrder,ServiceContracts"}]' WHERE deploy_type=130;

update ld_workreport_field set label = '工作简报详情' where name = 'saleskit_day';
update ld_workreport_field set label = '工作简报详情' where name = 'saleskit_week';
update ld_workreport_field set label = '工作简报详情' where name = 'saleskit_month';
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_INVOICE_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_no');
select sequence into @sequence from ld_field where tabid=@tabid AND columnname='invoicestatus' LIMIT 1;

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
  select @tabid,@maxfieldid+1,'express_no','ld_invoice',1,1,'express_no','物流单号',1,2,@sequence+1,@blockid ,1,'V~O',1,1,'yes','yes','yes','yes','yes' from dual
  where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_no');

call getallprofile('Invoice');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='express_no';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid, @fieldid,'物流单号' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Logistics Single Number' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');

CALL AddColumn('ld_invoice','express_no','VARCHAR',255,NULL);
delimiter;

select tabid into @tabid from ld_tab where name='ChinaMap';
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
select blockid into @blockid from ld_appparenttab where parenttab_label='Accounts';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual
where not exists(select 1 from ld_appparenttabrel where tabid=@tabid);
delimiter;

update ld_dashboard_app set wx_presence=0 where name = 'AccountsMap';
delimiter;
-- 2019-05-16

UPDATE ld_systems_deploy SET inputvalue='[{"value":"rating","text":"rating"},{"field":"rating","type":"picklist","relatetable":"ld_field"},{"relatedmodule":"ServiceContracts,Accounts"},{"isSelectValue":"yes"}]' WHERE deploy_type=161;
UPDATE ld_systems_deploy SET inputvalue='[{"value":"1","text":"YES"},{"relatedmodule":"ServiceContracts"},{"value":"0","text":"NO"},{"sql":""}]' WHERE deploy_type=164;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid' LIMIT 1;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'mailingarea' LIMIT 1;
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','bill_area' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_documents_20190517`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_documents_20190517`(
)
BEGIN


	IF NOT EXISTS (SELECT 1 FROM ld_notes) THEN
		
		UPDATE ld_field SET presence=1 WHERE tabid=8 AND columnname='notecontent';

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=8 AND blocklabel='LBL_FILE_INFORMATION' LIMIT 1);
		UPDATE ld_tranlabel SET fieldlabel='文档信息' WHERE tabid=8 AND trantable='ld_blocks' AND Relateid=@blockid AND languagetype='zh';
		UPDATE ld_tranlabel SET fieldlabel='Document Information' WHERE tabid=8 AND trantable='ld_blocks' AND Relateid=@blockid AND languagetype='en';

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=8 AND columnname='filelocationtype' LIMIT 1);
		UPDATE ld_field SET fieldlabel='类型' WHERE tabid=8 AND columnname='filelocationtype';
		UPDATE ld_tranlabel SET fieldlabel='类型' WHERE tabid=8 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
		UPDATE ld_tranlabel SET fieldlabel='Document Type' WHERE tabid=8 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en';

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=8 AND columnname='name' LIMIT 1);
		UPDATE ld_field SET fieldlabel='文件' WHERE tabid=8 AND columnname='name';
		UPDATE ld_tranlabel SET fieldlabel='文件' WHERE tabid=8 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
		UPDATE ld_tranlabel SET fieldlabel='Choose Files' WHERE tabid=8 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en';

	END IF;

end ||
delimiter;

CALL ldcrm_reset_documents_20190517();
DROP PROCEDURE IF EXISTS `ldcrm_reset_documents_20190517`;


SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='folderid' LIMIT 1);
UPDATE ld_field SET defaultvalue=(SELECT listvalue FROM ld_picklist_values WHERE listid=@listid ORDER BY sequence LIMIT 1)
WHERE tabid=8 AND columnname='folderid' AND IFNULL(defaultvalue,'')<>''
	AND defaultvalue NOT IN (SELECT listvalue FROM ld_picklist_values WHERE listid=@listid);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','ALLMODULE','所有模块','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='ALLMODULE' AND languagetype='zh');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','ALLMODULE','All Modules','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='ALLMODULE' AND languagetype='en');

UPDATE ld_field SET searchfieldtype=1 WHERE tabid=6 AND NOT EXISTS (SELECT 1 FROM ld_salesorder);
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=6 AND columnname IN ('accountname','account_no','smownerid','modifiedtime') AND NOT EXISTS (SELECT 1 FROM ld_salesorder);

CREATE TABLE IF NOT EXISTS `ld_erp_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mac_address` varchar(100) DEFAULT NULL,
  `server_name` varchar(100) DEFAULT NULL,
  `root_directory` text,
  `createdtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

update ld_settings_field set active = 1 where `name` = 'LBL_DATAINTERFACE_SETTING';
update ld_systems_deploy set presence = 1 where deploy_type = 92;

DELETE FROM ld_settings_field WHERE `name` = 'LBL_DATAINTERFACE_SETTING' AND NOT EXISTS (SELECT 1 FROM ld_datainterface WHERE IFNULL(databasename,'')<>'');
DELETE FROM ld_systems_deploy WHERE deploy_type=92 AND NOT EXISTS (SELECT 1 FROM ld_datainterface WHERE IFNULL(databasename,'')<>'');
delimiter;
-- 2019-05-21

UPDATE ld_tab SET isduplicate='yes' WHERE `name`='Products'; 

select tabid into @tabid from ld_tab where name='Documents';
select blockid into @blockid from ld_appparenttab where parenttab_label='Others';
select tabid into @tabid_seq from ld_tab where name='Attachment';
select sequence into @sequence from ld_appparenttabrel where blockid=@blockid and tabid=@tabid_seq;

set @i = @sequence;
update ld_appparenttabrel set sequence=sequence+1 where sequence > @sequence;
insert into ld_appparenttabrel(blockid,tabid,sequence)
  select @blockid,@tabid,@sequence+1 from dual
  where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);

update ld_appparenttabrel set sequence=(@i:=@i+1) where sequence > @sequence and blockid=@blockid;
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,showtag)
  select 'Documents',1,1,'ld_notes:notes_title:notes_title:Documents_fieldlabel:V',2,'yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Documents' and columnname LIKE 'ld_notes:notes_title:%');

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,showtag)
  select 'Documents',2,1,'ld_notes:folderid:folderid:Documents_fieldlabel:V','yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Documents' and columnname LIKE 'ld_notes:folderid:%');

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,showtag)
  select 'Documents',3,1,'ld_notes:smownerid:assigned_user_id:Documents_fieldlabel:V','yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Documents' and columnname LIKE 'ld_notes:smownerid:%');
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_reset_uitype71_20190523`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_uitype71_20190523`(
)
BEGIN

	DECLARE tmp_fieldid INT(19) DEFAULT 0; 
	DECLARE tmp_tablename VARCHAR(200) DEFAULT ''; 
	DECLARE tmp_columnname VARCHAR(200) DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR 
				SELECT
					a.fieldid,
					a.tablename,
					a.columnname
				FROM ld_field a
				INNER JOIN information_schema.COLUMNS b ON b.TABLE_SCHEMA=DATABASE() AND b.TABLE_NAME=a.tablename AND b.COLUMN_NAME=a.columnname
				WHERE a.uitype=71
					AND a.fieldid>0
					AND b.COLUMN_TYPE='decimal(11,2)'
				GROUP BY a.tablename,a.columnname
				ORDER BY a.tablename,a.columnname;

		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_fieldid = NULL;

		OPEN MYCUSOR; 
		FETCH MYCUSOR INTO tmp_fieldid,tmp_tablename,tmp_columnname;
		WHILE(tmp_fieldid IS NOT NULL) DO
			
			SET @query_sql=CONCAT('ALTER TABLE ',tmp_tablename,' MODIFY COLUMN ',tmp_columnname,' DECIMAL(25,2)');
			PREPARE MYSTMT FROM @query_sql;
			EXECUTE MYSTMT;
			DEALLOCATE PREPARE MYSTMT;
		
			FETCH MYCUSOR INTO tmp_fieldid,tmp_tablename,tmp_columnname;
		END WHILE;
		CLOSE MYCUSOR;

end ||
delimiter;


CALL ldcrm_reset_uitype71_20190523();
DROP PROCEDURE IF EXISTS `ldcrm_reset_uitype71_20190523`;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILEUPLOAD','上传文档','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='FILEUPLOAD' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILEUPLOAD','Upload File','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='FILEUPLOAD' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAPPINGFIELD','映射字段','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='MAPPINGFIELD' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAPPINGFIELD','Mapping Field','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='MAPPINGFIELD' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCORDINGTEMPLATEIMPORTDATA','请按照数据模板的格式准备要导入的数据。','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='ACCORDINGTEMPLATEIMPORTDATA' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCORDINGTEMPLATEIMPORTDATA','请按照数据模板的格式准备要导入的数据。','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='ACCORDINGTEMPLATEIMPORTDATA' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOWNTEMPLATEDATA','下载数据模板','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='DOWNTEMPLATEDATA' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOWNTEMPLATEDATA','下载数据模板','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='DOWNTEMPLATEDATA' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIEWCAREITEM','查看注意事项','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='VIEWCAREITEM' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIEWCAREITEM','查看注意事项','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='VIEWCAREITEM' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STOPDELETEIMPORTTEMPLATEHEAD','模板中的表头名称不可更改，表头行不能删除','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='STOPDELETEIMPORTTEMPLATEHEAD' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','STOPDELETEIMPORTTEMPLATEHEAD','模板中的表头名称不可更改，表头行不能删除','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='STOPDELETEIMPORTTEMPLATEHEAD' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAYADJUSTORDERIMPORT','项目顺序可以调整，不需要的项目可以删减','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='MAYADJUSTORDERIMPORT' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAYADJUSTORDERIMPORT','项目顺序可以调整，不需要的项目可以删减','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='MAYADJUSTORDERIMPORT' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REDREPRESENTNOTEMPTY','红色*表示为必录项，必须保留并且不能为空','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='REDREPRESENTNOTEMPTY' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','REDREPRESENTNOTEMPTY','红色*表示为必录项，必须保留并且不能为空','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='REDREPRESENTNOTEMPTY' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','USESYSIMPORTFILE','请选择需要导入的文件。（请使用系统导出的模板表格）','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='USESYSIMPORTFILE' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','USESYSIMPORTFILE','请选择需要导入的文件。（请使用系统导出的模板表格）','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='USESYSIMPORTFILE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QuotesChange_Edit','新建->修改','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'QuotesChange_Edit' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QuotesChange_Edit','QuotesChange Edit','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'QuotesChange_Edit' and labeltype = 'fixedstr');
delimiter;

select max(actionid) into @actionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select @actionid+1,'QuotesChange_Edit',0,'QuotesChange_Edit' from DUAL
where not exists(select 1 from ld_actionmapping where actionname = 'QuotesChange_Edit');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quoteschange';
select actionid into @actionid_edit from ld_actionmapping where actionname = 'QuotesChange_Edit';
update ld_profileallpermission LEFT JOIN ld_actionmapping on ld_actionmapping.actionid = ld_profileallpermission.operation 
set sequence = sequence + 1 where tabid = @tabid and actionlabel != 'QuotesChange_Add' and actionlabel != 'QuotesChange_Replace';
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@actionid_edit,1 from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid_edit);
set @i=0;
update ld_profileallpermission set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'QuotesChange';
select tabid into @related_tabid from ld_tab where `name` = 'SalesOrder';
SELECT max(relation_id) into @relation_id FROM ld_relatedlists;
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence,trade)
select @relation_id+1,@tabid,@related_tabid,'get_salesorder',1,'SalesOrder',0,'add',1,0,'datacategory_sql','salesorder.quoteid',0,0,NULL from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

update ld_desk set fieldlabel = '新建->追加' where labelbol = 'QuotesChange_Add' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'New->Add' where labelbol = 'QuotesChange_Add' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '新建->更换' where labelbol = 'QuotesChange_Replace' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'New->Replace' where labelbol = 'QuotesChange_Replace' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

select max(table_sequence) into @tab_sequence from ld_option_module;
select tabid into @salesorder_tabid from ld_tab where `name` = 'SalesOrder';
select tabid into @quotes_tabid from ld_tab where `name` = 'Quotes';
select tabid into @quoteschange_tabid from ld_tab where `name` = 'QuotesChange';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
select @salesorder_tabid,@quotes_tabid,0,1,0,1,@tab_sequence+1 from DUAL
where not exists(select 1 from ld_option_module where tabid = @salesorder_tabid and option_tabid = @quotes_tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
select @salesorder_tabid,@quoteschange_tabid,0,0,0,2,@tab_sequence+1 from DUAL
where not exists(select 1 from ld_option_module where tabid = @salesorder_tabid and option_tabid = @quoteschange_tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
update ld_field set uitype = 208 where tabid = @tabid and fieldname = 'quote_id';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','onlycanbeselected','Only one {$Quotes.Quotes} can be selected','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='onlycanbeselected' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','onlycanbeselected','只能选择一个{$Quotes.Quotes}中的产品','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='onlycanbeselected' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','onlycanbeselected1','Only one {$QuotesChange.QuotesChange} can be selected','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='onlycanbeselected1' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','onlycanbeselected1','只能选择一个{$QuotesChange.QuotesChange}中的产品','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='onlycanbeselected1' and labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @fielid from ld_field where tabid = @tabid and uitype = 208;
update ld_tranlabel set fieldlabel = '选择源单' where tabid = @tabid and Relateid = @fielid and languagetype = 'zh' and trantable = 'ld_field';
update ld_tranlabel set fieldlabel = 'Select Source' where tabid = @tabid and Relateid = @fielid and languagetype = 'en' and trantable = 'ld_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'QuotesChange';
select tabid into @related_tabid from ld_tab where `name` = 'SalesOrder';
SELECT max(relation_id) into @relation_id FROM ld_relatedlists;
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence,trade)
select @relation_id+1,@tabid,@related_tabid,'get_salesorder',1,'SalesOrder',0,'add',1,0,'datacategory_sql','salesorder.quoteid',0,0,NULL from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

update ld_tabdetailfield INNER JOIN ld_tab
on  ld_tabdetailfield.tabid=ld_tab.tabid
 and ld_tabdetailfield.columnname='source_total'
set tablename=concat('ld_',lower(ld_tab.name),'detail')
where tablename is null or tablename='' ;
delimiter;

update ld_tabdetailfield INNER JOIN ld_tab
on  ld_tabdetailfield.tabid=ld_tab.tabid
 and ld_tabdetailfield.columnname='source_total'
set ld_tabdetailfield.presence=0
where ld_tabdetailfield.presence=2;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EFFECTIVEAFTERPRESERVATION','保存后生效','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EFFECTIVEAFTERPRESERVATION' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EFFECTIVEAFTERPRESERVATION','Effective after preservation','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='EFFECTIVEAFTERPRESERVATION' and Labeltype='fixedstr'); 
delimiter;
-- 2019-05-23

drop PROCEDURE if EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
create PROCEDURE account_singlerecycle_highsea_rule_beforeremind()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	
	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
  select beforereminddays into @var_beforereminddays from ld_account_set;



 if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
  select allotaccount into @allotaccount from ld_account_set;
	select recycleselect into @recycleselect from ld_account_set;
	set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;
			
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >=",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.`status`='active' ORDER BY ld_account_set_rule.sequence asc ) ";

			 set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
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
				
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
		delete from ld_publicaccount_remindtableview ;
        set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

        call crm_publicaccount_beforereminds();
	end if;
end||
delimiter;

call AddColumn('ld_users','searchmodules','text','','');
delimiter;

UPDATE ld_option_module a
LEFT JOIN ld_tab b ON a.tabid=b.tabid
SET a.table_sequence=b.tabsequence;

update ld_desk set fieldlabel='销售阶段变化' where labelbol='stagechange' and Labeltype='fixedstr' and languagetype='zh';
delimiter;
-- 2019-05-24

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

UPDATE ld_version SET old_version='V7.7.5',current_version='V7.7.5',remark='V7.7.5-20190524',wx_version='V7.7.5';
delimiter;