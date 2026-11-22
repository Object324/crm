<?php
class cls_BusinessInformation
{
    public $module;
    public $tabid;
    public $businessinformation_arr;
    public $backfillingmaparr;
    public $businesstype_arr = array('enablebusiness','nobusinessnosave','nobusinessnoimport','enablefuzzyquery','enablebatchbackfill','fuzzyquerycontrol');
    public static $fuzzycontrol_defaultarr = array('allowcancelbusiness'=>'no','allowprivatebusiness'=>'no');
    public static function getInstance($module)
    {
        static $static_businessinformationobj;
        if(isset($static_businessinformationobj[$module]))
        {
            return $static_businessinformationobj[$module];
        }
        $static_businessinformationobj[$module]=  new cls_BusinessInformation($module);
        return $static_businessinformationobj[$module];
    }

    public function __construct($module)
    {
        $this->module = $module;
        $this->tabid = getTabid($module);
    }
    //判断工商查询功能是否可以使用——有工商授权/设置了key
    public function IsUseBusinessStatus(){
        $deployarray=getSys_deploy(344);
        $flage = false;
        if($deployarray['deploy_value'] == 0){
            $flage = true;
        }
        else{
            $regop=RegOp::getInstance();
            if($regop->GetbusinessInterfaceStatus()==1 ){
                $flage = true;
            }
        }
        return $flage;
    }
    //判断是否启用工商查询
    public function IsEnableBusiness(){
        $businessinformation = $this->getBusinessInformation();
        $flage = false;
        $fieldid = $businessinformation['fieldid'];
        $focus = CRMEntity::getInstance($this->module);
        // $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldid',$fieldid);
        $allfieldinfos = $focus->fieldobj->getPresenceFields();
        $allfieldids = [];
        foreach($allfieldinfos as $blockid=>$fieldinfos)
        {
            $allfieldids = array_merge(array_keys($fieldinfos),$allfieldids);

        }

        if($businessinformation['enablebusiness'] == 'yes' && $this->IsUseBusinessStatus() && in_array($fieldid,$allfieldids)){
            $flage = true;
        }
        return $flage;
    }
    //判断是否开启没有工商信息不允许保存
    public function IsNoBusinessnosave(){
        $businessinformation = $this->getBusinessInformation();
        $flage = false;
        if($businessinformation['nobusinessnosave'] == 'yes'&&$this->IsEnableBusiness()){
            $flage = true;
        }
        return $flage;
    }
    //判断是否开启没有工商信息不允许导入
    public function IsNoBusinessnoimport(){
        $businessinformation = $this->getBusinessInformation();
        $flage = false;
        if($businessinformation['nobusinessnoimport'] == 'yes'&&$this->IsEnableBusiness()){
            $flage = true;
        }
        return $flage;
    }
    //判断是否启用工商模糊查询
    public function IsEnableBusinessfuzzyquery(){
        $businessinformation = $this->getBusinessInformation();
        $flage = false;
        if($businessinformation['enablefuzzyquery'] == 'yes' &&$this->IsEnableBusiness()){
            $flage = true;
        }
        return $flage;
    }
    //判断是否启用批量
    public function IsEnableBatchbackfill(){
        $businessinformation = $this->getBusinessInformation();
        $flage = false;
        if($businessinformation['enablebatchbackfill'] == 'yes' &&$this->IsEnableBusiness()){
            $flage = true;
        }
        return $flage;
    }


    //获取模糊查询规则
    public function getBusinessfuzzyquerycontrol(){
        $businessinformation = $this->getBusinessInformation();
        $fuzzyquerycontrol = array();
        if($this->IsEnableBusinessfuzzyquery()){
            $fuzzyquerycontrol = $this->fuzzycontrol_defaultarr;
            if(!empty($businessinformation['fuzzyquerycontrol']) ){
                $fuzzyquerycontrol = $businessinformation['fuzzyquerycontrol'];
            }
            if(is_array($fuzzyquerycontrol)){
                $fuzzyquerycontrol = $fuzzyquerycontrol;
            }
        }
        return $fuzzyquerycontrol;
    }
    //获取天眼查deployvalue
    public static function getBinsterfacedeployvalue(){
        $deployarray=getSys_deploy(344);
        $deploy_value  = $deployarray['deploy_value'];
        return $deploy_value;
    }
    //获取天眼查inputvalue
    public static function getBinsterfaceinputvalue(){
        global $adb;
        $deployarray=getSys_deploy(344);
        $inputvalue  = $deployarray['inputvalue'];
        $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
        $business_insterfacekey_value = $cls_AESencryptionbykeyobj->getdecryption($inputvalue);
        if($business_insterfacekey_value == ''){
            $business_insterfacekey_value = $inputvalue;
            $adb->pquery('update ld_systems_deploy set inputvalue = ? where deploy_type = 344',array($cls_AESencryptionbykeyobj->getencryption($inputvalue)));
        }
        return $business_insterfacekey_value;
    }
    //获取模糊查询开始查询数量
    public static function getBusinessfuzzyquerytosearchnum(){
        $deployarray=getSys_deploy(467);
        $tosearchnum  = $deployarray['deploy_value'];
        if(empty($tosearchnum)){
            $tosearchnum = 2;
        }
        return $tosearchnum;
    }
    //设置模糊查询开始查询数量
    public static function setBusinessfuzzyquerytosearchnum($fuzzyquerytosearchnum)
    {
        global $adb;
        $adb->pquery('update ld_systems_deploy set deploy_value =  ? where deploy_type = ?',array($fuzzyquerytosearchnum, 467));
        unsetCache('systems_deploy');
    }
    //获取模块的工商信息
    public function getBusinessInformation(){
        global $adb;
        $tabid = $this->tabid;
        if(isset($this->businessinformation_arr)&&!empty($this->businessinformation_arr)){
            return $this->businessinformation_arr;
        }
        $businessinformation_arr = array();
        $query = "select * from ld_business_settings where tabid = ?";
        $result = $adb->pquery($query,array($tabid));
        $rows = $adb->num_rows($result);
        if($rows>0){
            for($tmpi = 0;$tmpi<$rows;$tmpi++)
            {
                $tmparray = array();
                $tmptabid = $adb->query_result($result,$tmpi,'tabid');
                $businessinformation_arr['fieldid'] = $adb->query_result($result,$tmpi,'fieldid');
                //enablebusiness:是否启用工商接口；nobusinessnosave：没有工商信息不允许报存；nobusinessnoimport：没有工商信息不允许导入；enablefuzzyquery：模糊查询；enablebatchbackfill：批量回填
                //nosave_exception_column、nosave_exception_group没有工商信息不允许导入的例外条件
                $businessinformation_arr['enablebusiness'] = $adb->query_result($result,$tmpi,'enablebusiness');
                $businessinformation_arr['nobusinessnosave'] = $adb->query_result($result,$tmpi,'nobusinessnosave');
                $businessinformation_arr['nobusinessnoimport'] = $adb->query_result($result,$tmpi,'nobusinessnoimport');
                $businessinformation_arr['enablefuzzyquery'] = $adb->query_result($result,$tmpi,'enablefuzzyquery');
                $businessinformation_arr['enablebatchbackfill'] = $adb->query_result($result,$tmpi,'enablebatchbackfill');
                $businessinformation_arr['nosave_exception_column'] = html_entity_decode(trim($adb->query_result($result,$tmpi,'nosave_exception_column')));
                $businessinformation_arr['nosave_exception_group'] = html_entity_decode($adb->query_result($result,$tmpi,'nosave_exception_group'));
                $fuzzyquerycontrol_str= $adb->query_result($result,$tmpi,'fuzzyquerycontrol');
                $fuzzyquerycontrol = array();
                if(!empty($fuzzyquerycontrol_str)){
                    $fuzzyquerycontrol = json_decode(htmlspecialchars_decode($adb->query_result($result,$tmpi,'fuzzyquerycontrol')),true);
                }
                $businessinformation_arr['fuzzyquerycontrol'] = $fuzzyquerycontrol;
            }
        }
        $this->businessinformation_arr = $businessinformation_arr;
        return $businessinformation_arr;
    }
    public function setBusinessInformationbytype($type,$setvalue)
    {
        global $adb;
        $tabid = $this->tabid;
        if(in_array($type,$this->businesstype_arr)){
            $query = "update ld_business_settings set $type=? where tabid = ?";
            $adb->pquery($query,array($setvalue,$tabid));
        }

    }
    //保存模块工商信息保存的例外条件
    public function setBusinessadvancedemand($advance_demand_str,$advance_demand_groups_str)
    {
        global $adb;
        $advance_demand=ldcrm_json_decode(trim($advance_demand_str));
        if (!empty($advance_demand)) {
            $index = 1;
            $tmp_advance_demand = [];
            foreach ($advance_demand as $advft_criteria_obj){
                if (empty($advft_criteria_obj)) continue;
                $tmp_advance_demand[] = $advft_criteria_obj;
            }
            $advance_demand = ldcrm_json_encode($tmp_advance_demand);
        }


        $advance_demand_groups = ldcrm_json_decode(trim($advance_demand_groups_str));
        if (!empty($advance_demand_groups)) {
            $index = 1;
            $tmp_advance_demand_groups = [];
            foreach ($advance_demand_groups as $advft_criteria_groups_obj){

                $tmp_advance_demand_groups[] = $advft_criteria_groups_obj;
                $index++;
            }
            $advance_demand_groups = ldcrm_json_encode($tmp_advance_demand_groups);
        }
        if(is_array($advance_demand))
        {
            $advance_demand=ldcrm_json_encode($advance_demand);
        }
        if(is_array($advance_demand_groups))
        {
            $advance_demand_groups=ldcrm_json_encode($advance_demand_groups);

        }
        $tabid = $this->tabid;
        $query = "update ld_business_settings set nosave_exception_column=?,nosave_exception_group=? where tabid = ?";
        $adb->pquery($query,array($advance_demand,$advance_demand_groups,$tabid));

    }
    //设置工商查询key
    public static function setBusinessIinsterfacekey($business_search_method,$business_insterfacekey_value='')
    {
        global $adb;
        if(!empty($business_insterfacekey_value)){
            //更新天眼查工商接口KEY 0:设置 1:未设置
            $adb->pquery('update ld_systems_deploy set deploy_value = ? , inputvalue = ? where deploy_type = ?',array($business_search_method,$business_insterfacekey_value, 344));
            unsetCache('systems_deploy');
        }
        else{
            //更新天眼查工商接口KEY 0:设置 1:未设置
            $adb->pquery('update ld_systems_deploy set deploy_value =  ? where deploy_type = ?',array($business_search_method, 344));
            unsetCache('systems_deploy');
        }
    }
    //获取所有模块设置的工商设置信息
    public static function getAllBusinessInformation()
    {
        global $adb;
        $businessinformation_arr = array();
        $query = "SELECT ld_business_settings.* from ld_business_settings INNER JOIN ld_tab ON ld_business_settings.tabid = ld_tab.tabid WHERE ld_tab.presence in (0,2)
                    and ld_business_settings.tabid not IN (SELECT tabid from ld_tab where name in 
                    ('Reminds','ChinaMap','CooperativeWork','WorkReportList','Webmails','Emails','ReportAnalysis','VisualAnalysis','ChannelCode',
                    'Questionnaire','SocialPromotion','BankCash','Shopping','ShopSettings','WechatSession')) order by ld_business_settings.tabid ";
        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        if($rows>0){
            for($tmpi = 0;$tmpi<$rows;$tmpi++)
            {
                $tmparray = array();
                $tmptabid = $adb->query_result($result,$tmpi,'tabid');
                $fieldid = $adb->query_result($result,$tmpi,'fieldid');
                $field_arr = cls_BusinessInformation::getAvailableFields($tmptabid,$fieldid);
                $businessinformation_arr[$tmptabid]['field_arr'] = $field_arr;
                $businessinformation_arr[$tmptabid]['fieldid'] = $fieldid;
                $businessinformation_arr[$tmptabid]['id'] = $adb->query_result($result,$tmpi,'id');
                //enablebusiness:是否启用工商接口；nobusinessnosave：没有工商信息不允许报存；nobusinessnoimport：没有工商信息不允许导入；enablefuzzyquery：模糊查询；enablebatchbackfill：批量回填
                //nosave_exception_column、nosave_exception_group没有工商信息不允许导入的例外条件
                //fuzzyquerycontrol工商模糊查询规则
                $businessinformation_arr[$tmptabid]['enablebusiness'] = $adb->query_result($result,$tmpi,'enablebusiness');
                $businessinformation_arr[$tmptabid]['nobusinessnosave'] = $adb->query_result($result,$tmpi,'nobusinessnosave');
                $businessinformation_arr[$tmptabid]['nobusinessnoimport'] = $adb->query_result($result,$tmpi,'nobusinessnoimport');
                $businessinformation_arr[$tmptabid]['enablefuzzyquery'] = $adb->query_result($result,$tmpi,'enablefuzzyquery');
                $fuzzyquerycontrol_str= $adb->query_result($result,$tmpi,'fuzzyquerycontrol');
                $fuzzyquerycontrol = array();
                if(!empty($fuzzyquerycontrol_str)){
                    $fuzzyquerycontrol = json_decode(htmlspecialchars_decode($adb->query_result($result,$tmpi,'fuzzyquerycontrol')),true);
                }
                $businessinformation_arr[$tmptabid]['fuzzyquerycontrol'] = $fuzzyquerycontrol;
                $businessinformation_arr[$tmptabid]['enablebatchbackfill'] = $adb->query_result($result,$tmpi,'enablebatchbackfill');
                $businessinformation_arr[$tmptabid]['nosave_exception_column'] = html_entity_decode(trim($adb->query_result($result,$tmpi,'nosave_exception_column')));
                $businessinformation_arr[$tmptabid]['nosave_exception_group'] = html_entity_decode($adb->query_result($result,$tmpi,'nosave_exception_group'));
            }
        }
        return $businessinformation_arr;
    }
    //获取模块设置的回填映射规则
    public function getBackfillingMaprule()
    {
        global $adb;
        $tabid = $this->tabid;
        if(isset($this->backfillingmaparr)&&!empty($this->backfillingmaparr)){
            return $this->backfillingmaparr;
        }
        $cachekey = 'getBackfillingMaprule_'.$tabid;
        $Backfillingmaparr = CacheDirectory($cachekey,'Cache');
        if(!is_array($Backfillingmaparr)){
            $Backfillingmaparr = [];
        }
        if(empty($Backfillingmaparr)){
            $query = "select * from ld_business_backfillfield where tabid = ? order by sequence;"; 
            $result = $adb->pquery($query,array($tabid));
            $rows = $adb->num_rows($result);
            if($rows>0){
                for($i=0;$i<$rows;$i++){
                    $tmparray = array();
                    $tmparray['tianyanchalabel'] = $adb->query_result($result,$i,'tianyanchalabel');
                    $tmparray['tianyanchaname'] = $adb->query_result($result,$i,'tianyanchaname');
                    $tmparray['trancolumnname'] = $adb->query_result($result,$i,'trancolumnname');
                    $tmparray['defaultvalue'] = $adb->query_result($result,$i,'defaultvalue');
                    $tmparray['trancoltype'] = $adb->query_result($result,$i,'trancoltype');
                    $Backfillingmaparr[] = $tmparray;
                }
            }
            CacheDirectory($cachekey,'Cache',$Backfillingmaparr);
        }
        $this->backfillingmaparr = $Backfillingmaparr;
        return $Backfillingmaparr;
    }
    //获取数据库保存的设置回填字段信息
    public function getBackFillFields()
    {
        global $adb;
        $backfillingmaparr = $this->getBackfillingMaprule();
        $focus=CRMEntity::getInstance($this->module);
        foreach ($backfillingmaparr as $tmpindex=>$backfillinfo)
        {
            $tianyanchalabel = $backfillinfo['tianyanchalabel'];
            $tianyanchaname = $backfillinfo['tianyanchaname'];
            $trancolumnname = $backfillinfo['trancolumnname'];
            $defaultvalue = $backfillinfo['defaultvalue'];
            $trancoltype = $backfillinfo['trancoltype'];
            if(empty($trancolumnname)&&!empty($defaultvalue)){
                $trancolumnname = $defaultvalue;
            }
            $tranlabel = getFixedLabel('NONE');
            $fieldname = '';
            if(!empty($trancolumnname)&&$trancolumnname!=null){
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$trancolumnname);
                if(!empty($fieldinfo)){
                    $tranlabel = $fieldinfo->getFieldLabelKey();
                    $fieldname = $fieldinfo->getFieldName();
                }
                else{
                    $trancolumnname = '';
                }
            }
            $backfillfieldinfos[]= array(
                'label'=>getFixedLabel($tianyanchalabel),
                'tianyanchaname'=>$tianyanchaname,
                'trancolumnname'=>$trancolumnname,
                'fieldname'=>$fieldname,
                'tranlabel'=>$tranlabel,
                'type'=>$trancoltype
            );
        }
        return $backfillfieldinfos;
    }
    //更新设置的回填字段内容
    public function updataBackFillField($tabid,$tianyanchaname,$trancolumnname,$trancoltype){
        global $adb;
        $query = 'select * from ld_business_backfillfield where tabid = ? and tianyanchaname = ? and trancolumnname = ? and trancoltype = ?';
        $result = $adb->pquery($query,array($tabid,$tianyanchaname,$trancolumnname,$trancoltype));
        $rows = $adb->num_rows($result);
        if($rows<1)
        {
            $sqlquery = 'update ld_business_backfillfield set trancolumnname =? , trancoltype = ? where tabid=? and tianyanchaname = ?';
            $adb->pquery($sqlquery,array($trancolumnname,$trancoltype,$tabid,$tianyanchaname));
        }
        $tabid = $this->tabid;
        $cachekey = 'getBackfillingMaprule_'.$tabid;
        unsetCache($cachekey);
    }

    //获取所有的黑名单字段
    public static function getBlackKeylist($limit_start_rec,$per_page_new,$searchwords)
    {
        global $adb;
        $query = "select * from ld_business_wordslist where wordtype='blackkey'   ";
        if(!empty($searchwords)){
            $query .= "  and wordkey like '%$searchwords%' ";
        }
        $query .= "  limit $limit_start_rec,$per_page_new ";
        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        $blackkeylist = array();
        if($rows>0)
        {
            for($i=0;$i<$rows;$i++)
            {
                $blackkeyarr = array();
                $blackkeyarr['id'] = $adb->query_result($result,$i,'id');
                $blackkeyarr['wordkey'] = $adb->query_result($result,$i,'wordkey');
                $blackkeyarr['wordtype'] = $adb->query_result($result,$i,'wordtype');
                $creater = $adb->query_result($result,$i,'creater');
                $creater_name= 'System';
                if(!empty($creater)){
                    $creater_name = getUserFullName($creater);
                }
                $blackkeyarr['creater'] = $creater;
                $blackkeyarr['creater_name'] = $creater_name;
                $blackkeyarr['createdtime'] = $adb->query_result($result,$i,'createdtime');
                $modifieder = $adb->query_result($result,$i,'modifieder');
                $modifieder_name= 'System';
                if(!empty($modifieder)){
                    $modifieder_name = getUserFullName($modifieder);
                }
                $blackkeyarr['modifieder'] = $modifieder;
                $blackkeyarr['modifieder_name'] = $modifieder_name;
                $blackkeyarr['modifiedtime'] = $adb->query_result($result,$i,'modifiedtime');
                $blackkeylist[] = $blackkeyarr;
            }
        }
        return $blackkeylist;
    }
    //根据id获取黑名单关键字
    public static function getBlackKeyWordsById($keywordid)
    {
        global $adb;
        $query = "select * from ld_business_wordslist where wordtype='blackkey' and id=?;";
        $result = $adb->pquery($query,array($keywordid));
        $rows = $adb->num_rows($result);
        $wordkey = "";
        if($rows>0)
        {
            $wordkey = $adb->query_result($result,0,'wordkey');
        }
        return $wordkey;
    }

    //查询keyword是否存在
    public static function getBlackkeyWordsid($blackkeyword)
    {
        global $adb;
        $query = "select id from ld_business_wordslist where wordtype='blackkey' and wordkey=? ";
        $result = $adb->pquery($query,array($blackkeyword));
        $rows = $adb->num_rows($result);
        $keywordid = 0;
        if($rows>0){
            $keywordid = $adb->query_result($result,0,'id');
        }
        return $keywordid;
    }
    //查询keyword是否存在
    public static function IsExistBlackWords($blackkeyword)
    {
        global $adb;
        $flage = false;
        if(!empty(self::getBlackkeyWordsid($blackkeyword))){
            $flage = true;
        }
        return $flage;
    }
    //查询keyword是否存在
    public static function IsExistBlackWordsnotid($blackkeyword,$keywordid)
    {
        global $adb;
        $query = "select 1 from ld_business_wordslist where wordtype='blackkey' and wordkey=?  and id!=?";
        $result = $adb->pquery($query,array($blackkeyword,$keywordid));
        $rows = $adb->num_rows($result);
        $flage = false;
        if($rows>0){
            $flage = true;
        }
        return $flage;
    }
    public static function saveBlackKeyWords($blackkeyword,$keywordid)
    {
        global $adb,$current_user;
        if(!empty($keywordid)){
            $query = "update ld_business_wordslist set wordkey=?,modifieder=? where id=?";
            $adb->pquery($query,array($blackkeyword,$current_user->id,$keywordid));
        }
        else{
            if(!self::IsExistBlackWords($blackkeyword)){
                $query = "insert into ld_business_wordslist(`wordkey`,`wordtype`,`creater`,`modifieder`) values(?,'blackkey',?,?);";
                $adb->pquery($query,array($blackkeyword,$current_user->id,$current_user->id));
            }
        }
    }
    public static function deleteBlackKeyWords($keywordid)
    {
        global $adb,$current_user;
        if(!empty($keywordid)){
            $query = "DELETE from ld_business_wordslist where id=?";
            $adb->pquery($query,array($keywordid));
        }
    }


    public static function getBusinesslogBydate($startdata,$enddata){
        crm_load_class_file('cls_TianYanCha', 'modules/Users');
        $cls_TianYanChaobj = new cls_TianYanCha('','');
        $cls_TianYanChaobj->setOperationType('showbusinesslog');
        $apilogdata = $cls_TianYanChaobj->getSearchHistoryList($startdata,$enddata);
        return $apilogdata['result'];
    }
    public static function getBusinesslogBydatedetail($startdata,$enddata){
        crm_load_class_file('cls_TianYanCha', 'modules/Users');
        $cls_TianYanChaobj = new cls_TianYanCha('','');
        $cls_TianYanChaobj->setOperationType('showbusinesslogdetail');
        $apilogdata = $cls_TianYanChaobj->getSearchHistoryList($startdata,$enddata);
        return $apilogdata['result'];
    }
    public static function getBusinesslogdataanalysis($startdata,$enddata){
        crm_load_class_file('cls_TianYanCha', 'modules/Users');
        $cls_TianYanChaobj = new cls_TianYanCha('','');
        $cls_TianYanChaobj->setOperationType('showbusinesslogdataanalysis');
        $apilogdata = $cls_TianYanChaobj->getSearchHistoryList($startdata,$enddata);
        return $apilogdata['result'];
    }

    //获取模块的工商查询字段
    public function getModuleBusinessQueryField($returntype=''){
        global $adb;
        if (empty($this->module)) return '';
        $module = $this->module;
        $tabid = getTabid($module);
        $select_sql = "SELECT fieldid FROM ld_business_settings where tabid = ?";
        $select_result = $adb->pquery($select_sql,array($tabid));
        $fieldid = $adb->query_result($select_result,0,'fieldid');
        $focus=CRMEntity::getInstance($module);
        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldid',$fieldid);
        // dump($fieldinfo);
        if(empty($fieldinfo)){//字段没权限或者字段没启用
            $allfieldinfos = $focus->fieldobj->getPresenceFields();
            foreach($allfieldinfos as $blockid=>$fieldinfos){
                foreach($fieldinfos as $tmp_fieldid=>$tmp_fieldinfo){
                    if($tmp_fieldid == $fieldid){
                        $fieldinfo = $tmp_fieldinfo;
                        break 2;
                    }
                }
            }
            if(empty($fieldinfo))
                return '';
            if(!empty($returntype))
                $returninfo = $fieldinfo[$returntype];
            else
                $returninfo = $fieldinfo['fieldname'];
        }else{
            if($returntype == 'columnname')
                $returninfo = $fieldinfo->getColumnName();
            else if($returntype == 'fieldid')
                $returninfo = $fieldid;
            else
                $returninfo = $fieldinfo->getFieldName();
            
        }
        return $returninfo;
    }
    //获取所有有回填字段的模块
    public static function getBackfillModules(){
        global $adb;
        $select_sql = "SELECT ld_business_settings.tabid FROM ld_business_settings INNER JOIN ld_tab ON ld_business_settings.tabid = ld_tab.tabid WHERE ld_tab.presence in (0,2)
                        and ld_business_settings.tabid not IN (SELECT tabid from ld_tab where name in 
                        ('Reminds','ChinaMap','CooperativeWork','WorkReportList','Webmails','Emails','ReportAnalysis','VisualAnalysis','ChannelCode',
                        'Questionnaire','SocialPromotion','BankCash','Shopping','ShopSettings','WechatSession')) ";
        $select_result = $adb->pquery($select_sql,array());
        $num_rows = $adb->num_rows($select_result);
        if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $selectmodulearr[] = getTabModuleName($adb->query_result($select_result,$i,'tabid'));
            }
        }
        
        return $selectmodulearr;
    }
    //比较模块的回填字段，若有新增接口字段则插入
    public function compareBackfillFields(){
        global $adb;
        $tabid = getTabid($this->module);
        $selectmap_sql = "SELECT mappingfieldlabel,mappingfieldname FROM ld_business_mappingfields";
        $selectmap_result = $adb->pquery($selectmap_sql,array());
        $num_rows = $adb->num_rows($selectmap_result);
        if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $mappingfieldname = $adb->query_result($selectmap_result,$i,'mappingfieldname');
                $mappingfields_arr[] = $mappingfieldname;
                // $mappingfields[$mappingfieldname] = $adb->query_result($selectmap_result,$i,'mappingfieldlabel');
            }
        }

        $select_sql = "SELECT tianyanchaname FROM ld_business_backfillfield where tabid = ?";
        $select_result = $adb->pquery($select_sql,array($tabid));
        $num_rows = $adb->num_rows($select_result);
        if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $backfillfields_arr[] = $adb->query_result($select_result,$i,'tianyanchaname');
            }
        }
        $new_mappingfields = array_diff($mappingfields_arr, $backfillfields_arr);//对比得出新增的回填字段
        if($new_mappingfields != []){
            $cachekey = 'getBackfillingMaprule_'.$tabid;
            unsetCache($cachekey);
            $insert_sql = "INSERT into ld_business_backfillfield(`tabid`,`tianyanchalabel`,`tianyanchaname`,`trancolumnname`,`defaultvalue`,`trancoltype`,`sequence`) 
                            SELECT ".$tabid.",mappingfieldlabel,mappingfieldname,'','null','',sequence FROM ld_business_mappingfields where mappingfieldname = ?";
            foreach($new_mappingfields as $mappingfield){
                $adb->pquery($insert_sql,array($mappingfield));
            }
        }
    }
    //获取可选模块
    public static function getAvailableModules($tabid=''){
        global $adb;

        $sql = "SELECT DISTINCT ld_tab.tabid ,ld_tab.name from ld_tab INNER JOIN ld_field ON ld_tab.tabid = ld_field.tabid where ld_tab.isentitytype = 1 and ld_tab.presence in (0,2) 
                    and ld_tab.tabid not IN (SELECT tabid from ld_tab where name in 
                        ('Reminds','ChinaMap','CooperativeWork','WorkReportList','Webmails','Emails','ReportAnalysis','VisualAnalysis','ChannelCode',
                        'Questionnaire','SocialPromotion','BankCash','Shopping','ShopSettings','WechatSession')) 
                    and ld_tab.tabid not IN (SELECT tabid from ld_business_settings) and ld_field.columnname = 'smownerid'
                ";
        if(!empty($tabid)){
            $sql .= " or ld_tab.tabid = ".$tabid." ";
        }
        $sql .= " order by ld_tab.tabsequence";
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $module_tabid = $adb->query_result($result,$i,'tabid');
                $module_name = $adb->query_result($result,$i,'name');
                $modulelist[$module_tabid]['modulename'] = $module_name;
                $modulelist[$module_tabid]['modulelabel'] = getTranstab($module_name);
            }
        }
        return $modulelist;
    }
    //获取模块中所有可设置的工商查询字段
    public static function getAvailableFields($tabid,$fieldid=''){
        global $adb,$current_user;

        $field_arr['']['fieldlabel'] = "--".getFixedLabel('NONE')."--";
        $field_arr['']['selected'] = '';

        $module = getTabModuleName($tabid);
        $focus=CRMEntity::getInstance($module);
        if(!empty($focus->fieldobj)){
            $fieldinfos = $focus->fieldobj->getModuleFields();
            foreach ($fieldinfos as $fieldname => $fieldinfo){
                if($fieldinfo->getBigType() == 'text' && $fieldinfo->get_allowedit() == 'yes'){
                    // if($fieldinfo->getUiType() != 154){//排除团队成员
                        $tmp_fieldid = $fieldinfo->getFieldid();
                        $field_arr[$tmp_fieldid]['fieldlabel'] = $fieldinfo->getFieldLabelKey();
                        if($tmp_fieldid == $fieldid){
                            $field_arr[$tmp_fieldid]['selected'] = 'selected';
                        }else{
                            $field_arr[$tmp_fieldid]['selected'] = '';
                            $field_arr['']['selected'] = 'selected';
                        }
                    // }
                }
            }
        }
        return $field_arr;
    }
    //新增工商查询模块
    public static function createBusinessModule($tabid=''){
        global $adb,$current_user;
        if($tabid == ""){
            $tabid = array_keys(cls_BusinessInformation::getAvailableModules())[0];
        }
        // $tabid = getTabid($module);
        $module = getTabModuleName($tabid);
        $newmodule_arr = [];
        if(!empty($tabid)){
            $insert_sql = "INSERT into ld_business_settings(`tabid`,`enablebusiness`,`nobusinessnosave`,`nobusinessnoimport`,`enablefuzzyquery`,`enablebatchbackfill`,`nosave_exception_column`,`nosave_exception_group`) 
                            values(?,?,?,?,?,?,?,?);";
            $adb->pquery($insert_sql,array($tabid,'yes','no','no','no','no','[]','[]'));
            $newmodule_arr = [
                "id" => $adb->getLastInsertID(),
                "tabid" => $tabid,
                "module" => $module,
                "modulelabel" => getTranstab($module),
            ];
            cls_BusinessInformation::createBackfillFields($tabid);
        }
        return $newmodule_arr;
    }
    //新增时修改工商查询模块
    public static function changeBusinessModule($id,$tabid){
        global $adb,$current_user;
        //先删除原先模块的回填字段
        $select_sql = "SELECT tabid FROM ld_business_settings where id = ?";
        $select_result = $adb->pquery($select_sql,array($id));
        $old_tabid = $adb->query_result($select_result,0,'tabid');
        cls_BusinessInformation::deleteBackfillFields($old_tabid);//同时删除回填字段

        $update_sql = "UPDATE ld_business_settings set `tabid` = ?,`fieldid` = ? where id = ?";
        $adb->pquery($update_sql,array($tabid,'',$id));
        cls_BusinessInformation::createBackfillFields($tabid);
    }
    //新增工商查询模块对应回填字段
    public static function createBackfillFields($tabid){
        global $adb,$current_user;

        $insert_sql = "INSERT into ld_business_backfillfield(`tabid`,`tianyanchalabel`,`tianyanchaname`,`trancolumnname`,`defaultvalue`,`trancoltype`,`sequence`) 
                        SELECT ".$tabid.",mappingfieldlabel,mappingfieldname,'','null','',sequence FROM ld_business_mappingfields
                        WHERE NOT EXISTS(select 1 from ld_business_backfillfield where tabid= ?);";
        $adb->pquery($insert_sql,array($tabid));
    }
    //删除工商查询模块对应回填字段
    public static function deleteBackfillFields($tabid){
        global $adb,$current_user;

        $delete_sql = "DELETE from ld_business_backfillfield where tabid = ?";
        $adb->pquery($delete_sql,array($tabid));
    }
    //更改工商查询字段
    public static function changeBusinessQueryField($tabid,$fieldid){
        global $adb,$current_user;

        $update_sql1 = "UPDATE ld_business_settings set `fieldid` = ? where tabid = ?";
        $adb->pquery($update_sql1,array($fieldid,$tabid));

        $update_sql2 = "UPDATE ld_field set `businessquery` = ? where tabid = ?";
        $adb->pquery($update_sql2,array('no',$tabid));

        $update_sql3 = "UPDATE ld_field set `businessquery` = ? where `fieldid` = ? and tabid = ?";
        $adb->pquery($update_sql3,array('yes',$fieldid,$tabid));
        unsetCacheDirectory('fields');
    }
    //删除工商查询模块
    public static function deleteBusinessModule($tabid){
        global $adb,$current_user;
        
        $delete_sql = "DELETE from ld_business_settings where tabid = ?";
        $adb->pquery($delete_sql,array($tabid));
        cls_BusinessInformation::deleteBackfillFields($tabid);

        $update_sql = "UPDATE ld_field set `businessquery` = ? where tabid = ?";
        $adb->pquery($update_sql,array('no',$tabid));
        unsetCacheDirectory('fields');
    }
    //往smarty里传模块的工商查询设置信息
    public static function getBusinessQueryInfo($smarty,$module,$stype){
        $businessinformationobj = cls_BusinessInformation::getInstance($module);
        $smarty->assign('BUSINESSQUERY',1);
        if($stype == 'editview'){
            if($businessinformationobj->IsEnableBusiness()){
                $smarty->assign('BUSINESSQUERY',0);
                $smarty->assign('BUSINESSQUERYFIELD',$businessinformationobj->getModuleBusinessQueryField());
            }
            //工商查询列表
            $smarty->assign('MODULELISTBUS',1);
            if($businessinformationobj->IsEnableBusinessfuzzyquery()){
                $smarty->assign('MODULELISTBUS',0);
            }
        }else if($stype == 'detailview'){
            $focus = CRMEntity::getInstance($module);
            //zkt 20231024 BUG0073893 客户管理--工商查询功能应与角色的编辑权限挂钩，没有编辑权限应不显示工商查询按钮
            if(isPermitted($module,'EditView',$focus->id)=='yes'){
                if($businessinformationobj->IsEnableBusiness()){
                    $smarty->assign('BUSINESSQUERY',0);
                    $smarty->assign('BUSINESSQUERYFIELD',$businessinformationobj->getModuleBusinessQueryField());
                }
            }
        }
    }
}
?>