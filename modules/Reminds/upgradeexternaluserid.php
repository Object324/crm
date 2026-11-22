<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);

$root_dir= dirname(dirname(dirname(__FILE__)));

global $adb;
date_default_timezone_set('Asia/Shanghai');
require_once($root_dir.'/includefile.php');
require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
$server_api = 'http://www.51mis.cn/weixin/webapi/weixinapi_v5/server/server.php';
$server_api = 'http://www.51mis.cn/webapi/weixinapi_v5/server/server.php';
$weixinportobj=new cls_WeixinPort();
$auto_info_json = doCorpInfo('get_auth_info','');
$info_arr = json_decode($auto_info_json, true);
$crm_auth = $info_arr[StaticConst::$suite_crm];
if(!empty($crm_auth)) {
    $corpindex = $crm_auth['corpindex'];
    $corpid = $crm_auth['auth_corp_info']['corpid'];
   
}else{
    exit();
}
$sessiontime=$_REQUEST['sessiontime'];
$limitcount=$_REQUEST['limitcount'];
$sessiontime.='_'.$corpindex;
$sessiontime=md5($sessiontime);
$url = $server_api . '?action=checksessiontime&sessiontime='.$sessiontime;
//$weixinportobj->primary_get($url);


$adb=PearDatabase::getInstance();
if(!file_exists($root_dir.'/user_privileges/externalstart.txt'))
{
    
   
   $tmpcorpindex=0;
   
   
}
else{
    $tmpcorpindex=file_get_contents($root_dir.'/user_privileges/externalstart.txt');
}
 if($tmpcorpindex!=$corpindex){
    
     $sql=" insert into ld_upgrade_external_userid(contactid,external_userid,upgrade) select  contactid,weixin_external_userid,'no'  from ld_contactdetails where ifnull(weixin_external_userid,'')<>'' ";
    $adb->pquery($sql);
    
}
file_put_contents($root_dir.'/user_privileges/externalstart.txt',$corpindex);
if(empty($limitcount))
{
    $limitcount=150;
}
$sql='select * from ld_upgrade_external_userid where upgrade="no" order by id desc limit  '.$limitcount;
  
$result=$adb->pquery($sql,array());
$rows=$adb->num_rows($result);

$externaluserid_arr=[];
$externaluserid_contactid_arr=[];
for($i=0;$i<=$rows;$i++)
{
    $externaluserid=$adb->query_result($result,$i,'external_userid');
    
    $externaluserid_arr[]=$externaluserid;
    $externaluserid_contactid_arr[$externaluserid]=$adb->query_result($result,$i,'contactid');
    
}
if($rows<=0)
{
    $url = $server_api . '?action=setConvertExternalfinished&sessiontime='.$sessiontime.'&corpindex='.$corpindex;
    
    $info= $weixinportobj->curlSend($url,array());
    dump($info);

}
$data['external_userid_list']=json_encode($externaluserid_arr);

$url = $server_api . '?action=getNewExternalUserid&sessiontime='.$sessiontime.'&corpindex='.$corpindex;

$new_external_userid= $weixinportobj->curlSend($url,$data);

$new_external_userid_arr=json_decode($new_external_userid,true);
if(empty($new_external_userid_arr['result']['items']))
{
	
	foreach($externaluserid_arr as $externid)
	{
		 $sql='update ld_upgrade_external_userid set upgrade=? ,upgradedatetime=? where external_userid=?';
     
		$adb->pquery($sql,array("yes",date("Y-m-d H:i:s"),$externid));
	}
}
foreach($new_external_userid_arr['result']['items'] as $info)
{
     $old_external_userid=$info['external_userid'];
     $new_external_userid=$info['new_external_userid'];
     $contactid=$externaluserid_contactid_arr[$old_external_userid];
     $sql='update ld_contactdetails set weixin_external_userid =? where contactid=?';
     $adb->pquery($sql,array($new_external_userid,$contactid));
     $sql='update ld_external_contact set weixin_external_userid =? where weixin_external_userid=? ';
     $adb->pquery($sql,array($new_external_userid,$old_external_userid));
      $sql='update ld_upgrade_external_userid set upgrade=? ,upgradedatetime=? where external_userid=?';
     
     $adb->pquery($sql,array("yes",date("Y-m-d H:i:s"),$old_external_userid));
    
      
}


?>