UPDATE ld_desk SET fieldlabel='Details' where labelbol='details1' and languagetype='en';
delimiter;

SET @labelbol = 'SORT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'排序','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sort','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'CREATE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新建','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Create','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

UPDATE ld_desk SET fieldlabel='请选择至少两条记录！' where labelbol='SELECTLEASTTWO' and languagetype='zh';
UPDATE ld_desk SET fieldlabel='Please select at least two records!' where labelbol='SELECTLEASTTWO' and languagetype='en';
delimiter;

UPDATE ld_desk SET fieldlabel='Step 1: Select a parent field and a child field. Click on ''Next'' when you are done.' where labelbol='DEPENCYSELECTNEXTPREVFIELD' and languagetype='en';
delimiter;

SET @labelbol = 'PUBLISH';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'发表','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Publish','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PUBLISHModComments';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'发表了{$ModComments.ModComments}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Published {$ModComments.ModComments}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REPLIED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'回复了','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Replied','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='The all include unassigned pool' where fieldlabel='the all include unassigned pool' and labelbol='theallincludeunassignedpool' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk SET fieldlabel='The default all include unassigned' where fieldlabel='the default all include unassigned' and labelbol='thedefaultallincludeunassigned' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk SET fieldlabel='Create public account pool' where fieldlabel='create public account pool' and labelbol='createpublicaccountpool' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk SET fieldlabel='Maximum number of {$Accounts.Accounts}' where fieldlabel='maximum number of {$Accounts.Accounts}' and labelbol='maximumnumberofcustomers' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk SET fieldlabel='Maximum number of {$Leads.Leads}' where fieldlabel='maximum number of {$Leads.Leads}' and labelbol='maximumnumberofleads' and languagetype='en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETFREEZECOLUMN','设置冻结前几列','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETFREEZECOLUMN' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETFREEZECOLUMN','Set the first few columns to freeze','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETFREEZECOLUMN' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SetByRole','按角色','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetByRole' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SetByRole','Set by role','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetByRole' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CLICKIMAGETOSEEEFFCT','点击图片查看效果','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CLICKIMAGETOSEEEFFCT' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CLICKIMAGETOSEEEFFCT','Click on the image to see the effect','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CLICKIMAGETOSEEEFFCT' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ORIGINALLABELNAME','原标签名称','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ORIGINALLABELNAME' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ORIGINALLABELNAME','Original Label Name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ORIGINALLABELNAME' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MODIFIEDLABEL','修改后标签','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MODIFIEDLABEL' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MODIFIEDLABEL','Modified Label','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MODIFIEDLABEL' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ALLTIME','全部时间','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CLICKIMAGETOSEEEFFCT' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ALLTIME','All time','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CLICKIMAGETOSEEEFFCT' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='Advanced configuration' where labelbol='HighConfig' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk SET fieldlabel='Applicate submit scope' where labelbol='ApplicatesubmitScope' and languagetype='en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','FormSet','表格设置','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FormSet' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','FormSet','Form Settings','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FormSet' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NOTPASS','不通过','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOTPASS' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NOTPASS','Not pass','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOTPASS' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MAXFILENUMBER','最多文件数为6','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FormSet' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MAXFILENUMBER','The maximum number of files is 6','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FormSet' and labeltype='jspop');
delimiter;

UPDATE ld_desk SET fieldlabel='Assign value method' where labelbol='AssignValueMethod' and languagetype='en' and Labeltype='fixedstr';
delimiter;

UPDATE ld_field SET allowhide='no',masseditable=0 WHERE tablename='ld_bankaccountset' AND columnname='smownerid';
delimiter;

CALL AddColumn('ld_singin','triggercount','INT','19',0);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NOATTACHMENT','所选单据没有附件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOATTACHMENT' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NOATTACHMENT','The selected document has no attachments','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOATTACHMENT' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOWNLOADFILENUM','共选择 %d  条记录，成功提交 %d 条，失败 %d 条。','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOWNLOADFILENUM' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOWNLOADFILENUM','Totally select %d records, %d successful, %d failed.','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOWNLOADFILENUM' and labeltype='fixedstr');
delimiter;

SET @labelbol = 'WECHATAPPLETSETTINGSREMIND10';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'服务器无法访问网络','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The server cannot access the network','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @labelbol = 'DontRemind';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不提醒','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Don't remind",'fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @labelbol = 'suggestedsize145x40px';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'建议尺寸大小为：145*40(像素)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Recommended size: 145 * 40 (pixels)",'fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


UPDATE ld_desk SET fieldlabel='包含当前操作员' where labelbol='CURUSER' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='Include current operator' where labelbol='CURUSER' and languagetype='en' and Labeltype='fixedstr';
delimiter;


UPDATE ld_desk SET fieldlabel='任务未完成，不能向前推进！' where labelbol='CANNOTMOVEBEFORECOMPLETE' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='The task has not been completed and cannot move forward!' where labelbol='CANNOTMOVEBEFORECOMPLETE' and languagetype='en' and Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='任务未完成，不能向前推进！' where labelbol='CANNOTMOVEBEFORECOMPLETEAPP' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='The task has not been completed and cannot move forward!' where labelbol='CANNOTMOVEBEFORECOMPLETEAPP' and languagetype='en' and Labeltype='fixedstr';
delimiter;


DROP EVENT IF EXISTS `update_modenity_num`;
delimiter ||
CREATE EVENT `update_modenity_num` ON SCHEDULE EVERY 1 DAY STARTS '2023-02-09 00:30:00' ON COMPLETION NOT PRESERVE ENABLE DO 
UPDATE ld_modentity_num
SET 
	start_id ='1',
	cur_id = '1'
WHERE active = 1 
	AND reset_value = 'yes'
	AND (
		CASE 
			WHEN datetype LIKE '%dd%' THEN 1=1 
			WHEN datetype LIKE '%mm%' AND DAY(NOW())=1 THEN 1=1
		END);
||
delimiter;

UPDATE ld_desk SET fieldlabel='The selected cascade field duplicates or forms a circular cascade relationship. This cascade relationship cannot be created!' where labelbol='DEPENCYCYCLE' and languagetype='en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ENTERPRISEID','企业ID','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENTERPRISEID' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ENTERPRISEID','Enterprise ID','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENTERPRISEID' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ENTERPRISEIDREMIND','可以在"企业微信->我的企业"查看','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENTERPRISEIDREMIND' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ENTERPRISEIDREMIND','You can check in "Enterprise wechat -> My Enterprise"','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENTERPRISEIDREMIND' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='Number of signed documents' where labelbol='SignContractCount' and languagetype='en' and fieldlabel='签约单数';
update ld_desk set fieldlabel='Estimated transaction opportunity amount' where labelbol='AdvancePotentialsAmount' and languagetype='en' and fieldlabel='预计成交机会金额';
update ld_desk set fieldlabel='New signin record' where labelbol='NewSignCount' and languagetype='en' and fieldlabel='新建签到记录';
delimiter;

SET @labelbol = 'WHETHERICONSIMPLESTYLE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'移动端图标是否更换简易风格','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether mobile terminal icon simple style','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='不能为空！' where labelbol='CANOTEMPTY' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='can not be empty!' where labelbol='CANOTEMPTY' and languagetype='en' and Labeltype='jspop';
delimiter;

ALTER TABLE ld_validatasavemain MODIFY COLUMN tipzh Text;
ALTER TABLE ld_validatasavemain MODIFY COLUMN tipen Text;
delimiter;
-- 2023-02-03

UPDATE ld_field SET editpage='listview' WHERE uitype=15 AND displaytype=1 and columnname = 'rating';
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

UPDATE ld_version SET old_version='V8.4.8.9',current_version='V8.4.8.9',remark='V8.4.8.9-20230210',wx_version='V8.4.8.8';
delimiter;