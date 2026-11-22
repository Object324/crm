<?php
require_once(globalStatic::$root_directory.'WeiXinApp/detail/cls_DetailViewWX.php');
class cls_FormCode_Detailview extends cls_DetailViewWX
{
	public function getBlockFields_Formcode($module, $disp_view, $mode, $col_fields = '', $info_type = '')
    {
        global $adb, $current_user;
        global $mod_strings;
        $tabid = getTabid($module);
        //require(globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php');
        $languageType= getLanguageType($current_user);
        
        if ($module == 'Events') $tabid = 16;
        $block_detail = Array();
        $getBlockinfo = "";
        //and $disp_view=0:pc端没有用
        $query = "select blockid,case when ifnull(ld_tranlabel.fieldlabel,'')='' then blocklabel else ld_tranlabel.fieldlabel end as blocklabel
                 ,show_title,display_status from ld_blocks inner join ld_tranlabel
             on ld_blocks.blockid=ld_tranlabel.relateid where ld_blocks.tabid=? and ld_tranlabel.tabid = ?  and visible = 0 and ld_tranlabel.languagetype='$languageType' and trantable='ld_blocks'  order by sequence";

        $result = $adb->pquery($query, array($tabid, $tabid));

        $noofrows = $adb->num_rows($result);

        $prev_header = "";
        $blockid_list = array();
        for ($i = 0; $i < $noofrows; $i++) {
            //0034116: （珞落计划企业微信登录）附件管理模块：“允许查看或下载”字段值为“否”时，附件可以查看
            //editor:gyq_143 reason:附件管理：增加操作权限【下载】和【预览】,移动端只管预览权限  2019/9/10 11:48 ID1000603
            $blocklabel = $adb->query_result($result, $i, "blocklabel");
            $blockid = $adb->query_result($result, $i, "blockid");
            array_push($blockid_list, $blockid);
            $block_label[$blockid] = $blocklabel . '|##|' . $adb->query_result($result, $i, "display_status");
        }
        
        if ($disp_view == "detail_view") {

            $getBlockInfo = $this->getDetailBlockInformation($module, $result, $col_fields, $tabid, $block_label, $mode);

        } else {
            $getBlockInfo = $this->getDetailBlockInformation($module, $result, $col_fields, $tabid, $block_label, $mode);
            //处理级联带出下拉值问题 xxs 2017-09-29
            if (!empty($_REQUEST['optionarr'])) {
                $optionarr = $_REQUEST['optionarr'];
                foreach ($getBlockInfo as $key => $val) {
                    foreach ($val['fieldinfo'] as $okey => $oval) {
                        if (array_key_exists($oval['fieldname'], $optionarr)) {
                            $getBlockInfo[$key]['fieldinfo'][$okey]['option'] = $optionarr[$oval['fieldname']];
                        }
                    }
                }
                unset($_REQUEST['optionarr']);
            }
        }

        if (count($getBlockInfo) > 0) {
            foreach ($getBlockInfo as $label => $contents) {
                $tmp_fields = array();
                if (empty($getBlockInfo[$label])) {
                    unset($getBlockInfo[$label]);
                    continue;
                }
                //重新排序
                $fields = $contents['fieldinfo'];
                if(sizeof($fields)>0){
                    foreach($fields as $key=>$fieldinfo){
                        $tmp_fields[] = $fieldinfo;
                    }
                    $getBlockInfo[$label]['fieldinfo'] = $tmp_fields;
                }else{
                    unset($getBlockInfo[$label]);
                    continue;
                }
            }
        }
        return $getBlockInfo;
    }
    
    public function getDetailBlockInformation($module, $result, $col_fields, $tabid, $block_label, $mode)
    {
        global $adb;
        global $current_user, $weixin_user;
        $label_data = Array();
        $prevblock = 0;
        $fieldobj = Field::getInstance($module, $adb);
        $moduleFields = $fieldobj->getModuleFields();
        $focus=CRMEntity::getInstance($module);
        
        
        //editor:gyq170825
        //$noofrows = $adb->num_rows($result);
        $i = 0;
        //非管理员  控制只读字段不在模块的新增和编辑时显示
        if ($current_user->is_admin == 'off') {
            $profileobj = Profile::getInstance();
            $profilefields = $profileobj->getProfileInfos($current_user->profileid);
            $profilefields = $profilefields['field'];
        }
       
        //editor:gyq_113 reason:新增知识管理模块,不再每个循环都实例化类  2019/5/23 11:40
        if ($mode == 'detail') {
            crm_load_class_file("cls_DetailViewOutPutWX", 'WeiXinApp/detail');
            $detailView_htmlobj = new cls_DetailViewOutPutWX();
            //editor:gyq_143 reason:附件管理：增加操作权限【下载】和【预览】,移动端只管预览权限  2019/9/10 11:48 ID1000603
            $permit_file = IsPreviewProfile($this->record, $this->module);
        } else {
            crm_load_class_file("cls_EditViewOutPutWX", 'WeiXinApp/detail');
            $detailView_htmlobj = new cls_EditViewOutPutWX();
            
            //链接模块新增、编辑设置高级查询条件数组
            if(isset($_REQUEST['linkemodule_viewname']))
            {
                crm_load_class_file('CommonView',"modules/CustomView");
                $customviewobj=CustomView::getInstance($module);
                $advfilter_arr = array();
                $linkmodule_cvid = $_REQUEST['linkemodule_viewname'];
                $advfilter_arr=$customviewobj->getAdvFilterByCvid($linkmodule_cvid);
                $detailView_htmlobj->setAdvFilter($advfilter_arr);
            }
        }
		//跟踪方式设置为指定期间，当有推进记录产生后没有控制期间字段不可编辑
		/*
		edit:huangjian_chen
		date:2020-07-10
		reposon: 字段推进时，可以在编辑页显示，因为考虑到布局规则。所以这里去除原先的判断
		*/
		//if(!empty($_REQUEST['record']) && $_REQUEST['record'] > 0 && empty($_REQUEST['isDuplicate']) && $mode =='edit'){
			//crm_load_class_file('cls_module_advance','modules/Settings');
			//$cls_module_advance = new cls_module_advance($module);
			// $advance_fieldnames = $cls_module_advance->is_AdvanceRecord($_REQUEST['record']);
		//}
        
        foreach ($moduleFields as $fieldname => $fieldinfo) {
            $maxlength = $fieldinfo->getMaximumLength();
            $generatedtype = $fieldinfo->getGeneratedtype();
            $typeofdata = $fieldinfo->getTypeOfData();
            $fieldonly = $fieldinfo->getfieldOnly();
            $block = $fieldinfo->getBlockId();
            $displaytype = $fieldinfo->getDisplayType();
            $uitype = $fieldinfo->getUIType();
            $columnname = $fieldinfo->getColumnName();
            if(!array_key_exists($columnname,$this->qrcode_field_arr)){
                continue;
            }
            //editor:gyq_20191011 参考自include\utils\EditViewUtils.php 133
            //0038246: （http://47.102.85.179:85/crm [^] ）企业微信>灵当CRM>客户模块>选择单据编号为【DX114728】进入编辑界面：修改任意字段值保存，保存后【联系电话】字段值中间四位自动隐藏了，使用pc端编辑没有该问题。

            //ls 2022-03-31  呼博士 为’国内营销代理商‘的角色用户 页面 隐藏负责人，新增编辑详情都不显示
            $versiontrade = getVersionTradeInfo();
            $account = $versiontrade['account'];
            
            if ($account == 'huboshi' && in_array($module,array('Accounts','Contacts','CustomForm12','SalesOrder','OutboundOrder'))) {
                $smownercolumnname=$focus->getSmownerColumName();
                if ($columnname == $smownercolumnname){
                    $tmp_sql = "select p.profilename from ld_profile p LEFT JOIN ld_users u ON p.profileid = u.profileid where u.id = ?";
                    $tmp_result = $adb->pquery($tmp_sql, array($current_user->id));////获取当前用户的角色id
                    if ($adb->num_rows($tmp_result)>0) {
                        $profilename = $adb->query_result($tmp_result,0,'profilename');
                        if ($profilename == '国内营销代理商') {
                            continue;
                        }
                    }
                }
            }
            //移动端暂时不显示图片类型的字段
            if ($uitype == 69 && !in_array($fieldname,array('imagename','sharepicture','cover_url'))) {
                continue;
            }
            if ($mode == 'edit' ) {
                if($fieldinfo->getFieldDataType() == 'mobile' && fieldValueUitype::IsShowMobileTextBox($this->record, $this->module) == 'no'){
                    continue;
                }elseif ($uitype==230){
                    //editor:gyq_151 reason:编辑界面不显示插件型备注内容  2019/10/15 19:39 ID1000623
                    continue;
                }
				/*
				edit:huangjian_chen
				date:2020-07-10
				reposon: 字段推进时，可以在编辑页显示，因为考虑到布局规则。所以这里去除原先的判断
				*/
				// if(!empty($advance_fieldnames) && in_array($fieldname,$advance_fieldnames)){
				// 	$fieldonly = 'yes';
				// }
            }
            if( $module=='CashBill'&&$col_fields['cashtype']=='debuction'){
                
                //预收款单隐藏原单
                if($uitype==202)
                {
                    continue;
                }
             }
            //附件
            if ($permit_file == 'no' && ($uitype == 28 || $uitype == 1109 || $uitype == 1108)) {
                continue;
            }
            if ($i == 0) {
                $prevblock = $block;
            }
            if (($mode == '' || strtolower($mode) == 'create') && empty($col_fields[$fieldname])) {
                $col_fields[$fieldname] = $fieldinfo->getDefaultValue();
            }
            //0029954:客户新增查看编辑界面，当“首要联系人区块”设为不显示时，地址信息、备注信息、附件信息区块都没有显示出来
            if (!array_key_exists($block, $block_label)) continue;
            
            //duan 2022-1-14 表单码获取可见字段信息时，去除不可见字段
            
            if(isset($_REQUEST['qrcode_viewfield']) && sizeof($_REQUEST['qrcode_viewfield'])>0){
                $qrcode_viewfield_arr = $_REQUEST['qrcode_viewfield'];
                if(!in_array($columnname,$qrcode_viewfield_arr)){
                    continue;
                }
            }
            
            if ($mode == 'detail') {
                if ($displaytype == 3) continue;//display=3 都是属于产品明细区块的信息值，所以在基本里不需要显示
                //if($module == 'Products' && $uitype == 83)continue;	//产品详情页，价格信息区块的税不需要显示。
                $detailView_htmlobj->record = $this->record;
                $custfld = $detailView_htmlobj->getDetailViewOutputHtml($fieldinfo, $col_fields, $generatedtype, $tabid, $module);
                if (!empty($_REQUEST['tempSourceField'])) {
                    foreach ($_REQUEST['tempSourceField'] as $tempSourceContent) {
                        $label_data[] = $tempSourceContent;
                    }
                    unset($_REQUEST['tempSourceField']);
                }
            }else if($uitype == 222){
                
                crm_load_class_file("cls_DetailViewOutPutWX", 'WeiXinApp/detail');
                $detailView_htmlobj_detail = new cls_DetailViewOutPutWX();
                $detailView_htmlobj_detail->record = $this->record;
                
        
                $custfld = $detailView_htmlobj_detail->getDetailViewOutputHtml($fieldinfo, $col_fields, $generatedtype, $tabid, $module);
                $custfld['columnname'] = $columnname;
            }else {
                if ($weixin_user->action == 'is_duplicate') {
                    if (stripos($typeofdata, 'dt') !== false || stripos($typeofdata, 'd') !== false) {
                        //editor:gyq_20190620 单据复制，签约日期、交付日期、制单日期等日期类型字段，默认当天；
                        $col_fields[$fieldname] = $fieldinfo->getDefaultValue();
                    }
                }
                $fieldid = $fieldinfo->getFieldid();
                //编辑时只读的字段在详情界面时，显示但不可编辑，
        		 if( !empty($profilefields) && $profilefields[$fieldid]['editreadonly']==1 && (isset($_REQUEST['record'])&&$_REQUEST['action']=='EditView')){
        			$fieldinfo->set_allowedit('no');
        		 }
                //editor:gyq_20181129 0035628: 企业微信>珞落计划>普通用户登录>客户模块新增编辑界面：当一个字段设置了只允许查看权限的时候，在企业微信中还能看到这个字段，PC端是看不到这个字段的
                if (!empty($profilefields) && $profilefields[$fieldinfo->fieldid]['readonly'] == 1) continue;
                //工单管理解决方案显示部分字段
                if($module=='WorkSheet'&&$_REQUEST['get_solution']!=''&&$_REQUEST['get_solution']=='yes'){
                    //问题描述不允许编辑
                    if($columnname == 'description'){
                        $fieldinfo->set_allowedit('no');
                        $typeofdata = str_replace('M','O',$typeofdata);
                        $fieldinfo->settypeOfData($typeofdata);
                    }
                    //解决方案界面只显示固定的字段
                    if(in_array($columnname,$this->focus->solution_columnname)){
                        $fieldinfo->setDisplaytype(1);
                        $displaytype = 1;
                    }else{
                        $fieldinfo->setDisplaytype(2);
                        $displaytype = 2;
                    }
                 }
                
                if ($displaytype != 1 && $displaytype != 4 && $uitype != '222') continue;
                
                
                if ($uitype == '64' || $uitype == '301') continue;
                $detailView_htmlobj->record = $this->record;
                $curapproveformodulefield = array();
                if(!empty($this->record)&&$weixin_user->action != 'is_duplicate'){
                    //编辑且不是复制
                    $approve=new Approve();
                    $curapproveformodulefield = $approve->getCurApproveForModulefield($this->record);
                }
                if ($weixin_user->action == 'is_duplicate') {
                    
                    //edit:can 20220601 复制已批准的单据有问题
                    unset($_REQUEST['record']);
                }
                $custfld = $detailView_htmlobj->getEditViewOutputHtml($fieldinfo, $maxlength, $col_fields, $generatedtype, $module, $mode, $typeofdata, $fieldonly, $curapproveformodulefield);
                //编辑时只读权限，下拉框字段小程序编辑界面显示并可以保存，
                $custfld['bigtype']=$fieldinfo->getBigType();
                $custfld['savedatabase']=$fieldinfo->getSaveDataBase();
        		 if( $uitype=='15'&&!empty($profilefields) && $profilefields[$fieldid]['editreadonly']==1 && (isset($_REQUEST['record'])&&$_REQUEST['action']=='EditView')){
        			$custfld['type']=1;
        		 }
                 //下拉框字段readonly为yes时，应可以保存
                 else if($uitype=='15'&& $custfld['readonly']=='yes') {
                    $custfld['type']=1;
                 }
                  $custfld['savedatabase']=$fieldinfo->getSaveDataBase();
                 $custfld['bigtype']=$fieldinfo->getBigType();
                $fieldid = $fieldinfo->getFieldid();
                $custfld['columnname'] = $columnname;
                if ($this->getRelatedForFieldid($fieldid) == 'yes')
                    $custfld['is_relatedfield'] = $this->getRelatedForFieldid($fieldid);
                if (!empty($_REQUEST['tempSourceField'])) {
                    $label_data[] = $_REQUEST['tempSourceField'];
                    unset($_REQUEST['tempSourceField']);
                }
            }
            
            if (!is_array($custfld)) {
                continue;
            }
            if ($prevblock != $block) {
                $block_labelArr = explode("|##|", $block_label[$prevblock]);
                if ($block_labelArr[0] != '' && $block_labelArr[0] != null) {
                    $labelfield['blocklabel'] = $block_labelArr[0];
                    $labelfield['display_status'] = $block_labelArr[1];

                    $labelfield['fieldinfo'] = $label_data;
                    $blockinfos[] = $labelfield;
                    $label_data = array();
                    $labelfield = array();
                    $prevblock = $block;
                    $label_data[] = $custfld;
                }
            } else {
                $label_data[] = $custfld;
            }
            $columnvalues[$columnname] = $custfld['value_name'];
            $i++;
        }
        
        //区块显隐
        $block_labelArr = explode("|##|", $block_label[$prevblock]);
        if ($block_labelArr[0] != '' && $block_labelArr[0] != null) {
            $labelfield['blocklabel'] = $block_labelArr[0];
            $labelfield['display_status'] = $block_labelArr[1];
            $labelfield['fieldinfo'] = $label_data;
            $blockinfos[] = $labelfield;
        }
        
         crm_load_class_file('cls_fieldrule', 'include/fields/fieldrule');
        crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
        $detailfieldruleobj=cls_detailfieldrule::getInstance($module);
        $detailfieldruleobj->setColumnValues($columnvalues);
        $fieldrulecolsproperty= $detailfieldruleobj->getFieldRuleProperty();//明细布局规则字段的隐藏和必填项
        
        //布局规则
       
        $fieldruleobj = cls_fieldrule::getInstance($module);
        $fieldruleobj->setColumnValues($columnvalues);
        $fieldrulecolsproperty = $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
        
         
         
         
        //布局规则重新设置界面显示
        $hidecolumns = $fieldrulecolsproperty['hidecolumns'];//隐藏的字段

        $hidecolslen = sizeof($hidecolumns);
        $requiredcolumns = $fieldrulecolsproperty['requiredcolumns'];//必填字段

        $requiredcolslen = sizeof($requiredcolumns);
        $tmp_editview_arr = $editview_arr;
        $start_hide = 0;
        $start_required = 0;
        $tmpblockinfos = $blockinfos;
        $tmpfieldindex = 0;
        $tmpblockindex = 0;
        //  dump($hidecolumns);
        foreach ($tmpblockinfos as $blockindex => $blockfieldinfo) {
            $tmpfieldindex = 0;
            $isdeleteblock = 'no';
            foreach ($blockfieldinfo['fieldinfo'] as $fieldindex => $tmpfieldinfo) {
                $fieldinfo = $moduleFields[$tmpfieldinfo['fieldname']];
                //editor:gyq_20190820  reason:选择源单字段前，特殊插入的源单类型字段，增加特殊标识tempfield=1

                if (isset($tmpfieldinfo['tempfield'])) {
                    $tmpfieldindex++;
                    continue;
                }
                if (!$fieldinfo) {
                    $tmpfieldindex++;
                    continue;
                }
                $tmpcolumnname = $fieldinfo->getColumnName();
				if($tmpcolumnname == 'servicecharge_id' && $mode == 'detail'){
                    if($fieldinfo -> get_ShowHyperlinks() == 'yes')
					    $blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['relatemodule'] = 'ServiceCharge';
				}
                if (in_array($tmpcolumnname, $hidecolumns)) {
                    //隐藏字段

                    array_splice($blockinfos[$tmpblockindex]['fieldinfo'], $tmpfieldindex, 1);
                    if (sizeof($blockinfos[$tmpblockindex]['fieldinfo']) <= 0) {

                        array_splice($blockinfos, $tmpblockindex, 1);
                        $isdeleteblock = 'yes';
                    }
                    continue;
                } else if (in_array($tmpcolumnname, $requiredcolumns)) {

                    $blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['fieldtype'] = "M";
                }
                $tmpfieldindex++;
            }
            if ($isdeleteblock == 'no')//区块是0,1,2,3排序的，所以有次判断
                $tmpblockindex++;
        }
        //editor:gyq_151 reason:移动端，知识管理详情界面插件型备注无法查看PC端上传的附件及图片  2019/10/15 19:33 ID1000623
        if (!empty($detailView_htmlobj->uitype230)) {
            foreach ($blockinfos as $key1 => $value1) {
                foreach ($value1['fieldinfo'] as $key2 => $value2) {
                    if ($value2['uitype'] == 230) {
                        $blockinfos[$key1]['fieldinfo'] = array_values(array_merge($blockinfos[$key1]['fieldinfo'], $detailView_htmlobj->uitype230));
                        break;
                    }
                }
            }
        }
               
        return $blockinfos;
    }
}
?>