insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'zh', 'ld_systems_deploy',140,140,'单据分录明细中录入价税合计重算的字段' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=140);

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_systems_deploy',140,140,'Reference field for product detail entry tax total recalculation' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=140);
delimiter;

select sequence into @sequence from ld_systems_deploy  where roottype=4 and deploy_type=124;
select deploy_type  into @deploy_type from ld_systems_deploy where deploy_type=140;
update  ld_systems_deploy set sequence=sequence+2 where sequence>@sequence and @deploy_type!=140 ;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 'listprice',140,'单据分录明细中录入价税合计重算的字段',@sequence+1,4,'select',0,'[{"value":"listprice","text":"LISTPRICE"},{"value":"discount","text":"DISCOUNT"},{"sql":""}]' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=140);
delimiter;

UPDATE ld_producttoolfield_formula 
SET formulastring="a*base_tax_amount*(1-(c/100))"
WHERE producttoolfieldid IN (SELECT producttoolfieldid FROM  ld_producttoolfield WHERE columnname='tax_amount')
	AND columnstring="{formulavar:[{'lettervar':'a','column':'quantity'},base_tax_amount,{'lettervar':'c','column':'discount_percent'}]}"
	AND formulastring="a*base_tax_amount*(1-c/100)";
-- 2017-07-28

select tabid into @tabid from ld_tab where `name` = 'Campaigns';
update ld_field set typeofdata = if(LOCATE('M', typeofdata) > 0,'V~M','V~O') where tabid = @tabid and columnname = 'product_id' and uitype = 59;
delimiter;

update ld_field set typeofdata = if(LOCATE('M', typeofdata) > 0,'V~M','V~O') where tabid = 6 and columnname = 'product_id' and uitype = 59;
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'module','tools_export_pdf','http://51mis.com.cn/forum.php?mod=viewthread&tid=45','灵当CRM如何导出PDF格式的打印模板' from DUAL
where not EXISTS(select 1 from ld_links where linktype = 'module' and linklabel = 'tools_export_pdf');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'ProductDetails','selectproduct','http://51mis.com.cn/forum.php?mod=viewthread&tid=55','产品名称通过模糊匹配（名称为英文+数字）匹配不到信息' from DUAL
where not EXISTS(select 1 from ld_links where linktype = 'ProductDetails' and linklabel = 'selectproduct');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'module','AttachmentBlock','http://51mis.com.cn/forum.php?mod=viewthread&tid=116','如何在CRM中预览office附件？' from DUAL
where not EXISTS(select 1 from ld_links where linktype = 'module' and linklabel = 'AttachmentBlock');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'MinusJobBill','MinusJobBillUser','http://51mis.com.cn/forum.php?mod=viewthread&tid=150&fromuid=1','如何计算员工年假？入职日期有何关联？' from DUAL
where not EXISTS(select 1 from ld_links where linktype = 'MinusJobBill' and linklabel = 'MinusJobBillUser');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'listview','listview','http://51mis.com.cn/forum.php?mod=viewthread&tid=151&fromuid=1','如何使用价格表' from DUAL
where not EXISTS(select 1 from ld_links where tabid = @tabid and  linktype = 'listview' and linklabel = 'listview');
delimiter;

call AddColumn('ld_blocks','linkid','varchar','20',NULL);
select linkid into @linkid from ld_links where linktype = 'module' and linklabel = 'AttachmentBlock';
update ld_blocks set linkid = CONCAT(@linkid,'|edit') where blocklabel in ('LBL_FILE_INFORMATION','LBL_NORMALAPPROVE_FILE','LBL_ADDJOBBILL_FILE',
'LBL_MINUSJOBBILL_FILE','LBL_BUSINESSAPPLY_FILE','LBL_LOANAPPLY_FILE','LBL_CARDAPPLY_FILE','LBI_ATTACHMENT_FILE','ATTACHMENTS_LBL_ATTACHMENTS_INFO');
delimiter;

select linkid into @linkid from ld_links where linktype = 'MinusJobBill' and linklabel = 'MinusJobBillUser';
update ld_blocks set linkid = CONCAT(@linkid,'|detailview') where blocklabel in ('LBL_USERLOGIN_ROLE','LBL_MINUSJOBBILL_BASICINFORMATION');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
select linkid into @linkid from ld_links where tabid=@tabid and linktype = 'listview' and linklabel = 'listview';
update ld_blocks set linkid = CONCAT(@linkid,'|detailview') where blocklabel in ('LBL_PRICEBOOK_INFORMATION');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'account_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'contact_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

update ld_tab set mobilepresence=',weixin' where name='CashBill';
delimiter;

select linkid into @linkid from ld_links where linktype = 'module' and linklabel = 'AttachmentBlock';
update ld_blocks set linkid = @linkid where blocklabel in ('LBL_FILE_INFORMATION','LBL_NORMALAPPROVE_FILE','LBL_ADDJOBBILL_FILE',
'LBL_MINUSJOBBILL_FILE','LBL_BUSINESSAPPLY_FILE','LBL_LOANAPPLY_FILE','LBL_CARDAPPLY_FILE','LBI_ATTACHMENT_FILE','ATTACHMENTS_LBL_ATTACHMENTS_INFO');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BusinessApply';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
delimiter;
-- 2017-08-03

DROP PROCEDURE IF EXISTS `ldcrm_update_sykq_all`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_sykq_all`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE mycursor CURSOR FOR 
			SELECT DISTINCT smownerid FROM ld_addjobbill
			UNION 
			SELECT DISTINCT smownerid FROM ld_minusjobbill ORDER BY smownerid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN mycursor;
	Fetch mycursor INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		CALL ldcrm_update_sykq_byuserid(tmp_id);
		Fetch mycursor INTO tmp_id;
	END WHILE;
	CLOSE mycursor;
END ||
delimiter;

SET GLOBAL event_scheduler = ON;
DROP EVENT IF EXISTS `ldcrm_update_sykq__everyday`;
CREATE EVENT `ldcrm_update_sykq__everyday`
ON SCHEDULE EVERY 1 DAY STARTS '2017-08-07 00:00:59'
ON COMPLETION PRESERVE 
ENABLE
DO

CALL ldcrm_update_sykq_all();
delimiter;

UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=74 AND NOT EXISTS (SELECT 1 FROM ld_account);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=108 AND NOT EXISTS (SELECT 1 FROM ld_contactdetails);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=109 AND NOT EXISTS (SELECT 1 FROM ld_vendor);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=139 AND NOT EXISTS (SELECT 1 FROM ld_vendorcontacts);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=138 AND NOT EXISTS (SELECT 1 FROM ld_potential);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=119 AND NOT EXISTS (SELECT 1 FROM ld_project);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=116 AND NOT EXISTS (SELECT 1 FROM ld_salesorder);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=117 AND NOT EXISTS (SELECT 1 FROM ld_servicecontracts);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=118 AND NOT EXISTS (SELECT 1 FROM ld_purchaseorder);

DROP PROCEDURE IF EXISTS `ldcrm_update_attachments_notes`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_attachments_notes`(
)
BEGIN

	DECLARE tmp_crmid INT(19) DEFAULT 0;
	DECLARE tmp_attid INT(19) DEFAULT 0;

	DECLARE mycursor CURSOR FOR 
				SELECT
					b.crmid,
					b.attachmentsid
				FROM ld_notes a
				INNER JOIN ld_seattachmentsrel b ON a.notesid=b.crmid
				ORDER BY b.crmid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_crmid = NULL;
	
	OPEN mycursor;
	FETCH mycursor INTO tmp_crmid,tmp_attid;
	WHILE(tmp_crmid IS NOT NULL) DO
		SET @sql1=CONCAT("UPDATE ld_attachments SET `name`=REPLACE(`name`,'",tmp_crmid,"_','",tmp_attid,"_') WHERE attachmentsid=",tmp_attid);
		PREPARE stalter FROM @sql1;
		EXECUTE stalter;
		FETCH mycursor INTO tmp_crmid,tmp_attid;
	END WHILE;
	CLOSE mycursor;
END ||
delimiter;

CALL ldcrm_update_attachments_notes();
delimiter;

CALL AddColumn('ld_version','wx_version','varchar','50',null);
delimiter;

UPDATE ld_version SET wx_version='V3' WHERE current_version like 'V7.%';
UPDATE ld_version SET wx_version='V2' WHERE current_version like 'V6.%';
delimiter;

update ld_crmentity set setype = 'Attachment' where setype = 'Documents Attachment'; 
delimiter;

call altercolumnfor_primarykey('ld_expensescf','expenseid');
delimiter;
-- 2017-08-07

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

update ld_version set old_version='V7.0.8',current_version='V7.0.8',remark='V7.0.8-20170807';
delimiter;