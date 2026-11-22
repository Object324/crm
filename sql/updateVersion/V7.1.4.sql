DROP PROCEDURE IF EXISTS `rest_cvcolumnlist_wx`;
delimiter ||
CREATE  PROCEDURE `rest_cvcolumnlist_wx`(
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

UPDATE ld_field SET quickcreate=1 WHERE tabid=6 AND columnname IN ('account_no','phone','smownerid');

UPDATE ld_field SET quickcreate=0,quickcreatesequence=1000 WHERE tabid=6 AND columnname='bill_street';
SET @block=(SELECT block FROM ld_field WHERE tabid=6 AND columnname='bill_street');
SET @i=0;
UPDATE ld_field SET quickcreatesequence=(@i:=@i+1) WHERE tabid=6 AND block=@block AND quickcreate IN (0,2) ORDER BY sequence;
delimiter;

UPDATE ld_field SET quickcreate=1 WHERE tablename='ld_contactrecords' AND columnname='potentialid';
-- 2017-12-13

UPDATE ld_field SET quickcreate=0 WHERE tabid=4 AND columnname IN('accountid','lastname','mobile','title');
UPDATE ld_field SET sequence=sequence+1000 WHERE tabid=4 AND quickcreate IN (0,2);
SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=4 AND columnname='accountid';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=4 AND columnname='lastname';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=4 AND columnname='mobile';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=4 AND columnname='title';
SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=4 AND presence<>1 AND quickcreate IN (0,2) ORDER BY sequence;

SET @i=0;
SET @block=(SELECT block FROM ld_field WHERE tabid=4 AND columnname='smownerid');
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=4 AND block=@block AND presence<>1 ORDER BY sequence;
delimiter;

SET @tabid=2;
SET @block=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
UPDATE ld_field SET sequence=sequence+1000 WHERE tabid=@tabid AND block=@block;
SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='potentialname';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='sales_stage';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='accountid';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='contactid';

SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block AND presence<>1 ORDER BY sequence;

SET @i=0;
UPDATE ld_field SET sequence=sequence+1000 WHERE tabid=@tabid AND block=@block;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block ORDER BY sequence;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Potentials';
CALL rest_cvcolumnlist_wx('Potentials','potentialname','1','1','no','yes');
CALL rest_cvcolumnlist_wx('Potentials','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('Potentials','sales_stage','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('Potentials','smownerid','3','2','yes','yes');
CALL rest_cvcolumnlist_wx('Potentials','amount','4','1','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Products';
CALL rest_cvcolumnlist_wx('Products','productname','1','1','no','yes');
CALL rest_cvcolumnlist_wx('Products','productsheet','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('Products','product_no','2','2','yes','yes');
CALL rest_cvcolumnlist_wx('Products','unit_price','3','1','yes','yes');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense');
UPDATE ld_option_module SET sequence=sequence+50 WHERE tabid=@tabid;

SET @i=0;
UPDATE ld_option_module SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND option_tabid=22;
UPDATE ld_option_module SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND option_tabid=37;
UPDATE ld_option_module SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND option_tabid=2;
UPDATE ld_option_module SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND option_tabid=13;

SET @i=0;
UPDATE ld_option_module SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords');
SET @block=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid AND columnname='smownerid';
UPDATE ld_field SET sequence=sequence+1000 WHERE tabid=@tabid AND block=@block;
SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='accountid';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='contactrecord_no';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='contactid';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='smownerid';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='contactrecordtype';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='contactdate';

SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block AND presence<>1 ORDER BY sequence;

SET @i=0;
UPDATE ld_field SET sequence=sequence+1000 WHERE tabid=@tabid AND block=@block;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block ORDER BY sequence;
delimiter;

UPDATE ld_field SET quickcreate=1,quickcreatesequence=NULL WHERE tabid=2 AND columnname='leadsource';


DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Contacts';
CALL rest_cvcolumnlist_wx('Contacts','lastname','1','1','no','yes');
CALL rest_cvcolumnlist_wx('Contacts','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('Contacts','mobile','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('Contacts','title','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='BusinessApply';
CALL rest_cvcolumnlist_wx('BusinessApply','businessapply_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('BusinessApply','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('BusinessApply','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('BusinessApply','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CardApply';
CALL rest_cvcolumnlist_wx('CardApply','cardapply_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('CardApply','smownerid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('CardApply','printnum','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('CardApply','applydate','3','2','yes','yes');


UPDATE ld_modentity_num SET UseUserAccount=0,isallow=0 WHERE NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_cvcolumnlist_wx SET showtag='yes' WHERE modulename IN ('Invoice','CashBill') AND columnname LIKE '%:total:%';

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=22 AND columnname='salesorder_no');
SET @cnt=(SELECT COUNT(1) FROM ld_tranlabel WHERE tabid=22 AND Relateid=22 AND fieldlabel like '%合同%' AND trantable='ld_tab');
UPDATE ld_tranlabel SET fieldlabel='合同编号' WHERE tabid=22 AND trantable='ld_field' AND Relateid=@fieldid AND fieldlabel='编号' AND @cnt>0;
delimiter;

UPDATE ld_tranlabel SET fieldlabel='编号' WHERE trantable='ld_field' AND fieldlabel='单据编号';
UPDATE ld_relatedlists SET presence=1 WHERE tabid=14 AND related_tabid=6;
UPDATE ld_field SET quickcreate=1 WHERE tabid=14 AND columnname='smownerid';
UPDATE ld_field SET quickcreate=1 WHERE tabid=14 AND columnname='discontinued';
UPDATE ld_field SET displaytype=3 WHERE columnname='approvestatus' AND tabid<>29;
UPDATE ld_field SET quickcreate=1 WHERE tabid=4 AND columnname IN ('contact_no','smownerid');
UPDATE ld_approve SET allowediting=0,allowantiapproval=0 WHERE tabid=20 AND `name`='报价单审批流程' AND NOT EXISTS (SELECT 1 FROM ld_quotes);


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');
SET @block=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
UPDATE ld_field SET sequence=sequence+100 WHERE tabid=@tabid AND block=@block;

SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='accountid';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='commissiontype';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='expensedate';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='smownerid';

SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block AND presence<>1 ORDER BY sequence;

SET @i=0;
UPDATE ld_field SET sequence=sequence+1000 WHERE tabid=@tabid AND block=@block;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block ORDER BY sequence;
delimiter;


DELETE FROM ld_cvcolumnlist_wx WHERE modulename='ContactRecords';
CALL rest_cvcolumnlist_wx('ContactRecords','accountid','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('ContactRecords','contactid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('ContactRecords','smownerid','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('ContactRecords','contactdate','3','2','yes','yes');
CALL rest_cvcolumnlist_wx('ContactRecords','content','4','1','yes','yes');

UPDATE ld_cvcolumnlist_wx SET showtag='yes' WHERE showtag='no' AND systemdefault='yes';
UPDATE ld_desk SET fieldlabel='备注' WHERE labelbol='DESCRIPTION' AND languagetype='zh';

DROP PROCEDURE IF EXISTS `ldcrm_reset_approve`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_approve`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT tabid FROM ld_approve ORDER BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2) THEN
		OPEN MYCUSOR; 
		FETCH MYCUSOR INTO tmp_tabid;
		WHILE(tmp_tabid IS NOT NULL) DO

			SET @cnt=(SELECT COUNT(1) FROM ld_approve WHERE tabid=tmp_tabid);
			SET @tablable=IFNULL((SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_tab' AND Relateid=tmp_tabid AND languagetype='zh' LIMIT 1),'');

			IF @cnt=1 THEN
				UPDATE ld_approve SET `name`=CONCAT(@tablable,'审批流程'),description=CONCAT(@tablable,'预置审批流程'),approveallocatetype=0,`status`=0,allowediting=0,allowantiapproval=0 WHERE tabid=tmp_tabid;
			ELSEIF @cnt>1 THEN
				SET @id=(SELECT MIN(id) FROM ld_approve WHERE tabid=tmp_tabid);
				DELETE FROM ld_approvestep WHERE approveid IN (SELECT id FROM ld_approve WHERE tabid=tmp_tabid AND approveid>@id);
				DELETE FROM ld_approve WHERE tabid=tmp_tabid AND id>@id;
				UPDATE ld_approve SET `name`=CONCAT(@tablable,'审批流程'),description=CONCAT(@tablable,'预置审批流程'),approveallocatetype=0,`status`=0,allowediting=0,allowantiapproval=0 WHERE id=@id;
				
			END IF;

			FETCH MYCUSOR INTO tmp_tabid;
		END WHILE;
		CLOSE MYCUSOR;

		DELETE FROM ld_approve2role;
        
        DELETE FROM ld_approve2user;
        INSERT INTO ld_approve2user(approveid,userid) SELECT id,-1 FROM ld_approve;

	END IF;
end ||
delimiter;

CALL ldcrm_reset_approve();
DROP PROCEDURE IF EXISTS `ldcrm_reset_approve`;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BusinessApply';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'days';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select  @tabdetailfieldid,'date_diff(c,b,days)',"{formulavar:[{'lettervar':'c','column':'endtime'},{'lettervar':'b','column':'starttime'}]}",0 from DUAL
where not exists(select 1 from ld_tabdetailfield_formula where tabdetailfieldid = @tabdetailfieldid);
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
delete from ld_fieldwxmaininfo where tabid=@tabid and fieldname='assigned_user_id';
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='Products';
delete from ld_fieldwxmaininfo where tabid=@tabid and fieldname='qtyinstock';
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='Accounts';
update ld_fieldwxmaininfo set fieldname='lastname',sequence=3 where fieldname='assigned_user_id' and tabid=@tabid;
update ld_fieldwxmaininfo set fieldname='mobile',sequence=4 where fieldname='rating' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
-- 2017-12-14

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Expense';
CALL rest_cvcolumnlist_wx('Expense','expense_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('Expense','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('Expense','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('Expense','smownerid','3','2','yes','yes');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE columnname='total' AND tablename='ld_minusjobbill');
UPDATE ld_tranlabel SET fieldlabel='合计时长' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='合计';
delimiter;

SET @fieldid=(SELECT fieldid FROM ld_field WHERE columnname='total' AND tablename='ld_addjobbill');
UPDATE ld_tranlabel SET fieldlabel='合计时长' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='合计';
delimiter;

SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tablename='ld_minusjobbill');
UPDATE ld_tranlabel SET fieldlabel='合计时长' WHERE trantable='ld_tabdetailfield' AND Relateid=@relateid AND languagetype='zh' AND fieldlabel='合计';
delimiter;

SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tablename='ld_addjobbill');
UPDATE ld_tranlabel SET fieldlabel='合计时长' WHERE trantable='ld_tabdetailfield' AND Relateid=@relateid AND languagetype='zh' AND fieldlabel='合计';
delimiter;

SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tablename='ld_businessapply');
UPDATE ld_tranlabel SET fieldlabel='合计天数' WHERE trantable='ld_tabdetailfield' AND Relateid=@relateid AND languagetype='zh' AND fieldlabel='合计';
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Commission';
CALL rest_cvcolumnlist_wx('Commission','commission_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('Commission','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('Commission','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('Commission','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='PaymentPlan';
CALL rest_cvcolumnlist_wx('PaymentPlan','paymentplan_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('PaymentPlan','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('PaymentPlan','amount','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('PaymentPlan','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Stock';
CALL rest_cvcolumnlist_wx('Stock','ware_stock_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('Stock','vendorid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('Stock','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('Stock','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='OutboundOrder';
CALL rest_cvcolumnlist_wx('OutboundOrder','out_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('OutboundOrder','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('OutboundOrder','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('OutboundOrder','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='SalesOrder';
CALL rest_cvcolumnlist_wx('SalesOrder','salesorder_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('SalesOrder','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('SalesOrder','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('SalesOrder','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='ServiceContracts';
CALL rest_cvcolumnlist_wx('ServiceContracts','contract_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('ServiceContracts','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('ServiceContracts','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('ServiceContracts','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='HelpDesk';
CALL rest_cvcolumnlist_wx('HelpDesk','ticket_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('HelpDesk','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('HelpDesk','status','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('HelpDesk','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='ServiceReturn';
CALL rest_cvcolumnlist_wx('ServiceReturn','servicereturn_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('ServiceReturn','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('ServiceReturn','troubleticketid','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('ServiceReturn','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Faq';
CALL rest_cvcolumnlist_wx('Faq','faq_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('Faq','category','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('Faq','smownerid','2','2','yes','yes');
CALL rest_cvcolumnlist_wx('Faq','question','3','1','yes','yes');


DELETE FROM ld_cvcolumnlist_wx WHERE modulename='NormalApprove';
CALL rest_cvcolumnlist_wx('NormalApprove','normalapprove_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('NormalApprove','normalapprovetype','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('NormalApprove','smownerid','2','2','yes','yes');
CALL rest_cvcolumnlist_wx('NormalApprove','description','3','1','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Project';
CALL rest_cvcolumnlist_wx('Project','projectname','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('Project','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('Project','smownerid','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('Project','projectstatus','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='ProjectTask';
CALL rest_cvcolumnlist_wx('ProjectTask','projecttaskname','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('ProjectTask','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('ProjectTask','smownerid','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('ProjectTask','projecttaskstatus','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='PurchaseOrder';
CALL rest_cvcolumnlist_wx('PurchaseOrder','purchaseorder_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('PurchaseOrder','vendorid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('PurchaseOrder','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('PurchaseOrder','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Invoice';
CALL rest_cvcolumnlist_wx('Invoice','invoice_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('Invoice','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('Invoice','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('Invoice','smownerid','3','2','yes','yes');

DROP PROCEDURE IF EXISTS `ldcrm_reset_billnolabel`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_billnolabel`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0; 
	DECLARE tmp_label VARCHAR(200) DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				b.tranlabelid,
				CONCAT(IFNULL((SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_tab' AND languagetype='zh' AND Relateid=a.tabid LIMIT 1),''),'编号')
			FROM ld_field a
			LEFT JOIN ld_tranlabel b ON a.fieldid=b.Relateid
			WHERE a.uitype=4
				AND b.trantable='ld_field'
				AND b.languagetype='zh'
				AND b.fieldlabel='编号';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id,tmp_label;
	WHILE(tmp_id IS NOT NULL) DO
	
		UPDATE ld_tranlabel SET fieldlabel=tmp_label WHERE tranlabelid=tmp_id;
		FETCH MYCUSOR INTO tmp_id,tmp_label;
	END WHILE;
	CLOSE MYCUSOR;


end ||
delimiter;

CALL ldcrm_reset_billnolabel();
DROP PROCEDURE IF EXISTS `ldcrm_reset_billnolabel`;
delimiter;

UPDATE ld_approvestep SET specifyapproverid=0 WHERE sequence=1 AND NOT EXISTS (SELECT 1 FROM ld_approvelog);

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CashBill';
CALL rest_cvcolumnlist_wx('CashBill','cashbill_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('CashBill','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('CashBill','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('CashBill','smownerid','3','2','yes','yes');

CALL del_idx('account_account_type_idx','ld_account');
CALL del_idx('account_parentid_idx','ld_account');
CALL del_idx('account_tickersymbol_idx','ld_account');
CALL del_idx('account_publicaccount','ld_account');
CALL del_idx('account_name','ld_account');
CALL del_idx('account_rating','ld_account');

CALL addtableIndex('ld_account','deleted','deleted'); 
CALL addtableIndex('ld_account','publicaccount','publicaccount'); 


CALL del_idx('Contactrecords_deleted_idx','ld_contactrecords');
CALL del_idx('Contactrecords_accountid_idx','ld_contactrecords');
CALL del_idx('contactdate','ld_contactrecords');
CALL del_idx('deleted','ld_contactrecords');
CALL addtableIndex('ld_contactrecords','deleted_createdtime_contactdate','contactdate, createdtime, deleted');
 
select tabid into @tabid from ld_tab where `name` = 'BusinessApply';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'days';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select  @tabdetailfieldid,'date_diff(c,b,days)',"{formulavar:[{'lettervar':'c','column':'endtime'},{'lettervar':'b','column':'starttime'}]}",0 from DUAL
where not exists(select 1 from ld_tabdetailfield_formula where tabdetailfieldid = @tabdetailfieldid);
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
delete from ld_fieldwxmaininfo where tabid=@tabid and fieldname='assigned_user_id';
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
select tabid into @tabid from ld_tab where name='Products';
delete from ld_fieldwxmaininfo where tabid=@tabid and fieldname='qtyinstock';
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
select tabid into @tabid from ld_tab where name='Accounts';
update ld_fieldwxmaininfo set fieldname='lastname',sequence=3 where fieldname='assigned_user_id' and tabid=@tabid;
update ld_fieldwxmaininfo set fieldname='mobile',sequence=4 where fieldname='rating' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

update ld_desk set fieldlabel='请输入客户名称！' where labelbol='pleaseenterthename' and labeltype='jspop' and languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SCREENINGRELATIONSHIP','筛选关系','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SCREENINGRELATIONSHIP' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SCREENINGRELATIONSHIP','Screening relationship','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SCREENINGRELATIONSHIP' and Labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SEARCHKEY','关键字','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SEARCHKEY' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SEARCHKEY','Key word','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SEARCHKEY' and Labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SELECTIONCRITERIA','选择条件','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SELECTIONCRITERIA' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SELECTIONCRITERIA','Selection criteria','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SELECTIONCRITERIA' and Labeltype = 'fixedstr');
delimiter;

insert into ld_dashboard_app(`name`,labelbol,image,presence,wx_presence,wx_sequence)
select 'Saleskit','saleskit','dashboard_6',2,1,0
from dual where not exists(select 1 from ld_dashboard_app where name='Saleskit');
set @i=0; 
update ld_dashboard_app set wx_sequence=(@i:=@i+1) where wx_presence = 1 order by wx_sequence; 
delimiter;
update ld_dashboard_app set image='dashboard_7' where name='Returnamount';
delimiter;

DELETE FROM ld_settings_field WHERE name='LBL_PAGE_SET' ;
delimiter;

UPDATE ld_tabdetailfield SET width=42 WHERE fieldtype='Date_YmdHms' AND width<42;
UPDATE ld_tabdetailfield SET width=width-4 WHERE columnname='description' AND width IN (100,46);
-- 2017-12-15

SET @tabid=6;
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'lastname',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'mobile',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'bill_street',3,'normal';

SET @tabid=13;
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'ticketstatus',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hopetime',3,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',4,'normal';


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact');
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'lastname',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'mobile',3,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'email',4,'normal';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords');
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'contactdate',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',3,'normal';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords');
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'contactdate',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'nextcontactdate',3,'normal';

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='QuotesChange';
CALL rest_cvcolumnlist_wx('QuotesChange','quoteschange_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('QuotesChange','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('QuotesChange','change_type','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('QuotesChange','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='VendorContact';
CALL rest_cvcolumnlist_wx('VendorContact','lastname','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('VendorContact','vendorid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('VendorContact','mobile','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('VendorContact','title','3','2','yes','yes');

DROP PROCEDURE IF EXISTS `ldcrm_reset_potentials_fields`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_potentials_fields`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_potential) THEN
		SET @tabid=2;
		SET @blockid=(SELECT max(blockid) FROM ld_blocks);
		SET @blocklabel='LBI_SALES_FORECAST';
		SET @en='Sales Forecast';
		SET @zh='销售预测';
		SET @seq=(SELECT sequence FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_OPPORTUNITY_INFORMATION');

		UPDATE ld_blocks SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@seq;

		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @blockid+1,@tabid,@blocklabel,@seq+1,0,0,0,0,0,1,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);

		UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

		SET @i=0;
		UPDATE ld_blocks SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid and blocklabel=@blocklabel);
		DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid=@blockid;
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,@en;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,@zh;

		SET @i=0;
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='sales_stage';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='lastsales_stage';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='closingdate';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='amount';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='possibility';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='cf_1308';

	END IF;

end ||
delimiter;

CALL ldcrm_reset_potentials_fields();
DROP PROCEDURE IF EXISTS `ldcrm_reset_potentials_fields`;
delimiter;

call AddColumn('ld_bangwo8','is_customer','int','11','0');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','iscustomer','是否同步客户到帮我吧','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'iscustomer' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','iscustomer','Do you synchronize customers to bangwo ba！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'iscustomer' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel='账号已存在' where labelbol='auserwiththesepecifiednamealreadyexists' and languagetype='zh' and labeltype='fixedstr';
delimiter;
-- 2017-12-18

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

update ld_version set old_version='V7.1.4',current_version='V7.1.4',remark='V7.1.4-20171215',wx_version='V9';
delimiter;