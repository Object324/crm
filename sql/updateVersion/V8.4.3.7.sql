DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF IFNULL(tmp_defaultvalue,'')='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
	END IF;

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

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')
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
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >=",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
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
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
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

			 set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
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

			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;

				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'  group by ld_account.smownerid    ');
		end if;
		delete from ld_publicaccount_remindtableview ;
        set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

        call crm_publicaccount_beforereminds();
	end if;
end ||
delimiter;

update ld_field set advance_demand='' where advance_demand='[]';
update ld_field set advance_demand_groups='' where advance_demand_groups='[]';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_urgent_approve`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_urgent_approve`(
)
BEGIN

	DECLARE tmp_tablename VARCHAR(200) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR
		SELECT
			TABLE_NAME
		FROM information_schema.COLUMNS
		WHERE TABLE_SCHEMA=DATABASE()
			AND COLUMN_NAME='approvesubmittedtime'
            AND TABLE_NAME IN (SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_TYPE='BASE TABLE')
			AND TABLE_NAME NOT IN (SELECT TABLE_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND COLUMN_NAME='approveurgent')
			AND TABLE_NAME IN (SELECT DISTINCT tablename FROM ld_field WHERE columnname='approvestatus');
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tablename = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_tablename;
	WHILE(tmp_tablename IS NOT NULL) DO
		SET @disable_triggers='aaaaa';
		SET @this_sql=CONCAT('ALTER TABLE ',tmp_tablename," ADD COLUMN approveurgent VARCHAR(10) DEFAULT 'no' AFTER approvesubmittedtime");
		PREPARE my_execsql FROM @this_sql;
		EXECUTE my_execsql;
		DROP PREPARE my_execsql;
		SET @disable_triggers=NULL;
		FETCH MYCUSOR INTO tmp_tablename;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_add_urgent_approve();
DROP PROCEDURE IF EXISTS `ldcrm_add_urgent_approve`;

update  ld_linkmodulecustom set entitytype="category",linkmodule="CustomEcharts" where url like 'index.php?module=CustomEcharts&action=CustomEchartsAjax&file=SelfDefinedReport&function_name=getChart&isAjax=no&report_id=%';
delimiter;

UPDATE ld_validatasave SET fieldname="SELECT
	ROUND(IFNULL((SELECT SUM(total) FROM ld_customform25 WHERE deleted=0 AND approvestatus<>'已拒绝' AND projectid='{ld_purchaseorder.projectid}'),0),2)-
	ROUND(IFNULL((SELECT SUM(total) FROM ld_purchaseorder WHERE deleted=0 AND approvestatus<>'已拒绝' AND projectid='{ld_purchaseorder.projectid}' AND purchaseorderid<>'{Record.ID}'),0),2)
AS tmp_value"
WHERE module='PurchaseOrder'
	AND id=53
	AND relatedtable='ld_producttoolfield'
	AND fieldname LIKE '%FROM ld_customform25%'
	AND fieldname LIKE '%FROM ld_customform13%'
	AND fieldname LIKE '%{ld_purchaseorder.projectid}%';
delimiter;

UPDATE ld_account_public_pool SET usertype='all',administrators=(SELECT id FROM ld_users WHERE `status`='Active' AND is_admin='on' LIMIT 1) WHERE id=1 AND TRIM(IFNULL(administrators,''))='';
delimiter;

DROP PROCEDURE IF EXISTS `delete_proc_lingdang_nochange_pssword`;
delimiter ||
CREATE  PROCEDURE `delete_proc_lingdang_nochange_pssword`(
)
BEGIN

	IF FIND_IN_SET(DATABASE(),'crmqy_20150916,demo_biaozhun,demo_jichu,demo_it,demo_607,demo_bank,demo_jiaoyu,demo_yimin,demo_xiangmu1,demo_renzheng,demo_yiliao,demo_zhileng,demo_yuanqu,demo_envtesting,demo_jijin,demo_daizhang,yanshi_xst,yanshi_xiangmu88,yanshi_wuliu88')=0 THEN
		DROP TRIGGER IF EXISTS `lingdang_nochange_pssword`;
	END IF;

END ||
delimiter;

CALL delete_proc_lingdang_nochange_pssword();
delimiter;

update ld_producttoolfield set savedatabase = 'yes' where uitype = 51 and savedatabase is NULL;
delimiter;

call AddColumn('ld_approve','showurgent','varchar','20','no');
call AddColumn ('ld_approvelog', 'urgent', 'varchar', '20', 'no' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Urgent','急','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Urgent' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Urgent',"urgent",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Urgent' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShowUrgentWhenSubmit','提交审批时是否显示加急选项','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShowUrgentWhenSubmit' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShowUrgentWhenSubmit',"Whether urgent opinions are displayed when submitted",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShowUrgentWhenSubmit' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UrgentApproval','需要加急审批','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UrgentApproval' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UrgentApproval',"Urgent approval is required",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UrgentApproval' and labeltype='fixedstr');
delimiter;

update ld_systems_deploy set presence=1 where deploy_type=152;
update ld_systems_deploy set presence=1 where deploy_type=199;
delimiter;

SET @deploy_type = 329;
insert into ld_systems_deploy(deploy_value,deploy_type,description,inputvalue)
select 0,@deploy_type,'客户是否启用工商查询功能 0:是 1:否','[]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;
SET @deploy_type = 330;
insert into ld_systems_deploy(deploy_value,deploy_type,description,inputvalue)
select 1,@deploy_type,'客户是否启用保存时，没有工商信息不允许保存 0:是 1:否','[]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;

SET @deploy_type = 331;
insert into ld_systems_deploy(deploy_value,deploy_type,description,inputvalue)
select 0,@deploy_type,'供应商是否启用工商查询功能 0:是 1:否','[]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;
SET @deploy_type = 332;
insert into ld_systems_deploy(deploy_value,deploy_type,description,inputvalue)
select 1,@deploy_type,'供应商是否启用保存时，没有工商信息不允许保存 0:是 1:否','[]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;

SET @deploy_type = 333;
insert into ld_systems_deploy(deploy_value,deploy_type,description,inputvalue)
select 0,@deploy_type,'服务收费管理是否启用工商查询功能 0:是 1:否','[]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;
SET @deploy_type = 334;
insert into ld_systems_deploy(deploy_value,deploy_type,description,inputvalue)
select 1,@deploy_type,'服务收费管理是否启用保存时，没有工商信息不允许保存 0:是 1:否','[]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BUSINESSQUERYSETTINGS','工商查询设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BUSINESSQUERYSETTINGS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BUSINESSQUERYSETTINGS',"Business query settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BUSINESSQUERYSETTINGS' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENABLEBUSINESSQUERY','启用工商查询功能','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENABLEBUSINESSQUERY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENABLEBUSINESSQUERY',"Enable business query function",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENABLEBUSINESSQUERY' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOBUSINESSINFOLNOTALLOWSAVE','启用%s保存时，没有工商信息不允许保存','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOBUSINESSINFOLNOTALLOWSAVE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOBUSINESSINFOLNOTALLOWSAVE',"When %s saving is enabled, it is not allowed to save without business information" ,'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOBUSINESSINFOLNOTALLOWSAVE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETEXCEPTION','设置例外条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETEXCEPTION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETEXCEPTION',"Set exceptions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETEXCEPTION' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INCONDITIONALLOWSAVE','满足以下条件时，没有工商信息允许保存','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INCONDITIONALLOWSAVE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INCONDITIONALLOWSAVE',"When the following conditions are met, no business information is allowed to be saved",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INCONDITIONALLOWSAVE' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel = 'Set each value of the cascade field corresponding to the relationship, after the selection of the upper field value, then the lower field only shows the corresponding value of the setting.'
where labelbol = 'SETTINGDEPENCYPARENTCHILD' and languagetype = 'en';
update ld_desk set fieldlabel = 'Step two: Set each value of the cascade field corresponding to the relationship, after the selection of the upper field value, then the lower field only shows the corresponding value of the setting.'
where labelbol = 'DEPENCYEDITSECOND' and languagetype = 'en';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','FIELDMAPPING','字段映射','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='FIELDMAPPING' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','FIELDMAPPING','Field mapping','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='FIELDMAPPING' and Labeltype='fixedstr');
delimiter;
-- 2021-08-13

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','FIELDMAPPING','字段映射','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='FIELDMAPPING' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','FIELDMAPPING','Field mapping','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='FIELDMAPPING' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','COMPLETELYDELETED','彻底删除','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='COMPLETELYDELETED' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','COMPLETELYDELETED','Completely deleted','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='COMPLETELYDELETED' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','MARKEDAS','标记为','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='MARKEDAS' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','MARKEDAS','Marked as','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='MARKEDAS' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NOSTARMAIL',' 取消星标','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NOSTARMAIL' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NOSTARMAIL','no Star mail','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NOSTARMAIL' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','READMAIL','已读邮件','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='READMAIL' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','READMAIL','Read mail','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='READMAIL' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','UNREADMAIL','未读邮件','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='UNREADMAIL' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','UNREADMAIL','Unread mail','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='UNREADMAIL' and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_advancepicklist` ( 
    `advanceid` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `tabid` int NOT NULL,
    `stagename` varchar(255) NOT NULL,
	`completerequest` varchar(10),
	`autopush` varchar(10),
	`fieldname` varchar(50),
	`taskgroup` int(11)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_advancepicklisttask` ( 
    `taskid` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `advanceid` int(11) NOT NULL,
    `type` varchar(30),
	`tasklabel` varchar(255),
	`sequence` int(11)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_advancepicklist_selectinfo` ( 
    `id` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `taskid` int(11) NOT NULL,
    `selectinfo` varchar(255),
    `sequence` int(11)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_advancepicklistlog` ( 
    `jourid` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `taskid` int(11) NOT NULL,
    `record` int(19) NOT NULL,
	`taskresult` varchar(255),
	`smcreatorid` int(11),
	`createdtime` Datetime
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

alter table ld_settings_advance modify column module_field varchar(100);
alter table ld_settings_advance modify column module_period_start_field varchar(100);
alter table ld_settings_advance modify column module_period_end_field varchar(100);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','COMPLETEREQUEST','完成后才能继续推进','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='COMPLETEREQUEST' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','COMPLETEREQUEST','Finished then can continue','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='COMPLETEREQUEST' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','AUTOPUSH','完成后自动推进','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='AUTOPUSH' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','AUTOPUSH','Automatic propulsion after completion','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='AUTOPUSH' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NOCREATED','未创建','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NOCREATED' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NOCREATED','Not created','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NOCREATED' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CREATED','已创建','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='CREATED' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CREATED','Created','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='CREATED' and Labeltype='fixedstr');
delimiter;
 
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SFAProgress','自动化进度设置','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SFAProgress' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SFAProgress','Automation schedule settings','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SFAProgress' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NOTASK','无任务','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NOTASK' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NOTASK','No task','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NOTASK' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','MOUSEOVERTASKEXIST','鼠标点击或移动到图标上显示任务信息','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='MOUSEOVERTASKEXIST' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','MOUSEOVERTASKEXIST','Move the mouse over or click the icon to display task information','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='MOUSEOVERTASKEXIST' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CHOOSETASKTYPE','请选择任务类型','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='CHOOSETASKTYPE' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CHOOSETASKTYPE','Please choose task type','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='CHOOSETASKTYPE' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CANNOTMOVEBEFORECOMPLETE','任务未完成，不能向前推进','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='CANNOTMOVEBEFORECOMPLETE' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CANNOTMOVEBEFORECOMPLETE','The task has not been completed and cannot move forward','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='CANNOTMOVEBEFORECOMPLETE' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','Text','文本','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='Text' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','Text','text','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='Text' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','TASKNAME','任务名称','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='TASKNAME' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','TASKNAME',' task name','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='TASKNAME' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NOSAMEOPTION','请不要设置相同的选项','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NOSAMEOPTION' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NOSAMEOPTION','Please do not set the same option','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NOSAMEOPTION' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BUSINESSQUERYUNEXIS','该%s工商信息不存在，无法保存！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BUSINESSQUERYUNEXIS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BUSINESSQUERYUNEXIS',"The %s business information does not exist and cannot be saved!",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BUSINESSQUERYUNEXIS' and labeltype='fixedstr');
delimiter;


DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE (d.`name`='CooperativeWork'
			AND permissions=0
			and d.presence in(0,2)
			AND a.`status`='Active' ) or (a.is_admin='on' AND a.`status`='Active');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remindtime='no';
	SELECT IFNULL(cooperativeworkweek,'no') INTO @remindtime FROM ld_workremindset LIMIT 1;

	SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '日志提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() and reltab='CooperativeWork';

	IF @remindtime<>'no' AND WEEKDAY(NOW())<5 AND @cnt=0 AND DATE_FORMAT(DATE_ADD(NOW(),INTERVAL 1 HOUR),'%H:%i')>=@remindtime AND DATE_FORMAT(NOW(),'%H:%i')<=@remindtime THEN
	    OPEN Mycur;
		FETCH Mycur INTO tmp_id;
		WHILE (tmp_id IS NOT NULL) DO

			IF NOT EXISTS (SELECT 1 FROM ld_workreport WHERE  DATE_FORMAT(createdtime,"%Y-%m-%d")=CURDATE() AND smcreatorid=tmp_id and type=1) THEN
						 
			SET @content=CONCAT('日志提交提醒：您该提交日志啦，还有一个小时就到提交期限哦');
			CALL ldcrm_add_reminder(@content,tmp_id,'CooperativeWork',0);
			end if;
		FETCH Mycur INTO tmp_id;
		END WHILE;
		CLOSE Mycur;	
	END IF;

end ||
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','PROGRESSTRACKING','进度追踪','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='PROGRESSTRACKING' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','PROGRESSTRACKING','Progress tracking','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='PROGRESSTRACKING' and Labeltype='fixedstr');
delimiter;
-- 2021-08-15

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FINDNOW','立即查找','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FINDNOW' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FINDNOW',"Search Now",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FINDNOW' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SalesCommissionsByCash',"Sales Commissions By Cash",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SalesCommissionsByCash' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SalesCommissionsByOrder',"Sales Commissions By Order",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SalesCommissionsByOrder' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','onlyshowapprovecontactandservice',"Only show approved {$ServiceContracts.ServiceContracts} and {$SalesOrder.SalesOrder}",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='onlyshowapprovecontactandservice' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','onlyshowapprovefeeandcommissions',"Only show approved fee and commissions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='onlyshowapprovefeeandcommissions' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','rewardRule',"Commission rule settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='rewardRule' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_modentity_num','reset_value','varchar','50','no');
delimiter;
call AddColumn('ld_modentity_num','complement','int','11',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Theserialnumberisautomaticallyreseteveryday','流水号每天自动重置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Theserialnumberisautomaticallyreseteveryday' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Theserialnumberisautomaticallyreseteveryday',"The serial number is automatically reset every day",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Theserialnumberisautomaticallyreseteveryday' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Erialnumberautocomplementnumber','流水号自动补足位数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Erialnumberautocomplementnumber' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Erialnumberautocomplementnumber',"Erial number auto-complement number",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Erialnumberautocomplementnumber' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Nofilling','不补位','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Nofilling' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Nofilling',"No filling",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Nofilling' and labeltype='fixedstr');
delimiter;

delete from ld_modentity_num where active = 0;
delimiter;

DROP EVENT IF EXISTS `update_modenity_num`;
CREATE EVENT `update_modenity_num` ON SCHEDULE EVERY 1 DAY STARTS '2021-08-13 00:30:00' ON COMPLETION NOT PRESERVE ENABLE DO
	update ld_modentity_num set start_id ='1',cur_id = '1' where active = 1 and reset_value = 'yes';
DELIMITER ;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Executor','执行人：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Executor' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Executor',"Executor：",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Executor' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Completiontime','完成时间：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Completiontime' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Completiontime',"Completion time：",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Completiontime' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Jobbriefing','工作简报','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Jobbriefing' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Jobbriefing',"Job briefing",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Jobbriefing' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Generatebrief','生成简报','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Generatebrief' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Generatebrief',"Generate a brief",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Generatebrief' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReportResults','汇报结果','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ReportResults' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReportResults',"Report Results",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ReportResults' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOCONTENT','暂无内容','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOCONTENT' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOCONTENT',"No Content",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOCONTENT' and labeltype='jspop');
delimiter;


UPDATE ld_account_public_pool
SET usertype = 'all'
where 	id = 1
AND (TRIM(IFNULL(userids, '')) = ''
or not EXISTS(select 1 from ld_users where  FIND_IN_SET(id,userids) and `status` = 'Active'));
delimiter;

delete from ld_relatedlists where tabid=48 and `name`='get_salesorder' and actions='add' and  EXISTS (select 1 from ld_version where account='construction');
delimiter;

DROP EVENT IF EXISTS `update_account_nolinkdays`;
CREATE EVENT `update_account_nolinkdays` ON SCHEDULE EVERY 1 DAY STARTS '2016-05-24 00:30:00' ON COMPLETION NOT PRESERVE ENABLE 
DO 
	UPDATE ld_account SET nolinkdays=DATEDIFF(CURDATE(),IF(lastcontactdate>'1900-01-01',DATE_FORMAT(lastcontactdate,'%Y-%m-%d'),DATE_FORMAT(createdtime,'%Y-%m-%d')));
delimiter;

DROP EVENT IF EXISTS `update_lead_nolinkdays`;
CREATE EVENT `update_lead_nolinkdays` ON SCHEDULE EVERY 1 DAY STARTS '2021-05-24 00:30:00' ON COMPLETION NOT PRESERVE ENABLE 
DO 
	UPDATE ld_leads SET nolinkdays=DATEDIFF(CURDATE(),IF(lastcontactdate>'1900-01-01',DATE_FORMAT(lastcontactdate,'%Y-%m-%d'),DATE_FORMAT(createdtime,'%Y-%m-%d')));
delimiter;
-- 2021-08-18

UPDATE ld_field SET uitype=19,bigtype='longtextarea' WHERE tablename='ld_account' AND columnname='lastcontent';

UPDATE ld_desk SET fieldlabel='在{$SalesBack.SalesBack}序时簿先找到需要退款的{$SalesBack.SalesBack}，在{$SalesBack.SalesBack}查看界面单击左侧相关信息“{$CashBack.CashBack}”的操作按钮“新建”即可。' WHERE labelbol= 'WHENTHERETURNLISTISSOLD' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='在{$PurchaseBack.PurchaseBack}序时簿先找到需要退款的{$PurchaseBack.PurchaseBack}，在{$PurchaseBack.PurchaseBack}查看界面单击左侧相关信息“{$PurchaseCashBack.PurchaseCashBack}”的操作按钮“新建”即可。' WHERE labelbol= 'INORDERTOPURCHASEARETURNLIST' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;
-- 2021-08-20

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

UPDATE ld_version SET old_version='V8.4.3.7',current_version='V8.4.3.7',remark='V8.4.3.7-20210820',wx_version='V8.4.3.7';
delimiter;