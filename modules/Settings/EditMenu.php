<?php
/***************************************************
**更新操作
**edit:kevin
**date:2013-11-12
**reason:编辑菜单
***************************************************/
ob_clean();
global $adb,$theme,$mod_strings,$current_user;
$languageType= getLanguageType($current_user);

if(isset($_REQUEST['parenttabid']) && $_REQUEST['parenttabid'])
$parenttabid=$_REQUEST['parenttabid'];
$smarty=new lingdangCRM_Smarty;

/*
*更新操作
*edit:diony
*time:2013-12-03
*reson:0005828: 控制面板->菜单定制，建议“主模块”和“子模块”的菜单名称都不能重复。
*这里控制主模块不能重复，错误的时候给出错误提示
*/
if(isset($_REQUEST['error']) && $_REQUEST['error']!='')
$Error=getFixedLabel('MENUNAMEERROR');
$smarty->assign('Error',$Error);
if($languageType=='zh')
{
    $linkmodulefieldlabelcolumn='zh_label';
}
else
{
    $linkmodulefieldlabelcolumn='en_label';
}
$query="select * from (select ld_tab.tabid,fieldlabel,ld_parenttabrel.tab_tablename,ld_parenttabrel.sequence  from ld_parenttabrel 
inner join ld_tab on ld_tab.tabid=ld_parenttabrel.tabid
inner join  ld_tranlabel on ld_tranlabel.relateid=ld_tab.tabid
and ld_parenttabrel.tab_tablename='ld_tab'
 where  (languagetype=?  ) and trantable=? and ld_parenttabrel.parenttabid=? 
 and ld_tab.presence in(0,2) and ld_tab.tabid not in(-12,1,7,27,28,30,33,35,44,51,52,61,16)
 union all
 select ld_linkmodulecustom.id  as tabid,  $linkmodulefieldlabelcolumn as fieldlabel,
 ld_parenttabrel.tab_tablename,ld_parenttabrel.sequence from ld_parenttabrel inner join 
  ld_linkmodulecustom on ld_parenttabrel.tabid=ld_linkmodulecustom.id
 and ld_parenttabrel.tab_tablename='ld_linkmodulecustom'
  where  ld_parenttabrel.parenttabid=? ) as tmp
 
  order by tmp.sequence";

 
 $result=$adb->pquery($query,array($languageType,'ld_tab',$parenttabid,$parenttabid)); 
  $num_rows=$adb->num_rows($result);
 $childtabs=array();
 for($i=0;$i<$num_rows;$i++){
    $childtabs[]=array('tabid'=>$adb->query_result($result,$i,'tabid'),
    'tabname'=>$adb->query_result($result,$i,'fieldlabel'),
    'tab_tablename'=>$adb->query_result($result,$i,'tab_tablename')
    );
 }

$sql='select fieldlabel,sequence,visible,allocatetype,allocateid,inactive_icon,active_icon
 from ld_parenttab inner  join ld_tranlabel on ld_parenttab.parenttabid=ld_tranlabel.relateid 
 where (languagetype=? or languagetype=?) and trantable=? and  parenttabid=? order by languagetype  asc';
$presult=$adb->pquery($sql,array('zh','en','ld_parenttab',$parenttabid));
$enparentlabel=$adb->query_result($presult,0,'fieldlabel');

$sequence=$adb->query_result($presult,0,'sequence');
$visible=$adb->query_result($presult,0,'visible');
$zhparentlabel=$adb->query_result($presult,1,'fieldlabel');
$allocatetype = $adb->query_result($presult,1,'allocatetype');
$allocateid = $adb->query_result($presult,1,'allocateid');
$inactive_icon = $adb->query_result($presult,1,'inactive_icon');//zxm2021-1206 菜单图标-未选中
$active_icon = $adb->query_result($presult,1,'active_icon');//zxm2021-1206 菜单图标-选中
//zxm2021-1206 判断图标文件是否存在
if(empty($inactive_icon)||!file_exists(globalStatic::$root_directory.$inactive_icon)){
    $inactive_icon = '';//图标值为空 或者文件不存在 返回空
}
if(empty($active_icon)||!file_exists(globalStatic::$root_directory.$active_icon)){
    $active_icon = '';//图标值为空 或者文件不存在 返回空
    if(!empty($inactive_icon)&&!file_exists($inactive_icon)){
        $active_icon = $inactive_icon;//如果选中图标不存在 未选中图标存在 则使用未选中图标
    }
}
//图标文件名
$inactive_icon_arr=explode('/',$inactive_icon);
$inactive_icon_name = $inactive_icon_arr[sizeof($inactive_icon_arr)-1];
$active_icon_arr=explode('/',$active_icon);
$active_icon_name = $inactive_icon_arr[sizeof($active_icon_arr)-1];


if(empty($zhparentlabel))
{
    $zhparentlabel=$enparentlabel;
}
if(empty($allocatetype))$allocatetype = 'all';
$smarty->assign('ALLOCATETYPE',$allocatetype);
$smarty->assign('ALLOCATEID',$allocateid);
$smarty->assign('ENPARENTTABLELABEL',$enparentlabel);
$smarty->assign('ZHPARENTTABLABEL',$zhparentlabel);
$smarty->assign('PARENTTABID',$parenttabid);
if($languageType=='en')
{
	$parenttablelabel = $enparentlabel;
}
else
{
	$parenttablelabel = $zhparentlabel;
}
$smarty->assign('PARENTTABLELABEL',$parenttablelabel);
$smarty->assign('SEQUENCE',$sequence);
$inactive_icon = empty($inactive_icon)?'':$inactive_icon.'?a='.rand(0,999);
$active_icon = empty($active_icon)?'':$active_icon.'?a='.rand(0,999);
$smarty->assign('inactive_icon',$inactive_icon);//zxm2021-1206 菜单图标-未选中
$smarty->assign('active_icon',$active_icon);//zxm2021-1206 菜单图标-选中
$smarty->assign('inactive_icon_name',$inactive_icon_name);//zxm2021-1206 菜单图标名称-选中
$smarty->assign('active_icon_name',$active_icon_name);//zxm2021-1206 菜单图标名称-选中

$smarty->assign('visible',$visible=($visible==1)?1:'');
$smarty->assign('CHILDTABS',$childtabs);

$query="select ld_tab.tabid,ld_tranlabel.fieldlabel,'ld_tab' as tab_tablename,tabsequence from ld_tab 
    inner join ld_tranlabel on ld_tranlabel.tabid=ld_tab.tabid 
    where ld_tranlabel.languagetype = '$languageType' 
    and ld_tranlabel.trantable = 'ld_tab' and ld_tab.presence=0 and 
    ld_tab.tabid not in(-12,1,7,27,28,30,33,35,44,51,52,61,16)
    union all select id as tabid,$linkmodulefieldlabelcolumn as fieldlabel,'ld_linkmodulecustom' as tab_tablename,(id+50000) as tabsequence 
    from ld_linkmodulecustom 
     ";

//and ld_tab.tablabel not in ('Often_UseReport')
$result=$adb->query("select * from ($query) as tmp order by tabsequence");

//echo $query;
$num_rows=$adb->num_rows($result);

$alltabs=array();
for($i=0;$i<$num_rows;$i++){
    $tabid=$adb->query_result($result,$i,'tabid');
    $tab_tablename=$adb->query_result($result,$i,'tab_tablename');
    $iscontinue='no';
   
    foreach($childtabs as $tmpchildtabinfo)
    {
        if($tmpchildtabinfo['tabid']==$tabid&&$tab_tablename==$tmpchildtabinfo['tab_tablename'])
        {
            $iscontinue='yes';
            break;
        }
    }
    if($iscontinue=='yes')
    {
        continue;
    }
    $alltabs[]=array('tabid'=>$adb->query_result($result,$i,'tabid'),
    'tabname'=>$adb->query_result($result,$i,'fieldlabel'),
    'tab_tablename'=>$tab_tablename
    );
}


$sql_sequence="select max(sequence)+1 as sequences  from ld_parenttab";
$result_sequence=$adb->query($sql_sequence);
$sequences=$adb->query_result($result_sequence,0,'sequences');
$smarty->assign('ADDSEQUENCES',$sequences);
/**
 *@edit:andy 
 *@date:
 *@reason:左右选择改进
 *@version:

if(getInvisibleProfileid($parenttabid)){
   $smarty->assign('Invisiblerole',getAllProfileid($parenttabid,2));
}
$smarty->assign('ALLROLDS',getAllProfileid($parenttabid,1));
 */


$smarty->assign('ALLTABS',$alltabs);
$smarty->assign('THEME',$theme);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('APP',$app_strings);

 $_REQUEST['diony']='diony';
 //BUG0068072 txy 2023.06.08 【界面优化】后台设置---网页端菜单定制--新建/编辑--弹窗标题，新建弹窗标题去除括号以及括号内内容
 if(!empty($parenttabid)){
     $arr['title'] = getFixedLabel('EDIT');
 }else{
	$arr['title'] = getFixedLabel('LBL_TABLIST');
 }
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Menu/EditMenu.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");


exit();

?>