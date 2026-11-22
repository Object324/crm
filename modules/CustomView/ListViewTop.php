<?php
/**
*关键视图
*/
function getKeyMetrics($calCnt,$scopeType,$senioruserid,$is_phone='no')
{
	global $adb;
	global $current_language,$default_charset;

	$metriclists = getMetricList($scopeType,$senioruserid);

	// Determine if the KeyMetrics widget should appear or not?
	if($calCnt == 'calculateCnt') {
		return count($metriclists);
	}
	$public_account = [];

	if(isset($metriclists))
	{
		global $current_user;
		foreach ($metriclists as $key => $metriclist) {
				if($is_phone=="yes") {
					crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
					$mobj = new cls_ListViewWX($metriclist['module']);
					$mobj->get_page_query(null, "yes");
				}
                $_REQUEST['viewid']=$metriclist['id'];

                if(get_file_address($metriclist['module'],'ProductDetails') && $metriclist['module'] != 'ServiceCharge')
                {
					$queryGenerator=QueryGenerator::getInstance($metriclist['module'], $current_user,'','','no');
               	    $queryGenerator->initForCustomViewById($metriclist['id']);
                    $metricsql = $queryGenerator->getQueryRow_Count();
					$_REQUEST['viewid']=0;
                }
                elseif(get_file_address($metriclist['module'],'ContactsDetails'))
                {
					$customview = new CustomView();
					if ($metriclist['module'] == 'Accounts') {
						crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
						$cls_PublicAccounts =   cls_PublicAccounts::getInstance('Accounts');
						$public_account = $cls_PublicAccounts->getPublicAccount();
					
					}
                    $category=$customview->getCustomCategory($metriclist['id']);
					//duan 20230412 如果客户模块的公海未启用，则已分配、未分配页签的数据分类不在关键视图中显示
					if($public_account['status'] == 'no' && in_array($category,['PUBLICALLOCATE','NOALLOCATE','ALLPUBLICACCOUNT'])){
						unset($metriclists[$key]);
						continue;
					}
					//	0024201: 首页>组件视图：客户-全部（非公海）列表，数据分类“客户（本周）”，在首页-关键视图中显示的数量错误。
					//客户分公海已分配和未分配分类，所有做判断处理
                    //edit:can 2020-10-09 42845: （http://chaoliyang.gnway.org/crm [^]）（深圳市超力扬科技发展有限公司客户问题）首页>关键视图：“关键视图”显示的数量与点击打开客户列表所显示的数量不一致。（如图）
					if($category == 'NOALLOCATE')
					{
						//下面代码有处理，如果分配不是全部（含所有公海）下的，则在关键视图内不显示
					   	//	$_REQUEST['pagepublicaccounttype']='NOALLOCATE';
						//	$metricsql .=' and ld_account.publicaccount=1 ';
					}
					else if($category == 'PUBLICALLOCATE')
					{
					   	//$_REQUEST['pagepublicaccounttype']='PUBLICALLOCATE';
					//	$metricsql .=' and ld_account.publicaccount>1 ';
					}else{
						if($public_account['show_publicaccount_tab'] == 'yes'){
							$_REQUEST['pagepublicaccounttype']='ALLACCOUNT';
						}else{
							$_REQUEST['pagepublicaccounttype']='DEFAULTALLACCOUNT';
						}
					}
                    $queryGenerator=QueryGenerator::getInstance($metriclist['module'], $current_user,'','','no');
               	    $queryGenerator->initForCustomViewById($metriclist['id']);
                     $metricsql = $queryGenerator->getQueryRow_Count();
				    $_REQUEST['viewid']=0;
					
                }else{	//chj 2020/12/2 43547: （http://xiaoshou360.com/xs/lufei [^]）（路飞网络科技）首页-关键视图报表；跟进中这个分类显示的是0，点击之后查看，会发现是有客户数据的
					$queryGenerator=QueryGenerator::getInstance($metriclist['module'], $current_user,'','','no');
               	    $queryGenerator->initForCustomViewById($metriclist['id']);

                    $metricsql = $queryGenerator->getQueryRow_Count($metriclist['id']);

                    $_REQUEST['viewid']=0;
				}

                    $metricresult = $adb->query($metricsql);
    				if($metricresult)
    				{
    					$rowcount = $adb->query_result($metricresult,0,0);
    					$metriclists[$key]['count'] = $rowcount;
    				}
              
			
		}

	}

	//zxm 2020-0106 移动端只要数据
	if($is_phone=="yes"){
		foreach($metriclists as $k=>$v) {
			//getAccount_Set('status') : 1公海未开启  0公海已开启
			if ($v['module'] == 'Accounts') {
				if ($public_account['status'] == 'yes') {
					$oCustomView = new CustomView($v['module']);
					if ($oCustomView->getCustomCategory($v['id']) != 'ALLACCOUNT') {
						unset($metriclists[$k]);
					}
				}
			}
		}
		return array_values($metriclists);
	}
	$title=array();
	$title[]='keyMetrics.gif';
	$title[]=getFixedLabel('CRITICALVIEW');
	$title[]='home_metrics';
	$header=Array();
    /**
     * edit:kevin
     * date:2013-07-31
     * reason:4563
     */ 
	$header[]=getFixedLabel('DATACATEGORY');
	$header[]=getFixedLabel("MODULE");
	$header[]=getFixedLabel("QUANTITY");
	$entries=Array();
	if(isset($metriclists))
	{
		$oddRow = true;
		foreach($metriclists as $metriclist)
		{
			$value=array();
            //getAccount_Set('status') : 1公海未开启  0公海已开启
            if($metriclist['module'] == 'Accounts')
            {
                if($public_account['status'] == 'yes')
                {
                    $oCustomView = new CustomView($metriclist['module']);
                    //echo $oCustomView->getCustomCategory($metriclist['id']) . '<br>';
                    if($oCustomView->getCustomCategory($metriclist['id']) != 'ALLACCOUNT')
                    {
                        continue;
                    }
                }
            }
			$CVname = textlength_check_There($metriclist['name'],12);//(strlen($metriclist['name']) > 20) ? (mb_substr($metriclist['name'],0,20,$default_charset).'...') : $metriclist['name'];
			/**
             * edit:diony
             * date:2013-12-26
             * reason:0006490: 首页“关键视图”组件：希望将数据分类后面的创建人隐藏不显示
             */ 
             if($metriclist['count']==''){
                $metriclist['count']=0;
             }
            //$value[]='<a href="index.php?action=ListView&module='.$metriclist['module'].'&viewname='.$metriclist['id'].'">'.$CVname . '</a> <font style="color:#6E6E6E;">('. $metriclist['user'] .')</font>';
			
            if($metriclist['module'] != 'Accounts')
            {
				$url = 'index.php?pageto_action=ListView&pageto_module='.$metriclist['module'];
				$page_addurl = '&viewname='.$metriclist['id'];
                $value[]='<a href="javascript:;" onclick="home_href(\''.$url.'\',\''.$page_addurl.'\')" title="'.$CVname.'">'.$CVname . '</a>';
    			$value[]='<a href="javascript:;" onclick="home_href(\''.$url.'\',\''.$page_addurl.'\')" title="'.getTranstab($metriclist['module']).'">'.getTranstab($metriclist['module']). '</a>';
    			$value[]='<a href="javascript:;" onclick="home_href(\''.$url.'\',\''.$page_addurl.'\')" title="'.$metriclist['count'].'">'.$metriclist['count'].'</a>';
			}
            else
            {
				$url = 'index.php?pageto_action=ListView&pageto_module='.$metriclist['module'];
				$page_addurl = '&keyviewname='.$metriclist['id'];
                $value[]='<a href="javascript:;" onclick="home_href(\''.$url.'\',\''.$page_addurl.'\')" title="'.$CVname.'">'.$CVname . '</a>';
    			$value[]='<a href="javascript:;" onclick="home_href(\''.$url.'\',\''.$page_addurl.'\')" title="'.getTranstab($metriclist['module']).'">'.getTranstab($metriclist['module']). '</a>';
    			$value[]='<a href="javascript:;" onclick="home_href(\''.$url.'\',\''.$page_addurl.'\')" title="'.$metriclist['count'].'">'.$metriclist['count'].'</a>';
            }
            $entries[$metriclist['id']]=$value;
		}

	}
    //print_r($entries);
	$values=Array('Title'=>$title,'Header'=>$header,'Entries'=>$entries);
	if ( ($display_empty_home_blocks ) || (count($value)!= 0) )
		return $values;

}
function textlength_check_There($field_val,$textlength=0) {
	global $listview_max_textlength, $default_charset;
    if($textlength==0)
        $textlength=$listview_max_textlength;
	if ($textlength && $textlength > 0) {
		$temp_val = preg_replace("/(<\/?)(\w+)([^>]*>)/i", "", $field_val);
		if (function_exists('mb_strlen')) {
			if (mb_strlen($temp_val,$default_charset) > $textlength) {
				/**
				 * 中文如果输入“”字符，截取中文的时候会出现乱码，
				 * 目前未发现其他字符乱码问题，先专门解决这个乱码问题
				 * 先对内容进行转码，查找是否存在&amp;ldquo;、&amp;rdquo;
				 * 如果存在，则替换为英文标点，再进行切割
				 * @reason 0010810 项目任务，任务名称字段中有“中文引号”，序时簿中查看时会显示特殊字母
				 * @author Tujt 2014-08-21
				 */
				$value = htmlspecialchars($temp_val);
				if(strpos($value,'&amp;ldquo;') >= 0){
					$find = array('&amp;ldquo;','&amp;rdquo;');
					$replace = array('"','"');
					$value = str_replace($find,$replace,$value);
					if(mb_strlen($value,$default_charset) > $textlength){
						$temp_val = mb_substr(preg_replace("/(<\/?)(\w+)([^>]*>)/i", "", $value), 0, $textlength, $default_charset) . '...';
					}
				}else{
					$temp_val = mb_substr(preg_replace("/(<\/?)(\w+)([^>]*>)/i", "", $field_val), 0, $textlength, $default_charset) . '...';
				}
			}
		} elseif (strlen($field_val) > $textlength) {
			$temp_val = substr(preg_replace("/(<\/?)(\w+)([^>]*>)/i", "", $field_val), 0, $textlength) . '...';
		}
	} else {
		$temp_val = $field_val;
	}
	return $temp_val;
}	
/** to get the details of a customview Entries
* @returns  $metriclists Array in the following format
* $customviewlist []= Array('id'=>custom view id,
*                         'name'=>custom view name,
*                         'module'=>modulename,
						  'count'=>''
			   )
*/
function getMetricList($scopeType,$senioruserid)
{
	global $adb, $current_user;
	$usertype = $current_user->user_type;//用户是crm还是prm用户
	$regopobj=RegOp::getInstance();
	$prmauthenmodule_arr=explode(",",$regopobj->getPrmModules());

	$metriclists = [];
	$ssql = 'select ld_customview.entitytype,ld_customview.cvid,ld_customview.viewname,ld_customview.entitytype,ld_customview.customcategory from ld_customview inner join ld_tab on ld_tab.name = ld_customview.entitytype';
	$ssql .= ' where ld_customview.setmetrics = 1 ';
	$sparams = array();
	//0017891: (天训 192.168.1.88:85/crm）首页>关键视图,关于数据分类显示问题
	//ld_customview.status 为0  发现都是手机端的模块
	//edit:can 20220921  	（品思）合同订单模块，有三个分类已经删除了，但是仍然显示在首页关键视
	$ssql .='and (  ld_customview.status =3 or ld_customview.userid='.$current_user->id.' )';
	 
	$ssql .= ' and (ld_tab.presence=0 or ld_tab.presence=2 or ld_tab.name = \'Events\') order by ld_customview.entitytype,ld_customview.sequence';
	$result = $adb->pquery($ssql, $sparams);
	while($cvrow=$adb->fetch_array($result))
	{
		$metricslist = Array();
		//zxm @date:2024/11/19 @reason: 邱：经销商没有授权这个模块，关键视图里面不能显示这些模块的入口BUG20241113-61
		$tmpmodule = $cvrow['entitytype'];
		if($usertype=='prm'&& !in_array($tmpmodule,$prmauthenmodule_arr))
		{
			continue;
		}
		$metricslist['id'] = $cvrow['cvid'];
		if($cvrow['viewname'] == 'All'){
			if($cvrow['entitytype'] == 'Reminds'){
				$cvrow['viewname'] = getFixedLabel('LBL_UNREADEN');
			}else{
				$cvrow['viewname'] = getFixedLabel('ALL');
			}
		}
		if ($cvrow['entitytype'] == 'Accounts') {
			crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
			$cls_PublicAccounts =   cls_PublicAccounts::getInstance('Accounts');
			$public_account = $cls_PublicAccounts->getPublicAccount();

			if($public_account['status']&&$cvrow['customcategory']!='ALLACCOUNT')
			{
				continue;
			}

		}

		$metricslist['name'] = $cvrow['viewname'];
		if($cvrow['entitytype']=='Events'){
			$metricslist['module']='Calendar';
		}
		else{
				$metricslist['module'] = $cvrow['entitytype'];
		}
		$metricslist['user'] = $current_user->last_name;
		$metricslist['count'] = 0;
		if(isPermitted($cvrow['entitytype'],"index") == "yes"){
			$metriclists[] = $metricslist;
		}
	}

	return $metriclists;
}

?>
