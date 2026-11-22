insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','SetTriggerFieldConditionJS','设置触发字段条件','jspop' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='SetTriggerFieldConditionJS' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SetTriggerFieldConditionJS','Setting trigger field condition','jspop' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='SetTriggerFieldConditionJS' and labeltype='jspop');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','SettingOtherConditionJS','设置其他条件','jspop' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='SettingOtherConditionJS' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SettingOtherConditionJS','Setting other conditions','jspop' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='SettingOtherConditionJS' and labeltype='jspop');


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','SetTriggerOperationJS','设置触发操作','jspop' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='SetTriggerOperationJS' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SetTriggerOperationJS','Setting trigger operation','jspop' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='SetTriggerOperationJS' and labeltype='jspop');
-- 2019-08-23

ALTER TABLE ld_salesorder ALTER COLUMN currency_id SET DEFAULT 1;
ALTER TABLE ld_salesorder ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_salesorder ALTER COLUMN currency_symbol SET DEFAULT '¥';

ALTER TABLE ld_servicecontracts ALTER COLUMN currency_id SET DEFAULT 1;
ALTER TABLE ld_servicecontracts ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_servicecontracts ALTER COLUMN currency_symbol SET DEFAULT '¥';

UPDATE ld_salesorder SET currency_id=1,conversion_rate=1.000000,currency_symbol='¥' WHERE conversion_rate IS NULL;
UPDATE ld_servicecontracts SET currency_id=1,conversion_rate=1.000000,currency_symbol='¥' WHERE conversion_rate IS NULL;

DROP PROCEDURE IF EXISTS `ldcrm_reset_order_yishou`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_order_yishou`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR 
							SELECT 
								a.cashbillid
							FROM ld_cashbill a
							LEFT JOIN ld_cashbill2paymentplan b ON b.CashBillID=a.cashbillid
							INNER JOIN ld_servicecontracts c ON c.servicecontractsid=b.entitytypeid
							WHERE 1=1
								AND b.entitytypeid>0
								AND c.total>0
								AND IFNULL(c.received_amount,0)=0
							GROUP BY 	b.entitytypeid
							UNION ALL
							SELECT 
								a.cashbillid
							FROM ld_cashbill a
							LEFT JOIN ld_cashbill2paymentplan b ON b.CashBillID=a.cashbillid
							INNER JOIN ld_salesorder c ON c.salesorderid=b.entitytypeid
							WHERE 1=1
								AND b.entitytypeid>0
								AND c.total>0
								AND IFNULL(c.received_amount,0)=0
							GROUP BY 	b.entitytypeid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;


	UPDATE ld_salesorder SET conversion_rate=1 WHERE conversion_rate IS NULL;
	UPDATE ld_servicecontracts SET conversion_rate=1 WHERE conversion_rate IS NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		CALL update_sales_total(tmp_id);
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_reset_order_yishou();
DROP PROCEDURE IF EXISTS `ldcrm_reset_order_yishou`;

select sequence into @sequence from ld_systems_deploy where deploy_type=200;
update ld_systems_deploy set sequence=sequence+1 where roottype=8 and sequence>@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
  select 1,204,'移动端新建单据时，将审批流程定制中用户可见的唯一审批工作流设置为默认值',@sequence+1,8,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
  from dual where not exists(select 1 from ld_systems_deploy  where deploy_type=204);
set @i=@sequence;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=8 and sequence>@sequence order by sequence asc;

select deploy_type into @relateid from ld_systems_deploy where deploy_type=204;
insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_systems_deploy',@relateid,@relateid,'移动端新建单据时，将审批流程定制中用户可见的唯一审批工作流设置为默认值' from DUAL
  where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='zh');

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_systems_deploy',@relateid,@relateid,
    'When building new bill of document at the mobile terminal,the only approval workfiow user can see in the customization of approval process will be set to default'
  from DUAL
  where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='en');
delimiter;




update ld_field set fieldonly=0 where bigtype='relatedmodulefield' and allowedit='no';
delimiter;
update ld_systems_deploy set presence=1 where deploy_type=139;
delimiter;


CREATE TABLE if not exists `ld_relatecreatecondition` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `modulename` varchar(100) DEFAULT NULL,
  `columnname` varchar(255) DEFAULT NULL,
  `comparator` varchar(255) DEFAULT NULL,
  `content` varchar(255) DEFAULT NULL,
  `relatecreatemodule` varchar(100) DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid  from ld_tab where name='quotes';
update ld_field set uitype=202,bigtype='selectsource',datarang='all',maxrowsshow=20 where uitype=204 and tabid=@tabid;

update ld_field set columnname='source_list' ,fieldname='selectlistval',tablename='ld_quotes' where uitype=202 and tabid=@tabid;
select tabid into @option_tabid from ld_tab where name='PurchaseInquiryOrder';

insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,1,'all',20 from dual 
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

call AddColumn('ld_quotes','entitytype','varchar',50,'');
delimiter;
call AddColumn('ld_quotes','source_list','varchar','500','');
delimiter;

update ld_quotes INNER JOIN ld_quotesdetail
on ld_quotes.quoteid=ld_quotesdetail.id 
INNER JOIN ld_crmentity on ld_crmentity.crmid=ld_quotesdetail.entitytypeid
set ld_quotes.entitytype=ld_crmentity.setype;
delimiter;

update ld_quotes INNER JOIN(
select GROUP_CONCAT(entitytypeid) as entitytypeids ,id from ld_quotesdetail GROUP BY id 
) as tmp1 on tmp1.id=ld_quotes.quoteid
set ld_quotes.source_list=tmp1.entitytypeids;
delimiter;
-- 2019-08-26

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

UPDATE ld_version SET old_version='V7.8.5',current_version='V7.8.5',remark='V7.8.5-20190826',wx_version='V7.8.5';
delimiter;