<?php
/**
 * 审批页签列表
 * $approvestatus  0:待审批 1:已审批 3:我提交的
 * 优化：对于待审批和已审批页签，没有查询条件的情况下，不读主表，直接从ld_approvelog表读取
 *       由于我提交的页签要从主表读取审批状态，所以没有做此优化。
 * 查询条件包括：搜索内容、查询范围、模块名称(单选)、审批状态(我提交的页签)
 */
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$customView,$approvestatus,$mobile_pagerecordcount;
crm_load_class_file('cls_Approve_CountListViewWX','WeiXinApp/modules/Approve/cls_Approve');
if(isset($_REQUEST['approvestatus']) && !empty($_REQUEST['approvestatus'])){
	$approvestatus = $_REQUEST['approvestatus'];
}else{
	$approvestatus = 0;
}

$arrapprove=array(0,1,3,4);
if(!in_array($approvestatus,$arrapprove))
{
    ConvertTojsonString('-1',null,getFixedLabel('PARAMETERINPUTERROR'));    
}

$cls_Approve_CountListView = new cls_Approve_CountListViewWX($approvestatus);
$approveinfomc = $cls_Approve_CountListView->getapprovelist();

$viewmodules[] = array('text'=>getFixedLabel('ALL'),'value'=>'All','select'=>'yes'); 
foreach($approveinfomc as $infoval){
    $viewmodules[] = array('text'=>getTransTab($infoval['module']),'value'=>$infoval['module'],'select'=>'no');
    $approveinfo[] = $infoval['module'];
}

$page = $_REQUEST['page'];
$jsonArray['havenextpage']='no';
$searchcontent = $_REQUEST['filter']['searchcontent'];
$searchmodule = $_REQUEST['filter']['searchmodule']=='All'?'':$_REQUEST['filter']['searchmodule'];
$searchscope = empty($_REQUEST['filter']['SearchScope'])?'SmOwner_Search_All':$_REQUEST['filter']['SearchScope'];
$_REQUEST['filter']['searchstatus'] = $_REQUEST['filter']['searchstatus']=='All'?'':$_REQUEST['filter']['searchstatus'];
$searchstatus = $_REQUEST['filter']['searchstatus'];

if(!empty($searchmodule)) $approveinfo = array($searchmodule);
global $goapprovelogsql;
$goapprovelogsql = 0;
//可以直接读ld_approvelog表的条件
if(empty($searchcontent)&&$searchcontent!==0&&$searchcontent!=='0'&&$approvestatus!=3&&empty($searchmodule)&&$searchscope=='SmOwner_Search_All'){
    $goapprovelogsql = 1;
}
$list = array();
if(!empty($approveinfo)&&!empty($approveinfo[0])){
    crm_load_class_file('cls_Approve_ListViewWX','WeiXinApp/modules/Approve/cls_Approve');
    crm_load_class_file('cls_Approve_CustomViewWX','WeiXinApp/modules/Approve/cls_Approve');
    
    if($approvestatus==3){
        $sql = 'select indexid,approvestatus,approveurgent,approveexpediting from (';
    }else{
        $sql = 'select indexid,approveurgent,approveexpediting from (';
    }
    //zxm 2021-0611   0046343（企业微信移动端-kfbcrm）待办界面一直显示加载中
    if($goapprovelogsql) {
        $sql = 'select indexid,approveurgent,approveexpediting from (';
    }
    $count_sql = 'select count(1) from (';
    $module_sql = '';

    foreach($approveinfo as $key=>$info){
        $module = $info;
        $_REQUEST['fromapprovemodule'] = $module;
        $customView = new cls_Approve_CustomViewWX($module);
        $viewid = $customView->getViewId($module);
        $queryGenerator = new cls_Approve_ListViewWX($module);
        $focus = $queryGenerator->focus;
        $modulesql = $queryGenerator->getModuleApproveQuery($module, $current_user,$customView);

        if($key>0){
            $module_sql .= ' UNION '.$modulesql;
        }else{
            $module_sql .= $modulesql;
        }
    }

    $count_sql .= $module_sql.') as aaa';
   
    $count_result = $adb->pquery($count_sql,array());
    
    $noofrows = $adb->query_result($count_result,0,0);
    $navigation_array = cls_StaticCommonFun::VT_getJsonSimpleNavigationValues($page,$fromApproveModule,$noofrows);
    $_REQUEST['start']=$navigation_array['startpagenum']+1;
    $startpagerecord=$navigation_array['startpagenum']*$mobile_pagerecordcount;

    //ls 2021-08-11  【ID1001881】航港：加急（优先）审批
    //edit:can 小程序移动端的待审批维保计划单据的排序与pc端的审批中心->待处理维保计划单据排序不一致。pc端的是升序，而小
    if($approvestatus == 0){ //duan 移动端待审批页签按照审批时间从旧到新排序，其他页签从新到旧 
        //duan 20230202  泰开要求移动端待审批界面按照从新到旧排序
        $VersionInfo = getVersionInfo();
        if($VersionInfo['account'] == 'taikai'){
            $tmp_order = 'desc';
        }else{
            $tmp_order = 'asc';
        }
    }else{
        $tmp_order = 'desc';
    }
    $sql .= $module_sql.') as aaa order by (case when approveexpediting=\'yes\' then 0 when approveurgent=\'yes\' then 1 else 2 end),approveby_datetime '.$tmp_order.' limit '.$startpagerecord.','.$mobile_pagerecordcount;
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    if($num_rows>0){
        crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
        for($i=0;$i<$num_rows;$i++){
            $record = $adb->query_result($result,$i,'indexid');
            $module = getSalesEntityType($record);
            if(empty($module)) continue;
            $mobj = new cls_ListViewWX($module);
            $content = $mobj->getRecordContent($record);
            //editor:gyq_20180918	0035247: （企业微信登录）审批列表界面：已删除的单据不应显示在列表界面
            if(empty($content)){
                continue;
            }
            $content['module'] = $module;
            $content['modulename'] = getTranstab($module);
            $approveurgent = $adb->query_result($result,$i,'approveurgent');//单据加急状态
            $approveexpediting = $adb->query_result($result,$i,'approveexpediting');//单据催审状态
            
            $returnlabel = '';
            $returnurgent = 'no';
            if($approveexpediting=='yes'){
                $returnurgent= 'yes';
                $returnlabel = getFixedLabel("Expedit");
            }
            else if($approveurgent == 'yes'){
                $returnurgent = 'yes';
                $returnlabel = getFixedLabel("Urgent");
            }
            $content['approveurgent'] = $returnurgent;//返回状态：是否显示单据加急或催审状态
            $content['returnlabel'] = $returnlabel;//返回状态对应文字显示文字，
            //我提交的页签，显示审批状态
            if($approvestatus==3){
                $approvestatus_result = $adb->query_result($result,$i,'approvestatus');
                switch($approvestatus_result){
                    case '未提交':$approvestatus_result = getFixedLabel('Unapproved');break;
                    case '审批中':$approvestatus_result = getFixedLabel('Approvalof');break;
                    case '已批准':$approvestatus_result = getFixedLabel('Approved');break;
                    case '已拒绝':$approvestatus_result = getFixedLabel('Rejected');break;
                    case '已驳回':$approvestatus_result = getFixedLabel('Dismissed');break;
                    default:break;
                }
                $content['approvestatus'] = $approvestatus_result;
            }
            $list[] = $content;
        }
    }
    
    $jsonArray['pagecount']=$navigation_array['totalpagecount'];
    $jsonArray['havenextpage']=$navigation_array['havenextpage'];
    $jsonArray['haveprevpage']=$navigation_array['haveprevpage'];
    $jsonArray['curpagenum']=$navigation_array['startpagenum']+1;
    $jsonArray['listcount']=$noofrows;
}

$jsonArray['list1']=$list;//查询数据内容

//筛选条件
$searchscopearr['fieldlabel'] = getFixedLabel('VIEWRANGE');
$searchscopearr['fieldname'] = 'SearchScope';
$searchscopearr['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','select'=>'yes');
$searchscopearr['option'][] = array('text'=>getFixedLabel('Mine'),'value'=>'SmOwner_Search_Me','select'=>'no');
$searchscopearr['option'][] = array('text'=>getFixedLabel('LBL_SENIOR'),'value'=>'smowner_search_senior','select'=>'no');

$searchstatusarr['fieldlabel'] = getFixedLabel('approvestatus');
$searchstatusarr['fieldname'] = 'searchstatus';
$searchstatusarr['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'All','select'=>'yes');
$searchstatusarr['option'][] = array('text'=>getFixedLabel('Unapproved'),'value'=>'未提交','select'=>'no');
$searchstatusarr['option'][] = array('text'=>getFixedLabel('Approvalof'),'value'=>'审批中','select'=>'no');
$searchstatusarr['option'][] = array('text'=>getFixedLabel('Approved'),'value'=>'已批准','select'=>'no');
$searchstatusarr['option'][] = array('text'=>getFixedLabel('Dismissed'),'value'=>'已驳回','select'=>'no');
$searchstatusarr['option'][] = array('text'=>getFixedLabel('Rejected'),'value'=>'已拒绝','select'=>'no');

$searchmodulearr['fieldlabel'] = getFixedLabel('MODULENAME');
$searchmodulearr['fieldname'] = 'searchmodule';
$searchmodulearr['option'] = $viewmodules;
$jsonArray['list'][] = $searchscopearr;
if($approvestatus==3) $jsonArray['list'][]=$searchstatusarr;
$jsonArray['list'][] = $searchmodulearr;

//duan 20221010 添加翻译字符串返回
$approve_label_arr=array(
    'APPROVALITEMS',//审批事项
    'SALESASSISTANT',//销售助手
    'CRITICALVIEW',//关键视图
    'Pending1',//待审批
    'Approved',//已批准
    'isubmitted1',//我提交的
    'ApproveRejected',//被驳回的
    'NODATATOBEAPPROVED',//没有待审批数据
    'NOMOREDATATOBEAPPROVED',//没有更多待审批数据
    'NOAPPROVEDDATA',//没有已批准数据
    'NOMOREAPPROVEDDATA',//没有更多已批准数据
    'NODATASUBMITTEDBYME',//没有我提交的数据
    'NOMOREDATASUBMITTEDBYME',//没有更多我提交的数据
    'NOREJECTEDDATA',//没有被驳回的数据
    'NOMOREREJECTEDDATA',//没有更多被驳回的数据
    'APPROVAL',//审批
    'SEARCHNEW',//搜索
    'APPWORKBENCH',//工作台
    'APPFUNCTION',//功能
    'staydo',//待办
    'OFTENUSEREPORTWORD',//报表
    'APPSETTINGS',//设置
    'SET',//设置
    'nodata',//没有数据
    'NOMOREDATA',//没有更多数据
    'RemindsCenter',//消息中心
    'LBL_UNREADEN',//未读
    'LBL_READEN',//已读
    'LBL_SENDED',//我发送的
    'SetAllAsRead',//全部已读
);
$approve_fixedlabel_arr = TransFieldlabel($approve_label_arr);
$jsonArray['arrFixedLabel'] = $approve_fixedlabel_arr;
//审批列表页内容
$label_arr=array(
    'Rejected',//已拒绝
    'Dismissed',//已驳回
    'Approved',//已批准
    'Approvalof',//审批中
    'Urgent',//急
    'WARMPROMPT',//温馨提示
    'Unapproved',//未提交
);
$content_fixedlabel_arr = TransFieldlabel($label_arr,'no');
$jsonArray['arrFixedLabel_content'] = $content_fixedlabel_arr;

// 消息中心——未读消息条数
require_once(globalStatic::$root_directory.'modules/Reminds/static_reminds.php');
$remindscount = static_Reminds::getRemindsCount();
if($remindscount == 0)
    $remindscount = '';
$jsonArray['remindscount'] = $remindscount;

ConvertTojsonString(1,$jsonArray,'');
?>