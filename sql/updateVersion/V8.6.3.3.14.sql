insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DINGDINGINTERFACEDELETETIP','注销后，钉钉CRM应用将无法使用，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'DINGDINGINTERFACEDELETETIP' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DINGDINGINTERFACEDELETETIP','After cancellation, the DingTalk CRM application will no longer be available. Do you want to continue? ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'DINGDINGINTERFACEDELETETIP' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXCELHEADER','Excel表头','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXCELHEADER' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXCELHEADER',"Excel Header",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXCELHEADER' and labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_token_log` (
	`id`  int(19) NOT NULL AUTO_INCREMENT ,
	`username`  varchar(50) NULL COMMENT 'username' ,
	`token`  varchar(50) NULL COMMENT 'token' ,
	`tokenkey`  varchar(100) COMMENT '生成token参数nonce' ,
	`count`  int(4)  DEFAULT 0 COMMENT  '数量' ,
	`createtime`  datetime DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`)
) ENGINE = INNODB ;
delimiter;

call addtableIndex('ld_token_log','token','token');
delimiter;

SET @labelbol = 'COORDINATECONVERSIONFAILED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'坐标转换失败','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Coordinate conversion failed','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2024-11-25

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

UPDATE ld_version SET old_version='V8.6.3.3.14',current_version='V8.6.3.3.14',remark='V8.6.3.3.14-20241125',wx_version='V8.6.5.0';
delimiter;