<?php
//常用报表的打开
$_REQUEST['frommodule']='ReportAnalysis';
$report_name = $_REQUEST['report_name'];
$array = ['checkin_abnormal','checkin_monthly','minusjob_billdetail','dial_record'];

if(empty($_REQUEST['SmOwnerSearchScope'])){
    $_REQUEST['SmOwnerSearchScope'] = 'SmOwner_Search_All';
}
if(in_array($report_name,$array)){
    //checkin_monthly
    include_once globalStatic::$root_directory.'modules/OftenUseReport/index_report.php';
}else{
    include_once globalStatic::$root_directory.'modules/OftenUseReport/newindex.php';
}

