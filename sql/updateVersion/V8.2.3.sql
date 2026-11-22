UPDATE ld_tranlabel SET fieldlabel=REPLACE(fieldlabel,'回款计划','收款计划') WHERE fieldlabel LIKE '%回款计划%';
UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,'回款计划','收款计划') WHERE fieldlabel LIKE '%回款计划%';
-- 2020-09-14

DELETE FROM ld_desk WHERE labelbol IN ('FREEUSE','WELCOMECARDQRCODE','TIPSCARDQRCODE');

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template LIKE '%yinshua_%';

SET @report_name='客户画像打分表';
SET @report_type='template_js';
SET @report_template='yinshua_huaxiangdafen.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT folder_id FROM ld_customreport_info WHERE report_template='yinshua_failedquotation.mrt');
SET @seq=(SELECT sequence FROM ld_customreport_info WHERE report_template='yinshua_failedquotation.mrt');

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq AND @id>0;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1) AND @id>0;

SET @i=0;
UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@id AND presence<>1 ORDER BY sequence;
delimiter;


SET @mytemplateid=(SELECT templateid FROM ld_templates WHERE templatename='费用报销桌面' LIMIT 1);
DELETE FROM ld_templates WHERE templateid=@mytemplateid 
	AND NOT EXISTS (SELECT 1 FROM ld_templatesrole WHERE templateid=@mytemplateid);

DELETE FROM ld_templates WHERE templateid=@mytemplateid 
	AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>7);
    
insert into ld_ws_fieldtype(uitype,fieldtype)
select '74','reference' from dual
where not exists(select * from ld_ws_fieldtype where uitype='74' and fieldtype = 'reference');
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=74;
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'Contacts' from dual
where not exists(select * from ld_ws_referencetype where type='Contacts' and fieldtypeid=@fieldtypeid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','downloadAttachmentSuccess','附件下载成功！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'downloadAttachmentSuccess' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','downloadAttachmentSuccess','attached downloaded successfully！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'downloadAttachmentSuccess' and labeltype = 'fixedstr');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','downloadAttachmentFail','附件下载失败！原因：您没有该单据的','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'downloadAttachmentFail' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','downloadAttachmentFail','attachment download failed! Reason: You do not have the right to download this document!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'downloadAttachmentFail' and labeltype = 'fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `insert_profileallpermission`;
delimiter ||
CREATE  PROCEDURE `insert_profileallpermission`(
    tmp_operationid INT(19)
)
BEGIN


    DECLARE tmp_tabid INT(19) DEFAULT 0;
    DECLARE MYCUSOR CURSOR FOR SELECT tabid FROM ld_profileallpermission WHERE operation = 1 GROUP BY tabid;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

    OPEN MYCUSOR;
    Fetch MYCUSOR INTO tmp_tabid;
    WHILE(tmp_tabid IS NOT NULL) DO
            SET @i=(SELECT MAX(sequence) FROM ld_profileallpermission WHERE tabid=tmp_tabid);
            SET @mysql=CONCAT("INSERT INTO ld_profileallpermission(tabid,operation,sequence) SELECT ",
                              tmp_tabid,",",tmp_operationid,",",IFNULL(@i,0)+1," FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=",tmp_tabid," AND operation=",tmp_operationid,")");

            PREPARE mystmt FROM @mysql;
            EXECUTE mystmt;
            DEALLOCATE PREPARE mystmt;

            FETCH MYCUSOR INTO tmp_tabid;
        END WHILE;
    CLOSE MYCUSOR;


END ||
delimiter;

SET @actionid = (SELECT MAX(actionid) FROM ld_actionmapping)+1;
INSERT INTO ld_actionmapping (actionid,actionname,securitycheck,actionlabel)
SELECT @actionid,'DownloadSelected',0,'DOWNLOADSELECTED' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname = 'DownloadSelected');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','DOWNLOADSELECTED','下载全部附件','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='DOWNLOADSELECTED' AND Labeltype='fixedstr' AND languagetype='zh');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','DOWNLOADSELECTED','Download all attachments','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='DOWNLOADSELECTED' AND Labeltype='fixedstr' AND languagetype='en');
delimiter;

SET @myactionid=(SELECT actionid FROM ld_actionmapping WHERE actionname='DownloadSelected' LIMIT 1);
CALL insert_profileallpermission(@myactionid);
DROP PROCEDURE IF EXISTS `insert_profileallpermission`;
delimiter;

update ld_field set bigtype='multipicklist' where uitype=33;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','clickviewalltotal','点击查看全部合计','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='clickviewalltotal' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','clickviewalltotal','Click to view all total','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='clickviewalltotal' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_cloud_users`
(
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
		`crm_company_id` INT(11) NOT NULL DEFAULT '0',
		`crm_user_id` INT(11) NOT NULL DEFAULT '0',
		`cloud_id` INT(11) NOT NULL DEFAULT '0',
		`nickname` VARCHAR(20),
		`avatar` VARCHAR(255),
		`tel` char(11),
		`open_id` VARCHAR(255) NOT NULL,
		`sex` TINYINT(1),
		`create_time` datetime DEFAULT NULL,
		`update_time` datetime DEFAULT NULL,
		PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_cloud_book`
(
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
		`tel` char(11),
		`cloud_id` int(11) NOT NULL,
		`create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
delimiter;

UPDATE ld_producttoolfield SET defaultvalue='13.000' WHERE columnname='tax2' 
	AND NOT EXISTS (SELECT 1 FROM ld_salesorder UNION SELECT 1 FROM ld_servicecontracts) AND defaultvalue='16.000';
    
UPDATE ld_field SET searchfieldtype=1 WHERE columnname='sign_location_address';
UPDATE ld_field SET presence=1 WHERE tablename<>'ld_contactrecords' AND columnname='sign_location_address';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','profilenamenonull','权限名称不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'profilenamenonull' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','profilenamenonull','Profile name cannot be empty','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'profilenamenonull' and labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CARDQRCODE','名片小程序','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CARDQRCODE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CARDQRCODE','card applet','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CARDQRCODE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CARDQRCODE','名片小程序','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CARDQRCODE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CARDQRCODE','card applet','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CARDQRCODE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FREEUSE','申请免费使用（包含灵当产品推广链接）','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='FREEUSE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FREEUSE','Rock it','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='FREEUSE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WELCOMECARDQRCODE','欢迎使用灵当电子名片小程序，一招实现裂变营销，低成本获客','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WELCOMECARDQRCODE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WELCOMECARDQRCODE','Welcome to Lingdang Digital Business Card which brings you Fission Marketing','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WELCOMECARDQRCODE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TIPSCARDQRCODE','您可以联系销售付费购买，或点击下方按钮开启免费使用（包含灵当产品推广链接）','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TIPSCARDQRCODE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TIPSCARDQRCODE','Please contact us to move advertisement, or click the button below and get a free trial','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TIPSCARDQRCODE' and Labeltype='jspop' and languagetype='en');
delimiter;

update ld_desk set fieldlabel="申请免费使用（包含灵当产品推广链接）" where labelbol='FREEUSE' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel="欢迎使用灵当电子名片小程序，一招实现裂变营销，低成本获客" where labelbol='WELCOMECARDQRCODE' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel="您可以联系销售付费购买，或点击下方按钮开启免费使用（包含灵当产品推广链接）" where labelbol='TIPSCARDQRCODE' and Labeltype='jspop' and languagetype='zh';
-- 2020-09-18


update ld_desk set fieldlabel="支持右键保存图片" where labelbol='SELFSERVICEQRCODEEXPLAIN' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel="Right click to save pictures" where labelbol='SELFSERVICEQRCODEEXPLAIN' and Labeltype='jspop' and languagetype='en';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOCUIDNOTICE','系统设置->小程序设置->企业号设置未设置，生成灵当默认电子名片。设置企业号后，生成自有电子名片。','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NOCUIDNOTICE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOCUIDNOTICE','System settings -> applet settings -> enterprise number settings are not set. The default business card is generated. After the enterprise number is set, the self owned electronic business card is generated.','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NOCUIDNOTICE' and Labeltype='jspop' and languagetype='en');
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

UPDATE ld_version SET old_version='V8.2.3',current_version='V8.2.3',remark='V8.2.3-20200918',wx_version='V8.2.3';
delimiter;