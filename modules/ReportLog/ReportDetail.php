<?php
    require_once('Smarty_setup.php');
    global $adb;
        
        if(isset($_REQUEST['type']) && isset($_REQUEST['id']))//1表示是周报     
        {
            if($_REQUEST['type'] == 1)
            {
                $title = "周报";
            
                $smarty->assign("TITLE1",$title);

               $sql1 = "select worksummary,nextweekplan,ld_users.last_name
                       from ld_weekReport  left join ld_users on ld_users.id=ld_weekreport.smcreatorid 
                       where weekreportid = ".$_REQUEST['id']."";
              //查询工作总结和下周工作计划
               $result1 = $adb->pquery($sql1,array());//用pquery的方法处理数据,出来一个对象

               if($adb->num_rows($result1)>0)//判断获得的结果的行数是否大于0
               {
                 $WorkSummary=$adb->query_result($result1,0,0);
                 $WorkSummary=str_replace("&lt;","<",$WorkSummary);
                $WorkSummary=str_replace("&gt;",">",$WorkSummary);
                $WorkSummary=str_replace("&quot;",'"',$WorkSummary);
                 //获取结果,第一个代表结果，第二个代表结果行数，第三行代表列数
                 //echo "$WorkSummary";//字段的内容
                 
                 $Nextweekplan=$adb->query_result($result1,0,1);
                 $Nextweekplan=str_replace("&lt;","<",$Nextweekplan);
                $Nextweekplan=str_replace("&gt;",">",$Nextweekplan);
                $Nextweekplan=str_replace("&quot;",'"',$Nextweekplan);
                 
                 $Name = $adb->query_result($result1,0,2);
                 //同上列数0代表第一列，以此类推，两列中一个是工作总结一个是下周计划
               } 
              $sql2 = "select startdate,enddate from ld_weekReport where weekreportid = ".$_REQUEST['id']."";
              $result2 = $adb->pquery($sql2,array());
               
              if($adb->num_rows($result2)>0)
              {
                $Startdate=$adb->query_result($result2,0,0);//开始时间
                
                $Enddate=$adb->query_result($result2,0,1);//结束时间
              }
              $sql3 = "select T1.commentcontent,T1.commentdate,T2.last_name from ld_reportcomments as T1 
                       left join ld_users as T2 on T1.commentatorid=T2.id
                       where type =1 and reportid = ".$_REQUEST['id']."";
                     //查询回复的sql语句
                     
              $result3 = $adb->pquery($sql3,array());
              
              //echo "$result3";
              if($adb->num_rows($result3)>0)
              {
                $num_rows=$adb->num_rows($result3);
                   // echo "$num_rows";2
                for($i = 0;$i<=$num_rows;$i++)
                {
                    $commentcontent = $adb->query_result($result3,$i,0);//回复的内容
                
                    $commentdate = $adb->query_result($result3,$i,1);//回复的时间
                    $username=$adb->query_result($result3,$i,'last_name');
                    
                    $row_arr[] = array('commentcontent'=>$commentcontent,'commentdate'=>$commentdate,
                    'username'=>$username
                    );
                }                
               
              }
                 $smarty->assign("ROW_ARR",$row_arr);
                 $smarty->assign("WORKSUMMARY_W",$WorkSummary);//周总结
                 $smarty->assign("NEXTWEEKPLAN",$Nextweekplan);//周计划
                 $smarty->assign("NAME",$Name);//查看周报的人名
                 $smarty->assign("STARTDATE",$Startdate);//开始时间
                 $smarty->assign("ENDDATE",$Enddate);//结束时间
                 ///end week
             }
             else if($_REQUEST['type'] == 2)//2表示是月报   
            {
                   
                $title2 = "月报";
                //echo "$title2";
                $smarty->assign('TITLE2',$title2);
                
    
                
                $sql1 = "select T1.workSummary as worksummary,T1.nextmonthplan as nextmonthplan,ld_users.last_name from ld_monthReport as T1
                        left join ld_users on ld_users.id=T1.smcreatorid
                        where T1.monthreportid = ".$_REQUEST['id']."";
                     
                ////查询工作总结和下月工作计划
                $result1 = $adb->query($sql1);
                
                
                if($adb->num_rows($result1)>0)
                {
                    
                    $WorkSummary = $adb->query_result($result1,0,'worksummary');//月工总总结
                    
                    $WorkSummary=str_replace("&lt;","<",$WorkSummary);
                    $WorkSummary=str_replace("&gt;",">",$WorkSummary);
                    $WorkSummary=str_replace("&quot;",'"',$WorkSummary);
                    
                    $Nextmonthplan = $adb->query_result($result1,0,'nextmonthplan'); //下月工作计划
                    $Nextmonthplan=str_replace("&lt;","<",$Nextmonthplan);
                    $Nextmonthplan=str_replace("&gt;",">",$Nextmonthplan);
                    $Nextmonthplan=str_replace("&quot;",'"',$Nextmonthplan);
                    $Name2= $adb->query_result($result1,0,'last_name');//人名
                }
                
                $sql2 = "select startdate,enddate from ld_monthreport 
                        where monthreportid = ".$_REQUEST['id']."";
                        //查询开始和结束时间
                $result2 = $adb->query($sql2);      
                
                if($adb->num_rows($result2)>0)
                {
                    $Startdate = $adb->query_result($result2,0,0);//开始时间         
                    $Enddate = $adb->query_result($result2,0,1);//结束时间         
                }
                
                $sql3 = "select T1.commentcontent,T1.commentdate,T2.last_name from ld_reportcomments as T1 
                         left join ld_users as T2 on T1.commentatorid=T2.id
                         where type =2 and reportid = ".$_REQUEST['id']."";
                       //月报的回复查询语句  
                   
                $result3 = $adb->pquery($sql3,array());
                
                if($adb->num_rows($result3)>0)
                {
                    $num_rows=$adb->num_rows($result3);
                       // echo "$num_rows";2
                    for($j = 0;$j<=$num_rows;$j++)
                    {
                        $commentcontent = $adb->query_result($result3,$j,0);//回复的内容
                    
                        $commentdate = $adb->query_result($result3,$j,1);//回复的时间
                        $username=$adb->query_result($result3,$j,'last_name');
                        
                        $row_arr2[] = array('commentcontent'=>$commentcontent,'commentdate'=>$commentdate,
                        'username'=>$username
                        );
                    }                
                }
                $smarty->assign('ROW_ARR',$row_arr2);
                $smarty->assign("WORKSUMMARY_M",$WorkSummary);//工作总结
                $smarty->assign("NEXTMONTHPLAN",$Nextmonthplan);//下月工作计划
                $smarty->assign("NAME",$Name2);//查看月报的人名  
                $smarty->assign("STARTDATE",$Startdate);//月报开始时间
                $smarty->assign("ENDDATE",$Enddate);//月报结束时间
            }
        }
        setGLobalURLSmarty($smarty);//js,css的加载url
    
            $smarty->display('ReportLog/ReportDetail.tpl');
                 
?>