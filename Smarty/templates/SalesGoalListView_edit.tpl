{*<!--
/*+********************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/
-->*}
<style type="text/css">
  {literal}
    table tr.lvtColData td div, table tr.lvtColDataBj td div {width:150px;}
  {/literal}
</style>
<script>
var editgoallabel='{"EDITINGTHEOBJECT"|@getFixedLabel}';
var savegoallabel='{"KEEPTHEGOAL"|@getFixedLabel}';

{literal}
var isedit='no';
function editfrom(val)
{
    var isadmin = document.getElementById('isadmin').value;
    var tableindex=ld(".ld-ui-tabs-active").attr('tabindex');
    if(isadmin != 1)
    {
        var confirm_str = arrJsPopLabel['FORUSERSLIMIT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    /*var str=document.getElementsByName("bechosed");
    var chestr = '';
    for (i=0;i<str.length;i++)
    {
        if(str[i].checked == true)
        {
            chestr+=str[i].value+",";
        }
    }*/
    var searchscope=document.getElementById('SmOwnerSearchScope').options[document.getElementById('SmOwnerSearchScope').selectedIndex].value;
    var module_look = document.getElementById('module_look').value;
	//var url = "index.php?pageto_module=SalesGoal&pageto_action=ListView_edit";
	var addurl = "&query=true&SearchScope="+searchscope+"&module_look="+module_look;
    addurl+="&viewrangeone_year="+ld("#viewrangeone_year").val()+"&viewrangeone_month="+ld("#viewrangeone_month").val();
    addurl+="&viewrangetwo_year="+ld("#viewrangetwo_year").val()+"&viewrangetwo_month="+ld("#viewrangetwo_month").val();
    var url="index.php?pageto_module=SalesGoal&pageto_action=ListView_edit&page_addurl="+encodeURIComponent(addurl);
    var tmps={"SmOwnerSearchScope":searchscope,'viewrangeone_year':+ld("#viewrangeone_year").val()
                ,'viewrangeone_month':ld("#viewrangeone_month").val(),'viewrangetwo_year':ld("#viewrangetwo_year").val()
                ,'viewrangetwo_month':ld("#viewrangetwo_month").val(),'module_look':module_look};
    //console.log(ld("#PrompLeftCenter [tag=salesgoalvalue]").val());

    if(searchscope=='smowner_search_senior'){
        if(global_var.salesgoal !== undefined && global_var.salesgoal[tableindex] != undefined){
            tmps.senioruserid = global_var.salesgoal[tableindex];
        }else{
            tmps.senioruserid = ld('#scope_senioruserids').val();
        }
    }
    var stringurl="";
     if(isedit=='no')
    {
        ld("#editsalesgoal").val(savegoallabel);
        ldAjax("index.php?module=SalesGoal&file=ListView_edit&action=SalesGoalAjax&query=yes",tmps,function(data){
            ld("#PrompLeftCenter").html(data.result.content);
            DelProgressObjs();
            
        })
        isedit='yes';
    }
    else{
        stringurl="&alluserid="+document.getElementById('alluserid').value;
       stringurl+="&allmouth="+document.getElementById('allmouth').value;
        ld.each(ld("#PrompLeftCenter [tag=salesgoalvalue]"),function(){
            var tmpname=ld(this).attr("name");
           // tmps+="&"+tmpname+"="+ld(this).val();
           tmps[tmpname]=ld(this).val();
        })
        ldAjax("index.php?module=SalesGoal&file=Save&action=SalesGoalAjax&query=yes"+stringurl,tmps,function(data){
            ld("#PrompLeftCenter").html(data.result.content);
          ld("#editsalesgoal").val(editgoallabel);
            isedit='no';
			DelProgressObjs();
            
        })
        
       
    }
    
        
        
    //window.location.href=url;
    /*if(chestr == '')
    {
        alert(arrJsPopLabel['TOBESUREHAVECHOSE']);
        return false;
    }
    else
    {  
        window.location.href="index.php?action=ListView_edit&module=SalesGoal&query=true";
    }*/
}

function checkfrom()
{
    var viewrangeone_year= document.getElementById('viewrangeone_year').value;
    var viewrangeone_month= document.getElementById('viewrangeone_month').value;
    var viewrangetwo_year= document.getElementById('viewrangetwo_year').value;
    var viewrangetwo_month= document.getElementById('viewrangetwo_month').value;
    if(eval(viewrangeone_year) == eval(viewrangetwo_year))
    {
        if(eval(viewrangeone_month) > eval(viewrangetwo_month))
        {
            var confirm_str = arrJsPopLabel['TOBESURESTRARTNEQEND'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    else
    {
        if(viewrangeone_year > viewrangetwo_year)
        {
            var confirm_str = arrJsPopLabel['TOBESUREYEARSTARTNEQENDYEAR'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
}

{/literal}
</script>
<!--修改编码格式:统一编码：UTF-8-->
<div  id="resize_content_table_divid" style="overflow:auto">

        <div class="ld-ui-tabs">
            <ul class="ld-ui-tabs-nav">
                <li tabindex='0' onclick="SalesGoalTabClick(0)"><a href="javascript:;">{'TREEDIAGRAM'|@getFixedLabel}</a></li>
                {if $DETAILVIEW eq 1}
                    <li  tabindex='1' onclick="SalesGoalTabClick(1)"><a href="javascript:;">{'OBJECTVIEW_LOOK'|@getFixedLabel}</a></li>
                {/if}
                <li   tabindex='2' class="ld-ui-tabs-active" onclick="SalesGoalTabClick(2)"><a href="javascript:;">{'OBJECTVIEW_EDIT'|@getFixedLabel}</a></li>
                <li  tabindex='3' onclick="SalesGoalTabClick(3)"><a href="javascript:;">{'TEMPLATESALESGOALIMG'|@getFixedLabel}</a></li>
            </ul>
        </div>
        <div id="prompt" class="PromptDiv" style="display:none;">
        	<ul>
                <li>1.{'SALESGOALINSTRUCTION4'|@getFixedLabel}</li>
                <li>2.{'SALESGOALINSTRUCTION5'|@getFixedLabel}</li>
                <li>3.{'SALESGOALINSTRUCTION6'|@getFixedLabel} {'SALESGOALINSTRUCTION8'|@getFixedLabel}</li>
            </ul>
        </div>
        <form method="post" onsubmit="return checkfrom();">
        <div class="PromptDiv0" id="dv_salesgoaledit_smownerscope">
            <div class="LdShowselect" style="padding-right:20px;float:left;">
                {assign var=fldname value='SmOwnerSearchScope'}
            	<label>{'VIEWRANGE'|@getFixedLabel}</label>    
                <select onchange="SalesSmOwnerSearchScope(this,'{$MODULE}')" id="SmOwnerSearchScope" name="SmOwnerSearchScope" style="display:none">
        
                {foreach key=User_Key item=User_value from=$Merge_SmOwner}
                    {foreach key=User_id item=User_name from=$User_value}
                        {foreach key=User_name_key item=User_name_value from=$User_name}
                        
                            {if $User_id eq $SELECTEDSCOPE || $User_id eq 'SmOwner_Search_All'}
                                {assign var='optText' value=$User_name_key}
                                <option value="{$User_id}" selected="true">{$User_name_key}</option>
                            {else}
                                <option value="{$User_id}">{$User_name_key}</option>
                            {/if}
                        
                        {/foreach}
                    {/foreach}
                {/foreach}
                </select>                        
                <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','dv_salesgoaledit_smownerscope')" style="z-index:100;">
                 	<a style="width:117px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','dv_salesgoaledit_smownerscope')" href="javascript:void(0)" tabindex="-1"
                     name="cmb_a_{$fldname}">
                        <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;position: relative;top: -2px;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','dv_salesgoaledit_smownerscope')" onKeyUp="com_chosen(event,'{$fldname}','dv_salesgoaledit_smownerscope')" value="{$optText}">
                        <div>
                            <b></b>
                        </div>
            	    </a>
            	    <div style=" left:-9000px;width: 117px; top: 27px;" class="chzn-drop" name='dv_drop_{$fldname}' >
            			 <ul class="chzn-results" name="cmb_ul_{$fldname}">
            				{assign var="show" value=0}{assign var="i" value=0}
                    	   {foreach key=User_Key item=User_value from=$Merge_SmOwner}
                            {foreach key=User_id item=User_name from=$User_value}
                                {foreach key=User_name_key item=User_name_value from=$User_name}
         	                          <li  class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','dv_salesgoaledit_smownerscope')" onmouseover="cmb_limouseover(event,'{$fldname}','dv_salesgoaledit_smownerscope')">{$User_name_key}</li>
        							  {if $User_id eq 'smowner_search_senior'}
        									{assign var="show" value=1}
        								{/if}	
									  {assign var="i" value=$i+1}
                                    {/foreach}
                                {/foreach}
            	            {/foreach}
                               
                               <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
            			 </ul>
            	    </div>
                </div>
                {if $show eq 1}
            	<a class="icon-range" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}"  onclick="SmOwnerScopehightuser()"></a>
         	   	{/if}
            </div>
        	
            <label>{'TIMESLOT'|@getFixedLabel}:</label>
            <select name="viewrangeone_year" id="viewrangeone_year" class="salesgoaltimeselect btn-radius-system">
                {foreach item=last_year from=$LASTYEAR}
                    <option value="{$last_year}" {if $YEARSTART eq $last_year} selected {/if}>{$last_year}</option>
                {/foreach}
            </select>
            <select name="viewrangeone_month" id="viewrangeone_month" class="salesgoaltimeselect btn-radius-system" style='width:50px;'>
                {foreach key= year_id item=mouth from=$MOUTH_ALL}
                    <option value="{$mouth}" {if $ONEMOUTH eq $mouth} selected{/if}>{$mouth}</option>
                {/foreach}
            </select><label>{'TO'|@getFixedLabel}</label>
            <select name="viewrangetwo_year" id="viewrangetwo_year" class="salesgoaltimeselect btn-radius-system">
                {foreach item=next_year from=$LASTYEAR}  
                    <option value="{$next_year}" {if $YEARMEND eq $next_year} selected {/if}>{$next_year}</option>
                {/foreach}
            </select>
            <select name="viewrangetwo_month" id="viewrangetwo_month" class="salesgoaltimeselect btn-radius-system" style='width:50px;margin-right: 20px;'>
                {foreach key=year_id item=mouth from=$MOUTH_ALL}
                    <option value="{$mouth}" {if $SECONDMOUTH eq $mouth} selected {/if}>{$mouth}</option>
                {/foreach}
            </select>
        	<label>{'SALESINDEX'|@getFixedLabel}:</label>
            <select name="module_look" id="module_look" class="salesgoaltimeselect btn-radius-system">
                <option value="paymentamount" {if $MODULELOOK eq 'paymentamount'} selected {/if}>{'THEAMOUNTOFBACK'|@getFixedLabel}</option>
                <option value="contractamount" {if $MODULELOOK eq 'contractamount'} selected {/if} >{'CONTRACTAMOUNTS'|@getFixedLabel}</option>
                <option value="accountsnumber" {if $MODULELOOK eq 'accountsnumber'} selected {/if}>{'THECUSTOMERNUMER'|@getFixedLabel}</option>
        		{if $INVOICESTATUS eq 'yes'}
        			<option value="invoiceamount" {if $MODULELOOK eq 'invoiceamount'} selected {/if}>{'Invoiceamount1'|@getFixedLabel}</option>
        		{/if}
        		{if $OUTBOUNDORDERSTATUS eq 'yes'}
        			<option value="outboundorderamount" {if $MODULELOOK eq 'outboundorderamount'} selected {/if}>{'outamount'|@getFixedLabel}</option>
        		{/if}
{*                zxm 2022-0317 应收单 应收额目标  上海庆科*}
                {if $accountinfo eq 'sh_qingke'}
                <option value="receivableamount" {if $MODULELOOK eq 'receivableamount'} selected {/if}>{'receivableamount'|@getFixedLabel}</option>
                {/if}
            </select>
              <b onclick="editsalesgoaldefaultval()" title="设置" class="icon-homeimg icon-setgrey marT5 marL5 b" style="cursor:pointer;"></b>
            
            <input type="hidden" id='editresult' value="{$EDITRESULT}">
            <input type="hidden" id='actionname' value="{$ACTIONNAME}">
            <input type="button" onclick="SalesGoalListClick(ld(this))" value="{'QUERYTO'|@getFixedLabel}" class="E_pbtnok" style="margin-left:20px;margin-right: 20px;"/>
            <input class="E_pbtnok" name="editsalesgoal" id="editsalesgoal" onclick="return editfrom(this.value)" type="button" value="{'EDITINGTHEOBJECT'|@getFixedLabel}" {if $ISADMIN neq '1'} disabled style="background:#D4D0C8;" {else} {/if} />
            </form>
            <a class="rfloat" href="javascript:;" onclick="showprompt('prompt');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
        </div>
        <input type="hidden" id="isadmin" name="isadmin" value="{$ISADMIN}" />
        <!--中间-->
        <div class="PrompLeftCenter" id="PrompLeftCenter">
        	{include file="SalesGoalSettingAjax.tpl"}
        </div>
</div>
<input type="hidden" id="scope_senioruserids" value="{$ALLUSERID}">
<script>

ld("#resize_content_table_divid").css("width",getRightWidth()-30);
ld("#resize_content_table_divid .PrompLeftCenter").css("width",getRightWidth()-30);

setContentHeight("SalesGoal");//计算内容高度
 var Listpagepopupobj=new CrmPopup();

Listpagepopupobj.module='SalesGoal';
CrmPopup.global_listPopupObj.push(Listpagepopupobj);
Listpagepopupobj.pagetype=ListPagePopup.pagetype;//

{literal}
function editsalesgoaldefaultval(){
    //修改销售指标下拉框默认值弹出框
    //edit:can 20210128 销售目标功能优化，目标查看界面去掉目标为0的记录
   	var crmPopupobj=CrmPopup.load("","","","LdPopWidth450px",'SalesGoal',"","","","");
	crmPopupobj.prevshow();
    ldAjax("index.php?module=SalesGoal&action=SalesGoalAjax&file=SalesGoalMenuDefault",{},function(ajaxdata){
        
        crmPopupobj.setParams(ajaxdata.result.title,editsalesgoaldefaultval.save,"","LdPopWidth450px",'SalesGoal',"",ajaxdata.result.oktext,"",ajaxdata.result.canceltext,"");  
	   CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,ajaxdata.result.content);
       ld("#"+crmPopupobj.divid+" [name=salesgoalmenudefault]").val(ajaxdata.result.deploy_value);
       
    });
        
}
editsalesgoaldefaultval.save=function(){
    //修改销售指标下拉框默认值保存
    var popupobj=CrmPopup.getPopupObj('last');
    var deploy_value=ld("#"+popupobj.divid+' [name=salesgoalmenudefault]').val();
    //edit:can 20210128 销售目标功能优化，目标查看界面去掉目标为0的记录
    ldAjax("index.php?module=SalesGoal&action=SalesGoalAjax&file=SalesGoalMenuDefault&save=yes&deploy_value="+deploy_value,{},function(){
        popupobj.CancelEvent();
        popupobj=CrmPopup.getPopupObj('last');
        ld("#module_look").val(deploy_value);
        SalesGoalListClick(new Object());
    });
}
editsalesgoaldefaultval.save.funname="editsalesgoaldefaultval.save";

function SalesGoalListClick(jqueryobj){
        isedit='no';
        var tableindex=ld(".ld-ui-tabs-active").attr('tabindex');
        var searchscope=ld("#SmOwnerSearchScope").val();
        var viewrangeone_year=ld("#viewrangeone_year").val();
        var viewrangeone_month=ld("#viewrangeone_month").val();
        var viewrangetwo_year=ld("#viewrangetwo_year").val();
        var viewrangetwo_month=ld("#viewrangetwo_month").val();
        var module_look=ld("#module_look").val();
        var tmps={"SmOwnerSearchScope":searchscope,'viewrangeone_year':viewrangeone_year
                ,'viewrangeone_month':viewrangeone_month,'viewrangetwo_year':viewrangetwo_year
                ,'viewrangetwo_month':viewrangetwo_month,'module_look':module_look};
        var url="index.php?module=SalesGoal&file=ListView_edit&action=SalesGoalAjax&ajax=yes";
        
        if(searchscope=='smowner_search_senior'){
            if(global_var.salesgoal !== undefined && global_var.salesgoal[tableindex] != undefined){
                tmps.senioruserid = global_var.salesgoal[tableindex];
            }else{
                tmps.senioruserid = ld('#scope_senioruserids').val();
            }

        }
                
        ldAjax(url,tmps,function(data){
			//chj 2021/5/20 46003: （61mis.com/kfbcrm）工具-销售目标-目标设置，编辑目标时，切换销售指标，点击查询；“保存目标”按钮自动没有变为“编辑目标”
			 ld("#editsalesgoal").val(editgoallabel);
            ld("#PrompLeftCenter").html(data.result.content);
            DelProgressObjs();
        })
        
        
    }
    
    function SalesGoalTabClick(tabindex){
        var file ='';
        switch(tabindex){
            case 0:
                file ='ListView_tree';
                break;
            case 1:
                file ='ListView';
                break;
            case 2:
                file ='ListView_edit';
                break;
            case 3:
                file ='ListView_chart';
                break;
            default:
                return false;
                break;
        }
            ld.ajax({
                url:"index.php?module=SalesGoal&file="+file+"&action=SalesGoalAjax",
                type:"post",
                success:function(data)
                {
                    ChangeWebUrl("index.php?pageto_module=SalesGoal&pageto_action="+file);
                    
                    listcontentobj.html(data);
                }
                
            })
        }
{/literal}

</script>
<script>
    {literal}
        //加载tip 20200629 diony
        tooltip('.tip-items-goal', {transition: true, time: 200});
    {/literal}
</script>