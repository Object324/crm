<?php
if($_REQUEST['type']=='download')
{
    

    
    $modulelabel = "轨迹路线图";
    $file_name = 'ReportGuiji.xls';
    $file_dir = './storage/';
    
  
    //下载文件
    $file = fopen($file_dir.$file_name,"r"); 
    Header("Content-type: application/octet-stream");
    Header("Accept-Ranges: bytes");
    Header("Accept-Length: ".filesize($file_dir.$file_name));
    Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
    Header("pragma: no-cache");
    ob_clean();
    flush(); 
    echo fread($file, filesize($file_dir.$file_name));
    fclose($file);
    exit();
}
global $adb,$current_user;
include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).'1',"姓名");
$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(1).'1',"部门");
$tmp= PHPExcel_Cell::stringFromColumnIndex(1);
$objPHPExcel->getActiveSheet()->getColumnDimension($tmp)->setWidth(25);
$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(2).'1',"时间");
$tmp= PHPExcel_Cell::stringFromColumnIndex(2);
$objPHPExcel->getActiveSheet()->getColumnDimension($tmp)->setWidth(20);
$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(3).'1',"位置");
$tmp= PHPExcel_Cell::stringFromColumnIndex(3);
$objPHPExcel->getActiveSheet()->getColumnDimension($tmp)->setWidth(35);
 

$startdate=$_REQUEST['startdate'];
$uninx_starttime=strtotime($startdate);
    
$enddate=$_REQUEST['enddate'];
$uninx_enddtime=strtotime($enddate);
$userid=$_REQUEST['smowner'];
$tags=$_REQUEST['tags'];
$selecttags=explode(",",$tags);
$seconds=DateOperation::sencods_between_time($enddate,$startdate);
if($seconds>3600*24)//开始查询时间和结束查询时间的时间差不能超过24小时
{
        echo '##error##$$';
        exit();
}
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
    $k=2;//excel行号
    $nowtag=0;
    for($i=0;$i<$rows;$i++)
    {
      
        $last_name=$adb->query_result($result,$i,'last_name');
        $user_name=$adb->query_result($result,$i,'user_name');
        $groupnames=$adb->query_result($result,$i,'groupnames');
        
        $url="http://yingyan.baidu.com/api/v3/track/gettrack";
        $url.="?ak=".$ak.'&service_id=153080';
        $url.='&entity_name='.$enterpriseno."_".strtolower($user_name);
        $url.="&start_time=".$uninx_starttime."&end_time=".$uninx_enddtime;
        $url.="&is_processed=1&need_denoise=1&radius_threshold=50&need_vacuate=1";
        $info= file_get_contents($url);
        $info=json_decode($info,true);
        if($info['status']==0&&sizeof($info['points'])>0)
        {
            $pointscount=sizeof($info['points']);
           
           $createdtime= $info['points'][0]['create_time'];
            for($j=0;$j<$pointscount;$j++)
            {
               
                $nextcreatedtime=$info['points'][$j]['create_time'];
                
                //两次定位的时间差
                $seconds=DateOperation::sencods_between_time($nextcreatedtime,$createdtime);
                
                //两次定位的时间差超过5分钟则导出
                if($seconds>=300||$j==0)
                {
                    
                    $createdtime=$nextcreatedtime;
                  
                    $nowtag++;
                   if(!empty($tags)&&!in_array($nowtag,$selecttags))
                   {
                    //导出选定记录的轨迹
                      continue;
                   }
                     $loc=$info['points'][$j]['latitude'].','.$info['points'][$j]['longitude'];
                    
                     $addressinfo=json_decode(file_get_contents("http://api.map.baidu.com/geocoder/v2/?&location=$loc&output=json&pois=0&ak=$ak"),true);
                 
                   
                    $addressdetail=$addressinfo['result']['formatted_address'];
                    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex("0").$k,$last_name);
                    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex("1").$k,$groupnames);
                     $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex("2").$k,$createdtime);
                    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex("3").$k,$addressdetail);
                   
                   $k++;
                   
                }
            }
        }
        else
        {
              $nowtag++;
               if(!empty($tags)&&!in_array($nowtag,$selecttags))
               {
                //导出选定记录的轨迹
                  continue;
               }
              $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex("0").$k,$last_name);
            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex("1").$k,$groupnames);
            $k++;
        }
      
    }
    
    
$modulelabel = "轨迹路线图";
$file_name = 'ReportGuiji.xls';
$file_dir = './storage/';

$objPHPExcel->getActiveSheet()->setTitle('OftenUseReport');
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save($file_dir.$file_name);


exit();

?>