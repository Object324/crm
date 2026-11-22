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

DROP PROCEDURE IF EXISTS `ldcrm_reset_shoukuanrenlingdan_20240514`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_shoukuanrenlingdan_20240514`(
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ld_collectionslip) OR EXISTS (SELECT 1 FROM ld_validatasavedetail WHERE relateid IS NULL AND relatefieldname='hdnGrandTotal') THEN
		DELETE FROM ld_validatasavedetail WHERE relateid IN (SELECT id FROM ld_validatasave WHERE module='CollectionSlip');
		DELETE FROM ld_validatasave WHERE module='CollectionSlip';
		DELETE FROM ld_validatasavemain WHERE module='CollectionSlip';

		INSERT INTO `ld_validatasavemain` (
			`rulename`, 
			`module`, 
			`actionprevent`, 
			`tipzhtype`, 
			`tipzh`,

			`tipen`, 
			`conditiongroup`, 
			`validataapplication`, 
			`relatedtable`, 
			`sequence`
		) 
		SELECT
			'合计金额必须等于收款金额或者为零', 
			'CollectionSlip', 
			'yes', 
			'text', 
			'分录的金额合计必须等于认领单的收款金额！', 

			'The total amount of the entry shall be equal to the amount of the receipt.',
			'[null,{"groupcondition":""}]', 
			'create,edit', 
			'ld_field', 
			'1';

		SET @main_id=(SELECT id FROM ld_validatasavemain WHERE module='CollectionSlip' AND rulename='合计金额必须等于收款金额或者为零' LIMIT 1);
		INSERT INTO `ld_validatasave` (
			`module`, 
			`relatedtable`, 
			`fieldname`, 
			`comparator`,
			`status`, 
			`allowsave`, 
			`funtype`,
			`validatasavemainid`,
			`valid_condition`
		)
		SELECT
			'CollectionSlip', 
			'ld_field', 
			'collected_amount',
			'e',
			'active',
			'no',
			'fields',
			@main_id,
			'or';

		SET @valid_id=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@main_id AND module='CollectionSlip' AND fieldname='collected_amount' LIMIT 1);
		INSERT INTO `ld_validatasavedetail` (
			`relateid`,
			`relatefieldname`, 
			`relatedtable`, 
			`funtype`
		) 
		SELECT
			@valid_id,
			'hdnGrandTotal',
			'ld_field', 
			'fields';

		INSERT INTO `ld_validatasave` (
			`module`, 
			`relatedtable`, 
			`fieldname`, 
			`comparator`,
			`status`, 
			`allowsave`, 
			`funtype`,
			`validatasavemainid`,
			`valid_condition`
		)
		SELECT
			'CollectionSlip', 
			'ld_field', 
			'collected_amount',
			'e',
			'active',
			'no',
			'fields',
			@main_id,
			'';


		SET @valid_id=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@main_id AND module='CollectionSlip' AND fieldname='amount' LIMIT 1);
		INSERT INTO `ld_validatasavedetail` (
			`relateid`,
			`relatefieldname`, 
			`relatedtable`, 
			`funtype`
		) 
		SELECT
			@valid_id,
			'0',
			'ld_field', 
			'number';


		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='CollectionSlip');
		DELETE FROM ld_workflow_excutesql WHERE id IN (
			SELECT
				b.id
			FROM ld_workflow a
			LEFT JOIN ld_workflow_actions b ON b.workflow_id=a.id
			WHERE a.tabid=@tabid
		);
		DELETE FROM ld_workflow_actions WHERE workflow_id IN (SELECT id FROM ld_workflow WHERE tabid=@tabid);
		DELETE FROM ld_workflow WHERE tabid=@tabid;

		SET @maxid=IFNULL((SELECT MAX(id) FROM ld_workflow),0)+1;
		INSERT INTO `ld_workflow` (
			`id`, 
			`tabid`, 
			`name`, 
			`status`, 
			`description`, 

			`triggertime`, 
			`repeatmode`, 
			`approvalnode`, 
			`deleted`, 
			`createdtime`, 
			`advft_criteria`, 
			`advft_criteria_groups`
		) 
		SELECT
			@maxid, 
			@tabid,
			'客户名称为空时则根据汇款户名查询并关联相应的客户和负责人', 
			'Active', 
			'仅在新建的时候进行一次判断', 

			'Creation', 
			'every', 
			NULL, 
			'0', 
			NOW(), 
			'[{\"groupid\":\"1\",\"columnname\":\"\",\"comparator\":\"无\",\"value\":\"\",\"columncondition\":\"\"}]', 
			'[null,{\"groupcondition\":\"\"}]';


		UPDATE ld_workflow_seq SET id=(SELECT MAX(id) FROM ld_workflow);
		
		INSERT INTO `ld_workflow_actions` (
			`workflow_id`, 
			`action_title`, 
			`action_type`, 
			`api_url`, 
			`api_jsondata`, 
			`status`, 
			`createdtime`, 
			`deleted`, 
			`body_query_type`, 
			`sequence`, 
			`api_receive_msg`
		) 
		SELECT
			@maxid, 
			'如果有该客户，则自动选择相应客户和负责人', 
			'ExcuteSql', 
			NULL, 
			NULL, 
			'Active', 
			NOW(), 
			'0', 
			'form-data', 
			'1', 
			'no';

		SET @action_id=(SELECT id FROM ld_workflow_actions WHERE workflow_id=@maxid LIMIT 1);

		INSERT INTO ld_workflow_excutesql(
			workflow_action_id,
			query_sql
		)
		SELECT 
			@action_id,
			"UPDATE ld_collectionslip a
INNER JOIN ld_account b ON b.accountname=a.remit_account_name
SET 
a.accountid=b.accountid,
a.smownerid=b.smownerid
WHERE a.collectionslip_id='{Record.ID}'
AND b.deleted=0
AND IFNULL(a.accountid,0)  = 0;";


		SET @maxid=IFNULL((SELECT MAX(id) FROM ld_workflow),0)+1;
		INSERT INTO `ld_workflow` (
			`id`, 
			`tabid`, 
			`name`, 
			`status`, 
			`description`, 

			`triggertime`, 
			`repeatmode`, 
			`approvalnode`, 
			`deleted`, 
			`createdtime`, 
			`advft_criteria`, 
			`advft_criteria_groups`
		) 
		SELECT
			@maxid, 
			@tabid,
			'收款认领单通过审批通过后自动创建收款单', 
			'Active', 
			'', 

			'Approval', 
			'every', 
			'Approved', 
			'0', 
			NOW(), 
			'[{\"groupid\":\"1\",\"columnname\":\"\",\"comparator\":\"无\",\"value\":\"\",\"columncondition\":\"\"}]', 
			'[null,{\"groupcondition\":\"\"}]';


		UPDATE ld_workflow_seq SET id=(SELECT MAX(id) FROM ld_workflow);
		
		INSERT INTO `ld_workflow_actions` (
			`workflow_id`, 
			`action_title`, 
			`action_type`, 
			`api_url`, 
			`api_jsondata`, 
			`status`, 
			`createdtime`, 
			`deleted`, 
			`body_query_type`, 
			`sequence`, 
			`api_receive_msg`
		) 
		SELECT
			@maxid, 
			'收款认领单自动创建对应的收款单', 
			'ExcuteSql', 
			NULL, 
			NULL, 
			'Active', 
			NOW(), 
			'0', 
			'form-data', 
			'1', 
			'no';

		SET @action_id=(SELECT id FROM ld_workflow_actions WHERE workflow_id=@maxid LIMIT 1);

		INSERT INTO ld_workflow_excutesql(
			workflow_action_id,
			query_sql
		)
		SELECT 
			@action_id,
			"CALL autocreatecashbillbycollectionsslip_where('{Record.ID}');";

	END IF;
end ||
delimiter;

CALL ldcrm_reset_shoukuanrenlingdan_20240514();
DROP PROCEDURE IF EXISTS `ldcrm_reset_shoukuanrenlingdan_20240514`;
delimiter;

DELETE FROM ld_validatasavedetail WHERE relateid IS NULL;
delimiter;

UPDATE ld_field SET allowedit='yes',typeofdata='N~O~25,2' WHERE tablename='ld_salary' AND columnname IN ('phone_allowance','traffic_allowance');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='CollectionSlip' LIMIT 1);
SET @detailfieldid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='total' LIMIT 1);
INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
SELECT @detailfieldid,'sum(a)',"{formulavar:[{'lettervar':'a','column':'amount'}]}",1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@detailfieldid);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Salary');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_SALARYOTHERPAYABLE_INFO' LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) 
SELECT 'zh','ld_blocks',@tabid,@blockid,'其他应发' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND Relateid=@blockid AND languagetype='zh');

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Salary');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_SALARYOTHERPAYABLE_INFO' LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) 
SELECT 'en','ld_blocks',@tabid,@blockid,'Other Payables' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND Relateid=@blockid AND languagetype='en');
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
delimiter;

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

set @module='Users';
set @tablename='ld_users';
select tabid into @tabid from ld_tab where name=@module;
set @columnname="setmenuprofileid";
set @fieldname="setmenuprofileid";
set @allowhide="no";
set @uitype=56;
set @zh_fieldlabel='后台设置权限';
set @en_fieldlabel='System Setting';
set @readonly=1;
set @presence=2;
 
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=0;
set @masseditable=0;
set @fieldonly=0;
set @allowedit='yes';
set @savedatabase="yes";
set @bigtype="boolean";
set @profileeditfield="no";
set @allowdelete="no";
select  sequence into @sequence from ld_field where tabid=@tabid and columnname='last_name';
 

select  block into @block from ld_field where tabid=@tabid and columnname='last_name';
select fieldid into @tmpfieldid from ld_field where tabid=@tabid and columnname=@columnname;

update ld_field set sequence=sequence+2 where tabid=@tabid and sequence>@sequence and block=@block and  ifnull(@tmpfieldid,0)>0;
set @seqeunce=@seqeunce+1;
CALL AddColumn(@tablename,@columnname,'int','10',0);
select max(fieldid) into @fieldid from ld_field;
insert into ld_field (tabid, fieldid,columnname,fieldname,tablename,allowhide,uitype,fieldlabel,readonly,presence,block,sequence,displaytype,typeofdata,quickcreate,masseditable,fieldonly,allowedit,savedatabase
									,bigtype,profileeditfield,allowdelete)
select @tabid,@fieldid+1,@columnname,@fieldname,@tablename,@allowhide,@uitype,@zh_fieldlabel,@readonly,@presence,@block,@sequence,@displaytype,@typeofdata,@quickcreate,@masseditable,@fieldonly,@allowedit,@savedatabase
				,@bigtype,@profileeditfield,@allowdelete from dual where not exists(select 1 from ld_field where tabid=@tabid and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid, fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh_fieldlabel from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=@tabid and trantable='ld_field' and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid, fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en_fieldlabel from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=@tabid and trantable='ld_field' and relateid=@fieldid);

delimiter;
 
insert into  ld_desk (fieldlabel,languagetype,labelbol,labeltype)
select '开启后，自动拥有后台管理设置的相关权限','zh','setmenuprofileid','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='setmenuprofileid' and labeltype='fixedstr');


insert into  ld_desk (fieldlabel,languagetype,labelbol,labeltype)
select 'Enabled, automatically have relevant permissions for backend management settings','en','setmenuprofileid','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='setmenuprofileid' and labeltype='fixedstr');
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

UPDATE ld_systems_deploy SET presence = 1 WHERE deploy_type = 204;
delimiter;
-- 2024-05-14

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

UPDATE ld_version SET old_version='V8.6.3.3.1',current_version='V8.6.3.3.1',remark='V8.6.3.3.1-20240514',wx_version='V8.6.3.2';
delimiter;