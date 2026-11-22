<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

global $adb;
global $current_user;
$more_list = 0;
global $theme;
global $default_charset;
global $oCustomView;
$mcshow = 'yes';//是否显示【在关键视图中显示】
//edit:duan reason:新建分类显示列的默认字段改为从“全部”分类中复制 time:2021-6-29
if(!isset($_REQUEST['viewedit'])&&!isset($_REQUEST['viewcopy']))//判断当前流程为新建
{
    $_REQUEST['viewcopy'] = 'true';//新建改为走复制流程
    $viewcreate = 'true';//用于判断显示标题
    $customview=CustomView::getInstance($_REQUEST['module']);
    $categorylist=$customview->getCvListByModule();
    foreach($categorylist as $key=>$val){
        if($val['viewname']=='All')//获取“全部”分类的id
        {
            $_REQUEST['record'] = $key;
            break;
        }
    }
}


$error_msg = '';
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
@include('dataCache/tabdatas/tab_language.php');
require("user_privileges/user_language_".$current_user->id.'.php');
require_once('modules/Settings/ProductListView.php');//带产品明细的视图
require_once('modules/CustomView/CustomView_Columnlist.php');

$cv_module = vtlib_purify($_REQUEST['module']);
$isduplicate=vtlib_purify($_REQUEST['viewcopy']);
$recordid = vtlib_purify($_REQUEST['record']);
$groupEmail=vtlib_purify($_REQUEST['groupEmail']);
//$arr['tabletitle']=array(getFixedLabel("Select_field"),getFixedLabel("SELECTIONCRITERIA"),getFixedLabel("SEARCHKEY"),getFixedLabel("SCREENINGRELATIONSHIP"));

if($_REQUEST['viewcopy'] == 'true'){
    $smarty->assign("viewcopy","true");
	$smarty->assign('viewcopy_cvid',$recordid);
}
//MORE_LISTVIEW 1：设置“显示列”和“排序方式”  0：选择9列样式
if($_REQUEST['groupEmail'] == 'MassSMS' || $_REQUEST['groupEmail'] == 'Emails')
    $smarty->assign('MORE_LISTVIEW',2);
else if($cv_module == 'Reminds')// "消息"模块不需要显示列设置
    $smarty->assign('MORE_LISTVIEW',3);
else if($cv_module == 'ShoppingMall')// "消息"模块不需要显示列设置 //zxm @date:2024/10/18 @reason:  订货商城 数据分类设置不显示字段选择
    $smarty->assign('MORE_LISTVIEW',10);
else
    $smarty->assign('MORE_LISTVIEW',1);
$smarty->assign('GROUPEMAIL',$groupEmail);


$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("MODULE",$cv_module);
$focus=CRMEntity::getInstance($cv_module);

crm_load_class_file("CommonView","modules/CustomView");

$modulelabel=$tab_string[$cv_module];
if($languageType=='en')
    $modulelabel=$entab_string[$cv_module];
$smarty->assign("MODULELABEL",$modulelabel);

$smarty->assign("CVMODULE", $cv_module);
if($isduplicate=='true')
$smarty->assign("CUSTOMVIEWID",'');//edit by tifa 20130307 copy view 
else
$smarty->assign("CUSTOMVIEWID",$recordid);
$smarty->assign("DATEFORMAT",$current_user->date_format);
$smarty->assign("JS_DATEFORMAT",'YYYY-mm-ddd');
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($cv_module);
$arr['advanceFields'] = $controller->getAdvanceFields();
if($recordid == "") {
	$oCustomView = CustomView::getInstance($cv_module);
    $smarty->assign('SORTARR',$oCustomView->getModuleSortOrder($cv_module));
 
    //$smarty->assign('SORTDEFAULT',$oCustomView->getCvcolumnlistSort($recordid));
    //高级查询下拉框字段内容: 当前模块全部可用字段
	$modulecollist = $oCustomView->getModuleColumnsList($cv_module);
 
	//$stdfilterhtml = $oCustomView->getStdFilterCriteria();
    $arr['record']=$recordid;

    $stdfiltercolhtml = [];

    /**
    * edit:chj
    * date:2014-8-8
    * reason:服务收费 显示服务收费和服务合同的日期字段
    */
    // if($cv_module == 'ServiceCharge')
    //     $stdfiltercolhtml = CustomView_Columnlist::getStdFilterHTML(array('ServiceContracts','ServiceCharge'));
    // else
    //     $stdfiltercolhtml = CustomView_Columnlist::getStdFilterHTML(array($cv_module));
    
    
    
	//$stdfilterjs = $oCustomView->getCriteriaJS();

	$smarty->assign("STDFILTERCOLUMNS",$stdfiltercolhtml);
	$smarty->assign("STDCOLUMNSCOUNT",count($stdfiltercolhtml));
	$smarty->assign("STDFILTERCRITERIA",$stdfilterhtml);
	// $smarty->assign("STDFILTER_JAVASCRIPT",$stdfilterjs);
	
	$advfilterhtml = CustomView_Columnlist::getAdvCriteriaHTML();
	$modulecolumnshtml = CustomView_Columnlist::getByModule_ColumnsHTML($cv_module,$modulecollist);//高级查询模块字段
	//$smarty->assign("FOPTION",$advfilterhtml);
    
	// $smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);
    $arr['mandatorycheck']=array_unique($oCustomView->mandatoryvalues);
    $arr['foption']=$advfilterhtml;
    $arr['columns_block']=$modulecolumnshtml;

    $arr['criteria_groups']="";
	//$smarty->assign("MANDATORYCHECK",implode(",",array_unique($oCustomView->mandatoryvalues)));
	//$smarty->assign("SHOWVALUES",implode(",",$oCustomView->showvalues));
    $arr['showvalues']=$oCustomView->showvalues;
    $data_type[] = $oCustomView->data_type;
    $smarty->assign("DATATYPE",$data_type);
    //$smarty->assign("viewCopy","NoCopy");
    $arr['viewCopy']='NoCopy';
    //wym BUG0074501 查询分类无全部分类时新建分类-点击删除按钮没反应
    $defaultsort[0]['columnname']=$focus->table_name.":createdtime:createdtime:$cv_module"."_DT~O:fieldlabel";
    $defaultsort[0]['sort']="desc";

    $smarty->assign("defaultsort",$defaultsort);
} else {
    $focus=CRMEntity::getInstance($cv_module);
	$oCustomView = CustomView::getInstance($cv_module);
	$now_action = vtlib_purify($_REQUEST['action']);

    $smarty->assign('SORTARR',$oCustomView->getModuleSortOrder($cv_module));
    //@edit:zsk @date:2024/06/11 @reason:XUQIU20240516-01 查询分类功能优化
    $groupid = $oCustomView->getViewDetailInfo($recordid)['groupid'];
    if($viewcreate == 'true'){
        $groupid = $_REQUEST['groupid'];
    }

    $smarty->assign('CUSTOMVIEWGROUP',$groupid);
    $commonCustomViewByUser=getUsersettingByLabel($cv_module,$current_user->id,'CommonGroupForCategory');
    // 将逗号分隔的字符串转换为数组
    $commonCustomViewByUserArray = explode(",", $commonCustomViewByUser);
    if (in_array($recordid, $commonCustomViewByUserArray)) {
        // 找到并移除指定的groupid
        $commonCustomViewByUserArray = array_diff($commonCustomViewByUserArray, array($recordid));
        $smarty->assign('COMMONCUSTOMVIEW','yes');
    }
    else{
        $smarty->assign('COMMONCUSTOMVIEW','no');
    }
    //$smarty->assign('SORTDEFAULT',$oCustomView->getCvcolumnlistSort($recordid));
    $sql='select * from ld_cvcolumnlistsort where cvid=? order by sortid asc';
    $result=$adb->pquery($sql,array($recordid));
    //wym XUQIU1001870 查询分类增加多个排序字段
    if($adb->num_rows($result)>0) {
        for($i=0;$i<$adb->num_rows($result);$i++) {
            $columnname=$adb->query_result($result, $i, 'columnname');
            $sortcolumn_arr = explode(":",$columnname);
            $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $sortcolumn_arr[1]);

            if($fieldinfo) {
                $defaultsort[$i]['columnname'] = $columnname;
                $defaultsort[$i]['sort'] = $adb->query_result($result, $i, 'sorttype');
            }
        }
    }
    //wym BUG0074330
    if(!is_array($defaultsort)) {
        //edit:can 20211119 48882: （https://81mis.com/kfbcrm/index.php [^]）客户》列表界面》管理分类》系统默认“全部”数据分类是按“更新时间”“降序”排序，当“更新时间”隐藏后，应改为“创建时间”来排序
        $fieldinfo= $focus->fieldobj->getFieldInfoobjBykey("columnname",'createdtime');
        if($fieldinfo) {
            $createdfieldname=$fieldinfo->getFieldName();
            $typeofdata=$fieldinfo->getTypeOfData();
            $defaultsort[0]['columnname']=$focus->table_name.":createdtime:$createdfieldname:$cv_module"."_$typeofdata:fieldlabel";
            $defaultsort[0]['sort']="desc";
        }
        //服务合同不存在createdtime字段,去获取负责人字段(与列表显示保持一致)
        if(!$fieldinfo) {
            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$focus->getSmownerColumName());
            if($fieldinfo) {
                $smownerfieldname=$fieldinfo->getFieldName();
                $smownercolumnname=$fieldinfo->getColumnName();
                $typeofdata=$fieldinfo->getTypeOfData();
                $defaultsort[0]['columnname']=$fieldinfo->getTableName().":$smownercolumnname:$smownerfieldname:$cv_module"."_$typeofdata:fieldlabel";
                $defaultsort[0]['sort']="desc";
            }
        }
    }

    $smarty->assign("defaultsort",$defaultsort);
    if($groupEmail!=''){
		$oCustomView->customviewmodule = $groupEmail;
        $customviewdtls = $oCustomView->getViewDetailInfo($recordid);
		//高级查询下拉框字段内容: 当前模块全部可用字段
        $modulecollist = $oCustomView->getModuleColumnsList($cv_module);
       
		//$selectedcolumnslist = $oCustomView->getColumnsListByCvid($recordid);
            
        if($isduplicate){
            $smarty->assign("VIEWNAME",""); 
            $smarty->assign("viewCopy","viewCopy");
        }
        else{
            $smarty->assign("VIEWNAME",$customviewdtls["viewname"]);    
            if($customviewdtls["setdefault"] == 1) {
            	$smarty->assign("CHECKED","checked");
            }
            $status = $customviewdtls["status"];
            $smarty->assign("STATUS",$status);
        }
		
	
		$advfilterlist = $oCustomView->getAdvFilterByCvid($recordid);
        
        $strModule="select tabid from ld_tab where name='".$cv_module."'";
        $result=$adb->query($strModule,null);
        $tabid=$adb->query_result($result,0,0);
       
        for($i=0;$i<count($advfilterlist[1]['columns']);$i++)
        {
            $oldColumnList=explode(":",$advfilterlist[1]['columns'][$i]['columnname']);
            $strArr=explode("_",$oldColumnList[3]);
           $advfilterlist[1]['columns'][$i]['columnname']=$oldColumnList[0].":".$oldColumnList[1].":".$oldColumnList[2].":".$strArr[0]."_fieldlabel".":".$oldColumnList[4];
        }
      
       
		$advfilterhtml = CustomView_Columnlist::getAdvCriteriaHTML();
      
		$modulecolumnshtml = CustomView_Columnlist::getByModule_ColumnsHTML($cv_module,$modulecollist);
		//$smarty->assign("FOPTION",$advfilterhtml);
		//$smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);
		//$smarty->assign("CRITERIA_GROUPS",$advfilterlist);
        $arr['foption']= $advfilterhtml;
        $arr['columns_block']= $modulecolumnshtml;
       
        if(!empty($advfilterlist))
            $arr['criteria_groups']=$advfilterlist;	
        else
            $arr['criteria_groups']="";
      
       // print_r($advfilterlist);
		//$smarty->assign("MANDATORYCHECK",implode(",",array_unique($oCustomView->mandatoryvalues)));
        $arr['mandatorycheck']=array_unique($oCustomView->mandatoryvalues);
        $arr['showvalues']=$oCustomView->showvalues;
	//	$smarty->assign("SHOWVALUES",implode(",",$oCustomView->showvalues));
		$smarty->assign("EXIST","true");
		$cactionhtml = "<input name='customaction' class='button' type='button' value='Create Custom Action' onclick=goto_CustomAction('".$cv_module."');>";
	
		if( $cv_module == "Accounts" || $cv_module == "Contacts")
		{
			$smarty->assign("CUSTOMACTIONBUTTON",$cactionhtml);
		}
        $data_type[] = $oCustomView->data_type;
        $smarty->assign("DATATYPE",$data_type);
        
    }
    else{
    /*
    edit:can
    date:20130812
    reason:4727: "创建数据分类"："复制"按钮应该不用控制操作权限
    */
	if($oCustomView->isPermittedCustomView($recordid,$now_action,$oCustomView->customviewmodule) == 'yes'||$isduplicate) {
		$customviewdtls = $oCustomView->getViewDetailInfo($recordid);
      
		//高级查询下拉框字段内容: 当前模块全部可用字段
       
        $modulecollist = $oCustomView->getModuleColumnsList($cv_module);
      
      
	//	$selectedcolumnslist = $oCustomView->getColumnsListByCvid($recordid);
      
	    if($isduplicate)//复制视图
        {
            $smarty->assign("VIEWNAME","");
            /*
            edit by LD Can
            date:20130327
            reason:0003535: 选中一个"视图"，点击"复制"，结果在复制编辑界面的列里面会显示2个"负责人"，希望查查原因。
            */
            //$smarty->assign("viewCopy","viewCopy");
            $arr['viewCopy']='viewCopy';
        }
        else 
        {
         
            $smarty->assign("PREVIEWNAME",$customviewdtls["viewname"]);
            if(strtolower($customviewdtls["viewname"])!='all')
            {
                 $smarty->assign("VIEWNAME",$customviewdtls["viewname"]); 
            }
            else
                 $smarty->assign("VIEWNAME",getFixedLabel("ALL")); 
            $ischecked='no';
            if($customviewdtls['default_cvid']>0)
            {
                if($customviewdtls['customcategory']==$customviewdtls['user_customcategory']){
                    if($customviewdtls['pool_id']==$customviewdtls['user_pool_id'])
                        if($customviewdtls['user_preferencesid']==$current_user->id)
                            {
                                //edit:can  20220808  54439：查询分类：每个用户登陆系统时显示自己设置“自定义显示默认分类”
                                $smarty->assign("CHECKED","checked");
                                $ischecked='yes';
                            }
                }
                if($customviewdtls['customcategory']=='ALLACCOUNT'&&$customviewdtls['customcategory']==$customviewdtls['user_customcategory'])
                    if($customviewdtls['user_preferencesid']==$current_user->id)
                         {
                                //edit:can  20220808  54439：查询分类：每个用户登陆系统时显示自己设置“自定义显示默认分类”
                                $smarty->assign("CHECKED","checked");
                                $ischecked='yes';
                         }
                        
            }

              if($customviewdtls["setdefault"] == 1 &&$ischecked=='no' ) {
                
                 $sql='select * from  ld_user_module_preferences where  userid=?  and tabid=? and customcategory=? ';
                $result=$adb->pquery($sql,array($current_user->id,getTabid($oCustomView->customviewmodule),$customviewdtls['customcategory']));
               
                if($adb->num_rows($result)<=0)
    			     $smarty->assign("CHECKED","checked");
    		}
    		if($customviewdtls["setmetrics"] == 1) {
    			$smarty->assign("MCHECKED","checked");
    		}
    		$status = $customviewdtls["status"];
    		$smarty->assign("STATUS",$status);
            //$smarty->assign("viewCopy","NoCopy");
            $arr['viewCopy']='viewCopy';
        }

        if(!empty($customviewdtls['customcategory'])&&$customviewdtls['customcategory']!='ALLACCOUNT'){
            //zxm 20231218 是否显示【在关键视图中显示】--只有全部客户页签的才显示该设置 BUG0077236
            $mcshow = 'no';
        }

	
		$advfilterlist = $oCustomView->getAdvFilterByCvid($recordid);
        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        crm_load_class_file('AdvanceSearchUtil', 'modules/lingdang');
        $advfilterlist = AdvanceSearchUtil::spacialAdvancedSearchCriteria($cv_module, $advfilterlist);

        $tabid=getTabid($cv_module);
        if($tabid==9)
            $tabid=16;
        if(is_array($advfilterlist[1]['columns'])){
            for($i=0;$i<count($advfilterlist[1]['columns']);$i++)
            {
                $oldColumnList=explode(":",$advfilterlist[1]['columns'][$i]['columnname']);

                $strArr=explode("_",$oldColumnList[3]);
                if($oldColumnList[1]=='createdtime'||$oldColumnList[1]=='modifiedtime')
                {
                    $advfilterlist[1]['columns'][$i]['columnname']=$oldColumnList[0].":".$oldColumnList[1].":".$oldColumnList[2].":".$strArr[0]."_fieldlabel".":DT";
                }
                else
                $advfilterlist[1]['columns'][$i]['columnname']=$oldColumnList[0].":".$oldColumnList[1].":".$oldColumnList[2].":".$strArr[0]."_fieldlabel".":".$oldColumnList[4];
            }
        }
		$advfilterhtml = CustomView_Columnlist::getAdvCriteriaHTML();
		$modulecolumnshtml = CustomView_Columnlist::getByModule_ColumnsHTML($cv_module,$modulecollist);
       
		//$smarty->assign("FOPTION",$advfilterhtml);
		//$smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);
		//$smarty->assign("CRITERIA_GROUPS",$advfilterlist);	
        $arr['foption']=$advfilterhtml;
        $arr['columns_block']=$modulecolumnshtml;
        if(!empty($advfilterlist))
            $arr['criteria_groups']=$advfilterlist;	
        else
           $arr['criteria_groups']="";	 	
        // print_r($advfilterlist);
		//$smarty->assign("MANDATORYCHECK",implode(",",array_unique($oCustomView->mandatoryvalues)));
        $arr['mandatorycheck'] = is_array($oCustomView->mandatoryvalues)?array_unique($oCustomView->mandatoryvalues):$oCustomView->mandatoryvalues;

        if(!empty($oCustomView->showvalues)){
 		    //	$smarty->assign("SHOWVALUES",implode(",",$oCustomView->showvalues));
            $arr['showvalues']=$oCustomView->showvalues;
 		}else{
            //	$smarty->assign("SHOWVALUES",'');
            $arr['showvalues']="";
 		}
		
		$smarty->assign("EXIST","true");
		$cactionhtml = "<input name='customaction' class='button' type='button' value='Create Custom Action' onclick=goto_CustomAction('".$cv_module."');>";
	
		if( $cv_module == "Accounts" || $cv_module == "Contacts")
		{
			$smarty->assign("CUSTOMACTIONBUTTON",$cactionhtml);
		}
       
        $data_type[] = $oCustomView->data_type;
        $smarty->assign("DATATYPE",$data_type);
	}
    else
	{
		echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
		echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>
			<table border='0' cellpadding='5' cellspacing='0' width='98%'>
			<tbody><tr>
			<td rowspan='2' width='11%'><img src='". lingdang_imageurl('denied.gif', $theme)."' ></td>
			<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span class='genHeaderSmall'>".getFixedLabel('NOPERMITTEDEXECUTE')."</span></td>
			</tr>
			<tr>
			<td class='small' align='right' nowrap='nowrap'>
			<a href='javascript:window.history.back();'>".getFixedLabel('RETURN')."</a><br>
			</td>
			</tr>
			</tbody></table>
			</div>";
		echo "</td></tr></table>";
		exit;
	}
    }  
}
// @edit:dong @date:2020/10/28 @reason:  数据分类变成模块  获取当前数据分类是否设置过为模块
crm_load_class_file('cls_LinkModuleCustom','include/utils/');
$linkInfo = cls_LinkModuleCustom::getLinkModuleCustomInfoBycvid($cv_module,$recordid);
if(is_array($linkInfo) && !empty($linkInfo)){
    $smarty->assign("setaslinkmodule", true);
}


$smarty->assign("RETURN_MODULE", $cv_module);
if($cv_module == "Calendar")
        $return_action = "ListView";
else
        $return_action = "index";

if($recordid == ''||$isduplicate=='true')
	$act = $mod_strings['LBL_NEW'];
else
	$act = $mod_strings['LBL_EDIT'];

$smarty->assign("ACT", $act);
$smarty->assign("RETURN_ACTION", $return_action);
$SearchScope="";
global $current_user;
//中英文包
$languageType= getLanguageType($current_user);
$smarty->assign("LANUGAGETYPE",$languageType);
if(isset($_REQUEST['SearchScope']))
{
    $SearchScope=$_REQUEST['SearchScope'];
}
$smarty->assign("SEARCHSCOPE",$SearchScope);
$smarty->assign("MCSHOW",$mcshow);
$smarty->assign('NOVIEWNAME',$customviewdtls["viewname"]);
//XUQIU1002181 新增查询条件，属于/不属于 条件可以输入多个字段，用“，”或“,”分辨注：中英文的“，”都可以做划分

$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);
$fLabels['belong']=getFixedLabel('BELONG');
$fLabels['notbelong'] =getFixedLabel('NOTBELONG');
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$fLabels['new_belong'] = getFixedLabel('BELONG');
$fLabels['new_notbelong'] = getFixedLabel('NOTBELONG');
//@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
$customview = CustomView::getInstance($_REQUEST['module']);
$viewid = $customview->getViewId($_REQUEST['module']);
$customview_html=$customview->getCustomViewAll($viewid, $_REQUEST['module']);
//获取查询分类分组列表
$groupList=$customview->getCustomViewGroupList($customview_html);
$smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
$smarty->assign("MODULE", $_REQUEST['module']);
$smarty->assign("VIEWID", $viewid);
$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);

if($_REQUEST['popup']=='yes')
{
    $_REQUEST['diony']='diony';
    $content=$smarty->fetch("CustomViewPopup.tpl");
    $arr['content']=$content;
    
    if($_REQUEST['viewcopy'] == 'true'){
        if($languageType=='en'){
            $arr['title']=getFixedLabel('COPY').' '.getFixedLabel('VIEWTYPE');
        }
        else{
            $arr['title']=getFixedLabel('COPY').getFixedLabel('VIEWTYPE');
        }
    }
    if($_REQUEST['viewedit'] == 'true'){
        if($languageType=='en'){
            $arr['title']=getFixedLabel('EDIT').' '.getFixedLabel('VIEWTYPE');
        }
        else{
            $arr['title']=getFixedLabel('EDIT').getFixedLabel('VIEWTYPE');
        }
    }
    if($viewcreate =='true')
    {
        if($languageType=='en'){
            $arr['title']=getFixedLabel('CREATE').' '.getFixedLabel('VIEWTYPE');
        }
        else{
            $arr['title']=getFixedLabel('CREATE').getFixedLabel('VIEWTYPE');
        }
    }
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
    $arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
    $arr['source']='customview';
    $arr['flabels']=$fLabels;
    $arr['viewnamelabel']=getFixedLabel('Category_Name');
    //231207 wym BUG0076816 “查询分类”-“新建分类”-“设置条件”处，选择“团队成员”字段后，右侧条件下拉框内，不显示“包含当前操作员”
    $fields=$focus->fieldobj->getListViewFields();
    $arr["fields"]=ldcrm_json_encode($fields['fields']);
    ConvertTojsonString(1,$arr,'success');

}
else
$smarty->display("CustomView.tpl");


?>