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

CREATE TABLE if not EXISTS ld_erpsubscribe_log (
       `id` int(11)  NOT NULL AUTO_INCREMENT,
       `msgid` varchar(50) ,
       `erp` varchar(30) ,
       `timestamp` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
       PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

UPDATE ld_desk SET fieldlabel='条记录！' where labelbol='RECORDS' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='records!' where labelbol='RECORDS' and languagetype='en' and Labeltype='jspop';
delimiter;

UPDATE ld_desk SET fieldlabel='您选择了{Var}条记录，批量操作只对前{Var}条记录生效，是否继续' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='You select {Var} records, the mass operation only effect on the first {Var} records, continue or not' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and languagetype='en' and Labeltype='jspop';
delimiter;


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


DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_approveforbill`(
    tmp_moudlename VARCHAR(100),
    tmp_deploytype INT(19)
)
BEGIN

	SET @modulename=tmp_moudlename;
	SET @new_deploytype=tmp_deploytype;

	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);

		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 1,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);


SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,isnewapprove,description)
SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no','yes','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);


SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+1,@approveid,'开始',NULL,1,1,now(),now(),6,'','start','yes',1,NULL,-1,-1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+2,@approveid,'一级审批',1,1,2,now(),now(),6,'','approver','yes',2,1,-1,1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+3,@approveid,'二级审批',1,1,3,now(),now(),6,'','approver','yes',3,1,-1,2 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+4,@approveid,'三级审批',1,1,4,now(),now(),6,'','approver','yes','',1,-1,3 FROM DUAL WHERE @hadinsert=0;

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

END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_attachments_filename_bymodule`(
    tmp_modulename VARCHAR(100)
)
BEGIN

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);

	IF @tabid>0 THEN
SELECT MAX(blockid) into @maxid FROM ld_blocks;
SELECT MAX(sequence) into @maxseq FROM ld_blocks WHERE tabid=@tabid;
SET @trantable='ld_blocks';
		SET @blocklabel='LBI_ATTACHMENT_FILE';
		SET @zh='附件信息';
		SET @en='Attachments Information';

INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title)
SELECT @maxid+1,@tabid,@blocklabel,@maxseq+1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);

UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

SELECT blockid INTO @relateid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel LIMIT 1;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

SET @maxseq=0;
SELECT MAX(fieldid) INTO @maxid FROM ld_field;
SELECT MAX(sequence) INTO @maxseq FROM ld_field WHERE tabid=@tabid AND block=@relateid;
SET @trantable='ld_field';
		SET @tablename='ld_attachments';
		SET @columnname='filename';
		SET @fieldname='filename';
		SET @zh='附件';
		SET @en='Attachment';
		SET @uitype=1109;

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,editpage)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,'fileattachment','listview' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

CALL getallprofile(tmp_modulename);
CALL fieldprofile(tmp_modulename);

END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_cvcolumnlist_wx`(
    tmp_module VARCHAR(100),
    tmp_column VARCHAR(100),
    tmp_rownum INT(1),
    tmp_colnum INT(1),
    tmp_showtag VARCHAR(20),
    tmp_sysdefault VARCHAR(20)
        )
BEGIN

  SET @columnname=(
    SELECT
      CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1))
    FROM ld_tab a
    LEFT JOIN ld_field b ON a.tabid=b.tabid
    WHERE a.`name`=tmp_module
      AND b.columnname=tmp_column
    LIMIT 1);

DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter ||
CREATE  PROCEDURE `addtabintoprofile`(
    tabname varchar(50),
    permissions int(19)
)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name=','''',tabname,'''');
prepare stmt from @sql;
execute stmt;
deallocate  prepare stmt;
OPEN cur1;
Fetch cur1 into pprofileid;
loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
Fetch cur1 into pprofileid;
end while loop1;
close cur1;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_module_withoutdetail`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_module_withoutdetail`(
    tmp_modulename VARCHAR(100),
    tmp_zhmoudulename VARCHAR(100),
    tmp_enmoudulename VARCHAR(100),
    tmp_parenttabid INT (19)
)
BEGIN

		-- 插入表单
		SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,tmp_modulename,5,@maxtseq+1,tmp_modulename,1,'CUSTOMFORMBASIC' FROM DUAL
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
SELECT @maxnum_id+1,tmp_modulename,CONCAT(getPY(tmp_zhmoudulename),'-'),1,1,1,'none',0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=tmp_modulename);
UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;

INSERT INTO ld_modtracker_tabs(tabid,visible)
SELECT @tabid,1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);


-- 插入权限
SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
                                                                                ('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView');

INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
SELECT @tabid,tmp_modulename,CONCAT('ld_',LOWER(tmp_modulename)),CONCAT(LOWER(tmp_modulename),'_no'),CONCAT(LOWER(tmp_modulename),'id'),CONCAT(LOWER(tmp_modulename),'id') FROM DUAl
WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename=tmp_modulename);


SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION'),2,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);

SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);


-- 插入字段
SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'accountid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,73,'account_id','客户名称',1,0,(@i:=@i+1),@blockid ,1,'V~O',1,0,0,'reference',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='accountid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='accountid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'客户名称' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Account Name' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,CONCAT(LOWER(tmp_modulename),'_no'),'no',CONCAT('ld_',LOWER(tmp_modulename)),1,4,CONCAT(LOWER(tmp_modulename),'_no'),'单据编号',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'单据编号' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Bill NO.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype)
SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2,'users' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'smcreatorid','创建人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'modifiedby','最新更新人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'modifiedtime','更新时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,609,'approvestatus','审批状态',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'approvetime','最新审批时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,131,'approveby','上一步审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,132,'currentapprover','当前审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
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
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'print_times','打印次数',1,1,(@i:=@i+1),@blockid ,2,'N~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='print_times');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'打印次数' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Print Times' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

-- 推进阶段 团队成员 标签 最新同步时间 最新同步结果 最新推进时间
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'advance_stage','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'advance_stage','推进阶段',1,1,(@i:=@i+1),@blockid ,3,'V~O',1,0,1,'text',0,1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='advance_stage');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='advance_stage');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'推进阶段' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Advance Stage' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'team_memberid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,154,'team_memberid','团队成员',1,1,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,'text',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'团队成员' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Team Members' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'tag','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,301,'tag','标签',0,2,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,'tag',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='tag');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='tag');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'标签' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Tag' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'exchtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,86,'exchtime','最新同步时间',1,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,'datetime',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='exchtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='exchtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新同步时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'最新同步时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'exchmsg','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,19,'exchmsg','最新同步结果',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,'longtextarea',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='exchmsg');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='exchmsg');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新同步结果' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'最新同步结果' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'latestpushtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),2,86,'latestpushtime','最新推进时间',0,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,'datetime',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新推进时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Latest push time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

-- 推进阶段 团队成员 标签 最新同步时间 最新同步结果 最新推进时间
CALL getallprofile(tmp_modulename);
CALL fieldprofile(tmp_modulename);


SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All');

INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+2,'已批准',0,0,tmp_modulename,3,1,2 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已批准');

INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+3,'审批中',0,0,tmp_modulename,3,1,3 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='审批中');

INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+4,'未提交',0,0,tmp_modulename,3,1,4 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='未提交');

INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+5,'已驳回',0,0,tmp_modulename,3,1,5 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已驳回');

INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+6,'已拒绝',0,0,tmp_modulename,3,1,6 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已拒绝');

UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':',LOWER(tmp_modulename),'_no',':',LOWER(tmp_modulename),'_no',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,1,CONCAT('ld_',LOWER(tmp_modulename),':','smownerid',':','assigned_user_id',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,2,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,3,CONCAT('ld_',LOWER(tmp_modulename),':','smcreatorid',':','smcreatorid',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,4,CONCAT('ld_',LOWER(tmp_modulename),':','createdtime',':','createdtime',':',tmp_modulename,'_fieldlabel:DT');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已批准');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已批准',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='审批中');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','审批中',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='未提交');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','未提交',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已驳回');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已驳回',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已拒绝');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已拒绝',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');

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


INSERT INTO ld_def_org_share(tabid,permission,editstatus)
SELECT @tabid,3,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);

CALL addtabintoprofile(tmp_modulename,1);


SET @querysql=CONCAT(
		"CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
		`",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
		`",LOWER(tmp_modulename),"_no` VARCHAR(255) DEFAULT NULL,
		`accountid` INT(19) DEFAULT 0,
		`smownerid` INT(19) DEFAULT 0,
		`smcreatorid` INT(19) DEFAULT 0,
		`createdtime` DATETIME DEFAULT NULL,
		`modifiedby` INT(19) DEFAULT 0,
		`modifiedtime` DATETIME DEFAULT NULL,
		`approvestatus` VARCHAR(50) DEFAULT '未提交',
		`approvetime` DATETIME DEFAULT NULL,
		`approveby` INT(19) DEFAULT 0,
		`currentapprover` TEXT DEFAULT NULL,
		`print_times` INT(11) DEFAULT '0',
		`deleted` INT(19) NOT NULL DEFAULT '0',
		`approvesubmitter` INT(19) DEFAULT 0,
		`approvesubmittedtime` DATETIME DEFAULT NULL,
		`approveurgent` VARCHAR(10) DEFAULT 'no',
		`approveexpediting` VARCHAR(10) DEFAULT 'no',
		`currentapprovestepid` INT(19) DEFAULT 0,
		`kis_id` INT(11) DEFAULT 0,
		`kis_no` VARCHAR(50) DEFAULT NULL,
		`exchtime` DATETIME DEFAULT NULL,
		`exchmsg` TEXT DEFAULT NULL,
		`team_memberid` TEXT DEFAULT NULL,
		`tag` VARCHAR(50) DEFAULT NULL,
		`latestpushtime` DATETIME DEFAULT NULL,

		PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");


PREPARE stmt FROM @querysql;
EXECUTE stmt;

PREPARE stmt FROM @querysql1;
EXECUTE stmt;
DROP PREPARE stmt;

		-- 添加附件区块
CALl ldcrm_add_attachments_filename_bymodule(tmp_modulename);


-- 移动端
DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_modulename;
CALL ldcrm_add_cvcolumnlist_wx(tmp_modulename,CONCAT(LOWER(tmp_modulename),'_no'),'1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(tmp_modulename,'createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(tmp_modulename,'smownerid','3','1','yes','yes');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,CONCAT(LOWER(tmp_modulename),'_no'),(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname=CONCAT(LOWER(tmp_modulename),'_no'));
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

update ld_tab set mobilepresence='weixin' where tabid=@tabid;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_101to160`;
delimiter ||
CREATE PROCEDURE `ldcrm_addcustomform_101to160`(
)
BEGIN

	declare i int default 101;

	SET @maxid=(SELECT MAX(parenttabid) FROM ld_parenttab);
	SET @seq=(SELECT MAX(sequence) FROM ld_parenttab);
INSERT INTO ld_parenttab(parenttabid,parenttab_label,sequence,visible,allocatetype)
SELECT @maxid+1,'CustomForms',@seq+1,0,'all' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttab WHERE parenttab_label='CustomForms');

SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_parenttab',@myparenttabid, @myparenttabid,'自定义表单' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@myparenttabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_parenttab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_parenttab',@myparenttabid, @myparenttabid,'Custom Forms' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@myparenttabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_parenttab');

WHILE i<=160 DO
		IF NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=CONCAT('CustomForm',i)) THEN
			-- 添加模块
			CALL ldcrm_add_module_withoutdetail(CONCAT('CustomForm',i),CONCAT('自定义表单',i),CONCAT('Custom Form ',i),@myparenttabid);

			-- 添加审批流程
CALL ldcrm_add_approveforbill(CONCAT('CustomForm',i),260+i);
CALL AddColumn(CONCAT('ld_',LOWER('CustomForm'),i),'advance_stage','VARCHAR','100','');
CALL AddColumn(CONCAT('ld_',LOWER('CustomForm'),i),'kis_id','int','11',0);
CALL AddColumn(CONCAT('ld_',LOWER('CustomForm'),i),'kis_no','varchar','50',NULL);
END IF;
		SET i=i+1;
END WHILE;

end ||
delimiter;


CALL ldcrm_addcustomform_101to160();
DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_61to100`;
DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
DROP PROCEDURE IF EXISTS `ldcrm_add_module_withoutdetail`;
delimiter;

update ld_desk set fieldlabel='发布' where labelbol='PUBLISH' and fieldlabel='发表' and Labeltype='fixedstr';
delimiter;


CALL AddColumn('ld_customtable','primaryname','varchar','100','');
CALL AddColumn('ld_report_analysis_folder','primaryname','varchar','100','');
delimiter;
DROP PROCEDURE IF EXISTS `reset_reportinfo_20230323`;
delimiter ||
CREATE  PROCEDURE `reset_reportinfo_20230323`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_report_analysis_folder where `primaryname`='DIR_potiential_report' and deleted=0 ) THEN
        select parent_id,sequence,depth into @parent_id,@sequence,@depth from ld_report_analysis_folder where `name`='销售报表（默认）' and deleted=0 order by createdtime desc limit 1;
        select max(analysisfolder_id)+1 into @analysisfolder_id  from ld_report_analysis_folder ;
        INSERT INTO `ld_report_analysis_folder` (`analysisfolder_id`, `name`, `folderlabel_zh`, `folderlabel_en`, `parent_id`, `description`, `smcreatorid`, `createdtime`, `sequence`, `visible`, `systemdefault`, `version`, `modify_id`, `modify_time`, `deleted`, `allocatetype`, `depth`, `approveallocatetype`,primaryname) VALUES (@analysisfolder_id, '商机报表（默认）', '商机报表（默认）', '商机报表（默认）', @parent_id, '', '1', '2023-03-23 17:03:11', @sequence+1, 'yes', 'no', '', '1', '2023-03-23 17:03:11', '0', '0', @depth, '0','DIR_potiential_report');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ld_customtable where `primaryname`='potiential_report_avg_period' and deleted=0 ) THEN
        select max(report_id)+1 into @report_id1  from ld_customtable ;
        select analysisfolder_id into @analysisfolder_id1 from ld_report_analysis_folder where `primaryname`='DIR_potiential_report' and deleted=0 order by createdtime desc  limit 1;

        INSERT INTO `ld_customtable` (`report_id`, `report_name`, `parent_id`, `description`, `sequence`, `linkmodulecheck`, `total_position`, `show_subtotal`, `show_detail`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `smcreatorid`, `approveallocatetype`, `report_type`, `sqlstr`, `isshow_search`, `istemplate`, `isfolder`, `templateid`, `level`, `analysisfolder_id`,primaryname) VALUES (@report_id1, '商机平均结单周期统计（按人员）', NULL, '', NULL, 'no', NULL, NULL, 'yes', '2023-03-23 15:38:48', '2023-03-23 15:55:43', '0', '1', '1', '0', 'sql', "select \nsmownerid,\npotential_no,\npotentialid,\npotentialname,\nlast_name,\ntotal,\nsales_stage,\ncreatedtime,\nchangedon,\ngaptime,\nordernum\nfrom (\nselect \np.smownerid,\np.potential_no,\np.potentialid,\np.potentialname,\nu.last_name,\np.total,\np.sales_stage,\np.createdtime,\nmodtracker.changedon,\ntimestampdiff(HOUR,p.createdtime,modtracker.changedon)as gaptime,\n1 as ordernum\nfrom \nld_potential p \nleft join ld_account a on p.accountid=a.accountid\nleft join ld_users u on u.id=p.smownerid\nleft join(\nselect \nld_modtracker_basic.crmid,\nmax(ld_modtracker_basic.changedon) as changedon,\nld_modtracker_detail.fieldname,\nld_modtracker_detail.postvalue\nfrom ld_modtracker_basic \nleft join ld_modtracker_detail on ld_modtracker_basic.id=ld_modtracker_detail.id\nwhere ld_modtracker_basic.module=\'Potentials\'\nand ld_modtracker_detail.postvalue=\'成功结案\' \nand ld_modtracker_detail.fieldname=\'sales_stage\'\ngroup by ld_modtracker_basic.crmid\n)modtracker on modtracker.crmid=p.potentialid\nwhere p.sales_stage=\'成功结案\'\nand p.createdtime>=DATE_FORMAT(\'{starttime}\',\'%Y-%m-%d 00:00:00\') and p.createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\')\nand find_in_set(p.smownerid,\'{userid}\')\nunion all \nselect \nsmownerid,\n\'\' as potential_no,\n\'\' as potentialid,\n\'\' as potentialname,\nconcat(last_name,'-小计') as last_name,\n\'\' as total,\n\'\' as sales_stage,\n\'\' as createdtime,\n\'\' as changedon,\nsum(timestampdiff(HOUR,createdtime,changedon))/count(1) as gaptime,\n2 as ordernum\nfrom (\nselect \np.smownerid,\np.potential_no,\np.potentialid,\np.potentialname,\nu.last_name,\np.total,\np.sales_stage,\np.createdtime,\nmodtracker.changedon,\ntimestampdiff(HOUR,p.createdtime,modtracker.changedon)as gaptime,\n2 as ordernum\nfrom \nld_potential p \nleft join ld_account a on p.accountid=a.accountid\nleft join ld_users u on u.id=p.smownerid\nleft join(\nselect \nld_modtracker_basic.crmid,\nmax(ld_modtracker_basic.changedon) as changedon,\nld_modtracker_detail.fieldname,\nld_modtracker_detail.postvalue\nfrom ld_modtracker_basic \nleft join ld_modtracker_detail on ld_modtracker_basic.id=ld_modtracker_detail.id\nwhere ld_modtracker_basic.module=\'Potentials\'\nand ld_modtracker_detail.postvalue=\'成功结案\' \nand ld_modtracker_detail.fieldname=\'sales_stage\'\ngroup by ld_modtracker_basic.crmid\n)modtracker on modtracker.crmid=p.potentialid\nwhere p.sales_stage=\'成功结案\'\n and p.deleted=0 and p.createdtime>=DATE_FORMAT(\'{starttime}\',\'%Y-%m-%d 00:00:00\') and p.createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\')\nand find_in_set(p.smownerid,\'{userid}\')\n)a group by smownerid\n)a order by smownerid asc,ordernum asc;", 'yes', 'no', 'no', '0', '1', @analysisfolder_id1,"potiential_report_avg_period");
        INSERT INTO `ld_customtable2user` (`report_id`, `userid`) VALUES (@report_id1, '-1');
        select max(id) into @filterid1 from ld_customtablesql_filter;
        INSERT INTO `ld_customtablesql_filter` (`id`, `report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`) VALUES (@filterid1+1, @report_id1, 'starttime', '创建开始时间', 'date', 'thisyearstart,2023-01-01', NULL, NULL, NULL, NULL, '1');
        INSERT INTO `ld_customtablesql_filter` (`id`, `report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`) VALUES (@filterid1+2, @report_id1, 'userid', '负责人', 'multiuser', '', NULL, 'Potentials', NULL, NULL, '3');
        INSERT INTO `ld_customtablesql_filter` (`id`, `report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`) VALUES (@filterid1+3, @report_id1, 'endtime', '创建结束时间', 'date', 'todayend,2023-03-23', NULL, NULL, NULL, NULL, '2');

        select max(id) into @columnsid from ld_customtable_columns;
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+1, @report_id1, 'smownerid', 'smownerid', NULL, NULL, NULL, 'no', NULL, 'left', '1', NULL, NULL, NULL, '0', NULL, NULL, 'no', 'string', 'no', 'no', NULL, NULL);
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+2, @report_id1, '商机编号', 'potential_no', NULL, NULL, NULL, 'no', NULL, 'left', '2', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', '{\"type\":\"detailview\",\"modulefield\":\"\",\"recordfield\":\"potentialid\",\"url\":\"\"}', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+3, @report_id1, '商机名称', 'potentialname', NULL, NULL, NULL, 'no', NULL, 'left', '3', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+4, @report_id1, '负责人', 'last_name', NULL, NULL, NULL, 'yes', NULL, 'left', '1', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+5, @report_id1, '预算金额', 'total', NULL, NULL, NULL, 'no', NULL, 'left', '4', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+6, @report_id1, '销售阶段', 'sales_stage', NULL, NULL, NULL, 'no', NULL, 'left', '5', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+7, @report_id1, '创建时间', 'createdtime', NULL, NULL, NULL, 'no', NULL, 'left', '6', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+8, @report_id1, '成功时间', 'changedon', NULL, NULL, NULL, 'no', NULL, 'left', '7', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+9, @report_id1, '结单时间（H）', 'gaptime', NULL, NULL, NULL, 'no', NULL, 'left', '8', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+10, @report_id1, 'ordernum', 'ordernum', NULL, NULL, NULL, 'no', NULL, 'left', '10', NULL, NULL, NULL, '0', NULL, NULL, 'no', 'string', 'no', 'no', NULL, NULL);
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+11, @report_id1, 'potentialid', 'potentialid', NULL, NULL, NULL, 'no', NULL, 'left', '3', NULL, NULL, NULL, '0', NULL, NULL, 'no', 'string', 'no', 'no', NULL, NULL);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM ld_customtable where `primaryname`='potiential_report_stay_period' and deleted=0 ) THEN
        select max(report_id)+1 into @report_id2  from ld_customtable ;
        select analysisfolder_id into @analysisfolder_id2 from ld_report_analysis_folder where `primaryname`='DIR_potiential_report' and deleted=0 order by createdtime desc  limit 1;

        INSERT INTO `ld_customtable` (`report_id`, `report_name`, `parent_id`, `description`, `sequence`, `linkmodulecheck`, `total_position`, `show_subtotal`, `show_detail`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `smcreatorid`, `approveallocatetype`, `report_type`, `sqlstr`, `isshow_search`, `istemplate`, `isfolder`, `templateid`, `level`, `analysisfolder_id`,primaryname) VALUES (@report_id, '商机阶段停留时长统计（按人员）', NULL, '', NULL, 'no', NULL, NULL, 'yes', '2023-03-23 18:32:16', '2023-03-27 09:51:03', '0', '1', '1', '0', 'sql', "select \np.smownerid,\np.potential_no,\np.potentialid,\np.potentialname,\na.accountname,\nu.last_name,\np.total,\nmodtracker.postvalue,\nmodtracker.createdtime,\nmodtracker.endtime,\ntimestampdiff(HOUR,modtracker.createdtime,modtracker.endtime)as gaptime\nfrom \nld_potential p \nleft join ld_account a on p.accountid=a.accountid\nleft join ld_users u on u.id=p.smownerid\nleft join(\nselect   t.crmid,t1.crmid as crmid1 ,timestampdiff(HOUR,t1.changedon,t.changedon)as gaptime,t1.j,t.postvalue,\ncase when t.crmid<>ifnull(t1.crmid,0)  then t.createdtime else t1.changedon  end as createdtime ,t.changedon as endtime \nfrom \n(select (@i:=@i+1) as i,a.*,p.createdtime,detail.postvalue from ld_modtracker_basic  as a left join ld_modtracker_detail detail on  detail.id=a.id INNER JOIN ld_potential  as p on p.potentialid=a.crmid and p.deleted=0 and detail.fieldname=\'sales_stage\' and a.module=\'Potentials\',(select @i:=0) as it    order by id asc) t\nleft join \n(select (@j:=@j+1) as j,a.* from ld_modtracker_basic as a left join ld_modtracker_detail detail on  detail.id=a.id INNER JOIN ld_potential \nas p on p.potentialid=a.crmid and p.deleted=0 and  detail.fieldname=\'sales_stage\' and a.module=\'Potentials\',(select @j:=1) as it     order by id asc ) t1\non t.i=t1.j\n)modtracker on modtracker.crmid=p.potentialid\nwhere p.deleted=0\nand p.createdtime>=DATE_FORMAT(\'{starttime}\',\'%Y-%m-%d 00:00:00\') and p.createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\')\nand find_in_set(p.smownerid,\'{userid}\')", 'yes', 'no', 'no', '0', '1', @analysisfolder_id2,"potiential_report_stay_period");
        INSERT INTO `ld_customtable2user` (`report_id`, `userid`) VALUES (@report_id2, '-1');
        select max(id) into @filterid2 from ld_customtablesql_filter;
        INSERT INTO `ld_customtablesql_filter` (`id`, `report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`) VALUES (@filterid2+1, @report_id2, 'starttime', '开始时间', 'date', 'thisyearstart,2023-01-01', NULL, NULL, NULL, NULL, '1');
        INSERT INTO `ld_customtablesql_filter` (`id`, `report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`) VALUES (@filterid2+2, @report_id2, 'endtime', '结束时间', 'date', 'todayend,2023-03-27', NULL, NULL, NULL, NULL, '2');
        INSERT INTO `ld_customtablesql_filter` (`id`, `report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`) VALUES (@filterid2+3, @report_id2, 'userid', '负责人', 'multiuser', '1,17,58', NULL, 'Potentials', NULL, NULL, '3');

        select max(id) into @columnsid from ld_customtable_columns;
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+1, @report_id2, 'smownerid', 'smownerid', NULL, NULL, NULL, 'no', NULL, 'left', '4', NULL, NULL, NULL, '0', NULL, NULL, 'no', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+2, @report_id2, '销售机会编号', 'potential_no', NULL, NULL, NULL, 'yes', NULL, 'left', '2', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', '{\"type\":\"detailview\",\"modulefield\":\"\",\"recordfield\":\"potentialid\",\"url\":\"\"}', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+3, @report_id2, 'potentialid', 'potentialid', NULL, NULL, NULL, 'no', NULL, 'left', '5', NULL, NULL, NULL, '0', NULL, NULL, 'no', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+4, @report_id2, '销售机会名称', 'potentialname', NULL, NULL, NULL, 'no', NULL, 'left', '4', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+5, @report_id2, '负责人', 'last_name', NULL, NULL, NULL, 'yes', NULL, 'left', '1', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+6, @report_id2, '商机金额', 'total', NULL, NULL, NULL, 'no', NULL, 'left', '6', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+8, @report_id2, '销售阶段', 'postvalue', NULL, NULL, NULL, 'no', NULL, 'left', '3', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+7, @report_id2, '开始时间', 'createdtime', NULL, NULL, NULL, 'no', NULL, 'left', '7', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+9, @report_id2, '结束时间', 'endtime', NULL, NULL, NULL, 'no', NULL, 'left', '7', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+10, @report_id2, '累计耗时（H）', 'gaptime', NULL, NULL, NULL, 'no', NULL, 'left', '8', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+11, @report_id2, '客户名称', 'accountname', NULL, NULL, NULL, 'no', NULL, 'left', '5', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ld_customtable where `primaryname`='account_gather_report' and deleted=0 ) THEN
        select max(report_id)+1 into @report_id3  from ld_customtable ;
        select analysisfolder_id into @analysisfolder_id3 from ld_report_analysis_folder where `name`='统计排名（默认）' and deleted=0 order by createdtime desc  limit 1;

        INSERT INTO `ld_customtable` (`report_id`, `report_name`, `parent_id`, `description`, `sequence`, `linkmodulecheck`, `total_position`, `show_subtotal`, `show_detail`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `smcreatorid`, `approveallocatetype`, `report_type`, `sqlstr`, `isshow_search`, `istemplate`, `isfolder`, `templateid`, `level`, `analysisfolder_id`,primaryname) VALUES (@report_id, '客户汇总统计表', NULL, '', NULL, 'no', NULL, NULL, 'yes', '2023-03-27 11:22:54', '2023-03-27 11:45:06', '0', '1', '1', '0', 'sql', "select \nld_users.last_name,\nld_users.id as userid,\na.accountallnums,\na.accountthisnums,\na.effectivenums,\nb.newsales,\nb.oldsales\nfrom ld_users \nleft join (\nselect \nsum(case when createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\') then 1 else 0 end ) as accountallnums,\nsum(case when createdtime>=DATE_FORMAT(\'{starttime}\',\'%Y-%m-%d 23:59:59\') and createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\') then 1 else 0 end ) as accountthisnums,\nsum(case when rating<>\'失败关闭\' then 1 else 0 end) as effectivenums,\nsmownerid\nfrom ld_account \nwhere ld_account.deleted=0 and find_in_set(smownerid,\'{userid}\')\nGROUP BY smownerid\n)a on a.smownerid=ld_users.id\nleft join (\nselect \nsum(case when sales.thisnums=1 and sales.allnums=1 then 1 else 0 end )as newsales,\nsum(case when sales.thisnums>=1 and sales.allnums>=1 then 1 else 0 end )as oldsales,\nld_account.smownerid\n  from ld_account\nleft join (\nselect \nsum(case when createdtime>=DATE_FORMAT(\'{starttime}\',\'%Y-%m-%d 00:00:00\') and createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\')then 1 else 0 end )as thisnums,\ncount(1)as allnums,\naccountid\nfrom ld_salesorder \nwhere deleted=0 \ngroup by accountid\n)sales on sales.accountid=ld_account.accountid\ngroup by ld_account.smownerid\n)b on b.smownerid=ld_users.id\nwhere ld_users.deleted=0 \nand (a.accountallnums >0 or\na.accountthisnums >0 or\na.effectivenums >0 or\nb.newsales >0 or\nb.oldsales)\nand find_in_set(ld_users.id,\'{userid}\')", 'yes', 'no', 'no', '0', '1', @analysisfolder_id3,"account_gather_report");
        INSERT INTO `ld_customtable2user` (`report_id`, `userid`) VALUES (@report_id3, '-1');
        select max(id) into @filterid3 from ld_customtablesql_filter;
        INSERT INTO `ld_customtablesql_filter` (`id`, `report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`) VALUES (@filterid3+1, @report_id3, 'starttime', '开始时间', 'date', 'thisyearstart,2023-01-01', NULL, NULL, NULL, NULL, '1');
        INSERT INTO `ld_customtablesql_filter` (`id`, `report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`) VALUES (@filterid3+2, @report_id3, 'endtime', '结束时间', 'date', 'todayend,2023-03-27', NULL, NULL, NULL, NULL, '2');
        INSERT INTO `ld_customtablesql_filter` (`id`, `report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`) VALUES (@filterid3+3, @report_id3, 'userid', '负责人', 'multiuser', '1,17,58', NULL, 'Accounts', NULL, NULL, '3');
        select max(id) into @columnsid from ld_customtable_columns;
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+1, @report_id3, '负责人', 'last_name', NULL, NULL, NULL, 'no', NULL, 'left', '1', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+2, @report_id3, 'userid', 'userid', NULL, NULL, NULL, 'no', NULL, 'left', '2', NULL, NULL, NULL, '0', NULL, NULL, 'no', 'string', 'no', 'no', NULL, NULL);
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+3, @report_id3, '客户总数', 'accountallnums', NULL, NULL, NULL, 'no', NULL, 'left', '2', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+4, @report_id3, '新增客户数', 'accountthisnums', NULL, NULL, NULL, 'no', NULL, 'left', '4', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+5, @report_id3, '有效客户数', 'effectivenums', NULL, NULL, NULL, 'no', NULL, 'left', '3', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+6, @report_id3, '首次成交客户数', 'newsales', NULL, NULL, NULL, 'no', NULL, 'left', '5', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');
        INSERT INTO `ld_customtable_columns` (`id`, `report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`) VALUES (@columnsid+7, @report_id3, '多次成交客户数', 'oldsales', NULL, NULL, NULL, 'no', NULL, 'left', '6', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null');

    END IF;
end ||
delimiter;

call reset_reportinfo_20230323();
delimiter;

set @labelbol='GetCustomBusinessError';
set @labelzh='获取工商信息失败，请重试！';
set @labelen='Failed to obtain industrial and commercial information, please try again (multiple queries without results, please check the interface information)!';
set @labeltype='jspop';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,@labelzh,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,@labelen,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='en');
delimiter;
set @labelbol='PlaceCheckTianYanChaInterface';
set @labelzh='（多次查询没有结果请联系管理员检查天眼查接口信息）';
set @labelen='(No results from multiple queries. Please contact the administrator to check the interface information.)';
set @labeltype='jspop';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,@labelzh,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,@labelen,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='en');
delimiter;

CREATE TABLE if not EXISTS `ld_stuff` (
    `stuffid` int(11) NOT NULL,
    `stufftitle` varchar(100) DEFAULT NULL,
    `stufftype` varchar(50) DEFAULT NULL,
    `relatedmodule` varchar(255) DEFAULT NULL,
    `trade` varchar(50) DEFAULT NULL,
    PRIMARY KEY (`stuffid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_homeboard` (
    `boardid` int(11) NOT NULL AUTO_INCREMENT,
    `description` text,
    `boardname` varchar(100) DEFAULT NULL,
    `smcreatorid` int(11) DEFAULT NULL,
    `createdtime` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    `modifiedby` int(11) DEFAULT NULL,
    `modifiedtime` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    `deleted` int(4) DEFAULT '0',
    `boardlayout` varchar(20) DEFAULT NULL,
    `scope` varchar(20) DEFAULT NULL,
    `timesearchdefault` varchar(50) DEFAULT NULL,
    `approve_value` varchar(100) DEFAULT NULL,
    PRIMARY KEY (`boardid`)
    ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE if not EXISTS `ld_homeboard_plate` (
    `plateid` int(11) NOT NULL AUTO_INCREMENT,
    `boardid` int(11) DEFAULT NULL,
    `platetype` varchar(20) DEFAULT NULL,
    `platewidth` varchar(20) DEFAULT NULL,
    `sequence` int(4) DEFAULT NULL,
    PRIMARY KEY (`plateid`)
    ) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE if not EXISTS `ld_homeboard_plate_stuff` (
    `stuffid` int(11) NOT NULL,
    `boardid` int(11) DEFAULT NULL,
    `plateid` int(11) DEFAULT NULL,
    `stufftype` varchar(50) DEFAULT NULL,
    `sequence` int(4) DEFAULT NULL,
    `height` varchar(20) DEFAULT NULL,
    `stufftitle_zh` varchar(100) DEFAULT NULL,
    `stufftitle_en` varchar(100) DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_related_scope` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `modulename` varchar(50) DEFAULT NULL,
    `type` varchar(50) DEFAULT NULL,
    `viewid` int(19) NOT NULL,
    `relatedid` int(19) NOT NULL,
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '1','SALESSIXMONTH','chart','SalesOrder' from dual
where not exists(select 1 from ld_stuff where stuffid='1' and stufftitle='SALESSIXMONTH' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '2','ANNUALSALES','twotable','SalesOrder,Accounts,CashBill' from dual
where not exists(select 1 from ld_stuff where stuffid='2' and stufftitle='ANNUALSALES' and stufftype='twotable');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '3','INVENTORYDATA','default','Products,Stock,OutboundOrder' from dual
where not exists(select 1 from ld_stuff where stuffid='3' and stufftitle='INVENTORYDATA' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '4','AMOUNTMONTHCONTRACTYEAR','chart','SalesOrder' from dual
where not exists(select 1 from ld_stuff where stuffid='4' and stufftitle='AMOUNTMONTHCONTRACTYEAR' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '5','BACKAMOUNTMONTHYEAR','chart','CashBill' from dual
where not exists(select 1 from ld_stuff where stuffid='5' and stufftitle='BACKAMOUNTMONTHYEAR' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '6','RECEIVESUMMARY','default','' from dual
where not exists(select 1 from ld_stuff where stuffid='6' and stufftitle='RECEIVESUMMARY' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '7','SUBORDINATEMOTHSALESDATA','default','CashBill,Accounts,Calendar,Potentials,SalesOrder' from dual
where not exists(select 1 from ld_stuff where stuffid='7' and stufftitle='SUBORDINATEMOTHSALESDATA' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '8','Penson Month Sales','default','CashBill,Accounts,Calendar,Potentials,SalesOrder' from dual
where not exists(select 1 from ld_stuff where stuffid='8' and stufftitle='Penson Month Sales' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '9','INDIVIDUALSIXMONTH','chart','SalesOrder' from dual
where not exists(select 1 from ld_stuff where stuffid='9' and stufftitle='INDIVIDUALSIXMONTH' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '10','OVERSERVENDAYSSCHEDULE','default','Calendar' from dual
where not exists(select 1 from ld_stuff where stuffid='10' and stufftitle='OVERSERVENDAYSSCHEDULE' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '11','FUTURESEVENDAYSSCHEDULE','default','Calendar' from dual
where not exists(select 1 from ld_stuff where stuffid='11' and stufftitle='FUTURESEVENDAYSSCHEDULE' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '12','EXPIREDAGENDA','default','Calendar' from dual
where not exists(select 1 from ld_stuff where stuffid='12' and stufftitle='EXPIREDAGENDA' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '13','TODAYCONTACTCUSTOMER','default','Accounts' from dual
where not exists(select 1 from ld_stuff where stuffid='13' and stufftitle='TODAYCONTACTCUSTOMER' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '14','LATESTPOTENTIALS','default','Potentials' from dual
where not exists(select 1 from ld_stuff where stuffid='14' and stufftitle='LATESTPOTENTIALS' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '15','LATESTQUOTATION','default','Quotes' from dual
where not exists(select 1 from ld_stuff where stuffid='15' and stufftitle='LATESTQUOTATION' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '16','NEWCONTRACTORDERS','default','SalesOrder' from dual
where not exists(select 1 from ld_stuff where stuffid='16' and stufftitle='NEWCONTRACTORDERS' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '17','LATESTINVOICE','default','Invoice' from dual
where not exists(select 1 from ld_stuff where stuffid='17' and stufftitle='LATESTINVOICE' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '19','SALESFUNNEL','chart','Potentials' from dual
where not exists(select 1 from ld_stuff where stuffid='19' and stufftitle='SALESFUNNEL' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '20','CRITICALVIEW','default','' from dual
where not exists(select 1 from ld_stuff where stuffid='20' and stufftitle='CRITICALVIEW' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '21','NOTEPAD','notebook','' from dual
where not exists(select 1 from ld_stuff where stuffid='21' and stufftitle='NOTEPAD' and stufftype='notebook');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '24','DAILYWEEKMONTH','reportLog','ReportLog' from dual
where not exists(select 1 from ld_stuff where stuffid='24' and stufftitle='DAILYWEEKMONTH' and stufftype='reportLog');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '25','WITHINPAYMENTPLAN','default','PaymentPlan' from dual
where not exists(select 1 from ld_stuff where stuffid='25' and stufftitle='WITHINPAYMENTPLAN' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '26','LATESTEXPENSE','default','Expense' from dual
where not exists(select 1 from ld_stuff where stuffid='26' and stufftitle='LATESTEXPENSE' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '27','LATESTCASHBILL','default','CashBill' from dual
where not exists(select 1 from ld_stuff where stuffid='27' and stufftitle='LATESTCASHBILL' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '28','LATESTSENDCASHBILL','default','SendCashBill' from dual
where not exists(select 1 from ld_stuff where stuffid='28' and stufftitle='LATESTSENDCASHBILL' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '29','LATESTCASHDEPOSIT','default','CashDeposit' from dual
where not exists(select 1 from ld_stuff where stuffid='29' and stufftitle='LATESTCASHDEPOSIT' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '30','LATESTPUTCASH','default','PutCash' from dual
where not exists(select 1 from ld_stuff where stuffid='30' and stufftitle='LATESTPUTCASH' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '31','BANKCASH','default','Expense,CashBill,SendCashBill,CashDeposit,PutCash' from dual
where not exists(select 1 from ld_stuff where stuffid='31' and stufftitle='BANKCASH' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '32','PUBLICANNOUNCEMENT','default','PublicAnnouncement' from dual
where not exists(select 1 from ld_stuff where stuffid='32' and stufftitle='PUBLICANNOUNCEMENT' and stufftype='default');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '33','SALESCHARTS','twotable2','SalesOrder,ServiceContracts,CashBill' from dual
where not exists(select 1 from ld_stuff where stuffid='33' and stufftitle='SALESCHARTS' and stufftype='twotable2');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '34','transaction','transaction','' from dual
where not exists(select 1 from ld_stuff where stuffid='34' and stufftitle='transaction' and stufftype='transaction');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '35','saleskit','saleskit','' from dual
where not exists(select 1 from ld_stuff where stuffid='35' and stufftitle='saleskit' and stufftype='saleskit');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '57','ContactTimesRanking','chart','' from dual
where not exists(select 1 from ld_stuff where stuffid='57' and stufftitle='ContactTimesRanking' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '66','ServiceKanban','servicekanban','HelpDesk' from dual
where not exists(select 1 from ld_stuff where stuffid='66' and stufftitle='ServiceKanban' and stufftype='servicekanban');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '39','PendingApproval','pendingapproval','' from dual
where not exists(select 1 from ld_stuff where stuffid='39' and stufftitle='PendingApproval' and stufftype='pendingapproval');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '40','COMPLATIONRATESIXMONTH','chart','SalesGoal' from dual
where not exists(select 1 from ld_stuff where stuffid='40' and stufftitle='COMPLATIONRATESIXMONTH' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '41','INVOICEAMOUNTYEAR','chart','Invoice' from dual
where not exists(select 1 from ld_stuff where stuffid='41' and stufftitle='INVOICEAMOUNTYEAR' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '42','OUTBOUNDORDERAMOUNTYEAR','chart','OutboundOrder' from dual
where not exists(select 1 from ld_stuff where stuffid='42' and stufftitle='OUTBOUNDORDERAMOUNTYEAR' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '43','日程管理','calendar','Calendar' from dual
where not exists(select 1 from ld_stuff where stuffid='43' and stufftitle IN ('日程管理','Calendar') and stufftype='calendar');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '44','StatisticsPotentialsBySalesPersonAndSalesStage','chart','SalesGoal' from dual
where not exists(select 1 from ld_stuff where stuffid='44' and stufftitle='StatisticsPotentialsBySalesPersonAndSalesStage' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '45','StatisticalPotentialsByTheAccountIndustryAndSalesStage','chart','Accounts,Potentials' from dual
where not exists(select 1 from ld_stuff where stuffid='45' and stufftitle='StatisticalPotentialsByTheAccountIndustryAndSalesStage' and stufftype='chart');
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '60','ProductsSalesRanking','default','SalesOrder,Products' from dual
where not exists(select 1 from ld_stuff where stuffid='60' and stufftitle='ProductsSalesRanking' and stufftype='default');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','homeboard_Page_layout','页面布局','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='homeboard_Page_layout' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','homeboard_Page_layout','Page layout','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='homeboard_Page_layout' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','upper_left_right_Layout','上左右布局','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='upper_left_right_Layout' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','upper_left_right_Layout','Layout of upper , left and right column area','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='upper_left_right_Layout' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','upper_left_right_Layout_width_ratio','页面上的上栏区，左栏区和右栏区，左右宽比为','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='upper_left_right_Layout_width_ratio' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','upper_left_right_Layout_width_ratio','The upper ,  left and the right column area on the page, where the left  and the right column area have a left to right width ratio of','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='upper_left_right_Layout_width_ratio' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Component_Settings','组件设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Component_Settings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Component_Settings','Component Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Component_Settings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Search_Component_Name','搜索组件名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Search_Component_Name' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Search_Component_Name','Search Component Name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Search_Component_Name' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Preset_components','预设组件','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Preset_components' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Preset_components','Preset components','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Preset_components' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','New_Data_Kanban','新增数据看板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='New_Data_Kanban' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','New_Data_Kanban','New Data Kanban','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='New_Data_Kanban' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Management_Data_Kanban','管理数据看板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Management_Data_Kanban' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Management_Data_Kanban','Management Data Kanban','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Management_Data_Kanban' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Default_Kanban','默认看板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Default_Kanban' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Default_Kanban','Default Kanban','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Default_Kanban' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPONENTHEIGHT','组件高度','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPONENTHEIGHT' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPONENTHEIGHT','Component height','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPONENTHEIGHT' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPONENTNOTCONFIGURED','该组件暂无配置','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPONENTNOTCONFIGURED' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPONENTNOTCONFIGURED','This component is not currently configured','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPONENTNOTCONFIGURED' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPONENTCHNAME','组件中文名称','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPONENTCHNAME' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPONENTCHNAME','Component Chinese Name','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPONENTCHNAME' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPONENTENNAME','组件英文名称','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPONENTENNAME' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPONENTENNAME','Component English Name','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPONENTENNAME' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Setquerytimedefault','设置查询时间默认值','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Setquerytimedefault' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Setquerytimedefault','Set query time default','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Setquerytimedefault' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Setapprovalstatusdefault','审批状态默认值设置','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Setapprovalstatusdefault' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Setapprovalstatusdefault','Default value setting of approval status','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Setapprovalstatusdefault' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Unapproved','未提交','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Unapproved' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Unapproved','Not submitted','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Unapproved' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Approvalof','审批中','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Approvalof' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Approvalof','Approving','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Approvalof' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Approvals','审批通过','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Approvals' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Approvals','Approval','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Approvals' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Rejected','已拒绝','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Rejected' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Rejected','Rejected','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Rejected' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Dismissed','已驳回','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Dismissed' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Dismissed','Dismissed','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Dismissed' and Labeltype='jspop' and languagetype='en');
delimiter;

set @link_old = "index.php?module=Settings&action=listtemplate&parenttab=Settings";
set @link_new = "index.php?module=Home&action=HomeAjax&file=HomeboardListview&from_module=Settings";
update ld_settings_field set linkto = @link_new where `name` = 'LBL_TEMPLATES' and linkto = @link_old;
delimiter;

update ld_field set bigtype='users'  where fieldname='assigned_user_id' and tablename like '%ld_customform%';
delimiter;



drop PROCEDURE  if EXISTS update_validatarule;
delimiter ||
create PROCEDURE update_validatarule
(
)
BEGIN
	declare var_validataid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT id from ld_validatasave where validatasavetype = 'php' and isshowlist = 'no' AND IFNULL(validatasavemainid,0) = 0;

	declare continue handler  for not   found  SET done =1;
	
	open cur1;
	Fetch cur1 into var_validataid;
	loop1: while  done<>1 DO
				INSERT into ld_validatasavemain(rulename,module,`status`,actionprevent,tipzh,tipen,conditiongroup,validataapplication,relatedtable,sequence,isshowlist)
				SELECT rulename,module,`status`,case when allowsave = 'no' then 'yes' ELSE 'no' END,tipzh,tipen,'',validatacheckbutton,relatedtable,sequence,'no' from ld_validatasave where id = var_validataid;
				SELECT MAX(id) into @max_mainid from ld_validatasavemain;

				UPDATE ld_validatasave SET conditiongroupid = 1,validatasavemainid = @max_mainid where id = var_validataid;
				Fetch cur1 into var_validataid;
	end while loop1;
	close cur1;
end ||
delimiter;

call update_validatarule();
drop PROCEDURE if EXISTS update_validatarule;

delimiter;


DROP PROCEDURE IF EXISTS `addcustomformadvance`;
delimiter ||
CREATE PROCEDURE `addcustomformadvance`(
)
BEGIN

	declare i int default 101;

	WHILE i<=160 DO
	SET @tmptablename=CONCAT('ld_customform',i);
	SET @tmpfieldname='assigned_user_id';

    UPDATE ld_field SET advance_demand='null####[null,{"groupid":"1","columnname":"ld_users:status:status:Users_状态:V","comparator":"e","value":"Active","columncondition":""}]',advance_demand_groups='All####[null,{"groupcondition":""}]' where fieldname=@tmpfieldname and tablename=@tmptablename;

    SET i=i+1;
    END WHILE;

end ||
delimiter;

call addcustomformadvance();
DROP PROCEDURE IF EXISTS `addcustomformadvance`;
delimiter ;

UPDATE ld_desk SET fieldlabel='条记录' where labelbol='RECORDS' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='records' where labelbol='RECORDS' and languagetype='en' and Labeltype='jspop';
delimiter;
-- 2023-03-31

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

UPDATE ld_version SET old_version='V8.4.9.5',current_version='V8.4.9.5',remark='V8.4.9.5-20230331',wx_version='V8.4.9.3';
delimiter;