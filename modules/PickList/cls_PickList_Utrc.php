<?php

/**
Eidtor:gyq_64 Reason:下拉框改进 联合技术MER特殊控 Date:2018/3/12 0012 下午 4:51
 */
crm_load_class_file("cls_PickList",'modules/PickList');
class cls_PickList_Utrc extends cls_PickList
{
    protected $relatetable = 'ld_tabdetailfield';
    protected $listname = 'expensetype';
    //获取费用类别
    public function getPickListValues_Utrc(){
        global $adb;
        $sqlquery = 'SELECT PV.listvalue,PV.utrc_type FROM ld_picklist_values PV LEFT JOIN ld_picklist_set PS on PV.listid=PS.listid
          WHERE PS.listname=? AND relatetable=? ORDER BY PV.sequence ASC';
        $result = $adb->pquery($sqlquery,array($this->listname,$this->relatetable));
        $num_rows = $adb->num_rows($result);
        for($i = 0; $i<$num_rows; $i++){
            $listvalue = $adb->query_result($result,$i,'listvalue');
            $data[$listvalue] = $adb->query_result($result,$i,'utrc_type');
        }
        return $data;
    }

    //联合技术MER特殊控制：获取明细第一行数据费用类别的utrc_type
    public function getExpenseDetailRowUtrcType($rRecordid){
        global $adb;
        if(!empty($rRecordid)){
            $sqlquery = 'select PV.utrc_type from ld_expensedetail
                      LEFT JOIN ld_expense on ld_expense.expenseid = ld_expensedetail.expenseid
                      LEFT JOIN ld_picklist_values PV on PV.listvalue = ld_expensedetail.expensetype
                      LEFT JOIN ld_picklist_set PS on PS.listid = PV.listid
                    where ld_expense.expenseid = ? AND PS.relatetable=? AND PS.listname=? limit 1';
            $result = $adb->pquery($sqlquery,array($rRecordid,$this->relatetable,$this->listname));
            $num_rows = $adb->num_rows($result);
            if($num_rows >= 0){
                return $adb->query_result($result,0,'utrc_type');
            }
        }else{
            crm_load_class_file("TabDetailFields",'include/TabDetailFields');
            $tabid = getTabid('Expense');
            $TabDetailFields = new TabDetailFields($tabid);
            $tabPresenceDetailFields = $TabDetailFields->getTabPresenceDetailFields();
            $expensetype =  $tabPresenceDetailFields['expensetype'];
            if(!empty($expensetype)){
                $defaultvalue = $expensetype->getDefaultvalue();
                if(!empty($defaultvalue)){
                    $query = 'select PV.utrc_type from ld_expensedetail ED
                          LEFT JOIN ld_picklist_values PV on PV.listvalue = ED.expensetype
                          LEFT JOIN ld_picklist_set PS on PS.listid = PV.listid
                        where ED.expensetype=? AND PS.relatetable=?  AND PS.listname=?  limit 1';
                    $result = $adb->pquery($query,array($defaultvalue,$this->relatetable,$this->listname));
                    $num_rows = $adb->num_rows($result);
                    if($num_rows >= 0){
                        return $adb->query_result($result,0,'utrc_type');
                    }
                }
            }

        }
    }

}