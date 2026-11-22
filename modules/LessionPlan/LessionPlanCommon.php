<?php


function getSelectContent($fieldlabel,$id)
{
    global $adb;
    switch($fieldlabel)
    {
        case 'projectid':   //班级
            $table_index = 'projectname';
            $table_name = 'ld_project';
            $sql = "select $fieldlabel,$table_index from $table_name where deleted=0 and approvestatus<>'已拒绝' order by $table_name.$table_index desc";
            break;
        case 'servicecontractsid':  //课程
            $table_index = 'subject';
            $table_name = 'ld_servicecontracts';
            $sql = "select $fieldlabel,$table_index from $table_name where deleted=0 and IFNULL(contract_no,'')<>'已作废' and approvestatus<>'已拒绝' and IFNULL(discontinued,1)<>0 order by $table_name.$table_index desc";
            break;
        case 'projectmilestoneid':  //教师
            $table_index = 'projectmilestonename';
            $table_name = 'ld_projectmilestone';
            $sql = "select $fieldlabel,$table_index from $table_name where deleted=0 order by $table_name.$table_index desc";
            break;
        case 'projecttaskid':  //教室
            $table_index = 'projecttaskname';
            $table_name = 'ld_projecttask';
            $sql = "select $fieldlabel,$table_index from $table_name where deleted=0 and approvestatus<>'已拒绝' order by $table_name.$table_index desc";
            break;
    }
    
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    $option = '';
    for($i = 0; $i<$num_rows; $i++)
    {
        $value = $adb->query_result($result,$i,$fieldlabel);
        $name = $adb->query_result($result,$i,$table_index);
        if($id == $value)
            $option .="<option value='$value' selected>$name</option>";
        else
            $option .="<option value='$value'>$name</option>";
    }
    return $option;
}
?>