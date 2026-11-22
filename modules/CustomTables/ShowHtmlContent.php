<?php

include_once globalStatic::$root_directory.'modules/CustomTables/StyleSet.php';
class ShowHtmlContent
{
    public $detailviewobj;
    public $StyleSetObj;
    public $quantity_decimal;
    public $amount_decimal;
    public $pagenum;
    public $mergeRowInfo;
    public $isexport;
    public $allmergecolumnvalue_arr = [];
    public function __construct($detailviewobj)
    {
        $this->detailviewobj=$detailviewobj;
        $this->StyleSetObj=new StyleSet();
         //小数位数
        $deploy = getSys_deploy(49);
        $this->quantity_decimal = $deploy['deploy_value'];
        $deploy = getSys_deploy(93);
        //设置单据分录明细中单价字段小数位数。
        $this->amount_decimal = $deploy['deploy_value'];
    }
    public function setPageNum($pagenum)
    {
        $this->pagenum=$pagenum;
        if(empty($this->pagenum))
        {
            $this->pagenum=1;

        }
    }
    public function setExport($export)
    {
        $this->isexport=$export;
    }
    //所有行的合并列数据
    public function getMergeColumnValueArr(){
        return $this->allmergecolumnvalue_arr;
    }
    public function getContent($result)
    {
        $quantity_decimal=$this->quantity_decimal;
        $amount_decimal=$this->amount_decimal;
        $detailviewobj=$this->detailviewobj;
        global $adb;
        $frommobile = $_REQUEST['frommobile'];
        $mergecolumnvalue_arr=[];
        $allmergecolumnvalue_arr=[];//所有行的合并列数据
        $html_arr=[];
        $data_arr=[];//数据  不是html的
        $htmltd_arr=[];
        $html = '';
        $pagetotal='';
        $res=$result;
        $nums=$adb->num_rows($res);
        $userinfo_arr=[];
        $computerText_arr=[];
        $computerFunName=[];
        foreach($this->detailviewobj->computerfunText_arr as $fun=>$text)
        {
            $computerText_arr[]=$text;
        }
        foreach($this->detailviewobj->computerfunText_arr as $fun=>$text)
        {
            $computerFunName[$text]=$fun;
        }
        $prevdetail_i=0;
        $prevdetailvalue_arr=[];
        //$start=($this->pagenum-1)*$this->detailviewobj->limit;
        $start = 0;
        $enddata=$start+$this->detailviewobj->limit;
        $reference_arr=[];
        $mergeRowInfo = [];

        $groupInfo_arr=[];
        foreach($this->detailviewobj->groupcolumn_arr as $tmpkey=>$tmpcolumninfo) {
            $tmp_arr= explode(":",$tmpcolumninfo);
            $groupInfo_arr[]=$tmp_arr[0].$this->detailviewobj->asfixedname.$tmp_arr[1];
        }

        for($i=$start;$i<$enddata&&$i<$nums;$i++){
            $temp_type = $adb->query_result($res,$i,"type");
            $type_desc=$adb->query_result($res,$i,'type_desc');
            if($type_desc!='detail')
            {

            }else{
                $prevdetail_i=$i;
            }
            //小计行 且不显示明细的时候  显示不同颜色
            $show_detail = $_REQUEST['show_detail'];//on
            $tdbgcolor = '';
            //小计行 且不显示明细的时候  显示不同颜色
            if(!empty($show_detail)||$show_detail=="on"){
                $tdbgcolor = $this->detailviewobj->computerfunColor_arr[$type_desc];
                $tdbgcolor = "background-color:".$tdbgcolor;
            }
            $trclass = '';
            if($i%2==0){
                $trclass = 'lvtColData';
            }else{
                $trclass = 'lvtColDataBj';
            }

            if($temp_type==$this->detailviewobj->total_typenumber){
                //所有合计
                $html_arr[$i]= '<tr rowindex="'.$i.'" style="background-color: #E1E4E6">';
            }else{
                $html_arr[$i]= '<tr class="'.$trclass.'" rowindex="'.$i.'" style="'.$tdbgcolor.'">';
            }


            foreach($this->detailviewobj->fieldsTableHeader as $k=>$v){
                $valueFormat = $this->detailviewobj->column_arr[$k]['value_format'];
                $bigtype = $this->detailviewobj->column_arr[$k]['bigtype']??'';


                $tempvalue = $adb->query_result($res,$i,$v);

                $temptitle = '';
                $data_arr[$i][$k] = $tempvalue;
                $type_desc=$adb->query_result($res,$i,'type_desc');

                $columnmodule=$this->detailviewobj->column_arr[$k]['columnmodule'];
                $tmpfocus = CRMEntity::getInstance($columnmodule);
                //获取模块超链接字段
                $entitynameinfo = getEntitynameInfo(getTabid($columnmodule));
                $entityfieldname = $entitynameinfo['fieldname'];

                $columns=$this->detailviewobj->column_arr[$k]['columns'];
                $temp_columns_arr = explode(':',$columns);
                $columnname = $temp_columns_arr[1];
                $uitype=$this->detailviewobj->column_arr[$k]['uitype'];
                $fieldtype=$this->detailviewobj->column_arr[$k]['fieldtype'];
                $isdetailfield=$this->detailviewobj->column_arr[$k]['isdetailfield'];
                $typeofdata = $this->detailviewobj->column_arr[$k]['typeofdata'];
                $merge=$this->detailviewobj->column_arr[$k]['merge'];
                //if($this->isexport)$merge = "no";
                $is_group=$this->detailviewobj->column_arr[$k]['is_group'];//是否是分组字段
                $total_type=$this->detailviewobj->column_arr[$k]['total_type'];
                $total_type_arr=explode(",",$total_type);
                $align = $this->detailviewobj->column_arr[$k]['align'];
                $prefix=$this->detailviewobj->column_arr[$k]['prefix'];//前缀
                $suffix=$this->detailviewobj->column_arr[$k]['suffix'];//后缀
                $decimal_places = $this->detailviewobj->column_arr[$k]['decimal_places'];//小数位数
                $issticky = $this->detailviewobj->column_arr[$k]['issticky'];

                //zkt 20221109 XUQIU1000804 单据头和单据分录“金额货币”类型的字段允许自定义小数位数
                //hzx 2023-11-14 BUG0075471 销售合同分录里的总吨位数字段是3位小数，报表中取过来的字段只能是2位小数（销售往来明细表）
                //$typeofdata_decimal=2;//获取typeofdata中的小数位数
                //单据头和单据分录“金额货币”类型字段根据typeofdata取值，其他的仍默认为2
                if(!is_numeric($typeofdata_decimal)){
                    $typeofdata_decimal = $this->quantity_decimal;
                }
                $typeofdatas = explode(',', $typeofdata);
                if(sizeof($typeofdatas)>1)
                {
                    $typeofdata_decimal=$typeofdatas[1];
                }


                $iscomputerfield='no';
                //源单类型翻译
                if($columnname=="entitytype"){
                    $tempvalue = getTranstab($tempvalue);
                }
                if($columnname=="source_list"||$columnname=="entitytypeid"||$bigtype=='selectsource'){
                    $tempvalue = $this->getSourceListNumber($tempvalue);
                }

                if($type_desc!='detail')//小计行
                {
                    if(array_key_exists($tempvalue,$computerFunName)&&in_array($v,$groupInfo_arr))
                    {
                        //统计字段
                        $iscomputerfield='yes';
                    }

                    if($iscomputerfield=='yes')
                    {

                        if($bigtype=='users'||$bigtype=='selectoneuser')
                        {
                            $tempvalue=$userinfo_arr[$adb->query_result($res,$prevdetail_i,$this->detailviewobj->fieldsTableHeader[$k])].$tempvalue;
                        }
                        else if($bigtype=='reference'||$bigtype=='multireference')
                        {
                            $tempvalue=$reference_arr[$adb->query_result($res,$prevdetail_i,$this->detailviewobj->fieldsTableHeader[$k])].$tempvalue;
                        }
                        else
                            $tempvalue=$adb->query_result($res,$prevdetail_i,$this->detailviewobj->fieldsTableHeader[$k]).$tempvalue;//考虑引用字段
                        if(empty($tempvalue))
                            $tempvalue='--';
                        unset($prevdetailvalue_arr[$prevdetail_i]);
                    }
                    else if($k==0&&in_array($type_desc,$this->detailviewobj->firstrColumnComputer_type))
                    {
                        $tempvalue=$this->detailviewobj->computerfunText_arr[$type_desc].$tempvalue;
                    }
                }
                //if($merge=='yes'&&$type_desc=='detail')//合并列
                $mergecolumn_arr = [];
                if(strpos($merge,':')!==false && $type_desc=='detail')//合并列
                {
                    $mergecolumn_arr = explode(':',$merge);
                    $merge_columnsalias = $mergecolumn_arr[0].$this->detailviewobj->asfixedname.$mergecolumn_arr[1];
                    $merge_columnsvalue = $adb->query_result($res,$i,$merge_columnsalias);//合并标签字段的值

                    //$tmpcurcolumntablename = $temp_columns_arr[0];//合并标签字段的表名

                    //导出的合并在导出的时候再处理
                    if($this->isexport){
                        $allmergecolumnvalue_arr[$i][$v] = $merge_columnsvalue;
                    }else {
                        if (!array_key_exists($v, $mergecolumnvalue_arr)) {
                            $mergecolumnvalue_arr[$v] = array("value" => $merge_columnsvalue,'curvalue'=>$tempvalue,'showvalue'=>$tempvalue, 'rowindex' => $i, 'rowspan' => 1, 'tdindex' => $k);
                            $allmergecolumnvalue_arr[$i][$v] = $merge_columnsvalue;
                        } else {
                            if ($merge_columnsvalue == $mergecolumnvalue_arr[$v]['value']) {
                                $mergecolumnvalue_arr[$v]['rowspan'] = $mergecolumnvalue_arr[$v]['rowspan'] + 1;
                                /*if($tmpcurcolumntablename!=$mergecolumn_arr[0]){
                                    $mergecolumnvalue_arr[$v]['showvalue'] = $mergecolumnvalue_arr[$v]['showvalue'].','.$tempvalue;
                                    $mergecolumnvalue_arr[$v]['curvalue'] = $tempvalue;
                                }*/
                                $allmergecolumnvalue_arr[$i][$v] = $merge_columnsvalue;
                                if ($this->isexport) {
                                    //导出时要有空td
                                    $html_arr[$i] .= '<td  title="' . $temptitle . '" tdindex="' . $k . '" ></td>';
                                }
                                continue;
                            } else {
                                $allmergecolumnvalue_arr[$i][$v] = $merge_columnsvalue;
                                $tmpkey = $mergecolumnvalue_arr[$v]['rowindex'];
                                $htmlparseobj = new simple_html_dom();
                                $htmlparseobj->load($html_arr[$tmpkey]);
                                $tmphtmlobj = $htmlparseobj->find('td[tdindex=' . $k . ']', 0);
                                $tmphtmlobj->rowspan = $mergecolumnvalue_arr[$v]['rowspan'];
                                $mergeRowInfo[$k][$i] = $mergecolumnvalue_arr[$v]['rowspan'];
                                $html_arr[$tmpkey] = $htmlparseobj->innertext;//str_replace('<td ','<tr rowpsan="'.$mergecolumnvalue_arr[$v]['rowspan'].'">',$html_arr[$tmpkey]);
                                $mergecolumnvalue_arr[$v] = array("value" => $merge_columnsvalue,'curvalue'=>$tempvalue,'showvalue'=>$tempvalue, 'rowindex' => $i, 'rowspan' => 1, 'tdindex' => $k);
                                $tempvalue = $mergecolumnvalue_arr[$v]['showvalue'];
                            }
                        }
                    }

                }
                else if(strpos($merge,':')!==false){
                    if($this->isexport){
                        $allmergecolumnvalue_arr[$i][$v] = $type_desc;
                    }else {
                        //小计行
                        $tmpkey = $mergecolumnvalue_arr[$v]['rowindex'];
                        $htmlparseobj = new simple_html_dom();
                        $htmlparseobj->load($html_arr[$tmpkey]);
                        $tmphtmlobj = $htmlparseobj->find('td[tdindex=' . $k . ']', 0);
                        if (!empty($tmphtmlobj))
                            $tmphtmlobj->rowspan = $mergecolumnvalue_arr[$v]['rowspan'];

                        $html_arr[$tmpkey] = $htmlparseobj->innertext;//str_replace('<td ','<tr rowpsan="'.$mergecolumnvalue_arr[$v]['rowspan'].'">',$html_arr[$tmpkey]);
                        unset($mergecolumnvalue_arr[$v]);
                    }
                }

                $lengthdecimal = 2;//小数位数默认为2
                //公式字段，单据头货币字段，单据分录金额字段小数位数
                $isformat='no';
                if($total_type=="formula" || ($isdetailfield == 'no' &&($uitype == 71 || $uitype == 72))
                || ($isdetailfield == 'yes'&&(($uitype>=25 && $uitype<=50)||$fieldtype == 'Amount')) )
                {
                    $lengthdecimal = $decimal_places;
                    $tempvalue = !empty($tempvalue)?floatval($tempvalue):0;
                    $tempvalue = number_format($tempvalue,(int)$lengthdecimal);
                    $tempvalue = $prefix.$tempvalue.$suffix;//加上前缀后缀
                    $isformat='yes';

                }
                if($bigtype=="currency"||$bigtype=='amount') {//amount:分录
                    if ($uitype == 117 || $columnname == 'currency_id') {
                        if ($tempvalue > 0 && !empty($tempvalue)) {
                            $currencyObj = Currency::getInstance($adb, $tempvalue);
                            $currencynfo = $currencyObj->getCurrencyCacheInfo($tempvalue);
                            //币种名称
                            $tempvalue = getTranslatedCurrencyString($currencynfo['currency_name']) . '(' . $currencynfo['currency_symbol'] . ')';
                        } else {
                            $tempvalue = '';
                        }
                    } else {
                        if ($tempvalue > 0 && !empty($tempvalue)) {
                            //查询符号
                            $tem_fieldalia_arr = explode('belong', $v);
                            //zxm 20230816 币种符号在主表不在明细表
                            $temp_currency_symbol = $adb->query_result($res, $i, $tmpfocus->table_name . 'currency_symbol');
                            $temp_detail_currency_symbol = $temp_currency_symbol;
                            //zxm @date:2024/10/25 @reason:费用报销单 币种符号在分录表
                            if ($tmpfocus->module_name == 'Expense' && $columnname == 'money' && $type_desc == 'detail') {
                                $tmpcurrency_id = $adb->query_result($res, $i, 'ld_expensedetailscfbelongcurrency_id');

                                if (!empty($tmpcurrency_id) && $tmpcurrency_id != null && $tmpcurrency_id > 0) {

                                    $tmpcurrencyObj = Currency::getInstance($adb, $tmpcurrency_id);
                                    $tmpcurrencynfo = $tmpcurrencyObj->getCurrencyCacheInfo($tmpcurrency_id);
                                    $temp_detail_currency_symbol = $tmpcurrencynfo['currency_symbol'];
                                }
                            }


                            //zxm 20220802 计数 唯一计数 不需要币种符号
                            if (!empty($total_type) && $type_desc != 'detail' && $type_desc != 'count' && $type_desc != 'distinct_count') {
                                if ($isformat == 'yes') {
                                    $tempvalue = $temp_currency_symbol . $tempvalue;
                                } else
                                    $tempvalue = $temp_currency_symbol . number_format($tempvalue, $lengthdecimal);
                            } else if ($type_desc == 'count' || $type_desc == 'distinctcount') {
                                if ($isformat == 'yes') {
                                    $tempvalue = $temp_currency_symbol . $tempvalue;
                                } else
                                    $tempvalue = number_format($tempvalue, $lengthdecimal);
                            } else
                                if ($type_desc == 'detail') {
                                    if ($isformat == 'yes') {
                                        $tempvalue = $temp_detail_currency_symbol . $tempvalue;
                                    } else
                                        $tempvalue = $temp_detail_currency_symbol . number_format($tempvalue, $lengthdecimal);
                                }
                        }
                        else{
                            $tempvalue = '';
                        }
                    }
                }
                else if($columnname=='publicaccount'){
                    //客户的公海状态 0 普通客户   1   公海未分配   2、3 公海已分配
                    $publicaccountarray = array(
                        '0' => getFixedLabel('COMMONACCOUNT'),
                        '1' => getFixedLabel('LBL_NOALLOCATE'),
                        '2' =>getFixedLabel('LBL_PUBLICALLOCATE'),
                        '3' => getFixedLabel('LBL_PUBLICALLOCATE')
                    );
                    $tempvalue = $publicaccountarray[$tempvalue];
                }
                else if($bigtype=="number"||$bigtype=="num"){
                    // hzx 2023-11-14 BUG0075471 销售合同分录里的总吨位数字段是3位小数，报表中取过来的字段只能是2位小数（销售往来明细表）
                    if(!isset($tempvalue))
                    {
                        $tempvalue=0;
                    }
                    if(trim($tempvalue)!="")
                        //zxm
                        //if($typeofdata_decimal){
                            $tempvalue = number_format($tempvalue,(int)$typeofdata_decimal);
                        //}else{
                            //$tempvalue = number_format($tempvalue,(int)$quantity_decimal);
                        //}

				}
                else if(($bigtype=="price")&&!empty(trim($tempvalue))){

				   //单价类型字段
				   for($tmpi=0;$tmpi<strlen($tempvalue);$tmpi++)
					{
						$tmpstr=substr($tempvalue,$tmpi,1);
						if( is_numeric($tmpstr)||$tmpstr=='-'||$tmpstr=='.')
						{
							break;
						}
					}


					$tempvalue=substr($tempvalue,$tmpi);
					$tempvalue ='¥'.number_format($tempvalue,(int)$this->amount_decimal);


				}
                else if($bigtype=='poolid')
                {
                    static $pool_arr;

                    if(!empty(trim($tempvalue)))
                    {
                        if(is_array($pool_arr)&&array_key_exists($tempvalue,$pool_arr[$columnmodule]))
                        {
                            $tempvalue=$pool_arr[$columnmodule][$tempvalue];

                        }
                        else
                        {
                            $tmp_tempvalue_arr = [];
                            // 2024-11-12 公海名-计数 行
                            if(!is_numeric($tempvalue) && is_string($tempvalue)){
                                $tmp_tempvalue_arr = explode('-',$tempvalue);
                                $tmp_pool_id = $tmp_tempvalue_arr[0];
                                $tempvalue = $tmp_pool_id;
                            }
                            if($columnmodule=='Accounts')
                                $sql='select id,zh_name from ld_account_public_pool where id= '.$tempvalue;
                            else
                                $sql='select id,zh_name from ld_leads_public_pool where id= '.$tempvalue;
                            
                            $pool_result=$adb->pquery($sql,array());
                            if($adb->num_rows($pool_result)>0)
                            {
                                $tempvalue=$adb->query_result($pool_result,0,'zh_name');
                                if(!empty($tmp_tempvalue_arr)){
                                    $tempvalue = $tempvalue.'-'.$tmp_tempvalue_arr[1];
                                }
                                $pool_arr[$columnmodule][$adb->query_result($pool_result,0,'id')]=$tempvalue;
                            }
                            else{
                                $pool_arr[$columnmodule][$tempvalue]='';
                                $tempvalue='';
                            }
                        }
                    }
                    else{
                        $tempvalue='';
                    }
                }
                else if($uitype==70&&$isdetailfield=='yes'&&$iscomputerfield=='no')
                {
                    $tmpproductid = $tempvalue;//产品id
                    static $arr_products_report;
                    if(is_array($arr_products_report)&&array_key_exists($tempvalue,$arr_products_report))
                    {
                        $tempvalue = $arr_products_report[$tmpproductid];
                    }
                    else
                    {
                        $sql='select productname from ld_products where productid=?';
                        $tempresult=$adb->pquery($sql,array($tempvalue));
                        if($adb->num_rows($tempresult)>0)
                        {
                            $productname=$adb->query_result($tempresult,0,'productname');
                            $reference_modulename="Products";
                            if(!is_array($arr_products_report))
                            {
                                $arr_products_report=[];
                            }
                            if($frommobile=='yes'){
                                $tempvalue = $this->getMobileLink($reference_modulename,$tempvalue,$productname);
                            }
                            else{
                                $tempvalue  = '<a lasturl="" fieldname="'.$columnname.'" module="'.$reference_modulename.'" record="'.$tempvalue.'" href="index.php?pageto_module='.$reference_modulename.'&pageto_action=index&pageto_record='.$tempvalue.'" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="'.$productname.'">'.$productname.'</a>';
                            }

                            $arr_products_report[$tmpproductid]=$tempvalue;
                        }
                    }
                }
                else if(($bigtype=='reference'||$bigtype=='multireference')&&$iscomputerfield=='no')
                {

                    $iscontinue='yes';
                    if($type_desc!='detail'){
                        if($is_group=='yes')
                        {
                            $tempvalue_arr = explode('-',$tempvalue);
                            $text_fix = $tempvalue_arr[1];
                            $tempvalue = $tempvalue_arr[0];
                        }
                        else
                        {
                            $iscontinue='no';
                        }
                    }
                    if(empty($tempvalue))
                    {
                        $tempvalue='';
                    }
                    if(!empty($tempvalue)&&$iscontinue=='yes')
                    {

                        $record = explode('-',$tempvalue);
                        $record = $record[0];//获取ID
                        //单据选择字段
                        $column_arr=explode(':',$this->detailviewobj->column_arr[$k]['columns']);

                        $tablename=$column_arr[0];
                        $focus=CRMEntity::getInstance($columnmodule);
						//wym 多选关联字段 字段设置启用超链接时，更改showpage值 使showvalue传值带有超链接
                        $tmpshowpage = SHOW_POPUP;
                        if($frommobile!='yes' && $bigtype=='multireference'){
                            $tmpshowpage = SHOW_DETAILVIEW;
                        }

                        $fieldvalueobj= new ShowFieldValue($focus->fieldobj,$columnmodule,$tmpshowpage);
                        if(in_array($tablename,$focus->tab_name))
                        {
                            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$column_arr[1]);
                            //dump(getModuleHref($fieldinfo->getReferencemodule(),$tempvalue));
                            $showvalue= $fieldvalueobj->getFieldValueByField($fieldinfo,$tempvalue,$tempvalue);
                            $reference_modulename = getEntitySetype($record);//获取模块名称
                            $reference_arr[$tempvalue]=$showvalue['value'];
                            $tempvalue = $showvalue['value'];
                        }
                        else{
                            $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$column_arr[1]);
                            //自定义报表添加的 活动申请单（企业参访）明细表 中 人员名单的字段无法显示姓名  BUG0059470  zxm 20221205
                            $tempvalue = getModuleHref($fieldinfo->getReferencemodule(),$tempvalue);
                        }
                        if($record>0){
//                            if(empty($showvalue['rawvalue']))
//                                $tempvalue='--';

                            if($frommobile=='yes') {
                                $tempvalue = $this->getMobileLink($reference_modulename, $record, $tempvalue);
                            } else {
                                if($bigtype=='multireference'){

                                }else{
                                    $tempvalue = '<a lasturl="" fieldname="' . $columnname . '" module="' . $reference_modulename . '" record="' . $record . '" href="index.php?pageto_module=' . $reference_modulename . '&pageto_action=index&pageto_record=' . $record . '" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="' . $tempvalue . '">' . $tempvalue . '</a>';
                                }
                            }
                        }

                    }

                    if($is_group=='yes'&&$type_desc!='detail'){
                        $tempvalue .= '-'.$this->detailviewobj->computerfunText_arr[$type_desc];//客户名称分组 后面没有后缀小计等字样
                    }

                }
                else if((
                    //$bigtype=='moduleno'||$uitype=='70'||//zxm 20231204 超链接字段根据超链接字段设置来
                    $columnname==$entityfieldname)&&$iscomputerfield=='no'){
                    //编号字段  也显示链接可跳转详情
                    $focus=CRMEntity::getInstance($columnmodule);
                    //单据选择字段
                    $column_arr=explode(':',$this->detailviewobj->column_arr[$k]['columns']);
                    $temp_tableindex_name = $column_arr[0]."belong".$focus->table_index;
                    $tableIndexValue = $adb->query_result($res,$i,$temp_tableindex_name);
                    if($tableIndexValue>0) {
                        if($frommobile=='yes'){
                            $tempvalue = $this->getMobileLink($columnmodule,$tableIndexValue,$tempvalue);
                        }
                        else {
                             $tempvalue = '<a lasturl="" fieldname="' . $columnname . '" module="' . $columnmodule . '" record="' . $tableIndexValue . '" href="index.php?pageto_module=' . $columnmodule . '&pageto_action=index&pageto_record=' . $tableIndexValue . '" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="' . $tempvalue . '">' . $tempvalue . '</a>';
                        }
                    }
                }
                //bigtype =='Users' 首字母是大写的
                else if((strtolower($bigtype)=='users'||$bigtype=='selectoneuser')&&$iscomputerfield=='no')
                    {
                        //分组字段
                        $iscontinue='yes';
                        if($type_desc!='detail'){
                            if($is_group=='yes')
                            {
                                $tempvalue_arr = explode('-',$tempvalue);
                                $text_fix = $tempvalue_arr[1];
                                $tempvalue = $tempvalue_arr[0];
                            }
                            else
                            {
                                $iscontinue='no';
                            }

                        }
                        if(!empty(trim($tempvalue))&& $iscontinue=='yes')
                        {
                            $userid_arr = explode(',',$tempvalue);
                            $username_arr = [];
                            //zxm 20240925 当前审批人有多个 处理不对
                            foreach($userid_arr as $tmpuid) {
                                if (array_key_exists($tmpuid, $userinfo_arr)) {
                                    $username_arr[] = $userinfo_arr[$tmpuid];
                                } else {

                                    $sql = 'select wx_userid,last_name,id from ld_users where id=?' ;
                                    $useresult = $adb->pquery($sql, array($tmpuid));
                                    if ($adb->num_rows($useresult) > 0) {
                                        $userobj = new Users();

                                        $userobj->wx_userid = $adb->query_result($useresult, 0, 'wx_userid');
                                        $userobj->id = $tmpuid;
                                        $userobj->last_name = $adb->query_result($useresult, 0, 'last_name');
                                        $tempuname = getUserlastName($userobj);
                                        $userinfo_arr[$tmpuid] = $tempuname;
                                    } else {
                                        $userinfo_arr[$tmpuid] = '';
                                    }
                                    $username_arr[] = $userinfo_arr[$tmpuid];
                                }
                            }
                            $tempvalue = implode(',',$username_arr);
                        }else{
                            $tempvalue = '';
                        }
                        //分组字段
                        if($is_group=='yes'&&$type_desc!='detail'&&!empty($text_fix)){
                            $tempvalue = $tempvalue.'-'.$text_fix;
                        }
                    }
                else if ($bigtype=='memberdepartment'||$columnname=='department'){
                    //分组字段 zxm 2022-5-7 列表处的业务部门字段，统计的数据显示的是数字，不是成员所属部门
                    if($type_desc!='detail'){
                        if($is_group=='yes')
                        {
                            $tempvalue_arr = explode('-',$tempvalue);
                            $text_fix = $tempvalue_arr[1];
                            $tempvalue = $tempvalue_arr[0];
                        }
                    }

                    //ls 2022-02-07 0049865: （https://81mis.com/kfbtest/index.php? [^]）自定义报表》“客户负责人部门分布”的部门，显示是数字
                    if($tempvalue!='')
                        $tempvalue = getGroupName_new($tempvalue);

                     //分组字段
                    if($is_group=='yes'&&$type_desc!='detail'&&!empty($text_fix)){
                        $tempvalue = $tempvalue.'-'.$text_fix;
                    }
                }
                else if (($uitype==56 || $uitype==156) && $columnname!='publicaccount' )
                {
                    if($tempvalue==1 || $tempvalue=='on')
                    {
                        $tempvalue=getFixedLabel("YES");
                    }
                    else{
                        $tempvalue=getFixedLabel("NO");
                    }
                }
                else if($total_type=="formula"){
                    $lengthdecimal = empty($decimal_places)?0:$decimal_places;
                    $tempvalue = number_format($tempvalue,(int)$lengthdecimal);
                    $tempvalue = $prefix.$tempvalue.$suffix;//加上前缀后缀
                }
                else if($uitype==251){
                    //收款单-选择银行账户  银行账户显示不出来账户名称
                    $bankaccountsql = "select Accountname  from ld_bankaccountset where Bankaccountsetid=?";
                    $bankaccountres = $adb->pquery($bankaccountsql,array($tempvalue));
                    $bankaccountnums = $adb->num_rows($bankaccountres);
                    if($bankaccountnums>0){
                       $tempvalue = $adb->query_result($bankaccountres,0,0);
                    }else{
                       $tempvalue = '-';
                    }
                }
                else if($uitype==154||$bigtype=='selectmultiuser'){
                    //团队成员 zxm 20221122 团队成员 多选用户的处理
                    if(!empty($tempvalue)){
                        $tmp_namefield = 'last_name';
                        if(isKehu001ServerPc()=='yes'){
                            $tmp_namefield = 'real_name';
                        }
                            $user_sql = " select group_concat($tmp_namefield) as user_name from ld_users where find_in_set(id,'$tempvalue') ";
                            $user_res = $adb->pquery($user_sql,array());
                            $user_nums = $adb->num_rows($user_res);
                        if($user_nums>0){
                            $tempvalue = $adb->query_result($user_res,0,0);
                            $tempvalue = trim($tempvalue,',');
                            $temptitle = $tempvalue;
                        }
                    }
                }
                else if($bigtype=='translatefield'){

                    $arr = getTranslateDbValueNew($columnmodule,$columnname);
                    if($type_desc!='detail'&&$is_group=='yes'){
                        $tempvalue_arr = explode('-',$tempvalue);
                        $text_fix = $tempvalue_arr[1];
                        $tempvalue = $tempvalue_arr[0];
                        $tempvalue = getFixedLabel($arr[$tempvalue]['labelbol']).'-'.$text_fix;
                    }else{
                        $tempvalue = getFixedLabel($arr[$tempvalue]['labelbol']);
                    }
                }
                else if($bigtype=='ware'){
                    //仓库  zxm 20240102


                    if(!empty(trim($tempvalue)))
                    {
                     require_once (globalStatic::$root_directory."include/Stock/CommonStock.php");
                     $warearr= getWareInfoById($tempvalue);


                      $tempvalue= $warearr['name'];



                    }
                    else{
                        $tempvalue='';
                    }
                }
                else if($bigtype=='time'||$bigtype=='date'||$bigtype=='datetime'){
                    //0000-00-00的处理
                    if($tempvalue=='0000-00-00' || $tempvalue=='00:00:00' || $tempvalue=='00:00' || $tempvalue=='0000-00-00 00:00:00'){
                        $tempvalue='';
                    }else{
                        if(!empty($valueFormat)) {
                            if($type_desc=='detail'){
                                $tempvalue = DateOperation::format($valueFormat, $tempvalue);
                            }else{
                                //zxm @date:2024/12/20 @reason: BUG20241220-02
                                $type_desc_zh = $this->detailviewobj->computerfunText_arr[$type_desc];
                                $tempvalue_arr = explode('-'.$type_desc_zh,$tempvalue);
                                $tempvalue_format = DateOperation::format($valueFormat, $tempvalue_arr[0]);
                                if(strpos($tempvalue,$type_desc_zh)==false||empty($tempvalue_arr[0])){
                                    $tempvalue = $tempvalue_format;
                                }else{
                                    $tempvalue = $tempvalue_format.'-'.$type_desc_zh;
                                }
                            }
                        }
                    }
                }
                else{
                    //zxm 20231018字段值超长隐藏了 增加title取值
                    if($bigtype!='richtext' && $bigtype !== 'selectsource'){
                        $temptitle = $tempvalue;
                    }
                    if($bigtype === 'richtext') {
                        $tempvalue='<div style="white-space: initial;word-wrap: break-word;">'.$tempvalue.'</div>';
                    }

                }
                $prevdetailvalue_arr[$prevdetail_i][]=$tempvalue;

                $issticky_style = $issticky=='yes'?'set-sticky':'';
                $styleset_body = $this->StyleSetObj->getstyleset_body($k);

                $html_arr[$i].= '<td  title="'.$temptitle.'" tdindex="'.$k.'" align="'.$align.'" class="'.$issticky_style.'" style="padding:0 3px;'.$styleset_body.'">'.$tempvalue.'</td>';
               //$data_arr[$i][$k] = $tempvalue;
            }
            $html_arr[$i] .= '</tr>';
        }

        foreach($mergecolumnvalue_arr as $v=>$info)
        {
            $tmpkey=$info['rowindex'];
            $htmlparseobj = new simple_html_dom();
            $htmlparseobj->load($html_arr[$tmpkey]);
            $tdinex=$info['tdindex'];
            $tmphtmlobj=$htmlparseobj->find('td[tdindex='.$tdinex.']',0);
            $tmphtmlobj->rowspan=$mergecolumnvalue_arr[$v]['rowspan'];
            $html_arr[$tmpkey]= $htmlparseobj->innertext;

        }

        $html=implode(" ",$html_arr);

        //$this->detailviewobj->data_arr=$data_arr;
        $this->mergeRowInfo = $mergeRowInfo;
        //zxm @date:2024/11/13 @reason: 这个保存的是每一行 的 合并那一列的字段值 格式是二维数组 二维的键是字段名 值是字段值 导出时使用
        $this->allmergecolumnvalue_arr = $allmergecolumnvalue_arr;
        return $html;
    }
    //获取源单编号
    public function getSourceListNumber($records){

        global $adb;
        $frommobile = $_REQUEST['frommobile'];

        $record_arr=explode(",",$records);
        $ret_value=[];

        foreach($record_arr as $record)
        {

            if(empty($record) || (is_string($record) && empty(trim($record))) || !is_numeric($record))
            {
                continue;
            }
            if(empty($modulename))
            {
                $modulename = getEntitySetype($record);
                $focus = CRMEntity::getInstance($modulename);
                $tablename = $focus->table_name;
                $scftablename = $focus->customFieldTable[0];
                //$table_code = $focus->table_code;
                $table_code = $focus->list_link_field;
                $tab_name_index = $focus->tab_name_index[$tablename];
            }

            $sql = "select ".$table_code." from ".$tablename." left join $scftablename on $tablename.$tab_name_index=$scftablename.$tab_name_index where $tablename.".$tab_name_index."=? ";
            $res = $adb->pquery($sql,array($record));
            $nums = $adb->num_rows($res);
            $sourceListNumber = '';

            if($nums>0){
                $sourceListNumber = $adb->query_result($res,0,0);
                if($frommobile=='yes'){
                   $ret_value[] = $this->getMobileLink($modulename,$record,$sourceListNumber);
                }else {
                    $ret_value[] = '<a lasturl="" fieldname="source_list" module="' . $modulename . '" record="' . $record . '" href="index.php?pageto_module=' . $modulename . '&pageto_action=index&pageto_record=' . $record . '" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="' . $sourceListNumber . '">' . $sourceListNumber . '</a>';
                 }
            }
        }

        return implode(',',$ret_value);
    }

    public function getTotalRowContent($result)
    {
        global $adb;
        $quantity_decimal=$this->quantity_decimal;
        $amount_decimal=$this->amount_decimal;
        $html='';
        $totalrows=$adb->num_rows($result);
        $rowindex=0;

        for($i=0;$i<$totalrows;$i++){
            $rowindex=$i;
            $html.= '<tr tag="tr_totalrow" rowindex="'.$rowindex.'" style="background-color: #E1E4E6">';
            foreach($this->detailviewobj->fieldsTableHeader as $k=>$v){
                $tempvalue = $adb->query_result($result,$i,$v);
                $type_desc=$adb->query_result($result,$i,'type_desc');
                $total_type = $this->detailviewobj->column_arr[$k]['total_type'];
                $align = $this->detailviewobj->column_arr[$k]['align'];
                $bigtype=$this->detailviewobj->column_arr[$k]['bigtype'];
                $uitype=$this->detailviewobj->column_arr[$k]['uitype'];
                $fieldtype=$this->detailviewobj->column_arr[$k]['fieldtype'];

                $prefix=$this->detailviewobj->column_arr[$k]['prefix'];//前缀
                $suffix=$this->detailviewobj->column_arr[$k]['suffix'];//后缀
                $issticky=$this->detailviewobj->column_arr[$k]['issticky'];//是否固定列
                $decimal_places = $this->detailviewobj->column_arr[$k]['decimal_places'];//小数位数

                $lengthdecimal = 2;//小数位数默认为2
                //公式字段，单据头货币字段，单据分录金额字段小数位数
                if($total_type=="formula" || ($isdetailfield == 'no' &&($uitype == 71 || $uitype == 72))
                || ($isdetailfield == 'yes'&&(($uitype>=25 && $uitype<=50)||$fieldtype == 'Amount')) )
                {
                    $lengthdecimal = $decimal_places;
                    $tempvalue = number_format($tempvalue,(int)$lengthdecimal);
                    $tempvalue = $prefix.$tempvalue.$suffix;//加上前缀后缀
                }
                //唯一计数 计数 虽然是金额字段但是不要人民币符号zxm 20220802
                if(($bigtype=="currency"||$bigtype=='amount')&&!empty(trim($tempvalue))){
                    if($type_desc!='count'&&$type_desc!='distinct_count'){
                        //金额类型字段
                        for($tmpi=0;$tmpi<strlen($tempvalue);$tmpi++)
                        {
                            $tmpstr=substr($tempvalue,$tmpi,1);
                            if( is_numeric($tmpstr)||$tmpstr=='-'||$tmpstr=='.')
                            {
                                break;
                            }
                        }


                        $tempvalue=substr($tempvalue,$tmpi);
                        $tempvalue ='¥'.number_format($tempvalue,$lengthdecimal);
                    }else{
                        $tempvalue = number_format($tempvalue,$lengthdecimal);
                    }

                }

                if(($bigtype=="price")&&!empty(trim($tempvalue))){

                  //单价类型字段
                   for($tmpi=0;$tmpi<strlen($tempvalue);$tmpi++)
                    {
                        $tmpstr=substr($tempvalue,$tmpi,1);
                        if( is_numeric($tmpstr)||$tmpstr=='-'||$tmpstr=='.')
                        {
                            break;
                        }
                    }


                    $tempvalue=substr($tempvalue,$tmpi);
                    $tempvalue ='¥'.number_format($tempvalue,(int)$this->amount_decimal);

                }
                 //计算公式字段 保留小数位数 加前缀后缀---zxm 20240620 去掉 前面加过了前缀和小数位数
                /*if($total_type=="formula") {
                    $lengthdecimal = empty($decimal_places) ? 0 : $decimal_places;
                    $tempvalue = number_format($tempvalue, (int)$lengthdecimal);
                    $tempvalue = $prefix . $tempvalue . $suffix;//加上前缀后缀
                }*/
                if(trim($tempvalue)!="")
                    if($bigtype=="number"||$bigtype=="num"){
                        $tempvalue = number_format($tempvalue,(int)$quantity_decimal);
                    }
                $issticky_style = $issticky=='yes'?'set-sticky':'';
                $styleset_body = $this->StyleSetObj->getstyleset_body($k);
                $html.= '<td tdindex="'.$k.'" align="'.$align.'" class="'.$issticky_style.'" style="padding:0 3px;'.$styleset_body.'">'.$tempvalue.'</td>';

                $tmpmergecolumn[$v] = 'total';
            }

            $html.='</tr>';
        }

        $this->allmergecolumnvalue_arr[]= $tmpmergecolumn;//最后一行
        return $html;
    }

    //zxm XUQIU1000530	统计表 自定义统计表-支持SQL语句
    public function getParseSqlContent($result,$columnsArr){
        global $adb;
        $htmlparseobj = new simple_html_dom();
        $frommobile = $_REQUEST['frommobile'];
        $data = $adb->query_result_all($result);
        $result->Close();//调用存储过程  如果不加这句关闭结果集 后面的关于sql的执行都不会生效
        $html_arr = [];
        $mergecolumnvalue_arr=[];
        $allmergecolumnvalue_arr = [];
        $totallineArr = [];


        foreach($data as $line=>$linedata){
            if($line%2==0){
                $trclass = 'lvtColData';
            }else{
                $trclass = 'lvtColDataBj';
            }
            $html_arr[$line] = '<tr class="'.$trclass.'" rowindex="'.$line.'">';
            foreach($columnsArr as $k=>$columns){
                $is_merge = $columns['is_merge'];//合并 -- todo --
                //if($this->isexport)$is_merge = "no";
                $align = $columns['align'];
                $linkurl = $columns['linkurl'];
                $column = $columns['columns'];
                $issticky = $columns['issticky'];
                $tempvalue = $linedata[strtolower($columns['columns'])];
                if($columns['fieldtype']=='number'){
                    $tempvalue = setNumberFormat($tempvalue,$this->quantity_decimal);
                }else if($columns['fieldtype']=='currency'){
                    $tempvalue = setNumberFormat($tempvalue,$this->amount_decimal);
                }

                if($columns['fieldtype']=='number'){
                    $totallineArr[$k] += $tempvalue;
                }else{
                    $totallineArr[$k] = '合计';
                }
                if(!empty($linkurl)&&$linkurl!='no'){
                    //{"type":"detailview","modulefield":"","recordfield":"accountid","url":""}
                    $linkurl = Zend_Json::decode($linkurl);
                    $linkurltype = $linkurl['type'];
                    $recordfield = $linkurl['recordfield'];

                    if($linkurltype=='detailview'){
                        $recordfield_value = $linedata[strtolower($recordfield)];
                        $modulename = getsalesentitytype($recordfield_value);
                        if($frommobile=='yes'){
                            $tempvalue = $this->getMobileLink($modulename,$recordfield_value,$tempvalue);
                        }else{
                            if($recordfield_value>0){
                                $tempvalue = '<a lasturl="" fieldname="'.$recordfield.'" module="'.$modulename.'" record="'.$recordfield_value.'" href="index.php?pageto_module='.$modulename.'&pageto_action=index&pageto_record='.$recordfield_value.'" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="'.$tempvalue.'">'.$tempvalue.'</a>';
                            }
                        }
                    }
                }
                //是否合并
                if(!empty($is_merge)&&$is_merge!='no'&&$is_merge!='noselect'){

                    $merge_columnsvalue = $linedata[$is_merge];//合并标签字段的值

                    if(!array_key_exists($column,$mergecolumnvalue_arr)) {
                        $mergecolumnvalue_arr[$column] = array("value" => $merge_columnsvalue, 'rowindex' => $line, 'rowspan' => 1, 'tdindex' => $k);
                        $allmergecolumnvalue_arr[$line][$column] = $merge_columnsvalue;
                    }
                    else
                    {
                        if($merge_columnsvalue==$mergecolumnvalue_arr[$column]['value'])
                        {
                            $mergecolumnvalue_arr[$column]['rowspan']=$mergecolumnvalue_arr[$column]['rowspan']+1;
                            $allmergecolumnvalue_arr[$line][$column] = $merge_columnsvalue;
                            if ($this->isexport) {
                                //导出时要有空td
                                $html_arr[$line] .= '<td tdindex="' . $k . '" ></td>';
                            }
                            continue;
                        }
                        else{
                            $tmpkey=$mergecolumnvalue_arr[$column]['rowindex'];

                            $htmlparseobj->load($html_arr[$tmpkey]);
                            $tmphtmlobj=$htmlparseobj->find('td[tdindex='.$k.']',0);
                            $tmphtmlobj->rowspan=$mergecolumnvalue_arr[$column]['rowspan'];

                            $html_arr[$tmpkey]= $htmlparseobj->innertext;//str_replace('<td ','<tr rowpsan="'.$mergecolumnvalue_arr[$v]['rowspan'].'">',$html_arr[$tmpkey]);
                            $mergecolumnvalue_arr[$column]=array("value"=>$merge_columnsvalue,'rowindex'=>$line,'rowspan'=>1,'tdindex'=>$k);
                            $allmergecolumnvalue_arr[$line][$column] = $merge_columnsvalue;
                        }
                    }
                }
                $style = "";
                //if($k<=2){
                    //$left = $k*200;
                    //$style = "position:sticky;left:".$left."px;background-color:#fff;";
                //}
                $issticky_style = $issticky=='yes'?'set-sticky':'';
                $styleset_body = $columns['styleset_body'];
                $html_arr[$line] .= '<td tdindex="'.$k.'" align="'.$align.'" class="'.$issticky_style.'" style="padding:0 3px;'.$style.$styleset_body.'">'.$tempvalue.'</td>';
            }

            $html_arr[$line] .= '</tr>';
        }

        //是否合并  最后一行
        foreach($mergecolumnvalue_arr as $v=>$info)
        {
            $tmpkey=$info['rowindex'];
            $htmlparseobj->load($html_arr[$tmpkey]);
            $tdinex=$info['tdindex'];
            $tmphtmlobj=$htmlparseobj->find('td[tdindex='.$tdinex.']',0);
            $tmphtmlobj->rowspan=$mergecolumnvalue_arr[$v]['rowspan'];
            $html_arr[$tmpkey]= $htmlparseobj->innertext;
        }
		//zxm 20231018 SQL报表合计行 先注释吧因为要提交代码
        //$html_arr[$line+1] = $this->getParseSqlTotalContent($data,$columnsArr,$totallineArr);
        $this->allmergecolumnvalue_arr = $allmergecolumnvalue_arr;

        return implode(" ",$html_arr);
    }
    public function getParseSqlTotalContent($data,$columnsArr,$totallineArr){
        $countsdata = count($data);
        $totalhtml = '';
        //合计行
        foreach($data as $line=>$linedata){
            if($countsdata==$line+1){
                $totalhtml = '<tr style="background-color: #f0f4fc;font-weight: bold;">';
                foreach($columnsArr as $k=>$columns){
                    $align = $columns['align'];
                    $issticky = $columns['issticky'];
                    $issticky_style = $issticky=='yes'?'set-sticky':'';
                    $styleset_body = $columns['styleset_body'];
                    $style = "";
                    //if($k<=2){
                    //$left = $k*200;
                    //$style = "position:sticky;left:".$left."px;background-color:#fff;";
                    //}
                    $totalhtml .= '<td  align="'.$align.'" class="'.$issticky_style.'" style="padding:0 3px;'.$style.$styleset_body.'">'.$totallineArr[$k].'</td>';
                }
                $totalhtml .= '</tr>';


            }
        }
        return $totalhtml;
    }

    public function getWxVersion(){
        global $adb;
        //wx_version
        $version_sql = "select wx_version from ld_version";
        $version_res = $adb->pquery($version_sql);
        $wx_version = $adb->query_result($version_res,0,0);
        return $wx_version;
    }
    //移动端穿透链接--详情

    /**
     * @param $modulename //模块名称
     * @param $recordfield_value //单据id
     * @param $tempvalue //值
     * @return string
     */
    public function getMobileLink($modulename,$recordfield_value,$tempvalue){
        global $weixin_user;

        $environment = $weixin_user->environment;
        $corpurl_all = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST']. $_SERVER['PHP_SELF'];
        $corpurl_arr = explode('WeiXinApp',$corpurl_all);
        $crm_url = $corpurl_arr[0];
        $modulelabel = getTranstab($modulename);
        $tmp_recordfield_value = explode(',',$recordfield_value);
        $tmplink = '';
        $count_record = count($tmp_recordfield_value);
        foreach($tmp_recordfield_value as $tmpindex =>$tmprecord){
            $tmpvalue = $tempvalue;
            if($count_record>1){
                $tmpvalue = getModuleHref($modulename, $tmprecord);
            }
            if($environment=='weixinh5'){
                //企业微信
                $vx_version = $this->getWxVersion();
                $linkmobile = 'http://www.51mis.cn/websaas/weixinsaas/'.$vx_version.'/ldcrm/index.html#!/detailview/' .$modulename. '/'.$tmprecord.'/' .$modulelabel . '/list/no/-1';

            }
            if( $environment=='wxwork'||$environment=='weixin'){
                //小程序---暂时还不行
                $linkmobile = "/page/index/index";
            }
            if($environment=='dingtalk'){
                //钉钉
                $linkmobile = $crm_url.'WeiXinApp/dingtalk/websaas/ldcrm/index.html#!/detailview/' .$modulename. '/'.$tmprecord.'/' .$modulelabel . '/list/no/-1';
            }
            if($environment=='yunzhijia'){
                //云之家
                $linkmobile = $crm_url.'WeiXinApp/yunzhijia/websaas/ldcrm/index.html#!/detailview/' .$modulename. '/'.$tmprecord.'/' .$modulelabel . '/list/no/-1';
            }
            if($environment=='fanwei' || $environment=='zhiyuan'){//致远
                //泛微
                $linkmobile = $crm_url.'WeiXinApp/selfbuildSass/ldcrm/index.html#!/detailview/' .$modulename. '/'.$tmprecord.'/' .$modulelabel . '/list/no/-1';
            }
            $tmplink .= '<a target="_self" href="'.$linkmobile.'" title="'.$tmpvalue.'">'.$tmpvalue.'</a>';
            if($tmpindex!=$count_record-1)$tmplink .= ',';
        }
        return $tmplink;
    }
}

?>

