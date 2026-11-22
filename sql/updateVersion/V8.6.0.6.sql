update ld_desk set fieldlabel='请在PC端添加{$Contacts.Contacts}图谱' where labelbol='ADDMODULEMAPINPC' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Please add {$Contacts.Contacts} Map on the PC' where labelbol='ADDMODULEMAPINPC' and languagetype='en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FULLSCREEN','全屏','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FULLSCREEN' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FULLSCREEN',"Full screen",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FULLSCREEN' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RECOVERY','恢复','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RECOVERY' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RECOVERY',"Recovery",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RECOVERY' and labeltype='jspop');
delimiter;

set @tabid = (select tabid from ld_tab where `name`='SocialPromotion');
UPDATE ld_field SET uitype=230 ,bigtype='richtext' WHERE tabid=@tabid AND columnname='activityintroduction';
delimiter;

ALTER TABLE ld_socialpromotionscf MODIFY activityintroduction TEXT;
ALTER TABLE ld_socialpromotionscf MODIFY shareintroduction TEXT;
delimiter;

DROP PROCEDURE IF EXISTS `ld_homeboard_updatesequence_history`;
delimiter ||
CREATE  PROCEDURE `ld_homeboard_updatesequence_history`()
BEGIN
	IF NOT EXISTS (select 1 from information_schema.`COLUMNS` where TABLE_SCHEMA=database() and TABLE_NAME='ld_homeboard' and column_name='sequence') THEN
		call AddColumn('ld_homeboard','sequence','tinyint','4',NULL);
		SET @seq_home = 0;
		UPDATE ld_homeboard SET sequence = (@seq_home:=@seq_home+1) WHERE boardtype = 'Home' ORDER BY modifiedtime;
		SET @seq_visual = 0;
		update ld_homeboard set sequence = (@seq_visual :=@seq_visual + 1) WHERE boardtype = 'VisualAnalysis' ORDER BY modifiedtime;
	END IF;

end ||
delimiter;

CALL ld_homeboard_updatesequence_history();
delimiter;

call addtableIndex('ld_cashbill2paymentplan','Idx_cashbill2paymemtplan_entitytypeid','entitytypeid');
delimiter;

select tabid into @tabid from ld_tab where name='ReportAnalysis';
select actionid  into @actionid1 from ld_actionmapping where actionname='Export';
select actionid  into @actionid from ld_actionmapping where actionname='Print';
select sequence into @sequence from ld_profileallpermission where tabid=@tabid and operation=@actionid1;
update ld_profileallpermission set sequence=sequence+1 where sequence>@sequence;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@actionid,@sequence+1 FROM DUAL 
    WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation =@actionid );
delimiter;

SET @module='Project';
SET @rel_module='PaymentPlan';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Project');
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template=CONCAT('get_',LOWER(@rel_module));
DELETE FROM ld_relatedlists
WHERE tabid=@tabid  AND related_tabid=@rel_tabid AND `name`=@template AND type='datacategory_sql' AND related_coltable='paymentplan.projectid';
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','paymentplan.projectid' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

SET @labelbol = 'BOARDMANAGEMENT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'管理{$VisualAnalysis.VisualAnalysis}的数据看板、设置看板关联的角色','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Manage the component template of {$VisualAnalysis.VisualAnalysis}, set the template associated roles','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_homestuffdetail SET `daterange`='ld_account:createdtime:createdtime:Accounts_fieldlabel:DT'
WHERE (`stufflabel`='NewAccounts')and `daterange`='ld_account:nextcontactdate:nextcontactdate:Accounts_fieldlabel:DT' LIMIT 1;

UPDATE ld_homestuffdetail SET `daterange`='ld_singin:createdtime:createdtime:Singin_fieldlabel:DT',
`viewrange`='ld_singin:smownerid:assigned_user_id:Singin_fieldlabel:V',compute_columns='ld_singin.smownerid',compute_module='Singin' WHERE (`stufflabel`='NewSignCount')  LIMIT 1;

UPDATE ld_homestuffdetail SET `daterange`='ld_commission:createdtime:createdtime:Commission_fieldlabel:DT'
WHERE (`stufflabel`='CommissionsAmount') and `daterange`='ld_commission:modifiedtime:modifiedtime:Commission_fieldlabel:DT' LIMIT 1;


UPDATE ld_homestuffdetail SET `viewrange`='ld_contactrecords:smownerid:assigned_user_id:ContactRecords_fieldlabel:V',
`daterange`='ld_contactrecords:createdtime:createdtime:ContactRecords_fieldlabel:DT'
WHERE (`stufflabel`='NewContactRecords') LIMIT 1;

UPDATE ld_homestuffdetail SET `viewrange`='ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V',
`daterange`='ld_account:createdtime:createdtime:Accounts_fieldlabel:DT'
WHERE (`stufflabel`='NewServiceChargeNums') LIMIT 1;
delimiter;
update ld_field set typeofdata='V~M' where columnname='budget_person' and tablename='ld_expensebudget';
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule_beforeremind`(
new_normal_id 	int(11),
new_pool_id 	int(11)
)
label_a:BEGIN

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

    				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
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

    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
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


UPDATE ld_dashboard_app SET wx_presence=0,kehu001_presence=0 WHERE `name`='PersonalAccountBalance';
delimiter;

UPDATE ld_cvcolumnlist set columnname = 'ld_singin:createdtime:createdtime:Singin_fieldlabel:DT'
where columnname = 'ld_singin:createdtime:createdtime:Singin_fieldlabel:V' and cvid in (select cvid from ld_customview where entitytype = 'Singin');
delimiter;

SET @labelbol = 'NOPERMISSIONTOMODIFYTHEPASSWORDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您没有修改其他用户密码的权限，请联系管理员。','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'You do not have permission to modify the passwords of other users. Please contact the administrator','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2023-09-08

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

UPDATE ld_version SET old_version='V8.6.0.6',current_version='V8.6.0.6',remark='V8.6.0.6-20230908',wx_version='V8.6.0.6';
delimiter;