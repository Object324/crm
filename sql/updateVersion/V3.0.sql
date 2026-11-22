drop procedure  if exists `AddColumn`;
delimiter ||
create procedure   AddColumn
(
-- tableschema varchar(50),
tablename varchar(50),
columnname varchar(50),
columntype varchar(50),
columnlen int(5),
isdefault int(2)
)
begin

select database() into @tableschema;

set tablename=lower(tablename);

SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and 

table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');

prepare stmt from @tsql;
execute stmt;
set @coladd=IFNULL(@colName,'-1');

IF @coladd = '-1'  or @coladd<>columnname THEN
 	if columntype='date'  or columntype='datetime' then 
		set @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
	elseif isdefault=0 then
		set @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default 0 ');
	else 

		 set @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')');
	end if;
prepare stalter from @altercolumn;
execute stalter;

END IF;

end ||
delimiter;

drop procedure  if exists `ChangeColumn`;
delimiter ||
create procedure ChangeColumn
(
-- tableschema varchar(50),
tablename varchar(50),
columnname varchar(50),
newname varchar(50),
columntype varchar(50),
columnlen int(5)
)
begin
select database() into @tableschema;
set tablename=lower(tablename);

SET @tsql=CONCAT('select count(*) into @colchange from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and 

table_name= ','''',tablename,'''',' and column_name=','''',columnname,'''');

prepare stmt from @tsql;
execute stmt;
-- set @colchange=IFNULL(@column_name,'-1');

IF @colchange=1  THEN
 	if columntype='date'  or columntype='datetime' then 
		set @alterColumn=CONCAT('alter table ',tablename, ' change ',columnname, ' ', newname, ' ', columntype, ' ');
	else 
		set @alterColumn=CONCAT('alter table ',tablename, ' change ',columnname, ' ', newname, ' ', columntype, '(',columnlen,')');
	end if;
prepare stalter from @altercolumn;
execute stalter;

END IF;
end ||
delimiter;

drop procedure if exists `getallprofile`;
delimiter ||
create procedure getallprofile
(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;


declare cur2 CURSOR FOR SELECT profileid   FROM  LD_profile;

declare continue handler  for not   found  SET done =1;


	open cur2;
	fetch cur2 into pprofileid;
	loop2: while  done<>1 DO
		
		call fieldintoprofile(pprofileid,tabname);
		fetch cur2 into pprofileid;
	end while loop2;
	close cur2;
end ||
delimiter;

drop procedure if exists `fieldintoprofile`;
delimiter ||
create procedure fieldintoprofile
(
profileid int(19),
 tabname varchar(50)
)
begin
declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  LD_field where tabid in(select tabid from lD_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into LD_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from LD_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');
	
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

update ld_field set presence = 0 where tablename= 'ld_products' and columnname = 'costprice';
delimiter;

select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  
where not exists(select 1 from ld_field where tablename='ld_products' and fieldname='costprice');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select 14,@id+1,'costprice','LD_products',1,1,'costprice','Costprice',1,0,'',100,2,32,1,'N~O',1,'','BAS',1,'',0 from dual 
where not exists (select 1 from ld_field where tablename='ld_products' and fieldname='costprice');
delimiter;         
call fieldprofile('products');
delimiter;

call addcolumn('ld_version','versiontype','char','10','1');
update ld_version set versiontype='10';
delimiter;

update ld_tab set presence=0 where name='Faq';
update ld_tab set presence=0 where name='ServiceContracts';
update ld_tab set presence=0 where name='Vendors';
update ld_tab set presence=0 where name='PurchaseOrder';
update ld_tab set presence=0 where name='Project';
update ld_tab set presence=0 where name='ProjectTask';
update ld_tab set presence=0 where name='ProjectMilestone';
update ld_tab set presence=0 where name='Service';
insert into lD_parenttabrel(parenttabid,tabid,sequence) 
select 1,15,6  from dual where not exists(select 1 from lD_parenttabrel  where parenttabid=1 and tabid=15);
insert into lD_parenttabrel(parenttabid,tabid,sequence) select 3,37,5  from dual where not exists(select 1 from lD_parenttabrel  where parenttabid=3 and tabid=37);
delimiter;

select max(parenttabid) into @id from LD_parenttab;
update LD_parenttab set sequence=sequence+1 where sequence>5 and sequence<11;
insert into LD_parenttab(parenttabid,parenttab_label,sequence,visible) select @id+1,'Project',6,0  from dual where not exists(select 1 from lD_parenttab where parenttab_label='project');
delimiter;

select parenttabid  into @parenttabid from LD_parenttab where parenttab_label='Project';

insert into lD_parenttabrel(parenttabid,tabid,sequence) select @parenttabid,46,3  from dual where not exists(select 1 from lD_parenttabrel  where parenttabid=@parenttabid  and tabid=46);
insert into lD_parenttabrel(parenttabid,tabid,sequence) select @parenttabid,47,2  from dual where not exists(select 1 from lD_parenttabrel  where parenttabid=@parenttabid  and tabid=47);
insert into lD_parenttabrel(parenttabid,tabid,sequence) select @parenttabid,48,1  from dual where not exists(select 1 from lD_parenttabrel  where parenttabid=@parenttabid  and tabid=48);
delimiter;


select max(parenttabid) into @id from LD_parenttab;
update LD_parenttab set sequence=sequence+1 where sequence>6 and sequence<13;
insert into LD_parenttab(parenttabid,parenttab_label,sequence,visible) select @id+1,'Purchase',7,0  from dual where not exists(select 1 from lD_parenttab where parenttab_label='Purchase');
delimiter;

select parenttabid  into @parenttabid from LD_parenttab where parenttab_label='Purchase';
insert into lD_parenttabrel(parenttabid,tabid,sequence) select @parenttabid,18,1  from dual where not exists(select 1 from lD_parenttabrel  where parenttabid=@parenttabid  and tabid=18);
insert into lD_parenttabrel(parenttabid,tabid,sequence) select @parenttabid,21,2  from dual where not exists(select 1 from lD_parenttabrel  where parenttabid=@parenttabid  and tabid=21);
delimiter;

insert into lD_parenttabrel(parenttabid,tabid,sequence) select 6,38,4  from dual where not exists(select 1 from lD_parenttabrel  where parenttabid=6 and tabid=38);
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='Faq');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'Faq',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='Faq');
delimiter;

select cvid into @cvid from ld_customview where entitytype='Faq' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_faq:faq_no:faq_no:Faq_Faq_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_faq:question:question:Faq_Question:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_faq:category:faqcategories:Faq_Category:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_faq:status:faqstatus:Faq_Status:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_faq:product_id:product_id:Faq_Product_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_faq:answer:faq_answer:faq_answer:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5); 
delimiter;

select tabid into @tabid from ld_tab where name='ProjectMilestone';
update ld_field set fieldlabel='项目名称' where tabid=@tabid and columnname='projectid';
delimiter;

select cvid into @cvid from ld_customview  where entitytype='ProjectMilestone' and viewname='ALL';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_projectmilestone:projectmilestone_no:projectmilestone_no:ProjectMilestone_Project_Milestone_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_projectmilestone:projectmilestonename:projectmilestonename:ProjectMilestone_Project_Milestone_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_projectmilestone:projectmilestonetype:projectmilestonetype:ProjectMilestone_Type:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_projectmilestone:projectid:projectid:ProjectMilestone_项目名称:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_projectmilestone:projectmilestonedate:projectmilestonedate:ProjectMilestone_里程碑日期:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_crmentity:description:description:ProjectMilestone_description:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:ProjectMilestone_Assigned_To:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6); 
delimiter;

update ld_tab set isentitytype=1 where name='Faq';
update ld_tab set isentitytype=1 where name='ServiceContracts';
update ld_tab set isentitytype=1 where name='Vendors';
update ld_tab set isentitytype=1 where name='PurchaseOrder';
update ld_tab set isentitytype=1 where name='Project';
update ld_tab set isentitytype=1 where name='ProjectTask';
update ld_tab set isentitytype=1 where name='ProjectMilestone';
update ld_tab set isentitytype=1 where name='Service';

update LD_links set linkicon='themes/images/pointer.gif' where tabid=47;


update LD_faqcategories set faqcategories='一般 '  where   faqcategories='General ' ;
update LD_Faq set category='一般' where category='General';

update lD_faqstatus set faqstatus='草案' where faqstatus='draft';
update lD_faqstatus set faqstatus='过期' where faqstatus='Reviewed';
update lD_faqstatus set faqstatus='已发布' where faqstatus='Published';
update lD_faqstatus set faqstatus='已审批' where faqstatus='Obsolete';
update lD_faq  set status='草案' where status='draft';
update lD_faq  set status='过期' where status='Reviewed';
update lD_faq set status='已发布' where status='Published';
update lD_faq  set status='已审批' where status='Obsolete';


update  lD_contract_status set  contract_status='未定义' where contract_status='Undefined';
update  lD_contract_status set  contract_status='计划中' where contract_status='In Planning';
update  lD_contract_status set  contract_status='进行中' where contract_status='In Progress';
update  lD_contract_status set  contract_status='搁置' where contract_status='On Hold';
update  lD_contract_status set  contract_status='已完成' where contract_status='Complete';
update  lD_contract_status set  contract_status='已归档' where contract_status='Archived';

update  lD_ServiceContracts set  contract_status='未定义' where contract_status='Undefined';
update  lD_ServiceContracts set  contract_status='计划中' where contract_status='In Planning';
update  lD_ServiceContracts set  contract_status='进行中' where contract_status='In Progress';
update  lD_ServiceContracts set  contract_status='搁置' where contract_status='On Hold';
update  lD_ServiceContracts set  contract_status='已完成' where contract_status='Complete';
update  lD_ServiceContracts set  contract_status='已归档' where contract_status='Archived';


update  lD_ServiceContracts set  priority='低' where priority='low';
update  lD_ServiceContracts set  priority='一般' where priority='normal';
update  lD_ServiceContracts set  priority='高' where priority='high';
update  lD_contract_priority set  contract_priority='低' where contract_priority='low';
update  lD_contract_priority set  contract_priority='一般' where contract_priority='normal';
update  lD_contract_priority set  contract_priority='高' where contract_priority='high';

update  lD_contract_type set  contract_type='支持' where contract_type='Support';
update  lD_contract_type set  contract_type='服务' where contract_type='Services';
update  lD_contract_type set  contract_type='管理' where contract_type='Administrative';
update  lD_ServiceContracts set  contract_type='支持' where contract_type='Support';
update  lD_ServiceContracts set  contract_type='服务' where contract_type='Services';
update  lD_ServiceContracts set  contract_type='管理' where contract_type='Administrative';

call getallprofile('Services');
call getallprofile('ServiceContracts');
call getallprofile('Vendors');
delimiter;

update ld_project set project_no=CONCAT('PROJ',projectid) where project_no='';
update ld_projecttask set projecttask_no=CONCAT('PROT',projecttaskid) where projecttask_no='';
update ld_projectmilestone set projectmilestone_no=CONCAT('PROM',projectmilestoneid) where projectmilestone_no='';

select max(num_id) into @id from ld_modentity_num;
select max(projectid) into @cur_id from ld_project;
update ld_modentity_num_seq set id=@id+1 where not exists (select 1 from ld_modentity_num where semodule='Project');
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active)
select @id+1,'Project','PROJ',1,@cur_id+1,1 from dual
where not exists(select 1 from ld_modentity_num where semodule='Project');
delimiter;

select max(num_id) into @id from ld_modentity_num;
select max(projectmilestoneid) into @cur_id from ld_projectmilestone;
update ld_modentity_num_seq set id=@id+1 where not exists (select 1 from ld_modentity_num where semodule='ProjectMilestone');
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active)
select @id+1,'ProjectMilestone','PROM',1,@cur_id+1,1 from dual
where not exists(select 1 from ld_modentity_num where semodule='ProjectMilestone');
delimiter;

select max(num_id) into @id from ld_modentity_num;
select max(projecttaskid) into @cur_id from ld_projecttask;
update ld_modentity_num_seq set id=@id+1 where not exists (select 1 from ld_modentity_num where semodule='ld_projecttask');
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active)
select @id+1,'ProjectTask','PROT',1,@cur_id+1,1 from dual
where not exists(select 1 from ld_modentity_num where semodule='ld_projecttask');
delimiter;

select max(vendorid) into @cur_id from ld_vendor;
update ld_modentity_num set cur_id=@cur_id+1 where semodule='Vendors';
delimiter;

select max(purchaseorderid) into @cur_id from ld_purchaseorder;
update ld_modentity_num set cur_id=@cur_id+1 where semodule='PurchaseOrder';
delimiter;

update ld_modentity_num set cur_id=1 where cur_id='';
update ld_postatus set postatus='已创建' where postatus='Created';
update ld_postatus set postatus='已审批' where postatus='Approved';
update ld_postatus set postatus='已发货' where postatus='Delivered';
update ld_postatus set postatus='已作废' where postatus='Cancelled';
update ld_postatus set postatus='已到货' where postatus='Received Shipment';
update ld_purchaseorder set postatus='已创建' where postatus='Created';
update ld_purchaseorder set postatus='已审批' where postatus='Approved';
update ld_purchaseorder set postatus='已发货' where postatus='Delivered';
update ld_purchaseorder set postatus='已作废' where postatus='Cancelled';
update ld_purchaseorder set postatus='已到货' where postatus='Received Shipment';

select cvid into @cvid from ld_customview where entitytype='purchaseorder' and viewname='Open Purchase Orders';
update ld_customview set viewname='未审批' where cvid=@cvid;
update ld_cvadvfilter set comparator='n',`value`='已审批' where cvid=@cvid and columnindex=0;
delimiter;

select cvid into @cvid from ld_customview where entitytype='purchaseorder' and viewname='Received Purchase Orders';
update ld_customview set viewname='已审批' where cvid=@cvid;
update ld_cvadvfilter set comparator='e',`value`='已审批' where cvid=@cvid and columnindex=0;
delimiter;

select cvid into @cvid from ld_customview where entitytype='purchaseorder' and viewname='订单状态';
update ld_customview set viewname='已作废' where cvid=@cvid;
update ld_cvadvfilter set comparator='e',`value`='已作废' where cvid=@cvid and columnindex=0;
delimiter;

select tabid into @tabid from ld_tab where name='Vendors';
update ld_field set fieldlabel='网址' where tabid=@tabid and columnname='website';
update ld_field set fieldlabel='行业' where tabid=@tabid and columnname='glacct';
update ld_field set columnname='bill_country',uitype=1023,fieldname='bill_country',sequence=1,defaultvalue='中国' where tabid=@tabid and columnname='country';
update ld_field set columnname='bill_state',uitype=1022,fieldname='bill_state',sequence=2,defaultvalue='上海' where tabid=@tabid and columnname='state';
update ld_field set columnname='bill_city',uitype=1021,fieldname='bill_city',sequence=3 where tabid=@tabid and columnname='city';
update ld_field set sequence=4 where tabid=@tabid and columnname='postalcode';
update ld_field set sequence=5 where tabid=@tabid and columnname='street';
update ld_field set sequence=6 where tabid=@tabid and columnname='pobox';
delimiter;

call changecolumn('ld_vendor','country','bill_country','varchar',100);
call changecolumn('ld_vendor','state','bill_state','varchar',100);
call changecolumn('ld_vendor','city','bill_city','varchar',100);
delimiter;

update LD_version set versiontype='10' where versiontype is null;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=37 );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 37,@maxfieldid+1,'accountid','LD_servicecontracts',1,73,'account_id','Account Name',1,0,'',100,3,91,1,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=37 ) ;
delimiter;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='contactid'  and tabid=37 );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 37,@maxfieldid+1,'contactid','LD_servicecontracts',1,57,'contact_id','联系人姓名',1,0,'',100,4,91,1,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='contactid'  and tabid=37 ) ;
delimiter;

call addcolumn('ld_servicecontracts','accountid','int','19','');
call addcolumn('ld_servicecontracts','contactid','int','19','');
delimiter;

update LD_servicecontracts inner join LD_account   on LD_servicecontracts.sc_related_to=ld_account.accountid  set LD_servicecontracts.accountid=ld_account.accountid   
where LD_servicecontracts.sc_related_to=ld_account.accountid;

update LD_servicecontracts inner join LD_contactdetails   on LD_servicecontracts.sc_related_to=LD_contactdetails.contactid  set LD_servicecontracts.contactid=LD_contactdetails.contactid
where LD_servicecontracts.sc_related_to=LD_contactdetails.contactid;

delete from lD_field where tabid=37 and columnname='sc_related_to';
update  lD_tracking_unit set  tracking_unit='无' where tracking_unit='None';
update  lD_tracking_unit set  tracking_unit='小时' where tracking_unit='Hours';
update  lD_tracking_unit set  tracking_unit='天' where tracking_unit='Days';
update  lD_tracking_unit set  tracking_unit='事件' where tracking_unit='Incidents';
update  lD_ServiceContracts set  tracking_unit='无' where tracking_unit='None';
update  lD_ServiceContracts set tracking_unit='小时' where tracking_unit='Hours';
update  lD_ServiceContracts set  tracking_unit='天' where tracking_unit='Days';
update  lD_ServiceContracts set  tracking_unit='事件' where tracking_unit='Incidents';
delimiter;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=48 );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 48,@maxfieldid+1,'accountid','LD_project',1,73,'account_id','Account Name',1,0,'',100,9,109,1,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=48 ) ;
delimiter;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='contactid'  and tabid=48 );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 48,@maxfieldid+1,'contactid','LD_project',1,57,'contact_id','联系人姓名',1,0,'',100,10,109,1,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='contactid'  and tabid=48 ) ;
delimiter;

call addcolumn('LD_project','accountid','int','19','');

call addcolumn('LD_project','contactid','int','19','');

update LD_project inner join LD_account   on LD_project.linktoaccountscontacts=ld_account.accountid  set LD_project.accountid=ld_account.accountid   
where LD_project.linktoaccountscontacts=ld_account.accountid;

update LD_project inner join LD_contactdetails   on LD_project.linktoaccountscontacts=LD_contactdetails.contactid  set LD_project.contactid=LD_contactdetails.contactid
where LD_project.linktoaccountscontacts=LD_contactdetails.contactid ;

delete from lD_field where tabid=48 and columnname='linktoaccountscontacts';
delimiter;

select tabid into @tabid from ld_tab where name='Reports';
select max(tabid) into @maxid from ld_tab;
select tabsequence into @tabseq from ld_tab where tabid=@tabid;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,modifiedby,modifiedtime,customized,ownedby,isentitytype,version,parent,printtab) 
select  @maxid+1 ,'Comprehensivereport' ,0,@tabseq+1,'Comprehensivereport','','',0,1,0,'','Analytics',0  from dual 
where not exists(select 1 from LD_tab where name='Comprehensivereport');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Parent Reports';
select tabid into @tabid from ld_tab where name='Comprehensivereport';
select max(sequence) into @seq from ld_parenttabrel where parenttabid=@parenttabid;
insert into LD_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@seq from dual where not exists(select 1 from LD_parenttabrel where parenttabid=@parenttabid and tabid=@tabid );
delimiter;

update ld_tab set  presence = 0 where name = 'Comprehensivereport';
delimiter;

update ld_parenttab set sequence=1 where parenttab_label='My Home Page';
update ld_parenttab set sequence=2 where parenttab_label='Marketing';
update ld_parenttab set sequence=3 where parenttab_label='Parent Accounts';
update ld_parenttab set sequence=4 where parenttab_label='Sales';
update ld_parenttab set sequence=5 where parenttab_label='Purchase';
update ld_parenttab set sequence=6 where parenttab_label='Project';
update ld_parenttab set sequence=7 where parenttab_label='Finacial';
update ld_parenttab set sequence=8 where parenttab_label='Parent Reports';
update ld_parenttab set sequence=9 where parenttab_label='Tools';
update ld_parenttab set sequence=10 where parenttab_label='Inventroy';
update ld_parenttab set sequence=11 where parenttab_label='Settings';

select tabsequence into @tabseq from ld_tab where name='Reports';
update ld_tab set tabsequence=@tabseq+1 where name='Comprehensivereport';
delimiter;

update LD_entityname set fieldname='user_name' where modulename='Users';
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseOrder';
select sequence into @seq from ld_field where tabid=@tabid and columnname='vendorid';
update ld_field set presence=2 where tabid=@tabid and columnname='contactid';
update ld_field set presence=1 where tabid=@tabid and columnname='carrier';
update ld_field set presence=1 where tabid=@tabid and columnname='salescommission';
update ld_field set presence=1 where tabid=@tabid and columnname='exciseduty';
update ld_field set presence=1 where tabid=@tabid and columnname='tracking_no';

update ld_field set sequence=@seq+1 where tabid=@tabid and columnname='contactid';
update ld_field set sequence=@seq+2 where tabid=@tabid and columnname='postatus';
update ld_field set sequence=@seq+3 where tabid=@tabid and columnname='duedate';
update ld_field set sequence=@seq+3 where tabid=@tabid and columnname='smownerid';

update ld_field set presence=1 where tabid=@tabid and columnname='bill_country';
update ld_field set presence=1 where tabid=@tabid and columnname='ship_country';
update ld_field set presence=1 where tabid=@tabid and columnname='bill_pobox';
update ld_field set presence=1 where tabid=@tabid and columnname='ship_pobox';
update ld_field set presence=1 where tabid=@tabid and columnname='bill_state';
update ld_field set presence=1 where tabid=@tabid and columnname='ship_state';
update ld_field set presence=1 where tabid=@tabid and columnname='bill_city';
update ld_field set presence=1 where tabid=@tabid and columnname='ship_city';
update ld_field set presence=1 where tabid=@tabid and columnname='bill_street';
update ld_field set presence=1 where tabid=@tabid and columnname='ship_street';
update ld_field set presence=1 where tabid=@tabid and columnname='bill_code';
update ld_field set presence=1 where tabid=@tabid and columnname='ship_code';
update ld_field set presence=1 where tabid=@tabid and columnname='description';
delimiter;

call addcolumn('LD_vendor','fax','varchar','30',NULL);
delimiter;

select tabid into @tabid from ld_tab where name='Vendors';
select id into @fieldid from ld_field_seq;
select block into @block from ld_field where tabid=@tabid and columnname='vendorname';
update ld_field_seq set id=@fieldid+1 where not exists (select 1 from ld_field where tabid=@tabid and fieldname='fax');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,'fax','LD_vendor','1','11','fax','传真','1','2','100','2',@block,'1','V~O','1',Null,'BAS','2',Null,'0' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and fieldname='fax');

select fieldid into @fieldid from ld_field where fieldname='fax' and tabid=@tabid;
insert into LD_def_org_field(tabid,fieldid,visible,readonly)
select @tabid,@fieldid,0,0 from dual
where not exists(select 1 from LD_def_org_field where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='Vendors';
update ld_field set sequence=1 where tabid=@tabid and columnname='vendorname';
update ld_field set sequence=2 where tabid=@tabid and columnname='vendor_no';
update ld_field set sequence=3 where tabid=@tabid and columnname='phone';
update ld_field set sequence=4 where tabid=@tabid and columnname='fax';
update ld_field set sequence=5 where tabid=@tabid and columnname='website';
update ld_field set sequence=6 where tabid=@tabid and columnname='email';
update ld_field set sequence=7,fieldlabel='所属行业' where tabid=@tabid and columnname='glacct';
update ld_field set fieldlabel='邮编' where tabid=@tabid and columnname='postalcode';
update ld_field set fieldlabel='地址' where tabid=@tabid and columnname='street';
delimiter;

select tabid into @tabid from ld_tab where name='Vendors';
update ld_relatedlists set sequence=1 where tabid=@tabid and name='get_contacts';
update ld_relatedlists set sequence=2 where tabid=@tabid and name='get_products';
update ld_relatedlists set sequence=3 where tabid=@tabid and name='get_purchase_orders';
update ld_relatedlists set sequence=4 where tabid=@tabid and name='get_emails';
delimiter;

select tabid into @tabid from ld_tab where name='Project';
update ld_field set sequence=3 where tabid=@tabid and columnname='accountid';
update ld_field set sequence=4 where tabid=@tabid and columnname='contactid';
update ld_field set sequence=5 where tabid=@tabid and columnname='projecttype';
update ld_field set sequence=6,fieldlabel='状态',defaultvalue='准备中' where tabid=@tabid and columnname='projectstatus';
update ld_field set sequence=7 where tabid=@tabid and columnname='startdate';
update ld_field set sequence=8 where tabid=@tabid and columnname='targetenddate';
update ld_field set sequence=9 where tabid=@tabid and columnname='actualenddate';
update ld_field set sequence=10 where tabid=@tabid and columnname='smownerid';

select sequence into @seq from ld_field where tabid=@tabid and columnname='projecturl';
update ld_field set fieldlabel='完成进度',sequence=@seq+1,defaultvalue='10%' where tabid=@tabid and columnname='progress';
update ld_field set sequence=@seq+2,defaultvalue='一般' where tabid=@tabid and columnname='projectpriority';
delimiter;

select tabid into @tabid from ld_tab where name='ProjectTask';
select sequence into @seq from ld_field where tabid=@tabid and columnname='projecttask_no';
update ld_field set fieldlabel='项目名称',sequence=@seq+1 where tabid=@tabid and columnname='projectid';
update ld_field set sequence=@seq+2 where tabid=@tabid and columnname='projecttasknumber';
update ld_field set sequence=@seq+3 where tabid=@tabid and columnname='projecttasktype';
update ld_field set sequence=@seq+4 where tabid=@tabid and columnname='projecttaskpriority';
update ld_field set sequence=@seq+5 where tabid=@tabid and columnname='smownerid';

update ld_field set sequence=1 where tabid=@tabid and columnname='startdate';
update ld_field set sequence=2 where tabid=@tabid and columnname='enddate';
update ld_field set sequence=3,fieldlabel='任务进度',defaultvalue='10%' where tabid=@tabid and columnname='projecttaskprogress';
update ld_field set sequence=4,fieldlabel='工作时长' where tabid=@tabid and columnname='projecttaskhours';
delimiter;

select tabid into @tabid from ld_tab where name='ServiceContracts';
update ld_field set fieldlabel='服务合同编号' where tabid=@tabid and columnname='contract_no';
update ld_field set fieldlabel='主题' where tabid=@tabid and columnname='subject';
update ld_field set sequence=3 where tabid=@tabid and columnname='accountid';
update ld_field set sequence=4 where tabid=@tabid and columnname='contactid';
update ld_field set sequence=5,fieldlabel='类型' where tabid=@tabid and columnname='contract_type';
update ld_field set sequence=6,fieldlabel='状态',defaultvalue='进行中' where tabid=@tabid and columnname='contract_status';
update ld_field set sequence=7 where tabid=@tabid and columnname='start_date';
update ld_field set sequence=8 where tabid=@tabid and columnname='end_date';
update ld_field set sequence=13,fieldlabel='服务次数' where tabid=@tabid and columnname='total_units';
update ld_field set sequence=14,presence=1 where tabid=@tabid and columnname='used_units';
update ld_field set sequence=15,presence=1 where tabid=@tabid and columnname='tracking_unit';
update ld_field set sequence=16,presence=1 where tabid=@tabid and columnname='priority';
update ld_field set sequence=17 where tabid=@tabid and columnname='smownerid';
delimiter;

update ld_faqcategories set faqcategories='常见问题';
update ld_faq set category='常见问题' where category='一般';

select ifnull(max(faqcategories_id),0) into @faqcategories_id from ld_faqcategories; 
select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_faqcategories where faqcategories='销售语言');
insert into ld_faqcategories(faqcategories_id,faqcategories,presence,picklist_valueid)
select @faqcategories_id+1,'销售语言',1,@id+1 from dual 
where not exists(select 1 from ld_faqcategories where faqcategories='销售语言');
delimiter;

select ifnull(max(faqcategories_id),0) into @faqcategories_id from ld_faqcategories; 
select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_faqcategories where faqcategories='服务礼仪');
insert into ld_faqcategories(faqcategories_id,faqcategories,presence,picklist_valueid)
select @faqcategories_id+1,'服务礼仪',1,@id+1 from dual 
where not exists(select 1 from ld_faqcategories where faqcategories='服务礼仪');
delimiter;


select cvid into @cvid from ld_customview where entitytype='FAQ' and viewname='ALL';
select max(columnindex) into @columnindex from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,@columnindex+1,'LD_crmentity:createdtime:createdtime:Faq_Created_Time:DT' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like 'LD_crmentity:createdtime:createdtime%');
delimiter;


select cvid into @cvid from ld_customview where entitytype='ServiceContracts' and viewname='ALL';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_servicecontracts:contract_no:contract_no:ServiceContracts_服务合同编号:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_servicecontracts:subject:subject:ServiceContracts_主题:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_servicecontracts:accountid:account_id:ServiceContracts_Account_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_servicecontracts:contract_type:contract_type:ServiceContracts_类型:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_servicecontracts:contract_status:contract_status:ServiceContracts_状态:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_servicecontracts:start_date:start_date:ServiceContracts_Start_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_servicecontracts:due_date:due_date:ServiceContracts_Due_date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_servicecontracts:total_units:total_units:ServiceContracts_服务次数:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:smownerid:assigned_user_id:ServiceContracts_Assigned_To:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;

select cvid into @cvid from ld_customview where entitytype='Vendors' and viewname='ALL';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_vendor:vendor_no:vendor_no:Vendors_Vendor_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_vendor:vendorname:vendorname:Vendors_Vendor_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_vendor:phone:phone:Vendors_Phone:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_vendor:fax:fax:Vendors_传真:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_vendor:website:website:Vendors_网址:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_vendor:email:email:Vendors_Email:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_vendor:glacct:glacct:Vendors_所属行业:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smcreatorid:creator:Vendors_Creator:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);
delimiter;


select cvid into @cvid from ld_customview where entitytype='PurchaseOrder' and viewname='ALL';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_purchaseorder:postatus:postatus:PurchaseOrder_Status:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_purchaseorder:duedate:duedate:PurchaseOrder_Due_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_负责人:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:createdtime:createdtime:PurchaseOrder_Created_Time:DT' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);
delimiter;


select cvid into @cvid from ld_customview where entitytype='PurchaseOrder' and viewname='未审批';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_purchaseorder:postatus:postatus:PurchaseOrder_Status:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_purchaseorder:duedate:duedate:PurchaseOrder_Due_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_负责人:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:createdtime:createdtime:PurchaseOrder_Created_Time:DT' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);
delimiter;

select cvid into @cvid from ld_customview where entitytype='PurchaseOrder' and viewname='已审批';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_purchaseorder:postatus:postatus:PurchaseOrder_Status:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_purchaseorder:duedate:duedate:PurchaseOrder_Due_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_负责人:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:createdtime:createdtime:PurchaseOrder_Created_Time:DT' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);
delimiter;

select cvid into @cvid from ld_customview where entitytype='PurchaseOrder' and viewname='已作废';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_purchaseorder:postatus:postatus:PurchaseOrder_Status:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_purchaseorder:duedate:duedate:PurchaseOrder_Due_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_负责人:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:createdtime:createdtime:PurchaseOrder_Created_Time:DT' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);
delimiter;

select cvid into @cvid from ld_customview where entitytype='Project' and viewname='ALL';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_project:project_no:project_no:Project_Project_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_project:projectname:projectname:Project_Project_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_project:accountid:account_id:Project_Account_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_project:projecttype:projecttype:Project_类型:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_project:projectstatus:projectstatus:Project_状态:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_project:startdate:startdate:Project_Start_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_project:targetenddate:targetenddate:Project_Target_End_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_project:progress:progress:Project_完成进度:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:smownerid:assigned_user_id:Project_Assigned_To:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;

select cvid into @cvid from ld_customview where entitytype='ProjectTask' and viewname='ALL';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_projecttask:projecttask_no:projecttask_no:ProjectTask_Project_Task_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_projecttask:projecttaskname:projecttaskname:ProjectTask_Project_Task_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_projecttask:projectid:projectid:ProjectTask_项目名称:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_projecttask:projecttasktype:projecttasktype:ProjectTask_Type:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_projecttask:projecttaskpriority:projecttaskpriority:ProjectTask_Priority:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_projecttask:startdate:startdate:ProjectTask_Start_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_projecttask:enddate:enddate:ProjectTask_End_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_projecttask:projecttaskprogress:projecttaskprogress:ProjectTask_任务进度:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:smownerid:assigned_user_id:ProjectTask_Assigned_To:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;

update ld_customview set viewname='All' where entitytype='ProjectMilestone' and cvid=46;
select cvid into @cvid from ld_customview where entitytype='ProjectMilestone' and viewname='ALL';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_projectmilestone:projectmilestone_no:projectmilestone_no:ProjectMilestone_Project_Milestone_No:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_projectmilestone:projectmilestonename:projectmilestonename:ProjectMilestone_Project_Milestone_Name:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_projectmilestone:projectid:projectid:ProjectMilestone_项目名称:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_projectmilestone:projectmilestonedate:projectmilestonedate:ProjectMilestone_里程碑日期:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_projectmilestone:projectmilestonetype:projectmilestonetype:ProjectMilestone_Type:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_crmentity:createdtime:createdtime:ProjectMilestone_Created_Time:T' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:modifiedtime:modifiedtime:ProjectMilestone_Modified_Time:T' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:ProjectMilestone_Assigned_To:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);
delimiter;

select tabid into @tabid from ld_tab where name='Vendors';
delete from ld_relatedlists where tabid=@tabid and name='get_contacts' and label='Contacts';
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseOrder';
delete from ld_relatedlists where tabid=@tabid and name='get_activities' and label='Activities';
delete from ld_relatedlists where tabid=@tabid and name='get_history' and label='Activity History';
delimiter;

update LD_field set fieldlabel='合同订单' where tablename='LD_cashbill'  and columnname='salesorderid';
update LD_cvcolumnlist set columnname='LD_cashbill:salesorderid:salesorder_id:CashBill_合同订单:V'  where columnname='LD_cashbill:salesorderid:salesorder_id:CashBill_销售订单:V';
update LD_cvadvfilter  set columnname='LD_cashbill:salesorderid:salesorder_id:CashBill_合同订单:V'  where columnname='LD_cashbill:salesorderid:salesorder_id:CashBill_销售订单:V';
update ld_cvstdfilter   set columnname='LD_cashbill:salesorderid:salesorder_id:CashBill_合同订单:V'  where columnname='LD_cashbill:salesorderid:salesorder_id:CashBill_销售订单:V';
delete from lD_links where linklabel='Add Project Task';
update LD_field set sequence=1 where tabid=18 and columnname='vendorname';
update LD_field set sequence=2 where tabid=18 and columnname='vendor_no';
update LD_tab set presence=1 where tabid=38;
call addcolumn ('ld_products','costprice','decimal','(25,2)',2);

update ld_field set sequence=1 where tabid=19 and columnname='bookname';
update ld_field set sequence=2 where tabid=19 and columnname='pricebook_no';
update ld_field set sequence=4 where tabid=19 and columnname='active';
update ld_field set sequence=3 where tabid=19 and columnname='currency_id';
update ld_field set sequence=5 where tabid=19 and columnname='smcreatorid';
update ld_field set sequence=6 where tabid=19 and columnname='createdtime';
update ld_field set sequence=7 where tabid=19 and columnname='modifiedby';
update ld_field set sequence=8 where tabid=19 and columnname='modifiedtime';
update ld_field set sequence=9  where tabid=19 and columnname='description';

select  id into @id from  LD_links_seq;
update ld_Links_seq  set id=id+1 where not exists(select 1 from LD_links where   linktype='DETAILVIEWWIDGET' and tabid=15);
insert into ld_Links(linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence)select @id+1,15,'DETAILVIEWWIDGET' ,'DetailViewBlockCommentWidget',
'block://ModComments:modules/ModComments/ModComments.php','themes/images/pointer.gif' ,0 from dual
where not exists(select 1 from LD_links where   linktype='DETAILVIEWWIDGET' and tabid=15);
update ld_profile2standardpermissions set permissions=0 where profileid=1 and permissions=1;
delete from ld_field where tabid=15 and columnname='comments';



call AddColumn('ld_users','level','int',11,null);
delimiter;
call AddColumn('ld_users','approvestatus','int',1,null);
delimiter;
call AddColumn('ld_users','approveby','int',19,null);
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1 where not exists(select 1 from ld_field where tablename='ld_users' and fieldname='level');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 29,@id+1,'level','LD_users',1,15,'level','Level',1,0,'',100,11,77,1,'V~O',1,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_users' and fieldname='level');
delimiter
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_users' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 29,@id+1,'approvestatus','LD_users',1,15,'approvestatus','Approvestatus',1,0,'',100,11,77,1,'V~O',1,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_users' and fieldname='approvestatus');
delimiter
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_users' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 29,@id+1,'approveby','LD_users',1,15,'approveby','Approveby',1,0,'',100,11,77,1,'V~O',1,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_users' and fieldname='approveby');
delimiter
select blockid into @blockid from ld_settings_blocks WHERE label='LBL_STUDIO';
select id into @id from ld_settings_field_seq;
update ld_settings_field_seq set id=@id+1 where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LBL_APPROVE');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,@blockid,'LBL_APPROVE','approvelist.gif','LBL_APPROVE_DESCRIPTION','index.php?module=Settings&action=MultiApproveList&parenttab=Settings',10,0
from dual where not exists (select 1 from ld_settings_field where blockid=@blockid and name='LBL_APPROVE');
delimiter;

create table if not exists ld_approvestatus (
id int(19) not null,
statusid int(2) null,
approvestatus varchar(20) null,
primary key(id)
)engine=innodb auto_increment=0 default charset=utf8;
delimiter;
create table if not exists ld_approve(
id int(19) not null,
tabid int(19) not null,
name varchar(100) not null,
description text null,
status int(19) null,
smcreatorid int(19) null,
modifiedby int(19) null,
createdtime datetime,
modifiedtime datetime,
primary key(id)
)engine=innodb auto_increment=0 default charset=utf8;
delimiter;
create table if not exists ld_approve_seq(
id int(11)
)engine=innodb auto_increment=0 default charset=utf8;
delimiter;
insert into ld_approve_seq(id)
select 1 from dual where not exists(select 1 from ld_approve_seq);
delimiter;
create table if not exists ld_approve2role(
approveid int(19) null,
roleid varchar(255) null
)engine=innodb auto_increment=0 default charset=utf8;
delimiter;
create table if not exists ld_approvestep(
id int(19) not null,
approveid int(19) not null,
name varchar(100) not null,
description text null,
ended int(1) null,
step int(1) null,
sequence int(11) null,
createdtime datetime,
modifiedtime datetime,
approvetype int(1) null,
approvevalue varchar(255) null,
primary key(id)
)engine=innodb auto_increment=0 default charset=utf8;
delimiter;
create table if not exists ld_approvestep_seq(
id int(11)
)engine=innodb auto_increment=0 default charset=utf8;
delimiter;
insert into ld_approvestep_seq(id)
select 1 from dual where not exists(select 1 from ld_approvestep_seq);
delimiter;
create table if not exists ld_approvestepdetails(
stepid int(19) null,
pass int(1) null,
modulestatus varchar(200)
)engine=innodb auto_increment=0 default charset=utf8;
delimiter;
create table if not exists ld_approvelog(
id int(19) not null,
crmid int(19) null,
description text null,
approveid int(19) null,
stepid int(19) null,
approved_by int(19) null,
approveresult int(11) null,
createdtime datetime,
nextstepid int(19),
nextstepapproveby varchar(255),
primary key(id),
KEY idx_approvelog_crmid (crmid,approveid)
)engine=innodb auto_increment=0 default charset=utf8;

delimiter;
create table if not exists ld_approvelog_seq(
id int(11)
)engine=innodb auto_increment=0 default charset=utf8;
delimiter;
insert into ld_approvelog_seq(id)
select 1 from dual where not exists(select 1 from ld_approvelog_seq);
delimiter;
call AddColumn('ld_salesorder','approvestatus','int',11,null);
call AddColumn('ld_salesorder','approveby','int',19,null);
delimiter;
call AddColumn('ld_invoice','approvestatus','int',11,null);
call AddColumn('ld_invoice','approveby','int',19,null);
delimiter;
call AddColumn('ld_quotes','approvestatus','int',11,null);
call AddColumn('ld_quotes','approveby','int',19,null);
delimiter;
call AddColumn('ld_troubletickets','approvestatus','int',11,null);
call AddColumn('ld_troubletickets','approveby','int',19,null);
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_salesorder' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 22,@id+1,'approvestatus','LD_salesorder',1,53,'approvestatus','Approvestatus',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_salesorder' and fieldname='approvestatus');
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_salesorder' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 22,@id+1,'approveby','LD_salesorder',1,53,'approveby','Approveby',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_salesorder' and fieldname='approveby');
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_invoice' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 23,@id+1,'approvestatus','LD_invoice',1,53,'approvestatus','Approvestatus',1,0,'',100,16,67,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_invoice' and fieldname='approvestatus');
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_invoice' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 23,@id+1,'approveby','LD_invoice',1,53,'approveby','Approveby',1,0,'',100,16,67,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_invoice' and fieldname='approveby');
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_quotes' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 20,@id+1,'approvestatus','LD_quotes',1,53,'approvestatus','Approvestatus',1,0,'',100,17,49,3,'V~O',3,'','BAS',2,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_quotes' and fieldname='approvestatus');
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_quotes' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 20,@id+1,'approveby','LD_quotes',1,53,'approveby','Approveby',1,0,'',100,17,49,3,'V~O',3,'','BAS',2,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_quotes' and fieldname='approveby');
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_trobuletickets' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 13,@id+1,'approvestatus','LD_trobuletickets',1,53,'approvestatus','Approvestatus',1,0,'',100,15,25,3,'V~O',0,4,'BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_trobuletickets' and fieldname='approvestatus');
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_trobuletickets' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 13,@id+1,'approveby','LD_trobuletickets',1,53,'approveby','Approveby',1,0,'',100,15,25,3,'V~O',0,4,'BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_trobuletickets' and fieldname='approveby');
delimiter;
call AddColumn('ld_systems_deploy','description','varchar',255,null);
delimiter;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,'3','SalesOrder2Approve' from dual where not exists
(select 1 from ld_systems_deploy where description='SalesOrder2Approve');
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,'4','Invoice2Approve' from dual where not exists
(select 1 from ld_systems_deploy where description='Invoice2Approve');
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,'5','Quotes2Approve' from dual where not exists
(select 1 from ld_systems_deploy where description='Quotes2Approve');
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,'6','HelpDesk2Approve' from dual where not exists
(select 1 from ld_systems_deploy where description='HelpDesk2Approve');
delimiter;


select max(blockid) into @id from ld_blocks;
update ld_blocks_seq set id=@id;
delimiter;

alter table ld_products modify costprice decimal(25,2);
update ld_field set presence=2 where tabid=14 and columnname='costprice';
update ld_tab set presence=1 where name='MassFaxs';

update ld_sales_stage set sales_stage='' where sales_stage_id=9 and picklist_valueid=158;
update ld_sales_stage set sales_stage='成功结案' where sales_stage_id=9 and picklist_valueid=158;

update LD_blocks set display_status=1 where blocklabel='LBL_CAMPAIGN_INFORMATION';

update LD_field set uitype=86 where columnname='date_time' and  tablename='LD_reminds';
update lD_relatedLists set actions='add' where tabid=22 and name='get_invoices';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='lastpotential'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 6,@maxfieldid+1,'lastpotential','LD_account',1,125,'lastpotential','最新销售机会',1,0,'',100,48,9,2,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='lastpotential'  and tabid=6 ) ;
delimiter;
select id into @id from LD_blocks_seq;
update LD_blocks_seq set id=@id+1  where not exists(select 1 from LD_blocks where tabid=6 and blocklabel='LBL_PUBLICACCOUNT_LOG'); 
insert into LD_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @id+1,6,'LBL_PUBLICACCOUNT_LOG',8,0,0,1,1,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=6 and blocklabel='LBL_PUBLICACCOUNT_LOG');
delimiter;

update LD_relatedlists set name='get_ServiceContracts' where tabid=6 and related_tabid=37;
update LD_relatedlists set name='get_project' where tabid=6 and related_tabid=48;

call AddColumn('ld_purchaseorder','approvestatus','int',11,null);
call AddColumn('ld_purchaseorder','approveby','int',19,null);
delimiter;

select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_purchaseorder' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 21,@id+1,'approvestatus','ld_purchaseorder',1,130,'approvestatus','Approvestatus',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_purchaseorder' and fieldname='approvestatus');
delimiter;

select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_purchaseorder' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 21,@id+1,'approveby','ld_purchaseorder',1,53,'approveby','Approveby',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_purchaseorder' and fieldname='approveby');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,'8','PurchaseOrder2Approve' from dual where not exists
(select 1 from ld_systems_deploy where description='PurchaseOrder2Approve');
delimiter;

update ld_field set uitype=130 where columnname='approvestatus';
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_STUDIO';
select id into @id from ld_settings_field_seq;
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
update ld_settings_field_seq set id=@id+1 where not exists (select 1 from ld_settings_field where blockid=@blockid and name='LBL_RELATED_RELATEDLIST');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,@blockid,'LBL_RELATED_RELATEDLIST','productfield.gif','LBL_RELATED_RELATEDLIST_DESCRIPTION','index.php?module=Settings&action=RelatedList&parenttab=Settings',@sequence+1,0 from dual 
where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LBL_RELATED_RELATEDLIST');
delimiter;

drop procedure  if exists `addtabintoprofile`;
delimiter ||
create procedure addtabintoprofile
(

profileid int(19),
tabname varchar(50)

)
begin
declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  LD_field where tabid in(select tabid from lD_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into LD_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from LD_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');
	
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

CREATE TABLE if not exists `ld_expense` (
  `expenseid` int(19) NOT NULL,
  `expensedate` date default NULL,
  `expense_no` varchar(255) default NULL,
  `accountid` int(19) default NULL,
  `Salesorderid` int(19) default NULL,
  `NumCount` decimal(11,0) default NULL,
  `total` decimal(25,2) default NULL,
  `approvestatus` int(11) default NULL,
  `approveby` int(19) default NULL,
  `currency_id` int(19) default '1',
  `conversion_rate` decimal(25,2) default '1.00',
  `potentialid` int(19) default NULL,
  PRIMARY KEY  (`expenseid`),
  KEY `idx_expense_approvestatus` (`approvestatus`),
  CONSTRAINT `fk_1_lingdang_expense` FOREIGN KEY (`expenseid`) REFERENCES `ld_crmentity` (`crmid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_expensedetail` (
  `expensedetailid` int(19) NOT NULL auto_increment,
  `expensetype` varchar(100) default NULL,
  `Startdate` date default NULL,
  `enddate` date default NULL,
  `Money` decimal(25,2) default NULL,
  `description` text,
  `expenseid` int(19) default NULL,
  `expenseuse` varchar(200) default NULL,
  `Sequence` int(10) default NULL,
  PRIMARY KEY  (`expensedetailid`),
  KEY `idx_expensedetail_expenseid` (`expenseid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
CREATE TABLE   if not exists `ld_expensescf` (
  `expenseid` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE  if not exists `ld_expensetype` (
  `expensetypeid` int(11) NOT NULL default '0',
  `expensetype` varchar(11) default NULL,
  PRIMARY KEY  (`expensetypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

Select  max(tabid) into @tabid from LD_tab;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'Expense',0,50,'Expense',0,0,1,'Finacial',1 from dual where not exists(select 1 from lD_tab where name='Expense');

select tabid into @tabid from lD_tab where name='expense';
select parenttabid into @parenttabid from LD_parenttab where  parenttab_Label='Finacial';
insert into LD_parenttabrel(tabid,parenttabid,sequence) select @tabid,@parenttabid,5 from dual where not exists(select 1 from LD_parenttabrel where tabid=@tabid );

select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='expense';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_Expense_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_EXPENSE_INFORMATION');

delimiter;

select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='expensedate'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'expensedate','LD_expense',1,5,'expensedate','expensedate',1,0,'thistoday',100,1,@expenseid,1,'D~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='expensedate'  and tabid=@tabid ) ;
delimiter;

select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='expense_no'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'expense_no','LD_expense',1,4,'expense_no','Expense No',1,0,'',100,2,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='expense_no'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'accountid','LD_expense',1,73,'account_id','Account Name',1,0,'',100,3,@expenseid,1,'I~O',3,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=@tabid ) ;
delimiter;



select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='potentialid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'potentialid','LD_expense',1,76,'potential_id','Potential Name',1,0,'',100,4,@expenseid,1,'I~O',3,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='potentialid'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salesorderid','LD_expense',1,80,'salesorder_id','Sales Order',1,0,'',100,5,@expenseid,1,'I~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='numcount'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'numcount','LD_expense',1,400,'numcount','numcount',1,0,'',100,6,@expenseid,1,'P~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='numcount'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','报销人',1,0,'',100,7,@expenseid,1,'V~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smownerid'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='total'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'total','LD_expense',1,72,'hdnGrandTotal','Total',1,0,'',100,8,@expenseid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='total'  and tabid=@tabid ) ;
delimiter;



select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smcreatorid','LD_crmentity',1,52,'creator','Creator',1,0,'',100,9,@expenseid,2,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid ) ;
delimiter;



select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','Created Time',1,0,'',100,10,@expenseid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='approvestatus'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'approvestatus','LD_expense',1,53,'approvestatus','ApproveStatus',1,0,'',100,11,@expenseid,3,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='approvestatus'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='expense';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='approveby'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'approveby','LD_expense',1,53,'approveby','Approveby',1,0,'',100,12,@expenseid,3,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='approveby'  and tabid=@tabid ) ;
delimiter;

select max(deploy_type) into @maxtype from LD_Systems_deploy;
insert into LD_systems_deploy (deploy_value,deploy_type,description) select 0,@maxtype+1,'Expense2Approve'  from dual where not exists(select 1 from LD_systems_deploy where description='Expense2Approve');

call fieldprofile('expense');
call getallprofile('expense');

select tabid into @tabid from LD_tab where name='expense' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;
select tabid into @tabid from LD_tab where name='expense';
update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
delimiter;



select max(id) into @maxid from LD_ws_entity ;
insert into LD_ws_entity(id,name,handler_path,handler_class,ismodule) select @maxid+1,'Expense','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 from dual
where not exists(select 1 from lD_ws_entity where name='Expense');
delimiter;

select  tabid into @tabid from LD_tab where name='Expense';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select  @tabid,'Expense','LD_Expense','expense_no','expenseid','expense_id' from dual
where not exists(select 1 from LD_entityname where tabid=@tabid);
delimiter;

select id into @maxid from LD_modentity_num_seq ;
update LD_modentity_num_seq set id=@maxid+1 where  not exists(select 1 from LD_modentity_num where  semodule='Expense');
insert into LD_modentity_num (num_id,semodule,prefix,start_id,cur_id,active)
select @maxid+1,'Expense','EXP',1,1,1 from dual  where  not exists(select 1 from LD_modentity_num where  semodule='Expense');
delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='Expense');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'Expense',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='Expense');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Expense';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_expense:expense_no:expense_no:Expense_Expense_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expense_no:expense_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_expense:expensedate:expensedate:Expense_expensedate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expensedate:expensedate%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_expense:accountid:account_id:Expense_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:accountid:account_id:Expense_Account%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_expense:salesorderid:salesorder_id:Expense_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:salesorderid:salesorder_id:Expense%');
delimiter;



select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_expense:total:hdnGrandTotal:Expense_Total:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:total:hdnGrandTotal:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:Expense_报销人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:Expense%');
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='已批准' and entitytype='Expense');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'已批准',    1, 0, 'Expense',3,1,1 from dual where not exists(select 1 from LD_customview where viewname='已批准' and entitytype='Expense');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已批准' and entitytype='Expense';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_expense:expense_no:expense_no:Expense_Expense_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expense_no:expense_no%');
delimiter;



select cvid into @cvid   from LD_customview where viewname='已批准' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_expense:expensedate:expensedate:Expense_expensedate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expensedate:expensedate%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已批准' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_expense:accountid:account_id:Expense_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:accountid:account_id:Expense_Account%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已批准' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_expense:salesorderid:salesorder_id:Expense_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:salesorderid:salesorder_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已批准' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已批准' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_expense:total:hdnGrandTotal:Expense_Total:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:total:hdnGrandTotal:Expense%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='已批准' and entitytype='Expense';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:Expense_报销人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已批准' and entitytype='expense';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' ,'e','已批准',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='审批中' and entitytype='Expense');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'审批中',    1, 0, 'Expense',3,1,1 from dual where not exists(select 1 from LD_customview where viewname='审批中' and entitytype='Expense');
delimiter;

select cvid into @cvid   from LD_customview where viewname='审批中' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_expense:expense_no:expense_no:Expense_Expense_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expense_no:expense_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='审批中' and entitytype='Expense';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_expense:expensedate:expensedate:Expense_expensedate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expensedate:expensedate%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='审批中' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_expense:accountid:account_id:Expense_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:accountid:account_id:Expense_Account%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='审批中' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_expense:salesorderid:salesorder_id:Expense_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:salesorderid:salesorder_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='审批中' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='审批中' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_expense:total:hdnGrandTotal:Expense_Total:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:total:hdnGrandTotal:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='审批中' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:Expense_报销人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='审批中' and entitytype='expense';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' ,'e','审批中',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='已驳回' and entitytype='Expense');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'已驳回',    1, 0, 'Expense',3,1,1 from dual where not exists(select 1 from LD_customview where viewname='已驳回' and entitytype='Expense');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已驳回' and entitytype='Expense';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_expense:expense_no:expense_no:Expense_Expense_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expense_no:expense_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已驳回' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_expense:expensedate:expensedate:Expense_expensedate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expensedate:expensedate%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已驳回' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_expense:accountid:account_id:Expense_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:accountid:account_id:Expense_Account%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已驳回' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_expense:salesorderid:salesorder_id:Expense_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:salesorderid:salesorder_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已驳回' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已驳回' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_expense:total:hdnGrandTotal:Expense_Total:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:total:hdnGrandTotal:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已驳回' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:Expense_报销人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已驳回' and entitytype='expense';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' ,'e','已驳回',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='未提交' and entitytype='Expense');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'未提交',    1, 0, 'Expense',3,1,1 from dual where not exists(select 1 from LD_customview where viewname='未提交' and entitytype='Expense');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未提交' and entitytype='Expense';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_expense:expense_no:expense_no:Expense_Expense_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expense_no:expense_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未提交' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_expense:expensedate:expensedate:Expense_expensedate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expensedate:expensedate%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未提交' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_expense:accountid:account_id:Expense_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:accountid:account_id:Expense_Account%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未提交' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_expense:salesorderid:salesorder_id:Expense_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:salesorderid:salesorder_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未提交' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未提交' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_expense:total:hdnGrandTotal:Expense_Total:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:total:hdnGrandTotal:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未提交' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:Expense_报销人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未提交' and entitytype='expense';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' ,'e','未提交',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='已拒绝' and entitytype='Expense');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'已拒绝',    1, 0, 'Expense',3,1,1 from dual where not exists(select 1 from LD_customview where viewname='已拒绝' and entitytype='Expense');
delimiter;

select cvid into @cvid from LD_customview where viewname='已拒绝' and entitytype='Expense';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_expense:expense_no:expense_no:Expense_Expense_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expense_no:expense_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已拒绝' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_expense:expensedate:expensedate:Expense_expensedate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:expensedate:expensedate%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已拒绝' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_expense:accountid:account_id:Expense_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:accountid:account_id:Expense_Account%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已拒绝' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_expense:salesorderid:salesorder_id:Expense_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:salesorderid:salesorder_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已拒绝' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已拒绝' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_expense:total:hdnGrandTotal:Expense_Total:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_expense:total:hdnGrandTotal:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已拒绝' and entitytype='Expense';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:Expense_报销人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:Expense%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已拒绝' and entitytype='expense';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V' ,'e','已拒绝',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_expense:approvestatus:approvestatus:Expense%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;

delete from lD_expensetype where expensetypeid<=7;

insert into LD_expensetype(expensetypeid,expensetype)values(1,'餐饮');
insert into LD_expensetype(expensetypeid,expensetype)values(2,'交通');
insert into LD_expensetype(expensetypeid,expensetype)values(3,'通讯');
insert into LD_expensetype(expensetypeid,expensetype)values(4,'礼品');
insert into LD_expensetype(expensetypeid,expensetype)values(5,'办公');
insert into LD_expensetype(expensetypeid,expensetype)values(6,'活动');
insert into LD_expensetype(expensetypeid,expensetype)values(7,'其他');


select id into @id from ld_links_seq;
select  tabid into @tabid from lD_Tab where name='Expense' ;
update LD_links_seq set id=@id+1 where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
insert into LD_Links (linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,handler)
select @id+1,@tabid,'DETAILVIEWBASIC','View History','javascript:ModTrackerCommon.showhistory(''$RECORD$'')','themes/images/pointer.gif',1,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual 
where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');




select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='Expense';
select tabid into @tabid from LD_tab where name='accounts';
update LD_relatedlists set sequence=sequence+1 where tabid=6 and sequence>24 and sequence<32;
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_expense'and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_expense',25,'expense',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_expense' and tabid=@tabid);
delimiter;




select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='Expense';
select tabid into @tabid from LD_tab where name='salesorder';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_expense'and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_expense',25,'expense',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_expense' and tabid=@tabid);
delimiter;


select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='Expense';
select tabid into @tabid from LD_tab where name='salesorder';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_expense'and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_expense',15,'expense',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_expense' and tabid=@tabid);
update LD_relatedlists set sequence=17  where tabid=@tabid and related_tabid=9;
delimiter;


update  LD_reportmodules set  secondarymodules='Invoice:Expense' where  reportmodulesid=52;

call addtabintoprofile('expense',1);
delimiter;

update ld_links set linkurl='index.php?module=Documents&action=EditView&return_module=ProjectTask&return_action=DetailView&return_id=$RECORD$&parent_id=$RECORD$&Create=yes'
where tabid=47 and linklabel='Add Note';
delimiter;
update ld_tab set presence=1 where name='Events';
update ld_tab set presence=1 where name='Emails';
delimiter;

insert into ld_approvestatus(id,statusid,approvestatus)
select 1,0,'未提交' from dual where not exists(select 1 from ld_approvestatus where approvestatus='未提交');
delimiter;
insert into ld_approvestatus(id,statusid,approvestatus)
select 2,1,'审批中' from dual where not exists(select 1 from ld_approvestatus where approvestatus='审批中');
delimiter;
insert into ld_approvestatus(id,statusid,approvestatus)
select 3,2,'已批准' from dual where not exists(select 1 from ld_approvestatus where approvestatus='已批准');
delimiter;
insert into ld_approvestatus(id,statusid,approvestatus)
select 4,3,'已拒绝' from dual where not exists(select 1 from ld_approvestatus where approvestatus='已拒绝');
delimiter;
insert into ld_approvestatus(id,statusid,approvestatus)
select 5,6,'已驳回' from dual where not exists(select 1 from ld_approvestatus where approvestatus='已驳回');
delimiter;
update ld_field set uitype=131,presence=2,displaytype=2,tablename='LD_salesorder' where columnname='approveby' and tabid=22;
delimiter;
update ld_field set uitype=130,presence=2,displaytype=2,tablename='LD_salesorder' where columnname='approvestatus' and tabid=22;
delimiter;
update ld_field set uitype=131,presence=2,displaytype=2,tablename='LD_invoice' where columnname='approveby' and tabid=23;
delimiter;
update ld_field set uitype=130,presence=2,displaytype=2,tablename='LD_invoice' where columnname='approvestatus' and tabid=23;
delimiter;
update ld_field set uitype=131,presence=2,displaytype=2,tablename='LD_purchaseorder' where columnname='approveby' and tabid=21;
delimiter;
update ld_field set uitype=130,presence=2,displaytype=2,tablename='LD_purchaseorder' where columnname='approvestatus' and tabid=21;
delimiter;
update ld_field set uitype=131,presence=2,displaytype=2,tablename='LD_troubletickets' where columnname='approveby' and tabid=13;
delimiter;
update ld_field set uitype=130,presence=2,displaytype=2,tablename='LD_troubletickets' where columnname='approvestatus' and tabid=13;
delimiter;
update ld_field set uitype=131,presence=2,displaytype=2,tablename='LD_quotes' where columnname='approveby' and tabid=20;
delimiter;
update ld_field set uitype=130,presence=2,displaytype=2,tablename='LD_quotes' where columnname='approvestatus' and tabid=20;
delimiter;
alter table ld_troubletickets alter column approvestatus set default 0;
alter table ld_troubletickets alter column approveby set default 0;
delimiter;
alter table ld_salesorder alter column approvestatus set default 0;
alter table ld_salesorder alter column approveby set default 0;
delimiter;
alter table ld_invoice alter column approvestatus set default 0;
alter table ld_invoice alter column approveby set default 0;
delimiter;
alter table ld_quotes alter column approvestatus set default 0;
alter table ld_quotes alter column approveby set default 0;
delimiter;
alter table ld_purchaseorder alter column approvestatus set default 0;
alter table ld_purchaseorder alter column approveby set default 0;
delimiter;

call addcolumn('ld_account_set','dataprofile','int',4,0);

call addcolumn('ld_account_set','getprofile','int',4,0);


select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='Accounts';
update LD_blocks_seq set id=@maxid+1 where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT'); 
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_ACCOUNT_PRIMARYCONTACT',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT');

delimiter;

update LD_blocks set sequence=1 where blockid=9;

update LD_blocks set sequence=4 where blockid=10;

update LD_blocks set sequence=5 where blockid=11;


select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='lastname'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'lastname','LD_contactdetails',1,255,'lastname','姓名',1,0,'',100,1,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='lastname'  and tabid=@tabid ) ;

select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='firstname'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'firstname','LD_contactdetails',1,1,'firstname','英文名',1,0,'',100,2,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='firstname'  and tabid=@tabid ) ;


select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salutation'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salutation','LD_contactdetails',1,15,'salutationtype','Salutation',1,0,'',100,3,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salutation'  and tabid=@tabid ) ;

select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='title'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'title','LD_contactdetails',1,1,'title','职务',1,0,'',100,4,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='title'  and tabid=@tabid ) ;

select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='phone'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'phone','LD_contactdetails',1,11,'phone','电话',1,0,'',100,5,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='phone'  and tabid=@tabid ) ;

select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='mobile'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'mobile','LD_contactdetails',1,11,'mobile','手机',1,0,'',100,6,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='mobile'  and tabid=@tabid ) ;



select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='faxx'  and tabid=@tabid and tablename='LD_contactdetails' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'faxx','LD_contactdetails',1,11,'faxx','传真',1,0,'',100,7,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='faxx'  and tabid=@tabid and tablename='LD_contactdetails') ;


select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='email'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'email','LD_contactdetails',1,13,'email','Email',1,0,'',100,8,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='email'  and tabid=@tabid ) ;

select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='email'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'reference','LD_contactdetails',1,56,'reference','Reference',1,1,'',100,9,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='reference'  and tabid=@tabid ) ;

call fieldprofile('accounts');
call getallprofile('accounts');

update ld_field set fieldlabel='公司电话' where tabid=6 and columnname='phone';
update ld_field set fieldlabel='公司传真' where tabid=6 and columnname='fax';
update ld_field set fieldlabel='公司Email' where tabid=6 and columnname='email1';

delimiter;
update  LD_tab set presence=2  where name='FieldFormulas';

CREATE TABLE if not exists `ld_smssendtype` (
  `typeid` int(19) NOT NULL auto_increment,
  `typename` varchar(200) NOT NULL,
  PRIMARY KEY  (`typeid`),
  UNIQUE KEY `typeid` (`typeid`)
) ENGINE=InnoDB   DEFAULT CHARSET=utf8;
delimiter;

insert into ld_smssendtype(typeid,typename) select  1,'营销短信'  from dual where not exists(select 1 from ld_smssendtype where typeid='1' and typename='营销短信');
delimiter;

insert into ld_smssendtype(typeid,typename) select  2,'短信提醒'  from dual where not exists(select 1 from ld_smssendtype where typeid='2' and typename='短信提醒');
delimiter;

insert into ld_systems_deploy (deploy_value,deploy_type,description) select 0,7,null from dual where not exists(select 1 from ld_systems_deploy where deploy_type =7);
delimiter;

update ld_field set uitype = 15 where columnname = 'approvestatus' and tablename = 'LD_users';
delimiter;

update ld_customview set sequence=sequence+1 where entitytype='faq' and viewname<>'all';
update LD_tab set presence=0 where name='emails';

drop procedure  if exists `addtabintoprofile`;
delimiter ||
create procedure addtabintoprofile
(

profileid int(19),
 tabname varchar(50)

)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  LD_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from LD_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;

	deallocate  prepare stmt;

	OPEN cur1;
	Fetch cur1 into pprofileid;

 loop1: while  done<>1 DO
		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;
		
		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
		prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

          set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

	     set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;


drop procedure  if exists fieldintoprofile;
delimiter ||
create procedure fieldintoprofile
(
profileid int(19),
 tabname varchar(50)

)
begin
declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  LD_field where tabid in(select tabid from lD_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into LD_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from LD_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');
	
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

update LD_profile2field  set readonly=0 where fieldid in(select fieldid from ld_field where tabid=6 and tablename='ld_contactdetails');
delimiter;

call addtabintoprofile('expense',1);
delimiter;

call fieldprofile('project');
delimiter;

call getallprofile('project');
delimiter;

call fieldprofile('projecttask');
delimiter;

call getallprofile('projecttask');
delimiter;

call fieldprofile('ProjectMilestone');
delimiter;

call getallprofile('ProjectMilestone');
delimiter;

call fieldprofile('ServiceContracts');
delimiter;

call getallprofile('ServiceContracts');
delimiter;

call fieldprofile('vendors');
delimiter;

call getallprofile('vendors');
delimiter;

call fieldprofile('expense');
delimiter;

call getallprofile('expense');
delimiter;

update LD_profile2field  set visible=0,readonly=0   where fieldid in(select fieldid  from lD_field where tabid=48);
update LD_def_org_field  set visible=0  where fieldid in(select fieldid  from lD_field where tabid=48);
update LD_profile2field  set visible=0,readonly=0   where fieldid in(select fieldid  from lD_field where tabid=47);
update LD_def_org_field  set visible=0  where fieldid in(select fieldid  from lD_field where tabid=47);
update LD_profile2field  set visible=0   where fieldid in(select fieldid  from lD_field where tabid=46);
update LD_def_org_field  set visible=0  where fieldid in(select fieldid  from lD_field where tabid=46);
update LD_profile2field  set visible=0,readonly=0   where fieldid in(select fieldid  from lD_field where tabid=37);
update LD_def_org_field  set visible=0  where fieldid in(select fieldid  from lD_field where tabid=37);
update LD_profile2field  set visible=0,readonly=0   where fieldid in(select fieldid  from lD_field where tabid=18);
update LD_def_org_field  set visible=0  where fieldid in(select fieldid  from lD_field where tabid=18);

select tabid into @tabid from ld_tab where name='Accounts';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='Contacts';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='ContactRecords';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='ServiceContracts';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='HelpDesk';
update ld_field set fieldlabel='服务人员' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='Quotes';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseOrder';
update ld_field set fieldlabel='采购负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='Project';
update ld_field set fieldlabel='项目负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='ProjectTask';
update ld_field set fieldlabel='项目负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='ProjectMilestone';
update ld_field set fieldlabel='项目负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='PaymentPlan';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
update ld_field set fieldlabel='销售负责人' where tabid=@tabid and columnname='smownerid';
delimiter;

update ld_tab set presence=0 where name='FieldFormulas';

drop procedure  if exists `addtabintoprofile`;
delimiter ||
create procedure addtabintoprofile
(
tabname varchar(50),
permissions int
)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  LD_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from LD_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;

	deallocate  prepare stmt;

	OPEN cur1;
	Fetch cur1 into pprofileid;

 loop1: while  done<>1 DO
		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;
		
		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
		prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

          set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

	     set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

call addtabintoprofile('expense',1);
delimiter;

update ld_profile2field set readonly=0 where tabid in  (select tabid from lD_tab where name='expense');
 
update ld_def_org_field  set visible=0 where tabid in  (select tabid from lD_tab where name='expense');

select id into @id from ld_def_org_share_seq;
update ld_def_org_share_seq set id=@id+1 where not exists (select 1 from ld_def_org_share where  tabid='18');
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @id+1,18,0,0 from dual where not exists (select 1 from ld_def_org_share where  tabid='18');
delimiter;
insert into LD_org_share_action2tab(share_action_id,tabid)
select 0,18 from dual where not exists(select 1 from LD_org_share_action2tab where tabid=18 and share_action_id=0); 
delimiter;
insert into LD_org_share_action2tab(share_action_id,tabid)
select 1,18 from dual where not exists(select 1 from LD_org_share_action2tab where tabid=18 and share_action_id=1);
delimiter;
insert into LD_org_share_action2tab(share_action_id,tabid)
select 2,18 from dual where not exists(select 1 from LD_org_share_action2tab where tabid=18 and share_action_id=2);
delimiter;
insert into LD_org_share_action2tab(share_action_id,tabid)
select 3,18 from dual where not exists(select 1 from LD_org_share_action2tab where tabid=18 and share_action_id=3);
delimiter;
alter table ld_Expense alter column approvestatus set default '0';
alter table ld_Expense alter column approveby set default '0';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_relatedlists_lable` (
  `id` int(11) NOT NULL auto_increment,
  `tabid` int(11) NOT NULL COMMENT '模块ID',
  `fieldid` varchar(25) NOT NULL COMMENT '对应表名',
  `width` int(11) default '0' COMMENT '字段宽度',
  `sequence` int(11) default '0' COMMENT '字段顺序',
  `presence` int(11) default '0' COMMENT '显示状态0不显示，1显示',
  `edit` int(11) default '0' COMMENT '0可修改，1不可修改',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=119 DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where name='Expense'; 
update ld_field set uitype=130 where tabid=@tabid and columnname='approvestatus';
update ld_field set uitype=131 where tabid=@tabid and columnname='approveby';
delimiter;

update LD_settings_field  set active=0 where name='INVENTORYTERMSANDCONDITIONS';
update LD_account_set set getprofile=1;

update ld_tab set tabsequence=0 where name='Home';

update ld_tab set tabsequence=1 where name='Accounts';
update ld_tab set tabsequence=2 where name='Contacts';
update ld_tab set tabsequence=3 where name='ContactRecords';
update ld_tab set tabsequence=4 where name='ServiceContracts';
update ld_tab set tabsequence=5 where name='HelpDesk';

update ld_tab set tabsequence=11 where name='ReportLog';
update ld_tab set tabsequence=12 where name='Calendar';
update ld_tab set tabsequence=13 where name='Webmails';
update ld_tab set tabsequence=14 where name='MailManager';
update ld_tab set tabsequence=15 where name='Emails';
update ld_tab set tabsequence=16 where name='Documents';
update ld_tab set tabsequence=17 where name='Faq';

update ld_tab set tabsequence=21 where name='Campaigns';
update ld_tab set tabsequence=22 where name='MassSMS';
update ld_tab set tabsequence=23 where name='MassEmails';
update ld_tab set tabsequence=24 where name='MassFaxs';
update ld_tab set tabsequence=25 where name='MassVoices';
update ld_tab set tabsequence=26 where name='SmsPhrases';
update ld_tab set tabsequence=27 where name='EmailListtmp';
update ld_tab set tabsequence=28 where name='CommunicationLog';


update ld_tab set tabsequence=31 where name='Potentials';
update ld_tab set tabsequence=32 where name='Quotes';
update ld_tab set tabsequence=33 where name='SalesOrder';

update ld_tab set tabsequence=41 where name='Vendors';
update ld_tab set tabsequence=42 where name='PurchaseOrder';


update ld_tab set tabsequence=51 where name='Project';
update ld_tab set tabsequence=52 where name='ProjectTask';
update ld_tab set tabsequence=53 where name='ProjectMilestone';

update ld_tab set tabsequence=61 where name='PaymentPlan';
update ld_tab set tabsequence=62 where name='CashBill';
update ld_tab set tabsequence=63 where name='Invoice';
update ld_tab set tabsequence=64 where name='Expense';


update ld_tab set tabsequence=81 where name='Reports';
update ld_tab set tabsequence=82 where name='Comprehensivereport';
update ld_tab set tabsequence=83 where name='Dashboard';


update ld_tab set tabsequence=91 where name='ModComments';
update ld_tab set tabsequence=92 where name='Announcements';
update ld_tab set tabsequence=93 where name='Products';
update ld_tab set tabsequence=94 where name='PriceBooks';
update ld_tab set tabsequence=95 where name='RecycleBin';
update ld_tab set tabsequence=96 where name='Reminds';
update ld_tab set tabsequence=97 where name='FieldFormulas';


update ld_tab set tabsequence=201 where name='Leads';
update ld_tab set tabsequence=202 where name='Events';
update ld_tab set tabsequence=203 where name='Rss';
update ld_tab set tabsequence=204 where name='Portal';
update ld_tab set tabsequence=205 where name='ConfigEditor';
update ld_tab set tabsequence=206 where name='Import';
update ld_tab set tabsequence=207 where name='Integration';
update ld_tab set tabsequence=208 where name='Mobile';
update ld_tab set tabsequence=209 where name='PBXManager';
update ld_tab set tabsequence=210 where name='Services';
update ld_tab set tabsequence=211 where name='lingdangBackup';
update ld_tab set tabsequence=212 where name='WSAPP';
update ld_tab set tabsequence=213 where name='Assets';
update ld_tab set tabsequence=214 where name='CronTasks';
update ld_tab set tabsequence=215 where name='CustomerPortal';
update ld_tab set tabsequence=216 where name='SMSNotifier';
update ld_tab set tabsequence=217 where name='Webforms';

update lD_field set presence=1 where (columnname='planned_duration' or columnname='actual_duration'  or columnname='progress' ) and tablename='LD_servicecontracts';
call addcolumn('ld_contactdetails','faxx','varchar',50,null);
update LD_contactdetails set faxx ='fax';

call addcolumn('ld_smssend','type','int',9,1);
delimiter;

select cvid into @cvid from ld_customview where entitytype='Faq' and viewname='已作废';
delete from ld_cvstdfilter where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_customview where entitytype='Faq' and viewname='已作废';
delimiter;

select cvid into @cvid from ld_customview where viewname='aaaa' and entitytype='Contacts';
delete from ld_cvstdfilter where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_customview where viewname='aaaa' and entitytype='Contacts';
delimiter;

update lD_tab set printtab=1 where name='contactrecords';
update LD_links set tabid=500000 where tabid=6 and linklabel='LBL_ADD_NOTE';
update LD_links set tabid=500001 where tabid in(select tabid from LD_tab where name='contactrecords')  and linklabel='LBL_ADD_NOTE';

select tabid into @tabid from ld_tab where name='ContactRecords';
select max(templateprintid) into @id from ld_templateprint;
insert into ld_templateprint(templateprintid,printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select @id+1,'ContactRecords.html',@tabid,1,'联系记录预置模板',1 from dual
where not exists(select 1 from ld_templateprint where Tabid=@tabid and printfilename='ContactRecords.html' and SystemDefault=1); 
delimiter;

select tabid into @tabid from ld_tab where name='Expense';
select max(templateprintid) into @id from ld_templateprint;
insert into ld_templateprint(templateprintid,printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select @id+1,'Expense.html',@tabid,1,'费用报销预置模板',1 from dual
where not exists(select 1 from ld_templateprint where Tabid=@tabid and printfilename='Expense.html' and SystemDefault=1); 
delimiter;

update lD_links set tabid=500004 where tabid=48 and linklabel='Add Note';
update lD_links set tabid=500005 where tabid=47 and linklabel='Add Note';
update lD_links set tabid=500006 where tabid in(select tabid from LD_tab where name='paymentplan')  and linklabel='LBL_ADD_NOTE';

select tabid into @tabid from lD_tab where name='expense';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='expense') and columnname='expense_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,15,1,1,1 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select tabid into @tabid from lD_tab where name='expense';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='expense') and columnname='expensedate';
 insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,15,2,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select tabid into @tabid from lD_tab where name='expense';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='expense') and columnname='numcount';
 insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,15,3,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
select tabid into @tabid from lD_tab where name='expense';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='expense') and columnname='salesorderid';
 insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,15,3,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select tabid into @tabid from lD_tab where name='expense';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='expense') and columnname='total';
 insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,15,4,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select tabid into @tabid from lD_tab where name='expense';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='expense') and columnname='smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,15,4,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='mailingzip'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'mailingzip','LD_contactaddress',1,1,'mailingzip','邮编',1,0,'',100,10,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='mailingzip'  and tabid=@tabid ) ;

select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='mailingstreet'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'mailingstreet','LD_contactaddress',1,21,'mailingstreet','住址',1,0,'',100,11,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='mailingstreet'  and tabid=@tabid ) ;

call fieldprofile('accounts');
call getallprofile('accounts');

update ld_field set fieldlabel='主题' where columnname='Subject';
update ld_cvcolumnlist set columnname=replace(columnname,'标题','主题');
update ld_field set fieldlabel='主题' where tabid=13 and columnname='title';
update ld_field set fieldlabel='交付日期' where tabid=21 and columnname='duedate';
update ld_field set fieldlabel='交付日期' where tabid=22 and columnname='duedate';
update ld_field set fieldlabel='备注' where columnname='Description';

select blockid into @blockid from LD_blocks where tabid=21 and blocklabel='LBL_PO_INFORMATION';
update LD_field set block=@blockid where tabid=21  and (columnname='approvestatus' or columnname='approveby');

select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @expenseid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='phone'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'pphone','LD_contactdetails',1,11,'pphone','电话',1,0,'',100,5,@expenseid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='pphone'  and tabid=@tabid ) ;

call addcolumn('ld_contactdetails','pphone','varchar',50,null);
update LD_contactdetails set pphone =phone;

call fieldprofile('accounts');
call getallprofile('accounts');
update LD_field set columnname='faxx' where columnname='fax' and tabid=4;
update LD_field set columnname='pphone' where columnname='phone' and tabid=4;

update lD_links set tabid=500002 where tabid in(select tabid from LD_tab where name='contacts')  and linklabel='LBL_ADD_NOTE';
delimiter;

delete from ld_relatedlists_lable;
INSERT INTO `ld_relatedlists_lable` VALUES ('1', '2', '110', '0', '1', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('2', '2', '118', '0', '2', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('3', '2', '112', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('4', '2', '114', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('5', '2', '119', '0', '5', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('6', '4', '70', '0', '1', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('7', '4', '76', '0', '2', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('8', '4', '69', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('9', '4', '71', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('10', '4', '80', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('11', '4', '87', '0', '6', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('12', '6', '1', '0', '1', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('13', '6', '2', '0', '2', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('14', '6', '26', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('15', '6', '801', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('16', '6', '13', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('17', '6', '749', '0', '6', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('18', '6', '745', '0', '7', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('19', '6', '20', '0', '8', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('20', '8', '205', '0', '1', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('21', '8', '208', '0', '2', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('22', '8', '217', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('23', '8', '209', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('24', '8', '216', '0', '5', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('25', '10', '224', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('26', '10', '238', '0', '2', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('27', '10', '220', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('28', '10', '223', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('29', '10', '230', '0', '5', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('30', '13', '155', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('31', '13', '170', '0', '2', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('32', '13', '159', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('33', '13', '157', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('34', '13', '158', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('35', '13', '161', '0', '6', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('36', '13', '156', '0', '7', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('37', '14', '174', '0', '1', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('38', '14', '175', '0', '2', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('39', '14', '176', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('40', '14', '179', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('41', '14', '189', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('42', '14', '197', '0', '6', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('43', '14', '194', '0', '7', '1', '0');

-- 更多信息字段“日程管理”
INSERT INTO `ld_relatedlists_lable` VALUES ('44', '16', '268', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('45', '16', '256', '0', '2', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('46', '16', '258', '0', '3', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('47', '16', '260', '0', '4', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('48', '16', '257', '0', '5', '1', '1');

INSERT INTO `ld_relatedlists_lable` VALUES ('49', '19', '306', '0', '1', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('50', '19', '307', '0', '2', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('51', '19', '702', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('52', '19', '309', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('53', '19', '308', '0', '5', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('54', '20', '314', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('55', '20', '315', '0', '2', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('56', '20', '317', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('57', '20', '318', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('58', '20', '325', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('59', '20', '331', '0', '6', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('60', '21', '351', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('61', '21', '352', '0', '2', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('62', '21', '353', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('63', '21', '356', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('64', '21', '357', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('65', '21', '362', '0', '6', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('66', '21', '369', '0', '7', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('67', '22', '389', '0', '2', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('68', '22', '390', '0', '3', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('69', '22', '399', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('70', '22', '396', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('71', '22', '403', '0', '6', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('72', '22', '410', '0', '7', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('73', '23', '474', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('74', '23', '436', '0', '2', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('75', '23', '453', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('76', '23', '440', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('77', '23', '447', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('78', '23', '437', '0', '6', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('79', '23', '454', '0', '7', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('80', '26', '126', '0', '1', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('81', '26', '128', '0', '2', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('82', '26', '130', '0', '3', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('83', '26', '141', '0', '4', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('84', '26', '131', '0', '5', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('85', '26', '132', '0', '6', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('86', '37', '548', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('87', '37', '540', '0', '2', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('88', '37', '546', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('89', '37', '544', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('90', '37', '534', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('91', '37', '541', '0', '6', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('92', '37', '531', '0', '7', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('93', '38', '551', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('94', '38', '550', '0', '2', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('95', '38', '567', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('96', '38', '562', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('97', '38', '565', '0', '5', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('98', '46', '598', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('99', '46', '593', '0', '2', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('100', '46', '594', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('101', '46', '596', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('102', '46', '597', '0', '5', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('103', '47', '609', '0', '1', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('104', '47', '603', '0', '2', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('105', '47', '604', '0', '3', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('106', '47', '605', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('107', '47', '610', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('108', '47', '612', '0', '6', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('109', '47', '613', '0', '7', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('110', '47', '607', '0', '8', '1', '0');

INSERT INTO `ld_relatedlists_lable` VALUES ('111', '48', '618', '0', '3', '1', '1');
INSERT INTO `ld_relatedlists_lable` VALUES ('112', '48', '626', '0', '4', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('113', '48', '619', '0', '5', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('114', '48', '620', '0', '6', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('115', '48', '623', '0', '7', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('116', '48', '622', '0', '8', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('117', '48', '630', '0', '9', '1', '0');
INSERT INTO `ld_relatedlists_lable` VALUES ('118', '48', '625', '0', '10', '1', '0');

-- 更多信息字段“联系记录”
select tabid into @tabid from ld_tab where name='ContactRecords';
select max(id) into @id from ld_relatedlists_lable;
delete from ld_relatedlists_lable where tabid=@tabid;
select fieldid into @fid1 from ld_field where tabid=@tabid and columnname='subject';
select fieldid into @fid2 from ld_field where tabid=@tabid and columnname='contactrecordtype';
select fieldid into @fid3 from ld_field where tabid=@tabid and columnname='contactdate';
select fieldid into @fid4 from ld_field where tabid=@tabid and columnname='nextcontactdate';
select fieldid into @fid5 from ld_field where tabid=@tabid and columnname='content';
select fieldid into @fid6 from ld_field where tabid=@tabid and columnname='smownerid';

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+1,@tabid,@fid1,0,1,1,1 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid1);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+2,@tabid,@fid2,0,2,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid2);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+3,@tabid,@fid3,0,3,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid3);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+4,@tabid,@fid4,0,4,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid4);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fid5,0,5,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid5);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+6,@tabid,@fid6,0,6,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid6);
delimiter;

-- 更多信息字段“回款计划”
select tabid into @tabid from ld_tab where name='PaymentPlan';
select max(id) into @id from ld_relatedlists_lable;
delete from ld_relatedlists_lable where tabid=@tabid;
select fieldid into @fid1 from ld_field where tabid=@tabid and columnname='paymentplan_no';
select fieldid into @fid2 from ld_field where tabid=@tabid and columnname='periodtime';
select fieldid into @fid3 from ld_field where tabid=@tabid and columnname='amount';
select fieldid into @fid4 from ld_field where tabid=@tabid and columnname='plandate';
select fieldid into @fid5 from ld_field where tabid=@tabid and columnname='paymentstatus';
select fieldid into @fid6 from ld_field where tabid=@tabid and columnname='salesorderid';
select fieldid into @fid7 from ld_field where tabid=@tabid and columnname='smownerid';

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+1,@tabid,@fid1,0,1,1,1 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid1);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+2,@tabid,@fid2,0,2,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid2);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+3,@tabid,@fid3,0,3,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid3);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+4,@tabid,@fid4,0,4,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid4);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fid5,0,5,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid5);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+6,@tabid,@fid6,0,6,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid6);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+7,@tabid,@fid7,0,7,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid7);
delimiter;

-- 更多信息字段“收款单”
select tabid into @tabid from ld_tab where name='CashBill';
select max(id) into @id from ld_relatedlists_lable;
delete from ld_relatedlists_lable where tabid=@tabid;
select fieldid into @fid1 from ld_field where tabid=@tabid and columnname='cashbill_no';
select fieldid into @fid2 from ld_field where tabid=@tabid and columnname='cashbilldate';
select fieldid into @fid3 from ld_field where tabid=@tabid and columnname='total';
select fieldid into @fid4 from ld_field where tabid=@tabid and columnname='iscashbill';
select fieldid into @fid5 from ld_field where tabid=@tabid and columnname='paymentmethod';
select fieldid into @fid6 from ld_field where tabid=@tabid and columnname='salesorderid';
select fieldid into @fid7 from ld_field where tabid=@tabid and columnname='smownerid';

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+1,@tabid,@fid1,0,1,1,1 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid1);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+2,@tabid,@fid2,0,2,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid2);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+3,@tabid,@fid3,0,3,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid3);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+4,@tabid,@fid4,0,4,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid4);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fid5,0,5,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid5);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+6,@tabid,@fid6,0,6,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid6);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+7,@tabid,@fid7,0,7,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid7);
delimiter;

-- 更多信息字段“费用报销”
select tabid into @tabid from ld_tab where name='Expense';
select max(id) into @id from ld_relatedlists_lable;
delete from ld_relatedlists_lable where tabid=@tabid;
select fieldid into @fid1 from ld_field where tabid=@tabid and columnname='expense_no';
select fieldid into @fid2 from ld_field where tabid=@tabid and columnname='expensedate';
select fieldid into @fid3 from ld_field where tabid=@tabid and columnname='total';
select fieldid into @fid4 from ld_field where tabid=@tabid and columnname='salesorderid';
select fieldid into @fid5 from ld_field where tabid=@tabid and columnname='smownerid';

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+1,@tabid,@fid1,0,1,1,1 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid1);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+2,@tabid,@fid2,0,2,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid2);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+3,@tabid,@fid3,0,3,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid3);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+4,@tabid,@fid4,0,4,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid4);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fid5,0,5,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid5);
delimiter;

alter table ld_salesorder modify column approvestatus varchar(200) default '未提交';
alter table ld_invoice modify column approvestatus varchar(200) default '未提交';
alter table ld_quotes modify column approvestatus varchar(200) default '未提交';
alter table ld_troubletickets modify column approvestatus varchar(200) default '未提交';
alter table ld_purchaseorder modify column approvestatus varchar(200) default '未提交';
alter table ld_expense modify column approvestatus varchar(200) default '未提交';
delimiter;

update ld_templatesstuff set stufftitle = "最近6个月销售情况" where stufftitle = "公司最近6个月销售情况";
update ld_templatesstuff set stufftitle = "签约额月度同比" where stufftitle = "公司签约额月度同比";
update ld_templatesstuff set stufftitle = "回款额月度同比" where stufftitle = "公司回款额月度同比";
update ld_templatesstuff set stufftitle = "年度销售情况" where stufftitle = "公司年度销售情况";
update ld_templatesstuff set stufftitle = "应收款汇总" where stufftitle = "应收款客户汇总";

select tabid into @tabid from ld_tab where name='PurchaseOrder';
select max(templateprintid) into @id from ld_templateprint;
insert into ld_templateprint(templateprintid,printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select @id+1,'PurchaseOrder.html',@tabid,1,'采购订单预置模板',1 from dual
where not exists(select 1 from ld_templateprint where Tabid=@tabid and printfilename='PurchaseOrder.html' and SystemDefault=1); 
delimiter;

-- 更多信息字段“常见问答”
select tabid into @tabid from ld_tab where name='Faq';
select max(id) into @id from ld_relatedlists_lable;
delete from ld_relatedlists_lable where tabid=@tabid;
select fieldid into @fid1 from ld_field where tabid=@tabid and columnname='faq_no';
select fieldid into @fid2 from ld_field where tabid=@tabid and columnname='question';
select fieldid into @fid3 from ld_field where tabid=@tabid and columnname='product_id';
select fieldid into @fid4 from ld_field where tabid=@tabid and columnname='category';
select fieldid into @fid5 from ld_field where tabid=@tabid and columnname='status';
select fieldid into @fid6 from ld_field where tabid=@tabid and columnname='createdtime';

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+1,@tabid,@fid1,0,1,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid1);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+2,@tabid,@fid2,0,2,1,1 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid2);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+3,@tabid,@fid3,0,3,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid3);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+4,@tabid,@fid4,0,4,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid4);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fid5,0,5,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid5);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fid5,0,5,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid5);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+6,@tabid,@fid5,0,6,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid6);
delimiter;


-- 更多信息字段“供应商”
select tabid into @tabid from ld_tab where name='Vendors';
select max(id) into @id from ld_relatedlists_lable;
delete from ld_relatedlists_lable where tabid=@tabid;
select fieldid into @fid1 from ld_field where tabid=@tabid and columnname='vendor_no';
select fieldid into @fid2 from ld_field where tabid=@tabid and columnname='vendorname';
select fieldid into @fid3 from ld_field where tabid=@tabid and columnname='phone';
select fieldid into @fid4 from ld_field where tabid=@tabid and columnname='email';
select fieldid into @fid5 from ld_field where tabid=@tabid and columnname='fax';
select fieldid into @fid6 from ld_field where tabid=@tabid and columnname='smcreatorid';

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+1,@tabid,@fid1,0,1,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid1);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+2,@tabid,@fid2,0,2,1,1 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid2);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+3,@tabid,@fid3,0,3,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid3);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+4,@tabid,@fid4,0,4,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid4);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fid5,0,5,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid5);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fid5,0,5,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid5);

INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+6,@tabid,@fid5,0,6,1,0 from dual
where not exists (select fieldid from  ld_relatedlists_lable where tabid=@tabid and fieldid=@fid6);
delimiter;

insert into ld_field(tablename,columnname,tabid) 
select 'LD_crmentity','modifiedtime',15 from dual 
where not exists (select fieldid from  ld_field where tabid=15 and columnname='modifiedtime');

call AddColumn('ld_account','lastpotential', 'char',10,null);
delimiter;

call addcolumn('LD_troubletickets','accountid','int',19,0);
call addcolumn('LD_troubletickets','contactid','int',19,0);
update LD_troubletickets  inner join LD_account on LD_account.accountid=LD_troubletickets.parent_id  set LD_troubletickets.accountid=LD_account.accountid;
update LD_troubletickets  inner join LD_contactdetails on LD_contactdetails.contactid=LD_troubletickets.parent_id  set LD_troubletickets.contactid=LD_contactdetails.contactid;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=13 );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 13,@maxfieldid+1,'accountid','LD_troubletickets',1,73,'account_id','Account Name',1,0,'',100,4,25,1,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=13 ) ;
delimiter;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='contactid'  and tabid=13 );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 13,@maxfieldid+1,'contactid','LD_troubletickets',1,57,'contact_id','联系人姓名',1,0,'',100,5,25,1,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='contactid'  and tabid=13 ) ;
delimiter;
update LD_field set presence=1  where tabid=13 and columnname='parent_id';

call fieldprofile('HelpDesk');
call getallprofile('HelpDesk');
update LD_cvcolumnlist set columnname='LD_troubletickets:accountid:account_id:HelpDesk_Account_Name:V' where columnname like 'LD_troubletickets:parent_id:parent_id:HelpDesk%';

select fieldid into @fieldid from LD_field where tabid=13 and columnname='accountid';
select fieldid into @parentfieldid from LD_field where tabid=13 and columnname='parent_id';
update ld_relatedlists_lable  set fieldid=@fieldid  where  fieldid=@parentfieldid;


call addcolumn('ld_potential','accountid','int',19,0);
call addcolumn('LD_potential','contactid','int',19,0);
update ld_potential  inner join LD_account on LD_account.accountid=ld_potential.related_to  set ld_potential.accountid=LD_account.accountid;
update ld_potential  inner join LD_contactdetails on LD_contactdetails.contactid=ld_potential.related_to  set ld_potential.contactid=LD_contactdetails.contactid;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=2 );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 2,@maxfieldid+1,'accountid','LD_potential',1,73,'account_id','Account Name',1,0,'',100,3,1,1,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountid'  and tabid=2 ) ;
delimiter;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='contactid'  and tabid=2 );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 2,@maxfieldid+1,'contactid','LD_potential',1,57,'contact_id','联系人姓名',1,0,'',100,4,1,1,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='contactid'  and tabid=2 ) ;
delimiter;
update LD_field set presence=1  where tabid=2 and columnname='related_to';

call fieldprofile('Potentials');
call getallprofile('Potentials');

update LD_cvcolumnlist set columnname='LD_potential:accountid:account_id:Potentials_Account_Name:V' where columnname like'LD_potential:related_to:related_to:Potentials%';

select fieldid into @fieldid from LD_field where tabid=2 and columnname='accountid';
select fieldid into @parentfieldid from LD_field where tabid=2 and columnname='related_to';
update ld_relatedlists_lable  set fieldid=@fieldid  where  fieldid=@parentfieldid;

delete from LD_paymentplan  where paymentplanid not in(select crmid from LD_crmentity);


delete from LD_cashbill  where cashbillid  not in(select crmid from lD_crmentity);

delete  from LD_CashBill2paymentplan  where cashbillid   not in(select crmid from lD_crmentity);

drop procedure  if exists `addforginkey`;
delimiter ||
create procedure addforginkey
(
 
tablename varchar(50),
forginkeyname varchar(100),
columnname varchar(50),
referencetable varchar(50),
referenceid varchar(50)
 
)
begin
 
select database() into @tableschema;
 
set tablename=lower(tablename);
 

set @colName='';
SET @tsql=CONCAT('select  IFNULL(referenced_column_name, '''') into @colName  from information_schema.key_column_usage  where  
TABLE_SCHEMA =','''',@tableschema,'''','  and  table_name= ','''',tablename,'''',' and referenced_column_name=''',referenceid,'''');
 
prepare stmt from @tsql;
execute stmt;
set @coladd=IFNULL(@colName,'-1');
 
IF @coladd = '-1'  or @coladd<>referenceid THEN
 set @alterColumn=CONCAT(' alter table ',tablename, ' add foreign key(  ',columnname, ' ) references  ',referencetable, '( ',referenceid,' )  ON  DELETE CASCADE');
 prepare stalter from @altercolumn;
 execute stalter;
 
END IF;
 
end ||
delimiter;

call addforginkey('ld_cashbill','fk_1_lingdang_cashbill','cashbillid','ld_crmentity','crmid');
call addforginkey('ld_paymentplan','fk_1_lingdang_paymentplan','paymentplanid','ld_crmentity','crmid');
call addforginkey('LD_CashBill2paymentplan','fk_1_lingdang_CashBill2Paymentplan','cashbillid','LD_cashbill','cashbillid');
update LD_tab set printtab=1 where name='purchaseorder';

select  id  into @id from  ld_selectquery_seq ;
update ld_selectquery_seq set id=@id+1 where not  exists(select 1 from LD_report where folderid=10 and reportname='产品销售统计表');
insert into ld_selectquery(queryid,startindex,numofobjects) select @id+1 ,0,0 from dual where not  exists(select 1 from LD_report where folderid=10 and reportname='产品销售统计表');
select max(id)  into @reportid from ld_selectquery_seq ;
insert into LD_report(reportid,folderid,reportname,description,reporttype,queryid,state,customizable,category,owner,sharingtype)
select @reportid,10,'产品销售统计表','产品销售统计表','summary',@reportid,'DEFAULT',1,60,1,'public' from dual where not exists
(select 1 from LD_report where folderid=10 and reportname='产品销售统计表');

select queryid  into @queryid  from LD_report where folderid=10 and reportname='产品销售统计表';
delete from LD_selectcolumn  where queryid =@queryid;  
insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,0,concat('LD_inventoryproductrel:productid:SalesOrder_产品名称:productid:V') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_inventoryproductrel:productid:SalesOrder_%');

insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,1,concat('LD_productsSalesOrder:product_no:SalesOrder_产品编号:product_no:V') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_productsSalesOrder:product_no:SalesOrder%');
insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,2,concat('LD_productsSalesOrder:productcategory:SalesOrder_产品类别:productcategory:V') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_productsSalesOrder:productcategory:SalesOrder%');

insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,3,concat('LD_salesorder:accountid:SalesOrder_客户名称:account_id:V') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_salesorder:accountid:SalesOrder_%');

insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,4,concat('LD_salesorder:duedate:SalesOrder_Due_Date:duedate:D') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_salesorder:duedate:SalesOrder_%');


insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,5,concat('LD_productsSalesOrder:productsheet:SalesOrder_规格型号:productsheet:V') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_productsSalesOrder:productsheet:SalesOrder_%');

insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,6,concat('LD_productsSalesOrder:usageunit:SalesOrder_计量单位:usageunit:V') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_productsSalesOrder:usageunit:SalesOrder_%');

insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,7,concat('LD_inventoryproductrel:quantity:SalesOrder_数量:quantity:I') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_inventoryproductrel:quantity:SalesOrder%');

insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,8,concat('LD_inventoryproductrel:listprice:SalesOrder_定价:listprice:I') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_inventoryproductrel:listprice:SalesOrder%');
insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,9,concat('LD_salesorder:total:SalesOrder_金额:hdnGrandTotal:N') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_salesorder:total:SalesOrder%');

insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,10,concat('LD_crmentitySalesOrder:createdtime:SalesOrder_Created_Time:createdtime:DT') from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname like 'LD_crmentitySalesOrder:createdtime:SalesOrder%');

insert into LD_selectcolumn (queryid,columnindex,columnname) select @queryid,11,'none' from dual 
where  not exists(select 1 from LD_selectcolumn where queryid=@queryid and columnname='none');
select reportid  into @reportid  from LD_report where folderid=10 and reportname='产品销售统计表'; 
insert into LD_reportsortcol(sortcolid,reportid,columnname) select 2, @reportid,'LD_productsSalesOrder:product_no:SalesOrder_产品编号:product_no:V' from dual 
where not exists(select 1 from LD_reportsortcol where reportid=@reportid and columnname='LD_productsSalesOrder:product_no:SalesOrder_产品编号:product_no:V');

select reportid  into @reportid  from LD_report where folderid=10 and reportname='产品销售统计表'; 
insert into LD_reportmodules(reportmodulesid,primarymodule,secondarymodules) 
select @reportid,'SalesOrder','' from dual where not exists(select 1 from LD_reportmodules where reportmodulesid=@reportid);
update LD_report set customizable=60 ,category=1 where folderid=10 and reportname='产品销售统计表'; 

update ld_field set uitype = 11 where tablename = 'LD_users' and columnname = 'approveby' and tabid=29 ;
update LD_field set fieldlabel='客户名称' where tabid=22 and columnname='accountid' and fieldlabel='Account Name';

update ld_field set fieldname='taskpriority' where tabid=16 and columnname='priority';
delimiter;
update ld_field set displaytype=2 where tabid=67 and columnname='approvestatus';
update ld_field set displaytype=2 where tabid=67 and columnname='approveby';
delimiter;

insert into ld_relatedlists_lable(tabid,fieldid,edit)
select 16,266,1 from dual where not exists (select 1 from ld_relatedlists_lable where 
tabid = 16 and fieldid = 266 and edit = 1);

update ld_relatedlists_lable set edit = 0,presence = 1 where tabid = 16;
update ld_relatedlists_lable set sequence = 1 where tabid = 16 and fieldid = 266;
update ld_relatedlists_lable set edit = 1 where tabid = 16 and fieldid in (256,266);

delete from ld_relatedlists where tabid=13 and related_tabid=9;
update ld_relatedlists_lable set sequence=1 where tabid=16 and fieldid=266;
update ld_relatedlists_lable set sequence=2 where tabid=16 and fieldid=268;
delete from ld_relatedlists_lable where tabid=6 and fieldid=749;
delete from ld_relatedlists_lable where tabid=6 and fieldid=745;
update ld_field set fieldlabel='参考价' where tabid=14 and columnname='unit_price';

update ld_tab set ownedby=0 where name='Vendors';
delimiter;
delete from ld_field where tabid=13 and columnname='approvestatus';
delete from ld_field where tabid=13 and columnname='approveby';
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_trobuletickets' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 13,@id+1,'approvestatus','LD_trobuletickets',1,130,'approvestatus','Approvestatus',1,2,'',100,15,25,2,'V~O',0,4,'BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_trobuletickets' and fieldname='approvestatus');
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_trobuletickets' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly
)
select 13,@id+1,'approveby','LD_trobuletickets',1,131,'approveby','Approveby',1,2,'',100,15,25,2,'V~O',0,4,'BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_trobuletickets' and fieldname='approveby');
delimiter;

update LD_currency_info  set currency_name='中国,人民币' where currency_name='China, Yuan Renminbi';
update LD_currency_info set currency_name='美国,美元' where currency_name='USA, Dollars';
update LD_currencies set currency_name='中国,人民币' where currency_name='China, Yuan Renminbi';
update LD_currencies  set currency_name='美国,美元' where currency_name='USA, Dollars';
update ld_settings_field set active=0 where name='LBL_FIELDFORMULAS';

delete from ld_relatedlists where tabid=14 and label='Parent Product';

-- 服务单审批流程
select id into @id from ld_approve_seq;
update ld_approve_seq set id=@id+1  where not exists(select 1 from ld_approve where tabid=13 and name='服务单审批流程');
insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime)
select @id+1,13,'服务单审批流程','',0,1,1, now(), now() from dual 
where not exists(select 1 from ld_approve where tabid=13 and name='服务单审批流程');

select  min(roleid) into @roleid from ld_role where depth>0;
insert into ld_approve2role(approveid,roleid)
select @id+1,@roleid from dual where not exists(select 1 from ld_approve2role where approveid=@id+1 and roleid=@roleid);
delimiter;

select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=13 and name='服务单审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'一级审批','',1,1,1,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
delimiter;

select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=13 and name='二级审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'二级审批','',1,1,2,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
delimiter;

-- 报价单审批流程
select id into @id from ld_approve_seq;
update ld_approve_seq set id=@id+1  where not exists(select 1 from ld_approve where tabid=20 and name='报价单审批流程');
insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime)
select @id+1,20,'报价单审批流程','',0,1,1, now(), now() from dual 
where not exists(select 1 from ld_approve where tabid=20 and name='报价单审批流程');

select  min(roleid) into @roleid from ld_role where depth>0;
insert into ld_approve2role(approveid,roleid)
select @id+1,@roleid from dual where not exists(select 1 from ld_approve2role where approveid=@id+1 and roleid=@roleid);
delimiter;

select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=20 and name='报价单审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'一级审批','',1,1,1,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
delimiter;
select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=20 and name='二级审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'二级审批','',1,1,2,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
delimiter;

-- 采购订单审批流程
select id into @id from ld_approve_seq;
update ld_approve_seq set id=@id+1  where not exists(select 1 from ld_approve where tabid=21 and name='采购订单审批流程');
insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime)
select @id+1,21,'采购订单审批流程','',0,1,1, now(), now() from dual 
where not exists(select 1 from ld_approve where tabid=21 and name='采购订单审批流程');

select  min(roleid) into @roleid from ld_role where depth>0;
insert into ld_approve2role(approveid,roleid)
select @id+1,@roleid from dual where not exists(select 1 from ld_approve2role where approveid=@id+1 and roleid=@roleid);
delimiter;

select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=21 and name='采购订单审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'一级审批','',1,1,1,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
delimiter;

select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=21 and name='二级审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'二级审批','',1,1,2,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
delimiter;

-- 合同订单审批流程
select id into @id from ld_approve_seq;
update ld_approve_seq set id=@id+1  where not exists(select 1 from ld_approve where tabid=22 and name='合同订单审批流程');
insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime)
select @id+1,22,'合同订单审批流程','',0,1,1, now(), now() from dual 
where not exists(select 1 from ld_approve where tabid=22 and name='合同订单审批流程');

select  min(roleid) into @roleid from ld_role where depth>0;
insert into ld_approve2role(approveid,roleid)
select @id+1,@roleid from dual where not exists(select 1 from ld_approve2role where approveid=@id+1 and roleid=@roleid);
delimiter;

select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=22 and name='合同订单审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'一级审批','',1,1,1,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
delimiter;

select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=22 and name='二级审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'二级审批','',1,1,2,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
delimiter;

-- 发票审批流程
select id into @id from ld_approve_seq;
update ld_approve_seq set id=@id+1  where not exists(select 1 from ld_approve where tabid=23 and name='发票审批流程');
insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime)
select @id+1,23,'发票审批流程','',0,1,1, now(), now() from dual 
where not exists(select 1 from ld_approve where tabid=23 and name='发票审批流程');

select  min(roleid) into @roleid from ld_role where depth>0;
insert into ld_approve2role(approveid,roleid)
select @id+1,@roleid from dual where not exists(select 1 from ld_approve2role where approveid=@id+1 and roleid=@roleid);
delimiter;

select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=23 and name='发票审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'一级审批','',1,1,1,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
delimiter;

select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=23 and name='二级审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'二级审批','',1,1,2,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
delimiter;

-- 费用报销审批流程
select tabid into @tabid from ld_tab where name='Expense';
select id into @id from ld_approve_seq;
update ld_approve_seq set id=@id+1  where not exists(select 1 from ld_approve where tabid=@tabid and name='费用报销审批流程');
insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime)
select @id+1,@tabid,'费用报销审批流程','',0,1,1, now(), now() from dual 
where not exists(select 1 from ld_approve where tabid=@tabid and name='费用报销审批流程');

select  min(roleid) into @roleid from ld_role where depth>0;
insert into ld_approve2role(approveid,roleid)
select @id+1,@roleid from dual where not exists(select 1 from ld_approve2role where approveid=@id+1 and roleid=@roleid);
delimiter;

select tabid into @tabid from ld_tab where name='Expense';
select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=@tabid and name='费用报销审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'一级审批','',1,1,1,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='一级审批');
delimiter;

select tabid into @tabid from ld_tab where name='Expense';
select id into @id from ld_approvestep_seq;
select id into @approveid from ld_approve where tabid=@tabid and name='二级审批流程';
update ld_approvestep_seq set id=@id+1 where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
select @id+1,@approveid,'二级审批','',1,1,2,now(),now(),0,1 from dual 
where not exists(select 1 from ld_approvestep where approveid=@approveid and name='二级审批');
delimiter;

delete from ld_picklist_dependency where tabid=18;
select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_country', 'bill_state', '--无--', '[\"--\\u65e0--\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter;

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '--无--', '[\"--\\u65e0--\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter;

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '上海', '[\"--\\u65e0--\",\"\\u5b9d\\u5c71\\u533a\",\"\\u957f\\u5b81\\u533a\",\"\\u5d07\\u660e\\u533a\",\"\\u5949\\u8d24\\u533a\",\"\\u8679\\u53e3\\u533a\",\"\\u9ec4\\u6d66\\u533a\",\"\\u5609\\u5b9a\\u533a\",\"\\u91d1\\u5c71\\u533a\",\"\\u9759\\u5b89\\u533a\",\"\\u5362\\u6e7e\\u533a\",\"\\u95f5\\u884c\\u533a\",\"\\u5357\\u6c47\\u533a\",\"\\u6d66\\u4e1c\\u65b0\\u533a\",\"\\u666e\\u9640\\u533a\",\"\\u9752\\u6d66\\u533a\",\"\\u677e\\u6c5f\\u533a\",\"\\u5f90\\u6c47\\u533a\",\"\\u6768\\u6d66\\u533a\",\"\\u95f8\\u5317\\u533a\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter;

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '北京', '[\"--\\u65e0--\",\"\\u660c\\u5e73\\u533a\",\"\\u671d\\u9633\\u533a\",\"\\u5d07\\u6587\\u533a\",\"\\u5927\\u5174\\u533a\",\"\\u4e1c\\u57ce\\u533a\",\"\\u623f\\u5c71\\u533a\",\"\\u4e30\\u53f0\\u533a\",\"\\u6d77\\u6dc0\\u533a\",\"\\u6000\\u67d4\\u533a\",\"\\u5bc6\\u4e91\\u53bf\",\"\\u5e73\\u8c37\\u533a\",\"\\u77f3\\u666f\\u5c71\\u533a\",\"\\u987a\\u4e49\\u533a\",\"\\u901a\\u5dde\\u533a\",\"\\u897f\\u57ce\\u533a\",\"\\u5ba3\\u6b66\\u533a\",\"\\u5ef6\\u5e86\\u53bf\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter;

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '天津', '[\"--\\u65e0--\",\"\\u5b9d\\u577b\\u533a\",\"\\u5317\\u8fb0\\u533a\",\"\\u5927\\u6e2f\\u533a\",\"\\u4e1c\\u4e3d\\u533a\",\"\\u6c49\\u6cbd\\u533a\",\"\\u548c\\u5e73\\u533a\",\"\\u6cb3\\u5317\\u533a\",\"\\u6cb3\\u4e1c\\u533a\",\"\\u6cb3\\u897f\\u533a\",\"\\u7ea2\\u6865\\u533a\",\"\\u84df\\u53bf\",\"\\u6d25\\u5357\\u533a\",\"\\u9759\\u6d77\\u53bf\",\"\\u5357\\u5f00\\u533a\",\"\\u5b81\\u6cb3\\u53bf\",\"\\u5858\\u6cbd\\u533a\",\"\\u6b66\\u6e05\\u533a\",\"\\u897f\\u9752\\u533a\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter;

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '重庆', '[\"--\\u65e0--\",\"\\u5df4\\u5357\\u533a\",\"\\u5317\\u789a\\u533a\",\"\\u957f\\u5bff\\u533a\",\"\\u5927\\u6e21\\u53e3\\u533a\",\"\\u6daa\\u9675\\u533a\",\"\\u5408\\u5ddd\\u533a\",\"\\u6c5f\\u5317\\u533a\",\"\\u6c5f\\u6d25\\u533a\",\"\\u4e5d\\u9f99\\u5761\\u533a\",\"\\u5357\\u5cb8\\u533a\",\"\\u5357\\u5ddd\\u533a\",\"\\u7da6\\u6c5f\\u533a\",\"\\u9ed4\\u6c5f\\u533a\",\"\\u6c99\\u576a\\u575d\\u533a\",\"\\u53cc\\u6865\\u533a\",\"\\u4e07\\u5dde\\u533a\",\"\\u6c38\\u5ddd\\u533a\",\"\\u6e1d\\u5317\\u533a\",\"\\u6e1d\\u4e2d\\u533a\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter;

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '香港', '[\"--\\u65e0--\",\"\\u9999\\u6e2f\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '澳门', '[\"--\\u65e0--\",\"\\u6fb3\\u95e8\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '台湾', '[\"--\\u65e0--\",\"\\u53f0\\u6e7e\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '福建', '[\"--\\u65e0--\",\"\\u798f\\u5dde\",\"\\u9f99\\u5ca9\",\"\\u5357\\u5e73\",\"\\u5b81\\u5fb7\",\"\\u8386\\u7530\",\"\\u6cc9\\u5dde\",\"\\u4e09\\u660e\",\"\\u53a6\\u95e8\",\"\\u6f33\\u5dde\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '广西', '[\"--\\u65e0--\",\"\\u767e\\u8272\",\"\\u5317\\u6d77\",\"\\u5d07\\u5de6\",\"\\u9632\\u57ce\\u6e2f\",\"\\u8d35\\u6e2f\",\"\\u6842\\u6797\",\"\\u6cb3\\u6c60\",\"\\u8d3a\\u5dde\",\"\\u6765\\u5bbe\",\"\\u67f3\\u5dde\",\"\\u5357\\u5b81\",\"\\u94a6\\u5dde\",\"\\u68a7\\u5dde\",\"\\u7389\\u6797\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '海南', '[\"--\\u65e0--\",\"\\u6d77\\u53e3\",\"\\u4e09\\u4e9a\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '河北', '[\"--\\u65e0--\",\"\\u4fdd\\u5b9a\",\"\\u6ca7\\u5dde\",\"\\u627f\\u5fb7\",\"\\u90af\\u90f8\",\"\\u8861\\u6c34\",\"\\u5eca\\u574a\",\"\\u79e6\\u7687\\u5c9b\",\"\\u77f3\\u5bb6\\u5e84\",\"\\u5510\\u5c71\",\"\\u90a2\\u53f0\",\"\\u5f20\\u5bb6\\u53e3\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '安徽', '[\"--\\u65e0--\",\"\\u5b89\\u5e86\",\"\\u868c\\u57e0\",\"\\u4eb3\\u5dde\",\"\\u5de2\\u6e56\",\"\\u6c60\\u5dde\",\"\\u6ec1\\u5dde\",\"\\u961c\\u9633\",\"\\u5408\\u80a5\",\"\\u6dee\\u5317\",\"\\u6dee\\u5357\",\"\\u9ec4\\u5c71\",\"\\u516d\\u5b89\",\"\\u9a6c\\u978d\\u5c71\",\"\\u5bbf\\u5dde\",\"\\u94dc\\u9675\",\"\\u829c\\u6e56\",\"\\u5ba3\\u57ce\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '甘肃', '[\"--\\u65e0--\",\"\\u767d\\u94f6\",\"\\u5b9a\\u897f\",\"\\u7518\\u5357\",\"\\u5609\\u5cea\\u5173\",\"\\u91d1\\u660c\",\"\\u9152\\u6cc9\",\"\\u5170\\u5dde\",\"\\u4e34\\u590f\",\"\\u9647\\u5357\",\"\\u5e73\\u51c9\",\"\\u5e86\\u9633\",\"\\u5929\\u6c34\",\"\\u6b66\\u5a01\",\"\\u5f20\\u6396\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '广东', '[\"--\\u65e0--\",\"\\u6f6e\\u5dde\",\"\\u4e1c\\u839e\",\"\\u4f5b\\u5c71\",\"\\u5e7f\\u5dde\",\"\\u6cb3\\u6e90\",\"\\u60e0\\u5dde\",\"\\u6c5f\\u95e8\",\"\\u63ed\\u9633\",\"\\u8302\\u540d\",\"\\u6885\\u5dde\",\"\\u6e05\\u8fdc\",\"\\u6c55\\u5934\",\"\\u6c55\\u5c3e\",\"\\u97f6\\u5173\",\"\\u6df1\\u5733\",\"\\u9633\\u6c5f\",\"\\u4e91\\u6d6e\",\"\\u6e5b\\u6c5f\",\"\\u8087\\u5e86\",\"\\u4e2d\\u5c71\",\"\\u73e0\\u6d77\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter;

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '贵州', '[\"--\\u65e0--\",\"\\u5b89\\u987a\",\"\\u6bd5\\u8282\",\"\\u8d35\\u9633\",\"\\u516d\\u76d8\\u6c34\",\"\\u9ed4\\u4e1c\\u5357\",\"\\u9ed4\\u5357\",\"\\u9ed4\\u897f\\u5357\",\"\\u94dc\\u4ec1\",\"\\u9075\\u4e49\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '河南', '[\"--\\u65e0--\",\"\\u5b89\\u9633\",\"\\u9e64\\u58c1\",\"\\u7126\\u4f5c\",\"\\u5f00\\u5c01\",\"\\u6d1b\\u9633\",\"\\u6f2f\\u6cb3\",\"\\u5357\\u9633\",\"\\u5e73\\u9876\\u5c71\",\"\\u6fee\\u9633\",\"\\u4e09\\u95e8\\u5ce1\",\"\\u5546\\u4e18\",\"\\u65b0\\u4e61\",\"\\u4fe1\\u9633\",\"\\u8bb8\\u660c\",\"\\u90d1\\u5dde\",\"\\u5468\\u53e3\",\"\\u9a7b\\u9a6c\\u5e97\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '黑龙江', '[\"--\\u65e0--\",\"\\u5927\\u5e86\",\"\\u5927\\u5174\\u5b89\\u5cad\",\"\\u54c8\\u5c14\\u6ee8\",\"\\u9e64\\u5c97\",\"\\u9ed1\\u6cb3\",\"\\u9e21\\u897f\",\"\\u4f73\\u6728\\u65af\",\"\\u7261\\u4e39\\u6c5f\",\"\\u4e03\\u53f0\\u6cb3\",\"\\u9f50\\u9f50\\u54c8\\u5c14\",\"\\u53cc\\u9e2d\\u5c71\",\"\\u7ee5\\u5316\",\"\\u4f0a\\u6625\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '湖北', '[\"--\\u65e0--\",\"\\u9102\\u5dde\",\"\\u6069\\u65bd\",\"\\u9ec4\\u5188\",\"\\u9ec4\\u77f3\",\"\\u8346\\u95e8\",\"\\u8346\\u5dde\",\"\\u5341\\u5830\",\"\\u968f\\u5dde\",\"\\u6b66\\u6c49\",\"\\u54b8\\u5b81\",\"\\u8944\\u6a0a\",\"\\u5b5d\\u611f\",\"\\u5b9c\\u660c\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '吉林', '[\"--\\u65e0--\",\"\\u767d\\u57ce\",\"\\u767d\\u5c71\",\"\\u957f\\u6625\",\"\\u5409\\u6797\",\"\\u8fbd\\u6e90\",\"\\u56db\\u5e73\",\"\\u677e\\u539f\",\"\\u901a\\u5316\",\"\\u5ef6\\u8fb9\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '江苏', '[\"--\\u65e0--\",\"\\u5e38\\u5dde\",\"\\u6dee\\u5b89\",\"\\u8fde\\u4e91\\u6e2f\",\"\\u5357\\u4eac\",\"\\u5357\\u901a\",\"\\u82cf\\u5dde\",\"\\u5bbf\\u8fc1\",\"\\u6cf0\\u5dde\",\"\\u65e0\\u9521\",\"\\u5f90\\u5dde\",\"\\u76d0\\u57ce\",\"\\u626c\\u5dde\",\"\\u9547\\u6c5f\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '辽宁', '[\"--\\u65e0--\",\"\\u978d\\u5c71\",\"\\u672c\\u6eaa\",\"\\u671d\\u9633\",\"\\u5927\\u8fde\",\"\\u4e39\\u4e1c\",\"\\u629a\\u987a\",\"\\u961c\\u65b0\",\"\\u846b\\u82a6\\u5c9b\",\"\\u9526\\u5dde\",\"\\u8fbd\\u9633\",\"\\u76d8\\u9526\",\"\\u6c88\\u9633\",\"\\u94c1\\u5cad\",\"\\u8425\\u53e3\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '内蒙古', '[\"--\\u65e0--\",\"\\u963f\\u62c9\\u5584\",\"\\u5df4\\u5f66\\u6dd6\\u5c14\",\"\\u5305\\u5934\",\"\\u8d64\\u5cf0\",\"\\u9102\\u5c14\\u591a\\u65af\",\"\\u547c\\u548c\\u6d69\\u7279\",\"\\u547c\\u4f26\\u8d1d\\u5c14\",\"\\u901a\\u8fbd\",\"\\u4e4c\\u6d77\",\"\\u4e4c\\u5170\\u5bdf\\u5e03\",\"\\u9521\\u6797\\u90ed\\u52d2\",\"\\u5174\\u5b89\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '宁夏', '[\"--\\u65e0--\",\"\\u56fa\\u539f\",\"\\u77f3\\u5634\\u5c71\",\"\\u5434\\u4e2d\",\"\\u94f6\\u5ddd\",\"\\u4e2d\\u536b\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '青海', '[\"--\\u65e0--\",\"\\u679c\\u6d1b\",\"\\u6d77\\u5317\",\"\\u6d77\\u4e1c\",\"\\u6d77\\u5357\",\"\\u6d77\\u897f\",\"\\u9ec4\\u5357\",\"\\u897f\\u5b81\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '山东', '[\"--\\u65e0--\",\"\\u6ee8\\u5dde\",\"\\u5fb7\\u5dde\",\"\\u4e1c\\u8425\",\"\\u83cf\\u6cfd\",\"\\u6d4e\\u5357\",\"\\u6d4e\\u5b81\",\"\\u83b1\\u829c\",\"\\u804a\\u57ce\",\"\\u4e34\\u6c82\",\"\\u9752\\u5c9b\",\"\\u65e5\\u7167\",\"\\u6cf0\\u5b89\",\"\\u5a01\\u6d77\",\"\\u6f4d\\u574a\",\"\\u70df\\u53f0\",\"\\u67a3\\u5e84\",\"\\u6dc4\\u535a\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '湖南', '[\"--\\u65e0--\",\"\\u957f\\u6c99\",\"\\u5e38\\u5fb7\",\"\\u90f4\\u5dde\",\"\\u8861\\u9633\",\"\\u6000\\u5316\",\"\\u5a04\\u5e95\",\"\\u90b5\\u9633\",\"\\u6e58\\u6f6d\",\"\\u6e58\\u897f\",\"\\u76ca\\u9633\",\"\\u6c38\\u5dde\",\"\\u5cb3\\u9633\",\"\\u5f20\\u5bb6\\u754c\",\"\\u682a\\u6d32\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '江西', '[\"--\\u65e0--\",\"\\u629a\\u5dde\",\"\\u8d63\\u5dde\",\"\\u5409\\u5b89\",\"\\u666f\\u5fb7\\u9547\",\"\\u4e5d\\u6c5f\",\"\\u5357\\u660c\",\"\\u840d\\u4e61\",\"\\u4e0a\\u9976\",\"\\u65b0\\u4f59\",\"\\u5b9c\\u6625\",\"\\u9e70\\u6f6d\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '山西', '[\"--\\u65e0--\",\"\\u957f\\u6cbb\",\"\\u5927\\u540c\",\"\\u664b\\u57ce\",\"\\u664b\\u4e2d\",\"\\u4e34\\u6c7e\",\"\\u5415\\u6881\",\"\\u6714\\u5dde\",\"\\u592a\\u539f\",\"\\u5ffb\\u5dde\",\"\\u9633\\u6cc9\",\"\\u8fd0\\u57ce\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '陕西', '[\"--\\u65e0--\",\"\\u5b89\\u5eb7\",\"\\u5b9d\\u9e21\",\"\\u6c49\\u4e2d\",\"\\u5546\\u6d1b\",\"\\u94dc\\u5ddd\",\"\\u6e2d\\u5357\",\"\\u897f\\u5b89\",\"\\u54b8\\u9633\",\"\\u5ef6\\u5b89\",\"\\u6986\\u6797\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '四川', '[\"--\\u65e0--\",\"\\u6210\\u90fd\",\"\\u8fbe\\u5dde\",\"\\u5fb7\\u9633\",\"\\u7518\\u5b5c\",\"\\u5e7f\\u5b89\",\"\\u5e7f\\u5143\",\"\\u4e50\\u5c71\",\"\\u51c9\\u5c71\",\"\\u6cf8\\u5dde\",\"\\u7709\\u5c71\",\"\\u7ef5\\u9633\",\"\\u5185\\u6c5f\",\"\\u5357\\u5145\",\"\\u6500\\u679d\\u82b1\",\"\\u9042\\u5b81\",\"\\u96c5\\u5b89\",\"\\u5b9c\\u5bbe\",\"\\u8d44\\u9633\",\"\\u81ea\\u8d21\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '西藏', '[\"--\\u65e0--\",\"\\u963f\\u91cc\",\"\\u660c\\u90fd\",\"\\u62c9\\u8428\",\"\\u6797\\u829d\",\"\\u90a3\\u66f2\",\"\\u65e5\\u5580\\u5219\",\"\\u5c71\\u5357\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '新疆', '[\"--\\u65e0--\",\"\\u963f\\u514b\\u82cf\",\"\\u963f\\u62c9\\u5c14\",\"\\u963f\\u52d2\\u6cf0\",\"\\u5df4\\u97f3\\u90ed\\u695e\",\"\\u535a\\u5c14\\u5854\\u62c9\",\"\\u660c\\u5409\",\"\\u54c8\\u5bc6\",\"\\u548c\\u7530\",\"\\u5580\\u4ec0\",\"\\u514b\\u62c9\\u739b\\u4f9d\",\"\\u514b\\u5b5c\\u52d2\\u82cf\",\"\\u77f3\\u6cb3\\u5b50\",\"\\u5854\\u57ce\",\"\\u56fe\\u6728\\u8212\\u514b\",\"\\u5410\\u9c81\\u756a\",\"\\u4e4c\\u9c81\\u6728\\u9f50\",\"\\u4e94\\u5bb6\\u6e20\",\"\\u4f0a\\u7281\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '云南', '[\"--\\u65e0--\",\"\\u5b9d\\u5c71\",\"\\u695a\\u96c4\",\"\\u5927\\u7406\",\"\\u5fb7\\u5b8f\",\"\\u8fea\\u5e86\",\"\\u7ea2\\u6cb3\",\"\\u6606\\u660e\",\"\\u4e3d\\u6c5f\",\"\\u4e34\\u6ca7\",\"\\u6012\\u6c5f\",\"\\u66f2\\u9756\",\"\\u601d\\u8305\",\"\\u6587\\u5c71\",\"\\u897f\\u53cc\\u7248\\u7eb3\",\"\\u7389\\u6eaa\",\"\\u662d\\u901a\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
select @id+1,18,'bill_state', 'bill_city', '浙江', '[\"--\\u65e0--\",\"\\u676d\\u5dde\",\"\\u6e56\\u5dde\",\"\\u5609\\u5174\",\"\\u91d1\\u534e\",\"\\u4e3d\\u6c34\",\"\\u5b81\\u6ce2\",\"\\u8862\\u5dde\",\"\\u7ecd\\u5174\",\"\\u53f0\\u5dde\",\"\\u6e29\\u5dde\",\"\\u821f\\u5c71\"]' from dual
where not exists(select 1 from ld_picklist_dependency where id=@id+1); 
delimiter; 

select max(id) into @id from ld_picklist_dependency;
update ld_picklist_dependency_seq set id=@id;
delimiter; 

call addcolumn('ld_expensetype','presence','int','10',1);
call addcolumn('ld_expensetype','picklist_valueid','int','19',0);
CREATE TABLE  if not exists `ld_expensetype_seq` (
  `id` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='expensetype');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'expensetype'  from dual where not exists(select 1 from LD_picklist where name='expensetype');
delimiter;
insert into LD_expensetype_seq  (id) select 0 from dual where not exists(select 1 from LD_expensetype_seq);
delimiter;

select  id into @seqmaxid from LD_expensetype_seq ;
update LD_expensetype_seq set id=@seqmaxid+2 where not exists(select 1 from LD_expensetype where expensetype='餐饮' and (picklist_valueid is null or picklist_valueid<=0) );
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from LD_expensetype where expensetype='餐饮'  and (picklist_valueid is null or picklist_valueid<=0) );
update LD_expensetype set  picklist_valueid=@maxid+1,presence=1  where expensetype='餐饮'  and (picklist_valueid is null or picklist_valueid<=0)  ;
delimiter;

select  id into @seqmaxid from LD_expensetype_seq ;
update LD_expensetype_seq set id=@seqmaxid+2 where not exists(select 1 from LD_expensetype where expensetype='交通' and (picklist_valueid is null or picklist_valueid<=0) );
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from LD_expensetype where expensetype='交通'  and (picklist_valueid is null or picklist_valueid<=0) );
update LD_expensetype set  picklist_valueid=@maxid+1,presence=1  where expensetype='交通'  and (picklist_valueid is null or picklist_valueid<=0) ;
delimiter;

select  id into @seqmaxid from LD_expensetype_seq ;
update LD_expensetype_seq set id=@seqmaxid+2 where not exists(select 1 from LD_expensetype where expensetype='通讯' and (picklist_valueid is null or picklist_valueid<=0));
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from LD_expensetype where expensetype='通讯'  and (picklist_valueid is null or picklist_valueid<=0) );
update LD_expensetype set  picklist_valueid=@maxid+1 ,presence=1 where expensetype='通讯'  and (picklist_valueid is null or picklist_valueid<=0) ;
delimiter;

select  id into @seqmaxid from LD_expensetype_seq ;
update LD_expensetype_seq set id=@seqmaxid+2 where not exists(select 1 from LD_expensetype where expensetype='礼品' and (picklist_valueid is null or picklist_valueid<=0) );
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from LD_expensetype where expensetype='礼品'  and (picklist_valueid is null or picklist_valueid<=0) );
update LD_expensetype set  picklist_valueid=@maxid+1 ,presence=1 where expensetype='礼品'  and (picklist_valueid is null or picklist_valueid<=0) ;
delimiter;
select  id into @seqmaxid from LD_expensetype_seq ;
update LD_expensetype_seq set id=@seqmaxid+2 where not exists(select 1 from LD_expensetype where expensetype='办公' and (picklist_valueid is null or picklist_valueid<=0) );
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from LD_expensetype where expensetype='办公'  and (picklist_valueid is null or picklist_valueid<=0) );
update LD_expensetype set  picklist_valueid=@maxid+1,presence=1  where expensetype='办公'  and (picklist_valueid is null or picklist_valueid<=0) ;
delimiter;

select  id into @seqmaxid from LD_expensetype_seq ;
update LD_expensetype_seq set id=@seqmaxid+2 where not exists(select 1 from LD_expensetype where expensetype='活动' and (picklist_valueid is null or picklist_valueid<=0) );
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from LD_expensetype where expensetype='活动'  and (picklist_valueid is null or picklist_valueid<=0) );
update LD_expensetype set  picklist_valueid=@maxid+1,presence=1  where expensetype='活动'  and (picklist_valueid is null or picklist_valueid<=0) ;
delimiter;

select  id into @seqmaxid from LD_expensetype_seq ;
update LD_expensetype_seq set id=@seqmaxid+2 where not exists(select 1 from LD_expensetype where expensetype='其他' and (picklist_valueid is null or picklist_valueid<=0) );
select  id into @maxid from ld_picklistvalues_seq;

update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from LD_expensetype where expensetype='其他'  and (picklist_valueid is null or picklist_valueid<=0) );
update LD_expensetype set  picklist_valueid=@maxid+1,presence=1  where expensetype='其他'  and (picklist_valueid is null or picklist_valueid<=0) ;
delimiter;

update LD_field set masseditable=0 where tabid in(select tabid from LD_tab where name='paymentplan');
update LD_expensetype_seq set id=7 where id<7;
delimiter;

update LD_field set masseditable=1 where tabid in(select tabid from LD_tab where name='paymentplan') and (columnname='smownerid' or columnname='amount');
update LD_products set costprice=0 where costprice is null;
delimiter;

update ld_users set approvestatus = 1 where approveby is null;
delimiter;

update ld_version set old_version='V3.0',current_version='V3.0',remark='V3.0-20131030';
delimiter;