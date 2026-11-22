<?php
global $currentModule,$adb;
$smarty=new lingdangCRM_Smarty();


if($_REQUEST['mode']=='ajax')
{
    
    if($_REQUEST['startdate'])
    {
        $startdate=$_REQUEST['startdate'];
        $uninx_starttime=strtotime($startdate);
        $_SESSION['ReportGuiji_startdate']=$startdate;
        $_SESSION['ReportGuiji_uninx_startdate']=$uninx_starttime;
    }
    else
    {
        $startdate=$_SESSION['ReportGuiji_startdate'];
        $uninx_starttime=$_SESSION['ReportGuiji_uninx_startdate'];
    }
    if($_REQUEST['enddate'])
    {
        $enddate=$_REQUEST['enddate'];
         $uninx_enddtime=strtotime($enddate);
         $_SESSION['ReportGuiji_enddate']=$enddate;
        $_SESSION['ReportGuiji_uninx_enddate']=$uninx_enddtime;
    }
    else
    {
       $enddate=$_SESSION['ReportGuiji_enddate'];
        $uninx_enddtime=$_SESSION['ReportGuiji_uninx_enddate'];
    }
    if($_REQUEST['smowner'])
    {
         $userid=$_REQUEST['smowner'];
         $_SESSION['ReportGuiji_userid']=$userid;
        
    }
    else
    {
        $userid=$_SESSION['ReportGuiji_userid'];
        
    }
    $seconds=DateOperation::sencods_between_time($enddate,$startdate);
    if($seconds>3600*24)//开始查询时间和结束查询时间的时间差不能超过24小时
    {
        echo '##error##$$';
        exit();
    }
    echo '##$$$###$$';
    $sql=" select user_name,last_name,tmp.groupnames from ld_users INNER JOIN 
            (
            select GROUP_CONCAT(groupname) as groupnames,ld_users2group.userid  from  ld_users2group 
            INNER JOIN ld_groups on ld_groups.groupid=ld_users2group.groupid
            group by ld_users2group.userid ) as tmp  on tmp.userid=ld_users.id   ";
    
    $service_id=file_get_contents(globalStatic::$root_directory."user_privileges/yingyanInfo.txt");
    $ak="6GGuFE5FBge1YoNpMqYD0ihpFSzFkuIi";
    
    $enterpriseno=file_get_contents(globalStatic::$root_directory."user_privileges/enterpriseno.txt");
    if($userid=="SmOwner_Search_All")
    {
        
    }
    else if($userid=="SmOwner_Search_Me")
    {
        $sql.=" where id= ".$current_user->id;
    }
    else
    {
        $sql.=" where id in( $userid )";
    }
    
    $sql.=" order by convert(last_name using gbk) asc ";
    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
    $k=0;
    for($i=0;$i<$rows;$i++)
    {
        
        $last_name=$adb->query_result($result,$i,'last_name');
        $user_name=$adb->query_result($result,$i,'user_name');
        $groupnames=$adb->query_result($result,$i,'groupnames');
        $tmparr[$k]=array("last_name"=>$last_name,'groupnames'=>$groupnames,"user_name"=>$user_name);
        
        $url="http://yingyan.baidu.com/api/v3/track/gettrack";
        $url.="?ak=".$ak.'&service_id=153080';
        $url.='&entity_name='.$enterpriseno."_".strtolower($user_name);
        $url.="&start_time=".$uninx_starttime."&end_time=".$uninx_enddtime;
        $url.="&is_processed=1&need_denoise=1&radius_threshold=100&need_vacuate=1";
      //  $url.="&page_index=1&page_size=200";
      
        $info= getcurl($url);
        $info=json_decode($info,true);
       
        
        if($info['status']==0&&sizeof($info['points'])>0)
        {
            $pointscount=sizeof($info['points']);
            
           $createdtime= $info['points'][0]['create_time'];
          
            
            for($j=0;$j<$pointscount;$j++)
            {
                $nextcreatedtime=$info['points'][$j]['create_time'];
                $seconds=DateOperation::sencods_between_time($nextcreatedtime,$createdtime);
                //两次定位的时间差超过5分钟则界面显示
                //$j=0;表示第一条记录
                if($seconds>=300||$j==0)
                {
                    $createdtime=$nextcreatedtime;
                     $loc=$info['points'][$j]['latitude'].','.$info['points'][$j]['longitude'];
                     //callback=renderReverse
                     $addressinfo=json_decode(file_get_contents("http://api.map.baidu.com/geocoder/v2/?&location=$loc&output=json&pois=0&ak=$ak"),true);
                   
                    $addressdetail=$addressinfo['result']['formatted_address'];
                   $tmparr[$k]=array("last_name"=>$last_name,'groupnames'=>$groupnames,"user_name"=>$user_name,"address"=>$addressdetail,'time'=>$createdtime);
                   $k++;
                   
                }
            }
        }
        else
        {
            $k++;
        }
      
    }
    
  
    $smarty->assign("USERINFO",$tmparr);
    $smarty->display("modules/OftenUseReport/reportguijicontent.tpl");
}
else
{
    $MergeSmowner=getCurSmOwnerSearchScope($currentModule);
    unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']);
    unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Create']);
    unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']); //去掉共享给我的
     unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']);
    // unset($MergeSmowner["OtherInfo"]['smowner_search_senior']);
    unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']);
    $smarty->assign('Merge_SmOwner',$MergeSmowner);
//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($MergeSmowner) > 0 && $currentModule != 'InventoryAccount' && $currentModule != 'InventoryQuery' && $currentModule != 'BankAccountSet' && $currentModule != 'Reminds'){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
    $smarty->assign("NOWTIME",date("Y-m-d H:i:s"));
    $smarty->assign("ENDTIME",date("Y-m-d 24:00:00"));
   //$smarty->assign("NOWTIME",'2018-01-31 00:00:00');
   // $smarty->assign("ENDTIME",'2018-01-31 24:00:00');
    $smarty->display("modules/OftenUseReport/reportguiji.tpl");
}
    


 function getcurl($url)
 {

   $curl = curl_init(); // 启动一个CURL会话
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_HEADER, 0);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false); // 跳过证书检查
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, true);  // 从证书中检查SSL加密算法是否存在
    $tmpInfo = curl_exec($curl);     //返回api的json对象
    //关闭URL请求
    curl_close($curl);
    
    return $tmpInfo;    //返回json对象
}

?>