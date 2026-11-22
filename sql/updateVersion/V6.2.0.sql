select tabid into @tabid from ld_tab where `name` = 'Reminds';
update ld_field set displaytype = 2 where tabid = @tabid and fieldname = 'reltab';
delimiter;

call AddColumn('ld_approve','approveallocatetype','int','11', 0); 
delimiter;

UPDATE ld_approve SET approveallocatetype=0
WHERE id IN
(
  SELECT approveid FROM ld_approve2user WHERE userid=-1
) and ld_approve.approveallocatetype is null ;
UPDATE ld_approve SET approveallocatetype=2
WHERE id IN
(
  SELECT approveid FROM ld_approve2user WHERE userid <>-1
)  and( ld_approve.approveallocatetype=0  or ld_approve.approveallocatetype is null);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DISTRIBUT','分配 ','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DISTRIBUT' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DISTRIBUT','Distribut','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DISTRIBUT' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

delete from ld_desk  where labelbol = 'APPLICABLESCOPE'  and labeltype = 'jspop';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPLICABLESCOPE','适用范围 ','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'APPLICABLESCOPE' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPLICABLESCOPE','Applicable scope','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'APPLICABLESCOPE' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETBYDEPARTMENT','按部门 ','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SETBYDEPARTMENT' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETBYDEPARTMENT','Set by department','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SETBYDEPARTMENT' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETBYUSERS','按用户 ','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SETBYUSERS' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETBYUSERS','Set by user','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SETBYUSERS' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

call AddColumn('ld_templateprint','allocatetype','int','11', 0);
delimiter;

UPDATE ld_templateprint SET allocatetype=0
WHERE templateprintid IN
(
  SELECT templateprintid FROM ld_templateprint2user WHERE userid=-1
)  and allocatetype is null;
UPDATE ld_templateprint SET allocatetype=2
WHERE templateprintid IN
(
  SELECT templateprintid FROM ld_templateprint2user WHERE userid<>-1
)  and (allocatetype=0 or allocatetype is null);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEINPUTYOUWANTTOFINDTHEGROUP','请输入要查找的部门','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASEINPUTYOUWANTTOFINDTHEGROUP' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEINPUTYOUWANTTOFINDTHEGROUP','please input you want to find the group','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASEINPUTYOUWANTTOFINDTHEGROUP' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPLICABLESCOPE','适用范围 ','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'APPLICABLESCOPE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPLICABLESCOPE','Applicable scope','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'APPLICABLESCOPE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
-- 2015-12-15

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','SERVICE_HISTORY','服务单历史记录','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SERVICE_HISTORY' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','SERVICE_HISTORY','Service history','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SERVICE_HISTORY' and Labeltype='fixedstr');
delimiter;

SELECT tabid into @tabid from ld_tab WHERE `name` ='PublicAnnouncement';
UPDATE ld_field SET uitype =230 WHERE tabid = @tabid AND columnname='content' and tablename = 'ld_publicannouncement' and uitype = 19;
delimiter;

call AddColumn('ld_emailtemplates','smcreatorid','int',11,0);
delimiter;

set @i=50;
update ld_tab set tabsequence=@i+1 where `name`='Project';
update ld_tab set tabsequence=@i+2 where `name`='ProjectTask';
update ld_tab set tabsequence=@i+3 where `name`='ProjectProgress';
update ld_tab set tabsequence=@i+4 where `name`='ProjectMilestone';
update ld_tab set tabsequence=@i+5 where `name`='Rate';
set @i=0;
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Tools';
select tabid into @tabid from ld_tab where `name`='PublicAnnouncement';
update ld_parenttabrel set sequence=sequence+1 where parenttabid=@parenttabid;
update ld_parenttabrel set sequence=0 where parenttabid=@parenttabid and tabid=@tabid;

set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=@parenttabid order by sequence;
delimiter;
-- 2015-12-16

SELECT tabid INTO @tabid from ld_tab WHERE NAME ='CommunicationLog';
INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,2 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=2);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'rate' and fieldname = 'rate';
update ld_tranlabel set fieldlabel = '费率' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
delimiter;
-- 2015-12-17

update ld_relatedlists set mobile_presence = 0 where tabid = 6 and label = 'Products';
delimiter;

set @tabid=29;
update ld_blocks set sequence=sequence+50 where tabid=@tabid and blocklabel='LBL_ATTACHMENTS_INFOMATION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
-- 2015-12-18

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobilePurchaseOrder',1,50,'mobilePurchaseOrder',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobilePurchaseOrder');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobilePurchaseOrder' and entitytype='mobilePurchaseOrder');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobilePurchaseOrder',0,0,'mobilePurchaseOrder',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobilePurchaseOrder' and entitytype='mobilePurchaseOrder');
select cvid into @cvid   from ld_customview where viewname='mobilePurchaseOrder' and entitytype='mobilePurchaseOrder';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobilePurchaseOrder' and entitytype='mobilePurchaseOrder' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:V' );
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileExpense',1,50,'mobileExpense',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileExpense');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileExpense' and entitytype='mobileExpense');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileExpense',0,0,'mobileExpense',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileExpense' and entitytype='mobileExpense');
select cvid into @cvid   from ld_customview where viewname='mobileExpense' and entitytype='mobileExpense';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileExpense' and entitytype='mobileExpense' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_expense:expense_no:expense_no:Expense_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_expense:accountid:account_id:Expense_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_expense:total:hdnGrandTotal:Expense_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_expense:smownerid:assigned_user_id:Expense_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_expense:expensedate:expensedate:Expense_fieldlabel:V' );
delimiter;

call AddColumn('ld_lead_view','picklist_valueid','int',11,0); 
delimiter;
call AddColumn('ld_approvestatus','presence','int',11,0);
delimiter;
call AddColumn('ld_approvestatus','picklist_valueid','int',11,0);
update ld_approvestatus set presence = 1;
delimiter;

call AddColumn('ld_activity_view','picklist_valueid','int',11,0);
delimiter;
call AddColumn('ld_currency_grouping_pattern','picklist_valueid','int',11,0);
delimiter;
call AddColumn('ld_currency_decimal_separator','picklist_valueid','int',11,0);
delimiter;
call AddColumn('ld_currency_grouping_separator','picklist_valueid','int',11,0);
delimiter;
call AddColumn('ld_currency_symbol_placement','picklist_valueid','int',11,0);
delimiter;
call AddColumn('ld_reminder_interval','picklist_valueid','int',11,0);
delimiter;
call AddColumn('ld_visibility','picklist_valueid','int',11,0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOTCREATERELVANTBILL','该单据未审核，不允许创建相关联的单据！','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NOTCREATERELVANTBILL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NOTCREATERELVANTBILL','The record has not approved, not allow to create a relevant bill!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NOTCREATERELVANTBILL' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel='该单据未审核，不允许创建相关联的单据！' where labelbol='NOTCREATERELVANTBILL' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='The record has not approved, not allow to create a relevant bill!' where labelbol='NOTCREATERELVANTBILL' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

select tabid into @tabid from ld_tab where name='rate';
select  fieldid into @fieldid from ld_field where tabid=@tabid and columnname='ratename';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,1,1,1 from dual 
where not exists(select  1 from ld_relatedlists_lable where tabid=@tabid and  fieldid=@fieldid);

select  fieldid into @fieldid from ld_field where tabid=@tabid and columnname='rate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,2,1,0 from dual 
where not exists(select  1 from ld_relatedlists_lable where tabid=@tabid and  fieldid=@fieldid);

select  fieldid into @fieldid from ld_field where tabid=@tabid and columnname='startdate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,3,1,0 from dual 
where not exists(select  1 from ld_relatedlists_lable where tabid=@tabid and  fieldid=@fieldid);

select  fieldid into @fieldid from ld_field where tabid=@tabid and columnname='enddate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,4,1,0 from dual 
where not exists(select  1 from ld_relatedlists_lable where tabid=@tabid and  fieldid=@fieldid);

select  fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,5,1,0 from dual 
where not exists(select  1 from ld_relatedlists_lable where tabid=@tabid and  fieldid=@fieldid);

select  fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,6,1,0 from dual 
where not exists(select  1 from ld_relatedlists_lable where tabid=@tabid and  fieldid=@fieldid);

select  fieldid into @fieldid from ld_field where tabid=@tabid and columnname='strrole_id';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,7,1,0 from dual 
where not exists(select  1 from ld_relatedlists_lable where tabid=@tabid and  fieldid=@fieldid);
delimiter;
-- 2015-12-21

update ld_tranlabel set fieldlabel='计划工时' where languagetype='zh' and trantable='ld_field' and fieldlabel='工时预算' and tabid in (47,48);
update ld_desk set labelbol='THESINGNINGAMOUNTOFBILLBOARD' where labelbol='The billboard of Receivables';
update ld_usereport set `name`='THESINGNINGAMOUNTOFBILLBOARD' where `name`='The billboard of Receivables';

update ld_field set uitype=1 where tabid=4 and columnname='firstname';
select tabid into @tabid from ld_tab where name='vendorcontact';
update ld_field set uitype=1 where tabid=@tabid and columnname='firstname';
delimiter;

insert into ld_sendinformcontent(content,type,description)
select '尊敬的客户您好，您订购的产品已退货。请注意查收！',8,'销售退货单短信' from DUAL
where not EXISTS(select 1 from ld_sendinformcontent where type=8);
delimiter;

update
ld_salesorder a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;

update
ld_servicecontracts e
INNER JOIN ld_currency_info f on e.currency_id=f.id
set e.conversion_rate=f.conversion_rate
where e.conversion_rate=0 or e.conversion_rate is NULL;
	
update ld_salesorder set currency_id=1,conversion_rate=1.000000 where currency_id=0;


DROP PROCEDURE IF EXISTS `update_sales_total`;
delimiter ||
CREATE  PROCEDURE `update_sales_total`(
	tmp_cashbillid INT(19)
)
BEGIN
	
	declare tmp_entitytypeid int;
	declare cur1 CURSOR FOR select distinct
															b.entitytypeid
															from ld_cashbill a 
															inner join ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID where a.cashbillid=tmp_cashbillid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	set @deploy_value=0;
	select deploy_value into @deploy_value from ld_systems_deploy where deploy_type=83;
		
	OPEN cur1;
	Fetch cur1 into tmp_entitytypeid;
	while(tmp_entitytypeid is not null) DO
			set	@tmp_entitytypeid=0;
			set @tmp_entitytypeid=tmp_entitytypeid;
			IF @deploy_value=0 THEN	
				set @cnt1=0;
				select 
					count( DISTINCT currency_id) into @cnt1 
					from 
						(select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid
							UNION ALL
								select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid
							UNION ALL
								select a.currency_id 
								from ld_cashbill a
								LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								where b.entitytypeid=@tmp_entitytypeid) c;
					IF @cnt1=1 THEN
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;

								update ld_salesorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where salesorderid=@tmp_entitytypeid;
								update ld_servicecontracts set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where servicecontractsid=@tmp_entitytypeid;
			
					ELSE
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount/a.conversion_rate as amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan/e.conversion_rate as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;

					update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where salesorderid=@tmp_entitytypeid;
					update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where servicecontractsid=@tmp_entitytypeid;					
					End IF;
			ELSE
				set @cnt1=0;
				select 
					count( DISTINCT currency_id) into @cnt1 
					from 
						(select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid
							UNION ALL
								select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid
							UNION ALL
								select a.currency_id 
								from ld_cashbill a
								LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								where b.entitytypeid=@tmp_entitytypeid and a.checkoutstatus='已审核') c;
					IF @cnt1=1 THEN
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0 and a.checkoutstatus='已审核'
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;
							
							update ld_salesorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where salesorderid=@tmp_entitytypeid;
							update ld_servicecontracts set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where servicecontractsid=@tmp_entitytypeid;
					
					ELSE
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount/a.conversion_rate as amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0 and a.checkoutstatus='已审核'
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan/e.conversion_rate as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;

					update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where salesorderid=@tmp_entitytypeid;
					update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where servicecontractsid=@tmp_entitytypeid;					
					End IF;
			END IF;
				
			Fetch cur1 into tmp_entitytypeid;
	end while;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `update_sales_total1`;
delimiter ||
CREATE  PROCEDURE `update_sales_total1`(
)
BEGIN
	
	declare tmp_entitytypeid int;
	declare cur1 CURSOR FOR select distinct
															b.entitytypeid
															from ld_cashbill a 
															inner join ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	set @deploy_value=0;
	select deploy_value into @deploy_value from ld_systems_deploy where deploy_type=83;
	
	OPEN cur1;
	Fetch cur1 into tmp_entitytypeid;
	while(tmp_entitytypeid is not null) DO
			set @tmp_entitytypeid=0;
			set @tmp_entitytypeid=tmp_entitytypeid;
			IF @deploy_value=0 THEN	
				set @cnt1=0;
				select 
					count( DISTINCT currency_id) into @cnt1 
					from 
						(select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid
							UNION ALL
								select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid
							UNION ALL
								select a.currency_id 
								from ld_cashbill a
								LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								where b.entitytypeid=@tmp_entitytypeid) c;
					IF @cnt1=1 THEN
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;

								update ld_salesorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where salesorderid=@tmp_entitytypeid;
								update ld_servicecontracts set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where servicecontractsid=@tmp_entitytypeid;
			
					ELSE
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount/a.conversion_rate as amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan/e.conversion_rate as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;

					update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where salesorderid=@tmp_entitytypeid;
					update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where servicecontractsid=@tmp_entitytypeid;					
					End IF;
			ELSE
				set @cnt1=0;
				select 
					count( DISTINCT currency_id) into @cnt1 
					from 
						(select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid
							UNION ALL
								select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid
							UNION ALL
								select a.currency_id 
								from ld_cashbill a
								LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								where b.entitytypeid=@tmp_entitytypeid and a.checkoutstatus='已审核') c;
					IF @cnt1=1 THEN
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0 and a.checkoutstatus='已审核'
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;
							
							update ld_salesorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where salesorderid=@tmp_entitytypeid;
							update ld_servicecontracts set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where servicecontractsid=@tmp_entitytypeid;
					
					ELSE
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount/a.conversion_rate as amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0 and a.checkoutstatus='已审核'
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan/e.conversion_rate as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;

					update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where salesorderid=@tmp_entitytypeid;
					update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where servicecontractsid=@tmp_entitytypeid;					
					End IF;
			END IF;
				
			Fetch cur1 into tmp_entitytypeid;
	end while;
	close cur1;
end ||
delimiter;


DROP TRIGGER IF EXISTS `update_by_salesorder1`;
call update_sales_total1();
delimiter; 

DROP TRIGGER IF EXISTS `update_by_salesorder1`;
delimiter ||
CREATE TRIGGER `update_by_salesorder1` BEFORE UPDATE ON `ld_salesorder` FOR EACH ROW 
BEGIN 
	set new.receivable_balance=round(ifnull(new.total,0)-ifnull(new.received_amount,0),2);		
END ||
delimiter; 

update ld_salesorder set receivable_balance=round(total-received_amount,2);
update ld_servicecontracts set receivable_balance=round(total-received_amount,2);
delimiter; 

drop trigger if exists update_salesorder_received1; 
delimiter || 
CREATE TRIGGER update_salesorder_received1 
AFTER UPDATE ON ld_cashbill 
FOR EACH ROW 
BEGIN 
 
		call update_sales_total1();
		
END || 
delimiter; 
-- 2015-12-23

drop trigger if exists update_salesorder_received2; 
delimiter || 
CREATE TRIGGER update_salesorder_received2 
AFTER DELETE ON ld_cashbill 
FOR EACH ROW 
BEGIN 

	set @deploy_value=0;
	select deploy_value into @deploy_value from ld_systems_deploy where deploy_type=83;
	
	IF @deploy_value=0 THEN
		call update_sales_total1;
		update ld_salesorder set received_amount=0.00,receivable_balance=round(total,2) where salesorderid not in 
		(select 
			ld_cashbill2paymentplan.entitytypeid
		from ld_cashbill
		INNER JOIN ld_cashbill2paymentplan on ld_cashbill.cashbillid=ld_cashbill2paymentplan.CashBillID);

		update ld_servicecontracts set received_amount=0.00,receivable_balance=round(total,2) where servicecontractsid not in 
		(select 
			ld_cashbill2paymentplan.entitytypeid
		from ld_cashbill
		INNER JOIN ld_cashbill2paymentplan on ld_cashbill.cashbillid=ld_cashbill2paymentplan.CashBillID);
	END IF;
	

END || 
delimiter; 
-- 2015-12-24

select cvid into @cvid from ld_customview where viewname='mobilePublicAnnouncement' and entitytype='mobilePublicAnnouncement';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_publicannouncement:subject:subject:PublicAnnouncement_标题:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_publicannouncement:startdate:startdate:PublicAnnouncement_发布日期:D' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_publicannouncement:smownerid:assigned_user_id:PublicAnnouncement_负责人:V' );
delimiter;

update ld_desk set Fieldlabel='该单据未审核，不允许创建相关联的单据' where labelbol='NOTCREATERELVANTBILL' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='The record has not approved, not allow to create a relevant bill' where labelbol='NOTCREATERELVANTBILL' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
-- 2015-12-25

update
ld_salesorder a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;

update
ld_servicecontracts a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
	
update ld_salesorder set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);
update ld_servicecontracts set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','BOUGHTPRODUCTHASAPPROVEDCONTRACTORDERS','Bought Product Has Approved Contract Orders','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='BOUGHTPRODUCTHASAPPROVEDCONTRACTORDERS' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','BOUGHTTOTAL','已购总额','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BOUGHTTOTAL' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','BOUGHTTOTAL','Bought Total','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='BOUGHTTOTAL' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','TRANSACTIONHISTORY','交易历史','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='TRANSACTIONHISTORY' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','TRANSACTIONHISTORY','Transaction History','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='TRANSACTIONHISTORY' and languagetype='en');
delimiter;

update
ld_warehousetransfer a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_warehousetransfer set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

update
ld_outboundorder a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_outboundorder set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

update
ld_stock a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_stock set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

update
ld_purchasecashback a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_purchasecashback set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

update
ld_cashback a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_cashback set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

update
ld_purchaseback a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_purchaseback set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

update
ld_salesback a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_salesback set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

update
ld_purchaseorder a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_purchaseorder set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

update
ld_quotes a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_quotes set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);

update
ld_invoice a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
update ld_invoice set currency_id=1,conversion_rate=1.000000 where currency_id in(0,1);
-- 2015-12-28

update ld_field set presence=1,typeofdata='V~O' where tabid=47 and columnname in ('timebudget','costbudget','hascost','hastime') 
and not exists (select 1 from ld_version where account='utrc');

update ld_field set presence=1,typeofdata='V~O' where tabid=48 and columnname in ('timebudget','costbudget','hascost','hastime') 
and not exists (select 1 from ld_version where account='utrc');

select tabid into @tabid from ld_tab where `name`='ProjectProgress';
update ld_field set presence=1,typeofdata='V~O' where tabid=@tabid and columnname in ('timecost','totalcost') 
and not exists (select 1 from ld_version where account='utrc');
delimiter;
-- 2015-12-29

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MODULE_HAVED_APPROVED','该单据已经提交审批！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MODULE_HAVED_APPROVED');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MODULE_HAVED_APPROVED',' it had been submitted!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MODULE_HAVED_APPROVED');
delimiter;

update ld_relatedlists set presence=1 where tabid=6 and name='get_buyproduct';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Reminds';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'related_to' and tablename = 'ld_reminds';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status)
select @fieldid,'Reminds','ProjectProgress',0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Reminds' and relmodule = 'ProjectProgress');
delimiter;

alter table ld_logpublicaccount  modify column operation text;
iNSERT INTO ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','TORELEASETHECUSTOMERTOTHEHIGNSEAS','将客户释放到公海未分配','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TORELEASETHECUSTOMERTOTHEHIGNSEAS' and labeltype='fixedstr');

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
select  'zh','RELEASEACCOUNTTREASON','释放原因','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RELEASEACCOUNTTREASON' and labeltype='fixedstr');

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, Labeltype) 
select 'en','RELEASEACCOUNTTREASON','release account reason','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='RELEASEACCOUNTTREASON' and labeltype='fixedstr');


INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, Labeltype) 
select  'zh','RELEASE','释放','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RELEASE' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
select 'en','RELEASE','Release','fixedstr' from DUAL
where not exists(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='RELEASE' and labeltype='fixedstr');

select tabid into @tabid from ld_tab where name='reminds';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into ld_fieldmodulerel(fieldid, module, relmodule, status, sequence)
SELECT @fieldid,'Reminds','ProjectProgress',0,0 FROM dual WHERE NOT
exists(SELECT 1 FROM ld_fieldmodulerel where fieldid=@fieldid and relmodule = 'ProjectProgress' AND module = 'Reminds');
delimiter;
-- 2015-12-31

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ProjectTask';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid AND fieldname='projecttaskstatus';
insert into ld_approvepickfield(tabid,fieldid) 
select @tabid,@fieldid 
from dual where not exists(select 1 from ld_approvepickfield where tabid=@tabid AND fieldid=@fieldid );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
SELECT 'zh','ALLOCATEPUBLICACCOUNTGIVEN','分配公海客户给%s','fixedstr' FROM dual
WHERE NOT exists(SELECT 1 FROM ld_desk WHERE labelbol = 'ALLOCATEPUBLICACCOUNTGIVEN' AND languagetype = 'zh' and labeltype='fixedstr');

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
SELECT 'en','ALLOCATEPUBLICACCOUNTGIVEN','Allocate high Seas customers%s','fixedstr' FROM dual 
WHERE NOT exists(SELECT 1 FROM ld_desk  WHERE languagetype = 'en'  and labelbol = 'ALLOCATEPUBLICACCOUNTGIVEN' AND  labeltype='fixedstr');
delimiter;

set @tabid=29;
update ld_blocks set sequence=1000 where tabid=@tabid and blocklabel='LBL_ATTACHMENTS_INFOMATION';

set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
-- 2016-01-05

select tabid into @tabid from ld_tab where `name`='VendorContactRecords';
update ld_blocks set sequence=100 where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='VendorContact';
update ld_blocks set sequence=100 where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
update ld_relatedlists set mobile_presence =0 where tabid = @tabid and label in ('PurchaseOrder');
delimiter;
select tabid into @tabid from ld_tab where name = 'Products';
update ld_relatedlists set mobile_presence =0 where tabid = @tabid and label in ('PurchaseOrder');
delimiter;
-- 2015-01-06

CREATE TABLE if not EXISTS `ld_buyproducthistory` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `productid` int(19) NOT NULL,
  `accountid` int(19) NOT NULL,
  `salesorderid` int(19) NOT NULL,
  `currencyid` int(19) NOT NULL,
  `after_total` decimal(25,6) DEFAULT NULL,
  `relative_money` decimal(25,6) DEFAULT NULL,
  `changetype` varchar(100) NOT NULL,
  `operationtype` varchar(100) NOT NULL,
  `operationtime` datetime NOT NULL,
  `userid` int(19) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','TOTALHOLDINGS','持有总额','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='TOTALHOLDINGS' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','TOTALHOLDINGS','Total holdings','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='TOTALHOLDINGS' and languagetype='en' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','LATESTUPDATETIME','最新操作日期','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='LATESTUPDATETIME' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','LATESTUPDATETIME','Latest update time','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='LATESTUPDATETIME' and languagetype='en' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','BALANCEAFTEROPERATION','操作后余额','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BALANCEAFTEROPERATION' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','BALANCEAFTEROPERATION','Balance after operation','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BALANCEAFTEROPERATION' and languagetype='en' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','NEWLYBUY','新购','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='NEWLYBUY' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','NEWLYBUY','Newly buy','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='NEWLYBUY' and languagetype='en' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','BOUGHTPRODUCTTRANSACTIONHISTORY','已购产品交易历史','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BOUGHTPRODUCTTRANSACTIONHISTORY' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','BOUGHTPRODUCTTRANSACTIONHISTORY','Bought Product Transaction History','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BOUGHTPRODUCTTRANSACTIONHISTORY' and languagetype='en' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','CANCELLATION','作废','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='CANCELLATION' and languagetype='zh' and labeltype='fixedstr' );
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','CANCELLATION','Cancel','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='CANCELLATION' and languagetype='en' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','RETIRED','已退','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='RETIRED' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','RETIRED','Retired','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='RETIRED' and languagetype='en' and labeltype='fixedstr');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Users';
INSERT INTO ld_profileallpermission(tabid,operation)
SELECT @tabid,3 FROM DUAL WHERE NOT EXISTS 
(SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=3);
delimiter;

SELECT parenttabid INTO @parenttabid FROM ld_parenttab WHERE parenttab_label = 'Tools';
SELECT MAX(sequence) INTO @sequence FROM ld_parenttabrel WHERE parenttabid=@parenttabid;
SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'Users';
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @parenttabid,@tabid,@sequence+1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE tabid=@tabid AND parenttabid=@parenttabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'用户管理' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Users' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,2,2  from dual where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_usersscf` (
  `id` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
-- 2016-01-08

CREATE TABLE IF NOT EXISTS`ld_dividendorder` (
  `dividendorderid` int(11) NOT NULL,
  `accountid` int(19) DEFAULT NULL,
  `banknum` varchar(100) DEFAULT NULL,
  `bankcard_no` varchar(100) DEFAULT NULL,
  `bankname` varchar(100) DEFAULT NULL,
  `bankbranchnumber` varchar(100) DEFAULT NULL,
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  `cashmoney` decimal(25,2) DEFAULT NULL,
  `plandividend_date` date DEFAULT NULL,
  `product_id` int(19) DEFAULT NULL,
  `status` varchar(100) DEFAULT '未派',
  `actualdividend_date` datetime DEFAULT NULL,
  `smownerid` int(11) DEFAULT NULL,
  `smcreatorid` int(11) DEFAULT NULL,
  `createdtime` date DEFAULT NULL,
  `modifiedby` int(11) DEFAULT NULL,
  `modifiedtime` date DEFAULT NULL,
  `dividend_no` varchar(100) DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  `remark` varchar(200) DEFAULT NULL,
  `salesorderid` int(11) DEFAULT '0',
  `license_no` varchar(255) DEFAULT NULL,
  `bill_street` varchar(250) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `mobilephone` varchar(50) DEFAULT NULL,
  `description` text,
  `currency_id` int(19) DEFAULT '0',
  `conversion_rate` decimal(25,6) DEFAULT NULL,
  `currency_symbol` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`dividendorderid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_dividendorder_sms` (
  `id` int(11) NOT NULL DEFAULT '0',
  `is_dividend` int(4) DEFAULT '0',
  `is_anti_dividend` int(4) DEFAULT '0',
  `mobile_fieldname` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_dividendordercf` (
  `dividendorderid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dividendorderid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_dividendorderdetail` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  `Dividendorderid` int(19) DEFAULT NULL,
  `days` int(19) DEFAULT NULL,
  `rate_senddate` date DEFAULT NULL,
  `float_income` decimal(25,6) DEFAULT NULL,
  `adjustment` decimal(25,6) DEFAULT NULL,
  `rate_money` decimal(25,6) DEFAULT NULL,
  `princial` decimal(25,6) DEFAULT NULL,
  `dividend_money` decimal(25,6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_dividendordersetting` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `ratetype` varchar(100) DEFAULT NULL,
  `daysmethod` varchar(100) DEFAULT NULL,
  `rate_senddatetype` varchar(100) DEFAULT NULL,
  `float_income` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select trade into @trade from ld_version;
select max(tabsequence) into @tabsequence  from ld_tab;
select max(tabid)+1 into @tabid from ld_tab;
insert into ld_tab(tabid,`name`,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'DividendOrder',if(@trade='finance',0,1) as presence,@tabsequence+1,'DividendOrder',1,'Sales',1 from DUAL
where not exists(select 1 from ld_tab where `name` = 'DividendOrder');

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'派息单' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tab' and tabid = @tabid and Relateid = @tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'DividendOrder' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tab' and tabid = @tabid and Relateid = @tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);

select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where not exists(select 1 from ld_Def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from ld_Def_org_share where tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Sales';
select tabid into @salesorder_tabid from ld_tab where `name` = 'SalesOrder';
select sequence into @sequence from ld_parenttabrel where parenttabid = @parenttabid and tabid = @salesorder_tabid;
update ld_parenttabrel set sequence = sequence + 1 where parenttabid = @parenttabid and sequence > @sequence;
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 from DUAL
where not exists(select 1 from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_DIVIDENDORDER_INFO',1 
from dual where not exists (select * from ld_blocks where tabid = @tabid and blocklabel = 'LBL_DIVIDENDORDER_INFO');

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_DIVIDENDORDER_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'dividend_no','ld_dividendorder',4,'dividend_no','派息编号',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'V~M',1,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'dividend_no');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'accountid','ld_dividendorder',73,'account_id','客户名称',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),2,0,'V~O',2,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'accountid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'banknum','ld_dividendorder',1,'banknum','银行账户',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'V~O',3,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'banknum');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'bankcard_no','ld_dividendorder',1,'bankcard_no','银行卡号',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'V~O',4,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'bankcard_no');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'bankname','ld_dividendorder',1,'bankname','开户银行',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'V~O',5,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'bankname');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'bankbranchnumber','ld_dividendorder',1,'bankbranchnumber','银行网点',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'V~O',6,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'bankbranchnumber');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'startdate','ld_dividendorder',5,'startdate','起始时间',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'D~O',7,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'startdate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'enddate','ld_dividendorder',5,'enddate','截止时间',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'D~O',8,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'enddate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'cashmoney','ld_dividendorder',71,'cashmoney','金额',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'N~O',9,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'cashmoney');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'plandividend_date','ld_dividendorder',5,'plandividend_date','计划派息日期',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'D~O',10,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'plandividend_date');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'product_id','ld_dividendorder',59,'product_id','产品名称',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'V~O',11,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'product_id');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'status','ld_dividendorder',1,'status','状态',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),2,0,'V~O',12,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'status');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'actualdividend_date','ld_dividendorder',86,'actualdividend_date','实际派息日期',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'DT~O',13,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'actualdividend_date');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_dividendorder',53,'assigned_user_id','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),1,0,'V~O',14,0,1
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smownerid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_dividendorder',52,'creator','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),2,0,'V~O',15,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_dividendorder',86,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),2,0,'DT~O',16,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_dividendorder',52,'modifiedby','最新更新人',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),2,0,'V~O',17,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedby');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_dividendorder',70,'modifiedtime','最新更新时间',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_INFO'),2,0,'DT~O',18,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'account_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'客户名称' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Account Name' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'banknum';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'银行账户' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Bank Num' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'bankcard_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'银行卡号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Bank Card_no' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'bankname';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'开户银行' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Bank Name' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'bankbranchnumber';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'银行网点' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Bank Branch Number' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'startdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'起始日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Start Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'startdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'起始日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Start Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'enddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'截止日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'End Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'cashmoney';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'金额' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Money' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'plandividend_date';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'计划派息日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Plan Dividend_date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'product_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'产品名称' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Product Name' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'status';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'actualdividend_date';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'实际派息日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Actual Dividend_date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'负责人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Assigned To' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'creator';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'创建人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'创建时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'最新更新人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'最新更新时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'dividend_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'派息编号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Dividend No' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_DIVIDENDORDER_REMARK',3 from dual 
where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_DIVIDENDORDER_REMARK');

SELECT blockid INTO @blockid from ld_blocks WHERE tabid =@tabid and blocklabel ='LBL_DIVIDENDORDER_REMARK';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_blocks',@tabid,@blockid,'备注信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Description Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'remark','ld_dividendorder',19,'remark','备注',(select blockid from ld_blocks where blocklabel = 'LBL_DIVIDENDORDER_REMARK'),1,0,'V~O',1,0 from dual 
where not exists (select * from ld_field where tabid = @tabid and columnname = 'remark');

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'remark';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'备注' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_ACCOUNT_INFO',2 from dual 
where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ACCOUNT_INFO');

SELECT blockid INTO @blockid from ld_blocks WHERE tabid =@tabid and blocklabel ='LBL_ACCOUNT_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_blocks',@tabid,@blockid,'客户相关信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Account Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'license_no','ld_dividendorder',1,'license_no','组织机构代码证',(select blockid from ld_blocks where blocklabel = 'LBL_ACCOUNT_INFO'),1,0,'V~O',1,0 from dual 
where not exists (select * from ld_field where tabid = @tabid and columnname = 'license_no');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'bill_street','ld_dividendorder',21,'bill_street','地址',(select blockid from ld_blocks where blocklabel = 'LBL_ACCOUNT_INFO'),1,0,'V~O',2,0 from dual 
where not exists (select * from ld_field where tabid = @tabid and columnname = 'bill_street');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'phone','ld_dividendorder',11,'phone','固定电话',(select blockid from ld_blocks where blocklabel = 'LBL_ACCOUNT_INFO'),1,0,'V~O',3,0 from dual 
where not exists (select * from ld_field where tabid = @tabid and columnname = 'phone');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'mobilephone','ld_dividendorder',1101,'mobilephone','移动电话',(select blockid from ld_blocks where blocklabel = 'LBL_ACCOUNT_INFO'),1,0,'V~O',4,0 from dual 
where not exists (select * from ld_field where tabid = @tabid and columnname = 'mobilephone');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'description','ld_dividendorder',19,'description','备注',(select blockid from ld_blocks where blocklabel = 'LBL_ACCOUNT_INFO'),1,0,'V~O',5,0 from dual 
where not exists (select * from ld_field where tabid = @tabid and columnname = 'description');

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'license_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'组织机构代码证' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Organization Code Certificate' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'bill_street';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'地址' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Address' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'phone';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'固定电话' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Phone' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'mobilephone';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'移动电话' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Mobile Phone' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'备注' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

UPDATE ld_blocks_seq SET id =(SELECT MAX(blockid) FROM ld_blocks);
delimiter;
UPDATE ld_field_seq SET id =(SELECT MAX(fieldid) from ld_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DIVIDENDBTN','派息','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DIVIDENDBTN' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DIVIDENDBTN','Dividend','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DIVIDENDBTN' and Labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ANTIDIVIDENDBTN','反派息','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ANTIDIVIDENDBTN' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ANTIDIVIDENDBTN','Anti dividend','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ANTIDIVIDENDBTN' and Labeltype = 'fixedstr');
delimiter;

select max(actionid) into @actionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select @actionid+1,'Devidend',0,'DIVIDENDBTN' from DUAL
where not exists(select 1 from ld_actionmapping where actionname = 'Devidend');

insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select @actionid+2,'AbtiDevidend',0,'ANTIDIVIDENDBTN' from DUAL
where not exists(select 1 from ld_actionmapping where actionname = 'AbtiDevidend');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=1);
insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=2);
insert into ld_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=4);
insert into ld_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=6);
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=12);
insert into ld_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=13);
insert into ld_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=14);
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
insert into ld_profileallpermission(tabid,operation)
select @tabid,26 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=26);
insert into ld_profileallpermission(tabid,operation)
select @tabid,27 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=27);
delimiter;

select id into @id from ld_customview_seq;
insert into ld_customview(cvid,viewname,setdefault,entitytype,`status`,userid,sequence,pagewidthpercent)
select @id+1,'All',1,'DividendOrder',3,1,0,100 from DUAL
where not exists(select 1 from ld_customview where viewname='All' and entitytype='DividendOrder');

select cvid into @cvid from ld_customview where entitytype = 'DividendOrder' and viewname = 'All';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_dividendorder:dividend_no:dividend_no:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_dividendorder:accountid:account_id:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_dividendorder:cashmoney:cashmoney:DividendOrder_fieldlabel:N';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_fieldlabel:D';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_dividendorder:status:status:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_dividendorder:actualdividend_date:actualdividend_date:DividendOrder_fieldlabel:DT';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_dividendorder:smownerid:assigned_user_id:DividendOrder_fieldlabel:V';
delimiter;

INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
SELECT @cvid+2,'本月应派',1,0,'DividendOrder',3,1,1,100,''
from dual where not EXISTS(select 1 from ld_customview  where viewname = '本月应派' and entitytype ='DividendOrder');
select cvid into @cvid from ld_customview where entitytype = 'DividendOrder' and viewname = '本月应派';
DELETE from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_dividendorder:dividend_no:dividend_no:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_dividendorder:accountid:account_id:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_dividendorder:cashmoney:cashmoney:DividendOrder_fieldlabel:N';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_fieldlabel:D';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_dividendorder:status:status:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_dividendorder:actualdividend_date:actualdividend_date:DividendOrder_fieldlabel:DT';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_dividendorder:smownerid:assigned_user_id:DividendOrder_fieldlabel:V';
INSERT INTO ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
SELECT @cvid,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_fieldlabel','thismonth',date_add(curdate(), interval - day(curdate()) + 1 day),last_day(curdate())
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_cvstdfilter WHERE cvid=@cvid);
delimiter;

INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
SELECT @cvid+3,'本月已派',1,0,'DividendOrder',3,1,2,100,''
from dual where not EXISTS(select 1 from ld_customview  where viewname = '本月已派' and entitytype ='DividendOrder');
select cvid into @cvid from ld_customview where entitytype = 'DividendOrder' and viewname = '本月已派';
DELETE from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_dividendorder:dividend_no:dividend_no:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_dividendorder:accountid:account_id:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_dividendorder:cashmoney:cashmoney:DividendOrder_fieldlabel:N';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_fieldlabel:D';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_dividendorder:status:status:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_dividendorder:actualdividend_date:actualdividend_date:DividendOrder_fieldlabel:DT';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_dividendorder:smownerid:assigned_user_id:DividendOrder_fieldlabel:V';
INSERT INTO ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
SELECT @cvid,'ld_dividendorder:actualdividend_date:actualdividend_date:DividendOrder_fieldlabel','thismonth',date_add(curdate(), interval - day(curdate()) + 1 day),last_day(curdate())
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_cvstdfilter WHERE cvid=@cvid);
INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,'ld_dividendorder:status:status:DividendOrder_fieldlabel:V','e','已派',1,''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_cvadvfilter WHERE cvid = @cvid);
delimiter;

INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
SELECT @cvid+4,'本月未派',1,0,'DividendOrder',3,1,3,100,''
from dual where not EXISTS(select 1 from ld_customview  where viewname = '本月未派' and entitytype ='DividendOrder');
UPDATE ld_customview_seq set id = (SELECT MAX(cvid) from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'DividendOrder' and viewname = '本月未派';
DELETE from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_dividendorder:dividend_no:dividend_no:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_dividendorder:accountid:account_id:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_dividendorder:cashmoney:cashmoney:DividendOrder_fieldlabel:N';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_fieldlabel:D';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_dividendorder:status:status:DividendOrder_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_dividendorder:actualdividend_date:actualdividend_date:DividendOrder_fieldlabel:DT';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_dividendorder:smownerid:assigned_user_id:DividendOrder_fieldlabel:V';
INSERT INTO ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
SELECT @cvid,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_fieldlabel','thismonth',date_add(curdate(), interval - day(curdate()) + 1 day),last_day(curdate())
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_cvstdfilter WHERE cvid=@cvid);
INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,'ld_dividendorder:status:status:DividendOrder_fieldlabel:V','e','未派',1,''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_cvadvfilter WHERE cvid = @cvid);
delimiter;

update ld_customview_seq set id = (select max(cvid) from ld_customview);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_devidend','如何创建派息单','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'How_to_create_devidend' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_devidend','How to create devidend','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'How_to_create_devidend' and Labeltype = 'fixedstr');
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type = 12;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select 0,89,'合同订单新增保存后是否立即创建派息单','',@sequence+1 from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 89);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THENEWCONTRACTORDERS','合同订单新增保存后是否立即创建派息单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THENEWCONTRACTORDERS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THENEWCONTRACTORDERS','The new contract orders after preservation immediately creates a single dividend','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THENEWCONTRACTORDERS' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BATCHDIVIDEND','批量派息','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'BATCHDIVIDEND' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BATCHDIVIDEND','Batch dividend','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'BATCHDIVIDEND' and labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0 from dual 
where not EXISTS(select 1 from ld_links  where tabid = @tabid and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual 
where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid and visible =1);
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'DividendOrder','PX',1,1,1,'none' from dual 
where not EXISTS(select 1 from ld_modentity_num  where semodule = 'DividendOrder' and prefix ='PX');
update ld_modentity_num_seq set id = (select max(num_id) from ld_modentity_num);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'DividendOrder';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'DividendOrder','ld_dividendorder','dividend_no','dividendorderid','dividendorderid' from dual 
where not EXISTS(select 1 from ld_entityname  where tabid = @tabid and modulename ='DividendOrder');
delimiter;

SELECT tabid into @tabid from ld_tab WHERE name = 'DividendOrder';
SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-1,0,0,'' FROM dual 
where not exists(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-1);

SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,78,0,0,'' FROM dual 
where not exists(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=78);

SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-5,0,0,'' FROM dual 
where not exists(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-5);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TODATERMINETHESELECTEDDIVIDEND','确定要派息选定的','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TODATERMINETHESELECTEDDIVIDEND' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TODATERMINETHESELECTEDDIVIDEND','To determine the selected dividend','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TODATERMINETHESELECTEDDIVIDEND' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TODATERMINETHEDIVIDEND','确定要派息吗？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TODATERMINETHEDIVIDEND' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TODATERMINETHEDIVIDEND','To determine the dividend?','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TODATERMINETHEDIVIDEND' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUREYOUWANTTOREVERSETHEDIVIDEND','确定要反派息吗？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SUREYOUWANTTOREVERSETHEDIVIDEND' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUREYOUWANTTOREVERSETHEDIVIDEND','Sure you want to reverse the dividend?','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SUREYOUWANTTOREVERSETHEDIVIDEND' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS','单据[%s]%s不成功！原因：该单据已经%s!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS','Document [%s]%s is not successful! Reason: the document has been%s!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS' and labeltype='fixedstr');
delimiter;

SELECT tabid into @tabid from  ld_tab WHERE NAME= 'DividendOrder';
SELECT tabid into @related_tabid from  ld_tab WHERE NAME= 'Attachment';
SELECT MAX(relation_id) into @relation_id from ld_relatedlists;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,@related_tabid,'get_attachment',1,'Attachment',0,'ADD',1,1 FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid);
delimiter;

SELECT tabid into @tabid from  ld_tab WHERE NAME= 'SalesOrder';
SELECT tabid into @related_tabid from  ld_tab WHERE NAME= 'DividendOrder';
SELECT MAX(relation_id) into @relation_id from ld_relatedlists;
SELECT sequence INTO @sequence FROM ld_relatedlists WHERE tabid =@tabid AND label='PaymentPlan';
UPDATE ld_relatedlists SET sequence=sequence+1 WHERE tabid =@tabid AND sequence >=@sequence;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,@related_tabid,'get_dividendorder',@sequence,'DividendOrder',0,'',1,1 FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid);
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','WHETHERSENDSMSIMMEDIATELYAFTERT','后是否立即发送短信通知','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='WHETHERSENDSMSIMMEDIATELYAFTERT' and labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','WHETHERSENDSMSIMMEDIATELYAFTERT','Whether to send SMS notification immediately after','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='WHETHERSENDSMSIMMEDIATELYAFTERT' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','CHOOSEWHICHPHONETOSENDTEXTMASSEAGE','请选择要发送短信到哪些手机','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='CHOOSEWHICHPHONETOSENDTEXTMASSEAGE' and labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','CHOOSEWHICHPHONETOSENDTEXTMASSEAGE','Choose which phone to send text messages','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='CHOOSEWHICHPHONETOSENDTEXTMASSEAGE' and labeltype='fixedstr');
delimiter;

insert into ld_sendinformcontent(content,type,description)
select '您有一笔金额为[var.dividendorder_cashmoney_DividendOrder]的利息已派，请注意查收！',9,'派息单派息短信' from dual
where not exists(select 1 from ld_sendinformcontent where type = 9);
delimiter;

insert into ld_sendinformcontent(content,type,description)
select '您有一笔金额为[var.dividendorder_cashmoney_DividendOrder]的利息已取消派息！',10,'派息单反派息短信' from dual
where not exists(select 1 from ld_sendinformcontent where type = 10);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DIVIDENDCONTENT','派息内容','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DIVIDENDCONTENT' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DIVIDENDCONTENT','Dividend Content','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DIVIDENDCONTENT' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ANTIDIVIDENDCONTENT','反派息内容','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ANTIDIVIDENDCONTENT' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ANTIDIVIDENDCONTENT','Antidividend Content','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ANTIDIVIDENDCONTENT' and labeltype='jspop');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','CHOOSEWHICHPHONETOSENDTEXTMASSEAGEJSPOP','请选择要发送短信到哪些手机','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='CHOOSEWHICHPHONETOSENDTEXTMASSEAGEJSPOP' and labeltype='jspop');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','CHOOSEWHICHPHONETOSENDTEXTMASSEAGEJSPOP','Choose which phone to send text messages','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='CHOOSEWHICHPHONETOSENDTEXTMASSEAGEJSPOP' and labeltype='jspop');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','INTERESTSCALCULATION','计息方式','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='INTERESTSCALCULATION' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','INTERESTSCALCULATION','Interests Calculation','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='INTERESTSCALCULATION' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','ACCORDINGTOTHEPURCHASEAMOUNTOFINTEREST','按已购金额计息','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='ACCORDINGTOTHEPURCHASEAMOUNTOFINTEREST' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','ACCORDINGTOTHEPURCHASEAMOUNTOFINTEREST','According to the purchase amount of interest','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='ACCORDINGTOTHEPURCHASEAMOUNTOFINTEREST' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','DAYSCALCLATION','天数计算方法','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='DAYSCALCLATION' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','DAYSCALCLATION','Days Calculation','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='DAYSCALCLATION' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','MONTHLYMONTH30DAYS','按月/每月30天，不足月计实际天数','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='MONTHLYMONTH30DAYS' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','MONTHLYMONTH30DAYS','Monthly / month 30 days, less than the actual number of days','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='MONTHLYMONTH30DAYS' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','INVESTMENT','投资金额','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='INVESTMENT' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','INVESTMENT','Investment','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='INVESTMENT' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','INTERESTPAYMENTDATE','利息发放日','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='INTERESTPAYMENTDATE' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','INTERESTPAYMENTDATE','Interest Payment Date','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='INTERESTPAYMENTDATE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','INVESTENDDAY','投资到期日','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='INVESTENDDAY' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','INVESTENDDAY','Inverst End Date','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='INVESTENDDAY' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','FLOATINCOME','浮动收益','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='FLOATINCOME' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','FLOATINCOME','Float Income','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='FLOATINCOME' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','MATURITYDATEOFDEBTSERVICE','到期日还本付息及浮动收益','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='MATURITYDATEOFDEBTSERVICE' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','MATURITYDATEOFDEBTSERVICE','Maturity date of debt service and floating income','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='MATURITYDATEOFDEBTSERVICE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','INTERESTSCALCULATIONFORMULA','利息计算公式','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='INTERESTSCALCULATIONFORMULA' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','INTERESTSCALCULATIONFORMULA','Interests Calculation Formula','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='INTERESTSCALCULATIONFORMULA' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','STARTDATE','起始日期','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='STARTDATE' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','STARTDATE','Start Date','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='STARTDATE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','ENDDATE','截止日期','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='ENDDATE' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','ENDDATE','End Date','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='ENDDATE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','INTERESTSDAYS','计息天数','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='INTERESTSDAYS' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','INTERESTSDAYS','Interests Days','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='INTERESTSDAYS' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','PRINCIPAL','本金','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='PRINCIPAL' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','PRINCIPAL','Principal','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='PRINCIPAL' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','INTEREST','利息','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='INTEREST' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','INTEREST','Interest','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='INTEREST' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','THENEXTMONTH','次月','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='THENEXTMONTH' AND Labeltype='fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','THENEXTMONTH','The next month','fixedstr' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='THENEXTMONTH' AND Labeltype='fixedstr');
delimiter;

call AddColumn('ld_dividendorder','salesorderid','int','11',0);
delimiter;
call fieldprofile('DividendOrder');
delimiter;
call getallprofile('DividendOrder');
delimiter;
call AddColumn('ld_dividendorder','currency_id','int','19',0);
call AddColumn('ld_dividendorder','conversion_rate','int','19',0);
call AddColumn('ld_dividendorder','currency_symbol','varchar','30',NULL);
alter table ld_dividendorder modify conversion_rate decimal(25,6); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_devidend_desc1','派息单是针对合同订单的，不允许直接新增；','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'How_to_create_devidend_desc1' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_devidend_desc1','Dividend only on the contract orders, not allowed to directly add','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'How_to_create_devidend_desc1' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_devidend_desc2','可通过系统参数控制，新增合同订单后自动弹出派息单新增界面；','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'How_to_create_devidend_desc2' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_devidend_desc2','Can be controlled by the system parameters, the new contract orders automatically add dividend single interface','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'How_to_create_devidend_desc2' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_devidend_desc3','也可以通过合同订单或查看明细界面更多：创建派息单。','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'How_to_create_devidend_desc3' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_devidend_desc3','Can contract or view the details: create a single interface more dividend.','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'How_to_create_devidend_desc3' and Labeltype = 'fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `update_sales_total1`;
delimiter ||
CREATE  PROCEDURE `update_sales_total1`(
)
BEGIN
	
	declare tmp_entitytypeid int;
	declare cur1 CURSOR FOR select distinct
															b.entitytypeid
															from ld_cashbill a 
															inner join ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	set @deploy_value=0;
	select deploy_value into @deploy_value from ld_systems_deploy where deploy_type=83;
	
	OPEN cur1;
	Fetch cur1 into tmp_entitytypeid;
	while(tmp_entitytypeid is not null) DO
			set @tmp_entitytypeid=0;
			set @tmp_entitytypeid=tmp_entitytypeid;
			IF @deploy_value=0 THEN	
				set @cnt1=0;
				select 
					count( DISTINCT currency_id) into @cnt1 
					from 
						(select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid
							UNION ALL
								select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid
							UNION ALL
								select a.currency_id 
								from ld_cashbill a
								LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								where b.entitytypeid=@tmp_entitytypeid) c;
					IF @cnt1=1 THEN
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;

								update ld_salesorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where salesorderid=@tmp_entitytypeid;
								update ld_servicecontracts set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where servicecontractsid=@tmp_entitytypeid;
			
					ELSE
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount/a.conversion_rate as amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan/e.conversion_rate as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;

					update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where salesorderid=@tmp_entitytypeid;
					update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where servicecontractsid=@tmp_entitytypeid;					
					End IF;
			ELSE
				set @cnt1=0;
				select 
					count( DISTINCT currency_id) into @cnt1 
					from 
						(select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid
							UNION ALL
								select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid
							UNION ALL
								select a.currency_id 
								from ld_cashbill a
								LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								where b.entitytypeid=@tmp_entitytypeid and a.checkoutstatus='已审核') c;
					IF @cnt1=1 THEN
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0 and a.checkoutstatus='已审核'
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;
							
							update ld_salesorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where salesorderid=@tmp_entitytypeid;
							update ld_servicecontracts set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where servicecontractsid=@tmp_entitytypeid;
					
					ELSE
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount/a.conversion_rate as amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0 and a.checkoutstatus='已审核'
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan/e.conversion_rate as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=@tmp_entitytypeid
								group by h.entitytypeid;

					update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where salesorderid=@tmp_entitytypeid;
					update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where servicecontractsid=@tmp_entitytypeid;					
					End IF;
			END IF;
				
			Fetch cur1 into tmp_entitytypeid;
	end while;
	close cur1;
end ||
delimiter;
-- 2015-01-11

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileFaq',1,50,'mobileFaq',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileFaq');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileFaq' and entitytype='mobileFaq');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileFaq',0,0,'mobileFaq',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileFaq' and entitytype='mobileFaq');
select cvid into @cvid   from ld_customview where viewname='mobileFaq' and entitytype='mobileFaq';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileFaq' and entitytype='mobileFaq' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_faq:faq_no:faq_no:Faq_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_faq:category:faqcategories:Faq_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_faq:faqtype:faqtype:Faq_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_faq:question:question:Faq_fieldlabel:V' );
delimiter;

call AddColumn('ld_users','groupid','varchar','100',NULL);
delimiter;

SELECT tabid into @tabid from ld_tab WHERE `name` = 'Users';
SELECT MAX(sequence) INTO @sequence from ld_field WHERE tabid = @tabid AND block= (select blockid from ld_blocks where blocklabel = 'LBL_USERLOGIN_ROLE');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'groupid','ld_users',180,'groupid','选择部门',(select blockid from ld_blocks where blocklabel = 'LBL_USERLOGIN_ROLE'),1,0,'V~O',@sequence+1,0
from dual where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'groupid');

SELECT fieldid INTO @fieldid from ld_field WHERE tabid = @tabid AND columnname = 'groupid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'选择部门' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Select Group' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

update ld_users LEFT JOIN (select userid,GROUP_CONCAT(ld_users2group.groupid) as str_groupid from ld_users2group GROUP BY ld_users2group.userid) 
as temp on temp.userid = ld_users.id set ld_users.groupid = temp.str_groupid;
delimiter;

update ld_desk set fieldlabel='{$Expense.Expense}明细'  where languagetype='zh' and  labelbol='FEEDETAIL' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Expense.Expense} detail'  where languagetype='en' and  labelbol='FEEDETAIL' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Commission.Commission}信息'  where languagetype='zh' and  labelbol='COMMISSIONINFO' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Commission.Commission} info'  where languagetype='en' and  labelbol='COMMISSIONINFO' and Labeltype='fixedstr';
delimiter;

select tabid into @tabid from ld_tab where `name`='ContactRecords';
update ld_field set uitype=86,typeofdata='DT~O' where tabid=@tabid and columnname='contactdate';
alter TABLE ld_contactrecords modify contactdate datetime;
delimiter;
-- 2016-01-12

update ld_relatedlists set presence=0 where EXISTS(select 1 from ld_version where trade='finance')  and  tabid=6 and name='get_buyproduct';
update ld_relatedlists set presence=1 where not  EXISTS(select 1 from ld_version where trade='finance')  and  tabid=6 and name='get_buyproduct';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh' ,'APPROVALSUGGESTION','审批意见','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='APPROVALSUGGESTION' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en' ,'APPROVALSUGGESTION','Approval suggestion','fixedstr' from DUAL
where not exists(select 1 from ld_desk  where languagetype='en' and labelbol='APPROVALSUGGESTION' and Labeltype='fixedstr');
delimiter;
-- 2016-01-13

DROP PROCEDURE IF EXISTS `update_sales_total2`;
delimiter ||
CREATE  PROCEDURE `update_sales_total2`(
	tmp_salesorderid INT(19)
)
BEGIN
	
	set @deploy_value=0;
	select deploy_value into @deploy_value from ld_systems_deploy where deploy_type=83;
		
			IF @deploy_value=0 THEN	
				set @cnt1=0;
				select 
					count( DISTINCT currency_id) into @cnt1 
					from 
						(select currency_id from ld_salesorder where salesorderid=tmp_salesorderid
							UNION ALL
								select currency_id from ld_servicecontracts where servicecontractsid=tmp_salesorderid
							UNION ALL
								select a.currency_id 
								from ld_cashbill a
								LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								where b.entitytypeid=tmp_salesorderid) c;
					IF @cnt1=1 THEN
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=tmp_salesorderid
								group by h.entitytypeid;

								update ld_salesorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where salesorderid=tmp_salesorderid;
								update ld_servicecontracts set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where servicecontractsid=tmp_salesorderid;
			
					ELSE
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount/a.conversion_rate as amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan/e.conversion_rate as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=tmp_salesorderid
								group by h.entitytypeid;
					update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where salesorderid=tmp_salesorderid;
					update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where servicecontractsid=tmp_salesorderid;					
					End IF;
			ELSE
				set @cnt1=0;
				select 
					count( DISTINCT currency_id) into @cnt1 
					from 
						(select currency_id from ld_salesorder where salesorderid=tmp_salesorderid
							UNION ALL
								select currency_id from ld_servicecontracts where servicecontractsid=tmp_salesorderid
							UNION ALL
								select a.currency_id 
								from ld_cashbill a
								LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								where b.entitytypeid=tmp_salesorderid and a.checkoutstatus='已审核') c;
					IF @cnt1=1 THEN
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0 and a.checkoutstatus='已审核'
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=tmp_salesorderid
								group by h.entitytypeid;
							update ld_salesorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where salesorderid=tmp_salesorderid;
							update ld_servicecontracts set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2) where servicecontractsid=tmp_salesorderid;
					
					ELSE
							set @sales_total=0.00;
							select
							sum(h.amount) into @sales_total
							from (
								select 
								a.cashbillid,
								b.entitytypeid,
								b.amount/a.conversion_rate as amount
								from ld_cashbill a 
								INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
								and a.deleted=0 and a.checkoutstatus='已审核'
								UNION ALL
								select * from (
									select 
									e.cashbillid,
									f.entitytypeid,
									e.NoPaymentplan/e.conversion_rate as amount
									from ld_cashbill e
									inner JOIN (select * from (
											select CashBillID,entitytypeid 
												from ld_cashbill2paymentplan 
												order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
											where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
								where h.entitytypeid=tmp_salesorderid
								group by h.entitytypeid;
					update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where salesorderid=tmp_salesorderid;
					update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2) where servicecontractsid=tmp_salesorderid;					
					End IF;
			END IF;
end ||
delimiter;

drop trigger if exists update_salesorder_received1; 
delimiter || 
CREATE TRIGGER update_salesorder_received1 
AFTER UPDATE ON ld_cashbill 
FOR EACH ROW 
BEGIN 
 
		call update_sales_total(new.cashbillid);
		
END || 
delimiter; 

drop trigger if exists update_salesorder_received2; 
delimiter || 
CREATE TRIGGER update_salesorder_received2 
AFTER INSERT ON ld_cashbill2paymentplan 
FOR EACH ROW 
BEGIN 
 
		call update_sales_total2(new.entitytypeid);
		
END || 
delimiter; 

drop trigger if exists update_salesorder_received3; 
delimiter || 
CREATE TRIGGER update_salesorder_received3
AFTER DELETE ON ld_cashbill2paymentplan 
FOR EACH ROW 
BEGIN 
 
		call update_sales_total2(old.entitytypeid);
		
END || 
delimiter; 


drop trigger if exists update_salesorder_received4; 
delimiter || 
CREATE TRIGGER update_salesorder_received4 
AFTER UPDATE ON ld_cashbill2paymentplan 
FOR EACH ROW 
BEGIN 
 
		call update_sales_total2(new.entitytypeid);
		
END || 
delimiter; 


call AddColumn('ld_troubletickets','hopetime_end','datetime','0', NULL);
delimiter;
call AddColumn('ld_troubletickets','hope_address','varchar','500', NULL);
delimiter;

SELECT tabid INTO @tabid from ld_tab WHERE `name`='HelpDesk';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'hopetime_end','ld_troubletickets',86,'hopetime_end','预约上门时间止',(select blockid from ld_blocks where blocklabel = 'LBL_TICKET_INFORMATION'),1,1,'DT~O',1,15,0 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'hopetime_end');
delimiter; 
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'hope_address','ld_troubletickets',19,'hope_address','上门地址',(select blockid from ld_blocks where blocklabel = 'LBL_TICKET_INFORMATION'),1,1,'V~O',1,16,0 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'hope_address');
delimiter;
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hopetime_end';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'预约上门时间止' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Hopetime End ' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hope_address';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'上门地址' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Hopetime Address ' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

call fieldprofile('HelpDesk');
delimiter;
call getallprofile('HelpDesk');
delimiter;

update ld_desk set fieldlabel='启用订单同步接口' where labelbol='ENABLEORDERINTERFACE' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='启用库存数量同步接口' where labelbol='ENABLEINVENTORYINTERFACE' and languagetype='zh' and Labeltype='fixedstr';

update ld_desk set fieldlabel = '必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）' 
where labelbol = 'OUTBOUNDSTOCKACCORDORIGNAL' and languagetype = 'zh';
delimiter;
update ld_desk set fieldlabel = 'must be strictly according to source and single (each product cumulative quantity is not allowed to exceed the source single or source single foreign products)' 
where labelbol = 'OUTBOUNDSTOCKACCORDORIGNAL' and languagetype = 'en';
delimiter;
update ld_desk set fieldlabel = '更新库存流水记录触发点' 
where labelbol = 'UPDATEINVENTORYLEDGER' and languagetype = 'zh';
delimiter;
update ld_desk set fieldlabel = 'pdate the trigger point of inventory record' 
where labelbol = 'UPDATEINVENTORYLEDGER' and languagetype = 'en';
delimiter;
-- 2016-01-14

select tabid into @tabid from ld_tab where `name`='ContactRecords';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='contactrecordtype';
update ld_tranlabel set fieldlabel='联系方式' where trantable='ld_field' and languagetype='zh' and tabid=@tabid and Relateid=@fieldid and fieldlabel='联系类型';
delimiter;

select tabid into @tabid from ld_tab where `name`='VendorContactRecords';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='contactrecordtype';
update ld_tranlabel set fieldlabel='联系方式' where trantable='ld_field' and languagetype='zh' and tabid=@tabid and Relateid=@fieldid and fieldlabel='联系类型';
delimiter;

update ld_logpublicaccount set username = '系统' where username = 'system';
delimiter;

SELECT tabid INTO @tabid from ld_tab WHERE `name`='Potentials';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE `name`='Salesorder';
SELECT tabid INTO @tabid3 FROM ld_tab WHERE `name`='ServiceContracts';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
SELECT sequence INTO @sequence FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@tabid2;
update ld_relatedlists  set sequence=sequence+1 where sequence>@sequence;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions) 
SELECT @relation_id+1,@tabid,@tabid3,'get_servicecontracts',@sequence+1,'ServiceContracts',0,'ADD'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_servicecontracts');
delimiter;

SELECT max(sequence) INTO @sequence FROM ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select 1,90,'用户密码是否严格管理 1:否，0:是','',@sequence+1 from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type = 90);

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PASSWORDMANAGED','用户密码是否严格管理','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PASSWORDMANAGED' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PASSWORDMANAGED','Is user password  strictly managed','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PASSWORDMANAGED' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PASSWORDVERFICATION','密码验证','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PASSWORDVERFICATION' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PASSWORDVERFICATION','Password verification','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PASSWORDVERFICATION' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NOTICEPASSWORDSTANDARDFAILED','您的密码不符合%s密码规范，请您立即重置密码','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='NOTICEPASSWORDSTANDARDFAILED' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NOTICEPASSWORDSTANDARDFAILED','Your password does not conform to the %s password standard, please reset your password immediately','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='NOTICEPASSWORDSTANDARDFAILED' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PMENTERNEWPASSWORD','请输入新密码','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMENTERNEWPASSWORD' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PMENTERNEWPASSWORD','Please import new password','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMENTERNEWPASSWORD' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PMLEASTPASSWORDLENGTH','用户密码长度至少需要%s位','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMLEASTPASSWORDLENGTH' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PMLEASTPASSWORDLENGTH','The user password length should have at least %s','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMLEASTPASSWORDLENGTH' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PMPASSWORDILLEGALCONTAIN','用户密码不能包含用户账号或者用户名','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMPASSWORDILLEGALCONTAIN' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PMPASSWORDILLEGALCONTAIN','User password cannot contain the user id or user name','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMPASSWORDILLEGALCONTAIN' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PMREQUIREMENTLACK','用户密码只符合规范中的%s项要求，应至少符合3项要求','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMREQUIREMENTLACK' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PMREQUIREMENTLACK','User password only conform to the requirements of the specifications of the %s, should conform to the requirements of the 3 items at least','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMREQUIREMENTLACK' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PMPASSWORDTIMEOUT','您已经%s天未重置密码，请您立即重置密码','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMPASSWORDTIMEOUT' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PMPASSWORDTIMEOUT','You have %s days not reset the password, please reset your password immediately','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMPASSWORDTIMEOUT' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PMENTERCONFIRMPASSWORD','请输入确认密码','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMENTERCONFIRMPASSWORD' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PMENTERCONFIRMPASSWORD','Please enter the confirmation password','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMENTERCONFIRMPASSWORD' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PMINCONSISTENTPASSWORD','新密码和确认密码不一致 ','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMINCONSISTENTPASSWORD' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PMINCONSISTENTPASSWORD','The new password and confirm password don''t match ','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMINCONSISTENTPASSWORD' and languagetype='en');
delimiter;




insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PMWARMREMINDFORPASSWORD','密码规范$=$
            1.普通用户每隔90天需要重置密码，管理员用户每隔30天需要重置密码;$=$
            2.普通用户密码至少需要8位，管理员至少需要15位;$=$
            3.密码不能包含用户账户或者用户名信息;
             ','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMWARMREMINDFORPASSWORD' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PMWARMREMINDFORPASSWORDADD','4.密码至少需要符合以下3项要求：$=$
            ●包含大写英文字母(A-Z)$=$
            ●包含小写英文字母(a-z)$=$
            ●包含数字(0-9)$=$
            ●包含特殊字符(!@#$...)
             ','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMWARMREMINDFORPASSWORDADD' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PMWARMREMINDFORPASSWORD','Password Specification$=$1.Ordinary users every 90 days need to reset the password, administrator user need to reset your password every 30 days;$=$2.Ordinary user password should have at least eight, the administrator will need at least 15;$=$3.Password cannot contain the user account or password information; ','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMWARMREMINDFORPASSWORD' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PMWARMREMINDFORPASSWORDADD','4.Password requires at least meet the following 3 requirements:$=$●Contains uppercase English letters$=$●Contain lowercase English letters$=$●Contains Numbers$=$●Contain special characters ','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='PMWARMREMINDFORPASSWORDADD' and languagetype='en');
delimiter;

update ld_field set typeofdata = 'V~O' where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'remark' and fieldname = 'remark';
delimiter;
update ld_field set typeofdata = 'V~O' where tabid = (select tabid from ld_tab where `name` = 'Stock') and columnname = 'remark' and fieldname = 'remark';
delimiter;
update ld_field set presence = 1 where tabid = (select tabid from ld_tab where `name` = 'Users') and columnname = 'departments' and fieldname = 'departments';
delimiter;
update ld_desk set fieldlabel = '目标完成情况统计图' where labelbol = 'TEMPLATESALESGOALIMG' and languagetype = 'zh';
delimiter;
-- 2016-01-18

UPDATE ld_desk set fieldlabel = '4.密码至少需要符合以下3项要求：$=$
            包含大写英文字母(A-Z)$=$
            包含小写英文字母(a-z)$=$
            包含数字(0-9)$=$
            包含特殊字符(!@#$...)' WHERE labelbol = 'PMWARMREMINDFORPASSWORDADD' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set fieldlabel = '4.Password requires at least meet the following 3 requirements:$=$  Contain uppercase English letters$=$  Contain lowercase English letters$=$  Contain Numbers$=$  Contain special characters' WHERE labelbol = 'PMWARMREMINDFORPASSWORDADD' and languagetype='en';
UPDATE ld_desk set labelbol = 'PASSWORDMANAGED' WHERE labelbol='PASSWORDMANAGE' and Labeltype='fixedstr';
delimiter;
-- 2016-01-19

update ld_field set quickcreate=1,quickcreatesequence=NULL where tabid=29;
-- 2016-01-21

CALL AddColumn('ld_datainterface','using_order_read','tinyint','1','0');
delimiter;
CALL AddColumn('ld_datainterface','using_quote_read','tinyint','1','0');
delimiter;
CALL AddColumn('ld_datainterface','using_ticket_read','tinyint','1','0');
delimiter;
CALL AddColumn('ld_datainterface','setting_mode','int','11','0');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','ENABLEREADORDERINTERFACE','启用订单读取接口','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'ENABLEREADORDERINTERFACE' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','ENABLEREADORDERINTERFACE','Enable Read Order Interface','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'ENABLEREADORDERINTERFACE' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','ENABLEREADQUOTEINTERFACE','启用报价单读取接口','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'ENABLEREADQUOTEINTERFACE' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','ENABLEREADQUOTEINTERFACE','Enable Read Quote Interface','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'ENABLEREADQUOTEINTERFACE' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','ENABLEREADTICKETINTERFACE','启用服务单读取接口','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'ENABLEREADTICKETINTERFACE' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','ENABLEREADTICKETINTERFACE','Enable Read Ticket Interface','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'ENABLEREADTICKETINTERFACE' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','DATAINTERFACESTEP7','5.读取接口：在客户相关信息中按照客户名称模糊匹配读取并显示接口帐套中相关单据信息。','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'DATAINTERFACESTEP7' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','DATAINTERFACESTEP7','Read bills of the interface soft, dispaly in the customer related information.','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'DATAINTERFACESTEP7' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','SELECTDATABASE','配置连接','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SELECTDATABASE' AND labeltype = 'jspop');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','SELECTDATABASE','Select database','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SELECTDATABASE' AND labeltype = 'jspop');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','SELECTDATABASE','配置连接','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SELECTDATABASE' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','SELECTDATABASE','Select database','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SELECTDATABASE' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','Configure','设置','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'Configure' AND labeltype = 'jspop');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','Configure','Configure','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'Configure' AND labeltype = 'jspop');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','TESTCONNECTION','测试连接','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'TESTCONNECTION' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','TESTCONNECTION','test connection','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'TESTCONNECTION' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','DATABASEENTITY','数据库实体','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'DATABASEENTITY' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','DATABASEENTITY','Database entity','fixedstr'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'DATABASEENTITY' AND labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','ZHANGTAOCHOOSE','账套选择','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'ZHANGTAOCHOOSE' AND labeltype = 'jspop');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','ZHANGTAOCHOOSE','Ledger selection','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'ZHANGTAOCHOOSE' AND labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONNECTINGMODE','连接方式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol ='CONNECTINGMODE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONNECTINGMODE','Connecting Mode','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol ='CONNECTINGMODE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DIRECTCONNECTION','直接连接(SQLSRV)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol ='DIRECTCONNECTION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DIRECTCONNECTION','SQLSRV','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol ='DIRECTCONNECTION' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DATASOURCEODBC','数据源(ODBC)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol ='DATASOURCEODBC' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DATASOURCEODBC','ODBC','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol ='DATASOURCEODBC' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DATASOURCEODBC','数据源(ODBC)','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol ='DATASOURCEODBC' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DATASOURCEODBC','ODBC','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol ='DATASOURCEODBC' and labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','DATABASEENTITY','数据库实体','jspop' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'DATABASEENTITY' AND labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','DATABASEENTITY','Database entity','jspop' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'DATABASEENTITY' AND labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'zh','SOFTWAREVERSION','软件版本','jspop' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SOFTWAREVERSION' AND labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
SELECT 'en','SOFTWAREVERSION','Software version','jspop' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SOFTWAREVERSION' AND labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel = '账套数据库' where labelbol = 'ZHANGTAONAME' and languagetype = 'zh';
delimiter;
update ld_desk set fieldlabel = 'Account database name' where labelbol = 'ZHANGTAONAME' and languagetype = 'en';
delimiter;

call AddColumn('ld_datainterface','connect_mode','varchar','25',NULL);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Accounts'; 
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists; 
SELECT COUNT(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid=@tabid; 
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,-1,'get_Kingdeeorders',@sequence+1,'Kingdeeorders',0,'',1,@sequence+1 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_Kingdeeorders'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','KINGDEEORDERS','金蝶订单','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'KINGDEEORDERS' and languagetype = 'zh' and labeltype = 'fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','KINGDEEORDERS','Kingdee Orders','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'KINGDEEORDERS' and languagetype = 'en' and labeltype = 'fixedstr'); 
delimiter; 

SELECT sequence INTO @sequence2 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_Kingdeeorders'; 
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+2,@tabid,-2,'get_Kingdeequotes',@sequence2,'Kingdeequotes',0,'',1,@sequence2 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_Kingdeequotes'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','KINGDEEQUOTES','金蝶报价单','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'KINGDEEQUOTES' and languagetype = 'zh' and labeltype = 'fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','KINGDEEQUOTES','Kingdee Quotes','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'KINGDEEQUOTES' and languagetype = 'en' and labeltype = 'fixedstr'); 
delimiter; 
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists); 

CALL AddColumn('ld_datainterface','using_order_read','tinyint','1','0'); 
delimiter; 
CALL AddColumn('ld_datainterface','using_quote_read','tinyint','1','0'); 
delimiter; 

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Accounts';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
SELECT COUNT(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid=@tabid;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,-3,'get_Digiwinorders',@sequence+1,'Digiwinorders',0,'',1,@sequence+1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_Digiwinorders');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DIGIWINORDERS','鼎捷订单','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DIGIWINORDERS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DIGIWINORDERS','Digiwin Orders','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DIGIWINORDERS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

SELECT sequence INTO @sequence2 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_Digiwinorders';
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+2,@tabid,-4,'get_Digiwintickets',@sequence2,'Digiwintickets',0,'',1,@sequence2
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_Digiwintickets');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DIGIWINTICKETS','鼎捷服务单','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DIGIWINTICKETS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DIGIWINTICKETS','Digiwin Tickets','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DIGIWINTICKETS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists); 
delimiter;
-- 2016-01-25

select tabid into @tabid from ld_tab where `name` = 'Checks';
update ld_field set typeofdata = 'V~O' where tabid = @tabid and fieldname = 'presence' and columnname = 'presence' and uitype = 130;
delimiter;
-- 2015-01-26

update ld_desk set fieldlabel='修改负责人为' where labelbol='Transfer_ownership_relationships' and languagetype='zh';
update ld_desk set fieldlabel='Modify the person in charge' where labelbol='Transfer_ownership_relationships' and languagetype='en';
-- 2016-01-27

select tabid into @tabid from ld_tab where `name`='ModComments';
update ld_field set masseditable=0 where tabid=@tabid and columnname='reltab';
delimiter;

select tabid into @tabid from ld_tab where `name`='PutCash';
update ld_field set quickcreate=0 where tabid=@tabid and columnname='currency_id';

select quickcreatesequence into @seq from ld_field where tabid=@tabid and columnname='inaccount';
update ld_field set quickcreatesequence=quickcreatesequence+1 where tabid=@tabid and quickcreatesequence>@seq;
update ld_field set quickcreatesequence=@seq+1 where tabid=@tabid and columnname='currency_id';
set @i=0;
update ld_field set quickcreatesequence=(@i:=@i+1) where tabid=@tabid and quickcreate=0 order by quickcreatesequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='CashDeposit';
update ld_field set quickcreate=0 where tabid=@tabid and columnname='currency_id';

select quickcreatesequence into @seq from ld_field where tabid=@tabid and columnname='outaccount';
update ld_field set quickcreatesequence=quickcreatesequence+1 where tabid=@tabid and quickcreatesequence>@seq;
update ld_field set quickcreatesequence=@seq+1 where tabid=@tabid and columnname='currency_id';
set @i=0;
update ld_field set quickcreatesequence=(@i:=@i+1) where tabid=@tabid and quickcreate=0 order by quickcreatesequence;
delimiter;

set @tabid=29;
set @blockid=77;
update ld_field set sequence=sequence+50 where tabid=@tabid and block=@blockid;
update ld_field set sequence=1 where tabid=@tabid and block=@blockid and columnname='user_name';
update ld_field set sequence=2 where tabid=@tabid and block=@blockid and columnname='is_admin';
update ld_field set sequence=3 where tabid=@tabid and block=@blockid and columnname='user_password';
update ld_field set sequence=4 where tabid=@tabid and block=@blockid and columnname='confirm_password';
update ld_field set sequence=5 where tabid=@tabid and block=@blockid and columnname='last_name';
update ld_field set sequence=6 where tabid=@tabid and block=@blockid and columnname='profileid';
update ld_field set sequence=7 where tabid=@tabid and block=@blockid and columnname='groupid';
update ld_field set sequence=8 where tabid=@tabid and block=@blockid and columnname='status';
update ld_field set sequence=8 where tabid=@tabid and block=@blockid and columnname='phone_mobile';
update ld_field set sequence=9 where tabid=@tabid and block=@blockid and columnname='phone_home';
update ld_field set sequence=10 where tabid=@tabid and block=@blockid and columnname='email1';
update ld_field set sequence=11 where tabid=@tabid and block=@blockid and columnname='level';
update ld_field set sequence=12 where tabid=@tabid and block=@blockid and columnname='approvestatus';
update ld_field set sequence=13 where tabid=@tabid and block=@blockid and columnname='approveby';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','IMPORTRECIPIENTPHONE','导入接收人手机','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='IMPORTRECIPIENTPHONE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','IMPORTRECIPIENTPHONE','Import recipient phone','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='IMPORTRECIPIENTPHONE' and Labeltype='fixedstr');
delimiter;

delete from ld_cvcolumnlistsort where cvid in (select cvid from ld_customview where entitytype='ServiceCharge') and columnname like '%ld_account:servicecasher%';
-- 2016-01-28

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
delimiter;

update ld_version set old_version='V6.2.0' ,current_version='V6.2.0' ,remark='V6.2.0-20160128';
delimiter;