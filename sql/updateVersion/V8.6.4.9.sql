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

SET @i=0;
SET @tabid=(SELECT tabid FROM ld_tab WHERE name='SalesBack');
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Sales');
SET @order_seq=(SELECT sequence FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=22);
SET @back_seq=(SELECT sequence FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);
UPDATE ld_parenttabrel SET sequence=sequence+2 WHERE parenttabid=@parenttabid AND sequence>@order_seq AND @order_seq>0;
UPDATE ld_parenttabrel SET sequence=@order_seq+1 WHERE parenttabid=@parenttabid AND tabid=@tabid AND @order_seq>0 AND @back_seq>0 AND @order_seq<@back_seq;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;
delimiter;

update ld_desk set fieldlabel='Clear filter values' where labelbol='ClearTiledFilterValues' and labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='清除筛选值' where labelbol='ClearTiledFilterValues' and labeltype='fixedstr' and languagetype='zh';
delimiter;

DELETE from ld_cvadvfilter where cvid not in (SELECT cvid from ld_customview);
DELETE from ld_cvadvfilter_grouping where cvid not in (SELECT cvid from ld_customview);
delimiter;
-- 2024-11-25

set @tmp_blockid = (SELECT blockid FROM ld_settings_blocks WHERE  `label` = 'EnterpriseLogs');
set @tmp_seq = (SELECT sequence FROM ld_settings_field WHERE blockid = @tmp_blockid AND `name` = 'OperationLogs');
UPDATE ld_settings_field SET sequence = @tmp_seq + 1 WHERE `name` = 'ImportExportLogs';
delimiter;

update ld_desk set fieldlabel='Clear filter values' where labelbol='ClearTiledFilterValues' and labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='清除筛选值' where labelbol='ClearTiledFilterValues' and labeltype='fixedstr' and languagetype='zh';
delimiter;

DELETE from ld_cvadvfilter where cvid not in (SELECT cvid from ld_customview);
DELETE from ld_cvadvfilter_grouping where cvid not in (SELECT cvid from ld_customview);
delimiter;

UPDATE ld_desk set fieldlabel = '定位参数' where labelbol='TRACKGROUP' AND labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel = 'Position Parameters' where labelbol='TRACKGROUP' AND labeltype='fixedstr' AND languagetype='en';
delimiter;

delete from ld_desk where labelbol = 'ImageImportTimeFinishTip1';
delete from ld_desk where labelbol = 'ImageImportTimeFinishTip2';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImageImportTimeFinishTip1','共有{Var}个图片，成功导入{Var}个图片','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishTip1' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImageImportTimeFinishTip1',"There are a total of {Var} images, {Var} images were successfully imported ",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishTip1' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImageImportTimeFinishTip2','导入失败{Var}个图片','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishTip2' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImageImportTimeFinishTip2'," and {Var} images failed to import",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ImageImportTimeFinishTip2' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_systems_deploy SET deploy_value=0,presence=1 WHERE deploy_type = 21;
delimiter;

SET @labelbol = 'qoq';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'同环比','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'QOQ','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'MOMgrowth';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'环比增长值','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Month on month growth value','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'MOMgrowthPercent';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'环比增长率','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Month on month growth rate','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;


SET @labelbol = 'prev_lastyear';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'去年同期','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'corresponding period of last year','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'YOYgrowth';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'与去年同比增长值','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Year on year growth compared to last year','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'YOYgrowthPercent';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'与去年同比增长率','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Year on year growth rate compared to last year','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

UPDATE ld_systems_deploy SET deploy_value=1,presence=1 WHERE deploy_type = 115;
delimiter;

update ld_producttoolfield set allowhide='yes' where  columnname='tax_price_before_discounted' or columnname='tax_amount_before_discounted';
delimiter;

SET @attachment_tabid = (select tabid from ld_tab where `name` = 'Attachment');
SET @target_tabid = (select tabid from ld_tab where `name` = 'PublicAnnouncement');
SET @max_seq = (select MAX(sequence) from ld_option_module where `tabid` = @attachment_tabid);
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence,datarang,maxrowsshow,unallowrepeat)
SELECT @attachment_tabid,@target_tabid,0,0,0,@max_seq+1,0,'permit',20,'no' FROM DUAL
WHERE NOT EXISTS (select 1 from ld_option_module where `tabid` = @attachment_tabid AND `option_tabid` = @target_tabid);
delimiter;

set @tabid = (select tabid from ld_tab where name = 'WorkSheet');
update ld_field set savedatabase = 'yes' where tabid = @tabid and columnname = 'filename' and savedatabase='no';
delimiter;

UPDATE ld_field set typeofdata = CONCAT('V~',SUBSTR(typeofdata,2)) where LOCATE('~',typeofdata) = 1 and columnname = 'bill_country';
delimiter;

UPDATE ld_producttoolprofile set create_profile = 'write' where create_profile = 'r';
UPDATE ld_producttoolprofile set edit_profile = 'write' where edit_profile = 'r';
UPDATE ld_producttoolprofile set details_profile = 'read' where details_profile = 'r';
delimiter;

update ld_homestuffdetail 
set  
	advance_demand='[{"groupid":"1","columnname":"ld_salesorder:receivable_balance:receivable_balance:SalesOrder_fieldlabel:N","comparator":"n","value":"0","columncondition":""}]',
	advance_demand_groups='[null,{"groupcondition":""}]' 
where stuffid=34 
	and stufflabel='transaction_balance_sales' 
	and compute_columns='ld_salesorder.receivable_balance';

update ld_homestuffdetail 
set  
	advance_demand='[{"groupid":"1","columnname":"ld_servicecontracts:receivable_balance:receivable_balance:ServiceContracts_fieldlabel:N","comparator":"n","value":"0","columncondition":""}]',
	advance_demand_groups='[null,{"groupcondition":""}]' 
where stuffid=34 
	and stufflabel='transaction_balance_service' 
	and compute_columns='ld_servicecontracts.receivable_balance';
delimiter;

CALL AddColumn('ld_customreport_total_column','compare_select','varchar','255','cur');
delimiter;

update ld_desk set fieldlabel='(Start date and deadline set value is the number of days after the current date delay)' where labelbol='REMINDFORCALENDARTEMPLATE' and labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='（起始日期和截止日期设置的值为当前日期延后的天数）' where labelbol='REMINDFORCALENDARTEMPLATE' and labeltype='fixedstr' and languagetype='zh';
delimiter;
-- 2024-12-03


update ld_users set `status` = 'Inactive' where `status` = 'nogroup_Inactive';
delimiter;


update ld_field set bigtype='picklist_key' where tabid in (select tabid from ld_tab where name='pricepolicy')
and (columnname='pricepolicy_type' or columnname='pricepolicy_forms');
delimiter;

CREATE TABLE  if not exists  `ld_pricepolicyscf` (
  `pricepolicyid` int(11) NOT NULL,
  PRIMARY KEY (`pricepolicyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_pricepolicydetailscf` (
  `lineitem_id` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @tabid = (select tabid from ld_tab where name = 'Personnelfile');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,'-19','get_operationlogs',@max_sequence+1,'OperationLogs',0,'','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_operationlogs');

SET @tabid = (select tabid from ld_tab where name = 'Personnelfile');
SET @rel_tabid = (select tabid from ld_tab where name = 'Reminds');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,@rel_tabid,'get_reminds',@max_sequence+1,'Reminds',0,'add','reminds.related_to','datacategory_sql' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_reminds');

SET @tabid = (select tabid from ld_tab where name = 'Personnelfile');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,0,'get_SharedUsers',@max_sequence+1,'SharedUsers',0,'share','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_SharedUsers');

SET @tabid = (select tabid from ld_tab where name = 'Personnelfile');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,'-7','get_viewhistory',@max_sequence+1,'ViewHistory',0,'','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_viewhistory');

SET @tabid = (select tabid from ld_tab where name = 'Personnelfile');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,'-10','get_changeview',@max_sequence+1,'ChangeView',0,'','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_changeview');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Tile','平铺','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Tile' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Tile','Tile','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Tile' and labeltype='jspop');
delimiter;

SET @labelbol = 'PRODUCTENTRYFIELDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'产品分录字段','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Product entry fields','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


set @cur_module = 'Contacts';set @option_module = 'OutboundOrder';
set @tabid = (SELECT tabid from ld_tab where `name` = @cur_module);
set @option_tabid = (SELECT tabid from ld_tab where `name` = @option_module);
SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,@option_tabid,CONCAT('get_',LOWER(@option_module)),@i+1,@option_module,1,'add','outboundorder.contactid','datacategory_sql' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@option_tabid );
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

UPDATE ld_module_setting_byuser SET content = 'no' WHERE label='Tiledsearch';
delimiter;

SET @labelbol = 'loginuisetting';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'登录页','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'login ui','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'Carousel';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'轮播图','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Carousel','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;


DROP PROCEDURE IF EXISTS `updateloginswiperdefault`;
delimiter ||
CREATE PROCEDURE `updateloginswiperdefault`(
)
BEGIN
		declare loginnum int default 0;
		set loginnum = (select count(login_id) from ld_loginhistory);

				IF loginnum < 5 THEN
update ld_loginsettingsinfo set isshow = 'no' where `name` = 'loginswiper' and type = 'default' and (content like '%defaultloginswiper2.png%' or content like '%defaultloginswiper1.png%');
END IF;



end ||
delimiter;

CALL updateloginswiperdefault();
DROP PROCEDURE IF EXISTS `updateloginswiperdefault`;
delimiter;


SET @labelbol = 'showtoolbox';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'显示下载按钮','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display download button','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @tabid = (select tabid from ld_tab where name = 'Laborcontract');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,'-19','get_operationlogs',@max_sequence+1,'OperationLogs',0,'','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid  AND `name`='get_operationlogs');
delimiter;

SET @tabid = (select tabid from ld_tab where name = 'Laborcontract');
SET @rel_tabid = (select tabid from ld_tab where name = 'Reminds');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,@rel_tabid,'get_reminds',@max_sequence+1,'Reminds',0,'add','reminds.related_to','datacategory_sql' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_reminds');
delimiter;

SET @tabid = (select tabid from ld_tab where name = 'Laborcontract');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,0,'get_SharedUsers',@max_sequence+1,'SharedUsers',0,'share','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_SharedUsers');
delimiter;

SET @tabid = (select tabid from ld_tab where name = 'Laborcontract');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,'-7','get_viewhistory',@max_sequence+1,'ViewHistory',0,'','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_viewhistory');
delimiter;

SET @tabid = (select tabid from ld_tab where name = 'Laborcontract');
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
SET @max_sequence=(SELECT max(sequence) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,'-10','get_changeview',@max_sequence+1,'ChangeView',0,'','','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_changeview');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_attachments_history` (
		`attachmentsid` INT ( 19 ) NOT NULL,
		`crmid` INT ( 19 ) COMMENT '单据id',
		`name` VARCHAR ( 255 ) COMMENT '原文件名',
		`newfile_name` VARCHAR ( 255 ),
		`type` VARCHAR ( 50 ),
		`path` TEXT,
		`size` VARCHAR ( 100 ),
		`imagefromtype` INT ( 19 ),
		`storage_location` VARCHAR ( 100 ) ,
		`upload_from` VARCHAR ( 100 ) ,
		`cloud_path` TEXT ,
		`description` TEXT ,
		`watermark` VARCHAR ( 10 ) ,
	PRIMARY KEY ( `attachmentsid` ) 
) ENGINE = INNODB;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_detailattachments_history` (
	`attachmentsid` INT ( 19 ) NOT NULL,
	`crmid` INT ( 19 ) COMMENT '单据id',
	`lineitem_id` INT ( 19 ) ,
	`name` VARCHAR ( 255 ) COMMENT '原文件名',
	`newfile_name` VARCHAR ( 255 ),
	`type` VARCHAR ( 50 ),
	`path` TEXT,
	`size` VARCHAR ( 100 ),
	`imagefromtype` INT ( 19 ),
	`storage_location` VARCHAR ( 100 ) ,
	`upload_from` VARCHAR ( 100 ) ,
	`cloud_path` TEXT ,
	`description` TEXT ,
	PRIMARY KEY ( `attachmentsid` ) 
) ENGINE = INNODB;
delimiter;

delete from ld_picklist_dependency where tabid in(select tabid from ld_tab where name='pricepolicy')
and sourcefield='pricepolicy_type' and targetfield='pricepolicy_forms';
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'BankAccountSet');
set @actionid = (SELECT actionid from ld_actionmapping where actionname = 'Advance');
DELETE from ld_profileallpermission where tabid = @tabid and operation = @actionid;
delimiter;

update ld_desk set fieldlabel='您的CRM系统密码已修改，请重新登录' where labelbol='OfflineNotification' and labeltype='jspop' and languagetype='zh';
delimiter;


SET @account_tabid = (select tabid from ld_tab where `name` = 'Accounts');
SET @expensebudget_tabid = (select tabid from ld_tab where `name` = 'ExpenseBudget');
DELETE FROM ld_relatedlists WHERE tabid = @account_tabid AND related_tabid = @expensebudget_tabid 
AND `name` = '1' AND related_coltable = 'ExpenseBudget.accountid';
delimiter;

update ld_entityname set tablename = 'ld_laborcontract' where modulename = 'laborcontract' and tablename = 'ld_attachments';
delimiter;

SET @disable_triggers=1;
UPDATE ld_cashbill SET cashtype = 'cashbill' WHERE cashtype = '收款';
UPDATE ld_cashbill INNER JOIN ld_crmentity ON ld_cashbill.source_list = ld_crmentity.crmid SET ld_cashbill.entitytype = ld_crmentity.setype
WHERE (ld_cashbill.cashtype = 'cashbill' OR ld_cashbill.cashtype = '收款') AND ( ld_cashbill.entitytype IS NULL OR ld_cashbill.entitytype = '' ) 
AND ld_crmentity.setype IS NOT NULL AND ld_crmentity.setype != '';
SET @disable_triggers=NULL;
delimiter;

SET @labelbol = 'REPORTFILE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'报表文件','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Report file','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REPORTSERVERADDRESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'报表服务器地址','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Report server address','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MINIPROGRAMNAME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'小程序名称','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Mini Program Name','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SHAREDESCRIPTION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'分享描述','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Share description','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SHAREIMAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'分享图片','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Share image','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUGGESTEDIMAGESIZE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'（建议图片尺寸比例宽*高：630*500）','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'(Suggested image size ratio: width * height: 630 * 500)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WHETHERDISPLAYINVOICE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否显示发票信息','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether to display invoice information','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2204-12-08

SET @labelbol = 'INDIVIDUAL_EFFECT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'个人生效','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Personal','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ALL_EFFECT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'全员生效','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Global','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_stuff','mobile_sequence','int','4',0);
UPDATE ld_stuff SET mobile_sequence = 1 WHERE stufftitle = 'commonmodules';
UPDATE ld_stuff SET mobile_sequence = 2 WHERE stufftitle = 'saleskit';
UPDATE ld_stuff SET mobile_sequence = 3 WHERE stufftitle = 'Contractkit';
UPDATE ld_stuff SET mobile_sequence = 4 WHERE stufftitle = 'DataDragonTigerList';
UPDATE ld_stuff SET mobile_sequence = 5 WHERE stufftitle = 'SaleDragonTiger';
UPDATE ld_stuff SET mobile_sequence = 6 WHERE stufftitle = 'CUSTOMERSOURCEDISSTATIST';
UPDATE ld_stuff SET mobile_sequence = 7 WHERE stufftitle = 'CUSTOMERTYPEDISSTATIS';
UPDATE ld_stuff SET mobile_sequence = 8 WHERE stufftitle = 'ContactTimesRanking';
UPDATE ld_stuff SET mobile_sequence = 9 WHERE stufftitle = 'SalesPhaseTransformationAnalysis';
UPDATE ld_stuff SET mobile_sequence = 10 WHERE stufftitle = 'SALESFUNNEL';
UPDATE ld_stuff SET mobile_sequence = 11 WHERE stufftitle = 'TargetAnalysis';
UPDATE ld_stuff SET mobile_sequence = 12 WHERE stufftitle = 'BACKAMOUNTMONTHYEAR';
UPDATE ld_stuff SET mobile_sequence = 13 WHERE stufftitle = 'AMOUNTMONTHCONTRACTYEAR';
UPDATE ld_stuff SET mobile_sequence = 14 WHERE stufftitle = 'CRITICALVIEW';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PASSWORD_DUPLICATION','新密码不可与旧密码相同','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PASSWORD_DUPLICATION' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PASSWORD_DUPLICATION',"The new password cannot be the same as the old password",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PASSWORD_DUPLICATION' and labeltype='jspop');
delimiter;

ALTER TABLE ld_collectionslip MODIFY COLUMN smownerid int(4) NULL;
delimiter;

SET @labelbol = 'SPECIALNAME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'专题名称','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Special Name','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
SET @labelbol = 'CREATESPECIAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增专题','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Create Special','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_stuff','pc_sequence','int','4',0);
UPDATE ld_stuff SET pc_sequence = 16 WHERE stufftitle = 'SALESSIXMONTH'; 
UPDATE ld_stuff SET pc_sequence = 21 WHERE stufftitle = 'ANNUALSALES';
UPDATE ld_stuff SET pc_sequence = 45 WHERE stufftitle = 'INVENTORYDATA';
UPDATE ld_stuff SET pc_sequence = 19 WHERE stufftitle = 'AMOUNTMONTHCONTRACTYEAR';
UPDATE ld_stuff SET pc_sequence = 37 WHERE stufftitle = 'BACKAMOUNTMONTHYEAR';
UPDATE ld_stuff SET pc_sequence = 26 WHERE stufftitle = 'RECEIVESUMMARY';
UPDATE ld_stuff SET pc_sequence = 24 WHERE stufftitle = 'SUBORDINATEMOTHSALESDATA';
UPDATE ld_stuff SET pc_sequence = 25 WHERE stufftitle = 'Penson Month Sales';
UPDATE ld_stuff SET pc_sequence = 15 WHERE stufftitle = 'INDIVIDUALSIXMONTH';
UPDATE ld_stuff SET pc_sequence = 47 WHERE stufftitle = 'OVERSERVENDAYSSCHEDULE';
UPDATE ld_stuff SET pc_sequence = 48 WHERE stufftitle = 'FUTURESEVENDAYSSCHEDULE';
UPDATE ld_stuff SET pc_sequence = 49 WHERE stufftitle = 'EXPIREDAGENDA';
UPDATE ld_stuff SET pc_sequence = 7 WHERE stufftitle = 'TODAYCONTACTCUSTOMER';
UPDATE ld_stuff SET pc_sequence = 9 WHERE stufftitle = 'LATESTPOTENTIALS';
UPDATE ld_stuff SET pc_sequence = 14 WHERE stufftitle = 'LATESTQUOTATION';
UPDATE ld_stuff SET pc_sequence = 20 WHERE stufftitle = 'NEWCONTRACTORDERS';
UPDATE ld_stuff SET pc_sequence = 33 WHERE stufftitle = 'LATESTINVOICE';
UPDATE ld_stuff SET pc_sequence = 11 WHERE stufftitle = 'SALESFUNNEL';
UPDATE ld_stuff SET pc_sequence = 50 WHERE stufftitle = 'CRITICALVIEW';
UPDATE ld_stuff SET pc_sequence = 52 WHERE stufftitle = 'NOTEPAD';
UPDATE ld_stuff SET pc_sequence = 32 WHERE stufftitle = 'WITHINPAYMENTPLAN';
UPDATE ld_stuff SET pc_sequence = 41 WHERE stufftitle = 'LATESTEXPENSE';
UPDATE ld_stuff SET pc_sequence = 35 WHERE stufftitle = 'LATESTCASHBILL';
UPDATE ld_stuff SET pc_sequence = 38 WHERE stufftitle = 'LATESTSENDCASHBILL';
UPDATE ld_stuff SET pc_sequence = 39 WHERE stufftitle = 'LATESTCASHDEPOSIT';
UPDATE ld_stuff SET pc_sequence = 40 WHERE stufftitle = 'LATESTPUTCASH';
UPDATE ld_stuff SET pc_sequence = 43 WHERE stufftitle = 'BANKCASH';
UPDATE ld_stuff SET pc_sequence = 51 WHERE stufftitle = 'PUBLICANNOUNCEMENT';
UPDATE ld_stuff SET pc_sequence = 22 WHERE stufftitle = 'SALESCHARTS';
UPDATE ld_stuff SET pc_sequence = 27 WHERE stufftitle = 'transaction';
UPDATE ld_stuff SET pc_sequence = 1 WHERE stufftitle = 'saleskit';
UPDATE ld_stuff SET pc_sequence = 53 WHERE stufftitle = 'PendingApproval';
UPDATE ld_stuff SET pc_sequence = 29 WHERE stufftitle = 'COMPLATIONRATESIXMONTH';
UPDATE ld_stuff SET pc_sequence = 34 WHERE stufftitle = 'INVOICEAMOUNTYEAR';
UPDATE ld_stuff SET pc_sequence = 44 WHERE stufftitle = 'OUTBOUNDORDERAMOUNTYEAR';
UPDATE ld_stuff SET pc_sequence = 46 WHERE stufftitle = 'Calendar';
UPDATE ld_stuff SET pc_sequence = 12 WHERE stufftitle = 'StatisticsPotentialsBySalesPersonAndSalesStage';
UPDATE ld_stuff SET pc_sequence = 13 WHERE stufftitle = 'StatisticalPotentialsByTheAccountIndustryAndSalesStage';
UPDATE ld_stuff SET pc_sequence = 8 WHERE stufftitle = 'ContactTimesRanking';
UPDATE ld_stuff SET pc_sequence = 23 WHERE stufftitle = 'ProductsSalesRanking';
UPDATE ld_stuff SET pc_sequence = 28 WHERE stufftitle = 'ServiceKanban';
UPDATE ld_stuff SET pc_sequence = 2 WHERE stufftitle = 'DataDragonTigerList';
UPDATE ld_stuff SET pc_sequence = 30 WHERE stufftitle = 'TARGETCOMPLETIONRATE';
UPDATE ld_stuff SET pc_sequence = 17 WHERE stufftitle = 'Contractnumber';
UPDATE ld_stuff SET pc_sequence = 18 WHERE stufftitle = 'Contractamount';
UPDATE ld_stuff SET pc_sequence = 36 WHERE stufftitle = 'STATISTICALRECEIVABLES';
UPDATE ld_stuff SET pc_sequence = 42 WHERE stufftitle = 'STATISTICALEXPENSECOMMISSION';
UPDATE ld_stuff SET pc_sequence = 5 WHERE stufftitle = 'CUSTOMERSOURCEDISSTATIST';
UPDATE ld_stuff SET pc_sequence = 6 WHERE stufftitle = 'CUSTOMERTYPEDISSTATIS';
UPDATE ld_stuff SET pc_sequence = 10 WHERE stufftitle = 'SalesPhaseTransformationAnalysis';
UPDATE ld_stuff SET pc_sequence = 4 WHERE stufftitle = 'LeadsFunnel';
UPDATE ld_stuff SET pc_sequence = 31 WHERE stufftitle = 'TargetAnalysis';
UPDATE ld_stuff SET pc_sequence = 3 WHERE stufftitle = 'LeadsAnalysis';
UPDATE ld_stuff SET pc_sequence = 54 WHERE stufftitle = 'Carousel';
UPDATE ld_stuff SET pc_sequence = 55 WHERE stufftitle = 'new_reminds';
delimiter;

CALL AddColumn('ld_communicationaccount','status','varchar','25','yes');
UPDATE ld_communicationaccount SET platform='tencent' WHERE platform='腾讯云';
UPDATE ld_communicationaccount SET platform='aliyun' WHERE platform='阿里云';
delimiter;


CREATE TABLE IF NOT EXISTS `ld_smsrelated` (
	`id` int(19) NOT NULL AUTO_INCREMENT,
	`relatedtable` varchar(100) DEFAULT '' COMMENT '关联的表名',
	`relatedid` int(19) DEFAULT NULL COMMENT '关联的表主键',
	`relatedmodulename` varchar(50) DEFAULT NULL COMMENT '关联的模块名称',
	`template_id` int(19) DEFAULT NULL COMMENT '短信模板表主键',
	`templateparamconf` text COMMENT '短信模板中需要替换的参数具体如何取值',
	`scene` varchar(50) DEFAULT NULL COMMENT '场景：标记为哪个功能使用的短信模板',
	`created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY  (`id`)
	) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TencentCloud','腾讯云','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TencentCloud' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TencentCloud','Tencent Cloud','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TencentCloud' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AliCloud','阿里云','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AliCloud' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AliCloud','Alibaba Cloud','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AliCloud' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SMSPlatform','短信账户类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SMSPlatform' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SMSPlatform','SMS Account Type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SMSPlatform' and labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','sdkappidandappkeyaliyun','AccessKeyId和AccessKeySecret必须与阿里云短信中保持一致','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='sdkappidandappkeyaliyun' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','sdkappidandappkeyaliyun','AccessKeyId and AccessKeySecret must be consistent with Alibaba cloud SMS.','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='sdkappidandappkeyaliyun' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','smsmustbeapprovedbyaliyun','短信模板必须在后台审批通过后才可成功发送','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='smsmustbeapprovedbyaliyun' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','smsmustbeapprovedbyaliyun',"The SMS template must be approved in the backend before it can be successfully sent.",'fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='smsmustbeapprovedbyaliyun' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InputVar','输入变量','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InputVar' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InputVar','Input variable','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InputVar' and Labeltype='fixedstr' and languagetype='en');
delimiter;
update ld_desk set fieldlabel='短信推送成功，等待返回结果！' where labelbol='smsSendTips' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='SMS push succeeded, waiting for the return result!' where labelbol='smsSendTips' and languagetype='en' and Labeltype='jspop';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMMUNICATIONNOTSETSMSTEMPLATE','请联系管理员再登录控制里设置短信模板','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='COMMUNICATIONNOTSETSMSTEMPLATE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMMUNICATIONNOTSETSMSTEMPLATE','Contact your system administrator to set the SMS template in the login control','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='COMMUNICATIONNOTSETSMSTEMPLATE' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','VAR','变量','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VAR' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','VAR','Variable','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VAR' and Labeltype='jspop');
delimiter;

CALL AddColumn('ld_smstemplates','templatecode','varchar','50','');
CALL AddColumn('ld_smstemplates','templatecontent','text','','');
CALL AddColumn('ld_smstemplates','templateparaminfo','text','','');
CALL AddColumn('ld_smstemplates','signname','varchar','50','');
CALL AddColumn('ld_smstemplates','platform','varchar','10','');
CALL AddColumn('ld_smstemplates','deleted','tinyint',2,0);
CALL AddColumn('ld_smstemplates','deletedreason','varchar','100','');
delimiter;
UPDATE ld_smstemplates SET platform='tencent' WHERE IFNULL(platform,'')='';
delimiter;

CALL AddColumn('ld_smssend','response','text','','');
CALL AddColumn('ld_smssend','templateparam','text','','');
CALL AddColumn('ld_smssend','templateid','int','19','');
CALL AddColumn('ld_smssend','platform','varchar','10','');
delimiter;
CALL addtableIndex('ld_smssend','idx_templateid','templateid');
delimiter;

DROP PROCEDURE IF EXISTS `addtableuniqueIndex`;
delimiter ||
CREATE  PROCEDURE `addtableuniqueIndex`(
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
		SET @sql3=CONCAT('alter  table ',tablename,' add unique index ',indexname,' (',columnlist,')' );
PREPARE statement_name FROM @sql3;
EXECUTE statement_name;
DEALLOCATE PREPARE statement_name;
END IF;

end ||
delimiter;

CALL addtableuniqueIndex('ld_smstemplates','idx_templatecode','templatecode');
DROP PROCEDURE IF EXISTS `addtableuniqueIndex`;
delimiter;

SET @labelbol = 'SELECTLOGO';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选择LOGO：','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Select LOGO','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
SET @labelbol = 'SELECTMINILOGO';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选择小LOGO：','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Select mini LOGO','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
SET @labelbol = 'SUGGESTEDSIZE14540PIXELS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'建议尺寸：140*40(像素)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Suggested size: 145 * 40 pixels','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
SET @labelbol = 'SUGGESTEDSIZE3636PIXELS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'建议尺寸：36*36(像素)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Suggested size: 36 * 36 pixels','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
SET @labelbol = 'IMAGESMAYBYDISPLAYED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'提醒：超出建议尺寸可能无法显示图片','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Reminder: Images may not be displayed if they exceed the recommended size','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_field SET label_style = '' WHERE label_style = '{"color":"#333333;"}';
UPDATE ld_field SET label_style = '' WHERE label_style = '{"color":"#666;"}';
delimiter;

SET @labelbol = 'fieldnotenabled';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未启用字段','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Field not enabled','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'clickdragfieldstoadd';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点击并从右边拖拽字段进行添加','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click and drag fields from the right to add','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2024-12-12


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill');
SET @columnname='deductionreceived_amount';
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @sequence=(SELECT MAX(sequence) FROM ld_field where tabid=@tabid and block = @relateid);
SET @fieldname='deductionreceived_amount';
SET @fieldlabel='预收抵扣总额';
SET @zh='预收抵扣总额';
SET @en='Total amount of deductions received in advance';
SET @uitype=71;
set @deploy_value = (select IFNULL(deploy_value,2) from ld_systems_deploy where deploy_type=351);
SET @typeofdata=CONCAT('N~O~25,',@deploy_value);
SET @quickcreate=0;
SET @displaytype=3;
SET @bigtype='currency';
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


SET @disable_triggers = '11';
CALL AddColumn (@tablename, @columnname, 'decimal', '25', '');
ALTER TABLE ld_cashbill MODIFY COLUMN deductionreceived_amount DECIMAL(25,8);
SET @disable_triggers = NULL;
delimiter;
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
delimiter;
call getallprofile('CashBill');
call fieldprofile('CashBill');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_deductionreceived_amount_detail_20241205`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_deductionreceived_amount_detail_20241205`(
)
BEGIN
	-- 明细字段插入
	DECLARE tmpsourcemodule VARCHAR(50) DEFAULT '';
	DECLARE tmptabid int(4) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR  SELECT ld_tab.`name`,ld_option_module.tabid as sourcemodule from ld_option_module 
		INNER JOIN ld_tab on ld_tab.tabid = ld_option_module.option_tabid where ld_option_module.tabid = (SELECT tabid from ld_tab WHERE `name`='CashBill');
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmpsourcemodule = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmpsourcemodule,tmptabid;

	WHILE(tmpsourcemodule IS NOT NULL) DO
		IF EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid = tmptabid and sourcemodule = tmpsourcemodule) THEN
			CALL ldcrm_add_deductionreceived_amount_productdetail_20241205(tmpsourcemodule,tmptabid);
		END IF;
		IF EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid = tmptabid and sourcemodule = tmpsourcemodule) THEN
			CALL ldcrm_add_deductionreceived_amount_tabledetail_20241205(tmpsourcemodule,tmptabid);
		END IF;
		FETCH MYCUSOR INTO tmpsourcemodule,tmptabid;

	END WHILE;
	CLOSE MYCUSOR;
END ||
delimiter;
DROP PROCEDURE IF EXISTS `ldcrm_add_deductionreceived_amount_productdetail_20241205`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_deductionreceived_amount_productdetail_20241205`(
    tmpsourcemodule VARCHAR(50),
    tmptabid INT(4)
)
BEGIN
	UPDATE ld_producttoolfield_seq SET ld_producttoolfield_seq.id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
	SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
	SET @columnname = 'deductionreceived_amount';
	SET @trantable='ld_producttoolfield';
	SET @tablename='ld_cashbill';
	SET @allowhide = 'yes';
	SET @fieldlabel = '预收抵扣总额';
	SET @zh='预收抵扣总额';
	SET @en='Total amount of deductions received in advance';
	set @deploy_value = (select IFNULL(deploy_value,2) from ld_systems_deploy where deploy_type=351);
	SET @typeofdata=CONCAT('N~O~25,',@deploy_value);
	SET @bigtype='currency';
	SET @uitype=38;
	SET @parentbigtype='';
	SET @newline=1;
	SET @edit_permission=1;
	SET @sourcemodule = IFNULL(tmpsourcemodule,'');
	SELECT IFNULL(sequence,2)-2 INTO @sequence FROM ld_producttoolfield where tabid=tmptabid and columnname ='total' LIMIT 1;

	INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type, fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
	SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,tmptabid,@tablename,45,@edit_permission,0,0,@newline,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND tablename=@tablename AND IFNULL(sourcemodule,1) = IFNULL(@sourcemodule,1) );

	SELECT producttoolfieldid INTO @relatedid FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND IFNULL(sourcemodule,1) = IFNULL(@sourcemodule,1) LIMIT 1;
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'zh',@trantable,tmptabid,@relatedid,@zh FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'en',@trantable,tmptabid,@relatedid,@en FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);

	UPDATE ld_producttoolfield_seq SET ld_producttoolfield_seq.id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
END ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_deductionreceived_amount_tabledetail_20241205`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_deductionreceived_amount_tabledetail_20241205`(
    tmpsourcemodule VARCHAR(50),
    tmptabid INT(4)
)
BEGIN
	UPDATE ld_tabdetailfield_seq SET ld_tabdetailfield_seq.id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
	SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
	SET @columnname = 'deductionreceived_amount';
	SET @trantable='ld_tabdetailfield';
	SET @tablename='ld_cashbill';
	SET @allowhide = 'yes';
	SET @fieldlabel = '预收抵扣总额';
	SET @zh='预收抵扣总额';
	SET @en='Total amount of deductions received in advance';
	set @deploy_value = (select IFNULL(deploy_value,2) from ld_systems_deploy where deploy_type=351);
	SET @typeofdata=CONCAT('N~O~25,',@deploy_value);
	SET @bigtype='amount';
	SET @uitype='Amount';
	SET @parentbigtype='';
	SET @newline=1;
	SET @edit_permission=1;
	SET @sourcemodule = IFNULL(tmpsourcemodule,'');
	SELECT IFNULL(sequence,2)-2 INTO @sequence FROM ld_tabdetailfield where tabid=tmptabid and columnname ='total' LIMIT 1;

	INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type, fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
	SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,tmptabid,@tablename,45,@edit_permission,0,0,@newline,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=tmptabid AND columnname=@columnname AND tablename=@tablename AND IFNULL(sourcemodule,1) = IFNULL(@sourcemodule,1) );

	SELECT tabdetailfieldid INTO @relatedid FROM ld_tabdetailfield WHERE tabid=tmptabid AND columnname=@columnname AND IFNULL(sourcemodule,1) = IFNULL(@sourcemodule,1) LIMIT 1;
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'zh',@trantable,tmptabid,@relatedid,@zh FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'en',@trantable,tmptabid,@relatedid,@en FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);

	UPDATE ld_tabdetailfield_seq SET ld_tabdetailfield_seq.id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
END ||
delimiter;
CALL ldcrm_add_deductionreceived_amount_detail_20241205();
DROP PROCEDURE IF EXISTS `ldcrm_add_deductionreceived_amount_detail_20241205`;
DROP PROCEDURE IF EXISTS `ldcrm_add_deductionreceived_amount_productdetail_20241205`;
DROP PROCEDURE IF EXISTS `ldcrm_add_deductionreceived_amount_tabledetail_20241205`;
delimiter;

SET @labelbol = 'dragdropsettings';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'可进行拖拽设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Drag and drop settings','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

update ld_field set uitype=1, bigtype='text'  where relatedmodulefield='yes' and bigtype  ='translatefield' AND parentbigtype = 'translatefield';
delimiter;

SET @labelbol = 'SQLREPORTINSTRUCTIONS_1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'变量名称尽量使用字母数字和下划线命名，字母在前数字在后，例如：account_name123；','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Variable names should be named using letters, numbers, and underscores, with letters before numbers. For example: account_name123;','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');

SET @labelbol = 'SQLREPORTINSTRUCTIONS_2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'在SQL中使用&#x007b;&#x007d;包裹，例如:变量account_name，在SQL中应当用&#x007b;account_name&#x007d;表示；','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Use &#x007b;&#x007d; wrapping in SQL, for example, the variable 'accountant name' should be represented as &#x007b;account name&#x007d; in SQL;",'fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');

SET @labelbol = 'SQLREPORTINSTRUCTIONS_3';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'同一个报表变量名请勿重复。','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Do not duplicate the same report variable name.','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SyncMsg','请检查接口参数是否配置正确！','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='SyncMsg' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SyncMsg',"Check whether the interface parameters are correctly configured!",'fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='SyncMsg' and labeltype='fixedstr');
delimiter;
-- 2024-12-13

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

UPDATE ld_version SET old_version='V8.6.4.9',current_version='V8.6.4.9',remark='V8.6.4.9-20241213',wx_version='V8.6.5.0';
delimiter;