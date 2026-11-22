<?php
/**
 * zxm 2020-1009 常用报表增加销售提成报表（按合同，按收款）销售提成规则设置类 新建
 */
if(isset($_REQUEST['function'])) {
    $function = $_REQUEST['function'];
    $action_obj = new Action();
    $res = $action_obj->$function();
    $_REQUEST['diony'] = 'diony';
    if(isset($res['code'])){
        ConvertTojsonString($res['code'], $res, 'success');
    }
    ConvertTojsonString(1, $res, 'success');
}
class Action{
    public $adb;
    public function __construct()
    {
        global $adb;
        $this->adb = $adb;
    }
    public function saveRule()
    {
        $byType = $_REQUEST['byType'];
        $unit = $_REQUEST['unit'];
        $commission_start = $_REQUEST['commission_start'];
        $commission_end = $_REQUEST['commission_end'];
        $commission_rate = $_REQUEST['commission_rate'];
        $insert_values = [];
        foreach($commission_start as $k=>$v){
            $co_last  = isset($commission_end[$k-1])?$commission_end[$k-1]:0;
            if($co_last > $v||$commission_end[$k]<$v){
                return ['code'=>-1,'msg'=>'当前金额应该大于前一行的最大金额','index'=>$k];
            }
            $temp =[$v,$commission_end[$k],$unit,$commission_rate[$k],'%',$k,$byType,'yes'];
            $temp = '"'.implode('","',$temp).'"';
            $insert_values[] = $temp;
        }
        // 将不是该unit的数据禁用  并将该unit的数据删除
        $update_sql = "update ld_userreport_commissionrule set is_on='no' where unit!=? and bytype = ?";

        $this->adb->pquery($update_sql,[$unit,$byType]);
        $delete_sql = "delete from ld_userreport_commissionrule where unit=? and bytype = ? ";
        $this->adb->pquery($delete_sql,[$unit,$byType]);
        $insert_field = "(`start`,`end`,`unit`,commission_rate,commission_unit,`order`,`bytype`,is_on)";
        $insert_values = '('. implode('),(',$insert_values).")";
        $insert_sql = "insert into ld_userreport_commissionrule $insert_field values $insert_values";
        $res = $this->adb->pquery($insert_sql);
        return $this->adb->getLastInsertID($res);
    }
    public function ajaxGetRuleList()
    {
        $byType = $_REQUEST['byType'];
        if(empty($_REQUEST['unit'])){
            $unitSql = "select unit from ld_userreport_commissionrule where is_on='yes' and bytype=?";
            $unitRes = $this->adb->pquery($unitSql,[$_REQUEST['byType']]);
            $unitNums = $this->adb->num_rows($unitRes);
            if($unitNums>=1){
                $unit = $this->adb->query_result($unitRes,0,"unit");
            }else{
                $unit = "万元";
            }
        }else{
            $unit = $_REQUEST['unit'];
        }
        $unit_type = ($unit == "万元")?"amount":"target_rate";
        $res['unit'] = $unit;
        $moduleName = $byType == "byOrder"?"合同":"收款";
        //zxm 20201123 新增的服务收费奖金 没有tab切换
        if($byType=="byOrder"||$byType=="byCash"){
            $res['select'] = $this->getCommissionType($moduleName,"commission_type","commission_type","html",'',$unit_type);
        }else{
            $res['select'] = [];
        }

        $res['list'] = $this->getRuleList($_REQUEST['byType'],$unit);
        return $res;
    }
    public function getRuleList($byType,$unit){

        $sql = "select * from ld_userreport_commissionrule where bytype=? and unit=? order by `order` asc";
        $res = $this->adb->pquery($sql,[$byType,$unit]);
        $nums = $this->adb->num_rows($res);
        $list = [];
        if($nums > 0){
            for($i=0;$i<$nums;$i++){
                $list[$i]['id'] = $this->adb->query_result($res,$i,'id');
                $list[$i]['start'] = $this->adb->query_result($res,$i,'start');
                $list[$i]['end'] = $this->adb->query_result($res,$i,'end');
                $list[$i]['unit'] = $this->adb->query_result($res,$i,'unit');
                $list[$i]['order'] = $this->adb->query_result($res,$i,'order');
                $list[$i]['commission_rate'] = $this->adb->query_result($res,$i,'commission_rate');
                $list[$i]['commission_unit'] = $this->adb->query_result($res,$i,'commission_unit');
            }
        }
        return $list;
    }

    public function getCommissionType($moduleName,$name,$id,$type="html",$type_key="",$unit_type='')
    {
        $title = "提成计算方法";
        $list = [
            "amount"=>$moduleName.getFixedLabel("AMOUNT"),
            "target_rate"=>$moduleName."目标完成率"
        ];
        if($type=="html"){
            return $this->getSelectHtml($list,$title,$name,$id,$unit_type);
        }else if($type=="array"){
            return $list;
        }else if($type=="string"){
            return (!empty($type_key)&&isset($list[$type_key]))?$list[$type_key]:"未知提成计算方式";
        }
    }
    /**
     * @param $list
     * @param $title
     * @param $name
     * @param $id
     * @return string
     * 数组组装select
     */
    public function getSelectHtml($list,$title,$name,$id,$unit_type)
    {
        $html = '<label style="font-weight:normal;">'.$title.'&nbsp;&nbsp;</label><select class="borderALL btn-radius-system" style="font-size:12px;" onchange="'.$id.'_change(this)" name="'.$name.'" id="'.$id.'">';
        foreach($list as $k=>$v){
            $selectValue = $unit_type==$k?"selected":'';
            $html .= '<option '.$selectValue.' value="'.$k.'" >'.$v.'</option>';
        }
        $html .= '</select>';
        return $html;
    }
}
