<?php
//ls 20221111 XUQIU1000848  普罗定制开发表单特殊带入需求(私车公用报销单)
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
    if ($selectModule == 'CustomForm23') {//私车公用报销单 选 优马
        $query = "SELECT distinct ld_customform23.customform23_no,ld_customform23.customform23id,ld_customform23scf.cf_5433,ld_customform23scf.cf_5435,ld_customform23scf.cf_5436,
ld_customform23detailscf.sf448,ld_customform23detailscf.sf449,ld_customform23detailscf.sf450,ld_customform23detail.remark
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
                $tmp['cf_5433'] = $result_set['cf_5433'];//日期
                $tmp['cf_5435'] = $result_set['cf_5435'];//起讫地点
                $tmp['cf_5436'] = $result_set['cf_5436'];//里程记录
                $tmp['sf448'] = number_format($result_set['sf448'],2);//路桥费
                $tmp['sf449'] = number_format($result_set['sf449'],2);//停车费
                $tmp['sf450'] = number_format($result_set['sf450'],2);//补贴标准
                $tmp['remark'] = $result_set['remark'];//备注

                $data[]=$tmp;
            }
        }
    }
    elseif ($selectModule == 'CustomForm22') {//私车公用报销单 选 耕道
        $query = "SELECT distinct ld_customform22.customform22_no,ld_customform22.customform22id,ld_customform22scf.cf_5307,ld_customform22scf.cf_5309,ld_customform22scf.cf_5310,
ld_customform22detailscf.sf453,ld_customform22detailscf.sf454,ld_customform22detailscf.sf452,ld_customform22detail.remark
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
                $tmp['cf_5310'] = $result_set['cf_5310'];
                $tmp['sf453'] = number_format($result_set['sf453'],2);
                $tmp['sf454'] = number_format($result_set['sf454'],2);
                $tmp['sf452'] = number_format($result_set['sf452'],2);
                $tmp['remark'] = $result_set['remark'];

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
