<?php
/**
 * 公海客户类型转换
 * User: chj
 * Date: 2018-03-01
 */
crm_load_class_file("cls_ConvertAccount", 'modules/Accounts');
$transfer=$_REQUEST['transfer'];	//公海转换  转移到公海：transfer_to，转移出公海（转为普通客户）：transfer_out
$pool_id = $_REQUEST['select_pool_id'];
$cls_ConvertAccount = new cls_ConvertAccount('Accounts',$transfer,$pool_id);

if(isset($_REQUEST['record'])){
  
	$data = $cls_ConvertAccount->setConvertAccount_more($_REQUEST['record']);
	if(isset($_SESSION['lvs']['Accounts']['viewname'])){
		$viewid = $_SESSION['lvs']['Accounts']['viewname'];
		$start = $_SESSION['lvs']['Accounts'][$viewid]['start'];
	}
   
	if(!$start) $start = 1;
	$entity['log']['value'] = "<div class='pop_prc_content'>".$data['log']."</div>";//批量处理信息
	$entity['title']['value'] = $data['title'];
	$entity['start']['value'] = $start;//当前页数
	$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
	$entity['error_num']['value'] = $data['error'];
	//echo "###$countsuccess####";//exit();

    if($_REQUEST['types']=='Account_deatil_view')
    {
         
		$_REQUEST['diony']='diony';
		$arr['refreshdetailmodules'] = array('Accounts');
		ConvertTojsonString(1,$arr,"success");
       //add lmx 20140214  转公海或者转普通后跳转回客户明细界面
       //header("Location: index.php?module=Accounts&parenttab=Parent Accounts&action=DetailView&record=".$_REQUEST['record']);
    }
    else
    {
   
			$jsonentity = json_encode($entity);
        	echo $jsonentity;die;
      // header("Location: index.php?module=Accounts&action=ListView&parenttab=Parent Accounts$rstart&SearchScope=$SearchScope&pagepublicaccounttype=$accounttype");
    }
}elseif($_REQUEST['idstring']){
    
	$data = $cls_ConvertAccount->setConvertAccount_more($_REQUEST['idstring']);
	$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
	$submitlog = sprintf($submitlog,$data['mass_convert_totalrows'],$data['success'],$data['error']);
	$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
	if(isset($_SESSION['lvs']['Accounts']['viewname'])){
		$viewid = $_SESSION['lvs']['Accounts']['viewname'];
		$start = $_SESSION['lvs']['Accounts'][$viewid]['start'];
	}
	if(!$start) $start = 1;
	$entity['log']['value'] = $submitlog."<div class='pop_prc_content'>".$data['log']."</div>";//批量处理信息
	$entity['title']['value'] = $data['title'];
	$entity['start']['value'] = $start;//当前页数
	$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
	//echo "###$countsuccess####";//exit();

	$jsonentity = json_encode($entity);
	echo $jsonentity;die;
}
?>