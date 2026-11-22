SET @my_presence=1;
SET @my_tabid=37;
SET @my_relmodule='OutboundOrder';
SET @my_reltabid=(SELECT tabid FROM ld_tab WHERE `name`=@my_relmodule LIMIT 1);
SET @my_seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@my_tabid);
SET @my_actions='add';
SET @my_reltype='entitytype_datacategory_sql';
SET @my_relcoltable='tmpsourcedetail.id';
SET @my_buttonstatus='yes';


SET @my_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,buttonstatus)
SELECT @my_id+1,@my_tabid,@my_reltabid,CONCAT('get_',LOWER(@my_relmodule)),@my_seq,@my_relmodule,@my_presence,@my_actions,0,4,@my_reltype,@my_relcoltable,0,@my_buttonstatus FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@my_tabid AND related_tabid=@my_reltabid);

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

UPDATE ld_servicecontracts a
LEFT JOIN  (
	SELECT
		servicecontractsid,
		COUNT(1) AS qty
	FROM ld_troubletickets
	WHERE deleted=0
		AND approvestatus<>'已拒绝'
	GROUP BY servicecontractsid
) b ON b.servicecontractsid=a.servicecontractsid
SET a.service_units=IFNULL(b.qty,0)
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=6 AND columnname='service_units');
delimiter;
-- 2020-04-13

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

UPDATE ld_version SET old_version='V7.9.9.15',current_version='V7.9.9.15',remark='V7.9.9.15-20200317',wx_version='V8.0.0.6';
delimiter;