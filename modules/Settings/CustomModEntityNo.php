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



global $app_strings;
global $mod_strings;
global $currentModule;
global $current_language;
global $theme;
 global $current_user;
 global $current_user;

$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='CustomModEntityNo';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$prefixtype=0;
if(isset($_REQUEST['prefixtype']))
    $prefixtype=vtlib_purify($_REQUEST['prefixtype']);
    
$recprefix = vtlib_purify($_REQUEST['recprefix']);
$mode = $_REQUEST['mode'];
//ls 2021-08-04 0047188: （https://81mis.com/kfbcrm [^]）单据编号定制，使用前缀，固定字符录入中文和冒号等特殊字符保存时一直显示加载中
/*$validInput = validateAlphaNumericInput($recprefix);
if(!empty($recprefix) && ! $validInput) {
    $recprefix = '';
    $mode='';
    $STATUSMSG = "<font color='red'>".getFixedLabel('UPDATEFINISHED')."</font>";
}*/
$recnumber = vtlib_purify($_REQUEST['recnumber']);
$datetype = vtlib_purify($_REQUEST['datetype']);
$useuseraccount = vtlib_purify($_REQUEST['UseUserAccount']);

//andy 新增参数
$isallow=0;
if(isset($_REQUEST['isallow']))
    $isallow=vtlib_purify($_REQUEST['isallow']);

$module_array=getCRMSupportedModules();
if(count($module_array) <= 0) {
	echo "<table border='0' cellpadding='0' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
	echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>

		<table border='0' cellpadding='5' cellspacing='0' width='98%'>
		<tbody><tr>
		<td rowspan='2' width='11%'><img src= " . lingdang_imageurl('denied.gif', $theme) . " ></td>
		<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'>
			<span class='genHeaderSmall'>".getFixedLabel('UPDATEFINISHED')."</span></td>
		</tr>
		</tbody></table>
		</div>";
	echo "</td></tr></table>";
	exit;	
}

$modulesList = array_keys($module_array);

$selectedModule = vtlib_purify($_REQUEST['selmodule']);
if($selectedModule == '') $selectedModule = $modulesList[0];

if(in_array($selectedModule, $module_array)) {
	$focus = CRMEntity::getInstance($selectedModule);
}
$reset_value = vtlib_purify($_REQUEST['reset_value']);	//流水号每天自动重置
$complement = vtlib_purify($_REQUEST['complement']);	//流水号自动补足位数
if($mode == 'UPDATESETTINGS') {
	if(isset($focus)) {
        /**
         * @by andy
         * @date 20140728
         * @reason 系统编号改进
         * @version v5.56
         */
         if($prefixtype==2)
         {
            $recprefix="";
         }
        $status = $focus->Library('SystemCode')->setModuleSeqNumber('configure', $selectedModule, $recprefix, $recnumber, $datetype,$useuseraccount,$isallow,$prefixtype,$reset_value,$complement); 
		//old::$status = $focus->setModuleSeqNumber('configure', $selectedModule, $recprefix, $recnumber, $datetype,$useuseraccount);
		if($status === false&&$prefixtype!=2) {
			$STATUSMSG = "<font color='red'>".getFixedLabel('UPDATEFAILED')."</font>  ".getFixedLabel('CURRENTCODE').getFixedLabel('WAREHOUSEUSEING');
		} else {
		      //清除缓存
            $cachekey = 'cache_modentityfieldinfo';
            unsetCache($cachekey);
			$STATUSMSG = getFixedLabel('UPDATEFINISHED');
            //zkt 20220505 51438(https://61mis.com/order/index.php)  租赁客户注册信息》单据编号，在列表界面点击编辑提示“【单据编号】字段在列表界面不能编辑”
            //同步更新对应的editpage值
            $checknofield = $adb->pquery("select * from ld_field where tabid=? and uitype = 4",array(getTabid($selectedModule)));
            if($adb->num_rows($checknofield)>=1){
                $updatefieldsql = "update ld_field set editpage = ? where  tabid=? and uitype = 4";
                if($isallow == 1){
                    $adb->pquery($updatefieldsql,array('listview',getTabid($selectedModule)));
                }
                else{
                    $adb->pquery($updatefieldsql,array('',getTabid($selectedModule)));
                }
                unsetCacheDirectory('fields');
            }
            
 		}
		$_REQUEST['diony']='diony';
		ConvertTojsonString(1,array('log'=>$STATUSMSG),"success");
        
	}
} else if($mode == 'UPDATEBULKEXISTING') {	//看了下代码，暂时没有用到
	if(isset($focus)) {
		$resultinfo = $focus->Library('SystemCode')->updateMissingSeqNumber($selectedModule);
		
		if(!empty($resultinfo)&&$prefixtype!=2) {
			$usefontcolor = 'green';
			if($resultinfo['totalrecords'] != $resultinfo['updatedrecords']) $usefontcolor = 'red';
			
			$STATUSMSG = "<font color='$usefontcolor'>" . 
				getFixedLabel('TOTAL') . $resultinfo['totalrecords'] . ", " . 
				getFixedLabel('UPDATEFINISHED'). ':' . $resultinfo['updatedrecords'] . 
				"</font>";
		}		
		$seqinfo = $focus->Library('SystemCode')->getModuleSeqInfo($selectedModule);
		$recprefix = $seqinfo[0];
		$recnumber = $seqinfo[1];
        /***
        *更新操作
        *负责人：karl
        *日期:2013.12.17
        *说明：系统编号定制改进，增加使用日期
        ***/
		$datetype = $seqinfo[2];
         /***
        *更新操作
        *负责人：lmx
        *日期:20140308
        *说明：系统编号定制改进，增加使用用户账号
        ***/
		$useuseraccount = $seqinfo[3];
        
        $isallow = $seqinfo[4];
        $prefixtype = $seqinfo[5];
	}
} else {
	//列表
	if(isset($focus)) {
		$seqinfo = $focus->Library('SystemCode')->getModuleSeqInfo($selectedModule);
		$recprefix = $seqinfo[0];
		$recnumber = $seqinfo[1];
		$datetype = $seqinfo[2];
 	    $useuseraccount = $seqinfo[3];
        /**
         * @by andy
         * @date 20140728
         * @reason 系统编号改进
         * @version v5.56
         */
        $isallow = $seqinfo[4];
        $prefixtype = $seqinfo[5];
		$reset_value = $seqinfo[6];
		$complement = $seqinfo[7];
	}
}
/***
        *更新操作
        *负责人：karl
        *日期:2013.12.17
        *说明：系统编号定制改进，增加使用日期
        ***/
$allDateType = array('none','yymm','yymm.','yymm-','yy-mm','mmdd','mm-dd','yyyymmdd','yyyymmdd-','yyyy-mm-dd','yyyy-mm-dd-');
$cur_datetype = "";
foreach($allDateType as $value)
{
    if($value=='none') 
    {
        $selecttype='--'.getFixedLabel('DONOTUSE').'--';
    }
    else 
    {   
        $selecttype=$value;
    }
    $datetypeSelected="";
    if($value==$datetype) 
    {
        $datetypeSelected="selected='selected'";
    }
    $cur_datetype .= "<option value= '".$value."'".$datetypeSelected.">".$selecttype."</option>";
}
/*end*/

$smarty = new lingdangCRM_Smarty;

//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("CMOD", $mod_strings);

//andy begin 赋值
//手动编码
$smarty->assign("isallow", $isallow);
//前缀
$smarty->assign("prefixtype", $prefixtype);
//省份、城市字段翻译
$smarty->assign("state", gettranslabelfields($selectedModule,'bill_state'));
$smarty->assign("bill_city", gettranslabelfields($selectedModule,'bill_city'));
if($languageType =='')
    $languageType='zh';
$smarty->assign("languageType", $languageType);
//andy end
$smarty->assign('RESETVALUE',$reset_value);
$smarty->assign('COMPLEMENT',$complement);
$smarty->assign('DATETYPE',$datetype);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("USEUSERACCOUNT",$useuseraccount);
$smarty->assign("MODULES",$module_array);
$smarty->assign("SELMODULE",$selectedModule);
$smarty->assign("MODNUM_PREFIX",$recprefix);
$smarty->assign("MODNUM", $recnumber);
/***
*更新操作
*负责人：karl
*日期:2013.12.17
*说明：系统编号定制改进，增加使用日期
***/
$smarty->assign("CUR_DATETYPE",$cur_datetype);
/*end*/
$smarty->assign("STATUSMSG", $STATUSMSG);

// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
if($_REQUEST['ajax'] == 'true'){
    $smarty->display('Settings/CustomModEntityNoInfo.tpl');
}else{
    $arr['content']= $smarty->fetch('Settings/CustomModEntityNo.tpl');
    ConvertTojsonString(1,$arr,"success");
}
function getCRMSupportedModules()
{
	global $adb;
	//$sql="select tabid,name from ld_tab where isentitytype = 1 and presence = 0 and tabid in(select distinct tabid from ld_field where uitype='4') order by tabsequence";
	/**
      *@edit:andy 
      *@date:20140905
      *@reason:	0011154: 系统编号中不需要"服务收费"编号,应去除
      *@version:v5.7
      */
    $sql="select tabid,name from ld_tab where isentitytype = 1 and presence = 0 and tabid in(select distinct tabid from ld_field where uitype='4') and tabid not IN
    (SELECT tabid from ld_tab where name in ('ServiceCharge'))
    order by tabsequence";
    $result = $adb->query($sql);
	while($moduleinfo=$adb->fetch_array($result))
	{
		$modulelist[$moduleinfo['name']] = $moduleinfo['name'];
	}
	return $modulelist;
}

?>