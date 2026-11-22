<?php

/**
 * 更新操作
 * 操作人: Yan
 * 日期: 2016/8/31
 * 时间: 17:56
 * 说明:
 */
crm_load_class_file('cls_DetailView_OutPut','include/utils');

class cls_DetailViewOutPutWX extends cls_DetailView_OutPut
{
    public $record;
    //reason:移动端，知识管理详情界面插件型备注无法查看PC端上传的附件及图片  2019/10/15 19:28 ID1000623
    public $uitype230;
    public function getDetailViewOutputHtml($fieldinfo, $col_fields, $generatedtype, $tabid = '', $module = '')
    {

        global $current_user,$adb,$weixin_user;
        //$this->output_type = 'weixin';
        //0027105: 微信端项目任务详细信息中项目名称显示有误
        $_REQUEST['weixin_mark']=2;
        $fieldarr= parent::getDetailViewOutputHtml($fieldinfo, $col_fields, $generatedtype, $tabid, $module);
        $up = $fieldarr[2]; //uitype
        
        $text = $fieldarr[1];
        $tp = ''; //type 对uitype进行分组
        // 0027514: 微信端：项目>新增，选择源单保存后，选择源单字段值显示不正确  gyq date:20170324
        //0037285: 灵当CRM小程序->客户->详情->负责人：点击负责人链接跳转到了客户界面
        //根据有无link显示超链接字段,增加relatemodule,排除负责人字段
        //editor:gyq_20200303 reason:创建人修改人等，不允许跳转
        if(!empty($fieldarr['link'])&&$up != 53 && $up != 52&&$up != 153){
            $relaterecord = $fieldarr['secid'];
            //if(in_array($relatemodule,array('Accounts','Contacts','Vendors'))){
            //edit: xll 2023/06/12 XUQIU1001203 增加“显示超链接”字段属性
            $ShowHyperlinks = '';
            if($fieldinfo->getbigtype() == 'selectsource'){
                $relatemodule = getSalesEntityType($relaterecord);
                crm_load_class_file('cls_OptionModule', 'include/OptionModule');
                $cls_OptionModule = cls_OptionModule::getInstance($module,'');
                $field_AllData = $cls_OptionModule->getSourceModule_AllData($module);
                $parent_Tabid = getTabid($relatemodule);
                $ShowHyperlinks = $field_AllData[$parent_Tabid]['ShowHyperlinks'];
            }else{
                $ShowHyperlinks = $fieldinfo -> get_ShowHyperlinks();
            }
            if($ShowHyperlinks != 'no'){
                $relatemodule = getSalesEntityType($relaterecord);
                $fieldarr['relatemodule'] = $relatemodule;
            }
            //}
            unset($fieldarr['link']);
        }

        $newfieldarr = array();
        $fieldname = $newfieldarr['fieldname'] = $fieldinfo->fieldName;
        $typeofdata = $newfieldarr['typeofdata'] = $fieldinfo->typeofData;
        //将父数组$fieldarr转换成新字段数组$newfieldarr
        $init_arr = array('fieldlabel','text','uitype');
        foreach($fieldarr as $key => $val){
            if($key===0||$key===2||$key===1){
                $newfieldarr[$init_arr[$key]] = $val;
            }
            else{
                $newfieldarr[$key]=$val;
            }
        }
        $newfieldarr['phone'] = 'no';
        
        //判断源单字段
        $bigtype = $fieldinfo->getbigtype();
        $up=$fieldinfo->getUIType();
        
        //editor:gyq_129 reason:选择源单字段,字段名称后增加显示模块名  2019/7/11 17:22 ID1000529
        if($bigtype=='selectsource'){
            $newfieldarr['fieldlabel']= $newfieldarr['fieldlabel'].' '.getTranstab($fieldarr['relatemodule']);
            //unset($newfieldarr['relatemodule']);
        }elseif($up==102 &&($module=='Project'||$module=='PaymentPlan')){
            $newfieldarr['fieldlabel']= $newfieldarr['fieldlabel'].' '.getTranstab(getSalesEntityType($fieldarr['secid']));
        }elseif($up==14){
            $tp=9;
        }elseif($up==154 || $up==242)
            $tp = 154;
        elseif($up==86)
            $tp=7;
        elseif($up==117 || $up==251||$up==55)
            $tp=4;
        elseif($up==116 ||$up == 52 || $up == 77 || $up == 101||$up==4)
            $tp=10;
        elseif($up==13||$up==104||$up==17||$up == 11||$up==1101||$up==255||$up==71||$up==72){
            if($up==72||$up==71){
                //editor:gyq_20190821 reason:企业微信端。合同订单页面，已开票金额，未开票金额，已收款金额，未收款金额，没有显示千分位。PC端显示的。
                //$newfieldarr['text'] = setNumberFormat($text);
            }elseif($up==13){
                $tp=13;
            }elseif ($up == 11||$up==1101) {
                $mobileValue = $col_fields[$fieldname];
                //编辑时，判断是否显示手机
                if($up == 1101){
                    if ( isset($_REQUEST['action']) && $_REQUEST['action'] == 'EditView') {
                        if (fieldValueUitype::IsShowMobileTextBox($col_fields['record_id'], $module) == 'no') {
                            return;
                        }
                    }
                    //设置手机字段显示样式
                    if ( isset($_REQUEST['action']) && $_REQUEST['action'] != 'EditView') {

                        $newfieldarr['phonetext'] = $mobileValue;
                        $mobileValue = fieldValueUitype::SetMobileStyle($col_fields['record_id'], $mobileValue, $module);
                    }
                }else{
                    $newfieldarr['phonetext'] = $mobileValue;
                }
                $mobileValue=(string)$mobileValue;
                if(strpos($mobileValue,'*') === false ){
                    $newfieldarr['phone'] = 'yes';
                }else{
                    $newfieldarr['phone'] = 'no';
                }
                $newfieldarr['text'] = $mobileValue;
                $tp=1;
            }
        }
        elseif($up==16||$up==200||$up==245||$up==244||$up==130||$up==131){
            if($up==200){
                $newfieldarr['text'] = strip_tags(getDetailListValName($col_fields['record_id'],'SalesOrder',1));
            }
        }
        elseif($up==15) {//gyqTS
            unset($newfieldarr['options']);
            if ($fieldname == 'sales_stage' && $module == 'Potentials')
                $tp = '10';
            else
                $tp = '4';
        }
        elseif($up==33) {
            unset($newfieldarr['options']);
            if ($fieldname == 'sales_stage' && $module == 'Potentials')
                $tp = '10';
            else
                $tp = '21';
        }elseif ($up==230){
            $tp=5;
            //editor:gyq_151 reason:移动端，知识管理详情界面插件型备注无法查看PC端上传的附件及图片  2019/10/15 19:28 ID1000623
            $subStr = "<img src=";
            $subStr2 = "dialogs/attachment/fileTypeImages/icon";
            if (strpos($text, $subStr) !== false || strpos($text, $subStr2) !== false) {
                $newfieldarr['text'] = $this->uitype230($text,$fieldarr[0]);//20240307 公告模块手机端显示不全 先将这里去掉
            }
        }elseif($up==19 || $up == 20 || $up == 21 || $up == 22 || $up == 24|| $up == 65){
            $tp=5;
            //0032999: 企业微信：客户明细界面，备注字段，录入一行数据，换行再对齐录入数据，结果数据没有左对齐，换行符没有用
            if($up==19||$up==20) {
                $newfieldarr['text'] = nl2br($newfieldarr['text']);
            }
            //wym 240513 XUQIU1002193 销售线索、客户，即将回收和回收消息提醒内容单据查看详情界面，客户名称增加显示超链接，移动端不显示该超链接
            if($module=='Reminds' && $fieldinfo->fieldName=='content'){
                $newfieldarr['text'] = strip_tags($newfieldarr['text'],'<br>');
            }
        }
        elseif($up==56) {
            $tp = 2;
            //客户模块复制，需要获取到公海客户的类型 data:20180302 xxs
            if($fieldname=='publicaccount') $newfieldarr['value']=$col_fields['publicaccount']+1;
        }
        elseif($up==105) {
            //editor:gyqCom0306 reason:输出样式,weixin微信输出样式 date:20170307
            $newfieldarr['options'] = $fieldarr[1];
            //字段值为空，则不返回该字段
            if(empty($fieldarr[1])) return '';
            $newfieldarr['text'] = '';
            $tp = 69;
        }elseif($up==222) {
            $tp = 222;
            $newfieldarr['fldallow_rewriting'] = $fieldinfo->get_fldallow_rewriting();
        }
        elseif($up==5||$up==23||$up==70)
            $tp=8;
        elseif($up==83){
           // 0028139: 微信端：产品查看界面：税别字段开启销售税后，查看界面没有显示税
            crm_load_function_file('getTaxDetailsForProduct','include/utils','InventoryUtils');
            $tax_details = getTaxDetailsForProduct($this->record);
            $tempfield=[];
            if(is_array($tax_details))
                for($i=0;$i<count($tax_details);$i++)
                {
                    $tempfield[$i]['fieldlabel'] = $tax_details[$i]['taxlabel'].'(%)';
                    $tempfield[$i]['text'] =  getProductTaxPercentage($tax_details[$i]['taxname'],$this->record);;

                    $tempfield[$i]['fieldname'] = $tax_details[$i]['taxname'];
                    $tempfield[$i]['type'] = 1;
                    $tempfield[$i]['uitype'] = 1;
                    $tempfield[$i]['typeofdata'] = 'V~O';
                    $tempfield[$i]['phone'] = 'no';
                }
            $_REQUEST['tempSourceField'] = $tempfield;
            return false;

        }
        else if($up==69)
        {
             $i=0;
             $tmp_crmid = $this->record;
             if(($module == 'Accounts' || $module== 'ServiceCharge') && strpos($fieldname,'_mapping') !== false){
                $tmp_crmid = $col_fields['contactid'];
             }
             
             //2022-06-13 联系人模块照片字段详情页没有返回照片信息的问题，我和小光看了一下数组没有键为2的了
            foreach($fieldarr[1][$tmp_crmid] as $fileid=>$fileinfo){
                $value[$i]['id']=$fileid;
               
                 foreach($fileinfo as $filekey=>$filevalue){
                     $value[$i][$filekey]=$filevalue;
                 }
                 $value[$i]['ext']=cls_StaticCommonFun::getExtName($value[$i]['newfile_name']);
                 
                 $i++;
            }
            $newfieldarr['text'] = $value;
            $tp = 69;
            //duan 20220830 移动端增加下载和预览附件权限参数
            $newfieldarr['previewprofile'] = IsPreviewProfile($this->id,$module);
            $newfieldarr['downloadprofile'] = IsDownLoadProfile($this->id,$module);
        }
        elseif($up == 28||$up==1109||$up==1108){//附件
            $value = array();
          
            $tmp_crmid = $this->record;
            if(($module == 'Accounts' || $module== 'ServiceCharge') && strpos($fieldname,'_mapping') !== false){
                $tmp_crmid = $col_fields['contactid'];
            }
            $i=0;
            foreach($fieldarr[1][$tmp_crmid] as $fileid=>$fileinfo){
                $value[$i]['id']=$fileid;
               
                 foreach($fileinfo as $filekey=>$filevalue){
                     $value[$i][$filekey]=$filevalue;
                 }
                 $value[$i]['ext']=cls_StaticCommonFun::getExtName($value[$i]['newfile_name']);
                 
                 $i++;
            }
           
            $tp = 1109;
            $newfieldarr['text'] = $value;
            //editor:gyq_113 reason:新增知识管理模块  2019/5/21 17:25 
            if($module=='Documents'&&$up==28){
                if($col_fields['filelocationtype'] == 'E'){
                    $newfieldarr['inputtype'] = 'text';
                    $tp = 1;
                    $newfieldarr['type'] = 1;
                    $newfieldarr['text'] = $value[0][0];
                }else{
                    $newfieldarr['inputtype'] = 'file';
                }
            }
            //duan 20220830 移动端增加下载和预览附件权限参数
            $newfieldarr['previewprofile'] = IsPreviewProfile($this->id,$module);
            $newfieldarr['downloadprofile'] = IsDownLoadProfile($this->id,$module);
        }
        else{
            $tp=1;
        }
        if($fieldinfo->displaytype==2 && ($up!=222 && $up!=69)){
            $tp=10;
        }
        //editor:gyq_20191010 0038232: 企业微信：单据详情界面->单据头字段，如果是数字类型字段，值为0（0.00、0.0），不显示
		//chj 2022-04-11 移动端，字段值为0时，应该显示，如：应收余额为0，文本字段输入0，或者其他字段类型为0时，都应该显示
        /*if($fieldinfo->isFldNumOrMoney()){
            $float_text = (float)$newfieldarr['text'];
            if(empty($float_text))
                return '';
        }
		*/
        if($up==1501||$up==1500||$up==1502||$up==1503){
            $tp = 1500;
        }
        
        //字段值为空，则不返回该字段
        if( empty($newfieldarr['text'])&&$newfieldarr['text']!==0&&$newfieldarr['text']!=='0'&&$tp!=1500&&$weixin_user->environment_weixin){
            //gyq_117 reason:企业微信增加个人资料及修改密码  2019/5/31 16:01 
            if($module == 'Users'){
                $newfieldarr['text'] = '--';
            }elseif($newfieldarr['uitype']==301){
                if(sizeof($newfieldarr['choosedArr'])==0&&sizeof($newfieldarr['options'])==0)
                    return '';     
            }elseif($up==230){
                //duan 20231031 修复富文本框中只有文件时，在移动端无法显示的问题
                if(!empty($this->uitype230) && sizeof($this->uitype230)==0){
                    return '';
                }
            }else{
                return '';   
            }
        }


        if(!is_array($newfieldarr['text'])){
            $newfieldarr['text'] = htmlspecialchars_decode($newfieldarr['text']);
        }
        $newfieldarr['type'] = $tp;
        $newfieldarr['value_name'] = $fieldarr['value_name'];
        if($tp==1500){
            $newfieldarr['text'] = getFixedLabel('VIEW').''.getFixedLabel('SOCIALPROMOTIONQRCODE');//查看二维码;
            $newfieldarr['fieldid'] = $fieldinfo->fieldid;
        }
        // diony 2020.12.17 增加真实姓名
        // 目前仅用于河北慧谷打印，先都注释
//         if ($up == 53) {
//             $user_sql = "select real_name from ld_users where id=".$newfieldarr['secid'];
//             $user_res = $adb->pquery($user_sql);
//             $user_num = $adb->num_rows($user_res);
//             $newfieldarr['real_name'] = $user_num>0?$adb->query_result($user_res,0,'real_name'):'-';
//         }
        return $newfieldarr;
    }
    //editor:gyq_151 reason:移动端，知识管理详情界面插件型备注无法查看PC端上传的附件及图片  2019/10/15 19:24 ID1000623
    //BUG0052842	已分派	系统错误	zxm20220628
    //钉钉端，公告模块，富文本字段中加入图片，钉钉端点开单据查看不到图片。 我测试了 3 个系统，均有此问题。小程序及微信端没问题
    protected function uitype230($r_text,$fieldlabel){
        $list = array();
        $list_i = 0;
        //从HTML字符串中提取图片内容
        $tag = "img";
        $regex =   "/<$tag.*?(.*?)>/is";
        preg_match_all($regex,$r_text,$matches,PREG_PATTERN_ORDER);
        foreach ($matches[0] as $key=>$value){
            $r_text = str_replace($value,'',$r_text);
        }
        if(!empty($matches[1])){
            //模拟图片字段
            $list[$list_i]['fieldname'] = 'imagename';
            $list[$list_i]['typeofdata'] = 'V~O';
            $list[$list_i]['text'] = '';
            $list[$list_i]['uitype'] = 69;
            $list[$list_i]['isadmin'] = 1;
            $list[$list_i]['value_name'] ='';
            $list[$list_i]['phone'] ='no';
            $list[$list_i]['type'] =69;
            $list[$list_i]['previewprofile'] = 'yes';
            $list[$list_i]['downloadprofile'] = 'yes';
            $i =0 ;
            foreach ($matches[1] as $key=>$value){
                if(stripos($value,'storage/ueditor/php/upload')!==false){
                    $content = explode('"',$value);
                    $list_img[$i]['value'] = $content[1];
                    $list_img[$i]['httppath'] = $content[1];
                    $list_img[$i]['storage_location'] = 'local';
                    $list_img[$i]['imgid'] = 0;
                    $i++;
                }
            }
            $list[$list_i]['text'] = $list_img;
            $list_i++;
        }
        //从HTML字符串中提取附件内容
        $tag = "a";
        $regex =   "/<$tag.*?>(.*?)<\/$tag>/is";
        preg_match_all($regex,$r_text,$matches,PREG_PATTERN_ORDER);
        if(!empty($matches[0])){
            //模拟附件字段
            $list[$list_i]['fieldname'] = 'filename';
            $list[$list_i]['typeofdata'] = 'V~O';
            $list[$list_i]['uitype'] = 1109;
            $list[$list_i]['isadmin'] = 1;
            $list[$list_i]['value_name'] ='';
            $list[$list_i]['phone'] ='no';
            $list[$list_i]['type'] =1109;
            $list[$list_i]['previewprofile'] = 'yes';
            $list[$list_i]['downloadprofile'] = 'yes';
            $i =0 ;
            foreach ($matches[0] as $key=>$value){
                $r_text = str_replace($value,'',$r_text);
                if(stripos($value,'storage/ueditor/php/upload')!==false){
                    $content = explode('"',$value);
                    $list_file[$i]['ext'] = 'excle';
                    $list_file[$i]['id'] = 0;
                    $list_file[$i]['imagefromtype'] = '电脑硬盘';
                    $filename = basename($content[3]);
                    $list_file[$i]['name'] = $content[5];
                    $list_file[$i]['newfile_name'] = $filename;
                    $list_file[$i]['httppath'] = str_replace($filename,'',$content[3]).$filename;
                    $list_file[$i]['storage_location'] = 'local';
                    $list_file[$i]['path'] = str_replace($filename,'',$content[3]) ;
                    $file_size = filesize(globalStatic::$root_directory.$content[3]);
                    $list_file[$i]['size'] = cls_StaticCommonFun::trans_byte($file_size);
                    $list_file[$i]['sizeraw'] =$file_size;
                    $list_file[$i]['type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
                    $i++;
                }
            }
            $list[$list_i]['text'] = $list_file;
        }
        //方便在字段列表最后追加模拟的图片和附件字段
        $this->uitype230 = $list;
        //去除空内容的多余html内容<p></p>
        $tag = "p";
        $regex =   "/<$tag.*?>(.*?)<\/$tag>/is";
        preg_match_all($regex,$r_text,$matches,PREG_PATTERN_ORDER);
        foreach ($matches[0] as $key=>$value){
            $content = strip_tags($value);
            if(empty($content)){
                $r_text = str_replace($value,'',$r_text);
            }
        }
        return $r_text;
    }
}


?>