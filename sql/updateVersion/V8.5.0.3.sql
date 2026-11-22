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

SET @tabid = (select tabid from ld_tab where `name`='Leads');
SET @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname = 'leads_no');
update ld_module_mappingfields set is_disabled=0 where tabid=@tabid and fieldid=@fieldid;
update ld_module_mappingfields set mapping_columnname='' where tabid=@tabid and fieldid=@fieldid and not exists (select 1 from ld_leads);
delimiter;

update ld_cvadvfilter set columnname='ld_leads:status:status:Leads_fieldlabel:V' where columnname='ld_leads:upgradeaccountid:upgradeaccountid:Leads_fieldlabel:V' and `value`='升级到' and cvid=(select cvid from ld_customview WHERE entitytype='Leads' and viewname='已升级' and customcategory='ALLACCOUNT');
delimiter;

UPDATE ld_desk SET fieldlabel = '（温馨提示：光标定位在[varfield]中按下Ctrl+Enter键可以更改当前行及之后所有行的[varfield]值）' where labelbol = 'CtrlEnterComBox' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = '(Note:Press Ctrl+Enter to change the value of the [varfield] for the current row and all subsequent rows)' where labelbol = 'CtrlEnterComBox' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','UPGRATEDLEADS','单据[%s]%s失败！原因：该销售线索已%s！','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'UPGRATEDLEADS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','UPGRATEDLEADS','The document [%s] %s failed! Reason: This lead has been %s!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'UPGRATEDLEADS' and Labeltype = 'fixedstr');
delimiter;


UPDATE ld_desk SET fieldlabel='Customer self-service platform(Chinese)' WHERE labelbol= 'MPSELFCONFIGPLAT' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='客户自助服务平台(中文)' WHERE labelbol= 'MPSELFCONFIGPLAT' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MPSELFCONFIGPLATEN','客户自助服务平台(英文)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MPSELFCONFIGPLATEN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MPSELFCONFIGPLATEN','Customer self-service platform(English)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MPSELFCONFIGPLATEN' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_weixinmp_module','mplabel_en','varchar','100',NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MyRepairHint1','实时查看以及管理我的报修单！','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MyRepairHint1' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MyRepairHint1','Check and manage my claim in real time!','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MyRepairHint1' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MyRepairHint2','实时报修并解决反馈问题！','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MyRepairHint2' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MyRepairHint2','Real time repair and resolution of feedback issues!','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MyRepairHint2' and labeltype='fuwu');
delimiter;

UPDATE ld_weixinmp_module SET content='MyRepairHint1',mplabel_en= CASE WHEN mplabel='我的报修' THEN 'My Repair Request' ELSE mplabel END where modulename='HelpDesk' and type='view' and ifnull(mplabel_en,'') = '';
UPDATE ld_weixinmp_module SET content='MyRepairHint2',mplabel_en= CASE WHEN mplabel='我要报修' THEN 'Apply For Repair' ELSE mplabel END where modulename='HelpDesk' and type='create' and ifnull(mplabel_en,'') = '';
UPDATE ld_weixinmp_module SET mplabel_en= CASE WHEN mplabel='注册' THEN 'Registration' ELSE mplabel END where modulename='Accounts' and ifnull(mplabel_en,'') = '';
UPDATE ld_weixinmp_module SET mplabel_en= CASE WHEN mplabel='注册' THEN 'Registration' ELSE mplabel END where modulename='Contacts' and ifnull(mplabel_en,'') = '';
UPDATE ld_weixinmp_module SET mplabel_en= CASE WHEN mplabel='我的订单' THEN 'My Order' ELSE mplabel END where modulename='SalesOrder' and type='view' and ifnull(mplabel_en,'') = '';
UPDATE ld_weixinmp_module SET mplabel_en= CASE WHEN mplabel='我要下单' THEN 'Place An Order' ELSE mplabel END where modulename='SalesOrder' and type='create' and ifnull(mplabel_en,'') = '';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MyInfoHint','实时查看我的个人信息！','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MyInfoHint' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MyInfoHint','View my personal information in real-time!','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MyInfoHint' and labeltype='fuwu');
delimiter;


CALL AddColumn('ld_weixinmp_fields','fieldlabel_en','varchar','100',NULL);
delimiter;

UPDATE ld_weixinmp_fields as t2
	INNER JOIN (
	SELECT ld_tranlabel.fieldlabel as translate_en,ld_field.fieldname,ld_tab.name
	FROM ld_field
	LEFT JOIN ld_tranlabel ON ld_tranlabel.tabid=ld_field.tabid AND ld_field.fieldid=Relateid
	LEFT JOIN ld_tab ON ld_tab.tabid = ld_field.tabid WHERE ld_tranlabel.trantable = 'ld_field' AND languagetype='en'
	) as t1 ON t1.fieldname=t2.fieldname AND t1.name=t2.modulename
SET t2.fieldlabel_en=t1.translate_en WHERE ifnull(t2.fieldlabel_en,'') = '';
delimiter;


UPDATE ld_wx_evaluate_field SET en_label= CASE WHEN zh_label='服务评分' THEN 'Service evaluation' ELSE zh_label END where columname='grade' AND ifnull(en_label,'') = '';
UPDATE ld_wx_evaluate_field SET en_label= CASE WHEN zh_label='满意度' THEN 'Satisfaction' ELSE zh_label END where columname='satisfaction' AND ifnull(en_label,'') = '';
UPDATE ld_wx_evaluate_field SET en_label= CASE WHEN zh_label='及时率' THEN 'Timeliness rate' ELSE zh_label END where columname='timeliness_rate' AND ifnull(en_label,'') = '';
UPDATE ld_wx_evaluate_field SET en_label= CASE WHEN zh_label='解决率' THEN 'Resolution rate' ELSE zh_label END where columname='resolution_rate' AND ifnull(en_label,'') = '';
UPDATE ld_wx_evaluate_field SET en_label= CASE WHEN zh_label='服务体验' THEN 'Service experience' ELSE zh_label END where columname='service_experience' AND ifnull(en_label,'') = '';
UPDATE ld_wx_evaluate_field SET en_label= CASE WHEN zh_label='自定义项1' THEN 'Customization 1' ELSE zh_label END where columname='custom1' AND ifnull(en_label,'') = '';
UPDATE ld_wx_evaluate_field SET en_label= CASE WHEN zh_label='自定义项2' THEN 'Customization 2' ELSE zh_label END where columname='custom2' AND ifnull(en_label,'') = '';
UPDATE ld_wx_evaluate_field SET en_label= CASE WHEN zh_label='自定义项3' THEN 'Customization 3' ELSE zh_label END where columname='custom3' AND ifnull(en_label,'') = '';
delimiter;


CALL AddColumn('ld_weixinmp_users','languagetype','varchar','5','zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OnlineService','在线服务','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OnlineService' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OnlineService','Online service','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OnlineService' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnterPhoneNumber','请输入手机号码','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EnterPhoneNumber' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnterPhoneNumber','Mobile number','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EnterPhoneNumber' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnterVerificationCode','请输入验证码','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EnterVerificationCode' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnterVerificationCode','Verification code','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EnterVerificationCode' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GetVerificationCode','获取验证码','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GetVerificationCode' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GetVerificationCode','Obtain verification code','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GetVerificationCode' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SResend','s后重新发','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SResend' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SResend','s resend','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SResend' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Tips','温馨提示','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Tips' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Tips','Tips','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Tips' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Tips1BindVerification','绑定时会验证手机号码和验证码','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Tips1BindVerification' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Tips1BindVerification','Verify mobile number and verification code during binding','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Tips1BindVerification' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Tips2CodeMaximum5Times','当日最多可获取5次验证码，若无法接收，请联系微信在线客服','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Tips2CodeMaximum5Times' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Tips2CodeMaximum5Times','You can obtain a maximum of 5 verification codes on the same day. If you are unable to receive them, please contact WeChat online customer service','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Tips2CodeMaximum5Times' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Login','登录','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Login' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Login','Login','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Login' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PhoneCannotEmpty','手机号码不能为空','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PhoneCannotEmpty' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PhoneCannotEmpty','Mobile phone number cannot be empty','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PhoneCannotEmpty' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PhoneFormatIncorrect','手机号码格式错误','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PhoneFormatIncorrect' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PhoneFormatIncorrect','The format of the mobile phone number is incorrect','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PhoneFormatIncorrect' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VerificationCodeFailedMsg','发送验证码失败，请检查：1.CRM服务器系统设置-短信账号设置；2.短信模板是否设置正确','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VerificationCodeFailedMsg' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VerificationCodeFailedMsg','Sending verification code failed. Please check: 1. CRM server system settings - SMS account settings; 2. Is the SMS template set correctly','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VerificationCodeFailedMsg' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VerificationCodeCannotEmpty','验证码不能为空','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VerificationCodeCannotEmpty' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VerificationCodeCannotEmpty','The verification code cannot be empty','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VerificationCodeCannotEmpty' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VerificationCodeIsIncorrect','验证码不正确','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VerificationCodeIsIncorrect' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VerificationCodeIsIncorrect','Incorrect verification code','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VerificationCodeIsIncorrect' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PhoneNotRegisteredToRegisterAccount','手机号未注册，直接注册客户','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PhoneNotRegisteredToRegisterAccount' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PhoneNotRegisteredToRegisterAccount','Unregistered mobile phone number, directly registered customer','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PhoneNotRegisteredToRegisterAccount' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PhoneNotRegisteredToRegisterContact','手机号未注册，直接注册联系人','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PhoneNotRegisteredToRegisterContact' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PhoneNotRegisteredToRegisterContact','Mobile number not registered, directly register contact','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PhoneNotRegisteredToRegisterContact' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Registration','注册','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Registration' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Registration','Registration','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Registration' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Add','新增','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Add' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Add','Add','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Add' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Edit','编辑','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Edit' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Edit','Edit','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Edit' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Details','详情','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Details' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Details','Details','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Details' and labeltype='fuwu');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PhoneRegisteredToBindAccount','手机号已注册，直接绑定客户','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PhoneRegisteredToBindAccount' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PhoneRegisteredToBindAccount','The mobile number has been registered and can be directly linked to the customer','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PhoneRegisteredToBindAccount' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PhoneRegisteredToBindContact','手机号已注册，直接绑定联系人','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PhoneRegisteredToBindContact' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PhoneRegisteredToBindContact','The mobile number has been registered and can be directly linked to a contact','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PhoneRegisteredToBindContact' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RegisteredSuccess','注册成功','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RegisteredSuccess' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RegisteredSuccess','Reg Success','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RegisteredSuccess' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HomePage','首页','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='HomePage' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HomePage','Home page','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='HomePage' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MyInfo','我的信息','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MyInfo' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MyInfo','My Information','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MyInfo' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MyInfoHint','实时查看我的个人信息！','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MyInfoHint' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MyInfoHint','View my personal information in real-time!','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MyInfoHint' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Me','我','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Me' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Me','Me','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Me' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WeChatUser','微信用户','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WeChatUser' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WeChatUser','WeChat user','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WeChatUser' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Unbind','解除绑定','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Unbind' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Unbind','Unbind','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Unbind' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ConfirmUnbind','你确定要解除绑定的客户吗？','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ConfirmUnbind' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ConfirmUnbind','Are you sure about the clients you want to unbind?','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ConfirmUnbind' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Search','搜索','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Search' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Search','Search ','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Search' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','All','全部','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='All' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','All','All','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='All' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ToBeEvaluate','待评价','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ToBeEvaluate' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ToBeEvaluate','To be evaluated','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ToBeEvaluate' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Evaluated','已评价','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Evaluated' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Evaluated','Evaluated','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Evaluated' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Evaluate','评价','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Evaluate' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Evaluate','Evaluate','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Evaluate' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Loading','加载中...','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Loading' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Loading','Loading...','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Loading' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseSelect','请选择','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PleaseSelect' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseSelect','Please select','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PleaseSelect' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseSelectFirst','请先选择','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PleaseSelectFirst' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseSelectFirst','Please select first','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PleaseSelectFirst' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Reselecting','，再选择','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Reselecting' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Reselecting',',reselecting','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Reselecting' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UpToUpload','最多可上传','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UpToUpload' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UpToUpload','You can upload up to ','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UpToUpload' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pictures','个图片','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Pictures' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pictures',' pictures','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Pictures' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Photograph','拍照','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Photograph' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Photograph','Photograph','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Photograph' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PhotoAlbum','相册','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PhotoAlbum' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PhotoAlbum','Photo album','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PhotoAlbum' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Attachments','个附件','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Attachments' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Attachments',' attachments','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Attachments' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseSelectType','请选择源单类型后，再选择源单','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PleaseSelectType' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseSelectType','Select the original order type and then select the original order','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PleaseSelectType' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AreLocationAddressesUsed','是否用定位地址覆盖国家、省份、城市及地址？','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AreLocationAddressesUsed' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AreLocationAddressesUsed','Are countries, provinces, cities, and addresses covered with location addresses?','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AreLocationAddressesUsed' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PrimaryContactCannotEmpty','首要联系人姓名不能为空','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PrimaryContactCannotEmpty' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PrimaryContactCannotEmpty','The primary contact name cannot be empty','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PrimaryContactCannotEmpty' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CanNotBeEmpty','不能为空','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CanNotBeEmpty' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CanNotBeEmpty','Can not be empty','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CanNotBeEmpty' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FormatError','格式错误','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FormatError' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FormatError','Format error','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FormatError' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseEnterCorrect','请输入正确的','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PleaseEnterCorrect' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseEnterCorrect','Please enter the correct one','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PleaseEnterCorrect' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseEnter','请输入','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PleaseEnter' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseEnter','Please enter','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PleaseEnter' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BasicInformation','基本信息','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BasicInformation' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BasicInformation','Basic information','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BasicInformation' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Save','保存','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Save' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Save','Save','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Save' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Confirmed','确定','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Confirmed' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Confirmed','Confirm','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Confirmed' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Cancel','取消','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Cancel' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Cancel','Cancel','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Cancel' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Submit','提交','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Submit' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Submit','Submit','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Submit' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SubmitSuccessfully','提交成功','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SubmitSuccessfully' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SubmitSuccessfully','Submit successfully','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SubmitSuccessfully' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddedSuccess','新增成功','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddedSuccess' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddedSuccess','Added success','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddedSuccess' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ServiceEvaluation','服务评价','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ServiceEvaluation' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ServiceEvaluation','Service evaluation','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ServiceEvaluation' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BindingSuccess','绑定成功','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BindingSuccess' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BindingSuccess','Binding success','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BindingSuccess' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Communicate','沟通','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Communicate' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Communicate','Communicate','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Communicate' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CommunicateInfo','沟通信息','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CommunicateInfo' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CommunicateInfo','Communicate information','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CommunicateInfo' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoCommunicateInfo','没有沟通信息','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NoCommunicateInfo' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoCommunicateInfo','No communicate information','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NoCommunicateInfo' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseFillIn','请填写','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PleaseFillIn' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseFillIn','Please fill in','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PleaseFillIn' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoData','没有数据','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NoData' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoData','No data','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NoData' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotObtained','未获取','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NotObtained' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotObtained','Not obtained','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NotObtained' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ObtainAuthorization','获取授权','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ObtainAuthorization' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ObtainAuthorization','Obtain authorization','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ObtainAuthorization' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ClickObtainAuth','点击下方【获取授权】可获取用户头像及昵称','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ClickObtainAuth' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ClickObtainAuth',"Click 'Obtain Authorization' below to get the user's picture and nickname",'fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ClickObtainAuth' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OrderRecordQuery','订单记录查询','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OrderRecordQuery' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OrderRecordQuery','Order record query','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OrderRecordQuery' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoMoreData','没有更多数据','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NoMoreData' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoMoreData','No more data','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NoMoreData' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Date','日期','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Date' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Date','Date','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Date' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Content','内容','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Content' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Content','Content','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Content' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Content1','内容：','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Content1' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Content1','Content:','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Content1' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FillInReply','请填写回复内容','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FillInReply' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FillInReply','Please fill in the reply','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FillInReply' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FillInContent','请填写内容','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FillInContent' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FillInContent','Please fill in the content','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FillInContent' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CommunicationAndReply','沟通回复','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CommunicationAndReply' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CommunicationAndReply','Communication and reply','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CommunicationAndReply' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FailedShutdown','失败关闭','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FailedShutdown' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FailedShutdown','Failed shutdown','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FailedShutdown' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotFillInContent','您还没有填写内容','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NotFillInContent' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotFillInContent',"You haven't filled it in yet",'fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NotFillInContent' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Release','发布','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Release' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Release','Release','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Release' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REPLY','回复','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='REPLY' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REPLY','Reply','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='REPLY' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOGRAPH','签名','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOGRAPH' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOGRAPH','autograph','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOGRAPH' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RESIGN','重签','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RESIGN' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RESIGN','Re sign','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RESIGN' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAP','地图','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MAP' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAP','Map','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MAP' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPLETE','完成','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='COMPLETE' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPLETE','Complete','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='COMPLETE' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REWRITE','重写','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='REWRITE' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REWRITE','Rewrite','fuwu' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='REWRITE' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BINDTIPS2','您确定绑定所选信息？','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BINDTIPS2' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BINDTIPS2','Are you sure you want to bind the selected information?','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BINDTIPS2' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BINDTIPS','根据所填号码获取到以下客户，请确认后选择绑定','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BINDTIPS' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BINDTIPS','Based on the number filled in, we have obtained the following customers. Please confirm and choose to bind them','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BINDTIPS' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SAVEASIMAGE','保存为图片','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SAVEASIMAGE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SAVEASIMAGE','Save as image','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SAVEASIMAGE' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Columnnamecannotbeempty','列名称不能为空','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Columnnamecannotbeempty' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Columnnamecannotbeempty','Column name cannot be empty','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Columnnamecannotbeempty' and labeltype='jspop');
delimiter;


SET @module='Campaigns';			
SET @rel_module='Leads';		

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module);
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`=@rel_module);

SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @relation_id+1,@tabid,@rel_tabid,CONCAT('get_',LOWER(@rel_module)),@seq+1,@rel_module,0,'add,sendemail,select','crmentityrel_datacategory_sql','crmentityrel.crmid' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=CONCAT('get_',LOWER(@rel_module)));

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

UPDATE ld_desk SET fieldlabel='设为PC端首页看板可选组件' WHERE labelbol='showAtPcHome' AND languagetype='zh' AND Labeltype='fixedstr';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesGoal' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='目标管理' WHERE trantable='ld_tab' AND Relateid=@tabid AND languagetype='zh' AND fieldlabel='销售目标';
UPDATE ld_tranlabel SET fieldlabel='Objectives management' WHERE trantable='ld_tab' AND Relateid=@tabid AND languagetype='en' AND fieldlabel='Sales Goal';
delimiter;
-- 2023-05-26


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

UPDATE ld_version SET old_version='V8.5.0.3',current_version='V8.5.0.3',remark='V8.5.0.3-20230526',wx_version='V8.5.0.3';
delimiter;