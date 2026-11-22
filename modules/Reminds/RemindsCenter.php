<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_RemindsCenter','modules/Reminds');
crm_load_class_file('RemindsQueryGenerator','include/QueryGenerator');
global $adb,$current_user;
$remindscenterObj = new cls_RemindsCenter();
$smarty = new lingdangCRM_Smarty;
$module = 'Reminds';
$mode = '';
if(isset($_REQUEST['mode']) && !empty($_REQUEST['mode'])){
    $mode = $_REQUEST['mode'];
}
$_REQUEST['diony']='yes';

if (!empty($mode)) {
    switch ($mode) {
        // 获取分类
        case 'getcategory':
            $category_arr = $remindscenterObj->getDataCategory();
            $arr['category_arr'] = $category_arr;
            // dump($category_arr);
            $is_admin = 'no';
            if($current_user->is_admin == 'on'){
                $is_admin = 'yes';
            }
            $arr['is_admin'] = $is_admin;
            $arr['title'] = getFixedLabel("REMINDS");
            unset($remindscenterObj,$category_arr);
            ConvertTojsonString(1,$arr,"success");
            break;

        // 设置分类
        case 'setcategory':

            $customview_html = $remindscenterObj->customView->getCustomView_RemindsCategory();
            $cv_grouplist = $remindscenterObj->customView->getCustomViewGroupList($customview_html)['groupList'];
            
            $arr['cv_grouplist'] = $cv_grouplist;
            $arr['title'] = getFixedLabel("MANAGECATEGORIES");
            unset($remindscenterObj,$customview_html,$cv_grouplist);
            ConvertTojsonString(1,$arr,"success");
            break;

        // 获取列表
        case 'getlist':
            $remindscategoryid = $_REQUEST['remindscategoryid'];// 消息分类id
            if($remindscenterObj->customView->getViewDetailInfo($remindscategoryid) == ''){// 分类已被删除
                ConvertTojsonString(-2,$arr,getFixedLabel('RECORDDELETED'));
            }

            $cvid = $_REQUEST['cvid'];// 未读，已读的id
            // 页数
            if(isset($_REQUEST['pagenum']) && !empty($_REQUEST['pagenum'])){
                $pagenum = $_REQUEST['pagenum'];
            }else{
                $pagenum = 1;
            }
            // 类型：整个弹出层内容or仅列表
            if(isset($_REQUEST['type']) && !empty($_REQUEST['type'])){
                $type = $_REQUEST['type'];
            }else{
                $type = 'entires';
            }
            $remindscenterObj->setPagenum($pagenum);
            // 是否有查找
            if($_REQUEST['query'] == 'true') {
                $remindscenterObj->setSearchConditions($_REQUEST);
            }
            // 列表数据
            $listdata = $remindscenterObj->getListByPagenum($remindscategoryid,$cvid);
            $arr['listdata'] = $listdata;
            $smarty->assign('ListData', $listdata);
            // dump($listdata);
            // 页签
            $NavBarList = [];
            $ListTab_arr = $remindscenterObj->customView->getCustomView_RemindsNavBar();
            foreach ($ListTab_arr as $index => $viewinfo) {
                $tmplabel = $viewinfo['viewname'];
                // 全部，未读页签带条数
                $numofreminds = 0;
                if($remindscenterObj->focus->show_customview_num == 'yes'){
                    if(!in_array($viewinfo['cvid'],[114,115])){
                        if($viewinfo['cvid'] != $cvid){// 不是当前页签,需要获取一下条数
                            $remindscenterObj->getEntireListSql($remindscategoryid,$viewinfo['cvid']);
                        }
                        $numofreminds = $remindscenterObj->noofrows_arr[$remindscategoryid][$viewinfo['cvid']];
                        $tmplabel = ($viewinfo['viewname'].'（'.$numofreminds.'）');
                    }
                }

                $NavBarList[$index] = ['label' => $tmplabel,'id' => $viewinfo['cvid'], 'num' => $numofreminds, 'rawlabel' => $viewinfo['viewname']];// ,'selected' => $selected
            }
            $arr['NavBarList'] = $NavBarList;
            // 分页
            crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
            $noofrows = $remindscenterObj->noofrows_arr[$remindscategoryid][$cvid];
            $recordListRangeMsg = getRecordRangeMessage('', '',$noofrows);
            $smarty->assign('recordListRange',$recordListRangeMsg);
            $navigation_array = VT_getSimpleNavigationValues($pagenum,$remindscenterObj->list_max_entries_per_page_new,$noofrows);
            $navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, '', $module, 'index');
            $smarty->assign("NAVIGATION", $navigationOutput);
            // dump($navigation_array);
            
            // 翻译
            $label_arr = ['setreaden' => getFixedLabel('SetAllAsRead'),'setunread' => getFixedLabel('SetAllAsUnread')];
            $arr['label_arr'] = $label_arr;
            // 基础查找的字段
            $controller = $remindscenterObj->controller_arr[$remindscategoryid][$cvid];
            $listview_header_search = $controller->getBasicSearchFieldInfoList();
            $smarty->assign('SEARCHLISTHEADER',$listview_header_search);
            if($type == 'entires'){
                // 高级查找
                $fieldnames = $controller->getAdvancedSearchOptionString();
                $arr['advancefieldnames']=$fieldnames;

                $arr['content']= $smarty->fetch('modules/Reminds/RemindsCenterListEntries.tpl');
            }else{
                $arr['content']= $smarty->fetch('modules/Reminds/RemindsCenterList.tpl');
            }
            // dump($remindscenterObj->noofrows_arr);
            unset($remindscenterObj,$controller,$navigation_array,$navigationOutput);
            ConvertTojsonString(1,$arr,"success");
            break;

        // 获取指定分类中的未读条数
        case 'gettargetcategory':
            $remindscenterObj->getEntireListSql($_REQUEST['remindscategoryid'],getRemindsCvid('unread'));
            $newreminds_num = $remindscenterObj->noofrows_arr[$_REQUEST['remindscategoryid']][getRemindsCvid('unread')];
            $arr['newreminds_num'] = $newreminds_num;
            $arr['icon_path'] = 'themes/icon2024/remindscategory-default.png';
            unset($remindscenterObj);
            ConvertTojsonString(1,$arr,"success");
            break;

        // 全部设为未读
        case 'setunread':
        // 全部设为已读
        case 'setreaden':
            $remindscategoryid = $_REQUEST['remindscategoryid'];// 消息分类id
            $remindscenterObj->setSearchConditions($_REQUEST);// 增加查找条件
            $remindscenterObj->setAllReadStatus($remindscategoryid, $mode);
            unset($remindscenterObj);
            ConvertTojsonString(1,$arr,"success");
            break;

        // 列表界面-刷新消息类型
        case 'reloadlistcategory':
            $category_arr = $remindscenterObj->getDataCategory();
            $arr['category_arr'] = $category_arr;
            if(isset($_REQUEST['selected_remindscategoryid']) && !empty($_REQUEST['selected_remindscategoryid'])){
                $selected_remindscategoryid = $_REQUEST['selected_remindscategoryid'];
            }
            if(empty($selected_remindscategoryid)){
                $selected_remindscategoryid = $category_arr[0]['remindscategoryid'];
            }
            $smarty->assign("Category_arr",$category_arr);
            $smarty->assign('selected_remindscategoryid',$selected_remindscategoryid);// 所选分类
            $arr['content']= $smarty->fetch('modules/Reminds/ListViewCategoryTree.tpl');
            unset($remindscenterObj,$category_arr);
            ConvertTojsonString(1,$arr,"success");
            break;
        // 消息中心，点击进入消息详情页
        case 'listlinkclick':
            include('modules/Reminds/SetRemindReaden.php');
            ConvertTojsonString(1,$arr,"success");
            break;
        default:
            
            break;
    }

    ConvertTojsonString(1, $arr, '');

} else {
    ConvertTojsonString(-1, array(), getFixedLabel('NOMATCHINGITEMS'));
}