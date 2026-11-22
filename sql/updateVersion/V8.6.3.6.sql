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
CREATE PROCEDURE `addtableIndex`(tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50))
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

SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='actual_amount_paid' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'pretax_salary_total'},{'lettervar':'b','column':'individual_income_tax'},{'lettervar':'c','column':'otherpayable_subtotal'}]}",
	'a-b+c',
	'',
	NOW(),
	NOW();
delimiter;
-- 2024-05-14

UPDATE ld_holiday SET wheatherholidays=1 WHERE holiday_title LIKE '%补假';
delimiter;

UPDATE ld_field SET uitype=15,typeofdata='V~O',bigtype='picklist' WHERE tablename='ld_holiday' AND columnname='wheatherholidays';
INSERT INTO ld_picklist_set(listname,relatetable,picklist_allowedit,picklist_allowdelete)
SELECT 'wheatherholidays','ld_field','no','no' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_set WHERE listname='wheatherholidays');

SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='wheatherholidays' ORDER BY listid DESC LIMIT 1);
INSERT INTO ld_picklist_values(listid,listvalue,pick_color)
SELECT @listid,'班','#FF0000' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue='班');

INSERT INTO ld_picklist_values(listid,listvalue,pick_color)
SELECT @listid,'休','#0000FF' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue='休');
delimiter;

ALTER TABLE ld_holiday MODIFY COLUMN wheatherholidays VARCHAR(10);
UPDATE ld_holiday SET wheatherholidays='休' WHERE wheatherholidays=0;
UPDATE ld_holiday SET wheatherholidays='班' WHERE wheatherholidays=1;
UPDATE ld_holiday SET wheatherholidays='班' WHERE holiday_title LIKE '%补假';
delimiter;

 	

UPDATE ld_systems_deploy SET roottype=4,sequence=-100 WHERE deploy_type=51;

SET @i=0;
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=4 ORDER BY sequence;
delimiter;

UPDATE ld_customreport_info 
SET 
	report_name=REPLACE(report_name,'——','_')
WHERE report_template IN ('default_performance_bycashbill.mrt','default_performance_byorder.mrt');

SET @report_name='项目提成表';
SET @report_type='template_js';
SET @report_template='default_performance_project.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT analysisfolder_id FROM ld_customreport_info WHERE report_template='default_performance_bycashbill.mrt' LIMIT 1);
SET @folderid=(SELECT folder_id FROM ld_customreport_info WHERE report_template='default_performance_bycashbill.mrt' LIMIT 1);
SET @seq=IFNULL((SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id),0);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,analysisfolder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype,createdtime)
SELECT @folderid,@id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink',NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);

SET @i=0;
SET @seq=(SELECT sequence FROM ld_customreport_info WHERE folder_id=@folderid AND report_template='default_performance_bycashbill.mrt');
UPDATE ld_customreport_info SET sequence=sequence+10 WHERE folder_id=@folderid AND sequence>@seq;
UPDATE ld_customreport_info SET sequence=@seq+2 WHERE report_template='default_performance_project.mrt';
UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@folderid ORDER BY sequence;
delimiter;
-- 2024-05-20

set @tabid = (SELECT tabid FROM ld_tab WHERE NAME = 'Salary');
set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_SALARYOTHERPAYABLE_INFO');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '其他应发' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Other Salaries payable' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);
delimiter;

set @tabid = (SELECT tabid FROM ld_tab WHERE NAME = 'Collectionslip');
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='collectionslip_time' LIMIT 1);
update ld_tranlabel SET fieldlabel='领取时间' WHERE Relateid=@relateid AND trantable='ld_field' AND languagetype='zh' AND fieldlabel='领取事件';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOCREATEPAYMENTPLANTIP','，已自动生成{$PaymentPlan.PaymentPlan}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOCREATEPAYMENTPLANTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOCREATEPAYMENTPLANTIP',', automatically generated {$PaymentPlan.PaymentPlan}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOCREATEPAYMENTPLANTIP' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOCREATESENDPAYMENTTIP','，已自动生成{$SendPayment.SendPayment}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOCREATESENDPAYMENTTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOCREATESENDPAYMENTTIP',', automatically generated {$SendPayment.SendPayment}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOCREATESENDPAYMENTTIP' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_field','word_watermark','VARCHAR','10','no');
CALL AddColumn('ld_field','excel_watermark','VARCHAR','10','no');
CALL AddColumn('ld_attachments','watermark','VARCHAR','10','no');
CALL AddColumn('ld_attachmentsforbillsdetails','watermark','VARCHAR','10','no');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_attachments_watermark_setting` (
    `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增id',
    `module` varchar(50) DEFAULT NULL COMMENT '模块',
    `fieldname` varchar(50) DEFAULT NULL COMMENT '字段名',
    `type` varchar(20) DEFAULT NULL COMMENT 'word/excel',
    `image_watermark` varchar(20) DEFAULT 'no' COMMENT '图片水印是否开启',
    `text_watermark` varchar(20) DEFAULT 'no' COMMENT '文字水印是否开启',
    `content` text DEFAULT NULL COMMENT '文字水印内容模版',
    `image_name` varchar(100) DEFAULT NULL COMMENT '文字水印内容模版',
    `image_path` text DEFAULT NULL COMMENT '文字水印内容模版',
    `image_newfilename` varchar(100) DEFAULT NULL COMMENT '文字水印内容模版',
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WORDWATERMARK','上传Word文件添加水印','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WORDWATERMARK' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WORDWATERMARK',"Upload Word file to add watermark",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WORDWATERMARK' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXCELWATERMARK','上传Excel文件添加水印','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'EXCELWATERMARK' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXCELWATERMARK','Upload Excel file to add watermark','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'EXCELWATERMARK' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETWATERMARK','设置水印','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SETWATERMARK' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETWATERMARK','Set watermark','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SETWATERMARK' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETWATERMARKTIP','请先保存字段后再进行设置！','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SETWATERMARKTIP' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETWATERMARKTIP','Set watermark','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SETWATERMARKTIP' and languagetype='en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WATERMARKSETTING','水印设置','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WATERMARKSETTING' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WATERMARKSETTING','Watermark Setting','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WATERMARKSETTING' and languagetype='en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WATERMARKSETTING','水印设置','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WATERMARKSETTING' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WATERMARKSETTING','Watermark Setting','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WATERMARKSETTING' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PICTUREWATERMARK','图片水印','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'PICTUREWATERMARK' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PICTUREWATERMARK','Picture watermark','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'PICTUREWATERMARK' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TEXTWATERMARK','文字水印','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'TEXTWATERMARK' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TEXTWATERMARK','Text watermark','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'TEXTWATERMARK' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Choosepictures','选择图片','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'Choosepictures' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Choosepictures','Choose pictures','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'Choosepictures' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WILDCARD','通配符','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WILDCARD' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WILDCARD','Wildcard','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WILDCARD' and languagetype='en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ONEIMAGECANBEUPLOADED','只能上传一张图片','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ONEIMAGECANBEUPLOADED' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ONEIMAGECANBEUPLOADED','Only one image can be uploaded','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ONEIMAGECANBEUPLOADED' and languagetype='en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ONEIMAGECANBEUPLOADED','只能上传一张图片','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ONEIMAGECANBEUPLOADED' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ONEIMAGECANBEUPLOADED','Only one image can be uploaded','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ONEIMAGECANBEUPLOADED' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

CALL AddColumn('ld_workreport_remind','push_to_fw','int','2',0);
CALL AddColumn('ld_workreport_remind','push_time_fw','datetime',null,null );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXCELADDWATERMARKTIP','添加水印只支持xlsx后缀文件','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'EXCELADDWATERMARKTIP' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXCELADDWATERMARKTIP','add watermarks only support xlsx suffix files','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'EXCELADDWATERMARKTIP' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','insert','插入','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'insert' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','insert','Insert','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'insert' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTENTTEMPLATECANNOTEMPTY','内容模版不能为空！','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CONTENTTEMPLATECANNOTEMPTY' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTENTTEMPLATECANNOTEMPTY','The content template cannot be empty!','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CONTENTTEMPLATECANNOTEMPTY' and languagetype='en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IMAGECANNOTEMPTY','图片选择不能为空！','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'IMAGECANNOTEMPTY' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IMAGECANNOTEMPTY','Select picture cannot be empty!','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'IMAGECANNOTEMPTY' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RECORDINGPERMISSIONMANAGEMENT','录音权限管理','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'RECORDINGPERMISSIONMANAGEMENT' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RECORDINGPERMISSIONMANAGEMENT','Recording permission management','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'RECORDINGPERMISSIONMANAGEMENT' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ABOUT','关于','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ABOUT' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ABOUT','About','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ABOUT' and languagetype='en' and labeltype = 'fixedstr');
delimiter;


UPDATE ld_account a
LEFT JOIN (
	SELECT
		accountid,
		MAX(id) AS max_id
	FROM ld_logpublicaccount
	GROUP BY accountid
) b ON b.accountid=a.accountid
LEFT JOIN ld_logpublicaccount c ON c.id=b.max_id
SET a.pool_id=c.pool_id
WHERE a.publicaccount>0
	AND a.pool_id=0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WORDADDWATERMARKTIP','添加水印只支持docx后缀文件','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WORDADDWATERMARKTIP' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WORDADDWATERMARKTIP','Word documents only support docx suffix files','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WORDADDWATERMARKTIP' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = '请从左侧双击/拖拽简报至此处' WHERE labelbol = 'dragmodule' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Please double-click / drag the left saleskit to here' WHERE labelbol = 'dragmodule' AND languagetype = 'en';
UPDATE ld_desk SET fieldlabel = '请从左侧双击/拖拽报表组件至此处' WHERE labelbol = 'dragstuff' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Please double-click / drag or double-click the stuff from the left to this point' WHERE labelbol = 'dragstuff' AND languagetype = 'en';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SCREENVIEW','分屏视图','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SCREENVIEW' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SCREENVIEW','Split screen view','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SCREENVIEW' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SCREENVIEWTIP','请从左边选择一个报表','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SCREENVIEWTIP' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SCREENVIEWTIP','Please select a report from the left side','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SCREENVIEWTIP' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SCREENVIEWTIP','请从左边选择一个报表','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SCREENVIEWTIP' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SCREENVIEWTIP','Please select a report from the left side','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SCREENVIEWTIP' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_appsystem','is_open','varchar','10',' ');
call AddColumn('ld_appsystem','name','varchar','255',' ');
call AddColumn('ld_appsystem','sequence','int','11','0');
call AddColumn('ld_appsystem','module','varchar','255',' ');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',4,'是否显示销售助手','no' ,'',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=4);

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'超过N天没有跟进的客户','no' ,'Accounts',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Accounts');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'预计N天内成交的销售机会','no' ,'Potentials',1 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Potentials');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'N天内需要收款的回款计划','no' ,'PaymentPlan',2 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='PaymentPlan');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'N天内将到期的服务合同','no' ,'ServiceContracts',3 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='ServiceContracts');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'最近N天将要过生日的联系人','no' ,'Contacts',4 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Contacts');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',6,'是否显示关键视图','no' ,'',6 from dual
where not exists(select 1 from ld_appsystem where deploy_type=6 and description='是否显示关键视图');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds');
delete from ld_field where tabid=@tabid and columnname='team_memberid';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BELONG','属于','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BELONG' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BELONG','Belong','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BELONG' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','NOTBELONG','不属于','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'NOTBELONG' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','NOTBELONG','Not Belong','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'NOTBELONG' AND labeltype = 'fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = '全部已读' WHERE labelbol = 'SetAllAsRead' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'All read' WHERE labelbol = 'SetAllAsRead' AND languagetype = 'en';
delimiter;

UPDATE ld_systems_deploy SET description="设置计算已开票金额时是否统计未审批的销售发票和采购发票" WHERE deploy_type=463;
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder_exec`(
)
BEGIN


    IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkdaily LIKE '%:%')  THEN
SELECT count(1) into @cnt FROM ld_reminds WHERE  DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE()
                                            and content LIKE '日志提交提醒：%'  and reltab='CooperativeWork' ;
if @cnt=0 and EXISTS(SELECT 1 FROM ld_tab WHERE `name`='CooperativeWork' AND presence IN(0,2))
						then
            CALL task_cooperativework_dailyreport_reminder();
UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkdaily_eventreminder';
end if;
END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_weekreport_reminder_exec`(
)
BEGIN

    IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkweek>=3)   THEN

SELECT count(1) into @cnt FROM ld_reminds WHERE  DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE()
                                            and content LIKE '周计划提交提醒：%'  and reltab='CooperativeWork' ;
if @cnt=0 and EXISTS(SELECT 1 FROM ld_tab WHERE `name`='CooperativeWork' AND presence IN(0,2))
				then
            CALL task_cooperativework_weekreport_reminder();
UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkweek_eventreminder';
end if;

END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `task_cooperativework_monthreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_monthreport_reminder_exec`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkmonth>=3) AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>NOW() AND type='task_cooperativeworkmonth_eventreminder')  THEN

SELECT count(1) into @cnt FROM ld_reminds WHERE  DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE()
                                            and content LIKE '月计划提交提醒：%'  and reltab='CooperativeWork' ;
if @cnt=0 and EXISTS(SELECT 1 FROM ld_tab WHERE `name`='CooperativeWork' AND presence IN(0,2))
			then
				CALL task_cooperativework_monthreport_reminder();
UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkmonth_eventreminder';
end if;
END IF;

end ||
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 'no',570,'分页组件，是否显示GO按钮','',100011,1,'select',1,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 570);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateTemplate','新建模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateTemplate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateTemplate','Create template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateTemplate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateWordTemplate','新建Word模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateWordTemplate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateWordTemplate','Create Word template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateWordTemplate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateExcelTemplate','新建Excel模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateExcelTemplate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateExcelTemplate','Create Excel template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateExcelTemplate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UploadTemplate','上传模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UploadTemplate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UploadTemplate','Upload Template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UploadTemplate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UploadPrintTemplate','上传打印模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UploadPrintTemplate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UploadPrintTemplate','Upload Print Template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UploadPrintTemplate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UploadPrintTemplate','上传打印模板','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='UploadPrintTemplate' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UploadPrintTemplate','Upload Print Template','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='UploadPrintTemplate' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CopyInformationToTemplateAndUpload','复制系统中的变量信息到Word模板中，然后再上传Word模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CopyInformationToTemplateAndUpload' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CopyInformationToTemplateAndUpload','Copy the variable information from the system to the Word template, and then upload the Word template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CopyInformationToTemplateAndUpload' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CopyInformationToExcelTemplateAndUpload','复制系统中的变量信息到Excel模板中，然后再上传Excel模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CopyInformationToExcelTemplateAndUpload' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CopyInformationToExcelTemplateAndUpload','Copy the variable information from the system to the Excel template, and then upload the Excel template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CopyInformationToExcelTemplateAndUpload' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PresetTemplateDeleted','预置模板不存在或已被删除','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PresetTemplateDeleted' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PresetTemplateDeleted','The preset template does not exist or has been deleted','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PresetTemplateDeleted' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UploadTemplateCannotEmpty','上传模板不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='UploadTemplateCannotEmpty' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UploadTemplateCannotEmpty','The upload template cannot be empty!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='UploadTemplateCannotEmpty' and Labeltype='jspop' and languagetype='en');
delimiter;

CALL AddColumn('ld_templateprint','originalfilename','varchar','100','');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportToXLSFormat','导出成XLS格式','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ExportToXLSFormat' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportToXLSFormat','Export to XLS format','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ExportToXLSFormat' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SendEmailAddXLS','发送邮件并添加XLS格式附件','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SendEmailAddXLS' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SendEmailAddXLS','Send email and attach as XLS','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SendEmailAddXLS' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportToXLSFormat','导出成XLS格式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExportToXLSFormat' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportToXLSFormat','Export to XLS format','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExportToXLSFormat' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SendEmailAddXLS','发送邮件并添加XLS格式附件','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SendEmailAddXLS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SendEmailAddXLS','Send email and attach as XLS','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SendEmailAddXLS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CALL AddColumn('ld_reminds_agenda','dingtalk_agendadata','text','','');
CALL AddColumn('ld_users','dingtalk_unionid','varchar','100','');
ALTER TABLE ld_users MODIFY COLUMN dingtalk_unionid varchar(100) AFTER dingtalk_userid;
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','RecentBrowsingReport','最近浏览的报表记录','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'RecentBrowsingReport' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','RecentBrowsingReport','Recent browsing report records','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'RecentBrowsingReport' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','RecentBrowsingReport','最近浏览的报表记录','jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'RecentBrowsingReport' AND labeltype = 'jspop');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','RecentBrowsingReport','Recent browsing report records','jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'RecentBrowsingReport' AND labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SourceFileFormat','源文件格式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SourceFileFormat' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SourceFileFormat','Source file format','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SourceFileFormat' and Labeltype='fixedstr' and languagetype='en');
delimiter;

select max(tabsequence) into @tabsequence from ld_tab;
insert into ld_tab (tabid,name,presence,tabsequence)
select -13,'CallRecord',1,@tabsequence+1 from dual 
where not exists(select 1 from ld_tab where name='CallRecord' AND tabid = -13);
delimiter;

insert into ld_tranlabel(languagetype,relateid,trantable,tabid,fieldlabel)
select 'zh','-13','ld_tab' ,'-13' ,'通话记录' from dual 
where not exists(select 1 from ld_tranlabel where tabid=-13 and relateid=-13 and trantable='ld_tab' and languagetype='zh');

insert into ld_tranlabel(languagetype,relateid,trantable,tabid,fieldlabel)
select 'en','-13','ld_tab' ,'-13' ,'Call Records' from dual 
where not exists(select 1 from ld_tranlabel where tabid=-13 and relateid=-13 and trantable='ld_tab' and languagetype='en');
delimiter;

SET @tabid = (SELECT tabid FROM ld_tab WHERE `name`='SendCashBill');
update ld_tranlabel set fieldlabel='源单金额'
WHERE languagetype='zh' AND trantable='ld_tabdetailfield' AND tabid=@tabid AND Relateid in ( select tabdetailfieldid FROM ld_tabdetailfield  WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额') AND fieldlabel='合同金额';
update ld_tranlabel set fieldlabel='Contract amount'
WHERE languagetype='en' AND trantable='ld_tabdetailfield' AND tabid=@tabid AND Relateid in (select tabdetailfieldid FROM ld_tabdetailfield  WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额') AND fieldlabel='合同金额';
update ld_tabdetailfield set fieldlabel='源单金额' WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额';
delimiter;
SET @tabid = (SELECT tabid FROM ld_tab WHERE `name`='CashBill');
update ld_tranlabel set fieldlabel='源单金额'
WHERE languagetype='zh' AND trantable='ld_tabdetailfield' AND tabid=@tabid AND Relateid in (select tabdetailfieldid FROM ld_tabdetailfield  WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额') AND fieldlabel='合同金额';
update ld_tranlabel set fieldlabel='Contract amount'
WHERE languagetype='en' AND trantable='ld_tabdetailfield' AND tabid=@tabid AND Relateid in (select tabdetailfieldid FROM ld_tabdetailfield  WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额') AND fieldlabel='合同金额';
update ld_tabdetailfield set fieldlabel='源单金额' WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额';
delimiter;

select usereportid into @parent_id from ld_usereport where `name`='CourseEnquiryReport';
delete from ld_usereport where parent_id=@parent_id;
delimiter;

UPDATE ld_relatedlists SET buttonstatus = 'no' WHERE `related_tabid` = 142 AND label = 'Singin';
delimiter;

UPDATE ld_relatedlists SET `name` = 'get_singin_list',type = 'entitytype_datacategory_sql',related_coltable = 'tmpsourcedetail.id',related_advanceset = '[{"columnname":"tmpsourcedetail.id","comparator":"e","columncondition":""}]'
WHERE `related_tabid` = 142 AND label = 'Singin' AND `name` = 'get_singin';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WillDeleteLogWhetherContinue','当前变更将会删除{Var}个月前的日志留存，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WillDeleteLogWhetherContinue' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WillDeleteLogWhetherContinue','The current change will delete the log retention from {Var} months ago.Do you want to continue?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WillDeleteLogWhetherContinue' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_systems_deploy SET description="审批通过后计算已开票金额" WHERE deploy_type=463;
UPDATE ld_tranlabel SET fieldlabel='设置{$Invoice.Invoice}或{$PurchaseInvoice.PurchaseInvoice}审批通过后计算已开票金额' WHERE trantable='ld_systems_deploy' AND Relateid=463 AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel = 'Set calculating have_invoicetotal after the approval of {$Invoice.Invoice} or {$PurchaseInvoice.PurchaseInvoice}' WHERE languagetype = 'en' and trantable ='ld_systems_deploy' and tabid = 463 and relateid=463;
delimiter;
-- 2024-05-26

UPDATE ld_desk set fieldlabel='导出成Word格式' WHERE labelbol='ExporttoPDF' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Export to Word format' WHERE labelbol='ExporttoPDF' and languagetype='en' and Labeltype='fixedstr';
delimiter;

UPDATE ld_desk set fieldlabel='导出成Excel格式' WHERE labelbol='ExportToXLSFormat' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Export to Excel format' WHERE labelbol='ExportToXLSFormat' and languagetype='en' and Labeltype='fixedstr';
delimiter;

UPDATE ld_desk set fieldlabel='导出成Excel格式' WHERE labelbol='ExportToXLSFormat' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk set fieldlabel='Export to Excel format' WHERE labelbol='ExportToXLSFormat' and languagetype='en' and Labeltype='jspop';
delimiter;

UPDATE ld_desk set fieldlabel='发送邮件并添加Word格式附件' WHERE labelbol='Send_Email_Add_DOC' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Send email and attach as Word' WHERE labelbol='Send_Email_Add_DOC' and languagetype='en';
delimiter;

UPDATE ld_desk set fieldlabel='发送邮件并添加Excel格式附件' WHERE labelbol='SendEmailAddXLS' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Send email and attach as Excel' WHERE labelbol='SendEmailAddXLS' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportToPDFNeedInstallOpenOffice','导出成pdf格式，若要与模板显示样式一致，需在服务器上安装openoffice插件','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ExportToPDFNeedInstallOpenOffice' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportToPDFNeedInstallOpenOffice','Export to PDF format. To match the template display style, install the OpenOffice plugin on the server','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ExportToPDFNeedInstallOpenOffice' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXCELWATERMARKDOWNLOADTIP','添加水印只支持xlsx后缀文件，且仅下载时才有','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXCELWATERMARKDOWNLOADTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXCELWATERMARKDOWNLOADTIP',"Adding a watermark only supports xlsx suffix files and is available only when downloading",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXCELWATERMARKDOWNLOADTIP' and labeltype='fixedstr');
delimiter;
-- 2024-05-27


SET @stufftitle = 'IncomeAndExpenditureReport';
set @stuffid=65;
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule,pc_show,mobile_show)
select @stuffid,@stufftitle,'saleskit','','','no','no' from dual
where not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');
delimiter;


SET @stufftitle = 'IncomeAndExpenditureReport';
set @stuffid=65;
update ld_homestuffdetail set
                              daterange='ld_purchaseorder:createdtime:createdtime:PurchaseOrder_fieldlabel:DT' ,
                              viewrange='ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V',
                              compute_module='PurchaseOrder'
where stufflabel='TotalPurchaseContractAmount' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');


update ld_homestuffdetail set
                              daterange='ld_commission:createdtime:createdtime:Commission_fieldlabel:DT' ,
                              viewrange='ld_commission:smownerid:assigned_user_id:Commission_fieldlabel:V',
                              compute_module='Commission'
where stufflabel='TotalCommissionBill' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_sendcashbill:createdtime:createdtime:SendCashBill_fieldlabel:DT' ,
                              viewrange='ld_sendcashbill:smownerid:assigned_user_id:SendCashBill_fieldlabel:V',
                              compute_module='SendCashBill'
where stufflabel='TotalAmountPaid' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_expense:createdtime:createdtime:Expense_fieldlabel:DT' ,
                              viewrange='ld_expense:smownerid:assigned_user_id:Expense_fieldlabel:V',
                              compute_module='Expense'
where stufflabel='TotalAmountOfExpenseReimbursement' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_cashbill:createdtime:createdtime:CashBill_fieldlabel:DT' ,
                              viewrange='ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V',
                              compute_module='CashBill'
where stufflabel='ServiceContractsTotalReceived' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_servicecontracts:createdtime:createdtime:ServiceContracts_fieldlabel:DT' ,
                              viewrange='ld_servicecontracts:smownerid:assigned_user_id:ServiceContracts_fieldlabel:V',
                              compute_module='ServiceContracts'
where stufflabel='ServiceContractsTotalBalanceReceivable' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_servicecontracts:createdtime:createdtime:ServiceContracts_fieldlabel:DT' ,
                              viewrange='ld_servicecontracts:smownerid:assigned_user_id:ServiceContracts_fieldlabel:V',
                              compute_module='ServiceContracts'
where stufflabel='ServiceContractsHaveNotReceived' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_cashbill:createdtime:createdtime:CashBill_fieldlabel:DT' ,
                              viewrange='ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V',
                              compute_module='CashBill'
where stufflabel='SalesorderTotalReceived' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_salesorder:createdtime:createdtime:SalesOrder_fieldlabel:DT' ,
                              viewrange='ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V',
                              compute_module='SalesOrder'
where stufflabel='SalesorderTotalBalanceReceivable' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_salesorder:createdtime:createdtime:SalesOrder_fieldlabel:DT' ,
                              viewrange='ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V',
                              compute_module='SalesOrder'
where stufflabel='SalesorderHaveNotReceived' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_invoice:createdtime:createdtime:Invoice_fieldlabel:DT' ,
                              viewrange='ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V',
                              compute_module='Invoice'
where stufflabel='SalesInvoicedAmount' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_purchaseback::createdtime:createdtime:PurchaseBack_fieldlabel:DT' ,
                              viewrange='ld_purchaseback:smownerid:assigned_user_id:PurchaseBack_fieldlabel:V',
                              compute_module='PurchaseBack'
where stufflabel='RefundAmount' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_purchaseinvoice::createdtime:createdtime:PurchaseInvoice_fieldlabel:DT' ,
                              viewrange='ld_purchaseinvoice:smownerid:assigned_user_id:PurchaseInvoice_fieldlabel:V',
                              compute_module='PurchaseInvoice'
where stufflabel='PurchaseInvoicedAmount' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_purchaseorder:createdtime:createdtime:PurchaseOrder_fieldlabel:DT' ,
                              viewrange='ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V',
                              compute_module='PurchaseOrder'
where stufflabel='PurchaseBalancePayable' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_customform16:createdtime:createdtime:CustomForm16_fieldlabel:DT' ,
                              viewrange='ld_customform16:smownerid:assigned_user_id:CustomForm16_fieldlabel:V',
                              compute_module='CustomForm16'
where stufflabel='ProjectOutputValueConfirmationSheetAmount' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_customform15:createdtime:createdtime:CustomForm15_fieldlabel:DT' ,
                              viewrange='ld_customform15:smownerid:assigned_user_id:CustomForm15_fieldlabel:V',
                              compute_module='CustomForm15'
where stufflabel='PlannedQuantities' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_customform15:createdtime:createdtime:CustomForm15_fieldlabel:DT' ,
                              viewrange='ld_customform15:smownerid:assigned_user_id:CustomForm15_fieldlabel:V',
                              compute_module='CustomForm15'
where stufflabel='PlannedOutputValue' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_purchaseback:createdtime:createdtime:PurchaseBack_fieldlabel:DT' ,
                              viewrange='ld_purchaseback:smownerid:assigned_user_id:PurchaseBack_fieldlabel:V',
                              compute_module='PurchaseBack'
where stufflabel='HaveRefundAmount' and stuffid=@stuffid
  and not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');


delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHBELONGTIP','多个值用|隔开','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SEARCHBELONGTIP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHBELONGTIP','Multiple values separated by |','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SEARCHBELONGTIP' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTTOOLFIELDSAVETIP','该字段将添加到所有含产品分录的模块分录中，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRODUCTTOOLFIELDSAVETIP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTTOOLFIELDSAVETIP',"This field will be added to all module entries containing product entries. Do you want to continue?",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRODUCTTOOLFIELDSAVETIP' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DATABASECOLUMNNAME','数据库列名','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'DATABASECOLUMNNAME' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DATABASECOLUMNNAME','Database Column Names','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'DATABASECOLUMNNAME' and languagetype='en' and labeltype = 'fixedstr');
delimiter;


DROP PROCEDURE IF EXISTS `AddIdColumntoparenttabrel`;
delimiter ||
CREATE PROCEDURE `AddIdColumntoparenttabrel`(
)
BEGIN
    DECLARE field_exists INT;
    DECLARE current_db VARCHAR(64);

    SELECT DATABASE() INTO current_db;

    SELECT COUNT(*)
    INTO field_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = current_db
    AND TABLE_NAME = 'ld_parenttabrel'
    AND COLUMN_NAME = 'id';

    IF field_exists = 0 THEN
        SET @query = CONCAT('ALTER TABLE `', current_db, '`.ld_parenttabrel ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
end ||
delimiter;

CALL AddIdColumntoparenttabrel();
DROP PROCEDURE IF EXISTS `AddIdColumntoparenttabrel`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CommonFunctions','常用功能','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CommonFunctions' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CommonFunctions','Common Functions','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CommonFunctions' and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @blockid = (select blockid from ld_settings_blocks where label = 'LBI_UI_SETTINGS');
select max(fieldid) into @maxfieldid from ld_settings_field ;
select sequence into @sequence from ld_settings_field where `name` = 'LBL_LOGIN_SETTINGS';
update ld_settings_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_settings_field where  blockid=@blockid and `name`='ld_leftmenu_ui_setting');
set @have = 0;
select count(fieldid) into @have from ld_settings_field where blockid=@blockid and `name`='ld_leftmenu_ui_setting';
update ld_settings_field set sequence = sequence+1 where @have <= 0 and sequence >= @sequence;
insert into ld_settings_field(fieldid,blockid,`name`,description,linkto,sequence,active)
select @maxfieldid+1,@blockid,'ld_leftmenu_ui_setting','ld_leftmenu_ui_setting','index.php?module=Settings&action=leftmenuuisetting&mode=listview&parenttab=Settings',@sequence,0
from dual where not exists(select 1 from ld_settings_field where  blockid=@blockid and `name`='ld_leftmenu_ui_setting');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence)
select '1',476,'菜单样式定制','',0,0,'text',0 from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 476);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_leftmenu_ui_setting','网页菜单交互定制','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ld_leftmenu_ui_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_leftmenu_ui_setting','Customization of webpage menu interaction','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ld_leftmenu_ui_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleasetrynewkeywords','请尝试搜索其他关键词','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasetrynewkeywords' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleasetrynewkeywords','Please try searching for other keywords','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasetrynewkeywords' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','nofindcontentwithworkbefore','没找到与','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='nofindcontentwithworkbefore' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','nofindcontentwithworkbefore','No matching results found for the ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='nofindcontentwithworkbefore' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','nofindcontentwithworkafter','匹配的结果','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='nofindcontentwithworkafter' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','nofindcontentwithworkafter','','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='nofindcontentwithworkafter' and Labeltype='jspop' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CollapseNavigation','收起导航','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CollapseNavigation' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CollapseNavigation','Collapse Navigation','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CollapseNavigation' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CollapseNavigation','收起导航','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CollapseNavigation' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CollapseNavigation','Collapse Navigation','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CollapseNavigation' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExpandNavigation','展开导航','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ExpandNavigation' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExpandNavigation','Expand Navigation','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ExpandNavigation' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 'yes',478,'部门编号字段启用状态' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=478 );
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 'yes',477,'部门备注字段启用状态' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=477 );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETFIELD','设置字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETFIELD' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETFIELD','Set Field','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETFIELD' and labeltype='jspop');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription,validatasavetype)
select 'AddJobBill','ld_tabdetailfield','starttime','m','小于等于','js' from dual
where not exists(select 1 from ld_validatasave where module='AddJobBill' and relatedtable='ld_tabdetailfield' and fieldname='starttime');
delimiter;
select id into @relateid from ld_validatasave where module='AddJobBill' and relatedtable='ld_tabdetailfield' and fieldname='starttime';
insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','endtime',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid);
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription,validatasavetype)
select 'ExpenseBudget','ld_field','budget_start_date','m','小于等于','js' from dual
where not exists(select 1 from ld_validatasave where module='ExpenseBudget' and relatedtable='ld_field' and fieldname='budget_start_date');
delimiter;
select id into @relateid from ld_validatasave where module='ExpenseBudget' and relatedtable='ld_field' and fieldname='budget_start_date';
insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','budget_end_date',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid);
delimiter;

update ld_tranlabel set fieldlabel='设置当模块有关联的单据时是否允许删除' where trantable='ld_systems_deploy' and Relateid=69 and languagetype='zh';
update ld_tranlabel set fieldlabel='Whether to allow the users to delete the orders that related to modules existed' where trantable='ld_systems_deploy' and Relateid=69 and languagetype='en';
delimiter;

SET @labelbol = 'LINGDANGHUOKE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'灵当获客',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Lingdang captures guests',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'SharedUsers';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'共享人',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Shared Users',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

set @tabid = (SELECT tabid from ld_tab where name = 'CollectionSlip');
UPDATE ld_tabdetailfield set defaultcolumn = 0 where tabid = @tabid and columnname = 'line_project_id';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateHTMLTemplate','新建HTML模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateHTMLTemplate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateHTMLTemplate','Create HTML template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateHTMLTemplate' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2024-05-30

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

UPDATE ld_version SET old_version='V8.6.3.6',current_version='V8.6.3.6',remark='V8.6.3.6-20240530',wx_version='V8.6.3.6';
delimiter;