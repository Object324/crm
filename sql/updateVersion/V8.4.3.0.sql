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

UPDATE ld_field SET presence=1 WHERE columnname='available_budget' AND tablename='ld_expense';
update ld_desk set fieldlabel='剩余{quantity}为0时不用自动带出' where languagetype = 'zh' and labelbol = 'WithBalanceQtyCondition' and labeltype = 'fixedstr';
update ld_desk set fieldlabel='When the remaining {quantity} is 0, it will not be brought out automatically' where languagetype = 'en' and labelbol = 'WithBalanceQtyCondition' and labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','smsSendTips','短信推送成功，等待腾讯云返回结果！','jspop' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='smsSendTips' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','smsSendTips','SMS push succeeded, waiting for Tencent cloud to return to the result!','jspop' from dual where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='smsSendTips' and labeltype='jspop');
delimiter;

SET @disable_triggers='abcd';
call AddColumn('ld_salesorderdetail','erpentryid','varchar','200',null);
call AddColumn('ld_servicecontractsdetail','erpentryid','varchar','200',null);
SET @disable_triggers=NULL;
delimiter;

CREATE TABLE if not exists `ld_publicleads_remindtableview` (
  `type` varchar(100) DEFAULT NULL,
  `names` text,
  `totalleads` int(19) DEFAULT NULL,
  `smownerid` int(19) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

drop PROCEDURE if exists crm_publicleads_recoveryreminds;
delimiter ||
create PROCEDURE crm_publicleads_recoveryreminds()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			else
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				 call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

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
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leads_id   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >=",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid  ');

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
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leads_id   where ttt_',var_tablename,'.leadsid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads inner join "  ,var_tablename,' on ',var_tablename,'.leadsid=ld_leads.leadsid  ');
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

    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(concat (ld_leads.leadsname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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

    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(concat(ld_leads.leadsname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as leadsnames,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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
drop PROCEDURE if exists leads_singlerecycle_normal_rule;
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



    		if var_condition='or'  then
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_leads.accountname separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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


drop PROCEDURE if exists execute_leads_publicoperation;
delimiter ||
create PROCEDURE execute_leads_publicoperation()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_leads_public_pool where deleted = 0;
	declare continue handler  for not   found  SET done =1;
	if  EXISTS (SELECT 1 FROM ld_leads_public WHERE STATUS = 'yes')  THEN
		if NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicleads')  THEN
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicleads';
			call leads_singlerecycle_normal_rule();
			call leads_singlerecycle_normal_rule_beforeremind();
			OPEN cur1;
				Fetch cur1 into tmp_pool_id;
					loop1: while  done<>1 DO
						call leads_singlerecycle_highsea_rule(tmp_pool_id);
						call leads_singlerecycle_highsea_rule_beforeremind(tmp_pool_id);
				Fetch cur1 into tmp_pool_id;
			end while loop1;
			close cur1;
		end if;
	end if;
end ||
delimiter;

DROP EVENT IF EXISTS `lingdang_public_leads_event`;
CREATE EVENT `lingdang_public_leads_event` ON SCHEDULE EVERY 5 MINUTE STARTS CONCAT('2019-06-21 ',floor(rand()*24),':',floor(rand()*60),':',floor(rand()*60)) ON COMPLETION NOT PRESERVE ENABLE DO
call execute_leads_publicoperation();
delimiter;

call execute_leads_publicoperation;
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
    if var_condition='or'  then

			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_leads.accountname separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype = 53;
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'Users' from dual
where not exists(select 1 from ld_ws_referencetype where fieldtypeid = @fieldtypeid and type = 'Users');
delimiter;

call AddColumn('ld_approve','showsubmitremark','varchar','20','yes');
call AddColumn('ld_approve','submitremarkrequire','varchar','20','no');
call AddColumn('ld_approvestep','approveremarkrequire','varchar','20','no');
delimiter;

update ld_approve set showsubmitremark='yes' where  showsubmitremark is null or showsubmitremark='';
update ld_approve set submitremarkrequire='no' where  submitremarkrequire is null or submitremarkrequire='';
update ld_approvestep set approveremarkrequire='no' where  approveremarkrequire is null or approveremarkrequire='';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','APPROVEDEFAULTVALUEONPURPORT','提交审批时是否显示提交意见','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='APPROVEDEFAULTVALUEONPURPORT' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','APPROVEDEFAULTVALUEONPURPORT','Whether submitted opinions are displayed when submitted for approval','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='APPROVEDEFAULTVALUEONPURPORT' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','APPROVEDEFAULTVALUEONPURPORTREQUIRE','提交审批时提交意见是否必填 ','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='APPROVEDEFAULTVALUEONPURPORTREQUIRE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','APPROVEDEFAULTVALUEONPURPORTREQUIRE','Whether the submitted opinions are required when submitting for approval','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='APPROVEDEFAULTVALUEONPURPORTREQUIRE' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','APPROVEDEFAULTVALUEONAPPROVEREQUIRE','审批意见是否必填','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='APPROVEDEFAULTVALUEONAPPROVEREQUIRE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','APPROVEDEFAULTVALUEONAPPROVEREQUIRE','Whether the approval opinions are required','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='APPROVEDEFAULTVALUEONAPPROVEREQUIRE' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SUBMITREMARKREQUIRE','提交意见不能为空 ','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SUBMITREMARKREQUIRE' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SUBMITREMARKREQUIRE','Submitted opinions cannot be empty','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SUBMITREMARKREQUIRE' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','APPROVEREMARKREQUIRE','审批意见不能为空 ','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='APPROVEREMARKREQUIRE' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','APPROVEREMARKREQUIRE','approval opinions cannot be empty','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='APPROVEREMARKREQUIRE' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','APPROVEREMARKREQUIRE','审批意见不能为空 ','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='APPROVEREMARKREQUIRE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','APPROVEREMARKREQUIRE','approval opinions cannot be empty','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='APPROVEREMARKREQUIRE' and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='Default values when new' WHERE labelbol= 'APPROVEDEFAULTVALUEONNEW' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='是否新建时默认流程' WHERE labelbol= 'APPROVEDEFAULTVALUEONNEW' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

update ld_account_public_pool set en_name='unassigned sea default' where id=1 and en_name='high sea';
delimiter;

UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,'提交意见','审批意见') WHERE languagetype='zh' AND labelbol IN ('SubmitOpinions','APPROVEDEFAULTVALUEONPURPORT',
'APPROVEDEFAULTVALUEONPURPORTREQUIRE','SUBMITREMARKREQUIRE');
-- 2021-06-16

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE  PROCEDURE `account_singlerecycle_normal_rule`()
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
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = 1;
	
    declare continue handler  for not   found  SET done =1;
    select  ld_account_public_pool.userid_after_transfer into  @allotaccount from ld_account_public
				inner join  ld_account_public_pool on ld_account_public_pool.id=account_rule_pool_id;

    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_account_set_rule.days) into @maxdays
      from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
    	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = 1;
    
    	select recycleselect,account_rule_pool_id into @recycleselect,@account_rule_pool_id from ld_account_public;
    
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
    
    
    
    		if var_condition='or'  then
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
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
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
    		end if;
    
         delete from ld_publicaccount_remindtableview ;
    
         set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
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

end;
||
delimiter;


CALL AddColumn('ld_picklist_values','pick_color','varchar','10',NULL);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','DisplayColor','显示颜色 ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='DisplayColor' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','DisplayColor','Display color','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='DisplayColor' and Labeltype='fixedstr');
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','RestoreDefaultColors','恢复默认颜色 ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='RestoreDefaultColors' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','RestoreDefaultColors','Restore default colors','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='RestoreDefaultColors' and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='Default process when creating new' WHERE labelbol= 'APPROVEDEFAULTVALUEONNEW' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='是否新建时默认流程' WHERE labelbol= 'APPROVEDEFAULTVALUEONNEW' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

UPDATE ld_desk SET fieldlabel='New default' WHERE labelbol= 'APPROVEDEFAULTVALUEONNEWMINI' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='是否新建默认' WHERE labelbol= 'APPROVEDEFAULTVALUEONNEWMINI' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

delete from ld_expensebudget_totalcolumns where name in ('Paymentamount',
'Contractamount',
'Invoiceamount',
'Outboundorderamount',
'Cashbillamount',
'SendCashBillamount',
'SalesOrderamount',
'ServiceContractamount',
'Invoiceamount',
'PurchaseInvoiceamount',
'OutboundOrderamount',
'Stockamount',
"ContractVolumeamount",
"Invoicedamount",
"SalesOrderBill",
"salesInvoice",
"OutboundOrderBill");
delimiter;

insert into ld_expensebudget_totalcolumns (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'Paymentamount','ld_salestarget.paymentamount','','','','salesGoalBudget','0','SalesGoal' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='Paymentamount' and `type`='salesGoalBudget');

insert into ld_expensebudget_totalcolumns (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'ContractVolumeamount','ld_salestarget.contractamount','','','','salesGoalBudget','0','SalesGoal' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='ContractVolumeamount' and `type`='salesGoalBudget');

insert into ld_expensebudget_totalcolumns (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'Invoicedamount','ld_salestarget.invoiceamount','','','','salesGoalBudget','0','SalesGoal' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='Invoicedamount' and `type`='salesGoalBudget');

insert into ld_expensebudget_totalcolumns (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'Outboundorderamount','ld_salestarget.outboundorderamount','','','','salesGoalBudget','0','SalesGoal' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='Outboundorderamount' and `type`='salesGoalBudget');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'ContractVolumeamount','ld_salesorder.total','ld_salesorder.signed_data','ld_salesorder.createdtime','yes','salesAchievementBudget','0','SalesOrder' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='ContractVolumeamount' and `type`='salesAchievementBudget' and `columns`="ld_salesorder.total");

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'ContractVolumeamount','ld_servicecontracts.total','ld_servicecontracts.due_date','ld_servicecontracts.createdtime','yes','salesAchievementBudget','0','ServiceContracts' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='ContractVolumeamount' and `type`='salesAchievementBudget' and `columns`="ld_servicecontracts.total");

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'Cashbillamount','ld_cashbill.Total','ld_cashbill.cashbilldate','ld_cashbill.createdtime','yes','salesAchievementBudget','1','CashBill' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='Cashbillamount' and `type`='salesAchievementBudget' and `columns`="ld_cashbill.Total");

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'SendCashBillamount','ld_sendcashbill.Total','ld_sendcashbill.cashbilldate','ld_sendcashbill.createdtime','yes','salesAchievementBudget','2','SendCashBill' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='SendCashBillamount' and `type`='salesAchievementBudget' and `columns`="ld_sendcashbill.Total");

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'SalesOrderBill','ld_salesorder.total','ld_salesorder.signed_data','ld_salesorder.createdtime','yes','salesAchievementBudget','3','SalesOrder' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='SalesOrderBill' and `type`='salesAchievementBudget' and `columns`="ld_salesorder.total");

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'ServiceContractamount','ld_servicecontracts.total','ld_servicecontracts.due_date','ld_servicecontracts.createdtime','yes','salesAchievementBudget','4','ServiceContract' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='ServiceContractamount' and `type`='salesAchievementBudget' and `columns`="ld_servicecontracts.total");

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'salesInvoice','ld_invoice.total','ld_invoice.invoicedate','ld_invoice.createdtime','yes','salesAchievementBudget','5','Invoice' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='salesInvoice' and `type`='salesAchievementBudget' and `columns`="ld_invoice.total");

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'PurchaseInvoiceamount','ld_purchaseinvoice.total','ld_purchaseinvoice.purchaseinvoicedate','ld_purchaseinvoice.createdtime','yes','salesAchievementBudget','6','PurchaseInvoice' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='PurchaseInvoiceamount' and `type`='salesAchievementBudget' and `columns`="ld_purchaseinvoice.total");

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'OutboundOrderBill','ld_outboundorder.total','ld_outboundorder.outdate','ld_outboundorder.createdtime','yes','salesAchievementBudget','7','OutboundOrder' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='OutboundOrderBill' and `type`='salesAchievementBudget' and `columns`="ld_outboundorder.total");

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`,modulename)
select 'Stockamount','ld_stock.total','ld_stock.createdate','ld_stock.createdtime','yes','salesAchievementBudget','8','Stock' from dual
where not exists(select 1 from ld_expensebudget_totalcolumns where `name`='Stockamount' and `type`='salesAchievementBudget' and `columns`="ld_stock.total");
delimiter;
-- 2021-06-20

UPDATE ld_desk SET fieldlabel='Approved' WHERE labelbol='APPROVEDSUCCESS' AND languagetype='en' AND fieldlabel='Approved successfully';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','EDITAPPROVEORDER','更改订单信息','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='EDITAPPROVEORDER' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','EDITAPPROVEORDER','Change order information','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='EDITAPPROVEORDER' and Labeltype='fixedstr');
delimiter;


DELETE FROM ld_systems_deploy WHERE deploy_type IN (324,325);
DELETE FROM ld_tranlabel WHERE Relateid IN (324,325) AND trantable='ld_systems_deploy';

SET @tmp_modulename='ExpenseBudget';
SET @tmp_zhmoudulename='费用预算单';
SET @tmp_deploy_type=324;
SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 0,@tmp_deploy_type,CONCAT(@tmp_zhmoudulename,'是否启用审批流程'),@tmp_modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@tmp_deploy_type);


select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 206;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 'ServiceContracts','325', '设置服务收费管理序时簿列表界面显示服务合同或联系人',@sequence+1,@roottype,'select',0,'[{"value":"ServiceContracts","text":"ServiceContracts"},{"value":"Contacts","text":"Contacts"},{"sql":""}]' from dual
where not exists(select * from ld_systems_deploy where deploy_type=325);

SET @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = 1 order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',325,325,'设置{$ServiceCharge.ServiceCharge}序时簿列表界面显示{$ServiceContracts.ServiceContracts}或{$Contacts.Contacts}' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=325 and relateid=325 and trantable='ld_systems_deploy' and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',325,325,'设置{$ServiceCharge.ServiceCharge}序时簿列表界面显示{$ServiceContracts.ServiceContracts}或{$Contacts.Contacts}' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=325 and relateid=325 and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','EDITAPPROVEORDER','更改订单信息','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='EDITAPPROVEORDER' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','EDITAPPROVEORDER','Change order information','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='EDITAPPROVEORDER' and Labeltype='fixedstr');
delimiter;


CALL AddColumn('ld_field', 'uploadwatermark', 'varchar', '20', 'no');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MobileUploadWatermark','移动端上传图片添加签到水印','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MobileUploadWatermark' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MobileUploadWatermark','Upload pictures on mobile terminal to add sign-in watermark','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MobileUploadWatermark' and labeltype = 'fixedstr');
delimiter;

update ld_field set masseditable = 0 where uitype = 53 and columnname = 'smownerid' and masseditable = 1;
delimiter;


CALL AddColumn('ld_expensebudget', 'advance_stage', 'varchar', '20', null);
set @fieldid = (select max(fieldid) from ld_field)+1;
set @tabid = (select tabid from ld_tab where name="ExpenseBudget");
set @tablename = 'ld_expensebudget';
set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_EXPENSEBUDGET_BASICINFORMATION');

INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`)
select @tabid, @fieldid, 'advance_stage', 'yes', @tablename, '1', '1', 'advance_stage', '推进阶段', '1', '1', NULL, '100', '13', @blockid, '3', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '1', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', '', NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='advance_stage');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='推进阶段' or fieldlabel ='Advance Stage');
set @field_id = (select fieldid from ld_field where tabid=@tabid and columnname='advance_stage');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @field_id, '推进阶段' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='推进阶段');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @field_id, 'Advance Stage' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Advance Stage');
delimiter;

select tabid into @tabid from ld_tab where name='ExpenseBudget';
select tabid into @relatedtabid from ld_tab where name='Attachment';
select max(sequence)+1 into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,type,related_coltable,buttonstatus)
select @relation_id+1,@tabid,@relatedtabid,'get_attachment',@sequence,'Attachment',0,'add','datacategory_sql','attachmentsforbills.related_to','yes' from dual
where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
update ld_relatedLists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;

update ld_producttoolfield set savedatabase='yes' where uitype<>'101' AND edit_permission<>1;
delimiter;
-- 2021-06-23

ALTER TABLE ld_salesback ALTER COLUMN approvestatus SET DEFAULT '未提交';
UPDATE ld_salesback SET approvestatus='已拒绝' WHERE IFNULL(approvestatus,'')='' AND salesbackstatus='中止';
UPDATE ld_salesback SET approvestatus='已批准' WHERE IFNULL(approvestatus,'')='' AND salesbackstatus='结束';
UPDATE ld_salesback SET approvestatus='未提交' WHERE IFNULL(approvestatus,'')='' ;
delimiter;

ALTER TABLE ld_attachmentsforbills ALTER COLUMN approvestatus SET DEFAULT '未提交';
ALTER TABLE ld_bankbranch ALTER COLUMN approvestatus SET DEFAULT '未提交';
ALTER TABLE ld_pricebook ALTER COLUMN approvestatus SET DEFAULT '未提交';
ALTER TABLE ld_projectmilestone ALTER COLUMN approvestatus SET DEFAULT '未提交';
ALTER TABLE ld_publicannouncement ALTER COLUMN approvestatus SET DEFAULT '未提交';
ALTER TABLE ld_vendorcontactrecords ALTER COLUMN approvestatus SET DEFAULT '未提交';
delimiter;

alter table ld_remindcvadvfilter modify comparator varchar(50);
delimiter;

drop PROCEDURE if exists crm_publicleads_beforereminds;
delimiter ||
create PROCEDURE crm_publicleads_beforereminds()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

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
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid  ');

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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUBGROUPUNFOLD','子部门默认收起','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SUBGROUPUNFOLD' and labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUBGROUPUNFOLD',"Subdepartments are folded by default",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SUBGROUPUNFOLD' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NORELATEDMODULES','没有相关模块','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NORELATEDMODULES' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NORELATEDMODULES','No related modules','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NORELATEDMODULES' and Labeltype='jspop');
delimiter;


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

UPDATE ld_version SET old_version='V8.4.3.0',current_version='V8.4.3.0',remark='V8.4.3.0-20210624',wx_version='V8.4.3.0';
delimiter;