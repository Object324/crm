UPDATE ld_field SET quickcreate=1 WHERE tabid=22 AND columnname IN ('duedate','sostatus');
UPDATE ld_field SET quickcreate=0 WHERE tabid=22 AND columnname IN ('salesorder_no','accountid','contactid','duedate','smownerid','filename');
UPDATE ld_field SET quickcreate=1 WHERE tabid=23 AND columnname IN ('invoice_num','invoicestatus');
UPDATE ld_field SET quickcreate=0 WHERE tabid=23 AND columnname IN ('accountid','invoice_no','invoicedate','invoicetype','smownerid','filename');
UPDATE ld_field SET quickcreate=0 WHERE tabid=23 AND uitype=202;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill');
UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid AND columnname IN ('bankaccountsetid','cashtype','description');
UPDATE ld_field SET quickcreate=0 WHERE tabid=@tabid AND columnname IN ('accountid','cashbill_no','smownerid','cashbilldate','filename');
UPDATE ld_field SET quickcreate=0 WHERE tabid=@tabid AND uitype=202;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense');
UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid AND columnname IN ('bankaccountsetid');
UPDATE ld_field SET quickcreate=0 WHERE tabid=@tabid AND columnname IN ('expensedate','expense_no','accountid','smownerid','filename','total');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');
UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid;

UPDATE ld_field SET quickcreate=1 WHERE tabid IN (SELECT tabid FROM ld_tab WHERE `name` IN ('HelpDesk','Project','ProjectTask','Rate'));
-- 2017-12-29

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

update ld_version set old_version='V7.1.7',current_version='V7.1.7',remark='V7.1.7-20171229',wx_version='V7.1.7';
delimiter;