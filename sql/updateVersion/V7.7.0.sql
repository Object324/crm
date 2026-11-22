DROP PROCEDURE IF EXISTS `ldcrm_reset_parenttabforleads_20190301`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_parenttabforleads_20190301`(
)
BEGIN


	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
	SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Parent Accounts');
	SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Accounts');
	
	IF NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid) THEN
		UPDATE ld_parenttabrel SET sequence=sequence+1 WHERE parenttabid=@parenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parenttabid,@tabid,1;
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=@tabid) THEN
		UPDATE ld_appparenttabrel SET sequence=sequence+1 WHERE blockid=@blockid;
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,@tabid,1;
	END IF;

END ||
delimiter;

CALL ldcrm_reset_parenttabforleads_20190301();
DROP PROCEDURE IF EXISTS `ldcrm_reset_parenttabforleads_20190301`;

UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=48 AND NOT EXISTS (
	SELECT 1 FROM ld_crmentity WHERE setype IN ('OutboundOrder','Stock','WareHouseTransfer','Checks','SalesBack','PurchaseBack'));
delimiter;

update ld_desk set fieldlabel='客户联系适用范围配置' where labelbol='ExternalContactUsersSetting' and languagetype='zh';
delimiter;

UPDATE ld_purchaseorder a
LEFT JOIN ld_inventoryproductrel b ON a.purchaseorderid=b.id
LEFT JOIN (
	SELECT
		b.entitytypeid,
		b.parent_lineitem_id,
		SUM(b.quantity) AS in_qty
	FROM ld_stock a
	LEFT JOIN ld_inventoryproductrel b ON a.stock_id=b.id
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 LIMIT 1)=0 THEN 
						a.approvestatus='已批准'
					ELSE 1=1
				END
			)
		AND b.entitytype='PurchaseOrder'
	GROUP BY b.entitytypeid,b.parent_lineitem_id
) c ON b.id=c.entitytypeid AND b.lineitem_id=c.parent_lineitem_id
SET b.havepurchasecount=IFNULL(c.in_qty,0);
delimiter;
UPDATE ld_purchaseorder a
LEFT JOIN ld_inventoryproductrel b ON a.purchaseorderid=b.id
SET b.balancepurchasecount=IFNULL(b.quantity,0)-IFNULL(b.havepurchasecount,0);
delimiter;

UPDATE ld_purchaseorder a
LEFT JOIN ld_inventoryproductrel b ON a.purchaseorderid=b.id
SET a.stockpresence=(	CASE 
												WHEN b.balancepurchasecount<=0 THEN '全部入库' 
												WHEN b.havepurchasecount>0 AND b.balancepurchasecount>0 THEN '部分入库' 
												ELSE '未入库'
											END);
delimiter;

update ld_stock set presence='未入库'
	where exists  (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 and deploy_value=0) 
and ifnull(approvestatus,'')<>'已批准';
delimiter;

update ld_stock set presence='已入库'
	where exists  (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 and deploy_value=1) ;
delimiter;

UPDATE ld_salesorder a
LEFT JOIN ld_inventoryproductrel b ON a.salesorderid=b.id
LEFT JOIN (
	SELECT
		b.entitytypeid,
		b.parent_lineitem_id,
		SUM(b.quantity) AS in_qty
	FROM ld_outboundorder a
	LEFT JOIN ld_inventoryproductrel b ON a.out_id=b.id
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 LIMIT 1)=0 THEN 
						a.approvestatus='已批准'
					ELSE 1=1
				END
			)
		AND b.entitytype='SalesOrder'
	GROUP BY b.entitytypeid,b.parent_lineitem_id
) c ON b.id=c.entitytypeid AND b.lineitem_id=c.parent_lineitem_id
SET b.haveoutproductcount=IFNULL(c.in_qty,0);
delimiter;

UPDATE ld_salesorder a
LEFT JOIN ld_inventoryproductrel b ON a.salesorderid=b.id
SET b.balanceoutproductcount=IFNULL(b.quantity,0)-IFNULL(b.haveoutproductcount,0);
delimiter;


UPDATE ld_salesorder a
LEFT JOIN ld_inventoryproductrel b ON a.salesorderid=b.id
SET a.stockpresence=(	CASE 
												WHEN b.balanceoutproductcount<=0 THEN '全部出库' 
												WHEN b.haveoutproductcount>0 AND b.balanceoutproductcount>0 THEN '部分出库' 
												ELSE '未出库'
											END);

delimiter;
update ld_outboundorder set presence='未出库'
	where exists  (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 and deploy_value=0) 
and ifnull(approvestatus,'')<>'已批准';
delimiter;

update ld_outboundorder set presence='已出库'
	where exists  (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 and deploy_value=1) ;
delimiter;


select tabid into @tabid from ld_tab where `name` = 'Invoice';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid and fieldtype = 'main');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'PASSWORDVERFICATION','密码验证','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PASSWORDVERFICATION' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'PASSWORDVERFICATION','Password verification','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PASSWORDVERFICATION' and labeltype='fixedstr');
delimiter;

SET @tabid=6;
SET @blockid1=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_ACCOUNT_INFORMATION');
SET @blockid2=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_ACCOUNT_PRIMARYCONTACT' ORDER BY blockid LIMIT 1);
SET @blockid3=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_ACCOUNT_PRIMARYCONTACT' AND blockid>@blockid2 ORDER BY blockid LIMIT 1);
DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_blocks' AND Relateid=@blockid3;
DELETE FROM ld_blocks WHERE blockid=@blockid3;
UPDATE ld_field SET block=@blockid1 WHERE tabid=@tabid AND block=@blockid3;
-- 2019-03-01

update ld_tranlabel set fieldlabel = '设置新增{$Accounts.Accounts}保存时，工商局无该公司名称不允许保存' where tabid = '199' and Relateid = '199' and languagetype = 'zh';
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='SalesBack';

CALL ldcrm_add_cvcolumnlist_wx('SalesBack','salesback_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('SalesBack','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('SalesBack','smownerid','3','1','yes','yes');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'salesback_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='salesback_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CashBack';
CALL ldcrm_add_cvcolumnlist_wx('CashBack','cashback_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CashBack','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CashBack','smownerid','3','1','yes','yes');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'cashback_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='cashback_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='PurchaseBack';
CALL ldcrm_add_cvcolumnlist_wx('PurchaseBack','purchaseback_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('PurchaseBack','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('PurchaseBack','smownerid','3','1','yes','yes');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'purchaseback_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='purchaseback_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='PurchaseCashBack';
CALL ldcrm_add_cvcolumnlist_wx('PurchaseCashBack','purchasecashback_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('PurchaseCashBack','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('PurchaseCashBack','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack');

DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'purchasecashback_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='purchasecashback_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='WareHouseTransfer';
CALL ldcrm_add_cvcolumnlist_wx('WareHouseTransfer','transferdate_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('WareHouseTransfer','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('WareHouseTransfer','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WareHouseTransfer');

DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'transferdate_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='transferdate_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

update ld_desk set fieldlabel = '登录界面自定义设置' where Labeltype = 'fixedstr' and labelbol = 'LBL_LOGIN_SETTINGS' and languagetype = 'zh';
delimiter;

SET @lable='LBI_MINI_SETTINGS';
SET @zh='小程序设置';
SET @en='Applet Settings';
SET @blockid=(SELECT max(blockid) FROM ld_settings_blocks);
SET @sequence=(SELECT max(sequence) FROM ld_settings_blocks);
INSERT INTO ld_settings_blocks(blockid,label,sequence,active)
  SELECT @blockid+1,@lable,@sequence+1,0 FROM DUAL
  WHERE NOT EXISTS (SELECT 1 FROM ld_settings_blocks WHERE label=@lable);
UPDATE ld_settings_blocks_seq SET id=(SELECT max(blockid) FROM ld_settings_blocks);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'zh',@lable,@zh,'fixedstr' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol=@lable AND labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'en',@lable,@en,'fixedstr' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol=@lable AND labeltype='fixedstr');
select blockid into @blockid from ld_settings_blocks where label='LBI_MINI_SETTINGS';
set @sequence = 1;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'WECHATAPPLETSETTINGS','picklistdependency.png','WECHATAPPLETSETTINGSWEBURL',
    'index.php?module=Settings&action=wechat_miniprogram_setting&parenttab=Settings',@sequence,0 from dual
where not exists(select 1 from ld_settings_field where blockid=@blockid and name='WECHATAPPLETSETTINGS');
select blockid into @blockid from ld_settings_blocks where label='LBI_MINI_SETTINGS';
set @sequence = 2;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'CUSTOMERSELFSERVICECONFIG01','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&step=home',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='CUSTOMERSELFSERVICECONFIG01');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIG01','Self-service widget login homepage settings','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIG01' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIG01','自助服务小程序登录首页设置','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIG01' and labeltype='fixedstr');
select blockid into @blockid from ld_settings_blocks where label='LBI_MINI_SETTINGS';
set @sequence = 3;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'CUSTOMERSELFSERVICECONFIG02','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&step=module',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='CUSTOMERSELFSERVICECONFIG02');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIG02','Self-service widget module settings','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIG02' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIG02','自助服务小程序模块设置','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIG02' and labeltype='fixedstr');
select blockid into @blockid from ld_settings_blocks where label='LBI_MINI_SETTINGS';
set @sequence = 4;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'CUSTOMERSELFSERVICECONFIG03','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&step=moduledetail',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='CUSTOMERSELFSERVICECONFIG03');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIG03','Customization of self-service widget details interface','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIG03' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIG03','自助服务小程序详情界面定制','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIG03' and labeltype='fixedstr');
select blockid into @blockid from ld_settings_blocks where label='LBI_MINI_SETTINGS';
set @sequence = 5;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'CUSTOMERSELFSERVICECONFIG04','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&step=modulelist',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='CUSTOMERSELFSERVICECONFIG04');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIG04','List customization of self-service widgets','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIG04' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIG04','自助服务小程序模块列表定制','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIG04' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME08','Self-service applet download','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME08' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME08','自助服务小程序下载','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME08' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME07','Other members of the self service WeChat applet, please download through each member''s personal Settings','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME07' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME07','其他成员的自助服务微信小程序，请分别通过每个成员的个人设置下载','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME07' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME06','System administrator self - service WeChat small program download','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME06' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME06','系统管理员自助服务微信小程序下载','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME06' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME05','Login mobile phone number binding field','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME05' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME05','登录手机号码绑定字段','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME05' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME04','Register to create a new','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME04' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME04','注册创建新','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME04' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME03','Login binding already exists','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME03' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME03','登录绑定已有','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME03' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME02','Small program initialization home Settings','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME02' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME02','小程序初始化首页设置','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME02' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME01','Please set up the enterprise number of CRM applet ahead of time','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME01' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME01','请提前进行crm小程序企业号设置','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME01' and labeltype='fixedstr');
select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
delete from ld_settings_field where blockid=@blockid and name in ('CUSTOMERSELFSERVICECONFIG','WECHATAPPLETSETTINGS');
delimiter;
-- 2019-03-06


SET @i=0;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Singin' LIMIT 1);
SET @seq=(SELECT sequence FROM ld_option_module WHERE tabid=@tabid AND option_tabid=2 LIMIT 1);
UPDATE ld_option_module SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@seq;

INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
SELECT @tabid,13,0,0,0,@seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=13);
UPDATE ld_option_module SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Singin' LIMIT 1);
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='record' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='address' LIMIT 1);
UPDATE ld_related_field SET fromvalue_info="SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,ld_account.bill_street) AS address
FROM ld_account
WHERE ld_account.deleted = 0 AND accountid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,ld_account.bill_street) AS address
FROM ld_contactdetails
INNER JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
WHERE ld_account.deleted = 0 AND ld_contactdetails.contactid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,ld_account.bill_street) AS address
FROM ld_contactrecords
INNER JOIN ld_account ON ld_account.accountid = ld_contactrecords.accountid
WHERE ld_account.deleted = 0 AND ld_contactrecords.contactrecordID = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,ld_account.bill_street) AS address
FROM ld_potential
INNER JOIN ld_account ON ld_account.accountid = ld_potential.accountid
WHERE ld_account.deleted = 0 AND ld_potential.potentialid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,ld_account.bill_street) AS address
FROM ld_troubletickets
INNER JOIN ld_account ON ld_account.accountid = ld_troubletickets.accountid
WHERE ld_account.deleted = 0 AND ld_troubletickets.ticketid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,ld_account.bill_street) AS address
FROM ld_project
INNER JOIN ld_account ON ld_account.accountid = ld_project.accountid
WHERE ld_account.deleted = 0 AND ld_project.projectid = ?"
WHERE trigger_fieldid=@trigger_fieldid 
	AND effect_fieldid=@effect_fieldid
	AND LOCATE('ld_project',fromvalue_info)>0
	AND LOCATE('ld_account',fromvalue_info)>0
	AND LOCATE('ld_contactrecords',fromvalue_info)>0
	AND LOCATE('ld_potential',fromvalue_info)>0
	AND LOCATE('ld_project',fromvalue_info)>0;
-- 2019-03-07

UPDATE ld_mailmanager_mailrecord SET seen=1 WHERE mailtype='smtp';

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','CUSTOMIZESEARCH','高级查找','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CUSTOMIZESEARCH' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','CUSTOMIZESEARCH','Customize Search','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CUSTOMIZESEARCH' and languagetype='en' and Labeltype='fixedstr');
delimiter;


update ld_desk set fieldlabel='服务小程序登录首页设置'
where labelbol='CUSTOMERSELFSERVICECONFIG01' and languagetype='zh';
update ld_desk set fieldlabel='服务小程序模块设置'
where labelbol='CUSTOMERSELFSERVICECONFIG02' and languagetype='zh';
update ld_desk set fieldlabel='服务小程序详情界面定制'
where labelbol='CUSTOMERSELFSERVICECONFIG03' and languagetype='zh';
update ld_desk set fieldlabel='服务小程序模块列表定制'
where labelbol='CUSTOMERSELFSERVICECONFIG04' and languagetype='zh';
set @modulename ='Contacts';
insert into ld_weixinmp_set (modulename, viewall) select @modulename,'no' from dual
where not exists(select 1 from ld_weixinmp_set where modulename=@modulename);
insert into ld_weixinmp_fields (modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, sequence)
    select @modulename,'lastname','main','联系人姓名','all','m',1 from dual
    where not exists(select 1 from ld_weixinmp_fields where modulename=@modulename and fieldname='lastname');
insert into ld_weixinmp_fields (modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, sequence)
  select @modulename,'mobile','main','联系人手机','all','m',2 from dual
  where not exists(select 1 from ld_weixinmp_fields where modulename=@modulename and fieldname='mobile');
insert into ld_weixinmp_fields (modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, sequence)
  select @modulename,'assigned_user_id','main','销售负责人','createno','o',3 from dual
  where not exists(select 1 from ld_weixinmp_fields where modulename=@modulename and fieldname='assigned_user_id');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTORECYCLERULEDATACATEGORY','自动回收规则数据分类设置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AUTORECYCLERULEDATACATEGORY' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTORECYCLERULEDATACATEGORY','Data Classification Settings for Automatic Recycling Rules','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AUTORECYCLERULEDATACATEGORY' and Labeltype='fixedstr');
delimiter;

CREATE TABLE if not exists `ld_account_set_advfilter` (
  `columnindex` int(11) DEFAULT NULL,
  `columnname` varchar(250) DEFAULT NULL,
  `comparator` varchar(50) DEFAULT NULL,
  `column_condition` varchar(50) DEFAULT NULL,
  `value` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_account_set','recycleselect','text',0,0 );
delimiter;

DROP FUNCTION IF EXISTS `func_changeToCapitalRMB`;
delimiter ||
CREATE FUNCTION `func_changeToCapitalRMB`(MONEY decimal(14,2)) RETURNS varchar(150) CHARSET utf8
BEGIN

	DECLARE RV_MONEY0 VARCHAR(20);
	DECLARE RV_MONEY1 VARCHAR(4);
	DECLARE RV_MONEY2 VARCHAR(4);
	DECLARE V_MONEY0 VARCHAR(28);
	DECLARE V_MONEY1 VARCHAR(4);
	DECLARE V_MONEY2 VARCHAR(4);
	DECLARE V_MONEY3 VARCHAR(4);
	DECLARE V_MONEY4 VARCHAR(4);
	DECLARE V_MONEY5 VARCHAR(4);
	DECLARE V_MONEY6 VARCHAR(4);
	DECLARE V_MONEY7 VARCHAR(4);
	DECLARE V_MONEY8 VARCHAR(4);
	DECLARE V_MONEY9 VARCHAR(4);
	DECLARE V_MONEY10 VARCHAR(4);
	DECLARE V_MONEY11 VARCHAR(4);
	DECLARE V_MONEY12 VARCHAR(4);
	DECLARE RPV_MONEY1 VARCHAR(4);
	DECLARE RPV_MONEY2 VARCHAR(4);
	DECLARE PV_MONEY0 VARCHAR(14);
	DECLARE PV_MONEY1 VARCHAR(4);
	DECLARE PV_MONEY2 VARCHAR(4);
	DECLARE PV_MONEY3 VARCHAR(4);
	DECLARE PV_MONEY4 VARCHAR(4);
	DECLARE PV_MONEY5 VARCHAR(4);
	DECLARE PV_MONEY6 VARCHAR(4);
	DECLARE PV_MONEY7 VARCHAR(4);
	DECLARE PV_MONEY8 VARCHAR(4);
	DECLARE PV_MONEY9 VARCHAR(4);
	DECLARE PV_MONEY10 VARCHAR(4);
	DECLARE PV_MONEY11 VARCHAR(4);
	DECLARE PV_MONEY12 VARCHAR(4);
	DECLARE Z_MONEY VARCHAR(28);

	SET Z_MONEY=FLOOR(MONEY);
	SET V_MONEY0=LTRIM(RTRIM(Z_MONEY));
	SET Z_MONEY=FLOOR(MONEY*100);
	SET RV_MONEY0=LTRIM(RTRIM(Z_MONEY));
	SET RV_MONEY1=SUBSTR(RV_MONEY0,LENGTH(RV_MONEY0),1);

	IF LENGTH(RV_MONEY0)>1 THEN 
		SET RV_MONEY2=SUBSTR(RV_MONEY0,LENGTH(RV_MONEY0)-1,1);
	ELSE
		SET RV_MONEY2='0';
	END IF;

	SET V_MONEY1=SUBSTR(V_MONEY0,LENGTH(V_MONEY0),1);

	IF LENGTH(V_MONEY0)-1>0 THEN
		SET V_MONEY2=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-1,1);
	ELSE
		SET V_MONEY2='0';
	END IF;

	IF LENGTH(V_MONEY0)-2>0 THEN
		SET V_MONEY3=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-2,1);
	ELSE
		SET V_MONEY3='0';

	END IF;

	IF LENGTH(V_MONEY0)-3>0 THEN
		SET V_MONEY4=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-3,1);
	ELSE
		SET V_MONEY4='0';
	END IF;

	IF LENGTH(V_MONEY0)-4>0 THEN
		SET V_MONEY5=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-4,1);
	ELSE
		SET V_MONEY5='0';
	END IF;

	IF LENGTH(V_MONEY0)-5>0 THEN
		SET V_MONEY6=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-5,1);
	ELSE
		SET V_MONEY6='0';
	END IF;

	IF LENGTH(V_MONEY0)-6>0 THEN
		SET V_MONEY7=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-6,1);
	ELSE
		SET V_MONEY7='0';
	END IF;

	IF LENGTH(V_MONEY0)-7>0 THEN
		SET V_MONEY8=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-7,1);
	ELSE
		SET V_MONEY8='0';
	END IF;

	IF LENGTH(V_MONEY0)-8>0 THEN
		SET V_MONEY9=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-8,1);
	ELSE
		SET V_MONEY9='0';
	END IF;

	IF LENGTH(V_MONEY0)-9>0 THEN
		SET V_MONEY10=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-9,1);
	ELSE
		SET V_MONEY10='0';
	END IF;

	IF LENGTH(V_MONEY0)-10>0 THEN
		SET V_MONEY11=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-10,1);
	ELSE
		SET V_MONEY11='0';
	END IF;

	IF LENGTH(V_MONEY0)-11>0 THEN
		SET V_MONEY12=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-11,1);
	ELSE
		SET V_MONEY12='0';
	END IF;


	SELECT 
		CASE
			WHEN RV_MONEY1=0 THEN ''
			WHEN RV_MONEY1=1 THEN '壹分'
			WHEN RV_MONEY1=2 THEN '贰分'
			WHEN RV_MONEY1=3 THEN '叁分'			
			WHEN RV_MONEY1=4 THEN '肆分'
			WHEN RV_MONEY1=5 THEN '伍分'
			WHEN RV_MONEY1=6 THEN '陆分'
			WHEN RV_MONEY1=7 THEN '柒分'	
			WHEN RV_MONEY1=8 THEN '捌分'	
			WHEN RV_MONEY1=9 THEN '玖分'
		END INTO RPV_MONEY1;
	SELECT 
		CASE
			WHEN RV_MONEY2=0 AND RV_MONEY1=0 THEN '整'
			WHEN RV_MONEY2=0 AND RV_MONEY1>0 THEN '零'
			WHEN RV_MONEY2=1 THEN '壹角'
			WHEN RV_MONEY2=2 THEN '贰角'
			WHEN RV_MONEY2=3 THEN '叁角'			
			WHEN RV_MONEY2=4 THEN '肆角'
			WHEN RV_MONEY2=5 THEN '伍角'
			WHEN RV_MONEY2=6 THEN '陆角'
			WHEN RV_MONEY2=7 THEN '柒角'	
			WHEN RV_MONEY2=8 THEN '捌角'	
			WHEN RV_MONEY2=9 THEN '玖角'
		END INTO RPV_MONEY2;
	SELECT 
		CASE
			WHEN V_MONEY1=0 THEN '元'
			WHEN V_MONEY1=1 THEN '壹元'
			WHEN V_MONEY1=2 THEN '贰元'
			WHEN V_MONEY1=3 THEN '叁元'			
			WHEN V_MONEY1=4 THEN '肆元'
			WHEN V_MONEY1=5 THEN '伍元'
			WHEN V_MONEY1=6 THEN '陆元'
			WHEN V_MONEY1=7 THEN '柒元'	
			WHEN V_MONEY1=8 THEN '捌元'	
			WHEN V_MONEY1=9 THEN '玖元'
		END INTO PV_MONEY1;
	SELECT 
		CASE
			WHEN V_MONEY2=0 THEN ''
			WHEN V_MONEY2=1 THEN '壹拾'
			WHEN V_MONEY2=2 THEN '贰拾'
			WHEN V_MONEY2=3 THEN '叁拾'			
			WHEN V_MONEY2=4 THEN '肆拾'
			WHEN V_MONEY2=5 THEN '伍拾'
			WHEN V_MONEY2=6 THEN '陆拾'
			WHEN V_MONEY2=7 THEN '柒拾'	
			WHEN V_MONEY2=8 THEN '捌拾'	
			WHEN V_MONEY2=9 THEN '玖拾'
		END INTO PV_MONEY2;
	SELECT 
		CASE
			WHEN V_MONEY3=0 THEN ''
			WHEN V_MONEY3=1 THEN '壹佰'
			WHEN V_MONEY3=2 THEN '贰佰'
			WHEN V_MONEY3=3 THEN '叁佰'			
			WHEN V_MONEY3=4 THEN '肆佰'
			WHEN V_MONEY3=5 THEN '伍佰'
			WHEN V_MONEY3=6 THEN '陆佰'
			WHEN V_MONEY3=7 THEN '柒佰'	
			WHEN V_MONEY3=8 THEN '捌佰'	
			WHEN V_MONEY3=9 THEN '玖佰'
		END INTO PV_MONEY3;
	SELECT 
		CASE
			WHEN V_MONEY4=0 THEN ''
			WHEN V_MONEY4=1 THEN '壹仟'
			WHEN V_MONEY4=2 THEN '贰仟'
			WHEN V_MONEY4=3 THEN '叁仟'			
			WHEN V_MONEY4=4 THEN '肆仟'
			WHEN V_MONEY4=5 THEN '伍仟'
			WHEN V_MONEY4=6 THEN '陆仟'
			WHEN V_MONEY4=7 THEN '柒仟'	
			WHEN V_MONEY4=8 THEN '捌仟'	
			WHEN V_MONEY4=9 THEN '玖仟'
		END INTO PV_MONEY4;
	SELECT 
		CASE
			WHEN V_MONEY5=0 THEN '万'
			WHEN V_MONEY5=1 THEN '壹万'
			WHEN V_MONEY5=2 THEN '贰万'
			WHEN V_MONEY5=3 THEN '叁万'			
			WHEN V_MONEY5=4 THEN '肆万'
			WHEN V_MONEY5=5 THEN '伍万'
			WHEN V_MONEY5=6 THEN '陆万'
			WHEN V_MONEY5=7 THEN '柒万'	
			WHEN V_MONEY5=8 THEN '捌万'	
			WHEN V_MONEY5=9 THEN '玖万'
		END INTO PV_MONEY5;
	SELECT 
		CASE
			WHEN V_MONEY6=0 THEN ''
			WHEN V_MONEY6=1 THEN '壹拾'
			WHEN V_MONEY6=2 THEN '贰拾'
			WHEN V_MONEY6=3 THEN '叁拾'			
			WHEN V_MONEY6=4 THEN '肆拾'
			WHEN V_MONEY6=5 THEN '伍拾'
			WHEN V_MONEY6=6 THEN '陆拾'
			WHEN V_MONEY6=7 THEN '柒拾'	
			WHEN V_MONEY6=8 THEN '捌拾'	
			WHEN V_MONEY6=9 THEN '玖拾'
		END INTO PV_MONEY6;
	SELECT 
		CASE
			WHEN V_MONEY7=0 THEN ''
			WHEN V_MONEY7=1 THEN '壹佰'
			WHEN V_MONEY7=2 THEN '贰佰'
			WHEN V_MONEY7=3 THEN '叁佰'			
			WHEN V_MONEY7=4 THEN '肆佰'
			WHEN V_MONEY7=5 THEN '伍佰'
			WHEN V_MONEY7=6 THEN '陆佰'
			WHEN V_MONEY7=7 THEN '柒佰'	
			WHEN V_MONEY7=8 THEN '捌佰'	
			WHEN V_MONEY7=9 THEN '玖佰'
		END INTO PV_MONEY7;
	SELECT 
		CASE
			WHEN V_MONEY8=0 THEN ''
			WHEN V_MONEY8=1 THEN '壹仟'
			WHEN V_MONEY8=2 THEN '贰仟'
			WHEN V_MONEY8=3 THEN '叁仟'			
			WHEN V_MONEY8=4 THEN '肆仟'
			WHEN V_MONEY8=5 THEN '伍仟'
			WHEN V_MONEY8=6 THEN '陆仟'
			WHEN V_MONEY8=7 THEN '柒仟'	
			WHEN V_MONEY8=8 THEN '捌仟'	
			WHEN V_MONEY8=9 THEN '玖仟'
		END INTO PV_MONEY8;
	SELECT 
		CASE
			WHEN V_MONEY9=0 THEN '亿'
			WHEN V_MONEY9=1 THEN '壹亿'
			WHEN V_MONEY9=2 THEN '贰亿'
			WHEN V_MONEY9=3 THEN '叁亿'			
			WHEN V_MONEY9=4 THEN '肆亿'
			WHEN V_MONEY9=5 THEN '伍亿'
			WHEN V_MONEY9=6 THEN '陆亿'
			WHEN V_MONEY9=7 THEN '柒亿'	
			WHEN V_MONEY9=8 THEN '捌亿'	
			WHEN V_MONEY9=9 THEN '玖亿'
		END INTO PV_MONEY9;
	SELECT 
		CASE
			WHEN V_MONEY10=0 THEN ''
			WHEN V_MONEY10=1 THEN '壹拾'
			WHEN V_MONEY10=2 THEN '贰拾'
			WHEN V_MONEY10=3 THEN '叁拾'			
			WHEN V_MONEY10=4 THEN '肆拾'
			WHEN V_MONEY10=5 THEN '伍拾'
			WHEN V_MONEY10=6 THEN '陆拾'
			WHEN V_MONEY10=7 THEN '柒拾'	
			WHEN V_MONEY10=8 THEN '捌拾'	
			WHEN V_MONEY10=9 THEN '玖拾'
		END INTO PV_MONEY10;
	SELECT 
		CASE
			WHEN V_MONEY11=0 THEN ''
			WHEN V_MONEY11=1 THEN '壹佰'
			WHEN V_MONEY11=2 THEN '贰佰'
			WHEN V_MONEY11=3 THEN '叁佰'			
			WHEN V_MONEY11=4 THEN '肆佰'
			WHEN V_MONEY11=5 THEN '伍佰'
			WHEN V_MONEY11=6 THEN '陆佰'
			WHEN V_MONEY11=7 THEN '柒佰'	
			WHEN V_MONEY11=8 THEN '捌佰'	
			WHEN V_MONEY11=9 THEN '玖佰'
		END INTO PV_MONEY11;
	SELECT 
		CASE
			WHEN V_MONEY12=0 THEN ''
			WHEN V_MONEY12=1 THEN '壹仟'
			WHEN V_MONEY12=2 THEN '贰仟'
			WHEN V_MONEY12=3 THEN '叁仟'			
			WHEN V_MONEY12=4 THEN '肆仟'
			WHEN V_MONEY12=5 THEN '伍仟'
			WHEN V_MONEY12=6 THEN '陆仟'
			WHEN V_MONEY12=7 THEN '柒仟'	
			WHEN V_MONEY12=8 THEN '捌仟'	
			WHEN V_MONEY12=9 THEN '玖仟'
		END INTO PV_MONEY12;

	SET V_MONEY0=CONCAT(PV_MONEY12,PV_MONEY11,PV_MONEY10,PV_MONEY9,PV_MONEY8,PV_MONEY7,PV_MONEY6,PV_MONEY5,PV_MONEY4,PV_MONEY3,PV_MONEY2,PV_MONEY1,RPV_MONEY2,RPV_MONEY1);

	IF SUBSTR(V_MONEY0,1,1)='亿' THEN
		SET V_MONEY0=SUBSTR(V_MONEY0,2,LENGTH(V_MONEY0)-1);
	END IF;

	IF SUBSTR(V_MONEY0,1,1)='万' THEN
		SET V_MONEY0=SUBSTR(V_MONEY0,2,LENGTH(V_MONEY0)-1);
	END IF;

	SET V_MONEY0=REPLACE(V_MONEY0,'亿万','亿');

	IF locate('元',V_MONEY0)-locate('亿',V_MONEY0)=2 THEN
		SET V_MONEY0=REPLACE(V_MONEY0,'亿壹','亿零壹');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿贰','亿零贰');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿叁','亿零叁');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿肆','亿零肆');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿伍','亿零伍');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿陆','亿零陆');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿柒','亿零柒');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿捌','亿零捌');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿玖','亿零玖');
	END IF;

	SET V_MONEY0=REPLACE(V_MONEY0,'亿壹拾','亿零壹拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿贰拾','亿零贰拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿叁拾','亿零叁拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿肆拾','亿零肆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿伍拾','亿零伍拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿陆拾','亿零陆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿柒拾','亿零柒拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿捌拾','亿零捌拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿玖拾','亿零玖拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿壹佰','亿零壹佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿贰佰','亿零贰佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿叁佰','亿零叁佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿肆佰','亿零肆佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿伍佰','亿零伍佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿陆佰','亿零陆佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿柒佰','亿零柒佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿捌佰','亿零捌佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿玖佰','亿零玖佰');

	IF locate('元',V_MONEY0)-locate('万',V_MONEY0)=2 THEN
		SET V_MONEY0=REPLACE(V_MONEY0,'万壹','万零壹');
		SET V_MONEY0=REPLACE(V_MONEY0,'万贰','万零贰');
		SET V_MONEY0=REPLACE(V_MONEY0,'万叁','万零叁');
		SET V_MONEY0=REPLACE(V_MONEY0,'万肆','万零肆');
		SET V_MONEY0=REPLACE(V_MONEY0,'万伍','万零伍');
		SET V_MONEY0=REPLACE(V_MONEY0,'万陆','万零陆');
		SET V_MONEY0=REPLACE(V_MONEY0,'万柒','万零柒');
		SET V_MONEY0=REPLACE(V_MONEY0,'万捌','万零捌');
		SET V_MONEY0=REPLACE(V_MONEY0,'万玖','万零玖');
	END IF;

	SET V_MONEY0=REPLACE(V_MONEY0,'万壹拾','万零壹拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万贰拾','万零贰拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万叁拾','万零叁拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万肆拾','万零肆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万伍拾','万零伍拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万陆拾','万零陆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万柒拾','万零柒拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万捌拾','万零捌拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万玖拾','万零玖拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万壹佰','万零壹佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万贰佰','万零贰佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万叁佰','万零叁佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万肆佰','万零肆佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万伍佰','万零伍佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万陆佰','万零陆佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万柒佰','万零柒佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万捌佰','万零捌佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万玖佰','万零玖佰');

	IF locate('元',V_MONEY0)-locate('仟',V_MONEY0)=2 THEN
		SET V_MONEY0=REPLACE(V_MONEY0,'仟壹','仟零壹');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟贰','仟零贰');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟叁','仟零叁');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟肆','仟零肆');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟伍','仟零伍');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟陆','仟零陆');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟柒','仟零柒');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟捌','仟零捌');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟玖','仟零玖');
	END IF;

	SET V_MONEY0=REPLACE(V_MONEY0,'仟壹拾','仟零壹拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟贰拾','仟零贰拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟叁拾','仟零叁拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟肆拾','仟零肆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟伍拾','仟零伍拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟陆拾','仟零陆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟柒拾','仟零柒拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟捌拾','仟零捌拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟玖拾','仟零玖拾');

	IF locate('元',V_MONEY0)-locate('佰',V_MONEY0)=2 THEN
		SET V_MONEY0=REPLACE(V_MONEY0,'佰壹','佰零壹');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰贰','佰零贰');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰叁','佰零叁');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰肆','佰零肆');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰伍','佰零伍');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰陆','佰零陆');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰柒','佰零柒');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰捌','佰零捌');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰玖','佰零玖');
	END IF;

	IF V_MONEY0='元整' THEN
		SET V_MONEY0='零元';
	END IF;

	RETURN V_MONEY0;
END ||
delimiter;

drop PROCEDURE if EXISTS `account_singlerecycle_highsea_rule`;
delimiter ||
create PROCEDURE  account_singlerecycle_highsea_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
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
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
								and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

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
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		
	  if var_condition='or'  then
			 
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
		else
			 if @recycleselect is not null and @recycleselect<>'' then 
					set @tmpsql=concat(@tmpsql,' union all select ld_account.accountid,ld_account.allocatedate from ld_account left join  ' ,@recycleselect,' on ld_account.accountid=recyclewheretableset.accountid where  ld_account.deleted=0  and recyclewheretableset.accountid is null ');

				end if ;
				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');

		end if;
    
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
		

    if var_condition='or'  then
			
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
			end if;	
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();

			if var_condition='or'  then
			  
			 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				end if;	
			ELSE
		
			  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

		

end||
delimiter;


drop PROCEDURE if EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE PROCEDURE account_singlerecycle_normal_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
 
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
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
   
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.smownerid=ld_account.smownerid ');

			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		 
		  if var_iscycle ='yes' then 
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
			else
				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

			 end if;
      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


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
				
				if var_iscycle='yes' then 
					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
				else
						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname); 
						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
			   end if;

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then
				 
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
				end if;
		else
			 if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;
				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
		end if;

     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();


		if var_condition='or'  then
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
			
		      if @recycleselect<>'' and @recycleselect is not null THEN	
						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
					end if;	
				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
  
					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
					if @recycleselect<>'' and @recycleselect is not null THEN	 
					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				  end if;
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

drop PROCEDURE if EXISTS `execute_account_publicoperation`;
delimiter ||
create PROCEDURE  execute_account_publicoperation()
BEGIN
	select `status` into @status  from ld_account_set;


	if @status=0   then
		select DATE_FORMAT(eventdate,'%Y-%m-%d') into @eventdate from ld_sys_event where type='publicaccount' ORDER BY eventdate DESC LIMIT 1;
		if @eventdate!=CURDATE() then
			 update  ld_sys_event set eventdate=now() where type='publicaccount';
			call account_singlerecycle_normal_rule();
			call account_singlerecycle_highsea_rule();
		end if;

	end if;
end||
delimiter;

SET @tabid=22;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='description' LIMIT 1);
UPDATE ld_profile2field SET visible=0 WHERE tabid=@tabid AND fieldid=@fieldid;
delimiter;

UPDATE ld_documenttemplates SET body=REPLACE(body,'.font2 {','.font222 {');
UPDATE ld_documenttemplates SET body=REPLACE(body,'class="font2"','class="font222"');

UPDATE ld_documenttemplates SET body=REPLACE(body,'.font3 {','.font333 {');
UPDATE ld_documenttemplates SET body=REPLACE(body,'class="font3"','class="font333"');

UPDATE ld_documenttemplates SET body=REPLACE(body,'.font4 {','.font444 {');
UPDATE ld_documenttemplates SET body=REPLACE(body,'class="font4"','class="font444"');

DROP PROCEDURE IF EXISTS `ldcrm_reset_uitype230_20190312`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_uitype230_20190312`(
)
BEGIN

	DECLARE tmp_fieldid INT(19) DEFAULT 0;
	DECLARE tmp_columnname VARCHAR(200) DEFAULT ''; 
	DECLARE tmp_tablename VARCHAR(200) DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR SELECT fieldid,columnname,tablename FROM ld_field WHERE uitype=230 AND presence<>1;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_fieldid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_fieldid,tmp_columnname,tmp_tablename;
	WHILE(tmp_fieldid IS NOT NULL) DO
		SET @update_sql1=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", '.font2 {','.font222 {')");	
		SET @update_sql2=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", '.font3 {','.font333 {')");
		SET @update_sql3=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", '.font4 {','.font444 {')");
		SET @update_sql4=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", 'class=",'"font2"',"','class=",'"font222"',"')");	
		SET @update_sql5=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", 'class=",'"font3"',"','class=",'"font333"',"')");	
		SET @update_sql6=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", 'class=",'"font4"',"','class=",'"font444"',"')");	

		PREPARE stalter1 FROM @update_sql1;
		PREPARE stalter2 FROM @update_sql2;
		PREPARE stalter3 FROM @update_sql3;
		PREPARE stalter4 FROM @update_sql4;
		PREPARE stalter5 FROM @update_sql5;
		PREPARE stalter6 FROM @update_sql6;

		EXECUTE stalter1;
		EXECUTE stalter2;
		EXECUTE stalter3;
		EXECUTE stalter4;
		EXECUTE stalter5;
		EXECUTE stalter6;

		DEALLOCATE PREPARE stalter1;
		DEALLOCATE PREPARE stalter2;
		DEALLOCATE PREPARE stalter3;
		DEALLOCATE PREPARE stalter4;
		DEALLOCATE PREPARE stalter5;
		DEALLOCATE PREPARE stalter6;

		FETCH MYCUSOR INTO tmp_fieldid,tmp_columnname,tmp_tablename;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_reset_uitype230_20190312;
DROP PROCEDURE IF EXISTS `ldcrm_reset_uitype230_20190312`;
delimiter;


drop PROCEDURE if EXISTS `account_singlerecycle_highsea_rule`;
delimiter ||
create PROCEDURE  account_singlerecycle_highsea_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
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
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
								and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

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
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		
	  if var_condition='or'  then
			 
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
		else
			 
				if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');

		end if;
    
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
		

    if var_condition='or'  then
			
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
			end if;	
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();

			if var_condition='or'  then
			  
			 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				end if;	
			ELSE
		
			  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

		

end||
delimiter;

drop PROCEDURE if EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE PROCEDURE account_singlerecycle_normal_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
 
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
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
   
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.smownerid=ld_account.smownerid ');

			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		 
		  if var_iscycle ='yes' then 
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
			else
				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

			 end if;
      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


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
				
				if var_iscycle='yes' then 
					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
				else
						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname); 
						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
			   end if;

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then
				 
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
				end if;
		else
			 if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;
			
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
		end if;

     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();


		if var_condition='or'  then
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
			
		      if @recycleselect<>'' and @recycleselect is not null THEN	
						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
					end if;	
				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
  
					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
					if @recycleselect<>'' and @recycleselect is not null THEN	 
					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				  end if;
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
-- 2019-03-12


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
UPDATE ld_workreport_field_seq SET id=(SELECT MAX(id) FROM ld_workreport_field);
delimiter;

UPDATE ld_version SET old_version='V7.7.0',current_version='V7.7.0',remark='V7.7.0-20190312',wx_version='V7.7.0';
delimiter;