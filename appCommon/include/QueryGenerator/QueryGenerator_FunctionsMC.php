<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/3/15 0015
 * Time: 上午 10:14
 */
class QueryGenerator_FunctionsMC
{
    public $default_quantity;
    public $applicationScene;//应用场景
    //editor:gyq_32  data:20170519 reason:移动端序时簿显示列内容统一
    public function getListViewEntries($focus, $module,$list_result,$approvestatus)
    {
        global $adb,$PlatformMC,$weixin_user;
        crm_load_class_file('cls_StaticCommonFun','WeiXinApp/WeiXin_common');
        $columnlist_show = $this->getColumnsListByModule($module);
        $mixedDisplayColumns = $columnlist_show['complex'];
        if($_REQUEST['action']=='getMoreDetailInfo'&&$_REQUEST['type']=='relation'){
            $mixedDisplayColumns = $this->unsetFrommoduleField($mixedDisplayColumns);
        }
        // @edit:dong @date:2020/08/05 @reason: 移动端，查重列表界面显示字段根据设置查重字段设置显示
        if($_REQUEST['action'] =='duplicate_related_popu_multifields'){
            $mixedDisplayColumns=array();
            //wym 240416 查重类文件结构优化
            crm_load_class_file('cls_DuplicateColumn','modules/lingdang');
            $duplicate_obj=cls_DuplicateColumn::getInstance($module);
            $filecontent_str = $duplicate_obj->getDuplicateColumnDisplaySetting(1);
            foreach ($filecontent_str as $key=>$value){
                $mixedDisplayColumns[][]=$value;
            }
        }
        //下拉框对象,用于获取下拉框颜色
        global $global_picklist_colors_byvalue;
        crm_load_class_file("cls_PickList_Ori",'include/Functions/PickList');
        $picklistobj = new cls_PickList_Ori();
        $indexfield[0]['columnname'] = $focus->table_index;
        $indexfield[0]['tablename'] = $focus->table_name;
        $indexfield[0]['type'] = 'index';
        $mixedDisplayColumns[] = $indexfield;
        $num_rows = $adb->num_rows($list_result);
        $detail_value = array();
        $data_recordid = array();
        $baseTable =$focus->table_name;
        $moduleTableIndexList = $focus->tab_name_index;
        $baseTableIndex = $moduleTableIndexList[$baseTable];
        $real_i = 0;//gyq_122
        crm_load_class_file("cls_fieldSensitiverule", "include/fields");
        $displayfieldname_arr=[];

        foreach ($mixedDisplayColumns as $row => $detail)
        {

            foreach ($detail as $list => $content) {
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$content['columnname']);
                if($fieldinfo)
                    $displayfieldname_arr[]=$fieldinfo->getFieldName();
            }
        }

        for ($i = 0; $i < $num_rows; $i++) {
            //0027082: （微信端）合同订单：全部页签下，显示了5条一样的单据，应该只显示1条，pc端上这条单据对应有5个产品明细
            if($module != 'Users') {
                $recordId = $adb->query_result($list_result,$i,$baseTableIndex);
            }else {
                $recordId = $adb->query_result($list_result,$i,"id");
            }
            // @edit:dong @date:2020/08/07 @reason: 查重多个联系人显示多条
            if($_REQUEST['action'] !='duplicate_related_popu_multifields') {
                //去重
                if (in_array($recordId, $data_recordid)) {
                    continue;
                }
            }
            $data_recordid[] = $recordId;
            $naturalrow = 0;
            $titlerow = 0;

            //zkt 20231113 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制

            $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($module);
            $cls_fieldSensitiveruleobj->resetobj($module,$recordId);
            $cls_fieldSensitiveruleobj->setSensitiveFieldRange($this->listViewFields);
            $tmp_columnvalue=$adb->query_result_rowdata($list_result,$i);
            $cls_fieldSensitiveruleobj->setColumnValues($tmp_columnvalue);
            //XUQIU20240703-03 敏感规则，增加“禁用场景”参数，支持自定义设置模块列表或相关信息列表加密方式生效范围（安康金源）
            $applicationScene = $this->getApplicationScene();
            $cls_fieldSensitiveruleobj->setApplicationScene($applicationScene);
            $cls_fieldSensitiveruleobj->setSensitiveFieldRange($displayfieldname_arr);
            $sensitiveresultinfo = $cls_fieldSensitiveruleobj->getSensitiveResultInfobyColumnname();

            foreach ($mixedDisplayColumns as $row => $detail) {
                $listcontent = array();

                $rowmark = 0;

                foreach ($detail as $list => $content) {
                    $valuecolumn = $content['columnname'];

                    //@edit:liushuai,2020-12-09,reason:0043632: 企业版、客户001、销售360：移动端模板模块列表定制>客户>新增联系人微信（有数据）>用移动端查看客户>列表页联系人微信显示无
                    if(($content['tablename']=='ld_contactdetails' || $content['tablename']=='ld_contactscf')&&$module!='Contacts'){
                        $valuecolumn = 'products_'.$content['columnname'];
                    }
                    $value = $adb->query_result($list_result, $i, $valuecolumn);
                    $value = html_entity_decode(trim((string)$value));
                    if($content['type']==10){
                        $this->set_special_type10($content,$detail_value,$value,$real_i,$module);

                        continue;
                    }elseif( $content['type']==='index'){
                        $detail_value[$real_i]['curid'] = $value;
                        $this->set_detail_value($detail_value,$approvestatus,$value,$real_i);

                        continue;
                    }else{

                        // @edit:dong @date:2020/08/05 @reason: 移动端，客户查重列表界面显示字段根据设置查重字段设置显示
                        if($_REQUEST['action'] =='duplicate_related_popu_multifields'){
                            $focus = CRMEntity::getInstance($content['module']);
                        }
                        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname', $content['columnname']);

                        if(empty($fieldinfo)) continue;
                        $label_style = $fieldinfo->getLabelStyle();//wsh 标签颜色
                        //zxm 20240819 默认值  要放在这里
                        if($_REQUEST['frommodule'] == 'Shopping'&& $fieldinfo->getColumnName() == 'imagename'){
                            $detail_value[$real_i]['image_url'] = 'themes/images/noshopimg.jpg';
                        }
                        if($_REQUEST['frommodule'] == 'Shopping' && $fieldinfo->getColumnName() == 'unit_price'){
                            $ShoppingMallFocus = CRMEntity::getInstance('ShoppingMall');
                            //如果有开启产品属性 需要读取默认属性组合的价格 //zxm @date:2024/10/29 @reason:
                            if($ShoppingMallFocus->ProductPropertyIsActive=='no') {
                                //价格策略
                                $value = $ShoppingMallFocus->getShopProPrice($recordId,$value,1);
                            }else{
                                crm_load_class_file('ProductPropertyUtils', 'modules/Products');
                                //先获取默认的属性组合
                                $defaultproperty_info = ProductPropertyUtils::getDefaultPropertyByProductid($recordId);
                                $productdetail_lineitem_id_str = implode(',',array_values($defaultproperty_info));

                                $productproperty_info = ProductPropertyUtils::getPropertyInfoByProductDetailId($productdetail_lineitem_id_str);
                                $tmpproductdetail_lineitem_id = $defaultproperty_info[$recordId];
                                //开启产品属性的产品才去找属性组合的价格
                                if(isset($productproperty_info[$tmpproductdetail_lineitem_id])&&$productproperty_info[$tmpproductdetail_lineitem_id]>0) {
                                    //开启属性的 就不计算价格策略了
                                    $value = $productproperty_info[$tmpproductdetail_lineitem_id]['line_unit_price'];//取按属性设置的价格
                                }else{
                                    //价格策略
                                    $value = $ShoppingMallFocus->getShopProPrice($recordId,$value,1);
                                }
                            }
                        }
                        $showobjvalue = new ShowFieldValue($focus->fieldobj, $module, SHOW_POPUP);

                        $showobjvalue->setadbResult($list_result);
                        $showobjvalue->setLine_index($i);
                        $showobjvalue->setRecorId($recordId);
                        $detail_value2 = $showobjvalue->getFieldValueByField($fieldinfo, $value, $value);

                        $trueValue = $detail_value2['value'];
                        $db_trueValue = $detail_value2['value'];
                        $orgin_value = $detail_value2['value'];
                        $rawvalue = $detail_value2['rawvalue'];

                        $orgin_fieldlabel = '';
                        $fieldvaluecolor = '';
                        $columnname = $fieldinfo->getColumnName();
                        //duan 20221031 移动端列表页增加翻译显示
                        if($fieldinfo->getBigType() == 'picklist'){
                            $picklistobj->getPickListValues($fieldinfo->getFieldName(),$fieldinfo);
                            $color_arr = $global_picklist_colors_byvalue[$fieldinfo->getFieldName()];
                            $fieldvaluecolor = isset($color_arr[$trueValue])&&!empty($color_arr[$trueValue])?$color_arr[$trueValue]:'';
                        }else if($fieldinfo->getBigType() == 'translatefield'){
                            //读取颜色设置
                            $translate_dbvalues= getTranslateDbValueNew($module,$columnname);
                            if(!empty($translate_dbvalues[$rawvalue]) && !empty($translate_dbvalues[$rawvalue]['value_color'])){
                                $fieldvaluecolor=$translate_dbvalues[$rawvalue]['value_color'];
                            }
                        }
                        else{
                            $fieldvaluecolor = $fieldinfo->getFieldValueColor();
                            if(empty($fieldvaluecolor)) $fieldvaluecolor = '';
                        }

                        //手机字段
                        //editor:gyq_149 reason:移动端手机号显示样式  2019/10/14 17:29 ID1000522
                        //editor:gyq_20191111 reason:移动端序时簿手机，企业微信H5和钉钉都可以拨号
                        //0038360: （kfbcrm）钉钉手机端，单据列表界面手机字段电话不能呼叫（联系人模块测试）（邱：做微信小程序时，做了特殊判断，微信小程序直接返回电话号码不能点击，这个后台返回参考企业微信处理，做好这个记得测试是否能够正常使用。）
                        if($fieldinfo->getUIType()==1101&&!empty($value)&&is_numeric($value)){
                            $deploy_content = getSys_deploy(80);
                            $value_80 = $deploy_content['deploy_value'];
                            if($value_80==0){
                                //editor:gyq_20181119 reason:微信同样受手机号码样式限制 2018/11/19 15:56
                                if($weixin_user->environment=='weixinh5'||$weixin_user->environment=='dingtalk'||$weixin_user->environment=='yunzhijia'||$weixin_user->environment=='fanwei'){
                                    $trueValue = '<a onclick="event.stopPropagation();" style="color:'.$fieldvaluecolor.'" href="tel:'.$trueValue.'">'.$trueValue.'</a>';
                                    $orgin_value = $trueValue;
                                }
                                else{
                                    // $trueValue = $trueValue."isphone";
                                    $trueValue = $trueValue;
                                }
                            }
                        }
                        //// @edit:dong @date:2020/08/07 @reason:移动端，客户查重列表界面显示字段根据设置查重字段设置显示 字段都需要显示字段名
                        // @edit:dong @date:2020/08/10 @reason: bug 0042321 除“客户名称”不显示字段名称外，其他字段都显示字段名称
                        if($_REQUEST['action'] =='duplicate_related_popu_multifields' && $fieldinfo->getColumnName() != 'accountname'){
                            $trueValue = $fieldinfo->getFieldLabel().'：'.$trueValue;
                        }
                        if (empty($trueValue)&&$trueValue!==0&&$trueValue!=='0') {//0028974: 名片申请，当印刷数量为0时，列表显示为 --
                            //$trueValue = '--'; //gyq161215
                            if(!empty($fieldinfo)){
                                $trueValue = $fieldinfo->getFieldLabel().'：无';//edit:xxs date:2017-11-22
                                $orgin_fieldlabel = $fieldinfo->getFieldLabel().'：';
                                $orgin_value = '无';
                                $title_value = '<span style="'.$label_style.'">' .$fieldinfo->getFieldLabel().': 无</span>';
                            }else{
                                $trueValue = '--';
                                $orgin_value = '--';
                                $title_value = $trueValue;
                            }
                        }elseif(!empty($fieldinfo)&&$content['showtag']=='yes'){
                            $orgin_fieldlabel = $fieldinfo->getFieldLabel().'：';

                            $title_value = '<span style="'.$label_style.'">' .$fieldinfo->getFieldLabel().': </span>'.'<span style="color:'.$fieldvaluecolor.'">' .$trueValue.' </span>';
                            $trueValue = $fieldinfo->getFieldLabel().'：'.$trueValue;
                        }else{
                            $title_value = '<span style="color:'.$fieldvaluecolor.'">' .$trueValue.' </span>';
                        }

                        //工单管理列表页显示工单状态图标
                        if($module =='WorkSheet'&&$valuecolumn == 'worksheet_status'){
                            $detail_value[$real_i][$valuecolumn] = $detail_value2['value'];
                        }
                        // 2024-10-14 xxy 移动端，消息中心，相关模块为工作汇报列表时，相关对象显示不正确，pc端也有这样的处理
                        if ($module == 'Reminds' && $valuecolumn == 'related_to') {
                            $reltab = $adb->query_result($list_result, $i, "reltab");
                            if ($reltab == 'WorkReportList' && !empty($recordId) && !empty($value)) {
                                $orgin_value = getRelatedtoValue($recordId,$reltab,$value);
                            }
                        }
                        //if($content['type']==2){  editor:gyq data:20170607 reason:弃用type=2等类型
                        //联系人列表界面增加拨打电话功能 date:20180105 xxs
                        //if($valuecolumn=='mobile'&&$module=='Contacts') $detail_value[$real_i]['hidden'] = $value;
                        if($titlerow==0){
                            $detail_value[$real_i]['title'][] = $title_value;
                            $title_color = $fieldvaluecolor;
                        }else{

                            //zxm 20201222 以下注释的三行 0038987: （ancrm）服务小程序，选择单据界面，单据显示的字段应该根据“移动端模块列表定制”控制显示
                            // if($_REQUEST['miniprogram'] == 'zizhufuwu'){
                            //     $listcontent[] = $trueValue;
                            // }
                            // else{
                            if($_REQUEST['frommodule'] == 'Shopping' && $fieldinfo->getColumnName() == 'unit_price'){
                                $detail_value[$real_i]['price'] = decode_html($db_trueValue);
                            }else if($_REQUEST['frommodule'] == 'Shopping' && $fieldinfo->getColumnName() == 'imagename'){
                                $detail_value[$real_i]['image_url'] = $focus->getImageUrl($recordId,'one');
                            }else{
                                if($list == 0){
                                    $listcontent[0] = $trueValue;
                                }else{
                                    $listcontent[1][] = $trueValue;
                                }
                                $rowmark = 1;
                            }
                            // }
                        }
                        if($titlerow>0){
                            //移动端增加颜色显示
                            $len = sizeof($detail);
                            if($list < $len -1){
                                $shu = ' | ';
                            }else{
                                $shu = ' ';
                            }
                            $detail_value[$real_i]['newfield'][$row][$list] = array('label'=>'<span style="'.$label_style.'">' .$orgin_fieldlabel.' </span>','value'=>$orgin_value,'fieldvaluecolor'=>$fieldvaluecolor,'shu'=>$shu);
                        }
                        $titlerow++;
                    }
                }

                if(!empty($rowmark)){
                    if(!empty($listcontent[1])){
                        $listcontent[1] = implode(' | ',$listcontent[1]);
                    }
                    if($PlatformMC['type']=='weixin') $listcontent = implode(' | ',$listcontent);
                    $detail_value[$real_i]['field'][$naturalrow] = htmlspecialchars_decode($listcontent);
                    $naturalrow++;
                }
            }

            //泰康特殊开发，相关信息列表页显示终端用户（供应商）单据到当前位置的距离
            crm_load_class_file("cls_TaiKangSignin",'WeiXinApp/modules/Vendors');
            $taikangobj = new cls_TaiKangSignin();
            if($taikangobj->JudgeVersion() == 'yes'){
                $distance  = $adb->query_result($list_result,$i,"tmp_distance");
                if($distance != '' || ($distance === 0|| $distance === '0')){
                    $distance_info = array('label'=>getFixedLabel('DISTANCE').' : ','value'=>$distance.'('.getFixedLabel('metre').')');
                    $detail_value[$real_i]['newfield'][$row+1][0] = $distance_info;
                    $detail_value[$real_i]['field'][$naturalrow] = getFixedLabel('DISTANCE').': '.$distance.'('.getFixedLabel('metre').')';
                }
            }
            //duan 20221209 拜访签到模块列表特殊处理，获取关联单据id
            if($module == 'Singin'){
                $detail_value[$real_i]['fromid'] = $adb->query_result($list_result,$i,"record");
                $detail_value[$real_i]['fromtabid'] = $adb->query_result($list_result,$i,"tabid");
                $detail_value[$real_i]['userid'] = $adb->query_result($list_result,$i,"userid");
                $detail_value[$real_i]['signedout'] = empty($adb->query_result($list_result,$i,"signout_id"))?'no':'yes';//是否已签退
            }
            if(is_array($detail_value[$real_i]['newfield'])){
                $detail_value[$real_i]['newfield'] = array_values($detail_value[$real_i]['newfield']);
            }else{
                $detail_value[$real_i]['newfield'] = [];
            }

            $detail_value[$real_i]['isphone'] = 'no';
            $detail_value[$real_i]['phone'] = '';
            $detail_value[$real_i]['phonetext'] = '';
            if(is_array($detail_value[$real_i]['title'])){
                $detail_value[$real_i]['title'] = implode(' | ',$detail_value[$real_i]['title']);
            }else{
                $detail_value[$real_i]['title'] = '';
            }

            if($focus->module_name=='CashBill'&&$adb->query_result($list_result,$i,'cashtype')=='debuction'){
                $detail_value[$real_i]['title'].='('.getFixedLabel('CreateDebuction').')';
            }
            //$detail_value[$real_i]['title_color'] = $title_color;

            //0031580: 企业微信>灵当CRM>工作汇报>勾选拜访客户：带出的单据，前面的那个客户名称去掉。
            $hiddentitle = $adb->query_result($list_result,$i,$focus->list_link_field);
            if(empty($hiddentitle)) $hiddentitle=$detail_value[$real_i]['title'];
            //是否为外部联系人
            $detail_value[$real_i]['hiddentitle'] = $hiddentitle;
            //20230614 duan 移动端多选产品时，带出当前模块的数量字段默认值
            $detail_value[$real_i]['hiddenqty'] = $this->get_quantity_defaultvalue($module);//前端选择批次和选择客户、源单等是同一个js
            $detail_value[$real_i]['select'] = 'no';//移动端
            $version_info = getVersionInfo();
            // if($PlatformMC['type']=='weixin'&&$module=='Contacts'&&(cls_StaticCommonFun::isExternalContactUser()||$version_info['trade'] == 'yongdingcheng')){
            //之前只有导入外部联系人的用户才可以被关联，后来yongdingcheng要求手动创建的联系人也可以被关联，实际上可以把条件去掉（所有未被关联的联系人都显示关联按钮）
            if($PlatformMC['type']=='weixin'&&$module=='Contacts'){
                $result = $adb->pquery('select IFNULL(weixin_external_userid,\'\') from ld_contactdetails where contactid=?',array($recordId));
                $detail_value[$real_i]['ec_userid'] = $adb->query_result($result,0,0);
                //东贸 - 48361: （企业微信）企业微信PC端侧边栏：点击【去关联】进入联系人列表界面，当前已经关联过的联系人，不需要显示【关联】按钮
                if($version_info['account'] == 'dongmao' && empty($detail_value[$real_i]['ec_userid'])){
                    $result = $adb->pquery('select IFNULL(unionid_external_userid,\'\') from ld_contactdetails where contactid=?',array($recordId));
                    $detail_value[$real_i]['ec_userid'] = $adb->query_result($result,0,0);
                }
            }
            $real_i++;
        }

        return $detail_value;
    }
    //相关信息中不显示客户字段信息 date:2018-01-04 xxs
    protected function unsetFrommoduleField($mixedDisplayColumns){
        foreach($mixedDisplayColumns as $fkey=>$fval){
            foreach($fval as $skey=>$sval){
                if($sval['columnname']=='accountid') unset($mixedDisplayColumns[$fkey][$skey]);
            }
            if(empty($mixedDisplayColumns[$fkey])) unset($mixedDisplayColumns[$fkey]);
        }
        $mixedDisplayColumns = array_values($mixedDisplayColumns);
        return $mixedDisplayColumns;
    }
    //data:20170503 reason:审批中心序时簿还在插入审批状态
    protected function set_detail_value(&$detail_value,$approvestatus,$value,$real_i){
        return false;
    }
    //联系人序时簿电话显示
    protected function set_special_type10($content,&$detail_value,$value,$real_i,$module){
        if($module=='Contacts'&&$content['columnname'] == 'mobile'){
            $phonenumbers = array();
            //$phonenumbers = array_diff(explode(',',$value),array(''));
            $phonenumbers_str = explode(',',$value);
            foreach($phonenumbers_str as $val){
                if(!empty($val)){
                    $temp_val = cls_StaticCommonFun::checkPhone($val);
                    if(!empty($temp_val)){
                        $phonenumbers[] = $temp_val;
                    }
                }
            }
            $phonenumbers = array_unique($phonenumbers);
            $detail_value[$real_i]['hidden'] = implode(',',$phonenumbers);

        }else{
            $detail_value[$real_i]['hidden'] = $value;
        }

    }

    public function getColumnsListByModule($module){
        if($module == 'Products' && $_REQUEST['frommodule'] == 'Shopping'){
            //zxm 20240819 BUG20240816-75 	企业微信移动端，产品设置了产品图片后，订货商城界面，列表图片没有更新  缓存相互影响了
            $cachekey = 'cache_modulelist_getcvcolumnlist_ShoppingProducts_getcvcolumnlist_MC';
        }
        else{
            $cachekey = 'cache_modulelist_getcvcolumnlist_' . $module . '_getcvcolumnlist_MC';
        }
        $cachemodulelistview = CacheDirectory($cachekey, 'customview');
        if (!$cachemodulelistview) {
            $columnlistNew = $this->init_ColumnsListByModule($module,null);
            CacheDirectory($cachekey, 'customview', $columnlistNew);
            return $columnlistNew;
        } else {
            return $cachemodulelistview;
        }
    }
    //类似ProductDetails中，获取序时簿字段
    public function getSelectColumn_SQL($module){
        global $adb;
        $sSQL = "SELECT columnname as columns from ld_cvcolumnlist_wx WHERE presence=0 AND modulename=? 
                order by rownumber,listnumber,id";
        $result = $adb->pquery($sSQL, array($module));
        return $result;
    }
    public function init_ColumnsListByModule($module){
        global $adb;
        $sSQL = "SELECT rownumber,listnumber,columnname,type,showtag from ld_cvcolumnlist_wx WHERE presence=0 AND modulename=? 
                order by rownumber,listnumber,id";
        $result = $adb->pquery($sSQL, array($module));
        $nums = $adb->num_rows($result);
        $columnlist = array();
        $columnlist_standard=array();
        for ($i = 0; $i < $nums; $i++) {
            $rownumber = $adb->query_result($result, $i, 'rownumber');
            $listnumber = $adb->query_result($result, $i, 'listnumber');
            $columnname = $adb->query_result($result, $i, 'columnname');
            $columninfo = explode(':',$columnname);
            if(($columninfo[0]=='ld_contactdetails'||$columninfo[0]=='ld_contactscf')&&!vtlib_isModuleActive('Contacts')) continue;
            //联系人手机字段特殊处理
            if($columninfo[0]=='ld_contactdetails'&&$columninfo[2]=='pphone'){
                $columninfo[2] = 'phone';
                $columnname = implode(':',$columninfo);
            }
            $type = $adb->query_result($result, $i, 'type');
            $showtag = $adb->query_result($result, $i, 'showtag');
            $columnlist[$rownumber][$listnumber] = array($columnname,$type,$showtag);
            $columnlist_standard[$i]=$columnname;
        }
        ksort($columnlist);
        foreach ($columnlist as $key => $value) {
            ksort($value);
            $valuecolumnlist = array();
            foreach ($value as $key2 => $field) {
                $valArr = explode(':', $field[0]);
                $valuecolumnlist[$key2]['columnname'] = $valArr[1];
                $valuecolumnlist[$key2]['tablename'] = $valArr[0];
                $orignColumnList[] = $valuecolumnlist[$key2];
                $valuecolumnlist[$key2]['type'] = $field[1];
                $valuecolumnlist[$key2]['showtag'] = $field[2];
            }
            $columnlistComplex[$key] = array_values($valuecolumnlist);
        }
        //订货商城
        if($_REQUEST['frommodule'] == 'Shopping'){
            global $adb;
            $focus = CRMEntity::getInstance('ShoppingMall');//订货商城模块
            $fieldobj = Field::getInstance('Products', $adb);
            $modulefields = $fieldobj->getModuleFields();
            $list_fieldname = $focus->getlist_fieldname();//获取订货商城显示的字段

            foreach($list_fieldname as $fieldname){
                $field = $modulefields[$fieldname];
                if(!empty($field)){
                    $showtag = 'yes';
                    if($fieldname == 'productname'){
                        $showtag = 'no';
                    }
                    $complex[][0] = array(
                        'columnname' => $field->getColumnName(),
                        'tablename' => $field->getTableName(),
                        'type' => '0',
                        'showtag' => $showtag,
                    );
                    $orign[] = array(
                        'columnname' => $field->getColumnName(),
                        'tablename' => $field->getTableName(),
                    );
                    $base[] = $field->getTableName().':'.$field->getColumnName().':'.$fieldname.':Products_'.$field->getFieldLabel().':V';
                }

            }
            $columnlistNew['complex'] = $complex;
            $columnlistNew['orign'] = $orign;
            $columnlistNew['base'] = $base;
        }else{
            $columnlistNew['complex'] = array_values($columnlistComplex);
            $columnlistNew['orign'] = $orignColumnList;
            $columnlistNew['base'] = $columnlist_standard;
        }


        return $columnlistNew;

    }
    //gyqCom0315 reaosn:移动端模糊查找 date:20170315
    public function addsearchContent($QueryGenerator,$platform){
        $this->setSearchConditions($QueryGenerator,$platform);
        $QueryGenerator->addUserSearchConditions($_REQUEST);
    }
    // editor:gyq_17 reason:根据显示的字段初始化高级查找条件 date:20161014
    public function setAdvanceFilter($QueryGenerator,$platform){
        $_REQUEST['search_appmark'] = 1;
        $moduleFields =$QueryGenerator->fieldobj->getModuleFields();
        $columnlist_weixin_copy = $QueryGenerator->customview->getColumnsListByCvid(null);
        foreach($columnlist_weixin_copy as $key=>$val){
            $name = explode(':',$val);
            $field = $moduleFields[$name[2]];
            //gyqX161107
            if(!empty($field)){
                if($QueryGenerator->isDateType($field->getFieldDataType())){
                    $appmark = 0;
                    $value = getValidDBInsertDateTimeValue($_REQUEST['searchcontent']);
                    if(empty($value)){
                        //editor:gyq_17  Bug:0025159: 手机端 应用 公告 列表查询 根据 开始日期 负责人 进行查询 查不到数据
                        preg_match_all("/^[0-9-: ]*$/", $_REQUEST['searchcontent'], $match);
                        if(empty($match[0][0])){
                            unset($columnlist_weixin_copy[$key]);
                        }
                    }
                }
            } else{
                unset($columnlist_weixin_copy[$key]);
            }
        }
        $columnlist_weixin_copy_final = array_values($columnlist_weixin_copy);
        return $columnlist_weixin_copy_final;
    }
    //editor:gyq_17
    protected function setSearchConditions($QueryGenerator,$platform){
        global $adb;
        $result = array();
        if(!empty($_REQUEST['searchcontent']) || !empty($_REQUEST['session_search_criteria'])) {
            if (!empty($_REQUEST['select_option_value'])) {//客户查重
                $select_option_arr = explode('|', $_REQUEST['select_option_value']);
                $fieldinfo = $QueryGenerator->moduleobj->fieldobj->getFieldInfoobjBykey('columnname', $select_option_arr[1]);
                $columnname = $select_option_arr[0] . ':' . $select_option_arr[1] . ':' . $fieldinfo->getFieldName() . ':' . $fieldinfo->getFieldLabelKey();

                $temp['groupid'] = 1;
                $temp['columnname'] = $columnname;
                $temp['comparator'] = 'c';
                $temp['value'] = $_REQUEST['search_content'];
                $temp['columncondition'] = '';
                $result[0] = $temp;
            } else {
                $result = array();
                if(!empty($_REQUEST['searchcontent'])){
                    $columnlist = array();
                    if(isset($_REQUEST['duplicate_related_popu_multifields'])){
                        //editor:gyq_80 reason:微信客户查重改进 2018/9/6 18:10
                        //wym 240416 查重类文件结构优化
                        crm_load_class_file('cls_DuplicateColumn','modules/lingdang');
                        $duplicate_obj=cls_DuplicateColumn::getInstance($_REQUEST['module']);
                        $columnlist = $duplicate_obj->getDuplicateColumnSearchSetting_in_filter();
                    }else{
                        $columnlist = $this->setAdvanceFilter($QueryGenerator, $platform);
                    }
                    $select_sql = 'select isforsearch from ld_cvcolumnlist_wx where columnname = ?';

                    if (!empty($columnlist)) {
                        $count = count($columnlist);
                        foreach ($columnlist as $key => $val) {
                            $select_result = $adb->pquery($select_sql, array($val));
                            $isforsearch = $adb->query_result($select_result,0,'isforsearch');
                            if($isforsearch == 'no') {
                                continue;
                            }
                            $result[$key]['groupid'] = 1;
                            $result[$key]['columnname'] = $val;
                            $result[$key]['comparator'] = 'c';
                            $result[$key]['value'] = $_REQUEST['searchcontent'];

                            if ($key < $count - 1)
                                $result[$key]['columncondition'] = 'or';
                            else
                                $result[$key]['columncondition'] = '';
                        }
                    }
                }
            }
            //editor:gyq_78 reason:发布工作汇报时显示销售简报 2018/8/29 16:00
            if(!empty($_REQUEST['session_search_criteria'])){
                //editor:gyq_78 reason:发布工作汇报时显示销售简报 2018/8/29 16:14
                $session_advft_criteria  = json_decode( $_REQUEST['session_search_criteria'],true);
                $advft_criteria_arr  = json_decode( $session_advft_criteria['advft_criteria'],true);
                $result = array_merge($result,$advft_criteria_arr);
                if(empty($_REQUEST['searchcontent'])){
                    $_REQUEST['advft_criteria_groups'] = '[null,{"groupcondition":""}]';
                }else{
                    $_REQUEST['advft_criteria_groups'] = '[null,{"groupcondition":"and"},{"groupcondition":""}]';
                }
            }else{
                $_REQUEST['advft_criteria_groups'] = '[null,{"groupcondition":""}]';
            }
            $result_true = json_encode($result);
            $_REQUEST['advft_criteria'] = $result_true;
            $_REQUEST['searchtype'] = 'advance';
        }
    }
    //20230614 duan 移动端多选产品时，带出当前模块的数量字段默认值
    public function get_quantity_defaultvalue($module){
        if(isset($this->default_quantity)){
            return $this->default_quantity;
        }
        //20240918 diony 产品套餐，默认值为1
        if($module == 'Productbom'){
            $this->default_quantity = 1;
            return $this->default_quantity;
        }
        if($module == 'Products' && !empty($_REQUEST['frommodule']) && $_REQUEST['chooseMoreProducts'] == 'yes'){
            $frommodule = $_REQUEST['frommodule'];
            $from_focus = CRMEntity::getInstance($frommodule);
            if(!empty($from_focus->detailfieldobj)){
                $qty_fieldinfo = $from_focus->detailfieldobj->getFieldInfoobjBykey('columnname','quantity');
                if(!empty($qty_fieldinfo) && is_numeric($qty_fieldinfo->getDefaultvalue())){
                    if($qty_fieldinfo->getDefaultvalue() == null){
                        $this->default_quantity = 0;
                    }
                    else{
                        $this->default_quantity = $qty_fieldinfo->getDefaultvalue();
                    }
                }
                else{
                    $this->default_quantity = 0;
                }
            }
        }else{
            $this->default_quantity = 0;
        }
        return $this->default_quantity;
    }

    //设置应用场景
    public function setApplicationScene($applicationScene){
        $this->applicationScene = $applicationScene;
    }
    //获取应用场景
    public function getApplicationScene(){
        return $this->applicationScene;
    }
}