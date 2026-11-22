<?php
//ls 20221111 XUQIU1000848  普罗定制开发表单特殊带入需求(日常费用报销单)
global $adb,$current_user,$currentModule;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');


//新建日常费用报销单CustomForm26、私车公用报销单CustomForm25时，分录获取优马工作日报CustomForm23、耕道工作日报CustomForm22
if(isset($_REQUEST['selectmodule'])&&isset($_REQUEST['idstring'])) {
    $selectModule = $_REQUEST['selectmodule'];
    $select_focus=CRMEntity::getInstance($selectModule);
    $recordstr = rtrim($_REQUEST['idstring'],",");

//    $frommodule=$_REQUEST['module'];
//    $fromfocus=CRMEntity::getInstance($frommodule);
//	$version_info = getVersionInfo();

    $records_arr = explode(',',$recordstr);
    $records_arr = array_unique($records_arr);
    $recordstr = implode(',',$records_arr);

    $data = [];
    if ($selectModule == 'CustomForm23') {//优马
        $query = "SELECT distinct ld_customform23.customform23_no,ld_customform23.customform23id,ld_customform23scf.cf_5433,ld_customform23scf.cf_5435,
ld_customform23detailscf.sf345,ld_customform23detailscf.sf306,
ld_customform23detailscf.sf307,ld_customform23detailscf.sf308,
ld_customform23detailscf.sf309,ld_customform23detailscf.sf310,
ld_customform23detail.remark,ld_customform23detailscf.sf491,ld_customform23detailscf.sf492,ld_customform23detailscf.sf497
FROM ld_customform23 
left join ld_customform23scf on ld_customform23scf.customform23id = ld_customform23.customform23id 
left join ld_customform23detail on ld_customform23detail.id=ld_customform23.customform23id 
left join ld_customform23detailscf on ld_customform23detailscf.lineitem_id = ld_customform23detail.lineitem_id 
WHERE ld_customform23.customform23id in($recordstr) AND ld_customform23.deleted = 0
ORDER BY field(ld_customform23.customform23id,$recordstr)";
        $result = $adb->pquery($query, array());

        if($adb->num_rows($result) >= 1)
        {
            while($result_set = $adb->fetch_array($result))
            {
                $tmp['recordid'] = $result_set['customform23id'];
                $tmp['recordino'] = $result_set['customform23_no'];
                $tmp['cf_5433'] = $result_set['cf_5433'];
                $tmp['cf_5435'] = $result_set['cf_5435'];
                $tmp['sf345'] = $result_set['sf345'];
                $tmp['sf306'] = number_format($result_set['sf306'],2);
                $tmp['sf307'] = number_format($result_set['sf307'],2);
                $tmp['sf308'] = number_format($result_set['sf308'],2);
                $tmp['sf309'] = number_format($result_set['sf309'],2);
                $tmp['sf310'] = number_format($result_set['sf310'],2);
                $tmp['remark'] = $result_set['remark'];
                $tmp['sf491'] = number_format($result_set['sf491'],2);
                $tmp['sf492'] = number_format($result_set['sf492'],2);
                $tmp['sf497'] = $result_set['sf497'];

                $data[]=$tmp;
            }
        }
    }
    elseif ($selectModule == 'CustomForm22') {//耕道
        $query = "SELECT distinct ld_customform22.customform22_no,ld_customform22.customform22id,ld_customform22scf.cf_5307,ld_customform22scf.cf_5309,
ld_customform22detailscf.sf346,ld_customform22detailscf.sf299,
ld_customform22detailscf.sf298,ld_customform22detailscf.sf300,
ld_customform22detailscf.sf301,ld_customform22detailscf.sf302,
ld_customform22detail.remark,ld_customform22detailscf.sf494,ld_customform22detailscf.sf495,ld_customform22detailscf.sf498
FROM ld_customform22 
left join ld_customform22scf on ld_customform22scf.customform22id = ld_customform22.customform22id 
left join ld_customform22detail on ld_customform22detail.id=ld_customform22.customform22id 
left join ld_customform22detailscf on ld_customform22detailscf.lineitem_id = ld_customform22detail.lineitem_id 
WHERE ld_customform22.customform22id in($recordstr) AND ld_customform22.deleted = 0
ORDER BY field(ld_customform22.customform22id,$recordstr)";
        $result = $adb->pquery($query, array());

        if($adb->num_rows($result) >= 1)
        {
            while($result_set = $adb->fetch_array($result))
            {
                $tmp['recordid'] = $result_set['customform22id'];
                $tmp['recordino'] = $result_set['customform22_no'];
                $tmp['cf_5307'] = $result_set['cf_5307'];
                $tmp['cf_5309'] = $result_set['cf_5309'];
                $tmp['sf346'] = $result_set['sf346'];
                $tmp['sf299'] = number_format($result_set['sf299'],2);
                $tmp['sf298'] = number_format($result_set['sf298'],2);
                $tmp['sf300'] = number_format($result_set['sf300'],2);
                $tmp['sf301'] = number_format($result_set['sf301'],2);
                $tmp['sf302'] = number_format($result_set['sf302'],2);
                $tmp['remark'] = $result_set['remark'];
                $tmp['sf494'] = number_format($result_set['sf494'],2);
                $tmp['sf495'] = number_format($result_set['sf495'],2);
                $tmp['sf498'] = $result_set['sf498'];
                $data[]=$tmp;
            }
        }
    }

    $_REQUEST['diony'] = 'diony';
    ConvertTojsonString(1,$data,'success');


/*    $len=sizeof($prod_arr);

    $tmparr['data']=$prod_arr;
    $tmparr['datalen']=$len;

    @ob_clean();
    @ob_flush();
	$jsonentity = Zend_Json::encode($prod_arr);

	echo $jsonentity;exit();*/
}else{
    ConvertTojsonString(-1,array(),'success');
}
