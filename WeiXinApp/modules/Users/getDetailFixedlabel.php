<?php 
/*
edit:duan
date:20221021
resson:移动端单据明细客户列表页获取字符串翻译请求
*/
global $MobileLanguageType;
if(isset($_REQUEST['type']) && !empty($_REQUEST['type'])){
    $type = $_REQUEST['type'];
}else if(isset($_REQUEST['mode']) && !empty($_REQUEST['mode'])){
    $type = $_REQUEST['mode'];
}

if($type == 'relevant'){
    $label_arr=array(
        'Theallocationway',//分摊方式
        'shareequally',//均摊
        'apportionmentofdifferentproportions',//不同比例分摊
        'CHOOSEENTITYTYPE',//源单类型
        'CANCEL',//取消
        'NOTMPDATA',//没有%s数据
        'NOMORETMPDATA',//没有更多%s数据
        'SEARCHNEW',//搜索
    );
}else if($type == 'address'){
    $label_arr=array(
        'CANCEL',//取消
        'KILOMETRE',//公里
        'NEARBYADDRESS',//附近地址
        'LOCATINGADDRESS',//定位地址
        'SEARCHNEW',//搜索
        'UNABLETOOBTAINLONGITUDE',//无法获取经纬度，请输入更详细的地址
        'PLEASEENTERTHEADDRESS',//请输入地址
        'NOADDRESSISOBTAINED',//未获取地址，请确定是否开启GPS
        'POSITIONING',//定位中
    );
} else{
    //duan 移动端增加字符串翻译返回
    $label_arr=array(
        'LBL_PLEASE_SELECT',//请选择
        'pleaseenter',//请输入
        'CANCEL',//取消
        'CONFIRMED',//确定
        'ADDDETAILS',//添加明细
        'EDITDETAILS',//编辑明细
        'SELECTAPP',//选择
        'SELECTPRODUCTLINEITEMAPP',//不能选择源单以外的产品
        'SELECTPRODUCTFIRST',//请先选择产品
        'APPCANNOTBEEMPTY',//不能为空
        'SHOULDLESSTHANAPP',// 应小于
        'LBL_Creates',//创建
        'EDIT',//编辑
        'DISCARDTHEMODIFICATION',//确定要放弃当前页面的修改？
        'CANOTEMPTYGTH',//不能为空！
        'SHOULDGREATEROREQUALAPP',//应大于或等于
        'PRODUCTNAMEHASNOTCHANGED',//产品名称更换前后没有变化，请重新选择
        'SELECTTHESOURCEDOCUMENTTYPE',//请选择源单类型后，再选择源单
        'UPTOUPLOAD',
        'ALSOUPLOAD',
        'NOTPICTUREFILETYPE',
        'UPLOADFAILED',
        'IMAGEUPLOADING',
        'UPLOADSUCCEEDED',
        'ATTACHMENTUPLOADING'
    );
}

$fixedlabel_arr = TransFieldlabel($label_arr,'no');
$jsonArray['arrFixedLabel']=$fixedlabel_arr;
ConvertTojsonString(1,$jsonArray,'success');
?>