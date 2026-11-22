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
include_once dirname(__FILE__) . '/ModCommentsCore.php';
include_once dirname(__FILE__) . '/models/Comments.php';

require_once globalStatic::$root_directory.'include/utils/VtlibUtils.php';

class ModComments extends ModCommentsCore {

    public $remindusers;
    public $module_name;
    public $commentmode;
    //	//关联模块
    var $relatedtab=array('accounts'=>'','users'=>'','company'=>'','modcomments'=>'');
    function __construct()
    {
    
        parent::__construct();
        $this->module_name='ModComments';

        unset($this->list_fields);//Liver 2017-04-24,bug：快速查找评论列列宽显示太长
         
    }
	/**
	 * Invoked when special actions are performed on the module.
	 * @param String Module name
	 * @param String Event Type (module.postinstall, module.disabled, module.enabled, module.preuninstall)
	 */
	function vtlib_handler($modulename, $event_type) {
		parent::vtlib_handler($modulename, $event_type);
		if ($event_type == 'module.postinstall') {
			self::addWidgetTo(array('Leads', 'Contacts', 'Accounts', 'Potentials', 'Project', 'ProjectTask'));
			global $adb;
			// Mark the module as Standard module
			$adb->pquery('UPDATE ld_tab SET customized=0 WHERE name=?', array($modulename));

		} elseif ($event_type == 'module.postupdate') {
			self::addWidgetTo(array('Potentials'));
		}
	}

	/**
	 * Transfer the comment records from one parent record to another.
	 * @param CRMID Source parent record id
	 * @param CRMID Target parent record id
	 */
	static function transferRecords($currentParentId, $targetParentId) {
		global $adb;
		$adb->pquery("UPDATE ld_modcomments SET related_to=? WHERE related_to=?", array($targetParentId, $currentParentId));
	}

	/**
	 * Get widget instance by name
	 */
	static function getWidget($name) {
		if ($name == 'DetailViewBlockCommentWidget' &&
				isPermitted('ModComments', 'DetailView') == 'yes') {
			require_once dirname(__FILE__) . '/widgets/DetailViewBlockComment.php';
			return (new ModComments_DetailViewBlockCommentWidget());
		}
		return false;
	}

	/**
	 * Add widget to other module.
	 * @param unknown_type $moduleNames
	 * @return unknown_type
	 */
	static function addWidgetTo($moduleNames, $widgetType='DETAILVIEWWIDGET', $widgetName='DetailViewBlockCommentWidget') {
		if (empty($moduleNames)) return;

		include_once 'vtlib/lingdang/Module.php';

		if (is_string($moduleNames)) $moduleNames = array($moduleNames);

		$commentWidgetModules = array();
		foreach($moduleNames as $moduleName) {
			$module = lingdang_Module::getInstance($moduleName);
			if($module) {
				$module->addLink($widgetType, $widgetName, "block://ModComments:modules/ModComments/ModComments.php");
				$commentWidgetModules[] = $moduleName;
			}
		}
		if (count($commentWidgetModules) > 0) {
			$modCommentsModule = lingdang_Module::getInstance('ModComments');
			$modCommentsModule->addLink('HEADERSCRIPT', 'ModCommentsCommonHeaderScript', 'modules/ModComments/ModCommentsCommon.js');
			$modCommentsRelatedToField = lingdang_Field::getInstance('related_to', $modCommentsModule);
			$modCommentsRelatedToField->setRelatedModules($commentWidgetModules);
		}
	}

	/**
	 * Remove widget from other modules.
	 * @param unknown_type $moduleNames
	 * @param unknown_type $widgetType
	 * @param unknown_type $widgetName
	 * @return unknown_type
	 */
	static function removeWidgetFrom($moduleNames, $widgetType='DETAILVIEWWIDGET', $widgetName='DetailViewBlockCommentWidget') {
		if (empty($moduleNames)) return;

		include_once 'vtlib/lingdang/Module.php';

		if (is_string($moduleNames)) $moduleNames = array($moduleNames);

		$commentWidgetModules = array();
		foreach($moduleNames as $moduleName) {
			$module = lingdang_Module::getInstance($moduleName);
			if($module) {
				$module->deleteLink($widgetType, $widgetName, "block://ModComments:modules/ModComments/ModComments.php");
				$commentWidgetModules[] = $moduleName;
			}
		}
		if (count($commentWidgetModules) > 0) {
			$modCommentsModule = lingdang_Module::getInstance('ModComments');
			$modCommentsRelatedToField = lingdang_Field::getInstance('related_to', $modCommentsModule);
			$modCommentsRelatedToField->unsetRelatedModules($commentWidgetModules);
		}
	}
	function save_module($module){
		global $adb,$current_user;
		if(!empty($_REQUEST['related_to_type'])){
			$query = 'update ld_modcomments set reltab = ? where modcommentsid = ?';
			$adb->pquery($query,array($_REQUEST['related_to_type'],$this->id));
		}

        if($this->mode == 'create'){

            $remind_relate_to = $this->id;//评论对应单据id
            if($this->column_fields['topictype'] == 'comments'){
                if(!empty($this->column_fields['related_to'])){
                    $remind_relate_to = $this->column_fields['related_to'];
                }
            }
            //回复获取用户
            if($this->column_fields['topictype'] == 'reply'){
                //所在评论所有提醒人
                $tmpsql = "select remindusers,smownerid,related_to,topictype from ld_modcomments where deleted = 0 and ( parent_comments =? or modcommentsid = ?)";
                $tmpresult = $adb->pquery($tmpsql,array($this->column_fields['parent_comments'],$this->column_fields['parent_comments']));
                $tmprows = $adb->num_rows($tmpresult);
                if($tmprows>0){
                    $tmpremindid_arr = [];
                    for($i=0;$i<$tmprows;$i++)
                    {
                        $tmpremindusers = $adb->query_result($tmpresult,$i,'remindusers');
                        $tmpsmownerid = $adb->query_result($tmpresult,$i,'smownerid');
                        $tmprelated_to = $adb->query_result($tmpresult,$i,'related_to');
                        $tmptopictype = $adb->query_result($tmpresult,$i,'topictype');
                        if(!empty($tmprelated_to)&&$tmptopictype == 'comments'){
                            $remind_relate_to = $tmprelated_to;
                        }
                        if(empty($tmpremindusers)){
                            $tmpremindusers = $tmpsmownerid;
                        }
                        $tmpremindusers_arr = explode(',',$tmpremindusers);
                        $tmpremindusers_arr_new = [];
                        foreach ($tmpremindusers_arr as $tmpuserid){
                            if($tmpuserid != $this->column_fields['assigned_user_id']){
                                $tmpremindusers_arr_new[] = $tmpuserid;
                            }
                        }
                        if(!empty($tmpremindusers_arr_new)){
                            $tmpremindid_arr = array_unique(array_merge($tmpremindusers_arr_new,$tmpremindid_arr));
                        }
                    }
                    $this->remindusers .= ','.implode(',',$tmpremindid_arr);
                }
            }
            $newusernames=$_REQUEST['newusernames'];
            if(!empty($newusernames))
            {
                $newusernames = trim($newusernames,',');
                $newArr = explode(',',$newusernames);
                $oldArr = explode(',',$this->remindusers);
                foreach ($newArr as $key => $value) {
                   //直接点击回复时，文本框中会添加:，需要去掉该字符
                   $value = trim($value);
                   $value = trim($value,':');
                   if(!isset($oldArr[$value])){
                       $userarr[] = $value;
                   }
               }
               if(!empty($userarr)){
                  foreach ($userarr as $key => $value) {
                      $tmpsql="select id,user_name from ld_users where last_name = ?";
                      if( isKehu001ServerPc() == 'yes'){
                        $tmpsql="select id,user_name from ld_users where real_name = ?";
                      }
                      $tmpresult=$adb->pquery($tmpsql,array($value));
                      if($adb->num_rows($tmpresult)>0)
                      {
                          $userid = $adb->query_result($tmpresult,0,'id');
                      }
                      else
                      {
                          $userid = '0';
                      }
                      if(!empty($userid)){
                          $this->remindusers .= ','.$userid;
                      }
                  }
               }
            }
            //发送提醒,获取提醒用户
            if(empty($this->remindusers)){
                //评论模块新建时，默认提醒单据负责人
                $this->remindusers = $this->column_fields['assigned_user_id'];
            }

            $this->CommentAddReminds($this->column_fields['commentcontent'],$this->remindusers,$remind_relate_to,$this->column_fields['topictype']);
        }
	}
	/**
	 * Wrap this instance as a model
	 */
	function getAsCommentModel($parentid) {
	   global $adb,$current_user;
        $query='SELECT ld_modcomments.modcommentsid as crmid,ld_modcomments.*,ld_attachments.newfile_name as name,ld_attachments.path,
             ld_attachments.storage_location,ld_attachments.cloud_path
                      FROM ld_modcomments 
                        LEFT JOIN ld_users ON ld_modcomments.smownerid = ld_users.id
                        left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                        left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid  
                        LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_modcomments.modcommentsid 
                        WHERE ld_modcomments.deleted = 0 AND ld_modcomments.modcommentsid=?
                ORDER BY ld_modcomments.createdtime DESC ';
        $result = $adb->pquery($query, array($parentid));
		$instances = array();
		if($adb->num_rows($result)) {
            $info=$adb->query_result_all($result);
            foreach ($info as $index => $value){
                $crmid=$value['crmid'];
                $value['file_img_info']=getAllFile_imageInfo($crmid,'ModComments');
                $instances[] = new ModComments_CommentsModel($value);
            }
		}
        return $instances;
	}
    /*
    function getRelated()
    {
        global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $tabid = getTabid('ModComments');
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              left join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=".$tabid." and ld_field.presence in (0,2)
			 and ld_field.displaytype in (1) and ld_field.tablename != 'ld_modcommentscf' order by ld_field.sequence";//ld_relatedlists_lable.presence=1 
        $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
		$rows = $adb->num_rows($result);
        unset($this->list_fields);
        for($i=0;$i<$rows;$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
    
	//联系记录详情页 - 评论区块 高级选项
    public function getDetailBlocks($parentid,$type, $mode='')
    {
        global $adb,$current_user;
		$sourceRecordId =  $parentid;
       
	
	   $smarty= new lingdangCRM_Smarty;
		$smarty->assign('ID', $sourceRecordId);
		$smarty->assign('CRITERIA',$type);
		$smarty->assign('UIKEY',$sourceRecordId);
        $query='SELECT ld_modcomments.modcommentsid as crmid,ld_modcomments.*,ld_attachments.newfile_name as name,ld_attachments.path,
             ld_attachments.storage_location,ld_attachments.cloud_path
                      FROM ld_modcomments 
                        LEFT JOIN ld_users ON ld_modcomments.smownerid = ld_users.id
                        left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                        left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid  
                        LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_modcomments.modcommentsid 
                        WHERE ld_modcomments.deleted = 0 AND ld_modcomments.related_to=? ';
        $query2='SELECT ld_modcomments.modcommentsid AS crmid,ld_modcomments.*,ld_attachments.newfile_name as name,ld_attachments.path,
             ld_attachments.storage_location,ld_attachments.cloud_path
                FROM ld_modcomments  AS ld_modcommentscoment
                INNER JOIN ld_modcomments  on ld_modcomments.parent_comments=ld_modcommentscoment.modcommentsid and ld_modcomments.deleted = 0
                LEFT JOIN ld_users ON ld_modcommentscoment.smownerid = ld_users.id
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
                LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_modcommentscoment.modcommentsid
                WHERE ld_modcommentscoment.deleted = 0 AND ld_modcommentscoment.related_to = ? ';
        $tmporderquery = '';
		if($type == 'Last5'){
			$tmporderquery=' order by ld_modcomments.createdtime desc limit 0,5';
		}else if($type == 'Mine'){
			$tmporderquery=' and ld_modcomments.smcreatorid = ' . $current_user->id."  order by ld_modcomments.createdtime desc";
		}else{
			$tmporderquery=' ORDER BY ld_modcomments.createdtime DESC';
		}
        $query.= $tmporderquery;
        $query2.= $tmporderquery;
        $result = $adb->pquery($query, array($parentid));
		 //echo $result->sql;echo '<br><br>';
			$instances = array();
			if($adb->num_rows($result)) {
                $info=$adb->query_result_all($result);
                foreach ($info as $index => $value){
                    $crmid=$value['crmid'];
                    $value['file_img_info']=getAllFile_imageInfo($crmid,'ModComments');
					$instances[] = new ModComments_CommentsModel($value);
				}
			}
        $result2 = $adb->pquery($query2, array($parentid));
            $replys = array();
			if($adb->num_rows($result2)) {
            $info=$adb->query_result_all($result2);
            foreach ($info as $index => $value){
                $crmid=$value['crmid'];
                $value['file_img_info']=getAllFile_imageInfo($crmid,'ModComments');
                $replys[] = new ModComments_CommentsModel($value);
            }
        }
        $tmparray = array();
        foreach($replys as $tmpindex=>$tmpinfo)
        {
            $tmpparentcomment = $tmpinfo->getParentComments();
            $tmparray[$tmpparentcomment] = $tmparray[$tmpparentcomment]+1;
        }
        $smarty->assign('COMMENTREPLYCOUNT', $tmparray);
        $smarty->assign('REPLYLISTHIDDEN', 'yes');
		$smarty->assign('COMMENTS', $instances);
        $smarty->assign('REPLYS', $replys);
		$smarty->assign('MODULE', $_REQUEST['modulename']);
//        $smarty->assign('UIKEY',$record);

        
        $system_358 = getSys_deploy(358);
        $modcommentdisplayright = 'yes';
        if($system_358['deploy_value'] == 1){
            $modcommentdisplayright = 'no';
        }
        $smarty->assign("MODCOMMENTDISPLAYRIGHT",$modcommentdisplayright);
    $smarty->assign('COMMENTMODE', $mode);

        if (isPermitted('ModComments','Create','') == 'yes') {
            $ModComment_focus = CRMEntity::getInstance('ModComments');
            if (array_key_exists('image',$ModComment_focus->column_fields)){
                $isImgEnable = 'yes';
            }
            if (array_key_exists('filename',$ModComment_focus->column_fields)){
                $isAttEnable = 'yes';
            }
            $isPreviewEnable = isPermitted('ModComments','Preview','');
            $smarty->assign("isImgEnable", $isImgEnable);
            $smarty->assign("isAttEnable", $isAttEnable);
            $smarty->assign("isPreviewEnable", $isPreviewEnable);
        }
        
		return $smarty->fetch("modules/ModComments/widgets/DetailViewBlockComment.tpl");
    }
    function ShowCommentItem() {
        $smarty= new lingdangCRM_Smarty;
        $model= $this->getAsCommentModel($this->id);
        $commentmode = $this->commentmode;
	       $smarty->assign('record',$this->id);
        $replys= $this->getReplylistByCommentid($this->id);
        $tmparray = array();
        foreach($replys as $tmpindex=>$tmpinfo)
        {
            $tmpparentcomment = $tmpinfo->getParentComments();
            $tmparray[$tmpparentcomment] = $tmparray[$tmpparentcomment]+1;
        }
        $smarty->assign('COMMENTREPLYCOUNT', $tmparray);
        $smarty->assign('REPLYS', $replys);
        $smarty->assign('COMMENTMODE', $commentmode);
		$smarty->assign('COMMENTMODEL', $model[0]);
        // XUQIU1001924 PC端+移动端：模块单据详情界面：评论内容增加图片、附件 回复、图片附件按钮显示控制
        if (isPermitted('ModComments','Create','') == 'yes') {
            $ModComment_focus = CRMEntity::getInstance('ModComments');
            if (array_key_exists('image',$ModComment_focus->column_fields)){
                $isImgEnable = 'yes';
            }
            if (array_key_exists('filename',$ModComment_focus->column_fields)){
                $isAttEnable = 'yes';
            }
            $isPreviewEnable = isPermitted('ModComments','Preview','');
            $smarty->assign("isImgEnable", $isImgEnable);
            $smarty->assign("isAttEnable", $isAttEnable);
            $smarty->assign("isPreviewEnable", $isPreviewEnable);
        }
        return $smarty->fetch("modules/ModComments/widgets/DetailViewBlockCommentItem.tpl");
	}
  function getcommentmode($modulename){
      global  $current_user;
      if(empty($modulename)){
        return '';
      }
      //显示位置
      $system_358 = getSys_deploy(358);
      if($system_358['deploy_value'] == 0){
        return '';
      }
      //commentmode
      $mode = getUsersettingByLabel($modulename, $current_user->id, 'CommentMode');
      return $mode;
  }
    function getReplylistByCommentid($parentid){
        global $adb,$current_user;
        $query='SELECT ld_modcomments.modcommentsid AS crmid,ld_modcomments.*,ld_attachments.newfile_name as name,ld_attachments.path,
             ld_attachments.storage_location,ld_attachments.cloud_path
                FROM ld_modcomments
                LEFT JOIN ld_users ON ld_modcomments.smownerid = ld_users.id
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
                LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_modcomments.modcommentsid
                WHERE ld_modcomments.deleted = 0 AND ld_modcomments.parent_comments = ? 
                ORDER BY ld_modcomments.createdtime DESC ';
        $result = $adb->pquery($query, array($parentid));
		$instances = array();
		if($adb->num_rows($result)) {
            $info=$adb->query_result_all($result);
            foreach ($info as $index => $value){
                // XUQIU1001924 PC端+移动端：模块单据详情界面：评论内容增加图片、附件 回复、图片数据
                $crmid=$value['crmid'];
                $value['file_img_info']=getAllFile_imageInfo($crmid,'ModComments');
                $instances[] = new ModComments_CommentsModel($value);
            }
		}
        return $instances;
    }
    
    function getListQuery($module, $where = '') {

    $customview=CustomView::getInstance($module);
    $moduleobj=$this;
	
	$table_name = $moduleobj->table_name;

    $viewid=$customview->getViewId($module);
    $columnlist=$customview->getColumnsListByCvid($viewid);
   
    $fromclause="";
	$ismodtable = array('ld_crmentity'=>'1','ld_accountbillads'=>'1',
		'ld_accountshipads'=>'1','ld_contactaddress'=>'1','ld_contactsubdetails'=>'1');

    foreach($columnlist as $colmn)
    {
         $arrcolumn=explode(":",$colmn);
	   if(isset($ismodtable[strtolower($arrcolumn[0])])){
				$arrcolumn[0] = $table_name;
			 }
        $fromclause .=" ,".$arrcolumn[0].".".$arrcolumn[1];
    }
    $query = 'SELECT 
							ld_modcomments.modcommentsid as crmid,ld_modcomments.* '.$fromclause.' 
						FROM
							ld_modcomments 
						LEFT JOIN ld_users 
							ON ld_modcomments.smownerid = ld_users.id
                         left join ld_modcommentscf on ld_modcommentscf.modcommentsid=ld_modcomments.modcommentsid ';
		   $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_modcomments.modcommentsid";
		   $query .= "   WHERE ld_modcomments.deleted = 0 " . $where;
         return $query;
    }
    
    
    function CommentAddReminds($commentcontent,$remindusers,$remind_relate_to,$topictype){
        global $adb;
        //用户去重

        if(!empty($remindusers)){
            $tmpremindusers_arr = explode(',',$remindusers);
            $tmparr = [];
            foreach($tmpremindusers_arr as $tmpindex=>$tmpuserid){
                if(!empty($tmpuserid)&&!in_array($tmpuserid,$tmparr)){
                    $tmparr[] = $tmpuserid;
                }
            }
            $remindusers = implode(',',$tmparr);
        }
        if(empty($remindusers)||empty($topictype)){
            return ;
        }
        $adb->pquery(" update ld_modcomments set remindusers=? where modcommentsid =?",array($remindusers,$this->id));
        
        $reminduser_arr = explode(',',$remindusers);
        $remind_swomnerid = 0;//被评论单据/被回复评论 负责人
        $commented_record =  $remind_relate_to;//被评论单据/被回复评论
        if($topictype == 'reply'){
            if(!empty($this->column_fields['parent_reply'])){
                $commented_record = $this->column_fields['parent_reply'];
            }
            else if(!empty($this->column_fields['parent_comment'])){
                $commented_record = $this->column_fields['parent_comment'];
            }
        }
        $commented_modulename = getSalesEntityType($commented_record);//获取对应模块
        if(!empty($commented_modulename)){
            $relate_focus = CRMEntity::getInstance($commented_modulename);
            $relate_tabname =  $relate_focus->table_name;
            $relate_tabindex =  $relate_focus->table_index;
            $relate_swomnercolumnname = $relate_focus->getSmownerColumName();
            $tmpsql = "select $relate_swomnercolumnname as swomnerid from $relate_tabname where $relate_tabindex=?;";
            $tmpresult = $adb->pquery($tmpsql,array($commented_record));
            if($adb->num_rows($tmpresult)>0){
                $tmpswomner = $adb->query_result($tmpresult,0,0);
                if(!empty($tmpswomner)&&in_array($tmpswomner,$reminduser_arr)){
                    $remind_swomnerid = $adb->query_result($tmpresult,0,0);
                }
                
            }
        }
        
        $remind_relate_module = getSalesEntityType($remind_relate_to);//获取对应模块
        $relate_to_focus = CRMEntity::getInstance($remind_relate_module);
        $relate_to_focus->id = $remind_relate_to;
        $relate_to_focus->retrieve_entity_info($remind_relate_to, $remind_relate_module);
        $remind_relate_module_lable = getTranstab($remind_relate_module);
        if(empty($remind_relate_module)||!preg_match("/[^\d-., ]/",$remind_relate_module)){
            $remind_relate_module = $this->moduleName;
        }
        $swomnerlastname = getUserFullName($this->column_fields['assigned_user_id']);
        $time = date('Y-m-d H:i:s',time());
        $subject[$commented_record]['subject'] = $relate_to_focus->column_fields[$relate_to_focus->list_link_field];
        $subject[$commented_record]['table_code'] = $relate_to_focus->column_fields[$relate_to_focus->table_code];
        //发送提醒 remindstype:MODULECOMMENTRemind
        require_once(globalStatic::$root_directory.'WeiXinApp/modules/Reminds/MessageCorpconversation.php');
        foreach($reminduser_arr as $tmpkey=>$reminderuserid){
            if($reminderuserid == $remind_swomnerid && $remind_swomnerid>0){
                $remindconten = $swomnerlastname.'评论了您的'.$remind_relate_module_lable.'，';
                if($remind_relate_module == $this->moduleName){
                    $remindconten = $swomnerlastname.'发表了评论'.$remind_relate_module_lable.'，';
                }
                $remindconten .= '评论内容如下：'.$commentcontent;
                $remindtitle = '【'.$remind_relate_module_lable.'】'.getTranstab($this->moduleName).'提醒';
                if($topictype == 'reply'){
                    $remindconten = $swomnerlastname.'回复了您的'.$remind_relate_module_lable.getTranstab($this->moduleName).'信息，回复内容如下：'.$commentcontent;
                    $remindtitle = '【'.$remind_relate_module_lable.'】'.getTranstab($this->moduleName).'回复提醒';
                }
            }
            else{
                $remind_swomnerlastname =getUserFullName($remind_swomnerid);
                $remindconten = $swomnerlastname.'评论了'.$remind_swomnerlastname.'的'.$remind_relate_module_lable.'，';
                if($remind_relate_module == $this->moduleName){
                    $remindconten = $swomnerlastname.'发表了评论，';
                }
                $remindconten .= '评论内容如下：'.$commentcontent;
                $remindtitle = '【'.$remind_relate_module_lable.'】'.getTranstab($this->moduleName).'抄送提醒';
                if($topictype == 'reply'){
                    $remindconten = $swomnerlastname.'回复了'.$remind_swomnerlastname.'的'.$remind_relate_module_lable.getTranstab($this->moduleName).'信息，回复内容如下：'.$commentcontent;
                    $remindtitle = '【'.$remind_relate_module_lable.'】'.getTranstab($this->moduleName).'回复抄送提醒';
                }
            }
            $remindsinfo = array();
            $remindsinfo[] = $this->AddReminds($remindconten,$time,$reminderuserid,$remind_relate_to,$remind_relate_module,'immediately');
            $remind = new MessageCorpconversation();
            $remind->setRemindType();
            if ($remind->installWX || $remind->installDing || $remind->installYzj || $remind->installZy ||$remind->judgeOffiaccount()=='yes' || $remind->installFanwei)
            {
                $sql = 'select wx_userid,dingtalk_userid,yunzhijia_openid,zhiyuan_userid,fanwei_userid from ld_users  where id=? and push_wx_reminds = 1 ';
                $tmpuserresult = $adb->pquery($sql, array($reminderuserid));
                $tmprows = $adb->num_rows($tmpuserresult);
                $wx_userid_arr = [];
                $dingtalk_userid_arr = [];
                $yunzhijia_openid_arr = [];
                $zhiyuan_userid_arr = [];
                $fanwei_userid_arr = [];
                //移动端-设置页签-“推送消息提醒”参数关闭应不发送提醒
                if($tmprows<=0){
                    continue;
                }
                else{
                    for($i=0;$i<$tmprows;$i++){
                        $wx_userid_arr[] = $adb->query_result($tmpuserresult, $i, 'wx_userid');
                        $dingtalk_userid_arr[] = $adb->query_result($tmpuserresult, $i, 'dingtalk_userid');
                    	$yunzhijia_openid_arr[] = $adb->query_result($tmpuserresult, $i, 'yunzhijia_openid');
                        $zhiyuan_userid_arr[] = $adb->query_result($tmpuserresult, $i, 'zhiyuan_userid');
                        $fanwei_userid_arr[] = $adb->query_result($tmpuserresult, $i, 'fanwei_userid');
                    }
                }
                if (!empty($wx_userid_arr) || !empty($dingtalk_userid_arr)|| !empty($yunzhijia_openid_arr) || !empty($zhiyuan_userid_arr) ||$remind->judgeOffiaccount()=='yes' || !empty($fanwei_userid_arr)) {
                    $sql = 'update ld_reminds set remindstype=?,wxremindstype=? where remindsid in( ' . implode(',', $remindsinfo) . ') ';
                    $adb->pquery($sql, array('MODULECOMMENTRemind', 'immediately'));
                    $r_multi_content = array(
                        array(
                            'message' => $remindconten,
                            'reltab' => $remind_relate_module,
                            'related_to' => $remind_relate_to,
                            'date_time' => date("Y-m-d H:i:s"),
                            'remindtype' => 'MODULECOMMENTRemind',
                            'title' => $remindtitle,
                            'received_id'=>$reminderuserid,
                            'remindsid' => implode(',', $remindsinfo),
                        )
                    );
                    if(!empty($wx_userid_arr)){
                        $r_multi_content[0]['userid'] = $wx_userid_arr;
                    }
                    if(!empty($dingtalk_userid_arr)){
                        $r_multi_content[0]['userid_ding'] = $dingtalk_userid_arr;
                    }
            		if(!empty($yunzhijia_openid_arr)){
                        $r_multi_content[0]['userid_openid'] = implode(',', $yunzhijia_openid_arr);
                    }
                    /*if(!empty($zhiyuan_userid_arr)){
                        $r_multi_content[0]['userid_zhiyuan'] = implode(',', $zhiyuan_userid_arr);
                    }*/
                    if(!empty($fanwei_userid_arr)){
                        $r_multi_content[0]['userid_fanwei'] = implode(',', $fanwei_userid_arr);
                    }
                    //$tmpremindsid = implode(',', $remindsinfo);
                    //企业微信/自建应用 钉钉 云之家
                    if(!empty($wx_userid_arr) || !empty($dingtalk_userid_arr)|| !empty($yunzhijia_openid_arr) || !empty($zhiyuan_userid_arr) || !empty($fanwei_userid_arr)) {
                        //zkt 20230801 BUG0070213 http://222.208.64.231:8948/crm ；成都博达；OA表单>工作周报>ZDYBD22-22的详情页面>右侧评论信息，客户反馈说评论类的信息在云之家的手机端接收不到。 
                        $errorno = $remind->sendAllTypeRemindsImmediately($remindsinfo, $r_multi_content,'MODULECOMMENTRemind',$subject);
                    }
                    //zxm 20221116 公众号提醒消息单独请求
                    if($remind->judgeOffiaccount()=='yes'){
                        require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
                        $offiaccount_remind = new cls_reminds_offiaccount();

                        //zkt 20230412 BUG0064635 评论提醒没有推送到小程序提醒：企业微信提醒了，但是小程序没有
                        $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately($remindsinfo,'jiaofu',$subject);
                    }
                }
            }
        }
    }
    
    public function AddReminds($RemindsContent,$datetime,$recieverid,$record,$module='',$wxremindstype='')
    {
             global $adb,$current_user;
          
            
            $focus_rel =CRMEntity::getInstance('Reminds');                    
        	$focus_rel->column_fields['date_time'] = $datetime;	   
            $focus_rel->column_fields['related_to']=$record;
            if(empty($module)){
               $module =$this->moduleName;
            }
            $focus_rel->column_fields['reltab']=$module;
            
            $focus_rel->column_fields['recieverid']=$recieverid;
            
            $focus_rel->column_fields['status_rmd']='未读';
            $focus_rel->column_fields['content']=$RemindsContent;
            $focus_rel->column_fields['wxremindstype']=$wxremindstype;
            $focus_rel->mode="create";
            $focus_rel->save('Reminds');
            return $focus_rel->id;
    }

    public function getModCommentsRemindUser($modulename,$record)
    {
        global $current_user,$adb;
        $related_focus=CRMEntity::getInstance($modulename);


        $related_focus->retrieve_entity_info($record, $modulename);

        $sql="select * from ld_module_setting_byuser  where modulename=? and userid=? and type=? ";
        $result=$adb->pquery($sql,array($modulename,$current_user->id,"CommentUserSet"));
        $copyuserid=array();
        $copyusername=array();
        $sqluserid_arr=[];
        $sqlusercolumn_arr=[];

        if($adb->num_rows($result)>0)
        {

            for($i=0;$i<$adb->num_rows($result);$i++){

                $tmparr=json_decode($adb->query_result($result,$i,'content'),true);

                if(is_array($tmparr))
                {

                    $tmpsql=html_entity_decode($tmparr['sql']);
                    $allpresencefield=$related_focus->fieldobj->getModuleAllPreseneceFields();

                    foreach($allpresencefield as   $tmpfieldname=>$tmpfieldinfo){
                        $tmptablename=$tmpfieldinfo->getTableName();
                        $tmpcolumnname=$tmpfieldinfo->getColumnName();
                        if(array_key_exists($tmpfieldname,$related_focus->column_fields))
                        {
                            $tmpsql=str_replace("##$tmptablename.$tmpcolumnname##",(string)$related_focus->column_fields[$tmpfieldname],$tmpsql);
                            $tmpsql=str_replace("{"."$tmptablename.$tmpcolumnname"."}",(string)$related_focus->column_fields[$tmpfieldname],$tmpsql);
                        }

                    }
                    $tmpsql=str_replace("{Record.ID}",$record,$tmpsql);

                    if($adb->num_rows($adb->pquery($tmpsql))>0)
                    {

                        $tmpuserid_arr=explode(",",$tmparr['userid']);
                        $tmpusercolumn_arr=explode(",",$tmparr['fieldname']);
                        if(is_array($tmpuserid_arr))
                        {
                            $sqluserid_arr=array_merge($sqluserid_arr,$tmpuserid_arr);

                        }
                        if(is_array($tmpusercolumn_arr))
                        {
                            $sqlusercolumn_arr=array_merge($sqlusercolumn_arr,$tmpusercolumn_arr);
                        }

                    }
                }
            }
        }

        if(!empty($sqlusercolumn_arr))
        {
            foreach ($sqlusercolumn_arr as $tmpcolumnname)
            {
                $tmpfieldinfo=  $related_focus->fieldobj->getFieldInfoobjBykey('columnname',$tmpcolumnname);
                if($tmpfieldinfo)
                {
                    if(!empty($related_focus->column_fields[$tmpfieldinfo->getFieldName()]))
                    {
                         $tmpuserid_arr=explode(",",$related_focus->column_fields[$tmpfieldinfo->getFieldName()]);
                         if(is_array($tmpuserid_arr)&&!empty($tmpuserid_arr))
                         {
                             $sqluserid_arr=array_merge( $sqluserid_arr,$tmpuserid_arr);

                         }
                         else{
                             $sqluserid_arr[]=$related_focus->column_fields[$tmpfieldinfo->getFieldName()];

                         }
                    }


                }

            }
        }
        if(empty($sqluserid_arr)){

            $smownercolumnname = $related_focus->getSmownerColumName();
            $smownerfieldinfo = $related_focus->fieldobj->getFieldInfoobjBykey('columnname',$smownercolumnname);
            if(!empty($smownerfieldinfo)){
                $smownerfieldname = $smownerfieldinfo->getFieldName();
                $smownerid=$related_focus->column_fields[$smownerfieldname];
                if(!in_array($smownerid,$copyuserid) && $smownerid != 0){
                    $copyuserid[]=$smownerid;
                }
            }
            $createdcolumnname = $related_focus->getCreateColumnName();
            $createrfieldinfo = $related_focus->fieldobj->getFieldInfoobjBykey('columnname',$createdcolumnname);
            if(!empty($createrfieldinfo)){
                $createrfieldname = $createrfieldinfo->getFieldName();
                $createrid=$related_focus->column_fields[$createrfieldname];
                if(!in_array($createrid,$copyuserid)){
                    $copyuserid[]=$createrid;
                }
            }
            else{
                //wym 240222 创建人字段可能会被关闭，所以不能在column_fields中获取，从数据库获取
                $creatersql='select '.$related_focus->getCreateColumnName().' from '.$related_focus->table_name.' where '.$related_focus->table_index.'=?';
                $createrresult=$adb->pquery($creatersql,array($related_focus->id));
                if($adb->num_rows($createrresult)>0) {
                    $createrid = $adb->query_result($createrresult,0);
                    if(!in_array($createrid,$copyuserid)){
                        $copyuserid[] = $createrid;
                    }
                }
            }

        }
        else{
            $copyuserid=array_unique($sqluserid_arr);

        }
        foreach ($copyuserid as $id){
            if ($id != $current_user->id){
                $copyuserlastname = getUserFullName($id);
                $copyusername[$id]=$copyuserlastname;
            }
        }
        return $copyusername;

    }
}
?>