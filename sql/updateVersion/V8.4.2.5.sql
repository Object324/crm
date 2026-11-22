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
			IF tmp_defaultvalue='' THEN
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
			IF tmp_columnlen<=1 THEN 
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


select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
update ld_field set presence = 1 where tabid = @tabid and columnname = 'location_address';
delimiter;

call AddColumn('ld_publicannouncement','publicannoucement_no','varchar','100','');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='publicannouncement');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='publicannoucement_no';
SET @fieldname='publicannoucement_no';
SET @zh='公告编号';
SET @en='publicannouncementno';
SET @uitype=4;
SET @typeofdata='V~M~LE~20';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='text';
SET @datarang='all';
SET @maxrowsshow=5;

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
delimiter;

set @tabid = (SELECT tabid from ld_tab where name ='Questionnaire');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, -14, 'get_QuestionnaireReport', 2, 'QuestionnaireReport', 0, 'select', 0, 36, NULL, NULL, 0, 0, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=-14);
UPDATE ld_relatedlists_seq set id =(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_tabdetailfield set width = 50 where tabid = @tabid and columnname = 'entitytypeid';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StartRecycling','开始回收','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='StartRecycling' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','StartRecycling','Start recycling','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='StartRecycling' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SuspendRecycling','暂停回收','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SuspendRecycling' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SuspendRecycling','Suspend recycling','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SuspendRecycling' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','StartRecyclingReminder','要开始回收该问卷吗？','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='StartRecyclingReminder' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','StartRecyclingReminder','Do you want to start recycling？','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='StartRecyclingReminder' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SuspendRecyclingReminder','暂停回收期间，问卷链接关闭，问卷不回收数据。确定要暂停回收该问卷吗？','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SuspendRecyclingReminder' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SuspendRecyclingReminder','b.During the period of suspension of recycling, the questionnaire link is closed and the questionnaire does not recycle data. Confirm to suspend the recycle questionnaire ?','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SuspendRecyclingReminder' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OpenQuestionnaire','打开问卷','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OpenQuestionnaire' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OpenQuestionnaire','Open the questionnaire','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OpenQuestionnaire' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetEndTime','设置问卷结束时间','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetEndTime' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetEndTime','Set the end time of the questionnaire','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetEndTime' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CannotLessCurrentTime','不能小于当前时间','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CannotLessCurrentTime' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CannotLessCurrentTime','Cannot be less than the current time','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CannotLessCurrentTime' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TopicSetting','题目设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TopicSetting' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TopicSetting','Topic setting','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TopicSetting' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddTopic','添加题目','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddTopic' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddTopic','Add topic','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddTopic' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TopicName','题目名称','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TopicName' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TopicName','Topic name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TopicName' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Topictype','题目类型','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Topictype' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Topictype','Topic type','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Topictype' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Required','必填','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Required' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Required','Required','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Required' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Questionnaire','问卷调查','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Questionnaire' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Questionnaire','Questionnaire','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Questionnaire' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','QuestionnaireName','问卷名称','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='QuestionnaireName' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','QuestionnaireName','Questionnaire name','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='QuestionnaireName' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QuestionnaireDescribingPlaceholder','为了给您提供更好的服务，希望您能抽出几分钟时间，将您的感受和建议告诉我们，我们非常重视每位用户的宝贵意见，期待您的参与！现在我们就马上开始吧！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='QuestionnaireDescribingPlaceholder' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QuestionnaireDescribingPlaceholder','In order to provide you with better service, I hope you can take a few minutes to tell us your feelings and suggestions. We attach great importance to the valuable opinions of each user and look forward to your participation! Lets start right now!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='QuestionnaireDescribingPlaceholder' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AddTopicReminder','您还没有添加题目','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AddTopicReminder' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AddTopicReminder','You have not added a topic','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AddTopicReminder' and Labeltype='jspop');
delimiter;
-- 2021-05-07

update ld_producttoolfield set savedatabase = 'yes' where columnname = 'tax_total';
delimiter;

SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
SELECT @maxnum_id+1,'PublicAnnouncement','ANC',1,1,1,'none',0,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule='PublicAnnouncement');
UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;
delimiter;

UPDATE ld_field SET allowhide='yes' WHERE columnname='team_memberid' AND uitype=154;

alter table ld_validatasave alter column `status` set default 'active';
delimiter;

update ld_validatasave set `status`='active' where `status` is null or `status`='';
delimiter;


select sequence into @sequence from ld_homestuffdetail where stufflabel="NewSalesOrderAmount" and stuffid=35;
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'SalesorderBalanceReceivable','fixedstr','ld_salesorder.receivable_balance','sum','index.php?pageto_module=SalesOrder&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='SalesorderBalanceReceivable');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SalesorderBalanceReceivable';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:createdtime:createdtime:SalesOrder_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:createdtime:createdtime:SalesOrder%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:approvestatus:approvestatus:SalesOrder_审批状态:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:approvestatus:approvestatus:SalesOrder%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SalesorderBalanceReceivable','{$SalesOrder.SalesOrder}应收余额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SalesorderBalanceReceivable' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SalesorderBalanceReceivable','{$Commission.Commission}  balance receivable','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SalesorderBalanceReceivable' and Labeltype='fixedstr');
delimiter;

update ld_homestuffdetail set cssname="item-ico-salesorder",icon="crm_SalesOrder.png" where stufflabel="SalesorderBalanceReceivable";

select sequence into @sequence from ld_homestuffdetail where stufflabel="NewServiceContractsAmount" and stuffid=35;
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'ServiceContractBalanceReceivable','fixedstr','ld_servicecontracts.receivable_balance','sum','index.php?pageto_module=ServiceContracts&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='ServiceContractBalanceReceivable');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='ServiceContractBalanceReceivable';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_审批状态:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:approvestatus:approvestatus:ServiceContracts%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ServiceContractBalanceReceivable','{$ServiceContracts.ServiceContracts}应收余额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ServiceContractBalanceReceivable' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ServiceContractBalanceReceivable','{$ServiceContracts.ServiceContracts}  balance receivable','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ServiceContractBalanceReceivable' and Labeltype='fixedstr');
delimiter;

update ld_homestuffdetail set cssname="item-ico-servicecontracts",icon="crm_ServiceContracts.png" where stufflabel="ServiceContractBalanceReceivable";

select sequence into @sequence from ld_homestuffdetail where stufflabel="SignContractCount" and stuffid=35 and compute_columns="ld_servicecontracts.servicecontractsid";
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'SignContractBalanceReceivable','fixedstr','ld_salesorder.total','sum','index.php?pageto_module=SalesOrder&pageto_action=index',9 from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractBalanceReceivable' and pageurl like '%SalesOrder%');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractBalanceReceivable' and pageurl like '%SalesOrder%';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:createdtime:createdtime:SalesOrder_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and columns like '%ld_salesorder:createdtime:createdtime:SalesOrder%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:approvestatus:approvestatus:SalesOrder_审批状态:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'SignContractBalanceReceivable','fixedstr','ld_servicecontracts.total','sum','index.php?pageto_module=ServiceContracts&pageto_action=index',9 from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractBalanceReceivable' and pageurl like '%ServiceContracts%');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractBalanceReceivable' and pageurl like '%ServiceContracts%';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid  and COLUMNS like '%ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:approvestatus:approvestatus%') ;
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SignContractBalanceReceivable','签约应收余额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SignContractBalanceReceivable' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SignContractBalanceReceivable','Contract balance receivable','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SignContractBalanceReceivable' and Labeltype='fixedstr');
delimiter;
update ld_homestuffdetail set cssname="item-ico-salesorder",icon="crm_SalesOrder.png" where stufflabel="SignContractBalanceReceivable";


select sequence into @sequence from ld_homestuffdetail where stufflabel="NewPurchaseOrderAmount" and stuffid=35;
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'PurchaseOrderPayBalance','fixedstr','ld_purchaseorder.pay_balance','sum','index.php?pageto_module=PurchaseOrder&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='PurchaseOrderPayBalance');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='PurchaseOrderPayBalance';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_purchaseorder:createdtime:createdtime:PurchaseOrder_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_purchaseorder:createdtime:createdtime:PurchaseOrder%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_purchaseorder:approvestatus:approvestatus:PurchaseOrder_审批状态:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_purchaseorder:approvestatus:approvestatus:PurchaseOrder%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PurchaseOrderPayBalance','{$PurchaseOrder.PurchaseOrder}应付余额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PurchaseOrderPayBalance' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PurchaseOrderPayBalance','{$ServiceContracts.ServiceContracts}  payable balance','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PurchaseOrderPayBalance' and Labeltype='fixedstr');
delimiter;

update ld_homestuffdetail set cssname="item-ico-purchaseorder",icon="crm_PurchaseOrder.png" where stufflabel="PurchaseOrderPayBalance";
delimiter;

select sequence into @sequence from ld_homestuffdetail where stufflabel="NewSalesOrderAmount" and stuffid=35;
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
update ld_homestuffdetail set sequence=@sequence where stufflabel="SalesorderBalanceReceivable";

select sequence into @sequence from ld_homestuffdetail where stufflabel="NewServiceContractsAmount" and stuffid=35;
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
update ld_homestuffdetail set sequence=@sequence where stufflabel="ServiceContractBalanceReceivable";

select sequence into @sequence from ld_homestuffdetail where stufflabel="SignContractCount" and stuffid=35 and compute_columns="ld_servicecontracts.servicecontractsid";
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
update ld_homestuffdetail set sequence=@sequence where stufflabel="SignContractBalanceReceivable";

select sequence into @sequence from ld_homestuffdetail where stufflabel="NewPurchaseOrderAmount" and stuffid=35;
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
update ld_homestuffdetail set sequence=@sequence where stufflabel="PurchaseOrderPayBalance";
delimiter;

update ld_desk set fieldlabel = '全部（含公海）' where languagetype = 'zh' and labelbol = 'thedefaultallincludeunassigned' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '允许公海未分配客户显示在“全部（含公海）”列表' where languagetype = 'zh' and labelbol = 'Allowtheunallocatedcustomerstobedisplayedinalllist' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '允许公海已分配客户显示在“全部（含公海）”列表' where languagetype = 'zh' and labelbol = 'Allowtheallocatedcustomerstobedisplayedinalllist' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllowmembersAssignUnassigned','允许“公海分配”的成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowmembersAssignUnassigned' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllowmembersAssignUnassigned','Allow members "Assign Unassigned"','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowmembersAssignUnassigned' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllowmembersTransfer','允许“转换公海”的成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowmembersTransfer' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllowmembersTransfer','Allow members "Transfer"','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowmembersTransfer' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_account_public_pool','allow_users','varchar','200','');
delimiter;

call AddColumn('ld_account_public_pool','transfer_users','varchar','200','');
delimiter;

select  concat(left(inputvalue, length(inputvalue)-1),',{"value":120,"text":"custom"}]')
into @inputvalue  from ld_systems_deploy where deploy_type=323;

update ld_systems_deploy set inputvalue=@inputvalue where deploy_type=323 and inputvalue not like '%"custom"%';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Limittimethan1','限制时长必须输入大于等于1的整数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Limittimethan1' 
and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Limittimethan1','The  limit time must be an integer greater than or equal to 1','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Limittimethan1' 
and labeltype='fixedstr');
delimiter;
-- 2021-05-10

SET @i=0;
SET @tabseq=IFNULL((SELECT tabsequence FROM ld_tab WHERE `name`='SocialPromotion'),1000);
UPDATE ld_tab SET tabsequence=tabsequence+1 WHERE tabsequence>@tabseq;
UPDATE ld_tab SET tabsequence=@tabseq+1 WHERE `name`='Questionnaire';
UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence;
delimiter;

SET @i=0;
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Marketing');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SocialPromotion');
SET @tabid1=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @seq=IFNULL((SELECT sequence FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid),100);
UPDATE ld_parenttabrel SET sequence=sequence+1 WHERE sequence>@seq AND parenttabid=@parenttabid;
UPDATE ld_parenttabrel SET sequence=@seq+1 WHERE parenttabid=@parenttabid AND tabid=@tabid1;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;
delimiter;

DROP EVENT IF EXISTS `task_questionnaire_resetstatus_everysecond`;
delimiter ||
CREATE  EVENT `task_questionnaire_resetstatus_everysecond` ON SCHEDULE EVERY 5 SECOND STARTS '2021-05-11 15:00:00' ON COMPLETION NOT PRESERVE ENABLE 
DO 
UPDATE ld_questionnaire SET `status`='暂停' WHERE recovery_endtime<NOW();
||
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

UPDATE ld_version SET old_version='V8.4.2.5',current_version='V8.4.2.5',remark='V8.4.2.5-20210510',wx_version='V8.4.2.5';
delimiter;