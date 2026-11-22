<?php
global $adb, $current_user, $currentModule,$mod_strings;
require_once('Smarty_setup.php');
$smarty=new lingdangCRM_Smarty;

$sql = "";
$wheresql = "";
$result_search = "";
if(isset($_REQUEST['search_txt']) && $_REQUEST['search_txt']!= "" && $_REQUEST['search_field']!= "")
{
    $search_txt = $_REQUEST['search_txt'];
    if($_REQUEST['search_field'] == 1)
    { 
        $wheresql .= "where user_name = '".$search_txt."'";
    }
    elseif($_REQUEST['search_field'] == 2)
    {
        
        $wheresql .= "where last_name = '".$search_txt."'";
    }
    else
    {
        $wheresql .= "where rolename = '".$search_txt."'";
    }
    
    
    $sql .= " select ld_users.id,ld_users.last_name,ld_users.user_name,ld_role.rolename from ld_users ";
    $sql .= " inner join ld_user2role ";
    $sql .= " on ld_users.id = ld_user2role.userid ";
    $sql .= " inner join ld_role ";
    $sql .= " on ld_role.roleid = ld_user2role.roleid ";
    $sql .= $wheresql;
    $result = $adb->pquery($sql,array());
    $num_rows=$adb->num_rows($result);
    $search_users = array();
    if($num_rows)
    {
        for($i=0;$i<$num_rows;$i++)
        {
          $result_search .= "<table class=\"small\" align=\"center\" width=\"99%\" cellspacing=\"1\" cellpadding=\"5\" border=\"0\" style=\"background-color: rgb(204, 204, 204);\">";
          $result_search .= "<tbody>";
          $result_search .= "<tr>";
          $result_search .= "<td class=\"lvtCol\">账号</td>";
          $result_search .= "<td class=\"lvtCol\">姓名</td>";
          $result_search .= "<td class=\"lvtCol\">角色</td>";
          $result_search .= "</tr>";
          $result_search .= "<tr>";
          $result_search .= "<td class=\"lvtColData\" bgcolor=\"white\" onmouseout=\"this.className='lvtColData'\" onmouseover=\"this.className='lvtColDataHover'\">";
          $result_search .= "<a href=\"javascript:window.close();\" onclick=\"set_value_approveby('".$adb->query_result($result,$i,'user_name')."','".$adb->query_result($result,$i,'user_name')."')\">".$adb->query_result($result,$i,'user_name')."</a>";
          $result_search .= "<input type=\"hidden\" id=".$adb->query_result($result,$i,'id')." value=".$adb->query_result($result,$i,'id')."/>";
          $result_search .= "</td>";
          $result_search .= "<td class=\"lvtColData\" bgcolor=\"white\" onmouseout=\"this.className='lvtColData'\" onmouseover=\"this.className='lvtColDataHover'\">".$adb->query_result($result,$i,'lastname')."</td>";
          $result_search .= "<td class=\"lvtColData\" bgcolor=\"white\" onmouseout=\"this.className='lvtColData'\" onmouseover=\"this.className='lvtColDataHover'\">".$adb->query_result($result,$i,'rolename')."</td>";
          $result_search .= "</tr>";  
          $result_search .= "</tbody>";  
          $result_search .= "</table>";  
        }
    }
    echo "#SUCCESS#".$result_search;
        exit();
}
else
{
    $sql .= " select ld_users.id,ld_users.last_name,ld_users.user_name,ld_role.rolename from ld_users ";
    $sql .= " inner join ld_user2role ";
    $sql .= " on ld_users.id = ld_user2role.userid ";
    $sql .= " inner join ld_role ";
    $sql .= " on ld_role.roleid = ld_user2role.roleid ";
    $result = $adb->pquery($sql,array());
    $num_rows=$adb->num_rows($result);
    $all_users = array();
    if($num_rows)
    {
        for($i=0;$i<$num_rows;$i++)
        {
            $all_users[] = array(
            'id'=> $adb->query_result($result,$i,'id'),
            'last_name'=> $adb->query_result($result,$i,'last_name'),
            'user_name'=> $adb->query_result($result,$i,'user_name'),
            'rolename'=> $adb->query_result($result,$i,'rolename')
            );    
        }
    }
    
}
if(isset($_REQUEST['action_name']) && $_REQUEST['action_name']!="")
{
    $action_name = $_REQUEST['action_name'];
}
$smarty->assign("action_name",$action_name);
$smarty->assign("all_users",$all_users);
$smarty->display("approvebyusers.tpl");

?>