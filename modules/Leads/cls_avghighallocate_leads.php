<?php
crm_load_class_file('cls_allocate_leads','modules/Leads');
crm_load_function_file('setAccount_Average_Group','modules/Leads','averageComputer');
crm_load_function_file('getAverageUserName','modules/Leads','averageComputer');
/**
 * 公海平均分配
 * */
class cls_avghighallocate_leads extends cls_allocate_leads{

    public function __construct($focus,$module)
    {
        parent::__construct($focus,$module,0,$_REQUEST['userid'],2);
        $this->setHighAccount_Smowner();
    }
    private $selectedindex=0;
    private function setHighAccount_Smowner(){
        global $current_user;
        $caterorid = $this->userid;//分配弹出层中勾选的用户
        $this->smownerids=explode(',',$caterorid);//将勾选的用户ID转换为数组

        $excludedRecords = $_REQUEST['excludedRecords']?:'';
        if($_REQUEST['idstring']=='all'){
            $idstring = getSelectedRecords($_REQUEST, 'Leads', rtrim($_REQUEST['idstring'], ';'), $excludedRecords);
            $this->recordids=$idstring;
            
        }else{
            $idstring = $_REQUEST['idstring'];//勾选的客户
            $this->recordids=array_filter(explode(';',$idstring));//将勾选的客户ID转换为数组,并且过滤掉数组值为空的数据
        }

        //获取批量处理数
        $deployarray = getSys_deploy(67);
        $btach_num = $deployarray['deploy_value'];
        

        $this->success=count($this->recordids);//选中的客户条数
      
        if(sizeof($this->recordids)>$btach_num)
        {
            $this->recordids=array_slice($this->recordids,0,$btach_num);
            
        }
        $smownerid_count = count($this->smownerids);//勾选的用户总数

//        @edit:liushuai,2021-03-11,reason:【ID1001390】公海未分配批量平均分配增加显示进度条
        //将所选单据id分割
        $this->startrow = $_REQUEST['startrow'];
        $this->endrow = $_REQUEST['endrow'];
        if(!isset($_REQUEST['endrow']) || $this->endrow > count($this->recordids))
        {
            $this->endrow = count($this->recordids);
        }
        if($this->startrow==0||!isset($_REQUEST['startrow']))
        {
            $this->startrow=0;
            unset($_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetleads']);
        }
        if (count($this->recordids)>1) {
            $this->newrecordids = array_slice($this->recordids,$this->startrow,$this->endrow - $this->startrow);
        }

    }
    public function savelist()
    {
        global $current_user;
        $Account_HighAverage_Group = setAccount_Average_Group($this->newrecordids,$this->smownerids);//将公海客户,按用户个数平均分组
        $this->Account_HighAverage_Group=$Account_HighAverage_Group; 
        $edit_err='';
        $smcolumnname='smownerid';
        $focus = $this->focus;
        $batchsuccesslog = getFixedLabel('AVERAGE_PROMPT');
       
        
        foreach($Account_HighAverage_Group as $key => $value){
            foreach($value as $kky=> $accountid){
                $this->id=$accountid;
                $this->userid=$this->getUserId();

                parent::save();

            }
            echo $this->userid;
            $this->selectedindex++;
//            $edit_err .= sprintf($batchsuccesslog,getAverageUserName($this->smownerids[$key]),count($Account_HighAverage_Group[$key]))."<br>";
        }
       
//        @edit:liushuai,2021-03-11,reason:【ID1001390】公海未分配批量平均分配增加显示进度条
        foreach($_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetleads']['leads_Average'] as $userid =>$value){
            $edit_err .= sprintf($batchsuccesslog,getAverageUserName($userid),$value)."<br>";
        }

        $submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
        $error= $this->success-$_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetleads']['success'];
        $submitlog = sprintf($submitlog, $this->success, $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetleads']['success'], $error);
        $submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
        $edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";

        $entity['log']['value'] = $submitlog . $edit_err;//批量处理信息
        $entity['start']['value'] = $start;//当前页数
        $entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
        
        $field = $focus->fieldobj->getFieldInfoobjBykey('columnname', $smcolumnname);
        $entity['title']['value'] = getVarFixedLabel('CHANGECREATED', $field->getFieldLabel());// 确认  

        $entity['maxrows']=sizeof($this->recordids);
        $entity['selectrows']=sizeof($this->recordids);
        if($this->endrow >= sizeof($this->recordids))
        {
            unset($_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetleads']);
        }
        $this->set_HighAvgsaveReturn($entity);

    }
  
     public function getUserId()
    {
       
        return $this->smownerids[$this->selectedindex];
    }
    
    protected function set_HighAvgsaveReturn($entity)//平均分配后弹出层提示
    {
        ob_clean();
        ob_flush();
        $json = new Zend_Json();
        $jsonentity = $json->encode($entity);
        echo $jsonentity;
        die;          
    }
    
   
}
$focus=CRMEntity::getInstance('Leads');
                                                                
$obj_avghig=new cls_avghighallocate_leads($focus,'Leads',0,$_REQUEST['userid'],2);
$obj_avghig->savelist();
?>