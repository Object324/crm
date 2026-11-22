<?php
//zkt 20231023 XUQIU1002065 ��¼��ס�����Ż�+SQLע���������XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb,$current_user;
$modObj = CRMEntity::getInstance($currentModule);
$fieldobj=Field::getInstance($currentModule,$adb);
$ajaxaction = $_REQUEST["ajxaction"];

// ljj 20240412 XUQIU1001924 PC端+移动端：模块单据详情界面：评论内容增加图片、附件
$fieldobj = Field::getInstance($currentModule,$adb);
$moduleFields=$fieldobj->getModuleFields();
foreach ($moduleFields as $fieldname => $info){
    if ($fieldname == 'image' || $fieldname == 'filename'){
        if (!empty($_REQUEST[$fieldname])){
            foreach ($_REQUEST[$fieldname] as $key => $value){
                $_REQUEST[$key] = $value;
            }
        }
    }
}

if($ajaxaction == 'WIDGETADDCOMMENT') {
	if (isPermitted($currentModule, 'Create', '') == 'yes') {
		$modObj->column_fields['commentcontent'] = vtlib_purify($_REQUEST['comment']);
		$modObj->column_fields['related_to'] = vtlib_purify($_REQUEST['parentid']);
		$modObj->column_fields['assigned_user_id'] = $current_user->id;
        $modObj->mode='create';
        if(!empty($_REQUEST['ccrangeuser'])){
            $modObj->remindusers = trim($_REQUEST['ccrangeuser'],',');
        }
        $modObj->column_fields['topictype']='comments';
        //$modObj->column_fields['reltab']=$_REQUEST['modulename'];
		$_REQUEST['related_to_type'] = $_REQUEST['modulename'];
        $relate_focus = CRMEntity::getInstance($_REQUEST['modulename']);
        $relate_tabname =  $relate_focus->table_name;
        $relate_tabindex =  $relate_focus->table_index;
        // $relate_swomnercolumnname = $relate_focus->getSmownerColumName();
        // $relate_creatercolumnname = $relate_focus->getCreateColumnName();
        // //wym 240222 XUQIU20240204-01 评论：默认除@负责人外，创建人也应该@（移动端还没有@用户功能，先默认给创建人也发送提醒）
        // $tmpsql = "select $relate_swomnercolumnname as swomnerid,$relate_creatercolumnname as createrid from $relate_tabname where $relate_tabindex=?;";
        // $tmpresult = $adb->pquery($tmpsql,array($modObj->column_fields['related_to']));
        // if($adb->num_rows($tmpresult)>0){
        //     $tmpremindid_arr=array();
        //     $tmpremindid_arr[] = $adb->query_result($tmpresult,0,'swomnerid');
        //     $tmpcreater = $adb->query_result($tmpresult,0,'createrid');
        //     if(!in_array($tmpcreater,$tmpremindid_arr) && $tmpcreater){
        //         $tmpremindid_arr[]=$tmpcreater;
        //     }
        //     if(!empty($tmpremindid_arr)){
        //         $modObj->remindusers = implode(',',$tmpremindid_arr);
        //     }
        // }
        $modObj->save($currentModule);
		ConvertTojsonString('1',null,'');
	} else {
		ConvertTojsonString('-1',null,'');
	}
}
else if($ajaxaction == 'WIDGETADDREPLY'){
    if(isPermitted($_REQUEST['related_to_type'], 'DetailView', $_REQUEST['related_to']) == 'no'){
        ConvertTojsonString(-2,array(),'');
    }
    else if(isPermitted($currentModule, 'Reply', $_REQUEST['parentid']) == 'no'){
        ConvertTojsonString(-1,array(),'你没有评论回复权限！');
    }
    else{
        if (isPermitted($currentModule, 'Create', '') == 'yes' && isPermitted($_REQUEST['related_to_type'], 'DetailView', $_REQUEST['related_to']) == 'yes') {
            $parentid = vtlib_purify($_REQUEST['parentid']);
            $replyedid = vtlib_purify($_REQUEST['replyedid']);
            $modObj->column_fields['commentcontent'] = vtlib_purify($_REQUEST['comment']);
            $modObj->column_fields['parent_comments'] = $parentid;
            $modObj->column_fields['assigned_user_id'] = $_SESSION['authenticated_user_id'];
            $modObj->column_fields['topictype']='reply';
            if($replyedid!=$parentid){
                $modObj->column_fields['parent_reply'] = $replyedid;
            }
            $modObj->mode = 'create';
            $fieldobj = Field::getInstance($currentModule,$adb);
            $moduleFields=$fieldobj->getModuleFields();
            $modObj->save($currentModule);
            $fieldid = $fieldobj->getFieldInfoBykeyValue('fieldname','related_to','fieldid');
            $query = 'select 1 from ld_fieldmodulerel where fieldid = ? and module = ? and relmodule = ?';
            $result = $adb->pquery($query,array($fieldid,$currentModule,$_REQUEST['related_to_type']));
            if($adb->num_rows($result) <= 0){
                $adb->pquery('insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)values(?,?,?,?,?)',array($fieldid,$currentModule,$_REQUEST['related_to_type'],0,0));
            }
           /*
           edit:can
           date:20130424
           reason:0003839: 在客户资料界面 用个人用户（ivy）添加一条评论，但是显示出来的 评论信息里面 作者 都显示成：admin
           other:current_user->id=> $_SESSION['authenticated_user_id']
           */
            if(empty($modObj->column_fields['smcreatorid'])) $modObj->column_fields['smcreatorid'] = $_SESSION['authenticated_user_id'];
            if(empty($modObj->column_fields['modifiedtime'])) $modObj->column_fields['modifiedtime']= date('Y-m-d H:i:s');
            ConvertTojsonString(1,array(),'');
        } else {
            ConvertTojsonString(-2,array(),'');
        }
    }
}
else if($ajaxaction == 'getRemindUserList'){
    $remindusers = $_REQUEST['remindusers'];
    $entityContent = [];
    if(!empty($remindusers)){
        $sql = "select DISTINCT ld_salesmanattachmentsrel.attachmentsid ,ld_users.last_name ,ld_users.wx_userid,
                path,ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_users.id
                from ld_users
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                where FIND_IN_SET(ld_users.id,?);";
        $result = $adb->pquery($sql,array($remindusers));
        $row = $adb->num_rows($result);
        for($i=0 ; $i<$row ;$i++){
            $attachmentsid=$adb->query_result($result,$i,'attachmentsid');
            $path=$adb->query_result($result,$i,'path');
            $userimagename=$adb->query_result($result,$i,'userimagename');
            $storage_location=$adb->query_result($result,$i,'storage_location');
            if($storage_location == 'cos'){
              $userfilepath=$adb->query_result($result,$i,'cloud_path');
            }
            else{
                if(!empty($attachmentsid)&&!empty($path)){
                    $userfilepath=$path.$userimagename;
                }
                else{
                    // ljj 20231201 XUQIU1000927 更换默认头像
                    $userfilepath=getDefaultAvatar($remindusers);
                }
                $userfilepath_True = globalStatic::$root_directory.$userfilepath;//gyq date:20170324
                //加载图片时图片错误时，显示默认图片
                if(!file_exists($userfilepath_True)||!@getimagesize($userfilepath_True)){
                  $userfilepath='themes/images/defaultuser.png';
                } 
            }
            $last_name=$adb->query_result($result,$i,'last_name');
            $wx_userid=$adb->query_result($result,$i,'wx_userid');
            $userobj=new Users();
            $userobj->wx_userid=$wx_userid;
            $userobj->last_name=$last_name;
            $entityContent['list'][]=array('userimage'=>$userfilepath,'curid'=>$adb->query_result($result,$i,'id'),'username'=>getUserlastName($userobj),'userlevel'=>$userlevel);
        }
        $entityContent['usercount']=$row;
    }
    ConvertTojsonString(1,$entityContent,'');
}
?>