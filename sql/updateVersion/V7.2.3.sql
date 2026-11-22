select tabid into @tabid from ld_tab where name='contactrecords';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
update ld_tranlabel set fieldlabel='负责人' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid and fieldlabel='销售负责人';
delimiter;
-- 2018-01-15

UPDATE ld_field SET quickcreate=0 WHERE tabid=13 AND columnname IN ('accountid','category','productcategory','hopetime')
	AND NOT EXISTS (SELECT 1 FROM ld_troubletickets);
UPDATE ld_approve a
LEFT JOIN ld_approvestep b ON a.id=b.approveid
SET b.ended=0,b.specifyapproverid=0
WHERE a.description LIKE '%预置审批流程'
	AND NOT EXISTS (SELECT 1 FROM ld_approvelog);
    
update ld_relatedlists set type='sendcashbillsourcebill_datacategory_sql',related_coltable='tmp_related_cashbill.entitytypeid' where tabid=21 and name='get_SendCashBill';
delimiter;

update ld_desk set fieldlabel = '可见角色设置' where languagetype = 'zh' and labelbol = 'INVISIBLEROLESET';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');
UPDATE ld_tabdetailfield SET typeofdata='N~O~25,2' WHERE tabid=@tabid AND columnname='rate';
delimiter;

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=29 AND columnname='wx_userid');
UPDATE ld_tranlabel SET fieldlabel='企业微信通讯录帐号' WHERE Relateid=@fieldid AND tabid=29 AND languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOEDITAPPROVESTEP','说明：该审批流程正在使用，不能修改当前界面的内容','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'NOEDITAPPROVESTEP' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOEDITAPPROVESTEP','The approval process is in use and can not modify the content of the current interface','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'NOEDITAPPROVESTEP' and labeltype = 'fixedstr');
delimiter;
update ld_tranlabel set fieldlabel='设置移动端拜访签到上传图片时是否允许选择相册图片' where trantable='ld_systems_deploy' and Relateid=114 and languagetype='zh';
update ld_tranlabel set fieldlabel='微信端拜访签到选择客户功能的控制方式' where trantable='ld_systems_deploy' and Relateid=143 and languagetype='zh';
delimiter;

DROP PROCEDURE IF EXISTS `reset_cvcolumnlist_wx20180117`;
delimiter ||
CREATE  PROCEDURE `reset_cvcolumnlist_wx20180117`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Accounts';
		CALL rest_cvcolumnlist_wx('Accounts','accountname','1','1','no','yes');
		CALL rest_cvcolumnlist_wx('Accounts','bill_street','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Accounts','lastname','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Accounts','mobile','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Contacts';
		CALL rest_cvcolumnlist_wx('Contacts','lastname','1','1','no','yes');
		CALL rest_cvcolumnlist_wx('Contacts','accountid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Contacts','mobile','3','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='ContactRecords';
		CALL rest_cvcolumnlist_wx('ContactRecords','accountid','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('ContactRecords','contactid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('ContactRecords','contactdate','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('ContactRecords','content','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Potentials';
		CALL rest_cvcolumnlist_wx('Potentials','potentialname','1','1','no','yes');
		CALL rest_cvcolumnlist_wx('Potentials','accountid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Potentials','sales_stage','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Potentials','amount','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='SalesOrder';
		CALL rest_cvcolumnlist_wx('SalesOrder','accountid','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('SalesOrder','salesorder_no','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('SalesOrder','total','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('SalesOrder','smownerid','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Invoice';
		CALL rest_cvcolumnlist_wx('Invoice','invoice_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Invoice','accountid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Invoice','total','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Invoice','smownerid','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CashBill';
		CALL rest_cvcolumnlist_wx('CashBill','cashbill_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('CashBill','accountid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('CashBill','total','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('CashBill','smownerid','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Products';
		CALL rest_cvcolumnlist_wx('Products','productname','1','1','no','yes');
		CALL rest_cvcolumnlist_wx('Products','productsheet','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Products','product_no','3','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='NormalApprove';
		CALL rest_cvcolumnlist_wx('NormalApprove','normalapprove_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('NormalApprove','normalapprovetype','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('NormalApprove','smownerid','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('NormalApprove','description','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='AddJobBill';
		CALL rest_cvcolumnlist_wx('AddJobBill','addjobbill_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('AddJobBill','smownerid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('AddJobBill','total','3','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='MinusJobBill';
		CALL rest_cvcolumnlist_wx('MinusJobBill','minusjobbill_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('MinusJobBill','smownerid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('MinusJobBill','total','3','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='BusinessApply';
		CALL rest_cvcolumnlist_wx('BusinessApply','businessapply_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('BusinessApply','accountid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('BusinessApply','total','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('BusinessApply','smownerid','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='LoanApply';
		CALL rest_cvcolumnlist_wx('LoanApply','loanapply_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('LoanApply','smownerid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('LoanApply','loanmoney','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('LoanApply','paymentdate','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CardApply';
		CALL rest_cvcolumnlist_wx('CardApply','cardapply_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('CardApply','smownerid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('CardApply','printnum','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('CardApply','applydate','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Expense';
		CALL rest_cvcolumnlist_wx('Expense','expense_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Expense','accountid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Expense','total','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Expense','smownerid','4','1','yes','yes');

		DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Commission';
		CALL rest_cvcolumnlist_wx('Commission','commission_no','1','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Commission','accountid','2','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Commission','total','3','1','yes','yes');
		CALL rest_cvcolumnlist_wx('Commission','smownerid','4','1','yes','yes');
	END IF;
end ||
delimiter;

CALL reset_cvcolumnlist_wx20180117();
DROP PROCEDURE IF EXISTS `reset_cvcolumnlist_wx20180117`;
delimiter;
-- 2018-01-17

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

update ld_version set old_version='V7.2.3',current_version='V7.2.3',remark='V7.2.3-20180117',wx_version='V7.2.3';
delimiter;