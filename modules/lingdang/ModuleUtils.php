<?php
class ModuleUtils{
    public function getCvColumnListWidth($module,$type,$cvid)
    {
        global $current_user,$adb;
        if($type=='popup_customview')
        {
            //edit:can 20230905
              $sql='select * from ld_list_headerwidth  where module=? and type=? and userid=?  ';
        $result=$adb->pquery($sql,array($module,$type,$current_user->id));
        }
       else{
        
        
         $sql='select * from ld_list_headerwidth  where module=? and type=? and userid=? and relateid=?';
        $result=$adb->pquery($sql,array($module,$type,$current_user->id,$cvid));
       }
        $num_rows=$adb->num_rows($result);
  
        $column_width=array();
        for($i=0;$i<$num_rows;$i++)
        {
            $columninfo=$adb->query_result($result,$i,'columns');
            $header_width=$adb->query_result($result,$i,'header_width');
            $column_width[$columninfo]=$header_width;
        }
        return $column_width;
    }
    public function getTabdetail_issticky($module) {
        //zxm 20220909 单据分录冻结列数
        static $tablearray;//加入静态变量内，防止重复提取文件 tujt
        if(!empty($tablearray) && isset($tablearray[$module])) return $tablearray[$module];
        $key = 'ldcrmTabdetail_issticky';
        $tablearray = Cache($key);
        if(!$tablearray){
            global $adb;
            $tablearray = array();
            $query = 'SELECT `name`,detail_issticky FROM ld_tab ORDER BY tabid;';
            $result = $adb->pquery($query,array());
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;$i++){
                    $name = $adb->query_result($result,$i,'name');
                    $detail_issticky = $adb->query_result($result,$i,'detail_issticky');
                    $tablearray[$name] = $detail_issticky;
                }
                Cache($key,$tablearray);
            }
        }
        if(isset($tablearray[$module]))return $tablearray[$module];
        return '';
    }
    public function getTabid($module) {
        /**
         * @project PROT58 速度优化：缓存
         * @author Tujt 2014-07-29
         */
        static $tablearray;//加入静态变量内，防止重复提取文件 tujt
        if(!empty($tablearray) && isset($tablearray[$module])) return $tablearray[$module];
        $key = 'ldcrmgettabid';
        $tablearray = Cache($key);
        if(!$tablearray||!isset($tablearray[$module])){
            global $adb;
            $tablearray = array();
            $query = 'SELECT tabid,name FROM ld_tab ORDER BY tabid;';
            $result = $adb->pquery($query,array());
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;$i++){
                    $tabid = $adb->query_result($result,$i,'tabid');
                    $mod = $adb->query_result($result,$i,'name');
                    if($mod == 'Calendar') $tabid = 16;
                    $tablearray[$mod] = $tabid;
                }
                Cache($key,$tablearray);
            }
        }
        if(isset($tablearray[$module]))return $tablearray[$module];
        return '';
    }
    //根据模块id获取移动端单据分录展现样式  zxm 20230316
    public function getTabDetailShowType($tabid) {
        /**
         * @project PROT58 速度优化：缓存
         * @author Tujt 2014-07-29
         */
        static $detailshowtypearray;//加入静态变量内，防止重复提取文件 tujt
        if(!empty($detailshowtypearray) && isset($detailshowtypearray[$tabid])) return $detailshowtypearray[$tabid];
        $key = 'ldcrmgetdetailshowtype';
        $detailshowtypearray = Cache($key);
        if(!$detailshowtypearray||!isset($detailshowtypearray[$tabid])){
            global $adb;
            $detailshowtypearray = array();
            $query = 'SELECT tabid,mobiledetailinfoshowtype FROM ld_tab ORDER BY tabid;';
            $result = $adb->pquery($query,array());
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;$i++){
                    $tmptabid = $adb->query_result($result,$i,'tabid');
                    $tmpmobiledetailinfoshowtype = $adb->query_result($result,$i,'mobiledetailinfoshowtype');
                    $detailshowtypearray[$tmptabid] = $tmpmobiledetailinfoshowtype;
                }
                Cache($key,$detailshowtypearray);
            }
        }
        if(isset($detailshowtypearray[$tabid]))return $detailshowtypearray[$tabid];
        return '';
    }
    //获取折叠或者表格显示的明细字段 zxm 20230316
    public function getSelectedDetailFields($module,$mobiledetailinfoshowtype){
        global $adb,$PlatformMC;
        $tabid = getTabid($module);
        $focus = CRMEntity::getInstance($module);
        $fieldSelectedArr = [];
        $fieldinfoObj = $focus->detailfieldobj->getListSearchFields();
        $sql = "select * from ld_fieldwxdetailinfo where tabid=? and mobiledetailinfoshowtype=?";
        $res = $adb->pquery($sql,array($tabid,$mobiledetailinfoshowtype));
        $nums = $adb->num_rows($res);
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $columnname = $adb->query_result($res,$i,'columnname');
                $fieldlabel = $fieldinfoObj[$columnname]->fieldLableKey;
                $fieldvaluecolor = $fieldinfoObj[$columnname]->fieldvaluecolor;
                //BUG0067892  zxm 20230728 设置好了字段显示之后 将字段隐藏 这里也不应该显示这个字段了
                if(!isset($fieldinfoObj[$columnname])){
                    continue;
                }
                if (!empty($PlatformMC['type_mini'])) {
                    //小程序
                    $fieldSelectedArr[$columnname] = [
                        'prop'=>$columnname,
                        'label'=>$fieldlabel,
                        'ordernum'=>$i
                    ];
                    if($columnname=='productname'){
                        //如果是产品名称
                        $fieldSelectedArr[$columnname]['onclick'] = 'true';
                        $fieldSelectedArr[$columnname]['fontSize'] = '';
                        $fieldSelectedArr[$columnname]['fontWeight'] = '400';
                        $fieldSelectedArr[$columnname]['width'] = '350';
                    }
                    if(!empty($fieldvaluecolor)){
                        $fieldSelectedArr[$columnname]['color'] = $fieldvaluecolor;
                    }
                }else{
                    $fieldSelectedArr[$columnname] = ['columnname'=>$columnname,'fieldlabel'=>$fieldlabel,'ordernum'=>$i];
                }

            }
        }
        return $fieldSelectedArr;
    }

    public function getBlocks($module, $disp_view, $mode, $col_fields = '', $info_type = '') {
        global $adb, $current_user;
        global $mod_strings;
        $tabid = getTabid($module);
        if($module=='Events') $tabid=16;
        $block_detail = Array();
        $getBlockinfo = "";
        $sigintabid=getTabid("Singin");
      
        $fieldobj=Field::getInstance($module,$adb);
       
        $cachemoduleblock=$fieldobj->getBlockInfos();
         
        // @edit:dong @date:2020/08/14 @reason: bug 0042408 系统设置->签到源单类型定制：模块新增时启用参数为“否”时，单据查看详情界面应该不显示签到地址区块
    
    
        $blockid_list = array();
        foreach($cachemoduleblock as $key_blockid=>$moduleblockinfo){
            // @edit:dong @date:2020/08/14 @reason: bug 0042408 系统设置->签到源单类型定制：模块新增时启用参数为“否”时，单据查看详情界面应该不显示签到地址区块
            /* edit:duan 拜访签到定制，这个参数enablewhenadding目前已经弃用，无法在界面上设置，所以删除相关的判断
            if($disp_view == 'detail_view' && $moduleblockinfo['label'] == 'LBL_ADDRESS_SINGIN' ){
                   crm_load_class_file("cls_OptionModule",'include/OptionModule');
                          
                       $optionmoduleobj=  cls_OptionModule::getInstance("Singin");
                        $optionModuleLists =$optionmoduleobj->getCurModuleData();
                       if( isset($optionModuleLists[$sigintabid][$tabid]['enablewhenadding']) 
                                   && $optionModuleLists[$sigintabid][$tabid]['enablewhenadding'] == 0)
                    {
                        continue;
                    }
            }
            */
            /**
            edit:chj
            date:2014-7-9
            reason:用户模块，如果服务合同没有开启，则不显示服务信息区块
             */
            if('Users' == $module && vtlib_isModuleActive('ServiceContracts') == false || (vtlib_isModuleActive('Accounts') == false&&vtlib_isModuleActive('HelpDesk') == false))
                if('LBL_SERVICECONTRACTS' == $moduleblockinfo['label'])
                    continue;
            if($_REQUEST['massedit'] == 'yes' && 'LBI_ATTACHMENT_FILE' == $moduleblockinfo['label']){
                //	continue;
            }
            //XUQIU1001374 xxy 2023-5-18 不再将标签的内容传进去，单独将内容拿出，在DetailViewUtils.php中
            if($moduleblockinfo['label'] == 'LBL_LABEL'){ 
                continue;
            }

            if($moduleblockinfo['visible']!=0||$moduleblockinfo[$disp_view]!=0)
            {
                continue;
            }
            //布局规则获取block列表时，根据触发布局规则的弹出层的disp_view值确定对应block是否显示
            if($mode == 'showpagerule'&&isset($_REQUEST['showpageruledisp_view'])&&$moduleblockinfo[$_REQUEST['showpageruledisp_view']]!=0){
                continue;
            }
            array_push($blockid_list, $key_blockid);
            // array('blocklabel'=>$moduleblockinfo['blocklabel'],'display_status'=>$moduleblockinfo['display_status'],'show_title'=>$moduleblockinfo['show_title'],'label'=>$moduleblockinfo['label']);
            $block_label[$key_blockid] =$moduleblockinfo['blocklabel'];
            $sLabelVal = $block_label[$key_blockid];

            //源单区块andy,$mode != 'mass_edit':批量编辑不显示原单信息
            if($moduleblockinfo['label']=='LBL_INVOICE_INFORMATION'&&$mode != 'mass_edit'){
                $block_label['show_origin_information']=array();//销售发票
            }
            /* if($moduleblockinfo['label']=='LBL_Cashbill_INFORMATION'&&$mode != 'mass_edit'){
                 $block_label['show_origin_information']=array();//收款单
             }*/

            if($moduleblockinfo['label']=='LBL_PURCHASEINVOICE_INFO'&&$mode != 'mass_edit'){
                $block_label['show_origin_information']=array();//采购发票
            }
            /* if($moduleblockinfo['label']=='LBL_SendCashBill_INFORMATION')
             {
                $block_label['show_origin_information']=array() ;
             }*/

            $aBlockStatus[$sLabelVal] = $moduleblockinfo['display_status'];
        }
        $_SESSION['BLOCKINITIALSTATUS'] = $aBlockStatus;
        $getBlockInfo = [];
        if ($disp_view == "detail_view") {

            if (isset($_SESSION['rlvs']))
                unset($_SESSION['rlvs']);
            crm_load_function_file("getDetailBlockInformation","include/utils",'DetailViewUtils');

            $getBlockInfo = getDetailBlockInformation($module, $result, $col_fields, $tabid, $block_label);
             
        }
        else {
            crm_load_function_file("getBlockInformation","include/utils",'EditViewUtils');
            $getBlockInfo = getBlockInformation($module, $result, $col_fields, $tabid, $block_label, $mode);

        }

        if (is_array($getBlockInfo) && count($getBlockInfo) > 0) {
            foreach ($getBlockInfo as $label => $contents) {

                if (empty($getBlockInfo[$label])&& $label!= getFixedLabel('RECORDSOFOPERATION')) {
                    unset($getBlockInfo[$label]);
                }
            }
        }

        return $getBlockInfo;
    }
    public function setObjectValuesFromRequest($focus) {
        if (isset($_REQUEST['record'])) {

            $focus->id = $_REQUEST['record'];
        }
        if (isset($_REQUEST['mode'])) {
            $focus->mode = $_REQUEST['mode'];
        }
        global $adb;
        $focus->after_field_info=array();
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset($_REQUEST[$fieldname])) {

                if (is_array($_REQUEST[$fieldname]))
                    $value = $_REQUEST[$fieldname];
                else
                    $value = trim($_REQUEST[$fieldname]);

                $field_uitype = $focus->columns_uitype[$fieldname];
                if(in_array($field_uitype,[230,231,19,21])){
                    //editor:gyqX160929 reason:微信端备注等长字段是经POST数组放在REQUSET中，此时用POST接收不到数据
                    if($field_uitype==230 || $field_uitype==231)
                    {
                        if(isset($_POST[$fieldname])){
                            $value=($_POST[$fieldname]);
                        }else{
                            $value=($_REQUEST[$fieldname]);
                        }
                    }
                    else
                    {
                        
                        $value=TextRemoveXSS($_REQUEST[$fieldname]);
                    }

                }
                else{
                     $value=TextRemoveXSS($_REQUEST[$fieldname]);
                }
                if($field_uitype==56)
                {
                    //26764: 控制面板>用户管理页面：普通用户编辑“允许查看相关信息列表数据权限”勾选保存不生效
                    //	$value = $_POST[$fieldname];
                    //editor:gyqX170122 reason:经POST数组放在REQUSET中，此时用POST接收不到数据  gyq_122
                    //gyqLoad0122 微信参数统一放入POST
                    if(isset($_POST[$fieldname])){
                        $value=$_POST[$fieldname];
                    }else{
                        $value=$_REQUEST[$fieldname];
                    }
                }

                $focus->column_fields[$fieldname] = $value;
            }
            else
            {
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
                //editor:gyq reason:在编辑保存时，跳过displaytype=2或=3的情况 date:20180719
                $displaytype = $fieldinfo->displaytype;
                if(($displaytype==2||$displaytype==3) && $focus->id > 0){
                    continue;
                }
                if($focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname))
                {
                    //025040: 快速创建-产品：设置产品类别的默认值后创建产品，保存后列表界面，产品类别字段显示为空
                    $defaultvalue=$fieldinfo->getDefaultValue();
                    if($fieldinfo->getFieldDataType()=='date')
                    {

                        if($defaultvalue=='thistoday')
                        {
                            $defaultvalue=date("Y-m-d");
                        }
                    }
                    else if($fieldinfo->getFieldDataType()=='datetime')
                    {
                        if($defaultvalue=='thistoday')
                        {
                            $defaultvalue=date("Y-m-d H:i:s");
                        }
                    }
                }

                //销售发票，复选框在打钩的情况无法修改
                $focus->column_fields[$fieldname]=$_REQUEST[$fieldname];
                //38469: （51mis.com/kfbcrm）系统设置>页面设置>选择报价单模块>启用字段：设置默认勾选，在新增报价单时没有生效。
                if($focus->columns_uitype[$fieldname]==56&&( isset($_REQUEST['file'])&&  strtolower($_REQUEST['file'])=='save'))
                {
                    //if(empty($_REQUEST[$fieldname]))
//					$focus->column_fields[$fieldname]=0;//23770: 产品序列表界面：自定义分类【测试】，新建保存的单据无法帅选出来
//				if(!empty($fieldinfo) && $fieldinfo->getQuickCreate()==0&&$defaultvalue!='')//快速创建中不存在该复选框字段时，保存应取该字段默认值
//                   $focus->column_fields[$fieldname]=$defaultvalue;
//                if(isset($_POST[$fieldname])){
//                    $focus->column_fields[$fieldname]=$_POST[$fieldname];
//                   }
                }else{
                    if($defaultvalue!='')
                    {
                        //zkt 20240529 BUG20240528-45  入库单已设置仓库默认值，但是不生效
                        if($fieldinfo->getColumnName()=='wareid')
                        {
                            require_once(globalStatic::$root_directory.'include/Stock/CommonStock.php');
                            $ware_arr= getWareAllInfo($current_user);
                            foreach($ware_arr as $wareinfo)
                            {
                                if($wareinfo['name']==$fieldinfo->getDefaultvalue()||$wareinfo['id']==$fieldinfo->getDefaultvalue())
                                {
                                    $defaultvalue=$wareinfo['id'];
                                    break;
                                }
                            }
                        }
                        //025040: 快速创建-产品：设置产品类别的默认值后创建产品，保存后列表界面，产品类别字段显示为空
                        $focus->column_fields[$fieldname]=$defaultvalue;

                    }
                }
                $defaultvalue="";

            }

            $fieldinfo=new fieldInfo();
            $columnname=$focus->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'columnname');
            $fieldinfo->setcolumnName($columnname);
            $fieldinfo->setFieldName($fieldname);
            $fieldinfo->setColumn_Value($focus->column_fields[$fieldname]);
            $focus->after_field_info[]=$fieldinfo;


        }
        $focus->after_save_infos[]=$focus->column_fields;

    }
    //根据区块的名称获取区块的对应的帮助说明
  
    public function getBlockInfoForLinks($header,$mode = 'edit'){
        global $adb,$currentModule;
        $oem = getCommonVersion('oem_crm');
        $a_href = '';
        if($oem == 'no'){
            if(!empty($header)){
                $fieldobj=Field::getInstance($currentModule,$adb);
                $cachemoduleblock=$fieldobj->getBlockInfos();
                foreach($cachemoduleblock as $key_blockid=>$moduleblockinfo){
                    if($moduleblockinfo['visible']!=0){
                        continue;
                    }
                    if(!empty($moduleblockinfo['linkid']) && $moduleblockinfo['linkid'] != null && $moduleblockinfo['linkid'] != ''){
                        $blocks = explode('|',$moduleblockinfo['linkid']);
                        $blockid = $blocks[0];
                        $blockmode = $blocks[1];
                    }
                    if($blockid > 0 && $header == $moduleblockinfo['blocklabel'] && ($blockmode == $mode || empty($blockmode))){
                        $query = 'select tabid,linktype,linklabel from ld_links where linkid = ?';
                        $result = $adb->pquery($query,array($moduleblockinfo['linkid']));
                        $num_rows = $adb->num_rows($result);
                        if($num_rows >= 1){
                            $tabid = $adb->query_result($result,0,'tabid');
                            $linktype = $adb->query_result($result,0,'linktype');
                            $linklabel = $adb->query_result($result,0,'linklabel');
                            if($linklabel == 'AttachmentBlock')continue;
                            $style = "margin-top: 2px;";
                            if($currentModule == 'Users'){
                                $style = 'margin: 0 10px;';
                            }else{
                                if($mode == 'detailview'){
                                    $style = "margin: 0 10px;";
                                }else if($mode == 'edit'){
                                    $style = "margin: 5px 10px 0 0;";
                                }
                            }
                            $a_href = "<a class=\"detailTab rfloat\" id=\"$linklabel\" href=\"javascript:;\" style='$style' onclick=\"event.stopPropagation()||(event.cancelBubble = true);getLinksUrl('$tabid','$linktype','$linklabel');\">".getFixedLabel('ONLINEHELP')."</a>";
                            //echo $a_href;echo '<br><br>';
                        }
                    }
                }
            }
        }
        return $a_href;
    } 
    
    public function getModuleHref($module,$id){
        global $adb;
        if(empty($id)) return '';
        static $modulehrefvalue=array();
        if(isset($modulehrefvalue[$module.'_'.$id]))
        {
            //不需要重复查询
            return $modulehrefvalue[$module.'_'.$id];
        }
        if(empty($module)) $module = getSalesEntityType($id);
        if(array_key_exists($module, globalStatic::$moduleHrefArr)){
            $modulehrefs= globalStatic::$moduleHrefArr;
            $entitynames=$modulehrefs[$module];
        }else{
            $entitynames = getEntitynameByModulename($module);
        }
        $focus = CRMEntity::getInstance($module);
        $columnname = $entitynames['fieldname'];
        $tablename = $entitynames['tablename'];
        $entityidfield = $entitynames['entityidfield'];

        globalStatic::$moduleHrefArr[$module]=array('fieldname'=>$columnname,'tablename'=>$tablename,'entityidfield'=>$entityidfield);
        $sql = 'select '.$columnname.' from '.$tablename;
        //自定义表
        if(!empty($focus->customFieldTable)&&$tablename!=$focus->customFieldTable[0]){
            $sql .= ' left join ' . $focus->customFieldTable[0] . ' on ' . $focus->customFieldTable[0] . '.' .$focus->customFieldTable[1] . ' = ' . $tablename . '.' . $entityidfield;
        }
        $sql .= ' where '.$tablename.'.'.$entityidfield.' = ? limit 1;';
        $result = $adb->pquery($sql, array($id));
        $rows = $adb->num_rows($result);
        $name = '';
        if(1 == $rows)
            $name = $adb->query_result($result,0,$columnname);
        $modulehrefvalue[$module.'_'.$id]=$name;
        return $name;
    }
    public function getModuleSequenceNumber($module, $recordId) {
        global $adb;
        switch ($module) {
            case "Invoice":
                $res = $adb->query("SELECT invoice_no FROM ld_invoice WHERE invoiceid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'invoice_no');
                break;
            case "PurchaseOrder":
                $res = $adb->query("SELECT purchaseorder_no FROM ld_purchaseorder WHERE purchaseorderid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'purchaseorder_no');
                break;
            case "Quotes":
                $res = $adb->query("SELECT quote_no FROM ld_quotes WHERE quoteid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'quote_no');
                break;
            case "SalesOrder":
                $res = $adb->query("SELECT salesorder_no FROM ld_salesorder WHERE salesorderid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'salesorder_no');
                break;
            case 'HelpDesk':
                $res = $adb->query("SELECT ticket_no FROM ld_troubletickets WHERE ticketid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'ticket_no');
                break;
            case 'PaymentPlan':
                $res = $adb->query("SELECT paymentplan_no FROM ld_PaymentPlan WHERE paymentplanid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'paymentplan_no');
                break;
            case 'PriceBooks':
                $res = $adb->query("SELECT pricebook_no FROM ld_pricebook WHERE pricebookid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'pricebook_no');
                break;
            case 'Expense':
                $res = $adb->query("SELECT expense_no FROM ld_Expense WHERE expenseid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'expense_no');
                break;
            case 'ContactRecords':
                $res = $adb->query("SELECT contactrecordid FROM ld_contactrecords WHERE contactrecordid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'contactrecordid');
                break;
            case 'Accounts':
                $res = $adb->query("SELECT accountid FROM ld_account WHERE accountid = $recordId");
                $moduleSeqNo = $adb->query_result($res, 0, 'accountid');
                break;
            default:
                $sql='select tablename,entityidfield from ld_entityname where modulename=?';
                $result=$adb->pquery($sql,array($module));
                if($adb->num_rows($result)>0)
                {
                    $entityidfield=$adb->query_result($result,0,1);
                    $tablename=$adb->query_result($result,0,0);
                    $res = $adb->query("SELECT $entityidfield FROM $tablename WHERE $entityidfield = $recordId");
                    $moduleSeqNo = $adb->query_result($res, 0, $entityidfield);
                }
        }
        return $moduleSeqNo;
    }
    public function getEntityName($module, $ids_list) {
        if ($module == 'Events') {
            $module = 'Calendar';
        }
        if ($module != '') {
            if (is_array($ids_list) && count($ids_list) <= 0) {
                return array();
            }
            $entityDisplay = array();
            $entity_field_info = getEntityFieldNames($module);
            if($module=='Users')
            {
                $fieldsName='last_name';
                $entity_field_info['fieldname']=$fieldsName;
            }
            else
            {
                $fieldsName = $entity_field_info['fieldname'];
            }
            $entity_FieldValue = getEntityFieldValues($entity_field_info, $ids_list);
            foreach($entity_FieldValue as $entityInfo) {
                foreach($entityInfo as $key => $entityName) {
                    $fieldValues = $entityName;
                    $entityDisplay[$key] = getEntityFieldNameDisplay($module, $fieldsName, $fieldValues);
                }
            }
            return $entityDisplay;
        }
    }
    public function isPermitted($module,$actionname='index',$record_id=''){
     
    }
    //根据模块名称 字段名称 获取级联字段的上级字段名称
    public function getPrevAdvanceFieldname($module,$stagefieldname){
        $tabid= getTabid($module);
        $all_prev_advance_fieldname_value = array();
        //zxm 20230523 kfbcrm BUG0066412   服务收费管理---进度漏斗---点击打开速度很慢
        global $adb;
        $depency_sql = "select sourcefield from ld_picklist_dependency where tabid=? and targetfield=? ";
        $depency_res = $adb->pquery($depency_sql,array($tabid,$stagefieldname));
        $depency_nums = $adb->num_rows($depency_res);
        $sourcefield = "";
        //是级联字段 且有上级字段
        if ($depency_nums>0) {
            crm_load_function_file("getAllPickListValues",'modules/PickList','PickListUtils');
            $sourcefield = $adb->query_result($depency_res,0,'sourcefield');

        }
        return $sourcefield;
    }
    //获取所有已开启的模块名称
    public function getAllModules(){
        global $adb;
        $query="SELECT
        	ld_tab.name
        FROM
        	ld_tab
        where ld_tab.presence = 0  and tabid in(select  DISTINCT tabid from ld_field)
        ORDER BY
        	ld_tab.tabsequence ASC";
        $result = $adb->query($query,array());
        $num_rows=$adb->num_rows($result);
        $alltabs = [];
        for($i=0;$i<$num_rows;$i++) {
            $alltabs[] = $adb->query_result($result, $i, 'name');
        }
        return $alltabs;
    }
}