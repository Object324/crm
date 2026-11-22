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

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','DOWNLOADNOW','立即下载','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DOWNLOADNOW' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','DOWNLOADNOW','Download now','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DOWNLOADNOW' and languagetype='en' and Labeltype='fixedstr');
delimiter;

call addcolumn('ld_hantian_phonerecord','bridging','varchar',255,null);
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','HANTIANPHONEMISSED','未接','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HANTIANPHONEMISSED' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','HANTIANPHONEMISSED','Missed','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HANTIANPHONEMISSED' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','HANTIANPHONERECEIVED','已接','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HANTIANPHONERECEIVED' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','HANTIANPHONERECEIVED','Received','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HANTIANPHONERECEIVED' and languagetype='en' and Labeltype='fixedstr');
delimiter;  
-- 2019-01-16

UPDATE ld_desk SET fieldlabel='正在批量拉取企业微信“我的客户”数据，请勿刷新或关闭浏览器！' WHERE labelbol='IMPORTDATAREMIND1' AND languagetype='zh' AND Labeltype='jspop';
UPDATE ld_desk SET fieldlabel="Wechat customers are being imported, don't refresh or close browser." WHERE labelbol='IMPORTDATAREMIND1' AND languagetype='en' AND Labeltype='jspop';

update ld_desk set fieldlabel='自助服务小程序' where labelbol='SELFSERVICEQRCODE' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Self-service applet' where labelbol='SELFSERVICEQRCODE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='自助服务小程序' where labelbol='SELFSERVICEQRCODE' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='Self-service applet' where labelbol='SELFSERVICEQRCODE' and languagetype='en' and Labeltype='jspop';
delimiter;

UPDATE ld_desk SET fieldlabel='企业号只能输入字母、数字和下划线，最多50个字符' WHERE labelbol='WECHATAPPLETSETTINGSREMIND04' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='CRM外网访问地址请参照此格式输入：http://www.51mis.com/crm' WHERE labelbol='WECHATAPPLETSETTINGSREMIND05' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='Please enter CRM URL according to the example, example: http://www.51mis.com/crm' WHERE labelbol='WECHATAPPLETSETTINGSREMIND05' AND languagetype='en' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='这里是CRM小程序的二维码，自助服务小程序的二维码请到成员管理详情界面查看和下载' WHERE labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' AND languagetype='zh' AND Labeltype='fixedstr';
update ld_desk set fieldlabel='This is CRM applet code, you can view and download the self-service applet code in user details interface' where labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' and languagetype='en' and Labeltype='fixedstr';
delimiter;

update ld_weixinmp_module set mplabel='我的报修',content='实时查看以及管理我的报修单！'  where mplabel='我的维修' and modulename='HelpDesk' and type='view';
delimiter;

update ld_desk set fieldlabel='CRM微信小程序' where labelbol='CRMWECHATSMALLPROGRAMTWODIMENSIONAL' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='CRM Wechat Small Program ' where labelbol='CRMWECHATSMALLPROGRAMTWODIMENSIONAL' and Labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='System Setting' where labelbol='SYSTEM_DESCRIPTION' and Labeltype='fixedstr' and languagetype='en';
delimiter;
-- 2019-01-18

select sequence into @sequence from ld_systems_deploy where deploy_type=143;
update ld_systems_deploy set sequence=sequence+1 where roottype=7 and sequence>@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
  select 1,200,'设置微信端拜访签到选择照片是否为必填字段',@sequence+1,7,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
  from dual where not exists(select 1 from ld_systems_deploy  where deploy_type=200);
set @i=@sequence;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=7 and sequence>@sequence order by sequence asc;

select deploy_type into @relateid from ld_systems_deploy where deploy_type=200;
insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_systems_deploy',@relateid,@relateid,'设置微信端拜访签到选择照片是否为必填字段' from DUAL
  where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='zh');

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_systems_deploy',@relateid,@relateid,'Set the WeChat visit check-in to select whether the photo is a required field' from DUAL
  where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='en');
delimiter;
-- 2019-01-21

UPDATE ld_usereport SET setype='SalesOrder,ServiceContracts,CashBill' WHERE `name`='Salesranking';

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select sequence into @sequence from ld_producttoolfield where columnname = 'quantity' and tabid = @tabid;
update ld_producttoolfield set sequence = sequence + 1000 where tabid = @tabid and sequence >= @sequence;
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,description,nullfield)
select @maxfieldid+1,'wareid','no','仓库','',0,30,'V~M',@sequence,@tabid,'ld_inventoryproductrel',30,0,0,0,0,2,0,NULL,1 from DUAL
where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'wareid');

select tabid into @tabid from ld_tab where name='OutboundOrder';
select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='wareid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'仓库' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'Warehouse' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;

call AddColumn('ld_inventoryproductrel','wareid','int','11',0);
delimiter;

update ld_inventoryproductrel INNER JOIN ld_outboundorder on ld_outboundorder.out_id = ld_inventoryproductrel.id
set ld_inventoryproductrel.wareid = ld_outboundorder.wareid where ld_inventoryproductrel.wareid = 0;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
delete from ld_field where tabid = @tabid and columnname = 'wareid';
delimiter;

update ld_field set approve_demand = 2 where tabid = 4 and columnname in ('bill_street','bill_area','locationaddress_map','locationaddress','bill_country','bill_state','bill_city');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_lianxiren_dizhi_20190122`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_lianxiren_dizhi_20190122`()
BEGIN

	IF (SELECT COUNT(1) FROM ld_field WHERE tabid=4 AND columnname IN ('mailingcountry','mailingstate','mailingcity') AND presence<>1)=3 THEN
		SET @tabid=4;
		UPDATE ld_field SET fieldname='bill_country',uitype=15 WHERE tabid=4 AND columnname='mailingcountry';
		UPDATE ld_field SET fieldname='bill_state',uitype=15 WHERE tabid=4 AND columnname='mailingstate';
		UPDATE ld_field SET fieldname='bill_city',uitype=15 WHERE tabid=4 AND columnname='mailingcity';

		SET @seq=(SELECT sequence FROM ld_field WHERE tabid=@tabid AND columnname='mailingcountry');
		SET @block=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='mailingcountry');
		UPDATE ld_field SET sequence=IFNULL(sequence,0)+100 WHERE tabid=@tabid AND block=@block AND sequence>@seq;
		UPDATE ld_field SET sequence=@seq+1,block=@block WHERE tabid=@tabid AND columnname='mailingstate';
		UPDATE ld_field SET sequence=@seq+2,block=@block WHERE tabid=@tabid AND columnname='mailingcity';
		UPDATE ld_field SET sequence=@seq+3,block=@block WHERE tabid=@tabid AND columnname='mailingarea';
		UPDATE ld_field SET sequence=@seq+4,block=@block WHERE tabid=@tabid AND columnname='mailingzip';
		UPDATE ld_field SET sequence=@seq+5,block=@block WHERE tabid=@tabid AND columnname='mailingstreet';

		SET @i=0;
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block ORDER BY sequence;

		IF NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield IN ('bill_country','bill_state','bill_city')) THEN
			DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield IN ('bill_country','bill_state','bill_city');
			SET @i=(SELECT MAX(id) FROM ld_picklist_dependency);

			INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
			SELECT (@i:=@i+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency 
			WHERE tabid=6 AND sourcefield IN ('bill_country','bill_state','bill_city');
		END IF;
	END IF;

END ||
delimiter;

CALL ldcrm_reset_lianxiren_dizhi_20190122();
DROP PROCEDURE IF EXISTS `ldcrm_reset_lianxiren_dizhi_20190122`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'plainsms','普通短信','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='plainsms' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'plainsms','Planin Sms','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='plainsms' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_smstemplates','template_type','varchar','200',NULL);
delimiter;

update ld_smstemplates set template_type = 'ordinary' where template_type is NULL;
delimiter;
-- 2019-01-22

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'QUANTITYMORTHANCURRENTROWBATCH1','出库数量大于仓库{warename}该批次号产品的库存数量','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='QUANTITYMORTHANCURRENTROWBATCH1' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'QUANTITYMORTHANCURRENTROWBATCH1','Save failed, reason: The quantity of {warename} is larger than the quantity of the current batch number!','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='QUANTITYMORTHANCURRENTROWBATCH1' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'elementrow','第{rowid}行','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='elementrow' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'elementrow','{rowid} row','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='elementrow' and labeltype='fixedstr');
delimiter;

select usereportid into @id from ld_usereport where name='InventoryQuery';
update ld_usereportcolumns set realcolumns='ld_products:product_no:product_no:Products_产品编号:V'
where Usereportid=@id and columns='ld_products:product_no:product_no:Products_产品编号#:V';
delimiter;

UPDATE ld_products p 
LEFT JOIN (
	SELECT
		a.wareid,
		a.productid,
		a.batchtext,
		SUM(a.inventory_qty) AS inventory_qty
	FROM (
		SELECT
			a.warehouseid AS wareid,
			a.productid,
			a.batchtext,
			a.lastqty AS inventory_qty
		FROM ld_warehousecondtions a
		LEFT JOIN ld_products c ON c.productid=a.productid
		WHERE a.modulename='库存初始化'
			AND a.type='确认初始库存'
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			c.quantity
		FROM ld_stock a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.stock_id
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			c.quantity
		FROM ld_salesback a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.salesbackid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.salesbackstatus<>'中止'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			0-c.quantity
		FROM ld_outboundorder a
		LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.out_id
		LEFT JOIN ld_inventoryproductrelscf d ON d.lineitem_id=c.lineitem_id
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			0-c.quantity
		FROM ld_purchaseback a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.purchasebackid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.purchasebackstatus<>'中止'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.purchasebackstatus='结束'
				END)
		UNION ALL
		SELECT
			a.inwarehouse,
			c.productid,
			c.batchtext,
			c.quantity
		FROM ld_warehousetransfer a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.warehousetransferid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.transferstatus='已审核'
				END)
		UNION ALL
		SELECT
			a.outwarehouse,
			c.productid,
			c.batchtext,
			0-c.quantity
		FROM ld_warehousetransfer a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.warehousetransferid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.transferstatus='已审核'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			c.profitloss
		FROM ld_checks a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.id
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.presence='盘点结束'
				END)
	) a
	WHERE a.productid>0
	GROUP BY a.productid
) a ON a.productid=p.productid
SET p.qtyinstock=IFNULL(a.inventory_qty,0)
WHERE p.deleted=0
	AND IFNULL(p.qtyinstock,0)<>IFNULL(a.inventory_qty,0);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'whethertochangethewarehouse','是否更改下面所有行的仓库为{warename}','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='whethertochangethewarehouse' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'whethertochangethewarehouse','Whether to change the warehouse for all the bellow rows','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='whethertochangethewarehouse' and labeltype='jspop');
delimiter;
-- 2019-01-23

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

UPDATE ld_version SET old_version='V7.6.8',current_version='V7.6.8',remark='V7.6.8-20190123',wx_version='V7.6.8';
delimiter;