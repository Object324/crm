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

call AddColumn('ld_producttoolfield','editpage','varchar','20',NULL);
call AddColumn('ld_tabdetailfield','editpage','varchar','20',NULL);
delimiter;

UPDATE ld_producttoolfield set editpage = 'listview' where bigtype in ('text','textarea','picklist') and IFNULL(editpage,'') = '';
UPDATE ld_tabdetailfield set editpage = 'listview' where fieldtype in ('Text','Select','TextArea') and IFNULL(editpage,'') = '';

SET @labelbol = 'DOCUMENTCHANGEDLISTREFRESHED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单据信息已变化，即将刷新列表界面',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The information of the document has changed and the list interface will be refreshed soon',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @tabid = (select tabid from ld_tab where `name`='Leads');
UPDATE ld_business_backfillfield SET trancolumnname = 'accountname',trancoltype= 'text' WHERE tianyanchaname = 'name' and tabid= @tabid;
UPDATE ld_business_backfillfield SET trancolumnname = 'locationaddress',trancoltype= '' WHERE tianyanchaname = 'regLocation' and tabid= @tabid;
UPDATE ld_business_backfillfield SET trancolumnname = 'bill_country',trancoltype= 'picklist' WHERE tianyanchaname = 'country' and tabid= @tabid;
UPDATE ld_business_backfillfield SET trancolumnname = 'bill_state',trancoltype= 'picklist' WHERE tianyanchaname = 'state' and tabid= @tabid;
UPDATE ld_business_backfillfield SET trancolumnname = 'bill_city',trancoltype= 'picklist' WHERE tianyanchaname = 'city' and tabid= @tabid;
UPDATE ld_business_backfillfield SET trancolumnname = 'bill_area',trancoltype= 'picklist' WHERE tianyanchaname = 'district' and tabid= @tabid;
UPDATE ld_business_backfillfield SET trancolumnname = 'bill_street',trancoltype= 'text' WHERE tianyanchaname = 'address' and tabid= @tabid;
UPDATE ld_business_backfillfield SET trancolumnname = 'contactname',trancoltype= 'text' WHERE tianyanchaname = 'legalPersonName' and tabid= @tabid;
UPDATE ld_business_backfillfield SET trancolumnname = 'mobile',trancoltype= 'text' WHERE tianyanchaname = 'phoneNumber' and tabid= @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CRMAPI','CRM API','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CRMAPI' and languagetype='zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CRMAPI','CRM API','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CRMAPI' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule`;
delimiter ||
CREATE   PROCEDURE `account_singlerecycle_highsea_rule`(IN tmp_pool_id INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
                                 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
                                                                                           INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    and (ld_field.presence in(0,2) ) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
select max(ld_account_set_rule.days) into @maxdays
from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
                          INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2)
where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;

select IF(ld_users.id>0,userid_after_release,0) into @allotaccount from ld_account_public_pool LEFT join ld_users on ld_users.id=userid_after_release
where ld_account_public_pool.id = tmp_pool_id;

if  ifnull(@allotaccount,0)=0  then
			set @allotaccount=0;
end if;
select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;

if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
else
				set	var_smownercolumn='smownerid' ;
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
end if;
					set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
								and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

				set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );

				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;


			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

ELSE
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then

			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id =  ',tmp_pool_id);

			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);

			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;

else

				if @recycleselect is not null and @recycleselect<>'' then

					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
end if;

			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);

end if;

	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) ',@TMPSQL_TWO);
prepare stmt from @TMPSQL_THREE;
execute stmt;
deallocate prepare stmt;


if var_condition='or'  then

			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'   group by ld_account.smownerid    ');
end if;

delete from ld_publicaccount_remindtableview ;

set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicaccount_recoveryreminds();
if @allotaccount>0 then
select  tmp.tablename into @grouptablename  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
                                                                                                                                                          on ld_related_field.effect_fieldid=ld_field.fieldid
                                                  where ld_field.uitype=1600  )  as  tmp
                                                     INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
where ld_field.tabid=6 and ld_field.columnname='smownerid'
  and presence in(0,2)  GROUP BY ld_field.fieldid limit 1;

select  tmp.columnname into @groupcolumnname  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
                                                                                                                                                            on ld_related_field.effect_fieldid=ld_field.fieldid
                                                    where ld_field.uitype=1600  )  as  tmp
                                                       INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
where ld_field.tabid=6 and ld_field.columnname='smownerid'
  and presence in(0,2)  GROUP BY ld_field.fieldid limit 1;
end if;
	if var_condition='or'  then

		 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		if @recycleselect<>'' and @recycleselect is not null THEN
			set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
		set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		 if @allotaccount>0 THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;
ELSE

	  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);

						if   ifnull(@groupcolumnname,'')!='' then

select GROUP_CONCAT(groupid) into @groupid from  ld_users2group where userid =@allotaccount;
set @TMPSQL_GroupEditSql=concat( ' update  ',@grouptablename,' inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=',@grouptablename,'.accountid ') ;
								if @grouptablename!='ld_account' then
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' inner join ld_account on ld_account.accountid=ld_accountscf.accountid ');
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql, ' set ',@groupcolumnname,'="', @groupid,'"');

end if ;
								set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
prepare stmt1 from @TMPSQL_GroupEditSql;
execute stmt1;
deallocate prepare stmt1;
end if;

end if;
  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
end if;

prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;
end ||

delimiter;

call AddColumn('ld_picklist_values','map_module','text','','');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAPMODULE','映射模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MAPMODULE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAPMODULE',"Mapping module",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MAPMODULE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TRANSFERTOMODULE','升级后将转入"{Module}"模块，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TRANSFERTOMODULE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TRANSFERTOMODULE','After operation this record will be transferred to "{Module}",continue or not?','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TRANSFERTOMODULE' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','beforeoperationthisrecord3','该单据未审批，不允许升级为"{Module}"单据！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='beforeoperationthisrecord3' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','beforeoperationthisrecord3','This document is not allowed to be upgraded to an "{Module}" document without approval!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='beforeoperationthisrecord3' and labeltype='jspop');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_approveforbill`(
    tmp_moudlename VARCHAR(100),
    tmp_deploytype INT(19)
)
BEGIN
	SET @modulename=tmp_moudlename;
	SET @new_deploytype=tmp_deploytype;
	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 0,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);
SET @approvename=CONCAT(@name_zh,'审批流程');
SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,isnewapprove,description)
SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no','yes','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+1,@approveid,'开始',NULL,1,1,now(),now(),6,'','start','yes',1,NULL,-1,-1 FROM DUAL WHERE @hadinsert=0;
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+2,@approveid,'一级审批',1,1,2,now(),now(),6,'','approver','yes',2,1,-1,1 FROM DUAL WHERE @hadinsert=0;
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+3,@approveid,'二级审批',1,1,3,now(),now(),6,'','approver','yes',3,1,-1,2 FROM DUAL WHERE @hadinsert=0;
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+4,@approveid,'三级审批',1,1,4,now(),now(),6,'','approver','yes','',1,-1,3 FROM DUAL WHERE @hadinsert=0;
UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);
SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);
SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);
SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);
SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);
SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);
SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);
SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);
SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);
SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);
END IF;
end ||
delimiter;
set @modulename='CollectionSlip';
CALL ldcrm_add_approveforbill(@modulename,475);
delimiter;

call AddColumn('ld_collectionslip','approvesubmittedtime','datetime','','');
call AddColumn('ld_collectionslip','currentapprovestepid','int','19','');
delimiter;

call AddColumn('ld_competition','approvesubmittedtime','datetime','','');
call AddColumn('ld_competition','currentapprovestepid','int','19','');
delimiter;

call AddColumn('ld_holiday','approvesubmittedtime','datetime','','');
call AddColumn('ld_holiday','currentapprovestepid','int','19','');
delimiter;

call AddColumn('ld_laborcontract','approvesubmittedtime','datetime','','');
call AddColumn('ld_laborcontract','currentapprovestepid','int','19','');
delimiter;

call AddColumn('ld_personnelfile','approvesubmittedtime','datetime','','');
call AddColumn('ld_personnelfile','currentapprovestepid','int','19','');
delimiter;
select max(fieldtypeid) into @fieldtypeid from ld_ws_fieldtype;
insert into ld_ws_fieldtype(fieldtypeid,uitype,fieldtype)
select  @fieldtypeid+1,789,'reference' from DUAL where not exists(select 1 from ld_ws_fieldtype where uitype=789);

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=789;
 insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CollectionSlip'  from dual where not exists(select 1 from ld_ws_referencetype
where fieldtypeid=@fieldtypeid);


update ld_field set uitype=789 where bigtype='reference' and columnname='collectionslip_id'
and tablename='ld_cashbill';
delimiter;

UPDATE ld_tabwithproductview set `columns` = 'ld_collectionslip:total:total:CollectionSlip_fieldlabel:N' where `columns` = 'ld_collectionslip:total:total:CollectionSlip_fieldlabel:V';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BULLETINBOARD','看板','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BULLETINBOARD' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BULLETINBOARD',"Bulletin Board",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BULLETINBOARD' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENTERPRISEACCOUNT','企业号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENTERPRISEACCOUNT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENTERPRISEACCOUNT',"Enterprise Account",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENTERPRISEACCOUNT' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_modtracker_detail','advancerelatedid','int','11',NULL);

SET @labelbol = 'STAGESBRANCHNOTREPEATED';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'同一分支下阶段不能重复',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The stages under the same branch cannot be repeated',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

update ld_desk set fieldlabel='Search' where labelbol='SEARCHNEW' and languagetype='en';
delimiter;

SET @labelbol = 'showZero';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'显示数据为0的成员',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Displays a member whose data is 0',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT id,'showZero','no' FROM ld_homestuffdetail
WHERE stuffid = 100 and NOT EXISTS (SELECT 1 FROM ld_homestuffdetail_setting WHERE type = 'showZero');
delimiter;

drop PROCEDURE if EXISTS leads_singlerecycle_highsea_rule_beforeremind;
delimiter ||
create PROCEDURE leads_singlerecycle_highsea_rule_beforeremind(tmp_pool_id INT(11))
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare var_leadsidcolumnname varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and  (presence in(0,2) or ld_leads_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_leads_set_rule.days) into @maxdays
  from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;
  select beforereminddays into @var_beforereminddays from ld_leads_public_pool where id=tmp_pool_id;



 if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
  select userid_after_release into @allotaccount from ld_leads_public_pool where id = tmp_pool_id;
	select recycleselect into @recycleselect from ld_leads_public_pool where id = tmp_pool_id;
	set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;
			
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
						set	var_leadsidcolumnname='record' ;
		   else
				set	var_smownercolumn='smownerid' ;
				set	var_leadsidcolumnname='leads_id' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_leads.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_leads.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from  ld_leads LEFT JOIN(select ld_leads.leadsid
							from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',var_tablename,'.',var_leadsidcolumnname,' and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >=",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_leads.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_leads.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_leads.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_leads_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_leads_set_rule.`status`='active' ORDER BY ld_leads_set_rule.sequence asc ) ";

			 set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_leads.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
		else
			if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone 
												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid 
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid ') ;
				ELSE
					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid') ;
				end if;
				
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_leads.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		   
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0  and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id,'  group by ld_leads.smownerid    ');
		end if;
		delete from ld_publicleads_remindtableview ;
        set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

        call crm_publicleads_beforereminds();
	end if;
end ||
delimiter;



drop PROCEDURE if EXISTS leads_singlerecycle_normal_rule_beforeremind;
 delimiter ||
create PROCEDURE leads_singlerecycle_normal_rule_beforeremind()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_leadsidcolumnname varchar(100);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,
	ld_leads_set_rule.iscycle,`condition`,ld_leads_set_rule.days
 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and pool_id = 1;

    declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_leads_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_leads_set_rule.days) into @maxdays
      from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
    	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    	and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and pool_id = 1;

    	select recycleselect,account_rule_pool_id into @recycleselect,@leads_rule_pool_id from ld_leads_public;

    	select beforereminddays into @var_beforereminddays from ld_leads_public_pool where id = @leads_rule_pool_id;
      if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
    		leave label_a ;
    	end if;
       set @maxdays=@maxdays-@var_beforereminddays;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
    	end if;
    	OPEN cur1;

    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO

    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
						  set	var_leadsidcolumnname='record' ;
    		   else
    				set	var_smownercolumn='smownerid' ;
					   set	var_leadsidcolumnname='leads_id' ;
    			end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
    		   end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
    				end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
    			else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))>",var_days);

    			 end if;

               set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime , '",var_tabname,"' as remindtabname from ld_leads LEFT JOIN (select ld_leads.leadsid from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',
                    var_tablename,'.leadsid and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
    				end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leads_id   where ttt_',var_tablename,'.leads_id is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads inner join "  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
    				end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
    				else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))<=",var_days);
    			   end if;

    				set @tmpsql=concat(@tmpsql,' union all ' );

    			end if;
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;


    	if @tmpint>0 then
    			set @len=CHAR_LENGTH(' union all ');
    			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    			if var_condition='or'  then
    				 set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_leads_set_rule
    									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
    									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
    										where type='complete' and ld_leads_set_rule.status='active' and ld_leads_set_rule.status='active' ORDER BY ld_leads_set_rule.sequence asc ) ";

    				set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;

    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(concat (ld_leads.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
    				end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null  and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
    					end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");

    		  else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid ') ;
    				ELSE
    					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid') ;
    				end if;

    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(concat(ld_leads.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountname,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1) group by ld_leads.smownerid'  );
    			end if;

    	 	delete from ld_publicleads_remindtableview ;
    		 set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
    			prepare stmt from @tmpthree;
    			execute stmt;
    			deallocate prepare stmt;

    			call crm_publicleads_beforereminds();
    	 end if;
    END IF;

end ||
delimiter;


insert into ld_wx_config (name,description) select 'electronic_signature_qys','契约锁电子签章' from dual where not exists(select 1 from ld_wx_config where name='electronic_signature_qys');
delimiter;

update ld_field set tablename='ld_salesorder_electronicsignet' where tablename='ld_salesorder' and columnname = 'flowstatus';
update ld_field set tablename='ld_salesorder_electronicsignet' where tablename='ld_salesorder' and columnname = 'sponsorid';
update ld_salesorder_electronicsignet t1 LEFT JOIN ld_salesorder t2 ON t2.salesorderid=t1.salesorderid SET t2.sponsorid=t1.sponsorid WHERE  t1.sponsorid = 0 AND t2.deleted = 0;
delimiter;

CALL AddColumn('ld_salesorder_electronicsignet','callbackdata','text','','');
CALL AddColumn('ld_salesorder_electronicsignet','completetime','datetime','','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WorkBriefReportSaveTip','你的统计字段/统计模块已更改，是否修改相应的简报详情并保存？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WorkBriefReportSaveTip' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WorkBriefReportSaveTip',"Your Statistics Module/statistics fields have changed. Have you modified the corresponding briefing details and saved them?",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WorkBriefReportSaveTip' and labeltype='jspop');
delimiter;

set @listid = (select listid from ld_picklist_set where listname='status' and relatetable='ld_field');
set @map_module_count =  (select count(*) from ld_picklist_values where listid=@listid and map_module!='');
update ld_picklist_values set map_module = 'close' where listid=@listid and listvalue='失败关闭' and @map_module_count<=0;
update ld_picklist_values set map_module = 'Accounts' where listid=@listid and listvalue='升级到客户' and @map_module_count<=0;
update ld_picklist_values set map_module = 'Accounts:Potentials' where listid=@listid and listvalue='升级到客户和销售机会' and @map_module_count<=0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUREWANTEXIT','确定退出？','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SUREWANTEXIT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUREWANTEXIT',"Are you sure you want to exit?",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SUREWANTEXIT' and labeltype='fixedstr');
delimiter;
update ld_desk set fieldlabel='Confirm' where labelbol='CONFIRMED' and languagetype='en';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETESUCCESSFUL','删除成功','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DELETESUCCESSFUL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETESUCCESSFUL',"Delete successful",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DELETESUCCESSFUL' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVENTORYINQUIRY','库存查询','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INVENTORYINQUIRY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVENTORYINQUIRY',"Inventory inquiry",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INVENTORYINQUIRY' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONCURRENTSTEPS','并发步骤','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CONCURRENTSTEPS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONCURRENTSTEPS',"Concurrent steps",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CONCURRENTSTEPS' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAPED','图谱','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MAPED' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAPED'," Map",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MAPED' and labeltype='fixedstr');
delimiter;
update ld_desk set fieldlabel='确定要转换为公海吗？' where labelbol='CONVERTTOHIGHSEASCLIENT' and languagetype='zh';
update ld_desk set fieldlabel='Are you sure you want to convert to high seas?' where labelbol='CONVERTTOHIGHSEASCLIENT' and languagetype='en';
delimiter;
update ld_desk set fieldlabel='确定要转换为普通吗？' where labelbol='CONVERTTONORMALCLIENT' and languagetype='zh';
update ld_desk set fieldlabel='Are you sure you want to convert to normal?' where labelbol='CONVERTTONORMALCLIENT' and languagetype='en';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UPGRADINGAFTER1','升级后将转入','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UPGRADINGAFTER1' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UPGRADINGAFTER1',"After upgrading, it will be transferred to",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UPGRADINGAFTER1' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UPGRADINGAFTER2','，是否继续？','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UPGRADINGAFTER2' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UPGRADINGAFTER2',",continue or not?",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UPGRADINGAFTER2' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILETYPENOTSUPPORTED','当前文件类型不支持','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FILETYPENOTSUPPORTED' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILETYPENOTSUPPORTED',"The current file type is not supported",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FILETYPENOTSUPPORTED' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASECONFIRMSOFTWAREFORFILE','请确定是否有对应文件的打开软件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASECONFIRMSOFTWAREFORFILE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASECONFIRMSOFTWAREFORFILE',"Please confirm if there is an open software for the corresponding file",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASECONFIRMSOFTWAREFORFILE' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OPENING','打开中...','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OPENING' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OPENING',"Opening...",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OPENING' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COPYSUCCESSFUL','复制成功','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='COPYSUCCESSFUL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COPYSUCCESSFUL',"Copy successful",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='COPYSUCCESSFUL' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COOPERATIVEWORKTITLEMOB','一天的工作开始于前一天晚上','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='COOPERATIVEWORKTITLEMOB' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COOPERATIVEWORKTITLEMOB',"The day's work begins the night before",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='COOPERATIVEWORKTITLEMOB' and labeltype='fixedstr');
delimiter;


select max(tabid) into @tabid from ld_tab ;
insert into ld_tab (tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab,proportion)
select @tabid+1,'ldsoukebao',0,50,'ldsoukebao',0,0,1,'',0,0 from dual
where not EXISTS(select 1 from ld_tab where name='ldsoukebao');
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ldsoukebao');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab',@tabid,@tabid,'搜客宝' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab',@tabid,@tabid,'搜客宝' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ldsoukebao');
select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Parent Accounts';
SET @sequence=1;
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @parenttabid,@tabid,@sequence FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);
SET @i=0;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) where parenttabid = @parenttabid ORDER BY sequence;
delimiter;

drop PROCEDURE  if EXISTS crm_addtab_intoprofile_20240328;
delimiter ||
create PROCEDURE crm_addtab_intoprofile_20240328
(
	tabname varchar(100),
	operation int(10)
)
BEGIN
	declare var_profileid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT profileid   FROM  ld_profile;
declare continue handler  for not   found  SET done =1;
	set @sql='select tabid into @tabid from ld_tab  where ';
	set @sql=CONCAT(@sql, " name='",tabname,"'");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
open cur1;
Fetch cur1 into var_profileid;
loop1: while  done<>1 DO

        set @sql=" insert into ld_profile2tab(profileid,tabid,permissions) select ";
        set @sql=concat(@sql,var_profileid,",",@tabid,",",0 ," from dual where not exists(select 1 from ld_profile2tab where tabid=",@tabid," and profileid=",var_profileid,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

set @sql=" insert into ld_profileallpermission(tabid,operation,sequence) select ";
        set @sql=concat(@sql,@tabid,",",operation ,",",0, " from dual where not exists(select 1 from ld_profileallpermission where tabid=",@tabid ,' and operation=',operation,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

set @sql=" insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select ";
        set @sql=concat(@sql,var_profileid,',',@tabid,",",operation ,",",0,",",0, " from dual where not exists(select 1 from ld_profile2standardpermissions where profileid=" ,var_profileid," and tabid=",@tabid ,' and operation=',operation,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

Fetch cur1 into var_profileid;
end while loop1;
close cur1;
end ||
delimiter;

call crm_addtab_intoprofile_20240328('ldsoukebao',3);
drop PROCEDURE  if EXISTS crm_addtab_intoprofile_20240328;
delimiter;


SET @labelbol = 'SOUKEBAO';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜客宝',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sokebao',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ldsoukebao' );
SET @leadstabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads' );
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Parent Accounts' LIMIT 1);
SET @seq=(SELECT sequence FROM ld_parenttabrel WHERE parenttabid=@parenttabid and tabid = @leadstabid and tab_tablename='ld_tab');
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename,isopeninblank)
SELECT @parenttabid,@tabid,@seq-1,'ld_tab','yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid AND tab_tablename='ld_tab')
  AND @tabid>0
  AND @parenttabid>0;
set @i =0 ;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=3 order by sequence asc;
delimiter;

call AddColumn('ld_option_module','nosignout_cantsignin','varchar',10,'no');
call AddColumn('ld_option_module','allowsupsignout','varchar',10,'no');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoSignoutNotAllowSignin','当天有未签退的外勤时，不允许继续签到','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoSignoutNotAllowSignin' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoSignoutNotAllowSignin','It is not allowed to continue signing in when the field worker has not signed out on the same day','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoSignoutNotAllowSignin' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IsAllowSupplementarySignout','签退是否允许补签（补签时不判断签退误差）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IsAllowSupplementarySignout' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IsAllowSupplementarySignout','Sign out allows for re signing (re signing does not determine sign out error)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IsAllowSupplementarySignout' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotAllowSigninPleaseSignout','管理员已设置未签退时不允许再次签到，请前往历史记录中签退','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotAllowSigninPleaseSignout' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotAllowSigninPleaseSignout','The admin has set that no one is allowed to sign in again without signing out. Please go to the history to sign out','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotAllowSigninPleaseSignout' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CLICKTOSIGNOUT','点击签退','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CLICKTOSIGNOUT' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CLICKTOSIGNOUT','Click to sign out','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CLICKTOSIGNOUT' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SIGNOUTISREQUIRED','签退必填，请点击签退后保存','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SIGNOUTISREQUIRED' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SIGNOUTISREQUIRED','Sign out is required, please click sign out to save','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SIGNOUTISREQUIRED' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SIGNOUTSUCCEEDED','签退成功','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SIGNOUTSUCCEEDED' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SIGNOUTSUCCEEDED','Sign out successfully','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SIGNOUTSUCCEEDED' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TheAdminHasSetNotAllowSignoutBeyondRange','管理员已设置超出误差范围不允许签退，请完善您的拜访对象地址信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TheAdminHasSetNotAllowSignoutBeyondRange' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TheAdminHasSetNotAllowSignoutBeyondRange','The administrator has set that it is not allowed to sign out beyond the error range. Please improve your visitors address information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TheAdminHasSetNotAllowSignoutBeyondRange' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Theadministratorhassetthatitisnotallowedtosignout','管理员已设置超出误差范围不允许签退，您的签退误差已超{metre}米，请在规定范围内签退！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Theadministratorhassetthatitisnotallowedtosignout' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Theadministratorhassetthatitisnotallowedtosignout','The administrator has set that it is not allowed to sign out beyond the error range. Your sign out error has exceeded {metre} meters. Please sign out within the specified range!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Theadministratorhassetthatitisnotallowedtosignout' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExceedErrorRangeNotAllowSign','超出误差范围，不允许签到','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExceedErrorRangeNotAllowSign' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExceedErrorRangeNotAllowSign','If it exceeds the error range, it is not allowed to sign in','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExceedErrorRangeNotAllowSign' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TheErrorIsAllowed','允许误差','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TheErrorIsAllowed' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TheErrorIsAllowed','and the error is allowed','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TheErrorIsAllowed' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk set fieldlabel='点击定位' WHERE labelbol='CLICKTOSIGNIN' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Click to locate' WHERE labelbol='CLICKTOSIGNIN' and languagetype='en';
delimiter;

UPDATE ld_desk set fieldlabel='请点击定位后保存' WHERE labelbol='SIGNINISREQUIRED' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Please click on locate to save' WHERE labelbol='SIGNINISREQUIRED' and languagetype='en';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_signout` (
    `signoutid` int(11) NOT NULL,
    `signout` varchar(255) DEFAULT NULL,
    `signout_time` datetime,
    `signout_address` text(0) DEFAULT NULL,
    `signout_distance` varchar(20) DEFAULT NULL,
    `signout_type` varchar(20) ,
    `signout_imagename` varchar(200),
    `signout_longtitude` varchar(50),
    `signout_latitude` varchar(50),
    `signin_id` int(19),
    `source_list` varchar(255) ,
    `address` varchar(255),
    `entityaddress` varchar(255),
    `timeused` varchar(50),
    `deleted` int(4) DEFAULT 0,
    `smownerid` Int(4) NOT NULL,
    `smcreatorid` Int(4),
    `createdtime` datetime ,
    `modifiedtime` datetime,
    `modifiedby` Int(4),
    PRIMARY KEY (`signoutid`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_signoutscf` (
    `signoutid` int(11) NOT NULL,
    PRIMARY KEY (`signoutid`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;


SELECT max(tabid) INTO @maxtabid FROM ld_tab;
SELECT max(tabsequence) INTO @maxtabsequence FROM ld_tab ;
INSERT INTO ld_tab (
    tabid,NAME,presence,tabsequence,tablabel,parent,printtab,isduplicate
)
SELECT
        @maxtabid + 1,'Signout',0 ,@maxtabsequence + 1,'Signout',null,0,'yes'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE NAME = 'Signout');
delimiter;


SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
INSERT INTO ld_tranlabel (
    languagetype,trantable,tabid,relateid,fieldlabel)
SELECT
    'zh','ld_tab' ,@tabid ,@tabid,'签退'
FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'zh'
                                     AND trantable = 'ld_tab'
    );

INSERT INTO ld_tranlabel (
    languagetype,trantable,tabid,relateid,fieldlabel)
SELECT
    'en','ld_tab' ,@tabid ,@tabid,'Sign out'
FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'en'
                                     AND trantable = 'ld_tab'
    );
delimiter;


SET @tabid = (select tabid from ld_tab where `name` = 'Signout');

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks
( blockid,tabid,blocklabel,sequence )
SELECT
    @blockid,@tabid,'LBL_LABEL',1
FROM DUAL WHERE
    NOT EXISTS
        ( SELECT * FROM ld_blocks WHERE tabid = @tabid
                                    AND blocklabel = 'LBL_LABEL'
                                    AND sequence = 1);
delimiter;

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks
( blockid,tabid,blocklabel,sequence )
SELECT
    @blockid,@tabid,'LBL_SIGNOUT_BASICINFORMATION',2
FROM DUAL WHERE
    NOT EXISTS
        ( SELECT * FROM ld_blocks WHERE tabid = @tabid
                                    AND blocklabel = 'LBL_SIGNOUT_BASICINFORMATION'
                                    AND sequence = 2);
delimiter;

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks
( blockid,tabid,blocklabel,sequence )
SELECT
    @blockid,@tabid,'LBL_FILE_INFORMATION',3
FROM DUAL WHERE
    NOT EXISTS
        ( SELECT * FROM ld_blocks WHERE tabid = @tabid
                                    AND blocklabel = 'LBL_FILE_INFORMATION'
                                    AND sequence = 3);
delimiter;

update ld_blocks_seq set id=@blockid;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_LABEL');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '标签' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and fieldlabel ='标签');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Label' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and fieldlabel ='BaLabelation');

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_SIGNOUT_BASICINFORMATION');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '基本信息' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and fieldlabel ='基本信息');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Basic Information' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and fieldlabel ='Basic Information');

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_FILE_INFORMATION');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '附件信息' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and fieldlabel ='附件信息');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Attachments Information' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and fieldlabel ='Attachments Information');
delimiter;

CALL getallprofile('Signout');
CALL fieldprofile('Signout');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
INSERT into ld_profileallpermission(`tabid`,`operation`,`sequence`) 
SELECT @tabid,operation,sequence FROM ld_profileallpermission WHERE tabid = (select tabid from ld_tab where `name` = 'Singin')
AND NOT EXISTS(select 1 from ld_profileallpermission where tabid= @tabid);

INSERT into ld_profile2standardpermissions(`profileid`,`tabid`,`operation`,`permissions`,`sequence`,`relatednames`) 
SELECT profileid,@tabid,operation,permissions,sequence,relatednames FROM ld_profile2standardpermissions WHERE tabid = (select tabid from ld_tab where `name` = 'Singin')
AND NOT EXISTS(select 1 from ld_profile2standardpermissions where tabid= @tabid);
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
SET @singin_tabid = (select tabid from ld_tab where `name` = 'Singin');
set @sequence = (select sequence from ld_parenttabrel where tabid = @singin_tabid LIMIT 1);
set @parenttabid = (select parenttabid from ld_parenttabrel where tabid = @singin_tabid LIMIT 1);
UPDATE ld_parenttabrel SET sequence = sequence+1 WHERE parenttabid = @parenttabid AND sequence > @sequence;

INSERT INTO ld_parenttabrel
(parenttabid,tabid,sequence,tab_tablename)
SELECT
    @parenttabid,@tabid,@sequence+1,'ld_tab'
FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_parenttabrel WHERE parenttabid = @parenttabid
                                        AND tabid = @tabid
                                        AND tab_tablename = 'ld_tab'
    );
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SIGNOUT_BASICINFORMATION';
set @tablename='ld_signout';
set @columnname='signout';
set @fieldname='signout';
set @zh='签退';
set @uitype=306;
set @bigtype='signin';
set @readonly=0;
set @presence=0;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~M';
set @quickcreate=0;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowhide='no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,2,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @tablename='ld_signout';
set @columnname='signout_time';
set @fieldname='signout_time';
set @zh='签退时间';
set @uitype=86;
set @bigtype='datetime';
set @readonly=0;
set @presence=0;
set @defaultvalue='thistoday';
set @displaytype=1;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @tablename='ld_signout';
set @columnname='signout_address';
set @fieldname='signout_address';
set @zh='签退地址';
set @uitype=1;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @tablename='ld_signout';
set @columnname='signout_distance';
set @fieldname='signout_distance';
set @zh='签退误差(米)';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @tablename='ld_signout';
set @columnname='signout_type';
set @fieldname='signout_type';
set @zh='签退方式';
set @uitype=1;
set @bigtype='translatefield';
set @readonly=1;
set @presence=0;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @tablename='ld_signout';
set @columnname='signout_imagename';
set @fieldname='signout_imagename';
set @zh='签退图片';
set @uitype=69;
set @bigtype='fileattachment';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit)
select @tabid,@fieldid+1,@columnname,@tablename,2,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @tablename='ld_signout';
set @columnname='timeused';
set @fieldname='timeused';
set @zh='用时';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

drop PROCEDURE if exists `addReferenceUitypmodule`;
delimiter ||
create PROCEDURE `addReferenceUitypmodule`(
  referenceuitype varchar(100)
)
begin
    select max(uitype+0) into @maxuitype from ld_ws_fieldtype;
    if @maxuitype<2000  then

                set @maxuitype=2000;

            else

                set @maxuitype=@maxuitype+1;
    end if;

        set @sql=concat('insert into ld_ws_fieldtype(uitype,fieldtype)value("',@maxuitype,'","reference")');
        prepare stmta from @sql;
        execute stmta;
    deallocate prepare stmta;
    set @sql=concat('select fieldtypeid  into @lastid from ld_ws_fieldtype where uitype ="',@maxuitype,'"');
    prepare stmt1 from @sql;
    execute stmt1;
    deallocate prepare stmt1;

    set @sql=concat('insert into ld_ws_referencetype(fieldtypeid,type)value("',@lastid,'","',referenceuitype,'")');
    prepare stmt2 from @sql;
    execute stmt2;
    deallocate prepare stmt2;
end ||
delimiter;
call addReferenceUitypmodule('Singin');
DROP PROCEDURE IF EXISTS `addReferenceUitypmodule`;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SIGNOUT_BASICINFORMATION';
set @tablename='ld_signout';
set @columnname='signin_id';
set @fieldname='signin_id';
set @zh='签到地址';
set @uitype=(SELECT max(uitype) FROM ld_ws_fieldtype LEFT JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid where ld_ws_referencetype.type='Singin');
set @bigtype='reference';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
set @showhyperlinks='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit,showhyperlinks)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit,@showhyperlinks from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @tablename='ld_signout';
set @columnname='source_list';
set @fieldname='source_list';
set @zh='拜访对象';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
set @parentbigtype='selectsource';
set @relatedmodulefield='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit,parentbigtype,relatedmodulefield)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit,@parentbigtype,@relatedmodulefield from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);
delimiter;

SET @singin_tabid = (select tabid from ld_tab where `name` = 'Singin');
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signin_id' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
SET @curmodule_columninfo='source_list';
SET @fromvalue_type='column';
SET @fromvalue_info='source_list';
SET @frommodule='Singin';

INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT 'main',@trigger_fieldid,@effect_fieldid,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SIGNOUT_BASICINFORMATION';
set @tablename='ld_signout';
set @columnname='entityaddress';
set @fieldname='entityaddress';
set @zh='拜访地址';
set @uitype=2;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
set @parentbigtype='text';
set @relatedmodulefield='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit,parentbigtype,relatedmodulefield)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit,@parentbigtype,@relatedmodulefield from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signin_id' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='entityaddress' LIMIT 1);
SET @curmodule_columninfo='entityaddress';
SET @fromvalue_type='column';
SET @fromvalue_info='entityaddress';
SET @frommodule='Singin';

INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT 'main',@trigger_fieldid,@effect_fieldid,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SIGNOUT_BASICINFORMATION';
set @tablename='ld_signout';
set @columnname='smownerid';
set @fieldname='assigned_user_id';
set @zh='负责人';
set @uitype=53;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SIGNOUT_BASICINFORMATION';
set @tablename='ld_signout';
set @columnname='smcreatorid';
set @fieldname='smcreatorid';
set @zh='创建人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @tabid=(select tabid from ld_tab where name="Signout");
SET @trantable='ld_field';

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout' LIMIT 1);
SET @zh='签退';
SET @en='Sign out';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_time' LIMIT 1);
SET @zh='签退时间';
SET @en='Sign out Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_address' LIMIT 1);
SET @zh='签退地址';
SET @en='Sign out Address';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_distance' LIMIT 1);
SET @zh='签退误差(米)';
SET @en='Sign out Distance(m)';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_type' LIMIT 1);
SET @zh='签退方式';
SET @en='Sign out way';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_imagename' LIMIT 1);
SET @zh='签退图片';
SET @en='Sign out photo';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='timeused' LIMIT 1);
SET @zh='用时';
SET @en='Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signin_id' LIMIT 1);
SET @zh='签到地址';
SET @en='Sign in Address';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
SET @zh='拜访对象';
SET @en='Customer Name';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='entityaddress' LIMIT 1);
SET @zh='拜访地址';
SET @en='Customer Address';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @zh='负责人';
SET @en='Owner';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @zh='创建人';
SET @en='Creator';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SELECT MAX(cvid) INTO @maxcvid FROM ld_customview;
INSERT INTO ld_customview (
    cvid,viewname,setdefault,setmetrics,entitytype,STATUS,userid,sequence
) SELECT
          @maxcvid + 1,'All',1,0,'Signout',3,1,1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype = 'Signout' AND viewname = 'All');

SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = 'Signout' AND viewname = 'All' );
INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,0,CONCAT('ld_',LOWER('Signout'),':','signout_time',':','signout_time',':','Signout','_fieldlabel:DT')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,1,CONCAT('ld_',LOWER('Signout'),':','signout_address',':','signout_address',':','Signout','_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,2,CONCAT('ld_',LOWER('Signout'),':','signout_distance',':','signout_distance',':','Signout','_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,3,CONCAT('ld_',LOWER('Signout'),':','signout_type',':','signout_type',':','Signout','_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,4,CONCAT('ld_',LOWER('Signout'),':','signout_imagename',':','signout_imagename',':','Signout','_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,5,CONCAT('ld_',LOWER('Signout'),':','timeused',':','timeused',':','Signout','_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,6,CONCAT('ld_',LOWER('Signout'),':','source_list',':','source_list',':','Signout','_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,7,CONCAT('ld_',LOWER('Signout'),':','address',':','address',':','Signout','_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,8,CONCAT('ld_',LOWER('Signout'),':','entityaddress',':','entityaddress',':','Signout','_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=8);

update ld_modentity_num_seq set id =( select max(num_id) from ld_modentity_num );
set @tabid=(select tabid from ld_tab where name="Signout");
INSERT INTO `ld_entityname`(`tabid`, `modulename`, `tablename`, `fieldname`, `entityidfield`, `entityidcolumn`)
SELECT @tabid, 'Signout', 'ld_signout', 'signout_address', 'signoutid', 'signoutid' FROM  DUAL  where not exists (select 1 from ld_entityname where  tabid =@tabid);

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'signout_type','Signout','signout','SIGNOUT2' from dual
where not exists(select 1 from ld_translatefield where module='Signout' and columnname='signout_type' and column_Dbvalue='signout');
delimiter;
insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'signout_type','Signout','supsignout','SUPSIGN' from dual
where not exists(select 1 from ld_translatefield where module='Signout' and columnname='signout_type' and column_Dbvalue='supsignout');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SIGNOUT2','签退','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SIGNOUT2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SIGNOUT2','Sign out','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SIGNOUT2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUPSIGN','补签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SUPSIGN' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUPSIGN','Supplementary sign out','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SUPSIGN' and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @tabid = (select tabid from ld_tab where name = "Signout");
set @fieldid = (select fieldid from ld_field where tabid = @tabid and columnname = 'distince');
UPDATE ld_tranlabel Set `fieldlabel` = "签到误差(米)" WHERE `fieldlabel` = "误差(米)" and tabid = @tabid and `Relateid` = @fieldid;

set @tabid = (select tabid from ld_tab where name = "Signout");
set @fieldid = (select fieldid from ld_field where tabid = @tabid and columnname = 'imagename');
UPDATE ld_tranlabel Set `fieldlabel` = "签到照片" WHERE `fieldlabel` = "照片" and tabid = @tabid and `Relateid` = @fieldid;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotSignedOut','未签退','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotSignedOut' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotSignedOut','Not signed out','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotSignedOut' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SignedOut','已签退','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SignedOut' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SignedOut','Signed out','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SignedOut' and Labeltype='fixedstr' and languagetype='en');
delimiter;


call AddColumn('ld_singin','signout_id','int',11,'');
call AddColumn('ld_singin','signout_time','datetime','','');
call AddColumn('ld_singin','signout_distance','varchar',20,'');
call AddColumn('ld_singin','signout_type','varchar',20,'');
call AddColumn('ld_singin','signout_imagename','varchar',200,'');
call AddColumn('ld_singin','timeused','varchar',50,'');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SINGIN_BASICINFORMATION';


drop PROCEDURE if exists `addReferenceUitypmodule`;
delimiter ||
create PROCEDURE `addReferenceUitypmodule`(
  referenceuitype varchar(100)
)
begin
    select max(uitype+0) into @maxuitype from ld_ws_fieldtype;
    if @maxuitype<2000  then

                set @maxuitype=2000;

            else

                set @maxuitype=@maxuitype+1;
    end if;

        set @sql=concat('insert into ld_ws_fieldtype(uitype,fieldtype)value("',@maxuitype,'","reference")');
        prepare stmta from @sql;
        execute stmta;
    deallocate prepare stmta;
    set @sql=concat('select fieldtypeid  into @lastid from ld_ws_fieldtype where uitype ="',@maxuitype,'"');
    prepare stmt1 from @sql;
    execute stmt1;
    deallocate prepare stmt1;

    set @sql=concat('insert into ld_ws_referencetype(fieldtypeid,type)value("',@lastid,'","',referenceuitype,'")');
    prepare stmt2 from @sql;
    execute stmt2;
    deallocate prepare stmt2;
end ||
delimiter;
call addReferenceUitypmodule('Signout');
DROP PROCEDURE IF EXISTS `addReferenceUitypmodule`;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SINGIN_BASICINFORMATION';
set @tablename='ld_singin';
set @columnname='signout_id';
set @fieldname='signout_id';
set @zh='签退地址';
set @uitype=(SELECT max(uitype) FROM ld_ws_fieldtype LEFT JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid where ld_ws_referencetype.type='Signout');
set @bigtype='reference';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
set @showhyperlinks='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit,showhyperlinks)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit,@showhyperlinks from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SINGIN_BASICINFORMATION';
set @tablename='ld_singin';
set @columnname='signout_time';
set @fieldname='signout_time';
set @zh='签退时间';
set @uitype=86;
set @bigtype='datetime';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
set @parentbigtype='datetime';
set @relatedmodulefield='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit,parentbigtype,relatedmodulefield)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit,@parentbigtype,@relatedmodulefield from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);
delimiter;

SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_id' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_time' LIMIT 1);
SET @curmodule_columninfo='signout_time';
SET @fromvalue_type='column';
SET @fromvalue_info='signout_time';
SET @frommodule='Signout';

INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT 'main',@trigger_fieldid,@effect_fieldid,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SINGIN_BASICINFORMATION';
set @tablename='ld_singin';
set @columnname='signout_distance';
set @fieldname='signout_distance';
set @zh='签退误差(米)';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
set @parentbigtype='text';
set @relatedmodulefield='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit,parentbigtype,relatedmodulefield)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit,@parentbigtype,@relatedmodulefield from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);
delimiter;

SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_id' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_distance' LIMIT 1);
SET @curmodule_columninfo='signout_distance';
SET @fromvalue_type='column';
SET @fromvalue_info='signout_distance';
SET @frommodule='Signout';

INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT 'main',@trigger_fieldid,@effect_fieldid,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SINGIN_BASICINFORMATION';
set @tablename='ld_singin';
set @columnname='signout_type';
set @fieldname='signout_type';
set @zh='签退方式';
set @uitype=1;
set @bigtype='translatefield';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
set @parentbigtype='translatefield';
set @relatedmodulefield='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit,parentbigtype,relatedmodulefield)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit,@parentbigtype,@relatedmodulefield from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);
delimiter;

SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_id' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_type' LIMIT 1);
SET @curmodule_columninfo='signout_type';
SET @fromvalue_type='column';
SET @fromvalue_info='signout_type';
SET @frommodule='Signout';

INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT 'main',@trigger_fieldid,@effect_fieldid,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SINGIN_BASICINFORMATION';
set @tablename='ld_singin';
set @columnname='signout_imagename';
set @fieldname='signout_imagename';
set @zh='签退图片';
set @uitype=69;
set @bigtype='fileattachment';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
set @parentbigtype='fileattachment';
set @relatedmodulefield='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit,parentbigtype,relatedmodulefield)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit,@parentbigtype,@relatedmodulefield from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);
delimiter;

SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_id' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_imagename' LIMIT 1);
SET @curmodule_columninfo='signout_imagename';
SET @fromvalue_type='column';
SET @fromvalue_info='signout_imagename';
SET @frommodule='Signout';

INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT 'main',@trigger_fieldid,@effect_fieldid,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SINGIN_BASICINFORMATION';
set @tablename='ld_singin';
set @columnname='timeused';
set @fieldname='timeused';
set @zh='用时';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=2;
set @allowedit='no';
set @parentbigtype='text';
set @relatedmodulefield='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowedit,parentbigtype,relatedmodulefield)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,'',@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowedit,@parentbigtype,@relatedmodulefield from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);


SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_id' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='timeused' LIMIT 1);
SET @curmodule_columninfo='timeused';
SET @fromvalue_type='column';
SET @fromvalue_info='timeused';
SET @frommodule='Signout';

INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT 'main',@trigger_fieldid,@effect_fieldid,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;


set @tabid=(select tabid from ld_tab where name="Singin");
SET @trantable='ld_field';
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_time' LIMIT 1);
SET @zh='签退时间';
SET @en='Sign out Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_id' LIMIT 1);
SET @zh='签退地址';
SET @en='Sign out Address';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_distance' LIMIT 1);
SET @zh='签退误差(米)';
SET @en='Sign out Distance(m)';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_type' LIMIT 1);
SET @zh='签退方式';
SET @en='Sign out way';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signout_imagename' LIMIT 1);
SET @zh='签退图片';
SET @en='Sign out photo';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='timeused' LIMIT 1);
SET @zh='用时';
SET @en='Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'signout_type','Singin','signout','SIGNOUT2' from dual
where not exists(select 1 from ld_translatefield where module='Singin' and columnname='signout_type' and column_Dbvalue='signout');
delimiter;
insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'signout_type','Singin','supsignout','SUPSIGN' from dual
where not exists(select 1 from ld_translatefield where module='Singin' and columnname='signout_type' and column_Dbvalue='supsignout');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseSelectConsClickQuery','请选择条件后点击查询','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSelectConsClickQuery' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseSelectConsClickQuery','Please select the conditions and click on Query','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSelectConsClickQuery' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk set fieldlabel='管理员已设置未签退时不允许再次签到，是否前往历史记录中签退？' WHERE labelbol='NotAllowSigninPleaseSignout' and languagetype='zh';
UPDATE ld_desk set fieldlabel='The admin has set that no one is allowed to sign in again without signing out,whether to go to the history to sign out?' WHERE labelbol='NotAllowSigninPleaseSignout' and languagetype='en';
delimiter;
-- 2024-03-29


SET @disable_triggers=NULL;
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
UPDATE ld_customview_seq SET id = (SELECT MAX(cvid) FROM ld_customview);
UPDATE ld_links_seq SET id=(SELECT MAX(linkid) FROM ld_links);
UPDATE ld_picklist_dependency_seq SET id=(SELECT MAX(id) FROM ld_picklist_dependency);
UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
UPDATE ld_approve_seq SET id=(SELECT MAX(id) FROM ld_approve);
UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);
UPDATE ld_autotask_seq SET id = (SELECT MAX(autotaskid) FROM ld_autotask);
UPDATE ld_currency_info_seq SET id=(SELECT MAX(id) FROM ld_currency_info);
UPDATE ld_users_seq SET id=(SELECT MAX(id) FROM ld_users);
UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
UPDATE ld_customreport_info_seq SET id=(SELECT MAX(report_id) FROM ld_customreport_info);
UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT MAX(fieldid) FROM ld_settings_field);
UPDATE ld_workreport_field_seq SET id=(SELECT MAX(id) FROM ld_workreport_field);
delimiter;

UPDATE ld_version SET old_version='V8.6.2.8',current_version='V8.6.2.8',remark='V8.6.2.8-20240329',wx_version='V8.6.2.8';
delimiter;