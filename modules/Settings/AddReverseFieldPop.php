<?php

require('include/ProductToolFields/cls_AutoLoadDetailFields.php');
global $adb,$current_user;


$autoLoadInstance = new INSTANCE();
$languageType= getLanguageType($current_user);
$module=$_REQUEST['frommodule'];
$focus=CRMEntity::getInstance($module);
$tabid=getTabid($module);
$reverseparentid=$_REQUEST['reverseparentid'];
$producttoolobj= $autoLoadInstance->autoLoad($tabid,'Field');
$formulcolumnlistinfo=$producttoolobj->getFieldFormulaList($tabid);
$reversefieldtype=$_REQUEST['reversefieldtype'];
$reversetable=$_REQUEST['reversetable'];
$params[]=$tabid;
$params[]=$reversetable;

$sql='select GROUP_CONCAT(relateid) from ld_reverseformula where reversetabid=? and reversetable=? ';
if(!empty($reversefieldtype))
{
    $sql.=' and reversefieldtype=?';
    $params[]=$reversefieldtype;
}
$result=$adb->pquery($sql,$params);
$haverelateids=array();
if($adb->num_rows($result)>0)
    $haverelateids=explode(',',$adb->query_result($result,0,0));
    
$formulahtml.="<div>";
    $formulahtml.="<table border='0' cellpadding='20' cellspacing='1'>";
    
    $formulahtml.="<tr>";
    $formulahtml.='<td>'.getFixedLabel('Calculatedfields').'</td>';
    $formulahtml.="<td>";
            $formulahtml.="<select name='reversefield'>";
            for($k=0;$k<sizeof($formulcolumnlistinfo);$k++)
            {
                           $tmpfieldinfo=$formulcolumnlistinfo[$k];
                        
                           if($tmpfieldinfo->getProductToolFieldid()==$reverseparentid)
                           {
                                continue;
                           }
                           if(in_array($tmpfieldinfo->getProductToolFieldid(),$haverelateids))
                           {
                            //38172: 单据分录定制->编辑价税合计->反算字段->新增，新增可选字段没有控制
                            continue;
                           }
                           if($_REQUEST['reversefieldtype']=='discount')
                           {
                                if($tmpfieldinfo->getUIType()==15||$tmpfieldinfo->getUIType()==37)
                                {
                                    
                                }
                               else if($tmpfieldinfo->getTableName()!=$focus->Detail_table_scf)
                               {
                                continue;
                               }
                           }
                           else
                            {
                                 if($tmpfieldinfo->getUIType()==15||$tmpfieldinfo->getUIType()==37
                                    ||$tmpfieldinfo->getUIType()==163||$tmpfieldinfo->getColumnName()=='tax_total'
                                    ||$tmpfieldinfo->getColumnName()=='list_amount')
                                {
                                    
                                }
                                
                                else if($tmpfieldinfo->getTableName()!=$focus->Detail_table_scf)
                               {
                                continue;
                               }
                            }
                            $productcolumn=$tmpfieldinfo->getColumnName();
                            $fieldlabel=$tmpfieldinfo->getFieldLabel();
                            $producttoolfieldid=$tmpfieldinfo->getProductToolFieldid();
                            if($productcolumn==$columnname)
                            {
                               $formulahtml.= " <option value='".$producttoolfieldid."' selected>".$fieldlabel."</option> ";
                            }
                            else
                            {
                                $formulahtml.= " <option value='".$producttoolfieldid."'>".$fieldlabel."</option> ";
                            }
                            
            }
            $formulahtml.='</select>';
    
    $formulahtml.="</td>";
    $formulahtml.="<tr>";
    $formulahtml.="</table>";
$formulahtml.="</div>";

$_REQUEST['diony']='yes';
$arr['content']=$formulahtml;
$arr['title']=getFixedLabel("NEW");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,'success');
?>