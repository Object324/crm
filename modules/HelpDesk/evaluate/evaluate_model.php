<?php
//editor:gyq_127 reason:服务小程序增加评价  2019/6/24 17:33
class evaluate_model
{
    public $module;
    public $option_list;
    public function __construct(){
        include_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/wx_config_const.php';
    }
    //editor:gyq_20191008 0038208: （:http://akjykj.vicp.cc:85/crm/ [^]）没有购买服务小程序，企业微信客户服务单应该不显示服务评价  2019/10/8 13:39
    public function detail_show_judge(){
        require_once globalStatic::$root_directory.'weixinmp/include/cls_MP_CommonFun.php';
        require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/wx_config_const.php';
        global $adb,$current_user;
        $mix_output = array();
        //服务小程序是否启用服务评价
        $sql  = 'select switch,para_one,para_two from ld_wx_config where name=?';
        $result = $adb->pquery($sql,array(wx_config_const::$helpdesk_evaluate));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0 && $adb->query_result($result,0,'switch')=='open' && cls_MP_CommonFun::check_self_help_reg('service')){
            return true;
        }
        return false;
    }
    //初始化下拉框可选项明细
    protected function init_option(){
        $list['five_star'] = array(1,2,3,4,5);
        $list['ten'] = array(1,2,3,4,5,6,7,8,9,10);
        $list['hundred'] = array(10,20,30,40,50,60,70,80,90,100);
        $list['satisfaction'] = array('十分满意','满意','不满意');
        foreach ($list as $key=>$content){
           foreach ($content as $key2=>$value){
               $list[$key][$key2] = array('text'=>$value,'value'=>$value);
           }
        }
        $this->option_list = $list;
    }
    //新增评价
    public function create_evaluate(){
        global $adb,$MobileLanguageType;
        $record = $_REQUEST['record'];
        $this->init_option();
        $output['module_title'] = getFuWuLabel('ServiceEvaluation');//服务评价
        $output['page_title'] = getFuWuLabel('ServiceEvaluation');
        $list = $this->get_setting_windows_content('create_evaluate');
        $field_list = array();
        $pi = 0;
        foreach ($list['field'] as $key=>$value){
            $option_name = $list['optionid_list'][$value['option_value']]['name'];
            if(array_key_exists($option_name,$this->option_list)){
                if($option_name=='five_star'){
                    $field_type = $option_name;
                }else{
                    $field_type = 4;
                }
                $field_list[$pi] = array(
                    'fieldname'=>$value['field_value'],
                    'fieldlabel'=>$MobileLanguageType=='en'?$value['field_text_en']:$value['field_text'],
                    'value'=>'',
                    'text'=>'',
                    'type'=>$field_type,
                    'option'=>$this->option_list[$option_name] /*,
                    'optionid'=>array(
                        'fieldname'=>$value['field_value'].'__'.$option_name,
                        'value'=>$value['option_value'])*/
                );
            }elseif($option_name=='input'){
                $field_list[$pi] = array(
                    'fieldname'=>$value['field_value'],
                    'fieldlabel'=>$MobileLanguageType=='en'?$value['field_text_en']:$value['field_text'],
                    'value'=>'',
                    'text'=>'',
                    'type'=>1
                );
            }elseif($option_name=='text'){
                $field_list[$pi] = array(
                    'fieldname'=>$value['field_value'],
                    'fieldlabel'=>$MobileLanguageType=='en'?$value['field_text_en']:$value['field_text'],
                    'value'=>'',
                    'text'=>'',
                    'type'=>5
                );
            }elseif($option_name=='file'){
                $field_list[$pi] = array(
                    'fieldname'=>$value['field_value'],
                    'fieldlabel'=>$MobileLanguageType=='en'?$value['field_text_en']:$value['field_text'],
                    'value'=>'',
                    'text'=>'',
                    'type'=>1109
                );
            }
            $pi++;
        }
        $output['list'][0] = array(
            'blocklabel'=>getFuWuLabel('ServiceEvaluation'),
            'display_status'=>1,
            'fieldinfo'=>$field_list
        );
        ConvertTojsonString(1,$output,'success');
    }
    //评价保存
    public function save(){
        if(!empty($_REQUEST['wx_fieldInfo'])) {
            foreach ($_REQUEST['wx_fieldInfo'] as $key=>$val) {
                $_REQUEST[$key] = $val;
            }
        }
        $record = $_REQUEST['record'];
        global $adb;
        $sql  = 'select id,columname,zh_label,optionid,presence from ld_wx_evaluate_field order by sequence asc';
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        //editor:20190930 0037858: 服务小程序，服务评价保存，没有评价时间。
        $time = date('Y-m-d H:i:s',time());
        for($i=0;$i<$num_rows;$i++) {
            $columname = $adb->query_result($result, $i, 'columname');
            $fieldid = $adb->query_result($result, $i, 'id');
            if(isset($_REQUEST[$columname])&&!empty($_REQUEST[$columname])){
                $sql = 'insert into ld_wx_evaluate_content(record, fieldid, content,create_time) value (?,?,?,?)';
                $adb->pquery($sql,array($record,$fieldid,$_REQUEST[$columname],$time));
            }
        }
        ConvertTojsonString(1,array(),'success');
    }
    //获取明细界面内容
    public function get_detail(){
        global $current_user,$adb,$weixin_user;
        $list = $this->init_detail_info();
        $output = array();
        if($weixin_user->environment_weixin){
            $output['blocklabel'] = getFuWuLabel('ServiceEvaluation');
            $output['display_status'] =1;
            foreach ($list as $key=>$value){
                $fieldinfo[$key]['fieldlabel'] = $value['label'];
                $fieldinfo[$key]['fieldname'] = $value['name'];
                $fieldinfo[$key]['text'] = $value['text'];
                if($value['op_name']=='five_star'){
                    $fieldinfo[$key]['type'] = 'five_star';
                }else{
                    $fieldinfo[$key]['type'] = 4;
                }
                $fieldinfo[$key]['typeofdata'] = 'V~M';
            }
            $output['fieldinfo'] = $fieldinfo;
            return $output;
        }else{
            $this->get_detail_html($list);
        }
    }
    //PC端详情显示
    public function get_detail_html($list){
        global $app_strings, $mod_strings, $theme;
        $star = array('1'=>'☆','2'=>'☆☆','3'=>'☆☆☆','4'=>'☆☆☆☆','5'=>'☆☆☆☆☆');
        $smarty = new lingdangCRM_Smarty();
        $table = '<table border="0" cellspacing="1" cellpadding="0" width="100%" class="DetailContentTable">';
        if(!empty($list)){
            //内容
            foreach($list as $key=>$content){
                if($content['op_name1']=='five_star'){
                    $content['text1'] = $star[$content['text1']];
                }
                if($content['op_name2']=='five_star'){
                    $content['text2'] = $star[$content['text2']];
                }
                $table .='<tr bgcolor="white">';
                $table .='<td class="DetailedTd1Label" width="20%" align="right"><span>' . $content['label1'] .'</span></td>';
                $table .='<td width="30%" class="DetailedTd2Info" align="left"><span>' . $content['text1'] .'</span></td>';
                $table .='<td class="DetailedTd1Label" width="20%" align="right"><span>' . $content['label2'] .'</span></td>';
                $table .='<td width="30%" class="DetailedTd2Info" align="left"><span>' . $content['text2'] .'</span></td>';
                $table .='</tr>';
            }
        }
        $table .='</table>';
        $smarty->assign('TABLE',$table);
        $smarty->display('modules/lingdang/evaluate_detail.tpl');
        exit();
    }

    //获取明细界面评价内容
    public function init_detail_info(){
        $record = $_REQUEST['record'];
        global $adb,$weixin_user,$MobileLanguageType;
        //editor:gyq_20190708 reason:没值的字段也要现实出来 0037456: （落落计划）企业微信>灵当CRM>客户服务单模块明细界面：
        //详情和日志显示空白，微信小程序也存在问题（需要补丁）（邱：明细界面服务评价区块返回有问题，返回为空）
        if(!empty($record)){
            $sql  = 'select fie.id,con.content,fie.zh_label,fie.en_label,fie.columname fi_name,opt.columname op_name from ld_wx_evaluate_field fie
          left join (select content,fieldid from ld_wx_evaluate_content where record=?) as con on con.fieldid=fie.id
          left join ld_wx_evaluate_option opt on opt.id=fie.optionid
        where  fie.presence=\'yes\'';
            $result = $adb->pquery($sql,array($record));
        }else{
            $sql = 'select fie.id,\'\' as content,fie.zh_label,fie.en_label,fie.columname fi_name,opt.columname op_name from ld_wx_evaluate_field fie
  left join ld_wx_evaluate_option opt on opt.id=fie.optionid
where  fie.presence=\'yes\'';
            $result = $adb->pquery($sql,array());
        }
        $num_rows = $adb->num_rows($result);
        $list = array();
        if($weixin_user->environment_weixin){
            for($i=0;$i<$num_rows;$i++) {
//                $field_label = $adb->query_result($result, $i, 'zh_label');
                $field_label = $MobileLanguageType=='en'?$adb->query_result($result, $i, 'en_label'):$adb->query_result($result, $i, 'zh_label');
                $field_value = $adb->query_result($result, $i, 'content');
                $columname = $adb->query_result($result, $i, 'fi_name');
                $op_name = $adb->query_result($result, $i, 'op_name');
                $list[$i]['label'] = $field_label;
                $list[$i]['text'] = $field_value;
                $list[$i]['name'] = $columname;
                $list[$i]['op_name'] = $op_name;
            }
        }else{
            $pi = 0;
            for($i=0;$i<$num_rows;$i++) {
                $field_label = $adb->query_result($result, $i, 'zh_label');
                $field_value = $adb->query_result($result, $i, 'content');
                $op_name = $adb->query_result($result, $i, 'op_name');
                if($i%2==0){
                    $list[$pi]['label1'] = $field_label;
                    $list[$pi]['text1'] = $field_value;
                    $list[$pi]['op_name1'] = $op_name;
                    $list[$pi]['label2'] = '';
                    $list[$pi]['text2'] = '';
                }else{
                    $list[$pi]['label2'] = $field_label;
                    $list[$pi]['text2'] = $field_value;
                    $list[$pi]['op_name2'] = $op_name;
                    $pi++;
                }
            }
        }
        return $list;
    }
    //获取策略设置界面
    public function get_setting_windows(){
        $this->module = $_REQUEST['module'] ;
        global $adb,$current_user;
        $title = array(getFixedLabel('WHETHERTOENABLE'),getFixedLabel('CNTAG'),getFixedLabel('ENTAG'),getFixedLabel('INPUTMODE'));
        $smarty = new lingdangCRM_Smarty();
        $content = $this->get_setting_windows_content('');
        $smarty->assign('TITLE', $title);
        $smarty->assign('MAIN', $content['field']);
        $smarty->assign('OPTION', $content['option']);
        $smarty->assign('SWITCH', $content['switch']);
        $smarty->assign('MODULE', $this->module);
        $adv_value = '';
        if(!empty($content['para_one'])){
            $adv_content = json_decode( $content['para_one'],true);
            $adv_value = $adv_content[0]['value'];
            $columnname_con = explode(':',$adv_content[0]['columnname']) ;
            $_REQUEST['evaluate_advance_search_field_selected'] = $columnname_con[0].':'. $columnname_con[1].':'.$columnname_con[2];
        }
        //reason:仅显示下拉框字段  2019/6/27 11:56 ID1000419
        $_REQUEST['evaluate_advance_search_permit_uitype'] = array(16,117,15);
        $customView = CustomView::getInstance($this->module);
        $queryGenerator =  QueryGenerator::getInstance($this->module, $current_user,$customView);
        $controller = new ListViewController($adb, $current_user, $queryGenerator);
        $fieldnames = $controller->getAdvancedSearchOptionString();
        $smarty->assign("FIELDNAMES", $fieldnames);
        $smarty->assign("ADVVALUE", $adv_value);

        $_REQUEST['diony']='diony';
        $arr['title']=getFixedLabel("EVALUATESETTING");
        $arr['oktext']=getFixedLabel("SAVE");
        $arr['canceltext']=getFixedLabel("CANCEL");
        $str=$smarty->fetch("modules/HelpDesk/evaluate/setting_windows.tpl");
        $arr['content']=$str;
        ConvertTojsonString(1,$arr,"success");
    }
    //获取策略设置界面
    public function get_setting_windows_content($r_type){
        require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/wx_config_const.php';
        global $adb,$current_user;
        $mix_output = array();
        //服务小程序是否启用服务评价
        $sql  = 'select switch,para_one,para_two from ld_wx_config where name=?';
        $result = $adb->pquery($sql,array(wx_config_const::$helpdesk_evaluate));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            $mix_output['switch'] = $adb->query_result($result,0,'switch');
            $mix_output['para_one'] = $adb->query_result($result,0,'para_one');
        }else{
            return false;
        }
        //录入方式
        $sql  = 'select id,columname,zh_label from ld_wx_evaluate_option order by sequence asc';
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        $option_content = array();
        $first_option_id = 0;
        for($i=0;$i<$num_rows;$i++) {
            $columname = $adb->query_result($result, $i, 'columname');
            $zh_label = $adb->query_result($result, $i, 'zh_label');
            $optionid = $adb->query_result($result, $i, 'id');
            if($first_option_id <= 0){
                $first_option_id = $optionid;
            }
            $option_content[$i] = array('text' => $zh_label, 'value' => $optionid,'name'=>$columname);
            $option_content2[$optionid] = array('text' => $zh_label, 'value' => $optionid,'name'=>$columname);
        }
        $mix_output['option'] = $option_content;
        $mix_output['optionid_list'] = $option_content2;
        //标签名称
        //liushuai 20230518 XUQIU1001398 服务小程序，增加英文版(PC端服务评价设置及小程序新增评价页面都会调用)
        if($r_type=='create_evaluate'){
            $sql  = 'select columname,zh_label,en_label,optionid,presence from ld_wx_evaluate_field where presence=\'yes\' order by sequence asc';
        }else{
            $sql  = 'select columname,zh_label,en_label,optionid,presence from ld_wx_evaluate_field order by sequence asc';
        }
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        $field_content = array();
        for($i=0;$i<$num_rows;$i++) {
            $columname = $adb->query_result($result, $i, 'columname');
            $zh_label = $adb->query_result($result, $i, 'zh_label');
            $en_label = $adb->query_result($result, $i, 'en_label');
            $optionid = $adb->query_result($result, $i, 'optionid');
            $presence = $adb->query_result($result, $i, 'presence');
            if(empty($optionid)||$optionid < 1)
                $optionid = $first_option_id;
            $field_content[$i] = array(
                'presence'=>$presence,'field_text' => $zh_label,'field_text_en' => $en_label, 'field_value' => $columname,
                'option_value'=>$optionid
            );
        }
        $mix_output['field'] = $field_content;

        return $mix_output;
    }
    //价格策略设置界面保存
    public function save_setting(){
        $_REQUEST['diony'] = 'yes';
        global $adb;
        //保存字段
        $sql  = 'select id,columname,zh_label,optionid,presence from ld_wx_evaluate_field order by sequence asc';
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        for($i=0;$i<$num_rows;$i++) {
            $presence = 'no';
            $optionid = 0;
            $en_label = '';
            $columname = $adb->query_result($result, $i, 'columname');
            $fieldid = $adb->query_result($result, $i, 'id');
            if(isset($_REQUEST[$columname])&&!empty($_REQUEST[$columname])){
                if(isset($_REQUEST[$columname.'__presence'])&&$_REQUEST[$columname.'__presence']=='on'){
                    $presence=  'yes';
                }
                if(isset($_REQUEST[$columname.'__optionid'])){
                    $optionid= $_REQUEST[$columname.'__optionid'];
                }
                if(isset($_REQUEST[$columname.'__en'])){
                    $en_label=trim($_REQUEST[$columname.'__en']);
                }
                $sql = 'update ld_wx_evaluate_field set presence=?,optionid=?,zh_label=?,en_label=? where id=?';
                $adb->pquery($sql,array($presence,$optionid,$_REQUEST[$columname],$en_label,$fieldid));
            }
        }
        //保存开关
        $sql_switch = 'update ld_wx_config set switch=? where name=?';
        if($_REQUEST['switch']=='on'){
            $adb->pquery($sql_switch,array('open',wx_config_const::$helpdesk_evaluate));
        }else{
            $adb->pquery($sql_switch,array('close',wx_config_const::$helpdesk_evaluate));
        }
        //保存高级查找
        if(!empty($_REQUEST['adv_name'])&&!empty($_REQUEST['adv_value'])){
            $adv_name = str_replace('\\\'','',$_REQUEST['adv_name']);
            $para_one = '[{"groupid":"1","columnname":"'.$adv_name.'","comparator":"e","value":"'.$_REQUEST['adv_value'].'","columncondition":""}]';
            $para_two = '[null,{"groupcondition":""}]';
            $sql = 'update ld_wx_config set para_one=?,para_two=? where name=?';
            $adb->pquery($sql,array($para_one,$para_two,wx_config_const::$helpdesk_evaluate));
        }else{
            $sql = 'update ld_wx_config set para_one=?,para_two=? where name=?';
            $adb->pquery($sql,array('','',wx_config_const::$helpdesk_evaluate));
        }
        ConvertTojsonString(1,array(),'success');
    }
}