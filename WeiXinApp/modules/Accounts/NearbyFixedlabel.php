<?php 
/*
edit:duan
date:20221014
resson:移动端附件客户列表页获取字符串翻译请求
*/
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $MobileLanguageType;
//duan 移动端增加字符串翻译返回
$label_arr=array(
    'AWAYFROMYOU',//距您%d米
    'FOLLOWUP',//跟进
    'RECEIVE',//领取
    'COMEHERE',//到这里
    'VIEW',//查看
    'Phone',//电话
    'NOTMPDATA',//没有%s数据
    'NOMORETMPDATA',//没有更多%s数据
    'MAP',//地图
    'NEARBY',//附近
    'LISTMODE',//列表模式
    'SUREYOUWANTCOLLECT',//确定要领取？
    'SUCCESSFULLYRECEIVED',//领取成功
    'SINGINADDRESS',//签到地址
    'NOTENTEREDMOBILENUMBER',//该客户没有录入手机号码或电话号码！
);
$fixedlabel_arr = TransFieldlabel($label_arr);


//组合字符串先分割再到移动端重新组合:
$fixedlabel_arr = CombineLabelSolution('%d','AWAYFROMYOU',$fixedlabel_arr);// 距您%d米
$fixedlabel_arr = CombineLabelSolution('%s','NOMORETMPDATA',$fixedlabel_arr);// 没有更多%s数据
$fixedlabel_arr = CombineLabelSolution('%s','NOTMPDATA',$fixedlabel_arr);//没有%s数据

$fixedlabel_arr['ContactRecords']=getTranstab('ContactRecords');
$jsonArray['arrFixedLabel']=$fixedlabel_arr;
global $mobile_pagerecordcount;
$jsonArray['noofrows']=$mobile_pagerecordcount;

ConvertTojsonString(1,$jsonArray,'success');
?>