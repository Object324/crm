<?php

crm_load_class_file('cls_RemindsCenter','modules/Reminds');
class static_Reminds
{
    
    static function getRemindsCount(){
            global $adb, $current_user;

            // $date = date('Y-m-d H:i:s', time());
            // $callback_counts = 'select count(1) from ld_reminds WHERE ld_reminds.deleted=0 and recieverid='.$current_user->id.' and status_rmd="未读" and is_del_rec=0 and date_time<="'.$date.'" and remindsid > 0;';
            
			// 获取"全部消息"分类的高级条件
			$remindscenterObj = new cls_RemindsCenter();
			$RemindsCategory_arr = $remindscenterObj->customView->getCustomView_RemindsCategory();
			$RemindsCategory_all = [];
			foreach ($RemindsCategory_arr as $index => $categoryinfo) {
				if($categoryinfo['preset_all'] == 'yes'){
					$RemindsCategory_all = $categoryinfo;
					break;
				}
			}
			$list_query = $remindscenterObj->getEntireListSql($RemindsCategory_all['cvid'],getRemindsCvid('unread'));
            
        	$result_counts = $adb->query($list_query);
            // $num_rows=$adb->query_result($result_counts, 0);
            $num_rows=$adb->num_rows($result_counts);
            if($num_rows>0)
                $counts = $num_rows;
            else
                $counts=0;
            
            // $callback_counts = 'select count(1) from ld_reminds_accepted WHERE ld_reminds_accepted.deleted=0 and recieverid='.$current_user->id.' and status_rmd="未读" and is_del_rec=0 and date_time<="'.$date.'" and remindsid > 0;';
            
            
        	// $result_counts = $adb->query($callback_counts);
            // $num_rows=$adb->query_result($result_counts, 0);    
            // if($num_rows>0)
            //     $counts += $num_rows;
         
            return $counts;
    }
    /**
     * edit:diony
     * reason:获取提醒数量
     * */
    static function getCountForAppCount()
    {
		global $adb,$current_user;
		$date = date('Y-m-d H:i:s', time());
        $num_rows=static_Reminds::getRemindsCount();      
		$reminds['total']=$num_rows;
		return $reminds;
    }
	/**
     * edit:chj
     * reason:获取提醒内容
     * */
	static function getRemindsContent(){
		global $adb,$current_user;
		$cur_time = time();
		$date = date('Y-m-d H:i:s',$cur_time);
		
		$id=$_REQUEST['remindsid'];
        //zkt 20220527  51613【亿海蓝】首页下方弹窗提醒，点击下一条消息。下方显示很多代码杨海超：kfbcrm也有同样的问题
		if($_REQUEST['page_tag']=='down')
		{
		   $order="where remindsid < '$id' order by remindsid desc,date_time desc";
		   $pagenum=$_REQUEST['pagenum'] + 1;
		}
		elseif($_REQUEST['page_tag']=='up')
		{
		   $pagenum=$_REQUEST['pagenum'] - 1;
		   $order="where  remindsid > '$id' order by remindsid asc,date_time desc";
		}
        //edit:xll 2023/05/04 BUG0065801 kfbcrm-右上角消息，点击推迟后应留在当页
        elseif($_REQUEST['current_page'] > 0){
            $pagenum = $_REQUEST['current_page'];
            $is_last = $_REQUEST['is_last'];
            $order = "where remindsid < '$id' order by remindsid desc,date_time desc";
            $order_last = "where remindsid > '$id' order by remindsid asc,date_time desc";//推迟最后一页时向前翻页
            $order = ($is_last == 1) ? $order_last : $order;
        }
		else{
			$pagenum = 1;
			$order="order by remindsid desc,date_time desc ";
		}

		// 获取"全部消息"分类的高级条件
		crm_load_class_file('RemindsQueryGenerator','include/QueryGenerator');
		$remindscenterObj = new cls_RemindsCenter();
		$RemindsCategory_arr = $remindscenterObj->customView->getCustomView_RemindsCategory();
		$RemindsCategory_all = [];
		foreach ($RemindsCategory_arr as $index => $categoryinfo) {
			if($categoryinfo['preset_all'] == 'yes'){
				$RemindsCategory_all = $categoryinfo;
				break;
			}
		}
		$remindscenterObj->queryGenerator = new RemindsQueryGenerator('Reminds', $current_user,$remindscenterObj->customView);
		$remindscenterObj->addDataCategoryConditions($RemindsCategory_all['cvid']);// 增加分类条件
		$remindscenterObj->setSearchConditions($_REQUEST);// 增加查找条件
		$remindscenterObj->queryGenerator->addUserSearchConditions($remindscenterObj->searchinfos);
		$unread_cvid = getRemindsCvid('unread');
		$remindscenterObj->queryGenerator->initForCustomViewById($unread_cvid);
		$remindscenterObj->queryGenerator->reminds_viewname = $unread_cvid;
		$list_query = $remindscenterObj->queryGenerator->getQuery('',2);

		
		// $callback_counts = 'select count(remindsid) from (
		// 						select remindsid from ld_reminds WHERE ld_reminds.deleted=0 and recieverid='.$current_user->id.' and status_rmd="未读"
		// 								and is_del_rec=0 and date_time<="'.$date.'" and remindsid > 0 ';

		// $callback_counts.=' union all  select remindsid from ld_reminds_accepted WHERE ld_reminds_accepted.deleted=0 and recieverid='.$current_user->id.' and status_rmd="未读"
		// 						and is_del_rec=0 and date_time<="'.$date.'" and remindsid > 0 ';
		// $callback_counts .= " ) as tmp ";

		// $callback_query = 'select ld_reminds.reltab,ld_reminds.date_time,ld_reminds.content,ld_reminds.related_to,ld_users.last_name,remindsid from ld_reminds 
		// left join ld_users ON ld_reminds.smcreatorid = ld_users.id 
		// WHERE ld_reminds.deleted=0 and 
		// recieverid='.$current_user->id.' and status_rmd="未读" and is_del_rec=0
		//  and date_time<="'.$date.'" and remindsid > 0 ';
         
         
		// $callback_query .= ' union all  select ld_reminds_accepted.reltab,ld_reminds_accepted.date_time,
		//         ld_reminds_accepted.content,ld_reminds_accepted.related_to,ld_users.last_name,remindsid from ld_reminds_accepted 
		// left join ld_users ON ld_reminds_accepted.smcreatorid = ld_users.id 
		// WHERE ld_reminds_accepted.deleted=0 and 
		// recieverid='.$current_user->id.' and status_rmd="未读" and is_del_rec=0
		//  and date_time<="'.$date.'" and remindsid > 0 ';

		
		$callback_query = 'select * from ( '.$list_query.') as tmp2 '.$order.' limit 1 ';
		// dump($callback_query);
		
		// $result_counts = $adb->query($callback_counts);
		// $counts = $adb->query_result($result_counts, 0);
		
		$result_counts = $adb->query($list_query);
		$counts = $adb->num_rows($result_counts);

		$prepage = 'yes';
		$nextpage = 'yes';
		if($pagenum == 1){
			$prepage = 'no';
			if($counts <= $pagenum){
				$nextpage = 'no';
			}
		}
		if($pagenum >= $counts){
			$nextpage = 'no';
		}
		$result = $adb->query($callback_query);
        if($adb->num_rows($result)<=0)
        {
            return [];
        }
		$reltab = $adb->query_result($result, 0,'reltab');
		$date_time = $adb->query_result($result, 0,'date_time');
		$smcreatorid = $adb->query_result($result, 0,'smcreatorid');
		if (!empty($smcreatorid) && $smcreatorid > 0) {
			$last_name = getUserFullName($smcreatorid);
		}else{
			$last_name = 'System';
		}
		$content = $adb->query_result($result, 0,'content');
		$header_content = $adb->query_result($result, 0,'content');
		$remindsid = $adb->query_result($result, 0,'remindsid');
		$parent_id = $adb->query_result($result, 0,'related_to');
		// dump($result);

		// if($last_name=='')$last_name='system';
		if (!empty($parent_id)) {
			$parent_module = getSalesEntityType($parent_id);
			$valueTitle = $parent_module;
			$valueTitle = getTranstab($valueTitle);
			$displayValueArray = getEntityName($parent_module, $parent_id);
			if (!empty($displayValueArray)) {
				foreach ($displayValueArray as $key => $value) {
					$displayValue = $value;
				}
			}
			$label_fld ="<a style='display:inline;' target='_blank' href='index.php?pageto_module=$parent_module&pageto_action=index&pageto_record=$parent_id' title='$valueTitle'>$displayValue</a>";
			/**
			 * 判断合同订单、服务收费模块时，获取对应的客户信息并添加到单据后面
			 * @reason 0014117: 合同订单（服务合同），审批通过后，提醒信息改进需求
			 * @author Tujt 2015-04-28
			 */
			$accountarr = array();
			switch($parent_module){
				case 'SalesOrder':
					$qeury = 'SELECT ld_account.accountid,ld_account.accountname 
								FROM ld_salesorder 
									INNER JOIN ld_account 
										ON ld_account.accountid = ld_salesorder.accountid 
								WHERE ld_salesorder.salesorderid = '.$parent_id.' LIMIT 1;';
					//and ld_salesorder.deleted = 0
					$result = $adb->query($qeury);
					$rows = $adb->num_rows($result);
					if(1 == $rows){
						$accountarr['accountid'] = $adb->query_result($result, 0,'accountid');
						$accountarr['accountname'] = $adb->query_result($result, 0,'accountname');
					}
					break;
				case 'ServiceContracts':
					$qeury = 'SELECT ld_account.accountid,ld_account.accountname 
								FROM ld_servicecontracts 
									INNER JOIN ld_account 
										ON ld_account.accountid = ld_servicecontracts.accountid 
								WHERE ld_servicecontracts.servicecontractsid = '.$parent_id.' LIMIT 1;';
					//and ld_salesorder.deleted = 0
					$result = $adb->query($qeury);
					$rows = $adb->num_rows($result);
					if(1 == $rows){
						$accountarr['accountid'] = $adb->query_result($result, 0,'accountid');
						$accountarr['accountname'] = $adb->query_result($result, 0,'accountname');
					}
					break;
			   case 'ContactRecords':
					$qeury = 'SELECT ld_account.accountid,ld_account.accountname 
								FROM ld_contactrecords 
									INNER JOIN ld_account 
										ON ld_account.accountid = ld_contactrecords.accountid 
								WHERE ld_contactrecords.contactrecordID = '.$parent_id.' LIMIT 1;';
					//and ld_salesorder.deleted = 0
					$result = $adb->query($qeury);
					$rows = $adb->num_rows($result);
					if(1 == $rows){
						$accountarr['accountid'] = $adb->query_result($result, 0,'accountid');
						$accountarr['accountname'] = $adb->query_result($result, 0,'accountname');
					}
					break;
			}
			if(!empty($accountarr)){
				 /*
				 *  diony 2016-06-20
				 *	0022975: 温馨提醒弹出层：弹出层中客户名称链接字段值没有显示为蓝色字体
				 *  去掉 style="color:#666666;" 
				 */
				 //chj 2021/1/5 43984: 右下角消息提醒：合同订单提醒，分别点击超链接中的“合同编号”和“客户名称”，打开详情界面方式不一样
				 $label_fld .="<a style='display:inline;' target='_blank' href='index.php?pageto_module=Accounts&pageto_action=index&pageto_record=".$accountarr['accountid']."' title='".$accountarr['accountname']."'>(".$accountarr['accountname'].")</a>";
				//$label_fld .= '&nbsp;<a referencemodule="Accounts" referencerecord="'.$accountarr['accountid'].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" title="'.getTranstab('Accounts').'">('.$accountarr['accountname'].')</a>';
			}//end
		}
        if($reltab!='ReportLog'&&!empty($reltab)&&$reltab!='CooperativeWork' && $reltab!='WorkReportList' )
		{
			$relfocus=CRMEntity::getInstance($reltab);
			if($relfocus )
			{//32501: 企业微信消息提醒
				$listlinkfield=$relfocus->list_link_field;
				$fieldlabel=$relfocus->fieldobj->getFieldInfoBykeyValue("fieldname",$listlinkfield,'fieldlabel');
				$listlinkfieldlabel = $fieldlabel;
                //wym 240604 BUG20240520-15 销售线索即将回收提醒，右上角弹窗中多了个编号字段
                //相关对象为空时 不应该显示字段翻译 目前只有回收提醒有该情况,如果其他提醒不想隐藏,可以在sql中获取type值,筛选出只有回收提醒不显示
                if(empty($parent_id)){
                    $listlinkfieldlabel = '';
                }
			}
		}
		elseif ($reltab == 'WorkReportList' || $reltab == 'CooperativeWork'){
            $listlinkfieldlabel = getTranstab($reltab);
            // $remindstype=getWorkReportResult('remindstype',$remindsid);
            // $workreport=['workreport','task','reply','reportCC'];//回复reply  日志workreport 任务task 日志@抄送reportCC
            // $workreply=['replyCC','praise','comment','finishtask','canceltask','forwardCC','commentCC'];//回复抄送replyCC 点赞 praised 点评comment 完成任务finishtask 取消任务canceltask 转发抄送forwardCC 点评抄送commentCC
            // if (in_array($remindstype,$workreport)){
            //     $workreport_no=getWorkReportResult('workreport_no',$parent_id);
            //     $workreport=getWorkReportResult('workreport',$parent_id);
            //     $label_fld ="<a style='display:inline;' target='_blank' href='index.php?pageto_module=WorkReportList&pageto_action=index&pageto_record=$parent_id' title='$workreport_no'>$workreport_no</a>";
            // }elseif (in_array($remindstype,$workreply))
            // {
            //     $reportid=getWorkReportResult($remindstype,$parent_id);
            //     $reportid=getWorkReportResult($remindstype,$parent_id);
            //     $workreport_no=getWorkReportResult('workreport_no',$reportid);
            //     $label_fld ="<a style='display:inline;' target='_blank' href='index.php?pageto_module=WorkReportList&pageto_action=index&pageto_record=$reportid' title='$workreport_no'>$workreport_no</a>";

            // }
            $label_fld = getRelatedtoValue($remindsid,$reltab,$parent_id,'href');
        }else{
            $listlinkfieldlabel = getTranstab($reltab);
		}
		$data['reltab'] = $reltab;
		$data['date_time'] = $date_time;
		$data['last_name'] = $last_name;
		$data['content'] = htmlentities($content);
        $header_content = html_entity_decode($content);
        if(!empty($listlinkfieldlabel)){
            $header_content .= '<p>'.$listlinkfieldlabel;
        }
        if(!empty($listlinkfieldlabel)){
            $header_content .= '<font>'.$label_fld.'</font>';
        }
        $header_content .= '<br/>'.getFixedLabel('operatoroertime').'：'.$date_time;
        $data['header_content'] = $header_content;
		$data['remindsid'] = $remindsid;
		$data['label_fld'] = $label_fld;
		$data['prepage'] = $prepage;
		$data['nextpage'] = $nextpage;
		$data['pagenum'] = $pagenum;
		return $data;
			
	}
    /**
     * edit:can
     * reason:获取提醒数量及内容
     * */
    static function getCountForApp()
    {
		global $adb,$current_user;
		$date = date('Y-m-d H:i:s', time());
        $num_rows=static_Reminds::getRemindsCount();      
		$reminds['total']=$num_rows;
		
        $callback_counts = 'select content,date_time,remindsid from ld_reminds WHERE ld_reminds.deleted=0 and recieverid='.$current_user->id.' and status_rmd="未读" and is_del_rec=0 and date_time<="'.$date.'" and remindsid > 0 order by date_time desc limit 1;';

		$result_counts = $adb->pquery($callback_counts,array());
		if($adb->num_rows($result_counts)>0){
			$content=trim($adb->query_result($result_counts,0,'content'));

			$len=mb_strlen($content,'utf8');

			if($len<=20)
				$reminds['content']=$content;
			else
			{
				$reminds['content']=mb_substr($content,0,20,'utf-8').'...';
			}
			$reminds['id']=$adb->query_result($result_counts,0,'remindsid');
			$reminds['createdtime']=$adb->query_result($result_counts,0,'date_time');
       }
       else
       {
		 $reminds['id']=0;
         $reminds['content']='';
         $reminds['createdtime']='';
       }
       
        return $reminds;
    }
    /**
     * edit:can
     * reason:获取提醒的相关数量
     * */
    static function getDetailCountForApp()
    {
        global $adb, $current_user;
   
      
         $jsonArray['unreadcount']=static_Reminds::getRemindsCount();
       
        
         return $jsonArray;
    }
    
    /**
     * edit:can
     * reason:获取列表
     * */
     static function getListApp()
     {
        global $adb,$current_user,$mobile_pagerecordcount;
        $type=$_REQUEST['type'];
         
        if($type=='unread')
        {
              $sql="SELECT distinct remindsid, ld_reminds.content, ld_reminds.reltab, ld_reminds.related_to, ld_reminds.date_time, ld_reminds.smcreatorid,
             ld_reminds.remindsid FROM ld_reminds left join ld_users as users_creator on users_creator.id=ld_reminds.smcreatorid WHERE ld_reminds.deleted = 0 AND 
            ( (( ld_reminds.status_rmd = '未读') and ( ld_reminds.date_time <= ?) )) AND ld_reminds.remindsid > 0 
            and is_del_rec=0 and ld_reminds.recieverid=?  ";
            //$result=$adb->pquery($sql,array(date("Y-m-d H:i:s"),$current_user->id));
            $param=array(date("Y-m-d H:i:s"),$current_user->id);
            $_REQUEST['page'] = 1;//editor:gyqCom0309 0026414: （APP）消息提醒：显示90条，进入列表界面一直往底翻，翻到刷不出单据，返回，仍然显示还有40条单据
        }
      
        else if($type=='readen')
        {
            $sql="SELECT distinct remindsid, ld_reminds.content, ld_reminds.reltab, ld_reminds.related_to, ld_reminds.date_time, ld_reminds
            .smcreatorid, ld_reminds.remindsid FROM ld_reminds  left join ld_users as users_creator on users_creator
            .id=ld_reminds.smcreatorid WHERE   ld_reminds.deleted = 0  AND   (  (( ld_reminds.status_rmd = '已读')
             )) AND ld_reminds.remindsid > 0 and is_del_rec=0 and ld_reminds.recieverid=? ";
            // $result=$adb->pquery($sql,array($current_user->id));
            $param=array($current_user->id);
        }
        else if($type='email')
        {
            $sql="SELECT distinct remindsid,ld_reminds.content, ld_reminds.reltab, ld_reminds.related_to, ld_reminds.date_time, ld_reminds
                .recieverid, ld_reminds.status_rmd, ld_reminds.remindsid FROM ld_reminds  WHERE   ld_reminds.deleted
                 = 0  AND ld_reminds.remindsid > 0 and is_del_send=0 and ld_reminds.smcreatorid=? ";
           // $result=$adb->pquery($sql,array($current_user->id));
            $param=array($current_user->id);
        }
        //echo $sql;echo '<br><br>';
        //print_r($param);die;
        $result=$adb->pquery($sql,$param);
        $noofrows=$adb->num_rows($result);
        $jsonArray['summary']['totalrows']=$noofrows;
        $startpagenum=0;
        $endpagenum=$mobile_pagerecordcount;
        $startpagerecord=0;
        $endpagerecord=$mobile_pagerecordcount;
        $haveprevpage='yes';
        $havenextpage='yes';
            
        $totalpagecount=ceil ($noofrows/$mobile_pagerecordcount);
        if($totalpagecount*$mobile_pagerecordcount<$noofrows)
        {
                $totalpagecount+=1;
        }
        if(!isset($_REQUEST['page']))
        {
                $_REQUEST['page']=1;
        }
        $startpagenum=$_REQUEST['page']-1;
        if($_REQUEST['page']>=$totalpagecount)//是否有下一页
        {
                $havenextpage='no';
                $startpagenum=$totalpagecount-1;
        }
        if($_REQUEST['page']<=1)//是否有上一页
        {
                $haveprevpage='no';
                $startpagenum=0;
        }
          
        $jsonArray['summary']['pagecount']=$totalpagecount;
        $jsonArray['summary']['havenextpage']=$havenextpage;
        $jsonArray['summary']['haveprevpage']=$haveprevpage;
        $jsonArray['summary']['curpagenum']=$startpagenum+1;   
        $startpagerecord=$startpagenum*$mobile_pagerecordcount;
        $endpagerecord=$startpagerecord+$mobile_pagerecordcount;
        $jsonArray['summary']['pagecount']=$totalpagecount;
        $jsonArray['summary']['havenextpage']=$havenextpage;
        $jsonArray['summary']['haveprevpage']=$haveprevpage;
        $jsonArray['summary']['curpagenum']=$startpagenum+1;   
        $startpagerecord=$startpagenum*$mobile_pagerecordcount;
        $endpagerecord=$startpagerecord+$mobile_pagerecordcount;
        $sql.="    order by ld_reminds.createdtime desc  $orderby limit $startpagerecord, $mobile_pagerecordcount ";
      
        $result=$adb->pquery($sql,$param);
        $noofrows=$adb->num_rows($result);
        $user_info['image']=$current_user->getUserImage();
        $user_info['id']=$current_user->id;
        $user_info['lastname']=$current_user->last_name;
        $entityContents=array();
        for($i=0;$i<$noofrows;$i++)
        {
            $relatedto=$adb->query_result($result,$i,'related_to');
            $relatetolabel="";
            $reltab=$adb->query_result($result,$i,'reltab');
            $entityname=getEntitynameByTabId(getTabid($reltab));
        
            $hrefcolumnname=$entityname['fieldname'];
            $hreftable=$entityname['tablename'];
            $hrefkeyColumnname=$entityname['entityidfield'];

            $sql="select $hrefcolumnname from $hreftable  where $hrefkeyColumnname=?";
          
            $hrefresult=$adb->pquery($sql,array($relatedto));
            if($adb->num_rows($hrefresult)>0)
            {
                $relatetolabel=$adb->query_result($hrefresult,0,0);
            }
            //$sql='select '
            $reltablabel=getTranstab($reltab);
            $createdtime=$adb->query_result($result,$i,'date_time');
            $content=$adb->query_result($result,$i,'content');
            $remindsid=$adb->query_result($result,$i,'remindsid');
            $Ids[]=$remindsid;
			/**
			 * 判断合同订单、服务收费模块时，获取对应的客户信息并添加到单据后面
			 * @reason 0014117: 合同订单（服务合同），审批通过后，提醒信息改进需求
			 * @author Tujt 2015-04-28
			 */
			$accountarr = array();
			switch($reltab){
			    case 'SalesOrder':
			        $account_qeury = 'SELECT ld_account.accountid,ld_account.accountname 
								FROM ld_salesorder 
									INNER JOIN ld_account 
										ON ld_account.accountid = ld_salesorder.accountid 
								WHERE ld_salesorder.salesorderid = '.$relatedto.' LIMIT 1;';
					$account_result = $adb->query($account_qeury);
					$rows = $adb->num_rows($account_result);
					if(1 == $rows){
						$accountarr['accountid'] = $adb->query_result($account_result, 0,'accountid');
						$accountarr['accountname'] = $adb->query_result($account_result, 0,'accountname');
					}
			        break;
			    case 'ServiceContracts':
			        $account_qeury = 'SELECT ld_account.accountid,ld_account.accountname 
								FROM ld_servicecontracts 
									INNER JOIN ld_account 
										ON ld_account.accountid = ld_servicecontracts.accountid 
								WHERE ld_servicecontracts.servicecontractsid = '.$relatedto.' LIMIT 1;';
					$account_result = $adb->query($account_qeury);
					$rows = $adb->num_rows($account_result);
					if(1 == $rows){
						$accountarr['accountid'] = $adb->query_result($account_result, 0,'accountid');
						$accountarr['accountname'] = $adb->query_result($account_result, 0,'accountname');
					}
			        break;
	           case 'ContactRecords':
			        $account_qeury = 'SELECT ld_account.accountid,ld_account.accountname 
								FROM ld_contactrecords 
									INNER JOIN ld_account 
										ON ld_account.accountid = ld_contactrecords.accountid 
								WHERE ld_contactrecords.contactrecordID = '.$relatedto.' LIMIT 1;';
					$account_result = $adb->query($account_qeury);
					$rows = $adb->num_rows($account_result);
					if(1 == $rows){
						$accountarr['accountid'] = $adb->query_result($account_result, 0,'accountid');
						$accountarr['accountname'] = $adb->query_result($account_result, 0,'accountname');
					}
			        break;
			}
			if(!empty($accountarr)){
				$relatetolabel .= '  ('.$accountarr['accountname'].')';
			}
            $entityContents[]=array('relatedto'=>$relatedto,'relatetolabel'=>$relatetolabel,'reltab'=>$reltab,'reltablabel'=>$reltablabel,'remindtime'=>$createdtime,'content'=>$content,'curid'=>$remindsid);
        }
        $Ids=implode(',',$Ids);
        $sql="update ld_reminds set status_rmd = '已读' where remindsid in($Ids) ";
        
        $adb->pquery($sql,array());
        $jsonArray['list']=$entityContents;
        $jsonArray['userinfo']=$user_info;
        return $jsonArray;
     }
}


?>