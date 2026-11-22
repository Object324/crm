select home_sequence into @home_sequence from ld_dashboard_app where name='Salesfunnel';
update ld_dashboard_app set home_sequence=home_sequence+2 where home_sequence > @home_sequence;
update ld_dashboard_app set home_sequence=@home_sequence+1,home_presence='yes' where name='Accountleadsource' ;
update ld_dashboard_app set home_sequence=@home_sequence+2 ,home_presence='yes' where name='Accountaccounttype' ;
set @i=0;
update ld_dashboard_app set home_sequence=(@i:=@i+1) where home_presence='yes' order by home_sequence asc;
delimiter;

create table if not exists `ld_mobile_report_user_set`(
  `id` int(19) auto_increment primary key comment '移动端报表个人用户显示设置主键',
  `userid` int(19)  comment '用户ID',
  `tabid` int(19)  comment '报表ID',
  `tab_tablename` varchar(100) comment '类型'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;
-- 2019-11-15

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

UPDATE ld_version SET old_version='V7.9.6',current_version='V7.9.6',remark='V7.9.6-20191115',wx_version='V7.9.6';
delimiter;