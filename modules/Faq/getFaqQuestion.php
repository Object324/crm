<?php
/**
 * edit:chj
 * date:2015-12-05
 * reason:获取选择的常见问题的问题和解决办法
 **/
global $adb;
$x = 1;
if(isset($_REQUEST['idstring']) && !empty($_REQUEST['idstring']))
{
	$query = 'select question,answer,faq_no from ld_faq where id in ('.$_REQUEST['idstring'].')';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	//显示列号
	if(isset($_REQUEST['select_type']) && $_REQUEST['select_type']=='Reverse'){
		$x = 1;
	}else{
		if(!empty($_REQUEST['faqNo'])){
			$x = $_REQUEST['faqNo'];
		}
	}
	if($num_rows > 0){
		for($i = 0; $i<$num_rows; $i++){
			$question = $adb->query_result($result,$i,'question');
			$answer = $adb->query_result($result,$i,'answer');
			$faq_no[] = $adb->query_result($result,$i,'faq_no');
			$question_arr[$i] = $x . '. '.$question;
			$answer_arr[$i] = $x . '. '.$answer;
			$x++;
		}
		$content['question'] = implode("\r\n",$question_arr);
		$content['answer'] = implode("\r\n",$answer_arr);
		$content['faqno'] = implode(",",$faq_no);
	}
}
$jsonentity = Zend_Json::encode($content);
//$jsonentity=json_encode($searchInfo);

echo $jsonentity;exit();


?>