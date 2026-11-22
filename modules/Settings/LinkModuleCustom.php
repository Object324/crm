<?php

global $adb;
global $current_user;
if($current_user->getHaveSetProfile("Settings")!="yes")
{
    exit('请用管理员');
}
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='LinkModuleCustom';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';

if(isset($_REQUEST['mode']) && 'allocate' == $_REQUEST['mode']){
    global $adb;
    $linkmodulecustomid = $_REQUEST['id'];
     $query = 'delete from ld_linkmodulecustom2user where linkmodulecustomid = '.$linkmodulecustomid.' ';
     $adb->pquery($query,array());

    if(isset($_REQUEST['allocatetype']) && $_REQUEST['allocatetype'] != ''){
        $userid = $_REQUEST['userid'];
        $userarr = explode(',', $userid);
		
        if(!empty($userarr)){
            foreach ($userarr as $user) {
                if($user<=0)
                    continue;
                $query = 'insert into ld_linkmodulecustom2user(linkmodulecustomid,userid) values('.$linkmodulecustomid.','.$user.') ';
               
                $adb->pquery($query,array());
            }
        }
    }
   /* if($_REQUEST['allocatetype']==0)
    {
        $scope='all';
    }
    else if($_REQUEST['allocatetype']==1)
    {
        $scope='group';
    }
    else if($_REQUEST['allocatetype']==2)
    {
        $scope='user';
    }
	else if($_REQUEST['allocatetype']==2)
    {
        $scope='user';
    }*/
	$scope = $_REQUEST['allocatetype'];
    $sql='update ld_linkmodulecustom set scope=? where id=?';
    $adb->pquery($sql,array($scope,$linkmodulecustomid));
}

$smarty=new lingdangCRM_Smarty();
//判断是否授权 金蝶云星空库存查询
$regopobj=RegOp::getInstance();
$stock_view = 0;
if(method_exists($regopobj,"geterpstocksearch")){
  $stock_view = $regopobj->geterpstocksearch();
}
$sql='select distinct name,zh_label,en_label,status,allocatepname,id,allocateids,scope,active_icon,url from (
select 
            -1 AS allocateids,ld_linkmodulecustom.id,
            "'.getFixedLabel('ALLTHEUSERS').'" AS allocatepname,
            zh_label,en_label,name,active_icon,
            scope,ld_linkmodulecustom.status,ld_linkmodulecustom.url 
       	  from ld_linkmodulecustom where ld_linkmodulecustom.scope="all"
      	  UNION
          select  
              GROUP_CONCAT(ld_users.id) as allocateids,			
              ld_linkmodulecustom.id,
              GROUP_CONCAT(ld_users.last_name  SEPARATOR "、") as allocatepname,
              zh_label,en_label,name,active_icon,
              scope,ld_linkmodulecustom.status,ld_linkmodulecustom.url 
       		  from ld_linkmodulecustom2user 
       		  inner JOIN ld_users on ld_users.id=ld_linkmodulecustom2user.userid 
              inner JOIN ld_linkmodulecustom
       		  on ld_linkmodulecustom.id=ld_linkmodulecustom2user.linkmodulecustomid  
           where ld_linkmodulecustom.scope="user" GROUP BY  ld_linkmodulecustom2user.linkmodulecustomid
		    UNION
          select  
              GROUP_CONCAT(ld_profile.profileid) as allocateids,			
              ld_linkmodulecustom.id,
              GROUP_CONCAT(ld_profile.profilename  SEPARATOR "、") as allocatepname,
              zh_label,en_label,name,active_icon,
              scope,ld_linkmodulecustom.status,ld_linkmodulecustom.url 
       		  from ld_linkmodulecustom2user 
       		  inner JOIN ld_profile on ld_profile.profileid=ld_linkmodulecustom2user.userid 
              inner JOIN ld_linkmodulecustom
       		  on ld_linkmodulecustom.id=ld_linkmodulecustom2user.linkmodulecustomid  
           where ld_linkmodulecustom.scope="role" GROUP BY  ld_linkmodulecustom2user.linkmodulecustomid
       	   UNION
           select  
                GROUP_CONCAT(ld_groups.groupid) as allocateids,						
                ld_linkmodulecustom.id,
                GROUP_CONCAT(ld_groups.groupname  SEPARATOR "、") as allocatepname,
                zh_label,en_label,name,active_icon,
                scope,ld_linkmodulecustom.status,ld_linkmodulecustom.url 
        		from ld_linkmodulecustom left join  ld_linkmodulecustom2user 
                on ld_linkmodulecustom.id=ld_linkmodulecustom2user.linkmodulecustomid  
        		left  JOIN ld_groups on ld_groups.groupid=ld_linkmodulecustom2user.userid 
        		
                where ld_linkmodulecustom.scope="group" GROUP BY  ld_linkmodulecustom2user.linkmodulecustomid)
                AS alldata
        WHERE status="yes"  order by id desc
';
$result=$adb->pquery($sql,array());
$rows=$adb->num_rows($result);

for($i=0;$i<$rows;$i++)
{
    $zh_label=$adb->query_result($result,$i,'zh_label');
    $en_label=$adb->query_result($result,$i,'en_label');
    $allocatename=$adb->query_result($result,$i,'allocatepname');
    $id=$adb->query_result($result,$i,'id');
    $scope=$adb->query_result($result,$i,"scope");
    $active_icon=$adb->query_result($result,$i,"active_icon");
    $active_icon = empty($active_icon)?'':$active_icon.'?a='.rand(0,9999);
    $allocateids=$adb->query_result($result,$i,'allocateids');
    $url=$adb->query_result($result,$i,'url');
    //金蝶云星空库存查询（PC）
    if(strpos(strtolower($url),'file=stock_report') !== false){
        if($stock_view != 1){
          continue;
        }
    }
    
    $scopeType=0;
    if($scope=='all')
    {
        $scopeType=0;
    }
    else if($scope=='user')
    {
        $scopeType=2;
		$allocatename = getUserName($allocateids);
    }
	else if($scope=='role')
    {
        $scopeType=3;
    }
    else if($scope=='group')
    {
        $scopeType=1;
		$allocatename = getGroupNameCustom($allocateids);
    }
    $list[]=array(
        'sequence'=>$i+1,
        'zh_label'=>$zh_label,
        'en_label'=>$en_label,
        'allocatename'=>$allocatename,
        'id'=>$id,
        'scope'=>$scope,
        'allocateids'=>$allocateids,
        'scopetype'=>$scopeType,
        'active_icon'=>$active_icon);
}

$smarty->assign("List",$list);
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='yes';
$arr=array();
if($_REQUEST['ajax']=='yes')
{
    $arr['content']=$smarty->fetch("Settings/LinkModuleCustomListContent.tpl");
}
else
{
    $arr['content']=$smarty->fetch("Settings/LinkModuleCustomList.tpl");
}
ConvertTojsonString(1,$arr,"success");

function getUserName($ids){
	global $adb;
	$query = 'select last_name,wx_userid from ld_users where id in ('.$ids.')';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows > 0){
		$userobj=new Users();
		$data = array();
		for($i = 0; $i < $num_rows; $i++){
			$last_name = $adb->query_result($result,$i,'last_name');
			$wx_userid = $adb->query_result($result,$i,'wx_userid');
			$userobj->wx_userid=$wx_userid;
			$userobj->last_name=$last_name;
			$data[] = getUserlastName($userobj);
		}
		return implode('、',$data);
	}
	return '';
}

function getGroupNameCustom($ids){
	global $adb;
	$query = 'select groupid,groupname from ld_groups where groupid in ('.$ids.')';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows > 0){
		require_once( 'modules/Users/Group.class.php');
		$groupobj=new Group();
		$data = array();
		for($i = 0; $i < $num_rows; $i++){
			$groupid = $adb->query_result($result,$i,'groupid');
			$groupname = $adb->query_result($result,$i,'groupname');
			$groupobj->groupid=$groupid;
			$groupobj->groupname=$groupname;
			$data[] = getWx_GroupName($groupobj);
		}
		return implode('、',$data);
	}
	return '';
}
?>