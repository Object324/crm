<?php
crm_load_class_file('ScopOfAuthority','include/ScopOfAuthority');
class cls_ScopOfAuthority extends ScopOfAuthority{
    public $scopeType,$senioruserid;
    public function __construct($adb, $module)
    {
        parent::__construct($adb, $module);
    }
    public function setParams($scopeType, $senioruserid){
        $this->scopeType = $scopeType;
        $this->senioruserid = $senioruserid;
    }
    public function setsmowneridsql($smowneridsql){
        $this->smowneridsql = $smowneridsql;
    }
    //重写获取负责人字段的方法
    public function getsmowneridsql(){
        if(!empty($this->smowneridsql)){
            return $this->smowneridsql;
        }else{
            return $this->focus->table_name.'.'.$this->moduleSearchSmownerId;
        }

    }
    //获取模块数据范围重写  父类方法中有session  这个方法重写去掉session
    public function getSmOwnerSearchSql(){
        $scopeType=$this->scopeType;
        $senioruserid=$this->senioruserid;

        if ($this->module == 'WorkReportList') {
            $table = $this->focus->table_name.'.smcreatorid';//工作汇报没有负责人字段，故使用创建人
        }else{
            $table = $this->getsmowneridsql();
        }
        if(method_exists($this->focus,"getCreateColumnName"))
            $tablecreator = $this->focus->table_name.'.'.$this->focus->getCreateColumnName();//用于我创建的查询
        else
            return "";
        $SearchScope=' and ( ';
        if(!empty($scopeType)){
            $this->smownerScope=$scopeType;
        }
        if(empty($this->smownerScope)){
            $this->smownerScope = 'SmOwner_Search_All';
        }
        if($this->smownerScope){
            switch($this->smownerScope){
                case 'SmOwner_Search_All':
                    return $this->getModuleListViewQuery();
                case 'SmOwner_Search_Me':
                    $SearchScope .="$table=".$this->userobj->id;
                    break;
                case 'smowner_search_senior':	// 查看范围 高级
                    if(!empty($senioruserid)){
                        $SearchScope .= $table . ' in ('.$senioruserid.')';
                    }else{
                        return $this->getModuleListViewQuery();
                    }
                    break;
                case 'SmOwner_Search_Create':
                    //19732: 服务收费管理>列表：普通用户，允许查询自己创建的单据为否，查看范围选择“我创建的”，结果：显示了服务收费人不是当前用户的数据。
                    $SearchScope .="($tablecreator=".$this->userobj->id .$this->getModuleListViewQuery().')';
                    break;
                case 'SmOwer_Search_ShareMe':
                    $SearchScope .=' ld_tabshare.viewuserid = '.$this->userobj->id.'';
                    break;
                case '':
                    break;
                case 'SmOwer_Search_MeToShare'://共享给他人的
                    //18429: 所有模块>列表：查看范围，共享给他人的，数据显示错误。
                    //23790: 市场活动列表：将单据共享给自己和个人用户后，查看范围选择“共享给他人的”，没有显示这条刚共享的单据
                    $SearchScope .='ld_tabshare.Shareuserid = ' .$this->userobj->id. ' and ld_tabshare.viewuserid != \''.$this->userobj->id.'\''.$this->getModuleListViewQuery();
                    break;
                //订单商城  我的订货
                case 'SmOwner_Search_MyShopcart':
                    $SearchScope .= $this->focus->table_name . ".order_source in ('订货商城','商城小程序') and $tablecreator=".$this->userobj->id;
                    break;
                default:
                    //BUG0065472   zxm 20230425 客户地图的数据范围选择全部后数据消失
                    $SearchScope .= " $table in(".$this->smownerScope.")";

            }
        }else {
            return "";
        }
        $SearchScope=$SearchScope ." )";

        return $SearchScope;
    }
    
    public function getTabShareSql()
    {
         //edit:can 20230804 普通用户登录穿透列表没有数据
        global $current_user;
        return '';
    }
}