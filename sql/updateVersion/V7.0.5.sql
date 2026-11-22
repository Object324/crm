DROP PROCEDURE IF EXISTS `ldcrm_update_approvestep_sequence`;
delimiter ||
CREATE  PROCEDURE `ldcrm_update_approvestep_sequence`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	
	DECLARE Mycur CURSOR FOR 
		SELECT 
			b.approveid
		FROM ld_approve a
		INNER JOIN ld_approvestep b ON a.id=b.approveid
		GROUP BY b.approveid,b.sequence
		HAVING count(1)>1;


	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;
	OPEN Mycur;
	FETCH Mycur INTO tmp_id;
	WHILE (tmp_id IS NOT NULL) DO
		SET @i=0;
		UPDATE ld_approvestep SET sequence=(@i:=@i+1) WHERE approveid=tmp_id ORDER BY sequence,approveid;
		FETCH Mycur INTO tmp_id;
	END WHILE;
	
	CLOSE Mycur;
	
end ||
delimiter;

CALL ldcrm_update_approvestep_sequence();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_approvestep_sequence`;
delimiter;
-- 2017-07-05

update ld_tranlabel set fieldlabel='单据分录明细中录入{$Products.Products}时只允许选择已审批的{$Products.Products}' 
	WHERE trantable='ld_systems_deploy' and Relateid=71 and languagetype='zh';
update ld_tranlabel set fieldlabel='单据分录明细中录入{$Products.Products}时允许选择无效的{$Products.Products}' 
	WHERE trantable='ld_systems_deploy' and Relateid=82 and languagetype='zh';
update ld_tranlabel set fieldlabel='{$SalesOrder.SalesOrder}中{$Products.Products}单价自动根据客户最近购买记录带出' 
	WHERE trantable='ld_systems_deploy' and Relateid=79 and languagetype='zh';
update ld_tranlabel set fieldlabel='单据分录明细中{$Products.Products}的价格和金额计算时的基准字段' 
	WHERE trantable='ld_systems_deploy' and Relateid=124 and languagetype='zh';

update ld_tranlabel set fieldlabel='课程名称' where tabid=37 and Relateid=540 and languagetype='zh' and fieldlabel='摘要'
	and exists (select 1 from ld_version where trade='edu');

update ld_field set allowhide='no',typeofdata='V~M' where tabid=37 and columnname='subject' and exists (select 1 from ld_version where trade='edu');

set @link_module = 'PaymentPlan';
set @uitype=264; 
insert into ld_ws_fieldtype(uitype,fieldtype) 
select @uitype,'reference' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype = @uitype and fieldtype = 'reference'); 
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype = @uitype and fieldtype = 'reference'; 

insert into ld_ws_referencetype(fieldtypeid,type) 
select @fieldtypeid,@link_module from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid = @fieldtypeid); 

select tabid into @tabid from ld_tab where `name`='PaymentPlan';
update ld_field set searchfieldtype=1 where tabid=@tabid;
update ld_field set searchfieldtype=0 where tabid=@tabid and columnname in ('paymentplan_no','accountid','plandate','periodtime','amount','entitytypeid');
delimiter;

select tabid into @tabid from ld_tab where name='servicecontracts';
update ld_field set typeofdata='NN~O~4,0' where tabid=@tabid and columnname in ('total_units','service_units');
delimiter;
-- 2017-07-07

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
delimiter;

update ld_version set old_version='V7.0.5',current_version='V7.0.5',remark='V7.0.5-20170707';
delimiter;