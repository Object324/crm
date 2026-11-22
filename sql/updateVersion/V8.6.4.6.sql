DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF IFNULL(tmp_defaultvalue,'')='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
	END IF;

end ||
delimiter;


select tabid into @tabid from ld_tab where name='Questionnaire';
select actionid  into @actionid1 from ld_actionmapping where actionname='COPY';
select MAX(sequence) into @sequence from ld_profileallpermission where tabid=@tabid;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@actionid1,@sequence+1 FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation =@actionid1 );
delimiter;
-- 2024-09-26

SET @labelbol = 'usercheckacountmsg';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已达用户上限，保存后将自动把用户设置为离职，是否继续？',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The user limit has been reached. After saving, the user will be automatically set as resigned. Do you want to continue?',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

set @max_fieldid = (SELECT max(fieldid) from ld_settings_field);
set @blockid = (SELECT blockid from ld_settings_field where `name` = 'LBL_EXPRESS100_SETTINGS');
set @sequence = (SELECT sequence from ld_settings_field where `name` = 'LBL_EXPRESS100_SETTINGS');
INSERT INTO ld_settings_field(fieldid, blockid, `name`,description,linkto,sequence)
SELECT @max_fieldid+1, @blockid, 'LBL_PIAOZONE_SETTINGS','发票识别验真接口设置','index.php?module=Settings&action=PiaozoneSetting&parenttab=Settings',@sequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_settings_field WHERE name = 'LBL_PIAOZONE_SETTINGS');
UPDATE ld_settings_field_seq SET id=(SELECT MAX(fieldid) FROM ld_settings_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_PIAOZONE_SETTINGS','发票识别验真接口设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LBL_PIAOZONE_SETTINGS' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_PIAOZONE_SETTINGS','Invoice identification and verification interface Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LBL_PIAOZONE_SETTINGS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PiaozoneSettingListTile','发票识别验真接口','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PiaozoneSettingListTile' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PiaozoneSettingListTile','Invoice identification and verification interface','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PiaozoneSettingListTile' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PiaozoneMethod','发票识别验真方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PiaozoneMethod' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PiaozoneMethod','Invoice identification and verification method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PiaozoneMethod' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UsePurchaseFlagshipInvoice','使用自购发票云旗舰版接口','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'UsePurchaseFlagshipInvoice' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UsePurchaseFlagshipInvoice','Use the Purchase invoice cloud flagship interface','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'UsePurchaseFlagshipInvoice' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceLoginAddress','发票云登录地址','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'InvoiceLoginAddress' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceLoginAddress','Invoice cloud login address','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'InvoiceLoginAddress' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LoginAccount','登录账号','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LoginAccount' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LoginAccount','login account','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LoginAccount' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TenantId','租户Id','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'TenantId' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TenantId','tenant Id','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'TenantId' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OrganizationCode','组织编码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'OrganizationCode' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OrganizationCode','organization code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'OrganizationCode' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ClearPiaozoneSettingTip','注销后，费用报销单导入发票功能将无法使用，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ClearPiaozoneSettingTip' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ClearPiaozoneSettingTip','After sign out, the function of importing expense reimbursement forms into invoices will not be available.  Do you want to continue?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ClearPiaozoneSettingTip' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceHeader','发票抬头','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'InvoiceHeader' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceHeader','Invoice header','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'InvoiceHeader' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseAddInvoiceHeaderDetail','请录入发票抬头明细信息','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'PleaseAddInvoiceHeaderDetail' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseAddInvoiceHeaderDetail','Please enter the invoice header details information','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'PleaseAddInvoiceHeaderDetail' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CompanyTaxID','公司税号','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CompanyTaxID' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CompanyTaxID','company tax ID','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CompanyTaxID' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddInvoiceHeader','新增发票抬头','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AddInvoiceHeader' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddInvoiceHeader','Add invoice header','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AddInvoiceHeader' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_loginsettingsinfo` (
  `id` mediumint(9) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `labelzh` varchar(100) DEFAULT NULL,
  `labelen` varchar(100) DEFAULT NULL,
  `isshow` varchar(10) DEFAULT NULL,
  `isedit` varchar(10) DEFAULT NULL,
  `content` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
	`swipertype` varchar(50) DEFAULT NULL,
  `sequence` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;


DROP PROCEDURE IF EXISTS `insertloginswiperdefault`;
delimiter ||
CREATE PROCEDURE `insertloginswiperdefault`(
)
BEGIN
		declare loginnum int default 0;
		set loginnum = (select count(login_id) from ld_loginhistory);
    IF NOT EXISTS (select 1 from ld_loginsettingsinfo where `name` = 'loginswiper' and type = 'default') THEN
				INSERT INTO `ld_loginsettingsinfo` (`name`, `labelzh`, `labelen`, `isedit`, `content`) VALUES ('swiperratio', '轮播图比例', 'Rotation chart ratio', 'yes', '1:2');
				INSERT INTO `ld_loginsettingsinfo` (`name`, `isshow`, `isedit`, `content`, `url`, `type`, `swipertype`, `sequence`) VALUES ('loginswiper', 'yes', 'yes', 'defaultloginswiper1.png', 'https://www.51mis.com/', 'default', '1:2', '2');
				INSERT INTO `ld_loginsettingsinfo` (`name`, `isshow`, `isedit`, `content`, `url`, `type`, `swipertype`, `sequence`) VALUES ('loginswiper', 'yes', 'yes', 'defaultloginswiper2.png', 'https://www.51mis.com/', 'default', '1:2', '3');
				INSERT INTO `ld_loginsettingsinfo` (`name`, `isshow`, `isedit`, `content`, `url`, `type`, `swipertype`, `sequence`) VALUES ('loginswiper', 'yes', 'yes', 'defaultloginswiper3.png', 'https://www.51mis.com/', 'default', '1:2', '1');
				INSERT INTO `ld_loginsettingsinfo` (`name`, `isshow`, `isedit`, `content`, `url`, `type`, `swipertype`, `sequence`) VALUES ('loginswiper', 'yes', 'yes', 'defaultloginswiper1.png', 'https://www.51mis.com/', 'default', '2:1', '2');
				INSERT INTO `ld_loginsettingsinfo` (`name`, `isshow`, `isedit`, `content`, `url`, `type`, `swipertype`, `sequence`) VALUES ('loginswiper', 'yes', 'yes', 'defaultloginswiper2.png', 'https://www.51mis.com/', 'default', '2:1', '3');
				INSERT INTO `ld_loginsettingsinfo` (`name`, `isshow`, `isedit`, `content`, `url`, `type`, `swipertype`, `sequence`) VALUES ('loginswiper', 'yes', 'yes', 'defaultloginswiper3.png', 'https://www.51mis.com/', 'default', '2:1', '1');

				IF loginnum > 1 THEN
						INSERT INTO `ld_module_setting_byuser` (`modulename`, `userid`, `label`, `type`, `content`) VALUES ('Settings', '1', 'historyloginui', NULL, 'old');
				ELSE
						INSERT INTO `ld_module_setting_byuser` (`modulename`, `userid`, `label`, `type`, `content`) VALUES ('Settings', '1', 'historyloginui', NULL, 'new');
				END IF;

    END IF;

end ||
delimiter;

CALL insertloginswiperdefault();
DROP PROCEDURE IF EXISTS `insertloginswiperdefault`;
delimiter;

SET @labelbol = 'SETLOGINSWIPERRATIO';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置登录界面显示样式',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Set login interface display style',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'updateloginswiperfirst';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'仅新版登录界面才可使用轮播图设置。确定后，将使用新版登录界面，且不可恢复，是否继续？',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Only the new login interface can use the carousel settings.After confirmation, the new login interface will be used and cannot be restored. Do you want to continue?',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'updateloginsavefirst';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定后，将使用新版登录界面，且不可恢复，是否继续？',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After confirmation, the new login interface will be used and cannot be restored. Do you want to continue?',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'shownewloginui';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点击查看新版登录效果',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click to see the new login effect',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'restdefaultswiper';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确认要恢复预设轮播图吗?',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure you want to restore the preset carousel?',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'swipersmallproportion';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'轮播占小比例',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Rotating broadcasting accounts for a small proportion',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'swiperbigproportion';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'轮播占大比例',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Rotating broadcasting accounts for a big proportion',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'swipersuggestsmall';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'建议尺寸：1380*2400(像素)，图片名称禁用汉字及中文特殊字符',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Suggested size: 1380 * 2400 pixels, Chinese characters and special text characters are prohibited for image names',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'swipersuggestbig';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'建议尺寸：2000*1600(像素)，图片名称禁用汉字及中文特殊字符',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Suggested size: 2000*1600 pixels, Chinese characters and special text characters are prohibited for image names',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

ALTER TABLE ld_report_analysis2user MODIFY COLUMN userid text;
delimiter;

UPDATE ld_desk set fieldlabel='该工商信息暂未收录，您可以几分钟后再尝试！' WHERE labelbol='thecustomerbusiness' and languagetype='zh' and labeltype='jspop';
UPDATE ld_desk set fieldlabel='该工商信息暂未收录，您可以几分钟后再尝试！' WHERE labelbol='thecustomerbusiness' and languagetype='zh' and labeltype='fixedstr';
delimiter;

SET @labelbol = 'ld_popup_button_ui_setting';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'弹窗按钮布局样式',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Pop up button layout style',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'allpopupbottontypelabel';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'所有模块的弹窗按钮布局，均按照所设置布局',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The layout of pop-up buttons for all modules follows the set layout',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'popupbuttonright';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按钮居右',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Button on the right',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'popupbuttoncenter';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按钮居中',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Button centered',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

set @deploy_type = 488;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 2,@deploy_type,'弹窗按钮布局样式','',0,'','text',0,'' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@deploy_type);
delimiter;

set @tabid = (select tabid from ld_tab where `name` = 'Users');
update ld_field set disallowed_copy = 'yes' where tabid = @tabid and fieldname in ('user_name','user_password','confirm_password');
delimiter;
-- 2024-10-08

set @deploy_type = 488;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 2,@deploy_type,'弹窗按钮布局样式','',0,'','text',0,'' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@deploy_type);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_module_setting_static` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `modulename` varchar(50) DEFAULT NULL ,
    `action` varchar(50) DEFAULT NULL ,
    `pagetype` varchar(30) DEFAULT NULL ,
    `content` Text DEFAULT NULL ,
    `createdtime` timestamp DEFAULT CURRENT_TIMESTAMP,
    `modifiedtime` timestamp ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

SET @labelbol = 'NotAllowSave';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不允许保存',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Not allow',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'PRODUCTSDUPLICATEDCONTINUE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'以下产品重复,是否继续保存？',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The following products are duplicated. Do you want to continue saving them?',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'PRODUCTSDUPLICATEDNOTSAVE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'以下产品重复,不允许保存',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The following products are duplicated and cannot be saved',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

update ld_desk set fieldlabel='网页端显示公海客户模块' where labelbol='DISPLAYSEACUSTOMER' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Web display of open sea customer module' where labelbol='DISPLAYSEACUSTOMER' and labeltype='fixedstr' and languagetype='en';
delimiter;

set @tabid = (select tabid from ld_tab where name = 'PricePolicy');
set @import_actionid = (select actionid from ld_actionmapping where actionname = 'Import');
set @export_actionid = (select actionid from ld_actionmapping where actionname = 'Export');
delete from ld_profileallpermission where tabid = @tabid and (operation = @import_actionid or operation = @export_actionid);
delete from ld_profile2standardpermissions where tabid = @tabid and (operation = @import_actionid or operation = @export_actionid);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PricePolicy');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename='ld_pricepolicy';
SET @columnname='smcreatorid';
SET @fieldname='creator';
SET @zh='创建人';
SET @en='Creator';
SET @uitype=52;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='users';
SET @datarang='all';
SET @maxrowsshow=5;
SET @presence=2;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,
                     maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,
                     info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,
       100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,
       'BAS',0,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

SET @labelbol = 'recoveryendremarksnoempty';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'结束语不能为空！',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The conclusion cannot be empty !',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_update_superposition_list`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_superposition_list`()
BEGIN

    DECLARE tmp_pricepolicyid INT(11) DEFAULT 0;
    DECLARE tmp_superposition_list TEXT DEFAULT '';

    DECLARE MYCUSOR CURSOR FOR SELECT pricepolicyid,superposition_list FROM ld_pricepolicy;

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_pricepolicyid = NULL;

    SET @disable_triggers = 1;

    OPEN MYCUSOR;
    FETCH MYCUSOR INTO tmp_pricepolicyid,tmp_superposition_list;
    WHILE(tmp_pricepolicyid IS NOT NULL) DO

            UPDATE ld_pricepolicy SET superposition_list = IF(superposition_list = '' OR superposition_list IS NULL,tmp_pricepolicyid,CONCAT(superposition_list,',',tmp_pricepolicyid))
            WHERE FIND_IN_SET(pricepolicyid,tmp_superposition_list) AND !FIND_IN_SET(tmp_pricepolicyid,superposition_list);

            FETCH MYCUSOR INTO tmp_pricepolicyid,tmp_superposition_list;
        END WHILE;
    CLOSE MYCUSOR;
    SET @disable_triggers = NULL;
END ||
delimiter;

CALL ldcrm_update_superposition_list();
delimiter;

DELETE from ld_leads_set_rule where (tabname = '' or tabname = 'null' or tabname = 'undefined');
DELETE from ld_account_set_rule where (tabname = '' or tabname = 'null' or tabname = 'undefined');
DELETE from ld_account_set_rule_normal where (tabname = '' or tabname = 'null' or tabname = 'undefined');
delimiter;

SET @labelbol = 'SuchAs';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'示例 : ',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'For Example : ',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

CALL AddColumn('ld_field', 'value_format', 'varchar', 20, '');
delimiter;
-- 2024-10-11

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ButtonName','按钮名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ButtonName' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ButtonName','Button Name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ButtonName' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ButtonPosition','按钮位置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ButtonPosition' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ButtonPosition','Button Position','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ButtonPosition' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ButtonPermissions','按钮权限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ButtonPermissions' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ButtonPermissions','Button permissions','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ButtonPermissions' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EmptyMeansEveryoneCanOperate','如果为空表示所有人可操作','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EmptyMeansEveryoneCanOperate' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EmptyMeansEveryoneCanOperate','Empty means everyone can operate it','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EmptyMeansEveryoneCanOperate' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WebPageDetails','网页端查看详情页','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WebPageDetails' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WebPageDetails','Web page Details','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WebPageDetails' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ListOperationColumn','网页端列表操作列','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ListOperationColumn' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ListOperationColumn','List operation column','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ListOperationColumn' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AppPageDetails','移动端查看详情页','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AppPageDetails' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AppPageDetails','App page Details','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AppPageDetails' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DisplayConditions','显示条件','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayConditions' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DisplayConditions','Display conditions','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayConditions' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DisplayWhenMet','满足条件时显示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayWhenMet' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DisplayWhenMet','Display when it matches','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayWhenMet' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DisplayWhenNotMet','不满足条件时显示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayWhenNotMet' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DisplayWhenNotMet','Display when not matches','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayWhenNotMet' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUCCESSFULOPERATION','操作成功','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SUCCESSFULOPERATION' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUCCESSFULOPERATION','Successful operation','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SUCCESSFULOPERATION' and labeltype='fixedstr' and languagetype='en');
delimiter;

SET @labelbol = 'ButtonsCustomization';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'操作按钮定制',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Buttons customization',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);

DROP PROCEDURE IF EXISTS `InsertButtonsCustomization`;
delimiter ||
CREATE PROCEDURE InsertButtonsCustomization()
BEGIN

    SELECT blockid INTO @blockid FROM ld_settings_blocks WHERE label = 'PROCESS_TEMPLATE_CUSTOMIZATION';
    SET @labelbol = 'ButtonsCustomization';
	
	IF NOT EXISTS (SELECT 1 FROM ld_settings_field WHERE blockid = @blockid AND `name` = @labelbol) THEN
		
        SELECT MAX(fieldid) + 1 INTO @fieldid FROM ld_settings_field;
        SET @link = 'index.php?module=Users&action=ButtonsCustomization&parenttab=Settings&mode=list';
        SELECT (sequence) + 1 INTO @sequence FROM ld_settings_field WHERE blockid = @blockid AND `name` = 'LBL_WORKFLOWCUSTOMIZATION_SET';
    
        UPDATE ld_settings_field SET sequence = sequence + 1 WHERE blockid = @blockid AND sequence >= @sequence;
        INSERT INTO ld_settings_field(`fieldid`,`blockid`,`name`,`iconpath`,`description`,`linkto`,`sequence`, `active`)
        SELECT @fieldid, @blockid, @labelbol, '', '操作按钮定制', @link, @sequence, 0 FROM DUAL;
        
        UPDATE ld_settings_field_seq SET id = (SELECT MAX(fieldid) FROM ld_settings_field);
	END IF;
	
END ||
delimiter;

CALL InsertButtonsCustomization();
DROP PROCEDURE IF EXISTS `InsertButtonsCustomization`;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_buttonscustomization` (
    `btnid` INT(5) NOT NULL AUTO_INCREMENT COMMENT '主键，自增',
    `btnkey` VARCHAR(50) COMMENT '按钮key',
		`module` VARCHAR(50) COMMENT '所属模块',
    `is_active` VARCHAR(10) COMMENT '是否启用',
		`label_zh` VARCHAR(100) COMMENT '中文名称',
		`label_en` VARCHAR(100) COMMENT '英文名称',
		`deleted` INT(1) COMMENT '是否被删除',
		`is_showlist` VARCHAR(10) COMMENT '是否显示在后台设置的列表上',
		`btnposition` VARCHAR(200) COMMENT '按钮位置',
		`profileid` TEXT COMMENT '角色id字符串',
		`userid` TEXT COMMENT '成员id字符串',
    `userfieldid` TEXT COMMENT '用户字段id字符串',
		`type` VARCHAR(30) COMMENT '按钮的作用类型：例如工作流',
    `related_id` INT(11) COMMENT '关联id',
    `effectivemethod` VARCHAR(30) COMMENT '满足条件时显示/不满足条件时显示',
		`description` TEXT COMMENT '备注',
		`advft_criteria` TEXT COMMENT '高级条件',
		`advft_criteria_groups` TEXT COMMENT '高级条件组间关系',
		`modifiedtime` DATETIME COMMENT '更新时间',
    PRIMARY KEY (`btnid`)
) ENGINE = INNODB ;
delimiter;
-- 2024-10-14

CREATE TABLE IF NOT EXISTS `ld_buttonscustomization` (
    `btnid` INT(5) NOT NULL AUTO_INCREMENT COMMENT '主键，自增',
    `btnkey` VARCHAR(50) COMMENT '按钮key',
    `module` VARCHAR(50) COMMENT '所属模块',
    `is_active` VARCHAR(10) COMMENT '是否启用',
    `label_zh` VARCHAR(100) COMMENT '中文名称',
    `label_en` VARCHAR(100) COMMENT '英文名称',
    `deleted` INT(1) COMMENT '是否被删除',
    `is_showlist` VARCHAR(10) COMMENT '是否显示在后台设置的列表上',
    `btnposition` VARCHAR(200) COMMENT '按钮位置',
    `profileid` TEXT COMMENT '角色id字符串',
    `userid` TEXT COMMENT '成员id字符串',
    `userfieldid` TEXT COMMENT '用户字段id字符串',
    `type` VARCHAR(30) COMMENT '按钮的作用类型：例如工作流',
    `related_id` INT(11) COMMENT '关联id',
    `effectivemethod` VARCHAR(30) COMMENT '满足条件时显示/不满足条件时显示',
    `description` TEXT COMMENT '备注',
    `advft_criteria` TEXT COMMENT '高级条件',
    `advft_criteria_groups` TEXT COMMENT '高级条件组间关系',
    `modifiedtime` DATETIME COMMENT '更新时间',
    PRIMARY KEY (`btnid`)
) ENGINE = INNODB;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Sender2','发送人','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Sender2' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Sender2','Sender','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Sender2' and labeltype='fixedstr' and languagetype='en');
delimiter;



SET @labelbol = 'ADDTOCART';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'加入购物车',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Add to cart',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;


SET @labelbol = 'ORDERIMMEDIATELY';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'立即下单',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Place an order immediately',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;
SET @labelbol = 'Price';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'价格',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Price',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'properties_explanation';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'说明:不需要的属性组合取消勾选即可',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Explanation: Unnecessary attribute combinations can be unchecked',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;


SET @labelbol = 'selectproperties';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选择属性组合',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Select attribute combination',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;


SET @labelbol = 'generate';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'生成',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Generate',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'Choosetogenerate';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选择生成',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Choose to generate',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'More_Currency';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'更多币种',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'More Currency',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'Product_Property';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'产品属性',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Product Property',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

select tabid into @producttabid from ld_tab where name='Products';

select parenttabid into @tmp_parenttabid from ld_parenttabrel where tabid=@producttabid and tab_tablename='ld_tab' LIMIT 1;

select max(sequence) into @sequence from ld_parenttabrel where parenttabid=@tmp_parenttabid;

set @tmp_modulename = 'ProductProperty';
set @tmp_zhmoudulename = '产品属性';
set @tmp_enmoudulename = 'Product Property';
SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,@tmp_modulename,0,@maxtseq+1,@tmp_modulename,1,'' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=@tmp_modulename);

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@tmp_modulename);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab',@tabid,@tabid,@tmp_zhmoudulename FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab',@tabid,@tabid,@tmp_enmoudulename FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');


SET @labseq=IFNULL((SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=@tmp_parenttabid),0);
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @tmp_parenttabid,@tabid,@labseq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@tmp_parenttabid AND tabid=@tabid);

SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
SELECT @maxnum_id+1,@tmp_modulename,getPY(@tmp_zhmoudulename),1,1,1,'none',0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=@tmp_modulename);
UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;

INSERT INTO ld_modtracker_tabs(tabid,visible)
SELECT @tabid,1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid)
  AND actionname IN ('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView');

INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
SELECT @tabid,@tmp_modulename,CONCAT('ld_',LOWER(@tmp_modulename)),CONCAT(LOWER(@tmp_modulename),'_no'),CONCAT(LOWER(@tmp_modulename),'id'),CONCAT(LOWER(@tmp_modulename),'id') FROM DUAl
WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename=@tmp_modulename);

SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(@tmp_modulename),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(@tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);

SELECT MAX(blockid) into @maxid FROM ld_blocks;
SELECT MAX(sequence) into @maxseq FROM ld_blocks WHERE tabid=@tabid;
SET @trantable='ld_blocks';
SET @blocklabel='LBI_ATTACHMENT_FILE';
SET @zh='附件信息';
SET @en='Attachments Information';

INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title)
SELECT @maxid+1,@tabid,@blocklabel,@maxseq+1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);

UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

SELECT blockid INTO @relateid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel LIMIT 1;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);


SET @maxseq=0;
SELECT MAX(fieldid) INTO @maxid FROM ld_field;
SELECT MAX(sequence) INTO @maxseq FROM ld_field WHERE tabid=@tabid AND block=@relateid;
SET @trantable='ld_field';
SET @tablename='ld_attachments';

SET @columnname='filename';
SET @fieldname='filename';
SET @zh='附件';
SET @en='Attachment';
SET @uitype=1109;

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,editpage)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,'fileattachment','listview' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

CALL getallprofile(@tmp_modulename);
CALL fieldprofile(@tmp_modulename);

SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(@tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'productproperty_name','no',CONCAT('ld_',LOWER(@tmp_modulename)),1,2,'productproperty_name','属性名称',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,0,0,'text',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='productproperty_name');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='productproperty_name');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'属性名称' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Property Name' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'team_memberid','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,154,'team_memberid','团队成员',1,1,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,'text',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'团队成员' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Team Members' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,CONCAT(LOWER(@tmp_modulename),'_no'),'no',CONCAT('ld_',LOWER(@tmp_modulename)),1,4,CONCAT(LOWER(@tmp_modulename),'_no'),'属性编号',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(@tmp_modulename),'_no'));

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(@tmp_modulename),'_no'));
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'属性编号' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Property NO.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );



select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,'description',CONCAT('ld_',LOWER(@tmp_modulename)),1,19,'textarea','description','描述',1,2,'',100,@seq+1,@blockid,1,'V~O',1,'','BAS',1,NULL,0,'no' from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=CONCAT('ld_',LOWER(@tmp_modulename)) and columnname='description');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='description');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'描述' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Description' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,'property_status',CONCAT('ld_',LOWER(@tmp_modulename)),1,56,'boolean','property_status','禁用',1,2,'no',100,@seq+1,@blockid,1,'C~O',1,'','BAS',1,NULL,0,'no' from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=CONCAT('ld_',LOWER(@tmp_modulename)) and columnname='property_status');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='property_status');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'禁用' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Disable' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,advance_demand,advance_demand_groups)
SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(@tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2,'null####[null,{"groupid":"1","columnname":"ld_users:status:status:Users_状态:V","comparator":"e","value":"Active","columncondition":""}]','All####[null,{"groupcondition":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,52,'smcreatorid','创建人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,52,'modifiedby','最新更新人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,70,'modifiedtime','更新时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,609,'approvestatus','审批状态',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,70,'approvetime','最新审批时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,131,'approveby','上一步审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,132,'currentapprover','当前审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'当前审批人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Current Approver' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,1,'print_times','打印次数',1,1,(@i:=@i+1),@blockid ,2,'N~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='print_times');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'打印次数' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Print Times' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'exchtime','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,86,'exchtime','最新同步时间',1,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,'datetime',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='exchtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='exchtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新同步时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'最新同步时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'exchmsg','yes',CONCAT('ld_',LOWER(@tmp_modulename)),1,19,'exchmsg','最新同步结果',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,'longtextarea',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='exchmsg');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='exchmsg');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新同步结果' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'最新同步结果' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'latestpushtime','yes',CONCAT('ld_',LOWER(@tmp_modulename)),2,86,'latestpushtime','最新推进时间',0,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,'datetime',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新推进时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Latest push time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

SET @detailtablename='ld_productpropertydetail';
SET @sourcemodule='ProductProperty';
SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @columnname = 'property_value_name';
SET @allowhide = 'no';
SET @fieldlabel = '属性值名称';
SET @fieldtype = 'Text';
SET @typeofdata='V~M';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @referencemodule = '';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,22,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='property_value_name' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='属性值名称';
SET @en='Property Value Name';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @columnname = 'property_value_no';
SET @allowhide = 'no';
SET @fieldlabel = '属性值编号';
SET @fieldtype = 'Num';
SET @typeofdata='N~M~25,0';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @referencemodule = '';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,22,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='property_value_no' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='属性值编号';
SET @en='Property Value NO.';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @columnname = 'description';
SET @allowhide = 'no';
SET @fieldlabel = '描述';
SET @fieldtype = 'TextArea';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @referencemodule = '';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,22,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='description' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='描述';
SET @en='Description';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @columnname = 'setdefault';
SET @allowhide = 'no';
SET @fieldlabel = '设为默认';
SET @fieldtype = 'CheckBox';
SET @typeofdata='V~O';
SET @bigtype='boolean';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @referencemodule = '';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,22,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='setdefault' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='设为默认';
SET @en='Set Default';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALL getallprofile(@tmp_modulename);
CALL fieldprofile(@tmp_modulename);

SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+1,'All',1,0,@tmp_modulename,3,1,1 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=@tmp_modulename and viewname='All');

select cvid into @maxcvid from ld_customview where viewname='All' and entitytype=@tmp_modulename;
INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
SELECT @tabid, 'ld_productproperty:productproperty_name:productproperty_name:ProductProperty_fieldlabel:V', '0', @maxcvid FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview where tabid=@tabid and cvid=@maxcvid and columns='ld_productproperty:productproperty_name:productproperty_name:ProductProperty_fieldlabel:V');

INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
SELECT @tabid, 'ld_productproperty:productproperty_no:productproperty_no:ProductProperty_fieldlabel:V', '1', @maxcvid FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview where tabid=@tabid and cvid=@maxcvid and columns='ld_productproperty:productproperty_no:productproperty_no:ProductProperty_fieldlabel:V');
INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
SELECT @tabid, 'ld_productproperty:smownerid:assigned_user_id:ProductProperty_fieldlabel:V', '2', @maxcvid FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview where tabid=@tabid and cvid=@maxcvid and columns='ld_productproperty:smownerid:assigned_user_id:ProductProperty_fieldlabel:V');
INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
SELECT @tabid, 'ld_productpropertydetail:property_value_name:property_value_name:ProductPropertyDetails_fieldlabel:V', '3', @maxcvid FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview where tabid=@tabid and cvid=@maxcvid and columns='ld_productpropertydetail:property_value_name:property_value_name:ProductPropertyDetails_fieldlabel:V');
INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
SELECT @tabid, 'ld_productpropertydetail:property_value_no:property_value_no:ProductPropertyDetails_fieldlabel:V', '4', @maxcvid FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview where tabid=@tabid and cvid=@maxcvid and columns='ld_productpropertydetail:property_value_no:property_value_no:ProductPropertyDetails_fieldlabel:V');
INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
SELECT @tabid, 'ld_productpropertydetail:description:description:ProductPropertyDetails_fieldlabel:V', '5', @maxcvid FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview where tabid=@tabid and cvid=@maxcvid and columns='ld_productpropertydetail:description:description:ProductPropertyDetails_fieldlabel:V');
INSERT INTO ld_tabwithproductview (`tabid`, `columns`, `sequence`, `cvid`)
SELECT @tabid, 'ld_productpropertydetail:setdefault:setdefault:ProductPropertyDetails_fieldlabel:V', '6', @maxcvid FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabwithproductview where tabid=@tabid and cvid=@maxcvid and columns='ld_productpropertydetail:setdefault:setdefault:ProductPropertyDetails_fieldlabel:V');


INSERT INTO ld_def_org_share(tabid,permission,editstatus)
SELECT @tabid,3,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);

CALL addtabintoprofile(@tmp_modulename,1);

SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 0,488,CONCAT(@tmp_zhmoudulename,'是否启用审批流程'),@tmp_modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=488);

SET @approvename=CONCAT(@tmp_zhmoudulename,'审批流程');
SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
SELECT @approveid+1,@tabid,CONCAT(@tmp_zhmoudulename,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;


UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

CREATE TABLE IF NOT EXISTS `ld_productproperty` (
    `productpropertyid` INT(19) NOT NULL DEFAULT '0',
    `productproperty_no` VARCHAR(255) DEFAULT NULL,
    `productproperty_name` VARCHAR(255) DEFAULT NULL,
    `description` TEXT DEFAULT '',
    `property_status` TINYINT(2) DEFAULT 0,
    `smownerid` INT(19) DEFAULT NULL,
    `smcreatorid` INT(19) DEFAULT NULL,
    `createdtime` DATETIME DEFAULT NULL,
    `modifiedby` INT(19) DEFAULT NULL,
    `modifiedtime` DATETIME DEFAULT NULL,
    `approvestatus` VARCHAR(50) DEFAULT '未提交',
    `approvetime` DATETIME DEFAULT NULL,
    `approveby` INT(19) DEFAULT NULL,
    `currentapprover` TEXT DEFAULT NULL,
    `print_times` INT(11) DEFAULT '0',
    `deleted` INT(19) NOT NULL DEFAULT '0',
    PRIMARY KEY (`productpropertyid`)
) ENGINE=InnoDB;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_productpropertydetail` (
    `lineitem_id` INT(19) NOT NULL AUTO_INCREMENT,
    `id` INT(19) DEFAULT 0,
    `sequence` INT(4) DEFAULT 0,
    `property_value_name` varchar(100) DEFAULT NULL,
    `property_value_no` INT(19) DEFAULT 0,
    `setdefault` TINYINT(2) DEFAULT 0,
    `description` TEXT DEFAULT NULL,
    PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_productpropertyscf` (
    `productpropertyid` INT(19) NOT NULL DEFAULT '0',
    PRIMARY KEY (`productpropertyid`)
) ENGINE=InnoDB;
delimiter;

select tabid into @tabid from ld_tab where name='Products';
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel='LBL_PRODUCT_INFORMATION' AND tabid=@tabid);

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,'property_status','ld_products',1,56,'boolean','property_status','启用产品属性',1,0,'0',100,@seq+1,@blockid,1,'C~O',1,'','BAS',1,NULL,0,'yes' from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename='ld_products' and columnname='property_status');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='property_status');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'启用产品属性' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Enabling Product Attributes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

CALL AddColumn('ld_products','property_status','TINYINT','2',0);


select tabid into @tabid from ld_tab where name='Products';
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel='LBL_PRODUCT_INFORMATION' AND tabid=@tabid);
SELECT IF(MAX(uitype + 0 ) < 2000, 2001, MAX(uitype + 0) + 1) as uitype INTO @uitype FROM ld_ws_fieldtype;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,maxrowsshow)
select @tabid,@fieldid+1,'propertyids','ld_products',2,@uitype,'multireference','propertyids','产品属性',0,0,'',100,@seq+1,@blockid,1,'V~O',1,'','BAS',1,NULL,0,'yes',5 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename='ld_products' and columnname='propertyids');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='propertyids');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'产品属性' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Product Property' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

CALL AddColumn('ld_products','propertyids','varchar','255','');

select tabid into @tabid from ld_tab where name='Products';
select uitype into @uitype from ld_field where tabid=@tabid AND columnname='propertyids' ;
INSERT INTO ld_ws_fieldtype (`uitype`, `fieldtype`)
SELECT @uitype, 'multireference' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_ws_fieldtype WHERE uitype=@uitype AND fieldtype='multireference');
SELECT fieldtypeid INTO @fieldtypeid FROM ld_ws_fieldtype WHERE uitype = @uitype;
INSERT INTO ld_ws_multireferencetype (`fieldtypeid`, `type`)
SELECT @fieldtypeid, 'ProductProperty' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_ws_multireferencetype WHERE fieldtypeid=@fieldtypeid AND type='ProductProperty');

UPDATE ld_field_seq SET id=@seq;

select tabid into @tabid from ld_tab where `name` = 'Products';

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'attribute_combination','产品属性及属性集合','',0,'text','V~O~200',1,@tabid,'ld_productdetail',15,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'attribute_combination');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'attribute_combination';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@id,'产品属性及属性集合' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@id,'Product attributes and attribute combinations' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'line_unit_price','产品报价','',0,'Amount','N~O~25,2',2,@tabid,'ld_productdetail',15,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'line_unit_price');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'line_unit_price';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@id,'产品报价' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@id,'Product Price' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);


insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'line_procostprice','参考成本价','',0,'Amount','N~O~25,2',3,@tabid,'ld_productdetail',15,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'line_procostprice');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'line_procostprice';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@id,'参考成本价' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@id,'Reference cost price' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'line_qtyearly','安全库存','',0,'Num','N~O~20,12',4,@tabid,'ld_productdetail',10,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'line_qtyearly');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'line_qtyearly';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@id,'安全库存' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@id,'safety stock' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,bigtype)
select 'line_img','产品图片','',0,'Image','V~O',5,@tabid,'ld_productdetail',15,0,0,0,0,2,'image' from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'line_img');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'line_img';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@id,'产品图片' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@id,'Product Image' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'line_status','是否启用','',0,'CheckBox','V~O',6,@tabid,'ld_productdetail',10,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'line_status');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'line_status';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@id,'是否启用' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@id,'Is Active' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'line_productcode','产品条码','',0,'text','V~O',7,@tabid,'ld_productdetail',10,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'line_productcode');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'line_productcode';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@id,'产品条码' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@id,'Product Code' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_productdetail` (
    `productid` int(11) NOT NULL ,
    `lineitem_id` int(11) NOT NULL AUTO_INCREMENT,
    `sequence` tinyint(4) DEFAULT 1,
    `line_unit_price` DECIMAL(25,8) DEFAULT 0.00,
    `line_procostprice` DECIMAL(25,8) DEFAULT 0.00,
    `line_qtyearly` DECIMAL(25,8) DEFAULT 0,
    `line_img` varchar(25) DEFAULT NULL,
    `line_status` tinyint(2) DEFAULT 1,
    `line_productcode` varchar(25) DEFAULT '',
    PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_productdetail2propertydetail` (
    `productdetail_lineitem_id` int(11) NOT NULL ,
    `propertydetail_lineitem_id` int(11) NOT NULL,
    `propertyid` int(11) NOT NULL
) ENGINE=InnoDB;
delimiter;

CALL AddColumn('ld_productcurrencyrel','lineitem_id','int','11','0');
CALL AddColumn('ld_productdetail','property_value_name_combin','text','','');
CALL AddColumn('ld_productdetail2propertydetail','productid','int','','');
delimiter;


set @tabid=(select tabid from ld_tab where name='Products' limit 1);
INSERT INTO ld_fieldrule(tabid,rulename,columnname,createdtime,smcreator,enablestatus)
SELECT @tabid,'根据启用产品属性控制单据头显示','property_status',NOW(),1,'yes' from dual
where not exists(select 1 from ld_fieldrule where tabid=@tabid and columnname='property_status');
delimiter;


SET @myruleid=(SELECT id FROM ld_fieldrule WHERE tabid=@tabid AND columnname='property_status' LIMIT 1);
INSERT INTO ld_fieldrulebasicsearch(ruleid,comparator,`value`)
SELECT @myruleid,'n','是' from dual
where not exists(select 1 from ld_fieldrulebasicsearch where ruleid=@myruleid  AND comparator='n' AND `value`='是'  LIMIT 1) ;

SET @mysearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@myruleid AND comparator='n' AND `value`='是' LIMIT 1);
INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
SELECT 'unit_price','display',@mysearchid from dual
where not exists(select 1 from ld_fieldrule_operate where basicsearchid=@mysearchid and columnname='unit_price' and type='display' ) ;
INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
SELECT 'costprice','display',@mysearchid from dual
where not exists(select 1 from ld_fieldrule_operate where basicsearchid=@mysearchid and columnname='costprice' and type='display' );

INSERT INTO ld_fieldrulebasicsearch(ruleid,comparator,`value`)
SELECT @myruleid,'e','是' from dual
where not exists(select 1 from ld_fieldrulebasicsearch where ruleid=@myruleid  AND comparator='e' AND `value`='是' LIMIT 1);

SET @mysearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@myruleid AND comparator='e' AND `value`='是' LIMIT 1);
INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
SELECT 'propertyids','display',@mysearchid from dual
where not exists(select 1 from ld_fieldrule_operate where basicsearchid=@mysearchid and columnname='propertyids' and type='display' );
delimiter;

select tabid into @tabid from ld_tab where name='Products';

update ld_field set advance_demand='[{"groupid":"1","columnname":"ld_productproperty:property_status:property_status:ProductProperty_fieldlabel:C","comparator":"e","value":"否","columncondition":""}]' ,advance_demand_groups='[null,{"groupcondition":""}]' WHERE tabid=@tabid AND columnname='propertyids';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_token_log` (
    `id`  int(19) NOT NULL AUTO_INCREMENT ,
    `username`  varchar(50) NULL COMMENT 'username' ,
    `token`  varchar(50) NULL COMMENT 'token' ,
    `tokenkey`  varchar(100) COMMENT '生成token参数nonce' ,
    `count`  int(4)  DEFAULT 0 COMMENT  '数量' ,
    `createtime`  datetime DEFAULT CURRENT_TIMESTAMP ,
    PRIMARY KEY (`id`)
) ENGINE = INNODB;
delimiter;

call addtableIndex('ld_token_log','token','token');
delimiter;

call AddColumn('ld_validatasavemain','effectivemethod','varchar','50',NULL);
UPDATE ld_validatasavemain set effectivemethod = 'notmeetcondition' where IFNULL(effectivemethod,'') = '';
delimiter;

SET @labelbol = 'VERIFICATIONCONDI';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'验证条件',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Verification conditions',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_detailfield_after_discounted`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_detailfield_after_discounted`()
BEGIN

    DECLARE tmptabid INT(11) DEFAULT 0;
    DECLARE tmpsourcemodule VARCHAR(50) DEFAULT '';
    DECLARE tmpuitype INT(10) DEFAULT 0;
    DECLARE tmpbigtype VARCHAR(50) DEFAULT 0;
    DECLARE tmptypeofdata VARCHAR(20) DEFAULT 'V~O~4';
    DECLARE tmptablename VARCHAR(50) DEFAULT 'ld_products';

    DECLARE MYCUSOR CURSOR FOR SELECT tabid,sourcemodule,uitype,bigtype,tablename,typeofdata FROM ld_producttoolfield WHERE columnname = 'taxprice';

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmptabid = NULL;

    SET @disable_triggers = 1;
    OPEN MYCUSOR;
    FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmpuitype,tmpbigtype,tmptablename,tmptypeofdata;
    WHILE(tmptabid IS NOT NULL) DO

            SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
            SET @columnname = 'tax_price_after_discounted';
            SET @trantable='ld_producttoolfield';
            SET @allowhide = 'no';
            SET @fieldlabel = '含税单价（优惠后）';
            SET @zh='含税单价（优惠后）';
            SET @en='Discounted price';
            SET @bigtype=tmpbigtype;
            SET @parentbigtype='';
            SET @newline=3;
            SET @edit_permission=1;
            SELECT IFNULL(MAX(sequence),1) INTO @sequence FROM ld_producttoolfield where tabid=tmptabid;
            INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type, fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
            SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,tmpuitype,tmptypeofdata,@sequence+1,tmptabid,tmptablename,45,@edit_permission,0,0,@newline,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,tmpsourcemodule FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND tablename=tmptablename AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) );

            SELECT producttoolfieldid INTO @relatedid FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) LIMIT 1;
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'zh',@trantable,tmptabid,@relatedid,@zh FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'en',@trantable,tmptabid,@relatedid,@en FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);

            CALL AddColumn (tmptablename,@columnname,'decimal','25,8','');

            SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
            SET @columnname = 'tax_amount_after_discounted';
            SET @trantable='ld_producttoolfield';
            SET @allowhide = 'no';
            SET @fieldlabel = '价税合计（优惠后）';
            SET @zh='价税合计（优惠后）';
            SET @en='Discounted amount';
            SET @bigtype=tmpbigtype;
            SET @parentbigtype='';
            SET @newline=3;
            SET @edit_permission=1;
            SELECT typeofdata INTO tmptypeofdata FROM ld_producttoolfield WHERE columnname = 'tax_amount' AND tabid=tmptabid LIMIT 1;
            SELECT IFNULL(MAX(sequence),1) INTO @sequence FROM ld_producttoolfield where tabid=tmptabid;
            INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type, fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
            SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,tmpuitype,tmptypeofdata,@sequence+1,tmptabid,tmptablename,45,@edit_permission,0,0,@newline,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,tmpsourcemodule FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND tablename=tmptablename AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) );

            SELECT producttoolfieldid INTO @relatedid FROM ld_producttoolfield WHERE tabid=tmptabid AND columnname=@columnname AND IFNULL(sourcemodule,1) = IFNULL(tmpsourcemodule,1) LIMIT 1;
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'zh',@trantable,tmptabid,@relatedid,@zh FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);
            INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
            SELECT 'en',@trantable,tmptabid,@relatedid,@en FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND tabid=tmptabid AND relateid=@relatedid AND trantable=@trantable);

            CALL AddColumn (tmptablename,@columnname,'decimal','25,8','');

            UPDATE ld_producttoolfield_seq SET ld_producttoolfield_seq.id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);

            FETCH MYCUSOR INTO tmptabid,tmpsourcemodule,tmpuitype,tmpbigtype,tmptablename,tmptypeofdata;
        END WHILE;

    CLOSE MYCUSOR;
    SET @disable_triggers = NULL;
END ||
delimiter;

CALL ldcrm_add_detailfield_after_discounted();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_detailfield_after_discounted`;
delimiter;

select tabid into @tabid from ld_tab where name='Products' limit 1;
SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @detailtablename='ld_productdetail';
SET @columnname = 'setdefault';
SET @allowhide = 'no';
SET @fieldlabel = '设为默认';
SET @fieldtype = 'CheckBox';
SET @typeofdata='V~O';
SET @bigtype='boolean';
SET @sourcemodule='Products';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @referencemodule = '';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,10,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='setdefault' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='设为默认';
SET @en='Set Default';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;
-- 2024-10-15

SET @i=0;
UPDATE ld_industrydemo SET sequence=sequence+5;
UPDATE ld_industrydemo SET sequence=1 WHERE datasql_path='IndustryDemo/001_factory.sql';

INSERT INTO ld_industrydemo (industry_zh, industry_en, datasql_path, templatefile_path, suit_crmversion, sequence)
SELECT '半导体设计和品牌厂商适用', 'Semiconductor Solution for Agents', 'IndustryDemo/017_bandaotiforchangshang.sql',NULL, 'all', '2' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_industrydemo WHERE datasql_path='IndustryDemo/017_bandaotiforchangshang.sql');

INSERT INTO ld_industrydemo (industry_zh, industry_en, datasql_path, templatefile_path, suit_crmversion, sequence)
SELECT '半导体集成方案代理商适用', 'Semiconductor Solution for Agents', 'IndustryDemo/016_bandaotifordailishang.sql',NULL, 'all', '3' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_industrydemo WHERE datasql_path='IndustryDemo/016_bandaotifordailishang.sql');

UPDATE ld_industrydemo SET sequence=(@i:=@i+1) ORDER BY sequence;
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

UPDATE ld_version SET old_version='V8.6.4.6',current_version='V8.6.4.6',remark='V8.6.4.6-20241015',wx_version='V8.6.5.0';
delimiter;