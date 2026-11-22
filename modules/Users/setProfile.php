<?php


if(isset($_REQUEST['ajax']) && isset($_REQUEST['select'])){
    $profile = new Profile();
    $profileinfo=$profile->getProfileArray();
    //$SQL = "SELECT viewothers,editothers,delothers,viewselfbills,edit_other_mobile,is_mobile_style,profileid FROM ld_users WHERE id=?;";
   // $query = $adb->pquery($SQL,array($_REQUEST['userid']));
        $userscope['viewothers']=0;
        $userscope['editothers']=0;
        $userscope['delothers']=0;
        $userscope['viewselfbills']=0;
		$userscope['edit_other_mobile']=0;
		$userscope['is_mobile_style']=0;
		$userscope['profileid']=0;
        $userLevel=array();
	/*$query = 'select userlevel from ld_userlevel';
	$result = $adb->pquery($query,array());
	for($i = 0; $i<$adb->num_rows($result); $i++){
		$userLevel[$adb->query_result($result,$i,'userlevel')] = $adb->query_result($result,$i,'userlevel');
	}*/
	$selectarray = array(
			'profileid'=>$profileinfo,
			'is_admin'=>array('on'=>getFixedLabel('YES'),'off'=>getFixedLabel('NO')),
			'status'=>array('Active'=>getFixedLabel('ACTIVATE'),'Inactive'=>getFixedLabel('INACTIVATE')),
			'userlevel'=>$userLevel,
		);
	//$selectids = $_REQUEST['selectids'];
    
    $returnarray['selectarray']=$selectarray['profileid'];
    $returnarray['userscope']=$userscope;
    $returnarray['permitted']=isPermitted("Users",'AllowSetRoleDataProfile');
	$selectjason = json_encode($returnarray);
	echo $selectjason;
	die;
}

?>