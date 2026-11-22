<?php
/**
     * Liver 将客户平均分组 
     */
      function setAccount_Average_Group($recordids,$smownerids){
   		$Accounts_count=count($recordids);//选中的客户总数
		$smownerid_count=count($smownerids);//选中的用户总数
		$k=0;
		
		if($Accounts_count == 0) {  
			$avg_Accouns = array_fill(0, $smownerid_count, 0);  
		} else {			
			$avg     = floor($Accounts_count / $smownerid_count);  
			$ceilSum = $avg * $smownerid_count;  
			$avg_Accouns   = array();  
						
			for($i = 0; $i < $smownerid_count; $i++) {  
				if($i < $Accounts_count - $ceilSum) { 					
					$avg_Accouns[]=array_slice($recordids,$k,$avg+1);
					$k += $avg+1;					
				} else {  
					$avg_Accouns[]=array_slice($recordids,$k,$avg);
					$k += $avg;
				}	
			}  
		}  
		return $avg_Accouns; 
     }
    /*
    获取勾选用户的last_name
    */
     function getAverageUserName($userid){
        global $adb;

        $sql='select last_name,wx_userid from ld_users where id=? limit 0,1';
        $result=$adb->pquery($sql,array($userid));
        $nums = $adb->num_rows($result);
        if($nums==1){
            $wx_userid=$adb->query_result($result,0,'wx_userid');
            $username=$adb->query_result($result,0,'last_name');
            $userobj=new Users();
            $userobj->wx_userid=$wx_userid;
            $userobj->last_name=$username;
            $username=getUserlastName($userobj);
        }
        return $username;
    }
?>