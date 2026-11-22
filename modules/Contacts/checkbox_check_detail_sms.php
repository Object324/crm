<?php
global $adb;
if(isset($_REQUEST['tabid_fieldlabel']))
{
    $contact_fieldlabel = $_REQUEST['tabid_fieldlabel'];

}

if(isset($_REQUEST['allids']))
{
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
$sql = "select tablename,columnname from ld_field where tabid = 4 and fieldlabel in (".$fieldlabel_info.") and presence<>1";
$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);
$info = array();
if($num_rows)
{
        for($i=0;$i<$num_rows;$i++)
        {
            $info[]=array(
            'tablename'=> $adb->query_result($result,$i,'tablename'),
            'columnname'=> $adb->query_result($result,$i,'columnname')
            ); 
        }
}
$value_all ="";

//根据字段和表查询
$num_rows_info = count($info);


for($i=0;$i<$num_rows_info;$i++)
{      
    $infodetail=$info[$i];
    $tablename = $infodetail['tablename'];
    $columnname = $infodetail['columnname'];
    if($infodetail['tablename'] != 'ld_contactdetails')
    {
        $sql_value = "select ".$infodetail['tablename'].".".$infodetail['columnname'].",ld_contactdetails.lastname from ".$infodetail['tablename']." inner join ld_contactdetails on ld_contactdetails.contactid = ".
                    $infodetail['tablename'].".contactid where ld_contactdetails.contactid in(".$contactid.") ";
        $result_info_select = $adb->pquery($sql_value,array());
        $num_rows_infomation = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        $info1 = "";
        if($num_rows_infomation)
        {
            for($j=0;$j<$num_rows_infomation;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$infodetail['columnname'])
                );
                $infoall = $info_select_detial[$j];
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1']))
                {
                    $info1 .= $infoall['1']."<".$infoall['0'].">;";     
                }  
            }        
        }
    }
    else
    {
        $sql_value = "select ".$infodetail['tablename'].".".$infodetail['columnname'].",ld_contactdetails.lastname from ".$infodetail['tablename']." where contactid in(".$contactid.") ";
        $result_info_select = $adb->pquery($sql_value,array());
        $num_rows_infomation = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        $info2 = "";
        if($num_rows_infomation)
        {
            for($j=0;$j<$num_rows_infomation;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$infodetail['columnname'])
                );
                $infoall = $info_select_detial[$j];
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1']))
                {
                    $info2 .= $infoall['1']."<".$infoall['0'].">;";     
                }  
            }        
        }
    }
      
}
//print_r($info);
//exit();
$value_all.= $info1;
$value_all.= $info2;

echo "#####SUCCESS#####".$value_all."#####SUCCESS#####";
?>