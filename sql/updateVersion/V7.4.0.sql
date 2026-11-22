INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NearbyAccounts','附近{$Accounts.Accounts}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NearbyAccounts' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NearbyAccounts','Nearby {$Accounts.Accounts}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'NearbyAccounts' and languagetype='en' and labeltype = 'fixedstr');


UPDATE ld_tab SET presence=0 WHERE `name` IN ('NormalApprove','AddJobBill','MinusJobBill','LoanApply') AND REPLACE(DATABASE(),'wx','')>17001;

SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Service');
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @parenttabid,'-1',20000 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid='-1')
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=57)
	AND REPLACE(DATABASE(),'wx','')>17001;

SET @i=0;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;
delimiter;



SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Sales');
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @parenttabid,'-1',20000 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid='-1')
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56))
	AND REPLACE(DATABASE(),'wx','')>17001;

SET @i=0;
UPDATE ld_appparenttabrel SET sequence=30000 WHERE blockid=@blockid AND tabid=-1;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;
delimiter;


SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='OAForms');
DELETE FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=-1 
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57))
	AND REPLACE(DATABASE(),'wx','')>17001;
delimiter;


SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Service' AND systemdefault='yes' LIMIT 1);
INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
SELECT @blockid,-1,20000 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=-1)
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=57)
	AND REPLACE(DATABASE(),'wx','')>17001;

SET @i=0;
UPDATE ld_appparenttabrel SET sequence=30000 WHERE blockid=@blockid AND tabid=-1;
UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;


SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Sales' AND systemdefault='yes' LIMIT 1);
INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
SELECT @blockid,-1,20000 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=-1)
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56))
	AND REPLACE(DATABASE(),'wx','')>17001;

SET @i=0;
SET @j=0;
UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;
UPDATE ld_appparenttabrel SET sequence=(@j:=@j+1) WHERE blockid=@blockid AND REPLACE(DATABASE(),'wx','')>17001
ORDER BY FIELD(tabid,
	(SELECT tabid FROM ld_tab WHERE `name`='Expense'),
	(SELECT tabid FROM ld_tab WHERE `name`='AddJobBill'),
	(SELECT tabid FROM ld_tab WHERE `name`='MinusJobBill'),
	(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply'),
	(SELECT tabid FROM ld_tab WHERE `name`='NormalApprove'),
	(SELECT tabid FROM ld_tab WHERE `name`='LoanApply'),
	(SELECT tabid FROM ld_tab WHERE `name`='CardApply'),
	(SELECT tabid FROM ld_tab WHERE `name`='Commission')
),sequence;
delimiter;


SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='OAForms' AND systemdefault='yes' LIMIT 1);
DELETE FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=-1 
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57))
	AND REPLACE(DATABASE(),'wx','')>17001;
delimiter;

DROP PROCEDURE IF EXISTS `rest_picklist_dependency_20180612`;
delimiter ||
CREATE PROCEDURE `rest_picklist_dependency_20180612`()
BEGIN

	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=6 AND columnname='bill_area') THEN

		IF NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE tabid=6 AND sourcefield='bill_city' AND targetfield='bill_area' AND sourcevalue='上海市') THEN
			SET @maxid=IFNULL((SELECT MAX(id) FROM ld_picklist_dependency),0);
			INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
			SELECT @maxid+1,6,'bill_city','bill_area',"上海市",'["黄浦区","卢湾区","徐汇区","长宁区","静安区","普陀区","闸北区","虹口区","杨浦区","闵行区","宝山区","嘉定区","浦东新区","金山区","松江区","青浦区","南汇区","奉贤区","崇明区"]';
		END IF;

		IF NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE tabid=4 AND sourcefield='bill_city' AND targetfield='bill_area' AND sourcevalue='上海市') THEN
			SET @maxid=IFNULL((SELECT MAX(id) FROM ld_picklist_dependency),0);
			INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
			SELECT @maxid+1,4,'bill_city','bill_area',"上海市",'["黄浦区","卢湾区","徐汇区","长宁区","静安区","普陀区","闸北区","虹口区","杨浦区","闵行区","宝山区","嘉定区","浦东新区","金山区","松江区","青浦区","南汇区","奉贤区","崇明区"]';
		END IF;

		IF NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE tabid=18 AND sourcefield='bill_city' AND targetfield='bill_area' AND sourcevalue='上海市') THEN
			SET @maxid=IFNULL((SELECT MAX(id) FROM ld_picklist_dependency),0);
			INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
			SELECT @maxid+1,18,'bill_city','bill_area',"上海市",'["黄浦区","卢湾区","徐汇区","长宁区","静安区","普陀区","闸北区","虹口区","杨浦区","闵行区","宝山区","嘉定区","浦东新区","金山区","松江区","青浦区","南汇区","奉贤区","崇明区"]';
		END IF;


		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='ServiceCharge' LIMIT 1);
		IF NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield='bill_city' AND targetfield='bill_area' AND sourcevalue='上海市') THEN
			SET @maxid=IFNULL((SELECT MAX(id) FROM ld_picklist_dependency),0);
			INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
			SELECT @maxid+1,@tabid,'bill_city','bill_area',"上海市",'["黄浦区","卢湾区","徐汇区","长宁区","静安区","普陀区","闸北区","虹口区","杨浦区","闵行区","宝山区","嘉定区","浦东新区","金山区","松江区","青浦区","南汇区","奉贤区","崇明区"]';
		END IF;
	END IF;


end ||
delimiter;

CALL rest_picklist_dependency_20180612();
DROP PROCEDURE IF EXISTS `rest_picklist_dependency_20180612`;
delimiter;

drop PROCEDURE if exists account_nocomplete_recoveryrule;
delimiter ||
create PROCEDURE account_nocomplete_recoveryrule()


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
	



end||
delimiter;
drop PROCEDURE if EXISTS account_complete_recoveryrule;
delimiter ||
create PROCEDURE account_complete_recoveryrule()
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
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成" group by ld_account.smownerid    ');
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

end||
delimiter;
drop PROCEDURE if EXISTS account_normal_recoveryrule;
delimiter ||
create PROCEDURE account_normal_recoveryrule()
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
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
		end if;
select @TMPSQL_TWO;
     delete from ld_publicaccount_remindtableview ;

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

end||
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OftenUseReport'; 
update ld_usereport set tabids = @tabid where `name` = 'SalesSumSequence'; 
delimiter; 

select count(1) into @cnt from ld_field where tabid = 6 and duplicatefield = 0; 
update ld_field set duplicatefield = 0 where tabid = 6 and columnname in ('phone','lastname','mobile') and @cnt = 1; 
delimiter;

update ld_field set quickcreate = 2 where columnname in ('5w2p_why1','5w2p_plan1','5w2p_plan2','5w2p_why2','5w2p_why3','5w2p_why4','5w2p_why5');
delimiter;

delete from ld_cvcolumnlist_wx where modulename='ServiceCharge' and (columnname like 'ld_contactscf%' or columnname like 'ld_contactdetails%');
delimiter;
-- 2018-06-12

DROP PROCEDURE IF EXISTS `rest_kehu001_caidan`;
delimiter ||
CREATE PROCEDURE `rest_kehu001_caidan`(
)
begin
	
	IF DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' THEN

		UPDATE ld_tab SET presence=0 WHERE `name` IN ('NormalApprove','AddJobBill','MinusJobBill','LoanApply');

		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Service');
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parenttabid,'-1',20000 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid='-1')
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=57);

		SET @i=0;
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;


		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Sales');
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parenttabid,'-1',20000 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid='-1')
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56));

		SET @i=0;
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;


		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='OAForms');
		DELETE FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=-1 
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57));

		SET @j=0;
		UPDATE ld_parenttabrel SET sequence=(@j:=@j+1) WHERE parenttabid=@parenttabid 
		ORDER BY FIELD(tabid,
			(SELECT tabid FROM ld_tab WHERE `name`='Expense'),
			(SELECT tabid FROM ld_tab WHERE `name`='AddJobBill'),
			(SELECT tabid FROM ld_tab WHERE `name`='MinusJobBill'),
			(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply'),
			(SELECT tabid FROM ld_tab WHERE `name`='NormalApprove'),
			(SELECT tabid FROM ld_tab WHERE `name`='LoanApply'),
			(SELECT tabid FROM ld_tab WHERE `name`='CardApply'),
			(SELECT tabid FROM ld_tab WHERE `name`='Commission')
		),sequence;
		

		SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Service' AND systemdefault='yes' LIMIT 1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,-1,20000 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=-1)
            AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57));

		SET @i=0;
        UPDATE ld_appparenttabrel SET sequence=30000 WHERE blockid=@blockid AND tabid=-1;
		UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;

		SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Sales' AND systemdefault='yes' LIMIT 1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,-1,20000 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=-1)
            AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57));

		SET @i=0;
		UPDATE ld_appparenttabrel SET sequence=30000 WHERE blockid=@blockid AND tabid=-1;
		UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;

		SET @j=0;
        SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='OAForms' AND systemdefault='yes' LIMIT 1);
		UPDATE ld_appparenttabrel SET sequence=(@j:=@j+1) WHERE blockid=@blockid
		ORDER BY FIELD(tabid,
			(SELECT tabid FROM ld_tab WHERE `name`='Expense'),
			(SELECT tabid FROM ld_tab WHERE `name`='AddJobBill'),
			(SELECT tabid FROM ld_tab WHERE `name`='MinusJobBill'),
			(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply'),
			(SELECT tabid FROM ld_tab WHERE `name`='NormalApprove'),
			(SELECT tabid FROM ld_tab WHERE `name`='LoanApply'),
			(SELECT tabid FROM ld_tab WHERE `name`='CardApply'),
			(SELECT tabid FROM ld_tab WHERE `name`='Commission')
		),sequence;

		SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='OAForms' AND systemdefault='yes' LIMIT 1);
		DELETE FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=-1 
			AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57));
            
        UPDATE ld_appparenttab SET blockname='OA表单' WHERE parenttab_label='OAForms' AND systemdefault='yes' AND blockname='汇报审批';
        SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='OAForms' LIMIT 1);
        UPDATE ld_tranlabel SET fieldlabel='OA表单' WHERE trantable='ld_parenttab' AND Relateid=@parenttabid AND languagetype='zh' AND fieldlabel='汇报审批';

	END IF;

end ||
delimiter;

CALL rest_kehu001_caidan();
DROP PROCEDURE IF EXISTS `rest_kehu001_caidan`;
-- 2018-06-14

DELETE FROM ld_picklist_values WHERE listvalue='' AND listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_city');
DELETE FROM ld_picklist_values WHERE listvalue='中国' AND listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_state');

SET @listvalue='上海市';
SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_city');
SET @seq=(SELECT MAX(sequence) FROM ld_picklist_values WHERE listid=@listid);
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvalue,@seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvalue);
delimiter;

SET @targetvalues='["北京市","河北省","山西省","内蒙古","辽宁省","吉林省","黑龙江","上海市","江苏省","浙江省","安徽省","福建省","江西省","山东省","河南省","湖北省","湖南省","广东省","天津市","台湾省","香  港","澳  门","广  西","海南省","重庆市","四川省","贵州省","云南省","西  藏","陕西省","甘肃省","青海省","宁  夏","新  疆"]';
SET @oldtargetvalues='["北京市","河北省","山西省","内蒙古","辽宁省","吉林省","黑龙江","上海市","江苏省","浙江省","安徽省","福建省","江西省","山东省","河南省","湖北省","湖南省","广东省","天津市","台湾省","香  港","澳  门","广  西","海南省","重庆市","四川省","贵州省","云南省","西  藏","陕西省","甘肃省","青海省","宁  夏","新  疆","中国"]';
UPDATE ld_picklist_dependency SET targetvalues=@targetvalues WHERE sourcefield='bill_country' AND targetfield='bill_state' AND targetvalues=@oldtargetvalues;
delimiter;

SET @targetvalues='["Shanghai","Beijing","Nanchong","Kaifeng","Wuhan","Chongqing","Chengdu","Tianjin","Puyang","Shenyang","Shiyan","Harbin","Lanzhou","Guangzhou","Nanjing","Taiyuan","Yunfu","Changchun","Changsha","Jinan","Dalian","Zhengzhou","Shijiazhuang","Jilin","Hangzhou","Nanchang","Qingdao","Tangshan","Xinyang","Urumqi","Fushun","Luoyang","Hefei","Handan","Suzhou","Shantou","Baotou","Anshan","Xuzhou","Fuzhou","Guiyang","Dayan","Wuxi","Datong","Xianyang","Huainan","Kunming","Shenzhen","Jieyang","Baoding","Benxi","Changzhou","Huaibei","Pingdingshan","Qiqihar","Wenzhou","Nanning","Anyang","Hohhot","Xining","Qinhuangdao","Hengyang","Xinxiang","Hegang","Langfang","Ningbo","Yantai","Zhuzhou","Changzhi","Zhangjiakou","Zigong","Fuxin","Huangshi","Liaoyang","Xiangtan","Zibo","Nantong","Mudanjiang","Guilin","Zhanjiang","Zhenjiang","Dandong","Shaoguan","Yancheng","Foshan","Panshan","Haikou","Taizhou","Xingtai","Jinzhou","Shuangyashan","Luancheng","Yingkou","Zhangzhou","Xiamen","Bengbu","Shihezi"]';
DELETE FROM ld_picklist_dependency WHERE sourcefield='bill_state' AND targetfield='bill_city' AND targetvalues=@targetvalues;
delimiter;

update ld_desk set fieldlabel='注销企业' where languagetype='zh' and labelbol='LBL_WECHATAPPLICATION' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Logout company' where languagetype='en' and labelbol='LBL_WECHATAPPLICATION' and Labeltype='fixedstr';
-- 2018-06-21


SET @parenttab_label='Parent Accounts';
SET @zh_old='客户';
SET @zh_new='客户管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid
    AND fieldlabel=@zh_old AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;

SET @parenttab_label='Sales';
SET @zh_old='销售';
SET @zh_new='销售管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid
    AND fieldlabel=@zh_old AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;


SET @parenttab_label='Service';
SET @zh_old='服务';
SET @zh_new='服务管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid
    AND fieldlabel=@zh_old AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;


SET @parenttab_label='Project';
SET @zh_old='项目';
SET @zh_new='项目管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid
    AND fieldlabel=@zh_old AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;

SET @parenttab_label='Finacial';
SET @zh_old='财务';
SET @zh_new='财务管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid
    AND fieldlabel=@zh_old AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;


SET @parenttab_label='Stock';
SET @zh_old='库存';
SET @zh_new='库存管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid
    AND fieldlabel=@zh_old AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter;

SET @parenttab_label='Purchase';
SET @zh_old='采购';
SET @zh_new='采购管理';
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@parenttab_label LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel=@zh_new WHERE trantable='ld_parenttab' AND languagetype='zh' AND Relateid=@parenttabid
    AND fieldlabel=@zh_old AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
delimiter; 
-- 2018-06-22

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

update ld_version set old_version='V7.4.0',current_version='V7.4.0',remark='V7.4.0-20180622',wx_version='V7.4.0';
delimiter;