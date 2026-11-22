<?php

class UnifiedSearch_ListQuery extends QueryGenerator
{
    public function __construct($module, $user,$customview='')
    {
        parent::__construct($module, $user,$customview);
        
        $this->initForCustomViewById();
        
    }
    public function getPropertyFields()
    {
       
        if($this->module=='ServiceCharge')
        {
            $this->fields_property=array();
            for($i=0;$i<20;$i++)
             $this->fields_property[]='Accounts';
            
            return $this->fields_property;
        }
        else
        {
            return $this->fields_property;
        }
    }
    public function getQuery($puputype='',$sqltype="1") {
             if($this->module=='PublicAnnouncement')
             {
                $this->whereFieldTables['ld_receipts']=' ld_receipts on  ld_publicannouncement.publicannouncementid = ld_receipts.id ';
                
             }
            $query=parent::getQuery($puputype,$sqltype);
            if($this->module=='Accounts')
            {
                $dataProfile=getAccount_Set('dataprofile');
               
                if($dataProfile==1)
                {
                    
                }
                else
                {
                    //公海未分配客户不控制数据权限（可查询所有公海未分配客户） 
                    if(!empty($this->chart_owner))
                    {
                        $scopesql=trim($this->chart_owner,')');
                        $scopesql.='  or ld_account.publicaccount=1 ) ';
                        $query=str_replace($this->chart_owner,$scopesql,$query);
                    }
                    
                }
            }
            return $query;
        }
    public function getFromClause()
    {
   	    if(!empty($this->query) || !empty($this->fromClause))
         {
			return $this->fromClause;
		 }
         
         $baseTable = $this->moduleobj->table_name;
		 $sql = " FROM $baseTable ";
		 if(!empty($this->moduleobj->customFieldTable[0])){
			$sql .= " left join  ".$this->moduleobj->customFieldTable[0]." on ". $this->moduleobj->customFieldTable[0].".".$this->moduleobj->customFieldTable[1]."=".$baseTable.".".$this->moduleobj->table_index;
		 }
		  if($this->module=='PublicAnnouncement')
          {
               	$sql .= " left join  ld_receipts  on ld_receipts.id=ld_publicannouncement.publicannouncementid ";
                    
          }
        
        return $sql;
    }
    public function getWhereClause()
    {
        $focus=$this->moduleobj;
        $moduleFieldList = $this->fieldobj->getModuleFields();
        $this->whereFieldTables[$focus->customFieldTable[0]]=" ".$focus->customFieldTable[0]." on ".$focus->customFieldTable[0].".".$focus->customFieldTable[1].'='.$focus->table_name.".".$focus->table_index;
        if($this->module=="Accounts" ||$this->module=='ServiceCharge')
        {
            $deploy_sys=getSys_deploy("72");
            if($deploy_sys['deploy_value']==0)
            {
                //$this->whereFieldTables['ld_contactdetails']=' ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid and ld_contactdetails.reference=1 and ld_contactdetails.deleted=0 ';
               //  $this->whereFieldTables['ld_contactscf']=' ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid ';
                
            }
            
        }
        $searchvalue=trim($_REQUEST['query_string']);
          foreach($moduleFieldList as $fieldname=>$fieldinfo)
          {
            if(!in_array($fieldinfo->getTableName(),$this->moduleobj->tab_name))
                continue;
             if($fieldinfo->getFieldName()==''||$fieldinfo->getColumnName()=='')
             {
                //源单字段
                continue;
             }
             if( $fieldinfo->getUIType()==53)
             {
                $user_columnname=$fieldinfo->getColumnName();
                 $astablename='users_'.$fieldname;//表别名：模块名称小写_fieldname
                 $wheresql[]=" $astablename.last_name like '%$searchvalue%'";
                 $this->whereFieldTables[$astablename]=' ld_users as '.$astablename. " on $astablename.id=$focus->table_name.$user_columnname";
             }
             else if($fieldinfo->getUIType()==73)
             {
                 $wheresql[]=" ld_account.accountname like '%$searchvalue%'";
                 $this->whereFieldTables['ld_account']=' ld_account on ld_account.accountid='.$fieldinfo->getTableName().".".$fieldinfo->getColumnName();
             }
             else if($fieldinfo->getUIType()==4)
             {
                $wheresql[]=$fieldinfo->getTableName().".".$fieldinfo->getColumnName(). " like '%$searchvalue%'";
             }
             else 
             {
                $wheresql[]=$fieldinfo->getTableName().".".$fieldinfo->getColumnName()." like binary  '%$searchvalue%'";
             }
          }
          
         
            $ret_wheresql=' where '.$focus->table_name.'.deleted=0 and ('.implode(" or ",$wheresql).")";
            
          return $ret_wheresql;
        
    }
}






?>