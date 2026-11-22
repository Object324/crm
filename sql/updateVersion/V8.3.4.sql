update ld_desk set fieldlabel="只统计审批通过的{$CashBill.CashBill}" where labelbol = 'onlyshowapprovecashbill' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
update ld_desk set fieldlabel="只统计审批通过的{$HelpDesk.HelpDesk}" where  labelbol = 'onlyshowapproveservicebill' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
update ld_desk set fieldlabel="只统计审批通过的{$ServiceContracts.ServiceContracts}" where  labelbol = 'onlyshowapproveservicecontract' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N', 1, 1, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N', 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N' );

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N', 1, 1, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N', 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N');

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同金额:N';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同收款金额:N';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_totalmoney:N', 1, 1, 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同收款金额:N', 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_totalmoney:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同收款金额:N');
delimiter;


update ld_desk set fieldlabel="只统计审批通过的{$CashBill.CashBill}" where labelbol = 'onlyshowapprovecashbill' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
update ld_desk set fieldlabel="只统计审批通过的{$HelpDesk.HelpDesk}" where  labelbol = 'onlyshowapproveservicebill' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
update ld_desk set fieldlabel="只统计审批通过的{$ServiceContracts.ServiceContracts}" where  labelbol = 'onlyshowapproveservicecontract' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N', 1, 1, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N', 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N' );

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N', 1, 1, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N', 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N');

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同金额:N';
delete from ld_usereportcolumns where Usereportid =@id AND realcolumns = 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同收款金额:N';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_totalmoney:N', 1, 1, 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同收款金额:N', 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_totalmoney:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同收款金额:N');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'Theamountofdepartmentalcashbillfrom', 'The amount of departmental service contract from', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_desk WHERE
			labelbol = 'Theamountofdepartmentalcashbillfrom' AND Labeltype = 'fixedstr' AND languagetype = 'en'
	);

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'Theamountofdepartmentalcashbillfrom', '部门服务合同收款额从', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_desk WHERE
			labelbol = 'Theamountofdepartmentalcashbillfrom' AND Labeltype = 'fixedstr' AND languagetype = 'zh'
	);

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'Theamountofdepartmentalcashbillto', 'The amount of departmental service contract to', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_desk WHERE
			labelbol = 'Theamountofdepartmentalcashbillto' AND Labeltype = 'fixedstr' AND languagetype = 'en'
	);

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'Theamountofdepartmentalcashbillto', '部门服务合同收款额到', 'fixedstr'
FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'Theamountofdepartmentalcashbillto' AND Labeltype = 'fixedstr' AND languagetype = 'zh');

select tabid into @tabid from ld_tab where name='WechatSession';
update ld_relatedlists set related_tabid=@tabid  where actions='add' and name='get_wechatsession';
delimiter;
-- 2020-12-08


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

UPDATE ld_version SET old_version='V8.3.4',current_version='V8.3.4',remark='V8.3.4-20201208',wx_version='V8.3.4';
delimiter;