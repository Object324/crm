<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
 global $adb, $currentModule, $current_user;
 
 $frommodule = $_REQUEST['frommodule'];
 $id = $_REQUEST['id'];
 if($frommodule=='ProjectTask'){
    //022498: 联系记录新增界面：选择项目任务后，带出的值显示了null
    $sql = "SELECT projecttaskid,ld_account.accountid,ld_project.projectid,ifnull(ld_account.accountname,'') as accountname,ifnull(ld_project.projectname,'') as projectname,
             ifnull(ld_contactdetails.contactid,0) as contactid,ifnull(ld_contactdetails.lastname,'') as lastname
            FROM ld_projecttask 
            LEFT JOIN ld_account ON ld_projecttask.accountid = ld_account.accountid
            LEFT JOIN ld_project ON ld_project.projectid = ld_projecttask.projectid
            LEFT JOIN ld_contactdetails ON ld_contactdetails.accountid = ld_account.accountid
            where ld_projecttask.projecttaskid=".$id;
    $query=$adb->pquery($sql,array());
    $list['accountid']=$adb->query_result($query,0,'accountid');
    $list['projectid']=$adb->query_result($query,0,'projectid');
    $list['accountname']=$adb->query_result($query,0,'accountname');
    $list['projectname']=$adb->query_result($query,0,'projectname');
    $list['contactid']=$adb->query_result($query,0,'contactid');
    $list['lastname']=$adb->query_result($query,0,'lastname');
     echo json_encode($list);exit;
 }
 $entityname=getEntitynameByModulename($frommodule);
 $sql="SELECT * FROM ".$entityname['tablename'].' where '.$entityname['entityidfield'].'='.$id.' limit 1';
 if($frommodule=='Accounts'){
     /*$sql2='SELECT contactid FROM ld_contactdetails WHERE  accountid='.$id.' limit 1';
     $query2=$adb->pquery($sql2,array());*/
     $sql2='SELECT contactid FROM ld_contactdetails WHERE accountid='.$id.' and reference=1 limit 1';
     $query2=$adb->pquery($sql2,array());
     if($adb->num_rows($query2)<=0){
        $sql2='SELECT contactid FROM ld_contactdetails WHERE accountid='.$id.' limit 1';  
        $query2=$adb->pquery($sql2,array());  
     }      
 }

 $query=$adb->pquery($sql,array());
 
            $list['accountid']=$adb->query_result($query,0,'accountid');
            if($frommodule=='Accounts')
                $list['contactid']=$adb->query_result($query2,0,'contactid');
            else
                $list['contactid']=$adb->query_result($query,0,'contactid');
            $list['vendorid']=$adb->query_result($query,0,'vendorid');
            $list['vendorcontactsid']=$adb->query_result($query,0,'vendorcontactsid');
            
             if($list['accountid']=='')$list['accountid']=0;          
             if($list['contactid']=='')$list['contactid']=0;      
             if($list['vendorid']=='')$list['vendorid']=0;          
             if($list['vendorcontactsid']=='')$list['vendorcontactsid']=0;   
                    
            $sql='SELECT accountname,smownerid FROM ld_account 
                  LEFT JOIN ld_users on ld_users.id=ld_account.smownerid 
                  WHERE ld_users.status=\'Active\' and accountid='.$list['accountid'];
             $resulta=$adb->pquery($sql,array());
             if($adb->num_rows($resulta)>0)
             {
                    $list['accountname']=$adb->query_result($resulta,0,'accountname');
                    $list['smownerid']=$adb->query_result($resulta,0,'smownerid');
             }
             else
             {
                $list['accountname']='';
                //Liver 2016-11-02,bug0025558: 合同订单新建：选择的客户名称对应的销售负责人停用，合同订单新建时必填字段“销售负责人”的值为空，保存成功
                $list['smownerid']=$current_user->id;
             }
             
            $sql='SELECT lastname FROM ld_contactdetails WHERE contactid='.$list['contactid'];
            
             $resultc=$adb->pquery($sql,array());
             if($adb->num_rows($resultc)>0)
                 $list['lastname']=$adb->query_result($resultc,0,'lastname');
             else
                 $list['lastname']='';
             
             $sql='SELECT vendorname,smownerid FROM ld_vendor  
                   LEFT JOIN ld_users on ld_users.id=ld_vendor.smownerid
                   WHERE ld_users.status=\'Active\' and vendorid='.$list['vendorid'];
             //echo $sql;
             $resultv=$adb->pquery($sql,array());
             if($adb->num_rows($resultv)>0)
                {
                      $list['vendorname']=$adb->query_result($resultv,0,'vendorname');
                    $list['vsmownerid']=$adb->query_result($resultv,0,'smownerid');
                }
                else
                {
                    $list['vendorname']='';
                    $list['vsmownerid']=$current_user->id;
                }
             if($frommodule=='Vendors'){
                $sql='SELECT lastname,vendorcontactsid FROM ld_vendorcontacts where vendorid='.$list['vendorid'];
                $resultvc=$adb->pquery($sql,array());
                if($adb->num_rows($resultvc)>0)
                {
                    $list['vendorcontacts']=$adb->query_result($resultvc,0,'lastname');
                    $list['vendorcontactsid']=$adb->query_result($resultvc,0,'vendorcontactsid');
                }
                else
                {
                    $list['vendorcontacts']='';
                    $list['vendorcontactsid']='0';
                }
             }else{
                 $sql='SELECT Lastname FROM ld_vendorcontacts WHERE vendorcontactsid='.$list['vendorcontactsid'];
                 $resultvc=$adb->pquery($sql,array());
                 if($adb->num_rows($resultvc)>0)
                     $list['vendorcontacts']=$adb->query_result($resultvc,0,'lastname');
                 else
                    $list['vendorcontacts']='';
             }

        echo json_encode($list);
?>