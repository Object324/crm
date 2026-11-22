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
			IF tmp_columnlen<=1 THEN 
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

DROP PROCEDURE IF EXISTS `altercolumn`;
delimiter ||
CREATE PROCEDURE `altercolumn`(
  tablename VARCHAR(50),
  oldcolumnname VARCHAR(100),
  newcolumnname VARCHAR(100),
  newcolumntype VARCHAR(100)
)
BEGIN
    SELECT DATABASE() INTO @tableschema;
    SET tablename=LOWER(tablename);
    SET @colName=0;

    select length(column_name) into @colName from information_schema.columns
    where TABLE_SCHEMA= @tableschema and table_name=tablename and COLUMN_NAME=oldcolumnname;

    IF @colName>0 THEN

      SET @altersql=CONCAT(' alter table ',tablename, ' change ',oldcolumnname,' ',newcolumnname,' ',newcolumntype);

      PREPARE stalter FROM @altersql;
      EXECUTE stalter;
    END IF;

end ||
delimiter;

set @tabid = (SELECT tabid from ld_tab where name ='Leads');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid;
set @statu = (select  ifnull(`status`,'1')='0'  from ld_leads_public);

INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, -302, 'get_publicaccount', 0, 'publicaccount_log', @statu, '', @statu, 0, NULL, NULL, 0, 0, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=-302);
UPDATE ld_relatedlists_seq set id =(SELECT MAX(relation_id) FROM ld_relatedlists);
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AddNormalLeads','普通{$Leads.Leads}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddNormalLeads' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AddNormalLeads','Normal {$Leads.Leads}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddNormalLeads' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOGPUBLICALLOCATELEADS','公海已分配{$Leads.Leads}参与回收，设置的回收条件未达成，释放到公海未分配','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LOGPUBLICALLOCATELEADS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOGPUBLICALLOCATELEADS','公海已分配{$Leads.Leads}参与回收，设置的回收条件未达成，释放到公海未分配','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LOGPUBLICALLOCATELEADS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEPUBLICLEADSGIVEN','分配公海{$Leads.Leads}给%s','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOCATEPUBLICLEADSGIVEN' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEPUBLICLEADSGIVEN','Allocate high Seas {$Leads.Leads}%s','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLOCATEPUBLICLEADSGIVEN' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GETMYPUBLICLEADS','领取为自己的公海{$Leads.Leads}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GETMYPUBLICLEADS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','GETMYPUBLICLEADS','get high Seas leads for me','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GETMYPUBLICLEADS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELAYPUBLICLEADSDAYS','将公海{$Leads.Leads}回收日期延期%s天','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DELAYPUBLICLEADSDAYS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELAYPUBLICLEADSDAYS','Delay high Seas %s days','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DELAYPUBLICLEADSDAYS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOBETHEHIGHSEALEADS','将{$Leads.Leads}转为公海线索','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TOBETHEHIGHSEALEADS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOBETHEHIGHSEALEADS','transfer leads to be the high Seas customers','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TOBETHEHIGHSEALEADS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TORELEASETHELEADSTOTHEHIGNSEAS','将{$Leads.Leads}释放到公海未分配','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TORELEASETHELEADSTOTHEHIGNSEAS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TORELEASETHELEADSTOTHEHIGNSEAS','To release the customer to the unassigned not allocated','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TORELEASETHELEADSTOTHEHIGNSEAS' and labeltype='fixedstr');
delimiter;

update ld_logpublicleads set operation=replace(operation,'GETMYPUBLICACCOUNT','GETMYPUBLICLEADS') 
where operation like '%GETMYPUBLICACCOUNT%';
delimiter;
update ld_logpublicleads set operation=replace(operation,'DELAYPUBLICACCOUNTDAYS','DELAYPUBLICLEADSDAYS') 
where operation like '%DELAYPUBLICACCOUNTDAYS%';
delimiter;

update ld_logpublicleads set operation=replace(operation,'TOBETHEHIGHSEASCUSTOMTERS','TOBETHEHIGHSEASLEADS') 
where operation like '%TOBETHEHIGHSEASCUSTOMTERS%';
delimiter;

update ld_logpublicleads set operation=replace(operation,'TOBETHEHIGHSEASCLEADS','TOBETHEHIGHSEASLEADS') 
where operation like '%TOBETHEHIGHSEASCLEADS%';
delimiter;

update ld_logpublicleads set operation='LOGPUBLICALLOCATELEADS'
where operation = 'LOGPUBLICALLOCATE';
delimiter;
-- 2021-06-02

UPDATE ld_producttoolfield SET savedatabase='yes' WHERE edit_permission=3;


CALL AddColumn('ld_option_module', 'uploadwatermark', 'varchar', '20', 'yes');
delimiter;

CALL altercolumn('ld_attachmentsforsign','cloud_path','cloud_path','text');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UploadWatermark','拜访签到上传图片添加水印','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'UploadWatermark' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UploadWatermark',"Outside SignSet upload picture add watermark",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'UploadWatermark' and labeltype = 'fixedstr');
delimiter;

SET @modulename='Leads';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @maxseq=(select sequence from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_leads';
SET @columnname='completed';
SET @fieldname='completed';
SET @zh='公海目标';
SET @en='completed';
SET @uitype=203;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @relateid and sequence >= @maxseq;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid = @tabid and block = @relateid order by sequence;
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;

call getallprofile("Leads");
delimiter;

SET @modulename='Emails';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @maxseq=(select sequence from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_emaildetails';
SET @columnname='subject';
SET @fieldname='subject';
SET @zh='主题';
SET @en='Subject';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @relateid and sequence >= @maxseq;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid = @tabid and block = @relateid order by sequence;
delimiter;
update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;
call getallprofile("Leads");
delimiter;


update ld_field set fieldonly=1 where tabid in(select tabid from ld_tab where name='users') and columnname='user_name';
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
  select beforereminddays into @var_beforereminddays from ld_leads_set;



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
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid ');
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
							from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',var_tablename,'.leadsid and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

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
    		   else
    				set	var_smownercolumn='smownerid' ;
    			end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
    		   end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid' );
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
    		   else
    				set	var_smownercolumn='smownerid' ;
    			end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from ld_leads ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid' );
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
    					from ld_leads inner join ',var_tablename,' on ld_leads.leadsid=',var_tablename,'.leads_id
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
    				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.leadsid=ld_leads.leadsid  ');
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
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(leadsname separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_leads.leadsname separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
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
    				set @TMPSQL_ONE=concat( ' update  ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid set ld_leads.publicleads=1,ld_leads.pool_id=',@leads_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
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
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid ');
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
							from ld_leads inner join ',var_tablename,' on ld_leads.leadsid=',var_tablename,'.leads_id
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
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid  ');

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

update ld_field set displaytype = 2 where tabid = 6 and columnname in ('completed');
delimiter;

UPDATE ld_field SET allowhide='yes' WHERE tabid=21 AND columnname IN ('vendorid','contactid');
-- 2021-06-04

SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=21 AND columnname='source_list' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=21 AND columnname='contactid' LIMIT 1);
DELETE FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfieldformula`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_relatedlistsinfo`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_relid INT(19) DEFAULT 0;
	DECLARE tmp_fangfa VARCHAR(100) DEFAULT '';

	DECLARE tmp_minid INT(19) DEFAULT 0;
	DECLARE tmp_isshow INT(1) DEFAULT 0;

	
	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				IFNULL(a.tabid,0) AS tabid,
				a.related_tabid,
				IFNULL(a.related_coltable,'') AS related_coltable,
				(SELECT MIN(relation_id) FROM ld_relatedlists WHERE IFNULL(tabid,0)=IFNULL(a.tabid,0) AND related_tabid=a.related_tabid AND IFNULL(related_coltable,'')=IFNULL(a.related_coltable,'')) AS minid,
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_relatedlists WHERE IFNULL(tabid,0)=IFNULL(a.tabid,0) AND related_tabid=a.related_tabid AND IFNULL(related_coltable,'')=IFNULL(a.related_coltable,'') AND presence=0) THEN 0
					ELSE 1
				END AS is_show
			FROM ld_relatedlists a
			WHERE a.related_tabid NOT IN (-1,0)
			GROUP BY a.tabid,a.related_tabid,a.label,related_coltable
			HAVING COUNT(a.relation_id)>1;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_relid,tmp_fangfa,tmp_minid,tmp_isshow;
	WHILE(tmp_tabid IS NOT NULL) DO
		DELETE  FROM ld_relatedlists WHERE IFNULL(tabid,0)=tmp_tabid AND related_tabid=tmp_relid AND IFNULL(related_coltable,'')=tmp_fangfa AND relation_id>tmp_minid;
		IF tmp_isshow=0 THEN
			UPDATE ld_relatedlists SET presence=0 WHERE IFNULL(tabid,0)=tmp_tabid AND related_tabid=tmp_relid AND relation_id=tmp_minid;
		ELSE
			UPDATE ld_relatedlists SET presence=1 WHERE IFNULL(tabid,0)=tmp_tabid AND related_tabid=tmp_relid AND relation_id=tmp_minid;
		END IF;
		FETCH MYCUSOR INTO tmp_tabid,tmp_relid,tmp_fangfa,tmp_minid,tmp_isshow;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_relatedlistsinfo();
DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedlistsinfo`;

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

UPDATE ld_version SET old_version='V8.4.2.8',current_version='V8.4.2.8',remark='V8.4.2.8-20210604',wx_version='V8.4.2.8';
delimiter;