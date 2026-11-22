insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BELOW','以下','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BELOW' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BELOW','Below ','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BELOW' and labeltype='jspop' and languagetype='en');
delimiter;
-- 2017-02-24

update ld_producttoolfield set uitype = 1,typeofdata = if(LOCATE('M',typeofdata) >0,'V~M~100','V~O~100') where input_type = 1 and defaultcolumn = 1;
delimiter;
-- 2017-03-01

update ld_autotaskquery set `query`=CONCAT("DROP PROCEDURE IF EXISTS `task_contact_birthday_reminds_before1day`; 
delimiter $$ 
CREATE PROCEDURE `task_contact_birthday_reminds_before1day`( 
) 
BEGIN 
DECLARE done int DEFAULT 0; 
DECLARE task_crmid int default 0; 
DECLARE task_name varchar(200) default ''; 
DECLARE task_user int default 0; 
DECLARE task_time datetime DEFAULT NOW(); 
DECLARE mycursor cursor for SELECT contactid,lastname,smownerid FROM ld_contactdetails WHERE deleted = 0 AND birthday != '' AND 
(DATE_FORMAT(birthday,'%m%d') - DATE_FORMAT(CURDATE(),'%m%d') = 1) ORDER BY contactid; 
DECLARE CONTINUE HANDLER for not found set dOne= 1; 
OPEN mycursor; 
fetch mycursor into task_crmid,task_name,task_user; 
LOOP1: WHILE done != 1 DO 
IF task_crmid > 0 THEN 
set @maxid = 0; 
select max(crmid) into @maxid from ld_crmentity; 
insert into ld_crmentity(crmid,setype) 
select @maxid+1,'Reminds'; 
insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted) 
select @maxid+1,concat('明天是',task_name,'的生日，请送上生日的祝福。'),task_time,task_user,'未读',task_crmid,'Contacts',0,0,0,1,1,1,task_time,task_time,'',0; 
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity); 
END IF; 
FETCH mycursor INTO task_crmid,task_name,task_user; 
END WHILE LOOP1; 
close mycursor; 
END $$
delimiter",";
CALL task_contact_birthday_reminds_before1day();
delimiter",";")
WHERE `query` like 'DROP PROCEDURE IF EXISTS `task_contact_birthday_%';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPORTDATATITLE','导出数据','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXPORTDATATITLE');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPORTDATATITLE','Export data','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXPORTDATATITLE');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPORTINGDATA','正在导出数据，请不要关闭或刷新浏览器','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXPORTINGDATA');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPORTINGDATA','Exporting data, please do not refresh or close the browser','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXPORTINGDATA');
delimiter;
-- 2017-03-02

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

update ld_version set old_version='V6.6.4',current_version='V6.6.4',remark='V6.6.4-20170302';
delimiter;