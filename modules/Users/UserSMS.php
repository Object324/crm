<?php
global $adb;
$allids=trim($_REQUEST['allids'],',');

$sql="select phone_mobile ,last_name from ld_users where id in( $allids)";
$result=$adb->pquery($sql,array());

/**
 * 增加一个数组，已经加进来的手机号直接过滤掉，防止手机号重复
 * @reason 0012241: 【群发短信】：点击“数据分类”或接收人手机，选择的号码后，希望直接过滤掉重复的号码。
 * @author Tujt 2014-11-14
 */
$mobilearray = array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
	$phone_mobile = $adb->query_result($result,$i,'phone_mobile');   
    $subject=$adb->query_result($result,$i,'last_name');
    if($phone_mobile!=''&&!array_key_exists($phone_mobile,$mobiles))
    {
        if(preg_match(globalStatic::$reg_mobile_digit,$phone_mobile))
        {
            $mobiles[$mobile]=$phone_mobile;
            $accepter .=$mobiles[$mobile].'<'.$subject.'>'."\r\n";  
            $hiddenaccepter .=base64_encode($phone_mobile)."\r\n";
        }
                     
    }     
}

echo "#####SUCCESS#####".$accepter."#####SUCCESS#####".$hiddenaccepter;
exit();

?>