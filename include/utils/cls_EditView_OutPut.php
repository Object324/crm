<?php
class cls_EditView_OutPut
{
    var  $notallow_edit_arr;//链接模块设置条件，对应字段不可编辑
    public $isincludefile='yes';

    //editor:zkt 链接模块新增、编辑复制单据时，数据分类中设置为等于的条件不可编辑
    //获取高级查询条件数组中，等于条件对应的columnname及value设置的内容
    //$advfilter_arr:链接模块设置高级查询数组；
    public function setAdvFilter($advfilter_arr)
    {
        if(isset($advfilter_arr)&&!empty($advfilter_arr))
        {
            $tmp_notallow_edit_arr = array();
            foreach($advfilter_arr as $column_arr)
            {
                foreach($column_arr['columns'] as $key => $array)
                {
                    if($array['comparator']=='e')
                    {
                        $tmp_name =  explode(':',$array['columnname']);
                        $tmp_columnname =$tmp_name[1];
                        if(!isset($tmp_notallow_edit_arr[$tmp_columnname])&&empty($tmp_notallow_edit_arr[$tmp_columnname])){
                            $tmp_notallow_edit_arr[$tmp_columnname] = $array['value'];
                        }
                    }
                }
            }
            $this->notallow_edit_arr = $tmp_notallow_edit_arr;
        }
    }
    //editor:gyqCom0306 reason:输出样式,weixin微信输出样式 date:20170307
    //editor:gyq_20190725 reason:清除$this->output_type  2019/7/25 10:03
    //public $output_type;
    public function getEditViewOutputHtml($fieldobj, $maxlength, $col_fields,$generatedtype,$module_name,$mode='', $typeofdata=null,$fieldonly=0,$curapproveformodulefield=[]){
        global $adb,$default_charset,$edit_column_fields_value;
        global $theme;

        global $current_user,$weixin_user;
        $fldtypearr = Field::getFieldUitypeType($adb);
        $fldmodulerel = Field::getFieldEntity();
        if($this->isincludefile=='yes')
            crm_load_class_file('DateTimeField','include/fields');
        /**
         * 控制面板，用户界面是否编辑，要使用该变量
         * @reason 0015034: 合同订单>明细：审批失败后，没有删除关联的回款计划和提醒
         * @author Tujt 2015-05-20
         */
        $uitype=$fieldobj->getUIType();
        $fieldname=$fieldobj->getFieldName();
        $fieldlabel=$fieldobj->getFieldLabelKey();
        $columnname = $fieldobj->getColumnName();
        $defaultvalue = $fieldobj->getDefaultvalue();
        $is_admin = is_admin($current_user);
        $bigtype=$fieldobj->getBigType();
        $theme_path="themes/".$theme."/";
        $image_path=$theme_path."images/";
        $fieldlabel = from_html($fieldlabel);
        if($columnname=='campaignsview'){ //wym 240314 BUG20240308-29 kfbcrm-“市场活动”模块修改模块名称，成员管理详情页参数“市场活动相关信息查询所有数据”，“市场活动”没有跟着修改的模块名称自适应
            $fieldlabel=getTransTab('Campaigns').getFixedLabel('SEARCHALLRELEVANTDATA');
        }
        $fieldvalue = Array();
        $final_arr = Array();
        $value = $col_fields[$fieldname];
        $custfld = '';
        $ui_type[]= $uitype;

        $editview_fldname[] = $fieldname;
        $tmp_field_obj=Field::getInstance($module_name,$adb);
        $showfieldvalue=new ShowFieldValue($tmp_field_obj,$module_name,constant('SHOW_EDITVIEW'));

        $focus=CRMEntity::getInstance($module_name);
        $showfieldvalue->col_fields=$col_fields;
        $showfieldvalue->setRecorId($col_fields['record_id']);

        if($mode=='showpagerule'&&($fieldobj->getBigType()=='reference'||$fieldobj->getBigType=='picklist'||($fieldobj->getColumnName()=='sales_stage'&&$module_name=='Potentails')))
        {
            $showvalue['value']=$col_fields[$fieldname];
            $showvalue['optionvalue']=$col_fields[$fieldname];
            if($fieldobj->getBigType()=='reference')
            {
                $showvalue['value']=$col_fields[$fieldname."_name"];
            }


        }
        else{
            $showvalue=$showfieldvalue->getFieldValueByField($fieldobj,$col_fields[$fieldname],$col_fields[$fieldname]);
            if(Field::user_fields($uitype)&&isKehu001ServerPc()=='yes')
            {
                $showvalue['value'] = $showvalue['rawvalue'];
            }
            //duan 20240424 调用布局规则时,如果选择源单为空,但是源单类型有值,类型会被清空,增加从请求获取源单类型
            if($mode=='showpagerule'&& $uitype == '202' && !empty($col_fields['entitytype'])){
                $showvalue['entityname'] = $col_fields['entitytype'];
            }
        }

        //XUQIU1001834  ls 20230906 圣拉维特殊控制开发(大编辑页及列表编辑页及移动端编辑页,客户状态不做控制)
        $VersionInfo = getVersionInfo();
        if ($VersionInfo['account'] == 'shenglawei' && $module_name == 'Accounts' && $showvalue['value'] != '' && !in_array($columnname,array('rating','accountname','cf_7564','cf_7562','cf_7616','cf_7996')) && in_array($current_user->profileid,array(33,50,51))) {
            $fieldobj->set_allowedit('no');
        }
        if(array_key_exists("hrefvalue",$showvalue))

            $edit_column_fields_value[$fieldobj->getColumnName()]=array($col_fields[$fieldname],$showvalue['hrefvalue']);
        else
            $edit_column_fields_value[$fieldobj->getColumnName()]=array($col_fields[$fieldname],$showvalue['value']);

        //zkt 0047756: （81mis.com/kfbcrm）客户管理》客户_成交客户+IT；该模块是链接模块，条件是‘状态等于成交客户’或‘行业等于IT’；编辑单据admin366时，状态被改为了成交客户
        //链接模块等于条件不可修改
        if(isset($this->notallow_edit_arr[$columnname])&&!empty($this->notallow_edit_arr[$columnname])){
            $fieldobj->set_allowedit('no');
        }
        //链接模块数据分类条件包含该内容时设置对应value值
        if(isset($this->notallow_edit_arr[$columnname])&&!empty($this->notallow_edit_arr[$columnname])&&!isset($_REQUEST['record'])){
            //收款单收款类型设置为链接模块条件，界面新增应根据新增按钮类型显示。eg：新增 收款单_全部预收单时，直接新建应新建收款单
            if($module_name=='CashBill'&&$columnname=='cashtype'&&!empty($showvalue['rawvalue'])&&$bigtype=='translatefield'){
                $tmpresult = $adb->pquery("select labelbol from ld_translatefield where module=? and columnname=? and column_Dbvalue = ?;",
                    array($module_name,$columnname,$showvalue['rawvalue']));
                if($adb->num_rows($tmpresult)>0)
                {
                    $tmplabelbol = $adb->query_result($tmpresult,0,'labelbol');
                    $this->notallow_edit_arr[$columnname] = getFixedLabel($tmplabelbol);
                }
            }
            $showvalue['value']=$this->notallow_edit_arr[$columnname];
            $value = $this->notallow_edit_arr[$columnname];
            //zkt 20240708 BUG20240627-24 问题描述：模块“入库单”，查询分类设置了两个条件并设置了链接模块，在链接模块创建入库单另一个条件的值带不出来，单个条件的时候是正常的。
            if($uitype=='151'&&function_exists('getWareAllInfo'))
            {
                $ware_arr= getWareAllInfo($current_user);
                $ware_permit = 'no';
                foreach($ware_arr as $wareinfo)
                {
                    if($wareinfo['name']==$this->notallow_edit_arr[$columnname]||$wareinfo['id']==$this->notallow_edit_arr[$columnname])
                    {
                        $showvalue['rawvalue']=$wareinfo['id'];
                        break;
                    }
                }
            }
            //新增单据时设置条件中有关联单据条件，则反向查找单据id
            if($fieldobj->getBigType()=='reference'&&!isset($_REQUEST['record'])){
                $uitypemodules = cls_module_uitype::getUitypeModules();
                $referencemodule = $uitypemodules[$uitype];
                $referencefocus = CRMEntity::getInstance($referencemodule);
                $referencetab = $referencefocus->table_name;
                $referenceindex = $referencefocus->table_index;
                $entitynames = getEntitynameByModulename($referencemodule);
                $referencecode = $entitynames['fieldname'];
                $referencetab = $entitynames['tablename'];
                $referenceentity_table = $referencefocus->entity_table;
                $result = $adb->pquery("select $referenceindex from $referencetab where $referencecode = '$value'",array());
                if($adb->num_rows($result)>0){
                    $value = $adb->query_result($result,0,$referenceindex);
                }
            }

        }
        $allowedit=$fieldobj->get_allowedit();

        if(array_key_exists('approvestatus',$col_fields)){

            if($col_fields['approvestatus']==D_A_S_APPROVED)
            {
                //审批结束设置允许编辑的字段
                if($this->isincludefile=='yes')
                    crm_load_class_file('ApproveFinished','modules/Approve');
                $approvefinishedobj=ApproveFinished::getInstance($module_name,$_REQUEST['record']);

                $alloweditfield_arr= $approvefinishedobj->getAllowEditField();
                $tablename=$fieldobj->getTableName();
                $columnname=$fieldobj->getColumnName();

                if(!array_key_exists("$tablename:$columnname:$module_name",$alloweditfield_arr))
                {
                    $allowedit='no';

                }
            }
        }

        //	if($uitype == 230)return;//16482: 知识管理>新建：详细信息区块，缺少了文本编辑控件。
        //相关模块
        //uitype10uitype
        if($uitype == '82'){
            if(!empty($value)) {
                $valueType = getSalesEntityType($value);
                $displayValue = getModuleHref($valueType, $value);
            }
            else
            {
                $displayValue='';
                $valueType='';
                $value='';
            }

            $editview_label[]=$fieldlabel;
            $fieldvalue[] = Array('displayvalue'=>$displayValue,'entityid'=>$value);;
        }
        elseif($uitype == '10'||$uitype == '112'||$uitype==102) {//前面有模块选择框的
            global $adb;
            if($uitype==10)
            {
             /*   $fldmod_result = $adb->pquery('select ld_tab.name  from ld_quickactions
                        INNER JOIN ld_tab on ld_quickactions.tabid=ld_tab.tabid 
											 inner join ld_tab  as relatedTab on ld_quickactions.related_tabid=relatedTab.tabid
                        where relatedTab.name=\'reminds\'',array());*/
                $fldmod_result=$adb->pquery('select ld_tab.name from ld_tab where presence=111111',array());


            }
            else if($uitype==102)
            {
                //$fldmod_result = $adb->pquery('select ld_tab.name  from ld_tab

                // where name=\'SalesOrder\' or name=\'ServiceContracts\'',array());
                //（51mis.com/kfbcrm）项目立项模块页面设置>选择源单字段编辑弹出层：选择源单字段缺少了“源单类型定制”区块。（如图）
                $fldmod_result=$adb->pquery("select ld_tab.name,ld_option_module.`default` from ld_option_module 
                                             inner join ld_tab on ld_tab.tabid= ld_option_module.option_tabid
                                            where ld_option_module.tabid=? and ld_option_module.presence=0 order by ld_option_module.sequence asc",array(getTabid($module_name)));


            }
            else{
                if($uitype==112 && $module_name == 'Reminds')
                {
                    //ls 2022-02-22 0050064: https://81mis.com/kfbcrm/ [^]) 通用问题：提醒中心-发件箱-新建-相关对象选不到销售线索模块(同自动提醒设置可选模块一致)
                    //edit: xll XUQIU1001203 评论、附件管理、提醒模块相关对象改为选择源单样式
                    //wym 20230703 BUG0068691 提醒新建界面，相关对象应该不显示“工作汇报（列表）”、“订货商城”、“商城设置”、“渠道码”、“调查问卷”、“报表分析”模块
                    $sql="SELECT DISTINCT ld_option_module.option_tabid,`name`,tablabel,ld_tranlabel.fieldlabel,ld_option_module.default 
                    FROM ld_option_module 
                    INNER JOIN ld_tranlabel ON ld_option_module.option_tabid = ld_tranlabel.relateid 
                    INNER JOIN ld_tab ON ld_option_module.option_tabid = ld_tab.tabid 
                    WHERE languagetype = ? AND trantable = ? AND ld_option_module.presence = 0 AND ld_option_module.tabid = ? AND ld_option_module.option_tabid not in (256,-12,253,257,249,205)
                    ORDER BY ld_option_module.sequence";
                    $fldmod_result=$adb->pquery($sql,array(getLanguageType($current_user),'ld_tab',getTabid($module_name)));
                }
                //zkt 20220921 BUG0056783评论模块新建相关模块选不到销售线索，但是销售线索可以评论
                else if($uitype==112 && $module_name == 'ModComments')
                {
                    //edit: xll XUQIU1001203 评论、附件管理、提醒模块相关对象改为选择源单样式
                    $sql="SELECT DISTINCT ld_option_module.option_tabid,`NAME`,tablabel,ld_tranlabel.fieldlabel,ld_option_module.default 
                    FROM ld_option_module 
                    INNER JOIN ld_tranlabel ON ld_option_module.option_tabid = ld_tranlabel.relateid 
                    INNER JOIN ld_tab ON ld_option_module.option_tabid = ld_tab.tabid 
                    WHERE languagetype = ? AND trantable = ? AND ld_option_module.presence = 0 AND ld_option_module.tabid = ? 
                    ORDER BY ld_option_module.sequence";
                    $fldmod_result=$adb->pquery($sql,array(getLanguageType($current_user),'ld_tab',getTabid($module_name)));
                }
                else{
                    //edit: xll XUQIU1001203 评论、附件管理、提醒模块相关对象改为选择源单样式
                    //wym BUG0068886 附件管理->页面设置，相关对象弹出层中不启用“联系人”模块后，附件管理相关对象下拉选项中仍显示了“联系人”模块
                    $fldmod_result = $adb->pquery('select distinct ld_tab.name,ld_option_module.default  from ld_option_module 
                    INNER JOIN ld_tab on ld_tab.tabid=ld_option_module.option_tabid 
                    where ld_option_module.tabid=? AND ld_option_module.presence = 0 ',array(getTabid($module_name)));
                }
            }




            $entityTypes = Array();
            $parent_id = $value;
            $entityTypes[] = '';//相关对象下拉框增加空行，防止模块关闭后导致已有数据对应的选项错乱
            for($index = 0; $index < $adb->num_rows($fldmod_result); ++$index) {
                $relmodule = $adb->query_result($fldmod_result, $index, 'name');
                //035057: pc端：当附件管理模块，当前操作员没有的模块权限，相关对象中不应该显示。
                if(vtlib_isModuleActive($relmodule)&&isPermitted($relmodule,"index")=='yes'){
                    $entityTypes[] = $relmodule;
                }
                //edit: xll XUQIU1001203 评论、附件管理、提醒模块相关对象改为选择源单样式  此处实现设为默认属性控制功能
                //zkt 20230911 BUG0072045 （http://42.193.125.39:85/crm）8506版本，工程账套，使用了lingdang.dll，项目立项Project的“源单”字段，已经设置了“源单”的默认模块，但是在新建时，还需要再手动选择源单模块，不能默认带出。
                If(($uitype==112 && in_array($module_name,array('ModComments','Reminds','Attachment')))||($uitype==102 && $module_name=='Project')){
                    $default = $adb->query_result($fldmod_result, $index, 'default');
                    if($default == '1')
                        $default_value = $relmodule;
                }
            }


            if(!empty($value)) {
                if($col_fields['reltab']=='Users')
                {
                    $valueType='Users';
                    $displayValue=getUserFullName($value);
                }
                else
                {
                    $valueType = getSalesEntityType($value);
                    //BUG0074708 xxy 历史遗留问题,ld_crmentity中旧成员的settype不是Users,导致关联创建就不是成员管理 成员管理-相关信息栏点击附件管理-新建-相关对象显示的是银行账户模块
                    if($_REQUEST['frommodule'] == 'Users' && $fieldname == 'related_to'){
                        $valueType = 'Users';
                    }
                    $displayValue = getModuleHref($valueType, $value);
                }
                //	0027903: 服务收费管理明细界面：相关信息-附件管理：新建，结果相关模块显示的是：客户
                if($valueType == 'Accounts' && !empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'ServiceCharge'){
                    $valueType = 'ServiceCharge';
                }
            } else {
                $displayValue='';
                //edit: xll XUQIU1001203 评论、附件管理、提醒模块相关对象改为选择源单样式  此处实现设为默认属性控制功能
                $valueType = empty($default_value) ? '' : $default_value;
                $value='';
            }
            //评论模块 相关评论
            if($fieldname == 'parent_comments'||$fieldname == 'parent_reply'){
                $entityTypes = array();
                $entityTypes[] = 'ModComments';
                $valueType = '';
            }
            $editview_label[] = Array('options'=>$entityTypes, 'selected'=>$valueType, 'displaylabel'=>($fieldlabel));
            $fieldvalue[] = Array('displayvalue'=>$displayValue,'entityid'=>$parent_id);

        }
        else if($uitype==602)//项目模块关联创建项目计划时，将客户名称显示出来。
        {

            if(!empty($value)) {
                $valueType = getSalesEntityType($value);
                $displayValue = getModuleHref($valueType, $value);
                //数据删除了，id清空
                //36734: （http://218.2.247.42:85/crm [^]）销售机会>单据编号为POT397>明细界面关联创建销售合同：客户名称为必填项，但是没有录入客户名称也可以保存。
                if($displayValue==''){
                    $value='';
                }
            }
            else
            {
                $displayValue='';
                $valueType='';
                $value='';
            }

            $editview_label[]=$fieldlabel;
            $fieldvalue[] = $displayValue;
            $fieldvalue[] = $value;
        }
        else if(isset($fldmodulerel[$uitype])) {//66、68、357

            $parent_id = 0;$parent_name = '';$parent_module = '';$entityTypes = array();
            if(!empty($value)) {
                $parent_id = $value;
                $parent_module = getSalesEntityType($parent_id);
                $parent_name = getModuleHref($parent_module,$parent_id);
                $entityTypes[] = $parent_module;
            }
            $editview_label[] = Array(
                'options'=>$entityTypes,
                'selected'=>$parent_module,
                'displaylabel'=>$fieldlabel);
            $fieldvalue[] = Array('displayvalue'=>$parent_name,'entityid'=>$parent_id);
        }
        else if(isset($fldtypearr[$uitype]) && (constant('REFERENCE_FIELD') == $fldtypearr[$uitype]['fieldtype'] || constant('MULTIREFERENCE_FIELD') == $fldtypearr[$uitype]['fieldtype'])
            ||$uitype==79 ){//关联模块字段

            $entityname = $showvalue['value'];
            $editview_label[] = $fieldlabel;
            $fieldvalue[] = $entityname;
            $fieldvalue[] = $value;

            if($_REQUEST['isDuplicate']&&empty($showvalue['value'])&&empty($showvalue['entityname']))
            { //BUG0068248 20230904 ls 付款单开启源单，当有选择模块时，复制时也应该选中模块，否则分录保存会失败
                //收付款单复制，被复制的单据原单为空，则复制的单据原单也为空
                //edit:can 60333 】V8.4.8.3（http://jsjingmei.gnway.org/crm）（远程时需联系客户，密码会变）
                $showvalue['entityname']='';
            }
            $fieldvalue[]=$showvalue['entityname'];

        }
        else if($uitype==202||$uitype==208)
        {
            $editview_label[] = $fieldlabel;
            $fieldvalue[] = $showvalue['value'];
            $fieldvalue[] = $value;
            $fieldvalue[]=$showvalue['entityname'];
        }
        else if($uitype==1101 || $uitype == 152 || $uitype == 180 || $uitype == 154 || $uitype == 1600 ||$uitype == 603 )
        {


            $editview_label[] = $fieldlabel;
            $fieldvalue[] = $showvalue['value'];
            $fieldvalue[] = $showvalue['rawvalue'];

        }
        else if($uitype==1108){


            $editview_label[] = $fieldlabel;

            $fieldvalue[] = implode(',',(array)$value);


        }
        else if($uitype == 5 || $uitype == 6 || $uitype ==23||$uitype == 86){// END



            if($uitype == 6) {
                if ($col_fields['time_start'] != '' && ($module_name == 'Events' || $module_name
                        == 'Calendar'||$module_name == 'Reminds')) {
                    $curr_time = $col_fields['time_start'];
                    $value = $value . ' ' . $curr_time;
                } else {
                    $curr_time = date('H:i', strtotime('+5 minutes'));
                }
            }
            if(($module_name == 'Events' || $module_name == 'Calendar') && $uitype == 23) {
                if ($col_fields['time_end'] != '') {
                    $curr_time = $col_fields['time_end'];
                    $value = $value . ' ' . $curr_time;
                } else {
                    $curr_time = date('H:i', strtotime('+10 minutes'));
                }
            }
            $disp_value=$showvalue['value'];

            //$disp_value = getValidDisplayDate($value);//edit:can;如果$value值为空，则$disp_value应该为空，而不是获取默认值


            $editview_label[]=($fieldlabel);
            $date_format = 'YYYY-mm-dd';
            if(!empty($curr_time)) {
                if(($module_name == 'Events' || $module_name == 'Calendar'||$module_name == 'Events') && ($uitype == 23 ||
                        $uitype == 6)) {
                    $curr_time = DateTimeField::convertToUserTimeZone($curr_time);
                    $curr_time = $curr_time->format('H:i');
                }
            }

            $fieldvalue[] = array($disp_value => $curr_time) ;
            if($uitype == 5 || $uitype == 23)
            {
                if($module_name == 'Events' && $uitype == 23)
                {
                    $fieldvalue[] = array($date_format=>$current_user->date_format.' '.$app_strings['YEAR_MONTH_DATE']);
                }
                else
                    $fieldvalue[] = array($date_format=>$current_user->date_format);
            }
            else
            {
                $fieldvalue[] = array($date_format=>$current_user->date_format.' '.$app_strings['YEAR_MONTH_DATE']);
            }

        }
        elseif($uitype == 70){

            $dateValue = $value;
            $editview_label[]=($fieldlabel);

            $date='';
            $isPop=false;
            if ($dateValue == '0000-00-00 00:00:00' || empty($dateValue)) {
                $date = new DateTimeField(date('Y-m-d H:i'));

            } else {
                $date = new DateTimeField($value);
                $isPop=true;
            }
            $displayValue = $date->getDisplayDateTimeValue();

            $dis_date=substr($displayValue,0,10);
            $dis_time=substr($displayValue,11,5);
            $dis_time=explode(':',$dis_time);
            if(strstr($fieldname,'end')){
                $dis_time=$this->getTimeHtml($dis_time,$fieldname);
            }else{
                $dis_time=$this->getTimeHtml($dis_time,$fieldname);
            }
            if($fieldobj->isRelatedModuleField())
            {
                $fieldvalue[] = array($dateValue,$dis_time,$isPop);
            }
            else
                $fieldvalue[] = array($dis_date,$dis_time,$isPop);
            $date_format ='YYYY-mm-dd';
            $fieldvalue[] = array($date_format=>$current_user->date_format.' '.$app_strings['YEAR_MONTH_DATE']);

        }
        elseif($uitype == 357) {
            $pmodule = $_REQUEST['pmodule'];
            if(empty($pmodule))
                $pmodule = $_REQUEST['par_module'];

            if($pmodule == 'Contacts')
            {
                $contact_selected = 'selected';
            }
            elseif($pmodule == 'Accounts')
            {
                $account_selected = 'selected';
            }

            elseif($pmodule == 'Vendors')
            {
                $vendor_selected = 'selected';
            }
            elseif($pmodule == 'Users')
            {
                $user_selected = 'selected';
            }
            if(isset($_REQUEST['emailids']) && $_REQUEST['emailids'] != '')
            {
                $parent_id = $_REQUEST['emailids'];
                $parent_name='';

                $myids=explode("|",$parent_id);
                for ($i=0;$i<(count($myids)-1);$i++)
                {
                    $realid=explode("@",$myids[$i]);
                    $entityid=$realid[0];
                    $nemail=count($realid);

                    if ($pmodule=='Accounts'){
                        require_once('modules/Accounts/Accounts.php');
                        $myfocus = new Accounts();
                        $myfocus->retrieve_entity_info($entityid,"Accounts");
                        $fullname=br2nl($myfocus->column_fields['accountname']);
                        $account_selected = 'selected';
                    }
                    elseif ($pmodule=='Contacts'){
                        require_once('modules/Contacts/Contacts.php');
                        $myfocus = new Contacts();
                        $myfocus->retrieve_entity_info($entityid,"Contacts");
                        $fname=br2nl($myfocus->column_fields['firstname']);
                        $lname=br2nl($myfocus->column_fields['lastname']);
                        $fullname=$lname.' '.$fname;
                        $contact_selected = 'selected';
                    }

                    for ($j=1;$j<$nemail;$j++){
                        $querystr='select columnname from ld_field where fieldid=? and ld_field.presence in (0,2)';
                        $result=$adb->pquery($querystr, array($realid[$j]));
                        $temp=$adb->query_result($result,0,'columnname');
                        $temp1=br2nl($myfocus->column_fields[$temp]);

                        //Modified to display the entities in red which don't have email id
                        if(!empty($temp_parent_name) && strlen($temp_parent_name) > 150)
                        {
                            $parent_name .= '<br>';
                            $temp_parent_name = '';
                        }

                        if($temp1 != '')
                        {
                            $parent_name .= $fullname.'&lt;'.$temp1.'&gt;; ';
                            $temp_parent_name .= $fullname.'&lt;'.$temp1.'&gt;; ';
                        }
                        else
                        {
                            $parent_name .= "<b style='color:red'>".$fullname.'&lt;'.$temp1.'&gt;; '."</b>";
                            $temp_parent_name .= "<b style='color:red'>".$fullname.'&lt;'.$temp1.'&gt;; '."</b>";
                        }

                    }
                }
            }
            else
            {
                if($_REQUEST['record'] != '' && $_REQUEST['record'] != NULL)
                {
                    $parent_name='';
                    $parent_id='';
                    $myemailid= $_REQUEST['record'];
                    $mysql = "select crmid from ld_seactivityrel where activityid=?";
                    $myresult = $adb->pquery($mysql, array($myemailid));
                    $mycount=$adb->num_rows($myresult);
                    if($mycount >0)
                    {
                        for ($i=0;$i<$mycount;$i++)
                        {
                            $mycrmid=$adb->query_result($myresult,$i,'crmid');
                            $parent_module = getSalesEntityType($mycrmid);
                            if($parent_module == "Contacts")
                            {
                                $sql = "select lastname from  ld_contactdetails where contactid=?";
                                $result = $adb->pquery($sql, array($mycrmid));
                                $full_name = getFullNameFromQResult($result,0,"Contacts");
                                $myemail=$adb->query_result($result,0,"email");
                                $parent_id .=$mycrmid.'@0|'  ;//make it such that the email adress sent is remebered and only that one is retrived
                                $parent_name .= $full_name.'<'.$myemail.'>; ';
                                $contact_selected = 'selected';
                            }
                            elseif($parent_module == "Accounts")
                            {
                                $sql = "select accountname from  ld_account where accountid=?";
                                $result = $adb->pquery($sql, array($mycrmid));
                                $account_name = $adb->query_result($result,0,"accountname");
                                $myemail=$adb->query_result($result,0,"email1");
                                $parent_id .=$mycrmid.'@0|'  ;//make it such that the email adress sent is remebered and only that one is retrived
                                $parent_name .= $account_name.'<'.$myemail.'>; ';
                                $account_selected = 'selected';
                            }elseif($parent_module == "Users")
                            {
                                $sql = "select user_name,email1 from ld_users where id=?";
                                $result = $adb->pquery($sql, array($mycrmid));
                                $account_name = $adb->query_result($result,0,"user_name");
                                $myemail=$adb->query_result($result,0,"email1");
                                $parent_id .=$mycrmid.'@0|'  ;//make it such that the email adress sent is remebered and only that one is retrived
                                $parent_name .= $account_name.'<'.$myemail.'>; ';
                                $user_selected = 'selected';
                            }
                            elseif($parent_module == "Vendors")
                            {
                                $sql = "select vendorname from  ld_vendor where vendorid=?";
                                $result = $adb->pquery($sql, array($mycrmid));
                                $vendor_name = $adb->query_result($result,0,"vendorname");
                                $myemail=$adb->query_result($result,0,"email");
                                $parent_id .=$mycrmid.'@0|'  ;//make it such that the email adress sent is remebered and only that one is retrived
                                $parent_name .= $vendor_name.'<'.$myemail.'>; ';
                                $vendor_selected = 'selected';
                            }
                        }
                    }
                }
                $custfld .= '<td width="20%" class="dataLabel">'.$app_strings['To'].'&nbsp;</td>';
                $custfld .= '<td width="90%" colspan="3"><input name="parent_id" type="hidden" value="'.$parent_id.'"><textarea readonly name="parent_name" cols="70" rows="2">'.$parent_name.'</textarea>&nbsp;<select name="parent_type" >';
                $custfld .= '<OPTION value="Contacts" selected>'.$app_strings['COMBO_CONTACTS'].'</OPTION>';
                $custfld .= '<OPTION value="Accounts" >'.$app_strings['COMBO_ACCOUNTS'].'</OPTION>';

                $custfld .= '<OPTION value="Vendors" >'.$app_strings['COMBO_VENDORS'].'</OPTION></select><a class="icon-homeimg icon-select" href="javascript:;" title="'.$app_strings['LBL_SELECT_BUTTON_LABEL'].'" onclick=\'return window.open("index.php?module="+ document.EditView.parent_type.value +"&action=Popup&popuptype=set; return_emails&form=EmailEditView&form_submit=false","test","width=600,height=400,resizable=1,scrollbars=1,top=150,left=200");\'></a>&nbsp;<input class="icon-homeimg icon-clear inpb-reset" type="button" title="'.$app_strings['LBL_CLEAR_BUTTON_LABEL'].'" onClick="this.form.parent_id.value=\'\';this.form.parent_name.value=\'\';return false;"/></td>';
                //by LDCan 20121217  bug:2889 库存管理 供应商明细 更多信息 新增Email 收件人下拉列表潜在客户去掉
                $editview_label[] = array(
                    'Contacts'=>$contact_selected,
                    'Accounts'=>$account_selected,
                    'Vendors'=>$vendor_selected,
                    //'Leads'=>$lead_selected,
                    'Users'=>$user_selected
                );
                $fieldvalue[] =$parent_name;
                $fieldvalue[] = $parent_id;
            }
        }
        elseif($uitype == 16) {
            require_once( globalStatic::$root_directory.'modules/PickList/PickListUtils.php');
            $editview_label[]=$fieldlabel;
            $fieldvalue [] = $showvalue['optionvalue'];

        }
        elseif($uitype == 15 || $uitype == 33 || $uitype==601){
            //echo $fieldname."<br>";
            require_once( globalStatic::$root_directory.'modules/PickList/PickListUtils.php');
            $profileid=$current_user->profileid;
            $notablepick=array('approvestatus_Users','level_Users');
            if($module_name == 'LessionPlan'){
                $fieldvalue[]='';
            }
            else{
                $editview_label[]=$fieldlabel;
                $fieldvalue [] = $showvalue['optionvalue'];

            }


        }elseif($uitype == 34){
            //edit:duan date:2024/10/24 reason:用户模块的职位级别字段特殊处理
            $groupid_str = $col_fields['groupid'];
            $groupid_arr = explode(',',$groupid_str);
            $record_id = $col_fields['record_id'];
            $value_arr = [];
            $show_value_arr = [];
            $num_rows = 0;

            if(isset($col_fields['jsonvalue_'.$fieldname]) ){
                $json_value = $col_fields['jsonvalue_'.$fieldname];
                $json_arr = json_decode($json_value,true);
                foreach ($json_arr as $tmp_arr){
                    $tmp_groupid = $tmp_arr['id'];
                    $content = $tmp_arr['value'];

                    $value_arr[] = ['id'=>$tmp_groupid,'value'=>$content];
                    if(!empty($content)){
                        $show_value_arr[] = ['id'=>$tmp_groupid,'name'=>getGroupFullName($tmp_groupid),'value'=>$content];
                    }
                }

            }elseif($record_id != ""){
                if(empty($groupid_str)||trim($groupid_str,',')=='')
                {
                    foreach ($groupid_arr as $tmp_groupid){
                        $value_arr[] = ['id'=>$tmp_groupid,'value'=>''];
                    }
                }
                else{
                    $sql = "SELECT groupid,content from ld_user_group_set where userid = ? and groupid in (".$groupid_str.") and type = 'userlevel'";
                    $result = $adb->pquery($sql,[$record_id]);
                    $num_rows = $adb->num_rows($result);
                    if($num_rows >0){
                        for ($tmp_index=0;$tmp_index < $num_rows;$tmp_index++){
                            $tmp_groupid = $adb->query_result($result,$tmp_index,'groupid');
                            $content = $adb->query_result($result,$tmp_index,'content');

                            $value_arr[] = ['id'=>$tmp_groupid,'value'=>$content];
                            if(!empty($content)){
                                $show_value_arr[] = ['id'=>$tmp_groupid,'name'=>getGroupFullName($tmp_groupid),'value'=>$content];
                            }
                        }
                    }else{
                        foreach ($groupid_arr as $tmp_groupid){
                            $value_arr[] = ['id'=>$tmp_groupid,'value'=>''];
                        }
                    }
                }

            }else{
                if(empty($defaultvalue))$defaultvalue = '';
                foreach ($groupid_arr as $tmp_groupid){
                    $value_arr[] = ['id'=>$tmp_groupid,'value'=>$defaultvalue];
                    if(!empty($content)){
                        $show_value_arr[] = ['id'=>$tmp_groupid,'name'=>getGroupFullName($tmp_groupid),'value'=>$content];
                    }
                }
            }
            $json_value = json_encode($value_arr);

            $editview_label[]=$fieldlabel;
            $fieldvalue [] = $showvalue['value'];
            $fieldvalue [] = $show_value_arr;
            $fieldvalue [] = htmlentities($json_value);
            //dump($showvalue);

        }elseif($uitype == 251 || $uitype == 252){


            $fieldvalue=$showvalue['optionvalue'];

            $editview_label[]=$fieldlabel;
            if(empty($showvalue['rawvalue'])){
                //客户创建收款单带出预收款信息
                //$showvalue['rawvalue']=$fieldvalue[0][1][0];
                $edit_column_fields_value[$fieldobj->getColumnName()]=array($fieldvalue[0][1][0],$showvalue['value']);

            }


        }
        else if($uitype ==150 && ($mode == 'edit'||$module_name=='SendCashBill'||$module_name=='SendPayment'))
        {
            $editview_label[]=$fieldlabel;

            if(!empty($value))
            {
                $fieldvalue [] = getModuleHref('PurchaseOrder',$value);
                $fieldvalue [] = $value;
            }
            else
            {
                $fieldvalue [] = '';
                $fieldvalue [] = $value;
            }

        }
        /**
         * *新增操作，公告接收人字段
         * *by andy
         * *20140318
         * */
        else if($uitype == 242)
        {
            $editview_label[]=$fieldlabel;
            $fieldvalue=getReceipts($col_fields['record_id']);

        }
        elseif ($uitype ==1021 || $uitype==1022 ||$uitype==1023)
        {
            require_once( globalStatic::$root_directory.'modules/PickList/PickListUtils.php');
            $picklistValues = getPicklistValesForNORole($fieldname, $adb);
            $valueArr = explode("|##|", $value);
            $pickcount = 0;

            if(!empty($picklistValues)){
                foreach($picklistValues as $order=>$pickListValue){
                    if(in_array(trim($pickListValue),array_map("trim", $valueArr))){
                        $chk_val = "selected";
                        $pickcount++;
                    }else{
                        $chk_val = '';
                    }
                    if(isset($_REQUEST['file']) && $_REQUEST['file'] == 'QuickCreate'){
                        $options[] = array(htmlentities($pickListValue,ENT_QUOTES,$default_charset),$pickListValue,$chk_val );
                    }else{
                        $options[] = array($pickListValue,$pickListValue,$chk_val );
                    }
                }

                if($pickcount == 0 && !empty($value)){
                    $options[] =  array(getFixedLabel('NOTACCESS'),$value,'selected');
                }
            }
            $editview_label[]=$fieldlabel;
            $fieldvalue [] = $options;

        }

        elseif($uitype == 19 || $uitype == 20)
        {
            if(isset($_REQUEST['body']))
            {
                $value = ($_REQUEST['body']);

            }

            if($fieldname == 'terms_conditions')//for default Terms & Conditions
            {
                //Assign the value from focus->column_fields (if we create Invoice from SO the SO's terms and conditions will be loaded to Invoice's terms and conditions, etc.,)
                $value = $col_fields['terms_conditions'];

                //if the value is empty then only we should get the default Terms and Conditions
                if($value == '' && $mode != 'edit')
                    $value=getTermsandConditions();
            }
            $editview_label[]=$fieldlabel;

            if($USE_RTE == 'false'){
                $value=html_entity_decode($value);
                $fieldvalue [] = strip_tags($value);

            }else{
                $fieldvalue [] = decode_html($value);
            }

        }

        elseif($uitype == 100)
        {

            $editview_label[]=$fieldlabel;

            if($value != '' && $value != 0)
                $assigned_user_id = $value;
            else{
                $assigned_user_id = $current_user->id;
            }
            $user_arr=get_user_array(FALSE, "Active", $assigned_user_id);
            $users_combo = get_select_options_array($user_arr, $assigned_user_id);
            $fieldvalue[]=$users_combo;

        }
        elseif($uitype == 174){	//多选模块 客户
            $editview_label[]=$fieldlabel;
            crm_load_class_file('DetailView_174', 'include/fields/DetailView');
            $modulehref = DetailView_174::get_uitype_174($focus, $fieldobj, $col_fields);
            $fieldvalue[] = $modulehref[2];
            $fieldvalue[] = $modulehref[1];
        }
        elseif($uitype == 303){	//适用范围
            $editview_label[]=$fieldlabel;
            $scope_query = "select advft_criteria,advft_criteria_groups from $focus->table_name where $focus->table_index = ?";
            $scope_result = $adb->pquery($scope_query,array($col_fields['record_id']));
            $fieldvalue[] = $adb->query_result($scope_result,0,'advft_criteria');
            $fieldvalue[] = $adb->query_result($scope_result,0,'advft_criteria_groups');
        }
        elseif($uitype == 53 || $uitype == 153)
        {
            $editview_label[]=$fieldlabel;
            //zkt 链接模块数据分类选择条件为销售负责人、负责人等字段时，value获取对应的id值，否则设为空
            //ls 20220818 BUG0055220 销售订单和出库提货单，这两个单增加了“单选用户”类型的制单人字段，设置有了默认值，但是新建界面是默认显示的是创建人
            if(isset($this->notallow_edit_arr[$columnname])&&!empty($this->notallow_edit_arr[$columnname])&&!isset($_REQUEST['record']))
            {
                $user_result=$adb->pquery('select id from ld_users where last_name=?',array($value));
                $rows = $adb->num_rows($user_result);
                if($rows>0){
                    $value = $adb->query_result($user_result,0,'id');
                }
                else{
                    $value = '';
                }
            }
            if($value != '' && $value != 0)
                $assigned_user_id = $value;
            else{
//                @edit:liushuai,2021-03-04,reason:【ID1001429】页面设置新增自定义“单选用户”类型字段，默认值为空，只有系统预置的负责人字段才有默认值
                if(($value=='0' || $value == '') && $uitype == '153'){
                    //服务收费管理 的服务收费人也要有默认值
                    $assigned_user_id = '';
                }else
                    $assigned_user_id = $current_user->id;
            }
            //38163: （51mis.com/kfbcrm）客户服务单关联创建跟进记录时，跟进记录新建界面【引用服务单服务人员】没有带出字段值
            //38191: 页面设置->新增字段->引用字段->引用客户销售负责人、保存到数据库、不可编辑，带出信息后收起/展开字段显示为ID了
            if($fieldobj->isRelatedModuleField())
            {
                //引用字段为空
                $assigned_user_id=$value;
            }
            //克莱门特  商品的调试人，可以在新建的时候默认空白吗？ 商品还未调试，有人名存在不合适
            $VersionInfo = getVersionInfo();
            if($VersionInfo['account'] == 'climaveneta' && $module_name == 'Products' && $uitype == 153 && empty($_REQUEST['record'])){
                $assigned_user_id = '';
            }
            if($VersionInfo['account'] == 'climaveneta' && ($module_name == 'Potentials' || $module_name == 'HelpDesk') && $uitype == 153){
                if(empty($value))$assigned_user_id = '';
            }
            /**
             * 暂时让所有人能看到所有用户
             * @author Tujt 2015-04-23
             */
            //18060: 合同订单>新建：界面上方有乱码。
//		   $user_arr=get_user_array(FALSE, "Active", $assigned_user_id);
            //wyt 220929 XUQIU1000728 新建单据时，单据的【销售负责人】允许选择到所有成员包括离职成员
            $user_arr_all=get_user_array(FALSE, "", "");
            //wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据
            $fieldid = $fieldobj->getFieldid();
            $users_select = $this->getUserSelect($fieldid, $user_arr_all, $module_name, $current_user);//选择的成员范围
            $users_result_othercondition=$this->getUserSelect_othercondition($fieldid);//选择成员范围其他条件
            $users_result=array_intersect_key(is_array($users_select)?$users_select:[],is_array($users_result_othercondition['users_result'])?$users_result_othercondition['users_result']:[]);

            $users_combo = get_select_options_array($users_result, $assigned_user_id);
            $users_combo = is_array($users_combo)?$users_combo:[];
            /*0008993: “个人权限用户”审批单据时，若点击“编辑”按钮，保存后，会导致单据的销售负责人改变
            *20140604
            *将原订单销售负责人拼接到下拉列表中
            */
            //wyt 220928 BUG0057222 在单选用户字段，也存在条件设为选择部门的时候。出现只能选择当前用户 在负责人字段，选择按照职位级别，出现只能选择当前用户
            if(!array_key_exists($assigned_user_id,$users_combo) && !empty($assigned_user_id)&& ($focus->mode=='edit' || $mode=='showpagerule'))   //避免下拉框出现空白选项
            {
                $users_combo[$assigned_user_id]=array(getOwnerName($assigned_user_id)=>'selected');
            }
            $fieldvalue[]=$users_combo;
        }
        elseif($uitype == 55 || $uitype == 255){
            require_once( globalStatic::$root_directory.'modules/PickList/PickListUtils.php');

            if($uitype == 255 && $fieldpermission == '0'){
                $fieldvalue[] = '';
            }else{
                $fieldvalue=$showvalue['optionvalue'];

            }
            $editview_label[]=($fieldlabel);
            $fieldvalue[] = $value;
        }
        elseif($uitype == 63)
        {
            $editview_label[]=($fieldlabel);
            if($value=='')
                $value=1;
            $options = array();
            $pick_query="select * from ld_duration_minutes order by sortorderid";
            $pickListResult = $adb->pquery($pick_query, array());
            $noofpickrows = $adb->num_rows($pickListResult);
            $salt_value = $col_fields["duration_minutes"];
            for($j = 0; $j < $noofpickrows; $j++)
            {
                $pickListValue=$adb->query_result($pickListResult,$j,"duration_minutes");

                if($salt_value == $pickListValue)
                {
                    $chk_val = "selected";
                }
                else
                {
                    $chk_val = '';
                }
                $options[$pickListValue] = $chk_val;
            }
            $fieldvalue[]=$value;
            $fieldvalue[]=$options;

        }
        elseif($uitype == 156)
        {
            $editview_label[]=$fieldlabel;
            $fieldvalue[] = $value;
            //wym BUG0076366 引用成员管理-是否管理员 字段 不能直接获取当前用户是否管理员 应查看引用对象是否管理员
            if($fieldobj->getRelatedModuleField()!='yes'){
                $fieldvalue[] = $is_admin;
            }
        }
        elseif($uitype == 56)
        {
            //$editview_label[]=getFixedLabel(strtoupper($fieldlabel));
            $editview_label[]=$fieldlabel;
            if($value==='yes'||$value==='是')
            {
                $value='1';//edit:can reason:16133: 用户资料中的checkbox选项的默认值应该从数据库中设置，而不是代码控制
            }
            if($value=='')
            {
                $value=0;
            }

            $fieldvalue[] = $value;
            if($value == 1)
                $fieldvalue[] = getFixedLabel('YES');
            else
                $fieldvalue[] = getFixedLabel('NO');
        }
        elseif($uitype == 61)
        {
            if($value != '')
            {
                $assigned_user_id = $value;
            }
            else
            {
                $assigned_user_id = $current_user->id;
            }
            if($module_name == 'Emails' && $col_fields['record_id'] != '')
            {
                $attach_result = $adb->pquery("select attachmentsid from ld_seattachmentsrel where crmid = ?", array($col_fields['record_id']));
                //to fix the issue in mail attachment on forwarding mails
                if(isset($_REQUEST['forward']) && $_REQUEST['forward'] != '')
                    global $att_id_list;
                for($ii=0;$ii < $adb->num_rows($attach_result);$ii++)
                {
                    $attachmentid = $adb->query_result($attach_result,$ii,'attachmentsid');
                    if($attachmentid != '')
                    {
                        $attachquery = "select name from ld_attachments where attachmentsid=?";
                        $attachmentsname = $adb->query_result($adb->pquery($attachquery, array($attachmentid)),0,'name');
                        if($attachmentsname != '')
                            $fieldvalue[$attachmentid] = '[ '.$attachmentsname.' ]';
                        if(isset($_REQUEST['forward']) && $_REQUEST['forward'] != '')
                            $att_id_list .= $attachmentid.';';
                    }

                }
            }else
            {
                if($col_fields['record_id'] != '')
                {
                    $attachmentid=$adb->query_result($adb->pquery("select attachmentsid from ld_seattachmentsrel where crmid = ?", array($col_fields['record_id'])),0,'attachmentsid');
                    if($col_fields[$fieldname] == '' && $attachmentid != '')
                    {
                        $attachquery = "select name from ld_attachments where attachmentsid=?";
                        $value = $adb->query_result($adb->pquery($attachquery, array($attachmentid)),0,'name');
                    }
                }
                if($value!='')
                    $filename=' [ '.$value. ' ]';

                if($filename != '')
                    $fieldvalue[] = $filename;
                if($value != '')
                    $fieldvalue[] = $value;
            }
            $editview_label[]=($fieldlabel);
        }
        elseif($uitype == 28){
            if($col_fields['record_id'] != '')
            {
                $maintablename=$focus->table_name;
                $maintableindex=$focus->table_index;
                if($col_fields['filelocationtype']=='I'){
                    $sql="SELECT * FROM ld_attachments LEFT JOIN
                        ld_seattachmentsrel on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid
                        LEFT JOIN $maintablename on $maintablename.$maintableindex=ld_seattachmentsrel.crmid
                        where ld_notes.notesid=?;";
                    $result=$adb->pquery($sql,array($col_fields['record_id']));
                    $nums=$adb->num_rows($result);

                    if($nums>0){
                        for($i=0;$i<$nums;$i++){
                            $attachmentid=$adb->query_result($result,$i,'attachmentsid');
                            $value=$adb->query_result($result,$i,'name');

                            if($value!='' && $module_name != 'Documents')
                                $filename=' [ '.$value. ' ]';
                            elseif($value != '' && $module_name == 'Documents')
                                $filename= $value;


                            if($filename != '')
                                $fieldvalue[1][$i] = $filename;
                            if($value != '')
                                $fieldvalue[1][$i] = $value;

                        }
                    }
                }else{
                    $sql ='SELECT filename FROM '.$maintablename.' WHERE '.$maintableindex.'=?';
                    $result=$adb->pquery($sql,array($col_fields['record_id']));
                    $nums=$adb->num_rows($result);

                    $value='';
                    if($nums > 0){
                        $value=$adb->query_result($result,0,'filename');
                    }

                    $fieldvalue[1][0] = $value;
                }

            }
            $editview_label[]=($fieldlabel);

        }
        elseif($uitype == 69&&($weixin_user->environment_weixin||get_file_address($module_name,"ProductDetails")||get_file_address($module_name,$module_name."DetailFieldsHtml") ))
        {
            //editor:gyq_20190725 reason:清除$this->output_type  2019/7/25 10:03
            $root_dictionary = '';
            $editview_label[]=($fieldlabel);
            if( $col_fields['record_id'] != "")
            {

                $maintablename=$focus->table_name;
                $maintableindex=$focus->table_index;
                $query = "select ld_attachments.path, ld_attachments.attachmentsid, ld_attachments.name ,
                         ld_attachments.newfile_name,ld_attachments.size,ld_attachments.type,
								ld_crmentity.setype from $maintablename left join ld_seattachmentsrel on 
								ld_seattachmentsrel.crmid=$maintablename.$maintableindex inner join ld_attachments on
								ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid inner join ld_crmentity 
								on ld_crmentity.crmid=ld_attachments.attachmentsid 
								where ld_crmentity.setype=? and ld_seattachmentsrel.attachmentcolumnname=? and $maintableindex=?";

                //ls 2022-04-06 【1002543】页面设置，增加“图片”字段类型(移动端)
                $result_image = $adb->pquery($query, array($module_name.' image', $fieldobj->getColumnName(), $col_fields['record_id']));
                for($image_iter=0;$image_iter < $adb->num_rows($result_image);$image_iter++)
                {
                    $image_id_array[] = $adb->query_result($result_image,$image_iter,'attachmentsid');
                    $image_array[] = urlencode(decode_html($adb->query_result($result_image,$image_iter,'newfile_name')));
                    $image_orgname_array[] = decode_html($adb->query_result($result_image,$image_iter,'name'));
                    $image_newfile_array[] = decode_html($adb->query_result($result_image,$image_iter,'newfile_name'));
                    $image_path_array[] = $root_dictionary.$adb->query_result($result_image,$image_iter,'path');
                    //editor:gyq_97 reason:小程序附件上传  2019/1/15 14:39
                    $image_size_array[] = $adb->query_result($result_image,$image_iter,'size');
                    $image_type_array[] = $adb->query_result($result_image,$image_iter,'type');
                }
                if(is_array($image_array))

                    for($img_itr=0;$img_itr<count($image_array);$img_itr++)
                    {
                        $arr=explode('.',$image_array[$img_itr]);
                        $imagename= $image_id_array[$img_itr] . "_" . $image_array[$img_itr];
                        $imagepath=$image_path_array[$img_itr] ;
                        $newfile_name=$image_newfile_array[$img_itr];
                        $size=$image_size_array[$img_itr];
                        $imagetype=$image_type_array[$img_itr];

                        if(!file_exists($imagepath.$imagename))
                        {
                            $imagepath=$image_path_array[$img_itr] ;
                            $imagename= $image_id_array[$img_itr] . $image_array[$img_itr];

                            if(!file_exists($imagepath.$imagename))
                            {


                                $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
                                $encode=mb_detect_encoding($image_array[$img_itr], $arr);
                                if($encode=='UTF-8')
                                {
                                    $imagepath=$image_path_array[$img_itr] ;
                                    $imagename=$image_id_array[$img_itr].'_'.  $image_array[$img_itr];
                                }
                                else
                                {
                                    $imagepath=$image_path_array[$img_itr] ;
                                    $imagename=$image_id_array[$img_itr].'_'. iconv ( 'gb2312', 'utf-8', $image_array[$img_itr] );
                                }

                            }

                            if(!file_exists($imagepath.$imagename))
                            {
                                //24562: 报价单编辑状态下手机端上传的图片显示X
                                $imagename= $image_id_array[$img_itr].'_'.   $image_array[$img_itr];
                                $imagepath=$imagepath_array[$img_itr] ;

                                if(!file_exists($imagepath.$imagename))
                                {
                                    $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
                                    $encode=mb_detect_encoding($image_array[$img_itr], $arr);

                                    if($encode=='UTF-8')
                                    {
                                        $imagename=  $image_array[$img_itr];
                                        $imagepath=$imagepath_array[$img_itr] ;
                                    }

                                    else
                                    {
                                        $imagename= iconv ( 'gb2312', 'utf-8', $image_array[$img_itr] );
                                        $imagepath=$imagepath_array[$img_itr] ;
                                    }


                                }
                            }
                        }
                        $fieldvalue[] = array('name'=>$imagename,'newfile_name'=>$newfile_name, 'path'=>$image_path_array[$img_itr],"orgname"=>$image_orgname_array[$img_itr],'fileid_image'=>$image_id_array[$img_itr],'size'=>$size,'type'=>$imagetype);
                    }
            }
            else
                $fieldvalue[] = '';

        }
        elseif($uitype == 71 || $uitype == 72||$uitype==222) {
            if($uitype==222)
            {
                $module="CashBill";

            }
            //	$currencyField = new CurrencyField($value);
            // Some of the currency fields like Unit Price, Total, Sub-total etc of Inventory modules, do not need currency conversion
            if($col_fields['record_id'] != '' && $uitype == 72) {
                //产品参考价小数位根据系统参数单价小数位控制
                if(($fieldname == 'unit_price' || $fieldname == 'procostprice') && $module_name == 'Products'){
                    $sysdeploy_93 = getSys_deploy(93);	// 系统参数控制单价小数位
                    $price_decimal = $sysdeploy_93['deploy_value'];
                    $fieldvalue[] = sprintf("%.".$price_decimal."f", $value);
                }else{
                    //zkt 20221205 BUG0059474客户（客户名称  累计订货金额）单据编辑界面，“累计订货金额”显示8位小数，保存时提示无效的数字长度
                    $fieldvalue[]=$showvalue['value'];
                }
            } else {

                $fieldvalue[]=$showvalue['value'];
            }

            $editview_label[] = $fieldlabel;
        }
        elseif($uitype == 30)
        {
            $rem_days = 0;
            $rem_hrs = 0;
            $rem_min = 0;
            if($value!='')
                $SET_REM = "CHECKED";
            $rem_days = floor($col_fields[$fieldname]/(24*60));
            $rem_hrs = floor(($col_fields[$fieldname]-$rem_days*24*60)/60);
            $rem_min = ($col_fields[$fieldname]-$rem_days*24*60)%60;
            $editview_label[]=($fieldlabel);
            $day_options = getReminderSelectOption(0,31,'remdays',$rem_days);
            $hr_options = getReminderSelectOption(0,23,'remhrs',$rem_hrs);
            $min_options = getReminderSelectOption(1,59,'remmin',$rem_min);
            $fieldvalue[] = array(array(0,32,'remdays',getFixedLabel('Day'),$rem_days),array(0,24,'remhrs',getFixedlabel('HOUR'),$rem_hrs),array(1,60,'remmin',getFixedLabel('MINUTE').'&nbsp;&nbsp;'.getFixedLabel('BEFOREEVENT'),$rem_min));
            $fieldvalue[] = array($SET_REM,getFixedLabel('YES'),getFixedLabel('NO'));
            $SET_REM = '';
        }
        elseif($uitype == 115||$uitype == 116 || $uitype == 117)
        {
            $editview_label[]=$fieldlabel;
            $fieldvalue [] = $showvalue['optionvalue'];
            $fieldvalue [] = $is_admin;
            //wym XUQIU1000290 引用成员管理-状态 字段 需要rawvalue
            $fieldvalue [] = $showvalue['rawvalue'];
        }
        elseif($uitype ==98)
        {
            if(strtolower($mode)=='create'||$mode=='')
            {
                //18053: 新建帐套：控制面板>新增用户界面：角色权限默认值建议为：销售人员
                if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
                {
                    //edit:can 2021-03-01 44645: （https://61mis.com/kfbcrm [^]）（李发林）成员管理中复制成员后不会把“角色权限”也一起带过来
                }
                else
                {
                    //zkt 0045569: （https://61mis.com/kfbcrm [^] ）页面设置-》成员管理中，类似“角色权限”“状态”“部门”这类字段设施默认后不生效
                    //判断是否设置默认值，若设置默认值则角色权限默认显示默认值，否则默认显示销售人员
                    $defaultvalue=$fieldobj->getDefaultValue();
                    if (!empty($defaultvalue))
                    {
                        $query = 'select profilename,profileid from ld_profile where profileid=?';
                        $result =$adb->pquery($query,array($defaultvalue));
                    }
                    else
                    {
                        $query = 'select profilename,profileid from ld_profile where profilename=?';
                        $result = $adb->pquery($query,array('销售人员'));
                    }
                    if($adb->num_rows($result)>0)
                        $value=$adb->query_result($result,0,'profileid');
                }
            }
            $editview_label[]=($fieldlabel);
            $fieldvalue[]=$value;

            $query = 'select profilename,profileid from ld_profile order by profileseq asc';
            $result = $adb->pquery($query);
            $num_rows = $adb->num_rows($result);
            for($i = 0; $i<$num_rows; $i++){
                $profilename=$adb->query_result($result,$i,'profilename');
                $profileid=$adb->query_result($result,$i,'profileid');
                if($value == $profileid)
                {
                    $chk_val = "selected";
                    $found = true;
                }
                else
                {
                    $chk_val = '';
                }
                $options[$profileid] = array($profilename=>$chk_val );
            }
            /*if($is_admin == false){
                 $profile=new Profile();
                  $profilenames=$profile->getProfileinfo($value);
                $fieldvalue[]=$profilenames['profilename'];
            }*/
            /*else{*/
            $fieldvalue[] = $options;
            /*}*/
            //这里没有管理与非管理的差别
            $fieldvalue[]=true;
        }
        elseif($uitype == 105)
        {
            $editview_label[]=($fieldlabel);
            if( isset( $col_fields['record_id']) && $col_fields['record_id'] != '') {
                $query = "select ld_attachments.path, ld_attachments.name from ld_contactdetails left join ld_seattachmentsrel on ld_seattachmentsrel.crmid=ld_contactdetails.contactid inner join ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid where ld_contactdetails.imagename=ld_attachments.name and contactid=?";
                $result_image = $adb->pquery($query, array($col_fields['record_id']));
                for($image_iter=0;$image_iter < $adb->num_rows($result_image);$image_iter++)
                {
                    $image_array[] = $adb->query_result($result_image,$image_iter,'name');
                    $image_path_array[] = $adb->query_result($result_image,$image_iter,'path');
                }
            }
            if(is_array($image_array))
                for($img_itr=0;$img_itr<count($image_array);$img_itr++)
                {
                    $fieldvalue[] = array('name'=>$image_array[$img_itr],'path'=>$image_path_array[$img_itr]);
                }
            else
                $fieldvalue[] = '';
        }
        elseif($uitype == 26){
            $editview_label[]=($fieldlabel);
            $folderid=$col_fields['folderid'];
            $foldername_query = 'select foldername from ld_attachmentsfolder where folderid = ?';
            $res = $adb->pquery($foldername_query,array($folderid));
            $foldername = $adb->query_result($res,0,'foldername');
            if($foldername != '' && $folderid != ''){
                $fldr_name[$folderid]=$foldername;
            }
            $sql="select foldername,folderid from ld_attachmentsfolder order by foldername";
            $res=$adb->pquery($sql,array());
            for($i=0;$i<$adb->num_rows($res);$i++)
            {
                $fid=$adb->query_result($res,$i,"folderid");
                $fldr_name[$fid]=$adb->query_result($res,$i,"foldername");
            }
            $fieldvalue[] = $fldr_name;
        }
        elseif($uitype == 27){
            if($value == 'E'){
                $external_selected = "selected";
                $filename = $col_fields['filename'];
            }
            else{
                $internal_selected = "selected";
                $filename = $col_fields['filename'];
            }
            $editview_label[] = array(getFixedLabel('INTERNAL'),
                getFixedLabel('EXTERNAL')
            );
            $editview_label[] = array($internal_selected,
                $external_selected
            );
            $editview_label[] = array("I","E");
            $editview_label[] = ($fieldlabel);
            $fieldvalue[] = $value;
            $fieldvalue[] = $filename;
        }
        else if($bigtype=='translatefield')
        {
            $editview_label[] = $fieldlabel;
            $fieldvalue[] = $showvalue['value'];
            $fieldvalue[] = $showvalue['rawvalue'];
        }
        //ls 2021-10-22 48407: （http://47.97.110.63:85/crm [^]）客户问题（李辉），项目立项单据查看详情界面，相关信息关联创建“项目分配”时，引用“项目立项->负责人”（销售负责人）字段显示数字
        //zkt 20230918 关联创建-引用单选用户字段-显示错误。
        else if ($fieldobj->isRelatedModuleField() && ($fieldobj->getParentBigType() == 'users' || $fieldobj->getParentBigType() == 'selectoneuser') && $fieldobj->getSaveDataBase() == 'yes') {
            //引用字段保存数据库，uitype=1
            $value=$showvalue['value'];
            $editview_label[]=($fieldlabel);

            if (is_numeric($value)) {
                $user_result=$adb->pquery('select last_name,wx_userid from ld_users where id=?',array($value));
                $rows = $adb->num_rows($user_result);
                if($rows>0){
                    $last_name = $adb->query_result($user_result,0,'last_name');
                }
                $userobj=new Users();
                $userobj->last_name=$last_name;
                $userobj->wx_userid=$adb->query_result($user_result,0,'wx_userid');
                $value=getUserlastName($userobj);
            }

            $fieldvalue[] = $value;
        }
        else if ($fieldobj->isRelatedModuleField()){
            $editview_label[] = $fieldlabel;
            if($fieldobj->getSaveDataBase() == 'yes' && $fieldobj->getParentBigType() == 'multipicklist'){
                $fieldvalue[] = str_replace('|##|',',',$showvalue['value']??"");
                $fieldvalue[] = str_replace('|##|',',',$showvalue['rawvalue']??"");
            }else{
                $fieldvalue[] = $showvalue['value'];
                $fieldvalue[] = $showvalue['rawvalue']; 
            }
        }
        else
        {
            //Added condition to set the subject if click Reply All from web mail
            if($_REQUEST['module'] == 'Emails' && $_REQUEST['mg_subject'] != '')
            {
                $value = $_REQUEST['mg_subject'];
            }

            $value=$showvalue['value'];
            if($uitype==2&&$module_name=='Users'&&$fieldobj->getColumnName()=='last_name'){
                $userobj=new Users();
                $userobj->id=$col_fields['record_id'];
                $userobj->last_name=$value;
                $userobj->wx_userid=$col_fields['wx_userid'];
                $value=getUserlastName($userobj);
            }
            $editview_label[]=($fieldlabel);
            if($fieldname == 'fileversion'){
                if(empty($value)){
                    $value = '';
                }
                else{
                    $fieldvalue[] = $value;
                }
            }
            else{
                $fieldvalue[] = $value;
            }
            $fieldvalue[] = $showvalue['rawvalue'];
        }

        // Mike Crowe Mod --------------------------------------------------------force numerics right justified.
        if ( !preg_match("/id=/i",$custfld) )
            $custfld = preg_replace("/<input/iS","<input id='$fieldname' ",$custfld);

        if ( in_array($uitype,array(71,72,7,9,90)) )
        {
            $custfld = preg_replace("/<input/iS","<input align=right ",$custfld);
        }


        /**
         * edit:can
         * date:20130802
         * reason:自定义设置不允许重复
         *
         * */
        $final_arr[]=array($ui_type,array($fieldonly));
        $final_arr[]=$editview_label;
        $final_arr[]=$editview_fldname;
        $final_arr[]=$fieldvalue;

        $type_of_data  = explode('~',$typeofdata);
        if(!empty($curapproveformodulefield) && in_array($fieldname,$curapproveformodulefield)){
            $final_arr[]='M';
        }else{
            $final_arr[]=$type_of_data[1];
        }

        $final_arr[]=$columnname;

        $final_arr['profileeditfield']="yes";

        if($module_name=='Users'&&$col_fields['record_id']==$current_user->id&&isPermitted('Users','EditView')=='no')
        {
            //个人用户允许编辑部分用户信息字段
            $profileeditfield=$fieldobj->getProfileEditField();

            $final_arr['profileeditfield']=$profileeditfield;
        }

        //跟踪方式设置为指定期间，当有推进记录产生后没有控制期间字段不可编辑
        //edit:can 2020-11-16 043274: （https://61mis.com/WX/kh40630 [^]）客户管理-客户；对客户进行批量编辑设置，基本信息中客户状态字段没有文本框来填写内容。
        if($mode == 'mass_edit'||isset($_REQUEST['isDuplicate']))
        {
            //批量编辑，复制
        }
        else  if((!empty($_REQUEST['record']) && $_REQUEST['record'] > 0) ){
            if($this->isincludefile=='yes')
                crm_load_class_file('cls_module_advance','modules/Settings');
            //edit:can 20220701 客户问题（贵州君诺），合同编辑界面打不开，显示空白，时间长了提示“操作系统和环境故障”
            $cls_module_advanceobj = cls_module_advance::getInstance($module_name);
            $advance_fieldnames = $cls_module_advanceobj->is_AdvanceRecord($_REQUEST['record']);

            if(!empty($advance_fieldnames) && in_array($fieldname,$advance_fieldnames) && !empty($value)){
                $allowedit = 'no';
            }

        }

        //海格-报价单-复制、编辑-报价单类型不可编辑

        if((!empty($_REQUEST['record']) && $_REQUEST['record'] > 0)&&
            $module_name=='Quotes'&& $fieldname=='quotetype')
        {

            $VersionInfo = getVersionInfo();
            if( $VersionInfo['account'] == 'haige')
                $allowedit = 'no';
        }
        //海格-报价单-复制、编辑-已有出货记录则地址信息不可编辑
        if((!empty($_REQUEST['record']) && $_REQUEST['record'] > 0)&&
            $VersionInfo['account'] == 'haige'&&$module_name=='Quotes'&&
            in_array($columnname,array('cf_3023','cf_3024','cf_3025','cf_3026','cf_3027')))
        {
            //获取出货记录
            crm_load_function_file('CheckProductDetail','modules/Quotes','Haigequotefunction');
            $haigedeal_info = CheckProductDetail($_REQUEST['record']);
            if(!empty($haigedeal_info))
            {
                $haigequoteid = $_REQUEST['record'];
                //前一版本的地址信息不可修改，复制时$_REQUEST['record']即为前一版本quoteid不需要查询前一版本quoteid
                if(!isset($_REQUEST['isDuplicate'])){
                    crm_load_function_file('getprequoteid','modules/Quotes','Haigequotefunction');
                    $haigequoteid = getprequoteid($haigequoteid);
                }
                crm_load_function_file('getShippingAddressByid','modules/Quotes','Haigequotefunction');
                $haigeaddressarr = getShippingAddressByid($haigequoteid);
                if(isset($haigeaddressarr[$columnname]))
                {
                    $allowedit = 'no';
                }
            }
        }


        $final_arr['take_photo_only'] = $fieldobj->get_take_photo_only();
        $final_arr['allowedit'] = $allowedit;
        $final_arr['allowedit_presence'] = $fieldobj->get_allowedit_presence();
        $final_arr['allowcreate'] = $fieldobj->get_allowcreate();
        $final_arr['allowcreate_presence'] = $fieldobj->get_allowcreate_presence();
        $final_arr['bigtype'] = $fieldobj->getBigType();
        $final_arr['relatedmodulefield'] = $fieldobj->getRelatedModuleField();
        $final_arr['label_style'] = $fieldobj->getLabelStyle(); //wsh 标签颜色
        $final_arr['fieldvaluecolor'] = $fieldobj->getFieldValueColor();
        $final_arr['fieldplaceholder'] = $fieldobj->getFieldPlaceholder();
        $final_arr['value_name'] = $showvalue['value'];//布局规则使用
        //zkt 20220523 52029（https://81mis.com/kfbtest/index.php）合同订单，SSO305，已审批通过，编辑单据时，不可编辑字段显示界面异常；“多选框”“图片”字段
        $final_arr['value_name_show'] = $showvalue['value'];
        if($uitype == 33 || ($final_arr['relatedmodulefield'] == 'yes' && $fieldobj->getSaveDataBase() == 'yes' && $fieldobj->getParentBigType() == 'multipicklist')){
            $final_arr['value_name_show'] = str_replace('|##|',',',$final_arr['value_name_show']??"");
        }

        if($uitype ==15){
            //BUG0065318 徐心玥 2023-4-26 进入新建或编辑界面，下拉框中选中字段将直接显示默认或自行设置的颜色而非黑色
            $selLabel = $col_fields[$fieldname];
            if($bigtype === 'picklist_key') {
                $selIndex = $showvalue['selectedIndex'];
                $selOption = $showvalue['optionvalue'][$selIndex];
                $selLabel = $final_arr['label'] = $selOption['label'];
                $final_arr['value'] = $selOption['value'];
            }
            $final_arr[] = $selLabel;
            $cur_fieldvalue = $showvalue['value'];
            for($i = 0;$i < count((array)$final_arr[3][0]); $i++){
                if($final_arr[3][0][$i][1] == $cur_fieldvalue){
                    $fieldcolor = $final_arr[3][0][$i][3];
                }
            }
            $final_arr['fieldvaluecolor'] = $fieldcolor;
        }
        $final_arr['businessquery'] = $fieldobj->getbusinessquery();
        $final_arr['isenablebusiness'] = $fieldobj->getenablebusiness();
        $final_arr['isenablebusinessfuzzyquery'] = $fieldobj->getenablebusinessfuzzyquery();

        $final_arr['helptips'] = $fieldobj->getHelptips();

        return $final_arr;
    }

    function getTimeHtml($time,$name='df'){
        global $mod_strings;
        $outHtml='';
        $outHtml.='<select class=small name="'.$name.'_hr" id="'.$name.'_hr">';
        for($i=0;$i<23;$i++){
            $i=twoDigit($i);
            $hrsel='';
            if($i==$time[0]){
                $hrsel='selected';
            }
            $outHtml.='<option value="'.$i.'" '.$hrsel.'>'.$i.'</option>';
        }
        $outHtml.='</select>'.$mod_strings['LBL_HR'].'&nbsp;';

        $outHtml.='<select class=small name="'.$name.'_min" id="'.$name.'_min">';
        $min=$time[1];
        $min = $min - ($min%5);
        for($i=0;$i<60;$i+=5){
            $hrsel='';
            $i=twoDigit($i);
            if($i==$min){
                $hrsel='selected';
            }
            $outHtml.='<option value="'.$i.'" '.$hrsel.'>'.$i.'</option>';
        }
        $outHtml.='</select>'.$mod_strings['LBL_MIN'].'<input type="hidden" name="'.$name.'_fmt" id="'.$name.'_fmt">';

        return $outHtml;
    }

    function getUserSelect($fieldid,$user_arr,$module_name,$current_user,$tabid=''){
        global $adb;
        if(empty($fieldid)){
            $fieldid = '';
        }
        $userobj=new Users();
        if(!empty($fieldid))
            $sql="select fieldid,advance_demand,advance_demand_groups from ld_field where fieldid= $fieldid";
        else if($tabid)
            $sql="select fieldid,advance_demand,advance_demand_groups from ld_field where tabid= $tabid and fieldname='assigned_user_id'";

        $result = $adb->pquery($sql,array());
        $rows = $adb->num_rows($result);

        //wyt 221021 XUQIU1000764 负责人、单选用户、多选用户、团队成员字段，“设置可选择的成员范围”增加“其他条件”参数控制
        if($rows>0){
            $advance_demand = $adb->query_result($result,0,'advance_demand')??"";
            $advance_demand_groups = $adb->query_result($result,0,'advance_demand_groups')??"";
            if(strpos($advance_demand,'####')&&strpos($advance_demand_groups,"####")) {
                $tmp_demand = explode("####", $advance_demand);
                $tmp_demand_groups = explode("####", $advance_demand_groups);
                $memberrange_select = $tmp_demand[0];
                $memberrange_select_type = $tmp_demand_groups[0];
            }else{
                $memberrange_select=$advance_demand;
                $memberrange_select_type=$advance_demand_groups;
            }
        }
        if(empty($memberrange_select_type))
        {
            $memberrange_select_type='All';
        }
        if($memberrange_select_type == 'All'){
            $users_result=$user_arr;
        }
        else if($memberrange_select_type == 'Module'){
            //wyt 220929 BUG0057272 如图，当”设置可选择的成员数据范围“选择”根据模块数据范围控制“时，若登录的用户为管理员，应该可以选择全部，不受这个选项控制
            if(is_admin($current_user) == true){
                $users_result=$user_arr;
            }else{
                $scopeobj = new ScopOfAuthority($adb,$module_name);
                $tmp_default_value = $scopeobj->getCurUserScopeIds();
                $sql_0="select id,last_name,wx_userid  from ld_users where find_in_set(id,'$tmp_default_value') ";
                $result_0=$adb->pquery($sql_0,array());
                $num_rows_0=$adb->num_rows($result_0);
                for($i=0;$i<$num_rows_0;$i++){
                    $userid=$adb->query_result($result_0,$i,'id');
                    $userobj->last_name= $adb->query_result($result_0, $i, "last_name");
                    $userobj->wx_userid= $adb->query_result($result_0, $i, "wx_userid");
                    $users_result[$userid]=getUserlastName($userobj);
                }
            }
        }
        else if($memberrange_select_type == 'Person'){
            $entity_field_info = getEntityFieldNames('Users');
            $fieldsName = $entity_field_info['fieldname'];
            $sql_userbyperson="select id,last_name,wx_userid from ld_users where find_in_set(id,'$memberrange_select') order by CONVERT(".$fieldsName." USING gbk)  ASC";
            $result_userbyperson = $adb->pquery($sql_userbyperson);
            $num_rows_userbyperson = $adb->num_rows($result_userbyperson);
            if($num_rows_userbyperson){
                for($i=0;$i<$num_rows_userbyperson;$i++){
                    $userid=$adb->query_result($result_userbyperson,$i,'id');
                    $userobj->last_name= $adb->query_result($result_userbyperson, $i, "last_name");
                    $userobj->wx_userid= $adb->query_result($result_userbyperson, $i, "wx_userid");
                    $users_result[$userid]=getUserlastName($userobj);
                }
            }
        }
        else if($memberrange_select_type == 'Departments'){
            $entity_field_info = getEntityFieldNames('Users');
            $fieldsName = $entity_field_info['fieldname'];
            $sql_userbygroup="SELECT u.id,u.last_name,u.wx_userid,u.groupid FROM ld_users u LEFT JOIN ld_users2group g ON u.id = g.userid WHERE find_in_set(g.groupid,'$memberrange_select') order by CONVERT(".$fieldsName." USING gbk)  ASC";
            $result_userbygroup1=$adb->pquery($sql_userbygroup);

            $num_rows_userbygroup=$adb->num_rows($result_userbygroup1);
            if($num_rows_userbygroup){
                for($i=0;$i<$num_rows_userbygroup;$i++){
                    $userid=$adb->query_result($result_userbygroup1,$i,'id');
                    $userobj->last_name= $adb->query_result($result_userbygroup1, $i, "last_name");
                    $userobj->wx_userid= $adb->query_result($result_userbygroup1, $i, "wx_userid");
                    $users_result[$userid]=getUserlastName($userobj);
                }
            }
        }
        else if($memberrange_select_type == 'Roles'){
            $entity_field_info = getEntityFieldNames('Users');
            $fieldsName = $entity_field_info['fieldname'];
            $sql_userbyroles="select u.id,u.last_name,u.wx_userid,p.profileid from ld_users u left join ld_profile p on u.profileid=p.profileid where find_in_set(p.profileid,'$memberrange_select') order by CONVERT(".$fieldsName." USING gbk)  ASC";
            $result_userbyroles=$adb->pquery($sql_userbyroles);

            $num_rows_userbyroles=$adb->num_rows($result_userbyroles);
            if($num_rows_userbyroles){
                for($i=0;$i<$num_rows_userbyroles;$i++){
                    $userid=$adb->query_result($result_userbyroles,$i,'id');
                    $userobj->last_name= $adb->query_result($result_userbyroles, $i, "last_name");
                    $userobj->wx_userid= $adb->query_result($result_userbyroles, $i, "wx_userid");
                    $users_result[$userid]=getUserlastName($userobj);
                }
            }
        }
        else if($memberrange_select_type == 'Position'){
            $entity_field_info = getEntityFieldNames('Users');
            $fieldsName = $entity_field_info['fieldname'];
            $sql_userbyposition="SELECT u.id,u.last_name,u.wx_userid,pv.id as pvid FROM ld_users u inner JOIN ld_picklist_values pv ON u.userlevel = pv.listvalue WHERE find_in_set(pv.id,'$memberrange_select') order by CONVERT(".$fieldsName." USING gbk)  ASC";
            $result_userbyposition=$adb->pquery($sql_userbyposition);

            $num_rows_userbyposition=$adb->num_rows($result_userbyposition);
            if($num_rows_userbyposition){
                for($i=0;$i<$num_rows_userbyposition;$i++){
                    $userid=$adb->query_result($result_userbyposition,$i,'id');
                    $userobj->last_name= $adb->query_result($result_userbyposition, $i, "last_name");
                    $userobj->wx_userid= $adb->query_result($result_userbyposition, $i, "wx_userid");
                    $users_result[$userid]=getUserlastName($userobj);
                }
            }
        }
        return $users_result;
    }

    //wyt 221021 XUQIU1000764 负责人、单选用户、多选用户、团队成员字段，“设置可选择的成员范围”增加“其他条件”参数控制
    function getUserSelect_othercondition($fieldid='',$tabid=''){
        global $current_user,$adb;
        $tmp_module='Users';
        crm_load_class_file("SelectRelatedPopu",'include/SelectRelatedPopu');
        $SelectRelatedPopu = new SelectRelatedPopu($tmp_module,$adb);

        $sql=$SelectRelatedPopu->memberrange_sql($fieldid,$tabid);//获取其它条件的sql

//        $sql=$tmp_sql['page_list_query'];
        $tmp_result = $adb->pquery($sql);
        $num_rows = $adb->num_rows($tmp_result);
        for($i=0;$i<$num_rows;$i++){
            $result[$i]=$adb->query_result($tmp_result,$i,0);
        }
        $resultid=is_array($result)?implode(',',$result):[];
        if(!empty($resultid)){
            //edit:can 20221125 0059164
            $sql_userbyperson="select id,last_name,wx_userid from ld_users where find_in_set(id,'$resultid') ";
            $result_userbyperson = $adb->pquery($sql_userbyperson);
            $num_rows_userbyperson = $adb->num_rows($result_userbyperson);
            if($num_rows_userbyperson){
                for($i=0;$i<$num_rows_userbyperson;$i++){
                    $userid=$adb->query_result($result_userbyperson,$i,'id');
                    $userobj=new Users();
                    $userobj->wx_userid=$adb->query_result($result_userbyperson,$i,'wx_userid');
                    $userobj->last_name=$adb->query_result($result_userbyperson,$i,'last_name');
                    $userobj->id=$adb->query_result($result_userbyperson,$i,'id');
                    $users_result[$userid]=getUserlastName($userobj);
                }
            }
        }
        return array('users_result'=>$users_result,'userid'=>$resultid);
    }
}


?>