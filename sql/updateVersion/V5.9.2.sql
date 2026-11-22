select tabid into @tabid from ld_tab where `name` = 'Reminds';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'reltab';
delete from ld_tranlabel where tabid != @tabid and Relateid = @fieldid;
delimiter;

update ld_desk set fieldlabel = '请仔细确认单据信息,是否确认退货入库？' 
where labelbol = 'RETURNSWAREHOUSINGOPERATIONNOTREVERSIBLE' and languagetype = 'zh' and Labeltype = 'jspop';
delimiter;

DROP PROCEDURE IF EXISTS `updatecontactscolumnindex`;
delimiter ||
CREATE  PROCEDURE `updatecontactscolumnindex`(

)
begin

	declare tmp_cvid  int default 0;
	
	declare mycursor cursor for select cvid from ld_customview where entitytype='Contacts'; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = NULL;
	
	open mycursor;
	fetch mycursor into tmp_cvid;
	while(tmp_cvid is not null) DO
			
			update ld_cvcolumnlist set columnindex=columnindex+100 where cvid=tmp_cvid;
			update ld_cvcolumnlist set columnindex=0 where cvid=tmp_cvid and columnname like 'LD_contactdetails:lastname:lastname:%';
			
			set @i=0;
			update ld_cvcolumnlist set columnindex=(@i:=@i+1) where cvid=tmp_cvid order by columnindex;

			fetch mycursor into tmp_cvid;
	end while;
	close mycursor;
end ||
delimiter;

call updatecontactscolumnindex();
delimiter;

update ld_desk set fieldlabel='许可用户数' where languagetype='zh' and labelbol='LICENSEDUSER';
-- 2015-02-28

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHOWINGRECORDS','显示','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHOWINGRECORDS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SHOWINGRECORDS','Showing Records','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHOWINGRECORDS' and Labeltype='fixedstr');
delimiter;

UPDATE ld_usereport SET advfilter=0 WHERE name IN ('Contractnumber','Contractamount');
delimiter;

update ld_desk set Fieldlabel='该记录已审核，不能进行编辑！' where labelbol='TDHBCYCNES' and languagetype='zh' and Labeltype = 'jspop';
update ld_desk set Fieldlabel='The records have been audited, and cannot be edited!' where labelbol='TDHBCYCNES' and languagetype='en' and Labeltype = 'jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TDHBCYCNESMASSEDIT','您选择的记录中有已审批的单据，不能进行批量修改！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TDHBCYCNESMASSEDIT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TDHBCYCNESMASSEDIT','There has been the approval documents of your choice records, can not modify the batch!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TDHBCYCNESMASSEDIT' and Labeltype='jspop');
delimiter;

update ld_field set presence=1 where tabid=(select tabid from ld_tab where `name`='SendCashBill') and columnname='criscashbill' and exists (select 1 from ld_crmentity_seq where id=2);

select tabid into @tabid from ld_tab where `name`='PutCash';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
update ld_tranlabel set fieldlabel='修改时间' where tabid=@tabid and Relateid=@fieldid and trantable='LD_field' and languagetype='zh';
update ld_blocks set sequence=100 where tabid=@tabid and blocklabel='LBL_PUTCASH_DESCRIPTION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BANKACCOUNTCANNOTBEEMPTY','银行账户不能为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BANKACCOUNTCANNOTBEEMPTY' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BANKACCOUNTCANNOTBEEMPTY','Bank account can not be empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BANKACCOUNTCANNOTBEEMPTY' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DATESELECTION','日期选择','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DATESELECTION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DATESELECTION','Date Selection','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DATESELECTION' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_ONLYUPLOADXLSHTML','只允许上传xls、html格式的文件','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_ONLYUPLOADXLSHTML' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_ONLYUPLOADXLSHTML','Allow only upload XLS, HTML file format.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_ONLYUPLOADXLSHTML' AND Labeltype='fixedstr');
-- 2015-03-04

select tabid into @tabid from ld_tab where `name` = 'Products';
update ld_field set quickcreate = 2,masseditable=0 where tabid = @tabid and fieldname = 'taxclass';
delimiter;
delete from ld_cvcolumnlist where cvid in (select cvid from ld_customview where entitytype='Products') and columnname like 'LD_products:taxclass:taxclass%';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DATESELECTION','日期选择','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DATESELECTION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DATESELECTION','Date Selection','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DATESELECTION' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_ONLYUPLOADXLSHTML','只允许导入xls、html格式的文件','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_ONLYUPLOADXLSHTML' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_ONLYUPLOADXLSHTML','Allow only upload XLS, HTML file format.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_ONLYUPLOADXLSHTML' AND Labeltype='fixedstr');

delete from ld_cvcolumnlist where cvid in (select cvid from ld_customview where entitytype='Products') and columnname like 'LD_products:taxclass:taxclass%';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CALENDARVIEW','日历视图','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CALENDARVIEW' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CALENDARVIEW','Calendar View','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CALENDARVIEW' and Labeltype='fixedstr');
delimiter;
-- 2015-03-05


update ld_quickactions set presence=1 where tabid=6 
and related_tabid in (select tabid from ld_tab where `name` in('Invoice','PaymentPlan','Expense','Commission','Project','OutboundOrder','CashBill','HelpDesk'))
and exists(select 1 from ld_crmentity_seq where id=2);

select tabid into @tabid from ld_tab where `name` = 'CashDeposit';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname in('outaccount','inaccount');
delimiter;

select tabid into @tabid from ld_tab where name='ServiceCharge';
delete from ld_modtracker_tabs where tabid=@tabid;
insert into ld_modtracker_tabs
select @tabid,1; 
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Checks';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname ='wareid';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','YOUCHOOSETOHAVEALREADYCOUNTED','您选择的有已经盘点结束的记录，不能进行批量删除！','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUCHOOSETOHAVEALREADYCOUNTED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','YOUCHOOSETOHAVEALREADYCOUNTED','You choose to have already counted records, can not del the batch!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUCHOOSETOHAVEALREADYCOUNTED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','YOUCHOOSETOHAVEALREADYCOUNTEDEDIT','您选择的记录中有已经盘点结束的单据，不能进行批量修改！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUCHOOSETOHAVEALREADYCOUNTEDEDIT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','YOUCHOOSETOHAVEALREADYCOUNTEDEDIT','You choose to have already counted records, can not modify the batch!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUCHOOSETOHAVEALREADYCOUNTEDEDIT' and Labeltype='jspop');
delimiter;

update ld_field set issmownerid = 0 where tabid = (select tabid from ld_tab where `name` = 'Vendors') and fieldname='creator';
delimiter;

select tabid into @tabid from ld_tab where `name`='CashDeposit';
update ld_blocks set sequence=100 where tabid=@tabid and blocklabel='LBL_CASHDEPOSIT_DESCRIPTION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
-- 2015-03-09

update ld_cashbill LEFT JOIN ld_cashbill2paymentplan on ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID 
LEFT JOIN ld_paymentplan on ld_paymentplan.paymentplanid = ld_cashbill2paymentplan.paymentplanid 
set ld_cashbill.currency_id = ld_paymentplan.currency_id,
ld_cashbill.conversion_rate = ld_paymentplan.conversion_rate,
ld_cashbill.currency_symbol = ld_paymentplan.currency_symbol where (ld_cashbill.currency_id = '' or ld_cashbill.currency_id is NULL) and ld_cashbill2paymentplan.paymentplanid > 0;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ComplainSummaryreports','客诉汇总表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ComplainSummaryreports' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ComplainSummaryreports','Complain Summary reports','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ComplainSummaryreports' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Productcustomerservicefaultsummarytable','产品售后故障汇总表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Productcustomerservicefaultsummarytable' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Productcustomerservicefaultsummarytable','Product customer service fault summary table','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Productcustomerservicefaultsummarytable' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SinglewiretransfertableHotline','热线单来电汇总表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SinglewiretransfertableHotline' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SinglewiretransfertableHotline','Single wire transfer table Hotline','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SinglewiretransfertableHotline' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Productcustomerservicefailurein','产品售后故障占比图','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Productcustomerservicefailurein' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Productcustomerservicefailurein','Product customer service failure in','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Productcustomerservicefailurein' and Labeltype='fixedstr');
delimiter;

set @tabid=2;
select fieldname into @fieldname from ld_field where tabid=@tabid and helpinfo='absamount(预算绝对值)';
delete from  ld_fieldformulas where expression_engine like '%cf_1308%' or expression_engine is NULL;
select max(expressionid) into @expressionid from ld_fieldformulas;
insert into ld_fieldformulas(expressionid,modulename,expression_engine)
select @expressionid+1,'Potentials',concat('O:18:"VTExpressionEngine":6:{s:4:"data";a:0:{}s:11:"expressions";a:1:{s:7:"',@fieldname,'";O:10:"VTTreeNode":1:{s:3:"arr";a:3:{i:0;O:6:"Symbol":1:{s:5:"value";s:1:"*";}i:1;O:6:"Symbol":1:{s:5:"value";s:6:"amount";}i:2;O:10:"VTTreeNode":1:{s:3:"arr";a:3:{i:0;O:6:"Symbol":1:{s:5:"value";s:1:"/";}i:1;O:6:"Symbol":1:{s:5:"value";s:11:"possibility";}i:2;i:100;}}}}}s:19:"unparsedExpressions";a:1:{s:7:"',@fieldname,'";s:22:"amount*possibility/100";}s:4:"vars";a:1:{i:0;s:7:"',@fieldname,'";}s:12:"independents";a:0:{}s:10:"dependents";a:0:{}}');
update ld_fieldformulas_seq set id=(select max(expressionid) from ld_fieldformulas);
delimiter
-- 2015-03-10

delete from ld_remindcvstdfilter where startdate  is null;
delete from ld_remindcvstdfilter where enddate  is null;
-- 2015-03-11

update ld_tab set presence = 1 where `name` = 'SalesGoal' and exists (select * from ld_version where versiontype = 2);
update ld_tab set presence = 1 where `name` = 'SalesGoal' and exists (select * from ld_version where versiontype = 7);

set @tabid=0;
select tabid into @tabid from ld_tab where name='ServiceCharge';
update ld_tab set presence=1 where tabid=@tabid and exists (select 1 from ld_version where versiontype in (2,7));
delimiter;

update ld_tab set presence=1 where `name` in ('WareHouseTransfer','PurchaseInvoice','PurchaseOrder') and exists (select 1 from ld_version where versiontype in (2,5,7,10));
update ld_relatedlists set presence=1 where tabid=6 and `name`='get_balanceofaccount' and exists (select 1 from ld_version where versiontype in (2,7));
delimiter;

call AddColumn('LD_smssend','reminds_ruleid','int',11,1);
delimiter;
-- 2015-03-12


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
update lD_version set old_version='V5.9.2' ,current_version='V5.9.2' ,remark='V5.9.2-20150312';
delimiter;