<?php
global $current_user;
global $adb;
require_once(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
if($_REQUEST['getlistajax']=='yes')
{
    //反写公式保存后调用
    $reverseparentid=$_REQUEST['reverseparentid'];
    $module=$_REQUEST['frommodule'];
    $tabid=getTabid($module);
    require('include/ProductToolFields/cls_AutoLoadDetailFields.php');
    
        $autoLoadInstance = new INSTANCE();
      $producttoolfields = $autoLoadInstance->autoLoad($tabid,'Field');
}
//获取价税合计反写的字段
$tmpsql='select ld_producttoolfield.producttoolfieldid,ld_producttoolfield.columnname,ld_reverseformula.columnstring,
                ld_reverseformula.formulastring,ld_reverseformula.reversefieldtype,ld_tranlabel.fieldlabel from ld_reverseformula
                    inner join ld_producttoolfield 
                        on ld_producttoolfield.producttoolfieldid=ld_reverseformula.relateid
                        inner join ld_tranlabel  on ld_tranlabel.relateid=ld_reverseformula.relateid
                 where ld_reverseformula.reversetabid=? and reversetable=? and ld_reverseformula.parentid=? 
                 and ld_tranlabel.trantable=? and ld_tranlabel.tabid=? and ld_tranlabel.languagetype=?
                 and ld_reverseformula.activatestatus="yes" and ld_producttoolfield.presence in(0,2) order by ld_reverseformula.id asc ';
        
$tmpresult=$adb->pquery($tmpsql,array($tabid,'ld_producttoolfield',$reverseparentid,'ld_producttoolfield',$tabid,$languageType));
$tmprows=$adb->num_rows($tmpresult);
$reverse_arr=array();
for($tmpi=0;$tmpi<$tmprows;$tmpi++)
{
             $formulastring=$adb->query_result($tmpresult,$tmpi,'formulastring');
             $columnstring=$adb->query_result($tmpresult,$tmpi,'columnstring');
             $columnstringlabel=$columnstring;
             $producttoolfieldid=$adb->query_result($tmpresult,$tmpi,'producttoolfieldid');
             $columnname=$adb->query_result($tmpresult,$tmpi,'columnname');
             $fieldlabel=$adb->query_result($tmpresult,$tmpi,'fieldlabel');
             $arr_columnstring=json_decode($columnstring,true);
             $smarty->assign('reversefieldtype',$adb->query_result($tmpresult,$tmpi,'reversefieldtype'));
             foreach($arr_columnstring['formulavar'] as $index=>$formulainfo)
             {
                 $lettervar=$formulainfo['lettervar'];
                 $formulacolumn=$formulainfo['column'];
                 $formulafieldlabel=$producttoolfields->getFieldInfoBykeyValue("columnname",$formulacolumn,"fieldlabel");
                 $columnstringlabel=str_replace($lettervar,$formulafieldlabel,$columnstringlabel);
             }
             $reverse_arr[]=array('reversefieldlabel'=>$fieldlabel,'reversefieldid'=>$producttoolfieldid,'formulastring'=>$formulastring,'columnstring'=>$columnstring,'columnstringlabel'=>$columnstringlabel);
}
if($_REQUEST['getlistajax']=='yes')
{
     $smarty=new lingdangCRM_Smarty();
     $smarty->assign("reverseparentid",$reverseparentid);
     $smarty->assign("MODULE",$module);
     $smarty->assign("ReverseArr",$reverse_arr);
     $_REQUEST['diony']='yes';
     $arr['content']=$smarty->fetch("ReverseFormulaList.tpl");
     ConvertTojsonString(1,$arr,'success');
     
}
?>