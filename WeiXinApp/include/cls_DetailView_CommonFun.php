<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2017/2/28 0028
 * Time: 上午 11:03
 */
class cls_DetailView_CommonFun
{
    //获取分录币种信息20170406
    public function getCurrencyMC($module,$record,$type,$relatedCreationInfo){
        //$relatedCreationInfo 关联创建信息
        if(!empty($relatedCreationInfo)){
            $relatedInfo = $relatedCreationInfo;
            $module=$relatedInfo['frommodule'];
            $record = $relatedInfo['fromid'];
        }
        if($type=='all'){
            global $adb;
            $Currency=Currency::getInstance($adb);
            $allCurrencies = $Currency->getAllCurrencies();
            foreach($allCurrencies as $currency_info){
                $output[] = array('currency_name'=>getTranslatedCurrencyString($currency_info['currencylabel']),'currency_id'=>$currency_info['curid']);
            }
        }else{
            if(!empty($module)){
                $focus = CRMEntity::getInstance($module);
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname','currency_id');
            }
            if(!empty($record)&&$fieldinfo&&$fieldinfo->getFieldName()!=''){
                crm_load_function_file('getInventoryCurrencyInfo', 'include/utils', 'InventoryUtils');
                $currency_info = getInventoryCurrencyInfo($module,$record);
                $output['currency_id'] = empty($currency_info['currency_id'])?'':$currency_info['currency_id'];
                if(!empty($output['currency_id'])){
                    $currency_name = getTranslatedCurrencyString($currency_info['currency_name']) . '('.decode_html($currency_info['currency_symbol']).')';
                }else{
                    $currency_name='';
                }
                $output['currency_name'] =$currency_name;
            }else{
                global $adb;
                $Currency=Currency::getInstance($adb);
                $allCurrencies = $Currency->getAllCurrencies();
                foreach($allCurrencies as $currency_info){
                    $option[] = array('currency_name'=>getTranslatedCurrencyString($currency_info['currencylabel']),'currency_id'=>$currency_info['curid']);
                }
                $output = $option[0];
            }
        }
        return $output;
    }
    //获取模块关联的模块和条目数
    public function jsongetModuleRelatedList($module,$focus){
        global $adb,$related_header,$current_user;
        //gyq_33
        $related_header = $module;//相关信息列表允许查询所有数据
        $_REQUEST['SearchScope'] = 'SmOwner_Search_All';
        $_REQUEST['viewid'] = '';
        $rel_list = isPresentRelatedLists($module);
        $mobilemodules = self::wx_presenceModules($module);
        if(!empty($rel_list)) {
            $relationInfo = array();
            crm_load_function_file('getRelatedListInfoById', 'include/utils', 'DetailViewUtils');
            crm_load_class_file('cls_getRelatedInfoWX', 'WeiXinApp/list/RelatedListView');
            crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
            $j=0;
            foreach ($rel_list as $relatedid => $relatedlabel) {
                $relatedcount = array();
                $relatedcount['nums'] = 0;
                $relatedcount['list'] = array();
                $_REQUEST['viewid'] = 0;

                if(!in_array($relatedlabel,$mobilemodules)) continue;
                if($module=='SalesOrder'&&$relatedlabel=='SalesOrder'&&cls_StaticCommonFun::checkVersionIs001()) continue;
                if ($relatedlabel == 'BalanceOfAccount') continue;
                //微信端相关信息没有修改日志、负责人变更历史
                if (in_array($relatedlabel,array('ViewHistory','ChangeView','AccountHierarchy','Print'))) continue;
                $relationInfo = getRelatedListInfoById($relatedid,$module);
                $function_name = $relationInfo['functionName'];
                if (getEduType('Edu') == false) {
                    if ($relatedlabel == 'ServiceContracts' && $function_name != 'get_related_list') {
                        $function_name = 'get_ServiceContracts';
                    }
                }
                if ($relationInfo['functionName'] == 'get_SharedUsers' && $relationInfo['label'] == 'SharedUsers') {
                    require_once(globalStatic::$root_directory . 'modules/Users/SetRelatedInfo.php');
                    $shareuserobj = new SetRelatedInfo();
                    $relatedListData = $shareuserobj->get_SharedUsersNum($focus->id);
                }elseif($relationInfo['label'] == 'ViewHistory'){
                    
                }elseif($relationInfo['functionName']=='get_singin'&&$relationInfo['label']=='Singin'){
                    crm_load_class_file('cls_ListViewSpecialWX','WeiXinApp/list');;
                    $mobj = new cls_ListViewSpecialWX($module);
                    $relatedListData = $mobj->get_AccountsSignNum($focus->id);

                    // @edit:dong @date:2020/07/27 @reason: 表单推广 表单数据特殊处理
                }elseif($module=='SocialPromotion' && $relationInfo['functionName']=='get_SocialPromotionForm' && $relationInfo['label']='SocialPromotionForm'){
                    crm_load_class_file('SocialPromotionForm','modules/SocialPromotion');
                    $mobj = new SocialPromotionForm();
                    $smownerid = $mobj->getSmownerid($focus->id);
                    if($current_user->id == $focus->column_fields['smcreatorid'] || $current_user->id == $smownerid){
                        $mobj->getFormList('',$focus->id);
                    }else{
                        $mobj->getFormList($current_user->id,$focus->id);
                    }
                    $relatedListData['record'] = $focus->id;
                    $relatedListData['relcount'] = $mobj->formCountNum;

                }else{
                    $cls_getRelatedInfoobj = new cls_getRelatedInfoWX($module, $relationInfo, $focus->id);
                    $relatedListData = $cls_getRelatedInfoobj->getRelateCount();
                }
                if (isset($relatedListData['relcount']) && $relatedListData['relcount'] > 0) {
                    $relatedcount['nums']  = $relatedListData['relcount'];
                    if(array_key_exists('total',$relatedListData)){
                        $total = $relatedListData['total'];
                        $relatedcount['total'] = '（合计：¥'.number_format($total,2).'）';
                    }
                    //获取第一条单据的列表内容
                    if($relationInfo['label']=='SharedUsers'){
                        $relatedcount['list']['title'] = getUserFullName($relatedListData['record']);
                    }elseif($relationInfo['functionName']=='get_singin'&&$relationInfo['label']=='Singin'){
                        $relatedcount['list'] = $mobj->getRecordContentJson($relatedListData['record']);
                    }elseif($relationInfo['label']=='SocialPromotionForm'){
                            // @edit:dong @date:2020/07/28 @reason: 表单推广相关的映射模块不需要第一项数据
                    }else{
                        $relatemodule = getTabname($relationInfo['relatedTabId']);
                        if(!empty($relatemodule)){
                            $mobj = new cls_ListViewWX($relatemodule);
                            $content = $mobj->getRecordContent($relatedListData['record']);
                            if(empty($content)){
                                $content = [];
                                $relatedcount['nums']=0;
                            }
                            $relatedcount['list'] = $content;
                        }
                    }
                }
                //数量为零 不显示对应的相关信息内容 date:20180120 xxs
                if($relatedcount['nums']==0&&$relationInfo['label']!='QuotesChange') continue;
                
                $relatedcount['related_id'] = $relatedid;
                $relatedcount['module'] = $relationInfo['label'];
                if($module=='SalesOrder'&&$relatedlabel=='SalesOrder'){
                    $tranlabel = getFixedLabel('CHANGEORDER');//变更单(子合同)
                }elseif($relatedlabel=='SharedUsers'){
                    $tranlabel =  getFixedLabel('ShareUsers');
                }elseif($relatedlabel=='ViewHistory'){
                    $tranlabel =  getFixedLabel('View History');
                }
                else{
                    $tranlabel = getTranstab($relatedlabel);
                }
                $relatedcount['label'] = $tranlabel;
                $relatedlistcount[$j] =$relatedcount;
                $j++;
            }
        }
        return $relatedlistcount;
    }
    //获取模块相关模块的具体单据信息和操作按钮
    public function jsongetModuleRelatedDetails($module,$record,$related_id){
        global $currentModule;
        crm_load_function_file('getRelatedListInfoById','include/utils','DetailViewUtils');
        $relationInfo = getRelatedListInfoById($related_id,$module);
        crm_load_class_file('cls_getRelatedInfo','include/ListView/RelatedListView');
        $cls_getRelatedInfoobj=new cls_getRelatedInfo($module,$relationInfo,$record);
        $obj = $cls_getRelatedInfoobj->getDataCategory_sqlObj();
        if(empty($obj)){
            return $related_info;
        }
        $obj->AddWhereFieldTable();
        $related_info['list_query'] =  ' and ' .$obj->createIdWhere();
        $related_info['whereFieldTables'] = $obj->querygeneratorobj->whereFieldTables;
        $related_info['whereFieldTableJoinType'] = $obj->querygeneratorobj->whereFieldTableJoinType;
        $related_info['whereDetailTable'] = $obj->querygeneratorobj->whereDetailTable;

        return $related_info;
    }

    //获取微信端开启模块
    public function wx_presenceModules($module){
        $cachekey = 'cache_wx_ispresentmodules';
        $cacherelatedlist = Cache($cachekey);
        if(!$cacherelatedlist){
            global $adb;
            $cacherelatedlist = array();
            //editor:gyq_20191202 reason:清除限制条件wx_presence=0 and
            $query = 'select a.tabid,label from ld_relatedlists a
                      inner join ld_tab on a.related_tabid=ld_tab.tabid
                      where  mobilepresence like \'%weixin%\'';
            $result = $adb->pquery($query, array());
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for ($i = 0; $i < $rows; ++$i) {
                    $tabid = $adb->query_result($result,$i,'tabid');
                    $cacherelatedlist[getTabname($tabid)][]=$adb->query_result($result,$i,'label');
                }
                Cache($cachekey,$cacherelatedlist);
            }
        }
        if(empty($cacherelatedlist)) return '';
        $relatedmodules = $cacherelatedlist[$module];
        $relatedmodules[] = 'SharedUsers';
        $relatedmodules[] = 'Singin';                        
        return $relatedmodules;
    }
}