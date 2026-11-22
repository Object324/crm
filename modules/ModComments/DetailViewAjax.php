<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
global $currentModule,$adb,$current_user;
//global $current_user;
$modObj = CRMEntity::getInstance($currentModule);
$fieldobj=Field::getInstance($currentModule,$adb);
$ajaxaction = $_REQUEST["ajxaction"];
if($ajaxaction == 'WIDGETADDCOMMENT') {
	if(isPermitted($_REQUEST['related_to_type'], 'DetailView', $_REQUEST['parentid']) == 'no'){
		ConvertTojsonString(-2,array(),'');
	}else{
		if (isPermitted($currentModule, 'Create', '') == 'yes' && isPermitted($_REQUEST['related_to_type'], 'DetailView', $_REQUEST['parentid']) == 'yes') {
			$modObj->column_fields['commentcontent'] = vtlib_purify($_REQUEST['comment']);
			$modObj->column_fields['related_to'] = vtlib_purify($_REQUEST['parentid']);
			$modObj->column_fields['assigned_user_id'] = $_SESSION['authenticated_user_id'];
			$modObj->column_fields['reltab']=$_REQUEST['related_to_type'];
            $modObj->column_fields['topictype']='comments';
            $modObj->mode = 'create';
            if(!empty($_REQUEST['ccrangeuser'])){
                $modObj->remindusers = trim($_REQUEST['ccrangeuser'],',');
            }
            $commentmode = getUsersettingByLabel($modObj->column_fields['reltab'], $current_user->id, 'CommentMode');
            if($commentmode == 'concise' && empty($modObj->remindusers)){
                if(!empty($modObj->column_fields['reltab'])){
                    $relate_focus = CRMEntity::getInstance($modObj->column_fields['reltab']);
                    $relate_tabname =  $relate_focus->table_name;
                    $relate_tabindex =  $relate_focus->table_index;
                    $relate_swomnercolumnname = $relate_focus->getSmownerColumName();
                    $tmpsql = "select $relate_swomnercolumnname as swomnerid from $relate_tabname where $relate_tabindex=?;";
                    $tmpresult = $adb->pquery($tmpsql,array($modObj->column_fields['related_to']));
                    if($adb->num_rows($tmpresult)>0){
                        $tmpswomner = $adb->query_result($tmpresult,0,0);
                        if(!empty($tmpswomner)){
                            $modObj->remindusers = $tmpswomner.'';
                        }
                    }
                }
            }

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
			$modObj->commentmode = $modObj->getcommentmode($modObj->column_fields['reltab']);
		    //$widgetInstance = $modObj->ShowCommentItem('DetailViewBlockCommentWidget');
			$arr['content'] = $modObj->ShowCommentItem();
            $arr['modcommentid'] =$modObj->id;
            ConvertTojsonString(1,$arr,'');
		} else {
		    if(isPermitted($currentModule, 'Create', '') != 'yes'){
		         ConvertTojsonString(-1,array(),'你没有评论新增权限！');  
		    }
			ConvertTojsonString(-2,array(),'');
		}
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
			echo ':#:SUCCESS';
		//	$widgetInstance = $modObj->ShowCommentItem('DetailViewBlockCommentWidget');
			$focus = CRMEntity::getInstance($currentModule);
            $focus->id = $parentid;
            $focus->retrieve_entity_info($parentid, $currentModule);
            $focus->commentmode = $focus->getcommentmode($modObj->column_fields['reltab']);
            $arr['content'] = $focus->ShowCommentItem();
            $arr['modcommentid'] =$modObj->id;
            ConvertTojsonString(1,$arr,'');
		} else {
			ConvertTojsonString(-2,array(),'');
		}
	}
}
else if($ajaxaction == 'DETAILVIEW') {
	/*$crmid = $_REQUEST['recordid'];
	$tablename = $_REQUEST['tableName'];
	$fieldname = $_REQUEST['fldName'];
	$fieldvalue = utf8RawUrlDecode($_REQUEST['fieldValue']); 
	if($crmid != '')
	{
		$modObj->retrieve_entity_info($crmid, $currentModule);
		$modObj->column_fields[$fieldname] = $fieldvalue;
		$modObj->id = $crmid;
		$modObj->mode = 'edit';
		$modObj->save($currentModule);
		if($modObj->id != '')
		{
			echo ':#:SUCCESS';
		}else
		{
			echo ':#:FAILURE';
		}   
	}else
	{
		echo ':#:FAILURE';
	}*/
	crm_load_class_file("DetailViewAjaxSave",'data');
	 $crmid = $_REQUEST["recordid"];
	 $tablename = $_REQUEST["tableName"];
	 $fieldname = $_REQUEST["fldName"];
	 $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
	 $DetailViewAjaxSaveobj=new DetailViewAjaxSave($currentModule,$crmid,$fieldname,$fieldvalue);
	 $DetailViewAjaxSaveobj->save();
	 
	 $DetailViewAjaxSaveobj->setEcho();
}
else if($ajaxaction == 'DELMODCOMMENT'){
	if(!empty($_REQUEST['record'])){
		$focus = CRMEntity::getInstance('ModComments');
        DeleteEntity('ModComments', '', $focus, $_REQUEST['record'], '');
        $arr = array();
		if(!empty($_REQUEST['parentid'])){
		    $focus = CRMEntity::getInstance('ModComments');
            $parentid = $_REQUEST['parentid'];
            $focus->id = $parentid;
            $focus->retrieve_entity_info($parentid, 'ModComments');
            $arr['content'] = $focus->ShowCommentItem();
        }
        ConvertTojsonString(1,$arr,'删除成功');
	}
}
elseif($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE"){
	require_once 'include/ListView/RelatedListViewContents.php';
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