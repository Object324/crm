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
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);

		CALl AddColumn(@tablename,'approvesubmitter','INT','19',0);
		CALl AddColumn(@tablename,'approvesubmittedtime','DATETIME','',0);
		CALl AddColumn(@tablename,'currentapprovestepid','INT','19',0);

		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvestatus'; 
		SET @fieldname='approvestatus'; 
		SET @zh='审批状态'; 
		SET @en='Approve status'; 
		SET @uitype=609; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'approvestatus','VARCHAR','50','未提交');


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approveby'; 
		SET @fieldname='approveby'; 
		SET @zh='上一步审批人'; 
		SET @en='Approve By'; 
		SET @uitype=131; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'approveby','INT','19',NULL);


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='currentapprover'; 
		SET @fieldname='currentapprover'; 
		SET @zh='当前审批人'; 
		SET @en='Current Approver'; 
		SET @uitype=132; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'currentapprover','TEXT','100',NULL);


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvetime'; 
		SET @fieldname='approvetime'; 
		SET @zh='最新审批时间'; 
		SET @en='Last Approve Time'; 
		SET @uitype=70; 
		SET @typeofdata='DT~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'approvetime','DATETIME','','0');

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);


		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 1,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);



		SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
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

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,'fileattachment' from dual
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
		SELECT @maxnum_id+1,tmp_modulename,CONCAT('ZDYBD',REPLACE(tmp_modulename,'CustomForm',''),'-'),1,1,1,'none',0,1,0 FROM DUAL
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
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2 FROM DUAL
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


		SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
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


DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_61to100`;
delimiter ||
CREATE PROCEDURE `ldcrm_addcustomform_61to100`(
)
BEGIN

	declare i int default 61; 

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

	WHILE i<=100 DO 
		IF NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=CONCAT('CustomForm',i)) THEN
			-- 添加模块
			CALL ldcrm_add_module_withoutdetail(CONCAT('CustomForm',i),CONCAT('自定义表单',i),CONCAT('Custom Form ',i),@myparenttabid);

			-- 添加审批流程
			CALL ldcrm_add_approveforbill(CONCAT('CustomForm',i),220+i);
			CALL AddColumn(CONCAT('ld_',LOWER('CustomForm'),i),'advance_stage','VARCHAR','100','');
			CALL AddColumn(CONCAT('ld_',LOWER('CustomForm'),i),'kis_id','int','11',0);
			CALL AddColumn(CONCAT('ld_',LOWER('CustomForm'),i),'kis_no','varchar','50',NULL);
		END IF;
		SET i=i+1;
	END WHILE;

end ||
delimiter;

CALL ldcrm_addcustomform_61to100();
DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_61to100`;
DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
DROP PROCEDURE IF EXISTS `ldcrm_add_module_withoutdetail`;
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
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);

		CALl AddColumn(@tablename,'approvesubmitter','INT','19',0);
		CALl AddColumn(@tablename,'approvesubmittedtime','DATETIME','',0);
		CALl AddColumn(@tablename,'currentapprovestepid','INT','19',0);

		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvestatus'; 
		SET @fieldname='approvestatus'; 
		SET @zh='审批状态'; 
		SET @en='Approve status'; 
		SET @uitype=609; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'approvestatus','VARCHAR','50','未提交');


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approveby'; 
		SET @fieldname='approveby'; 
		SET @zh='上一步审批人'; 
		SET @en='Approve By'; 
		SET @uitype=131; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'approveby','INT','19',NULL);


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='currentapprover'; 
		SET @fieldname='currentapprover'; 
		SET @zh='当前审批人'; 
		SET @en='Current Approver'; 
		SET @uitype=132; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'currentapprover','TEXT','100',NULL);


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvetime'; 
		SET @fieldname='approvetime'; 
		SET @zh='最新审批时间'; 
		SET @en='Last Approve Time'; 
		SET @uitype=70; 
		SET @typeofdata='DT~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'approvetime','DATETIME','','0');

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);


		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 1,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);



		SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
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

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,'fileattachment' from dual
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
		SELECT @maxnum_id+1,tmp_modulename,getPY(tmp_zhmoudulename),1,1,1,'none',0,1,0 FROM DUAL
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
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2 FROM DUAL
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


		SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
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


DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_61to100`;
delimiter ||
CREATE PROCEDURE `ldcrm_addcustomform_61to100`(
)
BEGIN

	declare i int default 61; 

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

	WHILE i<=100 DO 
		IF NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=CONCAT('CustomForm',i)) THEN
			-- 添加模块
			CALL ldcrm_add_module_withoutdetail(CONCAT('CustomForm',i),CONCAT('自定义表单',i),CONCAT('Custom Form ',i),@myparenttabid);

			-- 添加审批流程
			CALL ldcrm_add_approveforbill(CONCAT('CustomForm',i),220+i);
			CALL AddColumn(CONCAT('ld_',LOWER('CustomForm'),i),'advance_stage','VARCHAR','100','');
			CALL AddColumn(CONCAT('ld_',LOWER('CustomForm'),i),'kis_id','int','11',0);
			CALL AddColumn(CONCAT('ld_',LOWER('CustomForm'),i),'kis_no','varchar','50',NULL);
		END IF;
		SET i=i+1;
	END WHILE;

end ||
delimiter;

CALL ldcrm_addcustomform_61to100();
DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_61to100`;
DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
DROP PROCEDURE IF EXISTS `ldcrm_add_module_withoutdetail`;
delimiter;

SET @i=0;
UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence; 

SET @tabsequence=(SELECT tabsequence FROM ld_tab WHERE `name`='CustomForm60' LIMIT 1);
UPDATE ld_tab SET tabsequence=tabsequence+100 WHERE tabsequence>@tabsequence;
UPDATE ld_tab SET tabsequence=(@tabsequence:=@tabsequence+1) WHERE `name` LIKE 'CustomForm%' AND REPLACE(`name`,'CustomForm','')+0>=61 ORDER BY tabid;

SET @i=0;
UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence; 


UPDATE ld_modentity_num 
SET prefix=CONCAT(prefix,'-')
WHERE semodule LIKE 'CustomForm%' AND REPLACE(semodule,'CustomForm','')+0>60 AND cur_id=1 AND RIGHT(prefix,1)<>'-';

drop PROCEDURE if EXISTS `AddDownloadPrivewProfileByTabid`;
delimiter ||
create PROCEDURE AddDownloadPrivewProfileByTabid(ttabid int(19))
begin
	
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @tabid=ttabid;
set @sql =concat('select tabid into @attachmenttabid from ld_tab where name="Attachment"');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;

	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
				 select actionid into @downloadoperation from ld_actionmapping where actionname='download';
		   		select actionid into @previewoperation from ld_actionmapping where actionname='preview';
					select  permissions into @permissions from ld_profile2standardpermissions where profileid=pprofileid and tabid=@attachmenttabid and operation=@downloadoperation ;
				SET @permissions=IFNULL(@permissions,'-1');					
				if @permissions='-1' THEN
								set 	done=1;
									
					end if;
			set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',@downloadoperation,',',@permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@downloadoperation,')' );
				  prepare stmt from @sql;
			  	execute stmt;

			   deallocate prepare stmt;
				select  permissions into @permissions from ld_profile2standardpermissions where profileid=pprofileid and  tabid=@attachmenttabid and operation=@previewoperation ;

				 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',@previewoperation,',',@permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@previewoperation,')' );
				  prepare stmt from @sql;
			  	execute stmt;
			   deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE if EXISTS `AddDownloadPrivewButtonForAllModules`;
delimiter ||
create PROCEDURE AddDownloadPrivewButtonForAllModules()
begin
	
	declare done  int  default 0;
	declare ttabid  int ;
	declare cur2 CURSOR FOR 
	select 
		ld_tab.tabid 
	from ld_tab 
	inner join ld_field  on ld_field.tabid=ld_tab.tabid 
	inner join ld_profileallpermission on ld_profileallpermission.tabid=ld_tab.tabid and ld_profileallpermission.operation=1
	where ld_tab.name!="Attachment" and ld_tab.name!="Reminds" and ld_tab.name!="Emails" and ld_tab.tabid!=16 
		AND ld_tab.name LIKE 'CustomForm%' AND REPLACE(ld_tab.name,'CustomForm','')+0>60
	group by ld_tab.tabid;
	declare continue handler  for not   found  SET done =1;


	OPEN cur2;
	Fetch cur2 into ttabid;
   select actionid into @downloadoperation from ld_actionmapping where actionname='download';
		select actionid into @previewoperation from ld_actionmapping where actionname='preview';

	 loop1: while  done<>1 DO
				select max(sequence) into @sequence from ld_profileallpermission where tabid=ttabid ;
			  set @sequence=IFNULL(@sequence,'-1');
				if @sequence<>'-1' then 
						set @sql=CONCAT('insert into ld_profileallpermission(tabid,operation,sequence) select  ' ,ttabid,',',@downloadoperation,',',@sequence+1,'  from dual  where not exists (select 1 from ld_profileallpermission where tabid=',ttabid ,' and operation=',@downloadoperation,' )' );
				
							prepare stmt from @sql;
							execute stmt;

						 deallocate prepare stmt;
					
					
							set @sql=CONCAT('insert into ld_profileallpermission(tabid,operation,sequence) select  ' ,ttabid,',',@previewoperation,',',@sequence+2,'  from dual  where not exists (select 1 from ld_profileallpermission where tabid=',ttabid ,' and operation=',@previewoperation,' )' );
							prepare stmt from @sql;
							execute stmt;

						 deallocate prepare stmt;
						call AddDownloadPrivewProfileByTabid(ttabid);
				 end if ;
				Fetch cur2 into ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

CALL AddDownloadPrivewButtonForAllModules();
DROP PROCEDURE if EXISTS `AddDownloadPrivewProfileByTabid`;
DROP PROCEDURE if EXISTS `AddDownloadPrivewButtonForAllModules`;
delimiter;

UPDATE ld_desk SET fieldlabel='自动带出所选源单的分录明细' WHERE labelbol='AutoWithProductDetail' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='控制“{columnname}”不允许超出源单' WHERE labelbol='StrictSourceBillColumn' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='The {columnname} amount is not allowed to exceed the tax-inclusive amount of the order' WHERE labelbol='StrictSourceBillColumn' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel="电子名片" where labelbol="CARDQRCODE" and languagetype="zh";
update ld_desk set fieldlabel="Electronic business card" where labelbol="CARDQRCODE" and languagetype="en";
update ld_desk set fieldlabel="Electronic business card" where labelbol="CARDQRCODEELECTRIC" and languagetype="en";
delimiter;

update ld_organizationdetails set menustyle='dark',menuback_color='#18223d',menuhover_color='#2490f8' WHERE IFNULL(menustyle,'')='';
delimiter;

update ld_tabdetailfield set savedatabase = 'yes' where columnname in ('source_total','due_date','received_amount');
delimiter;
-- 2021-04-06

SET @module='Expense';
SET @select_module='BusinessApply';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module LIMIT 1);
SET @select_tabid=(SELECT tabid FROM ld_tab WHERE `name`=@select_module LIMIT 1);
SET @select_seq=(SELECT COUNT(1) FROM ld_option_module WHERE tabid=@tabid);
SET @select_tabseq=(SELECT tabsequence FROM ld_tab WHERE `name`=@select_module);
INSERT INTO ld_option_module(tabid,option_tabid,presence,approve_demand,sequence,table_sequence,datarang,fieldname,maxrowsshow)
SELECT @tabid,@select_tabid,0,0,@select_seq+1,@select_tabseq,'all',NULL,5 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@select_tabid);
delimiter;

SET @module='BusinessApply';
SET @related_module='Expense';
SET @actions='add';
SET @datatype='datacategory_sql';
SET @relatedcoltable='expensedetail.entitytypeid';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module);
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`=@related_module);
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @relation_id+1,@tabid,@rel_tabid,CONCAT('get_',LOWER(@related_module)),@seq+1,@related_module,0,@actions,@datatype,@relatedcoltable FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND label=@related_module);

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

DROP PROCEDURE IF EXISTS `lingdang_add_profile2standardpermissions`;
delimiter ||
CREATE PROCEDURE `lingdang_add_profile2standardpermissions`(
	tmp_tabid INT(19),
	tmp_addactionid INT(19),
	tmp_permissions INT(19)
)
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;
	DECLARE THIS_CUSOR CURSOR FOR SELECT profileid FROM ld_profile;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	OPEN THIS_CUSOR; 
	FETCH THIS_CUSOR INTO tmp_profileid;
	WHILE(tmp_profileid IS NOT NULL) DO

		INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions) 
		SELECT tmp_profileid,tmp_tabid,tmp_addactionid,IF(tmp_permissions>=1,1,0) FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE profileid=tmp_profileid AND tabid=tmp_tabid AND operation=tmp_addactionid);

		IF tmp_addactionid=(SELECT actionid FROM ld_actionmapping WHERE actionname='Advance' LIMIT 1) THEN
			SET @i=0;
			UPDATE ld_profile2standardpermissions SET sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND profileid=tmp_profileid ORDER BY operation;
		END IF;
		FETCH THIS_CUSOR INTO tmp_profileid;
	END WHILE;
	CLOSE THIS_CUSOR;

END ||
delimiter;


DROP PROCEDURE if EXISTS `lingdang_add_profileallpermission`;
delimiter ||
CREATE PROCEDURE `lingdang_add_profileallpermission`(
	tmp_actionid INT(19)
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT tabid FROM ld_tab WHERE `name` LIKE 'CustomForm%' AND REPLACE(`name`,'CustomForm','')+0>60;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;
		
	IF tmp_actionid>0 THEN
		OPEN MYCUSOR; 
		FETCH MYCUSOR INTO tmp_id;
		WHILE(tmp_id IS NOT NULL) DO
			SET @sequence=IFNULL((SELECT MAX(sequence) FROM ld_profileallpermission WHERE tabid=tmp_id),0);
			INSERT INTO ld_profileallpermission(tabid,operation,sequence)
			SELECT tmp_id,tmp_actionid,@sequence+1 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=tmp_id AND operation=tmp_actionid);
			CALL lingdang_add_profile2standardpermissions(tmp_id,tmp_actionid,0);
			FETCH MYCUSOR INTO tmp_id;
		END WHILE;
		CLOSE MYCUSOR;
	END IF;

END ||
delimiter;


SET @myactionid=(SELECT actionid FROM ld_actionmapping WHERE actionname='DownloadSelected' LIMIT 1);
CALL lingdang_add_profileallpermission(@myactionid);

SET @myactionid=(SELECT actionid FROM ld_actionmapping WHERE actionname='Advance' LIMIT 1);
CALL lingdang_add_profileallpermission(@myactionid);
DROP PROCEDURE IF EXISTS `lingdang_add_profile2standardpermissions`;
DROP PROCEDURE if EXISTS `lingdang_add_profileallpermission`;
delimiter;

DROP PROCEDURE IF EXISTS `lingdang_reset_profile2standardpermissions`;
delimiter ||
CREATE PROCEDURE `lingdang_reset_profile2standardpermissions`(
	tmp_tabid INT(19)
)
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;
	DECLARE THIS_CUSOR CURSOR FOR SELECT profileid FROM ld_profile;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	OPEN THIS_CUSOR; 
	FETCH THIS_CUSOR INTO tmp_profileid;
	WHILE(tmp_profileid IS NOT NULL) DO
		IF (SELECT permissions FROM ld_profile2standardpermissions WHERE tabid=tmp_tabid AND profileid=tmp_profileid ANd operation=1 LIMIT 1)=1 THEN
			UPDATE ld_profile2standardpermissions SET permissions=1 WHERE tabid=tmp_tabid AND profileid=tmp_profileid ANd operation IN (SELECT actionid FROM ld_actionmapping WHERE actionname IN ('FileReadHistory','DownloadSelected','Advance','DownLoad'));
		END IF;
		FETCH THIS_CUSOR INTO tmp_profileid;
	END WHILE;
	CLOSE THIS_CUSOR;

END ||
delimiter;


DROP PROCEDURE if EXISTS `lingdang_reset_profileallpermission`;
delimiter ||
CREATE PROCEDURE `lingdang_reset_profileallpermission`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT tabid FROM ld_tab WHERE `name` LIKE 'CustomForm%' AND REPLACE(`name`,'CustomForm','')+0 BETWEEN 1 AND 100 ORDER BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;
		

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
        SET @i=0;
        UPDATE ld_profileallpermission SET sequence=(@i:=@i+1) WHERE tabid=tmp_id ORDER BY FIELD(operation,3,4,11,1,2,12,13,14,5,6,25,37,22,49,42,43,50);
		CALL lingdang_reset_profile2standardpermissions(tmp_id);
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;


END ||
delimiter;

CALL lingdang_reset_profileallpermission();
DROP PROCEDURE if EXISTS `lingdang_reset_profileallpermission`;
DROP PROCEDURE IF EXISTS `lingdang_reset_profile2standardpermissions`;
delimiter;
-- 2021-04-08


DROP PROCEDURE IF EXISTS `ldcrm_relatedaccount_forcustomform`;
delimiter ||
CREATE PROCEDURE `ldcrm_relatedaccount_forcustomform`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_modulename VARCHAR(100) DEFAULT '';
	DECLARE tmp_tablename VARCHAR(100) DEFAULT '';
	DECLARE tmp_block INT(19) DEFAULT 0;
	
	DECLARE MYCUSOR_ADDFIELD CURSOR FOR 
						SELECT 
							b.tabid,
							a.`name` AS modulename,
							b.tablename,
							b.block
						FROM ld_tab a
						LEFT JOIN ld_field b ON a.tabid=b.tabid
						WHERE a.`name` LIKE 'CustomForm%'
							AND b.columnname='accountid'
							AND REPLACE(`name`,'CustomForm','')+0>60
						ORDER BY a.tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR_ADDFIELD; 
	FETCH MYCUSOR_ADDFIELD INTO tmp_id,tmp_modulename,tmp_tablename,tmp_block;
	WHILE(tmp_id IS NOT NULL) DO


		SET @module='Accounts';
		SET @related_module=tmp_modulename;
		SET @actions='add';
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module);
		SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`=@related_module);
		SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
		SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
		SELECT @relation_id+1,@tabid,@rel_tabid,CONCAT('get_',LOWER(@related_module)),@seq+1,@related_module,1,@actions,'datacategory_sql',CONCAT(LOWER(@related_module),'.accountid') FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND label=@related_module);

		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

		FETCH MYCUSOR_ADDFIELD INTO tmp_id,tmp_modulename,tmp_tablename,tmp_block;
	END WHILE;
	CLOSE MYCUSOR_ADDFIELD;

END ||
delimiter;

CALL ldcrm_relatedaccount_forcustomform();
DROP PROCEDURE IF EXISTS `ldcrm_relatedaccount_forcustomform`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_orgshare_forcustomform`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_orgshare_forcustomform`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE MYCUSOR_ADDFIELD CURSOR FOR 
						SELECT 
							tabid
						FROM ld_tab
						WHERE tabid>(SELECT tabid FROM ld_tab WHERE `name`='CustomForm60')
						ORDER BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR_ADDFIELD; 
	FETCH MYCUSOR_ADDFIELD INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 0,tmp_id FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_id AND share_action_id=0);

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 1,tmp_id FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_id AND share_action_id=1);
		
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 2,tmp_id FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_id AND share_action_id=2);

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 3,tmp_id FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_id AND share_action_id=3);

		FETCH MYCUSOR_ADDFIELD INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR_ADDFIELD;

END ||
delimiter;

CALL ldcrm_reset_orgshare_forcustomform();
DROP PROCEDURE IF EXISTS `ldcrm_reset_orgshare_forcustomform`;
delimiter;

update ld_tabdetailfield set savedatabase = 'yes' where columnname in ('source_total','due_date','received_amount');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','key_word','关键词','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='key_word' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','key_word','Keywords','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='key_word' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','relationship','关系','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='relationship' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','relationship','relationship','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='relationship' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','statisticalGraphics','统计图','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='statisticalGraphics' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','statisticalGraphics','statistical graphics','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='statisticalGraphics' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','base','基础','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='base' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','base','base','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='base' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','data','数据','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='data' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','data','data','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='data' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2021-04-09

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

UPDATE ld_version SET old_version='V8.4.2.2',current_version='V8.4.2.2',remark='V8.4.2.2-20210409',wx_version='V8.4.2.2';
delimiter;