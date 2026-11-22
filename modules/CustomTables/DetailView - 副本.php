<?php
crm_load_class_file("cls_ComputerSql","modules/CustomTables/ComputerSql");
crm_load_class_file("cls_TableJoin_module",'include/fields');
crm_load_class_file("ReportTableWhere",'modules/CustomTables/Query');
require_once(globalStatic::$root_directory."include/simple_html_dom.php");
require_once(globalStatic::$root_directory."appCommon/appCommon.php");
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
$obj = new CustomTablesDetailView();
$is_ajax = $_REQUEST['is_ajax'];
$obj->$function($is_ajax);


class CustomTablesDetailView
{
    public $CustomTablesActionsObj;
    public $total_typenumber = "10";//默认底部
    public $module_arr;//模块数组
    public $relatedModule;//相关模块数组
    public $mainmodule;//主模块
    public $column_arr;//统计字段数组
    public $groupcolumn_arr;//分组字段数组
    public $maxcolumn_arr;//求最大值字段 数组
    public $mincolumn_arr;//求最小值字段 数组
    public $sumcolumn_arr;//求和字段 数组
    public $avgcolumn_arr;//求均值字段 数组
    public $countcolumn_arr;//计数字段 数组
    public $mergeColumn_arr;
    public $sorting_list_all; //zxm20220719
    public $sorting_list_bycolumnname; //zxm20220719
    public $sorting_list_byresult; //zxm20220719
    public $group_sql_statistic;//安分组字段 统计字段组合的子sql zxm20220719
    public $aliasArr = [
        'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
        'aa','ba','ca','da','ea','fa','ga','ha','ia','ja','ka','la','ma','na','oa','pa','qa','ra','sa','ta','ua','va','wa','xa','ya','za',
        'ab','bb','cb','db','eb','fb','gb','hb','ib','jb','kb','lb','mb','nb','ob','pb','qb','rb','sb','tb','ub','vb','wb','xb','yb','zb',
        'ac','bc','cc','dc','ec','fc','gc','hc','ic','jc','kc','lc','mc','nc','oc','pc','qc','rc','sc','tc','uc','vc','wc','xc','yc','zc'
    ];//少的话可以再加
    public $distinctcountcolumn_arr;//唯一计数字段 数组
    public $asfixedname;

    public $fields;//统计字段
    public $fieldsAlias=[];//统计字段别名
    public $fieldsFormulaArr=[];//公式字段别名--
    public $fieldsCurrencySymbol;//字段 -币种符号
    public $fieldsTableHeader;
    public $conditionSql;//条件子sql
    public $typevalue_arr;
    public $ordercolumn_arr;
    public $sqlOrdercolumn_arr;
    public $ordercolumn_suff="_order";
    public $selectColumnFrom;
    public $selectColumnTable_arr;
    public $limit;
    public $report_id;
    public $computerfunText_arr;
    public $computerfunColor_arr;//颜色
    public $firstrColumnComputer_type;//第一列是计算字段的函数类型
    public $detail_type;
    public $sum_type;
    public $max_type;
    public $min_type;
    public $count_type;
    public $avg_type;
    public $wheremodule_arr;//有查询条件的模块
    public $distinctcount_type;
    public $show_detail = 'yes';
    public $DetailDableIdField;//明细表的lineitem_id
    public function __construct(){
        include_once globalStatic::$root_directory.'modules/CustomTables/CustomTablesActions.php';
        $this->asfixedname='belong';
        $this->typevalue_arr=[];
        $this->wheremodule_arr=[];
        $this->CustomTablesActionsObj = new CustomTablesActions();
        $this->detail_type='detail';
        $this->sum_type='sumgroup';
        $this->avg_type='avg';
        $this->max_type='max';
        $this->min_type='min';
        $this->count_type='count';
        $this->distinctcount_type='distinctcount';

        $this->typevalue_arr[$this->detail_type]=1;
        $this->typevalue_arr[$this->sum_type]=2000;
        $this->typevalue_arr[$this->avg_type]=2300;
        $this->typevalue_arr[$this->max_type]=2600;
        $this->typevalue_arr[$this->min_type]=2900;
        $this->typevalue_arr[$this->count_type]=3200;
        $this->typevalue_arr[$this->distinctcount_type]=3500;
        $this->typevalue_arr['alltotal']=10000;
        $this->limit=200;
        $this->firstrColumnComputer_type=[];
        $this->computerfunText_arr=[$this->count_type=>getFixedLabel('COUNT').'：',$this->distinctcount_type=>getFixedLabel('UCOUNT').'：'
            ,$this->max_type=>getFixedLabel('MAXVALUE').'：',$this->min_type=>getFixedLabel('MINVALUE').'：',$this->avg_type=>getFixedLabel('AVGVALUE').'：',$this->sum_type=>getFixedLabel('SUBTOTAL').'：'];
//        $this->computerfunColor_arr=[
//            $this->count_type=>'rgb(178 196 223 / 70%)',
//            $this->distinctcount_type=>'rgb(178 196 223 / 60%)',
//            $this->max_type=>"rgb(178 196 223 / 50%)",
//            $this->min_type=>"rgb(178 196 223 / 40%)",
//            $this->avg_type=>"rgb(178 196 223 / 30%)",
//            $this->sum_type=>'rgb(178 196 223 / 20%)'];//小计行颜色
        $this->computerfunColor_arr=[
            $this->count_type=>'#EEEEEE',
            $this->distinctcount_type=>'#EEEEEE',
            $this->max_type=>"#EEEEEE",
            $this->min_type=>"#EEEEEE",
            $this->avg_type=>"#EEEEEE",
            $this->sum_type=>'#EEEEEE'];//小计行颜色

    }
    //详情页面
    public function index(){
        $report_id = $_REQUEST['report_id'];

        $this->report_id=$report_id;
        $this->CustomTablesActionsObj->smarty->assign("report_id",$report_id);
        $timeValueArr = $this->CustomTablesActionsObj->getComparatorValue();
        $this->CustomTablesActionsObj->smarty->assign('timeValueArr',json_encode($timeValueArr,JSON_UNESCAPED_UNICODE));
        //报表信息
        $reportInfo = $this->CustomTablesActionsObj->getReportInfo($report_id);

        //模块信息
        $modules = $this->CustomTablesActionsObj->getReportModules($report_id);
        $reportInfo['selectedModules'] = implode(',',$modules);
        $this->CustomTablesActionsObj->smarty->assign("report_info",$reportInfo);

        if($_REQUEST['limitrecord'])
        {
            $this->CustomTablesActionsObj->smarty->assign("LimitRecord",$_REQUEST['limitrecord']);
        }
        else{
            $this->CustomTablesActionsObj->smarty->assign("LimitRecord",$this->limit);

        }
        $templatename = 'detailview.tpl';
        $this->CustomTablesActionsObj->smarty->assign("mode",'detail');
        $this->CustomTablesActionsObj->smarty->assign("iskehu001",isKehu001ServerPc());
        $this->CustomTablesActionsObj->smarty->assign("frommobile",$_REQUEST['frommobile']);
        if($_REQUEST['frommobile']=='yes'){
            //移动端查看页
            $corpurl_all = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST']. $_SERVER['PHP_SELF'];
            $corpurl_arr = explode('WeiXinApp',$corpurl_all);
            $this->CustomTablesActionsObj->smarty->assign("JSURL",$corpurl_arr[0]);
            $this->CustomTablesActionsObj->smarty->assign("CSSURL",$corpurl_arr[0]);
            $this->CustomTablesActionsObj->smarty->assign("CRMCOMMONURL",$corpurl_arr[0]);
            //zxm 20230423 app端的判断
            global $PlatformMC;
            if(array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
            {
                $encryptobj=new cls_MyCRMcrypt();
                $this->CustomTablesActionsObj->smarty->assign("wx_userid",$encryptobj->encode($_REQUEST['userid']));
                $this->CustomTablesActionsObj->smarty->assign("appusertoken",$_REQUEST['appusertoken']);
            }else{
                $this->CustomTablesActionsObj->smarty->assign("wx_userid",$_REQUEST['userid']);
            }

            //来自移动端
            global $weixin_user;
            if($weixin_user->environment=='wxwork'||$weixin_user->environment=='weixin'){
                //小程序
                $homefile = "index_mini.php";
            }else if(array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes') {
                //app
                $homefile = "indexnative.php";
            }else{
                //企业微信
                //云之家
                //钉钉
                $homefile = "index.php";
            }
            $this->CustomTablesActionsObj->smarty->assign("homefile",$homefile);
        }
        if($_REQUEST['isAjax']=="no"){
            $this->CustomTablesActionsObj->smarty->assign("isAjax",$_REQUEST['isAjax']);
            $this->CustomTablesActionsObj->smarty->display('CustomTables/'.$templatename);
        }else{
            $content = $this->CustomTablesActionsObj->smarty->fetch('CustomTables/'.$templatename);
            $_REQUEST['diony']='diony';
            $res['content'] = $content;
            $res['permit_print'] = isPermitted('ReportAnalysis','Print');
            $res['permit_export'] = isPermitted('ReportAnalysis','Export');
            $res['permit_create'] = isPermitted('ReportAnalysis','Create');
            $res['title'] = $reportInfo['report_name'];
            ConvertTojsonString(1,$res,'success');
        }

    }
    //ajax获取图表数据
    public function getDetailData()
    {

        //判断最终合计在顶部还是底部
        $total_position = $_REQUEST['total_position'];
        //是否显示明细
        $show_detail = $_REQUEST['show_detail'];//on
        //直接不显示明细 则明细sql不需要获得
        $sql_arr = [];
        $this->initParam();//初始化参数
        $this->conditionSql = $this->getDetailCondition();
        if(empty($show_detail)||$show_detail!="on") {
            //直接不显示明细 则明细sql不需要获得
        }else{
            $detail_sql = $this->getDetailedSql();//明细sql
            $sql_arr[] = $detail_sql;
        }

        //分组求和sql
        $group_count = count($this->groupcolumn_arr);

        $groupbysumsql = $this->getGroupBySumSql();//合计
        if(!empty($groupbysumsql)){
            $sql_arr[] = $groupbysumsql;
        }

        $maxsql=$this->getGroupByMaxSql();//最大值
        if(!empty($maxsql))
        {
            $sql_arr[] = $maxsql;
        }

        $minsql=$this->getGroupByMinSql();//获取最小值
        if(!empty($minsql))
        {
            $sql_arr[] = $minsql;
        }

        $countsql=$this->getGroupByCountSql();//计数
        if(!empty($countsql))
        {
            $sql_arr[] = $countsql;
        }

        $distinctcountsql=$this->getGroupByDistinctCountSql();//唯一计数

        if(!empty($distinctcountsql))
        {
            $sql_arr[] = $distinctcountsql;
        }
        $avgsql=$this->getGroupByAvgSql();//均值
        if(!empty($avgsql))
        {
            $sql_arr[] = $avgsql;
        }
        $sql_str = implode(' union all ',$sql_arr);
        $orderbycolumn_arr=$this->sqlOrdercolumn_arr;

        if(sizeof($orderbycolumn_arr))
            $orderby= implode(" ,",$orderbycolumn_arr);

        $GroupLeftJoinSql = '';
        if(sizeof($this->sorting_list_byresult)>0&&$this->show_detail!='yes')
        {
            //有统计结果排序的字段
            crm_load_class_file('cls_SetOrderBy','modules/CustomTables');
            $SetOrderByobj=new cls_SetOrderBy($this);
            $SetOrderByobj->setGroupLeftJoin();
            //设置分组排序的left join 子查询
            $GroupLeftJoinSql = $SetOrderByobj->groupLeftJoinSql;
            //设置分组排序的group by
            $orderbySql = " order by " .$SetOrderByobj->orderbySql;
        }else if(!empty($orderby)){
            $orderbySql = " order by $orderby " ;//zxm 20220722仅按列名排序的结果
        }
        $countsql="select 1 from ($sql_str)a";
        $pagenum=$_REQUEST['pagenum'];
        if(!isset($_REQUEST['totalrows'])||$_REQUEST['pagenum']<=1)
        {
            $result=$this->CustomTablesActionsObj->adb->pquery($countsql,array());

            $totalrows=$this->CustomTablesActionsObj->adb->num_rows($result);
        }
        else{
            $totalrows=$_REQUEST['totalrows'];
        }
        if(isset($_REQUEST['limitrecord']))
        {
            $this->limit=$_REQUEST['limitrecord'];
        }else{
            $this->limit=200;
        }
        if($_REQUEST['Export']=='true'){
            //导出 导出所有的数据 不分页
            $this->limit=$totalrows;
        }

        $fieldsFormulaArr = [];
        foreach($this->fieldsFormulaArr as $formulainfo)
        {
            foreach( $this->fieldsAlias as $tmpcolumn)
            {
                $formulainfo=str_replace($tmpcolumn,"a.$tmpcolumn",$formulainfo);
            }
            $fieldsFormulaArr[] = $formulainfo;
        }
        $fieldsAlias = [];
        foreach($this->fieldsAlias as $tmpcolumn){

            $tmpcolumn="a.$tmpcolumn";
            $fieldsAlias[] = $tmpcolumn;
        }
        $allFieldsArr = array_merge( $fieldsAlias, $fieldsFormulaArr);
        $allFieldsStr = implode(',',$allFieldsArr);
        if(!empty($orderbySql))
            $sql = "select $allFieldsStr,a.type,a.type_desc from ($sql_str)a   $GroupLeftJoinSql  $orderbySql ";
        else
            $sql = "select $allFieldsStr,a.type,a.type_desc from ($sql_str)a   $GroupLeftJoinSql order by  `type` asc";


        $totalpages = ceil($totalrows/$this->limit);
        $offset = ($pagenum-1)*$this->limit;
        $offset = $offset<=0?0:$offset;
        $sql .= " limit $offset,".$this->limit;
        $res = $this->CustomTablesActionsObj->adb->pquery($sql);
        $nums = $this->CustomTablesActionsObj->adb->num_rows($res);
        $html = '';
        if($nums){
            crm_load_class_file("ShowHtmlContent",'modules/CustomTables');
            $contentobj=new ShowHtmlContent($this);
            $contentobj->setPageNum($pagenum);
            $html=$contentobj->getContent($res);
            $total_sql = $this->getTotalSql();//所有数据求和的sql
            if(!empty($total_sql))
            {
                //合计行
                $result=$this->CustomTablesActionsObj->adb->pquery("select ".$allFieldsStr.",type,type_desc from ($total_sql) as a order by  `type` asc ");
                $html_total = $contentobj->getTotalRowContent($result);
                if($total_position == "top"){
                    $html = $html_total.$html;
                }else{
                    $html = $html.$html_total;
                }
            }
        }
        $_REQUEST['diony']='diony';
        //导出
        if($_REQUEST['Export']=='true'){
            $filename = $this->detailExport($html,$res);
            //返回文件路径
            ConvertTojsonString(1,['filename'=>$filename],'success');die;
        }

        global  $current_user, $languageType;
        $languageType = getLanguageType($current_user);

        $recordListRangeMsg = '';
        $totalrows = empty($totalrows)?0:$totalrows;
        $totalpages = empty($totalrows)?1:$totalpages;
        if ($languageType == 'zh') {
            $recordListRangeMsg .= ' ' . getFixedLabel('TOTALOF') . " $totalrows" . ' ' . getFixedLabel('RECORDNUMS');
        } else {
            $recordListRangeMsg .= " $totalrows" . ' ' . getFixedLabel('DETAILRECORDNUMS');
        }

        ConvertTojsonString(1,[
            'rows'=>$nums,
            'pagerows'=>$totalrows,
            'totalpages'=>$totalpages,//总页数
            'totaldescription'=>$recordListRangeMsg,
            'content'=>$html,
            'columnsCount'=>count($this->column_arr),
            'chartInfo'=>['legend'=>['上海','北京','深圳'],'datas'=>['190','280','89']]
//            'chartInfo'=>['legend'=>_array_column($this->data_arr,0),'datas'=>_array_column($this->data_arr,3)]
        ],'success');die;
    }
    //导出功能
    public function detailExport($html,$result){
        global $adb;
        $report_name = $_REQUEST['report_name'];
        $htmlparseobj = new simple_html_dom();


        $csc = explode("</tr>",$html);
        $csc=array_filter($csc);

        require_once( globalStatic::$root_directory.'PHPExcel/PHPExcel.php');
        $objPHPExcel = new PHPExcel();
        $objPHPExcel->setActiveSheetIndex(0);
        $activesheet = $objPHPExcel->getActiveSheet();
        $column_arr = $this->column_arr;
        //edit: xll 2023/08/03 BUG0070673 导出优化，系统导出的excel表格的表头应有底色，标题应加粗
        crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
        $Header_FromArray = cls_ExportListView::getListHeaderFormArray();
        foreach($column_arr as $key=>$column){
            $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key) . '1')->applyFromArray($Header_FromArray);
            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$column['fieldlabel']);
            $activesheet->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($key))->setWidth(20);
            $bigtype[]=$column['bigtype'];
        }
        $j = 2;

        foreach($csc as $kee=>&$arr) {
            $arr = explode("</td>", $arr);
        }

        //处理合并的数据
        foreach($csc as $kee=>$tmp_arr) {

            foreach ($tmp_arr as $keyy=>$value) {
                $rowspan = 0;
                $ismatch = preg_match('/rowspan="(.*?)"/u',$value,$match);
                if($ismatch==1){
                    $rowspan = $match[1];
                }

                if($rowspan>0){

                    for($k=1;$k<$rowspan;$k++){
                        array_splice($csc[$kee+$k],$keyy,0,'');
                    }
                }
            }
        }


        foreach($csc as $kee=>$tmparr){
            $cscs = $tmparr;
            if(!empty($result)){   //判断是否为小计行 XUQIU1001388
                $type_desc=$adb->query_result($result,$kee,'type_desc');
            }
            $for_i = 0;
            foreach ($cscs as $keyy=>$value) {

                if(stripos($value,'/ww-open-data')!==false)
                {
                    $htmlparseobj = new simple_html_dom();
                    $htmlparseobj->load($value);
                    $tmphtml_arr=$htmlparseobj->find('ww-open-data');
                    foreach($tmphtml_arr as $tmpparser)
                    {
                        $type=$tmpparser->type;
                        $openid=$tmpparser->openid;
                        if($type=='userName'){
                            $tmpparser->outertext ='$userName='.$openid.'$';
                        }
                        else if($openid!='')
                        {
                            $tmpparser->outertext ='$departmentName='.$openid.'$';
                        }
                    }
                    $value=$htmlparseobj->innertext;

                }
                $value = strip_tags(trim($value));
                $value = ltrim($value, '&nbsp;');
                if ($value == '&nbsp;') {
                    $value = '';
                }
                $value = str_replace('yen;', '¥', strip_tags($value));
                $value = decode_html($value);
                $tmpvalue = $value;

                $changetype = $bigtype[$keyy];
                //XUQIU1001388zl 判断是否需要取小数位数，导出格式与列表显示一致
                $decvalue = $tmpvalue;
                $arr_decimal = explode('.',$decvalue);
                $tmpdecimal=strlen($arr_decimal[1]);
                //拆分格式为字符串拼接，获取小数位数长度，拼接成新格式
                $tmpstr = '0.00';
                if (is_numeric($tmpdecimal)) {
                    $tmpstr = number_format($tmpstr, (int)$tmpdecimal);
                }

                //XUQIU1001388zl 替换货币符号,转换导出格式为货币
                $allCurrencies=["¥","￡","￥","$","€","AUD","ALL","HKD","TWD"];
                $changetype_number_arr = ['currency','amount','moduleno'];
                if(in_array($changetype,$changetype_number_arr)){
                    foreach ($allCurrencies as $currency) {
                        if (strpos($tmpvalue, $currency) !== false) {
                            $containcur = strpos($tmpvalue, $currency) ;
                            $tmpvalue = str_replace($currency, '', strip_tags($tmpvalue));
                        }
                    }
                    $tmpvalue = str_replace(',', '', strip_tags($tmpvalue));
                    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . $j)->getNumberFormat()->setFormatCode('#,##' . $tmpstr);
                }

                //XUQIU1001388zl 数字类型导出excel自定义可计算
                else if($changetype=="number"||$changetype=="num"){
                    $tmpvalue = str_replace(',', '', strip_tags($tmpvalue));
                    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . $j)->getNumberFormat()->setFormatCode($tmpstr);
                }

                $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($for_i) . $j,trim($tmpvalue),PHPExcel_Cell_DataType::TYPE_STRING);

                //XUQIU1001388zl 筛选报表小计行不做格式处理
                if($type_desc !='detail'){

                }
                //XUQIU1001388zl 筛选日期类型字段,修改导出格式为自定义
                else if($changetype == 'date')
                {
                    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i).$j)->getNumberFormat()->setFormatCode('yyyy-mm-dd');
                }
                else if($changetype == 'datetime')
                {
                    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i).$j)->getNumberFormat()->setFormatCode('yyyy-mm-dd hh:mm:ss');
                }

                ++$for_i;
            }
            ++ $j;
        }

        /*
        */

        $file_name = $report_name.'.xls';
        $file_name = str_replace('/','_',$file_name);
        $file_name = str_replace('\\','_',$file_name);
        $file_dir = globalStatic::$root_directory.'storage/';
        $objPHPExcel->getActiveSheet()->setTitle('OftenUseReport');
        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
        $objWriter->save($file_dir.$file_name);

        //BUG0053634	已解决	客户紧急	李金雪
        //https://61mis.com/WX/kh48789/）001通用问题：自定义统计表点击导出没反应
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        if(isKehu001ServerPc()=='yes')
        {

            $file_dir = 'storage/';
            $pathname=$file_dir.$file_name;
            require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
            $portobj=new cls_WeixinPort();



            $wx_downloadurl=  $portobj->UploadUserInfoFile(globalStatic::$root_directory.$pathname,$file_name);

            return $wx_downloadurl;
        }
        else
            return  './storage/'.$file_name;
    }

    //处理参数
    public function initParam(){

        $this->selectColumnTable_arr=[];
        $params = $_REQUEST;
        $this->module_arr = $params['selectedModules'];//选中的模块
        if(empty($this->module_arr)){
            //查看详情  模块选择不显示 导致传参为空
            $this->module_arr = $this->CustomTablesActionsObj->getReportModules($_REQUEST['report_id']);
        }else{
            $this->module_arr = explode(',',$this->module_arr);
        }

        $this->mainmodule = $this->module_arr[0];
        $focus=CRMEntity::getInstance($this->mainmodule);

        $this->selectColumnFrom=$focus->table_name;
        $this->selectColumnTable_arr[]=$focus->table_name;

        $this->relatedModule = array_slice($this->module_arr,1);
        //是否显示明细
        $show_detail = $params['show_detail'];
        $this->show_detail = $show_detail=="on"?'yes':'no';

        //统计字段处理
        $columns = $params['columns'];//统计字段
        $columnmodule = $params['columnmodule'];//统计字段所属模块
        $modulelabel = $params['modulelabel'];//统计字段来自模块名称
        $fieldlabel = $params['fieldlabel'];//统计字段名称
        $bigtype = $params['bigtype'];//统计字段bigtype
        $typeofdata = $params['typeofdata'];//统计字段typeofdata
        $is_group = $params['is_group'];//统计字段是否是分组条件
        $order_by = $params['order_by'];//统计字段排序条件
        $is_merge_arr = $params['is_merge'];//统计字段是否合并
        $total_type = $params['total_type'];//统计字段是否合并
        $align = $params['align'];//统计字段对齐方式
        $alias = $params['alias'];//统计字段别名
        $prefix = $params['prefix'];//前缀
        $suffix = $params['suffix'];//后缀
        $decimal_places = $params['decimal_places'];//小数位数
        $issticky = $params['issticky'];//是否列固定

        $alias_flip = array_flip($alias);//统计字段别名键值反转
        $modulefieldseq=0;
        $prevmodule='';
        $regex3 = "/\{(.+?)\}/"; // {} 花括号，大括号 正则
        $prevmodule='';
        //统计字段主表自定义字段 zxm-2021-12-10

        //排序设置-数据 zxm20220718
        $select_sql = " select * from ld_customtable_sorting where report_id=? order by sequence asc ";
        $select_res = $this->CustomTablesActionsObj->adb->pquery($select_sql,array($_REQUEST['report_id']));
        $select_nums = $this->CustomTablesActionsObj->adb->num_rows($select_res);
        $sorting_list_all = [];//排序设置所有的值
        $sorting_list_bycolumnname = [];//排序设置按列名称排序的值
        $sorting_list_byresult = [];//按统计结果排序的设置

        if($select_nums>=1){
            for($i=0;$i<$select_nums;$i++){
                $tmp_columns = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'columns');
                $sorting_list_all[$i]['report_id'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'report_id');
                $sorting_list_all[$i]['sorttype'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'sorttype');
                $sorting_list_all[$i]['columnmodule'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'columnmodule');
                $sorting_list_all[$i]['columns'] = $tmp_columns;
                $sorting_list_all[$i]['sortmethod'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'sortmethod');
                $sorting_list_all[$i]['sequence'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'sequence');
                $sorting_list_all[$i]['total_type'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'total_type');

                $tmp_columns_arr = explode(":",$tmp_columns);
                $tmp_column_name = $tmp_columns_arr[1];
                $tmp_table_name = $tmp_columns_arr[0];
                $sorting_list_all[$i]['aliasname'] = $tmp_table_name.$this->asfixedname.$tmp_column_name;

                if($sorting_list_all[$i]['sorttype']=='byresult'){
                    $sorting_list_byresult[$i] = $sorting_list_all[$i];
                }
                if($sorting_list_all[$i]['sorttype']=='bycolumnname'){
                    $sorting_list_bycolumnname[$sorting_list_all[$i]['columns']] = $sorting_list_all[$i]['sortmethod'];//仅有按列名排序的话  只需要这两个值
                }
            }
        }
        $this->sorting_list_all = $sorting_list_all;
        $this->sorting_list_byresult = $sorting_list_byresult;
        $this->sorting_list_bycolumnname = $sorting_list_bycolumnname;

        foreach($this->module_arr as $tmpmodule_index=> $tmpmodulename)
        {
            //添加了5个模块，中间两个模块没有字段在界面显示
            $tmpfocus=CRMEntity::getInstance($tmpmodulename);

            $tmp_tablename=$tmpfocus->table_name;
            if(!in_array($tmp_tablename,$this->selectColumnTable_arr))
            {
                if(!empty($prevmodule)&&$prevmodule!=$tmpmodulename)
                {

                    $tmp_curcolumn_module=$curcolumn_module_arr[0];




                    $relatetablejoinobj = cls_TableJoin_module::getInstance($prevmodule, $tmpmodulename);
                    $relatetablejoinobj->hadJoinTable_arr=$this->selectColumnTable_arr;
                    $join_arr= $relatetablejoinobj->getJoin();

                    if($tmpmodule_index==1)
                    {
                        $join_arr['joinsqltype']=' inner join ';

                    }
                    $this->selectColumnFrom.=$join_arr['joinsqltype'].$join_arr['joinsql'];
                    $this->selectColumnTable_arr[]=$tmpfocus->table_name;

                    if(!in_array($tmpfocus->table_name,$join_arr['jointable'])
                        &&in_array($tmpfocus->Detail_table,$join_arr['jointable']))
                    {
                        $detail_table=$tmpfocus->Detail_table;

                        $this->selectColumnTable_arr=array_merge($this->selectColumnTable_arr,$join_arr['jointable']);
                        $Detail_table_index=$tmpfocus->Detail_table_index;
                        $this->selectColumnFrom.=" inner join ". $tmpfocus->table_name."   on $detail_table.$Detail_table_index=".$tmpfocus->table_name.'.'.$tmpfocus->table_index.' and '.$tmpfocus->table_name.'.deleted=0';

                    }

                }

                if(!in_array($tmp_tablename,$this->selectColumnTable_arr))
                {
                    //自定义字段自定义表
                    $tmp_maintablename=$tmpfocus->table_name;
                    $tmp_tableindex=$tmpfocus->table_index;

                    $this->selectColumnFrom.="  left join $tmp_tablename on  $tmp_tablename.$tmp_tableindex=$tmp_maintablename.$tmp_tableindex " ;
                    $this->selectColumnTable_arr[]=$tmp_tablename;

                }
            }
            $prevmodule=$tmpmodulename;
        }
        foreach($columns as $tmpFieldinfo)
        {
            //跨模块分组字段  排序要使用另外一个模块的字段
            $tmpFieldinfo_arr=explode(":",$tmpFieldinfo);
            $temp_table = $tmpFieldinfo_arr[0];
            $temp_field_module_arr=explode("_",$tmpFieldinfo_arr[3]);
            $temp_field_focus = CRMEntity::getInstance($temp_field_module_arr[0]);

            if(in_array($temp_table,$temp_field_focus->customFieldTable)&&!in_array($temp_table,$this->selectColumnTable_arr))
            {
                //求和字段是自定义表
                $this->selectColumnFrom.=" left  join $temp_table on ".$temp_field_focus->table_name.".".$temp_field_focus->table_index."=$temp_table.".$temp_field_focus->table_index;
                $this->selectColumnTable_arr[]=$temp_table;
            }

        }

        $prevmodule='';

        foreach($this->module_arr as $tmpmodule_index=> $tmpmodulename)
        {

            $modulefieldseq=sizeof($this->fieldsAlias);
            $tmpfocus=CRMEntity::getInstance($tmpmodulename);
            foreach($columns as $k=>$columnVal){
                if($total_type[$k]=='formula'&&$tmpmodule_index==0){
                    $temp_formula = $columns[$k];
                    $temp_res = preg_replace_callback($regex3,function($matches) use($alias,$alias_flip,$columns){
                        //Array ( [0] => {E} [1] => E )
                        //解析公式
                        //判断除数为0
                        if(isset($matches[1])&&in_array($matches[1],$alias)){
                            $flipkey =  $alias_flip[$matches[1]];
                            $temp_column = $columns[$flipkey];
                            $temp_column = explode(':',$temp_column);
                            return ' ifnull('.$temp_column[0].$this->asfixedname.$temp_column[1].',0) ';
                        }
                    },$temp_formula);
                    //BUG0053208	已分派	严重	zxm
                    //报表管理-自定义统计表-BPW市场信息收集表-终端客户市场占比分析表 表格里“占比”字段，计算公式的结果应该为0，表格显示却是1
                    $this->fieldsFormulaArr[] = 'ifnull('.$temp_res.',0) as '.$alias[$k];
                    continue;
                }
                if($columnmodule[$k]!=$tmpmodulename)
                {
                    continue;
                }
                $col_arr=explode(':',$columnVal);
                $tmp_tablename=$col_arr[0];
                $isdetailfield='no';

                if(in_array($tmp_tablename,$tmpfocus->tab_name ))
                {
                    $fieldinfo=$tmpfocus->fieldobj->getFieldInfoobjBykey("columnname",$col_arr[1]);
                    if(!in_array($tmp_tablename,$this->selectColumnTable_arr))
                    {
                        if($tmpfocus->customFieldTable[0]==$tmp_tablename)
                        {

                            $tmp_maintablename=$tmpfocus->table_name;
                            $tmp_tableindex=$tmpfocus->table_index;

                            $this->selectColumnFrom.="  left join $tmp_tablename on  $tmp_tablename.$tmp_tableindex=$tmp_maintablename.$tmp_tableindex " ;
                            $this->selectColumnTable_arr[]=$tmp_tablename;

                        }
                    }
                }
                else{
                    $fieldinfo=$tmpfocus->detailfieldobj->getFieldInfoobjBykey("columnname",$col_arr[1]);
                    $isdetailfield='yes';
                    if(!in_array($tmp_tablename,$this->selectColumnTable_arr))
                    {
                        $Detail_table_index=$tmpfocus->Detail_table_index;
                        $tmp_maintablename=$tmpfocus->table_name;
                        $tmp_tableindex=$tmpfocus->table_index;
                        $Detail_table=$tmpfocus->Detail_table;
                        //if($tmp_tablename==$tmpfocus->Detail_table||$tmp_tablename==$tmpfocus->Detail_table_scf)
                        $Detail_table_id=$tmpfocus->Detail_table_id;

                        if(!in_array($Detail_table,$this->selectColumnTable_arr)){
                            $this->selectColumnFrom.="  inner join $Detail_table on  $Detail_table.$Detail_table_index=$tmp_maintablename.$tmp_tableindex " ;
                        }
                        if($tmp_tablename==$tmpfocus->Detail_table_scf)
                        {
                            $this->selectColumnFrom.=" left  join $tmp_tablename on  $tmp_tablename.$Detail_table_id=$Detail_table.$Detail_table_id ";
                            $this->selectColumnTable_arr[]=$tmp_tablename;
                        }
                        if(get_file_address($columnmodule[$k],'ProductDetails')&&($tmp_tablename=='ld_products'||$tmp_tablename=='ld_productcf'))
                        {

                            if(!in_array('ld_products',$this->selectColumnTable_arr)){
                                $this->selectColumnFrom.=" left  join ld_products on  ld_products.productid=$Detail_table.productid ";
                                $this->selectColumnTable_arr[]='ld_products';
                            }
                            //zxm 20220111 选择明细字段有产品表自定义表的字段的时候
                            if($tmp_tablename=='ld_productcf'){
                                $this->selectColumnFrom.=" left  join ld_productcf on  ld_products.productid=ld_productcf.productid ";
                                $this->selectColumnTable_arr[]=$tmp_tablename;
                            }
                        }
                        $this->selectColumnTable_arr[]=$Detail_table;

                    }

                }
                $prevmodule=$tmpmodulename;

                //分组字段
                if($is_group[$k]=="yes"){
                    $this->groupcolumn_arr[$modulefieldseq] = $columnVal;
                }else{
                    //设置了分组的字段 统计方式失效
                    $temp_total_type = explode(',',$total_type[$k]);
                    if(!empty($temp_total_type)&&in_array("sum",$temp_total_type)){
                        $this->sumcolumn_arr[$modulefieldseq] = $columnVal;
                    }
                    if(!empty($temp_total_type)&&in_array("count",$temp_total_type)){
                        $this->countcolumn_arr[$modulefieldseq] = $columnVal;
                    }
                    if(!empty($temp_total_type)&&in_array("max",$temp_total_type)){
                        $this->maxcolumn_arr[$modulefieldseq] = $columnVal;
                    }
                    if(!empty($temp_total_type)&&in_array("min",$temp_total_type)){
                        $this->mincolumn_arr[$modulefieldseq] = $columnVal;
                    }
                    if(!empty($temp_total_type)&&in_array("avg",$temp_total_type)){
                        $this->avgcolumn_arr[$modulefieldseq] = $columnVal;
                    }
                    if(!empty($temp_total_type)&&in_array("distinct_count",$temp_total_type)){
                        $this->distinctcountcolumn_arr[$modulefieldseq] = $columnVal;
                    }
                }

                if($is_merge_arr[$k]=='yes')
                {
                    $this->mergeColumn_arr[]=$columnVal;
                }
                //统计字段处理
                $temp_columns_arr = explode(':',$columnVal);
                if($fieldinfo->getBigType()=='currency')
                {
                    //币种
                    //$this->fields[$modulefieldseq] =" concat( ".$tmpfocus->table_name.'.currency_symbol ,'.$temp_columns_arr[0].".".$temp_columns_arr[1].") as ".$temp_columns_arr[0].$this->asfixedname.$temp_columns_arr[1];
                    $this->fields[$modulefieldseq] =$temp_columns_arr[0].".".$temp_columns_arr[1]." as ".$temp_columns_arr[0].$this->asfixedname.$temp_columns_arr[1];
                    $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];//加上$k 防止两个表的相同字段
                    $modulefieldseq++;

                    $currency_symbolinfo=$tmpfocus->fieldobj->getFieldInfoobjBykey("columnname",'currency_id');
                    //币种字段不存在则不查询该字段
                    if($currency_symbolinfo){
                        $currency_symbol_field = $tmpfocus->table_name.'.currency_symbol';
                    }else{
                        $currency_symbol_field = '"¥"';
                    }
                    if(!in_array($tmpfocus->table_name.'currency_symbol',$this->fieldsAlias)){
                        $this->fields[$modulefieldseq] = $currency_symbol_field.' as '. $tmpfocus->table_name.'currency_symbol';
                        $this->fieldsAlias[$modulefieldseq] = $tmpfocus->table_name.'currency_symbol';
                        $this->fieldsCurrencySymbol[] = $tmpfocus->table_name.'currency_symbol';
                        $modulefieldseq++;
                    }
                }
                else if($fieldinfo->getBigType()=='moduleno'){
                    $this->fields[$modulefieldseq] = $temp_columns_arr[0] . "." . $temp_columns_arr[1] . " as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                    $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];//加上$k 防止两个表的相同字段
                    $modulefieldseq++;


                    $this->fields[$modulefieldseq] = $temp_columns_arr[0] . "." . $tmpfocus->table_index. " as " . $temp_columns_arr[0] . $this->asfixedname . $tmpfocus->table_index;
                    $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $tmpfocus->table_index;//加上$k 防止两个表的相同字段
                    $modulefieldseq++;
                }
                else if($fieldinfo->getUIType()==70&&$isdetailfield=='yes')
                {
                    $this->fields[$modulefieldseq] = $temp_columns_arr[0] . ".productid as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                    //zxm 20220720  用产品名字
                    //$this->fields[$modulefieldseq] = $temp_columns_arr[0] . ".productname as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                    $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];//加上$k 防止两个表的相同字段
                    $modulefieldseq++;
                }
                else{
                    $this->fields[$modulefieldseq] = $temp_columns_arr[0] . "." . $temp_columns_arr[1] . " as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                    $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];//加上$k 防止两个表的相同字段
                    $modulefieldseq++;
                }
            }
        }
        $this->sumcolumn_arr=array_values($this->sumcolumn_arr);
        $this->maxcolumn_arr=array_values($this->maxcolumn_arr);
        $this->mincolumn_arr=array_values($this->mincolumn_arr);
        $this->countcolumn_arr=array_values($this->countcolumn_arr);
        $this->distinctcountcolumn_arr=array_values($this->distinctcountcolumn_arr);
        $firstcolumn=$columns[0];
        if(in_array($firstcolumn,$this->sumcolumn_arr))
        {
            //获取第一列是否求和
            $this->firstrColumnComputer_type[]=$this->sum_type;

        }
        if(in_array($firstcolumn,$this->maxcolumn_arr))
        {

            $this->firstrColumnComputer_type[]=$this->max_type;

        }
        if(in_array($firstcolumn,$this->mincolumn_arr))
        {

            $this->firstrColumnComputer_type[]=$this->min_type;

        }
        if(in_array($firstcolumn,$this->distinctcountcolumn_arr))
        {

            $this->firstrColumnComputer_type[]=$this->distinctcount_type;

        }
        if(in_array($firstcolumn,$this->countcolumn_arr))
        {

            $this->firstrColumnComputer_type[]=$this->count_type;

        }
        $ordercolumn=$this->ordercolumn_suff;
        $orderbycolumn_arr=[];
        $show_detail = $this->show_detail;
//        if($show_detail == 'yes'){
        //如果不显示详情  则直接按用户选择的字段排序--这样也有问题  先去掉
        $tmpsize=sizeof($this->groupcolumn_arr);
        foreach($this->groupcolumn_arr as $tmpindex=> $groupcolumninfo )
        {
            $tmpgroupcolumn_arr=explode(":",$groupcolumninfo);
            $tmpcolumn=$tmpgroupcolumn_arr[1];
            $tablename=$tmpgroupcolumn_arr[0];
            $searchindex=array_search($groupcolumninfo,$columns);
//print_r($sorting_list_bycolumnname);die;
//print_r($order_by);
//print_r($columns);
//dump($groupcolumninfo);
            $orderbycolumn_arr[]=$tablename.$this->asfixedname.$tmpcolumn.$ordercolumn;
            /*  if($tmpsize>1 && $tmpindex==$tmpsize-1)
               {
                    $this->sqlOrdercolumn_arr[]=$tablename.$this->asfixedname.$tmpcolumn.'    desc';
               }
              else*/
            // if($order_by[$searchindex]!='no')
            //zxm 20220720 仅有按列名排序的排序设置
            if(isset($sorting_list_bycolumnname[$groupcolumninfo])){
                if($tmpcolumn=='productname'){
                    //产品名称的时候 特殊处理 zxm BUG0054462
                    $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.$this->ordercolumn_suff.',"") USING gbk) '.$sorting_list_bycolumnname[$groupcolumninfo];
                }else{
                    $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.',"") USING gbk) '.$sorting_list_bycolumnname[$groupcolumninfo];
                }
            }
            else{
                if($tmpcolumn=='productname') {
                    //产品名称的时候 特殊处理 zxm BUG0054462
                    $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.$this->ordercolumn_suff.',"") USING gbk) asc ';
                }else{
                    $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.',"") USING gbk) asc ';
                }
            }
            //$this->sqlOrdercolumn_arr[]=$tablename.$this->asfixedname.$tmpcolumn.$ordercolumn.' asc ';
            $this->fields[$modulefieldseq] = $tablename.".".$tmpcolumn." as ".$tablename.$this->asfixedname.$tmpcolumn.$ordercolumn;
            $this->fieldsAlias[$modulefieldseq]= $tablename.$this->asfixedname.$tmpcolumn.$ordercolumn;//加上$k 防止两个表的相同字段
            $modulefieldseq++;
        }

        if(sizeof($this->sqlOrdercolumn_arr)>0)
        {
            $this->sqlOrdercolumn_arr[]=' type asc ';
        }

//dump($this->sqlOrdercolumn_arr);
//        }
        $this->ordercolumn_arr=$orderbycolumn_arr;
        foreach($columns as $k=>$columnVal) {

            $tmp_arr = explode(":", $columnVal);
            $column_tablename = $tmp_arr[0];
            $colum_module = $columnmodule[$k];
            $column_focus = CRMEntity::getInstance($colum_module);
            $typeofdata_decimal = 2;
            $uitype = 0;
            $fieldtype = '';
            $fieldinfo = '';
            if (in_array($column_tablename, $column_focus->tab_name)) {
                $fieldinfo = $column_focus->fieldobj->getFieldInfoobjBykey("columnname", $tmp_arr[1]);
                if(!empty($fieldinfo)){
                    $uitype = $fieldinfo->getUIType();
                    $tmptypeofdata = $fieldinfo->getTypeOfData();
                    $typeofdatas = explode(',', $tmptypeofdata);
                    if(sizeof($typeofdatas)>1)
                    {
                        $typeofdata_decimal=$typeofdatas[1];
                    }
                }
                $isdetailfield = 'no';

            } else if ($total_type[$k] != 'formula') {
                //zxm 2022-0124 公式字段要排除
                $fieldinfo = $column_focus->detailfieldobj->getFieldInfoobjBykey("columnname", $tmp_arr[1]);

                if(!empty($fieldinfo)){
                    $uitype = $fieldinfo->getUIType();
                    $fieldtype = $fieldinfo->getFieldType();
                    $tmptypeofdata = $fieldinfo->getTypeOfData();
                    $typeofdatas = explode(',', $tmptypeofdata);
                    if(sizeof($typeofdatas)>1)
                    {
                        $typeofdata_decimal=$typeofdatas[1];
                    }
                }
                $isdetailfield = 'yes';
            }
            //zkt 20221110 XUQIU1000804 单据头和单据分录“金额货币”类型的字段允许自定义小数位数
            if(!empty($fieldinfo)){
                if($fieldinfo->isAmountorCurrencyField()){
                    $decimal_places[$k] = $typeofdata_decimal;
                }
            }
            $this->column_arr[$k]['uitype'] = $uitype;
            $this->column_arr[$k]['fieldtype'] = $fieldtype;
            $this->column_arr[$k]['isdetailfield'] = $isdetailfield;
            $this->column_arr[$k]['columns'] = $columnVal;
            $this->column_arr[$k]['columnmodule'] = $columnmodule[$k];
            $this->column_arr[$k]['modulelabel'] = $modulelabel[$k];
            $this->column_arr[$k]['fieldlabel'] = $fieldlabel[$k];
            $this->column_arr[$k]['bigtype'] = $bigtype[$k];
            $this->column_arr[$k]['typeofdata'] = $typeofdata[$k];
            $this->column_arr[$k]['is_group'] = $is_group[$k];
            $this->column_arr[$k]['order_by'] = $order_by[$k];
            $this->column_arr[$k]['merge'] = $is_merge_arr[$k];
            $this->column_arr[$k]['total_type'] = $total_type[$k];
            $this->column_arr[$k]['align'] = $align[$k];
            $this->column_arr[$k]['alias'] = $alias[$k];
            $this->column_arr[$k]['prefix'] = $prefix[$k];
            $this->column_arr[$k]['suffix'] = $suffix[$k];
            $this->column_arr[$k]['decimal_places'] = $decimal_places[$k];
            $this->column_arr[$k]['issticky'] = $issticky[$k];
            //统计字段处理
            $temp_columns_arr = explode(':', $columnVal);
            //zxm 20220720  仅有按列名排序的排序设置 以前的排序方法去掉不用了
//                if($order_by[$k]!='no')
//                {
//                     $this->sqlOrdercolumn_arr[]=$temp_columns_arr[0].$this->asfixedname.$temp_columns_arr[1].' '.$order_by[$k];
//                }
            //zxm 20220720  仅有按列名排序的排序设置
            if (isset($sorting_list_bycolumnname[$columnVal])&&$is_group[$k]!='yes'){
                $this->sqlOrdercolumn_arr[] = 'CONVERT(ifnull('.$temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1] . ',"") USING gbk) ' . $sorting_list_bycolumnname[$columnVal];
            }
            if($total_type[$k]=='formula'){
                $this->fieldsTableHeader[$k] = $alias[$k];
            }else{
                $this->fieldsTableHeader[$k] = $temp_columns_arr[0].$this->asfixedname.$temp_columns_arr[1];//加上$k 防止两个表的相同字段
            }
        }
//         dump($this->sqlOrdercolumn_arr);
        //zxm 20220721 为了排序  合并字段的排序需要设置到最后
        foreach($this->mergeColumn_arr as $mergecolumninfo)
        {
            $tmpgroupcolumn_arr=explode(":",$mergecolumninfo);
            $tmpcolumn=$tmpgroupcolumn_arr[1];
            $tablename=$tmpgroupcolumn_arr[0];
            if(!in_array($tablename.$this->asfixedname.$tmpcolumn,$orderbycolumn_arr))
            {
                $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.',"") USING gbk) asc ';
            }
        }
    }



    public function getDetailCondition(){
        //总的条件
        global $current_user;
        $allModules = $this->module_arr;
        $moduleCondition_arr=[];
        $condition_arr=[];
        //获取条件数据
        $cvadvfilter = $_REQUEST['cvadvfilter'];
        $comparator_arr = $_REQUEST['comparator'];
        $groupid = $_REQUEST['groupid'];//条件所属分组id
        $columncondition = $_REQUEST['columncondition'];//组内条件之间的关系
        $value1_arr = $_REQUEST['value1'];
        $value2_arr = $_REQUEST['value2'];
        $conditionArr = [];
        //获取条件分组数据 zxm 20220630
        $group_condition_id = $_REQUEST['group_condition_id'];
        $group_condition = $_REQUEST['group_condition'];
        $group_condition_arr = [];
        foreach ($group_condition_id as $ck=>$cv){
            $group_condition_arr[$cv] = $group_condition[$ck];
        }
        // todo

        foreach($cvadvfilter as $condKey =>$conditionColumn){
            $temp_column = explode(':',$conditionColumn);
            $temp_table =  $temp_column[0];
            $tmpmodule_arr=explode("_",$temp_column[3]);
            $tmpmodule=$tmpmodule_arr[0];
            $temp_comparator = $comparator_arr[$condKey];
            //zxm 2022-6-9 0052267  1、报表分析-（费用报销单-合同汇总）-编辑条件-合同名称不为空点搜索无效（开发部账套也是一样）
            //2、报表分析-（费用报销单-合同汇总）-对合同名称分组，统计不出来数据（合同名称是分录中源单合同订单引用过来的，估计是因为这个）
            if(($temp_comparator!='isnull'&&$temp_comparator!='isnotnull')&&trim($value1_arr[$condKey])=='')
                continue;
            if($temp_comparator=='bw')
            {
                $moduleCondition_arr[$tmpmodule][]=array(
                    'column'=>$conditionColumn,
                    'comparator'=>$comparator_arr[$condKey],
                    'value'=>$value1_arr[$condKey].','.$value2_arr[$condKey],
                    'groupid'=>$groupid[$condKey],
                    'columncondition'=>$columncondition[$condKey]
                );
            }
            else{
                $moduleCondition_arr[$tmpmodule][]=array(
                    'column'=>$conditionColumn,
                    'comparator'=>$comparator_arr[$condKey],
                    'value'=>$value1_arr[$condKey],
                    'groupid'=>$groupid[$condKey],
                    'columncondition'=>$columncondition[$condKey]
                );
            }
        }
        //zxm 20231009 高级查找条件为空
        if(empty($moduleCondition_arr)||sizeof($moduleCondition_arr)<=0){
            return '';
        }
        //主表条件
        $mainWhere = [];
        $mainWhereDeleted = '';
        $tableIndexField = [];
        $DetailDableIdField = [];
        $tables = [];
        $hadTable_arr=[];
        //获取主sql的各表的索引字段条件  例：accountid in (983,2)
        $this->wheremodule_arr=[];
        foreach($allModules as $k=>$tempModule){
            $currModule = $allModules[$k];
            $currModuleFocus = CRMEntity::getInstance($currModule);
            $currTable = $currModuleFocus->table_name;
            $currTableIndex = $currModuleFocus->table_index;

            if($k==0){
                //第一个模块
                $tableIndexField[$k] = $currTable.'.'.$currTableIndex;
                $mainWhere[]=$currTable.'.deleted=0 ';
                $mainWhereDeleted = $currTable.'.deleted=0 ';//主表的deleted条件 zxm 20220630
                $tables[] = $currTable;
                $hadTable_arr[]=$currTable;
            }else{
                $prevModule = $allModules[$k-1];
                $relatetablejoinobj = cls_TableJoin_module::getInstance($prevModule, $currModule);
                $tmpjoin_arr = $relatetablejoinobj->getJoin();
                $tableIndexField[$k] = $currTable.'.'.$currTableIndex;
                $hadTable_arr=array_merge($hadTable_arr,$tmpjoin_arr['jointable']);
                if($k==1)
                {
                    $tmpjoin_arr['joinsqltype']=' inner join ';
                }
                //if(in_array($currTable,$tmpjoin_arr['jointable'])) {
                $tables[] = $tmpjoin_arr['joinsqltype'] . " " . $tmpjoin_arr['joinsql'] ;
                //}else{
                //$tables[] = $tmpjoin_arr['joinsql'];
                //}
                if(!in_array($currModuleFocus->table_name,$tmpjoin_arr['jointable'])
                    &&in_array($currModuleFocus->Detail_table,$tmpjoin_arr['jointable']))
                {
                    $detail_table=$currModuleFocus->Detail_table;

                    $this->selectColumnTable_arr=array_merge($this->selectColumnTable_arr,$tmpjoin_arr['jointable']);
                    $Detail_table_index=$currModuleFocus->Detail_table_index;
                    $tables[]=" inner join ". $currModuleFocus->table_name."   on $detail_table.$Detail_table_index=".$currModuleFocus->table_name.'.'.$currModuleFocus->table_index.' and '.$currModuleFocus->table_name.'.deleted=0 ';
                    $hadTable_arr[]=$detail_table;

                }

            }
            if(array_key_exists($tempModule,$moduleCondition_arr))
            {
                $this->wheremodule_arr[]=$tempModule;
                foreach($moduleCondition_arr[$tempModule] as $conditionindex=>$conditionInfo)
                {

                    $reportwhereobj=new ReportTableWhere($tempModule);

                    $reportwhereobj->setWhereColumn($conditionInfo['column']);
                    $reportwhereobj->setComparator($conditionInfo['comparator']);
                    $reportwhereobj->setSearchText($conditionInfo['value']);
                    $tmpwhere=$reportwhereobj->getWhere();

                    foreach($reportwhereobj->querygeneratoryobj->whereMainTable as $tmptablename=>$leftjoin)
                    {
                        if(!in_array($tmptablename,$hadTable_arr))
                        {
                            if($tmptablename==$currModuleFocus->customFieldTable[0])
                            {
                                //自定义表
                                $tables[]=" left join  $tmptablename on $tmptablename.$currTableIndex=$currTable.$currTableIndex ";

                            }
                            else if($tmptablename==$currModuleFocus->Detail_table)
                            {
                                $Detail_table_index=$currModuleFocus->Detail_table_index;
                                $tables[]=" inner join  $tmptablename on $tmptablename.$Detail_table_index=$currTable.$currTableIndex ";
                                $Detail_table_id=$currModuleFocus->Detail_table_id;
                                $DetailDableIdField[] = $tmptablename.'.'.$Detail_table_id;//明细表的lineitem_id   //zxm 20221012 查询条件是明细表的字段
                            }
                            else if($tmptablename==$currModuleFocus->Detail_table_scf)
                            {
                                $detail_table=$currModuleFocus->Detail_table;
                                $Detail_table_id=$currModuleFocus->Detail_table_id;

                                $tables[]=" inner join  $detail_table on $detail_table.$Detail_table_index=$currTable.$currTableIndex ";

                                $tables[]=" left join  $tmptablename on $tmptablename.$Detail_table_id=$detail_table.$Detail_table_id ";
                                $hadTable_arr[]=$detail_table;
                                $DetailDableIdField[] = $detail_table.'.'.$Detail_table_id;//明细表的lineitem_id //zxm 20221012 查询条件是明细表的字段
                            }
                            else {
                                $tables[]= ' left join '.$leftjoin;

                                $hadTable_arr[]=$tmptablename;
                            }
                            $hadTable_arr[]=$tmptablename;
                        }
                    }


                    foreach($reportwhereobj->querygeneratoryobj->whereDetailTable  as  $tmptablename=>$tmpleftjoin)
                    {
                        if(!in_array($tmptablename,$hadTable_arr))
                        {
                            if($tmptablename==$currModuleFocus->Detail_table)
                            {
                                $Detail_table_index=$currModuleFocus->Detail_table_index;
                                $tables[]=" inner join  $tmptablename on $tmptablename.$Detail_table_index=$currTable.$currTableIndex ";
                                $hadTable_arr[]=$tmptablename;
                                $Detail_table_id=$currModuleFocus->Detail_table_id;
                                $DetailDableIdField[] = $tmptablename.'.'.$Detail_table_id;//明细表的lineitem_id //zxm 20221012 查询条件是明细表的字段
                            }
                            else if($tmptablename==$currModuleFocus->Detail_table_scf)
                            {
                                $detail_table=$currModuleFocus->Detail_table;
                                $Detail_table_id=$currModuleFocus->Detail_table_id;
                                $DetailDableIdField[] = $detail_table.'.'.$Detail_table_id;//明细表的lineitem_id //zxm 20221012 查询条件是明细表的字段
                                if(!in_array($detail_table,$hadTable_arr))
                                {
                                    $tables[]=" inner join  $detail_table on $detail_table.$Detail_table_index=$currTable.$currTableIndex ";
                                    $hadTable_arr[]=$detail_table;
                                }
                                $tables[]=" left join  $tmptablename on $tmptablename.$Detail_table_id=$detail_table.$Detail_table_id ";
                                $hadTable_arr[]=$tmptablename;

                            }else if($tmptablename=='ld_products'){
                                //BUG0053953	已分派	系统错误	zxm
                                //报表管理》产品销量排行榜（按出库金额）》点击后里面有数据，添加产品名称模糊搜索条件  没数据了
                                $tables[] = " left join ".$tmpleftjoin;
                                $hadTable_arr[]=$tmptablename;
                            }
                        }
                    }
                    $mainWhere[]=$tmpwhere;
                    //组合条件 所有的条件
                    $conditionInfo['sql'] = $tmpwhere;
                    $condition_arr[$conditionInfo['groupid']][] = $conditionInfo;

                }
            }
        }
        $mainWhereStr = '';//最后的条件 zxm 20220630 组合条件
        foreach($condition_arr as $groupidkey=>$groupcoditionvalue){
            $groupcoditionvalue_temp = '';
            foreach($groupcoditionvalue as $conditionkey=>$conditionvalue){
                if($conditionkey==0){
                    $groupcoditionvalue_temp = $conditionvalue['sql'];
                }else{

                    $groupcoditionvalue_temp .= $conditionvalue['columncondition'] . ' ' .$conditionvalue['sql'];
                }
            }
            $group_condition_temp = isset($group_condition_arr[$groupidkey])?$group_condition_arr[$groupidkey]:'';
            $mainWhereStr .= $group_condition_temp . '('.$groupcoditionvalue_temp.')';
            $condition_arr[$groupidkey] = $groupcoditionvalue_temp;
        }
        if(!empty($mainWhereStr)){
            $mainWhereStr = $mainWhereDeleted .' and '.$mainWhereStr;
        }else{
            $mainWhereStr = $mainWhereDeleted;
        }
        $this->DetailDableIdField = array_unique($DetailDableIdField);//zxm 20221012 查询条件是明细表的字段
        //$tableIndexField = array_merge($DetailDableIdField,$tableIndexField);//明细表的lineitem_id
        if(!empty($DetailDableIdField)&&!empty($DetailDableIdField[0])){
            $tableIndexField[] = $DetailDableIdField[0];
        }

        $tableIndexField = array_unique($tableIndexField);
        $tableIndexField = implode(',',$tableIndexField);
        //数据范围
        global $current_user;
        $currUserid = $current_user->id;
        $mainmoduleFocus = CRMEntity::getInstance($this->mainmodule);
        $mainmoduleTable = $mainmoduleFocus->table_name;
        $smownerid = $mainmoduleTable.'.smownerid';
        //ld_workreport 工作汇报(列表)模块
        if($this->mainmodule=='WorkReportList'){
            $smownerid = $mainmoduleTable.'.smcreatorid';
        }
        //0049528: （苏州凡图）http://110.40.187.151:85/crm/ [^]，财务管理——客户收款统计，这个报表是用自定义统计表做的一个简单报表，给普通销售数据范围设置只能看到自己的数据，但他们还是能看到全部的数据，除此之外还有别的问题，详情见说明
        $datarangeSql = "INNER JOIN (
			SELECT DISTINCT
				userid 
			FROM (
				SELECT 
					ld_users.id AS userid 
				FROM ld_users
				WHERE EXISTS(SELECT 1 FROM ld_setscoperhigher WHERE modulename='$this->mainmodule' and scopeauthority=1 AND userid=$currUserid)
				UNION
				SELECT 
					viewid AS userid 
				FROM ld_scoperhigher
				WHERE userid=$currUserid AND modulename='$this->mainmodule' AND EXISTS(SELECT 1 FROM ld_setscoperhigher WHERE userid=$currUserid AND scopeauthority=2 AND modulename='$this->mainmodule')			
				UNION
				SELECT DISTINCT 
					ld_users2group.userid AS userid 
				FROM ld_scoperhigher 
				INNER JOIN ld_groups ON ld_groups.groupid=ld_scoperhigher.viewid
				INNER JOIN ld_users2group ON ld_users2group.groupid=ld_groups.groupid
				WHERE ld_scoperhigher.userid=$currUserid 
					AND ld_scoperhigher.modulename='$this->mainmodule'
					AND ld_scoperhigher.scopeauthority=3 
					AND EXISTS(SELECT 1 FROM ld_setscoperhigher WHERE modulename='$this->mainmodule' AND scopeauthority=3 AND userid=$currUserid)
				UNION 
				SELECT 
					id AS userid 
				FROM ld_users  
				WHERE EXISTS(SELECT 1 FROM ld_users WHERE id=$currUserid AND is_admin='on')
				UNION
				SELECT $currUserid) AS vw_users
		) AS tmp_users ON tmp_users.userid=$smownerid";
        if(is_admin($current_user))
        {

        }
        else
            $tables[] = $datarangeSql;
        $tables = implode(' ',$tables);
        //$mainWhere = implode(" and ",$mainWhere);
        $conditionSql = "select $tableIndexField,$smownerid from $tables where   ".$mainWhereStr ;

        return $conditionSql;
    }

    public function getDetailedSql (){
        //明细1
        //字段
        $detail_fields = implode(',',$this->fields);
        $mainModule = $this->mainmodule;
        $mainFocus = CRMEntity::getInstance($mainModule);
        $mainTableName = $mainFocus->table_name;
        $mainTableIndex = $mainFocus->table_index;
        $detailtype=intval($this->typevalue_arr['detail']);
        $detail_fields .= ", $detailtype as type,'detail' as type_desc,$mainTableName.$mainTableIndex as maintableindex ";
        $detailSql = "select $detail_fields from  ".$this->selectColumnFrom;
        $allModules = $this->module_arr;
        $groupby_arr[]=$mainTableName.'.'.$mainTableIndex;
        foreach($this->module_arr as $tmpmodule_index=> $tmpmodulename)
        {
            if($tmpmodulename!=$mainModule&&in_array($tmpmodulename,$this->wheremodule_arr))
            {

                //合同和费用报销 报表
                //一个合同有4个费用报销，3个已审批
                //按照费用 报销 的审批状态 查询
                $tmpfocus=CRMEntity::getInstance($tmpmodulename)  ;

                $groupby_arr[]=$tmpfocus->table_name.'.'.$tmpfocus->table_index;
            }
        }
        $joinOn = $mainTableName.'.'.$mainTableIndex.'=conditionSql.'.$mainTableIndex;

        if(!empty($this->DetailDableIdField)&&!empty($this->DetailDableIdField[0])){
            //zxm 20221012 查询条件是明细表的字段
            $groupby_arr[]= $this->DetailDableIdField[0];
            $DetailDableIdFieldArr = explode('.',$this->DetailDableIdField[0]);
            $joinOn = $this->DetailDableIdField[0].'=conditionSql.'.$DetailDableIdFieldArr[1];
        }
        //拼接条件 zxm 20231009 条件sql不为空才inner join 条件子查询
        if(!empty($this->conditionSql))
            $detailSql .= ' inner join ('.$this->conditionSql.' group by '.implode(",",$groupby_arr).' )as conditionSql on '.$joinOn;

        foreach($this->wheremodule_arr as $tmpwheremodule)
        {
            if(empty($tmpwheremodule))
                continue;
            if($tmpwheremodule!=$mainModule)
            {
                $tmpfocus=CRMEntity::getInstance($tmpwheremodule);
                $wheremoduleindex=$tmpfocus->table_index;
                $tmpwheretablename=$tmpfocus->table_name;
                $detailSql.=" and conditionSql.$wheremoduleindex=$tmpwheretablename.$wheremoduleindex";


            }
        }

        return $detailSql;
    }




    public function getGroupBySumSql()
    {
        if(sizeof($this->groupcolumn_arr)>0&&sizeof($this->sumcolumn_arr)>0)
        {
            crm_load_class_file('cls_sumSql','modules/CustomTables/ComputerSql');
            $sumsqlobj=new cls_sumSql($this);
            return $sumsqlobj->getGroupBySumSql();
        }

    }


    public function getGroupByMaxSql(){
        //按分组字段的求和2，3，4，5，6（最多五个分组字段）
        if(sizeof($this->maxcolumn_arr)>0)
        {
            crm_load_class_file('cls_maxSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_maxSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }

    public function getGroupByMinSql(){
        if(sizeof($this->mincolumn_arr)>0)
        {
            crm_load_class_file('cls_minSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_minSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }
    public function getGroupByAvgSql(){
        if(sizeof($this->avgcolumn_arr)>0)
        {
            crm_load_class_file('cls_avgSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_avgSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }
    public function getGroupByCountSql(){

        if(sizeof($this->countcolumn_arr)>0)
        {
            crm_load_class_file('cls_countSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_countSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }
    public function getGroupByDistinctCountSql(){
        if(sizeof($this->distinctcountcolumn_arr)>0)
        {
            crm_load_class_file('cls_countDistinctSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_countDistinctSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }
    //求和的所有合计
    public function getTotalSql(){

        $totalsql_arr=[];
        $sumtotalsql='';

        if(sizeof($this->groupcolumn_arr)>0&&sizeof($this->sumcolumn_arr)>0)
        {
            crm_load_class_file('cls_sumSql','modules/CustomTables/ComputerSql');
            $sumsqlobj=new cls_sumSql($this);
            $sumsqlobj->setIstotal('yes');
            $sumtotalsql= $sumsqlobj->getGroupBySumSql();
            $totalsql_arr[]=$sumtotalsql;
        }



        if(sizeof($this->maxcolumn_arr)>0)
        {
            crm_load_class_file('cls_maxSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_maxSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }


        if(sizeof($this->mincolumn_arr)>0)
        {
            crm_load_class_file('cls_minSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_minSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }

        if(sizeof($this->countcolumn_arr)>0)
        {
            crm_load_class_file('cls_countSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_countSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }

        if(sizeof($this->distinctcountcolumn_arr)>0)
        {
            crm_load_class_file('cls_countDistinctSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_countDistinctSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }
        if(sizeof($this->avgcolumn_arr)>0)
        {
            crm_load_class_file('cls_avgSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_avgSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }
        return implode(" union all ",$totalsql_arr);

    }

    public function getLimitSql (){
        //分页Sql


        $start=$_REQUEST['pagenum'];
        if($start>0)
        {
            $start=$start-1;
        }
        else{
            $start=0;
        }
        $startdate=$start*$this->limit;
        return "  $startdate,".$this->limit;

    }


}