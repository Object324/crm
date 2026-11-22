<?php
//@edit:liushuai,2020-09-02,reason:【ID1001055】/销售线索增加审批功能(只有审批通过后才能继续升级流程),(升级时查询审批是否已批准)
global $adb;
$_REQUEST['diony']='yes';
$record = $_REQUEST['record'];
//wym 目前只能选择客户和商机 如果两个一起选择 不用该参数
$mapmodule_str = $_REQUEST['mapmodule'];
$mapmodule_arr=explode(':',$mapmodule_str);
if(count($mapmodule_arr) > 1){
    $arr['modulename'] = '"'.getTranstab($mapmodule_arr[0]).'"'.getFixedLabel('AND').'"'.getTranstab($mapmodule_arr[1]).'"';
}else{
    $arr['modulename'] = '"'.getTranstab($mapmodule_arr[0]).'"';
}

if(getSys_deploy(260)['deploy_value'] == 1){  //未开启不用判断是否已审批
    ConvertTojsonString(1,$arr,"success");
}
if(isset($record) && !empty($record)){
    $sql = 'select approvestatus from ld_leads  where leadsid=? ';
    $result = $adb->pquery($sql,array((int)$record));
    if($adb->num_rows($result)>0)
    {
        $approvestatus = $adb->query_result($result, 0, 'approvestatus');
        if ($approvestatus == constant('D_A_S_APPROVED')) {
            ConvertTojsonString(1,$arr,"success");
        }else if($approvestatus == constant('D_A_S_REJECTED') || $approvestatus == constant('D_A_S_DISMISSED')){
            ConvertTojsonString(-2,$arr,"error");
        }
    }
}
ConvertTojsonString(-1,$arr,"error");


?>