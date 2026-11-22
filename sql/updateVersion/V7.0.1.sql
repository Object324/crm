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
		ELSEIF columntype='decimal' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, '(',columnlen,',2)',' default 0.00');
		ELSEIF columntype='int' THEN
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default 0');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
profileid int(19),
tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter ||
CREATE  PROCEDURE `addtabintoprofile`(
tabname varchar(50),
permissions int(19)

)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;
	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
			  set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
		 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

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

DROP PROCEDURE IF EXISTS `getallprofile`;
delimiter ||
CREATE  PROCEDURE `getallprofile`(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;


declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;

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

DROP PROCEDURE IF EXISTS `update_cvcolumnlist_wx_20170531`;
delimiter ||
CREATE  PROCEDURE `update_cvcolumnlist_wx_20170531`(
)
begin

	declare tmp_module varchar(100) default '';
	declare cur1 cursor for select DISTINCT modulename from ld_cvcolumnlist_wx;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_module = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_module;
	while(tmp_module is not null) DO
		select min(rownumber) into @min_row from ld_cvcolumnlist_wx where modulename=tmp_module;
		select min(listnumber) into @min_col from ld_cvcolumnlist_wx where modulename=tmp_module;
		update ld_cvcolumnlist_wx set rownumber=rownumber+1 where modulename=tmp_module and @min_row=0;
		update ld_cvcolumnlist_wx set listnumber=listnumber+1 where modulename=tmp_module and @min_col=0;
		Fetch cur1 into tmp_module;
	end while;

	close cur1;

end ||
delimiter;

call update_cvcolumnlist_wx_20170531();
delimiter;
-- 2017-05-31

update ld_field set displaytype=1 where tabid=29 and columnname in ('approvestatus','approveby');

select tabid into @tabid from ld_tab where `name`='CashDeposit';
update ld_tranlabel set fieldlabel='出纳存现单' where Relateid=@tabid and languagetype='zh' and trantable='ld_tab' and fieldlabel='存现单';

select tabid into @tabid from ld_tab where `name`='PutCash';
update ld_tranlabel set fieldlabel='出纳提现单' where Relateid=@tabid and languagetype='zh' and trantable='ld_tab' and fieldlabel='提现单';
delimiter;

update ld_producttoolfield set width=30 where columnname='listprice' and width<30;
update ld_producttoolfield set width=55 where columnname='productname' and tabid=37 and width<55;

update ld_systems_deploy set deploy_value=1 where deploy_type=54 and not exists (select 1 from ld_potential);
update ld_systems_deploy set deploy_value=1 where deploy_type=58 and not exists (select 1 from ld_servicecontracts);
update ld_systems_deploy set deploy_value=1 where deploy_type=15 and not exists (select 1 from ld_purchaseorder);
update ld_systems_deploy set deploy_value=1 where deploy_type=12 and not exists (select 1 from ld_salesorder);
update ld_systems_deploy set deploy_value=1 where deploy_type=57 and not exists (select 1 from ld_salesorder);

set @tabid=6;
select max(autotaskid) into @autotaskid from ld_autotask;
set @taskname='服务到期提醒(提醒客户负责人)';
insert into ld_autotask(autotaskid,tabid,autotaskname,autotaskmode,autotaskdate,autotasktype,filtergroup,execution,presence)
select @autotaskid+1,@tabid,@taskname,0,'day',1,'',0,0 from dual
where not exists (select 1 from ld_autotask where tabid=@tabid and autotaskmode=0 and autotaskname=@taskname);

update ld_autotask_seq set id=(select max(autotaskid) from ld_autotask);

select autotaskid into @autotaskid from ld_autotask where tabid=@tabid and autotaskmode=0 and autotaskname=@taskname;
insert into ld_autotaskquery(autotaskid,`query`)
SELECT @autotaskid,CONCAT("DROP PROCEDURE IF EXISTS `task_accounts_remind_lastservicedate`;
delimit","er |","|
CREATE PROCEDURE `task_accounts_remind_lastservicedate`(
)
BEGIN


	declare tmp_accountid int(19) default 0;
	declare tmp_accountname varchar(255) default NULL;
	declare tmp_date date default NULL;
	declare tmp_recieverid int(19) default 0;
	declare tmp_days int(19) default 0;

	declare cur1 cursor for SELECT
								accountid,
								accountname,
								lastservicedate,
								smownerid,
								DATEDIFF(lastservicedate,CURDATE()) AS days
							FROM ld_account
							WHERE deleted=0
								AND lastservicedate BETWEEN DATE_SUB(CURDATE(),INTERVAL 37 DAY) AND DATE_ADD(CURDATE(),INTERVAL 30 DAY);

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_accountid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_accountid,tmp_accountname,tmp_date,tmp_recieverid,tmp_days;
	while(tmp_accountid is not null) DO
		IF tmp_days<=-30 THEN
			SET @remind_type='自动任务之服务过期提醒';
			IF not exists (select 1 from ld_reminds where related_to=tmp_accountid and reltab='Accounts' and content like '自动任务之服务过期提醒%') THEN
				set @content=concat(@remind_type,'，您的客户',tmp_accountname,'服务已经过期',abs(tmp_days),'天（',tmp_date,'），请及时跟进！');

				set @maxid=0;
				select max(crmid) into @maxid from ld_crmentity;
				insert into ld_crmentity(crmid,setype)
				select @maxid+1,'Reminds';
				insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
				select @maxid+1,@content,now(),tmp_recieverid,'未读',tmp_accountid,'Accounts',0,0,0,1,1,1,now(),now(),null,0;

				update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
			END IF;
		ELSEIF tmp_days=0 AND tmp_days>=-7 THEN
			SET @remind_type='自动任务之服务到期提醒';
			IF not exists (select 1 from ld_reminds where related_to=tmp_accountid and reltab='Accounts' and content like '自动任务之服务到期提醒%') THEN
				set @content=concat(@remind_type,'，您的客户',tmp_accountname,'服务已经到期（',tmp_date,'），请及时跟进！');

				set @maxid=0;
				select max(crmid) into @maxid from ld_crmentity;
				insert into ld_crmentity(crmid,setype)
				select @maxid+1,'Reminds';
				insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
				select @maxid+1,@content,now(),tmp_recieverid,'未读',tmp_accountid,'Accounts',0,0,0,1,1,1,now(),now(),null,0;

				update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
			END IF;
		ELSEIF tmp_days>=23 AND tmp_days<=30 THEN
			SET @remind_type='自动任务之服务即将到期提醒';

			IF not exists (select 1 from ld_reminds where related_to=tmp_accountid and reltab='Accounts' and content like '自动任务之服务即将到期提醒%') THEN

				set @content=concat(@remind_type,'，您的客户',tmp_accountname,'还有',abs(tmp_days),'天（',tmp_date,'）即将到期，请及时跟进！');
				set @maxid=0;
				select max(crmid) into @maxid from ld_crmentity;
				insert into ld_crmentity(crmid,setype)
				select @maxid+1,'Reminds';
				insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
				select @maxid+1,@content,now(),tmp_recieverid,'未读',tmp_accountid,'Accounts',0,0,0,1,1,1,now(),now(),null,0;

				update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
			END IF;
		END IF;

		Fetch cur1 into tmp_accountid,tmp_accountname,tmp_date,tmp_recieverid,tmp_days;
	end while;
	close cur1;


end |","|
delimit","er;

CALL task_accounts_remind_lastservicedate();
delimit","er;") from dual
where not exists (select 1 from ld_autotaskquery where autotaskid=@autotaskid);
delimiter;


select tabid into @tabid from ld_tab where `name`='ServiceCharge';
select max(autotaskid) into @autotaskid from ld_autotask;
set @taskname='服务到期提醒(提醒服务收费人)';
insert into ld_autotask(autotaskid,tabid,autotaskname,autotaskmode,autotaskdate,autotasktype,filtergroup,execution,presence)
select @autotaskid+1,@tabid,@taskname,0,'day',1,'',0,0 from dual
where not exists (select 1 from ld_autotask where tabid=@tabid and autotaskmode=0 and autotaskname=@taskname);

update ld_autotask_seq set id=(select max(autotaskid) from ld_autotask);

select autotaskid into @autotaskid from ld_autotask where tabid=@tabid and autotaskmode=0 and autotaskname=@taskname;
insert into ld_autotaskquery(autotaskid,`query`)
SELECT @autotaskid,CONCAT("DROP PROCEDURE IF EXISTS `task_servicecharge_remind_lastservicedate`;
delimit","er |","|
CREATE PROCEDURE `task_servicecharge_remind_lastservicedate`(
)
BEGIN


	declare tmp_accountid int(19) default 0;
	declare tmp_accountname varchar(255) default NULL;
	declare tmp_date date default NULL;
	declare tmp_recieverid int(19) default 0;
	declare tmp_days int(19) default 0;

	declare cur1 cursor for SELECT
								accountid,
								accountname,
								lastservicedate,
								CASE WHEN servicecasher>0 THEN servicecasher ELSE 1 END AS servicecasher,
								DATEDIFF(lastservicedate,CURDATE()) AS days
							FROM ld_account
							WHERE deleted=0
								AND lastservicedate BETWEEN DATE_SUB(CURDATE(),INTERVAL 37 DAY) AND DATE_ADD(CURDATE(),INTERVAL 30 DAY);

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_accountid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_accountid,tmp_accountname,tmp_date,tmp_recieverid,tmp_days;
	while(tmp_accountid is not null) DO
		IF tmp_days<=-30 THEN
			SET @remind_type='自动任务之服务过期提醒';
			IF not exists (select 1 from ld_reminds where related_to=tmp_accountid and reltab='ServiceCharge' and content like '自动任务之服务过期提醒%') THEN
				set @content=concat(@remind_type,'，您的客户',tmp_accountname,'服务已经过期',abs(tmp_days),'天（',tmp_date,'），请及时跟进！');

				set @maxid=0;
				select max(crmid) into @maxid from ld_crmentity;
				insert into ld_crmentity(crmid,setype)
				select @maxid+1,'Reminds';
				insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
				select @maxid+1,@content,now(),tmp_recieverid,'未读',tmp_accountid,'ServiceCharge',0,0,0,1,1,1,now(),now(),null,0;

				update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
			END IF;
		ELSEIF tmp_days=0 AND tmp_days>=-7 THEN
			SET @remind_type='自动任务之服务到期提醒';
			IF not exists (select 1 from ld_reminds where related_to=tmp_accountid and reltab='ServiceCharge' and content like '自动任务之服务到期提醒%') THEN
				set @content=concat(@remind_type,'，您的客户',tmp_accountname,'服务已经到期（',tmp_date,'），请及时跟进！');

				set @maxid=0;
				select max(crmid) into @maxid from ld_crmentity;
				insert into ld_crmentity(crmid,setype)
				select @maxid+1,'Reminds';
				insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
				select @maxid+1,@content,now(),tmp_recieverid,'未读',tmp_accountid,'ServiceCharge',0,0,0,1,1,1,now(),now(),null,0;

				update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
			END IF;
		ELSEIF tmp_days>=23 AND tmp_days<=30 THEN
			SET @remind_type='自动任务之服务即将到期提醒';

			IF not exists (select 1 from ld_reminds where related_to=tmp_accountid and reltab='ServiceCharge' and content like '自动任务之服务即将到期提醒%') THEN

				set @content=concat(@remind_type,'，您的客户',tmp_accountname,'还有',abs(tmp_days),'天（',tmp_date,'）即将到期，请及时跟进！');
				set @maxid=0;
				select max(crmid) into @maxid from ld_crmentity;
				insert into ld_crmentity(crmid,setype)
				select @maxid+1,'Reminds';
				insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
				select @maxid+1,@content,now(),tmp_recieverid,'未读',tmp_accountid,'ServiceCharge',0,0,0,1,1,1,now(),now(),null,0;

				update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
			END IF;
		END IF;

		Fetch cur1 into tmp_accountid,tmp_accountname,tmp_date,tmp_recieverid,tmp_days;
	end while;
	close cur1;


end |","|
delimit","er;

CALL task_servicecharge_remind_lastservicedate();
delimi","ter;") from dual
where not exists (select 1 from ld_autotaskquery where autotaskid=@autotaskid);
delimiter;
-- 2017-06-01

update ld_customview set status=3 where entitytype='reminds' and (viewname='readen' or viewname='sended');
delimiter;

select tabid into @tabid  from ld_tab where name='minusjobbill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-11,0,0,'查看申请人的加班历史' from dual
where not EXISTS (select 1 from ld_quickactions where tabid=@tabid and related_tabid=-11);
delimiter;

select tabid into @tabid  from ld_tab where name='addjobbill';
update ld_quickactions set sequence=sequence+1 where  tabid=@tabid ;

update ld_quickactions set sequence=0,label='查看申请人的加班历史1' where  tabid=@tabid and label='查看申请人的加班历史';
delimiter;
update ld_desk set fieldlabel='考勤统计' where labelbol='VIEWADDJOBBILLHISTORY' and LANGUAGEtype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='Attendance Statistics' where labelbol='VIEWADDJOBBILLHISTORY' and LANGUAGEtype='en' and labeltype='fixedstr';
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OASTATISTICSAPPROVE','只统计已审批通过的单据','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OASTATISTICSAPPROVE' and labeltype='fixedstr');
insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OASTATISTICSAPPROVE','Only statistics the approved','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OASTATISTICSAPPROVE' and labeltype='fixedstr');
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OATOTALOVERTIME','总加班时长(h)','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OATOTALOVERTIME' and labeltype='fixedstr');

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OATOTALOVERTIME','Total overtime','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OATOTALOVERTIME' and labeltype='fixedstr');
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OATOTALDAYSOFF','总调休时长(h)','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OATOTALDAYSOFF' and labeltype='fixedstr');
insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OATOTALDAYSOFF','Total days Off','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OATOTALDAYSOFF' and labeltype='fixedstr');
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OAREMAININGOVERTIME','剩余加班时长(h)','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OAREMAININGOVERTIME' and labeltype='fixedstr');
insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OAREMAININGOVERTIME','Remaining overtime','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OAREMAININGOVERTIME' and labeltype='fixedstr');
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OATOTALANNUALLEAVE','总年假时长(h)','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OATOTALANNUALLEAVE' and labeltype='fixedstr');
insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OATOTALANNUALLEAVE','Total annual leave','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OATOTALANNUALLEAVE' and labeltype='fixedstr');
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OAUSEDANNUALLEAVE','已使用年假(h)','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OAUSEDANNUALLEAVE' and labeltype='fixedstr');
insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OAUSEDANNUALLEAVE','Used annual leave','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OAUSEDANNUALLEAVE' and labeltype='fixedstr');
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OAREMAININGANNUALLEAVE','剩余年假时长(h)','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OAREMAININGANNUALLEAVE' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OAREMAININGANNUALLEAVE','Remaining annual leave','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OAREMAININGANNUALLEAVE' and labeltype='fixedstr');
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIEWATTENDANCEDETAILINFO','查看考勤详细信息','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VIEWATTENDANCEDETAILINFO' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIEWATTENDANCEDETAILINFO','查看考勤详细信息','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VIEWATTENDANCEDETAILINFO' and labeltype='fixedstr');
delimiter;

UPDATE ld_cvcolumnlist_wx SET type=10 WHERE modulename='VendorContact' AND columnname LIKE 'ld_vendorcontacts:mobile:%';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCOUNTSMAP','客户地图','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACCOUNTSMAP' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCOUNTSMAP','Account Map','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACCOUNTSMAP' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RETURNCOUNTRY','返回全国','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'RETURNCOUNTRY' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RETURNCOUNTRY','Return Country','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'RETURNCOUNTRY' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ANTIONALDATAOVERVIEW','全国数据总览','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ANTIONALDATAOVERVIEW' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ANTIONALDATAOVERVIEW','National data overview','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ANTIONALDATAOVERVIEW' and labeltype = 'jspop');
delimiter;

update ld_systems_deploy set inputvalue = '[{"value":"0","text":"LBL_COMPONENTVIEW"},{"value":"1","text":"LBL_COOPERATIVEWORK"},{"value":"2","text":"ACCOUNTSMAP"},{"sql":""}]'
where deploy_type = 66;
delimiter;

update ld_field set quickcreate=1 where tabid in (select tabid from ld_tab where `name` in ('NormalApprove','LoanApply','CardApply'));
update ld_desk set fieldlabel='View attendance details' where labelbol='VIEWATTENDANCEDETAILINFO' and languagetype='en' and Labeltype='fixedstr';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Narrow','缩小','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Narrow' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Narrow','Narrow','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Narrow' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name`='AddJobBill';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='costtime';
delete from ld_tabdetailfield_formula where tabdetailfieldid=@tabdetailfieldid;

select tabid into @tabid from ld_tab where `name`='MinusJobBill';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='costtime';
delete from ld_tabdetailfield_formula where tabdetailfieldid=@tabdetailfieldid;
-- 2017-06-02

ALTER TABLE ld_producttoolfield ALTER COLUMN nullfield SET DEFAULT 1;
update ld_producttoolfield set nullfield = 1;
update ld_producttoolfield set nullfield = 0 where tabid in (select tabid from ld_tab where `name` in ('SalesOrder','ServiceContracts','Quotes','PurchaseOrder','OutboundOrder','Stock','WareHouseTransfer',
'Checks','Invoice','PurchaseInvoice','Productbom')) and columnname = 'productname';
delimiter;

update ld_producttoolfield set allowhide='no' where columnname='entitytype'
	and tabid in (select tabid from ld_tab where `name` in ('PurchaseOrder','Invoice','OutboundOrder','Stock','PurchaseInvoice'));

select tabid into @tabid from ld_tab where `name`='CardApply';
set @approvename='名片申请单审批流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;
-- 2017-06-05

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','commasymbols','，','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'commasymbols' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','commasymbols',',','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'commasymbols' and Labeltype = 'fixedstr');
delimiter;
-- 2017-06-06

update ld_desk set fieldlabel='Find Duplicates' where labelbol='CHECK' and languagetype='en';
select tabid into @tabid from ld_tab where `name`='ServiceReturn';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
update ld_tranlabel set fieldlabel='回访人' where tabid=@tabid and trantable='ld_field' and Relateid=@fieldid and languagetype='zh';
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceReturn';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
select tablename into @tablename from ld_field where tabid=@tabid and columnname='smownerid';
set @columnname='ticket_servicer';
set @fieldname='ticket_servicer';
set @zh='原服务人员';
set @en='Ticket Servicer';
set @uitype=153;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
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

call AddColumn(@tablename,@columnname,'int','19','0');
delimiter;

call getallprofile('ServiceReturn');
delimiter;
call fieldprofile('ServiceReturn');
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceReturn';
select sequence into @seq from ld_field where tabid=@tabid and columnname='servant_come';
select block into @block from ld_field where tabid=@tabid and columnname='servant_come';
update ld_field set sequence=sequence+1 where tabid=@tabid and sequence>=@seq and block=@block;
update ld_field set sequence=@seq where tabid=@tabid and columnname='ticket_servicer';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceReturn';
select fieldid into @trigger_fieldid from ld_field where tabid=@tabid and columnname='troubleticketid';
select fieldid into @effect_fieldid from ld_field where tabid=@tabid and columnname='ticket_servicer';
set @fieldtype='main';
set @curmodule_columninfo='assigned_user_id';
set @fromvalue_type='column';
set @fromvalue_info='smownerid';

insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select @fieldtype,@trigger_fieldid,@effect_fieldid,@curmodule_columninfo,@fromvalue_type,@fromvalue_info from dual
where not exists(select 1 from ld_related_field where trigger_fieldid=@trigger_fieldid and effect_fieldid=@effect_fieldid);
delimiter;

update ld_servicereturn a
LEFT JOIN ld_troubletickets b ON troubleticketid=b.ticketid
SET a.ticket_servicer=b.smownerid
WHERE a.troubleticketid>0;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','commasymbols','，','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'commasymbols' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','commasymbols',',','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'commasymbols' and Labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='cardapply';
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='loanapply';
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=@tabid);

select tabid into @tabid from ld_tab where name='minusjobbill';
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='normalapprove';
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='businessapply';
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

set @tabid=14;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='qtyearly';
update ld_tranlabel set fieldlabel='安全库存'
	where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and fieldlabel in ('最低库存','预警数量');
update ld_tranlabel set fieldlabel='Safety Stock'
	where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='en' and fieldlabel in ('Minimum inventory');
delimiter;

select tabid into @tabid from ld_tab where `name`='InventoryQuery';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='qtyearly';
update ld_tranlabel set fieldlabel='安全库存'
	where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and fieldlabel in ('预警数量');
update ld_tranlabel set fieldlabel='Safety Stock'
	where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='en' and fieldlabel in ('Warning Counter');
delimiter;

update ld_field set fieldlabel='安全库存' where columnname='qtyearly' and fieldlabel='预警数量';

select max(cvid) into @maxcvid from ld_customview ;
update ld_customview_seq set id=@maxcvid+1 where not exists(select 1 from ld_customview where viewname='quickAll' and entitytype='Reminds');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'quickSearchAll',0,1,'Reminds',3,1,1 from dual where not exists(select 1 from ld_customview where viewname='quickSearchAll' and entitytype='Reminds');
delimiter;

select cvid into @cvid from ld_customview where entitytype='Reminds' and viewname='quickSearchAll';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_reminds:recieverid:recieverid:Reminds_V' from dual where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_reminds:recieverid:recieverid:Reminds%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_reminds:related_to:related_to:Reminds_V' from dual where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_reminds:related_to:related_to:Reminds%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_reminds:date_time:date_time:Reminds_DT' from dual where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_reminds:date_time:date_time:Reminds%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_reminds:content:content:Reminds_DT' from dual where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_reminds:content:content:Reminds%');
delimiter;

select  cvid into @cvid  from ld_customview where entitytype='Emails' and viewname='all';
delete from ld_cvcolumnlist where cvid =@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_emaildetails:from_email:from_email:Emails_V' from dual
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_emaildetails:from_email:from_email:Emails%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_activity:subject:subject:Emails_V' from dual where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_activity:subject:subject:Emails%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_activity:date_start:date_start:Emails_DT' from dual where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_activity:date_start:date_start:Emails%');
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_emaildetails:to_email:saved_toid:Emails_V' from dual where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_emaildetails:to_email:saved_toid:Emails%');
delimiter;
-- 2017-06-07

update ld_producttoolfield set width=55 where columnname='productname' and width=50;
update ld_desk set fieldlabel='查找关键字' where labelbol='FINDRESULT' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Search key' where labelbol='FINDRESULT' and Labeltype='fixedstr' and languagetype='en';

ALTER TABLE ld_contactrecords MODIFY COLUMN content text;
ALTER TABLE ld_account MODIFY COLUMN lastcontent text;

update ld_customview set sequence=sequence+1 where entitytype='normalapprove' and viewname<>'All';
update ld_customview set sequence=sequence+1 where entitytype='MinusJobBill' and viewname<>'All';
update ld_customview set sequence=sequence+1 where entitytype='BusinessApply' and viewname<>'All';
update ld_customview set sequence=sequence+1 where entitytype='BusinessApply' and viewname<>'All';

select tabid into @tabid from ld_tab where name='project';
select tabid into @related_tabid from ld_tab where name='projectprogress';
update ld_quickactions set sequence=sequence+1 where related_tabid<=0  and tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,3,0,'项目进度' from dual where not exists(select 1 from ld_quickactions where related_tabid=@related_tabid and tabid=@tabid);
update ld_quickactions set presence=0  where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
-- 2017-06-08

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MobileAppDataListCustomization','移动端模块列表界面定制','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MobileAppDataListCustomization' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MobileAppDataListCustomization','Mobile App Data List Customization','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MobileAppDataListCustomization' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Customisedatalistofmobileapplication','定制移动端各模块列表显示的字段和布局样式','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'Customisedatalistofmobileapplication' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Customisedatalistofmobileapplication','Customise data list of mobile application','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'Customisedatalistofmobileapplication' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MobileAppMenuCustomization','移动端CRM菜单界面定制','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MobileAppMenuCustomization' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MobileAppMenuCustomization','Mobile App Menu Customization','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MobileAppMenuCustomization' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Customiseinterfacelayoutofmobileapplication','定制移动端底部导航菜单CRM的界面布局样式','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'Customiseinterfacelayoutofmobileapplication' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Customiseinterfacelayoutofmobileapplication','Customise interface layout of mobile application','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'Customiseinterfacelayoutofmobileapplication' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

select blockid,sequence into @blockid,@sequence from ld_settings_field where name = 'LBL_Optionalmodule_Customization';
select max(fieldid) into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'MobileAppDataListCustomization','migrate.png','Customisedatalistofmobileapplication','index.php?module=Settings&action=MobileMenuList&parenttab=Settings',@sequence+1,0 from DUAL
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'MobileAppDataListCustomization');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+2,@blockid,'MobileAppMenuCustomization','picklistdependency.png','Customiseinterfacelayoutofmobileapplication','index.php?module=Settings&action=MobileList&parenttab=Settings',@sequence+2,0 from DUAL
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'MobileAppMenuCustomization');
delimiter;

update ld_settings_blocks_seq set id = (select max(fieldid) from ld_settings_field);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','mobileblockname','区块名称','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'mobileblockname' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','mobileblockname','Block Name','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'mobileblockname' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','blocks','区块','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'blocks' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','blocks','Block','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'blocks' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','linenumber','所在行','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'linenumber' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','linenumber','Line Number','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'linenumber' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','rownumber','所在列','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'rownumber' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','rownumber','Row Number','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'rownumber' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','linenumber','所在行','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'linenumber' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','linenumber','Line Number','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'linenumber' and languagetype='en' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','rownumber','所在列','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'rownumber' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','rownumber','Row Number','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'rownumber' and languagetype='en' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','existingfield','已设置字段','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'existingfield' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','existingfield','Existing field','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'existingfield' and languagetype='en' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleasereset','请重新设置','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'pleasereset' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleasereset','Please reset','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'pleasereset' and languagetype='en' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','youdonotallowallfields','不允许将所有字段都设置为不显示','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'youdonotallowallfields' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','youdonotallowallfields','You do not allow all fields to be set without display','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'youdonotallowallfields' and languagetype='en' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','mobileterminalmodulelistinterface','移动端模块列表界面定制','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'mobileterminalmodulelistinterface' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','mobileterminalmodulelistinterface','Mobile terminal module list interface customization','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'mobileterminalmodulelistinterface' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWBLOCK','新增区块','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NEWBLOCK' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWBLOCK','Add Block','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NEWBLOCK' and languagetype='en' and labeltype = 'jspop');
delimiter;

call AddColumn('ld_tab','mobilepresence','varchar','255',NULL);
delimiter;

update ld_tab set mobilepresence = 'mobile' where `name` in ('Contacts','Accounts','ContactRecords','SalesOrder','ServiceContracts','Quotes',
'Potentials','Campaigns','Products','ServiceCharge','HelpDesk','Project','ProjectTask','Faq','NormalApprove','AddJobBill','MinusJobBill',
'BusinessApply','LoanApply','CardApply','Commission','Expense','Vendors','VendorContact','VendorContactRecords');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_appparenttab` (
  `blockid` int(11) NOT NULL AUTO_INCREMENT,
  `blockname` varchar(255) DEFAULT NULL,
  `presence` int(4) DEFAULT NULL,
  `sequence` int(4) DEFAULT NULL,
  `systemdefault` varchar(25) DEFAULT 'no',
  PRIMARY KEY (`blockid`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_appparenttabrel` (
  `blockid` int(11) DEFAULT NULL,
  `tabid` int(11) DEFAULT NULL,
  `sequence` int(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_appparenttab','parenttab_label','varchar','255',null);
delimiter;

insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '客户管理',0,1,'yes','Accounts' from dual
where not exists(select 1 from ld_appparenttab where parenttab_label = 'Accounts');

select blockid into @blockid from ld_appparenttab where parenttab_label='Accounts' limit 1;
set @i=0;
set @tabid=6;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

set @tabid=4;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);


insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '销售管理',0,2,'yes','Sales' from dual
where not exists(select 1 from ld_appparenttab where parenttab_label = 'Sales');

select blockid into @blockid from ld_appparenttab where parenttab_label='Sales' limit 1;
set @i=0;
set @tabid=22;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select blockid into @blockid from ld_appparenttab where parenttab_label='Sales' limit 1;
set @tabid=37;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select blockid into @blockid from ld_appparenttab where parenttab_label='Sales' limit 1;
set @tabid=20;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select blockid into @blockid from ld_appparenttab where parenttab_label='Sales' limit 1;
set @tabid=2;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select blockid into @blockid from ld_appparenttab where parenttab_label='Sales' limit 1;
set @tabid=26;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select blockid into @blockid from ld_appparenttab where parenttab_label='Sales' limit 1;
set @tabid=14;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);


insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '服务管理',0,3,'yes','Service' from dual
where not exists(select 1 from ld_appparenttab where parenttab_label = 'Service');

select blockid into @blockid from ld_appparenttab where parenttab_label='Service' limit 1;
set @i=0;
select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

set @tabid=13;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

set @tabid=48;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

set @tabid=47;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

set @tabid=15;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);


insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select 'OA表单',0,4,'yes','OAForms' from dual
where not exists(select 1 from ld_appparenttab where parenttab_label = 'OAForms');

select blockid into @blockid from ld_appparenttab where parenttab_label='OAForms' limit 1;
set @i=0;
select tabid into @tabid from ld_tab where `name` = 'NormalApprove';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'AddJobBill';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'MinusJobBill';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'BusinessApply';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'LoanApply';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'CardApply';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'Expense';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);


insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '供应商管理',0,5,'yes','Purchase' from dual
where not exists(select 1 from ld_appparenttab where parenttab_label = 'Purchase');

select blockid into @blockid from ld_appparenttab where parenttab_label='Purchase' limit 1;
set @i=0;
select tabid into @tabid from ld_tab where `name` = 'Vendors';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'VendorContact';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'VendorContactRecords';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'VendorContactRecords';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,(@i:=@i+1) from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = @blockid and tabid=@tabid);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWBLOCK','新增区块','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NEWBLOCK' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWBLOCK','Add Block','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NEWBLOCK' and languagetype='en' and labeltype = 'jspop');
delimiter;

call AddColumn('ld_cvcolumnlist_wx','systemdefault','varchar','255',null);
delimiter;

update ld_cvcolumnlist_wx set systemdefault = 'yes' where systemdefault is NULL or systemdefault = '';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DATACREATOR','单据创建人','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DATACREATOR' and labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DATACREATOR','Data Creator','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DATACREATOR' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DATASSIGNEDTO','单据负责人','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DATASSIGNEDTO' and labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DATASSIGNEDTO','Data Assigned To','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DATASSIGNEDTO' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select '0','Settings','WorkRemindSet','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=','控制面板工作报告提醒设置' from dual
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'WorkRemindSet');
delimiter;

update ld_customview set sequence=0 where viewname='all';
delimiter;

delete from ld_ws_fieldtype where uitype = 52 and fieldtype = 'reference';
delimiter;

select tabid into @tabid from ld_tab where name='normalapprove';
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=12);
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=12);
delimiter;

select tabid into @tabid from ld_tab where name='minusjobbill';
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=12);
delimiter;

select tabid into @tabid from ld_tab where name='loanapply';
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=12);

select tabid into @tabid from ld_tab where name='cardapply';
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=12);
delimiter;

select tabid into @tabid from ld_tab where name='businessapply';
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=12);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','potentialid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid);
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'quote_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','quoteid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','sql','select ld_vendor.smownerid from ld_vendorcontacts LEFT JOIN ld_vendor on ld_vendor.vendorid = ld_vendorcontacts.Vendorid where vendorcontactsid = ?' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','potentialid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','potentialid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select '0','Settings','AccountsContactsField','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=','控制面板 客户和联系人关联字段 ' from dual
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'AccountsContactsField');
delimiter;

update ld_settings_field set sequence=sequence+100 where blockid=3 and `name`='MobileAppDataListCustomization';
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=3 order by sequence;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_insertinto_sequence`;
delimiter ||
CREATE PROCEDURE `ldcrm_insertinto_sequence`(
)
BEGIN

	declare i int default 1;

	while i<=2000 DO
		insert into sequence(seq) select i from dual where not exists (select 1 from sequence where seq=i);
		set i=i+1;
	end while;
end ||
delimiter;

call ldcrm_insertinto_sequence();
delimiter;
-- 2017-06-09

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','blocks','区块','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'blocks' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','blocks','Block','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'blocks' and languagetype='en' and labeltype = 'jspop');
delimiter;

select blockid into @blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO';
select tabid into @tabid from ld_tab where `name` = 'InventoryQuery';
select max(fieldid) into @max_fieldid from ld_field;
insert ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,block,displaytype,typeofdata,quickcreate)
select @tabid,@max_fieldid+1,'qtyinstock','yes','ld_products',1,166,'qtyinstock','安全库存差额',1,0,@blockid,1,'V~M',3 from DUAL
where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'qtyinstock');

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'qtyinstock';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'安全库存差额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @fieldid and trantable = 'ld_field' and languagetype = 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Safe Stock Balance' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @fieldid and trantable = 'ld_field' and languagetype = 'en');
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'InventoryQuery' and viewname = 'all';
select max(columnindex) into @columnindex from ld_cvcolumnlist where cvid =@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,@columnindex+1,'ld_products:qtyinstock:qtyinstock:InventoryQuery_fieldlabel:V' from DUAL
where not exists(select 1 from ld_cvcolumnlist where cvid= @cvid and columnname = 'ld_products:qtyinstock:qtyinstock:InventoryQuery_fieldlabel:V');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryQuery';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'qtyearly';
update ld_tranlabel set fieldlabel = '安全库存' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Safety Stock' where tabid = @tabid and Relateid = @fieldid and languagetype = 'en';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'qtyearly';
update ld_tranlabel set fieldlabel = '安全库存' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Safety Stock' where tabid = @tabid and Relateid = @fieldid and languagetype = 'en';
delimiter;

UPDATE ld_desk set fieldlabel='订单接口：本系统合同订单保存（包括新增和编辑）后，同时自动保存到接口账套中。' WHERE labelbol='DATAINTERFACESTEP1' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='The order interface:after the?system?contract order?are preserved (including?add and edit),it will be?saved automatically to the?interface?set of books at the same time.' WHERE labelbol='DATAINTERFACESTEP1' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk set fieldlabel='库存数量接口：自动获取接口账套中的库存数量，并更新本系统中对应产品的总库存数量。' WHERE labelbol='DATAINTERFACESTEP2' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='In the inventory interface: automatic acquisition interface number accounts in the inventory, the total number of inventory and to update the corresponding products in this system.' WHERE labelbol='DATAINTERFACESTEP2' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk set fieldlabel='数据接口为单向接口，即订单接口只能由本系统到接口账套、库存数量接口只能由接口账套到本系统。' WHERE labelbol='DATAINTERFACESTEP3' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='The data interface for the one-way interface, i.e. the order interface only by the system to the interface accounts, inventory number interface only by the interface to the system account.' WHERE labelbol='DATAINTERFACESTEP3' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk set fieldlabel='订单同步过程中，若接口账套中缺少相关的客户或商品时，则自动向接口账套中增加相关信息。' WHERE labelbol='DATAINTERFACESTEP4' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='Order the synchronization process, if the interface account related customers or commodity lack, will automatically increase the relevant information to the interface set of books.' WHERE labelbol='DATAINTERFACESTEP4' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk set fieldlabel='读取接口：在客户相关信息中按照客户名称模糊匹配读取并显示接口帐套中相关单据信息。' WHERE labelbol='DATAINTERFACESTEP7' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='Read bills of the interface soft, dispaly in the customer related information.' WHERE labelbol='DATAINTERFACESTEP7' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk set fieldlabel='该接口仅支持单账套对接，即一个CRM系统账套只对接一个ERP系统。' WHERE labelbol='DATAINTERFACESTEP8' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='The interface only supports single account docking, that is, a CRM system account only for docking a ERP system.' WHERE labelbol='DATAINTERFACESTEP8' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='当{$Accounts.Accounts}访问权为私有时: {$Potentials.Potentials}、{$HelpDesk.HelpDesk}、{$Quotes.Quotes}、{$SalesOrder.SalesOrder}、{$Invoice.Invoice} 访问权限必须设为私有' where labelbol='ACCOUNT_ACCESS_INFO' and languagetype='zh' and Labeltype='jspop';
update ld_picklistvalues_seq set id=3000 where id<3000;
-- 2017-06-11

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOOLSDOWNLOAD','工具下载','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOOLSDOWNLOAD' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOOLSDOWNLOAD','Tools Download','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOOLSDOWNLOAD' and labeltype = 'fixedstr');
delimiter;

select fieldid into @trigger_fieldid from ld_field where tabid = 16 and columnname = 'potentialid';
select fieldid into @accountid from ld_field where tabid = 16 and columnname = 'accountid';
select fieldid into @contactid from ld_field where tabid = 16 and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@accountid,'','column','accountid' from DUAL
where not EXISTS(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @accountid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@contactid,'','column','contactid' from DUAL
where not EXISTS(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @contactid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'purchaseorder_id';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'vendorid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'vendor_id,vendors_name','column','vendorid' from DUAL
where not EXISTS(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

update ld_option_showtableheader set columns='[{"modulename":"SalesOrder","select_column":"href_columnname,signed_data,total,have_invoicetotal,invoicedate,href_columnname,received_amount,cashbilldate"}]'
,special_column_op='[{"columnname":"have_invoicetotal","show_style":"totalamount","modulename":"SalesOrder"}]'
where module='Invoice' and  selectmodule='SalesOrder';
delimiter;

update ld_option_showtableheader set columns='[{"modulename":"ServiceContracts","select_column":"href_columnname,due_date,total,have_invoicetotal,invoicedate,href_columnname,received_amount,cashbilldate"}]'
,special_column_op='[{"columnname":"have_invoicetotal","show_style":"totalamount","modulename":"ServiceContracts"}]'
where module='Invoice' and  selectmodule='ServiceContracts';
delimiter;
update ld_option_showtableheader set columns='[{"modulename":"OutboundOrder","select_column":"href_columnname,outdate,total,have_invoicetotal,invoicedate,href_columnname,received_amount,cashbilldate"}]'
,special_column_op='[{"columnname":"have_invoicetotal","show_style":"totalamount","modulename":"OutboundOrder"}]'
where module='Invoice' and  selectmodule='OutboundOrder';
delimiter;

update ld_option_showtableheader set columns='[{"modulename":"PurchaseOrder","select_column":"href_columnname,signed_data,total,invoicetotal,invoicedate,href_columnname,pay_amount,sendcashbilldate"}]'
,special_column_op='[{"columnname":"have_invoicetotal","show_style":"totalamount","modulename":"PurchaseOrder"}]'
where module='PurchaseInvoice' and  selectmodule='PurchaseOrder';
delimiter;
update ld_option_showtableheader set columns='[{"modulename":"Stock","select_column":"href_columnname,createdate,total,invoicetotal,invoicedate,href_columnname,pay_amount,sendcashbilldate"}]'
,special_column_op='[{"columnname":"have_invoicetotal","show_style":"totalamount","modulename":"Stock"}]'
where module='PurchaseInvoice' and  selectmodule='Stock';
delimiter;
-- 2017-06-12

delete from ld_customview where entitytype = 'Reminds' and viewname = 'quickAll';
update ld_customview set setmetrics = 0 where entitytype = 'Reminds' and viewname = 'quickSearchAll';
delimiter;

select tabid into @tabid from ld_tab where name = 'CardApply';
update ld_field set issmownerid=0 where tabid=@tabid and columnname='applydate';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TAXRATE','税率','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TAXRATE' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TAXRATE','Tax Rate','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TAXRATE' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel=REPLACE(fieldlabel,', whether to continue?',', continue or not?') where fieldlabel like '%, whether to continue?%';
update ld_desk set fieldlabel=REPLACE(fieldlabel,',whether to continue?',', continue or not?') where fieldlabel like '%,whether to continue?%';
update ld_desk set fieldlabel=REPLACE(fieldlabel,', please confirm whether to continue?',', continue or not?') where fieldlabel like '%, please confirm whether to continue?%';

select tabid into @tabid from ld_tab where `name`='ContactRecords';
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname='content' and not exists (select 1 from ld_contactrecords);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='content';
update ld_tranlabel set fieldlabel='跟进记录' where tabid=@tabid and trantable='ld_field' and languagetype='zh' and fieldlabel='备注';
delimiter;

alter table ld_automaticreminds  modify reminder text;

call AddColumn('ld_automaticreminds','specifyuserids','text',1000,1);
call AddColumn('ld_activity','to_email','text',1000,1);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMERPRIMARYCONTACT','客户首要联系人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERPRIMARYCONTACT' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMERPRIMARYCONTACT','Customer primary contact','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERPRIMARYCONTACT' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTACTS','联系人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CONTACTS' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTACTS','Contacts ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CONTACTS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMERANDRELATEDCONTACT','客户和关联联系人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERANDRELATEDCONTACT' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMERANDRELATEDCONTACT','Customer and related contacts ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERANDRELATEDCONTACT' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VENDORS','供应商','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VENDORS' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','VENDORS','Vendor ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VENDORS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VENDORCONTACT','供应商联系人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VENDORCONTACT' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','VENDORCONTACT','Vendor contact name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VENDORCONTACT' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VENDORANDRELATEDCONTACT','供应商和关联联系人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VENDORANDRELATEDCONTACT' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','VENDORANDRELATEDCONTACT','Vendor and related contacts','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VENDORANDRELATEDCONTACT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thisopreationdoesnotcheckthehignseaquantitylimit','该功能不判断被分配用户的公海客户是否达到上限，是否继续？','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thisopreationdoesnotcheckthehignseaquantitylimit' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thisopreationdoesnotcheckthehignseaquantitylimit','This opreation does not check the high sea quantity limit，continue or not?','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thisopreationdoesnotcheckthehignseaquantitylimit' and labeltype = 'jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCOUNTDUPLICATECHECK','{$Accounts.Accounts}查重','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ACCOUNTDUPLICATECHECK' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCOUNTDUPLICATECHECK','Duplicate Check','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ACCOUNTDUPLICATECHECK' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHECKMERGE','查重合并','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKMERGE' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHECKMERGE','Check Merge','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHECKMERGE' and labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceReturn';
select fieldid into @effect_fieldid from ld_field where tabid=@tabid and columnname='ticket_servicer';
select fieldid into @trigger_fieldid from ld_field where tabid=@tabid and columnname='troubleticketid';
update ld_related_field set curmodule_columninfo='' where trigger_fieldid=@trigger_fieldid and effect_fieldid=@effect_fieldid;
delimiter;

update ld_account set bill_city='保山' where bill_city='宝山' and bill_state='云南';
update ld_bill_city set bill_city='保山' where bill_city='宝山' and bill_cityid=357;
update ld_picklist_dependency set targetvalues=REPLACE(targetvalues,',"\\u5b9d\\u5c71",',',"保山",') where sourcevalue='云南';
delimiter;

update ld_tabdetailfield set newline=0 where (columnname='entitytype' or columnname='entitytypeid' ) and tablename='ld_cashbill2paymentplan';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
update ld_tab set mobilepresence='mobile' where tabid=@tabid;
-- 2017-06-14

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
delimiter;

update ld_version set old_version='V7.0.1',current_version='V7.0.1',remark='V7.0.1-20170614';
delimiter;