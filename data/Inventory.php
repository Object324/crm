<?php
/**
 * Inventory
 * 
 * @package vtigercrm
 * @author phpadmin
 * @copyright 2014
 * @version $Id$
 * @access public
 */
class Inventory
{

    /**
     * edit:can
     * reason:IE9浏览器错位
     * $LISTENTITY:查询结果集
     * $ROW_COUNT:总行数
     * $ROW_HEADER:总列数
     * */
    static function createModWithDetailhtml($LISTENTITY,$ROW_COUNT,$ROW_HEADER,$checkbox='yes',$related_list='',$controller='')
    {
        global $global_minversin;
        $currentModule = $controller->module;
        $i=0;
     
        $chkbox_listwidth=$controller->listchkbox_width;
        $headerlistfieldobj=$controller->listViewFields;//获取列头字段
        $old_checkvalueid=0;   
        $html='';
        if(sizeof($LISTENTITY)<=0)
        {
			//非空，代表是相关信息
			if(!empty($related_list)){
			 
				// $html .='<tr bgcolor="white" style="height: 25px;">
				// 		<td align="center" colspan="'.$ROW_HEADER.'">
				// 		<i style="display:inline-block;width:100%;text-align:center;">'.getFixedLabel('NONE').'</i>
				// 		</td>
				// 		</tr>';

                $tmp_height = $_REQUEST['fromtab'] == 'BalanceOfAccount'?'height:300px':'height:0px';//客户-往来对账
                $tmp_style = $_REQUEST['fromtab'] == 'BalanceOfAccount'?'top: calc(50% - 85px);':'';
                //BUG0069178 相关信息 空态优化
                $html .= '<tr> <td id="resize_content_tdid"  style="background-color:#FFF;padding: 0;'.$tmp_height.'" align="center" colspan="'.$ROW_HEADER.'">';
                $html .= '<div class="warningTableContent" style="z-index:600;padding-top:30px;'.$tmp_style.'">
                          <div class="wtc_img"><img src="themes/icon2023/ld-no-records.png?v='.$global_minversin.'"></div>
                          <div class="wtc_content">'.getFixedLabel('NODATAFOUND').'</div>
                          </div></td></tr>';
			}else{
                $html.='<tr style="height: 300px;"> <td id="resize_content_tdid"  style="background-color:#FFF;height:0px;padding: 0;" align="center" colspan="'.$ROW_HEADER.'">';
                
                $html.="<div class='warningTableContent' style='z-index:600;padding-top:30px;'>";
                $html.= "<div class='wtc_img'><img src='themes/icon2023/ld-no-records.png?v=".$global_minversin."'></div>";
                $html .= '<div class="wtc_content">'.getFixedLabel('NODATAFOUND').'</div>';
                // $html .= "<div class='wtc_content'>".getFixedLabel('YOUCANCLICKONTHE').getFixedLabel('CREATE').getFixedLabel('ADDARECORD')."</div>";
                $html .= "<div class='wtc_btn'>";

                $create_html = "<input value=".getFixedLabel('CREATE')." title=".getFixedLabel('CREATE')." class='ld-button ld-button-primary'";//新建
                $create_html .= "  onclick=\" var objparams=new CreatePagePopup.params(); CreatePagePopup.showpage('$currentModule','',objparams)\" type='button'/>";
                $import_html = "<input value=".getFixedLabel('IMPORT')." title=".getFixedLabel('IMPORT')." class='ld-button' onclick=\" listviewImport('','$currentModule')\" type='button'/>";//导入
                $refresh_html = "<input value='".getFixedLabel('TRYREFRESHING')."'class='ld-button' type='button' onclick='window.location.reload();'>";//刷新试试

                //edit: xll 20221212 BUG0059712 是否允许直接创建，若不允许，列表没有数据显示时，列表中间应该不显示“新建”操作按钮
                if(!in_array($currentModule,array('QuotesChange','BudgetChange','Approve')) && isPermitted($currentModule,'Create', '') == 'yes'){
                    $createbutton='yes';
                    if($currentModule=='Accounts')
                    {
                        $publicaccountobj=new cls_PublicAccounts('Accounts');
                        $config_arr=$publicaccountobj->getPublicAccountConfig();
                        
                        if($config_arr['status']=='yes')
                        {
                            if($config_arr['is_commonaccount_create']=='no')
                                $createbutton='no';
                        }
                    }
                }
                if(isPermitted($currentModule,'Import', '') == 'yes'){//导入按钮权限判断
                    $importbutton='yes';
                }
                //hzx BUG0077717 kfbcrm-收款单-进度漏斗，阶段显示单据为空时，点击新建，创建单据后 漏斗弹出层右下角显示翻页组件，关闭弹出层 序时簿右下角的翻页组件消失
                if(isset($_REQUEST['fromtype']) && $_REQUEST['fromtype'] == 'salesfunnel'){}else{
                    if($createbutton == 'yes' && $importbutton == 'yes'){//新建导入
                        $html .= $create_html.$import_html;
                    }else if($createbutton == 'yes' && $importbutton != 'yes'){//仅新建
                        $html .= $create_html.$refresh_html;
                    }
                    else if($createbutton != 'yes' && $importbutton == 'yes'){//仅导入
                        $html .= $import_html.$refresh_html;
                    }
                    else{
                        $html .= $refresh_html;//刷新试试
                    }
                }


                $html.="</div>";
			    $html.='</div></td></tr>';
			    return $html;
			}
               
        }
        $row_index=0;
        $row_arr=[];
        foreach($LISTENTITY as $entity_id=>$entity )
        {
            
              
            $redcordid=$entity_id;
            $tmp_arr=explode(",",$redcordid);
            $isfirst = true;//是否为第一单据的第一条
            if(array_key_exists($tmp_arr[0],$row_arr))
            {
                $isfirst = false;
            }
            $row_arr[$tmp_arr[0]]='a';
            
            $checkvalueid=substrTd($entity_id,1,'$currentModule');  
            if ($checkvalueid != $old_checkvalueid){
                $i++;
            }
            $rowSpan=getTableRowCell($redcordid,$LISTENTITY,$row_index);
            if($checkbox=='yes')
            {
                  if ($i%2 ==0) {
                    $html.=' <tr class="lvtColDataBj" record="'.$checkvalueid.'" module="'.$currentModule.'" onmouseover="listOnMouseOver(ld(this), \'record\')" onmouseout="listOnMouseOut(ld(this),\'On\', \'record\')" id="row_'.$entity_id.'">';
                }
                else{
                    $html.=' <tr class="lvtColData" record="'.$checkvalueid.'" module="'.$currentModule.'" onmouseover="listOnMouseOver(ld(this), \'record\')" onmouseout="listOnMouseOut(ld(this),\'on\', \'record\')" id="row_'.$entity_id.'">';
                }
            }
            else
            {
                  if ($i%2 ==0) {
                    $html.=' <tr class="lvtColDataBj" record="'.$checkvalueid.'" module="'.$currentModule.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" id="row_'.$entity_id.'">';
                }
                else{
                    $html.=' <tr class="lvtColData" record="'.$checkvalueid.'" module="'.$currentModule.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" id="row_'.$entity_id.'">';
                }
            }
          
            if($ROW_COUNT <= 0)
            {
                if ($checkvalueid != $old_checkvalueid&&$checkbox=='yes')
                {
                    $html .=' <td class="firstChild" style="width:'.$chkbox_listwidth.'px" rowspan="' .$rowSpan.'" tag="0"  headermodule="'.$currentModule.'" headername="chkbox" onclick="check_objects_parent_td(this)"><input class="checkbox-item j-all-checkbox" type="checkbox" NAME="selected_id" id="'.$checkvalueid.'" value= \''.$checkvalueid.'\'></td>';
                }
            }
            else
            {
                if ($LISTENTITY[$entity_id][0] != '&&'&&$checkbox=='yes')
                {
                   
                    $html .=' <td class="firstChild" style="width:'.$chkbox_listwidth.'px" rowspan="'.$rowSpan.'" tag="0" headermodule="'.$currentModule.'" headername="chkbox" onclick="check_objects_parent_td(this)">
                            <input class="checkbox-item j-all-checkbox" type="checkbox" NAME="selected_id" id="'.$checkvalueid.'" value= \''.$checkvalueid.'\' >
                        </td>';
                }     
            }
            $old_checkvalueid=substrTd($entity_id,1,'$currentModule');      
            $ik=0;
             $row_index++;
         
           foreach($entity as $key=>$data)
            {
                
                 $istdright="";
                  
                 if (istdRight($key,$MODULE)==true)
                 {
                    $istdright="right";
                 }
                 else
                 {
                    $istdright="left";
                 }		
			     $entity_id=$ik;
                 $ik++;
                
                 $bol=foreachArray ($entity,$entity_id);
                 //没有操作列时$bol = false;
                 if(is_object ($controller)){
                    if($entity_id>= $ROW_COUNT&&!$controller->haveoperation){
                        $bol = false;
                     }
                 }
                 $fieldname = $headerlistfieldobj[$entity_id];
                 $tmptdindex = "tdindex='$ik'";
                if($bol&&$fieldname == '')
                {
                    $tmptdindex = '';
                }
                 
                 if ($entity_id <=$ROW_COUNT && $data != '&&' &&$rowSpan> 1)
                 {
                    $html .=' <td '.$tmptdindex.' rowspan="'.$rowSpan.'" align=\''.$istdright.'\'>';
                    $html .= $data.' </td>';
                 }
                 elseif( $entity_id >= $ROW_COUNT && $data != '&&' && $bol == false && $rowSpan > 1)
                 {
                      //分录字段
                    if($bol == true && count($entity) == $ik){
                        $html .=' <td class="lastChild" '.$tmptdindex.' align=\''.$istdright.'\' >';
                        $html .= $data .' </td>';
                    }else{
                        $html .=' <td '.$tmptdindex.' align=\''.$istdright.'\' >';
                        $html .= $data .' </td>';
                    }
                 }
                 
                 
                elseif ($bol == true && $data != '&&')
                {  
                    if($currentModule=='Attachment'||$currentModule=='Documents' || $currentModule=='Users'){ //这2个模块操作按钮不合并,用户是查看界面附件信息
                        $html .=' <td class="lastChild" '.$tmptdindex.'  align=\''.$istdright.'\'>'.$data.'</td>';
                    }
                    //显示分录列，$bol == true且不是同一的第一条时，跳过
                    elseif( $entity_id >= $ROW_COUNT &&!$isfirst&& $data != '&&' && $bol == true){
                            
                    }
                    else{
                        $html .=' <td class="lastChild" '.$tmptdindex.' rowspan="'.$rowSpan.'" align=\''.$istdright.'\'>'.$data.'</td>';
                    }
                }
                 
                elseif( $data == '&&')
                {
                    
                }
                else
                {
                    if($bol == true && count($entity) == $ik){
                        $html .=' <td class="lastChild" '.$tmptdindex.' align="'.$istdright.'">' . $data . '</td>';
                    }else{
                        $html .=' <td '.$tmptdindex.' align="'.$istdright.'">' . $data . '</td>';   
                    }
                }
            }
            
	        $html .='</tr>';
         }
       return $html;
    }
    
    /**
     * edit:can
     * reason:没有明细的模块列表
     * */
    static function  createHTML($LISTENTITY,$MODULE,$ISBOLD,$ROW_HEADER,$tool_buttons,$controller,$checkbox='yes')
    {
        global $global_minversin;
        $currentModule = $controller->module;
        $i=0;
        $html=''; 
      //   $category=getParentTab();
        $chkbox_listwidth=$controller->listchkbox_width;
        $headerlistfieldobj=$controller->listViewFields;//获取列头字段
        $focus=CRMEntity::getInstance($MODULE);
       
        if(empty($LISTENTITY) || (is_array($LISTENTITY) && sizeof($LISTENTITY)<=0))
        {
            $html=	'<tr style="height: 300px;">  <td id="resize_content_tdid" style="background-color:#FFF;height:0px;padding: 0;" align="center" colspan="'.$ROW_HEADER.'">';
            $MODULE_CREATE =getTranstab($MODULE);
            $html.="<div class='warningTableContent' style='z-index:600;padding-top:30px;'>";
            $html.= "<div class='wtc_img'><img src='themes/icon2023/ld-no-records.png?v=".$global_minversin."'></div>";
			/*
			*edit: chj
			*date: 2020/10/30
			*reason: 渠道码 列表，没有数据时，特殊控制。因为目前列表的显示数据调用的是通用代码
			*/
			if($MODULE == 'ChannelCode'){
				$html.="<div class='wtc_content' style='white-space: initial;word-break: break-all;'>".getFixedLabel('Welcometousethechannelcode').'<br>'.getFixedLabel('Start').' <a module="ChannelCode" href="javascript:;" onclick="channelcode_add(0)" data-direction="top" data-type="position">'.getFixedLabel('CREATE').'</a> '.getFixedLabel('Thefirstchannelcodetoexperienceit')."</div>";
            }else{
				
                $html .= '<div class="wtc_content">'.getFixedLabel('NOTFOUNDANYRECORD').'</div>';
                // $html.="<div class='wtc_content'>".getFixedLabel('YOUCANCLICKONTHE').getFixedLabel('CREATE').getFixedLabel('ADDARECORD')."</div>";
                $html.="<div class='wtc_btn'>";

                $create_html = "<input value=".getFixedLabel('CREATE')." title=".getFixedLabel('CREATE')." ";//新建
                $create_html .= "  class='ld-button ld-button-primary' onclick= \" var objparams=new CreatePagePopup.params();objparams.params['refreshpage']='no'; CreatePagePopup.showpage('$MODULE','',objparams)\" type='button'>";
                $import_html = "<input value=".getFixedLabel('IMPORT')." title=".getFixedLabel('IMPORT')." class='ld-button' onclick=\" listviewImport('','$MODULE')\" type='button'/>";//导入
                $refresh_html = "<input class='ld-button' value='".getFixedLabel('TRYREFRESHING')."' type='button' onclick='window.location.reload();'>";//刷新试试
                
				if ($MODULE == 'HelpDesk')
					$MODULE_CREATE='Ticket';
                $createbutton = 'no';
				if (($tool_buttons['Create']['permit']=='yes'||$tool_buttons['Create'] == 'yes') && $MODULE != 'Emails' && $MODULE != 'Webmails')
                {
                    if ($MODULE != 'InventoryAccount' && $MODULE != 'InventoryQuery' && $MODULE != 'SendPayment' && $MODULE != 'PaymentPlan'){

                        if($MODULE != 'Calendar'){
                            $createbutton = 'yes';
                        }else{
                            $createbutton = 'yes';
                        }
                        if($MODULE=='Leads')
                        {
                            $publicaccountobj=new cls_PublicLeads('Leads');
                            $config_arr=$publicaccountobj->getPublicAccountConfig();
                            if($config_arr['status']=='yes')
                            {
                                if($config_arr['is_commonaccount_create']=='no')
                                    $createbutton='no';
                            }
                        }
                          
                    }
                }
                if (($tool_buttons['Import']['permit']=='yes'||$tool_buttons['Import'] == 'yes') && $MODULE != 'Emails' && $MODULE != 'Webmails'){
                    if ($MODULE != 'InventoryAccount' && $MODULE != 'InventoryQuery' && $MODULE != 'SendPayment' && $MODULE != 'PaymentPlan'){                        
                        $importbutton = 'yes';                          
                    }
                }
                
                if($createbutton == 'yes' && $importbutton == 'yes'){//新建导入
                    $html .= $create_html.$import_html;
                }else if($createbutton == 'yes' && $importbutton != 'yes'){//仅新建
                    $html .= $create_html.$refresh_html;
                }else if($createbutton != 'yes' && $importbutton == 'yes'){//仅导入
                    $html .= $import_html.$refresh_html;
                }else{
                    $html .= $refresh_html;//刷新试试
                }
			}
            $html.="<div>";
            $html.='<div></td></tr>';
            return $html;
        }
       
        foreach ($LISTENTITY as $entity_id=>$entity)
        {
            
            $redcordid=$entity_id;
            if($MODULE == 'InventoryAccount' || $MODULE == 'InventoryQuery') 
            {
                if($i % 2 == '0') 
                    $html.= '<tr class="lvtColData" onmouseover="listOnMouseOver(ld(this));" onmouseout="listOnMouseOut(ld(this),\'on\');" id="row_'.$entity_id.'">';
                else
                    $html.='<tr class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this));" onmouseout="listOnMouseOut(ld(this),\'On\');"  id="row_'.$entity_id.'">';
            }   
            else
            {
                if ($i%2 == '0')
                    $html.='<tr class="lvtColData" module="'.$MODULE.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\');" id="row_'.$entity_id.'">';
                else
                    $html.='<tr class="lvtColDataBj" module="'.$MODULE.'" onmouseover="listOnMouseOver(ld(this));" onmouseout="listOnMouseOut(ld(this),\'On\');" id="row_'.$entity_id.'">';
            }
            if ($checkbox == 'yes')
            {
                $html.='<td class="firstChild" style="width:'.$chkbox_listwidth.'px" headermodule="'.$currentModule.'" headername="chkbox" onclick="check_objects_parent_td(this)"><input class="checkbox-item j-all-checkbox aa" type="checkbox" tag="select_id_box" NAME="selected_id" id="'.$entity_id.'" value= \''.$entity_id.'\'></td>';
            }                                
            if ($MODULE == 'InventoryQuery'){
                foreach ($entity as $entity_id=>$data)
                {
                    if ($entity_id >= 4 && $entity_id <= 5)
                        $html.="<td align=\"right\">$data";
                    elseif ($entity_id >=3 && $entity_id <7)
                        $html.= '<td align="right">'.$data;
                    elseif ($entity_id < 3)
                        $html.="<td>$data";
                    else
                        $html.="<td align=\"right\">$data";
                    $html.="</td>";
                }
            }	
            else{
                $j = 1;//用来计算操作列是否存在
                $tdindex=0;

                foreach ($entity as $entity_id=>$data)
                {
                    $j++;
                    $fieldname=$headerlistfieldobj[$tdindex];
                    $bigtype='';
                    if($controller->IsDetailTableField($tdindex,$fieldname)=='no')
                    {
                        $bigtype=$focus->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'bigtype');
                        
                    }
                    $tdindex++;
                    $tmptdindex = "tdindex='$tdindex'";
                    if($controller->haveoperation&&$fieldname == '')
                    {
                        //edit:can 20220705 53117 客户问题（普阳会计），跟进记录单据列表界面，“凭证数”数字字段和“本月开票总金额”货币字段没有小编辑按钮（通用问题） 
                        $tmptdindex = '';
                    } 
                    if (istdRight($entity_id,$module)==true)
                    {    	
    					if ($entity_id >= 4 && $entity_id <= 5)
    						$html.="<td align=\"right\" $tmptdindex>$data";
                        elseif ($entity_id >=3 && $entity_id <7)
                            //zkt 20230110 BUG0060624kfbcrm  项目日志----消耗工时字段，序时簿列表页面没有小编辑
                        	$html.= '<td align="right" '.$tmptdindex.'>'.$data;
                        elseif ($entity_id < 3)
                             $html.="<td align=\"right\" $tmptdindex>$data";
                        else
                             $html.="<td align=\"right\" $tmptdindex>$data";
                    }
                    else{
                        //
                        
                        
                        if($bigtype==Field_FILEATTACHMENT)
                        {
                            //附件类型的字段
                             $html.="<td module='$MODULE' $tmptdindex record='$redcordid' fieldname='$fieldname'>";
                        }
                        else{
                            if($fieldname!=""){
                                $html.="<td $tmptdindex fieldname = '$fieldname'>";
                            }else{
                                $html.="<td class='lastChild' $tmptdindex fieldname = '$fieldname'>";
                            }
                        }
                             
						$html.=$data;
                    }
                    $html.="</td>";
                }
                if($ROW_HEADER==$j+1){
                    $html.="<td></td>";
                }
            }
            $html.="</tr>";
            $i++;
        }
        return $html;
    }    
}
?>