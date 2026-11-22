<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2014-03-31
 */
//zkt 20231102 XUQIU1001892 PC端高危优化-水平越权优化（文档中第三个问题）（王耀文）
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
global $current_user;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty = new lingdangCRM_Smarty;
$workreportid = $_REQUEST['workreportid'];
$relatedListData = array();
$relatedListData ['header'] =  array('fieldname' => getFixedLabel('LBL_Field'),
    'prevalue' => getFixedLabel('LBL_Earlier'),
    'postvalue' => getFixedLabel('LBL_Present'),
    'changedon' => getFixedLabel('OPERATTIME'));
crm_load_class_file('WorkReportModel','modules/Home');
$workObj = new WorkReportModel();
$changelog = $workObj->getChangeLog($workreportid);
$relatedListData ['entries'] = array();
$relatedListData ['headername'] = array('columnname'=>array(),'fieldname'=>array());
$relatedListData['headername']['columnname']=array('fieldname' => 'fieldname','prevalue' => 'prevalue','postvalue'=>'postvalue','changedon'=>'changedon');
$relatedListData['headername']['fieldname']=array('fieldname' => 'fieldname','prevalue' => 'prevalue','postvalue'=>'postvalue','changedon'=>'changedon');
$relatedListData['fieldwidth'] =array('fieldname' => 80,'prevalue' => 130,'postvalue'=>130,'changedon'=>120);


foreach($changelog['loglist'] as $index=>$logentry){
    $relatedListData ['entries'][]=array('fieldname'=>'','prevalue'=>'','postvalue'=>'','changedon'=>'');
    $relatedListData ['entries'][$index]['fieldname']=$logentry['fieldname'];
    $relatedListData['entries'][$index]['changedon']=$logentry['changedon'];
    if($logentry['fieldname']==getFixedLabel('Image')){
        foreach($logentry['prevalue'] as $idx=>$img){
            $achmentid = $img['achmentid'];
            $src = $img['storage_location']=='local'?$img['real_path'].$img['newfile_name']:urldecode($img['cloud_path']);
            $relatedListData['entries'][$index]['prevalue'].= "<div id='changelogimage_".$achmentid."' name='changelogimage_".$achmentid."'><img  src='".$src."' style = 'float: left;;width:50px; height:50px' ></div>";
        }
        foreach($logentry['postvalue'] as $idx=>$img){
            $achmentid = $img['achmentid'];
            $src = $img['storage_location']=='local'?$img['real_path'].$img['newfile_name']:urldecode($img['cloud_path']);
            $relatedListData['entries'][$index]['postvalue'].= "<div id='changelogimage_".$achmentid."' name='changelogimage_".$achmentid."'><img  src='".$src."' style = 'float: left;;width:50px; height:50px' ></div>";
        }
    }else if($logentry['fieldname']==getFixedLabel('Attachment')){
        $relatedListData['entries'][$index]['prevalue']= implode(",",$logentry['prevalue']);
        $relatedListData['entries'][$index]['postvalue']= implode(",",$logentry['postvalue']);
    }else{
        $relatedListData['entries'][$index]=$logentry;
    }

}
$smarty->assign("RELATEDLISTDATA", $relatedListData);
$smarty->assign("RELATED_MODULE",'changelog');
$title = getfixedLabel('View History');
$oktext = getfixedLabel('CONFIRME');
$canceltext = getfixedLabel('CANCEL');
$content= $smarty->fetch("Home/CoordinationChangeLog.tpl");
ConvertTojsonString(1,array('title'=>$title,'oktext'=>$oktext,'canceltext'=>$canceltext,'content'=>$content),'success');

?>