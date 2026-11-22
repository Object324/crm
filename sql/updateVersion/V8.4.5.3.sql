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


select max(sequence)+1 into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 'thismonth',345,'设置首页默认时间筛选条件',@sequence,'','select',0,''
from dual where not exists(select 1 from ld_systems_deploy  where deploy_type=345);


insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',345,345,'设置首页默认时间筛选条件' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=345 and relateid=345 and trantable='ld_systems_deploy' and languagetype='zh');

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',345,345,'Set default time filter criteria for homepagee' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=345 and relateid=345 and trantable='ld_systems_deploy' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Setquerytimedefault','设置查询时间默认值','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Setquerytimedefault' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Setquerytimedefault','Set query time default','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Setquerytimedefault' and labeltype='fixedstr');
delimiter;


SET @actionid = (select max(actionid) from ld_actionmapping)+1;
INSERT into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT @actionid,'Receive',0,'RECEIVE' from dual 
where not EXISTS (SELECT 1 from ld_actionmapping where actionname = 'Receive');

DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_WorkSheet`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addnewmoudule_WorkSheet`(
	tmp_modulename VARCHAR(100),
	tmp_zhmoudulename VARCHAR(100),
	tmp_enmoudulename VARCHAR(100),
	tmp_parenttabid INT(19),
	tmp_deploy_type INT(19)
)
BEGIN

		SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @tabsequence=(select tabsequence from ld_tab where name="HelpDesk");
    update ld_tab set tabsequence=tabsequence+1  where tabsequence>@tabsequence;
		INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
		SELECT @maxtabid+1,tmp_modulename,0,@tabsequence+1,tmp_modulename,1,'DOCUMENTENTRY' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename);
		
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tab',@tabid,@tabid,tmp_zhmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tab',@tabid,@tabid,tmp_enmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');
		
		SET @labseq=IFNULL((SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid),0);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT tmp_parenttabid,@tabid,@labseq+1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid AND tabid=@tabid);
		
		SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
		INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
		SELECT @maxnum_id+1,tmp_modulename,'CS',1,1,1,'none',0,0,0 FROM DUAL
		WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=tmp_modulename);
		UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;
		
		INSERT INTO ld_modtracker_tabs(tabid,visible)
		SELECT @tabid,1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);
		
		SET @i=0;
		INSERT INTO ld_profileallpermission(tabid,operation,sequence)
		SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
		WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
			('index','Detailview','Create','Receive','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView','Advance','DownLoad','Preview','DownloadSelected','FileReadHistory');

		INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
		SELECT @tabid,tmp_modulename,CONCAT('ld_',LOWER(tmp_modulename)),CONCAT(LOWER(tmp_modulename),'_no'),CONCAT(LOWER(tmp_modulename),'id'),CONCAT(LOWER(tmp_modulename),'id') FROM DUAl
		WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename=tmp_modulename);
		
		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
		UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
		
		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'worksheet_name','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,2,'worksheet_name','工单名称',0,2,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,1,'text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='worksheet_name');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='worksheet_name');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'工单名称' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Customer Service Name' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


	  SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,CONCAT(LOWER(tmp_modulename),'_no'),'yes',CONCAT('ld_',LOWER(tmp_modulename)),1,4,CONCAT(LOWER(tmp_modulename),'_no'),'工单编号',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,0,0,2,NULL,NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'工单编号' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Customer Service NO.' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
	
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'worksheet_type','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,15,'worksheet_type','工单类型',1,0,(@i:=@i+2),@blockid ,1,'V~M',1,0,0,1,'picklist',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='worksheet_type');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='worksheet_type');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'工单类型' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Customer Service Type' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'accountid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,73,'account_id','客户名称',0,2,@i-1,@blockid ,1,'V~M',1,0,1,0,'reference',NULL,5 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='accountid');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='accountid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'客户名称' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Account Name' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'contactid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,57,'contact_id','联系人姓名',1,2,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,0,'reference',NULL,5 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='contactid');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='contactid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'联系人姓名' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Contact Name' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'address','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,2,'address','地址',0,1,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,1,'text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='address');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='address');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'地址' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Address' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'repair_source','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,15,'repair_source','报修来源',1,0,(@i:=@i+1),@blockid ,1,'V~O',1,0,0,1,'picklist',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='repair_source');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='repair_source');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'报修来源' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Repair Source' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
    SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'hope_deal_date','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,5,'hope_deal_date','希望处理日期',0,1,(@i:=@i+1),@blockid ,1,'D~O',1,0,1,1,'date',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='hope_deal_date');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='hope_deal_date');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'希望处理日期' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Hope to process date' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
    SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'warranty_expiration_date','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,5,'warranty_expiration_date','保修截止日期',0,1,(@i:=@i+1),@blockid ,1,'D~O',1,0,1,1,'date',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='warranty_expiration_date');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='warranty_expiration_date');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'保修截止日期' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Warranty expiration date' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
    SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'service_expiration_date','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,5,'service_expiration_date','服务到期日',0,1,(@i:=@i+1),@blockid ,1,'D~O',1,0,1,1,'date',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='service_expiration_date');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='service_expiration_date');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'服务到期日' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Service expiration date' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'source_list','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,202,'selectlistval','选择源单',0,2,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,1,'selectsource',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'选择源单' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Select Sourcemodule' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'smcreatorid','创建人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'modifiedby','最新更新人',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'modifiedtime','更新时间',1,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'urgedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'urgedtime','领取时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='urgedtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='urgedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'催单时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Urged Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'endedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'endedtime','结单时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='endedtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='endedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'结单时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Ended Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,609,'approvestatus','审批状态',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,NULL,NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'approvetime','最新审批时间',1,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,131,'approveby','上一步审批人',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,132,'currentapprover','当前审批人',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'当前审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Current Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'print_times','打印次数',1,1,(@i:=@i+1),@blockid ,2,'N~O',1,0,1,2,'text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='print_times');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'打印次数' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Print Times' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
		
		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(tmp_modulename),'_PROCESSINGSTATUS'),1,0,0,0,0,0,1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_PROCESSINGSTATUS') AND tabid=@tabid);

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_PROCESSINGSTATUS') AND tabid=@tabid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,'处理状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,'Processing status' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
		UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
		
		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'worksheet_status','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'worksheet_status','工单状态',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,0,1,'translatefield',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='worksheet_status');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='worksheet_status');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'工单状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Customer Service Situation' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'receivedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'receivedtime','领取时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='receivedtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='receivedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新分配时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Received Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','服务人员',1,0,(@i:=@i+1),@blockid ,2,'V~M',1,1,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'服务人员' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Service Personal' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'total','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnGrandTotal','合计',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='total');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='total');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'合计' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Total' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'subtotal','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnSubTotal','小计',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='subtotal');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='subtotal');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'小计' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Subtotal' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'discount_amount','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnDiscountAmount','折扣直接降价',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='discount_amount');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='discount_amount');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'折扣直接降价' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Discount Amount' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'currency_id','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,117,'currency_id','币种',1,0,(@i:=@i+1),@blockid ,3,'V~M',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'币种' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Currency' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'conversion_rate','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'conversion_rate','汇率',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='conversion_rate');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='conversion_rate');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'汇率' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Conversion Rate' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
		
		SET @i=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
		SET @j=0;
		INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield)
		SELECT (@i:=@i+1),columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,(@j:=@j+1),@tabid,
			CASE
				WHEN tablename='ld_products' THEN 'ld_products'
				WHEN tablename='ld_servicecontractsdetail' THEN CONCAT('ld_',LOWER(tmp_modulename),'detail')
				WHEN tablename='ld_servicecontracts' THEN CONCAT('ld_',LOWER(tmp_modulename))
			END AS tablename,width,edit_permission,input_type,
		CASE
			WHEN tablename='ld_products' OR columnname IN ('listprice','taxprice','productcost') THEN fieldid
			WHEN columnname IN ('tax1','tax2','tax3') THEN (SELECT taxid FROM ld_inventorytaxinfo WHERE taxname=ld_producttoolfield.columnname)
			WHEN columnname IN ('discount_amount','adjustment','subtotal','total') THEN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=ld_producttoolfield.columnname)
			ELSE 0
		END AS fieldid,newline,defaultcolumn,is_checkimportfield,nullfield
		FROM ld_producttoolfield 
		WHERE tabid=37 and tablename <> 'ld_servicecontractsdetailscf'
			AND NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid)
		ORDER BY IFNULL(sequence,1000);

		DELETE FROM ld_producttoolfield_formula WHERE producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid);
		INSERT INTO ld_producttoolfield_formula(producttoolfieldid,formulastring,columnstring,sequence)
		SELECT  
			c.producttoolfieldid,
			a.formulastring,
			a.columnstring,
			a.sequence
		FROM ld_producttoolfield_formula a
		LEFT JOIN ld_producttoolfield b ON a.producttoolfieldid=b.producttoolfieldid
		LEFT JOIN ld_producttoolfield c ON c.columnname=b.columnname AND c.tabid=@tabid
		WHERE b.tabid=37
		ORDER BY a.sequence;

		DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_producttoolfield';
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT
		b.languagetype,
		b.trantable,
		@tabid,
		c.producttoolfieldid,
		b.fieldlabel
		FROM ld_producttoolfield a
		LEFT JOIN ld_tranlabel b ON b.Relateid=a.producttoolfieldid AND b.trantable='ld_producttoolfield'
		LEFT JOIN ld_producttoolfield c ON c.columnname=a.columnname AND c.tabid=@tabid
		WHERE a.tabid=37
		ORDER BY a.producttoolfieldid;

		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);
		
		SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+2,'小程序报修',0,0,tmp_modulename,3,1,2 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='小程序报修');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+3,'面访报修',0,0,tmp_modulename,3,1,3 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='面访报修');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+4,'今日内创建',0,0,tmp_modulename,3,1,4 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='今日内创建');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+5,'三天内创建',0,0,tmp_modulename,3,1,5 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='三天内创建');

		UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);

		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':',LOWER(tmp_modulename),'_no',':',LOWER(tmp_modulename),'_no',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,1,CONCAT('ld_',LOWER(tmp_modulename),':','accountid:account_id:WorkSheet_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,2,CONCAT('ld_',LOWER(tmp_modulename),':','contactid:contact_id:WorkSheet_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,3,CONCAT('ld_',LOWER(tmp_modulename),':','smownerid:assigned_user_id:WorkSheet_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,4,CONCAT('ld_',LOWER(tmp_modulename),':','worksheet_status:worksheet_status:WorkSheet_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,5,CONCAT('ld_',LOWER(tmp_modulename),':','repair_source:repair_source:WorkSheet_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,6,CONCAT('ld_',LOWER(tmp_modulename),':','worksheet_type:worksheet_type:WorkSheet_fieldlabel:V');
		

		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='小程序报修');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,'ld_worksheet:repair_source:repair_source:WorkSheet_fieldlabel:V','e','小程序报修',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='面访报修');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,'ld_worksheet:repair_source:repair_source:WorkSheet_fieldlabel:V','e','面访报修',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='今日内创建');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,'ld_worksheet:createdtime:createdtime:WorkSheet_fieldlabel:DT','today','2021-11-22 00:00:00,2021-11-22 37:59:59',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='三天内创建');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,'ld_worksheet:createdtime:createdtime:WorkSheet_fieldlabel:DT','last3days','2021-11-19 00:00:00,2021-11-21 37:59:59',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		DELETE FROM ld_relatedlists WHERE tabid=@tabid;
		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-1','get_SharedUsers',(@i:=@i+1),'SharedUsers',0,'share','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-1' AND `name`='get_SharedUsers');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-7','get_viewhistory',(@i:=@i+1),'ViewHistory',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-7' AND `name`='get_viewhistory');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-10','get_changeview',(@i:=@i+1),'ChangeView',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-10' AND `name`='get_changeview');

		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
		

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 0,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=0);
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 1,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=1);
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 2,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=2);
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 3,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=3);

		INSERT INTO ld_def_org_share(tabid,permission,editstatus)
		SELECT @tabid,3,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);
		
		CALL addtabintoprofile(tmp_modulename,1);


		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 0,tmp_deploy_type,CONCAT(tmp_zhmoudulename,'是否启用审批流程'),tmp_modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=tmp_deploy_type);

		SET @approvename=CONCAT(tmp_zhmoudulename,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(tmp_zhmoudulename,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

		SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+2,@approveid,'二级审批',1,1,2,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+3,@approveid,'三级审批',1,1,3,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

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

SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  `",LOWER(tmp_modulename),"_no` VARCHAR(255) DEFAULT NULL,
  `worksheet_name` VARCHAR(500) DEFAULT '',
  `worksheet_type` VARCHAR(50) DEFAULT '',
  `worksheet_status` VARCHAR(50) DEFAULT '',
  `accountid` int(19) DEFAULT NULL,
  `contactid` int(19) DEFAULT NULL,
  `address` VARCHAR(500) DEFAULT '',
  `repair_source` VARCHAR(50) DEFAULT '',
  `hope_deal_date` DATE DEFAULT NULL,
  `warranty_expiration_date` DATE DEFAULT NULL,
  `service_expiration_date` DATE DEFAULT NULL,
	`source_list` varchar(500) DEFAULT NULL,
	`entitytype` varchar(500) DEFAULT NULL,
	`receivedtime` DATETIME DEFAULT NULL,
	`endedtime` DATETIME DEFAULT NULL,
	`urgedtime` DATETIME DEFAULT NULL,

	`smownerid` INT(19) DEFAULT NULL,
  `smcreatorid` INT(19) DEFAULT NULL,
  `createdtime` DATETIME DEFAULT NULL,
  `modifiedby` INT(19) DEFAULT NULL,
  `modifiedtime` DATETIME DEFAULT NULL,
  `approvestatus` VARCHAR(50) DEFAULT '未提交',
  `approvetime` DATETIME DEFAULT NULL,
  `approveby` INT(19) DEFAULT NULL,
  `currentapprover` TEXT DEFAULT NULL,
  `print_times` INT(11) DEFAULT '0',
  `total` DECIMAL(25,6) DEFAULT NULL,
  `subtotal` DECIMAL(25,6) DEFAULT NULL,
  `adjustment` DECIMAL(25,6) DEFAULT NULL,
  `discount_type` INT(1) DEFAULT 0,
  `discount_percent` DECIMAL(25,3) NOT NULL DEFAULT '0.000',
  `discount_amount` DECIMAL(25,6) DEFAULT NULL,
  `s_h_amount` DECIMAL(25,3) DEFAULT NULL,
  `currency_id` INT(19) DEFAULT '1',
  `conversion_rate` DECIMAL(25,6) DEFAULT NULL,
  `currency_symbol` VARCHAR(30) DEFAULT NULL,
  `deleted` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	
	SET @querysql2=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detail` LIKE ld_servicecontractsdetail");
		
SET @querysql3=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detailscf` (
  `lineitem_id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		

		PREPARE stmt FROM @querysql;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql1;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql2;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql3;
		EXECUTE stmt;
		DROP PREPARE stmt;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addWorkSheet`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addWorkSheet`(
)
BEGIN
   SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Service');
   CALL ldcrm_addnewmoudule_WorkSheet('WorkSheet','工单管理','Customer Service',@myparenttabid,345);
end ||
delimiter;

CALL ldcrm_addWorkSheet();
DROP PROCEDURE IF EXISTS `ldcrm_addWorkSheet`;
DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_WorkSheet`;
delimiter;


SET @listname = 'worksheet_type';
INSERT INTO ld_picklist_set(listname,relatetable)
SELECT @listname,'ld_field' from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_set WHERE listname=@listname);

SET @listid = (SELECT listid FROM ld_picklist_set WHERE listname=@listname);
SET @sequence = 0;
SET @listvalue = '保内收费';
INSERT into ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvalue,@sequence:=@sequence+1 from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_values WHERE listvalue=@listvalue and listid=@listid);

SET @listvalue = '保外收费';
INSERT into ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvalue,@sequence:=@sequence+1 from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_values WHERE listvalue=@listvalue and listid=@listid);

SET @listvalue = '保内免费';
INSERT into ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvalue,@sequence:=@sequence+1 from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_values WHERE listvalue=@listvalue and listid=@listid);

SET @listvalue = '保外免费';
INSERT into ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvalue,@sequence:=@sequence+1 from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_values WHERE listvalue=@listvalue and listid=@listid);
delimiter;

SET @listname = 'repair_source';
INSERT INTO ld_picklist_set(listname,relatetable)
SELECT @listname,'ld_field' from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_set WHERE listname=@listname);

SET @listid = (SELECT listid FROM ld_picklist_set WHERE listname=@listname);
SET @sequence = 0;
SET @listvalue = '小程序报修';
INSERT into ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvalue,@sequence:=@sequence+1 from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_values WHERE listvalue=@listvalue and listid=@listid);

SET @listvalue = '网上保修';
INSERT into ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvalue,@sequence:=@sequence+1 from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_values WHERE listvalue=@listvalue and listid=@listid);

SET @listvalue = '电话报修';
INSERT into ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvalue,@sequence:=@sequence+1 from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_values WHERE listvalue=@listvalue and listid=@listid);

SET @listvalue = '面访报修';
INSERT into ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvalue,@sequence:=@sequence+1 from DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_values WHERE listvalue=@listvalue and listid=@listid);
delimiter;


SET @work_tabid = (select tabid from ld_tab where name = 'WorkSheet');
SET @sale_tabid = (select tabid from ld_tab where name = 'SalesOrder');
SET @service_tabid = (select tabid from ld_tab where name = 'ServiceContracts');
INSERT into ld_option_module(tabid,option_tabid,sequence,datarang,maxrowsshow,withdetail)
SELECT @work_tabid,@sale_tabid,1,'all',5,'yes' from dual 
where not EXISTS(SELECT 1 from ld_option_module where tabid = @work_tabid and option_tabid = @sale_tabid);

INSERT into ld_option_module(tabid,option_tabid,sequence,datarang,maxrowsshow,withdetail)
SELECT @work_tabid,@service_tabid,1,'all',5,'yes' from dual 
where not EXISTS(SELECT 1 from ld_option_module where tabid = @work_tabid and option_tabid = @service_tabid); 
delimiter;


SET @work_tabid = (select tabid from ld_tab where name = 'WorkSheet');
SET @Outbound_tabid = (select tabid from ld_tab where name = 'OutboundOrder');
INSERT into ld_option_module(tabid,option_tabid,sequence,datarang,maxrowsshow,withdetail)
SELECT @Outbound_tabid,@work_tabid,1,'all',5,'yes' from dual 
where not EXISTS(SELECT 1 from ld_option_module where tabid = @Outbound_tabid and option_tabid = @work_tabid);
delimiter;


set @tabid = (SELECT tabid from ld_tab where name = 'WorkSheet');
set @accontid_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'accountid');
set @contactid_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'contactid');

insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT 'main',@accontid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql',
			'select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by reference desc,ld_contactdetails.contactid desc limit 1' 
from DUAL where NOT EXISTS (SELECT 1 FROM ld_related_field where trigger_fieldid =@accontid_fieldid and effect_fieldid = @contactid_fieldid);

insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT 'main',@contactid_fieldid,@accontid_fieldid,'account_id,accounts_name','sql',
			'select {hrefcolumn},ld_account.accountid from ld_account LEFT JOIN ld_accountscf on ld_account.accountid=ld_accountscf.accountid  inner JOIN ld_contactdetails on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.contactid = ? and ld_account.deleted = 0 order by ld_account.accountid  desc limit 1' 
from DUAL where NOT EXISTS (SELECT 1 FROM ld_related_field where trigger_fieldid =@contactid_fieldid and effect_fieldid = @accontid_fieldid);
delimiter;

SET @sourse_list_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'source_list');
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT 'main',@sourse_list_fieldid,@accontid_fieldid,'','column','accountid'
from DUAL where NOT EXISTS (SELECT 1 FROM ld_related_field where trigger_fieldid =@sourse_list_fieldid and effect_fieldid = @accontid_fieldid);

SET @sourse_list_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'source_list');
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT 'main',@sourse_list_fieldid,@contactid_fieldid,'','column','contactid'
from DUAL where NOT EXISTS (SELECT 1 FROM ld_related_field where trigger_fieldid =@sourse_list_fieldid and effect_fieldid = @contactid_fieldid);


SET @modulename ='WorkSheet';
SET @tabid=(SELECT tabid from ld_tab where name = @modulename);
SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
SET @blockname = 'LBL_PROBLEMDESCRIPTION';

SET @sequence = (SELECT max(sequence) from ld_blocks where tabid=@tabid);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,@blockname,@sequence+1,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);

SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'问题描述' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Problem description' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);

SET @relateid=@blockid;
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='description'; 
SET @fieldname='description'; 
SET @zh='问题描述'; 
SET @en='Problem description'; 
SET @uitype=19; 
SET @typeofdata='V~M';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='longtextarea';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'YES';
SET @allowedit = 'YES';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALL AddColumn(@tablename,@columnname,'varchar','50','');
delimiter;

CALL AddColumn('ld_worksheetdetail','related_productid','int','19','');
delimiter;


SET @modulename ='WorkSheet';
SET @tabid=(SELECT tabid from ld_tab where name = @modulename);
SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
SET @blockname = 'LBL_PROBLEMSOLUTION';

SET @sequence = (SELECT max(sequence) from ld_blocks where tabid=@tabid);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,@blockname,@sequence+1,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);

SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'解决方案' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Solution' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);

SET @relateid=@blockid;
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='solution'; 
SET @fieldname='solution'; 
SET @zh='解决方案'; 
SET @en='Solution'; 
SET @uitype=19; 
SET @typeofdata='V~M';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='longtextarea';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'YES';
SET @allowedit = 'YES';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALL AddColumn(@tablename,@columnname,'varchar','50','');
delimiter;


SET @modulename ='WorkSheet';
SET @tabid=(SELECT tabid from ld_tab where name = @modulename);
SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
SET @blockname = 'LBL_FILE_INFORMATION';

SET @sequence = (SELECT max(sequence) from ld_blocks where tabid=@tabid);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,@blockname,@sequence+1,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);

SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'附件信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Attachments Information' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);

SET @relateid=@blockid;
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='filename'; 
SET @fieldname='filename'; 
SET @zh='附件'; 
SET @en='Attachments'; 
SET @uitype=1109; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='fileattachment';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'YES';
SET @allowedit = 'YES';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);


SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @columnname = 'worksheet_status';
SET @module = 'WorkSheet';

SET @Dbvalue = 'new';
SET @labelbol = 'NEW';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);

SET @Dbvalue = 'tobeallocated';
SET @labelbol = 'TOBEALLOCATED';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);

SET @Dbvalue = 'urged';
SET @labelbol = 'BEURGED';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);

SET @Dbvalue = 'inprocess';
SET @labelbol = 'INPROCESS';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);

SET @Dbvalue = 'closed';
SET @labelbol = 'CLOSEDBILL';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);
delimiter;


set @presence = 0;
set @related_tabid = -16;
select tabid into @tabid from ld_tab where `name`='WorkSheet';
select max(relation_id) into @relation_id from ld_relatedlists;
select max(sequence) into @maxsequence from ld_relatedlists where tabid=@tabid;
update ld_relatedlists_seq set id=@relation_id+1 where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid); 
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,label,presence,wx_presence,wx_sequence,sequence)
select @relation_id+1,@tabid,@related_tabid,'get_trends','trends',@presence,@presence,@maxsequence+1,@maxsequence+1 from dual 
where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid);
delimiter;

SET @related_tabid = (SELECT tabid from ld_tab where name ='WorkSheet');
SET @tabid =  (SELECT tabid from ld_tab where name ='Accounts');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, @related_tabid, 'get_worksheet', 10000, 'WorkSheet', 1, 'add', 1, 0, 'datacategory_sql', 'worksheet.accountid', 1, 10000, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid);

SET @tabid =  (SELECT tabid from ld_tab where name ='Contacts');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, @related_tabid, 'get_worksheet', 10000, 'WorkSheet', 1, 'add', 1, 0, 'datacategory_sql', 'worksheet.contactid', 1, 10000, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid);

SET @tabid =  (SELECT tabid from ld_tab where name ='SalesOrder');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, @related_tabid, 'get_worksheet', 10000, 'WorkSheet', 1, 'add', 1, 0, 'entitytype_datacategory_sql', 'tmpsourcedetail.id', 1, 10000, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid);

SET @tabid =  (SELECT tabid from ld_tab where name ='ServiceContracts');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, @related_tabid, 'get_worksheet', 10000, 'WorkSheet', 1, 'add', 1, 0, 'entitytype_datacategory_sql', 'tmpsourcedetail.id', 1, 10000, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid);
UPDATE ld_relatedlists_seq set id =(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

SET @related_tabid = (SELECT tabid from ld_tab where name ='OutboundOrder');
SET @tabid =  (SELECT tabid from ld_tab where name ='WorkSheet');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, @related_tabid, 'get_outorder', 10000, 'OutboundOrder', 0, 'add', 1, 0, 'entitytype_datacategory_sql', 'tmpsourcedetail.id', 1, 10000, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid);
UPDATE ld_relatedlists_seq set id =(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;


CREATE TABLE IF NOT EXISTS `ld_worksheetlog` ( 
    `id` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `worksheetid` int(19) NOT NULL,
    `modulename` varchar(50),
		`modifiedby` int(19),
		`modifiedtime` datetime,
		`description` varchar(50)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;


CREATE TABLE IF NOT EXISTS `ld_worksheetspecialdetail` ( 
    `id` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `worksheetid` int(19) NOT NULL,
    `productid` int(19) NOT NULL,
		`repaired` varchar(10),
		`entitytype` varchar(50),
		`entitytypeid` int(19),
		`parent_lineitem_id` int(19)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @tabid = (SELECT tabid from ld_tab where name = 'WorkSheet');
SET @maxfieldid=(SELECT MAX(producttoolfieldid) from ld_producttoolfield);
INSERT INTO ld_producttoolfield (tabid,producttoolfieldid,columnname,allowhide,tablename,uitype,fieldlabel,presence,sequence,edit_permission,typeofdata,width,defaultcolumn)
SELECT @tabid,@maxfieldid+1,'entitytypeid','yes','ld_worksheetdetail',200,'源单',0,6 ,1,'V~O~100',25,3 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='entitytypeid');

SET @fieldid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='entitytypeid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_producttoolfield',@tabid, @fieldid,'源单' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_producttoolfield' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_producttoolfield',@tabid, @fieldid,'Sourselist' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_producttoolfield' );
	
SET @maxfieldid=(SELECT MAX(producttoolfieldid) from ld_producttoolfield);
INSERT INTO ld_producttoolfield (tabid,producttoolfieldid,columnname,allowhide,tablename,uitype,fieldlabel,presence,sequence,edit_permission,typeofdata,width,defaultcolumn)
SELECT @tabid,@maxfieldid+1,'entitytype','yes','ld_worksheetdetail',204,'源单类型',0,6 ,1,'V~O~100',25,4 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='entitytype');

SET @fieldid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='entitytype');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_producttoolfield',@tabid, @fieldid,'源单类型' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_producttoolfield' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_producttoolfield',@tabid, @fieldid,'Sourselist Type' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_producttoolfield' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WorkSheet');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='advance_stage'; 
SET @fieldname='advance_stage'; 
SET @zh='推进阶段'; 
SET @en='Advance Stage'; 
SET @uitype=1; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=3;
SET @bigtype='text';
SET @datarang='';
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

call AddColumn(@tablename,@columnname,'varchar','20','');
delimiter;

CALL addtableIndex('ld_worksheet','index_status','worksheet_status');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','REPAIRPRODUCTS','报修产品','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='REPAIRPRODUCTS' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','REPAIRPRODUCTS','Repair products','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='REPAIRPRODUCTS' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','ACCESSORYINFORMATION','配件信息','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='ACCESSORYINFORMATION' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','ACCESSORYINFORMATION','Accessory information','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='ACCESSORYINFORMATION' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','REPLACEACCESSORIES','更换配件','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='REPLACEACCESSORIES' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','REPLACEACCESSORIES','Replace accessories','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='REPLACEACCESSORIES' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','WHETHERTOREPAIR','是否报修','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='WHETHERTOREPAIR' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','WHETHERTOREPAIR','Whether to repair','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='WHETHERTOREPAIR' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','ACCESSORY','配件','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='ACCESSORY' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','ACCESSORY','Accessory','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='ACCESSORY' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','RECENTUSE','近期使用','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='RECENTUSE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','RECENTUSE','Recent use','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='RECENTUSE' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','RECEIVEDORALLOCATED','被领取或分配','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='RECEIVEDORALLOCATED' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','RECEIVEDORALLOCATED',' received or allocated','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='RECEIVEDORALLOCATED' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','BATCHSUBMITLOG_INFO','共选择 %d 条记录，成功 %d 条，失败 %d 条。','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='BATCHSUBMITLOG_INFO' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','BATCHSUBMITLOG_INFO','Choosed %d records,%d successful, %d failed.','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='BATCHSUBMITLOG_INFO' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','TOBEALLOCATED','待分配','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='TOBEALLOCATED' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','TOBEALLOCATED','Tobeallocated','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='TOBEALLOCATED' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','BEURGED','已催单','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='BEURGED' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','BEURGED','Be urged','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='BEURGED' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','INPROCESS','处理中','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='INPROCESS' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','INPROCESS','In process','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='INPROCESS' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CLOSEDBILL','已结单','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='CLOSEDBILL' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CLOSEDBILL','Closed worksheet','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='CLOSEDBILL' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CLOSEBILL','结单','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='CLOSEBILL' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CLOSEBILL','Close worksheet','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='CLOSEBILL' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','WORKORDER','工单','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='WORKORDER' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','WORKORDER','Work order','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='WORKORDER' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','URGE','催单','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='URGE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','URGE','Urge','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='URGE' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SOLUTION','解决方案','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SOLUTION' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SOLUTION','Solution','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SOLUTION' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','REOPEN','重新打开','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='REOPEN' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','REOPEN','Restart','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='REOPEN' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CANOTURGED','{Var}小时内不可再次催单,上次催单时间:','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='CANOTURGED' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CANOTURGED','No further reminders are allowed within {Var} hours,the last reminder time:','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='CANOTURGED' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','URGEREMIND','已催单,请及时处理！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='URGEREMIND' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','URGEREMIND','has urged,please deal with it in time!','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='URGEREMIND' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','REOPENWORKSHEET','重新打开工单,请及时处理！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='REOPENWORKSHEET' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','REOPENWORKSHEET','has reopened the workorder,please deal with it in time!','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='REOPENWORKSHEET' and Labeltype='fixedstr');
delimiter;

SET @disable_triggers='abcdefg';
CALl AddColumn('ld_servicecontracts','triggercount','INT',19,0);
CALl AddColumn('ld_account','balance_amount','decimal','25,6','0');
CALl AddColumn('ld_shopcartdetails','relatedmodule','varchar','200','');
CALl AddColumn('ld_shopcartdetails','relatedid','int','11','');
CALl AddColumn('ld_picklist_set','picklist_allowedit','varchar','20','yes');

CALl AddColumn('ld_salesorder','order_status','varchar','200','待付款');
CALl AddColumn('ld_salesorder','wechatuserid','int','11',0);

select tabid into @tabid  from ld_tab where name='SalesOrder';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SO_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='order_status');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata,bigtype)
select @tabid,@maxfieldid+1,'order_status','yes','ld_salesorder',1,15,'order_status','微信订单状态',2,'',@maxsequence+1,@blockid,1,'V~O','picklist' from dual
where not exists(select 1 from ld_field where tabid=@tabid and columnname='order_status');
delimiter;


select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'order_status';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'微信订单状态' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'wechat order status' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


insert into ld_picklist_set(listname,relatetable,picklist_allowedit) select 'order_status','ld_field','yes' from dual
where not exists (select 1 from ld_picklist_set where listname='order_status' and relatetable='ld_field');
select listid into @listid from ld_picklist_set where listname='order_status' and relatetable='ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)select @listid,'已取消',1 from dual
where not exists (select 1 from ld_picklist_values where listid=@listid and listvalue='已取消');
insert into ld_picklist_values(listid,listvalue,sequence)select @listid,'待付款',1 from dual
where not exists (select 1 from ld_picklist_values where listid=@listid and listvalue='待付款');
insert into ld_picklist_values(listid,listvalue,sequence)select @listid,'待发货',1 from dual
where not exists (select 1 from ld_picklist_values where listid=@listid and listvalue='待发货');
insert into ld_picklist_values(listid,listvalue,sequence)select @listid,'待收货',1 from dual
where not exists (select 1 from ld_picklist_values where listid=@listid and listvalue='待收货');
insert into ld_picklist_values(listid,listvalue,sequence)select @listid,'评价',1 from dual
where not exists (select 1 from ld_picklist_values where listid=@listid and listvalue='评价');
insert into ld_picklist_values(listid,listvalue,sequence)select @listid,'售后',1 from dual
where not exists (select 1 from ld_picklist_values where listid=@listid and listvalue='售后');


call AddColumn('ld_cashbill','transaction_no','varchar','255','');
select tabid into @tabid  from ld_tab where name='CashBill';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_Cashbill_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='transaction_no');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata,bigtype)
select @tabid,@maxfieldid+1,'transaction_no','yes','ld_cashbill',1,1,'transaction_no','微信交易号',1,'',@maxsequence+1,@blockid,1,'V~O','text' from dual
where not exists(select 1 from ld_field where tabid=@tabid and columnname='transaction_no');
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'transaction_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'微信交易号' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'wechat transaction NO.' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;


SET @tabid = (SELECT tabid from ld_tab where name = 'Worksheet');
UPDATE ld_field set displaytype = 1 where tabid = @tabid and columnname = 'filename';
delimiter;

call AddColumn('ld_linkmodulecustom','authcheck','varchar','20','no');
delimiter;

update ld_linkmodulecustom set authcheck='no' where authcheck='yes';
delimiter;

call AddColumn('ld_linkmodulecustom','paramvalue','text','','');
delimiter;

update ld_field set issmownerid=0 where tabid=102 ;
update ld_field set issmownerid=1 where tabid=102 and columnname='servicecasher';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Expedit','催','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Expedit' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Expedit','Urge','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Expedit' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NOTREPEATEIN30MINUTES','30分钟内不可重复催审','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOTREPEATEIN30MINUTES' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NOTREPEATEIN30MINUTES','The review reminder cannot be repeated within 30 minutes','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOTREPEATEIN30MINUTES' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Enableexpeditingfunction','是否启用催审功能','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Enableexpeditingfunction' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Enableexpeditingfunction','Enable expediting function','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Enableexpeditingfunction' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Expediting','催审','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Expediting' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Expediting','Expediting','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Expediting' and labeltype='fixedstr');
delimiter;

SET @disable_triggers='abcdefg';
CALL AddColumn('ld_approve','enableexpediting','varchar','20','no');
ALTER TABLE `ld_approve`  ALTER COLUMN `enableexpediting` set default 'no';
update ld_approve set enableexpediting='no' where enableexpediting is null or enableexpediting = '';
delimiter;

SET @disable_triggers='abcdefg';
CALL AddColumn('ld_approvelog','expediting','varchar',20,'no');
ALTER TABLE `ld_approvelog`  ALTER COLUMN `expediting` set default 'no';
update ld_approvelog set expediting='no' where expediting is null or expediting = '';
CALL AddColumn('ld_approvelog','expeditingtime','datetime','',0);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_expediting_approve`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_expediting_approve`(
)
BEGIN

	DECLARE tmp_tablename VARCHAR(200) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR
		SELECT
			TABLE_NAME
		FROM information_schema.COLUMNS
		WHERE TABLE_SCHEMA=DATABASE()
			AND COLUMN_NAME='approveurgent'
			AND TABLE_NAME IN (SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_TYPE='BASE TABLE')
			AND TABLE_NAME NOT IN (SELECT TABLE_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND COLUMN_NAME='approveexpediting');
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tablename = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_tablename;
	WHILE(tmp_tablename IS NOT NULL) DO
		SET @disable_triggers='aaaaa';
		SET @this_sql=CONCAT('ALTER TABLE ',tmp_tablename," ADD COLUMN approveexpediting VARCHAR(10) DEFAULT 'no' AFTER approveurgent");
		PREPARE my_execsql FROM @this_sql;
		EXECUTE my_execsql;
		DROP PREPARE my_execsql;
		SET @disable_triggers=NULL;
		FETCH MYCUSOR INTO tmp_tablename;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_add_expediting_approve();
DROP PROCEDURE IF EXISTS `ldcrm_add_expediting_approve`;
delimiter;


DROP PROCEDURE IF EXISTS `reset_producttoolfield_20211201`;
delimiter ||
CREATE  PROCEDURE `reset_producttoolfield_20211201`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_servicecontracts WHERE deleted=0) THEN
		SET @tabid=37;
		IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='salesorderid') AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list') THEN
			UPDATE ld_field SET uitype=202,columnname='source_list',fieldname='selectlistval',bigtype='selectsource',fieldlabel='选择源单' WHERE tabid=@tabid AND columnname='salesorderid';
			SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
			UPDATE ld_tranlabel SET fieldlabel='选择源单' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='合同订单';

			SET @disable_triggers='abcdefg';
			CALl AddColumn('ld_servicecontracts','entitytype','VARCHAR','100','');
			CALl AddColumn('ld_servicecontracts','source_list','TEXT','100','');
			SET @disable_triggers=NULL;


			SET @option_tabid=22;
			SET @presence=0;
			SET @isdefault=1;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',20,'yes',0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);

			SET @option_tabid=20;
			SET @presence=0;
			SET @isdefault=0;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',20,'yes',0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);


			SET @tabid=37;
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytype';
			SET @zh='源单类型';
			SET @en='Entity Type';
			SET @uitype=204;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'VARCHAR','100','');



			SET @tabid=37;
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytypeid';
			SET @zh='源单';
			SET @en='Related Orders';
			SET @uitype=202;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'INT','19','');


			SET @tabid=37;
			UPDATE ld_producttoolfield SET edit_permission=1 WHERE tabid=@tabid AND columnname IN ('entitytypeid','entitytype');
			ALTER TABLE ld_servicecontractsdetail MODIFY COLUMN entitytypeid INT(19) AFTER entitytype;

			SET @i=0;
			SET @seq=(SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid AND presence<>1 AND tablename='ld_products');
			UPDATE ld_producttoolfield SET sequence=sequence+4 WHERE tabid=@tabid AND presence<>1 AND sequence>@seq;
			UPDATE ld_producttoolfield SET sequence=@seq+1 WHERE tabid=@tabid AND columnname='entitytype';
			UPDATE ld_producttoolfield SET sequence=@seq+2 WHERE tabid=@tabid AND columnname='entitytypeid';
			UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;

			UPDATE ld_relatedlists SET type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' WHERE tabid IN (20,22) AND related_tabid=37;

			SET @tabid=37;
			SET @trigger_columnname='source_list';
			SET @effect_columnname='potentialid';
			SET @mysql="SELECT
				potentialid
			FROM (
				SELECT potentialid FROM ld_quotes WHERE deleted=0 AND FIND_IN_SET(quoteid,?)
				UNION
				SELECT potentialid FROM ld_salesorder WHERE deleted=0 AND FIND_IN_SET(salesorderid,?)
			) a
			WHERE potentialid>0 LIMIT 1";
			SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
			SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
			INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
			SELECT 'main',@trigger_fieldid,@effect_fieldid,'sql',@mysql FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
				AND @trigger_fieldid>0 AND @effect_fieldid>0;
		END IF;

	END IF;


end ||
delimiter;

CALL reset_producttoolfield_20211201();
DROP PROCEDURE IF EXISTS `reset_producttoolfield_20211201`;
delimiter;

DROP PROCEDURE IF EXISTS `reset_producttoolfield_order_20211201`;
delimiter ||
CREATE  PROCEDURE `reset_producttoolfield_order_20211201`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_salesorder WHERE deleted=0) THEN
		SET @tabid=22;
		IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='quoteid') AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list') THEN
			UPDATE ld_field SET uitype=202,columnname='source_list',fieldname='selectlistval',bigtype='selectsource',fieldlabel='选择源单' WHERE tabid=@tabid AND columnname='quoteid';
			SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
			UPDATE ld_tranlabel SET fieldlabel='选择源单' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';

			SET @disable_triggers='abcdefg';
			CALl AddColumn('ld_salesorder','entitytype','VARCHAR','100','');
			CALl AddColumn('ld_salesorder','source_list','TEXT','100','');
			SET @disable_triggers=NULL;

			SET @tabid=22;
			SET @option_tabid=20;
			SET @presence=0;
			SET @isdefault=1;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',20,'yes',0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);

			SET @option_tabid=(SELECT tabid FROM ld_tab WHERE name='QuotesChange');
			SET @presence=0;
			SET @isdefault=0;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',20,'yes',0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);


			SET @tabid=22;
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytype';
			SET @zh='源单类型';
			SET @en='Entity Type';
			SET @uitype=204;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'VARCHAR','100','');



			SET @tabid=22;
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytypeid';
			SET @zh='源单';
			SET @en='Related Orders';
			SET @uitype=202;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'INT','19','');


			SET @tabid=22;
			UPDATE ld_producttoolfield SET edit_permission=1 WHERE tabid=@tabid AND columnname IN ('entitytypeid','entitytype');
			ALTER TABLE ld_salesorderdetail MODIFY COLUMN entitytypeid INT(19) AFTER entitytype;

			SET @i=0;
			SET @seq=(SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid AND presence<>1 AND tablename='ld_products');
			UPDATE ld_producttoolfield SET sequence=sequence+4 WHERE tabid=@tabid AND presence<>1 AND sequence>@seq;
			UPDATE ld_producttoolfield SET sequence=@seq+1 WHERE tabid=@tabid AND columnname='entitytype';
			UPDATE ld_producttoolfield SET sequence=@seq+2 WHERE tabid=@tabid AND columnname='entitytypeid';
			UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;

			UPDATE ld_relatedlists SET type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' WHERE tabid IN (SELECT tabid FROM ld_tab WHERE `name` IN ('Quotes','QuotesChange')) AND related_tabid=@tabid;

			SET @tabid=22;
			SET @trigger_columnname='source_list';
			SET @effect_columnname='potentialid';
			SET @mysql="SELECT
				potentialid
			FROM (
				SELECT potentialid FROM ld_quotes WHERE deleted=0 AND FIND_IN_SET(quoteid,?)
				UNION
				SELECT b.potentialid FROM ld_quoteschange a LEFT JOIN ld_quotes b ON b.quoteid=a.quoteid WHERE a.deleted=0 AND b.deleted=0 AND FIND_IN_SET(a.quoteschangeid,?)
			) a
			WHERE potentialid>0 LIMIT 1";
			SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname LIMIT 1);
			SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname LIMIT 1);
			INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
			SELECT 'main',@trigger_fieldid,@effect_fieldid,'sql',@mysql FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
				AND @trigger_fieldid>0 AND @effect_fieldid>0;
		END IF;

	END IF;


end ||
delimiter;

CALL reset_producttoolfield_order_20211201();
DROP PROCEDURE IF EXISTS `reset_producttoolfield_order_20211201`;
delimiter;

SET @disable_triggers='abcdefg';
CALL AddColumn('ld_vendor', 'kis_id', 'varchar', '20', '');
CALL AddColumn('ld_vendor', 'kis_no', 'varchar', '20', '');
delimiter;

set @delopy_type = 346;
set @modulename = 'WorkSheet';
SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 0,@delopy_type,CONCAT('工单管理是否启用审批流程'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@delopy_type);
delimiter;

SET @work_tabid = (select tabid from ld_tab where name = 'WorkSheet');
SET @service_tabid = (select tabid from ld_tab where name = 'ServiceContracts');
UPDATE ld_option_module set `default`=0,approve_demand=0 where tabid = @work_tabid and option_tabid = @service_tabid and  IFNULL(approve_demand,0) = 0;

SET @sale_tabid = (select tabid from ld_tab where name = 'SalesOrder');
UPDATE ld_option_module set `default`=0,approve_demand=0 where tabid = @work_tabid and option_tabid = @sale_tabid and IFNULL(approve_demand,0) = 0;

SET @Outbound_tabid = (select tabid from ld_tab where name = 'OutboundOrder');
UPDATE ld_option_module set `default`=0,approve_demand=0 where tabid = @Outbound_tabid and option_tabid = @work_tabid and IFNULL(approve_demand,0) = 0;
delimiter;

SET @tabid = (SELECT tabid from ld_tab where name = 'WorkSheet');
UPDATE ld_field SET savedatabase = 'no' where tabid = @tabid and columnname = 'filename';
delimiter;

SET @disable_triggers='abcdefg';
call AddColumn('ld_expense','kis_id','varchar','200','');
call AddColumn('ld_expense','kis_no','varchar','200','');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_module_api` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(100) DEFAULT NULL,
  `api_name` varchar(255) DEFAULT NULL,
  `api_type` varchar(50) DEFAULT NULL,
  `api_cert` text,
  `api_user` varchar(100) DEFAULT NULL,
  `api_pwd` varchar(100) DEFAULT NULL,
  `api_fromid` varchar(100) DEFAULT NULL,
  `api_url` text,
  `api_filterstring` text,
  `deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_module_api_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `api_id` int(11) DEFAULT NULL,
  `parameter` varchar(100) DEFAULT NULL,
  `crm_columnname` varchar(50) DEFAULT NULL,
  `erp_field` varchar(50) DEFAULT NULL,
  `method` varchar(50) DEFAULT NULL,
  `filterstring` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;


select tabid into @tabid from ld_tab where `name` = 'Stock';
select tabid into @related_tabid from ld_tab where `name` = 'OutboundOrder';
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) + 1 into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence,buttonstatus)
select @relation_id,@tabid,@related_tabid,'get_outboundorder',@sequence+1,'OutboundOrder',0,'add',1,1,'entitytype_datacategory_sql','tmpsourcedetail.id',0,1,'yes' from dual
where not exists(select 1 from ld_relatedlists where tabid =@tabid and related_tabid = @related_tabid);
delimiter;

INSERT into ld_cvcolumnlistsort(cvid,columnname,sorttype)
SELECT ld_customview.cvid,'ld_worksheet:createdtime:createdtime:WorkSheet_DT~O:fieldlabel','desc' from ld_customview
LEFT JOIN ld_cvcolumnlistsort on ld_customview.cvid = ld_cvcolumnlistsort.cvid
where entitytype = 'WorkSheet' and IFNULL(ld_cvcolumnlistsort.cvid,0)=0;
delimiter;


UPDATE ld_desk SET fieldlabel='审批结束编辑单据保存，提交审批时默认审批流程' WHERE labelbol= 'ApproveAllowAgainSubmit' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='After approval, edit the document and save it. The default approval process is when submitting for approval' WHERE labelbol= 'ApproveAllowAgainSubmit' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;
UPDATE ld_desk SET fieldlabel='编辑单据保存提交审批时默认审批流程' WHERE labelbol= 'ApproveAllowAgainSubmitView' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='The default approval process is when editing a document and saving it for submission for approval' WHERE labelbol= 'ApproveAllowAgainSubmitView' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ApprovedEditAgainSubmitMsg','编辑已审批的单据将重置其审批状态，稍后您需要重新提交审批！','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ApprovedEditAgainSubmitMsg' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ApprovedEditAgainSubmitMsg','When editing approved records, the approval status will be updated. You need to submit it again for approval!','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ApprovedEditAgainSubmitMsg' and Labeltype='jspop');
delimiter;

DROP PROCEDURE IF EXISTS `reset_gongchengdemo_20211202`;
delimiter ||
CREATE  PROCEDURE `reset_gongchengdemo_20211202`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE trade='construction') THEN
		SET @report_name='项目进度计划';
		SET @report_type='template_js';
		SET @report_template='default_project_progress.mrt';
		SET @setype='';
		SET @report_describe='';
		SET @report_url='';
		SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
		SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

		UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
		INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
		SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);

		SET @report_name='项目进度计划与实际对比';
		SET @report_type='template_js';
		SET @report_template='default_project_progresscontrast.mrt';
		SET @setype='';
		SET @report_describe='';
		SET @report_url='';
		SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
		SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

		UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
		INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
		SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);


		UPDATE ld_usercolor SET color='140,139,170' WHERE id=1;
		UPDATE ld_usercolor SET color='222,221,226' WHERE id=2;
		UPDATE ld_usercolor SET color='181,199,201' WHERE id=3;
		UPDATE ld_usercolor SET color='196,218,201' WHERE id=4;
		UPDATE ld_usercolor SET color='146,200,224' WHERE id=5;
		UPDATE ld_usercolor SET color='103,171,214' WHERE id=6;
		UPDATE ld_usercolor SET color='195,176,214' WHERE id=7;
		UPDATE ld_usercolor SET color='0,158,78' WHERE id=8;
		UPDATE ld_usercolor SET color='253,197,0' WHERE id=9;
		UPDATE ld_usercolor SET color='248,125,11' WHERE id=10;
		UPDATE ld_usercolor SET color='22,119,210' WHERE id=11;
	END IF;

end ||
delimiter;

CALL reset_gongchengdemo_20211202();
DROP PROCEDURE IF EXISTS `reset_gongchengdemo_20211202`;
-- 2021-12-02

CREATE TABLE  if not EXISTS `ld_upgrade_external_userid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contactid` int(11) DEFAULT NULL,
  `upgrade` varchar(20) DEFAULT NULL,
  `upgradedatetime` datetime DEFAULT NULL,
  `external_userid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `upgrade` (`upgrade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

UPDATE ld_tab SET mobilepresence = 'mobile,weixin',main_tablename = 'ld_worksheet',custom_tablename='ld_worksheetscf',primary_key = 'worksheetid' where name = 'WorkSheet';
delimiter;

SET @blockid = (SELECT blockid from ld_appparenttab where parenttab_label = 'Service');
SET @sequence = (SELECT max(sequence) from ld_appparenttabrel where blockid = @blockid);
SET @tabid = (SELECT tabid from ld_tab where name = 'WorkSheet');
INSERT into ld_appparenttabrel(blockid,tabid,sequence,relatename,tab_tablename)
SELECT @blockid,@tabid,@sequence,'','ld_tab' from dual
where not EXISTS(SELECT 1 from ld_appparenttabrel where tabid = @tabid and blockid = @blockid);
delimiter;

SET @modulename = 'WorkSheet';
SET @row = 1;
SET @list = 1;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,systemdefault,showtag)
SELECT @modulename,@row,@list,'ld_worksheet:worksheet_name:worksheet_name:WorkSheet_工单名称:V',0,'yes','yes' from DUAL
where not EXISTS (SELECT 1 from ld_cvcolumnlist_wx where modulename = @modulename and rownumber = @row and listnumber = @list);

SET @row = 2;
SET @list = 1;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,systemdefault,showtag)
SELECT @modulename,@row,@list,'ld_worksheet:smownerid:assigned_user_id:WorkSheet_服务人员:V',0,'yes','yes' from DUAL
where not EXISTS (SELECT 1 from ld_cvcolumnlist_wx where modulename = @modulename and rownumber = @row and listnumber = @list);

SET @row = 2;
SET @list = 2;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,systemdefault,showtag)
SELECT @modulename,@row,@list,'ld_worksheet:worksheet_status:worksheet_status:WorkSheet_工单状态:V',0,'yes','yes' from DUAL
where not EXISTS (SELECT 1 from ld_cvcolumnlist_wx where modulename = @modulename and rownumber = @row and listnumber = @list);

SET @row = 3;
SET @list = 1;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,systemdefault,showtag)
SELECT @modulename,@row,@list,'ld_worksheet:accountid:account_id:WorkSheet_客户名称:V',0,'yes','yes' from DUAL
where not EXISTS (SELECT 1 from ld_cvcolumnlist_wx where modulename = @modulename and rownumber = @row and listnumber = @list);

SET @row = 4;
SET @list = 1;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,systemdefault,showtag)
SELECT @modulename,@row,@list,'ld_worksheet:contactid:contact_id:WorkSheet_联系人姓名:V',0,'yes','yes' from DUAL
where not EXISTS (SELECT 1 from ld_cvcolumnlist_wx where modulename = @modulename and rownumber = @row and listnumber = @list);
delimiter;

call AddColumn('ld_customreport_info','report_file','varchar','255','');
delimiter;

call AddColumn('ld_parenttabrel','checkphp','varchar','255','');
delimiter;

call AddColumn('ld_parenttabrel','isopeninblank','varchar','50','');
delimiter;

call AddColumn('ld_appparenttabrel','checkphp','varchar','255','');
delimiter;

call AddColumn('ld_mobile_report_tab_rel','checkphp','varchar','255','');
delimiter;

SET @related_tabid = (SELECT tabid from ld_tab where name ='ProjectTask');
SET @tabid =  (SELECT tabid from ld_tab where name ='Accounts');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, @related_tabid, 'get_dependents_list', 10000, 'ProjectTask', 0, 'add', 1, 0, 'datacategory_sql', 'projecttask.accountid', 1, 10000, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid);
UPDATE ld_relatedlists_seq set id =(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;
-- 2021-12-03


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

UPDATE ld_version SET old_version='V8.4.5.3',current_version='V8.4.5.3',remark='V8.4.5.3-20211203',wx_version='V8.4.5.3';
delimiter;