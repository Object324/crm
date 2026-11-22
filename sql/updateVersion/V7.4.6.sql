insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','DUPLICATECHECKREMIND','请选择匹配字段（选择多个字段时为且的关系）','fixedstr' from dual where
not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DUPLICATECHECKREMIND' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
select 'en','DUPLICATECHECKREMIND','Please select the match field（The relationship between multiple fields）','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DUPLICATECHECKREMIND' and Labeltype='fixedstr');

select sequence into @sequence from ld_systems_deploy where deploy_type=59;
update ld_systems_deploy set sequence=sequence+1 where sequence>@sequence and roottype=1;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select '',161,'设置服务合同新增保存后更新客户的客户状态字段',@sequence+1,1,'select',0,'[{"value":"rating","text":"rating"},{"field":"rating","type":"picklist","relatetable":"ld_field"},{"relatedmodule":"SalesOrder,Accounts"},{"isSelectValue":"yes"}]'
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=161);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',161,161,'设置{$ServiceContracts.ServiceContracts}新增保存后是否更新{$Accounts.Accounts}的{$Accounts.rating}字段为（为空表示不更新）'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=161 and Relateid=161 and trantable='ld_systems_deploy' and  languagetype='zh');
 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',161,161,'{$Accounts.Accounts} updated when {$ServiceContracts.ServiceContracts} Added save {$Accounts.rating} is (blank means no update)'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=161 and Relateid=161 and trantable='ld_systems_deploy' and  languagetype='en');
delimiter;
-- 2018-07-06

SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
UPDATE ld_customreport_info SET sequence=sequence+10 WHERE folder_id=@id;

SET @report_name='工作汇报日志统计表';
SET @report_type='template';
SET @report_template='default_workreport_daily.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @sequence=1;
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);

SET @report_name='工作汇报周计划统计表';
SET @report_type='template';
SET @report_template='default_workreport_weekly.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SET @sequence=2;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);

SET @report_name='工作汇报月计划统计表';
SET @report_type='template';
SET @report_template='default_workreport_monthly.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SET @sequence=3;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);

SET @i=0;
UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@id ORDER BY sequence;
delimiter;

SET @i=0;
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
UPDATE ld_customreport_info SET sequence=sequence+10 WHERE folder_id=@id;
UPDATE ld_customreport_info SET sequence=1,setype='CooperativeWork' WHERE folder_id=@id AND report_template='default_workreport_daily.mrt';
UPDATE ld_customreport_info SET sequence=2,setype='CooperativeWork' WHERE folder_id=@id AND report_template='default_workreport_weekly.mrt';
UPDATE ld_customreport_info SET sequence=3,setype='CooperativeWork' WHERE folder_id=@id AND report_template='default_workreport_monthly.mrt';
UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@id ORDER BY sequence;
delimiter;
-- 2018-07-06

update ld_field set uitype = 1 where tabid = 6 and columnname = 'lastdistributer';
delimiter;

select max(actionid) into @max_actionid from ld_actionmapping ;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select  @max_actionid+1,'dup_and_merge',0,'CHECKMERGE' 
from dual where not exists(select 1 from ld_actionmapping where   actionname='dup_and_merge');

select actionid into @actionid from ld_actionmapping where actionname='dup_and_merge';
select tabid into @tabid from ld_tab where name='Accounts';
select max(sequence) into @max_seq from ld_profileallpermission where tabid=@tabid;

insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@actionid,@max_seq+1 
from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=@actionid);

insert into  ld_profile2standardpermissions (profileid,tabid,operation,permissions,sequence)
select profileid ,@tabid ,@actionid,0,22 from ld_profile
where not exists(select 1 from ld_profile2standardpermissions where operation=@actionid and tabid=@tabid);

select tabid into @tabid from ld_tab where name='ServiceCharge';
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@actionid,@max_seq+1 
from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=@actionid);

select tabid into @tabid from ld_tab where name='ServiceCharge';
insert into  ld_profile2standardpermissions (profileid,tabid,operation,permissions,sequence)
select profileid ,@tabid ,@actionid,0,22  from ld_profile
where not exists(select 1 from ld_profile2standardpermissions where operation=@actionid and tabid=@tabid);

select tabid into @tabid from ld_tab where name='Contacts';
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@actionid,@max_seq+1 
from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=@actionid);

select tabid into @tabid from ld_tab where name='Contacts';
insert into  ld_profile2standardpermissions (profileid,tabid,operation,permissions,sequence)
select profileid ,@tabid ,@actionid,0,22  from ld_profile
where not exists(select 1 from ld_profile2standardpermissions where operation=@actionid and tabid=@tabid);
delimiter;

update ld_desk set fieldlabel = '公海已分配{$Accounts.Accounts}数量上限' where labelbol = 'maximumnumberofhighseascustomers' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '可拥有公海已分配{$Accounts.Accounts}数量上限' where labelbol = 'Themaximumnumberofhighseascustomers' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

ALTER TABLE ld_products MODIFY COLUMN productname TEXT;
ALTER TABLE ld_products MODIFY COLUMN productsheet TEXT;
-- 2018-07-16

update ld_desk set fieldlabel=REPLACE (fieldlabel,'单据[%s]%s不成功！','单据[%s]%s失败！') where fieldlabel like'单据[%s]%s不成功！%' and Labeltype='fixedstr';
update ld_desk set fieldlabel=REPLACE (fieldlabel,'单据[%s]提交不成功！','单据[%s]提交失败！') where fieldlabel like'单据[%s]提交不成功！%' and Labeltype='fixedstr';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','Manualaddition','手动添加','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Manualaddition' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','Manualaddition','Manual addition','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Manualaddition' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','IMPORTRECIPIENTPHONE','导入接收人手机','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='IMPORTRECIPIENTPHONE' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','IMPORTRECIPIENTPHONE','Import recipient phone','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='IMPORTRECIPIENTPHONE' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','linethephonenumberiswrong','手机号【{hang}】格式错误！','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='linethephonenumberiswrong' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','linethephonenumberiswrong','phone [{hang}] is wrong!','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='linethephonenumberiswrong' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','sdkappidandappkey','1、SDK AppID和AppKey必须与腾讯云短信中保持一致','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='sdkappidandappkey' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','sdkappidandappkey','1. SDK AppID and AppKey must be consistent with Tencent cloud SMS.','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='sdkappidandappkey' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','smssignaturemustbesigned','2、短信签名必须录入腾讯云中审核通过的短信签名','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='smssignaturemustbesigned' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','smssignaturemustbesigned',"2. SMS signature must be signed into the Tencent's cloud through the SMS signature.",'fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='smssignaturemustbesigned' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','Resend','重新发送','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Resend' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','Resend',"Resend",'fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Resend' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','besuretoresend','确定要重新发送吗？','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='besuretoresend' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','besuretoresend',"Be sure to resend?",'jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='besuretoresend' and labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = '短信批次查询' where labelbol = 'SMSJOBINQUIRIES' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = 'SMS batch query' where labelbol = 'SMSJOBINQUIRIES' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

update ld_desk set fieldlabel = '未提交' where labelbol = 'To_be_submitted' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = 'To be submitted' where labelbol = 'To_be_submitted' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

update ld_desk set fieldlabel = '成功' where labelbol = 'Sent_successfully' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = 'successfully' where labelbol = 'Sent_successfully' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

update ld_desk set fieldlabel = '失败' where labelbol = 'Failed_to_send' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Failed' where labelbol = 'Failed_to_send' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

call AddColumn('ld_smssend','failed_msg','varchar','255',NULL);
delimiter;

update ld_systems_deploy set presence = 1 where deploy_type in (7,62,115);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'MassSms';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Module','sendsmshelp','http://51mis.com.cn/forum.php?mod=viewthread&tid=375&fromuid=1','群发短信，接受人手机格式' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Module' and linklabel = 'sendsmshelp');
delimiter;

update ld_desk set 
fieldlabel ='公海成员可以看到公海已分配{$Accounts.Accounts}、公海未分配{$Accounts.Accounts}、领取公海{$Accounts.Accounts}、转为公海{$Accounts.Accounts}' where labelbol='USERSPUBLICCUSTOMER' and languagetype='zh' and labeltype='fixedstr';
delimiter;

select IFNULL(max(templateid),0) into @templateid from ld_smstemplates;
insert into ld_smstemplates(templateid,templatename,body)
select @templateid+1,'短信','{1}为您的{2}验证码，请在{3}内完成输入。如非本人操作，请忽略。详询客服{4}' from DUAL
where not exists(select 1 from ld_smstemplates where body = '{1}为您的{2}验证码，请在{3}内完成输入。如非本人操作，请忽略。详询客服{4}');
delimiter;
-- 2018-07-18

update ld_desk set fieldlabel ='普通{$Accounts.Accounts}参与回收，循环自动回收规则' where labelbol='REGULARCUSTOMERRECOVERYRULE' and languagetype='zh' and Labeltype='fixedstr';

update ld_desk set fieldlabel ='Regular customers participate in recycling, recycling automatic recovery rules'
where labelbol='REGULARCUSTOMERRECOVERYRULE' and languagetype='en' and Labeltype='fixedstr';
delimiter;
insert into ld_desk (fieldlabel ,languagetype,labelbol,labeltype)
SELECT '普通{$Accounts.Accounts}参与回收，单次自动回收规则','zh','SINGLEREGULARCUSTOMERRECOVERYRULE','fixedstr' from  DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SINGLEREGULARCUSTOMERRECOVERYRULE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (fieldlabel ,languagetype,labelbol,labeltype)
SELECT 'Regular customers participate in recovery, single automatic recovery rules','en','SINGLEREGULARCUSTOMERRECOVERYRULE','fixedstr' from  DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SINGLEREGULARCUSTOMERRECOVERYRULE' and Labeltype='fixedstr');
delimiter;

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'ContactRecords','singlenormal','and','ALLOCATEORGETSTART/NOTCREATECONTACTRECORDS',10,'inactive','createdtime',1 from dual
 where not exists(select 1 from ld_account_set_rule where type='singlenormal' and tabname='contactrecords');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'Potentials','singlenormal','and','ALLOCATEORGETSTART/NOTCREATEPOTENTIALS',15,'inactive','createdtime',2 from dual
 where not exists(select 1 from ld_account_set_rule where type='singlenormal' and tabname='Potentials');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'SalesOrder','singlenormal','and','ALLOCATEORGETSTART/NOTCREATESALESORDER',30,'inactive','createdtime',3 from dual
 where not exists(select 1 from ld_account_set_rule where type='singlenormal' and tabname='SalesOrder');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'ServiceContracts','singlenormal','and','ALLOCATEORGETSTART/NOTCREATESERVICECONTRACTS',30,'inactive','createdtime',4 from dual
 where not exists(select 1 from ld_account_set_rule where type='singlenormal' and tabname='ServiceContracts');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'CashBill','singlenormal','and','ALLOCATEORGETSTART/NOTCREATECASHBILL',40,'inactive','createdtime',5 from dual
 where not exists(select 1 from ld_account_set_rule where type='singlenormal' and tabname='CashBill');
delimiter;

DROP PROCEDURE if EXISTS account_singlenormal_recoveryrule;
delimiter ||
create PROCEDURE account_singlenormal_recoveryrule
()
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
	and ld_field.presence in(0,2) where ld_account_set_rule.type='singlenormal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
  select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='singlenormal' and ld_account_set_rule.`status`='active';
     
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
      set @tmpsqlone=concat(@tmpsqlone,"  and datediff(ld_account.allocatedate,min( ",var_tablename,'.',var_columnname,"))>",var_days);

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
			  set @tmpsqlone=concat(@tmpsqlone,"  and datediff(ld_account.allocatedate,min( ",var_tablename,'.',var_columnname,"))<=",var_days);
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
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ifnull(ld_account.publicaccount,0)<1)');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
	  else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ifnull(ld_account.publicaccount,0)<1)');
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);

		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
     

	if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "singlenormal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ifnull(ld_account.publicaccount,0)<1) ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "singlenormal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
		end if;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();

			if var_condition='or'  then
				set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ifnull(ld_account.publicaccount,0)<1)  ');
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		 else
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ifnull(ld_account.publicaccount,0)<1) ');
		  end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;
	end if;
	




end ||
delimiter;
drop PROCEDURE if exists crm_publicaccount_recoveryreminds;
delimiter ||
CREATE PROCEDURE crm_publicaccount_recoveryreminds()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户达成条件后未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			else
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				 call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

end ||
delimiter;


drop PROCEDURE if EXISTS execute_account_publicoperation;
delimiter ||
create PROCEDURE execute_account_publicoperation()
BEGIN
	select `status` into @status  from ld_account_set;


	if @status=0   then
		select eventdate into @eventdate from ld_sys_event where type='publicaccount' ORDER BY eventdate DESC LIMIT 1;
		if @eventdate!=CURDATE() then
			 update  ld_sys_event set eventdate=now() where type='publicaccount';
				call  account_nocomplete_recoveryrule();
				call  account_complete_recoveryrule();
				call account_normal_recoveryrule();
			call account_singlenormal_recoveryrule();
		end if;

	end if;
end ||
delimiter;

update ld_field set quickcreate=2 where columnname='swort_s' or columnname='swort_w' or columnname='swort_o' or columnname='swort_t';
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)
select 173,'reference' from dual where not exists (select * from ld_ws_fieldtype where uitype = 173);
delimiter;

SELECT fieldtypeid into @fieldtypeid FROM ld_ws_fieldtype where uitype = 173;
INSERT INTO ld_ws_referencetype(fieldtypeid,TYPE) SELECT @fieldtypeid,'Accounts' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_referencetype WHERE fieldtypeid = @fieldtypeid);
delimiter;

update ld_desk set fieldlabel='允许编辑其他成员的单据（角色权限必须有编辑权限）' where Labeltype='fixedstr'  and labelbol='editothers' and languagetype='zh';
update ld_desk set fieldlabel='允许删除其他成员的单据（角色权限必须有删除权限）' where Labeltype='fixedstr'  and labelbol='delothers' and languagetype='zh';
delimiter;

call AddColumn('ld_users','campaignsview','int',11,'0');
delimiter;

select blockid into @blockid from ld_blocks where blocklabel='LBL_USER_DATAACCESS';
select tabid into @tabid from ld_tab where name='users';
select max(fieldid) into @fieldid from ld_field;
update ld_field_seq set id=@fieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='campaignsview');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@fieldid+1,'campaignsview','no','ld_users',56,'campaignsview','市场活动相关信息查询所有数据',0,0,39,@blockid,1,'C~O',1,2,0 from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='campaignsview');
delimiter;

select fieldid into @fieldid from ld_field where tabid=29 and columnname='campaignsview';
select tabid into @tabid from ld_tab where name='Campaigns';
select fieldlabel into @fieldlabel from ld_tranlabel where trantable='ld_tab' and tabid=@tabid and languagetype='zh';
insert into ld_tranlabel(trantable,relateid,tabid,fieldlabel,languagetype)
select 'ld_field',@fieldid,29,concat(@fieldlabel,'相关信息查询所有数据'),'zh' from dual 
where not exists(select 1 from ld_tranlabel where relateid=@fieldid and tabid=29  and languagetype='zh');
delimiter;

select fieldid into @fieldid from ld_field where tabid=29 and columnname='campaignsview';
insert into ld_tranlabel(trantable,relateid,tabid,fieldlabel,languagetype)
select 'ld_field',@fieldid,29,'view the Campaigns relevant information list','en' from dual 
where not exists(select 1 from ld_tranlabel where relateid=@fieldid and tabid=29 and languagetype='en' );
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIRSTROWSETONE','第一行只能设置显示一列','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'FIRSTROWSETONE' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIRSTROWSETONE','The first line can only be set to display one column','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'FIRSTROWSETONE' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SAVEFIALFORMORECOLUMNS','保存失败！原因：第一行只能设置显示一列','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SAVEFIALFORMORECOLUMNS' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SAVEFIALFORMORECOLUMNS','Save failure! Reason: The first line can only be set to display one column','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SAVEFIALFORMORECOLUMNS' and languagetype='en' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel='时长(s)' where languagetype='zh' and labelbol='DURATION' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Duration(s)' where languagetype='en' and labelbol='DURATION' and Labeltype='fixedstr';
delimiter;

call AddColumn('ld_field','allowedit','varchar','25',NULL);
call AddColumn('ld_field','allowedit_presence','varchar','25',NULL);
call AddColumn('ld_field','allowcreate','varchar','25',NULL);
call AddColumn('ld_field','allowcreate_presence','varchar','25',NULL);
call AddColumn('ld_field','allowdetail_presence','varchar','25',NULL);

update ld_field set allowedit = 'yes',allowedit_presence = 'yes',allowcreate = 'yes',allowcreate_presence = 'yes',allowdetail_presence = 'yes' where displaytype = 1 AND allowedit IS NULL;
update ld_field set allowedit = 'no',allowedit_presence = 'no',allowcreate = 'no',allowcreate_presence = 'no',allowdetail_presence = 'yes' where displaytype = 2 AND allowedit IS NULL;
update ld_field set allowedit = 'no',allowedit_presence = 'no',allowcreate = 'no',allowcreate_presence = 'no',allowdetail_presence = 'no' where displaytype = 3 AND allowedit IS NULL;
update ld_field set allowedit = 'no',allowedit_presence = 'no',allowcreate = 'no',allowcreate_presence = 'no',allowdetail_presence = 'no' where displaytype = 4 AND allowedit IS NULL;
delimiter;
-- 2018-07-20

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','cannotbelessthan','不能小于制单日期！','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='cannotbelessthan' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','cannotbelessthan',' can not be less than the date of production!','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='cannotbelessthan' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','theamountofreimbursement','报销金额不能小于0！','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='theamountofreimbursement' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','theamountofreimbursement','The amount of reimbursement should not be less than 0!','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='theamountofreimbursement' and labeltype='jspop');
delimiter;

UPDATE ld_desk SET fieldlabel='报销金额合计不能等于零！' WHERE labelbol='theamountofreimbursement' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='The total amount of the reimbursement can not equal to zero.' WHERE labelbol='theamountofreimbursement' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='不能晚于制单日期！' WHERE labelbol='cannotbelessthan' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='can not later than the creation date.' WHERE labelbol='cannotbelessthan' AND languagetype='en';

UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'I','V') WHERE columnname='vendorid' AND uitype=81;
-- 2018-07-24

update ld_field  set allowedit='yes' where tabid=29 and uitype=99;
delimiter;

call AddColumn('ld_automaticreminds','annualremind','varchar','20','no');
delimiter;

update ld_automaticreminds set annualremind='no' where annualremind is null  or annualremind='';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ANNUALREMIND','每年提醒','fixedstr' from ld_desk 
where not EXISTS(select 1 from ld_desk where labelbol='ANNUALREMIND' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ANNUALREMIND','Annual reminding','fixedstr' from ld_desk 
where not EXISTS(select 1 from ld_desk where labelbol='ANNUALREMIND' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2018-07-25

update ld_desk set fieldlabel='显示离职成员' where labelbol='LBL_VIEWDISABLEUSER' and Labeltype='jspop' and languagetype='zh';
delete from ld_picklist_values where listid in (select listid from ld_picklist_set where listname='bill_area') and listvalue is null or listvalue='';
delimiter;

DROP PROCEDURE IF EXISTS `rest_kehu001_caidan`;
delimiter ||
CREATE PROCEDURE `rest_kehu001_caidan`(
)
begin
	
    UPDATE ld_tab SET presence=0 WHERE `name`='PaymentPlan' AND presence=1 AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (56,57));
    
	IF DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' OR NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN

		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Service');
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'),20000 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'))
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=57);

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parenttabid,(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet'),20001 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet'))
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=57);

		SET @i=0;
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid 
			ORDER BY FIELD(tabid,
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts'),
				(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),
				(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'),
				(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge'),
				(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn'),
				(SELECT tabid FROM ld_tab WHERE `name`='Products'),
				(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork')
			),sequence;


		SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Service' AND systemdefault='yes' LIMIT 1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'),20000 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'))
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=57);

		SET @i=0;
		UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid 
			ORDER BY FIELD(tabid,
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge'),
				(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk'),
				(SELECT tabid FROM ld_tab WHERE `name`='Faq'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts'),
				(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),
				(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'),
				(SELECT tabid FROM ld_tab WHERE `name`='Products'),
				(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork')
			),sequence;



		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Sales');
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'),20000 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'))
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=56);

		SET @i=0;
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid 
			ORDER BY FIELD(tabid,
				(SELECT tabid FROM ld_tab WHERE `name`='Potentials'),
				(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder'),
				(SELECT tabid FROM ld_tab WHERE `name`='Invoice'),
				(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),
				(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'),
				(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet'),
				(SELECT tabid FROM ld_tab WHERE `name`='Products'),
				(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork')
			),sequence;


		SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Sales' AND systemdefault='yes' LIMIT 1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'),20000 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'))
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=56);

		SET @i=0;
		UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid 
			ORDER BY FIELD(tabid,
				2,
				22,
				23,
				(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),
				(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'),
				14,
				-1
			),sequence;

	END IF;

end ||
delimiter;

CALL rest_kehu001_caidan();
DROP PROCEDURE IF EXISTS `rest_kehu001_caidan`;
-- 2018-07-27

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=23 AND columnname='cashbilldate');
UPDATE ld_tranlabel SET fieldlabel='最新收款日期' WHERE tabid=23 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='最新发票号';
delimiter;

SET @tabid=29;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='level');
DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid;
DELETE FROM ld_field WHERE fieldid=@fieldid;
delimiter;

SET @tabid=29;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='trackgroupid');
DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid;
DELETE FROM ld_field WHERE fieldid=@fieldid;
delimiter;

SET @tabid=102;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='mailingzip');
DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid;
DELETE FROM ld_field WHERE fieldid=@fieldid;
delimiter;

SET @tabid=22;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print');
DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid;
DELETE FROM ld_field WHERE fieldid=@fieldid;
delimiter;

SET @tabid=8;
SET @zh='下载次数';
SET @en='Download Times';
SET @trantable='ld_field';
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='filedownloadcount');

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@fieldid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@fieldid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@fieldid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@fieldid);
delimiter;

UPDATE ld_field a
LEFT JOIN ld_tranlabel b ON a.fieldid=b.Relateid AND b.trantable='ld_field' AND b.languagetype='zh' AND a.tabid=b.tabid
SET a.fieldlabel=b.fieldlabel;


select sequence into @sequence from ld_blocks where tabid = 6 and blocklabel = 'LBL_ADDRESS_INFORMATION';
update ld_blocks set sequence = sequence + 100 where tabid = 6 and sequence >@sequence;
select max(blockid) into @blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom,linkid)
select @blockid+1,6,'LBL_LOCATION_ADDRESS',@sequence+1,0,0,0,0,0,1,0,NULL from DUAL
where not exists(select 1 from ld_blocks where tabid = 6 and blocklabel = 'LBL_LOCATION_ADDRESS');
select blockid into @blockid from ld_blocks where tabid = 6 and blocklabel = 'LBL_LOCATION_ADDRESS';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',6,@blockid,'定位地址' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = 6 and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',6,@blockid,'Location address' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = 6 and relateid = @blockid);
SET @i=0;
UPDATE ld_blocks SET sequence=(@i:=@i+1) WHERE tabid=6 ORDER BY sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_LOCATION_ADDRESS' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'locationaddress','yes','ld_account',1,65,'locationaddress','定位地址',1,2,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'定位地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Location address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

call AddColumn('ld_account','locationaddress','varchar','255',null);


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','doyouuselocationaddress','是否用定位地址覆盖国家、省份、城市及地址？','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='doyouuselocationaddress' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','doyouuselocationaddress','Do you use location addresses to cover countries, provinces, cities and addresses?','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='doyouuselocationaddress' and labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select sequence into @sequence from ld_blocks where tabid = @tabid and blocklabel = 'LBL_TICKET_INFORMATION';
update ld_blocks set sequence = sequence + 100 where tabid = @tabid and sequence >@sequence;
select max(blockid) into @blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom,linkid)
select @blockid+1,@tabid,'LBL_LOCATION_ADDRESS',@sequence+1,0,0,0,0,0,1,0,NULL from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_LOCATION_ADDRESS');
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_LOCATION_ADDRESS';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'定位地址' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Location address' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
SET @i=0;
UPDATE ld_blocks SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_LOCATION_ADDRESS' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'locationaddress','yes','ld_troubletickets',1,65,'locationaddress','定位地址',1,2,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'定位地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Location address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

call AddColumn('ld_troubletickets','locationaddress','varchar','255',null);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'locationaddress';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','locationaddress' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;
-- 2018-07-30

UPDATE ld_producttoolfield SET typeofdata=REPLACE(typeofdata,'~25,6','~25,8') WHERE columnname='actualtaxprice';

update ld_desk set fieldlabel='转普通' where labelbol='CONVERTEDHIGHSEASCUST' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='转公海' where labelbol='CONVERTEDHIGHSEASCUST' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='高级功能-动态赋值不能为空！' where labelbol='ASSIGNMENTCANOTEMPTY' and Labeltype='jspop' and languagetype='zh';
delimiter;

update ld_field set allowedit = 'yes' where uitype = 99;
delimiter;
-- 2018-08-01

update ld_account_set_rule set labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE/Days' where type='singlenormal' and tabname='ContactRecords';
update ld_account_set_rule set labelbol='ALLOCATEORGETSTARTNOCREATEPOTENTIALSCREATE/Days' where type='singlenormal' and tabname='Potentials';
update ld_account_set_rule set labelbol='ALLOCATEORGETSTARTNOCREATESALESORDERCREATE/Days' where type='singlenormal' and tabname='SalesOrder';
update ld_account_set_rule set labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE/Days' where type='singlenormal' and tabname='ServiceContracts';
update ld_account_set_rule set labelbol='ALLOCATEORGETSTARTNOCREATECASHBILLCREATE/Days' where type='singlenormal' and tabname='CashBill';
delimiter;

update ld_account_set_rule set otherwhere=' and ifnull(ld_salesorder.sostatus,"")<>"已作废" ' where type='singlenormal' and tabname='SalesOrder';
update ld_account_set_rule set otherwhere=' and ifnull(ld_servicecontracts.contract_status,"")<>"已作废"  ' where type='singlenormal' and tabname='ServiceContracts';
delimiter;

update ld_desk set fieldlabel='转普通' where labelbol='CONVERTEDORDINARYCUST' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

UPDATE ld_picklist_values SET listvalue=REPLACE(listvalue,"Mar'ina Horka","Mar''ina Horka") WHERE listvalue LIKE "%ina Horka%";
UPDATE ld_picklist_dependency SET targetvalues=REPLACE(targetvalues,"Mar'ina Horka","Mar''ina Horka") WHERE targetvalues LIKE "%ina Horka%";

CREATE TABLE IF NOT EXISTS `ld_weixinmp_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `openid` varchar(255) NOT NULL,
  `contactid` int(11) NOT NULL,
  `createdtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_weixinmp_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `modulename` varchar(100) DEFAULT NULL,
  `fieldname` varchar(100) DEFAULT NULL,
  `tabletype` varchar(100) DEFAULT NULL,
  `fieldlabel` varchar(255) DEFAULT NULL,
  `displaytype` varchar(100) DEFAULT NULL,
  `typeofdata` varchar(100) DEFAULT NULL,
  `defaultvalue` varchar(255) DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'HelpDesk','ticket_no','main','服务单编号','createno','m','',1
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='HelpDesk' and fieldname='ticket_no');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'HelpDesk','ticketcategories','main','故障类别','all','m','',2
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='HelpDesk' and fieldname='ticketcategories');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'HelpDesk','hopetime','main','希望处理时间','all','m','',3
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='HelpDesk' and fieldname='hopetime');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'HelpDesk','description','main','问题描述','all','m','',4
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='HelpDesk' and fieldname='description');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'HelpDesk','filename','main','附件','all','o','',5
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='HelpDesk' and fieldname='filename');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'HelpDesk','assigned_user_id','main','服务人员','createno','o','',6
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='HelpDesk' and fieldname='assigned_user_id');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'HelpDesk','ticketstatus','main','处理状态','createno','o','',6
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='HelpDesk' and fieldname='ticketstatus');

insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'SalesOrder','salesorder_no','main','合同编号','createno','m','',1
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='salesorder_no');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'SalesOrder','signed_data','main','签约日期','all','m','',2
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='signed_data');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'SalesOrder','description','main','备注','all','m','',3
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='description');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'SalesOrder','hdnGrandTotal','main','合计','all','m','',4
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='hdnGrandTotal');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'SalesOrder','filename','main','附件','all','m','',5
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='filename');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'SalesOrder','productname','detail','产品名称','all','m','',6
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='productname');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'SalesOrder','quantity','detail','数量','all','m','',7
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='quantity');

CREATE TABLE IF NOT EXISTS `ld_weixinmp_listfields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `modulename` varchar(100) DEFAULT NULL,
  `rownumber` int(11) DEFAULT NULL,
  `listnumber` int(11) DEFAULT NULL,
  `fieldname` varchar(255) DEFAULT NULL,
  `presence` int(11) DEFAULT NULL,
  `showtag` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_weixinmp_listfields(`modulename`,`rownumber`,`listnumber`,`fieldname`,`presence`,`showtag`)
  select 'HelpDesk','1','1','ticket_no',0,0
  from dual where not exists(select 1 from ld_weixinmp_listfields where modulename='HelpDesk' and fieldname='ticket_no');
insert into ld_weixinmp_listfields(`modulename`,`rownumber`,`listnumber`,`fieldname`,`presence`,`showtag`)
  select 'HelpDesk','2','1','ticketstatus',0,0
  from dual where not exists(select 1 from ld_weixinmp_listfields where modulename='HelpDesk' and fieldname='ticketstatus');
insert into ld_weixinmp_listfields(`modulename`,`rownumber`,`listnumber`,`fieldname`,`presence`,`showtag`)
  select 'HelpDesk','3','1','description',0,0
  from dual where not exists(select 1 from ld_weixinmp_listfields where modulename='HelpDesk' and fieldname='description');
insert into ld_weixinmp_listfields(`modulename`,`rownumber`,`listnumber`,`fieldname`,`presence`,`showtag`)
  select 'HelpDesk','3','2','assigned_user_id',0,0
  from dual where not exists(select 1 from ld_weixinmp_listfields where modulename='HelpDesk' and fieldname='assigned_user_id');

insert into ld_weixinmp_listfields(`modulename`,`rownumber`,`listnumber`,`fieldname`,`presence`,`showtag`)
  select 'SalesOrder','1','1','salesorder_no',0,0
  from dual where not exists(select 1 from ld_weixinmp_listfields where modulename='SalesOrder' and fieldname='salesorder_no');
insert into ld_weixinmp_listfields(`modulename`,`rownumber`,`listnumber`,`fieldname`,`presence`,`showtag`)
  select 'SalesOrder','2','1','signed_data',0,0
  from dual where not exists(select 1 from ld_weixinmp_listfields where modulename='SalesOrder' and fieldname='signed_data');
insert into ld_weixinmp_listfields(`modulename`,`rownumber`,`listnumber`,`fieldname`,`presence`,`showtag`)
  select 'SalesOrder','3','1','hdnGrandTotal',0,0
  from dual where not exists(select 1 from ld_weixinmp_listfields where modulename='SalesOrder' and fieldname='hdnGrandTotal');

CREATE TABLE IF NOT EXISTS `ld_weixinmp_module` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `modulename` varchar(100) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `mplabel` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `presence` int(11) DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_weixinmp_module(`modulename`,`type`,`mplabel`,`image`,`content`,`presence`,`sequence`)
  select 'HelpDesk','create','我要报修','phonerepair','实时报修并解决反馈问题！','0','3' from dual where not exists
  (select 1 from ld_weixinmp_module where modulename='HelpDesk' and type='create');
insert into ld_weixinmp_module(`modulename`,`type`,`mplabel`,`image`,`content`,`presence`,`sequence`)
  select 'HelpDesk','view','我的维修','repair','实时查看以及管理我的维修单！','0','4' from dual where not exists
  (select 1 from ld_weixinmp_module where modulename='HelpDesk' and type='view');
insert into ld_weixinmp_module(`modulename`,`type`,`mplabel`,`image`,`content`,`presence`,`sequence`)
  select 'SalesOrder','create','我要下单','preorder','实时下单提升工作效率！','0','1' from dual where not exists
  (select 1 from ld_weixinmp_module where modulename='SalesOrder' and type='create');
insert into ld_weixinmp_module(`modulename`,`type`,`mplabel`,`image`,`content`,`presence`,`sequence`)
  select 'SalesOrder','view','我的订单','order','实时查看以及管理我的订单信息！','0','2' from dual where not exists
  (select 1 from ld_weixinmp_module where modulename='SalesOrder' and type='view');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_weixinmp_set` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `modulename` varchar(100) DEFAULT NULL,
  `viewall` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
insert into ld_weixinmp_set(`modulename`,`viewall`)
  select 'HelpDesk','no' from dual where not exists(select 1 from ld_weixinmp_set where modulename='HelpDesk');
insert into ld_weixinmp_set(`modulename`,`viewall`)
  select 'SalesOrder','no' from dual where not exists(select 1 from ld_weixinmp_set where modulename='SalesOrder');
delimiter;

CALL AddColumn('ld_salesorder','sourcefrom','varchar','100',null);
alter table ld_salesorder alter column sourcefrom set default 'crm';
CALL AddColumn('ld_troubletickets','sourcefrom','varchar','100',null);
alter table ld_troubletickets alter column sourcefrom set default 'crm';

update ld_troubletickets set sourcefrom = 'crm' where sourcefrom is null or sourcefrom = '';
update ld_salesorder set sourcefrom = 'crm' where sourcefrom is null or sourcefrom = '';
select tabid into @tabid from ld_tab where name='HelpDesk';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_TICKET_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid=@tabid and block=@blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
  select @tabid,@maxfieldid+1,'sourcefrom','ld_troubletickets',1,118,'sourcefrom','单据来源',1,0,@sequence,@blockid ,3,'V~O',3,0 from dual
  where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sourcefrom');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sourcefrom';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid, @fieldid,'单据来源' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Source' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_SO_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid=@tabid and block=@blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
  select @tabid,@maxfieldid+1,'sourcefrom','ld_salesorder',1,118,'sourcefrom','单据来源',1,0,@sequence,@blockid ,3,'V~O',3,0 from dual
  where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sourcefrom');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sourcefrom';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid, @fieldid,'单据来源' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Source' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIG','客户自助服务平台配置','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERSELFSERVICECONFIG' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIG','Customer self-service platform configuration','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERSELFSERVICECONFIG' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_PARAMETER_SETTINGS';
select sequence into @sequence from ld_settings_field where blockid=@blockid and name='LBL_ACCOUNT_SET';
select max(fieldid) into @fieldid from ld_settings_field;
update ld_settings_field set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
  select @fieldid+1,@blockid,'CUSTOMERSELFSERVICECONFIG','picklistdependency.png','','index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings',@sequence+1,0 from DUAL
  where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'CUSTOMERSELFSERVICECONFIG');
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','SETTINGOFMEDIAPLATFORM','公众号表单和字段设置','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'SETTINGOFMEDIAPLATFORM' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SETTINGOFMEDIAPLATFORM','Settings of media platform modules and fields','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'SETTINGOFMEDIAPLATFORM' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','THESETTINGOFSELFSERVICEFIELDS','自助服务平台新增单据界面字段设置','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'THESETTINGOFSELFSERVICEFIELDS' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','THESETTINGOFSELFSERVICEFIELDS','The setting of self-service platform fields','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'THESETTINGOFSELFSERVICEFIELDS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MPCRMFIELDS','CRM系统中的字段','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCRMFIELDS' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MPCRMFIELDS','The fields of CRM','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCRMFIELDS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MPFIELDLABEL','自助平台中的标签名称','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPFIELDLABEL' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MPFIELDLABEL','The fields of self-service platform','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPFIELDLABEL' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MPCREATEDISPLAY','新增界面是否显示','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCREATEDISPLAY' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MPCREATEDISPLAY','Whether createview is displayed','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCREATEDISPLAY' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MPCREATEMFILLED','新增时是否必录项','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCREATEMFILLED' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MPCREATEMFILLED','Whether createview is must filled','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCREATEMFILLED' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MPCREATEDEFAULT','新增时默认值','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCREATEDEFAULT' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MPCREATEDEFAULT','The default value of createview','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCREATEDEFAULT' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','THESETTINGOFSELFSERVICELISTFIELDS','自助服务平台列表界面字段设置','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'THESETTINGOFSELFSERVICELISTFIELDS' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','THESETTINGOFSELFSERVICELISTFIELDS','The setting of self-service platform listfields','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'THESETTINGOFSELFSERVICELISTFIELDS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MPMODULESET','模块名称设置','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPMODULESET' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MPMODULESET','Modules setting','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPMODULESET' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MPCRMMODULENAME','CRM系统模块名称','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCRMMODULENAME' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MPCRMMODULENAME','Modulename of CRM','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPCRMMODULENAME' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MPSELFCONFIGPLAT','客户自助服务平台','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPSELFCONFIGPLAT' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MPSELFCONFIGPLAT','Customer self-config plat of CRM','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MPSELFCONFIGPLAT' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','ALLOWSEARCHALLRECORDS','允许查询绑定客户的所有服务记录 ','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'ALLOWSEARCHALLRECORDS' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','ALLOWSEARCHALLRECORDS','Allow to search all the records','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'ALLOWSEARCHALLRECORDS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','INTRODUCTIONOFSELFSERVICE','自助服务平台简介 ','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'INTRODUCTIONOFSELFSERVICE' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','INTRODUCTIONOFSELFSERVICE','Introduction of customer self-sevice platform','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'INTRODUCTIONOFSELFSERVICE' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','INTENTIONOFSELFSERVICE','客户自助服务平台有什么用？','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'INTENTIONOFSELFSERVICE' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','INTENTIONOFSELFSERVICE','Intention of self-service platform','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'INTENTIONOFSELFSERVICE' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','INTENTIONOFSELFSERVICEDETAIL','客户自助服务平台是基于微信公众号的自助服务工具，通过整合灵当CRM和微信公众号，让公众号用户可以自助完成下单、报修、查询等业务','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'INTENTIONOFSELFSERVICEDETAIL' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','INTENTIONOFSELFSERVICEDETAIL','The customer self-service platform is a self-service tool based on the WeChat public number. By integrating the CRM and the WeChat public number, the public number user can help to complete the service of the order, repair, query and so on.','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'INTENTIONOFSELFSERVICEDETAIL' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','ANSWER2','答','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'ANSWER2' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','ANSWER2','Answer','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'ANSWER2' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','SOURCEFROMCRM','CRM系统新建','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'SOURCEFROMCRM' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SOURCEFROMCRM','Create from CRM','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'SOURCEFROMCRM' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','SOURCEFROMWPM','客户自助服务平台','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'SOURCEFROMWPM' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SOURCEFROMWPM','Create from customer self-service platform','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'SOURCEFROMWPM' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_wx_config(name, description, switch)
  select 'weixinmp_bindtype','客户自助服务平台首页设置','login' from dual where not exists
  (select 1 from ld_wx_config where name='weixinmp_bindtype');

insert into ld_weixinmp_module(`modulename`,`type`,`mplabel`,`image`,`content`,`presence`,`sequence`)
  select 'Accounts','create','注册','preorder','','0','5' from dual where not exists
  (select 1 from ld_weixinmp_module where modulename='Accounts' and type='create');
insert into ld_weixinmp_module(`modulename`,`type`,`mplabel`,`image`,`content`,`presence`,`sequence`)
  select 'Accounts','view','注册','order','','0','6' from dual where not exists
  (select 1 from ld_weixinmp_module where modulename='Accounts' and type='view');

insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'Accounts','accountname','main','客户名称','all','m','',1
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='Accounts' and fieldname='accountname');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'Accounts','phone','main','公司电话','all','m','',2
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='Accounts' and fieldname='phone');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'Accounts','lastname','main','联系人姓名','all','m','',3
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='Accounts' and fieldname='lastname');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'Accounts','mobile','main','联系人手机','all','o','',4
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='Accounts' and fieldname='mobile');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'Accounts','filename','main','附件','all','m','',5
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='Accounts' and fieldname='filename');
insert into ld_weixinmp_fields(`modulename`,`fieldname`,`tabletype`,`fieldlabel`,`displaytype`,`typeofdata`,`defaultvalue`,`sequence`)
  select 'Accounts','assigned_user_id','main','销售负责人','createno','o','1',6
  from dual where not exists(select 1 from ld_weixinmp_fields where modulename='Accounts' and fieldname='assigned_user_id');

insert into ld_weixinmp_set(`modulename`,`viewall`)
  select 'Accounts','no' from dual where not exists(select 1 from ld_weixinmp_set where modulename='Accounts');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICEHOME','客户自助服务平台首页','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERSELFSERVICEHOME' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICEHOME','Customer self-service platform home','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERSELFSERVICEHOME' and languagetype='en' and labeltype = 'fixedstr');
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CELLLOGIN','登录','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CELLLOGIN' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CELLLOGIN','Login','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CELLLOGIN' and languagetype='en' and labeltype = 'fixedstr');


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CELLREGISTER','注册','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CELLREGISTER' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CELLREGISTER','Register','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CELLREGISTER' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
-- 2018-08-03

UPDATE ld_field SET presence=0 WHERE columnname='completed' 
	AND EXISTS (SELECT 1 FROM ld_account_set WHERE `status`=0) 
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (56,57,58));

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

update ld_version set old_version='V7.4.6',current_version='V7.4.6',remark='V7.4.6-20180803',wx_version='V7.4.5';
delimiter;