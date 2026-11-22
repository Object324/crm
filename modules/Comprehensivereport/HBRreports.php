<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings;
require_once('include/utils/UserInfoUtil.php');
$smarty=new lingdangCRM_Smarty();
//echo $_REQUEST['search_text'];
if(isset($_REQUEST['year']) && isset($_REQUEST['month']))
{
    if(is_int(intval($_REQUEST['year']))==false)
    {
        echo '报表年份错误！';
        exit();
    }
    
    if(intval($_REQUEST['year'])>date('Y'))
    {
        echo '报表年份错误！';
        exit();
    }
    if(intval($_REQUEST['month'])<0 ||intval($_REQUEST['month'])>12)
    {
        echo '报表月份错误！';
        exit();
    }
    
    $year = $_REQUEST['year'];
    $month = $_REQUEST['month'];
}


if(isset($_REQUEST['begin_date']) && isset($_REQUEST['end_date'])){
    $begin_date = $_REQUEST['begin_date'];
    $end_date = $_REQUEST['end_date'];
}


if(!isset($_REQUEST['begin_date']) && !isset($_REQUEST['end_date'])){
    $year = $_REQUEST['year'];
    $month = $_REQUEST['month'];
    //判断为年度表
    if($month == "0")
    {
        $begin_month = "1";
        $end_month = "12";
    }
    else
    {
        $begin_month = $month;
        $end_month = $month;
    }
    
        //判断2月是否是闰年
       if ($_REQUEST['year']%4==0 && ($_REQUEST['year']%100!=0 || $_REQUEST['year']%400==0))
       {
        //是闰年
        $monthday = "1";
       }
       else
       {
        //不是闰年
        $monthday = "2";
       }
	
    $begin_date = "";
    $begin_date = "".$year."-".formatMonth($begin_month)."-01";  
    $end_date = "";
    $lastday=getthemonth($year."-".$end_month.'-1');
    $arrlastday=explode('-',$lastday);
    $lastday=$arrlastday[2];
    $end_date = "".$year."-".formatMonth($end_month)."-".$lastday;
}

if(isset($_REQUEST['rolename'])&&$_REQUEST['rolename']<>'all'){
    $roles = $_REQUEST['rolename'];
    $sql = "SELECT roleid FROM ld_role WHERE depth<>0 AND parentrole LIKE '%$roles%';";
    $result=$adb->pquery($sql,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $roleid[$i] = $adb->query_result($result, $i, 'roleid');
    }
    
}else{
    $uid = $current_user->id;
    $sql = "SELECT ld_user2role.roleid FROM ld_role 
LEFT JOIN ld_user2role ON ld_role.roleid = ld_user2role.roleid 
WHERE userid <> '' AND userid =$uid GROUP BY ld_role.roleid";
    $result=$adb->pquery($sql,array());
    $urole = $adb->query_result($result, 0, 'roleid');
    
    $sql = "SELECT roleid FROM ld_role WHERE depth<>0 AND parentrole LIKE '%$urole%';";
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {      
        $roleid[$i] = $adb->query_result($result, $i, 'roleid');
    }
}
//$roleList = getAllRoleDetails();
$profile_focus = Profile::getInstance();
$roleDetails = $profile_focus->getProfileArray();
array_shift($roleDetails);
unset($roleList['H1']);
$usersList = getRoleList();
$AccountNumber = getAccountNumber($usersList['SearchScope'],$begin_date,$end_date,$roleid);
$rolesNameList = getRolesName($current_user->id);

//print_r($usersList);

//print_r($roleList);
$fg=0;
foreach($roleList as $key=>$arr){
    foreach($AccountNumber as $key2=>$arr2){
        if($key==$key2){
           $roleList[$key]['arrs'][$key2] = $arr2;
           $roleList[$key]['arrs'][$key2]['gcount'] = $fg;
           $fg++;
        }
    }
}
foreach($roleList as $key=>$arr){
        if(!isset($arr['arrs'])){
            unset($roleList[$key]);
        }
}

//搜索条件下拉
function getRolesName($uid){
    global $adb;
    $selqq = 'SELECT roleid FROM ld_user2role WHERE userid='.$uid;
     $resulta=$adb->pquery($selqq,array());
     $roleid1 = $adb->query_result($resulta, 0, 0);
    // echo $selqq;echo "<br>";
    $sql = "SELECT
	ld_user2role.roleid,
	rolename
FROM
	ld_role
LEFT JOIN ld_user2role ON ld_role.roleid = ld_user2role.roleid
WHERE
	userid <> '' AND parentrole LIKE '%".$roleid1."%' 
AND depth>=(SELECT depth FROM ld_role WHERE roleid='$roleid1')
GROUP BY
	ld_role.roleid;";
//echo $sql;
    $result=$adb->pquery($sql,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $roleid = $adb->query_result($result, $i, 'roleid');
        $rolesNameList[$roleid] = $adb->query_result($result, $i, 'rolename');
    }
    return $rolesNameList;
    
}

//显示当前账号可见userid
function getRoleList(){
    global $adb;
    $MergeSmowner=getCurSmOwnerSearchScope('Accounts');
    $UserArr = $MergeSmowner['UserCombo'];
    unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
    $Smownerids= getCurSmOwnerSearchScope('Potentials');
    $SearchScope="";
    foreach($Smownerids['UserCombo']as $userid=>$userinfo)
    {
        if($SearchScope == "")
        {
            $SearchScope .=$userid; 
        }
        else
        {
            $SearchScope .=",".$userid; 
        }	
                
    }
   // echo $SearchScope;
    $sql = 'SELECT userid,last_name,roleid FROM ld_user2role 
INNER JOIN ld_users ON ld_user2role.userid = ld_users.id  WHERE userid in ('.$SearchScope.');';
    $result=$adb->pquery($sql,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $userid = $adb->query_result($result, $i, 'userid');
        $userList['user'][$userid]['roleid'] = $adb->query_result($result, $i, 'roleid');
        $userList['user'][$userid]['uname'] = $adb->query_result($result, $i, 'last_name');
    }
    $userList['SearchScope']=$SearchScope;
    return $userList;
}

//主搜索方法
function getAccountNumber($SearchScope,$begin_date,$end_date,$roleid){
        global $adb;
      //  print_r($roleid);
       $roleid = "'".implode("','",$roleid)."'";  
    $SQL = "SELECT yy.roleid,rolename,SUM(yy.KeHuBaiFangLiang) AS KeHuBaiFangLiang,SUM(yy.XinZengKeHuLiang) AS XinZengKeHuLiang,
SUM(yy.XinKeHuChengJiaoLiang) AS XinKeHuChengJiaoLiang,
SUM(yy.XinKeHuChengJiaoEn) AS XinKeHuChengJiaoEn,
SUM(yy.XinKeHuCengJiaoEnZhanBi) AS XinKeHuCengJiaoEnZhanBi,
SUM(yy.LaoKeHuChengJiaoLiang) AS LaoKeHuChengJiaoLiang,
SUM(yy.LaoKeHuChengJiaoEn) AS LaoKeHuChengJiaoEn,
SUM(yy.ZongChengJiaoLiang) AS ZongChengJiaoLiang,
SUM(yy.ZongChengJiaoEn) AS ZongChengJiaoEn 
FROM (SELECT 	roleid,
 id,
 IFNULL(KeHuBaiFangLiang, 0) AS KeHuBaiFangLiang,
 IFNULL(XinZengKeHuLiang, 0) AS XinZengKeHuLiang,
	IFNULL(XinKeHuChengJiaoLiang, 0) AS XinKeHuChengJiaoLiang,
	IFNULL(XinKeHuChengJiaoEn, 0) AS XinKeHuChengJiaoEn,
	ROUND(
  IFNULL(
			IFNULL(XinKeHuChengJiaoEn, 0) * 100 / IFNULL(ZongChengJiaoEn, 0),
			0
		),
		2
	) AS XinKeHuCengJiaoEnZhanBi,
	IFNULL(LaoKeHuChengJiaoLiang, 0) AS LaoKeHuChengJiaoLiang,
	IFNULL(LaoKeHuChengJiaoEn, 0) AS LaoKeHuChengJiaoEn,
	IFNULL(ZongChengJiaoLiang, 0) AS ZongChengJiaoLiang,
	IFNULL(ZongChengJiaoEn, 0) AS ZongChengJiaoEn
FROM
	ld_users
LEFT JOIN (
	SELECT
		SUM(count) AS KeHuBaiFangLiang,
		smownerid
	FROM
		(
			SELECT
				count(DISTINCT ld_account.accountid) AS count,
				ld_account.smownerid
			FROM
				ld_activity
                LEFT JOIN ld_account ON ld_activity.accountid = ld_account.accountid 
			WHERE
				ld_activity.deleted = 0 AND ld_activity.accountid<>0 
			AND date_start BETWEEN '$begin_date'
			AND '$end_date'
			GROUP BY
				ld_account.smownerid
			UNION
				SELECT
					count(DISTINCT ld_contactrecords.accountid) AS KeHuBaiFangLiang,
					ld_account.smownerid
				FROM
					ld_contactrecords
				LEFT JOIN ld_account ON ld_account.accountid=ld_contactrecords.accountid                     
				WHERE
					ld_contactrecords.deleted = 0 AND ld_contactrecords.accountid<>0 
				AND contactDate BETWEEN '$begin_date'
				AND '$end_date' AND ld_account.accountid NOT IN (
 			        SELECT
				    accountid
			         FROM
				        ld_activity
			         WHERE
				        deleted = 0 
			             AND date_start BETWEEN '$begin_date'
			             AND '$end_date'
                    )
				GROUP BY
					ld_account.smownerid
		) AS c
	GROUP BY
		smownerid
) AS F1 ON ld_users.id = F1.smownerid
LEFT JOIN (
	SELECT
		COUNT(accountid) AS XinZengKeHuLiang,
		smcreatorid
	FROM
		ld_account
	WHERE
		account_type <> '招商客户'
	AND deleted = 0
	AND createdtime BETWEEN '$begin_date'
	AND '$end_date'
	GROUP BY
		smcreatorid
) AS F2 ON F2.smcreatorid = ld_users.id
LEFT JOIN (
	SELECT
		SUM(total) AS XinKeHuChengJiaoEn,
		COUNT(
			DISTINCT ld_salesorder.accountid
		) AS XinKeHuChengJiaoLiang,
		g.smcreatorid
	FROM
		ld_salesorder
	LEFT JOIN (
		SELECT
			accountid,
			smcreatorid
		FROM
			ld_account
		WHERE
			account_type <> '招商客户'
		AND deleted = 0
		AND createdtime BETWEEN '$begin_date'
		AND '$end_date'
	) AS g ON g.accountid = ld_salesorder.accountid
	WHERE
		deleted = 0
	AND sostatus <> '已作废'
	AND ld_salesorder.accountid IN (
		SELECT
			accountid
		FROM
			ld_account
		WHERE
			account_type <> '招商客户'
		AND deleted = 0
		AND createdtime BETWEEN '$begin_date'
		AND '$end_date'
	)
	AND signed_data BETWEEN '$begin_date'
	AND '$end_date'
	GROUP BY
		g.smcreatorid
) AS F3 ON ld_users.id = F3.smcreatorid
LEFT JOIN (
	SELECT
		SUM(total) AS LaoKeHuChengJiaoEn,
		COUNT(
			DISTINCT ld_salesorder.accountid
		) AS LaoKeHuChengJiaoLiang,
		g.smcreatorid
	FROM
		ld_salesorder
	LEFT JOIN (
		SELECT
			accountid,
			smcreatorid
		FROM
			ld_account
		WHERE
			account_type <> '招商客户'
		AND deleted = 0
		AND createdtime <= '$begin_date'
	) AS g ON g.accountid = ld_salesorder.accountid
	WHERE
		deleted = 0
	AND sostatus <> '已作废'
	AND ld_salesorder.accountid NOT IN (
		SELECT
			accountid
		FROM
			ld_account
		WHERE
			account_type <> '招商客户'
		AND deleted = 0
		AND createdtime >= '$begin_date'
	)
	AND signed_data BETWEEN '$begin_date'
	AND '$end_date'
	GROUP BY
		g.smcreatorid
) AS F4 ON ld_users.id = F4.smcreatorid
LEFT JOIN (
	SELECT
		SUM(total) AS ZongChengJiaoEn,
		COUNT(
			DISTINCT ld_salesorder.accountid
		) AS ZongChengJiaoLiang,
		g.smcreatorid
	FROM
		ld_salesorder
	LEFT JOIN (
		SELECT
			accountid,
			smcreatorid
		FROM
			ld_account
		WHERE
			account_type <> '招商客户'
		AND deleted = 0
	) AS g ON g.accountid = ld_salesorder.accountid
	WHERE
		deleted = 0
	AND sostatus <> '已作废'
	AND ld_salesorder.accountid IN (
		SELECT
			accountid
		FROM
			ld_account
		WHERE
			account_type <> '招商客户'
		AND deleted = 0
	)
	AND signed_data BETWEEN '$begin_date'
	AND '$end_date'
	GROUP BY
		g.smcreatorid
) AS F5 ON ld_users.id = F5.smcreatorid 
LEFT JOIN ld_user2role ON userid=id 
WHERE  roleid in ($roleid) ) AS yy  
 LEFT JOIN ld_role ON yy.roleid=ld_role.roleid 
GROUP BY roleid;";
//echo $SQL;
    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {        
        $userid = $adb->query_result($result, $i, 'roleid');
        $userNumberList[$userid]['rolename'] = $adb->query_result($result, $i, 'rolename');
        $userNumberList[$userid]['KeHuBaiFangLiang'] = $adb->query_result($result, $i, 'kehubaifangliang');
        $userNumberList[$userid]['XinZengKeHuLiang'] = $adb->query_result($result, $i, 'xinzengkehuliang');
        $userNumberList[$userid]['XinKeHuChengJiaoLiang'] = $adb->query_result($result, $i, 'xinkehuchengjiaoliang');
        $userNumberList[$userid]['XinKeHuChengJiaoEn'] = number_format($adb->query_result($result, $i, 'xinkehuchengjiaoen'),2);
        $userNumberList[$userid]['XinKeHuCengJiaoEnZhanBi'] = $adb->query_result($result, $i, 'xinkehucengjiaoenzhanbi')."%";
        $userNumberList[$userid]['LaoKeHuChengJiaoLiang'] = $adb->query_result($result, $i, 'laokehuchengjiaoliang');
        $userNumberList[$userid]['LaoKeHuChengJiaoEn'] = number_format($adb->query_result($result, $i, 'laokehuchengjiaoen'),2);
        $userNumberList[$userid]['ZongChengJiaoLiang'] = $adb->query_result($result, $i, 'zongchengjiaoliang');
        $userNumberList[$userid]['ZongChengJiaoEn'] = number_format($adb->query_result($result, $i, 'zongchengjiaoen'),2);
    }
    //print_r($userNumberList);
    return $userNumberList;
}

function formatMonth($month)
{
    if($month<10){
        $month='0'.$month;
    }
    return $month;
}
function getthemonth($date)
{
$firstday = date('Y-m-01', strtotime($date));
$lastday = date('Y-m-d', strtotime("$firstday +1 month -1 day"));
return $lastday;
}

//print_r($salesList['slist']);
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);
$smarty->assign("rolenames",$_REQUEST['rolename']);
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$smarty->assign("roleList",$roleList);
$smarty->assign("rolename",$rolesNameList);
$smarty->display('Comprehensivereport/HBRreports.tpl');
exit();
?>