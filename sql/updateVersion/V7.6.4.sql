UPDATE ld_producttoolfield SET defaultcolumn=1 WHERE columnname IN ('list_amount','tax_amount','tax_total','discount_amount',
	'actualtaxprice') AND tablename='ld_inventoryproductrel';
UPDATE ld_field SET displaytype=2 WHERE columnname='totalquantity';

UPDATE ld_tab SET presence=5 WHERE `name`='Rate' AND presence=0 AND NOT EXISTS (SELECT 1 FROM ld_rate);

DROP PROCEDURE IF EXISTS `rest_fieldlable_20181225`;
delimiter ||
CREATE PROCEDURE `rest_fieldlable_20181225`()
BEGIN

		IF NOT EXISTS (SELECT 1 FROM ld_project) THEN
			UPDATE ld_tab a
			LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab' AND b.languagetype='zh'
			SET b.fieldlabel='项目立项'
			WHERE a.`name`='Project'
				AND b.fieldlabel='项目';
		END IF;

		IF NOT EXISTS (SELECT 1 FROM ld_projecttask) THEN
			UPDATE ld_tab a
			LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab' AND b.languagetype='zh'
			SET b.fieldlabel='项目任务'
			WHERE a.`name`='ProjectTask'
				AND b.fieldlabel='项目计划';

		UPDATE ld_field a
		LEFT JOIN ld_tranlabel b ON a.fieldid=b.Relateid AND b.trantable='ld_field' AND b.languagetype='zh'
		SET a.fieldlabel='任务名称',b.fieldlabel='任务名称'
		WHERE a.tabid=47
			AND a.columnname='projecttaskname'
			AND b.fieldlabel='计划名称';

		UPDATE ld_field a
		LEFT JOIN ld_tranlabel b ON a.fieldid=b.Relateid AND b.trantable='ld_field' AND b.languagetype='zh'
		SET a.fieldlabel='任务类别',b.fieldlabel='任务类别'
		WHERE a.tabid=47
			AND a.columnname='projecttasktype'
			AND b.fieldlabel='计划类别';

		UPDATE ld_field a
		LEFT JOIN ld_tranlabel b ON a.fieldid=b.Relateid AND b.trantable='ld_field' AND b.languagetype='zh'
		SET a.fieldlabel='任务编号',b.fieldlabel='任务编号'
		WHERE a.tabid=47
			AND a.columnname='projecttask_no'
			AND b.fieldlabel='计划编号';

		UPDATE ld_field a
		LEFT JOIN ld_tranlabel b ON a.fieldid=b.Relateid AND b.trantable='ld_field' AND b.languagetype='zh'
		SET a.fieldlabel='任务工时',b.fieldlabel='任务工时'
		WHERE a.tabid=47
			AND a.columnname='timebudget'
			AND b.fieldlabel='计划工时';

		UPDATE ld_field a
		LEFT JOIN ld_tranlabel b ON a.fieldid=b.Relateid AND b.trantable='ld_field' AND b.languagetype='zh'
		SET a.fieldlabel='任务进度',b.fieldlabel='任务进度'
		WHERE a.tabid=47
			AND a.columnname='projecttaskprogress'
			AND b.fieldlabel='计划进度';
		END IF;

		IF NOT EXISTS (SELECT 1 FROM ld_timesheet) THEN
			UPDATE ld_tab a
			LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab' AND b.languagetype='zh'
			SET b.fieldlabel='项目工时'
			WHERE a.`name`='TimeSheet'
				AND b.fieldlabel='工时';
		END IF;


END ||
delimiter;

CALL rest_fieldlable_20181225();
DROP PROCEDURE IF EXISTS `rest_fieldlable_20181225`;
delimiter;
-- 2018-12-25

DELETE FROM ld_field WHERE columnname='reference' AND tabid=6;
SET @block=(SELECT block FROM ld_field WHERE tabid=4 AND columnname='mobile');
UPDATE ld_field SET block=@block WHERE tabid=4 AND columnname='faxx';
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 152;
update ld_systems_deploy set sequence = sequence + 1000 where inputtype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',199,'设置新增客户保存时是否判断工商局有无该公司名称','',@sequence+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type=199);
UPDATE ld_systems_deploy SET roottype=@roottype,sequence=@sequence+1 WHERE deploy_type=199;
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',199,199,'设置新增{$Accounts.Accounts}保存时是否判断工商局有无该公司名称' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=199 and tabid = 199);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',199,199,'Set whether to judge whether the industrial and commercial bureau has the company name when the new customer is saved' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=199 and tabid = 199);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thiecustomerbusiness','该客户工商信息不存在，无法保存！','jspop' from dual
where not exists(select  1 from ld_desk where languagetype='zh' and labeltype='jspop' and labelbol='thiecustomerbusiness');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','thiecustomerbusiness','This customer business information does not exist, cannot save!','jspop' from dual
where not exists(select  1 from ld_desk where languagetype='en' and labeltype='jspop' and labelbol='thiecustomerbusiness');
delimiter;

update ld_tranlabel set trantable='ld_field' where tabid in(select tabid from ld_tab where name='salesback')
and  trantable='ld_salesback';
update ld_field set allowedit='yes' where tabid in(select tabid from ld_tab where name='salesback')
and columnname='salesbackstatus';
delimiter;
-- 2018-12-26

UPDATE ld_tranlabel SET fieldlabel='设置 ERP 接口中订单数据同步的触发点' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=92;
UPDATE ld_tranlabel SET fieldlabel='设置 API 接口授权码（只能输入字母和数字）' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=105;
UPDATE ld_tranlabel SET fieldlabel='设置 API 接口 KEY（只能输入字母和数字）' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=106;

UPDATE ld_producttoolfield_formula 
SET formulastring='base_list_amount*c*(1-d/100)',
	columnstring="{formulavar:[base_list_amount,{'lettervar':'c','column':'quantity'},{'lettervar':'d','column':'discount_percent'}]}"
WHERE producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE columnname='list_amount')
	AND formulastring='base_list_amount*e*(1-d/100)'
	AND EXISTS (SELECT 1 FROM ld_version WHERE trade='puyoung');

select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
select sequence into @sequence from ld_settings_field where blockid=@blockid and name='WECHATAPPLETSETTINGS';
update ld_settings_field set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
update ld_settings_field set blockid=@blockid ,sequence = @sequence+1 where name='CUSTOMERSELFSERVICECONFIG';
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','SELFSERVICEQRCODE','客户自助服务平台二维码','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='SELFSERVICEQRCODE' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','SELFSERVICEQRCODE','Customer self-service platform two-dimensional code','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='SELFSERVICEQRCODE' and languagetype='en' and Labeltype='fixedstr');

update ld_desk set fieldlabel='小程序企业号设置' where labelbol='WECHATAPPLETSETTINGS' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Mini program enterprise number settings' where labelbol='WECHATAPPLETSETTINGS' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='客户自助服务平台二维码下载地址，到成员管理详情界面更多中生成下载' where labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Customer self-service platform two-dimensional code download address, to the member management details more interface to generate download' where labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' and Labeltype='fixedstr' and languagetype='en';

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','SELFSERVICEQRCODEEXPLAIN','可右键保存图片','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='SELFSERVICEQRCODEEXPLAIN' and languagetype='zh' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','SELFSERVICEQRCODEEXPLAIN','Right click to save the picture','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='SELFSERVICEQRCODEEXPLAIN' and languagetype='en' and Labeltype='jspop');

update ld_desk set fieldlabel='可右键保存图片' where labelbol='SELFSERVICEQRCODEEXPLAIN' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='Right click to save the picture' where labelbol='SELFSERVICEQRCODEEXPLAIN' and languagetype='en' and Labeltype='jspop';

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','SELFSERVICEQRCODE','客户自助服务平台二维码','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='SELFSERVICEQRCODE' and languagetype='zh' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','SELFSERVICEQRCODE','Customer self-service platform two-dimensional code','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='SELFSERVICEQRCODE' and languagetype='en' and Labeltype='jspop');

select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
select sequence into @sequence from ld_settings_field where blockid=@blockid and name='WECHATAPPLETSETTINGS';
update ld_settings_field set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
update ld_settings_field set blockid=@blockid ,sequence = @sequence+1 where name='CUSTOMERSELFSERVICECONFIG';
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;

update ld_weixinmp_fields set defaultvalue='' where modulename='Accounts' and fieldname='assigned_user_id' and defaultvalue='1' ;

update ld_desk set fieldlabel='客户自助服务平台小程序码' where labelbol='SELFSERVICEQRCODE' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Customer Self-Service Platform Small Program Code' where labelbol='SELFSERVICEQRCODE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='客户自助服务平台小程序码' where labelbol='SELFSERVICEQRCODE' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='Customer Self-Service Platform Small Program Code' where labelbol='SELFSERVICEQRCODE' and languagetype='en' and Labeltype='jspop';

update ld_tranlabel set fieldlabel='设置微信端拜访签到选择拜访对象是否为必填字段' where trantable = 'ld_systems_deploy' and tabid = 143 and Relateid = 143 and languagetype = 'zh';
update ld_tranlabel set fieldlabel='Set the WeChat visit check-in to select whether the visiting object is a required field' where trantable = 'ld_systems_deploy' and tabid = 143 and Relateid = 143 and languagetype = 'en';  
-- 2018-12-28 

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
    
DROP PROCEDURE IF EXISTS `crm_publicaccount_recoveryreminds`;
delimiter ||
CREATE PROCEDURE `crm_publicaccount_recoveryreminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			else
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				 call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

end||
delimiter;
-- 2018-12-29 

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

UPDATE ld_version SET old_version='V7.6.4',current_version='V7.6.4',remark='V7.6.4-20181229',wx_version='V7.6.4';
delimiter;