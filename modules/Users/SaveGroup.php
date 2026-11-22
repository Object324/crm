<?php

include("modules/Users/Group.class.php");
$group_focus = new Group();
global $adb;
$_REQUEST['diony']='diony';
$groupname=$_REQUEST['groupname'];
$groupno=$_REQUEST['groupno'];
$isDepartmentNubmer=getSys_deploy(478);
$isDepartmentRemark=getSys_deploy(477);
 if($_REQUEST['record']&&$_REQUEST['record']>0)
{
    $input=$_REQUEST;
     if(isPermitted("Users","EditView")!='yes')
     {
        ConvertTojsonString("-1",array(),"无编辑权限");
     }

    $related_crmid = 0;
    if($_REQUEST['related_crmid'] && !empty($_REQUEST['related_crmid'])){
        $related_crmid = intval($_REQUEST['related_crmid']);
    }
    // zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数. 根据字段启用情况做特殊处理
    //启用部门编号字段
     if($isDepartmentNubmer['deploy_value']!='no'){
         //230705 wyt BUG0068483   kfbcrm-成员管理-新增部门-应控制部门编号不能重复
         $sql_groupno="select 1 from ld_groups where group_no=? and  groupid<>?";
         $result_groupno=$adb->pquery($sql_groupno,array($groupno,$_REQUEST['record']));
         $rows_groupno = $adb->num_rows($result_groupno);
         if($rows_groupno > 0 ){
             ConvertTojsonString("-1",array(),"groupnorepeat");
         }
         //zkt 20230517 BUG0066589 （http://222.173.113.110:10190/crm）8499版本，修改部门架构，保存后，刷新界面，又变回修改前的部门。
         $fieldarr = array('groupname'=>$input['groupname'],
             'parentid'=>$input['parentid'],
             'group_no'=>$input['groupno'],
             'description'=>$input['description']);
         $sql="update ld_groups set groupname=?,description=?,group_no=?,related_crmid=? where groupid=? ";
         $adb->pquery($sql,array($groupname,$_REQUEST['description'], $groupno,$related_crmid,$_REQUEST['record']));
     }
     //不启用部门编号字段
    else{
        //启用备注字段
        if($isDepartmentRemark['deploy_value']!=1){
            $fieldarr = array('groupname'=>$input['groupname'],
                'parentid'=>$input['parentid'],
                'description'=>$input['description']);
            $sql="update ld_groups set groupname=?,description=?,related_crmid=? where groupid=? ";
            $adb->pquery($sql,array($groupname,$_REQUEST['description'],$related_crmid,$_REQUEST['record']));
        }
        else{
            $fieldarr = array('groupname'=>$input['groupname'],
                'parentid'=>$input['parentid']);
            $sql="update ld_groups set groupname=?,related_crmid=? where groupid=? ";
            $adb->pquery($sql,array($groupname,$related_crmid,$_REQUEST['record']));
        }
    }
    
    $arr['groupid']=$_REQUEST['record'];
    if($_REQUEST['parentid']!=$_REQUEST['oldparentid'])
    {
        if(stripos($input['parentid'],'__')!==false)
        {
           $tmp_arr= explode('__',$input['parentid']);
           $input['parentid']=$tmp_arr[0];
        }
        $parentarr = $group_focus->getGroupInfoByid($input['parentid']);
        
        $fieldarr['depth'] = ++ $parentarr['depth'];
        $fieldarr['parentgroup'] = $parentarr['parentgroup'].'::'.$input['record'];
        $updatesql = '';
        foreach($fieldarr as $fld=>$val){
            $updatesql .= $fld.'="'.$val.'",';
        }
        //$updatesql = trim($updatesql,',');
        //获取新的groupseq
        $seqsql = 'SELECT MAX(groupseq) AS groupseq FROM ld_groups WHERE parentid=?';
        $result = $adb->pquery($seqsql,array($_REQUEST['parentid']));
        $rows = $adb->num_rows($result);
        if($rows > 0 ){
            $groupseq = $adb->query_result($result,0,'groupseq');
            ++ $groupseq;
        }
        else{
            $groupseq = 1;
        }
        $updatesql .= 'groupseq='.$groupseq;
	   	$query = 'update ld_groups set '.$updatesql.' where groupid = '.$input['record'].' ';
        $adb->pquery($query,array());
        $group_focus->GroupDragDrop($input['record'],$input['parentid']);

        //更新原部门同级子部门groupseq
        $upquery = 'select groupid from ld_groups where parentid = '.$_REQUEST['oldparentid'].' order by groupseq';
        $upresult = $adb->pquery($upquery);
        $num_rows = $adb->num_rows($upresult);
        if($num_rows > 0){
            for($i=0;$i<$num_rows;$i++)
            {
                $groupidnow=$adb->query_result($upresult,$i,'groupid');
                $adb->pquery('update ld_groups set groupseq=? where groupid=?',array($i+1,$groupidnow));
            }
        }

        $arr['grouptreehtml']="ereererer";
        $arr['parentid']=$_REQUEST['parentid'];
    }
    else
    {
        $arr['grouptreehtml']="";
    }
   
}
else if($_REQUEST['delrecord']&&$_REQUEST['delrecord']>0)
{
    $input=$_REQUEST;
    //删除
    if(isPermitted("Users","Delete")!='yes')
    {
        ConvertTojsonString("-1",array(),"无删除权限");
    }
     
    //获取删除部门的下级html
    if(isset($_REQUEST['userto']))
    {
        $groupuser=$group_focus->getGroupChild($input['delrecord']);

        $delrecord=$input['delrecord'];
        $userto=$input['userto'];
        //edit:can 2021-01-08 42024: （https://61mis.com/kfbtest/ [^]）成员管理，删除子部门时，转移关联成员到部门后，被转移的成员列表界面没有显示部门字段值
        $update_query1 = "UPDATE `ld_users` SET `groupid` = replace (`groupid`,'$delrecord','$userto') 
                    where FIND_IN_SET('$delrecord',groupid) ";
        $adb->pquery($update_query1, array());

        //1、修改部门对应的用户信息
        $update_query2 = 'UPDATE ld_users2group SET groupid = ? WHERE groupid = ?;';
        $adb->pquery($update_query2, array($input['userto'], $input['delrecord']));

        $update_query3 = 'UPDATE ld_user_group_set SET groupid = ? WHERE groupid = ?;';
        $adb->pquery($update_query3, array($input['userto'], $input['delrecord']));

        //BUG0065156 2.修改所属部门字段的值
        $field_sql = "SELECT tablename,columnname from ld_field where uitype = 1600";
        $field_result = $adb->pquery($field_sql,[]);
        $num_rows = $adb->num_rows($field_result);
        for($i=0;$i<$num_rows;$i++){
            $tmp_table = $adb->query_result($field_result,$i,'tablename');
            $tmp_column = $adb->query_result($field_result,$i,'columnname');
            $update_sql = "UPDATE $tmp_table set $tmp_column = REPLACE($tmp_column,'$delrecord','$userto') where FIND_IN_SET('$delrecord',$tmp_column)";
            $adb->pquery($update_sql,array());
        }
    }
    else
    {
        $query="delete from ld_users2group  where groupid=?";
        $adb->pquery($query,array($input['delrecord']));
    }

		//2、将部门的下级部门全都转移走
		if(!empty($input['groupto'])){
			$lowerarr = $group_focus->getGroupTheLower($input['delrecord']);//获取部门所有下级部门信息
           
			$parentarr = $group_focus->getGroupInfoByid($input['groupto']);//获取上级部门信息
           
			foreach($lowerarr as $id=>$lower){//循环下级部门信息
				$from_parentarr = explode('::'.$input['delrecord'].'::',$lower['parentgroup']);
				$parentgroup = $parentarr['parentgroup'].'::'.$from_parentarr[1];
             
				$parentgrouparr = explode('::', $parentgroup);
				$parentgrouplen = count($parentgrouparr);
				$depth = $parentgrouplen-1;
				$parentid = $parentgrouparr[$parentgrouplen-2];
                //zkt 更新部门的parentgroup、depth、parentid
                if($parentid != $input['groupto'])
                {
                    $query = 'UPDATE ld_groups SET parentgroup = ?,depth = ?,parentid=? WHERE groupid = ?;';
              
                    $adb->pquery($query,array($parentgroup,$depth,$parentid,$id));
                    
                }
                else
                {
                    //更新当前转移部门的直系子部门的groupeq、parentgroup、depth、parentid
                    $newgroup_re = $adb->pquery('SELECT MAX(groupseq) as groupseq FROM ld_groups where parentid = ?',array($input['groupto']));
                    $rows = $adb->num_rows($newgroup_re);
                    if($rows > 0 ){
                        $newgroupseq = $adb->query_result($newgroup_re,0,'groupseq');
                        ++ $newgroupseq;
                    }
                    else{
                        $newgroupseq = 1;
                    }
                    $query = 'UPDATE ld_groups SET parentgroup = ?,depth = ?,parentid=?,groupseq=? WHERE groupid = ?;';
                    $adb->pquery($query,array($parentgroup,$depth,$parentid,$newgroupseq,$id));
                }
                
                
                
				
			}
            //$groupuser['parentidvalue']=$input['groupto'];
           // $groupuserarray = $group_focus->setOneParent($groupuser);
           // $array[$group_focus->group_parent_key] = $groupuserarray[$group_focus->group_parent_key];
           // $grouptreehtml= $group_focus->setGroupChildTree($array[$group_focus->group_parent_key]['children'],'','parentgroup');
            $arr['grouptreehtml']="weweew";
            $arr['parentid']=$input['groupto'];
		}
        else
        {
            $arr['grouptreehtml']="";
        }
   
		//3、删除部门，并更新同级部门groupseq(zkt)
        
        $delresult=$adb->pquery('SELECT parentid FROM ld_groups WHERE groupid = ?;',array($input['delrecord']));
        $delparentid = $adb->query_result($delresult,0,'parentid');
    	$query = 'DELETE FROM ld_groups WHERE groupid = ? and parentid <> -1;';
        $adb->pquery($query,array($input['delrecord']));
        //zkt 更新删除部门同级子部门groupseq
        $upquery = 'select groupid from ld_groups where parentid = '.$delparentid.' order by groupseq;';
        $upresult = $adb->pquery($upquery);
		$num_rows = $adb->num_rows($upresult);
        if($num_rows > 0){
            for($i=0;$i<$num_rows;$i++)
            {
                $groupidnow=$adb->query_result($upresult,$i,'groupid');
                $adb->pquery('update ld_groups set groupseq=? where groupid=?;',array($i+1,$groupidnow));
            }
        }
    }

else if($_REQUEST['hiderecord']&&$_REQUEST['hiderecord']>0)
{
    $input=$_REQUEST;
     
       //获取删除部门的下级html
    $groupuser=$group_focus->getGroupChild($input['hiderecord']);
    $groupids = [];
    foreach($groupuser as $ky=>$content)
    {
        $groupids[]=$content['groupid'];
    }
    if (count($groupids)>0) {
        $sql="select distinct ld_users.id from ld_users INNER JOIN ld_users2group on ld_users2group.userid=ld_users.id ";
        $sql.=" and ld_users2group.groupid in (" .implode(',',$groupids)." ) and `status` = 'Active' ";
        $sql.="where ld_users.id not in (select distinct userid from ld_users2group where groupid not in (".implode(',',$groupids)." ))";
        $result=$adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        $allUser = [];
        for($i=0;$i<$num_rows;$i++){
            $allUser[] = $adb->query_result($result,$i,'id');
        }
        //Frank 隐藏部门自动离职下级成员
        if (count($allUser)>0) {
            $query="update `ld_users` SET `status` = 'Inactive'
            where id in (" .implode(',',$allUser)." ) ";
            $adb->pquery($query,array());
        }

        $query="update ld_groups SET is_hidden ='yes' where groupid in (" .implode(',',$groupids).")";
        $adb->pquery($query,array());
    }




}

//zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数 字段设置保存事件
else if(isset($_REQUEST['departmentNumber'])&&isset($_REQUEST['departmentRemark'])){
    $departmentNumber=$_REQUEST['departmentNumber'];
    $departmentRemark=$_REQUEST['departmentRemark'];
    $sql='update ld_systems_deploy set deploy_value=? where deploy_type=?';
    $result=$adb->pquery($sql,array($departmentNumber,478));
    $sql2='update ld_systems_deploy set deploy_value=? where deploy_type=?';
    $result=$adb->pquery($sql2,array($departmentRemark,477));
    unsetCache('systems_deploy');
    $arr['departmentNumber']=$departmentNumber;
    $arr['departmentRemark']=$departmentRemark;
    ConvertTojsonString(1,$arr,"success");
}
//新增部门
else
{
    if(isPermitted("Users","Create")!='yes')
    {
        ConvertTojsonString("-1",array(),"无新增权限");
    }
    // zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数. 根据字段启用情况做特殊处理
    //启用部门编号字段
    if($isDepartmentNubmer['deploy_value']!='no') {
        $sql_groupno = "select 1 from ld_groups where group_no=?";
        $result_groupno = $adb->pquery($sql_groupno, array($groupno));
        $rows_groupno = $adb->num_rows($result_groupno);
        if ($rows_groupno > 0) {
            ConvertTojsonString("-1", array(), "groupnorepeat");
        }
    }
     $parentid=$_REQUEST['parentid'];

     $_REQUEST['record']=$parentid;
     $group_type = 'crm';
     if($_REQUEST['group_type']){
         $group_type = $_REQUEST['group_type'];
     }
    $related_crmid = 0;
    if($_REQUEST['related_crmid'] && !empty($_REQUEST['related_crmid'])){
        $related_crmid = intval($_REQUEST['related_crmid']);
    }
    $sql='select  parentgroup,depth from ld_groups where groupid=?';
    $result=$adb->pquery($sql,array($parentid));
    $parentgroup=$adb->query_result($result,0,'parentgroup');
    $depth=$adb->query_result($result,0,'depth');
    
    $query = 'SELECT MAX(groupid) AS groupid FROM ld_groups ;';
     $result = $adb->pquery($query,array());
      $rows = $adb->num_rows($result);
		if($rows > 0){
			$groupid = $adb->query_result($result,0,'groupid');
			 ++ $groupid;
		}
    
    $seqsql = 'SELECT MAX(groupseq) AS groupseq FROM ld_groups WHERE parentid=?';
    $result = $adb->pquery($seqsql,array($parentid));
    $rows = $adb->num_rows($result);
    if($rows > 0 ){
        $groupseq = $adb->query_result($result,0,'groupseq');
        ++ $groupseq;
    }
    else{
        $groupseq = 1;
    }
    $sql="insert into ld_groups(groupid,groupname,parentgroup,depth,parentid,description,groupseq,group_no,group_type,related_crmid)value(?,?,?,?,?,?,?,?,?,?)";
    $result = $adb->pquery($sql,array($groupid,$groupname,$parentgroup."::".$groupid,$depth+1,$parentid,$_REQUEST['description'],$groupseq,$groupno,$group_type,$related_crmid));
    $arr['groupid']=$groupid;
}


unsetCache("cache_getgrouplist_array");

$arr['groupname']=$groupname;
$arr['groupno']=$groupno;
ConvertTojsonString(1,$arr,"success");

?>