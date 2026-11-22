<?php


class LeadsSetQueryGenerator extends QueryGenerator
{
     public function getDateTimestr()
    {
        Crm_load_class_file('CommonView',"modules/CustomView");
          $this->datetimestr=CommonView::MysqlFilterDateTimeStr();
          return $this->datetimestr;
    }
    public function getConditionDateSql($value, $operator, $field)
    {
        
        
        
        $db = PearDatabase::getInstance();
        if(($operator == 'between' || $operator == 'bw' ||array_key_exists($operator,$this->datetimestr)) && !is_array($value)) {
			$valueArray = explode('#' , $value);
         
		}
		else if(is_array($value)) {
			$valueArray = $value;
		} else{
			$valueArray = array($value);
		}
		$sql = array();
		if($operator == 'between' || $operator == 'bw'||array_key_exists($operator,$this->datetimestr)) {
			if($field->getFieldName() == 'birthday') {
			
				$sql[] = "BETWEEN DATE_FORMAT(".$valueArray[0].", '%m%d') AND ".
						"DATE_FORMAT(".$valueArray[1].", '%m%d')";
			} else {
			 $tmpone=$valueArray[0];
             $tmptwo=$valueArray[1];
			    if($field->getFieldDataType()=='datetime')
                {
                    $tmpone=' concat( '.$valueArray[0].','.'" 00:00:00")';
                    $tmptwo=' concat( '.$valueArray[1].','.'" 23:59:59")';
                }
				$sql[] = " BETWEEN ".$tmpone." AND ".
							$tmptwo;
			}
			return $sql;
		}
    }
    
    	/**
	* V6.0 角色权限改进
	* @reason 获取 授权范围、共享、查看自己创建的单据 条件
	* 只有查看在全部的情况下，才会去获取以上条件
	* @author Chj 
	*/
	public function whereRangeQuery(){
		return '';
	}
}
?>