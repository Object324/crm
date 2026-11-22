<?php

define('SHOW_LISTVIEW', 'show_listview');
define('SHOW_POPUP', 'show_popup');
define('SHOW_DETAILVIEW', 'show_detailview');
define('SHOW_EDITVIEW', 'show_editview');
define('SHOW_PAGEFIELDRULE', 'show_pagefieldrule');
include(globalStatic::$root_directory . 'include/fields/fieldValueUitype.php');

class ShowFieldValue
{
    var $fieldobj;
    var $show_type;//显示的样式
    var $export_type;//导出的方式,excel,csv;
    var $module;
    public $recordId;
    var $ownerNameList;
    var $result;//数据库查询结果集
    var $detailidvalue;//明细id:合同订单:lineitemid(产品明细ID),客户:contactid(联系人ID),供应商：vendorcontactsid
    var $col_fields;
    var $line_index;//查询结果行号
    var $LengthDecimal;//数量小数位数
    private $showfieldvaluetype;//显示界面的类型
    public $sourcefromvalue;

    function __construct($fieldobj, $module, $show_type)
    {

        $this->fieldobj = $fieldobj;
        $this->module = $module;
        $this->show_type = $show_type;
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value']))
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        else
            $lengthdecimaldigits = 2;

        $this->LengthDecimal = $lengthdecimaldigits;
        $this->showfieldvaluetype = PAGELIST;

    }

    /**
     * //显示界面的类型,列表，快速创建，导出，快速查找等待
     * */
    public function setShowFieldValueType($showfieldvaluetype)
    {
        $this->showfieldvaluetype = $showfieldvaluetype;
    }

    public function getShowFieldValueType()
    {
        return $this->showfieldvaluetype;

    }

    public function setRecorId($recordId)
    {

        $this->recordId = $recordId;
    }


    public function setownerNameList($ownerNameList)
    {
        $this->ownerNameList = $ownerNameList;
    }

    public function setadbResult($result)
    {
        $this->result = $result;
    }

    public function setLine_index($line_index)
    {
        $this->line_index = $line_index;
    }

    function getFieldValueByField($field, $rawValue, $value)
    {
        global $adb, $theme,$weixin_user,$current_user;
        $module = $this->module;
        if (empty($field)) return '';
        $uitype = $field->getUIType();
        $fieldName = $field->getFieldName();
        $columnname=$field->getColumnName();
        $bigtype=$field->getBigType();
        //获取uitype的类型（reference,picklist,multipicklist,number，text等）
        $fldtypearr = Field::getFieldUitypeType($adb);

        $moduleFields = $this->fieldobj->getModuleFields();
        $typeofdata = $field->getTypeOfData();
        $format = $field->getValueFormat();
        if(!is_null($typeofdata))
            $typedata = explode('~', $typeofdata);
        //zkt 20221109 XUQIU1000804 单据头和单据分录“金额货币”类型的字段允许自定义小数位数
        $typeofdata_decimal=$field->gettypeofdata_decmail();//获取typeofdata中的小数位数
        //单据头和单据分录“金额货币”类型字段根据typeofdata取值，其他的仍默认为2
        if(!$field->isAmountorCurrencyField()){
            $typeofdata_decimal = 2;
        }
        $tmpshowtype = $this->show_type;
        $savedatabase=$field->getSaveDataBase();
        if ($this->show_type == PAGEEXPORTLIST) {
            $tmpshowtype = SHOW_POPUP;
        }
        $focus=CRMEntity::getInstance($this->module);

        if (($this->module == 'Accounts'||$this->module=='Leads') && strtolower($field->getColumnName()) == 'publicaccount') {

            /*
            * editor : gyq_03
            * reason : 客户详情页是否公海类型精确显示
            * date   : 2016 1 27
            * */
            switch ($value) {
                case 0:
                    $value = getFixedLabel('COMMONACCOUNT');
                    //zxm BUG0063981 20230529 销售线索，单据公海状态“普通客户”，应该改为“普通销售线索”
                    if($this->module=='Leads'){
                        $value = getFixedLabel('COMMONLEADS');
                    }
                    break;
                case 1:
                    $value = getFixedLabel('LBL_NOALLOCATE');
                    break;
                default :
                    $value = getFixedLabel('LBL_PUBLICALLOCATE');
            }


        }
        else if ($uitype == 56) {


            if ($value == 1||$value=='是') {
                $value = getFixedLabel('YES');
            } else {
                $value = getFixedLabel("NO");
            }

        }
        else if($bigtype=='multireference')
        {

            //多选
            if(!empty($value) && trim($value,',')!='')
            {
                $multreference_arr=  Field::getMutlReferenceInfo();

                $typemodulename=$multreference_arr[$uitype]['type'];
                $typefocus=CRMEntity::getInstance($typemodulename);

                $listlink_field=$typefocus->list_link_field;
                $sourcetablename=$typefocus->fieldobj->getFieldInfoBykeyValue("fieldname",$listlink_field,"tablename");
                $sourcetableindex=$typefocus->table_index;
                //wym 获取字段信息 判断是否添加超链接
                $ShowHyperlinks=$field->get_ShowHyperlinks()?$field->get_ShowHyperlinks():'yes';
                $value_arr=explode(",",trim($value,','));
                foreach($value_arr as $value) {
                    $tmprawvalue.= getModuleHref($typemodulename, $value);
                    if (($tmpshowtype == SHOW_LISTVIEW || $tmpshowtype == SHOW_DETAILVIEW)&&$ShowHyperlinks=='yes') {
                        $tmpvalue .= "<a href='".CreateDetailViewHref($typemodulename,$value)."' onclick='ListReferenceLinkClick(ld(this),event)' referencemodule='" . $typemodulename . "' referencerecord='" . $value . "' >" . getModuleHref($typemodulename, $value) . "</a>,";
                        $tmpvalue_weixin .= getModuleHref($typemodulename, $value) . ',';
                    } else
                        $tmpvalue .= getModuleHref($typemodulename, $value) . ',';
                }
                //wym 移动端传值与pc端不一样
                if($weixin_user->environment_weixin && ($tmpshowtype == SHOW_LISTVIEW || $tmpshowtype == SHOW_DETAILVIEW ) && $ShowHyperlinks=='yes'){
                    $tmpvalue = trim($tmpvalue_weixin, ',');
                }else{
                    $tmpvalue=trim($tmpvalue, ',');
                }
                return array('rawvalue' => $rawValue, 'value' =>$tmpvalue , 'hrefvalue' => $tmprawvalue, 'entityname' => $typemodulename);
            }


        }
        else if($bigtype=='translatefield'){
            //todo:公海客户类型
            static $translate_dbvalues;


            if($value!='')
            {
                $translate_dbvalues= getTranslateDbValueNew($this->module,$columnname);
                //zkt 0047524: （81mis.com/kfbcrm）客户管理-客户，客户列表数据分类中含有“是否来源于销售线索”字段，字段内容是“from_leads”；该字段能否优化显示为中文或者不显示在数据分类中？
                //ld_translatefield中不存在$value对应内容时，value不做翻译变化
                if(!empty($translate_dbvalues[$value]) && !empty($translate_dbvalues[$value]['labelbol'])){
                    $value=getFixedLabel($translate_dbvalues[$value]['labelbol']);
                }

            }

        }
        else if ($uitype == 27) {
            if ($value == 'I') {
                $value = getFixedLabel('Attachment');
            } elseif ($value == 'E') {
                $value = getFixedLabel('LINK');
            } else {
                $value = ' --';
            }
        }
        else if ($field->getUIType() == 242) {
            if ($tmpshowtype == SHOW_POPUP || $tmpshowtype == SHOW_LISTVIEW) {
                $sql = 'select GROUP_CONCAT(ld_users.last_name) as userarr from ld_receipts left join ld_users on ld_receipts.userid=ld_users.id
                      where ld_receipts.id=?';
                if (empty($this->result)) {
                    $id = $this->recordId;
                } else {
                    $id = $adb->query_result($this->result, $this->line_index, 'publicannouncementid');
                }


                $receipt_result = $adb->pquery($sql, array($id));
                if ($adb->num_rows($receipt_result) > 0) {
                    $value = $adb->query_result($receipt_result, 0, 0);
                }
            }

        }
        else if ($field->getUIType() == 79)//服务单选择常见问题
        {

            $sql = 'select faq_no,id   from ld_faq where deleted=0 and   id in( ' . $value . ')';
            if ($value != "")
                $faq_result = $adb->pquery($sql, array());
            if ($faq_result && $adb->num_rows($faq_result) > 0) {
                for ($faq_i = 0; $faq_i < $adb->num_rows($faq_result); $faq_i++) {
                    $faqids[] = $adb->query_result($faq_result, $faq_i, 'id');
                    $faq_nos[] = $adb->query_result($faq_result, $faq_i, 'faq_no');
                }
                $value = implode(',', $faq_nos);
                $rawValue = implode(',', $faqids);
            } else {
                $value = "";
                $rawValue = '';
            }

        }
        else if ($field->getUIType() == 156) {//是否是管理员
            $rawValue = $value;
            $newuser=new Users();
            $newuser->is_admin=$rawValue;
            //wym BUG0076366 引用成员管理-是否管理员字段 value可能为空
            if($rawValue){
                if (!is_admin($newuser)) {
                    $value = getFixedLabel('NO');
                } else {
                    $value = getFixedLabel('YES');
                }
            }
        }
        else if ($field->getUIType() == 152) {//显示部门
            if (!empty($value)) {
                $groupname = array();
                $groupid = array();
                $query = 'select groupname,groupid from ld_groups where groupid in (' . $value . ') order by ld_groups.depth,ld_groups.groupseq asc';
                $result = $adb->pquery($query, array());
                if ($adb->num_rows($result) >= 1) {
                    for ($i = 0; $i < $adb->num_rows($result); $i++) {
                        $groupname[$i] = $adb->query_result($result, $i, 'groupname');
                        $groupid[$i] = $adb->query_result($result, $i, 'groupid');
                    }
                }
                $value = implode(',', $groupname);
                $rawValue = implode(',', $groupid);
            }
        }
        else if($field->getUIType()=='stepname'){
            ///edit:can 20200714 审批中心列表显示审批步骤
            static $approve_step_info;
            if(is_array($approve_step_info)&&array_key_exists($rawValue,$approve_step_info))
            {
                $value=$approve_step_info[$rawValue];
            }
            else
            {
                $approve_step_info=array();
                if($rawValue=='-1'){
                    $value=getFixedLabel('SUBMITAPPROVAL');
                }
                else if($rawValue=='-2'){
                    $value=getFixedLabel('RETRACEMENT');
                }
                else
                {
                    $sql='select `name` from ld_approvestep where id=? ';
                    $tmp_result=$adb->pquery($sql,array($rawValue));
                    if($adb->num_rows($tmp_result)>0){
                        $value=$adb->query_result($tmp_result,0,0);
                    }
                    else{
                        $value='';
                    }
                }

                $approve_step_info[$rawValue]=$value;
            }
        }
        else if ($field->getUIType() == 98) {
            $rawValue = $value;
            $profile = new Profile();
            $profileinfo = $profile->getProfileinfo($value);
            $value = $profileinfo['profilename'];

        }
        else if ($field->getUIType() == 123) {
            if (empty($this->recordId) || $_REQUEST['isDuplicate'] == true) {
                global $current_user;
                crm_load_class_file('cls_RelatedField_Data', 'include/RelatedField');
                $cls_RelatedField_Data = new cls_RelatedField_Data($this->module, $current_user->id, 'smownerid');
                $RelatedField_Data = $cls_RelatedField_Data->getData();
                if (!empty($RelatedField_Data)) {
                    $value = $RelatedField_Data[0]['value']['value'];
                    $rawValue = $value;
                }
            }
        }
        elseif ($field->getUIType() == 301) {//标签
            crm_load_class_file('cls_moduledata_tag','include/utils');
            $cls_moduledata_tag = new cls_moduledata_tag($this->module,$this->recordId);
            $moduledata_tag = $cls_moduledata_tag->getModuledataTagForUser();
            if(!empty($moduledata_tag)){
                foreach($moduledata_tag as $tag_info){
                    $tag[] = $tag_info['tag'];
                }
                $value = $rawValue = implode(',',$tag);
            }
            else{
                //zkt 20240424 BUG20240418-04  服务收费管理列表界面，单据详情没有3000009这个“标签”，但列表展示了3000009
                $value = $rawValue = '';
            }

        }
        elseif ($field->getUIType() == 302) {//多公海 - 公海池
            if(!empty($value)){
                $languageType= getLanguageType($current_user);
                if($this->module=='Leads')
                {
                    $query = 'select zh_name,en_name from ld_leads_public_pool where id = ? limit 1';
                }
                else
                    $query = 'select zh_name,en_name from ld_account_public_pool where id = ? limit 1';
                $result = $adb->pquery($query, array($value));
                if($languageType == 'zh'){
                    $value = $adb->query_result($result,0,'zh_name');
                }else{
                    $value = $adb->query_result($result,0,'en_name');
                }
            }else{
                $value = '';
            }

        }
        else if ($field->getUIType() == 154||$field->getUIType() == 603) {//显示用户
            $username = $userid = [];
            $verion_arr=getVersionInfo();
            if(($field->getColumnName()=='team_memberid'||$field->getColumnName()=='team_memberid1')&&$verion_arr['account']=='shanshui')
            {
                if(!empty($value))
                {
                    $value_arr=explode(",",$value);
                    $userobj=new Users();

                    foreach($value_arr as $tmpindex=> $tmpuserid){
                        $sql="select id,last_name,wx_userid from ld_users where id=? ";
                        $userresult=$adb->pquery($sql,array($tmpuserid));
                        if($adb->num_rows($userresult)>0)
                        {
                            $userobj->wx_userid= $adb->query_result($userresult, 0, 'wx_userid');
                            $userobj->last_name= $adb->query_result($userresult, 0, 'last_name');

                            $username[$tmpindex] = getUserlastName($userobj);
                            $userid[$tmpindex] = $adb->query_result($userresult, 0, 'id');
                        }
                    }

                    unset($userobj);
                    $value = implode('、', $username);
                    $rawValue = implode(',', $userid);
                }
            }
            else if (!empty($value)) {
                $username = $userid = [];
                $query = 'select id,last_name,wx_userid from ld_users where id in (' . $value . ')';
                $result = $adb->pquery($query, array());
                $userobj=new Users();
                if ($adb->num_rows($result) >= 1) {
                    for ($i = 0; $i < $adb->num_rows($result); $i++) {
                        $userobj->wx_userid= $adb->query_result($result, $i, 'wx_userid');
                        $userobj->last_name= $adb->query_result($result, $i, 'last_name');
                        if($this->show_type==PAGEEXPORTLIST)
                        {
                            if(isKehu001ServerPc()=='yes'){
                                $userid_arr=explode(",",$value);
                                $userlastName_arr=[];
                                foreach($userid_arr as $tmpuserid)
                                    $userlastName_arr[]=getUserRealName($tmpuserid);//客户001导出用户的姓名和部门名称
                                $username[$i]=implode("、",$userlastName_arr);
                            }
                            else{
                                $username[$i] = getUserlastName($userobj);
                            }
                        }
                        else
                            $username[$i] = getUserlastName($userobj);

                        $userid[$i] = $adb->query_result($result, $i, 'id');
                    }
                }
                unset($userobj);
                $value = implode(',', $username);
                $rawValue = implode(',', $userid);
            }
        }
        else if ($field->getUIType() == 125) {//均摊
            crm_load_class_file('DetailView_125', 'include/fields/DetailView');
            $col_fields['record_id'] = $this->recordId;
            $col_fields['module'] = $this->module;
            $col_fields['show_type'] = $tmpshowtype;
            $label_fld = DetailView_125::get_uitype_125($focus, $field, $col_fields);
            $value = $label_fld;
            $rawValue = $label_fld;
        }
        else if ($field->getUIType() == 180) {//用户管理  - 对应部门
            if (!empty($this->recordId)) {
                $groupname = array();
                $groupid = array();
                if (trim((string)$rawValue, ',') != '' && trim((string)$rawValue) != '') {
                    //37116: （1.6）成员管理列表界面>勾选任意用户>修改该用户的所在部门：修改后没有生成修改日志。（需要补丁）
                    $query = 'select distinct ld_users2group.groupid,ld_groups.groupname from ld_users2group
							inner join ld_groups on ld_groups.groupid = ld_users2group.groupid 
                            where ld_users2group.groupid in(' . $rawValue . ') order by ld_groups.depth,ld_groups.groupseq asc';
                    $result = $adb->pquery($query, array());
                } else {
                    $query = 'select ld_users2group.groupid,ld_groups.groupname from ld_users2group
							inner join ld_groups on ld_groups.groupid = ld_users2group.groupid 
                            where ld_users2group.userid=? ';
                    $result = $adb->pquery($query, array($this->recordId));
                }
                $num_rows = $adb->num_rows($result);
                if ($num_rows >= 1) {
                    for ($i = 0; $i < $num_rows; $i++) {
                        $groupobj=new Users();
                        $groupobj->groupid=$adb->query_result($result, $i, 'groupid');
                        $groupobj->groupname=$adb->query_result($result, $i, 'groupname');
                        if($this->show_type==PAGEEXPORTLIST)
                        {
                            $groupname[$i]=getWxRemindGroupName($groupobj);//客户001导出用户的姓名和部门名称
                        }
                        else{
                            $groupname[$i] =getWx_GroupName($groupobj);
                        }
                        $groupid[$i] = $adb->query_result($result, $i, 'groupid');
                    }
                }
                $value = implode(',', $groupname);
                $rawValue = implode(',', $groupid);
            } else if (!empty($rawValue)) {
                //新增用户的判断
                $sql = 'select groupname from ld_groups where groupid=? ';
                $groupresult = $adb->pquery($sql, array($rawValue));
                if ($adb->num_rows($groupresult) > 0) {
                    $value = $adb->query_result($groupresult, 0, 0);
                }
            }
        }
        elseif(Field::user_multi_fields($field->getUIType()))//多选用户，当前审批人
        {
            static $field_user_name;


            if (is_array($field_user_name) && array_key_exists($value, $field_user_name)) {

                $value = $field_user_name[$value];

            } else {
                if (is_array($this->ownerNameList) && in_array($fieldName, $this->ownerNameList)) {
                    $value = $this->ownerNameList[$fieldName][$value];
                }  else {

                    $tmp_arruserid=array_filter(!empty($value)?explode(",",$value):[]);

                    $tmpname='';
                    foreach($tmp_arruserid as $tmpuserid)
                    {
                        if(is_array($field_user_name)&&array_key_exists($tmpuserid,$field_user_name)){
                            $value=$field_user_name[$tmpuserid];
                        }
                        else
                        {
                            $userobj=new Users();
                            $sql='select wx_userid,last_name from ld_users where id  = ?';
                            $userresult=$adb->pquery($sql,array($tmpuserid));
                            $userobj->wx_userid=$adb->query_result($userresult,0,0);

                            $userobj->last_name=$adb->query_result($userresult,0,1);
                            if($this->show_type==PAGEEXPORTLIST)
                            {
                                if(isKehu001ServerPc()=='yes'){
                                    $userid_arr=explode(",",$tmpuserid);
                                    $userlastName_arr=[];
                                    foreach($userid_arr as $tmpuserid)
                                        $userlastName_arr[]=getUserRealName($tmpuserid);//客户001导出用户的姓名和部门名称
                                    $value=implode("、",$userlastName_arr);
                                }
                                else{
                                    $value = getUserlastName($userobj);
                                }
                            }
                            else
                                $value = getUserlastName($userobj);
                        }
                        $tmpname.=','.$value;
                        $field_user_name[$tmpuserid] = $value;
                    }
                    $value=trim($tmpname,',');

                }


            }
        }
        elseif (Field::user_fields($field->getUIType())&&$tmpshowtype!=SHOW_POPUP) { //创建人或负责人



            if (is_array($field_user_name) && array_key_exists($value, $field_user_name)) {

                $value = $field_user_name[$value];

            } else {
                if (is_array($this->ownerNameList) && in_array($fieldName, $this->ownerNameList)) {
                    $value = $this->ownerNameList[$fieldName][$value];
                } elseif (($value == '' || $value == 0) && $this->module == 'Reminds' && $field->getUIType() == 52) {
                    $value = 'System';
                } else {



                    //$userobj=new Users();
                    //$sql='select wx_userid,last_name from ld_users where id=?';
                    //$userresult=$adb->pquery($sql,array($value));
                    //$userobj->wx_userid=$adb->query_result($userresult,0,0);

                    //$userobj->last_name=$adb->query_result($userresult,0,1);
                    //edit:duan date:2024/11/27 reason: 速度优化
                    $userid = $value;
                    if($this->show_type==PAGEEXPORTLIST)
                    {
                        if(isKehu001ServerPc()=='yes'){
                            $userid_arr=explode(",",$userid);
                            $userlastName_arr=[];
                            foreach($userid_arr as $tmpuserid)
                                $userlastName_arr[]=getUserRealName($tmpuserid);//客户001导出用户的姓名和部门名称
                            $value=implode("、",$userlastName_arr);
                        }
                        else{
                            $value = getUserFullName($userid);
                        }
                    }
                    else
                        $value = getUserFullName($userid);


                }

                $field_user_name[$rawValue] = $value;
            }



        }
        else if ($field->getUIType() == 1108) {

            if ($this->module == 'Attachment') {

                return array('value' => $value, 'parent_module' => 'Attachment', 'rawvalue' => $this->recordId);
            } else {
                crm_load_class_file('DetailView_1108', 'include/fields/DetailView');
                $col_fields['record_id'] = $this->recordId;

                $label_fld = DetailView_1108::get_uitype_1108($focus, $field, $col_fields);

                return array('value' => $label_fld, 'parent_module' => 'Attachment', 'rawvalue' => $this->recordId);
            }
        }
        else if (($field->getUIType() == 102 || $field->getUIType() == '10'  || $field->getUIType() == 112)){
            //&&($this->show_type==SHOW_LISTVIEW||$this->show_type==SHOW_POPUP)
            //41283: （61mis.com/kfbtest）项目里程碑 项目 字段，列表没有超链接

            if (!empty($value)) {
                //edit:can 2021-01=14 44270: （http://51mis.com.cn/XS/ZKEA [^]）（苏州智数家建筑科技有限公司）成员管理中新建自动提醒（名字叫测试提醒，参考字段是更新时间），由这个设置发出的消息点击了相关对象之后显示模块未激活，并且页面会卡主
                if (($this->module == 'Attachment'||$this->module=='ModComments'||$this->module=='Reminds') && $field->getUIType() == 112) {
                    if($this->module == 'Attachment')
                    {
                        $sql = ' select reltab from ld_attachmentsforbills  where attachmentsid  =?  ';
                        $result = $adb->pquery($sql, array($this->recordId));
                    }
                    else if($this->module=='ModComments')
                    {
                        $sql = ' select reltab from ld_modcomments  where modcommentsid  =?  ';
                        $result = $adb->pquery($sql, array($this->recordId));
                    }
                    else
                    {
                        $sql = ' select distinct reltab  from  (select reltab from ld_reminds where remindsid=? union all 

                                            select  reltab from  ld_reminds_accepted where remindsid=?) as tmp  ';
                        $result = $adb->pquery($sql, array($this->recordId,$this->recordId));
                    }
                    $reltab = $adb->query_result($result, 0, 0);
                    if ($reltab == 'Users') {
                        $value = getUserFullName($rawValue);
                        $entitytype = 'Users';
                    } else {
                        $entitytype = getSalesEntityType($value);
                        if (!empty($entitytype)) {

                            $value = getModuleHref($entitytype, $value);
                        }
                    }

                } else {
                    $entitytype = getSalesEntityType($value);
                    if (!empty($entitytype)) {

                        $value = getModuleHref($entitytype, $value);
                    }
                }
                //zkt 20220623 BUG0053127【奥德】升级到最新版本后，2、附件管理中【机型数量】字段不显示（应该和布局规则有关）。
                return array('value' => $value, 'parent_module' => $entitytype, 'rawvalue' => $rawValue, 'hrefvalue' => $value);


            } else {
                $value = '';
            }
            //editor:gyq_129 reason:微信合同订单选择源单字段显示超链接  2019/7/25 14:52 ID1000529
            //ls 2022-05-06 0051373:项目》选中单据后，操作导出，导出文档中 选择源单字段显示的是数字(PC端也应该支持)
        }
        elseif ($field->getUIType() == 208 && !($field instanceof ProductFields)){
            $tmpmodulename = getSalesEntityType($value);
            $sourcedatavalue = getModuleHref($tmpmodulename, $value);
            //zkt 20240111 BUG0078271  销售订单导出Excel，选择源单那列没有显示源单单号，显示的是链接代码
            if ($tmpshowtype == SHOW_LISTVIEW || $tmpshowtype == SHOW_DETAILVIEW){
                //edit: xll 2023/05/06 XUQIU1001203 选择源单 增加“显示超链接”字段属性
                crm_load_class_file('cls_OptionModule', 'include/OptionModule');
                $cls_OptionModule = cls_OptionModule::getInstance($this->module,'');
                $field_AllData = $cls_OptionModule->getSourceModule_AllData($this->module);
                $tmpTabid = getTabid($tmpmodulename);
                if($field_AllData[$tmpTabid]['ShowHyperlinks'] === 'yes'){
                    $sourcedatavalue = "<a href='".CreateDetailViewHref($tmpmodulename,$value)."' doubleclick='yes' onclick='ListReferenceLinkClick(ld(this),event)' referencemodule='" . $tmpmodulename . "' referencerecord='" . $value . "' >" . getModuleHref($tmpmodulename, $value) . "</a>";
                }
            }
            return array('rawvalue' => $value, 'value' =>$sourcedatavalue , 'hrefvalue' => $sourcedatavalue, 'entityname' => $tmpmodulename);
        }
        elseif ($field->getUIType() == 202 && !($field instanceof ProductFields)){

            if (!empty($value)) {
                $tmpvalue = '';
                $tmpmodulename = '';
                $values = explode(',', $value);
                foreach ($values as $value) {
                    $value = trim($value, ',');

                    if (!empty($value)) {
                        if (empty($tmpmodulename))
                            $tmpmodulename = getSalesEntityType($value);
                        $sourcedatavalue = getModuleHref($tmpmodulename, $value);
                        if ($sourcedatavalue != '') {
                            $tmprawvalue.=  getModuleHref($tmpmodulename, $value);
                            if ($tmpshowtype == SHOW_LISTVIEW || $tmpshowtype == SHOW_DETAILVIEW) {

                                //edit: xll 2023/05/06 XUQIU1001203 选择源单 增加“显示超链接”字段属性
                                crm_load_class_file('cls_OptionModule', 'include/OptionModule');
                                $cls_OptionModule = cls_OptionModule::getInstance($this->module,'');
                                $field_AllData = $cls_OptionModule->getSourceModule_AllData($this->module);
                                $tmpTabid = getTabid($tmpmodulename);
                                if ($tmpTabid == 16) $tmpTabid = 9;
                                if($field_AllData[$tmpTabid]['ShowHyperlinks'] === 'yes')
                                    $tmpvalue .= "<a href='".CreateDetailViewHref($tmpmodulename,$value)."' doubleclick='yes' onclick='ListReferenceLinkClick(ld(this),event)' referencemodule='" . $tmpmodulename . "' referencerecord='" . $value . "' >" . getModuleHref($tmpmodulename, $value) . "</a>,";
                                else
                                    $tmpvalue .= getModuleHref($tmpmodulename, $value) . ',';

                                //$tmpvalue .= "<a href='".CreateDetailViewHref($tmpmodulename,$value)."' doubleclick='yes' onclick='ListReferenceLinkClick(ld(this),event)' referencemodule='" . $tmpmodulename . "' referencerecord='" . $value . "' >" . getModuleHref($tmpmodulename, $value) . "</a>,";
                                $tmpvalue_weixin .= getModuleHref($tmpmodulename, $value) . ',';
                            }
                            else
                                $tmpvalue .= getModuleHref($tmpmodulename, $value) . ',';
                        }
                    }
                }


                //editor:gyq_129 reason:选择源单字段增加保存到数据库功能  2019/7/11 17:11 ID1000529
                if($weixin_user->environment_weixin && ($tmpshowtype == SHOW_LISTVIEW || $tmpshowtype == SHOW_DETAILVIEW )){
                    $rawValue = $tmpvalue = trim($tmpvalue_weixin, ',');
                }else{
                    // $value = trim($tmpvalue, ',');
                    $tmpvalue=trim($tmpvalue, ',');
                    $tmprawvalue=trim($tmprawvalue,',');
                }
                return array('rawvalue' => $rawValue, 'value' =>$tmpvalue , 'hrefvalue' => $tmprawvalue, 'entityname' => $tmpmodulename);

            } else if ($tmpshowtype == SHOW_EDITVIEW && ($_REQUEST['record'] == 0 || $_REQUEST['isduplicate'] == true||$_REQUEST['isDuplicate'] == true)) {
                //新增或复制界面
                //37447: 源单类型定制中的默认值不生效了
                $sources = getSourceModule($module);
                foreach ($sources as $sourceinfo) {
                    if ($sourceinfo['default'] == 1)
                        $entitytype = $sourceinfo['entitytype'];

                }
                if($module == 'CashBill'||$module == 'SendCashBill'){
                    //收付款单，复制界面，源单类型有值但选择源单值为空
                    if ($this->recordId>0){
                        //zkt 20240620 BUG20240619-31  付款单（CR6945），复制单据（CR5924）填写实际付款金额后保存，单据详情中的实际付款金额没有了
                        $entitytype =  $focus->getSourceField('entitytype',$this->recordId);
                    }
                }
                return array('rawvalue' => 0, 'value' => '', 'hrefvalue' => '', 'entityname' => $entitytype);
            }
            //zkt 20221021 BUG0057835分录付款单分录丢失
            //收付款单，编辑界面，源单类型有值但选择源单值为空
            else if($tmpshowtype == SHOW_EDITVIEW&& ($_REQUEST['record'] != 0&& $_REQUEST['isDuplicate'] != true) &&($module == 'CashBill'||$module == 'SendCashBill')){
                if($module == 'CashBill'||$module == 'SendCashBill'){
                    if ($this->recordId>0){
                        $tmpentitytype =  $focus->getSourceField('entitytype',$this->recordId);
                        if(!empty($tmpentitytype)){
                            $entitytype = $tmpentitytype;
                        }
                    }
                }
                return array('rawvalue' => 0, 'value' => '', 'hrefvalue' => '', 'entityname' => $entitytype);
            }



        }
        elseif ($field->getUIType() == 202 && $field instanceof ProductFields && ($tmpshowtype == SHOW_LISTVIEW || $tmpshowtype == SHOW_POPUP)){
            //$isModule = new $module();

            $source_focus = CRMEntity::getInstance($this->module);
            if (get_file_address($this->module, 'ProductDetails')) {
                $lineitem_id = $adb->query_result($this->result, $this->line_index, 'lineitem_id');
                $sourceModuleinfo = $source_focus->getSourceField('entitytype', $lineitem_id);
                $sourceModule = $sourceModuleinfo['module'];
                $id = $sourceModuleinfo['sourceid'];
            }
            else {
                $sourceModuleinfo = $source_focus->getSourceField('entitytype', $this->recordId);
                $sourceModule = $sourceModuleinfo['module'];
                $id = $sourceModuleinfo['sourceid'];
            }

            $fielName = getEntityFieldNames($sourceModule);
            $fieldname = $fielName['fieldname'];
            $value = getModuleHref($sourceModule, $id);
            if (empty($value))
                $value = '--';
        }
        elseif ($field->getUIType() == 158 || ($field->getUIType() == 1 && $fieldName == 'reltab')){
            //$field->getUIType()==1&&$fieldName=='reltab'快速查找：评论
            $moduleName = $value;
            $value = getTranstab($value);
        }
        elseif ($field->getFieldDataType() == 'currency' ) {

            if(empty($value)) $value = '0.00000000';//BUG0065374 20230424 收款计划，没有已收金额时应自动显示为0


            ///222:佣金单小计

            if ($field->getUIType() == 72 || $field->getUIType() == 222 || $field->getUIType() == 71) {
                $contract_money_columnname = array('contract_total', 'contract_received_amount', 'contract_receivable_balance');
                $purchase_money_columnname = array('purchase_total', 'purchase_pay_amount', 'purchase_pay_balance');
                if( $this->showfieldvaluetype != PAGEEXPORTLIST)
                {
                    if (in_array($field->getColumnName(), $contract_money_columnname)) {
                        ///收款单选择原单发票，出库单
                        $currencySymbol = $adb->query_result($this->result, $this->line_index, 'contract_currency_symbol');

                    } else if (in_array($field->getColumnName(), $purchase_money_columnname)) {
                        //付款单选择原单采购发票，入库单
                        $currencySymbol = $adb->query_result($this->result, $this->line_index, 'purchase_currency_symbol');
                    } else {

                        if(!array_key_exists("currency_id",$moduleFields))
                        {
                            //币种为外币隐藏，列表的合计显示错误
                            //币种为外币可以通过关联创建
                            if(isHaveCurrrencyColumn($this->module)=='yes')
                            {
                                $focus=CRMEntity::getInstance($this->module);

                                $sql='select currency_id,currency_symbol from  '.$focus->table_name.' where '.$focus->table_index.'=?';
                                $tmpresult=$adb->pquery($sql,array($this->recordId));

                                if ($adb->num_rows($tmpresult) > 0) {
                                    $focus->column_fields['currency_id']=$adb->query_result($tmpresult,0,'currency_id');
                                    $this->col_fields['currency_id']=$focus->column_fields['currency_id'];
                                    $this->col_fields['currency_symbol']=$adb->query_result($tmpresult,0,'currency_symbol');
                                }


                            }
                        }
                        if (!empty($moduleFields['currency_id'])||$this->col_fields['currency_id']>0) {

                            if ($this->result&&$moduleFields['currency_id'])
                                $currency_id = $adb->query_result($this->result, $this->line_index, 'currency_id');
                            else
                                $currency_id = $this->col_fields['currency_id'];

                            if ($currency_id > 0) {
                                if ($this->result&&$moduleFields['currency_id'])
                                    $currencySymbol = $adb->query_result($this->result, $this->line_index, 'currency_symbol');
                                else
                                    $currencySymbol = $this->col_fields['currency_symbol'];
                            } else {
                                crm_load_function_file('getInventoryCurrencyInfo', 'include/utils', 'InventoryUtils');
                                $currencyInfo = getInventoryCurrencyInfo($this->module, $this->recordId);
                                $currencySymbol = $currencyInfo['currency_symbol'];
                            }

                        } else {

                            //没有币种的模块，金额字段默认为人民币
                            $currencyobj = Currency::getInstance($adb);
                            $currencySymbol = $currencyobj->getCurrencySymbol();
                        }
                    }
                }

                if (($field->getFieldName() == 'unit_price' || $field->getFieldName() == 'procostprice'||$field->getFieldName() == 'costprice') &&( $this->module == 'Products'||get_file_address($this->module,"ProductDetails"))) {
                    $sysdeploy_93 = getSys_deploy(93);    // 产品参考价小数位根据系统参数单价小数位控制
                    $price_decimal = $sysdeploy_93['deploy_value'];
                    $value = sprintf("%." . $price_decimal . "f", $value);
                    $value = floatval($value);
                    $rawValue=number_format((float)$value, $price_decimal,".","");
                    $rawValue = floatval($rawValue);
                    //zkt 20230303 先设置这两个字段 BUG0062342“产品管理”中“产品报价”和“参考成本价”字段缺少千分位
                    if($this->module == 'Products' &&($field->getFieldName() == 'unit_price' || $field->getFieldName() == 'procostprice')&&$tmpshowtype==SHOW_DETAILVIEW){
                        $value = setNumberFormat($rawValue, $price_decimal);
                    }

                } else {
                    $rawValue = !empty($rawValue)?floatval($rawValue):0;
                    if ($tmpshowtype == SHOW_DETAILVIEW) {
                        //edit:can 20210507 045762: （61mis.com/kfbcrm）OA表单-出差申请单-单据详情-小编辑预算或预支字段，显示了8位小数，保存时会提示另一个字段超过长度
                        $rawValue = number_format((float)$rawValue, $typeofdata_decimal, ".", "");
                        $value = number_format((float)$value, $typeofdata_decimal);//货币字段，从后台格式化
                    }elseif($tmpshowtype == SHOW_EDITVIEW){
                        $value = number_format((float)$value, $typeofdata_decimal, ".", "");
                        $rawValue = number_format((float)$rawValue, $typeofdata_decimal, ".", "");
                    }else {
                        $price_decimal=2;
                        if($this->showfieldvaluetype == PAGEEXPORTLIST)
                        {
                            //导出不需要格式千分位
                            $value = number_format((float)$value, $typeofdata_decimal,".","");

                        }
                        else

                            $value = number_format((float)$value, $typeofdata_decimal);
                    }

                }


            } else {
                $value = number_format((float)$value, $typeofdata_decimal);
            }

            //if($this->showfieldvaluetype==PAGEEXPORTLIST)//导出隐藏币种符号字段
            //{
            //  $currencySymbol="";


            //}




        }
        else if ($field->getUIType() == 115) {
            //Mikecrowe fix to correctly default for custom pick lists
            $values = array(getFixedLabel('Job') => 'Active', getFixedLabel('Quit') => 'Inactive');
            $optionvalue = array();
            $found = false;
            foreach ($values as $fixedlabel => $labelbol) {
                $pickListValue = $fixedlabel;
                //edit:can reason:13000: 控制面板>>用户管理：编辑未启用的用户，结果编辑界面中，用户状态显示为启用。
                if ($value == $labelbol) {
                    $chk_val = "selected";
                    $found = true;
                } else {
                    $chk_val = '';
                }
                $optionvalue[] = array($pickListValue, $labelbol, $chk_val);
            }
            if ($value == 'Inactive')
                $value = getFixedLabel('Quit');
            else
                $value = getFixedLabel('Job');


        }
        else if ($field->getUIType() == 118) {
            if (empty($this->sourcefromvalue)){
                $this->sourcefromvalue = getSourceFromValue();
            }
            if (!empty($this->sourcefromvalue[$value])){
                $value = $this->sourcefromvalue[$value];
            }
            if (empty($value)) {
                $value = '';
            }
        }
        else if ($field->getUIType() == 161 && $module == "Users" && $field->getFieldName() == 'approveby') {
            $value = getUserFullName($value);
        }
        elseif ($field->getUIType() == 111) {
            switch ($value) {
                case '1':
                    $value = constant('D_A_S_APPROVALOF');
                    break;
                case '2':
                    $value = constant('D_A_S_APPROVED');
                    break;
                case '3':
                    $value = constant('D_A_S_REJECTED');
                    break;
                case '4':
                    $value = constant('D_A_S_DISMISSED');
                    break;
                case '5':
                    $value = constant('D_A_S_APPROVALOF');
                    break;
            }
        }
        else if (($field->getUIType() == 7 || $field->getUIType() == 560) && $value != "") {


            $decimals_data = explode(',', $typeofdata);
            if ($decimals_data[1] == '') {
                $decimals_data[1] = 2;
            }
            $tmps=explode('~', $typeofdata);
            if($tmps[0]=='I'){
                //整数
                $decimals_data[1] = 0;
            }
            if ($this->module == 'Products' && ($fieldName == 'qtyinstock' || $fieldName == 'qtyearly')) {
                //28704: 新建账套-产品-编辑：安全库存 小数位数不正确
                $rawValue=number_format((float)$value, $this->LengthDecimal,".","");
                $value = number_format((float)$value, $this->LengthDecimal, '.', '');
                //edit:can 2020-10-09 42785: (61mis.com/kfbcrm)工具-产品管理-详情；在产品详情界面对产品的字段进行修改，若总库存和安全库存为千分位形式的话，会提示“无效的总库存数量”或“无效的安全库存”。crm_php72版本的产品管理也存在此状况。

                //在下面格式化

            } else if ($field->getUIType() == 560) {

                //合同订单数量合计
                $value = number_format((float)$value, $this->LengthDecimal, '.', '');
                $rawValue=number_format((float)$value, $this->LengthDecimal,".","");
            } else {
                //26856: （创彩账套）库存流水账列表：查找”操作前库存数量，关键字5“，查找出的单据不正确
                $value = number_format((float)$value, $decimals_data[1], '.', '');
                $rawValue=number_format((float)$value, $decimals_data[1],".","");

            }

        }
        elseif ($field->getFieldDataType() == 'date' || $field->getFieldDataType() == 'datetime') {

            if (!empty($value)) {
                if (strtolower($value) == 'thistoday') {
                    if ($field->getFieldDataType() == 'datetime') {
                        $value = date("Y-m-d H:i:s");
                    } else
                        $value = date("Y-m-d");
                } elseif (strtolower($value) == 'thistomorrow') {
                    $value = date("Y-m-d", strtotime("+1 day"));
                } elseif (strtolower($value) == 'thisextmonth') {
                    $value = date("Y-m-d", strtotime("+1 month"));
                } elseif (strtolower($value) == 'oneyear') {
                    if ($field->getFieldDataType() == 'datetime') {
                        $value = date("Y-m-d H:i:s", strtotime("+1 year -1 day"));
                    } else
                        $value = date("Y-m-d", strtotime("+1 year -1 day"));
                } elseif (strtolower($value) == 'beforeoneyear') {
                    if ($field->getFieldDataType() == 'datetime') {
                        $value = date("Y-m-d H:i:s", strtotime("-1 year +1 day"));
                    } else
                        $value = date("Y-m-d", strtotime("-1 year +1 day"));
                }
                else if (strpos(strtolower($value), 'afterday') !== false) {
                    $value_arr = explode('afterday', $value);
                    $day = $value_arr[1];
                    if($value=='afterday365')
                    {
                        //edit:can 20220706 修改为和高级查询 ，数据分类值一样
                        $day=$day;
                    }

                    if ($field->getFieldDataType() == 'datetime') {
                        $value = date("Y-m-d H:i:s");
                        $value = date("Y-m-d H:i:s", strtotime("+" . $day . " day"));
                    } else {
                        $value = date("Y-m-d");
                        $value = date("Y-m-d", strtotime("+" . $day . " day"));
                    }


                }
                else if (strpos(strtolower($value), 'daysago') !== false) {
                    $value_arr = explode('daysago', $value);
                    $day = $value_arr[1];
                    // dump($day);
                    if($value=='daysago365')
                    {
                        $day=$day;
                    }

                    if ($field->getFieldDataType() == 'datetime') {
                        $value = date("Y-m-d H:i:s");
                        $value = date("Y-m-d H:i:s", strtotime("-" . $day . " day"));
                    } else {
                        $value = date("Y-m-d");
                        $value = date("Y-m-d", strtotime("-" . $day . " day"));
                    }


                }
            }


            if($tmpshowtype !== SHOW_EDITVIEW) {
                // edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
                $value = DateOperation::format($format, $value);
            }

            if ($value != '' && $value > '1900-00-00') {

            } elseif ($value < '1900-00-00') {
                $value = '';
            }

        }
        elseif ($field->getFieldDataType() == 'time')
        {
            if($tmpshowtype !== SHOW_EDITVIEW) {
                // edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
                $value = DateOperation::format($format, $value);
            }

            //edit:can 20210129 44459: （本地8.3.7.1版本）客户-新建；客户模块有一个时间类型字段，保存后显示00:00:00；实际应当为空
            if($value=='00:00:00')
            {
                $value='';
            }
        }
        else if ($field->getUIType() == 251 || $field->getUIType() == 252) {

            if(is_null($value))
            {
                $value='';
            }
            $valueArr = explode("|##|", $value);

            if(!array_key_exists("currency_id",$moduleFields))
            {
                //币种为外币隐藏，列表的合计显示错误

                if(isHaveCurrrencyColumn($this->module)=='yes')
                {
                    $focus=CRMEntity::getInstance($this->module);

                    $sql='select currency_id,currency_symbol from  '.$focus->table_name.' where '.$focus->table_index.'=?';
                    $tmpresult=$adb->pquery($sql,array($this->recordId));

                    $focus->column_fields['currency_id']=$adb->query_result($tmpresult,0,'currency_id');
                    $this->col_fields['currency_id']=$focus->column_fields['currency_id'];
                    $this->col_fields['currency_symbol']=$adb->query_result($tmpresult,0,'currency_symbol');


                }
            }
            //在请求中加入“字段”名称，便于识别“转入账户”和“转出账户”
            //edit:can 20220411 50885: (81mis.com/kfbcrm）合同订单》相关创建收款单，默认显示的账户是“现金（财务部）”，不是根据设置的账户顺序显示第一个
            $reqfieldname=$_REQUEST['fieldname'];

            $_REQUEST['bankset_fieldname'] = $fieldName;
            $_REQUEST['fieldname']=$_REQUEST['bankset_fieldname'];

            crm_load_class_file("BankAccountSet", "modules/BankAccountSet");
            if ($this->recordId <= 0 && empty($this->col_fields['currency_id'])) {
                //BUG20240808-41 ls 240809 	出纳提现单，新建界面下拉显示了外币账户,币种下拉框默认为人民币
                if(isHaveCurrrencyColumn($this->module)=='yes' && array_key_exists("currency_id",$moduleFields))
                {
                    if (!empty($moduleFields['currency_id']->getDefaultvalue())) {
                        $currencyid = $moduleFields['currency_id']->getDefaultvalue();
                    }else{
                        $currencyid = 1;
                    }
                    $result = BankAccountSet::getBackAccount($currencyid);//有币种的模块且启用时
                }else{
                    $result = BankAccountSet::getBackAccount();//沒有币种的模块
                }
            } else {
                $tmpmode = 'edit';
                if (!empty($this->col_fields['currency_id'])) {
                    $currencyid = $this->col_fields['currency_id'];
                }  else {
                    //$currencyid = 1;
                }

                //0025692: 费用报销>新建：银行账户应该是一直显示为人民币的银行账户。
                //36680: （1.6）费用报销单新增界面>账户字段：选择不到外币的账户，只能选择人民币的账户。（需要补丁）
                $result = BankAccountSet::getBackAccount($currencyid);
            }
            //edit:can 202204111 50885: (81mis.com/kfbcrm）合同订单》相关创建收款单，默认显示的账户是“现金（财务部）”，不是根据设置的账户顺序显示第一个
            $_REQUEST['fieldname']=$reqfieldname;
            $rowCount = $adb->num_rows($result);
            if ($this->recordId <= 0) {
                $tmpmode = 'create';
            }

            for ($i = 0; $i < $rowCount; $i++) {

                //zkt 20220412 50923（https://81mis.com/kfbcrm/index.php）（需要补丁）银行账户，“一般账户”被禁用了，但做收付款单，仍可以选到。
                //新增、编辑界面，禁用账户下拉框不显示
                $tmpbankaccountsetid = $adb->query_result($result, $i, 'bankaccountsetid');
                $tmpdiscontinued = $adb->query_result($result, $i, 'discontinued');
                //if(($tmpmode == 'create'||$tmpmode == 'edit')&&$tmpbankaccountsetid!=$rawValue&&$tmpdiscontinued==0)
                //{continue;}

                $optionvalue[0][$i + 1][0] = $tmpbankaccountsetid;
                $optionvalue[0][$i + 1][1] = $adb->query_result($result, $i, 'accountname');
                $optionvalue[0][$i + 1][3] = $adb->query_result($result, $i, 'currency_id');
                if (($tmpmode == 'create' && $optionvalue[0][$i + 1][0] == $rawValue&&!empty($rawValue)) || ($tmpmode == 'edit' && $optionvalue[0][$i + 1][0] == $value&&!empty($value))) {
                    $optionvalue[0][$i + 1][2] = 'selected';
                    $detailoptions[] = array($adb->query_result($result, $i, 'bankaccountsetid'), $adb->query_result($result, $i, 'accountname'), 'selected');
                    $value = $adb->query_result($result, $i, 'accountname');
                } else {
                    $detailoptions[] = array($adb->query_result($result, $i, 'bankaccountsetid'), $adb->query_result($result, $i, 'accountname'), '');
                }
                if (empty($valueArr[0])) {
                    $value = '';
                }
                //银行账户新增时默认值
                if (empty($valueArr[0]) && $i == 0 && $tmpmode == 'create') {
                    $value = $adb->query_result($result, $i, 'accountname');
                }
            }

            //zkt 0047412: （http://112.233.242.118:85/crm/ [^]）客户问题（苏宁），费用报销、收款单（GR1379）、付款单 佣金单 ，银行账户历史数据显示数字
            if($rawValue==$value && ($this->show_type==SHOW_LISTVIEW||$this->show_type==SHOW_DETAILVIEW))
            {
                crm_load_class_file("BankAccountSet", "modules/BankAccountSet");
                $value = BankAccountSet::getBackAccountNameById($rawValue);
            }

        }
        else if ($uitype == 609) {
            if(empty($value)){
                $value = '';
            }
            switch (trim($value)) {
                case D_A_S_UNAPPROVED:
                    $value = getFixedLabel('Unapproved');
                    break;
                case D_A_S_APPROVALOF:
                    $value = getFixedLabel('Approvalof');
                    break;
                case D_A_S_APPROVED:
                    $value = getFixedLabel('Approved');
                    break;
                case D_A_S_REJECTED:
                    $value = getFixedLabel('Rejected');
                    break;
                case D_A_S_DISMISSED:
                    $value = getFixedLabel('Dismissed');
                    break;
            }
        }
        else if ($uitype == 116 || $uitype == 117) {
            static $static_currencyids;


            $pick_query = "select currency_name,id from ld_currency_info where currency_status = 'Active' and deleted=0";
            $pickListResult = $adb->pquery($pick_query, array());
            $noofpickrows = $adb->num_rows($pickListResult);

            //Mikecrowe fix to correctly default for custom pick lists
            $optionvalue = array();
            $found = false;
            for ($j = 0; $j < $noofpickrows; $j++) {
                $pickListValue = $adb->query_result($pickListResult, $j, 'currency_name');
                $currency_id = $adb->query_result($pickListResult, $j, 'id');
                $static_currencyids[$currency_id]['currency_name'] = $pickListValue;

                if ($value == $currency_id) {

                    $chk_val = "selected";

                } else {
                    $chk_val = '';
                }
                $optionvalue[$currency_id] = array($pickListValue => $chk_val);
            }
            $static_currencyids[$value]['options'] = $optionvalue;


            $currency_obj = new Currency($adb, $rawValue);
            $value = $currency_obj->getCurrencyName();
        }
        /*else if (($tmpshowtype == SHOW_EDITVIEW || $tmpshowtype == SHOW_DETAILVIEW) && $uitype == 16) {
            $fieldname = $adb->sql_escape_string($fieldName);
            $pick_query = "select $fieldname from ld_$fieldname order by sortorderid";
            $params = array();
            $pickListResult = $adb->pquery($pick_query, $params);
            $noofpickrows = $adb->num_rows($pickListResult);

            $options = array();
            $count = 0;
            $found = false;
            for ($j = 0; $j < $noofpickrows; $j++) {
                $pickListValue = decode_html($adb->query_result($pickListResult, $j, strtolower($fieldname)));
                $value = decode_html($value);

                if ($value == $pickListValue) {
                    $chk_val = "selected";
                    $count++;
                } else {
                    $chk_val = '';
                }
                $pickListValue = to_html($pickListValue);
                $optionvalue[] = array(($pickListValue), $pickListValue, $chk_val);
            }

        }*/
        else if (($tmpshowtype == SHOW_EDITVIEW || $tmpshowtype == SHOW_DETAILVIEW) && ($uitype == 15 || $uitype == 33 || $uitype == 601)) {
            global $default_charset, $global_pick_list_values;
            //没有办法了，要在最短的时间内做好下拉框优化，我只能采用全局变量，因为我们系统有弹出层和编辑页面，而弹出层ajax不执行js
            if (($fieldName == 'approvestatus' || $fieldName == 'level') && $this->module == 'Users')//用户审批委托人或职位级别没有下来（edit:can)
            {
                $picklistValues = array();
                if ($fieldName == 'approvestatus') {

                    if (stripos($value, '1') !== false || $value === '' || $value === null)
                        $value = getFixedLabel('INACTIVATE');
                    else if ($value == '0') {
                        $value = getFixedLabel('ACTIVATE');
                    }
                }
            }
            else {

                crm_load_function_file('getAssignedPicklistValues', 'modules/PickList', 'PickListUtils');
                //$picklistValues = getAssignedPicklistValues($fieldName, $profileid, $adb);//获取下拉列表显示值。
                if ($uitype == 601) {
                    if (!empty($value)) {
                        $trackpostion_query = "SELECT trackpostion from ld_trackpostion where trackpostion_id=? ";
                        $trackpostion_result = $adb->pquery($trackpostion_query, array($value));
                        $trackpostion_nums = $adb->num_rows($trackpostion_result);
                        if ($trackpostion_nums > 0) {
                            $value = $adb->query_result($trackpostion_result, 0, 0);
                        }
                    }
                }
                //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/9 0009 下午 2:35

                $tmpbol=false;
                foreach($global_pick_list_values as $tmp_pickindex=>$tmp_pickinfo)
                {

                    if($tmp_pickinfo['fieldname']==$fieldName)
                    {
                        $tmpbol=true;
                        $optionvalue=$tmp_pickinfo['optionvalue'];
                        break;
                    }
                }

                if(!$tmpbol)
                {
                    //edit:can 20210121 44374: （61mis.com/kfbcrm）客户-页面设置-布局规则；客户模块中设置了下拉框的布局规则，在单据新增时，修改下拉选项值，第一次点开发现变更了，再次点开发现没有显示原数值；
                    if($fieldName=='bill_state'||$fieldName=='bill_city'||$fieldName=='bill_area')
                    {
                        //先这样吧，应该是判断下拉框字段是否有级联
                        if($fieldName=='bill_state')
                        {
                            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname","bill_country");
                            $sql='select * from ld_picklist_dependency where tabid=? and sourcefield=? and targetfield=?';
                            $tmpresult=$adb->pquery($sql,array(getTabid($module),'bill_country','bill_state'));
                            if($adb->num_rows($tmpresult)<=0)
                                unset($fieldinfo);


                        }
                        else if($fieldName=='bill_city')
                        {
                            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname","bill_state");
                            //zkt 20240424 BUG20240422-30  1、新建客户时城市下拉框不显示选项，只有点设置保存后才显示选项
                            $sql='select * from ld_picklist_dependency where tabid=? and sourcefield=? and targetfield=?';
                            $tmpresult=$adb->pquery($sql,array(getTabid($module),'bill_state','bill_city'));
                            if($adb->num_rows($tmpresult)<=0)
                                unset($fieldinfo);
                        }
                        else{
                            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname","bill_city");
                        }
                        if($fieldinfo&&!empty($fieldinfo->getFieldName()))
                            $optionvalue=[];
                        else
                            $optionvalue = getEditViewPagePickList($fieldName, $value, $uitype, $field);
                    }
                    else if ($fieldName === 'role_module') {
                        crm_load_class_file('PricePolicyUtils','modules/PricePolicy');
                        $optionvalue =  PricePolicyUtils::getRoleModules($focus);
                    }
                    else {
                        if($bigtype === 'picklist_key') {
                            list('option' => $optionvalue, 'selectedIndex' => $selectedIndex) = getEditViewPagePickList($fieldName, $value, $uitype, $field);
                        }
                        else
                            $optionvalue = getEditViewPagePickList($fieldName, $value, $uitype, $field);
                    }

                    $global_pick_list_values[] = array('fieldname' => $fieldName, 'optionvalue' => $optionvalue);
                }

                //ls 2022-01-21 【ID1002461】中煤：下拉框选项动态显示的控制需求 (替换原来下拉框的值，包括编辑和详情页小编辑，修改$global_pick_list_values的值)
                //wym 240611 BUG20240607-47 移动端-工资条模块-工资期间字段 需要动态显示下拉框选项 新增页选项显示无法访问
                //判断内没有需要record的内容,原先因为只做编辑和详情页所以加了这个判断,目前新增页也需要所以先注释了
                if (/*$_REQUEST['record'] > 0 &&*/ $uitype == 15) {
                    $focus=CRMEntity::getInstance($this->module);
                    static $static_picklistRelatedValue_arr;
                    if(!is_array($static_picklistRelatedValue_arr))
                    {
                        $static_picklistRelatedValue_arr=[];
                    }
                    if(!is_array($static_picklistRelatedValue_arr[$this->module]))
                    {
                        $static_picklistRelatedValue_arr[$this->module]=[];
                    }
                    if(  !array_key_exists($this->module,$static_picklistRelatedValue_arr)
                        && array_key_exists($columnname,$static_picklistRelatedValue_arr[$this->module]))
                    {
                        $result=$static_picklistRelatedValue_arr[$this->module][$columnname] ;

                    }
                    else{
                        $sql = "SELECT t.* FROM ld_related_field AS t LEFT JOIN ld_field AS t1 ON t.effect_fieldid = t1.fieldid 
                        WHERE t1.columnname=? and  t.picklistsql is not null and t.picklistsql<>'' ORDER BY id DESC LIMIT 1";
                        $result = $adb->pquery($sql, array($columnname));
                    }

                    $static_picklistRelatedValue_arr[$this->module][$columnname]=$result;
                    if ($adb->num_rows($result) > 0) {
                        $trigger_fieldid = $adb->query_result($result, 0, 'trigger_fieldid');

                        $sql1 = "SELECT tabid,columnname FROM ld_field WHERE fieldid = ?";
                        $result1 = $adb->pquery($sql1, array($trigger_fieldid));
                        $trigger_fieldid_tabid = $adb->query_result($result1, 0, 'tabid');//trigger_fieldid_module
                        $trigger_fieldid_columnname = $adb->query_result($result1, 0, 'columnname');//trigger_fieldid_columnname

                        crm_load_class_file('cls_ParentRelatedField_Data','include/RelatedField');
                        $cls_ParentRelatedFields = new cls_ParentRelatedField_Data(vtlib_getModuleNameById($trigger_fieldid_tabid),
                            $focus->column_fields[$trigger_fieldid_columnname], $trigger_fieldid_columnname);
                        $relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');

                        if(!empty($relatedfielddata)){
                            foreach($relatedfielddata as $key => $vals){
                                if ($vals['picklist']['fieldname'] == $columnname) {
                                    foreach ($vals['picklist']['optionvalue'] as $key1=>$val1) {
                                        if ($val1[0] == $value) {
                                            $vals['picklist']['optionvalue'][$key1][2] = 'selected';
                                        }
                                    }

                                    //替换$global_pick_list_values的值
                                    foreach($global_pick_list_values as &$v){
                                        if($v['fieldname'] == $columnname){
                                            $v['optionvalue'] = $vals['picklist']['optionvalue'];
                                        }
                                    }

                                    $optionvalue = $vals['picklist']['optionvalue'];
                                }
                            }
                        }

                    }

                }
            }
        }else if ($uitype == 34){
            //edit:duan date:2024/10/28 reason:用户职位级别显示内容
            crm_load_function_file('getAssignedPicklistValues', 'modules/PickList', 'PickListUtils');
            global $default_charset, $global_pick_list_values;
            IF(($tmpshowtype == SHOW_EDITVIEW || $tmpshowtype == SHOW_DETAILVIEW)){
                $optionvalue = getEditViewPagePickList($fieldName, $value, $uitype, $field);
                $global_pick_list_values[] = array('fieldname' => $fieldName, 'optionvalue' => $optionvalue);
            }

            if($tmpshowtype == SHOW_DETAILVIEW || $tmpshowtype == SHOW_LISTVIEW){
                //列表详情页显示
                $user_level_arr = getUserGroupLevel($this->recordId,'no');

                $html_content = '';
                $tmp_value = '';
                foreach ($user_level_arr as $tmp_index=>$tmp_arr){
                    $groupid = $tmp_arr['id'];
                    $user_level = $tmp_arr['value'];
                    if(empty($user_level))continue;

                    if($tmp_index > 0){
                        $html_content .= ' , ';
                        $tmp_value .= ',';
                    }
                    $tmp_value .= $user_level;
                    $html_content .= '<span>'.getGroupFullName($groupid).'</span>';
                    $html_content .= '<span>:'.$user_level.'</span>';
                }
                $value = $html_content;
            }else if($tmpshowtype == SHOW_POPUP){
                //修改日志显示
                $user_level_arr = json_decode($value,true);
                if(is_array($user_level_arr)){
                    $html_content = '';
                    $tmp_value = '';
                    foreach ($user_level_arr as $tmp_index=>$tmp_arr){
                        $groupid = $tmp_arr['id'];
                        $user_level = $tmp_arr['value'];
                        if(empty($user_level))continue;

                        if($tmp_index > 0){
                            $html_content .= ' , ';
                            $tmp_value .= ',';
                        }
                        $tmp_value .= $user_level;
                        $html_content .= '<span>'.getGroupFullName($groupid).'</span>';
                        $html_content .= '<span>:'.$user_level.'</span>';
                    }
                    $value = $html_content;

                }
            }

        }
        else if ($uitype == 55 || $uitype == 255) {
            if ($fieldName == 'salutationtype') {

                $picklistValues = getAssignedPicklistValues('salutationtype', $profileid, $adb);
                $pickcount = 0;
                $salt_value = $col_fields["salutationtype"];
                foreach ($picklistValues as $order => $pickListValue) {
                    if ($value == trim($pickListValue)) {
                        $chk_val = "selected";
                        $pickcount++;
                    } else {
                        $chk_val = '';
                    }
                    if (isset($_REQUEST['file']) && $_REQUEST['file'] == 'QuickCreate') {
                        $optionvalue[] = array(htmlentities($pickListValue, ENT_QUOTES, $default_charset), $pickListValue, $chk_val);
                    } else {
                        $optionvalue[] = array($pickListValue, $pickListValue, $chk_val);
                    }
                }
                if ($pickcount == 0 && $salt_value != '') {
                    $optionvalue[] = array(getFixedLabel('NOTACCESS'), $salt_value, 'selected');
                }

            } else {
                $optionvalue[] = '';
            }

        }
        else if ($uitype == 1101)//手机样式
        {

            if ($tmpshowtype == SHOW_EDITVIEW) {

                if (fieldValueUitype::IsShowMobileTextBox($this->recordId, $this->module) == 'no') {
                    $rawValue = $value;
                    //$rawValue=base64_encode($value);
                    $value = fieldValueUitype::SetMobileStyle($this->recordId, $value, $this->module);
                }
            } else {
                $rawValue = base64_encode((string)$value);
                //gyqX160920 reason:微信端序时簿显示号码，号码原样输出
                //editor:gyq_20181119 reason:微信同样受手机号码样式限制 2018/11/19 15:56
                // if($_REQUEST['weixin_mark'] != 1){
                $value = fieldValueUitype::SetMobileStyle($this->recordId, $value, $this->module);
                //  }
            }
            //editor:gyq_85 reason:汉天呼叫中心优化 弹屏创建单据，带出手机号（有客户把手机字段设为不可编辑，导致tpl中uitype判断不到，故在后台传值） 2018/10/31 18:04
            if (!empty($_REQUEST['callphone']) && $_REQUEST['Create'] == true) {
                $value = $_REQUEST['callphone'];
            }
        }
        elseif ($uitype == 1600) {//选择成员字段
            //ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）(新建时showpagerule及编辑)
            if (!empty($value)) { //新建时，showPageByRule showpagerule 会重新给页面赋值
                //if(($field->isRelatedModuleField()&&$savedatabase=='no')||!$field->isRelatedModuleField())
                //{
                $value_groupid_arr = explode(',',$value);
                $groupid_where_arr = [];
                foreach ($value_groupid_arr as $tmpindex=>$tmpgroupid)
                {
                    if(is_numeric($tmpgroupid)){
                        $groupid_where_arr[] = " groupid=$tmpgroupid ";
                    }
                }
                $groupid_where = '';
                if(!empty($groupid_where_arr)){
                    $groupid_where = implode(' or ',$groupid_where_arr);
                }

                if(!empty($groupid_where)){
                    $query = 'select groupname,groupid from ld_groups where '.$groupid_where;
                    $result = $adb->pquery($query, array());
                    $userobj=new Users();
                    if ($adb->num_rows($result) >= 1) {
                        $groupname = array();
                        $groupid = array();
                        for ($i = 0; $i < $adb->num_rows($result); $i++) {
                            $userobj->groupid=$adb->query_result($result, $i, 'groupid');
                            $userobj->groupname=$adb->query_result($result, $i, 'groupname');
                            //edit:can 20210902 47802: （https://kehu001.com/KH/kh30033 [^]）客户-普阳会计；问题：部门字段显示有问题，新建单据保存以后，显示依然有问题。
                            if($this->show_type==PAGEEXPORTLIST)
                            {
                                $tmpgroupname=getWxRemindGroupName($userobj);//客户001导出用户的姓名和部门名称
                            }
                            else{
                                $tmpgroupname = getWx_GroupName($userobj);
                            }
                            $groupname[$i] = $tmpgroupname;
                            $groupid[$i] = $adb->query_result($result, $i, 'groupid');
                        }
                        $value = implode(',', $groupname);
                        $rawValue = implode(',', $groupid);
                    }else{
                        $value = '';
                        $rawValue = '';
                    }
                }
                unset($groupid_where,$groupid_where_arr,$value_groupid_arr);
                //}
                //else{
                //$rawValue=$value;
                //}
            }

        }

        //数字格式化
        if ($typedata[0] == 'N' || $typedata[0] == 'NN') {


            if ((isset($this->numfldarray['products_' . $fieldName]) && $fieldName != 'qtyinstock'
                    && $fieldName != 'qtyearly') ||
                (($fieldName == 'qtyinstock' || $fieldName == 'qtyearly')
                    && ($tmpshowtype == SHOW_LISTVIEW || $tmpshowtype == SHOW_DETAILVIEW))) {//最低库存
                if ($fieldName == 'qtyinstock' && $field->getTableName() == 'ld_products') {
                    if ($this->module == 'Quotes' || $this->module == 'SalesOrder') {
                        global $current_user;
                        if ($current_user->is_admin == 'off' && isset($current_user->column_fields['view_quantity']) && $current_user->column_fields['view_quantity'] == 0) {
                            if ($value >= 21) {
                                $value = getFixedLabel('many');    //多
                            } else if ($value <= 20 && $value > 0) {
                                $value = getFixedLabel('less');    //少
                            } else {
                                $value = getFixedLabel('NONE');    //无
                            }
                        }
                    }
                }
                //edit:can 2021-03-22 45095: 山尖（http://xiaoshou360.com/xs/sageplas [^]）产品管理模块-筛查产品POK后，合计异常（详情见附件）
                ///库存数量是4位以上的有该bug

                if (is_numeric($value)) {
                    //$value = setNumberFormat($value, $this->LengthDecimal);
                }
            }

        } else {
            if (isset($this->lenfldarray['products_' . $fieldName])) {//总库存数量、预警数量监控
                $value = setNumberFormat($value, $this->LengthDecimal);
            }
        }

        if ($this->module == 'InventoryAccount') {
            $numfldarr = array('firstqty' => '1', 'inputqty' => '1', 'outputqty' => '1', 'lastqty' => '1', '');
            if (isset($numfldarr[$fieldName])) {
                $value = setNumberFormat($value);//26294: 即时库存查询：预警数量小数位数显示为8位数。
            }
        }
        if ($this->module == 'InventoryQuery' && $fieldName == 'qtyearly') {
            $value = setNumberFormat($value, $typeofdata_decimal, "");
        }

        switch ($tmpshowtype) {
            case SHOW_POPUP:
                if($this->show_type==PAGEEXPORTLIST)
                    $currencySymbol='';
                $value = $currencySymbol . $value;//$currencySymbol币种符号
                crm_load_class_file("ShowPopFieldValue", "include/fields");

                $showpopfieldobj = new ShowPopFieldValue($this);

                $value = $showpopfieldobj->getFieldValueByField($field, $rawValue, $value);
                //zkt 20231113 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
                crm_load_class_file("cls_fieldSensitiverule", "include/fields");
                $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($this->module);
                if($field->gethavesensitivevalue() == 'yes'){
                    $tmpcolumn_value = $value['value'];
                    $tmpcolumn_value_arr = $cls_fieldSensitiveruleobj->getfieldsecretvaluearr($field,$tmpcolumn_value);
                    if(!empty($tmpcolumn_value_arr)){
                        $value['value'] = $tmpcolumn_value_arr['secretvalue'];
                    }
                    $tmpcolumn_value = $value['rawvalue'];
                    $tmpcolumn_value_arr = $cls_fieldSensitiveruleobj->getfieldsecretvaluearr($field,$tmpcolumn_value);
                    if(!empty($tmpcolumn_value_arr)){
                        $value['rawvalue'] = $tmpcolumn_value_arr['encryptvalue'];
                    }
                }
                return array('rawvalue' => $value['rawvalue'], 'value' => $value['value'], 'parent_module' => $value['parent_module']);
            case SHOW_EDITVIEW:
                crm_load_class_file("ShowEditFieldValue", "include/fields");
                $showeditfieldobj = new ShowEditFieldValue($this);
                $value = $showeditfieldobj->getFieldValueByField($field, $rawValue, $value);
                return array('rawvalue' => $rawValue, 'value' => $value['value'], 'parent_module' => $value['parent_module'], 'optionvalue' => $optionvalue, 'selectedIndex' => $selectedIndex);

            case SHOW_LISTVIEW:
                crm_load_class_file("ShowListFieldValue", "include/fields");
                $value = $currencySymbol . $value;//$currencySymbol币种符号
                $showlistviewobj = new ShowListFieldValue($this);
                $value = $showlistviewobj->getFieldValueByField($field, $rawValue, $value);

                if($field->gethavesensitivevalue() == 'yes'){
                    //zkt 20231113 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
                    crm_load_class_file("cls_fieldSensitiverule", "include/fields");
                    $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($this->module);
                    $tmpcolumn_value = $value['value'];
                    $tmpcolumn_value_arr = $cls_fieldSensitiveruleobj->getfieldsecretvaluearr($field,$tmpcolumn_value);
                    if(!empty($tmpcolumn_value_arr)){
                        $value['value'] = $tmpcolumn_value_arr['secretvalue'];
                        $value['hrefvalue'] = $tmpcolumn_value_arr['secretvalue'];
                    }
                    $tmpcolumn_value = $value['rawvalue'];
                    $tmpcolumn_value_arr = $cls_fieldSensitiveruleobj->getfieldsecretvaluearr($field,$tmpcolumn_value);
                    if(!empty($tmpcolumn_value_arr)){
                        $value['rawvalue'] = $tmpcolumn_value_arr['encryptvalue'];
                    }

                }
                return array('rawvalue' => $value['rawvalue'], 'value' => $value['value'], 'parent_module' => $value['parent_module']);
            case SHOW_DETAILVIEW:
                crm_load_class_file("ShowDetailViewValue", "include/fields");
                $showlistviewobj = new ShowDetailViewValue($this);
                $value = $showlistviewobj->getFieldValueByField($field, $rawValue, $value);


                return array('rawvalue' => $rawValue, 'value' => $value['value'], 'hrefvalue' => $value['hrefvalue'], 'parent_module' => $value['parent_module'], 'optionvalue' => $optionvalue, 'detailoption' => $detailoptions, 'selectedIndex' => $selectedIndex);
        }

        return array('rawvalue' => $rawValue, 'value' => $value, 'hrefvalue' => $value);

    }

}

?>