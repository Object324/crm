update ld_tab set description='OAFORMS' where `name` in ('Commission','Expense');

set @i=0;
select tabsequence into @seq from ld_tab where `name`='CardApply';
update ld_tab set tabsequence=tabsequence+10 where tabsequence>@seq;
update ld_tab set tabsequence=@seq+1 where `name`='Commission';
update ld_tab set tabsequence=@seq+2 where `name`='Expense';
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
update ld_tranlabel set fieldlabel='Common Approvals' where Relateid=@tabid and trantable='ld_tab' and languagetype='en';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ReportLog';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'ReportLog','lookReportLog','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=','看报告' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'ReportLog' and linklabel = 'lookReportLog');
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'ReportLog','writeReportLog','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=','写报告' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'ReportLog' and linklabel = 'writeReportLog');
delimiter;

select sequence into @sequence from ld_systems_deploy where roottype = 1 and deploy_type = 119;
update ld_systems_deploy set sequence = sequence+1000 where roottype = 1 and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 1,137,'序时簿列表页面是否显示本次查询统计图表','',@sequence+1,1,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 137);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',137,137,'序时簿列表页面是否显示本次查询统计图表' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and tabid = 137 and relateid = 137 and trantable = 'ld_systems_deploy');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',137,137,'Whether to show the query statistics charts' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and tabid = 137 and relateid = 137 and trantable = 'ld_systems_deploy');
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = 1 order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_org_share_action2tab(share_action_id,tabid)
select  0 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  1 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=3);
delimiter;


select tabid into @tabid from ld_tab where name='minusjobbill';
insert into ld_org_share_action2tab(share_action_id,tabid)
select  0 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  1 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=3);
delimiter;


select tabid into @tabid from ld_tab where name='loanapply';
insert into ld_org_share_action2tab(share_action_id,tabid)
select  0 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  1 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=3);
delimiter;

select tabid into @tabid from ld_tab where name='businessapply';
insert into ld_org_share_action2tab(share_action_id,tabid)
select  0 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  1 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=3);
delimiter;

select tabid into @tabid from ld_tab where name='minusjobbill';
insert into ld_org_share_action2tab(share_action_id,tabid)
select  0 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  1 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=3);
delimiter;

select tabid into @tabid from ld_tab where name='NormalApprove';
insert into ld_org_share_action2tab(share_action_id,tabid)
select  0 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  1 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=3);
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
insert into ld_org_share_action2tab(share_action_id,tabid)
select  0 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  1 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=3);
delimiter;
-- 2017-06-19

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thattheprovincehascustomers','表示该省份有客户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thattheprovincehascustomers' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thattheprovincehascustomers','That the province has customers','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thattheprovincehascustomers' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','indicatesthattheprovincehasnocustomers','表示该省份没有客户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'indicatesthattheprovincehasnocustomers' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','indicatesthattheprovincehasnocustomers','Indicates that the province has no customers','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'indicatesthattheprovincehasnocustomers' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thatthecityhascustomers','表示该城市有客户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thatthecityhascustomers' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thatthecityhascustomers','That the city has customers','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thatthecityhascustomers' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','indicatesthatthecityhasnocustomers','表示该城市没有客户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'indicatesthatthecityhasnocustomers' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','indicatesthatthecityhasnocustomers','Indicates that the city has no customers','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'indicatesthatthecityhasnocustomers' and labeltype = 'fixedstr');
delimiter;

update ld_producttoolfield set typeofdata='N~O~' where uitype=20 and typeofdata like 'V~O%';
update ld_producttoolfield set uitype=1,typeofdata='V~O~100' where tabid=22 and columnname='usageunit';
-- 2017-06-20

insert into ld_attachmentsforbillsdetails(attachmentsid,filename,newfile_name,size,path,type,lineitem_id)
select attachmentsid,filename,newfile_name,size,path,type,lineitem_id from ld_attachmentsforbills
where attachmentsid not in (select attachmentsid from ld_attachmentsforbillsdetails);

SET @report_name='库存余额表';
SET @report_template='default_warehouse_products.mrt';
SET @report_describe='数据来源：产品库存，查看范围：所有数据';
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,'template',@report_template,@sequence+1,0,1,0,'InventoryQuery',@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);
delimiter;

update ld_producttoolfield 
LEFT JOIN ld_field on ld_field.fieldid = ld_producttoolfield.fieldid 
set ld_producttoolfield.uitype = ld_field.uitype,ld_producttoolfield.typeofdata = ld_field.typeofdata 
where ld_producttoolfield.fieldid > 0 and input_type = 1;
delimiter;

UPDATE ld_tab SET mobilepresence = CONCAT_WS(',',mobilepresence,'weixin')
WHERE  `name` IN ('Accounts','Products', 'ContactRecords', 'Potentials',
                             'HelpDesk', 'Commission', 'CashBill', 'OutboundOrder', 'TimeSheet', 'PublicAnnouncement',
                             'SalesOrder', 'Contacts', 'Expense', 'Quotes', 'ServiceContracts', 'Faq',
                             'Project', 'Campaigns', 'ProjectTask','NormalApprove', 'AddJobBill', 'MinusJobBill',
                             'BusinessApply', 'LoanApply', 'CardApply') AND locate('weixin',mobilepresence)=0;
                             delimiter;

insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select  29,'accountdatadup',0,'ACCOUNTDUPLICATECHECK' from dual 
where not exists(select 1 from ld_actionmapping where actionid=29 and actionname='accountdatadup');
delimiter;

insert into ld_profileallpermission(tabid,operation)
select 6,29 from dual where not exists(select 1 from ld_profileallpermission  where tabid=6 and operation=29);
delimiter;

select tabid into @tabid from ld_tab where name='ServiceCharge';
insert into ld_profileallpermission(tabid,operation)
select @tabid,29 from dual where not exists(select 1 from ld_profileallpermission  where tabid=@tabid and operation=29);
delimiter;

insert into  ld_profile2standardpermissions (profileid,tabid,operation,permissions,sequence)
select profileid ,6,29,0,20  from ld_profile  where not exists(select 1 from ld_profile2standardpermissions where operation=29 and tabid=6);
delimiter;

select tabid into @tabid from ld_tab where name='ServiceCharge';
insert into  ld_profile2standardpermissions (profileid,tabid,operation,permissions,sequence)
select profileid ,@tabid ,29,0,20  from ld_profile  where not exists(select 1 from ld_profile2standardpermissions where operation=29 and tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='products';
delete  from ld_profileallpermission where tabid=@tabid and(operation=8 or operation=10);
delete from ld_profile2standardpermissions where tabid=@tabid and(operation=8 or operation=10);
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
select fieldid into @triggerid from ld_field where tabid=@tabid and uitype=202;
select fieldid into @effectid from ld_field where tabid=@tabid and columnname='accountid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
select 'main',@triggerid,@effectid,'column','accountid' from dual where not exists
(select 1 from ld_related_field where trigger_fieldid=@triggerid and effect_fieldid=@effectid);
delimiter;
-- 2017-06-22

update ld_reminds set reltab='ReportLog' where reltab='' and content like '%报提交提醒%';

DROP PROCEDURE IF EXISTS `ldcrm_add_reminder`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_reminder`(
	tmp_content text,
	tmp_recieverid int(19),
    tmp_reltab varchar(100),
	tmp_related_to int(19)
    
)
BEGIN
	
	set @maxid=0;
	select max(crmid) into @maxid from ld_crmentity;
	insert into ld_crmentity(crmid,setype)
	select @maxid+1,'Reminds';			
	insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
	select @maxid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0;

	update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);

end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_dailyreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_dailyreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE d.`name`='ReportLog'
			AND permissions=0
			AND a.`status`='Active';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remind='不提醒';
	SELECT IFNULL(dailyreminddate,'不提醒') INTO @remind FROM ld_workremindset LIMIT 1;
	
	SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '日报提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE();

	IF @remind<>'不提醒' AND WEEKDAY(NOW())<5 AND @cnt=0 AND DATE_FORMAT(DATE_ADD(NOW(),INTERVAL 1 HOUR),'%H:%i')>=@remind AND DATE_FORMAT(NOW(),'%H:%i')<=@remind THEN
		OPEN Mycur;
		FETCH Mycur INTO tmp_id;
		WHILE (tmp_id IS NOT NULL) DO
			IF NOT EXISTS (SELECT 1 FROM ld_dailyreport WHERE startdate=CURDATE() AND dstatus=1 AND smcreatorid=tmp_id) THEN
				SET @content=CONCAT('日报提交提醒：您该提交日报啦，还有一个小时就到提交期限哦');
				CALL ldcrm_add_reminder(@content,tmp_id,'ReportLog',0);
			END IF;
		FETCH Mycur INTO tmp_id;
		END WHILE;
		CLOSE Mycur;	
	END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `task_weekreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_weekreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE d.`name`='ReportLog'
			AND permissions=0
			AND a.`status`='Active';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remind='不提醒';
	SELECT IFNULL(weekreminddate,'不提醒') INTO @remind FROM ld_workremindset LIMIT 1;

	SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '周报提交提醒：%' AND WEEK(date_time)=WEEK(CURDATE());

	IF @remind<>'不提醒' AND WEEKDAY(NOW())IN (@remind-2,@remind-1) AND @cnt=0 THEN
		OPEN Mycur;
		FETCH Mycur INTO tmp_id;
		WHILE (tmp_id IS NOT NULL) DO
			IF NOT EXISTS (SELECT 1 FROM ld_weekreport WHERE Weeksofyear=WEEK(CURDATE()) AND yearbol=YEAR(CURDATE()) AND `status`=1 AND smcreatorid=tmp_id) THEN
				IF WEEKDAY(NOW())=@remind-2 THEN
					SET @content=CONCAT('周报提交提醒：您该提交周报啦，明天是最后一天期限哦');
				ELSEIF WEEKDAY(CURDATE())=@remind-1 THEN
					SET @content=CONCAT('周报提交提醒：您该提交周报啦，今天是最后一天期限哦');
				END IF;
				CALL ldcrm_add_reminder(@content,tmp_id,'ReportLog',0);
			END IF;
		FETCH Mycur INTO tmp_id;
		END WHILE;
		CLOSE Mycur;	
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_monthreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_monthreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE d.`name`='ReportLog'
			AND permissions=0
			AND a.`status`='Active';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remind='不提醒';
	SELECT IFNULL(monthreminddate,'不提醒') INTO @remind FROM ld_workremindset LIMIT 1;

	IF @remind<>'不提醒' THEN
		IF @remind>=20 AND @remind<32 THEN
			SET @yue=MONTH(CURDATE());
			SET @do_remind=IF(DAY(CURDATE())>=@remind-2 AND DAY(CURDATE())<=@remind,1,0);
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月报提交提醒：%' AND date_time>=DATE_ADD(CURDATE(),INTERVAL @remind-DAY(CURDATE())-2 DAY);
			SET @days=@remind-DAY(CURDATE())+1;
		ELSEIF @remind=40 THEN
			SET @yue=MONTH(CURDATE());
			SET @do_remind=IF(DATE_ADD(CURDATE(),INTERVAL 2 DAY)>=LAST_DAY(CURDATE()),1,0);
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月报提交提醒：%' AND date_time>=DATE_SUB(LAST_DAY(CURDATE()),INTERVAL 2 DAY);	
			SET @days=DATEDIFF(LAST_DAY(CURDATE()),CURDATE())+1;
		ELSEIF @remind<=2 AND DAY(CURDATE())>=25 THEN
			SET @yue=MONTH(CURDATE());
			SET @do_remind=IF(CURDATE()>=DATE_ADD(LAST_DAY(CURDATE()),INTERVAL @remind-2 DAY),1,0);
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月报提交提醒：%' AND date_time>=DATE_ADD(LAST_DAY(CURDATE()),INTERVAL @remind-2 DAY);	
			SET @days=DATEDIFF(DATE_ADD(LAST_DAY(CURDATE()), INTERVAL @remind DAY),CURDATE())+1;
		ELSEIF @remind<=2 AND DAY(CURDATE()) IN (1,2) THEN
			SET @yue=MONTH(CURDATE())-1;
			SET @do_remind=IF(CURDATE()<=DATE_ADD(CURDATE(),INTERVAL @remind-DAY(CURDATE()) DAY),1,0);
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月报提交提醒：%' AND date_time>=DATE_ADD(CURDATE(),INTERVAL @remind-DAY(CURDATE())-2 DAY);	
			SET @days=DATEDIFF(DATE_ADD(CURDATE(),INTERVAL @remind-DAY(CURDATE()) DAY),CURDATE())+1;
		ELSEIF @remind>=3 AND @remind<=5 THEN
			SET @yue=MONTH(CURDATE())-1;
			SET @do_remind=IF(CURDATE()>=DATE_ADD(CURDATE(),INTERVAL @remind-DAY(CURDATE())-2 DAY) AND CURDATE()<=DATE_ADD(CURDATE(),INTERVAL @remind-DAY(curdate()) DAY),1,0);
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月报提交提醒：%' AND date_time>=DATE_ADD(CURDATE(),INTERVAL @remind-DAY(CURDATE())-2 DAY);
			SET @days=DATEDIFF(DATE_ADD(CURDATE(),INTERVAL @remind-DAY(curdate()) DAY),CURDATE())+1;
		ELSE 
				SET @do_remind=0;
		END IF;

		IF @do_remind=1 AND @cnt=0 THEN 
			OPEN Mycur;
			FETCH Mycur INTO tmp_id;
			WHILE (tmp_id IS NOT NULL) DO
				IF NOT EXISTS (SELECT 1 FROM ld_monthreport WHERE monthofyear=@yue AND `Status`=1 AND smcreatorid=tmp_id) THEN
					IF @days=1 THEN
						SET @content=CONCAT('月报提交提醒：您该提交月报啦，今天就是提交期限哦');
					ELSE
						SET @content=CONCAT('月报提交提醒：您该提交月报啦，还有',@days,'天就是提交期限哦');
					END IF;
					CALL ldcrm_add_reminder(@content,tmp_id,'ReportLog',0);
				END IF;
			FETCH Mycur INTO tmp_id;
			END WHILE;
			CLOSE Mycur;	
		END IF;
	END IF;
end ||
delimiter;

SET GLOBAL event_scheduler = on;
DROP EVENT IF EXISTS `task_dailyreport_reminder`;
CREATE EVENT `task_dailyreport_reminder`
ON SCHEDULE EVERY 10 MINUTE STARTS '2017-06-21 14:00:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

CALL task_dailyreport_reminder();
delimiter;

DROP EVENT IF EXISTS `task_weekreport_reminder`;
CREATE EVENT `task_weekreport_reminder`
ON SCHEDULE EVERY 1 HOUR STARTS '2017-06-22 05:00:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

CALL task_weekreport_reminder();
delimiter;

DROP EVENT IF EXISTS `task_monthreport_reminder`;
CREATE EVENT `task_monthreport_reminder`
ON SCHEDULE EVERY 1 HOUR STARTS '2017-06-22 08:30:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

CALL task_monthreport_reminder();
delimiter;

select tabid into @tabid from ld_tab where `name`='TimeSheet';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='total';
update ld_tranlabel set fieldlabel='合计' where Relateid=@relateid and trantable='ld_tabdetailfield' and languagetype='zh' and fieldlabel='Total'
	and not exists (select 1 from ld_version where account='utrc');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_insertinto_sequence`;
delimiter ||
CREATE PROCEDURE `ldcrm_insertinto_sequence`(
)
BEGIN

	declare i int default 0;
	delete from sequence;

	while i<=2000 DO
		insert into sequence(seq) select i;
		set i=i+1;
	end while;
end ||
delimiter;

call ldcrm_insertinto_sequence();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_read_tmpreminder`;
delimiter ||
CREATE PROCEDURE `ldcrm_read_tmpreminder`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_content text DEFAULT '';
	DECLARE tmp_recieverid INT(19) DEFAULT 0;
	DECLARE tmp_remindtime datetime;
	DECLARE tmp_reltab varchar(100) DEFAULT '';
	DECLARE tmp_related_to INT(19) DEFAULT 0;
	DECLARE tmp_ruleid INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR 
		SELECT
			id,
			content,
			reminderid,
			remindtime,
			reltab,
			related_to,
			reminds_ruleid 
		FROM ld_tmpreminder 
		WHERE remindtime<=NOW() 
		ORDER BY remindtime DESC LIMIT 50;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	OPEN Mycur;
	FETCH Mycur INTO tmp_id,tmp_content,tmp_recieverid,tmp_remindtime,tmp_reltab,tmp_related_to,tmp_ruleid;
	WHILE (tmp_id IS NOT NULL) DO
		DELETE FROM ld_tmpreminder WHERE id=tmp_id;
		set @maxid=0;
		select max(crmid) into @maxid from ld_crmentity;
		insert into ld_crmentity(crmid,setype)
		select @maxid+1,'Reminds';
		
		update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
			
		insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
		select @maxid+1,tmp_content,tmp_remindtime,tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,tmp_ruleid,0,0,0,tmp_remindtime,tmp_remindtime,null,0;

	FETCH Mycur INTO tmp_id,tmp_content,tmp_recieverid,tmp_remindtime,tmp_reltab,tmp_related_to,tmp_ruleid;
	END WHILE;
	CLOSE Mycur;	
	
end ||
delimiter;

DROP EVENT IF EXISTS `task_read_tmpreminder`;
CREATE EVENT `task_read_tmpreminder`
ON SCHEDULE EVERY 30 SECOND STARTS '2017-06-23 14:00:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

CALL ldcrm_read_tmpreminder();
delimiter;

update ld_desk set fieldlabel='客户和所有联系人' where labelbol='CUSTOMERANDRELATEDCONTACT' and languagetype='zh';
update ld_desk set fieldlabel='Customer and all related contacts' where labelbol='CUSTOMERANDRELATEDCONTACT' and languagetype='en';

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=3&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Accounts');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=5&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Contacts');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=6&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='ContactRecords');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=7&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Potentials');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=8&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Quotes');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=9&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='SalesOrder');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=11&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='ServiceCharge');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=12&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='HelpDesk');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=13&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Project');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=14&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='ProjectTask');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=15&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='ProjectMilestone');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=16&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='TimeSheet');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=17&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='ProjectProgress');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=18&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='CashBill');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=19&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='SendCashBill');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=20&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Stock');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=21&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Vendors');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=22&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='VendorContact');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=23&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='VendorContactRecords');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=24&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='PurchaseOrder');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=25&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Products');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=27&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='NormalApprove');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=28&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='AddJobBill');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=29&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='MinusJobBill');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=30&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='BusinessApply');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=31&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='LoanApply');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=32&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='CardApply');
    
update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=26&fromuid=1'
	where linktype='ReportLog' and tabid=(select tabid from ld_tab where `name`='ReportLog');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=34&fromuid=1'
	where linktype='Settings'  AND linklabel='WorkRemindSet';

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=35&fromuid=1'
	where linktype='Settings'  AND linklabel='AccountsContactsField';

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=36&fromuid=1'
	where linktype='Settings'  AND linklabel='TemplateprintList';

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=36&fromuid=1'
	where linktype='Settings'  AND linklabel='createtemplatePrint';

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=37&fromuid=1'
	where linktype='Settings'  AND linklabel='publicAccountSet';

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=38&fromuid=1'
	where linktype='Allocate'  AND linklabel='averageDistribution';
    
update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=10&fromuid=1'
	where linktype='Import' and tabid=(select tabid from ld_tab where `name`='ServiceContracts');
    
update ld_links set tabid=16 where tabid=9;
delete from ld_links where linktype='Import' and tabid in (8,15,23,26); 
delete from ld_links where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Expense'); 
delete from ld_links where linktype='Import' and tabid=(select tabid from ld_tab where `name`='OutboundOrder'); 
delete from ld_links where linktype='Import' and tabid=(select tabid from ld_tab where `name`='PutCash'); 
delete from ld_links where linktype='Import' and tabid=(select tabid from ld_tab where `name`='CashDeposit'); 
delete from ld_links where linktype='Import' and tabid=(select tabid from ld_tab where `name`='Commission'); 
delete from ld_links where linktype='Import' and tabid=(select tabid from ld_tab where `name`='PurchaseInvoice'); 
delete from ld_links where linktype='Import' and tabid=(select tabid from ld_tab where `name`='ServiceReturn');

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=39&fromuid=1'
	where linktype='Import' and tabid=16;  
    
update ld_field set readonly=1,displaytype=2 where columnname in('currentapprover','approvestatus','approveby') and tabid<>29;
delimiter;      
-- 2017-06-23


update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
delimiter;

update ld_version set old_version='V7.0.3',current_version='V7.0.3',remark='V7.0.3-20170623';
delimiter;