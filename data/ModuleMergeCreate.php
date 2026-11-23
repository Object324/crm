<?php
/**
 * 合并创建
 * 
 */
class ModuleMergeCreate
{
    private $module;
    private $mergemodule;
    private $select_id;
    function __construct($module,$mergemodule,$select_id){
        $this->module = $module;
        $this->select_id = $select_id;
    }
    
    public function getMergeCreate(){
        $focus = CRMEntity::getInstance($this->module);
        
        $selectidarr = explode(';',$this->select_id);
       
        unset($selectidarr[count($selectidarr)-1]);
        
        sort($selectidarr);
        
        //当单据数量为1，走关联创建
       /* if(count($selectidarr) == 1){
            $selectid = $selectidarr[0];
            $_REQUEST[$focus->table_index] = $selectid;
            $focus->retrieve_entity_info($selectid,$this->module);
            $_REQUEST['account_id'] = $focus->column_fields['account_id'];
            $_REQUEST['contact_id'] = $focus->column_fields['contact_id'];
             
        }else{*/
            $lineidstr = '';    //lineitem_id
            $codestr = '';      //编号（产品信息备注栏显示）
            foreach($selectidarr as $val){
                $strids = substrTd($val.',',0,'Quotes').',';
                //echo $strids;
                $pro_num = substr_count($strids,',');
                $lineidstr .= $strids;
                $focus->retrieve_entity_info($val, $this->module);
                $accounts[] = $focus->column_fields['account_id'];
                $contacts[] = $focus->column_fields['contact_id'];
                $codestr .= str_repeat($focus->column_fields[$focus->table_code].',',$pro_num);
            }

            if(count(array_unique($accounts)) == 1){
                if($accounts[0] != '')
                    $_REQUEST['account_id'] = $accounts[0];
            }
            if(count(array_unique($contacts)) == 1){
                if($contacts[0] != '')
                    $_REQUEST['contact_id'] = $contacts[0];
            }
            
            $lineidstr = substr($lineidstr,0,-1);
            //echo $lineidstr.'<br>';
            $focus->column_fields[$focus->table_code] = $codestr;
            //echo $codestr;
            
    		$focus->lineitemIds = $lineidstr;

    		$focus->mode = 'mergecreate';
    		
            return $focus;
        //}
    }
}
?>