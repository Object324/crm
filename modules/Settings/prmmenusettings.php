<?php
global $current_user,$adb;
$languageType= getLanguageType($current_user);
$smarty = new lingdangCRM_Smarty();

if($languageType=='zh')
{
    $linkmodulefieldlabelcolumn='zh_label';
}
else
{
    $linkmodulefieldlabelcolumn='en_label';
}


$query="select * from (select ld_tab.name, ld_tab.tabid,fieldlabel,ld_prmparenttabrel.tab_tablename,ld_prmparenttabrel.sequence  from ld_prmparenttabrel 
inner join ld_tab on ld_tab.tabid=ld_prmparenttabrel.tabid
inner join  ld_tranlabel on ld_tranlabel.relateid=ld_tab.tabid
and ld_prmparenttabrel.tab_tablename='ld_tab'
 where  (languagetype=?  ) and trantable=? 
 and ld_tab.presence in(0,2) and ld_tab.tabid not in(-12,1,7,27,28,30,33,35,44,51,52,61,16)
 union all
 select ld_linkmodulecustom.linkmodule,ld_linkmodulecustom.id  as tabid,  $linkmodulefieldlabelcolumn as fieldlabel,
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
    $childtabs[]=array(
        'name'=>$adb->query_result($result,$i,'name'),
        'tabid'=>$adb->query_result($result,$i,'tabid'),
        'tabname'=>$adb->query_result($result,$i,'fieldlabel'),
        'tab_tablename'=>$adb->query_result($result,$i,'tab_tablename')
    );
}


$query="select ld_tab.name , ld_tab.tabid,ld_tranlabel.fieldlabel,'ld_tab' as tab_tablename,tabsequence from ld_tab 
    inner join ld_tranlabel on ld_tranlabel.tabid=ld_tab.tabid 
    where ld_tranlabel.languagetype = '$languageType' 
    and ld_tranlabel.trantable = 'ld_tab' and ld_tab.presence=0 and 
    ld_tab.tabid not in(-12,1,7,27,28,30,33,35,44,51,52,61,16)
    union all select linkmodule, id as tabid,$linkmodulefieldlabelcolumn as fieldlabel,'ld_linkmodulecustom' as tab_tablename,(id+50000) as tabsequence 
    from ld_linkmodulecustom 
     ";


$result=$adb->query("select * from ($query) as tmp order by tabsequence");

//echo $query;
$num_rows=$adb->num_rows($result);


$alltabs=array();
for($i=0;$i<$num_rows;$i++){
    $tabid=$adb->query_result($result,$i,'tabid');
    $tab_tablename=$adb->query_result($result,$i,'tab_tablename');
    $iscontinue='no';
    $name=$adb->query_result($result,$i,'name');
    foreach($childtabs as $tmpchildtabinfo)
    {
        if($tmpchildtabinfo['tabid']==$tabid&&$tab_tablename==$tmpchildtabinfo['tab_tablename'])
        {
            $iscontinue='yes';
            break;
        }
    }




   if($tab_tablename=='ld_tab')
   {
       if(!in_array($name,$prmauthenmodule_arr))
       {
           continue;
       }
   }
   else if($tab_tablename=='ld_linkmodulecustom'&&$name!='')
   {
       if($name=='CustomEcharts'||$name=='CustomTables'||$name=='Customreport'||$name=='OftenUseReport')
           $name='ReportAnalysis';

       if(!in_array($name,$prmauthenmodule_arr))
       {
           continue;
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

$smarty->assign('ALLTABS',$alltabs);
$smarty->assign('CHILDTABS',$childtabs);

$arr = [];
$arr['content']= $smarty->fetch('Menu/prmEditMenu.tpl');
$arr['title']=getFixedLabel("menu_settings");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");


ConvertTojsonString(1,$arr,'success');
?>