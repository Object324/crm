select tabid into @tabid from ld_tab where `name` = 'Paymentplan';
update ld_field set approve_demand = 2 where tabid = @tabid and columnname = 'entitytypeid' and uitype = 202;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
update ld_field set approve_demand = 2 where tabid = @tabid and columnname = 'purchaseorder_id' and uitype = 202;
delimiter;

update ld_desk set fieldlabel = '当{$Accounts.Accounts}访问权为私有时: Mtd 访问权限必须设为私有' where labelbol = 'ACCOUNT_ACCESS_INFO' and languagetype = 'zh' and Labeltype = 'jspop';
update ld_desk set fieldlabel = 'Mtd access must be set to Private when the {$Accounts.Accounts} access is set to Private' where labelbol = 'ACCOUNT_ACCESS_INFO' and languagetype = 'en' and Labeltype = 'jspop';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_account_bwid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `accountid` int(11) NOT NULL DEFAULT '0',
  `bw_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_ENTERPRISEWECHAT','企业微信','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_ENTERPRISEWECHAT' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_ENTERPRISEWECHAT','Enterprise wechat','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_ENTERPRISEWECHAT' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_WECHATAPPLICATION','企业微信应用','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_WECHATAPPLICATION' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_WECHATAPPLICATION','Enterprise wechat application','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_WECHATAPPLICATION' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_WECHATAPPLICATION_DESCRIPTION','注销CRM账套对应的微信版本','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_WECHATAPPLICATION_DESCRIPTION' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_WECHATAPPLICATION_DESCRIPTION','The WeChat version of CRM cancellation','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_WECHATAPPLICATION_DESCRIPTION' and labeltype = 'fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label = 'LBL_OTHER_SETTINGS';
select sequence into @sequence from ld_settings_field where `name` = 'LBL_COMPANY_DETAILS' and blockid = @blockid;
update ld_settings_field set sequence = sequence + 1000 where blockid = @blockid and sequence > @sequence;
select MAX(fieldid) into @max_fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,`name`,iconpath,description,linkto,sequence,active)
select @max_fieldid+1,@blockid,'LBL_WECHATAPPLICATION','wechat.png','LBL_WECHATAPPLICATION_DESCRIPTION','index.php?module=Settings&action=Wechat&parenttab=Settings',@sequence+1,0 from DUAL
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'LBL_WECHATAPPLICATION');
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid = @blockid order by sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','wecharno','企业微信号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'wecharno' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','wecharno','Wechat no','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'wecharno' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','authorizingperson','应用授权人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'authorizingperson' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','authorizingperson','Authorizing person','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'authorizingperson' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','authorizingdate','应用授权日期','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'authorizingdate' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','authorizingdate','Authorizing date','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'authorizingdate' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','wechardescription','注销后，系统内的所有数据都会被清空，且该操作不可撤销，请谨慎操作！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'wechardescription' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','wechardescription','After the cancellation, all the data in the system will be cleared, and the operation is irrevocable. Please operate carefully！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'wechardescription' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','wechardescription1','注销后，企业微信将不能登录CRM系统，重新授权灵当CRM应用后才可登录CRM系统。','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'wechardescription1' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','wechardescription1','After the cancellation, the enterprise WeChat will not be able to log in to the CRM system and re authorize the CRM application to log in to the CRM system.','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'wechardescription1' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Reminds';
update ld_field set quickcreate = 1 where tabid = @tabid and columnname = 'status_rmd';
delimiter;

UPDATE ld_workreport_field SET label=REPLACE(label,'请填写','') WHERE label LIKE '请填写%';

update ld_desk set fieldlabel = '自定义日期' where labelbol = 'DATESELECTION' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Custom date' where labelbol = 'DATESELECTION' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
-- 2017-12-25

ALTER TABLE ld_users ALTER COLUMN push_news_reminds SET DEFAULT 1;
ALTER TABLE ld_users ALTER COLUMN push_work_reminds SET DEFAULT 1;
UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname IN ('push_wx_reminds','push_work_reminds','push_news_reminds');
UPDATE ld_field SET presence=1 WHERE tabid=29 AND columnname IN ('telephone_view','push_work_reminds','push_news_reminds');

update ld_systems_deploy set inputvalue='[{"value":"5","text":"5"},{"value":"20","text":"20"},{"value":"50","text":"50"} ,{"value":"100","text":"100"},{"sql":""}]' where deploy_type=151 ;
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 143;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = @roottype and sequence >=@sequence;
update ld_systems_deploy set sequence = @sequence,roottype = @roottype where deploy_type = 114;
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

update ld_desk set fieldlabel = '请输入换算率' where labelbol = 'ENTERVALIDCONVERSIONRATE' and languagetype = 'zh' and Labeltype = 'jspop';
delimiter;

UPDATE ld_field SET presence=1 WHERE tabid=14 AND columnname='discontinued' AND NOT EXISTS (SELECT 1 FROM ld_products);
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CardApply');
UPDATE ld_field SET quickcreate=0 WHERE tabid=@tabid AND columnname IN ('zh_companyname','zh_address','zh_name','zh_title','zh_department','zh_phone','zh_fax','zh_email');
delimiter;

update ld_desk set fieldlabel = '产品属性' where labelbol = 'THEFIELDBASEDONTHEBASICENTRY' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Products attribute' where labelbol = 'THEFIELDBASEDONTHEBASICENTRY' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '可选角色' where labelbol = 'AVAILABLEROLES' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '已选角色' where labelbol = 'SELECTEDROLES' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MANAGECATEGORIES','管理分类','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MANAGECATEGORIES' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MANAGECATEGORIES','Manage Categories','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MANAGECATEGORIES' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CREATECATEGORIES','新建分类','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CREATECATEGORIES' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CREATECATEGORIES','Create Categories','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CREATECATEGORIES' and labeltype = 'fixedstr');
delimiter;
-- 2017-12-27

call AddColumn('ld_parenttab','allocatetype','varchar','255','');
call AddColumn('ld_parenttab','allocateid','text','','');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_parenttab2users`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_parenttab2users`(
)
BEGIN

	DECLARE tmp_parenttabid INT(19) DEFAULT 0;
	DECLARE tmp_profieldid text DEFAULT NULL;  

	DECLARE MYCUSOR CURSOR FOR SELECT parenttabid,menu_profieldid FROM ld_parenttab;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_parenttabid = NULL;


	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_parenttabid,tmp_profieldid;
	WHILE(tmp_parenttabid IS NOT NULL) DO
		IF TRIM(IFNULL(tmp_profieldid,''))='' THEN
			UPDATE ld_parenttab SET allocatetype='all',allocateid=NULL WHERE parenttabid=tmp_parenttabid AND IFNULL(allocatetype,'')='';
		ELSE
			UPDATE ld_parenttab SET allocatetype='user',
				allocateid=(SELECT GROUP_CONCAT(id) FROM ld_users WHERE id NOT IN (SELECT id FROM ld_users WHERE FIND_IN_SET(profileid,'11,12'))) 
			WHERE parenttabid=tmp_parenttabid AND IFNULL(allocatetype,'')='';
		END IF;

		FETCH MYCUSOR INTO tmp_parenttabid,tmp_profieldid;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_reset_parenttab2users();
DROP PROCEDURE IF EXISTS `ldcrm_reset_parenttab2users`;
delimiter;

update ld_desk set fieldlabel = '产品属性' where labelbol = 'THEFIELDBASEDONTHEBASICENTRY' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Products attribute' where labelbol = 'THEFIELDBASEDONTHEBASICENTRY' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '可选角色' where labelbol = 'AVAILABLEROLES' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '已选角色' where labelbol = 'SELECTEDROLES' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','howtomaintrandepartanduser','如何维护部门和用户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'howtomaintrandepartanduser' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','howtomaintrandepartanduser','How to maintain departments and users','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'howtomaintrandepartanduser' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','howtomaintrandepartanduserinfo1','1.您的CRM系统已经绑定企业微信','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'howtomaintrandepartanduserinfo1' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','howtomaintrandepartanduserinfo1','1.Your CRM system has been bound to enterprise WeChat','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'howtomaintrandepartanduserinfo1' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','howtomaintrandepartanduserinfo2','2.请企业微信管理员在企业微信管理后台维护部门和用户信息','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'howtomaintrandepartanduserinfo2' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','howtomaintrandepartanduserinfo2','2. Ask the enterprise WeChat administrator to manage the background maintenance department and the user information in the enterprise WeChat','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'howtomaintrandepartanduserinfo2' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','howtomaintrandepartanduserinfo3','3.企业微信的部门和用户会自动同步到CRM系统','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'howtomaintrandepartanduserinfo3' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','howtomaintrandepartanduserinfo3',"3. Enterprise WeChat's departments and users automatically synchronize to the CRM system",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'howtomaintrandepartanduserinfo3' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SORTORDER','排序方式','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='SORTORDER');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SORTORDER','Sort Order','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='SORTORDER');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Reminds';
update ld_relatedlists set actions = '' where related_tabid = @tabid;
delimiter;

update ld_dashboard_app set modulenames='Potentials' where name='Salesfunnel';
update ld_dashboard_app set modulenames='SalesOrder,ServiceContracts' where name='Contractamount';
update ld_dashboard_app set modulenames='SalesOrder,ServiceContracts' where name='Salessituation';
update ld_dashboard_app set modulenames='CashBill' where name='Returnamount';
update ld_dashboard_app set modulenames='CooperativeWork' where name='daylog';
delimiter;

UPDATE ld_wx_config SET time_interval=10,limitnum=500 WHERE `name`='remind_time';
UPDATE ld_desk SET fieldlabel='1.	{$HelpDesk.HelpDesk}业绩=({$HelpDesk.productcategory}绩效基数*{$HelpDesk.ticketcategories}绩效权重*0.01 + {$Accounts.bill_city}绩效基数)*{$HelpDesk.servicetype}绩效权重*0.01*AVG({$ServiceReturn.resolutionrate})*AVG({$ServiceReturn.timelyrate})*AVG({$ServiceReturn.satisfaction})'
WHERE labelbol='Performance_scores_1' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='1.	Performance scores of {$HelpDesk.HelpDesk}=scores of ({$HelpDesk.productcategory} * {$HelpDesk.ticketcategories} * weight*0.01+ scores of {$Accounts.bill_city})*{$HelpDesk.servicetype}* weight*0.01*AVG({$ServiceReturn.resolutionrate})*AVG({$ServiceReturn.timelyrate})*AVG({$ServiceReturn.satisfaction})'
WHERE labelbol='Performance_scores_1' AND languagetype='en' AND Labeltype='fixedstr';
UPDATE ld_field SET uitype=154 WHERE tablename='ld_rate' AND columnname='strrole_id';
UPDATE ld_field SET quickcreate=0 WHERE tabid=13 AND columnname='description';
UPDATE ld_field SET quickcreate=0 WHERE tabid=37 AND columnname IN ('accountid','contactid','due_date','description','filename');
UPDATE ld_field SET quickcreate=1 WHERE tabid=37 AND columnname IN ('salesorderid','contract_type','contract_status','total_units');
-- 2017-12-28


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
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.1.6',current_version='V7.1.6',remark='V7.1.6-20171228',wx_version='V7.1.6';
delimiter;