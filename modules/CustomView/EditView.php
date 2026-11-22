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
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;



global $current_user;
$more_list = 0;
global $theme;
global $default_charset;
//<<<<<>>>>>>
global $oCustomView;
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

//<<<<<>>>>>>
if($_REQUEST['viewcopy'] == 'true'){
    $smarty->assign("viewcopy","true");
	$smarty->assign('viewcopy_cvid',$recordid);
}
//MORE_LISTVIEW 1：设置“显示列”和“排序方式”  0：选择9列样式
if($_REQUEST['groupEmail'] == 'MassSMS' || $_REQUEST['groupEmail'] == 'Emails')
    $smarty->assign('MORE_LISTVIEW',2);
else
    $smarty->assign('MORE_LISTVIEW',1);
$smarty->assign('GROUPEMAIL',$groupEmail);

$smarty->assign("CATEGORY", getParentTab());

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("MODULE",$cv_module);
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
if($recordid == "") {
	$oCustomView = CustomView::getInstance($cv_module);
    $smarty->assign('SORTARR',$oCustomView->getModuleSortOrder($cv_module));
    $smarty->assign('SORTDEFAULT',$oCustomView->getCvcolumnlistSort($recordid));
    //高级查询下拉框字段内容: 当前模块全部可用字段
	$modulecollist = $oCustomView->getModuleColumnsList($cv_module);
 
	$stdfilterhtml = $oCustomView->getStdFilterCriteria();
   
    /**
    * edit:chj
    * date:2014-8-8
    * reason:服务收费 显示服务收费和服务合同的日期字段
    */
    if($cv_module == 'ServiceCharge')
        $stdfiltercolhtml = CustomView_Columnlist::getStdFilterHTML(array('ServiceContracts','ServiceCharge'));
    else
        $stdfiltercolhtml = CustomView_Columnlist::getStdFilterHTML(array($cv_module));
    
	$stdfilterjs = $oCustomView->getCriteriaJS();

	$smarty->assign("STDFILTERCOLUMNS",$stdfiltercolhtml);
	$smarty->assign("STDCOLUMNSCOUNT",count($stdfiltercolhtml));
	$smarty->assign("STDFILTERCRITERIA",$stdfilterhtml);
	$smarty->assign("STDFILTER_JAVASCRIPT",$stdfilterjs);
	
	$advfilterhtml = CustomView_Columnlist::getAdvCriteriaHTML();
	$modulecolumnshtml = CustomView_Columnlist::getByModule_ColumnsHTML($cv_module,$modulecollist);//高级查询模块字段
	$smarty->assign("FOPTION",$advfilterhtml);
	$smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);
    
	$smarty->assign("MANDATORYCHECK",implode(",",array_unique($oCustomView->mandatoryvalues)));
	$smarty->assign("SHOWVALUES",implode(",",$oCustomView->showvalues));
    $data_type[] = $oCustomView->data_type;
    $smarty->assign("DATATYPE",$data_type);
    $smarty->assign("viewCopy","NoCopy");
         
} else {
  
	$oCustomView = CustomView::getInstance($cv_module);
	$now_action = vtlib_purify($_REQUEST['action']);
    $smarty->assign('SORTARR',$oCustomView->getModuleSortOrder($cv_module));
    $smarty->assign('SORTDEFAULT',$oCustomView->getCvcolumnlistSort($recordid));
    if($groupEmail!=''){
		$oCustomView->customviewmodule = $groupEmail;
        $customviewdtls = $oCustomView->getViewDetailInfo($recordid);
		$customviewdtls = !empty($customviewdtls)?$customviewdtls:[];
        $oCustomView->customviewmodule = $cv_module;
		//高级查询下拉框字段内容: 当前模块全部可用字段
        $modulecollist = $oCustomView->getModuleColumnsList($cv_module);
       
		$selectedcolumnslist = $oCustomView->getColumnsListByCvid($recordid);
            
		if($isduplicate){
		    $smarty->assign("VIEWNAME","");
		    $smarty->assign("viewCopy","viewCopy");
		} else {
			if(!isset($customviewdtls["viewname"]) || empty($customviewdtls["viewname"])){
				$customviewdtls["viewname"] = '';
			}
		    $smarty->assign("VIEWNAME",$customviewdtls["viewname"]);
            
		    if(strtolower($customviewdtls["viewname"])!='all') {
		        $smarty->assign("VIEWNAME",$customviewdtls["viewname"]);
		    }
            else
                $smarty->assign("VIEWNAME",getFixedLabel("ALL"));
            if($customviewdtls["setdefault"] == 1) {
                $smarty->assign("CHECKED","checked");
            }
            $status = $customviewdtls["status"];
            $smarty->assign("STATUS",$status);
            /*for($i=1;$i<10;$i++) {
                $choosecolslist = getByModule_ColumnsList($cv_module,$modulecollist,$selectedcolumnslist[$i-1]);
                $smarty->assign("CHOOSECOLUMN".$i,$choosecolslist);
            }*/
        }
        $stdfilterlist = $oCustomView->getStdFilterByCvid($recordid);
        
	
		$stdfilterlist["stdfilter"] = ($stdfilterlist["stdfilter"] != "") ? ($stdfilterlist["stdfilter"]) : ("custom");
		$stdfilterhtml = $oCustomView->getStdFilterCriteria($stdfilterlist["stdfilter"]);
        if($cv_module == 'ServiceCharge')
            $stdfiltercolhtml = CustomView_Columnlist::getStdFilterHTML(array('ServiceContracts','ServiceCharge'),$stdfilterlist["columnname"]);
        else
            $stdfiltercolhtml = CustomView_Columnlist::getStdFilterHTML(array($cv_module),$stdfilterlist["columnname"]);
		//$stdfiltercolhtml = getStdFilterHTML($cv_module,$stdfilterlist["columnname"]);
		$stdfilterjs = $oCustomView->getCriteriaJS();

		$smarty->assign("STARTDATE",$stdfilterlist["startdate"]);
		$smarty->assign("ENDDATE",$stdfilterlist["enddate"]);

		$smarty->assign("STDFILTERCOLUMNS",$stdfiltercolhtml);

		$smarty->assign("STDCOLUMNSCOUNT",count($stdfiltercolhtml));
		$smarty->assign("STDFILTERCRITERIA",$stdfilterhtml);
		$smarty->assign("STDFILTER_JAVASCRIPT",$stdfilterjs);

		$advfilterlist = $oCustomView->getAdvFilterByCvid($recordid);

        $strModule="select tabid from ld_tab where name='".$cv_module."'";
        $result=$adb->query($strModule,null);
        $tabid=$adb->query_result($result,0,0);
		if(!empty($advfilterlist[1]['columns'])){
			for($i=0;$i<count($advfilterlist[1]['columns']);$i++)
			{
				$oldColumnList=explode(":",$advfilterlist[1]['columns'][$i]['columnname']);
				$strArr=explode("_",$oldColumnList[3]);
				$advfilterlist[1]['columns'][$i]['columnname']=$oldColumnList[0].":".$oldColumnList[1].":".$oldColumnList[2].":".$strArr[0]."_fieldlabel".":".$oldColumnList[4];
				$advfilterlist[1]['columns'][$i]['search_comparator']=$advfilterlist[1]['columns'][$i]['comparator'];
			}
		}

		$advfilterhtml = CustomView_Columnlist::getAdvCriteriaHTML();

		$modulecolumnshtml = CustomView_Columnlist::getByModule_ColumnsHTML($cv_module,$modulecollist);
		$smarty->assign("FOPTION",$advfilterhtml);
		$smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);
		$smarty->assign("CRITERIA_GROUPS",$advfilterlist);
       // print_r($advfilterlist);
		$smarty->assign("MANDATORYCHECK",implode(",",array_unique($oCustomView->mandatoryvalues)));
		$smarty->assign("SHOWVALUES",implode(",",$oCustomView->showvalues));
		$smarty->assign("EXIST","true");
		$cactionhtml = "<input name='customaction' class='button' type='button' value='Create Custom Action' onclick=goto_CustomAction('".$cv_module."');>";

		if( $cv_module == "Accounts" || $cv_module == "Contacts")
		{
			$smarty->assign("CUSTOMACTIONBUTTON",$cactionhtml);
		}
        $data_type[] = $oCustomView->data_type;
        $smarty->assign("DATATYPE",$data_type);

    }
    else {
    /*
    edit:can
    date:20130812
    reason:4727: "创建数据分类"："复制"按钮应该不用控制操作权限
    */
	if($oCustomView->isPermittedCustomView($recordid,$now_action,$oCustomView->customviewmodule) == 'yes'||$isduplicate) {
		$customviewdtls = $oCustomView->getViewDetailInfo($recordid);
	
		//高级查询下拉框字段内容: 当前模块全部可用字段
        $modulecollist = $oCustomView->getModuleColumnsList($cv_module);
     
		$selectedcolumnslist = $oCustomView->getColumnsListByCvid($recordid);
		
	    if($isduplicate)//复制视图
        {
            $smarty->assign("VIEWNAME","");
            /*
            edit by LD Can
            date:20130327
            reason:0003535: 选中一个"视图"，点击"复制"，结果在复制编辑界面的列里面会显示2个"负责人"，希望查查原因。
            */
            $smarty->assign("viewCopy","viewCopy");
        }
        else 
        {
           $smarty->assign("VIEWNAME",$customviewdtls["viewname"]); 
           if($customviewdtls["setdefault"] == 1) {
    			$smarty->assign("CHECKED","checked");
    		}
    		if($customviewdtls["setmetrics"] == 1) {
    			$smarty->assign("MCHECKED","checked");
    		}
    		$status = $customviewdtls["status"];
    		$smarty->assign("STATUS",$status);
            $smarty->assign("viewCopy","NoCopy");
        }

		/*for($i=1;$i<10;$i++) {
			$choosecolslist = getByModule_ColumnsList($cv_module,$modulecollist,$selectedcolumnslist[$i-1]);
			$smarty->assign("CHOOSECOLUMN".$i,$choosecolslist);
		}*/
       
		$stdfilterlist = $oCustomView->getStdFilterByCvid($recordid);
  
		$stdfilterlist["stdfilter"] = ($stdfilterlist["stdfilter"] != "") ? ($stdfilterlist["stdfilter"]) : ("custom");
		$stdfilterhtml = $oCustomView->getStdFilterCriteria($stdfilterlist["stdfilter"]);
        
        if($cv_module == 'ServiceCharge')
            $stdfiltercolhtml = CustomView_Columnlist::getStdFilterHTML(array('ServiceContracts','ServiceCharge'),$stdfilterlist["columnname"]);
        else
            $stdfiltercolhtml = CustomView_Columnlist::getStdFilterHTML(array($cv_module),$stdfilterlist["columnname"]);
		//$stdfiltercolhtml = getStdFilterHTML($cv_module,$stdfilterlist["columnname"]); 
              
		$stdfilterjs = $oCustomView->getCriteriaJS();
	
		$smarty->assign("STARTDATE",$stdfilterlist["startdate"]);
		$smarty->assign("ENDDATE",$stdfilterlist["enddate"]);
	
		$smarty->assign("STDFILTERCOLUMNS",$stdfiltercolhtml);
       
		$smarty->assign("STDCOLUMNSCOUNT",count($stdfiltercolhtml));
		$smarty->assign("STDFILTERCRITERIA",$stdfilterhtml);
		$smarty->assign("STDFILTER_JAVASCRIPT",$stdfilterjs);
	
		$advfilterlist = $oCustomView->getAdvFilterByCvid($recordid);


       // $strModule="select tabid from ld_Tab where name='".$cv_module."'";
        
        //$params=array($cv_module);
        //$result=$adb->query($strModule,null);
        $tabid=getTabid($cv_module);
      if($tabid==9)
            $tabid=16;
        for($i=0;$i<count($advfilterlist[1]['columns']);$i++)
        {
            $oldColumnList=explode(":",$advfilterlist[1]['columns'][$i]['columnname']);

            $strArr=explode("_",$oldColumnList[3]);

            $advfilterlist[1]['columns'][$i]['columnname']=$oldColumnList[0].":".$oldColumnList[1].":".$oldColumnList[2].":".$strArr[0]."_fieldlabel".":".$oldColumnList[4];
        }

		$advfilterhtml = CustomView_Columnlist::getAdvCriteriaHTML();
		$modulecolumnshtml = CustomView_Columnlist::getByModule_ColumnsHTML($cv_module,$modulecollist);
        
		$smarty->assign("FOPTION",$advfilterhtml);
      
        
		$smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);
		$smarty->assign("CRITERIA_GROUPS",$advfilterlist);
       // print_r($advfilterlist);
		$smarty->assign("MANDATORYCHECK",implode(",",array_unique($oCustomView->mandatoryvalues)));
 		
 		if(!empty($oCustomView->showvalues)){
 			$smarty->assign("SHOWVALUES",implode(",",$oCustomView->showvalues));
 		}else{
 			$smarty->assign("SHOWVALUES",'');
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
if(isset($_REQUEST['SearchScope']))
{
    $SearchScope=$_REQUEST['SearchScope'];
}

$smarty->assign('NOVIEWNAME',$customviewdtls["viewname"]);
$smarty->assign("SEARCHSCOPE",$SearchScope);
//$smarty->display("CustomView.tpl");


$_REQUEST['diony']='yes';
$content=$smarty->fetch("CustomView.tpl");
$arr['title']=getTranstab($currentModule);
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;

ConvertTojsonString(1,$arr,"success");
exit();
?>