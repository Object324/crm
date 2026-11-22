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
class ModComments_CommentsModel {
	private $data;
	private $focus;
	static $ownerNamesCache = array();
	
	function __construct($datarow) {
		$this->data = $datarow;
        $this->focus = CRMEntity::getInstance('ModComments');
	}
	
	function author() {
		global $current_user;
        $authorid = $this->data['smcreatorid'];
		if(!isset(self::$ownerNamesCache[$authorid])) {
		      /*$userobj=new Users();
              $userobj->id=$authorid*/
              //getOwnerName($authorid)
			self::$ownerNamesCache[$authorid] =getUserFullName($authorid) ;
		}
        $keyfldname = 'assigned_user_id';
        $module = '';
        $keyval = self::$ownerNamesCache[$authorid];
        if(is_admin($current_user)){
            return "<a fieldname='$keyfldname' module='' record='' referencemodule='Users' referencerecord='$authorid' href='index.php?pageto_module=Users&action=index&pageto_record=$authorid' onclick='ListReferenceLinkClick(ld(this),event)'>$keyval</a>";
        }
        else{
            
        }
		
		return $keyval;
	}
	
	function timestamp(){
		//$date = new DateTimeField($this->data['modifiedtime']);
        return date("Y/m/d H:i",strtotime($this->data['modifiedtime']));
        
		return $date->getDisplayDateTimeValue();
	}
	
	function content() {
		return decode_html($this->data['commentcontent']);
	}

	function getRecord() {
		return $this->data['crmid'];
	}
    
    function getParentComments() {
		return $this->data['parent_comments'];
	}
    
    
    
    function getParentReply() {
		return $this->data['parent_reply'];
	}
    
    function getRemindUsers() {
		return $this->data['remindusers'];
	}

	function isDelete(){
		return isPermitted('ModComments','Delete',$this->data['crmid']);
	}
    
    function isReply(){
        if(isPermitted('ModComments','Create')){
		  return isPermitted('ModComments','Reply',$this->data['crmid']);
        }
        else 
         return 'no';
	}
    
    function userimagestr() {
        global $adb;
        $storage_location = $this->data['storage_location'];
        $userimgpath = $this->data['path'];
        $userimgname = $this->data['name'];
        $cloud_path = $this->data['cloud_path'];
        // ljj 20240319 BUG20240318-69 评论和回复的两个人头像相同,但实际上不一样
        $smownerid = $this->data['smownerid'];
        $image_sql = 'select ld_attachments.newfile_name,ld_attachments.path,ld_attachments.storage_location,ld_attachments.cloud_path from ld_salesmanattachmentsrel 
                            LEFT JOIN ld_attachments ON ld_attachments.attachmentsid = ld_salesmanattachmentsrel.attachmentsid where smid=?';
        $image_result =$adb->pquery($image_sql,array($smownerid));
        $image_num_rows = $adb->num_rows($image_result);
        if ($image_num_rows==0){
            $userimgname = '';
        }else{
            $userimgname = $adb->query_result($image_result,0,'newfile_name');
            $userimgpath = $adb->query_result($image_result,0,'path');
            $storage_location = $adb->query_result($image_result,0,'storage_location');
            $cloud_path = $adb->query_result($image_result,0,'cloud_path');
        }
        if($userimgname != ''){
            if($storage_location == 'cos'){
                $image_str = $cloud_path;
            }
            else{
                $image_str = $userimgpath.$userimgname;
                $userfilepath_True = globalStatic::$root_directory.$image_str;
                //加载图片时图片错误时，显示默认图片
                if(!file_exists($userfilepath_True)||!@getimagesize($userimgpath.$userimgname)){
                    $image_str='themes/images/defaultuser.png';
                }
            }
            $image_str = $image_str;
        }
        else{
            // ljj 20231201 XUQIU1000927 更换默认头像
            $image_str=getDefaultAvatar($this->data['smownerid']);
        }
		return $image_str;
	}
    
    function getDefalutReplyContent() {
        global $adb;
        $swomnerid = $this->data['smownerid'];
        if(empty($swomnerid)){
            return '';
        }
        $swomnerlastname =getUserFullName($swomnerid);
        if(isKehu001ServerPc() == 'yes'){
            $tmpsql="select real_name from ld_users where id = ?";
            $tmpresult=$adb->pquery($tmpsql,array($swomnerid));
            if($adb->num_rows($tmpresult)>0){
                $swomnerlastname = $adb->query_result($tmpresult,0,'real_name');
            }
        }
		return '@'.$swomnerlastname.' ';
	}
    
    //显示抄送了多少同事
    function getccrangeCount(){
        global $languageType;
        $remindsusers = $this->data['remindusers']??"";
        $remindsuser_arr = explode(',',$remindsusers);
        if(empty($remindsusers)||sizeof($remindsuser_arr)<=0){
            return '';
        }
        $str = ($languageType == 'en')?' ':'';
        return ''.sizeof($remindsuser_arr).$str.getFixedLabel('COLLEAGUES').'</a>';
        
    }

    // XUQIU1001924 PC端+移动端：模块单据详情界面：评论内容增加图片、附件 回复、图片附件内容显示
    function getFileImgContent($type)
    {
        $content = '';
        $AttData = $this->data['file_img_info'][$type];
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        foreach ($AttData as $index => $info){
            if ($type == 'image'){
                $info['file_path']=$cls_MyCRMcrypt->decode($info['file_path']);
                $info['newfile_name']=$cls_MyCRMcrypt->decode($info['newfile_name']);
                $info['cloud_path']=$cls_MyCRMcrypt->decode($info['cloud_path']);
            }
            $content .= '<div class="ld-detail-ModComments-image-show" name="ModComments_Att">';
            if ($type == 'image' && IsPreviewProfile($info['recordid'],'ModComments') == 'yes'){
                $content .= '<div class="ld-detail-ModComments-image">';
                if ($info['storage_location'] == 'cos'){
                    $content .= '<img name="prevshow_img" src="'.$info['cloud_path'].'" onclick="savePreviewlog(\''.$info['recordid'].'\',\''.$info['fileid'].'\',\'ModComments\',\'\');update_frequency(\''.$info['fileid'].'\',\'preview\');previewImage(ld(this).get(0));" alt="">';
                }else{
                    $content .= '<img name="prevshow_img" src="'.$info['file_path'].$info['newfile_name'].'" onclick="savePreviewlog(\''.$info['recordid'].'\',\''.$info['fileid'].'\',\'ModComments\',\'\');update_frequency(\''.$info['fileid'].'\',\'preview\');previewImage(ld(this).get(0));" alt="">';
                }
                $content .= '</div>';
            }
            $content .= '<span>'.$info['file_name'].'('.$info['file_size'].')</span>';
            $IsFileReadHistoryProfile = IsFileReadHistoryProfile($info['recordid'], 'ModComments');
            if (IsDownLoadProfile($info['recordid'],'ModComments') == 'yes'){
                $content .= '<span class="padL10">';
                $content .='<a download="" href="index.php?module=uploads&action=downloadfile&return_module=ModComments&fileid='.$info['fileid'].'&entityid='.$info['recordid'].'" onclick="update_frequency(\''.$info['fileid'].'\',\'download\');">'.getFixedLabel('DOWNLOAD').'</a>';
                $content .='</span>';
                if ($IsFileReadHistoryProfile == 'yes'){
                    $download_count = getFileOperateTimes($info['recordid'],'download');
                    $content .= $download_count == 0?'<span style="display: none">':'<span style="">';
                    $content .='( <a href="javascript:void(0);" name="download_'.$info['fileid'].'" onclick="FileReadHistory('.$info['fileid'].',\'ModComments\',\'download\');">'.$download_count.'</a>次数)</span>';
                }
            }
            if (IsPreviewProfile($info['recordid'],'ModComments') == 'yes'){
                if ($type == 'image'){
                    $content .= '<span class="padL10"><a href="javascript:" onclick="ld(this).parents(\'div[name=ModComments_Att]\').find(\'img\').click()">'.getFixedLabel('PREVIEW').'</a></span>';
                }elseif ($type == 'filename'){
                    $content .= '<span class="padL10"><a href="javascript:" onclick="update_frequency(\''.$info['fileid'].'\',\'preview\');open_Attachment(\''.$info['recordid'].'\',\''.$info['fileid'].'\',\''.$info['module'].'\',\'\');">'.getFixedLabel('PREVIEW').'</a></span>';
                }
                if ($IsFileReadHistoryProfile == 'yes') {
                    $preview_count = getFileOperateTimes($info['recordid'],'preview');
                    $content .= $preview_count == 0?'<span style="display: none">':'<span style="">';
                    $content .='( <a href="javascript:void(0);" name="preview_'.$info['fileid'].'" onclick="FileReadHistory('.$info['fileid'].',\'ModComments\',\'preview\');">'.$preview_count.'</a>次数)</span>';
                }
            }
            $content .='</div>';
        }
        return $content;
    }

    function isFileImgShow($type){
        $column_fields = $this->focus->column_fields;
        if (!array_key_exists($type,$column_fields)){
            return 'no';
        }
        $AttData = $this->data['file_img_info'][$type];
        if(!is_array($AttData))
            return 'no';

        $count = sizeof($AttData);
        if ($count == 0){
            return 'no';
        }else{
            return 'yes';
        }
    }

    function getFileImgCounts($type)
    {
        $AttData = $this->data['file_img_info'][$type];
        if(!is_array($AttData))
            return 0;
        $count = sizeof($AttData);
        return $count;
    }



}