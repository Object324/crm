select sequence into @sequence from ld_homestuffdetail where stufflabel="NewInvoiceAmount" and stuffid=35;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
set @sequence=@sequence+1;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'NewQuotesCount','fixedstr','ld_quotes.quoteid','count','index.php?pageto_module=Quotes&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesCount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:createdtime:createdtime:Quotes_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:createdtime:createdtime:Quotes%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:approvestatus:approvestatus:Quotes_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:approvestatus:approvestatus:Quotes%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewQuotesCount','{$Quotes.Quotes}数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewQuotesCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewQuotesCount','New{$Quotes.Quotes}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewQuotesCount' and Labeltype='fixedstr');
delimiter;

UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;


select sequence into @sequence from ld_homestuffdetail where stufflabel="NewQuotesCount" and stuffid=35;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
set @sequence=@sequence+1;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'NewQuotesAmount','fixedstr','ld_quotes.total','sum','index.php?pageto_module=Quotes&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesAmount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesAmount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:createdtime:createdtime:Quotes_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:createdtime:createdtime:Quotes%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:approvestatus:approvestatus:Quotes_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:approvestatus:approvestatus:Quotes%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewQuotesAmount','{$Quotes.Quotes}金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewQuotesAmount' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewQuotesAmount','{$Quotes.Quotes} amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewQuotesAmount' and Labeltype='fixedstr');
delimiter;

UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;


update ld_homestuffdetail set cssname="item-ico-quotes" where stuffid=35 and stufflabel='NewQuotesAmount';
update ld_homestuffdetail set cssname="item-ico-quotes" where stuffid=35 and stufflabel='NewQuotesCount';
delimiter;

select sequence into @sequence from ld_homestuffdetail where stufflabel="NewCashBillCount" and stuffid=35;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
set @sequence=@sequence+1;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'NewPaymentPlanCashBillAmount','fixedstr','ld_cashbill.total','sum','index.php?pageto_module=CashBill&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewPaymentPlanCashBillAmount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewPaymentPlanCashBillAmount';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill:createdtime:createdtime:CashBill_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill:createdtime:createdtime:CashBill%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill:approvestatus:approvestatus:CashBill%') ;
delimiter;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill2paymentplan:entitytype:entitytype:CashBill_源单类型:V','e','PaymentPlan' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill2paymentplan:entitytype:entitytype:CashBill%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewPaymentPlanCashBillAmount','{$PaymentPlan.PaymentPlan}收款额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewPaymentPlanCashBillAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewPaymentPlanCashBillAmount','{$PaymentPlan.PaymentPlan} amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewPaymentPlanCashBillAmount' and Labeltype='fixedstr');
delimiter;

UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;


update ld_homestuffdetail set cssname="item-ico-cashbill" where stuffid=35 and stufflabel='NewPaymentPlanCashBillAmount';
update ld_homestuffdetail set sequence=sequence+1;
set @sequence=0;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'LeadUgradeToCustomerCount','fixedstr','ld_account.accountid','count','index.php?pageto_module=Accounts&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='LeadUgradeToCustomerCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='LeadUgradeToCustomerCount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:createdtime:createdtime:Accounts_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:createdtime:createdtime:Accounts%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:approvestatus:approvestatus:Accounts_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:approvestatus:approvestatus:Accounts%') ;
delimiter;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:kis_no:kis_no:Accounts_fieldlabel:V','e','from_leads' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:kis_no:kis_no:Accounts%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LeadUgradeToCustomerCount','线索升级到{$Accounts.Accounts}数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LeadUgradeToCustomerCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LeadUgradeToCustomerCount','The lead upgrade to{$Accounts.Accounts} count','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LeadUgradeToCustomerCount' and Labeltype='fixedstr');
delimiter;

UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;

UPDATE ld_field SET quickcreate=1 WHERE tablename='ld_contactrecords' AND columnname='location_address';
update ld_homestuffdetail set cssname="item-ico-account" where stuffid=35 and stufflabel='LeadUgradeToCustomerCount';
-- 2021-01-28

SET @disable_triggers=NULL;
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

UPDATE ld_version SET old_version='V8.3.7.2',current_version='V8.3.7.2',remark='V8.3.7.2-20210128',wx_version='V8.3.7.1';
delimiter;