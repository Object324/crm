<?php
@ob_clean();
@ob_flush();
global $currentModule;
global $adb;
if($_REQUEST['userlist'])
{
    $sql="select user_name,last_name,id,ld_users.tracklinecolor from ld_users    ORDER BY convert(last_name USING 'gbk');";
    $result=$adb->pquery($sql,array());
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
        $user_name=$adb->query_result($result,$i,'user_name');
        $last_name=$adb->query_result($result,$i,'last_name');
        $tracklinecolor=$adb->query_result($result,$i,'tracklinecolor');
        $id=$adb->query_result($result,$i,'id');
        $users[]=array('user_name'=>strtolower($user_name),'last_name'=>$last_name,'id'=>$id,'tracklinecolor'=>$tracklinecolor);
        
    }
     $tmp_users['list']=$users;
     $enterpriseno=file_get_contents(globalStatic::$root_directory."user_privileges/enterpriseno.txt");
     
     
      $tmp_users['enterpriseno']=trim(strtolower($enterpriseno));
     echo json_encode($tmp_users);
    
}
else if($_REQUEST['mapcolor'])
{
    //where firstregion='上海市浦东新区宣桥镇' and secondregion='项埭村'
    $sql="select * from ld_mapregion    ";
    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
    for($i=0;$i<$rows;$i++)
    {
        $regioncolor=$adb->query_result($result,$i,'regioncolor');
        $bounds=$adb->query_result($result,$i,'bounds');
        $secondregion=$adb->query_result($result,i,'secondregion');
        if($secondregion=='宣桥镇')
        {
            $tmp_bounds=$bounds;
            $tmp_regioncolor=$regioncolor;
        }
        else
        
        $arr['mapinfo'][]=array('color'=>$regioncolor,'bounds'=>explode('#',$bounds));
    }
    if(!empty($tmp_bounds))
    {
        $arr['mapinfo'][0]=array('color'=>$tmp_regioncolor,'bounds'=>explode('#',$tmp_bounds));
    }
    
     echo json_encode($arr);
}
else if(isset($_REQUEST['type'])&&$_REQUEST['type']=='getgroup')
{
    $sql='select DISTINCT ld_users.id,ld_users.last_name,ld_users.user_name,ld_users.tracklinecolor from ld_users2group
        INNER JOIN ld_users on ld_users.id=ld_users2group.userid where ld_users2group.groupid in('.$_REQUEST['ids'].')  ';
    $result=$adb->pquery($sql,array());
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
        $user_name=$adb->query_result($result,$i,'user_name');
        $last_name=$adb->query_result($result,$i,'last_name');
        $tracklinecolor=$adb->query_result($result,$i,'tracklinecolor');
        $id=$adb->query_result($result,$i,'id');
        $users[]=array('user_name'=>strtolower($user_name),'last_name'=>$last_name,'id'=>$id,'tracklinecolor'=>$tracklinecolor);
        
        
    }
    $tmp_users['list']=$users;
    
     echo json_encode($tmp_users);     
}
else if(isset($_REQUEST['type'])&&$_REQUEST['type']=='getuser') 
{
    
    {
        $sql='select DISTINCT ld_users.id,ld_users.last_name,ld_users.user_name,ld_users.tracklinecolor from  ld_users 
         where ld_users.id in('.$_REQUEST['ids'].')  ';
        $result=$adb->pquery($sql,array());
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $user_name=$adb->query_result($result,$i,'user_name');
            $last_name=$adb->query_result($result,$i,'last_name');
            $tracklinecolor=$adb->query_result($result,$i,'tracklinecolor');
            $id=$adb->query_result($result,$i,'id');
            $users[]=array('user_name'=>strtolower($user_name),'last_name'=>$last_name,'id'=>$id,'tracklinecolor'=>$tracklinecolor);
            
            
        }
        $tmp_users['list']=$users;
        
         echo json_encode($tmp_users);     
    }
}
else if(isset($_REQUEST['type'])&&$_REQUEST['type']=='getprofile')
{
    $sql='select DISTINCT ld_users.id,ld_users.last_name,ld_users.user_name ,ld_users.tracklinecolor from ld_users where profileid in('.$_REQUEST['ids'].')';
     $result=$adb->pquery($sql,array());
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
         $user_name=$adb->query_result($result,$i,'user_name');
        $last_name=$adb->query_result($result,$i,'last_name');
        $tracklinecolor=$adb->query_result($result,$i,'tracklinecolor');
        $id=$adb->query_result($result,$i,'id');
        $users[]=array('user_name'=>strtolower($user_name),'last_name'=>$last_name,'id'=>$id,'tracklinecolor'=>$tracklinecolor);
        
        
    }
    $tmp_users['list']=$users;
    
     echo json_encode($tmp_users);        
}
else
{
    /*$service_id=113382;
     if(file_exists(globalStatic::$root_directory."user_privileges/yingyanInfo.txt"))
     {
        $service_id=file_get_contents(globalStatic::$root_directory."user_privileges/yingyanInfo.txt");
     }
    echo json_encode(array('serviceid'=>$service_id,'ak'=>'Hgvb6X18khZw223dBW1hFHuT'));*/
    
    include(globalStatic::$root_directory.'modules/Users/getyingyanak.php');
    
}
    
exit();
?>