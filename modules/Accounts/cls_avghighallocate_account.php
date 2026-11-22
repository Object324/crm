<?php
crm_load_class_file('cls_allocate_account','modules/Accounts');
crm_load_function_file('setAccount_Average_Group','modules/Accounts','averageComputer');
crm_load_function_file('getAverageUserName','modules/Accounts','averageComputer');
/**
 * 公海平均分配
 * */
class cls_avghighallocate_account extends cls_allocate_account{

    public function __construct($focus,$module)
    {
        global $current_user;
        parent::__construct($focus,$module,0,$_REQUEST['userid'],2);
        $this->setHighAccount_Smowner();
       // $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['test']=0;
    }
    private $selectedindex=0;
    private function setHighAccount_Smowner(){
        global $current_user;
        $caterorid = $this->userid;//分配弹出层中勾选的用户
        $this->smownerids=explode(',',$caterorid);//将勾选的用户ID转换为数组
         $this->startrow = $_REQUEST['startrow'];
        $this->endrow = $_REQUEST['endrow'];
        $excludedRecords = $_REQUEST['excludedRecords']?:'';
        if($this->startrow==0||!isset($_REQUEST['startrow']))
        {
            $this->startrow=0;
            unset($_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']);
        }
        if($_REQUEST['idstring']=='all'){
            
            if($_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['selectid'])
            {
                $idstring=$_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['selectid'];
              
            }
            else
           {
              $idstring=getSelectedRecords($_REQUEST, 'Accounts', rtrim($_REQUEST['idstring'], ';'), $excludedRecords);
              // file_put_contents(globalStatic::$root_directory.'modules/Accounts/a.txt',$this->module,FILE_APPEND);
         
           
             $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['selectid']=$idstring;
           }
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
       
        if(!isset($_REQUEST['endrow']) || $this->endrow > count($this->recordids))
        {
            $this->endrow = count($this->recordids);
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

        //duan  20240429 XUQIU20240423-05 奥克兰：公海分配时判断验证规则
        crm_load_class_file('cls_PageValidataSave','data');
        $PageValidataSaveobj=new cls_PageValidataSave('Accounts',0,0);
        $PageValidataSaveobj->setApplication('allocated');
        $PageValidataSaveobj->batchoprate = 'yes';
        $errormsg_arr = [];

        foreach($Account_HighAverage_Group as $key => $value){
            foreach($value as $kky=> $accountid){
                $this->id=$accountid;
                $this->userid=$this->getUserId();

                //duan  20240429 XUQIU20240423-05 奥克兰：分配时判断验证规则
                $PageValidataSaveobj->resetobj('Accounts',$accountid);//重置验证规则对象
                $PageValidataSaveobj->setAllowSave('no');
                $PageValidataSaveobj->setNewSmownerid($this->userid);
                $PageValidataSaveobj->getValidDataInfoPhp();
                if(!empty($PageValidataSaveobj->errortip)){
                    $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['Account_Average'][$this->userid] += 0;//依次统计所选用户分配个数
                    $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['success'] += 0;//依次统计分配成功的个数
                    $errormsg = $PageValidataSaveobj->errortip;
                    $errormsg_arr[$this->userid][] = $errormsg;
                    continue;
                }

                parent::save();

            }

            $this->selectedindex++;
//            $edit_err .= sprintf($batchsuccesslog,getAverageUserName($this->smownerids[$key]),count($Account_HighAverage_Group[$key]))."<br>";
        }

//        @edit:liushuai,2021-03-11,reason:【ID1001390】公海未分配批量平均分配增加显示进度条
        foreach($_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['Account_Average'] as $userid =>$value){
            $tmp_errormsg = '';
            if(is_array($errormsg_arr[$userid]) && count($errormsg_arr[$userid]) >0){
                $tmp_arr = array_unique($errormsg_arr[$userid]);
                $tmp_errormsg = implode(',',$tmp_arr);
            }
            $edit_err .= sprintf($batchsuccesslog,getAverageUserName($userid),$value).$tmp_errormsg."<br>";
        }

        $submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
        $error= $this->success-$_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['success'];
        $submitlog = sprintf($submitlog, $this->success, $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['success'], $error);
        $submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
        $edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";

        $entity['log']['value'] = $submitlog . $edit_err;//批量处理信息
        $entity['start']['value'] = $start;//当前页数
        $entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
        
        $field = $focus->fieldobj->getFieldInfoobjBykey('columnname', $smcolumnname);
        $entity['title']['value'] = getVarFixedLabel('CHANGECREATED', $field->getFieldLabel());// 确认  
        $entity['ids']=$_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['test'];
        $entity['maxrows']=sizeof($this->recordids);
        $entity['selectrows']=sizeof($this->recordids);
        if($this->endrow >= sizeof($this->recordids))
        {
            file_put_contents(globalStatic::$root_directory.'modules/Accounts/b.txt',$this->module,FILE_APPEND);
            unset($_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']);
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
$focus=CRMEntity::getInstance('Accounts');
                                                                
$obj_avghig=new cls_avghighallocate_account($focus,'Accounts',0,$_REQUEST['userid'],2);
$obj_avghig->savelist();
?>