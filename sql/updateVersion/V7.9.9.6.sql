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

select sequence into @sequence from ld_systems_deploy where deploy_type=204;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
  select 0,210,'设置移动端带分录的单据详情界面默认值显示',@sequence+1,8,'select',0,'[{"value":"0","text":"DETAIL"},{"value":"1","text":"details1"},{"sql":""}]'
  from dual where not exists(select 1 from ld_systems_deploy  where deploy_type=210);
set @i=@sequence;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=8 and sequence>@sequence order by sequence asc;

select deploy_type into @relateid from ld_systems_deploy where deploy_type=210;
insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_systems_deploy',@relateid,@relateid,'设置移动端带分录的单据详情界面默认值显示' from DUAL
  where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='zh');

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_systems_deploy',@relateid,@relateid,
    'Set the default value of the document details interface with entries on the mobile end to display'
  from DUAL
  where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

call AddColumn('ld_wx_config','para_content','text',null ,null );
alter table `ld_wx_config` change `para_content` `para_content` text DEFAULT null COMMENT '参数Json集合' after `description`;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','H5MICAPP','H5微应用','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='H5MICAPP' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','H5MICAPP','H5 Micro Application','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='H5MICAPP' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','PCHOMEADDRESS','PC端首页地址','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PCHOMEADDRESS' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','PCHOMEADDRESS','PC home address','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PCHOMEADDRESS' and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_tmp_wx_reminds','client_type','varchar',100,null );
delimiter;
update ld_tmp_wx_reminds set client_type='weixin' where client_type is null or client_type='';

select tabid into @tabid from ld_tab where name='Users';
select fieldid into @fieldid from ld_field where  tabid=@tabid and  columnname='push_wx_reminds';
update ld_tranlabel set fieldlabel='是否允许推送移动端提醒' where trantable='ld_field' and tabid=@tabid and relateid=@fieldid and languagetype='zh';
update ld_tranlabel set fieldlabel='Is it allowed to push mobile notifications' where trantable='ld_field' and tabid=@tabid and relateid=@fieldid and languagetype='en';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','FORMATERROR','格式错误','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FORMATERROR' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','FORMATERROR','Format error','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FORMATERROR' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','PARAMETERSNOTBENULL','全部参数均不能为空','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PARAMETERSNOTBENULL' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','PARAMETERSNOTBENULL','all parameters cannot be null','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PARAMETERSNOTBENULL' and Labeltype='fixedstr');

call AddColumn('ld_reminds','push_to_ding','int','2',0);
delimiter;
call AddColumn('ld_workreport_remind','push_to_ding','int','2',0);
delimiter;
CALL AddColumn('ld_reminds','push_time_ding','datetime',null ,null );
delimiter;
CALL AddColumn('ld_workreport_remind','push_time_ding','datetime',null,null);
delimiter;

alter table `ld_reminds` change `push_to_ding` `push_to_ding` int DEFAULT 2 COMMENT '钉钉提醒发送标识' after `push_to_weixin`;
alter table `ld_reminds` change `push_time_ding` `push_time_ding` datetime COMMENT '钉钉提醒发送时间' after `push_time`;
alter table `ld_workreport_remind` change `push_to_ding` `push_to_ding` int DEFAULT 2 COMMENT '钉钉提醒发送标识' after `push_to_weixin`;
alter table `ld_workreport_remind` change `push_time_ding` `push_time_ding` datetime COMMENT '钉钉提醒发送时间' after `push_time`;
delimiter;
-- 2020-01-03

drop PROCEDURE if exists account_singlerecycle_normal_rule_beforeremind;
delimiter ||
create PROCEDURE account_singlerecycle_normal_rule_beforeremind()
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
 
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
   
	select beforereminddays into @var_beforereminddays from ld_account_set;
  if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
   set @maxdays=@maxdays-@var_beforereminddays;
	select recycleselect into @recycleselect from ld_account_set;
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


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
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
				 set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.status='active' and ld_account_set_rule.status='active' ORDER BY ld_account_set_rule.sequence asc ) ";

				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

				set @TMPSQL_ONE=concat( ' select "normal", group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				if @recycleselect<>'' and @recycleselect is not null THEN	
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
				end if;	
				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
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


end ||
delimiter;

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

UPDATE ld_version SET old_version='V7.9.9.6',current_version='V7.9.9.6',remark='V7.9.9.6-20200103',wx_version='V7.9.9.6';
delimiter;