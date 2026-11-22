update ld_desk set fieldlabel="共%d条记录，明细%d条，覆盖%d条记录，成功导入%d条记录，%s失败%d条记录%s。" where labelbol="IMPORTRECORDTIP" and  languagetype="zh";

update ld_desk set fieldlabel="A total of %d records, detailed %d, covering %d records, successfully imported %d records, %sfailed %d records%s." where labelbol="IMPORTRECORDTIP" and  languagetype="en";
delimiter;

DELETE FROM ld_systems_deploy WHERE description='设置移动端单据详情界面是否启用另存为PDF格式功能' AND deploy_type<>268;
SET @roottype=8;
SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 1,268,'设置移动端单据详情界面是否启用另存为PDF格式功能',"",@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=268);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',268,268,'设置移动端单据详情界面是否启用另存为PDF格式功能'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_systems_deploy' and tabid = 268 and relateid=268);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',268,268,'Sets whether Save as PDF function is enabled in the mobile terminal document detail interface'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_systems_deploy' and tabid = 268 and relateid=268);
delimiter;

select sequence into @sequence from ld_homestuffdetail where stufflabel="NewInvoiceAmount" and stuffid=35;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
set @sequence=@sequence+1;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'NewQuotesCount','fixedstr','ld_quotes.quoteid','count','index.php?pageto_module=Quotes&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesCount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:createdtime:createdtime:Quotes_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:createdtime:createdtime:Quotes%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:approvestatus:approvestatus:Quotes_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:approvestatus:approvestatus:Quotes%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewQuotesCount','{$Quotes.Quotes}数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewQuotesCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewQuotesCount','New{$Quotes.Quotes}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewQuotesCount' and Labeltype='fixedstr');
delimiter;

UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;


select sequence into @sequence from ld_homestuffdetail where stufflabel="NewQuotesCount" and stuffid=35;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
set @sequence=@sequence+1;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'NewQuotesAmount','fixedstr','ld_quotes.total','sum','index.php?pageto_module=Quotes&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesAmount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesAmount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:createdtime:createdtime:Quotes_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:createdtime:createdtime:Quotes%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:approvestatus:approvestatus:Quotes_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:approvestatus:approvestatus:Quotes%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewQuotesAmount','{$Quotes.Quotes}金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewQuotesAmount' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewQuotesAmount','{$Quotes.Quotes} amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewQuotesAmount' and Labeltype='fixedstr');
delimiter;

UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;


update ld_homestuffdetail set cssname="item-ico-quotes" where stuffid=35 and stufflabel='NewQuotesAmount';
update ld_homestuffdetail set cssname="item-ico-quotes" where stuffid=35 and stufflabel='NewQuotesCount';
delimiter;

DROP PROCEDURE IF EXISTS `execute_account_publicoperation`;
delimiter ||
CREATE PROCEDURE `execute_account_publicoperation`()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_account_public_pool where deleted = 0;
	declare continue handler  for not   found  SET done =1;
	if NOT EXISTS (SELECT 1 FROM ld_account_public WHERE STATUS = 'yes')  THEN
		if NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicaccount')  THEN
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicaccount';
			call account_singlerecycle_normal_rule();
			call account_singlerecycle_normal_rule_beforeremind();
			OPEN cur1;
				Fetch cur1 into tmp_pool_id;
					loop1: while  done<>1 DO
						call account_singlerecycle_highsea_rule(tmp_pool_id);
						call account_singlerecycle_highsea_rule_beforeremind(tmp_pool_id);
				Fetch cur1 into tmp_pool_id;
			end while loop1;
			close cur1;
		end if;
	end if;
end ||
delimiter;
-- 2021-01-21

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

UPDATE ld_version SET old_version='V8.3.7.1',current_version='V8.3.7.1',remark='V8.3.7.1-20210121',wx_version='V8.3.7.1';
delimiter;