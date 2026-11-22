<?php
//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
  global $adb,$current_user;
  $id=$_REQUEST['id'];
  $module=getSalesEntityType($id);

  crm_load_class_file('cls_share','include/Functions/Share');
  $objShare = new cls_share();
  crm_load_class_file('MessageCorpconversation','WeiXinApp/modules/Reminds');
  $remind = new MessageCorpconversation();



//提取共享前的团队成员
if($id>0){
    $old_SharedUser = $objShare->getSelectedUser($id);
}
        
  $viewuserid=$_REQUEST['shareuserid'];
  $query='delete from ld_tabshare where crmid=? and viewuserid=?';
  $adb->pquery($query,array($id,$viewuserid));



//反写模块的团队成员值
$focus=CRMEntity::getInstance($module);
$tablename=$focus->table_name;
$tableindex=$focus->table_index;
$focus->retrieve_entity_info($id, $module);
$col_fields = $focus->column_fields;

//zkt 	0047410: （https://81mis.com/kfbcrm [^]）在相关信息的共享页签中点击取消共享（点击的地方见附件），在团队成员这个字段中数据没有取消选择。
$sql=" UPDATE  $tablename,(SELECT * FROM (
 SELECT 
  crmid,
  GROUP_CONCAT(viewuserid) AS teamownerid 
 FROM ld_tabshare 
 WHERE crmid =?
 GROUP BY crmid
) a
RIGHT JOIN (SELECT * FROM $tablename WHERE $tableindex=?) b ON b.$tableindex=a.crmid) AS c
SET $tablename.team_memberid=c.teamownerid,$tablename.modifiedtime = ? ,$tablename.modifiedby = ?
WHERE $tablename.$tableindex = c.$tableindex";

$adb->pquery($sql,array($id,$id,date('Y-m-d H:i:s'),$current_user->id));


        
if($id>0){
    //提取共享后团队成员信息
    $new_SharedUser = $objShare->getSelectedUser($id);
    //修改共享日志
    $time = date('Y-m-d H:i:s',time());$status = 0;
    $tr_id = $adb->getUniqueID('ld_modtracker_basic');
    $prevalue = $old_SharedUser;
    $postvalue = $new_SharedUser;
    $query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
					values(?,?,?,?,?,?);';
    $adb->pquery($query,array($tr_id,$id,$module,$current_user->id,$time,$status));
    $query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
    $adb->pquery($query,array($tr_id,'team_memberid',$prevalue,$postvalue));

}
//wyt 220906 BUG0056048 客户模块，共享单据，在公众号有提醒，但是取消共享的时候，就不会有提醒，右上角也没有
$smownersql="SELECT $tablename.smownerid,ld_users.wx_userid,ld_users.push_wx_reminds FROM $tablename left join ld_users on $tablename.smownerid=ld_users.id WHERE $tablename"."."."$tableindex=? ";
$smownerresult = $adb->pquery($smownersql, array($id));
$smownerid=$adb->query_result($smownerresult, 0, 'smownerid');
$smownerlastname = getUserFullName($smownerid);
$rRecieverid=$_REQUEST['shareuserid'];
$remindstype = 'cancelshare';
$content = getUserlastName($current_user) . "将" . $smownerlastname . '的' . getTranstab($module) . '对您取消共享！';
$remindsid=$focus->AddReminds($content, $time, $rRecieverid, $id);
$addreminds = "update ld_reminds set remindstype='cancelshare',related_to=? where remindsid=?";
$adb->pquery($addreminds,array($id,$remindsid));

$push_wx_reminds = $adb->query_result($smownerresult, 0, 'push_wx_reminds');
if(!empty($push_wx_reminds)){
    $wx_userid = $adb->query_result($smownerresult, 0, 'wx_userid');
    $reltab = $module;
    $related_to = $id;

    $tmparray['userid'] = $wx_userid;
    $tmparray['message'] = $content;
    $tmparray['reltab'] = $reltab;
    $tmparray['related_to'] = $related_to;
    $tmparray['date_time'] = date("Y-m-d H:i:s");
    $tmparray['remindtype'] = $remindstype;
    $tmparray['reminds_ruleid'] = 0;
    $tmparray['remindsid'] = $remindsid;
    $tmparray['received_id'] = $rRecieverid;
    $r_multi_content[] = $tmparray;

    $col_fields = $focus->column_fields;
    $subject[$id]['subject'] = $col_fields[$focus->list_link_field];//超链接字段
    $subject[$id]['table_code'] = $col_fields[$focus->table_code];//编号
    //zxm 20221116 公众号提醒消息单独请求
    if($remind->judgeOffiaccount()=='yes'){
        require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
        $offiaccount_remind = new cls_reminds_offiaccount();
        $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately([$remindsid],'allocate',$subject);
    }
    $errorno = $remind->sendAllTypeRemindsImmediately([$remindsid], $r_multi_content, 'allocate', $subject);
}

        
  echo 'success';die;
?>