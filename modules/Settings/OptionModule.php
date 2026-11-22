<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project 源单类型定制
 * @author xiaoshun 2016-07-29
 */
global $adb,$theme,$mod_strings,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
  global $current_user;
 global $current_user;


$smarty = new lingdangCRM_Smarty;
 
$tabs[] = array(
		'tabid' => getTabid('Singin'),
		'name'  => getTranstab('Singin')
	);
// @edit:dong @date:2020/08/13 @reason: bug 0042402
$list_header = array(getFixedLabel('SEQUENCE'),getFixedLabel('CNTAG'),getFixedLabel('ENTAG'),getFixedLabel('OUTSIDESIGN').getFixedLabel('ACTIVATE'),getFixedLabel('OUTSIDESIGN').getFixedLabel('Set_Default'),getFixedLabel('Ifitexceedstheerrorrange'));

$smarty->assign('TABS',$tabs);
$smarty->assign('TABID',getTabid('Singin'));
$smarty->assign('LIST_HEADER',$list_header);

if(isset($_REQUEST['selectTabid']) && $_REQUEST['selectTabid']>0){
    $tabid = $_REQUEST['selectTabid'];
}else{
    $tabid = $tabs[0]['tabid'];
}

$smarty->assign('TABID',$tabid);

$list_query = 'select op.*,tr.fieldlabel,tr.languagetype
                from ld_option_module as op
                left join ld_tranlabel as tr on op.option_tabid = tr.tabid and trantable = ?
				left join ld_tab on ld_tab.tabid = op.option_tabid
                where op.tabid=? and ld_tab.presence <> 1 order by sequence';

$list_result = $adb->pquery($list_query,array('ld_tab',$tabid));

$num_rows =  $adb->num_rows($list_result);

if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $languagetype = $adb->query_result($list_result,$i,'languagetype');
        $option_tabid = $adb->query_result($list_result,$i,'option_tabid');
		$option_module = getTabModuleName($option_tabid);
		$focus = CRMEntity::getInstance($option_module);
        $alltabs[$option_tabid]['id'] = $adb->query_result($list_result,$i,'id');
        $alltabs[$option_tabid]['label'][$languagetype] = $adb->query_result($list_result,$i,'fieldlabel');
        $alltabs[$option_tabid]['presence'] = $adb->query_result($list_result,$i,'presence');
        $alltabs[$option_tabid]['isdefault'] = $adb->query_result($list_result,$i,'default');
        $alltabs[$option_tabid]['approve_demand'] = $adb->query_result($list_result,$i,'approve_demand');
        $alltabs[$option_tabid]['datarang'] = $adb->query_result($list_result,$i,'datarang');
        $alltabs[$option_tabid]['maxrowsshow'] = $adb->query_result($list_result,$i,'maxrowsshow');
        $alltabs[$option_tabid]['required'] = $adb->query_result($list_result,$i,'required');
        $alltabs[$option_tabid]['automaticallysign'] = $adb->query_result($list_result,$i,'automaticallysign');
        // @edit:dong @date:2020/08/13 @reason: tapd ID1001007 签到源单类型定制功能优化
        $alltabs[$option_tabid]['enablewhenadding'] = $adb->query_result($list_result,$i,'enablewhenadding');
		$alltabs[$option_tabid]['approve_status'] = getFixedLabel('Approved');
        $alltabs[$option_tabid]['uploadwatermark'] = $adb->query_result($list_result,$i,'uploadwatermark');
        $alltabs[$option_tabid]['no_signin'] = $adb->query_result($list_result,$i,'no_signin');
        $alltabs[$option_tabid]['allowable_distance'] = $adb->query_result($list_result,$i,'allowable_distance');
        $alltabs[$option_tabid]['nosignout_cantsignin'] = $adb->query_result($list_result,$i,'nosignout_cantsignin');
        $alltabs[$option_tabid]['allowsupsignout'] = $adb->query_result($list_result,$i,'allowsupsignout');
    }

}

// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('LIST_ENTRIES',($alltabs));
setGLobalURLSmarty($smarty);//js,css加载的url
if(!empty($_REQUEST['Ajax']) && $_REQUEST['Ajax'] == 'yes'){
    $smarty->display('OptionModuleEntries.tpl'); 
}else{
    $arr['content']= $smarty->fetch('OptionModule.tpl');
    ConvertTojsonString(1,$arr,"success");
}

?>