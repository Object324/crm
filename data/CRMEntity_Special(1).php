<?php

class CRMEntity_Special
{
    static 	function filterInactiveFields($module,$focus) {
		if ($focus->__inactive_fields_filtered) {
			return;
		}

		global $adb, $mod_strings;

		// Look for fields that has presence value NOT IN (0,2)
		
		$cachedModuleFields = array();
		if ($cachedModuleFields === false) {
			// Initialize the fields calling suitable API
			//getColumnFields($module);
		
            $cachedModuleFields=$focus->fieldobj->getFieldInfoList();
		}

		$hiddenFields = array();

		if ($cachedModuleFields) {
			foreach ($cachedModuleFields as $fieldinfo) {
				$fieldLabel = $fieldinfo['fieldlabel'];
				// NOTE: We should not translate the label to enable field diff based on it down
				$fieldName = $fieldinfo['fieldname'];
				$tableName = str_replace("ld_", "", $fieldinfo['tablename']);
				$hiddenFields[$fieldLabel] = array($tableName => $fieldName);
			}
		}

		if (isset($focus->list_fields)) {
			$focus->list_fields = array_diff_assoc($focus->list_fields, $hiddenFields);
		}

		if (isset($focus->search_fields)) {
			$focus->search_fields = array_diff_assoc($focus->search_fields, $hiddenFields);
		}

		// To avoid re-initializing everytime.
		$focus->__inactive_fields_filtered = true;
	}
     
     static function getAuditTrialLog($id, $cur_tab_id, $rel_tab_id,$focus, $actions = false) {
    	global $currentModule;
		global $adb,$list_max_entries_per_page_new_more;
        $header = array(getFixedLabel('operatoroertime'),getFixedLabel('operatoroer'),getFixedLabel('OPERATMETHOD'));
		$query = "select ld_users.last_name,ld_fileoperationlog.operating_type,ld_fileoperationlog.operating_time
                  from ld_fileoperationlog
	              left join ld_users on ld_fileoperationlog.operator = ld_users.id
                  where ld_fileoperationlog.crmid=$id";

        $count_result = $adb->pquery( mkCountQuery($query));
        $noofrows = $adb->query_result($count_result,0,'count');
        global $related_left_type;
		if($related_left_type == 3){//获取相关信息条数
			$related_entries = array();
            
			$related_entries['relcount'] = $noofrows;
			return $related_entries;
		}
        if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
			$start = vtlib_purify($_REQUEST['start']);
			if($start == 'last'){
				if($noofrows > 0){
					$start = ceil($noofrows/$list_max_entries_per_page_new_more);
				}
			}
			if(!is_numeric($start)) $start = 1;
			elseif($start < 1) $start = 1;
			$start = ceil($start);
		}else{
			$start = 1;
		}
        global $related_left_start;
		$related_left_start = $start;
		$limstart=($start-1)*$list_max_entries_per_page_new_more;
		$query .= ' order by ld_fileoperationlog.operating_type desc LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
        $result = $adb->pquery($query,array());
        $num_rows=$adb->num_rows($result);
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++)
            {
                $listview_entrie = array();
				$listview_entrie[] = $adb->query_result($result,$i,'operating_time');
				$listview_entrie[] = $adb->query_result($result,$i,'last_name');
                $listview_entrie[] = getFixedLabel(strtoupper($adb->query_result($result,$i,'operating_type')));
                $listview_entries[] = $listview_entrie; 
            }
            
        }
        
        $navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'CommunicationLog',$id);
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput);
		return $return_value;

	}
    static  function getPrintTemplate($tabid,$focus)
    {
        global $adb,$current_user;   
        $checksql='SELECT groupid FROM ld_users2group  WHERE userid=?';
        $checkresult=$adb->pquery($checksql,array($current_user->id));
        $groupid=array();       
        for($i=0;$i<$adb->num_rows($checkresult);$i++)
        {
          $groupid[]=$adb->query_result($checkresult,$i,'groupid');  
        }
        $groupids=implode(",",$groupid); //求出当前用户所在的部门ID。                    
        $sql='select 1 from ld_tab where tabid='.$tabid.' and printtab=1';
        $result=$adb->pquery($sql,array());      
        if($adb->num_rows($result)<=0)
        {
            return 'NOTEMPLATEPRINT';
        }
      
          $sql="SELECT  distinct templateprintid,templateprintname,isdefault,sequence,printfilename
            FROM
            (
              select 
                ld_templateprint.tabid,
                ld_templateprint.templateprintid,
                ld_templateprint.templateprintname ,
                ld_templateprint.isdefault,
                ld_templateprint.sequence,
                ld_templateprint.printfilename
           	  from ld_templateprint where allocatetype=0 
          	  UNION
              select  
                  ld_templateprint.tabid,
                  ld_templateprint2user.templateprintid,
                  ld_templateprint.templateprintname ,
                  ld_templateprint.isdefault,
                  ld_templateprint.sequence,
                  ld_templateprint.printfilename
           		  from ld_templateprint2user 
           		  inner JOIN ld_users on ld_users.id=ld_templateprint2user.userid 
                  inner JOIN ld_templateprint 
           		  on ld_templateprint.templateprintid=ld_templateprint2user.templateprintid  
               where allocatetype=2  and ld_templateprint2user.userid=$current_user->id
               GROUP BY  ld_templateprint2user.templateprintid
			  UNION
              select  
                  ld_templateprint.tabid,
                  ld_templateprint2user.templateprintid,
                  ld_templateprint.templateprintname ,
                  ld_templateprint.isdefault,
                  ld_templateprint.sequence,
                  ld_templateprint.printfilename
           		  from ld_templateprint2user 
           		  inner JOIN ld_profile on ld_profile.profileid=ld_templateprint2user.userid 
                  inner JOIN ld_templateprint 
           		  on ld_templateprint.templateprintid=ld_templateprint2user.templateprintid  
               where allocatetype=3  and ld_templateprint2user.userid=$current_user->profileid
               GROUP BY  ld_templateprint2user.templateprintid 
			   ";
             if(sizeof($groupid)>0)
             {
                $sql.="  UNION
                       select  
                           ld_templateprint.tabid,
                        	ld_templateprint.templateprintid,
                            ld_templateprint.templateprintname,
                            ld_templateprint.isdefault ,
                            ld_templateprint.sequence,
                            ld_templateprint.printfilename
                    		from ld_templateprint2user 
                    		inner JOIN ld_groups on ld_groups.groupid=ld_templateprint2user.userid inner JOIN ld_templateprint 
                    		on ld_templateprint.templateprintid=ld_templateprint2user.templateprintid  
                            where allocatetype=1 and ld_groups.groupid in($groupids) 
                             GROUP BY  ld_templateprint2user.templateprintid
                    ) AS alldata where tabid=?
                     order by sequence asc,templateprintid desc";
                     
             } 
             else
             {
                $sql.=" ) as alldata  where tabid=? order by sequence asc,templateprintid desc";
                
             }             
              $result=$adb->pquery($sql,array($tabid));      
        //}        
         $templatearr=array();
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $sequence=$adb->query_result($result,$i,'sequence');
            $templateprintID=$adb->query_result($result,$i,'templateprintid');
            $templatename=$adb->query_result($result,$i,'templateprintname');
            $isDefault=$adb->query_result($result,$i,'isdefault');
            $printfilename=$adb->query_result($result,$i,'printfilename');
            $extension = pathinfo($printfilename, PATHINFO_EXTENSION);// 文件格式
            if($extension == 'doc' || $extension == 'docx'){
                $type = 'Word';
            }else if($extension == 'xls' || $extension == 'xlsx'){
                $type = 'Excel';
            }else{
                $type = '';
            }
            $templatearr[]=array($templatename,$isDefault,$templateprintID,$type);
        }
        
        //$userPeritted=isPermitted('Emails','Create');//Liver 判断用户是否有发送邮件权限,bug0028008: 合同订单明细界面：关联创建-工具：当用户没有【邮件管理】模块权限时，应该不显示【发送邮件并添加附件】
        //$templatearr['userPeritted']=$userPeritted;

        return $templatearr;
    }
}

?>