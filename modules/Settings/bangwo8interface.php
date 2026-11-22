<?php

$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings;
require_once('modules/Users/Group.class.php');

crm_load_class_file("CommonView","modules/CustomView");

if(isset($_REQUEST['mode'])&&$_REQUEST['mode']!=''){
     $mode=$_REQUEST['mode'];
}
if(isset($_REQUEST['editinterface'])&&$_REQUEST['editinterface']!=''){
    $editinterface=$_REQUEST['editinterface'];
    if($editinterface=='editinterface'){
        $vendorid=$_REQUEST['vendorid'];
        $authcode=$_REQUEST['authcode'];
		$presence = $_REQUEST['presence'];
		$is_customer = $_REQUEST['is_customer'];	//是否同步客户到帮我吧
        $bangwo8_supportname=getBangwo8Supportname($vendorid,$authcode);
		//if(!varify_url('https://www.bangwo8.com')){
		//	echo '##NOURL##';EXIT();
		//}
        if(is_array($bangwo8_supportname) && count($bangwo8_supportname)<=0){//密钥或者vendorid不正确，客服账号为空；
			$_REQUEST['diony']='yes';
			ConvertTojsonString(-1,array(),"ISNULL");
        }else{
			if($is_customer == 0){
				//验证帮我吧账号是否存在
				if(!is_array($bangwo8_supportname) || !in_array($_REQUEST['supportname'],$bangwo8_supportname)){
					$_REQUEST['diony']='yes';
					ConvertTojsonString(-1,array(),"NOSUPPORTNAME");
				}
				//验证帮我吧账号和密码是否有效
				if(!setBangwo8Supportname($_REQUEST['supportname'],$_REQUEST['supportpwd'])){
					$_REQUEST['diony']='yes';
					ConvertTojsonString(-1,array(),"INCORRECT");
				}
			}
			$selsql='select 1 from ld_bangwo8';
			$selresult=$adb->pquery($selsql);
			if($adb->num_rows($selresult)>0){
				$updatesql='update ld_bangwo8 set vendorid=?,authcode=?,presence=?,is_customer=?';
				$adb->pquery($updatesql,array($vendorid,$authcode,$presence,$is_customer)); 
			}else{
				 $insetquery='insert into ld_bangwo8(vendorid,authcode,presence,is_customer) values(?,?,?,?)' ;
				 $adb->pquery($insetquery,array($vendorid,$authcode,$presence,$is_customer));
			}
            if (is_array($bangwo8_supportname)) {
                for($i=0;$i<count($bangwo8_supportname);$i++){
                    $sql='select 1 from ld_bangwo8_supportname where supportname=?';
                    $result=$adb->pquery($sql,array($bangwo8_supportname[$i]));
                    if($adb->num_rows($result)<=0){
                        $insertSql='insert into ld_bangwo8_supportname(supportname,allocatetype) values(?,?)';
                        $adb->pquery($insertSql,array($bangwo8_supportname[$i],'user'));

                    }
                }
            }

			//删除不属于当前vendorid所获得的客服账号
			$select_del='select supportname from ld_bangwo8_supportname';
			$select_del_result=$adb->pquery($select_del);
			$select_del_num=$adb->num_rows($select_del_result);
			if($select_del_num>0){
				for($j=0;$j<$select_del_num;$j++){
					$select_supportname=$adb->query_result($select_del_result,$j,'supportname');
					if(!is_array($bangwo8_supportname) || !in_array($select_supportname,$bangwo8_supportname)){
					   $delsql='DELETE from ld_bangwo8_supportname where supportname=?'; 
					   $adb->pquery($delsql,array($select_supportname)); 
					}else{
						if(!empty($_REQUEST['supportname']) && $_REQUEST['supportname'] == $select_supportname){
							$query = 'update ld_bangwo8_supportname set supportpwd = ? where supportname = ?';
							$adb->pquery($query,array($_REQUEST['supportpwd'],$_REQUEST['supportname']));
						}else{
							$query = 'update ld_bangwo8_supportname set supportpwd = "" where supportname = ?';
							$adb->pquery($query,array($select_supportname));
						}
					}
				}
			}
			//提醒高级条件设置保存
			if(!empty($_REQUEST['columnlist'])){
				$query = 'delete from ld_bangwobacvadvfilter where id = 1';
				$adb->pquery($query,array());
				$query = 'delete from ld_bangwobacvadvfilter_grouping where id = 1';
				$adb->pquery($query,array());
				$columlist = json_decode($_REQUEST['columnlist']);
				for($i=0;$i<count($columlist);$i++)
				{
					$sql="INSERT INTO ld_bangwobacvadvfilter (id,columnindex,columnname,comparator,value,column_condition,groupid) VALUES(?,?,?,?,?,?,?)"; 
					//$columname=explode(':',$columlist[$i]['fcol']);
					$params=array(
						1,
						$i+1,
						$columlist[$i][0],
						$columlist[$i][1],
						$columlist[$i][2],
						$columlist[$i][3],
						'1',
					);
					$adb->pquery($sql,$params);
				}
				 //分组保存
				$nums=sizeOf($columlist);
				$str="";
				for($i=0;$i<$nums;$i++){
					$str.= $i.' and ';
				}
				$str = trim($str,'and ');
				//echo $str;exit;
				$params=array(1,1,'',$str);
				$sql="INSERT into ld_bangwobacvadvfilter_grouping (groupid,id,group_condition,condition_expression) 
					  VALUES (?,?,?,?)";     
				$adb->pquery($sql,$params);
			}
		 }
    }
    $_REQUEST['diony']='yes';
	ConvertTojsonString(1,array(),"success");
}
$showsql='select is_customer from ld_bangwo8';
$showresult=$adb->pquery($showsql);
if($adb->num_rows($showresult)>0 && $adb->query_result($showresult,0,'is_customer') == 0){
    $smarty->assign('ISSHOW','yes');
}
$listdata=getListdata();//获取客服账号区块列表信息
foreach($listdata as $support_info){
	if(!empty($support_info['supportpwd'])){
		$smarty->assign('SUPPORTNAME',$support_info['supportname']);
		$smarty->assign('SUPPORTPWD',$support_info['supportpwd']);
	}
}
$smarty->assign('LISTDATA',$listdata);
$smarty->assign('THENME',$theme);
$smarty->assign('MODE',$mode);
$sql='select * from ld_bangwo8';
$result=$adb->pquery($sql,array());
if($adb->num_rows($result)>0)
{
    $smarty->assign("ID",$adb->query_result($result,0,'id'));
    $smarty->assign("VENDORID",$adb->query_result($result,0,'vendorid'));
    $smarty->assign("AUTHCODE",$adb->query_result($result,0,'authcode'));
	$smarty->assign("PRESENCE",$adb->query_result($result,0,'presence'));
	$smarty->assign("ISCUSTOMER",$adb->query_result($result,0,'is_customer'));
}
//高级查询开始
$sql="SELECT * from ld_bangwobacvadvfilter where id=1";

$result=$adb->pquery($sql,array());
$nums=$adb->num_rows($result);

$AdvancedSearch=array();
for($i=0;$i<$nums;$i++)
{
    $columnname=explode(":",$adb->query_result($result,$i,'columnname'));
    $tablename=$columnname[0];//
	$tab_fieldlabel = explode('_',$columnname[3]);
    $columnname=$columnname[1];
   // echo $adb->query_result($result,$i,'columnname');echo '<br><br>';
	$focus=CRMEntity::getInstance($tab_fieldlabel[0]);
    $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldlabel'); 

    $AdvancedSearch[]=array(
        'columnindex'=>$i+1,
        'columnname'=>$fieldlabel,
        'comparator'=>getAdvCriteriaValue($adb->query_result($result,$i,'comparator')),
        'value'=>$adb->query_result($result,$i,'value'),
        'column_condition'=>$adb->query_result($result,$i,'column_condition'),
    );
}
$smarty->assign('AdvancedSearch',$AdvancedSearch);
$oCustomView = new CustomView();
$modulecollist = $oCustomView->getModuleColumnsList('Accounts');
$modulecolumnshtml = getByModule_ColumnsHTML('Accounts',$modulecollist);//高级查询select option
$modulecollist = $oCustomView->getModuleColumnsList('Contacts');
$modulecolumnshtml .= getByModule_ColumnsHTML('Contacts',$modulecollist);//高级查询select option
$smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);//高级查询select option 1
$advfilterlist = getAdvFilterByCvidRemind();
$smarty->assign("CRITERIA_GROUPS",$advfilterlist);
$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);
$advfilterhtml = CommonView::getAdvCriteriaHTML($fLabels);
$smarty->assign("FOPTION",$advfilterhtml);//高级查询select option 2
Crm_load_class_file('CommonView',"modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
// include("SetmenuControl.php");
if($mode == 'edit'){
	if(!empty($advfilterlist))
		$arr['criteria_groups']=$advfilterlist;	
	else
		$arr['criteria_groups']="";
	$arr['foption']=$advfilterhtml;
	$arr['columns_block']=$modulecolumnshtml;
	$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    $advanceFields_Accounts = ListViewController::getInstance('Accounts')->getAdvanceFields();
    $advanceFields_Contacts = ListViewController::getInstance('Contacts')->getAdvanceFields();
    $arr['advanceFields'] = array_merge($advanceFields_Accounts, $advanceFields_Contacts);
	$arr['flabels']=$fLabels; 
	$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
	$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
	   
	$arr['tipsetreminder']=getFixedLabel('PLEASESETREMINDER');
//	$arr['modulelabel']=getTranstab($tabname);
}

//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//帮我吧接口设置帮助
$labels = array('Bangwo8Interface');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);

$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('BANGWO8INTERFACE');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('bangwo8interface.tpl');
ConvertTojsonString(1,$arr,"success");

/**
 * @edit:cyb
 * @date:2016-05-19
 * @reason:调用bangwo8接口获取帮我吧客服账号
**/
function getBangwo8Supportname($vendorid,$authcode){
        $urlcon='https://www.bangwo8.com/api/apiGetSupprotNames.php?vendorID='.$vendorid.'&authcode='.$authcode;
        $data = '';
        $ch = curl_init($urlcon); //请求的URL地址
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);//$data JSON类型字符串
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Content-Length: ' . strlen($data)));
        $ret_data = curl_exec($ch); 
        $returndata=json_decode($ret_data);
        $supportnames=$returndata->supprotNames ; 
        return  $supportnames;
}
function getAdvCriteriaValue($comparator='')
{
    if($comparator=='e')
    {
        $value = getFixedLabel('EQ');
    }else if($comparator=='n')
    {
        $value = getFixedLabel('NEQ');
    }	else if($comparator=='s')
    {
        $value = getFixedLabel('Begins');
    }else if($comparator=='ew')
    {
        $value = getFixedLabel('Ends');
    }else if($comparator=='c')
    {
        $value = getFixedLabel('IN');
    }else if($comparator=='k')
    {
        $value = getFixedLabel('NOT_IN');
    }
    else if($comparator=='isnull')
    {
        $value=getFixedLabel('ISNULL');
    }
    else if($comparator=='isnotnull')
    {
        $value=getFixedLabel('ISNOTNULL');
    }
    else
    {
         $tmps= CommonView::stdFilterDateTimeStr();
      
         
         if(array_key_exists($comparator,$tmps))
         {
          
            $value=$tmps[$comparator][2];
            
         }
         else
         {
             $value = getFixedLabel('NONE');
         }
    } 
   

    return $value;
}
//验证帮我吧账号
function setBangwo8Supportname($supportname,$supportpwd){
	if(!empty($supportname) && !empty($supportpwd)){
		$url='https://www.bangwo8.com/api/v1/companies.json';
		$ch = curl_init(); //请求的URL地址
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
		curl_setopt($ch, CURLOPT_USERPWD, "".$supportname.":".$supportpwd."");
		$campany_info['company']['companyName'] = '';
		$data=json_encode($campany_info);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $data);//$data JSON类型字符串
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Content-Length: ' . strlen($data)));
		$ret_data = json_decode(curl_exec($ch));
		if(!empty($ret_data->status) && $ret_data->status == '40001'){
			return false;
		}
	}
	return true;
}
function getByModule_ColumnsHTML($module,$columnslist,$selected="") {
    global $mod_strings;
	$columnsList = getByModule_ColumnsList($module,$columnslist,$selected);
 
    /**
    * edit:chj
    * date:2014-1-12
    * reason: 模块，产品明细 查询条件显示产品明细内容
    **/
    if(get_file_address($module,'ProductDetails'))
    {
        crm_load_class_file('CustomView_Special','modules/CustomView');
        $columnsList[getTranstab('Products').getFixedLabel('INFORMATION')] = CustomView_Special::getProductSearchCustom($module,getCvadfilter($_REQUEST['record']));   
    }
	return generateSelectColumnsHTML($columnsList,$module);
}

function getByModule_ColumnsList($module,$columnslist,$selected="") {
	global $oCustomView, $current_language,$theme;
	global $app_list_strings;
    global $adb;
	$advfilter = array();
	//$mod_strings = return_specified_module_language($current_language,$module);

    /*
    edit by LD Can
    date:2013026
    reasion:3268: 页面布局修改字段名称之后，导致已创建的视图中“选择字段”显示异常
    
    */
	$check_dup = Array();

	foreach($oCustomView->module_list[$module] as $key=>$value)
	{
		$advfilter = array();			
		$label = $key;
		if(isset($columnslist[$module][$key]))
		{
			foreach($columnslist[$module][$key] as $field=>$fieldlabel)
			{
				if(!is_array($check_dup) || !in_array($fieldlabel,$check_dup))
				{
					if(isset($mod_strings[$fieldlabel]))
					{
					   $arrselected=explode(":",$selected);
                      $arrfield=explode(":",$field);
                       
					//if($selected == $field)
                   if($arrselected[0]==$arrfield[0] && $arrfield[1]==$arrselected[1])
                   {
							$advfilter_option['value'] = $field;
							$advfilter_option['text'] = $fieldlabel;
							$advfilter_option['selected'] = "selected";
						}else
						{
							$advfilter_option['value'] = $field;
							$advfilter_option['text'] = $fieldlabel;
							$advfilter_option['selected'] = "";
						}
					}else
					{
					   $arrselected=explode(":",$selected);
                      $arrfield=explode(":",$field);
                       
						//if($selected == $field)
                    if($arrselected[0]==$arrfield[0] && $arrfield[1]==$arrselected[1])
						{
							$advfilter_option['value'] = $field;
							$advfilter_option['text'] = $fieldlabel;
							$advfilter_option['selected'] = "selected";
						}else
						{
							$advfilter_option['value'] = $field;
							$advfilter_option['text'] = $fieldlabel;
							$advfilter_option['selected'] = "";
						}
					}
					$advfilter[] = $advfilter_option;
					$check_dup [] = $fieldlabel;
				}
			}
			$advfilter_out[$label]= $advfilter;
		}
	}
	
	return $advfilter_out;
}
function getCvadfilter($cvid)
{
    global $adb;
    $sql = "select columnname from ld_cvadvfilter where cvid = ?";
    $result = $adb->pquery($sql,array($cvid));
    for ($i=0;$i<$adb->num_rows($result);$i++) {
        $array[$i] = $adb->query_result($result, $i, "columnname");
    }
    return $array;
}
function generateSelectColumnsHTML($columnsList, $module) {
	$shtml = '';
	
	foreach($columnsList as $blocklabel=>$blockcolumns) {
    	$shtml .= "<optgroup label='".getTransTab($module).'_'.$blocklabel."' class='select' style='border:none'>";
    	foreach($blockcolumns as $columninfo) {
      		$shtml .= "<option ".$columninfo['selected']." value='".$columninfo['value']."'>".$columninfo['text']."</option>";
    	}
  	}
  	return $shtml;	
}
/**
 * @edit:cyb
 * @date:2016-05-19
 * @reason:获取帮我吧客服区块列表数据信息
 **/
function getListdata(){
   global $adb;
   $sql='SELECT
			ld_bangwo8_supportname.id,
			ld_bangwo8_supportname.supportname,
			ld_bangwo8_supportname.supportpwd,
			ld_users.last_name,allocatetype,userid
		FROM
			ld_bangwo8_supportname
		LEFT JOIN ld_users ON ld_bangwo8_supportname.operate_smownerid = ld_users.id
		order by ld_bangwo8_supportname.id asc';
    $result=$adb->pquery($sql);
    $num=$adb->num_rows($result);
    if($num>0){
		$group = new Group();
		$group_names = $group->getGroupIdName();
        for($i=0;$i<$num;$i++){
			$view_username = '';
			$user_name = array();
			$group_name = array();
            $bangwo8_id=$adb->query_result($result,$i,'id');
			$allocatetype = $adb->query_result($result,$i,'allocatetype');
			$ids = $adb->query_result($result,$i,'userid');
			$listdata[$bangwo8_id]['supportname']=$adb->query_result($result,$i,'supportname');
			$listdata[$bangwo8_id]['supportpwd']=$adb->query_result($result,$i,'supportpwd');
			
			if($allocatetype == 'all'){
				$view_username = getFixedLabel('ALLTHEUSERS');
			}else if($allocatetype == 'user'){
				if(!empty($ids)){
					$id_arr = explode(',',$ids);
					for($k = 0; $k<count($id_arr); $k++){
						$user_name[] = getUserFullName($id_arr[$k]);
					}
					$view_username = implode(';',$user_name);
				}
			}else if($allocatetype == 'group'){
				$id_arr = explode(',',$ids);
				for($k = 0; $k<count($id_arr); $k++){
					$group_name[] = $group_names[$id_arr[$k]];
				}
				$view_username = implode(';',$group_name);
			}
			$listdata[$bangwo8_id]['view_username'] = $view_username;
            $listdata[$bangwo8_id]['user_name']=$adb->query_result($result,$i,'last_name');
        }
    } 
    //print_r($listdata);die;
    return $listdata;
}

function getAdvFilterByCvidRemind() {

	global $adb,  $default_charset;

	$advft_criteria = array();

	$sql = 'SELECT * FROM ld_bangwobacvadvfilter_grouping WHERE id = 1 ORDER BY groupid';
	$groupsresult = $adb->pquery($sql, array());
    $i = 1;
	$j = 0;
	while ($relcriteriagroup = $adb->fetch_array($groupsresult)) {
		$groupId = $relcriteriagroup["groupid"];
		$groupCondition = $relcriteriagroup["group_condition"];

		$ssql = 'select ld_bangwobacvadvfilter.* from ld_bangwobacvadvfilter
					left join ld_bangwobacvadvfilter_grouping on ld_bangwobacvadvfilter.id = ld_bangwobacvadvfilter_grouping.id
							';
		$ssql.= " where ld_bangwobacvadvfilter.id = ? AND ld_bangwobacvadvfilter.groupid = ? order by ld_bangwobacvadvfilter.columnindex";

		$result = $adb->pquery($ssql, array(1, $groupId));
        
		$noOfColumns = $adb->num_rows($result);
		if ($noOfColumns <= 0)
			continue;

		while ($relcriteriarow = $adb->fetch_array($result)) {
			$columnIndex = $relcriteriarow["columnindex"];
			$criteria = array();
			$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
			$criteria['comparator'] = $relcriteriarow["comparator"];
			$advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
			$col = explode(":", $relcriteriarow["columnname"]);
			$temp_val = explode(",", $relcriteriarow["value"]);
			if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
			     crm_load_class_file("DateTimeField","include/fields");
            	$val = Array();
				for ($x = 0; $x < count($temp_val); $x++) {
					if ($col[4] == 'D') {
						$date = new DateTimeField(trim($temp_val[$x]));
						$val[$x] = $date->getDisplayDate();
					} elseif ($col[4] == 'DT') {
						$date = new DateTimeField(trim($temp_val[$x]));
						$val[$x] = $date->getDisplayDateTimeValue();
					} else {
						$date = new DateTimeField(trim($temp_val[$x]));
						$val[$x] = $date->getDisplayTime();
					}
				}
				$advfilterval = implode(",", $val);
			}
			$criteria['value'] = $advfilterval;
			$criteria['column_condition'] = $relcriteriarow["column_condition"];

			$advft_criteria[$i]['columns'][$j] = $criteria;
			$advft_criteria[$i]['condition'] = $groupCondition;
			$j++;
		}
		if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
			$advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
		}
		$i++;
	}
	// Clear the condition (and/or) for last group, if any.
	if (!empty($advft_criteria[$i - 1]['condition']))
		$advft_criteria[$i - 1]['condition'] = '';
	return $advft_criteria;
}
?>