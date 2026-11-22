<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//ｚｘｍ　　2021-0708 创建群聊选择成员 成员列表数据
$type = $_REQUEST['type'];
$related_module = $_REQUEST['related_module'];
$type = empty($type)?'all':$type ;
$recordid = $_REQUEST['recordid'];
$focus = CRMEntity::getInstance($related_module);
$focus->retrieve_entity_info($recordid,$related_module);
$focus->id = $recordid;
$focus->name=$focus->column_fields[$focus->list_link_field];
$res['entityname'] = $focus->name;

if($type=='all'){
    $rel_list = isPresentRelatedLists($related_module);
    $rel_list_flip = array_flip($rel_list);
    $Contactsrelated_id = $rel_list_flip['Contacts'];
    $ShareUsersrelated_id = $rel_list_flip['ShareUsers'];
    //共享人和外部联系人
    $ShareUsers = getShareUsers($ShareUsersrelated_id);
    $delWxUserid = [];
    //将通讯录中重复的 删除
    foreach($ShareUsers as &$u){
        $u['display'] = 'yes';
        $delWxUserid[]=$u['wx_userid'];
    }
    $res['list'][] = ['name'=>'团队成员','type'=>'SharedUsers','list'=>$ShareUsers];
    $contacts = getContacts($Contactsrelated_id);
    if(!empty($contacts)){
        foreach($contacts as &$c){
            $c['display'] = 'yes';
        }
        $res['list'][] = ['name'=>'外部联系人','type'=>'ExternalContacts','list'=>$contacts];
    }
    $users = getUsers();

    foreach($users as $k=>&$user){
        if(in_array($user['wx_userid'],$delWxUserid)){
            unset($users[$k]);
        }else{
            $user['display'] = 'yes';
        }
    }
    $users = array_values($users);
    $res['list'][] = ['name'=>'选择成员','type'=>'Users','list'=>$users];//BUG0055208 “企业通讯录”标签修改为“选择成员”
    //duan 20221020 移动端获取字符串翻译
    $label_arr = array('SESSION','CANCEL','SEARCHNEW','SELECTONECOLLEAGUE','WECHATVERSIONLOWPLEASEUPGRADE',
        'DISCUSSIONGROUP','DISCUSSIONGROUPOF','RESET');
    $res['arrFixedLabel']=TransFieldlabel($label_arr,'no');
    ConvertTojsonString(1, $res, 'success');

}else if($type=='mailList'){
    //企业通讯录 --暂时不用
    $res = getUsers();
    ConvertTojsonString(1, $res, 'success');
}

    //1.获取共享人
    function getShareUsers($related_id){
        crm_load_class_file('cls_ListViewShareUserWX','WeiXinApp/list');
        $recordid = $_REQUEST['recordid'];
        $_REQUEST['related_id'] = $related_id;
        $mobj = new cls_ListViewShareUserWX($recordid);
        $where = " and ld_users.wx_userid is not null and ld_users.wx_userid!='' ";//获取共享联系人  非微信用户不显示
        $shareUsers = $mobj->get_listdetail('','',$where);
        return $shareUsers['list1'];
    }
    //2.获取外部联系人
    function getContacts($related_id){
         global $adb;
         $mobj = cls_Instance::get_moduleAction_Instance('Contacts','ListView');

         $_REQUEST['weixin_external_userid'] = "yes";
         $_REQUEST['related_id'] = $related_id;
         $_REQUEST['module'] ="Contacts";
         $_REQUEST['action'] ="ListView";
         $page_list_query = $mobj->get_page_query('','no');
         $list_query = ' select lastname,weixin_external_userid,department from ld_contactdetails inner join   ( ' . $page_list_query . '  ) as tmp on tmp.' .
             $mobj->focus->table_index . '=' . $mobj->focus->table_name . '.' . $mobj->focus->table_index;
         $res = $adb->pquery($list_query);
         $nums = $adb->num_rows($res);

         $list = [];
         if($nums>0){
            for($i=0;$i<$nums;$i++){
                $list[$i]['lastname'] = $adb->query_result($res,$i,'lastname');
                $list[$i]['wx_userid'] = $adb->query_result($res,$i,'weixin_external_userid');
                $list[$i]['userimg'] = 'themes/images/defaultuser.png';
                $list[$i]['description'] = $adb->query_result($res,$i,'department');
             }
         }
         return $list;
    }
    //3.获取企业通讯录--是否考虑自己写sql
    function getUsers(){
        global $adb;
        $sql = "select id from ld_users where wx_userid is not null and wx_userid!=''";
        $res = $adb->pquery($sql);
        $nums = $adb->num_rows($res);
        $ids = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $ids[] = $adb->query_result($res,$i,'id');
            }
        }
        $ids = implode(',',$ids);
        $userdetailinfo = cls_StaticCommonFun::getUserDetailInfo($ids);
        return $userdetailinfo;
    }

?>