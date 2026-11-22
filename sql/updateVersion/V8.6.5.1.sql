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


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShouRowTotal','显示行合计','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShouRowTotal' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShouRowTotal',"Display row total",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShouRowTotal' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShouColumnTotal','显示列合计','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShouColumnTotal' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShouColumnTotal',"Display column total",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShouColumnTotal' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShouColumnTotalInchart','图表中显示列合计','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShouColumnTotalInchart' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShouColumnTotalInchart',"Display column total in the chart",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShouColumnTotalInchart' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShouTotalInchart','图表中显示合计','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShouTotalInchart' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShouTotalInchart',"Display the total in the chart",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShouTotalInchart' and labeltype='jspop');
delimiter;

CALL AddColumn('ld_customreport_chartset','show_rowtotal','varchar','20','no');
CALL AddColumn('ld_customreport_chartset','show_columntotal','varchar','20','no');
CALL AddColumn('ld_customreport_chartset','show_columntotal_inchart','varchar','20','no');
CALL AddColumn('ld_customreport_chartset','show_alltotal_inchart','varchar','20','no');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Products' LIMIT 1);
SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='manufacturer' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='制造商' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Manufacturer';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='sales_start_date' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='开始销售日期' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Sales Start Date';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='sales_end_date' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='停止销售日期' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Sales End Date';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='start_date' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='开始日期' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Support Start Date';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='expiry_date' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='过期日期' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Support Expiry Date';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='vendor_part_no' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='供应商部件编号' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Vendor PartNo';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='serialno' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='序列号' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Serial No';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='mfr_part_no' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='制造商部件编号' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Mfr PartNo';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='commissionrate' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='佣金率' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Commission Rate';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='reorderlevel' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='安全库存' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Reorder Level';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='qtyindemand' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='需求数量' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Qty In Demand';

SET @productsfieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='qty_per_unit' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='数量/单位' WHERE trantable='ld_field' AND tabid=@tabid AND relateid=@productsfieldid AND languagetype='zh' AND fieldlabel='Qty/Unit';
delimiter;

UPDATE ld_tabdetailfield a
LEFT JOIN ld_tranlabel b ON b.Relateid=a.tabdetailfieldid AND b.trantable='ld_tabdetailfield' AND b.languagetype='zh'
SET 
	a.fieldlabel='金额',
	b.fieldlabel='金额'
WHERE a.columnname='amount'
	AND a.tablename LIKE 'ld_customform%'
	AND b.fieldlabel='佣金';
delimiter;

DELETE FROM ld_tranlabel WHERE tabid=14 AND trantable='ld_field' AND Relateid IN (
	SELECT fieldid FROM ld_field WHERE tabid=14 AND columnname IN ('sales_start_date','sales_end_date','expiry_date','expiry_date','mfr_part_no','vendor_part_no','serial_no','manufacturer') AND presence=1
);
DELETE FROM ld_field WHERE tabid=14 AND columnname IN ('sales_start_date','sales_end_date','expiry_date','expiry_date','mfr_part_no','vendor_part_no','serial_no','manufacturer') AND presence=1;
delimiter;

set @sequence = (select max(sequence) from ld_systems_deploy where deploy_type = 465);
SET @maxcrmid = (SELECT IFNULL(MAX(crmid) ,0)  FROM ld_crmentity);
SET @deploy_value = (SELECT CASE  WHEN @maxcrmid>10 THEN  'yes' ELSE 'no' END);
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select @deploy_value,492,'设置计算预收单金额时是否统计未审批通过的预收单','',@sequence,1,'select',0,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 492);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',492,492,'设置计算预收单金额时是否统计未审批通过的预收单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
                                                         and trantable ='ld_systems_deploy' and tabid = 492 and relateid=492);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',492,492,'Set whether to count unapproved advance receipts when calculating the amount of advance receipts'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
                                                         and trantable ='ld_systems_deploy' and tabid = 492 and relateid=492);
delimiter;

set @sequence = (select max(sequence) from ld_systems_deploy where deploy_type = 465);
SET @maxcrmid = (SELECT IFNULL(MAX(crmid) ,0)  FROM ld_crmentity);
SET @deploy_value = (SELECT CASE  WHEN @maxcrmid>10 THEN  'no' ELSE 'yes' END);
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select @deploy_value,493,'设置预收单核销后不允许反审批','',@sequence,1,'select',0,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 493);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',493,493,'设置预收单核销后不允许反审批'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
                                                         and trantable ='ld_systems_deploy' and tabid = 493 and relateid=493);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',493,493,'Do not allow reverse approval after setting up advance receipts for write off'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
                                                         and trantable ='ld_systems_deploy' and tabid = 493 and relateid=493);
delimiter;
SET @i = 0;
update ld_systems_deploy set sequence = (@i := @i +1) WHERE roottype = 1 ORDER BY sequence,id;
delimiter;

SET @labelbol = 'UNAPPROVEDADVANCERECEIPTNOTWRITTEN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'预收单%s未审批通过，不允许核销','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Advance receipts %s have not been approved and cannot be written off','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ADVANCERECEIPTWRITTENOFFCANNOTUNAPPROVED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'预收单已被核销，不允许反审批!','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The advance receipt has been written off and cannot be unapproved!','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GETMAIL','获取邮件','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='GETMAIL' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GETMAIL','Get mail','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='GETMAIL' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GETTINGMAILINGLIST','正在获取邮件列表','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='GETTINGMAILINGLIST' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GETTINGMAILINGLIST','Getting mailing list','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='GETTINGMAILINGLIST' and Labeltype='jspop');
delimiter;

UPDATE ld_field set uitype = 1,bigtype = 'text' where parentbigtype = 'relatedpicklist' and relatedmodulefield = 'yes';
delimiter;


update ld_desk set fieldlabel='完成时间' where labelbol='Completiontime' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Completion time' where labelbol='Completiontime' and languagetype='en' and Labeltype='fixedstr';
delimiter;

SET @rel_module='ViewHistory';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CollectionSlip');
SET @rel_tabid=-7;
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT IFNULL(MAX(sequence),0) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template = 'get_viewhistory';
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,1,'','','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

SET @rel_module='OperationLogs';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CollectionSlip');
SET @rel_tabid=-19;
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT IFNULL(MAX(sequence),0) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template = 'get_operationlogs';
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,1,'','','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

update ld_customreport set sqlstr=REPLACE(sqlstr,'\'%2023%\'','CONCAT(\'%\',YEAR(NOW()),\'%\')') where ifnull(primaryname,'')<>'';
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','FORWARDING','转发', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'FORWARDING' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','FORWARDING','Forwarding', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'FORWARDING' AND labeltype = 'jspop' );
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_OrganizationConfig','https://www.51mis.com.cn/forum.php?mod=viewthread&tid=129&fromuid=1','公司信息' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_OrganizationConfig');
delimiter;

SET @labelbol = 'FeishuInterfaceSettings';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'飞书接口设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Feishu interface settings','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PCAccessAddress';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'PC端访问地址','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'PC access address','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MobileAccessAddress';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'移动端访问地址','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Mobile access address','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SELECT max(fieldid) into @fieldid from ld_settings_field;
SELECT max(sequence) into @sequence from ld_settings_field where `name`='zhiyuan_setting';
SELECT count(1) INTO @i FROM ld_settings_field WHERE `name` = 'FeishuInterfaceSettings';
UPDATE ld_settings_field SET sequence = sequence + 1 WHERE @i = 0 AND sequence > @sequence;
insert into ld_settings_field(fieldid,blockid,name,iconpath,linkto,sequence,active)
select @fieldid+1,8,'FeishuInterfaceSettings','picklistdependency.png','index.php?module=Settings&action=feishu_interface_setting&parenttab=Settings',@sequence+1,0 from DUAL
where @i = 0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RowTotal','行合计','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RowTotal' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RowTotal',"Row total",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RowTotal' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ColumnTotal','列合计','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ColumnTotal' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ColumnTotal',"Column total",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ColumnTotal' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','PerformTasks','执行任务', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'PerformTasks' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','PerformTasks','Perform tasks', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'PerformTasks' AND labeltype = 'jspop' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','ReviewLog','点评日志', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'ReviewLog' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','ReviewLog','Review Log', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'ReviewLog' AND labeltype = 'jspop' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','ReviewWeekPlan','点评周计划', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'ReviewWeekPlan' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','ReviewWeekPlan','Review week plan', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'ReviewWeekPlan' AND labeltype = 'jspop' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','ReviewMonthPlan','点评月计划', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'ReviewMonthPlan' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','ReviewMonthPlan','Review month plan', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'ReviewMonthPlan' AND labeltype = 'jspop' );
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','COMMENTAPP','点评','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','COMMENTAPP','Comment','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReportResults','汇报结果','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ReportResults' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReportResults',"Report Results",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ReportResults' and labeltype='jspop');
delimiter;

UPDATE ld_field SET label_style = '' WHERE label_style = '{"color":"#333333;"}';
UPDATE ld_field SET label_style = '' WHERE label_style = '{"color":"#333333"}';
UPDATE ld_field SET label_style = '' WHERE label_style = '{"color":"#666;"}';
UPDATE ld_field SET label_style = '' WHERE label_style = '{"color":"#666"}';
UPDATE ld_field SET label_style = '' WHERE label_style = '{"color":"#999;"}';
UPDATE ld_field SET label_style = '' WHERE label_style = '{"color":"#999"}';
delimiter;

UPDATE ld_field set bigtype = 'picklist' where columnname = 'approvestatus' and uitype = 15;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShouRowTotal','显示行合计','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShouRowTotal' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShouRowTotal',"Display row total",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShouRowTotal' and labeltype='jspop');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShouColumnTotal','显示列合计','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShouColumnTotal' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShouColumnTotal',"Display column total",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShouColumnTotal' and labeltype='jspop');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShouColumnTotalInchart','图表中显示列合计','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShouColumnTotalInchart' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShouColumnTotalInchart',"Display column total in the chart",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShouColumnTotalInchart' and labeltype='jspop');
delimiter;




insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShouTotalInchart','图表中显示合计','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShouTotalInchart' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShouTotalInchart',"Display the total in the chart",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShouTotalInchart' and labeltype='jspop');
delimiter;



CALL AddColumn('ld_customreport_chartset','show_rowtotal','varchar','20','no');
CALL AddColumn('ld_customreport_chartset','show_columntotal','varchar','20','no');
CALL AddColumn('ld_customreport_chartset','show_columntotal_inchart','varchar','20','no');
CALL AddColumn('ld_customreport_chartset','show_alltotal_inchart','varchar','20','no');
delimiter;


DROP PROCEDURE IF EXISTS `reset_key_20241225`;
delimiter ||
CREATE  PROCEDURE `reset_key_20241225`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_cashback' AND CONSTRAINT_NAME='ld_cashback_ibfk_1') THEN
		ALTER TABLE ld_cashback DROP FOREIGN KEY ld_cashback_ibfk_1;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_cashbackscf' AND CONSTRAINT_NAME='ld_cashbackscf_ibfk_1') THEN
		ALTER TABLE ld_cashbackscf DROP FOREIGN KEY ld_cashbackscf_ibfk_1;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_customview' AND CONSTRAINT_NAME='ld_customview_ibfk_1') THEN
		ALTER TABLE ld_customview DROP FOREIGN KEY ld_customview_ibfk_1;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_parenttabrel' AND CONSTRAINT_NAME='fk_1_vtiger_parenttabrel') THEN
		ALTER TABLE ld_parenttabrel DROP FOREIGN KEY fk_1_vtiger_parenttabrel;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_parenttabrel' AND CONSTRAINT_NAME='fk_2_vtiger_parenttabrel') THEN
		ALTER TABLE ld_parenttabrel DROP FOREIGN KEY fk_2_vtiger_parenttabrel;
	END IF;

end ||
delimiter;

CALL reset_key_20241225();
DROP PROCEDURE IF EXISTS `reset_key_20241225`;
delimiter;

UPDATE ld_producttoolfield SET presence = 1 WHERE columnname IN ('product_licence_price','cumulative_benefits') AND 1= (SELECT presence FROM ld_tab WHERE `name`= 'PricePolicy');
delimiter;


DROP PROCEDURE IF EXISTS `reset_prmparenttabrel_20241226`;
delimiter ||
CREATE  PROCEDURE `reset_prmparenttabrel_20241226`(
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM ld_prmparenttabrel) THEN
		INSERT INTO `ld_prmparenttabrel` (`id`, `tabid`, `sequence`, `tab_tablename`, `checkphp`, `isopeninblank`) VALUES ('1', '6', '1', 'ld_tab', NULL, NULL);
		INSERT INTO `ld_prmparenttabrel` (`id`, `tabid`, `sequence`, `tab_tablename`, `checkphp`, `isopeninblank`) VALUES ('2', '4', '2', 'ld_tab', NULL, NULL);
		INSERT INTO `ld_prmparenttabrel` (`id`, `tabid`, `sequence`, `tab_tablename`, `checkphp`, `isopeninblank`) VALUES ('3', '22', '3', 'ld_tab', NULL, NULL);
		INSERT INTO `ld_prmparenttabrel` (`id`, `tabid`, `sequence`, `tab_tablename`, `checkphp`, `isopeninblank`) VALUES ('4', '14', '4', 'ld_tab', NULL, NULL);
	END IF;

end ||
delimiter;

CALL reset_prmparenttabrel_20241226();
DROP PROCEDURE IF EXISTS `reset_prmparenttabrel_20241226`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RoleName2','角色名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RoleName2' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RoleName2','Role Name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RoleName2' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddRole','新增角色','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AddRole' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddRole','Add Role','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AddRole' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PermissionSettings','权限设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PermissionSettings' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PermissionSettings','Permission Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PermissionSettings' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetUsers','设置用户','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetUsers' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetUsers','Set Users','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetUsers' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SearchUsers','搜索用户','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SearchUsers' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SearchUsers','Search Users','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SearchUsers' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHMODULENAME','搜索模块名称','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHMODULENAME' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHMODULENAME','Search Module Name','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHMODULENAME' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EditRolename','编辑名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EditRolename' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EditRolename','Edit Rolename','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EditRolename' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EditRole','编辑角色','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EditRole' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EditRole','Edit Role','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EditRole' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CopyRole','复制角色','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CopyRole' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CopyRole','Copy Role','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CopyRole' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddUser','添加用户','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AddUser' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddUser','Add User','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AddUser' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SearchFieldname','搜索字段名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchFieldname' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SearchFieldname','Search field name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchFieldname' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SearchRolename','搜索角色名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchRolename' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SearchRolename','Search role name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchRolename' and labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk set fieldlabel='无效的权限ID，请指定一个有效的权限ID' WHERE labelbol='INVALIDPROFILEID' and languagetype='zh' and labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Authorize','授权','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Authorize' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Authorize','Authorize','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Authorize' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RevokePermissions','取消授权','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RevokePermissions' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RevokePermissions','Revoke permissions','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RevokePermissions' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTTHESELECTEDPERMISSIONS','全局快速授权','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SELECTTHESELECTEDPERMISSIONS' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTTHESELECTEDPERMISSIONS','Quickly authorize globally','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SELECTTHESELECTEDPERMISSIONS' and labeltype='fixedstr' and languagetype='en');
delimiter;

CALL AddColumn('ld_producttoolfield','selectpricefrombook','varchar','10','no');
update ld_producttoolfield set selectpricefrombook = 'no' where selectpricefrombook is null;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','selectPriceFromPriceBook','仅允许从价格表选择','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='selectPriceFromPriceBook' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','selectPriceFromPriceBook',"Only allow selection from the PriceBook",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='selectPriceFromPriceBook' and labeltype='fixedstr');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_SelfServiceConfigHome','https://www.51mis.com.cn/forum.php?mod=viewthread&tid=406','服务小程序登录首页设置' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_SelfServiceConfigHome');
delimiter;

SET @accountnum = (SELECT IFNULL(count(*) ,0)  FROM ld_account);
UPDATE ld_systems_deploy SET deploy_value = CASE WHEN @accountnum = 0 
	THEN 'part' 
	ELSE  deploy_value
END WHERE deploy_type = 61;
delimiter;

update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/1w8HY2vO' where label = 'HelpUrl_OrganizationConfig';
update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/jwVYtrbm' where label = 'HelpUrl_SelfServiceConfigHome';
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_ExternalContact','https://www.51mis.com.cn/forum.php?mod=viewthread&tid=374&fromuid=1','企业微信客户联系设置' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_ExternalContact');
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_CheckinSetting','https://www.51mis.com.cn/forum.php?mod=viewthread&tid=533&fromuid=1','考勤接口设置' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_CheckinSetting');
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_PhoneSteward','https://www.51mis.com.cn/forum.php?mod=viewthread&tid=372&fromuid=1','呼叫中心参数设置' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_PhoneSteward');
insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_Bangwo8Interface','https://www.51mis.com.cn/forum.php?mod=viewthread&tid=737&fromuid=1','帮我吧接口设置' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_Bangwo8Interface');
delimiter;

SET @labelbol = 'TASKLOGDISPLAY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'任务日志显示','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Setting the Task Log Display','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISPLAYCURRENTVALUE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'显示当前值','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display current value','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISPLAYHISTORICALVALUES';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'显示历史值','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display historical values','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_advancepicklisttask set effect_range = 'getlast' where IFNULL(effect_range,'') = '' and type = 'field';
delimiter;

SET @labelbol = 'ONLYTHELATESTHISTORICALDOCUMENTS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'仅统计该阶段下创建的历史单据的最新单据',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Only the latest historical documents created during this stage will be counted',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/kYIvoCqz' where label = 'HelpUrl_CheckinSetting';
delimiter;

UPDATE ld_desk set fieldlabel='网页端显示公海销售线索模块' WHERE labelbol='DISPLAYSEALEADS' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Web end display of open sea leads module' WHERE labelbol='DISPLAYSEALEADS' and languagetype='en' and labeltype='fixedstr';
delimiter;

SET @labelbol = 'NOUNITPRICEFIELDPERMISSION';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有{$Products.Products} unit_price字段权限或字段未开启',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No {$Products.Products} unit price field permission. The field has not been enabled for obtaining permission',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

CREATE TABLE if not EXISTS `ld_publicannouncement_readingstatus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `publicannouncementid` int(19) DEFAULT NULL,
	`recieverid` int(19) DEFAULT NULL,
	`reading_status` VARCHAR(50) DEFAULT '未读',
  `readedtime` datetime DEFAULT NULL,
	`deleted` int(19) DEFAULT 0,
  PRIMARY KEY (`id`)
)ENGINE=InnoDB;
delimiter;

call addtableIndex('ld_publicannouncement_readingstatus','publicannouncementid','publicannouncementid');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_publicannouncement_readingstatus_1230`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_publicannouncement_readingstatus_1230`(
)
BEGIN
		IF NOT EXISTS (SELECT 1 FROM ld_publicannouncement_readingstatus) THEN
			INSERT INTO ld_publicannouncement_readingstatus(publicannouncementid,recieverid,reading_status,readedtime,deleted)
			SELECT a.related_to,a.recieverid,a.status_rmd,a.readedtime,a.deleted
			FROM ld_reminds a JOIN ld_publicannouncement b ON a.related_to=b.publicannouncementid AND a.content=b.content WHERE a.deleted=0
			AND NOT EXISTS(SELECT 1 FROM ld_publicannouncement_readingstatus c WHERE c.publicannouncementid=a.related_to AND c.recieverid=a.recieverid AND c.deleted=0);
		END IF;
END ||
delimiter;

CALL ldcrm_add_publicannouncement_readingstatus_1230();
DROP PROCEDURE IF EXISTS `ldcrm_add_publicannouncement_readingstatus_1230`;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PublicAnnouncement');
SET @columnname='reading_status';
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @sequence=(SELECT MAX(sequence) FROM ld_field where tabid=@tabid and block = @relateid);
SET @fieldname='reading_status'; 
SET @fieldlabel='阅读情况';
SET @zh='阅读情况';
SET @en='Reading Status';
SET @uitype=1;
SET @typeofdata='V~O~LE~100';
SET @quickcreate=0;
SET @displaytype=2;
SET @bigtype='text';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @profileeditfield='no';
SET @savedatabase = 'yes';
SET @allowedit = 'no';
SET @allowhide='no';
SET @allowdelete='no';
SET @readonly=1;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);


INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@fieldlabel,@readonly,0,'','',@sequence+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',2,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=@columnname);
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;


CALL AddColumn (@tablename, @columnname, 'text', '', '');
delimiter;
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
delimiter;
call getallprofile('PublicAnnouncement');
call fieldprofile('PublicAnnouncement');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_publicannouncement_validatasaverule_1230`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_publicannouncement_validatasaverule_1230`(
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ld_validatasavemain WHERE rulename='修改公告内容提示重置阅读状态' AND module='PublicAnnouncement') THEN
		INSERT INTO `ld_validatasavemain` (
			`rulename`, 
			`module`, 
			`status`, 
			`actionprevent`, 
			`tipzhtype`, 
			`tipzh`, 
			`tipentype`, 
			`tipen`, 
			`validatasavetype`, 
			`isshowlist`, 
			`conditiongroup`, 
			`validataapplication`, 
			`relatedtable`, 
			`sequence`,
			`effectivemethod`
		) 
		SELECT
			'修改公告内容提示重置阅读状态', 
			'PublicAnnouncement', 
			'active',
			'no', 
			'text', 
			'修改公告内容会重置阅读情况,是否继续', 
			'text', 
			'Modifying the content of the announcement will reset the readings, whether or not it is continued', 
			'php', 
			'yes', 
			'[null,{"groupcondition":"and"},{"groupcondition":""}]', 
			'edit', 
			'ld_field', 
			IFNULL((SELECT MAX(sequence)+1 FROM ld_validatasavemain WHERE module='PublicAnnouncement'),1),
			'meetcontidion';

		SET @this_mainid=(SELECT id FROM ld_validatasavemain WHERE rulename='修改公告内容提示重置阅读状态' AND module='PublicAnnouncement' ORDER BY id DESC);

		INSERT INTO `ld_validatasave` (
		`module`, 
		`relatedtable`, 
		`fieldname`, 
		`comparator`, 
		`formulavalue`, 
		`comparatordescription`, 
		`rulename`, 
		`status`, 
		`validatacheckbutton`, 
		`allowsave`, 
		`tipzh`, 
		`tipen`, 
		`funtype`, 
		`fungroupdbcolumns`, 
		`fungrouphiddencolumns`, 

		`sequence`, 
		`validatasavetype`, 
		`isshowlist`, 
		`validatasavemainid`, 
		`conditiongroupid`, 
		`valid_condition`
	) 
	SELECT 
		'PublicAnnouncement', 
		'ld_field', 
		'select content as tmp_value from ld_publicannouncement where publicannouncementid = {Record.ID}', 
		'n', 
		NULL, 
		NULL, 
		NULL, 
		'active', 
		NULL, 
		'no', 
		NULL, 
		NULL, 
		'sql', 
		NULL, 
		NULL, 

		IFNULL((SELECT MAX(sequence)+1 FROM ld_validatasave WHERE validatasavemainid=@this_mainid),1), 
		'php', 
		'yes', 
		@this_mainid, 
		'1', 
		'';

		SET @this_validatasaveid=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@this_mainid ORDER BY id DESC LIMIT 1);
	
		INSERT INTO `ld_validatasavedetail` (
			`relateid`, 
			`relateformulavalue`, 
			`relatefieldname`, 
			`sequence`, 
			`relatedtable`, 
			`funtype`, 
			`fungroupdbcolumns`, 
			`fungrouphiddencolumns`
		) 
		SELECT
			@this_validatasaveid, 
			NULL, 
			'content', 
			NULL, 
			'ld_field', 
			'fields', 
			NULL, 
			NULL;
		


		INSERT INTO `ld_validatasave` (
		`module`, 
		`relatedtable`, 
		`fieldname`, 
		`comparator`, 
		`formulavalue`, 
		`comparatordescription`, 
		`rulename`, 
		`status`, 
		`validatacheckbutton`, 
		`allowsave`, 
		`tipzh`, 
		`tipen`, 
		`funtype`, 
		`fungroupdbcolumns`, 
		`fungrouphiddencolumns`, 

		`sequence`, 
		`validatasavetype`, 
		`isshowlist`, 
		`validatasavemainid`, 
		`conditiongroupid`, 
		`valid_condition`
	) 
	SELECT 
		'PublicAnnouncement', 
		'ld_field', 
		'select count(1) as tmp_value from ld_publicannouncement_readingstatus where publicannouncementid= {Record.ID} and deleted=0 and reading_status="已读"', 
		'n', 
		NULL, 
		NULL, 
		NULL, 
		'active', 
		NULL, 
		'no', 
		NULL, 
		NULL, 
		'sql', 
		NULL, 
		NULL, 

		IFNULL((SELECT MAX(sequence)+1 FROM ld_validatasave WHERE validatasavemainid=@this_mainid),1), 
		'php', 
		'yes', 
		@this_mainid, 
		'2', 
		'';

		SET @this_validatasaveid=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@this_mainid ORDER BY id DESC LIMIT 1);
	
		INSERT INTO `ld_validatasavedetail` (
			`relateid`, 
			`relateformulavalue`, 
			`relatefieldname`, 
			`sequence`, 
			`relatedtable`, 
			`funtype`, 
			`fungroupdbcolumns`, 
			`fungrouphiddencolumns`
		) 
		SELECT
			@this_validatasaveid, 
			NULL, 
			0, 
			NULL, 
			'ld_field', 
			'number', 
			NULL, 
			NULL;

	END IF;
END ||
delimiter;

CALL ldcrm_add_publicannouncement_validatasaverule_1230();
DROP PROCEDURE IF EXISTS `ldcrm_add_publicannouncement_validatasaverule_1230`;
delimiter;


drop  PROCEDURE  if exists insertinto_customreport_sqlchart20241230;
delimiter ||
create PROCEDURE insertinto_customreport_sqlchart20241230()
begin

select count(1) into @bandaoti_mainAccountAnalysis from ld_customreport where primaryname='bandaoti_mainAccountAnalysis' and deleted=0;
if @bandaoti_mainAccountAnalysis=0 then
select max(report_id)+1 into @report_id from ld_customreport;
select  analysisfolder_id into @analysisfolder_id from ld_report_analysis_folder where `name`='SalesReport'  ;

INSERT INTO `ld_customreport` (`report_id`, `report_name`, `report_desc`, `report_type`, `parent_id`, `sequence`, `mainmodule`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `limit`, `orderby`, `orderby_type`, `smcreatorid`, `stat_approach`, `approveallocatetype`, `show_athome`, `linkmodulecheck`, `can_penetrate`, `relatedmodule`, `isshow_search`, `isshow_table`, `analysisfolder_id`, `sqlstr`, `themename`, `advance_demand`, `advance_demand_groups`, `primaryname`) VALUES (@report_id, '主要客户分析(签约额)', '', 'sqlchart', NULL, '0', NULL, '2024-12-11 16:40:07', '2024-12-30 15:34:11', '0', '1', NULL, NULL, NULL, '1', NULL, '0', 'yes', 'yes', 'no', NULL, 'yes', 'Bottom', @analysisfolder_id, 'select accountname,monthdate,ifnull(sumtotal,0)as sumtotal,type,seq \nfrom \n(\n	select \n	ld_account.accountname ,\n	2 as ordernum,\n	DATE_FORMAT(ld_salesorder.signed_data,\'%Y-%m\') as monthdate,\n	\'\' as type,\n	sum(ld_salesorder.total)as sumtotal,\n	seq\n	from \n	(\n		select snt,accountid,(@seq:=@seq+1)as seq from(\n			select sum(ld_salesorder.total)as snt,accountid \n			from ld_salesorder \n			where ld_salesorder.deleted=0 \n			and ld_salesorder.signed_data between \'{startdate}\' and \'{enddate}\'\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n			group by accountid\n		)a, (SELECT @seq := 0) r  order by snt desc limit 5 \n	)tmp \n	left join ld_salesorder on tmp.accountid=ld_salesorder.accountid \n	left join ld_account on ld_salesorder.accountid=ld_account.accountid \n	where ld_salesorder.deleted=0 \n	and ld_salesorder.signed_data between \'{startdate}\' and \'{enddate}\'\n	and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n	and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n	group by DATE_FORMAT(ld_salesorder.signed_data,\'%Y-%m\'),\n	tmp.accountid\n\n	union all \n\n	select \n	\'其他\' as accountname ,\n	2 as ordernum,\n	DATE_FORMAT(ld_salesorder.signed_data,\'%Y-%m\') as monthdate,\n	\'\' as type,\n	sum(ld_salesorder.total)as sumtotal,\n	6 as seq \n	from ld_salesorder \n	left join ld_account on ld_salesorder.accountid=ld_account.accountid \n	where ld_salesorder.deleted=0 \n	and ld_salesorder.signed_data between \'{startdate}\' and \'{enddate}\'\n	and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n	and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n	and ld_salesorder.accountid not in(\n		select accountid from (\n			select * from(\n				select sum(ld_salesorder.total)as snt,accountid \n				from ld_salesorder where ld_salesorder.deleted=0 \n				and ld_salesorder.signed_data between \'{startdate}\' and \'{enddate}\'\n				and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n				and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n				group by accountid \n			)a order by snt desc limit 5\n		)a\n	)\n	group by DATE_FORMAT(ld_salesorder.signed_data,\'%Y-%m\')\n\n	union all \n\n	select \n	ld_account.accountname ,\n	1 as ordernum,\n	\'同比增长率(%)\' as monthdate,\n	\'不参与计算\' as type,\n	round(case when tmp2.last=0 then 100 else (tmp.snt-tmp2.last)*100/tmp2.last end,2) as sumtotal,\n	seq\n	from \n	(\n		select snt,accountid,(@seq:=@seq+1)as seq from(\n			select sum(ld_salesorder.total)as snt,accountid \n			from ld_salesorder where ld_salesorder.deleted=0 \n			and ld_salesorder.signed_data between \'{startdate}\' and \'{enddate}\'\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n			group by accountid \n		)a, (SELECT @seq := 0) r order by snt desc limit 5\n	)tmp\n	left join \n	(\n		select * from(\n			select sum(ld_salesorder.total)as last,accountid \n			from ld_salesorder \n			where ld_salesorder.deleted=0 \n			and ld_salesorder.signed_data between DATE_ADD(\'{startdate}\',INTERVAL -1 YEAR) and DATE_ADD(\'{enddate}\',INTERVAL -1 YEAR)\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n			group by accountid \n		)a  \n	)tmp2  on tmp.accountid=tmp2.accountid \n\n	left join ld_account on tmp.accountid=ld_account.accountid\n	union ALL\n\n	select \n	\'其他\' as accountname ,\n	1 as ordernum,\n	\'同比增长率(%)\' as monthdate,\n	\'不参与计算\' as type,\n	round(case when tmp2.last=0 then 100 else (tmp.snt-tmp2.last)*100/tmp2.last end,2) as sumtotal,\n	6 as seq \n	from \n	(\n		select snt,1 as accountid from(\n			select sum(ld_salesorder.total)as snt,accountid from ld_salesorder \n			where ld_salesorder.deleted=0 \n			and ld_salesorder.signed_data between \'{startdate}\' and \'{enddate}\'\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n			and ld_salesorder.accountid not in(\n				select accountid from (\n					select * from(\n						select sum(ld_salesorder.total)as snt,accountid \n						from ld_salesorder \n						where ld_salesorder.deleted=0 \n						and ld_salesorder.signed_data between \'{startdate}\' and \'{enddate}\'\n						and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n						and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n						group by accountid \n					)a order by snt desc limit 5\n				)a\n			)\n			\n		)a  \n	)tmp\n	left join \n	(\n		select last,1 as accountid from(\n			select sum(ld_salesorder.total)as last,accountid from ld_salesorder \n			where ld_salesorder.deleted=0 \n			and ld_salesorder.signed_data between DATE_ADD(\'{startdate}\',INTERVAL -1 YEAR) and DATE_ADD(\'{enddate}\',INTERVAL -1 YEAR)\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n			and ld_salesorder.accountid not in(\n				select accountid from (\n					select * from(\n						select sum(ld_salesorder.total)as snt,accountid from ld_salesorder where ld_salesorder.deleted=0 \n						and ld_salesorder.signed_data between \'{startdate}\' and \'{enddate}\'\n						and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.approvestatus,\'{approvestatus}\') end)\n						and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_salesorder.smownerid,\'{userid}\') end)\n						group by accountid \n					)a order by snt desc limit 5\n				)a\n			)\n			 \n		)a  \n	)tmp2  on tmp.accountid=tmp2.accountid \n)a order by seq asc,ordernum asc ,accountname asc ,monthdate asc \n ', 'Default', NULL, NULL, 'bandaoti_mainAccountAnalysis');


INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id ,'客户名称', 'accountname', 'no', '1', 'string')  ;
INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id,'年月', 'monthdate', 'no', '2', 'string') ;
INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id, '签约额', 'sumtotal', 'no', '3', 'number') ;
INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id,'type', 'type', 'no', '4', 'string') ;
INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id,'seq', 'seq', 'no', '5', 'string') ;

INSERT INTO `ld_customreportsql_filter` (`report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`, `filter_relatedtab`, `uses`) VALUES (@report_id, 'startdate', '开始日期', 'date', 'thisyearstart,2024-01-01', NULL, NULL, NULL, NULL, '1', NULL, NULL) ;
INSERT INTO `ld_customreportsql_filter` (`report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`, `filter_relatedtab`, `uses`) VALUES (@report_id, 'enddate', '截至日期', 'date', 'thisyearend,2024-12-31', NULL, NULL, NULL, NULL, '2', NULL, NULL) ;
INSERT INTO `ld_customreportsql_filter` (`report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`, `filter_relatedtab`, `uses`) VALUES (@report_id, 'approvestatus', '审批状态', 'approvestatus', '未提交,审批中,已批准,已拒绝,已驳回', NULL, NULL, NULL, NULL, '3', NULL, NULL) ;
INSERT INTO `ld_customreportsql_filter` (`report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`, `filter_relatedtab`, `uses`) VALUES (@report_id, 'userid', '用户组件', 'multiuser', '', NULL, 'SalesOrder', NULL, NULL, '4', NULL, NULL) ;

INSERT INTO `ld_customreport_chartset` (`report_id`, `title`, `chart_type`, `xAxis`, `yAxis`, `legend`, `tooltip`, `toolbox`, `show_percent`, `funnel_type`, `legend_position`, `series_datalabel`, `show_rowtotal`, `show_columntotal`, `show_columntotal_inchart`, `show_alltotal_inchart`) VALUES (@report_id, '{\"text\":\"主要客户分析(签约额)\",\"show\":false,\"left\":\"10\"}', 'simple_sunburst', NULL, NULL, '{\"type\":\"plain\",\"orient\":\"horizontal\",\"bottom\":10,\"right\":\"50%\"}', '{\"trigger\":\"axis\"}', '{\"bottom\":10,\"left\":\"50%\",\"orient\":\"vertical\",\"show\":false}', 'yes', NULL, 'Bottom', '{\"show\":true,\"position\":\"inside_tangential\"}', 'no', 'no', 'yes', 'yes') ;

select id into @column_id from ld_customreportsql_column where report_id=@report_id and `columns`='sumtotal' limit 1 ;

INSERT INTO `ld_customreport_total_column` (`report_id`, `total_type`, `columns`, `sequence`, `chart_column_type`, `color`, `chart_column_name`, `yaxisindex`, `column_module`, `compare_select`) VALUES (@report_id, '', @column_id, '0', 'sunburst', '', '签约额', NULL, '', 'cur') ;

INSERT INTO ld_report_analysis2user (`report_id`, `modulename`, `userid`, `sequence`) VALUES (@report_id, 'CustomEcharts', '-1', '0') ;

select id into @column_id from ld_customreportsql_column where report_id=@report_id and `columns`='accountname' limit 1 ;
INSERT INTO `ld_customreport_group` (`report_id`, `groupbytype`, `columns`, `sequence`, `bigtype`) VALUES (@report_id, 'bysql', @column_id, '0', NULL) ;
select id into @column_id from ld_customreportsql_column where report_id=@report_id and `columns`='monthdate' limit 1 ;
INSERT INTO `ld_customreport_group` (`report_id`, `groupbytype`, `columns`, `sequence`, `bigtype`) VALUES (@report_id, 'bysql', @column_id, '0', NULL) ;
end if;
end ||
delimiter;

call insertinto_customreport_sqlchart20241230();
delimiter;



drop  PROCEDURE  if exists insertinto_customreport_sqlchart20241231;
delimiter ||
create PROCEDURE insertinto_customreport_sqlchart20241231()
begin

select count(1) into @bandaoti_mainAccountAnalysis from ld_customreport where primaryname='bandaoti_mainAccountAnalysis_chuku' and deleted=0;
if @bandaoti_mainAccountAnalysis=0 then
select max(report_id)+1 into @report_id from ld_customreport;
select  analysisfolder_id into @analysisfolder_id from ld_report_analysis_folder where `name`='SalesReport'  ;

INSERT INTO `ld_customreport` (`report_id`, `report_name`, `report_desc`, `report_type`, `parent_id`, `sequence`, `mainmodule`, `createdtime`, `modify_time`, `deleted`, `modify_id`, `limit`, `orderby`, `orderby_type`, `smcreatorid`, `stat_approach`, `approveallocatetype`, `show_athome`, `linkmodulecheck`, `can_penetrate`, `relatedmodule`, `isshow_search`, `isshow_table`, `analysisfolder_id`, `sqlstr`, `themename`, `advance_demand`, `advance_demand_groups`, `primaryname`) VALUES (@report_id, '主要客户分析(出库额)', '', 'sqlchart', NULL, '0', NULL, '2024-12-11 16:40:07', '2024-12-30 15:34:11', '0', '1', NULL, NULL, NULL, '1', NULL, '0', 'yes', 'yes', 'no', NULL, 'yes', 'Bottom', @analysisfolder_id, 'select accountname,monthdate,ifnull(sumtotal,0)as sumtotal,type,seq \nfrom \n(\n	select \n	ld_account.accountname ,\n	2 as ordernum,\n	DATE_FORMAT(ld_outboundorder.outdate,\'%Y-%m\') as monthdate,\n	\'\' as type,\n	sum(ld_outboundorder.total)as sumtotal,\n	seq\n	from \n	(\n		select snt,accountid,(@seq:=@seq+1)as seq from(\n			select sum(ld_outboundorder.total)as snt,accountid \n			from ld_outboundorder \n			where ld_outboundorder.deleted=0 \n			and ld_outboundorder.outdate between \'{startdate}\' and \'{enddate}\'\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n			group by accountid\n		)a, (SELECT @seq := 0) r  order by snt desc limit 5 \n	)tmp \n	left join ld_outboundorder on tmp.accountid=ld_outboundorder.accountid \n	left join ld_account on ld_outboundorder.accountid=ld_account.accountid \n	where ld_outboundorder.deleted=0 \n	and ld_outboundorder.outdate between \'{startdate}\' and \'{enddate}\'\n	and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n	and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n	group by DATE_FORMAT(ld_outboundorder.outdate,\'%Y-%m\'),\n	tmp.accountid\n\n	union all \n\n	select \n	\'其他\' as accountname ,\n	2 as ordernum,\n	DATE_FORMAT(ld_outboundorder.outdate,\'%Y-%m\') as monthdate,\n	\'\' as type,\n	sum(ld_outboundorder.total)as sumtotal,\n	6 as seq \n	from ld_outboundorder \n	left join ld_account on ld_outboundorder.accountid=ld_account.accountid \n	where ld_outboundorder.deleted=0 \n	and ld_outboundorder.outdate between \'{startdate}\' and \'{enddate}\'\n	and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n	and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n	and ld_outboundorder.accountid not in(\n		select accountid from (\n			select * from(\n				select sum(ld_outboundorder.total)as snt,accountid \n				from ld_outboundorder where ld_outboundorder.deleted=0 \n				and ld_outboundorder.outdate between \'{startdate}\' and \'{enddate}\'\n				and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n				and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n				group by accountid \n			)a order by snt desc limit 5\n		)a\n	)\n	group by DATE_FORMAT(ld_outboundorder.outdate,\'%Y-%m\')\n\n	union all \n\n	select \n	ld_account.accountname ,\n	1 as ordernum,\n	\'同比增长率(%)\' as monthdate,\n	\'不参与计算\' as type,\n	round(case when tmp2.last=0 then 100 else (tmp.snt-tmp2.last)*100/tmp2.last end,2) as sumtotal,\n	seq\n	from \n	(\n		select snt,accountid,(@seq:=@seq+1)as seq from(\n			select sum(ld_outboundorder.total)as snt,accountid \n			from ld_outboundorder where ld_outboundorder.deleted=0 \n			and ld_outboundorder.outdate between \'{startdate}\' and \'{enddate}\'\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n			group by accountid \n		)a, (SELECT @seq := 0) r order by snt desc limit 5\n	)tmp\n	left join \n	(\n		select * from(\n			select sum(ld_outboundorder.total)as last,accountid \n			from ld_outboundorder \n			where ld_outboundorder.deleted=0 \n			and ld_outboundorder.outdate between DATE_ADD(\'{startdate}\',INTERVAL -1 YEAR) and DATE_ADD(\'{enddate}\',INTERVAL -1 YEAR)\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n			group by accountid \n		)a  \n	)tmp2  on tmp.accountid=tmp2.accountid \n\n	left join ld_account on tmp.accountid=ld_account.accountid\n	union ALL\n\n	select \n	\'其他\' as accountname ,\n	1 as ordernum,\n	\'同比增长率(%)\' as monthdate,\n	\'不参与计算\' as type,\n	round(case when tmp2.last=0 then 100 else (tmp.snt-tmp2.last)*100/tmp2.last end,2) as sumtotal,\n	6 as seq \n	from \n	(\n		select snt,1 as accountid from(\n			select sum(ld_outboundorder.total)as snt,accountid from ld_outboundorder \n			where ld_outboundorder.deleted=0 \n			and ld_outboundorder.outdate between \'{startdate}\' and \'{enddate}\'\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n			and ld_outboundorder.accountid not in(\n				select accountid from (\n					select * from(\n						select sum(ld_outboundorder.total)as snt,accountid \n						from ld_outboundorder \n						where ld_outboundorder.deleted=0 \n						and ld_outboundorder.outdate between \'{startdate}\' and \'{enddate}\'\n						and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n						and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n						group by accountid \n					)a order by snt desc limit 5\n				)a\n			)\n			\n		)a  \n	)tmp\n	left join \n	(\n		select last,1 as accountid from(\n			select sum(ld_outboundorder.total)as last,accountid from ld_outboundorder \n			where ld_outboundorder.deleted=0 \n			and ld_outboundorder.outdate between DATE_ADD(\'{startdate}\',INTERVAL -1 YEAR) and DATE_ADD(\'{enddate}\',INTERVAL -1 YEAR)\n			and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n			and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n			and ld_outboundorder.accountid not in(\n				select accountid from (\n					select * from(\n						select sum(ld_outboundorder.total)as snt,accountid from ld_outboundorder where ld_outboundorder.deleted=0 \n						and ld_outboundorder.outdate between \'{startdate}\' and \'{enddate}\'\n						and (case when \'{approvestatus}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.approvestatus,\'{approvestatus}\') end)\n						and (case when \'{userid}\'=\'\' then 1=1 else FIND_IN_SET(ld_outboundorder.smownerid,\'{userid}\') end)\n						group by accountid \n					)a order by snt desc limit 5\n				)a\n			)\n			 \n		)a  \n	)tmp2  on tmp.accountid=tmp2.accountid \n)a order by seq asc,ordernum asc ,accountname asc ,monthdate asc \n ', 'Default', NULL, NULL, 'bandaoti_mainAccountAnalysis_chuku');


INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id ,'客户名称', 'accountname', 'no', '1', 'string')  ;
INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id,'年月', 'monthdate', 'no', '2', 'string') ;
INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id, '出库额', 'sumtotal', 'no', '3', 'number') ;
INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id,'type', 'type', 'no', '4', 'string') ;
INSERT INTO `ld_customreportsql_column` (`report_id`, `column_label`, `columns`, `is_group`, `sequence`, `fieldtype`) VALUES (@report_id,'seq', 'seq', 'no', '5', 'string') ;

INSERT INTO `ld_customreportsql_filter` (`report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`, `filter_relatedtab`, `uses`) VALUES (@report_id, 'startdate', '开始日期', 'date', 'thisyearstart,2024-01-01', NULL, NULL, NULL, NULL, '1', NULL, NULL) ;
INSERT INTO `ld_customreportsql_filter` (`report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`, `filter_relatedtab`, `uses`) VALUES (@report_id, 'enddate', '截至日期', 'date', 'thisyearend,2024-12-31', NULL, NULL, NULL, NULL, '2', NULL, NULL) ;
INSERT INTO `ld_customreportsql_filter` (`report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`, `filter_relatedtab`, `uses`) VALUES (@report_id, 'approvestatus', '审批状态', 'approvestatus', '未提交,审批中,已批准,已拒绝,已驳回', NULL, NULL, NULL, NULL, '3', NULL, NULL) ;
INSERT INTO `ld_customreportsql_filter` (`report_id`, `var_name`, `display_name`, `var_type`, `default_value`, `select_source`, `modulename`, `fieldname`, `selectvalues`, `sequence`, `filter_relatedtab`, `uses`) VALUES (@report_id, 'userid', '用户组件', 'multiuser', '', NULL, 'OutboundOrder', NULL, NULL, '4', NULL, NULL) ;

INSERT INTO `ld_customreport_chartset` (`report_id`, `title`, `chart_type`, `xAxis`, `yAxis`, `legend`, `tooltip`, `toolbox`, `show_percent`, `funnel_type`, `legend_position`, `series_datalabel`, `show_rowtotal`, `show_columntotal`, `show_columntotal_inchart`, `show_alltotal_inchart`) VALUES (@report_id, '{\"text\":\"主要客户分析(出库额)\",\"show\":false,\"left\":\"10\"}', 'simple_sunburst', NULL, NULL, '{\"type\":\"plain\",\"orient\":\"horizontal\",\"bottom\":10,\"right\":\"50%\"}', '{\"trigger\":\"axis\"}', '{\"bottom\":10,\"left\":\"50%\",\"orient\":\"vertical\",\"show\":false}', 'yes', NULL, 'Bottom', '{\"show\":true,\"position\":\"inside_tangential\"}', 'no', 'no', 'yes', 'yes') ;

select id into @column_id from ld_customreportsql_column where report_id=@report_id and `columns`='sumtotal' limit 1 ;

INSERT INTO `ld_customreport_total_column` (`report_id`, `total_type`, `columns`, `sequence`, `chart_column_type`, `color`, `chart_column_name`, `yaxisindex`, `column_module`, `compare_select`) VALUES (@report_id, '', @column_id, '0', 'sunburst', '', '出库额', NULL, '', 'cur') ;

INSERT INTO ld_report_analysis2user (`report_id`, `modulename`, `userid`, `sequence`) VALUES (@report_id, 'CustomEcharts', '-1', '0') ;

select id into @column_id from ld_customreportsql_column where report_id=@report_id and `columns`='accountname' limit 1 ;
INSERT INTO `ld_customreport_group` (`report_id`, `groupbytype`, `columns`, `sequence`, `bigtype`) VALUES (@report_id, 'bysql', @column_id, '0', NULL) ;
select id into @column_id from ld_customreportsql_column where report_id=@report_id and `columns`='monthdate' limit 1 ;
INSERT INTO `ld_customreport_group` (`report_id`, `groupbytype`, `columns`, `sequence`, `bigtype`) VALUES (@report_id, 'bysql', @column_id, '0', NULL) ;
end if;
end ||
delimiter;

call insertinto_customreport_sqlchart20241231();
delimiter;

CALL AddColumn('ld_workreport','imagename','varchar','10',Null);
CALL AddColumn('ld_workreport','imagepath','varchar','10',Null);
delimiter;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
set @tabid = (select tabid from ld_tab where name='WorkReportList' limit 1);
SET @maxseq=(SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype)
SELECT @tabid,@maxid+1,'imagename','ld_workreport',2,69,'imagename','图片',0,2,NULL,100,@maxseq+1,750,1,'V~O',1,'BAS',2,NULL,0,0,0,'fileattachment' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename='ld_workreport' AND columnname='imagename' AND fieldlabel='图片'); 
delimiter;

SELECT fieldid into @relateid FROM ld_field WHERE tabid=@tabid AND tablename='ld_workreport' AND columnname='imagename' AND fieldlabel='图片';
set @tabid = (select tabid from ld_tab where name='WorkReportList' limit 1);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'图片'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=@tabid and Relateid=@relateid and trantable='ld_field' and  languagetype='zh') and EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename='ld_workreport' AND columnname='imagename' AND fieldlabel='图片');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'image'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=@tabid and Relateid=@relateid and trantable='ld_field' and  languagetype='en') and EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename='ld_workreport' AND columnname='imagename' AND fieldlabel='图片');
delimiter;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
set @tabid = (select tabid from ld_tab where name='WorkReportList' limit 1);
SET @maxseq=(SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype)
SELECT @tabid,@maxid+1,'filename','ld_workreport',2,1109,'filename','附件',0,2,NULL,100,@maxseq+1,750,1,'V~O',1,'BAS',1,NULL,0,0,0,'fileattachment' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename='ld_workreport' AND columnname='filename' AND fieldlabel='附件');
delimiter;

SELECT fieldid into @relateid FROM ld_field WHERE tabid=@tabid AND tablename='ld_workreport' AND columnname='filename' AND fieldlabel='附件'; 
set @tabid = (select tabid from ld_tab where name='WorkReportList' limit 1);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'附件'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=@tabid and Relateid=@relateid and trantable='ld_field' and  languagetype='zh') and EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename='ld_workreport' AND columnname='filename' AND fieldlabel='附件');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Attachments'
from dual where not exists(select 1 from  ld_tranlabel where  tabid=@tabid and Relateid=@relateid and trantable='ld_field' and  languagetype='en') and EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename='ld_workreport' AND columnname='filename' AND fieldlabel='附件');
delimiter;

set @tabid = (select tabid from ld_tab where name='WorkReportList' limit 1);
set @opDownload = (select max(actionid) from ld_actionmapping where actionlabel='DOWNLOAD');
set @opPreview = (select max(actionid) from ld_actionmapping where actionlabel='PREVIEW');
set @sequence = (SELECT max(sequence) FROM ld_profileallpermission WHERE tabid = @tabid);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@opDownload,@sequence+1 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid = @tabid AND operation=@opDownload);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@opPreview,@sequence+2 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid = @tabid AND operation=@opPreview);
delimiter;

SET @labelbol = 'InterfaceLogoutReminder';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'注销后，应用将无法使用，是否继续？',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After logging out, the application will no longer be available. Do you want to continue?',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;
-- 2024-12-31

DROP PROCEDURE IF EXISTS `ldcrm_add_holiday`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_holiday`(
	tmp_name VARCHAR(100),
  tmp_type VARCHAR(10),
	tmp_date DATE
)
BEGIN

		SET @autoadd_module='Holiday';
		SET @tmp_date=tmp_date;

		SET @tmp_title=CONCAT(DATE_FORMAT(tmp_date,'%Y年'),tmp_name,IF(tmp_type='休','放','补'),'假');
		
		IF NOT EXISTS (SELECT 1 FROM ld_holiday WHERE deleted=0 AND holiday_date=@tmp_date) THEN
			SET @autoadd_maxcrmid=(SELECT MAX(crmid) FROM ld_crmentity);
			INSERT INTO ld_crmentity(crmid,setype)
			SELECT @autoadd_maxcrmid+1,@autoadd_module;
			UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);

			INSERT INTO ld_holiday(
				holidayid,
				holidayno,

				
				holiday_title,
				holiday_name,
				holiday_date,
				wheatherholidays,
				holiday_type,
				deleted,
				
				smownerid,					
				smcreatorid,				
				modifiedby,					
				createdtime,				
				modifiedtime
			)
			SELECT
				@autoadd_maxcrmid+1,
				(SELECT CONCAT(prefix,cur_id) FROM ld_modentity_num WHERE semodule=@autoadd_module AND active=1),

				@tmp_title,
				tmp_name,
				tmp_date,
				IF(tmp_type='补','班','休'),
				'法定节假日',
				0,
				
				1,					
				1,				
				1,					
				NOW(),				
				NOW();
		
			UPDATE ld_modentity_num SET cur_id=cur_id+1 WHERE semodule=@autoadd_module AND active=1;

			INSERT INTO ld_holidayscf(holidayid) SELECT @autoadd_maxcrmid+1;

	END IF;
			
END ||
delimiter;

DROP PROCEDURE IF EXISTS `reset_holiday_2025`;
delimiter ||
CREATE  PROCEDURE `reset_holiday_2025`(
)
BEGIN
	

	IF NOT EXISTS (SELECT 1 FROM ld_holiday WHERE holiday_date>'2025-12-31' AND holiday_type='法定节假日') THEN
		CALL ldcrm_add_holiday('元旦','休','2025-01-01');

		CALL ldcrm_add_holiday('春节','补','2025-01-26');
		CALL ldcrm_add_holiday('春节','休','2025-01-28');
		CALL ldcrm_add_holiday('春节','休','2025-01-29');
		CALL ldcrm_add_holiday('春节','休','2025-01-30');
		CALL ldcrm_add_holiday('春节','休','2025-01-31');
		CALL ldcrm_add_holiday('春节','休','2025-02-03');
		CALL ldcrm_add_holiday('春节','休','2025-02-04');
		CALL ldcrm_add_holiday('春节','补','2025-02-08');

		CALL ldcrm_add_holiday('清明节','休','2025-04-04');

		CALL ldcrm_add_holiday('劳动节','补','2025-04-27');
		CALL ldcrm_add_holiday('劳动节','休','2025-05-01');
		CALL ldcrm_add_holiday('劳动节','休','2025-05-02');
		CALL ldcrm_add_holiday('劳动节','休','2025-05-05');

		CALL ldcrm_add_holiday('端午节','休','2025-06-02');

		CALL ldcrm_add_holiday('国庆节','补','2025-09-28');
		CALL ldcrm_add_holiday('国庆节','休','2025-10-01');
		CALL ldcrm_add_holiday('国庆节','休','2025-10-02');
		CALL ldcrm_add_holiday('国庆节','休','2025-10-03');
		CALL ldcrm_add_holiday('中秋节','休','2025-10-06');
		CALL ldcrm_add_holiday('国庆节','休','2025-10-07');
		CALL ldcrm_add_holiday('国庆节','休','2025-10-08');
		CALL ldcrm_add_holiday('国庆节','补','2025-10-11');

	END IF;

end ||
delimiter;

CALL reset_holiday_2025();
DROP PROCEDURE IF EXISTS `reset_holiday_2025`;
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

UPDATE ld_version SET old_version='V8.6.5.1',current_version='V8.6.5.1',remark='V8.6.5.1-20241231',wx_version='V8.6.5.0';
delimiter;