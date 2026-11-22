update ld_desk set fieldlabel = '按{$SalesGoal.SalesGoal}预算' where labelbol = 'salesGoalBudget' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Budget according to {$SalesGoal.SalesGoal}' where labelbol = 'salesGoalBudget' and languagetype = 'en';
delimiter;


SET @sequence = (select max(sequence)+1 from ld_mobile_report_tab_rel);
select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='statistical';
select id into @reportid from ld_dashboard_app where name = 'TargetCompletionRate';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename) select @block_id,@reportid,1,'ld_tab'
from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
delimiter;

SET @labelbol = 'REMAINONEINDICATOR';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'至少保留一个指标名称','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Reserve at least one indicator name','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WebsiteTitle','网站标题','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WebsiteTitle' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WebsiteTitle','Website title','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WebsiteTitle' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WelcomeToLogin','欢迎登陆','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WelcomeToLogin' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WelcomeToLogin','Welcome to login','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WelcomeToLogin' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk set fieldlabel='当前登陆账号服务小程序下载' WHERE labelbol='CUSTOMERSELFSERVICECONFIGHOME06' and languagetype='zh';
delimiter;
UPDATE ld_desk set fieldlabel='Download the current login account service mini program' WHERE labelbol='CUSTOMERSELFSERVICECONFIGHOME06' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='{$Contacts.Contacts}图谱' where labelbol='ContactsMap' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='{$Contacts.Contacts} Map' where labelbol='ContactsMap' and languagetype='en' and Labeltype='fixedstr';
delimiter;

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @modulename='PaymentPlan';
SET @tabid=(SELECT tabid FROM ld_tab WHERE name=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='projectid';
SET @fieldname='projectid';
SET @zh='项目名称';
SET @en='Project Name';
SET @uitype=82;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='reference';
SET @datarang='permit';
SET @maxrowsshow=5;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,7,'BAS',2,NULL,0,0,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid AND fieldlabel=@zh);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid AND fieldlabel=@en);

CALL AddColumn(@tablename,@columnname,'int','19','');
delimiter;

SET @module='Project';
SET @rel_module='PaymentPlan';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module);
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`=@rel_module);
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @relation_id+1,@tabid,@rel_tabid,CONCAT('get_',LOWER(@rel_module)),@seq+1,@rel_module,0,'add','datacategory_sql','paymentplan.projectid' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

update ld_desk set fieldlabel = '在所有[module]中进行查重，最多只显示符合条件的前{Var}条数据。' where languagetype = 'zh' and labelbol = 'NOTECHECKMODULES' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'check in all of the [module], only the first {Var} qualifying data.' where languagetype = 'en' and labelbol = 'NOTECHECKMODULES' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DUPLICATETIPS2','根据客户名称查重时，','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DUPLICATETIPS2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DUPLICATETIPS2','When searching for duplicates based on customer names, ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DUPLICATETIPS2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DUPLICATETIPS3','若查重内容仅输入国家、省、市、区地址信息或信息科技、有限公司等关键词搜索时，查找不到数据。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DUPLICATETIPS3' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DUPLICATETIPS3','if only country, province, city, district address information or keywords such as information technology or limited company are entered, data cannot be found.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DUPLICATETIPS3' and Labeltype='fixedstr' and languagetype='en');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MobileContentCanNotCopy','移动端内容无法复制','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MobileContentCanNotCopy' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MobileContentCanNotCopy','Mobile Content Can Not Be Copied','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MobileContentCanNotCopy' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_print`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_default_print`(in tmp_tabid int(19) , in `tmp_operation` int(19))
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;

DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	SET @tabid=tmp_tabid;

	set @operation = tmp_operation;

OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO
		SET @profileid=tmp_profileid;
		IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid and operation = @operation and profileid = @profileid)
		THEN
			INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT
    @profileid AS profileid,
    @tabid AS tabid,
    @operation,
    0,
    0
FROM ld_profile2standardpermissions a
         LEFT JOIN ld_tab b ON b.tabid=a.tabid
WHERE a.profileid=@profileid
  AND a.operation=@operation
    LIMIT 1;
END IF;

		SET @i=0;
UPDATE ld_profile2standardpermissions SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND profileid=@profileid ORDER BY sequence;

IF NOT EXISTS (SELECT 1 FROM ld_profile2tab WHERE tabid=@tabid AND profileid=@profileid) THEN
			INSERT INTO ld_profile2tab(profileid,tabid,permissions)
SELECT profileid,@tabid,IF(MIN(permissions)=0,1,0) FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid;
END IF;

		IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid AND permissions=0) THEN
UPDATE ld_profile2standardpermissions SET permissions=1 WHERE tabid=@tabid AND profileid=@profileid AND operation=0;
END IF;

FETCH MYCUSOR INTO tmp_profileid;
END WHILE;
CLOSE MYCUSOR;
END ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_print`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_print`()
BEGIN


	DECLARE tmp_tabid int(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR (
		SELECT ld_profileallpermission.tabid from ld_profileallpermission
		INNER JOIN ld_tab on ld_tab.tabid = ld_profileallpermission.tabid
		WHERE operation = (SELECT actionid from ld_actionmapping where actionname = 'Print') );

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

SELECT actionid INTO @operation from ld_actionmapping where actionname = 'Print';
IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid > 2) THEN
	OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_tabid;
WHILE(tmp_tabid IS NOT NULL) DO
		CALL ldcrm_add_profile_for_default_print(tmp_tabid,@operation);

FETCH MYCUSOR INTO tmp_tabid;
END WHILE;
CLOSE MYCUSOR;
END IF;
END ||
delimiter;

CALL ldcrm_add_profile_for_print();
delimiter;

update ld_tranlabel SET fieldlabel = "设置移动端{$Accounts.Accounts}、{$ServiceCharge.ServiceCharge}单据详情页签上方是否显示{$Contacts.Contacts}区块"
WHERE trantable = "ld_systems_deploy"AND tabid = 461 and languagetype = 'zh';
update ld_tranlabel SET fieldlabel = "Set whether the {$Contacts.Contacts} block is displayed above the mobile {$Accounts.Accounts}、{$ServiceCharge.ServiceCharge} document details tab"
where trantable = "ld_systems_deploy" AND tabid = 461 and languagetype = 'en';
delimiter;

UPDATE ld_field SET allowhide='yes' WHERE columnname='accountid' and allowhide='no';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CallLink2ERP','调用连接ERP','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallLink2ERP' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CallLink2ERP','Call link2erp','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallLink2ERP' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Link2ERPUrl','连接ERP地址','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Link2ERPUrl' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Link2ERPUrl','Link2ERP URL','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Link2ERPUrl' and Labeltype='fixedstr' and languagetype='en');
delimiter;


INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT 'zh','Available_fields','可用字段', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'Available_fields' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT 'en','Available_fields','Available Fields', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'Available_fields' AND labeltype = 'jspop' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT 'zh','Selected_Fields','已选字段', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'Selected_Fields' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT 'en','Selected_Fields','Selected Fields', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'Selected_Fields' AND labeltype = 'jspop' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT 'zh','PleaseEnterFieldSearchFor','请输入要查找的字段', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'PleaseEnterFieldSearchFor' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT 'en','PleaseEnterFieldSearchFor','Please enter the category you are looking for', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'PleaseEnterFieldSearchFor' AND labeltype = 'jspop' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOVERIGHT','右移','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MOVERIGHT' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOVERIGHT','Move right','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MOVERIGHT' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOVELEFT','左移','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MOVELEFT' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOVELEFT','Move left','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MOVELEFT' and Labeltype='jspop' and languagetype='en');
delimiter;
-- 2023-08-30


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

update ld_field set bigtype='date' where tabid=(select tabid from ld_tab where name='SalesOrder' limit 1)
and columnname='cashbilldate' and tablename='ld_salesorder' and fieldname='cashbilldate';
delimiter;

SET @stuffid=100;
INSERT INTO ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
SELECT @stuffid,'DataDragonTigerList','DragonTigerList',''  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_stuff WHERE stuffid=@stuffid AND stufftitle='DataDragonTigerList');
delimiter;

call AddColumn('ld_homestuffdetail','topnumber','varchar',10,'');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewAccounts','fixedstr',
       'ld_account.account_no','count','新增客户数',
       'New Accounts Count','ld_account:createdtime:createdtime:Accounts_fieldlabel:DT',
       'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V','yes','Accounts','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewAccounts');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewContacts','fixedstr',
       'ld_contactdetails.contact_no','count','新增联系人数',
       'New Contacts Count','ld_contactdetails:createdtime:createdtime:Contacts_fieldlabel:DT',
       'ld_contactdetails:smownerid:assigned_user_id:Contacts_fieldlabel:V','yes','Contacts','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewContacts');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewPotentialsCount','fixedstr',
       'ld_potential.potential_no','count','新增销售机会数',
       'New Potentials Count','ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT',
       'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V','yes','Potentials','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewPotentialsCount');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewCalendarCount','fixedstr',
       'ld_activity.subject','count','新增日程管理数',
       'New Calendar Count','ld_activity:createdtime:createdtime:Calendar_fieldlabel:DT',
       'ld_activity:smownerid:assigned_user_id:Calendar_fieldlabel:V','yes','Calendar','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewCalendarCount');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewContactRecordsCount','fixedstr',
       'ld_contactrecords.contactrecord_no','count','新增跟进记录数',
       'New ContactRecords Count','ld_contactrecords:contactdate:contactdate:ContactRecords_fieldlabel:DT',
       'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_fieldlabel:V','yes','ContactRecords','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewContactRecordsCount');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewHelpDeskCount','fixedstr',
       'ld_troubletickets.ticket_no','count','新增客户服务单数',
       'New HelpDesk Count','ld_troubletickets:createdtime:createdtime:HelpDesk_fieldlabel:DT',
       'ld_troubletickets:smownerid:assigned_user_id:HelpDesk_fieldlabel:V','yes','HelpDesk','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewHelpDeskCount');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewLeadUgradeToCustomerCount','fixedstr',
       'ld_account.account_no','count','线索升级到客户管理数',
       'Lead Ugrade To Customer Count','ld_account:createdtime:createdtime:Accounts_fieldlabel:DT',
       'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V','yes','Accounts','[null,{"groupid":"1","columnname":"ld_account:kis_no:kis_no:Accounts_fieldlabel:V","comparator":"c","value":"from_leads","columncondition":""}]','[null,{"groupcondition":""}]',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewLeadUgradeToCustomerCount');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewSalesOrderAmount','fixedstr',
       'ld_salesorder.total','sum','新增销售订单额',
       'New SalesOrder Amount','ld_salesorder:createdtime:createdtime:SalesOrder_fieldlabel:DT',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewSalesOrderAmount');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewServiceContractsAmount','fixedstr',
       'ld_servicecontracts.total','sum','新增服务合同额',
       'New ServiceContracts Amount','ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_fieldlabel:DT',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewServiceContractsAmount');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewSignContractAmount','fixedstr',
       'ld_salesorder.total','sum','新增签约额',
       'New SignContract Amount','ld_salesorder:createdtime:createdtime:SalesOrder_fieldlabel:DT',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewSignContractAmount' and compute_module='SalesOrder');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewSignContractAmount','fixedstr',
       'ld_servicecontracts.total','sum','新增签约额',
       'New SignContract Amount','ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_fieldlabel:DT',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewSignContractAmount' and compute_module='ServiceContracts');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewCommissionsAmount','fixedstr',
       'ld_commission.total','sum','新增佣金单额',
       'New Commissions Amount','ld_commission:createdtime:createdtime:Commission_fieldlabel:DT',
       'ld_commission:smcreatorid:smcreatorid:Commission_fieldlabel:V','yes','Commission','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewCommissionsAmount');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DataDragonTigerList','数据龙虎榜','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DataDragonTigerList' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DataDragonTigerList','Data Dragon Tiger List','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DataDragonTigerList' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANCELDRAGONTIGERLIST','该数据龙虎榜没有保存，退出将丢失未保存的信息，确定要退出吗？','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CANCELDRAGONTIGERLIST' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANCELDRAGONTIGERLIST','The Data DragonTiger List has not been saved. Exiting will lose any unsaved information. Are you sure you want to exit?','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CANCELDRAGONTIGERLIST' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANCELDRAGONTIGERLIST','该数据龙虎榜没有保存，退出将丢失未保存的信息，确定要退出吗？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CANCELDRAGONTIGERLIST' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANCELDRAGONTIGERLIST','The Data DragonTiger List has not been saved. Exiting will lose any unsaved information. Are you sure you want to exit?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CANCELDRAGONTIGERLIST' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DRAGONTIGERLISTCUSTOMIZATION','数据龙虎榜定制','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGONTIGERLISTCUSTOMIZATION' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DRAGONTIGERLISTCUSTOMIZATION','Data DragonTiger List Customization. Exiting will lose any unsaved information. Are you sure you want to exit?','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGONTIGERLISTCUSTOMIZATION' and Labeltype='fixedstr' and languagetype='en');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INPUTTHEDRAGONTIGERNAME','搜索龙虎榜名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INPUTTHEDRAGONTIGERNAME' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INPUTTHEDRAGONTIGERNAME','Search for Dragon and Tiger List Names','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INPUTTHEDRAGONTIGERNAME' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CLICKTOCUSTOMIZESETTING','点击可自定义设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CLICKTOCUSTOMIZESETTING' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CLICKTOCUSTOMIZESETTING','Click to customize Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CLICKTOCUSTOMIZESETTING' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DRAGDRAGONTIGERTOCHANGETHEORDER','拖动龙虎榜排列位置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGDRAGONTIGERTOCHANGETHEORDER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DRAGDRAGONTIGERTOCHANGETHEORDER','Drag the dragon tiger list to change the order','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGDRAGONTIGERTOCHANGETHEORDER' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDCUSTOMDRAGONTIGER','新增自定义龙虎榜','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDCUSTOMDRAGONTIGER','Add a custom dragon and tiger list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDCUSTOMDRAGONTIGER','新增自定义龙虎榜','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDCUSTOMDRAGONTIGER','Added custom Dragon Tiger list','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHOWDRAGONTIGERLIST','显示龙虎榜排名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SHOWDRAGONTIGERLIST' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHOWDRAGONTIGERLIST','Display the ranking of the Dragon and Tiger List','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SHOWDRAGONTIGERLIST' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHOWDRAGONTIGERLIST','显示龙虎榜排名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SHOWDRAGONTIGERLIST' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHOWDRAGONTIGERLIST','Display the ranking of the Dragon and Tiger List','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SHOWDRAGONTIGERLIST' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIRSTTHREE','前3名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FIRSTTHREE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIRSTTHREE','Top3','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FIRSTTHREE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIRSTFIVE','前5名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FIRSTFIVE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIRSTFIVE','TOP5','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FIRSTFIVE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIRSTTEN','前10名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FIRSTTEN' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIRSTTEN','TOP10','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FIRSTTEN' and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @labelbol = 'FIRSTTWENTY';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'前20名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'TOP50','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @labelbol = 'FIRSTFIFTY';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'前50名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'TOP50','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @labelbol = 'RANKINGDESC';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'排名从高到低','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'Ranking from high to low','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='en');
delimiter;

set @labelbol = 'RANKINGASC';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'排名从低到高','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'Ranking from low to high','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE   PROCEDURE `account_singlerecycle_normal_rule`(new_normal_id 	int(11),
	new_pool_id 	int(11))
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

end ||
delimiter;
-- 2023-08-31

set @field = (select f.fieldid from ld_tab t LEFT JOIN ld_field f on t.tabid = f.tabid where t.`name` = 'Leads' and f.columnname = 'upgradeaccountid');
UPDATE ld_tranlabel set fieldlabel = '升级后客户名称' where NOT EXISTS (SELECT 1 FROM ld_leads) and Relateid = @field and trantable = 'ld_field' and languagetype = 'zh';
UPDATE ld_tranlabel set fieldlabel = 'Customer name after upgrade' where NOT EXISTS (SELECT 1 FROM ld_leads) and Relateid = @field and trantable = 'ld_field' and languagetype = 'en';
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

UPDATE ld_version SET old_version='V8.6.0.5',current_version='V8.6.0.5',remark='V8.6.0.5-20230901',wx_version='V8.6.0.5';
delimiter;