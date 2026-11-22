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
-- 2022-07-20
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMERSELFSERVICECONFIGHOME09','服务小程序绑定微信公众号密钥','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CUSTOMERSELFSERVICECONFIGHOME09' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMERSELFSERVICECONFIGHOME09','Service applet binding wechat official account key','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CUSTOMERSELFSERVICECONFIGHOME09' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @labelbol = 'AdvanceValueIsEmpty';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'为空，进度无法显示','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'is empty, progress cannot be displayed!','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

select max(sequence) + 1 into @sequence from ld_systems_deploy where roottype = 8;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 1,350,'设置移动端单据详情界面相关模块是否横向显示','',@sequence,8,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 350);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',350,350,'设置移动端单据详情界面相关模块是否横向显示'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_systems_deploy' and tabid = 350 and relateid=350);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',350,350,'Set whether the relevant modules of the mobile terminal document details interface are displayed horizontally'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_systems_deploy' and tabid = 350 and relateid=350);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','aftertransferringtothehighseas','说明：转公海后，会重算保护结束日期并更新分配日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='aftertransferringtothehighseas' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','aftertransferringtothehighseas','Instructions: after transferring to the high seas, the protection end date will be recalculated and the distribution date will be updated','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='aftertransferringtothehighseas' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_users set wx_userid = "" ,wx_openid = "",dingtalk_userid = "",yunzhijia_openid = "",yunzhijia_wbuserid ="" where status ="Inactive";
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Reportsortingmethod','报表排序方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Reportsortingmethod' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Reportsortingmethod','Report sorting method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Reportsortingmethod' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIELDS','字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FIELDS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIELDS','field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FIELDS' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','METHOD','方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='METHOD' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','METHOD','method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='METHOD' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ColumnNameByReport','按报表列名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ColumnNameByReport' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ColumnNameByReport','Column name by Report','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ColumnNameByReport' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StatisticsResultValueByGroup','按分组统计结果值','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='StatisticsResultValueByGroup' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','StatisticsResultValueByGroup','Statistics result value by group','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='StatisticsResultValueByGroup' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customtable_sorting` (
    `report_id` int(19) NOT NULL COMMENT'报表ID',
    `sorttype` Varchar(20) COMMENT'排序方式 可选“按报表列名(bycolumnname)”、“按分组统计结果值（byresult）”，默认“按报表列名” ',
    `columnmodule` Varchar(50) COMMENT'排序字段来自模块 ',
    `columns` Varchar(255) COMMENT'排序字段',
    `sortmethod` Varchar(20) COMMENT'排序方式 desc asc ',
    `total_type` Varchar(20) COMMENT'统计方式 sum count avg等 ',
    `sequence` int(5) COMMENT'顺序 '
    )ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_customtable_sorting (report_id,sorttype,columnmodule,`columns`,sortmethod,sequence,total_type)
select
    c.report_id ,
    'bycolumnname' as sorttype,
    c.columnmodule,
    c.`columns`,
    'asc',
    c.sequence,c.total_type
from ld_customtable_columns  c
         left join ld_customtable tab on c.report_id=tab.report_id
         left join ld_customtable_sorting sort on sort.report_id=c.report_id and c.`columns`=sort.`columns`
where tab.deleted=0
  and (is_group='yes') and sort.report_id is null
order by c.report_id,c.sequence asc;

insert into ld_customtable_sorting (report_id,sorttype,columnmodule,`columns`,sortmethod,sequence,total_type)
select
    c.report_id ,
    'byresult' as sorttype,
    c.columnmodule,
    c.`columns`,
    c.order_by,
    c.sequence,c.total_type
from ld_customtable_columns  c
         left join ld_customtable tab on c.report_id=tab.report_id
where tab.deleted=0
  and (order_by='desc' or order_by='asc')
order by c.report_id,c.sequence asc ;

update ld_customtable_columns set order_by='no' where (order_by='desc' or order_by='asc');


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

	select userid_after_release into @allotaccount from ld_account_public_pool where id = tmp_pool_id;
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
-- 2022-07-22

CREATE TABLE IF NOT EXISTS`ld_module_setting_byuser` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `modulename` varchar(50) DEFAULT NULL ,
    `userid` int(19) DEFAULT NULL ,
    `label` varchar(50) DEFAULT NULL ,
    `type` varchar(30) DEFAULT NULL ,
    `content` Text DEFAULT NULL ,
    `createdtime` timestamp DEFAULT CURRENT_TIMESTAMP,
    `modifiedtime` timestamp ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

SET @labelbol = 'SHOWCURRENTAPPROVE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'只显示最近一次提交审批的日志','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Only the log of the latest submission for approval is displayed','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'HIDEAUTOPASSSTEP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'隐藏自动跳过的步骤','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Hide automatically skipped steps','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'HIDEAUTOPASSSTEP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'隐藏自动跳过的步骤','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Hide automatically skipped steps','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'HAVEPASSED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已通过','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Hide automatically skipped steps','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LOADMORENODES';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'加载更多节点','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Load more nodes','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2022-07-26

drop PROCEDURE if EXISTS ldcrm_addfield_advancetime_calender;
delimiter ||
create PROCEDURE ldcrm_addfield_advancetime_calender
(
)
BEGIN
		DECLARE tmp_module VARCHAR(100) DEFAULT NULL;
		DECLARE tmp_tabid INT(19) DEFAULT 0;
		DECLARE tmp_block INT(19) DEFAULT 0;
		DECLARE tmp_table VARCHAR(100) DEFAULT NULL;
		DECLARE tmp_primary_key VARCHAR(100) DEFAULT NULL;
		DECLARE MYCUSOR CURSOR FOR
			SELECT
				b.`name` AS module,
				a.tabid,
				a.block,
				a.tablename,
				b.primary_key
			FROM ld_field a
			LEFT JOIN ld_tab b ON b.tabid=a.tabid
			WHERE a.columnname='smownerid'
				AND a.tabid = 16
			GROUP BY a.tabid
			ORDER BY a.tabid;
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

		OPEN MYCUSOR;
		FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_block,tmp_table,tmp_primary_key;
		WHILE(tmp_tabid IS NOT NULL) DO
			SET @tabid=tmp_tabid;
			SET @relateid=tmp_block;
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
			SET @trantable='ld_field';
			SET @tablename=tmp_table;
			SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

			SET @presence = '1';
			set @sql="SELECT CASE WHEN `enable` = 'yes' or showadvancemobile = 'yes' THEN 2 ELSE 1 END as tmp into @presence from ld_settings_advance where tabid =";
			set @sql=CONCAT(@sql,@tabid);
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;

			SET @trantable='ld_field';
			SET @columnname='latestpushtime';
			SET @fieldname='latestpushtime';
			SET @zh='最新推进时间';
			SET @en='Latest push time';
			SET @uitype=86;
			SET @typeofdata='DT~O';
			SET @quickcreate=1;
			SET @displaytype=2;
			SET @bigtype='datetime';
			SET @datarang='NULL';
			SET @maxrowsshow=0;
			SET @savedatabase = 'YES';
			SET @allowedit = 'no';

			INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
			SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,IFNULL(@presence,1),NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
			UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

			SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALL AddColumn(@tablename,@columnname,'datetime','','');

			IF @presence = 2 THEN
					SET @sql1 = " INNER JOIN
											(SELECT MAX(ld_modtracker_basic.changedon) as tmp_changedon,ld_modtracker_basic.crmid from ld_modtracker_basic
												INNER JOIN ld_modtracker_detail on ld_modtracker_basic.id = ld_modtracker_detail.id
												INNER JOIN ld_settings_advance on ld_settings_advance.module_field = ld_modtracker_detail.fieldname
													AND ld_settings_advance.module = ld_settings_advance.module where ld_settings_advance.tabid =";
					SET @sql2 = " GROUP BY ld_modtracker_basic.crmid) as tmp
											on ";
					SET @sql3 = " = tmp.crmid SET latestpushtime = tmp.tmp_changedon";
					SET @sql4 = CONCAT('UPDATE ',@tablename,@sql1,@tabid,@sql2,tmp_primary_key,@sql3);
					prepare stmt from @sql4;
					execute stmt;
					deallocate prepare stmt;
			END IF;


			FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_block,tmp_table,tmp_primary_key;
		END WHILE;
		CLOSE MYCUSOR;

end ||
delimiter;

SET @disable_triggers = 'aaaa';
call ldcrm_addfield_advancetime_calender();
SET @disable_triggers = NULL;
drop PROCEDURE if EXISTS ldcrm_addfield_advancetime_calender;
delimiter;

CALL AddColumn('ld_systems','security_code_template','text','','');
delimiter;

update ld_field set typeofdata = 'N~O' where tabid = 6 and columnname = 'discount_rate' and typeofdata like 'N~O%';
delimiter;
update ld_field set typeofdata = 'N~M' where tabid = 6 and columnname = 'discount_rate' and typeofdata like 'N~M%';
delimiter;

set @tabid =(select tabid from ld_tab where `name`='Users');
SET @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='is_mobile_style');
update ld_field set fieldlabel='手机号码显示样式控制'  where fieldid=@fieldid and fieldlabel='手机显示样式控制';
update ld_tranlabel set fieldlabel='手机号码显示样式控制'  where Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and fieldlabel='手机显示样式控制';
update ld_tranlabel set fieldlabel='Control the displayed style of mobile phone number'  where Relateid=@fieldid and trantable='ld_field' and languagetype='en' and fieldlabel='Control the displayed style of mobile phone';
delimiter;

UPDATE ld_desk SET fieldlabel='取消授权' WHERE labelbol='CLOSE' AND languagetype='zh' AND Labeltype='jspop' AND fieldlabel='除权';
-- 2022-07-27

update ld_desk set fieldlabel = '经销商折扣价' where labelbol = 'Dealerorderdiscountprice' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

drop PROCEDURE if EXISTS ldcrm_addprofiletofield_fileattachment_getfields;
delimiter ||
create PROCEDURE ldcrm_addprofiletofield_fileattachment_getfields
(
)
BEGIN
		DECLARE tmp_tabid INT(19) DEFAULT 0;
		DECLARE tmp_fieldid INT(19) DEFAULT 0;
		
		DECLARE MYCUSOR CURSOR FOR 
			SELECT 
				a.tabid,
				a.fieldid
			FROM ld_field a
			WHERE a.bigtype='fileattachment'
			ORDER BY a.tabid;
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

		OPEN MYCUSOR; 
		FETCH MYCUSOR INTO tmp_tabid,tmp_fieldid;
		WHILE(tmp_tabid IS NOT NULL) DO
			call ldcrm_addprofiletofield_fileattachment_addprofile(tmp_tabid,tmp_fieldid);
			FETCH MYCUSOR INTO tmp_tabid,tmp_fieldid;
		END WHILE;
		CLOSE MYCUSOR;
		
end ||
delimiter;

drop PROCEDURE if EXISTS ldcrm_addprofiletofield_fileattachment_addprofile;
delimiter ||
create PROCEDURE ldcrm_addprofiletofield_fileattachment_addprofile
(
var_tabid int(19),
var_fieldid int(19)
)
BEGIN
		DECLARE tmp_profileid INT(19) DEFAULT 0;
		
		DECLARE MYCUSOR CURSOR FOR 
			SELECT 
				a.profileid
			FROM ld_profile a;
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

		OPEN MYCUSOR; 
		FETCH MYCUSOR INTO tmp_profileid;
		WHILE(tmp_profileid IS NOT NULL) DO
			
			IF EXISTS (SELECT 1 from ld_profile2field where fieldid = var_fieldid and tabid = var_tabid AND profileid = tmp_profileid ) THEN
				UPDATE ld_profile2field SET visible = 0,readonly = 0,editreadonly = 0 where fieldid = var_fieldid and tabid = var_tabid AND profileid = tmp_profileid;
			ELSEIF EXISTS (SELECT 1 FROM ld_profile2field WHERE fieldid=var_fieldid AND tabid <> var_tabid AND profileid = tmp_profileid ) THEN
				DELETE FROM ld_profile2field WHERE fieldid=var_fieldid AND tabid <> var_tabid AND profileid = tmp_profileid;
				INSERT into ld_profile2field(profileid,tabid,fieldid,visible,readonly,editreadonly) VALUES(tmp_profileid,var_tabid,var_fieldid,0,0,0);
			ELSE
				INSERT into ld_profile2field(profileid,tabid,fieldid,visible,readonly,editreadonly) VALUES(tmp_profileid,var_tabid,var_fieldid,0,0,0);
			END IF;

			FETCH MYCUSOR INTO tmp_profileid;
		END WHILE;
		CLOSE MYCUSOR;
		
end ||
delimiter;

call ldcrm_addprofiletofield_fileattachment_getfields();
drop PROCEDURE if EXISTS ldcrm_addprofiletofield_fileattachment_getfields;
drop PROCEDURE if EXISTS ldcrm_addprofiletofield_fileattachment_addprofile;
delimiter;


call AddColumn('ld_wechatuser','userid','INT','19','0');
select tabid into @tabid from ld_tab where name='WechatUser';
select max(fieldid) into @maxfieldid from ld_field ;
select max(sequence) into @maxsequence from ld_field where tabid=@tabid;
select block into @blockid from ld_field where columnname='accountid' and tabid=@tabid;

INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,
                      issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'userid','yes','ld_wechatuser',1,153,'userid','成员名称',1,0,@maxsequence+1,@blockid ,1,'V~O',1,0,1,2,'selectoneuser',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='userid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='userid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'成员名称' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Member name' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


call AddColumn('ld_wechatuser','bindtype','VARCHAR','255','');
select tabid into @tabid from ld_tab where name='WechatUser';
select max(fieldid) into @maxfieldid from ld_field ;
select max(sequence) into @maxsequence from ld_field where tabid=@tabid;
select block into @blockid from ld_field where columnname='accountid' and tabid=@tabid;

INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,
                      issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'bindtype','yes','ld_wechatuser',1,15,'bindtype','关联类型',1,0,@maxsequence+1,@blockid ,1,'V~O',1,0,1,2,'picklist',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='bindtype');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bindtype');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'关联类型' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Association type' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

insert into ld_picklist_set(listname,relatetable,picklist_allowedit)
select 'bindtype','ld_field','yes' from dual
where not exists(select 1 from ld_picklist_set where listname = 'bindtype' and relatetable = 'ld_field');
delimiter;

select listid into @listid from ld_picklist_set where listname = 'bindtype' and relatetable = 'ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'客户',1 from dual
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '客户');
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'用户',2 from dual
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '用户');

CREATE TABLE IF NOT EXISTS `ld_weixin_msg` (
    `msgid` int(19) NOT NULL AUTO_INCREMENT,
    `template_id` varchar(255) DEFAULT NULL COMMENT '消息模板ID',
    `title` varchar(255) DEFAULT NULL COMMENT '消息标题',
    `pageurl` varchar(255) DEFAULT NULL COMMENT '跳转页面',
    `content` text COMMENT '内容',
    `wechatuserid` int(19) DEFAULT NULL COMMENT '微信用户模块ID',
    `modulename` varchar(100) DEFAULT NULL COMMENT '模块ID',
    `record` int(19) DEFAULT NULL COMMENT '关联单据ID',
    `createdtime` datetime DEFAULT NULL COMMENT '创建时间',
    `sendtime` datetime DEFAULT NULL COMMENT '发送时间',
    `sendmessage` varchar(255) DEFAULT NULL COMMENT '发送反馈',
    `sendstatus` varchar(255) DEFAULT NULL COMMENT '发送状态no未发送success已发送 error发送失败',
    `accountid` int(19) DEFAULT NULL COMMENT '客户ID',
    `open_id` varchar(255) DEFAULT NULL,
    `userfrom` varchar(100) DEFAULT NULL,
    `userfromvalue` varchar(100) DEFAULT NULL,
    PRIMARY KEY  (`msgid`)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_temp_openid_list` (
    `open_id` varchar(255) DEFAULT ' ',
    `status` int(2) default 0,
    PRIMARY KEY  (`open_id` )
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

SET @labelbol = 'Appletremindersettings';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'小程序提醒设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Applet reminder settingsm','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AppletAppID';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'小程序AppID','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Applet AppID','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AppletSecret';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'小程序Secret','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Applet Secret','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WechatofficialaccountAppId';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'微信公众号AppID','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Wechat official account AppId','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WechatofficialaccountSecret';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'微信公众号Secret','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Wechat official account Secret','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WECHATAPPLETSETTINGSREMIND06';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'微信公众号，用于接收消息','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Wechat official account, used to receive messages','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WECHATAPPLETSETTINGSREMIND07';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'小程序需要OEM','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Applet requires OEM','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WECHATAPPLETSETTINGSREMIND08';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'需要申请微信开放平台，并将微信公众号和小程序绑定在开放平台中','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'You need to apply for wechat open platform and bind wechat official account and applet in the open platform','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WECHATAPPLETSETTINGSREMIND09';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'目前可接收分配和审批提醒','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Currently, you can receive allocation and approval reminders','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @labelbol = 'OffiaccountUserSync';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'同步公众号用户','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Synchronize official account users','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2022-07-28

INSERT INTO `ld_customreport` (`report_name`, `report_desc`, `report_type`, `parent_id`, `sequence`, `mainmodule`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `limit`, `orderby`, `orderby_type`, `smcreatorid`, `stat_approach`, `approveallocatetype`, `show_athome`, `linkmodulecheck`, `can_penetrate`, `relatedmodule`)
SELECT '默认图表', '默认图表', 'folder', '0', NULL, NULL, '2022-07-21 16:14:57', NULL, '0', NULL, NULL, NULL, NULL, '1', NULL, '0', NULL, 'no', 'no', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport WHERE report_name='默认图表');

-- 员工待转化线索
SET @seq=-2;
SET @parent_id=(SELECT report_id FROM ld_customreport WHERE report_type='folder' AND report_name='默认图表' ORDER BY report_id ASC LIMIT 1);
INSERT INTO `ld_customreport` (`report_name`, `report_desc`, `report_type`, `parent_id`, `sequence`, `mainmodule`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `limit`, `orderby`, `orderby_type`, `smcreatorid`, `stat_approach`, `approveallocatetype`, `show_athome`, `linkmodulecheck`, `can_penetrate`, `relatedmodule`)
SELECT '员工待转化线索', '统计每个员工名下未转化成客户的线索数量', 'chart', @parent_id, @seq, 'Leads', '2022-07-21 15:41:34', NULL, '0', NULL, '0', '', 'desc', '1', '', '0', 'no', 'no', 'no', '' FROM  DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport WHERE parent_id=@parent_id AND report_name='员工待转化线索' AND report_type='chart');

SET @report_id=(SELECT report_id FROM ld_customreport WHERE parent_id=@parent_id AND report_type='chart' AND report_name='员工待转化线索' ORDER BY report_id DESC LIMIT 1);
INSERT INTO `ld_customreport_chartset` (`report_id`, `title`, `chart_type`, `xAxis`, `yAxis`, `legend`, `tooltip`, `toolbox`, `show_percent`, `funnel_type`)
SELECT @report_id, '{\"text\":\"员工待转化线索\"}', 'bar', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"成员姓名\",\"axisLabel\":{\"rotate\":0}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"线索量\"}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_chartset WHERE report_id=@report_id);

INSERT INTO `ld_customreport_total_column` (`report_id`, `total_type`, `columns`, `sequence`, `chart_column_type`, `color`, `chart_column_name`, `yaxisindex`, `column_module`)
SELECT @report_id, 'count', 'ld_leads:leads_no:leads_no:Leads_销售线索编号:V', '0', 'bar', '', '线索数量', '0', 'Leads' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_total_column WHERE report_id=@report_id AND columns LIKE 'ld_leads:leads_no:leads_no%');


INSERT INTO `ld_customreport_group` (`report_id`, `groupbytype`, `columns`, `sequence`, `bigtype`)
SELECT @report_id,'byField', 'ld_leads:smownerid:assigned_user_id:Leads_负责人:V', '0', 'users' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_group WHERE report_id=@report_id AND columns LIKE 'ld_leads:smownerid:assigned_user_id%');
delimiter;


-- 本季度预计成交重点商机TOP10
SET @seq=-1;
SET @parent_id=(SELECT report_id FROM ld_customreport WHERE report_type='folder' AND report_name='默认图表' ORDER BY report_id ASC LIMIT 1);
INSERT INTO `ld_customreport` (`report_name`, `report_desc`, `report_type`, `parent_id`, `sequence`, `mainmodule`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `limit`, `orderby`, `orderby_type`, `smcreatorid`, `stat_approach`, `approveallocatetype`, `show_athome`, `linkmodulecheck`, `can_penetrate`, `relatedmodule`)
SELECT '本季度预计成交重点商机TOP10', '根据预计成交日期，按照非成交或失败状态的商机按预计合同金额大小排名', 'chart', @parent_id, @seq, 'Potentials', '2022-07-26 14:17:42', NULL, '0', NULL, '10', '', 'desc', '1', '', '0', 'no', 'no', 'no', '' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport WHERE parent_id=@parent_id AND report_name='本季度预计成交重点商机TOP10' AND report_type='chart');

SET @report_id=(SELECT report_id FROM ld_customreport WHERE parent_id=@parent_id AND report_type='chart' AND report_name='本季度预计成交重点商机TOP10' ORDER BY report_id DESC LIMIT 1);
DELETE FROM ld_customreport_chartset WHERE report_id=@report_id;
INSERT INTO `ld_customreport_chartset` (`report_id`, `title`, `chart_type`, `xAxis`, `yAxis`, `legend`, `tooltip`, `toolbox`, `show_percent`, `funnel_type`)
SELECT @report_id, '{\"text\":\"本季度预计成交重点商机TOP10\"}', 'simple_strip', '{\"bottom\":{\"type\":\"value\",\"position\":\"bottom\",\"name\":\"\"}}', '{\"left\":{\"type\":\"category\",\"position\":\"left\",\"name\":\"项目名称\",\"axisLabel\":{\"rotate\":0}}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL;

DELETE FROM ld_customreport_cvadvfilter WHERE report_id=@report_id;
INSERT INTO `ld_customreport_cvadvfilter` (`report_id`,`columnindex`, `groupid`, `columns`, `comparator`, `value`, `columncondition`)
SELECT @report_id, '0', '1', 'ld_potential:sales_stage:sales_stage:Potentials_销售阶段:V', 'k', '失败', 'and';

INSERT INTO `ld_customreport_cvadvfilter` (`report_id`,`columnindex`, `groupid`, `columns`, `comparator`, `value`, `columncondition`)
SELECT @report_id, '1', '1', 'ld_potential:closingdate:closingdate:Potentials_预计成交日期  :D', 'thisfq', '2022-07-01', 'and';

INSERT INTO `ld_customreport_cvadvfilter` (`report_id`,`columnindex`, `groupid`, `columns`, `comparator`, `value`, `columncondition`)
SELECT @report_id, '2', '1', 'ld_potential:sales_stage:sales_stage:Potentials_销售阶段:V', 'k', '成功', 'and';

DELETE FROM ld_customreport_cvadvfilter_grouping WHERE report_id=@report_id;
INSERT INTO `ld_customreport_cvadvfilter_grouping` (`report_id`, `groupid`, `group_condition`) 
SELECT @report_id, '1', '';

DELETE FROM ld_customreport_total_column WHERE report_id=@report_id;
INSERT INTO `ld_customreport_total_column` (`report_id`, `total_type`, `columns`, `sequence`, `chart_column_type`, `color`, `chart_column_name`, `yaxisindex`, `column_module`)
SELECT @report_id,'sum', 'ld_potential:amount:amount:Potentials_预计合同金额:N', '0', 'bar', '', '预计成交金额', '0', 'Potentials';

DELETE FROM ld_customreport_group WHERE report_id=@report_id;
INSERT INTO `ld_customreport_group` (`report_id`, `groupbytype`, `columns`, `sequence`, `bigtype`)
SELECT @report_id,'byField', 'ld_potential:potentialname:potentialname:Potentials_机会名称:V', '0', 'text';

SET @i=0;
UPDATE ld_customreport SET sequence=(@i:=@i+1) WHERE parent_id=@parent_id ORDER BY sequence;
delimiter;


-- 公海客户分类统计
SET @parent_id=(SELECT report_id FROM ld_customtable WHERE parent_id=0 AND report_name='默认报表（默认）' ORDER BY report_id ASC LIMIT 1);
SET @seq=-10;
INSERT INTO `ld_customtable` (`report_name`, `parent_id`, `description`, `sequence`, `linkmodulecheck`, `total_position`, `show_subtotal`, `show_detail`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `smcreatorid`, `approveallocatetype`)
SELECT '公海客户分类统计', @parent_id, '统计每个公海的客户情况', @seq, 'no', 'bottom', 'no', 'yes', '2022-07-22 10:57:54', '2022-07-29 13:57:41', '0', '1', '1', '0' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customtable WHERE report_name='公海客户分类统计');

SET @report_id=(SELECT report_id FROM ld_customtable WHERE parent_id=@parent_id AND report_name='公海客户分类统计' ORDER BY report_id DESC LIMIT 1);
DELETE FROM ld_customtable_columns WHERE report_id=@report_id;
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '所属公海', 'ld_account:pool_id:pool_id:Accounts_所属公海:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', '0', '所属公海', 'a', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', '1', '客户名称', 'b', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '销售负责人', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', '2', '销售负责人', 'f', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '公海状态', 'ld_account:publicaccount:publicaccount:Accounts_公海状态:C', 'Accounts', 'yes', 'no', 'yes', '', 'left', '3', '公海状态', 'c', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '最新领取日期', 'ld_account:allocatedate:allocatedate:Accounts_领取日期:D', 'Accounts', 'yes', 'no', 'yes', '', 'left', '4', '领取日期', 'e', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '最新公海分配日期', 'ld_account:lastdistributedate:lastdistributedate:Accounts_公海分配日期:D', 'Accounts', 'yes', 'no', 'yes', '', 'left', '5', '公海分配日期', 'd', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '保护结束日期', 'ld_account:protectdate:protectdate:Accounts_保护结束日期:D', 'Accounts', 'yes', 'no', 'yes', '', 'left', '6', '保护结束日期', 'g', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '客户编号', 'ld_account:account_no:account_no:Accounts_客户编号:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', '7', '客户编号', 'h', '', '0', '', '');

DELETE FROM ld_customtable2user WHERE report_id=@report_id;
INSERT INTO `ld_customtable2user` (`report_id`, `userid`) VALUES (@report_id, '-1');

DELETE FROM ld_customtable_condition WHERE report_id=@report_id;
INSERT INTO `ld_customtable_condition` (`report_id`, `columns`, `comparator`, `value`, `groupid`, `columncondition`) VALUES (@report_id, 'ld_account:publicaccount:publicaccount:Accounts_公海状态:C', 'n', '普通客户', '2', 'and');

DELETE FROM ld_customtable_condition_grouping WHERE report_id=@report_id;

DELETE FROM ld_customtable_module WHERE report_id=@report_id;
INSERT INTO `ld_customtable_module` (`report_id`, `tabid`, `modulename`, `parent_id`) VALUES (@report_id, '6', 'Accounts', '0');
delimiter;

-- 成员商机状态统计
SET @parent_id=(SELECT report_id FROM ld_customtable WHERE parent_id=0 AND report_name='默认报表（默认）' ORDER BY report_id ASC LIMIT 1);
SET @seq=-9;
INSERT INTO `ld_customtable` (`report_name`, `parent_id`, `description`, `sequence`, `linkmodulecheck`, `total_position`, `show_subtotal`, `show_detail`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `smcreatorid`, `approveallocatetype`)
SELECT '成员商机状态统计', @parent_id, '', @seq, 'no', 'bottom', 'no', 'yes', '2022-07-22 10:57:54', '2022-07-29 13:57:41', '0', '1', '1', '0' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customtable WHERE report_name='成员商机状态统计');

SET @report_id=(SELECT report_id FROM ld_customtable WHERE parent_id=@parent_id AND report_name='成员商机状态统计' ORDER BY report_id DESC LIMIT 1);
DELETE FROM ld_customtable_columns WHERE report_id=@report_id;
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '销售负责人', 'ld_potential:smownerid:assigned_user_id:Potentials_销售负责人:V', 'Potentials', 'yes', 'no', 'yes', '', 'left', '0', '销售负责人', 'a', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '销售阶段', 'ld_potential:sales_stage:sales_stage:Potentials_销售阶段:V', 'Potentials', 'no', 'no', 'yes', '', 'left', '1', '销售阶段', 'b', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '预计成交金额', 'ld_potential:amount:amount:Potentials_预计合同金额:N', 'Potentials', 'no', 'no', 'no', 'sum', 'right', '2', '预计合同金额', 'c', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '预计成交日期', 'ld_potential:closingdate:closingdate:Potentials_预计成交日期  :D', 'Potentials', 'no', 'no', 'no', '', 'left', '3', '预计成交日期', 'd', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '可能性(%)', 'ld_potentialscf:possibility:possibility:Potentials_可能性(%):V', 'Potentials', 'no', 'no', 'no', '', 'left', '4', '可能性(%)', 'e', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '未推进天数', 'ld_potential:staydays:staydays:Potentials_未推进天数:N', 'Potentials', 'no', 'no', 'no', 'sum', 'right', '5', '未推进天数', 'f', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '客户名称', 'ld_potential:accountid:account_id:Potentials_客户名称:V', 'Potentials', 'no', 'no', 'no', '', 'left', '6', '客户名称', 'g', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '最新进展', 'ld_potential:lastcontent:lastcontent:Potentials_最新进展:V', 'Potentials', 'no', 'no', 'no', '', 'left', '7', '最新进展', 'h', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '最新联系日期', 'ld_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:DT', 'Potentials', 'no', 'no', 'no', '', 'left', '8', '最新联系日期', 'i', '', '0', '', '');

DELETE FROM ld_customtable2user WHERE report_id=@report_id;
INSERT INTO `ld_customtable2user` (`report_id`, `userid`) VALUES (@report_id, '-1');

DELETE FROM ld_customtable_condition WHERE report_id=@report_id;

DELETE FROM ld_customtable_condition_grouping WHERE report_id=@report_id;

DELETE FROM ld_customtable_module WHERE report_id=@report_id;
INSERT INTO `ld_customtable_module` (`report_id`, `tabid`, `modulename`, `parent_id`) VALUES (@report_id, '2', 'Potentials', '0');
delimiter;


-- 产品采购汇总表
SET @parent_id=(SELECT report_id FROM ld_customtable WHERE parent_id=0 AND report_name='默认报表（默认）' ORDER BY report_id ASC LIMIT 1);
SET @seq=-8;
INSERT INTO `ld_customtable` (`report_name`, `parent_id`, `description`, `sequence`, `linkmodulecheck`, `total_position`, `show_subtotal`, `show_detail`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `smcreatorid`, `approveallocatetype`)
SELECT '产品采购汇总表', @parent_id, '', @seq, 'no', 'bottom', 'no', 'yes', '2022-07-22 10:57:54', '2022-07-29 13:57:41', '0', '1', '1', '0' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customtable WHERE report_name='产品采购汇总表');

SET @report_id=(SELECT report_id FROM ld_customtable WHERE parent_id=@parent_id AND report_name='产品采购汇总表' ORDER BY report_id DESC LIMIT 1);
DELETE FROM ld_customtable_columns WHERE report_id=@report_id;
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '产品名称', 'ld_products:productname:productname:PurchaseOrder_产品名称:V', 'PurchaseOrder', 'yes', 'no', 'yes', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '产品类别', 'ld_products:productcategory:productcategory:PurchaseOrder_产品类别:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', '1', '产品类别', 'h', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '产品编号', 'ld_products:product_no:product_no:PurchaseOrder_产品编号:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', '2', '产品编号', 'b', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '规格型号', 'ld_products:productsheet:productsheet:PurchaseOrder_规格型号:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', '3', '规格型号', 'c', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '计量单位', 'ld_products:usageunit:usageunit:PurchaseOrder_计量单位:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', '4', '计量单位', 'd', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '采购数量', 'ld_purchaseorderdetail:quantity:quantity:PurchaseOrder_数量:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', '5', '数量', 'e', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '采购金额', 'ld_purchaseorderdetail:tax_amount:tax_amount:PurchaseOrder_价税合计:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', '6', '价税合计', 'g', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '采购订单编号', 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', '7', '采购订单编号', 'f', '', '0', '', '');

DELETE FROM ld_customtable2user WHERE report_id=@report_id;
INSERT INTO `ld_customtable2user` (`report_id`, `userid`) VALUES (@report_id, '-1');

DELETE FROM ld_customtable_condition WHERE report_id=@report_id;

DELETE FROM ld_customtable_condition_grouping WHERE report_id=@report_id;

DELETE FROM ld_customtable_module WHERE report_id=@report_id;
INSERT INTO `ld_customtable_module` (`report_id`, `tabid`, `modulename`, `parent_id`) VALUES (@report_id, '21', 'PurchaseOrder', '0');
delimiter;


-- 产品销量统计(按合同）
SET @parent_id=(SELECT report_id FROM ld_customtable WHERE parent_id=0 AND report_name='默认报表（默认）' ORDER BY report_id ASC LIMIT 1);
SET @seq=-7;
INSERT INTO `ld_customtable` (`report_name`, `parent_id`, `description`, `sequence`, `linkmodulecheck`, `total_position`, `show_subtotal`, `show_detail`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `smcreatorid`, `approveallocatetype`)
SELECT '产品销量统计(按合同）', @parent_id, '', @seq, 'no', 'bottom', 'no', 'yes', '2022-07-28 18:34:03', '2022-07-29 13:57:01', '0', '1', '1', '0' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customtable WHERE report_name='产品销量统计(按合同）');

SET @report_id=(SELECT report_id FROM ld_customtable WHERE parent_id=@parent_id AND report_name='产品销量统计(按合同）' ORDER BY report_id DESC LIMIT 1);
DELETE FROM ld_customtable_columns WHERE report_id=@report_id;
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '产品编号', 'ld_products:product_no:product_no:SalesOrder_产品编号:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', '1', '产品编号', 'g', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '产品类别', 'ld_products:productcategory:productcategory:SalesOrder_产品类别:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', '2', '产品类别', 'h', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', '3', '销售负责人', 'b', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '4', '合同编号', 'c', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', '5', '签约日期', 'd', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '6', '数量', 'e', '', '0', '', '');
INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`) VALUES (@report_id, '销售价', 'ld_salesorderdetail:tax_amount:tax_amount:SalesOrder_价税合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '7', '价税合计', 'f', '', '0', '', '');

DELETE FROM ld_customtable2user WHERE report_id=@report_id;
INSERT INTO `ld_customtable2user` (`report_id`, `userid`) VALUES (@report_id, '-1');

DELETE FROM ld_customtable_condition WHERE report_id=@report_id;

DELETE FROM ld_customtable_condition_grouping WHERE report_id=@report_id;

DELETE FROM ld_customtable_module WHERE report_id=@report_id;
INSERT INTO `ld_customtable_module` (`report_id`, `tabid`, `modulename`, `parent_id`) VALUES (@report_id, '22', 'SalesOrder', '0');
delimiter;

SET @i=0;
SET @parent_id=(SELECT report_id FROM ld_customtable WHERE parent_id=0 AND report_name='默认报表（默认）' ORDER BY report_id ASC LIMIT 1);
UPDATE ld_customtable SET sequence=(@i:=@i+1) WHERE parent_id=@parent_id ORDER BY sequence;
delimiter;

update ld_field set allowedit = 'yes' where  tabid = 6 and columnname = 'registration_time';
delimiter;

UPDATE ld_desk set fieldlabel = '最近6个月个人销售情况' where labelbol = 'INDIVIDUALSIXMONTH' AND languagetype = 'zh' AND Labeltype = 'fixedstr';
delimiter;

UPDATE ld_desk SET fieldlabel = '签到轨迹表' where labelbol = 'Sign_in_track' AND languagetype = 'zh' AND Labeltype = 'fixedstr';
delimiter;
UPDATE ld_usereport SET reportlabel = '签到轨迹表' where `name` = 'Sign_in_track';
delimiter;

insert into ld_customtable_sorting (report_id,sorttype,columnmodule,`columns`,sortmethod,sequence,total_type)
select
    c.report_id ,
    'bycolumnname' as sorttype,
    c.columnmodule,
    c.`columns`,
    'asc',
    c.sequence,c.total_type
from ld_customtable_columns  c
left join ld_customtable tab on c.report_id=tab.report_id
left join ld_customtable_sorting sort on sort.report_id=c.report_id and c.`columns`=sort.`columns`
where tab.deleted=0
  and (is_group='yes') and sort.report_id is null
order by c.report_id,c.sequence asc;



insert into ld_customtable_sorting (report_id,sorttype,columnmodule,`columns`,sortmethod,sequence,total_type)
select
    c.report_id ,
    'byresult' as sorttype,
    c.columnmodule,
    c.`columns`,
    c.order_by,
    c.sequence,c.total_type
from ld_customtable_columns  c
left join ld_customtable tab on c.report_id=tab.report_id
where tab.deleted=0
  and (order_by='desc' or order_by='asc')
order by c.report_id,c.sequence asc ;

update ld_customtable_columns set order_by='no' where (order_by='desc' or order_by='asc');
-- 2022-07-29

update ld_field set allowedit = 'no' where bigtype='translatefield' and displaytype = 1 ;
SET @disable_triggers=1;
update ld_cashbill set cashtype='cashbill' where cashtype='收款';
SET @disable_triggers=NULL;
delimiter; 
-- 2022-08-02

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

UPDATE ld_version SET old_version='V8.4.7.0',current_version='V8.4.7.0',remark='V8.4.7.0-20220802',wx_version='V8.4.7.0';
delimiter;