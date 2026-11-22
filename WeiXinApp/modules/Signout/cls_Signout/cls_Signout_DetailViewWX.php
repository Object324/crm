<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_Signout_DetailViewWX extends cls_DetailViewWX
{
    //名片新增时给字段添加默认值
    protected function setDefaultValue($focus)
    {
        if(!empty($_REQUEST['cardserverId']) && !empty($_REQUEST['camcard'])){
            require_once(globalStatic::$root_directory.'expansion/camcard/cls_camcard.php');
            $camobj = new cls_camcard();
            $fieldComparison = $camobj->createViewDefaultValues($_REQUEST['camcard'],$_REQUEST['cardserverId']);
            if(!empty($fieldComparison)) {
                foreach ($focus->column_fields as $fieldname => $val) {
                    if (!empty($fieldComparison[$fieldname])) {
                        $defaultvalue = $fieldComparison[$fieldname];
                        $focus->column_fields[$fieldname] = $defaultvalue;
                        if ($fieldname == 'account_id') {
                            $_REQUEST['CamCard_RelatedCreate'] = $_REQUEST['cardcontent'];//为了在保存时分辨出客户名称的来源
                            $this->jsonArr['CamCard_RelatedCreate'] = $_REQUEST['cardcontent'];
                        }
                    }
                }
            }
        }
    }
    
    protected function get_CreateView()
    {
        $_REQUEST['signout_type'] = 'signout';
        if(isset($_REQUEST['signouttype'])){
            $_REQUEST['signout_type'] = $_REQUEST['signouttype'];
        }
        $this->focus->column_fields['signout_type'] = $_REQUEST['signout_type'];
        $this->jsonArr = parent::get_CreateView();
        $this->jsonArr['signData']['address'] = getFixedLabel('CLICKTOSIGNOUT');
        
        return $this->jsonArr;
    }
    
    //duan 20221021 移动端新建编辑页面翻译
    public function getCreateviewFixedlabel(){
        global $MobileLanguageType;
        $label_arr=array(
            'BASICINFO',//基本信息
            'EMPTY',//清空
            'pleaseenter',//请输入
            'LBL_PLEASE_SELECT',//请选择
            'PLEASEENTERTHESCALE',//请输入比例
            'Currency',//币种
            'DETAIL',//明细
            'DELETE',//删除
            'EDIT',//编辑
            'CALCULATE',//计算
            'ERRORMETRA',//误差(米)：
            'INACCURATEPOSITIONING',//定位不准？点我
            'VOICEMESSAGE',//语音信息
            'SUBMITAPPROVAL',//提交审批
            'SELECTAPPROVALPROC',//选择审批流程
            'UrgentApproval',//需要加急审批
            'SUBMITCOMMENTS',//提交意见
            'PLEASEFILLINYOURCOMMENTS',//请填写意见
            'DISPLAYMOREITEM',//展开更多栏目
            'COLLAPSE',//收起
            'SAVE',//保存
            'DISCARDTHEMODIFICATION',//确定要放弃当前页面的修改？
            'UPLOADING',//上传中...
            'FINDDUPLICATES',//查重
            'BUSINESSINFORMATION',//工商信息
            'PLEASEENTERINFORMATION',//请输入信息
            'LBL_Creates',//创建
            'SELECTTHESOURCEDOCUMENTTYPE',//请选择源单类型后，再选择源单
            'SELECTMODULEBEFORESELECTING',//请选择模块后，再选择
            'VERSIONLOWPLEASEUPGRADE',//版本过低请升级
            'SCANCODECONTINUOUSLY',//是否连续扫码
            'SELECTPRODUCTLINEITEMAPP',//不能选择源单以外的产品
            'ADD',//增加
            'DIRECTPRICE',//直接降价
            'APPCANNOTBEEMPTY',//不能为空
            'FORMATERROR',//格式错误
            'CONTACTNAMECANOTEMPTYAPP',//首要联系人姓名不能为空
            'PLEASEENTERTHECORRECTAPP',//请输入正确的
            'CANNOTBESAME',//%s和%s不能相同
            'CANNOTTHAN',//不能大于
            'CANNOTBELESSTHANONE',//不能小于
            'SHOULDGREATEROREQUALAPP',//应大于或等于
            'SIGNINISREQUIRED',//签退必填，请点击定位后保存
            'INCALCULABLE',//无法计算
            'CLICKTOREPOSITION',//您当前页面停留超过5分钟，点击【确定】按钮后将重新定位
            'SUCCESSFULLYSAVED',//保存成功
            'PLEASESELECTFIRST',//请先选择%s,再选择%s
            'SELECTAPP',//选择
            'DOYOUUSELOCATIONADDRESSAPP',//是否用定位地址覆盖国家、省份、城市及地址？
            'POSITIONING',//定位中...
            'NOADDRESSISOBTAINED',//未获取地址，请确定是否开启GPS
            'DELETELOCATIONINFORMATION',//确定要删除定位信息吗？
            'CLICKTOSIGNIN',//点击签到
            'CLICKTOSIGNOUT',//点击签退
            'UPTOUPLOAD',//最多可上传
            'ALSOUPLOAD',//您还可以上传
            'NOTPICTUREFILETYPE',//不是图片文件类型
            'PLEASESELECTPICTURES',//请选择%dM以内的图片
            'UPLOADFAILED',//上传失败
            'IMAGEUPLOADING',//图片上传中...
            'UPLOADSUCCEEDED',//上传成功
            'ATTACHMENTUPLOADING',//附件上传中...
            'FAILEDTOINITIALIZEPAGE',//初始化页面失败
            'TOTALOFAPP',//总
            'REQUIREDAPP',//要求
            'THANAPP',//比
            'MONTHSAPP',//个月
            'TOTAL',//合计
            'ADMINISTRATORCREATEVENDORS',//请联系系统管理员创建{$Vendors.Vendors}
            'ADMINISTRATORLOCATEADDRESS',//请联系系统管理员定位地址
            'SEARCHNEW',//搜索
            'nodata',//没有数据
            'NOMOREDATA',//没有更多数据
            'zhang',//张
            'SUCCESS',//成功
            'SUREWANTDELETE',//确定要删除吗？
            'DELETESUCCESSFUL',//删除成功
            'PHOTOGRAPH',//拍照
            'PhotoAlbum',//相册
            'WECHATCLIENTCHOOSEFILE',//微信客户端会话选择文件
            'COORDINATECONVERSIONFAILED',
        );
        
        $sign_label_arr=array(
            'SIGNTIME',//签到时间
            'VISITORTYPE',//拜访对象类型
            'LBL_PLEASE_SELECT',//请选择
            'BaiFang_DuiXiang',//拜访对象
            'VISITINGADDRESS',//拜访地址
            'REMARK',//备注
            'pleaseenter',//请输入
            'PHOTO',//照片
            'ERRORMETRA',//误差(米)：
            'INACCURATEPOSITIONING',//定位不准？点我
            'SIGNOUT2',//签退
            'SUPSIGN',//补签
            'SIGNIN',//签到
            'HISTORY',//历史
            'NOADDRESSISOBTAINED',//未获取地址，请确定是否开启GPS
            'POSITIONING',//定位中...
            'UPTOUPLOAD',//最多可上传
            'ALSOUPLOAD',//您还可以上传
            'NOTPICTUREFILETYPE',//不是图片文件类型
            'UPLOADFAILED',//上传失败
            'UPLOADING',//上传中...
            'UPLOADSUCCEEDED',//上传成功
            'LOCATINGCURRENTADDRESS2',//正在定位当前地址，请稍后再选择拜访对象
            'LOCATINGCURRENTADDRESS',//正在定位当前地址，请稍后再选择拜访对象类型
            'SELECTVISITORTYPEFIRST',//请选择拜访对象类型后，再选择拜访对象
            'PLEASEWAITLOCATING',//请稍等，正在定位中...
            'VISITORCANNOTBEEMPTY',//拜访对象不能为空
            'PICTURECANNOTEMPTY',//图片不能为空
            'REMARKCANNOTEMPTY',//备注不能为空
            'TheAdminHasSetNotAllowSignoutBeyondRange',//管理员已设置超出误差范围不允许签退，请完善您的拜访对象地址信息
            'INCALCULABLE',//无法计算
            'CLICKTOREPOSITION',//您当前页面停留超过5分钟，点击【确定】按钮后将重新定位
            'SIGNOUTSUCCEEDED',//签退成功
        );
        
        $label_arr = array_unique(array_merge($label_arr,$sign_label_arr));
        
        $fixedlabel_arr = TransFieldlabel($label_arr);
        if(isset($fixedlabel_arr['QUANTITYEXCEEDS']))
        {
            $fixedlabel_arr['QUANTITYEXCEEDS_out']= sprintf($fixedlabel_arr['QUANTITYEXCEEDS'],$fixedlabel_arr['chuku'],$fixedlabel_arr['chuku']);

            $fixedlabel_arr['QUANTITYEXCEEDS_in']= sprintf($fixedlabel_arr['QUANTITYEXCEEDS'],$fixedlabel_arr['WAREHOUSING'],$fixedlabel_arr['WAREHOUSING']);

        }
        if($MobileLanguageType == 'en'){
            $fixedlabel_arr['DETAIL'] = ' '.$fixedlabel_arr['DETAIL'].' ';
            $fixedlabel_arr['DETAIL1'] = ' '.$fixedlabel_arr['DETAIL'].':';
            $fixedlabel_arr['LBL_Creates'] = $fixedlabel_arr['LBL_Creates'].' ';
            $fixedlabel_arr['EDIT'] = $fixedlabel_arr['EDIT'].' ';
        }else{
            $fixedlabel_arr['DETAIL1'] = $fixedlabel_arr['DETAIL'].'：';
        }
        
        $fixedlabel_arr = CombineLabelSolution('%d','PLEASESELECTPICTURES',$fixedlabel_arr);//请选择%dM以内的图片
        $fixedlabel_arr = CombineLabelSolution('%s','CANNOTBESAME',$fixedlabel_arr);//%s和%s不能相同
        $fixedlabel_arr = CombineLabelSolution('%d','LINECOUNT',$fixedlabel_arr);//第%d行
        $fixedlabel_arr = CombineLabelSolution('%s','QUANTITYEXCEEDS',$fixedlabel_arr);//产品累积%s数量超过可%s数量，保存失败
        $fixedlabel_arr = CombineLabelSolution('%s','PLEASESELECTFIRST',$fixedlabel_arr);//请先选择%s,再选择%s
        $fixedlabel_arr = CombineLabelSolution('%s','PROPORTIONTOTALMUSTBE',$fixedlabel_arr);//%比例合计必须等于100
        
        //管理员已设置超出误差范围不允许签到，您的签到误差已超{metre}米，请在规定范围内签到！
        $signlabelstr = getFixedLabel('Theadministratorhassetthatitisnotallowedtosignout');
        $signlabelarr = explode('{metre}',$signlabelstr);
        $fixedlabel_arr['allowedtosign1'] = $signlabelarr[0];
        $fixedlabel_arr['allowedtosign2'] = $signlabelarr[1];
        
        $this->jsonArr['arrFixedLabel']=$fixedlabel_arr;
        //多选框控件
        $option_label_arr = array('CANCEL','CONFIRMED','SEARCHNEW','PLEASESELECTATLEASTONE');
        $fixedlabel_arr_option = TransFieldlabel($option_label_arr,'no');
        $this->jsonArr['arrFixedLabel_option']=$fixedlabel_arr_option;
    }
    
}