select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select usereportid into @usereportid from ld_usereport where parent_id=0 and `name` = 'SalesReport';
select Parent_id,sequence,reporttype into @Parent_id,@sequence,@reporttype from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereport set sequence = sequence + 1000 where Parent_id = @Parent_id and sequence > @sequence;
insert into ld_usereport(`name`,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype,pagewidthpercent,presence,setype)
select 'CashBillSum_Outboundorder','应收款统计表_按{$OutboundOrder}统计',@tabid,1,1,1,@usereportid,@sequence+1,@reporttype,100,0,'OutboundOrder' from DUAL
where not exists(select 1 from ld_usereport where `name` = 'CashBillSum_Outboundorder');
set @i=0;
update ld_usereport set sequence=(@i:=@i+1) where parent_id = @usereportid order by sequence;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CashBillSum_Outboundorder',"应收款统计表_按 {$OutboundOrder.OutboundOrder}统计",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CashBillSum_Outboundorder' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CashBillSum_Outboundorder',"Statistics of Receivables Acc To  {$OutboundOrder.OutboundOrder}",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CashBillSum_Outboundorder' and Labeltype='fixedstr');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Outboundorder';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_assigned_user_id:V',1,1,'ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_销售负责人:V','ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_Assigned to:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_assigned_user_id:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:groupname:groupname:OutboundOrder_groupname:V',2,1,'ld_outboundorder:groupname:groupname:OutboundOrder_部门:V','ld_outboundorder:groupname:groupname:OutboundOrder_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:groupname:groupname:OutboundOrder_groupname:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:out_no:out_no:OutboundOrder_Out no:V',3,1,'ld_outboundorder:out_no:out_no:OutboundOrder_出库编号:V','ld_outboundorder:out_no:out_no:OutboundOrder_Out No:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:out_no:out_no:OutboundOrder_Out no:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D',4,1,'ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D','ld_outboundorder:outdate:outdate:OutboundOrder_Outdate:D' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:accountid:account_id:OutboundOrder_Account Name:I',5,1,'ld_outboundorder:accountid:account_id:OutboundOrder_出库_客户名称:I','ld_outboundorder:accountid:account_id:OutboundOrder_AccountName:I' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:accountid:account_id:OutboundOrder_Account Name:I');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:presence:presence:OutboundOrder_Status:V',6,1,'ld_outboundorder:presence:presence:OutboundOrder_出库_出库状态:V','ld_outboundorder:presence:presence:OutboundOrder_Status:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:presence:presence:OutboundOrder_Status:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_Total:N',7,1,'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_合计:N','ld_outboundorder:total:hdnGrandTotal:OutboundOrder_Total:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_Total:N');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N',8,1,'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_已收金额:N','ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBill Amount:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N',9,1,'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_应收款余额:N','ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_Payment Balance:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Outboundorder';
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D','thisstartmonth~thisendmonth',1 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D');
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_accountoutboundorder:accountname:account_id:OutboundOrder_Account Name:I','',2 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_accountoutboundorder:accountname:account_id:OutboundOrder_Account Name:I');
delimiter;

ALTER TABLE ld_remindcvadvfilter MODIFY comparator VARCHAR(100) NOT NULL DEFAULT '';
-- 2018-11-28

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

update ld_version set old_version='V7.5.5.1',current_version='V7.5.5.1',remark='V7.5.5sp1-20181128';
delimiter;