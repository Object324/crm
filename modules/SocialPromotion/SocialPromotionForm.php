<?php
/**
* @edit:dong
* @data:2020/7/8
* @reason: 社交推广 自定义字段 辅助类
* @description:
*/
class SocialPromotionForm
{
    public $fixedTableName = 'ld_socialpromotionformfixed';
    public $customTableName = 'ld_socialpromotionformcustom';
    public $currentModule;  //当前模块
    public $customFields; //所有自定义的字段
    public $moduleFields;  //所有自定义的字段按所属模块分类
    public $fixedTableFields;  //属于fixedTableName  的字段 用于插入或获取数据
    public $customTableFields;  //属于customTableName  的字段 用于插入或获取数据
    public $formCountNum;  //本表单 数据量
    public $adb ;

    public function  __construct($column_fields='')
    {
        global  $currentModule,$adb;
        $this->currentModule =$currentModule;
        $this->adb = $adb;
        if(!empty($column_fields)){
            $this->getCustomFields($column_fields);
            $this->getTableFields();
        }
    }

    /**
    * @edit:dong
    * @data:2020/7/10
    * @reason:把传入的单据值 进行重新格式化
    * @description:
    */
    public function getCustomFields($column_fields)
    {
        //获取自定义字段信息
        //crm外部调用 CRmEntity 类获取数据 json会被转义,系统内不会
        $customFields = json_decode(html_entity_decode($column_fields['customfieldsorder']),true);
        foreach ($customFields as $key=>$field){
            if($field['bigtype'] =='picklist' || $field['bigtype'] =='multipicklist'){
                $customFields[$key]['pickListValue'] = explode(';',$field['pickListValue']);
            }
        }
        $this->customFields = $customFields;
        return $customFields;
    }
    /**
    * @edit:dong
    * @data:2020/7/10
    * @reason: 把所有$_REQUEST的值和 字段数据对应起来
    * @description:
    */
    public function getTableFields()
    {
        $fixedTableFields = array();
        $customTableFields = array();
        foreach ($this->customFields as $key => $customField){
            $this->customFields[$key]['value'] = vtlib_purify($_REQUEST[$customField['columnname']]);
            // @edit:dong @date:2020/07/15 @reason: 多选字段转换格式
            if($customField['bigtype'] =='multipicklist'){
                $_REQUEST[$customField['columnname']]=str_replace(',',' |##| ',trim(vtlib_purify($_REQUEST[$customField['columnname']]),','));
            }

            if($customField['isfixedtable'] == 1){
                $customField['value'] = vtlib_purify($_REQUEST[$customField['columnname']]);
                $fixedTableFields[] =$customField;
            }else{
                $customField['value'] = vtlib_purify($_REQUEST[$customField['columnname']]);
                $customTableFields[] = $customField;
            }
        }
        $this->fixedTableFields =$fixedTableFields;
        $this->customTableFields =$customTableFields;
    }
    /**
    * @edit:dong
    * @data:2020/7/10
    * @reason: 制作插入 当前类表的sql语句
    * @description:
    */
    public function makeInstallSql($tableName,$fields,$before=array(),$after=array()){
        $insertKey = '';
        $insertValue = '';
        if(!empty($before)){
            foreach ($before as $key=>$value){
                $insertKey .=$key.',';
                $insertValue .='"'.$value.'"'.',';
            }
        }
        foreach ($fields as $key =>$field){
            $insertKey .= $field['columnname'].',';
            $insertValue .= '"'.$field['value'].'"'.',';
        }
        if(!empty($after)){
            foreach ($after as $key=>$value){
                $insertKey .=$key.',';
                $insertValue .='"'.$value.'"'.',';
            }
        }
        $insertKey =trim($insertKey,',');
        $insertValue =trim($insertValue,',');

        $sql = 'INSERT INTO '.$tableName;
        $sql .='('.$insertKey.')VALUES('.$insertValue.')';

        return $sql;
    }
    /**
    * @edit:dong
    * @data:2020/7/10
    * @reason:插入当前类的表的数据并返回插入id
    * @description:
    */
    public function insertTable($sql){
        $result = $this->adb->pquery($sql);
        $id = $this->adb->getLastInsertID();
        return $id;
    }

    /**
     * Name: 保存外部发送数据插入数据库 并插入的id
     * User: Dong
     * Date: 2020/7/7 15:58
     * @param $arr
     * @return mixed
     */
    public function save($arr){
            //保存表单数据 加入创建时间和修改时间
         $arr = array_merge($arr,array('createdtime'=>date('Y-m-d H:i:s'),'modifiedtime'=>date('Y-m-d H:i:s')));
         $sql = $this->makeInstallSql($this->fixedTableName,$this->fixedTableFields,$arr);
         $id = $this->insertTable($sql);
         //判断是自定义字段是否存在 存在这插入自定义字段表
         if(!empty($this->customTableFields)){
             $cusSql =$this->makeInstallSql($this->customTableName,$this->customTableFields,array('fixedid'=>$id));
             $this->insertTable($cusSql);
         }
         return $id;
    }

    /**
     * Name: 获取具有唯一性质的字段
     * User: Dong
     * Date: 2020/7/7 16:06
     * @return array
     */
    public function getOlnyFields()
    {
        $onlyFields = array();
        foreach ($this->customFields as $field){
            if(isset($field['only']) && $field['only']==1){
                $onlyFields[] = $field;
            }
        }
        return $onlyFields;
    }

    /**
     * Name: 获取Accountname字段
     * User: Dong
     * Date: 2020/7/7 16:06
     * @return array
     */
    public function getAccountNameField()
    {
        $arr = array();
        foreach ($this->customFields as $field){
            if($field['columnname']=='accountname'){
                $arr = $field;
                break;
            }
        }
        return $field;
    }
    /**
     * Name: 字段按照所属模块分类  针对的是默认数据
     * User: Dong
     * Date: 2020/7/7 17:21
     * @return array
     */
    public function classification(){
        $newArr =array();
        foreach ($this->customFields as $customField){
            $newArr[$customField['module']][] = $customField;
        }
        $this->moduleFields = $newArr;
        return $newArr;
    }

    /**
     * Name: 更新状态
     * User: Dong
     * Date: 2020/7/7 18:30
     * @param $id
     * @param $status
     * @param $statusMsg
     * @param $mappingmoduleid
     */
    public function updateStatus($id,$status,$statusMsg,$mappingmoduleid)
    {
        $sql = 'update '.$this->fixedTableName .' set status=? ,statusMsg= ?,mappingmoduleid=? where id =?';
        $this->adb->pquery($sql,array($status,$statusMsg,$id,json_encode($mappingmoduleid)));
    }

    // @edit:dong @date:2020/07/28 @reason: 获取单条 外部表单单据
    public function getFromSingle($id)
    {
        $fields = array();
        foreach ($this->customFields as $field){
            $fields[] = $field['columnname'];
        }
        $sql = 'select '.'id,socialpromotionid,userid,'.implode(',',$fields).' from '.$this->fixedTableName .' left join '.$this->customTableName .' on ' .$this->fixedTableName.'.id='.$this->customTableName.'.fixedid  where id =? ';
        $result = $this->adb->pquery($sql,array($id));
        return $result;
    }
    /**
    * @edit:dong
    * @data:2020/7/8
    * @reason:获取外部表格对应单据的所有数据
    * @description:
    */
    public function getFormList($userid,$record,$start=null,$length=''){
        global  $list_max_entries_per_page_new_more;
        if($length ==''){
            $length = $list_max_entries_per_page_new_more;
        }
        $fields = array();
        $returnArr=array();
        foreach ($this->customFields as $field){
            $fields[] = $field['columnname'];
        }
//        获取数据的时候添加查询字段 创建时间 和插入对应模块的id
        array_push($fields,'createdtime','mappingmoduleid','statusMsg');

        $sql = 'select '.'id,socialpromotionid,'.implode(',',$fields).' from '.$this->fixedTableName .' left join '.$this->customTableName .' on ' .$this->fixedTableName.'.id='.$this->customTableName.'.fixedid  where socialpromotionid =? ';
        if($userid){
            $sql .='and userid = '.$userid;
        }
        $sql .= ' order by id desc';
        if($start !== null && $length != ''){
            $sql.=" limit ".$start.",".$length." ";
        }

        $result = $this->adb->pquery($sql,array($record));
        $num_row = $this->adb->num_rows($result);
        //start为空这获取所有数据 保存数据总数
        if($start ==0){
            $this->formCountNum = $num_row;
        }
//        if($num_row >0){
//            while ($row = $this->adb->fetch_row($result)){
//                $returnArr[] = $row;
//            }
//        }
        return $result;
    }

    /**
    * @edit:dong
    * @data:2020/07/16
    * @reason:获取当前单据的负责人
    * @description:
    */
    public function getSmownerid($record)
    {
        //获取当前id的负责人
        $sql = 'select smownerid  from ld_socialpromotion where socialpromotionid=?';
        $result = $this->adb->pquery($sql,array($record));
        $smownerid = $this->adb->query_result($result,0,0);
        return $smownerid;
    }
    /**
    * @edit:dong
    * @data:2020/7/8
    * @reason: 详情页 detailview 中展示外部提交的数据
    * @description:modules\Users\setRelatedModList.php 中使用
    */
    public function get_SocialPromotionForm($currentModule,$record,$mappingmodule,$smcreatorid,$relationInfo)
    {
        global  $current_user;
        global $related_left_start;
        global $list_max_entries_per_page_new_more;

        $userid = $current_user->id;
        //获取列头
        $header=array();
        foreach ($this->customFields as $field){
            $header[] =$field['fieldlabel'];
        }
        // @edit:dong @date:2020/7/10 @reason: 添加更多默认列头
        $moreHeader = array(getFixedLabel('SOCIALPROMOTIONSUBTIME'),getFixedLabel('SOCIALPROMOTIONCORR').getTranstab($mappingmodule));
        if($mappingmodule == 'Accounts'){  //映射模块为Accounts时 增加对应的Contacts列头
            array_push($moreHeader,getFixedLabel('SOCIALPROMOTIONCORR').getTranstab('Contacts'));
        }
        array_push($moreHeader,getFixedLabel('SOCIALPROMOTIONENTRYSTATUS'));
//        所有列头数据
        $header = array_merge(array(getFixedLabel('SEQUENCE')),$header,$moreHeader);

//        获取当前表单的创建人
        //获取当前id的负责人
        $smownerid = $this->getSmownerid($record);
        //获取分页
        // @edit:dong @date:2020/07/14 @reason: 当前用户是创建人和负责人能看到所有信息
        if($userid == $smcreatorid || $userid == $smownerid){
            $this->getFormList('',$record);
        }else{
            $this->getFormList($userid,$record);
        }

        $noofrows=$this->formCountNum;
        if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
            $start = vtlib_purify($_REQUEST['start']);
            if($start == 'last'){
                if($noofrows > 0){
                    $start = ceil($noofrows/$list_max_entries_per_page_new_more);
                }
            }
            if(!is_numeric($start)) $start = 1;
            elseif($start < 1) $start = 1;
            $start = ceil($start);
        }else{
            $start = 1;
        }
        $related_left_start = $start;
        $limstart=($start-1)*$list_max_entries_per_page_new_more;
        // @edit:dong @date:2020/07/14 @reason: 当前用户是创建人和负责人能看到所有信息
        if($userid == $smcreatorid || $userid == $smownerid){
            $curResult = $this->getFormList('',$record,$limstart);
        }else{
            $curResult = $this->getFormList($userid,$record,$limstart);
        }

        $listNum=$this->adb->num_rows($curResult);

        if($listNum>0)
        {
            while ($row = $this->adb->fetch_row($curResult,true)){
                //过滤掉下标为数组的值 去重
                foreach ($row as $key =>$value){
                    if(is_numeric($key)){
                        unset($row[$key]);
                    }
                    if(!is_numeric($key) && strstr($value,'|##|')){
                        $value = str_replace('|##|',',',$value);
                        $row[$key]= $value;
                    }
                }
                //0047062:表单推广->相关信息->客户,内容过多显示为 … 时，鼠标移动到上面不能 tips 显示详细内容
                foreach($row as $key =>$value){
                    if($key!='mappingmoduleid')
                        $row[$key] = '<span title="'.$value.'">'.$value.'</span>';
                }
                //组合需要数据的样式
                $mappingModuleId = json_decode($row['mappingmoduleid']);
                unset($row['mappingmoduleid']);
                foreach ($mappingModuleId as $tempMappingModule =>$id){
                    if($id !=''){
                        //start 获取字段的对应模块的 需要显示的字段值
                        $mapFouce = CRMEntity::getInstance($tempMappingModule);
                        if($tempMappingModule == 'Contacts'){
                            $sqlFieldName ='lastname';
                        }else{
                            $sqlFieldName ='accountname';
                        }
                        $sql = "select  $sqlFieldName  from $mapFouce->table_name where $mapFouce->table_index = $id";
                        $result = $this->adb->pquery($sql, array());
                        $name= $this->adb->query_result($result,0,0);  //name为需要显示的值

                        $tmphtml='<a  class="" href="javascript:void(0);" module="'.$tempMappingModule.'" record="'.$id.'"  onclick="ListLinkClick(ld(this),event)"><span title="'.$name.'">'.$name.'</span></a>';
                    }else{
                        $tmphtml ='';
                    }
                    //赋值 组装数据
                    $row['mapping'.$tempMappingModule] =$tmphtml;
                }

//                调整录入情况的顺序 放到数组最后
                $statusMsg = $row['statusmsg'];
                unset($row['statusmsg']);
                unset($row['socialpromotionid']);
                $row['statusmsg']=$statusMsg;

                $rel_listentries[] =$row;
            }

        }

//        获取分页
        $navigationOutput = Array();
        $url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
        crm_load_function_file('getModuleFieldProportion','include/utils','ListViewUtils');
        $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
        $navigationOutput[] =  getRecordRangeMessage($curResult, $limstart,$noofrows);
        $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'',$record);

    //拖动显示 显示模块未激活
//        $total_width=0;
//        $sql='select * from ld_list_headerwidth where module=? and type=? and userid=? ';
//        $result=$this->adb->pquery($sql,array($currentModule,'SharedUsers',$userid));
//        $rows=$this->adb->num_rows($result);
//
//        if($rows >0)
//            for($i=0;$i<$rows;$i++)
//            {
//                $columns=$this->adb->query_result($result,$i,'columns');
//
//                $tmpwidth['fieldwidth'][$columns]=$adb->query_result($result,$i,'header_width').'setting';
//
//            }
//        $widthinfo=getModuleWidth("",$tmpwidth['fieldwidth'],$currentModule);
//        $tmpwidth['fieldwidth']=$widthinfo;
//
//        foreach($widthinfo as $tmp_width)
//        {
//            $total_width+=$tmp_width;
//        }
//
//end

//        35599: （1.6）单据明细界面>相关模块：共享人、修改日志增加拖动列宽功能，可以参照其他模块。（需要补丁）
        $tmp['headername']['columnname'][]='share1';
        $tmp['headername']['columnname'][]='share2';
        $tmp['headername']['columnname'][]='share3';

        $tmp['headername']['fieldname'][]='share1';
        $tmp['headername']['fieldname'][]='share2';
        $tmp['headername']['fieldname'][]='share3';

        $actions=$relationInfo['actions'];
        if($actions) {
            if(is_string($actions)) $actions = explode(',', strtoupper($actions));
            if(in_array('EXPORT', $actions) && (isPermitted($currentModule,"ExportRelated", '') == 'yes' || $current_user->is_admin=='on')) {
                $button .='<div id="categoryExport"><div style="padding-left:4px;padding-right:5px;">
                           <a href="javascript:void(0);" onclick="ExportSocialPromotion('.$record.')"><b class="categoryExport"></b>'.getFixedLabel('EXPORT').'</a>
                           </div></div>';
            }
        }
//        组装返回数组
        $return_value= array('CUSTOM_BUTTON'=>$button,'header'=>$header,'entries'=>$rel_listentries,
                             'headername'=>$tmp['headername'],'fieldwidth'=>$tmpwidth['fieldwidth'],
                             'total_width'=>$total_width,'navigation'=>$navigationOutput,'relcount'=>$noofrows,'noofrows'=>$noofrows);
        return $return_value;
    }


    /**
    * @edit:dong
    * @data:2020/07/15
    * @reason:获取统计数据的内容html 包括搜索条件和表单内容
    * @description: 用于setRelatedModList.php 中使用
    */
    public function getReportFormContent($smarty,$record,$focus,$startime='',$endtime='',$shareUserid='')
    {
        global $current_user;
        $mappingmodule = $focus->column_fields['mappingmodule'];
        $currentmodule = $focus->module_name;
        //获取筛选日期html
        $smarty->assign("NOW_DATE",date('Y-m-d'));
        $basicfilterHtml = $this->createTimeHtml();
        $smarty->assign('BASICFILTERHTML',$basicfilterHtml);

        //人员范围
        $MergeSmowner=getCurSmOwnerSearchScope($currentmodule);

        //灵当CRM详细需求-PC端-常用报表查看范围增加按部门选项
        $scopeobj = new ScopOfAuthority($this->adb,$currentmodule);
        //灵当CRM详细需求-PC端-常用报表查看范围增加按部门选项
        if($scopeobj->getUserModuleScoperType() > 0 || $current_user->is_admin == 'on'){
            $fieldlabel_group = getFixedLabel('SETBYDEPARTMENT');
            $MergeSmowner["OtherInfo"]['SmOwner_Search_Group'][$fieldlabel_group] = '';
        }
        unset($MergeSmowner['OtherInfo']['SmOwner_Search_Me']);
        unset($MergeSmowner['OtherInfo']['SmOwner_Search_Create']);
        unset($MergeSmowner['OtherInfo']['SmOwer_Search_ShareMe']);
        unset($MergeSmowner['OtherInfo']['SmOwer_Search_MeToShare']);

        //获取当前单据的所有分享人，创建人和负责人 作为查询条件
        $allUsers = $this->getRecordAllUsers($focus,$record);
        //end
//        过滤用户  部分用户没有查看权限。 因为本模块是分享的
        foreach ($MergeSmowner["UserCombo"] as $user =>$value){
            if(!in_array($user,$allUsers)){
                unset($MergeSmowner['UserCombo'][$user]);
            }
        }
        $smarty->assign('Merge_SmOwner',$MergeSmowner);
//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($MergeSmowner) > 0 && $currentModule != 'InventoryAccount' && $currentModule != 'InventoryQuery' && $currentModule != 'BankAccountSet' && $currentModule != 'Reminds'){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));


        //表头
        $colTitle =  $this->makeColTitle($mappingmodule);
        $smarty->assign('colTitle',$colTitle);

//        获取表单数据的内容
        $reportArr = $this->getReportFormListHtml($shareUserid,$record,$mappingmodule,$allUsers,$startime,$endtime);
        $smarty->assign('reportArr',$reportArr);
        $content = $smarty->fetch('modules/SocialPromotion/SocialReport.tpl');
        return $content;
    }

    /**
    * @edit:dong
    * @data:2020/07/17
    * @reason:制作内容表头
    * @description:
    */
    function makeColTitle($mappingmodule){
        if($mappingmodule == 'Accounts'){
            $colname = getFixedLabel('NUMBEROFACQUIRED');
        }else{
            $colname = getFixedLabel('NUMBEROFACQUIRED2');
        }
        $colTitle = array(getFixedLabel('MEMBER'),$colname,getFixedLabel('PREVIEWNUMBER'),getFixedLabel('CUSTOMERCONTRACTS'),getFixedLabel('TOTALCONTRACTAMOUNT'));
        return $colTitle;
    }

    /**
    * @edit:dong
    * @data:2020/07/16
    * @reason:报表上面的日期筛选html  本代码参考 newinde.php
    * @description:
    */
    function createTimeHtml(){
        $basicfilterHtml='';
        $basicfilterHtml.="<td width='100%' colspan='2'>";
        //本日，昨日，本周，本月，时间获取
        $todayselect=  date('Y-m-d',time());
        $yesterdayselect=  date("Y-m-d",time()-24*60*60);
        $week_begin =  date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+1,date("Y")));
        $week_end =  date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));
        $lastweeks=DateOperation::getlastweekrange($todayselect);
        $lastweekbegin=$lastweeks[0];
        $lastweekend=$lastweeks[sizeof($lastweeks)-1];

        //上月
        $time=strtotime(date('Y-m-d'));
        $last_month_begin=date('Y-m-01',strtotime(date('Y',$time).'-'.(date('m',$time)-1).'-01'));
        $last_month_end=date('Y-m-d',strtotime("$last_month_begin +1 month -1 day"));
        //本月
        $month_begin=date("Y-m-d",mktime(0, 0, 0,date("m"),1,date("Y")));
        $month_end = date("Y-m-d",mktime(23,59,59,date("m"),date("t"),date("Y")));
        //本年
        $begin_this_year=date('Y-01-01');
        $end_this_year=date('Y-12-31');
        $basicfilterHtml .="<a class='changeday' id='today' name='OftenUseReport_search' href=\"javascript:void(0);\" onclick=\"socialchangedaytime(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
                        <a id='yesterday' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"socialchangedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
                         <a id='lastweek' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"socialchangedaytime(this,'lastweek','$lastweekbegin','$lastweekend')\">".getFixedLabel('lastweek')."</a>
                        <a id='week' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"socialchangedaytime(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
						<a id='lastmonth' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"socialchangedaytime(this,'lastmonth','$last_month_begin','$last_month_end')\">".getFixedLabel('lastmonth')."</a>
                        <a id='month' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"socialchangedaytime(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
                        <a id='year' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"socialchangedaytime(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
                        <a id='all' name='OftenUseReport_search' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"socialchangedaytime(this,'all','2000-01-01','2050-12-31')\">".getFixedLabel('ALL')."</a>";

        $basicfilterHtml .="<span class='changeday colorLink' id='daterangepicker_search'>" .getFixedLabel('DATESELECTION')."&nbsp;</span>";
        $data_system = "width:180px;padding-left:3px;margin-top: -2px;margin-left: 5px;";
        $basicfilterHtml .= "<input class='borderALL btn-radius-system' type='text' readonly=true value='2000-01-01 - 2050-12-31' id='startmonth' name='startmonth' findcolumn= '' style='".$data_system."'/>";
        $basicfilterHtml.='</td>';
        return $basicfilterHtml;

    }
    /**
    * @edit:dong
    * @data:2020/07/17
    * @reason:获取当前单据的所有共享的和创建人和负责人id
    * @description:
    */
    function getRecordAllUsers($focus,$record){
        $smcreatorid = $focus->column_fields['smcreatorid'];
        $smownerid = $this->getSmownerid($record);
        crm_load_class_file('cls_share', 'include/Functions/Share');
        $objShare = new cls_share();
        $shareUsers = $objShare->getSelectedUser($record);
        // 创建人 负责人和 共享人 合并去重
        $allUsers = array_filter(array_unique(array_merge(array($smcreatorid), array($smownerid), explode(',', $shareUsers['userid']))));
        //        插入个空值
        array_unshift($allUsers,'');
        return $allUsers;
    }

    /**
    * @edit:dong
    * @data:2020/07/17
    * @reason: 报表主体的内容
    * @description:
    */
    function getReportFormListHtml($shareUserid,$record,$mappingmodule,$allUsers,$startime,$endtime){

        $reportArr =array();
        //        获取所有用户的客户数量
        $sql = 'SELECT count(1) as num,userid FROM ld_socialpromotionformfixed WHERE status= 1 and socialpromotionid = ? ';
        $sql .=$this->makeWhereTimeSql('createdtime',$startime,$endtime);
        if ($shareUserid != ''){
            $sql .= ' and userid in ('.implode(',',$shareUserid).') ';
        }
        $sql .= ' GROUP BY userid';
        $numResult = $this->adb->pquery($sql,array($record));
        $num_row = $this->adb->num_rows($numResult);
        $userAccountNum =array();
        if($num_row>0){
            while ($row = $this->adb->fetch_array($numResult)){
                $userAccountNum[] =$row;
            }
            $userAccountNum = array_column($userAccountNum,'num','userid');
        }

        //获取预览量
        $sql = 'SELECT count(1) as num,shareuserid FROM ld_socialpromotionformviewlist where socialpromotionid = ? ';
        $sql .=$this->makeWhereTimeSql('viewtime',$startime,$endtime);
        if ($shareUserid != ''){
            $sql .= ' and shareuserid in ('.implode(',',$shareUserid).') ';
        }
        $sql .= ' GROUP BY shareuserid';
        $numResult = $this->adb->pquery($sql,array($record));
        $num_row = $this->adb->num_rows($numResult);
        $userViewNum =array();
        if($num_row>0){
            while ($row = $this->adb->fetch_array($numResult)){
                $userViewNum[] =$row;
            }
            $userViewNum = array_column($userViewNum,'num','shareuserid');
        }

        if($shareUserid != ''){
            $allUsers =$shareUserid;
        }else{
            $allUsers = array_filter($allUsers);
        }
        // 获取货币符号
        require_once ('include/Currency/Currency.class.php');
        $cur = Currency::getInstance($this->adb);
        $Currencysymbol = $cur->getCurrencySymbol();

        foreach ($allUsers as $userid) {
            $userName = getUserFullName($userid);
            //  用户数量
            $accountNum = isset($userAccountNum[$userid])?$userAccountNum[$userid]:0;
            //预览数量
            $viewNum = isset($userViewNum[$userid])?$userViewNum[$userid]:0;
            //合同数量
            $ht_num = 0;
            //合同金额
            $price = 0;
            $mapsql = 'SELECT mappingmoduleid FROM ld_socialpromotionformfixed WHERE `status` =1 AND userid = ? AND socialpromotionid = ? ';
            $mapsql .=$this->makeWhereTimeSql('createdtime',$startime,$endtime);
            $mapResult = $this->adb->pquery($mapsql,array($userid,$record));
            $map_num = $this->adb->num_rows($mapResult);
            $accountIdArr = array();  //当前用户的当前活动的多有对应客户
            if($map_num>0){
                while ($row = $this->adb->fetch_row($mapResult)){
                    $row = json_decode($row['mappingmoduleid'],true);
                    $accountIdArr[] = $row[$mappingmodule];
                }
                $htsql = 'SELECT total from ld_salesorder where accountid in ';
                $htsql .= '('.implode(',',$accountIdArr).')';
                $htResult = $this->adb->pquery($htsql);
                $ht_num = $this->adb->num_rows($htResult);
                if($ht_num>0){
                    while($row =$this->adb->fetch_row($htResult)){
                        $price += $row['total'];
                    }
//                    组装前台金额显示格式
                    $price = $Currencysymbol.setNumberFormat($price);
                }
            }
            $reportArr[$userName] =compact('userName','accountNum','viewNum','ht_num','price');
        }
        return $reportArr;
    }

    /**
    * @edit:dong
    * @data:2020/07/17
    * @reason:通过时间制作sql的where条件
    * @description:
    */
    function makeWhereTimeSql($field,$startime,$endtime){
        $sql ='';
        if($startime != ''){
            $startime .= ' 0:0:0';
        }
        if($endtime != ''){
            $endtime .=' 23:59:59';
        }
        if($startime!= '' && $endtime ==''){
            $sql .= 'and '.$field.' > \''.$startime.'\'';
        }elseif ($startime == '' && $endtime !=''){
            $sql .= 'and  '.$field.' < \''.$startime.'\'';
        }elseif ($startime != '' && $endtime !=''){
            $sql  .= 'and '.$field.' BETWEEN  \''.$startime.'\' and \''.$endtime.'\'';
        }
        return $sql;
    }

    /**
    * @edit:dong
    * @data:2020/07/17
    * @reason:更新外部提交的单据的映射的客户模块的信息
    * @description: 有问题再优化  josn比较
     *            mysql关于json比较的文档 https://dev.mysql.com/doc/refman/5.7/en/json.html#json-comparison
    */
    function updateFromMappingmodule($leadid,$accountid){
        $sql = 'select id from ld_socialpromotionformfixed where mappingmoduleid = \'{"Leads":?}\'';
        $leadid = intval($leadid);
        $result = $this->adb->pquery($sql,array($leadid));
        if($this->adb->num_rows($result)){
            $formId = $this->adb->query_result($result,0,0);
            $updateSql = 'UPDATE ld_socialpromotionformfixed SET mappingmoduleid = ?  WHERE id = ? ';
            $mappingmoduleid = '{"Accounts":'.$accountid.'}';
            $this->adb->pquery($updateSql,array($mappingmoduleid,$formId));
        }
    }

    /**
     * @edit:wym
     * @data:2023/11/28
     * @reason:获取导出映射模块的表头标题信息
     * @description:XUQIU1002093 表单推广的映射模块，客户/销售线索的签到统计界面需要增加一个导出功能（刘明）
     */
    function get_SocialPromotionExport($currentModule,$record,$mappingmodule,$smcreatorid,$startexportrow,$eachexportcount)
    {
        global $current_user;
        $userid = $current_user->id;

        //获取列头
        $header=array();
        foreach ($this->customFields as $field){
            $header[] =$field['fieldlabel'];
        }
        $moreHeader = array(getFixedLabel('SOCIALPROMOTIONSUBTIME'),getFixedLabel('SOCIALPROMOTIONCORR').getTranstab($mappingmodule));
        if($mappingmodule == 'Accounts'){  //映射模块为Accounts时 增加对应的Contacts列头
            array_push($moreHeader,getFixedLabel('SOCIALPROMOTIONCORR').getTranstab('Contacts'));
        }
        array_push($moreHeader,getFixedLabel('SOCIALPROMOTIONENTRYSTATUS'));
        // 所有列头数据
        $header = array_merge(array(getFixedLabel('SEQUENCE')),$header,$moreHeader);

        //获取当前id的负责人,负责人能看到所有人数据
        $smownerid = $this->getSmownerid($record);
        if($userid == $smcreatorid || $userid == $smownerid){
            $curResult = $this->getFormList('',$record,$startexportrow,$eachexportcount);
        }else{
            $curResult = $this->getFormList($userid,$record,$startexportrow,$eachexportcount);
        }
        $endexportrow=(int)$startexportrow+(int)$eachexportcount;

        $listNum=$this->adb->num_rows($curResult);
        if($listNum>0)
        {
            while ($row = $this->adb->fetch_row($curResult,true)){
                //过滤掉下标为数组的值 去重
                foreach ($row as $key =>$value){
                    if(is_numeric($key)){
                        unset($row[$key]);
                    }
                    if(!is_numeric($key) && strstr($value,'|##|')){
                        $value = str_replace('|##|',',',$value);
                        $row[$key]= $value;
                    }
                }
                //组合需要数据的样式
                $mappingModuleId = json_decode($row['mappingmoduleid']);
                unset($row['mappingmoduleid']);
                foreach ($mappingModuleId as $tempMappingModule =>$id){
                    $name ='';
                    if($id !=''){
                        $mapFouce = CRMEntity::getInstance($tempMappingModule);
                        if($tempMappingModule == 'Contacts'){
                            $sqlFieldName ='lastname';
                        }else{
                            $sqlFieldName ='accountname';
                        }
                        $sql = "select  $sqlFieldName  from $mapFouce->table_name where $mapFouce->table_index = $id";
                        $result = $this->adb->pquery($sql, array());
                        $name= $this->adb->query_result($result,0,0);  //name为需要显示的值
                    }
                    //赋值 组装数据
                    $row['mapping'.$tempMappingModule] =$name;
                }
                //调整录入情况的顺序 放到数组最后
                $statusMsg = $row['statusmsg'];
                unset($row['statusmsg']);
                unset($row['socialpromotionid']);
                $row['statusmsg']=$statusMsg;
                $rel_listentries[] =$row;
            }
        }
        //组装返回数组
        $return_value= array('header'=>$header,'entries'=>$rel_listentries,'endexportrow'=>$endexportrow);
        return $return_value;
    }
}