UPDATE ld_field SET typeofdata='NN~O' WHERE tabid=14 AND columnname IN ('qtyearly','qtyinstock') AND typeofdata LIKE 'NN~O%';
UPDATE ld_field SET typeofdata='NN~M' WHERE tabid=14 AND columnname IN ('qtyearly','qtyinstock') AND typeofdata LIKE 'NN~M%';
-- 2018-08-08

update ld_account_set_rule set labelbol='ALLOCATEORGETSTART/NOTCREATECONTACTRECORDS' where type='singlenormal' and tabname='ContactRecords';
update ld_account_set_rule set labelbol='ALLOCATEORGETSTART/NOTCREATEPOTENTIALS' where type='singlenormal' and tabname='Potentials';
update ld_account_set_rule set labelbol='ALLOCATEORGETSTART/NOTCREATESALESORDER' where type='singlenormal' and tabname='SalesOrder';
update ld_account_set_rule set labelbol='ALLOCATEORGETSTART/NOTCREATESERVICECONTRACTS' where type='singlenormal' and tabname='ServiceContracts';
update ld_account_set_rule set labelbol='ALLOCATEORGETSTART/NOTCREATECASHBILL' where type='singlenormal' and tabname='CashBill';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NORMALCUSTOMRECYCLE','普通客户参与回收','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NORMALCUSTOMRECYCLE' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NORMALCUSTOMRECYCLE','普通客户参与回收','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NORMALCUSTOMRECYCLE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SINGLEAUTORECYCLREGULAR','单次检测自动回收规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SINGLEAUTORECYCLREGULAR' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SINGLEAUTORECYCLREGULAR','单次检测自动回收规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SINGLEAUTORECYCLREGULAR' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SINGLEAUTORECYCLREGULAR','单次检测自动回收规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SINGLEAUTORECYCLREGULAR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RECYCLEUTORECYCLREGULAR','循环检测自动回收规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RECYCLEUTORECYCLREGULAR' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','RECYCLEUTORECYCLREGULAR','循环检测自动回收规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RECYCLEUTORECYCLREGULAR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thelocationaddress','定位地址中必须包含省份和城市，请重新输入准确的地址！','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='thelocationaddress' and Labeltype='jspop');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','thelocationaddress','The location address must contain provinces and cities. Please re enter the correct address.','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='thelocationaddress' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','提醒模式','REMINDMODEL','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='REMINDMODEL');

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','提醒模式','REMINDMODEL','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='REMINDMODEL');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','提醒次数','REMINDTIMES','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='REMINDMODEL');

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','提醒次数','REMINDTIMES','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='REMINDMODEL');
delimiter;

insert into ld_desk (languagetype,fieldlabel,labelbol,labeltype)
select 'zh','自动提醒时间参考字段之日起提前N天提醒：正数表示提前，负数表示延后','ANNUALREMINDEXPLAIN','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='ANNUALREMINDEXPLAIN');
insert into ld_desk (languagetype,fieldlabel,labelbol,labeltype)
select 'en','?Automatic reminder time reference field date N days reminder: positive number indicates advance, negative number indicates delayed.','ANNUALREMINDEXPLAIN','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='ANNUALREMINDEXPLAIN');
delimiter;

insert into ld_desk (languagetype,fieldlabel,labelbol,labeltype)
select 'zh','提前','AHEAD','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='AHEAD');
insert into ld_desk (languagetype,fieldlabel,labelbol,labeltype)
select 'en','Advance','AHEAD','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='AHEAD');
delimiter;

update ld_account_set_rule set labelbol='ALLOCATEORCREATETIMESTART/NOTCREATECONTACTRECORDS' where type='singlenormal' and tabname='ContactRecords';
update ld_account_set_rule set labelbol='ALLOCATEORCREATETIMESTART/NOTCREATEPOTENTIALS' where type='singlenormal' and tabname='Potentials';
update ld_account_set_rule set labelbol='ALLOCATEORCREATETIMESTART/NOTCREATESALESORDER' where type='singlenormal' and tabname='SalesOrder';
update ld_account_set_rule set labelbol='ALLOCATEORCREATETIMESTART/NOTCREATESERVICECONTRACTS' where type='singlenormal' and tabname='ServiceContracts';
update ld_account_set_rule set labelbol='ALLOCATEORCREATETIMESTART/NOTCREATECASHBILL' where type='singlenormal' and tabname='CashBill';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh', 'ALLOCATEORCREATETIMESTART', '自分配或创建之日起','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOCATEORCREATETIMESTART' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en', 'ALLOCATEORCREATETIMESTART', 'from the date of distribution or creation','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLOCATEORCREATETIMESTART' and Labeltype='fixedstr');
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

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime,",var_tablename,'.',var_columnname," as testtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );
			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0   ");

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"  having  abs(datediff(curdate(),case when IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ",var_tablename,'.',var_columnname,")   then IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) else max(",var_tablename,'.',var_columnname,") end  ))>",var_days );
      set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);

		  set @tmpsqlone=concat(@tmpsqlone,"  and datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime,ld_account.modifiedtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then

				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime,',var_tablename,'.',var_columnname,' as testtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");

				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) > max(" , var_tablename,".",var_columnname," ) then ifnull(ld_account.distributiondate,ld_account.createdtime) else max(" , var_tablename,".",var_columnname,") end  )<=",var_days );
			set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname); 
			set @tmpsqlone=concat(@tmpsqlone,"  and datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
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
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.distributiondate)>',@maxdays);
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
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and abs(datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)))>",@maxdays);
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
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and abs(datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)))>",@maxdays);
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


DROP PROCEDURE if EXISTS account_nocomplete_recoveryrule;
delimiter ||
create PROCEDURE account_nocomplete_recoveryrule
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

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate ,",var_tablename,".",var_columnname," as testtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );
			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0   ");

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(curdate(),case when ld_account.allocatedate>max( ",var_tablename,'.',var_columnname,")   then ld_account.allocatedate else max(",var_tablename,'.',var_columnname,") end  )>",var_days );
				set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
			set @tmpsqlone=concat(@tmpsqlone,"  and datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate,ld_account.modifiedtime from  ld_account LEFT JOIN(select ld_account.accountid
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

				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate,',var_tablename,".",var_columnname,' as testtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");

				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate > max(" , var_tablename,".",var_columnname," ) then ld_account.allocatedate else max(" , var_tablename,".",var_columnname,") end  )<=",var_days );
			   set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
				set @tmpsqlone=concat(@tmpsqlone,"  and datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
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
			 set @TMPSQL_ONE=concat( ' select "nocomplete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "nocomplete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成" group by ld_account.smownerid    ');
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
-- 2018-08-09

SET @modulename='ProjectTask';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
SET @columnname='workcontent';
SET @fieldname='workcontent';
SET @zh='工作内容';
SET @en='Work Content';
SET @uitype=19;
SET @readonly=1;
SET @presence=1;
SET @defaultvalue=NULL;
SET @displaytype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @quickcreatesequence=NULL;
SET @info_type='BAS';
SET @masseditable=1;
  
SELECT MAX(sequence) INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;

SELECT MAX(fieldid) INTO @fieldid FROM ld_field;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,MAXimumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
SELECT @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname;
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid,@fieldid,@zh FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel  WHERE languagetype = 'zh' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid,@fieldid,@en FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel  WHERE languagetype = 'en' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);

CALL AddColumn(@tablename,@columnname,'VARCHAR','100',NULL);
ALTER TABLE ld_projecttask MODIFY COLUMN workcontent TEXT;
delimiter;


CALL getallprofile(@modulename);
delimiter;
CALL fieldprofile(@modulename);
delimiter;

SET @modulename='ProjectTask';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
SET @columnname='solution';
SET @fieldname='solution';
SET @zh='解决方法';
SET @en='Solution';
SET @uitype=19;
SET @readonly=1;
SET @presence=1;
SET @defaultvalue=NULL;
SET @displaytype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @quickcreatesequence=NULL;
SET @info_type='BAS';
SET @masseditable=1;
  
SELECT MAX(sequence) INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;

SELECT MAX(fieldid) INTO @fieldid FROM ld_field;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,MAXimumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
SELECT @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname;
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid,@fieldid,@zh FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel  WHERE languagetype = 'zh' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid,@fieldid,@en FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel  WHERE languagetype = 'en' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);

CALL AddColumn(@tablename,@columnname,'VARCHAR','100',NULL);
ALTER TABLE ld_projecttask MODIFY COLUMN solution TEXT;
delimiter;


CALL getallprofile(@modulename);
delimiter;
CALL fieldprofile(@modulename);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REMINDDEFAULTVALUEFORSERVER','服务人员/负责人默认值不能为空！','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'REMINDDEFAULTVALUEFORSERVER' and languagetype='zh' and labeltype = 'jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REMINDDEFAULTVALUEFORSERVER','The default value of the Assigned To can not be empty！','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'REMINDDEFAULTVALUEFORSERVER' and languagetype='en' and labeltype = 'jspop');
delimiter;
-- 2018-08-10 


DROP PROCEDURE IF EXISTS `DEL_FK`;
delimiter ||
CREATE DEFINER=`root`@`localhost` PROCEDURE `DEL_FK`(
	tablename varchar(200),
	fkname varchar(200)
)
BEGIN
  SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);

	set@cnt=0;
  SET @tsql=CONCAT(' alter table ', tablename, ' drop foreign key ', fkname);
  select count(*) INTO @cnt FROM information_schema.key_column_usage WHERE TABLE_NAME=tablename and CONSTRAINT_NAME=fkname and TABLE_SCHEMA=@tableschema;
  IF @cnt >0 THEN
    PREPARE stmt FROM @tsql;
    EXECUTE stmt;
  END IF;
end ||
delimiter;

CALL DEL_FK('ld_reminds','ld_reminds_ibfk_1');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','themodulehasenotemailfield','该模块没有Eamli字段！','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='themodulehasenotemailfield' and Labeltype='jspop');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','themodulehasenotemailfield','The module has no Eamli field!','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='themodulehasenotemailfield' and Labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = '写邮件' where labelbol = 'LBL_Compose' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Write mail' where labelbol = 'LBL_Compose' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '收邮件' where labelbol = 'LBL_GETBOX' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Charge mail' where labelbol = 'LBL_GETBOX' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '需购买并设置短信账户' where labelbol = 'NEEDBUYACCOUNT' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '发送短信失败，请联系管理员设置短信账户' where labelbol = 'COMMUNICATIONACCOUNTISNOTSETEMPTYFAILED' and languagetype = 'zh' and Labeltype = 'jspop';
delimiter;

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

update ld_version set old_version='V7.4.7',current_version='V7.4.7',remark='V7.4.7-20180810',wx_version='V7.4.5';
delimiter;