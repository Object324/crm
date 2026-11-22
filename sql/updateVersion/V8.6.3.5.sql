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

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE PROCEDURE `addtableIndex`(tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50))
BEGIN
	
	SELECT DATABASE() into @datebase;

	SET @sql2=CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	IF @cnt=0 THEN 
		SET @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
  END IF;
	
end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_shoukuanrenlingdan_20240514`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_shoukuanrenlingdan_20240514`(
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ld_collectionslip) OR EXISTS (SELECT 1 FROM ld_validatasavedetail WHERE relateid IS NULL AND relatefieldname='hdnGrandTotal') THEN
		DELETE FROM ld_validatasavedetail WHERE relateid IN (SELECT id FROM ld_validatasave WHERE module='CollectionSlip');
		DELETE FROM ld_validatasave WHERE module='CollectionSlip';
		DELETE FROM ld_validatasavemain WHERE module='CollectionSlip';

		INSERT INTO `ld_validatasavemain` (
			`rulename`, 
			`module`, 
			`actionprevent`, 
			`tipzhtype`, 
			`tipzh`,

			`tipen`, 
			`conditiongroup`, 
			`validataapplication`, 
			`relatedtable`, 
			`sequence`
		) 
		SELECT
			'合计金额必须等于收款金额或者为零', 
			'CollectionSlip', 
			'yes', 
			'text', 
			'分录的金额合计必须等于认领单的收款金额！', 

			'The total amount of the entry shall be equal to the amount of the receipt.',
			'[null,{"groupcondition":""}]', 
			'create,edit', 
			'ld_field', 
			'1';

		SET @main_id=(SELECT id FROM ld_validatasavemain WHERE module='CollectionSlip' AND rulename='合计金额必须等于收款金额或者为零' LIMIT 1);
		INSERT INTO `ld_validatasave` (
			`module`, 
			`relatedtable`, 
			`fieldname`, 
			`comparator`,
			`status`, 
			`allowsave`, 
			`funtype`,
			`validatasavemainid`,
			`valid_condition`
		)
		SELECT
			'CollectionSlip', 
			'ld_field', 
			'collected_amount',
			'e',
			'active',
			'no',
			'fields',
			@main_id,
			'or';

		SET @valid_id=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@main_id AND module='CollectionSlip' AND fieldname='collected_amount' LIMIT 1);
		INSERT INTO `ld_validatasavedetail` (
			`relateid`,
			`relatefieldname`, 
			`relatedtable`, 
			`funtype`
		) 
		SELECT
			@valid_id,
			'hdnGrandTotal',
			'ld_field', 
			'fields';

		INSERT INTO `ld_validatasave` (
			`module`, 
			`relatedtable`, 
			`fieldname`, 
			`comparator`,
			`status`, 
			`allowsave`, 
			`funtype`,
			`validatasavemainid`,
			`valid_condition`
		)
		SELECT
			'CollectionSlip', 
			'ld_field', 
			'collected_amount',
			'e',
			'active',
			'no',
			'fields',
			@main_id,
			'';


		SET @valid_id=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@main_id AND module='CollectionSlip' AND fieldname='amount' LIMIT 1);
		INSERT INTO `ld_validatasavedetail` (
			`relateid`,
			`relatefieldname`, 
			`relatedtable`, 
			`funtype`
		) 
		SELECT
			@valid_id,
			'0',
			'ld_field', 
			'number';


		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='CollectionSlip');
		DELETE FROM ld_workflow_excutesql WHERE id IN (
			SELECT
				b.id
			FROM ld_workflow a
			LEFT JOIN ld_workflow_actions b ON b.workflow_id=a.id
			WHERE a.tabid=@tabid
		);
		DELETE FROM ld_workflow_actions WHERE workflow_id IN (SELECT id FROM ld_workflow WHERE tabid=@tabid);
		DELETE FROM ld_workflow WHERE tabid=@tabid;

		SET @maxid=IFNULL((SELECT MAX(id) FROM ld_workflow),0)+1;
		INSERT INTO `ld_workflow` (
			`id`, 
			`tabid`, 
			`name`, 
			`status`, 
			`description`, 

			`triggertime`, 
			`repeatmode`, 
			`approvalnode`, 
			`deleted`, 
			`createdtime`, 
			`advft_criteria`, 
			`advft_criteria_groups`
		) 
		SELECT
			@maxid, 
			@tabid,
			'客户名称为空时则根据汇款户名查询并关联相应的客户和负责人', 
			'Active', 
			'仅在新建的时候进行一次判断', 

			'Creation', 
			'every', 
			NULL, 
			'0', 
			NOW(), 
			'[{\"groupid\":\"1\",\"columnname\":\"\",\"comparator\":\"无\",\"value\":\"\",\"columncondition\":\"\"}]', 
			'[null,{\"groupcondition\":\"\"}]';


		UPDATE ld_workflow_seq SET id=(SELECT MAX(id) FROM ld_workflow);
		
		INSERT INTO `ld_workflow_actions` (
			`workflow_id`, 
			`action_title`, 
			`action_type`, 
			`api_url`, 
			`api_jsondata`, 
			`status`, 
			`createdtime`, 
			`deleted`, 
			`body_query_type`, 
			`sequence`, 
			`api_receive_msg`
		) 
		SELECT
			@maxid, 
			'如果有该客户，则自动选择相应客户和负责人', 
			'ExcuteSql', 
			NULL, 
			NULL, 
			'Active', 
			NOW(), 
			'0', 
			'form-data', 
			'1', 
			'no';

		SET @action_id=(SELECT id FROM ld_workflow_actions WHERE workflow_id=@maxid LIMIT 1);

		INSERT INTO ld_workflow_excutesql(
			workflow_action_id,
			query_sql
		)
		SELECT 
			@action_id,
			"UPDATE ld_collectionslip a
INNER JOIN ld_account b ON b.accountname=a.remit_account_name
SET 
a.accountid=b.accountid,
a.smownerid=b.smownerid
WHERE a.collectionslip_id='{Record.ID}'
AND b.deleted=0
AND IFNULL(a.accountid,0)  = 0;";


		SET @maxid=IFNULL((SELECT MAX(id) FROM ld_workflow),0)+1;
		INSERT INTO `ld_workflow` (
			`id`, 
			`tabid`, 
			`name`, 
			`status`, 
			`description`, 

			`triggertime`, 
			`repeatmode`, 
			`approvalnode`, 
			`deleted`, 
			`createdtime`, 
			`advft_criteria`, 
			`advft_criteria_groups`
		) 
		SELECT
			@maxid, 
			@tabid,
			'收款认领单通过审批通过后自动创建收款单', 
			'Active', 
			'', 

			'Approval', 
			'every', 
			'Approved', 
			'0', 
			NOW(), 
			'[{\"groupid\":\"1\",\"columnname\":\"\",\"comparator\":\"无\",\"value\":\"\",\"columncondition\":\"\"}]', 
			'[null,{\"groupcondition\":\"\"}]';


		UPDATE ld_workflow_seq SET id=(SELECT MAX(id) FROM ld_workflow);
		
		INSERT INTO `ld_workflow_actions` (
			`workflow_id`, 
			`action_title`, 
			`action_type`, 
			`api_url`, 
			`api_jsondata`, 
			`status`, 
			`createdtime`, 
			`deleted`, 
			`body_query_type`, 
			`sequence`, 
			`api_receive_msg`
		) 
		SELECT
			@maxid, 
			'收款认领单自动创建对应的收款单', 
			'ExcuteSql', 
			NULL, 
			NULL, 
			'Active', 
			NOW(), 
			'0', 
			'form-data', 
			'1', 
			'no';

		SET @action_id=(SELECT id FROM ld_workflow_actions WHERE workflow_id=@maxid LIMIT 1);

		INSERT INTO ld_workflow_excutesql(
			workflow_action_id,
			query_sql
		)
		SELECT 
			@action_id,
			"CALL autocreatecashbillbycollectionsslip_where('{Record.ID}');";

	END IF;
end ||
delimiter;

CALL ldcrm_reset_shoukuanrenlingdan_20240514();
DROP PROCEDURE IF EXISTS `ldcrm_reset_shoukuanrenlingdan_20240514`;
delimiter;

DELETE FROM ld_validatasavedetail WHERE relateid IS NULL;
delimiter;

UPDATE ld_field SET allowedit='yes',typeofdata='N~O~25,2' WHERE tablename='ld_salary' AND columnname IN ('phone_allowance','traffic_allowance');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='CollectionSlip' LIMIT 1);
SET @detailfieldid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='total' LIMIT 1);
INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
SELECT @detailfieldid,'sum(a)',"{formulavar:[{'lettervar':'a','column':'amount'}]}",1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@detailfieldid);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Salary');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_SALARYOTHERPAYABLE_INFO' LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) 
SELECT 'zh','ld_blocks',@tabid,@blockid,'其他应发' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND Relateid=@blockid AND languagetype='zh');

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Salary');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_SALARYOTHERPAYABLE_INFO' LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) 
SELECT 'en','ld_blocks',@tabid,@blockid,'Other Payables' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND Relateid=@blockid AND languagetype='en');
delimiter;

ALTER TABLE ld_picklist_dependency MODIFY COLUMN sourcevalue varchar(255);
delimiter;

UPDATE ld_systems_deploy SET presence = 1 WHERE deploy_type = 204;
delimiter;

call AddColumn('ld_publicleads_remindtableview','ids','text','','yes');
call AddColumn('ld_publicaccount_remindtableview','ids','text','','yes');
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
DELIMITER ||
CREATE   PROCEDURE `account_singlerecycle_normal_rule`(new_normal_id 	int(11),new_pool_id 	int(11))
BEGIN
	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
  DECLARE var_smownercolumn varchar(50);
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
                                   ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
                                                                                                                                              ,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                                                                                                                                                                                                      INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

declare continue handler  for not   found  SET done =1;
select if(ld_users.id>0,ld_account_public_pool.userid_after_transfer,0) into @allotaccount from ld_account_public_pool
                                                                                                    LEFT join ld_users on ld_users.id =ld_account_public_pool.userid_after_transfer where ld_account_public_pool.id = new_pool_id;
if  ifnull(@allotaccount,0)=0  then
			set @allotaccount=0;
end if;
    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
select max(ld_account_set_rule_normal.days) into @maxdays
from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                 INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;
set @account_rule_pool_id = new_pool_id;

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

    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

end if;
          set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
    					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
    						and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
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

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    			if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
    			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
    				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
end if;
else
    			 if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
ELSE
    					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
end if;

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
end if;

    	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) ',@TMPSQL_TWO);
prepare stmt from @TMPSQL_THREE;
execute stmt;
deallocate prepare stmt;


set @tmp_namelink='\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,\'</a>\'';
    		if var_condition='or'  then
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from    ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    		   if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
    		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    			if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
end if;

delete from ld_publicaccount_remindtableview ;

set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicaccount_recoveryreminds();


if var_condition='or'  then
    			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');

    		      if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
    				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
							if @allotaccount>0 THEN
							set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
end if;
    					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;

ELSE
    				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
							if @allotaccount>0 THEN
								set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
end if;

						set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');

end if;
prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;
end if;
END IF;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule_beforeremind`(
    new_normal_id 	int(11),
    new_pool_id 	int(11)
        )
    label_a:
BEGIN
	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
                                   ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
                                                                                                                                                ,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                                                                                                                                                                                                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
select max(ld_account_set_rule_normal.days) into @maxdays
from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                 INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;

select beforereminddays into @var_beforereminddays from ld_account_public_pool where id = new_pool_id;
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
else
    				set	var_smownercolumn='smownerid' ;
end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

end if;

               set @tmpsqltwo=concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime , '",var_tabname,"' as remindtabname from ld_account LEFT JOIN (select ld_account.accountid from ld_account inner join ",var_tablename,' on ld_account.accountid=',
                    var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


    			IF var_iscycle = 'yes' then
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
ELSE
						set @tmpthree=@tmpsqltwo;
end if;

    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account inner join "  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
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
    				 set @TMP_TMPTable=concat(' ( select  concat("(",GROUP_CONCAT(ld_tranlabel.fieldlabel),")")  from ld_account_set_rule_normal
							INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname
							INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
							and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
							where ld_account_set_rule_normal.status="active" and normal_id = ',new_normal_id,' ORDER BY ld_account_set_rule_normal.sequence asc ) ');
						set @tmp_namelink=concat('<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,',@TMP_TMPTable,',\'</a>');
    				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid ') ;
ELSE
    					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid') ;
end if;
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,lingdangtmp.fieldlabel,\'</a>\'');
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(',@tmp_namelink,'  separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid'  );
end if;

delete from ld_publicaccount_remindtableview ;
set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicaccount_beforereminds();
end if;
END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule`;
DELIMITER ||
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

	declare cur1 CURSOR FOR
select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days,ld_account_set_rule.otherwhere from ld_account_set_rule
                                                                                                                                                                            inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
                                                                                                                                                                            INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and (ld_field.presence in(0,2))
where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;

declare continue handler  for not found SET done =1;
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

set @tmp_namelink='\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,\'</a>\'';
if var_condition='or'  then
			set @TMPSQL_ONE=concat( 'select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_account.accountid) as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
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
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'   group by ld_account.smownerid    ');
end if;

delete from ld_publicaccount_remindtableview ;


set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids ) ", @TMPSQL_TWO);

call crm_publicaccount_recoveryreminds();
if @allotaccount>0 then
select  tmp.tablename into @grouptablename  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field
                                                                                                                                          INNER JOIN ld_related_field on ld_related_field.effect_fieldid=ld_field.fieldid where ld_field.uitype=1600  )  as  tmp
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

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_rule_beforeremind`(IN tmp_pool_id INT(11))
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

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')
                                                                                                                                                                                                                          INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
select max(ld_account_set_rule.days) into @maxdays
from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
                          INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;

select beforereminddays into @var_beforereminddays  from ld_account_public_pool where  id = tmp_pool_id;


if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
		leave label_a ;
end if;
select userid_after_release into @allotaccount from ld_account_public_pool where id = tmp_pool_id;
select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;


if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
		 set @old_days=var_days;
		 set var_days=var_days-@var_beforereminddays;

			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
else
				set	var_smownercolumn='smownerid' ;
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate) BETWEEN ",var_days,' and ' ,@old_days);
end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >=",var_days);
					IF var_iscycle = 'yes' then
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
ELSE
						set @tmpthree=@tmpsqltwo;
end if;
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_account.smownerid ' );
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
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.`status`='active' ORDER BY ld_account_set_rule.sequence asc ) ";
			set @tmp_namelink=concat('<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,',@TMP_TMPTable,',\'</a>');
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountidfrom ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',var_days);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
			if @recycleselect is not null and @recycleselect<>'' then
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
end if;
				set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,lingdangtmp.fieldlabel,\'</a>\'');
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(distinct ld_account.accountid)
							as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid  from ld_account  inner join ( ',@sql,' ) as lingdangtmp
							on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'  group by ld_account.smownerid ');
end if;
delete from ld_publicaccount_remindtableview ;

set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;
call crm_publicaccount_beforereminds();
end if;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `crm_publicaccount_recoveryreminds`;
delimiter ||
CREATE  PROCEDURE `crm_publicaccount_recoveryreminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare var_ids text;

	declare parent_remindsid int(19); -- 父提醒id
	declare accountid int(19); -- 当前分割出的字符串(客户id)
	declare remindid int(19); -- 子提醒id
  declare i INT DEFAULT 1;

	declare done int  default 0;
  declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
declare continue handler for not found SET done =1;

OPEN cur1;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
loop1: while done<>1 DO
			set i=1;
			if var_totalaccounts>0 then
				if var_type='normal' or var_type='singlenormal' THEN
					set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Accounts',0,'AccountsRECYCLEREMIND',parent_remindsid);
elseif var_type='complete' THEN
					set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Accounts',0,'AccountsRECYCLEREMIND',parent_remindsid);
else
					set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Accounts',0,'AccountsRECYCLEREMIND',parent_remindsid);
end if;

				-- 循环提取每个部分的accountid并生成提醒
				WHILE i <= var_totalaccounts DO
					SET accountid = SUBSTRING_INDEX(SUBSTRING_INDEX(var_ids, '##', i), '##', -1);
					-- 生成提醒
					set @remind_content="您的客户未达成目标，已被回收到公海池。";
call ldcrm_add_reminder_havetype_returnid(@remind_content,var_smownerid,'Accounts',accountid,'AccountsRECYCLEREMIND',remindid);
update ld_reminds set deleted=1,parentid=parent_remindsid where remindsid=remindid;
SET i = i + 1;
END WHILE;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
end while loop1;
close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `crm_publicaccount_beforereminds`;
delimiter ||
CREATE  PROCEDURE `crm_publicaccount_beforereminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare var_ids text;

	declare parent_remindsid int(19); -- 父提醒id
	declare accountid int(19); -- 当前分割出的字符串(客户id)
	declare remindid int(19); -- 子提醒id
  declare i INT DEFAULT 1;

	declare done  int  default 0;
  declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
declare continue handler  for not   found  SET done =1;
OPEN cur1;

Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
loop1: while  done<>1 DO
		set i=1;
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，即将要回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Accounts',0,'AccountsBEFOREREMIND',parent_remindsid);
elseif var_type='complete' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Accounts',0,'AccountsBEFOREREMIND',parent_remindsid);
end if;

			-- 循环提取每个部分的accountid并生成提醒
			WHILE i <= var_totalaccounts DO
				SET accountid = SUBSTRING_INDEX(SUBSTRING_INDEX(var_ids, '##', i), '##', -1);
				-- 生成提醒
				set @remind_content="您的客户未达成目标，即将要被回收到公海池。";
call ldcrm_add_reminder_havetype_returnid(@remind_content,var_smownerid,'Accounts',accountid,'AccountsBEFOREREMIND',remindid);
update ld_reminds set deleted=1,parentid=parent_remindsid where remindsid=remindid;
SET i = i + 1;
END WHILE;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
end while loop1;
close cur1;

end ||
delimiter;

drop PROCEDURE if EXISTS leads_singlerecycle_normal_rule;
delimiter ||
create PROCEDURE leads_singlerecycle_normal_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
   DECLARE var_smownercolumn varchar(50);
	declare var_leadsidcolumnname varchar(100);
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

if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
							set var_leadsidcolumnname='record';
else
    				set	var_smownercolumn='smownerid' ;
						set var_leadsidcolumnname='leads_id';
end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from ld_leads ");
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
          set @tmpsqltwo=concat('select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from  ld_leads LEFT JOIN(select ld_leads.leadsid
    					from ld_leads inner join ',var_tablename,' on ld_leads.leadsid=',var_tablename,'.',var_leadsidcolumnname,'
    						and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');
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

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    			if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
    			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)'  );
    				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null  and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
end if;
else
    			 if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.leadsid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid  group by tmpone.leadsid ') ;
ELSE
    					set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
end if;

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)'  );
end if;

    	   set @TMPSQL_THREE=concat('insert into ld_logpublicleads(username,operation,opdate,leadsid,pool_id) ',@TMPSQL_TWO);
prepare stmt from @TMPSQL_THREE;
execute stmt;
deallocate prepare stmt;


set @tmp_namelink='\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,\'</a>\'';
    		if var_condition='or'  then
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    		   if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)    ');
    		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    			if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
else
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1) group by ld_leads.smownerid    ');
end if;

delete from ld_publicleads_remindtableview ;

set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_recoveryreminds();


if var_condition='or'  then
    			  	set @TMPSQL_ONE=concat( ' update  ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ');

    		      if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
    				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_leads.publicaccount=1,ld_leads.pool_id=',@leads_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;

    					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');
    		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
end if;
ELSE
    				set @TMPSQL_ONE=concat( ' update  ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid set ld_leads.publicaccount=1,ld_leads.pool_id=',@leads_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
    		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');

end if;
prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;
END IF;

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
						set @tmp_namelink=concat('<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,',@TMP_TMPTable,',\'</a>');
    				set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;

    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,lingdangtmp.fieldlabel,\'</a>\'');
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountname,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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

drop PROCEDURE if EXISTS leads_singlerecycle_highsea_rule;
delimiter ||
create PROCEDURE leads_singlerecycle_highsea_rule( tmp_pool_id  int(19))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
declare var_leadsidcolumnname varchar(100);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
                                 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                                                                                       INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and (ld_field.presence in(0,2) ) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;
declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
select max(ld_leads_set_rule.days) into @maxdays
from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2)
where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;

select userid_after_release into @allotaccount from ld_leads_public_pool where id = tmp_pool_id;
select recycleselect into @recycleselect from ld_leads_public_pool where id = tmp_pool_id;

if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
					set var_leadsidcolumnname='record';
else
				set	var_smownercolumn='smownerid' ;
				set var_leadsidcolumnname='leads_id';
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_leads.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_leads.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)>",var_days);
end if;
					set @tmpsqltwo=concat('select ld_leads.leadsid,ld_leads.allocatedate from  ld_leads LEFT JOIN(select ld_leads.leadsid
							from ld_leads inner join ',var_tablename,' on ld_leads.leadsid=',var_tablename,'.',var_leadsidcolumnname,'
								and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');

				set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );

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
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then

			set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id =  ',tmp_pool_id);

			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);

			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
end if;
else
				if @recycleselect is not null and @recycleselect<>'' then

					set @sql=concat(' select tmpone.leadsid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid  group by tmpone.leadsid ') ;
ELSE
					set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
end if;

			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);

end if;

	   set @TMPSQL_THREE=concat('insert into ld_logpublicleads(username,operation,opdate,leadsid,pool_id) ',@TMPSQL_TWO);
prepare stmt from @TMPSQL_THREE;
execute stmt;
deallocate prepare stmt;

set @tmp_namelink='\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,\'</a>\'';
    if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0  and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3)   group by ld_leads.smownerid    ');
end if;
delete from ld_publicleads_remindtableview ;

set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_recoveryreminds();

if var_condition='or'  then

			 set @TMPSQL_ONE=concat( ' update  ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ');
		  if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
			set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_leads.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
end if;
ELSE

			  set @TMPSQL_ONE=concat( ' update  ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid set ld_leads.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
end if;

prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;



end ||
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
			set @tmp_namelink=concat('<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,',@TMP_TMPTable,',\'</a>');
			set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,lingdangtmp.fieldlabel,\'</a>\'');
			set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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

drop PROCEDURE if exists crm_publicleads_recoveryreminds;
delimiter ||
create PROCEDURE crm_publicleads_recoveryreminds()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare var_ids text;

	declare parent_remindsid int(19); -- 父提醒id
	declare leadsid int(19); -- 当前分割出的字符串(客户id)
	declare remindid int(19); -- 子提醒id
  declare i INT DEFAULT 1;

	declare done  int  default 0;
  declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
declare continue handler  for not   found  SET done =1;

OPEN cur1;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
loop1: while  done<>1 DO
		set i=1;
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND',parent_remindsid);
elseif var_type='complete' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND',parent_remindsid);
else
				set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND',parent_remindsid);

-- 循环提取每个部分的leadsid并生成提醒
WHILE i <= var_totalaccounts DO
					SET leadsid = SUBSTRING_INDEX(SUBSTRING_INDEX(var_ids, '##', i), '##', -1);
					-- 生成提醒
					set @remind_content="您的线索未达成目标，已被回收到公海池。";
call ldcrm_add_reminder_havetype_returnid(@remind_content,var_smownerid,'Leads',leadsid,'LeadsRECYCLEREMIND',remindid);
update ld_reminds set deleted=1,parentid=parent_remindsid where remindsid=remindid;
SET i = i + 1;
END WHILE;
end if;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
end while loop1;
close cur1;

end ||
delimiter;

drop PROCEDURE if exists crm_publicleads_beforereminds;
delimiter ||
create PROCEDURE crm_publicleads_beforereminds()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare var_ids text;

	declare parent_remindsid int(19); -- 父提醒id
	declare leadsid int(19); -- 当前分割出的字符串(客户id)
	declare remindid int(19); -- 子提醒id
  declare i INT DEFAULT 1;

	declare done  int  default 0;
  declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
declare continue handler  for not   found  SET done =1;
OPEN cur1;

Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
loop1: while  done<>1 DO
		set i=1;
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsBEFOREREMIND',parent_remindsid);
elseif var_type='complete' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsBEFOREREMIND',parent_remindsid);
end if;

			-- 循环提取每个部分的leadsid并生成提醒
			WHILE i <= var_totalaccounts DO
				SET leadsid = SUBSTRING_INDEX(SUBSTRING_INDEX(var_ids, '##', i), '##', -1);
				-- 生成提醒
				set @remind_content="您的线索未达成目标，已被回收到公海池。";
call ldcrm_add_reminder_havetype_returnid(@remind_content,var_smownerid,'Leads',leadsid,'LeadsBEFOREREMIND',remindid);
update ld_reminds set deleted=1,parentid=parent_remindsid where remindsid=remindid;
SET i = i + 1;
END WHILE;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
end while loop1;
close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_reminder_havetype_returnid`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_reminder_havetype_returnid`(
    tmp_content text,
    tmp_recieverid INT(19),
    tmp_reltab VARCHAR(100),
    tmp_related_to INT(19),
    tmp_remindstype VARCHAR(100),
    OUT remindid INT
        )
BEGIN

	SET @max_remindid=(SELECT MAX(crmid) FROM ld_crmentity);
		IF EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid=@max_remindid+1) OR EXISTS (SELECT 1 FROM ld_reminds WHERE remindsid=@max_remindid+1) OR EXISTS (SELECT 1 FROM ld_reminds_accepted WHERE remindsid=@max_remindid+1) THEN
			SET @max_remindid=(SELECT MAX(crmid)+10 FROM ld_crmentity);
END IF;

INSERT INTO ld_crmentity(crmid,setype)
SELECT @max_remindid+1,'Reminds';

UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);

INSERT INTO ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted,remindstype)
SELECT @max_remindid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0,tmp_remindstype;
select @max_remindid+1 into remindid ;
end ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LeadsBEFOREREMIND','【{$Leads.Leads}】即将回收提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LeadsBEFOREREMIND' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LeadsBEFOREREMIND','【{$Leads.Leads}】About to recycle Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LeadsBEFOREREMIND' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AccountsBEFOREREMIND','【{$Accounts.Accounts}】即将回收提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AccountsBEFOREREMIND' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AccountsBEFOREREMIND','【{$Accounts.Accounts}】About to recycle Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AccountsBEFOREREMIND' and labeltype='fixedstr');
delimiter;
-- 2024-05-14

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

UPDATE ld_version SET old_version='V8.6.3.5',current_version='V8.6.3.5',remark='V8.6.3.5-20240514',wx_version='V8.6.3.3';
delimiter;