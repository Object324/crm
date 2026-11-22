<?php

//反写字段公式
$reversefieldtype=$_REQUEST['reversefieldtype'];
$reversefieldid=$_REQUEST['reversefieldid'];

$reversetable=$_REQUEST['reversetable'];
$reverseparentid=$_REQUEST['reverseparentid'];
$module=$_REQUEST['frommodule'];
$tabid=getTabid($module);
$formulastring=$_REQUEST['formulastring'];
$columnstring=$_REQUEST['columnstring'];

$arr_columnstring=json_decode($columnstring,true);

$tmparr['formulavar']=$arr_columnstring;
$arrstr=json_encode($tmparr);
$tmpstr=str_replace('"formulavar"',"formulavar",$arrstr);
$columnstr=str_replace('"',"'",$tmpstr);
if(!empty($reversefieldtype))
{
    $sql='update ld_reverseformula set activatestatus=? where reversetabid=? and reversetable=? and
       reversefieldtype=? ';
    $adb->pquery($sql,array("yes",$tabid,$reversetable,$reversefieldtype));
    
    $sql='update ld_reverseformula set activatestatus=? where reversetabid=? and reversetable=? and
       ifnull(reversefieldtype,"")<>? ';
    $adb->pquery($sql,array("no",$tabid,$reversetable,$reversefieldtype));
}
$params=array();
$sql='select 1 from ld_reverseformula where relateid=? and parentid=? and reversetable=? ';
$params[]=$reversefieldid;
$params[]=$reverseparentid;
$params[]=$reversetable;
if(!empty($reversefieldtype))
{
    $sql.=" and  reversefieldtype=?";
    $params[]=$reversefieldtype;
}
$result=$adb->pquery($sql,$params);
$params=array();

if($adb->num_rows($result)>0)
{
    //更新反写公式
    $sql='update ld_reverseformula set columnstring=? ,formulastring=? where relateid=? and parentid=? and reversetable=? ';
    $params[]=$columnstr;
    $params[]=$formulastring;
    
    $params[]=$reversefieldid;
    $params[]=$reverseparentid;
    $params[]=$reversetable;
    if(!empty($reversefieldtype))
    {
        $sql.=" and  reversefieldtype=?";
        $params[]=$reversefieldtype;
    }
    $adb->pquery($sql,$params);
    
   
}
else
{
    $params=array();
    //新增反写公式
    $sql='insert into ld_reverseformula(columnstring,formulastring,relateid,reversetabid,reversetable,parentid,reversefieldtype)
            value(?,?,?,?,?,?,?)';
    $params[]=$columnstr;
    $params[]=$formulastring;
    $params[]=$reversefieldid;
    $params[]=$tabid;
    $params[]=$reversetable;
    $params[]=$reverseparentid;
    
    $params[]=$reversefieldtype;
 
    $adb->pquery($sql,$params);
    
      /* echo '<pre>';
    print_r($params);
    echo '</pre>';
    exit();*/
}
unsetCacheDirectory('productfields');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

?>