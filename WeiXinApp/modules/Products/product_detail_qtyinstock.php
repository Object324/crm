<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_101 reason:产品单据明细界面,查看产品所在仓库数量分布情况  2019/1/28 17:15
crm_load_class_file('ReportModel','modules/OftenUseReport');
$Model = new ReportModel();
$list_entry = $Model->product_detail_qtyinstock($_REQUEST['record'],$_REQUEST['type']);
if($_REQUEST['type']=='detail'){
    //duan 20221020 移动端增加翻译
    $label_arr=array(
        'nodata',//没有数据
        'CANCEL',//取消
    );
    $list_entry['arrFixedLabel']=TransFieldlabel($label_arr,'no');
}

ConvertTojsonString(1,$list_entry,"success");


?>
