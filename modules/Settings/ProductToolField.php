<?php
/**
 * 单据分录自定义
 * @reason 单据分录自定义
 * @author Chj 2015/5/27
 */
global $adb;
global $theme,$current_user;
$languageType= getLanguageType($current_user);
//zxm 保存设置前几列冻结 保存
if(isset($_REQUEST['setdetail_issticky'])&&$_REQUEST['setdetail_issticky']=='yes'){
    $update_sql = "update ld_tab set detail_issticky=? where tabid=?";
    $adb->pquery($update_sql,array($_REQUEST['detail_issticky'],$_REQUEST['selectTabid']));
    //清除缓存
    $key = 'ldcrmTabdetail_issticky';
    unsetCache($key);
    ConvertTojsonString(1,[],"success");
}
require('include/ProductToolFields/cls_AutoLoadDetailFields.php');
$smarty=new lingdangCRM_Smarty();
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='ProductToolField';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';


$curmodule=getTabname($_REQUEST['tabid']);
$curfocus=CRMEntity::getInstance($curmodule);
/*获取所有带有产品明细的模块*/
$query = 'select tabid,name from ld_tab ';
//zkt 0048676: （http://42.194.219.75:85/crm [^] ）客户问题（广州源丰）自营管理-产值及成本核算-单据分录设置，新增引用字段后点编辑出现错误
if(get_file_address($curmodule,$curmodule.'DetailFieldsHtml')&&($curmodule!='CashBill'&&$curmodule != 'SendCashBill') )
{
        //自定义模块插入字段，不需要再其他模块插入字段
       $query.=" where tabid=".$_REQUEST['tabid'];
       
}
$query.=" order by tabsequence asc";
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
$j = 0;
$productModule = array();
for($i = 0; $i<$num_rows; $i++){
	$isModule = $adb->query_result($result,$i,'name');
	$isTabid = $adb->query_result($result,$i,'tabid');

    // 单据分录定制，移除价格政策
    if($isModule === 'PricePolicy') {
        continue;
    }
    
	if($isModule=='Potentials'||get_file_address($isModule,'ProductDetails') || get_file_address($isModule,$isModule.'DetailFieldsHtml')){
	//if(get_file_address($isModule,'ProductDetails') ){
	   if(get_file_address($curmodule,$curmodule.'DetailFieldsHtml')&&($curmodule!='CashBill'&&$curmodule != 'SendCashBill')  )
        {
             //$isfocus=CRMEntity::getInstance($isModule);
            // if($isfocus->Detail_table!='ld_inventoryproductrel')
            // {
               // continue;
             //}
             continue;
        }
	   //zxm  2021-0621 预算单去除分录定制
		if($isModule == 'ServiceCharge'||$isModule =='ExpenseBudget') continue;
		$insertModule[$i] = array($isTabid => getTranstab($isModule));
		if(vtlib_isModuleActive($isModule) != 1) continue;//模块不启用则不显示
		if($isModule == 'SalesOrder'){
			$productModule[0] = array($isTabid => getTranstab($isModule)); 
		}else{
			$j++;
			$productModule[$j] = array($isTabid => getTranstab($isModule)); 	
		}
        
        
        
	}
}
ksort($productModule);
//$productModule[count($productModule)+1] = array(getTabid('Expense') => getTranstab('Expense'));
$smarty->assign('SELECTMODULE',$productModule);


//获取下拉框第一个模块ID
$first_select_module = (is_array($productModule)&&count($productModule)>0)?array_keys(current($productModule)):[];
if(!empty($_REQUEST['selectTabid'])){//选择模块传入的模块ID
	$now_tabid = $_REQUEST['selectTabid'];
}else if(!empty($_REQUEST['tabid'])){
	$now_tabid = $_REQUEST['tabid'];
}else{
	$now_tabid = $first_select_module[0];	
}
//zxm2021-0629 title部分增加【页面设置】【单据分录定制】按钮 跳转参数
if(!empty($_REQUEST['formodule'])&&$_REQUEST['formodule']!='undefined'){
    $now_tabid = getTabid($_REQUEST['formodule']);
}
//zxm 20220909 设置冻结前几列
$query_tab = "select tabid,detail_issticky from ld_tab where tabid=?";
$query_res = $adb->pquery($query_tab,array($now_tabid));
$detail_issticky = $adb->query_result($query_res,0,'detail_issticky');

$selectmodule_sourcetypearr = array();
$tmpselectmodule = getTabname($now_tabid);
if($tmpselectmodule=='CashBill'||$tmpselectmodule == 'SendCashBill'){
    //获取收款单和付款单对应的源单类型
     crm_load_class_file('cls_OptionModule','include/OptionModule');
    $objs=new cls_OptionModule($tmpselectmodule,0);
    $soureoptions=$objs->getcurModule_Option();
    $selectmodule_sourcetypearr = $soureoptions;
    
   
    foreach($soureoptions as $sourceoptioninfo){
        $selectmodule_sourcetype[$sourceoptioninfo['value']]=$sourceoptioninfo['text'];
    }
    if(isset($_REQUEST['selectsourcetype'])&&!empty($_REQUEST['selectsourcetype']))
    {
        
    }
    else//edit:can 20231013 70997 kfbcrm-收款单/付款单-单据分录定制-没有选择源单时新增字段，会出现多个字段，但是点击选择源单后，该字段不显示（是应该直接控制不选择源单不能新建字段，还是不选源单新建字段后自动更新到每个关联模块内） 
    
     $_REQUEST['selectsourcetype']= $soureoptions[0]['value'];
     
    
}

$smarty->assign('SELECTMODULESOURCETYPE',$selectmodule_sourcetype);

/* editor:gyq_10 reason:实例化对象 date:20160422 */

if($now_tabid > 0){
	$autoLoadInstance = new INSTANCE();
	$ProductToolFields = $autoLoadInstance->autoLoad($now_tabid,'Fields');
}elseif($_REQUEST['tabid'] > 0){
	$autoLoadInstance = new INSTANCE();
	$ProductToolFields = $autoLoadInstance->autoLoad($_REQUEST['tabid'],'Fields');
}
if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] == true){
	if($_REQUEST['type'] == 'allocate'){	//列表分配
		
	}
}
if(isset($_REQUEST['selectsourcetype'])&&!empty($_REQUEST['selectsourcetype'])){
    $ProductToolFields->Setselectsourcetype($_REQUEST['selectsourcetype']);
}

if(isset($_REQUEST['submode'])){
    $ret = '';
	if($_REQUEST['submode'] == 'UpdateFieldSequence')//更改产品自定义显示顺序
		$ret = $ProductToolFields->UpdateFieldSequence();
	elseif($_REQUEST['submode'] == 'SaveProductToolField')//新增产品自定义字段
    {
        $ret = $ProductToolFields->SaveProductToolField($insertModule);
    }
	elseif($_REQUEST['submode'] == 'setProductProfile')//设置自定义字段用户查看权限
	{
		$ProductToolFields->UpdateProductProfile($_REQUEST['frommodule'],$_REQUEST['producttoolfieldid'],$_REQUEST['useridall'],'');
	}
	elseif($_REQUEST['submode'] == 'allocate')//列表分配
	{
		if(!empty($_REQUEST['radiotype'])){
			if($_REQUEST['radiotype'] == 'all'){
				$_REQUEST['selectallocateid'] = '';
			}
			$ProductToolFields->UpdateProductProfile($curmodule,$_REQUEST['record'],$_REQUEST['selectallocateid'],$_REQUEST['radiotype']);
			$_REQUEST['diony']='yes';
			ConvertTojsonString(1,array(),"success");
		}
	}
	elseif($_REQUEST['submode'] == 'UpdateFieldSort')//更新、保存自定义字段显示顺序
		$ProductToolFields->UpdateFieldSort();
	elseif($_REQUEST['submode'] == 'UpdateFieldDis')//显示自定义隐藏字段
		$ProductToolFields->UpdateFieldDis();

	if($ret!="")
	{
	   if($ret =='zhyes'){
		   $_REQUEST['diony']='yes';
			ConvertTojsonString(-1,array(),"HERROR");
	   }elseif($ret == "enyes"){
		    $_REQUEST['diony']='yes';
			ConvertTojsonString(-1,array(),"ENERROR");
       }
	}
    else
    {
        unsetCacheDirectory('productfields');
        unsetCacheDirectory('tabdetailfields');
    }
}
if(!empty($ProductToolFields)){
$ProductToolFields->getDetailInfo();



$jsonList['formula']=$ProductToolFields->formualFields;

$formualFields=json_encode($jsonList);

$smarty->assign('FORMUALFIELDS',$formualFields);//字段公式下拉框

$smarty->assign('PRODUCTFIELDHTML',$ProductToolFields->producttoolhtml);

$smarty->assign('TABID',$now_tabid);//选中模块ID
$smarty->assign('detail_issticky',$detail_issticky);//选中模块 分录冻结前几列
$smarty->assign('PRODUCTTOOLFIELDS',$producttoolfieldid);//编辑自定义字段ID
$smarty->assign('LANGUAGETYPE',$languageType);
/* gyq_10 JS保存单据分录时根据此值判断走向 */
$smarty->assign('DETAILFIELDHTMLSEXIST',get_class($ProductToolFields));
}
//require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';

 if($_REQUEST['ajax']&&($_REQUEST['ajax']=='yes'||$_REQUEST['ajax']==true))
{
   $arr['selectsourcetypearr']= $selectmodule_sourcetypearr;
   $arr['detail_issticky']= $detail_issticky;
   $arr['content']= $smarty->fetch('ProductToolField/ListFieldEntries.tpl');
   ConvertTojsonString(1,$arr,"success");
}
else
{
 	$arr['content']= $smarty->fetch('ProductToolField/ListField.tpl');
 	ConvertTojsonString(1,$arr,"success");
}

?>