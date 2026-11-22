<?php
global $adb;
$smarty=new lingdangCRM_Smarty();
crm_load_class_file('cls_workreportshow',"modules/CooperativeWork");
$_REQUEST['diony']='diony';
$type = $_REQUEST['type'];
$smarty->assign('type',$type);
if ($type == 'settings'){
    $workreportshowobj=new cls_workreportshow();
    $smarty->assign("WORKREPORTSHOW",$workreportshowobj->getAllWorkReportType());
    $reportlabel = array(
        'weibo' => 'BLOG',//getFixedLabel('BLOG')
        'dayreport' => 'JOURNAL',
        'weekreport' => 'WEEKPLAN',
        'monthreport' => 'MONTHPLAN',
        'cocmd' => 'TASK'
    );
    $label_sql = 'select languagetype,fieldlabel from ld_desk where labelbol = ? and labeltype = ?';
    foreach ($reportlabel as $reporttype => $labelbol){
        $result = $adb->pquery($label_sql,array($labelbol,'fixedstr'));
        $num_row = $adb->num_rows($result);
        if ($num_row>0){
            $tmp_arr = [];
            for ($i = 0;$i<$num_row;$i++){
                $languagetype = $adb->query_result($result,$i,'languagetype');
                $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
                $tmp_arr[$languagetype]=$fieldlabel;
            }
            $workreprottype[$reporttype]=$tmp_arr;
        }
    }

    $smarty->assign("WORKREPORTTYPE",$workreprottype);
    $arr['all']=$workreportshowobj->getAllWorkReportType();
}else{
    // @edit:liushuai,2020-07-28,reason:ID1000926/工作汇报设置弹出层界面优化，增加“类别设置”和“文字描述设置”区块标签，文字描述可修改
    global $current_user;
    $languageType= getLanguageType($current_user);//en  zh
    if($languageType == 'zh')
        $placeholder = '一天的工作开始于前一天晚上，创建工作汇报吧！';
    else
        $placeholder = "A day's work starts the night before. Create a Cooperative Work!";
    $smarty->assign("placeholder",$placeholder);
}

$content=$smarty->fetch("Home/setWorkReportShow.tpl");

$arr['content']=$content;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
if ($type == 'settings'){
    $arr['title']=getFixedLabel('SetType');
}else{
    $arr['title']=getFixedLabel('Set_Cooperative_WorkSet');
}
ConvertTojsonString(1,$arr,"success");

?>