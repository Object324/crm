select tabid into @tabid from ld_tab where `name`='CashBack';
select max(sequence) into @seq from  ld_blocks where tabid=@tabid;
update ld_blocks set sequence=@seq+1 where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
update ld_field set masseditable=0 where tabid=@tabid;
update ld_field set masseditable=0 where columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseCashBack';
update ld_field set masseditable=0 where tabid=@tabid;
delimiter;

update ld_desk set fieldlabel='确定要删除选定的' where labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' and languagetype='zh';
update ld_desk set fieldlabel='Are you sure you want to delete the selected' where labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' and languagetype='en';
update ld_desk set fieldlabel='Are you sure you want to delete the selected ' where labelbol='REMOVEWILLDELETEOTHER' and languagetype='en' and Labeltype='jspop';

update ld_settings_field set active=1 where `name`='LBL_AUDIT_TRAIL';

select tabid into @tabid from ld_tab where `name`='ContactRecords';
update ld_field set quickcreatesequence=quickcreatesequence+30 where tabid=@tabid and presence<>1 and quickcreate=0;
update ld_field set quickcreatesequence=1 where tabid=@tabid and columnname='subject';
update ld_field set quickcreatesequence=2 where tabid=@tabid and columnname='contactrecordtype';
update ld_field set quickcreatesequence=3 where tabid=@tabid and columnname='contactdate';
update ld_field set quickcreatesequence=4 where tabid=@tabid and columnname='nextcontactdate';
update ld_field set quickcreatesequence=5 where tabid=@tabid and columnname='accountid';
update ld_field set quickcreatesequence=6 where tabid=@tabid and columnname='contactid';
update ld_field set quickcreatesequence=7 where tabid=@tabid and columnname='potentialid';
update ld_field set quickcreatesequence=8 where tabid=@tabid and columnname='smownerid';
update ld_field set quickcreatesequence=9 where tabid=@tabid and columnname='content';
set @i=0;
update ld_field set quickcreatesequence=(@i:=@i+1) where tabid=@tabid and presence<>1 and quickcreate=0 order by quickcreatesequence;
delimiter;

update ld_templatesrole set roleid=profileid where roleid like 'H%';
update ld_systems_deploy set deploy_value=1,description='有关联单据时是否允许删除客户。1:不允许，0:允许' where deploy_type=69;
update ld_systems_deploy set deploy_value=1 where deploy_type=57 and not exists (select 1 from ld_salesorder);

select tabid into @tabid from ld_tab where `name`='ServiceContracts';
select block into @blockid from ld_field where tabid=@tabid and columnname='contactid';
set @tablename='ld_servicecontracts';
set @columnname='potentialid';
set @fieldname='potential_id';
set @zh='销售机会';
set @en='销售机会';
set @uitype=76;

select sequence into @seq from ld_field where tabid=@tabid and columnname='contactid';
update ld_field set sequence=sequence+2 where tabid=@tabid and block=@blockid and sequence>@seq; 

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@seq+1,@blockid,1,'I~O',3,NULL,'BAS',1,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

update ld_field_seq set id=(select max(fieldid) from ld_field); 
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


call AddColumn(@tablename,@columnname,'int','19',null);
delimiter;

select tabid into @tabid from ld_tab where `name`='HelpDesk';
select block into @blockid from ld_field where tabid=@tabid and columnname='contactid';
set @tablename='ld_troubletickets';
set @columnname='potentialid';
set @fieldname='potential_id';
set @zh='销售机会';
set @en='销售机会';
set @uitype=76;

select sequence into @seq from ld_field where tabid=@tabid and columnname='contactid';
update ld_field set sequence=sequence+2 where tabid=@tabid and block=@blockid and sequence>@seq; 

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@seq+1,@blockid,1,'I~O',3,NULL,'BAS',1,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

update ld_field_seq set id=(select max(fieldid) from ld_field); 

set @i=0;
update ld_field set sequence=1000 where tabid=@tabid and columnname='ticket_no';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


call AddColumn(@tablename,@columnname,'int','19',null);
delimiter;

select usereportid into @id from ld_usereport where name='Performancestatisticscollection';
SELECT max(Sequence)+1 into @Sequence FROM ld_usereportcolumns WHERE usereportid=@id;
insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:description:description:CashBill_description:V', 
@Sequence, 1, 'ld_cashbill:description:description:CashBill_备注:V','ld_cashbill:description:description:CashBill_description:V'   
from dual where not exists(select 1 from ld_usereportcolumns 
where Usereportid=@id and realcolumns like 'ld_cashbill:description:description:CashBill_%');
delimiter;

insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 3);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 11);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 1);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 13);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 12);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 2);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 6);
delimiter;

update ld_field  set displaytype=1 where tabid=29   and columnname='approvestatus';
delimiter;

SELECT id INTO @id FROM ld_relatedlists_seq;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid = @tabid;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,actions)
SELECT @id+1,@tabid,0,'get_singin',@sequence+1,'Singin',''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists  WHERE tabid = @tabid AND NAME = 'get_singin');
UPDATE ld_relatedlists_seq SET id = (SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','Singin','签到记录','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='Singin' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','Singin','Singin record','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='Singin' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SINGINADDRESS','签到地点','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SINGINADDRESS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SINGINADDRESS','Sign in place','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SINGINADDRESS' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SINGINREMARKS','签到说明','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SINGINREMARKS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SINGINREMARKS','Sign Remarks','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SINGINREMARKS' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SIGNINACCOUNT','签到人','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SIGNINACCOUNT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SIGNINACCOUNT','Sign Account','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SIGNINACCOUNT' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SIGNTIME','签到时间','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SIGNTIME' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SIGNTIME','Sign Time','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SIGNTIME' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','ERRORDISTANCE','误差距离(米)','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='ERRORDISTANCE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','ERRORDISTANCE','Error distance (meter)','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='ERRORDISTANCE' AND Labeltype='fixedstr');
delimiter;
-- 2015-07-22

update ld_relatedlists set sequence=sequence+50 where tabid=6;
update ld_relatedlists set sequence=1 where tabid=6 and `name`='get_WorkReport';
update ld_relatedlists set sequence=2 where tabid=6 and `name`='get_singin';
update ld_relatedlists set sequence=3 where tabid=6 and `name`='get_balanceofaccount';
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=6 order by sequence;
delimiter;

update ld_tab set printtab=1 where `name` in ('ServiceContracts','Campaigns','Potentials','ProjectMilestone','Accounts');
update ld_tab set printtab=1 where `name` in ('CashBill','SendCashBill','Vendors','VendorContact','=VendorContactRecords');
update ld_tab set printtab=1 where `name` in ('ContactRecords','PublicAnnouncement','Contacts','ContactRecords');
update ld_quickactions set presence=0 where related_tabid='-5';

select tabid into @tabid from ld_tab where `name`='Accounts';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;

select tabid into @tabid from ld_tab where `name`='Contacts';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;


select tabid into @tabid from ld_tab where `name`='ContactRecords';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;


select tabid into @tabid from ld_tab where `name`='Vendors';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;

select tabid into @tabid from ld_tab where `name`='VendorContact';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;

select tabid into @tabid from ld_tab where `name`='VendorContactRecords';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');

select tabid into @tabid from ld_tab where `name`='PublicAnnouncement';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');

select tabid into @tabid from ld_tab where `name`='PublicAnnouncement';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');

DELETE FROM ld_desk WHERE labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' AND labeltype='jspop';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','DELETESUPPLIERSWILLDELETEPURCHASEORDERS','确定要删除选定的','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' 
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','DELETESUPPLIERSWILLDELETEPURCHASEORDERS','You sure you want to delete the selected','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' 
and Labeltype='jspop');

select usereportid into @id from ld_usereport where name='Salesforecastandanalysistable';
insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_potential:potential_no:potential_no:potentials_potential_no:V', 
6, 1, 'ld_potential:potential_no:potential_no:Potentials_销售编号:V',
'ld_potential:potential_no:potential_no:Potentials_potential no:V'   
from dual where not exists(select 1 from ld_usereportcolumns 
where Usereportid=@id and realcolumns like 'ld_potential:potential_no:potential_no:Potentials_%');
delimiter;
UPDATE ld_tab SET printtab=0 WHERE name in ('PublicAnnouncement','LessionPlan');
delimiter;
select tabid into @tabid from ld_tab where `name`='PurchaseCashBack';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5'); 
update ld_tab set printtab=1 where `name` in ('PurchaseCashBack');
delimiter;

update ld_producttoolfield set defaultcolumn = 2 where input_type=0 and columnname='total' and newline = 1;
delimiter;
update ld_producttoolfield set defaultcolumn = 3 where input_type=1 and columnname='productcost' and defaultcolumn > 0;
delimiter;
update ld_producttoolfield set defaultcolumn = 3 where input_type=0 and columnname='grossprofit' and defaultcolumn > 0;
delimiter;
update ld_producttoolfield set defaultcolumn = 3 where input_type=0 and columnname='servicecontracts_start_date' and defaultcolumn > 0;
delimiter;
update ld_producttoolfield set defaultcolumn = 3 where input_type=2 and columnname='servicecontracts_end_date' and defaultcolumn > 0;
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
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_expense:expense_no:expense_no:Expense_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_expense:expensedate:expensedate:Expense_报销日期:D' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_expense:smownerid:assigned_user_id:Expense_负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_expense:approvestatus:approvestatus:Expense_状态:V' );
delimiter;
-- 2015-07-23


select actionid INTO @actionid from ld_actionmapping WHERE actionname='Updatestate';
select tabid INTO @tabid from ld_tab where `name` in ('Invoice');
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual 
where not EXISTS(select 1 from ld_profileallpermission  where tabid = @tabid and operation = @actionid);
delimiter;

select actionid INTO @actionid from ld_actionmapping WHERE actionname='Updatestate';
select tabid INTO @tabid from ld_tab where `name` in ('PurchaseInvoice');
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual 
where not EXISTS(select 1 from ld_profileallpermission  where tabid = @tabid and operation = @actionid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 4);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 11);
delimiter;

insert into ld_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 14);
delimiter;

insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 2);
delimiter;

insert into ld_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 6);
delimiter;
-- 2015-07-24

update ld_producttoolfield set fieldlabel='合计' where columnname='total' and fieldlabel='价税合计';
update ld_tranlabel set fieldlabel='合计' where  trantable='ld_producttoolfield' and languagetype='zh' and fieldlabel='价税合计'
and Relateid in (select producttoolfieldid from ld_producttoolfield where columnname='total');
update ld_tranlabel set fieldlabel='Total' where  trantable='ld_producttoolfield' and languagetype='en' and fieldlabel='Price Tax Total'
and Relateid in (select producttoolfieldid from ld_producttoolfield where columnname='total');

DROP PROCEDURE IF EXISTS `update_producttoolfield_taxname`;
delimiter ||
CREATE  PROCEDURE `update_producttoolfield_taxname`(
)
BEGIN 
		
		declare tmp_taxname varchar(200) default NULL;
		declare tmp_taxlabel varchar(200) default NULL;
		
		declare mycursor cursor for select taxname,taxlabel from ld_inventorytaxinfo; 
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_taxname = NULL;

		open mycursor;
		fetch mycursor into tmp_taxname,tmp_taxlabel;
		while(tmp_taxname is not null) DO
			
			update ld_producttoolfield set fieldlabel=CONCAT('税(',tmp_taxlabel,')') where columnname=tmp_taxname and fieldlabel=tmp_taxlabel;
			update ld_tranlabel set fieldlabel=CONCAT('税(',tmp_taxlabel,')') where trantable='ld_producttoolfield' and languagetype='zh' and fieldlabel=tmp_taxlabel
			and Relateid in (select producttoolfieldid from ld_producttoolfield where columnname=tmp_taxname);
		
			fetch mycursor into tmp_taxname,tmp_taxlabel;
	end while;
	close mycursor;

end ||
delimiter; 

call update_producttoolfield_taxname();
delimiter; 

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_activity';
set @columnname='smcreatorid';
set @fieldname='creator';
set @zh='创建人';
set @en='Creator';
set @uitype=52;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@seq+1,@blockid,2,'V~O',1,NULL,'BAS',1,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'int','11',0);
delimiter;

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_activity';
set @columnname='modifiedby';
set @fieldname='modifiedby';
set @zh='最新更新人';
set @en='Modified By';
set @uitype=52;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@seq+1,@blockid,2,'V~O',1,NULL,'BAS',1,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'int','11',0);
delimiter;

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
update ld_field set sequence=@seq+1 where tabid=@tabid and columnname='smcreatorid';
update ld_field set sequence=@seq+2 where tabid=@tabid and columnname='createdtime';
update ld_field set sequence=@seq+3 where tabid=@tabid and columnname='modifiedby';
update ld_field set sequence=@seq+4 where tabid=@tabid and columnname='modifiedtime';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

update ld_field set masseditable=0 where tabid=6 and columnname='lastorderdate';
update ld_desk set fieldlabel='步骤' where labelbol='Stage' and languagetype='zh' and Labeltype='fixedstr';
update ld_producttoolfield set defaultcolumn=2 where columnname='taxprice';
update ld_producttoolfield set defaultcolumn=2 where columnname='total';
-- 2015-07-27

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','My','我的','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='My' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','My','My ','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='My' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','exporttemplate','导出模板','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='exporttemplate' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','exporttemplate',' export template','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='exporttemplate' 
and Labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence)
select '100,100',75,'设置系统打印图片的尺寸,格式为(宽，高)',114 from DUAL where not EXISTS(select * from ld_systems_deploy where deploy_type=75);

update ld_field set displaytype = 2 where fieldname in ('servicecasher','servicegroup','modifiedby');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastorderdate';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastcontactdate';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastcontent';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'publicaccount';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'ServiceContractscreator';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'total_units';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastorderdate';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastcontactdate';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastcontent';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'servicegroup';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'stockpresence';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'purchasestatus';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'cashbilldate';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'stockpresence';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContact';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContactRecords';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'modifiedtime';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'modifiedtime';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectMilestone';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'modifiedtime';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Checks';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'presence';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'subsmownerid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'presence';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'subsmownerid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PutCash';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashDeposit';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'modifiedtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'qtyinstock';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'procreator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_DEFAULTVALUE','默认值','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_DEFAULTVALUE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_DEFAULTVALUE','Default','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_DEFAULTVALUE' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRECISIONVALUE','精度','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'PRECISIONVALUE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRECISIONVALUE','PrecisionValue','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'PRECISIONVALUE' and labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
update ld_producttoolfield set edit_permission = 0 
where tabid = @tabid and defaultcolumn = 2 and columnname = 'quantity';
delimiter;

select tabid into @tabid from ld_field where tabid = 96 and issmownerid = 1;
update ld_field set issmownerid = 1 where fieldname = 'smcreatorid' and tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
update ld_field set displaytype = 2 where tabid = @tabid and fieldname = 'reltab';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Productbom';
update ld_field set displaytype = 2 where tabid = @tabid and fieldname = 'hdnGrandTotal';
delimiter;
-- 2015-07-29

update ld_desk set fieldlabel = 'SQL脚本任务' 
where labelbol = 'LBL_AUTOMATICTASK_SQL' and languagetype='zh' and labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = '普通任务' 
where labelbol = 'LBL_AUTOMATICTASK_CUSTOMIZED' and languagetype='zh' and labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel="本次收款金额" 
where labelbol = 'THEAMOUNTCOLLECTED' and labeltype = 'fixedstr' and languagetype = 'zh';
delimiter;

update ld_producttoolfield set typeofdata = 'V~O~100' where columnname = 'product_no' and defaultcolumn = 4;
delimiter;
-- 2015-07-30

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_activity';
set @columnname='approvestatus';
set @fieldname='approvestatus';
set @zh='审批状态';
set @en='Approve Status';
set @uitype=130;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=0;
  
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

call AddColumn(@tablename,@columnname,'varchar','100','未提交');
delimiter;

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_activity';
set @columnname='approveby';
set @fieldname='approveby';
set @zh='审批人';
set @en='Approve By';
set @uitype=131;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=0;
  
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

call AddColumn(@tablename,@columnname,'int','1','0');
delimiter;

update ld_producttoolfield set defaultcolumn=2 where columnname='tax_amount';

call AddColumn('ld_userlogincheck','type','int','10',1);
delimiter;
update ld_userlogincheck set type = 1 where type is null;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','SELECTHASRECEIVINGDELETINGFAILED','您选择的记录有已收款或者部分已收款的单据，删除失败！','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTHASRECEIVINGDELETINGFAILED' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','SELECTHASRECEIVINGDELETINGFAILED','The records you choose has receivable or part of documents,delete failed!','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SELECTHASRECEIVINGDELETINGFAILED' 
and Labeltype='fixedstr');
-- 2015-07-31

UPDATE ld_field SET displaytype=2 WHERE tabid=(select tabid FROM ld_tab WHERE name='Productbom') AND columnname='total';
delimiter;
update ld_producttoolfield set defaultvalue=NULL where columnname='comment';
-- 2015-08-03

update ld_desk set fieldlabel='导出类型' where labelbol='ExportRecordType' and languagetype='zh' and Labeltype='fixedstr';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DECIMALCANNOTBEEMPTY','小数点不能为空','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DECIMALCANNOTBEEMPTY' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DECIMALCANNOTBEEMPTY','decimal can not be empty','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DECIMALCANNOTBEEMPTY' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','SERVICEINFOREMIND2','( {$HelpDesk.HelpDesk}明细界面 )','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SERVICEINFOREMIND2' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','SERVICEINFOREMIND2','( {$HelpDesk.HelpDesk} detail interface )','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SERVICEINFOREMIND2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','SERVICEINFOREMIND3','( {$Accounts.Accounts}明细界面 )','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SERVICEINFOREMIND3' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','SERVICEINFOREMIND3','( {$Accounts.Accounts} detail interface )','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SERVICEINFOREMIND3' and Labeltype='fixedstr');
delimiter;

UPDATE ld_field SET displaytype=3 WHERE tabid=(select tabid FROM ld_tab WHERE name='Productbom') AND columnname='total';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','PAYMENTRECORDPARITIALLYDELETEFAILED','您选择的记录有已付款或者部分已付款的单据，删除失败！','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PAYMENTRECORDPARITIALLYDELETEFAILED' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','PAYMENTRECORDPARITIALLYDELETEFAILED','The records you choose has receivable or part of documents,delete failed!','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PAYMENTRECORDPARITIALLYDELETEFAILED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PickList','下拉框','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PickList' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PickList','PickList','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PickList' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'adjustment' and uitype = 35;
update ld_tranlabel set fieldlabel = '调整' where tabid = @tabid and relateid = @producttoolfieldid and languagetype = 'zh';
delimiter;
update ld_tranlabel set fieldlabel = 'Adjustment' where tabid = @tabid and relateid = @producttoolfieldid and languagetype = 'en';
delimiter;

UPDATE ld_field SET displaytype=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='ServiceCharge') AND columnname='servicecasher';
delimiter;

alter table ld_templateprint change templateprintid templateprintid int(11);
delete from ld_templateprint where templateprintid=0;
alter table ld_templateprint change templateprintid templateprintid int(19) auto_increment;

select tabid into @tabid from ld_tab where `name`='ServiceContracts';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'ServiceContractsDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='ServiceContractsDefault.html' and tabid=@tabid and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='CashBack';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'CashBackDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='CashBackDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseBack';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'PurchaseBackDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='PurchaseBackDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseCashBack';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'PurchaseCashBackDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='PurchaseCashBackDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseInvoice';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'PurchaseInvoiceDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='PurchaseInvoiceDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='SendPayment';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'SendPaymentDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='SendPaymentDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='OutboundOrder';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'OutboundOrderDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='OutboundOrderDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='Stock';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'StockOrderDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='StockOrderDefault.html' and tabid=@tabid);
delimiter;


select tabid into @tabid from ld_tab where `name`='WareHouseTransfer';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'WareHouseTransferDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='WareHouseTransferDefault.html' and tabid=@tabid);
delimiter;


select tabid into @tabid from ld_tab where `name`='VendorContactRecords';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'VendorContactRecordsDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='VendorContactRecordsDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='CashBill';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'CashBillDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='CashBillDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='SendCashBill';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'SendCashBillDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='SendCashBillDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='Potentials';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'PotentialsDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='PotentialsDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='Events';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'CalendarDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='CalendarDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='Campaigns';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'CampaignsDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='CampaignsDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='Faq';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'FaqDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='FaqDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='Project';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'ProjectDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='ProjectDefault.html' and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name`='ProjectMilestone';
select fieldlabel into @fieldlabel from ld_tranlabel where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' limit 1;
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault)
select 'ProjectMilestoneDefault.html',@tabid,1,concat(@fieldlabel,'预置模板'),1 from dual 
where not exists (select 1 from ld_templateprint where printfilename='ProjectMilestoneDefault.html' and tabid=@tabid);
delimiter;

update ld_tab set presence=1 where `name`='Reports' and not exists (select reportid from ld_report where reportid>57);
set @fieldid=0;
select fieldid into @fieldid from ld_field where tabid=16 and columnname='crmid' and fieldname='parent_id';
delete from ld_field where fieldid=@fieldid;
delete from ld_tranlabel where Relateid=@fieldid and trantable='ld_field';
delimiter;

call getallprofile('Products');
call fieldprofile('Products');
delimiter;

call getallprofile('ServiceContracts');
call fieldprofile('ServiceContracts');
delimiter;

call getallprofile('HelpDesk');
call fieldprofile('HelpDesk');
delimiter;

call getallprofile('Events');
call fieldprofile('Events');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTEXCEL2003FILE','请选择Excel2003扩展名的文件','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASESELECTEXCEL2003FILE' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTEXCEL2003FILE','please Select the file for the Excel2003 extension','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASESELECTEXCEL2003FILE' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'adjustment' and uitype = 35;
update ld_tranlabel set fieldlabel = '调整' where tabid = @tabid and relateid = @producttoolfieldid and languagetype = 'zh';
delimiter;
update ld_tranlabel set fieldlabel = 'Adjustment' where tabid = @tabid and relateid = @producttoolfieldid and languagetype = 'en';
delimiter;
UPDATE ld_field SET displaytype=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='ServiceCharge') AND columnname='servicecasher';
delimiter;

update ld_desk set fieldlabel = '小数位数' where labelbol = 'Decimal' and languagetype ='zh' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Decimal Length' where labelbol = 'Decimal' and languagetype ='en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Decimal','小数位数','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'Decimal' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Decimal','Decimal Length','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'Decimal' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
-- 2015-08-05

call fieldprofile('Project');
delimiter;
call getallprofile('Project');
delimiter;
call fieldprofile('ProjectTask');
delimiter;
call getallprofile('ProjectTask');
delimiter;
call fieldprofile('ProjectMilestone');
delimiter;
call getallprofile('ProjectMilestone');
delimiter;

update ld_tab  set printtab=1 where tabid=14;
select tabid into @tabid from ld_tab where name='PurchaseCashBack';
insert into ld_quickactions (tabid,related_tabid,sequence,presence,label)
select  @tabid,'-5',3,0,'打印工具' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
update ld_tab  set printtab=1 where name='publicannouncement';
select tabid into @tabid from ld_tab where name='publicannouncement';
insert into ld_quickactions (tabid,related_tabid,sequence,presence,label)
select  @tabid,'-5',1,0,'打印工具' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
update ld_field set presence=1 where tabid in (select tabid from ld_tab where name='cashbill') and columnname='vendorid';
update ld_field set presence=1 where tabid in (select tabid from ld_tab where name='cashbill') and columnname='salesorder_id';
delimiter;

delete from ld_profileallpermission where tabid=16 and operation = 5;
insert into ld_profileallpermission (tabid,operation)
select 9,5 from dual where not exists (select 1 from ld_profileallpermission where tabid=9 and operation=5);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED','此记录已有关联信息不能删除','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED','The record for the correlation information cannot be deleted ','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INPUTTEXTMESSAGEPLEASETONOTENTERTHEFOLLOWKEYWORDS:TESTING','录入短信内容时，请不要输入非正式内容，否则收件人将无法收到该短信，例如：测试 ','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'INPUTTEXTMESSAGEPLEASETONOTENTERTHEFOLLOWKEYWORDS:TESTING' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INPUTTEXTMESSAGEPLEASETONOTENTERTHEFOLLOWKEYWORDS:TESTING','please Select the file for the Excel2003 extension','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'INPUTTEXTMESSAGEPLEASETONOTENTERTHEFOLLOWKEYWORDS:TESTING' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
-- 2015-08-06

select tabid into @tabid from ld_tab where `name`='Invoice';
update ld_field set presence = 1 where tabid = @tabid and columnname in ('customerno','salesorderid');
delimiter;
-- 2015-08-07

select tabid into @tabid from ld_tab where `name` = 'Checks';
update ld_producttoolfield set columnname = 'paperquantity',tablename = 'ld_inventoryproductrel' 
where tabid = @tabid and columnname = 'qtyinstock' and uitype = 11 and defaultcolumn = 3;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Checks';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield 
where tabid = @tabid and columnname = 'profitloss' and tablename = 'ld_inventoryproductrel' and defaultcolumn = 3 limit 1;
update ld_producttoolfield_formula set columnstring = "{formulavar:[{'lettervar':'a','column':'firmoffer'},{'lettervar':'b','column':'paperquantity'}]}" 
where producttoolfieldid = @producttoolfieldid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
update ld_field set displaytype = 1 where tabid = @tabid and columnname = 'reltab';
delimiter;

update ld_desk set fieldlabel = '合并字段' where languagetype = 'zh' and labeltype = 'fixedstr' and labelbol = 'MERGERECORDSIN';
delimiter;

select fieldid into @fieldid from ld_field where tabid = 16 and fieldname = 'potential_id';
update ld_tranlabel set fieldlabel = '销售机会' where tabid = 16 and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
update ld_tranlabel set fieldlabel = 'Potentail' where tabid = 16 and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
delimiter;
-- 2015-08-10

DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @colName=NULL;
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
		ELSEIF isdefault=0 THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, '(',columnlen,')' 'default 0 ');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;


set @tabid=14;
select block into @blockid from ld_field where tabid=@tabid and columnname='productname';
set @tablename='ld_products';
set @columnname='batchmanagement';
set @fieldname='batchmanagement';
set @zh='批次管理';
set @en='Batch Management';
set @uitype=56;
set @readonly=1;
set @presence=2;
set @defaultvalue=0;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select sequence into @seq from ld_field where tabid=@tabid and columnname='discontinued';
update ld_field set sequence=@seq+5 where tabid=@tabid and block=@blockid and sequence>@seq;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select sequence into @seq from ld_field where tabid=@tabid and columnname='discontinued';
update ld_field set sequence=@seq+5 where tabid=@tabid and block=@blockid and sequence>@seq;
update ld_field set sequence=@seq+1 where tabid=@tabid and block=@blockid and columnname='batchmanagement';
update ld_field set sequence=@seq+2 where tabid=@tabid and block=@blockid and columnname='approveby';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'int',1,0);
delimiter;

call fieldprofile('Products');
delimiter;
call getallprofile('Products');
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileAccounts' and entitytype='mobileAccounts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_account:accountname:accountname:Accounts_客户名称:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_account:createdtime:createdtime:Accounts_创建时间:D' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_account:bill_state:bill_state:Accounts_省份:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_account:bill_city:bill_city:Accounts_城市:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_account:bill_street:bill_street:Accounts_地址:V' );
delimiter;

update ld_salesorder set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_purchaseorder set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_servicecontracts set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_quotes set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_salesback set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_purchaseback set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_outboundorder set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_stock set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_purchaseinvoice set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_invoice set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_cashback set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;
update ld_purchasecashback set discount_amount = subtotal - subtotal*(1-discount_percent/100) where discount_amount = 0 and discount_percent > 0;
delimiter;

insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZH_LABELEXISTS','字段中文标签重复，是否继续？','fixedstr' from dual 
 where not EXISTS(select 1 from ld_desk where labelbol='ZH_LABELEXISTS' and languagetype='zh');
insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZH_LABELEXISTS','The same chinese label already exists, do you want to continue?','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ZH_LABELEXISTS' and languagetype='en');

insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EN_LABELEXISTS','字段英文标签重复，是否继续？','fixedstr' from dual 
 where not EXISTS(select 1 from ld_desk where labelbol='EN_LABELEXISTS' and languagetype='zh');
insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','EN_LABELEXISTS','The same english label already exists, do you want to continue?','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='EN_LABELEXISTS' and languagetype='en');
delimiter;
-- 2015-08-11

select tabid into @tabid from ld_tab where `name` = 'Checks';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'profitloss' and input_type = 2 and defaultcolumn = 3;
update ld_producttoolfield_formula set formulastring = 'a-(b)' where producttoolfieldid = @producttoolfieldid;
delimiter;
-- 2015-08-12

select tabid into @tabid from ld_tab where `name`='Productbom';
select sequence into @seq from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
update ld_producttoolfield set sequence=sequence+5 where tabid=@tabid and sequence>=@seq;
update ld_producttoolfield set sequence=@seq-1,uitype=1 where tabid=@tabid and columnname='unit_price';
set @i=0;
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

update ld_field set sequence=sequence+10 where tabid=19 and block=46;
update ld_field set sequence=1 where tabid=19 and block=46 and columnname='bookname';
update ld_field set sequence=2 where tabid=19 and block=46 and columnname='pricebook_no';
update ld_field set sequence=3 where tabid=19 and block=46 and columnname='currency_id';
update ld_field set sequence=4 where tabid=19 and block=46 and columnname='active';
update ld_field set sequence=5 where tabid=19 and block=46 and columnname='smownerid';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=19 and block=46 order by sequence;
delimiter;

update ld_producttoolfield set tablename = 'ld_productcf' where tablename = 'ld_products' and columnname like 'cf_%';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
update ld_field set presence = 1 where tabid = @tabid and fieldname = 'salesorder_id';
delete from ld_field where tabid = @tabid and fieldname = 'salesorder_id';
delimiter;
-- 2015-08-13

UPDATE ld_field set searchfieldtype=0 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='ProjectTask') 
and columnname in ('projecttask_no','projectid');
delimiter;
-- 2015-08-14

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

update ld_version set old_version='V6.1.1' ,current_version='V6.1.1' ,remark='V6.1.1-20150814';
delimiter;