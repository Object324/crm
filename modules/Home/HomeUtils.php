<?php
require_once globalStatic::$root_directory.'modules/Home/HomeParentUtils.php';
//zxm 20230731 首页默认组件的类
//重要的参数 $scopeType $senioruserid $search_date $stuffid $boardid $boardstuffid  $approve_value

class HomeUtils extends HomeParentUtils{
    static public function getInstance(){

    }
    public $filterArr;
    public $boarddatarangmoduleArr;
    public $DefaultdatarangmoduleArr;
    public function __construct($boardid)
    {
        parent::__construct($boardid);
    }
    //组件：现金银行流水账
    public function getNewBankCash(){
        global $adb;
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $datarangesqlArr = $this->datarangesqlArr;

        $sqlc="SELECT accountname as bankname,date,money,name,temp.currency_symbol,type from (
(SELECT outaccount as account,Putcashdate as date,(if (ld_putcash.currency_id > 1,cashmoney/ld_putcash.conversion_rate,cashmoney)) as money,last_name as name,currency_symbol ,1 as type 
FROM ld_putcash LEFT JOIN ld_users ON ld_users.id=ld_putcash.smownerid 
".$datarangesqlArr['datarangesql_PutCash']." order by ".$this->filterArr['timecomponent_PutCash']['filtersfield']." DESC limit 12
)UNION(
SELECT inaccount as account,Putcashdate as date,(if (ld_putcash.currency_id > 1,cashmoney/ld_putcash.conversion_rate,cashmoney)) as money,last_name as name,currency_symbol,2 as type  
FROM ld_putcash LEFT JOIN ld_users ON ld_users.id=ld_putcash.smownerid 
".$datarangesqlArr['datarangesql_PutCash']." order by ".$this->filterArr['timecomponent_PutCash']['filtersfield']." DESC limit 12
)UNION(
SELECT inaccount as account,cashdepositdate as date,(if (ld_cashdeposit.currency_id > 1,cashmoney/ld_cashdeposit.conversion_rate,cashmoney)) as money,last_name as name,currency_symbol,2 as type  
FROM ld_cashdeposit LEFT JOIN ld_users ON ld_users.id=ld_cashdeposit.smownerid 
".$datarangesqlArr['datarangesql_CashDeposit']." order by ".$this->filterArr['timecomponent_CashDeposit']['filtersfield']." DESC limit 12
)UNION(
SELECT outaccount as account,cashdepositdate as date,(if (ld_cashdeposit.currency_id > 1,cashmoney/ld_cashdeposit.conversion_rate,cashmoney)) as money,last_name as name,currency_symbol,1 as type  
FROM ld_cashdeposit LEFT JOIN ld_users ON ld_users.id=ld_cashdeposit.smownerid 
".$datarangesqlArr['datarangesql_CashDeposit']." order by ".$this->filterArr['timecomponent_CashDeposit']['filtersfield']." DESC limit 12
)UNION(
SELECT bankaccountsetid as account,cashbilldate as date,(if (ld_sendcashbill.currency_id > 1,total/ld_sendcashbill.conversion_rate,total)) as money,last_name as name,currency_symbol, 1 as type  
FROM ld_sendcashbill LEFT JOIN ld_users ON ld_users.id=ld_sendcashbill.smownerid 
".$datarangesqlArr['datarangesql_SendCashBill']." order by ".$this->filterArr['timecomponent_SendCashBill']['filtersfield']." DESC limit 12
)UNION(
SELECT bankaccountsetid as account,cashbilldate as date,(if (ld_cashbill.currency_id > 1,total/ld_cashbill.conversion_rate,total)) as money,last_name as name,currency_symbol,2 as type  
FROM ld_cashbill LEFT JOIN ld_users ON ld_users.id=ld_cashbill.smownerid 
".$datarangesqlArr['datarangesql_CashBill']." order by ".$this->filterArr['timecomponent_CashBill']['filtersfield']." DESC limit 12
)UNION(
SELECT bankaccountsetid as account,expensedate as date,(if (ld_commission.currency_id > 1,total/ld_commission.conversion_rate,total)) as money,last_name as name,currency_symbol,1 as type  
FROM ld_commission LEFT JOIN ld_users ON ld_users.id=ld_commission.smownerid 
".$datarangesqlArr['datarangesql_Commission']." order by ".$this->filterArr['timecomponent_Commission']['filtersfield']." DESC limit 12
)UNION(
SELECT bankaccountsetid as account,expensedate as date,(if (ld_expense.currency_id > 1,total/ld_expense.conversion_rate,total)) as money,last_name as name,currency_symbol,1 as type  
FROM ld_expense LEFT JOIN ld_users ON ld_users.id=ld_expense.smownerid 
".$datarangesqlArr['datarangesql_Expense']." order by ".$this->filterArr['timecomponent_Expense']['filtersfield']." DESC limit 12 
)) as temp LEFT JOIN ld_bankaccountset on temp.account=ld_bankaccountset.Bankaccountsetid ORDER BY date DESC LIMIT 12;";

        $result = $adb->pquery($sqlc);
        $sendcashbillnum = $adb->num_rows($result);
        $sendcashbill_list = [];
        for($i=0;$i<$sendcashbillnum;$i++){
            $sendcashbill_list[] = Array(
                'date' => $adb->query_result($result,$i,'date'),
                'bankname' => $adb->query_result($result,$i,'bankname'),
                'money' => $adb->query_result($result,$i,'money'),
                'name' => $adb->query_result($result,$i,'name'),
                'currency_symbol' => $adb->query_result($result,$i,'currency_symbol'),
                'type' => $adb->query_result($result,$i,'type'),
            );
        }

        $title=array();
        //获取表头theader
        $headerNameArr = [getFixedLabel('DATE'),getFixedLabel('COMPANYACCOUNT'),getFixedLabel('AMOUNT'),getFixedLabel('Managers')];
        $header=$this->getTableStuffHeader($headerNameArr);
        $entries=array();
        if(sizeof($sendcashbill_list)>0){
            foreach($sendcashbill_list as $sendcashbill)
            {
                $value=array();
                $sendcashbill_no = (mb_strlen((string)$sendcashbill['bankname'],'utf8') > 18) ? (mb_substr((string)$sendcashbill['bankname'],0,18,"UTF-8").'...') : $sendcashbill['bankname'];
                $value[]='<span title="'.$sendcashbill['date'].'">' . $sendcashbill['date'] . '</span>';
                $value[]='<span title="'.$sendcashbill_no.'">' . $sendcashbill_no . '</span>';
                if($sendcashbill['type'] == 1){
                    $value[] = '￥' . setNumberFormat($sendcashbill['money'],$system_deploy_351);
                }else{
                    $value[] = '<font color="red">￥' . setNumberFormat($sendcashbill['money'],$system_deploy_351) . '</font>';
                }
                $value[]='<span title="'.$sendcashbill['name'].'">' . $sendcashbill['name'] . '</span>';
                $entries[]=$value;
            }
        }
        $values=Array('ModuleName'=>'BankCash','Title'=>$title,'Header'=>$header,'Entries'=>$entries);
        return $values;
    }
    //首页：公告
    public function getPublicAnnouncement()
    {
        global $adb,$current_user;
        $datarangesqlArr = $this->datarangesqlArr;
        $timefieldname = $this->filterArr['timecomponent_PublicAnnouncement']['filtersfield'];
        $nowdate = date('Y-m-d');
        $data_sql = " and ('$nowdate' between ld_publicannouncement.startdate and ld_publicannouncement.enddate) ";

        if( !is_admin($current_user ) ){
            $list_query = 'SELECT DISTINCT ld_publicannouncement.publicannouncementid as publicannouncementid,
         ld_publicannouncement.subject as subject,ld_publicannouncement.startdate as startdate 
         from ld_publicannouncement 
         LEFT JOIN ld_receipts on ld_publicannouncement.publicannouncementid=ld_receipts.id
         '.$datarangesqlArr['datarangesql_PublicAnnouncement'].'
         where  ld_publicannouncement.deleted=0 '.$data_sql;
        }
        else{
            $list_query='select *  from ld_publicannouncement '.$datarangesqlArr['datarangesql_PublicAnnouncement'].' where ld_publicannouncement.deleted=0 ' . $data_sql;
        }
        $list_query.= "  ORDER BY $timefieldname DESC";
        $list_query.= " limit 12";
        $result = $adb->pquery($list_query);
        $sendcashbillnum = $adb->num_rows($result);
        for($i=0;$i<$sendcashbillnum;$i++){
            $sendcashbill_list[] = Array('publicannouncementid' => $adb->query_result($result,$i,'publicannouncementid'),
                'subject' => $adb->query_result($result,$i,'subject'),
                'startdate' => $adb->query_result($result,$i,'startdate'),
            );
        }
        $title=array();
        $publicannounce_field_obj=Field::getInstance('PublicAnnouncement',$adb);
        $arrFieldLabel=$publicannounce_field_obj->getFieldLables();
        $header=array();
        $header[] = '<span title="'.$arrFieldLabel['subject'].'">' .$arrFieldLabel['subject'] . '</span>';
        $header[] = '<span title="'.$arrFieldLabel['startdate'].'">' .$arrFieldLabel['startdate'] . '</span>';
        $entries=array();
        if(!empty($sendcashbill_list)){
            //ls 20240329 BUG20240329-43 首页->销售看板，公告应该不显示超链接字段（路总已设置此字段不是超链接字段）
            $entity_field_info = getEntityFieldNames('PublicAnnouncement');
            $entity_fieldsname = '';
            if (isset($entity_field_info['fieldname']) && !empty($entity_field_info['fieldname'])) {
                $entity_fieldsname = $entity_field_info['fieldname'];
            }

            foreach($sendcashbill_list as $sendcashbill)
            {
                $value=array();
                $sendcashbill_no = $sendcashbill['subject'];
//                $sendcashbill_no = (mb_strlen($sendcashbill['subject'],'utf-8') > 28) ? (mb_substr($sendcashbill['subject'],0,18,'utf-8').'...') : $sendcashbill['subject'];
                $sendcashbill_no = TextRemoveXSS($sendcashbill_no);

                if (!empty($entity_fieldsname) && $entity_fieldsname == 'subject') {
                    $value[]='<a href="javascript:;" referencemodule="PublicAnnouncement" referencerecord="'.$sendcashbill["publicannouncementid"].'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$sendcashbill_no.'">'.$sendcashbill_no.'</a>';
                }else{
                    $value[]=$sendcashbill_no;
                }


                $value[]='<span title="'.$sendcashbill['startdate'].'">' .$sendcashbill['startdate'] . '</span>';
                $entries[$sendcashbill['publicannouncementid']]=$value;
            }
        }
        $values=Array('ModuleName'=>'PublicAnnouncement','Title'=>$title,'Header'=>$header,'Entries'=>$entries);
        return $values;
    }
    //首页组件：销售排行榜
    public function getContractnumberandamount($platesetting)
    {
        global $adb;
        $can_penetrate = $platesetting['can_penetrate'];
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $datarangesqlArr = $this->datarangesqlArr;

        $reg = RegOp::getInstance();
        $RegisterVersionNo = $reg->GetVersionNo();

        if($RegisterVersionNo != 7){
            $query="SELECT 
                        ld_users.id AS CashBill_ordernum,ld_cashbill.smownerid,
                        ld_users.wx_userid,
                        ld_users.last_name, 
                        sum(ifnull(ld_cashbill.Total,0.00)/ifnull(ld_cashbill.conversion_rate,1.00)) as total 
                    FROM ld_users 
                    INNER JOIN ld_cashbill ON ld_users.id = ld_cashbill.smownerid 
                    ".$datarangesqlArr['datarangesql_CashBill']."
                    GROUP BY ld_users.id 
                    order by total desc;";
            //35980: 首页组件-销售排行榜-回款金额排行统计不对
            $menu_list['amount']=array();
            $menu_list['contractaount']=array();
            $menu_list['contractquantity']=array();
            if(vtlib_isModuleActive('CashBill')){
                $userobj=new Users();
                $result3=$adb->query($query);
                $num_rows=$adb->num_rows($result3);
                for($i=0;$i<$num_rows;$i++){
                    $wx_userid=$adb->query_result($result3,$i,'wx_userid');
                    $userobj->wx_userid=$wx_userid;
                    $last_name=$adb->query_result($result3,$i,'last_name');
                    $userobj->last_name=$last_name;

                    if($can_penetrate=='no'){
                        $tmplabel3 = '<span>￥'.setNumberFormat($adb->query_result($result3,$i,'total'),$system_deploy_351).'</span>';
                    }else{
                        $tmplabel3 = '<a searchtype="now" uid="'.$adb->query_result($result3,$i,'smownerid').'" onclick="homestuffObj.setSalesKitChuantou(\'SalesRanking_Cash\',33,ld(this))">￥'.setNumberFormat($adb->query_result($result3,$i,'total'),$system_deploy_351).'</a>';
                    }
                    $menu_list['amount'][] = array(
                        'label1' => $i+1,
                        'label2' => getUserlastName($userobj),
                        'label3' => $tmplabel3,
                    );
                }
            }else{
                unset($menu_list['amount']);
            }
        }

        $salesorder_money_query = "SELECT DISTINCT
                DISTINCT ld_salesorder.salesorderid AS salesorder_id,
                ld_salesorder.currency_id AS salesorder_curid,
                ld_salesorder.conversion_rate AS salesorder_rate,
                (if (ld_salesorder.currency_id > 1,ld_salesorder.total/ld_salesorder.conversion_rate,ld_salesorder.total)) AS salesorder_total,
                ld_users.last_name AS salesorder_smownerid,
                ld_users.id AS smownerid,
                ld_users.wx_userid as salesorder_wx_userid
            FROM
                ld_salesorder
            inner JOIN ld_users ON ld_users.id = ld_salesorder.smownerid 
             ".$datarangesqlArr['datarangesql_SalesOrder'];
        $servicecontracts_money_query = "SELECT DISTINCT
                DISTINCT ld_servicecontracts.servicecontractsid AS salesorder_id,
                ld_servicecontracts.currency_id AS salesorder_curid,
                ld_servicecontracts.conversion_rate AS salesorder_rate,
                (if (ld_servicecontracts.currency_id > 1,ld_servicecontracts.total/ld_servicecontracts.conversion_rate,ld_servicecontracts.total)) AS salesorder_total,
                ld_users.last_name AS salesorder_smownerid,
                ld_users.id AS smownerid,
                ld_users.wx_userid as salesorder_wx_userid
            FROM
                ld_servicecontracts
            inner JOIN ld_users ON ld_users.id = ld_servicecontracts.smownerid 
            ".$datarangesqlArr['datarangesql_ServiceContracts'];
        if(vtlib_isModuleActive("SalesOrder")&&!vtlib_isModuleActive("ServiceContracts")){
            $money_query = $salesorder_money_query;
        }else if(vtlib_isModuleActive("ServiceContracts")&&!vtlib_isModuleActive("SalesOrder")){
            $money_query = $servicecontracts_money_query;
        }else if(vtlib_isModuleActive("SalesOrder")&&vtlib_isModuleActive("ServiceContracts")){
            $money_query = $salesorder_money_query.' UNION ALL '.$servicecontracts_money_query;
        }
        $query="SELECT * from (SELECT
        salesorder_smownerid,
        A.smownerid,
        IFNULL(
            sum(
                salesorder_total
            ),
            0
        ) AS salesorder_total,
        salesorder_wx_userid
    FROM
        (
            $money_query
        ) AS A
    GROUP BY
        A.salesorder_smownerid) AS C
    ORDER BY
        C.salesorder_total DESC,
        length(C.salesorder_total) DESC";
        $result=$adb->query($query);
        $num_rows=$adb->num_rows($result);

        $userobj=new Users();
        for($i=0;$i<$num_rows;$i++){
            $userobj->last_name=$adb->query_result($result,$i,'salesorder_smownerid');
            $userobj->wx_userid=$adb->query_result($result,$i,'salesorder_wx_userid');
            if($can_penetrate=='no'){
                $tmplabel3 = '<span>￥'.setNumberFormat($adb->query_result($result,$i,'salesorder_total'),$system_deploy_351).'</span>';
            }else{
                $tmplabel3 = '<a searchtype="now" uid="'.$adb->query_result($result,$i,'smownerid').'" onclick="homestuffObj.setSalesKitChuantou(\'SalesRanking_Order\',33,ld(this))">￥'.setNumberFormat($adb->query_result($result,$i,'salesorder_total'),$system_deploy_351).'</a>';
            }
            $menu_list['contractaount'][] = array(
                'label1' => $i+1,
                'label2' => getUserlastName($userobj),
                'label3' => $tmplabel3,
            );
        }
        $salesorder_count_query = "SELECT DISTINCT
            DISTINCT ld_salesorder.salesorderid AS salesorder_id,
            ld_users.last_name AS salesorder_smownerid,
            ld_users.id AS smownerid,
            ld_users.wx_userid AS salesorder_wx_userid,
            ld_salesorder.createdtime AS salesorder_created_time,
            ld_salesorder.salesorderid AS LBL_ACTION
        FROM
            ld_salesorder
        inner JOIN ld_users ON ld_users.id = ld_salesorder.smownerid 
        ".$datarangesqlArr['datarangesql_SalesOrder'];
        $servicecontracts_count_query = "SELECT DISTINCT
            DISTINCT ld_servicecontracts.servicecontractsid AS salesorder_id,
            ld_users.last_name AS salesorder_smownerid,
            ld_users.id AS smownerid,
            ld_users.wx_userid AS salesorder_wx_userid,
            ld_servicecontracts.createdtime AS salesorder_created_time,
            ld_servicecontracts.servicecontractsid AS LBL_ACTION
        FROM
            ld_servicecontracts
        inner JOIN ld_users ON ld_users.id = ld_servicecontracts.smownerid 
        ".$datarangesqlArr['datarangesql_ServiceContracts'];
        if(vtlib_isModuleActive("SalesOrder")&&!vtlib_isModuleActive("ServiceContracts")){
            $count_query = $salesorder_count_query;
        }else if(vtlib_isModuleActive("ServiceContracts")&&!vtlib_isModuleActive("SalesOrder")){
            $count_query = $servicecontracts_count_query;
        }else if(vtlib_isModuleActive("SalesOrder")&&vtlib_isModuleActive("ServiceContracts")){
            $count_query = $salesorder_count_query.' UNION ALL '.$servicecontracts_count_query;
        }
        $query="SELECT
        salesorder_smownerid,
        A.smownerid,
        count(1) salesorder_groupbycount,
        salesorder_wx_userid
    FROM
        (
            $count_query
        ) AS A
    GROUP BY
        A.salesorder_smownerid
    ORDER BY
        salesorder_groupbycount DESC";
        $result2=$adb->query($query);
        $num_rows=$adb->num_rows($result2);
        $userobj=new Users();
        for($i=0;$i<$num_rows;$i++){
            $userobj->last_name=$adb->query_result($result2,$i,'salesorder_smownerid');
            $userobj->wx_userid=$adb->query_result($result2,$i,'salesorder_wx_userid');
            if($can_penetrate=='no'){
                $tmplabel3 = '<span>'.$adb->query_result
                    ($result2,$i,'salesorder_groupbycount').'</span>';
            }else{
                $tmplabel3 = '<a searchtype="now" uid="'.$adb->query_result($result2,$i,'smownerid').'" onclick="homestuffObj.setSalesKitChuantou(\'SalesRanking_Counts\',33,ld(this))">'.$adb->query_result
                    ($result2,$i,'salesorder_groupbycount').'</a>';
            }
            $menu_list['contractquantity'][] = array(
                'label1' => $i+1,
                'label2' => getUserlastName($userobj),
                'label3' => $tmplabel3,
            );
        }
        //回款金额
        if($RegisterVersionNo != 7&&vtlib_isModuleActive('CashBill')){
            $menu_label['amount'] =  array(
                'name' => getFixedLabel('AMOUNTTO'),
                'nums' => -1,
            );
        }
        //签约金额

        if(vtlib_isModuleActive("SalesOrder")||vtlib_isModuleActive("ServiceContracts")){
            $menu_label['contractaount'] =  array(
                'name' => getFixedLabel('CONTRACTAOUNT'),
                'nums' => -1,
            );

            //签约数量
            $menu_label['contractquantity'] =  array(
                'name' => getFixedLabel('CONTRACTQUANTITY'),
                'nums' => -1,
            );
        }

        //edit: xll 2024/02/19 BUG20240119-33 kfbcrm-首页-销售排行榜组件，只显示三个页签，点击更多到报表界面，排行维度有5个，少了“开票金额”“出库金额”
        //todo $menu_list[] 数据
        if (vtlib_isModuleActive('Invoice')) {
            $menu_label['invoice_amount'] =  array(
                'name' => getFixedLabel('INVOICEAMOUNT'),
                'nums' => -1,
            );
            crm_load_class_file('cls_MainReportSQL','modules/OftenUseReport');
            $extraSql = new cls_MainReportSQL();
            $query = explode('WHERE',$extraSql->Invoiceamount(''));
            $query = $query[0] . $datarangesqlArr['datarangesql_Invoice'] . ' WHERE ' . $query[1];
            $result_i = $adb->query($query);
            $num_rows = $adb->num_rows($result_i);
            for($i=0;$i<$num_rows;$i++){
                $last_name = $adb->query_result($result_i,$i,'user_last_name');
                $uid = $adb->query_result($result_i,$i,'id');
                $cnt = setNumberFormat($adb->query_result($result_i,$i,'cnt'),$system_deploy_351);
                if($can_penetrate=='no'){
                    $tmplabel3 = '<span>￥'.$cnt.'</span>';
                }else{
                    $tmplabel3 = '<a searchtype="now" uid="'.$uid.'" onclick="homestuffObj.setSalesKitChuantou(\'SalesRanking_Invoice\',33,ld(this))">￥'.$cnt.'</a>';
                }
                $menu_list['invoice_amount'][] = array(
                    'label1' => $i+1,
                    'label2' => $last_name,
                    'label3' => $tmplabel3
                );
            }
        }
        if (vtlib_isModuleActive('OutboundOrder')) {
            $menu_label['out_amount'] =  array(
                'name' => getFixedLabel('AMOUNTLIBRARY'),
                'nums' => -1,
            );
            crm_load_class_file('cls_MainReportSQL','modules/OftenUseReport');
            $extraSql = new cls_MainReportSQL();
            $query = explode('WHERE',$extraSql->OutboundOrderamount(''));
            $query = $query[0] . $datarangesqlArr['datarangesql_OutboundOrder'] . ' WHERE ' . $query[1];
            $result = $adb->query($query);
            $num_rows = $adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++){
                $last_name = $adb->query_result($result,$i,'user_last_name');
                $uid = $adb->query_result($result,$i,'id');
                $cnt = setNumberFormat($adb->query_result($result,$i,'cnt'),$system_deploy_351);
                if($can_penetrate=='no'){
                    $tmplabel3 = '<span>￥'.$cnt.'</span>';
                }else{
                    $tmplabel3 = '<a searchtype="now" uid="'.$uid.'" onclick="homestuffObj.setSalesKitChuantou(\'SalesRanking_OutboundOrder\',33,ld(this))">￥'.$cnt.'</a>';
                }
                $menu_list['out_amount'][] = array(
                    'label1' => $i+1,
                    'label2' => $last_name,
                    'label3' => $tmplabel3,
                );
            }
        }
        $data = array(
            'menu_label' => $menu_label,
            'menu_list' => $menu_list,
        );
        return $data;
    }

    //产品销售排行榜
    public function getProductsSalesRanking($platesetting){
        global $adb;
        $can_penetrate = $platesetting['can_penetrate'];

        global $current_user,$default_charset;
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $datarangesqlArr = $this->datarangesqlArr;
        //edit:can 20211217 9282: （https://kehu001.com/weixin/kh45237 [^] ）客户问题（艾科特） 首页的“产品销售排行榜”模版没有数据。
        $list_query = " select 
 ifnull(b.quantity,0) as product_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,ld_products.productid from ld_products ".$datarangesqlArr['datarangesql_Products'].") a left join 
 (select sum(tax_amount / ifnull(ld_salesorder.conversion_rate, 1)) as quantity,b.productid 
  from ld_salesorder ".$datarangesqlArr['datarangesql_SalesOrder']."
  left join ld_salesorderdetail b on ld_salesorder.salesorderid=b.id  group by b.productid) 
 as b on a.productid=b.productid
 where ifnull(b.quantity,0)>0 group by a.productid order by product_count desc limit 0,20";
        $list_result = $adb->query($list_query);
        $list = array();
        $noofrows = $adb->num_rows($list_result);
        $fieldobj=Field::getInstance("Products",$adb);

        $arrFieldLabel=$fieldobj->getShowFieldLables();

        if ($noofrows) {
            for($i=0;$i<$noofrows;$i++)
            {
                $list[] = Array(
                    'product_count'=>$adb->query_result($list_result,$i,'product_count'),
                    'productname' => $adb->query_result($list_result,$i,'productname'),
                    'productsheet' => $adb->query_result($list_result,$i,'productsheet'),
                    'product_no' => $adb->query_result($list_result,$i,'product_no'),
                    'productid' => $adb->query_result($list_result,$i,'productid')
                );
            }
        }
        //商机编号、签约客户名称、最终用户名称、预计采购产品、预计合同金额、预计成交日期
        //获取表头theader
        $headerNameArr = ['#',$arrFieldLabel['productname'],getFixedLabel('AMOUNT'),$arrFieldLabel['productsheet'],$arrFieldLabel['product_no']];
        $header=$this->getTableStuffHeader($headerNameArr);
        $entries=array();
        foreach($list as $k=>$product)
        {
            $product_count = number_format($product['product_count'],$system_deploy_351);
            $value=array();
            $Top_Products = (mb_strlen($product['productname'],'utf-8') > 18) ? (mb_substr($product['productname'],0,18,$default_charset).'...') : $product['productname'];
            $value[] = '<span>' .($k+1). '</span>';
            $value[] = '<a href="javascript:;" referencemodule="Products" referencerecord="'.$product["productid"].'" onclick="ListReferenceLinkClick(ld(this),event)"  title="'.$Top_Products.'">'.$Top_Products.'</a>';
            if($can_penetrate=='no'){
                $value[] = '<span>￥' .$product_count. '</span>';
            }else{
                $value[] = '<a onclick="homestuffObj.HomeChartChuantou(60,\'&product_no='.$product["product_no"].'\')">￥' .$product_count. '</a>';
            }

            $value[] = '<span>' .$product['productsheet']. '</span>';
            $value[] = '<span>' .$product['product_no']. '</span>';
            $entries[$product['productid']]=$value;
        }

        $values = Array('ModuleName'=>'Products','Header'=>$header,'Entries'=>$entries);
        return $values;

    }
    public function getPendingApproval(){
        $data_type = $this->params['data_type'];
        $data_type = empty($data_type)?"Pending":$data_type;
        $tabtype = $this->params['targetid'];
        crm_load_class_file('cls_Approve_countListView','modules/Approve');
        $approveobj = new cls_Approve_countListView($tabtype);
        //getPendingList//待处理
        //getProcessedList//已处理
        //getisubmittedList//我提交的
        //getApproveRejectedList//被驳回的
        $funName = 'get'.$data_type.'List';

        $approveList = $approveobj->$funName();
        $value = $this->getApproveListTable($approveList,$data_type);
        return $value;
    }
    //审批数据数组 组装
    public function getApproveListTable($pending_approval_lists,$data_type){
        //组装table数据
        //表头
        //获取表头theader
        $headerNameArr = [getFixedLabel('HyperlinkField'),getFixedLabel('CURRENTAPPROVALPROCEDURE'),getFixedLabel('CURRENTAPPROVER'),getFixedLabel('operatoroertime'),getFixedLabel('ASSIGNEDTO'),getFixedLabel('Related_modules')];
        if($data_type=='ApproveRejected'){
            //被驳回的 只显示3个字段:超链接字段 单据负责人 模块
            $headerNameArr = [getFixedLabel('HyperlinkField'),getFixedLabel('ASSIGNEDTO'),getFixedLabel('Related_modules')];
        }
        $header=$this->getTableStuffHeader($headerNameArr);
        //表体
        $entries=array();
        $iskehu001=judgeCorpInfo("kehu001");
        foreach($pending_approval_lists as $val_approve){
            $value=array();
            $title = getModuleHref($val_approve['setype'],$val_approve['crmid']);
            //ls 2021-08-11  【ID1001881】航港：加急（优先）审批
            $urgent = '';
            if ($val_approve['urgent'] == 'yes')
                $urgent = '<b class="fontsup">'.getFixedLabel("Urgent").'</b>';
            //zkt 2021-11-23 【ID1002081】 审批流程定制增加“是否启用催审功能”参数
            if ($val_approve['expediting'] == 'yes'){
                $urgent = '<b class="fontsup">'.getFixedLabel("Expedit").'</b>';
            }
            $value[]='<a href="javascript:;" referencemodule="'.$val_approve['setype'].'" referencerecord="'.$val_approve['crmid'].'" lasturl="&homeapproveresult=1&stuffid=39&stufftype=pendingapproval" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$title.'">'.$title.$expediting.$urgent.'</a>';
            //被驳回的 只显示3个字段:超链接字段 单据负责人 模块
            if($data_type!='ApproveRejected') {
                $value[] = '<span title="' . $val_approve['stepname'] . '">' . $val_approve['stepname'] . '</span>';
                if ($iskehu001) {
                    $value[] = '<span>' . $val_approve['nextstepbyname'] . '</span>';
                } else
                    $value[] = '<span title="' . $val_approve['nextstepbyname'] . '">' . $val_approve['nextstepbyname'] . '</span>';
                $value[] = '<span title="' . $val_approve['approvetime'] . '">' . $val_approve['approvetime'] . '</span>';
            }
            if($iskehu001)
            {
                $value[]='<span>' . $val_approve['ownerName'] . '</span>';
            }
            else
                $value[]='<span title="'.$val_approve['ownerName'].'">' . $val_approve['ownerName'] . '</span>';
            $value[]='<span title="'.getTranstab($val_approve['setype']).'">' . getTranstab($val_approve['setype']) . '</span>';
            $entries[$val_approve['crmid']]=$value;
        }
        $values=Array('ModuleName'=>'Approve','Header'=>$header,'Entries'=>$entries);
        return $values;
    }
    //交易
    public function getTransaction(){
        global $adb;
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $datarangesqlArr = $this->datarangesqlArr;

        $module_array = array('SalesOrder','ServiceContracts','CashBill','CashBack');
        //标签
        //日期
        foreach($module_array as $module){
            $menu_nums = 0;
            if(!vtlib_isModuleActive($module)){
                continue;
            }
            if($module == 'SalesOrder'){
                $query = 'select sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total,
					sum(if(currency_id > 1,IFNULL(receivable_balance,0)/conversion_rate,receivable_balance)) as receivable_balance,
					sum(if(currency_id > 1,IFNULL(received_amount,0)/conversion_rate,received_amount)) as received_amount,count(1) as total_num 
					from ld_salesorder '.$datarangesqlArr['datarangesql_SalesOrder'];
                $result = $adb->pquery($query,array());
                $menu_date[$module]['label1'] = array(
                    'name' => getFixedLabel('TotalAmount'),	//总金额
                    'stufflabel'=>'transaction_amount_sales',
                    'value' => setNumberFormat($adb->query_result($result,0,'total'),$system_deploy_351),
                );
                if(vtlib_isModuleActive('CashBill')){
                    $menu_date[$module]['label2'] = array(
                        'name' => getFixedLabel('TOTALRECEIVES'),	//已收总额
                        'stufflabel'=>'transaction_received_sales',
                        'value' => setNumberFormat($adb->query_result($result,0,'received_amount'),$system_deploy_351),
                    );
                    $menu_date[$module]['label3'] = array(
                        'name' => getFixedLabel('receivablebalance'),	//应收余额
                        'stufflabel'=>'transaction_balance_sales',
                        'value' => setNumberFormat($adb->query_result($result,0,'receivable_balance'),$system_deploy_351),
                    );
                }
                $menu_nums = $adb->query_result($result,0,'total_num');
                $query = 'select accountname,ld_account.accountid,tmp.total,tmp.signed_data from ld_account
				INNER JOIN (
					select accountid,'.$this->filterArr['timecomponent_SalesOrder']['filtersfield'].' as signed_data,sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total 
					from ld_salesorder '.$datarangesqlArr['datarangesql_SalesOrder'].'
					GROUP BY accountid
				) as tmp on tmp.accountid = ld_account.accountid
				ORDER BY tmp.signed_data desc limit 2';
                $result = $adb->pquery($query,array());
                $num_rows = $adb->num_rows($result);
                if($num_rows > 0){
                    for($i = 0; $i < $num_rows; $i++){
                        $due_date = $adb->query_result($result,$i,'signed_data');
                        $total = $adb->query_result($result,$i,'total');
                        $accountid = $adb->query_result($result,$i,'accountid');
                        $menu_list[$module][$accountid] = array(
                            'name' => $adb->query_result($result,$i,'accountname'),
                            'label' => getFixedLabel('DATEOFCONTRACT') . ' : ' . $due_date . '&nbsp|&nbsp;' . getFixedLabel('AMOUNT') . ' : ￥' . setNumberFormat($total,$system_deploy_351),	//签约日期 - 金额
                        );
                    }
                }
            }else if($module == 'ServiceContracts'){
                $query = 'select sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total,
					sum(if(currency_id > 1,IFNULL(receivable_balance,0)/conversion_rate,receivable_balance)) as receivable_balance,
					sum(if(currency_id > 1,IFNULL(received_amount,0)/conversion_rate,received_amount)) as received_amount,count(1) as total_num 
					from ld_servicecontracts '.$datarangesqlArr['datarangesql_ServiceContracts'];
                $result = $adb->pquery($query,array());
                $menu_date[$module]['label1'] = array(
                    'name' => getFixedLabel('TotalAmount'),	//总金额
                    'stufflabel'=>'transaction_amount_service',
                    'value' => setNumberFormat($adb->query_result($result,0,'total'),$system_deploy_351),
                );
                if(vtlib_isModuleActive('CashBill')){
                    $menu_date[$module]['label2'] = array(
                        'name' => getFixedLabel('TOTALRECEIVES'),	//已收总额
                        'stufflabel'=>'transaction_received_service',
                        'value' => setNumberFormat($adb->query_result($result,0,'received_amount'),$system_deploy_351),
                    );
                    $menu_date[$module]['label3'] = array(
                        'name' => getFixedLabel('receivablebalance'),	//应收余额
                        'stufflabel'=>'transaction_balance_service',
                        'value' => setNumberFormat($adb->query_result($result,0,'receivable_balance'),$system_deploy_351),
                    );
                }
                $menu_nums = $adb->query_result($result,0,'total_num');
                $query = 'select accountname,ld_account.accountid,tmp.total,tmp.due_date from ld_account
				INNER JOIN (
					select accountid,'.$this->filterArr['timecomponent_ServiceContracts']['filtersfield'].' as due_date,sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total 
					from ld_servicecontracts '.$datarangesqlArr['datarangesql_ServiceContracts'].'
					GROUP BY accountid
				) as tmp on tmp.accountid = ld_account.accountid where 1=1
				ORDER BY tmp.due_date desc  limit 2';
                $result = $adb->pquery($query,array());
                $num_rows = $adb->num_rows($result);
                if($num_rows > 0){
                    for($i = 0; $i < $num_rows; $i++){
                        $due_date = $adb->query_result($result,$i,'due_date');
                        $total = $adb->query_result($result,$i,'total');
                        $accountid = $adb->query_result($result,$i,'accountid');
                        $menu_list[$module][$accountid] = array(
                            'name' => $adb->query_result($result,$i,'accountname'),
                            'label' => getFixedLabel('DATEOFCONTRACT') . ' : ' . $due_date . '&nbsp|&nbsp;' . getFixedLabel('AMOUNT') . ' : ￥' . setNumberFormat($total,$system_deploy_351),	//签约日期 - 金额
                        );
                    }
                }
            }else if($module == 'CashBill'){
                //收款金额
                $query = 'select sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total,count(1) as total_num 
					from ld_cashbill '.$datarangesqlArr['datarangesql_CashBill'];
                $result = $adb->pquery($query,array());
                $all_total = $adb->query_result($result,0,'total');
                $menu_date[$module]['label1'] = array(
                    'name' => getFixedLabel('TotalAmount'),	//总金额
                    'stufflabel'=>'transaction_cash_amount',
                    'value' => setNumberFormat($all_total,$system_deploy_351),
                );
                $menu_nums = $adb->query_result($result,0,'total_num');
                //已批准
                $query = 'select sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total,count(1) as total_num,checkoutstatus 
					from ld_cashbill '.$datarangesqlArr['datarangesql_CashBill'].'
				where approvestatus = \'已批准\'';
                $result = $adb->pquery($query,array());
                $check_total = $adb->query_result($result,0,'total');
                $menu_date[$module]['label2'] = array(
                    'name' => getFixedLabel('Approvals'),
                    'stufflabel'=>'transaction_approvecash_amount',
                    'value' => setNumberFormat($check_total,$system_deploy_351),
                );
                //未批准
                $query = 'select sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total,count(1) as total_num,checkoutstatus 
					from ld_cashbill '.$datarangesqlArr['datarangesql_CashBill'].'
				where approvestatus <> \'已批准\' ';
                $result = $adb->pquery($query,array());
                $check_total = $adb->query_result($result,0,'total');
                $menu_date[$module]['label3'] = array(
                    'name' => getFixedLabel('Notapproved'),
                    'stufflabel'=>'transaction_unapprovecash_amount',
                    'value' => setNumberFormat($check_total,$system_deploy_351),
                );
                $query = 'select accountname,ld_account.accountid,tmp.total,tmp.cashbilldate from ld_account
				INNER JOIN (
					select accountid,'.$this->filterArr['timecomponent_CashBill']['filtersfield'].' as cashbilldate,sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total 
					from ld_cashbill '.$datarangesqlArr['datarangesql_CashBill'].'
					GROUP BY accountid
				) as tmp on tmp.accountid = ld_account.accountid where 1=1
				ORDER BY tmp.cashbilldate desc limit 2';
                $result = $adb->pquery($query,array());
                $num_rows = $adb->num_rows($result);
                if($num_rows > 0){
                    for($i = 0; $i < $num_rows; $i++){
                        $cashbilldate = $adb->query_result($result,$i,'cashbilldate');
                        $total = $adb->query_result($result,$i,'total');
                        $accountid = $adb->query_result($result,$i,'accountid');
                        $menu_list[$module][$accountid] = array(
                            'name' => $adb->query_result($result,$i,'accountname'),
                            'label' => getFixedLabel('CollectionDate') . ' : ' . $cashbilldate . '&nbsp|&nbsp;' . getFixedLabel('AMOUNT') . ' : ￥' . setNumberFormat($total,$system_deploy_351),	//签约日期 - 金额
                        );
                    }
                }

            }else if($module == 'CashBack'){
                //退款金额
                $query = 'select sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total,count(1) as total_num 
					from ld_cashback '.$datarangesqlArr['datarangesql_CashBack'];
                $result = $adb->pquery($query,array());
                $all_total = $adb->query_result($result,0,'total');
                $menu_date[$module]['label1'] = array(
                    'name' => getFixedLabel('TotalAmount'),	//总金额
                    'stufflabel'=>'transaction_cashback_amount',
                    'value' => setNumberFormat($all_total,$system_deploy_351),
                );
                $menu_nums = $adb->query_result($result,0,'total_num');
                $query = 'select accountname,ld_account.accountid,tmp.total,tmp.cashbackdate from ld_account
				INNER JOIN (
					select accountid,'.$this->filterArr['timecomponent_CashBack']['filtersfield'].' as cashbackdate,sum(if(currency_id > 1,IFNULL(total,0)/conversion_rate,total)) as total 
					from ld_cashback '.$datarangesqlArr['datarangesql_CashBack'].'
				    GROUP BY accountid
				) as tmp on tmp.accountid = ld_account.accountid where 1=1
				ORDER BY tmp.cashbackdate desc limit 2';
                $result = $adb->pquery($query,array());
                $num_rows = $adb->num_rows($result);
                if($num_rows > 0){
                    for($i = 0; $i < $num_rows; $i++){
                        $cashbackdate = $adb->query_result($result,$i,'cashbackdate');
                        $total = $adb->query_result($result,$i,'total');
                        $accountid = $adb->query_result($result,$i,'accountid');
                        $menu_list[$module][$accountid] = array(
                            'name' => $adb->query_result($result,$i,'accountname'),
                            'label' => getFixedLabel('cashbackdate') . ' : ' . $cashbackdate . '&nbsp|&nbsp;' . getFixedLabel('AMOUNT') . ' : ￥' . setNumberFormat($total,$system_deploy_351),	//签约日期 - 金额
                        );
                    }
                }
            }
            $menu_label[$module]['nums'] = $menu_nums;
            if($module == 'CashBill')
                $menu_label[$module]['name'] = getTranstab('Receivables1');
            else if($module == 'CashBack')
                $menu_label[$module]['name'] = getTranstab('Payment1');
            else
                $menu_label[$module]['name'] = getTranstab($module);

        }
        $data = array(
            'menu_label' => $menu_label,
            'menu_data' => $menu_date,
            'menu_list' => $menu_list,
        );

        return $data;
    }
    public function getServiceKanban(){
        //zxm 2021-1213 服务看板
        //表头
        global $adb,$languageType;
        $sql='select a.* from ld_usereportcolumns a left join ld_usereport b on a.Usereportid=b.usereportid where b.name=? and columnshow=1 order by sequence';
        $result=$adb->pquery($sql,array('ServiceKanBan'));
        $showcolLists=array();
        $reportFindHeader='<tr>';
        for($i=0;$i<$adb->num_rows($result);$i++) {
            //columns:表名：字段名称：fieldname:模块名称_fieldlabel:typeofdate
            $columns = $adb->query_result($result, $i, 'columns');
            //zxm 20230523 kfbcrm 英文版，服务看板，表头字段，显示为中文
            if($languageType=='en'){
                $realcolumns = $adb->query_result($result, $i, 'realencolumns');
            }else{
                $realcolumns = $adb->query_result($result, $i, 'realcolumns');
            }
            $columshow=$adb->query_result($result,$i,'columnshow');
            $fieldlabels = explode(':',$realcolumns);
            $AllReportHeaders[]=$columns;
            $typeofdata=$fieldlabels[4];
            $fieldmodules=explode('_',$fieldlabels[3]);
            $fieldModule = $fieldmodules[0];
            $showcolkey=$fieldModule.'_'.$fieldlabels[1];
            $showcolLists[ $showcolkey.':'.$typeofdata]=array($columshow=>$fieldlabels[0]);
            $reportFindHeader.='<th>'.$fieldmodules[1].'</th>';
        }
        $reportFindHeader.='</tr>';
        include globalStatic::$root_directory.'modules/OftenUseReport/ServiceKanBan.php';
        $ServiceKanBanObj=new ServiceKanBan($showcolLists);
        $_REQUEST['fromhome'] = 'yes';
        $datarangesqlArr = $this->datarangesqlArr;

        $content = $ServiceKanBanObj->ListViewForServiceKanBan($datarangesqlArr['datarangesql_HelpDesk']);
        return ['content'=>$reportFindHeader.$content];
    }
    //常用模块--目前只有移动端用这个
    //常用模块
    public function getcommonmodules(){
        global $PlatformMC,$MobileLanguageType;
        $PlatformMC['type'] = 'weixin';
        $MobileLanguageType = 'zh';
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        $detailObj = new cls_ReportDetailInfoWX(27);
        $list =  $detailObj->getcommonmodules();
        foreach($list['list'] as &$row){
            $row['icon'] = empty($row['icon'])?'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/wx_images/report2022/report_8.png':$row['icon'];
        }
        return $list;
    }
    //移动端销售龙虎榜
    public function getSaleDragonTiger(){
        global $PlatformMC,$MobileLanguageType;
        $PlatformMC['type'] = 'weixin';
        $MobileLanguageType = 'zh';
        $_REQUEST['ranking_module']='ServiceContracts';
        $_REQUEST['ranking_sort']='low';
        $_REQUEST['page_num']='';
        $_REQUEST['selectuid']='all';
        $_REQUEST['page_step']='1';
        $_REQUEST['approve_value']='all';
        $_REQUEST['reporttype']='thisfy';
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        $detailObj = new cls_ReportDetailInfoWX(22);
        $list =  $detailObj->getsalesdragontiger();
        return $list;
    }
    //--移动端--合同简报
    public function getContractkit(){
        global $PlatformMC,$MobileLanguageType;
        $PlatformMC['type'] = 'weixin';
        $MobileLanguageType = 'zh';
        $_REQUEST['ranking_sort']='low';
        $_REQUEST['page_num']='';
        $_REQUEST['selectuid']='all';
        $_REQUEST['page_step']='1';
        $_REQUEST['approve_value']='all';
        $_REQUEST['reporttype']='thisfy';
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        $detailObj = new cls_ReportDetailInfoWX(21);
        $list =  $detailObj->getContractkit();
        return $list;
    }
    //--移动端 自定义宝柏哦
    public function getCustomReportBlock(){
        global $PlatformMC,$MobileLanguageType;
        $PlatformMC['type'] = 'weixin';
        $MobileLanguageType = 'zh';
        $_REQUEST['ranking_sort']='low';
        $_REQUEST['page_num']='';
        $_REQUEST['selectuid']='all';
        $_REQUEST['page_step']='1';
        $_REQUEST['approve_value']='all';
        $_REQUEST['reporttype']='thisfy';
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        $detailObj = new cls_ReportDetailInfoWX(26);
        $list =  $detailObj->getcustomreportblock();
        return $list;
    }

    public function getTargetAnalysis(){
        global $languageType;
        //记住页签
        $targetid = $_REQUEST['targetid'];
        setUsersettingByLabel('SalesGoal','','TargetAnalysis_SalesGoal',$targetid);
        $labelKey = ($languageType === 'en') ? 'stufflabel_en' : 'stufflabel_zh';
        crm_load_class_file('TargetAnalysis','modules/Home/HomeBoardNew');
        $TargetAnalysisObj=TargetAnalysis::getInstance($this->boardid);
        $TargetAnalysisObj->setStuffId($this->stuffid);
        $TargetAnalysisObj->setHomeDateArr(['search_date' => $this->search_date]);
        $TargetAnalysisList = $TargetAnalysisObj->getAllStuffDetailList();
        $SelStuffDetailList = $TargetAnalysisObj->SelStuffDetailList;
        $ResArr = [];
        $GaugeNum = 0;
        foreach ($SelStuffDetailList as $stuffDetailLabel){
            $stuffDetailInfo = $TargetAnalysisList[$stuffDetailLabel];
            $SetValue = $stuffDetailInfo['SetValue'];
            $DataArr = $TargetAnalysisObj->getTargetDoneDataArr($SetValue,$this->scopeType);
            $ResArr[$stuffDetailLabel] = $this->getTargetDoneRes($DataArr);
            $ResArr[$stuffDetailLabel]['title'] = $stuffDetailInfo[$labelKey];
            $ResArr[$stuffDetailLabel]['homestuffdetailid'] = $stuffDetailInfo['homestuffdetailid'];
            $ResArr[$stuffDetailLabel]['stufflabel'] = $stuffDetailLabel;
            $ResArr[$stuffDetailLabel]['indicator_unit'] = $DataArr['indicator_unit'];//wym 240410 XUQIU20240305-01 目标管理，增加设置“指标单位”和“换算率”（张华）
            $GaugeNum ++;
        }

        crm_load_class_file('Homeboard','modules/Home');
        $gaugeSet = Homeboard::getPlateSetting($this->boardid,$this->stuffid);
        return array('res_data'=>$ResArr,'GaugeNum'=>$GaugeNum,'gaugeSet'=>$gaugeSet,'can_penetrate'=>'yes');
    }

    public function getTargetDoneRes($DataArr){
        $salestarget = $DataArr['Target'];
        $salesgoal_done = $DataArr['Done'];
        $SalesGoalInfo = $DataArr['SalesGoalInfo'];
        $targetid = $SalesGoalInfo['targetid'];
        $targetModule = $SalesGoalInfo['modulename'];
        $system_351 = getSys_deploy(351);
        $system_deploy_351 = 2;
        if(is_numeric($system_351['deploy_value'])){
            $system_deploy_351 = $system_351['deploy_value'];
        }

        $res = [];
        $res['target'] = 0.00;
        $res['done'] = 0.00;
        $res['undone'] = 0.00;
        $res['rate'] = 0.00;
        $tmp_target_data = 0.00;
        $tmp_done_data = 0.00;
        //edit: xll 2023/10/06 BUG0073290 成员“hxg”并没有设置相应的目标管理指标，但首页-目标完成率却显示其目标值。
        //目标值收查看范围影响，只循环查看范围内的用户id
        $userid_arr = explode(',',$this->senioruserid);
        foreach($salestarget[$targetModule] as $userid => $target){
            //edit: xll 2024/04/01 BUG20240329-61 目标管理设置客户模块对象的指标，最近六个月没有目标值
            if($targetModule !== 'Users' || in_array($userid,$userid_arr)){
                foreach($target as $tmp_month=>$monthtarget){
                    $tmp_target_data += $monthtarget;
                }
            }
        }
        $tmp_target_data = round($tmp_target_data,$system_deploy_351);
        foreach($salesgoal_done as $userid=>$userdone){
            foreach($userdone as $tmp_month=>$monthdone){
                //if(in_array($tmp_month,$search_date_arr))
                $tmp_done_data += $monthdone;
            }
        }
        $tmp_done_data = round($tmp_done_data,$system_deploy_351);
        $res['target'] = $tmp_target_data;
        $res['done'] = $tmp_done_data;
        $undone = $tmp_target_data <= 0 ? 0 : ($tmp_target_data - $tmp_done_data);
        //edit: xll BUG20240529-26 超额完成，未完成显示为0
        if($undone < 0)
            $undone = 0;
        $res['undone'] = round($undone,$system_deploy_351);
        //edit: xll 2023/01/30 BUG20240115-51 不保留小数位数
        $modstatic = new SalesGoalNew();
        $indicator_unit_label= $modstatic->getIndicatorUnitLabel($targetid);
        $setStuffDataFormatarr = ['target','done','undone'];
        foreach ($setStuffDataFormatarr as $tmpkey){
            //edit: xll 2024/03/06 BUG20240229-42 油码表金额单位想要改成万元
            //wym 240409 XUQIU20240305-01 目标管理，增加设置“指标单位”和“换算率”（张华）
            $res[$tmpkey] = $res[$tmpkey] . $indicator_unit_label; 
        }
        $res['rate'] = ($tmp_target_data<=0) ? (($tmp_done_data >= 0) ? 100 : 0) : round($tmp_done_data*100 /$tmp_target_data,$system_deploy_351);
        $res['can_penetrate']='yes';
        return $res;
    }

    public function getCarousel() {
        crm_load_class_file('Homeboard','modules/Home');
        $homeboardObj = Homeboard::getInstance($this->boardid,'Home');
        $fun = "getOtherSetInfo_".$this->stuffid;
        $stuffOtherSet = $homeboardObj->$fun($this->stuffid);
        return $stuffOtherSet;
    }
}




