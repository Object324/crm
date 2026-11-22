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


CREATE TABLE IF NOT EXISTS `ld_reminds_agenda` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `remindsid` int(11) NOT NULL,
    `agendadata` TEXT COMMENT '待办消息参数json',
    `approvelogid` int(11) NOT NULL COMMENT '审批日志表主键id',
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `modifiedtime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX idx_remindsid (remindsid),
    INDEX idx_approvelogid (approvelogid)
    ) ENGINE=InnoDB;
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Salary';
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='house_rental_deduction' LIMIT 1);
SET @trantable='ld_field';
SET @zh='住房租金抵扣';
SET @en='House rental deduction';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

UPDATE ld_desk SET fieldlabel = '显示上期数据（如：本月和上月对比）' WHERE labelbol = 'SHOWPREVIOUSPERIODDATA' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Display previous period data (e.g. this month versus last month)' WHERE labelbol = 'SHOWPREVIOUSPERIODDATA' AND languagetype = 'en';
UPDATE ld_desk SET fieldlabel = '上期数据计算方式' WHERE labelbol = 'EqualDuration' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Calculation method for previous period data' WHERE labelbol = 'EqualDuration' AND languagetype = 'en';
delimiter;

SET @labelbol = 'EqualDurationYes';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按当前时间的截止日计算',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Calculated on the deadline of the current time',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'EqualDurationNo';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按整月、周、季或年计算',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Calculated by whole month, week, quarter, or year',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_saleskitset_showpercent_default`;
delimiter ||
CREATE PROCEDURE `ldcrm_saleskitset_showpercent_default`()
BEGIN

    DECLARE tmp_boardid INT(11) DEFAULT 0;
    DECLARE tmp_stuffid INT(11) DEFAULT 0;
    DECLARE tmp_boardstuffid INT(19) DEFAULT 0;

    DECLARE MYCUSOR CURSOR FOR SELECT boardid,stuffid,boardstuffid from ld_homeboard_plate_stuff WHERE stuffid = 35;

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_boardid = NULL;

    SET @settype = 'SalesKit_ShowPercent';

    OPEN MYCUSOR;
        FETCH MYCUSOR INTO tmp_boardid,tmp_stuffid,tmp_boardstuffid;
        WHILE(tmp_boardid IS NOT NULL) DO
            INSERT INTO ld_homeboard_plate_setting(boardid,stuffid,boardstuffid,type,setvalue)
            SELECT tmp_boardid,tmp_stuffid,tmp_boardstuffid,@settype,'yes' FROM DUAL
            WHERE NOT EXISTS (
                    SELECT 1 FROM ld_homeboard_plate_setting WHERE boardid = tmp_boardid AND stuffid = tmp_stuffid AND boardstuffid = tmp_boardstuffid AND type = @settype
                );

            FETCH MYCUSOR INTO tmp_boardid,tmp_stuffid,tmp_boardstuffid;
        END WHILE;
    CLOSE MYCUSOR;
END ||
delimiter;

CALL ldcrm_saleskitset_showpercent_default();
delimiter;

UPDATE ld_translatefield SET column_Dbvalue = 'supsign' WHERE columnname = 'signout_type' AND labelbol = 'SUPSIGN' AND column_Dbvalue = 'supsignout';
UPDATE ld_signout SET signout_type = 'supsign' WHERE signout_type = 'supsignout';
UPDATE ld_singin SET signout_type = 'supsign' WHERE signout_type = 'supsignout';

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','CHECKWORKFLOW','触发工作流','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'CHECKWORKFLOW' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','CHECKWORKFLOW','Trigger workflow','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'CHECKWORKFLOW' AND labeltype = 'fixedstr');
delimiter;


INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','CHECKWORKFLOWTIP','说明：触发工作流调用API和连接ERP时不接收返回状态和提示','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'CHECKWORKFLOWTIP' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','CHECKWORKFLOWTIP','Do not receive return status and prompts when triggering workflow API calls and connecting to ERP','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'CHECKWORKFLOWTIP' AND labeltype = 'fixedstr');
delimiter;

update ld_field set quickcreate=1 where columnname='pretax_salary_total' and tabid=362;
delimiter;

UPDATE ld_tab set mobilepresence='mobile,weixin' WHERE `name`='Reminds';
delimiter;

INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
SELECT 'Reminds', '1', '1', 'ld_reminds:reltab:reltab:Reminds_相关模块:M', '0', NULL, '0', 'no', 'yes', 'yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_cvcolumnlist_wx WHERE modulename = 'Reminds' AND columnname = 'ld_reminds:reltab:reltab:Reminds_相关模块:M');

INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
SELECT 'Reminds', '2', '1', 'ld_reminds:related_to:related_to:Reminds_相关对象:V', '0', NULL, '0', 'no', 'yes', 'yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_cvcolumnlist_wx WHERE modulename = 'Reminds' AND columnname = 'ld_reminds:related_to:related_to:Reminds_相关对象:V');

INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
SELECT 'Reminds', '3', '1', 'ld_reminds:smcreatorid:creator:Reminds_发送人:V', '0', NULL, '0', 'no', 'yes', 'yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_cvcolumnlist_wx WHERE modulename = 'Reminds' AND columnname = 'ld_reminds:smcreatorid:creator:Reminds_发送人:V');

INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
SELECT 'Reminds', '4', '1', 'ld_reminds:date_time:date_time:Reminds_提醒时间:DT', '0', NULL, '0', 'no', 'yes', 'yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_cvcolumnlist_wx WHERE modulename = 'Reminds' AND columnname = 'ld_reminds:date_time:date_time:Reminds_提醒时间:DT');

INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
SELECT 'Reminds', '5', '1', 'ld_reminds:content:content:Reminds_提醒内容:V', '0', NULL, '0', 'no', 'yes', 'yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_cvcolumnlist_wx WHERE modulename = 'Reminds' AND columnname = 'ld_reminds:content:content:Reminds_提醒内容:V');
delimiter;

UPDATE ld_desk set fieldlabel='我发送的' WHERE labelbol='LBL_SENDED' and languagetype='zh';
UPDATE ld_desk set fieldlabel='I sent' WHERE labelbol='LBL_SENDED' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetAllAsRead','全部标为已读','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetAllAsRead' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetAllAsRead','Set all as read','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetAllAsRead' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk set fieldlabel='全部标为已读' WHERE labelbol='SetAllAsRead' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Set all as read' WHERE labelbol='SetAllAsRead' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RemindsCenter','消息中心','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RemindsCenter' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RemindsCenter','Reminds Center','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RemindsCenter' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetSuccessfully','设置成功','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetSuccessfully' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetSuccessfully','Set successfully','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetSuccessfully' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_listview_btn SET btntype = 'rely',iconname = 'Allocate.png' WHERE `name` = 'CF54massget';
delimiter;


UPDATE ld_tab SET isduplicate='yes' WHERE presence<>0;

update ld_desk set fieldlabel='"CRM外网访问地址"不能为空' where labelbol='ZHIYUANREMINDCONTENTTEXT' and labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='"CRM external network access address" can not be empty！' where labelbol='ZHIYUANREMINDCONTENTTEXT' and labeltype='jspop' and languagetype='zh';
delimiter;

set @tabid = (select tabid from ld_tab where name = 'Commission');
delete from ld_field where tablename='ld_commission' and columnname = 'print_times' and tabid <> @tabid;
delimiter;




DROP PROCEDURE IF EXISTS `ldcrm_add_email_new`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_email_new`(
	tmp_subject text,
	tmp_content text,
	tmp_toemail text,
	tmp_ccemail text,
	tmp_filepath text,
	tmp_sendtime datetime,
	tmp_sender int(19)
)
BEGIN
	

		-- 参数名称：tmp_toemail，接收人，多个用逗号分隔。例如：luyx@51mis.com,boss_28007@163.com
		-- 参数名称：tmp_ccemail，抄送人，多个用逗号分隔，没有可传空值。例如：luyx@51mis.com,boss_28007@163.com
		
		-- 参数名称：tmp_filepath，附件路径，需包含附件名称、必须在CRM安装目录下、只写CRM目录下的相对路径，没有可传空值。
		-- 例如： CRM安装路径 /home/www/crm/
		-- 附件： /home/www/crm/storage/2024/May/6/Centos7配置firewalld_6381_1.txt
		-- 取值： storage/2024/May/6/Centos7配置firewalld_6381_1.txt

		
		-- 邮件自动发送：可自行添加计划任务定时访问 modules/Reminds/sendRemindsEmail.php
		
		IF LENGTH(tmp_toemail)>5 THEN 
			IF IFNULL(tmp_filepath,'')<>'' THEN
				SET @email_fileid=IFNULL((SELECT MAX(crmid) FROM ld_crmentity),0)+1;
				INSERT INTO ld_crmentity(crmid,setype) SELECT @email_fileid,'Emails Attachment';
				UPDATE ld_crmentity_seq SET id=(SELECT max(crmid) FROM ld_crmentity); 

			
				-- 1、根据附件路径分隔附件名称和路径
				SET @reverse_path=REVERSE(tmp_filepath);
				SET @email_filename=REVERSE(LEFT(@reverse_path,LOCATE('/',@reverse_path)-1));
				SET @email_filepath=REVERSE(RIGHT(@reverse_path,CHAR_LENGTH(@reverse_path)-LOCATE('/',@reverse_path)+1));

				-- 2、根据附件名称中的后缀获取附件类型
				IF RIGHT(@email_filename,4)='.txt' THEN
					SET @email_filetype='text/plain';
				ELSEIF RIGHT(@email_filename,4)='.pdf' THEN
					SET @email_filetype='application/pdf';

				ELSEIF RIGHT(@email_filename,4)='.zip' THEN
					SET @email_filetype='application/x-zip-compressed';
				ELSEIF RIGHT(@email_filename,4) IN ('.rar','.sql') THEN
					SET @email_filetype='application/octet-stream';

				ELSEIF RIGHT(@email_filename,4)='.doc' THEN
					SET @email_filetype='application/msword';
				ELSEIF RIGHT(@email_filename,5)='.docx' THEN
					SET @email_filetype='application/vnd.openxmlformats-officedocument.wordprocessingml.document';

				ELSEIF RIGHT(@email_filename,4)='.ppt' THEN
					SET @email_filetype='application/vnd.ms-powerpoint';
				ELSEIF RIGHT(@email_filename,5)='.pptx' THEN
					SET @email_filetype='application/vnd.openxmlformats-officedocument.presentationml.presentation';

				ELSEIF RIGHT(@email_filename,4)='.xls' THEN
					SET @email_filetype='application/vnd.ms-excel';
				ELSEIF RIGHT(@email_filename,5)='.xlsx' THEN
					SET @email_filetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

				ELSEIF RIGHT(@email_filename,4)='.png' THEN
					SET @email_filetype='image/png';
				ELSEIF RIGHT(@email_filename,4)='.bmp' THEN
					SET @email_filetype='image/bmp';
				ELSEIF RIGHT(@email_filename,4)='.gif' THEN
					SET @email_filetype='image/gif';
				ELSEIF RIGHT(@email_filename,4)='.jpg' THEN
					SET @email_filetype='image/jpeg';
				ELSEIF RIGHT(@email_filename,5)='.jpeg' THEN
					SET @email_filetype='image/jpeg';

				ELSE
					SET @email_filetype=NULL;
				END IF;

				-- 3、写入附件
				INSERT INTO ld_attachments(
					attachmentsid,
					name,
					description,
					type,
					path,
					imagefromtype
				)
				SELECT
					@email_fileid,
					@email_filename,
					'邮件附件',
					@email_filetype,
					@email_filepath,
					'Computer';
			END IF;

			-- 4、获取写入邮件ID
			SET @email_emailid=IFNULL((SELECT MAX(crmid) FROM ld_crmentity),0)+1;
			INSERT INTO ld_crmentity(crmid,setype) SELECT @email_emailid,'Emails';
			UPDATE ld_crmentity_seq SET id=(SELECT max(crmid) FROM ld_crmentity); 

			-- 5.写入邮件和附件关联表
			INSERT INTO ld_seattachmentsrel(crmid,attachmentsid) SELECT @email_emailid,@email_fileid;

			-- 6、写入邮件
			INSERT INTO ld_activity(activityid,`subject`,description,to_email,cc_email,date_start,smownerid,smcreatorid,activitytype,visibility,deleted)
			SELECT @email_emailid,tmp_subject,tmp_content,tmp_toemail,tmp_ccemail,tmp_sendtime,tmp_sender,tmp_sender,'Emails','公共',0;
			
			INSERT INTO ld_activitycf(activityid) SELECT @email_emailid;

			INSERT INTO ld_activity_reminder(activity_id,email_remind)
			SELECT @email_emailid,tmp_sendtime;
			
		END IF;

end ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','bondType','股票类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='bondType' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','bondType','Stock type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='bondType' and Labeltype='fixedstr' and languagetype='en');
delimiter;
SET @sequence = (select max(sequence) from ld_business_mappingfields);
SET @mappingfieldname='bondType';
SET @mappingfieldlabel='bondType';
insert into ld_business_mappingfields (`mappingfieldlabel`,`mappingfieldname`,`sequence`)
select @mappingfieldlabel,@mappingfieldname,@sequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_business_mappingfields WHERE mappingfieldlabel=@mappingfieldlabel and mappingfieldname=@mappingfieldname);
delimiter;
SET @tianyanchaname = 'bondType';
SET @tianyanchalabel = 'bondType';
SET @sequence = (select max(sequence) from ld_business_backfillfield);
insert into ld_business_backfillfield (`tabid`,`tianyanchalabel`,`tianyanchaname`,`sequence`)
select ld_business_settings.tabid,@tianyanchalabel,@tianyanchaname,@sequence+1 from ld_business_settings
where NOT EXISTS (SELECT 1 from ld_business_backfillfield WHERE tianyanchalabel=@tianyanchalabel and tianyanchaname=@tianyanchaname and tabid=ld_business_settings.tabid );
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','bondNum','股票代码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='bondNum' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','bondNum','Stock code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='bondNum' and Labeltype='fixedstr' and languagetype='en');
delimiter;
SET @sequence = (select max(sequence) from ld_business_mappingfields);
SET @mappingfieldname='bondNum';
SET @mappingfieldlabel='bondNum';
insert into ld_business_mappingfields (`mappingfieldlabel`,`mappingfieldname`,`sequence`)
select @mappingfieldlabel,@mappingfieldname,@sequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_business_mappingfields WHERE mappingfieldlabel=@mappingfieldlabel and mappingfieldname=@mappingfieldname);
delimiter;
SET @tianyanchaname = 'bondNum';
SET @tianyanchalabel = 'bondNum';
SET @sequence = (select max(sequence) from ld_business_backfillfield);
insert into ld_business_backfillfield (`tabid`,`tianyanchalabel`,`tianyanchaname`,`sequence`)
select ld_business_settings.tabid,@tianyanchalabel,@tianyanchaname,@sequence+1 from ld_business_settings
where NOT EXISTS (SELECT 1 from ld_business_backfillfield WHERE tianyanchalabel=@tianyanchalabel and tianyanchaname=@tianyanchaname and tabid=ld_business_settings.tabid );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','bondName','股票名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='bondName' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','bondName','Stock Name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='bondName' and Labeltype='fixedstr' and languagetype='en');
delimiter;
SET @sequence = (select max(sequence) from ld_business_mappingfields);
SET @mappingfieldname='bondName';
SET @mappingfieldlabel='bondName';
insert into ld_business_mappingfields (`mappingfieldlabel`,`mappingfieldname`,`sequence`)
select @mappingfieldlabel,@mappingfieldname,@sequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_business_mappingfields WHERE mappingfieldlabel=@mappingfieldlabel and mappingfieldname=@mappingfieldname);
delimiter;
SET @tianyanchaname = 'bondName';
SET @tianyanchalabel = 'bondName';
SET @sequence = (select max(sequence) from ld_business_backfillfield);
insert into ld_business_backfillfield (`tabid`,`tianyanchalabel`,`tianyanchaname`,`sequence`)
select ld_business_settings.tabid,@tianyanchalabel,@tianyanchaname,@sequence+1 from ld_business_settings
where NOT EXISTS (SELECT 1 from ld_business_backfillfield WHERE tianyanchalabel=@tianyanchalabel and tianyanchaname=@tianyanchaname and tabid=ld_business_settings.tabid );
delimiter;


INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','APPROVALNOTEMPTY','审批流程不能为空','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'APPROVALNOTEMPTY' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','APPROVALNOTEMPTY','Approval process can not be empty','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'APPROVALNOTEMPTY' AND labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateH5PosterAndPublish','制作一个H5海报并发布','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateH5PosterAndPublish' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateH5PosterAndPublish','Create an H5 poster and publish it','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateH5PosterAndPublish' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ObtainTheH5linkAfterPublication','获取发布后的H5链接','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ObtainTheH5linkAfterPublication' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ObtainTheH5linkAfterPublication','Obtain the H5 link after publication','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ObtainTheH5linkAfterPublication' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'SocialPromotion');
UPDATE ld_field SET presence = 0 WHERE tabid = @tabid and columnname = 'h5pageurl';
UPDATE ld_field SET presence = 0 WHERE tabid = @tabid and columnname = 'h5pagebutton';
UPDATE ld_field SET presence = 0 WHERE tabid = @tabid and columnname = 'H5buttoncolor';
UPDATE ld_field SET allowedit = 'yes' WHERE tabid = @tabid and columnname = 'social_activitytype';
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

UPDATE ld_version SET old_version='V8.6.3.4',current_version='V8.6.3.4',remark='V8.6.3.4-20240511',wx_version='V8.6.3.3';
delimiter;