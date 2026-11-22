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
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLDATA','全部数据','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLDATA' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLDATA',"All data",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLDATA' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REFRESHBROWSEREFFECT','刷新浏览器即可生效！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='REFRESHBROWSEREFFECT' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REFRESHBROWSEREFFECT',"Refresh the browser to take effect!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='REFRESHBROWSEREFFECT' and labeltype='jspop');
delimiter;

set @work_deploy_type = 346;
DELETE FROM ld_systems_deploy WHERE setype = 'WorkSheet' AND deploy_type <> @work_deploy_type;
delimiter;

SET @labelbol = 'UPDATEBANKCURRENCY';
SET @zh_fieldlabel = '确认后币种和初始金额不可再更改，也不允许删除单据，是否继续？';
SET @en_fieldlabel = 'After confirmation, the currency and initial amount cannot be changed, and the document cannot be deleted,Continue?';
UPDATE ld_desk SET fieldlabel=@zh_fieldlabel WHERE languagetype='zh' AND labelbol=@labelbol;
UPDATE ld_desk SET fieldlabel=@en_fieldlabel WHERE languagetype='en' AND labelbol=@labelbol;
delimiter;

SET @labelbol = 'MASSDELBANKNOTTODELETE';
SET @zh_fieldlabel = '单据[%s]删除失败！原因：该单据有关联数据!已关联收款单、付款单、费用报销单模块！';
SET @en_fieldlabel = 'Failed to delete document [%s]! Reason: the document has associated data! Collection document, payment document and expense reimbursement document modules have been associated!';
UPDATE ld_desk SET fieldlabel=@zh_fieldlabel WHERE languagetype='zh' AND labelbol=@labelbol;
UPDATE ld_desk SET fieldlabel=@en_fieldlabel WHERE languagetype='en' AND labelbol=@labelbol;
delimiter;

SET @labelbol = 'DISABLESUCCESSFULLY';
SET @zh_label = '单据[%s]禁用成功';
SET @en_label = 'Document[%s] is disabled successfully!';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh_label,'fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en_label,'fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISABLEFAILED';
SET @zh_label = '单据[%s]禁用失败！原因：该单据已经禁用!';
SET @en_label = 'Failed to disable document[%s]! Reason: this document has been disabled!';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh_label,'fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en_label,'fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @actionname = 'Inactivating';
SET @actionlabel = 'INACTIVATING';
SET @MAX_actionid=IFNULL((SELECT MAX(actionid) FROM ld_actionmapping),0);
INSERT INTO ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT @MAX_actionid+1,@actionname,0,@actionlabel FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname = 'Inactivating' AND actionlabel='INACTIVATING');
delimiter;

SET @operation=(SELECT actionid FROM ld_actionmapping WHERE actionname='Inactivating');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet');
SET @desequence = (SELECT sequence FROM ld_profileallpermission WHERE tabid=86 AND operation=37);
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @columnname='smownerid';
UPDATE ld_profileallpermission SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@desequence;
INSERT INTO ld_profileallpermission(tabid,operation,sequence) SELECT @tabid,@operation,@desequence+1 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@operation);
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @columnname='smownerid'; 
SET @fieldname='assigned_user_id';
SET @fieldlabel='负责人'; 
SET @zh='负责人'; 
SET @en='Assigned To'; 
SET @uitype=53;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='users';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @allowhide='yes';
SET @readonly=1;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
SET @desequence = (SELECT sequence FROM ld_field WHERE tabid=86 AND fieldid=1100 AND columnname='curbalancemoney');
UPDATE ld_field SET sequence=sequence+1 WHERE tabid=86 AND sequence>@desequence;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@desequence+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND fieldlabel=@fieldlabel); 
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;


SET @operation=(SELECT actionid FROM ld_actionmapping WHERE actionname='Allocate');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet');
SET @desequence = (SELECT sequence FROM ld_profileallpermission WHERE tabid=@tabid AND operation=1);
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @columnname='smownerid';
UPDATE ld_profileallpermission SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@desequence;
INSERT INTO ld_profileallpermission(tabid,operation,sequence) SELECT @tabid,@operation,@desequence+1 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@operation);
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet');
SET @related_tabid=-10;
SET @name2='get_changeview';
SET @label='ChangeView';
SET @presence=1;
SET @actions='add';
SET @mobile_presence=1;
SET @wx_presence=1;
SET @buttonstatus='yes';
SET @MAX_relation_id=IFNULL((SELECT MAX(relation_id) FROM ld_relatedlists),0);
SET @new_sequence = (SELECT sequence FROM ld_relatedlists WHERE tabid=@tabid AND label='ViewHistory');
UPDATE ld_relatedlists SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@new_sequence;
SET @new_mobile_sequence = (SELECT mobile_sequence FROM ld_relatedlists WHERE tabid=@tabid AND label='ViewHistory');
UPDATE ld_relatedlists SET mobile_sequence=mobile_sequence+1 WHERE tabid=@tabid AND mobile_sequence>@new_mobile_sequence;
SET @new_wx_sequence = (SELECT wx_sequence FROM ld_relatedlists WHERE tabid=@tabid AND label='ViewHistory');
UPDATE ld_relatedlists SET wx_sequence=wx_sequence+1 WHERE tabid=@tabid AND wx_sequence>@new_wx_sequence;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,wx_presence,wx_sequence,buttonstatus)
SELECT @MAX_relation_id+1,@tabid,@related_tabid,@name2,@new_sequence+1,@label,@presence,@actions,@mobile_presence,@new_mobile_sequence+1,@wx_presence,@new_wx_sequence+1,@buttonstatus FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND label=@label); 
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE tablabel='BankAccountSet');
SET @desequence=(SELECT tabsequence FROM ld_tab WHERE tablabel='Expense');
UPDATE ld_tab SET tabsequence=tabsequence+1 WHERE tabsequence>@desequence;
UPDATE ld_tab SET tabsequence=@desequence+1 WHERE tabid=@tabid;
delimiter;

select profileid into @profileid from ld_profile  where profilename='总经理';
select tabid into @tabid from ld_tab where name='BankAccountSet';
select actionid into @operation from ld_actionmapping where actionname='Inactivating';
insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select @profileid,@tabid,@operation,0,10 from  DUAL where not exists(select 1 from ld_profile2standardpermissions where tabid=@tabid and profileid=@profileid and operation=@operation);
delimiter;

select profileid into @profileid from ld_profile  where profilename='财务主管';
select tabid into @tabid from ld_tab where name='BankAccountSet';
select actionid into @operation from ld_actionmapping where actionname='Inactivating';
insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select @profileid,@tabid,@operation,0,10 from  DUAL where not exists(select 1 from ld_profile2standardpermissions where tabid=@tabid and profileid=@profileid and operation=@operation);
delimiter;

alter table ld_worksheet modify solution text;
delimiter;

SET @modulename ='Products';
SET @tabid=(SELECT tabid from ld_tab where name = @modulename);
SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
SET @blockname = 'LBL_SHOP_INFOMALL';
SET @maxsequence = (SELECT max(sequence)+1 from ld_blocks where tabid=@tabid);
SET @sequence = (SELECT IFNULL(sequence,@maxsequence) from ld_blocks where tabid=14 and blocklabel='LBL_PRODUCT_DETAILS');
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,@blockname,@sequence,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);

SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'商城信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Mall Info' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
delimiter;


SET @modulename ='Products';
SET @tabid=(SELECT tabid from ld_tab where name = @modulename);
SET @relateid=(SELECT blockid FROM ld_blocks WHERE blocklabel='LBL_SHOP_INFOMALL' AND tabid=@tabid);
SET @modulename ='Products';
SET @tabid=(SELECT tabid from ld_tab where name = @modulename);
SET @relateid=(SELECT blockid FROM ld_blocks WHERE blocklabel='LBL_SHOP_INFOMALL' AND tabid=14);
SET @maxseq=(SELECT IFNULL(MAX(sequence),0) FROM ld_field WHERE tabid=@tabid AND block=@relateid);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='appsharetitle'; 
SET @fieldname='appsharetitle'; 
SET @zh='分享标题'; 
SET @en='Share title'; 
SET @uitype=19; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='longtextarea';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);


SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALL AddColumn(@tablename,@columnname,'text','','');
delimiter;


SET @modulename='Products';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'appsharetitle' and tabid = @tabid);
SET @maxseq=(SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='appshareimage'; 
SET @fieldname='appshareimage'; 
SET @zh='分享图片'; 
SET @en='Share Image'; 
SET @uitype=1109; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='fileattachment';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
CALL AddColumn(@tablename,@columnname,'text','','');
delimiter;

SET @modulename='Products';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'appsharetitle' and tabid = @tabid);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='apprecommendreason'; 
SET @fieldname='apprecommendreason'; 
SET @zh='推荐理由'; 
SET @en='Reasons for recommendation'; 
SET @uitype=19; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='longtextarea';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALL AddColumn(@tablename,@columnname,'text','','');
delimiter;


SET @modulename='Products';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'appsharetitle' and tabid = @tabid);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='originalprice'; 
SET @fieldname='originalprice'; 
SET @zh='原价'; 
SET @en='Original price'; 
SET @uitype=72; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='currency';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALL AddColumn(@tablename,@columnname,'decimal','25','');
ALTER TABLE ld_products MODIFY COLUMN originalprice decimal(25,8);
delimiter;
-- 2022-01-16

CALL getallprofile('Products');
CALL fieldprofile('Products');

CALL getallprofile('BankAccountSet');
CALL fieldprofile('BankAccountSet');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_qrcode_basic` ( 
    `qrcodebasicid` int(19) NOT NULL auto_increment PRIMARY KEY, 
    `qrcodetemplateid` int(19),
    `modulename` Varchar(50),
	`record` int(19),
	`modifiedtime` Datetime,
	`modifiedby` int(19)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_qrcode_fieldsdetail` ( 
    `id` int(19) NOT NULL auto_increment PRIMARY KEY, 
    `qrcodetemplateid` int(19),
    `fieldid` int(19),
    `qrcode_fieldlabel` varchar(255),
    `viewpermit` varchar(10),
    `editpermit` varchar(10),
    `editcontentpermit` varchar(10),
    `approvepermit` varchar(10),
    `requirecontent` varchar(10)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_qrcode_viewlog` ( 
    `qrcodeviewlogid` int(19) NOT NULL auto_increment PRIMARY KEY, 
    `qrcodebasicid` int(19),
    `wechatuserid` int(19),
    `viewtime` Datetime,
    `type` int(19),
    `trackid` int(19),
    `crmid` int(19)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @labelbol = 'FORMCODE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'表单码','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Form code','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @labelbol = 'ALLOWVIEWING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'允许查看','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Allow viewing','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WHETHERTOEDIT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'允许编辑','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Allow editing','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ALLOWVIEWINGNOTEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当有值时是否允许编辑','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Allow editing when there is a value','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ALLOWVIEWINGAPPROVE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单据提交后是否允许编辑','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Allow editing of submitted documents for approval','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VIEWPEOPLENUMBER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'查看人数','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'View number of people','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EFFECTIVETIME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'有效时间','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Effective time','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PERMANENTLYVALID';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'永久有效','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Permanently valid','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'GREATERTHANONE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入大于等于1的正整数','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter a positive integer greater than or equal to 1','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FORMCODENOTEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'表单码字段名称不能为空','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Form code field name can not be empty！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'LEASTONEFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请至少设置一个可查看字段','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please set at least one viewable field！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'FORMCODEISEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'二维码内容为空，请重新设置','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'QR code content is empty, please reset！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VALIDUNTIL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'有效期至','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Valid until','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PERSONALCODESCAN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'个人微信扫码查看或编辑','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'personal wechat code scanning to view or edit','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_bankaccountset_picklist` ( 
    `listid` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `tabid` int(11),
    `fieldname` varchar(50),
    `bankaccountsetid` int(11) NOT NULL,
    `accountname` varchar(255),
    `sequence` int(11)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO ld_picklist_set (listname,relatetable,picklist_allowedit,picklist_allowdelete) SELECT 'bankaccountsetid','ld_field','no','no' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_set WHERE listname='bankaccountsetid' AND relatetable='ld_field');
INSERT INTO ld_picklist_set (listname,relatetable,picklist_allowedit,picklist_allowdelete) SELECT 'inaccount','ld_field','no','no' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_set WHERE listname='inaccount' AND relatetable='ld_field');
INSERT INTO ld_picklist_set (listname,relatetable,picklist_allowedit,picklist_allowdelete) SELECT 'outaccount','ld_field','no','no' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_picklist_set WHERE listname='outaccount' AND relatetable='ld_field');
delimiter;

SET @labelbol = 'ACCOUNTSSORTING';
SET @zh_label = '账户排序设置';
SET @en_label = 'Account sorting settings';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh_label,'fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en_label,'fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


call AddColumn('ld_approve','finishedfield_allocatetype','varchar',20,'all');
call AddColumn('ld_approve','finishedfield_allocateid','text','','');
delimiter;

update ld_approve set finishedfield_allocatetype='all' where finishedallowedit='yes' and (finishedfield_allocatetype is null or finishedfield_allocatetype='');
delimiter;

CREATE TABLE if not EXISTS `ld_approve_finishededitfield` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `columns` varchar(255) DEFAULT NULL,
  `userid` int(11) DEFAULT NULL,
	`approveid` int(19) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FinishedApproveAllowEditFieldSet' ,'设置已批准的单据允许编辑的字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FinishedApproveAllowEditFieldSet' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FinishedApproveAllowEditFieldSet' ,'Set the fields allowed to be edited for approved documents','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FinishedApproveAllowEditFieldSet' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FinishedApproveAllowEditDefaultAllField' ,'若未设置已选字段，则默认显示所有字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FinishedApproveAllowEditDefaultAllField' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FinishedApproveAllowEditDefaultAllField' ,'If the selected field is not set, all fields are displayed by default','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FinishedApproveAllowEditDefaultAllField' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetAllowEidtFieldScope' ,'设置可编辑字段的适用范围','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetAllowEidtFieldScope' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetAllowEidtFieldScope' ,'Set the applicable range of editable fields','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetAllowEidtFieldScope' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllFields' ,'全部字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AllFields' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllFields' ,'All fields','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AllFields' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PartialFields' ,'仅部分字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PartialFields' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PartialFields' ,'Partial fields only','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PartialFields' and labeltype='fixedstr');
delimiter;
-- 2022-01-18

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','PRINT','打印','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='PRINT' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','PRINT','print','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='PRINT' and Labeltype='jspop');
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','ExportExcel','导出Excel','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='ExportExcel' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','ExportExcel','ExportExcel','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='ExportExcel' and Labeltype='jspop');
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomTables');
delete from ld_profileallpermission where tabid=@tabid;
SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN ('index','Create','Delete','Allocate','EditView','Detailview','Export','Print');
delimiter;

SET @labelbol = 'PRESETENTERPRISENUM';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请在系统设置->小程序设置->企业号设置中预先设置企业号','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please set WeChat mini program enterprise number in (System Setting->Applet Settings->Enterprise number setting)','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_qrcode_basic','token','VARCHAR','100','');
delimiter;

alter table ld_qrcode_viewlog modify type varchar(20) ;
delimiter;

select block into @block from ld_field where tabid=16 and columnname='smownerid';
update ld_field  set block=@block    where tabid=16 and columnname='team_memberid';
delimiter;
-- 2022-01-19


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

UPDATE ld_version SET old_version='V8.4.5.6',current_version='V8.4.5.6',remark='V8.4.5.6-20220119',wx_version='V8.4.5.6';
delimiter;