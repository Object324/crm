insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONFIRMED','确定','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CONFIRMED' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONFIRMED','Confirmed','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CONFIRMED' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel='转普通' where languagetype='zh' and labelbol='TURNORDINARY' and Labeltype='fixedstr';
delimiter;
-- 2018-04-17

select tabid into @tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_PURCHASEINQUIRYORDER_BASICINFORMATION' and tabid = @tabid;
select sequence into @sequence from ld_field where tabid = @tabid and columnname = 'smownerid';
update ld_field set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'','no','',1,202,'','选择源单',0,0,NULL,NULL,
@sequence+1,@blockid,1,'V~O',1,NULL,NULL,2,NULL,0,0,0,0,
0,0,NULL,NULL,2,0 from DUAL
where not exists(select 1 from ld_field where tabid = @tabid and uitype = 202);
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and uitype = 202;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'选择源单' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Select Source' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
select tabid into @quotes_tabid from ld_tab where `name` = 'Quotes';
select tabid into @sales_tabid from ld_tab where `name` = 'SalesOrder';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
select @tabid,@quotes_tabid,0,1,0,1,1 from DUAL
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @quotes_tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
select @tabid,@sales_tabid,0,0,0,2,2 from DUAL
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @sales_tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select tabid into @related_tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
select sequence into @sequence from ld_relatedlists where tabid = @tabid and label = 'ContactRecords';
update ld_relatedlists set sequence = sequence + 1000 where tabid  =@tabid and sequence > @sequence;
select max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,type,related_coltable,wx_presence)
select @relation_id+1,@tabid,@related_tabid,'get_purchaseinquiryorder',@sequence+1,'PurchaseInquiryOrder',0,'add',1,'datacategory_sql','inventoryproductrel.entitytypeid',1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ORTHENUMBERISBEYONDTHECHARACTERLENGTH','，或数字超出字符长度！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ORTHENUMBERISBEYONDTHECHARACTERLENGTH' and Labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ORTHENUMBERISBEYONDTHECHARACTERLENGTH',',or the number is beyond the character length!','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ORTHENUMBERISBEYONDTHECHARACTERLENGTH' and Labeltype = 'jspop');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Approve','module_list_help','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=358&fromuid=1','审批中心列表帮助' from DUAL
where not exists(select 1 from ld_links where linktype = 'Approve' and linklabel = 'module_list_help');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NearbyAccounts','附近{$Accounts.Accounts}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NearbyAccounts' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NearbyAccounts','Nearby {$Accounts.Accounts}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NearbyAccounts' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

update ld_tranlabel
set fieldlabel = 'Tax(Service)'
where Relateid in (select producttoolfieldid from ld_producttoolfield where columnname = 'tax3')
and trantable = 'ld_producttoolfield' and languagetype = 'en' and fieldlabel = 'Tax(Sales)';
delimiter;

update ld_field set uitype = 52 where tabid = (select tabid from ld_tab where `name` = 'Stock') and columnname = 'smcreatorid';
update ld_field set uitype = 52 where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'smcreatorid';
delimiter;

UPDATE ld_producttoolfield SET defaultvalue=16.000 WHERE columnname='tax2' AND defaultvalue=17.000;

SET @parenttab_label='Parent Accounts';
SET @zh_old='客户';
SET @zh_new='客户管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid 
	AND fieldlabel=@zh_old	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;

SET @parenttab_label='Sales';
SET @zh_old='销售';
SET @zh_new='销售管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid 
	AND fieldlabel=@zh_old	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;


SET @parenttab_label='Service';
SET @zh_old='服务';
SET @zh_new='服务管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid 
	AND fieldlabel=@zh_old	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;


SET @parenttab_label='Project';
SET @zh_old='项目';
SET @zh_new='项目管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid 
	AND fieldlabel=@zh_old	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;

SET @parenttab_label='Finacial';
SET @zh_old='财务';
SET @zh_new='财务管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid 
	AND fieldlabel=@zh_old	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;


SET @parenttab_label='Stock';
SET @zh_old='库存';
SET @zh_new='库存管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid 
	AND fieldlabel=@zh_old	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;

SET @parenttab_label='Purchase';
SET @zh_old='采购';
SET @zh_new='采购管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid 
	AND fieldlabel=@zh_old	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;
-- 2018-05-03

update ld_desk set fieldlabel='自分配或领用之日起距最近一次{$ContactRecords.ContactRecords}的{$ContactRecords.createdtime}已超过' where labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDS' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='The nearest {$ContactRecords.createdtime} of {$ContactRecords.ContactRecords} has exceed  the date of distribution or receive' where labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDS' and languagetype='en' and labeltype='fixedstr';
delimiter;


update ld_desk set fieldlabel='自分配或领用之日起距最近一次{$SalesOrder.SalesOrder}的{$SalesOrder.createdtime}已超过' where labelbol='ALLOCATEORGETSTARTNOCREATESALESORDER' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='The nearest {$SalesOrder.createdtime} of {$SalesOrder.SalesOrder} has exceed  the date of distribution or receive' where labelbol='ALLOCATEORGETSTARTNOCREATESALESORDER' and languagetype='en' and labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel='自分配或领用之日起距最近一次{$ServiceContracts.ServiceContracts}的{$ServiceContracts.ServiceContractscreatedtime}已超过' where labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTS' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='The nearest {$ServiceContracts.ServiceContractscreatedtime} of {$ServiceContracts.ServiceContracts} has exceed  the date of distribution or receive' where labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTS' and languagetype='en' and labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel='自分配或领用之日起距最近一次{$CashBill.CashBill}的{$CashBill.createdtime}已超过' where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILL' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='The nearest {$CashBill.createdtime} of {$CashBill.CashBill} has exceed  the date of distribution or receive' where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILL' and languagetype='en' and labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel='自分配或创建之日起距最近一次{$ContactRecords.ContactRecords}的{$ContactRecords.createdtime}已超过' where labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='The nearest {$ContactRecords.createdtime} of {$ContactRecords.ContactRecords} has exceed  the date of distribution or creation' where labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE' and languagetype='en' and labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='自分配或创建之日起距最近一次{$SalesOrder.SalesOrder}的{$SalesOrder.createdtime}已超过' where labelbol='ALLOCATEORGETSTARTNOCREATESALESORDERCREATE' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='The nearest {$SalesOrder.createdtime} of {$SalesOrder.SalesOrder} has exceed  the date of distribution or creation' where labelbol='ALLOCATEORGETSTARTNOCREATESALESORDERCREATE' and languagetype='en' and labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='自分配或创建之日起距最近一次{$ServiceContracts.ServiceContracts}的{$ServiceContracts.ServiceContractscreatedtime}已超过' where labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='The nearest {$ServiceContracts.ServiceContractscreatedtime} of {$ServiceContracts.ServiceContracts} has exceed  the date of distribution or creation' where labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE' and languagetype='en' and labeltype='fixedstr';
delimiter;


update ld_desk set fieldlabel='自分配或创建之日起距最近一次{$CashBill.CashBill}的{$CashBill.cashbilldate}已超过' where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILLCREATE' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='The nearest {$CashBill.cashbilldate} of {$CashBill.CashBill} has exceed  the date of distribution or creation' where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILLCREATE' and languagetype='en' and labeltype='fixedstr';
delimiter;

update ld_account_set_rule set columnname='createdtime';
delimiter;
drop PROCEDURE if EXISTS account_normal_recoveryrule;
delimiter ||
create PROCEDURE  account_normal_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';

	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.smownerid=ld_account.smownerid ');

			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end>    max(",var_tablename,'.',var_columnname,") then  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );

      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
				set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end>max( ", var_tablename,'.',var_columnname,") then  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);


				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
			select @tmpsql;

		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname,"<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);

		else
			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname,"<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)     ');
		end if;
     delete from ld_publicaccount_remindtableview where type='normal';

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();


		if var_condition='or'  then
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		      set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			ELSE
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
     end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

end ||
delimiter;

drop PROCEDURE if EXISTS account_nocomplete_recoveryrule;
delimiter ||
create PROCEDURE  account_nocomplete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
  select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';
     
  select allotaccount into @allotaccount from ld_account_set ;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if var_condition='and'  then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );
			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0   ");

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(curdate(),case when ld_account.allocatedate>max( ",var_tablename,'.',var_columnname,")   then ld_account.allocatedate else max(",var_tablename,'.',var_columnname,") end  )>",var_days );

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then

				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");

				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate > max(" , var_tablename,".",var_columnname," ) then ld_account.allocatedate else max(" , var_tablename,".",var_columnname,") end  )<=",var_days );

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');

		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
	  else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);

		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;

			if var_condition='or'  then
				set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		 else
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
		  end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;
	end if;


end ||
delimiter;


drop PROCEDURE if EXISTS account_complete_recoveryrule;
delimiter ||
create PROCEDURE  account_complete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';

  select allotaccount into @allotaccount from ld_account_set;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

			set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
		  set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);

			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );


				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');

		end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;


			if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			ELSE
			  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

end ||
delimiter;
-- 2018-05-04

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NearbyAccounts','附近{$Accounts.Accounts}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NearbyAccounts' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NearbyAccounts','Nearby {$Accounts.Accounts}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NearbyAccounts' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

select blockid into @blockid from ld_appparenttab where parenttab_label='Accounts';
select sequence into @sequence from ld_appparenttabrel where blockid=@blockid and tabid=6;
update ld_appparenttabrel set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
insert into ld_appparenttabrel(blockid,tabid,sequence) 
select @blockid,-8,@sequence+1 from dual where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=-8) 
and @sequence is not null;
set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

update ld_inventorytaxinfo set percentage='16' where taxid=2 and taxname='tax2';
-- 2018-05-17

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

update ld_version set old_version='V7.3.6',current_version='V7.3.6',remark='V7.3.6-20180517',wx_version='V7.3.6';
delimiter;