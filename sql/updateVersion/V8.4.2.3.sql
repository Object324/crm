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

SET @add_actionname='FileReadHistory';
SET @max_actionid=(SELECT MAX(actionid) FROM ld_actionmapping);
INSERT INTO ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT @max_actionid+1,@add_actionname,0,UPPER(@add_actionname) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname=@add_actionname);
delimiter;

SET @labelbol=UPPER('FileReadHistory');
SET @labeltype='fixedstr';
SET @zh='查看下载和预览次数';
SET @en='View download and preview times';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol=@labelbol AND labeltype=@labeltype);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol=@labelbol AND labeltype=@labeltype);

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
	DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT tabid FROM ld_field WHERE columnname='filename' OR tabid IN (SELECT tabid FROM ld_tab WHERE name IN ('Leads','Articles')) ORDER BY tabid;
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

SET @my_actionid=(SELECT actionid FROM ld_actionmapping WHERE actionname='FileReadHistory' LIMIT 1);
CALL lingdang_add_profileallpermission(@my_actionid);
DROP PROCEDURE if EXISTS `lingdang_add_profileallpermission`;
DROP PROCEDURE IF EXISTS `lingdang_add_profile2standardpermissions`;
delimiter;


CREATE TABLE IF NOT EXISTS `ld_fileoperationlog`(
   `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
   `tabid` int(11) DEFAULT NULL,
   `newfile_name` varchar(100) DEFAULT NULL COMMENT '同附件表',
   `operator` varchar(255) DEFAULT NULL COMMENT '操作人（当前登录角色用户的id）',
   `operating_type` varchar(25) DEFAULT NULL COMMENT '操作类型 download preview',
   `operating_time` timestamp NULL COMMENT '操作时间',
   `created_at` timestamp  DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
   PRIMARY KEY ( `id` )
)ENGINE=InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Frequency','次数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Frequency' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Frequency','Frequency','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Frequency' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DownloadOperationLog','下载操作日志','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DownloadOperationLog' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DownloadOperationLog','Download operation log','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DownloadOperationLog' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PreviewOperationLog','预览操作日志','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PreviewOperationLog' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PreviewOperationLog','Preview operation log','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PreviewOperationLog' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OperationTotalNumber','操作总次数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OperationTotalNumber' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OperationTotalNumber','Total number of operations','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OperationTotalNumber' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='下载和预览次数' WHERE labelbol='FileReadHistory' AND languagetype='zh';
-- 2021-04-12

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','qrcodetype','二维码类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='qrcodetype' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','qrcodetype','Qr code type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='qrcodetype' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','contentcode','内容码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='contentcode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','contentcode','content code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='contentcode' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','linkcode','链接码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='linkcode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','linkcode','link code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='linkcode' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Contentcustomization','内容定制','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Contentcustomization' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Contentcustomization','Content customization','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Contentcustomization' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CALl AddColumn('ld_customreport_chartset','show_percent','VARCHAR','50','no');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_qrcode_template` (
  `qrcodetemplateid` int(19) NOT NULL AUTO_INCREMENT,
  `template_content` text DEFAULT NULL,
  `fieldid` int(11) DEFAULT NULL,
  `qrcode_type` varchar(50) DEFAULT NULL,
  `replacespacevalue` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`qrcodetemplateid`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOCIALPROMOTIONQRCODE','二维码','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SOCIALPROMOTIONQRCODE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOCIALPROMOTIONQRCODE','Qr code','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SOCIALPROMOTIONQRCODE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,inputtype,presence,inputvalue)
select 'AutoGivenBillSourceBalance','321', '自动带出源单剩余数量或金额','select',1,'[{"value":"quantity","text":""},{"value":"tax_amount","text":""},{"sql":""}]' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=321);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AutoGivenBillSourceBalance','自动带出源单剩余','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AutoGivenBillSourceBalance' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AutoGivenBillSourceBalance','Automatically bring out the source document remaining','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AutoGivenBillSourceBalance' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_option_module','autobalancevalue','varchar',255,'');
delimiter;

select tabid into @tabid  from ld_tab where name='OutboundOrder';
select tabid into @option_tabid from ld_tab where name='SalesOrder';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
select tabid into @option_tabid from ld_tab where name='ServiceContracts';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
select tabid into @option_tabid from ld_tab where name='Invoice';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
select tabid into @option_tabid from ld_tab where name='Stock';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
delimiter;

select tabid into @tabid  from ld_tab where name='Stock';
select tabid into @option_tabid from ld_tab where name='PurchaseOrder';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
select tabid into @option_tabid from ld_tab where name='PurchaseInvoice';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
delimiter;

select tabid into @tabid  from ld_tab where name='Invoice';
select tabid into @option_tabid from ld_tab where name='SalesOrder';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
select tabid into @option_tabid from ld_tab where name='ServiceContracts';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
select tabid into @option_tabid from ld_tab where name='OutboundOrder';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
delimiter;

select tabid into @tabid  from ld_tab where name='PurchaseInvoice';
select tabid into @option_tabid from ld_tab where name='PurchaseOrder';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
select tabid into @option_tabid from ld_tab where name='Stock';
update ld_option_module set autobalancevalue='quantity' where tabid=@tabid and option_tabid=@option_tabid and ( autobalancevalue is null or autobalancevalue='');
delimiter;
-- 2021-04-13

select tabid into @tabid from ld_tab where name='salesorder';
update ld_field set typeofdata='N~O~25,2' where columnname='purchasecost' and tabid=@tabid;
delimiter;

UPDATE ld_field SET bigtype='date' WHERE uitype=5 AND IFNULL(bigtype,'')<>'date';
UPDATE ld_field SET bigtype='picklist' WHERE uitype=15 AND IFNULL(bigtype,'')<>'picklist';
UPDATE ld_field SET bigtype='datetime' WHERE uitype=86 AND IFNULL(bigtype,'')<>'datetime';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_WORKFLOWCUSTOMIZATION_SET','工作流程定制','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='LBL_WORKFLOWCUSTOMIZATION_SET' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_WORKFLOWCUSTOMIZATION_SET','工作流程定制','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='LBL_WORKFLOWCUSTOMIZATION_SET' and labeltype='fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label = 'LBL_PARAMETER_SETTINGS';
select sequence into @sequence from ld_settings_field where blockid = @blockid and `name` = 'LBL_AUTOMATICREMINDS_SET';
update ld_settings_field set sequence = sequence + 100 where blockid = @blockid and sequence >= @sequence;
select max(fieldid) + 1 into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,`name`,iconpath,description,linkto,sequence,active)
select @fieldid,@blockid,'LBL_WORKFLOWCUSTOMIZATION_SET','migrate.png','LBL_WORKFLOWCUSTOMIZATION_SET','index.php?module=Settings&action=WorkflowCustomizationList&parenttab=Settings',@sequence+1,0 from  DUAL
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'LBL_WORKFLOWCUSTOMIZATION_SET');
update ld_settings_field_seq set id = (select max(fieldid) from ld_settings_field);
SET @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid = @blockid order by sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_WORKFLOWCUSTOMIZATION_SET','工作流程定制','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='LBL_WORKFLOWCUSTOMIZATION_SET' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_WORKFLOWCUSTOMIZATION_SET','工作流程定制','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='LBL_WORKFLOWCUSTOMIZATION_SET' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WorkflowName','流程名称','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='WorkflowName' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WorkflowName','Workflow Name','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='WorkflowName' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TriggerTime','触发点','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='TriggerTime' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TriggerTime','Trigger Time','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='TriggerTime' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateWorkflowCustomization','新建工作流程','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='CreateWorkflowCustomization' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateWorkflowCustomization','Create WorkflowCustomization','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='CreateWorkflowCustomization' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WorkflowTrigger','触发器','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='WorkflowTrigger' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WorkflowTrigger','Workflow Trigger','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='WorkflowTrigger' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UpdatedIncludesCreation','编辑（包含新增）','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='UpdatedIncludesCreation' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UpdatedIncludesCreation','Updated(Includes Creation)','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='UpdatedIncludesCreation' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Onlyfirsttimeconditonsaremet','第一次满足触发条件时','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Onlyfirsttimeconditonsaremet' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Onlyfirsttimeconditonsaremet','Only first time conditons are met','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Onlyfirsttimeconditonsaremet' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Everytimeconditonsareme','每一次满足触发条件时','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Everytimeconditonsareme' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Everytimeconditonsareme','Every time conditons are me','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Everytimeconditonsareme' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ApprovalNode','审批节点','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='ApprovalNode' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ApprovalNode','Approval Node','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='ApprovalNode' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Rejected','审批拒绝','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Rejected' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Rejected','Rejected','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Rejected' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Dismissed1','审批驳回','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Dismissed1' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Dismissed1','Dismissed','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Dismissed1' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WorkflowActions','工作流操作','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='WorkflowActions' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WorkflowActions','Workflow Actions','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='WorkflowActions' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddAction','添加操作','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='AddAction' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddAction','Add Action','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='AddAction' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CallAPI','调用API','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='CallAPI' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CallAPI','Call API','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='CallAPI' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ActionTitle','操作描述','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='ActionTitle' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ActionTitle','Action Title','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='ActionTitle' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FieldVariables','字段变量','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='FieldVariables' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FieldVariables','Field Variables','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='FieldVariables' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SystemVariables','系统变量','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='SystemVariables' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SystemVariables','System Variables','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='SystemVariables' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ErpCode','ERP内码','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='ErpCode' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ErpCode','Erp Code','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='ErpCode' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CurrentTime','当前时间','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='CurrentTime' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CurrentTime','Current Time','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='CurrentTime' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Atleastoneapprovalnodemustbeselected','至少得选择一个审批节点！','jspop' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Atleastoneapprovalnodemustbeselected' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Atleastoneapprovalnodemustbeselected','At least one approval node must be selected!','jspop' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Atleastoneapprovalnodemustbeselected' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleaseaddworkflowoperation','请添加工作流操作！','jspop' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Pleaseaddworkflowoperation' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleaseaddworkflowoperation','Please add workflow operation!','jspop' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Pleaseaddworkflowoperation' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','loginmobile','登陆手机号码','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='loginmobile' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','loginmobile','Login mobile','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='loginmobile' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','loginpassword','登陆密码','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='loginpassword' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','loginpassword','Login password','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='loginpassword' and labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS`ld_workflow` (
  `id` int(11) NOT NULL,
  `tabid` int(11) DEFAULT NULL,
  `name` varchar(200) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `description` text,
  `triggertime` varchar(50) DEFAULT NULL,
  `repeatmode` varchar(50) DEFAULT NULL,
  `approvalnode` varchar(50) DEFAULT NULL,
  `deleted` int(1) DEFAULT '0',
  `createdtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_workflow_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `workflow_id` int(11) DEFAULT NULL,
  `action_title` text,
  `action_type` varchar(20) DEFAULT NULL,
  `api_url` text,
  `api_jsondata` text,
  `status` varchar(20) DEFAULT 'Active',
  `createdtime` datetime DEFAULT NULL,
  `deleted` int(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_workflow_api` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `api_name` varchar(255) DEFAULT NULL,
  `api_url` text,
  `client_id` varchar(50) DEFAULT NULL,
  `client_secret` text,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(50) DEFAULT NULL,
  `orgid` varchar(50) DEFAULT NULL,
  `dbname` varchar(100) DEFAULT NULL,
  `db_description` varchar(100) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_workflow_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_workflow_seq(id)
select 0 from DUAL where not exists(select 1 from ld_workflow_seq where id <= 0);
delimiter;
-- 2021-04-15

CALL AddColumn('ld_fileoperationlog','crmid','int','19',0);
delimiter;

DROP PROCEDURE IF EXISTS `execute_account_publicoperation`;
delimiter ||
CREATE PROCEDURE `execute_account_publicoperation`()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_account_public_pool where deleted = 0;
	declare continue handler  for not   found  SET done =1;
	if  EXISTS (SELECT 1 FROM ld_account_public WHERE STATUS = 'yes')  THEN
		if NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicaccount')  THEN
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicaccount';
			call account_singlerecycle_normal_rule();
			call account_singlerecycle_normal_rule_beforeremind();
			OPEN cur1;
				Fetch cur1 into tmp_pool_id;
					loop1: while  done<>1 DO
						call account_singlerecycle_highsea_rule(tmp_pool_id);
						call account_singlerecycle_highsea_rule_beforeremind(tmp_pool_id);
				Fetch cur1 into tmp_pool_id;
			end while loop1;
			close cur1;
		end if;
	end if;
end ||
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,inputtype,presence,inputvalue)
select '3','322', '设置系统登陆时密码连续输错次数','select',1,'[{"value":"3","text":"PwdErrorAllowTimes"}]' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=322);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PwdErrorAllowTimes','设置系统登陆时密码连续输错{n}次后，不允许登陆的限制时长（为空表示不限制时长，允许登陆）','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PwdErrorAllowTimes' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PwdErrorAllowTimes','Set the time limit for not allowed to log in if the password is continuous incorrectly typed for {n} times during system login (empty means no time limit and allowed to log in)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PwdErrorAllowTimes' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UserEmpty','空','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UserEmpty' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UserEmpty','Empty','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UserEmpty' and labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,inputtype,presence,inputvalue)
select '0','323', '设置系统登陆时密码连续输错时间限制','select',1,'[{"value":"0","text":"UserEmpty"},{"value":"30","text":"30"},{"value":"60","text":"60"},{"value":"90","text":"90"}]' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=323);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnlockSuccess','解锁成功！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UnlockSuccess' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnlockSuccess','Unlocking succeeded！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UnlockSuccess' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LoginControl','登录控制','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LoginControl' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LoginControl','Login to control','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LoginControl' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnlockUserAccount','解锁账号','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UnlockUserAccount' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnlockUserAccount','Unlock the account','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UnlockUserAccount' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnLock','解锁','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UnLock' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnLock','UnLock','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UnLock' and labeltype='fixedstr');
delimiter;

update ld_systems_deploy  set roottype=0 where deploy_type=90 or deploy_type=73 ;
delimiter;

CREATE TABLE if not exists  `ld_loginerror` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `logintime` datetime DEFAULT NULL,
  `userid` int(19) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AdminUnlockUser','您的密码连续输错{n}次已锁定，请联系管理员解锁账号或{minute}分钟后重试！','fixedstr' from  dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AdminUnlockUser' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AdminUnlockUser','Your password continuous input error {n} times has been locked. Please contact the admin to unlock your account or try again in {minute} minutes！','fixedstr' from  dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AdminUnlockUser' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnLockTheAccount','解除锁定账号','fixedstr' from  dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UnLockTheAccount' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnLockTheAccount','Unlock the account','fixedstr' from  dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UnLockTheAccount' and labeltype='fixedstr');
delimiter;

update ld_tabdetailfield set savedatabase='yes' where columnname='total';
delimiter;
-- 2021-04-16

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','mobileDetailCode','移动端单据详情码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='mobileDetailCode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','mobileDetailCode','Mobile terminal document detail code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='mobileDetailCode' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','useCrmScan','使用CRM扫一扫功能','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='useCrmScan' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','useCrmScan','Using CRM scan function','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='useCrmScan' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CALL AddColumn('ld_users','pwd_checkcondition','varchar',20,'yes');
delimiter;

update ld_users set pwd_checkcondition='yes' where pwd_checkcondition is null or  pwd_checkcondition='';
delimiter;


CALL AddColumn('ld_tabshare','viewuserduty','varchar','100',0);
delimiter;

CALL AddColumn('ld_tabshare','viewuserremark','text','',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Duty','职责','fixedstr' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='duty' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Duty','Duty','fixedstr' from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='duty' and labeltype='fixedstr');
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

DROP PROCEDURE IF EXISTS `ldcrm_add_teamownerid`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_teamownerid`(
)
BEGIN

	DECLARE tmp_moudule VARCHAR(100) DEFAULT '';
	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_block INT(19) DEFAULT 0;
	DECLARE tmp_seq INT(19) DEFAULT 0;
	DECLARE tmp_table VARCHAR(100) DEFAULT '';
	DECLARE tmp_tablekey VARCHAR(100) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR 
					SELECT 
						a.tabid,
						b.`name` AS moudule,
						a.block,
						a.sequence,
						a.tablename,
						(SELECT entityidfield FROM ld_entityname WHERE tabid=a.tabid LIMIT 1) AS tablekey
					FROM ld_field a
					LEFT JOIN ld_tab b ON b.tabid=a.tabid
					WHERE a.columnname='smownerid'
						AND a.tabid<>16
					ORDER BY a.tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id,tmp_moudule,tmp_block,tmp_seq,tmp_table,tmp_tablekey;
	WHILE(tmp_id IS NOT NULL) DO
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=tmp_id AND columnname='team_memberid') THEN
			SET @modulename=tmp_moudule;
			SET @tabid=IF(tmp_id=9,16,tmp_id);
			SET @relateid=tmp_block;
			SET @maxseq=tmp_seq;
			SET @trantable='ld_field';
			SET @tablename=tmp_table;
			SET @columnname='team_memberid'; 
			SET @fieldname='team_memberid'; 
			SET @zh='团队成员'; 
			SET @en='Team Members'; 
			SET @uitype=154; 
			SET @typeofdata='V~O';
			SET @quickcreate=1;
			SET @displaytype=1;
			SET @bigtype='text';
			SET @datarang=NULL;
			SET @maxrowsshow=0;

			UPDATE ld_field SET sequence=sequence+1 WHERE tabid=@tabid AND block=@relateid AND sequence>@maxseq;

			SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
			INSERT INTO ld_field(tabid,fieldid,columnname,tablename,allowhide,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
			SELECT @tabid,@maxid+1,@columnname,@tablename,'no',1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

			UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

			SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'TEXT',NULL,NULL);

			CALL getallprofile(@modulename);
			CALL fieldprofile(@modulename);

			-- 更新团队成员数据
			SET @this_sql="UPDATE  (
					SELECT 
						crmid,
						GROUP_CONCAT(viewuserid) AS teamownerid 
					FROM ld_tabshare 
					WHERE crmid IN (SELECT crmid FROM ld_crmentity WHERE setype='THIS_MODULE') 
					GROUP BY crmid
				) a
				INNER JOIN THIS_TABLE b ON b.THIS_TABKEY=a.crmid
				SET b.team_memberid=a.teamownerid";

			SET @this_sql=REPLACE(@this_sql,'THIS_MODULE',@modulename);
			SET @this_sql=REPLACE(@this_sql,'THIS_TABLE',@tablename);
			SET @this_sql=REPLACE(@this_sql,'THIS_TABKEY',tmp_tablekey);

			SET @disable_triggers=1;
			PREPARE exec_smt FROM @this_sql;
			EXECUTE exec_smt;
			DROP PREPARE exec_smt;
			SET @disable_triggers=NULL;
		END IF;

		FETCH MYCUSOR INTO tmp_id,tmp_moudule,tmp_block,tmp_seq,tmp_table,tmp_tablekey;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_add_teamownerid();
DROP PROCEDURE IF EXISTS `ldcrm_add_teamownerid`;
-- 2021-04-19

UPDATE ld_field SET allowhide='yes' WHERE columnname='team_memberid' AND uitype=154;

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

UPDATE ld_version SET old_version='V8.4.2.3',current_version='V8.4.2.3',remark='V8.4.2.3-20210419',wx_version='V8.4.2.3';
delimiter;