<?php
global $adb;
 if($_REQUEST['type']=='popup')
 {
    $returnmodule="Users";
    $idlist=trim($_REQUEST['idlist'],';');
    
    $storearray = getSelectedRecords($_REQUEST,$returnmodule,$idlist,$excludedRecords);
    $count=sizeof($storearray);
    for($i=0;$i<$count;$i++)
    {
            $usergroup[$storearray[$i]]=array();
            
    }
     $sql='select  ld_groups.groupid ,ld_users2group.userid from ld_users2group INNER JOIN
    ld_groups on ld_groups.groupid=ld_users2group.groupid  where ld_users2group.userid  in(  '.implode(',',$storearray).' )';

    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
  
    for($i=0;$i<$rows;$i++)
    {
        $userid=$adb->query_result($result,$i,'userid');
        $groupid=$adb->query_result($result,$i,'groupid');
        
        $usergroup[$userid][]=$groupid;
    }
    $keys=array_keys($usergroup);
    $tmparray=$usergroup[$keys[0]];
    $_REQUEST['diony']='diony';
   $arr['userid']=implode(",",$storearray);
    if(empty($tmparray))
    {
        $arr['groupid']="";
        ConvertTojsonString(1,$arr,"success");
    }
    for($i=1;$i<sizeof($keys);$i++)
    {
        if(empty($usergroup[$keys[$i]]))
        {
            $arr['groupid']="";
            ConvertTojsonString(1,$arr,"success");
        }
        $tmparray=array_intersect($tmparray,$usergroup[$keys[$i]]);
    }
    $arr['groupid']=implode(",",$tmparray);
    ConvertTojsonString(1,$arr,"success");
    
    
 }
 else if($_REQUEST['type']=='save')
 {
    $_REQUEST['diony']='diony';
    $userlist=explode(",",$_REQUEST['userlist']);
    $grouplist=explode(",",$_REQUEST['grouplist']);
    $sql='delete from ld_users2group where userid in ('.implode(',',$userlist).' )';
    $adb->pquery($sql,array());
    $focus=new Users();
     $focus->getModuleStatic('ModTracker');//×Ö¶ÎÐÞ¸ÄÈÕÖ¾
    foreach($userlist as $id)
    {
        $sql='select groupid from ld_users where id=?';
        $result=$adb->pquery($sql,array($id));
        $beforevalue=$adb->query_result($result,0,0);
        
        foreach($grouplist as $groupid)
        {
            $sql="insert into ld_users2group (userid,groupid)value(?,?)";
            $adb->pquery($sql,array($id,$groupid));
        }
		//0033411: ³ÉÔ±¹ÜÀí-ÉèÖÃ²¿ÃÅ£¬ Ã»ÓÐ¸ø ld_users.groupid¸³Öµ
		$query = 'update ld_users set groupid = ? where id = ?';
		$adb->pquery($query,array($_REQUEST['grouplist'],$id));
        //37116: £¨1.6£©³ÉÔ±¹ÜÀíÁÐ±í½çÃæ>¹´Ñ¡ÈÎÒâÓÃ»§>ÐÞ¸Ä¸ÃÓÃ»§µÄËùÔÚ²¿ÃÅ£ºÐÞ¸ÄºóÃ»ÓÐÉú³ÉÐÞ¸ÄÈÕÖ¾¡££¨ÐèÒª²¹¶¡£©
        if($beforevalue!=$_REQUEST['grouplist'])
            $focus->modstatic->saveFieldLogOne("Users", 'groupid', $id, $beforevalue, $_REQUEST['grouplist']);
    }
    ConvertTojsonString(1,array(),"success");
    
 }

?>