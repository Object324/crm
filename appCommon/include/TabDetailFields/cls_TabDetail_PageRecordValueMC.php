<?php

/**
 * Created by PhpStorm.
 * User: gyq_27
 * Date: 2017/4/7 0007
 * Time: 上午 11:05
 */
crm_load_class_file('cls_TabDetail_PageRecordValue', 'include/TabDetailFields');

class cls_TabDetail_PageRecordValueMC extends cls_TabDetail_PageRecordValue
{
    public function getValues(){
        global $adb;
        
        $currencyobj=Currency::getInstance($adb);
        $allCurrencies = $currencyobj->getAllCurrencies();
        $orignValues = parent::getValues();
        foreach($orignValues['headers'] as $key=>&$fieldcontent){
           
            $defaultInfo = $fieldcontent['defaultInfo'];
            $defaultvalue = '';//gyqNote20170515
            $defaulthiddenvalue = '';
            if(!empty($defaultInfo['optionvalue'])){
                //editor:gyq_20191128 reason:项目工时源单下拉框重新赋值
                if( $this->module=='TimeSheet'&&$fieldcontent['columnname']=='timetype'){
                    //$directArrayOne = array('Direct123'=>'Direct','Indirect123'=>'Indirect');
                    $directArrayTwo = array('Direct'=>'timesheet_direct','Indirect'=>'timesheet_indirect');
                    $directArrayNew = array(0=>array('text'=>'','value'=>''));
                    $directI = 1;
                    foreach($directArrayTwo as $opkey=>$values){
                        $directArrayNew[$directI]['text'] = getFixedLabel($directArrayTwo[$opkey]);
                        $directArrayNew[$directI]['value'] = $opkey;
                        $directI++;
                    }
                    $defaultInfo['optionvalue'] = $directArrayNew;
                }
                $isdefaultMark = 0;
                foreach($defaultInfo['optionvalue'] as $opkey=>$values){
                    if($values['isdefault']==1){
                        $defaultvalue = $values['text'];
                        $defaulthiddenvalue = $values['value'];
                        $isdefaultMark = 1;
                        break;//0028153: 微信端：费用报销新增界面->新增明细->源单类型：源单类型字段没有显示默认值.reason:break写到了if外面
                    }
                }
                if (empty($defaultInfo['optionvalue'][0]['text'])) {//0028147: 微信端：费用报销新增界面：新增明细：费用类别选择界面，有一行空白
                    array_splice($defaultInfo['optionvalue'],0,1);
                }
                /* duan 20230208 BUG0061079:分录下拉框未设置默认值时，移动端打开依旧显示默认值
                if($isdefaultMark==0){
                    $defaultvalue = $defaultInfo['optionvalue'][0]['text'];
                    $defaulthiddenvalue = $defaultInfo['optionvalue'][0]['value'];
                }
                */
            }else{
                $defaultvalue = $defaultInfo['value'];
                $defaulthiddenvalue = $defaultInfo['hiddenvalue'];
            }
            /*if($fieldcontent['columnname']=='entitytype'){
                $defaultvalue = '';
                $defaulthiddenvalue = '';
            }*/
            $orignValues['headers'][$key]['defaultvalue'] = $defaultvalue;
            $orignValues['headers'][$key]['defaulthiddenvalue'] = $defaulthiddenvalue;
            $orignValues['headers'][$key]['text'] = '';
            
            $option = $defaultInfo['optionvalue'];
            if($fieldcontent['columnname']=='currency_id'){//分录币种字段额外增加汇率
                foreach($option as $okey=>$oval){
                    if($okey == 0){
                        $option[$okey]['select'] = 'yes';
                        $orignValues['headers'][$key]['defaultvalue'] = $oval['text'];
                        $orignValues['headers'][$key]['defaulthiddenvalue'] = $oval['value'];
                        $orignValues['headers'][$key]['text'] = $oval['text'];
                    }
                    else{
                        $option[$okey]['select'] = 'no';
                    }
                    foreach($allCurrencies as $ckey=>$cval){
                        if($cval['curid']==$oval['value']){
                            $option[$okey]['conversionrate'] = $cval['conversionrate'];
                            break;
                        }
                    }
                }
                $orignValues['headers'][$key]['option'] = $option;
            }elseif($fieldcontent['columnname']=='rmb_total') {
                //人民币金额异常含币种符号
                $orignValues['headers'][$key]['defaultvalue'] = $fieldcontent['defaultInfo']['hiddenvalue'];
                $orignValues['headers'][$key]['defaulthiddenvalue'] = $fieldcontent['defaultInfo']['hiddenvalue'];
            }else{
                    if(!empty($option)){
                        if(empty($option[0]['text'])){//0028147: 微信端：费用报销新增界面：新增明细：费用类别选择界面，有一行空白
                            unset($option[0]);
                        }

                        $orignValues['headers'][$key]['option'] = $option;
                    }
            }
            $type_data = explode('~',$fieldcontent['typedata']) ;
            $orignValues['headers'][$key]['fieldtype_orign_mc'] =$orignValues['headers'][$key]['fieldtype'];
            $orignValues['headers'][$key]['fieldtype'] = $type_data[1];
            //用于移动端判断
            if($orignValues['headers'][$key]['fieldtype_orign_mc'] == 'Select'){
                $orignValues['headers'][$key]['withcolor'] = 'yes';
                //下拉框根据默认值给颜色
                global $global_picklist_colors_byvalue;
                $color_arr =  $global_picklist_colors_byvalue[$fieldcontent['columnname']];
                $orignValues['headers'][$key]['fieldvaluecolor'] = isset($color_arr[$defaultvalue])?$color_arr[$defaultvalue]:reset($color_arr);
            }
            $fieldvaluecolor = $orignValues['headers'][$key]['fieldvaluecolor'];
            $orignValues['headers'][$key]['fieldvaluecolor'] = empty($fieldvaluecolor)?'':$fieldvaluecolor;
            $fieldplaceholder = $orignValues['headers'][$key]['fieldplaceholder'];
            $orignValues['headers'][$key]['fieldplaceholder'] = empty($fieldplaceholder)?'':$fieldplaceholder;
            
             if(array_key_exists('approvestatus',$this->focus->column_fields)){
                   
                if($this->focus->column_fields['approvestatus']==D_A_S_APPROVED)
                {
                    //审批结束设置允许编辑的字段
                    crm_load_class_file('ApproveFinished','modules/Approve');
                    $approvefinishedobj=ApproveFinished::getInstance($this->focus->module_name,$_REQUEST['record']);
                    $module_name=$this->focus->module_name;
                    $alloweditfield_arr= $approvefinishedobj->getAllowEditField();
                    $tablename=$fieldcontent['tablename'];
                    $columnname=$fieldcontent['columnname'];
                    
                    if(!array_key_exists("$tablename:$columnname:$module_name",$alloweditfield_arr))
                    {
                         $orignValues['headers'][$key]['edit_permission']=1;

                    }
                }
            }
            $orignValues['headers'][$key]['display'] = 'yes';// 20230808 diony 主表字段控制分录字段，双向绑定参数
            unset($orignValues['headers'][$key]['defaultInfo']);
        }
        foreach($orignValues['value'] as $linenum=>$lineval){
            foreach($lineval as $columnname=>$content){
                if(isset($orignValues['value'][$linenum][$columnname]['option'])){
                    unset($orignValues['value'][$linenum][$columnname]['option']);
                }
                if($columnname=='detailid'){
                    $focus = CRMEntity::getInstance($this->module);
                    $orignValues['value'][$linenum][$focus->Detail_table_id]['value']=$content;
                    $orignValues['value'][$linenum][$focus->Detail_table_id]['hiddenvalue']=$content;
                }elseif($columnname=='rmb_total'){//人民币金额异常含币种符号
                    $typeofdata_decmail = 2;
                    $fieldinfo = $this->tabDetailFieldDataobj->TabDetailFields->getFieldInfoobjBykey('columnname',$columnname);
                    if(!empty($fieldinfo)){
                        $typeofdata_decmail = $fieldinfo->gettypeofdata_decmail();
                    }
                    $orignValues['value'][$linenum]['rmb_total']['value']=setNumberFormatEmptySeperator($orignValues['value'][$linenum]['rmb_total']['hiddenvalue'],$typeofdata_decmail);
                    
                }
                //app端OA表单模块起止时间字段不显示秒
                if(($columnname=='starttime'||$columnname=='endtime')&&$_REQUEST['responseType']=='htmlfive'){
                    $orignValues['value'][$linenum][$columnname]['value'] = substr($content['value'],0,-3);
                }
                if($columnname=='startdate'||$columnname=='enddate'){
                    $orignValues['value'][$linenum][$columnname]['hiddenvalue'] = $orignValues['value'][$linenum][$columnname]['value'];
                }
            }
        }
        return $orignValues;

    }
    /**
     * 获取明细行数数据
     * */
    public function getrowDetailValueByDetailId($detailid,$sequenceno='0')
    {
        $showfieldvalueobj=new ShowTabDetailfieldValue($this->focus->fieldobj,$this->module,SHOW_EDITVIEW);
        $showfieldvalueobj->setadbResult('');
        $showfieldvalueobj->setRecorId($this->record);
        $this->createTabDetailsDataobj();
        $columnvalue=$this->tabDetailFieldDataobj->getrowDetailValue($detailid,$sequenceno);
        return $this->getrowvalue($columnvalue,$showfieldvalueobj);

    }
    public function getDetailHeader()
    {
        $orign_header = parent::getDetailHeader(); // TODO: Change the autogenerated stub

        return $orign_header;
    }
    // copy with appCommon\include\ProductDetailsHtml\cls_ProductDetailUitype_PageRecordValueMC.php
    public function getLastRow_Value()
    {
        $haveTotalFieldValue = parent::getLastRow_Value();
        if(in_array($this->module,array('AddJobBill','MinusJobBill','BusinessApply'))){
            //editor:gyq_20190805 reason:和下面的number_format($value['value'],2);重复了，导致数据显示错误
            //zkt 20240429 BUG20240428-69  系统升级后 移动端app部分员工无法提交出差申请单 提示error 问题账号：
            if(count($haveTotalFieldValue)>0&&$haveTotalFieldValue[0]['fieldname']!='total')
                $haveTotalFieldValue[0]['value'] = number_format($haveTotalFieldValue[0]['value'],1);
        }
        $lastRowValue = array();
        if ($_REQUEST['action'] == 'DetailView') {
            foreach ($haveTotalFieldValue as $key => $value) {
                if($value['fieldname']=='total'){
                    $typeofdata_decmail = 2;
                    $fieldinfo = $this->tabDetailFieldDataobj->TabDetailFields->getFieldInfoobjBykey('columnname',$value['columnname']);
                    if(!empty($fieldinfo)){
                        $typeofdata_decmail = $fieldinfo->gettypeofdata_decmail();
                    }
                    $value['value'] = number_format($value['value'],$typeofdata_decmail);
                }
                $lastRowField['label'] = $value['fieldlabel'];
                $lastRowField['value'] = $value['value'];
                $lastRowValue[$key] = $lastRowField;
            }
        } else {
            foreach ($haveTotalFieldValue as $key => $value) {
                $lastRowField = array();
                if ($value['columnname'] == 'noamount') {
                    if (substr($value['value'], 0, 1) == '-') {
                        $lastRowField['text'] = '减少';
                        $adjustment_type = '-';
                    } else {
                        $lastRowField['text'] = '增加';
                        $adjustment_type = '+';
                    }
                    $label = $value['fieldlabel'];
                    $lastRowField['adjustmentType'] = $adjustment_type;
                    $lastRowField['option'] = array(0 => array('text' => '增加', 'value' => '+'), 1 => array('text' => '减少', 'value' => '-'));
                    $lastRowField['value'] = abs($value['value']);
                } else {
                    $lastRowField['value'] = $value['value'];
                }
                $fieldinfo = $this->tabDetailFieldDataobj->TabDetailFields->getFieldInfoobjBykey('columnname',$value['columnname']);
                if(!empty($fieldinfo)){
                    if($fieldinfo->isAmountorCurrencyField()){
                        $typeofdata_decmail = $fieldinfo->gettypeofdata_decmail();
                        $lastRowField['value'] = setNumberFormatEmptySeperator($lastRowField['value'],$typeofdata_decmail);
                    }
                }
                $lastRowField['label'] = $value['fieldlabel'];
                $lastRowValue[$value['columnname']] = $lastRowField;
            }
        }
        return $lastRowValue;
    }
    //获取显示字段和不启用并且有字段公式的字段
    public function getTabDetailFormulaField()
    {
        return $this->tabDetailFieldDataobj->TabDetailFields->getTabDetailFormulaField();
    }
    //获取状态为不显示并且有字段公式的自定义字段
    public function getNoPresenceInputDetailField($tabid)
    {
        $noPresenceField = $this->tabDetailFieldDataobj->TabDetailFields->getNoPresenceInputDetailField($tabid);

        if(!empty($this->actionname)){
            //hzx 产品分录字段权限过滤
            foreach ($this->tabDetailFieldDataobj->tabPresenceDetailFields as $index => $field) {
                if ($field->getDetailsFieldsProfile($this->pagetype_actionarray[$this->actionname]) == 'hidden') {
                    $noPresenceField[$field->getColumnName()] = array(
                        'tabdetailfieldid'=>$field->getTabDetailFieldid(),
                        'columnname'=>$field->getColumnName()
                    );
                }
            }
        }

        return $noPresenceField;
    }
    public function set_entrydetail($action){
        global $weixin_user,$adb,$current_user,$PlatformMC;
        //补充条件$this->qrcodefield若当前为表单码则显示所有字段
        if($weixin_user->environment_weixin||$this->qrcodefield=="yes"){
            $detailshowtype='all';
        }else{
            $detailshowtype='part';
        }
        //费用报销、工时、佣金单
        $tabdetailContent = $this->getValues();
        //新建、编辑页特殊处理
        foreach ($tabdetailContent['headers'] as $key => $fielddetail) {
            if ($fielddetail['bigtype'] == 'image' || $fielddetail['bigtype'] == 'fileattachment') {
                $tabdetailContent['headers'][$key]['local_count'] = 0;
                $tabdetailContent['headers'][$key]['localId']=[];
                $tabdetailContent['headers'][$key]['serverId'] = [];
                $tabdetailContent['headers'][$key]['deletedId'] = [];
            }
        }
        $tabdetailContent['headers'] = array_values($tabdetailContent['headers']);

        if($action=='DetailView') {
            $showfieldslabel = array();//明细显示列字段名
            $tabdetailvalues = $tabdetailContent['value'];
            $detailFieldValue = array();
            //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
            crm_load_class_file('ModuleUtils','modules/lingdang');
            $ModuleUtilsObj = new ModuleUtils();
            $mobiledetailinfoshowtype = $ModuleUtilsObj->getTabDetailShowType(gettabid($this->module));
            $SelectedDetailFields = $ModuleUtilsObj->getSelectedDetailFields($this->module,$mobiledetailinfoshowtype);//获取显示的字段列表
            //zxm 20230317 XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
            $outputContentValues['mobiledetailinfoshowtype'] = $mobiledetailinfoshowtype;
            if($mobiledetailinfoshowtype=='table'){
                //小程序 --返回字段信息
                if (!empty($PlatformMC['type_mini'])) {
                    $outputContentValues['mobiledetailcolumns'] = array_values($SelectedDetailFields);
                }else{
                    //其他移动端
                    $outputContentValues['mobiledetailcolumns'] = _array_column($SelectedDetailFields,'fieldlabel');
                }
            }

            $SelectedDetailFieldsValue = [];

            foreach ($tabdetailContent['headers'] as $key => $fielddetail) {
                $columnname = $fielddetail['columnname'];
                $showfieldslabel[$columnname] = $fielddetail['fieldlabel'];
                $fieldvaluecolor_arr[$columnname] = $fielddetail['fieldvaluecolor'];
                $bigtype_arr[$columnname] = $fielddetail['bigtype'];
                $mobileshow_arr[$columnname] = $fielddetail['mobiledetailshow'];
                $ShowHyperlinks_arr[$columnname] = $fielddetail['ShowHyperlinks'];
            }
            
            //duan 通用设置 单据分录明细是否折叠显示
            //$sql_11 = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type=11 and is_open="yes"';
            //$result_11 = $adb->pquery($sql_11,array($current_user->id));
            //$is_open11 = $adb->num_rows($result_11)>0?'yes':'no';
            
            if($this->module=='Expense'){
                $outputFieldArr = array('expensetype', 'expenseuse','rmb_total','detailid');
                foreach ($tabdetailvalues as $linenum => $content) {
                    $item = 1;
                    $SelectedDetailFieldsValue = [];
                    $tmpSelectedDetailFields = $SelectedDetailFields;
                    foreach ($content as $fieldname => $mixvalue) {
                        if($fieldname=='rmb_total'){ 
                            $typeofdata_decmail = 2;
                            $fieldinfo = $this->tabDetailFieldDataobj->TabDetailFields->getFieldInfoobjBykey('fieldname',$fieldname);
                            if(!empty($fieldinfo)){
                                $typeofdata_decmail = $fieldinfo->gettypeofdata_decmail();
                            }
                            $mixvalue['value'] = number_format($mixvalue['hiddenvalue'],$typeofdata_decmail);
                        }
                        if($detailshowtype=='all'){
                            if(array_key_exists($fieldname,$showfieldslabel)&&(!empty($mixvalue['value'])||$mixvalue['value']===0||$mixvalue['value']==='0')){
                                $tmp_fieldvalue_arr = array('k'=>$showfieldslabel[$fieldname],'v'=>$mixvalue['value']);
                                //duan 移动端单据分录字段增加颜色显示
                                $fieldvaluecolor = $fieldvaluecolor_arr[$fieldname];
                                if($bigtype_arr[$fieldname] == 'picklist'){
                                    global $global_picklist_colors_byvalue;
                                    $all_pick_colors = $global_picklist_colors_byvalue[$fieldname];
                                    $fieldvaluecolor = isset($all_pick_colors[$mixvalue['value']])&&!empty($all_pick_colors[$mixvalue['value']])?$all_pick_colors[$mixvalue['value']]:'#666';
                                }
                                //移动端分录增加关联选择单据跳转
                                if($bigtype_arr[$fieldname] == 'reference' || $bigtype_arr[$fieldname] =='selectsource'){
                                    if(!empty($mixvalue['hiddenvalue'])){
                                        //edit: xll 2023/07/26 BUG0070182 单据分录超链接字段显示超链接控制无效
                                        if( $ShowHyperlinks_arr[$fieldname] == 'yes')
                                            $tmp_fieldvalue_arr['p'] = 'yes';
                                        $tmp_fieldvalue_arr['i'] = $mixvalue['hiddenvalue'];
                                        $tmp_fieldvalue_arr['m'] = getSalesEntityType($mixvalue['hiddenvalue']);
                                        $tmp_fieldvalue_arr['l'] = getTranstab($tmp_fieldvalue_arr['m']);
                                    }
                                }

                                if($bigtype_arr[$fieldname] == 'image' || $bigtype_arr[$fieldname] =='fileattachment'){
                                    $tmp_fieldvalue_arr['u'] = $bigtype_arr[$fieldname];
                                    if(IsPreviewProfile($this->record,$this->module) == 'yes'){
                                        $tmp_fieldvalue_arr['previewprofile'] = 'yes';
                                    }else{
                                        $tmp_fieldvalue_arr['previewprofile'] = 'no';
                                    }
                                    if(IsDownLoadProfile($this->record,$this->module) == 'yes'){
                                        $tmp_fieldvalue_arr['downloadprofile'] = 'yes';
                                    }else{
                                        $tmp_fieldvalue_arr['downloadprofile'] = 'no';
                                    }
                                }
                                if(!empty($fieldvaluecolor)){
                                    $tmp_fieldvalue_arr['c'] = $fieldvaluecolor;
                                }
                                $detailFieldValue[$linenum]['list'][] = $tmp_fieldvalue_arr;
                                //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰） 路总讲把11的判断去掉
                                if(array_key_exists($fieldname,$tmpSelectedDetailFields)&&in_array($mobiledetailinfoshowtype,['fold','table']) ){
                                    //$detailFieldValue[$linenum]['list2'][] = $tmp_fieldvalue_arr;
                                    //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
                                    $tmp_fieldvalue_arr['columnname'] = $fieldname;
                                    $SelectedDetailFieldsValue[$tmpSelectedDetailFields[$fieldname]['ordernum']] = $tmp_fieldvalue_arr;
                                    unset($tmpSelectedDetailFields[$fieldname]);
                                }
                            }
                        }else{
                            if (in_array($fieldname, $outputFieldArr)) {
                                if($fieldname=='detailid') {
                                    $detailFieldValue[$linenum]['entryid'] = $mixvalue;
                                }else{
                                    $detailFieldValue[$linenum]['list'][] = $showfieldslabel[$fieldname] . '：' . $mixvalue['value'];
                                    $item++;
                                }
                            }
                        }
                    }
                    $detailFieldValue[$linenum]['entrytype'] = 'source';
                    $detailFieldValue[$linenum]['sequence_no'] =$linenum;
                    $detailFieldValue[$linenum]['lineitem_id'] = $content['detailid'];
                    //zxm 20230317 字段排序 XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
                    if(!empty($SelectedDetailFields)&&$mobiledetailinfoshowtype=='table'){
                        foreach($SelectedDetailFields as $tmpk=>$tmpv){
                            if(!key_exists($tmpv['ordernum'],$SelectedDetailFieldsValue)) {
                                $SelectedDetailFieldsValue[$tmpv['ordernum']] = ['v' => '--', 'columnname' => $tmpv['prop']];
                            }
                        }
                    }
                    if($mobiledetailinfoshowtype=='fold'||$mobiledetailinfoshowtype=='table') {
                        $key = array_keys($SelectedDetailFieldsValue);
                        array_multisort($key, SORT_ASC, $SelectedDetailFieldsValue);
                        if (!empty($PlatformMC['type_mini'])&&$mobiledetailinfoshowtype=='table') {
                            //小程序返回值
                            $SelectedDetailFieldsValue_minipro = [];
                            foreach($SelectedDetailFieldsValue as $tmpminikey=>$tmpminivalue){
                                $SelectedDetailFieldsValue_minipro[$tmpminivalue['columnname']] = $tmpminivalue['v'];
                                if(!empty($tmpminivalue['c'])){
                                    $SelectedDetailFieldsValue_minipro[$tmpminivalue['columnname'].'Color'] = $tmpminivalue['c'];
                                }
                            }
                            $outputContentValues['minipro_tablelist'][] = $SelectedDetailFieldsValue_minipro;
                        }else{
                            //其他移动端的返回值
                            $detailFieldValue[$linenum]['list2'] = $SelectedDetailFieldsValue;
                        }
                    }
                }
            }
            elseif($this->module=='TimeSheet'){
                foreach ($tabdetailvalues as $linenum => $content) {
                    if($detailshowtype=='all'){
                        $SelectedDetailFieldsValue = [];
                        $tmpSelectedDetailFields = $SelectedDetailFields;
                        foreach($content as $fieldname=>$mixvalue){
                            if(array_key_exists($fieldname,$showfieldslabel)&&(!empty($mixvalue['value'])||$mixvalue['value']===0||$mixvalue['value']==='0')){
                                //editor:gyq_20191128  reason:项目工时源单下拉框重新赋值
                                if($fieldname=='timetype'){
                                    $directArrayTwo = array('Direct'=>'timesheet_direct','Indirect'=>'timesheet_indirect');
                                    $mixvalue['value'] = getFixedLabel($directArrayTwo[$mixvalue['value']]);
                                }
                                $tmp_fieldvalue_arr = array('k'=>$showfieldslabel[$fieldname],'v'=>$mixvalue['value']);
                                //duan 移动端单据分录字段增加颜色显示
                                $fieldvaluecolor = $fieldvaluecolor_arr[$fieldname];
                                if($bigtype_arr[$fieldname] == 'picklist'){
                                    global $global_picklist_colors_byvalue;
                                    $all_pick_colors = $global_picklist_colors_byvalue[$fieldname];
                                    $fieldvaluecolor = isset($all_pick_colors[$mixvalue['value']])&&!empty($all_pick_colors[$mixvalue['value']])?$all_pick_colors[$mixvalue['value']]:'#666';
                                }
                                //移动端分录增加关联选择单据跳转
                                if($bigtype_arr[$fieldname] == 'reference' || $bigtype_arr[$fieldname] =='selectsource'){
                                    if(!empty($mixvalue['hiddenvalue'])){
                                        //edit: xll 2023/07/26 BUG0070182 单据分录超链接字段显示超链接控制无效
                                        if( $ShowHyperlinks_arr[$fieldname] == 'yes')
                                            $tmp_fieldvalue_arr['p'] = 'yes';
                                        $tmp_fieldvalue_arr['i'] = $mixvalue['hiddenvalue'];
                                        $tmp_fieldvalue_arr['m'] = getSalesEntityType($mixvalue['hiddenvalue']);
                                        $tmp_fieldvalue_arr['l'] = getTranstab($tmp_fieldvalue_arr['m']);
                                    }
                                }
                                if($bigtype_arr[$fieldname] == 'image' || $bigtype_arr[$fieldname] =='fileattachment'){
                                    $tmp_fieldvalue_arr['u'] = $bigtype_arr[$fieldname];
                                    if(IsPreviewProfile($this->record,$this->module) == 'yes'){
                                        $tmp_fieldvalue_arr['previewprofile'] = 'yes';
                                    }else{
                                        $tmp_fieldvalue_arr['previewprofile'] = 'no';
                                    }
                                    if(IsDownLoadProfile($this->record,$this->module) == 'yes'){
                                        $tmp_fieldvalue_arr['downloadprofile'] = 'yes';
                                    }else{
                                        $tmp_fieldvalue_arr['downloadprofile'] = 'no';
                                    }
                                }
                                if(!empty($fieldvaluecolor)){
                                    $tmp_fieldvalue_arr['c'] = $fieldvaluecolor;
                                }
                                $detailFieldValue[$linenum]['list'][] = $tmp_fieldvalue_arr;
                                //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰） 路总讲把11的判断去掉
                                if(array_key_exists($fieldname,$tmpSelectedDetailFields)&&in_array($mobiledetailinfoshowtype,['fold','table']) ){
                                    //$detailFieldValue[$linenum]['list2'][] = $tmp_fieldvalue_arr;
                                    //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
                                    $tmp_fieldvalue_arr['columnname'] = $fieldname;
                                    $SelectedDetailFieldsValue[$tmpSelectedDetailFields[$fieldname]['ordernum']] = $tmp_fieldvalue_arr;
                                    unset($tmpSelectedDetailFields[$fieldname]);
                                }
                            }
                        }
                    }else{
                        if($content['timetype']['value']=='Direct'){
                            $detailFieldValue[$linenum]['list'][] = 'Direct|'.$content['entitytype']['value'];
                            $detailFieldValue[$linenum]['list'][] = $content['costtime']['value'];
                        }else{
                            $detailFieldValue[$linenum]['list'][] = 'Indirect|'.$content['indirectcharge']['value'];
                            $detailFieldValue[$linenum]['list'][] = $content['costtime']['value'];
                        }
                    }
                    $detailFieldValue[$linenum]['entryid'] = $content['detailid'];
                    $detailFieldValue[$linenum]['entrytype'] = 'source';
                    $detailFieldValue[$linenum]['sequence_no'] = $linenum;
                    $detailFieldValue[$linenum]['lineitem_id'] = $content['detailid'];
                    //zxm 20230317 字段排序 XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
                    if(!empty($SelectedDetailFields)&&$mobiledetailinfoshowtype=='table'){
                        foreach($SelectedDetailFields as $tmpk=>$tmpv){
                            if(!key_exists($tmpv['ordernum'],$SelectedDetailFieldsValue)) {
                                $SelectedDetailFieldsValue[$tmpv['ordernum']] = ['v' => '--', 'columnname' => $tmpv['prop']];
                            }
                        }
                    }
                    if($mobiledetailinfoshowtype=='fold'||$mobiledetailinfoshowtype=='table') {
                        $key = array_keys($SelectedDetailFieldsValue);
                        array_multisort($key, SORT_ASC, $SelectedDetailFieldsValue);
                        if (!empty($PlatformMC['type_mini'])&&$mobiledetailinfoshowtype=='table') {
                            //小程序返回值
                            $SelectedDetailFieldsValue_minipro = [];
                            foreach($SelectedDetailFieldsValue as $tmpminikey=>$tmpminivalue){
                                $SelectedDetailFieldsValue_minipro[$tmpminivalue['columnname']] = $tmpminivalue['v'];
                                if(!empty($tmpminivalue['c'])){
                                    $SelectedDetailFieldsValue_minipro[$tmpminivalue['columnname'].'Color'] = $tmpminivalue['c'];
                                }
                            }
                            $outputContentValues['minipro_tablelist'][] = $SelectedDetailFieldsValue_minipro;
                        }else {
                            //其他移动端的返回值
                            $detailFieldValue[$linenum]['list2'] = $SelectedDetailFieldsValue;
                        }
                    }
                }
            }
            else{
                /*
                if($this->module=='Commission'){
                    $outputFieldArr = array('source_total', 'amount','detailid');
                }elseif($this->module=='AddJobBill'){
                    $outputFieldArr = array('description','costtime','detailid');
                }elseif($this->module=='MinusJobBill'){
                    $outputFieldArr = array('minusjobtype','costtime','detailid');
                }elseif($this->module=='BusinessApply'){
                    $outputFieldArr = array('traffictype','days','detailid');
                }
                */
                $outputModuleFieldArr['Commission'] = array('source_total', 'amount','detailid');
                $outputModuleFieldArr['AddJobBill'] = array('#rangetime#','costtime','detailid');
                $outputModuleFieldArr['MinusJobBill'] = array('#rangetime#','costtime','minusjobtype','detailid');
                $outputModuleFieldArr['BusinessApply'] = array('#rangetime#','traffictype','days','detailid');


                foreach ($tabdetailvalues as $linenum => $content) {
                    if($detailshowtype=='all'){
                        $SelectedDetailFieldsValue = [];
                        $tmpSelectedDetailFields = $SelectedDetailFields;
                        foreach($content as $fieldname=>$mixvalue){
                            if(array_key_exists($fieldname,$showfieldslabel)&&(!empty($mixvalue['value'])||$mixvalue['value']===0||$mixvalue['value']==='0')){
                                $fieldinfo = $this->focus->detailfieldobj->getFieldInfoobjBykey("columnname", $fieldname);
                                //editor:gyq_20190821 reason:金额字段格式化千分位
                                $mixvalue_n = $mixvalue['value'];
                                if(!empty($fieldinfo)){
                                    $typeofdata_decmail = $fieldinfo->gettypeofdata_decmail();
                                    if($fieldinfo->isAmountorCurrencyField()||$fieldinfo->isFldNumOrMoney()){
                                        $mixvalue_n = setNumberFormat( $mixvalue['value'],$typeofdata_decmail) ;
                                    }
                                }
                                if (!empty($fieldinfo) && $fieldinfo->getFieldType() == "SelectComBox") {//佣金单单据分录为多选框字段的处理（单据详情）
                                    if(is_array($mixvalue_n)){
                                        $mixvalue_n = explode(',',$mixvalue_n);
                                    }else{
                                        $mixvalue_n = str_replace(" |##| ",", ",$mixvalue_n);
                                    }
                                }
                                $tmp_fieldvalue_arr = array('k'=>$showfieldslabel[$fieldname],'v'=>$mixvalue_n);
                                //duan 移动端单据分录字段增加颜色显示
                                $fieldvaluecolor = $fieldvaluecolor_arr[$fieldname];
                                if($bigtype_arr[$fieldname] == 'picklist'){
                                    global $global_picklist_colors_byvalue;
                                    $all_pick_colors = $global_picklist_colors_byvalue[$fieldname];
                                    $fieldvaluecolor = isset($all_pick_colors[$mixvalue_n])&&!empty($all_pick_colors[$mixvalue_n])?$all_pick_colors[$mixvalue_n]:'#666';
                                }
                                //移动端分录增加关联选择单据跳转
                                if($bigtype_arr[$fieldname] == 'reference' || $bigtype_arr[$fieldname] =='selectsource'){
                                    // 用户的关联字段移动端暂无穿透
                                    if(!empty($mixvalue['hiddenvalue']) && $fieldinfo->getReferenceModule() !== 'Users'){
                                        //edit: xll 2023/07/26 BUG0070182 单据分录超链接字段显示超链接控制无效
                                        if( $ShowHyperlinks_arr[$fieldname] == 'yes')
                                            $tmp_fieldvalue_arr['p'] = 'yes';
                                        $tmp_fieldvalue_arr['i'] = $mixvalue['hiddenvalue'];
                                        $tmp_fieldvalue_arr['m'] = getSalesEntityType($mixvalue['hiddenvalue']);
                                        $tmp_fieldvalue_arr['l'] = getTranstab($tmp_fieldvalue_arr['m']);
                                    }
                                }
                                if($bigtype_arr[$fieldname] == 'image' || $bigtype_arr[$fieldname] =='fileattachment'){
                                    $tmp_fieldvalue_arr['u'] = $bigtype_arr[$fieldname];
                                    if(IsPreviewProfile($this->record,$this->module) == 'yes'){
                                        $tmp_fieldvalue_arr['previewprofile'] = 'yes';
                                    }else{
                                        $tmp_fieldvalue_arr['previewprofile'] = 'no';
                                    }
                                    if(IsDownLoadProfile($this->record,$this->module) == 'yes'){
                                        $tmp_fieldvalue_arr['downloadprofile'] = 'yes';
                                    }else{
                                        $tmp_fieldvalue_arr['downloadprofile'] = 'no';
                                    }
                                }
                                if(!empty($fieldvaluecolor)){
                                    $tmp_fieldvalue_arr['c'] = $fieldvaluecolor;
                                }
                                $detailFieldValue[$linenum]['list'][] = $tmp_fieldvalue_arr;
                                //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰） 路总讲把11的判断去掉
                                if(array_key_exists($fieldname,$tmpSelectedDetailFields)&&in_array($mobiledetailinfoshowtype,['fold','table']) ){
                                    //$detailFieldValue[$linenum]['list2'][] = $tmp_fieldvalue_arr;
                                    //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
                                    $tmp_fieldvalue_arr['columnname'] = $fieldname;
                                    $SelectedDetailFieldsValue[$tmpSelectedDetailFields[$fieldname]['ordernum']] = $tmp_fieldvalue_arr;
                                    unset($tmpSelectedDetailFields[$fieldname]);
                                }
                            }
                        }
                    }else{
                        if($this->module=='Commission'){
                            $item = 2;//0028226: 微信端>佣金单查看界面：佣金单有两行明细时，第二行明细中佣金金额没有显示
                            $detailFieldValue[$linenum]['list'][] = $content['entitytype']['value'] . $content['entitytypeid']['value'];
                        }else{
                            $item = 1;
                        }
                        foreach($outputModuleFieldArr[$this->module] as $fieldname){
                            if($fieldname=='detailid'){
                                $detailFieldValue[$linenum]['entryid'] = $content[$fieldname];
                            }elseif($fieldname=='#rangetime#'){
                                $detailFieldValue[$linenum]['list'][]=$content['starttime']['value'].' ~ '.$content['endtime']['value'];
                                $item++;
                            }else{
                                $detailFieldValue[$linenum]['list'][] = $showfieldslabel[$fieldname] . '：' . $content[$fieldname]['value'];
                                $item++;
                            }
                        }
                    }
                    
                    /*
                    foreach ($content as $fieldname => $mixvalue) {
                        if (in_array($fieldname, $outputFieldArr)) {
                            if($fieldname=='detailid'){
                                $detailFieldValue[$linenum]['entryid'] = $mixvalue;
                            }else{
                                $detailFieldValue[$linenum]['item'.$item] = $showfieldslabel[$fieldname] . ':' . $mixvalue['value'];
                                $item++;
                            }
                        }
                    }*/
                    $detailFieldValue[$linenum]['entrytype'] = 'source';
                    $detailFieldValue[$linenum]['sequence_no'] =$linenum;
                    $detailFieldValue[$linenum]['lineitem_id'] = $content['detailid'];
                    //zxm 20230317 字段排序 XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
                    if(!empty($SelectedDetailFields)&&$mobiledetailinfoshowtype=='table'){
                        foreach($SelectedDetailFields as $tmpk=>$tmpv){
                            if(!key_exists($tmpv['ordernum'],$SelectedDetailFieldsValue)) {
                                $SelectedDetailFieldsValue[$tmpv['ordernum']] = ['v'=>'--','columnname'=>$tmpv['prop']];
                            }
                        }
                    }
                    if($mobiledetailinfoshowtype=='fold'||$mobiledetailinfoshowtype=='table') {
                        $key = array_keys($SelectedDetailFieldsValue);
                        array_multisort($key, SORT_ASC, $SelectedDetailFieldsValue);
                        if (!empty($PlatformMC['type_mini'])&&$mobiledetailinfoshowtype=='table') {
                            //小程序返回值
                            $SelectedDetailFieldsValue_minipro = [];
                            foreach($SelectedDetailFieldsValue as $tmpminikey=>$tmpminivalue){
                                $SelectedDetailFieldsValue_minipro[$tmpminivalue['columnname']] = $tmpminivalue['v'];
                                if(!empty($tmpminivalue['c'])){
                                    $SelectedDetailFieldsValue_minipro[$tmpminivalue['columnname'].'Color'] = $tmpminivalue['c'];
                                }
                            }
                            $outputContentValues['minipro_tablelist'][] = $SelectedDetailFieldsValue_minipro;
                        }else {
                            //其他移动端的返回值
                            $detailFieldValue[$linenum]['list2'] = $SelectedDetailFieldsValue;
                        }
                    }
                }
            }
        }
        else{
            if($action=='CreateView'&&empty($tabdetailContent['value'][0]['entitytype']['value'])){
                $detailFieldValue = array();
            }else{
                $detailFieldValue = $tabdetailContent['value'];

                foreach($detailFieldValue as $key=>$val){
                    unset($detailFieldValue[$key]['detailid']);
                    if($_REQUEST['isDuplicate']=='yes'||$action=='CreateView') unset($detailFieldValue[$key]['expensedetailid']);
                    if ($action=='EditView' && $this->module=='TimeSheet' && isset($val['timetype'])){
                        //editor:gyq_20191128 reason:项目工时源单下拉框重新赋值
                        $directArrayTwo = array('Direct'=>'timesheet_direct','Indirect'=>'timesheet_indirect');
                        $detailFieldValue[$key]['timetype']['value'] = getFixedLabel($directArrayTwo[$val['timetype']['value']]);
                    }

                    //佣金单单据分录为多选框字段的处理（单据编辑）
                    foreach($val as $fieldname=>$mixvalue){
                        $tmp_fieldinfo = $this->focus->detailfieldobj->getFieldInfoobjBykey("columnname", $fieldname);
                        if (!empty($tmp_fieldinfo) && $tmp_fieldinfo->getFieldType() == "SelectComBox") {
                            $detailFieldValue[$key][$fieldname]['value'] = str_replace(" |##| ",", ",$mixvalue['value']);
                        }
                    }
                    foreach($tabdetailContent['headers'] as $fieldnum=>$field_info){
                        if(($field_info['bigtype'] == 'image' || $field_info['bigtype'] == 'fileattachment') && $val[$field_info['columnname']]){
                            $attr_info = [];
                            if($val[$field_info['columnname']]['value'] && count($val[$field_info['columnname']]['value']) > 0){
                                $cls_MyCRMcrypt = new cls_MyCRMcrypt();
                                $value_arr = $val[$field_info['columnname']]['value'];
                                for($j=0;$j<count($value_arr);$j++){
                                    $tmp_info = [];
                                    $tmp_info['filename'] = $value_arr[$j]['filename'];
                                    $tmp_info['filesize'] = $value_arr[$j]['filesize'];
                                    $tmp_info['filetype'] = $value_arr[$j]['filetype'];
                                    $tmp_info['filepath'] = $value_arr[$j]['filepath']; //$cls_MyCRMcrypt->decode($value_arr[$j]['filepath'])
                                    $tmp_info['newfile_name'] = $value_arr[$j]['newfile_name']; //$cls_MyCRMcrypt->decode($value_arr[$j]['newfile_name'])
                                    $tmp_info['cloud_path'] = $value_arr[$j]['cloud_path']; //$cls_MyCRMcrypt->decode($value_arr[$j]['cloud_path'])
                                    $tmp_info['id'] = $value_arr[$j]['id'];
                                    $tmp_info['storage_location'] = $value_arr[$j]['storage_location'];
                                    $tmp_info['upload_from'] = $value_arr[$j]['upload_from'];
                                    $tmp_info['isEncrypt'] = 'no';
                                    $attr_info[] = $tmp_info;
                                }
                            }
                            $detailFieldValue[$key][$field_info['columnname']]['value'] = $attr_info;
                            $detailFieldValue[$key][$field_info['columnname']]['hiddenvalue'] = $attr_info;
                        }
                    }
                }
            }
            $outputContentValues['listfield'] = $tabdetailContent['headers'];//headers中的字段缺少fieldtype
            $outputContentValues['listformulafield']=$this->getTabDetailFormulaField();
            $outputContentValues['nopresencefield']=$this->getNoPresenceInputDetailField(getTabid($this->module));
        }
        $lastRowValue = $this->getLastRow_Value();//QQ整单折扣信息不全      \      编辑时最后一行合计空值
        if($detailshowtype=='part') $outputContentValues['blocklabel'] = getTranstab($this->module).getFixedLabel('INFORMATION');
        $outputContentValues['list'] = $detailFieldValue;
        $outputContentValues['p_total'] = $lastRowValue;
        $outputProductValues['productdetail'] = 'no';//默认为no，收付款单另做判断
        return $outputContentValues;
        //$this->jsonArr['entry'] = $outputContentValues;
    }




}