<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/HomeStuffChuantou.php");
/**
 * 处理首页默认组件穿透的类
 */
class HomeStuffChuantou45 extends HomeStuffChuantou
{
    protected $conditionChuantouSql='';
    public function __construct(){
        parent::__construct();
    }
    //商机统计图_按所属行业和销售阶段统计
    public function setCondition45($advft){
        $XAxisName = $_REQUEST['XAxisName'];//所属行业  实际上是关联客户的所属行业  需要构建个子查询
        //所属行业构建子查询
        $sql = "select distinct ld_potential.potentialid from ld_potential  left join ld_account on ld_potential.accountid=ld_account.accountid where ld_potential.deleted=0  ";
        if($XAxisName=='无'||empty($XAxisName)){
            $where = " and ifnull(ld_account.industry,'')='' ";
        }else{
            $where = " and ifnull(ld_account.industry,'')='$XAxisName' ";
        }
        $sql .= $where;
        $this->conditionChuantouSql =$sql;//穿透特殊条件
        //销售阶段名称 条件
        return $this->setCondition44($advft);
    }
    //重写父类方法--将setCondition45的sql inner join上去
    public function getDatarangesqlArr($boardstuffid){
        //$this->datarangesql 这个数组中的条件sql子查询是不带inner join 和on 的
        $daterange = $this->daterange;
        $this->datarangesql = $this->DataRangeHomeboardObj->getDataRangeSql($this->stuffid,$boardstuffid,$this->scopeType,$this->selectuserid,$daterange,$this->approve_value);
        $this->datarangesqlInnerJoin = $this->DataRangeHomeboardObj->datarangesqlArr;//这个数组中的条件sql子查询是带inner join 和on 的
        $this->curdatarangsql_str = $this->datarangesql[$this->penetrateModule]; //不带innerjoin 的
        //拼接特殊穿透条件
        $this->curdatarangsql_str = "select a.* from ($this->curdatarangsql_str)a inner join (".$this->conditionChuantouSql.")conditionChuantouSql on a.potentialid=conditionChuantouSql.potentialid" ;
        $this->curdatarangsql=$this->datarangesqlInnerJoin['datarangesql_'.$this->penetrateModule];//带inner join 的
        //拼接特殊穿透条件
        $this->curdatarangsql=  $this->curdatarangsql." inner join ($this->conditionChuantouSql)conditionChuantouSql on conditionChuantouSql.potentialid=ld_potential.potentialid";
        
    }
}



