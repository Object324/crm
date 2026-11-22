<?php
global $adb,$current_user;
$tabid_fieldlabel = '';
if(isset($_REQUEST['accountid']) && isset($_REQUEST['tabid_fieldlabel']))
{
    $accountid = substr($_REQUEST['accountid'],0,strlen($_REQUEST['accountid'])-1); 

    $tabid_fieldlabel = $_REQUEST['tabid_fieldlabel'];
}
$array_fieldlabel = explode(",",$tabid_fieldlabel);
if($array_fieldlabel[sizeof($array_fieldlabel)]=="")
{
    array_pop($array_fieldlabel);
}

$array_tabid = "";
$array_fieldlabel_name = "";
$num = count($array_fieldlabel);

for($i=0;$i<$num;$i++)
{
     $tabid_fieldlabels=explode('_',$array_fieldlabel[$i]);
     
     $array_tabid .= $tabid_fieldlabels[0].",";
    $array_fieldlabel_name .= "'".$tabid_fieldlabels[1]."',";
   
}

$array_tabid = substr($array_tabid,0,strlen($array_tabid)-1);
$array_fieldlabel_name = substr($array_fieldlabel_name,0,strlen($array_fieldlabel_name)-1);
require('user_privileges/user_language_'.$current_user->id.'.php');
$num_rows = 0;
if(!empty($array_tabid) && !empty($array_fieldlabel_name)){
    $sql = "select tablename,columnname,fieldid from ld_field inner join ld_tranlabel
    on ld_tranlabel.relateid=ld_field.fieldid  where ld_tranlabel.languagetype=? and ld_field.tabid in (".$array_tabid.")
    and ld_tranlabel.fieldlabel in (".$array_fieldlabel_name.")";

    $result = $adb->pquery($sql,array($languageType));
    $num_rows = $adb->num_rows($result);
}
$info_select = array();
$selected_fieldid = array();
if($num_rows > 0)
{
    for($i=0;$i<$num_rows;$i++)
    {
        $tablename = $adb->query_result($result,$i,'tablename');
        $columnname = $adb->query_result($result,$i,'columnname');
        $info_select[] = array(
            'tablename'=>$tablename,
            'columnname'=>$columnname
        ); 
        $selected_fieldid[]= $adb->query_result($result,$i,'fieldid');
    }  
}
//将选中的邮件字段存到session里面，再次打开的时候获取
$viewid = $_REQUEST['viewid'];
$list_query = '';
if($viewid>0){
    $_SESSION['email_field'][$viewid]['selected_fieldid'] =$selected_fieldid ;
    $queryGenerator = QueryGenerator::getInstance('Accounts', $current_user);
    $queryGenerator->initForCustomViewById($viewid);
    $list_query = $queryGenerator->getQuery();//分组查询条件
}else{
    unset($_SESSION['email_field']);
}

$num_info_select = sizeof($info_select);

$infoall = "";
$info = "";
$info2 = "";
$info4 = "";
$info3 = "";

for($i=0;$i<$num_info_select;$i++)
{
    $columnname=$info_select[$i]['columnname'];
    $tablename=$info_select[$i]['tablename'];
 
    if($tablename=='ld_accountscf')
    {
        $sql_info_select = "select ld_account.accountname,".$tablename.".".$columnname." from ".$tablename." left join ld_account on ld_account.accountid = ".$tablename.".accountid ";
        if(!empty($accountid))
            $sql_info_select .=" where $tablename.accountid in ( $accountid ) and ";
        else
            $sql_info_select.=" where ld_account.deleted=0 and ";
        $sql_info_select.=$tablename.".".$columnname."<> ''";
        if(!empty($list_query)){
            $sql_info_select.= " and $tablename.accountid in ( $list_query ) ";
        }
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        //print_r($sql_info_select);
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'accountname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $infoall = $info_select_detial[$j];
                $info .= $infoall['1']."<".$infoall['0'].">\r";     
                
            } 
        }
        
    }
    elseif($tablename=='ld_contactdetails')
    {
        $sql_info_select = "select ld_contactdetails.lastname,ld_contactdetails.$columnname from  $tablename  inner join ld_account on ld_account.accountid = ld_contactdetails.accountid  and ld_contactdetails.deleted=0 ";
        if(!empty($accountid))
            $sql_info_select.=" where ld_contactdetails.accountid in( $accountid ) and ";
        else
            $sql_info_select.=" where ld_account.deleted=0 and ";    
        $sql_info_select.=" ld_contactdetails.".$columnname."<> ''";
        if(!empty($list_query)){
            $sql_info_select.= " and ld_contactdetails.accountid in ( $list_query ) ";
        }
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $infoall = $info_select_detial[$j];

                    $info2 .= $infoall['1']."<".$infoall['0'].">\r";     
                
            } 
        }
    }
    elseif($tablename=='ld_account')
    {
        $sql_info_select = "select accountname,$columnname  from  $tablename ";
        if(!empty($accountid))
            $sql_info_select.=" where accountid in( $accountid ) and ";
        else
            $sql_info_select.=" where deleted=0 and ";
        $sql_info_select.= $columnname."<> ''";
        if(!empty($list_query)){
            $sql_info_select.= " and accountid in ( $list_query ) ";
        }
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        //print_r($sql_info_select);
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'accountname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $infoall = $info_select_detial[$j];

                    $info4 .= $infoall['1']."<".$infoall['0'].">\r";     
                
            } 
        }
    }  
    else
    {
        $sql_info_select = "select ld_contactdetails.lastname, $tablename.$columnname  from $tablename  inner join ld_contactdetails on  $tablename.contactid = ld_contactdetails.contactid inner join ld_account on ld_account.accountid = ld_contactdetails.accountid  and ld_contactdetails.deleted=0 ";
        
         if(!empty($accountid))
         
                $sql_info_select.= " where ld_contactdetails.accountid in ($accountid) and ";
         else
                $sql_info_select.=' ld_account.deleted=0 and ';
         $sql_info_select.=$tablename.".".$columnname ."<> ''";
        if(!empty($list_query)){
            $sql_info_select.= " and ld_contactdetails.accountid in ( $list_query ) ";
        }
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        //print_r($sql_info_select);
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $infoall = $info_select_detial[$j];

                    $info3 .= $infoall['1']."<".$infoall['0'].">\r";     
                
            } 
        }
    } 
 
}
$info_all.=$info;
$info_all.=$info2;
$info_all.=$info3;
$info_all.=$info4;

echo "#####SUCCESS#####".$info_all."#####SUCCESS#####";

?>