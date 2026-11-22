update ld_salesorder set stockpresence = '未出库' where stockpresence = 'SALESORDERNOTOUTSTOCK';
update ld_salesorder set stockpresence = '未采购' where stockpresence = 'NOPURCHASE';
delimiter;

update ld_desk set fieldlabel = '未找到审批人，请检查审批流程设置！' where labelbol = 'NONEXTAPPROVER' and Labeltype = 'jspop' and languagetype = 'zh';
update ld_desk set fieldlabel = 'No approver found, please check the approval process!' where labelbol = 'NONEXTAPPROVER' and Labeltype = 'jspop' and languagetype = 'en';
delimiter;

update ld_field set defaultvalue=0 where tabid=2 and columnname='amount' and defaultvalue is NULL;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CANCELTHEASSOCIATED','取消关联','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CANCELTHEASSOCIATED' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CANCELTHEASSOCIATED','Cancel the associated','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CANCELTHEASSOCIATED' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AREYOUSUREYOUWANTTOCANCELTHECONNECTION','确定要取消关联吗？','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AREYOUSUREYOUWANTTOCANCELTHECONNECTION' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AREYOUSUREYOUWANTTOCANCELTHECONNECTION','Are you sure you want to cancel the connection?','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AREYOUSUREYOUWANTTOCANCELTHECONNECTION' and Labeltype='jspop'); 
delimiter; 
-- 2016-01-17

SELECT tabid into @tabid from ld_tab where `name`='Documents';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='filelocationtype';
update ld_tranlabel set fieldlabel='附件类型' WHERE languagetype='zh' AND tabid=@tabid AND Relateid=@fieldid;
update ld_tranlabel set fieldlabel='Attachment type' WHERE languagetype='en' AND tabid=@tabid AND Relateid=@fieldid;
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CANNOTBELESSTHANOREQUALTO','不能小于等于','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTBELESSTHANOREQUALTO' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CANNOTBELESSTHANOREQUALTO','Can not be less than or equal to ','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTBELESSTHANOREQUALTO' and Labeltype='jspop'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','NOPROCESSPLEASESETPROCESS','您没有适用的审批流程，请联系管理员检查并设置审批流程！ ','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'NOPROCESSPLEASESETPROCESS' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','NOPROCESSPLEASESETPROCESS','You do not have appropriate approval process, please contact the administrator to check and set the approval process!','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'NOPROCESSPLEASESETPROCESS' and languagetype = 'en' and labeltype = 'fixedstr');
-- 2016-01-18

UPDATE ld_desk set fieldlabel=' is not mapped, import failed!' where Labeltype='jspop' AND labelbol='NOTMAPPEDIMPORTFAILED' AND languagetype='en';
delimiter;

insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-01-22',1,'补春节假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-01-22');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-02-04',1,'补春节假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-02-04');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-04-01',1,'补清明假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-04-01');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-05-27',1,'补端午假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-05-27');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-09-30',1,'补国庆假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-09-30');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-05-27',1,'补端午假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-05-27');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-01-01',2,'元旦放假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-01-01');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-01-02',2,'元旦放假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-01-02');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-01-27',2,'春节放假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-01-27');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-01-28',2,'春节放假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-01-28');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-01-29',2,'春节放假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-01-29');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-01-30',2,'春节放假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-01-30');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-01-31',2,'春节放假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-01-31');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-02-01',2,'春节放假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-02-01');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-02-02',2,'春节放假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-02-02');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-04-02',2,'清明假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-04-02');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-04-03',2,'清明假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-04-03');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-04-04',2,'清明假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-04-04');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-04-29',2,'五一假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-04-29');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-04-30',2,'五一假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-04-30');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-05-01',2,'五一假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-05-01');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-05-28',2,'端午假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-05-28');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-05-29',2,'端午假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-05-29');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-05-30',2,'端午假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-05-30');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-10-01',2,'国庆假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-10-01');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-10-02',2,'国庆假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-10-02');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-10-03',2,'国庆假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-10-03');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-10-04',2,'国庆假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-10-04');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-10-05',2,'国庆假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-10-05');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-10-06',2,'国庆假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-10-06');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-10-07',2,'国庆假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-10-07');
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2017','2017-10-08',2,'国庆假',1 from dual 
where not exists(select 1 from ld_workingdays where date='2017-10-08');
-- 2017-01-20

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

update ld_version set old_version='V6.6.1' ,current_version='V6.6.1' ,remark='V6.6.1-20170120';
delimiter;