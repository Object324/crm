<?php
if($_REQUEST['type'] == 'saveScheduleTemplateSort') {

    $type = $_REQUEST['type'];
    global $adb;
//保存审批流程排序 weiyannan 20231123 XUQIU1002038 后台设置列表界面可以做排序 后台设置--模板设置-日程模板定制
    if ($type == 'saveScheduleTemplateSort') {
        if (!empty($_REQUEST['tagids'])&&!empty($_REQUEST['tabid'])) {
            $tabid = $_REQUEST['tabid'];
            $tagids_arr = explode(',', $_REQUEST['tagids']);
            $sequence = 1;
            foreach ($tagids_arr as $id) {
                $adb->pquery('update ld_template_calendar set sequence = ? where templateid = ? and tabid = ?', array($sequence, $id, $tabid));
                $sequence++;
            }
            ConvertTojsonString(1,array(),"success");
        }
    }
}

header("Content-type: text/html; charset=utf-8"); 
if(isset($_REQUEST['template_showtype'])){
	global $current_user;
    require_once(globalStatic::$root_directory.'modules/Calendar/TemplateCalendar/cls_templateCalendar.php');
    require('user_privileges/user_language_'.$current_user->id.'.php');
    $showtype = $_REQUEST['template_showtype'];
    $calobj = new TemplateCalendar();
    switch($showtype){
        case 'listview':  // 显示日程模板列表
            $modulelist = $calobj->getAvailableModule();
            if($_REQUEST['blockid']){
                $blockid=$_REQUEST['blockid'];
            }else{
                // editor:gyqX160914  Bug:0024434: 控制面板>日程模块：切换模块后，客户模块下的单据显示不对
                $blockid = key($modulelist);
            }
            
            if($_REQUEST['changestatus'] == 'yes'){
                $calobj->changeStatus();
            }
            
            $smarty=new lingdangCRM_Smarty;
            $smarty->assign('LANGUAGETYPE',$languageType);
            $smarty->assign('APPROVE',array_values($calobj->getListview($blockid)));
            

            
            $smarty->assign("PRINTTABID",$tabid);
            $smarty->assign("TAB",$modulelist);
            $smarty->assign('BLOCKID',$blockid);

            $smarty->assign('blockidsetting',$_REQUEST['blockidsetting']);

            $smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
            // require_once(globalStatic::$root_directory.'modules/Settings/SetmenuControl.php');
            $_REQUEST['diony']='yes';
            if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
                $smarty->display('TemplateCalendar/CalendarTemplateEntries.tpl');
                exit();
            }
            else {
                $arr['content']= $smarty->fetch('TemplateCalendar/CalendarTemplateListView.tpl');
                ConvertTojsonString(1,$arr,"success");
            }
            break;
        case 'edit_template':  //显示日程模板详情页

            $smarty=new lingdangCRM_Smarty;

            $mode='create';
            if(isset($_REQUEST['mode']))
                $mode=$_REQUEST['mode'];
            $baseinfo = $calobj->getTemplateBaseInfo();
            $baseinfo[] = $calobj->getAllocateInfo();

            $smarty->assign('APPROVE',$baseinfo);
            /* 区分新建或编辑 */
            $smarty->assign('MODE',$mode);
            $smarty->assign('BLOCKID',$_REQUEST['blockid']);
            $smarty->assign('RECORD',$_REQUEST['record']);
            $smarty->assign("mokuai_name",getTranstab(getTabname($_REQUEST['blockid'])));
            $smarty->assign("APPROVEALLOCATEID",$calobj->getAllocateUsers());
            crm_load_class_file("CommonView","modules/CustomView");
            /* 模板明细 */
            $smarty->assign('CALENDARTEMPLATEDETAILS',$calobj->getCalendarDetailContent(array(),''));
            /* html格式明细列头 */
            $smarty->assign('DERAILHEARDERS',$calobj->getCalendarDetailContent_header());
            /* 明细列头 */
            $smarty->assign('TEMPLATEDETAILHEADER',Zend_Json::encode($calobj->detailheader_multiarr));
			require_once('modules/CustomView/CustomView_Columnlist.php');
			crm_load_class_file("CommonView","modules/CustomView");
			$tabname=getTabname($_REQUEST['blockid']);
			$oCustomView = CustomView::getInstance($tabname);
			$modulecollist = $oCustomView->getModuleColumnsList($tabname);
			$modulecolumnshtml = CustomView_Columnlist::getByModule_ColumnsHTML($tabname,$modulecollist);//高级查询模块字段
			$arr['criteria_groups']=$calobj->getAdvancedSearchCriteriaList($baseinfo[0]['judgeinfo'],$baseinfo[0]['judgeinfo_groups']);
			$arr['foption']=$calobj->getAdvCriteriaHTML();
			$arr['columns_block']=$modulecolumnshtml;
            $fLabels = CommonView::getComparatorLabel();
			$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            $controller = ListViewController::getInstance($tabname);
            $arr['advanceFields'] = $controller->getAdvanceFields();
			$_REQUEST['diony']='diony';
            $focus = CRMEntity::getInstance($tabname);
            $fields=$focus->fieldobj->getFieldListArray();
            $arr['fields']=$fields['fields'];
			$arr['title'] = getFixedLabel('LBL_CALENDAR_TEMPLATE');
			$arr['oktext']=getFixedLabel("SAVE");
			$arr['canceltext']=getFixedLabel("CANCEL");
			$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
			$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
			$arr['flabels']=$fLabels;   
			$arr['approve'] = $baseinfo;
			$arr['approveallocateid'] = $calobj->getAllocateUsers();
			$str=$smarty->fetch("TemplateCalendar/EditCalendarTemplate.tpl");
			$arr['content']=$str;
			ConvertTojsonString(1,$arr,"success");
            break;
        case 'save_template':    //保存日程模板
            $calobj->saveTemplateBaseInfo();
            $calobj->saveTemplateAllocateUser();
			$_REQUEST['diony']='diony';
            ConvertTojsonString(1,array(),"success");
            break;
        case 'save_allocate':  // 列表分配保存
            $calobj->saveTemplateAllocateUser();
			$_REQUEST['diony']='yes';
			ConvertTojsonString(1,array(),"success");
            break;
        case 'delete_template':  // 列表删除模板
            $calobj->deleteTemplate();
            $_REQUEST['diony']='yes';
			ConvertTojsonString(1,array(),"success");
            break;
        case 'newdetailrow':     // 明细新增一行日程
            $calobj->detailinfo = array();
            $smarty=new lingdangCRM_Smarty;
            if($_REQUEST['address'] != 'settings'){
                $smarty->assign('MODE', 'pop');
            }

            $smarty->assign('CALENDARTEMPLATEDETAILS',$calobj->getCalendarDetailContent(null,$_REQUEST['rownumber']));
            $smarty->display("TemplateCalendar/EditCalendarTemplate_DetailRow.tpl");
            break;
        case 'create_calendars':  // 详情页关联创建日程 CALENDARTEMPLATECONDITIONJUDGMENT

            $details = $calobj->createCalendars();

            if(isset($calobj->urldate['autoexec']) && empty($details)){
                echo '$==$AutoExecEmpty$==$';
                exit;
            }elseif(empty($details)){
                echo '$==$EmptyTemplate$==$';
                exit;
            }else{
                global $current_user;
                $smarty=new lingdangCRM_Smarty;
                /* 模板明细 */
                $smarty->assign('CALENDARTEMPLATEDETAILS',$details);
                /* html格式明细列头 */
                $smarty->assign('DERAILHEARDERS',$calobj->getCalendarDetailContent_header());
                /* 明细列头 */
                $smarty->assign('TEMPLATEDETAILHEADER',Zend_Json::encode($calobj->detailheader_multiarr));

                $smarty->assign('IS_ADMIN', is_admin($current_user));

                $smarty->assign('MODE', 'pop');

                $smarty->assign('CURRENTURLDATE', Zend_Json::encode($calobj->urldate));

                $smarty->assign('BLOCKID', $calobj->blockid);
                
                $smarty->assign('CURRENTUSERID',$current_user->id);
                $query = 'select fieldid,blockid from ld_settings_field where `name` = \'LBL_CALENDAR_TEMPLATE\'';
				$result = $adb->pquery($query,array());
				$blockidsetting = $adb->query_result($result,0,1);
				$fieldidsetting = $adb->query_result($result,0,0);
				$smarty->assign('BLOCKIDSETTING',$blockidsetting);

				$smarty->assign('FIELDIDSETTING',$fieldidsetting);
                $smarty->display("TemplateCalendar/Pop_EditCalendarTemplate.tpl");
            }
            break;
         case 'create_calendars_confirm':  // 保存关联创建的日程
             $calobj->saveRelatedTemplates();
             break;
    }
}
?>