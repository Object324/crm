{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Approve/Approve.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>

<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden" >
        <span class="grid-view-name dinline-block lfloat">
            <span>{'LBL_APPROVE'|@getFixedLabel}</span>
{*            <i onclick="ApproveStatusSet()" title="{'APPROVALSTATUSSETTING'|@getFixedLabel}" class="icon-picklist-set" style="cursor:pointer; margin-left: 3px;height: 24px;margin-top: -5px;"></i>*}
            {if $HelpHtml.MultiApproveList neq '' }{$HelpHtml.MultiApproveList}{/if}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select" style="display:none;" id="pick_module" name="pick_module" class="btn-radius-system width150" onchange="getCustomBlockList(this,'{$BLOCKIDSETTING}','{$FIELDIDSETTING}');">
          {foreach item=tab from=$TAB}
            {if $tab.tabid eq $BLOCKID}
              <option value="{$tab.tabid}" selected>{$tab.tabname}</option>
            {else}
              <option value="{$tab.tabid}">{$tab.tabname}</option>
            {/if}                
          {/foreach}
        </select>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a id="mobile_maininfo_create" href="javascript:;" onclick="getCreateApproveForm('','',0)" class="ld-button ld-button-primary" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
            <a href="javascript:;" onclick="ApproveStatusSet()" class="ld-button" title="{'APPROVALSTATUSSETTING'|@getFixedLabel}">{'APPROVALSTATUSSETTING'|@getFixedLabel}</a>
            <a href="javascript:;" onclick="CancelApproveProfileSet()" class="ld-button" title="{'ANTIAPPROVALAUTHORITY'|@getFixedLabel}">{'ANTIAPPROVALAUTHORITY'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_set select-input ld-wordwrap-listcontent">
    <input type="checkbox"  name="module_approve" value="" onclick="set_module_approve(this)" id="WHETHERENABLEAPPROVAL" {if $MODULE_APPROVE eq '0'}checked{/if}>
    <label class="padR10" for="WHETHERENABLEAPPROVAL" >{'WHETHERENABLEAPPROVAL'|@getFixedLabel}</label>
    <input type="checkbox" name="quick_submit" value="" onclick="set_module_approve(this)" id="ENABLEQUICKCOMMIT" {if $QUICK_SUBMIT eq '0'}checked{/if}>
    <label class="padR10" for="ENABLEQUICKCOMMIT">{'ENABLEQUICKCOMMIT'|@getFixedLabel}</label>
    <input type="checkbox" name="again_submit" value="" onclick="set_module_approve(this)" id="AllowAgainSubmitApprove" {if $AGAIN_SUBMIT eq '0'}checked{/if}>
    <label class="padR10" for="AllowAgainSubmitApprove">{'AllowAgainSubmitApprove'|@getFixedLabel}</label>
    <input type="checkbox" name="showdisabledapprove" value="" onclick="set_module_approve(this)" id="SHOWDISABLEDAPPROVE" {if $SHOWDISABLEDAPPROVE eq '0'}checked{/if}>
    <label class="padR10" for="SHOWDISABLEDAPPROVE">{'SHOWDISABLEDAPPROVE'|@getFixedLabel}</label>
    <input type="checkbox" name="noapprovalshowempty" value="" onclick="set_module_approve(this)" id="NOAPPROVALSHOWEMPTY" {if $NOAPPROVALSHOWEMPTY eq 'yes'}checked{/if}>
    <label class="padR10" for="NOAPPROVALSHOWEMPTY">{'NoApprovalShowEmpty'|@getFixedLabel}</label>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float" name="multiapprovelist">
            {include file="Approve/MultiApproveLists.tpl"}
        </div>
    </div>
</div>
</form>
<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>

<script type="text/javascript">
{literal}
    function changeApproveStatus(obj,id,tabid)
    {
         //obj.disabled=true;
   var rowIndex=obj.parentNode.parentNode.rowIndex;
   var secondcell=document.getElementById("approvelisttable").rows[rowIndex].cells[3];
   
   var columnname = ld(obj).attr('columnname');
   var status_value = '';
   if(ld(obj).is(':checked')){
        if(columnname == 'status'){
            status_value = 0;
        }else{
            status_value = 'yes';
        }
   }else{
        if(columnname == 'status'){
            status_value = 1;
        }else{
            status_value = 'no';
        }
   }
   //BUG0072466 xxy 2023-9-11 审批流程定制，若是只有一条审批流程，审批流程名称中的“是否启用”参数开启后，自动勾选“是否启用审批流程”参数 
   if(ld(obj).parents('tr:first').siblings("tr[id^=setting_]").length==0 && !ld("input[name=module_approve]").is(':checked')){
        if(ld(obj).is(':checked')){
            ld("input[name=module_approve]").prop("checked",true);
            set_module_approve(ld("input[name=module_approve]").get(0))
        }
   }
   var param = {};
   param['columnname'] = columnname;
   param['status_value'] = status_value;
   ld.ajax({
        url: 'index.php?module=Settings&action=SettingsAjax&file=changeApproveStatus&id='+id+"&blockid="+tabid,
        type: 'POST',
        data: param,
       dataType:'json',
        async: true,//
        timeout: 5000,
        success: function(data)
        {
            
            if(data.code==1)
            {
                //edit:duan 2022-2-16 关于是否启用按钮的显示优化
                getCustomBlockList(document.getElementById('pick_module'));
            }    
            else
            {
                if(ld(obj).is(':checked')){
                    ld(obj).prop('checked',false);
                }else{
                    ld(obj).prop('checked',true);
                }
                var confirm_str = arrJsPopLabel['PROCESSUSEDCANOTMODIFIED'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                $("status").style.display="none";
            }
        
        }
       
    });
    
    }
    function fieldSel(obj)
    {
        document.getElementById("selField").value="[var."+obj.value+"]";
        
    }
{/literal}

</script>