<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */

//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$setype = (isset($_REQUEST['setype']))?$_REQUEST['setype']:'list';
$smarty->assign('SETYPE',$setype);

if($_REQUEST['type'] == 'saveWorkReportModuleSort') {
    $type = $_REQUEST['type'];
//保存工作汇报模块 weiyannan 20231120 BUG0075320
    if ($type == 'saveWorkReportModuleSort') {
        if (!empty($_REQUEST['tagids'])) {
            $tagids_arr = explode(',', $_REQUEST['tagids']);
            $sequence = 1;
            foreach ($tagids_arr as $id) {
//                $adb->pquery('update ld_workreport_field set sequence = ? where id = ?', array($sequence, $id));
                //BUG20240227-24 ls 240227 工作汇报（列表），字段排序不是工作汇报设置的顺序(不处理也可以)
                $adb->pquery('update ld_workreport_field left join ld_field on ld_workreport_field.name = ld_field.columnname  set ld_workreport_field.sequence = ?,ld_field.sequence = ? where id = ? and ld_field.tabid=?', array($sequence,$sequence, $id, getTabid("WorkReportList")));
                $sequence++;
            }
            unsetWorkFieldEntity();
            ConvertTojsonString(1,array(),"success");
        }
    }
}

switch($setype){

    case 'list'://列表
        $filter_arr = array('day'=>'ld_workreport_field.type = 1 ',
            'week'=>'ld_workreport_field.type = 2 ',
            'month'=>'ld_workreport_field.type = 3 ',
            'weibo'=>'ld_workreport_field.type = 4 ',
            'cocmd'=>'ld_workreport_field.type = 5 ');
        crm_load_class_file('cls_workreportshow',"modules/CooperativeWork");
        $workreportshowobj = new cls_workreportshow();
        $selectoption_arr = $workreportshowobj->getSelectOption();
		//预留出未来可能的微博、任务等大类
        foreach ($selectoption_arr as $key => $label){
            $tag_arr[$key]['label'] = $label;
            $tag_arr[$key]['filter'] = $filter_arr[$key];
        }
		$typearray = array(
			'workreport'=>array(
				'label'=>'发日志',
				'tag'=>$tag_arr
			)
		);
		//默认一级标签默认值：发日志
		$entitytype = 'workreport';
		//默认下属标签，默认值：日志
        if (array_key_exists('day',$selectoption_arr)){
            $type = 'day';
        }else{
            $type =array_keys($selectoption_arr)[0];
        }
		if(isset($_REQUEST['type'])){
			$type = $_REQUEST['type'];
		}
		//条件
		$where = ' and ld_workreport_field.entitytype = "'.$entitytype.'" ';
		$where .= ' and '.$typearray[$entitytype]['tag'][$type]['filter'];

		$defheightarr = array('20','25','50','100');
		$defheightopts = '';
		foreach($defheightarr as $def_key=>$def_val){
			$defheightopts .= '<option value="'.$def_val.'">'.$def_val.'px</option>';
		}
		
		$header = array(
					'label'=>getFixedLabel('LBL_FIELDNAME'),
					'is_activate'=>getFixedLabel('WHETHERTOENABLE'),
					'is_mandatory'=>getFixedLabel('LBL_MANDATORYFIELDS'),
					'defaultheight'=>getFixedLabel('LBL_DEFAULTHEIGHT'),
					'defaultvalue'=>getFixedLabel('LBL_DEFAULTVALUE'),
					'tools'=>getFixedLabel('OPERATING'),
				  );
		$headkey = array_keys($header);
        if ($type == 'weibo' || $type == 'cocmd'){
            unset($header['label']);
        }
		array_pop($headkey);
		$fieldsql = 'ld_workreport_field.'.join(',ld_workreport_field.',$headkey);
		$query = 'select '.$fieldsql.',ld_workreport_field.id,ld_workreport_field.name,
					ld_workreport_field.tablename from ld_workreport_field ';
		$query .= 'where ld_workreport_field.deleted = 0 '.$where;
		$query .= 'and ld_workreport_field.id > 0 and ld_workreport_field.allow_edit=\'yes\' ';
		$query .= 'ORDER BY ld_workreport_field.sequence ';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		$entitylist = '';
		if($rows > 0){
			$mandatoryarr = array(getFixedLabel('YES'),getFixedLabel('NO'));
			$activatearr = array(getFixedLabel('YES'),getFixedLabel('NO'));
			$activatecolor = array('#69BA69','#FCB368');//启用、禁用显示不同的颜色
			//编辑
			$editLink = '<a class="Anu3_a" onclick="WorkTemplate.editworktpl_click(this);return false;" href="javascript:void(0);">'.getFixedLabel('EDIT').'</a>';
			//删除
			$delLink = '<a class="Anu3_a redFont" onclick="WorkTemplate.delworktpl_click(this);return false;" href="javascript:void(0);">'.getFixedLabel('DELETE').'</a>';
			//上移
			//$upLink = '<a class="Anu3_a" onclick="WorkTemplate.moveworktpl_click(this,\'up\');return false;" href="javascript:void(0);">'.getFixedLabel('MOVEUP').'</a>';
			//下移
			//$downLink = '<a class="Anu3_a" onclick="WorkTemplate.moveworktpl_click(this,\'down\');return false;" href="javascript:void(0);">'.getFixedLabel('MOVEDOWN').'</a>';
            //拖拽排序 添加拖拽按钮 weiyannan 20231120 BUG0075320
            $dragLink = '<a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="'.getFixedLabel('DRAGTOSORT').'"  data-direction="left" data-type="position" style="display:none;cursor:move;margin-top:0px"></a>';

            for($i=0;$i<$rows;++ $i){
				$id = $adb->query_result($result,$i,'id');
				$name = $adb->query_result($result,$i,'name');
				$tablename = $adb->query_result($result,$i,'tablename');
			    $label = $adb->query_result($result,$i,'label');
				$is_mandatory = $adb->query_result($result,$i,'is_mandatory');
				$defaultheight = $adb->query_result($result,$i,'defaultheight');
				$defaultvalue = $adb->query_result($result,$i,'defaultvalue');
				$is_activate = $adb->query_result($result,$i,'is_activate');				
                if ($i%2 ==0) {
                    $entitylist.='<tr id="setting_'.$i.'" tagid="'.$id.'" class="lvtColData ld-category-draggable" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" record="'.$id.'" fldname="'.$name.'">';
                }
                else{
                    $entitylist.='<tr id="setting_'.$i.'" tagid="'.$id.'" class="lvtColDataBj ld-category-draggable" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" record="'.$id.'" fldname="'.$name.'">';
                }                
				$entitylist .= '<td width="15">'.($i+1).'</td>';
				if ($type != 'weibo' && $type != 'cocmd'){
                    $entitylist .= '<td fld="label" val="'.$label.'" width=""><span title="'.$label.'">'.$label.'</span></td>';
                }
				//duan 2022-2-16 关于是否启用按钮的显示优化
                $entitylist .= '<td fld="is_activate" val="'.$is_activate.'" width="70"><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'workreport_field_active\')" class="second_switch" ';
        		if($name == 'worksummary'){//本日、本周、本月工作总结不允许关闭
        		  $entitylist .= ' disabled ';
        		}
        		if (($type == 'weibo' || $type == 'cocmd') && $name == 'workexperience'){//微博、任务不允许关闭
		            $entitylist .= ' disabled ';
		        }
                if($is_activate != ''&&$is_activate==0){
                    $entitylist .= 'checked /></td>';
        		}else{
        			$entitylist .= ' /></td>';
        		}
                //duan 2022-2-16 关于是否启用按钮的显示优化
                $entitylist .= '<td fld="is_mandatory" val="'.$is_mandatory.'" width="70"><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'workreport_field_is_mandatory\')" class="second_switch" ';
                if (($type == 'weibo' || $type == 'cocmd') && $name == 'workexperience'){//微博、任务不允许关闭
		            $entitylist .= ' disabled ';
		        }
                if($is_mandatory != ''&&$is_mandatory==0){
                    $entitylist .= 'checked /></td>';
        		}else{
        			$entitylist .= ' /></td>';
        		}
                $entitylist .= '<td fld="defaultheight" val="'.$defaultheight.'" width="110"><span title="'.$defaultheight.'">'.$defaultheight.'px</span></td>';
				$def_value = strtr($defaultvalue,array('/r'=>'<br>'));
				$def_value = strtr($def_value,array('/n'=>'<br>'));
				$entitylist .= '<td fld="defaultvalue" val="'.$defaultvalue.'" width=""><span title="'.$def_value.'">'.$def_value.'</span></td>';
                $link = $editLink;
				$linkopertion[0] = 'edit';
                $link .= $dragLink;
                $linkopertion[1] = 'drag';
				if('ld_workreportcf' == strtolower($tablename)){ 
					$link .= $delLink;//不允许删除预置字段
					$linkopertion[3] = 'delete';
				}
				$entitylist .= '<td style="white-space: nowrap;">'.$link.'</td>';
				$entitylist .= '</tr>';
			}
		}
		$smarty->assign('TYPEARRAY',$typearray);
		$smarty->assign('ENTITYTYPE',$entitytype);
		$smarty->assign('opertion_num',count($linkopertion));
		$smarty->assign('TYPE',$type);
		$smarty->assign('HEADER',$header);
		$smarty->assign('ENTITYLIST',$entitylist);
		$smarty->assign('COUNT',$rows);
		$smarty->assign('DEFHEIGHTYARR',$defheightarr);
		$smarty->assign('DEFHEIGHTOPTS',$defheightopts);
        $smarty->assign('LANGUAGETYPE',$languageType);
		// require_once('SetmenuControl.php');
        //获取帮助手册入口链接，为空则不显示
        //可能有多个帮助链接需要获取
        $helpHtmlArr = array();
        //企业号设置帮助
        $labels = array('WorkTemplate');
        foreach($labels as $label){
            $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
        }
        $smarty->assign("HelpHtml", $helpHtmlArr);
		$_REQUEST['diony']='yes';
        if($_REQUEST['ajax'] == 'true'){
			$smarty->display("Settings/WorkTemplateContents.tpl");
        }
		else{
			$arr['content']= $smarty->fetch('Settings/WorkTemplate.tpl');
    		ConvertTojsonString(1,$arr,"success");
		}
        break;
	case 'save'://保存
		$table = 'ld_workreport_field';$tabidx = 'id';
		$typearr = array('day'=>1,'week'=>2,'month'=>3,'weibo'=>4,'cocmd'=>5);
		$fieldarr = array();
		$fieldarr['label'] = $_REQUEST['label'];
		$fieldarr['entitytype'] = $_REQUEST['entitytype'];
		$fieldarr['type'] = $typearr[$_REQUEST['type']];
		$fieldarr['defaultvalue'] = $_REQUEST['defaultvalue'];
		$fieldarr['defaultheight'] = $_REQUEST['defaultheight'];
		$fieldarr['is_mandatory'] = ($_REQUEST['is_mandatory']=='true')?0:1;
		$fieldarr['is_activate'] = ($_REQUEST['is_activate']=='true')?0:1;
		$fieldarr['allow_edit'] = 'yes';
        if ($type != 'weibo' && $type != 'cocmd'){
            $fieldarr['relatedmodulefield']=$_REQUEST['relatedmodulefield'];
            $fieldarr['related_time']=$_REQUEST['related_time'];
            $fieldarr['related_fieldid']=$_REQUEST['related_fieldid'];
        }
		if(isset($_REQUEST['record']) && $_REQUEST['record'] > 0){//edit
			$record = $_REQUEST['record'];
			insertTable($table,$tabidx,$fieldarr,$record);
		}else{//create
			$record = $adb->getUniqueID($table);
			$fieldarr['id'] = $record;
			$fieldarr['name'] = 'workfld_'.$record;
			$fieldarr['sequence'] = $record;
			$fieldarr['tablename'] = 'ld_workreportcf';
			insertTable($table,$tabidx,$fieldarr);
			$query = 'ALTER TABLE ld_workreportcf ADD COLUMN '.$fieldarr['name'].' TEXT DEFAULT NULL;';
			$adb->pquery($query,array());
		}
		unsetWorkFieldEntity();
		echo '';die;
	    break;
	case 'del'://删除
	    $record = $_REQUEST['record'];
		$query = 'update ld_workreport_field set deleted = 1 where id = ? ';
		$adb->pquery($query,array($record));//删除该自动任务
		unsetWorkFieldEntity();

		//删除的字段在ld_field表的fieldid
        $query = 'select ld_field.fieldid,ld_field.columnname from ld_field LEFT JOIN  ld_workreport_field ON ld_workreport_field.name = ld_field.columnname where ld_workreport_field.id = ? AND ld_field.tabid = ? and ld_field.tablename=?';
        $res = $adb->pquery($query,array($record,getTabid('WorkReportList'),'ld_workreportcf'));
        $fieldid = $adb->query_result($res,0,'fieldid');
        $columnname = $adb->query_result($res,0,'columnname');

        $query = 'update ld_field set presence = 1 where fieldid = ? ';
        $adb->pquery($query,array($fieldid));

        /*$query='delete from ld_field where fieldid = ? and ld_field.presence in (0,2)';
        $adb->pquery($query, array($fieldid));

        $adb->pquery("delete from ld_cvcolumnlist where columnname like ?", array("%ld_workreportcf:". $columnname ."%"));
        $adb->pquery("delete from ld_cvstdfilter where columnname like ?", array("%ld_workreportcf:". $columnname ."%"));

        $adb->pquery("delete from ld_tranlabel where trantable='ld_field' and  relateid=$fieldid");
        */
        unsetCacheDirectory('fields');
        unsetCacheDirectory('customview');
		echo '';die;
	    break;
	case 'sortable'://排序
	    $record = trim($_REQUEST['workid'],',');
		$recordarr = explode(',',$record);
		$update = 'update ld_workreport_field set sequence = ';
		$update .= '(CASE id';
		foreach($recordarr as $key=>$id){
			$update .= ' WHEN '.$id.' THEN '.($key+1).' ';
		}
		$update .= 'END) where id in ('.join(',',$recordarr).') ';
		$adb->pquery($update,array());
		unsetWorkFieldEntity();
		echo '';die;
	    break;
	case 'moveupdate'://上移
		$entitytype = $_REQUEST['entitytype'];
		$typearr = array('day'=>1,'week'=>2,'month'=>3);
		$type = $typearr[$_REQUEST['type']];
		$workid = $_REQUEST['workid'];
		$movetype = $_REQUEST['movetype'];
		//首先都从1开始重新排列一次
		$query = 'SET @seq = 0;';
		$adb->query($query);
		$query = 'UPDATE ld_workreport_field SET sequence = (@seq:=@seq+1) WHERE deleted = 0 and allow_edit=\'yes\' and entitytype = "'.$entitytype.'" AND TYPE = '.$type.' ORDER BY sequence;';
		$adb->query($query);

		$query = 'select sequence from ld_workreport_field where id = '.$workid.' limit 1;';
		$result = $adb->pquery($query,array());
		$sequence = $adb->query_result($result,0,'sequence');
		if('up' == $movetype){//上移
			$update = 'update ld_workreport_field set sequence = '.$sequence.' 
						where deleted = 0 and allow_edit=\'yes\' and  entitytype = "'.$entitytype.'" AND TYPE = '.$type.' 
							and sequence = '.($sequence-1).';';
			$adb->pquery($update,array());
			$update = 'update ld_workreport_field set sequence = '.($sequence-1).' where deleted = 0 and  id = '.$workid.' ';
			$adb->pquery($update,array());
		}else{//下移
			$update = 'update ld_workreport_field set sequence = '.$sequence.' 
						where entitytype = "'.$entitytype.'" and allow_edit=\'yes\' AND TYPE = '.$type.' 
							and sequence = '.($sequence+1).';';
			$adb->pquery($update,array());
			$update = 'update ld_workreport_field set sequence = '.($sequence+1).' where id = '.$workid.' ';
			$adb->pquery($update,array());
		}
		unsetWorkFieldEntity();
		echo '';die;
	    break;
    case 'getrelatedhtml':
        //选择引用时间
        $related_time_arr=array(
            'latest'=>getFixedLabel('LATESTTIME'),
            'yesterday'=>getFixedLabel('syesterday'),
            'thisweek'=>getFixedLabel('thisweek'),
            'thismonth'=>getFixedLabel('thismonth'),
            'lastweek'=>getFixedLabel('lastweek'),
            'lastmonth'=>getFixedLabel('lastmonth'),
        );
        $smarty->assign('related_time_arr',$related_time_arr);
        //选择引用对象
        $related_reporttype_arr = array(
            'day'=>array('label'=>getFixedLabel('LBL_DAILYRECORD'), 'type'=>1,),
            'week'=>array('label'=>getFixedLabel('LBL_WEEKLYSCHEMES'), 'type'=>2,),
            'month'=>array('label'=>getFixedLabel('LBL_MONTHLYSCHEMES'), 'type'=>3,)
        );
        $smarty->assign('related_reporttype_arr',$related_reporttype_arr);

        $mode=$_REQUEST['mode'];
        $smarty->assign('mode',$mode);
        if ($mode == 'edit'){
            $record=$_REQUEST['record'];
            $sql='select id,relatedmodulefield,related_time,related_fieldid from ld_workreport_field where id=?';
            $result=$adb->pquery($sql,array($record));
            $num_row=$adb->num_rows($result);
            if ($num_row>0){
                $relatedmodulefield=$adb->query_result($result,0,'relatedmodulefield');
                $related_time=$adb->query_result($result,0,'related_time');
                $related_field=$adb->query_result($result,0,'related_fieldid');
                $related_fieldid=explode(',',$related_field);
                $smarty->assign('relatedmodulefield',$relatedmodulefield);
                $smarty->assign('related_time',$related_time);
            }
            //引用字段对应type
            if (!empty($related_field)) {
                $typesql='select type from ld_workreport_field where id in ( '.$related_field.' ) limit 1';
                $typeresult=$adb->pquery($typesql,array());
                $num_row=$adb->num_rows($typeresult);
                if ($num_row>0){
                    $type=$adb->query_result($typeresult,0,'type');
                }
            }

            $smarty->assign('related_type',$type);
            $type=empty($type)?1:$type;
            //选择引用字段
            $related_fieldid_arr=getRelatedFieldidArr($type);
            $smarty->assign('related_fieldid_arr',$related_fieldid_arr);

        }else if ($mode == 'create'){
            //新建默认引用对象为日志，type=1
            //选择引用字段
            $related_fieldid_arr=getRelatedFieldidArr(1);
            $smarty->assign('related_fieldid_arr',$related_fieldid_arr);
            $relatedmodulefield='no';
            $smarty->assign('relatedmodulefield',$relatedmodulefield);
        }else if ($mode == 'getrelatedfield'){
            $type=$_REQUEST['type'];
            $related_fieldid_arr=getRelatedFieldidArr($type);
            $smarty->assign('related_fieldid_arr',$related_fieldid_arr);
        }


       
        $arr['mode']=$mode;
        $arr['content']= $smarty->fetch('Settings/WorkTemplate_relatedmodulefield.tpl');
        $arr['relatedmodulefield']=$relatedmodulefield;
        $arr['related_fieldid']=$related_fieldid;
        ConvertTojsonString(1,$arr,'success');
        break;
    case 'WorkTemplateRule'://工作汇报模版规则
        $option = $_REQUEST['option'];
        crm_load_class_file('WorkTemplateRule','modules/Settings');
        $workTemplateRuleobj = new WorkTemplateRule();
        $reporttype = $_REQUEST['reporttype'];
        if (!empty($reporttype)){
            $workTemplateRuleobj->setWorkReportType($reporttype);
        }
        switch ($option){
            case 'editview'://新建编辑界面
                $ruleid = $_REQUEST['ruleid'];
                $smarty->assign('reporttype',$reporttype);
                //获取规则数据 $ruleid为空获取新建默认
                $info = $workTemplateRuleobj->getWorkTemplateRuleInfo($ruleid);
                $smarty->assign('info',$info);
                //获取截止日期数组
                $deadline_date_arr = $workTemplateRuleobj->getDeadlineDateArr();
                $smarty->assign('deadline_date_arr',$deadline_date_arr);
                //分配
                $allocateinfo = $workTemplateRuleobj->getAllocateInfo($ruleid);
                $smarty->assign('allocateinfo',$allocateinfo);
//                $arr['allocateinfo'] = $allocateinfo;
                //提醒提前部分
                $remind_time_str = $reporttype == 'day'?'HoursAgo':'DAYSAGO';
                $smarty->assign('remind_time_str',$remind_time_str);
                $smarty->assign('time_arr',array(1,2,3));
                //字段
                $selectUserFieldArr = $workTemplateRuleobj->getSelectUserField();
                $smarty->assign('selectUserFieldArr',$selectUserFieldArr);

                //汇报日期
                if ($reporttype == 'day'){
                    $reportDate = array('all'=>getFixedLabel('UnlimitedTime'),'1_0'=>getFixedLabel('SameDay'),
                        '1_1'=>getVarFixedLabel('CurrentDayAndThePastSomeDay',1),'1_3'=>getVarFixedLabel('CurrentDayAndThePastSomeDay',3),
                        '1_7'=>getVarFixedLabel('CurrentDayAndThePastSomeDay',7));
                }else{
                    $reportDate = array('yes'=>getFixedLabel('AllowModification'),'no'=>getFixedLabel('NoModificationsAllowed'));
                }
                $smarty->assign('reportDate',$reportDate);

                //编辑时限
                if ($reporttype == 'day'){
                    $editDate = array('all'=>getFixedLabel('UnlimitedTime'),'1'=>getVarFixedLabel('CannotEditAfterSomeDay',1),
                        '3'=>getVarFixedLabel('CannotEditAfterSomeDay',3),'7'=>getVarFixedLabel('CannotEditAfterSomeDay',7),
                        'no'=>getFixedLabel('NotAllowedToEdit'));
                    $smarty->assign('editDate',$editDate);
                }

                $arr['title']=getFixedLabel('RULESETTINGS').'<label style="font-size: 12px;color: #999">('.getFixedLabel('OneMemberOneRule').')</label>';
                $arr['oktext']=getFixedLabel("SAVE");
                $arr['canceltext']=getFixedLabel("CANCEL");
                $arr['content'] = $smarty->fetch('Settings/WorkTemplateRuleEditView.tpl');

                ConvertTojsonString(1,$arr,'success');
                break;
            case 'save'://新建编辑保存
                $ruleid = $_REQUEST['ruleid'];
                $dataArr = $_REQUEST['data'];
                $workTemplateRuleobj->saveRule($ruleid,$dataArr);
                $info = $workTemplateRuleobj->getRuleListbyReportType();
                $smarty->assign('workTemplateRuleArr',$info);
                $smarty->assign('length',sizeof($info));
                $arr['length'] = sizeof($info);
                $arr['content'] = $smarty->fetch('Settings/WorkTemplateRuleListView.tpl');
                ConvertTojsonString(1,$arr,'success');
                break;
            case 'getRuleList'://获取规则列表
                $status = getUsersettingByLabel('WorkTemplateRule',1,$reporttype);
                $status = empty($status)?'yes':$status;
                $smarty->assign('status',$status);
                $smarty->assign('reporttype',$reporttype);
                $info = $workTemplateRuleobj->getRuleListbyReportType();
                $smarty->assign('workTemplateRuleArr',$info);
                $smarty->assign('length',sizeof($info));
                $arr['length'] = sizeof($info);
                $arr['title'] = getFixedLabel('RULESETTINGS');
                $arr['canceltext'] = getFixedLabel('CLOSE');
                $arr['content'] = $smarty->fetch('Settings/WorkTemplateRule.tpl');
                ConvertTojsonString(1,$arr,'success');
                break;
            case 'changeSettingStatus'://列表设置启用按钮
                $status = $_REQUEST['status'];
                setUsersettingByLabel('WorkTemplateRule',1,$reporttype,$status);
                ConvertTojsonString(1,'','success');
                break;
            case 'changeRuleStatus'://列表规则启用按钮
                $status = $_REQUEST['status'];
                $ruleid = $_REQUEST['ruleid'];
                $sql = 'update ld_workreport_rulesettings set status = ? where id = ?';
                $adb->pquery($sql,array($status,$ruleid));
                ConvertTojsonString(1,'','success');
                break;
            case 'deleteRule'://删除规则
                $ruleid = $_REQUEST['ruleid'];
                $sql = 'delete from ld_workreport_rulesettings where id = ?';
                $adb->pquery($sql,array($ruleid));
                $info = $workTemplateRuleobj->getRuleListbyReportType();
                $smarty->assign('workTemplateRuleArr',$info);
                $smarty->assign('length',sizeof($info));
                $arr['length'] = sizeof($info);
                $arr['content'] = $smarty->fetch('Settings/WorkTemplateRuleListView.tpl');
                ConvertTojsonString(1,$arr,'success');
                break;
            case 'changeSequence':
                $sort_str = $_REQUEST['sort_str'];
                $sort_arr = explode(',',$sort_str);
                $update_sql = 'update ld_workreport_rulesettings set sequence = ? where id = ?';
                foreach($sort_arr as $index => $ruleid){
                    $adb->pquery($update_sql,array(($index+1),$ruleid));
                }
                $info = $workTemplateRuleobj->getRuleListbyReportType();
                $smarty->assign('workTemplateRuleArr',$info);
                $smarty->assign('length',sizeof($info));
                $arr['length'] = sizeof($info);
                $arr['content'] = $smarty->fetch('Settings/WorkTemplateRuleListView.tpl');
                ConvertTojsonString(1,$arr,'success');
                break;
        }


        break;


}

/**
 * query处理方法
 * @author Tujt 2015-01-13
 */
function insertTable($table,$tabindex,$fieldarr,$record=0) {
	global $adb;
    //ls 20221012 XUQIU1000284  增加“工作汇报（列表）”模块(同时新增到ld_field表)
    $tabid = getTabid('WorkReportList');
    $fieldlabel = $fieldarr['label'];
    $presence = $fieldarr['is_activate'];
    $uichekdata = ($fieldarr['is_mandatory']=='1')?'V~O':'V~M';
    $defaultvalue = $fieldarr['defaultvalue'];
    $categorytype = (int)$fieldarr['type'];
    // ljj 20231117 XUQIU1002166 工作汇报模板定制增加“自动引用工作内容”（宋清华）
    $relatedmodulefield=$fieldarr['relatedmodulefield'];
    $related_time=$fieldarr['related_time'];
    $related_fieldid=$fieldarr['related_fieldid'];

    if($record > 0){//编辑
		$updatesql = '';
		foreach($fieldarr as $fld=>$val){
			$updatesql .= $fld.'="'.$val.'",';
		}
		$updatesql = trim($updatesql,',');
		$query = 'update '.$table.' set '.$updatesql.' where '.$tabindex.' = '.$record.' ';
		$adb->pquery($query,array());


        $query = "select ld_field.fieldid,ld_field.columnname from ld_field LEFT JOIN  ld_workreport_field ON CASE WHEN ld_workreport_field.name in('signaddress','worksummary','workplan','workexperience') THEN CONCAT(ld_workreport_field.name,CASE WHEN ld_workreport_field.type=2 THEN '_week' WHEN ld_workreport_field.type=3 THEN '_month' ELSE '' END) ELSE ld_workreport_field.name END = ld_field.columnname where ld_workreport_field.id = ? AND ld_field.tabid = ?";
        $res = $adb->pquery($query,array($record,$tabid));
        $fieldid = $adb->query_result($res,0,'fieldid');

        $sql="update ld_field set typeofdata=?,presence=?,fieldlabel=?,defaultvalue=? where fieldid=?";
        $adb->pquery($sql,array($uichekdata,$presence,$fieldlabel,$defaultvalue,$fieldid));

        $sql=' update ld_tranlabel set fieldlabel=? where trantable=? and tabid=? and relateid=?';
        $pqaram=array($fieldlabel,'ld_field',$tabid,$fieldid);
        $adb->pquery($sql, $pqaram);

    }else{//新增
		$fieldkey = array_keys($fieldarr);
		$fieldsql = join(',',$fieldkey);
		$valuesql = '"'.join('","',$fieldarr).'"';
		$query = 'insert into '.$table.'('.$fieldsql.') values('.$valuesql.'); ';
		$adb->pquery($query,array());

        $columnName = $fieldarr['name'];//编辑没有传该字段

        $max_fieldsequence = "select max(sequence) as maxsequence,block from ld_field where block = (select block from ld_field where columnname = 'workreport_no')";
        $res = $adb->pquery($max_fieldsequence,array());
        $max_seq = $adb->query_result($res,0,'maxsequence');
        $blockid = $adb->query_result($res,0,'block');

        $custfld_fieldid = getMaxFieldid();

        $query = "insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,savedatabase,allowedit,bigtype,datarang,maxrowsshow,categorytype) 
                                                values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        $qparams = array($tabid,$custfld_fieldid,$columnName,'ld_workreportcf',2,21,$columnName,$fieldlabel,0,$presence,$defaultvalue,$max_seq+1,$blockid,1,$uichekdata,0,0,1,2,'yes',$fieldarr['allow_edit'],'textarea',NULL,0,$categorytype);
        $adb->pquery($query, $qparams);


        //翻译
        $fldlabel_zh = $fldlabel_en = $fieldlabel;
        $sql = 'delete from ld_tranlabel where trantable=? and tabid=? and relateid=?';
        $adb->pquery($sql, array('ld_field', $tabid, $custfld_fieldid));
        $sqls = "insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel) values(?,?,?,?,?)";
        $qparam = array('zh', 'ld_field', $tabid, $custfld_fieldid, $fldlabel_zh);
        $qparamz = array('en', 'ld_field', $tabid, $custfld_fieldid, $fldlabel_en);
        $adb->pquery($sqls, $qparam);
        $adb->pquery($sqls, $qparamz);


	}

//    unsetCache("all_getRelatedFieldInfo");//清除redis
//    unsetCacheDirectory('relatedfield');//清除文件缓存
    unsetCacheDirectory("fields");
    unsetCacheDirectory('customview');
//    unsetCacheDirectory('Cache');
}
/**
 * 清空缓存
 * @author Tujt 2015-05-06
 */
function unsetWorkFieldEntity() {
	$cachekey = 'cache_getworkreportfieldentity';
	unsetCache($cachekey);
	unsetCache('cache_getworkreportsignentity');
}

//获取ld_field表fieldid的最大值  同时更新ld_field_seq
function getMaxFieldid(){
    global $adb;
    $query  = 'select max(fieldid) as fieldid from ld_field limit 1';
    $result = $adb->pquery($query,array());
    $fieldid = $adb->query_result($result,0,0);
    $fieldid=$fieldid+1;
    //字段删除有bug,所以此处获取两者的最大值
    $tmpfieldid=$adb->getUniqueID('ld_field');
    $maxfieldid=max($tmpfieldid,$fieldid);
    if($maxfieldid>$tmpfieldid){
        $adb->pquery('update ld_field_seq set id = ?',array($maxfieldid));
    }
    return $maxfieldid;
}
function getRelatedFieldidArr($type){
    global $adb;
    //选择引用字段
    $fieldidsql='select id,name,label,type from ld_workreport_field where deleted=0 and type=?';
    $fieldidresult=$adb->pquery($fieldidsql,array($type));
    $num_row=$adb->num_rows($fieldidresult);
    if ($num_row>0){
        $related_fieldid_arr=[];
        for ($i=0;$i<$num_row;$i++){
            $fieldname=$adb->query_result($fieldidresult,$i,'name');
            if ($fieldname == 'signaddress' || $fieldname=='saleskit_day' || $fieldname=='saleskit_week' || $fieldname=='saleskit_month'){//签到 工作简报 不能引用
                continue;
            }
            $fieldid=$adb->query_result($fieldidresult,$i,'id');
            $fieldlabel=$adb->query_result($fieldidresult,$i,'label');
            $fieldtype=$adb->query_result($fieldidresult,$i,'type');
            $related_fieldid_arr[$fieldid]=array(
                'name'=>$fieldname,
                'label'=>$fieldlabel,
                'type'=>$fieldtype
            );
        }
    }
    return $related_fieldid_arr;
}


?>