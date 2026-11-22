<?php
class cls_SetOrderBy
{
    public $groupLeftJoinSql = '';
    public $orderbySql = '';
    public $detailviewobj = '';
    public function __construct($detailviewobj)
    {
        $this->detailviewobj = $detailviewobj;
    }


    public function setGroupLeftJoin (){
        $this->groupLeftJoinSql = '';
        $sorting_list_all = $this->detailviewobj->sorting_list_all;
        $orderbySql_arr = [];
        $on_temp_arr = [];
        foreach($sorting_list_all as $k=>$sortinfo1){
            $sorttype1 = $sortinfo1['sorttype'];
            if($sorttype1=='byresult') {
                $aliasname1 = $sortinfo1['aliasname'];
                $sortmethod1 = $sortinfo1['sortmethod'];
                $temp_total_type1 = $sortinfo1['total_type'];
                $temp_group_sql_statistic = $this->detailviewobj->group_sql_statistic[$temp_total_type1];
                if($temp_total_type1=='formula'){
                    //zxm 20231211 如果是公式字段的排序  需要直接将解析好的公式放到排序那
                    foreach($this->detailviewobj->fieldsFormulaArr as $i=>$tmpfieldsFormula){
                        $tmpfieldsFormula_arr = explode('as',$tmpfieldsFormula);
                        $orderbySql_arr[] = $tmpfieldsFormula_arr[0].' '.$sortmethod1;
                    }
                    $aliasname1='';
                }else{
                    foreach($sorting_list_all as $j=>$sortinfo2){
                        if($sortinfo2['sorttype']=='bycolumnname'){
                            $temptable_alias2 = 'group'.$k.$j;
                            $aliasname2 = $sortinfo2['aliasname'];
                            $orderbySql_arr[] = $temptable_alias2.'.'.$aliasname1.' '.$sortmethod1;
                            $orderbySql_arr[] = ' a.'.$aliasname2.' '.$sortinfo2['sortmethod'];
                            $on_temp_arr[] = $aliasname2.$this->detailviewobj->ordercolumn_suff.'=a.'.$aliasname2.$this->detailviewobj->ordercolumn_suff ;
                            $on_temp_str = $temptable_alias2.'.' . implode(' and '.$temptable_alias2.'.',$on_temp_arr);
                            $this->groupLeftJoinSql .= ' left join ('.$temp_group_sql_statistic[$sortinfo2['columns']].')'.$temptable_alias2.' on '.$on_temp_str;
                        }
                    }
                }
            }
        }
        if(!empty($aliasname1))
            $orderbySql_arr[] = ' a.'.$aliasname1.' '.$sortmethod1;

        $this->orderbySql = implode(',',$orderbySql_arr);
    }
}