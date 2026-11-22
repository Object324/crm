<?php
global $adb;
if(isset($_REQUEST['tabid_fieldlabel']) && isset($_REQUEST['allids']))
{
    $contact_fieldlabel = $_REQUEST['tabid_fieldlabel'];
    $contactid = $_REQUEST['allids'];
}

$contact_fieldlabel = explode("_",$contact_fieldlabel);


$num = sizeof($contact_fieldlabel);
$fieldlabel_info = "";


for($i=1;$i<$num;$i++)
{
    $fieldlabel_info.="'".$contact_fieldlabel[$i]."',";
    $i++;
}
$fieldlabel_info = substr($fieldlabel_info,0,strlen($fieldlabel_info)-1); 

//根据传的值知道是什么字段和表
$sql = "select tablename,columnname from ld_field where tabid = 4 and fieldlabel in (".$fieldlabel_info.")";
$result = $adb->pquery($sql,array());
$num = $adb->num_rows($result);
$info = array();
if($num)
{
        for($i=0;$i<$num;$i++)
        {
            $info[]=array(
            'tablename'=> $adb->query_result($result,$i,'tablename'),
            'columnname'=> $adb->query_result($result,$i,'columnname')
            ); 
        }
}
$value_all ="";
$allinfo= "";
//根据字段和表查询

for($i=0;$i<$num;$i++)
{
    $columnname=$info[$i]['columnname'];
    $tablename=$info[$i]['tablename'];
    if($info[$i][tablename] != 'ld_contactdetails')
    {
        $sql_value = "select ".$tablename.".".$columnname.",ld_contactdetails.lastname from ".$tablename." inner join ld_contactdetails on ld_contactdetails.contactid = ".$tablename.".contactid where ld_contactdetails.contactid in(".$contactid.") ";
        $result_value = $adb->pquery($sql_value,array());
        $num_rows = $adb->num_rows($result_value);
        $info_select_detial = array();
        $infomation = "";
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_value,$j,'lastname'),
                '1'=>$adb->query_result($result_value,$j,"$columnname")
                );
    
                if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$info_select_detial[$j][1])!=0)
                {
                    $infomation .= $info_select_detial[$j][1]."<".$info_select_detial[$j][0].">";     
                }  
            }       
        }
    }
    else
    {
        $sql_value = "select ".$tablename.".".$columnname.",ld_contactdetails.lastname from ".$tablename." where contactid in(".$contactid.") ";
        $result_value = $adb->pquery($sql_value,array());
        $num_rows = $adb->num_rows($result_value);
        $info_select_detial = array();
        $infomation2 = "";
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_value,$j,'lastname'),
                '1'=>$adb->query_result($result_value,$j,"$columnname")
                );
    
                if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$info_select_detial[$j][1])!=0)
                {
                    $infomation2 .= $info_select_detial[$j][1]."<".$info_select_detial[$j][0].">";     
                }
            }       
        }
    }
}
$allinfo .= $infomation;
$allinfo .= $infomation2;

echo "#####SUCCESS#####".$allinfo."#####SUCCESS#####";

?>