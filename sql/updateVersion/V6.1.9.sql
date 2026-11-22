DROP PROCEDURE IF EXISTS `fieldprofile`;
delimiter ||
CREATE  PROCEDURE `fieldprofile`(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from ld_def_org_field where fieldid=',ffieldid,')');
	
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select tabid into @project_tabid from ld_tab where `name` = 'Project';
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
select id into @id from ld_relatedlists_seq;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@project_tabid,'get_project',@sequence+1,'Project',0,'add' from dual where not exists(
select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @project_tabid);
delimiter;

select usereportid into @id from ld_usereport where name='SalesReport';
SELECT tabid into @tid from ld_tab where name='SalesOrder';
insert into ld_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','yuanzhoureport','远洲核信毛利表',@tid,1,0,1,@id,12,10,100 
from dual where not exists(select usereportid from ld_usereport where name='yuanzhoureport');
delimiter;

select usereportid into @id from ld_usereport where name='yuanzhoureport';
insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=3);

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_account:accountname:accountname:Accounts_accountname:I','',4  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=4);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','yuanzhoureport','远洲核信毛利表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='yuanzhoureport' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','yuanzhoureport','FSNI Report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='yuanzhoureport' and Labeltype='fixedstr');

select usereportid into @id from ld_usereport where name='yuanzhoureport';

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_users:rownum:rownum:OftenUseReport_rownum:V', 1, 1, 'ld_users:rownum:rownum:OftenUseReport_序号:V','ld_users:rownum:rownum:OftenUseReport_number:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_users:rownum:rownum:OftenUseReport_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:salesorder_no:salesorder_no:SaleSorder_salesorder_no:V', 2, 1, 'ld_salesorder:salesorder_no:salesorder_no:SaleSorder_合同编号:V','ld_salesorder:salesorder_no:salesorder_no:SaleSorder_Contract Number:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesorder:salesorder_no:salesorder_no:SaleSorder_%');


insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:subject:subject:SalesOrder_subject:V', 3, 1, 'ld_salesorder:subject:subject:SalesOrder_合同名称:V','ld_salesorder:subject:subject:SalesOrder_subject:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesorder:subject:subject:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_users:last_name:last_name:Users_last_name:V', 4, 1, 'ld_users:last_name:last_name:Users_项目经理:V','ld_users:last_name:last_name:Users_Person in charge:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_users:last_name:last_name:Users_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_account:accountname:accountname:Accounts_accountname:V', 5, 1, 'ld_account:accountname:accountname:Accounts_客户名称:V','ld_account:accountname:accountname:Accounts_amount of receivables:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_account:accountname:accountname:Accounts_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D', 6, 1, 'ld_salesorder:signed_data:signed_data:SaleSorder_签订日期:D','ld_salesorder:signed_data:signed_data:SalesOrder_signed data:D'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesorder:signed_data:signed_data:SaleSorder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:subtotal:subtotal:SalesOrder_subtotal:N', 7, 1, 'ld_salesorder:subtotal:subtotal:SaleSorder_合同金额:N','ld_salesorder:subtotal:subtotal:SalesOrder_subtotal:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesorder:subtotal:subtotal:SaleSorder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:subtotal:subtotal:CashBill_subtotal:N', 8, 1, 'ld_cashbill:subtotal:subtotal:CashBill_合同回款:N','ld_cashbill:subtotal:subtotal:CashBill_subtotal:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_cashbill:subtotal:subtotal:CashBill_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D', 9, 1, 'ld_cashbill:cashbilldate:cashbilldate:CashBill_回款日期:D','ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_cashbill:cashbilldate:cashbilldate:CashBill_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_invoice:total:total:Invoice_total:N', 10, 1,
 'ld_invoice:total:total:Invoice_开票金额:N','ld_invoice:total:total:Invoice_total:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_invoice:total:total:Invoice_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_invoice:invoicedate:invoicedate:Invoice_invoicedate:D', 11, 1,
 'ld_invoice:invoicedate:invoicedate:Invoice_开票日期:D','ld_invoice:invoicedate:invoicedate:Invoice_invoicedate:D'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_invoice:invoicedate:invoicedate:Invoice_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_products:costprice:costprice:Products_costprice:N', 12, 1,
 'ld_products:costprice:costprice:Products_销售成本:N','ld_products:costprice:costprice:Products_costprice:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_products:costprice:costprice:Products_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_purchaseorder:subtotal:subtotal:PurchaseOrder_subtotal:N', 13, 1,
 'ld_purchaseorder:subtotal:subtotal:PurchaseOrder_采购成本:N','ld_purchaseorder:subtotal:subtotal:PurchaseOrder_subtotal:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_purchaseorder:subtotal:subtotal:PurchaseOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_commission:total:total:Commission_total:N', 14, 1,
 'ld_commission:total:total:Commission_工程费:N','ld_commission:total:total:Commission_total:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_commission:total:total:Commission_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_expense:total:total:Expense_total:N', 15, 1,
 'ld_expense:total:total:Expense_费用报销:N','ld_expense:total:total:Expense_total:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id 
and realcolumns like 'ld_expense:total:total:Expense_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:lilv:lilv:OftenUseReport_lilv:V', 16, 1, 'ld_salesorder:lilv:lilv:OftenUseReport_毛利率:V','ld_salesorder:lilv:lilv:OftenUseReport_lilv:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesorder:lilv:lilv:OftenUseReport_%');

update ld_systems_deploy set deploy_value = 2 where deploy_type = 65;
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Project'; 
update ld_field SET displaytype=2
WHERE tabid=@tabid AND fieldname IN('hascost','hastime','completetask');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Productinformationintabularformat','非表格格式的产品明细信息','fixedstr' from dual where not exists( 
select 1 from ld_desk where languagetype = 'zh' and labeltype = 'fixedstr' and labelbol = 'Productinformationintabularformat'); 
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Productinformationintabularformat','Product information in tabular format','fixedstr' from dual where not exists( 
select 1 from ld_desk where languagetype = 'en' and labeltype = 'fixedstr' and labelbol = 'Productinformationintabularformat');
delimiter;
-- 2015-11-25

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileVendors',1,50,'mobileVendors',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileVendors');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileVendors' and entitytype='mobileVendors');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileVendors',0,0,'mobileVendors',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileVendors' and entitytype='mobileVendors');
select cvid into @cvid   from ld_customview where viewname='mobileVendors' and entitytype='mobileVendors';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileVendors' and entitytype='mobileVendors' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_vendor:vendor_no:vendor_no:Vendors_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_vendor:vendorname:vendorname:Vendors_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_vendor:smownerid:assigned_user_id:Vendors_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_vendor:createdtime:createdtime:Vendors_fieldlabel:V' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BROWSERNOTSUPPORTTIPS','您的浏览器可能不支持或只支持部分软件功能，为了更好地体验，建议您使用如下浏览器访问：' ,'fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='BROWSERNOTSUPPORTTIPS');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BROWSERNOTSUPPORTTIPS','Your browser may not support or support only part of the software functions, in order to obtain better experience, it is recommended that you use the following browser to access' ,'fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='BROWSERNOTSUPPORTTIPS');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
SELECT fieldid into @fieldid FROM ld_field WHERE ld_field.tabid= @tabid AND fieldname='projectid';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status)
select @fieldid,'Commission','Project',0 from dual where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Commission');
delimiter;

update ld_desk set Fieldlabel='是否需要验证' where labelbol='REQIREAUTHEN' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Whether you need to verify' where labelbol='REQIREAUTHEN' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

SELECT max(sequence) into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence) 
select 0,80,'设置手机号码的显示样式','',@sequence+1 
from dual where not exists(select 1 from ld_systems_deploy where description='设置手机号码的显示样式');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','SETPROPERTIESOFPHONENUMBERS','设置手机号码的显示样式','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='SETPROPERTIESOFPHONENUMBERS' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','SETPROPERTIESOFPHONENUMBERS','Set properties of phone numbers','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='SETPROPERTIESOFPHONENUMBERS' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','DISPLAYTHEALL','全部显示','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='DISPLAYTHEALL' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','DISPLAYTHEALL','Display all','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='DISPLAYTHEALL' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','HIDETHEMIDDLE4','隐藏中间4位','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='HIDETHEMIDDLE4' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','HIDETHEMIDDLE4','Hide the middle 4','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='HIDETHEMIDDLE4' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','HIDETHELAST4NUMBERS','隐藏末尾4位','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='HIDETHELAST4NUMBERS' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','HIDETHELAST4NUMBERS','Hide the last 4 numbers','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='HIDETHELAST4NUMBERS' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','HIDEALLNUMBERS','全部隐藏','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='HIDEALLNUMBERS' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','HIDEALLNUMBERS','Hide all numbers','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='HIDEALLNUMBERS' and languagetype='en');
delimiter;
SELECT max(sequence) into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence) 
select 0,81,'手机号码样式影响数据范围','',@sequence+1 
from dual where not exists(select 1 from ld_systems_deploy where description='手机号码样式影响数据范围');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','DATARANGEAFFECTEDBYSTYLEOFMOBILEPHONE','手机号码样式影响数据范围','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='DATARANGEAFFECTEDBYSTYLEOFMOBILEPHONE' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','DATARANGEAFFECTEDBYSTYLEOFMOBILEPHONE','Data range affected by the style of the mobile phone','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='DATARANGEAFFECTEDBYSTYLEOFMOBILEPHONE' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','ALLOFHEDATA','所有数据','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='ALLOFHEDATA' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','ALLOFHEDATA','All of the data','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='ALLOFHEDATA' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','THEPERSONINCHARGEISNOTHIMSELF','负责人不是自己的数据','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='THEPERSONINCHARGEISNOTHIMSELF' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','THEPERSONINCHARGEISNOTHIMSELF','The person in charge is not himself','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='THEPERSONINCHARGEISNOTHIMSELF' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','BOTHPERSONINCHARGEANDCREATORNOTTHEMSELVES','负责人及创建人都不是自己的数据','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BOTHPERSONINCHARGEANDCREATORNOTTHEMSELVES' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','BOTHPERSONINCHARGEANDCREATORNOTTHEMSELVES','Both the person in charge and creator  are not themselves','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BOTHPERSONINCHARGEANDCREATORNOTTHEMSELVES' and languagetype='en');
delimiter;

call AddColumn('ld_users','edit_other_mobile','int',4,0);
select max(fieldid) into @maxfieldid from ld_field ;
select tabid into @tabid from ld_tab where name='Users';
select blockid into @blockid from ld_blocks where blocklabel='LBL_USER_DATAACCESS';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'edit_other_mobile','ld_users',1,56,'edit_other_mobile','是否允许编辑其他用户单据的手机号码字段',0,0,26, @blockid,1,'V~O',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='edit_other_mobile');
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='edit_other_mobile');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='edit_other_mobile';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'是否允许编辑其他用户单据的手机号码字段' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Allow to edit other users'' mobile' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
update ld_field set masseditable=0 where uitype=1101;

update ld_field set typeofdata='V~O' where tabid=48 and columnname='salesorderid';
delimiter;

update ld_desk set Fieldlabel='单据[%s]转为公海客户失败，原因：当前单据已经是公海客户了！' where labelbol='TOTHEHIGNSEASCUSTOMERERROR' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;
-- 2015-11-27


select cvid into @cvid from ld_customview where entitytype='Project' and viewname='All';
update ld_cvcolumnlist set columnindex=columnindex+100 where cvid=@cvid and columnindex>2;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_project:accountid:account_id:Project_fieldlabel:I' from dual 
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like 'ld_project:accountid:account_id%');

update ld_cvcolumnlist set columnindex=columnindex+200 where cvid=@cvid;

set @i=0;
update ld_cvcolumnlist set columnindex=(@i:=@i+1) where cvid=@cvid order by columnindex;
delimiter;

set @tabid=48;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='completetask';
update ld_tranlabel set fieldlabel='已完成任务数' where trantable='ld_field' and languagetype='zh' and tabid=@tabid and Relateid=@fieldid;
delimiter;

call AddColumn('ld_users','push_work_reminds','int',4,0);
delimiter;

select max(fieldid) into @maxfieldid from ld_field ;
select tabid into @tabid from ld_tab where name='Users';
select blockid into @blockid from ld_blocks where blocklabel='LBL_USERLOGIN_ROLE';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'push_work_reminds','ld_users',1,56,'push_work_reminds','是否允许推送工作提醒',0,0,20, @blockid,1,'V~O',3,1,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='push_work_reminds');
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='push_work_reminds');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='push_work_reminds';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'是否允许推送工作提醒' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Are allowed to push work reminder' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

call AddColumn('ld_users','push_news_reminds','int',4,0);
delimiter;

select max(fieldid) into @maxfieldid from ld_field ;
select tabid into @tabid from ld_tab where name='Users';
select blockid into @blockid from ld_blocks where blocklabel='LBL_USERLOGIN_ROLE';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'push_news_reminds','ld_users',1,56,'push_news_reminds','是否允许推送消息提醒',0,0,21, @blockid,1,'V~O',3,1,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='push_news_reminds');
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='push_news_reminds');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='push_news_reminds';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'是否允许推送消息提醒' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Are allowed to push news reminder' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='Users';
select max(blockid) into @maxblockid from ld_blocks ;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_USERLOGIN_MOBILE',15,0,0,0,0,0,1,0 from DUAL 
where not EXISTS(select 1 from ld_blocks where tabid=@tabid and blocklabel='LBL_USERLOGIN_MOBILE');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USERLOGIN_MOBILE';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_blocks',@tabid,@blockid,'手机端相关设置' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_blocks' and tabid=@tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_blocks',@tabid,@blockid,'Mobile terminal related settings' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_blocks' and tabid=@tabid and relateid=@blockid);
delimiter;

select tabid into @tabid from ld_tab where name='Users';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USERLOGIN_MOBILE';
update ld_field set block=@blockid where tabid = @tabid and columnname in ('telephone_view','push_work_reminds','push_news_reminds');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh' ,'UPDATEPROJECTASKSTATUS','更改{$ProjectTask.projecttaskstatus}','fixedstr' 
from dual where not exists( select 1 from ld_desk where labelbol='UPDATEPROJECTASKSTATUS' and languagetype='zh'  );
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en' ,'UPDATEPROJECTASKSTATUS','Update {$ProjectTask.projecttaskstatus}','fixedstr' 
from dual where not exists( select 1 from ld_desk where labelbol='UPDATEPROJECTASKSTATUS' and languagetype='en'  );
delimiter;

call AddColumn('ld_account','distributiondate','date',0,0); 
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Accounts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ACCOUNT_INFORMATION';
select max(fieldid) into @fieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,maximumlength,quickcreatesequence,info_type)
select @tabid,@fieldid+1,'distributiondate','ld_account',70,'distributiondate','分配日期',@blockid,2,2,'D~O',1,@sequence+1,100,0,'BAS'
from dual where not exists(select * from ld_field where tabid = @tabid and columnname = 'distributiondate' and uitype = 70);
update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'distributiondate' and uitype = 70;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'分配日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Distribution date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

call getallprofile('Accounts');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELIVERYDATEREMINDERINFO','交付日期提醒，合同订单：','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DELIVERYDATEREMINDERINFO' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELIVERYDATEREMINDERINFO','Delivery date reminder, contract order:','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DELIVERYDATEREMINDERINFO' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELIVERYDATEREMINDER','交付日期提醒','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DELIVERYDATEREMINDER' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELIVERYDATEREMINDER','Delivery date reminder','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DELIVERYDATEREMINDER' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTSERVICEEXPIRATIONREMINDER','产品服务到期提醒，','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PRODUCTSERVICEEXPIRATIONREMINDER' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTSERVICEEXPIRATIONREMINDER,','Product service expiration reminder,','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PRODUCTSERVICEEXPIRATIONREMINDER' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTSSPIRITWHEN','中的产品','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PRODUCTSSPIRITWHEN' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTSSPIRITWHEN','products spirit when','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PRODUCTSSPIRITWHEN' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WILLEXPIREAT','将在','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'WILLEXPIREAT' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WILLEXPIREAT','will expire at','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'WILLEXPIREAT' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEFOLLOWUPINATIMELYMANNER','到期，请及时跟进！','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASEFOLLOWUPINATIMELYMANNER' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEFOLLOWUPINATIMELYMANNER','please follow up in a timely manner.','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASEFOLLOWUPINATIMELYMANNER' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PAYMENTPLANEXPIRES','回款计划到期，请及时催收！公司名称：','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PAYMENTPLANEXPIRES' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PAYMENTPLANEXPIRES','Payment plan expires, please timely collection! Company name:','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PAYMENTPLANEXPIRES' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STAGESINFO','，期次：','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'STAGESINFO' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STAGESINFO',',Stages:','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'STAGESINFO' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AMOUNTINFO','，金额：','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'AMOUNTINFO' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AMOUNTINFO',',Amount:','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'AMOUNTINFO' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RETURNVISIT','回访提醒，','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'RETURNVISIT' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RETURNVISIT','Return visit,','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'RETURNVISIT' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWANNEX',' 新增附件：','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'NEWANNEX' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWANNEX','New annex:','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'NEWANNEX' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITANNEX',' 编辑附件：','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'EDITANNEX' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITANNEX','Edit annex:','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'EDITANNEX' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETEANNEX',' 删除附件：','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DELETEANNEX' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETEANNEX','Delete annex:','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DELETEANNEX' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','intheinstankinventory','调入即时库存','fixedstr' from dual where not exists(
select 1 from ld_desk where languagetype = 'zh' and labelbol = 'intheinstankinventory' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','intheinstankinventory','In the instank inventory','fixedstr' from dual where not exists(
select 1 from ld_desk where languagetype = 'en' and labelbol = 'intheinstankinventory' and labeltype = 'fixedstr');
delimiter;

call getallprofile('Project');
delimiter;


call getallprofile('ProjectTask');
delimiter;


call getallprofile('ProjectProgress');
delimiter;

call getallprofile('Users');
delimiter;

update ld_tab set presence=1 where `name`='ProjectProgress' and exists (select 1 from ld_version where versiontype <>1);
-- 2015-11-30

update ld_users set edit_other_mobile=1;
update ld_field set defaultvalue=1 where tabid=29 and columnname='edit_other_mobile';

select fieldid into @fieldid from ld_field where tabid=29 and columnname='edit_other_mobile';
update ld_tranlabel set fieldlabel='允许编辑其他用户单据的手机号码字段' where languagetype='zh' and trantable='ld_field' and tabid=29 and Relateid=@fieldid;
delimiter;


select tabid into @tabid from ld_tab where name='ProjectProgress';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='projectid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,1,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='servicecontractsid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,2,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='projectmilestoneid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,3,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='projecttaskid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,4,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='lessiondate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,5,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='lessiontype';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,6,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='ProjectProgress';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='projectprogress_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,1,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);


select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='projectid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,2,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);



select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='projecttaskid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,3,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);


select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='timecost';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,4,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);


select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='totalcost';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,5,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,6,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);
delimiter;



set @tabid=22;
set @blockid=61;
set @tablename='ld_salesorder';
set @columnname='received_amount';
set @fieldname='received_amount';
set @zh='已收总额';
set @en='Received Amount';
set @uitype=71;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='N~O~25,2';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'decimal','25',NULL);
delimiter;

set @tabid=22;
set @blockid=61;
set @tablename='ld_salesorder';
set @columnname='receivable_balance';
set @fieldname='receivable_balance';
set @zh='应收余额';
set @en='Receivable Balance';
set @uitype=71;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='N~O~25,2';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'decimal','25',NULL);
delimiter;  


set @tabid=37;
set @blockid=91;
set @tablename='ld_servicecontracts';
set @columnname='received_amount';
set @fieldname='received_amount';
set @zh='已收总额';
set @en='Received Amount';
set @uitype=71;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='N~O~25,2';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'decimal','25',NULL);
delimiter;

set @tabid=37;
set @blockid=91;
set @tablename='ld_servicecontracts';
set @columnname='receivable_balance';
set @fieldname='receivable_balance';
set @zh='应收余额';
set @en='Receivable Balance';
set @uitype=71;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='N~O~25,2';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'decimal','25',NULL);
delimiter;  



drop trigger if exists update_salesorder_received1; 
delimiter || 
CREATE TRIGGER update_salesorder_received1 
AFTER UPDATE ON ld_cashbill 
FOR EACH ROW 
BEGIN 

select deploy_value into @deploy_value from ld_systems_deploy where deploy_type=83;
IF @deploy_value=1 then 
	update 
			ld_salesorder j
			LEFT JOIN (
			select
			 h.entitytypeid,
			 sum(h.amount) as amount
			from (
				select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytype='SalesOrder' and a.deleted=0 and a.checkoutstatus='已审核'
				UNION ALL
				select * from (
					select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					LEFT JOIN (select * from (
							select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							where entitytype='SalesOrder' 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
					where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
					group by h.entitytypeid) as k  on j.salesorderid=k.entitytypeid
	set j.received_amount=round(ifnull(k.amount,0)*j.conversion_rate,2),j.receivable_balance=round(j.total-round(ifnull(k.amount,0)*j.conversion_rate,2),2)
	where j.salesorderid in (select entitytypeid from ld_cashbill2paymentplan where CashBillID=old.cashbillid);

	update 
			ld_servicecontracts j
			LEFT JOIN (
			select
			 h.entitytypeid,
			 sum(h.amount) as amount
			from (
				select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytype='ServiceContracts' and a.deleted=0 and a.checkoutstatus='已审核'
				UNION ALL
				select * from (
					select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					LEFT JOIN (select * from (
							select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							where entitytype='ServiceContracts' 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
					where e.NoPaymentplan<>0 and e.deleted=0 and e.checkoutstatus='已审核' and f.entitytypeid>0 ) as g) as h
					group by h.entitytypeid) as k  on j.servicecontractsid=k.entitytypeid
	set j.received_amount=round(ifnull(k.amount,0)*j.conversion_rate,2),j.receivable_balance=round(j.total-round(ifnull(k.amount,0)*j.conversion_rate,2),2)
	where j.servicecontractsid in (select entitytypeid from ld_cashbill2paymentplan where CashBillID=old.cashbillid);

ELSE
		update 
			ld_salesorder j
			LEFT JOIN (
			select
			 h.entitytypeid,
			 sum(h.amount) as amount
			from (
				select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytype='SalesOrder' and a.deleted=0
				UNION ALL
				select * from (
					select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					LEFT JOIN (select * from (
							select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							where entitytype='SalesOrder' 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
					where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
					group by h.entitytypeid) as k  on j.salesorderid=k.entitytypeid
	set j.received_amount=round(ifnull(k.amount,0)*j.conversion_rate,2),j.receivable_balance=round(j.total-round(ifnull(k.amount,0)*j.conversion_rate,2),2)
	where j.salesorderid in (select entitytypeid from ld_cashbill2paymentplan where CashBillID=old.cashbillid);


	update 
			ld_servicecontracts j
			LEFT JOIN (
			select
			 h.entitytypeid,
			 sum(h.amount) as amount
			from (
				select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytype='ServiceContracts' and a.deleted=0
				UNION ALL
				select * from (
					select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					LEFT JOIN (select * from (
							select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							where entitytype='ServiceContracts' 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
					where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
					group by h.entitytypeid) as k  on j.servicecontractsid=k.entitytypeid
	set j.received_amount=round(ifnull(k.amount,0)*j.conversion_rate,2),j.receivable_balance=round(j.total-round(ifnull(k.amount,0)*j.conversion_rate,2),2)
	where j.servicecontractsid in (select entitytypeid from ld_cashbill2paymentplan where CashBillID=old.cashbillid);

END IF;

END || 
delimiter; 

drop trigger if exists update_salesorder_received2; 
delimiter || 
CREATE TRIGGER update_salesorder_received2 
BEFORE DELETE ON ld_cashbill 
FOR EACH ROW 
BEGIN 

select deploy_value into @deploy_value from ld_systems_deploy where deploy_type=83;
IF @deploy_value=0 then 
			
			update 
			ld_salesorder j
			LEFT JOIN (
			select
			 h.entitytypeid,
			 sum(h.amount) as amount
			from (
				select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytype='SalesOrder' and a.deleted=0 and a.cashbillid<>old.cashbillid
				UNION ALL
				select * from (
					select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					LEFT JOIN (select * from (
							select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							where entitytype='SalesOrder' 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
					where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 and e.cashbillid<>old.cashbillid) as g) as h
					group by h.entitytypeid) as k  on j.salesorderid=k.entitytypeid
	set j.received_amount=round(ifnull(k.amount,0)*j.conversion_rate,2),j.receivable_balance=round(j.total-round(ifnull(k.amount,0)*j.conversion_rate,2),2)
	where j.salesorderid in (select entitytypeid from ld_cashbill2paymentplan where CashBillID=old.cashbillid);
	update 
				ld_servicecontracts j
				LEFT JOIN (
				select
				 h.entitytypeid,
				 sum(h.amount) as amount
				from (
					select 
					a.cashbillid,
					b.entitytypeid,
					b.amount/a.conversion_rate as amount
					from ld_cashbill a 
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytype='ServiceContracts' and a.deleted=0 and a.cashbillid<>old.cashbillid
					UNION ALL
					select * from (
						select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan/e.conversion_rate as amount
						from ld_cashbill e
						LEFT JOIN (select * from (
							select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							where entitytype='ServiceContracts' 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
						where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 and e.cashbillid<>old.cashbillid) as g) as h
						group by h.entitytypeid) as k  on j.servicecontractsid=k.entitytypeid
		set j.received_amount=round(ifnull(k.amount,0)*j.conversion_rate,2),j.receivable_balance=round(j.total-round(ifnull(k.amount,0)*j.conversion_rate,2),2)
		where j.servicecontractsid in (select entitytypeid from ld_cashbill2paymentplan where CashBillID=old.cashbillid);

END IF;

END || 
delimiter; 

update 
			ld_salesorder j
			LEFT JOIN (
			select
			 h.entitytypeid,
			 sum(h.amount) as amount
			from (
				select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytype='SalesOrder' and a.deleted=0
				UNION ALL
				select * from (
					select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					LEFT JOIN (select * from (
						select CashBillID,entitytypeid 
						from ld_cashbill2paymentplan 
						where entitytype='SalesOrder' 
						order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
					where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
					group by h.entitytypeid) as k  on j.salesorderid=k.entitytypeid
	set j.received_amount=round(ifnull(k.amount,0)*j.conversion_rate,2),j.receivable_balance=round(j.total-round(ifnull(k.amount,0)*j.conversion_rate,2),2);
delimiter;

update 
			ld_servicecontracts  j
			LEFT JOIN (
			select
			 h.entitytypeid,
			 sum(h.amount) as amount
			from (
				select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytype='ServiceContracts' and a.deleted=0
				UNION ALL
				select * from (
					select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					LEFT JOIN (select * from (
						select CashBillID,entitytypeid 
						from ld_cashbill2paymentplan 
						where entitytype='ServiceContracts' 
						order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
					where e.NoPaymentplan<>0 and e.deleted=0 and f.entitytypeid>0 ) as g) as h
					group by h.entitytypeid) as k  on j.servicecontractsid=k.entitytypeid
	set j.received_amount=round(ifnull(k.amount,0)*j.conversion_rate,2),j.receivable_balance=round(j.total-round(ifnull(k.amount,0)*j.conversion_rate,2),2);
delimiter;

alter table ld_users alter column push_work_reminds set default 1; 
delimiter;
-- 2015-12-01

alter table ld_users alter column push_work_reminds set default 1; 
delimiter;

select cvid into @cvid   from ld_customview where viewname='mobilePotentials' and entitytype='mobilePotentials';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobilePotentials' and entitytype='mobilePotentials' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_potential:potentialname:potentialname:Potentials_机会名称:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_potential:smownerid:assigned_user_id:Potentials_负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_potential:accountid:account_id:Potentials_客户名称:V' );
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
update ld_relatedlists set mobile_presence =0 where tabid = @tabid and label in ('VendorContact','VendorContactRecords');
delimiter;

alter table ld_tab modify column name varchar(50) ;
delimiter;

alter table ld_tab modify column tablabel varchar(50) ;
delimiter;

alter table ld_customview modify column entitytype varchar(50) ;
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileVendorContact',1,50,'mobileVendorContact',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileVendorContact');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileVendorContact' and entitytype='mobileVendorContact');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileVendorContact',0,0,'mobileVendorContact',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileVendorContact' and entitytype='mobileVendorContact');
select cvid into @cvid   from ld_customview where viewname='mobileVendorContact' and entitytype='mobileVendorContact';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileVendorContact' and entitytype='mobileVendorContact' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_vendorcontacts:lastname:lastname:VendorContact_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_vendorcontacts:smownerid:assigned_user_id:VendorContact_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_vendorcontacts:vendorid:vendor_id:VendorContact_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_vendorcontacts:mobile:mobile:VendorContact_fieldlabel:V' );
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileVendorContactRecords',1,50,'mobileVendorContactRecords',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileVendorContactRecords');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileVendorContactRecords' and entitytype='mobileVendorContactRecords');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileVendorContactRecords',0,0,'mobileVendorContactRecords',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileVendorContactRecords' and entitytype='mobileVendorContactRecords');
select cvid into @cvid   from ld_customview where viewname='mobileVendorContactRecords' and entitytype='mobileVendorContactRecords';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileVendorContactRecords' and entitytype='mobileVendorContactRecords' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_vendorcontactrecords:subject:subject:VendorContactRecords_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_vendorcontactrecords:smownerid:assigned_user_id:VendorContactRecords_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_vendorcontactrecords:vendorid:vendor_id:VendorContactRecords_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_vendorcontactrecords:createdtime:createdtime:VendorContactRecords_fieldlabel:V' );
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContact';
update ld_relatedlists set mobile_presence =0 where tabid = @tabid and label in ('VendorContactRecords');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEALLOWEDTYPES','允许的类型','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEALLOWEDTYPES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEALLOWEDTYPES','The allowed types','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEALLOWEDTYPES' and Labeltype='fixedstr');
delimiter;
-- 2015-12-02

select tabid into @tabid from ld_tab where `name`='PaymentPlan';
delete from ld_quickactions where tabid=6 and related_tabid=@tabid;
delimiter;

CREATE TABLE IF not EXISTS `ld_publicannouncement_reminds` (
  `crmid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `presence` int(11) default '0' COMMENT '0未读1已读',
  PRIMARY KEY  (`crmid`,`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

ALTER TABLE ld_producttoolfield_formula  MODIFY COLUMN columnstring VARCHAR(1000);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Accounts';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,0,'get_buyproduct',29,'BoughtProduct',0,'',1,29
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_buyproduct');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BOUGHTPRODUCT','已购产品','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BOUGHTPRODUCT' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BOUGHTPRODUCT','Bought Product','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BOUGHTPRODUCT' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

SELECT max(sequence) into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence) 
select 0,86,'已购产品是否只统计已审批通过的合同订单 0:是，1:否','',@sequence+1 
from dual where not exists(select 1 from ld_systems_deploy where deploy_type=86);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','BOUGHTPRODUCTHASAPPROVEDCONTRACTORDERS','已购产品是否只统计已审批通过的合同订单','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BOUGHTPRODUCTHASAPPROVEDCONTRACTORDERS' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','BOUGHTPRODUCTHASAPPROVEDCONTRACTORDERS','Bought Product Has Approved Contract Orders','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BOUGHTPRODUCTHASAPPROVEDCONTRACTORDERS' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','BOUGHTTOTAL','已购总额','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BOUGHTTOTAL' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','BOUGHTTOTAL','Bought Total','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='BOUGHTTOTAL' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','THELATESTORDERDATE','最新订单日期','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='THELATESTORDERDATE' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','THELATESTORDERDATE','The Latest Order Date','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='THELATESTORDERDATE' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','TRANSACTIONHISTORY','交易历史','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='TRANSACTIONHISTORY' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','TRANSACTIONHISTORY','Transaction History','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='TRANSACTIONHISTORY' and languagetype='en');
delimiter;

drop trigger if exists update_product_sales_total; 
delimiter;

drop trigger if exists update_by_salesorder2; 
delimiter;

drop trigger if exists update_by_salesorder; 
delimiter;

drop trigger if exists update_by_salesorder1; 
delimiter || 
CREATE TRIGGER update_by_salesorder1 
BEFORE UPDATE ON ld_salesorder 
FOR EACH ROW 
BEGIN 

	set new.receivable_balance=round(ifnull(new.total,0)-ifnull(new.received_amount,0),2);

	set @cnt=0;
	set @cnt1=0;
	select count(1) into @cnt from ld_field where tabid=14 and columnname='sales_total';
	IF @cnt=1 THEN
		set @sales_total=0;
		update
			(select 
				a.salesorderid,
				b.productid,
				round(sum(b.tax_amount),2) as tax_amount
				from ld_salesorder a 
				LEFT JOIN ld_inventoryproductrel b on a.salesorderid=b.id
				where a.deleted=0 and a.sostatus<>'已作废' 
				GROUP BY b.productid) as t 
		LEFT JOIN ld_products c on c.productid=t.productid
		set c.sales_total=t.tax_amount
		where t.salesorderid=old.salesorderid;
	END IF;
		
END || 
delimiter;

drop trigger if exists update_by_servicecontracts1; 
delimiter || 
CREATE TRIGGER update_by_servicecontracts1 
BEFORE UPDATE ON ld_servicecontracts 
FOR EACH ROW 
BEGIN 

	set new.receivable_balance=round(ifnull(new.total,0)-ifnull(new.received_amount,0),2);
	
END || 
delimiter; 
-- 2015-12-03

set @tabid=15;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='category';
update ld_tranlabel set fieldlabel='问题类别' where languagetype='zh' and trantable='ld_field' and tabid=@tabid and Relateid=@fieldid and fieldlabel='类别';

set @tabid=15;
set @blockid=37;
set @tablename='ld_faq';
set @columnname='faqtype';
set @fieldname='faqtype';
set @zh='常见问题';
set @en='FAQ Type';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select sequence into @seq from ld_field where tabid=@tabid and block=@blockid and columnname='category';
update ld_field set sequence=sequence+10 where tabid=@tabid and block=@blockid and sequence>@seq;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;

call AddColumn(@tablename,@columnname,'varchar','100','');
delimiter;



CREATE TABLE IF NOT EXISTS `ld_faqtype` (
  `faqtypeid` int(19) NOT NULL AUTO_INCREMENT,
  `faqtype` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL DEFAULT '1',
  `picklist_valueid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`faqtypeid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_faqtype_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select id into @id from ld_picklistvalues_seq;


set @faqtype='软件安装';
insert into ld_faqtype(faqtype,presence,picklist_valueid)
select @faqtype,1,@id+1 from dual 
where not exists (select 1 from ld_faqtype where faqtype=@faqtype);

set @faqtype='其他';
insert into ld_faqtype(faqtype,presence,picklist_valueid)
select @faqtype,1,@id+2 from dual 
where not exists (select 1 from ld_faqtype where faqtype=@faqtype);


select ifnull(max(picklist_valueid),0) into @picklist_valueid from ld_faqtype;
update ld_picklistvalues_seq set id=@picklist_valueid where id<@picklist_valueid;
delimiter;

insert into ld_faqtype_seq(id)
select max(faqtypeid) from ld_faqtype;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_bankbranch` (
  `bankbranchid` int(11) NOT NULL,  
  `bankbranch_no` varchar(100) DEFAULT NULL, 
  `bankname` varchar(100) DEFAULT NULL,
  `bankbranchnumber` varchar(100) DEFAULT NULL,
  `smownerid` int(11) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT '0',
  `modifiedby` int(11) DEFAULT '0',
  `approveby` int(11) DEFAULT NULL,
  `approvestatus` VARCHAR(200) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  `description` text,  
  PRIMARY KEY (`bankbranchid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_bankbranchcf` (
  `bankbranchid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`bankbranchid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid) into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid + 1,'BankBranch',5,@tabsequence+1,'BankBranch',1,'Accounts',0 
from dual where not EXISTS(select 1 from ld_tab where `name`='BankBranch');
delimiter;

select parenttabid INTO @parenttabid from ld_parenttab where parenttab_label = 'Parent Accounts';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
select tabid into @tabid from ld_tab where `name` = 'BankBranch';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select parenttabid INTO @parenttabid from ld_parenttab where parenttab_label = 'Parent Accounts';
select tabid into @tabid from ld_tab where `name` = 'BankBranch';
select tabid into @tabid2 from ld_tab where `name` = 'ContactRecords';
update ld_parenttabrel set sequence=3 where tabid=@tabid and parenttabid=@parenttabid; 
update ld_parenttabrel set sequence=4 where tabid=@tabid2 and parenttabid=@parenttabid; 
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankBranch';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'银行网点' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_tab' and tabid = @tabid and Relateid=@tabid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'BankBranch' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_tab' and tabid = @tabid and Relateid=@tabid);
delimiter;

call fieldprofile('BankBranch');
delimiter;
call getallprofile('BankBranch');
delimiter;
call addtabintoprofile('BankBranch',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankBranch';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankBranch';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);
delimiter;

select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,0,0  from dual where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankBranch';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_BANKBRANCH_INFO',1 from dual where not exists (select 1 from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_BANKBRANCH_INFO');
delimiter;

insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_BANKBRANCH_REMARKS',2 from dual 
where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_BANKBRANCH_REMARKS');
delimiter;

update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'bankname','ld_bankbranch',2,'bankname','银行名称',(select blockid from ld_blocks where blocklabel = 'LBL_BANKBRANCH_INFO'),1,0,'V~M',2,1 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'bankname');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'bankbranch_no','ld_bankbranch',4,'bankbranch_no','单据编号',(select blockid from ld_blocks where blocklabel = 'LBL_BANKBRANCH_INFO'),1,0,'V~M',2,2 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'bankbranch_no');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'bankbranchnumber','ld_bankbranch',2,'bankbranchnumber','银行网点号',(select blockid from ld_blocks where blocklabel = 'LBL_BANKBRANCH_INFO'),1,0,'V~M',2,3 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'bankbranchnumber');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_bankbranch',53,'assigned_user_id','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_BANKBRANCH_INFO'),1,0,'V~M',1,4,1 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'smownerid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_bankbranch',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_BANKBRANCH_INFO'),2,0,'V~O',1,5 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'smcreatorid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_bankbranch',70,'createdtime','创建日期',(select blockid from ld_blocks where blocklabel = 'LBL_BANKBRANCH_INFO'),2,0,'DT~O',1,6 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'createdtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_bankbranch',52,'modifiedby','修改人',(select blockid from ld_blocks where blocklabel = 'LBL_BANKBRANCH_INFO'),2,0,'V~O',1,7 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedby');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_bankbranch',70,'modifiedtime','最新更新日期',(select blockid from ld_blocks where blocklabel = 'LBL_BANKBRANCH_INFO'),2,0,'DT~O',1,8 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'description','ld_bankbranch',19,'description','备注',(select blockid from ld_blocks where blocklabel = 'LBL_BANKBRANCH_REMARKS'),1,0,'V~O',1,1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'description');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankBranch';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_BANKBRANCH_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid ,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_BANKBRANCH_REMARKS' limit 1;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid ,'备注信息' from dual 
where not EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Description Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'bankname';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'银行名称' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Bank Name' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'bankbranch_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'单据编号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'BankBranch No' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'bankbranchnumber';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'银行网点号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'BankBranch Number' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'负责人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'assigned user' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'creator' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'修改人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新更新日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'备注' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'BankBranch','BANK',1,1,1,'none' 
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'BankBranch' 
and prefix ='BANK');
delimiter;

update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
select (select max(cvid)+1 from ld_customview),'All',1,0,'BankBranch',3,1,0,100,NULL 
from dual where not EXISTS(select 1 from ld_customview  where entitytype = 'BankBranch' and viewname ='All');
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'BankBranch' and viewname = 'All';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_bankbranch:bankbranch_no:bankbranch_no:BankBranch_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =0 and columnname = 'ld_bankbranch:bankbranch_no:bankbranch_no:BankBranch_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_bankbranch:bankname:bankname:BankBranch_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =1 and columnname = 'ld_bankbranch:bankname:bankname:BankBranch_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_bankbranch:bankbranchnumber:bankbranchnumber:BankBranch_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =2 and columnname = 'ld_bankbranch:bankbranchnumber:bankbranchnumber:BankBranch_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_bankbranch:smownerid:assigned_user_id:BankBranch_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =3 and columnname = 'ld_bankbranch:smownerid:assigned_user_id:BankBranch_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_bankbranch:smcreatorid:smcreatorid:BankBranch_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =4 and columnname = 'ld_bankbranch:smcreatorid:smcreatorid:BankBranch_fieldlabel:V');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankBranch';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'BankBranch','ld_bankbranch','bankname','bankbranchid','bankbranchid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid 
and modulename ='BankBranch');

select tabid into @tabid from ld_tab where `name` = 'BankBranch';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid 
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

update ld_tab set printtab = 1 where `name` = 'BankBranch';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankBranch';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid 
and visible =1);

SELECT tabid into @tabid from ld_tab  WHERE tablabel='BankBranch';
insert into ld_profileallpermission(tabid,operation)
select @tabid,1 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=1);
insert into ld_profileallpermission(tabid,operation)
select @tabid,2
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=2);
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,4
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=4);
insert into ld_profileallpermission(tabid,operation)
select @tabid,5
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=5);
insert into ld_profileallpermission(tabid,operation)
select @tabid,6
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=6);
insert into ld_profileallpermission(tabid,operation)
select @tabid,11
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=11);
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=12);
insert into ld_profileallpermission(tabid,operation)
select @tabid,13
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=13);
insert into ld_profileallpermission(tabid,operation)
select @tabid,14
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=14);
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=25);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='BankBranch';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,8,'get_attachments',0,'Documents',0,'ADD,SELECT',1,0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachments');
delimiter;
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,78,'get_attachment',1,'Attachment',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachment');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='BankBranch';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-1,2,0,'修改日志'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-1);
delimiter;
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,78,1,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=78);
delimiter;
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-5,5,0,'打印工具'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-5);
delimiter;
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,61,3,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=61);
delimiter;
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-10,4,0,'负责人变更记录'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-10);
delimiter;

select tabid into @tabid from ld_tab where `name`='BankBranch';
delete from ld_relatedlists where tabid=@tabid and label='Documents';
delimiter;


call AddColumn('ld_field','relate_search_parent_columnname','varchar','50','');
update ld_field set relate_search_parent_columnname='projectid' where fieldid=@fieldid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
update ld_field set displaytype = 2 where tabid = @tabid and columnname in('createdtime','modifiedtime','modifiedby','smcreatorid');
update ld_field set uitype = 19 where tabid = @tabid and columnname = 'remark';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseenterprofile','请输入要查找的角色','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'pleaseenterprofile' and languagetype='zh' and labeltype ='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseenterprofile','Please input the profile name','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'pleaseenterprofile' and languagetype='en' and labeltype ='jspop');
delimiter;

alter table ld_inventoryproductrel modify havepurchasecount decimal(25,8);
delimiter;
alter table ld_inventoryproductrel modify balancepurchasecount decimal(25,8);
delimiter;
alter table ld_inventoryproductrel modify haveoutproductcount decimal(25,8);
delimiter;
alter table ld_inventoryproductrel modify balanceoutproductcount decimal(25,8);
delimiter;
-- 2015-12-04
 
call AddColumn('ld_project','entitytype','varchar','25',NULL);
delimiter;

update ld_project set entitytype = 'SalesOrder' where salesorderid > 0 and entitytype is NULL;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTORECYLESEAACCOUNTS','公海客户到期未达成设定条件自动回收','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='AUTORECYLESEAACCOUNTS' and languagetype='zh');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTORECYLESEAACCOUNTS','Automatic recovery of the high Seas customers due to not reach the set conditions','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='AUTORECYLESEAACCOUNTS' and languagetype='en');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
update ld_field set quickcreate = 1 where columnname = 'salesorderid' and uitype = 202;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTATLEASTONEPROBLEM','请至少选择一个问题','jspop' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='PLEASESELECTATLEASTONEPROBLEM' and languagetype='zh' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTATLEASTONEPROBLEM','Please select at least one problem','jspop' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='PLEASESELECTATLEASTONEPROBLEM' and languagetype='en' and labeltype='jspop');
delimiter;


select tabid into @tabid from ld_tab where `name`='Expense';
update ld_field set quickcreate=3,quickcreatesequence=NULL where tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where `name`='Vendors';
update ld_field set uitype=11 where tabid=@tabid and columnname='phone';
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Parent Accounts';
select tabid into @tabid from ld_tab where `name`='BankBranch';

set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=@parenttabid order by sequence;

select IFNULL(sequence,2) into @seq from ld_parenttabrel where parenttabid=@parenttabid and tabid=4;
update ld_parenttabrel set sequence=sequence+5 where parenttabid=@parenttabid and sequence>@seq;
update ld_parenttabrel set sequence=@seq+1 where parenttabid=@parenttabid and tabid=@tabid;

set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=@parenttabid order by sequence;

update ld_field set quickcreate=0,quickcreatesequence=1 where tabid=@tabid and columnname='bankname';
update ld_field set quickcreate=0,quickcreatesequence=2 where tabid=@tabid and columnname='bankbranchnumber';
update ld_field set quickcreate=0,quickcreatesequence=3 where tabid=@tabid and columnname='smownerid';
delimiter;

set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) where tabsequence<10 order by tabsequence;

select tabid into @tabid from ld_tab where `name`='BankBranch';
select tabsequence into @seq from ld_tab where tabid=4;
update ld_tab set tabsequence=tabsequence+1 where tabsequence>@seq and tabsequence<10;
update ld_tab set tabsequence=@seq+1 where tabid=@tabid;

set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) where tabsequence<=10 order by tabsequence;
delimiter;

delete from ld_ws_fieldtype where uitype=79;
delimiter;
-- 2015-12-07

select tabid into @tabid from ld_tab where `name`='BankBranch';
update ld_field set searchfieldtype=1 where tabid=@tabid and columnname='bankbranch_no';
update ld_field set searchfieldtype=1 where tabid=@tabid and columnname='bankbranchnumber';
delimiter;

select tabid into @tabid from ld_tab where `name`='BankBranch';
update ld_field set searchfieldtype=1 where tabid=@tabid;
update ld_field set searchfieldtype=0 where tabid=@tabid and columnname in ('bankname','bankbranchnumber');
delimiter;

set @tabid=22;
set @columnname='accountid';
set @en='Customer Name';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where tabid=@tabid and languagetype='en' and trantable='ld_field' and Relateid=@fieldid;
delimiter;

 select max(fieldtypeid) into @fieldtypeid from ld_ws_fieldtype;
 insert into ld_ws_fieldtype (fieldtypeid,uitype,fieldtype) 
 select @fieldtypeid+1 ,600,'reference' from DUAL
 where not EXISTS(select 1 from ld_ws_fieldtype where uitype=600);
    
 select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=600;
 insert into ld_ws_referencetype (fieldtypeid,type) 
 select @fieldtypeid,'BankBranch' from dual
 where not EXISTS(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid);

CREATE TABLE if not exists `ld_relatedcreate_fieldinfo` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `from_module` varchar(200) DEFAULT NULL,
  `cur_module` varchar(200) DEFAULT NULL,
  `cur_columnname` varchar(200) DEFAULT NULL,
  `from_columnname` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
delimiter;  
  
insert into ld_relatedcreate_fieldinfo(from_module,cur_module,cur_columnname,from_columnname)
select 'ProjectTask','ProjectProgress','projecttaskid','projecttaskid' from dual 
where not EXISTS(select 1 from ld_relatedcreate_fieldinfo where from_module='projecttask' and cur_module='projectprogress' and  from_columnname='projecttaskid');
    
insert into ld_relatedcreate_fieldinfo(from_module,cur_module,cur_columnname,from_columnname)
select 'ProjectTask','ProjectProgress','projectid','projectid' from dual 
where not EXISTS(select 1 from ld_relatedcreate_fieldinfo where from_module='projecttask' and cur_module='projectprogress' and  from_columnname='projectid');
    
select tabid into @tabid from ld_tab  where name='bankbranch';
select fieldid into @fieldid from ld_field where columnname='modifiedtime'  and tabid=@tabid;
update ld_tranlabel set fieldlabel='最新更新时间' where Relateid=@fieldid and trantable='ld_field' and tabid=@tabid and languagetype='zh' and fieldlabel='最新更新日期';

select tabid into @tabid from ld_tab  where name='bankbranch';
select fieldid into @fieldid from ld_field where columnname='createdtime'  and tabid=@tabid;
update ld_tranlabel set fieldlabel='创建时间' where Relateid=@fieldid and trantable='ld_field' and tabid=@tabid and languagetype='zh'  and fieldlabel='创建日期';
delimiter;

select usereportid into @id from ld_usereport where name='SalesReport';
SELECT tabid into @tid from ld_tab where name='SalesOrder';
insert into ld_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','librarytrackreport','出库跟踪表',@tid,1,0,1,@id,12,10,100 
from dual where not exists(select usereportid from ld_usereport where name='librarytrackreport');
delimiter;

select usereportid into @id from ld_usereport where name='librarytrackreport';
insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_salesorder:duedate:duedate:SalesOrder_duedate:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=3);

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_salesorder:cf_1486:cf_1486:SalesOrder_cf_1486:I','',4  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=4);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','librarytrackreport','出库跟踪表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='librarytrackreport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','librarytrackreport','library track Report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='librarytrackreport' and Labeltype='fixedstr');


select usereportid into @id from ld_usereport where name='librarytrackreport';
insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:duedate:duedate:SalesOrder_duedate:D', 1, 1, 'ld_salesorder:duedate:duedate:SalesOrder_交付时间:D','ld_salesorder:duedate:duedate:SalesOrder_duedate:D'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesorder:duedate:duedate:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:cf_1486:cf_1486:SalesOrder_cf_1486:V', 2, 1,
 'ld_salesorder:cf_1486:cf_1486:SalesOrder_项目名称:V','ld_salesorder:cf_1486:cf_1486:SalesOrder_project name:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesorder:cf_1486:cf_1486:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V', 3, 1,
 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V','ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder no:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_users:last_name:last_name:Users_last_name:V', 4, 1,
 'ld_users:last_name:last_name:Users_项目经理:V','ld_users:last_name:last_name:Users_last name:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_users:last_name:last_name:Users_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_products:productsheet:productsheet:Products_productsheet:V', 5, 1,
 'ld_products:productsheet:productsheet:Products_备件型号:V','ld_products:productsheet:productsheet:Products_productsheet:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_products:productsheet:productsheet:Products_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_products:productname:productname:Products_productname:V', 6, 1,
 'ld_products:productname:productname:Products_备件名称:V','ld_products:productname:productname:Products_product name:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_products:productname:productname:Products_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_inventoryproductrel:quantity:quantity:OutboundOrder_quantity:N', 7, 1,
 'ld_inventoryproductrel:quantity:quantity:OutboundOrder_数量:N','ld_inventoryproductrel:quantity:quantity:OutboundOrder_quantitys:N'   
from dual where not exists(select 1 from ld_usereportcolumns 
where Usereportid=@id and realcolumns like 'ld_inventoryproductrel:quantity:quantity:OutboundOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_outboundorder:taxprice:taxprice:OutboundOrder_taxprice:N', 8, 1,
 'ld_outboundorder:taxprice:taxprice:OutboundOrder_单价:N','ld_outboundorder:taxprice:taxprice:OutboundOrder_taxprice:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_outboundorder:taxprice:taxprice:OutboundOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_outboundorder:comment:comment:OutboundOrder_comment:V', 9, 1,
 'ld_outboundorder:comment:comment:OutboundOrder_备件序列号:V','ld_outboundorder:comment:comment:OutboundOrder_comment:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_outboundorder:comment:comment:OutboundOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_outboundorder:name:name:OutboundOrder_name:V', 10, 1,
 'ld_outboundorder:name:name:OutboundOrder_出库仓:V','ld_outboundorder:name:name:OutboundOrder_name:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_outboundorder:name:name:OutboundOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:cf_1485:cf_1485:SalesOrder_cf_1485:V', 11, 1,
 'ld_salesorder:cf_1485:cf_1485:SalesOrder_交付用途:V','ld_salesorder:cf_1485:cf_1485:SalesOrder_name:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesorder:cf_1485:cf_1485:SalesOrder_%');

call AddColumn('ld_troubletickets','questionid','varchar',255,NULL);
delimiter;
SELECT tabid INTO @tabid from ld_tab WHERE `name` = 'HelpDesk';
update ld_field set fieldname = 'description' where tabid = @tabid and fieldname = '问题描述' and columnname = 'description';
UPDATE ld_field SET presence = 2 WHERE tabid =@tabid AND fieldname = 'product_id';
SELECT block,sequence INTO @block,@sequence from ld_field WHERE tabid =@tabid AND columnname ='productcategory';
UPDATE  ld_field SET sequence=@sequence+1 WHERE tabid =@tabid AND columnname ='product_id' AND block=@block;
delimiter;

SELECT tabid INTO @tabid from ld_tab WHERE `name` = 'HelpDesk';
SELECT sequence INTO @sequence from ld_field WHERE tabid =@tabid AND columnname = 'description';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'questionid','ld_troubletickets',79,'questionid','常见问题',(select blockid from ld_blocks where blocklabel = 'LBL_DESCRIPTION_INFORMATION' and tabid=@tabid),1,0,'V~M',@sequence-1
from dual where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'questionid');
delimiter;

SELECT tabid INTO @tabid from ld_tab WHERE `name` = 'HelpDesk';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'questionid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'常见问题' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Questionid' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

SELECT tabid INTO @tabid from ld_tab WHERE `name` ='HelpDesk';
SELECT MAX(relation_id) into @relation_id from ld_relatedlists;
SELECT MAX(mobile_sequence) INTO @mobile_sequence FROM ld_relatedlists WHERE tabid =@tabid;
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid =@tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,15,'get_commonproblem',@sequence+1,'Faq',0,'',1,@mobile_sequence+1
from dual where not EXISTS(select 1 from ld_relatedlists where tabid = @tabid and name ='get_commonproblem');
delimiter;

call getallprofile('HelpDesk');
delimiter;
call fieldprofile('HelpDesk');
delimiter;

update ld_customview set viewname ='All' where viewname = 'ALL' and entitytype = 'Rate';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Project';
update ld_field set quickcreate = 1 where tabid = @tabid and columnname = 'salesorderid' and fieldname = 'salesorder_id' and uitype = 202;
delimiter;
-- 2015-12-08

update ld_customview set sequence=0 where viewname='All';

select tabid into @tabid from ld_tab where name='BankBranch';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='bankbranch_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,1,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='bankname';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,2,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='bankbranchnumber';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,3,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,4,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,5,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid  and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
update ld_field set presence = 1,typeofdata = 'V~O' where tabid = @tabid and columnname = 'questionid' and uitype = 79;
update ld_relatedlists set presence = 1 where tabid = @tabid and label = 'Faq' and `name` = 'get_commonproblem';
delimiter;
-- 2015-12-09

select tabid into @tabid from ld_tab where `name` = 'Project';
update ld_field set quickcreate = 3 where tabid = @tabid and columnname = 'salesorderid' and uitype = 202;
delimiter;
-- 2015-12-10

select tabid into @tabid from ld_tab where `name` = 'Rate';
update ld_field set columnname = 'strrole_id',fieldname = 'strrole_id',fieldlabel='适用范围' where tabid = @tabid and uitype = 111 and columnname = 'strrole_id';
delete from ld_field where tabid = @tabid and columnname = 'struser_id';
update ld_field set issmownerid = 1 where tabid = @tabid and columnname = 'smownerid' and fieldname = 'assigned_user_id';
delimiter;
call AddColumn('ld_rate','selecttype','varchar','255',NULL);
call AddColumn('ld_rate','selectvalue','varchar','255',NULL);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Rate';
insert into ld_profileallpermission(tabid,operation)
select @tabid,4 from DUAL
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 4);
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','THISDATENOEDNDATE','起始日期不能大于截止日期！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'THISDATENOEDNDATE' and languagetype = 'zh' and Labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','THISDATENOEDNDATE','起始日期不能大于截止日期！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'THISDATENOEDNDATE' and languagetype = 'en' and Labeltype = 'jspop');
delimiter;
-- 2015-12-14

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
delimiter;

update ld_version set old_version='V6.1.9' ,current_version='V6.1.9' ,remark='V6.1.9-20151214';
delimiter;