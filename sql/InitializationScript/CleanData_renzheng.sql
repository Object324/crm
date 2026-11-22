DROP PROCEDURE IF EXISTS `Initial_CRM_Account1`;
DELIMITER ;;
CREATE PROCEDURE `Initial_CRM_Account1`(
)
BEGIN

	-- 设置关闭外键约束
	SET FOREIGN_KEY_CHECKS=0;
  SET @disable_triggers=1;

	-- 1、初始化自动备份信息
	DELETE FROM ld_backup;
	INSERT INTO `ld_backup` VALUES ('1', '1', NULL, NULL, NULL, NULL);
	INSERT INTO `ld_backup` VALUES ('2', '0', NULL, 'day', '23', '1');

	-- 2、重置系统编码流水号为1
	UPDATE ld_modentity_num 
	SET cur_id=start_id 
	WHERE cur_id>1 
		AND start_id=1 
		AND semodule NOT IN ('Documents','Faq','Products','CustomForm47','CustomForm49','CustomForm50',
			'CustomForm51','CustomForm52','CustomForm53','CustomForm56','CustomForm57','CustomForm58','CustomForm59','CustomForm60','CustomForm61');

	UPDATE ld_modentity_num 
	SET start_id=LPAD(1,LENGTH(cur_id),0),cur_id=LPAD(1,LENGTH(cur_id),0) 
	WHERE cur_id>1 
		AND start_id>1 
		AND semodule NOT IN ('Documents','Faq','Products','CustomForm47','CustomForm49','CustomForm50',
			'CustomForm51','CustomForm52','CustomForm53','CustomForm56','CustomForm57','CustomForm58','CustomForm59','CustomForm60','CustomForm61');


	-- 3、删除基础数据表 ld_crmentity 表中所有数据,仅保留预置的2个银行账户信息。
	DELETE FROM ld_crmentity WHERE crmid>2 AND setype NOT IN ('Documents','Faq','Products','CustomForm47','CustomForm49','CustomForm50',
			'CustomForm51','CustomForm52','CustomForm53','CustomForm56','CustomForm57','CustomForm58','CustomForm59','CustomForm60','CustomForm61');

	-- 3.01、初始化银行账户数据
  DELETE FROM ld_bankaccountset WHERE Bankaccountsetid>2;
	DELETE FROM ld_bankaccountprofile;
	INSERT INTO ld_bankaccountprofile(Bankaccountsetid,Userid)
	SELECT Bankaccountsetid,-1 FROM ld_bankaccountset;

	UPDATE ld_bankaccountset SET discontinued=1,banknum=NULL,bankname=NULL,InitMoney=0.00,curbalancemoney=0.00,confirmed=1,currency_id=1,
		conversion_rate=1.000000,currency_symbol='¥',confirmby=1,smownerid=1,smcreatorid=1,modifiedby=1,deleted=0,description=NULL;

	UPDATE ld_bankaccountset SET Accountname='现金(财务部)' WHERE Bankaccountsetid=1;
	UPDATE ld_bankaccountset SET Accountname='XX银行账户' WHERE Bankaccountsetid=2;

	-- 3.02、删除短信、邮件、通话记录
	-- 删除短信账户、邮件记录
	TRUNCATE ld_communicationaccount;
	TRUNCATE ld_smssend;

	-- 删除邮件设置、邮件记录
	TRUNCATE ld_systems;
	TRUNCATE ld_emaildetails;

	-- 删除呼叫中心设置参数
	UPDATE ld_systems_deploy SET deploy_value=NULL WHERE deploy_type=55;
	UPDATE ld_systems_deploy SET deploy_value='http://' WHERE deploy_type IN (101,107,121);
	UPDATE ld_systems_deploy SET deploy_value='' WHERE deploy_type=76;
	UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=160;

	UPDATE ld_field SET callchecked=0;
	UPDATE ld_field SET callchecked=1 WHERE tabid=6 AND columnname='phone';

	-- 删除录音盒、汉天、九维、思孚通话记录
	TRUNCATE ld_callbutler;
	TRUNCATE ld_hantian_phonerecord;
	TRUNCATE ld_jiuweiak_phonerecord;
	TRUNCATE ld_sopho_phonerecord;

	-- 3.02 删除帮我吧接口设置
	TRUNCATE ld_bangwo8;
	TRUNCATE ld_bangwo8_supportname;
	UPDATE ld_users SET bangwo8_supportname=NULL;

	-- 3.03 删除ERP接口配置
	TRUNCATE ld_datainterface;
	INSERT INTO ld_datainterface(ID,soft_version,sa,hostname) SELECT 1,1,'sa','.';

	-- 3.04 删除公告，记事本，包括上方滚动的公告
	TRUNCATE ld_publicannouncement;
	TRUNCATE ld_publicannouncement_reminds;
	TRUNCATE ld_announcement;
  TRUNCATE ld_notebook_contents;

	-- 3.05、初始化仓库信息
	TRUNCATE ld_warehousetransfer;
	TRUNCATE ld_warehousetransfercf;
	TRUNCATE ld_warehouse2products;
	TRUNCATE ld_warehousecondtions;
	TRUNCATE ld_warehouse2startedproducts;
	UPDATE ld_warehouse SET `status`=0,started=0;
	TRUNCATE ld_warehouse2user;
	INSERT INTO ld_warehouse2user(warehouseid,userid) SELECT id,-1 FROM ld_warehouse;

	-- 3.06、删除修改日志、登录日志等信息
	TRUNCATE ld_audit_trial;
	TRUNCATE ld_modtracker_basic;
	TRUNCATE ld_modtracker_detail;
	TRUNCATE ld_loginhistory;

	-- 3.07、删除工作协同
	TRUNCATE ld_workreport;
	TRUNCATE ld_workreportcf;
	TRUNCATE ld_workreport2user;
	TRUNCATE ld_workreportrelatedto;
	TRUNCATE ld_workrangenote;
	TRUNCATE ld_workreply;
	TRUNCATE ld_workreply2user;
	TRUNCATE ld_workachments;
	TRUNCATE ld_workreport_remind;

	-- 3.08 删除客户、联系人信息、联系记录
  TRUNCATE ld_leads;
  TRUNCATE ld_leadscf;
  TRUNCATE ld_leaddetails;
	TRUNCATE ld_account;
	TRUNCATE ld_accountscf;
	TRUNCATE ld_contactdetails;
	TRUNCATE ld_contactscf;
	TRUNCATE ld_contactrecords;
	TRUNCATE ld_contactrecordscf;

	-- 3.09 删除供应商、供应商联系人、供应商联系记录
	TRUNCATE ld_vendor;
	TRUNCATE ld_vendorcf;
	TRUNCATE ld_vendorcontactrecords;
	TRUNCATE ld_vendorcontactrecordsscf;
	TRUNCATE ld_vendorcontacts;
	TRUNCATE ld_vendorcontactscf;
	TRUNCATE ld_vendorcontactrel;

	-- 3.10、删除报价单、报价变更单、合同订单、服务合同、销售发票、采购订单、采购发票
	TRUNCATE ld_quotes;
	TRUNCATE ld_quotescf;
	TRUNCATE ld_quoteschange;
	TRUNCATE ld_quoteschangescf;
	TRUNCATE ld_salesorder;
	TRUNCATE ld_salesordercf;
	TRUNCATE ld_servicecontracts;
	TRUNCATE ld_servicecontractscf;
	TRUNCATE ld_invoice;
	TRUNCATE ld_invoicecf;
	TRUNCATE ld_purchaseorder;
	TRUNCATE ld_purchaseordercf;
	TRUNCATE ld_purchaseinvoice;
	TRUNCATE ld_purchaseinvoicecf;

	-- 3.11 删除入库单、出库单、调拨单、盘点单
	TRUNCATE ld_stock;
	TRUNCATE ld_stockcf;
	TRUNCATE ld_outboundorder;
	TRUNCATE ld_outboundordercf;
	TRUNCATE ld_warehousetransfer;
	TRUNCATE ld_warehousetransfercf;
	TRUNCATE ld_checks;
	TRUNCATE ld_checkscf;

	-- 3.12 删除销售退货单、销售退款单、采购退货单、采购退款单
	TRUNCATE ld_salesback;
	TRUNCATE ld_salesbackscf;
	TRUNCATE ld_cashback;
	TRUNCATE ld_cashbackscf;
	TRUNCATE ld_purchaseback;
	TRUNCATE ld_purchasebackscf;
	TRUNCATE ld_purchasecashback;
	TRUNCATE ld_purchasecashbackscf;

	-- 3.13 删除所有单据产品明细信息
	IF NOT EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_salesorderdetail') THEN 
		TRUNCATE ld_inventoryproductrel;
		TRUNCATE ld_inventoryproductrelscf;
	ELSE
		TRUNCATE ld_quotesdetail;
		TRUNCATE ld_quotesdetailscf;
		TRUNCATE ld_purchaseorderdetail;
		TRUNCATE ld_purchaseorderdetailscf;
		TRUNCATE ld_salesorderdetail;
		TRUNCATE ld_salesorderdetailscf;
		TRUNCATE ld_invoicedetail;
		TRUNCATE ld_invoicedetailscf;
		TRUNCATE ld_servicecontractsdetail;
		TRUNCATE ld_servicecontractsdetailscf;
		TRUNCATE ld_outboundorderdetail;
		TRUNCATE ld_outboundorderdetailscf;
		TRUNCATE ld_stockdetail;
		TRUNCATE ld_stockdetailscf;
		TRUNCATE ld_checksdetail;
		TRUNCATE ld_checksdetailscf;
		TRUNCATE ld_salesbackdetail;
		TRUNCATE ld_salesbackdetailscf;
		TRUNCATE ld_cashbackdetail;
		TRUNCATE ld_cashbackdetailscf;
		TRUNCATE ld_purchasebackdetail;
		TRUNCATE ld_purchasebackdetailscf;
		TRUNCATE ld_purchasecashbackdetail;
		TRUNCATE ld_purchasecashbackdetailscf;
		TRUNCATE ld_purchaseinvoicedetail;
		TRUNCATE ld_purchaseinvoicedetailscf;
		TRUNCATE ld_warehousetransferdetail;
		TRUNCATE ld_warehousetransferdetailscf;
		TRUNCATE ld_productbomdetail;
		TRUNCATE ld_productbomdetailscf;
		TRUNCATE ld_quoteschangedetail;
		TRUNCATE ld_quoteschangedetailscf;
		TRUNCATE ld_purchaseinquiryorderdetail;
		TRUNCATE ld_purchaseinquiryorderdetailscf;
	END IF;

	-- 3.14 删除产品、产品套餐、价格表
	TRUNCATE ld_products;
	TRUNCATE ld_productcf;
	TRUNCATE ld_productbom;
	TRUNCATE ld_productbomcf;
	TRUNCATE ld_pricebook;
	TRUNCATE ld_pricebookcf;
	TRUNCATE ld_pricebookproductrel;

	-- 3.15 删除回款计划、收款单
	TRUNCATE ld_paymentplan;
	TRUNCATE ld_paymentplanscf;
	TRUNCATE ld_cashbill;
	TRUNCATE ld_cashbillscf;
	TRUNCATE ld_cashbill2paymentplan;
	TRUNCATE ld_cashbill2paymentplanscf;

	-- 3.16 删除付款计划、付款单 
	TRUNCATE ld_sendpayment;
	TRUNCATE ld_sendpaymentscf;
	TRUNCATE ld_sendcashbill;
	TRUNCATE ld_sendcashbillscf;
	TRUNCATE ld_sendcashbill2payment;
	TRUNCATE ld_sendcashbill2paymentscf;

	-- 3.17 删除费用
	TRUNCATE ld_expense;
	TRUNCATE ld_expensescf;
	TRUNCATE ld_expensedetail;
	TRUNCATE ld_expensedetailscf;


	-- 3.18 删除佣金单
	TRUNCATE ld_commission;
	TRUNCATE ld_commissionscf;
	TRUNCATE ld_commission2payment;
	TRUNCATE ld_commission2paymentscf;

	-- 3.19 删除评论
	TRUNCATE ld_modcomments;
	TRUNCATE ld_modcommentscf;

	-- 3.20 删除项目、项目任务、项目里程碑、项目进度
	TRUNCATE ld_project;
	TRUNCATE ld_projectcf;
	TRUNCATE ld_projecttask;
	TRUNCATE ld_projecttaskcf;
	TRUNCATE ld_projectmilestone;
	TRUNCATE ld_projectmilestonecf;
	TRUNCATE ld_projectprogress;
	TRUNCATE ld_projectprogresscf;

	-- 3.21 删除费率设定
	TRUNCATE ld_rate;
	TRUNCATE ld_ratescf;

	-- 3.22 删除工时数据
	TRUNCATE ld_timesheet;
	TRUNCATE ld_timesheetcf;
	TRUNCATE ld_timesheetdetail;
	TRUNCATE ld_timesheetdetailscf;

	-- 3.23 删除市场活动
	TRUNCATE ld_campaign;
	TRUNCATE ld_campaignaccountrel;
	TRUNCATE ld_campaigncontrel;
	TRUNCATE ld_campaignleadrel;
	TRUNCATE ld_campaignscf;

	TRUNCATE ld_accountpotentialrel;
	TRUNCATE ld_contpotentialrel;

	-- 3.23 删除银行网点、派息单
	TRUNCATE ld_bankbranch;
	TRUNCATE ld_bankbranchcf;

	TRUNCATE ld_dividendorder;
	TRUNCATE ld_dividendordercf;
	TRUNCATE ld_dividendorderdetail;
	TRUNCATE ld_dividendordersetting;
	TRUNCATE ld_dividendorder_sms;

	-- 3.24 管理费佣金、管理费、业绩报酬、业绩报酬佣金、净值
	TRUNCATE ld_fund_management_commission;
	TRUNCATE ld_fund_manager_commissionscf;
	TRUNCATE ld_fund_management;
	TRUNCATE ld_fund_managementscf;
	TRUNCATE ld_fund_reward;
	TRUNCATE ld_fund_rewardcf;
	TRUNCATE ld_fund_reward_commission;
	TRUNCATE ld_fund_reward_commissioncf;
	TRUNCATE ld_fund_reward_low_water;
	
	TRUNCATE ld_fund_net;
	TRUNCATE ld_fund_netcf;
	TRUNCATE ld_fund_accured_history;
	TRUNCATE ld_fund_accured_history_detail;
	TRUNCATE ld_fund_buyproductquantityhistory;
	TRUNCATE ld_fund_redemption;

	-- 3.25 删除服务单、服务回访
	TRUNCATE ld_troubletickets;
	TRUNCATE ld_ticketcf;
	TRUNCATE ld_servicereturn;
	TRUNCATE ld_servicereturncf;

	-- 3.26 删除排课计划
	TRUNCATE ld_lessionplan;
	TRUNCATE ld_lessionplanscf;
	TRUNCATE ld_lessionplanorg;

	-- 3.27 删除加班单
	TRUNCATE ld_addjobbill;
	TRUNCATE ld_addjobbillscf;
	TRUNCATE ld_addjobbilldetail;
	TRUNCATE ld_addjobbilldetailscf;

	-- 3.28 删除请假单
	TRUNCATE ld_minusjobbill;
	TRUNCATE ld_minusjobbillscf;
	TRUNCATE ld_minusjobbilldetail;
	TRUNCATE ld_minusjobbilldetailscf;

	-- 3.29 删除普通审批
	TRUNCATE ld_normalapprove;
	TRUNCATE ld_normalapprovescf;

	-- 3.30 删除出差申请
	TRUNCATE ld_businessapply;
	TRUNCATE ld_businessapplyscf;
	TRUNCATE ld_businessapplydetail;
	TRUNCATE ld_businessapplydetailscf;

	-- 3.31 删除名片申请
	TRUNCATE ld_cardapply;
	TRUNCATE ld_cardapplyscf;

	-- 3.32 删除借款申请
	TRUNCATE ld_loanapply;
	TRUNCATE ld_loanapplyscf;

	-- 3.33 删除日程、邮件、提醒
	TRUNCATE ld_activity;
	TRUNCATE ld_activitycf;
	TRUNCATE ld_activity_reminder;
	TRUNCATE ld_activitycf;
	TRUNCATE ld_tmpreminder;
	TRUNCATE ld_reminds;
	TRUNCATE ld_reminds_weixin;

	-- 3.34 删除公海操作操作日志
	TRUNCATE ld_logpublicaccount;

	-- 3.35 删除销售目标
	TRUNCATE ld_salestarget;

	-- 3.36 删除服务到期信息
	TRUNCATE ld_maxservicedate;

	-- 3.37 删除销售阶段变化历史
	TRUNCATE ld_potential;
	TRUNCATE ld_potentialscf;
    TRUNCATE ld_potentialsdetail;
    TRUNCATE ld_potentialsdetailscf;
	TRUNCATE ld_potstagehistory;

	-- 3.38 删除附件及相关信息
	TRUNCATE ld_attachments;
	TRUNCATE ld_attachmentsforbills;
	TRUNCATE ld_attachmentsforbillscf;
	TRUNCATE ld_attachmentsforbillsdetails;
	TRUNCATE ld_attachmentsforsign;
	TRUNCATE ld_salesmanattachmentsrel;
	TRUNCATE ld_seattachmentsrel;
	TRUNCATE ld_attachments_tempsave;

	-- 3.39 删除签到历史记录
	TRUNCATE ld_singin;

	-- 3.40 删除其他必要的数据
	TRUNCATE ld_tabshare;
	TRUNCATE ld_approvelog;
	UPDATE ld_approvelog_seq SET id=1;
	UPDATE ld_crmentity_seq SET id=IFNULL((SELECT MAX(crmid) FROM ld_crmentity),0);
    
	-- 3.41 删除除 admin 外用户，并重置 admin 密码为空
	UPDATE ld_users 
	SET 
		first_name=NULL,
		last_name='系统管理员',
		real_name=NULL,
		reports_to_id=NULL,
		is_admin='on',
		currency_id=1,
		description=NULL,
		phone_home=NULL,
		phone_mobile=NULL,
		phone_work=NULL,
		phone_other=NULL,
		phone_fax=NULL,
		email1=NULL,
		email2=NULL,
		secondaryemail=NULL,
		`status` = 'Active',
		`signature` = '',
		`address_street` = '',
		`address_city` = '',
		`address_state` = '',
		`address_country` = '',
		`address_postalcode` = '',
		`namedays` = NULL,
		`workdays` = NULL,
		`weekstart` = NULL,
		`date_format` = 'yyyy-mm-dd',
		`hour_format` = '',
		`start_hour` = '',
		`end_hour` = '',
		`activity_view` = '',
		`lead_view` = '',
		`imagename` = '',
		`deleted` = '0',
		`theme` = 'softed',
		`language` = NULL,
		`time_zone` = 'Asia/Brunei',
		`currency_grouping_pattern` = '',
		`currency_decimal_separator` = '',
		`currency_grouping_separator` = '',
		`currency_symbol_placement` = '',
		wx_openid=NULL,
		hire_date=NULL,
		wx_openid=NULL,
		hantian_exten=NULL,
		dingtalk_userid=NULL,
		yunzhijia_openid=NULL,
		yunzhijia_wbuserid=NULL,
		bangwo8_supportname=NULL,
		jw_user=NULL,
		sopho_exten=NULL,
		sopho_queue=NULL,
		wx_userid_old=NULL,
		yxc_uid=NULL,
		user_password='$1$ad$peilFE10wX.4b0aIm7/.t/',
		user_hash='d41d8cd98f00b204e9800998ecf8427e',
		confirm_password=user_password
	WHERE id=1;

	DELETE FROM ld_usersscf WHERE id>1;
	DELETE FROM ld_users WHERE id>1;
  UPDATE ld_users SET phone_mobile=NULL,email1=NULL,email2=NULL,last_name='系统管理员' WHERE id=1;

	-- 删除自定义表单
	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name` IN ('CustomForm01','CustomForm10','CustomForm21','CustomForm25')) THEN 
		TRUNCATE ld_customform01;
		TRUNCATE ld_customform01scf;
		TRUNCATE ld_customform02;
		TRUNCATE ld_customform02scf;
		TRUNCATE ld_customform03;
		TRUNCATE ld_customform03scf;
		TRUNCATE ld_customform04;
		TRUNCATE ld_customform04scf;
		TRUNCATE ld_customform05;
		TRUNCATE ld_customform05scf;

		TRUNCATE ld_customform06;
		TRUNCATE ld_customform06scf;
		TRUNCATE ld_customform07;
		TRUNCATE ld_customform07scf;
		TRUNCATE ld_customform08;
		TRUNCATE ld_customform08scf;
		TRUNCATE ld_customform09;
		TRUNCATE ld_customform09scf;
		TRUNCATE ld_customform10;
		TRUNCATE ld_customform10scf;

		TRUNCATE ld_customform11;
		TRUNCATE ld_customform11scf;
		TRUNCATE ld_customform11detail;
		TRUNCATE ld_customform11detailscf;
		TRUNCATE ld_customform12;
		TRUNCATE ld_customform12scf;
		TRUNCATE ld_customform12detail;
		TRUNCATE ld_customform12detailscf;
		TRUNCATE ld_customform13;
		TRUNCATE ld_customform13scf;
		TRUNCATE ld_customform13detail;
		TRUNCATE ld_customform13detailscf;
		TRUNCATE ld_customform14;
		TRUNCATE ld_customform14scf;
		TRUNCATE ld_customform14detail;
		TRUNCATE ld_customform14detailscf;
		TRUNCATE ld_customform15;
		TRUNCATE ld_customform15scf;
		TRUNCATE ld_customform15detail;
		TRUNCATE ld_customform15detailscf;

		TRUNCATE ld_customform16;
		TRUNCATE ld_customform16scf;
		TRUNCATE ld_customform16detail;
		TRUNCATE ld_customform16detailscf;
		TRUNCATE ld_customform17;
		TRUNCATE ld_customform17scf;
		TRUNCATE ld_customform17detail;
		TRUNCATE ld_customform17detailscf;
		TRUNCATE ld_customform18;
		TRUNCATE ld_customform18scf;
		TRUNCATE ld_customform18detail;
		TRUNCATE ld_customform18detailscf;
		TRUNCATE ld_customform19;
		TRUNCATE ld_customform19scf;
		TRUNCATE ld_customform19detail;
		TRUNCATE ld_customform19detailscf;
		TRUNCATE ld_customform20;
		TRUNCATE ld_customform20scf;
		TRUNCATE ld_customform20detail;
		TRUNCATE ld_customform20detailscf;

		TRUNCATE ld_customform21;
		TRUNCATE ld_customform21scf;
		TRUNCATE ld_customform21detail;
		TRUNCATE ld_customform21detailscf;
		TRUNCATE ld_customform22;
		TRUNCATE ld_customform22scf;
		TRUNCATE ld_customform22detail;
		TRUNCATE ld_customform22detailscf;
		TRUNCATE ld_customform23;
		TRUNCATE ld_customform23scf;
		TRUNCATE ld_customform23detail;
		TRUNCATE ld_customform23detailscf;
		TRUNCATE ld_customform24;
		TRUNCATE ld_customform24scf;
		TRUNCATE ld_customform24detail;
		TRUNCATE ld_customform24detailscf;
		TRUNCATE ld_customform25;
		TRUNCATE ld_customform25scf;
		TRUNCATE ld_customform25detail;
		TRUNCATE ld_customform25detailscf;
    END IF;
        
	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name` IN ('CustomForm26','CustomForm30','CustomForm40','CustomForm50')) THEN 
		TRUNCATE ld_customform26;
		TRUNCATE ld_customform26detail;
		TRUNCATE ld_customform26detailscf;
		TRUNCATE ld_customform26scf;
		TRUNCATE ld_customform27;
		TRUNCATE ld_customform27detail;
		TRUNCATE ld_customform27detailscf;
		TRUNCATE ld_customform27scf;
		TRUNCATE ld_customform28;
		TRUNCATE ld_customform28detail;
		TRUNCATE ld_customform28detailscf;
		TRUNCATE ld_customform28scf;
		TRUNCATE ld_customform29;
		TRUNCATE ld_customform29detail;
		TRUNCATE ld_customform29detailscf;
		TRUNCATE ld_customform29scf;
		TRUNCATE ld_customform30;
		TRUNCATE ld_customform30detail;
		TRUNCATE ld_customform30detailscf;
		TRUNCATE ld_customform30scf;
		TRUNCATE ld_customform31;
		TRUNCATE ld_customform31detail;
		TRUNCATE ld_customform31detailscf;
		TRUNCATE ld_customform31scf;
		TRUNCATE ld_customform32;
		TRUNCATE ld_customform32detail;
		TRUNCATE ld_customform32detailscf;
		TRUNCATE ld_customform32scf;
		TRUNCATE ld_customform33;
		TRUNCATE ld_customform33detail;
		TRUNCATE ld_customform33detailscf;
		TRUNCATE ld_customform33scf;
		TRUNCATE ld_customform34;
		TRUNCATE ld_customform34detail;
		TRUNCATE ld_customform34detailscf;
		TRUNCATE ld_customform34scf;
		TRUNCATE ld_customform35;
		TRUNCATE ld_customform35detail;
		TRUNCATE ld_customform35detailscf;
		TRUNCATE ld_customform35scf;
		TRUNCATE ld_customform36;
		TRUNCATE ld_customform36detail;
		TRUNCATE ld_customform36detailscf;
		TRUNCATE ld_customform36scf;
		TRUNCATE ld_customform37;
		TRUNCATE ld_customform37detail;
		TRUNCATE ld_customform37detailscf;
		TRUNCATE ld_customform37scf;
		TRUNCATE ld_customform38;
		TRUNCATE ld_customform38detail;
		TRUNCATE ld_customform38detailscf;
		TRUNCATE ld_customform38scf;
		TRUNCATE ld_customform39;
		TRUNCATE ld_customform39detail;
		TRUNCATE ld_customform39detailscf;
		TRUNCATE ld_customform39scf;
		TRUNCATE ld_customform40;
		TRUNCATE ld_customform40detail;
		TRUNCATE ld_customform40detailscf;
		TRUNCATE ld_customform40scf;
		TRUNCATE ld_customform41;
		TRUNCATE ld_customform41detail;
		TRUNCATE ld_customform41detailscf;
		TRUNCATE ld_customform41scf;
		TRUNCATE ld_customform42;
		TRUNCATE ld_customform42detail;
		TRUNCATE ld_customform42detailscf;
		TRUNCATE ld_customform42scf;
		TRUNCATE ld_customform43;
		TRUNCATE ld_customform43detail;
		TRUNCATE ld_customform43detailscf;
		TRUNCATE ld_customform43scf;
		TRUNCATE ld_customform44;
		TRUNCATE ld_customform44detail;
		TRUNCATE ld_customform44detailscf;
		TRUNCATE ld_customform44scf;
		TRUNCATE ld_customform45;
		TRUNCATE ld_customform45detail;
		TRUNCATE ld_customform45detailscf;
		TRUNCATE ld_customform45scf;
		TRUNCATE ld_customform46;
		TRUNCATE ld_customform46scf;

		-- TRUNCATE ld_customform47;
		-- TRUNCATE ld_customform47scf;
		TRUNCATE ld_customform48;
		TRUNCATE ld_customform48scf;
		-- TRUNCATE ld_customform49;
		-- TRUNCATE ld_customform49scf;
		-- TRUNCATE ld_customform50;
		-- TRUNCATE ld_customform50scf;
		-- TRUNCATE ld_customform51;
		-- TRUNCATE ld_customform51scf;
		-- TRUNCATE ld_customform52;
		-- TRUNCATE ld_customform52scf;
		-- TRUNCATE ld_customform53;
		-- TRUNCATE ld_customform53scf;
		TRUNCATE ld_customform54;
		TRUNCATE ld_customform54scf;
		TRUNCATE ld_customform55;
		TRUNCATE ld_customform55scf;
		-- TRUNCATE ld_customform56;
		-- TRUNCATE ld_customform56scf;
		-- TRUNCATE ld_customform57;
		-- TRUNCATE ld_customform57scf;
		-- TRUNCATE ld_customform58;
		-- TRUNCATE ld_customform58scf;
		TRUNCATE ld_customform59;
		TRUNCATE ld_customform59scf;
		-- TRUNCATE ld_customform60;
		-- TRUNCATE ld_customform60scf;
	END IF;
	
	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name` IN ('CustomForm60','CustomForm80','CustomForm90','CustomForm100')) THEN 
		TRUNCATE ld_customform60;
		TRUNCATE ld_customform60scf;
		-- TRUNCATE ld_customform61;
		-- TRUNCATE ld_customform61scf;
		TRUNCATE ld_customform62;
		TRUNCATE ld_customform62scf;
		TRUNCATE ld_customform63;
		TRUNCATE ld_customform63scf;
		TRUNCATE ld_customform64;
		TRUNCATE ld_customform64scf;
		TRUNCATE ld_customform65;
		TRUNCATE ld_customform65scf;
		TRUNCATE ld_customform66;
		TRUNCATE ld_customform66scf;
		TRUNCATE ld_customform67;
		TRUNCATE ld_customform67scf;
		TRUNCATE ld_customform68;
		TRUNCATE ld_customform68scf;
		TRUNCATE ld_customform69;
		TRUNCATE ld_customform69scf;
		TRUNCATE ld_customform70;
		TRUNCATE ld_customform70scf;
		TRUNCATE ld_customform71;
		TRUNCATE ld_customform71scf;
		TRUNCATE ld_customform72;
		TRUNCATE ld_customform72scf;
		TRUNCATE ld_customform73;
		TRUNCATE ld_customform73scf;
		TRUNCATE ld_customform74;
		TRUNCATE ld_customform74scf;
		TRUNCATE ld_customform75;
		TRUNCATE ld_customform75scf;
		TRUNCATE ld_customform76;
		TRUNCATE ld_customform76scf;
		TRUNCATE ld_customform77;
		TRUNCATE ld_customform77scf;
		TRUNCATE ld_customform78;
		TRUNCATE ld_customform78scf;
		TRUNCATE ld_customform79;
		TRUNCATE ld_customform79scf;
		TRUNCATE ld_customform80;
		TRUNCATE ld_customform80scf;
		TRUNCATE ld_customform81;
		TRUNCATE ld_customform81scf;
		TRUNCATE ld_customform82;
		TRUNCATE ld_customform82scf;
		TRUNCATE ld_customform83;
		TRUNCATE ld_customform83scf;
		TRUNCATE ld_customform84;
		TRUNCATE ld_customform84scf;
		TRUNCATE ld_customform85;
		TRUNCATE ld_customform85scf;
		TRUNCATE ld_customform86;
		TRUNCATE ld_customform86scf;
		TRUNCATE ld_customform87;
		TRUNCATE ld_customform87scf;
		TRUNCATE ld_customform88;
		TRUNCATE ld_customform88scf;
		TRUNCATE ld_customform89;
		TRUNCATE ld_customform89scf;
		TRUNCATE ld_customform90;
		TRUNCATE ld_customform90scf;
		TRUNCATE ld_customform91;
		TRUNCATE ld_customform91scf;
		TRUNCATE ld_customform92;
		TRUNCATE ld_customform92scf;
		TRUNCATE ld_customform93;
		TRUNCATE ld_customform93scf;
		TRUNCATE ld_customform94;
		TRUNCATE ld_customform94scf;
		TRUNCATE ld_customform95;
		TRUNCATE ld_customform95scf;
		TRUNCATE ld_customform96;
		TRUNCATE ld_customform96scf;
		TRUNCATE ld_customform97;
		TRUNCATE ld_customform97scf;
		TRUNCATE ld_customform98;
		TRUNCATE ld_customform98scf;
		TRUNCATE ld_customform99;
		TRUNCATE ld_customform99scf;
		TRUNCATE ld_customform100;
		TRUNCATE ld_customform100scf;
	END IF;

    -- 删除灵当CRM小程序配置
    UPDATE ld_wx_config SET para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='wechat_miniprogram_setting';
    UPDATE ld_wx_config SET para_content=NULL,time=NULL,datetime=NULL,para_one=NULL WHERE `name`='dingtalk_setting';
    UPDATE ld_wx_config SET para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='checkin_monthly';
    UPDATE ld_wx_config SET para_content=NULL,para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='ordermp_bindtype';
    UPDATE ld_wx_config SET para_content=NULL,para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='weixinmp_bindtype';
    UPDATE ld_wx_config SET para_content=NULL,para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='channelcode_setting';
		UPDATE ld_wx_config SET para_content=NULL,para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='electronic_signature';
		UPDATE ld_wx_config SET para_content=NULL,para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='wechatsession_setting';
		UPDATE ld_wx_config SET para_content=NULL,para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='wechat_miniprogram_setting';
		UPDATE ld_wx_config SET para_content=NULL,para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='dial_record';
		UPDATE ld_wx_config SET para_content=NULL,para_one=NULL,para_two=NULL,para_three=NULL WHERE `name`='wxselfbuiltapp_setting';
			
    DELETE FROM tmp_date WHERE date<DATE_FORMAT(CURDATE(),'%Y-01-01');
    
    TRUNCATE ld_vendorcontacts;
    TRUNCATE ld_vendorcontactscf;
    
    TRUNCATE ld_purchaseinquiryorder;
    TRUNCATE ld_purchaseinquiryordercf;
    TRUNCATE ld_purchaseinquiryorderdetail;
    TRUNCATE ld_purchaseinquiryorderdetailscf;
    
    TRUNCATE ld_putcash;
    TRUNCATE ld_putcashscf;
    TRUNCATE ld_cashdeposit;
    TRUNCATE ld_cashdepositscf;
    
    TRUNCATE ld_faq;
    TRUNCATE ld_faqscf;

	TRUNCATE ld_notes;
	TRUNCATE ld_documenttemplates;
	-- TRUNCATE ld_documentscf;


	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_expensebudget') THEN
		TRUNCATE TABLE ld_expensebudget;
		TRUNCATE TABLE ld_expensebudgetscf;
		TRUNCATE TABLE ld_expensebudgetdetail;
		TRUNCATE TABLE ld_expensebudgetdetailscf;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='changelog_expense') THEN
		TRUNCATE TABLE changelog_expense;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='changelog_form13') THEN
		TRUNCATE TABLE changelog_form13;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='changelog_project') THEN
		TRUNCATE TABLE changelog_project;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='changelog_purchaseorder') THEN
		TRUNCATE TABLE changelog_purchaseorder;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='00_stylechangelog') THEN
		TRUNCATE TABLE 00_stylechangelog;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_logpublicleads') THEN
		TRUNCATE TABLE ld_logpublicleads;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_loginerror') THEN
		TRUNCATE TABLE ld_loginerror;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_userlogincheck') THEN
		TRUNCATE TABLE ld_userlogincheck;
		TRUNCATE TABLE ld_userlogincodeentries;
		TRUNCATE TABLE ld_userloginhistroy;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wechatuser') THEN
		TRUNCATE ld_wechatuser;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wechatuserscf') THEN
		TRUNCATE ld_wechatuserscf;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wechatuser_sign') THEN
		TRUNCATE ld_wechatuser_sign;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wx_user_log') THEN
		TRUNCATE TABLE ld_wx_user_log;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='auto_addcashbill_form12') THEN
		TRUNCATE TABLE auto_addcashbill_form12;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='auto_addcashbill_orderid') THEN
		TRUNCATE TABLE auto_addcashbill_orderid;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='auto_addcashbill_servicecontracts') THEN
		TRUNCATE TABLE auto_addcashbill_servicecontracts;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='auto_ele_info') THEN
		TRUNCATE TABLE auto_ele_info;
		TRUNCATE TABLE auto_ele_user;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='auto_resetinfo_cashbilldeleted') THEN
		TRUNCATE TABLE auto_resetinfo_cashbilldeleted;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='autoshare_log') THEN
		TRUNCATE TABLE autoshare_log;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_reminds_accepted') THEN
		TRUNCATE TABLE ld_reminds_accepted;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_searchhistory') THEN
		TRUNCATE TABLE ld_searchhistory;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wechatsession') THEN
		TRUNCATE TABLE ld_wechatsession;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_detailtracker_basic') THEN
		TRUNCATE TABLE ld_detailtracker_basic;
		TRUNCATE TABLE ld_detailtracker_detail;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wx_users') THEN
		TRUNCATE TABLE ld_wx_users;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_articles') THEN
		TRUNCATE ld_articles;
		TRUNCATE ld_articlesscf;
		TRUNCATE ld_articles_appid_set;
	END IF;
	
	DELETE FROM ld_user2mergefields WHERE userid NOT IN (SELECT id FROM ld_users);
	DELETE FROM ld_users2group WHERE userid NOT IN (SELECT id FROM ld_users);
	DELETE FROM ld_scoperhigher WHERE userid NOT IN (SELECT id FROM ld_users);
	DELETE FROM ld_userscoperhigher WHERE userid NOT IN (SELECT id FROM ld_users);

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_user2mergefields') THEN
		DELETE FROM ld_user2mergefields WHERE userid NOT IN (SELECT id FROM ld_users);
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_customecharts2user') THEN
		DELETE FROM ld_customecharts2user WHERE userid NOT IN (SELECT id FROM ld_users);
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_cloud_users') THEN
		TRUNCATE TABLE ld_cloud_users;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='saascrm_authfo') THEN
		TRUNCATE TABLE saascrm_authfo;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='saascrm_changehistory') THEN
		TRUNCATE TABLE saascrm_changehistory;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='saascrm_login') THEN
		TRUNCATE TABLE	saascrm_login;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='saaskh001_authinfo') THEN
		TRUNCATE TABLE	saaskh001_authinfo;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='00_changedangkou_log') THEN
		TRUNCATE TABLE	00_changedangkou_log;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_weixin_msg') THEN
		TRUNCATE TABLE	ld_weixin_msg;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_temp_openid_list') THEN
		TRUNCATE TABLE	ld_temp_openid_list;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wangcan') THEN
		TRUNCATE TABLE	ld_wangcan;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wechatexternalid') THEN
		TRUNCATE TABLE	ld_wechatexternalid;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wx_checkin') THEN
		TRUNCATE TABLE	ld_wx_checkin;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_worksheetlog') THEN
		TRUNCATE TABLE	ld_worksheetlog;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_bankaccountset_picklist') THEN
		TRUNCATE TABLE ld_bankaccountset_picklist;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_questionnaire') THEN
		TRUNCATE TABLE ld_questionnaire;
		TRUNCATE TABLE ld_questionnairescf;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_socialpromotion') THEN
		TRUNCATE TABLE ld_socialpromotion;
		TRUNCATE TABLE ld_socialpromotionscf;
		TRUNCATE TABLE ld_socialpromotionformcustom;
		TRUNCATE TABLE ld_socialpromotionformfixed;
		TRUNCATE TABLE ld_socialpromotionformviewlist;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_workflowdatalog') THEN
		TRUNCATE TABLE ld_workflowdatalog;
	END IF;

	DELETE FROM ld_profile2field WHERE profileid NOT IN (SELECT profileid FROm ld_profile);
	DELETE FROM ld_profile2tab WHERE profileid NOT IN (SELECT profileid FROm ld_profile);
	
	TRUNCATE TABLE ld_appsystem;
	
	-- 设置开启外键约束
	SET FOREIGN_KEY_CHECKS=1;
	SET @disable_triggers=NULL;
     
	UPDATE ld_organizationdetails SET logoname='logo_big_white.png',small_logoname='logo_mini_1.png';
	UPDATE ld_customview SET userid=1 WHERE userid NOT IN (SELECT id FROM ld_users);

	UPDATE ld_approvestep SET approvevalue=1 WHERE approvevalue>1;
	
	DELETE FROM ld_usercolor WHERE id NOT IN (SELECT id FROM ld_users);
	
	UPDATE ld_wx_config 
	SET para_content = '{"bindtype":"Contacts","allowedtocreate":"yes","useverificationcode":"no","appid":"wxb4cc43e5a12f5687","secret":"991ee9c028da1da860a44d7a0767b82e"}' 
	WHERE `name`="weixinmp_bindtype";
	
	TRUNCATE TABLE ld_fileoperationlog;
	DELETE FROM ld_setscoperhigher WHERE userid NOT IN (SELECT id FROM ld_users);

	TRUNCATE TABLE ld_receipts;
	
end ;;
DELIMITER ;

DROP PROCEDURE IF EXISTS `eee`;
DROP TABLE IF EXISTS acc;

CALL Initial_CRM_Account1();
DROP PROCEDURE IF EXISTS `Initial_CRM_Account1`;
DELIMITER ;