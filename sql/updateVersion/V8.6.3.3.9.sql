update ld_desk set fieldlabel='确定要删除所有搜索历史吗？' where labelbol = 'menudeletesearchhistorytip' and labeltype='jspop' and languagetype = 'zh';
update ld_desk set fieldlabel='Are you sure you want to delete all search history?' where labelbol = 'menudeletesearchhistorytip' and labeltype='jspop' and languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHUHUABASICEDITION','助华基础版','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHUHUABASICEDITION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHUHUABASICEDITION',"Zhuhua Basic Edition",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHUHUABASICEDITION' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHUHUAENHANCEDEDITION','助华增强版','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHUHUAENHANCEDEDITION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHUHUAENHANCEDEDITION',"Zhuhua Enhanced Edition",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHUHUAENHANCEDEDITION' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHUHUASERVICEENHANCEDEDITION','助华服务增强版','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHUHUASERVICEENHANCEDEDITION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHUHUASERVICEENHANCEDEDITION',"Zhuhua Service Enhanced Edition",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHUHUASERVICEENHANCEDEDITION' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEFILLFORMAT','请填写允许上传的文件格式，如：jpg，png','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASEFILLFORMAT' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEFILLFORMAT','Please fill in the allowed file formats for uploading, such as jpg, png, png','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASEFILLFORMAT' and labeltype='jspop' and languagetype='en');
delimiter;

set @tabid=(select tabid from ld_tab where `name`='ModComments');
update ld_field set tablename = 'ld_modcomments' where tabid=@tabid and fieldname='image' and uitype=69;
call AddColumn('ld_modcomments','image','text','','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTEMAIL','请选择Email','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASESELECTEMAIL' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTEMAIL',"Please select the Email",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASESELECTEMAIL' and labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = 'Sensitive Information - Data encryption' where labeltype = 'fixedstr' and labelbol = 'SensitiveAllEncrypted' and languagetype = 'en';
update ld_desk set fieldlabel = '敏感信息-数据加密' where labeltype = 'fixedstr' and labelbol = 'SensitiveAllEncrypted' and languagetype = 'zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','commongroup','常用分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='commongroup' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','commongroup','Common Group','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='commongroup' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ungrouped','未分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ungrouped' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ungrouped','Ungrouped','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ungrouped' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','deletegroup','删除‘组名’，删除后无法恢复','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='deletegroup' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','deletegroup','Delete ‘group name’, can‘t recover after deletion','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='deletegroup' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Blockingdeletionofgroups','请先移除分组中所有的分类，再进行删除操作','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Blockingdeletionofgroups' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Blockingdeletionofgroups','Please remove all the categories in the group before deleting.','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Blockingdeletionofgroups' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OPERATION','操作','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OPERATION' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OPERATION','Operation','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OPERATION' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Subgroups','所属分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Subgroups' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Subgroups','Subgroups','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Subgroups' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Collectionsincommonuse','收藏常用','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Collectionsincommonuse' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Collectionsincommonuse','Collections in common use','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Collectionsincommonuse' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','management','管理','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='management' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','management','management','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='management' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Searchforgroupsorcategories','搜索分组或分类','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Searchforgroupsorcategories' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Searchforgroupsorcategories','Search for groups or categories','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Searchforgroupsorcategories' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CancelFavorites','取消收藏','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CancelFavorites' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CancelFavorites','Cancel Favorites','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CancelFavorites' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MANAGEMENTGROUPING','管理分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MANAGEMENTGROUPING' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MANAGEMENTGROUPING','Management Grouping','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MANAGEMENTGROUPING' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWGROUPING','新建分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWGROUPING' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWGROUPING','New Grouping','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWGROUPING' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','POPUPGROUPNAME','分组名称','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='POPUPGROUPNAME' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','POPUPGROUPNAME','Group Name','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='POPUPGROUPNAME' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOGrouping','暂无任何分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NOGrouping' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOGrouping','There are no subgroups','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NOGrouping' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWCATEGORIESTIPS','新建的分类需要被授权至少一个分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWCATEGORIESTIPS' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWCATEGORIESTIPS','New categories need to be authorized for at least one grouping','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWCATEGORIESTIPS' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOGrouping','暂无任何分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOGrouping' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOGrouping','There are no subgroups','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOGrouping' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GROUPNAMENOTEMPTY','分组名称不得为空','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPNAMENOTEMPTY' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GROUPNAMENOTEMPTY','Group names must not be empty','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPNAMENOTEMPTY' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GROUPSTOBEDELETED','要删除的分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPSTOBEDELETED' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GROUPSTOBEDELETED','Groups to be deleted','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPSTOBEDELETED' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETEGROUPING','删除分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEGROUPING' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETEGROUPING','Delete Grouping','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEGROUPING' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONVERTCATEGORIEDTOGROUP','转换分类到分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CONVERTCATEGORIEDTOGROUP' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONVERTCATEGORIEDTOGROUP','Convert Categories to Groups','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CONVERTCATEGORIEDTOGROUP' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETASMYCOMMON','设为我的常用分类','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SETASMYCOMMON' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETASMYCOMMON','Set as my favorite category','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SETASMYCOMMON' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customviewgroup` (
    `groupid`  int(19) NOT NULL AUTO_INCREMENT ,
    `group_name`  varchar(100) NULL COMMENT '分组名称' ,
    `entity_type`  varchar(50) NULL COMMENT '模块类别' ,
    `sequence`  int(19) NULL COMMENT '排序' ,
    `is_dafault`  varchar(10) NOT NULL DEFAULT 'no' COMMENT '是否默认分组' ,
    `created_id`  int(11) NULL COMMENT '创建人id' ,
    `modified_by`  int(11) NULL COMMENT '修改人id' ,
    `created_time`  datetime DEFAULT CURRENT_TIMESTAMP ,
    `modified_time`  datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
    PRIMARY KEY (`groupid`)
    ) ENGINE = INNODB ;
delimiter;


call AddColumn('ld_customview','groupid','INT','19',NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHTITLE','的搜索结果','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHTITLE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHTITLE','search result','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHTITLE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDTOCOMMON','设为常用','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDTOCOMMON' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDTOCOMMON','Add To Common','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDTOCOMMON' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITCATEGORY','编辑分类','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EDITCATEGORY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITCATEGORY','Edit Category','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EDITCATEGORY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel='，删除后无法恢复' where languagetype='zh' and labelbol='deletegroup' and Labeltype='jspop';
update ld_desk set fieldlabel=', can‘t recover after deletion' where languagetype='en' and labelbol='deletegroup' and Labeltype='jspop';
delimiter;

update ld_desk set fieldlabel='可以看到其他成员单据列表的情况下是否有权限查看其他成员的单据详情' where languagetype='zh' and labelbol='viewothers' and labeltype='fixedstr';
update ld_desk set fieldlabel="Whether one has the permission to view the details of other members' documents when they can see the list of documents from other members" where languagetype='en' and labelbol='viewothers' and labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='可以看到"负责人"是其他成员的单据列表的情况下，是否有权限仅查看"创建人"字段是自己的单据详情' where languagetype='zh' and labelbol='ViewCreateMeTip' and labeltype='fixedstr';
update ld_desk set fieldlabel='Whether one has the permission to view the details of documents where the "Person in Charge" is another member, but the "Creator" field belongs to oneself' where languagetype='en' and labelbol='ViewCreateMeTip' and labeltype='fixedstr';
delimiter;

UPDATE ld_signout SET signout_type = 'signout' WHERE signout_type IS NULL;
UPDATE ld_singin SET signout_type = 'signout' WHERE signout_type IS NULL and signout_id > 0;
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
UPDATE ld_signout 
INNER JOIN ld_singin ON ld_signout.signoutid = ld_singin.signout_id
INNER JOIN ld_option_module ON ld_singin.tabid = ld_option_module.option_tabid 
SET ld_signout.signout_type = 'supsign',ld_singin.signout_type = 'supsign'
WHERE ld_option_module.tabid = @tabid and ld_signout.signout_distance > ld_option_module.allowable_distance;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NODOWNLOADPREVIEWPREMISSION','没有下载预览权限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NODOWNLOADPREVIEWPREMISSION' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NODOWNLOADPREVIEWPREMISSION','No download preview permission','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NODOWNLOADPREVIEWPREMISSION' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel='选择单选用户字段' where labelbol='SELECTUSER' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Select Single Choice User Field' where labelbol='SELECTUSER' and labeltype='fixedstr' and languagetype='en';
delimiter;
-- 2024-08-16

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

UPDATE ld_version SET old_version='V8.6.3.3.9',current_version='V8.6.3.3.9',remark='V8.6.3.3.9-20240816',wx_version='V8.6.4.0';
delimiter;