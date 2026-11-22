<?php
global $adb;
$module=$_REQUEST['frommodule'];
$tabid=getTabid($module);

$headlables=array('#',getFixedLabel('RULENAME'),getFixedLabel("TriggerField"),getFixedLabel("STATUS"),getFixedLabel('OPERATING'));
// $table='<div class="ControlDiv2">
//             <div  class="F_r"><input class="createauto" name="btn_add" type="button" name="New" value="'.getFixedLabel("NEW").'">
//             </div>
//         </div>';
$table.='<div class="mar-1">';
$table.="<table class='ControlTable1 listEntries fir-center listSettingData' cellspacing='1' cellpadding='0' border='0' width='100%'>";
$table.='<tr>';
foreach($headlables as $label)
{
    $table.='<th>'.$label."</th>";
}
$table.='</tr>';
$sql='select * from ld_fieldrule where tabid=?  order by id desc';
$result=$adb->pquery($sql,array($tabid));
$rows=$adb->num_rows($result);
$focus=CRMEntity::getInstance($module);

$j=0;
for($i=0;$i<$rows;$i++) {
    $name=$adb->query_result($result,$i,'rulename');
    $columname=$adb->query_result($result,$i,'columnname');
    $fieldLabel=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$columname,'fieldlabel');
    $enablestatus=$adb->query_result($result,$i,'enablestatus');
    $id=$adb->query_result($result,$i,'id');
    if($fieldLabel!='')
    {
        if ($j%2 ==0) {
            $table.='<tr id="setting_'.$j.'" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
        }
        else{
            $table.='<tr id="setting_'.$j.'" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
        }
        $table.='<td>'.($j+1)."</td>";
        //231107 wyn BUG0075078 页面设置-布局规则/验证规则，内容过长时显示不完全，增加浮显
        $table.='<td > <span class="tip-items-lists" data-tip="'.$name.'" data-type="position" data-direction="top">'.$name.'</span> </td>';
        $table.='<td>'.$fieldLabel."</td>";
        $checked = ($enablestatus=='yes')?'checked':'';
        $table.='<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'fieldrule\')" class="second_switch" '.$checked.'>'.'</td>';
        $table.='<td><a class="Anu3_a" href="javascript:void(0);" name="btn_edit" record="'.$id.'">'.getFixedLabel('EDIT').'</a>';
        $table.='<a class="Anu3_a redFont" href="javascript:void(0);" name="btn_delete" record="'.$id.'">'.getFixedLabel('DELETE').'</a>';

        $table.=' </td>';
        $table.='</tr>';
        $j++;
    }

}
$table.='</table>';
$table.='</div>';
$_REQUEST['diony']='yes';
$arr['content']=$table;
ConvertTojsonString(1,$arr,'success');
?>