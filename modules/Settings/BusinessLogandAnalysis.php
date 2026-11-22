<?php
global $languageType,$smarty;
$mode = $_REQUEST['mode'];
$smarty = new lingdangCRM_Smarty;
crm_load_class_file('cls_BusinessInformation', 'modules/Users');
if(isset($mode)&&$mode == 'showbusinesslogdetail'){
    $searchdate = $_REQUEST['searchdate'];
    $selectedoperator = '';
    if(isset($_REQUEST['selectedoperator'])){
        $selectedoperator = $_REQUEST['selectedoperator'];
    }
    $selectedoperationtype = '';
    if(isset($_REQUEST['selectedoperationtype'])){
        $selectedoperationtype = $_REQUEST['selectedoperationtype'];
    }
    $operationtypearr = ['list'=>getFixedLabel('FUZZYSEARCH'),'accuratesearch'=>getFixedLabel('ACCURATESEARCH'),'backfill'=>getFixedLabel('BatchBackFilling')];
    $businesslogarr = cls_BusinessInformation::getBusinesslogBydatedetail($searchdate,$searchdate);
    $headerkeyarr = [];
    foreach($businesslogarr['headtitle'] as $tmpindex=>$tmpheaderinfo){
        $headerkeyarr[] = $tmpheaderinfo['key'];
        $businessloglistheader_arr[] = $tmpheaderinfo['fieldlabel'];
    }
    $businessloglistarr = $businesslogarr['list'];
    $businesslogdetailshow_arr = array();
    $operatorarr = array();
    foreach($businessloglistarr as $businessloginfo){
        $storttime = strtotime($businessloginfo['searchtime']);
        //操作时间
        $searchtime = date("Y-m-d H:i:s", $storttime);
        //查询方式
        $operationtype = $operationtypearr[$businessloginfo['operationtype']];
        //查询关键词
        $searchwords = $businessloginfo['searchwords'];
        //操作人
        $userid = $businessloginfo['userid'];
        $user_name= '';
        if(!empty($userid)){
            $user_name = getUserFullName($userid);
        }
        if(!empty($userid)){
            $operatorarr[$userid] = $user_name;
        }
        if(!empty($selectedoperator)&&$userid!=$selectedoperator){
            continue;
        }
        if(!empty($selectedoperationtype)&&$businessloginfo['operationtype']!=$selectedoperationtype){
            continue;
        }
        //有效查询量
        $searchvalidcount = $businessloginfo['searchvalidcount'];
        $businesslogdetailshow_arr[] = array(
            'searchtime'=>$searchtime,
            'operationtype'=>$operationtype,
            'searchwords'=>$searchwords,
            'userid'=>$user_name,
            'searchcount'=>1,
            'searchvalidcount'=>$searchvalidcount,
        );
    }
    $arr = [];
    $smarty->assign('operatorarr',$operatorarr);
    $smarty->assign('operationtypearr',$operationtypearr);
    $smarty->assign('selectedoperator',$selectedoperator);
    $smarty->assign('selectedoperationtype',$selectedoperationtype);
    $smarty->assign('headerkeyarr',$headerkeyarr);
    $smarty->assign('businessloglistheader_arr',$businessloglistheader_arr);
    $smarty->assign('businesslogdetailshow_arr',$businesslogdetailshow_arr);
    $arr['content']=$smarty->fetch('Settings/BusinessSettings/BusinessLogDetail.tpl');
    $arr['title']=date("Y年m月d日", strtotime($searchdate)).getFixedLabel("business").getFixedLabel("LOG");
    $arr['canceltext']=getFixedLabel("CLOSE");
    ConvertTojsonString(1,$arr,'success');
}
?>