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

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ALLTIME','全部时间','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLTIME' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ALLTIME','All time','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLTIME' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MAXFILENUMBER','最多文件数为6','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MAXFILENUMBER' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MAXFILENUMBER','The maximum number of files is 6','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MAXFILENUMBER' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','COPYID','复制字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='COPYID' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','COPYID','Copy field','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='COPYID' and labeltype='jspop');
delimiter;

set @acc_tabid = (SELECT tabid from ld_tab WHERE `name` = 'Accounts');
set @ser_tabid = (SELECT tabid from ld_tab WHERE `name` = 'ServiceCharge');
UPDATE ld_field set allowhide = 'yes' where fieldname = 'lastname' and (tabid = @acc_tabid or tabid = @ser_tabid);
delimiter;

UPDATE ld_desk SET fieldlabel='不能选择源单以外的产品！' where labelbol='SELECTPRODUCTLINEITEM' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='Cannot choose the product outside of source single!' where labelbol='SELECTPRODUCTLINEITEM' and languagetype='en' and Labeltype='jspop';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','INCULDECURUSER','包含当前操作员','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INCULDECURUSER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','INCULDECURUSER','Include current operator','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INCULDECURUSER' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='是当前操作员' where labelbol='CURUSER' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='Is current operator' where labelbol='CURUSER' and languagetype='en' and Labeltype='fixedstr';
delimiter;
-- 2023-02-19

ALTER TABLE ld_salesorder MODIFY COLUMN received_amount DECIMAL(25,8) DEFAULT 0;
ALTER TABLE ld_servicecontracts MODIFY COLUMN received_amount DECIMAL(25,8) DEFAULT 0;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Virtual_block','虚拟区块','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Virtual_block' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Virtual_block','Virtual block','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Virtual_block' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','automatic_number','题目自动编号','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='automatic_number' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','automatic_number','Topic automatic numbering','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='automatic_number' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Automatic_number_style','自动编号样式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Automatic_number_style' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Automatic_number_style','Automatic numbering style','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Automatic_number_style' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Automatic_number_postfix','自动编号后缀','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Automatic_number_postfix' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Automatic_number_postfix','Automatic number postfix','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Automatic_number_postfix' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','blocknotshow','（区块不显示，只显示区块下的题目）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='blocknotshow' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','blocknotshow','(The block will not be displayed, only the topic will be displayed)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='blocknotshow' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODIFIEDBLOCK','编辑区块','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MODIFIEDBLOCK' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODIFIEDBLOCK','modified block','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MODIFIEDBLOCK' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETEQUESTIONNAIREBLOCK','该问卷已有回收数据，删除区块操作会将区块下的题目一起删除，并无法在统计图表看到删除题目的回收数据，确定要删除吗？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEQUESTIONNAIREBLOCK' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETEQUESTIONNAIREBLOCK','This questionnaire has collected data. Deleting the block will delete the items under the block together, and the collected data of the deleted items will not be visible in the statistical chart. Are you sure you want to delete?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEQUESTIONNAIREBLOCK' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANTDELETEBLOCK','该区块下的问题已有回收数据，不允许删除!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CANTDELETEBLOCK' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANTDELETEBLOCK','The question under this block has recycled data, and cannot be deleted!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CANTDELETEBLOCK' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QuestionnaireChartsave','数据详情','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='QuestionnaireChartsave' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QuestionnaireChartsave','Data details','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='QuestionnaireChartsave' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOQUESTIONNAIREHTML','您的问卷尚未完成设置，暂不能分享。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOQUESTIONNAIREHTML' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOQUESTIONNAIREHTML','Your questionnaire has not been set up yet, and cannot be shared temporarily.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOQUESTIONNAIREHTML' and Labeltype='fixedstr' and languagetype='en');
delimiter;


call AddColumn('ld_questionnaire_topic','blockid','int','11',0);
delimiter;

set @tabid = (SELECT tabid from ld_tab WHERE `name` = 'Questionnaire');
set @relationid = (select id from ld_relatedlists_seq LIMIT 1) + 1;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,actions,mobile_presence,buttonstatus)
select @relationid,@tabid,'-14','get_QuestionnaireChartsave','3','QuestionnaireChartsave','select',1,'yes' from dual
where not exists(select 1 from ld_relatedlists where tabid=@tabid and `name`='get_QuestionnaireChartsave' and label='QuestionnaireChartsave');
set @max_relationid = (select max(relation_id) from ld_relatedlists);
update ld_relatedlists_seq set id = @max_relationid;
delimiter;

ALTER TABLE ld_questionnaire ALTER COLUMN `status` SET DEFAULT '暂停';
delimiter;

CREATE TABLE if not EXISTS `ld_questionnaire_block` (
    `blockid` int(11) NOT NULL AUTO_INCREMENT,
    `questionnaireid` int(11) DEFAULT NULL,
    `blockname` varchar(255) DEFAULT NULL,
    `autonumber` varchar(10) DEFAULT NULL,
    `numberstyle` varchar(10) DEFAULT NULL,
    `numbersuffix` varchar(10) DEFAULT NULL,
    `blocktype` varchar(10) DEFAULT NULL,
    `sequence` int(4) DEFAULT NULL,
    `deleted` int(4) DEFAULT '0',
    `createdtime` datetime DEFAULT NULL,
    `modifiedtime` datetime DEFAULT NULL,
    PRIMARY KEY (`blockid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

set @tabid = (SELECT tabid from ld_tab where `name` = 'WeChatUser');
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

UPDATE ld_def_org_share set permission = 3,editstatus = 0 where tabid = @tabid and IFNULL(permission,'') = '';
delimiter;

SET @labelbol = 'TIPOFBILL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'(温馨提示：光标定位在$字段名称$中按下Ctrl+Enter键可以更改当前行及之后所有行的$字段名称$)','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'(Tip: The cursor is located in the $field name$ and press Ctrl+Enter to change the $field name$ of the current line and all subsequent lines)','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @actionid = (select max(actionid) from ld_actionmapping)+1;
INSERT into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT @actionid,'BatchOnShelves',0,'BATCHONSHELVES' from dual 
where not EXISTS (SELECT 1 from ld_actionmapping where actionname = 'BatchOnShelves');

SET @actionid = (select max(actionid) from ld_actionmapping)+1;
INSERT into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT @actionid,'BatchOffShelves',0,'BATCHOFFSHELVES' from dual 
where not EXISTS (SELECT 1 from ld_actionmapping where actionname = 'BatchOffShelves');

SET @operation=(SELECT actionid FROM ld_actionmapping WHERE actionname='BatchOffShelves');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Products');
SET @desequence = (SELECT sequence FROM ld_profileallpermission WHERE tabid=14 AND operation=6);
UPDATE ld_profileallpermission SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@desequence;
INSERT INTO ld_profileallpermission(tabid,operation,sequence) SELECT @tabid,@operation,@desequence+1 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@operation);
delimiter;

SET @operation=(SELECT actionid FROM ld_actionmapping WHERE actionname='BatchOnShelves');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Products');
SET @desequence = (SELECT sequence FROM ld_profileallpermission WHERE tabid=14 AND operation=6);
UPDATE ld_profileallpermission SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@desequence;
INSERT INTO ld_profileallpermission(tabid,operation,sequence) SELECT @tabid,@operation,@desequence+1 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@operation);
delimiter;

SET @labelbol = 'BATCHONSHELVES';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'批量上架','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Batch on shelves','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'BATCHOFFSHELVES';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'批量下架','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Batch off shelves','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_customreport_chartset','legend_position','varchar','100','');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOUBLECLICKTOSEEDETAILS','双击查看详情','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOUBLECLICKTOSEEDETAILS' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOUBLECLICKTOSEEDETAILS','Double-click to see details','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOUBLECLICKTOSEEDETAILS' and labeltype='jspop');
delimiter;

SET @labelbol = 'TREECHATSALESGOAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'销售目标完成情况树状图','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'dendrogram of sales target completion','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'TEMPLATESALESGOALIMG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'销售目标完成情况统计图','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Statistical chart of sales target completion','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'SAVEASIMAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'保存为图片','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Save as image','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='没有暂存信息！' where labelbol='NotStaging' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='No staging information!' where labelbol='NotStaging' and languagetype='en' and Labeltype='jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreatTopic','新增题目','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreatTopic' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreatTopic','Add Topic','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreatTopic' and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @tabid = (SELECT tabid from ld_tab WHERE `name` = 'Questionnaire');
set @namesequence = (select sequence from ld_field where tabid = @tabid and columnname = 'name');
update ld_field set sequence = @namesequence+1 where tabid = @tabid and columnname = 'category';
update ld_field set sequence = @namesequence+2 where tabid = @tabid and columnname = 'description';
update ld_field set sequence = @namesequence+3 where tabid = @tabid and columnname = 'recoverys';
delimiter;

call AddColumn('ld_field','isenablepresence','char','10','yes');
UPDATE ld_field SET isenablepresence = 'yes' where IFNULL(isenablepresence,'') = '';
delimiter;

CALL AddColumn('ld_salesorder_electronicsignet', 'sponsorid', 'int', '11', '');
delimiter;

UPDATE ld_field_seq SET id = (select MAX(fieldid) from ld_field);
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
SET @sequence=(SELECT sequence FROM ld_field WHERE `tabid`=@tabid AND columnname='contract_type');
SET @block=(SELECT block FROM ld_field WHERE `tabid`=@tabid AND columnname='contract_type');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype)
SELECT @tabid,@maxfieldid+1,'sponsorid','yes','ld_salesorder_electronicsignet',1,52,'sponsorid','合同发起人',1,0,@sequence,@block ,2,'V~O',1,0,0,2,'users' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='sponsorid');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='sponsorid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'合同发起人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Contract sponsor' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;


UPDATE ld_field_seq SET id = (select MAX(fieldid) from ld_field);
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
SET @sequence=(SELECT sequence FROM ld_field WHERE `tabid`=@tabid AND columnname='sponsorid');
SET @block=(SELECT block FROM ld_field WHERE `tabid`=@tabid AND columnname='sponsorid');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'flowstatus','yes','ld_salesorder_electronicsignet',1,1,'flowstatus','签章状态',1,0,@sequence,@block ,2,'V~O',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='flowstatus');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='flowstatus');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'签章状态' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'flowstatus' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

UPDATE ld_field_seq SET id = (select MAX(fieldid) from ld_field);
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes');
SET @sequence=(SELECT sequence FROM ld_field WHERE `tabid`=@tabid AND columnname='potentialid');
SET @block=(SELECT block FROM ld_field WHERE `tabid`=@tabid AND columnname='potentialid');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype)
SELECT @tabid,@maxfieldid+1,'sponsorid','yes','ld_salesorder_electronicsignet',1,52,'sponsorid','合同发起人',1,0,@sequence,@block ,2,'V~O',1,0,0,2,'users' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='sponsorid');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='sponsorid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'合同发起人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Contract sponsor' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

UPDATE ld_field_seq SET id = (select MAX(fieldid) from ld_field);
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes');
SET @sequence=(SELECT sequence FROM ld_field WHERE `tabid`=@tabid AND columnname='sponsorid');
SET @block=(SELECT block FROM ld_field WHERE `tabid`=@tabid AND columnname='sponsorid');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'flowstatus','yes','ld_salesorder_electronicsignet',1,1,'flowstatus','签章状态',1,0,@sequence,@block ,2,'V~O',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='flowstatus');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='flowstatus');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'签章状态' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'flowstatus' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;
-- 2023-02-24

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

UPDATE ld_version SET old_version='V8.4.9.0',current_version='V8.4.9.0',remark='V8.4.9.0-20230224',wx_version='V8.4.9.0';
delimiter;