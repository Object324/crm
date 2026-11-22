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


update ld_module_setting_byuser set content = 'https://help.51mis.com/' where label = 'HelpUrl_SettingsHelp';
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RemindsList','消息列表','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='RemindsList' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RemindsList','Reminds List','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='RemindsList' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ClassificationSettings','分类设置','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ClassificationSettings' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ClassificationSettings','Classification settings','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ClassificationSettings' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CREATECATEGORIES','新增分类','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CREATECATEGORIES' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CREATECATEGORIES','Create Categories','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CREATECATEGORIES' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YouHaveVarUnreadMessages','您有{Var}条未读消息','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='YouHaveVarUnreadMessages' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YouHaveVarUnreadMessages','You have {Var} unread messages','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='YouHaveVarUnreadMessages' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RemindsType','消息类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RemindsType' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RemindsType','Reminds type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RemindsType' and labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_customview','icon_path','text','','');
delimiter;

UPDATE ld_customview SET customcategory = 'RemindsNavBar' WHERE entitytype = 'Reminds' AND customcategory IS NULL;
delimiter;

UPDATE ld_customview SET `sequence` = `sequence`+1 WHERE entitytype = 'Reminds' AND customcategory = 'RemindsNavBar';
delimiter;

DROP PROCEDURE IF EXISTS `InsertRemindsCategory`;
delimiter ||
CREATE PROCEDURE InsertRemindsCategory()
BEGIN
    
	IF NOT EXISTS (select 1 from ld_customview where entitytype='Reminds' and viewname = 'allreminds')
		THEN
            DELETE from ld_cvcolumnlist where cvid not in (SELECT cvid from ld_customview);
            DELETE from ld_cvadvfilter where cvid not in (SELECT cvid from ld_customview);
            DELETE from ld_cvadvfilter_grouping where cvid not in (SELECT cvid from ld_customview);

            SET @maxcvid = (SELECT MAX(cvid) FROM ld_customview);
            INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, `status`, userid, `sequence`,customcategory , groupid)
            select @maxcvid+1, 'allreminds', '1', '0', 'Reminds', 3, '1', 0, 'RemindsNavBar', 0 from dual
            where NOT EXISTS (select 1 from ld_customview where entitytype='Reminds' and viewname = 'allreminds');

            SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = 'Reminds' AND viewname = 'allreminds' and customcategory = 'RemindsNavBar');
            INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
            select @cvid, 0, 'ld_reminds:content:content:Reminds_提醒内容:V' from dual
            where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

            INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
            select @cvid, 1, 'ld_reminds:reltab:reltab:Reminds_fieldlabel:V' from dual
            where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

            INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
            select @cvid, 2, 'ld_reminds:related_to:related_to:Reminds_fieldlabel:V' from dual
            where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

            INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
            select @cvid, 3, 'ld_reminds:date_time:date_time:Reminds_提醒时间:DT' from dual
            where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

            INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
            select @cvid, 4, 'ld_reminds:recieverid:recieverid:Reminds_fieldlabel:V' from dual
            where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

            INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
            select @cvid, 5, 'ld_reminds:smcreatorid:creator:Reminds_fieldlabel:V' from dual
            where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

            INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`)
            select @cvid, 6, 'ld_reminds:status_rmd:status_rmd:Reminds_fieldlabel:V' from dual
            where NOT EXISTS (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

			SET @maxcvid = (SELECT MAX(cvid) FROM ld_customview);
			SET @maxsequence = (SELECT IFNULL(MAX(sequence),-1) FROM ld_customview WHERE entitytype = 'Reminds' and customcategory = 'RemindsCategory');
			INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, `status`, userid, `sequence`,customcategory , groupid , icon_path)
			select @maxcvid+1, '全部消息', '0', '0', 'Reminds', 3, '1', @maxsequence+1, 'RemindsCategory', 0 , 'themes/icon2024/remindscategory-all.png' from dual;
			

			SET @maxcvid = (SELECT MAX(cvid) FROM ld_customview);
			SET @maxsequence = (SELECT IFNULL(MAX(sequence),-1) FROM ld_customview WHERE entitytype = 'Reminds' and customcategory = 'RemindsCategory');
			INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, `status`, userid, `sequence`,customcategory , groupid , icon_path)
			select @maxcvid+1, '待审批消息', '0', '0', 'Reminds', 3, '1', @maxsequence+1, 'RemindsCategory', 0 , 'themes/icon2024/remindscategory-approve.png' from dual;

			SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = 'Reminds' AND viewname = '待审批消息' and customcategory = 'RemindsCategory');
			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
			select @cvid, 0, 'ld_reminds:content:content:Reminds_fieldlabel:V', 'c', '需要审批', 1, '' from dual;

			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
			SELECT 1,@cvid,'',0 from dual;


			SET @maxcvid = (SELECT MAX(cvid) FROM ld_customview);
			SET @maxsequence = (SELECT IFNULL(MAX(sequence),-1) FROM ld_customview WHERE entitytype = 'Reminds' and customcategory = 'RemindsCategory');
			INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, `status`, userid, `sequence`,customcategory , groupid , icon_path)
			select @maxcvid+1, '审批通知', '0', '0', 'Reminds', 3, '1', @maxsequence+1, 'RemindsCategory', 0 , 'themes/icon2024/remindscategory-approvereminds.png' from dual;

			SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = 'Reminds' AND viewname = '审批通知' and customcategory = 'RemindsCategory');
			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
			select @cvid, 0, 'ld_reminds:content:content:Reminds_fieldlabel:V', 'belong', '已通过审批|未通过审批|审批并抄送', 1, 'and' from dual;

			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
			select @cvid, 1, 'ld_reminds:content:content:Reminds_fieldlabel:V', 'notbelong', '评论|回复', 1, 'and' from dual;

			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
			select @cvid, 2, 'ld_reminds:reltab:reltab:Reminds_fieldlabel:V', 'k', '工作汇报', 1, '' from dual;

			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
			SELECT 1,@cvid,'','0 and 1 and 2 ' from dual;


			SET @maxcvid = (SELECT MAX(cvid) FROM ld_customview);
			SET @maxsequence = (SELECT IFNULL(MAX(sequence),-1) FROM ld_customview WHERE entitytype = 'Reminds' and customcategory = 'RemindsCategory');
			INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, `status`, userid, `sequence`,customcategory , groupid , icon_path)
			select @maxcvid+1, '日程管理', '0', '0', 'Reminds', 3, '1', @maxsequence+1, 'RemindsCategory', 0 , 'themes/icon2024/remindscategory-calendar.png' from dual;

			SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = 'Reminds' AND viewname = '日程管理' and customcategory = 'RemindsCategory');
			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
			select @cvid, 0, 'ld_reminds:reltab:reltab:Reminds_fieldlabel:V', 'c', '日程管理', 1, '' from dual;

			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
			SELECT 1,@cvid,'',0 from dual;


			SET @maxcvid = (SELECT MAX(cvid) FROM ld_customview);
			SET @maxsequence = (SELECT IFNULL(MAX(sequence),-1) FROM ld_customview WHERE entitytype = 'Reminds' and customcategory = 'RemindsCategory');
			INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, `status`, userid, `sequence`,customcategory , groupid , icon_path)
			select @maxcvid+1, '公告', '0', '0', 'Reminds', 3, '1', @maxsequence+1, 'RemindsCategory', 0 , 'themes/icon2024/remindscategory-publicannouncement.png' from dual;

			SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = 'Reminds' AND viewname = '公告' and customcategory = 'RemindsCategory');
			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
			select @cvid, 0, 'ld_reminds:reltab:reltab:Reminds_fieldlabel:V', 'c', '公告', 1, '' from dual;

			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
			SELECT 1,@cvid,'',0 from dual;


			SET @maxcvid = (SELECT MAX(cvid) FROM ld_customview);
			SET @maxsequence = (SELECT IFNULL(MAX(sequence),-1) FROM ld_customview WHERE entitytype = 'Reminds' and customcategory = 'RemindsCategory');
			INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, `status`, userid, `sequence`,customcategory , groupid , icon_path)
			select @maxcvid+1, '工作汇报', '0', '0', 'Reminds', 3, '1', @maxsequence+1, 'RemindsCategory', 0 , 'themes/icon2024/remindscategory-workreport.png' from dual;

			SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = 'Reminds' AND viewname = '工作汇报' and customcategory = 'RemindsCategory');
			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
			select @cvid, 0, 'ld_reminds:reltab:reltab:Reminds_fieldlabel:V', 'c', '工作汇报', 1, '' from dual;

			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
			SELECT 1,@cvid,'',0 from dual;


			SET @maxcvid = (SELECT MAX(cvid) FROM ld_customview);
			SET @maxsequence = (SELECT IFNULL(MAX(sequence),-1) FROM ld_customview WHERE entitytype = 'Reminds' and customcategory = 'RemindsCategory');
			INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, `status`, userid, `sequence`,customcategory , groupid , icon_path)
			select @maxcvid+1, '工单管理', '0', '0', 'Reminds', 3, '1', @maxsequence+1, 'RemindsCategory', 0 , 'themes/icon2024/remindscategory-worksheet.png' from dual;

			SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = 'Reminds' AND viewname = '工单管理' and customcategory = 'RemindsCategory');
			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
			select @cvid, 0, 'ld_reminds:reltab:reltab:Reminds_fieldlabel:V', 'c', '工单管理', 1, '' from dual;

			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
			SELECT 1,@cvid,'',0 from dual;


			SET @maxcvid = (SELECT MAX(cvid) FROM ld_customview);
			SET @maxsequence = (SELECT IFNULL(MAX(sequence),-1) FROM ld_customview WHERE entitytype = 'Reminds' and customcategory = 'RemindsCategory');
			INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, `status`, userid, `sequence`,customcategory , groupid , icon_path)
			select @maxcvid+1, '市场活动', '0', '0', 'Reminds', 3, '1', @maxsequence+1, 'RemindsCategory', 0 , 'themes/icon2024/remindscategory-campaigns.png' from dual;

			SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = 'Reminds' AND viewname = '市场活动' and customcategory = 'RemindsCategory');
			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
			select @cvid, 0, 'ld_reminds:reltab:reltab:Reminds_fieldlabel:V', 'c', '市场活动', 1, '' from dual;

			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
			SELECT 1,@cvid,'',0 from dual;

	END IF;
END ||
delimiter;

CALL InsertRemindsCategory();
DROP PROCEDURE IF EXISTS `InsertRemindsCategory`;
delimiter;



UPDATE ld_customview_seq SET id = (SELECT MAX(cvid) FROM ld_customview);
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Reminds');
UPDATE ld_field SET typeofdata = 'V~M' WHERE tabid = @tabid AND columnname = 'reltab';
delimiter;

call addtableIndex('ld_reminds','reminds_deleted_is_del_rec_status_rmd','deleted, is_del_rec, status_rmd');
call addtableIndex('ld_reminds_accepted','reminds_accepted_deleted_is_del_rec_status_rmd','deleted, is_del_rec, status_rmd');
delimiter;

call AddColumn("ld_salestarget_basic",'displayinactiv','VARCHAR','10','no');
delimiter;

SET @labelbol = 'DisplayResignedMembers';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'显示离职成员',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display resigned members',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

CALL AddColumn('ld_picklist_values','listkey','varchar',255,'');
delimiter;

DROP PROCEDURE IF EXISTS addmodule_pricepolicy;
delimiter ||
CREATE PROCEDURE addmodule_pricepolicy()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM ld_tab WHERE `name` = 'PricePolicy') THEN

        -- 建表
        CREATE TABLE IF NOT EXISTS `ld_pricepolicy` (
                                                        `pricepolicyid` INT(11) NOT NULL,
                                                        `pricepolicy_no` VARCHAR(100) COMMENT 'Sales policy NO.',
                                                        `pricepolicy_name` VARCHAR(100) COMMENT 'Sales policy name',
                                                        `start_time` datetime COMMENT 'Start Time',
                                                        `end_time` datetime COMMENT 'End Time',
                                                        `description` text COMMENT 'Description',
                                                        `role_module` text COMMENT 'Role of Rules Module',
                                                        `role_module_scope` text COMMENT 'Scope of Rules Module',
                                                        `pricepolicy_type` VARCHAR(200) COMMENT 'Type of Policy',
                                                        `pricepolicy_forms` VARCHAR(200) COMMENT 'Forms of policy',
                                                        `recommended` VARCHAR(3) COMMENT 'Recommended?',
                                                        `bydefault` VARCHAR(3) COMMENT 'By default?',
                                                        `priority` INT(10) COMMENT 'Priority',
                                                        `smownerid` INT(11) COMMENT 'Smownerid',
                                                        `approvestatus` VARCHAR(50) COMMENT 'Approve Status',
                                                        `approvetime` datetime COMMENT 'Approve Time',
                                                        `approveby` INT(4) COMMENT 'Approve By',
                                                        `pricepolicy_scope` text COMMENT 'Scope of Policy',
                                                        `superposition_list` text COMMENT 'Superimposable List',
                                                        `smcreatorid` INT(4),
                                                        `createdtime` datetime ,
                                                        `modifiedby` INT(4),
                                                        `modifiedtime` datetime,
                                                        `currentapprover` text,
                                                        `latestpushtime` datetime,
                                                        `advance_stage` VARCHAR(100),
                                                        `exchtime` datetime,
                                                        `exchmsg` text,
                                                        `team_memberid` text,
                                                        `tag` text,
                                                        `Print_times` INT(4),
                                                        `approvesubmitter` INT(4),
                                                        `approveurgent` VARCHAR(100),
                                                        `approveexpediting` VARCHAR(100),
                                                        `Kis_id` INT(4),
                                                        `Kis_no` VARCHAR(50),
                                                        `deleted` SMALLINT(4) DEFAULT 0 ,
                                                        PRIMARY KEY (`pricepolicyid`),
                                                        INDEX index_time(start_time,end_time) USING BTREE COMMENT '对于时间这类范围查询，使用B树索引'
        ) ENGINE = INNODB ;

        CREATE TABLE IF NOT EXISTS `ld_pricepolicydetail` (
                                                              `id` INT(11),
                                                              `lineitem_id` INT(11) NOT NULL AUTO_INCREMENT,
                                                              `productid` INT(11) COMMENT '产品id',
                                                              `condition` VARCHAR(255) COMMENT '条件，数量区间，订单金额',
                                                              `present` INT(11) COMMENT '作为赠品的产品id',
                                                              `content` VARCHAR(255) COMMENT '活动内容，配合类型得出公式',
                                                              PRIMARY KEY (`lineitem_id`),
                                                              FOREIGN KEY (`id`) REFERENCES ld_pricepolicy(pricepolicyid)
        ) ENGINE = INNODB ;

        -- 	插入模块
        SELECT tabsequence INTO @tabsequence FROM ld_tab WHERE `name` = 'Products';
        UPDATE ld_tab SET tabsequence := tabsequence + 1 WHERE tabsequence > @tabsequence;

        SELECT MAX(tabid)+1 INTO @tabid FROM ld_tab ;
        SELECT tabsequence INTO @tabsequence FROM ld_tab WHERE `name`='PricePolicy';
        INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab )
        SELECT @tabid,'PricePolicy',0,@tabsequence+1,'PricePolicy',1 FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_tab WHERE `name`='PricePolicy');

        SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='PricePolicy';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh','ld_tab',@tabid,@tabid,'价格政策' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab' );
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en','ld_tab',@tabid,@tabid,'Price Policy' FROM DUAL
        WHERE NOT EXISTS(SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');

        -- 	插入菜单栏
        SET @parenttabid = NULL;
        SET @pre_sequence = NULL;
        SELECT ld_tab.tabid INTO @pre_tabid FROM ld_tab WHERE ld_tab.`name` = 'Products' LIMIT 1;
        SELECT parenttabid INTO @parenttabid FROM ld_parenttab WHERE parenttab_label='Tools' LIMIT 1;
        SELECT MAX(sequence) + 1 INTO @pre_sequence FROM ld_parenttabrel WHERE parenttabid=@parenttabid LIMIT 1;
        SELECT pr.parenttabid INTO @parenttabid FROM ld_parenttabrel pr WHERE pr.tabid = @pre_tabid LIMIT 1;
        SELECT pr.sequence INTO @pre_sequence FROM ld_parenttabrel pr WHERE pr.tabid = @pre_tabid LIMIT 1;
        IF @parenttabid IS NOT NULL THEN
            UPDATE ld_parenttabrel SET sequence := sequence + 1 WHERE sequence > @pre_sequence;
            INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
            SELECT @parenttabid,@tabid,@pre_sequence,'ld_tab' FROM DUAL
            WHERE NOT EXISTS ( SELECT 1 FROM ld_parenttabrel WHERE parenttabid = @parenttabid AND tabid = @tabid AND tab_tablename = 'ld_tab' );
        END IF;

        -- 	字段区块
        SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PricePolicy';
        SELECT MAX(blockid) + 1 INTO @blockid FROM ld_blocks;
        INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
        SELECT @blockid,@tabid,'LBL_PricePolicy_INFO',1 FROM DUAL
        WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_PricePolicy_INFO' AND sequence = 1);

        UPDATE ld_blocks_seq SET id=@blockid;

        SET @blockid = (SELECT  blockid FROM ld_blocks WHERE tabid = @tabid AND blocklabel='LBL_PricePolicy_INFO');
        INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
        SELECT 'zh', 'ld_blocks', @tabid, @blockid, '基本信息' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE  tabid =@tabid AND languagetype ='zh' AND fieldlabel ='基本信息');
        INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
        SELECT  'en', 'ld_blocks', @tabid, @blockid, 'Basic Information' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE  tabid =@tabid AND languagetype ='en' AND fieldlabel ='Basic Information');

        -- 字段
        SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='PricePolicy';
        SET @tablename='ld_pricepolicy';
        SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid=@tabid and blocklabel='LBL_PricePolicy_INFO';

        SET @columnname='pricepolicy_no';
        SET @fieldname='pricepolicy_no';
        SET @zh='单据编号';
        SET @uitype=4;
        SET @bigtype='moduleno';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='pricepolicy_name';
        SET @fieldname='pricepolicy_name';
        SET @zh='政策名称';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='start_time';
        SET @fieldname='start_time';
        SET @zh='政策开始时间';
        SET @uitype=86;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='DT~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='end_time';
        SET @fieldname='end_time';
        SET @zh='政策结束时间';
        SET @uitype=86;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='DT~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='description';
        SET @fieldname='description';
        SET @zh='政策描述';
        SET @uitype=21;
        SET @bigtype='textarea';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='role_module';
        SET @fieldname='role_module';
        SET @zh='政策作用模块';
        SET @uitype=33;
        SET @bigtype='multipicklist_key';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='role_module_scope';
        SET @fieldname='role_module_scope';
        SET @zh='政策适用范围';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=5;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='pricepolicy_type';
        SET @fieldname='pricepolicy_type';
        SET @zh='政策类型';
        SET @uitype=15;
        SET @bigtype='picklist_key';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='pricepolicy_forms';
        SET @fieldname='pricepolicy_forms';
        SET @zh='政策形式';
        SET @uitype=15;
        SET @bigtype='picklist_key';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='priority';
        SET @fieldname='priority';
        SET @zh='优先级';
        SET @uitype=7;
        SET @bigtype='number';
        SET @readonly=0;
        SET @presence=2;
        SET @defaultvalue=1;
        SET @displaytype=1;
        SET @typeofdata='NN~M~25,0';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SET @helptips = '输入的序号越小，规则的触发顺序越靠前。触发顺序相同的规则，将会同时执行';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,helptips)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide,@helptips FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='recommended';
        SET @fieldname='recommended';
        SET @zh='设置为推荐政策';
        SET @uitype=56;
        SET @bigtype='boolean';
        SET @readonly=0;
        SET @presence=2;
        SET @defaultvalue='';
        SET @displaytype=1;
        SET @typeofdata='C~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='smownerid';
        SET @fieldname='assigned_user_id';
        SET @zh='负责人';
        SET @uitype=53;
        SET @bigtype='users';
        SET @readonly=1;
        SET @presence=0;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='bydefault';
        SET @fieldname='bydefault';
        SET @zh='设置为默认使用政策';
        SET @uitype=56;
        SET @bigtype='boolean';
        SET @readonly=0;
        SET @presence=2;
        SET @defaultvalue='';
        SET @displaytype=1;
        SET @typeofdata='C~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='createdtime';
        SET @fieldname='createdtime';
        SET @zh='创建时间';
        SET @uitype=70;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='DT~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='modifiedby';
        SET @fieldname='modifiedby';
        SET @zh='更新人';
        SET @uitype=52;
        SET @bigtype='users';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='yes';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='modifiedtime';
        SET @fieldname='modifiedtime';
        SET @zh='更新时间';
        SET @uitype=70;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='DT~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='approvestatus';
        SET @fieldname='approvestatus';
        SET @zh='审批状态';
        SET @uitype=609;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='approvetime';
        SET @fieldname='approvetime';
        SET @zh='最新审批时间';
        SET @uitype=70;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='DT~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='approveby';
        SET @fieldname='approveby';
        SET @zh='上一步审批人';
        SET @uitype=131;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='currentapprover';
        SET @fieldname='currentapprover';
        SET @zh='当前审批人';
        SET @uitype=132;
        SET @bigtype='users';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='latestpushtime';
        SET @fieldname='latestpushtime';
        SET @zh='最新推进时间';
        SET @uitype=86;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='DT~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='advance_stage';
        SET @fieldname='advance_stage';
        SET @zh='推进阶段';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='exchtime';
        SET @fieldname='exchtime';
        SET @zh='最新同步时间';
        SET @uitype=86;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='DT~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='exchmsg';
        SET @fieldname='exchmsg';
        SET @zh='最新同步结果';
        SET @uitype=86;
        SET @bigtype='datetime';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='DT~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='team_memberid';
        SET @fieldname='team_memberid';
        SET @zh='团队成员';
        SET @uitype=154;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='tag';
        SET @fieldname='tag';
        SET @zh='标签';
        SET @uitype=301;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=1;
        SET @typeofdata='V~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='print_times';
        SET @fieldname='print_times';
        SET @zh='打印次数';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=2;
        SET @typeofdata='N~O';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='pricepolicy_scope';
        SET @fieldname='pricepolicy_scope';
        SET @zh='可用用户范围';
        SET @uitype=1;
        SET @bigtype='text';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=5;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

        SET @columnname='superposition_list';
        SET @fieldname='superposition_list';
        SET @zh='允许叠加的价格政策设置';
        SELECT IF(MAX(uitype + 0 ) < 2000, 2001, MAX(uitype + 0) + 1) as uitype INTO @uitype FROM ld_ws_fieldtype;
        SET @bigtype='multireference';
        SET @readonly=1;
        SET @presence=2;
        SET @defaultvalue=NULL;
        SET @displaytype=5;
        SET @typeofdata='V~M';
        SET @quickcreate=1;
        SET @quickcreatesequence=NULL;
        SET @info_type='BAS';
        SET @masseditable=1;
        SET @allowhide='no';
        SELECT MAX(sequence) + 1 INTO @seq FROM ld_field WHERE tabid=@tabid AND block=@blockid;
        SELECT max(fieldid) + 1 INTO @fieldid FROM ld_field;
        INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
        SELECT @tabid,@fieldid,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
        -- 多选字段
        INSERT INTO ld_ws_fieldtype (`uitype`, `fieldtype`)
        SELECT @uitype, 'multireference' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
        SELECT fieldtypeid INTO @fieldtypeid FROM ld_ws_fieldtype WHERE uitype = @uitype;
        INSERT INTO ld_ws_multireferencetype (`fieldtypeid`, `type`)
        SELECT @fieldtypeid, 'PricePolicy' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);


        UPDATE ld_field_seq SET id=@seq;

        -- 下拉框字段
        INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
        SELECT  'pricepolicy_type', 'ld_field', NULL, NULL FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_set WHERE listname ='pricepolicy_type');
        SET @listid = (SELECT listid FROM ld_picklist_set WHERE listname ='pricepolicy_type');
        INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`, `listkey` )
        SELECT @listid, '整单促销', 1, 'order' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listvalue='整单促销' AND listid =@listid);
        INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`, `listkey`  )
        SELECT @listid, '产品促销', 2, 'product' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listvalue='产品促销' AND listid =@listid);

        INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
        SELECT  'pricepolicy_forms', 'ld_field', NULL, NULL FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_set WHERE listname ='pricepolicy_forms');
        SET @listid = (SELECT listid FROM ld_picklist_set WHERE listname ='pricepolicy_forms');
        INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`, `listkey`  )
        SELECT @listid, '打折', 1, 'product_discount' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listvalue='打折' AND listid =@listid);
        INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`, `listkey`  )
        SELECT @listid, '减免', 2, 'product_reduced' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listvalue='减免' AND listid =@listid);
        INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`, `listkey`  )
        SELECT @listid, '一口价', 3, 'product_fixed' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listvalue='一口价' AND listid =@listid);
        INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`, `listkey`  )
        SELECT @listid, '买赠', 4, 'product_present' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listvalue='买赠' AND listid =@listid);
        INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`, `listkey`  )
        SELECT @listid, '满折', 5, 'order_discount' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listvalue='满折' AND listid =@listid);
        INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`, `listkey`  )
        SELECT @listid, '满减', 6, 'order_reduced' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listvalue='满减' AND listid =@listid);
        INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`, `listkey`  )
        SELECT @listid, '满赠', 7, 'order_present' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listvalue='满赠' AND listid =@listid);

        -- 级联关系
        SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='PricePolicy';

        SELECT MAX(id)+1 INTO @id FROM ld_picklist_dependency;
        INSERT INTO ld_picklist_dependency (`id`, `tabid`, `sourcefield`, `targetfield`, `sourcevalue`, `targetvalues`, `criteria`)
        SELECT @id, @tabid, 'pricepolicy_type', 'pricepolicy_forms', 'product', '[\"product_discount\",\"product_reduced\",\"product_fixed\",\"product_present\"]', '' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE sourcefield='pricepolicy_type' AND sourcevalue = '产品促销');

        SELECT MAX(id)+1 INTO @id FROM ld_picklist_dependency;
        INSERT INTO ld_picklist_dependency (`id`, `tabid`, `sourcefield`, `targetfield`, `sourcevalue`, `targetvalues`, `criteria`)
        SELECT @id, @tabid, 'pricepolicy_type', 'pricepolicy_forms', 'order', '[\"order_discount\",\"order_reduced\",\"order_present\"]', '' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_dependency WHERE sourcefield='pricepolicy_type' AND sourcevalue = '整单促销');

        UPDATE ld_picklist_dependency_seq SET id=(SELECT max(id) FROM ld_picklist_dependency);

        -- 	字段中英文翻译
        SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`="PricePolicy");
        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pricepolicy_no' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='单据编号';
        SET @en='No.';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pricepolicy_name' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='政策名称';
        SET @en='Name of Policy';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='start_time' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='政策开始时间';
        SET @en='Start Time';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='end_time' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='政策结束时间';
        SET @en='End Time';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='description' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='政策描述';
        SET @en='Description';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='role_module' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='政策作用模块';
        SET @en='Role of Rules Module';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='role_module_scope' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='政策适用范围';
        SET @en='Scope of Policy';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pricepolicy_type' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='政策类型';
        SET @en='Type of Policy';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pricepolicy_forms' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='政策形式';
        SET @en='Forms of Policy';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='recommended' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='设置为推荐政策';
        SET @en='Recommended ?';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bydefault' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='设置为默认使用政策';
        SET @en='By default ?';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='priority' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='优先级';
        SET @en='Priority';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='负责人';
        SET @en='Assigned To';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pricepolicy_scope' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='可用用户范围';
        SET @en='Available user scope';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='superposition_list' LIMIT 1);
        SET @trantable='ld_field';
        SET @zh='允许叠加的价格政策设置';
        SET @en='Superposition List';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


        -- 	查询分类
        SELECT MAX(cvid) + 1 INTO @maxcvid FROM ld_customview;
        INSERT INTO ld_customview ( cvid,viewname,setdefault,setmetrics,entitytype,STATUS,userid,sequence )
        SELECT @maxcvid,'All',1,0,'PricePolicy',3,1,1 FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype = 'PricePolicy' AND viewname = 'All');

        UPDATE ld_customview_seq SET id = @maxcvid;

        SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'PricePolicy';
        SELECT cvid INTO @cvid FROM ld_customview WHERE entitytype = 'PricePolicy' AND viewname = 'All';

        INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
        SELECT @tabid, 'ld_pricepolicy:pricepolicy_no:pricepolicy_no:PricePolicy_fieldlabel:V', 0, @cvid FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@cvid AND sequence=0);

        INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
        SELECT @tabid, 'ld_pricepolicy:pricepolicy_name:pricepolicy_name:PricePolicy_fieldlabel:V', 1, @cvid FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@cvid AND sequence=1);

        INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
        SELECT @tabid, 'ld_pricepolicy:start_time:start_time:PricePolicy_fieldlabel:DT', 2, @cvid FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@cvid AND sequence=2);

        INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
        SELECT @tabid, 'ld_pricepolicy:end_time:end_time:PricePolicy_fieldlabel:DT', 3, @cvid FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@cvid AND sequence=3);

        INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
        SELECT @tabid, 'ld_pricepolicy:description:description:PricePolicy_fieldlabel:V', 4, @cvid FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@cvid AND sequence=4);

        INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
        SELECT @tabid, 'ld_pricepolicydetail:entitytypeid:entitytypeid:PricePolicyDetails_fieldlabel:V', 5, @cvid FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=@cvid AND sequence=5);

        -- 单据编号规则
        SET @tmp_modulename = 'PricePolicy';
        SELECT id+1 INTO @modentity_num_seq FROM ld_modentity_num_seq;
        INSERT INTO `ld_modentity_num`(`num_id`, `semodule`, `prefix`, `start_id`, `cur_id`, `active`, `datetype`, `UseUserAccount`, `isallow`, `prefixtype`)
        SELECT @modentity_num_seq, @tmp_modulename, 'CXHD-', '1', '1', '1', 'none', 0, 0, 0  FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_modentity_num WHERE  semodule = @tmp_modulename);

        UPDATE ld_modentity_num_seq SET id =( SELECT max(num_id) FROM ld_modentity_num );

        -- 超链接字段
        SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @tmp_modulename;
        INSERT INTO `ld_entityname`(`tabid`, `modulename`, `tablename`, `fieldname`, `entityidfield`, `entityidcolumn`)
        SELECT @tabid, @tmp_modulename, 'ld_pricepolicy', 'pricepolicy_no', 'pricepolicyid', 'pricepolicyid' FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid = @tabid);

        -- 权限
        CALL getallprofile(@tmp_modulename);
        CALL fieldprofile(@tmp_modulename);
        CALL addtabintoprofile(@tmp_modulename,1);

        SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @tmp_modulename;
        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 1, 1 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=1);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 2, 2 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=2 );

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 3, 3 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=3);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 4, 4 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=4);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 5, 5 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=5);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 6, 6 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=6);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 11, 7 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=11);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 12, 8 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=12);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 13, 9 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=13);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 14, 10 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=14);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 22, 13 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=22);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 25, 11 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=25);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 37, 12 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=37);

        INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`)
        SELECT  @tabid, 57, 14 FROM  DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=37);

        -- 非产品分录字段
        SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'PricePolicy';
        SET @detailtablename = 'ld_pricepolicydetail';

        SELECT MAX(tabdetailfieldid)+1 INTO @tabdetailfieldid FROM ld_tabdetailfield;
        SET @columnname = 'productid';
        SET @allowhide = 'no';
        SET @fieldlabel = '产品ID';
        SET @fieldtype = '';
        SET @typeofdata='V~M~100';
        SET @bigtype='';
        SET @parentbigtype='';
        SELECT IFNULL(MAX(sequence)+1,1) INTO @sequence FROM ld_tabdetailfield WHERE tabid=@tabid;
        SET @referencemodule = '';
        SET @sourcemodule = '';
        INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule,subtotal_attr)
        SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence,@tabid,@detailtablename,100,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule,'yes' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname AND tablename=@detailtablename AND sourcemodule=@sourcemodule);

        SELECT MAX(tabdetailfieldid)+1 INTO @tabdetailfieldid FROM ld_tabdetailfield;
        SET @columnname = 'condition';
        SET @allowhide = 'no';
        SET @fieldlabel = '条件';
        SET @fieldtype = '';
        SET @typeofdata='Text';
        SET @bigtype='';
        SET @parentbigtype='';
        SELECT IFNULL(MAX(sequence)+1,1) INTO @sequence FROM ld_tabdetailfield WHERE tabid=@tabid;
        SET @referencemodule = '';
        SET @sourcemodule = '';
        INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule,subtotal_attr)
        SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence,@tabid,@detailtablename,100,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule,'yes' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname AND tablename=@detailtablename AND sourcemodule=@sourcemodule);

        SELECT MAX(tabdetailfieldid)+1 INTO @tabdetailfieldid FROM ld_tabdetailfield;
        SET @columnname = 'content';
        SET @allowhide = 'no';
        SET @fieldlabel = '内容';
        SET @fieldtype = 'Text';
        SET @typeofdata='V~O~';
        SET @bigtype='';
        SET @parentbigtype='';
        SELECT IFNULL(MAX(sequence)+1,1) INTO @sequence FROM ld_tabdetailfield WHERE tabid=@tabid;
        SET @referencemodule = '';
        SET @sourcemodule = '';
        INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule,subtotal_attr)
        SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence,@tabid,@detailtablename,100,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule,'yes' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname AND tablename=@detailtablename AND sourcemodule=@sourcemodule);

        SELECT MAX(tabdetailfieldid)+1 INTO @tabdetailfieldid FROM ld_tabdetailfield;
        SET @columnname = 'present';
        SET @allowhide = 'no';
        SET @fieldlabel = '赠送的产品ID';
        SET @fieldtype = '';
        SET @typeofdata='V~M~100';
        SET @bigtype='';
        SET @parentbigtype='';
        SELECT IFNULL(MAX(sequence)+1,1) INTO @sequence FROM ld_tabdetailfield WHERE tabid=@tabid;
        SET @referencemodule = '';
        SET @sourcemodule = '';
        INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule,subtotal_attr)
        SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence,@tabid,@detailtablename,100,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule,'yes' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname AND tablename=@detailtablename AND sourcemodule=@sourcemodule);

        UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);

        SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'PricePolicy';
        SET @trantable='ld_tabdetailfield';

        SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='productid' LIMIT 1);
        SET @zh='产品';
        SET @en='Product';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='condition' LIMIT 1);
        SET @zh='条件';
        SET @en='Condition';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='present' LIMIT 1);
        SET @zh='赠品';
        SET @en='Present';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='content' LIMIT 1);
        SET @zh='内容';
        SET @en='Content';
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

        -- 选择产品需要这个字段
        SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
        SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='PricePolicy';
        SET @columnname = 'productname';
        SET @trantable='ld_producttoolfield';
        SET @allowhide = 'no';
        SET @fieldlabel = '产品名称';
        SET @zh='产品名称';
        SET @en='Product Name';
        SET @uitype = 70;
        SET @typeofdata='V~M~100';
        SET @bigtype='selectsource';
        SET @parentbigtype='';
        SELECT IFNULL(MAX(sequence),1) INTO @sequence FROM ld_producttoolfield where tabid=@tabid;
        SET @tablename = 'ld_products';
        SET @sourcemodule = 'PricePolicy';
        SELECT tabid INTO @producttabid FROM ld_tab WHERE `name`='Products';
        SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @producttabid AND fieldname = 'productname';
        INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
                                        fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
        SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,45,0,0,@fieldid,0,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname AND tablename=@tablename );

        UPDATE ld_producttoolfield_seq SET ld_producttoolfield_seq.id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);

        SELECT producttoolfieldid INTO @relatedid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname;
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'zh',@trantable,@tabid,@relatedid,@zh FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND tabid=@tabid AND relateid=@relatedid AND trantable=@trantable);
        INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        SELECT 'en',@trantable,@tabid,@relatedid,@en FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND tabid=@tabid AND relateid=@relatedid AND trantable=@trantable);


    END IF;
END ||
delimiter;

CALL addmodule_pricepolicy();
delimiter;


SET @labelbol = 'LBI_PRICEPOLICY_SETTINGS';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'价格政策设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'PricePolicy Settings',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);

SELECT MAX(fieldid) + 1 INTO @fieldid FROM ld_settings_field;
SELECT blockid INTO @blockid FROM ld_settings_blocks WHERE label = 'LBI_FUNCTION_SETTINGS';
SET @link = 'index.php?module=Settings&action=BusinessInformation&parenttab=Settings';
SELECT MAX(sequence) + 1 INTO @sequence FROM ld_settings_field WHERE blockid = @blockid;
INSERT INTO ld_settings_field(`fieldid`,`blockid`,`name`,`iconpath`,`description`,`linkto`,`sequence`, `active`)
SELECT @fieldid, @blockid, @labelbol, '', '价格政策设置', @link, @sequence, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_settings_field WHERE blockid = @blockid AND `name` = @labelbol);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_pricepolicy_settings` (
     `id` SMALLINT(4) NOT NULL AUTO_INCREMENT,
     `module` VARCHAR(50) COMMENT '所属模块',
     `sequence` SMALLINT(4) COMMENT '顺序',
     `type` VARCHAR(50) COMMENT '类型',
     `value` VARCHAR(255) COMMENT '值',
     PRIMARY KEY (`id`)
) ENGINE = INNODB;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_producttotal_and_cumulativebenefits`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_producttotal_and_cumulativebenefits`()
BEGIN

    DECLARE tmptabid INT(11) DEFAULT 0;
    DECLARE tmpsourcemodule VARCHAR(50) DEFAULT '';
    DECLARE tmpuitype INT(10) DEFAULT 0;
    DECLARE tmptypeofdata VARCHAR(20) DEFAULT 'N~O~25,2';
    DECLARE tmptablename VARCHAR(50) DEFAULT 'ld_products';

    DECLARE MYCUSOR CURSOR FOR SELECT tabid,sourcemodule,uitype,typeofdata,tablename FROM ld_producttoolfield WHERE columnname = 'total';

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmptabid = NULL;

    OPEN MYCUSOR;
    FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmpuitype,tmptypeofdata,tmptablename;
    WHILE(tmptabid IS NOT NULL) DO
			SET @disable_triggers=1;
            SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
            SET @columnname = 'product_licence_price';
            SET @trantable='ld_producttoolfield';
            SET @allowhide = 'no';
            SET @fieldlabel = '产品总价';
            SET @zh='产品总价';
            SET @en='Product licence price';
            SET @bigtype='currency';
            SET @parentbigtype='';
            SET @newline=1;
            SET @edit_permission=1;
            SELECT IFNULL(MAX(sequence),1) INTO @sequence FROM ld_producttoolfield where tabid=tmptabid;
            INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type, fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
            SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,tmpuitype,tmptypeofdata,@sequence+1,tmptabid,tmptablename,45,@edit_permission,0,0,@newline,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,tmpsourcemodule FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND tablename=tmptablename AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) );

            SELECT producttoolfieldid INTO @relatedid FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) LIMIT 1;
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'zh',@trantable,tmptabid,@relatedid,@zh FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'en',@trantable,tmptabid,@relatedid,@en FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);

            CALL AddColumn (tmptablename,@columnname,'decimal','(25,8)',0);

            SET @exec_sql = CONCAT('UPDATE ',tmptablename,' SET ', @columnname, ' = total WHERE (total <> 0 OR total IS NOT NULL) AND ', @columnname, ' = 0');
            PREPARE mystmt FROM @exec_sql;
            EXECUTE mystmt;
            DEALLOCATE PREPARE mystmt;

            SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
            SET @columnname = 'cumulative_benefits';
            SET @trantable='ld_producttoolfield';
            SET @allowhide = 'no';
            SET @fieldlabel = '累计优惠';
            SET @zh='累计优惠';
            SET @en='Cumulative Benefits';
            SET @bigtype='currency';
            SET @parentbigtype='';
            SET @newline=1;
            SET @edit_permission=1;
            SELECT IFNULL(MAX(sequence),1) INTO @sequence FROM ld_producttoolfield where tabid=tmptabid;
            INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type, fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
            SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,tmpuitype,tmptypeofdata,@sequence+1,tmptabid,tmptablename,45,@edit_permission,0,0,@newline,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,tmpsourcemodule FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND tablename=tmptablename AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) );

            SELECT producttoolfieldid INTO @relatedid FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) LIMIT 1;
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'zh',@trantable,tmptabid,@relatedid,@zh FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'en',@trantable,tmptabid,@relatedid,@en FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);

            CALL AddColumn (tmptablename,@columnname,'decimal','(25,8)',0);

            UPDATE ld_producttoolfield a
                LEFT JOIN ld_producttoolfield b ON b.tabid = a.tabid AND b.tablename = a.tablename AND IFNULL(b.sourcemodule,1) = IFNULL(a.sourcemodule,1) AND b.columnname = 'cumulative_benefits'
            SET a.sequence = (b.sequence+1) WHERE a.columnname='total';

            UPDATE ld_producttoolfield_seq SET ld_producttoolfield_seq.id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @disable_triggers=NULL;
            FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmpuitype,tmptypeofdata,tmptablename;
        END WHILE;

    CLOSE MYCUSOR;
END ||
delimiter;


CALL ldcrm_add_producttotal_and_cumulativebenefits();
delimiter;

ALTER TABLE ld_module_setting_byuser MODIFY type VARCHAR(50);

delete from ld_module_setting_byuser where modulename='CallRecordLog' and userid is null;
delete from ld_module_setting_byuser where modulename='electronicsignet' and userid is null;
delimiter;

UPDATE ld_systems_deploy SET deploy_value='no' WHERE deploy_type=482 AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='Accounts');

DROP PROCEDURE IF EXISTS `ldcrm_add_detailfield_ispresent`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_detailfield_ispresent`()
BEGIN

    DECLARE tmptabid INT(11) DEFAULT 0;
    DECLARE tmpsourcemodule VARCHAR(50) DEFAULT '';
    DECLARE tmpuitype INT(10) DEFAULT 0;
    DECLARE tmptypeofdata VARCHAR(20) DEFAULT 'V~O~4';
    DECLARE tmptablename VARCHAR(50) DEFAULT 'ld_products';

    DECLARE MYCUSOR CURSOR FOR SELECT tabid,sourcemodule,uitype,tablename FROM ld_producttoolfield WHERE columnname = 'tax_amount';

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmptabid = NULL;

    OPEN MYCUSOR;
    FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmpuitype,tmptablename;
    WHILE(tmptabid IS NOT NULL) DO

            SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
            SET @columnname = 'is_present';
            SET @trantable='ld_producttoolfield';
            SET @allowhide = 'no';
            SET @fieldlabel = '是否为赠品';
            SET @zh='是否为赠品';
            SET @en='Is not present';
            SET @bigtype='currency';
            SET @parentbigtype='';
            SET @newline=3;
            SET @edit_permission=1;
            SELECT IFNULL(MAX(sequence),1) INTO @sequence FROM ld_producttoolfield where tabid=tmptabid;
            INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type, fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
            SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,tmpuitype,tmptypeofdata,@sequence+1,tmptabid,tmptablename,45,@edit_permission,0,0,@newline,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,tmpsourcemodule FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND tablename=tmptablename AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) );

            SELECT producttoolfieldid INTO @relatedid FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) LIMIT 1;
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'zh',@trantable,tmptabid,@relatedid,@zh FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'en',@trantable,tmptabid,@relatedid,@en FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);

            CALL AddColumn (tmptablename,@columnname,'VARCHAR','3','no');

            UPDATE ld_producttoolfield_seq SET ld_producttoolfield_seq.id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);

            FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmpuitype,tmptablename;
        END WHILE;

    CLOSE MYCUSOR;
END ||
delimiter;

CALL ldcrm_add_detailfield_ispresent();
delimiter;

DROP PROCEDURE IF EXISTS addmodule_pricepolicy;
DROP PROCEDURE IF EXISTS `ldcrm_add_detailfield_ispresent`;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_pricepolicy_use` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键，自增',
    `module` VARCHAR(50) COMMENT '模块名',
    `user` INT(19) COMMENT '用户id',
    `record` INT(19) COMMENT '关联单据id',
    `pricepolicyid` INT(11) COMMENT '政策id',
    PRIMARY KEY (`id`)
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `ld_pricepolicy_use_history` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键，自增',
    `module` VARCHAR(50) COMMENT '模块名',
    `time` datetime COMMENT '使用时间',
    `user` INT(19) COMMENT '用户id',
    `record` INT(19) COMMENT '关联单据id',
    `pricepolicyid` INT(11) COMMENT '政策id',
    PRIMARY KEY (`id`)
) ENGINE = INNODB;
delimiter;

UPDATE ld_customview SET `status` = 3 WHERE entitytype = 'Reminds' and customcategory = 'RemindsCategory' AND icon_path is NOT NULL;
delimiter;
-- 2024-09-22

DROP PROCEDURE IF EXISTS `ldcrm_update_product_licence_price`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_product_licence_price`()
BEGIN

    DECLARE tmptabid INT(11) DEFAULT 0;
    DECLARE tmpsourcemodule VARCHAR(50) DEFAULT '';
    DECLARE tmpuitype INT(10) DEFAULT 0;
    DECLARE tmptypeofdata VARCHAR(20) DEFAULT 'N~O~25,6';
    DECLARE tmptablename VARCHAR(50) DEFAULT 'ld_products';

    DECLARE MYCUSOR CURSOR FOR SELECT tabid,sourcemodule,uitype,typeofdata,tablename FROM ld_producttoolfield WHERE columnname = 'product_licence_price';

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmptabid = NULL;

    OPEN MYCUSOR;
    FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmpuitype,tmptypeofdata,tmptablename;
    WHILE(tmptabid IS NOT NULL) DO
			SET @disable_triggers=1;
            SET @exec_sql = CONCAT('UPDATE ',tmptablename,' SET product_licence_price = total WHERE (total <> 0 OR total IS NOT NULL) AND product_licence_price = 0');
            PREPARE mystmt FROM @exec_sql;
            EXECUTE mystmt;
            DEALLOCATE PREPARE mystmt;
			SET @disable_triggers=NULL;
            FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmpuitype,tmptypeofdata,tmptablename;
        END WHILE;

    CLOSE MYCUSOR;
END ||
delimiter;

CALL ldcrm_update_product_licence_price();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_product_licence_price`;
delimiter;

ALTER TABLE ld_pricepolicy_use MODIFY COLUMN `user` INT(19);
ALTER TABLE ld_pricepolicy_use MODIFY COLUMN `record` INT(19);
ALTER TABLE ld_pricepolicy_use_history MODIFY COLUMN `user` INT(19);
ALTER TABLE ld_pricepolicy_use_history MODIFY COLUMN `record` INT(19);
delimiter;

ALTER TABLE ld_pricepolicy MODIFY COLUMN `priority` INT(10);
delimiter;

SELECT MAX(cvid) + 1 INTO @maxcvid FROM ld_customview;
UPDATE ld_customview_seq SET id = @maxcvid;
delimiter;

SET @tabid=(SELECT tabid from ld_tab where `name` = 'Questionnaire');
SET @relateid=(SELECT block from ld_field where tabid = @tabid and columnname = 'smownerid');
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename from ld_field where tabid = @tabid and columnname = 'smownerid');
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

SET @presence = '0';
SET @trantable='ld_field';
SET @columnname='accountid';
SET @fieldname='account_id';
SET @zh='客户名称';
SET @en='Account Name';
SET @uitype=73;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='reference';
SET @datarang='permit';
SET @maxrowsshow=10;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @disallowed_copy = 'yes';

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit,disallowed_copy)
SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,IFNULL(@presence,1),NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit,@disallowed_copy from dual
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

call AddColumn(@tablename,'accountid','int','19','');
delimiter;

set @cur_module = 'Accounts';set @option_module = 'Questionnaire';
set @tabid = (SELECT tabid from ld_tab where `name` = @cur_module);
set @option_tabid = (SELECT tabid from ld_tab where `name` = @option_module);
SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,@option_tabid,CONCAT('get_',LOWER(@option_module)),@i+1,@option_module,1,'add','questionnaire.accountid','datacategory_sql' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@option_tabid AND `name`=CONCAT('get_',LOWER(@option_module)));
delimiter;


SET @tabid=(SELECT tabid from ld_tab where `name` = 'Questionnaire');
set @sequence = (select sequence from ld_field where tabid = @tabid and columnname = 'name');
set @sequencenew = (select sequence from ld_field where tabid = @tabid and columnname = 'accountid');
update ld_field set sequence = sequence+1 where tabid = @tabid and sequence > @sequence and @sequencenew <> (@sequence + 1);
update ld_field set sequence = @sequence+1 where tabid = @tabid and columnname = 'accountid';
delimiter;

select tabid into @tabid  from ld_tab where name='PricePolicy';
update ld_field set bigtype='multireference' where tabid=@tabid and columnname='superposition_list';

select uitype into @uitype from ld_field where tabid=@tabid and   columnname='superposition_list';

insert into ld_ws_fieldtype( uitype,fieldtype)
select @uitype,'multireference' from dual
where not exists (select 1 from ld_ws_fieldtype where uitype=@uitype);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=@uitype;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid, 'PricePolicy' from dual
where not exists (select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid);
delimiter;


CREATE TABLE IF NOT EXISTS `ld_pricepolicy_use_present` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键，自增',
    `module` VARCHAR(50) COMMENT '模块名',
    `record` INT(19) COMMENT '单据id',
    `lineitem_id` INT(11) COMMENT '赠品行分录的id',
    `pricepolicyid` INT(11) COMMENT '政策id',
    `pricepolicy_lineitem_id` INT(11) COMMENT '政策的分录id',
    PRIMARY KEY (`id`)
) ENGINE = INNODB;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_relationshipChart` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `frommodule` varchar(50) DEFAULT NULL COMMENT '模块名',
    `fromrecord` int(19) DEFAULT NULL COMMENT '模块单据id',
    `chartmodule` varchar(50) DEFAULT NULL COMMENT '图谱相关模块名',
    `chartid` int(19) DEFAULT NULL COMMENT '图谱id',
    `nodeid` int(19) DEFAULT NULL COMMENT '节点id',
    `parentnodeid` int(19) DEFAULT NULL COMMENT '上级节点id',
    `childrennodeid` varchar(100) DEFAULT NULL COMMENT '下级节点id',
    `chartrecord` int(19) DEFAULT 0 COMMENT '节点上的单据id',
    `oldchartrecord` int(19) DEFAULT 0 COMMENT '节点前一个单据id',
    `haverecordchart` varchar(20) DEFAULT 'yes' COMMENT '锁定状态',
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `modifiedtime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`)
    ) ENGINE = INNODB;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_relationshipChartListData` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `frommodule` varchar(50) NULL COMMENT '模块名',
    `fromrecord` int(19) NULL COMMENT '模块单据id',
    `chartmodule` varchar(50) NULL COMMENT '图谱相关模块名',
    `records` text NULL COMMENT '图谱左侧列表的单据id',
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
    ) ENGINE = INNODB;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_relationshipChartLockStatus` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `frommodule` varchar(50) NULL COMMENT '模块名',
    `fromrecord` int(19) NULL COMMENT '模块单据id',
    `chartmodule` varchar(50) NULL COMMENT '图谱相关模块名',
    `record` int(19) NULL COMMENT '图谱单据id',
    `lockstatus` varchar(20) DEFAULT 'yes' COMMENT '锁定状态',
    PRIMARY KEY (`id`)
    ) ENGINE = INNODB;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @mobile_seq=(SELECT MAX(mobile_sequence) FROM ld_relatedlists WHERE tabid=@tabid);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,buttonstatus)
SELECT @relation_id+1,@tabid,'-20','get_relationshipChart',@seq+1,'Accounts_relationshipChart',0,'add',0,@mobile_seq+1,'datacategory_sql','no' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND label='Accounts_relationshipChart' AND `name`='get_relationshipChart' AND related_tabid = '-20');
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

insert into ld_moduledatashowview(frommodule,modulename,columns,sequence)
select 'Default','Accounts','ld_account:accountname:accountname:Accounts_fieldlabel:V',1 from dual
where not exists(select 1 from ld_moduledatashowview where frommodule = 'Default' and modulename='Accounts' and `columns`='ld_account:accountname:accountname:Accounts_fieldlabel:V');
delimiter;
insert into ld_moduledatashowview(frommodule,modulename,columns,sequence)
select 'Default','Accounts','ld_contactdetails:lastname:lastname:Accounts_fieldlabel:V',2 from dual
where not exists(select 1 from ld_moduledatashowview where frommodule = 'Default' and modulename='Accounts' and `columns`='ld_contactdetails:lastname:lastname:Accounts_fieldlabel:V');
delimiter;
insert into ld_moduledatashowview(frommodule,modulename,columns,sequence)
select 'Default','Accounts','ld_contactdetails:mobile:mobile:Accounts_fieldlabel:V',3 from dual
where not exists(select 1 from ld_moduledatashowview where frommodule = 'Default' and modulename='Accounts' and `columns`='ld_contactdetails:mobile:mobile:Accounts_fieldlabel:V');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AccountsRelationshipChart','客户图谱','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AccountsRelationshipChart' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AccountsRelationshipChart','Accounts Relationship Chart','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AccountsRelationshipChart' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','getrelationshipChartByParenid','根据"{Var}"生成客户图谱','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'getrelationshipChartByParenid' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','getrelationshipChartByParenid','Generate customer graph based on the "{Var}" field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'getrelationshipChartByParenid' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GenerateImmediately','立即生成','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'GenerateImmediately' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GenerateImmediately','Generate immediately','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'GenerateImmediately' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectRelevantCustomers','选择相关{Var}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SelectRelevantCustomers' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectRelevantCustomers','Select relevant "{Var}"','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SelectRelevantCustomers' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DRAGCONTACTTOCHART','可将此处的{Var}拖拽到右侧图谱待添加中','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'DRAGCONTACTTOCHART' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DRAGCONTACTTOCHART','You can drag {Var} here to the map on the right to be added','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'DRAGCONTACTTOCHART' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','getrelationshipChartByParenidTip','该图谱为根据"{Var}"字段自动生成，如需修改请点击编辑','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'getrelationshipChartByParenidTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','getrelationshipChartByParenidTip','This chart is automatically generated based on the fields of "{Var}". If you need to modify it, please click edit','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'getrelationshipChartByParenidTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','getrelationshipChartByParenidMessageTip','是否使用上级单位字段自动生成的图谱覆盖现有图谱和相关客户？','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'getrelationshipChartByParenidMessageTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','getrelationshipChartByParenidMessageTip','Do you want to use the automatically generated graph from the superior unit fields to overwrite the existing graph and related customers?','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'getrelationshipChartByParenidMessageTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','getrelationshipChartByParenidMessageNoTip','该客户没有上下级关系，无法生成图谱，请手动选择相关客户进行图谱设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'getrelationshipChartByParenidMessageNoTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','getrelationshipChartByParenidMessageNoTip','This customer has no hierarchical relationship, can not generate the atlas, please manually select the relevant customers for the atlas settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'getrelationshipChartByParenidMessageNoTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WhetherToTakeNode','是否带出下级节点？','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WhetherToTakeNode' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WhetherToTakeNode','Do you want to bring out subordinate nodes?','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WhetherToTakeNode' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BroughtOutRelatedRecords','您选择的客户有相关图谱客户，已一并带出','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BroughtOutRelatedRecords' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BroughtOutRelatedRecords',' The customers you have selected have related customers that have been brought out together','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BroughtOutRelatedRecords' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNLOCKSAVETIPS','当前图谱中客户的图谱被锁定，请先解锁','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'UNLOCKSAVETIPS' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNLOCKSAVETIPS',' The customers you have selected have related customers that have been brought out together','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'UNLOCKSAVETIPS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RepeatCustomersSaveTip','当前图谱中存在客户重复','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'RepeatCustomersSaveTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RepeatCustomersSaveTip','There are duplicate customers in the current chart','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'RepeatCustomersSaveTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDMODULEMAPINPCTIP','请在PC端添加{Var}图谱','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ADDMODULEMAPINPCTIP' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDMODULEMAPINPCTIP','Please add {Var} Chart on the PC','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ADDMODULEMAPINPCTIP' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDMODULEMAPINPCTIP2','当前图谱中存在重复的客户，点击按钮进行査看','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ADDMODULEMAPINPCTIP2' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDMODULEMAPINPCTIP2','There are duplicate customers in the current chart. Click the button to check','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ADDMODULEMAPINPCTIP2' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShareSettings','共享设置','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShareSettings' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShareSettings','Share Settings','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShareSettings' and labeltype='jspop' and languagetype='en');
delimiter;

update ld_field set bigtype='date' where fieldname='allocatedate' and tablename='ld_leads';
delimiter;

select tabid into @tabid from ld_tab where name='Questionnaire';
select actionid  into @actionid1 from ld_actionmapping where actionname='COPY';
select MAX(sequence) into @sequence from ld_profileallpermission where tabid=@tabid;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@actionid1,@sequence+1 FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation =@actionid1 );
delimiter;
-- 2024-09-26

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

UPDATE ld_version SET old_version='V8.6.4.5',current_version='V8.6.4.5',remark='V8.6.4.5-20240926',wx_version='V8.6.4.0';
delimiter;