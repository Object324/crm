<?php
/**
 * 更新操作
 * 操作人: gyq_09
 * 日期: 2016/4/6
 * 时间: 15:21
 * 说明: 派息规则处理类
 */

class DividendRules
{

    private static $_instance;   //单例存储对象
    private $dividend_rules;    //派息规则明细存储数组
    private $productid;         // 产品ID
    private $productidAll;         // 产品ID
    private $column_names;     // 派息规则表列名数组
    private $rules_exist;

    private function __construct($record)
    {
       $this->getProductid($record);
    }

//创建__clone方法防止对象被复制克隆
    public function __clone()
    {
        trigger_error('Clone is not allow!', E_USER_ERROR);
    }

//单例方法,用于访问实例的公共的静态方法
    public static function getInstance($record)
    {
        if (!(self::$_instance instanceof self)) {
            self::$_instance = new self($record);
        }
        return self::$_instance;
    }


    private function __get($name)
    {
        if ($name == 'dividend_rules') {
            return $this->getDividendRules();
        }
    }

    private function __set($name, $value)
    {

    }


    /* 派息规则入口，自动判断 */
    public function autoEnter()
    {
        $jump = false;
        /* 保存派息规则 */
      
        if ($_REQUEST['didvidendRules_save'] == 'save') {
            $jump = true;
            $this->saveDividendRules();
        }

        /* 派息规则弹框AJAX事件:派息方式 */
        
        if (strlen($_REQUEST['formulamode_ajax']) > 0) {
            $jump = true;
            $mode = vtlib_purify($_REQUEST['formulamode_ajax']);
            echo $this->get_formulamode($mode,'') . '$##$' . $this->get_grantdate($mode);
        }

        /* 派息规则弹框AJAX事件:派息日期或截止日期 */
        if (isset($_REQUEST['grantdate_ajax']) && $_REQUEST['grantdate_ajax'] != '' && isset($_REQUEST['deadline_ajax']) && $_REQUEST['deadline_ajax'] != '') {
            $jump = true;
            $grantdate = vtlib_purify($_REQUEST['grantdate_ajax']);
            $selectedval = vtlib_purify($_REQUEST['deadline_ajax']);
            echo $this->get_deadline($selectedval, $grantdate);
        }
        /* 合同订单创建派息单，派息规则弹框内容保存 */
        if(strlen($_REQUEST['serializeinfo']) > 0){
            $jump = true;
            $forminfo = $_REQUEST['serializeinfo'];
            $forminfoArr = json_decode($forminfo,true);

            foreach($forminfoArr as $key=>$val){

                $_REQUEST[$key] = $val;
            }
            $this->saveDividendRules();
        }

        if (!$jump) {

            $this->display();

        }
    }

    /* 显示弹框 */
    private function display()
    {
        global $adb;

        /* 初始化界面*/
        $smarty = new lingdangCRM_Smarty;

        if ($this->productid > 0) {

            /* 初始化产品名 */
            $query = "SELECT productname FROM ld_products WHERE productid=" . $this->productid;
            $result = $adb->pquery($query);
            $num_rows = $adb->num_rows($result);
            $productname = '';
            if ($num_rows > 0) {
                $productname = '-' . $adb->query_result($result, 0, 'productname');
            }
            $smarty->assign('PRODUCTNAME', $productname);
        }

        /*  判断当前用户有产品资料的“创建”权限 */
        $isper = isPermitted('Products','Create');

        if($isper == 'yes'){
            /* 获取派息规则明细，去掉位于数组首位的产品ID */
            $this->getDividendRules();
            $divRules_Arr = $this->dividend_rules;
          
            if($this->rules_exist){
                $titletext=getFixedLabel('EDIT');
            }else{
               $titletext=getFixedLabel('NEW');
            }

            $arrayValues = array_values($divRules_Arr);
            array_shift($arrayValues);

            $transStr = implode(',', $arrayValues);
             
            $smarty->assign('DIVIDENDRULESINFO', $transStr);

            /* 区分详情页和序时簿 */
            $smarty->assign('FROMVIEW', $_REQUEST['fromview']);

            if(!empty($this->productidAll)){
                $smarty->assign('RECORD', $this->productidAll);
            }else{
                $smarty->assign('RECORD', $_REQUEST['dividendrules_ids']);
            }

            /* deadline info */
            $smarty->assign('DEADLINEINFO', $this->get_deadline('',''));
            /* 发放日 */
             $smarty->assign('GRANTDATEINFO', $this->get_grantdate());
            /* 利息计算公式 */
            $smarty->assign('FORMULASINFO', $this->get_formulamode('',''));
        }else{
            $smarty->assign('TRAVELVIEWS', $this->travelDisplay());
            $smarty->assign('TREVALVIEWSMARK', 'travelview');
        }
        $titletext.=getFixedLabel('DIVIDENDRULES').$productname;
        $arr['oktext']=getFixedLabel("SAVE");
        $arr['canceltext']=getFixedLabel("CANCEL");
        $arr['title']=$titletext;
        $arr['content']=$smarty->fetch('modules/Products/DividendRules.tpl');
        $_REQUEST['diony']='diony';
        ConvertTojsonString(1,$arr,'success');
        
    }

    /* 当用户没有创建产品资料权限时，显示新界面 */
    private function travelDisplay(){

        /* 获取经翻译过的派息规则明细数组 */
        $rulesArr =  $this->getDividendRulesForSalesorder($this->getDividendRules());
        /* 利息计算方式 */
        $formulamode = $rulesArr['FORMULAMODE'];
        /* 本金计算方式 */
        $formulcaptial = $rulesArr['FORMULACAPITAL'];
        /* 新派息明细详情数组 */
        $rulesArrDetail = array();
        foreach($rulesArr as $key=>$val){

            /* 利息发放日 */
            if($key == 'INTERESTPAYMENTDATE'){

                $content = "<tr><td width=\"20%\" nowrap=\"nowrap\" align=\"right\">". getFixedLabel($key) ."</td>";
                /* 按月派息 */
                if($formulamode == 'DIVIDENDMONTHLY'){
                    $content .= "<td width=\"80%\"><span style='display: inline-block;width: 110px'>".getFixedLabel($rulesArr['grantdate_switch'])."</span><span>".$val."</span></tr>";
                    unset($rulesArr['grantdate_switch']);

                    /*指定派息日*/
                }elseif($formulamode == 'DIVIDENDDESIGN'){

                    $dateArrOld = explode('$##$',$val);
                    array_pop($dateArrOld);

                    $option = "<td><select>";
                    foreach($dateArrOld as $value){
                        $option .= "<option>$value</option>";
                    }
                    $content .= $option."</select></td></tr>";
                }else{
                    $contents = '';
                    $startdate = getFixedLabel('FORMULASTART');
                    $month = getFixedLabel('nMonth');
                    $day = getFixedLabel('Day');
                    /* 按季派息 */
                    if ($formulamode == 'DIVIDENDQUARTERLY') {
                        $contents .= "{$startdate}+{3*n$month}";
                        if($val == 2){
                            $contents .= "-{1$day}";
                        }
                       /* 隔月派息 */
                    }elseif($formulamode == 'DIVIDENDOTHERMONTHLY'){
                        $contents .= "{$startdate}+{1*n$month}";
                        if($val == 2){
                            $contents .= "-{1$day}";
                        }
                        /* 半年派息 */
                    } elseif($formulamode == 'DIVIDENDSEMIAN'){
                        $contents .= "{$startdate}+{6*n$month}";
                        if($val == 2){
                            $contents .= "-{1$day}";
                        }
                        /* 一次性派息 */
                    }elseif($formulamode == 'DIVIDENDONEOFF'){
                        if($formulcaptial == 'FORMULATOTAL'){
                            $contents .= getFixedLabel('DIVIDENDGRANTOFFONE');
                        }elseif($formulcaptial == 'FORMULAEVERYCONTRACT'){
                            $contents .= getFixedLabel('DIVIDENDGRANTOFFTWO');
                        }
                    }
                    $content .= "<td width=\"80%\"><span style='display: inline-block;'>".$contents."</span></tr>";
                }
                $rulesArrDetail[$key] = $content;
            }elseif($key == 'FORMULAFLOATINCOME'){
                $content = "<tr><td width=\"20%\" nowrap=\"nowrap\" align=\"right\">". getFixedLabel($key) ."</td><td width=\"80%\">></td></tr>";
                $content .= "<tr><td width=\"20%\" nowrap=\"nowrap\" align=\"right\">". getFixedLabel('FORMULASTART') ."</td>";
                $content .= "<td width=\"80%\">".$val['FORMULASTART']."</td></tr>";
                $content .= "<tr><td width=\"20%\" nowrap=\"nowrap\" align=\"right\">". getFixedLabel('FORMULAINCOMERATE') ."</td>";
                $content .= "<td width=\"80%\">".$val['FORMULAINCOMERATE']."</td></tr>";

                $rulesArrDetail[$key] = $content;
            }elseif($key == 'grantdate_switch'){
                continue;
            }
            else{
                if($key == "FORMULACAPITAL" || $key == "FORMULAMODE"){
                    $val = getFixedLabel($val);
                }
                $content = "<tr><td width=\"20%\" nowrap=\"nowrap\" align=\"right\">". getFixedLabel($key) ."</td>
            <td width=\"80%\">".$val;
                $content .= "</td></tr>";
                $rulesArrDetail[$key] = $content;
            }
        }


        $htmlbody = '';
        foreach($rulesArrDetail as $val){
            $htmlbody .= $val;
        }
        $html = "<table class=\"D_pop_bod\" cellspacing=\"1\" cellpadding=\"1\" border=\"0\">";
        $html .= $htmlbody;
        $html .= "</table>";

        return $html;
    }


    /* 获取派息规则明细数组 */
    private function getDividendRules()
    {
        if (empty($this->dividend_rules)) {
            global $adb;
            $query = "SELECT * FROM ld_dividend_rules WHERE productid=" . $this->productid . " limit 1";
            $result = $adb->pquery($query);
            $num_rows = $adb->num_rows($result);
            if ($num_rows > 0) {

                $this->rules_exist = true;

                foreach ($this->getColumnName('ld_dividend_rules') as $param) {

                    if($param == 'floatyield'){
                        $this->dividend_rules[$param] = round($adb->query_result($result, 0, $param),2);
                    }else{
                        $this->dividend_rules[$param] = $adb->query_result($result, 0, $param);
                    }

                }
            }
            return $this->dividend_rules;
        }
    }


    /* 合同订单创建派息单 翻译字段*/
    public function getDividendRulesForSalesorder($rules_arr)
    {
        if(count($rules_arr) > 0){
            $rules_Arr = array();
            foreach($rules_arr as $key => $val){
                switch($key){
                    case 'formulacapital':
                        $deskArr = array(
                            'totalsubscription'=>'FORMULATOTAL',
                            'everycontract'=>'FORMULAEVERYCONTRACT'
                        );
                        $rules_Arr['FORMULACAPITAL'] = $deskArr[$val];
                        break;
                    case 'formulamode':
                        $deskArr = array(
                            'monthly'=>'DIVIDENDMONTHLY',
                            'othermonth'=>'DIVIDENDOTHERMONTHLY',
                            'quarterly'=>'DIVIDENDQUARTERLY',
                            'semiannual'=>'DIVIDENDSEMIAN',
                            'oneoff'=>'DIVIDENDONEOFF',
                            'designated'=>'DIVIDENDDESIGN'
                        );
                        $rules_Arr['FORMULAMODE'] = $deskArr[$val];
                        break;

                    case 'deadline':
                        if(!empty($val)) {
                            $rules_Arr['FORMULADEADLINE'] = $val;
                        }
                        break;
                    case 'grantdate':
                        $rules_Arr['INTERESTPAYMENTDATE'] = $val;
                        break;
                    case 'grantdate_switch':
                        if(!empty($val)){
                            $deskArr = array(
                                'thismonth'=>'DATETHISMONTH',
                                'nextmonth'=>'DATENEXTMONTH'
                            );
                            $rules_Arr[$key] = $deskArr[$val];
                        }
                        break;

                    case 'grantdate_designated':
                        if(!empty($val)) {
                            $rules_Arr['INTERESTPAYMENTDATE'] = $val;
                        }
                        break;
                    case 'formulas':
                        $formulasinfo = $this->get_formulamode('',$val);
                        $rules_Arr['INTERESTSCALCULATIONFORMULA'] = $formulasinfo;
                        break;

                    case 'float_switch':
                        if($val == 'on'){
                            $rules_Arr['FORMULAFLOATINCOME'] = array();
                        }
                        break;
                    case 'floatstartdate':
                        if(is_array($rules_Arr['FORMULAFLOATINCOME'])){
                            $rules_Arr['FORMULAFLOATINCOME']['FORMULASTART'] = $val;
                        }
                        break;
                    case 'floatyield':
                        if(is_array($rules_Arr['FORMULAFLOATINCOME'])){
                            $rules_Arr['FORMULAFLOATINCOME']['FORMULAINCOMERATE'] = $val;
                        }
                        break;
                }
            }
        }

        return $rules_Arr;
    }

    /*获取产品ID */
    private function getProductid($outrecord)
    {

        /* 合同订单传递的产品 */
        if(!empty($outrecord)){
            $_REQUEST['dividendrules_ids'] = $outrecord;
        }
        /* 当前保存的产品ID或序时簿批量ID */
        $record = '';

        if($_REQUEST['dividendrules_ids']=='all'){
            $recordArr = getSelectedRecords($_REQUEST,'Products','all','');
            $this->productidAll = implode(',',$recordArr);

        }else{
            $recordArr = explode(';', $_REQUEST['dividendrules_ids']);
        }

        /* 批量处理派息规则，只选一条，取第一条进入编辑派息规则界面 */
        if (count($recordArr) > 0) {
            $record = $recordArr[0];

            if ($recordArr[1] > 0) {
                $record = '';
            }
        }

        /*
         * 当产品不同，则清空派息规则
         * */
        if (!empty($this->productid) && $this->productid != $record) {
            $this->productid = $record;
            $this->dividend_rules = array();
        } else {
            $this->productid = $record;
        }
    }




    /* 获取月结算截止日或按月派息利息发放日  grantdate monthly info*/
    private function get_deadline($selectedval = 15, $datetype)
    {

        if ($datetype == 'nextmonth') {
            $selectedval = 1;
            $default = 10;
        }
        $deadline[32] = getFixedLabel('ENDOFMONTH');
        for ($i = 28; $i >= $selectedval; $i--) {
            $deadline[$i] = $i;
        }

        $str = '';
        foreach ($deadline as $key => $val) {
            if (!empty($default) && $default == $key) {
                $str .= "<option value=$key title=$val selected>$val</option>";
            } else {
                $str .= "<option value=$key title=$val>$val</option>";
            }
        }

        return $str;
    }

    /* 获取利息计算公式 */
    private function get_formulamode($mode = 'monthly',$formulas)
    {

        global $adb;

        $search = array('/Capital/is', '/Rate/is', '/\(Days-1\)/is','/Days/is','/FullMonth30/is','/AcMonth/is');
        $replace = array(
            '{' . getFixedLabel('PRINCIPAL') . '}',
            '{' . getFixedLabel('FIXEDINCOMERATE') . '}',
            '{' . getFixedLabel('INTERESTSDAYS') . '-1}',
            '{' . getFixedLabel('INTERESTSDAYS') . '}',
            '{' . getFixedLabel('INTERESTSDAYS') .':'.getFixedLabel('FULLMONTH30') . '}',
            '{' . getFixedLabel('ACTUALDAYSOFMONTH') . '}'
        );
        if(!empty($formulas)){
            return preg_replace($search, $replace, $formulas);
        }else {


            $query = "SELECT formulamode,formulas from ld_dividend_rules_formulas WHERE formulamode='$mode'";
            $result = $adb->pquery($query);
            $num_rows = $adb->num_rows($result);
            if ($num_rows > 0) {
                $str = '';

                for ($i = 0; $i < $num_rows; $i++) {
                    $formulas = $adb->query_result($result, $i, 'formulas');

                    $formulasinfo = preg_replace($search, $replace, $formulas);

                    if ($mode == 'monthly' && $formulas == 'Capital*Rate*Days/360' ||
                        $mode == 'quarterly' && $formulas == 'Capital*Rate/4' ||
                        $mode == 'semiannual' && $formulas == 'Capital*Rate/2' ||
                        $mode == 'oneoff' && $formulas == 'Capital*Rate*Days/360' ||
                        $mode == 'designated' && $formulas == 'Capital*Rate*Days/360'
                    ) {
                        $selected = 'selected';
                    } else {
                        $selected = '';
                    }
                    $str .= "<option value='$formulas' $selected>$formulasinfo</option>";
                }

            }
            return $str;
        }

    }


    /* 获取利息发放日 */
    private function get_grantdate($mode = 'monthly')
    {

        $str = '';
        if ($mode == 'monthly') {
            $str = "<select name=\"grantdateleft\" style=\"width:200px;border:1px solid #dadada;\" onchange=\"Products_dividendRules.getInstance().grant_rate()\" >
                    <option value=\"thismonth\">" . getFixedLabel('DATETHISMONTH') . "</option>
                    <option value=\"nextmonth\">" . getFixedLabel('DATENEXTMONTH') . "</option>
                </select>
                <select name=\"grantdateright\" style=\"width:98px;border:1px solid #dadada;\" >
                   " . $this->get_deadline(30,'') . "
                </select>";
        } elseif ($mode == 'designated') {
            $str = "<div class=\"dividend_active_date\" style=\"float:left;margin-right:2px;width: 190px;height:30px \">
                    <input name=\"grantdateright\" class=\"Wdate\"   type=\"text\" style=\"border:1px solid #bababa;\"
                           fieldonly=\"0\" size=\"20\" maxlength=\"10\"  onclick=\"WdatePicker()\">
                    <a class=\"icon-homeimg icon-sdel\" href=\"javascript:;\" alt=\"删除\" onclick=\"Products_dividendRules.getInstance().delete_div(this);\" ></a>
                    <a class=\"icon-homeimg icon-select\" href=\"javascript:;\" alt=\"选择\" onclick=\"Products_dividendRules.getInstance().add_div(this);\"></a>
                </div>";
        } else {
            $startdate = getFixedLabel('FORMULASTART');
            $month = getFixedLabel('nMonth');
            $day = getFixedLabel('Day');
            $str = "<select name=\"grantdateright\" style=\"width:350px;border:1px solid #dadada;\" >";
            if ($mode == 'quarterly') {
                $str .= "<option value=\"1\">{$startdate}+{3*n$month}</option>
                    <option value=\"2\">{$startdate}+{3*n$month}-{1$day}</option>
                </select>";
            } elseif($mode == 'othermonth'){
                $str .= "<option value=\"1\">{$startdate}+{1*n$month}</option>
                    <option value=\"2\">{$startdate}+{1*n$month}-{1$day}</option>
                </select>";
            } elseif ($mode == 'semiannual') {
                $str .= "<option value=\"1\">{$startdate}+{6*n$month}</option>
                    <option value=\"2\">{$startdate}+{6*n$month}-{1$day}</option>
                </select>";
            } elseif ($mode == 'oneoff') {

                $str = "<select name=\"grantdateright\" style=\"width:350px;border:1px solid #dadada;display: none\" >";
                $str .= "<option value=\"totalsubscription\">" . getFixedLabel('DIVIDENDGRANTOFFONE') . "</option>
                    <option value=\"everycontract\">" . getFixedLabel('DIVIDENDGRANTOFFTWO') . "</option>
                </select><input type=\"text\" value='" .getFixedLabel('DIVIDENDGRANTOFFONE')."' style=\"border:1px solid #dadada;width: 350px\" disabled >";
            }

        }

        return $str;

    }

    /* 派息规则保存 */

    private function saveDividendRules()
    {

        global $adb;

        $records = vtlib_purify($_REQUEST['productids']);
        if(strpos(','.$records,';') > 0){
            $_records = trim(str_replace(';', ',', $records), ',');
        }else{
            $_records = $records;
        }

        /* 根据派息规则列名获取对应$_REQUEST值 */
       /* $query = "select COLUMN_NAME from information_schema.columns where table_name='ld_dividend_rules'";
        $result = $adb->pquery($query);
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {*/

        $_REQUEST['grantdate_switch'] = $_REQUEST['grantdateleft'];
        $_REQUEST['grantdate'] = $_REQUEST['grantdateright'];

        /* 指定派息日的内容存在grantdate_designated中 */
        if (vtlib_purify($_REQUEST['formulamode'] == 'designated')) {
            $_REQUEST['grantdate'] = null;


            $date = explode('$##$',rtrim($_REQUEST['grantdate_designated'],'$##$'));
            sort($date);
            $newDate = implode('$##$',$date);
            $_REQUEST['grantdate_designated'] = $newDate.'$##$';
        }
        if (vtlib_purify($_REQUEST['formulamode'] != 'monthly')) {
            $_REQUEST['grantdate_switch'] = '';
            $_REQUEST['deadline'] = null;
        }
        /* 一次性派息公式和本金计算方式是唯一对应关于，无需存入数据库 */
        if (vtlib_purify($_REQUEST['formulamode'] == 'oneoff')) {
            $_REQUEST['grantdate'] = null;
        }
        /* 异常情况处理，当选择当月派息，派息日异常小于截止日时，派息日默认为32 */
        if (vtlib_purify($_REQUEST['grantdate_switch'] == 'thismonth')) {
            if (vtlib_purify($_REQUEST['grantdate']) < vtlib_purify($_REQUEST['deadline'])) {
                $_REQUEST['grantdate'] = 32;
            }
        }

        $autoParams = array();
        /*for ($i = 1; $i < $num_rows; $i++) {

            $autoParams[] = vtlib_purify($_REQUEST[$adb->query_result($result, $i, 0)]);

        }*/

        $column_names = $this->getColumnName('ld_dividend_rules');
        print_r($column_names);
        foreach($column_names as $val){
            $autoParams[] = vtlib_purify($_REQUEST[$val]);
        }
        //}

        /* 初始化产品的派息规则 */
        $query = "delete FROM ld_dividend_rules WHERE productid in ($_records)";
        $adb->pquery($query);
       if($_REQUEST['recal_float_income']=='yes')//浮动收益重新计算
       {
            if($_REQUEST['float_switch']=='')
            {
                $_REQUEST['floatyield']=0;
                $_REQUEST['floatstartdate']='';
            }
            $sql=" UPDATE ld_salesorder 
                    INNER JOIN (select DISTINCT ld_salesorder.salesorderid from ld_salesorder INNER JOIN ld_salesorderdetail
                     on ld_salesorder.salesorderid=ld_salesorderdetail.id where productid in($_records)) as product_salesorder
                     on product_salesorder.salesorderid=ld_salesorder.salesorderid
                    set float_rate=?,float_start_date=? ";
            
            $adb->pquery($sql,array($_REQUEST['floatyield'],$_REQUEST['floatstartdate']));
            ////最好的方式用max(Enddate)
             if($_REQUEST['float_switch']=='')
            {
               
                $_REQUEST['floatstartdate']='1970-01-01';
            }
            
            if($_REQUEST['formulacapital']=='totalsubscription')//按已认购金额
            {
                $sql="update ld_dividendorder 
                      INNER JOIN
                    (select max(dividendorderid) as maxdividendorderid from ld_dividendorder  where product_id in($_records) GROUP BY accountid,product_id)
                    as dividendorder_salesorder on maxdividendorderid=ld_dividendorder.dividendorderid
                    set float_income =principal*datediff(enddate,?)*?/100,cashmoney=principal+rate_money+principal*datediff(enddate,?)*?/100 ";
            }
            else 
            {
                $sql="update ld_dividendorder 
                      INNER JOIN
                    (select max(dividendorderid) as maxdividendorderid from ld_dividendorder  where product_id in($_records) GROUP BY salesorderid)
                    as dividendorder_salesorder on maxdividendorderid=ld_dividendorder.dividendorderid
                    set float_income =principal*datediff(enddate,?)*?/100,cashmoney=principal+rate_money+principal*datediff(enddate,?)*?/100 ";
            }
           
           
            $adb->pquery($sql,array($_REQUEST['floatstartdate'],$_REQUEST['floatyield'],$_REQUEST['floatstartdate'],$_REQUEST['floatyield']));
                
       }
        
        $recordArr = explode(',', $_records);
 //print_r($autoParams);
        foreach ($recordArr as $_record) {

            if (empty($_record)) {
                continue;
            }

            $query = "insert into ld_dividend_rules(productid,formulacapital,formulamode,deadline,grantdate,grantdate_switch,grantdate_designated,formulas,float_switch,floatstartdate,floatyield)";
            $query .= " value(?,?,?,?,?,?,?,?,?,?,?)";

            $autoParams[0] = $_record;
          
            $adb->pquery($query, $autoParams);

        }
        /* 根据fromview分别跳转入序时簿或明细页,若不存在fromview则说明此时为合同订单派息规则保存事件 */
        if ($_REQUEST['fromview'] == 'listview') {
            //header("Location: index.php?action=index&module=Products&parenttab=Sales");
        } elseif ($_REQUEST['fromview'] == 'detailview') {
           //header("Location: index.php?action=DetailView&module=Products&record=" . $recordArr[0]);
        }
    }
    /* 获取列名 */
    private function getColumnName($tabname)
    {
        global $adb;
        if (empty($this->column_names)) {
            $queryCol = "select DISTINCT COLUMN_NAME from information_schema.columns where table_name= '" . $tabname . "'";
            $resultCol = $adb->pquery($queryCol);
            $num_rowsCol = $adb->num_rows($resultCol);
            $autoParams = array();
            for ($i = 1; $i < $num_rowsCol; $i++) {
                $autoParams[] = $adb->query_result($resultCol, $i, 0);
            }
            $this->column_names = $autoParams;
        }
        return $this->column_names;
    }

    /* 创建合同订单，若产品没有设置派息规则，给出提示 */
    public function Salesorder_DividendRules(){

        $dividend_rules = $this->getDividendRules();

        if(empty($dividend_rules)){
            /*  判断当前用户有产品资料的“创建”权限 */
            $isper = isPermitted('Products','Create');

            if($isper == 'yes'){
                $remind = getFixedLabel('TIPSFORSETDIDIDNEDRULES')."##NORULES##yes##NORULES##$this->productid".'##NORULES##'.getFixedLabel('LBL_Creates').getTranstab('DividendOrder');
            }else{
                $remind = getFixedLabel('TIPSFORASKDIDIDNEDRULES').'##NORULES##no'.getFixedLabel('LBL_Creates').getTranstab('DividendOrder');
            }
            echo $remind;
            exit;
        }else{
            $Dividend_rules_detail = $this->getDividendRulesForSalesorder($dividend_rules);
            return $Dividend_rules_detail;
        }
    }
}

