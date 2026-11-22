<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme,$adb,$currentModule,$current_user;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$allMouth = $_REQUEST['allmouth'];

$allUsers = $_REQUEST['alluserid'];
$userArr = array();
if(empty($allUsers)||$allUsers=='SmOwner_Search_All')
{
	$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
	if(!empty($MergeSmowner['UserCombo'])){
		foreach($MergeSmowner['UserCombo'] as $userid => $userinfo){
			$userArr[] = $userid;
		}
	}
   /* $sql="select  GROUP_CONCAT(id) from ld_users   where `status`='active'";
    $result=$adb->pquery($sql,array());
    $allUsers=$adb->query_result($result,0,0);*/
    
}else{
    $userArr = explode(',',$allUsers);
}
//$userArr = explode(',',$allUsers);
$mouthArr = explode(',',$allMouth);
$startdates=explode("-",$mouthArr[0]);
$enddates=explode("-",$mouthArr[sizeof($mouthArr)-1]);
$viewrangeone_year=$startdates[0];
$viewrangeone_month=$startdates[1];

$viewrangetwo_year=$enddates[0];
$viewrangetwo_month=$enddates[1];
for($i = 0; $i<count($userArr); $i++)
{
    for($j = 0; $j<count($mouthArr); $j++)
    {
		if(!empty($_REQUEST['module_look'])){
			switch($_REQUEST['module_look']){
				case 'contractamount':
				   $input_name = $userArr[$i] . '-' . $mouthArr[$j] . '-' . 1;  //contractamount 签约额
				   break;
				case 'paymentamount':
				   $input_name = $userArr[$i] . '-' . $mouthArr[$j] . '-' . 2;  //paymentamount 回款额
				   break;
				case 'accountsnumber':
				   $input_name = $userArr[$i] . '-' . $mouthArr[$j] . '-' . 3;  //accountsnumber 客户数
				   break;
				case 'invoiceamount':
				   $input_name = $userArr[$i] . '-' . $mouthArr[$j] . '-' . 4;  //invoiceamount 发票额
				   break;
				case 'outboundorderamount':
				   $input_name = $userArr[$i] . '-' . $mouthArr[$j] . '-' . 5;  //outboundorderamount 出库额
				   break;
                case 'receivableamount':
                    $input_name = $userArr[$i] . '-' . $mouthArr[$j] . '-' . 6;  //receivableamount 应收额
                    break;
			}
		}
		$value = $_REQUEST[$input_name];
        updateSalesTarget($userArr[$i],$mouthArr[$j],$_REQUEST['module_look'],$value);
    }
}

$addurl="&viewrangeone_year=".$viewrangeone_year."&viewrangeone_month=".$viewrangeone_month;
$addurl.="&viewrangetwo_year=".$viewrangetwo_year."&viewrangetwo_month=".$viewrangetwo_month;
//header("location: index.php?pageto_module=$currentModule&pageto_action=ListView_edit&module_look=".$_REQUEST['module_look'].$addurl);
function updateSalesTarget($userid,$mouth,$module_look,$value)
{
    global $adb;
    $mArra = explode('-',$mouth);
    $sql = "select * from ld_salestarget where userid = ? and targetyear = ? and targetmouth = ?";
    $result = $adb->pquery($sql,array($userid,$mArra[0],$mArra[1]));
    if($value == '')
        $value = 0;
    if($adb->num_rows($result) > 0)
    {
        $adb->pquery("update ld_salestarget set $module_look = $value where userid = $userid and targetyear = $mArra[0] and targetmouth = $mArra[1] ");
    }
    else
    {
        $adb->pquery("insert into ld_salestarget(userid,targetyear,targetmouth,$module_look) values 
        ($userid,$mArra[0],$mArra[1],$value)");
    }

}
//edit:can 20210723 47038: （https://51mis.com/hy/liu0712 [^]）金融行业演示账套-基础资料-销售目标-目标设置-编辑错误
unset($_REQUEST['query']);
$_REQUEST['ajax']='yes';
include(globalStatic::$root_directory.'modules/SalesGoal/ListView_edit.php');
//$_REQUEST['diony']='yes';
//ConvertTojsonString(1,array(),'success');

?>