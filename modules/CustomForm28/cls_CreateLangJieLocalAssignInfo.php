<?php
/**
 * eidt:can 
 * date:20200806
 * 配送订单批量分配配送任务单
 * */
// crm_load_class_file('cls_ParentRelatedFields','include/RelatedFields');
class cls_CreateLangJieLocalAssignInfo
{
    public $localorderIds;
    /**
     * 配送订单ID
     * */
    public function __construct($localorderIds)
    {
        $this->localorderIds=trim($localorderIds,';');
        
    }
    public function getIds(){
        global $adb;
        $localids=$this->localorderIds;
        $id_arr=explode(";",$localids);
        //把选择的local订单的id转为行
        $tmpsql="SELECT 	SUBSTRING_INDEX(
            		SUBSTRING_INDEX('$localids', ';', seq),
            		';' ,- 1
            	) AS customformid
            	
            FROM ( SELECT * FROM sequence AS r ) b
            WHERE
            	seq BETWEEN 1
            AND ( SELECT 1 + LENGTH('$localids') - LENGTH(
            			REPLACE ( '$localids',';',	'')
            		)
            )";
            //删除已经创建过local任务单的id
        $sql="select group_concat(tmp.customformid) from ld_customform27

            INNER JOIN ld_customform28detail
            
            on ld_customform27.customform27id=ld_customform28detail.entitytypeid
            inner join ld_customform28 on ld_customform28.customform28id=ld_customform28detail.id
            and ld_customform28.deleted=0 
            right join ($tmpsql) as tmp on tmp.customformid=ld_customform27.customform27id 
             where ld_customform27.customform27id is null ";
   //dump($sql);
        $result=$adb->pquery($sql);
        if($adb->num_rows($result)>0)
        {
            return $adb->query_result($result,0,0);
            
        }
        else{
            return '';
        }
      /*  if($adb->num_rows($result)>0)
        {
           $num_rows=$adb->num_rows($result);
            //$c = array_diff($a,$b);  
            if($num_rows==sizeof($id_arr))
            {
                return "";
            } 
            for($i=0;$i<$num_rows;$i++)
            {
                $customformid=$adb->query_result($result,$i,'customformid');
                
            }
        }
        else
        {
            return $localids;
        }*/
         
    }
    public function getData()
    {
        $billid=$this->getIds();
        
        //$cls_tabledetail_focus=cls_ParentRelatedFields::getInstance("CustomForm28","7899","");
	   //$data = $cls_tabledetail_focus->getData();
    }
}
?>