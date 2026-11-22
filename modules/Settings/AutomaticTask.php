<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project PROT145 自动任务
 * @author Tujt 2015-01-04
 */
global $adb;
$smarty = new lingdangCRM_Smarty;
$setype = (isset($_REQUEST['setype']))?$_REQUEST['setype']:'list';
$smarty->assign('SETYPE',$setype);
$smarty->assign('LANGUAGETYPE',$languageType);
switch($setype){
    case 'list'://列表
		//不能显示出来的模块
		$notmodule = array('Home','MassSMS','MassEmails','SmsPhrases',
							'MailManager','Emails','SalesGoal','EmailListtmp','Prdtnums',
							'CommunicationLog','Navigation','InventoryLedger','Dashboard',
							'InventoryAccount','InventoryQuery','BankCash','OftenUseReport',
							'Comprehensivereport','Reports','Reminds','FieldFormulas','Cache',
							'ReportLog','ModComments','RecycleBin','CooperativeWork','ChinaMap','Customreport');
		$query = 'select DISTINCT ld_tab.tabid,name,tablabel,ld_tab.tabid,
					ld_tranlabel.fieldlabel from ld_tab 
						inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid 
					where languagetype = ? and "ld_tab" = LOWER(trantable) and presence in (0,2) 
						AND name NOT IN ('.'"'.join('","',$notmodule).'"'.') 
					GROUP BY tabid order by tabsequence ';
		$result = $adb->pquery($query,array($languageType));
		$rows = $adb->num_rows($result);
		$tablearr = array();
		if($rows > 0){
			for($i=0;$i<$rows;$i++){//获取模块信息
				$tabid = $adb->query_result($result,$i,'tabid');
				$module = $adb->query_result($result,$i,'name');
				$tablearr[] = array('tabid'=>$tabid,
					'tabname'=>getTranstab($module)
				);
			}
		}
		$tabid = getTabid('Accounts');
		if(isset($_REQUEST['fld_tabid']) && $_REQUEST['fld_tabid'] > 0)
			$tabid = $_REQUEST['fld_tabid'];//当前模块tabid值
		$smarty->assign('TABLEARR',$tablearr);
		$smarty->assign('FLD_TABID',$tabid);
		$header = array(
						'autotaskname'=>getFixedLabel('LBL_AUTOMATICTASK_NAME'),
						'autotaskmode'=>getFixedLabel('LBL_AUTOMATICTASK_TYPE'),
						'autotaskdate'=>getFixedLabel('LBL_AUTOMATICTASK_FREQUENCY'),
						'autotasktype'=>getFixedLabel('LBL_AUTOMATICTASK_CONTENT'),
						'presence'=>getFixedLabel('WHETHERTOENABLE'),
						'operating'=>getFixedLabel('OPERATING')
					);
		$query = 'select autotaskid,autotaskname,autotaskmode,autotaskdate,
					autotasktype,presence from ld_autotask where autotaskid > 0 and tabid = ?;';
		$result = $adb->pquery($query,array($tabid));
		$rows = $adb->num_rows($result);
		$entitylist = '';
		if($rows > 0){
			$autotaskmodearr = array(getFixedLabel('LBL_AUTOMATIC_EXECUTION'),getFixedLabel('LBL_MANUAL_EXECUTION'));
			$eachbackarr = array('day'=>getFixedLabel('Day'));
			$autotasktypearr = array(getFixedLabel('LBL_AUTOMATICTASK_CUSTOMIZED'),getFixedLabel('LBL_AUTOMATICTASK_SQL'));
			$presencearr = array(getFixedLabel('ACTIVATE'),getFixedLabel('INACTIVATE'));
			//编辑按钮
			$editLink = '<a class="Anu3_a" href="#" onclick="editautotask_click(\'%d\',\''.$tabid.'\');return false;">'.getFixedLabel('EDIT').'</a>';
			//删除按钮
			$deleteLink = '<a class="Anu3_a" href="#" onclick="delautotask_click(\'%d\');return false;">'.getFixedLabel('DELETE').'</a>';
			//执行按钮
			$execLink = '<a class="Anu3_a" href="#" onclick="execautotask_click(\'%d\',\''.$tabid.'\');return false;">'.getFixedLabel('Execution').'</a>';
			//开启、关闭按钮
			$presenceLink = '<a class="Anu3_a" href="#" onclick="startautotask_click(\'%d\',\'%d\');return false;">%s</a>';
			
			for($i=0;$i<$rows;++ $i){//循环自动任务信息（不分页，全显示）
				$autotaskid = $adb->query_result($result,$i,'autotaskid');
			    $autotaskname = $adb->query_result($result,$i,'autotaskname');
				$autotaskmode = $adb->query_result($result,$i,'autotaskmode');
				$autotaskdate = $adb->query_result($result,$i,'autotaskdate');
				$autotasktype = $adb->query_result($result,$i,'autotasktype');
				$presence = $adb->query_result($result,$i,'presence');
				$execution = $adb->query_result($result,$i,'execution');
				if ($i%2 ==0) {
                    $entitylist.='<tr id="setting_'.$i.'" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
                }
                else{
                    $entitylist.='<tr id="setting_'.$i.'" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
                }
				$entitylist .= '<td>'.($i+1).'</td>';
				$entitylist .= '<td><span title="'.$autotaskname.'">'.$autotaskname.'</span></td>';
				$entitylist .= '<td><span title="'.$autotaskmodearr[$autotaskmode].'">'.$autotaskmodearr[$autotaskmode].'</span></td>';
				$entitylist .= '<td><span title="'.getFixedLabel('EACH').$eachbackarr[$autotaskdate].'">'.getFixedLabel('EACH').$eachbackarr[$autotaskdate].'</span></td>';
				$entitylist .= '<td><span title="'.$autotasktypearr[$autotasktype].'">'.$autotasktypearr[$autotasktype].'</span></td>';
                if(0 == $presence){
                    $entitylist .= '<td><font class="greenFont"<span title="'.$presencearr[$presence].'">'.$presencearr[$presence].'</span></font></td>';
                }else{
                    $entitylist .= '<td><font class="oragleFont"<span title="'.$presencearr[$presence].'">'.$presencearr[$presence].'</span></font></td>';
                }	
				$link = sprintf($editLink,$autotaskid);
				$link .= sprintf($deleteLink,$autotaskid);
				if(0 == $presence){
					$presence = 1;
					$link .= sprintf($execLink,$autotaskid);
				}else{
					$presence = 0;
				}
				$link .= sprintf($presenceLink,$autotaskid,$presence,$presencearr[$presence]);
				$entitylist .= '<td>'.$link.'</td>';
				$entitylist .= '</tr>';
			}
		}
		$smarty->assign('HEADER',$header);
		$smarty->assign('ENTITYLIST',$entitylist);
		$smarty->assign('COUNT',$rows);
		require_once('SetmenuControl.php');
        if($_REQUEST['ajax'] == 'true')
			$smarty->display("Settings/AutomaticTaskContents.tpl");
		else
			$smarty->display("Settings/AutomaticTask.tpl");
        break;
    case 'edit'://编辑
		$autotaskmodearr = array('0'=>getFixedLabel('LBL_AUTOMATIC_EXECUTION'),'1'=>getFixedLabel('LBL_MANUAL_EXECUTION'));
		$smarty->assign('AUTOTASKMODEARR',$autotaskmodearr);
		$eachbackarr = array('day'=>getFixedLabel('Day'));
		//'week'=>getFixedLabel('Week'),'month'=>getFixedLabel('nMonth')
		$smarty->assign('EACHBACKARR',$eachbackarr);
		$weekopts = array('1'=>getFixedLabel('Monday'),'2'=>getFixedLabel('Tuesday'),
							'3'=>getFixedLabel('Wednesday'),'4'=>getFixedLabel('Thursday'),
							'5'=>getFixedLabel('Friday'),'6'=>getFixedLabel('Saturday'),
							'7'=>getFixedLabel('Sunday'));
		$smarty->assign('WEEKOPTS',$weekopts);//星期
		$eachdayopts = range(1,28);//每月执行天数
		$smarty->assign('EACHDAYOPTS',$eachdayopts);
		$cellselect = array(
			'pi'=>getFixedLabel('Basic_queries'),
			'mi'=>getFixedLabel('Advanced_Search'),
			'ui'=>getFixedLabel('LBL_AUTOMATICTASK_CUSTOMIZED')
		);
		$smarty->assign('CELLSELECT',$cellselect);//定制任务三个标签切换
       
		$fld_tabid = Input('fld_tabid');
		$fld_module = getTabname($fld_tabid);
		$smarty->assign("Fld_TABID",$fld_tabid);
		$smarty->assign("Fld_MODULE",$fld_module);
	
		global $oCustomView;
		//$oCustomView = new CustomView();
		$oCustomView = CustomView::getInstance($fld_module);
		//获取模块对应时间字段、模块字段、以及js等信息
		if($fld_module == 'ServiceCharge')
			$stdfiltercolhtml = getStdFilterHTML(array('ServiceContracts','ServiceCharge'),'');
		else
			$stdfiltercolhtml = getStdFilterHTML(array($fld_module),'');
		$stdfilterjs = $oCustomView->getCriteriaJS();
		$stdfilterhtml = $oCustomView->getStdFilterCriteria();

		$stdfilterjs = strtr($stdfilterjs,array('document.CustomView'=>'document.autotaskform'));
	
		//$smarty->assign("STARTDATE",$stdfilterlist["startdate"]);
		//$smarty->assign("ENDDATE",$stdfilterlist["enddate"]);
	
		$smarty->assign("STDFILTERCOLUMNS",$stdfiltercolhtml);
		$smarty->assign("STDCOLUMNSCOUNT",count($stdfiltercolhtml));
		$smarty->assign("STDFILTERCRITERIA",$stdfilterhtml);
		$smarty->assign("STDFILTER_JAVASCRIPT",$stdfilterjs);
		$smarty->assign("DATEFORMAT",$current_user->date_format);
		$smarty->assign("JS_DATEFORMAT",parse_calendardate('YYYY-mm-ddd'));
		//高级查询，获取显示字段
		$modulecollist = $oCustomView->getModuleColumnsList($fld_module);
		if(isset($modulecollist)) {
			$choosecolslist = getByModule_ColumnsList($fld_module,$modulecollist);
		}
		$advfilterhtml = getAdvCriteriaHTML();
        
		$modulecolumnshtml = getByModule_ColumnsHTML($fld_module,$modulecollist);//高级查询模块字段
		$smarty->assign("FOPTION",$advfilterhtml);
		$smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);
       
		$autotaskfield = getAutoTaskModuleField($fld_module);
		$smarty->assign("AUTOTASKFIELD",$autotaskfield);

		$autotask = array();
		if(isset($_REQUEST['record']) && $_REQUEST['record'] > 0){//编辑
			$record = $_REQUEST['record'];//自动任务ID
			$query = 'select autotaskid,autotaskname,autotaskmode,autotaskdate,
						autotasktype,filtergroup,execution from ld_autotask 
					where autotaskid = ? and tabid = ?;';
                   
			$result = $adb->pquery($query,array($record,$fld_tabid));
			$rows = $adb->num_rows($result);
          
            
			if(1 == $rows){//获取自动任务主表信息
				$autotask['autotaskname'] = $adb->query_result($result,0,'autotaskname');
				$autotask['autotaskmode'] = $adb->query_result($result,0,'autotaskmode');
				$autotask['autotaskdate'] = $adb->query_result($result,0,'autotaskdate');
				$autotask['autotasktype'] = $adb->query_result($result,0,'autotasktype');
				$autotask['filtergroup'] = $adb->query_result($result,0,'filtergroup');
				$execution = $adb->query_result($result,0,'execution');
				if(1 == $execution){//该自动任务正在执行中，不能编辑
					echo '<script type="text/javascript">alert(arrJsPopLabel.RUNNINGPLEASEWAIT);history.go(-1);</script>';exit();//(正在执行中，请稍后)
				}
				if($autotask['autotaskdate'] == 'day'){//每天执行
					$smarty->assign('EACHBACKED','day');
				}else{
					$intervalarr = explode(':',$autotask['autotaskdate']);
					if($intervalarr[0] == 'week'){//每周执行一次
						$smarty->assign('EACHBACKED','week');
						$smarty->assign('WEEKOPTSED',$intervalarr[1]);//每周周几执行
					}else{//每月执行一次
						$smarty->assign('EACHBACKED','month');
						$smarty->assign('MONTHOPTSED',$intervalarr[1]);//每月几号执行
					}
				}
				$smarty->assign('AUTOTASK',$autotask);//自动任务主表信息
				if(1 == $autotask['autotasktype']){//SQL格式
					$query = 'select query from ld_autotaskquery where autotaskid = ?;';
					$result = $adb->pquery($query,array($record));
					$sqlfilter = $adb->query_result($result,0,'query');
					$smarty->assign('SQLFILTER',$sqlfilter);//获取sql代码
				}else{//定制任务
					//1、获取基本查询条件
					$query = 'select columnname,stdfilter,startdate,enddate 
								from ld_autostdfilter where autotaskid = ?;';
					$result = $adb->pquery($query,array($record));
					$rows = $adb->num_rows($result);
					$autostdfilter = array();
					if(1 == $rows){//获取基本查询条件
						$autostdfilter['columnname'] = $adb->query_result($result,0,'columnname');
						$autostdfilter['stdfilter'] = $adb->query_result($result,0,'stdfilter');
						if($autostdfilter['stdfilter'] != 'custom'){
							if(!empty($autostdfilter['stdfilter'])){
								crm_load_class_file('CommonView','modules/CustomView');
								$autostds = CommonView::getDateforStdFilterBytype($autostdfilter['stdfilter']);
								$start = $adb->query_result($result,0,'startdate');
								if(empty($start)){
									$autostdfilter['startdate'] = $autostds[0];
								}else{
									$autostdfilter['startdate'] = $start;
								}
								$enddate = $adb->query_result($result,0,'enddate');
								if(empty($enddate)){
									$autostdfilter['enddate'] = $autostds[1];
								}else{
									$autostdfilter['enddate'] = $enddate;
								}
							}
						}else{
							$autostdfilter['startdate'] = $adb->query_result($result,0,'startdate');
							$autostdfilter['enddate'] = $adb->query_result($result,0,'enddate');
						}
					}
					$smarty->assign('AUTOSTDFILTER',$autostdfilter);
					$smarty->assign("STARTDATE",$autostdfilter["startdate"]);
					$smarty->assign("ENDDATE",$autostdfilter["enddate"]);
					//2、获取高级查询条件
					$query = 'select columnname,columnindex,comparator,value,groupid,column_condition 
								from ld_autoadvfilter where autotaskid = ?;';
					$result = $adb->pquery($query,array($record));
					$rows = $adb->num_rows($result);
					$autoadvfilter = array();
					if($rows > 0){
						for($i=0;$i<$rows;++ $i){//以分组id为主键循环放入数组中
						    $groupid = $adb->query_result($result,$i,'groupid');
							$columnindex = $adb->query_result($result,$i,'columnindex');
							$idnex = 0;//当前分组的条件index值(确保从0开始自增)
							if(isset($autoadvfilter[$groupid])){
								$idnex = count($autoadvfilter[$groupid]);
							}
							$autoadvfilter[$groupid][$idnex]['columnname'] = $adb->query_result($result,$i,'columnname');
							$autoadvfilter[$groupid][$idnex]['comparator'] = $adb->query_result($result,$i,'comparator');
							$autoadvfilter[$groupid][$idnex]['value'] = $adb->query_result($result,$i,'value');
							$autoadvfilter[$groupid][$idnex]['column_condition'] = $adb->query_result($result,$i,'column_condition');
						}
					}
					if(!empty($autoadvfilter)){//高级条件，格式化为json格式
						require_once('./include/Zend/Json.php');
						$json = new Zend_Json();
						$jsonentity = $json->encode($autoadvfilter);
						$smarty->assign('AUTOADVFILTER',$jsonentity);
						$smarty->assign('AUTOADVFILTERCOUNT',count($autoadvfilter));
					}
					//3、获取定制任务信息
					$query = 'select columnname,value from ld_autotaskfilter where autotaskid = ?;';
					$result = $adb->pquery($query,array($record));
					$rows = $adb->num_rows($result);
					$autotackfilter = array();
					if($rows > 0){
						for($i=0;$i<$rows;++ $i){//将获取的定制任务放入数组中
							$autotackfilter[$i]['fld'] = $adb->query_result($result,$i,'columnname');
							$autotackfilter[$i]['val'] = $adb->query_result($result,$i,'value');
						}
					}
					if(!empty($autotackfilter)){//定制任务数组转换成json格式
						if(!isset($json)){//没走上面高级条件的代码块，则重新初始化一次
							require_once('./include/Zend/Json.php');
							$json = new Zend_Json();
						}
						$jsonentity = $json->encode($autotackfilter);
						$smarty->assign('AUTOTACKFILTER',$jsonentity);
					}
				}
			}
			$smarty->assign('RECORD',$record);//自动任务ID，表名当前为编辑状态
		}
          
		global $theme;
		$theme_path="themes/".$theme."/";
		$image_path=$theme_path."images/";
		$smarty->assign("IMAGE_PATH", $image_path);
		$smarty->assign('SETYPE',$setype);
		require_once('SetmenuControl.php');
        $smarty->display("Settings/AutomaticTask.tpl");
        break;
	case 'save'://保存
		$record = (isset($_REQUEST['record']))?$_REQUEST['record']:0;
		$autotask = array();
		$autotask['tabid'] = $_REQUEST['fld_tabid'];
		$autotask['autotaskname'] = Input('autotaskname');
		$autotask['autotaskmode'] = $_REQUEST['autotaskmode'];//执行方式（手动、自动）
		$autotaskdate = $_REQUEST['eachbackopts'];//执行频率(日)
		if($autotaskdate == 'week'){
			$autotaskdate .= ':'.$_REQUEST['weekopts'];
		}else if($autotaskdate == 'month'){
			$autotaskdate .= ':'.$_REQUEST['eachday'];
		}
		$autotask['autotaskdate'] = $autotaskdate;//执行频率
		$autotask['autotasktype'] = $_REQUEST['autotasktype'];//执行类型
		
		if(1 == $autotask['autotasktype']){//SQL脚本
			//$_POST['sqlfilter'] = htmlspecialchars($_POST['sqlfilter']);
			//$_POST['sqlfilter'] = strip_tags($_POST['sqlfilter']);
			$sqlfilter = $_POST['sqlfilter'];
			$issql = checkQuery($sqlfilter);
			if(1 != $issql){
				echo '<script type="text/javascript">alert("'.getFixedLabel('LBL_AUTOTASK_CHECKQUERY').'");history.go(-1);</script>';exit();
			}
			if($record > 0){//编辑
				insertTable('ld_autotask','autotaskid',$autotask,$record);
				deleteAutoTask($record);//删除自动任务关联信息
			}else{//新增
				$record = $adb->getUniqueID('ld_autotask');
				$autotask['autotaskid'] = $record;
				insertTable('ld_autotask','autotaskid',$autotask);
			}
			//不管是编辑还是新增，都是插入query关联表中
			$autotask = array();
			$autotask['autotaskid'] = $record;
			$sqlfilter = strtr($sqlfilter,array('"'=>"'"));
			$autotask['query'] = $sqlfilter;
			insertTable('ld_autotaskquery','autotaskid',$autotask);
		}else{//定制任务
			//基本查询条件处理
			$autostdfilter = array();//基本查询信息数组
			if(isset($_REQUEST['stdDateFilter'])){
				if('custom' != $_REQUEST['stdDateFilter']){
					$autostdfilter['columnname'] = $_REQUEST['stdDateFilterField'];
					$autostdfilter['stdfilter'] = $_REQUEST['stdDateFilter'];
				}else if(!empty($_REQUEST['startdate']) && !empty($_REQUEST['enddate'])){
					$autostdfilter['columnname'] = $_REQUEST['stdDateFilterField'];
					$autostdfilter['stdfilter'] = $_REQUEST['stdDateFilter'];
					$autostdfilter['startdate'] = $_REQUEST['startdate'];
					$autostdfilter['enddate'] = $_REQUEST['enddate'];
				}
			}
			//高级查询条件处理
			$autoadvfilter = array();
			$maxindex = $_REQUEST['maxindex'];//高级条件最大index值
			$columnindex_i = 0;$groupid = 1;$filtergroup = '';
			$groupcond = trim($_REQUEST['groupcond'],',');//获取分组信息
			$groupcondarr = explode(',',$groupcond);
			$grouparr = array();
			foreach($groupcondarr as $groupcondstr){//处理分组信息
				$groupcondobj = explode('=',$groupcondstr);
				$grouparr[$groupcondobj[0]] = $groupcondobj[1];//index=>groupid
			}
			for($i=0;$i<=$maxindex;++ $i){//循环高级条件
				if(!isset($_REQUEST['fcol'.$i]) || empty($_REQUEST['fcol'.$i])) continue;
				$groupid = $grouparr[$i];//获取当前分组
				if(isset($_REQUEST['gpcon'.$groupid])){//获取分组的and、or
					$filtergroup[$groupid] = $_REQUEST['gpcon'.$groupid];
				}
				$autoadvfilter[$i]['columnindex'] = $columnindex_i ++;
				$autoadvfilter[$i]['columnname'] = $_REQUEST['fcol'.$i];//条件字段
				$autoadvfilter[$i]['comparator'] = $_REQUEST['fop'.$i];//条件与值的关联（大于、小于、包含等）
				$fval = Input('fval'.$i);
				if(isset($_REQUEST['fval_ext'.$i]) && !empty($_REQUEST['fval_ext'.$i])){
					$fval .= ','.Input('fval_ext'.$i);//时间区间情况
				}
				$autoadvfilter[$i]['value'] = $fval;//值
				$autoadvfilter[$i]['groupid'] = $groupid;//分组
				$autoadvfilter[$i]['column_condition'] = $_REQUEST['fcon'.$i];//条件的and、or
			}
			//定制任务条件处理
			$autotackfilter = array();$fori = 0;
			$updatefield = $_REQUEST['updatefield'];
			$updatetext = $_REQUEST['update_text'];
			foreach($updatefield as $key=>$u_fld){//循环定制任务
				if(!isset($updatetext[$key]) || empty($updatetext[$key])) continue;
				$autotackfilter[$fori]['columnindex'] = $fori;
				$autotackfilter[$fori]['columnname'] = $u_fld;//字段
				$autotackfilter[$fori]['value'] = $updatetext[$key];//要更新的值
				++ $fori;
			}
			//插入数据库
			if(!empty($filtergroup)){//高级条件分组的and、or条件，保存在主表中
				$autotask['filtergroup'] = join(',',$filtergroup);
			}
			if($record > 0){//编辑
				deleteAutoTask($record);//删除自动任务所有关联表信息
				insertTable('ld_autotask','autotaskid',$autotask,$record);
			}else{//新增
				$record = $adb->getUniqueID('ld_autotask');
				$autotask['autotaskid'] = $record;
				insertTable('ld_autotask','autotaskid',$autotask);
			}
			if(!empty($autostdfilter)){//基本查询（时间）
				$autostdfilter['autotaskid'] = $record;
				insertTable('ld_autostdfilter','autotaskid',$autostdfilter);//插入基本查询
			}
			if(!empty($autoadvfilter)){//高级查询
				foreach($autoadvfilter as $autotack){
					$autotack['autotaskid'] = $record;
					insertTable('ld_autoadvfilter','autotaskid',$autotack);//插入高级查询
				}
			}
			foreach($autotackfilter as $autotack){//定制任务
				$autotack['autotaskid'] = $record;
				insertTable('ld_autotaskfilter','autotaskid',$autotack);//插入定时任务
			}
		}
		//跳回列表
		header("Location: index.php?action=".$_REQUEST['action']."&module=".$_REQUEST['module']."&fld_tabid=".$_REQUEST['fld_tabid']."&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']."");
	    break;
	case 'start'://开启、关闭
	    $record = $_REQUEST['record'];
		$presence = $_REQUEST['presence'];
		$update = 'presence = ?';
		if(1 == $presence){//关闭自动任务时，将执行状态修改为未执行
			$update .= ',execution=0';
		}
		$query = 'update ld_autotask set '.$update.' where autotaskid = ?;';
		$adb->pquery($query,array($presence,$record));
		echo '###SUCCESS###';die;
	    break;
	case 'delete'://删除
		$record = $_REQUEST['record'];
		$query = 'select execution from ld_autotask where autotaskid = ?; ';
		$result = $adb->pquery($query,array($record));
		$execution = $adb->query_result($result,0,'execution');
		if(1 == $execution){
			echo '###EXECUTION###';die;//正在执行，请稍后
		}else{
			$query = 'delete from ld_autotask where autotaskid = ?; ';
			$adb->pquery($query,array($record));//删除该自动任务
			deleteAutoTask($record);//删除自动任务关联表信息
			echo '###SUCCESS###';die;
		}
		break;
	case 'execution'://执行判断
	    $record = $_REQUEST['record'];
		$fld_tabid = $_REQUEST['fld_tabid'];
		$query = 'select execution,presence from ld_autotask where autotaskid = ?; ';
      
		$result = $adb->pquery($query,array($record));
		$execution = $adb->query_result($result,0,'execution');
		$presence = $adb->query_result($result,0,'presence');
		if(1 == $presence){//自动任务关闭，不能执行
			echo '###PRESENCE###';die;
		}else if(1 == $execution){//正在执行中，请稍后
			echo '###EXECUTION###';die;//正在执行，请稍后
		}else{//执行自动任务
			ExecutionAutoTask($record,$fld_tabid);
			echo '###SUCCESS###';die;
		}
	    break;
	case 'checksql':
	    $sqlfilter = trim($_REQUEST['sqlfilter']);
		$issql = checkQuery($sqlfilter);
		echo $issql;exit();
	    break;
}

function getStdFilterHTML($module,$selected="")
{
    global $app_list_strings, $current_language,$app_strings,$current_user,$currentModule;
	global $oCustomView;
	$stdfilter = array();
	$is_admin=is_admin($current_user);
    for($i = 0; $i<count($module); $i++)
    {
        $result = $oCustomView->getStdCriteriaByModule($module[$i]);
        if(isset($result))
    	{
    		foreach($result as $key=>$value)
    		{
    			if($value == 'Start Date & Time')
    			{
    				$value = 'Start Date';
    			}
                if($module[$i] == 'ServiceCharge')
                    $use_module_label=getTranstab('Accounts');
                else
                    $use_module_label=getTranstab($module[$i]);
				if($key == $selected)
				{
					$filter['value'] = $key;
					
					$filter['text'] = $use_module_label." - ".$value;
					$filter['selected'] = 'selected';
				}else
				{
					$filter['value'] = $key;
					$filter['text'] = $use_module_label." - ".$value;
					$filter['selected'] ='';
				}
    			
    			$stdfilter[]=$filter;
    			//added to fix ticket #5117. If a user doesn't have permission for a field and it has been used to fileter a custom view, it should be get displayed to him as Not Accessible.
    			if(!$is_admin && $selected != '' && $filter['selected'] == '')
    			{
    				$keys = explode(":",$selected);
    				if(getFieldVisibilityPermission($module[$i],$current_user->id,$keys[2]) != '0')
    				{
    					$filter['value'] = "not_accessible";
    					$filter['text'] = getFixedLabel('NOTACCESS');
    					$filter['selected'] = "selected";
    					$stdfilter[]=$filter;
    				}
    			}
    
    		}
    
    	}
    }
    return $stdfilter;
}
function getAdvCriteriaHTML($selected="")
{
	 global $adv_filter_options;

	 foreach($adv_filter_options as $key=>$value)
	 {
        
		if($selected == $key)
		{
			$shtml .= "<option selected value=\"".$key."\">".$value."</option>";
		}else
		{
			$shtml .= "<option value=\"".$key."\">".$value."</option>";
		}
	 }
	
    return $shtml;
}
function getByModule_ColumnsHTML($module,$columnslist,$selected="") {
    global $mod_strings;
	$columnsList = getByModule_ColumnsList($module,$columnslist,$selected);
 
    /**
    * edit:chj
    * date:2014-1-12
    * reason: 模块，产品明细 查询条件显示产品明细内容
    **/
    if(get_file_address($module,'ProductDetails'))
    {
        crm_load_class_file('CustomView_Special','modules/CustomView');
        $columnsList[getTranstab('Products').getFixedLabel('INFORMATION')] = CustomView_Special::getProductSearchCustom($module,getCvadfilter($_REQUEST['record']));   
    }
    
    if(get_file_address($module,'ProductDetails') && $module == 'ServiceCharge')
    {
        crm_load_class_file('CustomView_Special','modules/CustomView');
        $columnsList[getTranstab('ServiceContracts').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('ServiceContracts',getCvadfilter($_REQUEST['record']));   
    }
	/**
    * edit:chj
    * date:2014-12-31
    * reason: 客户模块  高级查询里显示联系人信息，去除首要联系人信息
    **/
	if(get_file_address($module,'ContactsDetails'))
	{
	   crm_load_class_file('CustomView_Special','modules/CustomView');
		$columnsList[getTranstab('Contacts').getFixedLabel('INFORMATION')] =CustomView_Special:: getModuleSearchCustom('Contacts',getCvadfilter($_REQUEST['record'])); 
	}
	/**
    * edit:chj
    * date:2014-12-31
    * reason: 供应商模块  高级查询里显示供应商联系人信息
    **/
	if(get_file_address($module,'VendorsDetails'))
	{
	   crm_load_class_file('CustomView_Special','modules/CustomView');
		$columnsList[getTranstab('VendorContact').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('VendorContact',getCvadfilter($_REQUEST['record'])); 
	}
	return generateSelectColumnsHTML($columnsList,$module);
}
function generateSelectColumnsHTML($columnsList, $module) {
	$shtml = '';
	if(!empty($columnsList)){
		foreach($columnsList as $blocklabel=>$blockcolumns) {
			$shtml .= "<optgroup label='".$blocklabel."' class='select' style='border:none'>";
			foreach($blockcolumns as $columninfo) {
				$shtml .= "<option ".$columninfo['selected']." value='".$columninfo['value']."'>".$columninfo['text']."</option>";
			}
		}
	}
  	return $shtml;
}
function getByModule_ColumnsList($module,$columnslist,$selected="") {
	global $oCustomView, $current_language,$theme;
	global $app_list_strings;
    global $adb;
	$advfilter = array();
	//$mod_strings = return_specified_module_language($current_language,$module);

    /*
    edit by LD Can
    date:2013026
    reasion:3268: 页面布局修改字段名称之后，导致已创建的视图中“选择字段”显示异常
    
    */
	$check_dup = Array();
	if(isset($oCustomView->module_list[$module]) && !empty($oCustomView->module_list[$module])){
		foreach($oCustomView->module_list[$module] as $key=>$value)
		{
			$advfilter = array();			
			$label = $key;
			if(isset($columnslist[$module][$key]))
			{
				foreach($columnslist[$module][$key] as $field=>$fieldlabel)
				{
					if(!in_array($fieldlabel,$check_dup))
					{
						if(isset($mod_strings[$fieldlabel]))
						{
						   $arrselected=explode(":",$selected);
						  $arrfield=explode(":",$field);
						   
						//if($selected == $field)
					   if($arrselected[0]==$arrfield[0] && $arrfield[1]==$arrselected[1])
					   {
								$advfilter_option['value'] = $field;
								$advfilter_option['text'] = $fieldlabel;
								$advfilter_option['selected'] = "selected";
							}else
							{
								$advfilter_option['value'] = $field;
								$advfilter_option['text'] = $fieldlabel;
								$advfilter_option['selected'] = "";
							}
						}else
						{
						   $arrselected=explode(":",$selected);
						  $arrfield=explode(":",$field);
						   
							//if($selected == $field)
						if($arrselected[0]==$arrfield[0] && $arrfield[1]==$arrselected[1])
							{
								$advfilter_option['value'] = $field;
								$advfilter_option['text'] = $fieldlabel;
								$advfilter_option['selected'] = "selected";
							}else
							{
								$advfilter_option['value'] = $field;
								$advfilter_option['text'] = $fieldlabel;
								$advfilter_option['selected'] = "";
							}
						}
						$advfilter[] = $advfilter_option;
						$check_dup [] = $fieldlabel;
					}
				}
				$advfilter_out[$label]= $advfilter;
			}
		}
	}
	
	return $advfilter_out;
}
function getCvadfilter($cvid)
{
    global $adb;
    $sql = "select columnname from ld_cvadvfilter where cvid = ?";
    $result = $adb->pquery($sql,array($cvid));
    for ($i=0;$i<$adb->num_rows($result);$i++) {
        $array[$i] = $adb->query_result($result, $i, "columnname");
    }
    return $array;
}
/**
 * query处理方法
 * @author Tujt 2015-01-13
 */
function insertTable($table,$tabindex,$fieldarr,$record=0) {
	global $adb;
    if($record > 0){//编辑
		$updatesql = '';
		foreach($fieldarr as $fld=>$val){
			$updatesql .= $fld.'="'.$val.'",';
		}
		$updatesql = trim($updatesql,',');
		$query = 'update '.$table.' set '.$updatesql.' where '.$tabindex.' = '.$record.' ';
		$adb->pquery($query,array());
	}else{//新增
		$fieldkey = array_keys($fieldarr);
		$fieldsql = join(',',$fieldkey);
		$valuesql = '"'.join('","',$fieldarr).'"';
		$query = 'insert into '.$table.'('.$fieldsql.') values('.$valuesql.'); ';
		$adb->pquery($query,array());
	}
}
/**
 * 删除自动任务关联表信息
 * @author Tujt 2015-01-13
 */
function deleteAutoTask($record) {
	global $adb;
    //sql模式，删除基本条件、高级条件、定制任务关联
	$query = 'delete from ld_autostdfilter where autotaskid = ? ';
	$adb->pquery($query,array($record));
	$query = 'delete from ld_autoadvfilter where autotaskid = ? ';
	$adb->pquery($query,array($record));
	$query = 'delete from ld_autotaskfilter where autotaskid = ? ';
	$adb->pquery($query,array($record));
	$query = 'delete from ld_autotaskquery where autotaskid = ? ';
	$adb->pquery($query,array($record));
}
/**
 * 执行自动任务
 * @author Tujt 2015-01-14
 */
function ExecutionAutoTask($record,$fld_tabid) {
	global $current_user;
	$url = 'modules.Home.autotaskSend';
	$data = 'fld_tabid='.$fld_tabid.'&record='.$record.'&userid='.$current_user->id;
	$rest = f_sockopen($url,$data);
  
	if(-1 == $rest){
		$_REQUEST['fld_tabid'] = $fld_tabid;
		$_REQUEST['record'] = $record;
		$_REQUEST['userid'] = $current_user->id;
		include './modules/Home/autotaskSend.php';
	}
}

/**
 * 获取模块对应的编辑可见字段
 * @param String $fld_module 模块名
 * @return 返回模块对应字段
 * @author Tujt 2015-01-15
 */
function getAutoTaskModuleField($fld_module) {
	global $adb,$current_user;
	$languageType= getLanguageType($current_user);
	$tabid = getTabid($fld_module);
	//block 区域信息缓存
	$cachekey = 'cache_moduleblock_module_autotask_'.$languageType.'_'.$tabid;
	$cachemoduleblock = Cache($cachekey);
	if(!$cachemoduleblock){
		$cachemoduleblock = array();
		$qeury = 'select blockid,case when IFNULL(ld_tranlabel.fieldlabel,"")="" then blocklabel 
					else ld_tranlabel.fieldlabel end as blocklabel,show_title,
					display_status,ld_blocks.blocklabel as label 
				  from ld_blocks 
					inner join ld_tranlabel on 
						ld_blocks.blockid = ld_tranlabel.relateid 
				where ld_blocks.tabid=? and edit_view = 0 and visible = 0  and ld_tranlabel.tabid=?
					and ld_tranlabel.languagetype="'.$languageType.'" and trantable="ld_blocks" 
					order by sequence;';
		$result = $adb->pquery($qeury,array($tabid,$tabid));
		$rows = $adb->num_rows($result);
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
			    $modblockid = $adb->query_result($result,$i,'blockid');
				$label = $adb->query_result($result,$i,'blocklabel');
				$cachemoduleblock[$modblockid] = $label;
			}
			Cache($cachekey,$cachemoduleblock);
		}
	}
	$blockarr = array_keys($cachemoduleblock);
	//96=>联系人、81=>供应商、76=>销售机会、75=>供应商、73=>客户、57=>联系人
	$uitypearr = '1,11,1101,1102,1103,13,15,17,19,20,21,23,230,400,5,7,71';
    $query = 'SELECT ld_field.block,ld_field.columnname,ld_field.tablename,
				ld_field.uitype,ld_field.fieldname,CASE WHEN IFNULL(ld_tranlabel.fieldlabel,\'\')=\'\' THEN ld_field.fieldlabel ELSE ld_tranlabel.fieldlabel END AS fieldlabel 
			 FROM ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid 
			 WHERE ld_field.tabid=? and ld_tranlabel.tabid=? AND ld_field.block IN ('.join(',',$blockarr).') 
			 AND ld_field.displaytype IN (1,4) and ld_field.presence in (0,2) and ld_field.uitype in ('.$uitypearr.') 
			 and ld_tranlabel.languagetype="'.$languageType.'" and ld_tranlabel.trantable="ld_field" 
			 ORDER BY block,sequence,fieldid asc ';
	$result = $adb->pquery($query,array($tabid,$tabid));
	$rows = $adb->num_rows($result);
	$autotaskfield = array();
	if($rows > 0){
		for($i=0;$i<$rows;++ $i){
			$tablename = $adb->query_result($result,$i,'tablename');
			$columnname = $adb->query_result($result,$i,'columnname');
			$fieldname = $adb->query_result($result,$i,'fieldname');
			$uitype = $adb->query_result($result,$i,'uitype');
			$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
			$block = $adb->query_result($result,$i,'block');
			$autotaskfield[$block][$tablename.':'.$columnname.':'.$fieldname.':'.$uitype] = $fieldlabel;
		}
	}
	if(!empty($autotaskfield)){
		$option = '';
		foreach($autotaskfield as $blockid=>$fieldarr){
			$option .= '<optgroup class="select" style="border:none" label="'.$cachemoduleblock[$blockid].'">';
			foreach($fieldarr as $fld=>$label){
				$option .= '<option value="'.$fld.'">'.$label.'</option>';
			}
		}
		return $option;
	}
	return '';
}

/**
 * 判断query格式
 * @author Tujt 2015-01-16
 */
function checkQuery($sqlfilter) {
    $sqlfilter = strtolower($sqlfilter);
	$issql = 1;//允许提交
	if(stripos($sqlfilter,'drop ') > -1){
		$issql = -1;//判断drop database删除数据库格式
		$sqlarray = explode('drop ',$sqlfilter);
		if(!empty($sqlarray[1])){
			$sqlarray[1] = trim($sqlarray[1]);
			$sqlstrarr = explode(' ',$sqlarray[1]);
			if('procedure' == $sqlstrarr[0]){//判断 drop procedure格式
				$issql = 1;//允许删除存储过程
			}
		}
	}elseif(stripos($sqlfilter,'truncate ') > -1){
		$issql = -1;//判断truncate table删除表格式
	}elseif(stripos($sqlfilter,'delete ') > -1){
		$sqlarray = explode('delete ',$sqlfilter);
		if(!empty($sqlarray[1])){//判断delete from格式
			$sqlarray[1] = trim($sqlarray[1]);
			$sqlstrarr = explode(' ',$sqlarray[1]);
			if('from' == $sqlstrarr[0]){
				$issql = -1;
			}
		}
	}
	return $issql;
}
?>