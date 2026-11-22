<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

global $adb,$current_user;
require_once('include/CustomFieldUtil.php');
require_once 'modules/PickList/PickListUtils.php';
$languageType= getLanguageType($current_user);
$smarty=new lingdangCRM_Smarty;
if(!empty($_REQUEST['frommodule'])){
	$module = $_REQUEST['frommodule'];
	$tabid = getTabid($module);
	$focus = CRMEntity::getInstance($module);
	$fieldobj=Field::getInstance($module,$adb);
	$referenceFieldNames = array_keys($fieldobj->getReferenceFieldDetails());
	$nonEditableUiTypes = array('70','117');
	$query = "select GROUP_CONCAT(ld_tranlabel.fieldlabel order by ld_tranlabel.languagetype desc SEPARATOR '|#_#|') as fieldlabel,ld_field.fieldid,
		columnname,defaultvalue ,block,uitype,fieldonly,presence,fieldname,quickcreate,masseditable,typeofdata,
        displaytype ,approve_demand,advance_demand,advance_demand_groups,allowhide,fldallow_rewriting,take_photo_only ,allowedit
        ,savedatabase,bigtype,allowdelete,ld_field.fieldid,maxrowsshow,datarang,uploadwatermark,label_style,fieldvaluecolor,fieldplaceholder,input_type,auto_signin,no_signin,allowable_distance
        ,relatedmodulefield,parentbigtype,editview_signin,editview_resignin,showhyperlinks,disallowed_copy,subtotal_attr,showallgroupstructure,autowordwrap,word_watermark,excel_watermark
        ,helptips,disabled_copy,value_format  
		from ld_field LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_field.tabid and ld_tranlabel.Relateid = ld_field.fieldid 
		where ld_tranlabel.trantable = ? and ld_tranlabel.tabid = ? and ld_field.fieldid = ?";
	$result = $adb->pquery($query,array('ld_field',$tabid,$_REQUEST['fieldid']));
	$num_rows = $adb->num_rows($result);
    $relatemodulefield_relatemodule_label='';
    $relatemodulefield_relatefield_label='';

	if($num_rows >= 1){
		$fieldlabel_arr = explode('|#_#|',$adb->query_result($result,0,'fieldlabel'));
		$typeofdata = $adb->query_result($result,0,'typeofdata');
		$fieldname = $adb->query_result($result,0,'fieldname');
		$uitype = $adb->query_result($result,0,'uitype');
		$displaytype = $adb->query_result($result,0,'displaytype');
		$defaultvalue = $adb->query_result($result,0,'defaultvalue');
        $allowedit=$adb->query_result($result,0,'allowedit');
        $fieldid=$adb->query_result($result,0,'fieldid');
        $columnname=$adb->query_result($result,0,'columnname');
        //zxm 20211228 字段颜色设置 字段说明设置
        $fieldvaluecolor=$adb->query_result($result,0,'fieldvaluecolor');
        $label_color = json_decode(html_entity_decode($adb->query_result($result,0,'label_style')??''))->color;
        $fieldplaceholder=$adb->query_result($result,0,'fieldplaceholder');
        $input_type = $adb->query_result($result,0,'input_type');
        $auto_signin = $adb->query_result($result,0,'auto_signin');
        $no_signin = $adb->query_result($result,0,'no_signin');
        $allowable_distance = $adb->query_result($result,0,'allowable_distance');
        
        $allowdelete=$adb->query_result($result,0,'allowdelete');
        $bigtype=strtolower($adb->query_result($result,0,'bigtype')??'');
        $relatedmodulefield=strtolower($adb->query_result($result,0,'relatedmodulefield')??'');
        $parentbigtype=strtolower($adb->query_result($result,0,'parentbigtype')??'');
        //duan 20230506 签到字段增加编辑时是否允许签到和重签
        $editview_signin = $adb->query_result($result,0,'editview_signin');
        $editview_resignin = $adb->query_result($result,0,'editview_resignin');
        $isHrefField = 'no';    //用于判断是否是超链接字段，控制显示超链接属性是否显示
        // ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
        $word_watermark = $adb->query_result($result,0,'word_watermark');
        $excel_watermark = $adb->query_result($result,0,'excel_watermark');
        if($relatedmodulefield=='yes')
        {
            $bigtype = 'relatedmodulefield';//用于界面显示
            $bigtypelabel=getFixedLabel('REFERENCEFIELD');
            $sql='select * from ld_related_field where effect_fieldid=?; ';
            $triggerresult=$adb->pquery($sql,array($fieldid));

            $trigger_fieldid=$adb->query_result($triggerresult,0,'trigger_fieldid');
            $triggerfieldinfo=$fieldobj->getFieldInfoobjBykey("fieldid",$trigger_fieldid);
            if($triggerfieldinfo&&$triggerfieldinfo->getBigType()=='selectsource')
            {
                //引用的选择原单字段
                //$relatemodule=$adb->query_result($result,0,'frommodule');
                //chj 2021/6/23 46515: （https://81mis.com/kfbcrm/ [^]）收款单->页面设置，自定义“引用字段”，“引用对象”选择“收款计划”，“引用字段”选择“备注”保存后，字段编辑属性界面，“引用对象”显示空，“引用字段”显示选择源单
                $relatefieldname=$triggerfieldinfo->getFieldName();
                $relatemodulefield_relatemodule_label=$triggerfieldinfo->getFieldLabel();
                $related_query = 'select fromvalue_info,frommodule from ld_related_field where trigger_fieldid = ? and effect_fieldid = ?';
                $related_result = $adb->pquery($related_query,array($trigger_fieldid,$fieldid));
                $fromvalue_info = $adb->query_result($related_result,0,'fromvalue_info');
                $relatemodule = $adb->query_result($related_result,0,'frommodule');

                $relatemodulefield_relatemodule_label .= ' - '.getTranstab($relatemodule);
                if(!empty($relatemodule))
                {


                    $relatefocus=CRMEntity::getInstance($relatemodule);
                    $relatefieldinfo=$relatefocus->fieldobj->getFieldInfoobjBykey("columnname",$fromvalue_info);
                    if(!empty($relatefieldinfo)){

                        $relatemodulefield_relatefield_label=$relatefieldinfo->getFieldLabel();
                    }
                }
            }
            else{


                $sql='select ld_field.uitype,ld_related_field.fromvalue_info,ld_ws_referencetype.type from ld_related_field 
                    inner join ld_field on ld_field.fieldid=ld_related_field.trigger_fieldid
                    inner join ld_ws_fieldtype  on ld_ws_fieldtype.uitype=ld_field.uitype 
                    INNER JOIN ld_ws_referencetype
                    on ld_ws_fieldtype.fieldtypeid=ld_ws_referencetype.fieldtypeid  where effect_fieldid=?';
                $relatefieldresult=$adb->pquery($sql,array($fieldid));

                $relatemodule=$adb->query_result($relatefieldresult,0,'type');
                if($relatemodule!='')
                {
                    $relatefocus=CRMEntity::getInstance($relatemodule);

                    $relatefieldinfo=$relatefocus->fieldobj->getFieldInfoobjBykey("columnname",$adb->query_result($relatefieldresult,0,'fromvalue_info'));
                    if(!empty($relatefieldinfo)){
                        $relatefieldname=$relatefieldinfo->getFieldName();
                        $relatemodulefield_relatefield_label=$relatefieldinfo->getFieldLabel();
                    }
                }
                //edit:can 2021-01-13 40964: 系统设置>页面设置>跟进记录模块页面设置>编辑客户状态：编辑引用字段界面，应该要将该字段的“引用对象”和“引用字段”显示出来。（详情可参照引用字段新增界面）
                $relatemodulefield_relatemodule_label=getTranstab($relatemodule);

            }

            //edit: xll 2023/06/06 XUQIU1001203 引用字段增加“显示超链接”字段属性
            if($relatefieldinfo&&(in_array($relatefieldinfo->getBigType(),array('selectsource','reference')) || $relatefieldinfo->getUitype() == 112))
            {
                $isHrefField = 'yes';
            }
            if($module == 'Signout' && $columnname == 'source_list' && $relatemodule == 'Singin' && $uitype == 1)//BUG20240403-23 签退->页面设置，“拜访对象”字段应该不显示超链接字段属性
                $isHrefField = 'no';
            //wym XUQIU1000290 引用成员管理字段编辑页 需要显示选择成员
            $sql = 'select * from ld_related_field where effect_fieldid=?';
            $triggerresult = $adb->pquery($sql,array($fieldid));

            $selectmemberfield = '';
            if ($adb->num_rows($triggerresult) >= 1) {
                $trigger_fieldid=$adb->query_result($triggerresult,0,'trigger_fieldid');
                //不能用触发字段的对象【$fieldobj->getFieldInfoobjBykey("fieldid",$trigger_fieldid)】获取getFieldLabel，它有可能隐藏（比如单选用户类型的字段），所以得用sql查询
                $sql = "select ld_tranlabel.fieldlabel from ld_field LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_field.tabid and ld_tranlabel.Relateid = ld_field.fieldid
		where ld_tranlabel.languagetype=? and ld_tranlabel.trantable = 'ld_field' and ld_field.fieldid = ?";
                $labelresult = $adb->pquery($sql,array($languageType, $trigger_fieldid));
                $selectmemberfield = $adb->query_result($labelresult,0,'fieldlabel');
            }
        }

        else if($bigtype=='text')
        {
            $bigtypelabel=getFixedLabel('Text');
        }
        else if($bigtype=='boolean')
        {
            $bigtypelabel=getFixedLabel('CHECK_BOX');
        }
        else if($bigtype=='multipicklist')
        {
            $bigtypelabel=getFixedLabel('SELECT_COMBO');
        }
        else if($bigtype=='picklist')
        {
             $bigtypelabel=getFixedLabel('PickList');
        }
        else if($bigtype=='date')
        {
            $bigtypelabel=getFixedLabel('DATE');
        }
        else if($bigtype=='datetime')
        {
            $bigtypelabel=getFixedLabel('DateTime');
        }
        //zkt 20220412 50930（https://81mis.com/kfbcrm/index.php）系统设置》页面设置》客户，新增了时间类型字段，但字段列表不给显示字段类型
        else if($bigtype=='time')
        {
             $bigtypelabel=getFixedLabel('TIMES');
        }
        else if($bigtype=='phone')
        {
            $bigtypelabel=getFixedLabel('Phone');
        }
        else if($bigtype=='longtextarea')
        {
            $bigtypelabel=getFixedLabel('WholeTextArea');
        }
        else if($bigtype=='textarea')
        {
            $bigtypelabel=getFixedLabel('TEXT_AREA');
        }
        else if($bigtype=='currency')
        {
            $bigtypelabel=getFixedLabel('Currencyc');
        }
        else if($bigtype=='percent')
        {
            $bigtypelabel=getFixedLabel('Percents');
        }
        else if($bigtype=='mobile')
        {
            $bigtypelabel=getFixedLabel('Mobil');
        }
        else if($bigtype=='number')
        {
            $bigtypelabel=getFixedLabel('Numberc');
        }else if($bigtype=='signin')
        {
            $bigtypelabel=getFixedLabel('SIGNIN');
        }
        else if($bigtype=='qq')
        {
            $bigtypelabel='QQ';
        }
        else if($bigtype=='email')
        {
            $bigtypelabel='Email';
        }
        else if($bigtype=='email')
        {
            $bigtypelabel='Email';
        }
        else if($bigtype=='reference')
        {
            $bigtypelabel=getFixedLabel('SelectBill');
            //XUQIU1001403 xxy 2023-6-16 页面设置，编辑“关联选择单据（单选）”字段属性，“英文标签”属性下方增加显示“关联选择对象”字段属性  
            $trigger_moduleuitype = cls_module_uitype::getUitypeModule($uitype);
            $relatechoicemodule = getTranstab($trigger_moduleuitype);
            if(($module == 'Singin' && $columnname == 'signout_id') || ($module == 'Signout' && $columnname == 'signin_id')){//签到中的签退地址，签退中的签到地址需要超链接
                $isHrefField = 'yes';
            }
        }
        else if($bigtype=='multireference')
        {
            $bigtypelabel=getFixedLabel('SelectMultiBill');
            $trigger_moduleuitype = cls_module_uitype::getUitypeModule($uitype);
            $relatechoicemodule = getTranstab($trigger_moduleuitype);
        }
        else if($bigtype=='handwriting')
        {
            $bigtypelabel=getFixedLabel('handwriting');
            
        }
        else if($bigtype=='fileattachment'){
            if($uitype==69 or $uitype==28){
                 $bigtypelabel=getFixedLabel('Image');
            }
            else
            $bigtypelabel=getFixedLabel('Attachment');
        }else if($bigtype=='qrcode'){
            //二维码字段类型
            $bigtypelabel=getFixedLabel('qrcodetype');
            $template_sql = "select * from ld_qrcode_template where fieldid=?";
            $template_res = $adb->pquery($template_sql,[$fieldid]);
            $template_nums = $adb->num_rows($template_res);
            $qrcodetemplateid = $template_nums>0?$adb->query_result($template_res,0,'qrcodetemplateid'):0;
            $smarty->assign("qrcodetemplateid",$qrcodetemplateid);
        }
        else if($bigtype == 'memberdepartment'){
            //ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）
            $bigtypelabel = getFixedLabel('MemberDepartment');
            $sql = 'select * from ld_related_field where effect_fieldid=?';
            $triggerresult = $adb->pquery($sql,array($fieldid));

            $selectmemberfield = '';
            if ($adb->num_rows($triggerresult) >= 1) {
                $trigger_fieldid=$adb->query_result($triggerresult,0,'trigger_fieldid');
                //不能用触发字段的对象【$fieldobj->getFieldInfoobjBykey("fieldid",$trigger_fieldid)】获取getFieldLabel，它有可能隐藏（比如单选用户类型的字段），所以得用sql查询
                $sql = "select ld_tranlabel.fieldlabel from ld_field LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_field.tabid and ld_tranlabel.Relateid = ld_field.fieldid
		where ld_tranlabel.languagetype=? and ld_tranlabel.trantable = 'ld_field' and ld_field.fieldid = ?";
                $labelresult = $adb->pquery($sql,array($languageType, $trigger_fieldid));
                $selectmemberfield = $adb->query_result($labelresult,0,'fieldlabel');
            }
        }
        else if($bigtype == 'express'){
            $bigtypelabel=getFixedLabel('ExpressQueryComponent');
        }else if($bigtype == 'selectoneuser'){
            $bigtypelabel=getFixedLabel('SelectOneUser');
        }
        else if($bigtype == 'selectmultiuser'){
            $bigtypelabel=getFixedLabel('SelectMultiUser');
        }
        else if($bigtype == 'url'){
            $bigtypelabel=getFixedLabel('Website');
        }

        if($uitype==4&&$relatedmodulefield!='yes')
        {
            $bigtypelabel=getFixedLabel('AutoNumber');
        }
        if($uitype==65)
        {
            $bigtypelabel=getFixedLabel('LOCATION');
            
        }
        if($uitype==64)
        {
            $bigtypelabel=getFixedLabel('LocationMap');
            
        } elseif ($uitype==230) {
            $bigtypelabel=getFixedLabel('RichTextBox');
        }
        $savedatabase=$adb->query_result($result,0,'savedatabase');
		$fieldtype =explode("~",$typeofdata);
		$defaultPermitted = true;
		$strictlyMandatory = false;
		if(isset($focus->mandatory_fields) && (!empty($focus->mandatory_fields)) && in_array($fieldname, $focus->mandatory_fields)) {
			$strictlyMandatory = true;
			$defaultPermitted = false;
		} elseif (in_array($uitype, $nonEditableUiTypes) || $displaytype == 2) {
			$strictlyMandatory = true;
			$defaultPermitted = false;
		}
		if(in_array($fieldname, $referenceFieldNames)) {
			$defaultPermitted = false;
		}
        
		//账户的下拉框不能编辑，动态读取银行账户模块值
		if($uitype == 251){
			$defaultvalue = '';
			$defaultPermitted = false;
		}
		if($strictlyMandatory) {//fields without which the CRM Record will be inconsistent

			$mandatory = '0';
		}elseif($fieldtype[1] == "M") {//fields which are made mandatory
			$mandatory = '2';
		}else {
			$mandatory = '1'; //fields not mandatory
		}
		if ( $displaytype == 2) {
			$mandatory = '3';
		}
        
        //签到字段特殊控制，可以设置必填
        if($uitype == '306'){
            if($fieldtype[1] == "M"){
                $mandatory = '2';
            }else{
                $mandatory = '1';    
            }
            if($module == 'Singin'){
                $mandatory = '4';
            }
        }
        
        /*//ls 2022-04-29 0051423系统设置》页面设置》供应商联系记录，供应商名称字段 ，显示是必填字段，但编辑字段时没有勾选必填
		if($module == 'VendorContactRecords'){
			if($fieldname == 'vendor_id' || $fieldname == 'contact_id'){
				$mandatory = 1;
			}
		}*/
		$allValues = array();
		if(in_array($uitype, array('15','16','33','34'))) {
		    if($uitype == 15 || $uitype == 34){
		        //duan date:20241031 下拉框字段设置默认值的时候要添加空值，不然会自动保存第一个
                $orgin_allValues = getAllPickListValues($fieldname);
                $allValues[] = '';
                foreach ($orgin_allValues as $tmp_key=>$tmp_value){
                    $allValues[$tmp_key] = $tmp_value;
                }
            }else{
                $allValues = getAllPickListValues($fieldname);
            }

			if($fieldname == 'approvestatus' && $module=='Users'){
				$allValues = array(getFixedLabel('ACTIVATE'),getFixedLabel('INACTIVATE'));
			}
        }
        //销售负责人允许设置默认值
        if(($columnname == 'smownerid'||$columnname == 'servicecasher')&&$uitype == 53){
            $defaultPermitted = true;
            $defaultvalue = 'cur_user';
            $allValues= array();
            $picklist_label = getFixedLabel('DATASSIGNEDTO'); //单据负责人翻译
            //‘当前用户’选项
            $allValues[] =  array('value'=>'cur_user',
                                  'label'=>getFixedLabel('CURUSER'),
                                  'presence'=>0);
            //zkt 2022.02.25 客户/服务收费管理增加“服务代表”功能 
            //‘客户服务代表’选项
            if($module=='HelpDesk'){
                $tmp_fieldobj = Field::getInstance('Accounts',PearDatabase::getInstance());
                $service_representativefieldlabel=$tmp_fieldobj->getFieldInfoBykeyValue('columnname','service_representative','fieldlabel');
                if(!empty($service_representativefieldlabel))
                {
                    $allValues[] =  array('value'=>'Accounts##service_representative',
                                  'label'=>getTranstab('Accounts').$service_representativefieldlabel,
                                  'presence'=>0);
                }
                
            }
            
            //上次保存的默认值
            $sql = "select frommodule,trigger_fieldid,fromvalue_info from ld_related_field where effect_fieldid = ? order by id desc limit 1";
            $tmpresult = $adb->pquery($sql,array($fieldid));
            if($adb->num_rows($tmpresult)>0){
                $relatemodule = $adb->query_result($tmpresult,0,'frommodule');
                if(empty($relatemodule)){
                    //如果关联模块名称为空，则获取模块名称
                    $trigger_fieldid = $adb->query_result($tmpresult,0,'trigger_fieldid');
                    $tmp2_sql = 'select ld_ws_referencetype.type from ld_field 
                                INNER JOIN ld_ws_fieldtype on  ld_field.uitype = ld_ws_fieldtype.uitype 
                                INNER JOIN ld_ws_referencetype on ld_ws_fieldtype.fieldtypeid=ld_ws_referencetype.fieldtypeid
                                where ld_field.fieldid=? and ld_field.presence in(0,2) and ld_field.tabid = ?;';
                    $tmp2_result = $adb->pquery($tmp2_sql,array($trigger_fieldid,getTabid($module)));
                    if($adb->num_rows($tmp2_result)>0){
                        $relatemodule = $adb->query_result($tmp2_result,0,'type');
                    }   
                }
                $fromvalue_info = $adb->query_result($tmpresult,0,'fromvalue_info');
                $defaultvalue = $relatemodule.'_record';
                $defaultlabel = getTranstab($relatemodule).$picklist_label;
                
                if($fromvalue_info == 'service_representative')
                {

                    if(empty($service_representativefieldlabel))
                    {
                        $tmp_fieldobj = Field::getInstance('Accounts',PearDatabase::getInstance());
                        $service_representativefieldlabel=$tmp_fieldobj->getFieldInfoBykeyValue('columnname','service_representative','fieldlabel');
                    }
                    $defaultvalue = $relatemodule.'##service_representative';
                    $defaultlabel = getTranstab($relatemodule).$service_representativefieldlabel;
                }
                $default_presence = 1;
            }
            //获取所有的关联选择单据类型的字段
            //edit:can 20210925 048021: https://81mis.com/kfbcrm/ [^]，页面设置-合同订单-销售负责人-默认-出现俩个“测试客户单据负责人”如图
            $sql='select ld_ws_referencetype.type as name,ld_field.presence from ld_ws_fieldtype
                    inner join ld_ws_referencetype
                    on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
                    inner join ld_field on ld_field.uitype=ld_ws_fieldtype.uitype
                    inner join ld_tab on ld_field.tabid=ld_tab.tabid 
                    where  ld_tab.tabid=? and ld_field.savedatabase="yes" and ld_field.displaytype=1
                    and ld_field.uitype<>202 and ld_field.uitype <> 53 and ld_field.uitype <> 77
                    and ld_field.uitype<>173 group by ld_field.uitype
                    order by ld_field.sequence asc';
            $tmpresult=$adb->pquery($sql,array(getTabid($module)));
            $rows=$adb->num_rows($tmpresult);
            for($i=0;$i<$rows;$i++){
                $relatemodule=$adb->query_result($tmpresult,$i,'name');
                $presence=$adb->query_result($tmpresult,$i,'presence');
                //客户和联系人模块不能关联市场活动
                if($relatemodule =='Campaigns'&&($module=='Accounts'||$module=='Contacts'||$module=='ServiceCharge')){
                    $presence =1;
                }
                //服务收费管理不能像客户一样查看上下级关系
                if($relatemodule =='Accounts'&&$module=='ServiceCharge'){
                    $presence = 1;
                }
                if($presence==0 ||$presence==2){
                    $value = $relatemodule.'_record';
                    if($value==$defaultvalue){
                        $default_presence = 0;
                    }
                    $label=getTranstab($relatemodule).$picklist_label;
                    $allValues[] =  array('value'=>$value,
                                          'label'=>$label,
                                          'presence'=>$presence);
                }
            }
           
            //如果上次保存的关联模块未启用，添加对应值
            if($default_presence==1){
                $allValues[] =  array('value'=>$defaultvalue,
                                      'label'=>$defaultlabel,
                                      'presence'=>$default_presence);
            }
            
        }
        //zkt 0045569: （https://61mis.com/kfbcrm [^] ）页面设置-》成员管理中，类似“角色权限”“状态”“部门”这类字段设施默认后不生效
        //页面设置->成员管理->角色权限默认值设置为下拉选择框,此处导入下拉框选择的内容
        if($uitype==98)
        {
            $prosql = 'select profileid,profilename from ld_profile';
            $proresult = $adb->pquery($prosql,array());
            $pro_num_rows=$adb->num_rows($proresult);
            for($i=0;$i<$pro_num_rows;$i++)
            {
                $arr =array();
                $arr['id'] = $adb->query_result($proresult,$i,'profileid');
                $arr['name'] = $adb->query_result($proresult,$i,'profilename');
                array_push($allValues,$arr);
            }
        }
        else if($uitype==115 && $columnname == 'status')
        {
            $values = array(getFixedLabel('Job') => 'Active', getFixedLabel('Quit') => 'Inactive');
            foreach ($values as $fixedlabel => $tmpvalue) {
                $arr =array();
                $arr['value'] = $fixedlabel;
                $arr['hiddenvalue'] = $tmpvalue;
                $allValues[] = $arr;
            }
        }
       if($uitype==33)
       {
//           @edit:liushuai,2021-05-19,reason:页面设置，新增多选框，保存后，自动勾选了默认值；
           if (!empty($defaultvalue)) {
               $defaultvalue=explode(" |##| ",$defaultvalue);
           }
       }
       
       if($uitype==603)
       {
           if (!empty($defaultvalue)) {
               $defaultvalue=explode(" |##| ",$defaultvalue);
           }
       }
       
       $allowhide=$adb->query_result($result,0,'allowhide');
       if($focus->list_link_field==$fieldname)
       {
        //36733: 模块超链接字段应该控制不允许隐藏。
            $allowhide='no';
       }
       
       if($bigtype=='reference'||$bigtype=='multireference')
       {
            $uitypemodules=cls_module_uitype::getUitypeModules();
            $referencemodule=$uitypemodules[$uitype];
            
            $defaultPermitted=true;
            if($defaultvalue>0)
            {
                $defaultvalueid=$defaultvalue;
                $defaultvalue=getModuleHref($referencemodule,$defaultvalue);
            }
            $smarty->assign("UITYPEMODULES",$uitypemodules);
       }
       $regexp='0';
       if($bigtype=='mobile')
       {
		   //chj 2021/5/27 46047: （61mis.com/kfbcrm）客户管理-联系人，联系人手机字段，页面设置中“ 严格11位手机号码格式”无法保存成功；
          $sql="select ld_validatasave.* from ld_validatasave
                INNER JOIN ld_validatasavedetail on ld_validatasave.id=ld_validatasavedetail.relateid
                where module='$module' and fieldname='$fieldname' and ld_validatasave.relatedtable='ld_field' and comparator=?;";
          $tmpresult=$adb->pquery($sql,array('regexp'));
          if($adb->num_rows($tmpresult)>0)
          {
            $regexp='1';
          }
       }
       //zkt 字符长度、小数位数
       $fieldlength = '';
       $fieldDecimal =  '';
       if($fieldtype[0]=='NN')
       {
            $tmp_fieldlengthinfo = explode(',',$fieldtype[2]);
            $fieldDecimal = $tmp_fieldlengthinfo[1];
       }
       if($bigtype == 'text'){
            if($fieldtype[2] == 'LE'){
    			$fieldlength = $fieldtype[3];
    		}else{
    			$fieldlength = $fieldtype[2];
    		}
       }

       global $global_picklist_colors_byvalue;
       $picklist_colors = $global_picklist_colors_byvalue[$fieldname];


        //ls 2022-04-15 【1000118】页面设置，字段属性中增加【字段公式】页签
        $sql_formula='select * from ld_field_formula where fieldid=?';
        $result_formula=$adb->pquery($sql_formula,array($_REQUEST['fieldid']));
        if($adb->num_rows($result_formula)>0)
        {
            $functiontype = $adb->query_result($result_formula,0,'functiontype');
            if (empty($functiontype) || $functiontype == 'sql') {//公式
                $columnstring='"'.$adb->query_result($result_formula,0,'columnstring').'"';
                $col=explode(',',$columnstring);

                $formula=array();
                foreach($col as $value)
                {
                    $ps=explode(':',$value);
                    if(stripos($value,"var")!==false)
                    {

                        $letters[]=$ps[count($ps)-1];//获取字母
                    }
                    if(stripos($value,"column")!==false)
                    {
                        $strcolumn=$ps[count($ps)-1];
                        $column[]=substr($strcolumn,0,stripos($strcolumn,'}'));//获取字段名称
                    }
                }
            }else{
                $functioncolumn=$adb->query_result($result_formula,0,'columnstring');
            }
            $formulastring=$adb->query_result($result_formula,0,'formulastring');


        }
//wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据
        $advance_demandid=$adb->query_result($result,0,'advance_demand');

        $advance_demandid=!empty($advance_demandid)?explode('####',$advance_demandid):'';
        $advance_demandgroups=$adb->query_result($result,0,'advance_demand_groups');
        $advance_demandgroups=!empty($advance_demandgroups)?explode('####',$advance_demandgroups):'';

        if($advance_demandgroups[0]== 'Person'){
            $memberrange_type='按成员';
            $sql_foruser="select last_name from ld_users where find_in_set(id,'$advance_demandid[0]')";
        }
        else if($advance_demandgroups[0]== 'Module'){
            $memberrange_type='根据模块数据范围权限控制';
        }
        else if($advance_demandgroups[0]== 'Departments'){
            $memberrange_type='按部门';
            $sql_foruser="select groupname from ld_groups where find_in_set(groupid,'$advance_demandid[0]')";
        }
        else if($advance_demandgroups[0]== 'Roles'){
            $memberrange_type='按角色权限';
            $sql_foruser="select profilename from ld_profile where find_in_set(profileid,'$advance_demandid[0]')";
        }
        else if($advance_demandgroups[0]== 'Position'){
            $memberrange_type='按职位级别';
            $sql_foruser="select listvalue from ld_picklist_values where find_in_set(id,'$advance_demandid[0]')";
        }
        else if($advance_demandgroups[0]== 'All'){
            $memberrange_type='全部';
            $sql_foruser="select u.last_name from ld_users u INNER JOIN (select u.last_name,groups.groupid from ld_users u left join ld_groups groups on u.groupid=groups.groupid)g on g.last_name=u.last_name where u.deleted=0 ";
        }
        if (!empty($sql_foruser)) {
            $sql_foruser_result = $adb->pquery($sql_foruser,array());
            $sql_num_rows=$adb->num_rows($sql_foruser_result);
            for($i=0;$i<$sql_num_rows;$i++){
                $result_foruser[$i]=$adb->query_result($sql_foruser_result,$i,0);
            }
        }

        $memberrange = is_array($result_foruser)?implode(',',$result_foruser):[];

        //后台设置 附件文字水印
        $word_watermark_settingid = '';
        $excel_watermark_settingid = '';
        if ($uitype == 1108 || $uitype == 1109 || $uitype == 28){
            $watersetting_selectsql = 'select id,type from ld_attachments_watermark_setting where module=? and fieldname=? and type in ("word","excel")';
            $watersetting_result = $adb->pquery($watersetting_selectsql,array($module,$fieldname));
            $watersetting_numrow = $adb->num_rows($watersetting_result);
            if ($watersetting_numrow > 0){
                for ($i=0;$i<$watersetting_numrow;$i++){
                    $type =$adb->query_result($watersetting_result,$i,'type');
                    $settingid =$adb->query_result($watersetting_result,$i,'id');
                    if ($type == 'word'){
                        $word_watermark_settingid = $settingid;
                    }else{
                        $excel_watermark_settingid = $settingid;
                    }
                }
            }
        }
        $helptips = $adb->query_result($result,0,'helptips');

		$value = array(
			'fieldid' => $_REQUEST['fieldid'],
			'fieldlabel_zh' => $fieldlabel_arr[0],
			'fieldlabel_en' => $fieldlabel_arr[1],
			'columnname' => $columnname,
			'defaultvalue' => array('permitted' => $defaultPermitted, 'value' => $defaultvalue, '_allvalues' => $allValues,'defaultvalueid'=>$defaultvalueid,'_allvaluecolors'=>$picklist_colors),
			'block' => $adb->query_result($result,0,'block'),
			'uitype' => $uitype,
			'fieldonly' => $adb->query_result($result,0,'fieldonly'),
			'presence' => $adb->query_result($result,0,'presence'),
			'fieldname' => $fieldname,
			'quickcreate' => $adb->query_result($result,0,'quickcreate'),
			'masseditable' => $adb->query_result($result,0,'masseditable'),
			'typeofdata' =>$typeofdata,
			'displaytype' => $displaytype,
            'fldLength'=>$fieldlength,
            'fldDecimal'=>$fieldDecimal,
			'approve_demand' => $adb->query_result($result,0,'approve_demand'),
			'advance_demand' => $adb->query_result($result,0,'advance_demand'),
			'advance_demand_groups' => $adb->query_result($result,0,'advance_demand_groups'),
			'allowhide' => $allowhide,
			'fieldtype'=>$fieldtype[1],
			'mandatory'	=> $mandatory,
			'customfieldflag'=>InStrCount($fieldname,'cf_',true),//自定义字段
            'allowdelete'=>$allowdelete,
			'module' => $module,
            'savedatabase'=>$savedatabase,
            'relatemodulefield'=>$relatefieldname,
            'relatechoicemodule'=>$relatechoicemodule,
			'fldallow_rewriting' => $adb->query_result($result,0,'fldallow_rewriting'),
			'take_photo_only' => $adb->query_result($result,0,'take_photo_only'),
			'allowedit'=>$allowedit,
            'bigtype'=>$bigtype,
            'relatedmodulefield'=>$relatedmodulefield,
            'parentbigtype'=>$parentbigtype,
            'bigtypelabel'=>$bigtypelabel,
            'fieldvaluecolor'=>empty($fieldvaluecolor)?'#333333':$fieldvaluecolor,
            'label_color'=>empty($label_color)?'':$label_color,
            'show_label_color'=>empty($label_color)?'#999':$label_color,
            'fieldplaceholder'=>$fieldplaceholder,
            'relatemodule'=>$relatemodule,
            'relatemodulefield_relatemodule_label'=>$relatemodulefield_relatemodule_label,//引用字段引用的模块
            'relatemodulefield_relatefield_label'=>$relatemodulefield_relatefield_label,//引用字段引用的字段
            'maxrowsshow'=>$adb->query_result($result,0,'maxrowsshow'),
            'datarang'=>$adb->query_result($result,0,'datarang'),
            'regexp'=>$regexp,
            'uploadwatermark'=>$adb->query_result($result,0,'uploadwatermark'),
            'selectmemberfield'=>$selectmemberfield,
            'input_type'=>$input_type,
            'letters'=>$letters,
            'column'=>$column,
            'formulastring'=>$formulastring,
            'functiontype'=>$functiontype,
            'functioncolumn'=>$functioncolumn,
            'auto_signin'=>$auto_signin,
            'no_signin'=>$no_signin,
            'allowable_distance'=>$allowable_distance,
            'memberrangetype'=>$memberrange_type,
            'memberrange'=>$memberrange,
            'member_range'=>$advance_demandid[1],
            'memberrange_type'=>$advance_demandgroups[1],
            'advance_demandid'=>$advance_demandid[0],
            'advance_demandgroups'=>$advance_demandgroups[0],
            'editview_signin'=>$editview_signin,
            'editview_resignin'=>$editview_resignin,
            'ShowHyperlinks'=>$adb->query_result($result,0,'showhyperlinks'),
            'showallgroupstructure'=>$adb->query_result($result,0,'showallgroupstructure'),
			// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）
            'disallowed_copy'=>$adb->query_result($result,0,'disallowed_copy'),
            'disabled_copy'=>$adb->query_result($result,0,'disabled_copy'), //duan 20240709 设置字段是否固定不允许复制,如果为no,则'内容不可复制'参数不允许修改
            'subtotal_attr'=>$adb->query_result($result,0,'subtotal_attr'),
            'auto_wordwrap'=>$adb->query_result($result,0,'autowordwrap'),
            // ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
            'word_watermark'=>$word_watermark,
            'excel_watermark'=>$excel_watermark,
            'word_watermark_settingid'=>$word_watermark_settingid,
            'excel_watermark_settingid'=>$excel_watermark_settingid,
            'helptips'=>$helptips,// 帮助信息
            'valueFormat'=>html_entity_decode($adb->query_result($result,0,'value_format')??''),  // 字段值格式化: 目前用于时间字段格式
		);
	}
	// dump($value);
    //ls 2022-04-15 【1000118】页面设置，字段属性中增加【字段公式】页签
    $isEntryModule = 'no';//是否为分录模块
    if (get_file_address($module, 'ProductDetails') || get_file_address($module, $module . "DetailFieldsHtml")) {
        $isEntryModule = 'yes';
        if (get_file_address($module, $module . 'DetailFieldsHtml')) {
            //  crm_load_class_file("setTabDetailFields")
            $ProductToolFields = TabDetailFields::getInstance($module);
            $ProductToolFieldsInfo = $ProductToolFields->getTabDetailFields();
        } else {
            crm_load_class_file('ProductToolFields', 'include/ProductDetails');
            $ProductToolFields = ProductToolFields::getInstance($module);
            $tabid = getTabid($module);
            $languageType = getLanguageType($current_user);
            $ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid, $languageType);
        }
        $detailtable = $focus->Detail_table;
        $detailtablescf = $focus->Detail_table_scf;
        foreach ($ProductToolFieldsInfo as $tmpindex => $productfieldinfo) {

            $tablename = $productfieldinfo->getTableName();
//            if ($tablename == $detailtable || $tablename == $detailtablescf) {
                //根据分录函数显示不同类型的字段
                if ($productfieldinfo->isFldNumOrMoney() || $productfieldinfo->isTaxPercentField()) {
                    $EntryFuncfieldarr['numamount'][$productfieldinfo->getColumnName()] = $productfieldinfo->getfieldLabel();
                } elseif (in_array($productfieldinfo->getUIType(), array("5", "51", "256", "23", "14", "86", "70"))) {//date：5、51、256、23 time：14 datetime：86、70
                    $EntryFuncfieldarr['date'][$productfieldinfo->getColumnName()] = $productfieldinfo->getfieldLabel();
                } elseif (!in_array($productfieldinfo->getUIType(), array("69"))){
                    $EntryFuncfieldarr['string'][$productfieldinfo->getColumnName()] = $productfieldinfo->getfieldLabel();
                }
//            }
        }

        // 数字金额类型；数字金额日期类型（maxdate、mindate合并到了max、min）；其他类型，显示全部字段
        $smarty->assign('EntryFunction', array("Avg"=>getFixedLabel("Avg"), "Count"=>getFixedLabel("COUNT"), "CountDistinct"=>getFixedLabel("CountDistinct"), "First"=>getFixedLabel("FirstLine"), "Last"=>getFixedLabel("LastLine"), "Max"=>getFixedLabel("Max"), "Min"=>getFixedLabel("Min"), "Sum"=>getFixedLabel("Summation")));//分录函数
        $smarty->assign('EntryFuncfieldarr', $EntryFuncfieldarr);//分录函数-参数字段
        
    }
    $smarty->assign('isEntryModule', $isEntryModule);//是否为分录模块

    if ($value['input_type'] == 'formula' && (empty($functiontype) || $functiontype == 'sql')) {//通过公式计算  通过sql计算
        //通过公式计算（字段公式下拉框）
//            $fieldobj = Field::getInstance($module, $adb);
        $modulefields = $fieldobj->getModuleFields();

        $formualFields = array();
        foreach ($modulefields as $fieldinfo) {
            $uitype = $fieldinfo->getUIType();
            $tmp_bigtype = $fieldinfo->getBigType();
            $columnname = $fieldinfo->getColumnName();
            $fieldlabel = $fieldinfo->getFieldLabel();
            if (empty($functiontype)) {
                //duan 20230418 去掉displaytype为2的字段
                if ($fieldinfo->getDisplaytype() == 2) {
                    continue;
                }
                //销售机会启用产品分录时，不允许选择amount字段用于计算字段公式
                if($module == 'Potentials' && get_file_address($module,"ProductDetails")){
                    if($columnname == 'amount'){
                        continue;
                    }
                }
                //字段布局中的所有数字和货币类型的字段可参与运算
                if (in_array($tmp_bigtype, array('number', 'currency')) && $columnname != 'currency_id') {
                    $formualFields[] = array('columnname' => $columnname, 'fieldlabel' => $fieldlabel);
                }
            }else{
                //去掉引用字段
                if ($fieldinfo->isRelatedModuleField() && $fieldinfo->getSaveDataBase()=='no') {
                    continue;
                }
                $formualFields[] = array('columnname' => $columnname, 'fieldlabel' => $fieldlabel);
            }

        }

        $formulahtml = '';
        $idindex = 0;
        //循环字段公式，显示界面
        foreach ($value['column'] as $columnname) {

            $formulahtml .= " <tr id='formual_row_$fieldid"."_"."$idindex'> ";
            $formulahtml .= " <td> ";
            $formulahtml .= " <select id='formualcombox_$fieldid"."_"."$idindex' name='formualcombox_$fieldid"."_"."$idindex' class='ld-select-inner gwidth70'>";
            $formulahtml .= " <option value='none'></option> ";
            //$columnname=substr($columnname,6,-6);
            //$columnname 是sf293
            $columnname = trim(trim($columnname, '039;'), ',');
            $columnname = trim(trim($columnname, '&'), ',');
            $columnname = trim(trim($columnname, '#039;'), '&');

            foreach ($formualFields as $Fields) {
                $fieldcolumn = $Fields['columnname'];
                $fieldlabel = $Fields['fieldlabel'];

                if ($fieldcolumn == trim($columnname, "'")) {
                    $formulahtml .= " <option value='" . $fieldcolumn . "' selected>" . $fieldlabel . "</option> ";
                } else {
                    $formulahtml .= " <option value='" . $fieldcolumn . "'>" . $fieldlabel . "</option> ";
                }

            }

            $formulahtml .= '</select>';
            $formulahtml .= " </td> ";

            $formulahtml .= " <td> ";
            $tmpstr = trim(trim($value['letters'][$idindex], '&#039;'), ',');//&#039;:是单引号的html
            $formulahtml .= "<input type='text' class='commonTextBoxPop' name='formualtext_$fieldid"."_"."$idindex' id='formualtext_$fieldid"."_"."$idindex' value='" . $tmpstr . "'>";
            $formulahtml .= " </td> ";

            $formulahtml .= " <td> ";
            $formulahtml .= '<a href="javascript:;" id="formualdeleteimg_'.$fieldid.'_' . $idindex . '" onclick="deleteFormulaRow(\'' . $idindex .','.$fieldid. '\')"></a>';
            $formulahtml .= " </td> ";
            $formulahtml .= "</tr>";
            $idindex++;
        }

        $smarty->assign('FORMULAHTML', $formulahtml);
    }

    //0051503:（表头字段公式）（https://81mis.com/kfbtest/index.php）页面设置》联系人模块，负责人、客户名称等字段编辑时都有高级属性页签；高级属性页签应只有数字、货币、时间、百分比这些字段类型才有
    $isShowAdvanced = 'no';//是否显示高级属性
    $cur_fieldinfo = $fieldobj->getFieldInfoobjBykey("fieldid",$_REQUEST['fieldid']);
    //uitype 51(产品分录里的，可查看方法:getFieldDataType())   70(创建时间、更新时间)
    if(isset($cur_fieldinfo))
    if (!empty($cur_fieldinfo)&&($cur_fieldinfo->isFldNumOrMoney() || in_array($cur_fieldinfo->getUIType(), array("5", "256", "23", "14", "86")) || $value['input_type'] == 'formula')) {
        $isShowAdvanced = 'yes';
    }
    $smarty->assign('isShowAdvanced', $isShowAdvanced);

    //duan 20221216 拜访签到预置的图片字段不允许选择添加水印
    if($fieldname == 'imagename' && $module == 'Singin'){
        $smarty->assign('SINGINWATERMARK', 'no');
    }
}
$afterdayNums = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180,365];//XUQIU1001765 xxy 2023-8-11 页面设置/单据分录定制，“日期”和“日期时间”字段默认值下拉选项增加显示n天前选项
$afterdayinfo_arr = array();
foreach ($afterdayNums as $dayNum) {
    $afterdayinfo_arr[] = array(
        'value' => "afterday" . $dayNum,
        'label' => $dayNum . " " . getFixedLabel("AFTERDAY")
    );
}
$daysagoNums = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180,365];
$daysagoinfo_arr = array();
foreach ($daysagoNums as $dayNum) {
    $daysagoinfo_arr[] = array(
        'value' => "daysago" . $dayNum,
        'label' => $dayNum . " " . getFixedLabel("DAYSAGO")
    );
}

//edit: xll 2024/03/15 BUG20240305-17  客户管理->页面设置，客户名称字段属性中应该不显示“显示超链接”参数
$HrefField_BigType = ['reference','multireference'];
// getEntitynameInfo(getTabid($module))['fieldname'] == $fieldname ||
if(in_array($bigtype,$HrefField_BigType)){
    $isHrefField = 'yes';
}

//edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
if($bigtype === 'fileattachment') {
    $advance_demand = json_decode(html_entity_decode($value['advance_demand'] ?? ''),true);
    $advance_demand_groups = json_decode(html_entity_decode($value['advance_demand_groups'] ?? ''),true);
    $keyArr = ['Download','Preview'];
    foreach ($keyArr as $key) {
        if(!empty($advance_demand[$key])) {
            $keyId = $key.'Allowed';
            $arr[$keyId] = [
                "computemodule"=> $module,
                "advance_demand"=> json_encode($advance_demand[$key]),
                "advance_demand_groups"=> json_encode($advance_demand_groups[$key]),
            ];
            $value[$keyId] = 'yes';
        }
    }
}
$smarty->assign('isHrefField', $isHrefField);
$smarty->assign('AfterDayInfo',$afterdayinfo_arr);
$smarty->assign('DaysAgoInfo',$daysagoinfo_arr);
$smarty->assign('MODULE',$module);
$smarty->assign('value',$value);
$smarty->assign('LANGUAGETYPE',$languageType);
//@edit:liushuai,2021-06-04,reason:【ID1001652】页面设置，“附件”和“图片”字段增加字段属性，控制签到水印是否显示（第二版）
require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
$smarty->assign('isKehu001','no');//本地部署账套显示该参数(uploadwatermark)，租赁账套暂时不显示该参数
crm_load_class_file("StaticConst",'WeiXinApp/WeiXin_common');
//判断当前模块是开启了源单定位
$isOpenSignIn = 'no';
$classname = 'cls_' . $module . '_DetailViewWX';
if(file_exists(globalStatic::$root_directory.'WeiXinApp/modules/' . $module . '/cls_' . $module.'/'.$classname.'.php')){
    crm_load_class_file('cls_Instance','WeiXinApp/WeiXin_common');
    $detialViewWx = cls_Instance::get_moduleAction_Instance($module,'DetailView');
    if($detialViewWx->isOpenSignIn($module,'boolean'))
        $isOpenSignIn = 'yes';
}
$smarty->assign('isOpenSignIn',$isOpenSignIn);

if($bigtype=='selectsource' || $uitype == '112')
{
    //选择原单

     $fld_module=$_REQUEST['frommodule'];
    crm_load_class_file("cls_sourcelist",'modules/Settings');
    $sourcelistobj=new cls_sourcelist($fld_module);
    
    $smarty->assign('LIST_ENTRIES',$sourcelistobj->getListContentData());
    $smarty->assign('LIST_HEADER',$sourcelistobj->getListHead());
 
   
}
//敏感规则
crm_load_class_file("cls_SensitiveRules",'modules/Settings');
$sensitivepresence = cls_SensitiveRules::getFieldSensitiveStatus($tabid,$fieldid);
$sensitiverules_listdata = cls_SensitiveRules::getRulesListByField($fieldid);
$smarty->assign('sensitivepresence',$sensitivepresence);//敏感规则开启状态
$smarty->assign('sensitiverules',$sensitiverules_listdata);//规则内容

$arr['bigtype']=$bigtype;
$arr['columnname']=$columnname;
$arr['typeofdata']=$typeofdata;
$arr['allowdelete']=$allowdelete;// 是否允许删除

$_REQUEST['diony']='yes';
$arr['title']=getFixedLabel('EDITPROPERTIES');
$arr['relatedmoduelfield']=$relatedmodulefield;

// edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
$valueFormatShow = false;
$formatTypeArr = ['date', 'datetime', 'time'];
if(in_array($bigtype, $formatTypeArr)) {
    $valueFormatShow = true;
    crm_load_class_file('FieldSet', 'modules/Settings/FieldSet');
    $timeFormatArr = FieldSet::getTimeFormatInfoByType($bigtype);
    $arr['timeFormatInfo'] = $timeFormatArr;
    $arr['timeFormatInfo']['selected'] = $value['valueFormat'] ?? '';
}
$smarty->assign('valueFormatShow', $valueFormatShow);

$arr['content']=$smarty->fetch('Settings/LayoutBlockList_EditField.tpl');
ConvertTojsonString(1,$arr,'');
exit();

?>