<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2014-03-31
 */
//zkt 20231102 XUQIU1001892 PC端高危优化-水平越权优化（文档中第三个问题）（王耀文）
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('PopUpListView','include/Popup');
global $adb;
global $current_user;
global $relationId;
global $related_left_type;
global $related_func_type;
global $related_left_id;
global $related_left_record;
global $related_left_tabid;
global $related_left_mod;
global $related_left_customView;
global $related_left_viewid;
global $related_left_listmodule;
global $related_header;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;
$relationId =  vtlib_purify($_REQUEST['relatedid']);
$getEditDetail =  vtlib_purify($_REQUEST['isEditDetail']);
$logid =  vtlib_purify($_REQUEST['logid']);
$smarty->assign("LOGID",$logid);
$smarty->assign("GETEDITDETAIL",$getEditDetail);
$_REQUEST['diony']='diony';


if(!empty($relationId) && ((int)$relationId) > 0) {
	$record =  vtlib_purify($_REQUEST['record']);
    //if($_REQUEST['header'] == 'ServiceCharge')$_REQUEST['header'] = 'Accounts';
	$header = vtlib_purify($_REQUEST['header']);//module;
    $tabid = getTabid($header);
    $related_header = $header;
	$related_left_type = vtlib_purify($_REQUEST['related_left_type']);//;
	if(empty($header)) return '';

	$currentModule = $header;
	$focus = CRMEntity::getInstance($currentModule);
	$focus->retrieve_entity_info($record, $currentModule);
    crm_load_function_file('getRelatedListInfoById','include/utils','DetailViewUtils');
	$relationInfo = getRelatedListInfoById($relationId);
    $type=strtolower($relationInfo['type']??'');
	$version=getVersionTradeInfo();
    if($type=='datacategory_template_js'||$type=='datacategory_templatelink')//自定义报表
    {
        //自定义报表

        if(strtolower($relationInfo['related_coltable'])=='crmlink')
        {
            $default_report=1;
        }
        else
        {
            $default_report=0;
        }
        $straplh=array('a','b','A','E','B','C','c','f','g','H','z','X','Y');
        
        $random=rand(1,9);
        $tmpuserid=$current_user->id*$random;
        $lenuserid=strlen($tmpuserid)+10;
        $encryptrecord=$_REQUEST['record']+$tmpuserid;
        $encryptrecord.=$tmpuserid.$lenuserid.$random;
        $strrecord='';
        for($tmpi=0;$tmpi<strlen($encryptrecord);$tmpi++)
        {
            $digit=substr($encryptrecord,$tmpi,1);
            $strrecord.=$straplh[$digit];
        }
        $tmp=array("content"=>'','type'=>strtolower($relationInfo['type'])
                    ,'functionname'=>$relationInfo['functionName']
                    ,'default_report'=>$default_report,'report_name'=>$relationInfo['label']
                    ,'record'=>$strrecord);
        //自定义报表
        ConvertTojsonString(1,$tmp,'success');
    }
    else if($type=='datacategory_template_url'){//甘特图
        $tmp=array("content"=>'','type'=>strtolower($relationInfo['type'])
                    ,'functionname'=>$relationInfo['functionName']
                    ,'default_report'=>$default_report,'report_name'=>$relationInfo['label']
                    ,'record'=>$record);
        ConvertTojsonString(1,$tmp,'success');
    }

    // @edit:dong @date:2020/07/15 @reason: 表单推广数据统计。
    if($relationInfo['functionName']=='get_SocialPromotionReport' && $relationInfo['label']='SocialPromotionReport'){
        // @edit:dong @date:2020/7/8 @reason: 表单表单类
        crm_load_class_file("SocialPromotionForm",'modules/SocialPromotion');
        $socialPromotionForm = new SocialPromotionForm($focus->column_fields);
        // @edit:dong @date:2020/7/10 @reason:  获取页面所需要的所有数据
        $content = $socialPromotionForm->getReportFormContent($smarty,$record,$focus);
        ConvertTojsonString(1,array('content'=>$content),'success');
    } elseif ($relationInfo['functionName']=='get_QuestionnaireReport' && $relationInfo['label']='QuestionnaireReport') {
        $reportData = $focus->get_QuestionnaireReport($smarty,$record);
        ConvertTojsonString(1,array('content'=>$reportData['content'],'reportArr'=>$reportData['reportArr']),'success');
    }elseif ($relationInfo['functionName']=='get_QuestionnaireChartsave' && $relationInfo['label']='QuestionnaireChartsave') {
        $reportData = $focus->get_QuestionnaireChartsave($smarty,$record,$_REQUEST['start']);
        ConvertTojsonString(1,array('content'=>$reportData['content'],'reportArr'=>$reportData['reportArr']),'success');
    }

    //@edit:liushuai,2020-10-22,reason:ID1000713/企业微信会话存档(获取相关会话数据)  客戶模块和联系人模块
    if ($relationInfo['functionName'] == 'get_wechatsession' && $relationInfo['label'] = 'Wechatsession') {
//        crm_load_class_file("WeChatSession", 'modules/Accounts');
//        $weChatSession = new WeChatSession();
//        $content = $weChatSession->get_wechatsession($smarty,$record,$focus);
        global $wechatsession_page_size;
        $wechatsession_page_size=10;
        include ($root_directory.'modules/Accounts/WeChatSession.php');
        $data = get_wechatsession($currentModule,$record);
        $smarty->assign('record', $data["record"]);
        $smarty->assign('wx_userid', $data["wx_userid"]);
        $smarty->assign('weChatDatas', $data["weChatDatas"]);
        $smarty->assign('page_num', $data['page_num']); //总页数
        $smarty->assign('page', $data['page']);  //当前显示页数
        $content = $smarty->fetch('Accounts/WeChatSession.tpl');
        ConvertTojsonString(1,array('content'=>$content),'success');
    }
	$related_left_id = $relationId;
	$related_left_tabid = $relationInfo['relatedTabId'];
	$related_left_record = $record;
	$related_left_mod = $header;
	$related_left_mod_href_name = getModuleHref($related_left_mod,$_REQUEST['record']);
	if($relationInfo['relatedTabId'] > 0){
		$relatedModule = getTabname($relationInfo['relatedTabId']);
	//	require_once('modules/'.$relatedModule.'/'.$relatedModule.'.php');
    }
   // $focus=CRMEntity::getInstance($relatedModule);
   
    $related_left_listmodule = $relatedModule;
	$function_name = $relationInfo['functionName'];
	//添加get_related_list判断，服务单与服务合同是多对多关联方式。
   
    //var_dump(getEduType());
    //教育行業 更多信息查看班級
    if(getEduType('Edu') == false)
    {
        if($relatedModule == 'ServiceContracts' && $function_name != 'get_related_list'){
    		$function_name = 'get_ServiceContracts';
    	}
    }
	//chj 2021/3/5 44802: （https://61mis.com/kfbcrm [^]）客户管理-跟进记录测试；相关信息设置中有一个签到记录，将它放到已选栏目之后，并没有在相关信息中出现
    if($relatedModule != 'CommunicationLog' && ($relatedModule != 'Singin' || $function_name == 'get_singin_list') && $relationInfo['relatedTabId'] > 0)
    {
        $related_left_customView =CustomView::getInstance($relatedModule);
  
	  
    }
	if($relatedModule != 'CommunicationLog' && ($relatedModule != 'Singin' || $function_name == 'get_singin_list') && $relationInfo['relatedTabId'] > 0)
    {
        if($relatedModule == 'Reminds'){
            crm_load_class_file("RemindsCustomView",'modules/Reminds');
            $related_left_customView = RemindsCustomView::getInstance($relatedModule);
        }else{
            $related_left_customView = CustomView::getInstance($relatedModule);
        }
        if('Accounts' == $relatedModule){
        	$related_left_viewid = (isset($_REQUEST['viewid']) && $_REQUEST['viewid']>0)?
            $_REQUEST['viewid']:$related_left_customView->getViewId($relatedModule,'popup');
        }else{
            $related_left_viewid = (isset($_REQUEST['viewid']) && $_REQUEST['viewid']>0)?
            $_REQUEST['viewid']:$related_left_customView->getViewId($relatedModule);
        }

    }
	/**
	 * 日程管理模块特别处理
	 * @reason 0013678: 客户--明细：点击相关信息模块，列表界面，点击刷新按钮，刷新页面错误。
	 * @author Tujt 2015-03-02
	 */
	if('Calendar' == $relatedModule){
		$_SESSION['lvs']['Events']['viewname'] = $related_left_viewid;
	}else if($relatedModule == 'Accounts'){
	   $_SESSION['lvs']['Accounts_ALLACCOUNT']['viewname'] = $related_left_viewid;
	}else{
		$_SESSION['lvs'][$relatedModule]['viewname'] = $related_left_viewid;
	}

	$related_func_type = getRelatedFuncType($header,$relatedModule,
					$relationInfo['relatedTabId'],$function_name,$relationInfo['actions']);
	$customview_html = '';

    /**
     * @edit:cyb
     * @date:2016-03-16
     * @reason:具有共享权限的模块相关信息下--共享选项
    **/
    if($relationInfo['functionName']=='get_SharedUsers' &&$relationInfo['label']='SharedUsers')
    {
        //require_once('modules/Users/SetRelatedInfo.php');
        $shareuserobj=crm_load_class_obj("SetRelatedInfo",'modules/Users');
        $relatedListData=$shareuserobj->get_SharedUsers($currentModule,$record, $tabid,$relationInfo['relationId'],
								$relationInfo['relatedTabId'], $relationInfo['actions']);
       	$operationWidth = '80';

    	$smarty->assign('RELATEDTABLEWIDTH',$operationWidth);
    }
    elseif($relationInfo['label']=='ChangeView'||$relationInfo['label']=='ViewHistory'||$relationInfo['label']=='OperationLogs'){
        $fieldlogobj=crm_load_class_obj("SetRelatedInfo",'modules/Users');
        $fieldlogobj->setLogId($logid);
        $fieldlogobj->setIsEditDetail($getEditDetail);
        $relatedListData=$fieldlogobj->getFieldUpdateLog($currentModule,$record,$tabid,$relationInfo);
        //zl XUQIU1000760 富文本框是否隐藏
        $smarty->assign('CURLOGINFO', $fieldlogobj->getCurLogInfo());
        $smarty->assign('RICHTEXTHIDE',$relatedListData['Richtexthide']);
        //判断当前模块是否需要显示单据分录修改日志
        if($relationInfo['label']=='ViewHistory'){
            if($currentModule == 'ServiceCharge'){
                $showdetaillog = 'no';
            }else if($currentModule == 'Potentials'){
                $deployarray=getSys_deploy(205);//销售机会是否显示产品分录明细:0是，1否
                if($deployarray['deploy_value']==0){
                    $showdetaillog = 'yes';
                }else{
                    $showdetaillog = 'no';
                }
            }else if($currentModule == 'CashBill'){
                if($focus->column_fields['cashtype'] == 'debuction'){//xxy 2023-12-8 预收单单据分录修改日志，源单类型、源单等字段应该不显示，预收单单据分录修改日志不会增加所以直接去掉了
                    $showdetaillog = 'no';
                }else{
                    $showdetaillog = 'yes';
                }
            }else if(get_file_address($currentModule,$currentModule."DetailFieldsHtml")||get_file_address($currentModule,"ProductDetails")){
                //有单据分录的模块显示分录修改日志
                $showdetaillog = 'yes';
            }else{
                $showdetaillog = 'no';
            }
            $smarty->assign('SHOWDETAILLOG',$showdetaillog);
            $smarty->assign('LOGTYPE',$_REQUEST['detaillog']);

        }

    }
    elseif($relationInfo['label']=='signlog'){	//微信用户签到日志
        $fieldlogobj=crm_load_class_obj("SetRelatedInfo",'modules/Users');
        $relatedListData=$fieldlogobj->getWeChatUserSignLog($currentModule,$record,$tabid,$relationInfo);
    }
    elseif($relationInfo['label']=='publicaccount_log'){	//公海操作记录
        $fieldlogobj=crm_load_class_obj("SetRelatedInfo",'modules/Users');
      if($currentModule=='Leads')
      {
        $relatedListData=$fieldlogobj->getPublicLeadsLog($currentModule,$record,$tabid,$relationInfo);
      }
      else
        $relatedListData=$fieldlogobj->getPublicAccountLog($currentModule,$record,$tabid,$relationInfo);
        // 0044029: 公海日志：客户详情界面-公海日志，操作列显示为……时，鼠标移动到上面没有显示tips
        foreach($relatedListData['entries'] as &$v){
            $v['opdate'] = '<span title="'.$v['opdate'].'">'.$v['opdate'].'</span>';
            $v['operation'] = '<span title="'.$v['operation'].'">'.$v['operation'].'</span>';
            //BUG0054653 wyt 220803 公海日志没有显示公海池
            $v['zh_name'] = '<span title="'.$v['zh_name'].'">'.$v['zh_name'].'</span>';
            //chj 2021/5/28 46110: （61mis.com/WX/kh43633）客户001账套，客户管理-公海客户，客户详情的公海日志，操作人显示带有特殊字符
            $v['username'] = $v['username'];
        }
    }
    elseif($relationInfo['functionName']=='get_SocialPromotionForm' &&$relationInfo['label']='SocialPromotionForm') {
        // @edit:dong @date:2020/7/8 @reason:  社交推广 外部表单数据
        crm_load_class_file("SocialPromotionForm", 'modules/SocialPromotion');
        $socialPromotionForm = new SocialPromotionForm($focus->column_fields);
        // @edit:dong @date:2020/7/10 @reason:  获取页面所需要的所有数据
        $relatedListData = $socialPromotionForm->get_SocialPromotionForm($currentModule, $record, $focus->column_fields['mappingmodule'], $focus->column_fields['smcreatorid'],$relationInfo);
    }
    elseif($relationInfo['functionName']=='get_readrecord' &&$relationInfo['label']='ReadRecord') {
        // @edit:liushuai,2021-04-16,reason:【ID1001520】公告增加阅读数和阅读记录
        $related_left_viewid=$_REQUEST['viewid'];
        crm_load_class_file("RemindsCustomView",'modules/Reminds');
        $related_left_customView = RemindsCustomView::getInstance('Reminds');
        if(empty($related_left_viewid))
        {
            // $related_left_viewid=$related_left_customView->getViewId('Reminds'); //默认第一条
            $related_left_viewid = getRemindsCvid('readen');//已读
        }
        $customview_html = $related_left_customView->getCustomView_RemindsNavBar('relatedleft');
        
        $relatedListData=$focus->getReadRecordLog($related_left_viewid,$currentModule,$record,$tabid,$relationInfo);

    }
    elseif ($relationInfo['functionName']=='get_contactsmap' && $relationInfo['label']=='ContactsMap'){
        //@edit:ljj,2023-07-28,reason:XUQIU1001536 单据查看详情界面，相关信息联系人列表的“联系人图谱”修改为相关信息“联系人图谱”模块
        $mapdata = array();
        $mapdata['show'] = 'yes';
        crm_load_class_file("cls_ModuleMap","modules/Users");
        $relatedModule = 'Contacts';
        if(isPermitted($relatedModule,'EditView','') == 'yes'){
            $smarty->assign('RELATEDMODULEEDIT','yes');
        }
        $cls_modulemapobj = new cls_ModuleMap($header,$relatedModule,$record,$relationId);
        $cls_modulemapobj->setRelationInfo($relationInfo);
        //获取保存的图谱信息
        $modulemapdateinfo = $cls_modulemapobj->getmapdateinfo();
        //获取字段信息
        $modulemapfieldinfo = $cls_modulemapobj->getmodulemapFieldInfo();
        //获取对应的数据信息 数据有问题
        $moduledatainfo = $cls_modulemapobj->getmoduleDatainfo();
        // ljj 20231229 XUQIU1002228 联系人图谱增加锁定功能
        $lockState = $cls_modulemapobj->getLockState($record,$relatedModule,$header);

        if(!empty($cls_modulemapobj->hreffieldinfo)){
            $hreffieldcolumnname = $cls_modulemapobj->hreffieldinfo->getColumnName();
        }
        $moduledataindex_arr = array_keys($moduledatainfo);
        $mapdata['mapdata_arr']=$modulemapdateinfo;
        $mapdata['modulemapfieldinfo']=$modulemapfieldinfo;
        $mapdata['moduledatainfo']=$moduledatainfo;
        $mapdata['moduledataindex_arr']=$moduledataindex_arr;
        $mapdata['hreffieldcolumnname']=$hreffieldcolumnname;

        $smarty->assign("RELATIONID",$relationId);
        $smarty->assign("MODULE",$header);
        $smarty->assign("ID",$record);
        $smarty->assign("RELATED_MODULE",$relatedModule);
        $smarty->assign("HEADER",$header);
        $smarty->assign("LOCKSTATE",$lockState);
        $content= $smarty->fetch("DetailView/RelatedListDataContentsMap.tpl");
        ConvertTojsonString(1,array('content'=>$content,'mapdata'=>$mapdata),'success');
    }
    elseif($relationInfo['label']=='trends'){//客户动态模块信息
        if($header=='Accounts'||$header=='ServiceCharge'){
            crm_load_class_file('cls_sales_trends','modules/Accounts');
            $obj_trends = new cls_sales_trends($record, $header);
            $result = $obj_trends->getList();
            $tmp_count = 0;
            foreach($result as $value){
                $tmp_count += sizeof($value['list']);
            }
            $smarty->assign("Trendinfos",$result);
            $content = $smarty->fetch('Accounts/Trends.tpl');
        }else if($header == 'WorkSheet'){
            //工单模块动态
            crm_load_class_file('cls_worksheet_trends','modules/WorkSheet');
            $obj_trends = new cls_worksheet_trends($record, $header);
            $result = $obj_trends->getList();
            $tmp_count = 0;

            foreach($result as $value){
                $tmp_count += sizeof($value['list']);
            }
            $smarty->assign("Trendinfos",$result);
            $content = $smarty->fetch('modules/WorkSheet/WorkTrends.tpl');

        }
        ConvertTojsonString(1,array('content'=>$content,'noofrows'=>$tmp_count),'success');
    }
    elseif($relationInfo['label']=='CallButler'){// 通话记录
        crm_load_class_file('cls_CallRecord','modules/Settings');
        $obj_callrecord = new cls_CallRecord($header, $record);
        $result = $obj_callrecord->getList();
        $tmp_count = 0;
        foreach($result as $value){
            $tmp_count += sizeof($value['list']);
        }
        $smarty->assign("CallRecordinfos",$result);
        $content = $smarty->fetch('CallRecord.tpl');
        ConvertTojsonString(1,array('content'=>$content,'noofrows'=>$tmp_count),'success');
    }
    elseif ($relationInfo['functionName']=='get_relationshipChart'){
        crm_load_class_file('cls_relationshipChart','modules/lingdang');
        $chartmodule = explode('_',$relationInfo['label'])[0];
        $cls_relationshipChartobj = cls_relationshipChart::getInstance($header,$record,$chartmodule);
        $cls_relationshipChartobj->setShowType('view');
        $relationshipChartArr = $cls_relationshipChartobj->getRelationshipChartHtml();
        ConvertTojsonString(1,$relationshipChartArr,'success');

    }
    elseif ($relationInfo['functionName'] == 'get_pricebook_products' && $relationInfo['label']=='Products'){
        $record = isset($_REQUEST['record']) ? $_REQUEST['record'] : 0;
        $start = isset($_REQUEST['start']) ? $_REQUEST['start'] : 1;
        $searchInfo = [];
        if (isset($_REQUEST['searchtype']) && isset($_REQUEST['search_text'])){
            $searchInfo['searchtype'] = $_REQUEST['searchtype'];
            $searchInfo['search_field'] = $_REQUEST['search_field'];
            $searchInfo['search_text'] = $_REQUEST['search_text'];
        }
        $order_by = '';
        if (isset($_REQUEST['order_by']) && isset($_REQUEST['sorder'])){
            $order_by = $_REQUEST['order_by'].' '.$_REQUEST['sorder'];
        }
        $relatedListData=$focus->get_pricebook_products($record,$relationInfo['actions'],$start,$searchInfo,$related_left_type,$order_by);
        $smarty->assign("SEARCHLISTHEADER",$relatedListData['basicSearchField']);
        $smarty->assign("showBasicSearchBtn",$relatedListData['showBasicSearchBtn']);
        $operationWidth = 120;
    }
    else if($relationInfo['type']==''){
        if (method_exists($focus, $function_name)) {
            $relatedListData=$focus->$function_name($_REQUEST['record'], $relationInfo['relatedTabId'],
                $relationInfo['relatedTabId'], $relationInfo['actions'],$relationInfo['relationId']);
        }


    }
    else{

        //包含“datacategory_sql"是有数据分类的模块
        if(stripos($relationInfo['type'],'datacategory_sql')!==false)
        {
            $related_left_viewid=$_REQUEST['viewid'];
            if(empty($related_left_viewid))
            {
                $related_left_viewid=$related_left_customView->getViewId($relatedModule);
            }
            if ($relatedModule == 'Reminds') {
                $customview_html = $related_left_customView->getCustomView_RemindsNavBar('relatedleft');
            }else{
                $customview_html = $related_left_customView->getCustomViewAll($related_left_viewid,$relatedModule,'','relatedleft');
            }

        }
        crm_load_class_file('cls_getRelatedInfoHtml','include/ListView/RelatedListView');
        $cls_getRelatedInfoobj=new cls_getRelatedInfoHtml($header,$relationInfo,$record);
        $relatedListData=$cls_getRelatedInfoobj->getRelateInfo();
        if($relationInfo['functionName']=='get_redemption' ){
            $operationWidth = '43';
            $smarty->assign('RELATEDTABLEWIDTH',$operationWidth);
        }
        else if($relationInfo['functionName']=='get_buyproductquantity' ){
            $operationWidth = '80';
            $smarty->assign('RELATEDTABLEWIDTH',$operationWidth);
        }
        else
        {
            $operationWidth=$relatedListData['operationwidth'];
        }
        if(file_exists("modules/$relatedModule/$relatedModule.php"))
        {
    		if($header == 'PriceBooks' && $relatedModule == 'Products'){
    			$operationWidth = '90';
    		}

        }
    }

    //  $smarty->assign("FIELDNAMES",$relatedListData['AdvanceFields']);
    setGLobalURLSmarty($smarty);
    $mapdata = array();
    $mapdata['show'] = 'no';
    //zkt 20221026 XUQIU1000463 灵当CRM详细需求-PC端_移动端：相关信息-联系人列表增加“联系人图谱”
    //zkt 20230104 BUG0060372相关信息联系人模块，调整列表排序后，联系人图谱不显示
    //zkt 20230404 BUG0063910 相关信息栏，联系人模块，点击选择查询分类，联系人图谱消失  &&(!isset($_REQUEST['viewid'])||!empty($_REQUEST['sorder']))
    if($relationInfo['relatedTabId']==getTabid('Contacts')){
        $mapdata['show'] = 'yes';
        // ljj 20230901 BUG0071525 kfbcrm-单据查看详情界面，若是相关信息模块启用“联系人图谱”模块后，相关信息“联系人”列表下方增加展示“联系人图谱”
        $sql='select presence from ld_relatedlists where tabid=? and related_tabid=-18';
        $result=$adb->pquery($sql,array($relationInfo['tabid']));
        if ($adb->num_rows($result)>0) {
            $presence = $adb->query_result($result, 0, 'presence');
            if ($presence == 0) {
                $smarty->assign('MAPDATASHOW','yes');
            }
        }
        if(isPermitted($relatedModule,'EditView','') == 'yes'){
            $smarty->assign('RELATEDMODULEEDIT','yes');
        }
        crm_load_class_file("cls_ModuleMap","modules/Users");
        $cls_modulemapobj = new cls_ModuleMap($header,$relatedModule,$record,$relationId);
        $cls_modulemapobj->setRelationInfo($relationInfo);
        //获取保存的图谱信息
        $modulemapdateinfo = $cls_modulemapobj->getmapdateinfo();
        //获取字段信息
        $modulemapfieldinfo = $cls_modulemapobj->getmodulemapFieldInfo();
        //获取对应的数据信息
        $moduledatainfo = $cls_modulemapobj->getmoduleDatainfo();
        if(!empty($cls_modulemapobj->hreffieldinfo)){
            $hreffieldcolumnname = $cls_modulemapobj->hreffieldinfo->getColumnName();
        }
        $moduledataindex_arr = array_keys($moduledatainfo);
        $mapdata['mapdata_arr']=$modulemapdateinfo;
        $mapdata['modulemapfieldinfo']=$modulemapfieldinfo;
        $mapdata['moduledatainfo']=$moduledatainfo;
        $mapdata['moduledataindex_arr']=$moduledataindex_arr;
        $mapdata['hreffieldcolumnname']=$hreffieldcolumnname;
        // ljj 20231229 XUQIU1002228 联系人图谱增加锁定功能
        $lockState = $cls_modulemapobj->getLockState($record,$relatedModule,$header);
        $smarty->assign("LOCKSTATE",$lockState);
    }

    $smarty->assign('RELATEDTABLEWIDTH',$operationWidth);
	$relatedListData['total_width'] = $relatedListData['total_width'] - 4;
	//print_r($relatedListData);die;
    $listwidthInfo=$relatedListData['fieldwidth'];
    $total_width=$operationWidth;
    foreach($listwidthInfo as $index=>$width) {
        $total_width+=$width;
    }

    $smarty->assign('TOTALWIDTH',$total_width);
	$smarty->assign("THEME", $theme);
	$smarty->assign("IMAGE_PATH", $image_path);
	$smarty->assign("ID",$record);
	$smarty->assign("MODULE",$header);
    //diony 2014-10-31 录音文件特殊控制
    // @edit:dong @date:2024/09/10 @reason: GuanJiaPoReport $relatedModule赋值
    if(empty($relatedModule)) {
        $relatedModule = $relationInfo['label'];
        if($relatedModule == 'GuanJiaPoReport' && isset($_REQUEST['erpModuleName'])){
            $relatedModule = $_REQUEST['erpModuleName'];
        }
    }
	$smarty->assign("RELATED_MODULE",$relatedModule);
	$smarty->assign("HEADER",$header);
	$smarty->assign("RELATIONID",$relationId);
	$smarty->assign('RELATEDLEFTMODHREFNAME',$related_left_mod_href_name);
    /*echo '<pre>';
    print_r($relatedListData);
    echo '<pre>';
    exit();*/
	if($version['account'] == 'dongmao'){
		if($_REQUEST['header'] == 'CustomForm99' && $_REQUEST['related_module'] == 'CustomForm98'){
			$relatedListData['CUSTOM_BUTTON'] = '<a title="选择" href="javascript:void(0);" onclick="CrmPopupWindow(\'CustomForm99\',\'module=ServiceCharge&return_module=CustomForm99&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&popup=yes&page_popup=yes&recordid='.$record.'\',\'ServiceCharge\');">
			<b class="icon-homeimg icon-selectbtn"></b><span>选择</span></a>';
		}
		if($_REQUEST['header'] == 'CustomForm97' && $_REQUEST['related_module'] == 'CustomForm96'){
			$relatedListData['CUSTOM_BUTTON'] .= '<a title="确认发放" href="javascript:void(0);" onclick="dongmao_saveCustomform96Data('.$record.')">
			<b class="icon-homeimg icon-selectbtn"></b><span>确认发放</span></a>';
		}
	}

    if($relatedListData['NoRecords_CONTENT']) $smarty->assign('NoRecords_CONTENT',$relatedListData['NoRecords_CONTENT']);
	$smarty->assign("RELATEDLISTDATA", $relatedListData);
    // $smarty->assign('CRITERIA_GROUPS',$relatedListData['advfilterlist']);
    $smarty->assign("CUSTOMVIEW_OPTION", $customview_html);
	$smarty->assign('SMOWERNAME',getUserFullName($focus->column_fields['assigned_user_id']));
	$smarty->assign('RELMODULE',$relationInfo['label']);

        $pageWidthPercent = 100;
	if($function_name == 'get_Kingdeeorders' || $function_name == 'get_Kingdeequotes'){
		$smarty->assign('PAGEWIDTHPERCENT', 250);
	}else{
		$smarty->assign('PAGEWIDTHPERCENT', 100);
	}
	$smarty->assign('VIEWID',$related_left_viewid);
	$smarty->assign('START',$_REQUEST['start']);
	//wym XUQIU1002043 单据相关信息显示数据的查询规则可定义
    $smarty->assign("ISADMIN",is_admin($current_user));
    $smarty->assign("SHOWADVANCESET",isset($relationInfo['related_advanceset']));

	if($related_func_type==3 || $related_func_type == 8 || $related_func_type == 7
    || $related_func_type == 9||get_file_address($relatedModule,$relatedModule."DetailFieldsHtml")
    ||get_file_address($relatedModule,"ProductDetails")){//edit:can 2021-01-13 044257: （36d139k914.wicp.vip:46978/crm/）工具-产品管理-相关信息（王恒新问题）；产品编号19.20.CP13012，产品相关信息中，医院模块点击选择单据编号POT59后，点击确定没反应
		include(globalStatic::$root_directory."data/Inventory.php");
		$listview_entries=$relatedListData['entries'];
		$row_count=$relatedListData['ROW_COUNT'];
		$row_header=sizeof($relatedListData['header']);

		if($header == 'Campaigns' && ($relatedModule == 'Contacts' ||  $relatedModule == 'Accounts')){
			if($relatedModule == 'Accounts'){
				$select_campaignaccountrelstatus = '';
				if(!empty($_REQUEST['select_campaignaccountrelstatus'])){
					$select_campaignaccountrelstatus = $_REQUEST['select_campaignaccountrelstatus'];
				}
				crm_load_function_file('getPicklistValesForNORole','modules/PickList','PickListUtils');
				$statuscombox=getEditViewPagePickList('campaignaccountrelstatus',$select_campaignaccountrelstatus,array(),'');
				$smarty->assign('SELECT_CAMPAIGNACCOUNTRELSTATUS',$select_campaignaccountrelstatus);
				$smarty->assign('STATUSCOMBOXVALUE',$statuscombox);
            }


			$smarty->assign('PROHTML',Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,'yes','related_list',$focus));
	   }else{

			$smarty->assign('PROHTML',Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,'no','related_list',$focus));
	   }
	   // {if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')}

        $smarty->assign('ROW_COUNT',$relatedListData['ROW_COUNT']);
        $version=getVersionTradeInfo();
        $version=$version['trade'];
        $smarty->assign('VERSION',$version);
        $smarty->assign("LISTPAGEURL",getlisturl_aftersave());
        if($related_func_type == 9)
        {
            $strContent= $smarty->fetch("DetailView/RelProdListData.tpl");
        }else{
            $strContent= $smarty->fetch("DetailView/RelMultiTr.tpl");
        }
	}else{

		if(in_array($relationInfo['functionName'],array('get_Kingdeeorders','get_Kingdeequotes','get_Digiwinorders','get_Digiwintickets','get_changeview','get_publicaccount'))){
			$strContent= $smarty->fetch("DetailView/RelatedListDataContents_nomove.tpl");
		}
        else if ($relationInfo['functionName'] == 'get_pricebook_products'){
            $ajax = $_REQUEST['ajax'];
            if ($ajax == 'true'){
                $strContent= $smarty->fetch("DetailView/RelatedListDataWithFixedColumnContent.tpl");
            }else{
                $strContent= $smarty->fetch("DetailView/RelatedListDataWithFixedColumn.tpl");
            }
        }
        else{
            $strContent= $smarty->fetch("DetailView/RelatedListDataContents.tpl");
        }
	}
    if(file_exists(globalStatic::$root_directory.'modules/'.$relatedModule.'/'.$relatedModule.'.php') && $relatedModule != 'CommunicationLog')
    {
        $relatefocus=CRMEntity::getInstance($relatedModule);
        $fields=$relatefocus->fieldobj->getFieldListArray();
    }
    ConvertTojsonString(1,array('CRITERIA_GROUPS'=>$relatedListData['advfilterlist'],'fields'=>$fields['fields'],
            "content"=>$strContent,'type'=>$relationInfo['type'],'noofrows'=>$relatedListData['noofrows']
        ,'advancefieldnames'=>$relatedListData['AdvanceFields'],'mapdata'=>$mapdata,'advanceset'=>$relationInfo['related_advanceset'],
            'navigation'=>$relatedListData['navigation'])
        ,'success');

}
else if(isset($_REQUEST['related_left_type']) && $_REQUEST['related_left_type'] == 3){//相关信息数量加载
	$record =  vtlib_purify($_REQUEST['record']);

    //if($_REQUEST['header'] == 'ServiceCharge')$_REQUEST['header'] = 'Accounts';
	$header = vtlib_purify($_REQUEST['header']);//module;
    $relateids=$_REQUEST['relateids'];
    $arr_relateids=explode(",",$relateids);

	if(empty($header)) return '';
	$tabid = getTabid($header);
	$related_left_record = $record;
	$related_left_mod = $header;
	$related_left_type = vtlib_purify($_REQUEST['related_left_type']);//;
	$rel_list = isPresentRelatedLists($header);//取得当前模块所有相关信息结果集
	global $currentModule;

	$related_header = $header;
	$currentModule = $header;
	if(!empty($rel_list)){
		$relationInfo = array();//$relatedcount = '';
		$relatedcount = array();

    crm_load_function_file('getRelatedListInfoById','include/utils','DetailViewUtils');
    crm_load_class_file('cls_getRelatedInfoHtml','include/ListView/RelatedListView');
    if($currentModule =='SocialPromotion'){
        crm_load_class_file("SocialPromotionForm",'modules/SocialPromotion');
        $socialPromotionForm = new SocialPromotionForm($focus->column_fields);
    }

		foreach($rel_list as $relatedid=>$relatedlabel){
			if($relatedlabel == 'BalanceOfAccount') continue;
            if($relatedlabel == 'GuanJiaPoReport') continue;
            //edit:can 20200716 041999: （61mis.com/kfbtest）客户模块>单据详情界面：相关点击“更多”，展开默认显示“条数”
        //    if(!in_array($relatedid,$arr_relateids))continue;
            //'AccountHierarchy'
            //36409: （1.6）客户明细界面>相关信息>查看上下级关系：当该字段有关联关系时应该跟联系人字段一样显示出有多少条关联。
		    if(in_array($relatedlabel,array('ContactsHierarchy','Print'))) continue;
			$relationInfo = getRelatedListInfoById($relatedid,$header);

            $type=strtolower($relationInfo['type']??'');
             if($type=='datacategory_template_js'||$type=='datacategory_templatelink')//自定义报表
            {
                     //自定义报表
                    $relatedcount[$relatedid]='';
                    continue;
            }
            if($type=='datacategory_template_url'){//甘特图
            //edit:can 20220118 49734: (https://www.51mis.com/hy/demo0118028/ [^])项目管理-项目立项-点击项目名称进入明细页，相关页签右上角未显示相关单据的数量
             $relatedcount[$relatedid]='';
                    continue;
            }
			$related_left_id = $relatedid;
			$related_left_tabid = $relationInfo['relatedTabId'];
			//print_r($relationInfo);die;
			$relatedModule = getTabname($relationInfo['relatedTabId']);
            $currentModule = $related_left_listmodule = $relatedModule;
			//echo $relatedModule;die;
			$function_name = $relationInfo['functionName'];
            if(getEduType('Edu') == false)
            {
    			if($relatedModule == 'ServiceContracts' && $function_name != 'get_related_list'){
    				$function_name = 'get_ServiceContracts';
    			}
            }
			$related_func_type = getRelatedFuncType($header,$relatedModule,
							$relationInfo['relatedTabId'],$function_name,$relationInfo['actions']);

			if($relationInfo['functionName']=='get_SharedUsers' &&$relationInfo['label']=='SharedUsers')
            {
                require_once('modules/Users/SetRelatedInfo.php');
                $shareuserobj=new SetRelatedInfo();
                $relatedListData=$shareuserobj->get_SharedUsersNum($record);
            }elseif($relationInfo['label']=='signlog'){	//微信用户签到日志
				$fieldlogobj=crm_load_class_obj("SetRelatedInfo",'modules/Users');
				$relatedListData=$fieldlogobj->getWeChatUserSignLogNum($record);
			}elseif($relationInfo['label']=='ChangeView'||$relationInfo['label']=='ViewHistory'||$relationInfo['label']=='publicaccount_log'||$relationInfo['label']=='OperationLogs'){
                require_once('modules/Users/SetRelatedInfo.php');
                $fieldlogobj=new SetRelatedInfo();
				if($relationInfo['label'] == 'publicaccount_log')	//公海操作记录数
					$relatedListData=$fieldlogobj->getPublicAccountLogNum($record,$header);
				else
					$relatedListData=$fieldlogobj->getFieldUpdateLogNum($header,$record,$relationInfo['label']);
            }elseif($relationInfo['functionName']=='get_readrecord' &&$relationInfo['label']='ReadRecord'){
			    //单据详情页面相关信息的数量
                $focus = CRMEntity::getInstance($header);
                $relatedListData = $focus->getReadRecordLogNum($record);
            }elseif($relationInfo['functionName']=='get_SocialPromotionForm' &&$relationInfo['label']='SocialPromotionForm'){
                // @edit:dong @date:2020/7/8 @reason: 社交推广 外部表单数据数据个数 当前用户可查看的
                $currentModule = $header;
                $focus = CRMEntity::getInstance($currentModule);
                $focus->retrieve_entity_info($record, $currentModule);
                $smcreatorid =  $focus->column_fields['smcreatorid']; //创建人
                $smownerid = $socialPromotionForm->getSmownerid($record);  //负责人
                if($smcreatorid == $current_user->id || $smownerid == $current_user->id){
                    $socialPromotionForm->getFormList('',$record);
                }else{
                    $socialPromotionForm->getFormList($current_user->id,$record);
                }
                $relatedListData['relcount'] = $socialPromotionForm->formCountNum;
                $relatedListData['record'] = $record;

            }elseif($relationInfo['functionName']=='get_SocialPromotionReport' &&$relationInfo['label']='SocialPromotionReport'){
			    // @edit:dong @date:2020/07/20 @reason: 统计报表 不需要数字
                $relatedListData['relcount'] = '';
                $relatedListData['record'] = $record;
            }
            elseif($relationInfo['functionName']=='get_QuestionnaireReport' &&$relationInfo['label']='QuestionnaireReport'){
                $relatedListData['relcount'] = '';
                $relatedListData['record'] = $record;
            }
            
            elseif($relationInfo['functionName']=='get_singin' &&$relationInfo['label']='Singin')
            {
                $currentModule = $header;

                $focus = CRMEntity::getInstance($currentModule);
                $relatedListData=$focus->$function_name($_REQUEST['record'], $relationInfo['relatedTabId'],
    								$relationInfo['relatedTabId'], $relationInfo['actions'],$relationInfo['relationId']);
            }
            elseif($relationInfo['functionName']=='get_trends' &&$relationInfo['label']='trends'){
                if($header=='Accounts'||$header=='ServiceCharge'){
                    crm_load_class_file('cls_sales_trends','modules/Accounts');
                    $obj_trends = new cls_sales_trends($record, $header);
                    $result = $obj_trends->getList();
                    $tmp_count = 0;
                    foreach($result as $value){
                        $tmp_count += sizeof($value['list']);
                    }
                }else if($header == 'WorkSheet'){
                    //工单模块动态
                    crm_load_class_file('cls_worksheet_trends','modules/WorkSheet');
                    $obj_trends = new cls_worksheet_trends($record, $header);
                    $result = $obj_trends->getList();
                    $tmp_count = 0;
                    foreach($result as $value){
                        $tmp_count += sizeof($value['list']);
                    }
                }
                $relatedListData['relcount'] = $tmp_count;
                $relatedListData['record'] = $record;
            }
            elseif($relationInfo['functionName']=='get_CallButler' &&$relationInfo['label']='CallButler'){
                crm_load_class_file('cls_CallRecord','modules/Settings');
                $obj_callrecord = new cls_CallRecord($header, $record);
                $result = $obj_callrecord->getList();
                $tmp_count = 0;
                foreach($result as $value){
                    $tmp_count += sizeof($value['list']);
                }
                
                $relatedListData['relcount'] = $tmp_count;
                $relatedListData['record'] = $record;
            }
            //相关信息显示数量不对 ，联系人图谱
            else if((int)$relationInfo['relatedTabId'] <=0){
                $relatedListData['relcount'] = '';
                $relatedListData['record'] = $record;
            }
            else{
                $cls_getRelatedInfoobj=new cls_getRelatedInfoHtml($header,$relationInfo,$record);
                $relatedListData=$cls_getRelatedInfoobj->getRelateCount();
            }
			//is_numeric($relatedListData['relcount']) &&
            
			if(isset($relatedListData['relcount']) && $relatedListData['relcount'] >= 0){
				//$relatedcount .= $relatedid.':'.$relatedListData['relcount'].',';
				$relatedcount[$relatedid] = $relatedListData['relcount'];
			}
            else if(isset($relatedListData['entries']) && is_array($relatedListData['entries']))
            {
                $relatedcount[$relatedid] = count($relatedListData['entries']);
            }else{//手机端 相关信息
//				$result = $adb->pquery($relatedListData,array());
//				$relatedcount[$relatedid] = $adb->num_rows($result);

                $relatedcount[$relatedid] = $relatedListData;//看不懂什么逻辑,先这样改
			}
		}

		//手机相关信息获取条目数，因为手机相关信息没有分类，所有获取数据不走这边。
		if(isset($_REQUEST['app_related_list']) && $_REQUEST['app_related_list'] == 'true'){
			$app_related_list = $relatedcount;
			return;
		}
		if(!empty($relatedcount)){
		  $arr=array();
          $arr['count']=$relatedcount;
          $_REQUEST['diony']='yes';
          ConvertTojsonString(1,$arr,'success');

		}else{
			echo '';die;
		}
		//$relatedcount = trim($relatedcount,',');
		echo $relatedcount;
	}
	die;
}
else if(isset($_REQUEST['related_left_type']) && $_REQUEST['related_left_type'] == 4){
    //加载按钮
    global $currentModule;
    $record =  vtlib_purify($_REQUEST['record']);
    //if($_REQUEST['header'] == 'ServiceCharge')$_REQUEST['header'] = 'Accounts';
	$header = vtlib_purify($_REQUEST['header']);//module;
	if(empty($header)) return '';
	$tabid = getTabid($header);
    $currentModule = $header;
	$rel_list = isPresentRelatedLists($header);//取得当前模块所有相关信息结果集


    crm_load_function_file('getRelatedListInfoById','include/utils','DetailViewUtils');
    crm_load_class_file('cls_getRelatedInfoHtml','include/ListView/RelatedListView');
    foreach($rel_list as $relatedid=>$relatedlabel){
    	$relationInfo = getRelatedListInfoById($relatedid);
        $cls_getRelatedInfoobj=new cls_getRelatedInfoHtml($header,$relationInfo,$record);
        $relatedListData[$relatedid]=$cls_getRelatedInfoobj->getRelatedHref();
    }

    if(!empty($relatedListData)){
		require_once("include/Zend/Json.php");
		$json = new Zend_Json();
		$jsonentity = $json->encode($relatedListData);
		echo $jsonentity;
		die;
	}else{
		echo '';die;
	}
}


/**
 * 获取当前相关信息类型，多对多、一对多等。
 * @param $header 当前相关信息所属模块
 * @param $relatedModule 对应的模块
 * @param $related_tabid 关联相关信息tabid
 * @param $function_name 对应function方法名
 * @param $actions 对应的操作权限
 * @return $related_func_type 类型
 * @author Tujt 2014-04-01
 */
function getRelatedFuncType($header,$relatedModule,
										$related_tabid,$function_name,$actions) {
	$related_func_type = 0;
    $function_name = strtolower($function_name);
	switch($function_name){
	   case 'get_related_list':
			$related_func_type = 1;break;//标准多对多方法
		case 'get_products':
			$related_func_type = 2;break;//产品多对多方法
		case 'get_attachments':
			$related_func_type = 8;break;//知识共享
		case 'get_attachment':
			$related_func_type = 3;break;//附件
		case 'get_emails':
		   $related_func_type = 6;break;//邮件
		case 'get_campaigns':
		   $related_func_type = 4;break;//营销活动
//		case 'get_schedule':
//		   $related_func_type = 4;break;//日程安排
//		   break;
		case 'get_cashbill':
		   $related_func_type = 5;break;//关联收款单
		   break;
		case 'get_sendcashbill':
		   $related_func_type = 5;break;//关联付款单
		   break;
        case 'get_commission':
		   $related_func_type = 5;break;//关联佣金单
		   break;
		case 'get_accounts':
		   $related_func_type = 7;break;//关联客户
		   break;
		case 'get_contacts':
		case 'get_businessapply':
		   $related_func_type = 4;break;//关联联系人
		   break;
        case 'get_projectservicecontracts':
		   $related_func_type = 4;break;//课程
		case 'get_purchasecashback':
		   $related_func_type = 9;break;//采购退款单
		   break;
	}
    if(getEduType('Edu') == true)
    {
        switch($function_name){
            case 'get_project':
                $related_func_type = 4;break;//学员 更多信息 班级
            case 'get_projectservicecontracts':
                $related_func_type = 7;break;//学员 更多信息 课程
            case 'get_ProjectMilestone':
                $related_func_type = 4;break;//学员 更多信息 教师
            case 'get_LessionPlan':
                $related_func_type = 4;break;//学员 更多信息 课程计划
            case 'get_projectaccounts':
                $related_func_type = 4;break;//班级 更多信息 学员
       }
    }
	if($related_func_type == 0){
		if($header == 'Products'){
			if(in_array($function_name,array('get_tickets','get_product_pricebooks','get_opportunities')))
				return 4;
			else if($function_name == 'get_quotes' || $function_name == 'get_purchase_orders' || $function_name == 'get_salesorder' || $function_name == 'get_invoices')
				return 9;
		}else if($header == 'PurchaseOrder'){
			if(in_array($function_name,array('get_VendorContactRecords','get_SendCashBill')))
				return 4;
			else if($function_name == 'get_purchaseinvoice')
				return 9;
		}else if($header == 'SalesOrder'){
			if($function_name == 'get_paymentplan')
				return 4;//合同订单关联关联回款计划
			elseif($function_name == 'get_cashback')
				return 9;//合同订单关联退款单，通过退货单关联
		}else if($header == 'PurchaseInvoice'){
			if($function_name == 'get_SendCashBill')
				return 4;
		}else if($header == 'ServiceContracts'){
			if($function_name == 'get_paymentplan')
				return 4;//服务合同关联回款计划
			else if($function_name == 'get_invoice')
				return 9;//服务合同关联回款计划
		}else if($function_name == 'get_schedule'){
			if(in_array($header,array('Accounts','ServiceCharge','Contacts','Potentials'))){
				return 5;//一对多
			}else{
				return 4;//中间表关联
			}
		}else if($header == 'ServiceContracts'){
			//,'get_cashbill'=>'1','get_commission'=>'1','get_expense'=>'1'
			$funcarray = array('get_invoice'=>'1');
			if($function_name == 'get_invoice'){
				return 9;
			}else if($function_name == 'get_expense'){
				return 4;
			}
		}else if($header == 'Stock'){
			if($function_name == 'get_SendCashBill'){
				return 4;
			}
            if($function_name == 'get_purchaseinvoice'){//Liver 2016-11-30，bug0026166: 出/入库单明细界面：关联创建和相关信息的模块增加销售发票/采购发票
                return 9;
            }
		}else if($header =='OutboundOrder'){//Liver 2016-11-30，bug0026166: 出/入库单明细界面：关联创建和相关信息的模块增加销售发票/采购发票
            if($function_name == 'get_invoices'){
                return 9;
            }
		}

		if(strpos($actions,'select') > 0){
			$related_func_type = 4;//自定义多对多方法
		}else if($related_tabid > 0){
			$related_func_type = 5;//一对多方法
		}else{
			$related_func_type = 6;//没有对应tabid的相关信息，不做处理
		}
		if(get_file_address($relatedModule,'ProductDetails')){
			//列表中加产品的模块
			if($header == 'SalesOrder' && ($relatedModule == 'Invoice' || $relatedModule == 'OutboundOrder'|| $relatedModule == 'PurchaseOrder')){
				return 9;
			}elseif($header == 'PurchaseOrder' && $relatedModule == 'Stock'){
				return 9;
			}else{
				return 7;
			}
		}
	}
	return $related_func_type;
}
?>