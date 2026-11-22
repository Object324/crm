DROP PROCEDURE IF EXISTS `rest_cvcolumnlist_wx`;
delimiter ||
CREATE  PROCEDURE `rest_cvcolumnlist_wx`(
	tmp_module VARCHAR(100),
	tmp_column VARCHAR(100),
	tmp_rownum INT(1),
	tmp_colnum INT(1),
	tmp_showtag VARCHAR(20),
	tmp_sysdefault VARCHAR(20)
)
BEGIN
	
	SET @columnname=(
		SELECT 
			CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1)) 
		FROM ld_tab a
		LEFT JOIN ld_field b ON a.tabid=b.tabid
		WHERE a.`name`=tmp_module
			AND b.columnname=tmp_column
		LIMIT 1);

	DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
	INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
	SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;

update ld_desk set fieldlabel='修改字段' where labelbol='LBL_Field' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='修改前' where labelbol='LBL_Earlier' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='修改后' where labelbol='LBL_Present' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='修改人' where labelbol='OPERATOR' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='修改时间' where labelbol='OPERATTIME' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
-- 2017-12-08

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CURRENTURLNOWECHAT','当前登录地址没有绑定企业微信，是否立即绑定？','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CURRENTURLNOWECHAT' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CURRENTURLNOWECHAT','The current login address is not bound to the enterprise WeChat, or is it immediately bound?','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CURRENTURLNOWECHAT' and labeltype='fixedstr');
delimiter;
-- 2017-12-12

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approvelog','审批日志','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'approvelog' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','approvelog','Approve log','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'approvelog' and labeltype = 'fixedstr');
delimiter;

update ld_templatesstuff set stufftype = 'chart' where stuffid in (1,4,5,9,19);
update ld_templatesstuff set stufftype = 'transaction' where stuffid in (33,34);
update ld_templatesstuff set stufftype = 'saleskit' where stuffid in (35,36);
update ld_templatesstuff set stufftype = 'reportLog' where stuffid in (24);
update ld_templatesstuff set stufftype = 'twotable' where stuffid in (2);
update ld_templatesstuff set stufftype = 'notebook' where stuffid in (21);
update ld_templatesstuff set stufftype = 'default' where stufftype = 'Default';
delimiter;

delete from ld_desk where labelbol='CURRENTURLNOWECHAT';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ERR_MISSING_REQUIRED_FIELDS','必填内容不能为空；','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ERR_MISSING_REQUIRED_FIELDS' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ERR_MISSING_REQUIRED_FIELDS','Mandatory field can not be empty;','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ERR_MISSING_REQUIRED_FIELDS' and labeltype = 'jspop');
delimiter;
-- 2017-12-13

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
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
delimiter;

update ld_version set old_version='V7.1.3',current_version='V7.1.3',remark='V7.1.3-20171212',wx_version='V8';
delimiter;