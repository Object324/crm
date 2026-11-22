<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
global $current_user;


if(isset($_REQUEST['userid']) && $_REQUEST['userid']>0){
    $userid=$_REQUEST['userid'];
}else{
    $userid=$current_user->id;
}

$ScopOfAuthorityobj = new ScopOfAuthority($adb,'TrackLocationMap');
$scopeid = $ScopOfAuthorityobj->getCurUserScopeId();

$smarty = new lingdangCRM_Smarty();
$sql='select  * from ld_users where ifnull(trackgroupid,0)>0  ';
if($scopeid != 'All' && !is_admin($current_user)){
    $sql .= 'and id in ('.$scopeid.')';
}

$result=$adb->pquery($sql,array());
$find_user = 'no';
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $wx_userid=$adb->query_result($result,$i,'wx_userid');
    $last_name=$adb->query_result($result,$i,'last_name');
    $tmpuserid=$adb->query_result($result,$i,'id');
    $userobj=new Users();
    $userobj->last_name=$last_name;
    $userobj->wx_userid=$wx_userid;
    $userobj->id=$tmpuserid;
    $selected = false;
    if($userid == $tmpuserid){
        $find_user = 'yes';
        $selected = true;
    }
    $SmOwner_option_arr[]= array('label'=>getUserlastName($userobj),'value'=>$tmpuserid,'selected'=>$selected);
}
if($find_user == 'no'){
    $userid = '';

}

/*
$sql="select ld_tracklocation.*, from ld_tracklocation inner JOIN (
select max(id) as maxid from ld_tracklocation  where userid in(?) GROUP BY userid 
) as tmp inner join ld_users on ld_users.id=ld_tracklocation.userid  on tmp.maxid=ld_tracklocation.id ";
*/


$sql="select ld_tracklocation.*,ld_users.last_name,ld_users.wx_userid from ld_tracklocation inner join
 ld_users on ld_users.id=ld_tracklocation.userid 
 where ld_users.id=? 
 order by  ld_tracklocation.createdtime desc limit 1";

$result=$adb->pquery($sql,array($userid));

$arr=[];
if($adb->num_rows($result)>0)
{

        $lat=$adb->query_result($result,0,'weidu');
        $lng=$adb->query_result($result,0,'jingdu');
        $tmpuserid=$adb->query_result($result,0,'tmpuserid');
        $address=$adb->query_result($result,0,'address');
        $createdtime=$adb->query_result($result,0,'createdtime');
         $userobj=new Users();
        $userfilepath=$userobj->getUserImage($tmpuserid);
        $arr['address']=$address;
        $arr['createdtime']=$createdtime;
        $arr['lat']=$lat;
        $arr['lng']=$lng;
        $arr['imageurl']=$userfilepath;

        $userobj->id=$tmpuserid;
        $userobj->last_name=$adb->query_result($result,0,'last_name');
        $userobj->wx_userid=$adb->query_result($result,0,'wx_userid');
        $arr['tmpuserid']=$userid;
        $arr['last_name']=getUserlastName($userobj);

}


if($_REQUEST['getposition']&&$_REQUEST['getposition']=='yes' || $_REQUEST['ajax']&&$_REQUEST['ajax']=='yes')
{
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,['list'=>$arr],'success');
}
else
{
    if( $current_user->getHaveSetProfile('') == 'yes'){
        $showeditbtn = 'yes';
    }else{
        $showeditbtn = 'no';
    }

    $smarty->assign("showeditbtn",$showeditbtn);
    $smarty->assign("trackpositionjsonstr",json_encode($arr));
    $smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
    $smarty->assign("nowdate",date("Y-m-d"));
    $smarty->display("TrackLocationMap.tpl");
    //$content=$smarty->fetch("ShowLocationPosition.tpl");

    //$_REQUEST['diony']='yes';
    //ConvertTojsonString(1,['info'=>$arr,'content'=>$content],'success');
}

?>