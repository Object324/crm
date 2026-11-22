insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Operating_Instructions','操作说明','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Operating_Instructions' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','Operating_Instructions','Operation description','jspop' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Operating_Instructions' and Labeltype='jspop');

update ld_desk set fieldlabel='Operation description'
where labelbol='Operating_Instructions' and languagetype='en' and Labeltype='jspop';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARETYPEADD','在已有的共享人基础上增加新勾选的成员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARETYPEADD' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SHARETYPEADD','Adding newly elected members on the basis of an existing shared person','jspop' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARETYPEADD' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARETYPEREPLACE','将已有的共享人替换为新勾选的成员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARETYPEREPLACE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SHARETYPEREPLACE','Replacing existing shared people as newly selected members','jspop' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARETYPEREPLACE' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARETYPECANCEL','从已有的共享人中移除所选成员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARETYPECANCEL' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SHARETYPECANCEL','Remove selected members from an existing shared person','jspop' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARETYPECANCEL' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SUCCESS','成功','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SUCCESS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SUCCESS','Success','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SUCCESS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOINCHARGEOF','单据[%s]%s不成功！原因：您不是该单据的负责人!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NOINCHARGEOF' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','NOINCHARGEOF','Document[%s] %s no success! The reason: you are not the person in charge of the document！','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NOINCHARGEOF' and Labeltype='fixedstr');

UPDATE ld_systems_deploy SET description='设置是否仅允许系统管理员用户和负责人共享单据。1:否，0:是' WHERE deploy_type=33;
UPDATE ld_tranlabel SET fieldlabel = '设置是否仅允许系统管理员用户和负责人共享单据'
WHERE languagetype='zh' AND trantable='ld_systems_deploy'AND tabid=33 AND  Relateid=33;
UPDATE ld_tranlabel SET fieldlabel = 'Set whether to allow only the system administrator user and the person in charge to share records'
WHERE languagetype='en' AND trantable='ld_systems_deploy'AND tabid=33 AND  Relateid=33;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SUPERADDTION','追加','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SUPERADDTION' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SUPERADDTION','Add','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SUPERADDTION' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REPLACE','替换','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='REPLACE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REPLACE','Update','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REPLACE' and Labeltype='jspop');

update ld_desk set fieldlabel='Update'
where labelbol='REPLACE' and languagetype='en' and Labeltype='jspop';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TYPE','类型','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TYPE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TYPE','Type','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TYPE' and Labeltype='jspop');

update ld_desk set fieldlabel='单据[%s]共享失败！原因：您不是该单据的负责人!'
where labelbol='NOINCHARGEOF' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Record [%s] sharing fail! The reason: you are not the person in charge of the record！'
where labelbol='NOINCHARGEOF' and languagetype='en' and Labeltype='fixedstr';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARESUCCEED','单据[%s]共享成功!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARESUCCEED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SHARESUCCEED','Record [%s] sharing succeed!','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARESUCCEED' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHARECANCEL','单据[%s]取消共享成功!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHARECANCEL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SHARECANCEL','Record [%s] sharing cancel!','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHARECANCEL' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','SHAREDETAILFAIL','您没有权限共享该单据！<br/>原因：您不是该单据的负责人！','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHAREDETAILFAIL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SHAREDETAILFAIL'
    ,'You have no authority to share the record!<br/>Reason: you are not the person in charge of the record!','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en'
                                                and labelbol='SHAREDETAILFAIL' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WARMPROMPT','温馨提示','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WARMPROMPT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WARMPROMPT','Warm prompt','fixedstr' from dual
  where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WARMPROMPT' and Labeltype='fixedstr');


DROP PROCEDURE IF EXISTS `ldcrm_add_approveprocess`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_approveprocess`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_modname VARCHAR(100) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			b.tabid,
			c.fieldlabel
		FROM ld_systems_deploy a
		INNER JOIN ld_tab b ON a.setype=b.`name`
		LEFT JOIN ld_tranlabel c ON c.tabid=b.tabid AND c.trantable='ld_tab' AND c.languagetype='zh'
		WHERE IFNULL(a.setype,'')<>''
		ORDER BY tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;


	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_modname;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @maxid=IFNULL((SELECT MAX(id) FROM ld_approve),0);
		INSERT INTO ld_approve(id,tabid,`name`,description,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
		SELECT @maxid+1,tmp_tabid,CONCAT(tmp_modname,'选人审批流程'),CONCAT(tmp_modname,'预置审批流程'),0,1,1,NOW(),NOW(),0,0,0;

		UPDATE ld_approve_seq SET id=(SELECT max(id) FROM ld_approve);

		INSERT INTO ld_approve2user(approveid,userid) SELECT @maxid+1,-1;

		SET @i=0;
		SET @maxstepid=IFNULL((SELECT MAX(id) FROM ld_approvestep),0);		
		INSERT INTO ld_approvestep(id,approveid,`name`,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxstepid+1,@maxid+1,'一级审批','',0,1,(@i:=@i+1),NOW(),NOW(),6,NULL,0;

		INSERT INTO ld_approvestep(id,approveid,`name`,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxstepid+2,@maxid+1,'二级审批','',1,1,(@i:=@i+1),NOW(),NOW(),6,NULL,0;

		INSERT INTO ld_approvestep(id,approveid,`name`,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxstepid+3,@maxid+1,'三级审批','',1,1,(@i:=@i+1),NOW(),NOW(),6,NULL,0;
		
		UPDATE ld_approvestep_seq SET id=(SELECT max(id) FROM ld_approvestep);
		FETCH MYCUSOR INTO tmp_tabid,tmp_modname;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_reset_approveprocess_20180531`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_approveprocess_20180531`(
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) AND NOT EXISTS (SELECT 1 FROM ld_approvelog) THEN
		DELETE FROM ld_approve;
		DELETE FROM ld_approvestep;
		DELETE FROM ld_approve2user;
		DELETE FROM ld_approvelog;
		
		CALL ldcrm_add_approveprocess();
	END IF;

end ||
delimiter;

CALL ldcrm_reset_approveprocess_20180531();

DROP PROCEDURE IF EXISTS `ldcrm_reset_approveprocess_20180531`;
DROP PROCEDURE IF EXISTS `ldcrm_add_approveprocess`;


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






DROP PROCEDURE IF EXISTS `ldcrm_add_reminder`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_reminder`(
	tmp_content text,
	tmp_recieverid int(19),
    tmp_reltab varchar(100),
	tmp_related_to int(19)
    
)
BEGIN
	
	set @maxid=0;
	select max(crmid) into @maxid from ld_crmentity;
	insert into ld_crmentity(crmid,setype)
	select @maxid+1,'Reminds';			
	insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
	select @maxid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0;

	update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);

end ||
delimiter;


DROP TRIGGER IF EXISTS `ldcrm_remind_smowner`;
delimiter ||
CREATE TRIGGER `ldcrm_remind_smowner` AFTER INSERT ON `ld_modcomments` FOR EACH ROW BEGIN

  SELECT setype INTO @reltab FROM ld_crmentity WHERE crmid=NEW.related_to;

  IF NEW.related_to>0 THEN
    SELECT
      b.fieldlabel INTO @content
    FROM ld_tab a
    LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab' AND b.languagetype='zh'
    WHERE a.`name`=@reltab LIMIT 1;
	
    SELECT CONCAT(last_name,'评论了您的',@content) INTO @content FROM ld_users WHERE id=NEW.smownerid LIMIT 1;

    SET @smownerid=0;
    SET @servicecasher=0;
    IF @reltab='Accounts' THEN
      SELECT smownerid INTO @smownerid FROM ld_account WHERE accountid=NEW.related_to limit 1;
      SELECT servicecasher INTO @servicecasher FROM ld_account WHERE accountid=NEW.related_to limit 1;
    ELSEIF @reltab='Contacts' THEN
      SELECT smownerid INTO @smownerid FROM ld_contactdetails WHERE contactid=NEW.related_to limit 1;
    ELSEIF @reltab='ContactRecords' THEN
      SELECT smownerid INTO @smownerid FROM ld_contactrecords WHERE contactrecordid=NEW.related_to limit 1;
    ELSEIF @reltab='Potentials' THEN
      SELECT smownerid INTO @smownerid FROM ld_potential WHERE potentialid=NEW.related_to limit 1;
    ELSEIF @reltab='Quotes' THEN
      SELECT smownerid INTO @smownerid FROM ld_quotes WHERE quoteid=NEW.related_to limit 1;
    ELSEIF @reltab='SalesOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_salesorder WHERE salesorderid=NEW.related_to limit 1;
    ELSEIF @reltab='SalesBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_salesback WHERE salesbackid=NEW.related_to limit 1;

    ELSEIF @reltab='ServiceContracts' THEN
      SELECT smownerid INTO @smownerid FROM ld_servicecontracts WHERE servicecontractsid=NEW.related_to limit 1;
    ELSEIF @reltab='ServiceCharge' THEN
      SELECT servicecasher INTO @smownerid FROM ld_account WHERE accountid=NEW.related_to limit 1;
    ELSEIF @reltab='HelpDesk' THEN
      SELECT smownerid INTO @smownerid FROM ld_troubletickets WHERE ticketid=NEW.related_to limit 1;
    ELSEIF @reltab='ServiceReturn' THEN
      SELECT smownerid INTO @smownerid FROM ld_servicereturn WHERE servicereturnid=NEW.related_to limit 1;

    ELSEIF @reltab='Project' THEN
      SELECT smownerid INTO @smownerid FROM ld_project WHERE projectid=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectTask' THEN
      SELECT smownerid INTO @smownerid FROM ld_projecttask WHERE projecttaskid=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectMilestone' THEN
      SELECT smownerid INTO @smownerid FROM ld_projectmilestone WHERE projectmilestoneid=NEW.related_to limit 1;
    ELSEIF @reltab='TimeSheet' THEN
      SELECT smownerid INTO @smownerid FROM ld_timesheet WHERE timesheet_id=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectProgress' THEN
      SELECT smownerid INTO @smownerid FROM ld_projectprogress WHERE projectprogressid=NEW.related_to limit 1;
    ELSEIF @reltab='Rate' THEN
      SELECT smownerid INTO @smownerid FROM ld_rate WHERE rate_id=NEW.related_to limit 1;

    ELSEIF @reltab='Invoice' THEN
      SELECT smownerid INTO @smownerid FROM ld_invoice WHERE invoiceid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseInvoice' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseinvoice WHERE purchaseinvoiceid=NEW.related_to limit 1;
    ELSEIF @reltab='CashBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashbill WHERE cashbillid=NEW.related_to limit 1;
    ELSEIF @reltab='SendCashBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_sendcashbill WHERE sendcashbillid=NEW.related_to limit 1;
    ELSEIF @reltab='CashBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashback WHERE cashbackid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseCashBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchasecashback WHERE purchasecashbackid=NEW.related_to limit 1;
    ELSEIF @reltab='PaymentPlan' THEN
      SELECT smownerid INTO @smownerid FROM ld_paymentplan WHERE paymentplanid=NEW.related_to limit 1;
    ELSEIF @reltab='SendPayment' THEN
      SELECT smownerid INTO @smownerid FROM ld_sendpayment WHERE sendpaymentid=NEW.related_to limit 1;
    ELSEIF @reltab='PutCash' THEN
      SELECT smownerid INTO @smownerid FROM ld_putcash WHERE putcashid=NEW.related_to limit 1;
    ELSEIF @reltab='CashDeposit' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashdeposit WHERE cashdepositid=NEW.related_to limit 1;
    ELSEIF @reltab='BankAccountSet' THEN
      SELECT smcreatorid INTO @smownerid FROM ld_bankaccountset WHERE Bankaccountsetid=NEW.related_to limit 1;

    ELSEIF @reltab='OutboundOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_outboundorder WHERE out_id=NEW.related_to limit 1;
    ELSEIF @reltab='Stock' THEN
      SELECT smownerid INTO @smownerid FROM ld_stock WHERE stock_id=NEW.related_to limit 1;
    ELSEIF @reltab='WareHouseTransfer' THEN
      SELECT smownerid INTO @smownerid FROM ld_warehousetransfer WHERE warehousetransferid=NEW.related_to limit 1;
    ELSEIF @reltab='Checks' THEN
      SELECT smownerid INTO @smownerid FROM ld_checks WHERE id=NEW.related_to limit 1;

    ELSEIF @reltab='Vendors' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendor WHERE vendorid=NEW.related_to limit 1;
    ELSEIF @reltab='VendorContact' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendorcontacts WHERE vendorcontactsid=NEW.related_to limit 1;
    ELSEIF @reltab='VendorContactRecords' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendorcontactrecords WHERE contactRecordsid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseorder WHERE purchaseorderid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseback WHERE purchasebackid=NEW.related_to limit 1;

    ELSEIF @reltab='Campaigns' THEN
      SELECT smownerid INTO @smownerid FROM ld_campaign WHERE campaignid=NEW.related_to limit 1;

    ELSEIF @reltab='NormalApprove' THEN
      SELECT smownerid INTO @smownerid FROM ld_normalapprove WHERE normalapproveid=NEW.related_to limit 1;
    ELSEIF @reltab='AddJobBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.related_to limit 1;
    ELSEIF @reltab='MinusJobBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.related_to limit 1;
    ELSEIF @reltab='BusinessApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_businessapply WHERE businessapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='LoanApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_loanapply WHERE loanapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='CardApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_cardapply WHERE cardapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='Commission' THEN
      SELECT smownerid INTO @smownerid FROM ld_commission WHERE commission_id=NEW.related_to limit 1;
    ELSEIF @reltab='Expense' THEN
      SELECT smownerid INTO @smownerid FROM ld_expense WHERE expenseid=NEW.related_to limit 1;

    ELSEIF @reltab='Products' THEN
      SELECT smownerid INTO @smownerid FROM ld_products WHERE productid=NEW.related_to limit 1;
    ELSEIF @reltab='PriceBooks' THEN
      SELECT smownerid INTO @smownerid FROM ld_pricebook WHERE pricebookid=NEW.related_to limit 1;
    ELSEIF @reltab='Documents' THEN
      SELECT smownerid INTO @smownerid FROM ld_notes WHERE notesid=NEW.related_to limit 1;
    ELSEIF @reltab='Faq' THEN
      SELECT smownerid INTO @smownerid FROM ld_faq WHERE id=NEW.related_to limit 1;
    ELSEIF @reltab='Attachment' THEN
      SELECT smownerid INTO @smownerid FROM ld_attachmentsforbills WHERE attachmentsid=NEW.related_to limit 1;
    END IF;

    IF @smownerid>0  THEN
      CALL ldcrm_add_reminder(@content,@smownerid,@reltab,NEW.related_to);
    END IF;
    select presence into @presence from ld_tab where name='servicecharge';

    IF @servicecasher>0  and (@presence=0 or @presence=2) THEN
      CALL ldcrm_add_reminder(@content,@servicecasher,'ServiceCharge',NEW.related_to);
    END IF;
  END IF;

end ||
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESLECTFIRST','请先选择','jspop' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASESLECTFIRST' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESLECTFIRST','Please select','jspop' from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASESLECTFIRST' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THNECHOOSE','，再选择','jspop' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='THNECHOOSE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THNECHOOSE',' first, then choose','jspop' from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='THNECHOOSE' and labeltype='jspop');

select usereportid into @usereportid  from ld_usereport  where name='SalesSumSequence';
select sequence into @sequence  from ld_usereportcolumns  where usereportid=@usereportid and  columns like '%ld_users:last_name:last_name:OftenUseReport_last_name%';
update ld_usereportcolumns set sequence=sequence+1 where sequence>@sequence and usereportid=@usereportid;
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_singin:singincount:singincount:OftenUseReport_外勤签到次数:N',@sequence+1,1,'ld_singin:singincount:singincount:OftenUseReport_外勤签到次数:N','ld_singin:singincount:singincount:OftenUseReport_Number of sign in:N' from DUAL
where not EXISTS(select 1 from ld_usereportcolumns where usereportid =@usereportid and columns like '%ld_singin:singincount:singincount:OftenUseReport_singincount%');
delimiter;

select tabid into @tabid from ld_tab where name='outboundorder';
select sequence into @sequence from ld_profileallpermission  where operation=6 and tabid=70;
update ld_profileallpermission set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=5);
delimiter;

select tabid into @tabid from ld_tab where name='stock';
select sequence into @sequence from ld_profileallpermission  where operation=6 and tabid=70;
update ld_profileallpermission set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=5);
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
select sequence into @sequence from ld_profileallpermission  where operation=6 and tabid=@tabid;
update ld_profileallpermission set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=5);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInvoice';
select sequence into @sequence from ld_profileallpermission  where operation=6 and tabid=@tabid;
update ld_profileallpermission set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=5);
delimiter;
-- 2018-06-05

DELETE FROM ld_usereportcolumns WHERE `columns` LIKE '%ld_singin:singincount:singincount:OftenUseReport%';

select usereportid into @usereportid  from ld_usereport  where name='SalesSumSequence';
select sequence into @sequence  from ld_usereportcolumns  where usereportid=@usereportid and  columns like '%ld_users:last_name:last_name:OftenUseReport_last_name%';
update ld_usereportcolumns set sequence=sequence+1 where sequence>@sequence and usereportid=@usereportid;
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_singin:singincount:singincount:OftenUseReport_外勤签到次数:N',@sequence+1,1,'ld_singin:singincount:singincount:OftenUseReport_外勤签到次数:N','ld_singin:singincount:singincount:OftenUseReport_Number of sign in:N' from DUAL
where not EXISTS(select 1 from ld_usereportcolumns where usereportid =@usereportid and columns like '%ld_singin:singincount:singincount:OftenUseReport%');
delimiter;

update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords}次数TOP10' where labelbol='CUSTOMERCONTACTNUMTEN' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords} number TOP10' where labelbol='CUSTOMERCONTACTNUMTEN' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords}次数TOP50' where labelbol='CUSTOMERCONTACTNUMFIFTY' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Accounts.Accounts}{$ContactRecords.ContactRecords} number TOP50' where labelbol='CUSTOMERCONTACTNUMFIFTY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$ContactRecords.ContactRecords}数量负责人/月度统计' where labelbol='CONTACTRECORDSQUANTITY' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='{$ContactRecords.ContactRecords} person in charge of number/ monthly statistics' where labelbol='CONTACTRECORDSQUANTITY' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='{$ContactRecords.contactrecordtype}分布统计' where labelbol='CONTACTRECORDSTYPE' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$ContactRecords.contactrecordtype} distribution statistics' where labelbol='CONTACTRECORDSTYPE' and languagetype='en' and Labeltype='fixedstr';
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

update ld_version set old_version='V7.3.9',current_version='V7.3.9',remark='V7.3.9-20180605',wx_version='V7.3.9';
delimiter;