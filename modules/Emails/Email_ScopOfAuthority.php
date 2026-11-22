<?php

class Email_ScopOfAuthority extends ScopOfAuthority
{
    public function getsmowneridsql()
    {
        return  $table = "ld_mailmanager_mailrecord.userid";
    }
    
    /**
	 * V6.0 角色权限改进
	 * @reason 数据权限范围
	 * @author Chj
	 */
	public function getModuleListViewQuery() {
		global $related_header;
        global $current_user;
        return  " and ld_mailmanager_mailrecord.userid=".$current_user->id;
        
       $userids= $this->getCurUserScopeId();
     
    	if($this->userobj->is_admin == 'on' || ($this->userobj->accountallview == 1 && $related_header != 'Campaigns')){
				return '';
			}
            if($related_header=='Campaigns'&&($this->userobj->is_admin == 'on' || $this->userobj->campaignsview == 1))
            {
                return ' ';
            }
			$crmtablename = "ld_mailmanager_mailrecord.userid";
		
        if ($this->userobj->is_admin != 'on' && ($this->moduleShareRules[$this->tabid] == SHARE_PRIVATE || $this->moduleShareRules[$this->tabid] == ''))
        {
			if($this->getUserModuleScoperType() == SCOPE_PERSON){	//授权范围：个人
				$query[] = " $crmtablename = " . $this->userid;
			}
			else if($this->getUserModuleScoperType() == SCOPE_ALL){	//如果业务单据授权范围为全部

				//$userall = getCurSmOwnerSearchScope($this->module);
				//$userscope = $userall['UserCombo'];//获取授权范围
				//$userscopeid = array_keys($userscope);
				$userscope = get_user_array(FALSE, "", '');
				$userscopeid = array_keys($userscope);
				$query[] = "$crmtablename in (".implode(',',$userscopeid).")";
			}
			else if($this->getUserModuleScoperType() == SCOPE_HIGER_USER || $this->getUserModuleScoperType() == SCOPE_HIGHER_GROUP)
            {	//授权范围：高级
				$userscope = $this->getUserModuleScopeHigher();//获取授权范围
				//$userscopeid = array_keys($userscope);
				$userscopeid = $userscope;
				$userscopeid[]=$this->userobj->id;
				if(!empty($userscopeid))
					$query[] = "$crmtablename in (".implode(',',$userscopeid).")";
			}
			
		}
	
		$this->scope_sql = $query;
		if(count($query) >= 1)
			return ' and (' .implode(' or ',$query)  . ')';
		else
			return '';
	}
}

?>