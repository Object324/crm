<?php
global $current_user,$adb;
$languageType= getLanguageType($current_user);
$smarty = new lingdangCRM_Smarty();

$boardid = 0;
$sql = 'select boardid from ld_homeboard where boardtype = "prmHome";';
$result = $adb->pquery($sql,array());
$boardAllStuffNameStr = '';
if($adb->num_rows($result) > 0){
    $boardid = $adb->query_result($result,0,'boardid');
    //后台设置--经销商渠道定制-网页端界面定制-经销商渠道首页定制需要显示设置的组件 BUG20241231-35
    crm_load_class_file("Homeboard",'modules/Home');
    $Homeboardobj = Homeboard::getInstance($boardid,'Home');
    $Homeboard_content = $Homeboardobj->get_Homeboard_info($boardid);
    $boardAllStuffNameList = $Homeboardobj->getHomeBoardAllStuffNameList();
    $boardAllStuffNameStr = implode('、',$boardAllStuffNameList);
}
$smarty->assign('boardAllStuffNameStr',$boardAllStuffNameStr);
$smarty->assign('boardid',$boardid);

if($languageType=='zh')
{
    $linkmodulefieldlabelcolumn='zh_label';
}
else
{
    $linkmodulefieldlabelcolumn='en_label';
}


$query="select * from (select ld_tab.`name`,ld_tab.tabid,fieldlabel,ld_prmparenttabrel.tab_tablename,ld_prmparenttabrel.sequence  from ld_prmparenttabrel 
inner join ld_tab on ld_tab.tabid=ld_prmparenttabrel.tabid
inner join  ld_tranlabel on ld_tranlabel.relateid=ld_tab.tabid
and ld_prmparenttabrel.tab_tablename='ld_tab'
 where  (languagetype=?  ) and trantable=? 
 and ld_tab.presence in(0,2) and ld_tab.tabid not in(-12,1,7,27,28,30,33,35,44,51,52,61,16)
 union all
 select ld_linkmodulecustom.linkmodule as `name`,ld_linkmodulecustom.id  as tabid,  $linkmodulefieldlabelcolumn as fieldlabel,
 ld_prmparenttabrel.tab_tablename,ld_prmparenttabrel.sequence from ld_prmparenttabrel inner join 
  ld_linkmodulecustom on ld_prmparenttabrel.tabid=ld_linkmodulecustom.id
 and ld_prmparenttabrel.tab_tablename='ld_linkmodulecustom'
  ) as tmp
 
  order by tmp.sequence";

$result=$adb->pquery($query,array($languageType,'ld_tab'));

$num_rows=$adb->num_rows($result);

$regopobj=RegOp::getInstance();
$prmauthenmodule_arr=explode(",",$regopobj->getPrmModules());

$childtabs=array();
for($i=0;$i<$num_rows;$i++){
    $name=$adb->query_result($result,$i,'name');
    if(!empty($name))
    {
        if(!in_array($name,$prmauthenmodule_arr))
            continue;
    }
    $childtabs[]=$adb->query_result($result,$i,'fieldlabel');
}
$smarty->assign('childtabs_str',implode('、', $childtabs));

crm_load_class_file('MenuUtils','modules/Users');
$MenuUtilsObj = new MenuUtils();
$prmlogoname = $MenuUtilsObj->getPRMlogoname();
$smarty->assign('prmlogoname',$prmlogoname);


$arr = [];
if($_REQUEST['ajax'] && $_REQUEST['ajax'] != ''){
    $arr['content']= $smarty->fetch('Settings/prmwebsettings_content.tpl');
}else{
    $arr['content']= $smarty->fetch('Settings/prmwebsettings.tpl');
}


ConvertTojsonString(1,$arr,'success');
?>