<?php
global $current_user;
$userid = $current_user->id;
$searchdate = date("Y-m-d");
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$searchuserid=$_REQUEST['searchuserid'];
if(empty($searchuserid))
{
    $searchuserid=$userid;
}
$searchdate=$_REQUEST['searchdate'];
if(empty($searchdate))
{
    $searchdate=date("Y-m-d");

}
if($_REQUEST['maptype']=='track')
{
    crm_load_class_file("TrackLocationList","Register");
    $obj=new TrackLocationList($searchuserid,$searchdate);
    $arr=$obj->getList();
    ConvertTojsonString(1,['list'=>$arr],'success');
}
else{
    require_once (globalStatic::$root_directory."Register/TrackPositionShow.php");

    $obj=new TrackPositionShow();

    $userobj=new Users();
    $filepath=   $userobj->getUserImage($searchuserid);
    if($userobj->userimageinfo_arr['storagelocation']=='cos')
    {
        $imageurl=$filepath;
    }
    else{
        $filepath=$_REQUEST['crmurl'].$filepath;
    }


    ConvertTojsonString(1,['info'=>$obj->getlastPosition($searchuserid),'photourl'=>$filepath,
        'curday'=>date("Y-m-d"),
        'translate'=>['searchscope'=>getFixedLabel('VIEWRANGE').":"
            ,'beforeday'=>getFixedLabel("THEDAYBEFORE")
            ,'afterday'=>getFixedLabel('THEDAYAFTER')
            ,'ok'=>getFixedLabel('CONFIRMED')
            ,'cancel'=>getFixedLabel("CANCEL")
            ,'modulelabel'=>getTranstab("TrackLocationMap")]],'success');
}

?>